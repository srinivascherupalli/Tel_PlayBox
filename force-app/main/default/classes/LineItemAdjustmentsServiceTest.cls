/*----------------------------------------------------------------------------
EDGE        -88294
Class Name  -LineItemAdjustmentsServiceTest
Description -Test class for LineItemAdjustmentsService  class .
Author      -Dheeraj Bhatt
-------------------------------------------------------------------------------*/    
@IsTest (seeAllData=false)
public class LineItemAdjustmentsServiceTest {
/*----------------------------------------------------------------------------
EDGE        -88294
Method Name -testSetup
Description -Test Data creation for test class.
Author      -Dheeraj Bhatt
-------------------------------------------------------------------------------*/
    @TestSetup public static void testSetup(){
        account acc=TestDataFactory.generateAccount();
       
        contact con=testDataFactory.generateContact( 'Test_FirstName', acc.id,'Active','Test_LastName',system.today(),'Mobile');
        insert con;
        
        Billing_Account__c billingAccount=TestDataFactory.generateBillingAccount('700000335518','Created',acc.id, con.id);
        insert billingAccount;
    }
    /*---------------------------------------------------------------------------------------------
EDGE        -88294
Method Name -lineItemAdjustmentsRequestSuccessTest
Description -Test method to cover success test case in LineItemAdjustmentsService class 
              lineItemAdjustmentsRequest method .
Author      -Dheeraj Bhatt
-----------------------------------------------------------------------------------------------------*/
    public TestMethod static void lineItemAdjustmentsRequestSuccessTest(){
        String reqBody='{"productId":null,"instanceId":"a8g5O00000000HFQAY","gstIndicator":null,"description":"test","currencyCode":"AUD","comments":"testDescription","billingAccountNumber":700000335518,"ariaInvoiceNumber":"test12345","amount":null,"adjustmentType":"Line Item Credit","AdjustmentTarget":{"invoiceItem":[{"reasonCode":"3001","invoiceTransactionId":12345678901234,"invoiceLineNumber":null,"creditAmount":null,"chargeType":"service"}]}}';
        String billingAccountId=[SELECT id from Billing_Account__c WHERE Billing_Account_Number__c ='700000335518' LIMIT 1].id;
       Test.startTest();
        Test.setMock(HttpCalloutMock.class, new LineItemAdjustmentsServiceMock(200));
        HttpResponse response = LineItemAdjustmentsService.lineItemAdjustmentsRequest(reqBody, 'LineItemAdjustmentsRequest', billingAccountId);
        Test.stopTest(); 
        system.assertEquals(200, response.getstatuscode());
    }
/*---------------------------------------------------------------------------------------------
EDGE        -88294
Method Name -lineItemAdjustmentsRequestFailureTest
Description -Test method to cover Failure test case in LineItemAdjustmentsService class 
              lineItemAdjustmentsRequest method .
Author      -Dheeraj Bhatt
-----------------------------------------------------------------------------------------------------*/
        public TestMethod static void lineItemAdjustmentsRequestFailureTest(){
        String reqBody='{"productId":null,"instanceId":"a8g5O00000000HFQAY","gstIndicator":null,"description":"test","currencyCode":"AUD","comments":"testDescription","billingAccountNumber":700000335518,"ariaInvoiceNumber":"test12345","amount":null,"adjustmentType":"Line Item Credit","AdjustmentTarget":{"invoiceItem":[{"reasonCode":"3001","invoiceTransactionId":12345678901234,"invoiceLineNumber":null,"creditAmount":null,"chargeType":"service"}]}}';
        String billingAccountId=[SELECT id from Billing_Account__c WHERE Billing_Account_Number__c ='700000335518' LIMIT 1].id;
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new LineItemAdjustmentsServiceMock(422));
       HttpResponse response= LineItemAdjustmentsService.lineItemAdjustmentsRequest(reqBody, 'LineItemAdjustmentsRequest', billingAccountId);
            Test.stopTest();
            system.assertEquals(422, response.getstatuscode());
    }
      /*---------------------------------------------------------------------------------------------
EDGE        -88294
Method Name -doSubmitExceptionTest2
Description -Test method to cover Exception test case in LineItemAdjustmentsService class 
              lineItemAdjustmentsRequest method .
Author      -Dheeraj Bhatt
-----------------------------------------------------------------------------------------------------*/
    @IsTest public static void lineItemAdjustmentsRequestExceptionTest(){
        String reqBody='{"productId":null,"instanceId":"a8g5O00000000HFQAY","gstIndicator":null,"description":"test","currencyCode":"AUD","comments":"testDescription","billingAccountNumber":700000335518,"ariaInvoiceNumber":"test12345","amount":null,"adjustmentType":"Line Item Credit","AdjustmentTarget":{"invoiceItem":[{"reasonCode":"3001","invoiceTransactionId":12345678901234,"invoiceLineNumber":null,"creditAmount":null,"chargeType":"service"}]}}';
        String billingAccountId=[SELECT id from Billing_Account__c WHERE Billing_Account_Number__c ='700000335518' LIMIT 1].id;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new LineItemAdjustmentsServiceMock(422));
         HttpResponse response=LineItemAdjustmentsService.lineItemAdjustmentsRequest(reqBody, '', billingAccountId);
        Test.stopTest();
        system.assertEquals(null, response);
    }
}