/**================================================================ 
* Name: Orchestration_EvaluateChownOrder
* Description: Class to update service and subscriptions with service number and subscription number with replaced    data for chown orders 
* Created Date:02/03/2021
* Created By: Prajakta
===================================================================
1. Updated		Mukta Wadhwani		DIGI-31946 Added condition to populate network ServiceId in new CHOWN subscription.
===================================================================*/

global with sharing class Orchestration_EvaluateChownOrder extends Orchestration_AbstractStepHandler {
    private Map<Id, Orchestration_ProcessedRecords> processedIds = new Map<Id, Orchestration_ProcessedRecords>();
    private Map<Id, csord__service__c> serviceMap = new Map<Id, csord__service__c>();
    private Map<Id,csord__Subscription__c> subMap = new Map<Id,csord__Subscription__c>();
    //Store multiple records for a step at a place, use set to avoid duplication
    private Map<Id, Set<Id>> stepRelationshipMap = new Map<Id, Set<Id>>();
    private Map<Id, List<csord__Subscription__c>> ordToSubsMap = new Map<Id, List<csord__Subscription__c>>();
    private Map<Id, List<csord__Service__c>> subsToServiceMap = new Map<Id, List<csord__Service__c>>();
    private Map<Id, csord__Service__c> servicesToUpdate = new Map<Id, csord__Service__c>();
    private Map<Id, csord__Subscription__c> subsToUpdate = new Map<Id, csord__Subscription__c>();
    private Id IncompleteStepId = null;
    
    
    public override List<SObject> process(List<SObject> steps) {
        system.debug('steps:'+steps); 
        List<SObject> sobjList=new List<SObject>();  
        if (Orchestration_LimitsUtility.areLimitsViolated()) {
            //Cannot process the records
            return sobjList;
        }
        
        //Exception Handling
        try {
            List<CSPOFA__Orchestration_Step__c> stepList = getStepListData(steps);
            system.debug('stepList:'+stepList);
                   
                for (csord__Subscription__c sub : [Select Id, csord__Order__c,csordtelcoa__Replaced_Subscription__c,csordtelcoa__Subscription_Number__c,csordtelcoa__Replaced_Subscription__r.csordtelcoa__Subscription_Number__c,csordtelcoa__Replaced_Subscription__r.csordtelcoa__Replaced_Subscription__c,csordtelcoa__Replaced_Subscription__r.csordtelcoa__Replaced_Subscription__r.NetworkServiceId__c from csord__Subscription__c where csord__Order__c IN :orderIds]) {
                    
                    if (ordToSubsMap.containsKey(sub.csord__Order__c)) {
                        ordToSubsMap.get(sub.csord__Order__c).add(sub);
                    } else {
                        ordToSubsMap.put(sub.csord__Order__c, new List<csord__Subscription__c>{ sub });
                    }
                        
                } 
                 
                for (csord__service__c ser : [SELECT Id,csord__Order__c,csordtelcoa__Replaced_Service__c,Action_Type__c,Scenario_Type__c,csordtelcoa__Service_Number__c,csordtelcoa__Replaced_Service__r.csordtelcoa__Service_Number__c,csord__Subscription__c,csord__Order__r.Product_Basket__r.BasketType__c FROM csord__Service__c WHERE csord__Order__c IN :orderIds]) {
                        if (subsToServiceMap.containsKey(ser.csord__Subscription__c)) {
                            subsToServiceMap.get(ser.csord__Subscription__c).add(ser);
                        } else {
                            subsToServiceMap.put(ser.csord__Subscription__c, new List<csord__Service__c>{ ser });
                       }                                               
                    }
                
                
            //Step processing
            for (CSPOFA__Orchestration_Step__c step : stepList) {
                try {
                    
                    if (Orchestration_LimitsUtility.areLimitsViolated()) {  break;} 
                    Orchestration_ProcessedRecords processedRecordIds = getProcessedRecords(step); 
                    if (processedRecordIds != null) {processedIds.put(step.Id, processedRecordIds);
                    }
                    
                    //Check for data issue - order should be present
                    if (step.CSPOFA__Orchestration_Process__r.Order__c == null || ordToSubsMap == null || (ordToSubsMap.keyset()!=null && !ordToSubsMap.containskey(step.CSPOFA__Orchestration_Process__r.order__c))) {
                        //Updating steps as Error since no proper data linked to step
                        stepResults.put(step.Id, new stepResult('Error: Step do not have an order or subscriptions', OrchestratorConstants.OrchestratorStep.Error));
                        system.debug('stepResults:'+stepResults);
                        //Check the next step
                        continue;
                    }
                    
                    
                    for (csord__subscription__c subscription : ordToSubsMap.get(step.CSPOFA__Orchestration_Process__r.order__c)) {
                        
                        if (processedRecordIds == null || (processedRecordIds.subsIds == null || !processedRecordIds.subsIds.contains(subscription.Id))) {
                            if (Orchestration_LimitsUtility.areLimitsViolated() || hasDMLRowsLimitExceeded()) {IncompleteStepId = step.Id;break;
                            }
                        
                        if(subscription.csordtelcoa__Replaced_Subscription__c!= null){           
                            subscription.csordtelcoa__Subscription_Number__c = subscription.csordtelcoa__Replaced_Subscription__r.csordtelcoa__Subscription_Number__c;
                            if(subscription.csordtelcoa__Replaced_Subscription__r.csordtelcoa__Replaced_Subscription__c != null &&
                            String.isNotBlank(subscription.csordtelcoa__Replaced_Subscription__r.csordtelcoa__Replaced_Subscription__r.NetworkServiceId__c))//Added if condition to populate network serviceId as part of DIGI-31946
                            	subscription.NetworkServiceId__c = subscription.csordtelcoa__Replaced_Subscription__r.csordtelcoa__Replaced_Subscription__r.NetworkServiceId__c;
                            subsToUpdate.put(subscription.id,subscription);
                            system.debug('subsToUpdate:'+subsToUpdate);
                            if (!stepRelationshipMap.containsKey(step.Id)) {stepRelationshipMap.put(step.Id, new Set<Id>{ subscription.Id });
                            } else {
                                stepRelationshipMap.get(step.Id).add(subscription.Id);
                            }
                            
                        }
                        
                        for (csord__service__c service : subsToServiceMap.get(subscription.Id)) {
                            
                            if (processedRecordIds == null || (processedRecordIds.serviceIds == null || !processedRecordIds.serviceIds.contains(service.Id))) {
                                
                            if (Orchestration_LimitsUtility.areLimitsViolated() || hasDMLRowsLimitExceeded()) {
                                //terminate the loop
                                IncompleteStepId = step.Id;
                                break;
                            }
                            
                            if(service.csordtelcoa__Replaced_Service__c!= null){
                                service.csordtelcoa__Service_Number__c = service.csordtelcoa__Replaced_Service__r.csordtelcoa__Service_Number__c;
                                //if(service.Action_Type__c!= null){
                                if(service.csord__Order__r.Product_Basket__r.BasketType__c.containsIgnoreCase('Incoming')){ //added as part of EDGE-210310
                                    service.Scenario_Type__c = Label.CHOWN;}
                                servicesToUpdate.put(service.id,service);
                                system.debug('servicesToUpdate:'+servicesToUpdate);
                                if (!stepRelationshipMap.containsKey(step.Id)) {
                                    stepRelationshipMap.put(step.Id, new Set<Id>{ service.Id });
                                } else {
                                    stepRelationshipMap.get(step.Id).add(service.Id);
                                }
                                
                            }
                         }   
                        }  
                     }    
                    }
                    
                    if (Orchestration_LimitsUtility.areLimitsViolated() || hasDMLRowsLimitExceeded()) {
                        //terminate the loop
                        IncompleteStepId = step.Id;
                        break;
                    }
                    
                    if (IncompleteStepId == null || IncompleteStepId != step.Id) {

                        if (!stepRelationshipMap.containsKey(step.Id)) {
                            if (processedIds.get(step.Id) == null || processedIds.get(step.Id).subsIds.isempty() && processedIds.get(step.Id).serviceIds.isempty()) {
                            stepResults.put(step.Id, new stepResult('Success - No update required as no data needed any update for this step', OrchestratorConstants.OrchestratorStep.Complete));
                            system.debug('stepResults:'+stepResults);
                            } else {system.debug('inside else==');
                                stepResults.put(step.Id, new stepResult('Success: Records processed', OrchestratorConstants.OrchestratorStep.Complete));
                                system.debug('stepResults:'+stepResults);}
                    }
                  }
                        
                } catch (Exception ex) {
                    for (CSPOFA__Orchestration_Step__c st : (List<CSPOFA__Orchestration_Step__c>) steps) {
                        stepResults.put(st.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));}
                }
            }
           
        }catch (Exception ex) {
            for (CSPOFA__Orchestration_Step__c step1 : (List<CSPOFA__Orchestration_Step__c>) steps) {
                stepResults.put(step1.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));}
        }
        
        
        if (!subsToUpdate.isEmpty() ||!servicesToUpdate.isEmpty() ) {
            updateObjects();}
            
        return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
    }
    
    
    public override void updateObjects() {
        
        //Success DML subscription Ids
        List<Id> subsSuccessIds = new List<Id>();
        //Success DML service Ids
        List<Id> serviceSuccessIds = new List<Id>();
        List<Database.SaveResult> updateResult = new List<Database.SaveResult>();
        
        //Updating all the subscription records
        if (subsToUpdate.size() > 0) {
            updateResult = Database.update(subsToUpdate.values(), false);
            
            //Storing the  subscriptionsuccess Ids
            for (Database.SaveResult rslt : updateResult) { if (rslt.isSuccess()) {subsSuccessIds.add(rslt.getId());}
            }
        }
        
        //Updating all the service records
        if (servicesToUpdate.size() > 0) {
            updateResult = Database.update(servicesToUpdate.values(), false);
            
            //Storing the service success Ids
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    serviceSuccessIds.add(rslt.getId());
                }
            }
        }
        
        
        //Iteration over each step
        for (Id stepId : stepRelationshipMap.keySet()) {
            Boolean isFailed = false;
            Orchestration_ProcessedRecords perStepSuccessIds = new Orchestration_ProcessedRecords();
            //Initializing the attachmentIds Set
            perStepSuccessIds.subsIds = new Set<String>();
            perStepSuccessIds.serviceIds= new Set<String>();
            
            for (Id recId : stepRelationshipMap.get(stepId)) {
                if (subsSuccessIds.contains(recId)) {
                    perStepSuccessIds.subsIds.add(recId);
                } else if (serviceSuccessIds.contains(recId)) {
                    perStepSuccessIds.serviceIds.add(recId);
                } else if (!(subsSuccessIds.contains(recId) || serviceSuccessIds.contains(recId))) {isFailed = true;}
            }
            
            if (!isFailed && (String.isBlank(incompleteStepId) || !incompleteStepId.equals(stepId))) {
                stepResults.put(stepId, new stepResult('Success: Records processed', OrchestratorConstants.OrchestratorStep.Complete));
                system.debug('stepResults:'+stepResults);
                //move to next step
                continue;
            }
            
            //Adding the previous stored ids - error/partial processed case
             if (processedIds.containsKey(stepId)) {
            if (processedIds.get(stepId).serviceIds != null) {
                perStepSuccessIds.serviceIds.addAll(processedIds.get(stepId).serviceIds);}
            //added for cpu time out issue
            if (processedIds.get(stepId).subsIds != null) {
                perStepSuccessIds.subsIds.addAll(processedIds.get(stepId).subsIds);}
            }
            
            if (!isFailed && !String.isBlank(incompleteStepId) && incompleteStepId.equals(stepId)) {
                stepResults.put(stepId, new stepResult('Success: Partial records processed', OrchestratorConstants.OrchestratorStep.InProgress, perStepSuccessIds));
                system.debug('stepResults:'+stepResults);
            } else {
                stepResults.put(stepId, new stepResult('Error: Unable to process records', OrchestratorConstants.OrchestratorStep.Error, perStepSuccessIds));}
        } 
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
            if (String.IsNotBlank(step.JSON__c) && step.JSON__c.equals(OrchestratorConstants.SystemConstant.AttachmentMsg)) {
                stepIds.add(step.Id);}
        }
        //Check if attachments is required
        if (stepIds.size() > 0) {
            getAttachmentList(stepIds);}       
        //Returning the step list
        return stepList;
    }
    
    
    public override boolean hasDMLRowsLimitExceeded() {
        if (servicesToUpdate.size() + subsToUpdate.size() + Limits.getDMLRows() < Integer.valueOf(Governor_Limits__c.getInstance().DML_Rows_limit__c)) {
            return false;
      }
        //Limit Hit
        return true;
    }
    
}