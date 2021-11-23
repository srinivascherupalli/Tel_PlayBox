@RestResource(urlMapping='/updateEmailStatus/V1')
global without sharing class EmailMessageUpdater {       
    @HttpPatch
    global static void doPatch(String eventType,String eventId, String status,String statusDescription,String notificationId,String timestamp) {
            upsert new EmailMessage(Status__c = status, Correlation_Id__c = eventId) Correlation_Id__c; 
            ProcessMultipleRecipientNotify.updateEmailDeliveryStatus(eventId,status,statusDescription);
            
            //   Status__c is the Custom Field defined on the "Email Message" Object to store the Email Status from RNMS
            //   Correlation_Id__c is the Custom Field defined on the "Email Message" Object to correlate the Email Records between SF & RNMS
     }    
}