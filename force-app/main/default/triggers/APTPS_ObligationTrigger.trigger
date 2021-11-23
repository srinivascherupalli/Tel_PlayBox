/*****************************************************************
@Name: APTPS_ObligationTrigger
@Author: Shishir Bose
@CreateDate: 12/10/2016
@Description: This is the trigger on Obligation object for the event: after update
              It sets the status of task to close when the obligation is set to close.
@UsedBy: Obligation
******************************************************************/ 
trigger APTPS_ObligationTrigger on Apttus_SRM__SRMObligation__c (after update) {
	APTPS_ObligationTriggerHandler handler = new APTPS_ObligationTriggerHandler();	
    //after insert, update logic
    if(Trigger.isAfter && Trigger.isUpdate){  
        handler.closeTaskOnObligationClose(Trigger.oldMap, trigger.new);
    }
}