/*****************************************************************************************
* ModifiedBy     ModifiedDate     Edge          Description
* Manish Berad   18/02/2021       EDGE-201623   Auto creation of Deal opportunity for FA Revision on click of FA create new revision button on FA screen.
************************************************************************************************************************************************/
@isTest
public class CreateDealOppAndOppContactTest {
    
    static testMethod void updateFARevisionFieldsTest() {
        
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
        insert orpportunityDetailsRecord;
        Delegated_Pricing_Request__c insertDelegatedPricingRequest = new Delegated_Pricing_Request__c();
        insertDelegatedPricingRequest.Description__c = 'Test';
        insertDelegatedPricingRequest.Opportunity__c = orpportunityDetailsRecord.id;
        insertDelegatedPricingRequest.isPrimary__c = False;
        insertDelegatedPricingRequest.Mark_as_Variation__c = False;
        insertDelegatedPricingRequest.Parent_DPR__c = 'Test';
        insertDelegatedPricingRequest.Final_Delegation_Outcome__c = 'Sales Specialist';
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
        fam.csconta__Status__c = 'Draft';
        fam.Delegated_Pricing_Request__c=insertDelegatedPricingRequest.id;
        fam.Contract_Acceptance_Date__c=DateTime.now(); 
        fam.csconta__effective_end_date__c=DateTime.now().addMonths(1);
        fam.csconta__Account__c=a.Id;
        insert fam;
        
        DPR_offer__c dpo=new  DPR_offer__c();
        dpo.Delegated_Pricing_Request__c=insertDelegatedPricingRequest.Id;
        insert dpo;
        
        OpportunityTeamMember opp = new OpportunityTeamMember();
        Opp.UserId         = u.Id;
        Opp.OpportunityId  = orpportunityDetailsRecord.id;
        Opp.TeamMemberRole = 'Opportunity Team Member';
        insert opp;
        
        
        csconta__Frame_Agreement__c newFAM=new csconta__Frame_Agreement__c();
        newFAM.csconta__replaced_frame_agreement__c=fam.id;
        newFAM.Deal_Approver__c=u.Id;
        newFAM.csconta__Status__c = 'Draft';
        newFAM.Delegated_Pricing_Request__c=insertDelegatedPricingRequest.id;
        newFAM.Contract_Acceptance_Date__c=DateTime.now();
        insert newFAM;
        
        Test.startTest();
        FAMActionHelper famh=new FAMActionHelper();
        String jsonVal ='{"method":"createDealOppAndOppContactRol","faId":"'+newFAM.Id+'"}'; 
        famh.performAction(jsonVal);
        Test.stopTest();
        
        csconta__Frame_Agreement__c newFA=[Select Id,Opportunity__c From csconta__Frame_Agreement__c Where Id=:newFAM.Id limit 1];
        System.assert(newFA.Opportunity__c!=null);
        OpportunityContactRole primaryOpptyContactRole =[select id From OpportunityContactRole Where OpportunityId =:newFA.Opportunity__c AND IsPrimary=true limit 1];
        System.assert(primaryOpptyContactRole!=null);
    }
    
      
    static testMethod void ValidateOppContractTypeNotBSA() {
        
        Account parntAcc = new Account(Name = 'Test Account', Customer_Status__c = 'ACTIVE');
        insert parntAcc;
        Account relatedAcc = new Account(Name = 'Test Account', Customer_Status__c = 'ACTIVE');
        insert relatedAcc;
        
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(parntAcc);
        opp.name='Test Adaptive Opty';
        opp.RecordTypeId=[SELECT Name, Id, DeveloperName, SobjectType, IsActive FROM RecordType WHERE Name = 'Enterprise - Standard'].id;
        opp.Contract_Type__c='DSA';
        opp.amount = 4600;
        insert new List<Opportunity>{opp};
            
            list<Apttus__APTS_Agreement__c> Agglist= new list<Apttus__APTS_Agreement__c>();
        string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
        string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        Apttus__APTS_Agreement__c agreement1 = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=parntAcc.Id,name = 'TestPS', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated');
        insert agreement1;
        
        Delegated_Pricing_Request__c insertDpr = new Delegated_Pricing_Request__c();
        insertDpr.Description__c = 'Test';
        insertDpr.Opportunity__c = opp.id;
        insertDpr.isPrimary__c = true;
        insertDpr.Mark_as_Variation__c = False;
        insertDpr.Parent_DPR__c = 'Test';
        insertDpr.Final_Delegation_Outcome__c = 'Account Executive';
        insert insertDpr;
        
        csconta__Frame_Agreement__c famNew = new csconta__Frame_Agreement__c();
        famNew.Opportunity__c=opp.id;
        famNew.csconta__Status__c = 'Contract Synched';
        famNew.Delegated_Pricing_Request__c = insertDpr.Id;
        famNew.csconta__Account__c = parntAcc.Id;
        insert famNew;
        
        FA_Agreement_Association__c faAssociation = new FA_Agreement_Association__c(Agreement__c = agreement1.Id, FA__c = famNew.Id);
        insert faAssociation;
        
        Apttus__APTS_Agreement__c agreement2 = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=parntAcc.Id,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated', Apttus__Parent_Agreement__c =agreement1.Id);
        insert agreement2;
        
        csconta__Account_Frame_Agreement_Association__c accFAAssociation=new csconta__Account_Frame_Agreement_Association__c();
        accFAAssociation.csconta__Account__c=relatedAcc.Id;
        accFAAssociation.csconta__Frame_Agreement__c=famNew.Id;
        insert accFAAssociation;
        
        Test.startTest();
        string responce=CreateDealOppAndOppContact.ValidateInitiateContractAction(famNew.Id);
        Map<String,String> res=(Map<String,String>)System.JSON.deserialize(responce, Map<String,String>.class);
        //System.assertEquals(res.get('warning'),'true');
        Test.stopTest();
    }
    static testMethod void ValidateParentAccHasDSAAgreement() {
        
        Account parntAcc = new Account(Name = 'Test Account', Customer_Status__c = 'ACTIVE');
        insert parntAcc;
        Account relatedAcc = new Account(Name = 'Test Account', Customer_Status__c = 'ACTIVE');
        insert relatedAcc;
        
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(parntAcc);
        opp.name='Test Adaptive Opty';
        opp.RecordTypeId=[SELECT Name, Id, DeveloperName, SobjectType, IsActive FROM RecordType WHERE Name = 'Enterprise - Standard'].id;
        opp.Contract_Type__c='BSA';
        opp.amount = 4600;
        insert new List<Opportunity>{opp};
            
            string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
        string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        Apttus__APTS_Agreement__c agreement1 = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,APTPS_Validation_on_Fully_Signed__c=true,
                                                                             Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=parntAcc.Id,
                                                                             name = 'TestPS', Apttus__Agreement_Category__c = 'Digital Services',
                                                                             APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',
                                                                             Apttus__Status__c='Activated',Apttus__Source__c='Internal Digital');
        insert agreement1;
        
        Delegated_Pricing_Request__c insertDpr = new Delegated_Pricing_Request__c();
        insertDpr.Description__c = 'Test';
        insertDpr.Opportunity__c = opp.id;
        insertDpr.isPrimary__c = true;
        insertDpr.Mark_as_Variation__c = False;
        insertDpr.Parent_DPR__c = 'Test';
        insertDpr.Final_Delegation_Outcome__c = 'Account Executive';
        insert insertDpr;
        
        csconta__Frame_Agreement__c famNew = new csconta__Frame_Agreement__c();
        famNew.Opportunity__c=opp.id;
        famNew.csconta__Status__c = 'Contract Synched';
        famNew.Delegated_Pricing_Request__c = insertDpr.Id;
        famNew.csconta__Account__c = parntAcc.Id;
        insert famNew;
        
        FA_Agreement_Association__c faAssociation = new FA_Agreement_Association__c(Agreement__c = agreement1.Id, FA__c = famNew.Id);
        insert faAssociation;
        
        Apttus__APTS_Agreement__c agreement2 = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=parntAcc.Id,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated', Apttus__Parent_Agreement__c =agreement1.Id);
        insert agreement2;
        
        csconta__Account_Frame_Agreement_Association__c accFAAssociation=new csconta__Account_Frame_Agreement_Association__c();
        accFAAssociation.csconta__Account__c=relatedAcc.Id;
        accFAAssociation.csconta__Frame_Agreement__c=famNew.Id;
        insert accFAAssociation;
        
        Test.startTest();
        string responce=CreateDealOppAndOppContact.ValidateInitiateContractAction(famNew.Id);
        Map<String,String> res=(Map<String,String>)System.JSON.deserialize(responce, Map<String,String>.class);
       // System.assertEquals(res.get('warning'),'true');
        Test.stopTest();
    }
    
    static testMethod void ValidateRelatedAccHasDSAAgreement() {
        
        Account parntAcc = new Account(Name = 'Test Account', Customer_Status__c = 'ACTIVE');
        insert parntAcc;
        Account relatedAcc = new Account(Name = 'Test Account', Customer_Status__c = 'ACTIVE');
        insert relatedAcc;
        
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(parntAcc);
        opp.name='Test Adaptive Opty';
        opp.RecordTypeId=[SELECT Name, Id, DeveloperName, SobjectType, IsActive FROM RecordType WHERE Name = 'Enterprise - Standard'].id;
        opp.Contract_Type__c='BSA';
        opp.amount = 4600;
        insert new List<Opportunity>{opp};
            
          string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
        string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        Apttus__APTS_Agreement__c agreement1 = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,APTPS_Validation_on_Fully_Signed__c=true,
                                                                             Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=relatedAcc.Id,
                                                                             name = 'TestPS', Apttus__Agreement_Category__c = 'Digital Services',
                                                                             APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',
                                                                             Apttus__Status__c='Activated',Apttus__Source__c='Internal Digital');
        insert agreement1;
        
        Delegated_Pricing_Request__c insertDpr = new Delegated_Pricing_Request__c();
        insertDpr.Description__c = 'Test';
        insertDpr.Opportunity__c = opp.id;
        insertDpr.isPrimary__c = true;
        insertDpr.Mark_as_Variation__c = False;
        insertDpr.Parent_DPR__c = 'Test';
        insertDpr.Final_Delegation_Outcome__c = 'Account Executive';
        insert insertDpr;
        
        csconta__Frame_Agreement__c famNew = new csconta__Frame_Agreement__c();
        famNew.Opportunity__c=opp.id;
        famNew.csconta__Status__c = 'Contract Synched';
        famNew.Delegated_Pricing_Request__c = insertDpr.Id;
        famNew.csconta__Account__c = parntAcc.Id;
        insert famNew;
        
        FA_Agreement_Association__c faAssociation = new FA_Agreement_Association__c(Agreement__c = agreement1.Id, FA__c = famNew.Id);
        insert faAssociation;
        
        Apttus__APTS_Agreement__c agreement2 = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=parntAcc.Id,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated', Apttus__Parent_Agreement__c =agreement1.Id);
        insert agreement2;
        
        csconta__Account_Frame_Agreement_Association__c accFAAssociation=new csconta__Account_Frame_Agreement_Association__c();
        accFAAssociation.csconta__Account__c=relatedAcc.Id;
        accFAAssociation.csconta__Frame_Agreement__c=famNew.Id;
        insert accFAAssociation;
        
        Test.startTest();
        string responce=CreateDealOppAndOppContact.ValidateInitiateContractAction(famNew.Id);
        Map<String,String> res=(Map<String,String>)System.JSON.deserialize(responce, Map<String,String>.class);
      //   System.assertEquals(res.get('warning'),'success'); 
        Test.stopTest();
    }
    
}