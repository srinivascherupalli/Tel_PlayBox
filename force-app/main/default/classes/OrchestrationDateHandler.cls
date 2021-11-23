global with sharing class OrchestrationDateHandler{
    global class UpdateOrderDates implements CSPOFA.ExecutionHandler{
        public List<SObject> process(List<SObject> steps){
            List<CSPOFA__Orchestration_Step__c> result = new List<CSPOFA__Orchestration_Step__c>();
            List<CSPOFA__Orchestration_Step__c> stepList= (List<CSPOFA__Orchestration_Step__c>)steps;
            List<Id> orderIds = new List<Id>();
            List<Id> orchesIds= new List<Id>();
            for(CSPOFA__Orchestration_Step__c step: stepList)
                orchesIds.add(step.CSPOFA__Orchestration_Process__c);
            
            system.debug(orchesIds);
            List<CSPOFA__Orchestration_Process__c> orchList = [Select Id, Name, Order__c, csordtelcoa__Subscription__c from CSPOFA__Orchestration_Process__c where Id IN:orchesIds];
            System.debug('orchList ::'+orchList);
            for(CSPOFA__Orchestration_Process__c  orch : orchList)
                orderIds.add(orch.Order__c);
            
            system.debug('orderIds ::'+orderIds);
            
            updateSubOrderDates(orderIds);
            for(CSPOFA__Orchestration_Step__c step : stepList){
                step.CSPOFA__Status__c = Label.Complete;
                step.CSPOFA__Completed_Date__c=Date.today();
                step.CSPOFA__Message__c = Label.Custom_Step_Succeeded;
                result.add(step);
            }
            return result;
        }
    
    public void updateSubOrderDates(List<Id> primaryOrderIds){
        if(!primaryOrderIds.isEmpty()){
            List<csord__Order__c> orders = [SELECT Id, Name, csord__Status2__c, csord__Primary_Order__c FROM csord__Order__c WHERE (Id IN: primaryOrderIds OR csord__Primary_Order__c IN: primaryOrderIds)];
            system.debug('all orders'+orders);
            Map<Id, csord__Order__c> primaryOrders = new Map<Id, csord__Order__c>();
            Map<Id, List<csord__Order__c>> secondaryOrders = new Map<Id, List<csord__Order__c>>();
            List<csord__Order__c> orderstoUpdate = new List<csord__Order__c>();
            
            for(csord__Order__c ord: orders){
				ord.csord__Start_Date__c=Date.today();
                
            }
            update orders;
            
		}
	}
    
    
    }

}