/**
*  Purpose          :   This class is used to update solution sub and service statuses
*  
*  Author          :   Gaurang Maheshwari
* 
*  Created Date    :   16 June 2020
* 
*  Current Version :   V_1.0
* 
*  Revision Log    :   V_1.0 - Gaurang Maheshwari (16 June 2020) - Created/Optimised

* Pawan     28-10-2020      EDGE-177027 : Updating solution svc and subs status to Closed
* Gnana     22-12-2020      EDGE-132434 : Updating Subscription Status to Provisioned or Provisioning In Progress based on Offer Id
*/
global with sharing class Orchestration_UpdateSrvcStatusMainSol extends Orchestration_AbstractStepHandler {
    private List<CSPOFA__Orchestration_Step__c> stepList= new List<CSPOFA__Orchestration_Step__c>();
    
    private Map<Id, String> mapServiceToStep = new Map<Id, String>();
    
    private Set<Id> directCompleteServiceIds = new Set<Id>();
    private Map<Id, Set<Id>> stepRelationshipMap = new Map<Id, Set<Id>>();
    private Map<Id, csord__Subscription__c> subsToUpdate = new Map<Id, csord__Subscription__c>();
    private Map<Id, csord__Service__c> servicesToUpdate = new Map<Id, csord__Service__c>();
    private String incompleteStepId = null;
    
    public override List<SObject> process(List<SObject> data){
        
        try {
            if(Orchestration_LimitsUtility.areLimitsViolated()){        
                system.debug('stopping execution as limit breached.....');
                return null;
            }            
            stepList= getStepList(data);
            for(CSPOFA__Orchestration_Step__c step : stepList) {        
                try{        
                    if (step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c == null ) {
                        stepResults.put(step.Id, new stepResult('Error: Step do not have a related service record', OrchestratorConstants.OrchestratorStep.Error));
                        continue;
                    }
                    //Check if any limits hit then return execution
                    if(Orchestration_LimitsUtility.areLimitsViolated() || hasDMLRowsLimitExceeded()){        
                        break;
                    }          
                    //mapServiceToStep.put(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c, step.id);
                    csord__Service__c service = step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r;          
                    if(service.csordtelcoa__Product_Configuration__r.ConfigurationType1__c == 'SolutionComponent' || service.Name.contains('Bandwidth Clip On')){
                        /*******************CHECK SERVICE STATUS UPDATE*********************************************/
                        if(hasDMLRowsLimitExceeded()){
                            incompleteStepId = step.Id;
                            break;
                        }
                        System.debug('debug51 '+service.csord__Subscription__r.csordtelcoa__Product_Configuration__r.ConfigurationType1__c);
                        System.debug('Debug 52 '+service.csord__Subscription__r.MarketableOffer__c);
                        System.debug('Debug 53 '+service.csord__Subscription__r.MarketableOffer__r.Offer_ID__c);
                        //EDGE-177027 Start
                        if(service.csord__Subscription__r.csordtelcoa__Product_Configuration__r.ConfigurationType1__c == 'SolutionComponent' && service.csord__Subscription__r.MarketableOffer__c != null && service.csord__Subscription__r.MarketableOffer__r.Offer_ID__c != null && System.label.SvcSubsStatusClosed.contains(service.csord__Subscription__r.MarketableOffer__r.Offer_ID__c)){
                            if(service.csord__Status__c !='Closed'){
                            service.csord__Status__c ='Closed';
                            servicesToUpdate.put(service.Id, service);            
                            if (!stepRelationshipMap.containsKey(step.Id)) {
                                stepRelationshipMap.put(step.Id, new Set<Id>{ service.Id });
                            } else {stepRelationshipMap.get(step.Id).add(service.Id);}
                        }
                        }//EDGE-177027 End
                        else if(service.toBeCancelled__c == 'true' && service.csord__Status__c !='Disconnected'){            
                            service.csord__Status__c ='Disconnected';
                            servicesToUpdate.put(service.Id, service);            
                            if (!stepRelationshipMap.containsKey(step.Id)) {
                                stepRelationshipMap.put(step.Id, new Set<Id>{ service.Id });
                            } else {stepRelationshipMap.get(step.Id).add(service.Id);}
                        } else if(service.csord__Status__c !='Connected') {              
                            service.csord__Status__c = service.toBeCancelled__c == 'true' ? 'Disconnected' : 'Connected';
                            servicesToUpdate.put(service.Id, service);            
                            if (!stepRelationshipMap.containsKey(step.Id)) {
                                stepRelationshipMap.put(step.Id, new Set<Id>{ service.Id });
                            } else {stepRelationshipMap.get(step.Id).add(service.Id);}
                        }  
                        /*******************CHECK SUBS STATUS UPDATE*********************************************/
                        if(hasDMLRowsLimitExceeded()) {
                            incompleteStepId = step.Id;
                            break;
                        }
                        csord__Subscription__c subscription = new csord__Subscription__c(Id = step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__c, csord__Status__c = step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.csord__Status__c, Name = step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.Name);
                        //EDGE-177027 : start
                        System.debug('Pawan :: '+step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.csordtelcoa__Product_Configuration__r.ConfigurationType1__c  +' '+ step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.MarketableOffer__c +' '+ step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.MarketableOffer__r.Offer_ID__c +' '+ subscription.csord__Status__c );
                        
                        if(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.csordtelcoa__Product_Configuration__r.ConfigurationType1__c == 'SolutionComponent' && step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.MarketableOffer__c != null && step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.MarketableOffer__r.Offer_ID__c != null && System.label.SvcSubsStatusClosed.contains(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.MarketableOffer__r.Offer_ID__c) && subscription.csord__Status__c != 'Closed'){              
                            subscription.csord__Status__c='Closed';
                            subsToUpdate.put(subscription.Id, subscription);
                            if (!stepRelationshipMap.containsKey(step.Id)) {
                                stepRelationshipMap.put(step.Id, new Set<Id>{ subscription.Id });
                            } else {
                                stepRelationshipMap.get(step.Id).add(subscription.Id);
                            }
                            //stepRelationshipMap.get(step.Id).add(subscription.Id);
                        }//EDGE-177027 :end
                        else if(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.toBeCancelled__c=='true' && subscription.csord__Status__c != 'Pending'){              
                            subscription.csord__Status__c='Pending'; subsToUpdate.put(subscription.Id, subscription);
                            if (!stepRelationshipMap.containsKey(step.Id)) {stepRelationshipMap.put(step.Id, new Set<Id>{ subscription.Id });} else {stepRelationshipMap.get(step.Id).add(subscription.Id);}
                            //stepRelationshipMap.get(step.Id).add(subscription.Id);
                            //Modified condition to cease update for terminal status EDGE-198973;DPG-4085; Ila
                        }else if(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.csordtelcoa__Product_Configuration__r.ConfigurationType1__c == 'SolutionComponent' && ((!subscription.csord__Status__c.equalsIgnoreCase('Active')) && (!subscription.csord__Status__c.equalsIgnoreCase('Provisioned')) && (!subscription.csord__Status__c.equalsIgnoreCase('Bill Readiness In Progress')) && (!subscription.csord__Status__c.equalsIgnoreCase('Inactive')))){
                            System.debug('inside provisioned...'+step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.ConfigSpecID__c);
                            subscription.csord__Status__c = (System.label.Adaptive_Mobility_Offer_Id.contains(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.ConfigSpecID__c) || System.label.CMP_Offer_Id.contains(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.ConfigSpecID__c)) ? 'Provisioning In Progress' : 'Provisioned'; // Modified as part of EDGE-132434 to update Status based on Offer Id 
                            //Start DPG-4370: Ila
                            System.debug('subscription.csord__Status__c...'+subscription.csord__Status__c);
                            System.debug('subscription.triggerBill_RTB__c...'+subscription.triggerBill_RTB__c);
                            System.debug('System.Label.ManagedService_MarketableOfferId...'+step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.MarketableOffer__r.Offer_ID__c);

                            if((step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.MarketableOffer__r.Offer_ID__c==System.Label.ManagedService_MarketableOfferId || step.CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.MarketableOffer__r.Offer_ID__c==System.Label.ProfessionalService_MarketableOfferId) && subscription.csord__Status__c == 'Provisioned' && subscription.triggerBill_RTB__c == false){ subscription.triggerBill_RTB__c = true;}
                 
                           
                            //End DPG-4370: Ila
                            subsToUpdate.put(subscription.Id, subscription);
                            if (!stepRelationshipMap.containsKey(step.Id)) {
                                stepRelationshipMap.put(step.Id, new Set<Id>{ subscription.Id });
                            } else {
                                stepRelationshipMap.get(step.Id).add(subscription.Id);
                            }
                        
                            //stepRelationshipMap.get(step.Id).add(subscription.Id);
                        }else if(subscription.Name.equalsIgnoreCase('Unified Communication Tenancy Solution') && subscription.csord__Status__c != 'Active'){
                            subscription.csord__Status__c='Active';
                            subsToUpdate.put(subscription.Id, subscription);
                            if (!stepRelationshipMap.containsKey(step.Id)) {
                                stepRelationshipMap.put(step.Id, new Set<Id>{ subscription.Id });
                            } else {
                                stepRelationshipMap.get(step.Id).add(subscription.Id);
                            }
                            //stepRelationshipMap.get(step.Id).add(subscription.Id);
                        }
                    } else {
                        stepResults.put(step.Id, new StepResult('Success: No update needed as service does not meet given criteria', OrchestratorConstants.OrchestratorStep.Complete));
                    }
                    
                    if ((incompleteStepId == null || incompleteStepId != step.Id ) && !stepRelationshipMap.containsKey(step.Id)) {
                        stepResults.put(step.Id, new stepResult('Success - No service and subsciption found for update', OrchestratorConstants.OrchestratorStep.Complete));
                    }                    
                    
                }catch(Exception ex){
                    stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
                }
            }
        } catch(Exception ex) {
            for(CSPOFA__Orchestration_Step__c step : (List<CSPOFA__Orchestration_Step__c>) data) {
                stepResults.put(step.Id, new stepResult('Error: ' + ex.getMessage() + ' on line ' + ex.getLineNumber(), OrchestratorConstants.OrchestratorStep.Error, ex.getStackTraceString()));
            }
        }
        
        if ((!subsToUpdate.isEmpty() || !servicesToUpdate.isEmpty()) && !Orchestration_LimitsUtility.areLimitsViolated()) {
            updateObjects();
        }
        return processStepResults((List<CSPOFA__Orchestration_Step__c>) data, stepResults);
    }
    
    public override void updateObjects(){
        
        Set<Id> successIds = new Set<Id>();
        if(servicesToUpdate.size() > 0) {
            Database.SaveResult[] updateResult = Database.update(servicesToUpdate.values(), false);
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    successIds.add(rslt.getId());
                }
            }
        }
        if(subsToUpdate.size() > 0) {
            Database.SaveResult[] updateResult = Database.update(subsToUpdate.values(), false);
            for (Database.SaveResult rslt : updateResult) {
                if (rslt.isSuccess()) {
                    successIds.add(rslt.getId());
                }
            }
        }
        for (Id stepId : stepRelationshipMap.keySet()) {
            Boolean isFailed = false;
            for (Id recId : stepRelationshipMap.get(stepId)) {
                if (successIds == null || !successIds.contains(recId)) {
                    isFailed = true;
                }
            }
            if (!isFailed && (String.isBlank(incompleteStepId) || !incompleteStepId.equals(stepId))) {
                stepResults.put(stepId, new stepResult('Success: Records processed', OrchestratorConstants.OrchestratorStep.Complete));
                //move to next step
                continue;
            } else if (!isFailed && !String.isBlank(incompleteStepId) && incompleteStepId.equals(stepId)) {
                stepResults.put(stepId, new stepResult('Success: Partial records processed', OrchestratorConstants.OrchestratorStep.InProgress));
            } else {
                stepResults.put(stepId, new stepResult('Error: Unable to process records', OrchestratorConstants.OrchestratorStep.Error));
            }
        }
    }
    //method override getsteplist
    public override List<sObject> getStepList(List<sObject> steps) {
        Set<String> stepIds = new Set<String>();
        List<CSPOFA__Orchestration_Step__c> stepList = [SELECT ID, Name, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, JSON__c, 
                                                        CSPOFA__Message__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c, 
                                                        CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.Name,
                                                        CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.toBeCancelled__c,
                                                        CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csordtelcoa__Product_Configuration__r.ConfigurationType1__c,
                                                        CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Status__c,
                                                        CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__c,
                                                        CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.csord__Status__c,
                                                        CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.csordtelcoa__Product_Configuration__r.ConfigurationType1__c,
                                                        CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.toBeCancelled__c,
                                                        CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.Name,
                                                        CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.MarketableOffer__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.MarketableOffer__r.Offer_ID__c,
                                                        CSPOFA__Orchestration_Process__r.csordtelcoa__Service__r.csord__Subscription__r.ConfigSpecID__c
                                                        FROM CSPOFA__Orchestration_Step__c WHERE Id IN :steps];
        
        return stepList;
    }
    
     public override boolean hasDMLRowsLimitExceeded() {
        if (subsToUpdate.size() + servicesToUpdate.size() + Limits.getDMLRows() < Integer.valueOf(Governor_Limits__c.getInstance().DML_Rows_limit__c)) {
            return false;
        }
        //Limit Hit
        return true;
    }
}