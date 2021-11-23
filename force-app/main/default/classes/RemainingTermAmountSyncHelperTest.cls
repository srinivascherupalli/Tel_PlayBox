/******************************************************************
User Story   : DIGI-25050
Description  : To update get configuration, subscription details and invoke class for BDS Sync callout
Class Name   : RemainingTermAmountSyncHelperTest
Created By   : Team Alexandria, Divakar Tangudu
Created On   : 28 October 2021
*******************************************************************/
@istest
public class RemainingTermAmountSyncHelperTest {
    @testsetup
    static void testdata() {
        Account acc = new Account();
        acc.Name = 'account1';
        insert acc;
		
        Contact contact = AccountTestFactory.buildContact(acc, 'Smiths');   
        insert contact; 
		
		Billing_Account__c bAcc = new Billing_Account__c();
        bAcc.Billing_Account_Owner__c = contact.Id;
        bAcc.Account__c = acc.Id;
		bAcc.Status__c = 'Allocated';
        bAcc.Billing_Account_Number__c = '000000000002';
        insert bAcc;

        Opportunity opty = new Opportunity();
        opty.Account = acc;
        opty.Name = 'opty1122';
        opty.StageName = 'Define';
        opty.CloseDate = System.Date.today();
        opty.Product_Type__c = 'Modular';
        insert opty;
		
        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = acc.Id;
        testBasket.Name = 'ShowSubTestBasket';
        testBasket.cscfga__Opportunity__c = opty.Id;
       // testBasket.csordtelcoa__Change_Type__c = 'Upgrade';
        insert testBasket;
        
        cscfga__Product_Definition__c pd1 = new cscfga__Product_Definition__c ();
        pd1.Name = 'Next Generation Enterprise Mobility ';
        pd1.cscfga__Description__c = 'Description';
        pd1.product_Specification__c='DMCAT_ProductSpecification_001211';
        insert pd1;
        cscfga__Product_Configuration__c testConfig = new cscfga__Product_Configuration__c();
        testConfig.Name = 'Adaptive mobility';
        testConfig.cscfga__Product_Basket__c = testBasket.Id;
        testConfig.cscfga__Product_Definition__c=pd1.ID;
        insert testConfig;
        

        cscfga__Attribute__c testAttribute = new cscfga__Attribute__c();
        testAttribute.Name = 'testAttributeForTest';
        testAttribute.cscfga__Product_Configuration__c = testConfig.Id;
        insert testAttribute;

        csord__Order__c testOrder = new csord__Order__c();
        testOrder.csord__Account__c = acc.Id;
        testOrder.csordtelcoa__Opportunity__c = opty.Id;
        testOrder.Name = 'TestOrderNameForTest';
        testOrder.csord__Identification__c = 'test';
        insert testOrder;

        csordtelcoa__Orders_Subscriptions_Options__c testOso = new csordtelcoa__Orders_Subscriptions_Options__c();
        testOso.csordtelcoa__Subscription_Closed_Replaced_State__c = 'test2';
        testOso.csordtelcoa__Statuses_Not_Allowing_Change__c = 'false';
        insert testOso;

        csord__Subscription__c testSubscription = new csord__Subscription__c();
        testSubscription.Name = 'Adaptive mobility';
        testSubscription.csord__Account__c = acc.Id;
        testSubscription.csord__Order__c = testOrder.Id;
        testSubscription.csord__Identification__c = 'test';
        testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription.csord__Status__c = 'Active';
		testSubscription.csordtelcoa__Subscription_Number__c='SN-000238528';
        
        insert testSubscription;
        
        
        csord__Subscription__c testSubscription1 = new csord__Subscription__c();
        testSubscription1.Name = 'Next gen MOBILE';
        testSubscription1.csord__Account__c = acc.Id;
        testSubscription1.csord__Order__c = testOrder.Id;
        testSubscription1.csord__Identification__c = 'test';
        testSubscription1.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription1.csord__Status__c = 'Active';
        insert testSubscription1;
        csord__Service__c serv2 = new csord__Service__c();
        serv2.name ='User - Fixed Seat';
		serv2.csordtelcoa__Product_Configuration__c = testConfig.id;
        serv2.csord__Identification__c  = 'testIdentify_2';
        serv2.csord__Subscription__c = testSubscription.Id;
        insert serv2;
        
        cscfga__Product_Configuration__c testConfig1 = new cscfga__Product_Configuration__c();
        testConfig1.Name = 'Next Gen Mobile service';
        testConfig1.cscfga__Product_Basket__c = testBasket.Id;
        testConfig1.csordtelcoa__Replaced_Product_Configuration__c=testConfig.Id;
        testConfig1.cscfga__Product_Definition__c=pd1.ID;
		testConfig1.csordtelcoa__Replaced_Subscription__c=testSubscription1.id;
		testConfig1.Billing_Account__c=bAcc.id;
        insert testConfig1;
        
    }

	@istest
    static  void getConfig() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        cscfga__Product_Configuration__c conf =[select id,name,csordtelcoa__Replaced_Subscription__c ,csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c, 
        Billing_Account__r.Billing_Account_Number__c,
        csordtelcoa__Replaced_Subscription__r.csordtelcoa__Subscription_Number__c
        from cscfga__Product_Configuration__c where Name='Next Gen Mobile service'];
         inputMap.put('GetConfig',conf.id );
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSyncReqToBDSRespGenerator());
            returnMap = RemainingTermAmountSyncHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('GetTermAmount'));        
    }
	
		@istest
    static  void getConfigNone() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        cscfga__Product_Configuration__c conf =[select id,name from cscfga__Product_Configuration__c where Name='Adaptive mobility'];
         inputMap.put('GetConfig',conf.id );
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSyncReqToBDSRespGenerator());
            returnMap = RemainingTermAmountSyncHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('GetTermAmount'));        
    }

}