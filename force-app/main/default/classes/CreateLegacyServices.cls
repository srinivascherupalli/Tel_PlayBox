global with sharing class CreateLegacyServices implements CSPOFA.ExecutionHandler {
    public List<sObject> process(List<sObject> data){
        List<Id> orchesIds= new List<Id>();
        List<sObject> result = new List<sObject>();
        List<Id> orderIdList = new List<Id>();
        List<CSPOFA__Orchestration_Step__c> stepList= (List<CSPOFA__Orchestration_Step__c>)data;
        system.debug('stepList=='+stepList);
                 
        for(CSPOFA__Orchestration_Step__c step: stepList)
        {
            orchesIds.add(step.CSPOFA__Orchestration_Process__c);
        }
        for(CSPOFA__Orchestration_Process__c  orch : [Select Order__c from CSPOFA__Orchestration_Process__c where Id IN:orchesIds])
        {
            orderIdList.add(orch.Order__c);
        }
        List<Id> subscriptionIdList = new List<Id>();
         
        //commenting out the primary order as there will not be any secondary order created with upgraded O&S package
        /*for(csord__Subscription__c sub: [Select Id FROM csord__Subscription__c WHERE csord__Order__r.csord__Primary_Order__c IN: orderIdList]){
            subscriptionIdList.add(sub.id);
        }*/
        for(csord__Subscription__c sub: [Select Id FROM csord__Subscription__c WHERE csord__Order__c IN: orderIdList]){
            subscriptionIdList.add(sub.id);
        }
         
         
        TransitionServicesCreationObserverHelper.createLegacyServices(subscriptionIdList);
        
        for(CSPOFA__Orchestration_Step__c step : stepList){
             
            step.CSPOFA__Status__c = 'Complete';
            step.CSPOFA__Completed_Date__c=Date.today();
            step.CSPOFA__Message__c = 'Completed';
            result.add(step);
        }
        return result;
    }
     
}