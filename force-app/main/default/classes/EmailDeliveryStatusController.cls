public with sharing class EmailDeliveryStatusController {
    @AuraEnabled
    public static List<EmailDeliveryStatus__c> getEmailMessage(String RelatedId) {
        system.debug('Record Id is'+RelatedId);
        
        List<csord__Order__c > orderId = [Select id from csord__Order__c where id =: RelatedId];
        List<csord__Subscription__c> subId = [Select id from csord__Subscription__c where id =: RelatedId];
        List<EmailDeliveryStatus__c> EmailStatusList = new List<EmailDeliveryStatus__c>();
          
        if(!Orderid.isEmpty())
        {
        EmailStatusList = [SELECT Id,name,RecipientEmail__c,Status__c FROM EmailDeliveryStatus__c where Order__c=:RelatedId];
        }
        if(!subId.isEmpty())
        {
        EmailStatusList = [SELECT Id,name,RecipientEmail__c,Status__c FROM EmailDeliveryStatus__c where Subscription__c=:RelatedId];
        }
        
        return EmailStatusList;
      }
}