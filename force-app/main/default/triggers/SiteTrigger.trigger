trigger SiteTrigger on cscrm__Site__c (before insert, before update, before delete, 
									   after insert, after update, after delete, 
									   after undelete) {

	SiteTriggerHandler handler = new SiteTriggerHandler();

	if(Trigger.isInsert && Trigger.isBefore){
	    handler.OnBeforeInsert(Trigger.new);
	}
	else if(Trigger.isInsert && Trigger.isAfter){
	    handler.OnAfterInsert(Trigger.new);	    
	}

	else if(Trigger.isUpdate && Trigger.isBefore){
	   handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
	}
	else if(Trigger.isUpdate && Trigger.isAfter){
	    handler.OnAfterUpdate(Trigger.old,Trigger.oldMap, Trigger.new, Trigger.newMap);
	}

	else if(Trigger.isDelete && Trigger.isBefore){
	    //handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
	}
	else if(Trigger.isDelete && Trigger.isAfter){	
	    handler.OnAfterDelete(Trigger.old, Trigger.oldMap);	    
	}
}