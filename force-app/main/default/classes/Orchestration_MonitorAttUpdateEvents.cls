/**================================================================
 * Name: Orchestration_MonitorAttUpdateEvents
 * Description: Pseudo monitor step to monitor completion of associate dplatform event transaction from the observe class
 * Created Date: Oct 4, 2021
 * Created By: Ashish Agarwal
 ==================================================================*/

global with sharing class Orchestration_MonitorAttUpdateEvents extends Orchestration_AbstractStepHandler {
    private Map<Id, Id> stepRelationship = new Map<Id, Id>();
    private String FailedEventTransactionStatus = 'Error';
    private String InCompleteEventTransactionStatus = 'Started';
    public override List<SObject> process(List<SObject> steps) {
        if (Orchestration_LimitsUtility.areLimitsViolated()) {
            system.debug('stopping execution as limit breached.....');
            return null;
        }
        List<CSPOFA__Orchestration_Step__c> stepList = new List<CSPOFA__Orchestration_Step__c>();
        try {
            stepList = (List<CSPOFA__Orchestration_Step__c>) getStepList(steps);
            getRelatedOrderIds(stepList);
            Map<Id, Map<String,Integer>> orderToEventStatusCount = new Map<Id, Map<String,Integer>>();

            /*Aggregaete query to fetch all associated platform event transactions */
            for(AggregateResult platformEventTransactionAggr :[
                SELECT Field_19__c order, COUNT(Id) transactionCount, Field_3__c status
                FROM Orchestration_Technical__c
                WHERE Field_19__c IN :orderIds AND Field_3__c != null AND Field_14__c = 'PreREQ'
                GROUP BY Field_19__c, Field_3__c]){
                    String tempStatus = (String) platformEventTransactionAggr.get('status');
                    Id tempOrderId = (Id) platformEventTransactionAggr.get('order'); 
                    Integer tempTransactionCount = (Integer) platformEventTransactionAggr.get('transactionCount');
                    
                    Map<String,Integer> tempMap = new Map<String,Integer>();

                    if (!orderToEventStatusCount.containsKey(tempOrderId)) {
                        tempMap.put(tempStatus, tempTransactionCount);
                    } else {
                        tempMap = orderToEventStatusCount.get(tempOrderId);
                        tempMap.put(tempStatus, tempTransactionCount);
                    }
                    orderToEventStatusCount.put(tempOrderId, tempMap);
                    

            }

            for (CSPOFA__Orchestration_Step__c step : stepList) {
                try {
                    
                    if (step.CSPOFA__Orchestration_Process__r.Order__c == null ) {
                        //Updating steps as Error since no proper data linked to step
                        stepResults.put(step.Id, new stepResult('Error: Step do not have an associated Order', OrchestratorConstants.OrchestratorStep.Error));
                        //Check the next step
                        continue;
                    }
                    
                    if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        //terminate the loop
                        break;
                    }

                    Map<String,Integer> tempMap = new Map<String,Integer>();
                    Id tempOrderId = step.CSPOFA__Orchestration_Process__r.Order__c;

                    // keep step status to In progress if all associated transactions are not completed
                    // update step status to Error if atleast one associated transactions failed IE atleast one entry for failed status exists in the map
                    // else complete the step and move ahead
                    if (orderToEventStatusCount != null && !orderToEventStatusCount.isEmpty() && orderToEventStatusCount.containsKey(tempOrderId)) {
                        tempMap = orderToEventStatusCount.get(tempOrderId);
                        Set<String> statusList= new Set<String>();
                        statusList = tempMap.keyset();
                        if(statusList.contains(FailedEventTransactionStatus)){
                            stepResults.put(step.Id, new stepResult('Error: Atleast one attachment update event failed', OrchestratorConstants.OrchestratorStep.Error));
                        }else if(statusList.contains(InCompleteEventTransactionStatus)){
                            stepResults.put(step.Id, new stepResult('Attachment Update Events still processing', OrchestratorConstants.OrchestratorStep.InProgress));
                        }else {
                            stepResults.put(step.Id, new stepResult('Success: All attachment update events completed', OrchestratorConstants.OrchestratorStep.Complete));
                        }

                    }else{
                        stepResults.put(step.Id, new stepResult('Success: No platform events to monitor for this order', OrchestratorConstants.OrchestratorStep.Complete));
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
        return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
    }
    //override getStepList to fetch necessry field from steps
    public override List<sObject> getStepList(List<sObject> steps) {
        List<CSPOFA__Orchestration_Step__c> stepList = [
            SELECT ID, CSPOFA__Orchestration_Process__r.Order__c
            FROM CSPOFA__Orchestration_Step__c
            WHERE Id IN :steps
        ];

        return stepList;
    }
}