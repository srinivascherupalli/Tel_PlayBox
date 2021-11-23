/**================================================================
* Name: Orchestration_EvaluateOrderStatus_V2
* Description: Class to update Status of Orders and triggerBill_RTB__c field of Subscription
* Created Date: 
* Created By: 
==================================================================*/
global class Orchestration_EvaluateOrderStatus_V2 extends Orchestration_AbstractStepHandler {
    //Collection for the calculations
    @TestVisible private Map<Id, Integer> orderSubscriptionCntMap = new Map<Id, Integer>();
    @TestVisible private Map<Id, Integer> cancellationInProgressMap = new Map<Id, Integer>();
    @TestVisible private Map<Id, Integer> failedMap = new Map<Id, Integer>();
    @TestVisible private Map<Id, Integer> activeMap = new Map<Id, Integer>();
    @TestVisible private Map<Id, Integer> paidOutMap = new Map<Id, Integer>();  //EDGE-163712
    @TestVisible private Map<Id, Integer> inActiveMap = new Map<Id, Integer>();
    @TestVisible private Map<Id, Integer> closedMap = new Map<Id, Integer>();  //EDGE-177027    
    @TestVisible private Map<Id, Integer> cancelledMap = new Map<Id, Integer>();
    @TestVisible private Map<Id, Integer> billingCompleteMap = new Map<Id, Integer>();
    @TestVisible private Map<Id, Integer> suspendedMap = new Map<Id, Integer>();
    //Store active Solution component subscription
    //Step --> Processed Ids
    private Map<String, Orchestration_ProcessedRecords> processedIds = new Map<String, Orchestration_ProcessedRecords>();
    //Solution Subscription --> Child Subscription
   
    //Solution Association related to the step
    //Store multiple records for a step at a place
    private Map<Id, Set<Id>> stepRelationshipMap = new Map<Id, Set<Id>>();
    //Store the Id of the step where limit got hit
    private String pendingStep = '';
    //Store the active step Id
    private String currentStep = '';
    //Keep track of order updation
    private Map<Id, csord__Order__c> updateOrderMap = new Map<Id, csord__Order__c>();
    //Keep track of subscription updation
    private Map<Id, csord__Subscription__c> updateSubsMap = new Map<Id, csord__Subscription__c>();
    private String payloadStr='';
    Integer seq=0;
    Map<String,Object>payloadMap = new Map<String,Object>();
    List<Coms_Subscription_PE__e> subscriptionEvts = new List<Coms_Subscription_PE__e>();
    
    /**************************************************************
Name: process
Parameters: List<SObject> steps
Return Type: List<SObject>
Description: Overriding the process method of ExecutionHandler interface
*******************************************************************/
    public override List<SObject> process(List<SObject> steps) {
        List<SObject> sobjList=new List<SObject>(); // Added as part of EDGE-222326
        if (Orchestration_LimitsUtility.areLimitsViolated()) {
            //Cannot process the records
            //return null; // Commented as part of EDGE-222326
            return sobjList; // Added as part of EDGE-222326
        }
        //Exception Handling
        try {
            List<CSPOFA__Orchestration_Step__c> stepList = getStepListData(steps);
            //Aggregate query for order status calculation
         //   runAggregateProgram();
            //Step processing
            for (CSPOFA__Orchestration_Step__c step : stepList) {
                try {
                    if (step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c == null) {
                        //Updating steps as Error since no proper data linked to step
                        stepResults.put(step.Id, new stepResult('Error: Step is not related to a subscription', OrchestratorConstants.OrchestratorStep.Error));
                        //Check the next step
                        continue;
                    }
                    //Limit check
                    if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        //terminate the loop
                        break;
                    }
                    //Setting the current variable
                    currentStep = step.Id;
                    //Only order will be present in Json
                    Orchestration_ProcessedRecords processedRecordIds = getProcessedRecords(step);                    
                    if (processedRecordIds != null) {
                        processedIds.put(step.Id, processedRecordIds);
                    }
                    payloadMap.put('SubscriptionIds',subscriptionIds);
                    payloadMap.put('orderIds',orderIds);
                    payloadMap.put('StepId',step.Id);
                    payloadMap.put('Current',step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);
                    payloadMap.put('ProcessName',step.CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name);
                    payloadMap.put('ProcessedIds',processedIds);
                    payloadStr=(String)JSON.serialize(payloadMap);
                   // Coms_Subscription_PE__e subsEvt = new Coms_Subscription_PE__e(Sequence__c=step.id, payload__c=str, Orchestration_Process_Name__c=step.CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name,Step_Number__c=step.CSPOFA__Step_Order__c);
                    Coms_Subscription_PE__e subsEvt = new Coms_Subscription_PE__e(Sequence__c=String.valueOf(Orchestration_PlatformCacheUtility.seq), payload__c=payloadStr, Orchestration_Process_Name__c=step.CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name,Step_Number__c=step.CSPOFA__Step_Order__c);
                    subscriptionEvts.add(subsEvt);
                  
                    //These will be marked as Complete directly
                    if ((pendingStep == '' || pendingStep != step.Id) && !stepRelationshipMap.containsKey(currentStep)) {
                        //Updating steps as complete where no processing required
                        stepResults.put(step.Id, new stepResult('Success: No records required processing under the step', OrchestratorConstants.OrchestratorStep.Complete));
                    }
                    Orchestration_PlatformCacheUtility.seq++;
                   // seq++;
                    stepResults.put(step.Id, new stepResult('Waiting: Called Service Publisher', OrchestratorConstants.OrchestratorStep.Waiting));                    
                } catch (Exception ex) { stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error));
                }
            }
        } catch (Exception ex) {
            for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) steps) { stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error));
            }
        }
        
       // system.debug('StepResults### '+stepResults);
        publishSubsProcessingEvent(subscriptionEvts);
        return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
    }
      
    
    
    private List<CSPOFA__Orchestration_Step__c> getStepListData(List<sObject> steps) {
        Set<String> stepIds = new Set<String>();
        
        //Fetching more fields from the query
        List<CSPOFA__Orchestration_Step__c> stepList = [
            SELECT
            Id,
            CSPOFA__Orchestration_Process__c,
            CSPOFA__Status__c,
            CSPOFA__Completed_Date__c,
            CSPOFA__Message__c,
            cspofa__Orchestration_Process__r.csordtelcoa__Subscription__c,
            cspofa__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c,
            cspofa__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__r.name,
            cspofa__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Product_Configuration__c,
            cspofa__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Replacement_Subscription__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Product_Configuration__r.ConfigurationType1__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__status__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__r.csord__Status2__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__r.csord__Status2__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__r.csord__End_Date__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__r.csord__End_Date__c,
            JSON__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.triggerBill_RTB__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.cssdm__solution_association__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.changeType__c,
            CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name,
            CSPOFA__Step_Order__c
            FROM CSPOFA__Orchestration_Step__c
            WHERE Id IN :steps
        ];//EDGE-180743 added change type in query
        
        for (CSPOFA__Orchestration_Step__c step : stepList) {
            
            //Get orders related to the subscriptions
            if (step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c != null) {
                orderIds.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c);
            } else if (step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__c != null) {
                orderIds.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__c);
            }
            
            if (String.IsNotBlank(step.JSON__c) && step.JSON__c.equals(OrchestratorConstants.SystemConstant.AttachmentMsg)) {
                stepIds.add(step.Id);
            }
        }
        
        //Check if attachments is required
        if (stepIds.size() > 0) {
            getAttachmentList(stepIds);
        }
        
        //Returning the step list
        return stepList;
    }
    public static void publishSubsProcessingEvent(List<Coms_Subscription_PE__e> Events){
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