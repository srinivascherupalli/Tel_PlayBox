/**================================================================
 * Appirio, Inc
 * Name: Orchestration_UpdateMSISDN
 * Description: Class to check MSISDN Service on Order
 * Created Date: Aug 21, 2020
 * Created By: Gaurang Maheshwari
 * 1. Gnana    16/09/2020    EDGE-173277 - Added new scenarioTypeSet "Transition with Inactive Sim"
 * 2. Laxmi 	30/11/2020	 EDGE-186610 - Additonal value in  scenarioTypeSet -  "Reactiavte"
 ==================================================================*/

global with sharing class Orchestration_UpdateMSISDN extends Orchestration_AbstractStepHandler {
    //Order --> Service
    private Map<Id, List<csord__Service__c>> ordToServiceMap = new Map<Id, List<csord__Service__c>>();
    //Store the active step Id
    private String currentStep = '';
    //Flag to check reset callout
    private Boolean resetCallout;
    //Local Constants
    private Set<String> scenarioTypeSet = new Set<String>{ 'Transition', 'Change of Mobile Number', 'Port Out Reversal', 'Port In', 'Transition with Inactive Sim', 'Reactivate'};  // Added "Transition with Inactive Sim" as part of EDGE-173277
    private static String handler = 'UpdateMSISDNCheck';
    private Integer serviceCounter = 0;


    /**************************************************************
        Name: performCallouts
        Parameters: List<SObject> steps
        Return Type: Boolean
        Description: Overriding the performCallouts method of Calloutable interface
      *******************************************************************/
    public override Boolean performCallouts(List<SObject> steps) {
        if (Orchestration_LimitsUtility.areCallOutLimitsViolated()) {
            //Cannot process the records
            return false;
        }

        //Exception Handling
        try {
            List<CSPOFA__Orchestration_Step__c> stepList = getStepListData(steps);

            //Get Order --> Service Map
            for (csord__Service__c ser : [
                SELECT Id, serviceMSISDN__c, csordtelcoa__Product_Configuration__r.configGUID__c, cssdm__solution_association__c, csord__Order__c
                FROM csord__Service__c
                WHERE csord__Order__c IN :orderIds AND serviceMSISDN__C != null AND cssdm__solution_association__c != null AND (Scenario_Type__c IN :scenarioTypeSet OR csordtelcoa__Replaced_Service__c = null) AND csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Mobile_Number_Check__c = true
            ]) {
                if (!ordToServiceMap.containsKey(ser.csord__Order__c)) {
                    ordToServiceMap.put(ser.csord__Order__c, new List<csord__Service__c>{ ser });
                } else {
                    ordToServiceMap.get(ser.csord__Order__c).add(ser);
                }
            }

            //Step processing
            for (CSPOFA__Orchestration_Step__c step : stepList) {
                try {
                    //Limit check
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

                    if (!ordToServiceMap.containsKey(step.CSPOFA__Orchestration_Process__r.Order__c)) {
                        //Updating steps as Error since no proper data linked to step
                        stepResults.put(step.Id, new stepResult('Success: No MSISDN Service available on the order', OrchestratorConstants.OrchestratorStep.Complete));
                        //move to next step
                        continue;
                    }

                    //Setting the current variable
                    currentStep = step.Id;

                    //Check if reset callouts
                    if (step.cspofa__message__c == null || (step.cspofa__message__c != null && step.cspofa__message__c.contains(OrchestratorConstants.SystemConstant.stepResetMsg))) {
                        resetCallout = true;
                    } else {
                        resetCallout = false;
                    }

                    //Bulk method called
                    checkResponse(step.CSPOFA__Orchestration_Process__r.Order__c);
                } catch (Exception ex) {
                    stepResult cr = this.stepResults.get(step.Id);
                    if (cr != null) {
                        cr.message = 'Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber();
                        cr.status = OrchestratorConstants.OrchestratorStep.Error;
                    } else {
                        stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
                    }
                }
            }
        } catch (Exception ex) {
            for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) steps) {
                stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
            }
        }

        return !this.stepResults.isEmpty();
    }

    private void checkResponse(String ordId) {
        //Solution --> Service
        Map<Id, List<csord__Service__c>> solnToServiceMap = new Map<Id, List<csord__Service__c>>();
        List<Orchestration_CallOutResponse> stepToCallOutResponse = new List<Orchestration_CallOutResponse>();
        Map<Id, ApplicationLog__c> recToResponse = new Map<Id, ApplicationLog__c>();
        Boolean errorCallout = false;
        Integer successCallOutCnt = 0;
        //Capturing the solutions
        for (csord__Service__c serviceRec : ordToServiceMap.get(ordId)) {
            String solutionId = serviceRec.cssdm__solution_association__c;

            if (!mapStepIdToRecordApplicationLog.IsEmpty() && mapStepIdToRecordApplicationLog.containsKey(currentStep)) {
                recToResponse = mapStepIdToRecordApplicationLog.get(currentStep);
            }

           
            if (!recToResponse.isEmpty() && recToResponse.containsKey(serviceRec.Id)) {
                String resCode = recToResponse.get(serviceRec.Id).Status_Code__c;
                //Check if the response is of success
                if (resCode != null && resCode == '200') {
                    //move to next subscription, as success response already exists
                    successCallOutCnt++;
                    continue;
                } else if (!resetCallout) {
                    //Code is not success and message is not set for reset therefore callouts are not required here (App log already exists)
                    continue;
                }
            }
            
            serviceCounter++;

            if (Orchestration_LimitsUtility.areCallOutLimitsViolated() || serviceCounter >= Governor_Limits__c.getInstance().Update_Config_Counter__c) {
                //Terminate the loop
                break;
            }


            //Capturing the solution related to the service
            Datetime startTime = System.now();
            cssmgnt.API_1 api = new cssmgnt.API_1();
            String response = '';
            if (!Test.isRunningTest()) {
                response = api.updateConfigurations(solutionId, new Map<String, Map<String, String>>{ serviceRec.csordtelcoa__Product_Configuration__r.configGUID__c => new Map<String, String>{ Label.CustomerFacingServiceId => serviceRec.serviceMSISDN__c } });
            } else {
                response = 'UpdateMSISDNCheck';
            }

            Datetime endTime = System.now();
            Long reqTime = Orchestration_Utility.getRequestTimeDifference(startTime, endTime);
            String statusCode = '200';

            //Create a unique Identifier
            String correlationId = Orchestration_Utility.getUID();

            //Capture multiple Response for success
            if (!String.IsBlank(response)) {
                stepToCallOutResponse.add(new Orchestration_CallOutResponse(serviceRec.Id, null,'Success', statusCode, handler, 'Integration', null, correlationId, null, reqTime, Orchestration_CalloutUtility.HTTP_METHOD_POST));
                successCallOutCnt++;
            } else {
                statusCode = '404';
                stepToCallOutResponse.add(new Orchestration_CallOutResponse(serviceRec.Id, null,'Error', statusCode, handler, 'Exception', null, correlationId, statusCode, reqTime, Orchestration_CalloutUtility.HTTP_METHOD_POST));
                errorCallout = true;
            }
        }

        if (errorCallout) {
            stepResults.put(currentStep, new stepResult('Error: Error in callouts, please refer application logs', OrchestratorConstants.OrchestratorStep.Error, stepToCallOutResponse));
        } else if (successCallOutCnt == ordToServiceMap.get(ordId).size()) {
            stepResults.put(currentStep, new stepResult('Success: All Callout Performed', OrchestratorConstants.OrchestratorStep.Complete, stepToCallOutResponse));
        } else {
            stepResults.put(currentStep, new stepResult('Partial Success: Partial Callout performed due to limits hit', OrchestratorConstants.OrchestratorStep.InProgress, stepToCallOutResponse));
        }
    }

    /**************************************************************
        Name: process
        Parameters: List<SObject> steps  
        Return Type: List<SObject>
        Description: Overriding the process method of ExecutionHandler interface
      *******************************************************************/
    public override List<SObject> process(List<SObject> steps) {
        return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
    }

    private List<CSPOFA__Orchestration_Step__c> getStepListData(List<sObject> steps) {
        Set<String> stepIds = new Set<String>();
        //Fetching more fields from the query
        List<CSPOFA__Orchestration_Step__c> stepList = [SELECT Id, Name, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c, CSPOFA__Orchestration_Process__r.Order__c, JSON__c FROM CSPOFA__Orchestration_Step__c WHERE Id IN :steps];

        for (CSPOFA__Orchestration_Step__c step : stepList) {
            //Fetching the order Set
            if (step.CSPOFA__Orchestration_Process__r.Order__c != null) {
                orderIds.add(step.CSPOFA__Orchestration_Process__r.Order__c);
                stepIds.add(step.Id);
            }
        }

        //Get the logs related to the steps
        getResponseAndProcessIdAttachments(stepIds, handler);

        //Returning the step list
        return stepList;
    }
}