/*************************************************************************************************
Name : InvoiceTriggerHandler
Description : Handler for InvoiceTrigger 
Author: Kalashree Borgaonkar
Story: EDGE-88307
***************************************************************************************************/
@isTest
public with sharing class InvoiceTriggerHandlerTest {
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
Method : makeCalloutTest
Author: Kalashree Borgaonkar
Story: EDGE-88307 
-------------------------------------------------------------------------------------*/
    @isTest
    public static void makeCalloutTest(){
        List<Invoice__c> invoiceList = [SELECT id FROM Invoice__c];
        List<String> invoiceIdList = new List<String>();
        for(Invoice__c invoice :invoiceList){
            invoiceIdList.add(invoice.id);
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockInvoiceCallout('success_Search'));
        InvoiceTriggerHandler.makeCallout(invoiceIdList);
        Test.stopTest();
        System.assertEquals(!invoiceList.isEmpty(),true,'Job enqueued');
    }
}