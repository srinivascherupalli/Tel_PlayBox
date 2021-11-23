/**================================================================ 
* Name: Orchestration_LinkPctoReplacedPCChown
* Description: Class to update LinkPctoReplacedPCChown
* Created Date: March 1, 2021
* Created By: Vaibhav Deshpande
===================================================================*/

global with sharing class Orchestration_LinkPctoReplacedPCChown extends Orchestration_AbstractStepHandler {
    private Map<Id, Orchestration_ProcessedRecords> processedIds = new Map<Id, Orchestration_ProcessedRecords>();
    private Id IncompleteStepId = null;
    private Map<Id, List<csord__Service__c>> ordToServiceMap = new Map<Id, List<csord__Service__c>>();
    private Map<Id, Set<Id>> stepRelationshipMap = new Map<Id, Set<Id>>();
   
    private Map<Id,cscfga__Product_Configuration__c> PCtoUpdate = new Map<Id,cscfga__Product_Configuration__c>();
    public override List<SObject> process(List<SObject> steps) {
        system.debug('steps20'+steps);
        List<SObject> sobjList=new List<SObject>(); 
        if (Orchestration_LimitsUtility.areLimitsViolated()) {
            //Cannot process the records
            return sobjList;
        }
        
        try {
            
            List<CSPOFA__Orchestration_Step__c> stepList = getStepListData(steps);
            system.debug('stepList20'+stepList);
            system.debug('orderIds'+orderIds);
             
            for (csord__Service__c serv : [SELECT Id,Name,csord__Subscription__c,csordtelcoa__Replaced_Service__r.csordtelcoa__Product_Configuration__c,csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c,csord__Order__c FROM csord__Service__c WHERE csord__Order__c IN :orderIds]) {
                if (ordToServiceMap.containsKey(serv.csord__Order__c)) {
                    ordToServiceMap.get(serv.csord__Order__c).add(serv);
                } else {
                    ordToServiceMap.put(serv.csord__Order__c, new List<csord__Service__c>{ serv });
                }
                
            }
            
            system.debug('stepList124'+stepList);
            for (CSPOFA__Orchestration_Step__c step : stepList) {
                try {
                    system.debug('step'+step);
                    if (Orchestration_LimitsUtility.areLimitsViolated()) { break;
                    }
                    Orchestration_ProcessedRecords processedRecordIds = getProcessedRecords(step);
                    system.debug('processedRecordIds'+processedRecordIds);
                    if (processedRecordIds != null) {
                        processedIds.put(step.Id, processedRecordIds);
                    }
                        
                    
                    //Check for data issue - order should be present
                    if (step.CSPOFA__Orchestration_Process__r.Order__c == null || ordToServiceMap == null || (ordToServiceMap.keyset()!=null && !ordToServiceMap.containskey(step.CSPOFA__Orchestration_Process__r.order__c))) {
                        //Updating steps as Error since no proper data linked to step
                        stepResults.put(step.Id, new stepResult('Error: Step do not have an order or subscriptions', OrchestratorConstants.OrchestratorStep.Error)); continue;
                      
                    }
                    system.debug('ordToServiceMap'+ordToServiceMap);
                     if (!hasDMLRowsLimitExceeded()) {
                    for (csord__service__c service : ordToServiceMap.get(step.CSPOFA__Orchestration_Process__r.order__c)) {
                        
                            if (processedRecordIds == null || (processedRecordIds.pcIds == null || !processedRecordIds.pcIds.contains(service.csordtelcoa__Product_Configuration__r.id))) {
                                
                                if (Orchestration_LimitsUtility.areLimitsViolated() || hasDMLRowsLimitExceeded()) {IncompleteStepId = step.Id; break;}
                                service.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c = service.csordtelcoa__Replaced_Service__c!=null && service.csordtelcoa__Replaced_Service__r.csordtelcoa__Product_Configuration__c != null ?service.csordtelcoa__Replaced_Service__r.csordtelcoa__Product_Configuration__c:null;
                                //servicesToUpdate.put(service.Id, service);
                                PCtoUpdate.put( service.csordtelcoa__Product_Configuration__r.id, service.csordtelcoa__Product_Configuration__r);
                                if (!stepRelationshipMap.containsKey(step.Id)) {
                                    stepRelationshipMap.put(step.Id, new Set<Id>{  service.csordtelcoa__Product_Configuration__r.id });
                                } else {
                                    stepRelationshipMap.get(step.Id).add(service.csordtelcoa__Product_Configuration__r.id);
                                }
                                
                            }
                        }
                        
                    }
                     else{IncompleteStepId = step.Id; break;
                     }
                    
                    if (Orchestration_LimitsUtility.areLimitsViolated() || hasDMLRowsLimitExceeded()) {IncompleteStepId = step.Id;break;
                    }
                    if (IncompleteStepId == null || IncompleteStepId != step.Id) {
                        if (!stepRelationshipMap.containsKey(step.Id)) {
                            system.debug('processedIds.get(step.Id)'+processedIds.get(step.Id));
                            if (processedIds.get(step.Id) == null || processedIds.get(step.Id).pcIds.isempty()) { stepResults.put(step.Id, new stepResult('Success - No update required as no data needed any update for this step', OrchestratorConstants.OrchestratorStep.Complete));
                            } else {stepResults.put(step.Id, new stepResult('Success: Records processed', OrchestratorConstants.OrchestratorStep.Complete));}
                        }
                    }

                } catch (Exception ex) {stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
                }
                
            }
        } catch (Exception ex) {  for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) steps) {stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
            }
        }
         system.debug('PCtoUpdate'+PCtoUpdate);
            if (!PCtoUpdate.isEmpty()) {
                updateObjects();
            }
    
        return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
    }
    
    private List<CSPOFA__Orchestration_Step__c> getStepListData(List<sObject> steps) {
        //Fetching more fields from the query
        List<CSPOFA__Orchestration_Step__c> stepList = [
            SELECT ID, Name, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, JSON__c, CSPOFA__Message__c, CSPOFA__Orchestration_Process__r.Order__c, CSPOFA__Orchestration_Process__r.Order__r.skipFulfillment__c
            FROM CSPOFA__Orchestration_Step__c
            WHERE Id IN :steps
        ];
        Set<String> stepIds = new Set<String>();
        for (CSPOFA__Orchestration_Step__c step : stepList) {
            //Get orders related to the steps
            if (step.CSPOFA__Orchestration_Process__r.Order__c != null) {
                orderIds.add(step.CSPOFA__Orchestration_Process__r.Order__c);
            }
            if (String.IsNotBlank(step.JSON__c) && step.JSON__c.equals(OrchestratorConstants.SystemConstant.AttachmentMsg)) {stepIds.add(step.Id);
            }
        }
        //Check if attachments is required
        if (stepIds.size() > 0) { getAttachmentList(stepIds);
        }
        
        //Returning the step list
        return stepList;
    }
    
    
    public override boolean hasDMLRowsLimitExceeded() {
        if (PCtoUpdate.size() + Limits.getDMLRows() < Integer.valueOf(Governor_Limits__c.getInstance().DML_Rows_limit__c)) {
            return false;
        }
        return true;
    }  
    
    public override void updateObjects() {
       
        List<Id> pcSuccessIds = new List<Id>();
        Id currentstep;
        List<Database.SaveResult> updateResult = new List<Database.SaveResult>();
   
            if (PCtoUpdate.size() > 0) {
            system.debug('PCtoUpdate190'+PCtoUpdate);
            updateResult = Database.update(PCtoUpdate.values(), false);
            system.debug('updateResult190'+updateResult);
            //Storing the subscription success Ids
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    pcSuccessIds.add(rslt.getId());
                }
            }
        }
                
              
        //Iteration over each step
        for (Id stepId : stepRelationshipMap.keySet()) {
            Boolean isFailed = false;
            currentstep = stepId;
            Orchestration_ProcessedRecords perStepSuccessIds = new Orchestration_ProcessedRecords();
            perStepSuccessIds.pcIds = new Set<String>();
            
            for (Id recId : stepRelationshipMap.get(stepId)) {
                if (pcSuccessIds.contains(recId)) {
                    perStepSuccessIds.pcIds.add(recId);
                } else if (!pcSuccessIds.contains(recId)) {isFailed = true;
                }
            }
            
            if (!isFailed && (String.isBlank(incompleteStepId) || !incompleteStepId.equals(stepId))) {
                system.debug('inside if 254');
                stepResults.put(stepId, new stepResult('Success: Records processed', OrchestratorConstants.OrchestratorStep.Complete));
                 system.debug('inside if 256');
                //move to next step
                continue;
            }
            
            
            //Adding existing data of Json
            if (processedIds.containsKey(stepId)) {if (processedIds.get(stepId).pcIds != null) {perStepSuccessIds.pcIds.addAll(processedIds.get(stepId).pcIds);
                }
                
            }
            
            if (!isFailed && !String.isBlank(incompleteStepId) && incompleteStepId.equals(stepId)) { stepResults.put(stepId, new stepResult('Success: Partial records processed', OrchestratorConstants.OrchestratorStep.InProgress, perStepSuccessIds));
            } else {
                stepResults.put(stepId, new stepResult('Error: Unable to process records', OrchestratorConstants.OrchestratorStep.Error, perStepSuccessIds));
            }
        }
      
         
    }
}