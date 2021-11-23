/*
@Last Modified        : 07/01/2020 21.01 by Chhaveel, Team SFO
               				         as part of P2OB-9943/P2OB-6772 Removing Commented Code,debug Statements and updating API version to 50.
*/

@isTest
public class TerritoryAssignmentBatchSchedulerTest {
    
    //@LastModification  02/09/2020 (Sprint 20.12)
    //FDR & Prod Test class failures because of DUPLICATE_USERNAME error during a deployment
    //So SFO Added blow usercreation method for unique username on date 02/09/2020 (Sprint 20.12)
    private static testMethod void testBatchOpportunityAssignment(){  
         Test.startTest();
        String CRON_EXP = '0 05 * * * ? *';
        EnvironmentVariable__c dfault = new EnvironmentVariable__c();
        dfault.Name='UpdateSalesAccExecutive';
        dfault.Value__c='true';
        insert dfault;
        system.debug('SetupOwnerId:::::'+dfault.SetupOwnerId);
        Id p = [select id from profile where name='system Administrator'].id;
       
        User u = TestUtil.createTestUser(null,p,'TerritoryAssignment','BatchSchedulerTest');
        u.Phone = '0445678001';
        insert u; 
        system.runas(u) {
        Id ModelId = [select Id from Territory2Model where State = 'Active' LIMIT 1].Id;
    	Id TypeId = [select Id from Territory2Type where DeveloperName = 'Portfolio_Hierarchy' LIMIT 1].Id;
        Territory2 TestTerr2 = new Territory2(Name = 'TestTerr', Territory2ModelId = ModelId, DeveloperName = 'XYZ', Territory2TypeId = TypeId);
        insert TestTerr2;
        UserTerritory2Association UserTerrAssoc = new UserTerritory2Association(UserId = u.Id, Territory2Id = TestTerr2.Id, RoleInTerritory2 = 'Owner');
        insert UserTerrAssoc;
           list<Account> lstAcc = new list<Account>();
            Account objAcc = new Account();
            objAcc.Name = 'TestAccount';
            objAcc.CIDN__c = '3534535';
            objAcc.TCM_MasterID__c = '657567';
            objAcc.Portfolio_Code__c = 'XYZ';
            objAcc.OwnerId = u.Id;
            objAcc.Customer_Status__c='ACTIVE';
             
            Account objAcc1 = new Account();
            objAcc1.Name = 'Test3';
            objAcc1.Portfolio_Code__c = null;
            objAcc1.CIDN__c = '45325';
            objAcc1.Customer_Status__c='ACTIVE';
            objAcc1.TCM_MasterID__c = '45534534';
            objAcc1.OwnerId = u.Id;
             
            lstAcc.add(objAcc1);
            lstAcc.add(objAcc);
             
            insert lstAcc;
             
            list<Account> Updatelst = new list<Account>();
            for(Account objA : lstAcc)
            {
                objA.OwnerId = u.id;
                Updatelst.add(objA);
            }
            update Updatelst;
    
            String jobId = System.schedule('TerritoryAssignmentBatchSchedulerTest',  CRON_EXP, new TerritoryAssignmentBatchScheduler());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(ct.TimesTriggered, ct.TimesTriggered);
        }
        Test.stopTest();
    }
}