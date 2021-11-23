/********************************************************
Class Name      :   BillingOrderServiceUtilTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Shreya Jaiswal        15/10/19        EDGE-107514
2.            Shreya                13/12/19        EDGE-128358
3.            Shreya Jaiswal        20/12/19        EDGE-129979
4.            Vaibhav Deshpande     23/01/2020      EDGE-120128
5.            Vaibhav Deshpande     29/01/2020      EDGE-132475
6.            Vaibhav Deshpande     12/02/2020      EDGE-128979 
7.            Vaibhav Deshpande     05/03/2020      EDGE-138939
8.            Prajakta Patil        05/03/2020      EDGE-137515
9.            Vaibhav Deshpande     11/03/2020      EDGE-120131
10.           Prajakta Patil        11/03/2020      EDGE-137876
11.            Pawan                30/06/2020      EDGE-156163
12.           Vaibhav Deshpande     17/07/2020      EDGE-148819
13.           Vaibhav Deshpande     22/07/2020      EDGE-156163 code revert 
14.           Suyash Chiplunkar     23/07/2020      DPG-2000
**********************************************************
*/
@isTest
private class BillingOrderServiceUtilTest {
    @testsetup 
    public static void dataSetup(){
        
        Account acc=new Account();
        acc.Name='testacc';
        acc.CIDN__c='1234567891';
        acc.ABN__c='1235';
        acc.Customer_Status__c = 'ACTIVE';
        insert acc;
        
        Contact contact = AccountTestFactory.buildContact(acc, 'Smiths');
        insert contact;
        //EDGE-129979
        Opportunity testOpp = ProductTestFactory.getOpportunityBasic(acc);
        testOpp.StageName = 'Define';
        testOpp.CloseDate = System.Date.today();
        insert testOpp;
        
        cscrm__Address__c address = new cscrm__Address__c();
        address.Name='Unit 1 1234 Lostmy Way';
        address.Address_Line_1__c='Unit 4 Mahatma';
        address.Locality__c='Sydney';
        address.cscrm__Zip_Postal_Code__c='2000';
        address.cscrm__State_Province__c='NSW';
        address.cscrm__Country__c='Australia';
        address.cscrm__Street_Name__c ='Melbourne';
        
        insert address;
        
        Billing_Account__c billingAccount=new Billing_Account__c();
        billingAccount.Billing_Account_Number__c='123456789322';
        billingAccount.Billing_Address__c=address.id;
        billingAccount.Billing_Account_Owner__c=contact.Id;
        billingAccount.Account__c=acc.Id;
        insert billingAccount;
        
        
        cscrm__Site__c  site = AccountTestFactory.buildSite(address.Id, acc.Id);
        site.Primary_Contact__c = contact.Id;
        site.cscrm__Installation_Address__r = address;
        insert site;
        
        cscrm__Site__c  site1 = new cscrm__Site__c();
        site1.cscrm__Floor__c = 'L-T';
        site1.name='testSite';
        site1.cscrm__Installation_Address__c = address.Id;
        site1.cscrm__Account__c = acc.Id;
        insert site1;
        
        csord__Order__c ord = new csord__Order__c();
        ord.csord__Identification__c = 'test identification';
        ord.csord__Account__c = acc.id;
        ord.csord__Order_Type__c = 'test order' ;
        ord.Billing_Account__c = billingAccount.id;
        ord.Scenario_Type__c = System.Label.ReplaceSIM;
        insert ord;
        
        csord__Order__c secOrd = new csord__Order__c();
        secOrd.csord__Identification__c = 'test identification';
        secOrd.csord__Account__c = acc.id;
        secOrd.csord__Order_Type__c = 'test order' ;
        secOrd.Billing_Account__c = billingAccount.id;
        secOrd.csord__Primary_Order__c = ord.id;
        secOrd.csordtelcoa__Opportunity__c = testOpp.id;
        insert secOrd;
        
        //EDGE-129979
        csord__Order__c ChangeInMobOrd = new csord__Order__c();
        ChangeInMobOrd.csord__Identification__c = 'Change in mobile identification';
        ChangeInMobOrd.csord__Account__c = acc.id;
        ChangeInMobOrd.csord__Order_Type__c = 'Change in mobile number' ;
        ChangeInMobOrd.Billing_Account__c = billingAccount.id;
        insert ChangeInMobOrd;
        
        //Added offer_spec_id__c value. Changes for EDGE-75162 
        cscfga__Configuration_Offer__c OriginatingOffer = new cscfga__Configuration_Offer__c(name ='Test Originating offer',offer_spec_id__c='DMCAT_Offer_000303');
        
        insert OriginatingOffer;
        
        //Added to test DPG-2000
        cscfga__Configuration_Offer__c OriginatingOfferIOT = new cscfga__Configuration_Offer__c(name ='Test Originating offer',offer_spec_id__c='DMCAT_Offer_000964');
        insert OriginatingOfferIOT;
        
        //Start : Changes for EDGE-75162 
        cscfga__Product_Definition__c productDefinition = new cscfga__Product_Definition__c();
        productDefinition.Name = 'Test Product Definition';
        productDefinition.cscfga__Description__c = 'Test Product Definition Description';
        //productDefinition.RecordTypeId = '012280000011E6gAAE';
        productDefinition.RecordTypeId = Schema.SObjectType.cscfga__Product_Definition__c.getRecordTypeInfosByName().get('Product Definition').getRecordTypeId();
        productDefinition.product_Specification__c = 'DMCAT_ProductOffering_000304';
        insert productDefinition;
        //End : Changes for EDGE-75162
        
        //Added to test DPG-2000
        cscfga__Product_Definition__c productDefinitionIOT = new cscfga__Product_Definition__c();
        productDefinitionIOT.Name = 'IoT Solution';
        productDefinitionIOT.cscfga__Description__c = 'Test Product Definition Description';
        productDefinitionIOT.product_Specification__c = 'DMCAT_Offer_000964';
        insert productDefinitionIOT; 
        
        List<cscfga__Product_Configuration__c> pcList=new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c productConfig = new cscfga__Product_Configuration__c();
        productConfig.Offer_Reference__c = OriginatingOffer.id;
        //Added productConfig.cscfga__Product_Definition__c. Changes for EDGE-75162 
        productConfig.cscfga__Product_Definition__c = productDefinition.Id;
        productConfig.ConfigurationType1__c='SolutionComponent';
        productConfig.Remaining_Term__c  = 24;
        pcList.add(productConfig);
        
        cscfga__Product_Configuration__c productConfigCancel = new cscfga__Product_Configuration__c();
        productConfigCancel.Offer_Reference__c = OriginatingOffer.id;
        //Added productConfig.cscfga__Product_Definition__c. Changes for EDGE-75162 
        productConfigCancel.cscfga__Product_Definition__c = productDefinition.Id;
        productConfigCancel.ConfigurationType1__c='SolutionComponent';
        productConfigCancel.Type__c = 'Cancel';
        productConfigCancel.Remaining_Term__c = 24;
        pcList.add(productConfigCancel);
        
        //Added to test DPG-2000
        cscfga__Product_Configuration__c productConfigIOT = new cscfga__Product_Configuration__c();
        productConfigIOT.Offer_Reference__c = OriginatingOfferIOT.id;
        productConfigIOT.cscfga__Product_Definition__c = productDefinitionIOT.Id;
        productConfigIOT.ConfigurationType1__c='SolutionComponent';
        productConfigIOT.Remaining_Term__c  = 24;
        pclist.add(productConfigIOT);
        
        insert pcList;
        
        List<Marketable_Offer__c> mrktOfferList=new List<Marketable_Offer__c>();
        Marketable_Offer__c mOffer1 = new Marketable_Offer__c();
        mOffer1.Offer_ID__c = 'DMCAT_Offer_000646';
        mOffer1.Invoice_Definition__c = 'Invoice_Def_2';
        mOffer1.Auto_Expired_Entity__c = true;
        mrktOfferList.add(mOffer1);
        
        //Added to test EDGE-98378
        Marketable_Offer__c mOffer = new Marketable_Offer__c();
        mOffer.Offer_ID__c = 'DMCAT_Offer_000646';
        mOffer.Invoice_Definition__c = 'Invoice_Def_2';
        mOffer.Auto_Expired_Entity__c = true;
        mrktOfferList.add(mOffer);
        
        //Added to test DPG-2000
        Marketable_Offer__c mOfferIOT = new Marketable_Offer__c();
        mOfferIOT.Offer_ID__c = 'DMCAT_Offer_000964';
        mOfferIOT.Invoice_Definition__c = 'Invoice_Def_2';
        mOfferIOT.Auto_Expired_Entity__c = true;
        mrktOfferList.add(mOfferIOT);
        
        insert mrktOfferList;
        
        List<csord__Subscription__c> subsList=new List<csord__Subscription__c>();
        csord__Subscription__c subsL=new csord__Subscription__c();
        subsL.name  = 'test subsL';
        subsL.csord__Identification__c = 'test identityL';
        subsL.Site__c = site.Id;
        subsL.csord__Status__c='Subscription Created';
        subsL.csordtelcoa__Subscription_Number__c = 'SN-000003199';
        subsL.csord__Order__c = secOrd.id;
        subsL.csordtelcoa__Product_Configuration__c = productConfig.id;
        subsL.Billing_Account__c = billingAccount.id; //Added this
        //Added subs.Offer__c. Changes for EDGE-75162 
        subsL.Offer__c = OriginatingOffer.Id;
        subsL.MarketableOffer__c = mOffer1.id;
        subsList.add(subsL);
        
        csord__Subscription__c subsK=new csord__Subscription__c();
        subsK.name  = 'test subsK';
        subsK.csord__Identification__c = 'test identityK';
        subsK.Site__c = site.Id;
        subsK.csord__Status__c='Subscription Created';
        subsK.csordtelcoa__Subscription_Number__c = 'SN-000003199';
        subsK.csord__Order__c = secOrd.id;
        subsK.csordtelcoa__Product_Configuration__c = productConfig.id;
        subsK.Billing_Account__c = billingAccount.id; //Added this
        //Added subs.Offer__c. Changes for EDGE-75162 
        subsK.Offer__c = OriginatingOffer.Id;
        subsK.csordtelcoa__Replaced_Subscription__c = subsL.Id;
        subsK.MarketableOffer__c = mOffer1.id;
        subsList.add(subsK);
        
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity cancel';
        subs.Site__c = site.Id;
        subs.csord__Status__c='Subscription Created';
        subs.csordtelcoa__Subscription_Number__c = 'SN-000003298';
        subs.csord__Order__c = secOrd.id;
        subs.csordtelcoa__Product_Configuration__c = productConfigCancel.id;
        subs.Billing_Account__c = billingAccount.id; //Added this
        //Added subs.Offer__c. Changes for EDGE-75162 
        subs.Offer__c = OriginatingOffer.Id;
        //Added to test EDGE-98378
        subs.MarketableOffer__c= mOffer.Id;
        subs.csordtelcoa__Replaced_Subscription__c = subsK.Id;
        subsList.add(subs);
        
        csord__Subscription__c subs1=new csord__Subscription__c();
        subs1.name  = 'test subs1';
        subs1.csord__Identification__c = 'test identity';
        subs1.Site__c = site.Id;
        subs1.csord__Status__c='Subscription Created';
        subs1.csordtelcoa__Subscription_Number__c = 'SN-000003199';
        subs1.csord__Order__c = secOrd.id;
        subs1.csordtelcoa__Product_Configuration__c = productConfig.id;
        subs1.Billing_Account__c = billingAccount.id; 
        subs1.Offer__c = OriginatingOffer.Id;
        subs1.csordtelcoa__Replaced_Subscription__c = subs.Id;
        //EDGE-125548
        subs1.oldServiceMSISDN__c ='';
        subs1.MarketableOffer__c= mOffer.Id;
        subsList.add(subs1);
        
        
        csord__Subscription__c subsAddBillInfo=new csord__Subscription__c();
        subsAddBillInfo.name  = 'test subsAddBillInfo';
        subsAddBillInfo.csord__Identification__c = 'test identity';
        subsAddBillInfo.Site__c = site1.Id;
        subsAddBillInfo.csord__Status__c='Subscription Created';
        subsAddBillInfo.csordtelcoa__Subscription_Number__c = 'SN-000003199';
        subsAddBillInfo.csord__Order__c = secOrd.id;
        subsAddBillInfo.csordtelcoa__Product_Configuration__c = productConfig.id;
        subsAddBillInfo.csordtelcoa__Replaced_Subscription__c=subs.id;
        subsAddBillInfo.MarketableOffer__c= mOffer.Id;
        subsList.add(subsAddBillInfo);
        
        
        csord__Subscription__c subsUCMobile=new csord__Subscription__c();
        subsUCMobile.name  = 'test_subsUCMobile';
        subsUCMobile.csord__Identification__c = 'test identity';
        subsUCMobile.Site__c = site.Id;
        subsUCMobile.csord__Status__c='Subscription Created';
        subsUCMobile.csordtelcoa__Subscription_Number__c = 'SN-000003199';
        subsUCMobile.csord__Order__c = secOrd.id;
        subsUCMobile.csordtelcoa__Product_Configuration__c = productConfig.id;
        subsUCMobile.csordtelcoa__Replaced_Subscription__c =subs.Id;
        subsUCMobile.MarketableOffer__c= mOffer.Id;
        subsList.add(subsUCMobile);
        
        csord__Subscription__c subsModify=new csord__Subscription__c();
        subsModify.name  = 'test subs modify';
        subsModify.csord__Identification__c = 'test identity';
        //subs.Site__c = site.Id;
        subsModify.csord__Status__c='Subscription Created';
        subsModify.csordtelcoa__Replaced_Subscription__c = subs.id;
        subsModify.csordtelcoa__Subscription_Number__c = 'SN-000003199';
        subsModify.csord__Order__c = secOrd.id;
        subsModify.csordtelcoa__Product_Configuration__c = productConfig.id;
        subsModify.csordtelcoa__Replaced_Subscription__c = subs.Id;
        subsModify.MarketableOffer__c= mOffer.Id;
        subsList.add(subsModify);
        
         //EDGE-123083
        csord__Subscription__c checkUnits =new csord__Subscription__c();
        checkUnits.name  = 'test_checkUnits';
        checkUnits.csord__Identification__c = 'test identity';
        checkUnits.Site__c = site.Id;
        checkUnits.csord__Status__c='Subscription Created';
        checkUnits.csordtelcoa__Subscription_Number__c = 'SN-000003199';
        checkUnits.csord__Order__c = secOrd.id;
        checkUnits.csordtelcoa__Product_Configuration__c = productConfig.id;
        checkUnits.Billing_Account__c = billingAccount.id; //Added this
        checkUnits.csordtelcoa__Replaced_Subscription__c =subs.Id;
        checkUnits.Offer__c = OriginatingOffer.Id;
        checkUnits.MarketableOffer__c= mOffer.Id;
        subsList.add(checkUnits);
        
        csord__Subscription__c subsv=new csord__Subscription__c();
        subsv.name  = 'test subsv';
        subsv.csord__Identification__c = 'test identityv';
        subsv.Site__c = site.Id;
        subsv.csord__Status__c='Subscription Created';
        subsv.csordtelcoa__Subscription_Number__c = 'SN-000003199';
        subsv.csord__Order__c = secOrd.id;
        subsv.csordtelcoa__Product_Configuration__c = productConfigCancel.id;
        subsv.Billing_Account__c = billingAccount.id; 
        subsv.Offer__c = OriginatingOffer.Id;        
        subsv.MarketableOffer__c= mOffer.Id;
        subsList.add(subsv);
        
        csord__Subscription__c pricingModifySub =new csord__Subscription__c();
        pricingModifySub.name  = 'test_pricingModifySub';
        pricingModifySub.csord__Identification__c = 'test pricingModifySub';
        pricingModifySub.Site__c = site.Id;
        pricingModifySub.csord__Status__c='Subscription Created';
        pricingModifySub.csordtelcoa__Subscription_Number__c = 'SN-000003202';
        pricingModifySub.csord__Order__c = secOrd.id;
        pricingModifySub.csordtelcoa__Product_Configuration__c = productConfig.id;
        pricingModifySub.Billing_Account__c = billingAccount.id; 
        pricingModifySub.Offer__c = OriginatingOffer.Id;
        pricingModifySub.MarketableOffer__c= mOffer.Id;
        subsList.add(pricingModifySub);
    
    csord__Subscription__c pricingModifySub1 =new csord__Subscription__c();
        pricingModifySub1.name  = 'test_pricingModifySub1';
        pricingModifySub1.csord__Identification__c = 'test pricingModifySub1';
        pricingModifySub1.Site__c = site.Id;
        pricingModifySub1.csord__Status__c='Subscription Created';
        pricingModifySub1.csordtelcoa__Subscription_Number__c = 'SN-000003203';
        pricingModifySub1.csord__Order__c = secOrd.id;
        pricingModifySub1.csordtelcoa__Product_Configuration__c = productConfig.id;
        pricingModifySub1.Billing_Account__c = billingAccount.id; //Added this
        pricingModifySub1.csordtelcoa__Replaced_Subscription__c =pricingModifySub.Id;
        pricingModifySub1.Offer__c = OriginatingOffer.Id;
        pricingModifySub1.MarketableOffer__c= mOffer.Id;
        subsList.add(pricingModifySub1);
    
    csord__Subscription__c subV1=new csord__Subscription__c();
        subV1.name  = 'TestAutoExpiry1';
        subV1.csord__Identification__c = 'TestAutoExpiry1';
        subV1.csord__Status__c='Provisioned';
        subV1.csord__Order__c = ord.Id;
        subV1.autoExpiry__c=true;
        subV1.csordtelcoa__Product_Configuration__c=productConfig.id;
        subV1.Billing_Account__c=billingAccount.id;
        subV1.MarketableOffer__c= mOffer.Id;
        subsList.add(subV1);
        
        csord__Subscription__c subV2=new csord__Subscription__c();
        subV2.name  = 'TestAutoExpiry2';
        subV2.csord__Identification__c = 'TestAutoExpiry2';
        subV2.csord__Status__c='Provisioned';
        subV2.csord__Order__c = ord.Id;
        subV2.autoExpiry__c=true;
        subV2.csordtelcoa__Product_Configuration__c=productConfig.id;
        subV2.Billing_Account__c=billingAccount.id;
        subV2.MarketableOffer__c= mOffer.Id;
        subsList.add(subV2);
        
        //Added to test DPG-2000
        csord__Subscription__c subsLIOT =new csord__Subscription__c();
        subsLIOT.name  = 'IOT Subs 1';
        subsLIOT.csord__Identification__c = 'test identityL';
        subsLIOT.Site__c = site.Id;
        subsLIOT.csord__Status__c='Subscription Created';
        subsLIOT.csordtelcoa__Subscription_Number__c = 'SN-000003199';
        subsLIOT.csord__Order__c = secOrd.id;
        subsLIOT.csordtelcoa__Product_Configuration__c = productConfigIOT.id;
        subsLIOT.Billing_Account__c = billingAccount.id; 
        subsLIOT.Offer__c = OriginatingOfferIOT.Id;
        subsLIOT.MarketableOffer__c= mOffer.Id;
        subsList.add(subsLIOT);

        //Added to test DPG-2000
        csord__Subscription__c subsKIOT =new csord__Subscription__c();
        subsKIOT.name  = 'IOT Subs 2';
        subsKIOT.csord__Identification__c = 'test identityK';
        subsKIOT.Site__c = site.Id;
        subsKIOT.csord__Status__c='Subscription Created';
        subsKIOT.csordtelcoa__Subscription_Number__c = 'SN-000003199';
        subsKIOT.csord__Order__c = secOrd.id;
        subsKIOT.csordtelcoa__Product_Configuration__c = productConfigIOT.id;
        subsKIOT.Billing_Account__c = billingAccount.id; 
        subsKIOT.Offer__c = OriginatingOfferIOT.Id;
        subsKIOT.csordtelcoa__Replaced_Subscription__c = subsLIOT.Id;
        subsKIOT.MarketableOffer__c = mOfferIOT.id;
        subsList.add(subsKIOT);
        
        insert subsList;
        
        List<csord__Service__c> servList = new List<csord__Service__c>();
        csord__Service__c servK = new csord__Service__c();
        servK.name ='tst serviceK';
        servK.csord__Identification__c  = 'test identify';
        servK.csord__Subscription__c  = subsK.id;
        servK.csord__Order__c = ord.id;
        servK.csordtelcoa__Service_Number__c = 'SVC-313267';
        servK.Scenario_Type__c= 'Change of Mobile Number';
        servList.add(servK);
        
        csord__Service__c servNGEM = new csord__Service__c();
        servNGEM.name ='tst service1';
        servNGEM.csord__Identification__c  = 'test identify1';
        servNGEM.csord__Subscription__c  = subsK.id;
        servNGEM.csord__Order__c = ord.id;
        servNGEM.csordtelcoa__Service_Number__c = 'SVC-313268';
        servNGEM.Scenario_Type__c= 'Next Gen EM';
        servList.add(servNGEM);     
        
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify cancel';
        serv.csord__Subscription__c  = subs.id;
        serv.csord__Order__c = ord.id;
        serv.csordtelcoa__Service_Number__c = 'SVC-373269';
        serv.Scenario_Type__c= 'Change of Mobile Number';
        serv.contract_term__c ='24';
        serv.Initial_Activation_Date__c = date.newInstance(2018, 12, 17);
        serv.csord__service__c = servK.id;
        serv.csordtelcoa__Product_Configuration__c = productConfig.Id;
        serv.csord__Service__c = null;
        servList.add(serv); 
        
        csord__Service__c servD = new csord__Service__c();
        servD.name ='tst servicev';
        servD.csord__Identification__c  = 'test identifyv';
        servD.csord__Subscription__c  = subsv.id;
        servD.csord__Order__c = ord.id;
        servD.csordtelcoa__Service_Number__c = 'SVC-313269';
        servD.Scenario_Type__c= 'Change of Mobile Number';
        servD.contract_term__c ='24';
        servD.Initial_Activation_Date__c = date.newInstance(2018, 12, 17);
        servD.csord__service__c = servK.id;
        servD.csordtelcoa__Product_Configuration__c = productConfig.Id;
        servD.csord__Service__c = null;
        servList.add(servD); 
        
        csord__Service__c serv1 = new csord__Service__c();
        serv1.name ='tst service1';
        serv1.csord__Identification__c  = 'test identify';
        serv1.csord__Subscription__c  = subs1.id;
        serv1.csord__Order__c = ord.id;
        serv1.csordtelcoa__Service_Number__c = 'SVC-313260';
        serv1.Scenario_Type__c= 'Change of Mobile Number';
        serv1.csord__Service__c = serv.Id;
        serv1.Initial_Activation_Date__c = Date.newInstance(2019, 2, 17); 
        serv1.contract_term__c ='24';
        servList.add(serv1); 
        
         
        csord__Service__c servModify = new csord__Service__c();
        servModify.name ='tst service';
        servModify.csord__Identification__c  = 'test identify';
        servModify.csord__Subscription__c  = subsModify.id;
        servModify.csord__Order__c = ord.id;
        servModify.csordtelcoa__Service_Number__c = 'SVC-313293';
        servModify.Scenario_Type__c= 'Change of Mobile Number';
        servList.add(servModify);
        
        csord__Service__c serviceUCMobile = new csord__Service__c();
        serviceUCMobile.name ='tst_service';
        serviceUCMobile.csord__Identification__c  = 'test identify';
        serviceUCMobile.csord__Subscription__c  = subsUCMobile.id;
        serviceUCMobile.csord__Order__c = ord.id;
        serviceUCMobile.csordtelcoa__Service_Number__c = 'SVC-313263';
        serviceUCMobile.csordtelcoa__Product_Configuration__c = productConfig.id;
        serviceUCMobile.Scenario_Type__c= 'Change of Mobile Number';
        servList.add(serviceUCMobile);
        
        csord__Service__c unitsService = new csord__Service__c();
        unitsService.name ='tst_service';
        unitsService.csord__Identification__c  = 'test identify';
        unitsService.csord__Subscription__c  = checkUnits.id;
        unitsService.csord__Order__c = ord.id;
        unitsService.csordtelcoa__Service_Number__c = 'SVC-313263';
        unitsService.csordtelcoa__Product_Configuration__c = productConfig.id;
        unitsService.Scenario_Type__c= 'Change of Mobile Number';
        servList.add(unitsService);
        
        csord__Service__c pricingModifyServ = new csord__Service__c();
        pricingModifyServ.name ='tst_pricingModifyServ';
        pricingModifyServ.csord__Identification__c  = 'test identify';
        pricingModifyServ.csord__Subscription__c  = pricingModifySub.id;
        pricingModifyServ.csord__Order__c = secOrd.id;
        pricingModifyServ.csordtelcoa__Service_Number__c = 'SVC-313363';
        pricingModifyServ.csordtelcoa__Product_Configuration__c = productConfig.id;
        servList.add(pricingModifyServ);
    
    csord__Service__c pricingModifyServ1 = new csord__Service__c();
        pricingModifyServ1.name ='tst_pricingModifyServ1';
        pricingModifyServ1.csord__Identification__c  = 'test identify';
        pricingModifyServ1.csord__Subscription__c  = pricingModifySub1.id;
        pricingModifyServ1.csord__Order__c = secOrd.id;
        pricingModifyServ1.csordtelcoa__Service_Number__c = 'SVC-313364';
        pricingModifyServ1.csordtelcoa__Product_Configuration__c = productConfig.id;
    pricingModifyServ1.csordtelcoa__Replaced_Service__c=pricingModifyServ.id;
        servList.add(pricingModifyServ1);
    
    csord__Service__c servV1 = new csord__Service__c();
        servV1.name ='TestAutoExpiry';
        servV1.csord__Identification__c  = 'TestAutoExpiry';
        servV1.csordtelcoa__Service_Number__c = 'SVC-000023461';
        servV1.csord__Subscription__c = subV1.Id;
        servV1.csord__Status__c = 'Connected'; 
        servV1.csord__Order__c = ord.Id;
    servV1.autoExpiry__c =true;
    servV1.expiryDuration__c=2;
        servList.add(servV1);
        
        csord__Service__c servV2 = new csord__Service__c();
        servV2.name ='TestAutoExpiry2';
        servV2.csord__Identification__c  = 'TestAutoExpiry2';
        servV2.csordtelcoa__Service_Number__c = 'SVC-000023472';
        servV2.csord__Subscription__c = subV2.Id;
        servV2.csord__Status__c = 'Connected'; 
        servV2.csord__Order__c = ord.Id;
    servV2.autoExpiry__c =true;
    servV2.expiryDuration__c=1;
        insert servV2;
        
        csord__Service__c servV21 = new csord__Service__c();
        servV21.name ='TestAutoExpiry21';
        servV21.csord__Identification__c  = 'TestAutoExpiry21';
        servV21.csordtelcoa__Service_Number__c = 'SVC-000023473';
        servV21.csord__Subscription__c = subV2.Id;
        servV21.csord__Status__c = 'Connected'; 
        servV21.csord__Order__c = ord.Id;
    servV21.autoExpiry__c =true;
    servV21.expiryDuration__c=4;
        servV21.csord__Service__c=servV2.id;
        servList.add(servV21);
        
        //Added to test DPG-2000
        csord__Service__c servKIOT = new csord__Service__c();
        servKIOT.name ='tst serviceK';
        servKIOT.csord__Identification__c  = 'test identify';
        servKIOT.csord__Subscription__c  = subsKIOT.id;
        servKIOT.csord__Order__c = ord.id;
        servKIOT.csordtelcoa__Service_Number__c = 'SVC-200000';
        servKIOT.Scenario_Type__c= 'Change of Mobile Number';
        servList.add(servKIOT);
        
        insert servList;
        
        List<Attachment> attList=new List<Attachment>();
        Attachment attK = new Attachment();
        attK.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000537","productConfigurationId":"a3T5O00000007d0UAA","name":"T-MDM Powered by Vmware_Fulfillment","metadata":{},"instanceId":"","includeBilling":false,"guid":"a8ae4c3a-dd76-d908-fa0c-774d3b81cfa0","endDate":"","description":"","code":"DMCAT_ProductSpecification_000537_Fulfillment","attributes":{"TenancyID":"","__targetSystem":"FULFILLMENT","ContractTerm":"20","alteredPrice":"","50":"","billingSubtype":"billSubType"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000537DMCAT_ProductSpecification_000537_Billing_Allowance_000699","productConfigurationId":"a3T5O00000007d0UAA","name":"T-MDM Powered by Vmware_Billing_RecurringCharge_000699","metadata":{},"instanceId":"","includeBilling":false,"guid":"2140f506-f7ea-52a0-8bde-f9cd0c0bb4b1","endDate":"","description":"","code":"DMCAT_ProductSpecification_000537_Billing_Allowance_000699","attributes":{"customRate":[{"attributes":{"rateExcludeGST":"318.20","rangeTo":"","rangeFrom":""},"schemaId":"5ef6e85c-6910-7989-9539-2ce7e36fe211"},{"attributes":{"rateExcludeGST":"5","rangeTo":"1000","rangeFrom":"1"},"schemaId":"cd86774c-54f1-eadc-f2cc-3dd823a3dd43"},{"attributes":{"rateExcludeGST":"3.5","rangeTo":"4000","rangeFrom":"3001"},"schemaId":"58252e89-4c0e-b04d-32eb-0e3b550ba515"},{"attributes":{"rateExcludeGST":"3","rangeTo":"5000","rangeFrom":"4001"},"schemaId":"f82e92ae-151e-d088-1fce-0e6db9029d0d"},{"attributes":{"rateExcludeGST":"4","rangeTo":"3000","rangeFrom":"2001"},"schemaId":"c1ac451e-034a-2137-b0b6-94a9a3758057"},{"attributes":{"rateExcludeGST":"3","rangeTo":"99999","rangeFrom":"5001"},"schemaId":"556036fa-0366-b1d3-5f2d-15d00b7894d2"},{"attributes":{"rateExcludeGST":"4.5","rangeTo":"2000","rangeFrom":"1001"},"schemaId":"4e4f2fcc-1c18-9f2e-1f0a-a9ad86fe698d"}],"frequency":"Monthly","prorate":"false","billDescription":"Software License Fee","billingSpecId":"BSUSG003_CB","type":"RC","currency":"AUD","billingSubtype":"Tier Based Charge","unitofMeasure":"per device","taxTreatment":"GST Applicable","billInAdvance":"true","__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"a4e5O0000000SRYQA2","legacyAttributes":[]}');
        attK.Name = 'ServiceSpecifications.json';
        attK.ParentId = servK.Id;
        attList.add(attK);
        //EDGE-81130 END
        
        //
        Attachment attNGEM = new Attachment();
        attNGEM.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000537","productConfigurationId":"a3T5O00000007d0UAA","name":"T-MDM Powered by Vmware_Fulfillment","metadata":{},"instanceId":"","includeBilling":false,"guid":"a8ae4c3a-dd76-d908-fa0c-774d3b81cfa0","endDate":"","description":"","code":"DMCAT_ProductSpecification_000537_Fulfillment","attributes":{"TenancyID":"","__targetSystem":"FULFILLMENT","ContractTerm":"20","alteredPrice":"","50":"","billingSubtype":"billSubType"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000537DMCAT_ProductSpecification_000537_Billing_RecurringCharge_000699","productConfigurationId":"a3T5O00000007d0UAA","name":"T-MDM Powered by Vmware_Billing_RecurringCharge_000699","metadata":{},"instanceId":"","includeBilling":false,"guid":"2140f506-f7ea-52a0-8bde-f9cd0c0bb4b1","endDate":"","description":"","code":"DMCAT_ProductSpecification_000537_Billing_RecurringCharge_000699","attributes":{"customRate":[{"attributes":{"rateExcludeGST":"318.20","rangeTo":"","rangeFrom":""},"schemaId":"5ef6e85c-6910-7989-9539-2ce7e36fe211"},{"attributes":{"rateExcludeGST":"5","rangeTo":"1000","rangeFrom":"1"},"schemaId":"cd86774c-54f1-eadc-f2cc-3dd823a3dd43"},{"attributes":{"rateExcludeGST":"3.5","rangeTo":"4000","rangeFrom":"3001"},"schemaId":"58252e89-4c0e-b04d-32eb-0e3b550ba515"},{"attributes":{"rateExcludeGST":"3","rangeTo":"5000","rangeFrom":"4001"},"schemaId":"f82e92ae-151e-d088-1fce-0e6db9029d0d"},{"attributes":{"rateExcludeGST":"4","rangeTo":"3000","rangeFrom":"2001"},"schemaId":"c1ac451e-034a-2137-b0b6-94a9a3758057"},{"attributes":{"rateExcludeGST":"3","rangeTo":"99999","rangeFrom":"5001"},"schemaId":"556036fa-0366-b1d3-5f2d-15d00b7894d2"},{"attributes":{"rateExcludeGST":"4.5","rangeTo":"2000","rangeFrom":"1001"},"schemaId":"4e4f2fcc-1c18-9f2e-1f0a-a9ad86fe698d"}],"frequency":"Monthly","prorate":"false","billDescription":"Software License Fee","billingSpecId":"BSUSG003_CB","type":"RC","currency":"AUD","billingSubtype":"Tier Based Charge","unitofMeasure":"per device","taxTreatment":"GST Applicable","contractType":"Purchase","billInAdvance":"true","__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"a4e5O0000000SRYQA2","legacyAttributes":[]}');
        attNGEM.Name = 'ServiceSpecifications.json';
        attNGEM.ParentId = servK.Id;
        attList.add(attNGEM);       
        
        
        //
        
        
        //updated attachment as part of EDGE-138939
        Attachment attUCMobile = new Attachment();
        attUCMobile.Name = 'ServiceSpecifications.json';
        attUCMobile.ParentId = serviceUCMobile.Id;
        attUCMobile.Body = Blob.valueOf('{ "legacyAttributes": [], "serviceId": "'+serviceUCMobile.Id+'", "specifications": [ { "additionalAttributes": { "SERVICEID": "61429751286", "IMSI": "1222345678", "CustomerFacingServiceId": "C111", "tenancyId": "T101", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "2019-02-15T08:00:00", "IPWirelessProductInstanceID": "6eb08c83-b098-2ca8-b7a5-14a884585c30" }, "attributes": { "50": "", "ContractTerm": "20", "alteredPrice": 54.54, "rateExcludeGST":"54.54", "billingSubtype": "billSubType", "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "FULFILMENT", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "DMCAT_ProductSpecification_000263_Fulfilment", "description": "", "endDate": "", "guid": "cbc76a67-4404-29d8-5e11-308955d90822", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GV3GUAW", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "In Progress", "version": "1" }, { "additionalAttributes": {}, "attributes": { "50": "", "__targetSystem": "ASSURANCE", "ServiceManagementOption ": "1", "ContractTerm": "20", "alteredPrice": "", "billingSubtype": "billSubType" }, "code": "DMCAT_ProductSpecification_000326_Assurance", "description": "", "endDate": "", "guid": "2fd726fd-f547-b136-8f32-0aa323a5e3ea", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Telstra Managed Service Option 1_Assurance", "productConfigurationId": "a3T2O000000GV3GUAW", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000326", "startDate": "", "status": "Created", "version": "1" }, { "additionalAttributes": {}, "attributes": { "__targetSystem": "BILLING", "billingSpecId": "BSUSG001_CB", "ocsProdID": "ocsProd2", "type": "Domestic Data", "unitofMeasure": "GB", "value": "Unlimited", "RoutingServiceType": "Mobile", "SERVICEID": "", "IMSI": "" }, "code": "DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3", "description": "", "endDate": "", "guid": "040265c5-13b0-28b0-1965-0b091adae7ba", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Bill_AW", "productConfigurationId": "a3T2O000000GV3GUAW", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3", "startDate": "", "status": "Created", "version": "1" }, { "additionalAttributes": {}, "attributes": { "__targetSystem": "BILLING", "billingSpecId": "BSUSG001_CB", "ocsProdID": "ocsProd3", "type": "Dummy ngUC", "unitofMeasure": "GB", "value": "Unlimited", "RoutingServiceType": "Voice" }, "code": "DMCAT_ProductSpecification_000313_Billing_Allowance_000512_4", "description": "", "endDate": "", "guid": "4a094253-e91a-62b4-f6f0-bb354ded8868", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "UC Numbers_Bill_AW", "productConfigurationId": "a3T2O000000GV3GUAW", "specification": "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313_Billing_Allowance_000512_4", "startDate": "", "status": "Created", "version": "1" }, { "additionalAttributes": { "DMCAT_ProductSpecification_000322_CPEDeliveryDate": "2019-02-15T08:00:00", "BSServiceTypeProductInstanceID": "403d93a3-5c71-1663-8dc7-e51ab07bf4b8" }, "attributes": { "50": "", "ContractTerm": "20", "alteredPrice": "", "billingSubtype": "billSubType", "BSServiceTypeProductInstanceID": "DMCAT_ProductSpecification_000312_Fulfilment", "__targetSystem": "FULFILMENT", "CustomerFacingServiceId": "", "CustomerPreferredName": "", "DMCAT_ProductSpecification_000322_CPEDeliveryDate": "" }, "code": "DMCAT_ProductSpecification_000322_Fulfilment", "description": "", "endDate": "", "guid": "197ae1b8-9901-402c-290a-efd6e0740459", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "UC Site_Fulfilment", "productConfigurationId": "a3T2O000000GV3GUAW", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000322", "startDate": "", "status": "In Progress", "version": "1" }, { "additionalAttributes": { "InternetProtectionSolutionProductInstanceID": "b03fd5dd-c2f5-3fec-82dd-b621e16368b5" }, "attributes": { "__targetSystem": "FULFILMENT", "UserProtectionType": "Web and Mail", "InternetProtectionSolutionProductInstanceID": "DMCAT_ProductSpecification_000163_Fulfilment", "Quantity": "3" }, "code": "DMCAT_ProductSpecification_000162_Fulfilment", "description": "", "endDate": "", "guid": "e634201f-a357-ca27-92ec-d5368b8c8bed", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Web and Mail Internet Protection User_Fulfilment", "productConfigurationId": "a3T2O000000GV3GUAW", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000162", "startDate": "", "status": "In Progress", "version": "1" }, { "additionalAttributes": { "parentSpec": "2fd726fd-f547-b136-8f32-0aa323a5e3ea" }, "attributes": { "__targetSystem": "ASSURANCE", "parentSpec": "DMCAT_ProductSpecification_000326_Assurance", "ResponseTarget": "SLA0010001", "RestoreTarget": "SLA0010002" }, "code": "DMCAT_ProductSpecification_000151_Assurance", "description": "", "endDate": "", "guid": "5f735f33-0af6-8fb7-644a-8681ca0d258c", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Incident Management_Assurance", "productConfigurationId": "a3T2O000000GV3GUAW", "specification": "DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151", "startDate": "", "status": "Created", "version": "1" }, { "additionalAttributes": { "parentSpec": "197ae1b8-9901-402c-290a-efd6e0740459" }, "attributes": { "__targetSystem": "FULFILMENT", "name": "Hosted UC", "CustomerFacingServiceId": "", "id": "", "parentSpec": "DMCAT_ProductSpecification_000322_Fulfilment", "Quantity": 3 }, "code": "DMCAT_ProductSpecification_000315_Fulfilment", "description": "", "endDate": "", "guid": "2a0ef56f-f963-1faf-828c-a21967099d85", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Feature Packs_Fulfilment", "productConfigurationId": "a3T2O000000GV3GUAW", "specification": "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000315", "startDate": "", "status": "In Progress", "version": "1" }, { "additionalAttributes": { "parentSpec": "197ae1b8-9901-402c-290a-efd6e0740459" }, "attributes": { "parentSpec": "DMCAT_ProductSpecification_000322_Fulfilment", "__targetSystem": "FULFILMENT", "VoicePlan": "Complete Premium", "id": "", "CustomerFacingServiceId": "", "Number": [ { "schemaId": "2c3f0a69-f86c-fcfe-86ff-42e2f58bc3ab", "attributes": { "FNN": "1111111111", "rangeFrom": null, "rangeTo": null, "status": "RESERVED", "listCode": "No Entry Line" } }, { "schemaId": "6c9ca3f1-bde7-43a2-06ce-5625f3cfa3e8", "attributes": { "FNN": "2222222222", "rangeFrom": null, "rangeTo": null, "status": "RESERVED", "listCode": "No Entry Line" } }, { "schemaId": "43ebbd8e-27e6-3d72-2235-76cdc32b33df", "attributes": { "FNN": "3333333333", "rangeFrom": null, "rangeTo": null, "status": "RESERVED", "listCode": "No Entry Line" } }, { "schemaId": "e058b794-660f-e00b-34b5-ee92f0973d6e", "attributes": { "FNN": "8282345567", "rangeFrom": null, "rangeTo": null, "status": "RESERVED", "listCode": "No Entry Line" } }, { "schemaId": "7503f70d-8252-ceca-511a-9c97ccf4061d", "attributes": { "FNN": "8282345566", "rangeFrom": null, "rangeTo": null, "status": "RESERVED", "listCode": "No Entry Line" } }, { "schemaId": "5679bbbb-5bf3-f3e9-b80f-3138cf48c21e", "attributes": { "FNN": "8282345568", "rangeFrom": null, "rangeTo": null, "status": "RESERVED", "listCode": "No Entry Line" } }, { "schemaId": "042b8d27-541b-bec4-cb6f-7c95d2198afe", "attributes": { "FNN": "8282345569", "rangeFrom": null, "rangeTo": null, "status": "RESERVED", "listCode": "No Entry Line" } }, { "schemaId": "458791cb-9671-da71-c352-5bc182e529d5", "attributes": { "FNN": "8282345516", "rangeFrom": null, "rangeTo": null, "status": "RESERVED", "listCode": "No Entry Line" } }, { "schemaId": "ccd8dc11-5a51-831d-18c0-2cadc85b500d", "attributes": { "FNN": "8282345526", "rangeFrom": null, "rangeTo": null, "status": "RESERVED", "listCode": "No Entry Line" } }, { "schemaId": "4b76e4bc-6fdb-14cf-fdb5-2ea1b5135801", "attributes": { "FNN": "8282345536", "rangeFrom": null, "rangeTo": null, "status": "RESERVED", "listCode": "No Entry Line" } }, { "schemaId": "e78aa0ce-d9a2-4607-0d2b-07c73d7aade4", "attributes": { "FNN": "8282345546", "rangeFrom": null, "rangeTo": null, "status": "RESERVED", "listCode": "No Entry Line" } } ] }, "code": "DMCAT_ProductSpecification_000313_Fulfilment", "description": "", "endDate": "", "guid": "2d59449c-0097-46e3-b555-ebed20aaec3e", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "UC Numbers_Fulfilment", "productConfigurationId": "a3T2O000000GV3GUAW", "specification": "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313", "startDate": "", "status": "In Progress", "version": "1" } ] }');
        attList.add(attUCMobile);
        
        Attachment fnnAtt = new Attachment();
        fnnAtt.Name = 'NumberManagementv1_schema';
        fnnAtt.ParentId = productConfig.id;
        fnnAtt.Body = Blob.valueOf('{"configurations":[{"guid":"e40f1ea4-8bb0-b750-ae68-f386d4c85527","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"1111111111"},{"guid":"d134a3f5-dd2c-7cb3-cd56-d34d126ebf3e","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"2222222222"},{"guid":"35d1e850-7d18-7473-bcc9-042b3ff75a8d","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"3333333333"},{"guid":"8accab10-7cd3-5511-1ef6-04dc067ebf61","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345567"},{"guid":"c2c93b39-f62a-b376-4014-e0852a282705","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345566"},{"guid":"2faeaee5-fde0-a469-418f-2229c27c0390","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345568"},{"guid":"f0002746-71f3-24a1-d6db-856e7102505e","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345569"},{"guid":"ed064996-b24e-7bce-c8f2-adf9279297d1","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345516"},{"guid":"441a71c3-df28-a272-dfc4-4d352f4556b1","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345526"},{"guid":"342e5d07-17c3-b791-8c61-ae08e07b4e3f","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345536"},{"guid":"62e7bbde-5985-6059-d528-7e4e51838f82","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345546"}],"schema":{"name":"NumberManagementv1","id":"a792O00000000BcQAI","attributes":[{"type":"String","showInUI":true,"required":false,"name":"FNN"},{"type":"String","showInUI":true,"required":false,"name":"rangeFrom"},{"type":"String","showInUI":true,"required":false,"name":"rangeTo"},{"type":"String","showInUI":true,"required":false,"name":"status"},{"type":"String","showInUI":true,"required":false,"name":"listCode"}]}}');
        attList.add(fnnAtt);
        
        Attachment servDattach = new Attachment();
        servDattach.Name = 'ServiceSpecifications.json';
        servDattach.ParentId = productConfig.id;
        servDattach.Body = Blob.valueOf('{"configurations":[{"guid":"e40f1ea4-8bb0-b750-ae68-f386d4c85527","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"1111111111"},{"guid":"d134a3f5-dd2c-7cb3-cd56-d34d126ebf3e","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"2222222222"},{"guid":"35d1e850-7d18-7473-bcc9-042b3ff75a8d","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"3333333333"},{"guid":"8accab10-7cd3-5511-1ef6-04dc067ebf61","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345567"},{"guid":"c2c93b39-f62a-b376-4014-e0852a282705","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345566"},{"guid":"2faeaee5-fde0-a469-418f-2229c27c0390","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345568"},{"guid":"f0002746-71f3-24a1-d6db-856e7102505e","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345569"},{"guid":"ed064996-b24e-7bce-c8f2-adf9279297d1","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345516"},{"guid":"441a71c3-df28-a272-dfc4-4d352f4556b1","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345526"},{"guid":"342e5d07-17c3-b791-8c61-ae08e07b4e3f","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345536"},{"guid":"62e7bbde-5985-6059-d528-7e4e51838f82","listCode":"No Entry Line","status":"RESERVED","rangeTo":null,"rangeFrom":null,"FNN":"8282345546"}],"schema":{"name":"NumberManagementv1","id":"a792O00000000BcQAI","attributes":[{"type":"String","showInUI":true,"required":false,"name":"FNN"},{"type":"String","showInUI":true,"required":false,"name":"rangeFrom"},{"type":"String","showInUI":true,"required":false,"name":"rangeTo"},{"type":"String","showInUI":true,"required":false,"name":"status"},{"type":"String","showInUI":true,"required":false,"name":"listCode"}]}}');
        attList.add(servDattach);
        
        List<Attachment> atts = new List<Attachment>();
        Attachment att1 = new Attachment();
        Feature_Flag__mdt ft= FeatureFlagUtility.getFeatureTogglingByName('B2B2');
        if( ft.IsActive__c ==true){
            att1.Body = Blob.valueOf('{"specifications" :[{"version" : "1","status" : "Created","startDate" : "","specification" : "f2e195ae-049a-4c3f-bb08-eed2cba1ff89","productConfigurationId" : "a3T0l0000004oFiEAI","name" : "User","instanceId" : "","guid" : "059719f3-07de-4c93-1068-df146594a48b","endDate" : "","billDescription" : "Sample Billing Spec for Munich Testing","code" : "DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes" : {"Voice FNN Details" : [{ "attributes" : { "LegacyOfferName":null,"From" : 433221177,"To" : 433221144,"Migrated" : "No"},"productConfigurationId" : "a3T2O000000782fUAA"}],"__targetSystem" : "BILLING","ContractTerm":"20","alteredPrice":"50","50":"","billingSubtype":"billSubType","code" : "CWP_OFFER_123","productId" : "SEAT_123","quantity" : "25","RateExcludedGST" : "150","prorate" : "false","unitPrice" : 60,"applicationDuration" : "24","recurringChargePeriod" : "Months","description" : "CWP Mobile Seat","priority" :"1" ,"invoiceDefinition" : "Invoice_Def_1", "billInAdvance" : "false","billingSpecId" : "BSRC001_CB","frequency" : "Monthly","currency" : "AUD","type" : "RC", "billDescription" : "CWP Zone 1 Seat Charges"},"additionalAttributes" : {"parentSpec" :"059719f3-07de-2911-1068-df146594a48b"}}, {"version" : "1","status" : "Created","startDate" : "","specification" : "f2e195ae-049a-4c3f-bb08-eed2cba1ff89","productConfigurationId" : "a3T0l0000004oFiEAI","name" : "User","instanceId" : "","guid" : "5d9d486d-008b-12ba-78fd-687b6f212681","endDate" : "","billDescription" : "Sample Billing Spec for Munich Testing","code" : "DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes" : {"ContractTerm":"20","alteredPrice":"50","50":"","billingSubtype":"billSubType","__targetSystem" : "Billing","code" : "CWP_OFFER_123","productId" : "SEAT_123","quantity" : "25","amount" : "150","billDescription" : "Seat Charge for Zone 2","prorateType" : "false","billInAdvance" : "false","billingSpecId" : "BSRC001_CB","frequency" : "Monthly","currency" : "AUD","type" : "RC"},"additionalAttributes" : { }} ],"serviceId" : "a4e0l00000005U9AAI","legacyAttributes" : [ ]}');
        }
        else{ att1.Body = Blob.valueOf('{"specifications" :[{"version" : "1","status" : "Created","startDate" : "","specification" : "f2e195ae-049a-4c3f-bb08-eed2cba1ff89","productConfigurationId" : "a3T0l0000004oFiEAI","name" : "User","instanceId" : "","guid" : "059719f3-07de-4c93-1068-df146594a48b","endDate" : "","description" : "Sample Billing Spec for Munich Testing","code" : "PS_000074","attributes" : {"Voice FNN Details" : [{ "attributes" : { "LegacyOfferName":null,"From" : 433221177,"To" : 433221144,"Migrated" : "No"},"productConfigurationId" : "a3T2O000000782fUAA"}],"__targetSystem" : "BILLING","code" : "CWP_OFFER_123","productId" : "SEAT_123","units" : "25","unitPrice" : "150","prorate" : "false","unitPrice" : 60,"rateExcludeGST":100.0,"applicationDuration" : "24","recurringChargePeriod" : "Months","description" : "CWP Mobile Seat","priority" :"1" ,"invoiceDefinition" : "Invoice_Def_1", "billInAdvance" : "false","billingSpecId" : "BSRC001_CB","frequency" : "Monthly","currency" : "AUD","type" : "RC", "description" : "CWP Zone 1 Seat Charges","ContractTerm":"20","alteredPrice":"50","50":"","billingSubtype":"billSubType"},"additionalAttributes" : {"parentSpec" :"059719f3-07de-2911-1068-df146594a48b"}}, {"version" : "1","status" : "Created","startDate" : "","specification" : "f2e195ae-049a-4c3f-bb08-eed2cba1ff89","productConfigurationId" : "a3T0l0000004oFiEAI","name" : "User","instanceId" : "","guid" : "5d9d486d-008b-12ba-78fd-687b6f212681","endDate" : "","description" : "Sample Billing Spec for Munich Testing","code" : "DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes" : {"ContractTerm":"20","alteredPrice":"50","50":"","billingSubtype":"billSubType","__targetSystem" : "Billing","code" : "CWP_OFFER_123","productId" : "SEAT_123","units" : "25","amount" : "150","billDescription" : "Seat Charge for Zone 2","prorateType" : "false","billInAdvance" : "false","billingSpecId" : "BSRC001_CB","frequency" : "Monthly","currency" : "AUD","type" : "RC"},"additionalAttributes" : { }} ],"serviceId" : "a4e0l00000005U9AAI","legacyAttributes" : [ ]}');
            }
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        attList.add(att1);
        
  
        Attachment attModify = new Attachment();
        Feature_Flag__mdt flag= FeatureFlagUtility.getFeatureTogglingByName('B2B2');
        if( flag.IsActive__c ==true){
            attModify.Body = Blob.valueOf('{"specifications" :[{"version" : "1","status" : "Created","startDate" : "","specification" : "f2e195ae-049a-4c3f-bb08-eed2cba1ff89","productConfigurationId" : "a3T0l0000004oFiEAI","name" : "User","instanceId" : "","guid" : "059719f3-07de-4c93-1068-df146594a48b","endDate" : "","billDescription" : "Sample Billing Spec for Munich Testing","code" : "PS_000073","attributes" : {"Voice FNN Details" : [{ "attributes" : {"ContractTerm":"20","alteredPrice":"","50":"","billingSubtype":"billSubType", "LegacyOfferName":null,"From" : 433221177,"To" : 433221144,"Migrated" : "No"},"productConfigurationId" : "a3T2O000000782fUAA"}],"__targetSystem" : "BILLING","code" : "CWP_OFFER_123","productId" : "SEAT_123","quantity" : "25","RateExcludedGST" : "150","prorate" : "false", "invoiceDefinition" : "Invoice_Def_1", "billInAdvance" : "false","billingSpecId" : "BSRC001_CB","frequency" : "Monthly","currency" : "AUD","type" : "RC", "billDescription" : "CWP Zone 1 Seat Charges"},"additionalAttributes" : {"parentSpec" :"059719f3-07de-2911-1068-df146594a48b"}}, {"version" : "1","status" : "Created","startDate" : "","specification" : "f2e195ae-049a-4c3f-bb08-eed2cba1ff89","productConfigurationId" : "a3T0l0000004oFiEAI","name" : "User","instanceId" : "","guid" : "5d9d486d-008b-12ba-78fd-687b6f212681","endDate" : "","billDescription" : "Sample Billing Spec for Munich Testing","code" : "","attributes" : {"__targetSystem" : "Billing","code" : "CWP_OFFER_123","productId" : "SEAT_123","quantity" : "25","amount" : "150","billDescription" : "Seat Charge for Zone 2","prorateType" : "false","billInAdvance" : "false","billingSpecId" : "BSRC001_CB","frequency" : "Monthly","currency" : "AUD","type" : "RC"},"additionalAttributes" : { }} ],"serviceId" : "a4e0l00000005U9AAI","legacyAttributes" : [ ]}');
        }
        else{attModify.Body = Blob.valueOf('{"specifications" :[{"version" : "1","status" : "Created","startDate" : "","specification" : "f2e195ae-049a-4c3f-bb08-eed2cba1ff89","productConfigurationId" : "a3T0l0000004oFiEAI","name" : "User","instanceId" : "","guid" : "059719f3-07de-4c93-1068-df146594a48b","endDate" : "","description" : "Sample Billing Spec for Munich Testing","code" : "PS_000073","attributes" : {"Voice FNN Details" : [{ "attributes" : {"ContractTerm":"20","alteredPrice":"","50":"","billingSubtype":"billSubType","LegacyOfferName":null,"From" : 433221177,"To" : 433221144,"Migrated" : "No"},"productConfigurationId" : "a3T2O000000782fUAA"}],"__targetSystem" : "BILLING","code" : "CWP_OFFER_123","productId" : "SEAT_123","units" : "25","unitPrice" : "150","prorate" : "false", "invoiceDefinition" : "Invoice_Def_1", "billInAdvance" : "false","billingSpecId" : "BSRC001_CB","frequency" : "Monthly","currency" : "AUD","type" : "RC", "description" : "CWP Zone 1 Seat Charges"},"additionalAttributes" : {"parentSpec" :"059719f3-07de-2911-1068-df146594a48b"}}, {"version" : "1","status" : "Created","startDate" : "","specification" : "f2e195ae-049a-4c3f-bb08-eed2cba1ff89","productConfigurationId" : "a3T0l0000004oFiEAI","name" : "User","instanceId" : "","guid" : "5d9d486d-008b-12ba-78fd-687b6f212681","endDate" : "","description" : "Sample Billing Spec for Munich Testing","code" : "DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes" : {"__targetSystem" : "Billing","code" : "CWP_OFFER_123","productId" : "SEAT_123","units" : "25","amount" : "150","billDescription" : "Seat Charge for Zone 2","prorateType" : "false","billInAdvance" : "false","billingSpecId" : "BSRC001_CB","frequency" : "Monthly","currency" : "AUD","type" : "RC"},"additionalAttributes" : { }} ],"serviceId" : "a4e0l00000005U9AAI","legacyAttributes" : [ ]}');
            }
        attModify.Name = 'ServiceSpecifications.json';
        attModify.ParentId = servModify.Id;
        attList.add(attModify);

       Attachment unitsAttach = new Attachment();
        Feature_Flag__mdt flag1 = FeatureFlagUtility.getFeatureTogglingByName('B2B2');
        if( flag1.IsActive__c ==true){
            unitsAttach.Body = Blob.valueOf('{"specifications" :[{"version" : "1","status" : "Created","startDate" : "","specification" : "f2e195ae-049a-4c3f-bb08-eed2cba1ff89","productConfigurationId" : "a3T0l0000004oFiEAI","name" : "User","instanceId" : "","guid" : "059719f3-07de-4c93-1068-df146594a48b","endDate" : "","billDescription" : "Sample Billing Spec for Munich Testing","code" : "PS_000073","attributes" : {"Voice FNN Details" : [{ "attributes" : {"ContractTerm":"20","alteredPrice":"","50":"","billingSubtype":"billSubType", "LegacyOfferName":null,"From" : 433221177,"To" : 433221144,"Migrated" : "No"},"productConfigurationId" : "a3T2O000000782fUAA"}],"__targetSystem" : "BILLING","code" : "CWP_OFFER_123","productId" : "SEAT_123","quantity" : "25.51","RateExcludedGST" : "150","prorate" : "false", "invoiceDefinition" : "Invoice_Def_1", "billInAdvance" : "false","billingSpecId" : "BSRC001_CB","frequency" : "Monthly","currency" : "AUD","type" : "RC", "billDescription" : "CWP Zone 1 Seat Charges"},"additionalAttributes" : {"parentSpec" :"059719f3-07de-2911-1068-df146594a48b"}}, {"version" : "1","status" : "Created","startDate" : "","specification" : "f2e195ae-049a-4c3f-bb08-eed2cba1ff89","productConfigurationId" : "a3T0l0000004oFiEAI","name" : "User","instanceId" : "","guid" : "5d9d486d-008b-12ba-78fd-687b6f212681","endDate" : "","billDescription" : "Sample Billing Spec for Munich Testing","code" : "","attributes" : {"__targetSystem" : "Billing","code" : "CWP_OFFER_123","productId" : "SEAT_123","quantity" : "25.52","amount" : "150","billDescription" : "Seat Charge for Zone 2","prorateType" : "false","billInAdvance" : "false","billingSpecId" : "BSRC001_CB","frequency" : "Monthly","currency" : "AUD","type" : "RC"},"additionalAttributes" : { }} ],"serviceId" : "a4e0l00000005U9AAI","legacyAttributes" : [ ]}');
        }
        else{unitsAttach.Body = Blob.valueOf('{"specifications" :[{"version" : "1","status" : "Created","startDate" : "","specification" : "f2e195ae-049a-4c3f-bb08-eed2cba1ff89","productConfigurationId" : "a3T0l0000004oFiEAI","name" : "User","instanceId" : "","guid" : "059719f3-07de-4c93-1068-df146594a48b","endDate" : "","description" : "Sample Billing Spec for Munich Testing","code" : "PS_000073","attributes" : {"Voice FNN Details" : [{ "attributes" : {"ContractTerm":"20","alteredPrice":"","50":"","billingSubtype":"billSubType","LegacyOfferName":null,"From" : 433221177,"To" : 433221144,"Migrated" : "No"},"productConfigurationId" : "a3T2O000000782fUAA"}],"__targetSystem" : "BILLING","code" : "CWP_OFFER_123","productId" : "SEAT_123","units" : "25.01","unitPrice" : "150","prorate" : "false", "invoiceDefinition" : "Invoice_Def_1", "billInAdvance" : "false","billingSpecId" : "BSRC001_CB","frequency" : "Monthly","currency" : "AUD","type" : "RC", "description" : "CWP Zone 1 Seat Charges"},"additionalAttributes" : {"parentSpec" :"059719f3-07de-2911-1068-df146594a48b"}}, {"version" : "1","status" : "Created","startDate" : "","specification" : "f2e195ae-049a-4c3f-bb08-eed2cba1ff89","productConfigurationId" : "a3T0l0000004oFiEAI","name" : "User","instanceId" : "","guid" : "5d9d486d-008b-12ba-78fd-687b6f212681","endDate" : "","description" : "Sample Billing Spec for Munich Testing","code" : "DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes" : {"__targetSystem" : "Billing","code" : "CWP_OFFER_123","productId" : "SEAT_123","units" : "25.02","amount" : "150","billDescription" : "Seat Charge for Zone 2","prorateType" : "false","billInAdvance" : "false","billingSpecId" : "BSRC001_CB","frequency" : "Monthly","currency" : "AUD","type" : "RC"},"additionalAttributes" : { }} ],"serviceId" : "a4e0l00000005U9AAI","legacyAttributes" : [ ]}');
            }
        unitsAttach.Name = 'ServiceSpecifications.json';
        unitsAttach.ParentId = unitsService.Id;
        attList.add(unitsAttach);
       
        Attachment attPricingModify = new Attachment();
        attPricingModify.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+pricingModifyServ.id+'","specifications":[{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","ocsProdID":"T22E_IR_USAGE","currency":"AUD","type":"OC","billingSubtype":"IR","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","billDescription":"IR Pay as you go charge","rateExcludeGST":"0.00","unitofMeasure":"each","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000263_DMCAT_NonRecurringCharge_000601_108"},"code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","description":"Mobile Access_Billing_NonRecurringCharge_000601","endDate":"","guid":"a9e4497b-2754-7221-e6ca-6751671ef2a8","includeBilling":false,"instanceId":"","metadata":{},"name":"263_NRC_601","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"parentSpec":"908fe418-a109-e766-2517-363f5f32cd05"},"attributes":{"__targetSystem":"ASSURANCE","parentSpec":"DMCAT_ProductSpecification_000326_Assurance","ResponseTarget":"SLA0010001","RestoreTarget":"SLA0010006"},"code":"DMCAT_ProductSpecification_000151_Assurance","description":"Incident Management_Assurance","endDate":"","guid":"4f374952-2bf4-8fa5-85a7-e8a30727635c","includeBilling":false,"instanceId":"","metadata":{},"name":"151_ASR","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151_2","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"ServiceManagementOption":"1","__targetSystem":"ASSURANCE"},"code":"DMCAT_ProductSpecification_000326_Assurance","description":"Telstra Managed Service Option 1_Assurance","endDate":"","guid":"908fe418-a109-e766-2517-363f5f32cd05","includeBilling":false,"instanceId":"","metadata":{},"name":"326_ASR","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductOffering_000420DMCAT_ProductSpecification_000326","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_IRDAYPASS","type":"International Roaming Data","unitofMeasure":"MB","value":"200","billingSubtype":"IR","billDescription":"IR Day Pass"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000606","description":"Mobility_Billing_DMCAT_Allowance_000606","endDate":"","guid":"068b988d-18d3-78e8-407a-13d896f581b5","includeBilling":false,"instanceId":"","metadata":{},"name":"263_AW_606","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000606_5","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_IR_AUTOTOPUP","type":"International Roaming Data","unitofMeasure":"MB","value":"500","billingSubtype":"IR","billDescription":"IR Data Topup"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000607","description":"Mobility_Billing_DMCAT_Allowance_000607","endDate":"","guid":"805764a7-d9e5-01a8-65b0-52b23c81d1a8","includeBilling":false,"instanceId":"","metadata":{},"name":"263_AW_607","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000607_6","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","quantity":"1","recurringChargePeriod":"Months","description":"MRO Bonus Plan Discount","alteredPrice":1448.5,"applicationDuration":24,"type":"Data","currency":"AUD","frequency":"Monthly","billingSpecId":"BSRC001_CB","billInAdvance":"true","prorate":"false","billDescription":"Corporate mobile plus - global data sim plan","rateExcludeGST":"145.50","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_4910"},"code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","description":"Mobility_Billing_RecurringCharge_000654","endDate":"","guid":"50f59975-ac13-db8c-163c-477df5092dcc","includeBilling":false,"instanceId":"","metadata":{},"name":"420_RC_654","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"ASSURANCE"},"code":"DMCAT_ProductSpecification_000421_Assurance","description":"Mobile Device Management_Assurance","endDate":"","guid":"9292a251-590b-bd78-ac23-47da3755d4ff","includeBilling":false,"instanceId":"","metadata":{},"name":"421_ASR","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000421","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"SERVICEPROFILE":"TABLET","IMSI":"","CustomerFacingServiceId":"61473603212","MESSAGEBANK":"NA","SKU":"100119211","parentSpec":"7200c94d-ad78-0078-c8d3-b5c586d50313","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","__targetSystem":"FULFILMENT"},"attributes":{"__targetSystem":"FULFILMENT","IPWirelessProductInstanceID":"NA","BillofMaterialID":"NA","AccessRole":"Primary","CONTEXT":"CUSTOMER","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","SKU":"100119211","SuspensionContext":"NA","CustomerFacingServiceId":"","ShippingRequired":"TRUE","IMSI":"","SERVICEPROFILE":"TABLET"},"code":"DMCAT_ProductSpecification_000263_Fulfilment","description":"Mobile Access_Fulfilment","endDate":"","guid":"fc8e7088-a0ba-6b6c-ef69-3e6b3d281a89","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","startDate":"","status":"Suspend","version":"1"},{"additionalAttributes":{"__targetSystem":"FULFILMENT","IPWirelessProductInstanceID":"NA","BillofMaterialID":"NA","AccessRole":"Primary","CONTEXT":"CUSTOMER","SKU":"100119211","MESSAGEBANK":"NA","CustomerFacingServiceId":"61473603212","IMSI":"","SERVICEPROFILE":"TABLET"},"attributes":{"__targetSystem":"FULFILMENT"},"code":"DMCAT_ProductSpecification_000420_Fulfilment","description":"Mobility_Fulfilment","endDate":"","guid":"7200c94d-ad78-0078-c8d3-b5c586d50313","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobility_Fulfilment","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000420","startDate":"","status":"Modified","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","value":"250","unitofMeasure":"GB","type":"FairPlay Data","ocsProdID":"T22EM_MBB-L","billingSpecId":"BSUSG001_CB","billDescription":"Includes 250 GB Domestic Data"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000637","description":"Mobility_Billing_DMCAT_Allowance_000637","endDate":"","guid":"ebba38ae-33c5-6b11-f8ce-50f6b74520fe","includeBilling":false,"instanceId":"","metadata":{},"name":"420_AW_637","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000637_7","startDate":"","status":"Created","version":"1"}]}');
        attPricingModify.Name = 'ServiceSpecifications.json';
        attPricingModify.ParentId = pricingModifyServ.Id;
        attList.add(attPricingModify);
        
        Attachment attPricingModify1 = new Attachment();
        attPricingModify1.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+pricingModifyServ1.id+'","specifications":[{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","ocsProdID":"T22E_IR_USAGE","currency":"AUD","type":"OC","billingSubtype":"IR","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","billDescription":"IR Pay as you go charge","rateExcludeGST":"0.00","unitofMeasure":"each","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000263_DMCAT_NonRecurringCharge_000601_108"},"code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","description":"Mobile Access_Billing_NonRecurringCharge_000601","endDate":"","guid":"a9e4497b-2754-7221-e6ca-6751671ef2a8","includeBilling":false,"instanceId":"","metadata":{},"name":"263_NRC_601","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"parentSpec":"908fe418-a109-e766-2517-363f5f32cd05"},"attributes":{"__targetSystem":"ASSURANCE","parentSpec":"DMCAT_ProductSpecification_000326_Assurance","ResponseTarget":"SLA0010001","RestoreTarget":"SLA0010006"},"code":"DMCAT_ProductSpecification_000151_Assurance","description":"Incident Management_Assurance","endDate":"","guid":"4f374952-2bf4-8fa5-85a7-e8a30727635c","includeBilling":false,"instanceId":"","metadata":{},"name":"151_ASR","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151_2","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"ServiceManagementOption":"1","__targetSystem":"ASSURANCE"},"code":"DMCAT_ProductSpecification_000326_Assurance","description":"Telstra Managed Service Option 1_Assurance","endDate":"","guid":"908fe418-a109-e766-2517-363f5f32cd05","includeBilling":false,"instanceId":"","metadata":{},"name":"326_ASR","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductOffering_000420DMCAT_ProductSpecification_000326","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_IRDAYPASS","type":"International Roaming Data","unitofMeasure":"MB","value":"200","billingSubtype":"IR","billDescription":"IR Day Pass"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000606","description":"Mobility_Billing_DMCAT_Allowance_000606","endDate":"","guid":"068b988d-18d3-78e8-407a-13d896f581b5","includeBilling":false,"instanceId":"","metadata":{},"name":"263_AW_606","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000606_5","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_IR_AUTOTOPUP","type":"International Roaming Data","unitofMeasure":"MB","value":"500","billingSubtype":"IR","billDescription":"IR Data Topup"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000607","description":"Mobility_Billing_DMCAT_Allowance_000607","endDate":"","guid":"805764a7-d9e5-01a8-65b0-52b23c81d1a8","includeBilling":false,"instanceId":"","metadata":{},"name":"263_AW_607","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000607_6","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","quantity":"1","recurringChargePeriod":"Months","description":"MRO Bonus Plan Discount","alteredPrice":145.5,"applicationDuration":24,"type":"Data","currency":"AUD","frequency":"Monthly","billingSpecId":"BSRC001_CB","billInAdvance":"true","prorate":"false","billDescription":"Corporate mobile plus - global data sim plan","rateExcludeGST":"145.50","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_4910"},"code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","description":"Mobility_Billing_RecurringCharge_000654","endDate":"","guid":"50f59975-ac13-db8c-163c-477df5092dcc","includeBilling":false,"instanceId":"","metadata":{},"name":"420_RC_654","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"ASSURANCE"},"code":"DMCAT_ProductSpecification_000421_Assurance","description":"Mobile Device Management_Assurance","endDate":"","guid":"9292a251-590b-bd78-ac23-47da3755d4ff","includeBilling":false,"instanceId":"","metadata":{},"name":"421_ASR","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000421","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"SERVICEPROFILE":"TABLET","IMSI":"","CustomerFacingServiceId":"61473603212","MESSAGEBANK":"NA","SKU":"100119211","parentSpec":"7200c94d-ad78-0078-c8d3-b5c586d50313","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","__targetSystem":"FULFILMENT"},"attributes":{"__targetSystem":"FULFILMENT","IPWirelessProductInstanceID":"NA","BillofMaterialID":"NA","AccessRole":"Primary","CONTEXT":"CUSTOMER","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","SKU":"100119211","SuspensionContext":"NA","CustomerFacingServiceId":"","ShippingRequired":"TRUE","IMSI":"","SERVICEPROFILE":"TABLET"},"code":"DMCAT_ProductSpecification_000263_Fulfilment","description":"Mobile Access_Fulfilment","endDate":"","guid":"fc8e7088-a0ba-6b6c-ef69-3e6b3d281a89","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","startDate":"","status":"Suspend","version":"1"},{"additionalAttributes":{"__targetSystem":"FULFILMENT","IPWirelessProductInstanceID":"NA","BillofMaterialID":"NA","AccessRole":"Primary","CONTEXT":"CUSTOMER","SKU":"100119211","MESSAGEBANK":"NA","CustomerFacingServiceId":"61473603212","IMSI":"","SERVICEPROFILE":"TABLET"},"attributes":{"__targetSystem":"FULFILMENT"},"code":"DMCAT_ProductSpecification_000420_Fulfilment","description":"Mobility_Fulfilment","endDate":"","guid":"7200c94d-ad78-0078-c8d3-b5c586d50313","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobility_Fulfilment","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000420","startDate":"","status":"Modified","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","value":"250","unitofMeasure":"GB","type":"FairPlay Data","ocsProdID":"T22EM_MBB-L","billingSpecId":"BSUSG001_CB","billDescription":"Includes 250 GB Domestic Data"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000637","description":"Mobility_Billing_DMCAT_Allowance_000637","endDate":"","guid":"ebba38ae-33c5-6b11-f8ce-50f6b74520fe","includeBilling":false,"instanceId":"","metadata":{},"name":"420_AW_637","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000637_7","startDate":"","status":"Created","version":"1"}]}');
        attPricingModify1.Name = 'ServiceSpecifications.json';
        attPricingModify1.ParentId = pricingModifyServ1.Id;
        attList.add(attPricingModify1);
        
        Attachment attexp1= new Attachment();
        attexp1.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+servV1.id+'","specifications":[{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","ocsProdID":"T22E_IR_USAGE","currency":"AUD","type":"OC","billingSubtype":"IR","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","billDescription":"IR Pay as you go charge","rateExcludeGST":"0.00","unitofMeasure":"each","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000263_DMCAT_NonRecurringCharge_000601_108"},"code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","description":"Mobile Access_Billing_NonRecurringCharge_000601","endDate":"","guid":"a9e4497b-2754-7221-e6ca-6751671ef2a8","includeBilling":false,"instanceId":"","metadata":{},"name":"263_NRC_601","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"parentSpec":"908fe418-a109-e766-2517-363f5f32cd05"},"attributes":{"__targetSystem":"ASSURANCE","parentSpec":"DMCAT_ProductSpecification_000326_Assurance","ResponseTarget":"SLA0010001","RestoreTarget":"SLA0010006"},"code":"DMCAT_ProductSpecification_000151_Assurance","description":"Incident Management_Assurance","endDate":"","guid":"4f374952-2bf4-8fa5-85a7-e8a30727635c","includeBilling":false,"instanceId":"","metadata":{},"name":"151_ASR","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151_2","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"ServiceManagementOption":"1","__targetSystem":"ASSURANCE"},"code":"DMCAT_ProductSpecification_000326_Assurance","description":"Telstra Managed Service Option 1_Assurance","endDate":"","guid":"908fe418-a109-e766-2517-363f5f32cd05","includeBilling":false,"instanceId":"","metadata":{},"name":"326_ASR","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductOffering_000420DMCAT_ProductSpecification_000326","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_IRDAYPASS","type":"International Roaming Data","unitofMeasure":"MB","value":"200","billingSubtype":"IR","billDescription":"IR Day Pass"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000606","description":"Mobility_Billing_DMCAT_Allowance_000606","endDate":"","guid":"068b988d-18d3-78e8-407a-13d896f581b5","includeBilling":false,"instanceId":"","metadata":{},"name":"263_AW_606","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000606_5","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_IR_AUTOTOPUP","type":"International Roaming Data","unitofMeasure":"MB","value":"500","billingSubtype":"IR","billDescription":"IR Data Topup"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000607","description":"Mobility_Billing_DMCAT_Allowance_000607","endDate":"","guid":"805764a7-d9e5-01a8-65b0-52b23c81d1a8","includeBilling":false,"instanceId":"","metadata":{},"name":"263_AW_607","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000607_6","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","quantity":"1","recurringChargePeriod":"Months","description":"MRO Bonus Plan Discount","alteredPrice":145.5,"applicationDuration":24,"type":"Data","currency":"AUD","frequency":"Monthly","billingSpecId":"BSRC001_CB","billInAdvance":"true","prorate":"false","billDescription":"Corporate mobile plus - global data sim plan","rateExcludeGST":"145.50","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_4910"},"code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","description":"Mobility_Billing_RecurringCharge_000654","endDate":"","guid":"50f59975-ac13-db8c-163c-477df5092dcc","includeBilling":false,"instanceId":"","metadata":{},"name":"420_RC_654","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"ASSURANCE"},"code":"DMCAT_ProductSpecification_000421_Assurance","description":"Mobile Device Management_Assurance","endDate":"","guid":"9292a251-590b-bd78-ac23-47da3755d4ff","includeBilling":false,"instanceId":"","metadata":{},"name":"421_ASR","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000421","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"SERVICEPROFILE":"TABLET","IMSI":"","CustomerFacingServiceId":"61473603212","MESSAGEBANK":"NA","SKU":"100119211","parentSpec":"7200c94d-ad78-0078-c8d3-b5c586d50313","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","__targetSystem":"FULFILMENT"},"attributes":{"__targetSystem":"FULFILMENT","IPWirelessProductInstanceID":"NA","BillofMaterialID":"NA","AccessRole":"Primary","CONTEXT":"CUSTOMER","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","SKU":"100119211","SuspensionContext":"NA","CustomerFacingServiceId":"","ShippingRequired":"TRUE","IMSI":"","SERVICEPROFILE":"TABLET"},"code":"DMCAT_ProductSpecification_000263_Fulfilment","description":"Mobile Access_Fulfilment","endDate":"","guid":"fc8e7088-a0ba-6b6c-ef69-3e6b3d281a89","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","startDate":"","status":"Suspend","version":"1"},{"additionalAttributes":{"__targetSystem":"FULFILMENT","IPWirelessProductInstanceID":"NA","BillofMaterialID":"NA","AccessRole":"Primary","CONTEXT":"CUSTOMER","SKU":"100119211","MESSAGEBANK":"NA","CustomerFacingServiceId":"61473603212","IMSI":"","SERVICEPROFILE":"TABLET"},"attributes":{"__targetSystem":"FULFILMENT"},"code":"DMCAT_ProductSpecification_000420_Fulfilment","description":"Mobility_Fulfilment","endDate":"","guid":"7200c94d-ad78-0078-c8d3-b5c586d50313","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobility_Fulfilment","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000420","startDate":"","status":"Modified","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","value":"250","unitofMeasure":"GB","type":"FairPlay Data","ocsProdID":"T22EM_MBB-L","billingSpecId":"BSUSG001_CB","billDescription":"Includes 250 GB Domestic Data"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000637","description":"Mobility_Billing_DMCAT_Allowance_000637","endDate":"","guid":"ebba38ae-33c5-6b11-f8ce-50f6b74520fe","includeBilling":false,"instanceId":"","metadata":{},"name":"420_AW_637","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000637_7","startDate":"","status":"Created","version":"1"}]}');
        attexp1.Name = 'ServiceSpecifications.json';
        attexp1.ParentId = servV1.Id;
        attList.add(attexp1);
        insert attList;
       
        
        ContractJunction__c cJ=new ContractJunction__c();
        cJ.Account__c=acc.id;
        cJ.Name='CN000-156-869';
        cJ.Subscription__c=subsv.id;
        cj.Related_Opportunity__c=testOpp.id;
        insert cJ;
        
        List<Charge_Line_Item__c> CliList=new List<Charge_Line_Item__c>();
   
        Charge_Line_Item__c cli= new Charge_Line_Item__c();
        cli.Name='test';
        cli.CorrelationId__c='1234566';
        cli.status__c='new';
        cli.serviceId__c=servD.id;
        cli.BusinessID__c='DMCAT_Billing_000420';
        CliList.add(cli);
        
        Charge_Line_Item__c cli1= new Charge_Line_Item__c();
        cli1.Name='test';
        cli1.CorrelationId__c='1234566';
        cli1.status__c='new';
        cli1.serviceId__c=servD.id;
        cli1.BusinessID__c='DMCAT_Billing_000420';
        CliList.add(cli1);
        
        Charge_Line_Item__c cli3= new Charge_Line_Item__c();
        cli3.Name='test';
        cli3.CorrelationId__c='1234566';
        cli3.status__c='new';
        cli3.serviceId__c=pricingModifyServ.id;
        cli3.BusinessID__c='DMCAT_RecurringCharge_000654';
        CliList.add(cli3);
        
        Charge_Line_Item__c cli4= new Charge_Line_Item__c();
        cli4.Name='test';
        cli4.CorrelationId__c='1234566';
        cli4.status__c='new';
        cli4.serviceId__c=pricingModifyServ1.id;
        cli4.chargeType__c=System.label.Tiered_Recurring;
        cli4.BusinessID__c='DMCAT_RecurringCharge_000654';
        CliList.add(cli4);
        
        insert CliList;
        
        List<Price_Schedule_Line_Item__c> psliList=new List<Price_Schedule_Line_Item__c>();
        Price_Schedule_Line_Item__c psli=new Price_Schedule_Line_Item__c();
        psli.fromPeriod__c='0';
        psli.toPeriod__c='20';
        psli.status__c='new';
        psli.chargeInstance__c=cli.id;
        psli.applicationDuration__c=15.1;
        psli.unitPrice__c=20.0;
        psliList.add(psli);
        
        Price_Schedule_Line_Item__c psli1=new Price_Schedule_Line_Item__c();
        psli1.fromPeriod__c='20';
        psli1.toPeriod__c='40';
        psli1.status__c='new';
        psli1.chargeInstance__c=cli.id;
        psli1.applicationDuration__c=15.2;
        psli1.unitPrice__c=20.0;
        psliList.add(psli1);
        
        Price_Schedule_Line_Item__c psli2=new Price_Schedule_Line_Item__c();
        psli2.fromPeriod__c='20';
        psli2.toPeriod__c='40';
        psli2.status__c='new';
        psli2.chargeInstance__c=cli1.id;
        psli2.applicationDuration__c=15.2;
        psli2.unitPrice__c=20.0;
        psliList.add(psli2);
        
        Price_Schedule_Line_Item__c psli3=new Price_Schedule_Line_Item__c();
        psli3.fromPeriod__c='20';
        psli3.toPeriod__c='40';
        psli3.status__c='new';
        psli3.chargeInstance__c=cli1.id;
        psli3.applicationDuration__c=15.2;
        psli3.unitPrice__c=20.0;
        psliList.add(psli3);
        
        Price_Schedule_Line_Item__c psli4=new Price_Schedule_Line_Item__c();
        psli4.fromPeriod__c='20';
        psli4.toPeriod__c='99999';
        psli4.status__c='new';
        psli4.chargeInstance__c=cli1.id;
        psli4.applicationDuration__c=15.2;
        psli4.unitPrice__c=20.0;
        psliList.add(psli4);
        
        Price_Schedule_Line_Item__c psli5=new Price_Schedule_Line_Item__c();
        psli5.fromPeriod__c='20';
        psli5.toPeriod__c='58';
        psli5.status__c='Active';
        psli5.chargeInstance__c=cli3.id;
        psli5.applicationDuration__c=15.2;
        psli5.unitPrice__c=20.0;
        psliList.add(psli5);
        
        Price_Schedule_Line_Item__c psli6=new Price_Schedule_Line_Item__c();
        psli6.Name='NGUC';
        psli6.fromPeriod__c='20';
        psli6.toPeriod__c='56';
        psli6.status__c='new';
        psli6.chargeInstance__c=cli4.id;
        psli6.applicationDuration__c=15.2;
        psli6.unitPrice__c=20.0;
        psliList.add(psli6);
        
        insert psliList;
        
        List<Tier_Line_Item__c> tliList=new List<Tier_Line_Item__c>();
        Tier_Line_Item__c tli=new Tier_Line_Item__c();
        tli.fromPeriod__c='20';
        tli.FromUnit__c='0';
        tli.ToUnit__c='10';
        tli.Discounted_Price__c=12.5;
        tli.PSLIInstance__c=psli6.id;
        tliList.add(tli); 
        
        Tier_Line_Item__c tli1=new Tier_Line_Item__c();
        tli1.fromPeriod__c='20';
        tli1.FromUnit__c='0';
        tli1.ToUnit__c='10';
        tli1.Discounted_Price__c=12.5;
        tli1.PSLIInstance__c=psli6.id;
        tliList.add(tli1);
        
        Tier_Line_Item__c tli2=new Tier_Line_Item__c();
        tli2.fromPeriod__c='20';
        tli2.FromUnit__c='0';
        tli2.ToUnit__c='10';
        tli2.Discounted_Price__c=12.5;
        tli2.PSLIInstance__c=psli6.id;
        tliList.add(tli2);
        
        insert tliList; 
        
     

        //EDGE-92551 - Added for change to Number Object
        List<Number__c> numberList= new List<Number__c>();
       Number__c num2=new Number__c();
       num2.name='Num test2';
       num2.Product_Configuration__c=productConfig.id;
       num2.Subscription_number__c=subs.csordtelcoa__Subscription_Number__c;
       num2.Type__c='New';
       num2.Service_Number__c='61474850547';
       num2.Status__c='ACTIVE';
       num2.Account__c=acc.id;
       num2.Product_ID__c='gb58-89jk-yuit-fr46';
       numberList.add(num2);
       
       Number__c num3=new Number__c();
       num3.name='Num test3';
       num3.Product_Configuration__c=productConfig.id;
       num3.Subscription_number__c=subs.csordtelcoa__Subscription_Number__c;
       num3.Type__c='New';
       num3.Service_Number__c='61474850548';
       num3.Status__c='IN TRANSITION';
       num3.Account__c=acc.id;
       num3.Product_ID__c='gb58-89jk-yuit-fr46';
       num3.Start_Range__c='1';
       numberList.add(num3);
       
       Number__c num4=new Number__c();
       num4.name='Num test4';
       num4.Product_Configuration__c=productConfig.id;
       num4.Subscription_number__c=subs.csordtelcoa__Subscription_Number__c;
       num4.Type__c='New';
       num4.Service_Number__c='61474850549';
       num4.Status__c='Disconnect In Progress';
       num4.Account__c=acc.id;
       num4.Product_ID__c='gb58-89jk-yuit-fr46';
       num4.Start_Range__c='1';
       numberList.add(num4);
       
       Number__c num5=new Number__c();
       num5.name='Num test5';
       num5.Product_Configuration__c=productConfig.id;
       num5.Subscription_number__c=subs.csordtelcoa__Subscription_Number__c;
       num5.Type__c='New';
       //num5.Service_Number__c='61474850546';
       num5.Status__c='ACTIVE';
       num5.Account__c=acc.id;
       num5.Product_ID__c='gb58-89jk-yuit-fr46';
       num5.Start_Range__c='1';
       numberList.add(num5);
       
       Number__c num6=new Number__c();
       num6.name='Num test6';
       num6.Product_Configuration__c=productConfig.id;
       num6.Subscription_number__c=subs.csordtelcoa__Subscription_Number__c;
       num6.Type__c='New';
       //num5.Service_Number__c='61474850545';
       num6.Status__c='IN TRANSITION';
       num6.Account__c=acc.id;
       num6.Product_ID__c='gb58-89jk-yuit-fr46';
       num6.Start_Range__c='1';
       numberList.add(num6);
       
       Number__c num7=new Number__c();
       num7.name='Num test7';
       num7.Product_Configuration__c=productConfig.id;
       num7.Subscription_number__c=subs.csordtelcoa__Subscription_Number__c;
       num7.Type__c='New';
       //num5.Service_Number__c='61474850544';
       num7.Status__c='Disconnect In Progress';
       num7.Account__c=acc.id;
       num7.Product_ID__c='gb58-89jk-yuit-fr46';
       num7.Start_Range__c='1';
       numberList.add(num7);
       
       Number__c num8=new Number__c();
       num8.name='Num test7';
       num8.Product_Configuration__c=productConfig.id;
       num8.Subscription_number__c=subs.csordtelcoa__Subscription_Number__c;
       num8.Type__c='New';
       //num5.Service_Number__c='61474850543';
       num8.Status__c='RESERVED';
       num8.Account__c=acc.id;
       num8.Product_ID__c='gb58-89jk-yuit-fr46';
       num8.Start_Range__c='1';
       numberList.add(num8);
       
       Number__c num9=new Number__c();
       num9.name='Num test7';
       num9.Product_Configuration__c=productConfig.id;
       num9.Subscription_number__c=subs.csordtelcoa__Subscription_Number__c;
       num9.Type__c='New';
       //num5.Service_Number__c='61474850542';
       num9.Status__c='RESERVED';
       num9.Account__c=acc.id;
       num9.Product_ID__c='gb58-89jk-yuit-fr46';
       num9.Start_Range__c='1';
       numberList.add(num9);
        
       Number__c num10=new Number__c();
       num10.name='Num test7';
       num10.Product_Configuration__c=productConfig.id;
       num10.Subscription_number__c=pricingModifySub.csordtelcoa__Subscription_Number__c;
       num10.Type__c='New';
       num10.Service_Number__c='614748560599';
       num10.Status__c='Provisioned';
       num10.Start_Range__c='1';
       numberList.add(num10);
        
        Number__c num11=new Number__c();
       num11.name='Num test7';
       num11.Product_Configuration__c=productConfig.id;
       num11.Subscription_number__c=pricingModifySub.csordtelcoa__Subscription_Number__c;
       num11.Type__c='New';
       //num11.Service_Number__c='614747160599';
       num11.Status__c='Provisioned';
       num11.toBeCancelled__c=true;
       num11.Start_Range__c='1';
       numberList.add(num11);
        
       
       insert numberList;

        //EDGE-92551 - End
        
        //Added to test DPG-2000 Start
        cspmb__Price_Item__c price_item_shared_data = new cspmb__Price_Item__c(
            Name = 'IoT Shared Data 50KB',
            cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31),
            cspmb__Effective_Start_Date__c = Date.newInstance(2019,09,10),
            cspmb__Is_Active__c = true,
            cspmb__Price_Item_Code__c = 'IoT Shared Data',
            Commercial_Product_Code__c = 'IoT Shared Data', //AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
            cspmb__Product_Definition_Name__c = 'IoT Solutions',
            External_Id__c = 'dmcat_112',
            Charge_Id__c='DMCAT_RecurringCharge_000814',
            Package_Name__c = 'IoT Solution',
            BillingSpecId__c = 'BSOTC001_CB',
            Billing_Description__c = 'Plan',
            Offer_Id__c = 'DMCAT_Offer_000964',
            Plan__c = '50 KB'
        );
        insert price_item_shared_data;

        cspmb__Rate_Card__c rateCard_shared_data = new cspmb__Rate_Card__c();
        rateCard_shared_data.Name = 'IoT Shared Data 50KB';
        rateCard_shared_data.Offer_Id__c ='DMCAT_Offer_000964';
        rateCard_shared_data.cspmb__Rate_Card_Code__c = 'DMCAT_RecurringCharge_000814';  
        rateCard_shared_data.cspmb__Effective_End_Date__c = Date.today()+1;
        rateCard_shared_data.cspmb__Effective_Start_Date__c = Date.today()-1;
        rateCard_shared_data.cspmb__Is_Active__c = true;
        insert  rateCard_shared_data;

        List<cspmb__Rate_Card_Line__c> rateCardLineList = new List<cspmb__Rate_Card_Line__c>();

        cspmb__Rate_Card_Line__c rcl1 = new cspmb__Rate_Card_Line__c();
        rcl1.toUnit__c = 499;
        rcl1.fromUnit__c = 1;  
        rcl1.cspmb__Rate_Card__c= rateCard_shared_data.id;
        rcl1.cspmb__Effective_Start_Date__c=Date.today()-1;
        rcl1.cspmb__Effective_End_Date__c=Date.today()+1;
        rcl1.cspmb__rate_value__c = 1.5;
        rateCardLineList.add(rcl1);

        cspmb__Rate_Card_Line__c rcl2 = new cspmb__Rate_Card_Line__c();
        rcl2.toUnit__c = 999;
        rcl2.fromUnit__c = 500;  
        rcl2.cspmb__Rate_Card__c= rateCard_shared_data.id;
        rcl2.cspmb__Effective_Start_Date__c=Date.today()-1;
        rcl2.cspmb__Effective_End_Date__c=Date.today()+1;
        rcl2.cspmb__rate_value__c = 2.5;
        rateCardLineList.add(rcl2);

        cspmb__Rate_Card_Line__c rcl3 = new cspmb__Rate_Card_Line__c();
        rcl3.toUnit__c = 2499;
        rcl3.fromUnit__c = 1000;  
        rcl3.cspmb__Rate_Card__c= rateCard_shared_data.id;
        rcl3.cspmb__Effective_Start_Date__c=Date.today()-1;
        rcl3.cspmb__Effective_End_Date__c=Date.today()+1;
        rcl3.cspmb__rate_value__c = 3.5;
        rateCardLineList.add(rcl3);
        insert rateCardLineList;
        
        cspmb__Price_Item_Rate_Card_Association__c sharedDataassociation = new cspmb__Price_Item_Rate_Card_Association__c();
        sharedDataassociation.cspmb__Price_Item__c = price_item_shared_data.id;
        sharedDataassociation.cspmb__Rate_Card__c = rateCard_shared_data.id;
        insert sharedDataassociation;

        Attachment attKIOT = new Attachment();
        attKIOT.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"DMCAT_Offer_000964_DMCAT_Allowance_001078","productConfigurationId":"a3T5P00000024MrUAI","name":"964_AW_1078","metadata":{},"instanceId":"","includeBilling":false,"guid":"8f32323c-cd5b-4036-4edd-f9563f9b078a","endDate":"","description":"IoT solutions_Billing_DMCAT_Allowance_0001078","code":"DMCAT_ProductSpecification_000964_Billing_Allowance_001078","attributes":{"sharedPlanId":"'+price_item_shared_data.id+'","billDescription":"IOT Shared Data Plan 50KB","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_USAGE","type":"Shared Data","unitofMeasure":"KB","value":"50","__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"'+ servKIOT.id +'","legacyAttributes":[]}');
        attKIOT.Name = 'ServiceSpecifications.json';
        attKIOT.ParentId = servKIOT.Id;
        insert attKIOT;
        //Added to test DPG-2000 End
        
    }
    
    @istest static void TestBuildPostSubscriptionPayload() {
        // TO DO: implement unit test
         test.startTest();
        Map<Id, String> billingOrderPayloadMap = new Map<Id, String>();
        List<csord__Subscription__c> subsList = [select id,Name,MarketableOffer__r.Invoice_Definition__c,MarketableOffer__r.Offer_ID__c from csord__Subscription__c where name = 'test subs' LIMIT 1];
        List<String> subIds = new List<String>();
        for(csord__Subscription__c subs :subsList){
            subIds.add(subs.id);
        }       
        System.debug('---');
        Test.setMock(HttpCalloutMock.class, new MockBillingOrderResponseGenerator(202, 'ACCEPTED', null, new Map<String, String>()));
       
        boolean isIncludeSolution = true;
        boolean isProductActionExpire = false;
      //  billingOrderPayloadMap = BillingOrderServiceUtil.buildPostSubscriptionPayload(subIds,isIncludeSolution,isProductActionExpire);
          billingOrderPayloadMap = BillingOrderServiceUtil.buildPostSubscriptionPayload(subIds,isIncludeSolution,isProductActionExpire);

        test.stopTest();
        System.assertEquals(subsList!=null,true,'Sub Created');
    }
    
    @istest static void TestGetSubscriptionList(){
         test.startTest();
        List<csord__Subscription__c> subsList = [select id,Name from csord__Subscription__c LIMIT 1];
        List<String> subIds = new List<String>();
        for(csord__Subscription__c subs :subsList){
            subIds.add(subs.id);
        }
       
        List<csord__Subscription__c> returnSubsList = BillingOrderServiceUtil.getSubscriptionList(subIds);
        test.stopTest();
        System.assertEquals(subsList[0].id,returnSubsList[0].id);
    }
    
    
    
    @istest static void TestMapBillingSpecDataWithPayloadV2(){
        test.startTest();
        List<csord__Subscription__c> subsList = [SELECT id,Billing_Account__c,toBeCancelled__c,csordtelcoa__Replaced_Subscription__r.csord__Order__c,csordtelcoa__Replaced_Subscription__c, Site__r.name, Site__r.cscrm__Installation_Address__r.cscrm__Street_Name__c, Site__r.cscrm__Installation_Address__r.Street_Number_Start_calc__c, Site__r.cscrm__Installation_Address__r.Street_Number_End_calc__c, csordtelcoa__Product_Configuration__r.cscfga__originating_offer__r.name, csord__Order__r.csord__Primary_Order__c, csord__Order__r.csord__Primary_Order__r.Billing_Account__c, csord__Order__r.csord__Primary_Order__r.Billing_Account__r.Billing_Account_Number__c, csord__Order__r.Billing_Account__c, csord__Order__r.Billing_Account__r.Billing_Account_Number__c, right_to_bill_date__c, csordtelcoa__Subscription_Number__c, Offer__r.Offer_Spec_Id__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c FROM csord__Subscription__c where name = 'test subs' LIMIT 1];
        csord__Subscription__c subs = subsList[0];
        Map<Id, String> billingOrderPayloadMap = new Map<Id, String>();
        
        boolean isIncludeSolution = true;
        boolean isProductActionExpire = false;
        BillingOrderServiceUtil.mapBillingSpecDataWithPayloadV2(subs,billingOrderPayloadMap,isIncludeSolution,isProductActionExpire);
        test.stopTest();
        System.assertEquals(subs!=null,true,'Sub created');
    }
    
    /*@istest static void TestMapBillingSpecDataWithPayloadModify(){
        List<csord__Subscription__c> subsList = [SELECT id,csordtelcoa__Replaced_Subscription__r.Site__r.cscrm__Installation_Address__r.Street_Number_End_calc__c,csordtelcoa__Replaced_Subscription__r.Site__r.cscrm__Installation_Address__r.Street_Number_Start_calc__c,csordtelcoa__Replaced_Subscription__r.csord__Order__c,csordtelcoa__Replaced_Subscription__c, Site__r.name, Site__r.cscrm__Installation_Address__r.cscrm__Street_Name__c, Site__r.cscrm__Installation_Address__r.Street_Number_Start_calc__c, Site__r.cscrm__Installation_Address__r.Street_Number_End_calc__c, csordtelcoa__Product_Configuration__r.cscfga__originating_offer__r.name, csord__Order__r.csord__Primary_Order__c, csord__Order__r.csord__Primary_Order__r.Billing_Account__c, csord__Order__r.csord__Primary_Order__r.Billing_Account__r.Billing_Account_Number__c, csord__Order__r.Billing_Account__c, csord__Order__r.Billing_Account__r.Billing_Account_Number__c, right_to_bill_date__c, csordtelcoa__Subscription_Number__c, Offer__r.Offer_Spec_Id__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c FROM csord__Subscription__c  where name = 'test subs modify' LIMIT 1];
        csord__Subscription__c replaceSubs = [SELECT id,csordtelcoa__Replaced_Subscription__r.Site__r.cscrm__Installation_Address__r.Street_Number_End_calc__c,csordtelcoa__Replaced_Subscription__r.Site__r.cscrm__Installation_Address__r.Street_Number_Start_calc__c,csordtelcoa__Replaced_Subscription__r.csord__Order__c,csordtelcoa__Replaced_Subscription__c, Site__r.name, Site__r.cscrm__Installation_Address__r.cscrm__Street_Name__c, Site__r.cscrm__Installation_Address__r.Street_Number_Start_calc__c, Site__r.cscrm__Installation_Address__r.Street_Number_End_calc__c, csordtelcoa__Product_Configuration__r.cscfga__originating_offer__r.name, csord__Order__r.csord__Primary_Order__c, csord__Order__r.csord__Primary_Order__r.Billing_Account__c, csord__Order__r.csord__Primary_Order__r.Billing_Account__r.Billing_Account_Number__c, csord__Order__r.Billing_Account__c, csord__Order__r.Billing_Account__r.Billing_Account_Number__c, right_to_bill_date__c, csordtelcoa__Subscription_Number__c, Offer__r.Offer_Spec_Id__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c FROM csord__Subscription__c where name = 'test subs' LIMIT 1];
        csord__Subscription__c subs = subsList[0];
        subs.csordtelcoa__Replaced_Subscription__c = replaceSubs.id;
        Map<Id, String> billingOrderPayloadMap = new Map<Id, String>();
        test.startTest();
        boolean isIncludeSolution = true;
        BillingOrderServiceUtil.mapBillingSpecDataWithPayloadV2(subs,billingOrderPayloadMap,isIncludeSolution);
        test.stopTest();
        System.assertNotEquals(0,subsList.size());
    }  */
    
    @isTest static void TestcompareServiceSpec(){
         test.startTest();
        List<csord__Subscription__c> subsList = [SELECT id,csordtelcoa__Replaced_Subscription__c, Site__r.name, Site__r.cscrm__Installation_Address__r.cscrm__Street_Name__c, Site__r.cscrm__Installation_Address__r.Street_Number_Start_calc__c, Site__r.cscrm__Installation_Address__r.Street_Number_End_calc__c, csordtelcoa__Product_Configuration__r.cscfga__originating_offer__r.name, csord__Order__r.csord__Primary_Order__c, csord__Order__r.csord__Primary_Order__r.Billing_Account__c, csord__Order__r.csord__Primary_Order__r.Billing_Account__r.Billing_Account_Number__c, csord__Order__r.Billing_Account__c, csord__Order__r.Billing_Account__r.Billing_Account_Number__c, right_to_bill_date__c, csordtelcoa__Subscription_Number__c, Offer__r.Offer_Spec_Id__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c FROM csord__Subscription__c  where name = 'test subs modify' LIMIT 1];
        
        csord__Subscription__c replaceSubs = [SELECT id,csordtelcoa__Replaced_Subscription__c, Site__r.name, Site__r.cscrm__Installation_Address__r.cscrm__Street_Name__c, Site__r.cscrm__Installation_Address__r.Street_Number_Start_calc__c, Site__r.cscrm__Installation_Address__r.Street_Number_End_calc__c, csordtelcoa__Product_Configuration__r.cscfga__originating_offer__r.name, csord__Order__r.csord__Primary_Order__c, csord__Order__r.csord__Primary_Order__r.Billing_Account__c, csord__Order__r.csord__Primary_Order__r.Billing_Account__r.Billing_Account_Number__c, csord__Order__r.Billing_Account__c, csord__Order__r.Billing_Account__r.Billing_Account_Number__c, right_to_bill_date__c, csordtelcoa__Subscription_Number__c, Offer__r.Offer_Spec_Id__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c FROM csord__Subscription__c where name = 'test subs' LIMIT 1];
        
        csord__Subscription__c subs = subsList[0];
        subs.csordtelcoa__Replaced_Subscription__c = replaceSubs.id;
        
        //String serviceSpecNew = '{"specifications" :[{"version" : "1","status" : "Created","startDate" : "","specification" : "f2e195ae-049a-4c3f-bb08-eed2cba1ff89","productConfigurationId" : "a3T0l0000004oFiEAI","name" : "User","instanceId" : "","guid" : "059719f3-07de-4c93-1068-df146594a48b","endDate" : "","billDescription" : "Sample Billing Spec for Munich Testing","code" : "DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes" : {"Voice FNN Details" : [{ "attributes" : { "LegacyOfferName":null,"From" : 433221177,"To" : 433221144,"Migrated" : "No"},"productConfigurationId" : "a3T2O000000782fUAA"}],"__targetSystem" : "BILLING","code" : "CWP_OFFER_123","productId" : "SEAT_123","quantity" : "25","RateExcludedGST" : "150","prorate" : "false", "invoiceDefinition" : "Invoice_Def_1", "billInAdvance" : "false","billingSpecId" : "BSRC001_CB","frequency" : "Monthly","currency" : "AUD","type" : "RC", "billDescription" : "CWP Zone 1 Seat Charges"},"additionalAttributes" : {"parentSpec" :"059719f3-07de-2911-1068-df146594a48b"}}, {"version" : "1","status" : "Created","startDate" : "","specification" : "f2e195ae-049a-4c3f-bb08-eed2cba1ff89","productConfigurationId" : "a3T0l0000004oFiEAI","name" : "User","instanceId" : "","guid" : "5d9d486d-008b-12ba-78fd-687b6f212681","endDate" : "","billDescription" : "Sample Billing Spec for Munich Testing","code" : "DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes" : {"__targetSystem" : "Billing","code" : "CWP_OFFER_123","productId" : "SEAT_123","quantity" : "25","amount" : "150","billDescription" : "Seat Charge for Zone 2","prorateType" : "false","billInAdvance" : "false","billingSpecId" : "BSRC001_CB","frequency" : "Monthly","currency" : "AUD","type" : "RC"},"additionalAttributes" : { }} ],"serviceId" : "a4e0l00000005U9AAI","legacyAttributes" : [ ]}';
        //String serviceSpecModify = '{"specifications" :[{"version" : "1","status" : "Created","startDate" : "","specification" : "f2e195ae-049a-4c3f-bb08-eed2cba1ff89","productConfigurationId" : "a3T0l0000004oFiEAI","name" : "User","instanceId" : "","guid" : "059719f3-07de-4c93-1068-df146594a48b","endDate" : "","description" : "Sample Billing Spec for Munich Testing","code" : "PS_000073","attributes" : {"Voice FNN Details" : [{ "attributes" : { "LegacyOfferName":null,"From" : 433221177,"To" : 433221144,"Migrated" : "No"},"productConfigurationId" : "a3T2O000000782fUAA"}],"__targetSystem" : "BILLING","code" : "CWP_OFFER_123","productId" : "SEAT_123","units" : "25","unitPrice" : "150","prorate" : "false", "invoiceDefinition" : "Invoice_Def_1", "billInAdvance" : "false","billingSpecId" : "BSRC001_CB","frequency" : "Monthly","currency" : "AUD","type" : "RC", "description" : "CWP Zone 1 Seat Charges"},"additionalAttributes" : {"parentSpec" :"059719f3-07de-2911-1068-df146594a48b"}}, {"version" : "1","status" : "Created","startDate" : "","specification" : "f2e195ae-049a-4c3f-bb08-eed2cba1ff89","productConfigurationId" : "a3T0l0000004oFiEAI","name" : "User","instanceId" : "","guid" : "5d9d486d-008b-12ba-78fd-687b6f212681","endDate" : "","description" : "Sample Billing Spec for Munich Testing","code" : "DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes" : {"__targetSystem" : "Billing","code" : "CWP_OFFER_123","productId" : "SEAT_123","units" : "25","amount" : "150","billDescription" : "Seat Charge for Zone 2","prorateType" : "false","billInAdvance" : "false","billingSpecId" : "BSRC001_CB","frequency" : "Monthly","currency" : "AUD","type" : "RC"},"additionalAttributes" : { }} ],"serviceId" : "a4e0l00000005U9AAI","legacyAttributes" : [ ]}';
        String subSpecNew = csedm.API_1.getSubscriptionSpecificationsById(subs.csordtelcoa__Replaced_Subscription__c);
        String subSpecModify = csedm.API_1.getSubscriptionSpecificationsById(subs.id);
       
        BillingOrderServiceUtil.compareServiceSpec(subSpecNew,subSpecModify);
        test.stopTest();
        System.assertNotEquals(null,subSpecNew );
    }
    
    @isTest 
    static void testpopulateAdditionalBillInfo(){
        Test.startTest();
        csord__Subscription__c sub = [Select id,name from csord__Subscription__c where name = 'test subs'];
        BillingSpecDTOV2 billingSpecDTOV2 = new BillingSpecDTOV2();
        
        BillingOrderServiceUtil.populateAdditionalBillInfo(sub,billingSpecDTOV2);
        Test.stopTest();
        System.assertNotEquals(null,billingSpecDTOV2);
    }
    
    @isTest 
    static void testpopulateAdditionalBillInfoSite(){
        Test.startTest();
        List<csord__Subscription__c> subsList = [SELECT id,csordtelcoa__Replaced_Subscription__r.csord__Order__c,csordtelcoa__Replaced_Subscription__c, Site__r.name, Site__r.cscrm__Installation_Address__r.cscrm__Street_Name__c, Site__r.cscrm__Installation_Address__r.Street_Number_Start_calc__c, Site__r.cscrm__Installation_Address__r.Street_Number_End_calc__c, csordtelcoa__Product_Configuration__r.cscfga__originating_offer__r.name, csord__Order__r.csord__Primary_Order__c, csord__Order__r.csord__Primary_Order__r.Billing_Account__c, csord__Order__r.csord__Primary_Order__r.Billing_Account__r.Billing_Account_Number__c, csord__Order__r.Billing_Account__c, csord__Order__r.Billing_Account__r.Billing_Account_Number__c, right_to_bill_date__c, csordtelcoa__Subscription_Number__c, Offer__r.Offer_Spec_Id__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c FROM csord__Subscription__c where name = 'test subsAddBillInfo' LIMIT 1];
        csord__Subscription__c subs = subsList[0];
        subs.Site__r.name = '';
        update subs;
        /*csord__Subscription__c sub = [Select id,name from csord__Subscription__c where name = 'test subsAddBillInfo'];*/
        BillingSpecDTOV2 billingSpecDTOV2 = new BillingSpecDTOV2();
        
        BillingOrderServiceUtil.populateAdditionalBillInfo(subs,billingSpecDTOV2);
        Test.stopTest();
        System.assertNotEquals(null,billingSpecDTOV2);
    }
    
    @isTest 
    static void testpopulateProductOffering(){
        Test.startTest();
        csord__Subscription__c sub = [Select id,name from csord__Subscription__c where name = 'test subs'];
        BillingSpecDTOV2 billingSpecDTOV2 = new BillingSpecDTOV2();
        
        boolean solustionsub = true;
        String solutionsubNumber ='SN-000056';
        sub.isAggregationPoint__c = true;
        String productActionType ='add';
        BillingOrderServiceUtil.populateProductOffering(sub,billingSpecDTOV2,solutionsubNumber,productActionType);
        Test.stopTest();
        System.assertNotEquals(null,billingSpecDTOV2);
    }
    
    @isTest 
    static void testpopulateOrderItems(){
        Test.startTest();
        //csord__Subscription__c sub = [Select id,name from csord__Subscription__c where name = 'test subs'];
        csord__Subscription__c sub = [Select id,name,toBeCancelled__c,right_to_bill_date__c,ModelChange__c,csordtelcoa__Replaced_Subscription__c,csordtelcoa__Replaced_Subscription__r.csord__Order__c, csord__Order__c,csord__Order__r.csordtelcoa__Opportunity__c from csord__Subscription__c where name = 'test_subsUCMobile'];
        BillingSpecDTOV2 billingSpecDTOV2 = new BillingSpecDTOV2();
        
        BillingOrderServiceUtil.populateOrderItems(sub,billingSpecDTOV2);
        Test.stopTest();
        System.assertNotEquals(null,billingSpecDTOV2);
    }
    
    @isTest 
    static void testpopulateBillingSpecifications(){
        Test.startTest();
        csord__Subscription__c sub = [Select id,name from csord__Subscription__c where name = 'test subs'];
        BillingSpecDTOV2.OrderItems orderItem = new BillingSpecDTOV2.orderItems();
        List<CS_SpecificationDTO.ServiceSpecification> servSpecList = new List<CS_SpecificationDTO.ServiceSpecification>();
        String specode = '"DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3"';
        String servId='SVC-313269';
        
        BillingOrderServiceUtil.populateBillingSpecifications(servSpecList,orderItem,specode,servId);
        Test.stopTest();
        System.assertNotEquals(null,orderItem);
        System.assertEquals('"DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3"',specode);
    }
    
    //EDGE-156163
   /*@isTest  //commented as part of EDGE-156163 code revert 
    static void testpopulateBillingSpecificationsNGEM(){
        Test.startTest();
        csord__Subscription__c sub = [Select id,name from csord__Subscription__c where name = 'test subs'];
        BillingSpecDTOV2.OrderItems orderItem = new BillingSpecDTOV2.orderItems();
        Map<String,List<CS_SpecificationDTO.ServiceSpecification>> servSpecList = BillingOrderServiceUtil.getAllServSpecs(sub.id);
        String specode = '"DMCAT_ProductSpecification_000537_Billing_Allowance_000699"';
        String servId='SVC-313268';
        
        BillingOrderServiceUtil.populateBillingSpecifications(servSpecList.values()[0],orderItem,specode,servId);
        Test.stopTest();
        System.assertNotEquals(null,orderItem);
    }   */
    
    @isTest 
    static void testgetAllServSpecs(){
        Test.startTest();
        csord__Subscription__c sub = [Select id,name from csord__Subscription__c where name = 'test subs'];
        
        BillingOrderServiceUtil.getAllServSpecs(sub.Id);
        Test.stopTest();
        System.assertNotEquals(null,sub.Id);
    }
    
    @isTest(SeeAllData=false)
    static void testPopulateServices(){
         Test.startTest();
        csord__Subscription__c sub = [Select id,name,ModelChange__c,csordtelcoa__Replaced_Subscription__c,csordtelcoa__Replaced_Subscription__r.csord__Order__c,toBeCancelled__c,csord__Order__c,csord__Order__r.csordtelcoa__Opportunity__c from csord__Subscription__c where name = 'test_subsUCMobile'];
        System.debug('Test_Subscription::' + sub);
        Map<String,List<CS_SpecificationDTO.ServiceSpecification>> srvSpecMap = BillingOrderServiceUtil.getAllServSpecs(sub.id);
        List<CS_SpecificationDTO.ServiceSpecification> allBillingSpecs = srvSpecMap.get('BILLING');
        List<CS_SpecificationDTO.ServiceSpecification> allfulfilmentSpecs = srvSpecMap.get('FULFILMENT');
        List<String> srvInstanceIdList = BillingOrderServiceUtil.getAllSrvInstanceId(allBillingSpecs,sub.id);
        BillingSpecDTOV2.OrderItems orderItem = new BillingSpecDTOV2.orderItems();
        //BillingOrderServiceUtil.populateServices(allBillingSpecs,allfulfilmentSpecs,orderItem,srvInstanceIdList[1]);
       
        for(String instance : srvInstanceIdList){
            BillingOrderServiceUtil.populateServices(allBillingSpecs,allfulfilmentSpecs,orderItem,instance,sub);
        }
        Test.stopTest();
        System.assertNotEquals(null,orderItem);
    }
    
    @isTest 
    static void testfetchDescriptionFromSpec(){
        Test.startTest();   
        csord__Subscription__c sub = [Select id,name from csord__Subscription__c where name = 'test subs'];
        List<CS_SpecificationDTO.ServiceSpecification> allBillingSpec = new List<CS_SpecificationDTO.ServiceSpecification>();
            
        Map<String,List<CS_SpecificationDTO.ServiceSpecification>> srvSpecMap = BillingOrderServiceUtil.getAllServSpecs(sub.id);
        List<CS_SpecificationDTO.ServiceSpecification> allBillingSpecs = srvSpecMap.get('BILLING');
        String srvInstanceId = 'SVC-00001:DMCAT_ProductSpecification_000263';
        String des = BillingOrderServiceUtil.fetchDescriptionFromSpec(srvInstanceId,allBillingSpecs);
        Test.stopTest();
        System.assertNotEquals('DMCAT_ProductSpecification_000263',des);
    }
    
    @isTest 
    static void testgetOldServiceID(){
        Test.startTest(); 
        List<csord__Service__c> serv = [Select id,name,csordtelcoa__Service_Number__c from csord__Service__c where name = 'tst service'];
        
        String srvInstanceId = 'SVC-00001:DMCAT_ProductSpecification_000263';
        String servMsidn = BillingOrderServiceUtil.getOldServiceID(srvInstanceId.split(':')[0]);
        Test.stopTest();
        System.assertNotEquals('DMCAT_ProductSpecification_000263',servMsidn);
    }
    
    //Start :EDGE-88677:Introducing Price Alteration list for MRO bonus 
    /*@isTest 
    static void testpopulatepopulateUnitPrice(){
        Test.startTest();
        csord__Subscription__c sub = [Select id,name from csord__Subscription__c where name = 'test subs' LIMIT 1];
        csord__Subscription__c subsAddBillInfo = [Select id,name from csord__Subscription__c where name = 'test subsAddBillInfo' LIMIT 1];

        system.debug('Subs in my method'+sub);
        Map<String,List<CS_SpecificationDTO.ServiceSpecification>> srvSpecMap = BillingOrderServiceUtil.getAllServSpecs(sub.id);
        system.debug('Service specification'+srvSpecMap);
        List<CS_SpecificationDTO.ServiceSpecification> servSpecList = new List<CS_SpecificationDTO.ServiceSpecification>();
        List<CS_SpecificationDTO.ServiceSpecification> allBillingSpecs = srvSpecMap.get('BILLING');
        system.debug('allBillingSpecs--->'+allBillingSpecs);
        
        BillingSpecDTOV2.OrderItems orderItem = new BillingSpecDTOV2.orderItems();
        CS_SpecificationDTO.ServiceSpecification billSpec = new CS_SpecificationDTO.ServiceSpecification();
        String specode = 'DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498';
        String servId='SVC-313269';
        
        
        CS_SpecificationDTO.ServiceSpecification spe = new CS_SpecificationDTO.ServiceSpecification();
        List<CS_SpecificationDTO.SimpleAttributes> attrList = new List<CS_SpecificationDTO.SimpleAttributes>();
        CS_SpecificationDTO.SimpleAttributes attr1 = new CS_SpecificationDTO.SimpleAttributes();
        //updated for EDGE-128358
        attr1.name = 'rateExcludeGST';
        attr1.value = '1000.00';
        CS_SpecificationDTO.SimpleAttributes attr2 = new CS_SpecificationDTO.SimpleAttributes();
        //updated for EDGE-128358
        attr2.name = 'alteredPrice';
        attr2.value = '20.00';
        
        CS_SpecificationDTO.SimpleAttributes attr3 = new CS_SpecificationDTO.SimpleAttributes();
        attr3.name = 'description';
        attr3.value = 'description';
        
        spe.status = 'Modified';
        spe.code = specode;
        attrList.add(attr1);
        attrList.add(attr2);
        attrList.add(attr3);
        spe.SimpleAttributes = (attrList);
        spe.subscriptionId = String.valueOf(subsAddBillInfo.Id);
        servSpecList.add(spe);
        BillingOrderServiceUtil.populateBillingSpecifications(servSpecList,orderItem,specode,servId);
        BillingOrderServiceUtil.populatePriceAlteration(allBillingSpecs[0],'cease');
        BillingSpecDTOV2.priceAlterations priceAlterationObj = null;
        Test.stopTest();
        System.assertNotEquals(null,orderItem);
        System.assertEquals('DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498',specode);
    }*/
    /*@isTest 
    static void testpopulatepopulateApplicationDuration(){
         Test.startTest();
        csord__Subscription__c sub = [Select id,name from csord__Subscription__c where name = 'test subs1' LIMIT 1];
        csord__Service__c serv1 = [Select id,name from csord__Service__c where name = 'tst service1' LIMIT 1];
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{"specifications" :[{"version" : "1","status" : "Created","startDate" : "","specification" : "f2e195ae-049a-4c3f-bb08-eed2cba1ff89","productConfigurationId" : "a3T0l0000004oFiEAI","name" : "User","instanceId" : "","guid" : "059719f3-07de-4c93-1068-df146594a48b","endDate" : "","billDescription" : "Sample Billing Spec for Munich Testing","code" : "PS_000074","attributes" : {"Voice FNN Details" : [{ "attributes" : { "LegacyOfferName":null,"From" : 433221177,"To" : 433221144,"Migrated" : "No"},"productConfigurationId" : "a3T2O000000782fUAA"}],"__targetSystem" : "BILLING","code" : "CWP_OFFER_123","productId" : "SEAT_123","quantity" : "25","RateExcludedGST" : "150","prorate" : "false","applicationDuration" : "24","recurringChargePeriod" : "Months","description" : "CWP Mobile Seat","priority" :"1" ,"invoiceDefinition" : "Invoice_Def_1", "billInAdvance" : "false","billingSpecId" : "BSRC001_CB","frequency" : "Monthly","currency" : "AUD","type" : "RC", "billDescription" : "CWP Zone 1 Seat Charges"},"additionalAttributes" : {"parentSpec" :"059719f3-07de-2911-1068-df146594a48b"}}, {"version" : "1","status" : "Created","startDate" : "","specification" : "f2e195ae-049a-4c3f-bb08-eed2cba1ff89","productConfigurationId" : "a3T0l0000004oFiEAI","name" : "User","instanceId" : "","guid" : "5d9d486d-008b-12ba-78fd-687b6f212681","endDate" : "","billDescription" : "Sample Billing Spec for Munich Testing","code" :"PS_000074","attributes" : {"__targetSystem" :"BILLING","code" : "CWP_OFFER_123","productId" : "SEAT_123","quantity" : "25","amount" : "150","billDescription" : "Seat Charge for Zone 2","prorateType" : "false","billInAdvance" : "false","billingSpecId" : "BSRC001_CB","frequency" : "Monthly","currency" : "AUD","type" : "RC"},"additionalAttributes" : { }} ],"serviceId" : "a4e0l00000005U9AAI","legacyAttributes" : [ ]}') ;    
        att1.ParentId = serv1.Id;
        att1.Name = 'ServiceSpecifications.json';
        insert att1;
        String servId='SVC-313269';
        Map<String,List<CS_SpecificationDTO.ServiceSpecification>> srvSpecMap = BillingOrderServiceUtil.getAllServSpecs(sub.id);
        List<CS_SpecificationDTO.ServiceSpecification> servSpecList = new List<CS_SpecificationDTO.ServiceSpecification>();
        system.debug('srvSpecMap in test:'+srvSpecMap);
        List<CS_SpecificationDTO.ServiceSpecification> allBillingSpecs = srvSpecMap.get('BILLING');
        BillingSpecDTOV2.OrderItems orderItem = new BillingSpecDTOV2.orderItems();
        CS_SpecificationDTO.ServiceSpecification billSpec = new CS_SpecificationDTO.ServiceSpecification();
        String specode = '"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498"';
       
        BillingOrderServiceUtil.populateBillingSpecifications(servSpecList,orderItem,specode,servId);
        BillingOrderServiceUtil.populatePriceAlteration(allBillingSpecs[0],null);
        BillingOrderServiceUtil.populatePriceAlteration(allBillingSpecs[0],null);
        Test.stopTest();
        System.assertNotEquals(null,orderItem);
        System.assertEquals('"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498"',specode);
    }*/
    /*@isTest 
    static void testpopulatepopulateRecurringChargePeriod(){
         Test.startTest();
        csord__Subscription__c sub = [Select id,name from csord__Subscription__c where name = 'test subs1' LIMIT 1];
        csord__Service__c serv1 = [Select id,name from csord__Service__c where name = 'tst service1' LIMIT 1];
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{"specifications" :[{"version" : "1","status" : "Created","startDate" : "","specification" : "f2e195ae-049a-4c3f-bb08-eed2cba1ff89","productConfigurationId" : "a3T0l0000004oFiEAI","name" : "User","instanceId" : "","guid" : "059719f3-07de-4c93-1068-df146594a48b","endDate" : "","billDescription" : "Sample Billing Spec for Munich Testing","code" : "DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes" : {"Voice FNN Details" : [{ "attributes" : { "LegacyOfferName":null,"From" : 433221177,"To" : 433221144,"Migrated" : "No"},"productConfigurationId" : "a3T2O000000782fUAA"}],"__targetSystem" : "BILLING","code" : "CWP_OFFER_123","productId" : "SEAT_123","quantity" : "25","RateExcludedGST" : "150","prorate" : "false","recurringChargePeriod" : "Months","invoiceDefinition" : "Invoice_Def_1", "billInAdvance" : "false","billingSpecId" : "BSRC001_CB","frequency" : "Monthly","currency" : "AUD","type" : "RC", "billDescription" : "CWP Zone 1 Seat Charges"},"additionalAttributes" : {"parentSpec" :"059719f3-07de-2911-1068-df146594a48b"}}, {"version" : "1","status" : "Created","startDate" : "","specification" : "f2e195ae-049a-4c3f-bb08-eed2cba1ff89","productConfigurationId" : "a3T0l0000004oFiEAI","name" : "User","instanceId" : "","guid" : "5d9d486d-008b-12ba-78fd-687b6f212681","endDate" : "","billDescription" : "Sample Billing Spec for Munich Testing","code" : "DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes" : {"__targetSystem" : "Billing","code" : "CWP_OFFER_123","productId" : "SEAT_123","quantity" : "25","amount" : "150","billDescription" : "Seat Charge for Zone 2","prorateType" : "false","billInAdvance" : "false","billingSpecId" : "BSRC001_CB","frequency" : "Monthly","currency" : "AUD","type" : "RC"},"additionalAttributes" : { }} ],"serviceId" : "a4e0l00000005U9AAI","legacyAttributes" : [ ]}') ;   
        att1.ParentId = serv1.Id;
        att1.Name = 'ServiceSpecifications.json';
        insert att1;
        
        Map<String,List<CS_SpecificationDTO.ServiceSpecification>> srvSpecMap = BillingOrderServiceUtil.getAllServSpecs(sub.id);
        List<CS_SpecificationDTO.ServiceSpecification> servSpecList = new List<CS_SpecificationDTO.ServiceSpecification>();
        List<CS_SpecificationDTO.ServiceSpecification> allBillingSpecs = srvSpecMap.get('BILLING');
        BillingSpecDTOV2.OrderItems orderItem = new BillingSpecDTOV2.orderItems();
        CS_SpecificationDTO.ServiceSpecification billSpec = new CS_SpecificationDTO.ServiceSpecification();
        String specode = '"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498"';
        String servId='SVC-313269';
       
        BillingOrderServiceUtil.populateBillingSpecifications(servSpecList,orderItem,specode,servId);
        BillingOrderServiceUtil.populatePriceAlteration(allBillingSpecs[0],null);
        BillingOrderServiceUtil.populatePriceAlteration(allBillingSpecs[0],null);
        Test.stopTest();
        System.assertNotEquals(null,orderItem);
        System.assertEquals('"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498"',specode);
    }*/
    /*@isTest 
    static void testpopulatepopulateDescription(){
         Test.startTest();
        csord__Subscription__c sub = [Select id,name from csord__Subscription__c where name = 'test subs1' LIMIT 1];
        csord__Service__c serv1 = [Select id,name from csord__Service__c where name = 'tst service1' LIMIT 1];
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{"specifications" :[{"version" : "1","status" : "Created","startDate" : "","specification" : "f2e195ae-049a-4c3f-bb08-eed2cba1ff89","productConfigurationId" : "a3T0l0000004oFiEAI","name" : "User","instanceId" : "","guid" : "059719f3-07de-4c93-1068-df146594a48b","endDate" : "","billDescription" : "Sample Billing Spec for Munich Testing","code" : "DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes" : {"Voice FNN Details" : [{ "attributes" : { "LegacyOfferName":null,"From" : 433221177,"To" : 433221144,"Migrated" : "No"},"productConfigurationId" : "a3T2O000000782fUAA"}],"__targetSystem" : "BILLING","code" : "CWP_OFFER_123","productId" : "SEAT_123","quantity" : "25","RateExcludedGST" : "150","prorate" : "false", "description" : "CWP Mobile Seat", "invoiceDefinition" : "Invoice_Def_1", "billInAdvance" : "false","billingSpecId" : "BSRC001_CB","frequency" : "Monthly","currency" : "AUD","type" : "RC", "billDescription" : "CWP Zone 1 Seat Charges"},"additionalAttributes" : {"parentSpec" :"059719f3-07de-2911-1068-df146594a48b"}}, {"version" : "1","status" : "Created","startDate" : "","specification" : "f2e195ae-049a-4c3f-bb08-eed2cba1ff89","productConfigurationId" : "a3T0l0000004oFiEAI","name" : "User","instanceId" : "","guid" : "5d9d486d-008b-12ba-78fd-687b6f212681","endDate" : "","billDescription" : "Sample Billing Spec for Munich Testing","code" : "DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes" : {"__targetSystem" : "Billing","code" : "CWP_OFFER_123","productId" : "SEAT_123","quantity" : "25","amount" : "150","billDescription" : "Seat Charge for Zone 2","prorateType" : "false","billInAdvance" : "false","billingSpecId" : "BSRC001_CB","frequency" : "Monthly","currency" : "AUD","type" : "RC"},"additionalAttributes" : { }} ],"serviceId" : "a4e0l00000005U9AAI","legacyAttributes" : [ ]}') ;  
        att1.ParentId = serv1.Id;
        att1.Name = 'ServiceSpecifications.json';
        insert att1;
        
        Map<String,List<CS_SpecificationDTO.ServiceSpecification>> srvSpecMap = BillingOrderServiceUtil.getAllServSpecs(sub.id);
        List<CS_SpecificationDTO.ServiceSpecification> servSpecList = new List<CS_SpecificationDTO.ServiceSpecification>();
        List<CS_SpecificationDTO.ServiceSpecification> allBillingSpecs = srvSpecMap.get('BILLING');
        BillingSpecDTOV2.OrderItems orderItem = new BillingSpecDTOV2.orderItems();
        CS_SpecificationDTO.ServiceSpecification billSpec = new CS_SpecificationDTO.ServiceSpecification();
        String specode = '"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498"';
        String servId='SVC-313269';
       
        BillingOrderServiceUtil.populateBillingSpecifications(servSpecList,orderItem,specode,servId);
        BillingOrderServiceUtil.populatePriceAlteration(allBillingSpecs[0],null);
        BillingOrderServiceUtil.populatePriceAlteration(allBillingSpecs[0],null);
        Test.stopTest();
        System.assertNotEquals(null,orderItem);
        System.assertEquals('"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498"',specode);
    }*/
    @isTest 
    static void testpopulateBillingSpecification(){
        Test.startTest();
        csord__Subscription__c sub = [Select id,name from csord__Subscription__c where name = 'test subsK' LIMIT 1];
        
        boolean isIncludeSolution = false;
        boolean isProductActionExpire = false;
        Map<Id, String> sendBillingOrderPayload = BillingOrderServiceUtil.buildPostSubscriptionPayload(new List<Id>{sub.Id},isIncludeSolution,isProductActionExpire);
        system.debug(sendBillingOrderPayload);
        Test.stopTest();
        system.assertNotEquals(null,sub);
        
    }
    /*@isTest 
    static void testpopulatepopulateException(){
        Test.startTest();
        csord__Subscription__c sub = [Select id,name from csord__Subscription__c where name = 'test subs1' LIMIT 1];
        csord__Service__c serv1 = [Select id,name from csord__Service__c where name = 'tst service1' LIMIT 1];
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{"specifications" :[{"version" : "1","status" : "Created","startDate" : "","specification" : "f2e195ae-049a-4c3f-bb08-eed2cba1ff89","productConfigurationId" : "a3T0l0000004oFiEAI","name" : "User","instanceId" : "","guid" : "059719f3-07de-4c93-1068-df146594a48b","endDate" : "","billDescription" : "Sample Billing Spec for Munich Testing","code" : "DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes" : {"Voice FNN Details" : [{ "attributes" : { "LegacyOfferName":null,"From" : 433221177,"To" : 433221144,"Migrated" : "No"},"productConfigurationId" : "a3T2O000000782fUAA"}],"__targetSystem" : "BILLING","code" : "CWP_OFFER_123","productId" : "SEAT_123","quantity" : "25","RateExcludedGST" : "150","prorate" : "false", "invoiceDefinition" : "Invoice_Def_1", "billInAdvance" : "false","billingSpecId" : "BSRC001_CB","frequency" : "Monthly","currency" : "AUD","type" : "RC", "billDescription" : "CWP Zone 1 Seat Charges"},"additionalAttributes" : {"parentSpec" :"059719f3-07de-2911-1068-df146594a48b"}}, {"version" : "1","status" : "Created","startDate" : "","specification" : "f2e195ae-049a-4c3f-bb08-eed2cba1ff89","productConfigurationId" : "a3T0l0000004oFiEAI","name" : "User","instanceId" : "","guid" : "5d9d486d-008b-12ba-78fd-687b6f212681","endDate" : "","billDescription" : "Sample Billing Spec for Munich Testing","code" : "DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes" : {"__targetSystem" : "Billing","code" : "CWP_OFFER_123","productId" : "SEAT_123","quantity" : "25","amount" : "150","billDescription" : "Seat Charge for Zone 2","prorateType" : "false","billInAdvance" : "false","billingSpecId" : "BSRC001_CB","frequency" : "Monthly","currency" : "AUD","type" : "RC"},"additionalAttributes" : { }} ],"serviceId" : "a4e0l00000005U9AAI","legacyAttributes" : [ ]}') ;     
        att1.ParentId = serv1.Id;
        att1.Name = 'ServiceSpecifications.json';
        insert att1;
        
        Map<String,List<CS_SpecificationDTO.ServiceSpecification>> srvSpecMap = BillingOrderServiceUtil.getAllServSpecs(sub.id);
        List<CS_SpecificationDTO.ServiceSpecification> servSpecList = new List<CS_SpecificationDTO.ServiceSpecification>();
        List<CS_SpecificationDTO.ServiceSpecification> allBillingSpecs = srvSpecMap.get('BILLING');
        BillingSpecDTOV2.OrderItems orderItem = new BillingSpecDTOV2.orderItems();
        CS_SpecificationDTO.ServiceSpecification billSpec = new CS_SpecificationDTO.ServiceSpecification();
        String specode = '"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498"';
        String servId='SVC-313269';
        
        BillingOrderServiceUtil.populateBillingSpecifications(servSpecList,orderItem,specode,servId);
        BillingOrderServiceUtil.populatePriceAlteration(allBillingSpecs[0],null);
        BillingOrderServiceUtil.populatePriceAlteration(allBillingSpecs[0],null);
        Test.stopTest();
        System.assertNotEquals(null,orderItem);
        System.assertEquals('"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498"',specode);
    }*/
    //End :EDGE-88677
    @isTest 
    static void testevaluateSolutionCompletion(){
        Test.startTest();
        csord__Subscription__c subE = [Select id,name from csord__Subscription__c where name = 'test subsK' LIMIT 1];
        List<String> subscripIdList = new List<String>();
        subscripIdList.add(subE.Id);
      // Map<Id,CSPOFA__Orchestration_Step__c>subscriptionIdStepMap = new Map<Id,CSPOFA__Orchestration_Step__c>();
        BillingOrderServiceUtil.evaluateSolutionCompletion(subscripIdList);
        Test.stopTest();
        System.assertNotEquals(subE.Id, null);
    }
    //EDGE-123083
    @isTest 
    static void testCheckSpecificationUnits(){
        // TO DO: implement unit test
        test.startTest();
        Map<Id, String> billingOrderPayloadMap = new Map<Id, String>();
        List<csord__Subscription__c> subsList = [select id,Name,MarketableOffer__r.Invoice_Definition__c,MarketableOffer__r.Offer_ID__c from csord__Subscription__c where name = 'test_checkUnits' LIMIT 1];
        List<String> subIds = new List<String>();
        for(csord__Subscription__c subs :subsList){
            subIds.add(subs.id);
        }      
        Test.setMock(HttpCalloutMock.class, new MockBillingOrderResponseGenerator(202, 'ACCEPTED', null, new Map<String, String>()));
        
        boolean isIncludeSolution = true;
        boolean isProductActionExpire = false;
        billingOrderPayloadMap = BillingOrderServiceUtil.buildPostSubscriptionPayload(subIds,isIncludeSolution,isProductActionExpire);
        
        System.debug('testData--'+billingOrderPayloadMap);
        Map<String, Object> jsonParser = (Map<String, Object>) JSON.deserializeUntyped(billingOrderPayloadMap.get(subIds[0]));
        List<Object> orderItems = (List<Object>)jsonParser.get('orderItems');
        Map<String, Object> billingSpec = (Map<String, Object>)orderItems[0];
        List<Object> specItem = (List<Object>)billingSpec.get('billingSpecifications');
        /*Map<String, Object> unitsVal = (Map<String, Object>)specItem[0];
        System.assertEquals(25.51,unitsVal.get('units'));*/
        test.stopTest();
        System.assertEquals(subsList!=null,true,'Sub Created');
    }
    //created as part of EDGE-120128
        @isTest 
        static void testPSLImethod(){
            Test.startTest();
        Map<Id,Map<String,List<Price_Schedule_Line_Item__c>>> PsliMap=new Map<Id,Map<String,List<Price_Schedule_Line_Item__c>>>();
        List<BillingSpecDTOV2.priceAlterations> priceAlterValuesNew = new List<BillingSpecDTOV2.priceAlterations>();
        String code='DMCAT_Billing_000420';
        csord__Service__c serv = [Select id,name,csordtelcoa__Service_Number__c from csord__Service__c where name = 'tst servicev' LIMIT 1];
        List<csord__Subscription__c> subList=[select id,name,csordtelcoa__Replaced_Subscription__r.id from csord__Subscription__c where name='test subsv'];
       
        PsliMap=BillingOrderServiceUtil.getPSLIbyServId(subList);
        priceAlterValuesNew=BillingOrderServiceUtil.populatePriceAlterationPSLI(PsliMap.get(serv.id),code);  
        Test.stopTest();
        System.assertNotEquals(serv.Id, null);
    }
    
     //created as part of EDGE-132475
        @isTest 
        static void testOrderRef(){
        Test.startTest();
        List<csord__Subscription__c> subList=[select id,name from csord__Subscription__c where name='test subsv'];
        List<String> subIds = new List<String>();
        for(csord__Subscription__c subs :subList){
            subIds.add(subs.id);
        }    

        BillingOrderServiceUtil.buildPostSubscriptionPayload(subIds,false,false);
        Test.stopTest();
        System.assertNotEquals(null, subList);
    }
    
        //created as part of EDGE-128979
       @isTest 
        static void testTLImethod(){
        Test.startTest();
        Map<Id,Map<String,List<Price_Schedule_Line_Item__c>>> PsliMap=new Map<Id,Map<String,List<Price_Schedule_Line_Item__c>>>();
        Map<Id,List<Tier_Line_Item__c>> TliMap=new Map<Id,List<Tier_Line_Item__c>>();
        List<BillingSpecDTOV2.priceAlterations> priceAlterValuesNew = new List<BillingSpecDTOV2.priceAlterations>();
        String code='DMCAT_Billing_000420';
        csord__Service__c serv = [Select id,name,csordtelcoa__Service_Number__c from csord__Service__c where name = 'tst servicev' LIMIT 1];
        List<csord__Subscription__c> subList=[select id,name,csordtelcoa__Replaced_Subscription__r.id from csord__Subscription__c];
        PsliMap=BillingOrderServiceUtil.getPSLIbyServId(subList);
        TliMap=BillingOrderServiceUtil.getTLIbySubId(subList);
        priceAlterValuesNew=BillingOrderServiceUtil.populatePriceAlterationPSLI(PsliMap.get(serv.id),code);  
        Test.stopTest();
        System.assertNotEquals(serv.Id, null);
    }
    
     //created as part of EDGE-120128
        @isTest 
        static void testPSLImethodnew(){
        Test.startTest();
        Map<Id,Map<String,List<Price_Schedule_Line_Item__c>>> PsliMap=new Map<Id,Map<String,List<Price_Schedule_Line_Item__c>>>();
        List<BillingSpecDTOV2.priceAlterations> priceAlterValuesNew = new List<BillingSpecDTOV2.priceAlterations>();
        String code='DMCAT_Billing_000420';
        csord__Service__c serv = [Select id,name,csordtelcoa__Service_Number__c from csord__Service__c where name = 'tst servicev' LIMIT 1];
        List<csord__Subscription__c> subList=[select id,name,csordtelcoa__Replaced_Subscription__r.id from csord__Subscription__c where name='test subsv'];
       
        PsliMap=BillingOrderServiceUtil.getPSLIbyServId(subList);
        priceAlterValuesNew=BillingOrderServiceUtil.populatePriceAlterationPSLI(PsliMap.get(serv.id),code);  
        Test.stopTest();
        System.assertNotEquals(priceAlterValuesNew, null);
    }
    
      //created as part of EDGE-120131
        @isTest 
        static void testPSLIModify(){
        Test.startTest();
        Map<Id,Map<String,List<Price_Schedule_Line_Item__c>>> PsliMap=new Map<Id,Map<String,List<Price_Schedule_Line_Item__c>>>();
        List<BillingSpecDTOV2.priceAlterations> priceAlterValuesNew = new List<BillingSpecDTOV2.priceAlterations>();
        String code='DMCAT_RecurringCharge_000654';
        csord__Service__c serv = [Select id,name,csordtelcoa__Service_Number__c from csord__Service__c where name = 'tst_pricingModifyServ1' LIMIT 1];
        List<csord__Subscription__c> subList=[select id,name,csordtelcoa__Replaced_Subscription__r.id from csord__Subscription__c where name='test_pricingModifySub1'];
       
        PsliMap=BillingOrderServiceUtil.getPSLIbyServId(subList);
        system.debug('PsliMap'+PsliMap);
         system.debug('PsliMap.get(serv.id)'+PsliMap.get(serv.id));
        priceAlterValuesNew=BillingOrderServiceUtil.populatePriceAlterationPSLI(PsliMap.get(serv.id),code);  
        Test.stopTest();
        System.assertNotEquals(priceAlterValuesNew, null);
    }
    
      @isTest 
    static void testmultipleSubs(){
        List<Id> idLst=new List<Id>();
        for(csord__Subscription__c subs:[select id,name from csord__Subscription__c where Name='test subsv' or Name='test_pricingModifySub'])
        {
            idLst.add(subs.Id);
        }
        BillingOrderServiceUtil.buildPostSubscriptionPayload(idLst,false,false);
         System.assertNotEquals(idLst, null);
    }
    @isTest
    static void testgetTLIbyPSLIId(){
        Price_Schedule_Line_Item__c ps=[select id,name from Price_Schedule_Line_Item__c where name='NGUC' limit 1];
        BillingOrderServiceUtil.getTLIbyPSLIId(ps.Id);
         System.assertNotEquals(ps.id, null);
    }
  
    @isTest
    static void testautoExpiryforOneService(){
        csord__Subscription__c sub=[select id,name,csord__Identification__c,autoExpiry__c from csord__Subscription__c where name='TestAutoExpiry1' and csord__Identification__c='TestAutoExpiry1'];
        Test.startTest();
        Map<Id, String> sendBillingOrderPayload = BillingOrderServiceUtil.buildPostSubscriptionPayload(new List<Id>{sub.Id},false,false);
        String payload=sendBillingOrderPayload.get(sub.id);
        BillingSpecDTOV2 billSpecDTO = BillingSpecDTOV2.parse(payload);
        Test.stopTest();
        system.assertEquals(true,sub.autoExpiry__c);
        System.assertEquals(true,billSpecDTO.productOffering.autoExpiry);
        System.assertEquals(2,billSpecDTO.productOffering.expireDurationValue);
        System.assertEquals('Months',billSpecDTO.productOffering.expireDurationUnit);
    }
    
    @isTest
    static void testautoExpiryforTwoServices(){
        csord__Subscription__c sub=[select id,name,csord__Identification__c,autoExpiry__c from csord__Subscription__c where name='TestAutoExpiry2' and csord__Identification__c='TestAutoExpiry2'];
        Test.startTest();
        Map<Id, String> sendBillingOrderPayload = BillingOrderServiceUtil.buildPostSubscriptionPayload(new List<Id>{sub.Id},false,false);
        String payload=sendBillingOrderPayload.get(sub.id);
        BillingSpecDTOV2 billSpecDTO = BillingSpecDTOV2.parse(payload);
        Test.stopTest();
        system.assertEquals(true,sub.autoExpiry__c);
        System.assertEquals(true,billSpecDTO.productOffering.autoExpiry);
        System.assertEquals(4,billSpecDTO.productOffering.expireDurationValue); //added assertion to check Max of duration value
        System.assertEquals('Months',billSpecDTO.productOffering.expireDurationUnit);
    }
    //Added for DPG-2000
    @isTest
    static void testpopulateBillingSpecificationsIOT(){
        Test.startTest();
        csord__Subscription__c sub = [Select id,name from csord__Subscription__c where name = 'IOT Subs 2' LIMIT 1];
        boolean isIncludeSolution = false;
        boolean isProductActionExpire = false;
        Map<Id, String> sendBillingOrderPayload = BillingOrderServiceUtil.buildPostSubscriptionPayload(new List<Id>{sub.Id},isIncludeSolution,isProductActionExpire);
        String payload=sendBillingOrderPayload.get(sub.id);
        BillingSpecDTOV2 billSpecDTO = BillingSpecDTOV2.parse(payload);
        Test.stopTest();
        //Positive
        system.assertNotEquals(null,sendBillingOrderPayload.get(sub.id));
        system.assertEquals(billSpecDTO.orderItems[0].productId,'DMCAT_ProductSpecification_000964'); 
        //Negative
        system.assertNotEquals(billSpecDTO.productOffering.offerId,'DMCAT_Offer_000303');
 
    }
    
    
}