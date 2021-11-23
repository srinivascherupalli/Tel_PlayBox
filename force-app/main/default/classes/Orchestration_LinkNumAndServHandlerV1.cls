/**================================================================
 * Appirio, Inc
 * Name: Orchestration_LinkNumAndServOrchHandler
 * Description: Class to update SIMSerailNumber and IMSI in service spec
 * Created Date: July 16, 2020
 * Created By: Gaurang Maheshwari
 Prajakta       14/08/2020       EDGE-170096
 Prajakta       18/08/2020       EDGE-166432
 Prajakta       04/11/2020       EDGE-174930
 Prajakta       20/11/2020       EDGE-188748
 Vaibhav        03/12/2020       EDGE-192921
 Vaishali       08/12/2020       Sonar Fix -SOQL in For Loop
 Prajakta       25/01/2021      EDGE-195398 - refactoring of class
 Prajakta       04/02/2021      EDGE-194053
 Prajakta       24/02/2021      EDGE-152473
 Gnana      26/02/2020    EDGE-170545 - Modified the step to handle both inflight and normal orders 
 Mahima      23/03/2020      DPG-4545 - Suspend and Resume for AM Plan
 Pawan/Hitesh   20/05/2021      Partial Proccessing logic added
 Pawan/Hitesh   20/05/2021      INC000095943631 - AutoComplete flag resetting
 Vaibhav        08/06/2021      EDGE-222326 : Modified areLimitsViolated logic check to return SObject instead of NULL
 ==================================================================*/
 global with sharing class Orchestration_LinkNumAndServHandlerV1 extends Orchestration_AbstractStepHandler {
    private Map<Id, Orchestration_ProcessedRecords> processedIds = new Map<Id, Orchestration_ProcessedRecords>();
    String str='';
    Map<String, Object> payloadMap=new Map<String,Object>();

   /**************************************************************
       Name: process
       Parameters: List<SObject> steps
       Return Type: List<SObject>
       Description: Overriding the process method of ExecutionHandler interface
     *******************************************************************/
   public override List<SObject> process(List<SObject> steps) {
       if (Orchestration_LimitsUtility.areLimitsViolated()) {
           system.debug('stopping execution as limit breached.....');
           return null;
       }
       
       List<Coms_Step_PE__e> orderEvents = new List<Coms_Step_PE__e>(); 
       List<CSPOFA__Orchestration_Step__c> stepList = new List<CSPOFA__Orchestration_Step__c>();
       
       try{
           stepList = (List<CSPOFA__Orchestration_Step__c>) getStepList(steps);
           
           //TODO
           getRelatedOrderIds(stepList); //this gets the list of orderIds
           
                       
           /*Set<Id> serviceIds = new Set<Id>();
           for(csord__service__c serv :serviceList) {
                       serviceIds.add(serv.Id);
               }
           List <Object> attachmentList = (List<Object>) Coms_PlatformCacheUtil.getListofTechnicalObjectFromCache(serviceIds); // for attachments*/
           
           for (CSPOFA__Orchestration_Step__c step : stepList) {
               try {
                   //Limit check
                   if (Orchestration_LimitsUtility.areLimitsViolated()) {
                       //terminate the loop
                       break;
                   }
                   
                   Orchestration_ProcessedRecords processedRecordIds = getProcessedRecords(step);

                   /*if (processedRecordIds != null) {
                       processedIds.put(step.Id, processedRecordIds);
                   }*/
                   
                   
                   //payloadMap.put('orderIds',orderIds);
                   payloadMap.put('StepId',step.Id);
                   payloadMap.put('Current',step.CSPOFA__Orchestration_Process__r.Order__c);
                   payloadMap.put('ProcessName',step.CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name);
                   payloadMap.put('ProcessedRecords',processedRecordIds);
                   str=(String)JSON.serialize(payloadMap); 
                   system.debug('###payload: ' + str);
                   Coms_Step_PE__e orderEvt = new Coms_Step_PE__e(Sequence__c=String.valueOf(Orchestration_PlatformCacheUtility.seq), payload__c=str, Orchestration_Process_Name__c=step.CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name,Step_Number__c=step.CSPOFA__Step_Order__c);
                   orderEvents.add(orderEvt);
                   if (step.CSPOFA__Orchestration_Process__r.Order__c == null ) {
                       //Updating steps as Error since no proper data linked to step
                       stepResults.put(step.Id, new stepResult('Error: Step do not have an associated order', OrchestratorConstants.OrchestratorStep.Error));
                       //Check the next step
                       continue;
                   }
                   
                   if (Orchestration_LimitsUtility.areLimitsViolated()) {
                       //terminate the loop
                       break;
                   }
                   stepResults.put(step.Id, new stepResult('Waiting: Called Service Publisher', OrchestratorConstants.OrchestratorStep.Waiting));                    
               } catch (Exception ex) {
                   stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
               }
               Orchestration_PlatformCacheUtility.seq++;
           }
           
       } catch (Exception ex) {
           for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) steps) {
               stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error));
           }
       }
       
       publishOrderProcessingEvent(orderEvents);
       return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
   }
   
   
   //override getStepList to fetch necessry field from steps
   public override List<sObject> getStepList(List<sObject> steps) {
       List<CSPOFA__Orchestration_Step__c> stepList = [
           SELECT Id, Name, CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c, 
           CSPOFA__Orchestration_Process__r.Order__c,JSON__c,CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name, CSPOFA__Step_Order__c
           FROM CSPOFA__Orchestration_Step__c WHERE Id IN :steps];
       
       return stepList;
   }
   
   public static void publishOrderProcessingEvent(List<Coms_Step_PE__e> Events){
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