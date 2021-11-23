/*****************************************************************
@Name: APTPS_ObligationTriggerHandler
@Author: Shishir Bose
@CreateDate: 12/10/2016 
@Description: This is the trigger handler for the Obligation trigger
@UsedBy: APTPS_ObligationTriggerHandler 
******************************************************************/ 
public class APTPS_ObligationTriggerHandler {

    public void closeTaskOnObligationClose(Map<id,Apttus_SRM__SRMObligation__c> mapOldObligation, 
                                           List<Apttus_SRM__SRMObligation__c> obligationList)
    {
        List<Id> obligationIds = new List<Id>();
        //Get the obligations whose status changed to close
        for(Apttus_SRM__SRMObligation__c obligation: obligationList)
        {
            if(obligation.APTPS_Status__c == 'Closed' && mapOldObligation.get(obligation.Id).APTPS_Status__c != 'Closed')
            {
                obligationIds.add(obligation.Id);
            }
        }    
        
        if(obligationIds.size() > 0 )
        {
            closeTasks(obligationIds);
        }
    }
    
    private void closeTasks(List<Id> obligationIds)
    {
        //Set the status of all tasks to completed for closed obligation 
        List<Task> tasksToBeUpdated = new List<Task>();
        for(Task tsk : [select Id, WhatId, Status from Task where WhatId in : obligationIds])
        {
            tsk.Status = APTPS_Constants.COMPLETED_STATUS;
            tasksToBeUpdated.add(tsk);
        }
        if(tasksToBeUpdated.size() > 0)
        {
            update tasksToBeUpdated;
        }
    }
    
}