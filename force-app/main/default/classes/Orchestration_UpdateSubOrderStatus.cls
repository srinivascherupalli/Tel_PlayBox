/**================================================================
 * Appirio, Inc
 * Name: Orchestration_UpdateSubOrderStatus
 * Description: Checks if all the Subscriptions are in either Active Or Suspended Status:
 *              IF yes then updates the Order to Completed
 *              Else udpate the Status to "In Error"
 * Created Date: May 19, 2020
 * Created By: Martand Atrey
 * Sr.No.    Developer Name        Date          Description
    1		 Gnana          	 08/06/2021      EDGE-222326 : Modified areLimitsViolated logic check to return SObject instead of NULL
==================================================================*/
global with sharing class Orchestration_UpdateSubOrderStatus extends Orchestration_AbstractStepHandler {
	private Map<Id, Id> stepRelationship = new Map<Id, Id>();
	private Map<Id, String> orderStatusMap = new Map<Id, String>();
	private final List<String> subscriptionStatusesList = new List<String>{ OrchestratorConstants.SubscriptionStatus.Active, OrchestratorConstants.SubscriptionStatus.Suspended };

	//Main Process
	public override List<SObject> process(List<SObject> steps) {
		List<SObject> sobjList=new List<SObject>();// Added as part of EDGE-222326
        if (Orchestration_LimitsUtility.areLimitsViolated()) {
            //return null;// Commented as part of EDGE-222326
			return sobjList;// Added as part of EDGE-222326
        }
		List<CSPOFA__Orchestration_Step__c> stepList = new List<CSPOFA__Orchestration_Step__c>();

		try {
			stepList = (List<CSPOFA__Orchestration_Step__c>) getStepList(steps);
			//Create Step- Order relationship Map (To be done in ParentClass)
			//system.debug('ok test'+stepList[0].CSPOFA__Orchestration_Process__r.Order__c);
			//system.debug('ok test2222'+stepList[0].CSPOFA__Orchestration_Process__r.Order__r.Name);
			for (CSPOFA__Orchestration_Step__c step : stepList) {
				stepRelationship.put(step.CSPOFA__Orchestration_Process__r.Order__c, step.Id);
			}
			getRelatedOrderIds(stepList);

			//Get all the Orders Sub to calculate the status
			getOrderStatusMap(orderIds);
			for (CSPOFA__Orchestration_Step__c step : stepList) {
				try {
					
					if (step.CSPOFA__Orchestration_Process__r.Order__c == null) {
                        //Updating steps as Error since no proper data linked to step
                        stepResults.put(step.Id, new stepResult('Error: Step do not have an order or subscriptions', OrchestratorConstants.OrchestratorStep.Error));
                        //Check the next step
                        continue;
                    }
					
					//check for Limits
					if (!Orchestration_LimitsUtility.areLimitsViolated()) {
						Id orderId = step.CSPOFA__Orchestration_Process__r.Order__c;
						String OrderCurrentStatus;
						if (orderStatusMap.containsKey(orderId)) {
							OrderCurrentStatus = step.CSPOFA__Orchestration_Process__r.Order__r.csord__Status2__c;

							if (!hasDMLRowsLimitExceeded()) {
								//If the orderStatus isdifferent from New then Add to UpdateList
							
								if (OrderCurrentStatus != orderStatusMap.get(orderId)) {
									sObjectsToUpdate.put(orderId, new csord__order__c(Id = orderId, csord__Status2__c = orderStatusMap.get(orderId)));
								} else {
									stepResults.put(
										step.Id,
										new stepResult('Success: Records processed - Order Status already Updated', OrchestratorConstants.OrchestratorStep.Complete)
									);
								}
							} else {
								break;
							}
						} else {
							stepResults.put(step.Id, new stepResult('Success: No Subscriptions found.', OrchestratorConstants.OrchestratorStep.Complete));
						}
					} else {
						break;
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

	public void getOrderStatusMap(Set<Id> primaryOrderIds) {
		for (csord__Subscription__c sub : [
			SELECT id, csord__Order__c, csord__Status__c
			FROM csord__Subscription__c
			WHERE csord__Order__c IN :primaryOrderIds
			ORDER BY csord__Order__c
		]) {
			if (!(subscriptionStatusesList).contains(sub.csord__Status__c)) {
				orderStatusMap.put(sub.csord__Order__c, OrchestratorConstants.OrderStatus.InError);
			} else if (!orderStatusMap.containsKey(sub.csord__Order__c)) {
				orderStatusMap.put(sub.csord__Order__c, OrchestratorConstants.OrderStatus.Completed);
			}
		}
	}

	//Generic Method implemented in AbstractStepHandler
	public override void updateObjects() {
		//Updating all the records including orders and subscription
		Database.SaveResult[] updateResult = Database.update(sObjectsToUpdate.values(), false);
		//Storing the records
		for (Database.SaveResult rslt : updateResult) {
			//stepRelationship will contain only subscription therefore avoiding updated order records
			//if(stepRelationship.containsKey(rslt.getId())){
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