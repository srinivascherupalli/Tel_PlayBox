/****************************************************************************
@Name			: SFOCIDNRevenueTargetsTriggerHandlerTest
@Author			: SFO(SanFrancisco)/Sri
@Sprint 		: 20.08[P2OB-6264]
@CreateDate		: 15/06/2020
@Description	: Test class for SFOCIDNRevenueTargetsTriggerHandler
@Last Modified  : 11/11/2021 21.15.03 fastlane duplicate username fix
********************************************************************************/
@isTest
public class SFOCIDNRevenueTargetsTriggerHandlerTest {
    @testSetup static void setup() {
        User adminUser = TestUtil.createUser('admina1s2@test.com', 'adm', System.Label.Profile_SystemAdmin);
        insert adminUser;
        system.runas(adminUser){
            Test.startTest();
            //User salesUser = TestUtil.createUser('salesone@test.com', 'sus', System.Label.Profile_SalesEnterprise);
            UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
            insert r;
            Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise];
            User salesUser = TestUtil.createTestUser(r.id,pf.id,'salesone','Testing');
            salesUser.Phone = '0445678001';
            insert salesUser;
            PermissionSet ps = [SELECT id FROM PermissionSet WHERE name =:Label.PermissionSet_ReferenceDataAdmin LIMIT 1];
            
            PermissionSetAssignment psa = new PermissionSetAssignment(
                AssigneeId = salesUser.id,
                PermissionSetId = ps.Id
            );
            insert psa;
            
            //CREATE Accounts
            list<Account> acclist =new list<Account>();
            for(integer a=0;a<5;a++){
                Account customerAccount=TestUtil.createAccount('Testacc'+a);
                customerAccount.OwnerId=salesUser.id;
                acclist.add(customerAccount);
            }
            insert acclist;
            Test.stopTest();
        }
    }
    
    /*
Team SFO, sprint 20.08, P2OB-6264(Sri)  
Testmethod to cover checkDuplicateAccountRecords from class SFOCIDNRevenueTargetsTriggerHandler
*/
    @isTest
    static void checkDuplicateAccountRecordsTest(){
        User salesUser = [Select id from User where firstname='salesone'];
        system.runas(salesUser){
            List<CIDN_Revenue_Targets__c> listofCIDNRevTargets = new List<CIDN_Revenue_Targets__c>();
            Account accountRec;
            for(Account acc : [select id, name from Account where OwnerId=:salesUser.id]){
                accountRec = acc;
                CIDN_Revenue_Targets__c oneCIDNRevTarget = TestUtil.createCIDNRevenueTarget(acc.id);
                listofCIDNRevTargets.add(oneCIDNRevTarget);
            }
            listofCIDNRevTargets.add(new CIDN_Revenue_Targets__c(Account_Name__c=accountRec.id));
            Test.startTest();
            Database.SaveResult[] insertResult= Database.insert(listofCIDNRevTargets, false);
            System.assertEquals(1, [select id from CIDN_Revenue_Targets__c where Account_Name__c=:accountRec.id].size());
            CIDN_Revenue_Targets__c updateCIDNRevTarget = [select id, Account_Name__c,Revenue_Target__c from CIDN_Revenue_Targets__c where Account_Name__c !=:accountRec.id limit 1];
            updateCIDNRevTarget.Account_Name__c = accountRec.id;
            updateCIDNRevTarget.Revenue_Target__c = 990099;
            List<CIDN_Revenue_Targets__c> updateListCIDNRevTargets = new List<CIDN_Revenue_Targets__c>();
            updateListCIDNRevTargets.add(updateCIDNRevTarget);
            Database.SaveResult[] updateResult= Database.update(updateListCIDNRevTargets, false);
            System.assertNotEquals(updateCIDNRevTarget.Revenue_Target__c, [select id, Account_Name__c,Revenue_Target__c from CIDN_Revenue_Targets__c where Account_Name__c !=:accountRec.id limit 1].Revenue_Target__c);
            
            Test.stopTest();
            
        }
    }            
}