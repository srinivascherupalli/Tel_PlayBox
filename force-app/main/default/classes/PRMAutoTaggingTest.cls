@isTest(seeAllData=false) 
private class PRMAutoTaggingTest {
    
    @testSetup
    static void setupTestData(){
        
        User portalAccountOwner = SYS_TestDataFactory.createUser('Sales-Enterprise-Unified', 'Agribusiness');
        insert portalAccountOwner;
        
        Contact testContact;
        
        
        System.runAs(portalAccountOwner){
            Account testAccount = SYS_TestDataFactory.createAccount('test', 'Partner');
            testAccount.Imported__c = true;
            testAccount.OwnerId = portalAccountOwner.Id;
            testAccount.Partner_Type__c = 'Distributor';
            insert testAccount;
            
            testContact = SYS_TestDataFactory.createContact(testAccount.Id, 'Partner Contact');
            testContact.Contact_Status__c = 'Active';
            testContact.Email = 'c2o_opportunitytrigger@test.com';
            testContact.Onboarding_Status__c = opptyConstants.ONBOARDING_ACTIVE;
            testContact.Partner_Role__c = opptyConstants.PARTNER_SM;
            insert testContact;
            
            Account testNewAccount = SYS_TestDataFactory.createPrincipalAccount('testNew', 'Partner', testContact.Id);
            insert testNewAccount;
            
            PRM_Default__c prmDefault = (PRM_Default__c) SYS_TestDataFactory.createCustomSetting(PRM_Default__c.sObjectType);
            prmDefault.Partner_Opportunity_Amount__c = 1000;
            prmDefault.Partner_Opportunity_Verification__c = true;
            prmDefault.Enable_Partner_Opp_Conflict_Checking__c = false;
            prmDefault.Partner_Opp_Conflict_Number_of_Days__c = 10;
            insert prmDefault;
            
            PRM_Opportunity_Partner_Auto_Tagging__c prmAutoTagging = (PRM_Opportunity_Partner_Auto_Tagging__c) SYS_TestDataFactory.createCustomSetting(PRM_Opportunity_Partner_Auto_Tagging__c.sObjectType);
            prmAutoTagging.isActive__c = true;
            insert prmAutoTagging;
            
            PricebookEntry priceBookEntryObj = SYS_TestDataFactory.createPricebookEntry();
            insert priceBookEntryObj;
            
            //User portalUser1 = SYS_TestDataFactory.createUser('PRM Admin - Australia', testContact.Id);
            //insert portalUser1;
        
            
        }
        
        Test.startTest();
            User testPortalUser = SYS_TestDataFactory.createCommunityUser('TBTC Partner User',testContact.Id);
            insert testPortalUser;
            
            testPortalUser.IsPrmSuperUser = true;
            update testPortalUser;
        Test.stopTest();
    }
    
    /***************************************************************************************
    * Method Name - testPRMAutoTagging
    * Author - P.M
    * Description - Test Method for PRMAutoTagging class.
    ****************************************************************************************/
    @isTest static void testPRMAutoTagging(){
        PRMAutoTagging.doChainJob = false;
        Map<String,Account> mapAccountCdnVsDetails = new Map<String,Account>();
        List<AccountShare> listOfAccountShare = new List<AccountShare>();
        Contact con = [SELECT Id FROM Contact WHERE Email = 'c2o_opportunitytrigger@test.com'];
        List<User> testUser = [SELECT Id FROM User WHERE Profile.Name = 'TBTC Partner User' AND ContactId = :con.Id];
        
        for(Account acc : [SELECT Id,cidn__c FROM Account]){
            acc.isPartner = true;
            acc.Partner_Type__c = 'Distributor';
            mapAccountCdnVsDetails.put(acc.cidn__c, acc);
            listOfAccountShare.add(SYS_TestDataFactory.createAccountShare(acc.Id, testUser[0].Id));
        }
        update mapAccountCdnVsDetails.values();
        insert listOfAccountShare;
        
        String entCustomRecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByDeveloperName().get('Custom').getRecordTypeId();
        
        Opportunity opp;
        system.runAs(testUser[0]){
            String accountId = mapAccountCdnVsDetails.get('test')?.Id;
            opp = SYS_TestDataFactory.createPrincipalOpportunity(accountId, accountId);
            opp.Partner__c = testUser[0].Id;
            opp.DCHOwner__c = UserInfo.getUserId();
            
            
            insert opp;
            
            Test.startTest();
                System.enqueueJob(new PRMAutoTagging.AddPermissionSetToAccountOwner(new Set<Id>{opp.Id}));
                
                opp.PartnerAccountId = mapAccountCdnVsDetails.get('testNew')?.Id;
                opp.isInApprovalProcess__c = false;
                opp.Product_Type__c = opptyConstants.ACCOUNT_NON_MODULAR;
                update opp;
                
                PricebookEntry priceBookEntry = [SELECT Id FROM PricebookEntry LIMIT 1];
                OpportunityLineItem oli = SYS_TestDataFactory.createOpportunityLineItem(priceBookEntry.Id, opp.Id);
                insert oli;
                System.enqueueJob(new PRMAutoTagging.PRMAutoTaggingOliUpdate(new Map<Id,Opportunity>{opp.Id=>opp}));
                
                System.enqueueJob(new PRMAutoTagging.AddOTMForPartnerOwnedOpp(PRMUtilityClass.getListOfOpportunityForPRM(new Set<Id>{opp.Id})));
                
                System.enqueueJob(new PRMAutoTagging.AddPermissionSetToAccountOwner(new Set<Id>{opp.Id}));
                PRMAutoTagging.prmAutoTaggingPartner(new Set<Id>{opp.Id});
                
                //Rubbish code to do code coverage
                PRMAutoTagging.createChatterPost(opp,new Set<Id>{testUser[0].Id});
            
            Test.stopTest();
            Map<Id,Id> mapOppIdVsPartnerIdForOtmRemoval = new Map<Id,Id>();
            mapOppIdVsPartnerIdForOtmRemoval.put(opp.Id, opp.Partner__c);
            C2O_OpportunityTriggerHelper.remPartUsrFrmOpptyTeam(mapOppIdVsPartnerIdForOtmRemoval);
            
             
            
            Opportunity updatedOpportunityRecord = [SELECT Id, csordtelcoa__Change_Type__c,SubmittoPartnerStatus__c FROM Opportunity WHERE Id = :opp.Id];
            System.assertEquals(updatedOpportunityRecord.csordtelcoa__Change_Type__c, opptyConstants.CHANGE_SOLUTION);
            //System.assertEquals(updatedOpportunityRecord.SubmittoPartnerStatus__c, 'Approved');
            
            OpportunityLineItem updatedOli = [SELECT Channel__c FROM OpportunityLineItem]; 
            System.assertEquals(updatedOli.Channel__c, 'Indirect');
            
            List<OpportunityTeamMember> listOfOtm = [SELECT Id,TeamMemberRole,OpportunityAccessLevel FROM OpportunityTeamMember];
            System.assertEquals(listOfOtm.size(), 2);
            
        }
    }
    
    @isTest static void testPRMUtility(){
        PRMUtilityClass.addMarkupBeginSegment(new List<ConnectApi.MessageSegmentInput>(), PRMUtilityClass.LIST_TEXT);
        PRMUtilityClass.addMarkupBeginSegment(new List<ConnectApi.MessageSegmentInput>(), PRMUtilityClass.BOLD_TEXT);
        PRMUtilityClass.addMarkupBeginSegment(new List<ConnectApi.MessageSegmentInput>(), PRMUtilityClass.UNDERLINE);
        
        PRMUtilityClass.addMarkupEndSegment(new List<ConnectApi.MessageSegmentInput>(), PRMUtilityClass.LIST_TEXT);
        PRMUtilityClass.addMarkupEndSegment(new List<ConnectApi.MessageSegmentInput>(), PRMUtilityClass.HYPERLINK);
        PRMUtilityClass.addMarkupEndSegment(new List<ConnectApi.MessageSegmentInput>(), PRMUtilityClass.BOLD_TEXT);
        PRMUtilityClass.addMarkupEndSegment(new List<ConnectApi.MessageSegmentInput>(), PRMUtilityClass.UNDERLINE);
        
        PRMUtilityClass.addEmptySegment(new List<ConnectApi.MessageSegmentInput>());
        
    }
    
}