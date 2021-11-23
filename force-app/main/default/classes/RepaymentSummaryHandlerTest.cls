/*************************************************************************************************
Name : RepaymentSummaryHandlerTest
Description : Test class for RepaymentSummaryHandler
Author: Jawahar M
Story: EDGE-108333
Modification History 
1. Gnana        25/05/2021      EDGE-215748 - Created test methods
***************************************************************************************************/
@isTest 
public class RepaymentSummaryHandlerTest {
  /*----------------------------------------------------------------
    Method : setupdata
    Author: Jawahar M
    Story: EDGE-108333
    Descripton : Create Data
    -------------------------------------------------------------------------------------*/
    @testSetup 
    public static void setupdata(){
        Invoice__c invoice = TestUtil.createInvoice('700000002978','9900000202350');
        insert invoice;
        Invoice_Line_Item__c invoiceLineItem = new Invoice_Line_Item__c();
        invoiceLineItem.Invoice__c = invoice.id;
        invoiceLineItem.Charge_Id__c='4353';
        invoiceLineItem.Plan_Instance_Details_List__c = '14485289,14485293,14485295';
        invoiceLineItem.Tax_Inclusive__c = 0;
        invoiceLineItem.Tax_Rate__c = 0;
        /*** START OF EDGE-125016 ***/
        invoiceLineItem.Invoice_Transaction_ID__c=3452342;
        /*** END OF EDGE-125016 ***/
        invoiceLineItem.Invoice_Line_Number__c =34;
        insert invoiceLineItem;
        
        Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        testAccount.Customer_Status__c = 'ACTIVE';
        insert testAccount;
         Billing_Account__c billAccount = new Billing_Account__c(Status__c = 'Created', Include_related_Customer_Account_Contact__c=false, 
                                                                Account__c=testAccount.Id, Billing_Account_Number__c='992216148101',Balance_Amount__c=100.00);
                                                               
        insert billAccount;
    }
    
    /*----------------------------------------------------------------
    Method : getRepaymentResponseDetailsSuccess
    Author: Jawahar M
    Story: EDGE-108333 
    -------------------------------------------------------------------------------------*/
    @isTest
    public static void getRepaymentResponseDetailsSuccess(){
		 Billing_Account__c billAccount = [Select Billing_Account_Number__c from Billing_Account__c LIMIT 1 ];
         Invoice__c testInvoice = [Select Name from Invoice__c LIMIT 1];
         Test.setMock(HttpCalloutMock.class, new MockRepaymentCallout('success_Search'));
         Test.startTest();
         String calloutRes = RepaymentSummaryHandler.getRepaymentResponseDetails(77778888,'9900000013687','555666444','RepaymentDetailsHandler');
         Test.stopTest();
         System.assertNotEquals(calloutRes, null);
    }
    
    /*----------------------------------------------------------------
    Method : getRepaymentResponseDetailsFail
    Author: Jawahar M
    Story: EDGE-108333 
    -------------------------------------------------------------------------------------*/
    @isTest
    public static void getRepaymentResponseDetailsFail(){
        Billing_Account__c billAccount = [Select Billing_Account_Number__c from Billing_Account__c LIMIT 1 ];
         Invoice__c testInvoice = [Select Name from Invoice__c LIMIT 1];
         String req =  '{"chargeId":77778888,"statementNumber":9900000013687,"accountNumber":555666444}';
         Test.setMock(HttpCalloutMock.class, new MockRepaymentCallout('success_Error'));
         Test.startTest();
         String calloutRes = RepaymentSummaryHandler.getRepaymentResponseDetails(77778888,'9900000013687','555666444','RepaymentDetailsHandler');
         Test.stopTest();
         System.assertNotEquals(calloutRes, null);
    }
    
    /*----------------------------------------------------------------
    Method : getRepaymentResponseDetailsTest
    Author: Gnana
    Story: EDGE-215748 
    -------------------------------------------------------------------------------------*/
    @isTest
    public static void getRepaymentResponseDetailsTest(){
        Invoice_Line_Item__c invoiceRecord = [select id,Invoice__c,Plan_Instance_Details_List__c,Tax_Inclusive__c,Tax_Rate__c from Invoice_Line_Item__c];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockRepaymentCallout('success_Error_503'));
        //Map<Integer,String> respMap =  RepaymentSummaryHandler.getRepaymentResponseDetails(invoiceRecord.id);
        /*for(String res : respMap.values()){
            system.assertEquals('', res); 
        }*/
        Test.stopTest();
    }
}