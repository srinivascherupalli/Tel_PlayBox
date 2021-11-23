/*
* @Author : Rahul/Manoj
* @Date : 5 Nov 2019
* @Desc : Handler class in alignment with the Integration-Handler framework, for TM1 Eligibility Request for Transition
* @Jira Cloud : 
*/

public with sharing class TramasBatchHandler extends IntegrationQueueHandler{

public TramasBatchHandler() {
        super(TramasBatchHandler.class.getName());
    }

public override void executeWork(List<String> params) {
    System.debug('Execute work:'+params.size());
        for(Integer i = 0; i < params.size(); i++){
        //future method for making callout to TM1-interface and adding the response details in Salesforce-records
        //Making a separate callout for every site, to limit the size of response-payload sent by TRAMAS.
        TramasBatchEligibilityCheckService.sendEligibilityCheckRequest(params.get(i));
        }
    }

}