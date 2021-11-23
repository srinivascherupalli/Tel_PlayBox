global class ProcessOrderNotificationsBatch implements database.Batchable<sObject> {
    global database.QueryLocator start(Database.BatchableContext bc){
        return (database.getQueryLocator('Select Id, Name, Status__c, Internal_Error_Description__c, eventTimeStamp__c, eventType__c, externalOrderId__c, notificationAttributes__c, orderItemDetails__c, orderItemId__c, orderItemVersion__c, Request__c, sourceSystem__c, errorDetails__c From Notification__c Where Status__c = \'Pending\' Order By ExternalOrderId__c limit '+Label.NotificationBatchSize));
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        new BulkifiedOrderNotifications().sendBulkNotifications((List<Notification__c>)scope);
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
}