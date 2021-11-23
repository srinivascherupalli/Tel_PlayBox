/**================================================================
* Appirio, Inc
* Name: Orchestration_OrdertoBillHandler
* Description: Class to push subscription on Billing System
* Created Date: June 04, 2020
* Created By: Gaurang Maheshwari
EDGE-175339   Prajakta      16/09/2020
EDGE-179374   Prajakta      30/09/2020
EDGE-186947   Gunjan        1/12/2020
EDGE-195803   Gunjan        21/12/2020 Code Merge Issue on QA2
EDGE-187676   Akanksha      15/12/2020

==================================================================*/
global with sharing class Orchestration_OrdertoBillHandler extends Orchestration_AbstractStepHandler {
    //public static Map<Id, Id> mapStepToSubscription = new Map<Id, Id>();
    private Map<Id, stepResult> stepResults = new Map<Id, stepResult>();
    private Boolean exceptionInCallOut = false;
    private Map<Id, csord__Subscription__c> subscriptionsToUpdate = new Map<Id, csord__Subscription__c>();
    public static String handlerName = 'PostSubscriptionHandler';
    private Map<Id, Charge_Line_Item__c> chargeLineItemToUpdate = new Map<Id, Charge_Line_Item__c>();
    private Map<Id, Discount_Line_Item__c> discountLineItemToUpdate = new Map<Id, Discount_Line_Item__c>();
    private Map<Id, Price_Schedule_Line_Item__c> priceSchedLineItemToUpdate = new Map<Id, Price_Schedule_Line_Item__c>();
    private Map<Id, Tier_Line_Item__c> tierLineItemToUpdate = new Map<Id, Tier_Line_Item__c>();
    private Map<Id, Number__c> numbersToUpdate = new Map<Id, Number__c>();
    private Map<Id, csord__Subscription__c> mapSubscritpion = new Map<Id, csord__Subscription__c>();
    //private Set<String> subscriptionNumbers = new Set<String>();
    //private Map<Id, List<csord__Subscription__c>> mapOrderToSubs = new Map<Id, List<csord__Subscription__c>>();
    private String pendingStep = '';
    private List<CSPOFA__Orchestration_Step__c> stepList;
    private BillingUtility billUtility;
    public static Integration_Handler__mdt handlerMetaData;
    public List<Id> subscriptionIdList = new List<Id>();
    private Map<Id, Billing_Account__c> billingAccountsToUpdate = new Map<Id, Billing_Account__c>();
    //public List<Billing_Account__c> billingAccountList = new List<Billing_Account__c>();
    private Map<String, Orchestration_ProcessedRecords> processedIds = new Map<String, Orchestration_ProcessedRecords>();
    private Map<Id, List<String>> stepRelationshipMap = new Map<Id, List<String>>();
    //private Map<Id, ApplicationLog__c> mapSubIdToApplicationLog = new Map<Id, ApplicationLog__c>();
    private boolean allStepSkipped = true;
    public String oAuthToken = 'MLhlJPHAFdP38Z1CsAnEI1EDts6h';
    public override Boolean performCallouts(List<SObject> steps) {
        if (Orchestration_LimitsUtility.areCallOutLimitsViolated()) {
            //Cannot process the records
            return false;
        }
        try {
            system.debug('Heap Check====>>>'+limits.getHeapSize());
            stepList = (List<CSPOFA__Orchestration_Step__c>) getStepList(steps);
            //system.debug('Check performCallouts step size====>>>'+stepList.size());
            List<Feature_Flag__mdt> ftList = [SELECT Id, DeveloperName, IsActive__c, Permission_Set_Name__c, Profile_Name__c FROM Feature_Flag__mdt WHERE DeveloperName = 'PostSubProductAPIV2'];
            if (ftList.size() == 0 || !ftList[0].IsActive__c) {
                for (CSPOFA__Orchestration_Step__c step : stepList) {
                    stepResults.put(step.Id, new stepResult('Feature Flag is Off for PostSubProductAPIV2', OrchestratorConstants.OrchestratorStep.Error));
                }
                exceptionInCallOut = true;
                return true;
            }
            Map<Id, csord__Subscription__c> mapSubscription = new Map<Id, csord__Subscription__c>();
            system.debug('Heap Check before initializing====>>>'+limits.getHeapSize());
            if(subscriptionIdList.size() > 0) {
                billUtility = new BillingUtility(subscriptionIdList, true, false, handlerName);
            }
            system.debug('Heap Check after initializing====>>>'+limits.getHeapSize());
            //Fetching the Metadata
            handlerMetaData = getIntegrationHandlerSettings(handlerName);
            /** PROCESSING DATA */
            for (CSPOFA__Orchestration_Step__c step : stepList) {
                try{
                    if (step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c == null) {
                        //Updating steps as Error since no proper data linked to step
                        stepResults.put(step.Id, new stepResult('Error: Step is not related to a subscription', OrchestratorConstants.OrchestratorStep.Error));
                        //Check the next step
                        continue;
                    }
                    if (Orchestration_LimitsUtility.areCallOutLimitsViolated()) {
                        //Cannot process the records
                        break;
                    }
                    //system.debug('mapStepIdToRecordApplicationLog==>>'+mapStepIdToRecordApplicationLog);
                    if(!mapStepIdToRecordApplicationLog.isEmpty() && mapStepIdToRecordApplicationLog.containskey(step.Id)){
                        Map<Id, ApplicationLog__c> tempMap = mapStepIdToRecordApplicationLog.get(step.Id);
                        ApplicationLog__c appLog = tempMap.get(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);
                        //system.debug('appLog====>>>'+appLog);
                        if(appLog.Status_Code__c == '202' || (appLog.Status_Code__c != '202' && (step.cspofa__message__c != null && !step.cspofa__message__c.contains('Step has been reset') ))){
                            continue;
                        }
                    }
                    Id subscriptionId = step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c;
                    //generating the token - OAuth Callout
                    system.debug('before oAuth====>>>');
                    Datetime startTime = System.now();
                    //String oAuthToken;
                    //OAuth Failure
                    allStepSkipped = false;
                    if(!Test.isRunningTest()) {
                        oAuthToken = Orchestration_CalloutUtility.getOauthToken(handlerMetaData);
                    }
                    Datetime endTime = System.now();
                    Long reqTime = Orchestration_Utility.getRequestTimeDifference(startTime, endTime);
                    if (String.isBlank(oAuthToken)) {
                        stepResults.put(step.Id, new stepResult('Error: OAuth Failure', OrchestratorConstants.OrchestratorStep.Error, new List<Orchestration_CallOutResponse>{ new Orchestration_CallOutResponse(null, null, null, null, 'OAuthLogin', 'Exception', null, null, null, reqTime, Orchestration_CalloutUtility.HTTP_METHOD_GET) }));
                        //move to next step
                        continue;
                    }
                    Orchestration_calloutResponse calloutResponse = billUtility.processBillingCallout(subscriptionId, oAuthToken, handlerMetaData);
                    updateStepResultWithResponse(calloutResponse, step.Id);
                }catch(Exception ex) {
                    stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
                }
            }
        } catch(Exception ex) {
            exceptionInCallOut = true;
            for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) steps) {
                stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
            }
        }
        return (!this.stepResults.isEmpty() || allStepSkipped);
    }
    private void updateStepResultWithResponse(Orchestration_calloutResponse calloutResponse, Id stepId){
        if(calloutResponse == null){
            stepResults.put(stepId, new stepResult('Callout Failed: no response recieved from the interface', OrchestratorConstants.OrchestratorStep.Error));
        } else if(calloutResponse.statusCode=='202'){
            stepResults.put(stepId, new stepResult('Success: Callout Performed', OrchestratorConstants.OrchestratorStep.InProgress, new List<Orchestration_calloutResponse>{calloutResponse}));
        } else if(calloutResponse.statusCode=='404'){
            stepResults.put(stepId, new stepResult('HTTP Error: 404 recieved from the billing interface', OrchestratorConstants.OrchestratorStep.InProgress, new List<Orchestration_calloutResponse>{calloutResponse}));
        } else {
            stepResults.put(stepId, new stepResult('HTTP Error: '+calloutResponse.statusCode+' recieved from the billing interface', OrchestratorConstants.OrchestratorStep.InProgress, new List<Orchestration_calloutResponse>{calloutResponse}));
        }
    }
    /**
* @description   :  This method is inherited from AbstractStepHandlers to do further processing
* @param         : List<Sobject>
* @return        :  List<Sobject>
**/
    public override List<SObject> process(List<SObject> steps) {
        if (Orchestration_LimitsUtility.areLimitsViolated() || exceptionInCallOut) {
            //Cannot process the records
            return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
        }
        //Set<Id> serviceIds = new Set<Id>();
        //Set<String> subsNumbers = new Set<String>();
        try{
            system.debug('enteres process methid====>>>');
            //system.debug('enteres process methid step====>>>'+stepList);
            for (CSPOFA__Orchestration_Step__c step : stepList) {
                //Limit check
                try{
                    if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        //terminate the loop
                        break;
                    }
                    String subsId = step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c;
                    if(String.isNotBlank(subsId)) {
                        //Only order will be present in Json
                        Orchestration_ProcessedRecords processedRecordIds = getProcessedRecords(step);
                        if (processedRecordIds != null) {
                            processedIds.put(step.Id, processedRecordIds);
                        }
                        stepResult cr;
                        ApplicationLog__c appLog;
                        if(stepResults != null && stepResults.containsKey(step.Id)){
                            cr = stepResults.get(step.Id);
                        }
                        //In failed in performCallout Method, dont do anything for this step and continue to next step
                        if(cr != null && cr.status == 'Error'){
                            continue;
                        }
                        String responseBody = '';
                        if(cr != null && !cr.callOutResponse.isEmpty()){
                            responseBody = cr.callOutResponse[0].responseBody;
                        } else {
                            if(!mapStepIdToRecordApplicationLog.isEmpty() && mapStepIdToRecordApplicationLog.containskey(step.Id)){
                                Map<Id, ApplicationLog__c> tempMap = mapStepIdToRecordApplicationLog.get(step.Id);
                                appLog = tempMap.get(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);
                                if(appLog.Status_Code__c == '202' || (appLog.Status_Code__c != '202' && step.cspofa__message__c != null && !step.cspofa__message__c.contains('Step has been reset'))){
                                    responseBody = getCalloutResponse(appLog);
                                }
                            }
                        }
                        if(responseBody == ''){
                            if(cr!=null){
                                cr.message = 'Callout Failed: no response recieved from the interface';
                                cr.status = OrchestratorConstants.OrchestratorStep.Error;
                            }else{
                                stepResults.put(step.Id, new stepResult('Callout Failed: no response recieved from the interface', OrchestratorConstants.OrchestratorStep.Error));
                            }
                            continue;
                        }
                        csord__Subscription__c subscriptionToUpdate = billUtility.subscriptionMap.get(subsId);
                        Billing_Account__c billingAccountToUpdate = subscriptionToUpdate.Billing_Account__r;
                        //system.debug('billingAccountToUpdate===='+billingAccountToUpdate);
                        if((cr != null && cr.callOutResponse[0].statusCode != '202') || (appLog !=null && appLog.Status_Code__c != '202' )){
                            //subsctiion status failed
                            //billing account status error
                            String statusCode = '';
                            if(cr != null){
                                statusCode = cr.callOutResponse[0].statusCode;
                            }else{
                                statusCode = appLog.Status_Code__c;
                            }
                            if(performCalloutProcessOperations(step.Id ,subscriptionToUpdate, billingAccountToUpdate, 'Billing Pending', 'Error', false,  statusCode, null)){
                                pendingStep = step.Id;
                                //break;
                            }
                        } else {
                            if(performCalloutProcessOperations(step.Id ,subscriptionToUpdate, billingAccountToUpdate, 'Bill Readiness In Progress', 'Provisioned', true, '202', responseBody)){
                                pendingStep = step.Id;
                                //break;
                            }
                        }
                    }
                    //system.debug('after all Process===>>>'+pendingStep+'==>>'+stepRelationshipMap);
                    if (pendingStep != '') {
                        break;
                    } else if (stepRelationshipMap.isEmpty() || !stepRelationshipMap.containsKey(step.Id)) {
                        system.debug('====>>>> entered complete');
                        if(stepResults!= null && stepResults.containsKey(step.Id)){
                            if(stepResults.get(step.Id).message!=null && stepResults.get(step.Id).message.contains('HTTP Error')){
                                //stepResults.get(stepId).message = 'Success: Records processed';
                                stepResults.get(step.Id).status = OrchestratorConstants.OrchestratorStep.Error;
                            }
                        }else{
                            stepResults.put(step.Id, new stepResult('Success : No update required as no data found to update', OrchestratorConstants.OrchestratorStep.Complete));
                        }
                    }
                }catch(Exception ex){
                    if(stepResults !=null && stepResults.containsKey(step.Id)){
                        stepResults.get(step.Id).message = 'Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber();stepResults.get(step.Id).status = OrchestratorConstants.OrchestratorStep.Error;stepResults.get(step.Id).stackTrace = ex.getStackTraceString();
                    }else{
                        stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
                    }
                }
            }
        }catch(Exception ex){
            for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) steps) {
                if(stepResults !=null && stepResults.containsKey(step.Id)){
                    stepResults.get(step.Id).message = 'Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber();
                    stepResults.get(step.Id).status = OrchestratorConstants.OrchestratorStep.Error;stepResults.get(step.Id).stackTrace = ex.getStackTraceString();
                }else{
                    stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
                }
            }
        }
        updateObjects();
        return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
    }
    public boolean performCalloutProcessOperations(Id stepId, csord__Subscription__c subscriptionToUpdate, Billing_Account__c billingAccountToUpdate, String SubStatus, String billingStatus, Boolean isSuccessOperation, String statusCode, String responseBody){
        //System.debug('Response Body ::'+ responseBody + ' statusCode :::'+ statusCode + ' SubStatus :::'+ SubStatus);
        Set<Id> serviceIdsToFetchNew = new Set<Id>();
        Set<Id> baseOrderServiceID = new Set<Id>();
        BillingPostSubscriptionResponseDTO billingPostSubscriptionResponseJson;
        if(responseBody != null){
            billingPostSubscriptionResponseJson = BillingPostSubscriptionResponseDTO.parse(responseBody);
        }
      
        if(!hasDMLRowsLimitExceeded()){
            system.debug('subscriptionToUpdate.csord__Status__c'+subscriptionToUpdate.csord__Status__c);
            if(subscriptionToUpdate.csord__Status__c != SubStatus && subscriptionToUpdate.csord__Status__c!= 'Ready for Activation' && (subscriptionToUpdate.triggerBill_RTB__c==true || subscriptionToUpdate.toBeCancelled__c.equalsIgnoreCase('true'))){
                system.debug('Inside 1st if');
                subscriptionToUpdate.csord__Status__c = SubStatus;
                if(isSuccessOperation){
                    /*if(subscriptionToUpdate.csordtelcoa__Product_Configuration__r.ConfigurationType1__c != null){
                        if (subscriptionToUpdate.csordtelcoa__Product_Configuration__r.ConfigurationType1__c == 'SolutionComponent'){
                            subscriptionToUpdate.triggerBill_RTB__c = true;//added as part of EDGE-156196
                        }
                    }*/ //commented as part of solution suppression story
                    subscriptionToUpdate.eventId__c = billingPostSubscriptionResponseJson.eventId;
                    //subscriptionToUpdate.response_Status_Code__c = response.getStatusCode();
                }
                subscriptionToUpdate.response_Status_Code__c = statusCode != null ? Integer.valueOf(statusCode) : null;
                subscriptionsToUpdate.put(subscriptionToUpdate.Id, subscriptionToUpdate);
                if (!stepRelationshipMap.containsKey(stepId)) {
                    stepRelationshipMap.put(stepId, new List<String>{ subscriptionToUpdate.Id });
                } else {
                    stepRelationshipMap.get(stepId).add(subscriptionToUpdate.Id);
                }
            }
            // EDGE-187676 akanksha adding starts
            else if(subscriptionToUpdate.csord__Status__c == 'Ready for Activation')
            {
               
                subscriptionToUpdate.response_Status_Code__c = statusCode != null ? Integer.valueOf(statusCode) : null;
                if(isSuccessOperation){
          //commented as part of solution suppression story
                    /*if(subscriptionToUpdate.csordtelcoa__Product_Configuration__r.ConfigurationType1__c != null){
                        if (subscriptionToUpdate.csordtelcoa__Product_Configuration__r.ConfigurationType1__c == 'SolutionComponent'){
                            subscriptionToUpdate.csord__Status__c = 'Provisioned';
                            list<csord__Subscription__c> subsLst = new List<csord__Subscription__c>();
                            for(csord__Subscription__c subs: billUtility.solutionToSubsMap.get(subscriptionToUpdate.cssdm__solution_association__c))
                            {
                                if(subs.csordtelcoa__Product_Configuration__r.ConfigurationType1__c != 'SolutionComponent')
                                {
                                    subs.Trigger_RFA__c = true;subscriptionsToUpdate.put(subs.Id,subs);
                                }
                            }
                        }
                    }
                    else
                    {*///commented as part of solution suppression story
                        // individual subscription
                        subscriptionToUpdate.csord__Status__c = 'Provisioning In Progress';
                        updateNumberStatus(subscriptionToUpdate.csordtelcoa__Subscription_Number__c, 'Provisioning In Progress', StepId);
                       // subscriptionToUpdate.eventId__c = 'test';
                       // System.debug('Inside 325 55555');
                   // }
                    //subscriptionToUpdate.eventId__c = billingPostSubscriptionResponseJson.eventId;
                }
                subscriptionsToUpdate.put(subscriptionToUpdate.Id, subscriptionToUpdate);
                if (!stepRelationshipMap.containsKey(stepId)) {
                    stepRelationshipMap.put(stepId, new List<String>{ subscriptionToUpdate.Id });
                } else {
                    stepRelationshipMap.get(stepId).add(subscriptionToUpdate.Id);
                }
            }
            system.debug('subscriptionsToUpdate ---350'+subscriptionsToUpdate);
            // EDGE-187676 akanksha adding ends
        }
        else {
            return true;
        }
        //EDGE-186947 Record order submission date for all order scenarios including billing only change by Gunjan
        if(!hasDMLRowsLimitExceeded()){
            if(billingAccountToUpdate != null && billingAccountToUpdate.Status__c != billingStatus && billingStatus != 'Error' && (subscriptionToUpdate.csord__Status__c != 'Ready for Activation' || subscriptionToUpdate.csord__Status__c != 'Provisioning In Progress')){
                billingAccountToUpdate.Status__c = billingStatus;
                billingAccountToUpdate.isUpdated__c = true; //EDGE-170215 Kalashree. Fix for calling MS
                billingAccountsToUpdate.put(billingAccountToUpdate.Id, billingAccountToUpdate);
                if (!stepRelationshipMap.containsKey(stepId)) {
                    stepRelationshipMap.put(stepId, new List<String>{ billingAccountToUpdate.Id });
                } else {
                    stepRelationshipMap.get(stepId).add(billingAccountToUpdate.Id);
                }
                 //system.debug('billingAccountToUpdate ---350'+billingAccountToUpdate);
            }
        }else {return true;
        }
        if(isSuccessOperation){
            //numbersUpdate
            if(subscriptionToUpdate.csord__Status__c!= 'Ready for Activation' && subscriptionToUpdate.csord__Status__c == 'Bill Readiness In Progress' && (subscriptionToUpdate.triggerBill_RTB__c==true || subscriptionToUpdate.toBeCancelled__c.equalsIgnoreCase('true'))){
                if(updateNumberStatus(subscriptionToUpdate.csordtelcoa__Subscription_Number__c, 'Bill Readiness In Progress', StepId)){
                return true;
            }
            //}
            
            List<Id> serviceIdsForSubscription = billUtility.mapSubscriptionTolistServiceIds.get(subscriptionToUpdate.Id);
            for(id serviceId: serviceIdsForSubscription){
                csord__Service__c service = billUtility.serviceMap.get(serviceId);
                if (service.csordtelcoa__Replaced_Service__c == null) {
                    serviceIdsToFetchNew.add(service.Id);
                } else if (service.csordtelcoa__Replaced_Service__c != null && service.toBeCancelled__c.equalsIgnoreCase('false')) {
                    serviceIdsToFetchNew.add(service.Id);
                    baseOrderServiceID.add(service.csordtelcoa__Replaced_Service__c);
                }
            }
            //All cli, pli etc
            //Code added as part of EDGE-124711/EDGE-124029
            if (serviceIdsToFetchNew != null) {
                if(updateSchedule(stepId, serviceIdsToFetchNew, 'Ready to Active')){return true;
                }
            }
            if (baseOrderServiceID != null) {
                if(updateSchedule(stepId, baseOrderServiceID, 'Ready to Replaced')){return true;
                }
            }
            }
        }
        return false;
    }
    private boolean updateSchedule(String stepId, Set<Id> serviceIdsBaseOrder, String status) {
        for (Id serviceId : serviceIdsBaseOrder) {
            if(billUtility.mapServiceToCLIs != null && billUtility.mapServiceToCLIs.containsKey(serviceId)) {
                for (Charge_Line_Item__c cli : billUtility.mapServiceToCLIs.get(serviceId)) {
                    if (hasDMLRowsLimitExceeded()) {return true;
                    }
                    if(cli.status__c != status){
                        cli.status__c = status;
                        chargeLineItemToUpdate.put(cli.Id, cli);
                        if (!stepRelationshipMap.containsKey(stepId)) {
                            stepRelationshipMap.put(stepId, new List<String>{ cli.Id });
                        } else {
                            stepRelationshipMap.get(stepId).add(cli.Id);
                        }
                    }
                    if(billUtility.mapCLIsToDLIs != null && billUtility.mapCLIsToDLIs.containsKey(cli.Id)) {
                        for (Discount_Line_Item__c dli : billUtility.mapCLIsToDLIs.get(cli.Id)) {
                            if (hasDMLRowsLimitExceeded()) {
                                return true;
                            }
                            if(dli.status__c != status){
                                dli.status__c = status;
                                discountLineItemToUpdate.put(dli.Id, dli);
                                if (!stepRelationshipMap.containsKey(stepId)) {
                                    stepRelationshipMap.put(stepId, new List<String>{ dli.Id });
                                } else {
                                    stepRelationshipMap.get(stepId).add(dli.Id);
                                }
                            }
                        }
                    }
                    if(billUtility.mapCLIsToPSLIs != null && billUtility.mapCLIsToPSLIs.containsKey(cli.Id)) {
                        for (Price_Schedule_Line_Item__c pSLI : billUtility.mapCLIsToPSLIs.get(cli.Id)) {
                            if (hasDMLRowsLimitExceeded()) {
                                return true;
                            }
                            if(pSLI.status__c != status){
                                pSLI.status__c = status;
                                priceSchedLineItemToUpdate.put(pSLI.Id, pSLI);
                                if (!stepRelationshipMap.containsKey(stepId)) {
                                    stepRelationshipMap.put(stepId, new List<String>{ pSLI.Id });
                                } else {
                                    stepRelationshipMap.get(stepId).add(pSLI.Id);
                                }
                            }
                            if(billUtility.mapPSLIsToTLIs != null && billUtility.mapPSLIsToTLIs.containsKey(pSLI.Id)) {
                                for (Tier_Line_Item__c tLI : billUtility.mapPSLIsToTLIs.get(pSLI.Id)) {
                                    if (hasDMLRowsLimitExceeded()) {return true;
                                    }
                                    if(tLI.status__c != status){
                                        tLI.status__c = status;
                                        tierLineItemToUpdate.put(tLI.Id, tLI);
                                        if (!stepRelationshipMap.containsKey(stepId)) {
                                            stepRelationshipMap.put(stepId, new List<String>{ tLI.Id });
                                        } else {
                                            stepRelationshipMap.get(stepId).add(tLI.Id);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return false;
    }
    private boolean updateNumberStatus(String subscriptionNumber, String status, Id StepId) {
        Orchestration_ProcessedRecords processedRecordIds = processedIds.get(stepId);
        if(billUtility.mapSubsNumbers != null && billUtility.mapSubsNumbers.containskey(subscriptionNumber)){
            for (Number__c numb : billUtility.mapSubsNumbers.get(subscriptionNumber)) {
                if (hasDMLRowsLimitExceeded()) {
                    //isFailed = true;
                    return true;
                }
                System.debug('status ' + status);
                //EDGE-132208 - Added confitions to set the Number Status based on Previous Status and Notification Status.
                if(!(processedRecordIds !=null && processedRecordIds.numberIds!=null && processedRecordIds.numberIds.contains(numb.Id))){
                    if(numb.Status__c!='Active'){ // EDGE-175339 & EDGE-179374
                        if (numb.Status__c == 'RESERVED') {
                            numb.Status__c = status;
                        } else if (numb.Status__c == 'DISCONNECT PENDING') {
                            numb.Status__c = 'Disconnect in Progress';
                        } else if (numb.status__c == 'Disconnect In Progress') {
                            numb.Status__c = 'Disconnected';
                        } else if (numb.status__c == 'Provisioning In Progress') {
                            numb.Status__c = status;
                        } else if (numb.status__c == 'Provisioned') {
                            numb.Status__c = status;
                        } else {
                            numb.Status__c = status;
                        }
                        numbersToUpdate.put(numb.Id, numb);
                        if (!stepRelationshipMap.containsKey(stepId)) {
                            stepRelationshipMap.put(stepId, new List<String>{ numb.Id });
                        } else {
                            stepRelationshipMap.get(stepId).add(numb.Id);
                        }
                    }
                }
            }
        }
        system.debug('numbersToUpdate:'+numbersToUpdate);
        system.debug('stepRelationshipMap:'+stepRelationshipMap);
        return false;
    }
    public override void updateObjects() {
        //Success DML order Ids
        List<Id> successIds = new List<Id>();
        //List<Id> subscriptionSuccessIds = new List<Id>();
        //List<Id> billingAccSuccessIds = new List<Id>();
        //List<Id> cLISuccessIds = new List<Id>();
        //List<Id> dSLISuccessIds = new List<Id>();
        //List<Id> pSLISuccessIds = new List<Id>();
        //List<Id> tLISuccessIds = new List<Id>();
        List<Id> numbersSuccessIds = new List<Id>();
        //Updating all the subscription records
        //system.debug('subscriptionsToUpdate===>>>'+subscriptionsToUpdate);
        if (subscriptionsToUpdate.size() > 0) {
            List<Database.SaveResult> updateResult = Database.update(subscriptionsToUpdate.values(), false);
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    //subscriptionSuccessIds.add(rslt.getId());
                    successIds.add(rslt.getId());
                }
            }
        }
        //Updating all the order records
        //system.debug('billingAccountsToUpdate===>>>'+billingAccountsToUpdate);
        if (billingAccountsToUpdate.size() > 0) {
            List<Database.SaveResult> updateResult = Database.update(billingAccountsToUpdate.values(), false);
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    //billingAccSuccessIds.add(rslt.getId());
                    successIds.add(rslt.getId());
                }
            }
        }
        //Updating all the order records
        if (chargeLineItemToUpdate.size() > 0) {
            List<Database.SaveResult> updateResult = Database.update(chargeLineItemToUpdate.values(), false);
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    //cLISuccessIds.add(rslt.getId());
                    successIds.add(rslt.getId());
                }
            }
        }
        //Updating all the order records
        if (discountLineItemToUpdate.size() > 0) {
            List<Database.SaveResult> updateResult = Database.update(discountLineItemToUpdate.values(), false);
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    //dSLISuccessIds.add(rslt.getId());
                    successIds.add(rslt.getId());
                }
            }
        }
        //Updating all the order records
        if (priceSchedLineItemToUpdate.size() > 0) {
            List<Database.SaveResult> updateResult = Database.update(priceSchedLineItemToUpdate.values(), false);
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    //pSLISuccessIds.add(rslt.getId());
                    successIds.add(rslt.getId());
                }
            }
        }
        //Updating all the order records
        if (tierLineItemToUpdate.size() > 0) {
            List<Database.SaveResult> updateResult = Database.update(tierLineItemToUpdate.values(), false);
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    //tLISuccessIds.add(rslt.getId());
                    successIds.add(rslt.getId());
                }
            }
        }
        //Updating all the order records
        if (numbersToUpdate.size() > 0) {
            system.debug('inside if:');
            List<Database.SaveResult> updateResult = Database.update(numbersToUpdate.values(), false);
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    numbersSuccessIds.add(rslt.getId());
                    successIds.add(rslt.getId());
                }
            }
        }
        system.debug('numbersSuccessIds'+numbersSuccessIds);
        system.debug('successIds'+successIds);
        //Iteration over each step, processed Id check is not required
        for (Id stepId : stepRelationshipMap.keySet()) {
            //Object Type --> Ids
            Orchestration_ProcessedRecords perStepSuccessIds = new Orchestration_ProcessedRecords();
            //Initializing the orderids Set
            perStepSuccessIds.numberIds = new Set<String>();
            Boolean isFailed = false;
            for (Id recId : stepRelationshipMap.get(stepId)) {
                if(numbersSuccessIds.size()>0 && numbersSuccessIds.contains(recId)){
                    perStepSuccessIds.numberIds.add(recId);
                    system.debug('inside if568');
                }else if (successIds.size() > 0 && !successIds.contains(recId)){
                    //Failure
                    isFailed = true;
                    system.debug('isFailed571'+isFailed);
                }
            }
            String errorMessage = 'Error: Unable to process records';
            if (stepResults.containsKey(stepId)) {
                stepResult sr = stepResults.get(stepId);
                if (sr.status == OrchestratorConstants.OrchestratorStep.Error) {
                    isFailed = true;errorMessage = sr.message;
                    system.debug('isFailed579'+isFailed);
                    
                }
            }
            if (!isFailed && (String.isBlank(pendingStep) || !pendingStep.equals(stepId))) {
                if(stepResults!=null && stepResults.containsKey(stepId)){
                    stepResults.get(stepId).message = 'Success: Records processed';
                    stepResults.get(stepId).status = OrchestratorConstants.OrchestratorStep.Complete;
                }else{
                    stepResults.put(stepId, new stepResult('Success: Records processed', OrchestratorConstants.OrchestratorStep.Complete));
                }
                //move to next step
                continue;
            }
            //Adding the previous stored ids - error/partial processed case
            if (processedIds.containsKey(stepId) && processedIds.get(stepId).numberIds != null) {
                perStepSuccessIds.numberIds.addAll(processedIds.get(stepId).numberIds);
            }
            if (!isFailed && !String.isBlank(pendingStep) && pendingStep.equals(stepId)) {
                if(stepResults!=null && stepResults.containsKey(stepId)){
                    stepResults.get(stepId).message = 'Success: Partial records processed';                    stepResults.get(stepId).status = OrchestratorConstants.OrchestratorStep.InProgress;                    stepResults.get(stepId).processedRecords = perStepSuccessIds;
                }else{
                    stepResults.put(stepId, new stepResult('Success: Partial records processed', OrchestratorConstants.OrchestratorStep.InProgress, perStepSuccessIds));
                }
            } else {
                if(stepResults!=null && stepResults.containsKey(stepId)){
                    stepResults.get(stepId).message = errorMessage;                    stepResults.get(stepId).status = OrchestratorConstants.OrchestratorStep.Error;                    stepResults.get(stepId).processedRecords = perStepSuccessIds;
                }else{
                    stepResults.put(stepId, new stepResult(errorMessage, OrchestratorConstants.OrchestratorStep.Error, perStepSuccessIds));
                }
            }
        }
    }
    public override List<sObject> getStepList(List<sObject> steps) {
        Set<String> stepIds = new Set<String>();
        List<sObject> stepList = [
            SELECT
            ID,
            Name,
            CSPOFA__Orchestration_Process__c,
            CSPOFA__Status__c,
            CSPOFA__Completed_Date__c,
            JSON__c,
            CSPOFA__Message__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.cssdm__solution_association__r.Name,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.MarketableOffer__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.MarketableOffer__r.Auto_Expired_Entity__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Product_Configuration__r.ConfigurationType1__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Subscription_Number__c
            FROM CSPOFA__Orchestration_Step__c
            WHERE Id IN :steps
        ];
        for(CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>)stepList) {
            //system.debug('stepId===>>>'+step.Id+step.CSPOFA__Orchestration_Process__r);
            // system.debug('stepId===>>>'+step);
            //system.debug('stepId===>>>'+step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);
            if(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c != null) {
                subscriptionIdList.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);
            }
            stepIds.add(step.Id);
        }
        //TODO
        system.debug('before attachments===>>>');
        getResponseAndProcessIdAttachments(stepIds, handlerName);
        return stepList;
    }
    public override boolean hasDMLRowsLimitExceeded() {
        System.debug('Available Limit ::'+ Integer.valueOf(Governor_Limits__c.getInstance().DML_Rows_limit__c));
        System.debug('Total Limit :::'+ (chargeLineItemToUpdate.size() + discountLineItemToUpdate.size() + priceSchedLineItemToUpdate.size() + billingAccountsToUpdate.size() + tierLineItemToUpdate.size() + numbersToUpdate.size() + subscriptionsToUpdate.size() + Limits.getDMLRows()));
        if ((chargeLineItemToUpdate.size() + discountLineItemToUpdate.size() + priceSchedLineItemToUpdate.size() + billingAccountsToUpdate.size() + tierLineItemToUpdate.size() + numbersToUpdate.size() + subscriptionsToUpdate.size() + Limits.getDMLRows()) < Integer.valueOf(Governor_Limits__c.getInstance().DML_Rows_limit__c)) {
            system.debug('enterde false----==>>>');
            return false;
        }
        //Limit Hit
        return true;
    }
}