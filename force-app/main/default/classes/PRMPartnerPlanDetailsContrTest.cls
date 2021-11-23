/*********** 
 * Team : Hawaii
 * Description : Test class to covers 'PRMPartnerPlanDetailsContr' apex class.
 * Jira : P2OB-10459
 * Created Date : 3 November 2020
*****************/
@isTest
public class PRMPartnerPlanDetailsContrTest {
    
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
            
            List<Partner_Plan__c> partnerPlanList = PRMTestUtility.createPartnerPlan(1,partnerAccount,'FY22',partnerAccount[0].Partner_Code__c);
            insert partnerPlanList;
            system.debug('partnerPlanList id are'+partnerPlanList);
            
           
            //Create Partner User
            partnerUser = PRMTestUtility.createPartnerUsers(2,new List<Profile>{profilesMap.get('PRM Community User - Australia')} ,contactList,false);
            users.addAll(partnerUser);
            insert users;
            
        }
        Test.stopTest();
    }
    
    //Method to get partner plan details without card view
    public static testmethod void testGetRowDataWithoutCardView(){
        Test.startTest();
    	User[] usr = [Select Id,Profile.Name From User where (email='test@noemail45345555.com0')];
        system.debug('user value is'+usr);
        //run as partner user
        system.runAs(usr[0]){
            List<Partner_Plan__c> partnerPlan = [Select id,Partner_Code__c,Financial_Year__c,Target_Q1__c, Target_Q2__c, Target_Q3__c, Target_Q4__c From Partner_Plan__c where Financial_Year__c = 'FY22'];
            List<PRMPartnerPlanDetailsContr.DetailWrapper> detailWrapper = PRMPartnerPlanDetailsContr.getRowData('Target_Q1__c, Target_Q2__c, Target_Q3__c, Target_Q4__c',partnerPlan[0].Id,false); 
            system.assertEquals(true, detailWrapper.size() > 0);
        }
        Test.stopTest();
    }
    
    //Method to get partner plan details with card view
    public static testmethod void testGetRowDataWithCardView(){
        Test.startTest();
    	User[] usr = [Select Id,Profile.Name From User where (email='test@noemail45345555.com0')];
        //run as partner user
        system.runAs(usr[0]){
            List<Partner_Plan__c> partnerPlan = [Select id,Partner_Code__c,Financial_Year__c,Target_ASV__c From Partner_Plan__c where Financial_Year__c = 'FY22'];
            List<PRMPartnerPlanDetailsContr.DetailWrapper> detailWrapper = PRMPartnerPlanDetailsContr.getRowData('Partner_Focus__c',partnerPlan[0].Id,true); 
            system.assertEquals(true, detailWrapper.size() > 0);
        }
        Test.stopTest();
    }
}