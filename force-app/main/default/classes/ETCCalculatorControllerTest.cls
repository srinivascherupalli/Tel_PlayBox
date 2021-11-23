/*******************************************************************************************************************
Name : ETCCalculatorControllerTest
EDGE-> 198139
Description : Test class for ETCCalculatorController
====================================================================================================================
Sr.No.    Developer Name          Date                  Story Description
1.        Rajiv Singh          11/02/2021       Test class for ETCCalculatorController                                             
====================================================================================================================
********************************************************************************************************************/
@isTest
public with sharing class ETCCalculatorControllerTest {
    
    @testSetup
    static void setup(){

        BDS_Notify_Settings__c bdsNotifySettingFeatureLevel = (BDS_Notify_Settings__c) SYS_TestDataFactory.createCustomSetting(BDS_Notify_Settings__c.sObjectType);
        bdsNotifySettingFeatureLevel.Name = 'Feature Level';
        bdsNotifySettingFeatureLevel.Value__c = 'FeatureLevelShadow';
        BDS_Notify_Settings__c bdsNotifySettingTechnicalSupport = (BDS_Notify_Settings__c) SYS_TestDataFactory.createCustomSetting(BDS_Notify_Settings__c.sObjectType);
        bdsNotifySettingTechnicalSupport.Name = 'Technical Support';
        bdsNotifySettingTechnicalSupport.Value__c = 'TechnicalSupportShadow';
        
        insert new List<BDS_Notify_Settings__c>{bdsNotifySettingFeatureLevel, bdsNotifySettingTechnicalSupport};

        Account acc = new Account();
        acc.Name = 'testAcc';
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Rajiv';
        con.LastName = 'Singh'; 
        con.email ='rajiv@test.com';
        con.Contact_Status__c ='Active';
        con.AccountId = acc.Id;
        insert con;
        
        Marketable_Offer__c mo = new Marketable_Offer__c();
         mo.Offer_ID__c = 'DMCAT_Offer_001233';
         mo.Name = 'testing 1';
        insert mo;
        
        Marketable_Offer__c mo2 = new Marketable_Offer__c();
         mo2.Offer_ID__c = 'DMCAT_Offer_000618';
         mo2.Name = 'testing 1';
        insert mo2;
        
        Marketable_Offer__c mo3 = new Marketable_Offer__c();
         mo3.Offer_ID__c = 'DMCAT_Offer_000646';
         mo3.Name = 'testing 1';
        insert mo3;

        
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
        
       // insert ord;
       // system.debug('ord id '+ord.Id);
        
        csord__Order__c ord2 = new csord__Order__c();
        ord2.Name = 'testord2';
        ord2.csord__Identification__c = 'test123';
        ord2.csordtelcoa__Opportunity__c = opp.Id;
        ord2.csord__Status2__c = 'Amend Rejected';
        insert ord2;
        system.debug('ord id '+ord2.Id);
        
        csord__Order__c ord3 = new csord__Order__c();
        ord3.Name = 'testord3';
        ord3.csord__Identification__c = 'test123';
        ord3.csordtelcoa__Opportunity__c = opp.Id;
        ord3.csordtelcoa__Point_of_No_Return_Reached__c = true;
        insert ord3;
        
        csord__Solution__c sol = new csord__Solution__c();
        sol.Name = 'testsol';
        sol.csord__Identification__c = 'testing';
        sol.csord__Account__c = acc.Id;
        sol.csord__Order__c = ord.Id;
        insert sol;

        cscfga__Product_Configuration__c newConfig = new cscfga__Product_Configuration__c();
        newConfig.name = 'new config';
        newConfig.cssdm__solution_association__c = sol.Id;
        newConfig.cscfga__total_contract_value__c = 1234.45;
        insert newConfig;
 
        cscfga__Attribute__c cfgAttr = new cscfga__Attribute__c();
        cfgAttr.cscfga__Product_Configuration__c = newConfig.Id;
        cfgAttr.Name = 'InstalmentCharge';
        cfgAttr.cscfga__Recurring__c = true;
        cfgAttr.cscfga__Value__c = '1234';
        insert cfgAttr;
        
        csord__Subscription__c sub = new csord__Subscription__c();
        sub.Name = 'testsub';
        sub.MarketableOffer__c = mo.Id;
        sub.cssdm__solution_association__c = sol.Id;
        sub.csord__Account__c = acc.Id;
        //sub.csord__Order__c = ord.Id;
        sub.csord__Identification__c = 'testing';
        sub.Point_of_No_Return_Reached__c = false;
        sub.customerFacingServiceId__c = '1234';
        sub.csord__Status__c = 'testing';
        insert sub;
        
        csord__Subscription__c sub2 = new csord__Subscription__c();
        sub2.Name = 'testsub2';
        sub2.MarketableOffer__c = mo2.Id;
        sub2.cssdm__solution_association__c = sol.Id;
        sub2.csord__Account__c = acc.Id;
        //sub2.csord__Order__c = ord.Id;
        sub2.csord__Identification__c = 'testing';
        sub2.Point_of_No_Return_Reached__c = false;
        sub2.customerFacingServiceId__c = '1234';
        sub2.csord__Status__c = 'Active';
        insert sub2;
        
        csord__Subscription__c sub4 = new csord__Subscription__c();
        sub4.Name = 'testsub4';
        sub4.MarketableOffer__c = mo3.Id;
        sub4.cssdm__solution_association__c = sol.Id;
        sub4.csord__Account__c = acc.Id;
        //sub4.csord__Order__c = ord.Id;
        sub4.csord__Identification__c = 'testing';
        sub4.Point_of_No_Return_Reached__c = false;
        sub4.customerFacingServiceId__c = '1234';
        sub4.csord__Status__c = 'Active';
        insert sub4;
        
        csord__Order_Request__c orderReq = new csord__Order_Request__c();
        orderReq.csord__Module_Name__c   = 'CS Order Implementation Module Telco Test A';
        orderReq.csord__Module_Version__c = '1.0';
        orderReq.csord__Processing_Mode__c = 'SYNCHRONOUS';
        orderReq.csord__Process_Status__c = 'FINISHED';
        orderReq.csord__Completion_Status__c = 'SUCCESS';
        orderReq.csord__Request_DateTime__c = DateTime.newInstance(2021, 11, 18, 3, 3, 3);
        orderReq.csord__Next_Execution_Attempt__c = DateTime.newInstance(2021, 11, 18, 3, 6, 6);
        orderReq.csord__Previous_Execution_Attempt__c= DateTime.newInstance(2021, 11, 18, 3, 4, 4);
        orderReq.csord__Execution_Attempt_Count__c = 1;
        insert orderReq;
    
        cscrm__Address__c address = new cscrm__Address__c();
        address.Name = '2367 TESTINI LANE, WARBURN NSW 2680 Test';
        address.cscrm__Address_Type__c = 'Property With Number';
        address.cscrm__Street__c = '2367 TESTINI LANE';
        address.Locality__c = 'WARBURN';
        address.cscrm__State_Province__c = 'NSW';
        address.cscrm__Zip_Postal_Code__c = '2680';
        address.cscrm__Country__c = 'AUSTRALIA';
        address.Address_Line_1__c = '2367 TESTINI LANE,';
        address.Address_ID__c = '425122979';
        insert address;
        
        Billing_Account__c billingAcc = new Billing_Account__c();
        billingAcc.Billing_Account_Number__c = '700000017562';
        billingAcc.Status__c = 'Created';
        billingAcc.Account__c = acc.Id;
        billingAcc.Billing_Address__c = address.Id;
        billingAcc.Billing_Account_Owner__c = con.Id;

        csord__Subscription__c sub3 = new csord__Subscription__c();
        sub3.Name = 'testsub3';
        sub3.cssdm__solution_association__c = sol.Id;
        sub2.MarketableOffer__c = mo3.Id;
        sub3.csord__Account__c = acc.Id;
       // sub3.csord__Order__c = ord.Id;
        sub3.csord__Identification__c = 'testing';
        sub3.csordtelcoa__Product_Configuration__c = newConfig.Id;
        sub3.Point_of_No_Return_Reached__c = false;
        sub3.customerFacingServiceId__c = '1234';
        sub3.csord__Status__c = 'Active';
        sub3.Billing_Account__c = billingAcc.Id;
        insert sub3;
        
        
        
        csord__Service__c service = new csord__Service__c();
        service.csord__Subscription__c = sub.Id;
        service.csord__Order_Request__c = orderReq.Id;
        service.csord__Status__c = 'Active';
        service.Payment_Type__c = 'Repayment';
        service.Billing_Account__c = billingAcc.Id;
        service.Initial_Activation_Date__c = Date.newInstance(2021,1,1);
        service.csord__Activation_Date__c = Date.newInstance(2021,2,1);
        service.Action_Type__c = 'New';
        service.csord__Identification__c = 'Service_a3T4Y0000006mHRUAY_0';
        insert service;
        
        csord__Service__c service2 = new csord__Service__c();
        service2.csord__Service__c = service.Id;
        service2.csord__Subscription__c = sub2.Id;
        service2.csord__Order_Request__c = orderReq.Id;
        service2.csord__Status__c = 'Active';
        service2.Payment_Type__c = 'Repayment';
        service2.Billing_Account__c = billingAcc.Id;
        service2.Initial_Activation_Date__c = Date.newInstance(2021,1,1);
        service2.csord__Activation_Date__c = Date.newInstance(2021,2,1);
        service2.Action_Type__c = 'New';
        service2.csord__Identification__c = 'Service_a3T4Y0000006mHRUAY_0';
        insert service2;    
        
        csord__Service__c service3 = new csord__Service__c();
        service3.csord__Service__c = service.Id;
        service3.csord__Subscription__c = sub4.Id;
        service3.csord__Order_Request__c = orderReq.Id;
        service3.csord__Status__c = 'Active';
        service3.Payment_Type__c = 'Repayment';
        service3.Billing_Account__c = billingAcc.Id;
        service3.Initial_Activation_Date__c = Date.newInstance(2021,1,1);
        service3.csord__Activation_Date__c = Date.newInstance(2021,2,1);
        service3.Action_Type__c = 'New';
        service3.csord__Identification__c = 'Service_a3T4Y0000006mHRUAY_0';
        insert service3;    

       

    }
    
    @isTest
    // Calling the grtServiceDetails method with inactive subscription
    public static void testMethod1(){
        csord__Subscription__c subscriptionRec = [SELECT Id FROM csord__Subscription__c WHERE Name='testsub' LIMIT 1];
        Test.startTest();
        Object result = ETCCalculatorController.grtServiceDetails(subscriptionRec.Id);
        system.assertEquals(true, result!=null); 
        Test.stopTest();
    }
    @isTest
    // Calling the grtServiceDetails method with active subscription with a valid service
    public static void testMethod2(){
        csord__Subscription__c subscriptionRec = [SELECT Id FROM csord__Subscription__c WHERE Name='testsub2' LIMIT 1];
        Test.startTest();
        Object result = ETCCalculatorController.grtServiceDetails(subscriptionRec.Id);
        system.assertEquals(true, result!=null); 
        Test.stopTest();
    }
    @isTest
     // Calling the grtServiceDetails method with active subscription with no service
    public static void testMethod3(){
        csord__Subscription__c subscriptionRec = [SELECT Id FROM csord__Subscription__c WHERE Name='testsub3' LIMIT 1];
        Test.startTest();
        Object result = ETCCalculatorController.grtServiceDetails(subscriptionRec.Id);
        system.assertEquals(true, result!=null); 
        Test.stopTest();
    }
    @isTest
    // Calling the grtServiceDetails method with null for subscription id
    public static void testMethod4(){
        csord__Subscription__c subscriptionRec = new csord__Subscription__c();
        Test.startTest();
        Object result = ETCCalculatorController.grtServiceDetails(subscriptionRec.Id);
        Map<String,Object> resultMap = (Map<String,Object>)(JSON.deserializeUntyped(JSON.serialize(result)));
        system.assertEquals(true,resultMap.get('message') == 'Invalid subscription Id'); 
        Test.stopTest();
    }

    @isTest
    public static void testgetETCChargesForCMPDevice(){
        Map<String,Object> inputMap = new Map<String,Object>();
        cscfga__Product_Configuration__c pconfig = [SELECT Id FROM cscfga__Product_Configuration__c WHERE Name='new config'];
        csord__Subscription__c sub = [SELECT Id FROM csord__Subscription__c WHERE Name='testsub3'];
        Date disconnectionDate = Date.newInstance(2020,07,01);
        inputMap.put('ProdConfigId',pconfig.Id);
        inputMap.put('DisconnectionDate', String.valueOf(System.today()+30));
        inputMap.put('InitailActivationDate', String.valueOf(System.today()+20));
        inputMap.put('etc_Term',4);
        inputMap.put('subscriptionId',sub.Id);
        Test.startTest();
        Object result = ETCCalculatorController.getETCChargesForCMPDevice(inputMap);
        system.assertEquals(result!=null, true);
        Test.stopTest();
    }
    
    @isTest
    public static void testgetDataForCMP(){
        csord__Subscription__c sub = [SELECT Id FROM csord__Subscription__c WHERE Name='testsub4'];
        Test.startTest();
        Object result = ETCCalculatorController.getDataForCMP(sub.Id);
        system.assertEquals(result!=null, true);
        Test.stopTest();
        
    }
}