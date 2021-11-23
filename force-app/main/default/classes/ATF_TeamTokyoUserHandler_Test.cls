/*
 * Created By Ivan Aerlic
 */ 
@isTest
public class ATF_TeamTokyoUserHandler_Test {
    /*Tests that updating and inserting a user record updates the Activation Date field with todays date 
	 * for User records who are inserted as active or who have gone from inactive to active
	 * EDGE-115099 */
    @isTest
    public static void testAll(){
        User [] users = UserDataFactory.createUsers(4);
       
        //Set active status
        users[0].isActive = false;
        users[1].isActive = false;
        users[2].isActive = true;
        users[3].isActive = true;
        
        //Fire insert trigger
        insert users;
        
        //Reset Activation Date
        users[0].Activation_Date__c = null;
        users[1].Activation_Date__c = null;
        users[2].Activation_Date__c = null;
        users[3].Activation_Date__c = null;
        
        //Set users to active and fire update trigger
        users[0].isActive = false;
        users[1].isActive = true;
        users[2].isActive = false;
        users[3].isActive = true;
        
        test.startTest();
        update users;
     	test.stopTest();
        
        users = [SELECT Id, isActive, Activation_Date__c FROM User WHERE Id IN: users];
        
        //Assert negative and positive results
        System.assert(users[0].Activation_Date__c== null, 'false-false-update');
        System.assert(users[1].Activation_Date__c== System.today(), 'false-true-update');
        System.assert(users[2].Activation_Date__c== null, 'true-false-update');
        System.assert(users[3].Activation_Date__c== null, 'true-true-update'); 
    }
    
    @isTest static void test_handleAfterUpdate() {
        //Create active dummy users
        User [] users = UserDataFactory.createUsers(4);
        
        //Create active users
        insert users;
        
        //Query package license
       	PackageLicense pl = [SELECT Id,NamespacePrefix FROM PackageLicense LIMIT 1];
        //Query permission set assignment
       	PermissionSet ps = [SELECT Id,Name FROM PermissionSet WHERE isOwnedByProfile = false LIMIT 1];
        //Query permission set license assignment
        PermissionSetLicense psl = [SELECT Id,DeveloperName FROM PermissionSetLicense LIMIT 1];
        
        List<UserPackageLicense> uplList = new List<UserPackageLicense>();
        List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
        List<PermissionSetLicenseAssign> pslaList = new List<PermissionSetLicenseAssign>();
        //Tag package license, permission set assignment and permission set license assignment to all users
        for(User u : users) {
            uplList.add(new UserPackageLicense(PackageLicenseId = pl.Id, UserId = u.Id));
            psaList.add(new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = u.Id));
            pslaList.add(new PermissionSetLicenseAssign(PermissionSetLicenseId = psl.Id, AssigneeId = u.Id));
        }
        
        //Create user package license
        insert uplList;
        
        //Create permission set assignment
        insert psaList;
        
        //Create permission set license assignment
        insert pslaList;
        
        //Mark users inactive
        users[0].isActive = false;
        users[2].isActive = false;
        
        Test.startTest();
        //Update users
        update users;
     	Test.stopTest();
        
        //User Package License
        System.assertEquals([SELECT Id FROM UserPackageLicense WHERE UserId = :users[0].Id].size(), 0);
        System.assertEquals([SELECT Id FROM UserPackageLicense WHERE UserId = :users[1].Id].size(), 1);
        System.assertEquals([SELECT Id FROM UserPackageLicense WHERE UserId = :users[2].Id].size(), 0);
        System.assertEquals([SELECT Id FROM UserPackageLicense WHERE UserId = :users[3].Id].size(), 1);
        
        //Permission Set Assignment
        //When user is created profile level permission set will be assigned automatically
        //Profile level permission set will not be deleted. Only custom permission set will be deleted
        System.assertEquals([SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :users[0].Id].size(), 1);
        System.assertEquals([SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :users[1].Id].size(), 2);
        System.assertEquals([SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :users[2].Id].size(), 1);
        System.assertEquals([SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :users[3].Id].size(), 2);
        
        //Permission Set License Assignment
        System.assertEquals([SELECT Id FROM PermissionSetLicenseAssign WHERE AssigneeId = :users[0].Id].size(), 0);
        System.assertEquals([SELECT Id FROM PermissionSetLicenseAssign WHERE AssigneeId = :users[1].Id].size(), 1);
        System.assertEquals([SELECT Id FROM PermissionSetLicenseAssign WHERE AssigneeId = :users[2].Id].size(), 0);
        System.assertEquals([SELECT Id FROM PermissionSetLicenseAssign WHERE AssigneeId = :users[3].Id].size(), 1);
    }
}