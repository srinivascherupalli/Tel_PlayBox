/*************************************************************************************************
Name : InvoiceCalloutQueueableTest
Description : Test class for InvoiceCalloutQueueable
Author: Kalashree Borgaonkar
Story: EDGE-88307
***************************************************************************************************/

@isTest
public with sharing class InvoiceCalloutQueueableTest {
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
Method : createPayload
Author: Kalashree Borgaonkar
Story: EDGE-88307 
-------------------------------------------------------------------------------------*/
    @isTest
    public static void executeTest(){
        List<Invoice__c> invoiceList = [SELECT id FROM Invoice__c];
        List<id> invoiceIdList = new List<id>();
        String jobid=null;
        Test.startTest();
        if(!invoiceList.isEmpty()){
            for(Invoice__c invoice : invoiceList){
                invoiceIdList.add(invoice.id);
            }
            if(!invoiceIdList.isEmpty()){
                jobid = System.enqueueJob(new InvoiceCalloutQueueable(invoiceIdList) );
            }
        }
        Test.stopTest();
        System.assertEquals(jobid!=null,true,'Job enqueued');
    }
}