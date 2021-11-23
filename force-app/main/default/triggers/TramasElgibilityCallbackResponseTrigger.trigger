/*
* @Author : Robin Chawla
* @Date : 20 May 2019
* @Desc :Trigger class for TramasElgibilityCallbackResponse__c object
* @Jira : EDGE-84282 Notify Sales user when TM1 check has completed.
* @Test class:TramasEligibilityCallbackTriggerTest
*/
trigger TramasElgibilityCallbackResponseTrigger on TramasElgibilityCallbackResponse__c (after insert, after update, before insert, before update) {
    
    TramasElgibilityCallbackTriggerHandler handler=new TramasElgibilityCallbackTriggerHandler();
    
    
    if( Trigger.isInsert )
    {
        if(Trigger.isBefore)
        {
            handler.onBeforeInsert(trigger.New);
        }
        else
        {
            handler.onAfterInsert(trigger.New);
        }
    }
    else if ( Trigger.isUpdate )
    {
        if(Trigger.isBefore)
        {
            handler.onBeforeUpdate(trigger.New ,trigger.Old,Trigger.NewMap,Trigger.OldMap);
        }
        else
        {
            handler.onAfterUpdate(trigger.New ,trigger.Old,Trigger.NewMap,Trigger.OldMap);
        }
    }
}