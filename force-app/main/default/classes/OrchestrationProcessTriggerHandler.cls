public with sharing class OrchestrationProcessTriggerHandler {

	public void OnBeforeInsert(CSPOFA__Orchestration_Process__c[] newRecords) {
        
    }

    public void OnAfterInsert(CSPOFA__Orchestration_Process__c[] newRecords) {
    }

    public void OnBeforeUpdate(CSPOFA__Orchestration_Process__c[] oldRecords, 
    						   CSPOFA__Orchestration_Process__c[] updatedRecords, 
                               Map<ID, CSPOFA__Orchestration_Process__c> newMap) {
    }

    public void OnAfterUpdate(CSPOFA__Orchestration_Process__c[] oldRecords, 
    						  Map<ID, CSPOFA__Orchestration_Process__c> oldMap, 
                              CSPOFA__Orchestration_Process__c[] updatedRecords, 
                              Map<ID, CSPOFA__Orchestration_Process__c> updatedMap) {
    	
    	OrchestrationProcessTriggerHelper.rollupCancellationStatus(oldRecords, oldMap, updatedRecords, updatedMap);
    }
	

    public void OnBeforeDelete(CSPOFA__Orchestration_Process__c[] deletedRecords, 
    						   Map<ID, CSPOFA__Orchestration_Process__c> oldMap) {
    }

    public void OnAfterDelete(CSPOFA__Orchestration_Process__c[] deletedRecords, 
    						  Map<ID, CSPOFA__Orchestration_Process__c> oldMap) {
    }
	

}