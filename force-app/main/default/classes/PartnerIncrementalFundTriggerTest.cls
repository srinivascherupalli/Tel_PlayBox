/*******************************************************************
Created By          :   Team Hawaii
Created Date        :   01/06/2020
Jira                :   P2OB-6797
Desc                :   Test class for class 'PartnerIncrementalFundTriggerHandler'.It covers logic written in 'PartnerIncrementalFundTriggerHandler' class.
Updates :
1. 21-July-2020		:	Team Hawaii : Ritika Jaiswal : P2OB-8124 - Financial year from Picklist-Value-Set,Replacing hard-coded string 'FY20' with picklist value from global-set
***********************************************************************/
@isTest
public class PartnerIncrementalFundTriggerTest {
     // Test Data creation
    @testSetup static void setup() {
        // P2OB-8124 - Financial year from Picklist-Value-Set
        List<Schema.PicklistEntry> ple = Partner_Incremental_Fund_Allocation__c.Financial_Year__c.getDescribe().getPicklistValues();
        String financial_year = ple[0].getValue();
        //Profile Map
      Map<String,Profile> profilesMap = new Map<String,Profile>();
        for(Profile profile : [Select Name, Id From Profile])
            profilesMap.put(profile.Name, profile);
        //Role Map
        Map<String,UserRole> rolesMap = new Map<String,UserRole>();
        for(UserRole role : [Select DeveloperName, Id From UserRole where DeveloperName = 'Sales_Ops'])
            rolesMap.put(role.DeveloperName, role);
        //Create Admin User
        User[] adminUser = PRMTestUtility.createInternalUsers(1,new List<Profile>{profilesMap.get('System Administrator')} , rolesMap.get('Sales_Ops'));
        Test.startTest();
        insert adminUser;
        List<User> users= new List<User>();
        List<Contact> contactList = new List<Contact>();
        User[] partnerUser=new List<User>();
        //Create Customer Account
        Account[] customerAccount = PRMTestUtility.createAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Enterprise').getRecordTypeId());
        //Run as System Admin
        System.runAs(adminUser[0]){
            //Create Partner Account
            Account[] partnerAccount = PRMTestUtility.createPartnerAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId(),'Partner','New',null);          
            insert partnerAccount; 
            //Create Partner Contact
            contactList = PRMTestUtility.createContact(2,Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner_Contact').getRecordTypeId(),partnerAccount[0].Id);
            insert contactList;
            partnerAccount[0].isPartner = True;
            partnerAccount[0].PartnerPrincipalContact__c = contactList[0].id;
            partnerAccount[0].CWP_Eligible_Partner__c = false;
            partnerAccount[0].Account_Status__c = 'Active';
            //Update Partner account
            update partnerAccount[0];
            //Create Partner User
            partnerUser = PRMTestUtility.createPartnerUsers(2,new List<Profile>{profilesMap.get('PRM Community User - Australia')} ,contactList,false);
            users.addAll(partnerUser);
            insert users;
            //Assign 'PRM Claim Management' permission set to partner user
            List<PermissionSet> psList = [SELECT Id FROM PermissionSet WHERE Name = 'PRM_Claim_Management'];
            if(!psList.isEmpty()){
                List<PermissionSetAssignment> permissionSetAssignmentList = new List<PermissionSetAssignment> ();
                for(User pUser : partnerUser){
                    permissionSetAssignmentList.add(new PermissionSetAssignment(PermissionSetId = psList.get(0).Id,AssigneeId = pUser.Id));
                }
                insert permissionSetAssignmentList;
            }
            //Create Budget record
            List<PartnerMarketingBudget> budgetList = PRMTestUtility.createMarketingBudget(2,100000);
            budgetList[0].Financial_Year__c = financial_year;
            if(budgetList != Null && budgetList.size() > 0){
              insert budgetList;
            }
            //Create Custom setting to enable/disable trigger 
            Environment_Configurations__c env = new Environment_Configurations__c();
              env.No_Triggers__c = false;
            insert env;
        }
        Test.stopTest();
    }
    //This method covers the 'checkClaimCanBeApproved' method in 'PartnerFundClaimTriggerHelper' apex clas
    public static testMethod void testInsertFundAllocation(){
        // P2OB-8124 - Financial year from Picklist-Value-Set
        List<Schema.PicklistEntry> ple = Partner_Incremental_Fund_Allocation__c.Financial_Year__c.getDescribe().getPicklistValues();
        String financial_year = ple[0].getValue();
        User[] usr = [Select Id,Profile.Name From User where (email='test@noemail1234.com0') order by Profile.Name asc];
        List<Account> accountList = [select id, Partner_Code__c from Account where isPartner = true AND Name like 'TEST_Partner_ACCOUNT%'];
        //Run as partner user
        system.runAs(usr[0]){
            Test.StartTest();
            // insert Fund Allocation Test 
            List<Partner_Incremental_Fund_Allocation__c> fundIncrementalList = PRMTestUtility.createPartnerIncrementalFund(2, accountList, financial_year);
            insert fundIncrementalList;
            List<PartnerFundAllocation> partnerFundAllocations = [select id  from PartnerFundAllocation where channelPartnerId in : accountList];
            List<PartnerFundRequest> partnerFundRequests = [select id  from PartnerFundRequest where channelPartnerId in : accountList];
            System.assertEquals(partnerFundAllocations.size() , accountList.size());
            System.assertEquals(partnerFundRequests.size() , partnerFundRequests.size());
            // check Fund Allocation update call 
            fundIncrementalList = PRMTestUtility.createPartnerIncrementalFund(2, accountList, financial_year);
            insert fundIncrementalList;
            partnerFundRequests = [select id  from PartnerFundRequest where channelPartnerId in : accountList];
            System.assertEquals(partnerFundAllocations.size() , accountList.size());
            System.assertEquals(partnerFundRequests.size() , partnerFundRequests.size());
            Test.stopTest();
        }
    }
}