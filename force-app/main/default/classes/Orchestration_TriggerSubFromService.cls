/**================================================================
* Name: Orchestration_TriggerSubFromService
* Description: Class to update create orchestration process for related Subscription
* Created Date: 
* Created By: 
==================================================================*/
global with sharing class Orchestration_TriggerSubFromService extends Orchestration_AbstractStepHandler {
    
    private Integer orchProcessLimit = Orchestration_LimitsUtility.getOrchestrationProcessLimit();
    
    private Map<Id, sObject> sObjectsToInsertMap = new Map<Id, sObject>();
    private Map<Id, Id> stepRelationship = new Map<Id, Id>();
    private Id incompleteStepId;
    private final List<String> orchestrationProcessesList = new List<String>{
        OrchestratorConstants.OrchesTemplateName.svcFulfillmentProvision,
            OrchestratorConstants.OrchesTemplateName.svcFulfillmentActivation,
            OrchestratorConstants.OrchesTemplateName.autoCompleteSubsTemplate,
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
            
            //Create Map to process in the Loop
            Map<Id, csord__Service__c> servicesMap = new Map<Id, csord__Service__c>();
            List<csord__Service__c>serviceList = [
                SELECT
                Id,
                Name,
                csord__Status__c,
                csord__Order__c,
                csord__Subscription__r.Name,
                csord__Subscription__c,
                csord__Subscription__r.csord__Status__c,
                csord__Subscription__r.Trigger_RTS__c,
                Scenario_Type__c,
                csord__Order__r.csord__Primary_Order__c,
                csord__Subscription__r.csordtelcoa__Replaced_Subscription__c,
                csord__Order__r.name,
                csord__Subscription__r.csordtelcoa__Replaced_Subscription__r.csord__Order__c,					
                csord__Subscription__r.toBeCancelled__c,
                csord__Subscription__r.legacy_subscription__c
                FROM csord__Service__c
                WHERE
                Id IN :serviceIds					
                AND csord__Subscription__r.csord__Status__c != :OrchestratorConstants.SubscriptionStatus.PaidOut
               // AND csord__Subscription__r.csordtelcoa__Product_Configuration__r.ConfigurationType1__c != 'SolutionComponent' //EDGE-212433 added condition to Suppress creation of any orchestration processes related to order for solution subscription
            ];
            for(csord__Service__c service:serviceList){
                if (service.csord__Subscription__c!=null) {                
                    servicesMap.put(service.csord__Subscription__c, service );
                    system.debug('servicesMap '+servicesMap);
                }
            }
            
            
            for (CSPOFA__Orchestration_Step__c step : stepList) {
                try {
                    if (!Orchestration_LimitsUtility.areLimitsViolated()) {
                        Id subscriptionId = step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__c;
                        system.debug('subscriptionId###'+subscriptionId);
                        system.debug('subscription###'+servicesMap.get(subscriptionId));
                        if (servicesMap.get(subscriptionId) != null) {
                            //Populate all the record Ids that are processed already
                            Orchestration_ProcessedRecords processedRecordIds = getProcessedRecords(step);
                            
                            if (processedRecordIds != null) {
                                processedIds.put(step.Id, processedRecordIds);
                            }
                            csord__Service__c subtoCreate=servicesMap.get(subscriptionId);
                            
                            //Active, Inactive, Failed, Closed, Cancelled
                            if(subtoCreate.csord__Subscription__r.csord__Status__c =='Active' || subtoCreate.csord__Subscription__r.csord__Status__c =='Inactive' ||subtoCreate.csord__Subscription__r.csord__Status__c =='Failed'
                               || subtoCreate.csord__Subscription__r.csord__Status__c =='Closed' || subtoCreate.csord__Subscription__r.csord__Status__c =='Cancelled'){
                                   incompleteStepId = createOrchestrationProcess(step.Id, subtoCreate, orchesTemplates.get(OrchestratorConstants.OrchesTemplateName.autoCompleteSubsTemplate).id); //autoCompleteSubsTemplate
                               }
                            else if(subtoCreate.csord__Subscription__r.csord__Status__c =='Provisioned' && subtoCreate.csord__Subscription__r.Trigger_RTS__c ==False){
                                incompleteStepId = createOrchestrationProcess(step.Id, subtoCreate, orchesTemplates.get(OrchestratorConstants.OrchesTemplateName.svcFulfillmentProvision).id); //svcFulfillmentProvision
                            }
                            else if(subtoCreate.csord__Subscription__r.csord__Status__c =='Ready for Activation'){
                                incompleteStepId = createOrchestrationProcess(step.Id, subtoCreate, orchesTemplates.get(OrchestratorConstants.OrchesTemplateName.svcFulfillmentActivation).id); //svcFulfillmentActivation
                            }	
                            else if(subtoCreate.csord__Subscription__r.csord__Status__c =='Provisioned' && subtoCreate.csord__Subscription__r.Trigger_RTS__c== True){
                                incompleteStepId = createOrchestrationProcess(step.Id, subtoCreate, orchesTemplates.get(OrchestratorConstants.OrchesTemplateName.ceaseSubsTemplate).id); //ceaseSubsTemplate
                            }
                            else
                                stepResults.put(step.Id, new stepResult('Success: No records to process', OrchestratorConstants.OrchestratorStep.Complete));  
                            if (incompleteStepId != null) {
                                break;
                            }
                        } else {
                            stepResults.put(
                                step.Id,
                                new stepResult('Success: No services found.', OrchestratorConstants.OrchestratorStep.Complete)
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
                               
    public Id createOrchestrationProcess(Id stepId, csord__Service__c subscriptioToCreate, Id templateId) {
        if (sObjectsToInsertMap.size() >= orchProcessLimit) {
            return stepId;
        }
        if (!(processedIds.get(stepId) != null &&
              processedIds.get(stepId).subsIds != null &&
              processedIds.get(stepId).subsIds.contains(subscriptioToCreate.csord__Subscription__c)) && subscriptioToCreate!=null && templateId!=null)
        {
            CSPOFA__Orchestration_Process__c subOrches = new CSPOFA__Orchestration_Process__c();
            subOrches.CSPOFA__State__c = OrchestratorConstants.OrcehstrationProcessState.Active;
            subOrches.csordtelcoa__Subscription__c = subscriptioToCreate.csord__Subscription__c;               
            subOrches.CSPOFA__Orchestration_Process_Template__c = templateId;//orchesTemplates.get(OrchestratorConstants.OrchesTemplateName.fulfilmentSubsTemplate).id;
            sObjectsToInsertMap.put(subscriptioToCreate.csord__Subscription__c, subOrches);
            stepRelationship.put(subscriptioToCreate.Id, stepId);
        }           
        system.debug('Orchestration process List '+sObjectsToInsertMap.values());
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
                }
                
                if (incompleteStepId != null && incompleteStepId.equals(stepRelationship.get(recordId))) {
                    //Mark the Step Result as Inprogress
                    stepResults.put(
                        stepRelationship.get(recordId),
                        new stepResult('In Progress: Some Records are pending', OrchestratorConstants.OrchestratorStep.InProgress, processedIds.get(stepId))
                    );
                } else {
                    stepResults.put(stepRelationship.get(recordId), new stepResult('Success: Records inserted.', OrchestratorConstants.OrchestratorStep.Complete));
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
            CSPOFA__Orchestration_Process__r.Order__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__c
            FROM CSPOFA__Orchestration_Step__c
            WHERE Id IN :steps
        ];
        
        for (CSPOFA__Orchestration_Step__c step : stepList) {
            if (step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c != null) {
                serviceIds.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c);
            }
            
            if (String.IsNotBlank(step.JSON__c) && step.JSON__c.equals(OrchestratorConstants.SystemConstant.AttachmentMsg)) {
                stepIds.add(step.Id);
            }
        }
                                   
                                   //Check if attachments is required
                                   //if (stepIds.size() > 0) {
                                   //getAttachmentList(stepIds);
                                   //}
                                   
return stepList;
    }
                        
}