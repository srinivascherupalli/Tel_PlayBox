/**================================================================
 * Appirio, Inc
 * Name: Orchestration_NumberReservationForIoT
 * Description: Class to update billing Subscription and related data
 * Created Date: July 4, 2020
 * Created By: Gaurang Maheshwari
 ==================================================================*/
global with sharing class Orchestration_NumberReservationForIoT extends Orchestration_AbstractStepHandler {
    //Step --> Processed Ids
    private Map<String, Orchestration_ProcessedRecords> processedIds = new Map<String, Orchestration_ProcessedRecords>();
    //StepList will be fetched in performCallout
    private List<CSPOFA__Orchestration_Step__c> stepList = new List<CSPOFA__Orchestration_Step__c>();
    //Store Id --> Service
    private Map<Id, csord__service__c> serviceMap = new Map<Id, csord__service__c>();
    //Order --> Service
    private Map<Id, List<csord__Service__c>> orderServiceMap = new Map<Id, List<csord__Service__c>>();
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
    //Collection for DML Operation
    private Map<String, Number__c> numbersToInsert = new Map<String, Number__c>();
    private Map<Id, csord__Subscription__c> subscriptionsToUpdate = new Map<Id, csord__Subscription__c>();
    private Map<Id, csord__Service__c> servicesToUpdate = new Map<Id, csord__Service__c>();
    private Map<Id, Attachment> attachmentsToUpdate = new Map<Id, Attachment>();
    private Map<Id, Task> tasksToInsert = new Map<Id, Task>();
    //Store the order prefix
    private String orderKeyPrefix = csord__Order__c.SobjectType.getDescribe().getKeyPrefix();
    //Store the task record type
    private static Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('General').getRecordTypeId();
    //Local constants
    private static String handler = 'SearchFNN';
    private static final String HTTP422UNMS = 'The request is invalid due to a missing mandatory parameter or an invalid parameter value';
    private static final String HTTP409UNMS = 'Downstream is not allowing the operation to be performed due to resource state violation';

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
                    SELECT Id, Name, csord__Order__c, csordtelcoa__Product_Basket__c, csordtelcoa__Product_Configuration__c, csord__Subscription__c, csord__Subscription__r.serviceMSISDN__c, csordtelcoa__Service_Number__c, csordtelcoa__Product_Basket__r.csbb__Account__c, serviceMSISDN__c
                    FROM csord__Service__c
                    WHERE csord__Order__c IN :orderIds AND serviceMSISDN__c = NULL AND csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name = :System.Label.IoTSubscription
                ]
            );

            //Product Configuration is must for callouts
            for (csord__service__c ser : serviceMap.values()) {
                //Create Order to Service Map
                if (!orderServiceMap.containsKey(ser.csord__Order__c)) {
                    orderServiceMap.put(ser.csord__Order__c, new List<csord__Service__c>{ ser });
                } else {
                    orderServiceMap.get(ser.csord__Order__c).add(ser);
                }
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

                    //Check MSI reservation is required
                    if (step.CSPOFA__Orchestration_Process__r.Order__r.csord__Status2__c == OrchestratorConstants.OrderStatus.ReadyForSubmit) {
                        stepResults.put(step.Id, new stepResult('Success: Step related order already Ready for Submit', OrchestratorConstants.OrchestratorStep.Complete));
                        //move to next step
                        continue;
                    }

                    if (!orderServiceMap.containsKey(step.CSPOFA__Orchestration_Process__r.Order__c)) {
                        //Updating steps as Error since no proper data linked to step
                        stepResults.put(step.Id, new stepResult('Success: No Services attached under Order for Search Numbers', OrchestratorConstants.OrchestratorStep.Complete));
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
                    UNMSsearchFNN(step.CSPOFA__Orchestration_Process__r.Order__c);
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
                for (Attachment attch : [SELECT Id, body, parentId FROM Attachment WHERE parentId IN :serviceMap.keySet() AND Name = :OrchestratorConstants.DataOrchestrationNames.service]) {
                    serviceToAttachMap.put(attch.parentId, new Orchestration_AttachmentWrapper(attch.Id, attch.body));
                }
            }

            for (CSPOFA__Orchestration_Step__c step : stepList) {
                try {
                    //Limit check
                    if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        //terminate the loop
                        break;
                    }

                    //If result is not present, perform callout is not done for the step therefore skip the processing of that step
                    stepResult cr = this.stepResults.get(step.Id);
                    if (cr == null) {
                        //Check for next step
                        continue;
                    }

                    //Setting the current variable
                    currentStep = step.Id;

                    String orderId = step.CSPOFA__Orchestration_Process__r.Order__c;

                    //Message is already given on perform CallOut
                    if (orderId == null || !orderServiceMap.containsKey(orderId) || step.CSPOFA__Orchestration_Process__r.Order__r.csord__Status2__c == OrchestratorConstants.OrderStatus.ReadyForSubmit) {
                        //move to next step
                        continue;
                    }

                    //Only order will be present in Json
                    Orchestration_ProcessedRecords processedRecordIds = getProcessedRecords(step);

                    if (processedRecordIds != null) {
                        processedIds.put(step.Id, processedRecordIds);
                    }

                    //Capture all the response related to the order from result and app logs
                    List<String> capturedResponse = new List<String>();

                    //Step result will be present only if response was not captured earlier
                    if (cr.callOutResponse != null) {
                        //Iterating over each response
                        for (Orchestration_CallOutResponse resp : cr.callOutResponse) {
                            if (Orchestration_LimitsUtility.areLimitsViolated()) {
                                //terminate the loop
                                break;
                            }
                            String resCode = resp.statusCode;

                            if (resCode != null && (correctStatusCode.contains(resCode) || resCode.equals('422') || resCode.equals('409'))) {
                                //Capture the response
                                if (resp.responseBody != null) {
                                    capturedResponse.add(resp.responseBody);
                                }
                            }
                        }
                    }

                    //Response exists therefore no step result created in performcallout, pending step means limits got hit
                    if (!mapStepIdToUniqueIdApplicationLog.IsEmpty() && mapStepIdToUniqueIdApplicationLog.containsKey(step.Id)) {
                        Map<String, ApplicationLog__c> recToResponse = mapStepIdToUniqueIdApplicationLog.get(currentStep);
                        for (ApplicationLog__c applg : recToResponse.values()) {
                            if (Orchestration_LimitsUtility.areLimitsViolated()) {
                                //terminate the loop
                                break;
                            }

                            String resCode = applg.Status_Code__c;
                            if (resCode != null && (correctStatusCode.contains(resCode) || resCode.equals('422') || resCode.equals('409'))) {
                                String respBody = getcalloutResponse(applg);
                                //Capture the response
                                if (respBody != null) {
                                    capturedResponse.add(respBody);
                                }
                            }
                        }
                    }

                    //returns - true if limit hits
                    if (createNumbersOnServices(capturedResponse, step.CSPOFA__Orchestration_Process__r.Order__r)) {
                        //Capturing the step where limit got
                        pendingStep = step.Id;
                        //Terminate the loop
                        break;
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

        if (tasksToInsert.size() + numbersToInsert.size() + subscriptionsToUpdate.size() + servicesToUpdate.size() + attachmentsToUpdate.size() > 0) {
            //Call update
            updateAndInsertObjects();
        }

        return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
    }

    //generate the request Data to make the request and reserve the number
    private void UNMSsearchFNN(Id orderId) {
        List<Orchestration_CallOutResponse> stepToCallOutResponse = new List<Orchestration_CallOutResponse>();
        Map<String, ApplicationLog__c> recToResponse = new Map<String, ApplicationLog__c>();
        Integer serviceSize = orderServiceMap.get(orderId).size();
        Integer limitQuantity = String.isNotBlank(System.Label.UNMS_SOQL_Limit) ? Integer.valueOf(System.Label.UNMS_SOQL_Limit) : 200;
        Integer loopCounter = (serviceSize / limitQuantity) + ((Math.mod(serviceSize, limitQuantity) > 0) ? 1 : 0);
        Boolean errorCallout = false;

        //Fetching the response from the application logs
        if (!mapStepIdToUniqueIdApplicationLog.IsEmpty() && mapStepIdToUniqueIdApplicationLog.containsKey(currentStep)) {
            recToResponse = mapStepIdToUniqueIdApplicationLog.get(currentStep);
        }

        while (loopCounter > 0) {
            if (Orchestration_LimitsUtility.areCallOutLimitsViolated()) {
                //Terminate the loop
                break;
            }

            if (!recToResponse.isEmpty() && recToResponse.containsKey(String.valueOf(loopCounter))) {
                String resCode = recToResponse.get(String.valueOf(loopCounter)).Status_Code__c;
                //Check if the response is of success
                if (resCode != null && (correctStatusCode.contains(resCode) || resCode.equals('422') || resCode.equals('409')) || !resetCallout) {
                    //Callout response exists
                    loopCounter--;
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

            Integer searchQuan = serviceSize > limitQuantity ? limitQuantity : serviceSize;
            serviceSize -= limitQuantity;

            String correlationId = Orchestration_Utility.getUID();
            FNNSearchRequestDTO dto = new FNNSearchRequestDTO();
            FNNSearchRequestDTO.data fdo = new FNNSearchRequestDTO.data();
            fdo.quantity = searchQuan;
            fdo.resourceType = 'Mobile';
            fdo.activityName = 'Reserve Next Available';
            dto.data = fdo;

            String reqBody = JSON.serialize(dto, true);
            Map<String, String> headerMap = new Map<String, String>{ 'Content-Type' => 'application/json', 'Authorization' => 'Bearer ' + token, 'Correlation_Id' => +correlationId };
            startTime = System.now();
            HttpResponse resp = Orchestration_CalloutUtility.sendRequestGeneric(reqBody, Orchestration_CalloutUtility.HTTP_METHOD_POST, headerMap, handlerMetaData, null);
            endTime = System.now();
            reqTime = Orchestration_Utility.getRequestTimeDifference(startTime, endTime);
            String responseBody = resp.getBody();
            String statusCode = String.valueOf(resp.getStatusCode());

            //Capture multiple Response for success
            if (correctStatusCode.contains(statusCode)) {
                stepToCallOutResponse.add(new Orchestration_CallOutResponse(String.valueOf(loopCounter), reqBody, responseBody, statusCode, handler, 'Integration', null, correlationId, null, reqTime, Orchestration_CalloutUtility.HTTP_METHOD_POST));
            } else if (statusCode == '422') {
                FNNSearchResponseDTO fnnRes = FNNSearchResponseDTO.parse(responseBody);
                stepToCallOutResponse.add(new Orchestration_CallOutResponse(String.valueOf(loopCounter), reqBody, responseBody, String.valueOf(statusCode) + ' : ' + HTTP422UNMS + ' : ' + fnnRes.responseCode, 'SearchFNN', 'Technical', null, correlationId, String.valueOf(statusCode), reqTime, Orchestration_CalloutUtility.HTTP_METHOD_POST));
            } else if (statusCode == '409') {
                stepToCallOutResponse.add(new Orchestration_CallOutResponse(String.valueOf(loopCounter), reqBody, responseBody, String.valueOf(statusCode) + ' : ' + HTTP409UNMS, 'SearchFNN', 'Technical', null, correlationId, String.valueOf(statusCode), reqTime, Orchestration_CalloutUtility.HTTP_METHOD_POST));
            } else {
                stepToCallOutResponse.add(new Orchestration_CallOutResponse(String.valueOf(loopCounter), reqBody, responseBody, statusCode, handler, 'Exception', null, correlationId, statusCode, reqTime, Orchestration_CalloutUtility.HTTP_METHOD_POST));
                errorCallout = true;
            }

            //Callout Done
            loopCounter--;
        }

        //Capture All response, as processing will be done on the process method
        if (errorCallout) {
            stepResults.put(currentStep, new stepResult('Error: Error in Callouts', OrchestratorConstants.OrchestratorStep.Error, stepToCallOutResponse));
        } else if (loopCounter == 0) {
            stepResults.put(currentStep, new stepResult('Success: All Callout Performed', OrchestratorConstants.OrchestratorStep.InProgress, stepToCallOutResponse));
        } else {
            stepResults.put(currentStep, new stepResult('Partial Success: Partial Callout performed due to limits hit', OrchestratorConstants.OrchestratorStep.InProgress, stepToCallOutResponse));
        }
    }

    //Save number against successfull service callout
    private Boolean createNumbersOnServices(List<String> responses, csord__Order__c order) {
        List<String> numbersToReserve = new List<String>();
        Boolean taskRequired = false;

        for (String responseBody : responses) {
            FNNSearchResponseDTO fnnRes = FNNSearchResponseDTO.parse(responseBody);

            if (String.isNotBlank(fnnRes.responseCode) && fnnRes.responseCode.equalsIgnoreCase('UNMSPARTIAL_SUCCESS')) {
                taskRequired = true;
            }

            if (fnnRes.data != null && fnnRes.data.resources != null) {
                for (FNNSearchResponseDTO.Resources res : fnnRes.data.resources) {
                    //Capturing all the numbers from the response
                    if (res.resourceId != null && !(processedIds.containsKey(currentStep) && processedIds.get(currentStep).mapInsertedRecords != null && processedIds.get(currentStep).mapInsertedRecords.containsKey(res.resourceId))) {
                        numbersToReserve.add(res.resourceId);
                    }
                }
            }
        }

        if (numbersToReserve.size() > 0) {
            //Setting the loop count
            Integer loopCount = 0;

            for (csord__Service__c service : orderServiceMap.get(order.Id)) {
                if (hasDMLRowsLimitExceeded() || Orchestration_LimitsUtility.areLimitsViolated()) {
                    //Limit got hit
                    return true;
                }

                if (service.serviceMSISDN__c == null && numbersToReserve.size() >= (loopCount + 1) && !servicesToUpdate.containsKey(service.Id)) {
                    String mobileNo = numbersToReserve.get(loopCount);
                    Number__c msisdn = new Number__c();
                    msisdn.Service_Number__c = mobileNo;
                    msisdn.Basket__c = service.csordtelcoa__Product_Basket__c;
                    msisdn.Type__c = 'New';
                    msisdn.Mobile__c = 'Mobile';
                    msisdn.ListingCode__c = 'No Entry Line';
                    msisdn.Account__c = String.isNotBlank(service.csordtelcoa__Product_Basket__c) ? service.csordtelcoa__Product_Basket__r.csbb__Account__c : null;
                    msisdn.status__c = 'RESERVED';
                    msisdn.Service_Id__c = service.csordtelcoa__Service_Number__c;
                    msisdn.Product_Configuration__c = service.csordtelcoa__Product_Configuration__c;
                    //Adding the number
                    numbersToInsert.put(mobileNo, msisdn);
                    //Maintain the relationship
                    if (!stepRelationshipMap.containsKey(currentStep)) {
                        stepRelationshipMap.put(currentStep, new Set<String>{ mobileNo });
                    } else {
                        stepRelationshipMap.get(currentStep).add(mobileNo);
                    }

                    //Updating the service
                    if (service.serviceMSISDN__c == null || service.serviceMSISDN__c != mobileNo) {
                        service.serviceMSISDN__c = mobileNo;
                        servicesToUpdate.put(service.Id, service);
                        //Maintain the relationship
                        if (!stepRelationshipMap.containsKey(currentStep)) {
                            stepRelationshipMap.put(currentStep, new Set<String>{ service.Id });
                        } else {
                            stepRelationshipMap.get(currentStep).add(service.Id);
                        }
                    }

                    //Updating the subscription
                    if (service.csord__Subscription__r.serviceMSISDN__c == null || service.csord__Subscription__r.serviceMSISDN__c != mobileNo) {
                        csord__Subscription__c subRec = new csord__Subscription__c(Id = service.csord__Subscription__c, serviceMSISDN__c = mobileNo);
                        subscriptionsToUpdate.put(service.csord__Subscription__c, subRec);
                        //Maintain the relationship
                        if (!stepRelationshipMap.containsKey(currentStep)) {
                            stepRelationshipMap.put(currentStep, new Set<String>{ subRec.Id });
                        } else {
                            stepRelationshipMap.get(currentStep).add(subRec.Id);
                        }
                    }

                    //Updating the Specs
                    if (serviceToAttachMap.containskey(service.Id)) {
                        Map<String, String> AttrMap = new Map<String, String>();
                        AttrMap.put('CustomerFacingServiceId', mobileNo);
                        List<String> targetSystem = new List<String>{ 'FULFILMENT' };
                        List<String> specCodes = new List<String>{ 'DMCAT_ProductSpecification_000966' };
                        String bodyToUpdate = Orchestration_Utility.addAdditionalAttribute(serviceToAttachMap.get(service.Id).attchBody.toString(), AttrMap, targetSystem, specCodes);

                        if (!bodyToUpdate.equals('false')) {
                            Attachment attAdd = new Attachment(Id = serviceToAttachMap.get(service.Id).attchId);
                            attAdd.body = Blob.valueOf(bodyToUpdate);
                            attachmentsToUpdate.put(attAdd.id, attAdd);
                            //Maintain the relationship
                            if (!stepRelationshipMap.containsKey(currentStep)) {
                                stepRelationshipMap.put(currentStep, new Set<String>{ attAdd.Id });
                            } else {
                                stepRelationshipMap.get(currentStep).add(attAdd.Id);
                            }
                        }
                    }

                    //Increasing the loop count
                    loopCount++;
                }
            }
        }

        //Creating the fall back task
        if (taskRequired && (!(processedIds.containsKey(currentStep) && processedIds.get(currentStep).mapInsertedRecords != null && processedIds.get(currentStep).mapInsertedRecords.containsKey(order.Id)))) {
            Task taskRecord = new Task(ActivityDate = date.today(), RecordTypeId = taskRecordTypeId, Subject = Label.DPGTasksubject, Description = Label.DPGTaskDesc + ' : ' + order.csord__Order_Number__c, Priority = 'High', Status = 'Not Started', WhatId = order.Id, OwnerId = order.CreatedById);
            tasksToInsert.put(order.Id, taskRecord);

            if (!stepRelationshipMap.containsKey(currentStep)) {
                stepRelationshipMap.put(currentStep, new Set<String>{ order.Id });
            } else {
                stepRelationshipMap.get(currentStep).add(order.Id);
            }
        }

        return false;
    }

    private void updateAndInsertObjects() {
        Set<Id> SuccessIds = new Set<Id>();
        //Store unique combo
        Map<String, String> successIdentifiersMap = new Map<String, String>();

        if (tasksToInsert.size() > 0) {
            Database.insert(tasksToInsert.values(), false);
            for (Task taskRecord : tasksToInsert.values()) {
                //Check if inserted
                if (taskRecord.Id != null) {
                    successIdentifiersMap.put(taskRecord.WhatId, taskRecord.Id);
                }
            }
        }

        if (numbersToInsert.size() > 0) {
            Database.insert(numbersToInsert.values(), false);
            for (Number__c numRecord : numbersToInsert.values()) {
                //Check if inserted
                if (numRecord.Id != null) {
                    successIdentifiersMap.put(numRecord.Service_Number__c, numRecord.Id);
                }
            }
        }

        List<Database.SaveResult> updateResult = new List<Database.SaveResult>();

        if (subscriptionsToUpdate.size() > 0) {
            //Updating all the order records
            updateResult = Database.update(subscriptionsToUpdate.values(), false);
            //Storing the order success Ids
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    SuccessIds.add(rslt.getId());
                }
            }
        }

        if (servicesToUpdate.size() > 0) {
            updateResult = Database.update(servicesToUpdate.values(), false);
            //Storing the order success Ids
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    SuccessIds.add(rslt.getId());
                }
            }
        }

        if (attachmentsToUpdate.size() > 0) {
            updateResult = Database.update(attachmentsToUpdate.values(), false);
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
            boolean isOrderTask = false;

            //this will never be null because stepRelationshipMap is present for the step
            stepResult cr = this.stepResults.get(stepId);

            for (String recId : stepRelationshipMap.get(stepId)) {
                //Only order check
                if (successIdentifiersMap.containsKey(recId)) {
                    perStepSuccessIds.mapInsertedRecords.putAll(successIdentifiersMap);

                    if (recId.startsWith(orderKeyPrefix)) {
                        //Updating steps as complete where no processing required
                        cr.message = 'Failure: UNMS Partial Update Made';
                        cr.status = OrchestratorConstants.OrchestratorStep.Complete;
                        isOrderTask = true;
                        break;
                    }
                    //check if the record is a success
                } else if (!SuccessIds.contains(recId)) {
                    //Failure
                    isFailed = true;
                }
            }

            if (isOrderTask) {
                //Move to next step
                continue;
            }

            //Adding the previous stored ids - error/partial processed case
            if (processedIds.containsKey(stepId) && processedIds.get(stepId).mapInsertedRecords != null) {
                perStepSuccessIds.mapInsertedRecords.putAll(processedIds.get(stepId).mapInsertedRecords);
            }

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

    public override boolean hasDMLRowsLimitExceeded() {
        if (tasksToInsert.size() + numbersToInsert.size() + subscriptionsToUpdate.size() + servicesToUpdate.size() + attachmentsToUpdate.size() + Limits.getDMLRows() < Integer.valueOf(Governor_Limits__c.getInstance().DML_Rows_limit__c)) {
            return false;
        }
        //Limit Hit
        return true;
    }
}