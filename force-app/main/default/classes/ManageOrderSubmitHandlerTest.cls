@isTest
private class ManageOrderSubmitHandlerTest {
  
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
        insert acc;

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
    
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        csord__Order__c ord = new csord__Order__c();
        ord.csord__Identification__c = 'test identification';
        ord.csord__Account__c = acc.id;
        ord.csord__Order_Type__c = 'test order' ;
        ord.csord__Status2__c = 'In Progress';
        ord.csord__Order_Request__c = ordReq.Id;
        insert ord;

        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify';
        serv.csord__Subscription__c  = subs.id;
        serv.csord__Order__c = ord.id;
        serv.csordtelcoa__Service_Number__c = '3';
        insert serv;

        List<Attachment> atts = new List<Attachment>();
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"30a0f36c-b496-185e-6330-c7a9c317d22c","productConfigurationId":"a0b0Y000001oXmtQAE","name":"CWPSpec","instanceId":"1234","guid":"3072dad2-5546-eb71-8e13-bd04b7f9824a","endDate":"","description":"CWP CFS Specification","code":"CWPSpec01","attributes":{"Zone":"Zone 3","TotalMRC":1500,"Seat":5,"complexIPAccess":[{"attributes":{"complexAttrPort":8080,"complexAttrTech":"Fibre"},"productConfigurationId":"a0b0Y000001oXmyQAE"},{"attributes":{"complexAttrPort":9090,"complexAttrTech":"Ethernet"},"productConfigurationId":"a0b0Y000001oXn3QAE"}],"constantName":"contantValue"}},{"version":"1","status":"Created","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXmyQAE","name":"IPAccessSpec","instanceId":"3456","guid":"3df57fcf-7c28-c50a-140b-0d21e80714e7","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"Port":8080,"Technology":"Fibre","constantAttr":"constantValue"}},{"version":"1","status":"Created","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXn3QAE","name":"IPAccessSpec","instanceId":"6789","guid":"495bbebb-5166-6dce-24cd-648084f6241c","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"Port":9090,"Technology":"Ethernet","constantAttr":"constantValue"}}],"serviceId":"a1B0Y000001EnjrUAC","legacyAttributes":[]}');
        //att1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"30a0f36c-b496-185e-6330-c7a9c317d22c","productConfigurationId":"a0b0Y000001oXmtQAE","name":"Telstra Fibre","instanceId":"1234","guid":"3072dad2-5546-eb71-8e13-bd04b7f9824a","endDate":"","description":"","code":"PS_000027","attributes":{"PS_000027_feasibilityNumber":22,"Appointment_EndDateTime":null,"Appointment_StartDateTime":null,"Appointment_Category":null,"Appointment_ID":null,"parentSpec":"PS_000028"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXmyQAE","name":"Port","instanceId":"","guid":"085d571e-c9dc-86f9-d25a-816ec4a7cb8b","endDate":"","description":"","code":"PS_000030","attributes":{"parentSpec":"PS_000028"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"901e7c04-7568-4bdb-99cb-d65a141da925","productConfigurationId":"a3T2O0000002CCjUAM","name":"Unified Communication Site","instanceId":"","guid":"3a338ad9-6c6e-abf5-ca34-857ad7304b86","endDate":"","description":"","code":"PS_000095","attributes":{"Service Assurance Level":"EndOfNextBusinessDay","reliesOn":"PS_000007","Customer Preferred Name":"","Customer Facing Service Id":"","childSpec":"PS_000074"},"additionalAttributes":{}}],"serviceId":"a1B0Y000001EnjrUAC","legacyAttributes":[]}');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        insert att1;

        Attachment att2 = new Attachment();
        att2.Body = Blob.valueOf('{"subscriptions":[{"subscriptionId":"a4g2O0000000O1lQAE","services":[{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"1dc6e0f9-b1f3-151d-da28-1b52c66cf55c","productConfigurationId":"a3T2O0000000yJUUAY","name":"Managed Device","instanceId":"1234","guid":"92b54a6b-1bbd-2bd5-ce7c-8a15a96f52bd","endDate":"","description":"Managed Device","code":"CFS_00005","attributes":{"ModuleInstanceId":"MODULE_INSTANCE_ID"},"additionalAttributes":{}}],"serviceId":"a4e2O0000000IGoQAM","legacyAttributes":[]}]}],"orderId":"a4b2O0000000GQPQA2"}');
        att2.Name = 'OrderSpecifications.json';
        att2.ParentId = ord.id;
        insert att2;
    }

    @isTest
    public static void executeWork_WillRunAndExecute_WhenTheParametersProvided() {
        Test.startTest();
          List<csord__Order__c> ord = [select id,Name from csord__Order__c LIMIT 1];
          List<String> orderIds = new List<String>();
          for(csord__Order__c order :ord){
              orderIds.add(order.id);
          }
          
          Test.setMock(HttpCalloutMock.class, new MockManageOrderResponseGenerator(201, 'OK', '', new Map<String, String>()));
          
            Integration_Record__c insRec = new Integration_Record__c();
            insRec.params__c = orderIds[0];
            insRec.handler__c = 'ManageOrderSumbitHandler';
            insRec.status__c = IntegrationQueueHandler.PENDING;
            insert insRec;

            ManageOrderSumbitHandler handler = new ManageOrderSumbitHandler();
            handler.executeWork(new List<String>{orderIds[0]});
        Test.stopTest();

        List<Integration_Record__c> existingRequests = [SELECT Id, params__c, status__c
                                                       FROM Integration_Record__c
                                                       WHERE handler__c = 'ManageOrderSumbitHandler' LIMIT 1];
        System.assertEquals(1, existingRequests.size());
        System.assertEquals(IntegrationQueueHandler.PENDING, existingRequests.get(0).status__c);

        List<csord__Order__c> orders = [select id,Name, csord__Status2__c from csord__Order__c where Id =:orderIds[0]];
        System.assertEquals(1, orders.size());
        System.assertEquals('In Progress', orders.get(0).csord__Status2__c);
    }


  
}