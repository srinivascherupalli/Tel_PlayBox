/**================================================================
* Name: Orchestration_GenerateTransientDataV1
* Description: This Updates all the Orders with isTransientComplete__c = true and adds attachment to the Order
==================================================================*/
global with sharing class Orchestration_GenerateTransientDataV1 extends Orchestration_AbstractStepHandler {
    
    
    private Map<Id, Orchestration_ProcessedRecords> processedIds = new Map<Id, Orchestration_ProcessedRecords>();
    
    Map<String,Object>payloadMap = new Map<String,Object>();
    String str='';
    List<Coms_Step_PE__e> orderEvents = new List<Coms_Step_PE__e>();
    
    
    //Map<Id, String> serviceScenerioTypeMap = new Map<Id, String>();
    //Map<Id, String> serviceOfferMap = new Map<Id, String>();
    
    public override List<SObject> process(List<SObject> steps) {
        List<SObject> sobjList = new List<SObject>(); // Added as part of EDGE-222326
        if (Orchestration_LimitsUtility.areLimitsViolated()) {
            //Cannot process the records
            return sobjList; // Added as part of EDGE-222326
        }
        
        try {
            List<CSPOFA__Orchestration_Step__c> stepList = getStepList(steps);
            getRelatedOrderIds(stepList);
            
            //Set<Id> baseOrderSet = new Set<Id>();
           // Set<Id> inflightOrderSet = new Set<Id>();
            
            for (CSPOFA__Orchestration_Step__c step : stepList) {
				
				Map<Id,boolean>inflightFlagMap = new Map<Id,boolean>();
				
                try {
                    if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        //terminate the loop
                        break;
                    }
                    
                    if (step.CSPOFA__Orchestration_Process__r.Order__c == null ) {
                        //Updating steps as Error since no proper data linked to step
                        stepResults.put(step.Id, new stepResult('Error: Step do not have an associated order', OrchestratorConstants.OrchestratorStep.Error));
                        //Check the next step
                        continue;
                    }
                    if (step.CSPOFA__Orchestration_Process__r.Order__r.isTransientComplete__c) {
                        stepResults.put(step.Id, new StepResult('Success: Transient Already Completed', OrchestratorConstants.OrchestratorStep.Complete));
                        
                        continue;
                    }
                    
                    Orchestration_ProcessedRecords processedRecordIds = getProcessedRecords(step);
                    
                    /*if (processedRecordIds != null) {
                        processedIds.put(step.Id, processedRecordIds);
                    }*/
                    
                    
                    
                    if(step.CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name =='Inflight Orchestration Process') 
                    {
                       // inflightOrderSet.add(step.CSPOFA__Orchestration_Process__r.Order__c); 
                        inflightFlagMap.put(step.CSPOFA__Orchestration_Process__r.Order__c,true);					   
                    }
                    else if(step.CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name =='Order Fulfilment Process_New')
                    {
                       // baseOrderSet.add(step.CSPOFA__Orchestration_Process__r.Order__c);
                        inflightFlagMap.put(step.CSPOFA__Orchestration_Process__r.Order__c,false);					   

					}
                    
                    
                    //payloadMap.put('OrderIds',orderIds);
                    payloadMap.put('StepId',step.Id);
                    payloadMap.put('OrderId',step.CSPOFA__Orchestration_Process__r.order__c);
                   // payloadMap.put('ProcessName',step.CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name);
                    payloadMap.put('processedRecordIds',processedRecordIds);
                    payloadMap.put('inflightFlagMap',inflightFlagMap);
                    
                    str=(String)JSON.serialize(payloadMap);
                    Coms_Step_PE__e ordEvt = new Coms_Step_PE__e(Sequence__c=String.valueOf(Orchestration_PlatformCacheUtility.seq), payload__c=str, Orchestration_Process_Name__c=step.CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name,Step_Number__c=step.CSPOFA__Step_Order__c);
                    orderEvents.add(ordEvt);
                    
                    
                    stepResults.put(step.Id, new stepResult('Waiting: Called Service Publisher', OrchestratorConstants.OrchestratorStep.Waiting));                    
                } catch (Exception ex) { stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
                }
                
                Orchestration_PlatformCacheUtility.seq++;
            }
            
        } catch (Exception ex) {for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) steps) {
                stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error));
            }
        }
        
        publishOrderProcessingEvent(orderEvents);
        return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
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
            CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name,//EDGE-170463 added
            CSPOFA__Orchestration_Process__r.cspofa__account__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c,
            CSPOFA__Orchestration_Process__r.Order__c,
            CSPOFA__Orchestration_Process__r.Order__r.isTransientComplete__c,
            CSPOFA__Orchestration_Process__r.Order__r.scenario_type__c   ,
            CSPOFA__Step_Order__c
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