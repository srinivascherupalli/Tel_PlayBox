trigger NumberTrigger on Number__C (after insert, after update, after delete, before update) {
    
    if ( Trigger.isUpdate && Trigger.isBefore ) {
        NumberTriggerHandler.handleBeforeUpdate(Trigger.newMap, Trigger.oldMap);
    } else if (Trigger.isInsert){
        NumberTriggerHandler.handleAfterInsert(Trigger.newMap);
    } else if (Trigger.isUpdate){
        NumberTriggerHandler.handleAfterUpdate(Trigger.newMap, Trigger.oldMap);
    } else if ( Trigger.isDelete) {
        NumberTriggerHandler.handleAfterDelete(Trigger.oldMap);
    }
}