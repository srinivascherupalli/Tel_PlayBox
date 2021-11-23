trigger MCR_Trigger on Migration_Change_Request__c (before insert, before update,after insert, after update) {
    if(Trigger.isAfter && Trigger.isUpdate) {
        new MCR_TriggerHandler().run();
    }
}