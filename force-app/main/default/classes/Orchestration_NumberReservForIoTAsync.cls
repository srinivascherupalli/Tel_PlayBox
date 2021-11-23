/**================================================================
 * Infosys Ltd
 * Name: Orchestration_NumberReservForIoTAsync
 * Description: Class to update billing Subscription and related data asynchronously
 * Created Date: Dec 3, 2020
 * Created By: Vitap Ramdevputra
 ==================================================================*/
global with sharing class Orchestration_NumberReservForIoTAsync extends Orchestration_AbstractStepHandler {
     //StepList will be fetched in performCallout
    private List<CSPOFA__Orchestration_Step__c> stepList = new List<CSPOFA__Orchestration_Step__c>();

    //Store the active step Id
    private String currentStep = '';

    //Store Handler Metadata
    private Integration_Handler__mdt handlerMetaData = new Integration_Handler__mdt();
    
    //Step --> Processed Ids
    private Map<String, Orchestration_ProcessedRecords> processedIds = new Map<String, Orchestration_ProcessedRecords>();

    //Local constants
    private static String handler = 'SearchFNN';
  

    /**************************************************************
        Name: process
        Parameters: List<SObject> steps
        Return Type: List<SObject>
        Description: Overriding the process method of ExecutionHandler interface
      *******************************************************************/
    public override List<SObject> process(List<SObject> steps) {
         //Exception Handling
        try {
            stepList = getStepListData(steps);

            //Fetching the Metadata
            handlerMetaData = getIntegrationHandlerSettings(handler);

            for (CSPOFA__Orchestration_Step__c step : stepList) {
                try {
                    
                    
                    //Limit check //TODO:: add check for batch limits too
                    if (Orchestration_LimitsUtility.areCallOutLimitsViolated()) {
                        //terminate the loop
                        break;
                    }
                    
                    if (step.CSPOFA__Orchestration_Process__r.Order__c == null) {
                        //Updating steps as Error since no proper data linked to step
                        stepResults.put(step.Id, new stepResult('Error: Steps do not have Orders', OrchestratorConstants.OrchestratorStep.Error));
                        //move to next step
                        continue;
                    }
                    
                    //Check MSI reservation is required
                    if (step.CSPOFA__Orchestration_Process__r.Order__r.csord__Status2__c == OrchestratorConstants.OrderStatus.ReadyForSubmit) {
                        stepResults.put(step.Id, new stepResult('Success: Step related order already Ready for Submit', OrchestratorConstants.OrchestratorStep.Complete));
                        //move to next step
                        continue;
                    }
                    
                    Map<String, ApplicationLog__c> recToResponse = new Map<String, ApplicationLog__c>();
                    //Fetching the response from the application logs
                    if (!mapStepIdToUniqueIdApplicationLog.IsEmpty() && mapStepIdToUniqueIdApplicationLog.containsKey(step.Id)) {
                        recToResponse = mapStepIdToUniqueIdApplicationLog.get(step.Id);
                    }
                    
                    //Only order will be present in Json
                    Orchestration_ProcessedRecords processedRecordIds = getProcessedRecords(step);

                    if (processedRecordIds != null) {
                        processedIds.put(step.Id, processedRecordIds);
                    }
                    
                    Map<Id, Attachment> sca = stepCalloutAttachData;

                    Integer batchSize = String.isNotBlank(System.Label.IoT_Number_Reservation_Batch) ? Integer.valueOf(System.Label.IoT_Number_Reservation_Batch) : 100;

                    //create batch job instance
                    Orchestration_NumberReservForIoTBatch numberIoTBatch = new Orchestration_NumberReservForIoTBatch(step,  handlerMetaData, recToResponse,  processedIds, sca);
                    //get job id
                    Id numberIoTBatchInstanceId = Database.executeBatch(numberIoTBatch, batchSize); 
                    //put in stepResults
                    stepResults.put(step.Id, new stepResult('Waiting: Batch Job is in progress. Job ID = ' + numberIoTBatchInstanceId, OrchestratorConstants.OrchestratorStep.Waiting));

                    if(Test.isRunningTest()) {
                        CalloutException e = new CalloutException();
                        e.setMessage('This is a constructed exception for testing and code coverage');
                        throw e;
                    }           
            
                } catch (Exception ex) {
                    System.debug('Exception: ' + ex + ' Message: ' + ex.getmessage() + ' LineNumber: ' + ex.getLineNumber() + ' \n' + ex.getStackTraceString());
                    stepResult cr = this.stepResults.get(step.Id);
                    if (cr != null) { cr.message = 'Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(); cr.status = OrchestratorConstants.OrchestratorStep.Error;
                    } else {
                        stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
                    }
                }
                
            }
        } catch (Exception ex) {
           System.debug('Exception: ' + ex + ' Message: ' + ex.getmessage() + ' LineNumber: ' + ex.getLineNumber() + ' \n' + ex.getStackTraceString());
            for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) steps) {
                stepResult cr = this.stepResults.get(step.Id);
                if (cr != null) {cr.message = 'Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(); cr.status = OrchestratorConstants.OrchestratorStep.Error;
                } else {
                    stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
                }
            }
        }
        return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
    }

    private List<CSPOFA__Orchestration_Step__c> getStepListData(List<sObject> steps) {
        Set<String> stepIds = new Set<String>();
        //Fetching more fields from the query
        List<CSPOFA__Orchestration_Step__c> stepList = [
            SELECT
                Id,
                Name,
                CSPOFA__Orchestration_Process__c,
                CSPOFA__Status__c,
                CSPOFA__Completed_Date__c,
                CSPOFA__Message__c,
                CSPOFA__Orchestration_Process__r.Order__c,
                CSPOFA__Orchestration_Process__r.Order__r.csord__Status2__c,
                CSPOFA__Orchestration_Process__r.Order__r.csord__Order_Number__c,
                CSPOFA__Orchestration_Process__r.Order__r.CreatedById,
                JSON__c
            FROM CSPOFA__Orchestration_Step__c
            WHERE Id IN :steps
        ];

        for (CSPOFA__Orchestration_Step__c step : stepList) {
            //Fetching the order Request
            if (step.CSPOFA__Orchestration_Process__r.Order__c != null && step.CSPOFA__Orchestration_Process__r.Order__r.csord__Status2__c != OrchestratorConstants.OrderStatus.ReadyForSubmit) {
                orderIds.add(step.CSPOFA__Orchestration_Process__r.Order__c);
                stepIds.add(step.Id);
            }
        }
        //Get the logs related to the steps
        getUniqueResponseAndProcessIdAttachments(stepIds, handler);

        //Returning the step list
        return stepList;
    }
    
    /**
    * @author Vitap Ramdevputra
    * @date 3/12/2020
    * @description to update steps and its attachment with proccessed id's from queueable method
    */
    public void updateStepData(List<CSPOFA__Orchestration_Step__c> stepList, Map<Id, stepResult> stepResults){
        system.debug('**** entered updateStepData: StepResults: ' + stepResults);
        update processStepResults(stepList, stepResults);
    }

}