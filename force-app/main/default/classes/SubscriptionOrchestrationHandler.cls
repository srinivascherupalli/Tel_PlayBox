/**************************************************************
 Name: SubscriptionOrchestrationHandler
 Description: Class to update Account Status
**************************************************************/
global with sharing class SubscriptionOrchestrationHandler {
/**************************************************************
Name: process
Parameters: List<SObject> steps
Return Type: List<SObject>
Description: Class to update the status of account
*******************************************************************/
global class AccountStatusUpdate implements CSPOFA.ExecutionHandler{
	
	public List<SObject> process(List<SObject> steps){
        List<CSPOFA__Orchestration_Step__c> result = new List<CSPOFA__Orchestration_Step__c>();
        List<CSPOFA__Orchestration_Step__c> stepList= (List<CSPOFA__Orchestration_Step__c>)steps;
        List<account> accountToUpdateIds = new List<account>();
        Set<Id> acctIds= new Set<Id>();
        List<Id> subsIds = new List<Id>();
        List<Id> orchesIds= new List<Id>();
        for(CSPOFA__Orchestration_Step__c step: stepList){
            orchesIds.add(step.CSPOFA__Orchestration_Process__c);
        }
        system.debug(orchesIds);
        List<CSPOFA__Orchestration_Process__c> orchList = [Select Id, Name, Order__c, csordtelcoa__Subscription__c from CSPOFA__Orchestration_Process__c where Id IN:orchesIds];
        System.debug('orchList ::'+orchList);
        for(CSPOFA__Orchestration_Process__c  orch : orchList){
            subsIds.add(orch.csordtelcoa__Subscription__c);
        }    
	
        List<csord__Subscription__c> subsRecord=[Select id, csord__Account__c, csord__Account__r.Customer_Status__c from csord__Subscription__c where Id IN: subsIds AND csord__Subscription__c.csord__Account__r.Customer_Status__c = 'Active'];
        for(csord__Subscription__c sr:subsRecord){
            Account acc =  new Account(Id = sr.csord__Account__c);
            acc.Customer_Status__c='Acquired';
            accountToUpdateIds.add(acc);
       }
        database.update(accountToUpdateIds);
        List<Account> acctsToUpdateListAfterUpdate=[select id, Customer_Status__c from Account where id IN:acctIds];
        system.debug('acctsToUpdateListAfterUpdate'+acctsToUpdateListAfterUpdate);
        for(CSPOFA__Orchestration_Step__c step : stepList){
            step.CSPOFA__Status__c = Label.Complete;
            step.CSPOFA__Completed_Date__c=Date.today();
            step.CSPOFA__Message__c = Label.Custom_Step_Succeeded;
            result.add(step);
        }
        return result;
	 }

    }
        
}