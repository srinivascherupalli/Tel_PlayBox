/********************************************************************************
* Class Name    : C2O_AccountTeamMemberTriggerTest
* Description   : DIGI-12760, Sprint 21.12
                  This class is test class for C2O_AccountTeamMemberTrigger, C2O_AccountTeamMemberTriggerHandler and C2O_AccountTeamMemberTriggerHelper functionality 
* Created By    : Sri    

********************************************************************************/
@isTest
public class C2O_AccountTeamMemberTriggerTest {
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
            Test.startTest();
            insert customerAccount;
            
            List<AccountTeamMember> actTeamMembers = new List<AccountTeamMember>();
            AccountTeamMember actTeamMember1 = TestUtil.createAccountTeamMember(UserInfo.getUserId(), customerAccount.id, Label.ClosureApproverAccountTeamMemRole);
            actTeamMembers.add(actTeamMember1);
            
            AccountTeamMember actTeamMember2 = TestUtil.createAccountTeamMember(sales2.Id, customerAccount.id, 'Sales Rep');
            actTeamMembers.add(actTeamMember2);

            AccountTeamMember actTeamMember3 = TestUtil.createAccountTeamMember(sales.Id, customerAccount.id, Label.ClosureApproverAccountTeamMemRole);
            actTeamMembers.add(actTeamMember3);
            try{
	            Database.insert(actTeamMembers, false) ;
            }
            catch(Exception ex){
                system.debug('Exception:::: C2O_AccountTeamMemberTriggerTest :::: setup Method'+ ex.getMessage());
            }
            Test.stopTest();
        }
    }
    /*
    @Method Name: testCheckOpportunityApproverTeamMember
    @Description: DIGI-12760, Sprint 21.12
				  To test a checkOpportunityApproverTeamMember validation
    @Author		: Sri (Team SFO)
    */
    @isTest
    public static void testCheckOpportunityApproverTeamMember(){
        User sales = [select id, name from User where username='salesuser@testsales.com'];
        System.runAs(sales){
            try{
                Account customerAccount = [select id, name from Account limit 1 ];
                User sales2 = [select id, name from User where username='sales2user@testsales.com'];
                AccountTeamMember actTeamMember = [select userId, user.name, TeamMemberRole, AccountId from AccountTeamMember where AccountId =:customerAccount.Id and TeamMemberRole = 'Sales Rep' LIMIT 1];
                actTeamMember.TeamMemberRole = Label.ClosureApproverAccountTeamMemRole;
                update actTeamMember;
            }
            catch(Exception ex){
                system.debug('Exception:::: C2O_AccountTeamMemberTriggerTest :::: testCreateChatter Method'+ ex.getMessage());
            }
        }
    }
    
}