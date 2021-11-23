/**================================================================
 * Appirio, Inc
 * Name: Orchestration_CallMSISDNFromAppointment
 * Description: Class to update create orchestration process for MSISDN Reservation->Order
 * Created Date: June 12, 2020
 * Created By: Gaurang Maheshwari
 ==================================================================*/
global with sharing class Orchestration_CallMSISDNFromAppointment extends Orchestration_AbstractStepHandler {
    //Store Order --> Step since only one record will be present per step
    private Map<Id, Id> stepRelationshipMap = new Map<Id, Id>();
    //Store the active step Id
    private String currentStep = '';
    //Store the count of orchestration process that can be created in the transaction
    Integer orchProcessCnt = 0;
    //Keep track of order updation
    private List<CSPOFA__Orchestration_Process__c> insertOrchProcessList = new List<CSPOFA__Orchestration_Process__c>();
    //Store the template
    List<CSPOFA__Orchestration_Process_Template__c> orchesTemplates = new List<CSPOFA__Orchestration_Process_Template__c>();

    /**************************************************************
        Name: process
        Parameters: List<SObject> steps
        Return Type: List<SObject>
        Description: Overriding the process method of ExecutionHandler interface
      *******************************************************************/
    public override List<SObject> process(List<SObject> steps) {
        if (Orchestration_LimitsUtility.areLimitsViolated()) {
            //Cannot process the records
            return null;
        }

        //Exception Handling
        try {
            orchesTemplates = [SELECT Id, Name FROM CSPOFA__Orchestration_Process_Template__c WHERE Name = :OrchestratorConstants.OrchesTemplateName.msisdnReserveTemplate];
            //Terminate the processing since the template is missing
            if (orchesTemplates.IsEmpty()) {
                return populateStepResults('MSISDN Template is missing in the org', OrchestratorConstants.OrchestratorStep.Error, (List<CSPOFA__Orchestration_Step__c>) steps);
            }

            List<CSPOFA__Orchestration_Step__c> stepList = getStepList(steps);

            //Fetch the orchestration process creation Limit
            orchProcessCnt = Orchestration_LimitsUtility.getOrchestrationProcessLimit();
			//Step processing
            for (CSPOFA__Orchestration_Step__c step : stepList) {
                try {
                    //Limit check
                    if (Orchestration_LimitsUtility.areLimitsViolated() || orchProcessCnt == 0) {
                        //terminate the loop, no processing is required
                        break;
                    }

                    //Setting the current variable
                    currentStep = step.Id;

                    if (step.CSPOFA__Orchestration_Process__c != null && step.CSPOFA__Orchestration_Process__r.Order__c != null) {
                        //process creation method called
                        createMSISDNOchestrationProcess(step.CSPOFA__Orchestration_Process__r.Order__c);

                        //decreasing the count by 1
                        orchProcessCnt--;
                    } else {
                        //Updating steps as Error since no proper data linked to step
                        stepResults.put(step.Id, new stepResult('Error: Steps do not have Orders', OrchestratorConstants.OrchestratorStep.Error));
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

        if (insertOrchProcessList.size() > 0) {
            //Call update
            insertObjects();
        }

        return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
    }

    private void createMSISDNOchestrationProcess(Id orderId) {
        CSPOFA__Orchestration_Process__c orches = new CSPOFA__Orchestration_Process__c();
        orches.CSPOFA__State__c = 'Active';
        orches.Order__c = orderId;
        orches.CSPOFA__Orchestration_Process_Template__c = orchesTemplates.get(0).Id;

        //Avoid the processed ids for the step
        insertOrchProcessList.add(orches);
        //Maintain the relationship
        stepRelationshipMap.put(orderId, currentStep);
    }

    public override void insertObjects() {
        //Updating all the order records
        Database.insert(insertOrchProcessList, false);

        //Iterate over the insertion to check if the record inserted
        for (CSPOFA__Orchestration_Process__c orches : insertOrchProcessList) {
            if (orches.Id == null) {
                stepResults.put(stepRelationshipMap.get(orches.Order__c), new stepResult('Error: Orchestration process cannot be created', OrchestratorConstants.OrchestratorStep.Error));
            } else {
                stepResults.put(stepRelationshipMap.get(orches.Order__c), new stepResult('Success: Orchestration process is created', OrchestratorConstants.OrchestratorStep.Complete));
            }
        }
    }

    public override List<sObject> getStepList(List<sObject> steps) {
        //Fetching more fields from the query
        List<CSPOFA__Orchestration_Step__c> stepList = [
            SELECT Id, Name, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c, CSPOFA__Orchestration_Process__r.Order__c, JSON__c
            FROM CSPOFA__Orchestration_Step__c
            WHERE Id IN :steps
        ];

        //Returning the step list
        return stepList;
    }
}