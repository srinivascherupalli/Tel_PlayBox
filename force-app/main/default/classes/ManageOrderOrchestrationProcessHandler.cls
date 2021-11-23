public with sharing class ManageOrderOrchestrationProcessHandler {

	public static void createOrderOrchestrationProcess(List<String> orderIds){
		List<CSPOFA__Orchestration_Process__c> newProcesses = new List<CSPOFA__Orchestration_Process__c>();
		String orderProcessName = 'Order Fulfilment Process';
		List<CSPOFA__Orchestration_Process_Template__c> processTemplates = [SELECT Id, Name FROM CSPOFA__Orchestration_Process_Template__c WHERE Name =:orderProcessName LIMIT 1];
		CSPOFA__Orchestration_Process_Template__c processTemplate = new CSPOFA__Orchestration_Process_Template__c();
		if(!processTemplates.isEmpty()){
			processTemplate = processTemplates[0];
		}
		if(!orderIds.isEmpty() && processTemplate.Id != null){
			for(String orderId: orderIds){
				CSPOFA__Orchestration_Process__c newProcess = new CSPOFA__Orchestration_Process__c();
				newProcess.CSPOFA__Orchestration_Process_Template__c = processTemplate.Id;
				newProcess.Order__c = orderId;
				newProcess.CSPOFA__State__c = 'Active';

				newProcesses.add(newProcess);
			}
		}

		if(!newProcesses.isEmpty()){
			insert newProcesses;
		}

	}


}