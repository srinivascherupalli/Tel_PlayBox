global with sharing class Orchestration_RecreateDelSpecsV1_Main extends Orchestration_AbstractStepHandler {
     String str='';
     Map<String, Object> payloadMap=new Map<String,Object>();   
    
    public override List<SObject> process(List<SObject> steps) {
    
        // LIMITS VIOLATED THEN EXIT
        if (Orchestration_LimitsUtility.areLimitsViolated()) {
            return null;
        }
        
        
        List<CSPOFA__Orchestration_Step__c> stepList = new List<CSPOFA__Orchestration_Step__c>();
        
            stepList = (List<CSPOFA__Orchestration_Step__c>) getStepList(steps);

            //Order Id Vs LIst Of Services
            //Map<Id, csord__Service__c> serviceMap = new Map<Id, csord__Service__c>();
            //attchmap = new Map<Id, Orchestration_AttachmentWrapper>();
            //allAttachmentsMap = New Map<Id, Attachment> ();  
            //Set<Id> originServiceIds = new Set<Id>();
            //Map<Id, List<csord__Service__c>> orderServiceRelationMap = new Map<Id, List<csord__Service__c>>();
            List<Object>servList = new List<Object>();
            List<Object>attachList = new List<Object>();
            List<Coms_Step_PE__e> orderEvents = new List<Coms_Step_PE__e>(); 
             
            
            system.debug('heap check + CPU Check ==> '+limits.getHeapSize()+'=='+limits.getCpuTime());
      
            for(CSPOFA__Orchestration_Step__c step : stepList) {
                try {
                    //payloadMap.put('serviceListAll',serviceList);
                    //payloadMap.put('attachmentList',attachmentList);
                    payloadMap.put('orderIds',orderIds);
                    payloadMap.put('StepId',step.Id);
                    payloadMap.put('Current',step.CSPOFA__Orchestration_Process__r.Order__c);
                    payloadMap.put('ProcessName',step.CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name);
                    str=(String)JSON.serialize(payloadMap); 
                    system.debug('###payload: ' + str);
                    Coms_Step_PE__e orderEvt = new Coms_Step_PE__e(Sequence__c=step.id, payload__c=str, Orchestration_Process_Name__c=step.CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name,Step_Number__c=step.CSPOFA__Step_Order__c);
                    orderEvents.add(orderEvt);
                    stepResults.put(step.Id, new stepResult('Waiting: Called Order Publisher', OrchestratorConstants.OrchestratorStep.Waiting)); //Check with Prajakta
                    
                } catch (exception ex) {
                    //system.debug('exception found---???'+ex.getMessage());
                    stepResults.put(
                        step.Id,
                        new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString())
                    );
                }

            } // FOR ENDS

        publishOrderProcessingEvent(orderEvents);
        return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
    }

    public override List<sObject> getStepList(List<sObject> steps) {
        Set<String> stepIds = new Set<String>();

        List<CSPOFA__Orchestration_Step__c> stepList = [
            SELECT
                ID,
                Name,
                CSPOFA__Orchestration_Process__c,
                CSPOFA__Status__c,
                CSPOFA__Completed_Date__c,
                JSON__c,
                CSPOFA__Message__c,
                CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c,
                CSPOFA__Orchestration_Process__r.cspofa__account__c,
                CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c,
                CSPOFA__Orchestration_Process__r.Order__c,
                CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name, 
                CSPOFA__Step_Order__c
            FROM CSPOFA__Orchestration_Step__c
            WHERE Id IN :steps
        ];
        //system.debug(stepList[0].CSPOFA__Orchestration_Process__r.Name);
        for (CSPOFA__Orchestration_Step__c step : stepList) { //Check with Prajakta
            if (step.CSPOFA__Orchestration_Process__r.Order__c != null) {
                OrderIds.add(step.CSPOFA__Orchestration_Process__r.Order__c);
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