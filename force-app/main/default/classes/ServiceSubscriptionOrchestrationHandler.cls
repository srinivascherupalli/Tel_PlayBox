/**************************************************************
 Name: ServiceSubscriptionOrchestrationHandler 
 Description: Class to update create orchestration process for related Subscription->Services
Test Class : ServiceSubscriptionOrchestrationTest
Sr.No.    Developer Name        Date          Story Description
  1.      Shreya jaiswal          13/12/19        EDGE-125031
  2.      Pawan Devaliya          15/05/2020  EDGE-144704:Update status of subsription to Paid out for NGUC device and accesories for paid out scenario
  2.      Pawan Devaliya          15/05/2020  EDGE-163712:Orchestration should not be created when actionType on service is PaidOut or PayOut
**************************************************************/
global with sharing class ServiceSubscriptionOrchestrationHandler implements CSPOFA.ExecutionHandler{
/**************************************************************
  Name: process
  Parameters: List<SObject> steps
  Return Type: List<SObject>
  Description: Class to update create orchestration process for related Subscription->Services
*******************************************************************/
    public static List<SObject> process(List<SObject> steps){
        List<CSPOFA__Orchestration_Step__c> result = new List<CSPOFA__Orchestration_Step__c>();
        List<CSPOFA__Orchestration_Step__c> stepList= (List<CSPOFA__Orchestration_Step__c>)steps;
        List<Id> orderIds = new List<Id>();
        List<Id> orchesIds= new List<Id>();
        //EDGE-130760
        try{
        for(CSPOFA__Orchestration_Step__c step: stepList)
            orchesIds.add(step.CSPOFA__Orchestration_Process__c);
        
        system.debug(orchesIds);
        for(CSPOFA__Orchestration_Process__c  orch : [Select Order__c from CSPOFA__Orchestration_Process__c where Id IN:orchesIds])
            orderIds.add(orch.Order__c);
        system.debug(orderIds);
        //modified for EDGE-125031 : Queried legacy_subscription_c from subscription
        list<csord__Service__c> serviceSubsList =  [SELECT Id, Name, csord__Status__c, csord__Order__c,
                                                    csord__Subscription__c,Scenario_Type__c,
                                                    csord__Subscription__r.csordtelcoa__Replaced_Subscription__c,
                                                    csord__Subscription__r.csordtelcoa__Replaced_Subscription__r.csord__Order__c ,
                                                    csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.name,
                                                    csord__Subscription__r.toBeCancelled__c, csord__Subscription__r.legacy_subscription__c  FROM csord__Service__c 
                                                    WHERE (csord__Order__c IN: orderIds OR csord__Order__r.csord__Primary_Order__c IN: orderIds) AND (Action_Type__c!= 'PaidOut' AND Action_Type__c!= 'PayOut')];
                                                    //EDGE-144704 :added csord__Subscription__r.csord__Status__c = 'Paid Out'
                                                    //AND csord__Status__c != 'Connected' - removed this as part of EDGE-123619
        system.debug('serviceSubsList: '+serviceSubsList);
       /* List<Id> ReplacedsubscrpList =  new List<Id>();
        for(csord__Service__c sub : serviceSubsList){
            if(sub.csord__Subscription__r.csordtelcoa__Replaced_Subscription__c != null && sub.csord__Subscription__r.csordtelcoa__Replaced_Subscription__r.csord__Order__c == null)
                 ReplacedsubscrpList.add(sub.csord__Subscription__r.csordtelcoa__Replaced_Subscription__c);
              }
        list<csord__Service__c> ReplacedserviceSubsList =  [SELECT Id, Name, csord__Status__c, csord__Order__c,csord__Subscription__c,csord__Subscription__r.csordtelcoa__Replaced_Subscription__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.name  FROM csord__Service__c WHERE  csord__Subscription__c IN :ReplacedsubscrpList];
        serviceSubsList.addAll(ReplacedserviceSubsList);*/
        OrchestrationProcessCreator.createOchestrationProcess(serviceSubsList);
        for(CSPOFA__Orchestration_Step__c step : stepList){
            step.CSPOFA__Status__c = Label.Complete;step.CSPOFA__Completed_Date__c = Date.today();
            step.CSPOFA__Message__c = Label.Custom_Step_Succeeded;
            //result.add(step);
        }
        }catch(Exception ex){
            for (CSPOFA__Orchestration_Step__c step : stepList){

                                                                           step.CSPOFA__Status__c = Label.Error;

                                                                           step.CSPOFA__Completed_Date__c = Date.today();

                                                                           step.CSPOFA__Message__c = 'Exception: ' + ex.getMessage() + ' - ' + ex.getLineNumber();

                                                            }
        }
        return stepList;
    }
}