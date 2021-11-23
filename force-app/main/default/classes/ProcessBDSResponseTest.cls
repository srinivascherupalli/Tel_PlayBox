/******************************************************************
User Story   : DIGI-30060
Description  : To update remaining term and amount received from BDS for different subscriptions in Technical Orchestration Object
Class Name   : ProcessBDSResponseTest 
Created By   : Team Alexandria, Divakar Tangudu
Created On   : 12 October 2021
*******************************************************************/
@isTest
public class ProcessBDSResponseTest {
    static RestRequest request = New RestRequest();
    static RestResponse response = new RestResponse();
	
	@testSetup static void testDataSetUp()
    {
      list <Orchestration_Technical__c> orch_list=new list<Orchestration_Technical__c>(); 
	  
	  Orchestration_Technical__c orch_1=new Orchestration_Technical__c();
	  orch_1.Field_17__c='SN-000012305';
	  orch_1.Field_30__c='b5454454-a164-b480-9jsksd';
	  orch_list.add(orch_1);
	  
	  	  Orchestration_Technical__c orch_2=new Orchestration_Technical__c();
	  orch_2.Field_17__c='SN-000012315';
	  orch_1.Field_30__c='b5454454-a164-b480-9jsksd';
	  orch_list.add(orch_2);
	   
	  	  Orchestration_Technical__c orch_3=new Orchestration_Technical__c();
	  orch_3.Field_17__c='SN-000012325';
	  orch_1.Field_30__c='b5454454-a164-b480-9jsksd';
	  orch_list.add(orch_3);
	  
	  	  Orchestration_Technical__c orch_4=new Orchestration_Technical__c();
	  orch_4.Field_17__c='SN-000012335';
	  orch_1.Field_30__c='b5454454-a164-b480-9jsksd';
	  orch_list.add(orch_4);
	  
	  
	  	  	  Orchestration_Technical__c orch_5=new Orchestration_Technical__c();
	  orch_5.Field_17__c='SN-000012345';
	  orch_1.Field_30__c='b5454454-a164-b480-9jsksd';
	  orch_list.add(orch_5);
	  
	  	  	  Orchestration_Technical__c orch_6=new Orchestration_Technical__c();
	  orch_6.Field_17__c='SN-000012355';
	  orch_1.Field_30__c='b5454454-a164-b480-9jsksd';
	  orch_list.add(orch_6);
	  
	  	  	  	  Orchestration_Technical__c orch_7=new Orchestration_Technical__c();
	  orch_7.Field_17__c='SN-000012365';
	  orch_1.Field_30__c='b5454454-a164-b480-9jsksd';
	  orch_list.add(orch_7);
	  
  
	  insert orch_list;
	  
	  
    }
	
	static testMethod void testPOSTResponse() {
        request.requestURI = '/services/apexrest/chownSubUpdate'; 
        request.httpMethod = 'POST'; 
		String strBody = '{  "eventTimeStamp": "2019-06-30T05:00:16.000Z",  "billingAccounts": [    {      "billingAccountNumber": 700000000012,      "chargesDetails": [        {          "subscriptionId": "SN-000012305",          "instanceId": "c846491d-d696-cc07-912a-6f76109be6fc",          "durationUnit": "Months",          "durationRemaining": 15,          "chargeRemaining": 300,          "units": 1,          "taxTreatment": "TAX Exempt",          "status": "200",          "code": "200",          "message": "Success"        },        {          "subscriptionId": "SN-000012315",          "instanceId": "c846491d-d696-cc07-912a-6f76109be6fd",          "durationUnit": "Months",          "durationRemaining": 10,          "chargeRemaining": 200,          "units": 1,          "taxTreatment": "TAX Exempt",          "status": "200",          "code": "200",          "message": "Success"        },        {          "subscriptionId": "SN-000012325",          "instanceId": "c846491d-d696-cc07-912a-6f76109be6fy",          "status": "422",          "code": "422",          "message": "instanceId is Invalid"        }      ]    },    {      "billingAccountNumber": 700000000011,      "chargesDetails": [        {          "subscriptionId": "SN-000012335",          "instanceId": "c846491d-d696-cc07-912a-6f76109be6fc",          "durationUnit": "Months",          "durationRemaining": 10,          "chargeRemaining": 200,          "units": 1,          "taxTreatment": "TAX Exempt",          "status": "200",          "code": "200",          "message": "Success"        },        {          "subscriptionId": "SN-000012345",          "instanceId": "c846491d-d696-cc07-912a-6f76109be6fd",          "durationUnit": "Months",          "durationRemaining": 15,          "chargeRemaining": 300,          "units": 1,          "taxTreatment": "TAX Exempt",          "status": "200",          "code": "200",          "message": "Success"        },        {          "subscriptionId": "SN-000033811K",          "instanceId": "c846491d-d696-cc07-912a-6f76109be6fy",          "status": "422",          "code": "422",          "message": "SubscriptionId is Invalid"        },        {          "subscriptionId": "SN-000012355",          "instanceId": "c846491d-d696-cc07-912a-6f76109be6fd",          "durationUnit": "Months",          "durationRemaining": 0,          "chargeRemaining": 0,          "units": 1,          "taxTreatment": "TAX Exempt",          "status": "200",          "code": "200",          "message": "Success"        }      ]    },    {      "billingAccountNumber": 700000000013,      "chargesDetails": [        {          "subscriptionId": "SN-000033817",          "instanceId": "c846491d-d696-cc07-912a-6f76109be6fc",          "status": "500",          "code": "500",          "message": "Internal Server Error"        },        {          "subscriptionId": "SN-000033818F",          "instanceId": "c846491d-d696-cc07-912a-6f76109be6fd",          "durationUnit": "Months",          "durationRemaining": 15,          "units": 1,          "chargeRemaining": 300,          "taxTreatment": "TAX Exempt",          "status": "200",          "code": "200",          "Message": "Success"        },        {          "subscriptionId": "SN-000012365",          "instanceId": "c846491d-d696-cc07-912a-6f76109be6fy",          "status": "504",          "code": "504",          "Message": "Gateway Timeout"        }      ]    }  ]}';
        request.requestBody = Blob.valueOf(strBody);
		request.addHeader('Content-Type','application/json');
		request.addHeader('Correlation-Id','b5454454-a164-b480-9jsksd');
        Test.startTest();
        testDataSetUp();
			RestContext.request = request;
			RestContext.response = response; 
			ProcessBDSResponse.UpdateRemainingTermAmount();
        Test.stopTest();  
        system.assertNotEquals(null,response);
		system.debug('response::::'+string.valueOf(response.responseBody));
	}
	
		static testMethod void testPOSTResponseNull() {
        request.requestURI = '/services/apexrest/chownSubUpdate'; 
        request.httpMethod = 'POST'; 
		String strBody = '';
        request.requestBody = Blob.valueOf(strBody);
		request.addHeader('Content-Type','application/json');
		request.addHeader('Correlation-Id','b5454454-a164-b480-9jsksd');
        Test.startTest();
        testDataSetUp();
			RestContext.request = request;
			RestContext.response = response; 
			ProcessBDSResponse.UpdateRemainingTermAmount();
        Test.stopTest();  
        system.assertNotEquals(null,response);
		system.debug('response::::'+string.valueOf(response.responseBody));
	}
	

}