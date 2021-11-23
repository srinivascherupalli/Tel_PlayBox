/*******************************************************************
Created By          :   Team Hawaii
Created Date        :   15/5/2020
Jira                :   P2OB-6000
Desc                :   Test class for class 'PartnerFundClaimTriggerHelper'.It covers logic written in 'PartnerFundClaimTriggerHelper' class.
Updated : 1. P2OB-6797 :  Updated test data  (04/06/2020)
2. 21-July-2020		:	Team Hawaii : Ritika Jaiswal : P2OB-8124 - Financial year from Picklist-Value-Set, Replacing hard-coded string 'FY20' with picklist value from global-set
***********************************************************************/
@isTest
public class PartnerFundClaimTriggerHelperTest {    
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
            //Create Budget record
            // P2OB-6797 updated buget amount
            List<PartnerMarketingBudget> budgetList = PRMTestUtility.createMarketingBudget(2,200000);
            if(budgetList != Null && budgetList.size() > 0){
                insert budgetList;
            }
            //Create Allocation record for Partner
            List<PartnerFundAllocation> allocationList = PRMTestUtility.createFundAllocation(2,budgetList[0].Id,partnerAccount[0].Id,75000,financial_year);
            if(allocationList != Null && allocationList.size() > 0){
                insert allocationList;
            }
            //Create Fund Request for Partner
            List<PartnerFundRequest> fundRequestList = PRMTestUtility.createFundRequest(2,budgetList[0].Id,partnerAccount[0].Id,allocationList[0].Id,25000,financial_year);
            if(fundRequestList != Null && fundRequestList.size() > 0){
                insert fundRequestList;
            }
            //Create Custom setting to enable/disable trigger 
            Environment_Configurations__c env = new Environment_Configurations__c();
                env.No_Triggers__c = false;
            insert env;
            
            //Create Custom setting for Partner Fund Claim 
            PRM_Funds_Management__c prmFundManagement = new PRM_Funds_Management__c();
                prmFundManagement.Claim_Approver_Error__c = Label.PRM_CLAIM_ERROR_MESSAGE; 
                prmFundManagement.Custom_Permission_For_Approval__c = 'PRM_Partner_Claim_Final_Approver';
                prmFundManagement.Claim_Amount__c = 25000;
                prmFundManagement.Is_Second_Level_Approval_Required__c = true;
            insert prmFundManagement;
        }
        Test.stopTest();
    }
    
    //This method covers the 'checkClaimCanBeApproved' method in 'PartnerFundClaimTriggerHelper' apex clas
    public static testMethod void testCheckClaimCanBeApproved(){
        //P2OB-8124 - Financial year from Picklist-Value-Set
        List<Schema.PicklistEntry> ple = Partner_Incremental_Fund_Allocation__c.Financial_Year__c.getDescribe().getPicklistValues();
        String financial_year= ple[0].getValue();
        //Fetch partner user and admin user creted in data setup method
        User[] usr = [Select Id,Profile.Name From User where (email='test@noemail45345555.com0' OR email='test@noemail1234.com0') order by Profile.Name asc];
        //Fetch PartnerFundRequest record for Financial year financial_year
        List<PartnerFundRequest> partnerFundRequest = [Select id,Title from PartnerFundRequest Where Title = 'Partner Request0'AND Financial_Year__c =: financial_year LIMIT 1];
        List<PartnerFundClaim> fundClaimList = new List<PartnerFundClaim>();
        //Run as partner user
        system.runAs(usr[0]){
            fundClaimList = PRMTestUtility.createFundClaim(2,partnerFundRequest[0].Id,25000,financial_year);
            for(PartnerFundClaim fundClaim : fundClaimList){
                fundClaim.Partner_Account_Owner__c = usr[1].Id;
                fundClaim.Final_Approver__c = usr[1].Id;
            }
            //Create Partner Fund Claim record
            if(fundClaimList != Null && fundClaimList.size() > 0){
                Test.startTest();
                insert fundClaimList;
                //update status to approved
                fundClaimList[0].Status = 'Approved';
                try{
                    update fundClaimList;
                }catch(exception e){
                    //check if functionality is working as expected
                    system.assertEquals(true, e.getMessage().contains(Label.PRM_CLAIM_ERROR_MESSAGE));
                }
                Test.stopTest();
            }
        }
    }
}