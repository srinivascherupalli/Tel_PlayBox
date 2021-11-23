trigger sowItemTrigger on SOW_Items__c (before update) {
    if(trigger.isBefore && trigger.isUpdate){
    	SOWItemTriggerHandler.updateSOWApprovalRequired(Trigger.oldMap, Trigger.newMap);	
    }
}