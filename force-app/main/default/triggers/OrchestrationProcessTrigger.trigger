trigger OrchestrationProcessTrigger on CSPOFA__Orchestration_Process__c (before insert, before update, before delete,
																	  	 after insert, after update, after delete, 
																	  	 after undelete) {

	OrchestrationProcessTriggerHandler handler = new OrchestrationProcessTriggerHandler();

	if(Trigger.isInsert && Trigger.isBefore) {
	    handler.OnBeforeInsert(Trigger.new);
	}
	else if(Trigger.isInsert && Trigger.isAfter) {
	    handler.OnAfterInsert(Trigger.new);	    
	}

	else if(Trigger.isUpdate && Trigger.isBefore) {
	   handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
	}
	else if(Trigger.isUpdate && Trigger.isAfter) {
	    handler.OnAfterUpdate(Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
	}

	else if(Trigger.isDelete && Trigger.isBefore) {
	    handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
	}
	else if(Trigger.isDelete && Trigger.isAfter) {	
	    handler.OnAfterDelete(Trigger.old, Trigger.oldMap);	    
	}

}