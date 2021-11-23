/*
* @Author : Rahul/Ritika
* @Date : 3 April 2019
* @Desc : Handler class in alignment with the Integration-Handler framework, for TM1 Eligibility Request for Transition
* @Jira Cloud : EDGE-66569
*/

public with sharing class TM1EligibilityCheckHandler extends IntegrationQueueHandler{

public TM1EligibilityCheckHandler() {
        super(TM1EligibilityCheckHandler.class.getName());
    }

public override void executeWork(List<String> params) {
    System.debug('Execute work:'+params.size());
        for(Integer i = 0; i < params.size(); i++){
        //future method for making callout to TM1-interface and adding the response details in Salesforce-records
        //Making a separate callout for every site, to limit the size of response-payload sent by TRAMAS.
        TM1EligibilityCheckService.sendEligibilityCheckRequest(params.get(i));
        }
    }

}