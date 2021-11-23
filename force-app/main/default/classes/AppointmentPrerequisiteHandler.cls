/*************************************************************************************
    Name: AppointmentPrerequisiteHandler
    Description: This class implemented as part of EDGE-66239 and the class will Invokes the AppointmentPrerequisite callout
    ************************************************************************************/

    global with sharing class AppointmentPrerequisiteHandler implements CSPOFA.ExecutionHandler,CSPOFA.Calloutable {
        
        private List<Object> calloutResults;
        Boolean calloutsPerformed = false;  
        public List<String> calloutStatus = new List<String>();
        
        public Boolean performCallouts(List<SObject> data)
        {
            List<CSPOFA__Orchestration_Step__c> stepList= (List<CSPOFA__Orchestration_Step__c>)data;
            List<String> orderIds = new List<String>();
            List<Id> orchesIds= new List<Id>();
            
            for(CSPOFA__Orchestration_Step__c step: stepList)
            {
                orchesIds.add(step.CSPOFA__Orchestration_Process__c);
            }
            for(CSPOFA__Orchestration_Process__c  orch : [Select Order__c from CSPOFA__Orchestration_Process__c where Id IN:orchesIds])
            {
                orderIds.add(orch.Order__c);
            }            
            system.debug('orderIds'+orderIds);
            AppointmentServiceCallout.getSubscriptionIds(orderIds[0]);                
            calloutsPerformed = true;       
            return calloutsPerformed;
        }
        
        public List<sObject> process(List<sObject> data){
            List<Id> orchesIds= new List<Id>();
            List<sObject> result = new List<sObject>();
            List<Id> orderId = new List<Id>();
            List<CSPOFA__Orchestration_Step__c> stepList= (List<CSPOFA__Orchestration_Step__c>)data;
            system.debug('stepList=='+stepList);
            
            
            for(CSPOFA__Orchestration_Step__c step: stepList)
            {
                orchesIds.add(step.CSPOFA__Orchestration_Process__c);
            }
            for(CSPOFA__Orchestration_Process__c  orch : [Select Order__c from CSPOFA__Orchestration_Process__c where Id IN:orchesIds])
            {
                orderId.add(orch.Order__c);
            }   
            
            
            for(CSPOFA__Orchestration_Step__c step : stepList){
                
                if (calloutsPerformed != true)
                {
                    step.CSPOFA__Status__c = 'Error';
                    step.CSPOFA__Completed_Date__c=Date.today();
                    step.CSPOFA__Message__c = 'AppointmentPrerequisiteHandler Failed';
                    result.add(step);       
                }
                else
                {
                    step.CSPOFA__Status__c = 'Complete';
                    step.CSPOFA__Completed_Date__c=Date.today();
                    step.CSPOFA__Message__c = 'Completed';
                    result.add(step);
                    //OrderStatusHandler.changeOrderStatus(orderId);
                    system.debug('orderIdsprocess'+orderId);
                    system.debug('calloutStatus: '+calloutStatus);
                }
                
                
            }
            return result;
        }
        }