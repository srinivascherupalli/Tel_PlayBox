/**=====================================================================
 * @Modified By : Kamlesh Kumar
 * @Modified Date : 5th Nov 2020
 * @Desc : Test class for OrderPostProcessing
 =======================================================================
 ===============================================================================================================================
 Change.No.    Developer Name          Date          Story Description
 1.            Shubhi V              31/03/2021      EDGE-209293 (chown order)
 ================================================================================================================================*/
 @isTest
 public with sharing class OrderPostProcessingTest {
   @testSetup
   public static void setup() {
        Id devRecordTypeId1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - In Contract').getRecordTypeId();
        Account testAccount = new Account();
        testAccount.Name = 'TestAccount';
        testAccount.Customer_Status__c = 'ACTIVE';
        insert testAccount;
        Environment_Configurations__c settings = new Environment_Configurations__c();
        settings.No_Triggers__c = True; 
        insert settings;
        List<Contact> contactInsertList = new List<Contact>();
           
        Contact pconctact = AccountTestFactory.buildContact(testAccount, 'testPC', 'testabc122@test.com');
        contactInsertList.add(pconctact);
        Contact scontact = AccountTestFactory.buildContact(testAccount, 'testSC', 'estabc13222@testdom.com');
        contactInsertList.add(scontact);
        insert contactInsertList;
        
        List<EnvironmentVariable__c> environmentVarLst = new List<EnvironmentVariable__c>();
        EnvironmentVariable__c envrn = new EnvironmentVariable__c(Name='enableMSISDN', Value__c = 'true');
        environmentVarLst.add(envrn);
        
        EnvironmentVariable__c envs = new EnvironmentVariable__c(Name='enableOrderPrerequiste', Value__c = 'true');
        environmentVarLst.add(envs);
         
        EnvironmentVariable__c envrn1 = new EnvironmentVariable__c(Name='AppointmentVersion', Value__c = '2');
        environmentVarLst.add(envrn1);
        
        EnvironmentVariable__c setting = new EnvironmentVariable__c();
        setting.Name = 'engageSNRMFallout';
        setting.Value__c = 'FALSE';
        environmentVarLst.add(setting);
        
        insert environmentVarLst;
        
        //chown accIn EDGE-209293
        List<Account> accLst= new List<Account>();
        Account accOut = new Account();
        accOut.name = 'Test CHOWN Outgoing Account';
        accLst.add(accOut);
        
        Account accIn = new Account();
        accIn.name = 'Test CHOWN Incoming Account';
        accLst.add(accIn);
        insert accLst;
    
        List<Opportunity> opptyLst= new List<Opportunity>();
        Opportunity opptyOut = new Opportunity();
        opptyOut.Account = accOut;
        opptyOut.name = 'Test CHOWN Outgoing Oppty';
        opptyOut.StageName = 'Propose';
        opptyOut.recordtypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - In Contract').getRecordtypeId();
        opptyOut.CloseDate = System.today()+1;
        opptyLst.add(opptyOut);
        
        //EDGE-209293 chown optyis
        Opportunity opptyIn = new Opportunity();
        opptyIn.Account = accIn;
        opptyIn.name = 'Test CHOWN Incoming Oppty';
        opptyIn.StageName = 'Propose';
        opptyIn.CloseDate = System.today()+1;
        opptyOut.recordtypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - In Contract').getRecordtypeId();
        opptyIn.CloseDate = System.today()+1;
        opptyLst.add(opptyIn);
    
        Opportunity testOpp = new Opportunity();
        testOpp.AccountId = testAccount.Id;
        testOpp.Name = 'Test Account Opportunity';
        testOpp.StageName = 'Created';
        testOpp.CloseDate = System.Date.today();
        testOpp.RetiedAccOpp__c = true;
        opptyLst.add(testOpp);
    
        insert opptyLst;
        opptyOut.type = 'CHOWN';
        opptyOut.Product_Type__c = 'Modular';
        update opptyOut;
        
        opptyIn.type = 'CHOWN';
        opptyIn.Product_Type__c = 'Modular';
        update opptyIn;
        
        List<cscrm__Address__c> lstAddress = new List<cscrm__Address__c>();
        for(Integer i=0 ;i < 10 ; i++){
            cscrm__Address__c address = new cscrm__Address__c();
            address.Address_ID__c = testAccount+'--' + i;
            address.cscrm__Street__c  = testAccount+ 'Street'+ i;
            lstAddress.add(address);
        }   
        insert lstAddress;
        
        List<cscrm__Site__c> lstSite = new List<cscrm__Site__c>();
        for(cscrm__Address__c address: lstAddress){
            cscrm__Site__c  site = new cscrm__Site__c();
            site.cscrm__Floor__c = 'L-T'+address.Address_ID__c;
            site.cscrm__Installation_Address__c = address.id;
            site.cscrm__Account__c = testAccount.id;
            site.Primary_Contact__c = contactInsertList[0].id;
            site.Secondary_Contact__c = contactInsertList[1].id;    
            lstSite.add(site);
        }   
        insert lstSite;
        
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>();
        cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(
            Name = 'IP Site',
            cscfga__Description__c = 'PD1 Desc',
            Snapshot_Object__c ='CS_Basket_Snapshot_Transactional__c',
            product_Specification__c = Label.MobilitySpecCode
        );
        pdList.add(pd);

        cscfga__Product_Definition__c pdIOTSub = new cscfga__Product_Definition__c(
            Name = 'IOT Subscription',
            cscfga__Description__c = 'PD2 Desc',
            Snapshot_Object__c ='CS_Basket_Snapshot_Transactional__c',
            product_Specification__c = Label.MobilitySpecCode
        );
        pdList.add(pdIOTSub);
        insert pdList;

        csedm__Specification__c testSpecification = new csedm__Specification__c(
                Name = Label.MobilitySpecCode, csedm__Active__c= true, csedm__identifier__c='testIdentif',
                  //  csedm__Product_Definition__c = pd.Id,  // Spring 20 commented
                  csedm__Source__c = pd.Id,   // Spring 20 
                csedm__Value__c  = '{ "code": "DMCAT_ProductSpecification_000263",'
                 + '"name": "Mobility_Billing_Allowance_000484_1", "description": "",  "cpqAttributes": {},'
                 + ' "attributes": {   "__targetSystem": {"value": "FULFILMENT","type": "string"},"billingSpecId": {"value": "BSUSG001_CB","type": "string"},'
                 + ' "ocsProdID": {"value": "ocsProd1","type": "string"},"type": {"value": "Domestic Data","type": "string"},'
                 + '"unitofMeasure": {"value": "GB","type": "string"},"value": {"value": "50","type": "string"}}, "nonCommercialAttributes": []} )'
        );
        insert testSpecification;
        
        List<cscfga__Attribute_Definition__c> lstAttributeDef = new List<cscfga__Attribute_Definition__c>();
        cscfga__Attribute_Definition__c ad = new cscfga__Attribute_Definition__c(
            cscfga__Product_Definition__c = pd.Id,
            Name = 'AD1',
            Snapshot_Attribute_Value_Field__c = 'Text__c',
            Snapshot_Attribute_Fields__c = 'Test'
        );
        
        cscfga__Attribute_Definition__c ad1 = new cscfga__Attribute_Definition__c(
            cscfga__Product_Definition__c = pd.Id,
            Name = 'Site name 2',
            Snapshot_Attribute_Value_Field__c = 'Text__c',
            Snapshot_Attribute_Fields__c = 'Test1'
        );
        
        cscfga__Attribute_Definition__c ad2 = new cscfga__Attribute_Definition__c(
            cscfga__Product_Definition__c = pd.Id,
            Name = 'Site Address 2',
            Snapshot_Attribute_Value_Field__c = 'Text__c',
            Snapshot_Attribute_Fields__c = 'Test2'
        );

        cscfga__Attribute_Definition__c ad3 = new cscfga__Attribute_Definition__c(
            cscfga__Product_Definition__c = pdIOTSub.Id,
            Name = 'IOT Site Address 1',
            Snapshot_Attribute_Value_Field__c = 'Text__c',
            Snapshot_Attribute_Fields__c = 'Test3'
        );

        cscfga__Attribute_Definition__c ad4 = new cscfga__Attribute_Definition__c(
            cscfga__Product_Definition__c = pdIOTSub.Id,
            Name = 'IOT Site Address 2',
            Snapshot_Attribute_Value_Field__c = 'Text__c',
            Snapshot_Attribute_Fields__c = 'Test4'
        );
        
        lstAttributeDef.add(ad);
        lstAttributeDef.add(ad1);
        lstAttributeDef.add(ad2);
        lstAttributeDef.add(ad3);
        lstAttributeDef.add(ad4);
        
        insert lstAttributeDef;
        
        List<cscfga__Product_Basket__c> basketList = new List<cscfga__Product_Basket__c>();
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(
            Name = 'Test Account Opportunity Basket1',
            OwnerId = UserInfo.getUserId(),
            cscfga__Opportunity__c = testOpp.Id,
            csbb__Account__c = testAccount.Id,
            csordtelcoa__Basket_Stage__c = 'Quote'
        );
        cscfga__Product_Basket__c basketIOT = new cscfga__Product_Basket__c(
            Name = 'Test Account Opportunity Basket2',
            OwnerId = UserInfo.getUserId(),
            cscfga__Opportunity__c = testOpp.Id,
            csbb__Account__c = testAccount.Id,
            csordtelcoa__Basket_Stage__c = 'Quote'
        );
        //EDGE-209293 chown baskets 
        cscfga__Product_Basket__c basketOut = new cscfga__Product_Basket__c();
        basketOut.name = 'Test CHOWN Outgoing Basket';
        basketOut.BasketType__c = 'Outgoing';
        basketOut.csordtelcoa__Basket_Stage__c = 'Enriched';
        basketOut.csbb__Account__c = accOut.id;
        basketOut.cscfga__Opportunity__c = opptyOut.id;
        basketList.add(basketOut);
        
        cscfga__Product_Basket__c basketIn = new cscfga__Product_Basket__c();
        basketIn.name = 'Test CHOWN Outgoing Basket';
        basketIn.BasketType__c = 'Incoming';
        basketIn.csordtelcoa__Basket_Stage__c = 'Enriched';
        basketIn.csbb__Account__c = accIn.id;
        basketIn.cscfga__Opportunity__c = opptyIn.id;
        basketList.add(basketIn);
      
        basketList.add(basket);
        basketList.add(basketIOT);
        insert basketList;
            
        basket.csordtelcoa__Basket_Stage__c = 'Enriched';
        
        //Marketable_Offer__c
        List<Marketable_Offer__c> marketOfferList   =   new List<Marketable_Offer__c>();
        Marketable_Offer__c marktoffer1 =   new Marketable_Offer__c();
        marktoffer1.Name                =   'testoffer';
        marktoffer1.Offer_ID__c         =   'DMCAT1234';         
        marketOfferList.add(marktoffer1);
        Marketable_Offer__c marktoffer2 =   new Marketable_Offer__c();
        marktoffer2.Name                =   'testoffer';
        marktoffer2.Offer_ID__c         =   'DMCAT5678'; 
        marketOfferList.add(marktoffer2);        
        insert marketOfferList;
        
        //Offer 
        List<cscfga__Configuration_Offer__c> configOfferLst =   new List<cscfga__Configuration_Offer__c>();
        cscfga__Configuration_Offer__c offer1   =   new cscfga__Configuration_Offer__c();
        offer1.name                             =   'Mobile';
        offer1.Offer_Spec_Id__c                 =   'DMCAT1234';
        configOfferLst.add(offer1);
        cscfga__Configuration_Offer__c offer2   =   new cscfga__Configuration_Offer__c();
        offer2.name                             =   'Mobile';
        offer2.Offer_Spec_Id__c                 =   'DMCAT5678';
        configOfferLst.add(offer2);
        insert configOfferLst;
    
        List<cscfga__Product_Configuration__c> lstpc = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c pc     =   new cscfga__Product_Configuration__c();
        pc.cscfga__Product_Definition__c        =   pd.Id;   
        pc.cscfga__Product_Basket__c            =   basket.Id;
        pc.Marketable_Offer__c                  =   marktoffer1.id;
        pc.Offer_Reference__c                   =   offer1.id;
        pc.ConfigurationType1__c                =   'SolutionComponent';
        pc.Name                                 =   'IP Site';
        lstpc.add(pc);
        cscfga__Product_Configuration__c pc1    =   new cscfga__Product_Configuration__c();
        pc1.cscfga__Product_Definition__c       =   pd.Id;   
        pc1.cscfga__Product_Basket__c           =   basket.Id;
        pc1.Marketable_Offer__c                 =   marktoffer1.id;
        pc1.Name                                =   'Site';
        lstpc.add(pc1);
        cscfga__Product_Configuration__c pc2    =   new cscfga__Product_Configuration__c();
        pc2.cscfga__Product_Definition__c       =   pd.Id;   
        pc2.cscfga__Product_Basket__c           =   basket.Id;
        pc2.Marketable_Offer__c                 =   marktoffer1.id;
        pc2.Name                                =   'IP Network';
        lstpc.add(pc2);
        cscfga__Product_Configuration__c pc3    =   new cscfga__Product_Configuration__c();
        pc3.cscfga__Product_Definition__c       =   pd.Id;   
        pc3.cscfga__Product_Basket__c           =   basket.Id;
        pc3.Marketable_Offer__c                 =   marktoffer1.id;
        pc3.Name                                =   'Mobile';
        lstpc.add(pc3);
        cscfga__Product_Configuration__c pc4    =   new cscfga__Product_Configuration__c();
        pc4.cscfga__Product_Definition__c       =   pdIOTSub.Id;   
        pc4.cscfga__Product_Basket__c           =   basketIOT.Id;
        pc4.Marketable_Offer__c                 =   marktoffer1.id;
        pc4.Offer_Reference__c                  =   offer1.id;
        pc4.ConfigurationType1__c               =   'SolutionComponent';
        pc4.Name                                =   'IOT Subscription';
        lstpc.add(pc4);
        // chown pcs EDGE-209293
        cscfga__Product_Configuration__c configOut = new cscfga__Product_Configuration__c();         
        configOut.name = 'Test Outgoing Config';
        configOut.configGUID__c = 'dfghjkl56789067890vbnjkf';
        configOut.cscfga__Product_Basket__c = basketOut.Id;
        configOut.ConfigurationType1__c = '';
        lstpc.add(configOut);
        
        cscfga__Product_Configuration__c configIn = new cscfga__Product_Configuration__c();         
        configIn.name = 'Test Outgoing Config';
        configIn.configGUID__c = 'dfghjkl56789067890vbnjkf';
        configIn.cscfga__Product_Basket__c = basketIn.Id;
        configIn.ConfigurationType1__c = '';
        lstpc.add(configIn);
      
        insert lstpc;
        
        List<cscfga__Attribute__c> lstAttribute = new List<cscfga__Attribute__c>();

        cscfga__Attribute__c att = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = lstpc[0].Id,
            Name = 'Test',
            cscfga__Value__c = '10',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = lstAttributeDef[0].Id
        );
        cscfga__Attribute__c att0 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = lstpc[1].Id,
            Name = 'Site name',
            cscfga__Value__c = '10',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = lstAttributeDef[0].Id
        );
        
        cscfga__Attribute__c att1 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = lstpc[1].Id,
            Name = 'Site Address',
            cscfga__Value__c = '10',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = lstAttributeDef[0].Id
        );

        cscfga__Attribute__c att3 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = lstpc[0].Id,
            Name = 'IOT Site Address 1',
            cscfga__Value__c = '10',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = lstAttributeDef[3].Id
        );
        cscfga__Attribute__c att4 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = lstpc[1].Id,
            Name = 'IOT Site Address 2',
            cscfga__Value__c = '10',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = lstAttributeDef[4].Id
        );
        
        lstAttribute.add(att);
        lstAttribute.add(att0);
        lstAttribute.add(att1);
        lstAttribute.add(att3);
        lstAttribute.add(att4);
        
        insert lstAttribute;


        List<Basket_To_Order_Field_Map__c> lstBasketMap = new List<Basket_To_Order_Field_Map__c>();
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Name='Hot_Cutover_Comments__c',Source_Object_API_Name__c='cscfga__Product_Basket__c',Target_Object_API_Name__c='csord__Order__c',Source_Field_API_Name__c='Hot_Cutover_Comments__c',Target_Field_API_Name__c='Hot_Cutover_Comments__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Name='PM_Required__c',Source_Object_API_Name__c='cscfga__Product_Basket__c',Target_Object_API_Name__c='csord__Order__c',Source_Field_API_Name__c='PM_Required__c',Target_Field_API_Name__c='PM_Required__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Name='Project_Manager_Email__c',Source_Object_API_Name__c='cscfga__Product_Basket__c',Target_Object_API_Name__c='csord__Order__c',Source_Field_API_Name__c='Project_Manager_Email__c',Target_Field_API_Name__c='Project_Manager_Email__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Name='Service_Number__c',Source_Object_API_Name__c='cscfga__Product_Basket__c',Target_Object_API_Name__c='csord__Order__c',Source_Field_API_Name__c='Service_Number__c',Target_Field_API_Name__c='Service_Number__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Name='Project_Manager_User_ID__c',Source_Object_API_Name__c='cscfga__Product_Basket__c',Target_Object_API_Name__c='csord__Order__c',Source_Field_API_Name__c='Project_Manager_User_ID__c',Target_Field_API_Name__c='Project_Manager_User_ID__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Name='Hot_Cutover__c',Source_Object_API_Name__c='cscfga__Product_Basket__c',Target_Object_API_Name__c='csord__Order__c',Source_Field_API_Name__c='Hot_Cutover__c',Target_Field_API_Name__c='Hot_Cutover__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Name='Project_Complexity__c',Source_Object_API_Name__c='cscfga__Product_Basket__c',Target_Object_API_Name__c='csord__Order__c',Source_Field_API_Name__c='Project_Complexity__c',Target_Field_API_Name__c='Project_Complexity__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Name='Project_ID__c',Source_Object_API_Name__c='cscfga__Product_Basket__c',Target_Object_API_Name__c='csord__Order__c',Source_Field_API_Name__c='Project_ID__c',Target_Field_API_Name__c='Project_ID__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Name='Billing_Account__c',Source_Object_API_Name__c='cscfga__Product_Basket__c',Target_Object_API_Name__c='csord__Order__c',Source_Field_API_Name__c='Billing_Account__c',Target_Field_API_Name__c='Billing_Account__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Name='Project_Manager_Contact_Number__c',Source_Object_API_Name__c='cscfga__Product_Basket__c',Target_Object_API_Name__c='csord__Order__c',Source_Field_API_Name__c='Project_Manager_Contact_Number__c',Target_Field_API_Name__c='Project_Manager_Contact_Number__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Name='Opportunity_ID__c',Source_Object_API_Name__c='cscfga__Product_Basket__c',Target_Object_API_Name__c='csord__Order__c',Source_Field_API_Name__c='Maxim_Opportunity_ID__c',Target_Field_API_Name__c='Opportunity_ID__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Name='Model_Change__c',Source_Object_API_Name__c='cscfga__Product_Basket__c',Target_Object_API_Name__c='csord__Order__c',Source_Field_API_Name__c='Model_Change__c',Target_Field_API_Name__c='ModelChange__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Name='Owner',Source_Object_API_Name__c='cscfga__Product_Basket__c',Target_Object_API_Name__c='csord__Order__c',Source_Field_API_Name__c='OwnerId',Target_Field_API_Name__c='OwnerId'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Name='Tactical_Handling_Type__c',Source_Object_API_Name__c='cscfga__Product_Basket__c',Target_Object_API_Name__c='csord__Order__c',Source_Field_API_Name__c='Tactical_Handling_Type__c',Target_Field_API_Name__c='Tactical_Handling_Type__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Name='Serviceability_Location__c',Source_Object_API_Name__c='csord__Service__c',Target_Object_API_Name__c='csord__Subscription__c',Source_Field_API_Name__c='Serviceability_Location__c',Target_Field_API_Name__c='Serviceability_Location__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Name='SiteId__c',Source_Object_API_Name__c='csord__Service__c',Target_Object_API_Name__c='csord__Subscription__c',Source_Field_API_Name__c='SiteId__c',Target_Field_API_Name__c='Site__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Name='isAggregationPoint__c',Source_Object_API_Name__c='csord__Service__c',Target_Object_API_Name__c='csord__Subscription__c',Source_Field_API_Name__c='isAggregationPoint__c',Target_Field_API_Name__c='isAggregationPoint__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Name='Not_Before_CRD__c',Source_Object_API_Name__c='csord__Service__c',Target_Object_API_Name__c='csord__Subscription__c',Source_Field_API_Name__c='Not_Before_CRD__c',Target_Field_API_Name__c='Not_Before_CRD__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Name='Preferred_CRD__c',Source_Object_API_Name__c='csord__Service__c',Target_Object_API_Name__c='csord__Subscription__c',Source_Field_API_Name__c='Preferred_CRD__c',Target_Field_API_Name__c='Preferred_CRD__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Name='International_Calling__c',Source_Object_API_Name__c='csord__Service__c',Target_Object_API_Name__c='csord__Subscription__c',Source_Field_API_Name__c='International_Calling__c',Target_Field_API_Name__c='International_Calling__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Name='Call_Control__c',Source_Object_API_Name__c='csord__Service__c',Target_Object_API_Name__c='csord__Subscription__c',Source_Field_API_Name__c='Call_Control__c',Target_Field_API_Name__c='Call_Control__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Name='Cancellation_Reason_c',Source_Object_API_Name__c='csord__Service__c',Target_Object_API_Name__c='csord__Subscription__c',Source_Field_API_Name__c='Cancellation_Reason__c',Target_Field_API_Name__c='Reason_for_cancellation__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Name='ServiceToSub:Billing_Account__c',Source_Object_API_Name__c='csord__Service__c',Target_Object_API_Name__c='csord__Subscription__c',Source_Field_API_Name__c='Billing_Account__c',Target_Field_API_Name__c='Billing_Account__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Name='NetworkServiceId__c',Source_Object_API_Name__c='csord__Service__c',Target_Object_API_Name__c='csord__Subscription__c',Source_Field_API_Name__c='NetworkServiceId__c',Target_Field_API_Name__c='NetworkServiceId__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Name='autoExpiry__c',Source_Object_API_Name__c='csord__Service__c',Target_Object_API_Name__c='csord__Subscription__c',Source_Field_API_Name__c='autoExpiry__c',Target_Field_API_Name__c='autoExpiry__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Name='Access_Type__c',Source_Object_API_Name__c='csord__Service__c',Target_Object_API_Name__c='csord__Subscription__c',Source_Field_API_Name__c='TechnologyType__c',Target_Field_API_Name__c='Access_Type__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Name='serviceMSISDN__c',Source_Object_API_Name__c='csord__Service__c',Target_Object_API_Name__c='csord__Subscription__c',Source_Field_API_Name__c='serviceMSISDN__c',Target_Field_API_Name__c='serviceMSISDN__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Name='Offer__c',Source_Object_API_Name__c='csord__Subscription__c',Target_Object_API_Name__c='csord__Subscription__c',Source_Field_API_Name__c='csordtelcoa__Product_Configuration__r.Offer_Reference__c',Target_Field_API_Name__c='Offer__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Name='Product_Model_Version__c',Source_Object_API_Name__c='csord__Subscription__c',Target_Object_API_Name__c='csord__Subscription__c',Source_Field_API_Name__c='csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Product_Model_Version__c',Target_Field_API_Name__c='Product_Model_Version__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Name='MarketableOffer__c',Source_Object_API_Name__c='csord__Subscription__c',Target_Object_API_Name__c='csord__Subscription__c',Source_Field_API_Name__c='csordtelcoa__Product_Configuration__r.Marketable_Offer__c',Target_Field_API_Name__c='MarketableOffer__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Name='partnerAccount__c',Source_Object_API_Name__c='csord__Subscription__c',Target_Object_API_Name__c='csord__Subscription__c',Source_Field_API_Name__c='csord__Order__r.csordtelcoa__Opportunity__r.PartnerAccountId',Target_Field_API_Name__c='partnerAccount__c'));
        insert lstBasketMap;

        List<csord__Order_Request__c> ordReqList = new List<csord__Order_Request__c>();
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        ordReqList.add(ordReq);
        csord__Order_Request__c ordReq1 = ProductTestFactory.buildOrderRequest();
        ordReqList.add(ordReq1);
        csord__Order_Request__c ordReq2 = ProductTestFactory.buildOrderRequest();
        ordReqList.add(ordReq2);
        csord__Order_Request__c ordReq3 = ProductTestFactory.buildOrderRequest();
        ordReqList.add(ordReq3);
        insert ordReqList;

        List<csord__Order__c> orderList = new List<csord__Order__c>();
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', testAccount.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        orderList.add(ord);
        csord__Order__c ord1 = ProductTestFactory.buildOrder('TestOrder1', testAccount.id, 'Created', ordReq1.id);
        ord1.csord__Order_Request__c = ordReq1.Id;
        orderList.add(ord1);
        csord__Order__c ord2 = ProductTestFactory.buildOrder('TestOrder', accOut.id, 'Created', ordReq2.id);//EDGE-209293 chown order
        ord.csord__Order_Request__c = ordReq.Id;
        ord.csordtelcoa__Opportunity__c = opptyOut.Id;
        orderList.add(ord2);
        csord__Order__c ord3 = ProductTestFactory.buildOrder('TestOrder1', accIn.id, 'Created', ordReq3.id); //EDGE-209293 chown order
        ord1.csord__Order_Request__c = ordReq1.Id;
        ord1.csordtelcoa__Opportunity__c = opptyIn.Id;
        orderList.add(ord3);
        insert orderList;
        
        List<csord__Subscription__c> lstSub = new List<csord__Subscription__c>();
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'testSubscription';
        subs.csord__Identification__c = 'testIdentity';
        subs.csord__Order__c = ord.Id;
        subs.Sub_status__c = 'Active';
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subs.csordtelcoa__Product_Configuration__c = pc.id;
        lstSub.add(subs);
        
        csord__Subscription__c subsBT=new csord__Subscription__c();
        subsBT.name  = 'Next Generation Voice';
        subsBT.csord__Identification__c = 'testIdentity';
        subsBT.csord__Order__c = ord.Id;
        subsBT.Sub_status__c = 'Active';
        subsBT.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294f';
        subsBT.csordtelcoa__Product_Configuration__c = pc.id;
        lstSub.add(subsBT);
        
        csord__Subscription__c subsNGVoice=new csord__Subscription__c();
        subsNGVoice.name  = 'Broadsoft Tenancy';
        subsNGVoice.csord__Identification__c = 'testIdentity';
        subsNGVoice.csord__Order__c = ord.Id;
        subsNGVoice.Sub_status__c = 'Active';
        subsNGVoice.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294g';
        subsNGVoice.csordtelcoa__Product_Configuration__c = pc.id;
        lstSub.add(subsNGVoice);

        csord__Subscription__c subsIOT =new csord__Subscription__c();
        subsIOT.name  = 'IOT testSubscription';
        subsIOT.csord__Identification__c = 'testIdentity';
        subsIOT.csord__Order__c = ord1.Id;
        subsIOT.Sub_status__c = 'Active';
        subsIOT.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804295e';
        subsIOT.csordtelcoa__Product_Configuration__c = pc4.id;
        lstSub.add(subsIOT);
    
        csord__Subscription__c subOut = new csord__Subscription__c();////EDGE-209293 chown order
        subOut.csord__Identification__c = 'Subscription_1';
        subOut.csordtelcoa__Product_Configuration__c = configOut.id;
        subOut.name = 'Test Outgoing Subscription';
        subOut.csordtelcoa__Replacement_Subscription__c = null;
        subOut.csord__Order__c = ord2.Id;
        lstSub.add(subOut);
        
        csord__Subscription__c subIn = new csord__Subscription__c();//EDGE-209293 chown order
        subIn.csord__Identification__c = 'Subscription_2';
        subIn.csordtelcoa__Product_Configuration__c = configIn.id;
        subIn.name = 'Test Incoming Subscription';
        subIn.csordtelcoa__Replaced_Subscription__c = null;
        subIn.csord__Order__c = ord3.Id;
        lstSub.add(subIn);

        insert lstSub;
        
        List<csord__Service__c> servLst = new List<csord__Service__c>();
        csord__Service__c serv1 = ProductTestFactory.buildService('V_Service',ord.Id,subs.Id,ordReq.Id);
        servLst.add(serv1);

        csord__Service__c serv2 = ProductTestFactory.buildService('IOT_Service',ord1.Id,subsIOT.Id,ordReq1.Id);
        serv2.csordtelcoa__Product_Configuration__c = pc4.Id;
        serv2.serviceMSISDN__c='';
        servLst.add(serv2);
        
        //Modified by Aman Soni as a part of EDGE-142085 || Start
        csord__Service__c serv = new csord__Service__c();
        serv.name ='IP Network';
        serv.csord__Identification__c  = '1234';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Status__c = 'Service Created';
        serv.substage__c = 'Product Activation and Testing';
        serv.stage__c = 'Being Fulfilled';
        serv.csord__Order_Request__c = ordReq.Id;
        serv.csord__Order__c = ord.Id;
        serv.csordtelcoa__Product_Configuration__c = pc2.Id;
        serv.Transition_Id__c = 'Transition Number';//INC000092427869
        serv.csordtelcoa__Service_Number__c = '6142345678';
        serv.serviceMSISDN__c='6142345678';
        serv.csoe__Quantity_Decomposition_JSON__c = '{"jsonEntities":{"a792O00000000pXQAQ":"28c8f805-8d7f-2db6-a310-1b2f0f706c10"},"configurations":{}}';
        serv.NetworkServiceId__c = 'Test';
        serv.autoExpiry__c = true;
        serv.csord__service__c = serv1.Id;
        serv.TechnologyType__c = 'Mobile Access';
        //serv.modelChange__c = false;
        serv.Appointment_Required__c = 'true';
        serv.csordtelcoa__Replaced_Service__c = serv1.Id;
        servLst.add(serv);
        
        system.debug('serv+++' +serv);
        csord__Service__c servOut = new csord__Service__c();//EDGE-209293 chown order
        servOut.csordtelcoa__Product_Configuration__c = configOut.id;
        servOut.csord__Subscription__c = subOut.id;
        servOut.csord__Identification__c = 'Service_0';
        servOut.name = 'Test Outgoing Service';
        servLst.add(servOut);
        
        csord__Service__c servIn = new csord__Service__c();//EDGE-209293 chown order
        servIn.csordtelcoa__Product_Configuration__c = configIn.id;
        servIn.csord__Subscription__c = subIn.id;
        servIn.csord__Identification__c = 'Service_1';
        servIn.csordtelcoa__Replaced_Service__c = null;
        servIn.name = 'Test Incoming Service';
        servLst.add(servIn);
        insert servLst;
              
        //Modified by Aman Soni as a part of EDGE-142085 || End
        
        //Modified by Aman Soni as a part of EDGE-142085 || Start
        List<Service_Specification__c> servSpecLst = new List<Service_Specification__c>();
        Service_Specification__c servSpec=new Service_Specification__c();
        servSpec.Name='Test_servSpec';
        servSpec.Service__c=serv1.id;
        servSpec.Code__c='DMCAT_ProductSpecification_000263';
        servSpecLst.add(servSpec);
        
        Service_Specification__c servSpec1=new Service_Specification__c();
        servSpec.Name='Test_servSpec1';
        servSpec.Service__c=serv.id;
        servSpec.Code__c='DMCAT_ProductSpecification_000263';
        servSpecLst.add(servSpec1);

        Service_Specification__c servSpec2=new Service_Specification__c();
        servSpec2.Name='Test_servSpec1';
        servSpec2.Service__c=serv.id;
        servSpec2.Code__c='DMCAT_ProductSpecification_000264';
        servSpecLst.add(servSpec2);
        insert servSpecLst;
        //Modified by Aman Soni as a part of EDGE-142085 || End     
        
        csoe__Non_Commercial_Schema__c ncs=new csoe__Non_Commercial_Schema__c();
        ncs.name='MobileNumberManagementv1';
        ncs.csoe__Description__c='MobileNumberManagementv1';
        ncs.csoe__Schema__c='{"attributes":[{"showInUI":true,"required":false,"type":"String","name":"MobileNumber"},{"showInUI":true,"required":false,"type":"String","name":"Status"},{"showInUI":true,"required":false,"type":"String","name":"listCode"}],"name":"MobileNumberManagementv1","description":"Mobile numbers"}';
        insert ncs;
        
        String numberNCS='{"configurations":[{"listCode":"No Entry Line","Status":"RESERVED","MobileNumber":"61419454013","guid":"fab7227a-c952-8c93-2dc9-76c548bd4dcf"}],"schema":{"name":"MobileNumberManagementv1","id":"a792O00000001TSQAY","attributes":[{"type":"String","showInUI":true,"required":false,"name":"MobileNumber"},{"type":"String","showInUI":true,"required":false,"name":"Status"},{"type":"String","showInUI":true,"required":false,"name":"listCode"}]}}'; 
        
        //Modified by Aman Soni as a part of EDGE-142085 || Start
        List<Attachment> attachmentLst = new List<Attachment>();
        Attachment attach=new Attachment();
        attach.Body=Blob.valueOf(testSpecification.csedm__Value__c);
        attach.Name='ServiceSpecifications.json';
        attach.ContentType='Attachment';
        attach.ParentID=serv1.id;
        attachmentLst.add(attach);
        
        Attachment attach1=new Attachment();
        attach1.Body=Blob.valueOf(testSpecification.csedm__Value__c);
        attach1.Name='ServiceSpecifications.json';
        attach1.ContentType='Attachment';
        attach1.ParentID=serv.id;
        attachmentLst.add(attach1);
        
        Attachment attachPC=new Attachment();
        attachPC.Body=Blob.valueOf(numberNCS);
        attachPC.Name='MobileNumberManagementv1_schema.json';
        attachPC.ContentType='Attachment';
        attachPC.ParentID=pc3.id;
        attachmentLst.add(attachPC);        
        insert attachmentLst;
        //Modified by Aman Soni as a part of EDGE-142085 || End
        
        //Modified by Aman Soni as a part of EDGE-142085 || Start
        List<Number__c> numbLst = new List<Number__c>();
        Number__c numObj = new Number__c();
        numObj.Name = 'Num1';
        numObj.Product_Configuration__c = pc2.Id;
        numObj.Service_Id__c = serv.Id;
        numObj.Service_Number__c = serv.csordtelcoa__Service_Number__c;
        numObj.Type__c = 'Transition';
        numObj.Transition_Id__c = 'Transition Number';//INC000092427869
        numObj.Status__c = 'Disconnect Pending';
        numbLst.add(numObj);
        
        Number__c numObj2 = new Number__c();
        numObj2.Name = 'Num2';
        numObj2.Product_Configuration__c = pc2.Id;
        numObj2.Service_Id__c = serv.Id;
        numObj2.Service_Number__c = serv.csordtelcoa__Service_Number__c;
        numObj2.Type__c = 'Port In';
        numObj2.Transition_Id__c = 'Transition Number';//INC000092427869
        numObj2.Sim_Serial_Number__c = '89610185000014921507';//EDGE-148457
        numObj2.Basket__c = basket.Id;
        numbLst.add(numObj2);
        insert numbLst;
        //Modified by Aman Soni as a part of EDGE-142085 || End
       
        Service_Qualification__c sqr1 = new Service_Qualification__c();
        sqr1.Name = 'sqr1';
        sqr1.Account__c = testAccount.id;
        sqr1.Service_Number__c = numObj2.Service_Number__c;//serv.csordtelcoa__Service_Number__c;
        sqr1.SQ_Type__c = 'Port in SQ';
        sqr1.Incumbent_Account_Number__c = '3545654656';
        sqr1.Incumbent_Carrier__c='Vodafone';
        sqr1.Portability_Status__c = 'Y';
        sqr1.Basket_id__c = basket.Id;
        insert sqr1;
        System.assertEquals(true,true);
        
        ContractJunction__c testContract    =   new ContractJunction__c();
        testContract.Account__c             =   basket.csbb__Account__c;
        testContract.BSA_Generated__c       =   true;
        testContract.Related_Opportunity__c =   basket.cscfga__Opportunity__c;
        testContract.Related_Basket__c      =   basket.id;
        insert testContract;

        List<CSPOFA__Orchestration_Process_Template__c> processTempList =   Orchestration_TestUtility.buildProcessTemplate(false,1);
        processTempList[0].name = 'Order Prerequisite Process';
        insert processTempList;

        List<Migration_Change_Request__c> mcrLst = new List<Migration_Change_Request__c>();
        Migration_Change_Request__c mcr = new Migration_Change_Request__c();
        mcr.migration_status__c = 'Completed';
        String basketOutId = basketOut.id;
        String basketInId = basketIn.id;
        String basketMACId = basketOutId+','+basketInId;
        mcr.macd_basket_ids__c = basketMACId;
        mcr.target_account__c = accIn.id;
        mcr.account_id__c = accOut.id;
        mcrLst.add(mcr);
        insert mcrLst;
   }
 
   @isTest
   static void testMethod01() {
        Map<Id, csord__Order__c> orderMap = new Map<Id, csord__Order__c>([SELECT Id FROM    csord__Order__c where csordtelcoa__Opportunity__r.Type!='CHOWN']);
        Map<Id, csord__Subscription__c> subMap = new Map<Id, csord__Subscription__c>([SELECT Id FROM csord__Subscription__c where csord__Order__c IN:orderMap.keyset()]);
        Map<Id, csord__Service__c> servMap = new Map<Id, csord__Service__c>([SELECT Id FROM csord__Service__c where csord__Subscription__c IN: subMap.keyset()]);
        List<Id> subscriptionIds = new List<Id>(subMap.keySet());
        List<Id> orderIds = new List<Id>(orderMap.keySet());
        List<Id> serviceIds = new List<Id>(servMap.keySet());
        Test.startTest();
        csordcb.ObserverApi.Observable o;
        /*OrderPostProcessing observer = new OrderPostProcessing();
        csordtelcoa.OrderGenerationObservable o = new csordtelcoa.OrderGenerationObservable(
        'OrderPostProcessing',
        null,
        orderIds,
        subscriptionIds,
        serviceIds,
        null,
        null,
        null,
        null,
        null
        );
        csordcb.ObserverApi.Observable o2;
        OrderPostProcessing observer2 = new OrderPostProcessing(o2);*/
        //observer.execute(o, null);
        Database.executeBatch(new OrderPostProcessing(o,subscriptionIds), 200);
        Test.stopTest();
        List<csord__Order__c> orderList = [SELECT Id, csord__Status2__c FROM csord__Order__c where csordtelcoa__Opportunity__r.Type!='CHOWN'];
        System.assert(orderList[0].csord__Status2__c.Contains('Order Decomposition Failed'));
        System.assert(orderList[1].csord__Status2__c.Contains('Order Decomposition Failed'));
   }

   //EDGE-209293
   @isTest
   static void testMethodCHOWN() {
        Test.startTest();
        Map<Id, csord__Order__c> orderMap = new Map<Id, csord__Order__c>([SELECT Id FROM    csord__Order__c where csordtelcoa__Opportunity__r.Type='CHOWN']);
        Map<Id, csord__Subscription__c> subMap = new Map<Id, csord__Subscription__c>([SELECT Id FROM csord__Subscription__c where csord__Order__c IN:orderMap.keyset()]);
        Map<Id, csord__Service__c> servMap = new Map<Id, csord__Service__c>([SELECT Id FROM csord__Service__c where csord__Subscription__c IN: subMap.keyset()]);
        List<Id> subscriptionIds = new List<Id>(subMap.keySet());
        List<Id> orderIds = new List<Id>(orderMap.keySet());
        List<Id> serviceIds = new List<Id>(servMap.keySet());
        /*OrderPostProcessing observer = new OrderPostProcessing();
        csordtelcoa.OrderGenerationObservable o = new csordtelcoa.OrderGenerationObservable(
        'OrderPostProcessing',
        null,
        orderIds,
        subscriptionIds,
        serviceIds,
        null,
        null,
        null,
        null,
        null
        );
        csordcb.ObserverApi.Observable o2;
        OrderPostProcessing observer2 = new OrderPostProcessing(o2);
        observer.execute(o, null);*/
        csordcb.ObserverApi.Observable o;
        
        new OrderPostProcessing(o,null,subscriptionIds);
        new OrderPostProcessing(o);
        Database.executeBatch(new OrderPostProcessing(o,subscriptionIds), 200);
        Test.stopTest();
        List<csord__Order__c> orderList = [SELECT Id, csord__Status2__c FROM csord__Order__c];
        System.assert(orderList[0].csord__Status2__c.Contains('Order Decomposition Failed'));
   } 
 }