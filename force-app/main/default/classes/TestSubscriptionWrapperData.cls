/******************************************************************************************************************************
Class Name : TestSubscriptionWrapperData
===============================================================================================================================
Sr.No.  Developer           Date          Story Description                Sprint
1.      Aman Soni           19/03/2021    EDGE-199911(New Class)           21.04
*******************************************************************************************************************************/
@isTest
private class TestSubscriptionWrapperData{

	@testSetup static void setup(){
		Billing_Account__c billingAcount = new Billing_Account__c();
		billingAcount.Billing_Account_Number__c = '432276511234';
		insert billingAcount;

		csord__Subscription__c subscription = new csord__Subscription__c();
		subscription.csordtelcoa__Subscription_Number__c = '12345682';
		subscription.Name = 'Test Subscription';
		subscription.serviceMSISDN__c = '4432465890';
		subscription.Billing_Account__c = billingAcount.id;
		subscription.Nickname__c = 'TestNickname';
		subscription.csord__Identification__c = 'Identification_0';
		insert subscription;	
	}

	@isTest static void testMethod1(){
		Test.startTest();
		csord__Subscription__c subscription = [select Id,Name,Nickname__c,Billing_Account__r.Billing_Account_Number__c,serviceMSISDN__c,csordtelcoa__Subscription_Number__c from csord__Subscription__c limit 1];
		SubscriptionWrapperData subWrapObj = new SubscriptionWrapperData();
		if(subscription != null){
			subWrapObj.subscriptionName = subscription.Name;
			subWrapObj.subscriptionNumber = subscription.csordtelcoa__Subscription_Number__c;
			subWrapObj.serviceID = subscription.serviceMSISDN__c;
			subWrapObj.billingAccNumber = subscription.Billing_Account__r.Billing_Account_Number__c;
			subWrapObj.nickname =subscription.Nickname__c;
			subWrapObj.id = subscription.Id;
		}		
		system.assertEquals(subWrapObj.serviceID, subscription.serviceMSISDN__c,'Mobile Number has matched successfully');
		Test.stopTest();
	}
}