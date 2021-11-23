/************************************************************************
 Name:OrchestrationProcessHelper
 Description: Called from ObserverReferenceImplementation class
              Creates Orchestration Process for each subscription when
			  Subscription is created.
 ************************************************************************/
public with sharing class OrchestrationProcessHelper {
/***********************************************************************
  Name: CreateOrchestrationProcessforNewProvide
  Parameters: List<Id> subscriptionIds
  Return Type: void
  Description: Method Creates New Provide 
               Orchestration Process for each subscription 
*******************************************************************/

    public static void CreateOrchestrationProcessforNewProvide(List<Id> subscriptionIds){
        
        List<csord__subscription__c> lstSubs = [select Id, Name from csord__Subscription__c where Id IN:subscriptionIds];
        List<CSPOFA__Orchestration_Process__c> processes = new List<CSPOFA__Orchestration_Process__c>();
         CSPOFA__Orchestration_Process_Template__c template   = new CSPOFA__Orchestration_Process_Template__c();
        // Execute process for each new order
            template = [select Id, Name from CSPOFA__Orchestration_Process_Template__c where Name =:Label.CWP_New_Order_Workflow];
 
            for(csord__Subscription__c currentSub : lstSubs)
            {
                CSPOFA__Orchestration_Process__c newProcess = new CSPOFA__Orchestration_Process__c();
                newProcess.Name = Label.CWP_New_Order_Workflow;
                newProcess.CSPOFA__Process_Type__c = Label.NewProvide;
                newProcess.csordtelcoa__Subscription__c= currentSub.Id;
                newProcess.CSPOFA__Orchestration_Process_Template__c = template.id;
                processes.add(newProcess);
              
                
            }
            // Commit processes to the database
            insert processes;
    }
}