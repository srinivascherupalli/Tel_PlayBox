trigger CaseAndWOTrigger on Case_and_Work_Order_Data__e (after insert) {
    CaseAndWOTriggerHandler handler = new CaseAndWOTriggerHandler(trigger.new);
    if(trigger.isAfter){
        handler.beforeInsert();
    }
}