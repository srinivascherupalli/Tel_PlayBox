/***************************************************************************
Class Name:  ManageBillingCreateHandler_Test
Description: This class is Test Class for ManageBillingCreateHandler Class.
Author:      Vanita Mude
Version:     Created             Modified
             10/16/2017
****************************************************************************/

@isTest
public class ManageBillingCreateHandler_Test {

    static testMethod void executeWorkTestmethod(){
		List<EnvironmentVariable__c> envvariable = new List<EnvironmentVariable__c>();
		EnvironmentVariable__c envobj;
		envobj = new EnvironmentVariable__c(name = 'okapi_token_url', Value__c='https://test.com/org006/qa/v1/oauth/token');
		envvariable.add(envobj);
		envobj = new EnvironmentVariable__c(name = 'okapi_client_id', Value__c='test123cliid');
		envvariable.add(envobj);
		envobj = new EnvironmentVariable__c(name = 'okapi_client_secret', Value__c='1231test123');
		envvariable.add(envobj);
		insert envvariable;
        ManageBillingCreateHandler createHandler = new ManageBillingCreateHandler();
		csord__subscription__c subscription = new csord__subscription__c(name='subscription1', csord__Identification__c = 'asdasdsadsad');
		insert subscription;
		List<csord__subscription__c> subscriptionlst = new List<csord__subscription__c>();
		subscriptionlst.add(subscription);
		List<string> params = new List<string>();
		for(csord__subscription__c subs: subscriptionlst){
			string subid = ''+subs.id;
			params.add(subid);
        }
        test.starttest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorAPIUtil());
		createHandler.executeWork(params);
        test.stoptest();
		System.assert(subscription != null);
       } 
}