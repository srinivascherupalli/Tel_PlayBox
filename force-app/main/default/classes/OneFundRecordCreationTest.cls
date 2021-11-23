/*
* AUTHOR : Shivaprasad
* TEAM: Napier
* EDGE-205066 Advance fund payment frequency allocation
* DATE: 07/04/2021 
* Ankush Rana      08/06/2021  EDGE-219116 As a Sales/Partner user , When I have offered Fund (Flexi/Advance or No Fund) for a product during NEW FA journey, Then system should update Fund console data as "Allocated" on FA Activation
* Shivaprasad Patil  25/06/2021    EDGE-219475: Added field Fund Expiry (Fund Term)
*/

@istest
public class OneFundRecordCreationTest {

    static testMethod void createOneFundRecordAnnualInAdvanceTest() {
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
        
		//EDGE-219116 Changes started....
		
		Attachment attch = new Attachment();
        attch.body = Blob.valueOf('{"custom": {"fundConsoleData": [{"productFamily": "Adaptive Mobility","fundType": "Advance","fundIncrementFrequency": "Annual In Advance","contractTerm": "24","fundContribution": "0%","advanceFundAmount": "200.16","minimumSpendPerMonth": "100","totalSpentOverContractTerm": "58900.8","isAllocated": false}]},"products": {},"addons": {}}');
        attch.name = 'FrameAgreementAttachment';
        attch.ParentId = fam.Id;
        insert attch;
        
        Marketable_Offer__c mOffer1 = new Marketable_Offer__c();
        mOffer1.Offer_ID__c = 'DMCAT_Offer_000646';
        mOffer1.Invoice_Definition__c = 'Invoice_Def_2';
        mOffer1.Auto_Expired_Entity__c = true;
        mOffer1.Product_Family__c = 'Adaptive Mobility';
        insert mOffer1 ;
		//EDGE-219116 Changes ended....
		
        DPR_offer__c dpo=new  DPR_offer__c();
        dpo.Delegated_Pricing_Request__c=insertDelegatedPricingRequest.Id;
        dpo.Fund_Increment_Frequency__c = 'Annual In Advance';
        dpo.Fund_Amount__c = 9000;
    	dpo.PF_Contract_Term__c = 24;
		//EDGE-219116 starts....
		dpo.Marketable_Offer__c = mOffer1.id;
		//EDGE-219116 ends.....
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
    }
    
    static testMethod void createOneFundRecordAllInAdvanceTest() {
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
        dpo.Fund_Increment_Frequency__c = 'All In Advance';
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
    }
    
    static testMethod void createOneFundRecordFlexiTest() {
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
        insertDelegatedPricingRequest.Tech_Reward_Type__c = 'Flexi';
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
        dpo.Fund_Increment_Frequency__c = 'Monthly In Arrear';
        dpo.Fund_Amount__c = 9000;
    	dpo.PF_Contract_Term__c = 24;
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
        
    }
}