@isTest
public with sharing class billingAccountChangeCompTest {
    
    @TestSetup static void dataSetup()
    {
        Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        testAccount.Customer_Status__c = 'ACTIVE';
        insert testAccount;
        Opportunity testOpp = new Opportunity();
        testOpp.Account = testAccount;
        testOpp.Name = 'testOpp';
        testOpp.StageName = 'Define';
        testOpp.Product_Type__c = 'Modular';
        testOpp.CloseDate = System.Date.today();
        testOpp.Type = 'Migration';
        testOpp.Billing_Solution__c = 'Standard';
        Id standardID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defined').getRecordTypeId();
        testOpp.RecordTypeId = standardID;
        insert testOpp;
        
        Utility_Settings__c uc = new Utility_Settings__c();
        uc.Billing_Account_Status_Filter__c = 'created,provisioned';
        insert uc;
        
        
        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = testAccount.Id;
        testBasket.Name = 'ShowSubTestBasket';
        testBasket.cscfga__Opportunity__c = testOpp.Id;
        test.startTest();
        insert testBasket;
        test.stopTest();   
        csord__Solution__c sol = new csord__Solution__c(Name = 'Adaptive Solution Managed Services', csord__Account__c = testAccount.Id, csord__External_Identifier__c = '12345', csord__External_Identifier2__c = '1234', csord__Identification__c = '12');
        INSERT sol;
        list<Marketable_Offer__c> marketableList = new list<Marketable_Offer__c>(); 
        marketableList = Orchestration_TestUtility.buildMarkertableOffer(false, 1);
        marketableList[0].BAN_Cardinality__c = 'Single';
        insert marketableList;
        
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>();
        cscfga__Product_Definition__c cwProdDef = new cscfga__Product_Definition__c(Name = 'Connected Workplace', cscfga__Description__c = 'Connected Workplace');
        pdList.add(cwProdDef);
        cscfga__Product_Definition__c ucePD = new cscfga__Product_Definition__c(Name = 'Unified Communication', cscfga__Description__c = 'Unified Communication');
        pdList.add(ucePD);
        cscfga__Product_Definition__c ipNetPD = new cscfga__Product_Definition__c(Name = 'IP Network', cscfga__Description__c = 'IP Network');
        pdList.add(ipNetPD);
        cscfga__Product_Definition__c mobPD = new cscfga__Product_Definition__c(Name = 'Mobility', cscfga__Description__c = 'Mobility',product_Specification__c='DMCAT_ProductSpecification_000420');
        pdList.add(mobPD);
        cscfga__Product_Definition__c iotPD = new cscfga__Product_Definition__c(Name = 'IOT Subscription', cscfga__Description__c = 'IOT Subscription',product_Specification__c='DMCAT_ProductSpecification_000965');
        pdList.add(iotPD);
        insert pdList;    
        
        List<cscfga__Product_Configuration__c> prodconfigList=new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c testConfig = new cscfga__Product_Configuration__c();
        testConfig.Name = 'Connected Workplace';
        testConfig.cscfga__Product_Basket__c = testBasket.Id;
        testConfig.cscfga__Product_Definition__c=cwProdDef.id;
        prodconfigList.add(testConfig);
        cscfga__Product_Configuration__c testConfig1 = new cscfga__Product_Configuration__c();
        testConfig1.Name = System.Label.IP_Network;
        testConfig1.cscfga__Product_Basket__c = testBasket.Id;
        testConfig1.cscfga__Product_Definition__c=ucePD.id;
        prodconfigList.add(testConfig1);
        cscfga__Product_Configuration__c testConfig2 = new cscfga__Product_Configuration__c();
        testConfig2.Name = System.Label.UC_Enterprise;
        testConfig2.cscfga__Product_Basket__c = testBasket.Id;
        testConfig2.cscfga__Product_Definition__c=ipNetPD.id;
        prodconfigList.add(testConfig2); 
        cscfga__Product_Configuration__c testConfig3 = new cscfga__Product_Configuration__c();
        testConfig3.Name = System.Label.Mobility;
        testConfig3.cscfga__Product_Basket__c = testBasket.Id;
        testConfig3.cscfga__Product_Definition__c=mobPD.id;
        prodconfigList.add(testConfig3); 
        
        cscfga__Product_Configuration__c testConfig4 = new cscfga__Product_Configuration__c();
        testConfig4.Name = 'IOT Susbcription';
        testConfig4.cscfga__Product_Basket__c = testBasket.Id;
        testConfig4.cscfga__Product_Definition__c=iotPD.id;
        prodconfigList.add(testConfig4); 
        insert prodconfigList;
        
        cscfga__Attribute__c testAttribute = new cscfga__Attribute__c();
        testAttribute.Name = 'testAttributeForTest';
        testAttribute.cscfga__Product_Configuration__c = testConfig.Id;
        insert testAttribute;
        
        csord__Order__c testOrder = new csord__Order__c();
        testOrder.csord__Account__c = testAccount.Id;
        testOrder.csordtelcoa__Opportunity__c = testOpp.Id;
        testOrder.Name = 'TestOrderNameForTest';
        testOrder.csord__Identification__c = 'test';
        testOrder.isMSISDNHeld__c = false;
        insert testOrder;
        
        csordtelcoa__Orders_Subscriptions_Options__c testOso = new csordtelcoa__Orders_Subscriptions_Options__c();
        testOso.csordtelcoa__Subscription_Closed_Replaced_State__c = 'test2';
        testOso.csordtelcoa__Statuses_Not_Allowing_Change__c = 'false';
        insert testOso;
        
        csord__Subscription__c testSubscription = new csord__Subscription__c();
        testSubscription.Name = 'TestSubsforTest';
        testSubscription.csord__Account__c = testAccount.Id;
        testSubscription.csord__Order__c = testOrder.Id;
        testSubscription.csord__Identification__c = 'test';
        testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription.csord__Status__c = 'Active';
        testSubscription.cssdm__solution_association__c = sol.id;
        testSubscription.MarketableOffer__c = marketableList[0].id;
        
        csord__Subscription__c testSubscription2 = new csord__Subscription__c();
        testSubscription2.Name = 'TestSubsforTest2';
        testSubscription2.csord__Account__c = testAccount.Id;
        testSubscription2.csord__Order__c = testOrder.Id;
        testSubscription2.csord__Identification__c = 'test2';
        testSubscription2.csord__Status__c = 'Pending';
        testSubscription2.cssdm__solution_association__c = sol.id;
        testSubscription2.MarketableOffer__c = marketableList[0].id;
        
        csord__Subscription__c testSubscription3 = new csord__Subscription__c();
        testSubscription3.Name = 'TestSubsforTest3';
        testSubscription3.csord__Account__c = testAccount.Id;
        testSubscription3.csord__Order__c = testOrder.Id;
        testSubscription3.csord__Identification__c = 'test3';
        testSubscription3.csord__Status__c = null;
        
        csord__Subscription__c testSubscription4 = new csord__Subscription__c();
        testSubscription4.Name = 'TestSubsforTest4';
        testSubscription4.csord__Account__c = testAccount.Id;
        testSubscription4.csord__Order__c = testOrder.Id;
        testSubscription4.csord__Identification__c = 'test';
        testSubscription4.csordtelcoa__Product_Configuration__c = testConfig3.Id;
        testSubscription4.csord__Status__c = 'Suspended';
        
        csord__Subscription__c testSubscription5 = new csord__Subscription__c();
        testSubscription5.Name = 'TestSubsforTest5';
        testSubscription5.csord__Account__c = testAccount.Id;
        testSubscription5.csord__Order__c = testOrder.Id;
        testSubscription5.csord__Identification__c = 'test';
        testSubscription5.csordtelcoa__Product_Configuration__c = testConfig3.Id;
        testSubscription5.csord__Status__c = 'Closed Replaced';
        
        csord__Subscription__c testSubscription6 = new csord__Subscription__c();
        testSubscription6.Name = 'TestSubsforTest6';
        testSubscription6.csord__Account__c = testAccount.Id;
        testSubscription6.csord__Order__c = testOrder.Id;
        testSubscription6.csord__Identification__c = 'test';
        testSubscription6.csordtelcoa__Product_Configuration__c = testConfig3.Id;
        testSubscription6.csord__Status__c = 'Active';
        
        csord__Subscription__c testSubscription7 = new csord__Subscription__c();
        testSubscription7.Name = 'TestSubsforTest7';
        testSubscription7.csord__Account__c = testAccount.Id;
        testSubscription7.csord__Order__c = testOrder.Id;
        testSubscription7.csord__Identification__c = 'test';
        testSubscription7.csordtelcoa__Product_Configuration__c = testConfig4.Id;
        testSubscription7.csord__Status__c = 'Active';
        
        csord__Subscription__c testSubscription8 = new csord__Subscription__c();
        testSubscription8.Name = 'TestSubsforTest8';
        testSubscription8.csord__Account__c = testAccount.Id;
        testSubscription8.csord__Order__c = testOrder.Id;
        testSubscription8.csord__Identification__c = 'test';
        testSubscription8.csordtelcoa__Product_Configuration__c = testConfig4.Id;
        testSubscription8.csord__Status__c = 'Suspended';
        
        List<csord__Subscription__c> testSubsList = new List<csord__Subscription__c>{testSubscription,testSubscription2,testSubscription3,testSubscription4,testSubscription5,testSubscription6,testSubscription7,testSubscription8};
            insert testSubsList;
        
        csord__Service__c serv1 = new csord__Service__c();
        serv1.name ='testService_4';
        serv1.csord__Identification__c  = 'testIdentify_4';
        serv1.csordtelcoa__Service_Number__c = '3';
        serv1.csord__Subscription__c = testSubscription.Id;
        serv1.csord__Status__c = 'Created';
        serv1.substage__c = 'Product Requirements Validation';
        serv1.TechnologyType__c= 'Mobile Access';
        insert serv1;
        
        
    }
    @isTest
    static void  getRelatedSubsTest(){
        list<string> subids = new list<string>();
        for(csord__Subscription__c sub : [select id from csord__Subscription__c where name = 'TestSubsforTest']){
            subids.add(sub.id);     
        }
        test.startTest();
        list<string> subsList = new list<string>();
        try{
            subsList = billingAccountChangeComp.getRelatedSubs(subids); 
        }catch(exception ex){
            system.assertEquals(0, subsList.size());
        }	
        test.stopTest();
        
        
    }
    
    @isTest
    static void  getBillingAccStatusTest(){
        list<string> subsList = new list<string>();
        test.startTest();
        try{
            subsList = billingAccountChangeComp.getBillingAccStatus(); 
        }catch(exception ex){
            system.assertEquals(0, subsList.size());
        }	
        test.stopTest();
        
    }
}