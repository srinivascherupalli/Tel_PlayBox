/******************************************************************************************************************************
Class Name : CaptureSubNicknameOrderClass
Test Class : TestCaptureSubNicknameOrderClass
===============================================================================================================================
Sr.No.  Developer           Date         Sprint                   Story Description              
1.      Aman Soni			19/03/2021	 EDGE-199911(New Class)   Capture Nickname against mobile service in order journey
******************************************************************************************************************************/
public with sharing class CaptureSubNicknameOrderClass{   
    /*  
    * Method Name      : getSubscriptionsRecords 
    * Input Parameter  : String orderId
    * Return Parameter : List<SubscriptionWrapperData>
    * Description      : will return all the Subscriptions against the input order to LWC Comp  
    * Owner            : Aman Soni
    * Jira             : EDGE-199911
    */
    @AuraEnabled
    public static List<SubscriptionWrapperData> getSubscriptionsRecords(String orderId){
        List<SubscriptionWrapperData> subsFinalList = new List<SubscriptionWrapperData>();
        Set<csord__Subscription__c> subset = new Set<csord__Subscription__c>();
            if(String.isNotBlank(orderId)){
                subset = Model_Subscription.getSubsNicknameForOrder(orderId);
            }
            if(!subset.isEmpty()){
                subsFinalList = finalSubscriptions(subset);
            }                     
        return subsFinalList;   
    }

    @AuraEnabled
    public static List<csord__Subscription__c> toBeUpdatedSubNicknames(String subscriptions){
        List<SubscriptionWrapperData> subscriptionsList = (List<SubscriptionWrapperData>)System.JSON.deserialize(subscriptions, List<SubscriptionWrapperData>.Class);
        Map<Id,String> subWrapMap = new Map<Id,String>();
        for(SubscriptionWrapperData sub : subscriptionsList){
            subWrapMap.put(sub.Id, sub.nickname);
        }
        List<csord__Subscription__c> subsList = new List<csord__Subscription__c>();
        for(csord__Subscription__c subRec : [select id,Nickname__c from csord__Subscription__c where id IN :subWrapMap.keySet()]){
            if(subWrapMap.containsKey(subRec.id)){
                subRec.Nickname__c = subWrapMap.get(subRec.id);
                subsList.add(subRec);
            }
        }
        if(!subsList.isEmpty()){
            update subsList;
        }
        return subsList;
    }

    /*  
    * Method Name      : finalSubscriptions
    * Input Parameter  : Set<csord__Subscription__c> subsSet
    * Return Parameter : List<SubscriptionWrapperData>
    * Description      : will return the metadata record
    * Owner            : Aman Soni
    * Jira             : EDGE-199911
    */
    public static List<SubscriptionWrapperData> finalSubscriptions(Set<csord__Subscription__c> subsSet){
        List<SubscriptionWrapperData> subsFinalWrapList = new List<SubscriptionWrapperData>();
        if(!subsSet.isEmpty()){
            for(csord__Subscription__c sub : subsSet){
                SubscriptionWrapperData subWrap = new SubscriptionWrapperData();             
                subWrap.subscriptionName = sub.Name;
                subWrap.subscriptionNumber = sub.csordtelcoa__Subscription_Number__c;
                subWrap.serviceID = sub.serviceMSISDN__c;
                subWrap.billingAccNumber = sub.Billing_Account__r.Billing_Account_Number__c;
                subWrap.nickname = sub.Nickname__c;
                subWrap.Id = sub.Id;             
                subsFinalWrapList.add(subWrap);
            }
        }
        return subsFinalWrapList;
    } 
}