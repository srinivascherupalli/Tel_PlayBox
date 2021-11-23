@isTest
public class ReadChevronControllerTest {
    
    @testsetup
    static void dataSetup(){
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        insert acc;
        
        csord__Order_Request__c ordReq1 = ProductTestFactory.buildOrderRequest();
        insert ordReq1;
        
        Opportunity testOpp = new Opportunity();
        testOpp.Account = acc;
        testOpp.Name = 'testOpp';
        testOpp.StageName = 'Define';
        testOpp.CloseDate = System.Date.today();
        insert testOpp;
        
        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = acc.Id;
        testBasket.Name = 'CancelOrderTest';
        testBasket.cscfga__Opportunity__c = testOpp.Id;
        insert testBasket;
        
        
        
        cscfga__Product_Configuration__c testConfig1 = new cscfga__Product_Configuration__c();
        testConfig1.Name = System.Label.IP_Network;
        testConfig1.cscfga__Product_Basket__c = testBasket.Id;
        testConfig1.Type__c = 'New'; 
        insert testConfig1;
        
        cscfga__Product_Configuration__c testConfig2 = new cscfga__Product_Configuration__c();
        testConfig2.Name = System.Label.IP_Network;
        testConfig2.cscfga__Product_Basket__c = testBasket.Id;
        testConfig2.Type__c = 'Cancel'; 
        insert testConfig2;
		
		cscfga__Product_Configuration__c testConfig3 = new cscfga__Product_Configuration__c();
        testConfig3.Name = System.Label.IP_Network;
        testConfig3.cscfga__Product_Basket__c = testBasket.Id;
        testConfig3.cscfga__Root_Configuration__c = testConfig2.Id; 
		testConfig3.Type__c = 'Cancel'; 
        insert testConfig3;
        
        
        csord__Order__c ord1 = ProductTestFactory.buildOrder('TestOrderNew', acc.id, 'Created', ordReq1.id);
        ord1.csord__Order_Request__c = ordReq1.Id;
        ord1.stage__c = 'Ready for Use';
        insert ord1;
        
        csord__Order__c ord2 = ProductTestFactory.buildOrder('TestOrderNewww', acc.id, 'Created', ordReq1.id);
        ord2.csord__Order_Request__c = ordReq1.Id;
        ord2.Forecasted_Delivery_Date__c = Date.today()-1;
        ord2.Telstra_Committed_Date__c = Date.today()-1;
        ord2.stage__c = 'Ready for Use';
        ord2.csord__Primary_Order__c = ord1.Id;
        insert ord2;
        
        csord__Subscription__c subs1=new csord__Subscription__c();
        subs1.name  = 'test subscrip';
        subs1.csord__Identification__c = 'test identity';
        subs1.csord__Order__c = ord2.Id;
        subs1.Sub_status__c = 'Active';
        subs1.csord__Status__c = 'Active';
        subs1.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subs1.stage__c = 'Ready for Use';
        
        insert subs1;
        
        csord__Service__c serv1 = new csord__Service__c();
        serv1.name ='tesst service';
        serv1.csord__Identification__c  = 'test identify1';
        serv1.csordtelcoa__Service_Number__c = '3';
        serv1.csord__Subscription__c = subs1.Id;
        serv1.csord__Status__c = 'Service Created';
        serv1.csord__Order_Request__c = ordReq1.Id;
        serv1.csord__Order__c = ord2.Id;
        serv1.stage__c = 'Ready for Use';
        serv1.subStage__c = 'Product Activation And Testing';
        serv1.Forecasted_Delivery_Date__c = Date.today();
        serv1.Telstra_Committed_Date__c = Date.today();
        insert serv1;
        
        
        
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        ord.Forecasted_Delivery_Date__c = Date.today()-1;
        ord.Telstra_Committed_Date__c = Date.today()-1;
        ord.stage__c = 'Ready for Use';
        //ord.csord__Primary_Order__c = ord1.Id;
        insert ord;
        
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Order__c = ord.Id;
        subs.Sub_status__c = 'Active';
        subs.csord__Status__c = 'Active';
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subs.stage__c = 'Ready for Use';
        
        insert subs;
        
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify';
        serv.csordtelcoa__Service_Number__c = '3';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Status__c = 'Service Created';
        serv.csord__Order_Request__c = ordReq.Id;
        serv.csord__Order__c = ord.Id;
        serv.stage__c = 'Ready for Use';
        serv.subStage__c = 'Product Activation And Testing';
        serv.Forecasted_Delivery_Date__c = Date.today();
        serv.Telstra_Committed_Date__c = Date.today();
        
        insert serv;
		
		csord__Service__c servCancel = new csord__Service__c();
        servCancel.name ='tst service cancel';
        servCancel.csord__Identification__c  = 'test identify';
        servCancel.csordtelcoa__Service_Number__c = '3';
        servCancel.csord__Subscription__c = subs.Id;
        servCancel.csord__Status__c = 'Service Created';
        servCancel.csord__Order_Request__c = ordReq.Id;
        servCancel.csord__Order__c = ord.Id;
        servCancel.stage__c = 'Being Fulfilled';
        servCancel.subStage__c = 'Logical Deactivation';
        servCancel.Forecasted_Delivery_Date__c = Date.today();
        servCancel.Telstra_Committed_Date__c = Date.today();
		servCancel.csordtelcoa__Product_Configuration__c =testConfig2.Id;
        
        insert servCancel;
       
        List<Attachment> atts = new List<Attachment>();
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+serv.Id+'","specifications":[{"additionalAttributes":{"parentSpec":"1fba066a-4e7d-bb28-7bfe-495fae2b2066","ManagedRadiusProductInstanceID":"26eb46ab-e4e3-eb7b-4726-af867590d48f"},"attributes":{"parentSpec":"DMCAT_ProductSpecification_000028_Fulfilment","__targetSystem":"FULFILMENT","GlobalRoaming":"FALSE","APNtype":"Shared","RequiredPoolTypes":"Static IP Pool","CustomerFacingServiceId":"","ManagedRadiusProductInstanceID":"DMCAT_ProductSpecification_000053_Fulfilment"},"code":"DMCAT_ProductSpecification_000073_Fulfilment","description":"","endDate":"","guid":"364b883e-2759-0bf4-8adb-96c93be01ef9","instanceId":"","name":"IP Wireless_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"FULFILMENT","MulticastEnabled":"FALSE","CustomerFacingServiceId":"","CustomerPreferredName":""},"code":"DMCAT_ProductSpecification_000028_Fulfilment","description":"","endDate":"","guid":"1fba066a-4e7d-bb28-7bfe-495fae2b2066","instanceId":"","name":"IP VPN_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"parentSpec":"1fba066a-4e7d-bb28-7bfe-495fae2b2066"},"attributes":{"parentSpec":"DMCAT_ProductSpecification_000028_Fulfilment","__targetSystem":"FULFILMENT","RadiusUsers":"TRUE","AuthenticationType":"Username/Password Authentication","RADIUSServerType":"Basic Telstra Managed RADIUS"},"code":"DMCAT_ProductSpecification_000053_Fulfilment","description":"","endDate":"","guid":"26eb46ab-e4e3-eb7b-4726-af867590d48f","instanceId":"","name":"Managed Radius_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"}]}');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        insert att1;
		
		Attachment att2 = new Attachment();
        att2.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+serv.Id+'","specifications":[{"additionalAttributes":{"parentSpec":"1fba066a-4e7d-bb28-7bfe-495fae2b2066","ManagedRadiusProductInstanceID":"26eb46ab-e4e3-eb7b-4726-af867590d48f"},"attributes":{"parentSpec":"DMCAT_ProductSpecification_000028_Fulfilment","__targetSystem":"FULFILMENT","GlobalRoaming":"FALSE","APNtype":"Shared","RequiredPoolTypes":"Static IP Pool","CustomerFacingServiceId":"","ManagedRadiusProductInstanceID":"DMCAT_ProductSpecification_000053_Fulfilment"},"code":"DMCAT_ProductSpecification_000073_Fulfilment","description":"","endDate":"","guid":"364b883e-2759-0bf4-8adb-96c93be01ef9","instanceId":"","name":"IP Wireless_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"FULFILMENT","MulticastEnabled":"FALSE","CustomerFacingServiceId":"","CustomerPreferredName":""},"code":"DMCAT_ProductSpecification_000028_Fulfilment","description":"","endDate":"","guid":"1fba066a-4e7d-bb28-7bfe-495fae2b2066","instanceId":"","name":"IP VPN_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"parentSpec":"1fba066a-4e7d-bb28-7bfe-495fae2b2066"},"attributes":{"parentSpec":"DMCAT_ProductSpecification_000028_Fulfilment","__targetSystem":"FULFILMENT","RadiusUsers":"TRUE","AuthenticationType":"Username/Password Authentication","RADIUSServerType":"Basic Telstra Managed RADIUS"},"code":"DMCAT_ProductSpecification_000053_Fulfilment","description":"","endDate":"","guid":"26eb46ab-e4e3-eb7b-4726-af867590d48f","instanceId":"","name":"Managed Radius_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"}]}');
        att2.Name = 'ServiceSpecifications.json';
        att2.ParentId = servCancel.Id;
        insert att2;

        
    }
    
    @isTest
    static void testOrderStage(){
         csord__Order__c ord = [SELECT id, stage__c FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
         Test.startTest();
         String stage = ReadChevronController.getChevronData(ord.id, 'stage__c');
         String expectedString = '[{"width":"33%","val":"Received","helptext":"Received","cssClass":"visited"},{"width":"33%","val":"Being Fulfilled","helptext":"Being Fulfilled","cssClass":"visited"},{"width":"33%","val":"Closed","helptext":"Closed","cssClass":"visited"}]';
		 system.debug('stage:: '+stage);
         Test.stopTest();
         System.assertnotEquals(expectedString,null);
    }
    
    @isTest
    static void testSubscriptionStage(){
         csord__Subscription__c subs = [SELECT id, stage__c FROM csord__Subscription__c WHERE Name = 'test subs' limit 1][0];
         Test.startTest();
         String stage = ReadChevronController.getChevronData(subs.id, 'stage__c');
         String expectedString = '[{"width":"33%","val":"Received","helptext":"Received","cssClass":"visited"},{"width":"33%","val":"Being Fulfilled","helptext":"Being Fulfilled","cssClass":"visited"},{"width":"33%","val":"Closed","helptext":"Closed","cssClass":"visited"}]';
		 system.debug('stage:: '+stage);
         Test.stopTest();
         System.assertnotEquals(expectedString,null);
    }
    
    @isTest
    static void testServiceStage(){
         csord__Service__c serv = [SELECT id, stage__c FROM csord__Service__c where name = 'tst service' limit 1][0];
         Test.startTest();
        
         String stage = ReadChevronController.getChevronData(serv.id, 'stage__c');
      
         String expectedString = ' [{"width":"33%","val":"Received","helptext":"Received","cssClass":"visited"},{"width":"33%","val":"Being Fulfilled","helptext":"Being Fulfilled","cssClass":"visited"},{"width":"33%","val":"Closed","helptext":"Closed","cssClass":"visited"}]';
         Test.stopTest();
         System.assertnotEquals(expectedString,null);
    }
    
    @isTest
    static void testServiceSubStage(){
         csord__Service__c serv = [SELECT id, subStage__c FROM csord__Service__c WHERE Name = 'tst service' limit 1][0];
         Test.startTest();
         String subStage = ReadChevronController.getChevronData(serv.id, 'subStage__c');
          String expectedString = '[{"width":"33%","val":"Product Requirements Validation","helptext":"Received-- Product Requirements Validation","cssClass":"visited"},{"width":"33%","val":"Product Activation and Testing","helptext":null,"cssClass":"active"},{"width":"33%","val":"Complete","helptext":null,"cssClass":""}]';
		  system.debug('subStage:: '+subStage);
         Test.stopTest();
         System.assertnotEquals(expectedString,null);
    }
    
    @isTest
    static void testServiceCancelSubStage(){
         csord__Service__c serv = [SELECT id, subStage__c FROM csord__Service__c WHERE Name = 'tst service cancel' limit 1][0];
         Test.startTest();
         String subStage = ReadChevronController.getChevronData(serv.id, 'subStage__c');
		  system.debug('subStage:: '+subStage);
         Test.stopTest();
         System.assertnotEquals(subStage,null);
    }
    
    
}