/********************************************************************
EDGE        : EDGE-117021, EDGE-116922, EDGE-124053, EDGE-116083, EDGE-124045, EDGE-124896
Controller  : OneFundRetrospectiveRedemptionTest
Description : OneFund Retrospective Redemptions
Author      : Hari/Vamshi 

*******************************************************************/
@isTest
public class OneFundRetrospectiveRedemptionTest {    
    public static id committedFundRecId = Schema.SObjectType.OneFund__c.getRecordTypeInfosByDeveloperName().get('OneFund_Committed').getRecordTypeId();
    public static Id AccrualRecordId = Schema.SObjectType.OneFund_Transactions__c.getRecordTypeInfosByDeveloperName().get('OneFund_Accrual').getRecordTypeId();
    public static Id RetrospectiveRedemptionRecordId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Billing_OneFund_Retrospective_Redemption').getRecordTypeId();   
    @testSetup
    static void testData(){
        /*Profile p = [select Id,name from Profile where Name ='Sales Enterprise B2B'];
                User u1 = new User(alias = 'sales', email='salesuser@noemail.com',
                           emailencodingkey='UTF-8', lastname='Test salesuser', languagelocalekey='en_US',
                           localesidkey='en_US', profileid = p.id, country='United States',IsActive =true,
                           timezonesidkey='America/Los_Angeles', username='salesuser@noemail.com',phone='+121231231234');       
        insert u1;*/
        User u1 =TestDataFactory.createTestUser('Sales Enterprise B2B');
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'OneFund_Admin'];
        insert new PermissionSetAssignment(AssigneeId = u1.id, PermissionSetId = ps.Id);
    }
   //Method to insert test case 
    public static case inserttestcase(){
        Account accountRecord = APTPS_TestClassData.accountRecord('Fund Trigger Test','1233211230');
        Apttus__APTS_Agreement__c agreementRecord = APTPS_TestClassData.agreementRecord(accountRecord.Id);              
        Billing_Account__c OneFundRBillingAccount = new Billing_Account__c(Account__c= accountRecord.id, Billing_Account_Name__c='TestOneFund',Billing_Account_Number__c='121298645728');
        insert OneFundRBillingAccount;
        case OneFundRcase =new case(Account=accountRecord,Billing_Account__c= OneFundRBillingAccount.id,Subject='OneFundTest',status = 'New', RecordTypeId=RetrospectiveRedemptionRecordId);
        insert OneFundRcase;
        System.assertequals('OneFundTest',OneFundRcase.Subject);
        System.assertNotequals(null,OneFundRcase.Subject);
        return OneFundRcase;        
    }    
    @isTest
    Public static void getcaseDetatilsTestmethod(){ 
        case caseDetails=OneFundRetrospectiveRedemptionTest.inserttestcase();
        Test.startTest();
        case caseRecord=OneFundRetrospectiveRedemption.getcaseDetatils(caseDetails.id);
        system.assertEquals(caseRecord.Status,'New');
        Test.stopTest();
    }
    
    //Method to cover the code for AvailableOneFundBalanceTestmethod.
    //EDGE-124896
    @isTest
    Public static void AvailableOneFundBalanceTestmethod(){ 
        Id AccrualRecordId = Schema.SObjectType.OneFund_Transactions__c.getRecordTypeInfosByDeveloperName().get('OneFund_Accrual').getRecordTypeId();
        Account a = new Account(Name='OneFundTest');
        insert a;
        system.debug(a.id);
        List<OneFund__c> fundList = new List<OneFund__c>();
        List<OneFund_Transactions__c> fundTransList = new List<OneFund_Transactions__c>();
        OneFund__c fundRecord1 = new OneFund__c(CIDN__c = a.id);
        insert fundRecord1;
        OneFund_Transactions__c fundTransactionRecord3 = new OneFund_Transactions__c(OneFund__c = fundRecord1.id,
                                                                                     RecordTypeId = AccrualRecordId,  
                                                                                     Transaction_Amount__c=3000.00,Transaction_Status__c='Active');
        insert fundTransactionRecord3;
        system.debug(a.id);
        system.debug(fundTransactionRecord3.Transaction_Amount__c);
        case OneFundRcase =new case(Account=a,Subject='OneFundTest',status = 'New', RecordTypeId=RetrospectiveRedemptionRecordId);
        insert OneFundRcase;
        id caseid=OneFundRcase.Id;
        Decimal OneFundBalance= OneFundRetrospectiveRedemption.GetAvailableOneFundBalance(caseid);
        system.assertEquals(0.0,OneFundBalance);
        
    } 
    //Method to cover the code for insertQueriedLineItems.
    //EDGE-116083
    @isTest
    Public static void InsertQueriedLineItemsTestmethod(){ 
        case caseRecord=OneFundRetrospectiveRedemptionTest.inserttestcase();
        string invoices ='[{"accountNumber":"700000338751","ariaInvoiceNumber":"148148064","balanceCarriedForward":-1000,"chargeExcludingGST":250,"chargeIncludingGST":1375,"chargeType":"OnceOffCharge","errorKey":"","excludingGstCost":250,"Flag":"N","id":1,"includingGstCost":275,"invoiceDef":1,"invoiceIssueDate":"30 Aug 18","invoiceLineNumber":3,"invoiceNumber":"9900000002386","invoicePeriod":"01 Aug 18 - 30 Aug 18","invoiceTransactionId":196309338,"isAggregated":false,"isTaxable":true,"newCharge":770,"offername":"Connected Workplace","offerTotalExcludingGstCost":700,"offerTotalIncludingGstCost":770,"paymentsAndAdjustments":1000,"physicalLocationName":"150 lonsdale street","quantity":5,"servicetype":"Polycom VVX 411","sigmaSpecId":"BSOTC001_CB","siteExcludingGstCost":700,"siteIncludingGstCost":770,"totalDue":-230},{"accountNumber":"700000338751","ariaInvoiceNumber":"148148064","balanceCarriedForward":-1000,"chargeExcludingGST":350,"chargeIncludingGST":1875,"chargeType":"OnceOffCharge","errorKey":"","excludingGstCost":350,"Flag":"N","id":2,"includingGstCost":375,"invoiceDef":1,"invoiceIssueDate":"30 Aug 18","invoiceLineNumber":3,"invoiceNumber":"9900000002386","invoicePeriod":"01 Aug 18 - 30 Aug 18","invoiceTransactionId":196309338,"isAggregated":false,"isTaxable":true,"newCharge":770,"offername":"Connected Workplace","offerTotalExcludingGstCost":700,"offerTotalIncludingGstCost":770,"paymentsAndAdjustments":1000,"physicalLocationName":"150 lonsdale street","quantity":5,"servicetype":"Poly VVX 411","sigmaSpecId":"BSOTC001_CB","siteExcludingGstCost":700,"siteIncludingGstCost":770,"totalDue":-230}]';
        string redemptions='[{"nullredemptionamt":"111","id":"1"},{"nullredemptionamt":"111","id":"2"}]';
        Account accountRecord = APTPS_TestClassData.accountRecord('Fund Trigger Test','1233211231');
        Billing_Account__c OneFundRBillingAccount =new Billing_Account__c(Account__c=accountRecord.id, Billing_Account_Name__c='TestOneFund',Billing_Account_Number__c='221298645728');
        insert OneFundRBillingAccount;
        case OneFundRcase =new case(Account=accountRecord,Billing_Account__c=OneFundRBillingAccount.id,Subject='OneFundTest',status = 'New', RecordTypeId=RetrospectiveRedemptionRecordId);
        insert OneFundRcase;
        Credits_and_Adjustments__c cra = new  Credits_and_Adjustments__c();
        cra.Case_Number__c =  OneFundRcase.id;
        cra.Comments__c ='Dispute Against';
        cra.Charge_Status__c ='Pending';
        insert cra;
        system.debug('credi and adjustment'+cra);
        OneFund__c ofc  = new OneFund__c();
        ofc.Billing_Account__c = OneFundRBillingAccount.id ;
        ofc.CIDN__c = accountRecord.id ;
        insert ofc;
        OneFund_Transactions__c otr = new OneFund_Transactions__c();
        otr.Redeemed_Amount__c = 20;
        otr.Transaction_Status__c ='Pending';
        otr.Case_Number__c = OneFundRcase.id;
        otr.OneFund__c = ofc.id;
        insert otr;
        Invoice__c inv = new Invoice__c();
        Inv.name = '9900000182888';
        inv.Aria_Invoice_Number__c ='148148064';
        inv.Payments_and_Adjustments__c =0.0;
        insert inv;
        Invoice_Line_Item__c invlineitem =new Invoice_Line_Item__c();
        invlineitem.Invoice_Line_Number__c =7;
        invlineitem.Offer_Name__c ='Connected Workplace';
        invlineitem.Quantity__c ='3';
        invlineitem.Charge_Including_GST__c =450.00;
        invlineitem.Charge_Type__c = 'OnceOffCharge';
        invlineitem.Charge_Excluding_GST__c =450.00;
        invlineitem.Charge_Identifier__c =10566;
        invlineitem.Is_Queryable__c =true;
        invlineitem.Excluding_Cost__c=450.00;
        invlineitem.Invoice_Transaction_ID__c =200989724;
        invlineitem.Invoice__c =inv.id;
        insert invlineitem;
        Test.startTest(); 
        OneFundRetrospectiveRedemption.insertQueriedLineItems(invoices,redemptions,caseRecord.id);
        Test.stopTest(); 
        Queried_Line_Item__c  qli =[SELECT Case__c,Invoice_Line_Number__c,Line_Item_Identifier__c,Redemption_Amount__c FROM Queried_Line_Item__c WHERE Case__c =: caseRecord.id  limit 1];
        system.assertEquals(3.0,qli.Invoice_Line_Number__c);
        system.assertEquals(111.0,qli.Redemption_Amount__c);        
    }
    
    //Method to cover the code for getQueriedLineItems.
    //EDGE-116083
    @isTest
    Public static void getQueriedLineItemsTestmethod(){         
        string invoices ='[{"accountNumber":"700000338751","ariaInvoiceNumber":"148148064","balanceCarriedForward":-1000,"chargeExcludingGST":250,"chargeIncludingGST":1375,"chargeType":"OnceOffCharge","errorKey":"","excludingGstCost":250,"Flag":"N","id":1,"includingGstCost":275,"invoiceDef":1,"invoiceIssueDate":"30 Aug 18","invoiceLineNumber":3,"invoiceNumber":"9900000002386","invoicePeriod":"01 Aug 18 - 30 Aug 18","invoiceTransactionId":196309338,"isAggregated":false,"isTaxable":true,"newCharge":770,"offername":"Connected Workplace","offerTotalExcludingGstCost":700,"offerTotalIncludingGstCost":770,"paymentsAndAdjustments":1000,"physicalLocationName":"150 lonsdale street","quantity":5,"servicetype":"Polycom VVX 411","sigmaSpecId":"BSOTC001_CB","siteExcludingGstCost":700,"siteIncludingGstCost":770,"totalDue":-230},{"accountNumber":"700000338751","ariaInvoiceNumber":"148148064","balanceCarriedForward":-1000,"chargeExcludingGST":350,"chargeIncludingGST":1875,"chargeType":"OnceOffCharge","errorKey":"","excludingGstCost":350,"Flag":"N","id":2,"includingGstCost":375,"invoiceDef":1,"invoiceIssueDate":"30 Aug 18","invoiceLineNumber":3,"invoiceNumber":"9900000002386","invoicePeriod":"01 Aug 18 - 30 Aug 18","invoiceTransactionId":196309338,"isAggregated":false,"isTaxable":true,"newCharge":770,"offername":"Connected Workplace","offerTotalExcludingGstCost":700,"offerTotalIncludingGstCost":770,"paymentsAndAdjustments":1000,"physicalLocationName":"150 lonsdale street","quantity":5,"servicetype":"Poly VVX 411","sigmaSpecId":"BSOTC001_CB","siteExcludingGstCost":700,"siteIncludingGstCost":770,"totalDue":-230}]';
        string redemptions='[{"nullredemptionamt":"111","id":"1"},{"nullredemptionamt":"111","id":"2"}]';        
        Account accountRecord = APTPS_TestClassData.accountRecord('Fund Trigger Test','1233211231');
        Billing_Account__c OneFundRBillingAccount =new Billing_Account__c(Account__c=accountRecord.id, Billing_Account_Name__c='TestOneFund',Billing_Account_Number__c='221298645728');
        insert OneFundRBillingAccount;
        case OneFundRcase =new case(Account=accountRecord,Billing_Account__c=OneFundRBillingAccount.id,Subject='OneFundTest',status = 'New', RecordTypeId=RetrospectiveRedemptionRecordId);
        insert OneFundRcase;
        Credits_and_Adjustments__c cra = new  Credits_and_Adjustments__c();
        cra.Case_Number__c =  OneFundRcase.id;
        cra.Comments__c ='Dispute Against';
        cra.Charge_Status__c ='Pending';
        insert cra;
        system.debug('credi and adjustment'+cra);
        OneFund__c ofc  = new OneFund__c();
        ofc.Billing_Account__c = OneFundRBillingAccount.id ;
        ofc.CIDN__c = accountRecord.id ;
        insert ofc;
        OneFund_Transactions__c otr = new OneFund_Transactions__c();
        otr.Redeemed_Amount__c = 20;
        otr.Transaction_Status__c ='Pending';
        otr.Case_Number__c = OneFundRcase.id;
        otr.OneFund__c = ofc.id;
        insert otr;
        Invoice__c inv = new Invoice__c();
        Inv.name = '9900000182888';
        inv.Aria_Invoice_Number__c ='148148064';
        inv.Payments_and_Adjustments__c =0.0;
        insert inv;
        Invoice_Line_Item__c invlineitem =new Invoice_Line_Item__c();
        invlineitem.Invoice_Line_Number__c =7;
        invlineitem.Offer_Name__c ='Connected Workplace';
        invlineitem.Quantity__c ='3';
        invlineitem.Charge_Including_GST__c =450.00;
        invlineitem.Charge_Type__c = 'OnceOffCharge';
        invlineitem.Charge_Excluding_GST__c =450.00;
        invlineitem.Charge_Identifier__c =10566;
        invlineitem.Is_Queryable__c =true;
        invlineitem.Excluding_Cost__c=450.00;
        invlineitem.Invoice_Transaction_ID__c =200989724;
        invlineitem.Invoice__c =inv.id;
        insert invlineitem;
        Queried_Line_Item__c  qli = new Queried_Line_Item__c(); 
        qli.Invoice_Line_Item__c =invlineitem.id;
        qli.Invoice_Line_Number__c = 7;
        qli.Invoice_Transaction_ID__c ='200989724 ';
        qli.Line_Item_Identifier__c ='10566';
        qli.Max_Credit_Amount__c =450.00;
        qli.Redemption_Amount__c = 450.00;
        qli.Credit_Adjustment__c = cra.Id;
        qli.Case__c = OneFundRcase.id ;
        insert qli;
        Test.startTest();
        OneFundRetrospectiveRedemption.getQueriedLineItems(invoices,redemptions);
        Test.stopTest();
        Queried_Line_Item__c  qli1 =[SELECT Case__c,Invoice_Line_Number__c,Redemption_Amount__c FROM Queried_Line_Item__c WHERE Case__c =: OneFundRcase.id limit 1];
        system.assertEquals(7,qli1.Invoice_Line_Number__c);       
           }
    
    //Method to cover the code for getQueriedLineItems.
    //EDGE-116083
    ////Method to cover the code for insertInvoices.
    //EDGE-124045
    @isTest
    Public static void Testmethodnegative(){         
        Boolean success = true;
        try {
            List<Invoice_Line_Item__c> lnvlist = new list<Invoice_Line_Item__c>();
            string  CustomerAccountNumber = '';
            string  AriainvoiceNumber ='';
            string invoices='';
            string redemptions='[{"nullredemptionamt":"111","id":"1"},{"nullredemptionamt":"111","id":"2"}]';   
            case caseDetails =OneFundRetrospectiveRedemptionTest.inserttestcase();
            Test.startTest();
            OneFundRetrospectiveRedemption.insertInvoices(invoices, caseDetails);
            OneFundRetrospectiveRedemption.getQueriedLineItems(invoices,redemptions);
            OneFundRetrospectiveRedemption.insertQueriedLineItems(invoices,redemptions,caseDetails.id);
            Test.setMock(HttpCalloutMock.class, new MockOneFundInvoiceCallout('success_Search'));
            Test.setMock(HttpCalloutMock.class, new MockOneFundInvoiceCallout('success_Search2'));
            List<OneFundRetrospectiveRedemption.invoiceLineitem> responseDto = OneFundRetrospectiveRedemption.callAria(invoices, caseDetails.id);
            EligibleRedemAmountRequestDTO  ERAresp_DTO   =   OneFundRetrospectiveRedemption.generatePayLoadforExistingInvoice(lnvlist, customerAccountNumber, ariaInvoiceNumber);
            Test.stopTest();
        } catch (Exception e) {
            success = false;
        } finally {
            system.assertNotEquals(true,success);
        }  
        
    }
    //Method to cover the code for insertInvoices.
    //EDGE-124045
    @isTest 
    PUblic static void insertInvLineItemsTestMethod(){
        case caseDetails =OneFundRetrospectiveRedemptionTest.inserttestcase();
        string invoices ='[{"accountNumber":"700000338751","ariaInvoiceNumber":"148148064","balanceCarriedForward":-1000,"chargeExcludingGST":250,"chargeIncludingGST":1375,"chargeType":"OnceOffCharge","errorKey":"","excludingGstCost":250,"Flag":"N","id":1,"includingGstCost":275,"invoiceDef":1,"invoiceIssueDate":"30 Aug 18","invoiceLineNumber":3,"invoiceNumber":"9900000002386","invoicePeriod":"01 Aug 18 - 30 Aug 18","invoiceTransactionId":196309338,"isAggregated":false,"isTaxable":true,"newCharge":770,"offername":"Connected Workplace","offerTotalExcludingGstCost":700,"offerTotalIncludingGstCost":770,"paymentsAndAdjustments":1000,"physicalLocationName":"150 lonsdale street","quantity":5,"servicetype":"Polycom VVX 411","sigmaSpecId":"BSOTC001_CB","siteExcludingGstCost":700,"siteIncludingGstCost":770,"totalDue":-230},{"accountNumber":"700000338751","ariaInvoiceNumber":"148148064","balanceCarriedForward":-1000,"chargeExcludingGST":350,"chargeIncludingGST":1875,"chargeType":"OnceOffCharge","errorKey":"","excludingGstCost":350,"Flag":"N","id":2,"includingGstCost":375,"invoiceDef":1,"invoiceIssueDate":"30 Aug 18","invoiceLineNumber":3,"invoiceNumber":"9900000002386","invoicePeriod":"01 Aug 18 - 30 Aug 18","invoiceTransactionId":196309338,"isAggregated":false,"isTaxable":true,"newCharge":770,"offername":"Connected Workplace","offerTotalExcludingGstCost":700,"offerTotalIncludingGstCost":770,"paymentsAndAdjustments":1000,"physicalLocationName":"150 lonsdale street","quantity":5,"servicetype":"Poly VVX 411","sigmaSpecId":"BSOTC001_CB","siteExcludingGstCost":700,"siteIncludingGstCost":770,"totalDue":-230}]';
        OneFundRetrospectiveRedemption.insertInvoices(invoices, caseDetails);
        Invoice__c  Inv =[SELECT Aria_Invoice_Number__c FROM Invoice__c WHERE Aria_Invoice_Number__c = '148148064' ];
        system.assertEquals('148148064',Inv.Aria_Invoice_Number__c);
    }
    //Method to cover the code for callAria for Existing invoice.
    //EDGE-116222
    @isTest
    Public static void callAriaTestMethod(){ 
        case caseRecord=OneFundRetrospectiveRedemptionTest.inserttestcase();
        Credits_and_Adjustments__c cra = new  Credits_and_Adjustments__c();
        cra.Case_Number__c =  caseRecord.id;
        cra.Comments__c ='Dispute Against';
        cra.Charge_Status__c ='Pending';
        insert cra;
        Invoice__c inv = new Invoice__c();
        Inv.name = '9900000182888';
        inv.Aria_Invoice_Number__c ='148148064';
        inv.Payments_and_Adjustments__c =0.0;
        insert inv;
        Invoice_Line_Item__c invlineitem =new Invoice_Line_Item__c();
        invlineitem.Invoice_Line_Number__c =2;
        invlineitem.Offer_Name__c ='Connected Workplace';
        invlineitem.Quantity__c ='3';
        invlineitem.Charge_Including_GST__c =450.00;
        invlineitem.Charge_Type__c = 'RecurringCharge';
        invlineitem.Charge_Excluding_GST__c =450.00;
        invlineitem.Charge_Identifier__c =10566;
        invlineitem.Is_Queryable__c =true;
        invlineitem.Excluding_Cost__c=450.00;
        invlineitem.Invoice_Transaction_ID__c =200989724;
        invlineitem.Charge_Type__c = 'OnceOffCharge';
        invlineitem.Invoice__c =inv.id;
        insert invlineitem;
        Queried_Line_Item__c  qli = new Queried_Line_Item__c();
        qli.Invoice_Line_Item__c =invlineitem.id;
        qli.Invoice_Line_Number__c = 9900000182888.00 ;
        qli.Invoice_Transaction_ID__c ='200989724 ';
        qli.Line_Item_Identifier__c ='10566';
        qli.Max_Credit_Amount__c =450.00;
        qli.Redemption_Amount__c = 450.00;
        qli.Credit_Adjustment__c = cra.Id;
        qli.Case__c =caseRecord.id;
        insert qli;
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new MockOneFundInvoiceCallout('success_Search'));
        Test.setMock(HttpCalloutMock.class, new MockOneFundInvoiceCallout('success_Search2'));
        List<OneFundRetrospectiveRedemption.invoiceLineitem> responseDto = OneFundRetrospectiveRedemption.callAria('9900000182888', caseRecord.id); 
        System.assertnotequals(null,responseDto);
        system.assertEquals(responseDto[0].ariaInvoiceNumber,'148148064');
        Test.stopTest();  
    }
    //EDGE-116222
    // method to cover for callAria new invoice   
    @isTest
    Public static void callAriaTestMethodforNewInvoice(){ 
        case caseRecord=OneFundRetrospectiveRedemptionTest.inserttestcase();
        String invoiceNumber = '9900000182889';
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new MockOneFundInvoiceCallout('success_Search'));
        Test.setMock(HttpCalloutMock.class, new MockOneFundInvoiceCallout('success_Search2'));
        List<OneFundRetrospectiveRedemption.invoiceLineitem> responseDto = OneFundRetrospectiveRedemption.callAria(invoiceNumber, caseRecord.id);
        system.debug('responseDto is -->'+responseDto);
        system.assertEquals(responseDto[0].ariaInvoiceNumber,'149311676');
        Test.stopTest();       
    }
    //method to cover genertate payload for existing invoice.
    //EDGE-116222
    @istest
    Public static void generatePayLoadforinvoiceTest(){ 
        List<Invoice_Line_Item__c> lnvlist = new list<Invoice_Line_Item__c>();
        Invoice__c inv1 = new Invoice__c();
        Inv1.name = '9900000182889';
        inv1.Aria_Invoice_Number__c ='148148065';
        insert inv1;
        Invoice_Line_Item__c inv =new Invoice_Line_Item__c();
        inv.Invoice_Line_Number__c =2;
        inv.Offer_Name__c ='Connected Workplace';
        inv.Quantity__c ='3';
        inv.Charge_Including_GST__c =450.00;
        inv.Charge_Type__c = 'RecurringCharge';
        inv.Charge_Excluding_GST__c =450.00;
        inv.Charge_Identifier__c =10566;
        inv.Is_Queryable__c =true;
        inv.Excluding_Cost__c=450.00;
        inv.Invoice_Transaction_ID__c =200989724;
        inv.Invoice__c =inv1.id;
        insert inv;
        if(inv.id!= null){
            lnvlist.add(inv);
            system.debug('lnvlist'+lnvlist);
        }
        string  CustomerAccountNumber = '700000338751';
        string  AriainvoiceNumber ='149311676';
        EligibleRedemAmountRequestDTO  ERAresp_DTO   =   OneFundRetrospectiveRedemption.generatePayLoadforExistingInvoice(lnvlist, customerAccountNumber, ariaInvoiceNumber);
       system.debug('ERAresp_DTO is -->'+ERAresp_DTO);
        system.assertNotEquals(null, ERAresp_DTO);
        System.assertEquals(ERAresp_DTO.customerAccountNumber, '700000338751');
                // generatePayLoadforinvoice(Invlist,CustomerAccountNumber,AriainvoiceNumber);   
    }
    // EDGE-116222
    // method to cover getivoicelineitems 
    @isTest
    Public static void  getInvoiceLineitemsTest(){
        String json = '{"customerAddress":{"companyName":"MLC Company Ltd.","addressLine1":"Unit 1 1234 Lostmy Way","addressCity":"Sydney","stateAndPostalCode":"NSW 2000"},"invoiceDetails":{"accountNumber":"700000002978","invoiceNumber":"9900000202350","invoiceIssueDate":"24 Jul 19","invoicePeriod":"01 Mar 19 - 31 Mar 19","ariaInvoiceNumber":"148512498"},"paymentSummary":{"balanceCarriedForward":-603.02,"totalDue":298.98,"paymentsAndAdjustments":603.02,"dueDate":"07 Aug 19","newCharges":902},"serviceSummary":{"listOfOffers":[{"offerName":"Connected Workplace","offerTotalExcludingGstCost":590,"offerTotalIncludingGstCost":902,"invoiceDef":1,"listOfProducts":[{"physicalLocationName":"400 George St Sydney NSW","siteExcludingGstCost":590,"siteIncludingGstCost":902,"listOfChargesAndCredits":{"planCharges":[{"serviceType":"Bandwidth Bolt On","quantity":1,"excludingGstCost":50,"includingGstCost":55,"sigmaSpecId":"BSRC001_CB","startDate":"01 Apr","endDate":"30 Apr","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4261,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":5,"invoiceTransactionId":197352167,"chargeExcludingGST":50,"chargeIncludingGST":55}]},{"serviceType":"Apple iPhone 8 64GB Monthly Repayment Charge","quantity":2,"excludingGstCost":110,"includingGstCost":110,"sigmaSpecId":"BSRO001_CB","isAggregated":true,"isTaxable":false,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4274,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":7,"invoiceTransactionId":197352169,"chargeExcludingGST":55,"chargeIncludingGST":55},{"invoiceLineNumber":6,"invoiceTransactionId":197352168,"chargeExcludingGST":55,"chargeIncludingGST":55}],"drillDownInputAttribute":{"statementNumber":"9900000202350","chargeId":4274},"drillDownEndpoint":"Repayment details"},{"serviceType":"Fixed Seat (Zone 1)","quantity":1,"excludingGstCost":50,"includingGstCost":55,"sigmaSpecId":"BSRC001_CB","startDate":"01 Apr","endDate":"30 Apr","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4260,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":8,"invoiceTransactionId":197352170,"chargeExcludingGST":50,"chargeIncludingGST":55}]}],"onceOffChargesAndCredits":[{"serviceType":"Jabra Stealth UC","quantity":1,"excludingGstCost":30,"includingGstCost":33,"sigmaSpecId":"BSOTC001_CB","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4269,"chargeType":"OnceOffCharge","disputeAttributes":[{"invoiceLineNumber":11,"invoiceTransactionId":197352173,"chargeExcludingGST":30,"chargeIncludingGST":33}]},{"serviceType":"Polaris Soundpro Touch 790","quantity":1,"excludingGstCost":35,"includingGstCost":38.5,"sigmaSpecId":"BSOTC001_CB","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4268,"chargeType":"OnceOffCharge","disputeAttributes":[{"invoiceLineNumber":12,"invoiceTransactionId":197352174,"chargeExcludingGST":35,"chargeIncludingGST":38.5}]},{"serviceType":"Polaris Soundpro Touch 790","quantity":1,"excludingGstCost":135,"includingGstCost":148.5,"sigmaSpecId":"BSOTC001_CB","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4267,"chargeType":"OnceOffCharge","disputeAttributes":[{"invoiceLineNumber":13,"invoiceTransactionId":197352175,"chargeExcludingGST":135,"chargeIncludingGST":148.5}]},{"serviceType":"Polaris Soundpro SW10ND","quantity":3,"excludingGstCost":420,"includingGstCost":462,"sigmaSpecId":"BSOTC001_CB","isAggregated":true,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4275,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":14,"invoiceTransactionId":197352176,"chargeExcludingGST":140,"chargeIncludingGST":154},{"invoiceLineNumber":10,"invoiceTransactionId":197352172,"chargeExcludingGST":140,"chargeIncludingGST":154},{"invoiceLineNumber":9,"invoiceTransactionId":197352171,"chargeExcludingGST":140,"chargeIncludingGST":154}]},{"serviceType":"Apple iPhone 8 64GB","quantity":2,"excludingGstCost":2400,"includingGstCost":2640,"isAggregated":true,"isTaxable":true,"isQueryable":true,"isDisputable":false,"chargeIdentifier":4277,"chargeType":"OnceOffCharge"},{"serviceType":"Apple iPhone 8 64GB","quantity":2,"excludingGstCost":-2640,"includingGstCost":-2640,"isAggregated":true,"isTaxable":false,"isQueryable":true,"isDisputable":false,"chargeIdentifier":4276,"chargeType":"CreditCharge"}]}}]}],"accountLevelChargesAndCredits":{"adjustmentsExcludingGstCost":0,"adjustmentsIncludingGstCost":0,"grossTotalBill":902,"amountOfGstIncludedInGrossTotalBill":312,"totalNewChargesInThisBill":902,"gstFreeItemsIncludedInNewCharges":110,"gstIncludedInNewCharges":312,"adjustmentsTotal":-603.02,"gstIncludedInAdjustments":-54.82}},"adjustmentSummary":{"totalAdjustmentsCost":-603.02,"totalGSTIncludedInAdjustments":-54.82,"adjustments":[{"adjustmentDescription":"Compensation Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-150.38,"gstIncludedInAdjustments":-13.67,"isQueryable":true,"isDisputable":false,"chargeIdentifier":80,"chargeType":"CreditCharge"},{"adjustmentDescription":"Goodwill Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-100.66,"gstIncludedInAdjustments":-9.15,"isQueryable":true,"isDisputable":false,"chargeIdentifier":78,"chargeType":"CreditCharge"},{"adjustmentDescription":"Goodwill Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-100.66,"gstIncludedInAdjustments":-9.15,"isQueryable":true,"isDisputable":false,"chargeIdentifier":79,"chargeType":"CreditCharge"},{"adjustmentDescription":"Compensation Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-150.66,"gstIncludedInAdjustments":-13.7,"isQueryable":true,"isDisputable":false,"chargeIdentifier":77,"chargeType":"CreditCharge"},{"adjustmentDescription":"Goodwill Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-100.66,"gstIncludedInAdjustments":-9.15,"isQueryable":false,"isDisputable":false,"chargeIdentifier":76,"chargeType":"CreditCharge"}]}}';
        OneFundInvoiceResponseDTO obj = OneFundInvoiceResponseDTO.parse(json);
        // List<invoiceLineitem> responsedto = new List<invoiceLineitem>();
        Test.startTest();
        system.assertNotEquals(null, OneFundRetrospectiveRedemption.getInvoiceLineitems(obj));      
        Test.stopTest(); 
    }
    // EDGE-116222
    // Method to cover getEligibleRedemption
    @IsTest 
    Public static void getEligibleRedemptionTest(){
        EligibleRedemptionAmountResponseDTO resdto  = new EligibleRedemptionAmountResponseDTO();
        String jsonData = '{"creditAdjustmentEligibility":[{"chargeIdentifier":986960,"invoiceLineNumber":1,"maxCreditAmount":100}]}';
        resdto = EligibleRedemptionAmountResponseDTO.parse(jsonData);  
        // EligibleRedemption eralist = new EligibleRedemption();
        Test.startTest();
        List<OneFundRetrospectiveRedemption.EligibleRedemption> EligibleRedemptions=OneFundRetrospectiveRedemption.getEligibleRedemption(resdto);
        //system.assertNotEquals(null, OneFundRetrospectiveRedemption.getEligibleRedemption(resdto)); 
        system.assertEquals(EligibleRedemptions[0].maxCreditAmount, 100);
        Test.stopTest();
        
        
    }
 /*-------------------------------------------------------------------------------
EDGE        -165647
Method     -getInvoiceLineitemsOffersTest
Description -Enhance Onefund Credit/Debit charges to be applicable for all the products available in B2B Digi stack
Author      -Aishwarya
---------------------------------------------------------------------------------*/
    
    @isTest
    Public static void  getInvoiceLineitemsOffersTest(){
        String json='{"customerAddress":{"companyName":"MLC Company Ltd.","addressLine1":"Unit 1 1234 Lostmy Way","addressCity":"Sydney","stateAndPostalCode":"NSW 2000"},"invoiceDetails":{"accountNumber":"700000560545","invoiceNumber":"9900000042835","invoiceIssueDate":"02 Jul 20","invoicePeriod":"01 Aug 20 - 31 Aug 20","ariaInvoiceNumber":"150000130"},"paymentSummary":{"balanceCarriedForward":55635.85,"totalDue":60880.84,"paymentsAndAdjustments":0,"dueDate":"01 Aug 20","newCharges":5244.99,"prevBalance":0,"payments":0,"adjustments":0},"serviceSummary":{"listOfOffers":[{"offerName":"Standalone hardware and devices","offerTotalExcludingGstCost":4768.17,"offerTotalIncludingGstCost":5244.99,"invoiceDef":3,"listOfChargesAndCredits":{"onceOffChargesAndCredits":[{"serviceType":"Samsung Galaxy S20 128GB 4GX Blue","quantity":2,"excludingGstCost":1089.09,"includingGstCost":1198,"sigmaSpecId":"BSOTC001_CB","isAggregated":true,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeType":"OnceOffCharge","chargeIdentifier":27795,"invoiceLineAttributes":[{"invoiceLineNumber":7,"invoiceTransactionId":202869852,"chargeExcludingGST":499.09,"chargeIncludingGST":549,"chargeInstanceId":"4b6909a3-11b5-65bd-a443-3374f275d50e"},{"invoiceLineNumber":13,"invoiceTransactionId":202869858,"chargeExcludingGST":590,"chargeIncludingGST":649,"chargeInstanceId":"2902dda3-add3-fbfa-b8d8-4c6761f48ce3"}]},{"serviceType":"Samsung Galaxy S20 128GB 4GX Blue","quantity":3,"excludingGstCost":3679.08,"includingGstCost":4046.99,"sigmaSpecId":"BSOTC001_CB","isAggregated":true,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeType":"OnceOffCharge","chargeIdentifier":27796,"invoiceLineAttributes":[{"invoiceLineNumber":10,"invoiceTransactionId":202869855,"chargeExcludingGST":1226.36,"chargeIncludingGST":1349,"chargeInstanceId":"222f8a83-014e-b8fb-0ac1-0f26b1aa1ab0"},{"invoiceLineNumber":16,"invoiceTransactionId":202869861,"chargeExcludingGST":1226.36,"chargeIncludingGST":1348.99,"chargeInstanceId":"a13d6f41-b86c-33ba-5ef9-748ce80689ed"},{"invoiceLineNumber":19,"invoiceTransactionId":202869864,"chargeExcludingGST":1226.36,"chargeIncludingGST":1349,"chargeInstanceId":"1375a73c-f349-0509-5107-593a7daf8dc9"}]}]}}],"accountLevelChargesAndCredits":{"adjustmentsExcludingGstCost":0,"adjustmentsIncludingGstCost":0,"grossTotalBill":5244.99,"amountOfGstIncludedInGrossTotalBill":476.82,"totalNewChargesInThisBill":5244.99,"gstFreeItemsIncludedInNewCharges":0,"gstIncludedInNewCharges":476.82,"adjustmentsTotal":0,"gstIncludedInAdjustments":0}}}';
        OneFundInvoiceResponseDTO obj = OneFundInvoiceResponseDTO.parse(json);
        Test.startTest();
        system.assertNotEquals(null, OneFundRetrospectiveRedemption.getInvoiceLineitems(obj));      
        Test.stopTest(); 
    }
    
}