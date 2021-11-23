trigger APTPS_ComponentsTrigger on APTPS_Component__c (after insert, after update, after delete)
{
    APTPS_ComponentsTriggerHandler handler = new APTPS_ComponentsTriggerHandler();
    if(Trigger.isInsert && Trigger.isAfter)
    {
        handler.handleAllAfterEvents(Trigger.New);
    }
    
    if(Trigger.isUpdate && Trigger.isAfter)
    {
        handler.handleAllAfterEvents(Trigger.New);
    }
    
    if(Trigger.isDelete && Trigger.isAfter)
    {
        handler.handleAllAfterEvents(Trigger.Old);
    }
}