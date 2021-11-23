/****************************************************************************
@Name: DealSupportRequestTrigger.
@Author:  Sravanthi Velegapudi
@CreateDate: 10/04/2018
@Description: This is a Trigger on DealSupportRequest object 
********************************************************************************/
trigger DealSupportRequestTrigger on Deal_Support_Request__c (before insert,before Update) {
    if(Trigger.isBefore && (Trigger.isInsert)){  
        DealSupportRequestTriggerHandler dsrTriggerHandler=new DealSupportRequestTriggerHandler();
        dsrTriggerHandler.PricingSupportDSRCheck(trigger.new);
    }
    if(Trigger.isBefore && (Trigger.isUpdate)){  
        DealSupportRequestTriggerHandler dsrTriggerHandler=new DealSupportRequestTriggerHandler();
        dsrTriggerHandler.updateCompletedDate(trigger.new);
    }
    
}