/**================================================================
 * Appirio, Inc
 * Name: Orchestration_SendManageOrder
 * Description: Class to send Manage order payload to AMDOCS when order orchestration process started
 * Created Date: May 13, 2020
 * Created By: Gaurang Maheshwari
===============================================================================================================================
1.   Pawan            08-Sep-2021        DIGI-18183: Added new parameter in payload : Fulfilment Order Version
===============================================================================================================================
*/

global with sharing class Orchestration_SendManageOrder extends Orchestration_AbstractStepHandler {
    //Store the response for creating the application logs for High Volume
    List<Orchestration_CallOutResponse> respWrapper = new List<Orchestration_CallOutResponse>();
    /**************************************************************
        Name: process
        Parameters: List<SObject> steps
        Return Type: List<SObject>
        Description: Overriding the process method of ExecutionHandler interface
      *******************************************************************/
    public override List<SObject> process(List<SObject> steps) {
        //Limit check
        if (Orchestration_LimitsUtility.areLimitsViolated()) {
            //Cannot process the records
            return null;
        }

        //Exception Handling
        try {
            //Type casting of steps
            List<CSPOFA__Orchestration_Step__c> stepList = (List<CSPOFA__Orchestration_Step__c>) getStepList(steps);
            system.debug('---??????');
            //Processing the steps
            if (!Orchestration_Utility.HighVolumeOrderCheck()) {
                //nothing to publish, custom setting is off
                return populateStepResults('High Volume custom setting off therefore no processing required', OrchestratorConstants.OrchestratorStep.Complete, (List<CSPOFA__Orchestration_Step__c>) steps);
            }

            for (CSPOFA__Orchestration_Step__c step : stepList) {
                try {
                    if (step.CSPOFA__Orchestration_Process__r.Order__c == null ) {
                            //Updating steps as Error since no proper data linked to step
                        stepResults.put(step.Id, new stepResult('Error: Step do not have an order', OrchestratorConstants.OrchestratorStep.Error));
                            //Check the next step
                        continue;
                    }
                    if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        //Terminate the loop
                        break;
                    }

                    //Method returns false if limit got hit
                    if (!sendManageOrder(step.CSPOFA__Orchestration_Process__r.Order__r)) {
                        //Terminate the Loop
                        break;
                    }

                    //Setting the results when limit is not hit to avoid another iteration
                    stepResults.put(step.Id, new stepResult('Success: Events are enqueued', OrchestratorConstants.OrchestratorStep.Complete));
                } catch (Exception ex) {
                    stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error));
                }
            }
        } catch (Exception ex) {
            for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) steps) {
                stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error));
            }
        }

        if (eventsToPublish.size() > 0) {

            publishObject(respWrapper);
        }

        return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
    }

    private Boolean sendManageOrder(csord__Order__c ord) {
        HighVolumeReadyToSubmitOrder__e highVolEvent = new HighVolumeReadyToSubmitOrder__e();
        highVolEvent.OrderID__c = ord.Id;
        highVolEvent.Order_Number__c = ord.csord__Order_Number__c;        
        highVolEvent.CorrelationID__c = Orchestration_Utility.getUID();
        highVolEvent.Fulfilment_Order_Version__c= ord.Fulfilment_Order_Version__c; // DIGI-18183

        String StatusCode = '200';
        Orchestration_CallOutResponse res = new Orchestration_CallOutResponse(null, JSON.serialize(highVolEvent, true), null, statusCode, 'HighVolumeEvent', 'Integration', null, null, statusCode, null, null);
        respWrapper.add(res);

        //Limit check
        if (hasDMLRowsLimitExceeded()) {
            return false;
        }

        //Putting the event in the list
        eventsToPublish.add(highVolEvent);
        return true;
    }

    public override List<sObject> getStepList(List<sObject> steps) {
        //Fetching more fields from the query
        List<sObject> stepList = [SELECT Id, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c, CSPOFA__Orchestration_Process__r.Order__c, CSPOFA__Orchestration_Process__r.Order__r.csord__Order_Number__c, CSPOFA__Orchestration_Process__r.Order__r.Fulfilment_Order_Version__c FROM CSPOFA__Orchestration_Step__c WHERE Id IN :steps];

        return stepList;
    }

    public override boolean hasDMLRowsLimitExceeded() {
        if (eventsToPublish.size() + Limits.getDMLRows() < Integer.valueOf(Governor_Limits__c.getInstance().DML_Rows_limit__c)) {
            return false;
        }
        //Limit Hit
        return true;
    }
}