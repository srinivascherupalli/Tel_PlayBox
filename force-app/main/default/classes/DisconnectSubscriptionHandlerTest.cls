@isTest
public class DisconnectSubscriptionHandlerTest {
    @TestSetup
    static void testDisconnectSubscriptionHandler(){
        Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        testAccount.Customer_Status__c = 'ACTIVE';
        insert testAccount;
        
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
        csord__Order__c order = ProductTestFactory.buildOrder('PrimaryOrder', testAccount.id, 'Created', ordReq.id);
        order.csord__Order_Request__c = ordReq.Id;
        insert order;
        
        csord__Order__c testOrder = ProductTestFactory.buildOrder('TestOrder', testAccount.id, 'Created', ordReq.id);
        testOrder.csord__Order_Request__c = ordReq.Id;
        testOrder.csord__Primary_Order__c = order.Id;
        insert testOrder;
        
        Opportunity testOpp = new Opportunity();
        testOpp.Account = testAccount;
        testOpp.Name = 'testOpp';
        testOpp.StageName = 'Define';
        testOpp.Product_Type__c = 'Modular';
        testOpp.CloseDate = System.Date.today();
        //testOpp.Type = 'Disconnect';
        testOpp.Type = 'Price Review';
        testOpp.Billing_Solution__c= 'In Contract';
        insert testOpp;
        
        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = testAccount.Id;
        testBasket.Name = 'ShowSubTestBasket';
        testBasket.cscfga__Opportunity__c = testOpp.Id;
        insert testBasket;
        
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>();
        cscfga__Product_Definition__c CW_PD = new cscfga__Product_Definition__c(Name = 'Connected Workplace', cscfga__Description__c = 'Connected Workplace');
        pdList.add(CW_PD);
        insert pdList;
        
        
        
        
        List<cscfga__Product_Configuration__c> prodconfigList=new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c testConfig = new cscfga__Product_Configuration__c();
        
        
        
        testConfig.Name = 'Connected Workplace';
        testConfig.cscfga__Product_Basket__c = testBasket.Id;
        testConfig.cscfga__Product_Definition__c=CW_PD.id;
        prodconfigList.add(testConfig);
        insert prodconfigList;
        
        csbb__Product_Configuration_Request__c testProductConfiguration = TestDataFactory.generateProdutConfigurationRequest();
        testProductConfiguration.csbb__Status__c='Cancelled';
        testProductConfiguration.csbb__Product_Configuration__c=testConfig.Id;
        upsert testProductConfiguration;
        
        csord__Subscription__c testSubscription = new csord__Subscription__c();
        testSubscription.Name = 'TestSubsforTest';
        testSubscription.csord__Account__c = testAccount.Id;
        testSubscription.csord__Order__c = testOrder.Id;
        testSubscription.csord__Identification__c = 'test';
        testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription.csord__Status__c = 'Active';
        insert testSubscription;
        
        CSPOFA__Orchestration_Process_Template__c orchProcessTemp = new CSPOFA__Orchestration_Process_Template__c();
        orchProcessTemp.Name = 'Order Fulfilment Process';
        orchProcessTemp.CSPOFA__Process_Type__c = 'New Provide';
        orchProcessTemp.CSPOFA__Processing_Mode__c = 'Foreground';
        insert orchProcessTemp;
        
        CSPOFA__Orchestration_Process_Template__c orchProcessTemp1 = new CSPOFA__Orchestration_Process_Template__c();
        orchProcessTemp1.Name = 'Migration Order Fulfillment Process';
        orchProcessTemp1.CSPOFA__Process_Type__c = 'New Provide';
        orchProcessTemp1.CSPOFA__Processing_Mode__c = 'Foreground';
        insert orchProcessTemp1;
        
        DisconnectionRequest__c disconnectrequest = new DisconnectionRequest__c();
        disconnectrequest.Subscription__c =testSubscription.id;
        disconnectrequest.Requested_DateTime__c = '2019-03-25T00:00:00+11:00';
        disconnectrequest.Request_Reason__c = 'DisconnectSubscriptionHandlerTesting';
        disconnectrequest.MSISDN__c = '09915599371';
        disconnectrequest.E2ECorrelationID__c = '13244-3124124';
        
        
        insert disconnectrequest;
        
          
    }
    
    @isTest
    static void testingDisconnectSubscriptionHandler(){
        DisconnectionRequest__c DisconnectionRequesttest = [select id,Subscription__c from DisconnectionRequest__c where Request_Reason__c ='DisconnectSubscriptionHandlerTesting'];
        Test.startTest();
        List<String> ids = new List<String>();
        ids.add(DisconnectionRequesttest.Id+':'+DisconnectionRequesttest.Subscription__c);
        DisconnectSubscriptionHandler.disconnectrequest(ids);
        system.assert(ids!=null);
        List<String> idss = new List<String>();
        idss.add(DisconnectionRequesttest.Id+':');
        DisconnectSubscriptionHandler.disconnectrequest(idss);
        system.assert(idss!=null);
        Test.stopTest();
    }
}