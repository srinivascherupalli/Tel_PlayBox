/*****************************************************************
@Name: APTPS_TaskTrigger
@Author: Ruchika Patil 
@CreateDate: 19/4/2016
@Description: This is the trigger on Task object for the events: before delete, after insert & after update. 
              It prevents the task deletion of Activity History on Agreement records for profiles other than System Administrator.
              It populates Obligation due date with the closest due date on the associated Tasks.
@UsedBy: Task
******************************************************************/ 
trigger APTPS_TaskTrigger on Task (before delete, after insert, after update, before insert, before update) {
    APTPS_TaskTriggerHandler handler = new APTPS_TaskTriggerHandler();
    //Before Delete logic
    if(Trigger.isDelete && Trigger.isBefore){  
        handler.preventTaskDelete(Trigger.oldMap);
        handler.recheckObligationDueDate(Trigger.old);
    }
    //after insert, update logic
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){  
        handler.populateObligationDueDate(Trigger.new,Trigger.oldMap);
    }
    //after insert logic
    if(Trigger.isAfter && Trigger.isInsert){  
        handler.statusChangeOnImportOffline(Trigger.new);
    }
    
    //after insert, update logic
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){  
        handler.updateObligationAndRisk(Trigger.new, Trigger.newMap);
    }
    

}