@isTest
public class UpdateParentSpecAttEvent_test{
    @testSetup public static void setup() {
        Profile p=   [Select Name, Id From Profile where Name='Migration BOH user'];
        User migrationUser = new User(alias = 'migBoh', email='migrationBOHUser@test.com',
                                      emailencodingkey='UTF-8', lastname='BOHUser', languagelocalekey='en_US',
                                      localesidkey='en_US', profileid =p.id, country='United States',IsActive =true,                
                                      timezonesidkey='America/Los_Angeles', username='migrationBOHUser@test.com');
        insert migrationUser;
        
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
        
        //Modified by Aman Soni as a part of EDGE-142085 || End
        List<Opportunity>opportunityList=new List<Opportunity>();
        Opportunity testOpp = new Opportunity();
        testOpp.AccountId = testAccount.Id;
        testOpp.Name = 'Test Account Opportunity';
        testOpp.StageName = 'Develop';
        testOpp.CloseDate = System.Date.today();
        testOpp.RetiedAccOpp__c = true;
        opportunityList.add(testOpp);
        
        /*Opportunity testOppCHOWN = new Opportunity();
        testOppCHOWN.AccountId = testAccount.Id;
        testOppCHOWN.Name = 'Test CHOWN Opportunity';
        testOppCHOWN.StageName = 'Develop';
        testOppCHOWN.CloseDate = System.Date.today();
        testOppCHOWN.RetiedAccOpp__c = true;
        //testOppCHOWN.Type='CHOWN';
        opportunityList.add(testOppCHOWN);
        
        Opportunity migrationOpp = new Opportunity();
        system.runAs(migrationUser){
            
            migrationOpp.AccountId = testAccount.Id;
            migrationOpp.Name = 'Migration Opportunity';
            migrationOpp.Product_Domain__c = 'Other';
            migrationOpp.StageName = 'Develop';
            migrationOpp.Product_Type__c = 'Modular';
            migrationOpp.CloseDate = System.Date.today();
            migrationOpp.Description__c = 'test';   
            migrationOpp.Type = 'Migration';
            insert migrationOpp;
        }*/
        insert opportunityList;
        
        /*List<cscrm__Address__c> lstAddress = new List<cscrm__Address__c>();
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
        insert lstSite;*/
        
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>();
        cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(
            Name = 'IP Site',
            cscfga__Description__c = 'PD1 Desc',
            Snapshot_Object__c ='CS_Basket_Snapshot_Transactional__c',
            product_Specification__c = Label.MobilitySpecCode
        );
        pd.isDesignTimeParent__c = true;
        pdList.add(pd);
        
        /*cscfga__Product_Definition__c pdIOTSub = new cscfga__Product_Definition__c(
            Name = 'IOT Subscription',
            cscfga__Description__c = 'PD2 Desc',
            Snapshot_Object__c ='CS_Basket_Snapshot_Transactional__c',
            product_Specification__c = Label.MobilitySpecCode
        );
        pdList.add(pdIOTSub);
        
        cscfga__Product_Definition__c adaptivecarePD = new cscfga__Product_Definition__c();
        adaptivecarePD.Name = 'Adaptive Care';
        adaptivecarePD.cscfga__Description__c = 'Adaptive Care';
        adaptivecarePD.product_Specification__c ='DMCAT_ProductSpecification_001252';
        pdList.add(adaptivecarePD);*/
        insert pdList;
        
        csedm__Specification__c testSpecification = new csedm__Specification__c(
            Name = Label.MobilitySpecCode, csedm__Active__c= true, csedm__identifier__c='testIdentif',
            //  csedm__Product_Definition__c = pd.Id,  // Spring 20 commented
            csedm__Source__c = pd.Id,   // Spring 20
            csedm__Value__c  = '{ "code": "DMCAT_ProductSpecification_000263",'
            +'"specifications" : [{"additionalAttributes":{},"attributes" : {"rangeFrom":"501","rangeTo":"99999",'
            +'"price":"3.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000813_6976"},'
            +'"code":"DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000813","guid":"648990ee-38b0-8e51-8048-e22a787a0240"}],'
            + '"name": "Mobility_Billing_Allowance_000484_1", "description": "",  "cpqAttributes": {},'
            + ' "attributes": {   "__targetSystem": {"value": "FULFILMENT","type": "string"},"billingSpecId": {"value": "BSUSG001_CB","type": "string"},'
            + ' "ocsProdID": {"value": "ocsProd1","type": "string"},"type": {"value": "Domestic Data","type": "string"},'
            + '"unitofMeasure": {"value": "GB","type": "string"},"value": {"value": "50","type": "string"}}, "nonCommercialAttributes": []} '
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
        
        /*cscfga__Attribute_Definition__c ad3 = new cscfga__Attribute_Definition__c(
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
        );*/
        
        lstAttributeDef.add(ad);
        lstAttributeDef.add(ad1);
        lstAttributeDef.add(ad2);
        //lstAttributeDef.add(ad3);
        //lstAttributeDef.add(ad4);
        
        insert lstAttributeDef;
        
        List<cscfga__Product_Basket__c> basketList = new List<cscfga__Product_Basket__c>();
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(
            Name = 'Test Account Opportunity Basket1',
            OwnerId = UserInfo.getUserId(),
            cscfga__Opportunity__c = testOpp.Id,
            csbb__Account__c = testAccount.Id,
            csordtelcoa__Basket_Stage__c = 'Quote'
        );
        basket.csordtelcoa__Basket_Stage__c = 'Enriched';
        cscfga__Product_Basket__c basketIOT = new cscfga__Product_Basket__c(
            Name = 'Test Account Opportunity Basket2',
            OwnerId = UserInfo.getUserId(),
            cscfga__Opportunity__c = testOpp.Id,
            csbb__Account__c = testAccount.Id,
            csordtelcoa__Basket_Stage__c = 'Quote'
        );
        /*cscfga__Product_Basket__c migrationBasket = new cscfga__Product_Basket__c(
            Name = 'Migration Basket',
            OwnerId = UserInfo.getUserId(),
            cscfga__Opportunity__c = migrationOpp.Id,
            csbb__Account__c = testAccount.Id,
            csordtelcoa__Basket_Stage__c = 'Enriched'
        );
        cscfga__Product_Basket__c basketCHOWNOut = new cscfga__Product_Basket__c(
            Name = 'CHOWN Out Basket',
            OwnerId = UserInfo.getUserId(),
            cscfga__Opportunity__c = testOppCHOWN.Id,
            csbb__Account__c = testAccount.Id,
            csordtelcoa__Basket_Stage__c = 'Enriched',
            BasketType__c = 'Outgoing'
        );*/
        basketList.add(basket);
        basketList.add(basketIOT);
        //basketList.add(migrationBasket);
        //basketList.add(basketCHOWNOut);
        insert basketList;
        
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
        /*cscfga__Product_Configuration__c pc4    =   new cscfga__Product_Configuration__c();
        pc4.cscfga__Product_Definition__c       =   pdIOTSub.Id;   
        pc4.cscfga__Product_Basket__c           =   basketIOT.Id;
        pc4.Marketable_Offer__c                 =   marktoffer1.id;
        pc4.Offer_Reference__c                  =   offer1.id;
        pc4.ConfigurationType1__c               =   'SolutionComponent';
        pc4.Name                                =   'IOT Subscription';
        lstpc.add(pc4);
        
        cscfga__Product_Configuration__c pc5    =   new cscfga__Product_Configuration__c();
        pc5.cscfga__Product_Definition__c       =   adaptivecarePD.Id;   
        pc5.cscfga__Product_Basket__c           =   migrationBasket.Id;
        pc5.Marketable_Offer__c                 =   marktoffer1.id;
        pc5.Offer_Reference__c                  =   offer1.id;
        pc5.ConfigurationType1__c               =   'SolutionComponent';
        pc5.Name                                =   'Migration Subscription';
        pc5.subType__c                          =   'Migration';
        lstpc.add(pc5);
        
        cscfga__Product_Configuration__c pc6    =   new cscfga__Product_Configuration__c();
        pc6.cscfga__Product_Definition__c       =   pd.Id;   
        pc6.cscfga__Product_Basket__c           =   basketCHOWNOut.Id;
        pc6.Marketable_Offer__c                 =   marktoffer1.id;
        pc6.Offer_Reference__c                  =   offer1.id;
        pc6.ConfigurationType1__c               =   'SolutionComponent';
        lstpc.add(pc6);
        
        cscfga__Product_Configuration__c pc7    =   new cscfga__Product_Configuration__c();
        pc7.cscfga__Product_Definition__c       =   pd.Id;   
        pc7.cscfga__Product_Basket__c           =   basketCHOWNOut.Id;
        pc7.Marketable_Offer__c                 =   marktoffer1.id;
        pc7.Offer_Reference__c                  =   offer1.id;
        lstpc.add(pc7);*/
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
        
        /*cscfga__Attribute__c att3 = new cscfga__Attribute__c(
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
        );*/
        
        lstAttribute.add(att);
        lstAttribute.add(att0);
        lstAttribute.add(att1);
        //lstAttribute.add(att3);
        //lstAttribute.add(att4);
        
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
        //lstBasketMap.add(new Basket_To_Order_Field_Map__c(Name='partnerAccount__c',Source_Object_API_Name__c='csord__Subscription__c',Target_Object_API_Name__c='csord__Subscription__c',Source_Field_API_Name__c='csord__Order__r.csordtelcoa__Opportunity__r.PartnerAccountId',Target_Field_API_Name__c='partnerAccount__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Name='Action_Type__c',Source_Object_API_Name__c='csord__Service__c',Target_Object_API_Name__c='csord__Subscription__c',Source_Field_API_Name__c='Action_Type__c',Target_Field_API_Name__c='Action_Type__c'));
        
        insert lstBasketMap;
        
        List<csord__Order_Request__c> ordReqList = new List<csord__Order_Request__c>();
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        ordReqList.add(ordReq);
        csord__Order_Request__c ordReq1 = ProductTestFactory.buildOrderRequest();
        ordReqList.add(ordReq1);
        insert ordReqList;
        
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', testAccount.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        ord.csordtelcoa__Opportunity__c =testOpp.id;
        orderList.add(ord);
        csord__Order__c ord1 = ProductTestFactory.buildOrder('TestOrder1', testAccount.id, 'Created', ordReq1.id);
        ord1.csord__Order_Request__c = ordReq1.Id;
        //ord1.csordtelcoa__Opportunity__c =testOpp.id;
        orderList.add(ord1);
        /*csord__Order__c ord2 = ProductTestFactory.buildOrder('TestNonCommercial', testAccount.id, 'Created', ordReq1.id);
        ord2.csord__Order_Request__c = ordReq1.Id;
        orderList.add(ord2);
        csord__Order__c ord3 = ProductTestFactory.buildOrder('Test Migration', testAccount.id, 'Created', ordReq1.id);
        ord3.csord__Order_Request__c = ordReq1.Id;
        ord3.csordtelcoa__Opportunity__c=migrationOpp.id;
        orderList.add(ord3);
        csord__Order__c ord4 = ProductTestFactory.buildOrder('TestOrderCHOWN', testAccount.id, 'Created', ordReq1.id);
        ord4.csord__Order_Request__c = ordReq1.Id;
        ord4.csordtelcoa__Opportunity__c =testOppCHOWN.id;
        orderList.add(ord4);*/
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
        
        /*csord__Subscription__c subsIOT =new csord__Subscription__c();
        subsIOT.name  = 'IOT testSubscription';
        subsIOT.csord__Identification__c = 'testIdentity';
        subsIOT.csord__Order__c = ord1.Id;
        subsIOT.Sub_status__c = 'Active';
        subsIOT.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804295e';
        subsIOT.csordtelcoa__Product_Configuration__c = pc4.id;
        lstSub.add(subsIOT);
        
        /*csord__Subscription__c subsnonCom =new csord__Subscription__c();
        subsnonCom.name  = 'Noncom';
        subsnonCom.csord__Identification__c = 'NonCom';
        subsnonCom.csord__Order__c = ord2.Id;
        subsnonCom.Sub_status__c = 'Pending';
        subsnonCom.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804295e';
        subsnonCom.csordtelcoa__Product_Configuration__c = pc4.id;
        lstSub.add(subsnonCom);
        
        csord__Subscription__c migrationSub =new csord__Subscription__c();
        migrationSub.name  = 'Migration Subscription';
        migrationSub.csord__Identification__c = 'Migration';
        migrationSub.csord__Order__c = ord3.Id;
        migrationSub.Sub_status__c = 'Pending';
        migrationSub.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804295e';
        migrationSub.csordtelcoa__Product_Configuration__c = pc5.id;
        lstSub.add(migrationSub);
        
        csord__Subscription__c chownSub =new csord__Subscription__c();
        chownSub.name  = 'CHOWN Subscription';
        chownSub.csord__Identification__c = 'CHOWN';
        chownSub.csord__Order__c = ord4.Id;
        chownSub.Sub_status__c = 'Pending';
        chownSub.csordtelcoa__Product_Configuration__c = pc6.id;
        lstSub.add(chownSub);*/
        insert lstSub;
        
        List<csord__Service__c> servLst = new List<csord__Service__c>();
        csord__Service__c serv1 = ProductTestFactory.buildService('V_Service',ord.Id,subs.Id,ordReq.Id);
        serv1.csordtelcoa__Product_Configuration__c = pc.id;
        servLst.add(serv1);
        
        csord__Service__c serv2 = ProductTestFactory.buildService('IOT_Service',ord.Id,subs.Id,ordReq.Id);
        serv2.csordtelcoa__Product_Configuration__c = pc.Id;
        serv2.serviceMSISDN__c='';
        serv2.Action_Type__c = 'PayOut';
        servLst.add(serv2);
        
        csord__Service__c servNonCom = ProductTestFactory.buildService('nonCom',ord.Id,subs.Id,ordReq.Id);
        servNonCom.csordtelcoa__Product_Configuration__c = pc.Id;
        servNonCom.serviceMSISDN__c='';
        servLst.add(servNonCom);
        
        /*csord__Service__c migrationService = ProductTestFactory.buildService('Migration',ord3.Id,migrationSub.Id,ordReq1.Id);
        migrationService.csordtelcoa__Product_Configuration__c = pc5.Id;
        migrationService.serviceMSISDN__c='';
        servLst.add(migrationService);
        
        csord__Service__c chownService = ProductTestFactory.buildService('CHOWN_Service',ord4.Id,chownSub.Id,ordReq1.Id);
        chownService.csordtelcoa__Product_Configuration__c = pc6.Id;
        chownService.serviceMSISDN__c='';
        servLst.add(chownService);
        
        csord__Service__c chownService1 = ProductTestFactory.buildService('CHOWN_Service',ord4.Id,chownSub.Id,ordReq1.Id);
        chownService1.csordtelcoa__Product_Configuration__c = pc7.Id;
        chownService1.serviceMSISDN__c='';
        servLst.add(chownService1);
        
        csord__Service__c testService = ProductTestFactory.buildService('NofaultRet',ord4.Id,chownSub.Id,ordReq1.Id);
        testService.csordtelcoa__Product_Configuration__c = pc7.Id;
        testService.serviceMSISDN__c='';
        //testService.Action_Type__c = 'No Fault Return';
        servLst.add(testService);*/
        
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
        serv.csordtelcoa__Product_Configuration__c = pc.Id;
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
        numObj.Product_Configuration__c = pc1.Id;
        numObj.Service_Id__c = serv.Id;
        numObj.Service_Number__c = serv.csordtelcoa__Service_Number__c;
        numObj.Type__c = 'Transition';
        numObj.Transition_Id__c = 'Transition Number';//INC000092427869
        numObj.Status__c = 'Disconnect Pending';
        numObj.SimAvailabilityType__c='Existing Blank SIM';
        numbLst.add(numObj);
        
        Number__c numObj2 = new Number__c();
        numObj2.Name = 'Num2';
        numObj2.Product_Configuration__c = pc.Id;
        numObj2.Service_Id__c = serv.Id;
        numObj2.Service_Number__c = serv.csordtelcoa__Service_Number__c;
        numObj2.Type__c = 'Port In';
        numObj2.Transition_Id__c = 'Transition Number';//INC000092427869
        numObj2.Sim_Serial_Number__c = '89610185000014921507';//EDGE-148457
        numObj2.Basket__c = basket.Id;
        numbLst.add(numObj2);
        
        Number__c numObj3 = new Number__c();
        numObj3.Name = 'Num3';
        numObj3.Product_Configuration__c = pc.Id;
        numObj3.Service_Id__c = serv1.csordtelcoa__Service_Number__c;
        numObj3.Service_Number__c = '56854521551';
        numObj3.Type__c = 'New';
        numObj3.Sim_Serial_Number__c = '89610185000014921507';//EDGE-148457
        numObj3.Basket__c = basket.Id;
        numObj3.IMSI__c = '586412354154581511';
        numbLst.add(numObj3);
        
        /*Number__c numObj4 = new Number__c();
        numObj4.Name = 'Num4';
        numObj4.Product_Configuration__c = pc5.Id;
        numObj4.Service_Id__c = migrationService.csordtelcoa__Service_Number__c;
        numObj4.Service_Number__c = '56854521153';
        numObj4.Type__c = 'New';
        numObj4.Sim_Serial_Number__c = '89610185000014921153';//EDGE-148457
        numObj4.Basket__c = migrationbasket.Id;
        numObj4.IMSI__c = '586412354154581153';
        numbLst.add(numObj4);
        
        Number__c numObj5 = new Number__c();
        numObj5.Name = 'Num5';
        numObj5.Product_Configuration__c = pc5.Id;
        numObj5.Service_Id__c = migrationService.csordtelcoa__Service_Number__c;
        numObj5.Service_Number__c = '56854521157';
        numObj5.Type__c = 'Port In';
        numObj5.Sim_Serial_Number__c = '89610185000014921103';//EDGE-148457
        numObj5.Basket__c = migrationbasket.Id;
        numObj5.IMSI__c = '586412354154581103';
        numbLst.add(numObj5);*/
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
        //System.assertEquals(true,true);
        
        ContractJunction__c testContract    =   new ContractJunction__c();
        testContract.Account__c             =   basket.csbb__Account__c;
        testContract.BSA_Generated__c       =   true;
        testContract.Related_Opportunity__c =   basket.cscfga__Opportunity__c;
        testContract.Related_Basket__c      =   basket.id;
        insert testContract;
        
        List<CSPOFA__Orchestration_Process_Template__c> processTempList =   Orchestration_TestUtility.buildProcessTemplate(false,1);
        processTempList[0].name = 'Order Pre Requisite PE Process';
        insert processTempList;
        
        Billing_Account__c billingAccount=TestDataFactory.generateBillingAccount('700000335518','Created',testAccount.id, scontact.id);
        billingAccount.OwnerId=migrationUser.id;
        insert billingAccount;
        
        /*
        cscfga__Product_Definition__c productDefinition = new cscfga__Product_Definition__c();
        productDefinition.Name = 'Enterprise Mobility Plan';
        productDefinition.cscfga__Description__c = 'Enterprise Mobility Plan';
        productDefinition.product_Specification__c = 'DMCAT_ProductSpecification_001252';
        insert productDefinition;
        
        cscfga__Product_Configuration__c productConfig = new cscfga__Product_Configuration__c();
        productConfig.name='Enterprise Mobility Managed Service';
        productConfig.Type__c='New';
        productConfig.ConfigurationType1__c = 'SolutionComponent';
        productConfig.Quantity_Product_Configuration__c = 111;
        productConfig.cscfga__Product_Definition__c=productDefinition.id;
        insert productConfig;
        
        csord__Order__c Order=TestDataFactory.generateOrder(testAccount.id,'Order Submitted','Order Submitted','Order','Order_456',system.today(),'Mobile Device Replacement','Test Order','Device_replace',UserInfo.getUserId());
        order.csordtelcoa__Opportunity__c=migrationOpp.id;
        insert Order;
        
        csord__Subscription__c subscription=TestDataFactory.generateSubscription();
        subscription.csord__Status__c='Active';
        subscription.csord__Order__c=Order.id;
        subscription.csord__Account__c=testAccount.id;
        subscription.Billing_Account__c=billingAccount.id;
        subscription.csordtelcoa__Product_Configuration__c = productConfig.id;
        Update subscription;
        
        cspmb__Price_Item__c maincharge = new cspmb__Price_Item__c();
        maincharge.Name = 'Enterprise Mobility';
        maincharge.cspmb__Price_Item_Code__c = 'Enterprise Mobility';
        maincharge.cspmb__Product_Definition_Name__c = 'Enterprise Mobility';
        maincharge.cspmb__Is_Active__c = true;
        maincharge.Type__c = 'Handheld'; 
        insert maincharge;
        
        List<csord__Service__c> serviceList=new List<csord__Service__c>();
        csord__Service__c service=new csord__Service__c();
        service.csordtelcoa__Product_Configuration__c = productConfig.id;
        service.mainCharge__c = maincharge.id; 
        service.name ='Handheld';
        service.csord__Identification__c = productConfig.id;
        service.csord__Subscription__c=subscription.id;
        service.Billing_Account__c=billingAccount.id;
        insert service;
        
        csord__Service__c service2=TestDataFactory.generateService();
        service2.csordtelcoa__Product_Configuration__c = productConfig.id;
        service2.name ='Adaptive Mobility';
        service2.csord__Subscription__c=subscription.id;
        serviceList.add(service2);
        update serviceList;*/
        
        List<BDS_Notify_Settings__c> csList = new List<BDS_Notify_Settings__c>(); //EDGE-170552
        BDS_Notify_Settings__c bdscustomSetting1 = new BDS_Notify_Settings__c();
        bdscustomSetting1.name='Feature Level';
        bdscustomSetting1.Value__c ='FeatureLevelShadow';
        bdscustomSetting1.Is_SI5_Offer__c =true;
        csList.add(bdscustomSetting1);
        
        BDS_Notify_Settings__c bdscustomSetting2 = new BDS_Notify_Settings__c(); //EDGE-170552
        bdscustomSetting2.name='Technical Support';
        bdscustomSetting2.Value__c ='TechnicalSupportShadow';
        bdscustomSetting2.Is_SI5_Offer__c =true;
        csList.add(bdscustomSetting2);
        
        insert csList;
        
        
    }
    
    
    @isTest static void testMethodtoCoverHelper6() { 
        /*List<cscfga__Product_Definition__c> listOfPD = [SELECT Id, isDesignTimeParent__c FROM cscfga__Product_Definition__c];
        for(cscfga__Product_Definition__c pd : listOfPD){
            pd.isDesignTimeParent__c = true;
        }
        update listOfPD;*/
        List<String> createTemplate = New List<String>();
        
        List<Basket_To_Order_Field_Map__c> bksOrderMappingList  =   Basket_To_Order_Field_Map__c.getall().values();
        Account acc = [SELECT Id FROM Account WHERE Name='TestAccount']; 
        List<csord__Order__c> orderlst = [SELECT Id, csordtelcoa__Opportunity__c FROM csord__Order__c Where csordtelcoa__Opportunity__c != null];
        Set<id> orderIds = new Set<Id>();
        Map<Id,csord__Order__c> ordChownMap = New Map<Id,csord__Order__c> ();
        for(csord__Order__c objOrder: orderlst){
            orderIds.add(objOrder.Id);
            ordChownMap.put(objOrder.Id, objOrder);
            createTemplate.add(objOrder.Id);
        }
        system.assert(!orderIds.isEmpty()); 
        List<Id> lStrings = new List<Id>(orderIds);
        OrchestrationCacheBackupHelper.createPreReqProcessTemp(lStrings);
        List<csord__Service__c> servList = [SELECT Id,Appointment_Required__c,modelChange__c FROM csord__Service__c];
        Boolean flag = false;
        for(csord__Service__c oServ : servList) {
            oServ.Appointment_Required__c       =   'false';
            if(!flag){
                flag = true;
                //oServ.csord__Service__c = servList[1].Id;
                oServ.RunTimeParent__c = servList[1].Id;
            }
        }
        update servList;
        Test.startTest();
        OrderObserverManager_V2 orderObserver1 = new OrderObserverManager_V2(orderIds,bksOrderMappingList);
        Database.executeBatch(orderObserver1);
        
        OrchestrationCacheManager.get('test');
        OrchestrationCacheManager.remove('test');
        
        Map<String, Object> testMap = new Map<String, Object>();
        testMap.put('key', orderIds);
        OrchestrationCacheBackupManager.put(testMap);
        OrchestrationCacheBackupManager.get('test');
        OrchestrationCacheBackupManager.remove(new Set<String>{'test'});

        for(csord__Service__c servObj : servList) {
        OrchestrationCacheBackupHelper.processAttachment(servObj.Id, orderObserver1.cacheHandler);
        }
        //attachment == null
        BypassTrigger.isRunningTestCheck = true;
        for(csord__Service__c servObj : servList) {
        OrchestrationCacheBackupHelper.processAttachment(servObj.Id, orderObserver1.cacheHandler);
        }
        /*for(Integer i=0; i< 10; i++){
            ProcessAttachmentForOrchestration__e pfEvent = new ProcessAttachmentForOrchestration__e(Sequence__c=String.valueOf(i), ServiceIds__c=String.valueOf(servList[0].Id), PlatformCacheHandler__c=orderObserver1.cacheHandler);
            OrchestrationCacheBackupHelper.publishAttachmentProcessingEvent(pfEvent);
        }*/
        
        ManageOrdPrereqisteOrchestrationHandler.createOrchestrationProcessASYNC(createTemplate);
        ManageOrdPrereqisteOrchestrationHandler.createChownOrchestrationProcess(ordChownMap);
        Test.stopTest();
    }
}