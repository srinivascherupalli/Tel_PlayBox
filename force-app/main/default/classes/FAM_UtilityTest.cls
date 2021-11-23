/*************************************************************************************************
Name : FAM_UtilityTest
Description : Test class of FAM_Utility.
Sr.No.    Developer Name      Date          Story Description
**************************************************************************************************/
@isTest
public class FAM_UtilityTest {
    @testsetup static void testdata() {
        Account acc=new Account();
        acc.Name='testacc';
        acc.CIDN__c='1234567891';
        acc.ABN__c='1235';
        acc.Customer_Status__c = 'ACTIVE';
        insert acc;
        Contact contact = AccountTestFactory.buildContact(acc, 'Smiths');
        insert contact;
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
        Delegated_Pricing_Request__c insertDelegatedPricingRequest = new Delegated_Pricing_Request__c();
        insertDelegatedPricingRequest.Description__c = 'Test';
        insertDelegatedPricingRequest.Opportunity__c = testOpp.id;
        insertDelegatedPricingRequest.isPrimary__c = False;
        insertDelegatedPricingRequest.Mark_as_Variation__c = False;
        insertDelegatedPricingRequest.Parent_DPR__c = 'Test';
        insert insertDelegatedPricingRequest;
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert u; 
        csconta__Frame_Agreement__c fam=new csconta__Frame_Agreement__c();
        fam.Opportunity__c=testOpp.id;
        fam.Deal_Approver__c=u.Id;
        fam.Delegated_Pricing_Request__c=insertDelegatedPricingRequest.id;
        insert fam;
        cspmb__Price_Item__c priceItem = new cspmb__Price_Item__c();
        priceItem.name = 'Enterprise Mobility';
        priceItem.Commercial_Product_Code__c = 'DMCAT_Offer_001233_DMCAT_ProductSpecification_001196_DMCAT_RecurringCharge_001232_7790';
        priceItem.cspmb__Billing_Frequency__c = 'Monthly';
        priceItem.ProdSpecId__c = 'DMCAT_ProductSpecification_001196';
        priceItem.BillingSpecId__c = 'BSRC001_CB';
        priceItem.Offer_Id__c = 'DMCAT_Offer_001233';
        priceItem.Plan__c = 'Plan__c';
        priceItem.cspmb__Recurring_Charge__c = 45.45;
        Insert priceItem;
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
        csord__Order__c changeInMobOrd = new csord__Order__c();
        changeInMobOrd.csord__Identification__c = 'Change in mobile identification';
        changeInMobOrd.csord__Account__c = acc.id;
        changeInMobOrd.csord__Order_Type__c = 'Change in mobile number' ;
        changeInMobOrd.Billing_Account__c = billingAccount.id;
        insert changeInMobOrd;
        cscfga__Configuration_Offer__c originatingOffer = new cscfga__Configuration_Offer__c(name ='Test Originating offer',offer_spec_id__c='DMCAT_Offer_000303');
        insert originatingOffer;
        cscfga__Configuration_Offer__c originatingOfferIOT = new cscfga__Configuration_Offer__c(name ='Test Originating offer',offer_spec_id__c='DMCAT_Offer_000964');
        insert originatingOfferIOT;
        cscfga__Product_Definition__c productDefinition = new cscfga__Product_Definition__c();
        productDefinition.Name = 'Test Product Definition';
        productDefinition.cscfga__Description__c = 'Test Product Definition Description';
       // productDefinition.RecordTypeId = '012280000011E6gAAE';
        productDefinition.RecordTypeId = Schema.SObjectType.cscfga__Product_Definition__c.getRecordTypeInfosByName().get('Product Definition').getRecordTypeId();
        productDefinition.product_Specification__c = 'DMCAT_ProductOffering_000304';
        insert productDefinition;
        cscfga__Product_Definition__c productDefinitionIOT = new cscfga__Product_Definition__c();
        productDefinitionIOT.Name = 'IoT Solution';
        productDefinitionIOT.cscfga__Description__c = 'Test Product Definition Description';
        productDefinitionIOT.product_Specification__c = 'DMCAT_Offer_000964';
        insert productDefinitionIOT; 
        List<cscfga__Product_Configuration__c> pcList=new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c productConfig = new cscfga__Product_Configuration__c();
        productConfig.Offer_Reference__c = OriginatingOffer.id;
        productConfig.cscfga__Product_Definition__c = productDefinition.Id;
        productConfig.ConfigurationType1__c='SolutionComponent';
        productConfig.Remaining_Term__c  = 24;
        pcList.add(productConfig);
        cscfga__Product_Configuration__c productConfigCancel = new cscfga__Product_Configuration__c();
        productConfigCancel.Offer_Reference__c = OriginatingOffer.id;
        productConfigCancel.cscfga__Product_Definition__c = productDefinition.Id;
        productConfigCancel.ConfigurationType1__c='SolutionComponent';
        productConfigCancel.Type__c = 'Cancel';
        productConfigCancel.Remaining_Term__c = 24;
        pcList.add(productConfigCancel);
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
        Marketable_Offer__c mOffer = new Marketable_Offer__c();
        mOffer.Offer_ID__c = 'DMCAT_Offer_000646';
        mOffer.Invoice_Definition__c = 'Invoice_Def_2';
        mOffer.Auto_Expired_Entity__c = true;
        mrktOfferList.add(mOffer);
        Marketable_Offer__c mOfferIOT = new Marketable_Offer__c();
        mOfferIOT.Offer_ID__c = 'DMCAT_Offer_000964';
        mOfferIOT.Invoice_Definition__c = 'Invoice_Def_2';
        mOfferIOT.Auto_Expired_Entity__c = true;
        mrktOfferList.add(mOfferIOT);
        insert mrktOfferList;
        csord__Subscription__c subsL=new csord__Subscription__c();
        subsL.name  = 'test subsL';
        subsL.csord__Identification__c = 'test identityL';
        subsL.Site__c = site.Id;
        subsL.csord__Status__c='Subscription Created';
        subsL.csordtelcoa__Subscription_Number__c = 'SN-000003199';
        subsL.csord__Order__c = secOrd.id;
        subsL.csordtelcoa__Product_Configuration__c = productConfig.id;
        subsL.Billing_Account__c = billingAccount.id;
        subsL.Offer__c = OriginatingOffer.Id;

        subsL.MarketableOffer__c = mOffer.Id;

        insert subsL;
        cspmb__Rate_Card__c rc = new cspmb__Rate_Card__c(
            Name = 'Adacptive Care Rate Card',
            Offer_Id__c ='DMCAT_Offer_001251',
            cspmb__Rate_Card_Code__c = '7999', 
            cspmb__Effective_End_Date__c = Date.today()+1,
            cspmb__Effective_Start_Date__c = Date.today()-1,
            cspmb__Is_Active__c = true);
        insert rc;
        List<cspmb__Rate_Card_Line__c> rateCardLineList = new List<cspmb__Rate_Card_Line__c>();
        cspmb__Rate_Card_Line__c rcl1 =PricingTestDataFactory.generateRateCardLine(1,499,rc.id,'1');
        rcl1.cspmb__rate_value__c = 1.5;
        rateCardLineList.add(rcl1);
        cspmb__Rate_Card_Line__c rcl2 =PricingTestDataFactory.generateRateCardLine(999,500,rc.id,'1');
        rcl2.cspmb__rate_value__c = 2.5;
        rateCardLineList.add(rcl2);
        insert rateCardLineList;
        Attachment attch = new Attachment();
        attch.body = Blob.valueOf('{"custom":{"fundConsoleData":[{"productFamily":"Adaptive Mobility","fundType":"Advance","fundIncrementFrequency":"Annual In Advance","contractTerm":"24","fundContribution":"0%","advanceFundAmount":"200.16","minimumSpendPerMonth":"undefined","totalSpentOverContractTerm":"58900.8"}]},"products":{"'+priceItem.Id+'":{"_volume":{"mv":null,"mvp":null,"muc":null,"mucp":null},"_product":{"recurring":16.18},"_allowances":{},"_addons":{"a3q2N0000000VwPQAU":{"oneOff":27.27,"recurring":null},"a3q2N0000000VxLQAU":{"oneOff":null,"recurring":0}},"_rateCards":{"'+rateCardLineList[0].cspmb__Rate_Card__c+'":{"'+rateCardLineList[0].id+'":'+rateCardLineList[0].cspmb__rate_value__c+',"'+rateCardLineList[1].id+'":'+rateCardLineList[1].cspmb__rate_value__c+'}}}}}');
        attch.name = 'FrameAgreementAttachment';
        attch.ParentId = fam.Id;
        insert attch;
    }
    static testMethod void applyRateCardNegotiatedPricesTest() {
        csord__Subscription__c sub = [select id from csord__Subscription__c limit 1];
        List<cspmb__Rate_Card_Line__c> response;
        List<cspmb__Rate_Card_Line__c> rateCardLines = [select id,cspmb__rate_value__c from cspmb__Rate_Card_Line__c];
        test.startTest();
        FAM_Utility fm = new FAM_Utility(sub.id);
        response = fm.applyRateCardNegotiatedPrices(rateCardLines);
        system.assertEquals(true, response.size()>0);
        test.stopTest();
    }
    static testMethod void applyRateCardNegotiatedPricesNegativeTest() {
        delete[select id from attachment]; 
        List<cspmb__Rate_Card_Line__c> response;
        csconta__Frame_Agreement__c fam = [select id from csconta__Frame_Agreement__c limit 1];
        List<cspmb__Rate_Card_Line__c> rateCardLines = [select id,cspmb__rate_value__c from cspmb__Rate_Card_Line__c];
        test.startTest();
        FAM_Utility fm = new FAM_Utility(fam.id);
        response = fm.applyRateCardNegotiatedPrices(rateCardLines);
        system.assertEquals(rateCardLines, response);
        test.stopTest();
    }
    static testMethod void applyRateCardNegotiatedPricesMapTest() {
        csconta__Frame_Agreement__c fam = [select id from csconta__Frame_Agreement__c limit 1];
        Map<Id, List<cspmb__Rate_Card_Line__c> > response; 
        Map<Id, List<cspmb__Rate_Card_Line__c> > rateCardMap = new Map<Id, List<cspmb__Rate_Card_Line__c> >();
        for(cspmb__Rate_Card__c rc : [select id, (select id,cspmb__rate_value__c from cspmb__Rate_Card_Lines__r) from cspmb__Rate_Card__c]){
            rateCardMap.put(rc.id,rc.cspmb__Rate_Card_Lines__r);   
        }
        test.startTest();
        FAM_Utility fm = new FAM_Utility(fam.id);
        response = fm.applyRateCardNegotiatedPrices(rateCardMap);
        system.assertEquals(true, response.keyset().size()>0);
        test.stopTest();
    }
    static testMethod void applyRateCardNegotiatedPricesMapNegativeTest() {
        delete[select id from attachment]; 
        Map<Id, List<cspmb__Rate_Card_Line__c> > response;
        csconta__Frame_Agreement__c fam = [select id from csconta__Frame_Agreement__c limit 1];
        Map<Id, List<cspmb__Rate_Card_Line__c> > rateCardMap = new Map<Id, List<cspmb__Rate_Card_Line__c> >();
        for(cspmb__Rate_Card__c rc : [select id, (select id,cspmb__rate_value__c from cspmb__Rate_Card_Lines__r) from cspmb__Rate_Card__c]){
            rateCardMap.put(rc.id,rc.cspmb__Rate_Card_Lines__r);   
        }
        test.startTest();
        FAM_Utility fm = new FAM_Utility(fam.id);
        response = fm.applyRateCardNegotiatedPrices(rateCardMap);
        fm.getProductToVolumeAndPricingMap();
        system.assertEquals(rateCardMap, response);
        test.stopTest();
    }

    static testMethod void createAndInsertListPriceOverridesPositiveTest() {
        //create pricing rule where Name = Id and Code starts with FAM
        cspmb__Pricing_Rule__c pr = new cspmb__Pricing_Rule__c(
            Name = 'Test',
            cspmb__pricing_rule_code__c = 'FAM'
        );
        insert pr;
        pr.Name = pr.Id;
        update pr;
        cspmb__Price_Item_Pricing_Rule_Association__c cppra = new cspmb__Price_Item_Pricing_Rule_Association__c(
            cspmb__association_type__c = 'Pricing change',
      cspmb__target_price__c = 'Sales',
      cspmb__recurring_adjustment_type__c = 'Price Override',
            cspmb__one_off_adjustment_type__c = 'Price Override',
            cspmb__pricing_rule__c = pr.Id
        );
        Test.startTest();
        //FAM_Utility.createAndInsertListPriceOverrides will be triggered on after insert
        insert cppra;
        Test.stopTest();
        List<cspmb__Price_Item_Pricing_Rule_Association__c> cppraList = [SELECT Id FROM cspmb__Price_Item_Pricing_Rule_Association__c WHERE cspmb__pricing_rule__c = :pr.Id];
        System.assertEquals(2, cppraList.size()); //ensure that we DID create additional record
    }
    static testMethod void createAndInsertListPriceOverridesNegativeTest() {
        //create pricing rule where Name = Id and Code starts with FAM
        cspmb__Pricing_Rule__c pr = new cspmb__Pricing_Rule__c(
            Name = 'Test',
            cspmb__pricing_rule_code__c = 'FAM'
        );
        insert pr;
        //not updating the Name to SFDC Id means this Pricing rule will not be considered as FA generated
        cspmb__Price_Item_Pricing_Rule_Association__c cppra = new cspmb__Price_Item_Pricing_Rule_Association__c(
            cspmb__association_type__c = 'Pricing change',
      cspmb__target_price__c = 'Sales',
      cspmb__recurring_adjustment_type__c = 'Price Override',
            cspmb__one_off_adjustment_type__c = 'Price Override',
            cspmb__pricing_rule__c = pr.Id
        );
        Test.startTest();
        //FAM_Utility.createAndInsertListPriceOverrides will be triggered on after insert
        insert cppra;
        Test.stopTest();
        List<cspmb__Price_Item_Pricing_Rule_Association__c> cppraList = [SELECT Id FROM cspmb__Price_Item_Pricing_Rule_Association__c WHERE cspmb__pricing_rule__c = :pr.Id];
        System.assertEquals(1, cppraList.size()); //ensure that we did NOT create additional record
    }

}