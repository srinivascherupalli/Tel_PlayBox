/*************************************************************************************************
Name : PublishPricingEvent 
Description : EDGE-169456 :  One fund Redemption
TestClass : PublishPricingEventTest
Created by: Jagadeswary
*************************************************************************************************
Change.No.      Developer Name          Date            Story Description  
1.              Pawan           29-01-2021       EDGE-199005 : Step should be updated to waiting instead of Complete, to wait for the response from PricingMS  
2.              Shashidhar Kumar    10-08-2021       DIGI-2161 : Enhance order orchestration process steps to trigger Pricing MS requests only for subscriptions that has any promotion/discount/redemption applied
==================================================================================================*/

global with sharing class PublishPricingEvent extends Orchestration_AbstractStepHandler{

    Map<String,List<csord__Service__c>> subServiceMap = new Map<String,List<csord__Service__c>>();//DIGI-2161
    //Orch step execution method to publish events for pricing request to Microservices
    public override List<SObject> process(List<SObject> steps) {
        Map<Id, Id> subsToStepMap = new Map<Id, Id>();
        Logger2 logger = Logger2.getLogger('PricingMsEvents');


        List<CSPOFA__Orchestration_Step__c> stepList = new List<CSPOFA__Orchestration_Step__c>();
        Map<String,boolean> subIgnorePricingEvent  = new  Map<String,boolean>();//DIGI-2161
        stepList = (List<CSPOFA__Orchestration_Step__c>) getStepListData(steps);//DIGI-2161

        for (CSPOFA__Orchestration_Step__c step : stepList) {
            if (step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c != null) {
                subscriptionIds.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);
                subsToStepMap.put(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c, step.Id);
            }
        }
        //Retrieve all subscription ids and map subscription to orchestration step -to use later
        //DIGI-2161 start
        
        for(Id subscriptionId: subscriptionIds){
            subIgnorePricingEvent.put(subscriptionId,true);
			List<csord__service__c> serList= subServiceMap.get(subscriptionId);
			for(csord__service__c serv :serList){
				//DIGI-16904 : AM - DP&A | TED-423 Promotional Period Discount : Below ContainsDiscount__c Condition Added :Aman Gupta
                if((serv.Redemption_Amount__c != null && serv.Redemption_Amount__c != 0) || serv.ContainsDiscount__c == true){
					subIgnorePricingEvent.put(subscriptionId,false);
					break;
				}
			}
			if(subIgnorePricingEvent.get(subscriptionId)==true){
			  stepResults.put(subsToStepMap.get(subscriptionId), new stepResult('Success - No update required.', OrchestratorConstants.OrchestratorStep.Complete));
			}else{//DIGI-2161 end
				String corelationId = IntegrationRecordHandlerUtil.getCorrelationId();
				Boolean containsTieredCharges = false;
				PriceScheduleEvent__e priceSchEvent = new PriceScheduleEvent__e(eventType__c = 'Request', CorrelationId__c = corelationId,subscriptionId__c = subscriptionId, containsTieredCharges__c = containsTieredCharges);
				eventsToPublish.add(priceSchEvent);  
			}
		}
        //Publish events to Micro services with subscription id
        Database.SaveResult[] result = EventBus.publish(eventsToPublish);
        for(Integer i=0;i<eventsToPublish.size();i++){
            Database.SaveResult sr = result[i];
            if (sr.isSuccess()) {
                logger.logMessages(JSON.serialize(eventsToPublish, true), '', '', '', '', '', false, false,null,'','','');
                logger.exitLogger();
                Id stepId = subsToStepMap.get(String.valueOf(eventsToPublish[i].get('subscriptionId__c')));
                stepResults.put(stepId, new stepResult('Success - events got published.', OrchestratorConstants.OrchestratorStep.Waiting));
            }else {
                System.debug('Error:  ' + sr.getId());
                Id stepId = subsToStepMap.get(String.valueOf(eventsToPublish[i].get('subscriptionId__c')));
                stepResults.put(stepId, new stepResult('Error: ' + sr.getErrors() , OrchestratorConstants.OrchestratorStep.Error));
            }
        }
        //Cumulate step results and return to process for step status update
        return processStepResults((List<CSPOFA__Orchestration_Step__c>) steps, stepResults);
	}
/*
    DIGI-2161
    To get Orchestration steps for the subscription
*/
	private List<CSPOFA__Orchestration_Step__c> getStepListData(List<sObject> steps) {
        //Fetching more fields from the query
        List<CSPOFA__Orchestration_Step__c> stepList = [
            SELECT ID, Name, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, JSON__c, CSPOFA__Message__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c, CSPOFA__Orchestration_Process__r.Order__r.skipFulfillment__c
            FROM CSPOFA__Orchestration_Step__c
            WHERE Id IN :steps
        ];
        Set<String> stepIds = new Set<String>();
        for (CSPOFA__Orchestration_Step__c step : stepList) {
            //Get orders related to the steps
            if (step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c != null) {
                subscriptionIds.add(step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c);
            }
        }
        for(csord__Service__c serv : [Select id, Redemption_Amount__c,csord__Subscription__c,ContainsDiscount__c from csord__Service__c where csord__Subscription__c IN:subscriptionIds ]){
            if (subServiceMap.containsKey(serv.csord__Subscription__c)) {
				subServiceMap.get(serv.csord__Subscription__c).add(serv);
			} else {
				subServiceMap.put(serv.csord__Subscription__c, new List<csord__service__c>{ serv });
			}
        }
    
        //Returning the step list
        return stepList;
    }

}