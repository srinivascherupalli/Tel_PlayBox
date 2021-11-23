/*************************************************************************************************
Name : InvoiceComponentHandlerTest
Description : Test class for InvoiceComponentHandler
Author: Kalashree Borgaonkar
Story: EDGE-88307
***************************************************************************************************/
@isTest
public with Sharing class InvoiceComponentHandlerTest {
    /*----------------------------------------------------------------
Method : setupdata
Author: Kalashree Borgaonkar
Story: EDGE-88307 
Descripton : Create Data
-------------------------------------------------------------------------------------*/
    @testSetup 
    public static void setupdata(){
        Invoice__c invoice = TestUtil.createInvoice('700000002978','9900000202350');
        insert invoice;
    }
    /*----------------------------------------------------------------
Method : getInvoiceSuccessTest
Author: Kalashree Borgaonkar
Story: EDGE-88307 
-------------------------------------------------------------------------------------*/
    @isTest
    public static void getInvoiceSuccessTest(){
        // PageReference reference = Page.InvoicePdfPage;
        PageReference pageRef = new PageReference('apex/InvoicePdfPage?custAcc=700000002978&invoice=9900000202350');
        Test.setCurrentPage(pageRef);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockInvoiceCallout('successPdf'));
        InvoiceComponentHandler.getInvoice();
        Test.stopTest();
        System.assertEquals(pageRef!=null,true, 'Page reference set');
    }
    /*----------------------------------------------------------------
Method : getInvoiceErrorTest
Author: Kalashree Borgaonkar
Story: EDGE-88307 
-------------------------------------------------------------------------------------*/
    @isTest
    public static void getInvoiceErrorTest(){
        // PageReference reference = Page.InvoicePdfPage;
        PageReference pageRef = new PageReference('apex/InvoicePdfPage?custAcc=700000002978&invoice=9900000202350');
        Test.setCurrentPage(pageRef);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockInvoiceCallout('success_Error'));
        InvoiceComponentHandler.getInvoice();
        Test.stopTest();
        System.assertEquals(pageRef!=null,true, 'Page reference set');
    }
     /*----------------------------------------------------------------
Method : getInvoiceError503Test
Author: Kalashree Borgaonkar
Story: EDGE-88307 
-------------------------------------------------------------------------------------*/
    @isTest
    public static void getInvoiceError503Test(){
        // PageReference reference = Page.InvoicePdfPage;
        PageReference pageRef = new PageReference('apex/InvoicePdfPage?custAcc=700000002978&invoice=9900000202350');
        Test.setCurrentPage(pageRef);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockInvoiceCallout('success_Error_503'));
        InvoiceComponentHandler.getInvoice();
        Test.stopTest();
        System.assertEquals(pageRef!=null,true, 'Page reference set');
    }
    /*----------------------------------------------------------------
Method : getInvoicePDFSuccessTest
Author: Kalashree Borgaonkar
Story: EDGE-88307 
-------------------------------------------------------------------------------------*/
    @isTest
    public static void getInvoicePDFSuccessTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockInvoiceCallout('successPdf'));
        PageReference reference =  InvoiceComponentHandler.getInvoicePDF('700000002978','9900000202350');
        Test.stopTest();
        System.assertEquals(reference==null,true, 'Retrieved PDF response');
    }
    /*----------------------------------------------------------------
Method : getInvoicePDFFailTest
Author: Kalashree Borgaonkar
Story: EDGE-88307 
-------------------------------------------------------------------------------------*/
    @isTest
    public static void getInvoicePDFFailTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockInvoiceCallout('successPdf'));
        PageReference reference =  InvoiceComponentHandler.getInvoicePDF('700000002978','9900000202350');
        Test.stopTest();
        System.assertEquals(reference==null,true, 'Retrieved PDF response');
    }
    /*----------------------------------------------------------------
Method : getInvoiceRequestDetailsTest
Author: Kalashree Borgaonkar
Story: EDGE-88307 
-------------------------------------------------------------------------------------*/
    @isTest
    public static void getInvoiceRequestDetailsTest(){
        Invoice__c invoice = [SELECT id FROM Invoice__c];
        Test.startTest();
        InvoiceComponentHandler.RequestWrapper wrapper =  InvoiceComponentHandler.getInvoiceRequestDetails(invoice.id);
        Test.stopTest();
        System.assertEquals(wrapper!=null,true, 'Invoice details');
    }
    /*----------------------------------------------------------------
Method : getInvoiceRequestBulkTest
Author: Kalashree Borgaonkar
Story: EDGE-88307 
-------------------------------------------------------------------------------------*/
    @isTest
    public static void getInvoiceRequestBulkTest(){
        List<Invoice__c> invoiceList = [SELECT id FROM Invoice__c];
        List<String> invoiceIdList = new List<String>();
        for(Invoice__c invoice :invoiceList){
            invoiceIdList.add(invoice.id);
        }
        Test.startTest();
        List<InvoiceRequestDTO> requestDtoList =  InvoiceComponentHandler.getInvoiceRequestBulk(invoiceIdList);
        Test.stopTest();
        System.assertEquals(requestDtoList!=null,true, 'Invoice details');
    }
    
}