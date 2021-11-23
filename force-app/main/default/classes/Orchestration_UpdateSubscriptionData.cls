/**================================================================
* Name: Orchestration_UpdateSubscriptionData
* Description: Class to update subscription details from platformcache to database
* ================================================================*/
global with sharing class Orchestration_UpdateSubscriptionData extends Orchestration_AbstractStepHandler {
    private List<CSPOFA__Orchestration_Step__c> stepList= new List<CSPOFA__Orchestration_Step__c>();
    private final List<String> orchestrationProcessesList = new List<String>{
        OrchestratorConstants.OrchesTemplateName.svcFulfillmentProvision,
            OrchestratorConstants.OrchesTemplateName.svcFulfillmentActivation,
            OrchestratorConstants.OrchesTemplateName.autoCompleteSubsTemplate,
            OrchestratorConstants.OrchesTemplateName.ceaseSubsTemplate
            };
    private list<CSPOFA__Orchestration_Process__c> subOrchesProcess =  new list<CSPOFA__Orchestration_Process__c>();
    private Map<Id, Orchestration_ProcessedRecords> processedIds = new Map<Id, Orchestration_ProcessedRecords>();
   // Map<String, CSPOFA__Orchestration_Process_Template__c> orchesTemplates = CS_OrchUtils.getorchesTemplates();
   private String payloadStr='';
    Integer seq=0;
    private List<Coms_Subscription_PE__e> subscriptionEvents = new List<Coms_Subscription_PE__e>(); 
    Map<String, Object> payloadMap = new Map<String,Object>();
    private String IncompleteStepId = '';
    private Map<Id, Id> stepRelationship = new Map<Id, Id>();
    public override List<SObject> process(List<SObject> data){
        if (Orchestration_LimitsUtility.areLimitsViolated()) {
            system.debug('stopping execution as limit breached.....');
            return null;
        }
        stepList= (List<CSPOFA__Orchestration_Step__c>) getStepList(data);
        getRelatedSubscriptionIds(stepList);
        try{
            system.debug('subscriptionIds '+subscriptionIds);
             
             Map<String, CSPOFA__Orchestration_Process_Template__c> orchesTemplates = Orchestration_Utility.getOrchestrationTemplates(orchestrationProcessesList);
            //List<csord__Subscription__c>subDBList = [SELECT Id,LastModifiedDate from csord__Subscription__c where Id IN :subscriptionIds];
            //List<csord__Subscription__c> subList = Coms_PlatformCacheUtil.getListofSubscriptionFromCache(subscriptionIds);
            //List<Charge_Line_Item__c> chrgList = Coms_PlatormCacheUtil.getListOfChargeLineItem(subscriptionIds);
            //getPriceScheduleLineItem
            //system.debug('DBtimestamp '+subDBList);
          //  system.debug('PCTimestamp '+subList);
            for(CSPOFA__Orchestration_Step__c step : stepList) {
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
                    
                    payloadMap.put('StepId',step.Id);
                    payloadMap.put('subscriptionId',step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);
                    payloadMap.put('OrchName',step.CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name);
                    payloadMap.put('ProcessedRecords',processedIds);
                    payloadStr=(String)JSON.serialize(payloadMap);
                Coms_Subscription_PE__e subsEvt = new Coms_Subscription_PE__e(Sequence__c=String.valueof(Orchestration_PlatformCacheUtility.seq), payload__c=payloadStr, Orchestration_Process_Name__c=step.CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name,Step_Number__c=step.CSPOFA__Step_Order__c);
                    subscriptionEvents.add(subsEvt);
                    
                    System.debug('===> Step Processing');
                    
                   Orchestration_PlatformCacheUtility.seq++;
                //seq++;
                    stepResults.put(step.Id, new stepResult('Waiting: Called Service Publisher', OrchestratorConstants.OrchestratorStep.Waiting));
                 
               /* for (csord__Subscription__c subDB: subDBList){
                    for(csord__Subscription__c sub: subList){
                        
                        //if(srv.IsUpdated == true){
                        if (subDB.LastModifiedDate <= sub.Platform_Cache_Timestamp__c){
                            sObjectsToUpdate.put(sub.Id,sub);
                            stepRelationship.put(sub.Id, step.Id);
                        }
                        else{
                            //call orchestration process again
                            String subfulfilmentprocess =step.CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name; //'Subscription Fulfillment Process_Provision';
                            CSPOFA__Orchestration_Process__c subscriptionOrches = new CSPOFA__Orchestration_Process__c() ;
                            subscriptionOrches = createOrchestrationProcess(orchesTemplates.get(subfulfilmentprocess).id,sub.Id);
                            //subOrchesProcess.add(subscriptionOrches); 
                            //sObjectsToInsert.add(subscriptionOrches);
                            stepRelationship.put(sub.Id, step.Id);
                        } 
                        
                        //}
                    }   
                }*/
                  
            }
            
        }
        catch(exception e){
            system.debug('Failed in Update Subscription Data step'+e);
            for (CSPOFA__Orchestration_Step__c step : stepList) {
                stepResults.put(step.Id, new stepResult('Error: ' + e.getMessage() + ' on line ' + e.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, e.getStackTraceString()));
            }
        }
      /*  if(sObjectsToInsert.size()>0)
            //insert subOrchesProcess;
            insertOrchestrationProcess();
        else if(sObjectsToUpdate.size()>0)
            updateObjectsFromPlatformCache();
        else
            for (CSPOFA__Orchestration_Step__c step : stepList) {
                stepResults.put(step.Id, new stepResult('Success: No Records to process', OrchestratorConstants.OrchestratorStep.Complete));
            }*/
        publishSubsProcessingEvent(subscriptionEvents);
        return processStepResults((List<CSPOFA__Orchestration_Step__c>) stepList, stepResults);
    }
    public override List<sObject> getStepList(List<sObject> steps) {
        List<sObject> stepList = [SELECT ID, Name,CSPOFA__Orchestration_Process__c, CSPOFA__Step_Order__c, CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name, CSPOFA__Status__c, CSPOFA__Completed_Date__c, JSON__c, CSPOFA__Message__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__c,CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.cssdm__solution_association__c,CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Product_Configuration__r.ConfigurationType1__c FROM CSPOFA__Orchestration_Step__c WHERE Id IN :steps];        
        return stepList;
    }
    //Method to re-instantiate the orchestration process to get the latest data from DB
   /* public void insertOrchestrationProcess(){
        if(sObjectsToInsert.size() > 0){
            Database.SaveResult[] insertRslt = Database.insert(sObjectsToInsert, false);
            for (Database.SaveResult rslt : insertRslt) {                
                if (rslt.isSuccess()) {
                    system.debug('Success: Created Orchestration process'+rslt.getId());
                    stepResults.put(stepRelationship.get(rslt.getId()),           
                                    new stepResult('Success: Created Orchestration process', OrchestratorConstants.OrchestratorStep.Complete)
                                   );
                } else {
                    system.debug('Error: Unable to create orcestration process' +rslt.getId());
                    //record updation failed there related step updated
                    stepResults.put(stepRelationship.get(rslt.getId()), new stepResult('Error: Unable to create orchestration process', OrchestratorConstants.OrchestratorStep.Error));
                }
            }
        }
    }
    public void updateObjectsFromPlatformCache() {
        List<Id> subsSuccessIds = new List<Id>();
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        
        if (sObjectsToUpdate.size() > 0) {           
            Database.SaveResult[] updateResult = Database.update(sObjectsToUpdate.values(), false);            
            for (Database.SaveResult rslt : updateResult) {                
                if (rslt.isSuccess()) {
                    stepResults.put(stepRelationship.get(rslt.getId()),           
                                    new stepResult('Success: Subscription records updated', OrchestratorConstants.OrchestratorStep.Complete)
                                   );
                } else {
                    //record updation failed there related step updated
                    stepResults.put(stepRelationship.get(rslt.getId()), new stepResult('Error: Unable to update records to database', OrchestratorConstants.OrchestratorStep.Error));
                }
            }
        }       
    }
    public static CSPOFA__Orchestration_Process__c createOrchestrationProcess(Id templateid,Id SubscriptionId){        
        CSPOFA__Orchestration_Process__c orches;
        if(templateid!=null){
            orches  = new CSPOFA__Orchestration_Process__c();            
            orches.CSPOFA__State__c = 'Active';            
            if(SubscriptionId!=null){
               orches.csordtelcoa__Subscription__c = SubscriptionId;}            
            orches.CSPOFA__Orchestration_Process_Template__c =templateid;
        }        
        return orches;
    }*/
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