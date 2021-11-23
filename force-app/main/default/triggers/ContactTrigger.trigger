//EDGE-27948: Added before update context to the trigger
trigger ContactTrigger on Contact (before insert, before update, after insert, after update) {
    
    if(EnvironmentalSettings.isTriggerDisabled('ContactTrigger')|| BatchAccountAssignment.isBatchAccountAssignment){
        return;
    }
    
    ContactTriggerHandler ct=new ContactTriggerHandler();
    if(Trigger.isBefore && Trigger.isInsert){
        ct.OnBeforeInsert(Trigger.new);
    }
    //EDGE-27948: Captured before update context trigger condtion
    if(Trigger.isBefore && Trigger.isUpdate){
        ct.onBeforeUpdate(Trigger.new, Trigger.newMap,Trigger.oldMap);
    }
    if(Trigger.isAfter && Trigger.isInsert){
        ct.onAfterInsert(trigger.new,trigger.newMap);
    } 
    if(Trigger.isAfter && Trigger.isUpdate){
        ct.onAfterUpdate(trigger.new,trigger.newMap,trigger.oldMap);
    }
}