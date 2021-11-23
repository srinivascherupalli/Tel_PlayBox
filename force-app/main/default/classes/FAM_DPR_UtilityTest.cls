/*****************************************************************************************
* Name : FAM_DPR_UtilityTest
* Description : Test class of FAM_DPR_Utility.
* ModifiedBy     ModifiedDate     Edge          Description
* Shashank Jadhav   17/03/2021    EDGE-203808   Changes related to the FundConsole Tab Functionality
* Manish Berad      26/04/2021    EDGE-211115 & EDGE-211116

************************************************************************************************************************************************/
@isTest
public class FAM_DPR_UtilityTest {
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
        
        Marketable_Offer__c marketoffer=new Marketable_Offer__c();
        marketoffer.Name='Adaptive Mobility';
        marketoffer.Contract_Type__c='DSA';
        marketoffer.Product_Family__c='Adaptive Mobility';
        marketoffer.Offer_ID__c='DMCAT_Offer_001231';
        insert marketoffer;

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
        priceItem.Offer_Id__c = 'DMCAT_Offer_000647';
        priceItem.Plan__c = 'Plan__c';
        priceItem.cspmb__Recurring_Charge__c = 45.45;


        priceItem.ChargeType__c='RC';


        Insert priceItem;
        
         List<cspmb__Price_Item_Add_On_Price_Item_Association__c> piAddOnList = new List<cspmb__Price_Item_Add_On_Price_Item_Association__c> ();
         cspmb__Price_Item_Add_On_Price_Item_Association__c piaddonasso2 = new cspmb__Price_Item_Add_On_Price_Item_Association__c();
        piaddonasso2.cspmb__Price_Item__c = priceItem.Id;
        //piaddonasso2.cspmb__Add_On_Price_Item__c = piaddonlist[1].Id;
        piaddonasso2.cspmb__One_Off_Charge__c = 0.00;
        piaddonasso2.cspmb__Recurring_Charge__c=50;
        piAddOnList.add(piaddonasso2);
        if(!piAddOnList.isEmpty()){
            insert  piAddOnList;   
        }
        
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
        changeInMobOrd .csord__Identification__c = 'Change in mobile identification';
        changeInMobOrd .csord__Account__c = acc.id;
        changeInMobOrd .csord__Order_Type__c = 'Change in mobile number' ;
        changeInMobOrd .Billing_Account__c = billingAccount.id;
        insert changeInMobOrd ;
        cscfga__Configuration_Offer__c originatingOffer = new cscfga__Configuration_Offer__c(name ='Test Originating offer',offer_spec_id__c='DMCAT_Offer_000303');
        insert originatingOffer ;
        cscfga__Configuration_Offer__c originatingOfferIOT = new cscfga__Configuration_Offer__c(name ='Test Originating offer',offer_spec_id__c='DMCAT_Offer_000964');
        insert originatingOfferIOT ;
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
        mOffer1.Offer_ID__c = 'DMCAT_Offer_000647';
        mOffer1.Invoice_Definition__c = 'Invoice_Def_2';
        mOffer1.Auto_Expired_Entity__c = true;
        mOffer1.Product_Family__c='Device Mobility';
        mrktOfferList.add(mOffer1);
        Marketable_Offer__c mOffer = new Marketable_Offer__c();
        mOffer.Offer_ID__c = 'DMCAT_Offer_000646';
        mOffer.Invoice_Definition__c = 'Invoice_Def_2';
        mOffer.Auto_Expired_Entity__c = true;
        mOffer.Product_Family__c='Adaptive Mobility';
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
        

        cspmb__Price_Item_Rate_Card_Association__c rca=new cspmb__Price_Item_Rate_Card_Association__c();
        rca.cspmb__Price_Item__c=priceItem.Id;
        rca.External_Id__c='DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_8329_DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_8329_concurrencyLimit';
        rca.cspmb__Rate_Card__c=rc.Id;
        insert rca;
        

               
        DPR_Offer__c dprOffer = new DPR_Offer__c();
        dprOffer.Name = 'Test DPR';
        dprOffer.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id;
        dprOffer.Marketable_Offer__c = mOffer.Id;
        insert dprOffer;
        
        
        DPR_Offer_Line_Item__c dprOffLineItem = new DPR_Offer_Line_Item__c();
        dprOffLineItem.Offer_Type__c = priceItem.Id;
        dprOffLineItem.Offer_Type_Name__c = 'Mobile Broadband';
        dprOffLineItem.DPR_Offer__c = dprOffer.Id;
        dprOffLineItem.Marketable_Offer__c = mOffer.Id;
        dprOffLineItem.cspmb_Price_Item__c = priceItem.Id;
        dprOffLineItem.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id;
        dprOffLineItem.Quantity__c = 10;
        //Insert dprOffLineItem; 
        csconta__Frame_Agreement__c fam1=new csconta__Frame_Agreement__c();
        fam1.Opportunity__c=testOpp.id;
        fam1.csconta__Status__c = 'Draft';
        fam1.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id;
        insert fam1;
        
        //mOffer.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id;
        //update insertDelegatedPricingRequest;
        Attachment attch = new Attachment();



        attch.body = Blob.valueOf('{"custom":{"fundConsoleData":[{"productFamily":"Adaptive Mobility","fundType":"Advance","fundIncrementFrequency":"Annual In Advance","contractTerm":"24","fundContribution":"0%","advanceFundAmount":"200.16","minimumSpendPerMonth":"100","totalSpentOverContractTerm":"58900.8","isAllocated": false}]},"products":{"'+priceItem.Id+'":{"_volume":{"mv":null,"mvp":null,"muc":null,"mucp":null},"_product":{"recurring":16.18},"_allowances":{},"_addons":{"a3q2N0000000VwPQAU":{"oneOff":27.27,"recurring":null},"a3q2N0000000VxLQAU":{"oneOff":null,"recurring":0}},"_rateCards":{"'+rateCardLineList[0].cspmb__Rate_Card__c+'":{"'+rateCardLineList[0].id+'":'+rateCardLineList[0].cspmb__rate_value__c+',"'+rateCardLineList[1].id+'":'+rateCardLineList[1].cspmb__rate_value__c+'}}}}}');




        attch.name = 'FrameAgreementAttachment';
        attch.ParentId = fam.Id;
        insert attch;
    }
    




    static testMethod void createDPROffersTest2() {
        csconta__Frame_Agreement__c fam = [select id,Delegated_Pricing_Request__c from csconta__Frame_Agreement__c limit 1];
        Map<Id, List<cspmb__Rate_Card_Line__c> > response; 
        Map<Id, List<cspmb__Rate_Card_Line__c> > rateCardMap = new Map<Id, List<cspmb__Rate_Card_Line__c> >();
        for(cspmb__Rate_Card__c rc : [select id, (select id,cspmb__rate_value__c from cspmb__Rate_Card_Lines__r) from cspmb__Rate_Card__c]){
            rateCardMap.put(rc.id,rc.cspmb__Rate_Card_Lines__r);   
        }
        Delegated_Pricing_Request__c dpr=[SELECT Id, Deal_Status__c,Tech_Reward_Type__c,Opportunity__c,Opportunity__r.Contract_Term__c,
                   (SELECT Id FROM Delegated_Pricing_Request_Offers__r),
                   (SELECT Id FROM DPR_Offer_Line_Items__r),
                   (SELECT Id FROM DPR_GBB_Report_Detailes__r),
                   (SELECT Id FROM Delegated_Outcomes__r)
                   FROM Delegated_Pricing_Request__c
                   WHERE Id = :fam.Delegated_Pricing_Request__c];
        List<DPR_Offer__c> listOfDPROffers=[SELECT Id, Name, Marketable_Offer__c, Delegated_Pricing_Request__c FROM DPR_Offer__c WHERE Delegated_Pricing_Request__c = : dpr.Id];
        Map<Id,DPR_Offer__c> existingMoIdToDprOffer = new Map<Id,DPR_Offer__c>();
        existingMoIdToDprOffer.put(listOfDPROffers[0].Marketable_Offer__c,listOfDPROffers[0]);
        List<Marketable_Offer__c> listOfMo = [SELECT Id, Offer_ID__c, Name, Product_Family__c,Fund_Allocation_Percentage__c,Portfolio_Margin_Percentage__c
                                                      FROM Marketable_Offer__c
                                                      WHERE Offer_ID__c !=null];
        Map<String,Marketable_Offer__c> offerIdToMO   = new Map<String,Marketable_Offer__c>();
        for(Marketable_Offer__c mo:listOfMo){
            offerIdToMO.put(mo.id,mo);
        }
        Map<String,List<Marketable_Offer__c>> productFamilyToMO=new Map<String,List<Marketable_Offer__c>>();
        productFamilyToMO.put(listOfMo[0].Product_Family__c, new List<Marketable_Offer__c> {listOfMo[0]});
        productFamilyToMO.put(listOfMo[1].Product_Family__c, new List<Marketable_Offer__c> {listOfMo[1]});
        
        test.startTest();
        //createDPROffers(Delegated_Pricing_Request__c dpr,Map<Id,DPR_Offer__c> existingMoIdToDprOffer,Map<String,Marketable_Offer__c> offerIdToMO,Map<String,List<Marketable_Offer__c>> productFamilyToMO)
        FAM_DPR_Utility dprUtility=new FAM_DPR_Utility();
        List<DPR_Offer__c> dprOffers=FAM_DPR_Utility.createDPROffers(dpr,existingMoIdToDprOffer,offerIdToMO,productFamilyToMO);
        //system.assertEquals(true, listOfDPRRecords.size()>0);
        system.assertEquals(true, dprOffers.size()>0);
        FAM_Utility famUtility=new FAM_Utility(fam.id);
        FAM_DPR_Utility.getDPRRecords(fam.id);
        Map<String, FAM_Utility.FundData> fundDataRecords=famUtility.getFundConsoleCustomMap();
        System.debug('fundDataRecords='+fundDataRecords);
        FAM_DPR_Utility.updateDPROffersForFundData(dpr.id,fundDataRecords);
        Map<Id, FAM_Utility.VolumeAndPricing> productToVolumeAndPricingMap=famUtility.getProductToVolumeAndPricingMap();
        Map<Id, DPR_Offer_Line_Item__c> commercialProductIdToExistingParentOliMap=new Map<Id, DPR_Offer_Line_Item__c>();
        Map<String, List<cspmb__Price_Item__c> > offerNameToCP = new Map<String, List<cspmb__Price_Item__c> >();
        for(cspmb__Price_Item__c cp:[SELECT Id, Name, Offer_Id__c, cspmb__Recurring_Charge__c,
                                             cspmb__One_Off_Charge__c, Plan__c,Type__c,cspmb__Is_Recurring_Discount_Allowed__c,
                                             cspmb__Is_One_Off_Discount_Allowed__c,ProdSpecId__c,Model__c,ChargeType__c,IsContributing__c
                                             FROM cspmb__Price_Item__c
                                             WHERE Id IN :productToVolumeAndPricingMap.keySet()]){
            offerNameToCP.put(cp.Offer_Id__c,new List<cspmb__Price_Item__c>{cp});
        }
        //List<DPR_Offer_Line_Item__c> createDPROfferLineItems(List<DPR_Offer__c> dprOffers,Map<Id, DPR_Offer_Line_Item__c> commercialProductIdToExistingParentOliMap,Map<Id, FAM_Utility.VolumeAndPricing> productToVolumeAndPricingMap,Map<String, List<cspmb__Price_Item__c>> offerNameToCP,Map<String,Marketable_Offer__c> offerIdToMO, Boolean isVariation,Map<String,List<Marketable_Offer__c>> productFamilyToMO)
        List<DPR_Offer_Line_Item__c> dprOLIForUpsert=FAM_DPR_Utility.createDPROfferLineItems(dprOffers,commercialProductIdToExistingParentOliMap,productToVolumeAndPricingMap,offerNameToCP,null, false,productFamilyToMO,fundDataRecords);
        List<DPR_Offer_Line_Item__c> dprOLIForUpsertNew=new List<DPR_Offer_Line_Item__c>();
        for(DPR_Offer_Line_Item__c dprOLI:dprOLIForUpsert){
            System.debug('Test=dprOLI='+dprOLI);
            dprOLI.List_Price__c=20;
            dprOLI.Overridden_Unit_price__c = 18;
            dprOLIForUpsertNew.add(dprOLI);
        }
        
        List<cspmb__Price_Item_Add_On_Price_Item_Association__c> lstOfPriceItenAddOnAss=[SELECT Id, AddOnName__c,cspmb__Price_Item__c, cspmb__Add_On_Price_Item__c,cspmb__Add_On_Price_Item__r.cspmb__Is_Recurring_Discount_Allowed__c,
                                                                                         cspmb__Recurring_Charge__c,cspmb__One_Off_Charge__c,cspmb__Add_On_Price_Item__r.cspmb__Is_One_Off_Discount_Allowed__c
                                                                                         FROM cspmb__Price_Item_Add_On_Price_Item_Association__c ];
        Map<String, List<cspmb__Price_Item_Add_On_Price_Item_Association__c> > mapOfPriceItemVsPIA = new Map<String, List<cspmb__Price_Item_Add_On_Price_Item_Association__c> >();
        if(!lstOfPriceItenAddOnAss.isEmpty()){
            for(cspmb__Price_Item_Add_On_Price_Item_Association__c pia:lstOfPriceItenAddOnAss){
                if (!mapOfPriceItemVsPIA.containsKey(pia.cspmb__Price_Item__c)) {
                    mapOfPriceItemVsPIA.put(pia.cspmb__Price_Item__c, new List<cspmb__Price_Item_Add_On_Price_Item_Association__c>());
                }
                mapOfPriceItemVsPIA.get(pia.cspmb__Price_Item__c).add(pia);
                
            }
        }

        //EDGE-211115 & EDGE-211116 ...start
        Map<String,cspmb__Price_Item_Rate_Card_Association__c> mapOfCPvsRCAssociation=new Map<String,cspmb__Price_Item_Rate_Card_Association__c>();
        List<cspmb__Price_Item_Rate_Card_Association__c> lstRateCardAssociation = [SELECT Id,Name,cspmb__Price_Item__c,
                                                                                   cspmb__default__c,External_Id__c,cspmb__group__c,cspmb__max__c,cspmb__min__c,cspmb__Rate_Card__c
                                                                                   FROM cspmb__Price_Item_Rate_Card_Association__c ];
                                                                                  
        if(!lstRateCardAssociation.isEmpty()){
            for(cspmb__Price_Item_Rate_Card_Association__c rca:lstRateCardAssociation){
                if(rca.cspmb__Price_Item__c!=null){
                    mapOfCPvsRCAssociation.put(rca.cspmb__Price_Item__c,rca);
                   
                }
            }
        }
        
        Map<String,cspmb__Rate_Card_Line__c> mapOfRCL=new Map<String,cspmb__Rate_Card_Line__c>();
            List<cspmb__Rate_Card_Line__c> lstOfRCL=[Select Id,cspmb__rate_value__c,cspmb__Rate_Card__c 
                                                     From cspmb__Rate_Card_Line__c]; 
                                                     
            if(!lstOfRCL.isEmpty()){
                for(cspmb__Rate_Card_Line__c rcl:lstOfRCL){
                    mapOfRCL.put(rcl.Id,rcl);
                }
            }
           //EDGE-211115 & EDGE-211116 ...end
           

        Map<Id,DPR_Offer_Line_Item__c> existingDPROLI = new Map<Id,DPR_Offer_Line_Item__c>(
                [SELECT Id, Name, Delegated_Pricing_Request__c, DPR_Offer__c, cspmb_Price_Item__c, Parent_DPR_Offer_Line_Item_Id__c,
                 List_Price__c, Overridden_Unit_price__c, Quantity__c, Recontracting_Quantity__c, Total_Recurring_Charge__c,
                 Marketable_Offer__c, Offer_Type__c,Offer_Type_Name__c, DPR_Offer_Line_Item_Type__c, DPR_Offer_Line_Item_Unit_Type__c, DPR_Offer_Line_Item_Value__c,
                 Fund_Allocation__c,Portfolio_Margin__c,Marketable_Offer__r.Fund_Allocation_Percentage__c,Marketable_Offer__r.Portfolio_Margin_Percentage__c,
                 (SELECT Id FROM DPR_Offer_Line_Items__r) //just subquery so we can easily find child record, expecting only 1 record
                 FROM DPR_Offer_Line_Item__c
                 WHERE Delegated_Pricing_Request__c = : dpr.Id]);
        Set<String> setOfAddOnAssIds=new Set<String>();
        Map<String,FAM_Utility.AddOnPricing> mapOfAddOn=New Map<String,FAM_Utility.AddOnPricing>();

        Map<Id, Map<Id, Decimal>> mapOfRCvsRCL=new Map<Id, Map<Id, Decimal>>();

        for(Id vp:productToVolumeAndPricingMap.keyset()){
            FAM_Utility.VolumeAndPricing vPobj=productToVolumeAndPricingMap.get(vp);
            Map<String,FAM_Utility.AddOnPricing> mapOfAddOnPrice=vPobj.addOnAssociationToPricingMap;
            if(mapOfAddOnPrice!=null){
            for(String addOnKey:mapOfAddOnPrice.keySet()){                
                  FAM_Utility.AddOnPricing addOnWrapp=mapOfAddOnPrice.get(addOnKey);
                  mapOfAddOn.put(addOnKey,addOnWrapp);   
                }
            }

            //EDGE-211115 & EDGE-211116 ....Start
            Map<Id, Map<Id, Decimal>> rCToRCLinesMap=vPobj.rateCardToRateCardLinesMap;
            system.debug('rCToRCLinesMap-->'+rCToRCLinesMap);
            if(rCToRCLinesMap!=null){
                for(String rcKey:rCToRCLinesMap.keySet()){
                    Map<Id, Decimal> mapOfRCL1=rCToRCLinesMap.get(rcKey);
                    mapOfRCvsRCL.put(rcKey,mapOfRCL1);
                }
            }
            //EDGE-211115 & EDGE-211116 ....end
            setOfAddOnAssIds.addAll(mapOfAddOn.keySet());
        }
        
        Map<Id,DPR_Rate_Card__c> mapOfExistingRateCard = new Map<Id,DPR_Rate_Card__c>();
        Map<Id,DPR_Rate_Card__c> mapOfExistingRateCardLine = new Map<Id,DPR_Rate_Card__c>();
        
        //child ones that need to inserted have to be seperate DML i.e. after the 1st upsert as we need to have parent Ids
        Map<Id,DPR_Offer_Line_Item__c> neededOLIs = FAM_DPR_Utility.updateChildDPROfferLineItemsForAddonsAndDiscounts(dprOLIForUpsert,commercialProductIdToExistingParentOliMap,existingDPROLI,mapOfPriceItemVsPIA,mapOfAddOn,false);
		system.assertEquals(true, neededOLIs .size()>0);
        
        //EDGE-211115 & EDGE-211116 start
        FAM_DPR_Utility.upsertRateCardAndRateCardLineItems(dprOLIForUpsert,mapOfRCvsRCL,mapOfCPvsRCAssociation,mapOfRCL,mapOfExistingRateCard,mapOfExistingRateCardLine);
       	List<DPR_Rate_Card__c> dprRateCard=[Select Id,Delegated_Pricing_Request__c,DPR_Rate_Card_Type__c,Parent_DPR_OLI_id__c,
                                                Parent_DPR_Rate_Card_ID__c,Rate_Card__c,Rate_Card_Line__c
                                                From DPR_Rate_Card__c 
                                                Where Delegated_Pricing_Request__c=:dpr.Id];
        system.assertEquals(true, dprRateCard.size()>0);
        //EDGE-211115 & EDGE-211116 end
        test.stopTest();
    }

    static testMethod void createDPROffersTest() {
        csconta__Frame_Agreement__c fam = [select id,Delegated_Pricing_Request__c from csconta__Frame_Agreement__c limit 1];
        Map<Id, List<cspmb__Rate_Card_Line__c> > response; 
        Map<Id, List<cspmb__Rate_Card_Line__c> > rateCardMap = new Map<Id, List<cspmb__Rate_Card_Line__c> >();
        for(cspmb__Rate_Card__c rc : [select id, (select id,cspmb__rate_value__c from cspmb__Rate_Card_Lines__r) from cspmb__Rate_Card__c]){
            rateCardMap.put(rc.id,rc.cspmb__Rate_Card_Lines__r);   
        }


        Delegated_Pricing_Request__c dpr=[SELECT Id, Deal_Status__c,Tech_Reward_Type__c,Opportunity__c,Opportunity__r.Contract_Term__c,


                   (SELECT Id FROM Delegated_Pricing_Request_Offers__r),
                   (SELECT Id FROM DPR_Offer_Line_Items__r),
                   (SELECT Id FROM DPR_GBB_Report_Detailes__r),
                   (SELECT Id FROM Delegated_Outcomes__r)
                   FROM Delegated_Pricing_Request__c
                   WHERE Id = :fam.Delegated_Pricing_Request__c];
        List<DPR_Offer__c> listOfDPROffers=[SELECT Id, Name, Marketable_Offer__c, Delegated_Pricing_Request__c FROM DPR_Offer__c WHERE Delegated_Pricing_Request__c = : dpr.Id];
        Map<Id,DPR_Offer__c> existingMoIdToDprOffer = new Map<Id,DPR_Offer__c>();
        existingMoIdToDprOffer.put(listOfDPROffers[0].Marketable_Offer__c,listOfDPROffers[0]);
        List<Marketable_Offer__c> listOfMo = [SELECT Id, Offer_ID__c, Name, Product_Family__c,Fund_Allocation_Percentage__c,Portfolio_Margin_Percentage__c
                                                      FROM Marketable_Offer__c
                                                      WHERE Offer_ID__c !=null];
        Map<String,Marketable_Offer__c> offerIdToMO   = new Map<String,Marketable_Offer__c>();
        for(Marketable_Offer__c mo:listOfMo){
            offerIdToMO.put(mo.id,mo);
        }
        Map<String,List<Marketable_Offer__c>> productFamilyToMO=new Map<String,List<Marketable_Offer__c>>();
        productFamilyToMO.put(listOfMo[0].Product_Family__c, new List<Marketable_Offer__c> {listOfMo[0]});
        productFamilyToMO.put(listOfMo[1].Product_Family__c, new List<Marketable_Offer__c> {listOfMo[1]});
        
        test.startTest();
        //createDPROffers(Delegated_Pricing_Request__c dpr,Map<Id,DPR_Offer__c> existingMoIdToDprOffer,Map<String,Marketable_Offer__c> offerIdToMO,Map<String,List<Marketable_Offer__c>> productFamilyToMO)
        FAM_DPR_Utility dprUtility=new FAM_DPR_Utility();
        List<DPR_Offer__c> dprOffers=FAM_DPR_Utility.createDPROffers(dpr,existingMoIdToDprOffer,offerIdToMO,productFamilyToMO);
        //system.assertEquals(true, listOfDPRRecords.size()>0);
        system.assertEquals(true, dprOffers.size()>0);
        FAM_Utility famUtility=new FAM_Utility(fam.id);



        FAM_DPR_Utility.getDPRRecords(fam.id);
        Map<String, FAM_Utility.FundData> fundDataRecords=famUtility.getFundConsoleCustomMap();
        System.debug('fundDataRecords='+fundDataRecords);



        FAM_DPR_Utility.updateDPROffersForFundData(dpr.id,fundDataRecords);
        Map<Id, FAM_Utility.VolumeAndPricing> productToVolumeAndPricingMap=famUtility.getProductToVolumeAndPricingMap();
        Map<Id, DPR_Offer_Line_Item__c> commercialProductIdToExistingParentOliMap=new Map<Id, DPR_Offer_Line_Item__c>();
        Map<String, List<cspmb__Price_Item__c> > offerNameToCP = new Map<String, List<cspmb__Price_Item__c> >();
        for(cspmb__Price_Item__c cp:[SELECT Id, Name, Offer_Id__c, cspmb__Recurring_Charge__c,
                                             cspmb__One_Off_Charge__c, Plan__c,Type__c,cspmb__Is_Recurring_Discount_Allowed__c,
                                             cspmb__Is_One_Off_Discount_Allowed__c,ProdSpecId__c,Model__c,ChargeType__c,IsContributing__c
                                             FROM cspmb__Price_Item__c
                                             WHERE Id IN :productToVolumeAndPricingMap.keySet()]){


            cp.ChargeType__c = '';


            offerNameToCP.put(cp.Offer_Id__c,new List<cspmb__Price_Item__c>{cp});
        }
        //List<DPR_Offer_Line_Item__c> createDPROfferLineItems(List<DPR_Offer__c> dprOffers,Map<Id, DPR_Offer_Line_Item__c> commercialProductIdToExistingParentOliMap,Map<Id, FAM_Utility.VolumeAndPricing> productToVolumeAndPricingMap,Map<String, List<cspmb__Price_Item__c>> offerNameToCP,Map<String,Marketable_Offer__c> offerIdToMO, Boolean isVariation,Map<String,List<Marketable_Offer__c>> productFamilyToMO)
        List<DPR_Offer_Line_Item__c> dprOLIForUpsert=FAM_DPR_Utility.createDPROfferLineItems(dprOffers,commercialProductIdToExistingParentOliMap,productToVolumeAndPricingMap,offerNameToCP,null, false,productFamilyToMO,fundDataRecords);
        List<DPR_Offer_Line_Item__c> dprOLIForUpsertNew=new List<DPR_Offer_Line_Item__c>();
        for(DPR_Offer_Line_Item__c dprOLI:dprOLIForUpsert){
            System.debug('Test=dprOLI='+dprOLI);
            dprOLI.List_Price__c=20;
            dprOLI.Overridden_Unit_price__c = 18;
            dprOLIForUpsertNew.add(dprOLI);
        }
        
        List<cspmb__Price_Item_Add_On_Price_Item_Association__c> lstOfPriceItenAddOnAss=[SELECT Id, AddOnName__c,cspmb__Price_Item__c, cspmb__Add_On_Price_Item__c,cspmb__Add_On_Price_Item__r.cspmb__Is_Recurring_Discount_Allowed__c,
                                                                                         cspmb__Recurring_Charge__c,cspmb__One_Off_Charge__c,cspmb__Add_On_Price_Item__r.cspmb__Is_One_Off_Discount_Allowed__c
                                                                                         FROM cspmb__Price_Item_Add_On_Price_Item_Association__c ];
        Map<String, List<cspmb__Price_Item_Add_On_Price_Item_Association__c> > mapOfPriceItemVsPIA = new Map<String, List<cspmb__Price_Item_Add_On_Price_Item_Association__c> >();
        if(!lstOfPriceItenAddOnAss.isEmpty()){
            for(cspmb__Price_Item_Add_On_Price_Item_Association__c pia:lstOfPriceItenAddOnAss){
                if (!mapOfPriceItemVsPIA.containsKey(pia.cspmb__Price_Item__c)) {
                    mapOfPriceItemVsPIA.put(pia.cspmb__Price_Item__c, new List<cspmb__Price_Item_Add_On_Price_Item_Association__c>());
                }
                mapOfPriceItemVsPIA.get(pia.cspmb__Price_Item__c).add(pia);
                
            }
        }
        Map<Id,DPR_Offer_Line_Item__c> existingDPROLI = new Map<Id,DPR_Offer_Line_Item__c>(
                [SELECT Id, Name, Delegated_Pricing_Request__c, DPR_Offer__c, cspmb_Price_Item__c, Parent_DPR_Offer_Line_Item_Id__c,
                 List_Price__c, Overridden_Unit_price__c, Quantity__c, Recontracting_Quantity__c, Total_Recurring_Charge__c,
                 Marketable_Offer__c, Offer_Type__c,Offer_Type_Name__c, DPR_Offer_Line_Item_Type__c, DPR_Offer_Line_Item_Unit_Type__c, DPR_Offer_Line_Item_Value__c,
                 Fund_Allocation__c,Portfolio_Margin__c,Marketable_Offer__r.Fund_Allocation_Percentage__c,Marketable_Offer__r.Portfolio_Margin_Percentage__c,
                 (SELECT Id FROM DPR_Offer_Line_Items__r) //just subquery so we can easily find child record, expecting only 1 record
                 FROM DPR_Offer_Line_Item__c
                 WHERE Delegated_Pricing_Request__c = : dpr.Id]);
        Set<String> setOfAddOnAssIds=new Set<String>();
        Map<String,FAM_Utility.AddOnPricing> mapOfAddOn=New Map<String,FAM_Utility.AddOnPricing>();
        for(Id vp:productToVolumeAndPricingMap.keyset()){
            FAM_Utility.VolumeAndPricing vPobj=productToVolumeAndPricingMap.get(vp);
            Map<String,FAM_Utility.AddOnPricing> mapOfAddOnPrice=vPobj.addOnAssociationToPricingMap;
            if(mapOfAddOnPrice!=null){
            for(String addOnKey:mapOfAddOnPrice.keySet()){                
                  FAM_Utility.AddOnPricing addOnWrapp=mapOfAddOnPrice.get(addOnKey);
                  mapOfAddOn.put(addOnKey,addOnWrapp);   
                }
            }
            setOfAddOnAssIds.addAll(mapOfAddOn.keySet());
        }
        //child ones that need to inserted have to be seperate DML i.e. after the 1st upsert as we need to have parent Ids
        Map<Id,DPR_Offer_Line_Item__c> neededOLIs = FAM_DPR_Utility.updateChildDPROfferLineItemsForAddonsAndDiscounts(dprOLIForUpsert,commercialProductIdToExistingParentOliMap,existingDPROLI,mapOfPriceItemVsPIA,mapOfAddOn,false);
        system.assertEquals(true, neededOLIs .size()>0);
        test.stopTest();
    }

}