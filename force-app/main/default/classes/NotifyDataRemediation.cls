/*=========================================================================================================================
EDGE       -171186
class      -NotifyDataRemediation 
Description-Data remediation to update service level preference to any CMP or AM for production accounts
Author     -Dheeraj Bhatt
===========================================================================================================================*/
global with sharing class NotifyDataRemediation implements Database.Batchable<sObject>{
    // instance member to retain state across transactions
    public Integer recordsProcessed = 0;
    public Map<string,List<Plan__mdt>> mapOfProductAndPlan= ConstantMetadataUtility.fetchProductandPlanMetadata();
    public static map<string,Sobject> customMetadataNameValueMap=ConstantMetadataUtility.getConstantMetadataUtilityRecords('ConstantMetadataUtility__mdt');   
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'Select Id, Billing_Account__r.Billing_Account_Owner__r.email, mainCharge__r.Type__c,'+
            'csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,'+
            'csordtelcoa__Service_Number__c,csord__Subscription__r.csord__Account__c,'+
            '(Select id, IsActive__c, Communication_Method__c, Contact_Id__r.email from Notification_Preferences__r)'+ 
            ' FROM  csord__Service__c  WHERE csord__Status__c =\'Connected\' AND  mainCharge__c != NULL');
    }
    public void execute(Database.BatchableContext bc, List<csord__Service__c> serviceList){
        List<Notification_Preference__c> notificationPreferenceList = new List<Notification_Preference__c>();
        if(!serviceList.isEmpty()){
            for (csord__Service__c service : serviceList) {
                if(service.Notification_Preferences__r.isEmpty()){
                    notificationPreferenceList.addAll(NotificationPreferenceHelper.createNotificationPreference(service,mapOfProductAndPlan));
                   }
            }
        }
        if(!notificationPreferenceList.isEmpty()){
            Database.insert(notificationPreferenceList, false);
        }
    }
    public void finish(Database.BatchableContext bc){
        AsyncApexJob job = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems,CreatedBy.Email   FROM AsyncApexJob where Id =:BC.getJobId()];
        If(job.NumberOfErrors > 0 || test.isRunningTest()){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] { customMetadataNameValueMap.containsKey('NotifyDataRemediation_Email')? String.valueOf(customMetadataNameValueMap.get('NotifyDataRemediation_Email').get('Value__c')):''};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Alert: NotifyDataRemediation batch process failure ' + job.Status  + ' Batch ID : '+BC.getJobId());
            mail.setPlainTextBody('records processed ' + job.TotalJobItems +   'with '+ job.NumberOfErrors + ' failures.');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}