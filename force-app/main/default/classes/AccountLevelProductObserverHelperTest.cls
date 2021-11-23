/*********************
Class Name: AccountLevelProductObserverHelperTest
============================================================================
ChangeSet   No    Name            Date                    Description
EDGE-89844  1     Rohit T 		 12-June-2019             Products are not getting added for MAC Mobility order
*********************/
@isTest
public with sharing class AccountLevelProductObserverHelperTest {
      
    @TestSetup static void dataSetup()
    {
        Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        insert testAccount;

        Opportunity testOpp = new Opportunity();
        testOpp.Account = testAccount;
        testOpp.Name = 'testOpp1122';
        testOpp.StageName = 'Define';
        testOpp.CloseDate = System.Date.today();
        testOpp.Product_Type__c = 'Modular';
        insert testOpp;

        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = testAccount.Id;
        testBasket.Name = 'ShowSubTestBasket';
        testBasket.cscfga__Opportunity__c = testOpp.Id;
       // testBasket.csordtelcoa__Change_Type__c = 'Upgrade';
        insert testBasket;
        
        cscfga__Product_Definition__c pd1 = new cscfga__Product_Definition__c ();
        pd1.Name = 'IP Network';
        pd1.cscfga__Description__c = 'Description';
        insert pd1;
       
        
       

        cscfga__Product_Configuration__c testConfig = new cscfga__Product_Configuration__c();
        testConfig.Name = 'IP Network';
        testConfig.cscfga__Product_Basket__c = testBasket.Id;
        insert testConfig;
        cscfga__Product_Configuration__c testConfig1 = new cscfga__Product_Configuration__c();
        testConfig.Name = '	Unified Communication Enterprise';
        testConfig.cscfga__Product_Basket__c = testBasket.Id;
        insert testConfig1;

        cscfga__Attribute__c testAttribute = new cscfga__Attribute__c();
        testAttribute.Name = 'testAttributeForTest';
        testAttribute.cscfga__Product_Configuration__c = testConfig.Id;
        insert testAttribute;

        csord__Order__c testOrder = new csord__Order__c();
        testOrder.csord__Account__c = testAccount.Id;
        testOrder.csordtelcoa__Opportunity__c = testOpp.Id;
        testOrder.Name = 'TestOrderNameForTest';
        testOrder.csord__Identification__c = 'test';
        insert testOrder;

        csordtelcoa__Orders_Subscriptions_Options__c testOso = new csordtelcoa__Orders_Subscriptions_Options__c();
        testOso.csordtelcoa__Subscription_Closed_Replaced_State__c = 'test2';
        testOso.csordtelcoa__Statuses_Not_Allowing_Change__c = 'false';
        insert testOso;

        csord__Subscription__c testSubscription = new csord__Subscription__c();
        testSubscription.Name = 'IP Network';
        testSubscription.csord__Account__c = testAccount.Id;
        testSubscription.csord__Order__c = testOrder.Id;
        testSubscription.csord__Identification__c = 'test';
        testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription.csord__Status__c = 'Active';
        insert testSubscription;
        
        
        csord__Subscription__c testSubscription1 = new csord__Subscription__c();
        testSubscription1.Name = 'Unified Communication Enterprise';
        testSubscription1.csord__Account__c = testAccount.Id;
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

    }
    @isTest
    static void testCheckSubPresentOnAcc()
    {    
            cscfga__Product_Configuration__c prodConfig = [Select id, Name, cscfga__Product_Definition__r.name from cscfga__Product_Configuration__c where  name = 'IP Network'];   
        Test.startTest();
            AccountLevelProductObserverHelper.checkSubPresentOnAcc(prodConfig);
            system.assert(prodConfig!=null);
        Test.stopTest();
    }
    
}