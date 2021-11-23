@isTest
private class UpdateServiceSubscriptionsFieldsTest {
    
    @isTest
    static void testUpdateServiceFields()
    {
        cscfga__Product_Basket__c testBasket = TestDataFactory.generateProductBasket();
        cscfga__Product_Definition__c testDefn = TestDataFactory.generateProductDefinition();
        cscfga__Product_Configuration__c replacedProdConf = new cscfga__Product_Configuration__c();
        replacedProdConf.cscfga__Product_Definition__c = testDefn.Id;
        replacedProdConf.cscfga__Product_Basket__c = testBasket.Id;
        replacedProdConf.Name = 'ReplacedProdConf';
        Insert ReplacedProdConf;
        
        cscfga__Product_Configuration__c nonReplacedPC = TestDataFactory.generateProductConfiguration();
        nonReplacedPC.csordtelcoa__Replaced_Product_Configuration__c = replacedProdConf.Id;
        update nonReplacedPC;
        
        csord__Service__c testService2 = new csord__Service__c();
        testService2.Name = 'testService2';
        testService2.csord__Status__c = 'Success';
        testService2.csord__Subscription__c = TestDataFactory.generateSubscription().Id;
        testService2.csord__Identification__c = 'TestValue2';
        testService2.csordtelcoa__Product_Configuration__c = nonReplacedPC.Id;
        insert testService2;
        
        csord__Service__c testService3 = new csord__Service__c();
        testService3.Name = 'testService3';
        testService3.csord__Status__c = 'Success';
        testService3.csord__Subscription__c = TestDataFactory.generateSubscription().Id;
        testService3.csord__Identification__c = 'TestValue3';
        testService3.csordtelcoa__Product_Configuration__c = replacedProdConf.Id;
        insert testService3;
        
        csord__Service__c testService = TestDataFactory.generateService();
        
        testService.csordtelcoa__Product_Configuration__c = nonReplacedPC.Id;
        testService.csordtelcoa__Replaced_Service__c = testService2.Id;
        update testService;
        List<Id> IdList = new List<Id>();
        IdList.add(testService.Id);
        IdList.add(testService2.Id);
        IdList.add(testService3.Id);
        
        Test.startTest();
            UpdateServiceSubscriptionsFields.updateServiceFields(IdList);
        Test.stopTest();
        
        System.assertEquals(testService2.Id, testService.csordtelcoa__Replaced_Service__c, 'Services should be the same');
    }
    
    @isTest
    static void testUpdateSubscriptionFields()
    {
        cscfga__Product_Basket__c testBasket = TestDataFactory.generateProductBasket();
        cscfga__Product_Definition__c testDefn = TestDataFactory.generateProductDefinition();
        cscfga__Product_Configuration__c replacedProdConf = new cscfga__Product_Configuration__c();
        replacedProdConf.cscfga__Product_Definition__c = testDefn.Id;
        replacedProdConf.cscfga__Product_Basket__c = testBasket.Id;
        replacedProdConf.Name = 'ReplacedProdConf';
        Insert ReplacedProdConf;
        
        cscfga__Product_Configuration__c nonReplacedPC = TestDataFactory.generateProductConfiguration();
        nonReplacedPC.csordtelcoa__Replaced_Product_Configuration__c = replacedProdConf.Id;
        update nonReplacedPC;
        
        csord__Subscription__c testSubscription2 = new csord__Subscription__c();
        testSubscription2.Name = 'testSubscription2';
        testSubscription2.csord__Identification__c = 'TestValue2';
        testSubscription2.csordtelcoa__Product_Configuration__c = nonReplacedPC.Id;
        insert testSubscription2;
        
        csord__Subscription__c testSubscription3 = new csord__Subscription__c();
        testSubscription3.Name = 'testSubscription3';
        testSubscription3.csord__Identification__c = 'TestValue3';
        testSubscription3.csordtelcoa__Product_Configuration__c = replacedProdConf.Id;
        insert testSubscription3;
        
        csord__Subscription__c testSubscription = TestDataFactory.generateSubscription();
        testSubscription.csordtelcoa__Product_Configuration__c = nonReplacedPC.Id;
        testSubscription.csordtelcoa__Replaced_Subscription__c = testSubscription2.Id;
        update testSubscription;
        List<Id> IdList = new List<Id>();
        IdList.add(testSubscription.Id);
        IdList.add(testSubscription2.Id);
        IdList.add(testSubscription3.Id);
        
        Test.startTest();
            UpdateServiceSubscriptionsFields.updateSubscriptionFields(IdList);
        Test.stopTest();
        
        System.assertEquals(testSubscription.csordtelcoa__Replaced_Subscription__c, testSubscription2.Id, 'test msg');
    }    

}