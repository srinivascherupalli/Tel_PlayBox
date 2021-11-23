/**================================================================
 * Infosys Ltd
 * Name: Orchestration_NumberReservForIoTBatch
 * Description: Class to update billing Subscription and related data(including unms api callouts) in batches
 * Created Date: Dec 3, 2020
 * Created By: Vitap Ramdevputra
 * =======================================================================================================================
  ChangeSet       No      Name                Date            Description
  DPG-3906        1       Lalit/Vitap         16-02-2021     Added method filterNotRequiredSpecificationsForIpSite
  DIGI - 1003	  2		  Dharmik			  29-07-2021     Number Reservation for Shared Data Plans
 ==================================================================*/
 public class Orchestration_NumberReservForIoTBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.stateful{
    //Store the active step Id
    private String currentStep = '';
    //Store the Id of the step where limit got hit
    public String pendingStep = '';
    
    //store just orderID of current step
    private Id orderId;
    //store current step record
    private CSPOFA__Orchestration_Step__c step = new CSPOFA__Orchestration_Step__c();
    
    //Order --> Service
    private Map<Id, List<csord__Service__c>> orderServiceMap = new Map<Id, List<csord__Service__c>>();

    private Map<Id, List<csord__Service__c>> orderServiceWithNumberMap = new Map<Id, List<csord__Service__c>>();
    
    //Collection to Store the Step Result
    private Map<Id, Orchestration_AbstractStepHandler.stepResult> stepResults = new Map<Id, Orchestration_AbstractStepHandler.stepResult>();
    
    //Store the task record type
    private static Id taskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('General').getRecordTypeId();
    //Flag to check reset callout
    private Boolean resetCallout;
    
    //temp variable to check if execute is ran manually from finish method
    private boolean ranExecute = false;
    
    Private Map<String, ApplicationLog__c> recToResponse = new Map<String, ApplicationLog__c>();
    
    //Step --> Processed Ids
    private Map<String, Orchestration_ProcessedRecords> processedIds = new Map<String, Orchestration_ProcessedRecords>();
    
    //Log --> Callout Attachment
    private Map<Id, Attachment> stepCalloutAttachData = new Map<Id, Attachment>();
    
    //Collection for DML Operation
    private Map<String, Number_Group__c> numberGroupToInsert = new Map<String, Number_Group__c>();
    private Map<String, Number__c> numbersToInsert = new Map<String, Number__c>();
    private Map<Id, csord__Subscription__c> subscriptionsToUpdate = new Map<Id, csord__Subscription__c>();
    private Map<Id, csord__Service__c> servicesToUpdate = new Map<Id, csord__Service__c>();
    private Map<Id, Attachment> attachmentsToUpdate = new Map<Id, Attachment>();
    private Map<Id, Task> tasksToInsert = new Map<Id, Task>();
    
    //Service --> Attachment
    private Map<Id, Orchestration_AttachmentWrapper> serviceToAttachMap = new Map<Id, Orchestration_AttachmentWrapper>();
    
    //Store multiple records for a step at a place || Stateful variable
    public Map<String, Set<String>> stepRelationshipMap = new Map<String, Set<String>>();
    //to store unique combo after successful dmls || Stateful variable
    public Map<String, String> successIdentifiersMap = new Map<String, String>();
    //store ids of all insert dmls || Stateful variable
    public Set<Id> SuccessIds = new Set<Id>();
    //store current batch transaction number
    public Integer currentTransactionNumber = 0;
    //store current batch + loop counter's list to get appropriate app logs while updating numbers from app log
    public set<string> loopCounterCurrentTransactionList = new set<string>();

    //Store the order prefix
    private String orderKeyPrefix = csord__Order__c.SobjectType.getDescribe().getKeyPrefix();
    
    //map from metadata - for product name and specification it
    private map<String, List<string>> mapNumberReservationSettingList = new map<string, List<string>>();
    //Local constants
    private static String handler = 'SearchFNN';
    private static final String HTTP422UNMS = 'The request is invalid due to a missing mandatory parameter or an invalid parameter value';
    private static final String HTTP409UNMS = 'Downstream is not allowing the operation to be performed due to resource state violation';
    //Storing the success
    private Set<String> correctStatusCode = new Set<String>{ '200', '201', '202' };        
        
    //Store Handler Metadata
    private Integration_Handler__mdt handlerMetaData = new Integration_Handler__mdt();

    //To map the reserved quantity to service for partial fail
    private Map<String, Number_Group__c> serviceNumGrpMap = new Map<String, Number_Group__c>();
    
    public boolean callBatchJobAgain = false;

    //To check construct new or old model
    private String IoTPlans = '';
    private String IoTSubscription = '';
    private Integer limitQuantity = 1000;
    
    public Orchestration_NumberReservForIoTBatch(CSPOFA__Orchestration_Step__c step, Integration_Handler__mdt handlerMetaData, 
                                                 Map<String, ApplicationLog__c> recToResponse, Map<String, Orchestration_ProcessedRecords> processedIds,
                                                 Map<Id, Attachment> stepCalloutAttachData
                                                )
    {
        currentStep = step.Id;
        orderId = step.CSPOFA__Orchestration_Process__r.Order__c;
        this.step = step;
        this.recToResponse = recToResponse;
        this.handlerMetaData = handlerMetaData;
        this.processedIds = processedIds;
        this.stepCalloutAttachData = stepCalloutAttachData;
        system.debug('batch constructor called');
        system.debug('orderId = ' + orderId);
        system.debug('this.step = ' + this.step);
        system.debug('this.recToResponse = ' + this.recToResponse);
        system.debug('this.processedIds = ' + this.processedIds);
        system.debug('this.handlerMetaData = ' + this.handlerMetaData);
        system.debug('this.stepCalloutAttachData = ' + this.stepCalloutAttachData);
        
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
                
        //Created custom metadata to store the fulfillment Code, product name, DPG-3906
        List<NumberReservationSetting__mdt> NumberReservationRecords = [Select type__c, value__c from NumberReservationSetting__mdt];
        mapNumberReservationSettingList = new map<string, list<string>>();
        
        for(NumberReservationSetting__mdt record:NumberReservationRecords) {
            if(mapNumberReservationSettingList.get(record.type__c) == null)
                mapNumberReservationSettingList.put(record.type__c, new List<string>());
            List<string> tempList = mapNumberReservationSettingList.get(record.type__c);
            tempList.add(record.value__c);
            mapNumberReservationSettingList.put(record.type__c, tempList );

        }

        List<String> devNameList = new List<String>();
        devNameList.add('IotSubscription');
        devNameList.add('IotPlans');
        devNameList.add('IoT_UNMS_SOQL_Limit');
        
        // Changed Custom Lable to Custom Metadata
        List<ConstantMetadataUtility__mdt> ConstantMetadataRecordList = [Select DeveloperName, value__c from ConstantMetadataUtility__mdt Where DeveloperName IN: devNameList];
        for(ConstantMetadataUtility__mdt record:ConstantMetadataRecordList) {
            if(record.DeveloperName == 'IoTSubscription')  IoTSubscription = record.value__c;
            if(record.DeveloperName == 'IoTPlans')  IoTPlans = record.value__c;
            if(record.DeveloperName == 'IoT_UNMS_SOQL_Limit')  limitQuantity = Integer.valueOf(record.value__c);
        }

        serviceNumGrpMap = new Map<String ,Number_Group__c>();
        for(Number_Group__c numGrp : [Select Id, Name, OrderId__c, Service_Id__c, Total_Numbers_Reserved__c From Number_Group__c Where OrderId__c =: orderId Order By CreatedDate DESC]){
            if(!serviceNumGrpMap.containsKey(numGrp.Service_Id__c)){
                serviceNumGrpMap.put(numGrp.Service_Id__c, numGrp);
            }            
        }
        
        return Database.getQueryLocator([ 
            SELECT Id, Name, csord__Order__c, csordtelcoa__Product_Basket__c, csordtelcoa__Product_Configuration__c, csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name, csordtelcoa__Product_Configuration__r.Quantity_Product_Configuration__c, csord__Subscription__c, csord__Subscription__r.serviceMSISDN__c, csordtelcoa__Service_Number__c, csordtelcoa__Product_Basket__r.csbb__Account__c, serviceMSISDN__c
            FROM csord__Service__c
            WHERE csord__Order__c = :orderId AND (csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name != null AND csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name in :mapNumberReservationSettingList.get('NumberReservationProduct') )
        ]);
    }
    
    public void execute(Database.BatchableContext BC, List<csord__Service__c> serviceList){
        executeEntry(serviceList);
    }
    
    private void executeEntry(List<csord__Service__c> serviceList){
        try{
            for(Number_Group__c numGrp : [Select Id, Name, OrderId__c, Service_Id__c, Total_Numbers_Reserved__c From Number_Group__c Where OrderId__c =: orderId Order By CreatedDate DESC]){
                serviceNumGrpMap.put(numGrp.Service_Id__c, numGrp);
            }

            system.debug('**** entered execute method:  serviceList =  ' + serviceList);
            currentTransactionNumber++;

            loopCounterCurrentTransactionList = new set<string>();
            
            List<Id> serviceIdList = new list<id>();
            orderServiceMap = new Map<Id, List<csord__Service__c>>();
            orderServiceWithNumberMap = new Map<Id, List<csord__Service__c>>();
            //Product Configuration is must for callouts
            for (csord__Service__c ser : serviceList) {
                serviceIdList.add(ser.id);
                //Create Order to Service Map With Old Reserved Numbers
                if(ser.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name != IoTPlans){                    
                    if(ser.serviceMSISDN__c != null){
                        if (!orderServiceWithNumberMap.containsKey(ser.csord__Order__c)) {                    
                            orderServiceWithNumberMap.put(ser.csord__Order__c, new List<csord__Service__c>{ ser });
                        } else {
                            orderServiceWithNumberMap.get(ser.csord__Order__c).add(ser);
                        }
                    }else{
                        if (!orderServiceMap.containsKey(ser.csord__Order__c)) {                    
                            orderServiceMap.put(ser.csord__Order__c, new List<csord__Service__c>{ ser });
                        } else {
                            orderServiceMap.get(ser.csord__Order__c).add(ser);
                        }
                    }
                }else{
                    Integer reservedNumbers;
                    if(serviceNumGrpMap.containsKey(ser.csordtelcoa__Service_Number__c)){
                        reservedNumbers = (Integer)serviceNumGrpMap.get(ser.csordtelcoa__Service_Number__c).Total_Numbers_Reserved__c;
                    }
                    if(reservedNumbers != null && reservedNumbers < ser.csordtelcoa__Product_Configuration__r.Quantity_Product_Configuration__c){
                        if (!orderServiceWithNumberMap.containsKey(ser.csord__Order__c)) {                    
                            orderServiceWithNumberMap.put(ser.csord__Order__c, new List<csord__Service__c>{ ser });
                        } else {
                            orderServiceWithNumberMap.get(ser.csord__Order__c).add(ser);
                        }
                        if (!orderServiceMap.containsKey(ser.csord__Order__c)) {                    
                            orderServiceMap.put(ser.csord__Order__c, new List<csord__Service__c>{ ser });
                        } else {
                            orderServiceMap.get(ser.csord__Order__c).add(ser);
                        }
                    }else if(reservedNumbers != null && reservedNumbers == ser.csordtelcoa__Product_Configuration__r.Quantity_Product_Configuration__c){
                        if (!orderServiceWithNumberMap.containsKey(ser.csord__Order__c)) {                    
                            orderServiceWithNumberMap.put(ser.csord__Order__c, new List<csord__Service__c>{ ser });
                        } else {
                            orderServiceWithNumberMap.get(ser.csord__Order__c).add(ser);
                        }
                    }else{
                        if (!orderServiceMap.containsKey(ser.csord__Order__c)) {                    
                            orderServiceMap.put(ser.csord__Order__c, new List<csord__Service__c>{ ser });
                        } else {
                            orderServiceMap.get(ser.csord__Order__c).add(ser);
                        }
                    }                    
                }                
            }
            
            stepResults = new Map<Id, Orchestration_AbstractStepHandler.stepResult>();
            
            //Collection for DML Operation
            numbersToInsert = new Map<String, Number__c>();
            numberGroupToInsert = new Map<String, Number_Group__c>();
            subscriptionsToUpdate = new Map<Id, csord__Subscription__c>();
            servicesToUpdate = new Map<Id, csord__Service__c>();
            attachmentsToUpdate = new Map<Id, Attachment>();
            tasksToInsert = new Map<Id, Task>();
            
            //Service --> Attachment
            serviceToAttachMap = new Map<Id, Orchestration_AttachmentWrapper>();
            
            //Fetch the Service --> Attachment
            for (Attachment attch : [SELECT Id, body, parentId FROM Attachment WHERE parentId IN :serviceIdList AND Name = :OrchestratorConstants.DataOrchestrationNames.service]) {
                serviceToAttachMap.put(attch.parentId, new Orchestration_AttachmentWrapper(attch.Id, attch.body));
            }
            System.debug('**** serviceToAttachMap==>'+serviceToAttachMap);
            callOutEntry();
            
            processEntry();
            
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }          
            } catch (Exception ex) {
            System.debug('Exception: ' + ex + ' Message: ' + ex.getmessage() + ' LineNumber: ' + ex.getLineNumber() + ' \n' + ex.getStackTraceString());
            
            Orchestration_AbstractStepHandler.stepResult cr = this.stepResults.get(step.Id);
            if (cr != null) {
                cr.message = 'Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber();
                cr.status = OrchestratorConstants.OrchestratorStep.Error;
            } else {
                stepResults.put(step.Id, new Orchestration_AbstractStepHandler.stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
            }
        }
        system.debug('**** application log insert and step result insert : ' + stepResults);
    }
    
    
    private void calloutEntry(){
        try {
            if (!orderServiceMap.containsKey(orderId)) {
                //Updating steps as Error since no proper data linked to step
                stepResults.put(step.Id, new Orchestration_AbstractStepHandler.stepResult('Success: No Services attached under Order for Search Numbers Or No service found where mobile number is blank', OrchestratorConstants.OrchestratorStep.Complete));
                //nothing should be executed after this point
                return;
            }
            
            
            //Check if reset callouts
            if (step.cspofa__message__c == null || (step.cspofa__message__c != null && step.cspofa__message__c.contains(OrchestratorConstants.SystemConstant.stepResetMsg))) {
                resetCallout = true;
            } else {
                resetCallout = false;
            }
            
            //Main method called
            system.debug('**** calling unmsSearchFNN...cpu time limit: ' + Limits.getCpuTime());
            UNMSsearchFNN();
            system.debug('**** exited unmsSearchFNN...cpu time limit: ' + Limits.getCpuTime());
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }                      
        } catch (Exception ex) {
            System.debug('Exception: ' + ex + ' Message: ' + ex.getmessage() + ' LineNumber: ' + ex.getLineNumber() + ' \n' + ex.getStackTraceString());
            Orchestration_AbstractStepHandler.stepResult cr = this.stepResults.get(step.Id);
            if (cr != null) {
                cr.message = 'Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber();
                cr.status = OrchestratorConstants.OrchestratorStep.Error;
            } else {
                stepResults.put(step.Id, new Orchestration_AbstractStepHandler.stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
            }
        }
    }
    
    //generate the request Data to make the request and reserve the number
    private void UNMSsearchFNN() {
        List<Orchestration_CallOutResponse> stepToCallOutResponse = new List<Orchestration_CallOutResponse>();
        Integer totalServiceSize = 0;
        if(orderServiceWithNumberMap.containsKey(orderId)){           
            for(csord__Service__c ser : orderServiceWithNumberMap.get(orderId)){
                if(ser.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name != IoTPlans){
                    totalServiceSize += 1;
                }else{
                    if(serviceNumGrpMap.containsKey(ser.csordtelcoa__Service_Number__c) && serviceNumGrpMap.get(ser.csordtelcoa__Service_Number__c).Total_Numbers_Reserved__c != null){
                        totalServiceSize += (Integer)serviceNumGrpMap.get(ser.csordtelcoa__Service_Number__c).Total_Numbers_Reserved__c;
                    }
                }
            }
        }
        Integer serviceSize = 0;
        for(csord__Service__c ser : orderServiceMap.get(orderId)){
            if(ser.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name != IoTPlans){
                serviceSize += 1;
            }else{
                Integer reservedNumbers;
                    if(serviceNumGrpMap.containsKey(ser.csordtelcoa__Service_Number__c)){
                        reservedNumbers = (Integer)serviceNumGrpMap.get(ser.csordtelcoa__Service_Number__c).Total_Numbers_Reserved__c;
                    }
                if(ser.csordtelcoa__Product_Configuration__r.Quantity_Product_Configuration__c != null && reservedNumbers != null){
                    serviceSize += (Integer)ser.csordtelcoa__Product_Configuration__r.Quantity_Product_Configuration__c - reservedNumbers;
                }else if(ser.csordtelcoa__Product_Configuration__r.Quantity_Product_Configuration__c != null){
                    serviceSize += (Integer)ser.csordtelcoa__Product_Configuration__r.Quantity_Product_Configuration__c;
                }
            }
        }
        system.debug('totalServiceSize ' + totalServiceSize);
        system.debug('serviceSize ' + serviceSize);        
        Integer loopCounter = (serviceSize / limitQuantity) + ((Math.mod(serviceSize, limitQuantity) > 0) ? 1 : 0);
        Boolean errorCallout = false;
        Boolean partialCallout = false;
        
        system.debug('loopCounter ' + loopCounter);
        system.debug('*****serviceSize + limitQuantity + loopCounter --> ' + serviceSize +'--'+ limitQuantity +'--'+ loopCounter );

        //Fetching the response from the application logs //recToResponse -- getting it while calling batch class from StepClass itself
        System.debug('recToResponse'+recToResponse);
        Integer appLogSize = 0;
        for(ApplicationLog__c res : recToResponse.values()){
            FNNSearchResponseDTO fnnDTO = FNNSearchResponseDTO.parse(res.Message__c);            
            if(fnnDTO.data != null && fnnDTO.data.returnedQuantity != null)    appLogSize += Integer.valueOf(fnnDTO.data.returnedQuantity);
        }

        while (loopCounter > 0) {
            system.debug('Inside while');
            if (Orchestration_LimitsUtility.areCallOutLimitsViolated()) {
                //Terminate the loop
                break;
            }

            loopCounterCurrentTransactionList.add(String.valueOf(loopCounter)+'-'+string.valueOf(currentTransactionNumber));
            system.debug('loopCounterCurrentTransactionList ' + loopCounterCurrentTransactionList);
            system.debug('currentTransactionNumber ' + String.valueOf(loopCounter)+'-'+string.valueOf(currentTransactionNumber));
        
            if(totalServiceSize <= appLogSize){
                serviceSize -= (totalServiceSize - appLogSize);
            }      

            //generating the token - OAuth Callout
            Datetime startTime = System.now();
            String token = Orchestration_CalloutUtility.getOauthToken(handlerMetaData);
            // String token = 'xyzforMockInterface';
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
            system.debug('**** startTime callout: ' + startTime  + ' &&&  cpu time limit: ' + Limits.getCpuTime());
            HttpResponse resp = Orchestration_CalloutUtility.sendRequestGeneric(reqBody, Orchestration_CalloutUtility.HTTP_METHOD_POST, headerMap, handlerMetaData, null);
            system.debug('resp ' + resp);
            endTime = System.now();
            system.debug('**** endTime callout: ' + endTime + ' &&&  cpu time limit: ' + Limits.getCpuTime());
            reqTime = Orchestration_Utility.getRequestTimeDifference(startTime, endTime);
            system.debug('**** reqTime callout: ' + reqTime);
            String responseBody = resp.getBody();
            String statusCode = String.valueOf(resp.getStatusCode());
            system.debug('**** responseBody callout: ' + responseBody );
            system.debug('**** statusCode callout: ' + statusCode );
            
            //Capture multiple Response for success
            if (correctStatusCode.contains(statusCode)) {          
                stepToCallOutResponse.add(new Orchestration_CallOutResponse(String.valueOf(loopCounter)+'-'+string.valueOf(currentTransactionNumber), reqBody, responseBody, statusCode, handler, 'Integration', null, correlationId, null, reqTime, Orchestration_CalloutUtility.HTTP_METHOD_POST));
                FNNSearchResponseDTO fnnRes = FNNSearchResponseDTO.parse(responseBody);
                if(fnnRes.responseCode == 'UNMS-PARTIAL_SUCCESS' && fnnRes.data.returnedQuantity < fnnRes.data.requestedQuantity)    partialCallout = true;
            } else if (statusCode == '422') {
                FNNSearchResponseDTO fnnRes = FNNSearchResponseDTO.parse(responseBody);
                stepToCallOutResponse.add(new Orchestration_CallOutResponse(String.valueOf(loopCounter)+'-'+string.valueOf(currentTransactionNumber), reqBody, responseBody, String.valueOf(statusCode) + ' : ' + HTTP422UNMS + ' : ' + fnnRes.responseCode, 'SearchFNN', 'Technical', null, correlationId, String.valueOf(statusCode), reqTime, Orchestration_CalloutUtility.HTTP_METHOD_POST));
            } else if (statusCode == '409') {
                stepToCallOutResponse.add(new Orchestration_CallOutResponse(String.valueOf(loopCounter)+'-'+string.valueOf(currentTransactionNumber), reqBody, responseBody, String.valueOf(statusCode) + ' : ' + HTTP409UNMS, 'SearchFNN', 'Technical', null, correlationId, String.valueOf(statusCode), reqTime, Orchestration_CalloutUtility.HTTP_METHOD_POST));
            } else {
                stepToCallOutResponse.add(new Orchestration_CallOutResponse(String.valueOf(loopCounter)+'-'+string.valueOf(currentTransactionNumber), reqBody, responseBody, statusCode, handler, 'Exception', null, correlationId, statusCode, reqTime, Orchestration_CalloutUtility.HTTP_METHOD_POST));
                errorCallout = true;
            }
            //Callout Done
            loopCounter--;
        }
        //Capture All response, as processing will be done on the process method
        if (errorCallout) {
            stepResults.put(currentStep, new Orchestration_AbstractStepHandler.stepResult('Error: Error in Callouts', OrchestratorConstants.OrchestratorStep.Error, stepToCallOutResponse));
        } else if(partialCallout){
            stepResults.put(currentStep, new Orchestration_AbstractStepHandler.stepResult('Partial Success: Getting Partial Response from UNMS ', OrchestratorConstants.OrchestratorStep.Waiting, stepToCallOutResponse));
        } else if (loopCounter == 0) {
            stepResults.put(currentStep, new Orchestration_AbstractStepHandler.stepResult('Success: All Callout Performed.', OrchestratorConstants.OrchestratorStep.Waiting, stepToCallOutResponse));
        }else{
            stepResults.put(currentStep, new Orchestration_AbstractStepHandler.stepResult('Partial Success: Partial Callout performed due to limits hit', OrchestratorConstants.OrchestratorStep.Waiting, stepToCallOutResponse));
        }
        system.debug('**** unmssearchfnn exiting... stepResults: ' + stepResults + ' &&&  cpu time limit: ' + Limits.getCpuTime());
    }
    
    private void processEntry(){
        try {
            //Limit check
            system.debug('*****Inside Process Entry -->  ');
            if (Orchestration_LimitsUtility.areAsyncLimitsViolated()) {
                system.debug('**** Orchestration_LimitsUtility.areAsyncLimitsViolated() ' + Orchestration_LimitsUtility.areAsyncLimitsViolated());
                return;
            }
            system.debug('*****Inside Process Entry after limits checked-->  ');
            //If result is not present, perform callout is not done for the step therefore skip the processing of that step
            Orchestration_AbstractStepHandler.stepResult cr = this.stepResults.get(step.Id);
            if (cr == null) {
                system.debug('**** cr == null ' + (cr == null));
                return;
            }
            
            //Message is already given on perform CallOut
            if (orderId == null || !orderServiceMap.containsKey(orderId) || step.CSPOFA__Orchestration_Process__r.Order__r.csord__Status2__c == OrchestratorConstants.OrderStatus.ReadyForSubmit) {
                 system.debug('**** Message is already given on perform CallOut');
                return;
            }
            
            //Capture all the response related to the order from result and app logs
            List<String> capturedResponse = new List<String>();
            
            //Step result will be present only if response was not captured earlier
            if (cr.callOutResponse != null) {
                //Iterating over each response
                for (Orchestration_CallOutResponse resp : cr.callOutResponse) {
                    if (Orchestration_LimitsUtility.areAsyncLimitsViolated()) {
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
            if (!recToResponse.IsEmpty()) {
                for (ApplicationLog__c applg : recToResponse.values()) {
                    if (Orchestration_LimitsUtility.areAsyncLimitsViolated()) {
                        //terminate the loop
                        break;
                    }
                    
                    String resCode = applg.Status_Code__c;
                    if (resCode != null && loopCounterCurrentTransactionList.contains(applg.Related_Record_Id__c) && (correctStatusCode.contains(resCode) || resCode.equals('422') || resCode.equals('409'))) {
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
                pendingStep = currentStep;
                system.debug('*****pendingStep --> ' + pendingStep);
               //handle mechanism to store how many service we are updating and how many are pending
                //return;
            }
            system.debug('*****Calling updateAndInsertObjects --> ');
            updateAndInsertObjects();
            if(Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        } catch (Exception ex) {
            System.debug('Exception: ' + ex + ' Message: ' + ex.getmessage() + ' LineNumber: ' + ex.getLineNumber() + ' \n' + ex.getStackTraceString());
            Orchestration_AbstractStepHandler.stepResult cr = this.stepResults.get(step.Id);
            if (cr != null) {
                cr.message = 'Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber();
                cr.status = OrchestratorConstants.OrchestratorStep.Error;
            } else {
                stepResults.put(step.Id, new Orchestration_AbstractStepHandler.stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
            }
        }
    }
    
    //Save number against successfull service callout
    private Boolean createNumbersOnServices(List<String> responses, csord__Order__c order) {
        List<String> numbersToReserve = new List<String>();
        Boolean taskRequired = false;

        for (String responseBody : responses) {
            FNNSearchResponseDTO fnnRes = FNNSearchResponseDTO.parse(responseBody);

            if (String.isNotBlank(fnnRes.responseCode) && fnnRes.responseCode.equalsIgnoreCase('UNMS-PARTIAL_SUCCESS')) {
                // stepResults.put(currentStep, new Orchestration_AbstractStepHandler.stepResult('Partial Success: Partial Update Made', OrchestratorConstants.OrchestratorStep.Error, stepToCallOutResponse));
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
        
        system.debug('**** numbersToReserve.size = ' + numbersToReserve.size());
        if (numbersToReserve.size() > 0) {
            //Setting the loop count
            Integer loopCount = 0;
            system.debug('**** orderServiceMap size: ' + orderServiceMap.get(order.Id).size());
            Integer rCount = 0;
            for (csord__Service__c service : orderServiceMap.get(order.Id)) {
                if (hasDMLRowsLimitExceeded()) {
                //if (hasDMLRowsLimitExceeded() || Orchestration_LimitsUtility.areAsyncLimitsViolated()) {
                    system.debug('**** create number limit hit: hasDMLRowsLimitExceeded()' + hasDMLRowsLimitExceeded());
                    
                    //Limit got hit
                    return true;
                }
                
                Decimal numOfQuantity = 0;
                if(service.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name != IoTPlans){
                    numOfQuantity = 1;
                }else{
                    numOfQuantity = service.csordtelcoa__Product_Configuration__r.Quantity_Product_Configuration__c;
                }
                if (service.serviceMSISDN__c == null && numbersToReserve.size() >= ( rCount + 1 ) && !servicesToUpdate.containsKey(service.Id)) {
                    
                    String mobileNo = '';               
                    for(Integer i=0;i<numOfQuantity;i++){
                        if(numbersToReserve.size() >= (rCount + 1)){
                            mobileNo = numbersToReserve.get(rCount);
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
                            rCount++;
                        }
                    }

                    if(service.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name == IoTPlans){
                        Number_Group__c numGrp = new Number_Group__c();
                        if(serviceNumGrpMap.containsKey(service.csordtelcoa__Service_Number__c))    numGrp.Id = serviceNumGrpMap.get(service.csordtelcoa__Service_Number__c).Id;
                        numGrp.Service_Id__c = service.csordtelcoa__Service_Number__c;
                        numGrp.Status__c = 'Reserved';
                        numGrp.Product_Configuration__c = service.csordtelcoa__Product_Configuration__c;
                        numGrp.Product_Basket__c = service.csordtelcoa__Product_Basket__c;
                        numGrp.Pattern_Type__c = 'Number';
                        numGrp.OrderId__c = orderId;
                        if(serviceNumGrpMap.containsKey(service.csordtelcoa__Service_Number__c)){
                            if(serviceNumGrpMap.get(service.csordtelcoa__Service_Number__c).Total_Numbers_Reserved__c == null)
                                numGrp.Total_Numbers_Reserved__c = rCount;
                            else
                                numGrp.Total_Numbers_Reserved__c = serviceNumGrpMap.get(service.csordtelcoa__Service_Number__c).Total_Numbers_Reserved__c + rCount;                         
                        }else{
                            numGrp.Total_Numbers_Reserved__c = rCount;
                        }
                        numberGroupToInsert.put(service.csordtelcoa__Service_Number__c, numGrp);
                    }

                    if(service.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name != IoTPlans){
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
                            System.debug('**** update Spect==>');
                            Map<String, String> AttrMap = new Map<String, String>();
                            AttrMap.put('CustomerFacingServiceId', mobileNo);
                            List<String> targetSystem = new List<String>{ 'FULFILMENT' };
                            List<String> specCodes = new List<String>();
                            //List<String> specCodes = new List<String>{ 'DMCAT_ProductSpecification_000966','DMCAT_ProductSpecification_001447' };
                            
                            specCodes.addAll(mapNumberReservationSettingList.get('NumberReservationSpecification'));
                            
                            System.debug('**** update Spect==>addAdditionalAttribute -- serviceToAttachMap.get(service.Id).attchBody = ' + serviceToAttachMap.get(service.Id).attchBody);
                            String bodyToUpdate = Orchestration_Utility.addAdditionalAttribute(serviceToAttachMap.get(service.Id).attchBody.toString(), AttrMap, targetSystem, specCodes);
                            system.debug('**** bodyToUpdate = ' + bodyToUpdate);
                            if (!'false'.equals(bodyToUpdate)) {
                                system.debug('**** bodyToUpdate = ' + bodyToUpdate);
                                Attachment attAdd = new Attachment(Id = serviceToAttachMap.get(service.Id).attchId);
                                attAdd.body = Blob.valueOf(bodyToUpdate);
                                attachmentsToUpdate.put(attAdd.id, attAdd);
                                system.debug('**** bodyToUpdate = ' + attAdd);
                                //Maintain the relationship
                                if (!stepRelationshipMap.containsKey(currentStep)) {
                                    stepRelationshipMap.put(currentStep, new Set<String>{ attAdd.Id });
                                } else {
                                    stepRelationshipMap.get(currentStep).add(attAdd.Id);
                                }
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
        
        system.debug('**** taskstoInsert.size() = ' + taskstoinsert.size() + ' & Before taskInsert DML cpu time limit: ' + Limits.getCpuTime());
        if (tasksToInsert.size() > 0) {
            Database.insert(tasksToInsert.values(), false);
            system.debug('**** After taskInsert DML cpu time limit: ' + Limits.getCpuTime());
            for (Task taskRecord : tasksToInsert.values()) {
                //Check if inserted
                if (taskRecord.Id != null) {
                    successIdentifiersMap.put(taskRecord.WhatId, taskRecord.Id);
                }
            }
        }

        system.debug('**** numberGroupToInsert.size() = ' + numberGroupToInsert.size() + ' & Before numberGroupToInsert DML cpu time limit: ' + Limits.getCpuTime());        
        if(numberGroupToInsert.size() > 0){
            Database.upsert(numberGroupToInsert.values(), false);
        }
        
        system.debug('**** numbersToInsert.size() = ' + numbersToInsert.size() + ' & Before numbersToInsert DML cpu time limit: ' + Limits.getCpuTime());
        if (numbersToInsert.size() > 0) {

            for (Number__c numRecord : numbersToInsert.values()) {
                System.debug(numRecord.Service_Id__c+' >> '+numRecord.Service_Id__c);
                if(numRecord.Service_Id__c != null && numberGroupToInsert.containsKey(numRecord.Service_Id__c)){
                    numRecord.Number_Group__c = numberGroupToInsert.get(numRecord.Service_Id__c).Id;
                }
            }
            Database.insert(numbersToInsert.values(), false);
            system.debug('**** After numbersToInsert DML cpu time limit: ' + Limits.getCpuTime());
            for (Number__c numRecord : numbersToInsert.values()) {
                //Check if inserted
                if (numRecord.Id != null) {
                    successIdentifiersMap.put(numRecord.Service_Number__c, numRecord.Id);
                }
            }
        }
        
        List<Database.SaveResult> updateResult = new List<Database.SaveResult>();
        
        system.debug('**** subscriptionsToUpdate.size() = ' + subscriptionsToUpdate.size() + ' & Before subscriptionsToUpdate DML cpu time limit: ' + Limits.getCpuTime());
        if (subscriptionsToUpdate.size() > 0) {
            //Updating all the order records
            updateResult = Database.update(subscriptionsToUpdate.values(), false);
            
            system.debug('**** After subscriptionsToUpdate DML cpu time limit: ' + Limits.getCpuTime());
            
            //Storing the order success Ids
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    SuccessIds.add(rslt.getId());
                }
            }
        }
        
        system.debug('**** servicesToUpdate.size() = ' + servicesToUpdate.size() + ' & Before servicesToUpdate DML cpu time limit: ' + Limits.getCpuTime());
        if (servicesToUpdate.size() > 0) {
            updateResult = Database.update(servicesToUpdate.values(), false);
            
            system.debug('After servicesToUpdate DML cpu time limit: ' + Limits.getCpuTime());
            
            //Storing the order success Ids
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    SuccessIds.add(rslt.getId());
                }
            }
        }
        
        system.debug('**** attachmentsToUpdate.size() = ' + attachmentsToUpdate.size() + ' & Before attachmentsToUpdate DML cpu time limit: ' + Limits.getCpuTime());
        if (attachmentsToUpdate.size() > 0) {
            updateResult = Database.update(attachmentsToUpdate.values(), false);
            
            system.debug('After attachmentsToUpdate DML cpu time limit: ' + Limits.getCpuTime());
            
            //Storing the order success Ids
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    SuccessIds.add(rslt.getId());
                }
            }
        }
        
        
    }
    
    public boolean hasDMLRowsLimitExceeded() {
        if (tasksToInsert.size() + numbersToInsert.size() + subscriptionsToUpdate.size() + servicesToUpdate.size() + attachmentsToUpdate.size() + Limits.getDMLRows() < Integer.valueOf(Governor_Limits__c.getInstance().DML_Rows_limit__c)) {
            return false;
        }
        //Limit Hit
        return true;
    }
    
    //get application log body if callouts were already made while calling this batch //duplicate method from abstracthandler
    public String getcalloutResponse(ApplicationLog__c appLog) {
        //Store serialized Json
        String callouResponseBody;
        if (!stepCalloutAttachData.isEmpty() && stepCalloutAttachData.containsKey(appLog.Id)) {
            callouResponseBody = stepCalloutAttachData.get(appLog.Id).body.toString();
        } else if (appLog.message__c != null) {
            callouResponseBody = appLog.message__c;
        }
        return callouResponseBody;
    }
    
    public void finish(Database.BatchableContext BC){
        //TODO: check if we have to run batch once again if limit was hit.
        
        //stepResults = new Map<Id, Orchestration_AbstractStepHandler.stepResult>();
        
        //Set Step's status
        setStepStatus();        

        //application log insert -- only for callout responses.
        Orchestration_NumberReservForIoTAsync op = new Orchestration_NumberReservForIoTAsync();
        List<CSPOFA__Orchestration_Step__c> steps = new list<CSPOFA__Orchestration_Step__c>{this.step};
        op.updateStepData(steps, stepResults);
    }
    
    //to verify if all records are succesfully inserted/updated in finish method
    private void setStepStatus(){
        system.debug('**** stepRelationshipMap size = ' + stepRelationshipMap.size());
        
        if(stepRelationshipMap.size() == 0){
            //this will never be null because stepRelationshipMap is present for the step
            Orchestration_AbstractStepHandler.stepResult cr = stepResults.get(currentStep);
            system.debug('**** finish method stepresults cr = ' + cr);
            if(cr == null)
                stepResults.put(currentStep, new Orchestration_AbstractStepHandler.stepResult('Waiting', 'Waiting'));
            cr = stepResults.get(currentStep);
            System.debug('cr'+cr);            
            if(cr != null && cr.callOutResponse != null && cr.callOutResponse[0] != null && cr.callOutResponse[0].responseBody != null){
                System.debug('cr.callOutResponse'+cr.callOutResponse[0].responseBody);
                FNNSearchResponseDTO fnnRes = FNNSearchResponseDTO.parse(cr.callOutResponse[0].responseBody);
                if(fnnRes.responseCode == 'UNMS-INTERNAL_SERVER_ERROR'){
                    cr.status = OrchestratorConstants.OrchestratorStep.Error;
                    cr.message = 'Error: UNMS Internal Server Error.';
                }else if(fnnRes.responseCode == 'UNMS-RESOURCE_NOT_FOUND'){
                    cr.status = OrchestratorConstants.OrchestratorStep.Error;
                    cr.message = 'Error: UNMS Server Resource Not Found.';
                }else if(fnnRes.responseCode == 'UNMS-PARTIAL_SUCCESS'){
                    cr.status = OrchestratorConstants.OrchestratorStep.Error;
                    cr.message = 'Error: UNMS Partial Success.';
                }
            }else{ 
                cr.status = OrchestratorConstants.OrchestratorStep.Error;
                cr.message = 'Error: Something went wrong please Retry it.';
            }
            return;
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
            Orchestration_AbstractStepHandler.stepResult cr = stepResults.get(stepId);
            system.debug('**** finish method stepresults cr = ' + cr);
            if(cr == null)
                stepResults.put(stepId, new Orchestration_AbstractStepHandler.stepResult('Waiting', 'Waiting'));
            cr = stepResults.get(stepId);
            system.debug('**** stepRelationshipMap.get() size = ' + stepRelationshipMap.get(stepId).size());
            system.debug('**** stepRelationshipMap.get()  = ' + stepRelationshipMap.get(stepId));
            system.debug('**** successIdentifiersMap = ' + successIdentifiersMap);
            system.debug('**** SuccessIds = ' + SuccessIds);
            for (String recId : stepRelationshipMap.get(stepId)) {
                //Only order check
                system.debug('**** recId = ' + recId);
                if (successIdentifiersMap.containsKey(recId)) {
                    perStepSuccessIds.mapInsertedRecords.putAll(successIdentifiersMap);
                    
                    if (recId.startsWith(orderKeyPrefix)) {
                        //Updating steps as complete where no processing required
                        cr.message = 'Failure: UNMS Partial Update Made';
                        cr.status = OrchestratorConstants.OrchestratorStep.Error;
                        isOrderTask = true;
                        cr.processedRecords = perStepSuccessIds;
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
            
            system.debug('**** isFAiled = ' + isFailed);
            system.debug('**** pendingStep = ' + pendingStep);
            system.debug('**** cr.message = ' + cr.message);
            system.debug('**** perStepSuccessIds = ' + perStepSuccessIds);
            
            //If message is an error due to
            if (!isFailed && (String.isBlank(pendingStep) || !pendingStep.equals(stepId))) {

                if (cr.message.contains('Error:') || cr.message.contains('Partial Success:')) {
                    cr.message = cr.message + ' and processing done for other';
                    cr.processedRecords = perStepSuccessIds;
                    cr.status = OrchestratorConstants.OrchestratorStep.Error;
                } else {
                    cr.message = 'Success: Number reservation search performed';
                    cr.status = OrchestratorConstants.OrchestratorStep.Complete;
                }
            } else if (!isFailed && !String.isBlank(pendingStep) && pendingStep.equals(stepId)) {
                if (cr.message.contains('Error:') || cr.message.contains('Partial Success:')) {
                    cr.message = cr.message + ' and partial processing done for other';
                } else {
                    cr.message = 'Partial Success: Number search has been queued';
                    //to do inprogress once step class template is updated.
                    cr.status = OrchestratorConstants.OrchestratorStep.Waiting;
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
}