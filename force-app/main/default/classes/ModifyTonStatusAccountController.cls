/******************************************************************************************************************************
Class Name : ModifyTonStatusAccountController
Test Class : ModifyTonStatusAccountControllerTest
===============================================================================================================================
Sr.No.     Developer                Date         Sprint          Story            Story Description              
1.      Sarfraj Ahmad      01/07/2021        21.09         DPG-5729     [Modify TON Barring Status for an account]
2.      Krunal             10/11/2021       21.15           DIGI-37863
******************************************************************************************************************************/
 
    /*  
    * Method Name      : getSubscriptionsRecordsByAccountId 
    * Input Parameter  : String orderId
    * Return Parameter : List<SubscriptionWrapperData>
    * Description      : will return all the Subscriptions against the input order to LWC Comp  
    * Owner            : Sarfraj Ahmad
    * Jira             : DPG-5729
    */

public with sharing class ModifyTonStatusAccountController {
    public static final String SUCCESS_MSG = 'Success';
    public static final String ERROR_MSG = 'The following service has an active TON subscription, and must be disconnected before status can be changed to barred: ';
    @AuraEnabled
    public static List<SubscriptionWrapperData> getSubscriptionsRecordsByAccountId(String accountId){
        System.debug('Profile : ' + System.UserInfo.getProfileId());
        System.debug('Inside  getSubscriptionsRecordsByAccountId Mehthod with Account Id :: ' +  accountId);
        List<SubscriptionWrapperData> subScriptionsWrapper = null;
        if(null != accountId && !String.isBlank(accountId)){
            System.debug('Inside If for null check of account Id' );
            subScriptionsWrapper = new List<SubscriptionWrapperData>();
            List<csord__Subscription__c> subsciptions = getSubscriptionsByAccountId(accountId);
            if(null != subsciptions && !subsciptions.isEmpty()){
                for(csord__Subscription__c subscription : subsciptions) {
                    SubscriptionWrapperData subScriptionWrap = new SubscriptionWrapperData();
                    subScriptionWrap.Id  = subscription.Id;
                    subScriptionWrap.subscriptionName = subscription.Name;
                    subScriptionWrap.subscriptionNumber = subscription.csordtelcoa__Subscription_Number__c;
                    subScriptionWrap.serviceID = subscription.serviceMSISDN__c;
                    subScriptionWrap.billingAccNumber = subscription.Billing_Account__r.Billing_Account_Number__c;
                    subScriptionWrap.tonBarringStatus = subscription.TON_Barring_Status__c;
                    System.debug(' in for loop  subScriptionWrap ::  ' + subScriptionWrap );
                    subScriptionsWrapper.add(subScriptionWrap);
                }
            }
        }
        System.debug('subScriptionsWrapper :: ' + subScriptionsWrapper );
        return subScriptionsWrapper;
    }
    @AuraEnabled
    public static String updateTonStatus(String subscriptions){
        
        
        system.debug('inside updateTonStatus....');
        String status = SUCCESS_MSG;
        system.debug('subscriptions : ' + subscriptions);
        
        List<SubscriptionWrapperData> subscriptionsList = (List<SubscriptionWrapperData>)System.JSON.deserialize(subscriptions, List<SubscriptionWrapperData>.Class);
        Map<Id,String> subWrapMap = createUpdateSubscriptionMap(subscriptionsList);
        
        List<csord__Subscription__c> subsList = new List<csord__Subscription__c>();
        for(csord__Subscription__c subRec : [select id, Name, TON_Barring_Status__c, csordtelcoa__Subscription_Number__c,serviceMSISDN__c, 
                                                (select id, name, csord__Status__c from csord__Services__r)from csord__Subscription__c 
                                                where id IN :subWrapMap.keySet()]){
            if(subWrapMap.containsKey(subRec.id)){
                subRec.TON_Barring_Status__c = subWrapMap.get(subRec.id);
                subsList.add(subRec);
                if(null != subRec.csord__Services__r && !subRec.csord__Services__r.isEmpty()){
                    for(csord__Service__c service : subRec.csord__Services__r){
                        system.debug('Service Name : ' + service.Name + ' ====  Subscription Name : ' + subRec.Name + '  ==== Ton Status: ' + subRec.TON_Barring_Status__c + '   === Service Status' +service.csord__Status__c);
                        if('Telstra One Number'.equalsIgnoreCase(service.Name) && 'Connected'.equalsIgnoreCase(service.csord__Status__c)   && 'Barred'.equalsIgnoreCase(subWrapMap.get(subRec.id))){
                            status = ERROR_MSG + subRec.serviceMSISDN__c;
                            return status;
                        }
                    }
                } else {
                    continue;
                }
             }
        }
       if(!subsList.isEmpty() && SUCCESS_MSG ==status){
            if(csord__Subscription__c.SObjectType.getDescribe().isAccessible() && Schema.SObjectType.csord__Subscription__c.fields.TON_Barring_Status__c.isAccessible()){
                update subsList;
            }
            
        }
        
        return status;
    }

    public static Map<Id,String> createUpdateSubscriptionMap(List<SubscriptionWrapperData> subscriptionsList){
        Map<Id,String> subWrapMap = new Map<Id,String>();
        for(SubscriptionWrapperData sub : subscriptionsList){
            subWrapMap.put(sub.Id, sub.tonBarringStatus);
        }
        return subWrapMap;
    }


    public static List<csord__Subscription__c> getSubscriptionsByAccountId(String accountId){
        system.debug('Account ID : ' +  accountId);
        List<csord__Subscription__c> returnSubscriptions = null;
        if(csord__Subscription__c.SObjectType.getDescribe().isAccessible() && Schema.SObjectType.csord__Subscription__c.fields.Name.isAccessible()
        && Schema.SObjectType.csord__Subscription__c.fields.Id.isAccessible() && Schema.SObjectType.csord__Subscription__c.fields.csordtelcoa__Subscription_Number__c.isAccessible() 
        && Schema.SObjectType.csord__Subscription__c.fields.serviceMSISDN__c.isAccessible() && Schema.SObjectType.Billing_Account__c.fields.Billing_Account_Number__c.isAccessible() 
        && Schema.SObjectType.csord__Subscription__c.fields.TON_Barring_Status__c.isAccessible() ){
            String notAllowTONSubStatusEnvVariable = EnvironmentVariable.get('notAllowTONSubscriptionStatus');
            List<String> subscriptionStatus = notAllowTONSubStatusEnvVariable.split(',');
            system.debug('Inside Access check.........');
            List<csord__Subscription__c> subscriptions = [SELECT Id,Name,csordtelcoa__Subscription_Number__c, serviceMSISDN__c, Billing_Account__r.Billing_Account_Number__c,
                        TON_Barring_Status__c, csordtelcoa__Product_Configuration__r.Name,csord__Account__r.Id,csord__Account__c,csord__Status__c from csord__Subscription__c where csord__Account__c = : accountId and 
                       csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c = 'DMCAT_ProductSpecification_001196' and csord__Status__c not in :subscriptionStatus];
            system.debug('===== ' +subscriptions);
            if(null != subscriptions && !subscriptions.isEmpty()){
                system.debug('Inside subscriptions empty check.........');
                returnSubscriptions = new List<csord__Subscription__c>();
                for(csord__Subscription__c subscription : subscriptions){
                    system.debug('Name :  ' + subscription.csordtelcoa__Product_Configuration__r.Name);
                    if(subscription.csordtelcoa__Product_Configuration__r.Name.containsIgnoreCase('handheld')){
                        system.debug('Inside If.');
                        returnSubscriptions.add(subscription);
                    }
                }
            }
       }
        return returnSubscriptions;
    }
    

    
}