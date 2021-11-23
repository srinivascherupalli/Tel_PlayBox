trigger NotificationTrigger on Notification__c (before insert) {
    if((trigger.isBefore && Trigger.isInsert)){
        NotificationHandler.validateNotificationFields(trigger.new);
    }
}