/*************************************************************************************************
Name : RepaymentCalloutHandlerTest
Description : Test class for RepaymentCalloutHandler
Author:  Jawahar M
Story: EDGE-108333
Modification History 
1. Gnana        25/05/2021      EDGE-215748 - Created test methods
***************************************************************************************************/
@isTest
public class RepaymentCalloutHandlerTest {
    /*----------------------------------------------------------------
    Method : setupdata
    Author: Jawahar M
    Story: EDGE-108333
    Descripton : Create Data
    -------------------------------------------------------------------------------------*/
  @testSetup 
  public static void setupdata(){
      Billing_Account__c billingAcc = TestUtil.createBillingAccount('700000005112');
      insert billingAcc;
  }
    
    /*----------------------------------------------------------------
    Method : createPayload
    Author: Jawahar M
    Story: EDGE-108333
    -------------------------------------------------------------------------------------*/
    @isTest
    public static void createPayloadTest(){
        
        String statementNumber = '9900000182889';
        Integer chargeId= 148442927;
        
        RepaymentRequestDTO requestDto = RepaymentCalloutHandler.createPayload(statementNumber,chargeId);
        System.assertEquals(requestDto!=null,true, 'Request Payload created');
    }
    
    /*----------------------------------------------------------------
    Method : calloutRepaymentDetailsSuccess
    Author: Jawahar M
    Story: EDGE-108333 
    -------------------------------------------------------------------------------------*/
    /*@isTest
    public static void calloutUsageDetailsSuccess(){
        
        String statementNumber = '9900000182889';
        Integer chargeId = 148442927;
        
        RepaymentRequestDTO requestDto = RepaymentCalloutHandler.createPayload(statementNumber,chargeId);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockRepaymentCallout('success_Search'));
        RepaymentResponseDTO responseDto =  RepaymentCalloutHandler.calloutUsageDetails(requestDto);
        system.debug('responseDto is -->'+responseDto);
        Test.stopTest();
        System.assertEquals(chargeId,148442927);
    }
    /*----------------------------------------------------------------
    Method : calloutUsageDetailsFail
    Author: Jawahar M
    Story: EDGE-108333 
    -------------------------------------------------------------------------------------*/
    /*@isTest
    public static void calloutUsageDetailsFail(){
        
        String statementNumber = '9900000182889';
        Integer chargeId = 148442927;
        
        RepaymentRequestDTO requestDto = RepaymentCalloutHandler.createPayload(statementNumber,chargeId);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockRepaymentCallout('success_Error'));
        RepaymentResponseDTO responseDto =  RepaymentCalloutHandler.calloutUsageDetails(requestDto);
        Test.stopTest();
        System.assertEquals(chargeId,148442927);
    }*/
    
    // Created as part of EDGE-215748
    @isTest
    public static void calloutRepaymentDetailsTest(){
        InvoiceChargeTypeRequestDTO requestDTO = new InvoiceChargeTypeRequestDTO();
        requestDTO.accountNumber = '7089666555';
        requestDTO.chargeId = 77778888;
        requestDTO.statementNumber = '9900000013687';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockUsageCallout('success_Search'));
        String response=RepaymentCalloutHandler.calloutRepaymentDetails(requestDTO);
        RepaymentCalloutHandler.logException('methodName', 'referenceNumber', 'correlationId', 'errorMessage','businessDescription');
        Test.stopTest();
        System.assertNotEquals(response,Null); 

    }
    
    // Created as part of EDGE-215748
    @isTest
    public static void calloutRepaymentDetailsException(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockUsageCallout('success_Error'));
        String response=RepaymentCalloutHandler.calloutRepaymentDetails(null);
        Test.stopTest();
        System.assertNotEquals(response,null); 
        
    }
}