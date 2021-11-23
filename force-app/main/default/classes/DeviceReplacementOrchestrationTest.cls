@isTest
public class DeviceReplacementOrchestrationTest {
@isTest static void createCeaseOchestrationProcessTest()
    {
        list<CSPOFA__Orchestration_Process_Template__c> orcheList = new list<CSPOFA__Orchestration_Process_Template__c>();
        String processingMode='Foreground';
        
        Account acc = new Account(Name='Test Account2',Account_Status__c='Active');
        //csord__Order__c ord2 = ProductTestService.getNewOrderForAccount(acc2);
        List<Id> orderIds = new List<Id>();
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        csord__Order__c ord2 = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        insert ord2;
        csord__Subscription__c subs = ProductTestFactory.buildSubscription('TestOrder', acc.id, ord2.id, ordReq.id);
        insert subs;
        
        orderIds.add(ord2.id);
        
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Test Product', 'Test Plan');
        insert prodDef;
        ProductTestService.createSFAssociationForProdDefinition(prodDef.id);

        //Create Product configuration
        cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(prodDef.id);
        config.cscfga__Contract_Term__c = 12;
        config.type__c = 'Cancel';
        insert config;
        subs.csordtelcoa__product_configuration__c = config.id;
        update subs;
        
        system.debug('Product Config '+config);
        
        csord__Service__c ser = ProductTestFactory.buildService('TestOrder', ord2.id, subs.id, ordReq.id);
        ser.csordtelcoa__Product_Configuration__c = config.id;
        insert ser;
        
        system.debug('Service Product Config '+ser);
        
        CSPOFA__Orchestration_Process_Template__c orchProcessTemplate2 = new CSPOFA__Orchestration_Process_Template__c();
        orchProcessTemplate2.Name = 'Subscription Cease Process';
        orchProcessTemplate2.CSPOFA__Process_Type__c = 'Cease';
        orchProcessTemplate2.CSPOFA__Processing_Mode__c = processingMode;
        
        CSPOFA__Orchestration_Process_Template__c orchProcessTemplate3 = new CSPOFA__Orchestration_Process_Template__c();
        orchProcessTemplate2.Name = 'MSISDN Reserve Process';
        orchProcessTemplate2.CSPOFA__Process_Type__c = 'Cease';
        orchProcessTemplate2.CSPOFA__Processing_Mode__c = processingMode;
        orcheList.add(orchProcessTemplate3);
        orcheList.add(orchProcessTemplate2);
        
        insert orcheList;
         list<csord__Service__c> serviceSubsList2 =  [SELECT Id, Scenario_Type__c,Name, csord__Status__c, 
                                                      csord__Order__c,csord__Subscription__c,
                                                      csord__Subscription__r.csordtelcoa__Replaced_Subscription__c,
                                                      csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.name,
                                                      csord__Subscription__r.toBeCancelled__c,
                                                      csordtelcoa__Product_Configuration__r.Type__c 
                                                      FROM csord__Service__c WHERE csord__Order__c =: ord2.Id];
        for(csord__Service__c svc: serviceSubsList2){
            svc.csord__Status__c = 'Service created';
            svc.Scenario_Type__c = Label.Device_Replacement;
        }
               
        serviceSubsList2[0].csord__Subscription__r.Name = 'User Standard Zone 4';
        
         update serviceSubsList2;
        DeviceReplacementOrchestrationProcess.isDeviceReplacementOrchestrationProcess(serviceSubsList2);
         system.assertequals(1,serviceSubsList2.size());
    }
}