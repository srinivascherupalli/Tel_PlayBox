/**************************************************************
 Name: SolutionCompletionHandler
 Description: Class to evaluate Solution Completion 
**************************************************************/
/*Class Name      :   SolutionCompletionHandler
Test Class : SolutionCompletionHandlerTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1. 			  Prajakta Patil        22/10/19         EDGE-81140 
**********************************************************
*/

    global with sharing class SolutionCompletionHandler implements CSPOFA.ExecutionHandler,CSPOFA.Calloutable{

         public Boolean performCallouts(List<SObject> data){
            List<CSPOFA__Orchestration_Step__c> stepList= (List<CSPOFA__Orchestration_Step__c>)data;
			List<String> subscripIdList = new List<String>();
            List<Id> orchesIds= new List<Id>();
            Boolean calloutsPerformed = false;
             
            for(CSPOFA__Orchestration_Step__c step: stepList){
                orchesIds.add(step.CSPOFA__Orchestration_Process__c);
            }
            
            for(CSPOFA__Orchestration_Process__c  orch : [Select csordtelcoa__Subscription__c from CSPOFA__Orchestration_Process__c where Id IN:orchesIds])
			subscripIdList.add(orch.csordtelcoa__Subscription__c);		
			
            BillingOrderServiceUtil.evaluateSolutionCompletion(subscripIdList);
            calloutsPerformed = true;
            return calloutsPerformed;
			
         }
        
        
        public List<sObject> process(List<sObject> data){
            List<sObject> result = new List<sObject>();
            List<CSPOFA__Orchestration_Step__c> stepList= (List<CSPOFA__Orchestration_Step__c>)data;
           
            for(CSPOFA__Orchestration_Step__c step : stepList){
                step.CSPOFA__Status__c = 'Complete';
                step.CSPOFA__Completed_Date__c=Date.today();
                step.CSPOFA__Message__c = 'Completed';
                result.add(step);
            }
            return result;
        }

}