@isTest
public class TestUtilTest {
	static testMethod void validateHelloWorld() {
        List<User> userlist = new List<User>();
        Account acc = TestUtil.createAccount('Test');
        insert acc;
        TestUtil.createBulkAccountWithPortfolio(5,'Test','test');
        Contact con = TestUtil.createContact('Test','Data');
        insert con;
        Contact con1 = TestUtil.createContact(acc.id,'FirstName','LastName');
        insert con1;
        cscrm__Address__c add = TestUtil.createAddress();
        insert add;
        Opportunity opp = TestUtil.createOpportunity(acc.id);
        insert opp;
        TestUtil.getAddress(add.id);
        TestUtil.addContactToAccount(acc.id,con.id);
        TestUtil.getAccount(acc.id);
        TestUtil.getContact(con.id);
        TestUtil.createOPTemplate('test');
        TestUtil.getRandomString();
        TestUtil.createSite(con.id,con1.id,acc.id);
        TestUtil.createRoleId('UserName','Alias','System Administrator','CEO');
        User testUser = TestUtil.createUser('testuser@test.com.sample', 'test', 'System Administrator');
        userlist.add(testUser);
        //FDR & Prod Test class failures because of DUPLICATE_USERNAME error during a deployment
    	//So Team SFO Added blow line for test coverage for usercreation method  in TestUtil class on date 02/09/2020 (Sprint 20.12)
        profile pr = [SELECT Id FROM Profile WHERE Name='system Administrator'];
        User testUser1 = TestUtil.createTestUser(null,pr.Id,'validate','HelloWorld');
        userlist.add(testUser1);
        insert userlist;
        TestUtil.createOpportunityLineItem(opp.id);
        TestUtil.createNPSS('Test NPSS');
        TestUtil.createCIDNRevenueTarget(acc.id);
        TestUtil.createPortfolioCode('Test Portfolio');
        Territory2 terCode = TestUtil.createPortfolioTerritories('TestModel', 'TEST00');
        List<String> territoryNames = new List<String>();
            territoryNames.add('test');
        territoryNames.add('test2');
        TestUtil.createPortfolioTerritories('test', territoryNames);
        System.assertEquals(territoryNames!=null, true, 'Territory created');
    }
     /*----------------------------------------------------------------
Method : createBasketTest
Author: Kalashree Borgaonkar
Story: EDGE-90327
-------------------------------------------------------------------------------------*/
    static testMethod void createBasketTest() {
        Account acc = TestUtil.createAccount('Test');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        Test.startTest();
        cscfga__Product_Basket__c basket = TestUtil.createBasket(opp,acc);
        Test.stopTest();   
        System.assertEquals(basket!=null, true, 'Basket created');
    }
     /*----------------------------------------------------------------
Method : createOCRTest
Author: Kalashree Borgaonkar
Story: EDGE-90327
-------------------------------------------------------------------------------------*/
    static testMethod void createOCRTest() {
        Account acc = TestUtil.createAccount('Test');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        Contact con = TestUtil.createContact('Test','Data');
        insert con;
        Test.startTest();
        OpportunityContactRole ocr = TestUtil.createOCR(con,opp);
        Test.stopTest();   
        System.assertEquals(ocr!=null, true, 'OpportunityContactRole created');
    }
     /*----------------------------------------------------------------
Method : createCustAuthorityFormTest
Author: Kalashree Borgaonkar
Story: EDGE-90327
-------------------------------------------------------------------------------------*/
    static testMethod void createCustAuthorityFormTest() {
        Account acc = TestUtil.createAccount('Test');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        Test.startTest();
        Customer_Authority_Form__c caf = TestUtil.createCustAuthorityForm(opp,acc);
        Test.stopTest();   
        System.assertEquals(caf!=null, true, 'Customer_Authority_Form__c created');
    }
    /*----------------------------------------------------------------
Method : bulkCreateCustAuthorityFormTest
Author: Aishwarya Yeware
Story: EDGE-100327
-------------------------------------------------------------------------------------*/
     static testMethod void bulkCreateCustAuthorityFormTest() {
        Account acc = TestUtil.createAccount('Test');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
         Contact con = TestUtil.createContact('Test','Data');
        insert con;
        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        Test.startTest();
        List<Customer_Authority_Form__c> caf = TestUtil.createBulkCAFwithPPV(200,opp,acc,con);
        Test.stopTest();   
        System.assertEquals(caf!=null, true, 'Customer_Authority_Form__c created');
    }
    /*----------------------------------------------------------------
Method : createServiceQualificationTest
Author: Kalashree Borgaonkar
Story: EDGE-90327 
-------------------------------------------------------------------------------------*/
    static testMethod void createServiceQualificationTest() {
        Account acc = TestUtil.createAccount('Test');
        acc.Customer_Status__c = 'ACQUIRED';       
        insert acc;
        Test.startTest();
        Service_Qualification__c sqRecord = TestUtil.createServiceQualification(acc,'61411111111','Y');
        Test.stopTest();   
        System.assertEquals(sqRecord!=null, true, 'Service_Qualification__c created');  
    }
    /*----------------------------------------------------------------
Method : createNumberTest
Author: Kalashree Borgaonkar
Story: EDGE-90327 
-------------------------------------------------------------------------------------*/
    static testMethod void createNumberTest() {
        Account acc = TestUtil.createAccount('Test Account1');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        Opportunity opp =  ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c=opp.id;
        insert basket;
        Service_Qualification__c sqRecord = TestUtil.createServiceQualification(acc,'61411111111','Y');
        insert sqRecord;
        Test.startTest();
        Number__c numberRecord = TestUtil.createNumber('61411111111',basket.id,sqRecord.id);
        Test.stopTest();
        System.assertEquals(numberRecord!=null, true,'Number__c created');
    }
    /*----------------------------------------------------------------
Method : createPriceLineTest
Author: Aishwarya 
Story: EDGE-98400 
-------------------------------------------------------------------------------------
     static testMethod void createPriceLineTest() {
         Test.startTest();
         cspmb__Price_Item__c commerpro=TestUtil.createPriceItem();        
		Test.stopTest();
         System.assertEquals(commerpro!=null, true,'Price Line item Created');
     }*/
        /*----------------------------------------------------------------
Method : createBillingAccountTest
Author: Kalashree Borgaonkar
Story: EDGE-90327
-------------------------------------------------------------------------------------*/
    static testMethod void createBillingAccountTest() {
        Test.startTest();
        Billing_Account__c acc = TestUtil.createBillingAccount('700000002978');
        insert acc;
        Test.stopTest(); 
        System.assertEquals(acc.id!=null, true,'Billing_Account__c created');
    }
    /*----------------------------------------------------------------
Method : createBillingAccountTest
Author: Kalashree Borgaonkar
Story: EDGE-90327
-------------------------------------------------------------------------------------*/
    static testMethod void createInvoiceTest() {
        Test.startTest();
        Invoice__c invoice = TestUtil.createInvoice('700000002978','9900000202350');
        Test.stopTest(); 
        System.assertNotEquals(invoice.id!=null, true,'Invoice__c created');
    }
    static testMethod void addAddressToAccountTest() {
        Test.startTest();
        Account acc = TestUtil.createAccount('Test Account1');
        cscrm__Address__c address=TestUtil.createAddress();
        insert address;
        Boolean conUpdate=TestUtil.addAddressToAccount(acc.Id,address.Id);
        Test.stopTest(); 
        System.assertEquals(TRUE, conUpdate);
    }
     /*----------------------------------------------------------------
Method : createCongaQueryTest
Author: Kalashree Borgaonkar
Story: EDGE-93357
-------------------------------------------------------------------------------------*/
    static testMethod void createCongaQueryTest() {
        Test.startTest();
        APXTConga4__Conga_Merge_Query__c query =  TestUtil.createCongaQuery('CAFtemplate','Document');
        Test.stopTest();
        System.assertEquals(query!=null, true, 'msg'); 
    }
     /*----------------------------------------------------------------
Method : createCongaTemplateTest
Author: Kalashree Borgaonkar
Story: EDGE-93357
-------------------------------------------------------------------------------------*/
    static testMethod void createCongaTemplateTest() {
        Test.startTest();
        APXTConga4__Conga_Template__c template =  TestUtil.createCongaTemplate('CAFtemplate','Document','BSA');
        Test.stopTest();
        System.assertEquals(template!=null, true, 'msg'); 
        
    }
    
    static testMethod void createSQTabViewRecords(){
        Account acc = TestUtil.createAccount('Test');
        acc.Customer_Status__c = 'ACQUIRED';       
        insert acc;
        Test.startTest();
        Service_Qualification__c sqRecord = TestUtil.createServiceQualification(acc,'61411111111','Y');
        Carriage_Solutions__c carriageSolRecord = TestUtil.createCarriageSolutions(sqRecord.Id);
        Service_Qualification_Provider_Resource__c serviceQualProviderRecord=TestUtil.createSQProviderResource(sqRecord.Id);
        Service_Qualification_Resource_Detail__c serviceQualResourceDetail=TestUtil.createSQResource(sqRecord.Id);
        Service_Qualification_Port_Detail__c serviceQualPortDetail=TestUtil.createPortDetails(serviceQualResourceDetail.Id);
        Test.stopTest();
    }
    //TEAM SFO Sprint 21.12 DIGI-8926 Coverage for createOpportunityTeamMember,createAccountTeamMember in TestUtil
    static testMethod void createTeamMember(){
        User testUser = TestUtil.createUser('testuser@test.com.sample', 'test', System.Label.Profile_SystemAdmin);
        insert testUser;
        Account customerAccount = TestUtil.createAccount('Test Account Team Test');
            customerAccount.Customer_Status__c = 'Active';
        insert customerAccount;
        AccountTeamMember member1 = TestUtil.createAccountTeamMember(testUser.id,'Edit','Sales Rep',customerAccount.id);
        insert member1;
        Opportunity opp = TestUtil.createOpportunity(customerAccount.id);
        insert opp;
        OpportunityTeamMember member2 =TestUtil.createOpportunityTeamMember(testUser.id,'Edit','Sales Rep',opp.id);
        insert member2;
    }
         /*----------------------------------------------------------------
Method : createLeadTaskTest
Author: Chhaveel
Story: DIGI-34437
-------------------------------------------------------------------------------------*/
    static testMethod void createLeadTaskTest() {
        Test.startTest();
        Account acc = TestUtil.createAccount('Test');
        insert acc;
        Lead testLead  = TestUtil.createLead(acc.id, 'lead' , 'Test', Schema.SObjectType.lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Migration).getRecordTypeId() ,'Test@Lead.com');
        insert testLead;
        Task testTask  = TestUtil.createTask(testLead.Id, System.Label.Task_Status_Completed,Label.TaskSubjectFirstBill);
        insert testTask;
        Test.stopTest();
        System.assertEquals(testLead!=null, true, 'msg'); 
        System.assertEquals(testTask!=null, true, 'msg'); 
        
    }
}