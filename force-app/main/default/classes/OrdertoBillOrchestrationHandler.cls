/**************************************************************
 Name: OrdertoBillOrchestrationHandler
 Description: Class to send Bill to order payload to BDS/ARIA when order orchestration process started
**************************************************************/

    global with sharing class OrdertoBillOrchestrationHandler implements CSPOFA.ExecutionHandler,CSPOFA.Calloutable{
        private List<Object> calloutResults;
        
        public Boolean performCallouts(List<SObject> data){
            List<CSPOFA__Orchestration_Step__c> stepList= (List<CSPOFA__Orchestration_Step__c>)data;
			List<String> subscripIdList = new List<String>();
            List<Id> orchesIds= new List<Id>();
            Boolean calloutsPerformed = false;
			
			List<Id> ordList= new List<Id>();
			List<csord__Subscription__c> subList= new List<csord__Subscription__c>();
            Integer provisionedSubCount = 0;
			Boolean isIncludeSolution = true;
			 
            for(CSPOFA__Orchestration_Step__c step: stepList){
                orchesIds.add(step.CSPOFA__Orchestration_Process__c);
            }
            
            for(CSPOFA__Orchestration_Process__c  orch : [Select csordtelcoa__Subscription__c from CSPOFA__Orchestration_Process__c where Id IN:orchesIds])
			subscripIdList.add(orch.csordtelcoa__Subscription__c);
			//Please add EDGE-271 interface code here
			/* Commenting below change as that is redundant in the actual payload generation code
			// Start change for EDGE-87688
			if(subscripIdList != null)
			{
				csord__Subscription__c sub =[select id,csord__Order__c,csord__Status__c from csord__Subscription__c where id IN:subscripIdList LIMIT 1];
                ordList.add(sub.csord__Order__c);
				if(ordList!= null){
				subList = [select id,csord__Order__c,csord__Status__c from csord__Subscription__c where csord__Order__c IN:ordList ];}
			}
			
			for(csord__Subscription__c sub :subList){
			if(sub.csord__Status__c =='Provisioned')
				provisionedSubCount += 1;
			}
			
			if(provisionedSubCount == 1){
				isIncludeSolution = true;
			}
			// End change for EDGE-87688
			*/
            BillingOrderManager.triggerPostSubscription(subscripIdList,isIncludeSolution);
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