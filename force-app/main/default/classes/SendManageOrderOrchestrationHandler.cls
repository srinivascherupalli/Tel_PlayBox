/**************************************************************
 Name: SendManageOrderHandler
 Description: Class to send Managr order payload to AMDOCS when order orchestration process started
**************************************************************/

    global with sharing class SendManageOrderOrchestrationHandler implements CSPOFA.ExecutionHandler,CSPOFA.Calloutable{
        private List<Object> calloutResults;
        
        public Boolean performCallouts(List<SObject> data){
            List<CSPOFA__Orchestration_Step__c> stepList= (List<CSPOFA__Orchestration_Step__c>)data;
            List<String> orderIds = new List<String>();
            List<Id> orchesIds= new List<Id>();
            Boolean calloutsPerformed = false;
            
            for(CSPOFA__Orchestration_Step__c step: stepList){
                orchesIds.add(step.CSPOFA__Orchestration_Process__c);
            }
            
            for(CSPOFA__Orchestration_Process__c  orch : [Select Order__c from CSPOFA__Orchestration_Process__c where Id IN:orchesIds])
            orderIds.add(orch.Order__c);
            
            system.debug('orderIds'+orderIds);
            ManageOrderService.sendManageOrder(orderIds);
            calloutsPerformed = true;
            return calloutsPerformed;
        }
        
        public List<sObject> process(List<sObject> data){
            List<sObject> result = new List<sObject>();
            List<CSPOFA__Orchestration_Step__c> stepList= (List<CSPOFA__Orchestration_Step__c>)data;
            system.debug('stepList=='+stepList);
            //system.debug('stepList11=='+stepList[0].CSPOFA__Orchestration_Process__r.Order__c);
            //system.debug('stepList11=='+stepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c);
            
            for(CSPOFA__Orchestration_Step__c step : stepList){
                step.CSPOFA__Status__c = 'Complete';
                step.CSPOFA__Completed_Date__c=Date.today();
                step.CSPOFA__Message__c = 'Completed';
                result.add(step);
            }
            return result;
        }
    }