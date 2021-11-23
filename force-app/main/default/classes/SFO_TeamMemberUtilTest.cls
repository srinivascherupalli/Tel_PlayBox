/********************************************************************************
* Class Name    : C2O_ChatterUtilTest
* Description   : This class is test class for C2O_ChatterUtil functionality 
* Created By    : Sri    

********************************************************************************/
@isTest
public class SFO_TeamMemberUtilTest {
    @testSetup static void setup() {
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise]; 
        Profile pfAdmin = [select id from profile where name =:Label.Profile_SystemAdmin]; 
        
        List<user> userList = new List<user>();
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        User sales = TestUtil.createTestUser(r.id,pf.id,'salesuser','Testing');
        sales.username='salesuser@testsales.com';
        sales.email='salesuser@testsales.com';
        sales.phone='+121231231234';
        userList.add(sales);
        
        User sales2 = TestUtil.createTestUser(r.id,pf.id,'sales2user','Testing');
        sales2.username='sales2user@testsales.com';
        sales2.email='sales2user@testsales.com';
        sales2.phone='+121231231245';
        userList.add(sales2);
        
        User admin = TestUtil.createTestUser(r.id,pfAdmin.id,'adminUser','Testing2');
        admin.username='TestingAdmin@TestingAdmin.com';
        admin.email='adminuser@testadmin.com';
        admin.phone='+121231231234';
        
        userList.add(admin);
        insert userList;
        
        system.runAs(admin){
            Account customerAccount=TestUtil.createAccount('Test Account');
            customerAccount.OwnerId=sales.id;
            insert customerAccount;
            
			List<AccountTeamMember> actTeamMembers = new List<AccountTeamMember>();
            AccountTeamMember actTeamMember1 = TestUtil.createAccountTeamMember(UserInfo.getUserId(), customerAccount.id, 'Sales Rep');
            actTeamMembers.add(actTeamMember1);
            
            AccountTeamMember actTeamMember2 = TestUtil.createAccountTeamMember(sales2.Id, customerAccount.id, Label.ClosureApproverAccountTeamMemRole);
            actTeamMembers.add(actTeamMember2);

            insert actTeamMembers;
        }
    }
    @isTest
    public static void testGetAccountTeamMembers(){
        User sales = [select id, name from User where username='salesuser@testsales.com'];
        System.runAs(sales){
            Account acc = [select id, name from Account limit 1 ];
            Test.startTest();
            List<AccountTeamMember> actTeamMembersWORole = SFO_TeamMemberUtil.getAccountTeamMembers(new Set<Id>{acc.Id}, null);
            Test.stopTest();
            system.assertEquals(2, actTeamMembersWORole.size());
            
            List<AccountTeamMember> actTeamMembersWRole = SFO_TeamMemberUtil.getAccountTeamMembers(new Set<Id>{acc.Id}, Label.ClosureApproverAccountTeamMemRole);
            system.assertEquals(1, actTeamMembersWRole.size());
            
            List<AccountTeamMember> actTeamMembersWOAct = SFO_TeamMemberUtil.getAccountTeamMembers(new Set<Id>{}, Label.ClosureApproverAccountTeamMemRole);
            system.assertEquals(True, actTeamMembersWOAct.isEmpty());
        }
    }

}