/******************************************************************************************************
    *Class Name     : Orchestration_RegenerateSpecsChown

    *Decription     : Class for updating specs for chown from pre requisite
    *Test Class     : Orchestration_RegenerateSpecsChownTest
    
   Sr.No.      Developer Name          Date            Story           Description
    1.         Shubhi V               03/03/21           EDGE-100718    step 2 generate specs 
********************************************************************************************************/

global with sharing class Orchestration_RegenerateSpecsChown extends Orchestration_AbstractStepHandler {
	
    private Map<Id, stepResult> stepResults = new Map<Id, stepResult>();
    @testVisible
    private Boolean calloutsPerformed = false;
    @testvisible
    private String calloutResults;
    @testvisible
    private String specsResult;
    private String pendingStep = '';
    private List<CSPOFA__Orchestration_Step__c> stepList;
    private Map<String, Orchestration_ProcessedRecords> processedIds = new Map<String, Orchestration_ProcessedRecords>();
    private Map<Id, List<String>> stepRelationshipMap = new Map<Id, List<String>>();
    public List<Id> subscriptionIdList = new List<Id>();
	
	//overriden performCallouts and invoke noncommercialData api 
    public override Boolean performCallouts(List < SObject > steps) {
        if (Orchestration_LimitsUtility.areCallOutLimitsViolated()) {
            //Cannot process the records
			return false;
			
        }try {
            system.debug('Heap Check====>>>'+limits.getHeapSize());
            stepList = (List<CSPOFA__Orchestration_Step__c>) getStepList(steps);
            
            //Set<Id>  = new Set<Id>();
            String nonCommercialEntities ='';
            if(subscriptionIdList!=null && subscriptionIdList.size()>0){
                nonCommercialEntities=csedm.API_1.getNonCommercialData(subscriptionIdList, new List < Id > ());
                this.calloutResults = nonCommercialEntities;calloutsPerformed = true;
            }else{
				for (CSPOFA__Orchestration_Step__c step: stepList) {
					stepResults.put(step.id, new stepResult('Error: No subscription found', OrchestratorConstants.OrchestratorStep.Error));
				}
			}
            
        }catch(Exception ex) {
            calloutsPerformed = false;
            for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) steps) {
                stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
            }
            system.debug('exception in perform callout -->'+ex.getMessage());
        }
        return calloutsPerformed;
    }
	
	//overriden process methos and invoked specs generation api 
    public override List < sObject > process(List < sObject > steps) {
        List < sObject > result = new List < sObject > ();
        if (Orchestration_LimitsUtility.areLimitsViolated() || !calloutsPerformed){
            return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
		}
        try{
            system.debug('enteres process methid====>>>' );
            if(subscriptionIdList!=null && subscriptionIdList.size()>0){
                specsResult=csedm.API_1.generateSpecifications(subscriptionIdList,
                new List < Id > (), false, this.calloutResults);
                if(specsResult!=''){
                    for (CSPOFA__Orchestration_Step__c step: stepList) {
                        stepResults.put(step.id, new stepResult('Success: Records processed', OrchestratorConstants.OrchestratorStep.Complete));
                    }
                }else{
                    for (CSPOFA__Orchestration_Step__c step: stepList) {
                        stepResults.put(step.id, new stepResult('Error: Records failed', OrchestratorConstants.OrchestratorStep.Error));
                    }
                }
            }else{
				for (CSPOFA__Orchestration_Step__c step: stepList) {
					stepResults.put(step.id, new stepResult('Error: No subscription found', OrchestratorConstants.OrchestratorStep.Error));
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
        
        return  processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
    }
	
	// method to get steps and subscription ids 
    public override List<sObject> getStepList(List<sObject> steps) {
        //Fetching more fields from the query
        List<CSPOFA__Orchestration_Step__c> stepList = [
            SELECT ID, Name, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, JSON__c, CSPOFA__Message__c, CSPOFA__Orchestration_Process__r.Order__c
            FROM CSPOFA__Orchestration_Step__c
            WHERE Id IN :steps
        ];
        Set<String> stepIds = new Set<String>();
		Set<String> orderIds = new Set<String>();
        for (CSPOFA__Orchestration_Step__c step : stepList) {
            if (step.CSPOFA__Orchestration_Process__r.Order__c != null) {
                orderIds.add(step.CSPOFA__Orchestration_Process__r.Order__c);//Get orders related to the steps
            }
        }
		for(csord__Subscription__c sub:[Select id from csord__Subscription__c where csord__order__c  In: orderIds]){
			subscriptionIdList.add(sub.id);
		}

        return stepList;
    }
}