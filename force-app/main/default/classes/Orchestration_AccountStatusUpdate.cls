/**================================================================
 * Appirio, Inc
 * Name: Orchestration_AccountStatusUpdate
 * Description: Updates the acoount status to Acquired if subscription is sent for billing successfully
 * Created Date: May 19, 2020
 * Created By: Martand Atrey
 ==================================================================*/

global with sharing class Orchestration_AccountStatusUpdate extends Orchestration_AbstractStepHandler {
	private Map<Id, Id> stepRelationship = new Map<Id, Id>();
	public override List<SObject> process(List<SObject> steps) {
		if (Orchestration_LimitsUtility.areLimitsViolated()) {
			system.debug('stopping execution as limit breached.....');
			return null;
		}
		List<CSPOFA__Orchestration_Step__c> stepList = new List<CSPOFA__Orchestration_Step__c>();

		try {
			stepList = (List<CSPOFA__Orchestration_Step__c>) getStepList(steps);
			getRelatedSubscriptionIds(stepList);

			Map<Id, csord__Subscription__c> subscriptionMap = new Map<Id, csord__Subscription__c>(
				[
					SELECT Id, csord__Account__c, csord__Account__r.Customer_Status__c
					FROM csord__Subscription__c
					WHERE Id IN :subscriptionIds AND csord__Subscription__c.csord__Account__r.Customer_Status__c = 'Active'
				]
			);
			for (CSPOFA__Orchestration_Step__c step : stepList) {
				try {
					
					if (step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c == null ) {
                        //Updating steps as Error since no proper data linked to step
                        stepResults.put(step.Id, new stepResult('Error: Step do not have an associated subscription', OrchestratorConstants.OrchestratorStep.Error));
                        //Check the next step
                        continue;
                    }
					
					if (Orchestration_LimitsUtility.areLimitsViolated()) {
						//terminate the loop
						break;
					}

					csord__Subscription__c sub = subscriptionMap.get(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);

					if (
						sub == null || (sub != null && sub.csord__Account__c != null && sub.csord__Account__r.Customer_Status__c == 'Acquired') ||
						sObjectsToUpdate.containsKey(sub.csord__Account__c)
					) {
						stepResults.put(step.Id, new stepResult('Success: No Updation required.', OrchestratorConstants.OrchestratorStep.Complete));
						continue;
					} else {
						if (!hasDMLRowsLimitExceeded()) {
							sObjectsToUpdate.put(sub.csord__Account__c, new Account(Id = sub.csord__Account__c, Customer_Status__c = 'Acquired'));
							stepRelationship.put(sub.csord__Account__c, step.Id);
						}
					}
				} catch (Exception ex) {
					stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
				}
			}
		} catch (Exception ex) {
			for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) steps) {
				stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
			}
		}
		if (!sObjectsToUpdate.isEmpty() && !Orchestration_LimitsUtility.areLimitsViolated()) {
			updateObjects();
		}
		return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
	}
	//override getStepList to fetch necessry field from steps
	public override List<sObject> getStepList(List<sObject> steps) {
		List<CSPOFA__Orchestration_Step__c> stepList = [
			SELECT ID, CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Account__c
			FROM CSPOFA__Orchestration_Step__c
			WHERE Id IN :steps
		];

		return stepList;
	}

	//override Method implemented in AbstractStepHandler
	public override void updateObjects() {
		//Updating all the records including orders and subscription
		Database.SaveResult[] updateResult = Database.update(sObjectsToUpdate.values(), false);
		//Storing the records
		for (Database.SaveResult rslt : updateResult) {
			//stepRelationship will contain only subscription therefore avoiding updated order records
			//if(stepRelationship.containsKey(rslt.getId())){
			if (rslt.isSuccess()) {
				stepResults.put(
					stepRelationship.get(rslt.getId()),
					new stepResult('Success: Account Customer Status updated to Acquired.', OrchestratorConstants.OrchestratorStep.Complete)
				);
			} else {
				//record updation failed there related step updated
				stepResults.put(stepRelationship.get(rslt.getId()), new stepResult('Error: Unable to process records', OrchestratorConstants.OrchestratorStep.Error));
			}
		}
	}
}