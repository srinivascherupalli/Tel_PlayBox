@isTest
public class ServiceChangeEventTriggerTest {
    @testSetup static void testCreateAndUpdateEmployee() {
        // Enable all Change Data Capture entities for notifications.
        Test.enableChangeDataCapture();
        ManageOrderTestDataSetup.testdataSetup();
        
        Account acc = [Select Id from Account where Name = 'test Account'];
        
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
        csord__Order__c primaryOrd = ProductTestFactory.buildOrder('PrimaryOrder', acc.id, 'Created', ordReq.Id);
        insert primaryOrd;
        
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
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
        serv.csordtelcoa__Product_Configuration__c = prodConfig.Id;
        serv.Site_Delivery_Contact__c = contact.Id;
        serv.TenancyPrimaryContact__c= contact.Id;
        serv.csord__status__c = 'Connected';
        serv.Scenario_Type__c = Label.Device_Replacement;
        serv.Delivery_Address__c = address.Id;
        serv.csordtelcoa__Service_Number__c = '3';
        
        insert serv;
        
    }
    
    @isTest static void testCreateAndUpdate() {
        // Enable all Change Data Capture entities for notifications.
        Test.enableChangeDataCapture();
        
        List<csord__Service__c> lstserv = [SELECT id,Name,csord__status__c,Scenario_Type__c,csord__Order__c,
                                           csord__Subscription__c 
        FROM csord__Service__c WHERE Name='ServiceProd' Limit 1];
        
        if(!lstserv.isEmpty()){
            lstserv[0].csord__status__c = 'Connected';
            lstserv[0].Scenario_Type__c = Label.Device_Replacement;
            lstserv[0].csord__Subscription__c = lstserv[0].csord__Subscription__c;
            lstserv[0].csord__Order__c = lstserv[0].csord__Order__c;
        }
        system.debug('lstserv>>>>'+lstserv);
        update lstserv;
		
        Test.getEventBus().deliver();
        List<csord__Service__c> lstService = [SELECT id from csord__Service__c WHERE csord__status__c='Connected'];
        System.assertEquals(1, lstService.size());
    }
}