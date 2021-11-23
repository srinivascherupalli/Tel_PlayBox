/*------------------------------------------------------
Class Updated by Ayush(Team Hawaii) 
for story number P2OB-8369 
Date - 13th August 2020
Test Class Covered - PRMProductCategoryContr
--------------------------------------------------------*/


@isTest
public class PRMProductCategoryContrTest {
    
    //partner user, prm enterprise ps
    @testSetup
    public static void createData(){
        
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
        adminUser[0].UserPermissionsKnowledgeUser = true;
        insert adminUser;
        
        User[] partnerUser=new List<User>();
        List<User> users= new List<User>();
        List<Contact> contactList = new List<Contact>();
        
        System.runAs(adminUser[0]){
            Account[] partnerAccount = PRMTestUtility.createPartnerAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId(),'Partner','New',null);          
            insert partnerAccount; 
            //Create Partner Contact
            contactList = PRMTestUtility.createContact(1,Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner_Contact').getRecordTypeId(),partnerAccount[0].Id);
            insert contactList;
            partnerAccount[0].isPartner = True;
            partnerAccount[0].PartnerPrincipalContact__c = contactList[0].id;
            partnerAccount[0].CWP_Eligible_Partner__c = false;
            partnerAccount[0].Account_Status__c = 'Active';
            //Update Partner account
            update partnerAccount[0];
            
            //Create Partner User
            partnerUser = PRMTestUtility.createPartnerUsers(1,new List<Profile>{profilesMap.get('PRM Admin - Australia')} ,contactList,false);
            users.addAll(partnerUser);
            insert users;
            
            // Create PermissionSet with Custom Permission and assign to test user
            PermissionSet ps = new PermissionSet();
            ps.Name = 'TestNew';
            ps.Label = 'TestNew';
            insert ps;
            SetupEntityAccess sea = new SetupEntityAccess();
            sea.ParentId = ps.Id;
            sea.SetupEntityId = [select Id from CustomPermission where DeveloperName = 'PRM_Enterprise_Content_Knowledge_User'][0].Id;
            insert sea;
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = users[0].Id;
            psa.PermissionSetId = ps.Id;
            insert psa;
        }
    } 
	
    @isTest
    static void getTopProductCategoriesTest(){
        //User u = [Select id From User where Alias='PART' Limit 1];
        User usr = [Select Id,Profile.Name From User where email='test@noemail45345555.com0' AND Profile.Name = 'PRM Admin - Australia' Limit 1];
        List<PRMProductCategoryContr.PRMDataCategoryWrapper> productList= new List<PRMProductCategoryContr.PRMDataCategoryWrapper>();
        Test.startTest();
        system.runAs(usr){
            productList = PRMProductCategoryContr.getTopProductCategories('Products');
        }
        Test.stopTest();
        system.assertEquals(True, productList.size()>0);      
        
    }
}