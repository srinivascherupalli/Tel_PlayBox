/**================================================================
 * Appirio, Inc
 * Name: Orchestration_ServiceSubscription
 * Description: Class to update create orchestration process for related Subscription->Services
 * Created Date: May 21, 2020
 * Created By: Martand Atrey
 ==================================================================
 Change.No.    Developer Name          Date          Story Description
    1.         Pawan Singh          26-04-2021       EDGE-212433  must be promoted with 21.07 sprint
	2.		   Milos Djordjevic     08/06/2021       EDGE-222326 : Modified areLimitsViolated logic check to return SObject instead of NULL

 */
global with sharing class Orchestration_ServiceSubscription extends Orchestration_AbstractStepHandler {
	//TODO Change To Dynamic need to Ask Ashish ABout this.
	private Integer orchProcessLimit = Orchestration_LimitsUtility.getOrchestrationProcessLimit();

	private Map<Id, sObject> sObjectsToInsertMap = new Map<Id, sObject>();
	private Map<Id, Id> stepRelationship = new Map<Id, Id>();
	private Id incompleteStepId;
	private final List<String> orchestrationProcessesList = new List<String>{
		OrchestratorConstants.OrchesTemplateName.serviceTemplate,
		OrchestratorConstants.OrchesTemplateName.fulfilmentSubsTemplate,
		OrchestratorConstants.OrchesTemplateName.ceaseSubsTemplate
	};

	private String subsPrefix = Schema.getGlobalDescribe().get('csord__Subscription__c').getDescribe().getKeyPrefix();
	private String servicePrefix = Schema.getGlobalDescribe().get('csord__Service__c').getDescribe().getKeyPrefix();
	private Map<Id, Orchestration_ProcessedRecords> processedIds = new Map<Id, Orchestration_ProcessedRecords>();

	public override List<SObject> process(List<SObject> steps) {
		List<SObject> sobjList = new List<SObject>(); // Added as part of EDGE-222326
		if (Orchestration_LimitsUtility.areLimitsViolated()) {
			return sobjList;  // Added as part of EDGE-222326
		}

		Boolean checkforServices = false;
		Set<Id> dontProcessOrderIds = new Set<Id>();
		List<CSPOFA__Orchestration_Step__c> stepList = new List<CSPOFA__Orchestration_Step__c>();

		try {
			stepList = (List<CSPOFA__Orchestration_Step__c>) getStepList(steps);

			Map<String, CSPOFA__Orchestration_Process_Template__c> orchesTemplates = Orchestration_Utility.getOrchestrationTemplates(orchestrationProcessesList);
			//Exit with complete if there are No templates found
			if (orchesTemplates.isEmpty()) {
				for (CSPOFA__Orchestration_Step__c step : stepList) {
					stepResults.put(step.Id, new StepResult('Error: No Orchestration Process Templates found.', OrchestratorConstants.OrchestratorStep.Error));
				}
				return processStepResults(stepList, stepResults);
			}

			//this is used later to check if the Service has a scenerio Type = DeviceReplacement
			List<Orchestration_Config__mdt> lstconFig = [
				SELECT id, developername, label, Run_Service_Orchestration__c, Run_Subscription_Orchestration__c
				FROM Orchestration_Config__mdt
				WHERE label = :Label.Device_Replacement
				LIMIT 1
			];
			if (!lstconFig.isEmpty() && (lstconFig[0].Run_Service_Orchestration__c == false || lstconFig[0].Run_Subscription_Orchestration__c == false)) {
				checkforServices = true;
			}

			//Create Map to process in the Loop
			Map<Id, List<csord__Service__c>> orderServicesMap = new Map<Id, List<csord__Service__c>>();
			for (csord__Service__c service : [
				SELECT
					Id,
					Name,
					csord__Status__c,
					csord__Order__c,
					csord__Subscription__r.Name,
					csord__Subscription__c,
					Scenario_Type__c,
					csord__Order__r.csord__Primary_Order__c,
					csord__Subscription__r.csordtelcoa__Replaced_Subscription__c,
					csord__Order__r.name,
					csord__Subscription__r.csordtelcoa__Replaced_Subscription__r.csord__Order__c,
					csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.name,
					csord__Subscription__r.toBeCancelled__c,
					csord__Subscription__r.legacy_subscription__c
				FROM csord__Service__c
				WHERE
					(csord__Order__c IN :orderIds
					OR csord__Order__r.csord__Primary_Order__c IN :orderIds)
					AND csord__Subscription__r.csord__Status__c != :OrchestratorConstants.SubscriptionStatus.PaidOut
                	AND csord__Subscription__r.csordtelcoa__Product_Configuration__r.ConfigurationType1__c != 'SolutionComponent' //EDGE-212433 added condition to Suppress creation of any orchestration processes related to order for solution subscription
			]) {
				//START Conditions below to check if the order has a service with scenerio = DeviceReplacement
				//If Order has a service with above condition then that order is marked as completed
				if (checkforServices) {
					if (orderIds.contains(service.csord__Order__c)) {
						if (dontProcessOrderIds.contains(service.csord__Order__c)) {
							continue;
						} else if (service.Scenario_Type__c == Label.Device_Replacement && !dontProcessOrderIds.contains(service.csord__Order__c)) {
							dontProcessOrderIds.add(service.csord__Order__c);
							orderServicesMap.remove(service.csord__Order__c);
						}
					} else if (orderIds.contains(service.csord__Order__r.csord__Primary_Order__c)) {
						if (dontProcessOrderIds.contains(service.csord__Order__r.csord__Primary_Order__c)) {
							continue;
						} else if (service.Scenario_Type__c == Label.Device_Replacement && !dontProcessOrderIds.contains(service.csord__Order__r.csord__Primary_Order__c)) {
							dontProcessOrderIds.add(service.csord__Order__r.csord__Primary_Order__c);
							orderServicesMap.remove(service.csord__Order__r.csord__Primary_Order__c);
						}
					}
				}
				//END Conditions below to check if the order has a service with scenerio = DeviceReplacement
				if (orderIds.contains(service.csord__Order__c)) {
					if (orderServicesMap.containskey(service.csord__Order__c)) {
						orderServicesMap.get(service.csord__Order__c).add(service);
					} else {
						orderServicesMap.put(service.csord__Order__c, new List<csord__Service__c>{ service });
					}
				} else if (orderIds.contains(service.csord__Order__r.csord__Primary_Order__c)) {
					if (orderServicesMap.containskey(service.csord__Order__r.csord__Primary_Order__c)) {
						orderServicesMap.get(service.csord__Order__r.csord__Primary_Order__c).add(service);
					} else {
						orderServicesMap.put(service.csord__Order__r.csord__Primary_Order__c, new List<csord__Service__c>{ service });
					}
				}
			}

			for (CSPOFA__Orchestration_Step__c step : stepList) {
				try {
					if (!Orchestration_LimitsUtility.areLimitsViolated()) {
						Id orderId = step.CSPOFA__Orchestration_Process__r.Order__c;
						if (dontProcessOrderIds.contains(orderId)) {
							//if the Order has a service with scenerio type = Device Replacement
							stepResults.put(step.Id, new stepResult('Success: Service has a device Replacement Scenerio.', OrchestratorConstants.OrchestratorStep.Complete));
							continue;
						}

						if (orderServicesMap.get(orderId) != null) {
							//Populate all the record Ids that are processed already
							Orchestration_ProcessedRecords processedRecordIds = getProcessedRecords(step);

							if (processedRecordIds != null) {
								processedIds.put(step.Id, processedRecordIds);
							}
							incompleteStepId = createOchestrationProcess(step.Id, orderServicesMap.get(orderId), orchesTemplates);
							if (incompleteStepId != null) {
								break;
							}
						} else {
							stepResults.put(
								step.Id,
								new stepResult('Success: Attachment Insertion not required cause no services found.', OrchestratorConstants.OrchestratorStep.Complete)
							);
						}
					} else {
						break;
					}
				} catch (Exception ex) {
					stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error));
				}
			}
		} catch (Exception ex) {
			for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) steps) {
				stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error));
			}
		}
		if (!sObjectsToInsertMap.isEmpty() && !Orchestration_LimitsUtility.areLimitsViolated())
			insertObjects();

		return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
	}

	public Id createOchestrationProcess(Id stepId, List<csord__Service__c> serviceSubsList, Map<String, CSPOFA__Orchestration_Process_Template__c> orchesTemplates) {
		//create orchestration process for all subscriptions

		for (csord__Service__c service : serviceSubsList) {
			// Subscription Fulfilment Process should not get generated for legacy subscriptions.

			if (sObjectsToInsertMap.size() >= orchProcessLimit) {
				return stepId;
			}
            Boolean isComsUpliftment = false;
            isComsUpliftment = FeatureToggle__mdt.getInstance('Orchestration_ComsUpliftment').EnableForAll__c;
            if(isComsUpliftment==true)
            {
                if (!(processedIds.get(stepId) != null && processedIds.get(stepId).serviceIds != null && processedIds.get(stepId).serviceIds.contains(service.Id)) &&
                    orchesTemplates.get(OrchestratorConstants.OrchesTemplateName.serviceTemplateNew) != null) {
                        CSPOFA__Orchestration_Process__c orches = new CSPOFA__Orchestration_Process__c();
                        orches.CSPOFA__State__c = OrchestratorConstants.OrcehstrationProcessState.Active;
                        orches.csordtelcoa__Service__c = service.Id;
                        orches.CSPOFA__Orchestration_Process_Template__c = orchesTemplates.get(OrchestratorConstants.OrchesTemplateName.serviceTemplate).id;
                        // sObjectsToInsertMap.add(orches);
                        sObjectsToInsertMap.put(service.Id, orches);
                        stepRelationship.put(service.Id, stepId);
                    }
                if (sObjectsToInsertMap.size() >= orchProcessLimit) {
                    return stepId;
                }
            }
            else{
                if (
                    !(processedIds.get(stepId) != null &&
                      processedIds.get(stepId).subsIds != null &&
                      processedIds.get(stepId).subsIds.contains(service.csord__Subscription__c)) &&
                    service.csord__Subscription__c != null &&
                    service.csord__Subscription__r.legacy_subscription__c == null &&
                    orchesTemplates.get(OrchestratorConstants.OrchesTemplateName.fulfilmentSubsTemplate) != null
                ) {
                    //CHANGED Add the Sub Orch here itself instead of creating a new Loop
                    CSPOFA__Orchestration_Process__c subOrches = new CSPOFA__Orchestration_Process__c();
                    subOrches.CSPOFA__State__c = OrchestratorConstants.OrcehstrationProcessState.Active;
                    subOrches.csordtelcoa__Subscription__c = service.csord__Subscription__c;
                    
                    if (service.csord__Subscription__r.toBeCancelled__c != null && service.csord__Subscription__r.toBeCancelled__c.equalsIgnoreCase('true')) {
                        subOrches.CSPOFA__Orchestration_Process_Template__c = orchesTemplates.get(OrchestratorConstants.OrchesTemplateName.ceaseSubsTemplate).id;
                    } else {
                        subOrches.CSPOFA__Orchestration_Process_Template__c = orchesTemplates.get(OrchestratorConstants.OrchesTemplateName.fulfilmentSubsTemplate).id;
                    }
                    sObjectsToInsertMap.put(service.csord__Subscription__c, subOrches);
                    stepRelationship.put(service.csord__Subscription__c, stepId);
                }
                if (sObjectsToInsertMap.size() >= orchProcessLimit) {
                    return stepId;
                }
                if (
                    !(processedIds.get(stepId) != null && processedIds.get(stepId).serviceIds != null && processedIds.get(stepId).serviceIds.contains(service.Id)) &&
                    orchesTemplates.get(OrchestratorConstants.OrchesTemplateName.serviceTemplate) != null
                ) {
                    CSPOFA__Orchestration_Process__c orches = new CSPOFA__Orchestration_Process__c();
                    orches.CSPOFA__State__c = OrchestratorConstants.OrcehstrationProcessState.Active;
                    orches.csordtelcoa__Service__c = service.Id;
                    orches.CSPOFA__Orchestration_Process_Template__c = orchesTemplates.get(OrchestratorConstants.OrchesTemplateName.serviceTemplate).id;
                    // sObjectsToInsertMap.add(orches);
                    sObjectsToInsertMap.put(service.Id, orches);
                    stepRelationship.put(service.Id, stepId);
                }
            }
        }
		return null;
	}

	public override void insertObjects() {
		Database.SaveResult[] insertResult = Database.insert(sObjectsToInsertMap.values(), false);
		//Storing the records
		for (String recordId : sObjectsToInsertMap.keySet()) {
			//For Insert StepRelation will contain the Record Id vs Step
			//sObjectsToInsertMap will contain the recordid to which the record to be inserted is depended on. For Ex. : OrderId vs Order's Attachment Record
			//NOTE: this Will not work if the Record to be inserted is more than 1 and those are depended on 1 record. For Eg: orderId vs Multiple attachments

			String stepId = stepRelationship.get(recordId);

			if (processedIds.get(stepId) == null) {
				processedIds.put(stepId, new Orchestration_ProcessedRecords());
			}
			if (processedIds.get(stepId).subsIds == null) {
				processedIds.get(stepId).subsIds = new Set<String>();
			}

			if (processedIds.get(stepId).serviceIds == null) {
				processedIds.get(stepId).serviceIds = new Set<String>();
			}

			if (sObjectsToInsertMap.get(recordId).Id != null) {
				//This will add the success IDs to the Wrapper
				if (recordId.startsWith(subsPrefix)) {
					processedIds.get(stepId).subsIds.add(recordId);
				} else {
					processedIds.get(stepId).serviceIds.add(recordId);
				}

				if (incompleteStepId != null && incompleteStepId.equals(stepRelationship.get(recordId))) {
					//Mark the Step Result as Inprogress
					stepResults.put(
						stepRelationship.get(recordId),
						new stepResult('In Progress: Some Records are pending', OrchestratorConstants.OrchestratorStep.InProgress, processedIds.get(stepId))
					);
				} else {
					stepResults.put(stepRelationship.get(recordId), new stepResult('Success: Attachments inserted.', OrchestratorConstants.OrchestratorStep.Complete));
				}
			} else {
				if (stepResults.containsKey(stepRelationship.get(recordId))) {
					stepResults.get(stepRelationship.get(recordId)).status = OrchestratorConstants.OrchestratorStep.Error;
					stepResults.get(stepRelationship.get(recordId)).message = ' Error: Could not process some records.';
				} else {
					stepResults.put(
						stepRelationship.get(recordId),
						new stepResult('Error: Unable to process records', OrchestratorConstants.OrchestratorStep.Error, processedIds.get(stepId))
					);
				}
			}
		}
	}

	public override List<sObject> getStepList(List<sObject> steps) {
		Set<String> stepIds = new Set<String>();

		List<CSPOFA__Orchestration_Step__c> stepList = [
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
				CSPOFA__Orchestration_Process__r.Order__c
			FROM CSPOFA__Orchestration_Step__c
			WHERE Id IN :steps
		];

		for (CSPOFA__Orchestration_Step__c step : stepList) {
			if (step.CSPOFA__Orchestration_Process__r.Order__c != null) {
				OrderIds.add(step.CSPOFA__Orchestration_Process__r.Order__c);
			}

			if (String.IsNotBlank(step.JSON__c) && step.JSON__c.equals(OrchestratorConstants.SystemConstant.AttachmentMsg)) {
				stepIds.add(step.Id);
			}
		}

		//Check if attachments is required
		if (stepIds.size() > 0) {
			getAttachmentList(stepIds);
		}

		return stepList;
	}

}