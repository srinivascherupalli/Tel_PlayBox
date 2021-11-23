/**************************************************************
 Name: ServiceUpdatesHandler
 Description: Class to update the status of Services 
			  and Subscriptions to 'Live' once the
              Orchestration Process is completely executed
**************************************************************/
global class ServiceUpdatesHandler implements CSPOFA.ExecutionHandler{
/**************************************************************
  Name: process
  Parameters: List<SObject> steps
  Return Type: List<SObject>
  Description: Method updates the status of Services 
			   and Subscriptions to 'Live' and returns the 
			   Orchestrator step with status as completed
*******************************************************************/
    public static List<SObject> process(List<SObject> steps){
        List<CSPOFA__Orchestration_Step__c> result = new List<CSPOFA__Orchestration_Step__c>();
        List<CSPOFA__Orchestration_Step__c> stepList= (List<CSPOFA__Orchestration_Step__c>)steps;
        Id subId = [select Id, CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c from CSPOFA__Orchestration_Step__c where Id IN:stepList].get(0).CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c;
        csord__Subscription__c sub = [select Id,Name, csord__Status__c from csord__Subscription__c where Id = :subId].get(0);
        List<csord__Service__c> lstServices = new List<csord__Service__c>();//[select Id, csord__Subscription__c from csord__Service__c where csord__Subscription__c = :sub.Id];
        
        for(csord__Service__c Ser : [select Id, csord__Status__c, csord__Subscription__c from csord__Service__c where csord__Subscription__c = :sub.Id]){
            Ser.csord__Status__c = Label.LIVE;
            lstServices.add(Ser);
        }
        update lstServices;
        sub.csord__Status__c = Label.LIVE;
        update sub;
        for(CSPOFA__Orchestration_Step__c step : stepList){
            step.CSPOFA__Status__c = Label.Complete;
            step.CSPOFA__Completed_Date__c=Date.today();
            step.CSPOFA__Message__c = Label.Custom_Step_Succeeded;
            result.add(step);
        }
        return result;
    }
}