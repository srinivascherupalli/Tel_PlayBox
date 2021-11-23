/*************************************************************************************************
Name : InvoiceCalloutHandlerTest
Description : Test class for InvoiceCalloutHandler
Author: Kalashree Borgaonkar
Story: EDGE-88307
***************************************************************************************************/

@isTest
public with sharing class InvoiceCalloutHandlerTest {
    /*----------------------------------------------------------------
Method : setupdata
Author: Kalashree Borgaonkar
Story: EDGE-88307 
Descripton : Create Data
-------------------------------------------------------------------------------------*/
@testSetup 
public static void setupdata(){
    Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Case_Record_Type).getRecordTypeId();
    Account accountData = TestDataFactory.generateAccount();
    Contact contactData = TestDataFactory.generateContact('Test FirstName1', accountData.id,'Active','Test LastName1',System.today(),'Mobile');
    contactData.email='abc@gmail1.com';
    insert contactData;
    Billing_Account__c billingAccountData = TestDataFactory.generateBillingAccount('700000002979','Created',accountData.Id, contactData.Id);
    insert billingAccountData;
    Case caseData      = new Case(AccountId = accountData.Id,ContactId = contactData.Id,Status = 'New',Type = System.Label.Case_Type,RecordTypeId = caseRecordTypeId,Billing_Account__c = billingAccountData.Id);
    caseData.AccountId = accountData.Id;
    caseData.ContactId = contactData.Id;
    caseData.Type      = System.Label.Case_Type;
    insert caseData;
    Invoice__c invdata= new Invoice__c(Name='123434',Aria_Invoice_Number__c='1232');
    insert invdata;
    Invoice_Line_Item__c ILI=new Invoice_Line_Item__c(Invoice__c=invdata.id,Invoice_Line_Number__c=13432233, Charge_Excluding_GST__c = 1214,Charge_Type__c= 'RecurringCharge',Invoice_Transaction_ID__c=26022460,Line_Item_Identifier__c='43242342',charge_identifier__c=12453);
    insert ILI;
    List<Queried_Line_Item__c> qlilist=new List<Queried_Line_Item__c>();
    Queried_Line_Item__c sobj = new Queried_Line_Item__c(
        Queried_Amount__c = 34.99,                      // Queried Amount (ex GST)
        Line_Item_Identifier__c = 'RecurringCharge100',  // Line Item Identifier
        Case__c = caseData.id,                    // Case
        Invoice_Line_Item__c = ILI.id                   // Invoice Line Item 
    );
    qlilist.add(sobj);
    insert qlilist;
}

    /*----------------------------------------------------------------
Method : createPayload
Author: Kalashree Borgaonkar
Story: EDGE-88307 
-------------------------------------------------------------------------------------*/
    @isTest
    public static void createPayloadTest(){
        String invoiceNumber = '9900000182889';
        InvoiceRequestDTO requestDto = InvoiceCalloutHandler.createPayload('700000005112',Long.valueOf(invoiceNumber));
        System.assertEquals(requestDto!=null,true, 'Request Payload created');
    }
    /*----------------------------------------------------------------
Method : calloutInvoiceByNumberSuccess
Author: Kalashree Borgaonkar
Story: EDGE-88307 
-------------------------------------------------------------------------------------*/
    @isTest
    public static void calloutInvoiceByNumberSuccess(){
        String invoiceNumber = '9900000182889';
        try{   
        InvoiceRequestDTO requestDto = InvoiceCalloutHandler.createPayload('700000005112',Long.valueOf(invoiceNumber));
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockInvoiceCallout('success_Search'));
        InvoiceResponseDTO responseDto =  InvoiceCalloutHandler.calloutInvoiceByNumber(requestDto);
        system.debug('responseDto is -->'+responseDto);
        Test.stopTest();
        System.assertEquals(responseDto.invoiceDetails!=null,true,'SuccessResponse');
        }
        catch(exception e){
            
        }
    }
    /*----------------------------------------------------------------
Method : calloutInvoiceByNumberFail
Author: Kalashree Borgaonkar
Story: EDGE-88307 
-------------------------------------------------------------------------------------*/
    @isTest
    public static void calloutInvoiceByNumberFail(){
        String invoiceNumber = '9900000182889';
        InvoiceRequestDTO requestDto = InvoiceCalloutHandler.createPayload('700000005112',Long.valueOf(invoiceNumber));
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockInvoiceCallout('success_Error'));
        InvoiceResponseDTO responseDto =  InvoiceCalloutHandler.calloutInvoiceByNumber(requestDto);
        Test.stopTest();
        System.assertEquals(responseDto.errorMessage !=null,true,responseDto.errorMessage);
    }
    /*----------------------------------------------------------------
Method : calloutInvoiceByNumberFail503
Author: Kalashree Borgaonkar
Story: EDGE-88307 
-------------------------------------------------------------------------------------*/
    @isTest
    public static void calloutInvoiceByNumberFail503(){
        try{
            String invoiceNumber = '9900000182889';
        InvoiceRequestDTO requestDto = InvoiceCalloutHandler.createPayload('700000005112',Long.valueOf(invoiceNumber));
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockInvoiceCallout('success_Error_503'));
        InvoiceResponseDTO responseDto =  InvoiceCalloutHandler.calloutInvoiceByNumber(requestDto);
               Test.stopTest();
        System.assertEquals(responseDto ==null,true,'Failure Response');
        }
        catch(exception e){
            
        }
    }

  /*----------------------------------------------------------------
Method : getInvoicesNumbersTest
Author: Pradeep
Story: EDGE-124066  
-------------------------------------------------------------------------------------*/
    @isTest
    public static void getInvoicesNumbersTest(){
          
        Account accountData = TestDataFactory.generateAccount();
        Contact contactData = TestDataFactory.generateContact('Test FirstName', accountData.id,'Active','Test LastName',System.today(),'Mobile');
        insert contactData;
        Billing_Account__c billingAccountData = TestDataFactory.generateBillingAccount('700000002978','Created',accountData.Id, contactData.Id);
        insert billingAccountData;
        Invoice__c invoiceData = new Invoice__c(Name = '9900000202350',Billing_Account__c = billingAccountData.Id,Aria_Invoice_Number__c = '012345678912345'); 
        insert  invoiceData;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockInvoiceCallout('success_Search'));
        Map<String,String> invoiceResponse=InvoiceCalloutHandler.getInvoiceNumbers('700000002978');
        system.debug('responseDto is -->'+invoiceResponse);
        Test.stopTest();
        System.assertEquals(invoiceResponse!=null,true);
       
    }    
    
 /*----------------------------------------------------------------
Method : getInvoicesNumbersTestFail
Author: Pradeep
Story: EDGE-124066  
-------------------------------------------------------------------------------------*/
    @isTest
    public static void getInvoicesNumbersTestFail(){
        
        Account accountData = TestDataFactory.generateAccount();
        Contact contactData = TestDataFactory.generateContact('Test FirstName', accountData.id,'Active','Test LastName',System.today(),'Mobile');
        insert contactData;
        Billing_Account__c billingAccountData = TestDataFactory.generateBillingAccount('700000002978','Created',accountData.Id, contactData.Id);
        insert billingAccountData;
        Invoice__c invoiceData = new Invoice__c(Name = '9900000202350',Billing_Account__c = billingAccountData.Id,Aria_Invoice_Number__c = '012345678912345'); 
        insert  invoiceData;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockInvoiceCallout('success_Error'));
        Map<String,String> invoiceResponse=InvoiceCalloutHandler.getInvoiceNumbers('700000002978');
        system.debug('responseDto is -->'+invoiceResponse);
        Test.stopTest();
        System.assertEquals(invoiceResponse!=null,true);
           
    }  
    
    /*----------------------------------------------------------------
Method : calloutInvoicePDFTest
Author: Kalashree Borgaonkar
Story: EDGE-88307 
-------------------------------------------------------------------------------------*/
    @isTest
    public static void calloutInvoicePDFTest(){
        String invoiceNumber = '9900000182889';
        InvoiceRequestDTO requestDto = InvoiceCalloutHandler.createPayload('700000005112',Long.valueOf(invoiceNumber));
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockInvoiceCallout('successPdf'));
        HttpResponse response =  InvoiceCalloutHandler.calloutInvoicePDF(requestDto);
        Test.stopTest();
        System.assertEquals(response.getBody() !=null,true,'SuccessResponse');
    }
    /*----------------------------------------------------------------
Method : calloutInvoicePDFTestFail
Author: Kalashree Borgaonkar
Story: EDGE-88307 
-------------------------------------------------------------------------------------*/
    @isTest
    public static void calloutInvoicePDFTestFail(){
        String invoiceNumber = '9900000182889';
        InvoiceRequestDTO requestDto = InvoiceCalloutHandler.createPayload('700000005112',Long.valueOf(invoiceNumber));
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockInvoiceCallout('success_Error_503'));
        HttpResponse response =  InvoiceCalloutHandler.calloutInvoicePDF(requestDto);
        Test.stopTest();
        System.assertEquals(response.getBody() !=null,true,'Failure Response');
    }
    /*----------------------------------------------------------------
Method : calloutInvoicePDFFail
Author: Kalashree Borgaonkar
Story: EDGE-88307 
-------------------------------------------------------------------------------------*/
    @isTest
    public static void calloutInvoicePDFFail(){
        String invoiceNumber = '9900000182889';
        InvoiceRequestDTO requestDto = InvoiceCalloutHandler.createPayload('700000005112',Long.valueOf(invoiceNumber));
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockInvoiceCallout('success_Error_503'));
        HttpResponse responseDto =  InvoiceCalloutHandler.calloutInvoicePDF(requestDto);
        Test.stopTest();
        System.assertEquals(responseDto !=null,true,'Failure Response');
    }
    /*----------------------------------------------------------------
    Method : updateInvoiceLineItemsTest
    Author: Ramesh Somalagari
    Story: EDGE-119417
    -------------------------------------------------------------------------------------*/
    @isTest
    public static void updateInvoiceLineItemsTest(){
        String invoiceNumber = '9900000182889';
        String year = null;
        List<string> dateStringSplit;
        InvoiceRequestDTO requestDto = InvoiceCalloutHandler.createPayload('700000005112',Long.valueOf(invoiceNumber));
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockInvoiceCallout('success_Search'));
        InvoiceResponseDTO responseDto =  InvoiceCalloutHandler.calloutInvoiceByNumber(requestDto);
        system.debug('responseDto is -->'+responseDto);
        dateStringSplit =  responseDto.PaymentSummary.dueDate.split(' ');
        year = '20'+dateStringSplit[2];
        //Map<InvoiceCalloutHandler.Offer, InvoiceResponseDTO.ListOfProducts> productsMap = new Map<InvoiceCalloutHandler.Offer,InvoiceResponseDTO.ListOfProducts>();
        Map<Integer,InvoiceCalloutHandler.ProductOffer> productsMap = new Map<Integer,InvoiceCalloutHandler.ProductOffer>();
        dateStringSplit =  responseDto.InvoiceDetails.invoiceIssueDate.split(' ');
        productsMap = InvoiceCalloutHandler.getProducts(responseDto,null,'2019');
       /* try{
        if(!productsMap.isEmpty()) {
                    InvoiceCalloutHandler.updateInvoiceLineItems(productsMap,null,'2019');
                }
        }catch(Exception e){}*/
        InvoiceCalloutHandler.updateInvoiceLineItems(productsMap,null,'2019');
        
        Test.stopTest();
        System.assertEquals(responseDto.invoiceDetails!=null,true,'SuccessResponse');
    }
     /*----------------------------------------------------------------
    Method : adjustmentsummary
    Author: Mohammed Zeeshan
    Story: EDGE-120657
    Description: Negative test method
    -------------------------------------------------------------------------------------*/
    static testMethod void adjustmentsummary() {
        String json = '{"customerAddress":{"companyName":"MLC Company Ltd.","addressLine1":"Unit 1 1234 Lostmy Way","addressCity":"Sydney","stateAndPostalCode":"NSW 2000"},"invoiceDetails":{"accountNumber":"700000002978","invoiceNumber":"9900000202350","invoiceIssueDate":"24 Jul 19","invoicePeriod":"01 Mar 19 - 31 Mar 19","ariaInvoiceNumber":"148512498"},"paymentSummary":{"balanceCarriedForward":-603.02,"totalDue":298.98,"paymentsAndAdjustments":603.02,"dueDate":"07 Aug 19","newCharges":902},"serviceSummary":{"listOfOffers":[{"offerName":"Connected Workplace","offerTotalExcludingGstCost":590,"offerTotalIncludingGstCost":902,"invoiceDef":1,"listOfProducts":[{"physicalLocationName":"400 George St Sydney NSW","siteExcludingGstCost":590,"siteIncludingGstCost":902,"listOfChargesAndCredits":{"planCharges":[{"serviceType":"Bandwidth Bolt On","quantity":1,"excludingGstCost":50,"includingGstCost":55,"sigmaSpecId":"BSRC001_CB","startDate":"01 Apr","endDate":"30 Apr","discounts": [{"creditType": "Discount applied","quantity": 2,"excludingGstCost": 70,"includingGstCost": 77,"isDrillable": true,"drillDownInputAttribute":{"statementNumber": "9900000530358","chargeId": 166229}}],"isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4261,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":5,"invoiceTransactionId":197352167,"chargeExcludingGST":50,"chargeIncludingGST":55}]},{"serviceType":"Apple iPhone 8 64GB Monthly Repayment Charge","quantity":2,"excludingGstCost":110,"includingGstCost":110,"sigmaSpecId":"BSRO001_CB","isAggregated":true,"isTaxable":false,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4274,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":7,"invoiceTransactionId":197352169,"chargeExcludingGST":55,"chargeIncludingGST":55},{"invoiceLineNumber":6,"invoiceTransactionId":197352168,"chargeExcludingGST":55,"chargeIncludingGST":55}],"drillDownInputAttribute":{"statementNumber":"9900000202350","chargeId":4274},"drillDownEndpoint":"Repayment details"},{"serviceType":"Fixed Seat (Zone 1)","quantity":1,"excludingGstCost":50,"includingGstCost":55,"sigmaSpecId":"BSRC001_CB","startDate":"01 Apr","endDate":"30 Apr","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4260,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":8,"invoiceTransactionId":197352170,"chargeExcludingGST":50,"chargeIncludingGST":55}]}],"onceOffChargesAndCredits":[{"serviceType":"Jabra Stealth UC","quantity":1,"excludingGstCost":30,"includingGstCost":33,"sigmaSpecId":"BSOTC001_CB","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4269,"chargeType":"OnceOffCharge","disputeAttributes":[{"invoiceLineNumber":11,"invoiceTransactionId":197352173,"chargeExcludingGST":30,"chargeIncludingGST":33}]},{"serviceType":"Polaris Soundpro Touch 790","quantity":1,"excludingGstCost":35,"includingGstCost":38.5,"sigmaSpecId":"BSOTC001_CB","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4268,"chargeType":"OnceOffCharge","disputeAttributes":[{"invoiceLineNumber":12,"invoiceTransactionId":197352174,"chargeExcludingGST":35,"chargeIncludingGST":38.5}]},{"serviceType":"Polaris Soundpro Touch 790","quantity":1,"excludingGstCost":135,"includingGstCost":148.5,"sigmaSpecId":"BSOTC001_CB","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4267,"chargeType":"OnceOffCharge","disputeAttributes":[{"invoiceLineNumber":13,"invoiceTransactionId":197352175,"chargeExcludingGST":135,"chargeIncludingGST":148.5}]},{"serviceType":"Polaris Soundpro SW10ND","quantity":3,"excludingGstCost":420,"includingGstCost":462,"sigmaSpecId":"BSOTC001_CB","isAggregated":true,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4275,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":14,"invoiceTransactionId":197352176,"chargeExcludingGST":140,"chargeIncludingGST":154},{"invoiceLineNumber":10,"invoiceTransactionId":197352172,"chargeExcludingGST":140,"chargeIncludingGST":154},{"invoiceLineNumber":9,"invoiceTransactionId":197352171,"chargeExcludingGST":140,"chargeIncludingGST":154}]},{"serviceType":"Apple iPhone 8 64GB","quantity":2,"excludingGstCost":2400,"includingGstCost":2640,"isAggregated":true,"isTaxable":true,"isQueryable":true,"isDisputable":false,"chargeIdentifier":4277,"chargeType":"OnceOffCharge"},{"serviceType":"Apple iPhone 8 64GB","quantity":2,"excludingGstCost":-2640,"includingGstCost":-2640,"isAggregated":true,"isTaxable":false,"isQueryable":true,"isDisputable":false,"chargeIdentifier":4276,"chargeType":"CreditCharge"}]}}]}],"accountLevelChargesAndCredits":{"adjustmentsExcludingGstCost":0,"adjustmentsIncludingGstCost":0,"grossTotalBill":902,"amountOfGstIncludedInGrossTotalBill":312,"totalNewChargesInThisBill":902,"gstFreeItemsIncludedInNewCharges":110,"gstIncludedInNewCharges":312,"adjustmentsTotal":-603.02,"gstIncludedInAdjustments":-54.82}},"adjustmentSummary":{"totalAdjustmentsCost":-603.02,"totalGSTIncludedInAdjustments":-54.82,"adjustments":[{"adjustmentDescription":"Compensation Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-150.38,"gstIncludedInAdjustments":-13.67,"isQueryable":true,"isDisputable":false,"chargeIdentifier":80,"chargeType":"CreditCharge"},{"adjustmentDescription":"Goodwill Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-100.66,"gstIncludedInAdjustments":-9.15,"isQueryable":true,"isDisputable":false,"chargeIdentifier":78,"chargeType":"CreditCharge"},{"adjustmentDescription":"Goodwill Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-100.66,"gstIncludedInAdjustments":-9.15,"isQueryable":true,"isDisputable":false,"chargeIdentifier":79,"chargeType":"CreditCharge"},{"adjustmentDescription":"Compensation Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-150.66,"gstIncludedInAdjustments":-13.7,"isQueryable":true,"isDisputable":false,"chargeIdentifier":77,"chargeType":"CreditCharge"},{"adjustmentDescription":"Goodwill Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-100.66,"gstIncludedInAdjustments":-9.15,"isQueryable":false,"isDisputable":false,"chargeIdentifier":76,"chargeType":"CreditCharge"}]}}';
        InvoiceResponseDTO obj = InvoiceResponseDTO.parse(json);
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Case_Record_Type).getRecordTypeId();
        Account accountData = TestDataFactory.generateAccount();
        Test.startTest();
        Contact contactData = TestDataFactory.generateContact('Test FirstName', accountData.id,'Active','Test LastName',System.today(),'Mobile');
        insert contactData;
        Billing_Account__c billingAccountData = TestDataFactory.generateBillingAccount('700000002978','Created',accountData.Id, contactData.Id);
        insert billingAccountData;
        Case caseData      = new Case(AccountId = accountData.Id,ContactId = contactData.Id,Status = 'New',Type = System.Label.Case_Type,RecordTypeId = caseRecordTypeId,Billing_Account__c = billingAccountData.Id);
        caseData.AccountId = accountData.Id;
        caseData.ContactId = contactData.Id;
        caseData.Type      = System.Label.Case_Type;
        insert caseData;
        Test.stopTest();
        Invoice__c invoiceData = new Invoice__c(Name = '9900000202350',Billing_Account__c = billingAccountData.Id,Aria_Invoice_Number__c = '012345678912345'); 
        insert  invoiceData;
        List<Invoice_Line_Item__c> lineItemList = new List<Invoice_Line_Item__c> ();
        InvoiceCalloutHandler.updateAdjustmentLineItem(obj,invoiceData.id, lineItemList);
        
        System.assert(lineItemList.size() == 0);
    }
         /*----------------------------------------------------------------
    Method : adjustmentsummaryPositiveTest
    Author: Mohammed Zeeshan
    Story: EDGE-120657
    Description: Positive test method
    -------------------------------------------------------------------------------------*/
    static testMethod void adjustmentsummaryPositiveTest() {
        String json = '{"customerAddress":{"companyName":"MLC Company Ltd.","addressLine1":"Unit 1 1234 Lostmy Way","addressCity":"Sydney","stateAndPostalCode":"NSW 2000"},"invoiceDetails":{"accountNumber":"700000002979","invoiceNumber":"9900000202486","invoiceIssueDate":"25 Jul 19","invoicePeriod":"01 May 19 - 31 May 19","ariaInvoiceNumber":"148512791"},"paymentSummary":{"balanceCarriedForward":1819,"totalDue":13949,"paymentsAndAdjustments":0,"dueDate":"08 Aug 19","newCharges":12130},"serviceSummary":{"listOfOffers":[{"offerName":"Connected Workplace","offerTotalExcludingGstCost":6994.09,"offerTotalIncludingGstCost":7105,"invoiceDef":1,"listOfProducts":[{"physicalLocationName":"400 George St Sydney NSW","siteExcludingGstCost":200,"siteIncludingGstCost":210,"listOfChargesAndCredits":{"planCharges":[{"serviceType":"Bandwidth Bolt On","quantity":1,"excludingGstCost":50,"includingGstCost":55,"sigmaSpecId":"BSRC001_CB","startDate":"01 Jun","endDate":"30 Jun","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeType":"RecurringCharge","chargeIdentifier":49387,"invoiceLineAttributes":[{"invoiceLineNumber":5,"invoiceTransactionId":197353604,"chargeExcludingGST":50,"chargeIncludingGST":55,"chargeInstanceId":"Svdf4b13-f9sf-5i0b-f6if-8mz5fv0r9a6101"}]},{"serviceType":"Fixed Seat (Zone 1)","quantity":1,"excludingGstCost":50,"includingGstCost":55,"sigmaSpecId":"BSRC001_CB","startDate":"01 Jun","endDate":"30 Jun","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeType":"RecurringCharge","chargeIdentifier":49386,"invoiceLineAttributes":[{"invoiceLineNumber":3,"invoiceTransactionId":197353602,"chargeExcludingGST":50,"chargeIncludingGST":55,"chargeInstanceId":"S5vdf4b13-f9sf-5i0b-f6if-8mz5fv0r9a6111"}]},{"serviceType":"Apple iPhone 8 64GB Monthly Repayment Charge","quantity":1,"excludingGstCost":45,"includingGstCost":45,"sigmaSpecId":"BSRO001_CB","startDate":"01 Jun","endDate":"30 Jun","isAggregated":false,"isTaxable":false,"isQueryable":true,"isDisputable":true,"chargeType":"RecurringCharge","chargeIdentifier":49389,"invoiceLineAttributes":[{"invoiceLineNumber":6,"invoiceTransactionId":197353605,"chargeExcludingGST":45,"chargeIncludingGST":45,"chargeInstanceId":"S1df4b20-f9sf-5i0b-f6if-8mz5fv0r9a6i11"}]},{"serviceType":"Apple iPhone 8 64GB Monthly Repayment Charge","quantity":1,"excludingGstCost":55,"includingGstCost":55,"sigmaSpecId":"BSRO001_CB","startDate":"01 Jun","endDate":"30 Jun","isAggregated":false,"isTaxable":false,"drillDownEndpoint":"Repayment details","drillDownInputAttribute":{"statementNumber":"9900000202486","chargeId":49388},"isQueryable":true,"isDisputable":true,"chargeType":"RecurringCharge","chargeIdentifier":49388,"invoiceLineAttributes":[{"invoiceLineNumber":4,"invoiceTransactionId":197353603,"chargeExcludingGST":55,"chargeIncludingGST":55,"chargeInstanceId":"Svdf4b20-f9sf-5i0b-f6if-8mz5fv0r9a6i11"}]}]}},{"physicalLocationName":"Mobile workers add-on","siteExcludingGstCost":6794.09,"siteIncludingGstCost":6895,"listOfChargesAndCredits":{"planCharges":[{"serviceType":"CWP Mobile Seat","quantity":1,"excludingGstCost":50,"includingGstCost":55,"sigmaSpecId":"BSRC001_CB","startDate":"01 Jun","endDate":"30 Jun","discounts": [{"creditType": "Discount applied","quantity": 2,"excludingGstCost": 70,"includingGstCost": 77,"isDrillable": true,"drillDownInputAttribute":{"statementNumber": "9900000530358","chargeId": 166229}}],"isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeType":"RecurringCharge","chargeIdentifier":49390,"invoiceLineAttributes":[{"invoiceLineNumber":10,"invoiceTransactionId":197353609,"chargeExcludingGST":50,"chargeIncludingGST":55,"chargeInstanceId":"S5vdf4b13-f9sf-5i0b-f6if-8mz5fv0r9a6112"}]},{"serviceType":"Voice to text","quantity":1,"excludingGstCost":50,"includingGstCost":55,"sigmaSpecId":"BSRC001_CB","startDate":"01 Jun","endDate":"30 Jun","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeType":"RecurringCharge","chargeIdentifier":49391,"invoiceLineAttributes":[{"invoiceLineNumber":9,"invoiceTransactionId":197353608,"chargeExcludingGST":50,"chargeIncludingGST":55,"chargeInstanceId":"Svdf4b13-f9sf-5i0b-f6if-8mz5fv0r9a6102"}]},{"serviceType":"Apple iPhone 8 64GB Monthly Repayment Charge","quantity":1,"excludingGstCost":45,"includingGstCost":45,"sigmaSpecId":"BSRO001_CB","startDate":"01 Jun","endDate":"30 Jun","isAggregated":false,"isTaxable":false,"isQueryable":true,"isDisputable":true,"chargeType":"RecurringCharge","chargeIdentifier":49393,"invoiceLineAttributes":[{"invoiceLineNumber":8,"invoiceTransactionId":197353607,"chargeExcludingGST":45,"chargeIncludingGST":45,"chargeInstanceId":"S1df4b20-f9sf-5i0b-f6if-8mz5fv0r9a6i12"}]},{"serviceType":"Apple iPhone 8 64GB Monthly Repayment Charge","quantity":1,"excludingGstCost":55,"includingGstCost":55,"sigmaSpecId":"BSRO001_CB","startDate":"01 Jun","endDate":"30 Jun","isAggregated":false,"isTaxable":false,"drillDownEndpoint":"Repayment details","drillDownInputAttribute":{"statementNumber":"9900000202486","chargeId":49392},"isQueryable":true,"isDisputable":true,"chargeType":"RecurringCharge","chargeIdentifier":49392,"invoiceLineAttributes":[{"invoiceLineNumber":11,"invoiceTransactionId":197353610,"chargeExcludingGST":55,"chargeIncludingGST":55,"chargeInstanceId":"Svdf4b20-f9sf-5i0b-f6if-8mz5fv0r9a6i12"}]}],"usageSummaryCharges":[{"excludingGstCost":909.09,"includingGstCost":1000,"isAggregated":false,"isTaxable":true,"usageTypeNo":"10026121","units":"0.10 GB","drillDownEndpoint":"Usage Details","drillDownInputAttribute":{"usageTypeCode":"1007","statementNumber":"9900000202486","invoiceNumber":"148512791","accountNumber":"700000002979","invoicePeriod":"01 May 19 - 31 May 19","planInstanceDetailsList":[14498165],"chargeId":49401,"taxInclusive":1,"taxRate":0},"usageTypeName":"Data usage above plan","isQueryable":true,"isDisputable":true,"discounts": [{"creditType": "Discount applied","quantity": 2,"excludingGstCost": 70,"includingGstCost": 77,"isDrillable": true,"drillDownInputAttribute":{"statementNumber": "9900000530358","chargeId": 166229}}],"chargeType":"UsageCharge","chargeIdentifier":49401,"invoiceLineAttributes":[{"invoiceLineNumber":13,"invoiceTransactionId":197353612,"chargeExcludingGST":909.09,"chargeIncludingGST":1000,"chargeInstanceId":"Svdf4b13-f9sf-5i0b-f6if-8mz5fv0r9a6103"}]},{"excludingGstCost":60,"includingGstCost":60,"isAggregated":false,"isTaxable":false,"usageTypeNo":"10026335","units":"12","drillDownEndpoint":"Usage Details","drillDownInputAttribute":{"usageTypeCode":"7001","statementNumber":"9900000202486","invoiceNumber":"148512791","accountNumber":"700000002979","invoicePeriod":"01 May 19 - 31 May 19","planInstanceDetailsList":[14498165],"chargeId":49397,"taxInclusive":0,"taxRate":0},"usageTypeName":"International roaming day pass - zone 1","isQueryable":true,"isDisputable":true,"chargeType":"UsageCharge","chargeIdentifier":49397,"invoiceLineAttributes":[{"invoiceLineNumber":17,"invoiceTransactionId":197353616,"chargeExcludingGST":60,"chargeIncludingGST":60,"chargeInstanceId":"S5vdf4b13-f9sf-5i0b-f6if-8mz5fv0r9a6113"}]},{"excludingGstCost":600,"includingGstCost":600,"isAggregated":false,"isTaxable":false,"usageTypeNo":"10026336","units":"600","drillDownEndpoint":"Usage Details","drillDownInputAttribute":{"usageTypeCode":"7002","statementNumber":"9900000202486","invoiceNumber":"148512791","accountNumber":"700000002979","invoicePeriod":"01 May 19 - 31 May 19","planInstanceDetailsList":[14498165],"chargeId":49394,"taxInclusive":0,"taxRate":0},"usageTypeName":"International roaming day pass - zone 2","isQueryable":true,"isDisputable":true,"chargeType":"UsageCharge","chargeIdentifier":49394,"invoiceLineAttributes":[{"invoiceLineNumber":14,"invoiceTransactionId":197353613,"chargeExcludingGST":600,"chargeIncludingGST":600,"chargeInstanceId":"S5vdf4b13-f9sf-5i0b-f6if-8mz5fv0r9a6113"}]},{"excludingGstCost":25,"includingGstCost":25,"isAggregated":false,"isTaxable":false,"usageTypeNo":"10026337","units":"1","drillDownEndpoint":"Usage Details","drillDownInputAttribute":{"usageTypeCode":"7003","statementNumber":"9900000202486","invoiceNumber":"148512791","accountNumber":"700000002979","invoicePeriod":"01 May 19 - 31 May 19","planInstanceDetailsList":[14498165],"chargeId":49400,"taxInclusive":0,"taxRate":0},"usageTypeName":"International roaming day pass data top-up","isQueryable":true,"isDisputable":true,"chargeType":"UsageCharge","chargeIdentifier":49400,"invoiceLineAttributes":[{"invoiceLineNumber":20,"invoiceTransactionId":197353619,"chargeExcludingGST":25,"chargeIncludingGST":25,"chargeInstanceId":"S5vdf4b13-f9sf-5i0b-f6if-8mz5fv0r9a6113"}]},{"excludingGstCost":1500,"includingGstCost":1500,"isAggregated":false,"isTaxable":false,"usageTypeNo":"10026333","units":"0.95 GB","drillDownEndpoint":"Usage Details","drillDownInputAttribute":{"usageTypeCode":"1006","statementNumber":"9900000202486","invoiceNumber":"148512791","accountNumber":"700000002979","invoicePeriod":"01 May 19 - 31 May 19","planInstanceDetailsList":[14498165],"chargeId":49399,"taxInclusive":0,"taxRate":0},"usageTypeName":"International roaming data","isQueryable":true,"isDisputable":true,"chargeType":"UsageCharge","chargeIdentifier":49399,"invoiceLineAttributes":[{"invoiceLineNumber":19,"invoiceTransactionId":197353618,"chargeExcludingGST":1500,"chargeIncludingGST":1500,"chargeInstanceId":"S5vdf4b13-f9sf-5i0b-f6if-8mz5fv0r9a6113"}]},{"excludingGstCost":1700,"includingGstCost":1700,"isAggregated":true,"isTaxable":false,"usageTypeNo":"10026330","units":"53min","drillDownEndpoint":"Usage Details","drillDownInputAttribute":{"usageTypeCode":"1009","statementNumber":"9900000202486","invoiceNumber":"148512791","accountNumber":"700000002979","invoicePeriod":"01 May 19 - 31 May 19","planInstanceDetailsList":[14498165],"chargeId":49402,"taxInclusive":0,"taxRate":0},"usageTypeName":"International roaming outgoing calls","isQueryable":true,"isDisputable":true,"chargeType":"UsageCharge","chargeIdentifier":49402,"invoiceLineAttributes":[{"invoiceLineNumber":15,"invoiceTransactionId":197353614,"chargeExcludingGST":200,"chargeIncludingGST":200,"chargeInstanceId":"S5vdf4b13-f9sf-5i0b-f6if-8mz5fv0r9a6113"},{"invoiceLineNumber":18,"invoiceTransactionId":197353617,"chargeExcludingGST":1500,"chargeIncludingGST":1500,"chargeInstanceId":"S5vdf4b13-f9sf-5i0b-f6if-8mz5fv0r9a6113"}]},{"excludingGstCost":1800,"includingGstCost":1800,"isAggregated":false,"isTaxable":false,"usageTypeNo":"10026331","units":"1hr","drillDownEndpoint":"Usage Details","drillDownInputAttribute":{"usageTypeCode":"1011","statementNumber":"9900000202486","invoiceNumber":"148512791","accountNumber":"700000002979","invoicePeriod":"01 May 19 - 31 May 19","planInstanceDetailsList":[14498165],"chargeId":49396,"taxInclusive":0,"taxRate":0},"usageTypeName":"International roaming incoming calls","isQueryable":true,"isDisputable":true,"chargeType":"UsageCharge","chargeIdentifier":49396,"invoiceLineAttributes":[{"invoiceLineNumber":16,"invoiceTransactionId":197353615,"chargeExcludingGST":1800,"chargeIncludingGST":1800,"chargeInstanceId":"S5vdf4b13-f9sf-5i0b-f6if-8mz5fv0r9a6113"}]}]}},{"physicalLocationName":"Mobile workers add-on","siteExcludingGstCost":508,"siteIncludingGstCost":538,"listOfChargesAndCredits":{"planCharges":[{"serviceType":"Mobile Seat Charge","quantity":3,"excludingGstCost":300,"includingGstCost":330,"sigmaSpecId":"BSRC001_CB","startDate":"01 Jun","endDate":"30 Jun","isAggregated":true,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":9869602,"chargeType":"RecurringCharge","invoiceLineAttributes":[{"invoiceLineNumber":3,"invoiceTransactionId":197167983,"chargeExcludingGST":100,"chargeIncludingGST":110},{"invoiceLineNumber":4,"invoiceTransactionId":197167990,"chargeExcludingGST":100,"chargeIncludingGST":110},{"invoiceLineNumber":5,"invoiceTransactionId":197167999,"chargeExcludingGST":100,"chargeIncludingGST":110}]},{"serviceType":"Apple iPhone xs 128 GB Repayment","quantity":3,"excludingGstCost":165,"includingGstCost":165,"sigmaSpecId":"BSRO001_CB","startDate":"01 Jun","endDate":"30 Jun","isAggregated":true,"isTaxable":false,"isDisputable":true,"drillDownInputAttribute":{"chargeId":5553},"drillDownEndpoint":"Repayment details","isQueryable":true,"chargeIdentifier":9869601,"chargeType":"RecurringCharge","invoiceLineAttributes":[{"invoiceLineNumber":6,"invoiceTransactionId":197167982,"chargeExcludingGST":55,"chargeIncludingGST":55},{"invoiceLineNumber":7,"invoiceTransactionId":197167993,"chargeExcludingGST":55,"chargeIncludingGST":55},{"invoiceLineNumber":8,"invoiceTransactionId":197167996,"chargeExcludingGST":55,"chargeIncludingGST":55}]}],"usageSummaryCharges":[{"excludingGstCost":10,"includingGstCost":10,"isAggregated":false,"isTaxable":false,"usageTypeNo":"10026335","units":"2","drillDownInputAttribute":{"usageTypeCode":"7001","statementNumber":"9900000182889","invoiceNumber":"148442927","accountNumber":"700000005112","invoicePeriod":"01 Jun 19 - 23 Jun 19","planInstanceDetailsList":[14485289],"taxInclusive":0,"taxRate":0},"drillDownEndpoint":"Usage Details","usageTypeName":"Int roaming day pass - zone 1","isQueryable":true,"isDisputable":true,"chargeIdentifier":9869601,"chargeType":"UsageCharge","invoiceLineAttributes":[{"invoiceLineNumber":9,"invoiceTransactionId":197167980,"chargeExcludingGST":10,"chargeIncludingGST":10}]},{"excludingGstCost":5,"includingGstCost":5,"isAggregated":false,"isTaxable":false,"usageTypeNo":"10026337","units":"1","drillDownInputAttribute":{"usageTypeCode":"7003","statementNumber":"9900000182889","invoiceNumber":"148442927","accountNumber":"700000005112","invoicePeriod":"01 Jun 19 - 23 Jun 19","planInstanceDetailsList":[14485289],"taxInclusive":0,"taxRate":0},"drillDownEndpoint":"Usage Details","usageTypeName":"Int roaming day pass data top-up","isQueryable":true,"isDisputable":true,"chargeIdentifier":9869601,"chargeType":"UsageCharge","invoiceLineAttributes":[{"invoiceLineNumber":10,"invoiceTransactionId":197167981,"chargeExcludingGST":5,"chargeIncludingGST":5}]},{"excludingGstCost":12,"includingGstCost":12,"isAggregated":false,"isTaxable":false,"usageTypeNo":"10026333","units":"29.30 GB","drillDownInputAttribute":{"usageTypeCode":"1006","statementNumber":"9900000182889","invoiceNumber":"148442927","accountNumber":"700000005112","invoicePeriod":"01 Jun 19 - 23 Jun 19","planInstanceDetailsList":[14485293],"taxInclusive":0,"taxRate":0},"drillDownEndpoint":"Usage Details","usageTypeName":"Int roaming data","isQueryable":true,"isDisputable":true,"chargeIdentifier":9869601,"chargeType":"UsageCharge","invoiceLineAttributes":[{"invoiceLineNumber":11,"invoiceTransactionId":197167992,"chargeExcludingGST":12,"chargeIncludingGST":12}]},{"excludingGstCost":4,"includingGstCost":4,"isAggregated":false,"isTaxable":false,"usageTypeNo":"10026332","units":"2","drillDownInputAttribute":{"usageTypeCode":"1013","statementNumber":"9900000182889","invoiceNumber":"148442927","accountNumber":"700000005112","invoicePeriod":"01 Jun 19 - 23 Jun 19","planInstanceDetailsList":[14485293],"taxInclusive":0,"taxRate":0},"drillDownEndpoint":"Usage Details","usageTypeName":"Int roaming texts","isQueryable":true,"isDisputable":true,"chargeIdentifier":9869601,"chargeType":"UsageCharge","invoiceLineAttributes":[{"invoiceLineNumber":12,"invoiceTransactionId":197167991,"chargeExcludingGST":2,"chargeIncludingGST":2},{"invoiceLineNumber":13,"invoiceTransactionId":197167961,"chargeExcludingGST":2,"chargeIncludingGST":2}]},{"excludingGstCost":6,"includingGstCost":6,"isAggregated":false,"isTaxable":false,"usageTypeNo":"10026330","units":"6min","drillDownInputAttribute":{"usageTypeCode":"1009","statementNumber":"9900000182889","invoiceNumber":"148442927","accountNumber":"700000005112","invoicePeriod":"01 Jun 19 - 23 Jun 19","planInstanceDetailsList":[14485295],"taxInclusive":0,"taxRate":0},"drillDownEndpoint":"Usage Details","usageTypeName":"Int roaming outgoing calls","isQueryable":true,"isDisputable":true,"chargeIdentifier":9869601,"chargeType":"UsageCharge","invoiceLineAttributes":[{"invoiceLineNumber":14,"invoiceTransactionId":197167997,"chargeExcludingGST":6,"chargeIncludingGST":6}]},{"excludingGstCost":6,"includingGstCost":6,"isAggregated":false,"isTaxable":false,"usageTypeNo":"10026331","units":"6min","drillDownInputAttribute":{"usageTypeCode":"1011","statementNumber":"9900000182889","invoiceNumber":"148442927","accountNumber":"700000005112","invoicePeriod":"01 Jun 19 - 23 Jun 19","planInstanceDetailsList":[14485295],"taxInclusive":0,"taxRate":0},"drillDownEndpoint":"Usage Details","usageTypeName":"Int roaming incoming calls","isQueryable":true,"isDisputable":true,"chargeIdentifier":9869601,"chargeType":"UsageCharge","invoiceLineAttributes":[{"invoiceLineNumber":15,"invoiceTransactionId":197167998,"chargeExcludingGST":6,"chargeIncludingGST":6}]}],"onceOffChargesAndCredits":[{"serviceType":"Device Charges","quantity":90,"excludingGstCost":9000,"includingGstCost":9900,"sigmaSpecId":"BSOTC001_CB","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":9877601,"chargeType":"OnceOffCharge","invoiceLineAttributes":[{"invoiceLineNumber":16,"invoiceTransactionId":197167998,"chargeExcludingGST":9000,"chargeIncludingGST":9900}]},{"serviceType":"Apple iPhone xs 128 GB Handset","quantity":3,"excludingGstCost":3600,"includingGstCost":3960,"isAggregated":true,"isTaxable":true,"isQueryable":true,"chargeIdentifier":9877605,"chargeType":"OnceOffCharge","invoiceLineAttributes":[{"invoiceLineNumber":17,"invoiceTransactionId":197167976,"chargeExcludingGST":-1200,"chargeIncludingGST":-1320},{"invoiceLineNumber":18,"invoiceTransactionId":197167977,"chargeExcludingGST":-1200,"chargeIncludingGST":-1320},{"invoiceLineNumber":19,"invoiceTransactionId":197167978,"chargeExcludingGST":-1200,"chargeIncludingGST":-1320}]},{"serviceType":"Apple iPhone xs 128 GB Handset","quantity":3,"excludingGstCost":-3960,"includingGstCost":-3960,"isAggregated":true,"isTaxable":false,"isQueryable":true,"isDisputable":false,"chargeIdentifier":9877606,"chargeType":"CreditCharge","invoiceLineAttributes":[{"invoiceLineNumber":20,"invoiceTransactionId":197167999,"chargeExcludingGST":-1320,"chargeIncludingGST":-1320},{"invoiceLineNumber":21,"invoiceTransactionId":197168000,"chargeExcludingGST":-1320,"chargeIncludingGST":-1320},{"invoiceLineNumber":22,"invoiceTransactionId":197168001,"chargeExcludingGST":-1320,"chargeIncludingGST":-1320}]}]}}]},{"offerName":"Corporate Mobile Plus","offerTotalExcludingGstCost":4823.18,"offerTotalIncludingGstCost":5025,"invoiceDef":2,"listOfChargesAndCredits":{"planCharges":[{"serviceType":"Top Down M BYO Plan","quantity":1,"excludingGstCost":50,"includingGstCost":55,"sigmaSpecId":"BSRC001_CB","startDate":"01 Jun","endDate":"30 Jun","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeType":"RecurringCharge","chargeIdentifier":49378,"invoiceLineAttributes":[{"invoiceLineNumber":28,"invoiceTransactionId":197353627,"chargeExcludingGST":50,"chargeIncludingGST":55,"chargeInstanceId":"PSvdf4b12-f9sf-5i0b-f6if-8mz5fv0r9a6i22"}]},{"serviceType":"Top Down M Without BYO Plan","quantity":1,"excludingGstCost":50,"includingGstCost":55,"sigmaSpecId":"BSRC001_CB","startDate":"01 Jun","endDate":"30 Jun","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeType":"RecurringCharge","chargeIdentifier":49384,"invoiceLineAttributes":[{"invoiceLineNumber":34,"invoiceTransactionId":197353633,"chargeExcludingGST":50,"chargeIncludingGST":55,"chargeInstanceId":"PSvdf4b12-f9sf-5i0b-f6if-8mz5fv0r9a6i23"}]},{"serviceType":"Top Down S BYO Plan","quantity":1,"excludingGstCost":50,"includingGstCost":55,"sigmaSpecId":"BSRC001_CB","startDate":"01 Jun","endDate":"30 Jun","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeType":"RecurringCharge","chargeIdentifier":49377,"invoiceLineAttributes":[{"invoiceLineNumber":29,"invoiceTransactionId":197353628,"chargeExcludingGST":50,"chargeIncludingGST":55,"chargeInstanceId":"PSvdf4b12-f9sf-5i0b-f6if-8mz5fv0r9a6i21"}]},{"serviceType":"Top Down S Without BYO Plan","quantity":1,"excludingGstCost":50,"includingGstCost":55,"sigmaSpecId":"BSRC001_CB","startDate":"01 Jun","endDate":"30 Jun","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeType":"RecurringCharge","chargeIdentifier":49383,"invoiceLineAttributes":[{"invoiceLineNumber":35,"invoiceTransactionId":197353634,"chargeExcludingGST":50,"chargeIncludingGST":55,"chargeInstanceId":"PSvdf4b12-f9sf-5i0b-f6if-8mz5fv0r9a6i24"}]},{"serviceType":"Apple iPhone 8 256GB Monthly Repayment Charge","quantity":1,"excludingGstCost":55,"includingGstCost":55,"sigmaSpecId":"BSRO001_CB","startDate":"01 Jun","endDate":"30 Jun","isAggregated":false,"isTaxable":false,"drillDownEndpoint":"Repayment details","drillDownInputAttribute":{"statementNumber":"9900000202486","chargeId":49379},"isQueryable":true,"isDisputable":true,"chargeType":"RecurringCharge","chargeIdentifier":49379,"invoiceLineAttributes":[{"invoiceLineNumber":27,"invoiceTransactionId":197353626,"chargeExcludingGST":55,"chargeIncludingGST":55,"chargeInstanceId":"PSvdf4b20-f9sf-5i0b-f6if-8mz5fv0r9a6i11"}]}],"usageSummaryCharges":[{"excludingGstCost":1818.18,"includingGstCost":2000,"isAggregated":false,"isTaxable":true,"usageTypeNo":"10026121","units":"0.19 GB","drillDownEndpoint":"Usage Details","drillDownInputAttribute":{"usageTypeCode":"1007","statementNumber":"9900000202486","invoiceNumber":"148512791","accountNumber":"700000002979","invoicePeriod":"01 May 19 - 31 May 19","planInstanceDetailsList":[14498284],"chargeId":49385,"taxInclusive":1,"taxRate":0},"usageTypeName":"Data usage above plan","isQueryable":true,"isDisputable":true,"chargeType":"UsageCharge","chargeIdentifier":49385,"invoiceLineAttributes":[{"invoiceLineNumber":36,"invoiceTransactionId":197353635,"chargeExcludingGST":1818.18,"chargeIncludingGST":2000,"chargeInstanceId":"PSvdo4b13-f9sf-5i8b-f6if-8mz5fv0r9a6i22"}]},{"excludingGstCost":200,"includingGstCost":200,"isAggregated":false,"isTaxable":false,"usageTypeNo":"10026336","units":"200","drillDownEndpoint":"Usage Details","drillDownInputAttribute":{"usageTypeCode":"7002","statementNumber":"9900000202486","invoiceNumber":"148512791","accountNumber":"700000002979","invoicePeriod":"01 May 19 - 31 May 19","planInstanceDetailsList":[14498279],"chargeId":49380,"taxInclusive":0,"taxRate":0},"usageTypeName":"International roaming day pass - zone 2","isQueryable":true,"isDisputable":true,"chargeType":"UsageCharge","chargeIdentifier":49380,"invoiceLineAttributes":[{"invoiceLineNumber":30,"invoiceTransactionId":197353629,"chargeExcludingGST":200,"chargeIncludingGST":200,"chargeInstanceId":"PSvdo4b13-f9sf-5i8b-f6if-8mz5fv0r9a6i21"}]},{"excludingGstCost":750,"includingGstCost":750,"isAggregated":false,"isTaxable":false,"usageTypeNo":"10026333","units":"0.48 GB","drillDownEndpoint":"Usage Details","drillDownInputAttribute":{"usageTypeCode":"1006","statementNumber":"9900000202486","invoiceNumber":"148512791","accountNumber":"700000002979","invoicePeriod":"01 May 19 - 31 May 19","planInstanceDetailsList":[14498279],"chargeId":49382,"taxInclusive":0,"taxRate":0},"usageTypeName":"International roaming data","isQueryable":true,"isDisputable":true,"chargeType":"UsageCharge","chargeIdentifier":49382,"invoiceLineAttributes":[{"invoiceLineNumber":32,"invoiceTransactionId":197353631,"chargeExcludingGST":750,"chargeIncludingGST":750,"chargeInstanceId":"PSvdo4b13-f9sf-5i8b-f6if-8mz5fv0r9a6i21"}]},{"excludingGstCost":1800,"includingGstCost":1800,"isAggregated":false,"isTaxable":false,"usageTypeNo":"10026331","units":"1hr","drillDownEndpoint":"Usage Details","drillDownInputAttribute":{"usageTypeCode":"1011","statementNumber":"9900000202486","invoiceNumber":"148512791","accountNumber":"700000002979","invoicePeriod":"01 May 19 - 31 May 19","planInstanceDetailsList":[14498279],"chargeId":49381,"taxInclusive":0,"taxRate":0},"usageTypeName":"International roaming incoming calls","isQueryable":true,"isDisputable":true,"chargeType":"UsageCharge","chargeIdentifier":49381,"invoiceLineAttributes":[{"invoiceLineNumber":31,"invoiceTransactionId":197353630,"chargeExcludingGST":1800,"chargeIncludingGST":1800,"chargeInstanceId":"PSvdo4b13-f9sf-5i8b-f6if-8mz5fv0r9a6i21"}]}],"onceOffChargesAndCredits":[{"serviceType":"Device Charges","quantity":90,"excludingGstCost":9000,"includingGstCost":9900,"sigmaSpecId":"BSOTC001_CB","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":9877601,"chargeType":"OnceOffCharge","invoiceLineAttributes":[{"invoiceLineNumber":16,"invoiceTransactionId":197167998,"chargeExcludingGST":9000,"chargeIncludingGST":9900}]},{"serviceType":"Apple iPhone xs 128 GB Handset","quantity":3,"excludingGstCost":3600,"includingGstCost":3960,"isAggregated":true,"isTaxable":true,"isQueryable":true,"chargeIdentifier":9877605,"chargeType":"OnceOffCharge","invoiceLineAttributes":[{"invoiceLineNumber":17,"invoiceTransactionId":197167976,"chargeExcludingGST":-1200,"chargeIncludingGST":-1320},{"invoiceLineNumber":18,"invoiceTransactionId":197167977,"chargeExcludingGST":-1200,"chargeIncludingGST":-1320},{"invoiceLineNumber":19,"invoiceTransactionId":197167978,"chargeExcludingGST":-1200,"chargeIncludingGST":-1320}]}]}}],"accountLevelChargesAndCredits":{"adjustmentsExcludingGstCost":0,"adjustmentsIncludingGstCost":0,"grossTotalBill":12130,"amountOfGstIncludedInGrossTotalBill":312.73,"totalNewChargesInThisBill":12130,"gstFreeItemsIncludedInNewCharges":8690,"gstIncludedInNewCharges":312.73,"adjustmentsTotal":0,"gstIncludedInAdjustments":0}}}';
        InvoiceResponseDTO obj = InvoiceResponseDTO.parse(json);
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Case_Record_Type).getRecordTypeId();
        Account accountData = TestDataFactory.generateAccount();
        Test.startTest();
        Contact contactData = TestDataFactory.generateContact('Test FirstName', accountData.id,'Active','Test LastName',System.today(),'Mobile');
        insert contactData;
        Boolean skipcallout=true;
        Billing_Account__c billingAccountData = TestDataFactory.generateBillingAccount('700000002978','Created',accountData.Id, contactData.Id);
        insert billingAccountData;
        Case caseData      = new Case(AccountId = accountData.Id,ContactId = contactData.Id,Status = 'New',Type = System.Label.Case_Type,RecordTypeId = caseRecordTypeId,Billing_Account__c = billingAccountData.Id);
        caseData.AccountId = accountData.Id;
        caseData.ContactId = contactData.Id;
        caseData.Type      = System.Label.Case_Type;
        insert caseData;
        Test.stopTest();
        Invoice__c invoiceData = new Invoice__c(Name = '9900000202350',Billing_Account__c = billingAccountData.Id,Aria_Invoice_Number__c = '012345678912345'); 
        insert  invoiceData;
        //List<Invoice_Line_Item__c> invoicelineitem = InvoiceCalloutHandler.updateAdjustmentLineItem(obj,invoiceData.id);
        List<Invoice_Line_Item__c> lineItemList = new List<Invoice_Line_Item__c> ();
        Invoice_Line_Item__c invoicerec = new Invoice_Line_Item__c();
        invoicerec.Invoice__c = invoiceData.id;
        invoicerec.Invoice_Transaction_ID__c = 001234;
        invoicerec.Line_Item_Identifier__c = 'TEST';
        invoicerec.Charge_Excluding_GST__c = 123.45;
        invoicerec.Charge_Including_GST__c = 123.45;
        lineItemList.add(invoicerec);
        InvoiceCalloutHandler.updateAdjustmentLineItem(obj,invoiceData.id, lineItemList);
        InvoiceCalloutHandler.saveInvoice(obj,skipcallout);
        System.assert(lineItemList != null);
    }
 /*----------------------------------------------------------------
    Method : adjustmentsummaryPositiveTest
    Author: Mohammed Zeeshan
    Story: EDGE-120657
    Description: Positive test method
    -------------------------------------------------------------------------------------*/
     @isTest
    public static void calloutInvoiceAdjustmenSuccess(){
        String invoiceNumber = '9900000182889';
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Case_Record_Type).getRecordTypeId();
        Account accountData = TestDataFactory.generateAccount();
        Contact contactData = TestDataFactory.generateContact('Test FirstName', accountData.id,'Active','Test LastName',System.today(),'Mobile');
        insert contactData;
        Billing_Account__c billingAccountData = TestDataFactory.generateBillingAccount('700000002978','Created',accountData.Id, contactData.Id);
        insert billingAccountData;
        Invoice__c invoiceData = new Invoice__c(Name = '9900000202350',Billing_Account__c = billingAccountData.Id,Aria_Invoice_Number__c = '012345678912345'); 
        insert  invoiceData;
        List<Invoice_Line_Item__c> lineItemList = new List<Invoice_Line_Item__c> ();
        Invoice_Line_Item__c invoicerec = new Invoice_Line_Item__c();
        invoicerec.Invoice__c = invoiceData.id;
        try{   
        InvoiceRequestDTO requestDto = InvoiceCalloutHandler.createPayload('700000005112',Long.valueOf(invoiceNumber));
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockInvoiceCallout('success_adj_Search'));
        InvoiceResponseDTO responseDto =  InvoiceCalloutHandler.calloutInvoiceByNumber(requestDto);
        InvoiceCalloutHandler.updateAdjustmentLineItem(responseDto,invoicerec.Invoice__c,lineItemList);
        system.debug('responseDto is -->'+responseDto);
        Test.stopTest();
        System.assertEquals(responseDto.adjustmentSummary!=null,true,'SuccessResponse');
        }
        catch(exception e){
            
        }
    }
    
    /*----------------------------------------------------------------
    Method : adjustmentsummaryPositiveTest
    Author: Jawahar
    Story: EDGE-120657
    Description: Refactored Method to get Credit once-off charges test method
    -------------------------------------------------------------------------------------*/
     @isTest
    public static void calloutGetCreditOnceOffCharge(){
        InvoiceCalloutHandler.CreditOffer invoiceCreditOffer = new InvoiceCalloutHandler.CreditOffer();
        InvoiceCalloutHandler.Offer offervalue = new InvoiceCalloutHandler.Offer();
        
        offervalue.identifier =23;
        offervalue.offerName='Test';
        offervalue.offerTotalExcludingGstCost =20.34;
        offervalue.offerTotalIncludingGstCost=33.23;
        offervalue.invoiceDef = 5;
        
        Test.startTest();
        
        InvoiceResponseDTO.ListOfChargesAndCredits credits = new InvoiceResponseDTO.ListOfChargesAndCredits();
        List<InvoiceResponseDTO.OnceOffChargesAndCredits> oneOffChargeAndCredits = new List<InvoiceResponseDTO.OnceOffChargesAndCredits>();
        InvoiceResponseDTO.OnceOffChargesAndCredits oneOffChargeAndCreditsvalue = new InvoiceResponseDTO.OnceOffChargesAndCredits();
        oneOffChargeAndCreditsvalue.serviceType ='Device Charges';
        oneOffChargeAndCreditsvalue.quantityWithUnit = 'Testing';
        oneOffChargeAndCreditsvalue.excludingGstCost = 9000;
        oneOffChargeAndCreditsvalue.includingGstCost =9900;
        oneOffChargeAndCreditsvalue.sigmaSpecId ='BSOTC001_CB';
        oneOffChargeAndCreditsvalue.isAggregated =false;
        oneOffChargeAndCreditsvalue.isTaxable =true;
        oneOffChargeAndCreditsvalue.isQueryable =true;
        oneOffChargeAndCreditsvalue.isDisputable =true;
        oneOffChargeAndCreditsvalue.chargeIdentifier =9877601;
        oneOffChargeAndCreditsvalue.chargeType ='OnceOffCharge';
        oneOffChargeAndCredits.add(oneOffChargeAndCreditsvalue);
        List<InvoiceResponseDTO.InvoiceLineAttributes> invocieAttributes  = new List<InvoiceResponseDTO.InvoiceLineAttributes>();
        InvoiceResponseDTO.InvoiceLineAttributes invocieAttributesValue = new InvoiceResponseDTO.InvoiceLineAttributes(); 
        invocieAttributesValue.invoiceLineNumber =16;
        invocieAttributesValue.invoiceTransactionId =197167998;
        invocieAttributesValue.chargeExcludingGST =9000;
        invocieAttributesValue.chargeIncludingGST =9000;
        invocieAttributes.add(invocieAttributesValue);
        oneOffChargeAndCredits[0].InvoiceLineAttributes=invocieAttributes;
        credits.OnceOffChargesAndCredits = oneOffChargeAndCredits;
        invoiceCreditOffer.Offer = offervalue;
        List<InvoiceCalloutHandler.CreditOffer> creditofferList = new List<InvoiceCalloutHandler.CreditOffer>();
        
        Map<Integer,InvoiceCalloutHandler.CreditOffer> creditoffer = new Map<Integer,InvoiceCalloutHandler.CreditOffer>();
        creditoffer.put(453,invoiceCreditOffer);
        
        String invoiceNumber = '9900000182889';
        
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Case_Record_Type).getRecordTypeId();
        Account accountData = TestDataFactory.generateAccount();
        Contact contactData = TestDataFactory.generateContact('Test FirstName', accountData.id,'Active','Test LastName',System.today(),'Mobile');
        insert contactData;
        Billing_Account__c billingAccountData = TestDataFactory.generateBillingAccount('700000002978','Created',accountData.Id, contactData.Id);
        insert billingAccountData;
        Invoice__c invoiceData = new Invoice__c(Name = '9900000202350',Billing_Account__c = billingAccountData.Id,Aria_Invoice_Number__c = '012345678912345'); 
        insert  invoiceData;
        List<Invoice_Line_Item__c> lineItemList = new List<Invoice_Line_Item__c> ();
        Invoice_Line_Item__c invoicerec = new Invoice_Line_Item__c();
        invoicerec.Invoice__c = invoiceData.id;
        lineItemList.add(invoicerec);
        system.debug('----List'+lineItemList);
        system.debug('----credits'+credits);
        system.debug('----offervalue'+offervalue);
        system.debug('----invoiceData.id'+invoiceData.id);
        InvoiceCalloutHandler.getCreditOnceOffCharges(lineItemList,credits,offervalue,invoiceData.id);
        system.debug('----List'+lineItemList);
        Test.stopTest();
        System.assertEquals(lineItemList!=null,true,'SuccessResponse');
       
    }
    /*----------------------------------------------------------------
    Method : informMStoEnrichQLIpositivetest
    Author: shubhi V
    Story: EDGE-212404
    Description: Positive test method
    -------------------------------------------------------------------------------------*/
    @isTest
    public static void informMStoEnrichQLIPositiveTest(){
        String invoiceNumber = '1232';
        Case caseObj=[Select id from case limit 1];
        try{   
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new InvoiceCaseMSMock(202));
                String response=InvoiceCalloutHandler.informMStoEnrichQLI(caseObj.id,invoiceNumber);
                System.assertEquals(response=='Success',true,'SuccessResponse');
            Test.stopTest();
        }
        catch(exception e){
            
        }
    }
    /*----------------------------------------------------------------
    Method : informMStoEnrichQLINegativetest
    Author: shubhi V
    Story: EDGE-212404
    Description: Positive test method
    -------------------------------------------------------------------------------------*/
    @isTest
    public static void informMStoEnrichQLINegativetest(){
        String invoiceNumber = '1232';
        Case caseObj=[Select id from case limit 1];
        try{   
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new InvoiceCaseMSMock(500));
                String response=InvoiceCalloutHandler.informMStoEnrichQLI(caseObj.id,invoiceNumber);
                System.assertEquals(response=='Failure',true,'SuccessResponse');
            Test.stopTest();
        }
        catch(exception e){
            
        }
    }
     /*----------------------------------------------------------------
    Method : informMStoEnrichQLINegativetest
    Author: shubhi V
    Story: EDGE-212404
    Description: Positive test method
    -------------------------------------------------------------------------------------*/
    @isTest
    public static void informMStoEnrichQLIBulkPositivetest(){
        String invoiceNumber = '1232';
        Case caseObj=[Select id from case limit 1];
        Set<String> newinvoiceSetFinal=new Set<String>{'9900000202350'};
        Map<String,Set<String>> caseToInvoicenumListMap=new  Map<String,Set<String>>();
        caseToInvoicenumListMap.put(caseObj.id,newinvoiceSetFinal);
        try{   
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new InvoiceCaseMSMock(500));
                 InvoiceCalloutHandler.informMStoEnrichQLIBulk(caseToInvoicenumListMap);
                System.assertEquals(invoiceNumber,'1232');
            Test.stopTest();
        }
        catch(exception e){
            
        }
    }
}