/**************************************************************
 Name: CallMSISDNFromAppointment
 Description: Class to update create orchestration process for MSISDN Reservation->Order
**************************************************************/
global with sharing class CallMSISDNFromAppointment implements CSPOFA.ExecutionHandler{
/**************************************************************
  Name: process
  Parameters: List<SObject> steps
  Return Type: List<SObject>
  Description: Class to update create orchestration process for related Subscription->Services
*******************************************************************/
    public List<SObject> process(List<SObject> steps){
        List<CSPOFA__Orchestration_Step__c> result = new List<CSPOFA__Orchestration_Step__c>();
        List<CSPOFA__Orchestration_Step__c> stepList= (List<CSPOFA__Orchestration_Step__c>)steps;
        List<Id> orderIds = new List<Id>();
        List<Id> orchesIds= new List<Id>();
        for(CSPOFA__Orchestration_Step__c step: stepList)
            orchesIds.add(step.CSPOFA__Orchestration_Process__c);
        
        system.debug(orchesIds);
        for(CSPOFA__Orchestration_Process__c  orch : [Select Order__c from CSPOFA__Orchestration_Process__c where Id IN:orchesIds])
            orderIds.add(orch.Order__c);
        system.debug(orderIds);
        OrchestrationProcessCreator.createMSISDNOchestrationProcess(orderIds);
        for(CSPOFA__Orchestration_Step__c step : stepList){
            step.CSPOFA__Status__c = Label.Complete;
            step.CSPOFA__Completed_Date__c=Date.today();
            step.CSPOFA__Message__c = Label.Custom_Step_Succeeded;
            result.add(step);
        }
        return result;
    }
}