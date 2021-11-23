trigger SOWTrigger on SOW__c (after update) {
    if((trigger.isAfter && Trigger.isUpdate)){
        SOWTriggerHandler.updateBasketStage(trigger.oldMap, trigger.newMap);
    }
}