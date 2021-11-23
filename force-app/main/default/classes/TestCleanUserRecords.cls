@isTest(SeeAllData=true)
public class TestCleanUserRecords {
    //Create setup objects
    public static User [] setup(String query){
        User [] users = Database.query(query);
        UserPackageLicense [] licenses = new List<UserPackageLicense>();
        for(User user: users)
            licenses.add(new UserPackageLicense(UserId = user.id, PackageLicenseId = '05028000000fEVbAAM'));
        Database.insert(licenses,false);
        CaseTeamMember [] caseMembers = new List<CaseTeamMember>();
        CaseTeamRole role = new CaseTeamRole();
        role.Name = 'Best';
        role.AccessLevel = 'None';
        Database.insert(role,false);
        return users;
    }
    //Create non-setup objects
    public static User [] nonSetup(String query){
        User [] users = Database.query(query);
        Account account = new Account();
        account.Name = 'Test';
        Database.insert(account,false);
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];
        Case raisedCase = new Case();
        Database.insert(raisedCase, true);
        OpportunityTeamMember [] opportunityMembers = new List<OpportunityTeamMember>();
        for(User user: users)
            opportunityMembers.add(new OpportunityTeamMember(UserId = user.id, OpportunityId = opportunity.id));
        Database.insert(opportunityMembers,false);
        AccountTeamMember [] accountMembers = new List<AccountTeamMember>();
        for(User user: users)
            accountMembers.add(new AccountTeamMember(UserId = user.id, AccountId = account.id));
        
        Database.insert(accountMembers, false);
        /*CaseTeamRole role = [SELECT id FROM CaseTeamRole LIMIT 1];
        CaseTeamMember [] caseMembers = new List<CaseTeamMember>();
        for(User user: users)
            caseMembers.add(new CaseTeamMember(MemberId = user.id, ParentId = raisedCase.id, TeamRoleId = role.id));
        Database.insert(caseMembers, false);*/
        return users;
    }
    //Test that takes a a integer that represents a period since last login
    @isTest public static void testSetupQuery(){  
        //Make sure the user is sales enterprise otherwise they might not be inserted into teams 
        CleanUserRecords cleanUserRecords = new CleanUserRecords('SELECT Id FROM User WHERE isActive = true AND Profile.UserLicense.LicenseDefinitionKey = \'SFDC\' LIMIT 200');
        User [] clean = setup(cleanUserRecords.query);

        //Assert that licenses were inserted
        System.assert([SELECT Id FROM UserPackageLicense WHERE UserId IN: clean].size() >0);
        Test.startTest();
        Database.executeBatch(cleanUserRecords, 200);
        Test.stopTest();
        //Assert that licenses were deleted
        System.assert([SELECT Id FROM UserPackageLicense WHERE UserId IN: clean].size() == 0);
    }  
    /*//Test that takes a a integer that represents a period since last login
    @isTest public static void testNonSetup(){
        //Make sure the user is sales enterprise otherwise they might not be inserted into teams 
        CleanUserRecords cleanUserRecords = new CleanUserRecords('SELECT Id FROM User WHERE isActive = true AND Profile.UserLicense.LicenseDefinitionKey = \'SFDC\' LIMIT 200');
        User [] clean = nonSetup(cleanUserRecords.query);

        //Assert that relations were inserted
        System.assert([SELECT Id FROM OpportunityTeamMember WHERE UserId IN: clean].size() > 0);
        System.assert([SELECT Id FROM AccountTeamMember WHERE UserId IN: clean].size() > 0);
        //System.assert([SELECT Id FROM CaseTeamMember WHERE MemberId IN: clean].size() > 0); 
        Test.startTest();
        Database.executeBatch(cleanUserRecords, 200);
        Test.stopTest();
        //Assert that relations were deleted
        System.assert([SELECT Id FROM OpportunityTeamMember WHERE UserId IN: clean].size() == 0);
        System.assert([SELECT Id FROM AccountTeamMember WHERE UserId IN: clean].size() == 0);
        //System.assert([SELECT Id FROM CaseTeamMember WHERE MemberId IN: clean].size() == 0);
    }*/        
}