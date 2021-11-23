/*
===============================================================================================================================
Developer Name : Shubhi
Test Class : AccountExistingTenancyControllerTest
===============================================================================================================================
Sr.No.    Developer Name        Date          Story Description
1          shubhi             18/10/2019      Edge-112555
2          vivek              08/04/2021      edge-206232
===============================================================================================================================*/
@isTest
public class AccountExistingTenancyControllerTest {
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
        testOpp.Type = 'New To Market';
        testOpp.Product_Domain__c = 'FIXED TELEPHONY';
        testOpp.Pricing_Method__c = 'PET';
        testOpp.Billing_Solution__c = 'Non Standard';
        insert testOpp;
        
        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = testAccount.Id;
        testBasket.Name = 'ShowSubTestBasket';
        testBasket.cscfga__Opportunity__c = testOpp.Id;
        insert testBasket;
        
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>();
        cscfga__Product_Definition__c CW_PD = new cscfga__Product_Definition__c(Name = 'T-MDM', product_Specification__c='DMCAT_ProductSpecification_000537',cscfga__Description__c = 'Tenancy');
        pdList.add(CW_PD);
        insert pdList;
        
        List<cscfga__Product_Configuration__c> prodconfigList=new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c testConfig = new cscfga__Product_Configuration__c();
        testConfig.Name = 'T-MDM';
        testConfig.cscfga__Product_Basket__c = testBasket.Id;
        testConfig.cscfga__Product_Definition__c=CW_PD.id;
        prodconfigList.add(testConfig);
        insert prodconfigList;
        
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
        List<csord__Subscription__c> subslist=new List<csord__Subscription__c>();
        csord__Subscription__c testSubscription = new csord__Subscription__c();
        testSubscription.Name = 'TestSubsforTest';
        testSubscription.csord__Account__c = testAccount.Id;
        testSubscription.csord__Order__c = testOrder.Id;
        testSubscription.csord__Identification__c = 'test';
        testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
        //testSubscription.ConfigSpecID__c = 'DMCAT_ProductSpecification_000537';
        testSubscription.csord__Status__c = 'Active';
        subslist.add(testSubscription);
        csord__Subscription__c testSubscription4 = new csord__Subscription__c();
        testSubscription4.Name = 'TestSubsforTest4';
        testSubscription4.csord__Account__c = testAccount.Id;
        testSubscription4.csord__Order__c = testOrder.Id;
        testSubscription4.csord__Identification__c = 'test';
        //testSubscription4.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription4.csord__Status__c = 'Suspended';
        subslist.add(testSubscription4);
        insert subslist;
        
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify';
        serv.csord__Subscription__c  = testSubscription.id;
        serv.csord__Order__c = testOrder.id;
        serv.csordtelcoa__Service_Number__c = '3';
        insert serv;
        
        
        //List<Attachment> atts = new List<Attachment>();
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{"specifications" :[{"version" : "1","status" : "Created","startDate" : "","specification" : "f2e195ae-049a-4c3f-bb08-eed2cba1ff89","productConfigurationId" : "a3T0l0000004oFiEAI","name" : "User","instanceId" : "","guid" : "059719f3-07de-4c93-1068-df146594a48b","endDate" : "","description" : "Sample Billing Spec for Munich Testing","code" : "PS_000074","attributes" : {"__targetSystem" : "BILLING","code" : "CWP_OFFER_123","productId" : "SEAT_123","units" : "25","unitPrice" : "150","prorate" : "false", "invoiceDefinition" : "Invoice_Def_1", "billInAdvance" : "false","billingSpecId" : "BSRC001_CB","frequency" : "Monthly","currency" : "AUD","type" : "RC", "description" : "CWP Zone 1 Seat Charges"},"additionalAttributes" : {"parentSpec" :"059719f3-07de-2911-1068-df146594a48b"}}, {"version" : "1","status" : "Created","startDate" : "","specification" : "f2e195ae-049a-4c3f-bb08-eed2cba1ff89","productConfigurationId" : "a3T0l0000004oFiEAI","name" : "Broadsoft Tenancy_Fulfilment","instanceId" : "","guid" : "5d9d486d-008b-12ba-78fd-687b6f212681","endDate" : "","description" : "Sample Billing Spec for Munich Testing","code" : "PS_000074","attributes" : {"__targetSystem" : "Billing","code" : "CWP_OFFER_123","productId" : "SEAT_123","units" : "25","amount" : "150","billDescription" : "Seat Charge for Zone 2","prorateType" : "false","billInAdvance" : "false","billingSpecId" : "BSRC001_CB","frequency" : "Monthly","currency" : "AUD","type" : "RC"},"additionalAttributes" : { }} ],"serviceId" : "a4e0l00000005U9AAI","legacyAttributes" : [ ]}');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        insert att1;
        
    }
    
    @isTest
    static void testGetSubscriptions()
    {
        Account resultAccount = new Account();
        Account testAccount = [SELECT id, Name FROM Account LIMIT 1];
        Test.startTest();
        List<String> tenancyofferList=new List<String>();
        tenancyofferList.add('DMCAT_ProductSpecification_000537');
        List<csord__Subscription__c> subslist= AccountExistingTenancyController.getSubscriptions(testAccount.id,'','true',tenancyofferList);
        Test.stopTest();
        System.assert(subslist.size()>0);
        
    }
    @isTest
    static void testGetSubscriptions2()
    {
        cscfga__Product_Basket__c testBasket = [SELECT id,csbb__Account__c FROM cscfga__Product_Basket__c LIMIT 1];
        csord__Subscription__c sub=[Select id,csordtelcoa__Product_Configuration__c,csord__Status__c from csord__Subscription__c where  ConfigSpecID__c = 'DMCAT_ProductSpecification_000537' limit 1 ];
        sub.csordtelcoa__Product_Configuration__c=null;
        sub.csord__Status__c='Inactive';
        update sub;
        List<String> tenancyofferList=new List<String>();
        tenancyofferList.add('DMCAT_ProductSpecification_000537');
        Test.startTest();
        List<csord__Subscription__c> subslist= new List<csord__Subscription__c>();
        subslist=AccountExistingTenancyController.getSubscriptions('',testBasket.id,'true',tenancyofferList);
        subslist=AccountExistingTenancyController.getSubscriptions(testBasket.csbb__Account__c,'','true',tenancyofferList);
        Test.stopTest();
        System.assert(subslist.IsEmpty());
    }
    @isTest
    static void testGetSubscriptionsNegativeSecnario()
    {
        Account resultAccount = new Account();
        Account testAccount = [SELECT id, Name FROM Account LIMIT 1];
        csord__Subscription__c sub=[Select id,csordtelcoa__Product_Configuration__c,csord__Status__c from csord__Subscription__c where  ConfigSpecID__c = 'DMCAT_ProductSpecification_000537' limit 1 ];
        sub.csordtelcoa__Product_Configuration__c=null;
        sub.csord__Status__c='Inactive';
        update sub;
        List<String> tenancyofferList=new List<String>();
        tenancyofferList.add('DMCAT_ProductSpecification_000537');
        Test.startTest();
        List<csord__Subscription__c> subslist= new List<csord__Subscription__c>();
        subslist=AccountExistingTenancyController.getSubscriptions('','','true',tenancyofferList);
        subslist=AccountExistingTenancyController.getSubscriptions(testAccount.id,'','true',tenancyofferList);
        Test.stopTest();
        System.assert(subslist.IsEmpty());
    }
    
    @isTest
    static void testgetActualGUID()
    {    
        List<csord__Subscription__c> subList = [ SELECT Id ,csordtelcoa__Subscription_Number__c from csord__Subscription__c where csord__Status__c = 'Active'];
        list<csord__Service__c> serviceList          =   [select id from csord__Service__c where csord__Subscription__r.csordtelcoa__Subscription_Number__c =: subList[0].csordtelcoa__Subscription_Number__c];
        System.assertEquals( serviceList.size() > 0 , true);
        Test.startTest();
        List<String> tenancyofferList=new List<String>();
        tenancyofferList.add('DMCAT_ProductSpecification_000311');
        String guId= AccountExistingTenancyController.getActualGUID( subList[0].id );
        Test.stopTest();
        System.assertEquals( guId , '5d9d486d-008b-12ba-78fd-687b6f212681' , 'guid from servicespec should be matched');
        
    }
    
    @isTest
    static void testgetActualGUID_Negative()
    {
        Test.startTest();
        String guId= AccountExistingTenancyController.getActualGUID( null );
        Test.stopTest();
        
        System.assertNotEquals( guId , '5d9d486d-008b-12ba-78fd-687b6f212681' , 'guid from servicespec not should be matched, and null');
        
    }
}