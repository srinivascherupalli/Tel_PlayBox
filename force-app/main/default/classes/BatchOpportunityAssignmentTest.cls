@isTest
public class BatchOpportunityAssignmentTest {
    
    private static testMethod void testBatchOpportunityAssignment(){      
        Id p = [select id from profile where name='system Administrator'].id;
        // existing user creation removed & below line (TestUtil.createTestUser)added for creation because of 
        //FDR & Prod Test class failures because of DUPLICATE_USERNAME error during a deployment
        //So SFO Added blow usercreation method for unique username on date 02/09/2020 (Sprint 20.12)
        User u = TestUtil.createTestUser(null,p,'BatchOpportunity','AssignmentTest');
        insert u; 
        id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise').getRecordTypeId();
        Account acc = new Account();
        acc.name = 'TestClassEvent';
        acc.CIDN__c = 'ASDF1234';
        acc.RecordTypeId = accRecordTypeId;
        acc.Migrated_Customer__c = true;
        acc.Customer_status__c = 'ACTIVE';
        acc.Portfolio_Code__c = 'XYZ';
        Insert acc;
        Account objAcc1 = new Account();
        objAcc1.Name = 'Test3';
        objAcc1.Portfolio_Code__c = null;
        objAcc1.CIDN__c = '45325';
        objAcc1.Customer_Status__c='ACTIVE';
        objAcc1.TCM_MasterID__c = '45534534';
        objAcc1.OwnerId = u.Id;
        insert objAcc1;
        //id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Custom').getRecordTypeId();
        Opportunity opp=new Opportunity();
        opp.AccountId=acc.Id;
        //opp.recordTypeId=oppRecordTypeId;
        opp.Name='TestOppCreateForEventCreate';
        opp.Proposal_Required_Date__c=System.today()+2;
        opp.CloseDate=System.today()+10;
        opp.StageName='Develop';
        opp.Description__c='Test';
        opp.Product_Domain__c='MOBILES';
        opp.Shared_Opportunity__c=True;
        opp.ownerId = u.Id; 
        list<opportunity> lstopp = new list<opportunity>();
        lstopp.add(opp);
        insert lstopp;
        system.runas(u) {
            Id ModelId = [select Id from Territory2Model where State = 'Active' LIMIT 1].Id;
            Id TypeId = [select Id from Territory2Type where DeveloperName = 'Portfolio_Hierarchy' LIMIT 1].Id;
            Territory2 TestTerr2 = new Territory2(Name = 'XYZ', Territory2ModelId = ModelId, DeveloperName = 'XYZ', Territory2TypeId = TypeId);
            insert TestTerr2;
            UserTerritory2Association UserTerrAssoc = new UserTerritory2Association(UserId = u.Id, Territory2Id = TestTerr2.Id, RoleInTerritory2 = 'Owner');
            insert UserTerrAssoc;
            list<opportunity> updatelst = new list<opportunity>();
            for(Opportunity objOpp : lstOpp)
            {
                objOpp.OwnerId = u.Id;
                updatelst.add(objopp);
            }
            update updatelst;
        }
        Test.startTest();
        BatchOpportunityAssignment obj = new BatchOpportunityAssignment();
        database.executeBatch(obj);    
        Test.stopTest();
        system.assertEquals('Develop', opp.StageName);
    }
}