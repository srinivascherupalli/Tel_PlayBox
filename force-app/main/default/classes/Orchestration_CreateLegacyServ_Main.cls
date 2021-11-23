global with sharing class Orchestration_CreateLegacyServ_Main extends Orchestration_AbstractStepHandler {
	 String str='';
     Map<String, Object> payloadMap=new Map<String,Object>();
     public Map<Id, Orchestration_ProcessedRecords> processedIds = new Map<Id, Orchestration_ProcessedRecords>();
    
     public override List<SObject> process(List<SObject> steps) {
         if (Orchestration_LimitsUtility.areLimitsViolated()) {
            system.debug('stopping execution as limit breached.....');
            return null;
        }
         List<Coms_Step_PE__e> orderEvents = new List<Coms_Step_PE__e>();
         List<CSPOFA__Orchestration_Step__c> stepList = new List<CSPOFA__Orchestration_Step__c>();
         
         try {
             stepList = (List<CSPOFA__Orchestration_Step__c>) getStepList(steps);
             //List<Coms_Step_PE__e> orderEvents = new List<Coms_Step_PE__e>();
             
             //TODO
            getRelatedOrderIds(stepList); //this gets the list of orderIds
            //List <csord__service__c> serviceList = (List<csord__service__c>) Coms_PlatformCacheUtil.getAllServicesFromCache(orderIds);
             
             for (CSPOFA__Orchestration_Step__c step : stepList) {
                try {
                    Orchestration_ProcessedRecords processedRecordIds = getProcessedRecords(step);
                    
                    if (processedRecordIds != null) {
                        processedIds.put(step.Id, processedRecordIds);
                    }
                   
                    payloadMap.put('processedIds',processedIds);
                    payloadMap.put('StepId',step.Id);
                    payloadMap.put('orderIds',orderIds);
                    payloadMap.put('Current',step.CSPOFA__Orchestration_Process__r.Order__c);
                    payloadMap.put('ProcessName',step.CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name);
                    str=(String)JSON.serialize(payloadMap); 
                    system.debug('###payload: ' + str);
                    Coms_Step_PE__e orderEvt = new Coms_Step_PE__e(Sequence__c=step.id, payload__c=str, Orchestration_Process_Name__c=step.CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name,Step_Number__c=step.CSPOFA__Step_Order__c);
                    orderEvents.add(orderEvt);
                    if (step.CSPOFA__Orchestration_Process__r.Order__c == null ) {
                        //Updating steps as Error since no proper data linked to step
                        stepResults.put(step.Id, new stepResult('Error: Step do not have an associated order', OrchestratorConstants.OrchestratorStep.Error));
                        //Check the next step
                        continue;
                    }
                    
                    if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        //terminate the loop
                        break;
                    }
                    stepResults.put(step.Id, new stepResult('Waiting: Called Service Publisher', OrchestratorConstants.OrchestratorStep.Waiting));                    
                } catch (Exception ex) {
                    stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
                }
            }
             
            
         } catch (Exception ex) {
            for (CSPOFA__Orchestration_Step__c step : stepList) {
                stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
            }
        }
         
        publishOrderProcessingEvent(orderEvents);
        return processStepResults(stepList, stepResults);
    }
    
    //method override getsteplist
    public override List<sObject> getStepList(List<sObject> steps) {
        Set<String> stepIds = new Set<String>();
        List<CSPOFA__Orchestration_Step__c> stepList = [SELECT ID, Name, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, JSON__c,
                                                        CSPOFA__Message__c, CSPOFA__Orchestration_Process__r.Order__c, 
                                                        CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name, CSPOFA__Step_Order__c
                                                        FROM CSPOFA__Orchestration_Step__c WHERE Id IN :steps];
        
        for (CSPOFA__Orchestration_Step__c step : stepList) {
            if (step.CSPOFA__Orchestration_Process__r.Order__c != null) {
                OrderIds.add(step.CSPOFA__Orchestration_Process__r.Order__c);
                //stepRelationshipMap.put(step.Id, step.CSPOFA__Orchestration_Process__r.Order__c);
            }
            
            if (String.IsNotBlank(step.JSON__c) && step.JSON__c.equals(OrchestratorConstants.SystemConstant.AttachmentMsg)) {
                stepIds.add(step.Id);
            }
        }
        //Check if attachments is required
        if (stepIds.size() > 0) {
            getAttachmentList(stepIds); //Check with Prajakta
        }
        //Returning the step list
        return stepList;
    }
    
    public static void publishOrderProcessingEvent(List<Coms_Step_PE__e> Events){
        // Call method to publish events
        
        System.debug('Events ==> ' + Events );
        
        List<Database.SaveResult> results = EventBus.publish(Events);
        
        for(Database.SaveResult result: results){
            if (result.isSuccess()) {
                System.debug('Successfully published event ==> ' + result );
            } else {
                for(Database.Error err : result.getErrors()) {
                    System.debug('Error returned: ' +
                                 err.getStatusCode() +
                                 ' - ' +
                                 err.getMessage()); 
                }
            }
        }
    }
}