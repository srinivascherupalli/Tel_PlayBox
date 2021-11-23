/*************************************************************************************************
Name : UsageCalloutHandlerTest
Description : Test class for UsageCalloutHandler
Author: Sasidhar Devarapalli
Story: EDGE-108332
***************************************************************************************************/
@isTest
public class UsageCalloutHandlerTest {
    /*----------------------------------------------------------------
    Method : setupdata
    Author: Sasidhar Devarapalli
    Story: EDGE-108332 
    Descripton : Create Data
    -------------------------------------------------------------------------------------*/
	@testSetup 
	public static void setupdata(){ 
    	Billing_Account__c billingAcc = TestUtil.createBillingAccount('700000005112');
    	insert billingAcc;
	}
    
    /*----------------------------------------------------------------
    Method : calloutUsageDetailsSuccess
    Author: Sasidhar Devarapalli
    Story: EDGE-108332 
    -------------------------------------------------------------------------------------*/
    @isTest
    public static void calloutUsageDetailsSuccess(){
        String json = '{"usageTypeCode":"7001","statementNumber":"9900000182889","invoiceNumber":"148442927","accountNumber":"700000005112","invoicePeriod":"01 Jun 19 - 23 Jun 19","planInstanceDetailsList":[14485289,14485293,14485295],"taxInclusive":0,"taxRate":0}';
        UsageRequestDTO requestDTO = UsageRequestDTO.parse(json);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockUsageCallout('success_Search'));
        String responseDto =  UsageCalloutHandler.calloutUsageDetails(requestDto);
        system.debug('responseDto is -->'+responseDto);
        Test.stopTest();
        System.assertNotEquals(null,json) ;
    }
    /*----------------------------------------------------------------
    Method : calloutUsageDetailsFail
    Author: Sasidhar Devarapalli
    Story: EDGE-108332 
    -------------------------------------------------------------------------------------*/
    @isTest
    public static void calloutUsageDetailsFail(){
        String json = '{"usageTypeCode":"7001","statementNumber":"9900000182889","invoiceNumber":"148442927","accountNumber":"700000005112","invoicePeriod":"01 Jun 19 - 23 Jun 19","planInstanceDetailsList":[14485289,14485293,14485295],"taxInclusive":0,"taxRate":0}';
        UsageRequestDTO requestDTO = UsageRequestDTO.parse(json);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockUsageCallout('success_Error'));
        String responseDto =  UsageCalloutHandler.calloutUsageDetails(requestDto);
        Test.stopTest();
        System.assertNotEquals(null,json);
    }
     @isTest
    public static void calloutInvoiceDetailsFail(){
        String json = '{"chargeId":"7001","statementNumber":"9900000182889"}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockUsageCallout('success_Error'));
        Map<Integer,String> response=UsageCalloutHandler.calloutInvoiceDetails(json,'RecurringChargeHandler');
        Test.stopTest();
        System.assertEquals(false,response.containsKey(200));        
    }
    
    
      @isTest
    public static void calloutInvoiceDetailsPass(){
        String json = '{"chargeId":"7001","statementNumber":"9900000182889"}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockUsageCallout('success_Search'));
        Map<Integer,String> response=UsageCalloutHandler.calloutInvoiceDetails(json,'RecurringChargeHandler');
        Test.stopTest();
        System.assertEquals(true,response.containsKey(200));        
        
    }
    @isTest
    public static void calloutInvoiceOrderDetailsFail(){
        String json = '{"chargeId":"7001","statementNumber":"9900000182889"}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockUsageCallout('success_Error'));
        Map<Integer,String> response=UsageCalloutHandler.calloutInvoiceDetails(json,'InvoiceOrderHandler');
        Test.stopTest();
        System.assertEquals(false,response.containsKey(200));        
    }
    
    
      @isTest
    public static void calloutInvoiceOrderDetailsPass(){
        String json = '{"chargeId":"7001","statementNumber":"9900000182889"}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockUsageCallout('success_Search'));
        Map<Integer,String> response=UsageCalloutHandler.calloutInvoiceDetails(json,'InvoiceOrderHandler');
        Test.stopTest();
        System.assertEquals(true,response.containsKey(200));        
        
    }
   

    
}