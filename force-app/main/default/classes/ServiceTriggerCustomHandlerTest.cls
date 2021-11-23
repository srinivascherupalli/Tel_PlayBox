@isTest
public class ServiceTriggerCustomHandlerTest {
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
                                           csord__Subscription__c 
        FROM csord__Service__c WHERE Name='ServiceProd' Limit 1];
       // BDSNotifyTestFactory.createBdsNotifySettings();
        lstserv[0].csord__status__c = 'Connected';
        Test.startTest();
        update lstserv;
        Test.stopTest();
        Set<String> setServiceIds = new Set<String>();
        /*if(!lstserv.isEmpty()){            
            setServiceIds.add(lstserv[0].Id);
        }
        if(setServiceIds.size() > 0){
            ServiceChangeEventTriggerHandler.updaterelatedrecords(setServiceIds);
        }*/
        List<csord__Order__c> lstService = [SELECT id,csord__Status2__c from csord__Order__c WHERE Id=: lstserv[0].csord__Order__c];
        System.assertEquals('Completed', lstService[0].csord__Status2__c);
    }
    @isTest static void testupdateAssetIdforNonSerialized() {       
        List<csord__Service__c> newlstserv = [SELECT id,Name,csordtelcoa__Replaced_Service__c,csord__status__c,Scenario_Type__c,csord__Order__c,
                                             csord__Subscription__c FROM csord__Service__c WHERE Name='ServiceProd2' Limit 1];       
          map<Id,csord__Service__c> mapOfService = new  map<Id,csord__Service__c>();
          for(csord__Service__c cs : newlstserv){
              mapOfService.put(cs.id,cs);
          }   
          List<Asset> assetList1 = [Select id,AssetID__c,csord__Service__c,Subscription__c,Subscription__r.Logistics_Order_Number__c
              from Asset where csord__Service__c In : mapOfService.keyset() and AssetID__c=null];
          ServiceTriggerCustomHandler.updateAssetIdforNonSerialized(mapOfService,newlstserv);       
          
      }
}