/*************************************************************************************************
Name : InvoiceCmpHandlerTest
Description : Test class for InvoiceCmpHandler
Author: Manjunath Ediga
Story: EDGE-92010
***************************************************************************************************
UpdatedVersion      UpdatedBy            Edge Number         Date
1                   Aman Soni            EDGE-207867         18/05/2021
2                   Aman Soni            EDGE-207869         09/05/2021
3                   Shubhi                   13-9-2021        fdr test class fix
***************************************************************************************************/
@isTest
public class InvoiceCmpHandlerTest {
    /*----------------------------------------------------------------
    Method : setupdata
    Author: Manjunath Ediga
    Story: EDGE-92010
    Descripton : Create Billing account Data
    -------------------------------------------------------------------------------------*/
    @testSetup
    public static void setupdata(){
        /*Account account = new Account(name ='TelecomAC',Account_Status__c = 'Active',PRM_Remaining_License__c=25);
        insert account;  
        Contact contact = new Contact(LastName ='testCon',AccountId = account.Id, Onboarding_Status__c = 'Active',PIMS_User_Status__c='User Created',PIMS_User_Type__c='TEG');
        insert contact;
        Billing_Account__c billingAcc = TestDataFactory.generateBillingAccount('700000005112','Created',account.Id,contact.Id);
        insert billingAcc;*/
        
        profile pSysAdmin = [select id,name from Profile where Name =:'System Administrator'];
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        
        User uSysAdmin = new User(alias = 'Con123', email = 'InvoiceCmpHandlerTest_Testadmin00097@noemail.com', emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = pSysAdmin.id, country = 'United States', IsActive = true, timezonesidkey = 'America/Los_Angeles', username = uniqueName+'Testadmin00097@noemail.com');
        insert uSysAdmin;
        User  partneruser;
        System.runAs(uSysAdmin){
            UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
            insert r;
            uSysAdmin.userroleid=r.id;
            update uSysAdmin;
            
        id prmAdmin = [select id from profile where name='PRM Admin - Australia'].id;
        Account ac = new Account(name ='TelecomAC',Account_Status__c = 'Active',PRM_Remaining_License__c=25);
        insert ac;  
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Onboarding_Status__c = 'Active',PIMS_User_Status__c='User Created',PIMS_User_Type__c='TEG');
        insert con;
        Billing_Account__c billingAcc = TestDataFactory.generateBillingAccount('700000005112','Created',ac.Id,con.Id);
        insert billingAcc; 
        partneruser = new User(alias = 'test123', email='InvoiceCmpHandlerTest_b2btestPartner00097@noemail.com',
                                   emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                   localesidkey='en_US', Profileid = prmAdmin , country='United States',IsActive =true,
                                   timezonesidkey='America/Los_Angeles', username=uniqueName+'b2btestewwrpdua123@noemail.com',contactid=con.id);
        insert partneruser;
        
        PermissionSet ps = new PermissionSet();
        ps.Name = 'Test';
        ps.Label = 'Test';
        insert ps;
        SetupEntityAccess sea = new SetupEntityAccess();
        sea.ParentId = ps.Id;
        sea.SetupEntityId = [select Id from CustomPermission where DeveloperName = 'Partner_User'][0].Id;
        insert sea;
        
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = partneruser.id;
        psa.PermissionSetId = ps.Id;
        insert psa;

        //Added by Aman Soni for EDGE-207867 || Start
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

        Id caseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Case_Record_Type).getRecordTypeId();

        Case caseRec = new Case();
        caseRec.Subject = 'Test Case';
        caseRec.Description = 'Test Case Description';
        caseRec.Billing_Account__c = billingAcc.Id;
        caseRec.Contact = con;
        caseRec.salesup_Support_Type__c = 'Billing Support';
        caseRec.Status = 'New';
        caseRec.Origin = 'TPC';
        caseRec.AccountId = ac.Id;
        caseRec.ContactId = con.Id;
        caseRec.Type = System.Label.Case_Type;
        caseRec.RecordTypeId = caseRecTypeId;
		Test.startTest();
        insert caseRec;

        //Added by Aman Soni for EDGE-207869 || Start
        List<Invoice__c> invLst = new List<Invoice__c>();
        Invoice__c inv = new Invoice__c();
        inv.Name = '9900000017373';
        inv.Billing_Account__c = billingAcc.id;
        invLst.add(inv);
        insert invLst;

        List<Invoice_Line_Item__c> iliLst = new List<Invoice_Line_Item__c>();
        Invoice_Line_Item__c ili = new Invoice_Line_Item__c();
        ili.Invoice__c =inv.Id;
        iliLst.add(ili);
        insert iliLst;

        List<Queried_Line_Item__c> qliLst = new List<Queried_Line_Item__c>();
        Queried_Line_Item__c qli = new Queried_Line_Item__c();
        qli.Case__c =caseRec.Id;
        qli.Invoice_Line_Item__c =ili.Id;
        qli.Queried_Amount__c = 9.00;
        qliLst.add(qli);
        insert qliLst;

        List<SharedDisplayMessage__c> csList = new List<SharedDisplayMessage__c>();
        SharedDisplayMessage__c csRecExist = new SharedDisplayMessage__c();
        csRecExist.Name = 'MsgForExistingCase';
        csRecExist.Value__c = 'Existing Case Message';
        csList.add(csRecExist);
        insert csList;
		Test.stopTest();
        //Added by Aman Soni for EDGE-207869 || End
        //Added by Aman Soni for EDGE-207867 || End
    }
    }
    /*----------------------------------------------------------------
    Method : calloutInvoiceByNumberSuccess
    Author: Manjunath Ediga
    Story: EDGE-92010 
    -------------------------------------------------------------------------------------*/
    @isTest
    public static void calloutInvoiceByNumberSuccess(){
        String invoiceNumber = '9900000182889';
        List < Billing_Account__c > billingAcc = [SELECT id, Billing_Account_Number__c FROM Billing_Account__c];
        //  InvoiceRequestDTO requestDto = InvoiceCalloutHandler.createPayload('700000005112',Long.valueOf(invoiceNumber));
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockInvoiceCallout('success_Search'));
        String responseDto = InvoiceCmpHandler.getInvoiceDetailsList(billingAcc[0].id, invoiceNumber);
        system.debug('responseDto is -->' + responseDto);
        Test.stopTest();
        System.assertEquals(responseDto != null, true, 'SuccessResponse');
    }   
    
    /*----------------------------------------------------------------
    Method : calloutInvoiceByNumberFail
    Author: Manjunath Ediga
    Story: EDGE-92010
    -------------------------------------------------------------------------------------*/
    @isTest
    public static void calloutInvoiceByNumberFail() {
        String invoiceNumber = '9900000182889';
        List < Billing_Account__c > billingAcc = [SELECT id, Billing_Account_Number__c FROM Billing_Account__c ];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockInvoiceCallout('success_Error_503'));
        String responseDto = InvoiceCmpHandler.getInvoiceDetailsList(billingAcc[0].id, invoiceNumber);
        //String responseDto = InvoiceCmpHandler.getInvoiceDetailsList('', invoiceNumber);
        Test.stopTest();
        System.assertNotEquals(null, responseDto);
    }   
    
    
    /*----------------------------------------------------------------
    Method : createCaseRecord
    Author:Pradeep Bhumi
    Story: EDGE-121428
    -------------------------------------------------------------------------------------*/
    @isTest
    static void createCaseRecord()
    {         
        
        String json = '{"customerAddress":{"companyName":"MLC Company Ltd.","addressLine1":"Unit 1 1234 Lostmy Way","addressCity":"Sydney","stateAndPostalCode":"NSW 2000"},"invoiceDetails":{"accountNumber":"700000002978","invoiceNumber":"9900000202350","invoiceIssueDate":"24 Jul 19","invoicePeriod":"01 Mar 19 - 31 Mar 19","ariaInvoiceNumber":"148512498"},"paymentSummary":{"balanceCarriedForward":-603.02,"totalDue":298.98,"paymentsAndAdjustments":603.02,"dueDate":"07 Aug 19","newCharges":902},"serviceSummary":{"listOfOffers":[{"offerName":"Connected Workplace","offerTotalExcludingGstCost":590,"offerTotalIncludingGstCost":902,"invoiceDef":1,"listOfProducts":[{"physicalLocationName":"400 George St Sydney NSW","siteExcludingGstCost":590,"siteIncludingGstCost":902,"listOfChargesAndCredits":{"planCharges":[{"serviceType":"Bandwidth Bolt On","quantity":1,"excludingGstCost":50,"includingGstCost":55,"sigmaSpecId":"BSRC001_CB","startDate":"01 Apr","endDate":"30 Apr","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4261,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":5,"invoiceTransactionId":197352167,"chargeExcludingGST":50,"chargeIncludingGST":55}]},{"serviceType":"Apple iPhone 8 64GB Monthly Repayment Charge","quantity":2,"excludingGstCost":110,"includingGstCost":110,"sigmaSpecId":"BSRO001_CB","isAggregated":true,"isTaxable":false,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4274,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":7,"invoiceTransactionId":197352169,"chargeExcludingGST":55,"chargeIncludingGST":55},{"invoiceLineNumber":6,"invoiceTransactionId":197352168,"chargeExcludingGST":55,"chargeIncludingGST":55}],"drillDownInputAttribute":{"statementNumber":"9900000202350","chargeId":4274},"drillDownEndpoint":"Repayment details"},{"serviceType":"Fixed Seat (Zone 1)","quantity":1,"excludingGstCost":50,"includingGstCost":55,"sigmaSpecId":"BSRC001_CB","startDate":"01 Apr","endDate":"30 Apr","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4260,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":8,"invoiceTransactionId":197352170,"chargeExcludingGST":50,"chargeIncludingGST":55}]}],"onceOffChargesAndCredits":[{"serviceType":"Jabra Stealth UC","quantity":1,"excludingGstCost":30,"includingGstCost":33,"sigmaSpecId":"BSOTC001_CB","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4269,"chargeType":"OnceOffCharge","disputeAttributes":[{"invoiceLineNumber":11,"invoiceTransactionId":197352173,"chargeExcludingGST":30,"chargeIncludingGST":33}]},{"serviceType":"Polaris Soundpro Touch 790","quantity":1,"excludingGstCost":35,"includingGstCost":38.5,"sigmaSpecId":"BSOTC001_CB","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4268,"chargeType":"OnceOffCharge","disputeAttributes":[{"invoiceLineNumber":12,"invoiceTransactionId":197352174,"chargeExcludingGST":35,"chargeIncludingGST":38.5}]},{"serviceType":"Polaris Soundpro Touch 790","quantity":1,"excludingGstCost":135,"includingGstCost":148.5,"sigmaSpecId":"BSOTC001_CB","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4267,"chargeType":"OnceOffCharge","disputeAttributes":[{"invoiceLineNumber":13,"invoiceTransactionId":197352175,"chargeExcludingGST":135,"chargeIncludingGST":148.5}]},{"serviceType":"Polaris Soundpro SW10ND","quantity":3,"excludingGstCost":420,"includingGstCost":462,"sigmaSpecId":"BSOTC001_CB","isAggregated":true,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4275,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":14,"invoiceTransactionId":197352176,"chargeExcludingGST":140,"chargeIncludingGST":154},{"invoiceLineNumber":10,"invoiceTransactionId":197352172,"chargeExcludingGST":140,"chargeIncludingGST":154},{"invoiceLineNumber":9,"invoiceTransactionId":197352171,"chargeExcludingGST":140,"chargeIncludingGST":154}]},{"serviceType":"Apple iPhone 8 64GB","quantity":2,"excludingGstCost":2400,"includingGstCost":2640,"isAggregated":true,"isTaxable":true,"isQueryable":true,"isDisputable":false,"chargeIdentifier":4277,"chargeType":"OnceOffCharge"},{"serviceType":"Apple iPhone 8 64GB","quantity":2,"excludingGstCost":-2640,"includingGstCost":-2640,"isAggregated":true,"isTaxable":false,"isQueryable":true,"isDisputable":false,"chargeIdentifier":4276,"chargeType":"CreditCharge"}]}}]}],"accountLevelChargesAndCredits":{"adjustmentsExcludingGstCost":0,"adjustmentsIncludingGstCost":0,"grossTotalBill":902,"amountOfGstIncludedInGrossTotalBill":312,"totalNewChargesInThisBill":902,"gstFreeItemsIncludedInNewCharges":110,"gstIncludedInNewCharges":312,"adjustmentsTotal":-603.02,"gstIncludedInAdjustments":-54.82}},"adjustmentSummary":{"totalAdjustmentsCost":-603.02,"totalGSTIncludedInAdjustments":-54.82,"adjustments":[{"adjustmentDescription":"Compensation Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-150.38,"gstIncludedInAdjustments":-13.67,"isQueryable":true,"isDisputable":false,"chargeIdentifier":80,"chargeType":"CreditCharge"},{"adjustmentDescription":"Goodwill Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-100.66,"gstIncludedInAdjustments":-9.15,"isQueryable":true,"isDisputable":false,"chargeIdentifier":78,"chargeType":"CreditCharge"},{"adjustmentDescription":"Goodwill Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-100.66,"gstIncludedInAdjustments":-9.15,"isQueryable":true,"isDisputable":false,"chargeIdentifier":79,"chargeType":"CreditCharge"},{"adjustmentDescription":"Compensation Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-150.66,"gstIncludedInAdjustments":-13.7,"isQueryable":true,"isDisputable":false,"chargeIdentifier":77,"chargeType":"CreditCharge"},{"adjustmentDescription":"Goodwill Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-100.66,"gstIncludedInAdjustments":-9.15,"isQueryable":false,"isDisputable":false,"chargeIdentifier":76,"chargeType":"CreditCharge"}]}}';
        InvoiceResponseDTO obj = InvoiceResponseDTO.parse(json);
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Case_Record_Type).getRecordTypeId();
        Account accountData = TestDataFactory.generateAccount();
        Test.startTest();
        Contact contactData = TestDataFactory.generateContact('Test FirstName', accountData.id,'Active','Test LastName',System.today(),'Mobile');
        contactData.email='abc@gmail.com';
        insert contactData;
        
        //Start of EDGE-133408  Component
        integer transactionIdList1 = 10;
        integer transactionIdList2=20;
        list<integer> transactionIdList =new list<integer>();
        transactionIdList.add(transactionIdList1);
        transactionIdList.add(transactionIdList2);
        
        //End of EDGE-133408  Component
        //Invoice_Line_Item__c ILI=new Invoice_Line_Item__c(Invoice_Line_Number__c=13432233, Charge_Excluding_GST__c = 1214,Charge_Type__c= 'RecurringCharge',Invoice_Transaction_ID__c=26022460,Line_Item_Identifier__c='43242342',charge_identifier__c=12453);
        //insert ILI;
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
        
        InvoiceCmpHandler.CreateCaseRecord(caseMap);
		Test.stopTest();
        
        System.assertNotEquals(null, caseMap);
    }

    //Modified by Aman Soni to resolve Soql 101 error for EDGE-207869
    @isTest
    static void createCaseRecordFail()
    {  
        String json = '{"customerAddress":{"companyName":"MLC Company Ltd.","addressLine1":"Unit 1 1234 Lostmy Way","addressCity":"Sydney","stateAndPostalCode":"NSW 2000"},"invoiceDetails":{"accountNumber":"700000002978","invoiceNumber":"9900000202350","invoiceIssueDate":"24 Jul 19","invoicePeriod":"01 Mar 19 - 31 Mar 19","ariaInvoiceNumber":"148512498"},"paymentSummary":{"balanceCarriedForward":-603.02,"totalDue":298.98,"paymentsAndAdjustments":603.02,"dueDate":"07 Aug 19","newCharges":902},"serviceSummary":{"listOfOffers":[{"offerName":"Connected Workplace","offerTotalExcludingGstCost":590,"offerTotalIncludingGstCost":902,"invoiceDef":1,"listOfProducts":[{"physicalLocationName":"400 George St Sydney NSW","siteExcludingGstCost":590,"siteIncludingGstCost":902,"listOfChargesAndCredits":{"planCharges":[{"serviceType":"Bandwidth Bolt On","quantity":1,"excludingGstCost":50,"includingGstCost":55,"sigmaSpecId":"BSRC001_CB","startDate":"01 Apr","endDate":"30 Apr","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4261,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":5,"invoiceTransactionId":197352167,"chargeExcludingGST":50,"chargeIncludingGST":55}]},{"serviceType":"Apple iPhone 8 64GB Monthly Repayment Charge","quantity":2,"excludingGstCost":110,"includingGstCost":110,"sigmaSpecId":"BSRO001_CB","isAggregated":true,"isTaxable":false,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4274,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":7,"invoiceTransactionId":197352169,"chargeExcludingGST":55,"chargeIncludingGST":55},{"invoiceLineNumber":6,"invoiceTransactionId":197352168,"chargeExcludingGST":55,"chargeIncludingGST":55}],"drillDownInputAttribute":{"statementNumber":"9900000202350","chargeId":4274},"drillDownEndpoint":"Repayment details"},{"serviceType":"Fixed Seat (Zone 1)","quantity":1,"excludingGstCost":50,"includingGstCost":55,"sigmaSpecId":"BSRC001_CB","startDate":"01 Apr","endDate":"30 Apr","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4260,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":8,"invoiceTransactionId":197352170,"chargeExcludingGST":50,"chargeIncludingGST":55}]}],"onceOffChargesAndCredits":[{"serviceType":"Jabra Stealth UC","quantity":1,"excludingGstCost":30,"includingGstCost":33,"sigmaSpecId":"BSOTC001_CB","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4269,"chargeType":"OnceOffCharge","disputeAttributes":[{"invoiceLineNumber":11,"invoiceTransactionId":197352173,"chargeExcludingGST":30,"chargeIncludingGST":33}]},{"serviceType":"Polaris Soundpro Touch 790","quantity":1,"excludingGstCost":35,"includingGstCost":38.5,"sigmaSpecId":"BSOTC001_CB","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4268,"chargeType":"OnceOffCharge","disputeAttributes":[{"invoiceLineNumber":12,"invoiceTransactionId":197352174,"chargeExcludingGST":35,"chargeIncludingGST":38.5}]},{"serviceType":"Polaris Soundpro Touch 790","quantity":1,"excludingGstCost":135,"includingGstCost":148.5,"sigmaSpecId":"BSOTC001_CB","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4267,"chargeType":"OnceOffCharge","disputeAttributes":[{"invoiceLineNumber":13,"invoiceTransactionId":197352175,"chargeExcludingGST":135,"chargeIncludingGST":148.5}]},{"serviceType":"Polaris Soundpro SW10ND","quantity":3,"excludingGstCost":420,"includingGstCost":462,"sigmaSpecId":"BSOTC001_CB","isAggregated":true,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4275,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":14,"invoiceTransactionId":197352176,"chargeExcludingGST":140,"chargeIncludingGST":154},{"invoiceLineNumber":10,"invoiceTransactionId":197352172,"chargeExcludingGST":140,"chargeIncludingGST":154},{"invoiceLineNumber":9,"invoiceTransactionId":197352171,"chargeExcludingGST":140,"chargeIncludingGST":154}]},{"serviceType":"Apple iPhone 8 64GB","quantity":2,"excludingGstCost":2400,"includingGstCost":2640,"isAggregated":true,"isTaxable":true,"isQueryable":true,"isDisputable":false,"chargeIdentifier":4277,"chargeType":"OnceOffCharge"},{"serviceType":"Apple iPhone 8 64GB","quantity":2,"excludingGstCost":-2640,"includingGstCost":-2640,"isAggregated":true,"isTaxable":false,"isQueryable":true,"isDisputable":false,"chargeIdentifier":4276,"chargeType":"CreditCharge"}]}}]}],"accountLevelChargesAndCredits":{"adjustmentsExcludingGstCost":0,"adjustmentsIncludingGstCost":0,"grossTotalBill":902,"amountOfGstIncludedInGrossTotalBill":312,"totalNewChargesInThisBill":902,"gstFreeItemsIncludedInNewCharges":110,"gstIncludedInNewCharges":312,"adjustmentsTotal":-603.02,"gstIncludedInAdjustments":-54.82}},"adjustmentSummary":{"totalAdjustmentsCost":-603.02,"totalGSTIncludedInAdjustments":-54.82,"adjustments":[{"adjustmentDescription":"Compensation Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-150.38,"gstIncludedInAdjustments":-13.67,"isQueryable":true,"isDisputable":false,"chargeIdentifier":80,"chargeType":"CreditCharge"},{"adjustmentDescription":"Goodwill Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-100.66,"gstIncludedInAdjustments":-9.15,"isQueryable":true,"isDisputable":false,"chargeIdentifier":78,"chargeType":"CreditCharge"},{"adjustmentDescription":"Goodwill Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-100.66,"gstIncludedInAdjustments":-9.15,"isQueryable":true,"isDisputable":false,"chargeIdentifier":79,"chargeType":"CreditCharge"},{"adjustmentDescription":"Compensation Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-150.66,"gstIncludedInAdjustments":-13.7,"isQueryable":true,"isDisputable":false,"chargeIdentifier":77,"chargeType":"CreditCharge"},{"adjustmentDescription":"Goodwill Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-100.66,"gstIncludedInAdjustments":-9.15,"isQueryable":false,"isDisputable":false,"chargeIdentifier":76,"chargeType":"CreditCharge"}]}}';
        InvoiceResponseDTO obj = InvoiceResponseDTO.parse(json);
        //Start of EDGE-133408  Component
        list<integer> transactionIdList =new list<integer>();
        integer transactionIdList1 = 10;
        integer transactionIdList2=20;
        transactionIdList.add(transactionIdList1);
        transactionIdList.add(transactionIdList2);       
        //End of EDGE-133408  Component
        Case caseData = [Select id,Subject,AccountId,ContactId,Status,Description,Type,RecordTypeId,Billing_Account__c from Case];
        String contacteMail='abc@gmail.com';
        String rcChargeIds='(12453, 4261)';
        String chargeIdList='(49386, 49389, 49388)';
        String casecheck ='{"Priority":"Medium","Status":"New","Origin":"Assurance Service Agent"}'; 
        //Id billingEnquiryRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Case_Billing_Enquiry_RecordType).getRecordTypeId();
        Map<String,Object> caseMap=new Map<String,Object>();
        caseMap.put('caseData',casecheck);
        caseMap.put('invLineItemData',json);
        caseMap.put('contacteMail',contacteMail);
        caseMap.put('transactionIdList',transactionIdList);
        caseMap.put('rcChargeIds',rcChargeIds);
        caseMap.put('chargeIdList',chargeIdList);
        Test.startTest();
            InvoiceCmpHandler.getMaxCredit(''+caseData.id);
        Test.stopTest();
        System.assertNotEquals(null, caseMap); 
    }
    
    /*----------------------------------------------------------------
    Method : fetchInvoicesNumbersTest
    Author: Pradeep
    Story: EDGE-124066  
    -------------------------------------------------------------------------------------*/
    @isTest
    public static void fetchInvoicesNumbersTest(){
        String responseInvoice;
        Account accountData = TestDataFactory.generateAccount();
        Test.startTest();
            Contact contactData = TestDataFactory.generateContact('Test FirstName', accountData.id,'Active','Test LastName',System.today(),'Mobile');
            insert contactData;
        Test.stopTest();

        Billing_Account__c billingAccountData = TestDataFactory.generateBillingAccount('700000002978','Created',accountData.Id, contactData.Id);
        insert billingAccountData;
        Invoice__c invoiceData = new Invoice__c(Name = '9900000202350',Billing_Account__c = billingAccountData.Id,Aria_Invoice_Number__c = '012345678912345'); 
        insert  invoiceData;
        Test.setMock(HttpCalloutMock.class, new MockInvoiceCallout('success_Search'));
        Map<String,String> invoiceResponse=InvoiceCmpHandler.fetchInvoiceNumbers(billingAccountData.Id);
        system.debug('responseDto is -->'+invoiceResponse);
        System.assertEquals(invoiceResponse!=null,true);
    }    
    
    /*----------------------------------------------------------------
    Method : fetchInvoicesNumbersTestFail
    Author: Pradeep
    Story: EDGE-124066  
    -------------------------------------------------------------------------------------*/
    @isTest
    public static void fetchInvoicesNumbersTestFail(){
       
        Account accountData = TestDataFactory.generateAccount();
        Test.startTest();
        Contact contactData = TestDataFactory.generateContact('Test FirstName', accountData.id,'Active','Test LastName',System.today(),'Mobile');
        insert contactData;
        Billing_Account__c billingAccountData = TestDataFactory.generateBillingAccount('700000002978','Created',accountData.Id, contactData.Id);
        insert billingAccountData;
        Invoice__c invoiceData = new Invoice__c(Name = '9900000202350',Billing_Account__c = billingAccountData.Id,Aria_Invoice_Number__c = '012345678912345'); 
        insert  invoiceData;
        Test.setMock(HttpCalloutMock.class, new MockInvoiceCallout('success_Error'));
        Map<String,String> invoiceResponse=InvoiceCmpHandler.fetchInvoiceNumbers('');
        system.debug('responseDto is -->'+invoiceResponse);
        Test.stopTest();
        System.assertEquals(invoiceResponse!=null,false);
    }     

    /*----------------------------------------------------------------
    Method : fetchLookUpValuesPostive
    Author: Pradeep
    Story: EDGE-127943
    -------------------------------------------------------------------------------------*/
    @isTest
    public static void fetchLookUpValuesPostive(){
        Test.startTest();
		Account accountData = new Account();
        accountData.Customer_Status__c='ACTIVE'; 
        accountData.Name='Test';
        insert accountData;
        Contact contactData = TestDataFactory.generateContact('Test FirstName', accountData.id,'Active','Test LastName',System.today(),'Mobile');
        insert contactData;
        contactData.Authority__c='Full Authority';
        update contactData;
        Billing_Account__c billingAccountData = TestDataFactory.generateBillingAccount('700000002978','Created',accountData.Id, contactData.Id);
        insert billingAccountData;
        String searchKeyWord='Test FirstName';
        String ObjectName='Contact';
        String billingAccountId=billingAccountData.id;
        
        List <sObject> lookUpValues=InvoiceCmpHandler.fetchLookUpValues(searchKeyWord,ObjectName,billingAccountId);
        Test.stopTest();
        System.assertEquals(lookUpValues.isEmpty(),false);
    }    
    
    /*----------------------------------------------------------------
    Method : fetchLookUpValuesFail
    Author: Pradeep
    Story: EDGE-127943
    -------------------------------------------------------------------------------------*/
    @isTest
    public static void fetchLookUpValuesFail(){
        Test.startTest();
		Account accountData = new Account();
        accountData.Customer_Status__c='ACTIVE'; 
        accountData.Name='Test';
        insert accountData;
        Contact contactData = TestDataFactory.generateContact('Test FirstName', accountData.id,'Active','Test LastName',System.today(),'Mobile');
        insert contactData;
        String searchKeyWord='Test FirstName';
        String ObjectName='Contact';
        String billingAccountId='';
        List <sObject> lookUpValues=InvoiceCmpHandler.fetchLookUpValues(searchKeyWord,ObjectName,billingAccountId);
        Test.stopTest();
        System.assertEquals(lookUpValues.isEmpty(),true);

    }
    
    /*----------------------------------------------------------------
    Method : NoSearchkeyForFetchLookUpValuesTest
    Author : Aman Soni
    Story  : EDGE-207869(21.08)
    -------------------------------------------------------------------------------------*/
    /*
    @isTest
    public static void NoSearchkeyForFetchLookUpValuesTest(){
        User billUser = [select name,id, lastname from  User where username='billinguser@testbc.com'];
        User asaUser = [select name,id, lastname from  User where username='assuranceuser@testasa.com'];
        Account accountData = new Account();
        accountData.Customer_Status__c='ACTIVE'; 
        accountData.Name='Test';
        insert accountData;
        Contact contactData = TestDataFactory.generateContact('Test FirstName', accountData.id,'Active','Test LastName',System.today(),'Mobile');
        insert contactData;
        contactData.Authority__c='Full Authority';
        update contactData;
        Billing_Account__c billingAccountData = TestDataFactory.generateBillingAccount('700000002978','Created',accountData.Id, contactData.Id);
        insert billingAccountData; 
        String searchKeyWord='';
        String ObjectName='Contact';
        String billingAccountId=billingAccountData.id;
        Test.startTest();            
            System.runAS(billUser){
                List<sObject> lookUpValues=InvoiceCmpHandler.fetchLookUpValues(searchKeyWord,ObjectName,billingAccountId);
                System.assertEquals(lookUpValues.isEmpty(),false);
            }
            System.runAS(asaUser){
                List<sObject> lookUpValues=InvoiceCmpHandler.fetchLookUpValues(searchKeyWord,ObjectName,billingAccountId);
                System.assertEquals(lookUpValues.isEmpty(),false);
            }
        Test.stopTest();
    }*/
    
    @isTest
    public static void fetchBillingAddressTest(){
        Account accountData = new Account();
        accountData.Customer_Status__c='ACTIVE'; 
        accountData.Name='Test';
        insert accountData;
        Test.startTest();
        Contact contactData = TestDataFactory.generateContact('Test FirstName', accountData.id,'Active','Test LastName',System.today(),'Mobile');
        contactData.Authority__c='Full Authority';
        insert contactData;
        Test.stopTest();
        Billing_Account__c billingAccountData = TestDataFactory.generateBillingAccount('700000002978','Created',accountData.Id, contactData.Id);
        insert billingAccountData;
        String billingAccountId=billingAccountData.id;
        
        string lookUpValues=InvoiceCmpHandler.fetchBillingAddress(billingAccountId);
        
        System.assertEquals(lookUpValues!=null,false);
        
    }    
   
    /******************************************************************
    EDGE        -167053
    Method      -isPartnerusertest 
    Description -Checks if login user is partner user
    Author      -Raviteja
    ******************************************************************/
    @isTest
    public static void isPartnerusertest() {  
        user partneruser=[select id from user where email='InvoiceCmpHandlerTest_b2btestPartner00097@noemail.com' limit 1];
        user uSysAdmin=[select id from user where email='InvoiceCmpHandlerTest_Testadmin00097@noemail.com' limit 1];
            
        System.runAs(partneruser){
            boolean ispartner = InvoiceCmpHandler.isPartner();            
            System.assertEquals(ispartner,true);
        }
        System.runAs(uSysAdmin){
            boolean ispartner = InvoiceCmpHandler.isPartner();
            System.assertEquals(ispartner,false);
        }   
    }
    
    @isTest
    static void createCaseRecordPartner()
    {        
        user partneruser=[select id from user where email='InvoiceCmpHandlerTest_b2btestPartner00097@noemail.com' limit 1];
             
        String json = '{"customerAddress":{"companyName":"MLC Company Ltd.","addressLine1":"Unit 1 1234 Lostmy Way","addressCity":"Sydney","stateAndPostalCode":"NSW 2000"},"invoiceDetails":{"accountNumber":"700000002978","invoiceNumber":"9900000202350","invoiceIssueDate":"24 Jul 19","invoicePeriod":"01 Mar 19 - 31 Mar 19","ariaInvoiceNumber":"148512498"},"paymentSummary":{"balanceCarriedForward":-603.02,"totalDue":298.98,"paymentsAndAdjustments":603.02,"dueDate":"07 Aug 19","newCharges":902},"serviceSummary":{"listOfOffers":[{"offerName":"Connected Workplace","offerTotalExcludingGstCost":590,"offerTotalIncludingGstCost":902,"invoiceDef":1,"listOfProducts":[{"physicalLocationName":"400 George St Sydney NSW","siteExcludingGstCost":590,"siteIncludingGstCost":902,"listOfChargesAndCredits":{"planCharges":[{"serviceType":"Bandwidth Bolt On","quantity":1,"excludingGstCost":50,"includingGstCost":55,"sigmaSpecId":"BSRC001_CB","startDate":"01 Apr","endDate":"30 Apr","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4261,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":5,"invoiceTransactionId":197352167,"chargeExcludingGST":50,"chargeIncludingGST":55}]},{"serviceType":"Apple iPhone 8 64GB Monthly Repayment Charge","quantity":2,"excludingGstCost":110,"includingGstCost":110,"sigmaSpecId":"BSRO001_CB","isAggregated":true,"isTaxable":false,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4274,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":7,"invoiceTransactionId":197352169,"chargeExcludingGST":55,"chargeIncludingGST":55},{"invoiceLineNumber":6,"invoiceTransactionId":197352168,"chargeExcludingGST":55,"chargeIncludingGST":55}],"drillDownInputAttribute":{"statementNumber":"9900000202350","chargeId":4274},"drillDownEndpoint":"Repayment details"},{"serviceType":"Fixed Seat (Zone 1)","quantity":1,"excludingGstCost":50,"includingGstCost":55,"sigmaSpecId":"BSRC001_CB","startDate":"01 Apr","endDate":"30 Apr","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4260,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":8,"invoiceTransactionId":197352170,"chargeExcludingGST":50,"chargeIncludingGST":55}]}],"onceOffChargesAndCredits":[{"serviceType":"Jabra Stealth UC","quantity":1,"excludingGstCost":30,"includingGstCost":33,"sigmaSpecId":"BSOTC001_CB","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4269,"chargeType":"OnceOffCharge","disputeAttributes":[{"invoiceLineNumber":11,"invoiceTransactionId":197352173,"chargeExcludingGST":30,"chargeIncludingGST":33}]},{"serviceType":"Polaris Soundpro Touch 790","quantity":1,"excludingGstCost":35,"includingGstCost":38.5,"sigmaSpecId":"BSOTC001_CB","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4268,"chargeType":"OnceOffCharge","disputeAttributes":[{"invoiceLineNumber":12,"invoiceTransactionId":197352174,"chargeExcludingGST":35,"chargeIncludingGST":38.5}]},{"serviceType":"Polaris Soundpro Touch 790","quantity":1,"excludingGstCost":135,"includingGstCost":148.5,"sigmaSpecId":"BSOTC001_CB","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4267,"chargeType":"OnceOffCharge","disputeAttributes":[{"invoiceLineNumber":13,"invoiceTransactionId":197352175,"chargeExcludingGST":135,"chargeIncludingGST":148.5}]},{"serviceType":"Polaris Soundpro SW10ND","quantity":3,"excludingGstCost":420,"includingGstCost":462,"sigmaSpecId":"BSOTC001_CB","isAggregated":true,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4275,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":14,"invoiceTransactionId":197352176,"chargeExcludingGST":140,"chargeIncludingGST":154},{"invoiceLineNumber":10,"invoiceTransactionId":197352172,"chargeExcludingGST":140,"chargeIncludingGST":154},{"invoiceLineNumber":9,"invoiceTransactionId":197352171,"chargeExcludingGST":140,"chargeIncludingGST":154}]},{"serviceType":"Apple iPhone 8 64GB","quantity":2,"excludingGstCost":2400,"includingGstCost":2640,"isAggregated":true,"isTaxable":true,"isQueryable":true,"isDisputable":false,"chargeIdentifier":4277,"chargeType":"OnceOffCharge"},{"serviceType":"Apple iPhone 8 64GB","quantity":2,"excludingGstCost":-2640,"includingGstCost":-2640,"isAggregated":true,"isTaxable":false,"isQueryable":true,"isDisputable":false,"chargeIdentifier":4276,"chargeType":"CreditCharge"}]}}]}],"accountLevelChargesAndCredits":{"adjustmentsExcludingGstCost":0,"adjustmentsIncludingGstCost":0,"grossTotalBill":902,"amountOfGstIncludedInGrossTotalBill":312,"totalNewChargesInThisBill":902,"gstFreeItemsIncludedInNewCharges":110,"gstIncludedInNewCharges":312,"adjustmentsTotal":-603.02,"gstIncludedInAdjustments":-54.82}},"adjustmentSummary":{"totalAdjustmentsCost":-603.02,"totalGSTIncludedInAdjustments":-54.82,"adjustments":[{"adjustmentDescription":"Compensation Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-150.38,"gstIncludedInAdjustments":-13.67,"isQueryable":true,"isDisputable":false,"chargeIdentifier":80,"chargeType":"CreditCharge"},{"adjustmentDescription":"Goodwill Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-100.66,"gstIncludedInAdjustments":-9.15,"isQueryable":true,"isDisputable":false,"chargeIdentifier":78,"chargeType":"CreditCharge"},{"adjustmentDescription":"Goodwill Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-100.66,"gstIncludedInAdjustments":-9.15,"isQueryable":true,"isDisputable":false,"chargeIdentifier":79,"chargeType":"CreditCharge"},{"adjustmentDescription":"Compensation Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-150.66,"gstIncludedInAdjustments":-13.7,"isQueryable":true,"isDisputable":false,"chargeIdentifier":77,"chargeType":"CreditCharge"},{"adjustmentDescription":"Goodwill Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-100.66,"gstIncludedInAdjustments":-9.15,"isQueryable":false,"isDisputable":false,"chargeIdentifier":76,"chargeType":"CreditCharge"}]}}';
        InvoiceResponseDTO obj = InvoiceResponseDTO.parse(json);
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Case_Record_Type).getRecordTypeId();
        Account accountData = TestDataFactory.generateAccount();
        Test.startTest();
        Contact contactData = TestDataFactory.generateContact('Test FirstName', accountData.id,'Active','Test LastName',System.today(),'Mobile');
        contactData.email='abc@gmail.com';
        insert contactData;
        
        //Start of EDGE-133408  Component
        integer transactionIdList1 = 10;
        integer transactionIdList2=20;
        list<integer> transactionIdList =new list<integer>();
        transactionIdList.add(transactionIdList1);
        transactionIdList.add(transactionIdList2);
        
        Billing_Account__c billingAccountData = TestDataFactory.generateBillingAccount('700000002978','Created',accountData.Id, contactData.Id);
        insert billingAccountData;
        String contacteMail='abc@gmail.com';
        String rcChargeIds='(12453, 4261)';
        String chargeIdList='(49386, 49389, 49388)';
        String casecheck ='{"Priority":"Medium","Status":"New","Origin":"Assurance Service Agent"}';        //String caseInfo=String.valueOf(caseDatas);
        Id billingEnquiryRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Case_Billing_Enquiry_RecordType).getRecordTypeId();
        Map<String,Object> caseMap=new Map<String,Object>();
        caseMap.put('caseData',casecheck);
        caseMap.put('invLineItemData',json);
        caseMap.put('contacteMail',contacteMail);
        caseMap.put('rcChargeIds',rcChargeIds);
        caseMap.put('transactionIdList',transactionIdList);
        caseMap.put('chargeIdList',chargeIdList);
       
        system.runas(partneruser){ 
              InvoiceCmpHandler.CreateCaseRecord(caseMap);
          }
        Test.stopTest();
            list <case> caselist=[select id,Origin from case];
            
            for(case rec:caselist){
                system.debug('rec'+rec.Origin);
                System.assertEquals(rec.Origin, 'TPC');
                }
    }

    /*----------------------------------------------------------------
    Story(Sprint) : EDGE-207867(21.06)
    Method        : existCaseRecordTryTest
    Author        : Aman Soni
    ------------------------------------------------------------------*/
    @isTest
    public static void existCaseRecordTryTest(){
        User billUser = [select name,id, lastname from  User where username='billinguser@testbc.com'];
        User asaUser = [select name,id, lastname from  User where username='assuranceuser@testasa.com'];
        String json = '{"customerAddress":{"companyName":"MLC Company Ltd.","addressLine1":"Unit 1 1234 Lostmy Way","addressCity":"Sydney","stateAndPostalCode":"NSW 2000"},"invoiceDetails":{"accountNumber":"700000002978","invoiceNumber":"9900000202350","invoiceIssueDate":"24 Jul 19","invoicePeriod":"01 Mar 19 - 31 Mar 19","ariaInvoiceNumber":"148512498"},"paymentSummary":{"balanceCarriedForward":-603.02,"totalDue":298.98,"paymentsAndAdjustments":603.02,"dueDate":"07 Aug 19","newCharges":902},"serviceSummary":{"listOfOffers":[{"offerName":"Connected Workplace","offerTotalExcludingGstCost":590,"offerTotalIncludingGstCost":902,"invoiceDef":1,"listOfProducts":[{"physicalLocationName":"400 George St Sydney NSW","siteExcludingGstCost":590,"siteIncludingGstCost":902,"listOfChargesAndCredits":{"planCharges":[{"serviceType":"Bandwidth Bolt On","quantity":1,"excludingGstCost":50,"includingGstCost":55,"sigmaSpecId":"BSRC001_CB","startDate":"01 Apr","endDate":"30 Apr","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4261,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":5,"invoiceTransactionId":197352167,"chargeExcludingGST":50,"chargeIncludingGST":55}]},{"serviceType":"Apple iPhone 8 64GB Monthly Repayment Charge","quantity":2,"excludingGstCost":110,"includingGstCost":110,"sigmaSpecId":"BSRO001_CB","isAggregated":true,"isTaxable":false,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4274,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":7,"invoiceTransactionId":197352169,"chargeExcludingGST":55,"chargeIncludingGST":55},{"invoiceLineNumber":6,"invoiceTransactionId":197352168,"chargeExcludingGST":55,"chargeIncludingGST":55}],"drillDownInputAttribute":{"statementNumber":"9900000202350","chargeId":4274},"drillDownEndpoint":"Repayment details"},{"serviceType":"Fixed Seat (Zone 1)","quantity":1,"excludingGstCost":50,"includingGstCost":55,"sigmaSpecId":"BSRC001_CB","startDate":"01 Apr","endDate":"30 Apr","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4260,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":8,"invoiceTransactionId":197352170,"chargeExcludingGST":50,"chargeIncludingGST":55}]}],"onceOffChargesAndCredits":[{"serviceType":"Jabra Stealth UC","quantity":1,"excludingGstCost":30,"includingGstCost":33,"sigmaSpecId":"BSOTC001_CB","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4269,"chargeType":"OnceOffCharge","disputeAttributes":[{"invoiceLineNumber":11,"invoiceTransactionId":197352173,"chargeExcludingGST":30,"chargeIncludingGST":33}]},{"serviceType":"Polaris Soundpro Touch 790","quantity":1,"excludingGstCost":35,"includingGstCost":38.5,"sigmaSpecId":"BSOTC001_CB","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4268,"chargeType":"OnceOffCharge","disputeAttributes":[{"invoiceLineNumber":12,"invoiceTransactionId":197352174,"chargeExcludingGST":35,"chargeIncludingGST":38.5}]},{"serviceType":"Polaris Soundpro Touch 790","quantity":1,"excludingGstCost":135,"includingGstCost":148.5,"sigmaSpecId":"BSOTC001_CB","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4267,"chargeType":"OnceOffCharge","disputeAttributes":[{"invoiceLineNumber":13,"invoiceTransactionId":197352175,"chargeExcludingGST":135,"chargeIncludingGST":148.5}]},{"serviceType":"Polaris Soundpro SW10ND","quantity":3,"excludingGstCost":420,"includingGstCost":462,"sigmaSpecId":"BSOTC001_CB","isAggregated":true,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4275,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":14,"invoiceTransactionId":197352176,"chargeExcludingGST":140,"chargeIncludingGST":154},{"invoiceLineNumber":10,"invoiceTransactionId":197352172,"chargeExcludingGST":140,"chargeIncludingGST":154},{"invoiceLineNumber":9,"invoiceTransactionId":197352171,"chargeExcludingGST":140,"chargeIncludingGST":154}]},{"serviceType":"Apple iPhone 8 64GB","quantity":2,"excludingGstCost":2400,"includingGstCost":2640,"isAggregated":true,"isTaxable":true,"isQueryable":true,"isDisputable":false,"chargeIdentifier":4277,"chargeType":"OnceOffCharge"},{"serviceType":"Apple iPhone 8 64GB","quantity":2,"excludingGstCost":-2640,"includingGstCost":-2640,"isAggregated":true,"isTaxable":false,"isQueryable":true,"isDisputable":false,"chargeIdentifier":4276,"chargeType":"CreditCharge"}]}}]}],"accountLevelChargesAndCredits":{"adjustmentsExcludingGstCost":0,"adjustmentsIncludingGstCost":0,"grossTotalBill":902,"amountOfGstIncludedInGrossTotalBill":312,"totalNewChargesInThisBill":902,"gstFreeItemsIncludedInNewCharges":110,"gstIncludedInNewCharges":312,"adjustmentsTotal":-603.02,"gstIncludedInAdjustments":-54.82}},"adjustmentSummary":{"totalAdjustmentsCost":-603.02,"totalGSTIncludedInAdjustments":-54.82,"adjustments":[{"adjustmentDescription":"Compensation Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-150.38,"gstIncludedInAdjustments":-13.67,"isQueryable":true,"isDisputable":false,"chargeIdentifier":80,"chargeType":"CreditCharge"},{"adjustmentDescription":"Goodwill Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-100.66,"gstIncludedInAdjustments":-9.15,"isQueryable":true,"isDisputable":false,"chargeIdentifier":78,"chargeType":"CreditCharge"},{"adjustmentDescription":"Goodwill Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-100.66,"gstIncludedInAdjustments":-9.15,"isQueryable":true,"isDisputable":false,"chargeIdentifier":79,"chargeType":"CreditCharge"},{"adjustmentDescription":"Compensation Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-150.66,"gstIncludedInAdjustments":-13.7,"isQueryable":true,"isDisputable":false,"chargeIdentifier":77,"chargeType":"CreditCharge"},{"adjustmentDescription":"Goodwill Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-100.66,"gstIncludedInAdjustments":-9.15,"isQueryable":false,"isDisputable":false,"chargeIdentifier":76,"chargeType":"CreditCharge"}]}}';
        Test.startTest();
            Case caseRec = [Select id,Subject,Description,Contact.Id,Contact.Name from Case];
            String contacteMail='';
            String rcChargeIds='(12453, 4261)';
            String caseId = caseRec.Id;
            List<Integer> transactionIdList =new List<Integer>();
            Integer transactionIdList1 = 107895;
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

    /*----------------------------------------------------------------
    Story(Sprint) : EDGE-207867(21.06)
    Method        : fetchCaseObjLookUpValuesPosTest
    Author        : Aman Soni
    ------------------------------------------------------------------*/
    @isTest
    public static void fetchCaseObjLookUpValuesPosTest(){
        User billUser = [select name,id, lastname from  User where username='billinguser@testbc.com'];
        User asaUser = [select name,id, lastname from  User where username='assuranceuser@testasa.com'];
        Test.startTest();
            List<Billing_Account__c> billingAcc = [SELECT id, Billing_Account_Number__c FROM Billing_Account__c];
            String searchKeyWord='Test Case';
            String ObjectName='Case';
            String billingAccountId=billingAcc[0].id;
            System.runAS(billUser){
                List<sObject> lookUpValues=InvoiceCmpHandler.fetchCaseObjLookUpValues(searchKeyWord,ObjectName,billingAccountId);
                System.assertEquals(lookUpValues.isEmpty(),false);
            }
            System.runAS(asaUser){
                List<sObject> lookUpValues=InvoiceCmpHandler.fetchCaseObjLookUpValues(searchKeyWord,ObjectName,billingAccountId);
                System.assertEquals(lookUpValues.isEmpty(),false);
            }
        Test.stopTest();
    } 

    /*----------------------------------------------------------------
    Story(Sprint) : EDGE-207867(21.06)
    Method        : fetchCaseObjLookUpValuesNegTest
    Author        : Aman Soni
    ------------------------------------------------------------------*/
    @isTest
    public static void fetchCaseObjLookUpValuesNegTest(){
        User billUser = [select name,id, lastname from  User where username='billinguser@testbc.com'];
        User asaUser = [select name,id, lastname from  User where username='assuranceuser@testasa.com'];
        String searchKeyWord='Test Case';
        String ObjectName='Case';
        String billingAccountId='';
        Test.startTest();
            System.runAS(billUser){
                List<sObject> lookUpValues=InvoiceCmpHandler.fetchCaseObjLookUpValues(searchKeyWord,ObjectName,billingAccountId);
                System.assertEquals(lookUpValues.isEmpty(),true);
            }
            System.runAS(asaUser){
                List<sObject> lookUpValues=InvoiceCmpHandler.fetchCaseObjLookUpValues(searchKeyWord,ObjectName,billingAccountId);
                System.assertEquals(lookUpValues.isEmpty(),true);
            }
        Test.stopTest();
    }

    /*----------------------------------------------------------------
    Story(Sprint) : EDGE-207869(21.08)
    Method        : NoSearchKeyWordTest
    Author        : Aman Soni
    ------------------------------------------------------------------*/
    @isTest
    public static void NoSearchKeyWordTest(){
        User billUser = [select name,id, lastname from  User where username='billinguser@testbc.com'];
        User asaUser = [select name,id, lastname from  User where username='assuranceuser@testasa.com'];
        Test.startTest();
            List<Billing_Account__c> billingAcc = [SELECT id, Billing_Account_Number__c FROM Billing_Account__c];
            String searchKeyWord='';
            String ObjectName='Case';
            String billingAccountId=billingAcc[0].id;
            System.runAS(billUser){
                List<sObject> lookUpValues=InvoiceCmpHandler.fetchCaseObjLookUpValues(searchKeyWord,ObjectName,billingAccountId);
                System.assertEquals(lookUpValues.isEmpty(),false);
            }
            System.runAS(asaUser){
                List<sObject> lookUpValues=InvoiceCmpHandler.fetchCaseObjLookUpValues(searchKeyWord,ObjectName,billingAccountId);
                System.assertEquals(lookUpValues.isEmpty(),false);
            }
        Test.stopTest();
    }

    /*----------------------------------------------------------------
    Story(Sprint) : EDGE-207869(21.08)
    Method        : GetExistQlIAgainstCaseAndInvoiceClsPosTest
    Author        : Aman Soni
    ------------------------------------------------------------------*/
    @isTest
    public static void GetExistQlIAgainstCaseAndInvoiceClsPosTest(){
        User billUser = [select name,id, lastname from  User where username='billinguser@testbc.com'];
        User asaUser = [select name,id, lastname from  User where username='assuranceuser@testasa.com'];
        Queried_Line_Item__c qli = [Select id,Queried_Amount__c from Queried_Line_Item__c];
        Case caseRec = [Select id,Subject,Description from Case];
        String caseId = caseRec.id;
        Test.startTest();
            System.runAS(billUser){
                String res = InvoiceCmpHandler.GetExistQlIAgainstCaseAndInvoiceCls(caseId,'9900000017373');
                System.assertEquals(String.ValueOf(qli.Queried_Amount__c),res);
            }
            System.runAS(asaUser){
                String res = InvoiceCmpHandler.GetExistQlIAgainstCaseAndInvoiceCls(caseId,'9900000017373');
                System.assertEquals(String.ValueOf(qli.Queried_Amount__c),res);
            }
        Test.stopTest();
    }

    /*----------------------------------------------------------------
    Story(Sprint) : EDGE-207869(21.08)
    Method        : NoQlIAgainstCaseAndInvoiceTest
    Author        : Aman Soni
    ------------------------------------------------------------------*/
    @isTest
    public static void NoQlIAgainstCaseAndInvoiceTest(){
        User billUser = [select name,id, lastname from  User where username='billinguser@testbc.com'];
        User asaUser = [select name,id, lastname from  User where username='assuranceuser@testasa.com'];
        Test.startTest();
            System.runAS(billUser){
                String res = InvoiceCmpHandler.GetExistQlIAgainstCaseAndInvoiceCls('','');
                System.assertEquals('',res);
            }
            System.runAS(asaUser){
                String res = InvoiceCmpHandler.GetExistQlIAgainstCaseAndInvoiceCls('','');
                System.assertEquals('',res);
            }
        Test.stopTest();
    }

    /*----------------------------------------------------------------
    Story(Sprint) : EDGE-207869(21.08)
    Method        : getSharedDisplayMessageCSTest
    Author        : Aman Soni
    ------------------------------------------------------------------*/
    @isTest
    public static void getSharedDisplayMessageCSTest(){
        User billUser = [select name,id, lastname from  User where username='billinguser@testbc.com'];
        User asaUser = [select name,id, lastname from  User where username='assuranceuser@testasa.com'];
        List<SharedDisplayMessage__c> getCSList = [select id,Name,Value__c from  SharedDisplayMessage__c];
        List<SharedDisplayMessage__c> csList = new List<SharedDisplayMessage__c>();
        Test.startTest();
            System.runAS(billUser){
                csList = InvoiceCmpHandler.getSharedDisplayMessageCS();
                System.assertEquals(getCSList[0].Value__c,csList[0].Value__c);
            }
            System.runAS(asaUser){
                csList = InvoiceCmpHandler.getSharedDisplayMessageCS();
                System.assertEquals(getCSList[0].Value__c,csList[0].Value__c);
            }
        Test.stopTest();
    }

}