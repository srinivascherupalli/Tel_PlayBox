/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 05-20-2021
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   04-06-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
*       20-May-2021   Gokul P               EDGE-213659 
*Date: 
**/
@isTest
public with sharing class validationControllerTest {
    
    @TestSetup static void dataSetup()
    {

        BDS_Notify_Settings__c bdsNotifySettingFeatureLevel = (BDS_Notify_Settings__c) SYS_TestDataFactory.createCustomSetting(BDS_Notify_Settings__c.sObjectType);
        bdsNotifySettingFeatureLevel.Name = 'Feature Level';
        bdsNotifySettingFeatureLevel.Value__c = 'FeatureLevelShadow';
        BDS_Notify_Settings__c bdsNotifySettingTechnicalSupport = (BDS_Notify_Settings__c) SYS_TestDataFactory.createCustomSetting(BDS_Notify_Settings__c.sObjectType);
        bdsNotifySettingTechnicalSupport.Name = 'Technical Support';
        bdsNotifySettingTechnicalSupport.Value__c = 'TechnicalSupportShadow';
        
        insert new List<BDS_Notify_Settings__c>{bdsNotifySettingFeatureLevel, bdsNotifySettingTechnicalSupport};

        Account acc = new Account();
        acc.Name = 'test acc';
        acc.CIDN__c = '123476';
        acc.Account_Status__c = 'Active';
        insert acc;
        
         Account acc2 = new Account();
        acc2.Name = 'test acc2';
        acc2.CIDN__c = '22222';
        acc2.Account_Status__c = 'Active';
        insert acc2;
        
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Profile prof = [SELECT Id FROM Profile WHERE NAME = 'System Administrator'];
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  firstname = 'test',
                              lastName = 'user 1',
                              email = uniqueName + '@test' + orgId + '.org',
                              Username = uniqueName + '@test' + orgId + '.org',
                              EmailEncodingKey = 'ISO-8859-1',
                              Alias = uniqueName.substring(18, 23),
                              TimeZoneSidKey = 'America/Los_Angeles',
                              LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US',
                              ProfileId = prof.Id);
        
        insert tuser;
        
        
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Product_Domain__c = 'MOBILES';
        opp.Name = 'testopp';
        opp.StageName = 'New';
        opp.CloseDate = date.newInstance(2021,12,1);
        insert opp;
        system.debug('opp Id '+opp.Id);

        csord__Order__c ord = new csord__Order__c();
        ord.Name = 'testord';
        ord.csord__Identification__c = 'test123';
        ord.csordtelcoa__Opportunity__c = opp.Id;
        ord.csord__Status2__c = 'in Progress';
        
        insert ord;
        
         csord__Solution__c sol = new csord__Solution__c();
        sol.Name = 'testsol';
        sol.csord__Identification__c = 'testing';
        sol.csord__Account__c = acc.Id;
        sol.csord__Order__c = ord.Id;
        insert sol;

        csord__Subscription__c sub = new csord__Subscription__c();
        sub.Name = 'testsub';
        sub.cssdm__solution_association__c = sol.Id;
        sub.csord__Account__c = acc.Id;
        sub.csord__Order__c = ord.Id;
        sub.csord__Identification__c = 'testing';
        sub.Point_of_No_Return_Reached__c = false;
        sub.csordtelcoa__Subscription_Number__c = 'SN-000101578';
        sub.customerFacingServiceId__c = '1234';
        sub.csord__Status__c = 'Active';
        insert sub;
        

        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = acc.Id;
        testBasket.Name = 'ShowSubTestBasket';
        testBasket.cscfga__Opportunity__c = opp.Id;
       // testBasket.csordtelcoa__Change_Type__c = 'Upgrade';
        insert testBasket;
        
        cscfga__Product_Definition__c pd1 = new cscfga__Product_Definition__c ();
        pd1.Name = 'IP Network';
        pd1.cscfga__Description__c = 'Description';
        insert pd1;
 
        cscfga__Product_Configuration__c testConfig = new cscfga__Product_Configuration__c();
        testConfig.Name = 'IP Network';
        testConfig.cscfga__Product_Basket__c = testBasket.Id;
        insert testConfig;
        cscfga__Product_Configuration__c testConfig1 = new cscfga__Product_Configuration__c();
        testConfig.Name = ' Unified Communication Enterprise';
        testConfig.cscfga__Product_Basket__c = testBasket.Id;
        insert testConfig1;

        cscfga__Attribute__c testAttribute = new cscfga__Attribute__c();
        testAttribute.Name = 'testAttributeForTest';
        testAttribute.cscfga__Product_Configuration__c = testConfig.Id;
        insert testAttribute;

        csord__Order__c testOrder = new csord__Order__c();
        testOrder.csord__Account__c = acc.Id;
        testOrder.csordtelcoa__Opportunity__c = opp.Id;
        testOrder.Name = 'TestOrderNameForTest';
        testOrder.csord__Identification__c = 'test';
        insert testOrder;

        csordtelcoa__Orders_Subscriptions_Options__c testOso = new csordtelcoa__Orders_Subscriptions_Options__c();
        testOso.csordtelcoa__Subscription_Closed_Replaced_State__c = 'test2';
        testOso.csordtelcoa__Statuses_Not_Allowing_Change__c = 'false';
        insert testOso;

        csord__Subscription__c testSubscription = new csord__Subscription__c();
        testSubscription.Name = 'IP Network';
        testSubscription.csord__Account__c = acc.Id;
        testSubscription.TON_Barring_Status__c = 'Unbarred';
        testSubscription.csord__Order__c = testOrder.Id;
        testSubscription.csord__Identification__c = 'test';
        testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription.csord__Status__c = 'Active';
        insert testSubscription;
        
        csord__Subscription__c testSubscription1 = new csord__Subscription__c();
        testSubscription1.Name = 'Unified Communication Enterprise';
        testSubscription1.csord__Account__c = acc.Id;
        testSubscription1.TON_Barring_Status__c = 'Unbarred';
        testSubscription1.csordtelcoa__Subscription_Number__c = 'SN-000099809';
        testSubscription1.Suspension_reason_summary__c = 'testing';
        testSubscription1.csord__Order__c = testOrder.Id;
        testSubscription1.csord__Identification__c = 'test';
        //testSubscription1.csord__Status__c = 'Resume';
        testSubscription1.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription1.csord__Status__c = 'Active';
        insert testSubscription1;

        List<csord__Service__c> servList = new List<csord__Service__c>();

        csord__Service__c serv2 = new csord__Service__c();
        serv2.name ='User - Fixed Seat';
        serv2.serviceMSISDN__c = '61474703015';
        serv2.csordtelcoa__Product_Configuration__c = testConfig.id;
        serv2.csord__Identification__c  = 'testIdentify_2';
        serv2.csord__Subscription__c = testSubscription.Id;
        servList.add(serv2);
        
         csord__Service__c serv3 = new csord__Service__c();
        serv3.name ='User - Fixed Seat';
        serv3.serviceMSISDN__c = '61474703015';
        serv3.csordtelcoa__Product_Configuration__c = testConfig.id;
        serv3.csord__Identification__c  = 'testIdentify_3';
        serv3.csord__Status__c = 'Active';
        serv3.csord__Subscription__c = testSubscription1.Id;
        servList.add(serv3);
        
         TLS_Session__c session  = new TLS_Session__c();
        session.TLS_CorrelationId__c = 'ytuytw762te72';
        session.TLS_PayLoad__c = '{"validateData": "Success", "AccountId__c":"'+ acc.Id +'","AccountCIDN__c":"123456","CorrelationId__c":"008415e6-f785-66b8-811b-bc94838dde4d","ActionType__c":"SIM Replacement","Reason__c":"Sim Card (Physical SIM) faulty","ReferenceNumber__c":"TNC000000001","OwnerId__c":"' + tuser.id + '","services": [ { "Subscription_Number__c": "' + testSubscription.csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "61474703087", "Sim_Serial_Number__c": "1234567891234", "Requested_SIM_Type__c": "eSIM", "Dispatch_Required__c":"NO" }, { "Subscription_Number__c": "' +testSubscription1.csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "61474703087", "Sim_Serial_Number__c": "1234567891235", "Requested_SIM_Type__c": "SIM Card", "Dispatch_Required__c":"NO" } ]}';
        insert session;    
        
        Number__c numberobj = new Number__c();
        numberobj.Status__c='Inactive';
        numberobj.Service_Number__c='61474703015';
        insert numberobj;
        Number__c numberob = new Number__c();
        numberob.Status__c='Active';
        numberob.Service_Number__c='61474703016';
        insert numberob;
        /**
* Author: Gokul P
* EDGE-213659
* Date : 04.06.2021
*/
        cscrm__Address__c Address = new cscrm__Address__c();
        Address.Address_ID__c = '123Test';
        insert Address;

        Contact con = new Contact();
        con.LastName = 'test';
        con.AccountId = acc.Id;
        insert Con;

        Contact con2 = new Contact();
        con2.LastName = 'test2';
        con2.AccountId = acc2.Id;
        insert Con2;

        
        csord__Service__c serv9 = new csord__Service__c();
        serv9.name ='User - Fixed Seat';
        serv9.serviceMSISDN__c = '9876543129';
        serv9.csordtelcoa__Product_Configuration__c = testConfig.id;
        serv9.csord__Identification__c  = 'testIdentify_2';
        serv9.csord__Subscription__c = testSubscription.Id;
        serv9.Primary_Contact__c = con.Id;
        serv9.Delivery_Address__c = Address.id;
        servList.add(serv9);


        csord__Service__c serv10 = new csord__Service__c();
        serv10.name ='User - Fixed Seat';
        serv10.serviceMSISDN__c = '61474703087';
        serv10.csordtelcoa__Product_Configuration__c = testConfig.id;
        serv10.csord__Identification__c  = 'testIdentify_2';
        serv10.csord__Subscription__c = testSubscription.Id;
        servList.add(serv10);
        insert servList;



    }

 
/**
* Author: Shweta Khandelwal
*
* EDGE-209292
* Date : 04.06.2021
*/

    public static testMethod void validateRequestTest(){
        Test.startTest();
        Map<String,String> resultMap2 = validationController.validateRequest('','');
        Map<String,String> resultMap = validationController.validateRequest('ytuytw762te71','');
        Test.stopTest();
        System.assertEquals(resultMap.get('code'), '400');
        System.assertEquals(resultMap2.get('code'), '400');
        
    }
    
    public static testMethod void validateRequestTest2(){
        Test.startTest();
        Map<String,String> resultMap3 = validationController.validateRequest('ytuytw762te72','');
        Map<String,String> resultMap4 = validationController.validateRequest('ytuytw762te72',null);
        Map<String,String> resultMap5 = validationController.validateRequest('ytuytw762te72','ValidateData');
        Test.stopTest();
        System.assertEquals(resultMap3.get('code'), '422');
        System.assertEquals(resultMap4.get('code'), '422');
        System.assertEquals(resultMap5.get('code'), '422');
    }
 
    
    public static testMethod void validateMasterDataTest1(){
        Map<String,String> inputMap = new Map<String,String>();
        User usr = [SELECT Id,Name FROM USer LIMIT 1];
       // inputMap.put('CorrelationId__c','ytuytw762te72');
        inputMap.put('AccountId__c','123476');
        inputMap.put('ActionType__c','SIM Replacement');
        inputMap.put('Reason__c','Change from Sim Card (Physical SIM) to e-Sim');
        inputMap.put('ReferenceNumber__c','737373');
        inputMap.put('OwnerId__c',usr.Id);
        Test.startTest();
        validationController vc = new validationController();
        Map<String,String> resultMap = vc.validateMasterData(inputMap);
        //System.assertEquals(resultMap.get('code'), '422');
         System.assertEquals(resultMap.get('code'), '400');
        //system.debug('result '+JSON.deserializeUntyped(JSON.serialize(vc.validateMasterData(inputMap))));
        test.stopTest();
    }
    
    public static testMethod void validateMasterDataTest2(){
        Map<String,String> inputMap = new Map<String,String>();
        User usr = [SELECT Id,Name FROM USer LIMIT 1];
        inputMap.put('CorrelationId__c','ytuytw762te72');
        inputMap.put('AccountId__c','12347612');
        inputMap.put('ActionType__c','SIM Replacement');
        inputMap.put('Reason__c','testing');
        inputMap.put('ReferenceNumber__c','');
        inputMap.put('OwnerId__c','dhbdh778282h8');
        Test.startTest();
        validationController vc = new validationController();
        Map<String,String> resultMap = vc.validateMasterData(inputMap);
        System.assertEquals(resultMap.get('code'), '422');
        //system.debug('result '+JSON.deserializeUntyped(JSON.serialize(vc.validateMasterData(inputMap))));
        test.stopTest();
    }
    
    public static testMethod void validateMasterDataTest3(){
        Map<String,String> inputMap = new Map<String,String>();
        User usr = [SELECT Id,Name FROM USer LIMIT 1];
        inputMap.put('CorrelationId__c','ytuytw762te72');
        inputMap.put('ActionType__c','');
        inputMap.put('Reason__c','');
        inputMap.put('ReferenceNumber__c','');
        inputMap.put('OwnerId__c','');
         Test.startTest();
        validationController vc = new validationController();
        Map<String,String> resultMap = vc.validateMasterData(inputMap);
        System.assertEquals(resultMap.get('code'), '422');
        //system.debug('result '+JSON.deserializeUntyped(JSON.serialize(vc.validateMasterData(inputMap))));
        test.stopTest();
    }
    
    public static testMethod void validateMasterDataTest4(){
        Map<String,String> inputMap = new Map<String,String>();
        User usr = [SELECT Id,Name FROM USer LIMIT 1];
        inputMap.put('CorrelationId__c','');
        inputMap.put('ActionType__c','');
        inputMap.put('Reason__c','');
        inputMap.put('ReferenceNumber__c','');
        inputMap.put('OwnerId__c','');
         Test.startTest();
        validationController vc = new validationController();
        Map<String,String> resultMap = vc.validateMasterData(inputMap);
        System.assertEquals(resultMap.get('code'), '400');
        //system.debug('result '+JSON.deserializeUntyped(JSON.serialize(vc.validateMasterData(inputMap))));
        test.stopTest();
    }
    
    public static testMethod void validateMasterDataTest5(){
        Map<String,String> inputMap = new Map<String,String>();
        User usr = [SELECT Id,Name FROM USer LIMIT 1];
        inputMap.put('CorrelationId__c','ytuytw762te72');
        inputMap.put('AccountId__c','12347612');
        inputMap.put('ActionType__c','SIM Replacement');
        inputMap.put('Reason__c','');
        inputMap.put('ReferenceNumber__c','');
        inputMap.put('OwnerId__c','dhbdh778282h8');
         Test.startTest();
        validationController vc = new validationController();
        Map<String,String> resultMap = vc.validateMasterData(inputMap);
        System.assertEquals(resultMap.get('code'), '422');
        //system.debug('result '+JSON.deserializeUntyped(JSON.serialize(vc.validateMasterData(inputMap))));
        test.stopTest();
    }
    
    public static testMethod void validateTONData1(){
        Map<String,String> inputMap = new Map<String,String>();
        User usr = [SELECT Id,Name FROM USer LIMIT 1];
        inputMap.put('CorrelationId__c','ytuytw762te72');
        inputMap.put('AccountId__c','12347612');
        inputMap.put('ActionType__c','TON Connect');
        inputMap.put('Reason__c','');
        inputMap.put('ReferenceNumber__c','');
        inputMap.put('OwnerId__c','dhbdh778282h8');
        Map<String,String> inputMap3 = new Map<String,String>();
        inputMap3.put('serviceMSISDN__c','61474703015');
        inputMap3.put('Subscription_Number__c','SN-000099809');
        inputMap3.put('Requested_SIM_Type__c','eSIM');
        inputMap3.put('Dispatch_Required__c','NO');
        inputMap3.put('Sim_Serial_Number__c','0928287');
        List<Object> objList = new List<Object>();
        objList.add(inputMap3);
         inputMap.put('services',JSON.serialize(objList));
        Test.startTest();
        validationController vc = new validationController();
        Map<String,String> resultMap = vc.validateTONData(inputMap);
        System.assertEquals(resultMap.get('code'), '422');
        //system.debug('result '+JSON.deserializeUntyped(JSON.serialize(vc.validateMasterData(inputMap))));
        test.stopTest();
    }
    
    public static testMethod void validateTONData2(){
        Map<String,String> inputMap = new Map<String,String>();
        User usr = [SELECT Id,Name FROM USer LIMIT 1];
        inputMap.put('CorrelationId__c','ytuytw762te72');
        inputMap.put('AccountId__c','12347612');
        inputMap.put('ActionType__c','TON Connect');
        inputMap.put('Reason__c','TON Connect');
        inputMap.put('ReferenceNumber__c','');
        inputMap.put('OwnerId__c','dhbdh778282h8');
        Map<String,String> inputMap3 = new Map<String,String>();
        inputMap3.put('serviceMSISDN__c','61474703015');
        inputMap3.put('Subscription_Number__c','SN-000099809');
        inputMap3.put('Requested_SIM_Type__c','eSIM');
        inputMap3.put('Dispatch_Required__c','NO');
        inputMap3.put('Sim_Serial_Number__c','0928287');
        List<Object> objList = new List<Object>();
        objList.add(inputMap3);
         inputMap.put('services',JSON.serialize(objList));
        Test.startTest();
        validationController vc = new validationController();
        Map<String,String> resultMap = vc.validateTONData(inputMap);
        System.assertEquals(resultMap.get('code'), '422');
        //system.debug('result '+JSON.deserializeUntyped(JSON.serialize(vc.validateMasterData(inputMap))));
        test.stopTest();
    }
    
     public static testMethod void validateSecondaryMSISDNTest(){
        Map<String,String> inputMap = new Map<String,String>();
        Map<String,String> inputMap1 = new Map<String,String>();
        Map<String,Object> tempMap = new Map<String,Object>();
        User usr = [SELECT Id,Name FROM User LIMIT 1];
        inputMap.put('CorrelationId__c','ytuytw762te72');
        inputMap.put('AccountId__c','12347612');   
        inputMap.put('OwnerId__c','dhbdh778282h8');
        inputMap1.put('CorrelationId__c','ytuytw762te72');     
        inputMap1.put('OwnerId__c','dhbdh778282h8');
        Map<String,String> inputMap3 = new Map<String,String>();
        inputMap3.put('serviceMSISDN__c','61474703015');
        inputMap3.put('secondaryMSISDN__c','61474703015');
        inputMap3.put('Subscription_Number__c','SN-000099809');      
         Map<String,String> inputMap4 = new Map<String,String>();
        inputMap4.put('serviceMSISDN__c','61474703016');
        inputMap4.put('secondaryMSISDN__c','61474703016');
        inputMap4.put('Subscription_Number__c','SN-000099809');      
         
        List<Object> objList = new List<Object>();         
        objList.add(inputMap3);
        List<Object> objList1 = new List<Object>();
        objList1.add(inputMap4);
        inputMap.put('services',JSON.serialize(objList));
         inputMap1.put('services',JSON.serialize(objList1));
      	 List<Object> serviceList = (List<Object>)JSON.deserializeUntyped(inputMap.get('services'));
         tempMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(serviceList[0]));  
          List<Object> serviceList1 = (List<Object>)JSON.deserializeUntyped(inputMap1.get('services'));
    
        Test.startTest();
        validationController vc = new validationController();
        vc.validateSecondaryMSISDN(tempMap,inputMap1.get('CorrelationId__c'));
         validationController vc1 = new validationController();
        
          
    	 vc1.validateSecondaryMSISDN((Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(serviceList1[0])),inputMap1.get('CorrelationId__c'));
        //system.debug('result '+JSON.deserializeUntyped(JSON.serialize(vc.validateMasterData(inputMap))));
        test.stopTest();
    }
     public static testMethod void validateSecondaryMSISDNTest1(){
        Map<String,String> inputMap = new Map<String,String>();
          Map<String,Object> tempMap = new Map<String,Object>();
        User usr = [SELECT Id,Name FROM User LIMIT 1];
        inputMap.put('CorrelationId__c','ytuytw762te72');
        inputMap.put('AccountId__c','12347612');
        inputMap.put('ActionType__c','TON Connect');       
        Map<String,String> inputMap3 = new Map<String,String>();
        inputMap3.put('serviceMSISDN__c','61474703015');
         inputMap3.put('secondaryMSISDN__c','61474703017');
        inputMap3.put('Subscription_Number__c','SN-000099809');
        inputMap3.put('Requested_SIM_Type__c','eSIM');
        inputMap3.put('Dispatch_Required__c','NO');
        inputMap3.put('Sim_Serial_Number__c','0928287');
         
        List<Object> objList = new List<Object>();
        objList.add(inputMap3);
         inputMap.put('services',JSON.serialize(objList));
      	 List<Object> serviceList = (List<Object>)JSON.deserializeUntyped(inputMap.get('services'));
         tempMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(serviceList[0]));                          
        Test.startTest();
        validationController vc = new validationController();        
        
        vc.validateSecondaryMSISDN(tempMap,inputMap.get('CorrelationId__c'));
        //system.debug('result '+JSON.deserializeUntyped(JSON.serialize(vc.validateMasterData(inputMap))));
        test.stopTest();
    }
  
   public static testMethod void validateSecondaryMSISDNTest2(){
        Map<String,String> inputMap = new Map<String,String>();
          Map<String,Object> tempMap = new Map<String,Object>();
        User usr = [SELECT Id,Name FROM User LIMIT 1];
        inputMap.put('CorrelationId__c','ytuytw762te72');
        inputMap.put('AccountId__c','12347612');
        inputMap.put('ActionType__c','TON Connect');       
        Map<String,String> inputMap3 = new Map<String,String>();
        inputMap3.put('serviceMSISDN__c','61474703015');
         // inputMap3.put('secondaryMSISDN__c','61474703016');
        inputMap3.put('Subscription_Number__c','SN-000099809');
        inputMap3.put('Requested_SIM_Type__c','eSIM');
        inputMap3.put('Dispatch_Required__c','NO');
        inputMap3.put('Sim_Serial_Number__c','0928287');
         
        List<Object> objList = new List<Object>();
        objList.add(inputMap3);
         inputMap.put('services',JSON.serialize(objList));
      	 List<Object> serviceList = (List<Object>)JSON.deserializeUntyped(inputMap.get('services'));
         tempMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(serviceList[0]));                          
        Test.startTest();
        validationController vc = new validationController();
         Map<String,String> resultMap = vc.validateTONData(inputMap);
         vc.validateSecondaryMSISDN(tempMap,inputMap.get('CorrelationId__c'));
     
        //system.debug('result '+JSON.deserializeUntyped(JSON.serialize(vc.validateMasterData(inputMap))));
        test.stopTest();
    }
  
    public static testMethod void validateServicesDataTest1(){
        Map<String,String> inputMap3 = new Map<String,String>();
        inputMap3.put('serviceMSISDN__c','9876543123');
        inputMap3.put('Subscription_Number__c','SN-000099809');
        inputMap3.put('Requested_SIM_Type__c','eSIM');
        inputMap3.put('Dispatch_Required__c','NO');
        inputMap3.put('Sim_Serial_Number__c','0928287');
        Map<String,String> inputMap4 = new Map<String,String>();
        inputMap4.put('serviceMSISDN__c','9876543123321');
        inputMap4.put('Subscription_Number__c','SN-00ks0099809');
        inputMap4.put('Requested_SIM_Type__c',' ');
        inputMap4.put('Dispatch_Required__c','NhaskhdO');
        Map<String,String> inputMap5 = new Map<String,String>();
        inputMap5.put('serviceMSISDN__c','');
        inputMap5.put('Subscription_Number__c','');
        inputMap5.put('Requested_SIM_Type__c','');
        inputMap5.put('Dispatch_Required__c','');
        List<Object> objList = new List<Object>();
        objList.add(inputMap3);
        objList.add(inputMap4);
        objList.add(inputMap5);
        Map<String,String> inputMap2 = new Map<String,String>();
        inputMap2.put('serviceMSISDN__c',JSON.serialize(objList));
        Test.startTest();
        validationController vc = new validationController();
        Map<String,String> resultMap = vc.validateServicesData(inputMap2);
        System.assertEquals(resultMap.get('code'), '422');
        Test.stopTest();
    }
    
    public static testMethod void validateServicesDataTest2(){
        Map<String,String> inputMap3 = new Map<String,String>();
        inputMap3.put('serviceMSISDN__c','9876543123');
        inputMap3.put('Subscription_Number__c','SN-000099809');
        inputMap3.put('Requested_SIM_Type__c','eSIM');
        inputMap3.put('Dispatch_Required__c','NO');
        inputMap3.put('Sim_Serial_Number__c','0928287');
        Map<String,String> inputMap4 = new Map<String,String>();
        inputMap4.put('serviceMSISDN__c','9876543123321');
        inputMap4.put('Subscription_Number__c','SN-00ks0099809');
        inputMap4.put('Requested_SIM_Type__c',' ');
        inputMap4.put('Dispatch_Required__c','NhaskhdO');
        Map<String,String> inputMap5 = new Map<String,String>();
        inputMap5.put('serviceMSISDN__c','');
        inputMap5.put('Subscription_Number__c','');
        inputMap5.put('Requested_SIM_Type__c','');
        inputMap5.put('Dispatch_Required__c','');
        
        List<Object> objList = new List<Object>();
        objList.add(inputMap3);
        objList.add(inputMap4);
        objList.add(inputMap5);
        Map<String,String> inputMap2 = new Map<String,String>();
        inputMap2.put('serviceMSISDN__c',JSON.serialize(objList));
        inputMap2.put('ActionType__c','Suspend');
        Test.startTest();
        validationController vc = new validationController();
        Map<String,String> resultMap = vc.validateServicesData(inputMap2);
        System.assertEquals(resultMap.get('code'), '422');
        Test.stopTest();
    }
    
    
    public static testMethod void validateServicesDataTest3(){
        Map<String,String> inputMap3 = new Map<String,String>();
        inputMap3.put('serviceMSISDN__c','9876543123');
        inputMap3.put('Subscription_Number__c','SN-000099809');
        inputMap3.put('Requested_SIM_Type__c','eSIM');
        inputMap3.put('Dispatch_Required__c','NO');
        inputMap3.put('Sim_Serial_Number__c','0928287');
        Map<String,String> inputMap4 = new Map<String,String>();
        inputMap4.put('serviceMSISDN__c','9876543123321');
        inputMap4.put('Subscription_Number__c','SN-00ks0099809');
        inputMap4.put('Requested_SIM_Type__c',' ');
        inputMap4.put('Dispatch_Required__c','NhaskhdO');
        Map<String,String> inputMap5 = new Map<String,String>();
        inputMap5.put('serviceMSISDN__c','');
        inputMap5.put('Subscription_Number__c','');
        inputMap5.put('Requested_SIM_Type__c','');
        inputMap5.put('Dispatch_Required__c','');
        List<Object> objList = new List<Object>();
        objList.add(inputMap3);
        objList.add(inputMap4);
        objList.add(inputMap5);
        Map<String,String> inputMap2 = new Map<String,String>();
        inputMap2.put('serviceMSISDN__c',JSON.serialize(objList));
        inputMap2.put('ActionType__c','Resume');
        Test.startTest();
        validationController vc = new validationController();
        Map<String,String> resultMap = vc.validateServicesData(inputMap2);
        System.assertEquals(resultMap.get('code'), '422');
        Test.stopTest();
    }
    
   // Author: Gokul P
     public static testMethod void validateServicesDataTest4(){
        Map<String,String> inputMap3 = new Map<String,String>();
        inputMap3.put('serviceMSISDN__c','');
        inputMap3.put('Subscription_Number__c','SN-000099809');
        inputMap3.put('Requested_SIM_Type__c','eSIM');
        inputMap3.put('Dispatch_Required__c','NO');
        inputMap3.put('Sim_Serial_Number__c','0928287');
        Map<String,String> inputMap4 = new Map<String,String>();
        inputMap4.put('serviceMSISDN__c','');
        inputMap4.put('Subscription_Number__c','SN-00ks0099809');
        inputMap4.put('Requested_SIM_Type__c',' ');
        inputMap4.put('Dispatch_Required__c','NhaskhdO');
        Map<String,String> inputMap5 = new Map<String,String>();
        inputMap5.put('serviceMSISDN__c','');
        inputMap5.put('Subscription_Number__c','');
        inputMap5.put('Requested_SIM_Type__c','');
        inputMap5.put('Dispatch_Required__c','');
        List<Object> objList = new List<Object>();
        objList.add(inputMap3);
        objList.add(inputMap4);
        objList.add(inputMap5);
        Map<String,String> inputMap2 = new Map<String,String>();
        inputMap2.put('serviceMSISDN__c',JSON.serialize(objList));
        inputMap2.put('ActionType__c','Resume');
        Test.startTest();
        validationController vc = new validationController();
        Map<String,String> resultMap = vc.validateServicesData(inputMap2);
        System.assertEquals(resultMap.get('code'), '422');
        Test.stopTest();
    }
    
    
    public static testMethod void checkForActionTypeTest (){

        Test.startTest();
        Map<String,String> resultMap = validationController.checkForActionType('');
        Test.stopTest();
        System.assertEquals(resultMap.get('code'), '422');
          
    
    }
   /*Author: Gokul P
*EDGE-213659
*Date: 07-May-2021
*/
    
    public static testMethod void checkDispatchRequiredTest(){
        Map<String,String> inputMap = new Map<String,String>();
        List<Map<String,String>> inputVal = new List<Map<String,String>>();
        csord__Service__c serv = [SELECT Primary_Contact__c,serviceMSISDN__c FROM csord__Service__c where serviceMSISDN__c ='9876543129'];
        Contact contac = [SELECT Id, Account.CIDN__c from Contact where Account.CIDN__c ='123476'];
        csord__Subscription__c testSubscription = [select id,csordtelcoa__Subscription_Number__c from csord__Subscription__c where Name = 'Unified Communication Enterprise'];
        inputMap.put('Subscription_Number__c',testSubscription.csordtelcoa__Subscription_Number__c);
        inputMap.put('serviceMSISDN__c','9876543129');
        inputMap.put('Sim_Serial_Number__c','1234567891234');
        inputMap.put('Requested_SIM_Type__c','Sim Card');
        inputMap.put('Dispatch_Required__c','');
        inputMap.put('AdborID__c','123Test');
        inputMap.put('ContactID__c',contac.id);
        inputMap.put('Reason__c','');
        inputVal.add(inputMap);
        Test.startTest();
        validationController vc = new validationController();
        vc.checkDispatchRequired(inputVal,'123476');
        Test.stopTest();
        //inputVal.put('services','[ { "Subscription_Number__c": "' + testSubscription.csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "9876543129", "Sim_Serial_Number__c": "1234567891234", "Requested_SIM_Type__c": "eSIM", "Dispatch_Required__c":"YES","AdborID__c": "180901344","ContactID__c": "0032O00000BNzfgQAD" }]');
        
    }
    public static testMethod void checkDispatchRequiredYesTest1(){
        Map<String,String> inputMap = new Map<String,String>();
        List<Map<String,String>> inputVal = new List<Map<String,String>>();
        csord__Service__c serv = [SELECT Primary_Contact__c,serviceMSISDN__c FROM csord__Service__c where serviceMSISDN__c ='9876543129'];
        Contact contac = [SELECT Id, Account.CIDN__c from Contact where Account.CIDN__c ='123476'];
        csord__Subscription__c testSubscription = [select id,csordtelcoa__Subscription_Number__c from csord__Subscription__c where Name = 'Unified Communication Enterprise'];
        inputMap.put('Subscription_Number__c',testSubscription.csordtelcoa__Subscription_Number__c);
        inputMap.put('serviceMSISDN__c','9876543129');
        inputMap.put('Sim_Serial_Number__c','1234567891234');
        inputMap.put('Requested_SIM_Type__c','Sim Card');
        inputMap.put('Dispatch_Required__c','YES');
        inputMap.put('AdborID__c','123Test');
        inputMap.put('ContactID__c',contac.id);
        inputMap.put('Reason__c','');
        inputVal.add(inputMap);
        Test.startTest();
        //inputVal.put('services','[ { "Subscription_Number__c": "' + testSubscription.csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "9876543129", "Sim_Serial_Number__c": "1234567891234", "Requested_SIM_Type__c": "eSIM", "Dispatch_Required__c":"YES","AdborID__c": "180901344","ContactID__c": "0032O00000BNzfgQAD" }]');
        validationController vc = new validationController();
        vc.checkDispatchRequired(inputVal,'123476');
        Test.stopTest();
    }
    
       public static testMethod void checkDispatchRequiredYesTest2(){
        Map<String,String> inputMap = new Map<String,String>();
        List<Map<String,String>> inputVal = new List<Map<String,String>>();
        csord__Service__c serv = [SELECT Primary_Contact__c,serviceMSISDN__c FROM csord__Service__c where serviceMSISDN__c ='9876543129'];
        Contact contac = [SELECT Id, Account.CIDN__c from Contact where Account.CIDN__c ='123476'];
        csord__Subscription__c testSubscription = [select id,csordtelcoa__Subscription_Number__c from csord__Subscription__c where Name = 'Unified Communication Enterprise'];
        inputMap.put('Subscription_Number__c',testSubscription.csordtelcoa__Subscription_Number__c);
        inputMap.put('serviceMSISDN__c','9876543129');
        inputMap.put('Sim_Serial_Number__c','');
        inputMap.put('Requested_SIM_Type__c','Sim Card');
        inputMap.put('Dispatch_Required__c','YES');
        inputMap.put('AdborID__c','');
        inputMap.put('ContactID__c','');
        inputMap.put('Reason__c','');
        inputVal.add(inputMap);
        Test.startTest();
        //inputVal.put('services','[ { "Subscription_Number__c": "' + testSubscription.csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "9876543129", "Sim_Serial_Number__c": "1234567891234", "Requested_SIM_Type__c": "eSIM", "Dispatch_Required__c":"YES","AdborID__c": "180901344","ContactID__c": "0032O00000BNzfgQAD" }]');
        validationController vc = new validationController();
        vc.checkDispatchRequired(inputVal,'123476');
        Test.stopTest();
    }
    
    public static testMethod void checkDispatchRequiredYesTest3(){
        Map<String,String> inputMap = new Map<String,String>();
        List<Map<String,String>> inputVal = new List<Map<String,String>>();
        csord__Service__c serv = [SELECT Primary_Contact__c,serviceMSISDN__c FROM csord__Service__c where serviceMSISDN__c ='9876543129'];
        Contact contac = [SELECT Id, Account.CIDN__c from Contact where Account.CIDN__c ='123476'];
        csord__Subscription__c testSubscription = [select id,csordtelcoa__Subscription_Number__c from csord__Subscription__c where Name = 'Unified Communication Enterprise'];
        inputMap.put('Subscription_Number__c',testSubscription.csordtelcoa__Subscription_Number__c);
        inputMap.put('serviceMSISDN__c','9876543129');
        inputMap.put('Sim_Serial_Number__c','');
        inputMap.put('Requested_SIM_Type__c','Sim Card');
        inputMap.put('Dispatch_Required__c','YES');
        inputMap.put('AdborID__c','');
        inputMap.put('ContactID__c',contac.id);
        inputMap.put('Reason__c','');
        inputVal.add(inputMap);
        Test.startTest();
        //inputVal.put('services','[ { "Subscription_Number__c": "' + testSubscription.csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "9876543129", "Sim_Serial_Number__c": "1234567891234", "Requested_SIM_Type__c": "eSIM", "Dispatch_Required__c":"YES","AdborID__c": "180901344","ContactID__c": "0032O00000BNzfgQAD" }]');
        validationController vc = new validationController();
        vc.checkDispatchRequired(inputVal,'123476');
        Test.stopTest();
    }
    
    public static testMethod void checkDispatchRequiredYesTest3and1(){
        Map<String,String> inputMap = new Map<String,String>();
        List<Map<String,String>> inputVal = new List<Map<String,String>>();
        csord__Service__c serv = [SELECT Primary_Contact__c,serviceMSISDN__c FROM csord__Service__c where serviceMSISDN__c ='9876543129'];
        Contact contac = [SELECT Id, Account.CIDN__c from Contact where Account.CIDN__c ='22222'];
        csord__Subscription__c testSubscription = [select id,csordtelcoa__Subscription_Number__c from csord__Subscription__c where Name = 'Unified Communication Enterprise'];
        inputMap.put('Subscription_Number__c',testSubscription.csordtelcoa__Subscription_Number__c);
        inputMap.put('serviceMSISDN__c','9876543129');
        inputMap.put('Sim_Serial_Number__c','');
        inputMap.put('Requested_SIM_Type__c','Sim Card');
        inputMap.put('Dispatch_Required__c','YES');
        inputMap.put('AdborID__c','');
        inputMap.put('ContactID__c',contac.id);
        inputMap.put('Reason__c','');
        inputVal.add(inputMap);
        Test.startTest();
        //inputVal.put('services','[ { "Subscription_Number__c": "' + testSubscription.csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "9876543129", "Sim_Serial_Number__c": "1234567891234", "Requested_SIM_Type__c": "eSIM", "Dispatch_Required__c":"YES","AdborID__c": "180901344","ContactID__c": "0032O00000BNzfgQAD" }]');
        validationController vc = new validationController();
        vc.checkDispatchRequired(inputVal,'123476');
        Test.stopTest();
    }
    
    public static testMethod void checkDispatchRequiredYesTest4(){
        Map<String,String> inputMap = new Map<String,String>();
        List<Map<String,String>> inputVal = new List<Map<String,String>>();
        csord__Service__c serv = [SELECT Primary_Contact__c,serviceMSISDN__c FROM csord__Service__c where serviceMSISDN__c ='9876543129'];
        Contact contac = [SELECT Id, Account.CIDN__c from Contact where Account.CIDN__c ='123476'];
        csord__Subscription__c testSubscription = [select id,csordtelcoa__Subscription_Number__c from csord__Subscription__c where Name = 'Unified Communication Enterprise'];
        inputMap.put('Subscription_Number__c',testSubscription.csordtelcoa__Subscription_Number__c);
        inputMap.put('serviceMSISDN__c','9876543129');
        inputMap.put('Sim_Serial_Number__c','');
        inputMap.put('Requested_SIM_Type__c','Sim Card');
        inputMap.put('Dispatch_Required__c','YES');
        inputMap.put('AdborID__c','');
        inputMap.put('ContactID__c',contac.id);
        inputMap.put('Reason__c','');
        inputVal.add(inputMap);
        Test.startTest();
        //inputVal.put('services','[ { "Subscription_Number__c": "' + testSubscription.csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "9876543129", "Sim_Serial_Number__c": "1234567891234", "Requested_SIM_Type__c": "eSIM", "Dispatch_Required__c":"YES","AdborID__c": "180901344","ContactID__c": "0032O00000BNzfgQAD" }]');
        validationController vc = new validationController();
        vc.checkDispatchRequired(inputVal,'123476');
        Test.stopTest();
    }
    
    public static testMethod void checkDispatchRequiredYesTest5(){
        Map<String,String> inputMap = new Map<String,String>();
        List<Map<String,String>> inputVal = new List<Map<String,String>>();
        csord__Service__c serv = [SELECT Primary_Contact__c,serviceMSISDN__c FROM csord__Service__c where serviceMSISDN__c ='9876543129'];
        Contact contac = [SELECT Id, Account.CIDN__c from Contact where Account.CIDN__c ='123476'];
        csord__Subscription__c testSubscription = [select id,csordtelcoa__Subscription_Number__c from csord__Subscription__c where Name = 'Unified Communication Enterprise'];
        inputMap.put('Subscription_Number__c',testSubscription.csordtelcoa__Subscription_Number__c);
        inputMap.put('serviceMSISDN__c','9876543129');
        inputMap.put('Sim_Serial_Number__c','');
        inputMap.put('Requested_SIM_Type__c','Sim Card');
        inputMap.put('Dispatch_Required__c','YES');
        inputMap.put('AdborID__c','');
        inputMap.put('ContactID__c','someothervalue');
        inputMap.put('Reason__c','');
        inputVal.add(inputMap);
        Test.startTest();
        //inputVal.put('services','[ { "Subscription_Number__c": "' + testSubscription.csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "9876543129", "Sim_Serial_Number__c": "1234567891234", "Requested_SIM_Type__c": "eSIM", "Dispatch_Required__c":"YES","AdborID__c": "180901344","ContactID__c": "0032O00000BNzfgQAD" }]');
        validationController vc = new validationController();
        vc.checkDispatchRequired(inputVal,'123476');
        Test.stopTest();
    }

		public static testMethod void checkDispatchRequiredYesTest6(){
        Map<String,String> inputMap = new Map<String,String>();
        List<Map<String,String>> inputVal = new List<Map<String,String>>();
        csord__Service__c serv = [SELECT Primary_Contact__c,serviceMSISDN__c FROM csord__Service__c where serviceMSISDN__c ='9876543129'];
        Contact contac = [SELECT Id, Account.CIDN__c from Contact where Account.CIDN__c ='123476'];
        csord__Subscription__c testSubscription = [select id,csordtelcoa__Subscription_Number__c from csord__Subscription__c where Name = 'Unified Communication Enterprise'];
        inputMap.put('Subscription_Number__c',testSubscription.csordtelcoa__Subscription_Number__c);
        inputMap.put('serviceMSISDN__c','9876543129');
        inputMap.put('Sim_Serial_Number__c','');
        inputMap.put('Requested_SIM_Type__c','Sim Card');
        inputMap.put('Dispatch_Required__c','YES');
        inputMap.put('AdborID__c','someothervalue');
        inputMap.put('ContactID__c',contac.id);
        inputMap.put('Reason__c','');
        inputVal.add(inputMap);
        Test.startTest();
        //inputVal.put('services','[ { "Subscription_Number__c": "' + testSubscription.csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "9876543129", "Sim_Serial_Number__c": "1234567891234", "Requested_SIM_Type__c": "eSIM", "Dispatch_Required__c":"YES","AdborID__c": "180901344","ContactID__c": "0032O00000BNzfgQAD" }]');
        validationController vc = new validationController();
        vc.checkDispatchRequired(inputVal,'123476');
        Test.stopTest();
    }

		public static testMethod void checkDispatchRequiredYesTest7(){
        Map<String,String> inputMap = new Map<String,String>();
        List<Map<String,String>> inputVal = new List<Map<String,String>>();
        csord__Service__c serv = [SELECT Primary_Contact__c,serviceMSISDN__c FROM csord__Service__c where serviceMSISDN__c ='9876543129'];
        Contact contac = [SELECT Id, Account.CIDN__c from Contact where Account.CIDN__c ='123476'];//
        csord__Subscription__c testSubscription = [select id,csordtelcoa__Subscription_Number__c from csord__Subscription__c where Name = 'Unified Communication Enterprise'];
        inputMap.put('Subscription_Number__c',testSubscription.csordtelcoa__Subscription_Number__c);//invalid
        inputMap.put('serviceMSISDN__c','9876543129');
        inputMap.put('Sim_Serial_Number__c','1234567891234');
        inputMap.put('Requested_SIM_Type__c','Sim Card');
        inputMap.put('Dispatch_Required__c','');
        inputMap.put('AdborID__c','123Test');
        inputMap.put('ContactID__c',contac.id);
        inputMap.put('Reason__c','');
        inputVal.add(inputMap);
        //inputVal.put('services','[ { "Subscription_Number__c": "' + testSubscription.csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "9876543129", "Sim_Serial_Number__c": "1234567891234", "Requested_SIM_Type__c": "eSIM", "Dispatch_Required__c":"YES","AdborID__c": "180901344","ContactID__c": "0032O00000BNzfgQAD" }]');
        validationController vc = new validationController();
        vc.checkDispatchRequired(inputVal,'');//empty
    }   
    
    public static testMethod void checkDispatchRequiredYesTest8(){
        Map<String,String> inputMap = new Map<String,String>();
        List<Map<String,String>> inputVal = new List<Map<String,String>>();
        csord__Service__c serv = [SELECT Primary_Contact__c,serviceMSISDN__c FROM csord__Service__c where serviceMSISDN__c ='9876543129'];
        Contact contac = [SELECT Id, Account.CIDN__c from Contact where Account.CIDN__c ='123476'];
        csord__Subscription__c testSubscription = [select id,csordtelcoa__Subscription_Number__c from csord__Subscription__c where Name = 'Unified Communication Enterprise'];
        inputMap.put('Subscription_Number__c',testSubscription.csordtelcoa__Subscription_Number__c);
        inputMap.put('serviceMSISDN__c','');//empty
        inputMap.put('Sim_Serial_Number__c','1234567891234');
        inputMap.put('Requested_SIM_Type__c','Sim Card');
        inputMap.put('Dispatch_Required__c','');
        inputMap.put('AdborID__c','123Test');
        inputMap.put('ContactID__c',contac.id);
        inputMap.put('Reason__c','');
        inputVal.add(inputMap);
        Test.startTest();
        //inputVal.put('services','[ { "Subscription_Number__c": "' + testSubscription.csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "9876543129", "Sim_Serial_Number__c": "1234567891234", "Requested_SIM_Type__c": "eSIM", "Dispatch_Required__c":"YES","AdborID__c": "180901344","ContactID__c": "0032O00000BNzfgQAD" }]');
        validationController vc = new validationController();
        vc.checkDispatchRequired(inputVal,'123476');
        Test.stopTest();
    } 
    
    public static testMethod void checkDispatchRequiredYesTest9(){
        Map<String,String> inputMap = new Map<String,String>();
        List<Map<String,String>> inputVal = new List<Map<String,String>>();
        csord__Service__c serv = [SELECT Primary_Contact__c,serviceMSISDN__c FROM csord__Service__c where serviceMSISDN__c ='9876543129'];
        Contact contac = [SELECT Id, Account.CIDN__c from Contact where Account.CIDN__c ='123476'];
        csord__Subscription__c testSubscription = [select id,csordtelcoa__Subscription_Number__c from csord__Subscription__c where Name = 'Unified Communication Enterprise'];
        inputMap.put('Subscription_Number__c',testSubscription.csordtelcoa__Subscription_Number__c);
        inputMap.put('serviceMSISDN__c',testSubscription.csordtelcoa__Subscription_Number__c);
        inputMap.put('Sim_Serial_Number__c','1234567891234');//invalid
        inputMap.put('Requested_SIM_Type__c','Sim Card');
        inputMap.put('Dispatch_Required__c','');
        inputMap.put('AdborID__c','123Test');
        inputMap.put('ContactID__c',contac.id);
        inputMap.put('Reason__c','');
        inputVal.add(inputMap);
        Test.startTest();
        //inputVal.put('services','[ { "Subscription_Number__c": "' + testSubscription.csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "9876543129", "Sim_Serial_Number__c": "1234567891234", "Requested_SIM_Type__c": "eSIM", "Dispatch_Required__c":"YES","AdborID__c": "180901344","ContactID__c": "0032O00000BNzfgQAD" }]');
        validationController vc = new validationController();
        vc.checkDispatchRequired(inputVal,'123476');
        Test.stopTest();
    }
    
    
    public static testMethod void checkDispatchRequiredNoTest1(){
        Map<String,String> inputMap = new Map<String,String>();
        List<Map<String,String>> inputVal = new List<Map<String,String>>();
        csord__Service__c serv = [SELECT Primary_Contact__c,serviceMSISDN__c FROM csord__Service__c where serviceMSISDN__c ='9876543129'];
        Contact contac = [SELECT Id, Account.CIDN__c from Contact where Account.CIDN__c ='123476'];
        csord__Subscription__c testSubscription = [select id,csordtelcoa__Subscription_Number__c from csord__Subscription__c where Name = 'Unified Communication Enterprise'];
        inputMap.put('Subscription_Number__c',testSubscription.csordtelcoa__Subscription_Number__c);
        inputMap.put('serviceMSISDN__c','9876543129');
        inputMap.put('Sim_Serial_Number__c','1234567891234');
        inputMap.put('Requested_SIM_Type__c','Sim Card');
        inputMap.put('Dispatch_Required__c','No');
        inputMap.put('AdborID__c','123Test');
        inputMap.put('ContactID__c',contac.id);
        inputMap.put('Reason__c','');
        inputVal.add(inputMap);
        Test.startTest();
        //inputVal.put('services','[ { "Subscription_Number__c": "' + testSubscription.csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "9876543129", "Sim_Serial_Number__c": "1234567891234", "Requested_SIM_Type__c": "eSIM", "Dispatch_Required__c":"YES","AdborID__c": "180901344","ContactID__c": "0032O00000BNzfgQAD" }]');
        validationController vc = new validationController();
        vc.checkDispatchRequired(inputVal,'123476');
        Test.stopTest();
    }
      public static testMethod void checkDispatchRequiredNoTest01(){
        Map<String,String> inputMap = new Map<String,String>();
        List<Map<String,String>> inputVal = new List<Map<String,String>>();
        csord__Service__c serv = [SELECT Primary_Contact__c,serviceMSISDN__c FROM csord__Service__c where serviceMSISDN__c ='9876543129'];
        Contact contac = [SELECT Id, Account.CIDN__c from Contact where Account.CIDN__c ='123476'];
        csord__Subscription__c testSubscription = [select id,csordtelcoa__Subscription_Number__c from csord__Subscription__c where Name = 'Unified Communication Enterprise'];
        inputMap.put('Subscription_Number__c',testSubscription.csordtelcoa__Subscription_Number__c);
        inputMap.put('serviceMSISDN__c','9876543129');
        inputMap.put('Sim_Serial_Number__c','123456781234');
        inputMap.put('Requested_SIM_Type__c','Sim Card');
        inputMap.put('Dispatch_Required__c','No');
        inputMap.put('AdborID__c','123Test');
        inputMap.put('ContactID__c',contac.id);
        inputMap.put('Reason__c','');
        inputVal.add(inputMap);
        Test.startTest();
        //inputVal.put('services','[ { "Subscription_Number__c": "' + testSubscription.csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "9876543129", "Sim_Serial_Number__c": "1234567891234", "Requested_SIM_Type__c": "eSIM", "Dispatch_Required__c":"YES","AdborID__c": "180901344","ContactID__c": "0032O00000BNzfgQAD" }]');
        validationController vc = new validationController();
        vc.checkDispatchRequired(inputVal,'123476');
        Test.stopTest();
    }
    public static testMethod void checkDispatchRequiredNoTest2(){
        Map<String,String> inputMap = new Map<String,String>();
        List<Map<String,String>> inputVal = new List<Map<String,String>>();
        csord__Service__c serv = [SELECT Primary_Contact__c,serviceMSISDN__c FROM csord__Service__c where serviceMSISDN__c ='9876543129'];
        Contact contac = [SELECT Id, Account.CIDN__c from Contact where Account.CIDN__c ='123476'];
        csord__Subscription__c testSubscription = [select id,csordtelcoa__Subscription_Number__c from csord__Subscription__c where Name = 'Unified Communication Enterprise'];
        inputMap.put('Subscription_Number__c',testSubscription.csordtelcoa__Subscription_Number__c);
        inputMap.put('serviceMSISDN__c','9876543129');
        inputMap.put('Sim_Serial_Number__c','');
        inputMap.put('Requested_SIM_Type__c','Sim Card');
        inputMap.put('Dispatch_Required__c','No');
        inputMap.put('AdborID__c','');
        inputMap.put('ContactID__c','');
        inputMap.put('Reason__c','');
        inputVal.add(inputMap);
        Test.startTest();
        //inputVal.put('services','[ { "Subscription_Number__c": "' + testSubscription.csordtelcoa__Subscription_Number__c + '", "serviceMSISDN__c": "9876543129", "Sim_Serial_Number__c": "1234567891234", "Requested_SIM_Type__c": "eSIM", "Dispatch_Required__c":"YES","AdborID__c": "180901344","ContactID__c": "0032O00000BNzfgQAD" }]');
        validationController vc = new validationController();
        vc.checkDispatchRequired(inputVal,'123476');
        Test.stopTest();
    }

     @isTest
    public static void checkForSubscriptionNumberTest(){
        List<csord__Subscription__c> subList = [SELECT Id,Name,csord__Account__c,csord__Order__c,csord__Identification__c,csordtelcoa__Product_Configuration__c,csordtelcoa__Subscription_Number__c FROM csord__Subscription__c WHERE Name = 'Unified Communication Enterprise'];
        List<csord__Service__c> servList = [SELECT Id,serviceMSISDN__c,csordtelcoa__Product_Configuration__c,csord__Identification__c,csord__Subscription__c,csord__Status__c FROM csord__Service__c WHERE serviceMSISDN__c = '61474703015'];
        string servData = '[{"Reason__c":"Sim Card (Physical SIM) faulty","ContactID__c":"0032O00000BBgMTQA1","AdborID__c":"12546","Dispatch_Required__c":"No","Requested_SIM_Type__c":"sim card","Sim_Serial_Number__c":"1234567891234","serviceMSISDN__c":"61474703015","Subscription_Number__c":"SN-000099809"}]';
        Test.startTest();
        validationController validCont = new validationController();
        validCont.checkForSubscriptionNumber((List<Object>)JSON.deserializeUntyped(servData),subList);
        Test.stopTest();
    }
    
         @isTest
    public static void checkForSubscriptionNumberTest2(){
        List<csord__Subscription__c> subList = [SELECT Id,Name,csord__Account__c,csord__Order__c,csord__Identification__c,csordtelcoa__Product_Configuration__c,csordtelcoa__Subscription_Number__c FROM csord__Subscription__c WHERE Name = 'Unified Communication Enterprise'];
        List<csord__Service__c> servList = [SELECT Id,serviceMSISDN__c,csordtelcoa__Product_Configuration__c,csord__Identification__c,csord__Subscription__c,csord__Status__c FROM csord__Service__c WHERE serviceMSISDN__c = '61474703015'];
        string servData = '[{"Reason__c":"Sim Card (Physical SIM) faulty","ContactID__c":"0032O00000BBgMTQA1","AdborID__c":"12546","Dispatch_Required__c":"No","Requested_SIM_Type__c":"sim card","Sim_Serial_Number__c":"1234567891234","serviceMSISDN__c":"61474703015","Subscription_Number__c":"SN-000099809"}]';

        Test.startTest();
        validationController validCont = new validationController();
        validCont.checkForSubscriptionNumber((List<Object>)JSON.deserializeUntyped(servData),subList);
        Test.stopTest();
    }
    
    
    /*
* Author: Rajiv Kumar Singh
* Des : This method is used to add messages
* EDGE-214319
* Date : 

    */
  
    
    
   @isTest
    public static void checkCorrelationTest(){

        string servData = '[{"Reason__c":"Sim Card (Physical SIM) faulty","ContactID__c":"0032O00000BBgMTQA1","AdborID__c":"12546","Dispatch_Required__c":"No","Requested_SIM_Type__c":"sim card","Sim_Serial_Number__c":"1234567891234","serviceMSISDN__c":"61474703087","Subscription_Number__c":" SN-000101578"}]';
        Map<String,String> inputMap = new Map<String,String>();
        inputMap.put('CorrelationId__c','ytuytw762te72');
        inputMap.put('AccountId__c','12347612');
        inputMap.put('ActionType__c','Suspend');
        inputMap.put('Reason__c','sdhsl');
        inputMap.put('ReferenceNumber__c','dsad125');
        inputMap.put('OwnerId__c','dhbdh778282h8');
        inputMap.put('serviceMSISDN__c',servData);
        inputMap.put('Dispatch_Required__c','No');
        Test.startTest();
        validationController vc = new validationController();
        Map<String,String> resultMap = vc.validateServicesData(inputMap);
        Map<String,String> resultMap1 = vc.validateMasterData(inputMap);
		Test.stopTest();
        System.assertEquals(resultMap.get('code'), '422');
    }

    @isTest
    public static void checkCorrelationTest2(){
        string servData = '[{"Reason__c":"Sim Card (Physical SIM) faulty","ContactID__c":"0032O00000BBgMTQA1","AdborID__c":"12546","Dispatch_Required__c":"No","Requested_SIM_Type__c":"sim card","Sim_Serial_Number__c":"1234567891234","serviceMSISDN__c":"61474703015","Subscription_Number__c":" SN-000101578"}]';
        Map<String,String> inputMap = new Map<String,String>();
        inputMap.put('CorrelationId__c','ytuytw762te72');
        inputMap.put('AccountId__c','12347612');
        inputMap.put('ActionType__c','Resume');
        inputMap.put('Reason__c','sdhsl');
        inputMap.put('ReferenceNumber__c','dsad125');
        inputMap.put('OwnerId__c','dhbdh778282h8');
        inputMap.put('serviceMSISDN__c',servData);
        inputMap.put('Dispatch_Required__c','Yes');
        Test.startTest();
        validationController vc = new validationController();
        Map<String,String> resultMap = vc.validateServicesData(inputMap);
		Test.stopTest();
        System.assertEquals(resultMap.get('code'), '422');
    }
    
    @isTest
    public static void checkCorrelationNegativeTest(){
        Map<String,String> inputMap = new Map<String,String>();
        inputMap.put('CorrelationId__c','');
        Test.startTest();
        validationController vc = new validationController();
        Map<String,String> resultMap = vc.validateMasterData(inputMap);
		Test.stopTest();
        System.assertEquals(resultMap.get('code'), '400');
    }
    
    @isTest
    public static void checkTestMthodNew(){
            Map<String,String> inputMap = new Map<String,String>();
        User usr = [SELECT Id,Name FROM USer LIMIT 1];
        inputMap.put('CorrelationId__c','ytuytw762te72');
        inputMap.put('AccountId__c','12347612');
        inputMap.put('ActionType__c','SIM Replacement');
        inputMap.put('Reason__c','');
        inputMap.put('ReferenceNumber__c','');
        inputMap.put('OwnerId__c','dhbdh778282h8');
         Test.startTest();
        validationController vc = new validationController();
        vc.validateMasterData(inputMap);
        string servData = '[{"Reason__c":"Sim Card (Physical SIM) faulty","ContactID__c":"0032O00000BBgMTQA1","AdborID__c":"12546","Dispatch_Required__c":"No","Requested_SIM_Type__c":"sim card","Sim_Serial_Number__c":"1234567891234","serviceMSISDN__c":"61474703015","Subscription_Number__c":"SN-000099809"}]';
        Map<String,String> inputMap2 = new Map<String,String>();
        inputMap2.put('CorrelationId__c','ytuytw762te72');
        inputMap2.put('AccountId__c','12347612');
        inputMap2.put('ActionType__c','Resume');
        inputMap2.put('Reason__c','sdhsl');
        inputMap2.put('ReferenceNumber__c','dsad125');
        inputMap2.put('OwnerId__c','dhbdh778282h8');
        inputMap2.put('serviceMSISDN__c',servData);
        inputMap2.put('Dispatch_Required__c','Yes');
        Map<String,String> resultMap = vc.validateServicesData(inputMap2);
        Test.stopTest();
    }
    
    @isTest
    public static void checkServicesForSuspendTest(){
        List<csord__Subscription__c> subList = [SELECT Id,Name,csord__Account__c,csord__Order__c,csord__Identification__c,csordtelcoa__Product_Configuration__c,csordtelcoa__Subscription_Number__c FROM csord__Subscription__c WHERE Name = 'Unified Communication Enterprise'];
        List<csord__Service__c> servList = [SELECT Id,serviceMSISDN__c,csordtelcoa__Product_Configuration__c,csord__Identification__c,csord__Subscription__c,csord__Status__c FROM csord__Service__c WHERE serviceMSISDN__c = '61474703015'];
        string servData = '[{"Reason__c":"Sim Card (Physical SIM) faulty","ContactID__c":"0032O00000BBgMTQA1","AdborID__c":"12546","Dispatch_Required__c":"No","Requested_SIM_Type__c":"sim card","Sim_Serial_Number__c":"1234567891234","serviceMSISDN__c":"61474703015","Subscription_Number__c":"SN-000099809"}]';
        Test.startTest();
        validationController validCont = new validationController();
        validCont.checkServicesForSuspend((List<Object>)JSON.deserializeUntyped(servData),subList,servList);
        Test.stopTest();
    }
    
    @isTest
     public static void checkServicesForResumeTest(){
        List<csord__Subscription__c> subList = [SELECT Id,Name,csord__Account__c,csord__Order__c,csord__Identification__c,csordtelcoa__Product_Configuration__c,csordtelcoa__Subscription_Number__c,Suspension_reason_summary__c FROM csord__Subscription__c WHERE Name = 'Unified Communication Enterprise'];
        List<csord__Service__c> servList = [SELECT Id,serviceMSISDN__c,csordtelcoa__Product_Configuration__c,csord__Identification__c,csord__Subscription__c,csord__Status__c FROM csord__Service__c WHERE serviceMSISDN__c = '61474703015'];
        string servData = '[{"Reason__c":"Sim Card (Physical SIM) faulty","ContactID__c":"0032O00000BBgMTQA1","AdborID__c":"12546","Dispatch_Required__c":"No","Requested_SIM_Type__c":"sim card","Sim_Serial_Number__c":"1234567891234","serviceMSISDN__c":"61474703015","Subscription_Number__c":"SN-000099809"}]';
        Test.startTest();
        validationController validCont = new validationController();
         if(servData != null && subList != null && servList != null && subList.size() > 0){
              validCont.checkServicesForResume((List<Object>)JSON.deserializeUntyped(servData),subList,servList);
         }
        Test.stopTest();
    }
    
    @isTest
     public static void checkReasonOnServicesTest(){
        List<csord__Subscription__c> subList = [SELECT Id,Name,csord__Account__c,csord__Order__c,csord__Identification__c,csordtelcoa__Product_Configuration__c,csordtelcoa__Subscription_Number__c,Suspension_reason_summary__c FROM csord__Subscription__c WHERE Name = 'Unified Communication Enterprise'];
         subList[0].Suspension_reason_summary__c = 'testing new';
        List<csord__Service__c> servList = [SELECT Id,serviceMSISDN__c,csordtelcoa__Product_Configuration__c,csord__Identification__c,csord__Subscription__c,csord__Status__c FROM csord__Service__c WHERE serviceMSISDN__c = '61474703015'];
        string servData = '[{"Reason__c":"Sim Card (Physical SIM) faulty","ContactID__c":"0032O00000BBgMTQA1","AdborID__c":"12546","Dispatch_Required__c":"No","Requested_SIM_Type__c":"sim card","Sim_Serial_Number__c":"1234567891234","serviceMSISDN__c":"61474703015","Subscription_Number__c":"SN-000099809"}]';
        Test.startTest();
        validationController validCont = new validationController();
         if(servData != null && subList != null && servList != null && subList.size() > 0){
              validCont.checkReasonOnServices((List<Object>)JSON.deserializeUntyped(servData),subList,'Resume',servList);
              validCont.checkReasonOnServices((List<Object>)JSON.deserializeUntyped(servData),subList,'Suspend',servList);
         }
        Test.stopTest();
    }

    @isTest
    public static void CheckForServiceMSISDNTest(){
        List<csord__Service__c> servList = [SELECT Id,serviceMSISDN__c,csordtelcoa__Product_Configuration__c,csord__Identification__c,csord__Subscription__c,csord__Status__c FROM csord__Service__c WHERE serviceMSISDN__c = '61474703015'];
       string servData = '[{"Reason__c":"Sim Card (Physical SIM) faulty","ContactID__c":"0032O00000BBgMTQA1","AdborID__c":"12546","Dispatch_Required__c":"No","Requested_SIM_Type__c":"sim card","Sim_Serial_Number__c":"1237891234","serviceMSISDN__c":"61474715","Subscription_Number__c":"SN-0000909"}]';
         Test.startTest();
        validationController validCont = new validationController();
         validCont.CheckForServiceMSISDN((List<Object>)JSON.deserializeUntyped(servData),servList);
        Test.stopTest();
    }
}