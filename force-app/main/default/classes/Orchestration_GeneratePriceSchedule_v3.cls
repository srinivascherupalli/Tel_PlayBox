/**================================================================
* Appirio, Inc
* Name: Orchestration_GeneratePriceSchedule_v3
* Description:
* Created Date: 
* Created By: 
* TODO : Add Partial Processing
*      : Donto Proceed if 3rd Condition
*      : check for Unique Id
* ===================================================================*/
global with sharing class Orchestration_GeneratePriceSchedule_v3 extends Orchestration_AbstractStepHandler {
    // Data to be updated Lists
    private Map<Id, Charge_Line_Item__c> cliTobeUpdatedMap = new Map<Id, Charge_Line_Item__c>();
    private Map<String, Price_Schedule_Line_Item__c> psliTobeInserted = new Map<String, Price_Schedule_Line_Item__c>();
    private Map<String, Tier_Line_Item__c> tliTobeInserted = new Map<String, Tier_Line_Item__c>();
    private Map<String, Price_Schedule_Discount_Association__c> psdaTobeInserted = new Map<String, Price_Schedule_Discount_Association__c>();
    private Map<String, Set<String>> stepRelationshipMap = new Map<String, Set<String>>();
    private Map<Id, Id> subsToStepMap = new Map<Id, Id>();
    private Map<Id, List<Price_Schedule_Discount_Association__c>> psliPSDAtoBeInsertedMap = new Map<Id, List<Price_Schedule_Discount_Association__c>>();
    private Map<Id, List<Tier_Line_Item__c>> psliTLItoBeInsertedMap = new Map<Id, List<Tier_Line_Item__c>>();
    private Id incompleteStepId;
    
    private Map<Id, Orchestration_ProcessedRecords> processedIds = new Map<Id, Orchestration_ProcessedRecords>();
    
    private Set<Id> inProgressStepList = new Set<Id>();
    
    //Stpre the Data Map
    private Map<Id, Set<Id>> subChargeLineItemMap = new Map<Id, Set<Id>>();
    private Map<Id, Charge_Line_Item__c> cliMap = new Map<Id, Charge_Line_Item__c>();
    private Map<Id, List<PricingMSResponseObject__c>> cliToPriceResponseMap = new Map<Id, List<PricingMSResponseObject__c>>();
    private Map<Id, Set<Id>> cliModifySet = new Map<id, Set<Id>>(); /* changed to private */
    Set<Id> cliNewSet = new Set<Id>();
    private Map<Id, Set<Id>> subsServiceMap = new Map<Id, Set<Id>>();
    private Set<Id> servicesSet = new Set<Id>();
    
    private Map<Id, Blob> serviceAttachmentMap = new Map<Id, Blob>();
    private Map<Id, String> technicalObjMap = new Map<Id, String>();
    private String payloadStr='';
    //Integer seq=0;
    Map<String, Object> payloadMap = new Map<String,Object>();
    List<Coms_Subscription_PE__e> subscriptionEvents = new List<Coms_Subscription_PE__e>(); 
    
    public override List<SObject> process(List<SObject> steps) {
        if (Orchestration_LimitsUtility.areLimitsViolated()) {
            system.debug('stopping execution as limit breached.....');
            return null;
        }
        List<CSPOFA__Orchestration_Step__c> stepList = new List<CSPOFA__Orchestration_Step__c>();
        List<Object>technicalObjList=new List<Object>();
        List<Charge_Line_Item__c> chargeObjList = new List<Charge_Line_Item__c>();
        
        try {
            stepList = (List<CSPOFA__Orchestration_Step__c>) getStepList(steps);
            
            
            System.debug(cliMap + '===>cliMap');
            
            System.debug('===> Data Collected');
            for (CSPOFA__Orchestration_Step__c step : stepList) {
                try {
                    if (step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c == null) {
                        //Updating steps as Error since no proper data linked to step
                        stepResults.put(step.Id, new stepResult('Error: Step do not have an associated subscription', OrchestratorConstants.OrchestratorStep.Error));
                        //Check the next step
                        continue;
                    }
                    
                    if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        //terminate the loop
                        break;
                    }
                    
                    
                    Orchestration_ProcessedRecords processedRecordIds = getProcessedRecords(step);
                    
                    if (processedRecordIds != null) {
                        processedIds.put(step.Id, processedRecordIds);
                    }
                    //payloadMap.put('SubscriptionIds',subscriptionIds);
                    payloadMap.put('SubscriptionIds',step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);
                    payloadMap.put('StepId',step.Id);
                    payloadMap.put('Current',step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);
                    payloadMap.put('ProcessName',step.CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name);
                    payloadMap.put('ProcessedRecords',processedIds);
                    payloadStr=(String)JSON.serialize(payloadMap);
                    system.debug('payloadStr '+payloadStr);
                    //Coms_Subscription_PE__e subsEvt = new Coms_Subscription_PE__e(Sequence__c=step.id, payload__c=str, Orchestration_Process_Name__c=step.CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name,Step_Number__c=step.CSPOFA__Step_Order__c);
                    Coms_Subscription_PE__e subsEvt = new Coms_Subscription_PE__e(Sequence__c=String.valueof(Orchestration_PlatformCacheUtility.seq), payload__c=payloadStr, Orchestration_Process_Name__c=step.CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name,Step_Number__c=step.CSPOFA__Step_Order__c);
                    subscriptionEvents.add(subsEvt);
                    
                    System.debug('===> Step Processing');
                    
                   Orchestration_PlatformCacheUtility.seq++;
                    stepResults.put(step.Id, new stepResult('Waiting: Called Service Publisher', OrchestratorConstants.OrchestratorStep.Waiting));
                   
                } catch (Exception ex) {
                    System.debug('Exception: ' + ex + ' Message: ' + ex.getmessage() + ' LineNumber: ' + ex.getLineNumber() + ' \n' + ex.getStackTraceString());
                    
                    stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
                }
            }
        } catch (Exception ex) {
            System.debug('Exception: ' + ex + ' Message: ' + ex.getmessage() + ' LineNumber: ' + ex.getLineNumber() + ' \n' + ex.getStackTraceString());
            for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) steps) {
                stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
            }
        }
        
       
        publishSubsProcessingEvent(subscriptionEvents);
        return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
    }
    
    
    
    //override getStepList to fetch necessry field from steps
    public override List<sObject> getStepList(List<sObject> steps) {
        Set<String> stepIds = new Set<String>();
        
        List<CSPOFA__Orchestration_Step__c> stepList = [
            SELECT
            ID,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.Id,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Replaced_Subscription__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Account__c,
            JSON__c,
            CSPOFA__Message__c, 
            CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name,
            CSPOFA__Step_Order__c
            FROM CSPOFA__Orchestration_Step__c
            WHERE Id IN :steps
        ];
        
        for (CSPOFA__Orchestration_Step__c step : stepList) {
            if (step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c != null) {
                subscriptionIds.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);
                subsToStepMap.put(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c, step.Id);
            }
            
            if (String.IsNotBlank(step.JSON__c) && step.JSON__c.equals(OrchestratorConstants.SystemConstant.AttachmentMsg)) {
                stepIds.add(step.Id);
            }
        }
        
        //Check if attachments is required
        if (stepIds.size() > 0) {
            getAttachmentList(stepIds);
        }
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