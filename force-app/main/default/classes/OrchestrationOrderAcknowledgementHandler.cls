/**************************************************************
 Name: OrchestrationOrderAcknowledgementHandler
 Description: Class to update ServiceSpecs-->Services statuses
**************************************************************/
global with sharing class OrchestrationOrderAcknowledgementHandler {

	global class UpdateServiceStatusInProgress implements CSPOFA.ExecutionHandler{
	/**************************************************************
	  Name: process
	  Parameters: List<SObject> steps
	  Return Type: List<SObject>
	  Description: Class to update ServiceSpecs->Services statuses
	*******************************************************************/
	    public List<SObject> process(List<SObject> steps){
	        List<CSPOFA__Orchestration_Step__c> result = new List<CSPOFA__Orchestration_Step__c>();
	        List<CSPOFA__Orchestration_Step__c> stepList= (List<CSPOFA__Orchestration_Step__c>)steps;
	        List<Id> serviceIds = new List<Id>();
	        List<Id> orchesIds= new List<Id>();
			
	        for(CSPOFA__Orchestration_Step__c step: stepList)
	            orchesIds.add(step.CSPOFA__Orchestration_Process__c);
	        
	        system.debug(orchesIds);
	        List<CSPOFA__Orchestration_Process__c> orchList = [Select Id, Name, Order__c, csordtelcoa__Service__c from CSPOFA__Orchestration_Process__c where Id IN:orchesIds];
	        System.debug('orchList ::'+orchList);
	        for(CSPOFA__Orchestration_Process__c  orch : orchList)
	            serviceIds.add(orch.csordtelcoa__Service__c);
			
	        system.debug('serviceIds ::'+serviceIds);
	        
	        updateServiceStatus(serviceIds, Label.MO_status_in_progress);
			
	        for(CSPOFA__Orchestration_Step__c step : stepList){
	            step.CSPOFA__Status__c = Label.Complete;
	            step.CSPOFA__Completed_Date__c=Date.today();
	            step.CSPOFA__Message__c = Label.Custom_Step_Succeeded;
	            result.add(step);
	        }
	        return result;
	    }
	    
	    @TestVisible 
	    public void updateServiceStatus(List<Id> serviceIds, String targetStatus){
            if(!serviceIds.isEmpty()){
                ServiceSpecificationUtils.updatesServiceSpecsStatus(serviceIds, targetStatus);
            }
	    }

	}
}