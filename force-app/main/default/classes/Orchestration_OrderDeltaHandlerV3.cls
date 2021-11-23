/**================================================================ 

* Name: Orchestration_OrderDeltaHandlerV3
* Description: Class to update Delta changes

===============================================================================================================================
*/

global with sharing class Orchestration_OrderDeltaHandlerV3 extends Orchestration_AbstractStepHandler {
  
   // private Map<Id, Orchestration_ProcessedRecords> processedIds = new Map<Id, Orchestration_ProcessedRecords>();

    Map<String,Object>payloadMap = new Map<String,Object>();
    List<Coms_Step_PE__e> orderEvents = new List<Coms_Step_PE__e>();
    String str='';
    public override List<SObject> process(List<SObject> steps) {
        List<SObject> sobjList = new List<SObject>(); // Added as part of EDGE-222326
        if (Orchestration_LimitsUtility.areLimitsViolated()) {
            //Cannot process the records
            return sobjList; // Added as part of EDGE-222326
        }
        
        try {
            List<CSPOFA__Orchestration_Step__c> stepList = getStepListData(steps);
            
           for (CSPOFA__Orchestration_Step__c step : stepList) {
                
                    if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        //terminate the loop
                        break;
                    }
                   Orchestration_ProcessedRecords processedRecordIds = getProcessedRecords(step);
                    
                   /* if (processedRecordIds != null) {
                        processedIds.put(step.Id, processedRecordIds);
                    }*/
                    
					 //Check for data issue - order should be present
					 if (step.CSPOFA__Orchestration_Process__r.Order__c == null) {
                        //Updating steps as Error since no proper data linked to step
                        stepResults.put(step.Id, new stepResult('Error: Step do not have an order or subscriptions', OrchestratorConstants.OrchestratorStep.Error));
                        //Check the next step
                        continue;
                    }
					
                   // payloadMap.put('OrderIds',orderIds);
                    payloadMap.put('StepId',step.Id);
                    payloadMap.put('OrderId',step.CSPOFA__Orchestration_Process__r.order__c);
                    //payloadMap.put('ProcessName',step.CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name);
                    payloadMap.put('processedRecordIds',processedRecordIds);
                    str=(String)JSON.serialize(payloadMap);
                    Coms_Step_PE__e ordEvt = new Coms_Step_PE__e(Sequence__c=String.valueOf(Orchestration_PlatformCacheUtility.seq), payload__c=str, Orchestration_Process_Name__c=step.CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name,Step_Number__c=step.CSPOFA__Step_Order__c);
                    orderEvents.add(ordEvt);
                    stepResults.put(step.Id, new stepResult('Waiting: Called Order Publisher', OrchestratorConstants.OrchestratorStep.Waiting)); //Check with Prajakta
                Orchestration_PlatformCacheUtility.seq++;
            }
        } catch (Exception ex) {
            for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) steps) {
                stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
            }
        }
        publishOrderProcessingEvent(orderEvents);
        return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
    }
    
    private List<CSPOFA__Orchestration_Step__c> getStepListData(List<sObject> steps) {
        //Fetching more fields from the query
        List<CSPOFA__Orchestration_Step__c> stepList = [
            SELECT ID, Name, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, JSON__c, CSPOFA__Message__c, CSPOFA__Orchestration_Process__r.Order__c, CSPOFA__Orchestration_Process__r.Order__r.skipFulfillment__c,CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name,CSPOFA__Step_Order__c
            FROM CSPOFA__Orchestration_Step__c
            WHERE Id IN :steps
        ];
        Set<String> stepIds = new Set<String>();
        for (CSPOFA__Orchestration_Step__c step : stepList) {
            //Get orders related to the steps
            if (step.CSPOFA__Orchestration_Process__r.Order__c != null) {
                orderIds.add(step.CSPOFA__Orchestration_Process__r.Order__c);
            }
            if (String.IsNotBlank(step.JSON__c) && step.JSON__c.equals(OrchestratorConstants.SystemConstant.AttachmentMsg)) { stepIds.add(step.Id);}
                  
        }
        //Check if attachments is required
       // if (stepIds.size() > 0) {getAttachmentList(stepIds); }    
        
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