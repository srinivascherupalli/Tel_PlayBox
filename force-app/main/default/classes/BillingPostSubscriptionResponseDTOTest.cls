@isTest
public with sharing class BillingPostSubscriptionResponseDTOTest {
	
    @istest static void testParse() {
    	String jsonstr = '{"code": 202,"status": 202,"message": "Success","correlationId": "328fdbb9-a4e5-4c4c-b72f-0be6b9422917","eventId": "123fbcbb9-a4e5-4c4c-b72f-0be6b9421233"}';
    	Test.startTest();
    	BillingPostSubscriptionResponseDTO billingPostSubscriptionResponse = BillingPostSubscriptionResponseDTO.parse(jsonstr);
    	Test.stopTest();
    	System.assertEquals('Success', billingPostSubscriptionResponse.message);
    	System.assertEquals('202', billingPostSubscriptionResponse.code);
    	System.assertEquals('123fbcbb9-a4e5-4c4c-b72f-0be6b9421233', billingPostSubscriptionResponse.eventId);
    	System.assertEquals('202', billingPostSubscriptionResponse.status);
    	System.assertEquals('328fdbb9-a4e5-4c4c-b72f-0be6b9422917', billingPostSubscriptionResponse.correlationId);
        
    	} 
    
}