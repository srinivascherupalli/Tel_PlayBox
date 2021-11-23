@isTest
public class C2O_ServiceTriggerTest {
    @testSetup static void testCreateAndUpdateEmployee() {
        // Enable all Change Data Capture entities for notifications.
        Test.enableChangeDataCapture();
        ManageOrderTestDataSetup.testdataSetup();
        BDSNotifyTestFactory.createBdsNotifySettings();
        Account acc = [Select Id from Account where Name = 'test Account'];
        
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.Scenario_Type__c = Label.Device_Replacement;
        insert ord;
        
        csord__Subscription__c subscrip = ProductTestFactory.buildSubscription('SubscriptionProd', acc.id, ord.Id, ordReq.id);
        insert subscrip;
        
        Contact contact = AccountTestFactory.buildContact(acc, 'Nikhil3');
        insert contact;
        
        cscrm__Address__c address = AccountTestFactory.buildAddress('ADR-00003');
        insert address;
        
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Definition', 'Plan');
        prodDef.product_Specification__c = Label.MobilitySpecCode;
        insert prodDef;
        
        cscfga__Product_Configuration__c prodConfig = ProductTestFactory.buildProductConfig(prodDef.Id);
        prodConfig.Type__c='cancel';
        insert prodConfig;
        List<csord__Service__c> lstService = new List<csord__Service__c>();
        csord__Service__c serv = ProductTestFactory.buildService('ServiceProd', ord.Id, subscrip.Id, ordReq.id);
        serv.name = 'ttt x hhh1';
        serv.Model__c = 'ttt x hhh1';
        serv.csordtelcoa__Product_Configuration__c = prodConfig.Id;
        serv.Site_Delivery_Contact__c = contact.Id;
        serv.TenancyPrimaryContact__c= contact.Id;
        serv.csord__status__c = 'Pending';
        serv.Scenario_Type__c = Label.Device_Replacement;
        serv.Delivery_Address__c = address.Id;
        serv.csordtelcoa__Service_Number__c = '3';
        lstService.add(serv);
        
        csord__Service__c serv2 = ProductTestFactory.buildService('ServiceProd2', ord.Id, subscrip.Id, ordReq.id);
        serv2.csordtelcoa__Product_Configuration__c = prodConfig.Id;
        serv2.name = 'ttt x hhh';
        serv2.Model__c = 'ttt x hhh';
        serv2.Site_Delivery_Contact__c = contact.Id;
        serv2.TenancyPrimaryContact__c= contact.Id;
        serv2.csord__status__c = 'Connected';
        serv2.Delivery_Address__c = address.Id;
        serv2.csordtelcoa__Service_Number__c = '3';
        lstService.add(serv2);
        
        insert lstService;
        
    }
    @isTest static void testCreateAndUpdate() {
        List<csord__Service__c> lstserv = [SELECT id,Name,csord__status__c,Scenario_Type__c,csord__Order__c,
                                           csord__Subscription__c FROM csord__Service__c Limit 1];
        lstserv[0].csord__status__c = 'Connected';
        Test.startTest();
        update lstserv;
        Test.stopTest();
    }
    
    @isTest static void testServiceDisconnected() {
        List<csord__Service__c> lstserv = [SELECT id,Name,csord__status__c,Scenario_Type__c,csord__Order__c,
                                           csord__Subscription__c FROM csord__Service__c Limit 1];
        lstserv[0].csord__status__c = C2O_OrderConstants.DISCONNECTED;
        Test.startTest();
        update lstserv;
        Test.stopTest();
    }
    
    @isTest static void testServiceCompletion() {
        List<csord__Service__c> lstserv = [SELECT id,Name,csord__status__c,Scenario_Type__c,csord__Order__c,
                                           csord__Subscription__c FROM csord__Service__c Limit 1];
        lstserv[0].Name = 'ttt x hhh1';
        lstserv[0].Model__c = 'ttt x hhh1';
        lstserv[0].csord__status__c = C2O_OrderConstants.PAID_OUT;
        Test.startTest();
        update lstserv;
        Test.stopTest();
    }
    
    @isTest static void testServiceReplace() {
        List<csord__Service__c> lstserv = [SELECT id,Name,csord__status__c,Scenario_Type__c,csord__Order__c,
                                           csord__Subscription__c FROM csord__Service__c Limit 2];
        lstserv[0].csord__status__c = 'Connected';
        lstserv[0].csordtelcoa__Replaced_Service__c = lstserv[1].Id;
        Test.startTest();
        update lstserv;
        Test.stopTest();
    }
    
        @isTest static void testCreateAndUpdate1() {
        List<csord__Service__c> lstserv = [SELECT id,Name,csord__status__c,Scenario_Type__c,csord__Order__c,
                                           csord__Subscription__c FROM csord__Service__c Limit 1];
        lstserv[0].csord__status__c = 'Connected';
        Test.startTest();
            BypassTrigger.isRunningTestCheck = true;
        update lstserv;
        Test.stopTest();
    }
    
        @isTest static void testCreateAndUpdate2() {
        List<csord__Service__c> lstserv = [SELECT id,Name,csord__status__c,Scenario_Type__c,csord__Order__c,
                                           csord__Subscription__c FROM csord__Service__c Limit 1];
        lstserv[0].csord__status__c = 'Connected';
        Test.startTest();
            BypassTrigger.isRunningTestCheck = false; 
        update lstserv;
        Test.stopTest();
    }
    @isTest static void testupdateAssetIdforNonSerialized() {
        List<csord__Service__c> lstserv = [SELECT id,Name,csord__status__c,Scenario_Type__c,csord__Order__c,
                                           csord__Subscription__c FROM csord__Service__c Limit 1];
        lstserv[0].csord__status__c = 'Connected';
        Test.startTest();
            BypassTrigger.isRunningTestCheck = false; 
        update lstserv;
        Test.stopTest();
    }
}