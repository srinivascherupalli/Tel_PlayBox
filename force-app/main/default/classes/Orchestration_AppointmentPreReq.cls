/**================================================================
 * Appirio, Inc
 * Name: Orchestration_AppointmentPreReq
 * Description: Class will Invokes the AppointmentPrerequisite callout
 * Created Date: June 15, 2020
 * Created By: Gaurang Maheshwari 
 =======================================================================================================================
  ChangeSet       No      Name            		Date            Description
  DPG-3906        1       Lalit/Vitap   		16-02-2021     Added method filterNotRequiredSpecificationsForIpSite
 ======================================================================================================================*/

global with sharing class Orchestration_AppointmentPreReq extends Orchestration_AbstractStepHandler {
    //Step --> Processed Ids, store subId as processedId instead of Appointment
    private Map<String, Orchestration_ProcessedRecords> processedIds = new Map<String, Orchestration_ProcessedRecords>();
    //StepList will be fetched in performCallout
    private List<CSPOFA__Orchestration_Step__c> stepList = new List<CSPOFA__Orchestration_Step__c>();
    //Order --> Subscription
    private Map<Id, List<csord__Subscription__c>> ordToSubsMap = new Map<Id, List<csord__Subscription__c>>();
    //Subscription --> Service
    private Map<Id, List<csord__Service__c>> subToServMap = new Map<Id, List<csord__Service__c>>();
    //Service --> Attachment
    private Map<Id, Orchestration_AttachmentWrapper> serviceToAttachMap = new Map<Id, Orchestration_AttachmentWrapper>();
    //List for Appointment insertion
    private List<Required_Appointment__c> insertAppointment = new List<Required_Appointment__c>();
    //Map for order updation
    private Map<Id, csord__Order__c> updateOrderMap = new Map<Id, csord__Order__c>();
    //Store Handler Metadata
    private Integration_Handler__mdt handlerMetaData = new Integration_Handler__mdt();
    //Track if exception happens for all steps in callout
    private Boolean exceptionInCallOut = false;
    //Store the active step Id
    private String currentStep = '';
    //Store the Id of the step where limit got hit
    private String pendingStep = '';
    //Store multiple records for a step at a place
    private Map<String, Set<String>> stepRelationshipMap = new Map<String, Set<String>>();
    //Storing the success
    private Set<String> correctStatusCode = new Set<String>{ '200', '201', '202' };
    //Flag to check reset callout
    private Boolean resetCallout;
    //Local CONSTANT
    private static String cancel = 'Cancel';
    private static String add = 'ADD';
    private static String modify = 'MODIFY';
    private static String cease = 'CEASE';
    private static String existingActive = 'EXISTING-ACTIVE';
    private static String fulfil = '_Fulfilment';
    private static String parentSpec = 'parentSpec';
    private static String amdocs = 'B2B_Amdocs';
    private static String genericOrder = 'GENERIC ORDER';
    private static String metro = 'METRO';
    private static String regional = 'REGIONAL';
    private static String std = 'STD';
    private static String handler = 'GenerateAppointmentHandler';
    private static String iPSiteInstanceID = '877ca8f5-2487-752c-ad43-5b6dba91fe82';

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
            stepList = getStepListData(steps);

            //get skip appointment products from custom metadata DPG-3906
            NumberReservationSetting__mdt[] skipAppointmentRecords = [Select  type__c,value__c from NumberReservationSetting__mdt where type__c = 'SkipAppointmentProduct'];
            Set<String> skipAppointmentProductList = new Set<String>();
            for(NumberReservationSetting__mdt record:skipAppointmentRecords) {
                skipAppointmentProductList.add(record.value__c);
            }

            //Capturing the subscription
            //update by NEON: skipping SD-WAN appointment booking...
            Map<Id, csord__Subscription__c> subsMap = new Map<Id, csord__Subscription__c>(
                [
                    SELECT Id, Name, Site__c, toBeCancelled__c, csord__Order__c, csordtelcoa__Replacement_Subscription__c, csordtelcoa__Product_Configuration__r.Type__c, site__r.Address__c, csord__Order__r.csord__Order_Number__c, site__r.cscrm__Installation_Address_Details__c
                    FROM csord__Subscription__c
                    WHERE csord__Order__c IN :orderIds AND Site__c != null and csordtelcoa__Product_Configuration__r.Name != null and csordtelcoa__Product_Configuration__r.Name not in :skipAppointmentProductList
                ]
            );
            for (csord__Subscription__c sub : subsMap.values()) {
                /*if (Orchestration_LimitsUtility.areCallOutLimitsViolated()) {
                    //Collection cannot be created
                    return false;
                }*/

                if (!ordToSubsMap.containsKey(sub.csord__Order__c)) {
                    ordToSubsMap.put(sub.csord__Order__c, new List<csord__Subscription__c>{ sub });
                } else {
                    ordToSubsMap.get(sub.csord__Order__c).add(sub);
                }
            }

            //Capturing the service
            Map<ID, csord__Service__c> serviceMap = new Map<ID, csord__Service__c>([SELECT Id, Name, Zone__c, csord__Status__c, SiteId__c, Cust_Req_Disconn_Date__c, Not_Before_CRD__c, csord__Subscription__c FROM csord__Service__c WHERE csord__Subscription__c IN :subsMap.keySet()]);

            for (csord__Service__c serv : serviceMap.values()) {
                /*if (Orchestration_LimitsUtility.areCallOutLimitsViolated()) {
                    //Collection cannot be created
                    return false;
                }*/

                if (!subToServMap.containsKey(serv.csord__Subscription__c)) {
                    subToServMap.put(serv.csord__Subscription__c, new List<csord__Service__c>{ serv });
                } else {
                    subToServMap.get(serv.csord__Subscription__c).add(serv);
                }
            }

            //Capture the Attachment
            for (Attachment attch : [SELECT Id, Name, body, parentId FROM Attachment WHERE parentId IN :serviceMap.keySet() AND Name = :OrchestratorConstants.DataOrchestrationNames.service]) {
                /*if (Orchestration_LimitsUtility.areCallOutLimitsViolated()) {
                    //Collection cannot be created
                    return false;
                }*/

                serviceToAttachMap.put(attch.parentId, new Orchestration_AttachmentWrapper(attch.Id, attch.body));
            }

            //Fetching the Metadata
            handlerMetaData = getIntegrationHandlerSettings(handler);

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

                    if (!ordToSubsMap.containsKey(step.CSPOFA__Orchestration_Process__r.Order__c)) {
                        //Updating steps as Error since no proper data linked to step
                        stepResults.put(step.Id, new stepResult('Success: Appointment not required for the order', OrchestratorConstants.OrchestratorStep.Complete));
                        //move to next step
                        continue;
                    }

                    //Setting the current variable
                    currentStep = step.Id;

                    //generating the token - OAuth Callout
                    Datetime startTime = System.now();
                    String token = Orchestration_CalloutUtility.getOauthToken(handlerMetaData);
                    //String token = 'xyzforMockInterface';
                    Datetime endTime = System.now();
                    Long reqTime = Orchestration_Utility.getRequestTimeDifference(startTime, endTime);

                    //OAuth Failure
                    if (String.isBlank(token)) {
                        stepResults.put(currentStep, new stepResult('Error: OAuth Failure', OrchestratorConstants.OrchestratorStep.Error, new List<Orchestration_CallOutResponse>{ new Orchestration_CallOutResponse(null, null, null, null, 'OAuthLogin', 'Exception', null, null, null, reqTime, Orchestration_CalloutUtility.HTTP_METHOD_GET) }));
                        //move to next step
                        continue;
                    }

                    //Limit check after OAuth Generation
                    if (Orchestration_LimitsUtility.areCallOutLimitsViolated()) {
                        //terminate the loop
                        break;
                    }

                    //Check if reset callouts
                    if (step.cspofa__message__c == null || (step.cspofa__message__c != null && step.cspofa__message__c.contains(OrchestratorConstants.SystemConstant.stepResetMsg))) {
                        resetCallout = true;
                    } else {
                        resetCallout = false;
                    }

                    //Call the method
                    generateAppointment(step.CSPOFA__Orchestration_Process__r.Order__c, token);
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
            //Check if everything when to exception
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
                            //Bulk Method - return true if limit hits
                            system.debug('**** calling save appointment method');
                            if (saveAppointment(AppointmentResponseDTO.parse(resp.responseBody), step.CSPOFA__Orchestration_Process__r.Order__r, relRecId)) {
                                //Capturing the step where limit got
                                pendingStep = step.Id;
                                //Terminate the loop
                                break;
                            }
                        }
                    }
                }

                //Response exists therefore no step result created in performcallout, pending step means limits got hit
                if (!mapStepIdToRecordApplicationLog.IsEmpty() && mapStepIdToRecordApplicationLog.containsKey(step.Id) && String.IsBlank(pendingStep)) {
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

                            //Bulk Method - return true if limit hits
                            system.debug('**** Response exists: calling save appointment method');
                            if (saveAppointment(AppointmentResponseDTO.parse(respBody), step.CSPOFA__Orchestration_Process__r.Order__r, relRecId)) {
                                //Capturing the step where limit got
                                pendingStep = step.Id;
                                //Terminate the loop
                                break;
                            }
                        }
                    }
                }
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

        if (insertAppointment.size() > 0 || updateOrderMap.size() > 0) {
            //Need to override the method
            updateAndInsertObjects();
        }

        return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
    }

    /* For Callouts
        Order --> sub = no of callout --> Success  --> In progress
        Order --> sub = no of callout --> Success (No callout but App logs exists, skip callout case) --> In progress
        Order --> sub >= no of call (if any error) --> Error --> Error
        Order --> sub > no of call (No error) --> Partial Success --> In progress
    */
    private void generateAppointment(String ordId, String token) {
        List<Orchestration_CallOutResponse> stepToCallOutResponse = new List<Orchestration_CallOutResponse>();
        Map<Id, ApplicationLog__c> recToResponse = new Map<Id, ApplicationLog__c>();
        Boolean errorCallout = false;
        Integer successCallOutCnt = 0;
        if (!mapStepIdToRecordApplicationLog.IsEmpty() && mapStepIdToRecordApplicationLog.containsKey(currentStep)) {
            recToResponse = mapStepIdToRecordApplicationLog.get(currentStep);
        }

        for (csord__Subscription__c subs : ordToSubsMap.get(ordId)) {
            if (Orchestration_LimitsUtility.areCallOutLimitsViolated()) {
                //Terminate the loop
                break;
            }

            if (!recToResponse.isEmpty() && recToResponse.containsKey(subs.Id)) {
                String resCode = recToResponse.get(subs.Id).Status_Code__c;
                //Check if the response is of success
                if (resCode != null && correctStatusCode.contains(resCode)) {
                    //move to next subscription, as success response already exists
                    successCallOutCnt++;
                    continue;
                } else if (!resetCallout) {
                    //Code is not success and message is not set for reset therefore callouts are not required here (App log already exists)
                    continue;
                }
            }

            //Capture all the transaction product related to the subscription
            List<AppointmentRequestDTO.TransactionProducts> transProdList = new List<AppointmentRequestDTO.TransactionProducts>();
            AppointmentRequestDTO appoint = new AppointmentRequestDTO();
            AppointmentRequestDTO.Data appointReq = new AppointmentRequestDTO.Data();
            AppointmentRequestDTO.TransactionProducts transProd;
            String offerprodID;

            for (csord__Service__c serv : subToServMap.get(subs.Id)) {
                //Check if attachment exists
                if (!serviceToAttachMap.containsKey(serv.Id)) {
                    //move to next service
                    continue;
                }

                String prodAction = existingActive;
                if (subs.csordtelcoa__Product_Configuration__c != null && subs.csordtelcoa__Product_Configuration__r.Type__c != null) {
                    if (!subs.csordtelcoa__Product_Configuration__r.Type__c.equals(cancel)) {
                        if (subs.csordtelcoa__Replacement_Subscription__c != null) {
                            prodAction = modify;
                        } else {
                            prodAction = add;
                        }
                    } else {
                        prodAction = cease;
                    }
                }

                for (CS_SpecificationDTO.ServiceSpecification srvSpec : CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serviceToAttachMap.get(serv.Id).attchBody.toString()), OrchestratorConstants.TargetSystem.FULFILMENT)) {
                    //Initialize TransactionProducts
                    transProd = new AppointmentRequestDTO.TransactionProducts();
                    transProd.productAction = prodAction;
                    transProd.productID = srvSpec.code.remove(fulfil);
                    transProd.productInstanceID = srvSpec.guid;

                    if (srvSpec.identifier.contains('ProductOffering')) {
                        offerprodID = srvSpec.identifier.substringBeforeLast('DMCAT');
                    }

                    if (srvSpec.additionalAttributes != null) {
                        for (CS_SpecificationDTO.SimpleAttributes additionalAttr : srvSpec.additionalAttributes) {
                            if (additionalAttr.name.contains(parentSpec)) {
                                transProd.parentProductInstanceID = additionalAttr.value;
                            }
                        }
                    }

                    //Initialize ProductParameters
                    List<AppointmentRequestDTO.ProductParameters> prodParamList = new List<AppointmentRequestDTO.ProductParameters>();
                    for (CS_SpecificationDTO.SimpleAttributes simpleAttr : srvSpec.SimpleAttributes) {
                        if (simpleAttr.name != '' && simpleAttr.value != '') {
                            AppointmentRequestDTO.ProductParameters prodParam = new AppointmentRequestDTO.ProductParameters();
                            prodParam.parameterName = simpleAttr.name;
                            prodParam.parameterValue = simpleAttr.value;
                            prodParamList.add(prodParam);
                        }
                    }
                    transProd.productParameters = prodParamList;
                    transProdList.add(transProd);
                }
                if (serv.SiteId__c != null && subs.toBeCancelled__c.equals('true') && serv.Cust_Req_Disconn_Date__c != null) {
                    String dc = String.valueOfGMT(serv.Cust_Req_Disconn_Date__c);
                    appointReq.notEarlierThanDate = dc.replace(' ', 'T');
                } else if (serv.SiteId__c != null && subs.toBeCancelled__c.equals('false') && serv.Not_Before_CRD__c != null) {
                    String dt = String.valueOfGMT(serv.Not_Before_CRD__c);
                    appointReq.notEarlierThanDate = dt.replace(' ', 'T');
                }

                if (serv.name != null && serv.name.containsIgnoreCase('User - Fixed Seat - ')) {
                    if (serv.Zone__c != null && (serv.Zone__c.equals('1') || serv.Zone__c.equals('2'))) {
                        appointReq.locationType = metro;
                    } else if (serv.Zone__c != null && (serv.Zone__c.equals('3') || serv.Zone__c.equals('4'))) {
                        appointReq.locationType = regional;
                    }
                }
              
                appointReq.ruleSetID = amdocs;
                appointReq.transactionType = genericOrder;
                if (subs.site__r.cscrm__Installation_Address_Details__c != null) {
                    appointReq.state = subs.site__r.cscrm__Installation_Address_Details__c.substringBefore(',');
                }
            }

            //After going through the Service Specs
            transProd = new AppointmentRequestDTO.TransactionProducts();
            transProd.productAction = existingActive;
            if (subs.csordtelcoa__Product_Configuration__c != null && subs.csordtelcoa__Product_Configuration__r.Type__c != null) {
                if (!subs.csordtelcoa__Product_Configuration__r.Type__c.equals(cancel)) {
                    if (subs.csordtelcoa__Replacement_Subscription__c != null) {
                        transProd.productAction = modify;
                    } else {
                        transProd.productAction = add;
                    }
                } else {
                    transProd.productAction = cease;
                }
            }
            transProd.productID = offerprodID;
            transProd.productInstanceID = iPSiteInstanceID;
            transProdList.add(transProd);

            //Appointment data
            appointReq.complexityBand = std;
            appointReq.transactionReferenceID = subs.csord__Order__r.csord__Order_Number__c;
            appointReq.transactionProducts = transProdList;
            appoint.correlationId = Orchestration_Utility.getUID();
            appoint.data = appointReq;

            String reqBody = JSON.serialize(appoint, true);
            Datetime startTime = System.now();
            HttpResponse resp = bookAppointment(subs.Id, reqBody, token);
            Datetime endTime = System.now();
            Long reqTime = Orchestration_Utility.getRequestTimeDifference(startTime, endTime);
            String statusCode = String.valueOf(resp.getStatusCode());
            String responseBody = resp.getBody();

            //Capture multiple Response for success
            if (correctStatusCode.contains(statusCode)) {
                stepToCallOutResponse.add(new Orchestration_CallOutResponse(String.valueOf(subs.Id), reqBody, responseBody, statusCode, handler, 'Integration', null, appoint.correlationId, null, reqTime, Orchestration_CalloutUtility.HTTP_METHOD_POST));
                successCallOutCnt++;
            } else {
                stepToCallOutResponse.add(new Orchestration_CallOutResponse(String.valueOf(subs.Id), reqBody, responseBody, statusCode, handler, 'Exception', null, appoint.correlationId, statusCode, reqTime, Orchestration_CalloutUtility.HTTP_METHOD_POST));
                errorCallout = true;
            }
        }

        /*
        Result generation in Perform call out
        All callouts performed --> 'In progress' (msg contains SUCCESS)
        Partial callout performed --> 'In progress' (msg contains PARTIAL SUCCESS)
        Error in callouts --> 'Error' (msg contains ERROR)
        Skip callout but app log exists for all callouts --> 'In progress' (msg contains SUCCESS)

        If result is not present, perform callout is not done for the step therefore skip the processing of that step
        Based on the processing update the stepResult generated on callout
    */
        if (errorCallout) {
            stepResults.put(currentStep, new stepResult('Error: Error in Callouts', OrchestratorConstants.OrchestratorStep.Error, stepToCallOutResponse));
        } else if (successCallOutCnt == ordToSubsMap.get(ordId).size()) {
            stepResults.put(currentStep, new stepResult('Success: All Callout Performed', OrchestratorConstants.OrchestratorStep.InProgress, stepToCallOutResponse));
        } else {
            stepResults.put(currentStep, new stepResult('Partial Success: Partial Callout performed due to limits hit', OrchestratorConstants.OrchestratorStep.InProgress, stepToCallOutResponse));
        }
    }

    //Callout
    private HttpResponse bookAppointment(String subsID, String reqBody, String token) {
        HttpResponse adResponse = new HttpResponse();

        Map<String, String> headerMap = new Map<String, String>{ 'Content-Type' => 'application/json', 'Authorization' => 'Bearer ' + token, 'callingSystemID' => 'COM-B2B-FORCE' };
        adResponse = Orchestration_CalloutUtility.sendRequestGeneric(reqBody, Orchestration_CalloutUtility.HTTP_METHOD_POST, headerMap, handlerMetaData, null);

        /*   FOR TESTING
        String success_GenerateAppo = '{"status":200,"time":"2019-02-01T12:45:10","correlationId":"e8314645-c0fe-42a7-beac-2e64f8b3ebcf","path":"/v1/appointments/appointment-bom","method":"POST","data":{"transactionReferenceID":"MyOrderNumber123","callingSystemID":"b2b","bomID":"BOM0000000009","numberOfAppointmentsRequired":2,"requiredAppointments":[{"arrayItemNumber":1,"appointmentCategory":"NBN","appointmentType":"STANDARD INSTALL","appointmentSubType":"STANDARD","suggestedStartDate":"2019-06-03T00:05:00","minimumStartDate":"2019-02-04T00:05:00","baseRuleProducts":[{"productID":"DMCAT_ProductSpecification_000027","productInstanceID":"463949fd-e9b7-f459-b34f-4bcdb7d5b8d2"}]},{"arrayItemNumber":2,"appointmentCategory":"TELSTRA","appointmentType":"ORDER INSTALL","appointmentSubType":"CUST PREMISES","suggestedStartDate":"2019-06-14T00:05:00","minimumStartDate":"2019-02-04T00:05:00","dependencies":[{"dependentArrayItemNumber":1,"leadTimeDaysApplied":3}],"baseRuleProducts":[{"productID":"DMCAT_ProductSpecification_000073","productInstanceID":"397949fd-e6a7-f459-b34f-4bcdb7d5b5c1"}]}]}}';
        adResponse.setBody(success_GenerateAppo);
        adResponse.setStatusCode(200);
*/
        return adResponse;
    }

    private Boolean saveAppointment(AppointmentResponseDTO appointRes, csord__Order__c ord, String subID) {
        Required_Appointment__c appointment;
        String uniqueCombo;
        system.debug('**** appointRes = ' + appointRes);
        system.debug('**** appointRes.data = ' + appointRes.data);
        if (appointRes != null && appointRes.data != null) {
            system.debug('**** appointRes.data = ' + appointRes.data);
            if (appointRes.data.numberOfAppointmentsRequired == 0) {
                appointment = new Required_Appointment__c();
                appointment.Generate_Appointment_Order__c = ord.Id;
                appointment.Generate_Appointment_Subscription__c = subID;
                appointment.Appointment_BOM_ID__c = appointRes.data.bomID;
                appointment.required_AppointmentCount__c = 0;
                uniqueCombo = subID;
                if (!(processedIds.containsKey(currentStep) && processedIds.get(currentStep).mapInsertedRecords != null && processedIds.get(currentStep).mapInsertedRecords.containsKey(uniqueCombo))) {
                    if (!hasDMLRowsLimitExceeded()) {
                        insertAppointment.add(appointment);
                        //Maintain the relationship, subscription as unique Identifier
                        if (!stepRelationshipMap.containsKey(currentStep)) {
                            stepRelationshipMap.put(currentStep, new Set<String>{ uniqueCombo });
                        } else {
                            stepRelationshipMap.get(currentStep).add(uniqueCombo);
                        }
                    } else {
                        //limit got hit
                        return true;
                    }
                }
            } else {
                for (Integer i = 0; i < appointRes.data.requiredAppointments.size(); i++) {
                    if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        //terminate the loop
                        return false;
                    }
                    appointment = new Required_Appointment__c();
                    appointment.Generate_Appointment_Order__c = ord.Id;
                    appointment.Generate_Appointment_Subscription__c = subID;
                    appointment.Appointment_BOM_ID__c = appointRes.data.bomID;
                    appointment.required_AppointmentCount__c = appointRes.data.numberOfAppointmentsRequired;
                    appointment.array_ItemNumber__c = appointRes.data.requiredAppointments[i].arrayItemNumber;
                    appointment.Appointment_Category__c = appointRes.data.requiredAppointments[i].appointmentCategory;
                    appointment.Appointment_SubType__c = appointRes.data.requiredAppointments[i].appointmentSubType;
                    appointment.Appointment_Type__c = appointRes.data.requiredAppointments[i].appointmentType;

                    if (appointRes.data.requiredAppointments[i].dependencies != null) {
                        appointment.LeadTime_Days__c = appointRes.data.requiredAppointments[i].dependencies[0].leadTimeDaysApplied;
                        appointment.Dependencies__c = String.valueOf(appointRes.data.requiredAppointments[i].dependencies);
                        appointment.dependent_ArrayItemNumber__c = appointRes.data.requiredAppointments[i].dependencies[0].dependentArraryItemNumber;
                    }

                    appointment.Minimum_StartDate__c = Date.valueOf(appointRes.data.requiredAppointments[i].minimumStartDate);
                    appointment.Request_Time__c = Date.valueOf(appointRes.restime);
                    appointment.Sequence_of_Appointment__c = String.valueOf(appointRes.data.requiredAppointments[i].arrayItemNumber);
                    appointment.Suggested_StartDate__c = Date.valueOf(appointRes.data.requiredAppointments[i].suggestedStartDate);
                    appointment.Transaction_Reference_ID__c = appointRes.data.transactionReferenceID;

                    if (appointRes.data.requiredAppointments[i].baseRuleProducts != null) {
                        appointment.baseRuleProducts__c = getBaseRuleProductsJson(appointRes.data.requiredAppointments[i].baseRuleProducts);
                    }

                    //Maintain the relationship, subscription as unique Identifier
                    system.debug('**** uniqueCombo = ' + uniqueCombo);
                    uniqueCombo = subID + '-' + appointment.Appointment_Category__c + '-' + appointment.Appointment_SubType__c;
                    if (!(processedIds.containsKey(currentStep) && processedIds.get(currentStep).mapInsertedRecords != null && processedIds.get(currentStep).mapInsertedRecords.containsKey(uniqueCombo))) {
                        if (!hasDMLRowsLimitExceeded()) {
                            system.debug('**** insertAppointment = ' + insertAppointment);
                            insertAppointment.add(appointment);
                            if (!stepRelationshipMap.containsKey(currentStep)) {
                                stepRelationshipMap.put(currentStep, new Set<String>{ uniqueCombo });
                            } else {
                                stepRelationshipMap.get(currentStep).add(uniqueCombo);
                            }
                        } else {
                            //limit got hit
                            return true;
                        }
                    }
                }
            }

            //Check if order needs update
            if (ord.isAppointmentRequired__c == null || !ord.isAppointmentRequired__c.equals('true')) {
                ord.isAppointmentRequired__c = 'true';
                //Storing Order records for updation
                if (!hasDMLRowsLimitExceeded()) {
                    updateOrderMap.put(ord.Id, ord);
                    //Maintain the relationship
                    if (!stepRelationshipMap.containsKey(currentStep)) {
                        stepRelationshipMap.put(currentStep, new Set<String>{ ord.Id });
                    } else {
                        stepRelationshipMap.get(currentStep).add(ord.Id);
                    }
                } else {
                    //limit got hit
                    return true;
                }
            }
        }

        return false;
    }

    private String getBaseRuleProductsJson(List<AppointmentResponseDTO.BaseRuleProducts> baseRuleProdList) {
        List<Object> onlst = (List<Object>) baseRuleProdList;
        return JSON.serialize(onlst);
    }

    private void updateAndInsertObjects() {
        system.debug('**** inside updateAndInsertObjects');
        //Success DML order Ids
        List<String> orderSuccessIds = new List<String>();
        //Store unique combo of inserted appointment records
        Map<String, String> uniqueAppointment = new Map<String, String>();

        //Perform the Appointment insertion
        system.debug('**** inside insertAppointment : ' + insertAppointment);
        system.debug('**** inside insertAppointment.size() : ' + insertAppointment.size());
        if (insertAppointment.size() > 0) {
            Database.insert(insertAppointment, false);

            for (Required_Appointment__c app : insertAppointment) {
                //Check if inserted
                if (app.Id != null) {
                    if (app.required_AppointmentCount__c == 0) {
                        uniqueAppointment.put(app.Generate_Appointment_Subscription__c, app.Id);
                    } else {
                        uniqueAppointment.put(app.Generate_Appointment_Subscription__c + '-' + app.Appointment_Category__c + '-' + app.Appointment_SubType__c, app.Id);
                    }
                }
            }
        }

        //Updating all the order records
        system.debug('**** inside updateOrderMap.size() : ' + updateOrderMap.size());
        system.debug('**** inside updateOrderMap : ' + updateOrderMap);
        if (updateOrderMap.size() > 0) {
            List<Database.SaveResult> updateResult = Database.update(updateOrderMap.values(), false);

            //Storing the order success Ids
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    orderSuccessIds.add(rslt.getId());
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
                if (uniqueAppointment.containsKey(recId)) {
                    perStepSuccessIds.mapInsertedRecords.putAll(uniqueAppointment);
                    //If order is also not present it failure, processed Id of order is not required
                } else if (!orderSuccessIds.contains(recId)) {
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
            system.debug('**** isFailed : ' + isFailed);
            system.debug('**** pendingStep : ' + pendingStep);
            system.debug('**** cr.message : ' + cr.message);
            if (!isFailed && (String.isBlank(pendingStep) || !pendingStep.equals(stepId))) {
                if (cr.message.contains('Error:')) {
                    cr.message = 'Error: Error in performing callouts, processing done for others';
                    cr.processedRecords = perStepSuccessIds;
                } else if (cr.message.contains('Partial Success:')) {
                    cr.message = 'Partial Success: Partial callouts performed, processing done for others';
                    cr.processedRecords = perStepSuccessIds;
                } else {
                    cr.message = 'Success: Appointment has been created';
                    //Only case where status will be updated
                    cr.status = OrchestratorConstants.OrchestratorStep.Complete;
                }
            } else if (!isFailed && !String.isBlank(pendingStep) && pendingStep.equals(stepId)) {
                if (cr.message.contains('Error:')) {
                    cr.message = 'Error: Error in performing callouts, partial processing done for others';
                } else if (cr.message.contains('Partial Success:')) {
                    cr.message = 'Partial Success: Callouts and records are processed partially';
                } else {
                    cr.message = 'Partial Success: All callouts performed but partial records processed';
                }
                cr.processedRecords = perStepSuccessIds;
            } else {
                if (cr.message.contains('Error:')) {
                    cr.message = 'Error: Error in performing callouts and processing records';
                } else if (cr.message.contains('Partial Success:')) {
                    cr.message = 'Error: Partial callouts and error in processed';
                } else {
                    cr.message = 'Error: All callouts performed but error in records processed';
                }
                cr.processedRecords = perStepSuccessIds;
            }
        }
    }

    private List<CSPOFA__Orchestration_Step__c> getStepListData(List<sObject> steps) {
        Set<String> stepIds = new Set<String>();
        //Fetching more fields from the query
        List<CSPOFA__Orchestration_Step__c> stepList = [SELECT Id, Name, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c, CSPOFA__Orchestration_Process__r.Order__c, CSPOFA__Orchestration_Process__r.Order__r.isAppointmentRequired__c, JSON__c FROM CSPOFA__Orchestration_Step__c WHERE Id IN :steps];

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

    public override boolean hasDMLRowsLimitExceeded() {
        if (updateOrderMap.size() + insertAppointment.size() + Limits.getDMLRows() < Integer.valueOf(Governor_Limits__c.getInstance().DML_Rows_limit__c)) {
            return false;
        }
        //Limit Hit
        return true;
    }
}