/*************************************************************************************
    Name: UpdateParentSpecSpecAttachments 
    Description: This class updated as part of EDGE-66239 and class will update the service specifications
    ************************************************************************************/

    global with sharing class UpdateParentSpecSpecAttachments implements CSPOFA.ExecutionHandler {
        public List<sObject> process(List<sObject> data){
            List<Id> orchesIds= new List<Id>();
            List<sObject> result = new List<sObject>();
            Set<Id> oppIdSet = new Set<Id>();
            set<Id> accountIdSet =  new set<Id>();
            List<Id> oppIdList = new List<Id>();
            List<Id> serviceIds = new List<Id>();
            List<CSPOFA__Orchestration_Step__c> stepList= (List<CSPOFA__Orchestration_Step__c>)data;
            for(CSPOFA__Orchestration_Step__c step: stepList)
            {
                orchesIds.add(step.CSPOFA__Orchestration_Process__c);
            }
            for(CSPOFA__Orchestration_Process__c  orch : [Select Order__c, Order__r.csordtelcoa__Opportunity__c, Order__r.csord__Account__c from CSPOFA__Orchestration_Process__c where Id IN:orchesIds])
            {
                oppIdSet.add(orch.Order__r.csordtelcoa__Opportunity__c);
                accountIdSet.add(orch.Order__r.csord__Account__c);
            }
            for(csord__Service__c serviceObj: [SELECT Id from csord__Service__c WHERE csord__Order__r.csordtelcoa__Opportunity__c IN : oppIdSet]){
                serviceIds.add(serviceObj.Id);
            }
            oppIdList.addAll(oppIdSet);
            EDMRelationshipService_V2.createRelationShip(oppIdList);
            for(CSPOFA__Orchestration_Step__c step : stepList){
                step.CSPOFA__Status__c = 'Complete';
                step.CSPOFA__Completed_Date__c=Date.today();
                step.CSPOFA__Message__c = 'Completed';
                result.add(step);
            }
            return result;
        }
         
    }