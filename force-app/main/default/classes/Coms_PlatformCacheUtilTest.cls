/*************************************************************************************************************
 * @name            Coms_PlatformCacheUtilTest
 * @author          BLR\rohit.pal <rohit.pal@crmit.com>
 * @created         29 / 09 / 2021
 * @description     Description of your code
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 *              No.     Date            Author                  Description
 *              ----    ------------    --------------------    ----------------------------------------------
 * @version     1.0     2021-09-29      BLR\rohit.pal           Changes desription
 *
**************************************************************************************************************/
@isTest
public with sharing class Coms_PlatformCacheUtilTest {
    private static String correlationId;
    private static String cacheKey;

    private final static String NO_CACHE_OR_SESSION_ERROR = 'No cache or session found';
    private final static String MISSING_CORRELATION_ID_ERROR = 'No correlationId found';

    private final static String KEY = 'key';
    private final static String VALUE = 'value';
    private final static String KEY1 = 'key1';
    private final static String VALUE1 = 'value1';
    private final static String KEY2 = 'key2';
    private final static String VALUE2 = 'value2';

    @testSetup
    static void setupTestData() { 
        //create Accounts
        Test.StartTest();
        List<Account> lstOfAccount =Coms_TestDataFactory.createAccount();
        insert lstOfAccount;
        System.assertEquals(10,lstOfAccount.size());
        //create opportunities
        List<Opportunity> lstOpp=Coms_TestDataFactory.createOpportunity(lstOfAccount);
        insert lstOpp;
        System.assertEquals(10,lstOpp.size());
        //create orders
        List<csord__Order__c> lstOrder=Coms_TestDataFactory.createOrder(lstOfAccount,lstOpp);
        insert lstOrder;
        System.assertEquals(10,lstOrder.size());
        //create subscriptions
        List<csord__Subscription__c> lstSubscription=Coms_TestDataFactory.createSubscription(lstOfAccount,lstOrder);
        insert lstSubscription;
        System.assertEquals(10,lstSubscription.size());
        //create services
        List<csord__Service__c> lstServices=Coms_TestDataFactory.createServicesWithOrders(lstSubscription,lstOrder);
        insert lstServices;
        System.assertEquals(10,lstServices.size());
        //create orchestration
        List<Orchestration_Technical__c> lstOrchestration=Coms_TestDataFactory.createOrchestration(lstServices);
        insert lstOrchestration;
        System.assertEquals(10,lstOrchestration.size());
        // create Technical_Child_Attribute__c
        List<Technical_Child_Attribute__c> lsttestOrchestrationChild=Coms_TestDataFactory.createOrchestrationChild(lstOrchestration);
        insert lsttestOrchestrationChild;
        System.assertEquals(50,lsttestOrchestrationChild.size());
        //create Charge_Line_Item__c
        List<Charge_Line_Item__c> lstcli=Coms_TestDataFactory.createChargeLIneItem(lstServices);
        insert lstcli;
        System.assertEquals(10,lstcli.size());
        //create Number__c
        List<Number__c> lstnum=Coms_TestDataFactory.createNumber(lstOfAccount,lstcli);
        insert lstnum;
        System.assertEquals(10,lstnum.size());
        //create Price_Schedule_Line_Item__c
        List<Price_Schedule_Line_Item__c> lstpsli=Coms_TestDataFactory.createPSLI(lstcli);
        insert lstpsli;
        System.assertEquals(10,lstpsli.size());
        //create Discount_Line_Item__c
        List<Discount_Line_Item__c> lstdli=Coms_TestDataFactory.createDLI(lstcli);
        insert lstdli;
        System.assertEquals(10,lstdli.size());
        correlationId = '123';//GuidUtil.NewGuid();
        cacheKey = correlationId.replace('-', '');
        Test.StopTest();
        
    }
    @isTest
    static void testcreateSession() {
        Test.StartTest();
        set<String> correlationId =new set<String>();
        correlationId.add('123');//GuidUtil.NewGuid();
       // cacheKey = correlationId.replace('-', '');
        Map<String, Object> flow = new Map<String, Object>();
        csord__Order__c getRecor=[SELECT id,Name,csord__Identification__c,isMSISDNHeld__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        flow.put('123',getRecor);
        Boolean result = Coms_PlatformCacheUtil.createSession(correlationId, flow);
        Test.StopTest();
    }
    @isTest
    static void testInsertOrderSubscriptionAndServicesToCache() {
        Test.StartTest();
        csord__Order__c getRecor=[SELECT id,Name,csord__Identification__c,isMSISDNHeld__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        Coms_PlatformCacheUtil.insertOrderSubscriptionAndServicesToCache(getRecor.Id,true);
        Coms_PlatformCacheUtil.insertOrderSubscriptionAndServicesToCache(getRecor.Id,false);
        Test.StopTest();
    }
    @isTest
    static void testInsertSubscriptionToCache() {
        Test.StartTest();
        csord__Order__c getRecor=[SELECT id,Name,csord__Identification__c,isMSISDNHeld__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        Coms_PlatformCacheUtil.insertSubscriptionToCache(getRecor.Id);
        Test.StopTest();
    }

    @isTest
    static void tesgetListOfTierLineItem(){
        Test.StartTest();
        csord__Order__c getRecor=[SELECT id,Name,csord__Identification__c,isMSISDNHeld__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        List<csord__Subscription__c> getSubscription=[SELECT id FROM csord__Subscription__c WHERE Name = 'TestSubsforTest' ];
        Coms_PlatformCacheUtil.insertSubscriptionToCache(getRecor.Id);
        Coms_PlatformCacheUtil.getListOfTierLineItem(new set<id>{getSubscription.get(0).id});
        Test.StopTest();
    }
    
    @isTest
    static void tesgetListOfDiscountLineItem(){
        Test.StartTest();
        csord__Order__c getRecor=[SELECT id,Name,csord__Identification__c,isMSISDNHeld__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        List<csord__Subscription__c> getSubscription=[SELECT id FROM csord__Subscription__c WHERE Name = 'TestSubsforTest' ];
        Coms_PlatformCacheUtil.insertSubscriptionToCache(getRecor.Id);
        Coms_PlatformCacheUtil.getListOfDiscountLineItem(new set<id>{getSubscription.get(0).id});
        Test.StopTest();
    }
    @isTest
    static void tesgetListOfPriceScheduleDiscountAssocItem(){
        Test.StartTest();
        csord__Order__c getRecor=[SELECT id,Name,csord__Identification__c,isMSISDNHeld__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        List<csord__Subscription__c> getSubscription=[SELECT id FROM csord__Subscription__c WHERE Name = 'TestSubsforTest' ];
        Coms_PlatformCacheUtil.insertSubscriptionToCache(getRecor.Id);
        Coms_PlatformCacheUtil.getListOfPriceScheduleDiscountAssocItem(new set<id>{getSubscription.get(0).id});
        Test.StopTest();
    }
    
    @isTest
    static void testInsertServicesToCache() {
        Test.StartTest();
        csord__Order__c getRecor=[SELECT id,Name,csord__Identification__c,isMSISDNHeld__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        Coms_PlatformCacheUtil.insertServicesToCache(getRecor.Id);
        Test.StopTest();
    }
    @isTest
    static void testInsertOrchestrationTechnicalToCache() {
        Test.StartTest();
        csord__Order__c getRecor=[SELECT id,Name,csord__Identification__c,isMSISDNHeld__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        List<csord__Service__c> serviceId=[SELECT id FROM csord__Service__c WHERE name='tst service'];
        set<Id> lstServiceId=new set<Id>();
        for(csord__Service__c eachRecord:serviceId){
            lstServiceId.add(eachRecord.Id);
        }
        Coms_PlatformCacheUtil.insertOrchestrationTechnicalToCache(lstServiceId,getRecor.Id);
        Test.StopTest();
    }
    @isTest
    static void testInsertChargeLineItemsToCache() {
        Test.StartTest();
        csord__Order__c getRecor=[select id,Name,csord__Identification__c,isMSISDNHeld__c from csord__Order__c where name='TestOrderNameForTest' limit 1];
        Coms_PlatformCacheUtil.insertChargeLineItemsToCache(getRecor.Id);
        Test.StopTest();
    }
    @isTest
    static void testInsertPriceScheduleLineItemToCache() {
        Test.StartTest();
        csord__Order__c getRecor=[select id,Name,csord__Identification__c,isMSISDNHeld__c from csord__Order__c where name='TestOrderNameForTest' limit 1];
        Coms_PlatformCacheUtil.insertPriceScheduleLineItemToCache(getRecor.Id);
        Test.StopTest();
    }
    @isTest
    static void testInsertDiscountLineItemToCache() {
        Test.StartTest();
        csord__Order__c getRecor=[select id,Name,csord__Identification__c,isMSISDNHeld__c from csord__Order__c where name='TestOrderNameForTest' limit 1];
        Coms_PlatformCacheUtil.insertDiscountLineItemToCache(getRecor.Id);
        Test.StopTest();
    }
    @isTest
    static void testInsertTechnicalChildAttribute() {
        Test.StartTest();
        csord__Order__c getRecor=[select id,Name,csord__Identification__c,isMSISDNHeld__c from csord__Order__c where name='TestOrderNameForTest' limit 1];
        List<Orchestration_Technical__c> lstOrchestrationRecords=[select id from Orchestration_Technical__c where Field_1__c  = 'test field 1'];
        set<Id> lstOrchesId=new set<Id>();
        for(Orchestration_Technical__c eachRecord:lstOrchestrationRecords){
            lstOrchesId.add(eachRecord.Id);
        }
        Coms_PlatformCacheUtil.insertTechnicalChildAttribute(lstOrchesId,getRecor.Id);
        Test.StopTest();
    }
    @isTest
    static void testInsertServicesAndOrchestrationTechnicalToCache() {
        csord__Order__c getRecor=[SELECT id,Name,csord__Identification__c,isMSISDNHeld__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        List<csord__Service__c> serviceRecords=[SELECT id,csord__Order__c FROM csord__Service__c WHERE name='tst service'];
        Map<id,csord__Service__c> mapServicesAttachments =new Map<id,csord__Service__c>();
        for(csord__Service__c eachRecord:serviceRecords){
            mapServicesAttachments.put(eachRecord.Id,eachRecord);
            break;
        }
        Test.startTest();
        Coms_PlatformCacheUtil.insertServicesAndOrchestrationTechnicalToCache(mapServicesAttachments);
        Test.stopTest();
    }

    /****************************************Get Records from cache*******************************************************************/
    @isTest
    static void testGetCacheRecordInformation() {
        csord__Order__c getRecor=[SELECT id,Name,csord__Identification__c,isMSISDNHeld__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        Test.startTest();
        Coms_PlatformCacheUtil.getCacheRecordInformation(getRecor.Id,'csord__Order__c');
        Test.stopTest();
    }
    @isTest
    static void testGetServicesFromCache() {
        csord__Order__c getRecor=[SELECT id,Name,csord__Identification__c,isMSISDNHeld__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        List<csord__Service__c> serviceId=[SELECT id FROM csord__Service__c WHERE name='tst service'];
        set<Id> lstServiceId=new set<Id>();
        for(csord__Service__c eachRecord:serviceId){
            lstServiceId.add(eachRecord.Id);
        }
        Test.startTest();
        Coms_PlatformCacheUtil.getServicesFromCache(getRecor.Id,lstServiceId);
        Test.stopTest();
    }
    @isTest
    static void testGetListofServicesFromCache() {
        List<csord__Service__c> serviceId=[SELECT id FROM csord__Service__c WHERE name='tst service'];
        set<Id> lstServiceId=new set<Id>();
        for(csord__Service__c eachRecord:serviceId){
            lstServiceId.add(eachRecord.Id);
        }
        Test.startTest();
        Coms_PlatformCacheUtil.getListofServicesFromCache(lstServiceId);
        Test.stopTest();
    }
    @isTest
    static void testGetAllServicesFromCache() {
        List<csord__Order__c> getOrderRecords=[SELECT id,Name,csord__Identification__c,isMSISDNHeld__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        
        set<Id> lstOrderId=new set<Id>();
        for(csord__Order__c eachRecord:getOrderRecords){
            lstOrderId.add(eachRecord.Id);
        }
        Test.startTest();
        Coms_PlatformCacheUtil.getAllServicesFromCache(lstOrderId);
        Test.stopTest();
    }
    @isTest
    static void testGetTechnicalObjectFromCache() {
        csord__Order__c getRecor=[SELECT id,Name,csord__Identification__c,isMSISDNHeld__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        List<csord__Service__c> serviceId=[SELECT id FROM csord__Service__c WHERE name='tst service'];
        set<Id> lstServiceId=new set<Id>();
        for(csord__Service__c eachRecord:serviceId){
            lstServiceId.add(eachRecord.Id);
        }
        Test.StartTest();
        Coms_PlatformCacheUtil.getTechnicalObjectFromCache(getRecor.Id,lstServiceId);
        Test.StopTest();
    }


    @isTest
    static void testGetListofTechnicalObjectFromCache() {
        List<csord__Service__c> serviceId=[SELECT id FROM csord__Service__c WHERE name='tst service'];
        set<Id> lstServiceId=new set<Id>();
        for(csord__Service__c eachRecord:serviceId){
            lstServiceId.add(eachRecord.Id);
        }
        Test.StartTest();
        Coms_PlatformCacheUtil.getListofTechnicalObjectFromCache(lstServiceId);
        Test.StopTest();
    }
    @isTest
    static void testGetListOfChargeLineItem() {
        List<csord__Service__c> serviceId=[SELECT id FROM csord__Service__c WHERE name='tst service'];
        set<Id> lstServiceId=new set<Id>();
        for(csord__Service__c eachRecord:serviceId){
            lstServiceId.add(eachRecord.Id);
        }
        Test.StartTest();
        Coms_PlatformCacheUtil.getListOfChargeLineItem(lstServiceId);
        Test.StopTest();
    }
    @isTest
    static void testGetListOfSubscriptionFromCache() {
        List<csord__Service__c> serviceId=[SELECT id FROM csord__Service__c WHERE name='tst service'];
        set<Id> lstServiceId=new set<Id>();
        for(csord__Service__c eachRecord:serviceId){
            lstServiceId.add(eachRecord.Id);
        }
        Test.StartTest();
        Coms_PlatformCacheUtil.getListOfSubscriptionFromCache(lstServiceId);
        Test.StopTest();
    }
    
    @isTest
    static void testGetChargeLineItem() {
        csord__Order__c getRecor=[SELECT id,Name,csord__Identification__c,isMSISDNHeld__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        List<csord__Service__c> serviceId=[select id from csord__Service__c where name='tst service'];
                List<csord__Subscription__c> getSubscription=[SELECT id FROM csord__Subscription__c WHERE Name = 'TestSubsforTest' ];
        set<Id> lstServiceId=new set<Id>();
        for(csord__Service__c eachRecord:serviceId){
            lstServiceId.add(eachRecord.Id);
        }
        Test.StartTest();
        Coms_PlatformCacheUtil.getChargeLineItem(new set<id>{getSubscription[0].id});
        Test.StopTest();
    }
    @isTest
    static void testGetPriceScheduleLineItem() {
        csord__Order__c getRecor=[SELECT id,Name,csord__Identification__c,isMSISDNHeld__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        List<csord__Service__c> serviceId=[select id from csord__Service__c where name='tst service'];
        List<csord__Subscription__c> getSubscription=[SELECT id FROM csord__Subscription__c WHERE Name = 'TestSubsforTest' ];
        set<Id> lstServiceId=new set<Id>();
        for(csord__Service__c eachRecord:serviceId){
            lstServiceId.add(eachRecord.Id);
        }
        Test.StartTest();
        Coms_PlatformCacheUtil.getPriceScheduleLineItem(new set<id>{getSubscription[0].id});
        Test.StopTest();
    }

    @isTest
    static void testGetSubscriptionFromCache() {
        csord__Order__c getRecor=[SELECT id,Name,csord__Identification__c,isMSISDNHeld__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        List<csord__Service__c> serviceId=[SELECT id from csord__Service__c where name='tst service'];
        set<Id> lstServiceId=new set<Id>();
        for(csord__Service__c eachRecord:serviceId){
            lstServiceId.add(eachRecord.Id);
        }
        Test.StartTest();
        Coms_PlatformCacheUtil.getSubscriptionFromCache(getRecor.Id,lstServiceId);
        Test.StopTest();
    }

    /************************************** */
    @isTest
    static void testGetAllSubscriptionFromCache() {
        List<csord__Order__c> getOrderRecords=[SELECT id,Name,csord__Identification__c,isMSISDNHeld__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        
        set<Id> lstOrderId=new set<Id>();
        for(csord__Order__c eachRecord:getOrderRecords){
            lstOrderId.add(eachRecord.Id);
        }
        Test.StartTest();
        Coms_PlatformCacheUtil.getAllSubscriptionFromCache(lstOrderId);
        Test.StopTest();
    }
    @isTest
    static void testparseCacheData() {
        List<csord__Order__c> getOrderRecords=[SELECT id,Name,csord__Identification__c,isMSISDNHeld__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        Map<String, Object> mapValues=new Map<String, Object>();
        mapValues.put('correlationId','23456789');
        mapValues.put('attributes','23456789');
        Map<String, Object> mapValues1=new Map<String, Object>();
        mapValues1.put(getOrderRecords[0].id , getOrderRecords[0]);
       // Coms_PlatformCacheUtil.parseCacheData(mapValues1 , 'csord__Order__c');
    }
    @isTest
    static void testgetRecordFromDataBase() {
        List<csord__Order__c> getOrderRecords=[SELECT id,Name,csord__Identification__c,isMSISDNHeld__c FROM csord__Order__c WHERE name='TestOrderNameForTest' ];
        set<Id> lstOrderId=new set<Id>();
        for(csord__Order__c eachRecord:getOrderRecords){
            lstOrderId.add(eachRecord.Id);
        }
        Coms_PlatformCacheUtil.getRecordFromDataBase(lstOrderId,'csord__Order__c');
        List<csord__Subscription__c> getSubscription=[SELECT id FROM csord__Subscription__c WHERE Name = 'TestSubsforTest' ];
        set<Id> lstSubscripId=new set<Id>();
        for(csord__Subscription__c eachRecord:getSubscription){
            lstSubscripId.add(eachRecord.Id);
        }
        Coms_PlatformCacheUtil.getRecordFromDataBase(lstSubscripId,'csord__Subscription__c');
        List<csord__Service__c> serviceId=[SELECT id FROM csord__Service__c WHERE name='tst service'];
        set<Id> lstserviceId=new set<Id>();
        for(csord__Service__c eachRecord:serviceId){
            lstserviceId.add(eachRecord.Id);
        }
        Coms_PlatformCacheUtil.getRecordFromDataBase(lstserviceId,'csord__Service__c');
        List<Orchestration_Technical__c> orchesId=[SELECT id FROM Orchestration_Technical__c WHERE Field_1__c  = 'test field 1' ];
        set<Id> lstOrchesId=new set<Id>();
        for(Orchestration_Technical__c eachRecord:orchesId){
            lstOrchesId.add(eachRecord.Id);
        }
        Coms_PlatformCacheUtil.getRecordFromDataBase(lstOrchesId,'Orchestration_Technical__c');
        List<Charge_Line_Item__c> cliId=[SELECT id FROM Charge_Line_Item__c WHERE Name='test' ];
        set<Id> lstCLIId=new set<Id>();
        for(Charge_Line_Item__c eachRecord:cliId){
            lstCLIId.add(eachRecord.Id);
        }
        Coms_PlatformCacheUtil.getRecordFromDataBase(lstCLIId,'Charge_Line_Item__c');
        Coms_PlatformCacheUtil.getNumberListFromCache(new Set<id>{getSubscription[0].id});
    }
    @isTest
    static void testfindSObject() {
        Coms_PlatformCacheUtil.findSObject('12345678ServsdfghTO');
        Coms_PlatformCacheUtil.findSObject('12345678Subssdfghert');
        Coms_PlatformCacheUtil.findSObject('12345678srtyuhgdfghTO');
        //Coms_PlatformCacheUtil.findSObject('12345678wertyujhgf');
    }
    @isTest
    static void testGetCsordOrders() {
        
        //Orchestration_Technical__c orchesId=[SELECT id from Orchestration_Technical__c WHERE Field_1__c  = 'test field 1' limit 1];
        csord__Order__c getRecor=[SELECT id,Name,csord__Identification__c,isMSISDNHeld__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        Coms_PlatformCacheUtil.getCsordOrders(getRecor.Id);
    }
    @isTest
    static void testGetOrchestrationTechnical() {
        List<csord__Service__c> serviceId=[SELECT  id FROM csord__Service__c WHERE name='tst service'];
        set<Id> lstserviceId=new set<Id>();
        for(csord__Service__c eachRecord:serviceId){
            lstserviceId.add(eachRecord.Id);
        }
        Coms_PlatformCacheUtil.getOrchestrationTechnical(lstserviceId);
    }
    @isTest
    static void testGetTechnicalChildAttributes() {
        List<Orchestration_Technical__c> orchesId=[SELECT id FROM Orchestration_Technical__c WHERE Field_1__c  = 'test field 1' ];
        csord__Order__c getRecor=[SELECT id,Name,csord__Identification__c,isMSISDNHeld__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        List<csord__Service__c> serviceId=[SELECT  id FROM csord__Service__c WHERE name='tst service'];
        set<Id> lstOrchesId=new set<Id>();
        for(Orchestration_Technical__c eachRecord:orchesId){
            lstOrchesId.add(eachRecord.Id);
        }
        Coms_PlatformCacheUtil.getTechnicalChildAttributes(lstOrchesId);
        Coms_PlatformCacheUtil.getTechnicalChildAttributes(getRecor.id , new set<id>{serviceId[0].id});
        Coms_PlatformCacheUtil.getListOfSubscriptionFromServicesCache(new set<id>{serviceId[0].id});
    }
    @isTest
    static void testGetSubscriptions() {
        csord__Order__c getRecor=[SELECT id,Name,csord__Identification__c,isMSISDNHeld__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        
        Coms_PlatformCacheUtil.getSubscriptions(getRecor.Id);
    }
    @isTest
    static void testGetCSordServices() {
        csord__Order__c getRecor=[SELECT id,Name,csord__Identification__c,isMSISDNHeld__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        
        Coms_PlatformCacheUtil.getCSordServices(getRecor.Id);
        Coms_PlatformCacheUtil.getOrderFromCache(new set<id>{getRecor.id});
    }
    @isTest
    static void testmdtGetDynamicQueryFields() {
        
        Coms_PlatformCacheUtil.mdtGetDynamicQueryFields('csord__Order__c');
    }
    @isTest
    static void testparseCacheDataOrder() {
        Test.StartTest();
        Map<string , object> mapObject = new Map<string , object>();
        csord__Order__c getRecor=[SELECT Id,Name,CorrelationId__c,Platform_Cache_Timestamp__c,csord__Status2__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        system.debug('getRecor --- > ' + getRecor) ;
        getRecor.CorrelationId__c = getRecor.id;
        getRecor.Platform_Cache_Timestamp__c = system.now();
        //String jsonPayload = '{"a4b2N000000jCFbQAM":{"attributes":{"type":"csord__Order__c","url":"/services/data/v52.0/sobjects/csord__Order__c/a4b2N000000jCFbQAM"},"Id":"a4b2N000000jCFbQAM","Name":"Test11","CorrelationId__c":"a4b2N000000jCFbQAM","Platform_Cache_Timestamp__c":"2021-09-28T11:14:36.595+0000"}}    ';
        //mapObject.put('a4b2N000000jCFbQAM' , jsonPayload);
        mapObject.put(getRecor.Id , getRecor);
        String jsonPayload = JSON.serialize(mapObject);
        TLS_Session__c objTLSSession  =new TLS_Session__c();
        objTLSSession.Name = 'Test Info';
        objTLSSession.TLS_CorrelationId__c = getRecor.id;
        objTLSSession.TLS_PayLoad__c =jsonPayload;
        insert objTLSSession;
        Map<string , object> newMap = new Map<string , object>();
        newMap.put(objTLSSession.TLS_CorrelationId__c , objTLSSession.TLS_PayLoad__c );
        Coms_PlatformCacheUtil.parseCacheData(newMap , 'csord__Order__c');
        Test.StopTest();
    }

    @isTest
    static void testparseCacheDataSubscription() {
        Test.StartTest();
        Map<string , object> mapObject = new Map<string , object>();
        csord__Order__c getRecor=[SELECT Id,Name,CorrelationId__c,Platform_Cache_Timestamp__c,csord__Status2__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        List<csord__Subscription__c> getSubscription=[SELECT id FROM csord__Subscription__c WHERE Name = 'TestSubsforTest' ];
        system.debug('getRecor --- > ' + getRecor) ;
        getRecor.CorrelationId__c = getRecor.id;
        getRecor.Platform_Cache_Timestamp__c = system.now();
        getSubscription[0].CorrelationId__c  = getRecor.id+'Subs';
        getSubscription[0].Platform_Cache_Timestamp__c =system.now();
        //String jsonPayload = '{"a4b2N000000jCFbQAM":{"attributes":{"type":"csord__Order__c","url":"/services/data/v52.0/sobjects/csord__Order__c/a4b2N000000jCFbQAM"},"Id":"a4b2N000000jCFbQAM","Name":"Test11","CorrelationId__c":"a4b2N000000jCFbQAM","Platform_Cache_Timestamp__c":"2021-09-28T11:14:36.595+0000"}}    ';
        //mapObject.put('a4b2N000000jCFbQAM' , jsonPayload);
        mapObject.put(getSubscription[0].Id , getSubscription[0]);
        String jsonPayload = JSON.serialize(mapObject);
        TLS_Session__c objTLSSession  =new TLS_Session__c();
        objTLSSession.Name = 'Test Info';
        objTLSSession.TLS_CorrelationId__c = getSubscription[0].id;
        objTLSSession.TLS_PayLoad__c =jsonPayload;
        insert objTLSSession;
        Map<string , object> newMap = new Map<string , object>();
        newMap.put(objTLSSession.TLS_CorrelationId__c , objTLSSession.TLS_PayLoad__c );
        Coms_PlatformCacheUtil.parseCacheData(newMap , 'csord__Subscription__c');
        Test.StopTest();
    }
    @isTest
    static void testparseCacheDataServices() {
        Test.StartTest();
        Map<string , object> mapObject = new Map<string , object>();
        csord__Order__c getRecor=[SELECT Id,Name,CorrelationId__c,Platform_Cache_Timestamp__c,csord__Status2__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        List<csord__Service__c> serviceId=[SELECT  id FROM csord__Service__c WHERE name='tst service'];
        system.debug('getRecor --- > ' + getRecor) ;
        getRecor.CorrelationId__c = getRecor.id;
        getRecor.Platform_Cache_Timestamp__c = system.now();
        serviceId[0].CorrelationId__c  = getRecor.id+'Serv';
        serviceId[0].Platform_Cache_Timestamp__c =system.now();
        //String jsonPayload = '{"a4b2N000000jCFbQAM":{"attributes":{"type":"csord__Order__c","url":"/services/data/v52.0/sobjects/csord__Order__c/a4b2N000000jCFbQAM"},"Id":"a4b2N000000jCFbQAM","Name":"Test11","CorrelationId__c":"a4b2N000000jCFbQAM","Platform_Cache_Timestamp__c":"2021-09-28T11:14:36.595+0000"}}    ';
        //mapObject.put('a4b2N000000jCFbQAM' , jsonPayload);
        mapObject.put(serviceId[0].Id , serviceId[0]);
        String jsonPayload = JSON.serialize(mapObject);
        TLS_Session__c objTLSSession  =new TLS_Session__c();
        objTLSSession.Name = 'Test Info';
        objTLSSession.TLS_CorrelationId__c = serviceId[0].id;
        objTLSSession.TLS_PayLoad__c =jsonPayload;
        insert objTLSSession;
        Map<string , object> newMap = new Map<string , object>();
        newMap.put(objTLSSession.TLS_CorrelationId__c , objTLSSession.TLS_PayLoad__c );
        Coms_PlatformCacheUtil.parseCacheData(newMap , 'csord__Service__c');
        Test.StopTest();
    }
    @isTest
    static void testparseCacheDataOrchestrationTechnical() {
        Test.StartTest();
        Map<string , object> mapObject = new Map<string , object>();
        csord__Order__c getRecor=[SELECT Id,Name,CorrelationId__c,Platform_Cache_Timestamp__c,csord__Status2__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        List<csord__Service__c> serviceId=[SELECT  id FROM csord__Service__c WHERE name='tst service'];
        List<csord__Subscription__c> getSubscription=[SELECT id FROM csord__Subscription__c WHERE Name = 'TestSubsforTest' ];
        List<Orchestration_Technical__c> orchesId=[SELECT id FROM Orchestration_Technical__c WHERE Field_1__c  = 'test field 1' ];
        system.debug('getRecor --- > ' + getRecor) ;
        getRecor.CorrelationId__c = getRecor.id;
        getRecor.Platform_Cache_Timestamp__c = system.now();
        orchesId[0].CorrelationId__c  = getRecor.id+'Serv'+'OT';
        orchesId[0].Platform_Cache_Timestamp__c =system.now();
        //String jsonPayload = '{"a4b2N000000jCFbQAM":{"attributes":{"type":"csord__Order__c","url":"/services/data/v52.0/sobjects/csord__Order__c/a4b2N000000jCFbQAM"},"Id":"a4b2N000000jCFbQAM","Name":"Test11","CorrelationId__c":"a4b2N000000jCFbQAM","Platform_Cache_Timestamp__c":"2021-09-28T11:14:36.595+0000"}}    ';
        //mapObject.put('a4b2N000000jCFbQAM' , jsonPayload);
        mapObject.put(orchesId[0].Id , orchesId[0]);
        String jsonPayload = JSON.serialize(mapObject);
        TLS_Session__c objTLSSession  =new TLS_Session__c();
        objTLSSession.Name = 'Test Info';
        objTLSSession.TLS_CorrelationId__c = orchesId[0].id;
        objTLSSession.TLS_PayLoad__c =jsonPayload;
        insert objTLSSession;
        Map<string , object> newMap = new Map<string , object>();
        newMap.put(objTLSSession.TLS_CorrelationId__c , objTLSSession.TLS_PayLoad__c );
        Coms_PlatformCacheUtil.parseCacheData(newMap , 'Orchestration_Technical__c');
        Test.StopTest();
    }
    @isTest
    static void testparseCacheDataTechnicalChildAttribute() {
        Test.StartTest();
        Map<string , object> mapObject = new Map<string , object>();
        csord__Order__c getRecor=[SELECT Id,Name,CorrelationId__c,Platform_Cache_Timestamp__c,csord__Status2__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        List<csord__Service__c> serviceId=[SELECT  id FROM csord__Service__c WHERE name='tst service'];
        List<csord__Subscription__c> getSubscription=[SELECT id FROM csord__Subscription__c WHERE Name = 'TestSubsforTest' ];
        List<Orchestration_Technical__c> orchesId=[SELECT id FROM Orchestration_Technical__c WHERE Field_1__c  = 'test field 1' ];
        system.debug('getRecor --- > ' + getRecor) ;
        getRecor.CorrelationId__c = getRecor.id;
        orchesId[0].CorrelationId__c  = getRecor.id+'Serv'+'OT';
        orchesId[0].Platform_Cache_Timestamp__c =system.now();
        getRecor.Platform_Cache_Timestamp__c = system.now();
        getSubscription[0].CorrelationId__c  = getRecor.id+'Subs';
        getSubscription[0].Platform_Cache_Timestamp__c =system.now();
        //String jsonPayload = '{"a4b2N000000jCFbQAM":{"attributes":{"type":"csord__Order__c","url":"/services/data/v52.0/sobjects/csord__Order__c/a4b2N000000jCFbQAM"},"Id":"a4b2N000000jCFbQAM","Name":"Test11","CorrelationId__c":"a4b2N000000jCFbQAM","Platform_Cache_Timestamp__c":"2021-09-28T11:14:36.595+0000"}}    ';
        //mapObject.put('a4b2N000000jCFbQAM' , jsonPayload);
        Technical_Child_Attribute__c objTechnicalChildAttribute = new Technical_Child_Attribute__c ();
        objTechnicalChildAttribute.put('CorrelationId__c' , '345678');
        objTechnicalChildAttribute.put('Orchestration_Technical__c' , orchesId[0].id);
        objTechnicalChildAttribute.put('Complex_Attribute_Schema_Id__c' , '345678');
        objTechnicalChildAttribute.put('Field_1__c' ,'Test 1');
        objTechnicalChildAttribute.put('Field_5__c' , 'Test 2');
        objTechnicalChildAttribute.put('Field_3__c' , 'Test 3');
        objTechnicalChildAttribute.put('Field_2__c' , 'Test 4');
        objTechnicalChildAttribute.put('Field_4__c' , 'Test 5');
        objTechnicalChildAttribute.put('Field_6__c' , 'Test 5');
        objTechnicalChildAttribute.put('Category__c' , 'Simple Attributes');
        //objTechnicalChildAttribute.put('Name' , ((String)mapTechnicalChildAttributeInfo.get('Name')));
        objTechnicalChildAttribute.put('Platform_Cache_Timestamp__c' , system.now());
        insert objTechnicalChildAttribute;
        //getSubscription[0].csord__Order__r =getRecor;
        objTechnicalChildAttribute.Orchestration_Technical__r = orchesId[0];
        system.debug('getRecor --- > ' + getRecor) ;
        orchesId[0].CorrelationId__c = getRecor.id;
        orchesId[0].Platform_Cache_Timestamp__c = system.now();
        orchesId[0].Service__r = serviceId[0];
        //String jsonPayload = '{"a4b2N000000jCFbQAM":{"attributes":{"type":"csord__Order__c","url":"/services/data/v52.0/sobjects/csord__Order__c/a4b2N000000jCFbQAM"},"Id":"a4b2N000000jCFbQAM","Name":"Test11","CorrelationId__c":"a4b2N000000jCFbQAM","Platform_Cache_Timestamp__c":"2021-09-28T11:14:36.595+0000"}}	';
        //mapObject.put('a4b2N000000jCFbQAM' , jsonPayload);
        mapObject.put(objTechnicalChildAttribute.Id , objTechnicalChildAttribute);
        String jsonPayload = JSON.serialize(mapObject);
        TLS_Session__c objTLSSession  =new TLS_Session__c();
        objTLSSession.Name = 'Test Info';
        objTLSSession.TLS_CorrelationId__c = objTechnicalChildAttribute.id;
        objTLSSession.TLS_PayLoad__c =jsonPayload;
        insert objTLSSession;
        Map<string , object> newMap = new Map<string , object>();
        newMap.put(objTLSSession.TLS_CorrelationId__c , objTLSSession.TLS_PayLoad__c );
        Coms_PlatformCacheUtil.parseCacheData(newMap , 'Technical_Child_Attribute__c');
        Test.StopTest();
    }
}