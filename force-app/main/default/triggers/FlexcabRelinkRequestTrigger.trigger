trigger FlexcabRelinkRequestTrigger on Flexcab_Relink_Request__c (before insert, after insert) {
   /*if(Trigger.isInsert){
        if(Trigger.isBefore){
            FlexcabRelinkRequestTriggerHandler.ProcessRecordsBeforeInsert(Trigger.new);
        }
        if(Trigger.isAfter){
            FlexcabRelinkRequestTriggerHandler.ProcessRecords(Trigger.newMap);
        }
    }
    */
}