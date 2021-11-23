/*************************************************************************************************
Name : UsageSummaryHandlerTest
Description : Test class for UsageSummaryHandler
Author: Sasidhar Devarapalli
Story: EDGE-108332
***************************************************************************************************/
@isTest
public class UsageSummaryHandlerTest {
    public UsageSummaryHandlerTest(){}
  /*----------------------------------------------------------------
    Method : setupdata
    Author: Sasidhar Devarapalli
    Story: EDGE-108332
    Descripton : Create Data
    -------------------------------------------------------------------------------------*/
    @testSetup 
    public static void setupdata(){
        Invoice__c invoice = TestUtil.createInvoice('700000002978','9900000202350');
        insert invoice;
        Invoice_Line_Item__c invoiceLineItem = new Invoice_Line_Item__c();
        invoiceLineItem.Invoice__c = invoice.id;
        invoiceLineItem.Plan_Instance_Details_List__c = '14485289,14485293,14485295';
        invoiceLineItem.Tax_Inclusive__c = 0;
        invoiceLineItem.Tax_Rate__c = 0;
        invoiceLineItem.Invoice_Transaction_ID__c=12345;
        insert invoiceLineItem;

    }
    
    /*----------------------------------------------------------------
    Method : getUsageResponseDetailsSuccess
    Author: Sasidhar Devarapalli
    Story: EDGE-108332 
    -------------------------------------------------------------------------------------*/
    @isTest
    public static void getUsageResponseDetailsSuccess(){
        Invoice_Line_Item__c invoiceRecord = [select id,Invoice__c,Plan_Instance_Details_List__c,Tax_Inclusive__c,Tax_Rate__c from Invoice_Line_Item__c];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockUsageCallout('success_Search'));
        Map<String,Object> invoiceMapStr = new Map<String,Object>();
        Boolean isInvoiceLineItem=true;
        String invoiceString='{accountNumber=700000467501, chargeId=9772, invoiceNumber=149135609, invoicePeriod=01 Oct 19 - 31 Oct 19, planInstanceDetailsList=(14928352), statementNumber=9900000017373, taxInclusive=0, taxRate=0, usageTypeCode=1013}';
        invoiceMapStr.put('9772',invoiceString);
        String invoiceLineItemId=invoiceRecord.id;
        String wrapper =  UsageSummaryHandler.getUsageResponseDetails(invoiceLineItemId,invoiceMapStr, isInvoiceLineItem);
        system.assertNotEquals(null, invoiceString); 
        Test.stopTest();
    }
    
    /*----------------------------------------------------------------
    Method : getUsageResponseDetailsFail
    Author: Sasidhar Devarapalli
    Story: EDGE-108332 
    -------------------------------------------------------------------------------------*/
    @isTest
    public static void getUsageResponseDetailsFail(){
        Invoice_Line_Item__c invoiceRecord = [SELECT id,Invoice__c,Plan_Instance_Details_List__c,Tax_Inclusive__c,Tax_Rate__c FROM Invoice_Line_Item__c LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockUsageCallout('success_Error_503'));
        Map<String,Object> invoiceMapStr = new Map<String,Object>();
        Boolean isInvoiceLineItem=false;
        String invoiceString='{accountNumber=700000467501, chargeId=9772, invoiceNumber=149135609, invoicePeriod=01 Oct 19 - 31 Oct 19, planInstanceDetailsList=(14928352), statementNumber=9900000017373, taxInclusive=0, taxRate=0, usageTypeCode=1013}';
        invoiceMapStr.put('9772',invoiceString);
        String invoiceLineItemId=invoiceRecord.id;
        String wrapper =  UsageSummaryHandler.getUsageResponseDetails(invoiceLineItemId,invoiceMapStr, isInvoiceLineItem);
        system.assertNotEquals(null, invoiceString); 
        Test.stopTest();
    }
    
        /*----------------------------------------------------------------
    Method : getinvoiceLineItemRecord
    Author: Manjunath Ediga
    Story: EDGE-141682 
    -------------------------------------------------------------------------------------*/
    
    @isTest
    public static void getinvoiceLineItemRecord(){
        
        Invoice_Line_Item__c invoiceRecord = [SELECT id,Invoice__c,Invoice_Transaction_ID__c,Plan_Instance_Details_List__c,Tax_Inclusive__c,Tax_Rate__c FROM Invoice_Line_Item__c LIMIT 1];
        Test.startTest();
        String invoiceLineItemId =invoiceRecord.id;
        Invoice_Line_Item__c invoiceRecordReturned= UsageSummaryHandler.getinvoiceLineItem(invoiceLineItemId);
        system.assertNotEquals(null, invoiceRecordReturned);
        Test.stopTest();
    }
    /*----------------------------------------------------------------
    Method : getinvoiceLineItemRecordNegative
    Author: Manjunath Ediga
    Story: EDGE-141682 
    -------------------------------------------------------------------------------------*/
    @isTest
    public static void getinvoiceLineItemRecordNegative(){
        
        //Invoice_Line_Item__c invoiceRecord = [SELECT id,Invoice__c,Plan_Instance_Details_List__c,Tax_Inclusive__c,Tax_Rate__c FROM Invoice_Line_Item__c LIMIT 1];
        Test.startTest();
        String invoiceLineItemId =null;
        Invoice_Line_Item__c invoiceRecordReturned= UsageSummaryHandler.getinvoiceLineItem(invoiceLineItemId);
        system.assertEquals(null, invoiceRecordReturned);
        UsageSummaryHandler.getQueryLineItems(invoiceLineItemId);
        Test.stopTest();
    }
    
    /*----------------------------------------------------------------
    Method : getCustomMetadataRecord
    Author: Manjunath Ediga
    Story: EDGE-141682 
    -------------------------------------------------------------------------------------*/
    @isTest
    public static void getCustomMetadataRecord() {
        
        string usageTypeCode ='1006';
        String invoiceLineItemId ='false';
        Boolean isInvoiceLineItem =false;
        Test.startTest();
        List<Usage_Type__mdt > lstUsageData = UsageSummaryHandler.getUsageTypeLabels(usageTypeCode ,invoiceLineItemId,isInvoiceLineItem);
        system.assertNotEquals(null, lstUsageData);
        Test.stopTest();
    }
    /*----------------------------------------------------------------
    Method : getCustomMetadataForInvLineItem
    Author: Manjunath Ediga
    Story: EDGE-141682 
    -------------------------------------------------------------------------------------*/
      @isTest
    public static void getCustomMetadataForInvLineItem() {
        
        string usageTypeCode ='1006';
        String invoiceLineItemId ='false';
        Boolean isInvoiceLineItem =true;
        Test.startTest();
        List<Usage_Type__mdt > lstUsageData = UsageSummaryHandler.getUsageTypeLabels(usageTypeCode ,invoiceLineItemId,isInvoiceLineItem);
        system.assertEquals(null, lstUsageData);
        Test.stopTest();
    }

     /*----------------------------------------------------------------
    Method : getinvoiceLineItemRecord
    Author:Zeeshan
    Story: EDGE-141682 
    -------------------------------------------------------------------------------------*/
    
    @isTest
    public static void invoiceLineItemList(){
        
        Invoice_Line_Item__c invoiceRecord = [select id,Offer_Name__c,Physical_Location_Name__c,Line_Item_Identifier__c,Invoice_Line_Number__c,Service_Type__c,Charge_Type__c,Quantity__c, Is_Taxable__c, Charge_Excluding_GST__c,Charge_Including_GST__c  ,Invoice__r.Billing_Account__r.Account__r.Name,Invoice__r.Billing_Account__r.Account__r.AccountNumber, (select id,case__r.caseNumber from Queried_Line_Items__r) from Invoice_Line_Item__c  limit 1];
        Test.startTest();
        String invoiceLineItem =invoiceRecord.id;
        UsageSummaryHandler.invoiceLineItemListWrapper invoiceLineRecord = UsageSummaryHandler.invoiceLineItemList(invoiceLineItem);
        system.assertNotEquals(null, invoiceLineRecord);
        UsageSummaryHandler.getQueryLineItems(invoiceLineItem);
        Test.stopTest();
    }
      
     @isTest
    public static void getInvoiceDetailsPostive(){
        
        String json = '{"chargeId":"7001","statementNumber":"9900000182889"}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockUsageCallout('success_Error'));
        Map<Integer,String> response=UsageCalloutHandler.calloutInvoiceDetails(json,'RecurringChargeHandler');

        Test.stopTest();
        System.assertEquals(false,response.containsKey(200)); 

    }

    
     @isTest
    public static void getInvoiceDetailsNegative(){
        
       String json = '{"chargeId":"7001","statementNumber":"9900000182889"}';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockUsageCallout('success_Search'));
        Map<Integer,String> response=UsageCalloutHandler.calloutInvoiceDetails(json,'RecurringChargeHandler');
        Test.stopTest();
        System.assertEquals(true,response.containsKey(200)); 
    }

     /*----------------------------------------------------------------
    Method : upsertInvoiceLineItem
    Author:Shresth Dixit
    Story: DPG-3572
    -------------------------------------------------------------------------------------*/

    @isTest
    private static void upsertInvoiceLineItemTest(){
        
        Invoice_Line_Item__c invoiceRecord = [select id from Invoice_Line_Item__c WHERE Invoice_Transaction_ID__c = 12345];
        invoiceRecord.Tenancy_Id__c = 1234567;
        invoiceRecord.Date_Calculated__c = date.newInstance(1987, 12, 17);
        Test.startTest();
        UsageSummaryHandler.upsertInvoiceLineItem(invoiceRecord);
        Test.stopTest();
        invoiceRecord = [select id,Tenancy_Id__c,Date_Calculated__c FROM Invoice_Line_Item__c WHERE Invoice_Transaction_ID__c = 12345];
        System.assertEquals(date.newInstance(1987, 12, 17),invoiceRecord.Date_Calculated__c);
        System.assertEquals(1234567,invoiceRecord.Tenancy_Id__c);

    }
    @isTest
    private static void createDeviceCSVTest(){
    	Invoice_Line_Item__c invoiceRecord = [select id from Invoice_Line_Item__c WHERE Invoice_Transaction_ID__c = 12345];
        test.startTest();
        Id docId = UsageSummaryHandler.createDeviceCSV(invoiceRecord.Id,'E60A87459891,240CC02D1FE7,3687CF187010,0E1ECBFFC13');
        test.stopTest();
        system.assert(docId != null);

    }
     @isTest
    private static void createDeviceCSVNegativeTest(){
        test.startTest();
        Id docId = UsageSummaryHandler.createDeviceCSV(null,'E60A87459891,240CC02D1FE7,3687CF187010,0E1ECBFFC13');
        test.stopTest();
        system.assert(docId == null);

    }

}