/*=============================================================================================================================
Class : OrchestrationProcessCreatorTest
===============================================
Sr.No.    Developer Name        Date          Story Description
1.       Shreya jaiswal         16/12/19        EDGE-125031
================================================================================*/
@isTest
private class OrchestrationProcessCreatorTest {

    static testMethod void createOchestrationProcessTest() {
        // TO DO: implement unit test.
        Account acc = new Account(Name='Test Account',Account_Status__c='Active');
        csord__Order__c ord = ProductTestService.getNewOrderForAccount(acc);
        list<CSPOFA__Orchestration_Process_Template__c> orcheList = new list<CSPOFA__Orchestration_Process_Template__c>();
        String ProcessingMode='Foreground';
       
        CSPOFA__Orchestration_Process_Template__c orchProcessTemplate = new CSPOFA__Orchestration_Process_Template__c();
        orchProcessTemplate.Name = 'Subscription Fulfilment Process';
        orchProcessTemplate.CSPOFA__Process_Type__c = 'New Provide';
        orchProcessTemplate.CSPOFA__Processing_Mode__c = ProcessingMode;
        orcheList.add(orchProcessTemplate);
        
        CSPOFA__Orchestration_Process_Template__c orchProcessTemplate1 = new CSPOFA__Orchestration_Process_Template__c();
        orchProcessTemplate1.Name = 'Service Fulfilment Process';
        orchProcessTemplate1.CSPOFA__Process_Type__c = 'New Provide';
        orchProcessTemplate1.CSPOFA__Processing_Mode__c = ProcessingMode;
        orcheList.add(orchProcessTemplate1);
        
        
        
        
        insert orcheList;
        
        system.debug('step'+ord);
        list<csord__Service__c> serviceSubsList =  [SELECT Id, Name, csord__Status__c, Scenario_Type__c,csord__Order__c,csord__Subscription__c,
                                                    csord__Subscription__r.csordtelcoa__Replaced_Subscription__c,
                                                    csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.name,
                                                    csord__Subscription__r.toBeCancelled__c FROM csord__Service__c 
                                                    WHERE csord__Order__c =: ord.Id];
        for(csord__Service__c svc: serviceSubsList){
            svc.csord__Status__c = 'Service created';
        }
               
        serviceSubsList[0].csord__Subscription__r.Name = 'User Standard Zone 4';
        
        update serviceSubsList;
        OrchestrationProcessCreator.createOchestrationProcess(serviceSubsList);
        list<CSPOFA__Orchestration_Process__c> servicesProcess = [Select Id, CSPOFA__Orchestration_Process_Template__r.Name from CSPOFA__Orchestration_Process__c where csordtelcoa__Service__c In: serviceSubsList];
        system.assert(servicesProcess!=null);
        system.assert(servicesProcess[0].CSPOFA__Orchestration_Process_Template__r.Name!=null);
         list<CSPOFA__Orchestration_Process__c> SubscripProcess = [Select Id,csordtelcoa__Subscription__c,CSPOFA__Orchestration_Process_Template__r.Name from CSPOFA__Orchestration_Process__c where csordtelcoa__Subscription__c =: serviceSubsList[0].csord__Subscription__c];
        system.assert(SubscripProcess!=null);
        system.assert(SubscripProcess[0].CSPOFA__Orchestration_Process_Template__r.Name!=null);
         System.assert(ord!=null);
         
        
    }
    
   @isTest static void testgetInstance()
    {
        OrchestrationProcessCreator.getInstance();
        System.assertNotEquals(null,OrchestrationProcessCreator.getInstance());
    }
    
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
         list<csord__Service__c> serviceSubsList2 =  [SELECT Id, Name, csord__Status__c, Scenario_Type__c,csord__Order__c,csord__Subscription__c,csord__Subscription__r.csordtelcoa__Replaced_Subscription__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.name,csord__Subscription__r.toBeCancelled__c,csordtelcoa__Product_Configuration__r.Type__c FROM csord__Service__c WHERE csord__Order__c =: ord2.Id];
        for(csord__Service__c svc: serviceSubsList2){
            svc.csord__Status__c = 'Service created';
            svc.Scenario_Type__c = Label.Device_Replacement;
        }
               
        serviceSubsList2[0].csord__Subscription__r.Name = 'User Standard Zone 4';
        
         update serviceSubsList2;
        if(!serviceSubsList2.isEmpty())
            OrchestrationProcessCreator.createOchestrationProcess(serviceSubsList2);
        if(!orderIds.isEmpty())
            OrchestrationProcessCreator.createMSISDNOchestrationProcess(orderIds);
         list<CSPOFA__Orchestration_Process__c> servicesProcess2 = [Select Id, CSPOFA__Orchestration_Process_Template__r.Name from CSPOFA__Orchestration_Process__c where csordtelcoa__Service__c In: serviceSubsList2];
         system.assert(servicesProcess2!=null);
    }
    //EDGE-125031
    @isTest static void testcreateOchestrationProcessTransition()
    {
        Account accTrans = new Account(Name='Test Account Transition',Account_Status__c='Active');
        csord__Order_Request__c ordReqTrans = ProductTestFactory.buildOrderRequest();
        insert ordReqTrans;
        csord__Order__c ordTrans = ProductTestFactory.buildOrder('TestTransOrder', accTrans.id, 'Created', ordReqTrans.id);
        insert ordTrans;
        csord__Subscription__c subsTrans = ProductTestFactory.buildSubscription('TestTransSub', accTrans.id, ordTrans.id, ordReqTrans.id);
        insert subsTrans;
        csord__Subscription__c subsLegacy = ProductTestFactory.buildSubscription('TestLegacySub', accTrans.id, ordTrans.id, ordReqTrans.id);
        subsLegacy.legacy_subscription__c = subsTrans.Id;
        insert subsLegacy;
        csord__Service__c serv = new csord__Service__c();
        serv.name ='test transition';
        serv.csord__Identification__c  = 'test identify6';
        serv.csordtelcoa__Service_Number__c = '6';
        serv.csord__Subscription__c = subsTrans.Id;
        serv.csord__Status__c = 'In Progress';
        insert serv;
        List<csord__Service__c> serviceList = new List<csord__Service__c>{serv};
        Test.startTest();
        OrchestrationProcessCreator.createOchestrationProcess(serviceList);
        Test.stopTest();
        System.assertEquals(0,[Select Id, csordtelcoa__Subscription__c from CSPOFA__Orchestration_Process__c where csordtelcoa__Subscription__c = :subsLegacy.Id].size());
    }
}