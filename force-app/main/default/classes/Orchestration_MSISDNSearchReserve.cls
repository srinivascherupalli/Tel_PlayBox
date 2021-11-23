/**================================================================
 * Appirio, Inc
 * Name: Orchestration_MSISDNSearchReserve
 * Description: Class will create payload and invokes searchReserveMSISDN callout for IP Site with Mobile Access and updates corresponding specifications
 * Created Date: July 4, 2020
 * Created By: Gaurang Maheshwari
 ==================================================================*/
global with sharing class Orchestration_MSISDNSearchReserve extends Orchestration_AbstractStepHandler {
    //Step --> Processed Ids
    private Map<String, Orchestration_ProcessedRecords> processedIds = new Map<String, Orchestration_ProcessedRecords>();
    //StepList will be fetched in performCallout
    private List<CSPOFA__Orchestration_Step__c> stepList = new List<CSPOFA__Orchestration_Step__c>();
    //Store Id --> Service
    private Map<Id, csord__service__c> serviceMap = new Map<Id, csord__service__c>();
    //Order --> Service
    private Map<Id, List<csord__Service__c>> orderServiceMap = new Map<Id, List<csord__Service__c>>();
    //ProductConfig --> Attribute Value
    private Map<Id, cscfga__Attribute__c> prodConfigToAttValMap = new Map<Id, cscfga__Attribute__c>();
    //Service --> Attachment
    private Map<Id, Orchestration_AttachmentWrapper> serviceToAttachMap = new Map<Id, Orchestration_AttachmentWrapper>();
    //Store multiple records for a step at a place
    private Map<String, Set<String>> stepRelationshipMap = new Map<String, Set<String>>();
    //Track if exception happens for all steps in callout
    private Boolean exceptionInCallOut = false;
    //Store the active step Id
    private String currentStep = '';
    //Store the Id of the step where limit got hit
    private String pendingStep = '';
    //Store Handler Metadata
    private Integration_Handler__mdt handlerMetaData = new Integration_Handler__mdt();
    //Storing the success
    private Set<String> correctStatusCode = new Set<String>{ '200', '201', '202' };
    //Flag to check reset callout
    private Boolean resetCallout;
    //Fetch Attributes based on the product Configuration in the process method
    private Set<Id> prodConfigSet = new Set<Id>();
    //Collection to store attachments that needs updation
    private Map<String, Attachment> AttMapTobeUpdated = new Map<String, Attachment>();
    //Collection to store orders that needs updation
    private List<csord__Order__c> updateOrderList = new List<csord__Order__c>();
    //Store the number records
    private List<Number__c> insertFnnNumberList = new List<Number__c>();
    //Collection to store attributes that needs updation
    private Map<Id, cscfga__attribute__c> updateAttributeMap = new Map<Id, cscfga__attribute__c>();
    //Local constants
    private static String handler = 'SearchFNN';

    /**************************************************************
        Name: performCallouts
        Parameters: List<SObject> steps
        Return Type: Boolean
        Description: Overriding the performCallouts method of Calloutable interface
      *******************************************************************/
    public override Boolean performCallouts(List<sObject> steps) {
        if (Orchestration_LimitsUtility.areCallOutLimitsViolated()) {
            //Cannot process the records
            return false;
        }

        //Exception Handling
        try {
            stepList = getStepListData(steps);

            serviceMap = new Map<Id, csord__service__c>(
                [
                    SELECT Id, csord__Order__c, csordtelcoa__Product_Basket__c, csordtelcoa__Product_Basket__r.csbb__Account__c, csordtelcoa__Product_Configuration__c
                    FROM csord__service__c
                    WHERE csord__order__c IN :orderIds AND csordtelcoa__Product_Configuration__c != null AND csord__Service__c = null AND Name LIKE '%IP Site%' AND csordtelcoa__Replaced_Service__c = null
                ]
            );
            //Product Configuration is must for callouts
            for (csord__service__c ser : serviceMap.values()) {
                if (Orchestration_LimitsUtility.areCallOutLimitsViolated()) {
                    //Cannot create collections
                    return false;
                }
                //Create Order to Service Map
                if (!orderServiceMap.containsKey(ser.csord__Order__c)) {
                    orderServiceMap.put(ser.csord__Order__c, new List<csord__Service__c>{ ser });
                } else {
                    orderServiceMap.get(ser.csord__Order__c).add(ser);
                }

                //Capture the product configuration
                prodConfigSet.add(ser.csordtelcoa__Product_Configuration__c);
            }

            //Fetching the Metadata
            handlerMetaData = getIntegrationHandlerSettings(handler);

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

                    if (!orderServiceMap.containsKey(step.CSPOFA__Orchestration_Process__r.Order__c)) {
                        //Updating steps as Error since no proper data linked to step
                        stepResults.put(step.Id, new stepResult('Success: MSISDN held not required for the order', OrchestratorConstants.OrchestratorStep.Complete));
                        //move to next step
                        continue;
                    }

                    //Check MSI reservation is required
                    if (step.CSPOFA__Orchestration_Process__r.Order__r.isMSISDNHeld__c) {
                        //Updating steps as Complete since isMSISDNHeld__c = true
                        stepResults.put(step.Id, new stepResult('Success: MSISDN already held for reservation', OrchestratorConstants.OrchestratorStep.Complete));
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

                    //Main method called
                    searchNumberReq(step.CSPOFA__Orchestration_Process__r.Order__r);
                } catch (Exception ex) {
                    System.debug('Exception: ' + ex + ' Message: ' + ex.getmessage() + ' LineNumber: ' + ex.getLineNumber() + ' \n' + ex.getStackTraceString());
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
            System.debug('Exception: ' + ex + ' Message: ' + ex.getmessage() + ' LineNumber: ' + ex.getLineNumber() + ' \n' + ex.getStackTraceString());
            exceptionInCallOut = true;
            for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) steps) {
                stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
            }
        }

        return !this.stepResults.isEmpty();
    }

    /**************************************************************
        Name: process
        Parameters: List<SObject> steps
        Return Type: List<SObject>
        Description: Overriding the process method of ExecutionHandler interface
      *******************************************************************/
    public override List<SObject> process(List<SObject> steps) {
        if (Orchestration_LimitsUtility.areLimitsViolated() || exceptionInCallOut) {
            //Cannot process the records
            return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
        }

        //Exception Handling
        try {
            //Fetch the Service --> Attachment
            if (serviceMap.size() > 0) {
                for (Attachment attch : [SELECT id, body, parentId FROM Attachment WHERE parentId IN :serviceMap.keySet()]) {
                    serviceToAttachMap.put(attch.parentId, new Orchestration_AttachmentWrapper(attch.Id, attch.body));
                }

                    //Capture the attributes
                    for (cscfga__attribute__c att : [SELECT Id, Name, cscfga__value__c, cscfga__Product_Configuration__c FROM cscfga__attribute__c WHERE cscfga__Product_Configuration__c IN :prodConfigSet AND Name LIKE '%MSISDN%']) {
                        //1:1 mapping for payload
                        prodConfigToAttValMap.put(att.cscfga__Product_Configuration__c, att);
                    }
                }

            for (CSPOFA__Orchestration_Step__c step : stepList) {
                try {
                    //Limit check
                    if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        //terminate the loop
                        break;
                    }

                    //Store count of success callouts
                    Integer successCnt = 0;

                    //Store count of success callouts
                    Integer failCnt = 0;

                    //If result is not present, perform callout is not done for the step therefore skip the processing of that step
                    stepResult cr = this.stepResults.get(step.Id);
                    if (cr == null) {
                        //Check for next step
                        continue;
                    }

                    //Setting the current variable
                    currentStep = step.Id;

                    //Message is already given on perform CallOut
                    if (step.CSPOFA__Orchestration_Process__r.Order__c == null) {
                        //move to next step
                        continue;
                    }

                    if (!orderServiceMap.containsKey(step.CSPOFA__Orchestration_Process__r.Order__c)) {
                        //move to next step
                        continue;
                    }

                    //Check MSI reservation is required
                    if (step.CSPOFA__Orchestration_Process__r.Order__r.isMSISDNHeld__c) {
                        //move to next step
                        continue;
                    }

                    //Only order will be present in Json
                    Orchestration_ProcessedRecords processedRecordIds = getProcessedRecords(step);

                    if (processedRecordIds != null) {
                        processedIds.put(step.Id, processedRecordIds);
                    }

                    //Step result will be present only if response was not captured earlier
                    if (cr.callOutResponse != null) {
                        //Iterating over each response
                        for (Orchestration_CallOutResponse resp : cr.callOutResponse) {
                            if (Orchestration_LimitsUtility.areLimitsViolated()) {
                                //terminate the loop
                                break;
                            }
                            String resCode = resp.statusCode;
                            String relRecId = resp.recordId;

                            if (resCode != null && relRecId != null && correctStatusCode.contains(resCode)) {
                                //returns - true if limit hits
                                if (saveFnnNumber(FNNSearchResponseDTO.parse(resp.responseBody), resp.recordId)) {
                                    //Capturing the step where limit got
                                    pendingStep = step.Id;
                                    //Terminate the loop
                                    break;
                                }
                                successCnt++;
                            } else {
                                failCnt++;
                            }
                        }
                    }

                    if (!String.IsBlank(pendingStep)) {
                        //Terminate the main loop pending step found
                        break;
                    }

                    //Response exists therefore no step result created in performcallout, pending step means limits got hit
                    if (!mapStepIdToRecordApplicationLog.IsEmpty() && mapStepIdToRecordApplicationLog.containsKey(step.Id)) {
                        Map<Id, ApplicationLog__c> recToResponse = mapStepIdToRecordApplicationLog.get(currentStep);
                        for (ApplicationLog__c applg : recToResponse.values()) {
                            if (Orchestration_LimitsUtility.areLimitsViolated()) {
                                //terminate the loop
                                break;
                            }

                            String resCode = applg.Status_Code__c;
                            String relRecId = applg.Related_Record_Id__c;
                            if (resCode != null && relRecId != null && correctStatusCode.contains(resCode)) {
                                String respBody = getcalloutResponse(applg);
                                //returns - true if limit hits
                                if (saveFnnNumber(FNNSearchResponseDTO.parse(respBody), relRecId)) {
                                    //Capturing the step where limit got
                                    pendingStep = step.Id;
                                    //Terminate the loop
                                    break;
                                }
                                successCnt++;
                            } else {
                                failCnt++;
                            }
                        }
                    }

                    if (!String.IsBlank(pendingStep)) {
                        //Terminate the main loop pending step found
                        break;
                    }

                    //Capturing the order
                    csord__Order__c ord = step.CSPOFA__Orchestration_Process__r.Order__r;
                    Integer serviceCnt = orderServiceMap.get(ord.Id).size();
                    if (successCnt == serviceCnt) {
                        //DML check to avoid iteration in process method
                        if (!hasDMLRowsLimitExceeded()) {
                            processSuccessMSISDNReservation(ord);
                        } else {
                            //Capturing the step where limit got
                            pendingStep = step.Id;
                            //Terminate the loop
                            break;
                        }
                    } else if (successCnt + failCnt == serviceCnt) {
                        cr.message = 'Success: All Numbers cannot be Reserved, please refer the application logs';
                        cr.status = OrchestratorConstants.OrchestratorStep.Complete;
                    }
                } catch (Exception ex) {
                    System.debug('Exception: ' + ex + ' Message: ' + ex.getmessage() + ' LineNumber: ' + ex.getLineNumber() + ' \n' + ex.getStackTraceString());
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
            System.debug('Exception: ' + ex + ' Message: ' + ex.getmessage() + ' LineNumber: ' + ex.getLineNumber() + ' \n' + ex.getStackTraceString());
            for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) steps) {
                stepResult cr = this.stepResults.get(step.Id);
                if (cr != null) {
                    cr.message = 'Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber();
                    cr.status = OrchestratorConstants.OrchestratorStep.Error;
                } else {
                    stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
                }
            }
        }

        if (insertFnnNumberList.size() + AttMapTobeUpdated.size() + updateOrderList.size() + updateAttributeMap.size() > 0) {
            //Call update
            updateAndInsertObjects();
        }

        return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
    }

    //generate the request Data to make the request and reserve the number
    private void searchNumberReq(csord__Order__c ord) {
        List<Orchestration_CallOutResponse> stepToCallOutResponse = new List<Orchestration_CallOutResponse>();
        Map<Id, ApplicationLog__c> recToResponse = new Map<Id, ApplicationLog__c>();
        Integer callOutCnt = 0;

        //Fetching the response from the application logs
        if (!mapStepIdToRecordApplicationLog.IsEmpty() && mapStepIdToRecordApplicationLog.containsKey(currentStep)) {
            recToResponse = mapStepIdToRecordApplicationLog.get(currentStep);
        }

        //Order will always have a service, so null check not required
        for (csord__Service__c serv : orderServiceMap.get(ord.Id)) {
            if (Orchestration_LimitsUtility.areCallOutLimitsViolated()) {
                //Terminate the loop
                break;
            }

            if (!recToResponse.isEmpty() && recToResponse.containsKey(serv.Id)) {
                String resCode = recToResponse.get(serv.Id).Status_Code__c;
                //Check if the response is of success
                if (resCode != null && correctStatusCode.contains(resCode) || !resetCallout) {
                    //Callout response exists
                    callOutCnt++;
                    //No call required
                    continue;
                }
            }

            //generating the token - OAuth Callout
            Datetime startTime = System.now();
            String token = Orchestration_CalloutUtility.getOauthToken(handlerMetaData);
            Datetime endTime = System.now();
            Long reqTime = Orchestration_Utility.getRequestTimeDifference(startTime, endTime);

            //OAuth Failure
            if (String.isBlank(token)) {
                stepToCallOutResponse.add(new Orchestration_CallOutResponse(null, null, null, null, 'OAuthLogin', 'Exception', null, null, null, reqTime, Orchestration_CalloutUtility.HTTP_METHOD_GET));
                //move to next service
                continue;
            }

            String correlationId = Orchestration_Utility.getUID();
            FNNSearchRequestDTO dto = new FNNSearchRequestDTO();
            FNNSearchRequestDTO.data fdo = new FNNSearchRequestDTO.data();
            fdo.resourceType = 'Mobile';
            fdo.activityName = 'Reserve Next Available';
            dto.data = fdo;

            String reqBody = JSON.serialize(dto, true);
            Map<String, String> headerMap = new Map<String, String>{ 'Content-Type' => 'application/json', 'Authorization' => 'Bearer ' + token, 'Correlation_Id' => +correlationId };
            startTime = System.now();
            HttpResponse resp = searchNumber(reqBody, headerMap);
            endTime = System.now();
            reqTime = Orchestration_Utility.getRequestTimeDifference(startTime, endTime);
            String responseBody = resp.getBody();
            String statusCode = String.valueOf(resp.getStatusCode());

            //Callout Done
            callOutCnt++;

            //Capture multiple Response for success
            if (correctStatusCode.contains(statusCode)) {
                stepToCallOutResponse.add(new Orchestration_CallOutResponse(String.valueOf(serv.Id), reqBody, responseBody, statusCode, handler, 'Integration', null, correlationId, null, reqTime, Orchestration_CalloutUtility.HTTP_METHOD_POST));
            } else {
                stepToCallOutResponse.add(new Orchestration_CallOutResponse(String.valueOf(serv.Id), reqBody, responseBody, statusCode, handler, 'Exception', null, correlationId, statusCode, reqTime, Orchestration_CalloutUtility.HTTP_METHOD_POST));
            }
        }
        //Capture All response, as processing will be done on the process method
        if (callOutCnt == orderServiceMap.get(ord.Id).size()) {
            stepResults.put(currentStep, new stepResult('Success: All Callout Performed', OrchestratorConstants.OrchestratorStep.InProgress, stepToCallOutResponse));
        } else {
            stepResults.put(currentStep, new stepResult('Partial Success: Searching Number has been queued', OrchestratorConstants.OrchestratorStep.InProgress, stepToCallOutResponse));
        }
    }

    //To make the actual callout to reserve the number
    private HttpResponse searchNumber(String reqBody, Map<String, String> headerMap) {
        HttpResponse resp = new HttpResponse();

        resp = Orchestration_CalloutUtility.sendRequestGeneric(reqBody, Orchestration_CalloutUtility.HTTP_METHOD_POST, headerMap, handlerMetaData, null);

        /* Testing
        String success_fixed = '{"status":200,"code":200,"time":"2019-09-13T06:52:36.542+0000","correlationId":"53425d83-1d66-4bfe-80af-a3e4e5665750","path":"/v1/logical-resources/dialable-numbers","method":"PATCH","responseCode":"UNMS-SUCCESS","data":{"resources":[{"resourceId":"9828200076","countryCode":"61","countryName":"AU","nationalDestinationCode":"3","providedToKey":"2d1bfa7b-790b-4dcf-becf-5cd0e36c525d","activityStatus":"SUCCESS","resourceState":"Held Order","ageOut":"180","ageOutDate":"2020-03-11T06:52:36.000372Z"}]},"request":{"params":{},"method":"PATCH","path":"/v1/logical-resources/dialable-numbers","data":{"resourceState":"Held Order","resources":[{"resourceId":"9828200076"}]}}}';
        resp.setBody(success_fixed);
        resp.setStatusCode(200);
*/
        return resp;
    }

    //Save number against successfull service callout
    private Boolean saveFnnNumber(FNNSearchResponseDTO fnnRes, String serviceId) {
        if (fnnRes.data != null && fnnRes.data.resources != null) {
            csord__service__c service = serviceMap.get(serviceId);
            String uniqueCombo;
            FNNSearchResponseDTO.Resources res = fnnRes.data.resources[0];
            String numberReq = res.resourceId;
            Number__c fnnNumber = new Number__c();
            fnnNumber.Basket__c = service.csordtelcoa__Product_Basket__c;
            fnnNumber.Account__c = service.csordtelcoa__Product_Basket__r.csbb__Account__c;
            fnnNumber.Service_Number__c = numberReq;
            fnnNumber.Status__c = 'RESERVED';
            fnnNumber.Mobile__c = 'Mobile';
            fnnNumber.Type__c = 'New';
            //Maintain the relationship with unique Identifier
            uniqueCombo = fnnNumber.Basket__c + '-' + fnnNumber.Service_Number__c;
            if (!(processedIds.containsKey(currentStep) && processedIds.get(currentStep).mapInsertedRecords != null && processedIds.get(currentStep).mapInsertedRecords.containsKey(uniqueCombo))) {
                if (!hasDMLRowsLimitExceeded()) {
                    insertFnnNumberList.add(fnnNumber);
                    //Maintain the relationship, subscription as unique Identifier
                    if (!stepRelationshipMap.containsKey(currentStep)) {
                        stepRelationshipMap.put(currentStep, new Set<String>{ uniqueCombo });
                    } else {
                        stepRelationshipMap.get(currentStep).add(uniqueCombo);
                    }
                } else {
                    //Limit got Hit
                    return true;
                }
            }

            //Update Attributes
            if (prodConfigToAttValMap.containsKey(service.csordtelcoa__Product_Configuration__c)) {
                cscfga__Attribute__c attr = prodConfigToAttValMap.get(service.csordtelcoa__Product_Configuration__c);
                if (String.IsBlank(attr.cscfga__value__c)) {
                    if (!hasDMLRowsLimitExceeded()) {
                        attr.cscfga__value__c = numberReq;
                        updateAttributeMap.put(attr.Id, attr);
                        if (!stepRelationshipMap.containsKey(currentStep)) {
                            stepRelationshipMap.put(currentStep, new Set<String>{ attr.Id });
                        } else {
                            stepRelationshipMap.get(currentStep).add(attr.Id);
                        }
                    } else {
                        //Limit got Hit
                        return true;
                    }
                }
            }

            //Update Attachment
            if (serviceToAttachMap.containsKey(service.Id)) {
                Map<String, String> AttrMap = new Map<String, String>();
                AttrMap.put('CustomerFacingServiceId', numberReq);
                List<String> targetSystem = new List<String>{ 'FULFILMENT' };
                List<String> specCodes = new List<String>{ 'DMCAT_ProductSpecification_000263' };
                String bodyToUpdate = Orchestration_Utility.addAdditionalAttribute(serviceToAttachMap.get(service.Id).attchBody.toString(), AttrMap, targetSystem, specCodes);

                if (!bodyToUpdate.equals('false')) {
                    if (!hasDMLRowsLimitExceeded()) {
                        Attachment attAdd = new Attachment(Id = serviceToAttachMap.get(service.Id).attchId);
                        attAdd.body = Blob.valueOf(bodyToUpdate);
                        AttMapTobeUpdated.put(attAdd.id, attAdd);
                        //Maintain the relationship
                        if (!stepRelationshipMap.containsKey(currentStep)) {
                            stepRelationshipMap.put(currentStep, new Set<String>{ attAdd.Id });
                        } else {
                            stepRelationshipMap.get(currentStep).add(attAdd.Id);
                        }
                    } else {
                        //Limit got Hit
                        return true;
                    }
                }
            }
        }

        return false;
    }

    private void processSuccessMSISDNReservation(csord__Order__c primaryOrder) {
        primaryOrder.isMSISDNHeld__c = true;
        updateOrderList.add(primaryOrder);
        //Maintain the relationship, subscription as unique Identifier
        if (!stepRelationshipMap.containsKey(currentStep)) {
            stepRelationshipMap.put(currentStep, new Set<String>{ primaryOrder.Id });
        } else {
            stepRelationshipMap.get(currentStep).add(primaryOrder.Id);
        }
    }

    private void updateAndInsertObjects() {
        Set<Id> SuccessIds = new Set<Id>();
        //Store unique combo of inserted FNN Number records
        Map<String, String> uniqueFnnNumber = new Map<String, String>();

        //Perform the Appointment insertion
        if (insertFnnNumberList.size() > 0) {
            Database.insert(insertFnnNumberList, false);
            for (Number__c num : insertFnnNumberList) {
                //Check if inserted
                if (num.Id != null) {
                    uniqueFnnNumber.put(num.Basket__c + '-' + num.Service_Number__c, num.Id);
                }
            }
        }

        List<Database.SaveResult> updateResult = new List<Database.SaveResult>();

        if (AttMapTobeUpdated.size() > 0) {
            //Updating all the order records
            updateResult = Database.update(AttMapTobeUpdated.values(), false);
            //Storing the order success Ids
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    SuccessIds.add(rslt.getId());
                }
            }
        }

        if (updateOrderList.size() > 0) {
            updateResult = Database.update(updateOrderList, false);
            //Storing the order success Ids
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    SuccessIds.add(rslt.getId());
                }
            }
        }

        if (updateAttributeMap.size() > 0) {
            updateResult = Database.update(updateAttributeMap.values(), false);
            //Storing the order success Ids
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    SuccessIds.add(rslt.getId());
                }
            }
        }

        //Iteration over each step, processed Id check is not required
        for (String stepId : stepRelationshipMap.keySet()) {
            //Object Type --> Ids
            Orchestration_ProcessedRecords perStepSuccessIds = new Orchestration_ProcessedRecords();
            //Initializing the orderids Set
            perStepSuccessIds.mapInsertedRecords = new Map<String, String>();
            Boolean isFailed = false;
            for (String recId : stepRelationshipMap.get(stepId)) {
                //Only order check
                if (uniqueFnnNumber.containsKey(recId)) {
                    perStepSuccessIds.mapInsertedRecords.putAll(uniqueFnnNumber);
                    //check if the record is a success
                } else if (!SuccessIds.contains(recId)) {
                    //Failure
                    isFailed = true;
                }
            }

            //Adding the previous stored ids - error/partial processed case
            if (processedIds.containsKey(stepId) && processedIds.get(stepId).mapInsertedRecords != null) {
                perStepSuccessIds.mapInsertedRecords.putAll(processedIds.get(stepId).mapInsertedRecords);
            }

            //this will never be null because stepRelationshipMap is present for the step
            stepResult cr = this.stepResults.get(stepId);

            //If message is an error due to
            if (!isFailed && (String.isBlank(pendingStep) || !pendingStep.equals(stepId))) {
                if (cr.message.contains('Error:') || cr.message.contains('Partial Success:')) {
                    cr.message = cr.message + ' and processing done for other';
                    cr.processedRecords = perStepSuccessIds;
                } else {
                    cr.message = 'Success: Number reservation search performed';
                    cr.status = OrchestratorConstants.OrchestratorStep.Complete;
                }
            } else if (!isFailed && !String.isBlank(pendingStep) && pendingStep.equals(stepId)) {
                if (cr.message.contains('Error:') || cr.message.contains('Partial Success:')) {
                    cr.message = cr.message + ' and partial processing done for other';
                } else {
                    cr.message = 'Partial Success: Number search has been queued';
                }
                cr.processedRecords = perStepSuccessIds;
            } else {
                if (cr.message.contains('Error:') || cr.message.contains('Partial Success:')) {
                    cr.message = cr.message + ' and error in processing other';
                } else {
                    cr.message = 'Error: All callouts performed but error in processing the records';
                }
                cr.processedRecords = perStepSuccessIds;
                cr.status = OrchestratorConstants.OrchestratorStep.Error;
            }
        }
    }

    private List<CSPOFA__Orchestration_Step__c> getStepListData(List<sObject> steps) {
        Set<String> stepIds = new Set<String>();
        //Fetching more fields from the query
        List<CSPOFA__Orchestration_Step__c> stepList = [SELECT Id, Name, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c, CSPOFA__Orchestration_Process__r.Order__c, CSPOFA__Orchestration_Process__r.Order__r.isMSISDNHeld__c, JSON__c FROM CSPOFA__Orchestration_Step__c WHERE Id IN :steps];

        for (CSPOFA__Orchestration_Step__c step : stepList) {
            //Fetching the order Request
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

    public override boolean hasDMLRowsLimitExceeded() {
        if (insertFnnNumberList.size() + AttMapTobeUpdated.size() + updateOrderList.size() + updateAttributeMap.size() + Limits.getDMLRows() < Integer.valueOf(Governor_Limits__c.getInstance().DML_Rows_limit__c)) {
            return false;
        }
        //Limit Hit
        return true;
    }
}