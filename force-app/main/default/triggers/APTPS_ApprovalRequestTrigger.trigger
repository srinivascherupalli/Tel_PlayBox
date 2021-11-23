/*****************************************************************
@Name: APTPS_ApprovalRequestTrigger
@Author: Shishir Bose
@CreateDate: 16/04/2016 
@Description: This is the trigger on Approval Reuqest object for the 
events: after update
@UsedBy: Approval Request 
******************************************************************/ 
trigger APTPS_ApprovalRequestTrigger on Apttus_Approval__Approval_Request__c (after update)
{
    APTPS_ApprovalRequestTriggerHandler handler = new APTPS_ApprovalRequestTriggerHandler();
    public static boolean runOnce = true;
    
    if(Trigger.isUpdate && Trigger.isAfter){  
        if(runOnce)
        {
            handler.handleAfterUpdateEvents(trigger.new, Trigger.oldMap);            
            runOnce = false;
        }
    }
}