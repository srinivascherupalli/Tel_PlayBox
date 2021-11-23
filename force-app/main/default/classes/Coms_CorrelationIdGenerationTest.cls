/*************************************************************************************************************
 * @name			Coms_CorrelationIdGenerationTest
 * @author			BLR\rohit.pal <rohit.pal@crmit.com>
 * @created			27 / 09 / 2021
 * @description		Description of your code
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2021-09-27		BLR\rohit.pal			Changes desription
 *
**************************************************************************************************************/
@isTest(SeeAllData=false)
public  class Coms_CorrelationIdGenerationTest {
    @testSetup
    static void setupTestData() {
       //create Accounts
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

            List<Price_Schedule_Discount_Association__c> lstpsda= Coms_TestDataFactory.createPSDA(lstpsli);
            insert lstpsda;
            //create Discount_Line_Item__c
            List<Discount_Line_Item__c> lstdli=Coms_TestDataFactory.createDLI(lstcli);
            insert lstdli;
            System.assertEquals(10,lstdli.size());
    }
    @isTest
    static  void testupdateCorrelationIdOnOrderSubscriptionAndServices(){
        set<id> orderIds=new set<id>();
        User adminUser = Coms_TestDataFactory.getAdminUser();
        System.runAs(adminUser){
            Test.startTest();
            List<csord__Order__c> lstOfAllOrders=[SELECT id,Name,Platform_Cache_Timestamp__c,
            CorrelationId__c,csord__Identification__c,isMSISDNHeld__c FROM csord__Order__c WHERE name='TestOrderNameForTest'];
            System.debug('lstOfAllOrders ' + lstOfAllOrders);
            List<csord__Service__c> lstOfAllOrdersService=[select id,Name,csord__Identification__c,Platform_Cache_Timestamp__c,
            CorrelationId__c,csord__Order__c from csord__Service__c where csord__Order__c IN :lstOfAllOrders ];
            System.debug('lstOfAllOrdersService ' + lstOfAllOrdersService);
            Map<Id, Charge_Line_Item__c > mapChargeLine = new Map<Id,Charge_Line_Item__c>([SELECT Id, Name, Platform_Cache_Timestamp__c,
            CorrelationId__c,status__c,BusinessID__c FROM Charge_Line_Item__c WHERE serviceId__c IN : lstOfAllOrdersService]);
            System.debug('mapChargeLine ' + mapChargeLine);
            List<Price_Schedule_Line_Item__c> listPriceScheduleLineItem = [SELECT Id,Platform_Cache_Timestamp__c,
            CorrelationId__c,chargeInstance__c FROM Price_Schedule_Line_Item__c WHERE chargeInstance__c IN : mapChargeLine.keyset()];
            System.debug('listPriceScheduleLineItem ' + listPriceScheduleLineItem);
            List<Price_Schedule_Discount_Association__c> listPriceScheduleDiscountAssociation = [SELECT id,Name,Platform_Cache_Timestamp__c,
            CorrelationId__c FROM Price_Schedule_Discount_Association__c WHERE priceScheduleInstance__c IN : listPriceScheduleLineItem];
            System.debug('listPriceScheduleDiscountAssociation ' + listPriceScheduleDiscountAssociation);
            Map<Id, csord__Subscription__c > mapSubs = new Map<Id,csord__Subscription__c>([SELECT Id, 
                                                                                            Name,
                                                                                            Platform_Cache_Timestamp__c,
                                                                                            CorrelationId__c,
                                                                                            csord__Status__c,
                                                                                            csord__Account__c,
                                                                                            csord__Order__c,
                                                                                            csordtelcoa__Subscription_Number__c 
                                                                                    FROM csord__Subscription__c where csord__Order__c IN :lstOfAllOrders]);
            System.debug('mapSubs ' + mapSubs);
            for(csord__Order__c eachOrderRecord:lstOfAllOrders){
                orderIds.add(eachOrderRecord.Id);
            }
            Coms_CorrelationIdGeneration.updateCorrelationIdOnOrderSubscriptionAndServices(orderIds,true,true);
            Coms_CorrelationIdGeneration.updateCorrelationIdOnOrderSubscriptionAndServices(orderIds,false,true);
            Test.stopTest();
        }
        System.assertEquals(false,([select CorrelationId__c from csord__Subscription__c where name='TestSubsforTest' limit 1].CorrelationId__c).contains('subs'));
    }
    @isTest
    static  void testgetSpecificCSordServices(){
        set<id> serviceIds=new set<id>();
        User adminUser = Coms_TestDataFactory.getAdminUser();
        System.runAs(adminUser){
        Test.startTest();
            List<csord__Service__c> lstOfAllOrders=[select id,Name,csord__Identification__c,csord__Order__c from csord__Service__c where name='tst service'];
            for(csord__Service__c eachOrderRecord:lstOfAllOrders){
                serviceIds.add(eachOrderRecord.Id);
            }
            Coms_CorrelationIdGeneration.getSpecificCSordServices(serviceIds);
            Coms_CorrelationIdGeneration.getChargeLineItem(serviceIds);
            Test.stopTest();
        }
        System.assertEquals(10,[select count() from csord__Service__c where name ='tst service']);
    }
    @isTest
    static  void testupdateCorrelationIdOnNumber(){
        User adminUser = Coms_TestDataFactory.getAdminUser();
        System.runAs(adminUser){
        Test.startTest();
        Map<Id, csord__Subscription__c > mapSubs = new Map<Id,csord__Subscription__c>([SELECT Id, 
                                                                                            Name, 
                                                                                            csord__Status__c,
                                                                                            csord__Account__c,
                                                                                            csord__Order__c,
                                                                                            csordtelcoa__Subscription_Number__c 
                                                                                    FROM csord__Subscription__c WHERE csord__Status__c = 'Active']);
        
        Coms_CorrelationIdGeneration.updateCorrelationIdOnNumber(mapSubs,true);
        Coms_CorrelationIdGeneration.updateCorrelationIdOnNumber(mapSubs,false);
        Test.stopTest();
        }
        System.assertEquals(10,[select count() from Number__c where Status__c = 'Reserved']);
    }
    @isTest
    static  void testupdateCorrelationIdOnDiscountLineItem(){
        User adminUser = Coms_TestDataFactory.getAdminUser();
        System.runAs(adminUser){
            Test.startTest();
            Map<Id, Charge_Line_Item__c > mapSubs = new Map<Id,Charge_Line_Item__c>([SELECT Id, Name, status__c,BusinessID__c,CorrelationId__c FROM Charge_Line_Item__c WHERE status__c = 'new']);
            
            Coms_CorrelationIdGeneration.updateCorrelationIdOnDiscountLineItem(mapSubs,true);
            Coms_CorrelationIdGeneration.updateCorrelationIdOnDiscountLineItem(mapSubs,false);
            Test.stopTest();
        }
        System.assertEquals(false,([select CorrelationId__c from Discount_Line_Item__c where BusinessID__c='DMCAT_Discount_000945' limit 1].CorrelationId__c).contains('DLI'));
    }
    @isTest
    static  void testupdateCorrelationIdOnPriceScheduleLineItem(){
        User adminUser = Coms_TestDataFactory.getAdminUser();
        System.runAs(adminUser){
            Test.startTest();
            Map<Id, Charge_Line_Item__c > mapSubs = new Map<Id,Charge_Line_Item__c>([SELECT Id, Name, status__c,BusinessID__c,CorrelationId__c FROM Charge_Line_Item__c WHERE status__c = 'new']);
            
            Coms_CorrelationIdGeneration.updateCorrelationIdOnPriceScheduleLineItem(mapSubs,true);
            Coms_CorrelationIdGeneration.updateCorrelationIdOnPriceScheduleLineItem(mapSubs,false);
            Test.stopTest();
        }
        System.assertEquals(false,([select CorrelationId__c from Price_Schedule_Line_Item__c where status__c='new' limit 1].CorrelationId__c).contains('PSLI'));
    }
}