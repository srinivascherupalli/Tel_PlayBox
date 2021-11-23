/**================================================================
*  Name: Orchestration_AccountStatusUpdate_RF
* Description: Updates the account status to Acquired if subscription is sent for billing successfully
* Created Date: 
* Created By: 
==================================================================*/
global with sharing class Orchestration_AccountStatusUpdate_V2 extends Orchestration_AbstractStepHandler {
    private Map<Id, Id> stepRelationship = new Map<Id, Id>();
    private String payloadStr='';
    //Integer seq=0;
    Map<String, Object> payloadMap=new Map<String,Object>();
    
    public override List<SObject> process(List<SObject> steps) {
        if (Orchestration_LimitsUtility.areLimitsViolated()) {
          //  system.debug('stopping execution as limit breached.....');
            return null;
        }
        List<CSPOFA__Orchestration_Step__c> stepList = new List<CSPOFA__Orchestration_Step__c>();
        List<Coms_Subscription_PE__e> subscriptionEvents = new List<Coms_Subscription_PE__e>(); 
        try {
            stepList = (List<CSPOFA__Orchestration_Step__c>) getStepList(steps);
            
            getRelatedSubscriptionIds(stepList); //this gets the list of subscriptionIds           
            
            for (CSPOFA__Orchestration_Step__c step : stepList) { 
                try {
                    if (step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c == null ) {
                        //Updating steps as Error since no proper data linked to step
                        stepResults.put(step.Id, new stepResult('Error: Step do not have an associated subscription', OrchestratorConstants.OrchestratorStep.Error));
                        //Check the next step
                        continue;
                    }
                    
                    if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        //terminate the loop
                        break;
                    }
                    payloadMap.put('subscriptionIds',subscriptionIds);
                    payloadMap.put('StepId',step.Id);
                    payloadMap.put('Current',step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);
                    payloadMap.put('ProcessName',step.CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name);
                    payloadStr=(String)JSON.serialize(payloadMap); 
                    system.debug('###payload: ' + payloadStr);
                    //Coms_Subscription_PE__e subsEvt = new Coms_Subscription_PE__e(Sequence__c=step.id, payload__c=str, Orchestration_Process_Name__c=step.CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name,Step_Number__c=step.CSPOFA__Step_Order__c);
                    Coms_Subscription_PE__e subsEvt = new Coms_Subscription_PE__e(Sequence__c=String.valueOf(Orchestration_PlatformCacheUtility.seq), payload__c=payloadStr, Orchestration_Process_Name__c=step.CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name,Step_Number__c=step.CSPOFA__Step_Order__c);
                    subscriptionEvents.add(subsEvt);
                    
                    Orchestration_PlatformCacheUtility.seq++;
                    stepResults.put(step.Id, new stepResult('Waiting: Called Service Publisher', OrchestratorConstants.OrchestratorStep.Waiting));                    
                } catch (Exception ex) {
                    stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
                }
            }
        } catch (Exception ex) {
            for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) steps) {
                stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
            }
        }
        publishSubsProcessingEvent(subscriptionEvents);
        return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
    }
    //override getStepList to fetch necessry field from steps
    public override List<sObject> getStepList(List<sObject> steps) {
        List<CSPOFA__Orchestration_Step__c> stepList = [
            SELECT ID, CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Account__c,CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name,CSPOFA__Step_Order__c FROM CSPOFA__Orchestration_Step__c
            WHERE Id IN :steps
        ];
        
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