/**================================================================
 * Appirio, Inc
 * Name: Orchestration_SetOrderStatus
 * Description: Updates CHOWN Order status to Ready for Submit
 * Created Date: 1/03/2021
 * Created By: Akanksha Jain
 ==================================================================*/
global with sharing class Orchestration_SetOrderStatus extends Orchestration_AbstractStepHandler {
	private Map<Id, Id> stepRelationship = new Map<Id, Id>();
	private String orderStatus = OrchestratorConstants.OrderStatus.ReadyForSubmit;
	Id orderRecType = Schema.SObjectType.csord__Order__c.getRecordTypeInfosByName().get('Ready for Submit').getRecordTypeId();
	//Main Process
	public override List<SObject> process(List<SObject> steps) {
		if (Orchestration_LimitsUtility.areLimitsViolated()) {
			return null;
		}
		List<CSPOFA__Orchestration_Step__c> stepList = new List<CSPOFA__Orchestration_Step__c>();

		try {
			stepList = (List<CSPOFA__Orchestration_Step__c>) getStepList(steps);
			//Create Step- Order relationship Map (To be done in ParentClass)
			for (CSPOFA__Orchestration_Step__c step : stepList) {
				stepRelationship.put(step.CSPOFA__Orchestration_Process__r.Order__c, step.Id);
			}
			//getRelatedOrderIds(stepList);
			for (CSPOFA__Orchestration_Step__c step : stepList) {
				try {
					
					if (step.CSPOFA__Orchestration_Process__r.Order__c == null) {
                        stepResults.put(step.Id, new stepResult('Error: Step do not have an order', OrchestratorConstants.OrchestratorStep.Error));     
                        continue;
                    }
					if (!Orchestration_LimitsUtility.areLimitsViolated()) 
                    {
						Id orderId = step.CSPOFA__Orchestration_Process__r.Order__c;
							if (!hasDMLRowsLimitExceeded())
                            {
                               sObjectsToUpdate.put(orderId, new csord__order__c(Id = orderId, csord__Status2__c =orderStatus,RecordTypeId = orderRecType));
							}
					} 
				} catch (Exception ex) {
					stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
				}
			}
		} catch (Exception ex) {
			for (CSPOFA__Orchestration_Step__c step : stepList) {
				stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
			}
		}

		//Update the soBjects (Order)
		if (!sObjectsToUpdate.isEmpty()) {
			updateObjects();
		}
		return processStepResults(stepList, stepResults);
	}

	

	//Generic Method implemented in AbstractStepHandler
	public override void updateObjects() {
		//Updating all the records including orders
		Database.SaveResult[] updateResult = Database.update(sObjectsToUpdate.values(), false);
		//Storing the records
		for (Database.SaveResult rslt : updateResult) {
			System.debug(rslt.getErrors());
			if (rslt.isSuccess()) {
				stepResults.put(
					stepRelationship.get(rslt.getId()),
					new stepResult('Success: Records processed - Order Status Updated', OrchestratorConstants.OrchestratorStep.Complete)
				);
			} else {
				stepResults.put(
					stepRelationship.get(rslt.getId()),
					new stepResult('Error: Unable to process records' + rslt.getErrors(), OrchestratorConstants.OrchestratorStep.Error)
				);
			}
		}
	}

	public override List<sObject> getStepList(List<sObject> steps) {
		return [
			SELECT
				ID,
				Name,
				CSPOFA__Orchestration_Process__c,
				CSPOFA__Status__c,
				CSPOFA__Completed_Date__c,
				JSON__c,
				CSPOFA__Message__c,
				CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c,
				CSPOFA__Orchestration_Process__r.cspofa__account__c,
				CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c,
				CSPOFA__Orchestration_Process__r.Order__c,
				CSPOFA__Orchestration_Process__r.Order__r.csord__Status2__c
			FROM CSPOFA__Orchestration_Step__c
			WHERE Id IN :steps
		];
	}
}