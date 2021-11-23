/*************************************************************************************************************
 * @name			Coms_SobjectUtilTest
 * @author			BLR\rohit.pal <rohit.pal@crmit.com>
 * @created			05 / 10 / 2021
 * @description		Description of your code
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2021-10-05		BLR\rohit.pal			Changes desription
 *
**************************************************************************************************************/
@isTest(SeeAllData=false)
public class Coms_SobjectUtilTest {
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
        List<Tier_Line_Item__c> lsttli=Coms_TestDataFactory.createTLI(lstpsli);
        insert lsttli;
        System.assertEquals(10,lsttli.size());
        List<Price_Schedule_Discount_Association__c> lstPDSA=Coms_TestDataFactory.createPSDA(lstpsli);
        insert lstPDSA;
        System.assertEquals(10,lstPDSA.size());
        
        
        // correlationId = '123';//GuidUtil.NewGuid();
        // cacheKey = correlationId.replace('-', '');
        Test.StopTest();
    }

    /**
    * @description 
    * @author Rohit Pal | 10-05-2021 
    **/
    @isTest
    static void testgetObjectSobject() {
        Test.StartTest();
        Map<string , object> mapObject = new Map<string , object>();
        csord__Order__c getRecor=[SELECT Id,Name,CorrelationId__c,Platform_Cache_Timestamp__c,csord__Status2__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        system.debug('getRecor --- > ' + getRecor) ;
        getRecor.CorrelationId__c = getRecor.id;
        getRecor.Platform_Cache_Timestamp__c = system.now();
        //String jsonPayload = '{"a4b2N000000jCFbQAM":{"attributes":{"type":"csord__Order__c","url":"/services/data/v52.0/sobjects/csord__Order__c/a4b2N000000jCFbQAM"},"Id":"a4b2N000000jCFbQAM","Name":"Test11","CorrelationId__c":"a4b2N000000jCFbQAM","Platform_Cache_Timestamp__c":"2021-09-28T11:14:36.595+0000"}}	';
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
        Coms_SobjectUtil.getObjectSobject(newMap);
        Test.StopTest();
    }

    @isTest
    static void testgetServiceSobject() {
        Test.StartTest();
        Map<string , object> mapObject = new Map<string , object>();
        csord__Order__c getRecor=[SELECT Id,Name,CorrelationId__c,Platform_Cache_Timestamp__c,csord__Status2__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        getRecor.CorrelationId__c = getRecor.id;
        getRecor.Platform_Cache_Timestamp__c = system.now();
        List<csord__Service__c> serviceId=[SELECT  Id, Name,CorrelationId__c,Platform_Cache_Timestamp__c, 
                                                    csord__Order__c, csordtelcoa__Product_Configuration__c, 
                                                    csordtelcoa__Replaced_Service__c, toBeCancelled__c, csord__Status__c, 
                                                    csord__Order_Request__c,  csordtelcoa__Service_Number__c, 
                                                    csord__Subscription__c, csord__Subscription__r.CorrelationId__c,
                                                    csordtelcoa__Replaced_Service__r.csord__Status__c, 
                                                    csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__c, 
                                                    csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.EDMSpecToSuppressInRTB__c,
                                                    CreatedDate, csordtelcoa__Replaced_Service__r.CorrelationId__c, 
                                                    csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,
                                                    Billing_Account__r.Billing_Account_Owner__c,csord__Subscription__r.csord__Account__c,
                                                    mainCharge__r.Type__c,csordtelcoa__Product_Configuration__r.cssdm__solution_association__r.Name,
                                                    csord__Subscription__r.csordtelcoa__Subscription_Number__c,csord__Subscription__r.csord__Order__c,
                                                    csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c,changeType__c,
                                                    csord__Subscription__r.Suspension_reason__c,Scenario_Type__c,Sim_Serial_Number__c,csord__Service__c,
                                                    csord__Service__r.changeType__c,csord__Order__r.Scenario_Type__c,csord__Subscription__r.orderversion__c,
                                                    csord__Order__r.Fulfilment_Order_Version__c,csord__Order__r.Product_Basket__r.BasketType__c,
                                                    Marketable_Offer__c,csord__Subscription__r.cssdm__solution_association__c,csord__Subscription__r.Trigger_RTS__c,
                                                    csord__Order__r.name,Action_Type__c,OrderTransientDataDetails__c 
                                            FROM csord__Service__c WHERE name='tst service' limit 1];
        cscfga__Product_Configuration__c objcsordtelcoaProductConfiguration = new cscfga__Product_Configuration__c();
        objcsordtelcoaProductConfiguration.put('cscfga__Product_Definition__c' , userinfo.getUserId());
        objcsordtelcoaProductConfiguration.put('cscfga__Product_Basket__c' , 'erty');
        serviceId[0].csordtelcoa__Product_Configuration__r = objcsordtelcoaProductConfiguration;
        cscfga__Product_Definition__c objcscfgaProductDefinition = new cscfga__Product_Definition__c();
        objcscfgaProductDefinition.put('Id' , UserInfo.getUserId());
        objcscfgaProductDefinition.put('EDMSpecToSuppressInRTB__c' , 'Test');
        objcscfgaProductDefinition.put('product_Specification__c' , 'Test');
        objcsordtelcoaProductConfiguration.cscfga__Product_Definition__r = objcscfgaProductDefinition;
        serviceId[0].csordtelcoa__Product_Configuration__r = objcsordtelcoaProductConfiguration;
        serviceId[0].csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__c =objcscfgaProductDefinition.id;
        serviceId[0].csord__Order__r =getRecor;
        system.debug('getRecor --- > ' + getRecor) ;
        serviceId[0].CorrelationId__c = getRecor.id;
        serviceId[0].Platform_Cache_Timestamp__c = system.now();
        //String jsonPayload = '{"a4b2N000000jCFbQAM":{"attributes":{"type":"csord__Order__c","url":"/services/data/v52.0/sobjects/csord__Order__c/a4b2N000000jCFbQAM"},"Id":"a4b2N000000jCFbQAM","Name":"Test11","CorrelationId__c":"a4b2N000000jCFbQAM","Platform_Cache_Timestamp__c":"2021-09-28T11:14:36.595+0000"}}	';
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
        Coms_SobjectUtil.getServiceOject(newMap);
        Test.StopTest();
    }

    @isTest
    static void testgetSubscriptionSobject() {
        Test.StartTest();
        Map<string , object> mapObject = new Map<string , object>();
        csord__Order__c getRecor=[SELECT Id,Name,CorrelationId__c,Platform_Cache_Timestamp__c,csord__Status2__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        getRecor.CorrelationId__c = getRecor.id;
        getRecor.Platform_Cache_Timestamp__c = system.now();
        List<csord__Subscription__c> getSubscription=[SELECT id,Name,CorrelationId__c,csordtelcoa__Subscription_Number__c,
                                                            Platform_Cache_Timestamp__c,ConfigSpecID__c,csord__Status__c,
                                                            Parent_Subscription__c,csord__Order__c,cssdm__solution_association__c,
                                                            triggerBill_RTB__c,toBeCancelled__c,Trigger_RTS__c,Billing_Account__c,
                                                            csordtelcoa__Product_Configuration__c,MarketableOffer__c,
                                                            csord__Total_Recurring_Charges__c,csord__Total_One_Off_Charges__c,
                                                            changeType__c,Sub_Status__c,csordtelcoa__Product_Configuration__r.ConfigurationType1__c,
                                                            Is_Bill_Stopped__c,Suspension_reason__c,MarketableOffer__r.Config__c,
                                                            csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,
                                                            legacy_subscription__c,legacy_subscription__r.csord__Status__c,
                                                            csord__Order__r.name,legacy_subscription__r.MarketableOffer__c,
                                                            legacy_subscription__r.MarketableOffer__r.Config__c,legacy_subscription__r.csord__Total_Recurring_Charges__c,
                                                            legacy_subscription__r.csord__Total_One_Off_Charges__c,legacy_subscription__r.cssdm__solution_association__c,
                                                            Suspension_reason_summary__c,csord__Account__r.Customer_Status__c,csord__Account__c,
                                                            csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__c,
                                                            csordtelcoa__Product_Configuration__r.Type__c,csord__Order__r.csord__Status2__c 
                                                    FROM csord__Subscription__c WHERE Name = 'TestSubsforTest' ];
        Marketable_Offer__c objMarketableOffer = new Marketable_Offer__c();
        objMarketableOffer.put('Name' , 'Test1');
        objMarketableOffer.put('Offer_ID__c' , 'Test1');
        objMarketableOffer.put('Type__c' , 'Test1');
        objMarketableOffer.put('Config__c' , 'Test1');
        //objMarketableOffer.put('CorrelationId__c' , 'Test1');
        objMarketableOffer.put('Platform_Cache_Timestamp__c' , system.now());
        getSubscription[0].MarketableOffer__r =objMarketableOffer;
        getSubscription[0].csord__Order__r =getRecor;
        system.debug('getRecor --- > ' + getRecor) ;
        getSubscription[0].CorrelationId__c = getRecor.id;
        getSubscription[0].Platform_Cache_Timestamp__c = system.now();
        //String jsonPayload = '{"a4b2N000000jCFbQAM":{"attributes":{"type":"csord__Order__c","url":"/services/data/v52.0/sobjects/csord__Order__c/a4b2N000000jCFbQAM"},"Id":"a4b2N000000jCFbQAM","Name":"Test11","CorrelationId__c":"a4b2N000000jCFbQAM","Platform_Cache_Timestamp__c":"2021-09-28T11:14:36.595+0000"}}	';
        //mapObject.put('a4b2N000000jCFbQAM' , jsonPayload);
        mapObject.put(getSubscription[0].Id , getSubscription[0]);
        String jsonPayload = JSON.serialize(mapObject);
        TLS_Session__c objTLSSession  =new TLS_Session__c();
        objTLSSession.Name = 'Test Info';
        objTLSSession.TLS_CorrelationId__c = getSubscription[0].id;
        objTLSSession.TLS_PayLoad__c =jsonPayload;
        //objTLSSession.TLS_PayLoad__c='{a4b2N000000ktCZQAYSubs1={a4b2N000000ktCZQAYSubs1=csord__Subscription__c:{Id=a4g2N0000007QWWQA2, Name=TestSubsforTest0, csordtelcoa__Subscription_Number__c=SN-000264377, Platform_Cache_Timestamp__c=2021-10-27 07:31:27, csord__Status__c=Provisioned, csord__Order__c=a4b2N000000ktCZQAY, triggerBill_RTB__c=false, toBeCancelled__c=false, Trigger_RTS__c=false, csord__Total_Recurring_Charges__c=0.00, csord__Total_One_Off_Charges__c=0.00, Is_Bill_Stopped__c=false, CorrelationId__c=a4b2N000000ktCZQAYSubs1}}}';
        insert objTLSSession;
        Map<string , object> newMap = new Map<string , object>();
        newMap.put(objTLSSession.TLS_CorrelationId__c , objTLSSession.TLS_PayLoad__c );
        Coms_SobjectUtil.getSubscriptionSobject(newMap);
        Test.StopTest();
    }

    /**
    * @description 
    * @author Rohit Pal | 10-13-2021 
    **/
    @isTest
    static void testgetOrchestrationTechnicalOject() {
        Test.StartTest();
        Map<string , object> mapObject = new Map<string , object>();
        csord__Order__c getRecor=[SELECT Id,Name,CorrelationId__c,Platform_Cache_Timestamp__c,csord__Status2__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        getRecor.CorrelationId__c = getRecor.id;
        getRecor.Platform_Cache_Timestamp__c = system.now();
        List<Orchestration_Technical__c> orchesId=[SELECT Id,Name,CorrelationId__c,
                                                        Platform_Cache_Timestamp__c,External_Id_1__c,Service__c,	
                                                        Field_1__c,Field_3__c,Field_7__c,Field_13__c,Field_15__c,Field_10__c,
                                                        Field_4__c,Field_19__c,Field_8__c,Field_9__c,Field_6__c,Field_14__c,
                                                        Field_2__c,Field_11__c,Field_5__c,Field_12__c 
                                                    FROM Orchestration_Technical__c WHERE Field_1__c  = 'test field 1' ];

            
        //getSubscription[0].csord__Order__r =getRecor;
        system.debug('getRecor --- > ' + getRecor) ;
        orchesId[0].CorrelationId__c = getRecor.id;
        orchesId[0].Platform_Cache_Timestamp__c = system.now();
        //String jsonPayload = '{"a4b2N000000jCFbQAM":{"attributes":{"type":"csord__Order__c","url":"/services/data/v52.0/sobjects/csord__Order__c/a4b2N000000jCFbQAM"},"Id":"a4b2N000000jCFbQAM","Name":"Test11","CorrelationId__c":"a4b2N000000jCFbQAM","Platform_Cache_Timestamp__c":"2021-09-28T11:14:36.595+0000"}}	';
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
        Coms_SobjectUtil.getOrchestrationTechnicalOject(newMap);
        Test.StopTest();
    }

    /**
    * @description 
    * @author Rohit Pal | 10-13-2021 
    **/
    @isTest
    static void testgetTechnicalChildAttributeOject() {
        Test.StartTest();
        Map<string , object> mapObject = new Map<string , object>();
        csord__Order__c getRecor=[SELECT Id,Name,CorrelationId__c,Platform_Cache_Timestamp__c,csord__Status2__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        getRecor.CorrelationId__c = getRecor.id;
        getRecor.Platform_Cache_Timestamp__c = system.now();
        List<Orchestration_Technical__c> orchesId=[SELECT Id,Name,CorrelationId__c,
                                                        Platform_Cache_Timestamp__c,External_Id_1__c,Service__c,	
                                                        Field_1__c,Field_3__c,Field_7__c,Field_13__c,Field_15__c,Field_10__c,
                                                        Field_4__c,Field_19__c,Field_8__c,Field_9__c,Field_6__c,Field_14__c,
                                                        Field_2__c,Field_11__c,Field_5__c,Field_12__c 
                                                    FROM Orchestration_Technical__c WHERE Field_1__c  = 'test field 1' ];
        List<csord__Service__c> serviceId=[SELECT  Id, Name,CorrelationId__c,Platform_Cache_Timestamp__c, 
                                                    csord__Order__c, csordtelcoa__Product_Configuration__c, 
                                                    csordtelcoa__Replaced_Service__c, toBeCancelled__c, csord__Status__c, 
                                                    csord__Order_Request__c,  csordtelcoa__Service_Number__c, 
                                                    csord__Subscription__c, csord__Subscription__r.CorrelationId__c,
                                                    csordtelcoa__Replaced_Service__r.csord__Status__c, 
                                                    csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__c, 
                                                    csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.EDMSpecToSuppressInRTB__c,
                                                    CreatedDate, csordtelcoa__Replaced_Service__r.CorrelationId__c, 
                                                    csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,
                                                    Billing_Account__r.Billing_Account_Owner__c,csord__Subscription__r.csord__Account__c,
                                                    mainCharge__r.Type__c,csordtelcoa__Product_Configuration__r.cssdm__solution_association__r.Name,
                                                    csord__Subscription__r.csordtelcoa__Subscription_Number__c,csord__Subscription__r.csord__Order__c,
                                                    csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c,changeType__c,
                                                    csord__Subscription__r.Suspension_reason__c,Scenario_Type__c,Sim_Serial_Number__c,csord__Service__c,
                                                    csord__Service__r.changeType__c,csord__Order__r.Scenario_Type__c,csord__Subscription__r.orderversion__c,
                                                    csord__Order__r.Fulfilment_Order_Version__c,csord__Order__r.Product_Basket__r.BasketType__c,
                                                    Marketable_Offer__c,csord__Subscription__r.cssdm__solution_association__c,csord__Subscription__r.Trigger_RTS__c,
                                                    csord__Order__r.name,Action_Type__c,OrderTransientDataDetails__c 
                                            FROM csord__Service__c WHERE name='tst service' limit 1];
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
        Coms_SobjectUtil.getTechnicalChildAttributeOject(newMap);
        Test.StopTest();
    }

    /**
    * @description 
    * @author Rohit Pal | 10-13-2021 
    **/
    @isTest
    static void testgetBillingAccountOject() {
        Test.StartTest();
        Map<string , object> mapObject = new Map<string , object>();
        csord__Order__c getRecor=[SELECT Id,Name,CorrelationId__c,Platform_Cache_Timestamp__c,csord__Status2__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        system.debug('getRecor --- > ' + getRecor);
        Billing_Account__c objBillingAccount = new Billing_Account__c();
        objBillingAccount.put('CorrelationId__c' , UserInfo.getUserId());
        objBillingAccount.put('Id' , UserInfo.getUserId());
        //objBillingAccount.put('Name' , 'Test');
        objBillingAccount.put('Platform_Cache_Timestamp__c' , system.now());

        //String jsonPayload = '{"a4b2N000000jCFbQAM":{"attributes":{"type":"csord__Order__c","url":"/services/data/v52.0/sobjects/csord__Order__c/a4b2N000000jCFbQAM"},"Id":"a4b2N000000jCFbQAM","Name":"Test11","CorrelationId__c":"a4b2N000000jCFbQAM","Platform_Cache_Timestamp__c":"2021-09-28T11:14:36.595+0000"}}	';
        //mapObject.put('a4b2N000000jCFbQAM' , jsonPayload);
        mapObject.put(objBillingAccount.Id , objBillingAccount);
        String jsonPayload = JSON.serialize(mapObject);
        TLS_Session__c objTLSSession  =new TLS_Session__c();
        objTLSSession.Name = 'Test Info';
        objTLSSession.TLS_CorrelationId__c = objBillingAccount.id;
        objTLSSession.TLS_PayLoad__c =jsonPayload;
        insert objTLSSession;
        Map<string , object> newMap = new Map<string , object>();
        newMap.put(objTLSSession.TLS_CorrelationId__c , objTLSSession.TLS_PayLoad__c );
        Coms_SobjectUtil.getBillingAccountOject(newMap);
        Test.StopTest();
    }

    /**
    * @description 
    * @author Rohit Pal | 10-13-2021 
    **/
    @isTest
    static void testgetChargeLineItemOject() {
        Test.StartTest();
        Map<string , object> mapObject = new Map<string , object>();
        csord__Order__c getRecor=[SELECT Id,Name,CorrelationId__c,Platform_Cache_Timestamp__c,csord__Status2__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        List<csord__Service__c> serviceId=[SELECT  Id, Name,CorrelationId__c,Platform_Cache_Timestamp__c, 
                                                    csord__Order__c, csordtelcoa__Product_Configuration__c, 
                                                    csordtelcoa__Replaced_Service__c, toBeCancelled__c, csord__Status__c, 
                                                    csord__Order_Request__c,  csordtelcoa__Service_Number__c, 
                                                    csord__Subscription__c, csord__Subscription__r.CorrelationId__c,
                                                    csordtelcoa__Replaced_Service__r.csord__Status__c, 
                                                    csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__c, 
                                                    csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.EDMSpecToSuppressInRTB__c,
                                                    CreatedDate, csordtelcoa__Replaced_Service__r.CorrelationId__c, 
                                                    csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,
                                                    Billing_Account__r.Billing_Account_Owner__c,csord__Subscription__r.csord__Account__c,
                                                    mainCharge__r.Type__c,csordtelcoa__Product_Configuration__r.cssdm__solution_association__r.Name,
                                                    csord__Subscription__r.csordtelcoa__Subscription_Number__c,csord__Subscription__r.csord__Order__c,
                                                    csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c,changeType__c,
                                                    csord__Subscription__r.Suspension_reason__c,Scenario_Type__c,Sim_Serial_Number__c,csord__Service__c,
                                                    csord__Service__r.changeType__c,csord__Order__r.Scenario_Type__c,csord__Subscription__r.orderversion__c,
                                                    csord__Order__r.Fulfilment_Order_Version__c,csord__Order__r.Product_Basket__r.BasketType__c,
                                                    Marketable_Offer__c,csord__Subscription__r.cssdm__solution_association__c,csord__Subscription__r.Trigger_RTS__c,
                                                    csord__Order__r.name,Action_Type__c,OrderTransientDataDetails__c 
                                            FROM csord__Service__c WHERE name='tst service' limit 1];
        system.debug('getRecor --- > ' + getRecor);
        Charge_Line_Item__c objChargeLineItem = new Charge_Line_Item__c();
        objChargeLineItem.put('CorrelationId__c' , UserInfo.getUserId());
        objChargeLineItem.put('Id' , UserInfo.getUserId());
        objChargeLineItem.put('Platform_Cache_Timestamp__c' , system.now());
        objChargeLineItem.put('serviceId__c' , serviceId[0].id);
        objChargeLineItem.put('BusinessID__c' , UserInfo.getUserId());
        objChargeLineItem.put('chargeType__c' , 'sdfsdf');
        objChargeLineItem.serviceId__r = serviceId[0];
        //String jsonPayload = '{"a4b2N000000jCFbQAM":{"attributes":{"type":"csord__Order__c","url":"/services/data/v52.0/sobjects/csord__Order__c/a4b2N000000jCFbQAM"},"Id":"a4b2N000000jCFbQAM","Name":"Test11","CorrelationId__c":"a4b2N000000jCFbQAM","Platform_Cache_Timestamp__c":"2021-09-28T11:14:36.595+0000"}}	';
        //mapObject.put('a4b2N000000jCFbQAM' , jsonPayload);
        mapObject.put(objChargeLineItem.Id , objChargeLineItem);
        String jsonPayload = JSON.serialize(mapObject);
        TLS_Session__c objTLSSession  =new TLS_Session__c();
        objTLSSession.Name = 'Test Info';
        objTLSSession.TLS_CorrelationId__c = objChargeLineItem.id;
        objTLSSession.TLS_PayLoad__c =jsonPayload;
        insert objTLSSession;
        Map<string , object> newMap = new Map<string , object>();
        newMap.put(objTLSSession.TLS_CorrelationId__c , objTLSSession.TLS_PayLoad__c );
        Coms_SobjectUtil.getChargeLineItemOject(newMap);
        Test.StopTest();
    }
    /**
    * @description 
    * @author Rohit Pal | 10-13-2021 
    **/
    @isTest
    static void testgetDiscountLineItemOject() {
        Test.StartTest();
        Map<string , object> mapObject = new Map<string , object>();
        csord__Order__c getRecor=[SELECT Id,Name,CorrelationId__c,Platform_Cache_Timestamp__c,csord__Status2__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        system.debug('getRecor --- > ' + getRecor);
        Billing_Account__c objBillingAccount = new Billing_Account__c();
        objBillingAccount.put('CorrelationId__c' , UserInfo.getUserId());
        objBillingAccount.put('Id' , UserInfo.getUserId());
        //objBillingAccount.put('Name' , 'Test');
        objBillingAccount.put('Platform_Cache_Timestamp__c' , system.now());

        //String jsonPayload = '{"a4b2N000000jCFbQAM":{"attributes":{"type":"csord__Order__c","url":"/services/data/v52.0/sobjects/csord__Order__c/a4b2N000000jCFbQAM"},"Id":"a4b2N000000jCFbQAM","Name":"Test11","CorrelationId__c":"a4b2N000000jCFbQAM","Platform_Cache_Timestamp__c":"2021-09-28T11:14:36.595+0000"}}	';
        //mapObject.put('a4b2N000000jCFbQAM' , jsonPayload);
        mapObject.put(objBillingAccount.Id , objBillingAccount);
        String jsonPayload = JSON.serialize(mapObject);
        TLS_Session__c objTLSSession  =new TLS_Session__c();
        objTLSSession.Name = 'Test Info';
        objTLSSession.TLS_CorrelationId__c = objBillingAccount.id;
        objTLSSession.TLS_PayLoad__c =jsonPayload;
        insert objTLSSession;
        Map<string , object> newMap = new Map<string , object>();
        newMap.put(objTLSSession.TLS_CorrelationId__c , objTLSSession.TLS_PayLoad__c );
        Coms_SobjectUtil.getDiscountLineItemOject(newMap);
        Test.StopTest();
    }
    /**
    * @description 
    * @author Rohit Pal | 10-13-2021 
    **/
    @isTest
    static void testgetPriceScheduleLineItemOject() {
        Test.StartTest();
        Map<string , object> mapObject = new Map<string , object>();
        csord__Order__c getRecor=[SELECT Id,Name,CorrelationId__c,Platform_Cache_Timestamp__c,csord__Status2__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        system.debug('getRecor --- > ' + getRecor);
        Billing_Account__c objBillingAccount = new Billing_Account__c();
        objBillingAccount.put('CorrelationId__c' , UserInfo.getUserId());
        objBillingAccount.put('Id' , UserInfo.getUserId());
        //objBillingAccount.put('Name' , 'Test');
        objBillingAccount.put('Platform_Cache_Timestamp__c' , system.now());

        //String jsonPayload = '{"a4b2N000000jCFbQAM":{"attributes":{"type":"csord__Order__c","url":"/services/data/v52.0/sobjects/csord__Order__c/a4b2N000000jCFbQAM"},"Id":"a4b2N000000jCFbQAM","Name":"Test11","CorrelationId__c":"a4b2N000000jCFbQAM","Platform_Cache_Timestamp__c":"2021-09-28T11:14:36.595+0000"}}	';
        //mapObject.put('a4b2N000000jCFbQAM' , jsonPayload);
        mapObject.put(objBillingAccount.Id , objBillingAccount);
        String jsonPayload = JSON.serialize(mapObject);
        TLS_Session__c objTLSSession  =new TLS_Session__c();
        objTLSSession.Name = 'Test Info';
        objTLSSession.TLS_CorrelationId__c = objBillingAccount.id;
        objTLSSession.TLS_PayLoad__c =jsonPayload;
        insert objTLSSession;
        Map<string , object> newMap = new Map<string , object>();
        newMap.put(objTLSSession.TLS_CorrelationId__c , objTLSSession.TLS_PayLoad__c );
        Coms_SobjectUtil.getPriceScheduleLineItemOject(newMap);
        Test.StopTest();
    }
    @isTest
    static void testgetPriceScheduleDiscountAssociationOject() {
        Test.StartTest();
        Map<string , object> mapObject = new Map<string , object>();
        csord__Order__c getRecor=[SELECT Id,Name,CorrelationId__c,Platform_Cache_Timestamp__c,csord__Status2__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        system.debug('getRecor --- > ' + getRecor);
        Billing_Account__c objBillingAccount = new Billing_Account__c();
        objBillingAccount.put('CorrelationId__c' , UserInfo.getUserId());
        objBillingAccount.put('Id' , UserInfo.getUserId());
        //objBillingAccount.put('Name' , 'Test');
        objBillingAccount.put('Platform_Cache_Timestamp__c' , system.now());

        //String jsonPayload = '{"a4b2N000000jCFbQAM":{"attributes":{"type":"csord__Order__c","url":"/services/data/v52.0/sobjects/csord__Order__c/a4b2N000000jCFbQAM"},"Id":"a4b2N000000jCFbQAM","Name":"Test11","CorrelationId__c":"a4b2N000000jCFbQAM","Platform_Cache_Timestamp__c":"2021-09-28T11:14:36.595+0000"}}	';
        //mapObject.put('a4b2N000000jCFbQAM' , jsonPayload);
        mapObject.put(objBillingAccount.Id , objBillingAccount);
        String jsonPayload = JSON.serialize(mapObject);
        TLS_Session__c objTLSSession  =new TLS_Session__c();
        objTLSSession.Name = 'Test Info';
        objTLSSession.TLS_CorrelationId__c = objBillingAccount.id;
        objTLSSession.TLS_PayLoad__c =jsonPayload;
        insert objTLSSession;
        Map<string , object> newMap = new Map<string , object>();
        newMap.put(objTLSSession.TLS_CorrelationId__c , objTLSSession.TLS_PayLoad__c );
        Coms_SobjectUtil.getPriceScheduleDiscountAssocItem(newMap);
        Test.StopTest();
    }
    @isTest
    static void testgetTierLineItemOject() {
        Test.StartTest();
        Map<string , object> mapObject = new Map<string , object>();
        csord__Order__c getRecor=[SELECT Id,Name,CorrelationId__c,Platform_Cache_Timestamp__c,csord__Status2__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        system.debug('getRecor --- > ' + getRecor);
        Billing_Account__c objBillingAccount = new Billing_Account__c();
        objBillingAccount.put('CorrelationId__c' , UserInfo.getUserId());
        objBillingAccount.put('Id' , UserInfo.getUserId());
        //objBillingAccount.put('Name' , 'Test');
        objBillingAccount.put('Platform_Cache_Timestamp__c' , system.now());

        //String jsonPayload = '{"a4b2N000000jCFbQAM":{"attributes":{"type":"csord__Order__c","url":"/services/data/v52.0/sobjects/csord__Order__c/a4b2N000000jCFbQAM"},"Id":"a4b2N000000jCFbQAM","Name":"Test11","CorrelationId__c":"a4b2N000000jCFbQAM","Platform_Cache_Timestamp__c":"2021-09-28T11:14:36.595+0000"}}	';
        //mapObject.put('a4b2N000000jCFbQAM' , jsonPayload);
        mapObject.put(objBillingAccount.Id , objBillingAccount);
        String jsonPayload = JSON.serialize(mapObject);
        TLS_Session__c objTLSSession  =new TLS_Session__c();
        objTLSSession.Name = 'Test Info';
        objTLSSession.TLS_CorrelationId__c = objBillingAccount.id;
        objTLSSession.TLS_PayLoad__c =jsonPayload;
        insert objTLSSession;
        Map<string , object> newMap = new Map<string , object>();
        newMap.put(objTLSSession.TLS_CorrelationId__c , objTLSSession.TLS_PayLoad__c );
        Coms_SobjectUtil.getTierLineItem(newMap);
        Test.StopTest();
    }
    /**
    * @description 
    * @author Rohit Pal | 10-13-2021 
    **/
    @isTest
    static void testgetNumberOject() {
        Test.StartTest();
        Map<string , object> mapObject = new Map<string , object>();
        csord__Order__c getRecor=[SELECT Id,Name,CorrelationId__c,Platform_Cache_Timestamp__c,csord__Status2__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        system.debug('getRecor --- > ' + getRecor);
        Billing_Account__c objBillingAccount = new Billing_Account__c();
        objBillingAccount.put('CorrelationId__c' , UserInfo.getUserId());
        objBillingAccount.put('Id' , UserInfo.getUserId());
        //objBillingAccount.put('Name' , 'Test');
        objBillingAccount.put('Platform_Cache_Timestamp__c' , system.now());

        //String jsonPayload = '{"a4b2N000000jCFbQAM":{"attributes":{"type":"csord__Order__c","url":"/services/data/v52.0/sobjects/csord__Order__c/a4b2N000000jCFbQAM"},"Id":"a4b2N000000jCFbQAM","Name":"Test11","CorrelationId__c":"a4b2N000000jCFbQAM","Platform_Cache_Timestamp__c":"2021-09-28T11:14:36.595+0000"}}	';
        //mapObject.put('a4b2N000000jCFbQAM' , jsonPayload);
        mapObject.put(objBillingAccount.Id , objBillingAccount);
        String jsonPayload = JSON.serialize(mapObject);
        TLS_Session__c objTLSSession  =new TLS_Session__c();
        objTLSSession.Name = 'Test Info';
        objTLSSession.TLS_CorrelationId__c = objBillingAccount.id;
        objTLSSession.TLS_PayLoad__c =jsonPayload;
        insert objTLSSession;
        Map<string , object> newMap = new Map<string , object>();
        newMap.put(objTLSSession.TLS_CorrelationId__c , objTLSSession.TLS_PayLoad__c );
        Coms_SobjectUtil.getNumberOject(newMap);
        Test.StopTest();
    }
}