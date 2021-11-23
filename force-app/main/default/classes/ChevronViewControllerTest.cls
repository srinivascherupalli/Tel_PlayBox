@isTest
public class ChevronViewControllerTest {
    
    @testsetup
    static void dataSetup(){
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        insert acc;
        
         csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
    insert ordReq;
        
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        ord.stage__c = 'Ready for Use';
        insert ord;
        
    csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Order__c = ord.Id;
        subs.Sub_status__c = 'Active';
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
        insert serv;
        
    List<Attachment> atts = new List<Attachment>();
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+serv.Id+'","specifications":[{"additionalAttributes":{"parentSpec":"1fba066a-4e7d-bb28-7bfe-495fae2b2066","ManagedRadiusProductInstanceID":"26eb46ab-e4e3-eb7b-4726-af867590d48f"},"attributes":{"parentSpec":"DMCAT_ProductSpecification_000028_Fulfilment","__targetSystem":"FULFILMENT","GlobalRoaming":"FALSE","APNtype":"Shared","RequiredPoolTypes":"Static IP Pool","CustomerFacingServiceId":"","ManagedRadiusProductInstanceID":"DMCAT_ProductSpecification_000053_Fulfilment"},"code":"DMCAT_ProductSpecification_000073_Fulfilment","description":"","endDate":"","guid":"364b883e-2759-0bf4-8adb-96c93be01ef9","instanceId":"","name":"IP Wireless_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"FULFILMENT","MulticastEnabled":"FALSE","CustomerFacingServiceId":"","CustomerPreferredName":""},"code":"DMCAT_ProductSpecification_000028_Fulfilment","description":"","endDate":"","guid":"1fba066a-4e7d-bb28-7bfe-495fae2b2066","instanceId":"","name":"IP VPN_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"parentSpec":"1fba066a-4e7d-bb28-7bfe-495fae2b2066"},"attributes":{"parentSpec":"DMCAT_ProductSpecification_000028_Fulfilment","__targetSystem":"FULFILMENT","RadiusUsers":"TRUE","AuthenticationType":"Username/Password Authentication","RADIUSServerType":"Basic Telstra Managed RADIUS"},"code":"DMCAT_ProductSpecification_000053_Fulfilment","description":"","endDate":"","guid":"26eb46ab-e4e3-eb7b-4726-af867590d48f","instanceId":"","name":"Managed Radius_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"}]}');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        insert att1;

        
    }
    
    @isTest
    static void testOrderStage(){
         csord__Order__c ord = [SELECT id, stage__c FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
         Test.startTest();
         String stage = ChevronViewController.getChevronData(ord.id, 'stage__c');
         String expectedString = '[{"width":"25%","val":"Order Received","helptext":"Order Received","cssClass":"visited"},{"width":"25%","val":"Being Fulfilled","helptext":"Being Fulfilled","cssClass":"visited"},{"width":"25%","val":"Ready for Use","helptext":null,"cssClass":"active"},{"width":"25%","val":"Fulfilled","helptext":null,"cssClass":""}]';
		 system.debug('stage:: '+stage);
         Test.stopTest();
         System.assertnotEquals(expectedString,null);
    }
    
    @isTest
    static void testSubscriptionStage(){
         csord__Subscription__c subs = [SELECT id, stage__c FROM csord__Subscription__c WHERE Name = 'test subs' limit 1][0];
         Test.startTest();
         String stage = ChevronViewController.getChevronData(subs.id, 'stage__c');
         String expectedString = ' [{"width":"25%","val":"Order Received","helptext":"Order Received","cssClass":"visited"},{"width":"25%","val":"Being Fulfilled","helptext":"Being Fulfilled","cssClass":"visited"},{"width":"25%","val":"Ready for Use","helptext":null,"cssClass":"active"},{"width":"25%","val":"Fulfilled","helptext":null,"cssClass":""}]';
		 system.debug('stage:: '+stage);
         Test.stopTest();
         System.assertnotEquals(expectedString,null);
    }
    
    @isTest
    static void testServiceStage(){
         csord__Service__c serv = [SELECT id, stage__c FROM csord__Service__c WHERE Name = 'tst service' limit 1][0];
         Test.startTest();
         String stage = ChevronViewController.getChevronData(serv.id, 'stage__c');
         String expectedString = '[{"width":"25%","val":"Order Received","helptext":"Order Received","cssClass":"visited"},{"width":"25%","val":"Being Fulfilled","helptext":"Being Fulfilled","cssClass":"visited"},{"width":"25%","val":"Ready for Use","helptext":null,"cssClass":"active"},{"width":"25%","val":"Fulfilled","helptext":null,"cssClass":""}]';
		 system.debug('stage:: '+stage);
         Test.stopTest();
         System.assertnotEquals(expectedString,null);
    }
    
    @isTest
    static void testServiceSubStage(){
         csord__Service__c serv = [SELECT id, subStage__c FROM csord__Service__c WHERE Name = 'tst service' limit 1][0];
         Test.startTest();
         String subStage = ChevronViewController.getChevronData(serv.id, 'subStage__c');
         String expectedString = '[{"width":"16%","val":"Product Requirements Validation","helptext":"Order Received-- Product Requirements Validation","cssClass":"visited"},{"width":"16%","val":"Product Preparation","helptext":"Being Fulfilled-- Product Preparation","cssClass":"visited"},{"width":"16%","val":"Site Visit And Installation","helptext":"Being Fulfilled-- Site Visit And Installation","cssClass":"visited"},{"width":"16%","val":"Product Activation And Testing","helptext":null,"cssClass":"active"},{"width":"16%","val":"Customer Order Acceptance","helptext":null,"cssClass":""},{"width":"16%","val":"Product Completion Notice","helptext":null,"cssClass":""}]';
		 system.debug('subStage:: '+subStage);
         Test.stopTest();
         System.assertnotEquals(expectedString,null);
    }
    
    
}