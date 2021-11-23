@isTest(seeAllData=false)
public class PRMsendMailToPartnerSalesManagerJob_Test { 
    
    @testSetup
    
    static void setupTestData(){  
        
        User portalAccountOwner = SYS_TestDataFactory.createUser('System Administrator', 'Agribusiness');
        insert portalAccountOwner;
         
        Contact testContact;
        Account testEntAccount;
        System.runAs(portalAccountOwner){
            Account testAccount = SYS_TestDataFactory.createAccount('test', 'Partner');
            testAccount.OwnerId = portalAccountOwner.Id;
            insert testAccount;
            testContact = SYS_TestDataFactory.createContact(testAccount.Id, 'Partner Contact');
            testContact.Contact_Status__c = 'Active';
            testContact.Email = 'test@test.com';
            testContact.Onboarding_Status__c = opptyConstants.ONBOARDING_ACTIVE;
            testContact.Partner_Role__c = opptyConstants.PARTNER_SM;
            insert testContact;
            
            testEntAccount = SYS_TestDataFactory.createAccount('test', 'Enterprise');
            testEntAccount.Partner_Type__c='Distributed';
            testEntAccount.PartnerPrincipalContact__c = testContact.Id;
            testEntAccount.CIDN__c = '1234567890';
            
            Account testNewAccount = SYS_TestDataFactory.createPrincipalAccount('testNew', 'Partner', testContact.Id);
            testNewAccount.Partner_Type__c='Distributor';
            testNewAccount.CIDN__c = '1234567891';
            insert new List<Account>{testEntAccount, testNewAccount};
            
            List<Opportunity> testListOppty = SYS_TestDataFactory.createOpportunities(testAccount.Id,2);
            for(Opportunity testOpp:testListOppty){                
                testOpp.Associated_Distributor__c = testNewAccount.Id;
                testOpp.Distributor_Contact__c = portalAccountOwner.Id;
                testopp.SubmittoPartnerStatus__c = 'Submitted';
            }
            insert testListOppty;
        }
        
    }
    
    @isTest static void testPRMAutoTagging(){
        
        Map<String,Account> mapAccountCdnVsDetails = new Map<String,Account>();
        List<OpportunityShare> listOfOpptyShare = new List<OpportunityShare>();
        
        User testPortalUser;
        system.runAs(new User(Id = UserInfo.getUserId())){
            testPortalUser = SYS_TestDataFactory.createCommunityUser('TBTC Partner User', [SELECT Id FROM Contact LIMIT 1].Id);
            insert testPortalUser;
            
            testPortalUser.IsPrmSuperUser = true;
            update testPortalUser;
        }
        
        for(Opportunity opp : [SELECT Id FROM Opportunity]){
            listOfOpptyShare.add(SYS_TestDataFactory.createOpptyShare(opp.Id, testPortalUser.Id));
        }
        
        insert listOfOpptyShare;
        system.runAs(testPortalUser){
            
            Test.startTest();
            Set<String> oppIds = New Set<String> ();
            Map<String,String> opptyId_UserId = New Map<String,String> ();
            List<Opportunity> tstOpptyLst = [Select Id, OwnerId from Opportunity];
            for( Opportunity a : tstOpptyLst ){
                oppIds.add(a.id);
                opptyId_UserId.put(a.id,a.OwnerId);
            }
            
            System.enqueueJob(new PRMsendMailToPartnerSalesManagerJob(oppIds));
            C2O_OpportunityTriggerHelper.submitToDistributor(opptyId_UserId);
            Map<Id,Id> mapOppIdVsPartnerIdForOtmRemoval = new Map<Id,Id>();
            mapOppIdVsPartnerIdForOtmRemoval.put(tstOpptyLst[0].Id, tstOpptyLst[0].OwnerId);
            OpptyUtils.removeOpportunityTeamMember(mapOppIdVsPartnerIdForOtmRemoval); 
            Test.stopTest();
            
        }
    }
    
    @isTest static void testnullifyNonDistributor(){
        Test.startTest();
            List<Opportunity> tstOpptyLst = [Select Id from Opportunity];
            C2O_OpportunityTriggerHelper.updateSLAdateTo2days(tstOpptyLst);
            C2O_OpportunityTriggerHelper.updateBidnResMgmtReq(tstOpptyLst);
            C2O_OpportunityTriggerHelper.nullifyNonDistributerOppty(tstOpptyLst);
        Test.stopTest();
    }
    
    @isTest static void testNullifyDistributor(){
        Test.startTest();
            List<Opportunity> tstOpptyLst = [Select Id from Opportunity];
            C2O_OpportunityTriggerHelper.UpdateRetiedAccOpp(tstOpptyLst);
            C2O_OpportunityTriggerHelper.nullifyDistributerOppty(tstOpptyLst);
        Test.stopTest();
    }
    
    
}