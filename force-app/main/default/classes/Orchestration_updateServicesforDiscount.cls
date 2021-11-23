/**================================================================
* Wipro, Inc
* Name: Orchestration_updateServicesforDiscount
* Created Date: 07-10-2021
* Created By: Aman Gupta
==================================================================*/
global with sharing class Orchestration_updateServicesforDiscount extends Orchestration_AbstractStepHandler {
    private Map<Id, Set<Id>> stepRelationshipMap = new Map<Id, Set<Id>>();
    private Map<Id, List<Orchestration_AttachmentWrapper>> orderAttachmentMap = new Map<Id, List<Orchestration_AttachmentWrapper>>();
    private Map<Id, List<csord__Service__c>> servicesToUpdate = new Map<Id, List<csord__Service__c>>();
    private Boolean hasError=false;
    public override List<sObject> process(List<sObject> steps) {
        List<SObject> sobjList=new List<SObject>();

        Set<Id> oppIdSet = new Set<Id>();
        List<CSPOFA__Orchestration_Step__c> stepList = new List<CSPOFA__Orchestration_Step__c>();
        System.debug('before main block ' + limits.getCPUTime() + '  ' + limits.getHeapSize());
        try {            
            stepList = (List<CSPOFA__Orchestration_Step__c>) getStepList(steps);
            getRelatedOrderIds(stepList);
            for (csord__Service_Line_Item__c sliRecord: [SELECT ID,csord__Is_Adhoc__c,csord__Is_Active__c,csord__Discount_Type__c,
                                                         csord__Service__r.containsDiscount__c,csord__Service__r.csord__Order__c
                                                         FROM csord__Service_Line_Item__c 
                                                         WHERE csord__Service__r.csord__Order__c IN :orderIds
                                                         AND csord__Discount_Type__c != null
                                                         AND csord__Is_Adhoc__c =false
														 AND csord__Is_Active__c = true]) 
            {				                
				csord__Service__c service = sliRecord.csord__Service__r;              
                    service.containsDiscount__c = true;               
                    List<csord__Service__c> servicelist=new List<csord__Service__c>();
                    if(servicesToUpdate.containskey(service.csord__Order__c)){
                        servicelist=servicesToUpdate.get(service.csord__Order__c);
                    }
                    servicelist.add(service);
                    servicesToUpdate.put(service.csord__Order__c, servicelist);         
                if (servicesToUpdate.isempty()) {                  	
                    for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) steps) {
						stepResults.put(step.Id, new stepResult('No records found with suitable condition', OrchestratorConstants.OrchestratorStep.Complete));
                    }
                }
        }
            
            for (CSPOFA__Orchestration_Step__c step : stepList) {
                    if (step.CSPOFA__Orchestration_Process__r.Order__c == null) {
                        //Updating steps as Error since no proper data linked to step
                        stepResults.put(step.Id, new stepResult('Error: Step do not have Order.', OrchestratorConstants.OrchestratorStep.Error));
                        //Check the next step
                        continue;
                    }
                    if (step.CSPOFA__Orchestration_Process__r.Order__r.csordtelcoa__Opportunity__c == null) {
                        stepResults.put(step.Id, new stepResult('Success: Order do not have Opportunity.', OrchestratorConstants.OrchestratorStep.Complete));
                        continue;
                    }
                    Id orderId = step.CSPOFA__Orchestration_Process__r.Order__c;
                    if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        break;
                    }
                    System.debug('before data for block '+limits.getCPUTime()+'  '+limits.getHeapSize());
                    Set<ID> serviceidset=new Set<ID>();
                    for (csord__Service__c serv : servicesToUpdate.get(orderId)) {
                        serviceidset.add(serv.id);
                        sObjectsToUpdate.put(serv.id,serv);
                    }
                    stepRelationshipMap.put(step.id,serviceidset);
            }
            System.debug('sObjectsToUpdate data for block '+limits.getCPUTime()+'  '+limits.getHeapSize() + sObjectsToUpdate.values().size());
            if (!sObjectsToUpdate.isEmpty()) {
                updateObjects();
            }
        } catch (Exception ex) {
            for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) steps) {
                stepResults.put(
                    step.Id,
                    new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString())
                );
            }
        }
        return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
    }
    public override void updateObjects() {
        //Updating all the records including orders and subscription
        Database.SaveResult[] updateResult = Database.update(sObjectsToUpdate.values(), false);
        //Storing the records
        List<Id> successserviceIds = new List<Id>();
        for (Database.SaveResult rslt : updateResult) {
            if (rslt.isSuccess()) {
                successserviceIds.add(rslt.getId());
            }
        }
        System.debug('uodateblock data for block '+limits.getCPUTime()+'  '+limits.getHeapSize() + sObjectsToUpdate.values().size());
        for (Id stepId : stepRelationshipMap.keySet()) {
            //Object Type --> Ids
            Orchestration_ProcessedRecords perStepSuccessIds = new Orchestration_ProcessedRecords();
            Boolean isFailed = false;
            for (Id recId : stepRelationshipMap.get(stepId)) {
                //Only order check
                if (!successserviceIds.contains(recId)) {
                    isFailed = true;
                }
            }
            if (!isFailed) {
                stepResults.put(stepId, new stepResult('Success: Records processed', OrchestratorConstants.OrchestratorStep.Complete));
                //move to next step
                continue;
            }else {
                stepResults.put(stepId, new stepResult('Error: Unable to process records', OrchestratorConstants.OrchestratorStep.Error));
            }
        }
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
                CSPOFA__Orchestration_Process__r.Order__r.csordtelcoa__Opportunity__c
            FROM CSPOFA__Orchestration_Step__c
            WHERE Id IN :steps
        ];

        for (CSPOFA__Orchestration_Step__c step : stepList) {
            if (step.CSPOFA__Orchestration_Process__r.Order__c != null) {
                OrderIds.add(step.CSPOFA__Orchestration_Process__r.Order__c);
            }            
        }
        return stepList;
    }
}