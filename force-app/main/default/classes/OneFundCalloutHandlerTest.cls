/*************************************************************************************************
Name : OneFundCalloutHandlerTest
Description : Test class for OneFundCalloutHandler
Author: Vamshi
Story: EDGE-124053
***************************************************************************************************/

@isTest
public with sharing class OneFundCalloutHandlerTest {
    /*----------------------------------------------------------------
Method : setupdata
Author: Vamshi
Story: EDGE-124053 
Descripton : Create Data
-------------------------------------------------------------------------------------*/
@testSetup 
public static void setupdata(){
    Billing_Account__c billingAcc = TestUtil.createBillingAccount('700000005112');
    insert billingAcc;
}

    /*----------------------------------------------------------------
Method : createPayload
Author: Vamshi
Story: EDGE-124053
-------------------------------------------------------------------------------------*/
    @isTest
    public static void createPayloadTest(){
        String invoiceNumber = '9900000182889';
        OneFundInvoiceRequestDTO requestDto = OneFundCalloutHandler.createPayload('700000005112',Long.valueOf(invoiceNumber));
        System.assertEquals(requestDto!=null,true, 'Request Payload created');
    }
    /*----------------------------------------------------------------
Method : calloutInvoiceByNumberSuccess
Author: Vamshi
Story: EDGE-124053
-------------------------------------------------------------------------------------*/
    @isTest
    public static void calloutInvoiceByNumberSuccess(){
        String invoiceNumber = '9900000182889';
        OneFundInvoiceRequestDTO requestDto = OneFundCalloutHandler.createPayload('700000005112',Long.valueOf(invoiceNumber));
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockOneFundInvoiceCallout('success_Search'));
      HttpResponse responseDto = OneFundCalloutHandler.calloutInvoiceByNumber(requestDto);
      //  system.debug('responseDto is -->'+responseDto);
        Test.stopTest();
       System.assertnotequals(null,responseDto);
 
        //System.assertEquals(responseDto.invoiceDetails!=null,true,'SuccessResponse');
        //System.assertnotEquals(responseDto.invoiceDetails!=null,true,'SuccessResponse');
    }
    /*----------------------------------------------------------------
Method : calloutInvoiceByNumberFail
Author: Vamshi
Story: EDGE-124053
-------------------------------------------------------------------------------------*/
    @isTest
    public static void calloutInvoiceByNumberFail(){
        String invoiceNumber = '9900000182889';
        OneFundInvoiceRequestDTO requestDto = OneFundCalloutHandler.createPayload('700000005112',Long.valueOf(invoiceNumber));
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockOneFundInvoiceCallout('success_Error'));
       HttpResponse responseDto =   OneFundCalloutHandler.calloutInvoiceByNumber(requestDto);
      // OneFundInvoiceResponseDTO responseDto =  OneFundCalloutHandler.calloutInvoiceByNumber(requestDto);
        Test.stopTest();
         //System.assertEquals(responseDto.errorMessage !=null,true,responseDto.errorMessage);
        System.assertNotEquals(responseDto,null);
       
      //  System.assertnotEquals(responseDto.errorMessage !=null,true,responseDto.errorMessage);
        
    }
    /*----------------------------------------------------------------
Method : calloutInvoiceByNumberFail503
Author: Vamshi
Story: EDGE-124053
-------------------------------------------------------------------------------------*/
    @isTest
    public static void calloutInvoiceByNumberFail503(){
        String invoiceNumber = '9900000182889';
        OneFundInvoiceRequestDTO requestDto = OneFundCalloutHandler.createPayload('700000005112',Long.valueOf(invoiceNumber));
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockOneFundInvoiceCallout('success_Error_503'));
     HttpResponse responseDto =   OneFundCalloutHandler.calloutInvoiceByNumber(requestDto);
        system.assertNotEquals(null, responseDto);
      //  OneFundInvoiceResponseDTO responseDto =  OneFundCalloutHandler.calloutInvoiceByNumber(requestDto);
        Test.stopTest();
      // System.assertEquals(responseDto ==null,true,'Failure Response');
    }
    
/*----------------------------------------------------------------
Method : calloutQLiSuccess
Author: Nagamani
Story: EDGE-116222
-------------------------------------------------------------------------------------*/
      @isTest
    public static void calloutQLiSuccess(){
        
          String invoiceNumber = '9900000182889';
        OneFundInvoiceRequestDTO requestDto = OneFundCalloutHandler.createPayload('700000005112',Long.valueOf(invoiceNumber));
         String jsonData = '{"customerAccountNumber":"700000006111","ariaInvoiceNumber":179598001,"chargeDetails":[{"chargeIdentifier":986960,"chargeType":"RecurringCharge","invoiceLineNumber":1}]}';
        EligibleRedemAmountRequestDTO reqdto = EligibleRedemAmountRequestDTO.parse(jsonData);
        system.debug('Callout request:'+reqdto);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockOneFundInvoiceCallout('success_Search2'));
      EligibleRedemptionAmountResponseDTO responsedto =  OneFundCalloutHandler.calloutQLI1(reqdto);
        system.assertNotEquals(null, responsedto);
        //system.debug('responseDto is -->'+responseDto);
        Test.stopTest();
    }
    
}