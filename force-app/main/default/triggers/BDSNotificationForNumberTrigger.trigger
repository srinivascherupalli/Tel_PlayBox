trigger BDSNotificationForNumberTrigger on BDSNotificationForNumber__e (after insert) {
    if(Trigger.isInsert){
        BDSNotificationForNumberTriggerHandler.handleAfterInsert(Trigger.newMap);
    }
}