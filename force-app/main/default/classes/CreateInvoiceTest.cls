/*************************************************************************************************
Name : CreateInvoiceTest
Description : Test class for CreateInvoice
Author: Jawahar
Story: EDGE-138355
***************************************************************************************************
UpdatedVersion      UpdatedBy            Edge Number         Date
1                   Aman Soni            EDGE-207867         18/05/2021
2.                  Shubhi V            EDGE-216407          04/06/2021
***************************************************************************************************/
@isTest
public class CreateInvoiceTest{
    /*----------------------------------------------------------------
    Method : setupdata
    Author: Jawahar
    Story: EDGE-138355
    Descripton : Create Billing account Data
    -------------------------------------------------------------------------------------*/
    @testSetup
    public static void setupdata() {
        Billing_Account__c billingAcc = TestUtil.createBillingAccount('700000005112');
        insert billingAcc;

        //Added by Aman Soni for 207867 || Start
        Profile billConsultantPF = [select id from profile where name = 'Billing Consultant'];
        Profile asaPF = [select id from profile where name = 'Assurance Service Agent'];
        List<User> userList = new List<User>();
        User billConsUser = new User(alias = 'standt',email='billinguser@testbc.com',emailencodingkey='UTF-8',IsActive =true,
            lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
            profileid = billConsultantPF.id,
            timezonesidkey='Australia/Sydney',
            username='billinguser@testbc.com',phone='+121231231234');
        userList.add(billConsUser);

        User asaUser = new User(alias = 'standt',email='assuranceuser@testasa.com',emailencodingkey='UTF-8',IsActive =true,
            lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
            profileid = asaPF.id,
            timezonesidkey='Australia/Sydney',
            username='assuranceuser@testasa.com',phone='+121231231234');
        userList.add(asaUser);
        insert userList;

        Account ac = new Account(name ='Test Acc',Account_Status__c = 'Active');
        insert ac;  
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id);
        insert con;

        Case caseRec = new Case();
        caseRec.Subject = 'Test Case';
        caseRec.Description = 'Test Case Description';
        caseRec.Billing_Account__c = billingAcc.Id;
        caseRec.Contact = con;
        caseRec.salesup_Support_Type__c = 'Billing Support';
        caseRec.Status = 'New';
        caseRec.Origin = 'TPC';
        insert caseRec;

        Invoice__c inv = new Invoice__c();
        inv.Name = '9900000017373';
        insert inv;

        Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
        ili.Invoice_Transaction_ID__c = 123456;
        ili.Invoice__c = inv.id; 
        insert ili;
        
        Queried_Line_Item__c qli = new Queried_Line_Item__c();
        qli.Case__c = caseRec.id;
        qli.Invoice_Line_Item__c = ili.id;
        insert qli; 
        //Added by Aman Soni for 207867 || End
        //EDGE-216407
        EnvironmentVariable__c featureToggle=new EnvironmentVariable__c();
        featureToggle.name='enableBillingEnquiry1663';
        featureToggle.value__c='true';
        insert featureToggle;

    }
    
    
    
    /*----------------------------------------------------------------
    Method : createCaseRecord
    Author:Jawahar 
    Story: EDGE-138355
    -------------------------------------------------------------------------------------*/
    @isTest
    static void createCaseRecord()
    {         
        String json = '{"customerAddress":{"companyName":"MLC Company Ltd.","addressLine1":"Unit 1 1234 Lostmy Way","addressCity":"Sydney","stateAndPostalCode":"NSW 2000"},"invoiceDetails":{"accountNumber":"700000002978","invoiceNumber":"9900000202350","invoiceIssueDate":"24 Jul 19","invoicePeriod":"01 Mar 19 - 31 Mar 19","ariaInvoiceNumber":"148512498"},"paymentSummary":{"balanceCarriedForward":-603.02,"totalDue":298.98,"paymentsAndAdjustments":603.02,"dueDate":"07 Aug 19","newCharges":902},"serviceSummary":{"listOfOffers":[{"offerName":"Connected Workplace","offerTotalExcludingGstCost":590,"offerTotalIncludingGstCost":902,"invoiceDef":1,"listOfProducts":[{"physicalLocationName":"400 George St Sydney NSW","siteExcludingGstCost":590,"siteIncludingGstCost":902,"listOfChargesAndCredits":{"planCharges":[{"serviceType":"Bandwidth Bolt On","quantity":1,"excludingGstCost":50,"includingGstCost":55,"sigmaSpecId":"BSRC001_CB","startDate":"01 Apr","endDate":"30 Apr","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4261,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":5,"invoiceTransactionId":197352167,"chargeExcludingGST":50,"chargeIncludingGST":55}]},{"serviceType":"Apple iPhone 8 64GB Monthly Repayment Charge","quantity":2,"excludingGstCost":110,"includingGstCost":110,"sigmaSpecId":"BSRO001_CB","isAggregated":true,"isTaxable":false,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4274,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":7,"invoiceTransactionId":197352169,"chargeExcludingGST":55,"chargeIncludingGST":55},{"invoiceLineNumber":6,"invoiceTransactionId":197352168,"chargeExcludingGST":55,"chargeIncludingGST":55}],"drillDownInputAttribute":{"statementNumber":"9900000202350","chargeId":4274},"drillDownEndpoint":"Repayment details"},{"serviceType":"Fixed Seat (Zone 1)","quantity":1,"excludingGstCost":50,"includingGstCost":55,"sigmaSpecId":"BSRC001_CB","startDate":"01 Apr","endDate":"30 Apr","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4260,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":8,"invoiceTransactionId":197352170,"chargeExcludingGST":50,"chargeIncludingGST":55}]}],"onceOffChargesAndCredits":[{"serviceType":"Jabra Stealth UC","quantity":1,"excludingGstCost":30,"includingGstCost":33,"sigmaSpecId":"BSOTC001_CB","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4269,"chargeType":"OnceOffCharge","disputeAttributes":[{"invoiceLineNumber":11,"invoiceTransactionId":197352173,"chargeExcludingGST":30,"chargeIncludingGST":33}]},{"serviceType":"Polaris Soundpro Touch 790","quantity":1,"excludingGstCost":35,"includingGstCost":38.5,"sigmaSpecId":"BSOTC001_CB","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4268,"chargeType":"OnceOffCharge","disputeAttributes":[{"invoiceLineNumber":12,"invoiceTransactionId":197352174,"chargeExcludingGST":35,"chargeIncludingGST":38.5}]},{"serviceType":"Polaris Soundpro Touch 790","quantity":1,"excludingGstCost":135,"includingGstCost":148.5,"sigmaSpecId":"BSOTC001_CB","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4267,"chargeType":"OnceOffCharge","disputeAttributes":[{"invoiceLineNumber":13,"invoiceTransactionId":197352175,"chargeExcludingGST":135,"chargeIncludingGST":148.5}]},{"serviceType":"Polaris Soundpro SW10ND","quantity":3,"excludingGstCost":420,"includingGstCost":462,"sigmaSpecId":"BSOTC001_CB","isAggregated":true,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4275,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":14,"invoiceTransactionId":197352176,"chargeExcludingGST":140,"chargeIncludingGST":154},{"invoiceLineNumber":10,"invoiceTransactionId":197352172,"chargeExcludingGST":140,"chargeIncludingGST":154},{"invoiceLineNumber":9,"invoiceTransactionId":197352171,"chargeExcludingGST":140,"chargeIncludingGST":154}]},{"serviceType":"Apple iPhone 8 64GB","quantity":2,"excludingGstCost":2400,"includingGstCost":2640,"isAggregated":true,"isTaxable":true,"isQueryable":true,"isDisputable":false,"chargeIdentifier":4277,"chargeType":"OnceOffCharge"},{"serviceType":"Apple iPhone 8 64GB","quantity":2,"excludingGstCost":-2640,"includingGstCost":-2640,"isAggregated":true,"isTaxable":false,"isQueryable":true,"isDisputable":false,"chargeIdentifier":4276,"chargeType":"CreditCharge"}]}}]}],"accountLevelChargesAndCredits":{"adjustmentsExcludingGstCost":0,"adjustmentsIncludingGstCost":0,"grossTotalBill":902,"amountOfGstIncludedInGrossTotalBill":312,"totalNewChargesInThisBill":902,"gstFreeItemsIncludedInNewCharges":110,"gstIncludedInNewCharges":312,"adjustmentsTotal":-603.02,"gstIncludedInAdjustments":-54.82}},"adjustmentSummary":{"totalAdjustmentsCost":-603.02,"totalGSTIncludedInAdjustments":-54.82,"adjustments":[{"adjustmentDescription":"Compensation Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-150.38,"gstIncludedInAdjustments":-13.67,"isQueryable":true,"isDisputable":false,"chargeIdentifier":80,"chargeType":"CreditCharge"},{"adjustmentDescription":"Goodwill Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-100.66,"gstIncludedInAdjustments":-9.15,"isQueryable":true,"isDisputable":false,"chargeIdentifier":78,"chargeType":"CreditCharge"},{"adjustmentDescription":"Goodwill Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-100.66,"gstIncludedInAdjustments":-9.15,"isQueryable":true,"isDisputable":false,"chargeIdentifier":79,"chargeType":"CreditCharge"},{"adjustmentDescription":"Compensation Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-150.66,"gstIncludedInAdjustments":-13.7,"isQueryable":true,"isDisputable":false,"chargeIdentifier":77,"chargeType":"CreditCharge"},{"adjustmentDescription":"Goodwill Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-100.66,"gstIncludedInAdjustments":-9.15,"isQueryable":false,"isDisputable":false,"chargeIdentifier":76,"chargeType":"CreditCharge"}]}}';
        InvoiceResponseDTO obj = InvoiceResponseDTO.parse(json);
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Case_Record_Type).getRecordTypeId();
        Account accountData = TestDataFactory.generateAccount();
        Contact contactData = TestDataFactory.generateContact('Test FirstName', accountData.id,'Active','Test LastName',System.today(),'Mobile');
        contactData.email='abc@gmail.com';
        insert contactData;
        
        integer transactionIdList1 = 10;
        integer transactionIdList2=20;
        list<integer> transactionIdList =new list<integer>();
        transactionIdList.add(transactionIdList1);
        transactionIdList.add(transactionIdList2);
        
        Invoice__c invdata= new Invoice__c(Name='123434',Aria_Invoice_Number__c='1232');
        insert invdata;
        Invoice_Line_Item__c ILI=new Invoice_Line_Item__c(Invoice__c=invdata.id,Invoice_Line_Number__c=13432233, Charge_Excluding_GST__c = 1214,Charge_Type__c= 'RecurringCharge',Invoice_Transaction_ID__c=26022460,Line_Item_Identifier__c='43242342',charge_identifier__c=12453);
        insert ILI;
        Billing_Account__c billingAccountData = TestDataFactory.generateBillingAccount('700000002978','Created',accountData.Id, contactData.Id);
        insert billingAccountData;
        String contacteMail='abc@gmail.com';
        String rcChargeIds='(12453, 4261)';
        String chargeIdList='(49386, 49389, 49388)';
       // string transactionid = '(22323, 3424, 224422)';
        String casecheck ='{"Priority":"Medium","Status":"New","Origin":"Assurance Service Agent"}';        //String caseInfo=String.valueOf(caseDatas);
        Id billingEnquiryRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Case_Billing_Enquiry_RecordType).getRecordTypeId();
        Map<String,Object> caseMap=new Map<String,Object>();
        //caseMap.put('contacteMail',contacteMail);
        caseMap.put('caseData',casecheck);
        caseMap.put('invLineItemData',json);
        caseMap.put('contacteMail',contacteMail);
        caseMap.put('rcChargeIds',rcChargeIds);
        caseMap.put('transactionIdList',transactionIdList);
        caseMap.put('chargeIdList',chargeIdList);
        Test.startTest();
        InvoiceCmpHandler.CreateCaseRecord(caseMap);
        Test.stopTest();
        System.assertNotEquals(null, caseMap);
    }

    /*----------------------------------------------------------------
    Story(Sprint) : EDGE-207867(21.06)
    Method        : existCaseRecordTest
    Author        : Aman Soni
    ------------------------------------------------------------------*/
    @isTest
    public static void existCaseRecordTest(){
        User billUser = [select name,id, lastname from  User where username='billinguser@testbc.com'];
        User asaUser = [select name,id, lastname from  User where username='assuranceuser@testasa.com'];
        String json = '{"customerAddress":{"companyName":"MLC Company Ltd.","addressLine1":"Unit 1 1234 Lostmy Way","addressCity":"Sydney","stateAndPostalCode":"NSW 2000"},"invoiceDetails":{"accountNumber":"700000002978","invoiceNumber":"9900000202350","invoiceIssueDate":"24 Jul 19","invoicePeriod":"01 Mar 19 - 31 Mar 19","ariaInvoiceNumber":"148512498"},"paymentSummary":{"balanceCarriedForward":-603.02,"totalDue":298.98,"paymentsAndAdjustments":603.02,"dueDate":"07 Aug 19","newCharges":902},"serviceSummary":{"listOfOffers":[{"offerName":"Connected Workplace","offerTotalExcludingGstCost":590,"offerTotalIncludingGstCost":902,"invoiceDef":1,"listOfProducts":[{"physicalLocationName":"400 George St Sydney NSW","siteExcludingGstCost":590,"siteIncludingGstCost":902,"listOfChargesAndCredits":{"planCharges":[{"serviceType":"Bandwidth Bolt On","quantity":1,"excludingGstCost":50,"includingGstCost":55,"sigmaSpecId":"BSRC001_CB","startDate":"01 Apr","endDate":"30 Apr","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4261,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":5,"invoiceTransactionId":197352167,"chargeExcludingGST":50,"chargeIncludingGST":55}]},{"serviceType":"Apple iPhone 8 64GB Monthly Repayment Charge","quantity":2,"excludingGstCost":110,"includingGstCost":110,"sigmaSpecId":"BSRO001_CB","isAggregated":true,"isTaxable":false,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4274,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":7,"invoiceTransactionId":197352169,"chargeExcludingGST":55,"chargeIncludingGST":55},{"invoiceLineNumber":6,"invoiceTransactionId":197352168,"chargeExcludingGST":55,"chargeIncludingGST":55}],"drillDownInputAttribute":{"statementNumber":"9900000202350","chargeId":4274},"drillDownEndpoint":"Repayment details"},{"serviceType":"Fixed Seat (Zone 1)","quantity":1,"excludingGstCost":50,"includingGstCost":55,"sigmaSpecId":"BSRC001_CB","startDate":"01 Apr","endDate":"30 Apr","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4260,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":8,"invoiceTransactionId":197352170,"chargeExcludingGST":50,"chargeIncludingGST":55}]}],"onceOffChargesAndCredits":[{"serviceType":"Jabra Stealth UC","quantity":1,"excludingGstCost":30,"includingGstCost":33,"sigmaSpecId":"BSOTC001_CB","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4269,"chargeType":"OnceOffCharge","disputeAttributes":[{"invoiceLineNumber":11,"invoiceTransactionId":197352173,"chargeExcludingGST":30,"chargeIncludingGST":33}]},{"serviceType":"Polaris Soundpro Touch 790","quantity":1,"excludingGstCost":35,"includingGstCost":38.5,"sigmaSpecId":"BSOTC001_CB","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4268,"chargeType":"OnceOffCharge","disputeAttributes":[{"invoiceLineNumber":12,"invoiceTransactionId":197352174,"chargeExcludingGST":35,"chargeIncludingGST":38.5}]},{"serviceType":"Polaris Soundpro Touch 790","quantity":1,"excludingGstCost":135,"includingGstCost":148.5,"sigmaSpecId":"BSOTC001_CB","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4267,"chargeType":"OnceOffCharge","disputeAttributes":[{"invoiceLineNumber":13,"invoiceTransactionId":197352175,"chargeExcludingGST":135,"chargeIncludingGST":148.5}]},{"serviceType":"Polaris Soundpro SW10ND","quantity":3,"excludingGstCost":420,"includingGstCost":462,"sigmaSpecId":"BSOTC001_CB","isAggregated":true,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4275,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":14,"invoiceTransactionId":197352176,"chargeExcludingGST":140,"chargeIncludingGST":154},{"invoiceLineNumber":10,"invoiceTransactionId":197352172,"chargeExcludingGST":140,"chargeIncludingGST":154},{"invoiceLineNumber":9,"invoiceTransactionId":197352171,"chargeExcludingGST":140,"chargeIncludingGST":154}]},{"serviceType":"Apple iPhone 8 64GB","quantity":2,"excludingGstCost":2400,"includingGstCost":2640,"isAggregated":true,"isTaxable":true,"isQueryable":true,"isDisputable":false,"chargeIdentifier":4277,"chargeType":"OnceOffCharge"},{"serviceType":"Apple iPhone 8 64GB","quantity":2,"excludingGstCost":-2640,"includingGstCost":-2640,"isAggregated":true,"isTaxable":false,"isQueryable":true,"isDisputable":false,"chargeIdentifier":4276,"chargeType":"CreditCharge"}]}}]}],"accountLevelChargesAndCredits":{"adjustmentsExcludingGstCost":0,"adjustmentsIncludingGstCost":0,"grossTotalBill":902,"amountOfGstIncludedInGrossTotalBill":312,"totalNewChargesInThisBill":902,"gstFreeItemsIncludedInNewCharges":110,"gstIncludedInNewCharges":312,"adjustmentsTotal":-603.02,"gstIncludedInAdjustments":-54.82}},"adjustmentSummary":{"totalAdjustmentsCost":-603.02,"totalGSTIncludedInAdjustments":-54.82,"adjustments":[{"adjustmentDescription":"Compensation Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-150.38,"gstIncludedInAdjustments":-13.67,"isQueryable":true,"isDisputable":false,"chargeIdentifier":80,"chargeType":"CreditCharge"},{"adjustmentDescription":"Goodwill Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-100.66,"gstIncludedInAdjustments":-9.15,"isQueryable":true,"isDisputable":false,"chargeIdentifier":78,"chargeType":"CreditCharge"},{"adjustmentDescription":"Goodwill Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-100.66,"gstIncludedInAdjustments":-9.15,"isQueryable":true,"isDisputable":false,"chargeIdentifier":79,"chargeType":"CreditCharge"},{"adjustmentDescription":"Compensation Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-150.66,"gstIncludedInAdjustments":-13.7,"isQueryable":true,"isDisputable":false,"chargeIdentifier":77,"chargeType":"CreditCharge"},{"adjustmentDescription":"Goodwill Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-100.66,"gstIncludedInAdjustments":-9.15,"isQueryable":false,"isDisputable":false,"chargeIdentifier":76,"chargeType":"CreditCharge"}]}}';
        Test.startTest();
            Case caseRec = [Select id,Subject,Description,Contact.Id,Contact.Name from Case];
            String contacteMail='';
            String rcChargeIds='(12453, 4261)';
            String caseId = caseRec.Id;
            List<Integer> transactionIdList =new List<Integer>();
            Integer transactionIdList1 = 123456;
            Integer transactionIdList2 = 207896;
            transactionIdList.add(transactionIdList1);
            transactionIdList.add(transactionIdList2);
            Map<String,Object> caseMap=new Map<String,Object>();
            caseMap.put('invLineItemData',json);
            caseMap.put('contacteMail',contacteMail);
            caseMap.put('rcChargeIds',rcChargeIds);
            caseMap.put('caseId',caseId);
            caseMap.put('transactionIdList',transactionIdList);
            System.runAS(billUser){
                String cas = InvoiceCmpHandler.existCaseRecord(caseMap);
                System.assertNotEquals(null, caseMap);
            }
            System.runAS(asaUser){
                String cas = InvoiceCmpHandler.existCaseRecord(caseMap);
                System.assertNotEquals(null, caseMap);
            }
        Test.stopTest();  
    }
   
}