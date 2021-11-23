/*
 Change.No.    Developer Name          Date          Story Description
 1.		       Milos Djordjevic        08/06/2021    EDGE-222326 : Modified areLimitsViolated logic check to return SObject instead of NULL
 */
global with sharing class Orchestration_UpdateParentTriggerRts extends Orchestration_AbstractStepHandler {
    
    private Set<Id> solutionIds = new Set<Id>();
    private Set<Id> parentSubscription = new Set<Id>();
    private Map<Id, csord__Subscription__c> mapParentSubToSolution = new Map<Id, csord__Subscription__c>();
    private Map<Id, List<csord__Subscription__c>> mapChildSubsToSolution = new Map<Id, List<csord__Subscription__c>>();
    private Map<Id, Id> stepRelationship = new Map<Id, Id>();
    private Map<Id, Integer> solutionToAllsubCount = new Map<Id, Integer>();
    private Map<Id, Integer> solutionToreqSubCount = new Map<Id, Integer>();
    private Set<Id> solutionIdsNew = new Set<Id>();
    private Map<Id, csord__service__c> mapParentSubToService = new Map<Id, csord__service__c>();
    private Map<Id, Boolean> mapSolutiontoActive = new Map<Id, Boolean>();
    public override List<sObject> process(List<sObject> data){
		List<SObject> sobjList = new List<SObject>(); // Added as part of EDGE-222326
        if (Orchestration_LimitsUtility.areLimitsViolated()) {
            return sobjList; // Added as part of EDGE-222326
        }
        
        try{
            
            List<CSPOFA__Orchestration_Step__c> stepList = (List<CSPOFA__Orchestration_Step__c>) getStepList(data);
            for(Id solution :solutionToAllsubCount.keyset()) //added as part of B2B-328 - Solution Supress - start
            {
                if(solutionToAllsubCount.get(solution) == solutionToreqSubCount.get(solution))
                {
                    solutionIdsNew.add(solution);
                }else{
                    solutionIdsNew.add(solution);
                    mapSolutiontoActive.put(solution,true);
                }
            }
            populateMapRelationshipData();//added as part of B2B-328 - Solution Supress - End
            
            for (CSPOFA__Orchestration_Step__c step : stepList) {
                try {          
                    if (step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c == null ) {
                        //Updating steps as Error since no proper data linked to step
                        stepResults.put(step.Id, new stepResult('Error: Step do not have a related subscription', OrchestratorConstants.OrchestratorStep.Error));
                        //Check the next step
                        continue;
                    }
                    //Limit check
                    if (Orchestration_LimitsUtility.areLimitsViolated()) {
                        //terminate the loop
                        break;
                    }
                    //added as part of B2B-328 - Solution Supress - start
                    csord__Subscription__c subscriptionToUpdate = mapParentSubToSolution.containsKey(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.cssdm__solution_association__c)?mapParentSubToSolution.get(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.cssdm__solution_association__c):null;
                    csord__Service__c serv = mapParentSubToService.containsKey(subscriptionToUpdate.cssdm__solution_association__c)?mapParentSubToService.get(subscriptionToUpdate.cssdm__solution_association__c):null;
                    if(mapParentSubToSolution.containsKey(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.cssdm__solution_association__c))
                    {
                        if(mapSolutiontoActive.containsKey(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.cssdm__solution_association__c)){
                            subscriptionToUpdate.csord__Status__c ='Active';
                            serv.csord__Status__c = 'Connected';
                        }else{
                            subscriptionToUpdate.csord__Status__c ='Inactive';
                            serv.csord__Status__c = 'Disconnected';
                        }
                        
                        sObjectsToUpdate.put(serv.id,serv);
                        sObjectsToUpdate.put(subscriptionToUpdate.Id, subscriptionToUpdate);
                        stepRelationship.put(subscriptionToUpdate.Id, step.Id);
                        //added as part of B2B-328 - Solution Supress - End
                    }else{
                        stepResults.put(step.Id, new stepResult('Success: Not all child subscriptions are bill stopped or parent not cancelled', OrchestratorConstants.OrchestratorStep.Complete));
                    }

                } catch (Exception ex) {
                    stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
                }
            }  
        }catch (Exception ex) {
            for (CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) data) {
                stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
            }
        }
        
        if(!sObjectsToUpdate.isEmpty() && !Orchestration_LimitsUtility.areLimitsViolated()){
            updateObjects();
        }
        return processStepResults((List<CSPOFA__Orchestration_Step__c>) data, stepResults);
    }
    
    private void populateMapRelationshipData(){
        
        for(csord__Subscription__c subscription: [Select Id, Name, cssdm__solution_association__c , csordtelcoa__Product_Configuration__c, Trigger_RTS__c, toBeCancelled__c, csordtelcoa__Product_Configuration__r.configurationType1__c,(select id,csord__status__c from csord__services__r) from csord__Subscription__c where cssdm__solution_association__c IN: solutionIdsNew and csordtelcoa__Product_Configuration__r.configurationType1__c =:OrchestratorConstants.ProductConfigType.SolutionComponent]){
            /*if(subscription.csordtelcoa__Product_Configuration__r.configurationType1__c == OrchestratorConstants.ProductConfigType.SolutionComponent || subscription.Name.contains('Unified Communication Tenancy Solution')){*/
                mapParentSubToSolution.put(subscription.cssdm__solution_association__c, subscription); //added as part of B2B-328 - Solution Supress - start
            
            for(csord__service__c serv : subscription.csord__services__r)
            {
                mapParentSubToService.put(subscription.cssdm__solution_association__c, serv);
            }//added as part of B2B-328 - Solution Supress - End
            /*}else { //commented as part of B2B-328 - Solution Supress 
                if(!mapChildSubsToSolution.containskey(subscription.cssdm__solution_association__c)){
                    mapChildSubsToSolution.put(subscription.cssdm__solution_association__c, new List<csord__Subscription__c>{subscription});
                }else{
                    mapChildSubsToSolution.get(subscription.cssdm__solution_association__c).add(subscription);
                }
            }*/
            
        }
    }
    
    public override void updateObjects() {
    //Updating all the records including orders and subscription
    Database.SaveResult[] updateResult = Database.update(sObjectsToUpdate.values(), false);
    //Storing the records
    for (Database.SaveResult rslt : updateResult) {
      //stepRelationship will contain only subscription therefore avoiding updated order records
      if(stepRelationship.containsKey(rslt.getId())){
      if (rslt.isSuccess()) {
        stepResults.put(stepRelationship.get(rslt.getId()),  new stepResult('Success: parent subscription updated', OrchestratorConstants.OrchestratorStep.Complete));
      } else {
        //record updation failed there related step updated
        stepResults.put(stepRelationship.get(rslt.getId()), new stepResult('Error: Unable to process records as DML failed', OrchestratorConstants.OrchestratorStep.Error));
      }
      }
    }
  }
    
    public override List<sObject> getStepList(List<sObject> steps) {
        List<CSPOFA__Orchestration_Step__c> stepList = [
            SELECT
            ID,
            Name,
            CSPOFA__Orchestration_Process__c,
            CSPOFA__Status__c,
            CSPOFA__Completed_Date__c,
            JSON__c,
            CSPOFA__Message__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.Name,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Product_Configuration__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Product_Configuration__r.ConfigurationType1__c,
            CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.cssdm__solution_association__c
            FROM CSPOFA__Orchestration_Step__c
            WHERE Id IN :steps
        ];
        for(CSPOFA__Orchestration_Step__c step: stepList){
            if(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c != null){
                subscriptionIds.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);
            }
            if(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.cssdm__solution_association__c != null){
                solutionIds.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.cssdm__solution_association__c);
            }
            
        }
        //added as part of B2B-328 - Solution Supress - start
        for(AggregateResult allSubCount :[select cssdm__solution_association__c,count(Id) from csord__Subscription__c where cssdm__solution_association__c In :solutionIds and csordtelcoa__Product_Configuration__r.ConfigurationType1__c!='SolutionComponent' group by cssdm__solution_association__c]){
            Id solId = (Id)allSubCount.get('cssdm__solution_association__c');
            Integer cnt = (Integer)allSubCount.get('expr0'); 
            solutionToAllsubCount.put(solId,cnt);
        }
        
        for(AggregateResult reqSubCount :[select cssdm__solution_association__c,count(csord__Status__c) from csord__Subscription__c where cssdm__solution_association__c In :solutionIds and csordtelcoa__Product_Configuration__r.ConfigurationType1__c!='SolutionComponent' and csord__Status__c IN ('Inactive','Paid Out') group by cssdm__solution_association__c]){
            Id solId = (Id)reqSubCount.get('cssdm__solution_association__c');
            Integer cnt = (Integer)reqSubCount.get('expr0'); 
            solutionToreqSubCount.put(solId,cnt);
        }//added as part of B2B-328 - Solution Supress - End
        return stepList;
    }
}