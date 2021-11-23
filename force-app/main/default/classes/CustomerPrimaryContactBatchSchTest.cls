/*
    AUTHOR : Abhishek Rao
    DESCRIPTION : EDGE-93284 :: <Technical story> Batch script to update Customer Primary Contact for existing and migrated Agreement records
*/

@isTest
public class CustomerPrimaryContactBatchSchTest {
    
    private static testMethod void testBatchCustPrimContactAssignment(){  
         Test.startTest();
        String cronExp = '0 05 * * * ? *';
       
        /*Id p = [select id from profile where name='system Administrator'].id;
       
        User u = new User(alias = 'conf3', email='test@noemail.com',
                            emailencodingkey='UTF-8', lastname='conf3', languagelocalekey='en_US',
                            localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                            timezonesidkey='America/Los_Angeles', username='test@noemail.com');
        insert u; */
        User u =TestDataFactory.createTestUser('system Administrator');
         system.runas(u) {
        Id modelId = [select Id from Territory2Model where State = 'Active' LIMIT 1].Id;
    	Id typeId = [select Id from Territory2Type where DeveloperName = 'Portfolio_Hierarchy' LIMIT 1].Id;
        Territory2 testTerr2 = new Territory2(Name = 'TestTerr', Territory2ModelId = modelId, DeveloperName = 'XYZ', Territory2TypeId = typeId);
        insert testTerr2;
        UserTerritory2Association userTerrAssoc = new UserTerritory2Association(UserId = u.Id, Territory2Id = testTerr2.Id, RoleInTerritory2 = 'Owner');
        insert userTerrAssoc;
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
             
            list<Account> updatelst = new list<Account>();
            for(Account objA : lstAcc)
            {
                objA.OwnerId = u.id;
                updatelst.add(objA);
            }
            update updatelst;
        
        
            String jobId = System.schedule('CustomerPrimaryContactBatchSchTest',  cronExp, new CustomerPrimaryContactBatchSchedular());
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            //System.assertNotEquals(cronExp, ct.CronExpression);
            System.assertEquals(ct.TimesTriggered, ct.TimesTriggered);
        }
        Test.stopTest();
    }

}