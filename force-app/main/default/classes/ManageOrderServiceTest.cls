@isTest
private class ManageOrderServiceTest {
    
    
    @testsetup 
    static void dataSetup(){
        
        Environment_Configurations__c ec = new Environment_Configurations__c(Custom_Logging__c = true);
        insert ec;
        
        BDS_Notify_Settings__c featureLevel = new BDS_Notify_Settings__c(name = 'Feature Level',Value__c = 'FeatureLevelShadow',Is_SI5_Offer__c  = true);
        BDS_Notify_Settings__c technicalSupport = new BDS_Notify_Settings__c(name = 'Technical Support',Value__c = 'TechnicalSupportShadow ',Is_SI5_Offer__c  = true);
        insert new List<BDS_Notify_Settings__c>{featureLevel,technicalSupport};
        
        EnvironmentVariable.put('access_token', '1234');
        EnvironmentVariable.put('okapi_base_url', 'https://cb.test.dev.telstra.com/org006/slot6');
        EnvironmentVariable.put('okapi_east_url', '/?');
        EnvironmentVariable.put('okapi_client_id', '1234');
        EnvironmentVariable.put('okapi_client_secret', '1234');
        EnvironmentVariable.put('okapi_token_url', 'https://cb.test.dev.telstra.com/org006/slot6/v1/oauth/token');
        
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        acc.Customer_Status__c='Active';
        insert acc;
        System.assertNotEquals(acc.Id, null);
        //AccountTestFactory
        cscrm__Address__c addr = AccountTestFactory.buildAddress('ADR-00001');
        insert addr;
        Contact contact = AccountTestFactory.buildContact(acc, 'Smith');
        insert contact;
        cscrm__Site__c  site = AccountTestFactory.buildSite(addr.Id, acc.Id);
        site.Primary_Contact__c = contact.Id;
        insert site;
        
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.Site__c = site.Id;
        insert subs;
        //65707: Start
        //added
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
        csord__Order__c primaryOrd = ProductTestFactory.buildOrder('PrimaryOrder', acc.id, 'Created', ordReq.Id);
        primaryOrd.Csord__Order_Type__c ='test primary order';
        insert primaryOrd;
        
        csord__Order__c ord = new csord__Order__c();
        ord.csord__Identification__c = 'test identification';
        ord.csord__Account__c = acc.id;
        ord.csord__Order_Type__c = 'test order' ;
        ord.csord__Status2__c = 'In Progress';
        //added
        ord.csord__Primary_Order__c = primaryOrd.Id;
        //
        insert ord;
        //added
        cscfga__Product_Definition__c productDef = ProductTestFactory.buildProductDefinition('TestMobProduct', 'MobPlan');
        productDef.product_Specification__c = Label.MobilitySpecCode;
        insert productDef;
        
        cscfga__Product_Configuration__c prodConfig = ProductTestFactory.buildProductConfig(productDef.Id);
        insert prodConfig;
        //
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify';
        serv.csord__Subscription__c  = subs.id;
        serv.csord__Order__c = ord.id;
        serv.csordtelcoa__Service_Number__c = '3';
        //added
        serv.Site_Delivery_Contact__c = contact.Id;
        serv.csordtelcoa__Product_Configuration__c = prodConfig.id;
        insert serv;
        //End
        List<Attachment> atts = new List<Attachment>();
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"30a0f36c-b496-185e-6330-c7a9c317d22c","productConfigurationId":"a0b0Y000001oXmtQAE","name":"CWPSpec","instanceId":"1234","guid":"3072dad2-5546-eb71-8e13-bd04b7f9824a","endDate":"","description":"CWP CFS Specification","code":"CWPSpec01","attributes":{"Zone":"Zone 3","TotalMRC":1500,"Seat":5,"complexIPAccess":[{"attributes":{"complexAttrPort":8080,"complexAttrTech":"Fibre"},"productConfigurationId":"a0b0Y000001oXmyQAE"},{"attributes":{"complexAttrPort":9090,"complexAttrTech":"Ethernet"},"productConfigurationId":"a0b0Y000001oXn3QAE"}],"constantName":"contantValue"}},{"version":"1","status":"Created","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXmyQAE","name":"IPAccessSpec","instanceId":"3456","guid":"3df57fcf-7c28-c50a-140b-0d21e80714e7","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"Port":8080,"Technology":"Fibre","constantAttr":"constantValue"}},{"version":"1","status":"Created","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXn3QAE","name":"IPAccessSpec","instanceId":"6789","guid":"495bbebb-5166-6dce-24cd-648084f6241c","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"Port":9090,"Technology":"Ethernet","constantAttr":"constantValue"}}],"serviceId":"a1B0Y000001EnjrUAC","legacyAttributes":[]}');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        insert att1;
        
        Attachment att2 = new Attachment();
        att2.Body = Blob.valueOf('{"subscriptions":[{"subscriptionId":"a4g2O0000000O1lQAE","services":[{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"1dc6e0f9-b1f3-151d-da28-1b52c66cf55c","productConfigurationId":"a3T2O0000000yJUUAY","name":"Managed Device","instanceId":"1234","guid":"92b54a6b-1bbd-2bd5-ce7c-8a15a96f52bd","endDate":"","description":"Managed Device","code":"CFS_00005","attributes":{"ModuleInstanceId":"MODULE_INSTANCE_ID"},"additionalAttributes":{}}],"serviceId":"a4e2O0000000IGoQAM","legacyAttributes":[]}]}],"orderId":"a4b2O0000000GQPQA2"}');
        att2.Name = 'OrderSpecifications.json';
        att2.ParentId = ord.id;
        insert att2;
        
        /*HighVolumeReadyToSubmitOrder__e highVol= new HighVolumeReadyToSubmitOrder__e ();
highVol.OrderID__c = 'a4b2O000000R2LRewaq';
highVol.Order_Number__c = 'ON00027643';
highVol.CorrelationID__c ='b2re-654g-4e33-vfr67';
//insert highVol;*/
    }
    
    @istest static void test_buildOrderPayload() {
        Test.startTest();
        
        List<csord__Order__c> ord = [select csord__Primary_Order__c from csord__Order__c LIMIT 1];
        List<Id> orderIds = new List<String>();
        for(csord__Order__c order :ord){
            orderIds.add(order.id);
        }
        
        List<ManageOrderDataObject.ProductOrder> ordList = new  List<ManageOrderDataObject.ProductOrder>();
        Map<Id, string> ordMap = ManageOrderService.buildManageOrderPayload(orderIds);
        
        Test.stopTest();
        System.debug(ordMap.values());
        System.assertNotEquals(null, ordMap.values());
        
    }
    
    @istest static void test_triggerFulfilment200() {
        List<csord__Order__c> ord = [select id,Name from csord__Order__c LIMIT 1];
        List<String> orderIds = new List<String>();
        for(csord__Order__c order :ord){
            orderIds.add(order.id);
        }
        System.assertEquals(ord.Size()>0, True);
        List<ManageOrderDataObject.ProductOrder> ordList = new  List<ManageOrderDataObject.ProductOrder>();
        Map<Id, string> ordMap = ManageOrderService.buildManageOrderPayload(orderIds);
        
        String jsonStr = JSON.serialize(ordList);
        System.debug(jsonStr);
        
        Test.setMock(HttpCalloutMock.class, new MockManageOrderResponseGenerator(200, 'OK', '', new Map<String, String>()));
        Test.startTest();
        ManageOrderService.triggerFulfilment(ordMap,'ManageOrderService');
        Test.stopTest();
        List<ApplicationLog__c> appLog = [SELECT Id, Name from ApplicationLog__c];
        List<csord__Order__c> ord1 = [select Id, Name, csord__Status2__c, csord__Status__c from csord__Order__c WHERE Name ='Test Order 1' LIMIT 1];
        String status;
        if(ord1.size() > 0){
            System.assert(ord1[0].csord__Status2__c == 'Order submitted');
        }
        //System.assert(appLog.size() > 0);
        
    }
    
    @istest static void test_triggerFulfilment400() {
        List<csord__Order__c> ord = [select id,Name from csord__Order__c LIMIT 1];
        List<String> orderIds = new List<String>();
        for(csord__Order__c order :ord){
            orderIds.add(order.id);
        }
        System.assertEquals(ord.Size()>0, True);
        List<ManageOrderDataObject.ProductOrder> ordList = new  List<ManageOrderDataObject.ProductOrder>();
        Map<Id, string> ordMap = ManageOrderService.buildManageOrderPayload(orderIds);
        
        String jsonStr = JSON.serialize(ordList);
        System.debug(jsonStr);
        
        Test.setMock(HttpCalloutMock.class, new MockManageOrderResponseGenerator(400, 'OK', '', new Map<String, String>()));
        Test.startTest();
        ManageOrderService.triggerFulfilment(ordMap,'ManageOrderService');
        Test.stopTest();
        List<ApplicationLog__c> appLog = [SELECT Id, Name from ApplicationLog__c];
        List<csord__Order__c> ord1 = [select Id, Name, csord__Status2__c, csord__Status__c from csord__Order__c WHERE Name ='Test Order 1' LIMIT 1];
        String status;
        if(ord1.size() > 0){
            System.assert(ord1[0].csord__Status2__c == 'Order submitted');
        }
        //System.assert(appLog.size() > 0);
        
    }
    
    @istest static void test_triggerFulfilmentException() {
        List<csord__Order__c> ord = [select id,Name from csord__Order__c LIMIT 1];
        List<String> orderIds = new List<String>();
        for(csord__Order__c order :ord){
            orderIds.add(order.id);
        }
        System.assertEquals(ord.Size()>0, True);
        List<ManageOrderDataObject.ProductOrder> ordList = new  List<ManageOrderDataObject.ProductOrder>();
        Map<Id, string> ordMap = ManageOrderService.buildManageOrderPayload(orderIds);
        
        String jsonStr = JSON.serialize(ordList);
        System.debug(jsonStr);
        
        Test.setMock(HttpCalloutMock.class, new MockManageOrderResponseGenerator(500, 'Exception', null, new Map<String, String>()));
        Test.startTest();
        ManageOrderService.triggerFulfilment(ordMap,'ManageOrderService');
        Test.stopTest();
        List<ApplicationLog__c> appLog = [SELECT Id, Name from ApplicationLog__c];
        List<csord__Order__c> ord1 = [select Id, Name, csord__Status2__c, csord__Status__c from csord__Order__c WHERE Name ='Test Order 1' LIMIT 1];
        String status;
        if(ord1.size() > 0){
            System.assert(ord1[0].csord__Status2__c == 'Order submitted');
        }
        //System.assert(appLog.size() > 0);
        
    }
    
    @istest static void test_SendOrder() {
        List<csord__Order__c> ord = [select id,Name,csord__Order_Type__c from csord__Order__c LIMIT 1];
        System.debug('ord:::::'+ord);
        List<String> orderIds = new List<String>();
        for(csord__Order__c order :ord){
            System.debug('orderType:::::'+order.csord__Order_Type__c);
            orderIds.add(order.id);
        }
        System.assertEquals(ord.Size()>0, True);
        Test.setMock(HttpCalloutMock.class, new MockManageOrderResponseGenerator(201, 'OK', '', new Map<String, String>()));
        Test.startTest();
        ManageOrderService.sendOrder(orderIds);
        Test.stopTest();
        
        List<ApplicationLog__c> appLog = [SELECT Id, Name from ApplicationLog__c];
        List<csord__Order__c> ord1 = [select Id, Name, csord__Status2__c, csord__Status__c from csord__Order__c WHERE Name ='Test Order 1' LIMIT 1];
        String status;
        if(ord1.size() > 0){
            System.assert(ord1[0].csord__Status2__c == 'Order submitted');
        }
    }
    
    @istest static void test_SendOrderError() {
        List<csord__Order__c> ord = [select id,Name from csord__Order__c LIMIT 1];
        List<String> orderIds = new List<String>();
        for(csord__Order__c order :ord){
            orderIds.add(order.id);
        }
        System.assertEquals(ord.Size()>0, True);
        Test.setMock(HttpCalloutMock.class, new MockManageOrderResponseGenerator(200, 'OK', '', new Map<String, String>()));
        Test.startTest();
        ManageOrderService.sendOrder(orderIds);
        Test.stopTest();
        List<ApplicationLog__c> appLog = [SELECT Id, Name from ApplicationLog__c];
        List<csord__Order__c> ord1 = [select Id, Name, csord__Status2__c, csord__Status__c from csord__Order__c WHERE Name ='Test Order 1' LIMIT 1];
        String status;
        if(ord1.size() > 0){
            System.assert(ord1[0].csord__Status2__c == 'Order submitted');
        }        
    }
    
    @istest static void test_logError401() {
        List<csord__Order__c> ord = [select id,Name from csord__Order__c LIMIT 1];
        List<String> orderIds = new List<String>();
        for(csord__Order__c order :ord){
            orderIds.add(order.id);
        }
        System.assertEquals(ord.Size()>0, True);
        List<ManageOrderDataObject.ProductOrder> ordList = new  List<ManageOrderDataObject.ProductOrder>();
        Map<Id, string> ordMap = ManageOrderService.buildManageOrderPayload(orderIds);
        
        String jsonStr = JSON.serialize(ordList);
        System.debug(jsonStr);
        
        Test.setMock(HttpCalloutMock.class, new MockManageOrderResponseGenerator(401, 'OK', '', new Map<String, String>()));
        Test.startTest();
        ManageOrderService.triggerFulfilment(ordMap,'ManageOrderService');
        Test.stopTest();
        List<ApplicationLog__c> appLog = [SELECT Id, Name from ApplicationLog__c];
        List<csord__Order__c> ord1 = [select Id, Name, csord__Status2__c, csord__Status__c from csord__Order__c WHERE Name ='Test Order 1' LIMIT 1];
        String status;
        if(ord1.size() > 0){
            System.assert(ord1[0].csord__Status2__c == 'Order submitted');
        }
    }
    
    @istest static void test_logError409() {
        List<csord__Order__c> ord = [select id,Name from csord__Order__c LIMIT 1];
        List<String> orderIds = new List<String>();
        for(csord__Order__c order :ord){
            orderIds.add(order.id);
        }
        System.assertEquals(ord.Size()>0, True);
        List<ManageOrderDataObject.ProductOrder> ordList = new  List<ManageOrderDataObject.ProductOrder>();
        Map<Id, string> ordMap = ManageOrderService.buildManageOrderPayload(orderIds);
        
        String jsonStr = JSON.serialize(ordList);
        System.debug(jsonStr);
        
        Test.setMock(HttpCalloutMock.class, new MockManageOrderResponseGenerator(409, 'OK', '', new Map<String, String>()));
        Test.startTest();
        ManageOrderService.triggerFulfilment(ordMap,'ManageOrderService');
        Test.stopTest();
        List<ApplicationLog__c> appLog = [SELECT Id, Name from ApplicationLog__c];
        List<csord__Order__c> ord1 = [select Id, Name, csord__Status2__c, csord__Status__c from csord__Order__c WHERE Name ='Test Order 1' LIMIT 1];
        String status;
        if(ord1.size() > 0){
            System.assert(ord1[0].csord__Status2__c == 'Order submitted');
        }
        
    }
    
    @isTest
    public Static void testSendManageOrder(){
        List<String> orderIds = new List <String>();
        List<csord__Order__c> orders = [SELECT Id from csord__Order__c];
        for(csord__Order__c ord : orders){
            orderIds.add(ord.Id);
        }
        System.assertEquals(orderIds.Size()>0, True);
        insert new EnvironmentVariable__c(Name='EnableHV',Value__c = 'true');
        
        HighVolumeReadyToSubmitOrder__e highVol= new HighVolumeReadyToSubmitOrder__e ();
        highVol.OrderID__c = 'a4b2O000000R2LRewaq';
        highVol.Order_Number__c = 'ON00027643';
        highVol.CorrelationID__c ='b2re-654g-4e33-vfr67';       
        
        ManageOrderService.sendManageOrder(orderIds);
    }
     @isTest
    public Static void testsendOrderSync(){
        List<String> orderIds = new List <String>();
        List<csord__Order__c> orders = [SELECT Id from csord__Order__c LIMIT 1];
        for(csord__Order__c ord : orders){
            orderIds.add(ord.Id);
        }
    
        ManageOrderService.sendOrderSync(orderIds);
        System.assertNotEquals(orderIds.size(), 0);
    }
    //EDGE-139661
     @isTest
    public Static void testNoFulfilmentOrderType(){
        List<String> orderIds = new List <String>();
        List<csord__Order__c> orders = [SELECT Id from csord__Order__c LIMIT 1];
        Delete [Select Id from Attachment where Name = 'ServiceSpecifications.json'];
        for(csord__Order__c ord : orders){
            orderIds.add(ord.Id);
        }
    
        ManageOrderService.sendOrderSync(orderIds);
        System.assertNotEquals(orderIds.size(), 0);
    }
}