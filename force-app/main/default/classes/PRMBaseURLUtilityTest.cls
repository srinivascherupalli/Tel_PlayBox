/*
Created By : Team Hawaii
Created Date : 20/11/2019
Jira : P2OB- 3890
*/

//Test class for PRMBaseURLUtility class
// DUPLICATE_USERNAME fix
@IsTest
public class PRMBaseURLUtilityTest {
     
    public static testMethod void getBaseURLForCommunityUserTest(){
        Map<String,Profile> profileMap = new Map<String,Profile>();
        Profile[] partnerProfile = [Select id,Name from Profile where Name IN ('PRM Community User - Australia','System Administrator')];
        for(Profile prof : partnerProfile){
            profileMap.put(prof.Name,prof);
        }
        
        UserRole userRole = [Select id,Name from UserRole where Name = 'CEO']; 
        
        Test.startTest();
        // DUPUPLICATE_USERNAME - Hawaii - 02-09-2020
        List<User> adminUserList = PRMTestUtility.createInternalUsers(1, new List<Profile>{profileMap.get('System Administrator')}, userRole) ;
        insert adminUserList;
        
        List<User> userList = new List<User>();
        system.runas(adminUserList[0]){
        // DUPUPLICATE_USERNAME - Hawaii - 02-09-2020
        Id accountPartnerRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();
            List<Account> accList = new List<Account>(); 
            Account acc = new Account();
                acc.Name = 'Test Accountdit';
                acc.Partner_Type__c='Channel';
                acc.Customer_Status__c='ACTIVE';
                acc.Migrated_Customer__c=true;
                acc.OwnerId = adminUserList[0].Id;
                acc.RecordTypeId = accountPartnerRecTypeId;
                accList.add(acc);
           insert accList;
           // Test class fixes - Hawaii - 02-09-2020
           Id partnerRecord = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner_Contact').getRecordTypeId();
           List<Contact> conList = PRMTestUtility.createContact(1,partnerRecord,accList[0].Id);
           insert conList;
            
            accList[0].isPartner = True;
            accList[0].PartnerPrincipalContact__c = conList[0].id;
            update accList;
            
            // DUPLICATE_USERNAME - Hawaii - 02-09-2020
            userList = PRMTestUtility.createPartnerUsers(1, new List<Profile>{profileMap.get('PRM Community User - Australia')}, conList,true);
            insert userList;
            
            
        }
        
        system.runas(userList[0]){
           String baseURL = PRMBaseURLUtility.getBaseURLForCommunityUser();
           Boolean isTrue = baseURL.contains('telstra');
           system.assertEquals(isTrue,true);
        }
        Test.stopTest();
    }
    
}