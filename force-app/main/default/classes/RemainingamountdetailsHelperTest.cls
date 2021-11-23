@istest
public class RemainingamountdetailsHelperTest {
    @testsetup
    static void testdata() {
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
        testSubscription.Name = 'Adaptive mobility';
        testSubscription.csord__Account__c = testAccount.Id;
        testSubscription.csord__Order__c = testOrder.Id;
        testSubscription.csord__Identification__c = 'test';
        testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
        //testSubscription.csordtelcoa__Subscription_Number__c='SN-000123457';
        testSubscription.csord__Status__c = 'Active';
        
        insert testSubscription;
        
        
        csord__Subscription__c testSubscription1 = new csord__Subscription__c();
        testSubscription1.Name = 'Next gen MOBILE';
        testSubscription1.csord__Account__c = testAccount.Id;
        testSubscription1.csord__Order__c = testOrder.Id;
        testSubscription1.csord__Identification__c = 'test';
        testSubscription1.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription1.csord__Status__c = 'Active';
        //testSubscription1.csordtelcoa__Subscription_Number__c='SN-000123456';
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
        insert testConfig1;
        
        Orchestration_Technical__c ot = new Orchestration_Technical__c();
		ot.Process_Name__c = 'Order';
		ot.Field_9__c = 'aaaabbbbccccdddd';
        ot.Field_19__c=testBasket.id;
        ot.Field_29__c='Chatter sent to User';
        ot.Field_17__c=testSubscription1.csordtelcoa__Subscription_Number__c;
        ot.Field_20__c='10';
        ot.Field_21__c='100';
		insert ot;

    }
    @istest
    static  void getBasketTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        //List<cscfga__Product_Basket__c> basket1 = new List<cscfga__Product_Basket__c>();
      cscfga__Product_Basket__c  basket1 = [select id from cscfga__Product_Basket__c];
        cscfga__Product_Configuration__c conf =[select id,csordtelcoa__Replaced_Subscription__r.csordtelcoa__Subscription_Number__c from cscfga__Product_Configuration__c where Name='Next Gen Mobile service'];
        //system.debug('config' +conf);
        Orchestration_Technical__c orch =[select id,Field_17__c from Orchestration_Technical__c];
        orch.Field_17__c=conf.csordtelcoa__Replaced_Subscription__r.csordtelcoa__Subscription_Number__c;
        update orch;
        system.debug('hi'+ basket1);
        inputMap.put('GetBasket',basket1.id );
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
            returnMap = RemainingamountdetailsHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('GetBasket'));        
    }
    
    @istest
    static  void BdsresponcenotRecivedTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        //List<cscfga__Product_Basket__c> basket1 = new List<cscfga__Product_Basket__c>();
      cscfga__Product_Basket__c  basket1 = [select id from cscfga__Product_Basket__c];
        Orchestration_Technical__c orch =[select id,Field_29__c from Orchestration_Technical__c];
        orch.Field_29__c='Accepted';
        update orch;
        //cscfga__Product_Configuration__c conf =[select id from cscfga__Product_Configuration__c where cscfga__Product_Definition__r.product_Specification__c ='DMCAT_ProductSpecification_001211'];
        //system.debug('config' +conf);
        system.debug('hi'+ basket1);
        inputMap.put('GetBasket',basket1.id );
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
            returnMap = RemainingamountdetailsHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('GetBasket'));        
    }
    
    @istest
    static  void BdsresponceRecivedTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        //List<cscfga__Product_Basket__c> basket1 = new List<cscfga__Product_Basket__c>();
      cscfga__Product_Basket__c  basket1 = [select id from cscfga__Product_Basket__c];
        
        Orchestration_Technical__c orch =[select id,Field_29__c from Orchestration_Technical__c];
        orch.Field_29__c=Null;
        update orch;
        //cscfga__Product_Configuration__c conf =[select id from cscfga__Product_Configuration__c where cscfga__Product_Definition__r.product_Specification__c ='DMCAT_ProductSpecification_001211'];
        //system.debug('config' +conf);
        system.debug('hi'+ basket1);
        inputMap.put('GetBasket',basket1.id );
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
            returnMap = RemainingamountdetailsHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('GetBasket'));        
    }
    
    @istest
    static void chattermessageTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        //List<cscfga__Product_Basket__c> basket1 = new List<cscfga__Product_Basket__c>();
      cscfga__Product_Basket__c  basket1 = [select id from cscfga__Product_Basket__c];
        Orchestration_Technical__c orch =[select id,Field_24__c,Field_29__c from Orchestration_Technical__c];
        orch.Field_24__c='404';
        orch.Field_29__c='Chatter sent to User';
        update orch;
       
        //cscfga__Product_Configuration__c conf =[select id from cscfga__Product_Configuration__c where cscfga__Product_Definition__r.product_Specification__c ='DMCAT_ProductSpecification_001211'];
        //system.debug('config' +conf);
        system.debug('hi'+ basket1);
        inputMap.put('GetBasket',basket1.id );
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
            returnMap = RemainingamountdetailsHelper.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('GetBasket')); 
        
        }


}