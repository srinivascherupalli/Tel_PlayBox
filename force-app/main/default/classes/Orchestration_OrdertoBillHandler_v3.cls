/**================================================================
* Name: Orchestration_OrdertoBillHandler_v3
* Description: Class to push subscription on Billing System
* Created Date: 
* Created By: 
==================================================================*/
global with sharing class Orchestration_OrdertoBillHandler_v3 extends Orchestration_AbstractStepHandler {
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
    public String payloadStr='';
    //Integer seq=0;
    Map<String,Object> payloadMap = new Map<String,Object>();
    List<Coms_Subscription_PE__e> subscriptionEvents = new List<Coms_Subscription_PE__e>(); 
    public override Boolean performCallouts(List<SObject> steps) {
        if (Orchestration_LimitsUtility.areCallOutLimitsViolated()) {
            //Cannot process the records
            return false;
        }
        try {
            system.debug('Heap Check====>>>'+limits.getHeapSize());
            stepList = (List<CSPOFA__Orchestration_Step__c>) getStepList(steps);
            system.debug('Check performCallouts step size====>>>'+stepList.size());
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
                        system.debug('appLog====>>>'+appLog);
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
                try{
                    if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        //terminate the loop
                        break;
                    }
                    String subsId = step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c;
                    //  payloadMap.put('StepId',step.Id);
                    // payloadMap.put('Current',subsId);
                    //   payloadMap.put('ProcessName',step.CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name);
                    
                    
                    if(String.isNotBlank(subsId)) {
                        //Only order will be present in Json
                        Orchestration_ProcessedRecords processedRecordIds = getProcessedRecords(step);
                        if (processedRecordIds != null) {
                            processedIds.put(step.Id, processedRecordIds);
                        }
                        payloadMap.put('StepId',step.Id);
                        payloadMap.put('Current',subsId);
                        payloadMap.put('subscriptionIds',subscriptionIdList);
                        payloadMap.put('ProcessName',step.CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name);
                        payloadMap.put('ProcessedIds',processedRecordIds);
                        payloadMap.put('StepResults',stepResults); //need to chk if we need to pass this?
                        
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
                        
                        String statusCode = '';
                        if((cr != null && cr.callOutResponse[0].statusCode != '202') || (appLog !=null && appLog.Status_Code__c != '202' )){
                            //subsctiion status failed
                            //billing account status error                           
                            if(cr != null){
                                statusCode = cr.callOutResponse[0].statusCode;
                            }else{
                                statusCode = appLog.Status_Code__c;
                            }
                            
                        }
                        payloadMap.put('CalloutStatus',statusCode);
                        payloadMap.put('ResponseBody',responseBody);
                        payloadStr=(String)JSON.serialize(payloadMap);
                        system.debug('payloadStr '+payloadStr);
                       // Coms_Subscription_PE__e subsEvt = new Coms_Subscription_PE__e(Sequence__c=step.id, payload__c=str, Orchestration_Process_Name__c=step.CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name,Step_Number__c=step.CSPOFA__Step_Order__c);
                        Coms_Subscription_PE__e subsEvt = new Coms_Subscription_PE__e(Sequence__c=String.valueOf(Orchestration_PlatformCacheUtility.seq), payload__c=payloadStr, Orchestration_Process_Name__c=step.CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name,Step_Number__c=step.CSPOFA__Step_Order__c);
                        subscriptionEvents.add(subsEvt);                           
                    } 
                    Orchestration_PlatformCacheUtility.seq++;
                    stepResults.put(step.Id, new stepResult('Waiting: Called Service Publisher', OrchestratorConstants.OrchestratorStep.Waiting));
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
        publishSubsProcessingEvent(subscriptionEvents);
        return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
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
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Subscription_Number__c, 
            CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name,
            CSPOFA__Step_Order__c
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
    
    public static void publishSubsProcessingEvent(List<Coms_Subscription_PE__e> Events){
        // Call method to publish events
        
        System.debug('Events ==> ' + Events );
        
        List<Database.SaveResult> results = EventBus.publish(Events);
        
        for(Database.SaveResult result: results){
            if (result.isSuccess()) {
                System.debug('Successfully published event ==> ' + result );
            } else {
                for(Database.Error err : result.getErrors()) {
                    System.debug('Error returned: ' +
                                 err.getStatusCode() +
                                 ' - ' +
                                 err.getMessage()); 
                }
            }
        }
    }
}