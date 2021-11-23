/*===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1. 			  Shivaprasad Patil	    08/07/21		Modified insertReceivedEventDataTestPositive to increase coverage
***************************************************************************************************/
@isTest
Public class DP_PREInterfaceClass_Test{

    public static testMethod void getDealScoreFromPRETest(){
        //Account a = new Account(Name='Test Account');
        //Insted of creating separate test data, using existing TestUtil factory method for creating Account. 
        //Sprint 19.17 P2OB-4149
        Account a=TestUtil.createAccount('Test Account');
        insert a;
        Opportunity orpportunityDetailsRecord = new Opportunity();
        orpportunityDetailsRecord.Product_Domain__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Name = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Description__c = 'FIXED TELEPHONY';
        orpportunityDetailsRecord.Pricing_Method__c = 'Delegated Pricing';
        orpportunityDetailsRecord.Product_Type__c = 'Modular';
        orpportunityDetailsRecord.CloseDate = system.today();
        orpportunityDetailsRecord.StageName = 'Open';
        orpportunityDetailsRecord.AccountId = a.Id;
        insert orpportunityDetailsRecord;
        system.assertNotEquals(orpportunityDetailsRecord,NULL);
        Delegated_Pricing_Request__c insertDelegatedPricingRequest = new Delegated_Pricing_Request__c();
        insertDelegatedPricingRequest.Description__c ='Test';
        insertDelegatedPricingRequest.Opportunity__c =orpportunityDetailsRecord.id;
        insertDelegatedPricingRequest.isPrimary__c =False;
        insertDelegatedPricingRequest.Mark_as_Variation__c=False;
        insertDelegatedPricingRequest.Parent_DPR__c='Test';
        //insertDelegatedPricingRequest.Total_Contract_Value__c=0;
        insert insertDelegatedPricingRequest;
        system.assertNotEquals(insertDelegatedPricingRequest, NULL);
        EnvironmentVariable__c ev = new EnvironmentVariable__c();
        ev.Name = 'massl_certificate_name';
        ev.value__c = 'telstrab2b_sandbox';
        insert ev;
        String correlationId = GetDealScoreController.getDPRCorrelationID();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorDealScore());
        GetDealScoreController.getDealScoreFromPREServer(insertDelegatedPricingRequest.Id,correlationId);
        Test.stopTest();
        GetDealScoreController.getDealScoreFromPREServer(insertDelegatedPricingRequest.Id,correlationId);
    }
    public static testMethod void insertReceivedEventDataTestPositive(){
    
		List<Delegated_Pricing_Request__c> insertDPRList = new List<Delegated_Pricing_Request__c>();
        
        Delegated_Pricing_Request__c dpr = new Delegated_Pricing_Request__c(Final_Delegation_Outcome__c = 'Customized Pricing',
                                                                            Deal_Status__c = 'Draft');
        insert dpr;
        

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
         
        DPR_Offer__c dprOffer1 = new DPR_Offer__c(Marketable_Offer__c = mOffer1.id,
                                                 Delegated_Pricing_Request__c = dpr.id);
        insert dprOffer1;
         
         DPR_Offer__c dprOffer2 = new DPR_Offer__c(Marketable_Offer__c = mOffer2.id,
                                                 Delegated_Pricing_Request__c = dpr.id);
        insert dprOffer2;
        		
        DPR_Offer_Line_Item__c dprLineItem = new DPR_Offer_Line_Item__c();
        dprLineItem.Name='Standard';
        dprLineItem.DPR_Offer__c=dprOffer1.Id;
        dprLineItem.Delegated_Pricing_Request__c = dpr.Id;
        dprLineItem.Marketable_Offer__c=mOffer1.Id;
        dprLineItem.Offer_Type_Name__c='Committed Data';
        dprLineItem.DPR_Offer_Line_Item_Type__c='Plan';
        dprLineItem.List_Price__c=54.60;
        insert dprLineItem;
        
        DPR_Offer_Line_Item__c dprLineItem1 = new DPR_Offer_Line_Item__c();
        dprLineItem1.Name='Mobile Workspace Discount 1';
        dprLineItem1.DPR_Offer__c=dprOffer1.Id;
        dprLineItem1.Delegated_Pricing_Request__c = dpr.Id;
        dprLineItem1.Marketable_Offer__c=mOffer1.Id;
        dprLineItem1.Offer_Type_Name__c='Committed Data';
        dprLineItem1.DPR_Offer_Line_Item_Type__c='Discount';
        dprLineItem1.List_Price__c=54.60;
        insert dprLineItem1;
		
		
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
		
    
		csconta__Frame_Agreement__c fam=new csconta__Frame_Agreement__c();
        fam.Opportunity__c=oppRecord.id; 
        fam.csconta__Status__c = 'Draft';
        fam.is_deal_escalated__c = false;
        fam.Delegated_Pricing_Request__c= dpr.Id;
        fam.Contract_Acceptance_Date__c=DateTime.now(); 
        insert fam;
		DP_PREInterfaceClass test1 = new DP_PREInterfaceClass();
        DP_PREInterfaceClass.ResponseDetail testing = new DP_PREInterfaceClass.responseDetail();
        
        Test.startTest();
       
        String DPRRecord = '{"Data": {"attributes": {"type": "Delegated_Pricing_Request__c","url":"/services/data/v46.0/sobjects/Delegated_Pricing_Request__c/'+dpr.Id+'"},"Id": "'+dpr.Id+'","Description__c": "Megha is attempting an update","Deal_Status__c":"Scored","Final_Delegation_Outcome__c": "Sales Manager"}}';  

		String DPROffer = '[{"attributes":{"type":"DPR_Offer__c","url":"/services/data/v46.0/sobjects/DPR_Offer__c/Id/'+dprOffer1.Id+'/"},"Id":"'+dprOffer1.Id+'","Final_Delegation_Outcome__c":"Customized Pricing","ActualOfferPrice__c":"214400.0","BestMaxValue__c":"204000.0","BetterBestValue__c":"204000.0","GoodBetterValue__c":"204000.0","MarginalGoodValue__c":"204000.0","MinimalMarginalValue__c":"204000.0","PoorMinimalValue__c":"192872.73"},{"attributes":{"type":"DPR_Offer__c","url":"/services/data/v46.0/sobjects/DPR_Offer__c/Id/'+dprOffer2.Id+'/"},"Id":"'+dprOffer2.Id+'","Final_Delegation_Outcome__c":"No Discount Offerable"}]';
	
        String DPROfferLineItem = '[{"attributes": {"type": "DPR_Offer_Line_Item__c","url":"/services/data/v46.0/sobjects/DPR_Offer_Line_Item__c/'+dprLineItem.Id+'"},"Id": "'+dprLineItem.Id+'","BestMaxValue__c": "16.50","BetterBestValue__c":"12.50","GoodBetterValue__c": "33.90","MarginalGoodValue__c":"34.45","MinimalMarginalValue__c":"83.99","PoorMinimalValue__c" : "18.50"},{"attributes": {"type": "DPR_Offer_Line_Item__c","url":"/services/data/v46.0/sobjects/DPR_Offer_Line_Item__c/'+dprLineItem1.Id+'"},"Id": "'+dprLineItem1.Id+'","BestMaxValue__c": "16.50","BetterBestValue__c":"12.50","GoodBetterValue__c": "33.90","MarginalGoodValue__c":"34.45","MinimalMarginalValue__c":"83.99","PoorMinimalValue__c" : "18.50"}]';
        
        String DPRDelegationOutcome = '[{"attributes": {"type": "DPR_Delegation_Outcome__c","url":"/services/data/v46.0/sobjects/DPR_Delegation_Outcome__c"},"Actual_Display__c": "16.50(Poor)","Actual_Display_Value__c": "11.99","AE_Expected_Display__c":"Poor","AE_Expected_Display_Value__c": "12.99","Category__c":"Mobility","Delegated_Pricing_Request__c":"'+dpr.Id+'","DPR_Offer__c" : "'+dprOffer1.Id+'","Delegation_Required__c" : "Customized Pricing","Label_Name__c" : "Test Label","Pricing_Expected_Display__c" : "Marginal","Pricing_Expected_Display_Value__c" : "17.99", "SGM_Expected_Display__c" : "Marginal","SGM_Expected_Display_Value__c" : "17.99","SM_Expected_Display__c" : "Marginal","SM_Expected_Display_Value__c" : "17.99","Sort_Order__c" : "5","SS_Expected_Display__c" : "Marginal","SS_Expected_Display_Value__c" : "17.99"},{"attributes": {"type": "DPR_Delegation_Outcome__c","url":"/services/data/v46.0/sobjects/DPR_Delegation_Outcome__c"},"Actual_Display__c": "16.50(Poor)","Actual_Display_Value__c": "11.99","AE_Expected_Display__c":"Poor","AE_Expected_Display_Value__c": "12.99","Category__c":"Mobility","Delegated_Pricing_Request__c":"'+dpr.id+'","DPR_Offer__c" : "'+dprOffer2.Id+'","Delegation_Required__c" : "Customized Pricing","Label_Name__c" : "Test Label","Pricing_Expected_Display__c" : "Marginal","Pricing_Expected_Display_Value__c" : "17.99", "SGM_Expected_Display__c" : "Marginal","SGM_Expected_Display_Value__c" : "17.99","SM_Expected_Display__c" : "Marginal","SM_Expected_Display_Value__c" : "17.99","Sort_Order__c" : "5","SS_Expected_Display__c" : "Marginal","SS_Expected_Display_Value__c" : "17.99"}]';

        String DPRGBBReportDetail = '[{"attributes": {"type": "DPR_GBB_Report_Detail__c","url":"/services/data/v46.0/sobjects/DPR_GBB_Report_Detail__c"},  "Annual_Revenue_Impact__c" : "1625.50", "Display_Name__c" : "Poor","DPR_Offer_Line_Item__c" : "'+dprLineItem.Id+'","Impact_Type__c" : "12.99","Label_Name__c" : "Mobility","Scenario_Value__c" : "12.99"},{"attributes": {"type": "DPR_GBB_Report_Detail__c","url":"/services/data/v46.0/sobjects/DPR_GBB_Report_Detail__c"},  "Annual_Revenue_Impact__c" : "1625.50", "Display_Name__c" : "Poor","DPR_Offer_Line_Item__c" : "'+dprLineItem.Id+'","Impact_Type__c" : "12.99","Label_Name__c" : "Mobility","Scenario_Value__c" : "12.99"}]"';

        system.assertNotEquals(GetDealScoreController.insertReceivedEventData(DPRRecord, DPROffer, DPROfferLineItem, DPRDelegationOutcome, DPRGBBReportDetail),null);
        Test.stopTest();
    }
     public static testMethod void mapJSONToObjectsTest(){
    
        Test.startTest();
        system.assertEquals(DP_PREInterfaceClass.mapJSONToObjects('teststring','teststring','teststring','teststring','teststring'),'Something went wrong...Please Contact your System Administrator!');
        
        Test.stopTest();
    }
	
}