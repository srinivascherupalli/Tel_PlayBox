/*****************************************************************************************
* Name : FAM_PRGRA_HandlerTest
* Description : 
* ModifiedBy        ModifiedDate    Edge Number   Description
* Shashank Jadhav   10/05/2021      EDGE- 219476   Pricing Rules per product family  
* Shubham Tiwari   22/09/2021      DIGI-24015  FA Custom price rule creation logic optimization 
************************************************************************************************************************************************/

@isTest
private class FAM_PRGRA_HandlerTest {
   
    static testMethod void VerifyActivateFrameAgreement() {
        Account a = new Account(Name = 'Test Account', Customer_Status__c = 'ACTIVE');
        insert a;
        Contact c = new Contact();
        c.FirstName = 'Paul';
        c.LastName  = 'Test';
        c.AccountId = a.id;
        c.MailingStreet = '298 S. Ringo Street';
        c.MailingCity = 'Little Rock';
        c.MailingState = 'AR';
        c.MailingPostalCode = '72201'; 
        insert c;
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
        orpportunityDetailsRecord.Contract_Term__c = 36;
        insert orpportunityDetailsRecord;
        
        Delegated_Pricing_Request__c insertDelegatedPricingRequest = new Delegated_Pricing_Request__c();
        insertDelegatedPricingRequest.Description__c = 'Test';
        insertDelegatedPricingRequest.Opportunity__c = orpportunityDetailsRecord.id;
        insertDelegatedPricingRequest.isPrimary__c = False;
        insertDelegatedPricingRequest.Mark_as_Variation__c = False;
        insertDelegatedPricingRequest.Parent_DPR__c = 'Test';
        insertDelegatedPricingRequest.Final_Delegation_Outcome__c = 'Sales Specialist';
        insertDelegatedPricingRequest.Tech_Reward_Type__c = 'Advance';
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
            Delegation_Role__c = 'Account Executive',
            LocaleSidKey = 'en_US'
            
        );
        insert u; 
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = c.Id;
        ocr.OpportunityId =orpportunityDetailsRecord.Id;
        ocr.IsPrimary = TRUE;
        ocr.Role = 'Decision Maker';
        insert ocr;
        
        csconta__Frame_Agreement__c fam=new csconta__Frame_Agreement__c();
        fam.Opportunity__c=orpportunityDetailsRecord.id;
        fam.Deal_Approver__c=u.Id;
        fam.csconta__Status__c = 'Active';
        fam.Delegated_Pricing_Request__c=insertDelegatedPricingRequest.id;
        fam.Contract_Acceptance_Date__c=DateTime.now(); 
        fam.csconta__Account__c=a.Id;
        fam.Mark_as_Variation__c = false;
        fam.csconta__effective_start_date__c = DateTime.now(); 
        fam.csconta__effective_end_date__c = DateTime.now().addMonths(36);
        insert fam;
        
        DPR_offer__c dpo=new  DPR_offer__c();
        dpo.Delegated_Pricing_Request__c=insertDelegatedPricingRequest.Id;
        dpo.Fund_Increment_Frequency__c = 'Annual In Advance';
        dpo.Fund_Amount__c = 9000;
        dpo.PF_Contract_term__c =24;
        insert dpo;
        
        OpportunityTeamMember opp = new OpportunityTeamMember();
        Opp.UserId         = u.Id;
        Opp.OpportunityId  = orpportunityDetailsRecord.id;
        Opp.TeamMemberRole = 'Opportunity Team Member';
        insert opp;     
        
        cspmb__Pricing_Rule__c pr = new cspmb__Pricing_Rule__c();   
        pr.cspmb__pricing_rule_code__c = 'BasePrices';
        pr.cspmb__description__c = 'Auto generated from FA decomposition.';
        pr.cspmb__pricing_rule_code__c='FAM 2021-05-06 09:46:34___3';
        insert pr;


        cspmb__Pricing_Rule_Group__c pg = new cspmb__Pricing_Rule_Group__c();
        pg.Name = 'PG2';
        pg.cspmb__description__c ='Auto generated from FA decomposition.';
        pg.cspmb__pricing_rule_group_code__c = 'FAM 2021-05-06 09:46:34___3';
        pg.cspmb__priority__c = 100;
        pg.cspmb__rule_group_compounding_type__c='Inclusive';
        //pg.csfam__standard_price_book__c = true;
        pg.csconta__frame_agreement__c=fam.Id;
        insert pg;

        cspmb__Pricing_Rule_Group_Rule_Association__c PriceRuleAssoc = new cspmb__Pricing_Rule_Group_Rule_Association__c();
        PriceRuleAssoc.cspmb__pricing_rule_group__c = pg.Id;
        PriceRuleAssoc.cspmb__pricing_rule__c = pr.Id;
        insert PriceRuleAssoc;
        
        cspmb__Price_Item__c priceItem = new cspmb__Price_Item__c();
        priceItem.name = 'Enterprise Mobility';
        priceItem.Commercial_Product_Code__c = 'DMCAT_Offer_001233_DMCAT_ProductSpecification_001196_DMCAT_RecurringCharge_001232_7790';
        priceItem.cspmb__Billing_Frequency__c = 'Monthly';
        priceItem.ProdSpecId__c = 'DMCAT_ProductSpecification_001196';
        priceItem.BillingSpecId__c = 'BSRC001_CB';
        priceItem.Offer_Id__c = 'DMCAT_Offer_001233';
        priceItem.Plan__c = 'Plan__c';
        priceItem.cspmb__Recurring_Charge__c = 45.45;
        priceItem.cspmb__Is_Recurring_Discount_Allowed__c = true;// Added for EDGE 184803 by team Amsterdam
        priceItem.ChargeType__c='RC';//EDGE-177929
        priceItem.Offer_Name__c='Adaptive Mobility';
        Insert priceItem;
        
        cspmb__Price_Item__c priceItem2 = new cspmb__Price_Item__c();
        priceItem2.name = 'Enterprise Mobility';
        priceItem2.Commercial_Product_Code__c = 'DMCAT_Offer_001233_DMCAT_ProductSpecification_001196_DMCAT_RecurringCharge_001232_7790';
        priceItem2.cspmb__Billing_Frequency__c = 'Monthly';
        priceItem2.ProdSpecId__c = 'DMCAT_ProductSpecification_001196';
        priceItem2.BillingSpecId__c = 'BSRC001_CB';
        priceItem2.Offer_Id__c = 'DMCAT_Offer_001233';
        priceItem2.Plan__c = 'Plan__c';
        priceItem2.cspmb__Recurring_Charge__c = 55.45;
        priceItem2.cspmb__Is_Recurring_Discount_Allowed__c = true;// Added for EDGE 184803 by team Amsterdam
        priceItem2.ChargeType__c='RC';//EDGE-177929
        priceItem2.Offer_Name__c='CMPD';
        Insert priceItem2;
        
        List<cspmb__Add_On_Price_Item__c> piaddonlist = new List<cspmb__Add_On_Price_Item__c>();
        cspmb__Add_On_Price_Item__c piAddOn = new cspmb__Add_On_Price_Item__c();
        piAddOn.Name = 'AppleCare+ 2 years iPad 10.2 G8';
        piAddOn.cspmb__Add_On_Price_Item_Code__c = 'DMCAT_Offer_001233_DMCAT_ProductSpecification_001208_DMCAT_NonRecurringCharge_001216_8110';
        piAddOn.Offer_Id__c = 'DMCAT_Offer_001233';
        piAddOn.cspmb__Is_One_Off_Discount_Allowed__c = false;
        piAddOn.cspmb__Is_Recurring_Discount_Allowed__c = false;
        piAddOn.ProdSpecId__c='DMCAT_ProductSpecification_001208';        
        piaddonlist.add(piAddOn);
        //EDGE-177926 end        
        cspmb__Add_On_Price_Item__c piAddOn1 = new cspmb__Add_On_Price_Item__c();
        piAddOn1.Name = 'AppleCare+ 2 years iPad 10.2 G8_Test';
        piAddOn1.cspmb__Add_On_Price_Item_Code__c = 'DMCAT_Offer_001233_DMCAT_ProductSpecification_001208_DMCAT_NonRecurringCharge_001216_8110';
        piAddOn1.Offer_Id__c = 'DMCAT_Offer_001233';
        piAddOn1.cspmb__Is_One_Off_Discount_Allowed__c = false;
        piAddOn1.cspmb__Is_Recurring_Discount_Allowed__c = true;
        piAddOn1.ProdSpecId__c='DMCAT_ProductSpecification_001208';        
        piaddonlist.add(piAddOn1);
        if(!piaddonlist.isEmpty()){
            insert piaddonlist;
        }
        List<cspmb__Price_Item_Add_On_Price_Item_Association__c> piaddonassList = new List<cspmb__Price_Item_Add_On_Price_Item_Association__c>();
        cspmb__Price_Item_Add_On_Price_Item_Association__c piaddonasso = new cspmb__Price_Item_Add_On_Price_Item_Association__c();
        piaddonasso.cspmb__Price_Item__c = priceItem.Id;
        piaddonasso.cspmb__Add_On_Price_Item__c = piaddonlist[0].Id;
        piaddonasso.cspmb__One_Off_Charge__c = 90;
        piaddonasso.cspmb__Recurring_Charge__c=0.00;
        
        piaddonassList.add(piaddonasso); 
        
        cspmb__Price_Item_Add_On_Price_Item_Association__c piaddonasso1 = new cspmb__Price_Item_Add_On_Price_Item_Association__c();
        piaddonasso1.cspmb__Price_Item__c = priceItem2.Id;
        piaddonasso1.cspmb__Add_On_Price_Item__c = piaddonlist[1].Id;
        piaddonasso1.cspmb__One_Off_Charge__c = 0.00;
        piaddonasso1.cspmb__Recurring_Charge__c=50;
        piaddonassList.add(piaddonasso1);
        if(!piaddonassList.isEmpty()){
          insert  piaddonassList;   
        }
        
        
        cspmb__Price_Item_Pricing_Rule_Association__c pipra=new cspmb__Price_Item_Pricing_Rule_Association__c();
        pipra.cspmb__association_type__c = 'Pricing change';
        pipra.cspmb__target_price__c = 'Sales';
        pipra.cspmb__recurring_adjustment_type__c='Price Override';
        pipra.cspmb__one_off_adjustment_type__c='Price Override';   
        pipra.cspmb__pricing_rule__c = pr.id;
        pipra.cspmb__price_item__c = priceItem.Id;
        pipra.cspmb__recurring_adjustment__c=10;
        insert pipra;
        
        cspmb__Price_Item_Pricing_Rule_Association__c pipra2=new cspmb__Price_Item_Pricing_Rule_Association__c();
        pipra2.cspmb__association_type__c = 'Pricing change';
        pipra2.cspmb__target_price__c = 'Sales';
        pipra2.cspmb__recurring_adjustment_type__c='Price Override';
        pipra2.cspmb__one_off_adjustment_type__c='Price Override';  
        pipra2.cspmb__pricing_rule__c = pr.id;
        pipra2.cspmb__price_item__c = priceItem2.Id;
        pipra2.cspmb__recurring_adjustment__c=20;
        insert pipra2;
        
        Marketable_Offer__c mOffer = new Marketable_Offer__c();
        mOffer.Name = 'Adaptive Mobility';
        mOffer.Solution_Template__c = '';
        mOffer.Configurations__c = '{"skipBasketSyncValidations":false}';
        mOffer.Config__c = '{"skipBasketSyncValidations":false,"validateBillAccEnrich":true}';
        mOffer.Offer_ID__c = 'DMCAT_Offer_001233';
        insert mOffer;
        
        Marketable_Offer__c mOffer2 = new Marketable_Offer__c();
        mOffer2.Name = 'CMPD';
        mOffer2.Solution_Template__c = '';
        mOffer2.Configurations__c = '{"skipBasketSyncValidations":false}';
        mOffer2.Config__c = '{"skipBasketSyncValidations":false,"validateBillAccEnrich":true}';
        mOffer2.Offer_ID__c = 'DMCAT_Offer_001233';
        insert mOffer2;
        
        DPR_Offer__c dprOffer = new DPR_Offer__c();
        dprOffer.Name = 'Adaptive Mobility';
        dprOffer.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id;
        dprOffer.Marketable_Offer__c = mOffer.Id;
        dprOffer.ContractStartDate__c = System.now();
        //dprOffer.ContractEndDate__c = System.now().addYears(2);
        insert dprOffer;
        
        DPR_Offer__c dprOffer2 = new DPR_Offer__c();
        dprOffer2.Name = 'CMPD';
        dprOffer2.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id;
        dprOffer2.Marketable_Offer__c = mOffer2.Id;
        dprOffer2.ContractStartDate__c = System.now();
        //dprOffer2.ContractEndDate__c = System.now().addYears(3);
        insert dprOffer2;
        
        Test.startTest();
            FAMActionHelper famh=new FAMActionHelper();
            String jsonVal ='{"method":"activateFrameAgreement","faId":"'+fam.Id+'"}'; 
            //famh.performAction(jsonVal);
            System.assertEquals('success',famh.performAction(jsonVal));
            FAM_PRGRA_Handler handler= new FAM_PRGRA_Handler();
            String response=handler.preparePricingGroupsPerProductFamily(fam.Id);
            System.assertEquals('Success',response);
        Test.stopTest();
        
       // Delegated_Pricing_Request__c prevDpr = [select id,Name,Deal_Status__c from Delegated_Pricing_Request__c where id =: insertDelegatedPricingRequest1.Id];
       // System.assertEquals('Draft',prevDpr.Deal_Status__c);
    }
     
    /*static testMethod void VerifyActivateFrameAgreement2() {
        Account a = new Account(Name = 'Test Account', Customer_Status__c = 'ACTIVE');
        insert a;
        Contact c = new Contact();
        c.FirstName = 'Paul';
        c.LastName  = 'Test';
        c.AccountId = a.id;
        c.MailingStreet = '298 S. Ringo Street';
        c.MailingCity = 'Little Rock';
        c.MailingState = 'AR';
        c.MailingPostalCode = '72201'; 
        insert c;
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
        orpportunityDetailsRecord.Contract_Term__c = 36;
        insert orpportunityDetailsRecord;
        
        Delegated_Pricing_Request__c insertDelegatedPricingRequest = new Delegated_Pricing_Request__c();
        insertDelegatedPricingRequest.Description__c = 'Test';
        insertDelegatedPricingRequest.Opportunity__c = orpportunityDetailsRecord.id;
        insertDelegatedPricingRequest.isPrimary__c = False;
        insertDelegatedPricingRequest.Mark_as_Variation__c = False;
        insertDelegatedPricingRequest.Parent_DPR__c = 'Test';
        insertDelegatedPricingRequest.Final_Delegation_Outcome__c = 'Sales Specialist';
        insertDelegatedPricingRequest.Tech_Reward_Type__c = 'Advance';
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
            Delegation_Role__c = 'Account Executive',
            LocaleSidKey = 'en_US'
            
        );
        insert u; 
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = c.Id;
        ocr.OpportunityId =orpportunityDetailsRecord.Id;
        ocr.IsPrimary = TRUE;
        ocr.Role = 'Decision Maker';
        insert ocr;
        
        csconta__Frame_Agreement__c fam=new csconta__Frame_Agreement__c();
        fam.Opportunity__c=orpportunityDetailsRecord.id;
        fam.Deal_Approver__c=u.Id;
        fam.csconta__Status__c = 'Active';
        fam.Delegated_Pricing_Request__c=insertDelegatedPricingRequest.id;
        fam.Contract_Acceptance_Date__c=DateTime.now(); 
        fam.csconta__Account__c=a.Id;
        fam.Mark_as_Variation__c = false;
        fam.csconta__effective_start_date__c = DateTime.now(); 
        fam.csconta__effective_end_date__c = DateTime.now().addMonths(36);
        insert fam;
        
        DPR_offer__c dpo=new  DPR_offer__c();
        dpo.Delegated_Pricing_Request__c=insertDelegatedPricingRequest.Id;
        dpo.Fund_Increment_Frequency__c = 'Annual In Advance';
        dpo.Fund_Amount__c = 9000;
        dpo.PF_Contract_term__c =24;
        insert dpo;
        
        OpportunityTeamMember opp = new OpportunityTeamMember();
        Opp.UserId         = u.Id;
        Opp.OpportunityId  = orpportunityDetailsRecord.id;
        Opp.TeamMemberRole = 'Opportunity Team Member';
        insert opp;     
        
        cspmb__Pricing_Rule__c pr = new cspmb__Pricing_Rule__c();   
        pr.cspmb__pricing_rule_code__c = 'BasePrices';
        pr.cspmb__description__c = 'Auto generated from FA decomposition.';
        pr.cspmb__pricing_rule_code__c='FAM 2021-05-06 09:46:34___3';
        insert pr;


        cspmb__Pricing_Rule_Group__c pg = new cspmb__Pricing_Rule_Group__c();
        pg.Name = 'PG2';
        pg.cspmb__description__c ='Auto generated from FA decomposition.';
        pg.cspmb__pricing_rule_group_code__c = 'FAM 2021-05-06 09:46:34___3';
        pg.cspmb__priority__c = 100;
        pg.cspmb__rule_group_compounding_type__c='Inclusive';
        //pg.csfam__standard_price_book__c = true;
        pg.csconta__frame_agreement__c=fam.Id;
        insert pg;

        cspmb__Pricing_Rule_Group_Rule_Association__c PriceRuleAssoc = new cspmb__Pricing_Rule_Group_Rule_Association__c();
        PriceRuleAssoc.cspmb__pricing_rule_group__c = pg.Id;
        PriceRuleAssoc.cspmb__pricing_rule__c = pr.Id;
        insert PriceRuleAssoc;
        
        cspmb__Price_Item__c priceItem = new cspmb__Price_Item__c();
        priceItem.name = 'Enterprise Mobility';
        priceItem.Commercial_Product_Code__c = 'DMCAT_Offer_001233_DMCAT_ProductSpecification_001196_DMCAT_RecurringCharge_001232_7790';
        priceItem.cspmb__Billing_Frequency__c = 'Monthly';
        priceItem.ProdSpecId__c = 'DMCAT_ProductSpecification_001196';
        priceItem.BillingSpecId__c = 'BSRC001_CB';
        priceItem.Offer_Id__c = 'DMCAT_Offer_001233';
        priceItem.Plan__c = 'Plan__c';
        priceItem.cspmb__Recurring_Charge__c = 45.45;
        priceItem.cspmb__Is_Recurring_Discount_Allowed__c = true;// Added for EDGE 184803 by team Amsterdam
        priceItem.ChargeType__c='RC';//EDGE-177929
        priceItem.Offer_Name__c='Adaptive Mobility';
        Insert priceItem;
        
        cspmb__Price_Item__c priceItem2 = new cspmb__Price_Item__c();
        priceItem2.name = 'Enterprise Mobility';
        priceItem2.Commercial_Product_Code__c = 'DMCAT_Offer_001233_DMCAT_ProductSpecification_001196_DMCAT_RecurringCharge_001232_7790';
        priceItem2.cspmb__Billing_Frequency__c = 'Monthly';
        priceItem2.ProdSpecId__c = 'DMCAT_ProductSpecification_001196';
        priceItem2.BillingSpecId__c = 'BSRC001_CB';
        priceItem2.Offer_Id__c = 'DMCAT_Offer_001233';
        priceItem2.Plan__c = 'Plan__c';
        priceItem2.cspmb__Recurring_Charge__c = 55.45;
        priceItem2.cspmb__Is_Recurring_Discount_Allowed__c = true;// Added for EDGE 184803 by team Amsterdam
        priceItem2.ChargeType__c='RC';//EDGE-177929
        priceItem2.Offer_Name__c='CMPD';
        Insert priceItem2;
        
        List<cspmb__Add_On_Price_Item__c> piaddonlist = new List<cspmb__Add_On_Price_Item__c>();
        cspmb__Add_On_Price_Item__c piAddOn = new cspmb__Add_On_Price_Item__c();
        piAddOn.Name = 'AppleCare+ 2 years iPad 10.2 G8';
        piAddOn.cspmb__Add_On_Price_Item_Code__c = 'DMCAT_Offer_001233_DMCAT_ProductSpecification_001208_DMCAT_NonRecurringCharge_001216_8110';
        piAddOn.Offer_Id__c = 'DMCAT_Offer_001233';
        piAddOn.cspmb__Is_One_Off_Discount_Allowed__c = false;
        piAddOn.cspmb__Is_Recurring_Discount_Allowed__c = false;
        piAddOn.ProdSpecId__c='DMCAT_ProductSpecification_001208';        
        piaddonlist.add(piAddOn);
        //EDGE-177926 end        
        cspmb__Add_On_Price_Item__c piAddOn1 = new cspmb__Add_On_Price_Item__c();
        piAddOn1.Name = 'AppleCare+ 2 years iPad 10.2 G8_Test';
        piAddOn1.cspmb__Add_On_Price_Item_Code__c = 'DMCAT_Offer_001233_DMCAT_ProductSpecification_001208_DMCAT_NonRecurringCharge_001216_8110';
        piAddOn1.Offer_Id__c = 'DMCAT_Offer_001233';
        piAddOn1.cspmb__Is_One_Off_Discount_Allowed__c = false;
        piAddOn1.cspmb__Is_Recurring_Discount_Allowed__c = true;
        piAddOn1.ProdSpecId__c='DMCAT_ProductSpecification_001208';        
        piaddonlist.add(piAddOn1);
        if(!piaddonlist.isEmpty()){
            insert piaddonlist;
        }
        List<cspmb__Price_Item_Add_On_Price_Item_Association__c> piaddonassList = new List<cspmb__Price_Item_Add_On_Price_Item_Association__c>();
        cspmb__Price_Item_Add_On_Price_Item_Association__c piaddonasso = new cspmb__Price_Item_Add_On_Price_Item_Association__c();
        piaddonasso.cspmb__Price_Item__c = priceItem.Id;
        piaddonasso.cspmb__Add_On_Price_Item__c = piaddonlist[0].Id;
        piaddonasso.cspmb__One_Off_Charge__c = 90;
        piaddonasso.cspmb__Recurring_Charge__c=0.00;
        
        piaddonassList.add(piaddonasso); 
        
        cspmb__Price_Item_Add_On_Price_Item_Association__c piaddonasso1 = new cspmb__Price_Item_Add_On_Price_Item_Association__c();
        piaddonasso1.cspmb__Price_Item__c = priceItem2.Id;
        piaddonasso1.cspmb__Add_On_Price_Item__c = piaddonlist[1].Id;
        piaddonasso1.cspmb__One_Off_Charge__c = 0.00;
        piaddonasso1.cspmb__Recurring_Charge__c=50;
        piaddonassList.add(piaddonasso1);
        if(!piaddonassList.isEmpty()){
          insert  piaddonassList;   
        }
        
        
        cspmb__Price_Item_Pricing_Rule_Association__c pipra=new cspmb__Price_Item_Pricing_Rule_Association__c();
        pipra.cspmb__association_type__c = 'Pricing change';
        pipra.cspmb__target_price__c = 'Sales';
        pipra.cspmb__recurring_adjustment_type__c='Price Override';
        pipra.cspmb__one_off_adjustment_type__c='Price Override';   
        pipra.cspmb__pricing_rule__c = pr.id;
        pipra.cspmb__price_item__c = priceItem.Id;
        pipra.cspmb__recurring_adjustment__c=10;
        insert pipra;
        
        cspmb__Price_Item_Pricing_Rule_Association__c pipra2=new cspmb__Price_Item_Pricing_Rule_Association__c();
        pipra2.cspmb__association_type__c = 'Pricing change';
        pipra2.cspmb__target_price__c = 'Sales';
        pipra2.cspmb__recurring_adjustment_type__c='Price Override';
        pipra2.cspmb__one_off_adjustment_type__c='Price Override';  
        pipra2.cspmb__pricing_rule__c = pr.id;
        pipra2.cspmb__price_item__c = priceItem2.Id;
        pipra2.cspmb__recurring_adjustment__c=20;
        insert pipra2;
        
        Marketable_Offer__c mOffer = new Marketable_Offer__c();
        mOffer.Name = 'Adaptive Mobility';
        mOffer.Solution_Template__c = '';
        mOffer.Configurations__c = '{"skipBasketSyncValidations":false}';
        mOffer.Config__c = '{"skipBasketSyncValidations":false,"validateBillAccEnrich":true}';
        mOffer.Offer_ID__c = 'DMCAT_Offer_001233';
        insert mOffer;
        
        Marketable_Offer__c mOffer2 = new Marketable_Offer__c();
        mOffer2.Name = 'CMPD';
        mOffer2.Solution_Template__c = '';
        mOffer2.Configurations__c = '{"skipBasketSyncValidations":false}';
        mOffer2.Config__c = '{"skipBasketSyncValidations":false,"validateBillAccEnrich":true}';
        mOffer2.Offer_ID__c = 'DMCAT_Offer_001233';
        insert mOffer2;
        
        DPR_Offer__c dprOffer = new DPR_Offer__c();
        dprOffer.Name = 'Adaptive Mobility';
        dprOffer.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id;
        dprOffer.Marketable_Offer__c = mOffer.Id;
        dprOffer.ContractStartDate__c = System.now();
        //dprOffer.ContractEndDate__c = System.now().addYears(2);
        insert dprOffer;
        
        DPR_Offer__c dprOffer2 = new DPR_Offer__c();
        dprOffer2.Name = 'CMPD';
        dprOffer2.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id;
        dprOffer2.Marketable_Offer__c = mOffer2.Id;
        dprOffer2.ContractStartDate__c = System.now();
        //dprOffer2.ContractEndDate__c = System.now().addYears(3);
        insert dprOffer2;
        
        Test.startTest();
            FAMActionHelper famh=new FAMActionHelper();
            String jsonVal ='{"method":"activateFrameAgreement","faId":"'+fam.Id+'"}'; 
            //famh.performAction(jsonVal);
            
            System.assertEquals('success',famh.performAction(jsonVal));
            System.debug('$$$$$Entered in isRunningTest');
            FAM_PRGRA_Handler handler= new FAM_PRGRA_Handler();
            String response=handler.preparePricingGroupsPerProductFamily(fam.Id);
            System.assertEquals('Success',response);
        Test.stopTest();
        
       // Delegated_Pricing_Request__c prevDpr = [select id,Name,Deal_Status__c from Delegated_Pricing_Request__c where id =: insertDelegatedPricingRequest1.Id];
       // System.assertEquals('Draft',prevDpr.Deal_Status__c);
    }
    */
    

     static testMethod void VerifyActivateFrameAgreement2() {
        Account a = new Account(Name = 'Test Account', Customer_Status__c = 'ACTIVE');
        insert a;
        Contact c = new Contact();
        c.FirstName = 'Paul';
        c.LastName  = 'Test';
        c.AccountId = a.id;
        c.MailingStreet = '298 S. Ringo Street';
        c.MailingCity = 'Little Rock';
        c.MailingState = 'AR';
        c.MailingPostalCode = '72201'; 
        insert c;
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
        orpportunityDetailsRecord.Contract_Term__c = 36;
        insert orpportunityDetailsRecord;
        
        Delegated_Pricing_Request__c insertDelegatedPricingRequest = new Delegated_Pricing_Request__c();
        insertDelegatedPricingRequest.Description__c = 'Test';
        insertDelegatedPricingRequest.Opportunity__c = orpportunityDetailsRecord.id;
        insertDelegatedPricingRequest.isPrimary__c = False;
        insertDelegatedPricingRequest.Mark_as_Variation__c = False;
        insertDelegatedPricingRequest.Parent_DPR__c = 'Test';
        insertDelegatedPricingRequest.Final_Delegation_Outcome__c = 'Sales Specialist';
        insertDelegatedPricingRequest.Tech_Reward_Type__c = 'Advance';
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
            Delegation_Role__c = 'Account Executive',
            LocaleSidKey = 'en_US'
            
        );
        insert u; 
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = c.Id;
        ocr.OpportunityId =orpportunityDetailsRecord.Id;
        ocr.IsPrimary = TRUE;
        ocr.Role = 'Decision Maker';
        insert ocr;
        
        csconta__Frame_Agreement__c fam=new csconta__Frame_Agreement__c();
        fam.Opportunity__c=orpportunityDetailsRecord.id;
        fam.Deal_Approver__c=u.Id;
        fam.csconta__Status__c = 'Active';
        fam.Delegated_Pricing_Request__c=insertDelegatedPricingRequest.id;
        fam.Contract_Acceptance_Date__c=DateTime.now(); 
        fam.csconta__Account__c=a.Id;
        fam.Mark_as_Variation__c = false;
        fam.csconta__effective_start_date__c = DateTime.now(); 
        fam.csconta__effective_end_date__c = DateTime.now().addMonths(36);
        insert fam;
        
      /*  DPR_offer__c dpo=new  DPR_offer__c();
        dpo.Delegated_Pricing_Request__c=insertDelegatedPricingRequest.Id;
        dpo.Fund_Increment_Frequency__c = 'Annual In Advance';
        dpo.Fund_Amount__c = 9000;
        dpo.PF_Contract_term__c =24;
        insert dpo;
         */
        
        OpportunityTeamMember opp = new OpportunityTeamMember();
        Opp.UserId         = u.Id;
        Opp.OpportunityId  = orpportunityDetailsRecord.id;
        Opp.TeamMemberRole = 'Opportunity Team Member';
        insert opp;     
        
        cspmb__Pricing_Rule__c pr = new cspmb__Pricing_Rule__c();   
        pr.cspmb__pricing_rule_code__c = 'BasePrices';
        pr.cspmb__description__c = 'Auto generated from FA decomposition.';
        pr.cspmb__pricing_rule_code__c='FAM 2021-05-06 09:46:34___3';
        insert pr;


        cspmb__Pricing_Rule_Group__c pg = new cspmb__Pricing_Rule_Group__c();
        pg.Name = 'PG2';
        pg.cspmb__description__c ='Auto generated from FA decomposition.';
        pg.cspmb__pricing_rule_group_code__c = 'FAM 2021-05-06 09:46:34___3';
        pg.cspmb__priority__c = 100;
        pg.cspmb__rule_group_compounding_type__c='Inclusive';
        //pg.csfam__standard_price_book__c = true;
        pg.csconta__frame_agreement__c=fam.Id;
        insert pg;

        cspmb__Pricing_Rule_Group_Rule_Association__c PriceRuleAssoc = new cspmb__Pricing_Rule_Group_Rule_Association__c();
        PriceRuleAssoc.cspmb__pricing_rule_group__c = pg.Id;
        PriceRuleAssoc.cspmb__pricing_rule__c = pr.Id;
        insert PriceRuleAssoc;
        
        cspmb__Price_Item__c priceItem = new cspmb__Price_Item__c();
        priceItem.name = 'Enterprise Mobility';
        priceItem.Commercial_Product_Code__c = 'DMCAT_Offer_001233_DMCAT_ProductSpecification_001196_DMCAT_RecurringCharge_001232_7790';
        priceItem.cspmb__Billing_Frequency__c = 'Monthly';
        priceItem.ProdSpecId__c = 'DMCAT_ProductSpecification_001196';
        priceItem.BillingSpecId__c = 'BSRC001_CB';
        priceItem.Offer_Id__c = 'DMCAT_Offer_001233';
        priceItem.Plan__c = 'Plan__c';
        priceItem.cspmb__Recurring_Charge__c = 45.45;
        priceItem.cspmb__Is_Recurring_Discount_Allowed__c = true;// Added for EDGE 184803 by team Amsterdam
        priceItem.ChargeType__c='RC';//EDGE-177929
        priceItem.Offer_Name__c='Adaptive Mobility';
        Insert priceItem;
        
       
	   
       /* List<cspmb__Add_On_Price_Item__c> piaddonlist = new List<cspmb__Add_On_Price_Item__c>();
        cspmb__Add_On_Price_Item__c piAddOn = new cspmb__Add_On_Price_Item__c();
        piAddOn.Name = 'AppleCare+ 2 years iPad 10.2 G8';
        piAddOn.cspmb__Add_On_Price_Item_Code__c = 'DMCAT_Offer_001233_DMCAT_ProductSpecification_001208_DMCAT_NonRecurringCharge_001216_8110';
        piAddOn.Offer_Id__c = 'DMCAT_Offer_001233';
        piAddOn.cspmb__Is_One_Off_Discount_Allowed__c = false;
        piAddOn.cspmb__Is_Recurring_Discount_Allowed__c = false;
        piAddOn.ProdSpecId__c='DMCAT_ProductSpecification_001208';        
        piaddonlist.add(piAddOn);
        //EDGE-177926 end        
        cspmb__Add_On_Price_Item__c piAddOn1 = new cspmb__Add_On_Price_Item__c();
        piAddOn1.Name = 'AppleCare+ 2 years iPad 10.2 G8_Test';
        piAddOn1.cspmb__Add_On_Price_Item_Code__c = 'DMCAT_Offer_001233_DMCAT_ProductSpecification_001208_DMCAT_NonRecurringCharge_001216_8110';
        piAddOn1.Offer_Id__c = 'DMCAT_Offer_001233';
        piAddOn1.cspmb__Is_One_Off_Discount_Allowed__c = false;
        piAddOn1.cspmb__Is_Recurring_Discount_Allowed__c = true;
        piAddOn1.ProdSpecId__c='DMCAT_ProductSpecification_001208';        
        piaddonlist.add(piAddOn1);
        if(!piaddonlist.isEmpty()){
            insert piaddonlist;
        }
        List<cspmb__Price_Item_Add_On_Price_Item_Association__c> piaddonassList = new List<cspmb__Price_Item_Add_On_Price_Item_Association__c>();
        cspmb__Price_Item_Add_On_Price_Item_Association__c piaddonasso = new cspmb__Price_Item_Add_On_Price_Item_Association__c();
        piaddonasso.cspmb__Price_Item__c = priceItem.Id;
        piaddonasso.cspmb__Add_On_Price_Item__c = piaddonlist[0].Id;
        piaddonasso.cspmb__One_Off_Charge__c = 90;
        piaddonasso.cspmb__Recurring_Charge__c=0.00;
        
        piaddonassList.add(piaddonasso); 
        
        cspmb__Price_Item_Add_On_Price_Item_Association__c piaddonasso1 = new cspmb__Price_Item_Add_On_Price_Item_Association__c();
        piaddonasso1.cspmb__Price_Item__c = priceItem2.Id;
        piaddonasso1.cspmb__Add_On_Price_Item__c = piaddonlist[1].Id;
        piaddonasso1.cspmb__One_Off_Charge__c = 0.00;
        piaddonasso1.cspmb__Recurring_Charge__c=50;
        piaddonassList.add(piaddonasso1);
        if(!piaddonassList.isEmpty()){
          insert  piaddonassList;   
        }
        */
        
        cspmb__Price_Item_Pricing_Rule_Association__c pipra=new cspmb__Price_Item_Pricing_Rule_Association__c();
        pipra.cspmb__association_type__c = 'Pricing change';
        pipra.cspmb__target_price__c = 'Sales';
        pipra.cspmb__recurring_adjustment_type__c='Price Override';
        pipra.cspmb__one_off_adjustment_type__c='Price Override';   
        pipra.cspmb__pricing_rule__c = pr.id;
        pipra.cspmb__price_item__c = priceItem.Id;
        pipra.cspmb__recurring_adjustment__c=10;
        insert pipra;
        
 
        
        Marketable_Offer__c mOffer = new Marketable_Offer__c();
        mOffer.Name = 'Adaptive Mobility';
        mOffer.Solution_Template__c = '';
        mOffer.Configurations__c = '{"skipBasketSyncValidations":false}';
        mOffer.Config__c = '{"skipBasketSyncValidations":false,"validateBillAccEnrich":true}';
        mOffer.Offer_ID__c = 'DMCAT_Offer_001233';
        insert mOffer;
        
     
        DPR_Offer__c dprOffer = new DPR_Offer__c();
        dprOffer.Name = 'Adaptive Mobility';
        dprOffer.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id;
        dprOffer.Marketable_Offer__c = mOffer.Id;
        dprOffer.ContractStartDate__c = System.now();
        dprOffer.ContractEndDate__c = DateTime.now().addMonths(24);
        insert dprOffer;
        
        
        
        Test.startTest();
            FAMActionHelper famh=new FAMActionHelper();
            String jsonVal ='{"method":"activateFrameAgreement","faId":"'+fam.Id+'"}'; 
            //famh.performAction(jsonVal);
            System.assertEquals('success',famh.performAction(jsonVal));
            FAM_PRGRA_Handler handler= new FAM_PRGRA_Handler();
            String response=handler.preparePricingGroupsPerProductFamily(fam.Id);
            System.assertEquals('Success',response);
        Test.stopTest();
        
       // Delegated_Pricing_Request__c prevDpr = [select id,Name,Deal_Status__c from Delegated_Pricing_Request__c where id =: insertDelegatedPricingRequest1.Id];
       // System.assertEquals('Draft',prevDpr.Deal_Status__c);
    }
    
    
}