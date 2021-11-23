trigger NumberGroupTrigger on Number_Group__c (before insert, before update, after update) {
    if(Trigger.isInsert && Trigger.isBefore){
        NumberGroupTriggerHandler.handleBeforeInsert(Trigger.new);
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        NumberGroupTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
    }
	 else if(Trigger.isUpdate && Trigger.isAfter){
        NumberGroupTriggerHandler.handleAfterUpdate(Trigger.newMap, Trigger.oldMap);
    }
}