@isTest
private class GetDealScoreControllerTest {
    
    /**********************************************************
  * Story: EDGE-185052
  * Developer: Abhishek
  * Team : Osaka
  * Description: Test Setup method.
  * *********************************************************/
    @testSetup
    public static void dataSetup(){
        Account a = new Account(Name = 'Test Account', Customer_Status__c = 'ACTIVE');
        insert a;
        Opportunity opportunityDetailsRecord = new Opportunity();
        opportunityDetailsRecord.Product_Domain__c = 'FIXED TELEPHONY';
        opportunityDetailsRecord.RetiedAccOpp__c = True;
        opportunityDetailsRecord.Name = 'Test Migration';
        opportunityDetailsRecord.Description__c = 'FIXED TELEPHONY';
        opportunityDetailsRecord.Pricing_Method__c = 'Delegated Pricing';
        opportunityDetailsRecord.Product_Type__c = 'Modular';
        opportunityDetailsRecord.Type = 'Migration';
        opportunityDetailsRecord.Billing_Solution__c = 'Non Standard';
        opportunityDetailsRecord.CloseDate = system.today();
        opportunityDetailsRecord.StageName = 'Open';
        opportunityDetailsRecord.AccountId = a.Id;
        insert opportunityDetailsRecord;
        
        Delegated_Pricing_Request__c insertDelegatedPricingRequest = new Delegated_Pricing_Request__c();
        insertDelegatedPricingRequest.Description__c = 'Test';
        insertDelegatedPricingRequest.Opportunity__c = opportunityDetailsRecord.id;
        insertDelegatedPricingRequest.isPrimary__c = False;
        insertDelegatedPricingRequest.Mark_as_Variation__c = False;
        insertDelegatedPricingRequest.Parent_DPR__c = 'Test';
        //insertDelegatedPricingRequest.Total_Contract_Value__c=0;
        insert insertDelegatedPricingRequest;
        
        User userRec = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Migration BOH user'].Id,
            LastName = 'last',
            Email = 'migrationBoh@amamama.com',
            Username = 'migrationBoh@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'migBOH',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert userRec; 
    }
    
    static testMethod void fetchOfferLineItemAndUpdateTest() {
        
        Account a = new Account(Name = 'Test Account', Customer_Status__c = 'ACTIVE');
        insert a;
        
        Opportunity orpportunityDetailsRecord = new Opportunity();
        orpportunityDetailsRecord.Product_Domain__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.RetiedAccOpp__c = True;
        orpportunityDetailsRecord.Name = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Description__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Pricing_Method__c = 'Delegated Pricing';
        orpportunityDetailsRecord.Product_Type__c = 'Modular';
        orpportunityDetailsRecord.CloseDate = system.today();
        orpportunityDetailsRecord.StageName = 'Open';
        orpportunityDetailsRecord.AccountId = a.Id;
        insert orpportunityDetailsRecord;
        
        Delegated_Pricing_Request__c insertDelegatedPricingRequest = new Delegated_Pricing_Request__c();
        insertDelegatedPricingRequest.Description__c = 'Test';
        insertDelegatedPricingRequest.Opportunity__c = orpportunityDetailsRecord.id;
        insertDelegatedPricingRequest.isPrimary__c = False;
        insertDelegatedPricingRequest.Mark_as_Variation__c = False;
        insertDelegatedPricingRequest.Parent_DPR__c = 'Test';
        //insertDelegatedPricingRequest.Total_Contract_Value__c=0;
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
        fam.Opportunity__c=orpportunityDetailsRecord.id;
        fam.Deal_Approver__c=u.Id;
        fam.Delegated_Pricing_Request__c=insertDelegatedPricingRequest.id;
        insert fam;
        
        DPR_offer__c dpo=new  DPR_offer__c();
        dpo.Delegated_Pricing_Request__c=insertDelegatedPricingRequest.Id;
        //dpo.Frame_Agreement__c=fam.Id;
        insert dpo;
        OpportunityTeamMember opp = new OpportunityTeamMember();
        Opp.UserId         = u.Id;
        Opp.OpportunityId  = orpportunityDetailsRecord.id;
        Opp.TeamMemberRole = 'Opportunity Team Member';
        insert opp;
        DPR_Offer_Line_Item__c dprol=new  DPR_Offer_Line_Item__c ();
        dprol.Delegated_Pricing_Request__c= insertDelegatedPricingRequest.Id;
        //dprol.Frame_Agreement__c=fam.Id;
        dprol.DPR_Offer__c=dpo.Id;
        dprol.DPR_Offer_Line_Item_Type__c ='Plan';
        dprol.Overridden_Unit_price__c = 45;
        dprol.isNegotiableCharge__c = true;//added isNegotiableCharge__c = true as part of EDGE-177929 by Team Amsterdam
        insert dprol;
        DPR_Offer_Line_Item__c dprolchild=new  DPR_Offer_Line_Item__c ();
        dprolchild.Delegated_Pricing_Request__c= insertDelegatedPricingRequest.Id;
        //dprolchild.Frame_Agreement__c=fam.Id;
        dprolchild.DPR_Offer__c=dpo.Id;
        dprolchild.Parent_DPR_Offer_Line_Item_Id__c=dprol.id;
        dprol.isNegotiableCharge__c = true;//added isNegotiableCharge__c = true as part of EDGE-177929 by Team Amsterdam
        insert dprolchild; 
        
        DPR_Offer_Line_Item__c dpAddon=new  DPR_Offer_Line_Item__c ();
        dpAddon.Delegated_Pricing_Request__c= insertDelegatedPricingRequest.Id;
        dpAddon.DPR_Offer__c=dpo.Id;
        dpAddon.DPR_Offer_Line_Item_Type__c ='Addon';
        dpAddon.Overridden_Unit_price__c = 45;
        dprolchild.Parent_DPR_Offer_Line_Item_Id__c=dprol.id;
        dpAddon.isNegotiableCharge__c = true;
        insert dpAddon;
        
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
        
        DPR_Rate_Card__c rcObj=new DPR_Rate_Card__c();
        rcObj.Delegated_Pricing_Request__c=insertDelegatedPricingRequest.Id;
        rcObj.DPR_Rate_Card_Type__c='Rate Card';
        rcObj.Parent_DPR_OLI_id__c=dprol.Id;
        rcObj.Rate_Card__c=rc.ID;
        Insert rcObj;
        
        DPR_Rate_Card__c rclObj=new DPR_Rate_Card__c();
        rclObj.Parent_DPR_OLI_id__c=rcObj.Parent_DPR_OLI_id__c;
        rclObj.Delegated_Pricing_Request__c=rcObj.Delegated_Pricing_Request__c;
        rclObj.DPR_Rate_Card_Type__c='Rate Card Line';
        rclObj.DPR_RC_Negotiated_Value__c=12;
        rclObj.Negotiated_Discount__c=5;
        rclObj.Parent_DPR_Rate_Card_ID__c=rcObj.Id;
        rclObj.Rate_Card__c=rcObj.Rate_Card__c;
        rclObj.Rate_Card_Line__c=rcl1.Id;
        insert rclObj;
        Test.startTest();
        List<GetDealScoreController.wrapperLineItem > wrapperList=GetDealScoreController.fetchOfferLineItem(fam.Id);
        System.assertEquals(true, wrapperList != null);//added isNegotiableCharge__c = true as part of EDGE-177929 by Team Amsterdam
        System.assertEquals(true, wrapperList[0].wrapperRateCardLineItem.size()>0);
        //system.debug('@@@@@wrapperList'+wrapperList[0].wrapperRateCardLineItem);
        //Update DPR Offer Line item 
        List<GetDealScoreController.wrapperLineItem> LineItemWrap = new List<GetDealScoreController.wrapperLineItem>();
        for(GetDealScoreController.wrapperLineItem lineWrap : wrapperList){
            lineWrap.recordId=dprol.id;
            lineWrap.activationSIO = 200;
            lineWrap.recontractSIO = 300;
            
            LineItemWrap.add(lineWrap);
        }
        GetDealScoreController.UpdateDPROfferLine(LineItemWrap);
        GetDealScoreController.Samplemethod();
        Test.stopTest();
        
    }
    
    static testMethod void getDealScoreFromPREServerTest() {
        
        Account a = new Account(Name = 'Test Account', Customer_Status__c = 'ACTIVE');
        insert a;
        Opportunity orpportunityDetailsRecord = new Opportunity();
        orpportunityDetailsRecord.Product_Domain__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.RetiedAccOpp__c = True;
        orpportunityDetailsRecord.Name = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Description__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Pricing_Method__c = 'Delegated Pricing';
        orpportunityDetailsRecord.Product_Type__c = 'Modular';
        orpportunityDetailsRecord.CloseDate = system.today();
        orpportunityDetailsRecord.StageName = 'Open';
        orpportunityDetailsRecord.AccountId = a.Id;
        insert orpportunityDetailsRecord;
        
        Delegated_Pricing_Request__c insertDelegatedPricingRequest = new Delegated_Pricing_Request__c();
        insertDelegatedPricingRequest.Description__c = 'Test';
        insertDelegatedPricingRequest.Opportunity__c = orpportunityDetailsRecord.id;
        insertDelegatedPricingRequest.isPrimary__c = False;
        insertDelegatedPricingRequest.Mark_as_Variation__c = False;
        insertDelegatedPricingRequest.Parent_DPR__c = 'Test';
        //insertDelegatedPricingRequest.Total_Contract_Value__c=0;
        insert insertDelegatedPricingRequest;
        System.assert(insertDelegatedPricingRequest != null);
        
        EnvironmentVariable__c ev = new EnvironmentVariable__c();
        ev.Name = 'massl_certificate_name';
        ev.value__c = 'telstrab2b_sandbox';
        insert ev;
        
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
        fam.Opportunity__c=orpportunityDetailsRecord.id;
        fam.Deal_Approver__c=u.Id;
        fam.Delegated_Pricing_Request__c=insertDelegatedPricingRequest.id;
        insert fam;
        
        DPR_offer__c dpo=new  DPR_offer__c();
        dpo.Delegated_Pricing_Request__c=insertDelegatedPricingRequest.Id;
        //dpo.Frame_Agreement__c=fam.Id;
        insert dpo;
        OpportunityTeamMember opp = new OpportunityTeamMember();
        Opp.UserId         = u.Id;
        Opp.OpportunityId  = orpportunityDetailsRecord.id;
        Opp.TeamMemberRole = 'Opportunity Team Member';
        insert opp;
        DPR_Offer_Line_Item__c dprol=new  DPR_Offer_Line_Item__c ();
        dprol.Delegated_Pricing_Request__c= insertDelegatedPricingRequest.Id;
        //dprol.Frame_Agreement__c=fam.Id;
        dprol.DPR_Offer__c=dpo.Id;
        dprol.DPR_Offer_Line_Item_Type__c ='Plan';
        dprol.Overridden_Unit_price__c = 45;
        dprol.isNegotiableCharge__c = true;//added isNegotiableCharge__c = true as part of EDGE-177929 by Team Amsterdam
        insert dprol;
        DPR_Offer_Line_Item__c dprolchild=new  DPR_Offer_Line_Item__c ();
        dprolchild.Delegated_Pricing_Request__c= insertDelegatedPricingRequest.Id;
        //dprolchild.Frame_Agreement__c=fam.Id;
        dprolchild.DPR_Offer__c=dpo.Id;
        dprolchild.Parent_DPR_Offer_Line_Item_Id__c=dprol.id;
        dprol.isNegotiableCharge__c = true;//added isNegotiableCharge__c = true as part of EDGE-177929 by Team Amsterdam
        insert dprolchild; 
        
        DPR_Offer_Line_Item__c dpAddon=new  DPR_Offer_Line_Item__c ();
        dpAddon.Delegated_Pricing_Request__c= insertDelegatedPricingRequest.Id;
        dpAddon.DPR_Offer__c=dpo.Id;
        dpAddon.DPR_Offer_Line_Item_Type__c ='Addon';
        dpAddon.Overridden_Unit_price__c = 45;
        dprolchild.Parent_DPR_Offer_Line_Item_Id__c=dprol.id;
        dpAddon.isNegotiableCharge__c = true;
        insert dpAddon;
        Test.startTest();
        //string correlationId='';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorDealScore());
        String correlationId = GetDealScoreController.getDPRCorrelationID();
        GetDealScoreController.getDealScoreFromPREServer(insertDelegatedPricingRequest.Id,correlationId);
        GetDealScoreController.getDPRCorrelationID();
        String dprOfferId1='';
        string  recordId='';
        string    discountRecordId='';
        string  Delegated_Pricing_Request= 'insertDelegatedPricingRequest';
        string    planType='';
        string   plan='';
        Decimal    listPrice=0.00;
        Decimal   mmc =0.00;
        Decimal    activationSIO = 0;
        Decimal  recontractSIO = 0;
        string  offerLineType='';
        Decimal   Overridden_Unit_price=0.00;
        string finalDelegatedOutcome='';
        string  Deal_Status='';
        GetDealScoreController.wrapperLineItem cmp=new GetDealScoreController.wrapperLineItem();
        cmp.recordId=recordId;
        String DPRRecord='test';
        String DPROffer='test'; 
        String DPROfferLineItem='test';
        String DPRDelegationOutcome='test';
        String DPRGBBReportDetail='test';
        //GetDealScoreController.insertReceivedEventData(DPRRecord,DPROffer,DPROfferLineItem,DPRDelegationOutcome,DPRGBBReportDetail);
        system.assertEquals(GetDealScoreController.insertReceivedEventData(DPRRecord,DPROffer,DPROfferLineItem,DPRDelegationOutcome,DPRGBBReportDetail),'Something went wrong...Please Contact your System Administrator!');
        Test.stopTest();
    }
    
    static testMethod void getFinalDelegationOutcomeAndGBBscaleTest() {
        
        Account a = new Account(Name = 'Test Account', Customer_Status__c = 'ACTIVE');
        insert a;
        Opportunity orpportunityDetailsRecord = new Opportunity();
        orpportunityDetailsRecord.Product_Domain__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.RetiedAccOpp__c = True;
        orpportunityDetailsRecord.Name = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Description__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Pricing_Method__c = 'Delegated Pricing';
        orpportunityDetailsRecord.Product_Type__c = 'Modular';
        orpportunityDetailsRecord.CloseDate = system.today();
        orpportunityDetailsRecord.StageName = 'Open';
        orpportunityDetailsRecord.AccountId = a.Id;
        insert orpportunityDetailsRecord;
        
        Delegated_Pricing_Request__c insertDelegatedPricingRequest = new Delegated_Pricing_Request__c();
        insertDelegatedPricingRequest.Description__c = 'Test';
        insertDelegatedPricingRequest.Opportunity__c = orpportunityDetailsRecord.id;
        insertDelegatedPricingRequest.isPrimary__c = False;
        insertDelegatedPricingRequest.Mark_as_Variation__c = False;
        insertDelegatedPricingRequest.Parent_DPR__c = 'Test';
        //insertDelegatedPricingRequest.Total_Contract_Value__c=0;
        insert insertDelegatedPricingRequest;
        System.assert(insertDelegatedPricingRequest != null);
        
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
        fam.Opportunity__c=orpportunityDetailsRecord.id;
        fam.Deal_Approver__c=u.Id;
        fam.Delegated_Pricing_Request__c=insertDelegatedPricingRequest.id;
        insert fam;
        
        DPR_offer__c dpo=new  DPR_offer__c();
        dpo.Delegated_Pricing_Request__c=insertDelegatedPricingRequest.Id;
        //dpo.Frame_Agreement__c=fam.Id;
        insert dpo;
        OpportunityTeamMember opp = new OpportunityTeamMember();
        Opp.UserId         = u.Id;
        Opp.OpportunityId  = orpportunityDetailsRecord.id;
        Opp.TeamMemberRole = 'Opportunity Team Member';
        insert opp;
        DPR_Offer_Line_Item__c dprol=new  DPR_Offer_Line_Item__c ();
        dprol.Delegated_Pricing_Request__c= insertDelegatedPricingRequest.Id;
        //dprol.Frame_Agreement__c=fam.Id;
        dprol.DPR_Offer__c=dpo.Id;
        dprol.DPR_Offer_Line_Item_Type__c ='Plan';
        dprol.Overridden_Unit_price__c = 45;
        dprol.isNegotiableCharge__c = true;//added isNegotiableCharge__c = true as part of EDGE-177929 by Team Amsterdam
        insert dprol;
        DPR_Offer_Line_Item__c dprolchild=new  DPR_Offer_Line_Item__c ();
        dprolchild.Delegated_Pricing_Request__c= insertDelegatedPricingRequest.Id;
        //dprolchild.Frame_Agreement__c=fam.Id;
        dprolchild.DPR_Offer__c=dpo.Id;
        dprolchild.Parent_DPR_Offer_Line_Item_Id__c=dprol.id;
        dprol.isNegotiableCharge__c = true;//added isNegotiableCharge__c = true as part of EDGE-177929 by Team Amsterdam
        insert dprolchild; 
        
        DPR_Offer_Line_Item__c dpAddon=new  DPR_Offer_Line_Item__c ();
        dpAddon.Delegated_Pricing_Request__c= insertDelegatedPricingRequest.Id;
        dpAddon.DPR_Offer__c=dpo.Id;
        dpAddon.DPR_Offer_Line_Item_Type__c ='Addon';
        dpAddon.Overridden_Unit_price__c = 45;
        dprolchild.Parent_DPR_Offer_Line_Item_Id__c=dprol.id;
        dpAddon.isNegotiableCharge__c = true;
        insert dpAddon;
        Test.startTest();
        GetDealScoreController.getFinalDelegationOutcome(insertDelegatedPricingRequest.Id);  
        GetDealScoreController.getDelegationOutcomeTable(insertDelegatedPricingRequest.Id);  
        
        string palnId='test';
        GetDealScoreController.fetchGBBReportDetails(palnId);
        Test.stopTest();
    }
    
    
    
    /**********************************************************
  * Story: EDGE-185052
  * Developer: Abhishek
  * Team : Osaka
  * Description: Test Method for getOpptyType method.
  * *********************************************************/
    @isTest public static void getOpptyTypeTest(){
        Opportunity oppRec = new Opportunity();
        oppRec = [select id from Opportunity where Name = 'Test Migration' LIMIT 1];
        User userId = new User();
        userId = [select id from User where alias = 'migBOH' limit 1];
        Delegated_Pricing_Request__c dprRec = new Delegated_Pricing_Request__c();
        dprRec = [select id from Delegated_Pricing_Request__c where Description__c = 'Test'];
        csconta__Frame_Agreement__c frameRec = new csconta__Frame_Agreement__c();
        frameRec.Opportunity__c = oppRec.id;
        frameRec.Deal_Approver__c = userId.Id;
        frameRec.csconta__Status__c = 'Draft';
        frameRec.Delegated_Pricing_Request__c = dprRec.id;
        insert frameRec;
        System.runAs(userId){
            Test.startTest();
            Boolean oppType = GetDealScoreController.getOpptyType(frameRec.Id);
            System.assert(oppType == true);
            Test.stopTest();
        }
    }
    /**********************************************************
  * Story: EDGE-185052
  * Developer: Abhishek
  * Team : Osaka
  * Description: Test method for updatDPR method.
  * *********************************************************/
    @isTest public static void updatDPRTest(){
        Opportunity oppRec = new Opportunity();
        oppRec = [select id from Opportunity where Name = 'Test Migration' LIMIT 1];
        User userId = new User();
        userId = [select id from User where LastName = 'last' limit 1];
        Delegated_Pricing_Request__c dprRec = new Delegated_Pricing_Request__c();
        dprRec = [select id from Delegated_Pricing_Request__c where Description__c = 'Test'];
        csconta__Frame_Agreement__c frameRec = new csconta__Frame_Agreement__c();
        frameRec.Opportunity__c = oppRec.id;
        frameRec.Deal_Approver__c = userId.Id;
        frameRec.csconta__Status__c = 'Draft';
        frameRec.Delegated_Pricing_Request__c = dprRec.id;
        insert frameRec;
        
        Test.startTest();
        csconta__Frame_Agreement__c faRec = GetDealScoreController.updatDPR(frameRec.Id);
        System.assert(faRec!=null);
        Test.stopTest();
        
    }
    
    
  
  /**********************************************************
  * Story: EDGE-219478 EDGE-219744
  * Developer: Shivaprasad
  * Team : Napier
  * *********************************************************/
  
         static testMethod void GBBandDelOutHandlerMultiProductTestMethod() {
         List<Delegated_Pricing_Request__c> insertDPRList = new List<Delegated_Pricing_Request__c>();
        
        Delegated_Pricing_Request__c dpr = new Delegated_Pricing_Request__c(Final_Delegation_Outcome__c = 'Customized Pricing',
                                                                            Deal_Status__c = 'Draft');
        insertDPRList.add(dpr);
        
        Delegated_Pricing_Request__c dpr1 = new Delegated_Pricing_Request__c(Final_Delegation_Outcome__c = 'Account Executive',
                                                                             Deal_Status__c = 'Draft');
        insertDPRList.add(dpr1);
        Delegated_Pricing_Request__c dpr2 = new Delegated_Pricing_Request__c(Final_Delegation_Outcome__c = 'No Discount Offerable',
                                                                             Deal_Status__c = 'Draft');
        insertDPRList.add(dpr2);
        Delegated_Pricing_Request__c dpr3 = new Delegated_Pricing_Request__c(Final_Delegation_Outcome__c = '',
                                                                             Deal_Status__c = 'Draft');
        insertDPRList.add(dpr3);
        
        
        insert insertDPRList;
        
         Marketable_Offer__c mOffer1 = new Marketable_Offer__c();
        mOffer1.Offer_ID__c = 'DMCAT_Offer_000646';
        mOffer1.Invoice_Definition__c = 'Invoice_Def_2';
        mOffer1.Auto_Expired_Entity__c = true;
        mOffer1.Product_Family__c = 'Adaptive Mobility';
        insert mOffer1;
    
        Marketable_Offer__c mOffer2 = new Marketable_Offer__c();
        mOffer2.Offer_ID__c = 'DMCAT_Offer_000618';
        mOffer2.Invoice_Definition__c = 'Invoice_Def_2';
        mOffer2.Auto_Expired_Entity__c = true;
        mOffer2.Product_Family__c = 'Telstra Collaboration';
        insert mOffer2;
         
        DPR_Offer__c dprOffer = new DPR_Offer__c(ActualOfferPrice__c = 100, 
                                                 PoorMinimalValue__c = 200, 
                                                 MinimalMarginalValue__c = 300, 
                                                 MarginalGoodValue__c = 400,
                                                 GoodBetterValue__c = 500,
                                                 BetterBestValue__c = 600,
                                                 BestMaxValue__c = 700,
                                                 Marketable_Offer__c = mOffer1.id,
                                                 Final_Delegation_Outcome__c = 'Customized Pricing',
                                                 Delegated_Pricing_Request__c = dpr.id);
        insert dprOffer;
         
         DPR_Offer__c dprOffer2 = new DPR_Offer__c(ActualOfferPrice__c = 200, 
                                                 PoorMinimalValue__c = 200, 
                                                 MinimalMarginalValue__c = 300, 
                                                 MarginalGoodValue__c = 400,
                                                 GoodBetterValue__c = 500,
                                                 BetterBestValue__c = 600,
                                                 BestMaxValue__c = 700,
                                                 Marketable_Offer__c = mOffer2.id,
                                                   Final_Delegation_Outcome__c = 'No Discount Offerable',
                                                 Delegated_Pricing_Request__c = dpr.id);
        insert dprOffer2;
        
      DPR_Delegation_Outcome__c delOut = new DPR_Delegation_Outcome__c(Category__c = 'Mobility', 
                                                                         Label_Name__c = 'Mobility GBB',
                                                                         Sort_Order__c = 1,
                                                                         Actual_Display__c = '16.50(Poor)', 
                                                                         Delegation_Required__c = 'Customized Pricing',
                                                                         AE_Expected_Display__c = 'Poor',
                                                                         SS_Expected_Display__c = 'Marginal',
                                                                         SM_Expected_Display__c = 'Marginal',
                                                                         SGM_Expected_Display__c = 'Marginal',
                                                                         Pricing_Expected_Display__c = 'Marginal',
                                                                       DPR_Offer__c = dprOffer.Id,
                                                                         Delegated_Pricing_Request__c = dpr.id);
        insert delOut;
        
         DPR_Delegation_Outcome__c delOut2 = new DPR_Delegation_Outcome__c(Category__c = 'Mobility', 
                                                                         Label_Name__c = 'Mobility GBB',
                                                                         Sort_Order__c = 1,
                                                                         Actual_Display__c = '16.50(Poor)', 
                                                                         Delegation_Required__c = 'Account Executive',
                                                                         AE_Expected_Display__c = 'Poor',
                                                                         SS_Expected_Display__c = 'Marginal',
                                                                         SM_Expected_Display__c = 'Marginal',
                                                                         SGM_Expected_Display__c = 'Marginal',
                                                                         Pricing_Expected_Display__c = 'Marginal',
                                                                       DPR_Offer__c = dprOffer2.Id,
                                                                         Delegated_Pricing_Request__c = dpr.id);
        insert delOut2;
        
    
        Account acc = new Account();
        acc.name = 'testGBDEL';
        insert acc;
        contact con = new contact();
        con.LastName = 'conLast';
        con.AccountId = acc.id;
        con.Pref_Comm_Method__c = 'eMail';
        con.Authority__c = 'full Authority';
        insert con;

        
        String dprID = String.valueOf(dpr.id);
        String dprID1 = String.valueOf(dpr1.id);
        String dprID2 = String.valueOf(dpr2.id);
        String dprID3 = String.valueOf(dpr3.id);
       
        String dprOfferId = String.valueOf(dprOffer.id);
        String dprOffer2Id = String.valueOf(dprOffer2.id);
         
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
            Delegation_Role__c = 'Account Executive',
            LocaleSidKey = 'en_US'
            
        );
        insert u;
        
  
    
        Account a = new Account(Name = 'Test Account', Customer_Status__c = 'ACTIVE');
        insert a;
    Opportunity oppRecord = new Opportunity();
        oppRecord.Product_Domain__c = 'FIXED TELEPHONY';
        oppRecord.Name = 'FIXED TELEPHONY';
        oppRecord.Description__c = 'FIXED TELEPHONY';
        oppRecord.Pricing_Method__c = 'Delegated Pricing';
        oppRecord.Product_Type__c = 'Modular';
        oppRecord.CloseDate = system.today();
        oppRecord.StageName = 'Open';
        oppRecord.AccountId = a.Id;
        insert oppRecord;
    
        List<csconta__Frame_Agreement__c> famSet = new List<csconta__Frame_Agreement__c>();
    csconta__Frame_Agreement__c fam=new csconta__Frame_Agreement__c();
        fam.Opportunity__c=oppRecord.id; 
        fam.csconta__Status__c = 'Draft';
        fam.is_deal_escalated__c = false;
        fam.Delegated_Pricing_Request__c= dprID1;
        fam.Contract_Acceptance_Date__c=DateTime.now(); 
        //insert fam;
        famSet.add(fam);
    
    csconta__Frame_Agreement__c fam1=new csconta__Frame_Agreement__c();
        fam1.Opportunity__c=oppRecord.id; 
        fam1.csconta__Status__c = 'Draft';
        fam1.is_deal_escalated__c = false;
        fam1.Delegated_Pricing_Request__c= dprID2;
        fam1.Contract_Acceptance_Date__c=DateTime.now(); 
        //insert fam1;
        famSet.add(fam1);
    
    csconta__Frame_Agreement__c fam2=new csconta__Frame_Agreement__c();
        fam2.Opportunity__c=oppRecord.id; 
        fam2.csconta__Status__c = 'Draft';
        fam2.is_deal_escalated__c = false;
        fam2.Delegated_Pricing_Request__c= dprID3;
        fam2.Contract_Acceptance_Date__c=DateTime.now(); 
        //insert fam2;
        famSet.add(fam2);
    
    csconta__Frame_Agreement__c fam3=new csconta__Frame_Agreement__c();
        fam3.Opportunity__c=oppRecord.id; 
        fam3.csconta__Status__c = 'Draft';
        fam3.is_deal_escalated__c = false;
        fam3.Delegated_Pricing_Request__c= dprID;
        fam3.Contract_Acceptance_Date__c=DateTime.now(); 
        //insert fam3;
        famSet.add(fam3);
        insert famSet;

         DPR_Offer__c insertedDPROffer = [select Product_Family__c from DPR_Offer__c where Id =: dprOffer.Id];
         
      System.RunAs(u){  
        //getDPROfferLevelDetails Method Call
        system.debug('dprID::'+dprID+'Product_Family__c::'+insertedDPROffer.Product_Family__c);
        
            DPR_Offer__c dprOfferList = GetDealScoreController.getDPROfferLevelDetails(dprID,insertedDPROffer.Product_Family__c);
            System.assertEquals(300, dprOfferList.MinimalMarginalValue__c);
          
            List<GetDealScoreController.dprOfferFDOColor > wrapperList=GetDealScoreController.getDPROfferFinalDelegationOutcome(dprID);
          system.debug('wrapperList::'+wrapperList+'wrapperListSize::'+wrapperList.size());
         
           System.assertEquals(true, wrapperList != null);
          System.assertEquals(true, wrapperList.size()>0);
            
            //getDPRDelegationOutcomeTable Method Call
            Map<String, List<DPR_Delegation_Outcome__c>> delOutListMap = GetDealScoreController.getDPRDelegationOutcomeTable(dprID);
            System.assertEquals(2, delOutListMap.size());
     }
    }
}