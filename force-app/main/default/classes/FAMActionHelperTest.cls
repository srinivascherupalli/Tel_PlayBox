@isTest
private class FAMActionHelperTest {
    static testMethod void validateHelloWorld() {
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
        insertDelegatedPricingRequest.Final_Delegation_Outcome__c = 'Sales Specialist';
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
            Delegation_Role__c = 'Account Executive',//EDGE-186881
            LocaleSidKey = 'en_US'
            
        );
        insert u; 
        csconta__Frame_Agreement__c fam=new csconta__Frame_Agreement__c();
        fam.Opportunity__c=orpportunityDetailsRecord.id;
        fam.Deal_Approver__c=u.Id;
        fam.csconta__Status__c = 'Draft';
        fam.Delegated_Pricing_Request__c=insertDelegatedPricingRequest.id;
        fam.Contract_Acceptance_Date__c=DateTime.now(); //EDGE-186881
        fam.csconta__effective_start_date__c=System.today();//EDGE-205066
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
        Test.startTest();
        
        FAMActionHelper famh=new FAMActionHelper();
        famh.beforeActivationValidation(fam.Id);
        famh.activateFrameAgreement(fam.Id);
        famh.cancelFrameAgreement(fam.Id);
        famh.escalateFAM(fam.Id);
        famh.generateOpportunityTeamMember(fam.Id);
        famh.refreshDelegatedPricing(fam.Id);
        //famh.FetchPricingMethodandVerification(orpportunityDetailsRecord.id);
        
        String jsonVal ='{"method":"refreshDelegatedPricing","faId":"'+fam.Id+'"}' ; 
        famh.performAction(jsonVal);
        jsonVal ='{"method":"beforeActivationValidation","faId":"'+fam.Id+'"}' ; 
        famh.performAction(jsonVal);
        jsonVal ='{"method":"cancelFrameAgreement","faId":"'+fam.Id+'"}' ; 
        famh.performAction(jsonVal);
        jsonVal ='{"method":"getUserDetails"}' ; 
        famh.performAction(jsonVal);
        jsonVal ='{"method":"getQueueUsers"}' ; 
        famh.performAction(jsonVal);
        jsonVal ='{"method":"getDealApproverDetails","dealApproverId":"'+u.Id+'"}' ; 
        famh.performAction(jsonVal);
        jsonVal ='{"method":"generateOpportunityTeamMember","faId":"'+fam.Id+'"}' ; 
        famh.performAction(jsonVal);
        jsonVal ='{"method":"activateFrameAgreement","faId":"'+fam.Id+'"}' ; 
        famh.performAction(jsonVal);
        //jsonVal ='{"method":"FetchPricingMethodandVerification","OppId":"'+orpportunityDetailsRecord.Id+'"}' ; 
        famh.performAction(jsonVal);
        
        
        
        jsonVal ='{"method":"updateDPRtoDraft","faId":"'+fam.Id+'"}' ; 
        famh.performAction(jsonVal);


        jsonVal ='{"method":"quoteGeneration","faId":"'+fam.Id+'"}' ; 
        famh.performAction(jsonVal);


        //  string param='';
        //  famh.performAction(param);
        famh.getQueueUsers();
        famh.userDetails();
        
        famh.getDealApproverDetails(fam.Deal_Approver__c);
        
        Test.stopTest();
        List<csconta__Frame_Agreement__c> fam1 = [SELECT Id, csconta__Status__c  FROM csconta__Frame_Agreement__c ];
       // System.assertEquals('Quote',fam1[0].csconta__Status__c);
        
    }
    static testMethod void validatdprnull() {
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
        
        
        
        csconta__Frame_Agreement__c fam1=new csconta__Frame_Agreement__c();
        fam1.Opportunity__c=orpportunityDetailsRecord.id;
        fam1.csconta__Status__c = 'Draft';
        insert fam1;
        
        Test.startTest();
        
        
        FAMActionHelper famh1=new FAMActionHelper();
        
        famh1.refreshDelegatedPricing(fam1.Id);
        
        
        Test.stopTest();
        List<csconta__Frame_Agreement__c> famT = [SELECT Id, csconta__Status__c  FROM csconta__Frame_Agreement__c ];
        System.assertEquals('Draft',famT[0].csconta__Status__c);
        
    }
    static testMethod void validatdpr() {
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

        Insert priceItem;
        // EDGE-177926 test data
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
        piaddonasso1.cspmb__Price_Item__c = priceItem.Id;
        piaddonasso1.cspmb__Add_On_Price_Item__c = piaddonlist[1].Id;
        piaddonasso1.cspmb__One_Off_Charge__c = 0.00;
        piaddonasso1.cspmb__Recurring_Charge__c=50;
        piaddonassList.add(piaddonasso1);
        if(!piaddonassList.isEmpty()){
          insert  piaddonassList;   
        }
        
        Delegated_Pricing_Request__c insertDelegatedPricingRequest = new Delegated_Pricing_Request__c();
        insertDelegatedPricingRequest.Description__c = 'Test';
        insertDelegatedPricingRequest.Opportunity__c = orpportunityDetailsRecord.id;
        insertDelegatedPricingRequest.isPrimary__c = False;
        insertDelegatedPricingRequest.Mark_as_Variation__c = False;
        insertDelegatedPricingRequest.Parent_DPR__c = 'Test';
        //insertDelegatedPricingRequest.Total_Contract_Value__c=0;
        insert insertDelegatedPricingRequest;
        
        Marketable_Offer__c mOffer = new Marketable_Offer__c();
        mOffer.Name = 'Test Offer';
        mOffer.Solution_Template__c = '';
        mOffer.Configurations__c = '{"skipBasketSyncValidations":false}';
        mOffer.Config__c = '{"skipBasketSyncValidations":false,"validateBillAccEnrich":true}';
        mOffer.Offer_ID__c = 'DMCAT_Offer_001233';
        insert mOffer;
        
        DPR_Offer__c dprOffer = new DPR_Offer__c();
        dprOffer.Name = 'Test DPR';
        dprOffer.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id;
        dprOffer.Marketable_Offer__c = mOffer.Id;
        insert dprOffer;
        
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
        rca.External_Id__c='DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_8329_DMCAT_Offer_000618_DMCAT_ProductSpecification_00871_DMCAT_RecurringCharge_000814_8329_concurrencyLimit';
        rca.cspmb__Rate_Card__c=rc.Id;
        insert rca;
        
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
        fam1.Opportunity__c=orpportunityDetailsRecord.id;
        fam1.csconta__Status__c = 'Draft';
        fam1.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id;
        insert fam1;
        Attachment attch = new Attachment();
        //attch.body = Blob.valueOf('{"custom":{},"products":{"'+priceItem.Id+'":{"_volume":{"mv":null,"mvp":null,"muc":null,"mucp":null},"_product":{"recurring":16.18},"_allowances":{}},"a3u4Y00000034DVQAY":{"_volume":{"mv":null,"mvp":null,"muc":null,"mucp":null},"_product":{"recurring":35.45},"_allowances":{}}},"addons":{}}');
        //attch.body = Blob.valueOf('{"custom":{},"products":{"'+priceItem.Id+'":{"_volume":{"mv":null,"mvp":null,"muc":null,"mucp":null},"_addons": {"'+piaddonassList[0].Id+'":{"oneOff": 27.27,"recurring": null},"'+piaddonassList[1].Id+'":{"oneOff": null,"recurring": 40}},"_product":{"recurring":16.18},"_allowances":{}},"a3u4Y00000034DVQAY":{"_volume":{"mv":null,"mvp":null,"muc":null,"mucp":null},"_product":{"recurring":35.45},"_allowances":{}}},"addons":{}}');
        attch.body = Blob.valueOf('{"custom":{},"products":{"'+priceItem.Id+'":{"_volume":{"mv":null,"mvp":null,"muc":null,"mucp":null},"_addons": {"'+piaddonassList[0].Id+'":{"oneOff": 27.27,"recurring": null},"'+piaddonassList[1].Id+'":{"oneOff": null,"recurring": 40}},"_rateCards":{"'+rateCardLineList[0].cspmb__Rate_Card__c+'":{"'+rateCardLineList[0].id+'":'+rateCardLineList[0].cspmb__rate_value__c+',"'+rateCardLineList[1].id+'":'+rateCardLineList[1].cspmb__rate_value__c+'}}  ,"_product":{"recurring":16.18},"_allowances":{}},"a3u4Y00000034DVQAY":{"_volume":{"mv":null,"mvp":null,"muc":null,"mucp":null},"_product":{"recurring":35.45},"_allowances":{}}},"addons":{}}');
        attch.name = 'FrameAgreementAttachment';
        attch.ParentId = fam1.Id;
        insert attch;
        Test.startTest();
        
        
        FAMActionHelper famh1=new FAMActionHelper();
        
        famh1.refreshDelegatedPricing(fam1.Id);
        
        
        Test.stopTest();
        List<csconta__Frame_Agreement__c> fam = [SELECT Id,Delegated_Pricing_Request__c, csconta__Status__c  FROM csconta__Frame_Agreement__c ];
        System.assertEquals('Draft',fam[0].csconta__Status__c);
        List<DPR_Offer_Line_Item__c> lstOfDPR=[Select Id,Name,Offer_Type_Name__c,DPR_Offer_Line_Item_Type__c,Total_Recurring_Charge__c,Overridden_Unit_price__c From DPR_Offer_Line_Item__c Where Delegated_Pricing_Request__c =:fam[0].Delegated_Pricing_Request__c];
        if(lstOfDPR != null && !lstOfDPR.isEmpty())
        System.assert(lstOfDPR.size()>0);//EDGE-177929
        String addons;
        for(DPR_Offer_Line_Item__c oli:lstOfDPR){
            if(oli.DPR_Offer_Line_Item_Type__c=='Plan'){
                System.assertEquals(16.18,oli.Overridden_Unit_price__c);//EDGE-177929
            }
            if(oli.DPR_Offer_Line_Item_Type__c=='Addon'){
                addons = oli.DPR_Offer_Line_Item_Type__c;
            }
        }
        if(addons != null && addons != '')
        system.assertEquals(addons.contains('Addon'),true);// EDGE-177926
   }
    static testMethod void validatdpr1() {
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
        
        
        
        csconta__Frame_Agreement__c fam1=new csconta__Frame_Agreement__c();
        fam1.Opportunity__c=orpportunityDetailsRecord.id;
        fam1.csconta__Status__c = 'Draft';
        fam1.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id;
        insert fam1;
        
        Test.startTest();
        
        
        FAMActionHelper famh1=new FAMActionHelper();
        
        famh1.refreshDelegatedPricing(fam1.Id);
        
        
        Test.stopTest();
        List<csconta__Frame_Agreement__c> fam = [SELECT Id, csconta__Status__c,Deal_Approver__c  FROM csconta__Frame_Agreement__c ];
        System.assertEquals('Draft',fam[0].csconta__Status__c);
        System.assertEquals(null,fam[0].Deal_Approver__c);//DIGI-2608
    }    
    /*static testMethod void validateperformaction() {
        
        String jsonVal ='{"method":"refreshDelegatedPricing"}' ; 
        
        FAMActionHelper famh2=new FAMActionHelper();
        
        //famh2.performAction(jsonVal);
        List<csconta__Frame_Agreement__c> fam = [SELECT Id, csconta__Status__c  FROM csconta__Frame_Agreement__c ];
        System.assertEquals('Draft',fam[0].csconta__Status__c);
    }*/
    
    static testMethod void ValidateSyncContract() {
        Account acc1 = new Account(Name = 'Test Account', Customer_Status__c = 'ACTIVE');
        insert acc1;
        
        Opportunity oppRecord = new Opportunity();
        oppRecord.Product_Domain__c = 'FIXED TELEPHONY';
        oppRecord.RetiedAccOpp__c = True;
        oppRecord.Name = 'FIXED TELEPHONY';
        oppRecord.Description__c = 'FIXED TELEPHONY';
        oppRecord.Pricing_Method__c = 'Delegated Pricing';
        oppRecord.Product_Type__c = 'Modular';
        oppRecord.CloseDate = system.today();
        oppRecord.StageName = 'Open';
        oppRecord.AccountId = acc1.Id;
        //oppRecord.Billing_Solution__c ='Non Standard';    
        oppRecord.Type = 'Migration';
        oppRecord.BidStatus__c = 'Bid Approved';
        insert oppRecord;
        
        list<Apttus__APTS_Agreement__c> Agglist= new list<Apttus__APTS_Agreement__c>();
    string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
    string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        Apttus__APTS_Agreement__c agreement1 = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=acc1.Id,name = 'TestPS', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated');
        insert agreement1;
         cspmb__Price_Item__c priceItem1 = new cspmb__Price_Item__c();
        priceItem1.name = 'Enterprise Mobility';
        priceItem1.Commercial_Product_Code__c = 'DMCAT_Offer_001233_DMCAT_ProductSpecification_001196_DMCAT_RecurringCharge_001232_7790';
        priceItem1.cspmb__Billing_Frequency__c = 'Monthly';
        priceItem1.ProdSpecId__c = 'DMCAT_ProductSpecification_001196';
        priceItem1.BillingSpecId__c = 'BSRC001_CB';
        priceItem1.Offer_Id__c = 'DMCAT_Offer_001233';
        priceItem1.Plan__c = 'Plan__c';
        priceItem1.cspmb__Recurring_Charge__c = 45.45;
        priceItem1.cspmb__Is_Recurring_Discount_Allowed__c = true;// Added for EDGE 184803 by team Amsterdam

        priceItem1.ChargeType__c='RC';//EDGE-177929

        Insert priceItem1;
        
        List<cspmb__Price_Item_Add_On_Price_Item_Association__c> piAddOnList = new List<cspmb__Price_Item_Add_On_Price_Item_Association__c> ();
         cspmb__Price_Item_Add_On_Price_Item_Association__c piaddonasso2 = new cspmb__Price_Item_Add_On_Price_Item_Association__c();
        piaddonasso2.cspmb__Price_Item__c = priceItem1.Id;
        //piaddonasso2.cspmb__Add_On_Price_Item__c = piaddonlist[1].Id;
        piaddonasso2.cspmb__One_Off_Charge__c = 0.00;
        piaddonasso2.cspmb__Recurring_Charge__c=50;
        piAddOnList.add(piaddonasso2);
        if(!piAddOnList.isEmpty()){
          insert  piAddOnList;   
        }
    
    Delegated_Pricing_Request__c insertDpr = new Delegated_Pricing_Request__c();
        insertDpr.Description__c = 'Test';
        insertDpr.Opportunity__c = oppRecord.id;
        insertDpr.isPrimary__c = true;
        insertDpr.Mark_as_Variation__c = False;
        insertDpr.Parent_DPR__c = 'Test';
        insertDpr.Final_Delegation_Outcome__c = 'Account Executive';
        insert insertDpr;
        
        csconta__Frame_Agreement__c famNew = new csconta__Frame_Agreement__c();
        famNew.Opportunity__c=oppRecord.id;
        famNew.csconta__Status__c = 'Contract Synched';
        famNew.Delegated_Pricing_Request__c = insertDpr.Id;
        famNew.csconta__Account__c = acc1.Id;
        insert famNew;
        
        FA_Agreement_Association__c faAssociation = new FA_Agreement_Association__c(Agreement__c = agreement1.Id, FA__c = famNew.Id);
    insert faAssociation;
        
        Apttus__APTS_Agreement__c agreement2 = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=acc1.Id,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated', Apttus__Parent_Agreement__c =agreement1.Id);
        insert agreement2;
        Marketable_Offer__c marketOffer = new Marketable_Offer__c();
        marketOffer.Name = 'Test Offer';
        marketOffer.Product_Family__c = 'Adaptive Mobility';
        marketOffer.Solution_Template__c = '';
        marketOffer.Configurations__c = '{"skipBasketSyncValidations":false}';
        marketOffer.Config__c = '{"skipBasketSyncValidations":false,"validateBillAccEnrich":true}';
        marketOffer.Offer_ID__c = 'DMCAT_Offer_001233';
        set<String> mrktName = new set<String> ();
        mrktName.add(marketOffer.Product_Family__c);
        insert marketOffer;
        
        User userRecord = new User(
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
            Delegation_Role__c = 'Migration',//EDGE-185053
            LocaleSidKey = 'en_US'
            
        );
        
        insert userRecord;
        
         DPR_Offer__c newdprOffer = new DPR_Offer__c();
        newdprOffer.Name = 'Adaptive Mobility';
        newdprOffer.Delegated_Pricing_Request__c = insertDpr.Id;
        newdprOffer.Marketable_Offer__c = marketOffer.Id;
        newdprOffer.PF_Contract_Term__c = 3000;
        insert newdprOffer;
        
        DPR_Offer_Line_Item__c dprOffLineItem = new DPR_Offer_Line_Item__c();
        dprOffLineItem.Offer_Type__c = priceItem1.Id;
        dprOffLineItem.Offer_Type_Name__c = 'Mobile Broadband';
        dprOffLineItem.DPR_Offer__c = newdprOffer.Id;
        dprOffLineItem.Marketable_Offer__c = marketOffer.Id;
        dprOffLineItem.cspmb_Price_Item__c = priceItem1.Id;
        dprOffLineItem.Delegated_Pricing_Request__c = insertDpr.Id;
        dprOffLineItem.DPR_Offer_Line_Item_Type__c = 'plan';
        dprOffLineItem.isNegotiableCharge__c = true;
        dprOffLineItem.Overridden_Total_Price__c = 200;
        dprOffLineItem.Quantity__c = 10;
        List<DPR_Offer_Line_Item__c> dprOli = new List<DPR_Offer_Line_Item__c>(); 
        dprOli.add(dprOffLineItem);
        Insert dprOffLineItem; 
        
        list<Product2> prodlst =new list<Product2>();
        Product2 prod=new Product2();
        prod.Name='Adaptive Mobility';
        
        Product2 prod1=new Product2();
        prod1.Name='Adaptive Mobility1';
        prodlst.add(prod);
        prodlst.add(prod1);
        insert prodlst;
        
        Apttus__AgreementLineItem__c lineitem = new Apttus__AgreementLineItem__c();
        lineitem.Apttus__AgreementId__c = agreement2.id;
        lineitem.Apttus__ProductId__c= prod.id;
        insert lineitem;
        
        String ProdName = 'Adaptive Mobility';
        set<String> prodString = new Set<String> ();
        prodString.add(ProdName);
        String existingDsa = FAMActionHelper.fetchExistingDSA(acc1.Id);
        Test.startTest();
        FAMActionHelper famHelper = new FAMActionHelper();
        famHelper.CustomContractSync(famNew.Id);
        famHelper.updateDPRtoDraft(famNew.Id);
        
        FAMActionHelper.createAgreementLineItem(agreement2.Id, dprOli, mrktName);
        String fetchProd = FAMActionHelper.fetchProductIds(mrktName);
        FAMActionHelper.createFaAssociationRecord(existingDsa, famNew.Id);
        famHelper.updateDPRtoScored(famNew.Id);
        FAMActionHelper.updateFA(famNew.Id);
        Test.stopTest();
        List<csconta__Frame_Agreement__c> fam = [SELECT Id, csconta__Status__c FROM csconta__Frame_Agreement__c ];
        System.assertEquals(fam.size() > 0,true);
        
    }
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
        dpo.PF_Contract_Term__c = 24;
        dpo.Fund_Term__c = 12;
        insert dpo;
        
        OpportunityTeamMember opp = new OpportunityTeamMember();
        Opp.UserId         = u.Id;
        Opp.OpportunityId  = orpportunityDetailsRecord.id;
        Opp.TeamMemberRole = 'Opportunity Team Member';
        insert opp; 
            
        
        Test.startTest();
        FAMActionHelper famh=new FAMActionHelper();
        String jsonVal ='{"method":"activateFrameAgreement","faId":"'+fam.Id+'"}'; 
        //famh.performAction(jsonVal);
        System.assertEquals('success',famh.performAction(jsonVal));
        Test.stopTest();
        // Delegated_Pricing_Request__c prevDpr = [select id,Name,Deal_Status__c from Delegated_Pricing_Request__c where id =: insertDelegatedPricingRequest1.Id];
       // System.assertEquals('Draft',prevDpr.Deal_Status__c);
    }
  
}