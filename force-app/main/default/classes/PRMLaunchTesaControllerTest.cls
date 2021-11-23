/*********** 
 * Team : Hawaii
 * Description : Test class to covers 'PRMLaunchTesaController' apex class.
 * Jira : P2OB-6450
 * Created Date : 10 October 2020
*****************/
@isTest
public class PRMLaunchTesaControllerTest {
    
    //Create test data
    @testSetup static void setup(){
        //Profile Map
        Map<String,Profile> profilesMap = new Map<String,Profile>();
        
        for(Profile profile : [Select Name, Id From Profile]){
            profilesMap.put(profile.Name, profile);
        }
        
        //Role Map
        Map<String,UserRole> rolesMap = new Map<String,UserRole>();
        for(UserRole role : [Select DeveloperName, Id From UserRole where DeveloperName = 'Sales_Ops']){
            rolesMap.put(role.DeveloperName, role);
        }
        
        //Create Admin User
        User[] adminUser = PRMTestUtility.createInternalUsers(1,new List<Profile>{profilesMap.get('System Administrator')} , rolesMap.get('Sales_Ops'));
        adminUser[0].UserPermissionsKnowledgeUser = true;
        
        Test.startTest();
        
        insert adminUser;
        
        List<User> users= new List<User>();
        List<Contact> contactList = new List<Contact>();
        User[] partnerUser=new List<User>();
        
        //Create Customer Account
        Account[] customerAccount = PRMTestUtility.createAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Enterprise').getRecordTypeId());
        
        //Run as System Admin
        System.runAs(adminUser[0]){
            
        	insert customerAccount;
        	
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
            
            //share customer account with partner user
            AccountShare[] shareList = new List<AccountShare>();
            for(Account acc : customerAccount){
            AccountShare share = new AccountShare();
            	share.AccountId = acc.Id;
            	share.UserOrGroupId = users[0].Id;
                share.AccountAccessLevel = 'Edit';
                share.OpportunityAccessLevel = 'Edit';
                share.CaseAccessLevel = 'Read';
                shareList.add(share);
            }
            insert shareList;
            
            PRM_Default__c defaultSet = new PRM_Default__c();
            defaultSet.EnablePartnerTesaLaunch__c = true;
            insert defaultSet;
        }
        Test.stopTest();
    }
    
    //Method to cover error conditions logic on click of 'Launch TESA' button
    public static testmethod void testErrorConditions(){
        
        Test.startTest();
        User[] usr = [Select Id,Profile.Name From User where (email='test@noemail45345555.com0')];
        Account[] partnerAcc = [Select Id,Name From Account where Name='TEST_Partner_ACCOUNT0' limit 1];
        Account[] customerAcc = [Select Id,Name From Account where Name='TEST_ACCOUNT0' limit 1];
        //run as partner user
        system.runAs(usr[0]){ 
            Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('MAC').getRecordTypeId();
			List<Opportunity> oppList = new List<Opportunity>();
            oppList = PRMTestUtility.createOpportunity(1,customerAcc,oppRecordTypeId,partnerAcc[0].Id);
            oppList[0].SubmittoPartnerStatus__c = 'Submitted'; 
            insert oppList;
            List<PRMLaunchTesaController.OppDataWrapper> oppWrapper =PRMLaunchTesaController.getOpportunityData(oppList[0].Id);
            for(PRMLaunchTesaController.OppDataWrapper oppWrap : oppWrapper){
                system.assertEquals(true, oppWrap.errorMsgs.size() > 0);
            }
        }
        Test.stopTest();
     }
    
    //Method to cover launch of tesa application if there is no error
    public static testmethod void testOpportunityApproved(){
        
        Test.startTest();
        User[] usr = [Select Id,Profile.Name From User where (email='test@noemail45345555.com0')];
        Account[] partnerAcc = [Select Id,Name From Account where Name='TEST_Partner_ACCOUNT0' limit 1];
        Account[] customerAcc = [Select Id,Name From Account where Name='TEST_ACCOUNT0' limit 1];
        //run as partner user
        system.runAs(usr[0]){
            Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('MAC').getRecordTypeId();
			List<Opportunity> oppList = new List<Opportunity>();
            oppList = PRMTestUtility.createOpportunity(1,customerAcc,oppRecordTypeId,partnerAcc[0].Id);
            oppList[0].Partner_Opportunity_Verification__c = 'Approved';
            insert oppList;
            List<PRMLaunchTesaController.OppDataWrapper> oppWrapper =PRMLaunchTesaController.getOpportunityData(oppList[0].Id);
            Boolean featureEnable = PRMLaunchTesaController.checkFeatureEnabled();
            for(PRMLaunchTesaController.OppDataWrapper oppWrap : oppWrapper){
                system.assertEquals(false, oppWrap.showError);
            }
        }
        Test.stopTest();
     }
}