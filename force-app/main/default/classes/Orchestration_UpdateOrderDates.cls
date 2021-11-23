/**================================================================
 * Appirio, Inc
 * Name: Orchestration_UpdateOrderDates
 * Description: Class to update order dates
 * Created Date: May 12, 2020
 * Created By: Gaurang Maheshwari
 ==================================================================
 Change.No.    Developer Name          Date          Story Description
 1.		   Milos Djordjevic     08/06/2021       EDGE-222326 : Modified areLimitsViolated logic check to return SObject instead of NULL
 */

global with sharing class Orchestration_UpdateOrderDates extends Orchestration_AbstractStepHandler {
    //Step --> Processed Ids
    private Map<String, Orchestration_ProcessedRecords> processedIds = new Map<String, Orchestration_ProcessedRecords>();
    //Primary Order --> Child Order
    private Map<Id, List<csord__Order__c>> primaryToChildOrd = new Map<Id, List<csord__Order__c>>();
    //Store multiple records for a step at a place
    private Map<Id, Set<Id>> stepRelationshipMap = new Map<Id, Set<Id>>();
    //Store the Id of the step where limit got hit
    private String pendingStep = '';
    //Store the active step Id
    private String currentStep = '';
    //Keep track of order updation
    private Map<Id, csord__Order__c> updateOrderMap = new Map<Id, csord__Order__c>();

    /**************************************************************
        Name: process
        Parameters: List<SObject> steps
        Return Type: List<SObject>
        Description: Overriding the process method of ExecutionHandler interface
      *******************************************************************/
    public override List<SObject> process(List<SObject> steps) {
		List<SObject> sobjList = new List<SObject>(); // Added as part of EDGE-222326
        if (Orchestration_LimitsUtility.areLimitsViolated()) {
            //Cannot process the records
            return sobjList; // Added as part of EDGE-222326
        }

        //Exception Handling
        try {
            List<CSPOFA__Orchestration_Step__c> stepList = getStepListData(steps);

            for (csord__Order__c ord : [SELECT Id, csord__Start_Date__c, csord__Primary_Order__c FROM csord__Order__c WHERE csord__Primary_Order__c IN :orderIds]) {
                if (Orchestration_LimitsUtility.areLimitsViolated()) {
                    //Collection cannot be created there can process
                    return sobjList; // Added as part of EDGE-222326
                }

                if (ord.csord__Primary_Order__c != null) {
                    if (!primaryToChildOrd.containsKey(ord.csord__Primary_Order__c)) {
                        primaryToChildOrd.put(ord.csord__Primary_Order__c, new List<csord__Order__c>{ ord });
                    } else {
                        primaryToChildOrd.get(ord.csord__Primary_Order__c).add(ord);
                    }
                }
            }

            //Step processing
            for (CSPOFA__Orchestration_Step__c step : stepList) {
                try {
					if (step.CSPOFA__Orchestration_Process__r.Order__c == null ) {
						//Updating steps as Error since no proper data linked to step
						stepResults.put(step.Id, new stepResult('Error: Step do not have an order', OrchestratorConstants.OrchestratorStep.Error));
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

                    if (step.CSPOFA__Orchestration_Process__c != null && step.CSPOFA__Orchestration_Process__r.Order__c != null) {
                        //Bulk Method - return true if limit hits
                        if (updateSubOrderDates(step.CSPOFA__Orchestration_Process__r.Order__r)) {
                            //Capturing the step where limit got
                            pendingStep = step.Id;
                            //Terminate the loop
                            break;
                        }

                        //These will be marked as Complete directly
                        if (!stepRelationshipMap.containsKey(currentStep)) {
                            //Updating steps as complete where no processing required
                            stepResults.put(step.Id, new stepResult('Success: No records required processing under the step', OrchestratorConstants.OrchestratorStep.Complete));
                        }
                    } else {
                        //Updating steps as Error since no proper data linked to step
                        stepResults.put(step.Id, new stepResult('Error: Steps do not have Orders', OrchestratorConstants.OrchestratorStep.Error));
                    }
                } catch (Exception ex) {
                    stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
                }
            }
        } catch (Exception ex) {
            for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) steps) {
                stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
            }
        }

        if (updateOrderMap.size() > 0) {
            //Call update
            updateObjects();
        }

        return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
    }

    private Boolean updateSubOrderDates(csord__Order__c primaryOrder) {
        primaryOrder.csord__Start_Date__c = Date.today();

        //Storing Order records for updation
        if (!hasDMLRowsLimitExceeded()) {
            //Avoid the processed ids for the step

            if (!(processedIds.containsKey(currentStep) && processedIds.get(currentStep).orderIds != null && processedIds.get(currentStep).orderIds.contains(primaryOrder.Id))) {
                updateOrderMap.put(primaryOrder.id, primaryOrder);
                //Maintain the relationship
                if (!stepRelationshipMap.containsKey(currentStep)) {
                    stepRelationshipMap.put(currentStep, new Set<Id>{ primaryOrder.Id });
                } else {
                    stepRelationshipMap.get(currentStep).add(primaryOrder.Id);
                }
            }
        } else {
            //limit got hit
            return true;
        }

        //If child order exists
        if (primaryToChildOrd.containsKey(primaryOrder.Id)) {
            for (csord__Order__c ord : primaryToChildOrd.get(primaryOrder.Id)) {
                if (Orchestration_LimitsUtility.areLimitsViolated()) {
                    //limit got hit
                    return true;
                }

                ord.csord__Start_Date__c = Date.today();
                if (!hasDMLRowsLimitExceeded()) {
                    //Avoid the processed ids for the step
                    if (!(processedIds.containsKey(currentStep) && processedIds.get(currentStep).orderIds != null && processedIds.get(currentStep).orderIds.contains(ord.Id))) {
                        updateOrderMap.put(ord.id, ord);
                        //Maintain the relationship
                        if (!stepRelationshipMap.containsKey(currentStep)) {
                            stepRelationshipMap.put(currentStep, new Set<Id>{ ord.Id });
                        } else {
                            stepRelationshipMap.get(currentStep).add(ord.Id);
                        }
                    }
                } else {
                    //limit got hit
                    return true;
                }
            }
        }
        return false;
    }

    /**
* @author Gaurang Maheshwari
* @date 19/05/2020
* @description for updating the records related to the steps (Step is dependent on multiple records)
step with failed records --> Error AND put the success ids in JSON
step with all passed records -- > Complete
Step with partial records due to limit and all success --> In progress AND put the success ids in JSON
Step with partial records due to limit and failed records --> Error AND put the success ids in JSON
*/
    public override void updateObjects() {
        //Success DML order Ids
        List<Id> orderSuccessIds = new List<Id>();

        //Updating all the order records
        List<Database.SaveResult> updateResult = Database.update(updateOrderMap.values(), false);

        //Storing the order success Ids
        for (Database.SaveResult rslt : updateResult) {
            if (rslt.isSuccess()) {
                orderSuccessIds.add(rslt.getId());
            }
        }

        //Iteration over each step
        for (Id stepId : stepRelationshipMap.keySet()) {
            //Object Type --> Ids
            Orchestration_ProcessedRecords perStepSuccessIds = new Orchestration_ProcessedRecords();
            //Initializing the orderids Set
            perStepSuccessIds.orderIds = new Set<String>();
            Boolean isFailed = false;

            for (Id recId : stepRelationshipMap.get(stepId)) {
                //Only order check
                if (orderSuccessIds.contains(recId)) {
                    perStepSuccessIds.orderIds.add(recId);
                } else {
                    //Failure
                    isFailed = true;
                }
            }

            if (!isFailed && (String.isBlank(pendingStep) || !pendingStep.equals(stepId))) {
                stepResults.put(stepId, new stepResult('Success: Records processed', OrchestratorConstants.OrchestratorStep.Complete));
                //move to next step
                continue;
            }

            //Adding the previous stored ids - error/partial processed case
            if (processedIds.containsKey(stepId) && processedIds.get(stepId).orderIds != null) {
                perStepSuccessIds.orderIds.addAll(processedIds.get(stepId).orderIds);
            }

            if (!isFailed && !String.isBlank(pendingStep) && pendingStep.equals(stepId)) {
                stepResults.put(stepId, new stepResult('Success: Partial records processed', OrchestratorConstants.OrchestratorStep.InProgress, perStepSuccessIds));
            } else {
                stepResults.put(stepId, new stepResult('Error: Unable to process records', OrchestratorConstants.OrchestratorStep.Error, perStepSuccessIds));
            }
        }
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
                cspofa__Orchestration_Process__r.Order__r.csord__Start_Date__c,
                JSON__c
            FROM CSPOFA__Orchestration_Step__c
            WHERE Id IN :steps
        ];

        for (CSPOFA__Orchestration_Step__c step : stepList) {
            //Fetching the order Set
            if (step.CSPOFA__Orchestration_Process__r.Order__c != null) {
                orderIds.add(step.CSPOFA__Orchestration_Process__r.Order__c);
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

    public override boolean hasDMLRowsLimitExceeded() {
        if (updateOrderMap.size() + Limits.getDMLRows() < Integer.valueOf(Governor_Limits__c.getInstance().DML_Rows_limit__c)) {
            return false;
        }
        //Limit Hit
        return true;
    }
}