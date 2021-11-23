/********************************************************************************
EDGE       -140733
Class       -SubscriptionLockUnlockController
Description -ability to Lock NGUC subscription in SFDC/CS during number port out,
So that the subscription cannot be modified by another user.
Author      -Dheeraj Bhatt
********************************************************************************/
public with sharing class SubscriptionLockUnlockController {
    public static map<string,Sobject>  customMetadataNameValueMap=ConstantMetadataUtility.getConstantMetadataUtilityRecords('ConstantMetadataUtility__mdt');   
    /**********************************************************************************************************
EDGE       -140733
Method      -getSubscriptions
Description -get subscription list as per subscription status selected by user in in Port out screen in UI.
Author      -Dheeraj Bhatt
************************************************************************************************************/
    @AuraEnabled 
    public static List<csord__Subscription__c> getSubscriptions(String accountId,String status) {
        return [SELECT id,Name,csordtelcoa__Subscription_Number__c,ConfigSpecID__c,csord__Order__c,CreatedDate,
                csord__Status__c,csord__Account__c FROM csord__Subscription__c WHERE csord__Account__c =: accountId AND csord__Status__c=:status AND ConfigSpecID__c =:Label.ProductSpecificationNgUc];
    }
    
    /**************************************************************************************************************
EDGE       -140733
Method      -submitSubscriptions
Description -Change subscription status to Active or  Pending Port Out on selection of Lock/Unlock Subscription
Author      -Dheeraj Bhatt
***************************************************************************************************************/
    @AuraEnabled  
    public static void submitSubscriptions(List<csord__Subscription__c> subscriptionList,String status){
        Try{
            List<csord__Subscription__c> updatedSubscriptionList=new List<csord__Subscription__c>();
            if(!subscriptionList.isEmpty()){
                for (csord__Subscription__c subs : subscriptionList) {
                    if(customMetadataNameValueMap.containsKey('Active') && customMetadataNameValueMap.get('Active').get('Value__c') == status
                       && customMetadataNameValueMap.containsKey('PendingPortOut')){
                           subs.csord__Status__c=String.valueOf(customMetadataNameValueMap.get('PendingPortOut').get('Value__c'));
                       }
                    else if(customMetadataNameValueMap.containsKey('PendingPortOut') 
                            && customMetadataNameValueMap.get('PendingPortOut').get('Value__c') == status && customMetadataNameValueMap.containsKey('Active')){
                                subs.csord__Status__c=String.ValueOf(customMetadataNameValueMap.get('Active').get('Value__c'));
                            }
                    updatedSubscriptionList.add(subs);
                }
                if(!updatedSubscriptionList.IsEmpty()){
                    update updatedSubscriptionList;
                }
            }
        }
        Catch(exception ex){
            system.debug('Exception occured at Line number '+Ex.getLineNumber()+' due to '+ex.getMessage()); 
        }
    }
}