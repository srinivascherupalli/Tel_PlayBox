@IsTest
public class C2O_OpportunityTriggerHandlerTest {
    @testSetup
    static void setupTestData() {
        User portalAccountOwner = SYS_TestDataFactory.createUser('Sales-Enterprise-Unified', 'Agribusiness');
        insert portalAccountOwner;
        
        Contact testContact;
        
        System.runAs(portalAccountOwner){
            Account testAccount = SYS_TestDataFactory.createAccount('test', 'Partner');
            testAccount.Imported__c = true;
            testAccount.Partner_Type__c = 'Distributor';
            testAccount.OwnerId = portalAccountOwner.Id;
            insert testAccount;
            
            Account testAccountDistributor = SYS_TestDataFactory.createAccount('testDist1', 'Partner');
            testAccountDistributor.Imported__c = true;
            testAccountDistributor.Partner_Type__c = 'Distributor';
            testAccountDistributor.OwnerId = portalAccountOwner.Id;
            insert testAccountDistributor;
            
            testContact = SYS_TestDataFactory.createContact(testAccount.Id, 'Partner Contact');
            testContact.Contact_Status__c = 'Active';
            testContact.Email = 'c2o_opportunitytrigger@test.com';
            testContact.Onboarding_Status__c = opptyConstants.ONBOARDING_ACTIVE;
            testContact.Partner_Role__c = opptyConstants.PARTNER_SM;
            insert testContact;
            
            Account testNewAccount = SYS_TestDataFactory.createPrincipalAccount('testNew', 'Partner', testContact.Id);
            // testNewAccount.Customer_Status__c='RETIRED';
            insert testNewAccount;
            
            Opportunity opp1 = SYS_TestDataFactory.createOpportunity(testNewAccount.Id);
            Opportunity opp2 = SYS_TestDataFactory.createOpportunity(testNewAccount.Id);
            Opportunity opp3 = SYS_TestDataFactory.createOpportunity(testNewAccount.Id);
            Opportunity opp4 = SYS_TestDataFactory.createOpportunity(testNewAccount.Id);
            Opportunity opp5 = SYS_TestDataFactory.createOpportunity(testNewAccount.Id);
            insert new List<Opportunity>{opp1, opp2, opp3, opp4, opp5};
        }
        
        User testPortalUser = SYS_TestDataFactory.createCommunityUser('TBTC Partner User',testContact.Id);
        insert testPortalUser;
        
        testPortalUser.IsPrmSuperUser = true;
        update testPortalUser;
        
    }
    
    @isTest static void testOpptyBeforeInsert(){
        Map<String,Account> mapAccountCdnVsDetails = new Map<String,Account>();
        List<AccountShare> listOfAccountShare = new List<AccountShare>();
        //Contact con = [SELECT Id FROM Contact WHERE Email = 'c2o_opportunitytrigger@test.com']; //DN: SOQL101 in B2BCI
        List<User> testUser = [SELECT Id, Email, Profile.Name, Contact.Email FROM User WHERE Profile.Name = 'TBTC Partner User' AND Contact.Email = 'c2o_opportunitytrigger@test.com']; //DN: added AND Contact.Email filter
        
        
        for(Account acc : [SELECT Id,cidn__c FROM Account]){
            acc.isPartner = true;
            acc.Partner_Type__c = 'Distributor';
            mapAccountCdnVsDetails.put(acc.cidn__c, acc);
            listOfAccountShare.add(SYS_TestDataFactory.createAccountShare(acc.Id, testUser[0].Id));
        }
        update mapAccountCdnVsDetails.values();
        insert listOfAccountShare;
        String entCustomRecordTypeId = [select id from recordtype where sobjecttype='Opportunity' and DeveloperName ='Custom'].Id;
        
        /** SARV **/
        Account[] accs = [SELECT Id,cidn__c FROM Account];
        Contact testContact2 = New Contact ();
        testContact2 = SYS_TestDataFactory.createContact(accs[0].Id, 'Partner Contact');
        testContact2.lastName = 'testContact2'+System.now();
        testContact2.Contact_Status__c = 'Active';
        testContact2.Email = 'test2@test.com';
        testContact2.Onboarding_Status__c = opptyConstants.ONBOARDING_ACTIVE;
        testContact2.Partner_Role__c = opptyConstants.PARTNER_SM;
        insert testContact2;
        
        
        Opportunity opp;
        system.runAs(testUser[0]){
            Test.startTest();
            String accountId = mapAccountCdnVsDetails.get('test')?.Id;
            opp = SYS_TestDataFactory.createPrincipalOpportunity(accountId, accountId);
            opp.Partner__c = testUser[0].Id;
            opp.DCHOwner__c = UserInfo.getUserId();
            opp.recordtypeId = entCustomRecordTypeId;
            opp.StageName = 'Define';
            opp.RetiedAccOpp__c = true;
            opp.Opportunity_Source__c = opptyConstants.PARTNER ;
            opp.Amount = 10000000;
            opp.Customer_Contact_Email__c = 'test@test.com';
            opp.LeadSource = opptyConstants.CAMPAIGN ;
            opp.Proposal_Required_Date__c = DateTime.now();
            opp.Billing_Solution__c = 'Standard';
            insert opp;
            
            opp.Customer_Contact_Email__c = 'test@test.com';
            opp.LeadSource = opptyConstants.CAMPAIGN;
            opp.Contract_Type__c = 'Subcontract';
            
            
            opp.SubmittoPartnerStatus__c = 'Rejected';
            opp.Customer_Contact_Email__c = 'test2@test.com';
            opp.Distributor_Contact__c = testUser[0].Id;
            opp.Partner__c = testUser[0].Id;
            
            System.Debug('UserInfo ==>  ' + opp?.DCHOwner__r  );
            System.Debug('UserInfo ==>  ' + opp?.DCHOwner__r?.Contact  );
            System.Debug('UserInfo ==>  ' + opp?.DCHOwner__r?.Contact?.Account  );
            System.Debug('UserInfo ==>  ' + opp?.DCHOwner__r?.Contact?.Account.Partner_Type__c   );
            System.Debug('UserInfo ==>  ' + opp   );
            
            
            update opp;
            

            opp.DCHOwner__c = testUser[0].Id;
            opp.RetiedAccOpp__c = true ;
            opp.Customer_Contact_Email__c = '';
            
   //         update opp;
            
                        
            Test.stopTest();
            
            
        }
    }
    
    
    @isTest static void testOpptyAfterUpdate(){
        Test.startTest();
        List<User> testUser = [SELECT Id FROM User WHERE Profile.Name = 'TBTC Partner User'];
        List<Opportunity> opplist = [Select id,accountid,Customer_Contact_Email__c,RetiedAccOpp__c from Opportunity]; //OB
        Account DistrAcc = [Select id from Account where cidn__c ='testDist1' limit 1];
        User prmus1 = [Select Id,contactid from User where contactId!=''][0];
        opplist[0].OwnerId = prmus1.Id;
        opplist[1].Submit_for_Closure_Status__c = opptyConstants.SUBMITTED;
        opplist[2].Submit_for_Closure_Status__c = opptyConstants.APPROVED;
        opplist[3].Submit_for_Closure_Status__c = opptyConstants.REJECTED;
        
        opplist[4].Associated_Distributor__c = DistrAcc.Id;
        opplist[4].Distributor_Contact__c = prmus1.Id;
        opplist[4].SubmittoPartnerStatus__c = opptyConstants.SUBMITTED;
        opplist[4].isInApprovalProcess__c = false;
        opplist[4].Distributor_Contact__c = testUser[0].Id; 
        opplist[4].Partner__c = testUser[0].Id;
            
        Update opplist;
        
        C2O_OpportunityTriggerHelper.updateSLAdateTo2days(opplist);
        
        Set<Id> oppIdList = new Set<Id>{opplist[0].Id};

        C2O_OpportunityTriggerHelper.updateRevenue(oppIdList);
        
        C2O_OpportunityTriggerHelper.sentPartnerVerificationEmail(oppIdList);
        C2O_OpportunityTriggerHelper.createOpportunityContactRole(opplist);
        C2O_OpportunityTriggerHelper.CreateOpptyContactRole coConRole = new C2O_OpportunityTriggerHelper.CreateOpptyContactRole(opplist);
        System.enqueueJob(coConRole);
        C2O_OpportunityTriggerHelper.PartnerOpportunityVerificationEmail partnerVerificationEmail = 
                                            new C2O_OpportunityTriggerHelper.PartnerOpportunityVerificationEmail(oppIdList,'Partner_Opportunity_Verification_Required');
        System.enqueueJob(partnerVerificationEmail);
        C2O_OpportunityTriggerHelper.nullifyDistributerOppty(opplist);
        C2O_OpportunityTriggerHelper.nullifyNonDistributerOppty(opplist);

        Test.stopTest();
    }

    @isTest static void testsubmitToPartner(){
        Test.startTest();
        List<User> testUser = [SELECT Id FROM User WHERE Profile.Name = 'TBTC Partner User'];
        List<Opportunity> opplist = [Select id,accountid,Customer_Contact_Email__c,RetiedAccOpp__c from Opportunity]; //OB
        Account DistrAcc = [Select id from Account where cidn__c ='testDist1' limit 1];
        User prmus1 = [Select Id,contactid from User where contactId!=''][0];
        opplist[0].OwnerId = prmus1.Id;
        opplist[1].Submit_for_Closure_Status__c = opptyConstants.SUBMITTED;
        opplist[2].Submit_for_Closure_Status__c = opptyConstants.APPROVED;
        opplist[3].Submit_for_Closure_Status__c = opptyConstants.REJECTED;
        
        opplist[4].Associated_Distributor__c = DistrAcc.Id;
        opplist[4].Distributor_Contact__c = prmus1.Id;
        opplist[4].SubmittoPartnerStatus__c = opptyConstants.SUBMITTED;
        opplist[4].isInApprovalProcess__c = false;
        opplist[4].Distributor_Contact__c = testUser[0].Id; 
        opplist[4].Partner__c = testUser[0].Id;
            
        Update opplist;      
        Map<String,String> opptyId_UserId = New Map<String,String> ();
        for( Opportunity a : [Select Id, OwnerId from Opportunity where SubmittoPartnerStatus__c =: opptyConstants.SUBMITTED]){
            opptyId_UserId.put(a.id,a.OwnerId);
        }      
        C2O_OpportunityTriggerHelper.submitToPartner(opptyId_UserId);
        Test.stopTest();
    }
    
    
}