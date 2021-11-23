/*********** 
 * Team : Hawaii
 * Description : Test class for PRM_GenericListViewController.
 * Jira : 
 * Created Date : 09 Feb 2021
*****************/
@isTest
public class PRM_GenericListViewControllerTest {
    
    private static final String List_View_Name = 'PRM_Opportunities';
    private static final String Sobject_Name = 'Opportunity';
    private static final String Field_To_Show = 'Name,AccountId,StageName,CloseDate';
    
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
            
			Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('MAC').getRecordTypeId();
			List<Opportunity> oppList = new List<Opportunity>();
            oppList = PRMTestUtility.createOpportunity(1,customerAccount,oppRecordTypeId,partnerAccount[0].Id);
            insert oppList;
            
            //Create Group
        	Group grp = new Group();
        	grp.name = 'PRM_Partner_Users';
        	grp.Type = 'Regular'; 
        	Insert grp;
            
            List<GroupMember> grpMemList = new List<GroupMember>();
            if(users != null && users.size() > 0){
                for(User usr : users){
                    //Create Group Member
                    GroupMember grpMem = new GroupMember();
                    grpMem.UserOrGroupId = usr.Id;
                    grpMem.GroupId = grp.Id;
                    grpMemList.add(grpMem);
                }
            }
            
            if(grpMemList.size() > 0){
                insert grpMemList;
            }
            
        }
    }
        
    //Method to test getListViewQuery
   	public static testmethod void testGetListViewQuery(){
    	Test.startTest();
        //Get Partner User
        User[] usr = [Select Id,Profile.Name From User where (email='test@noemail45345555.com0') limit 1];
        system.runAs(usr[0]){
            // Setting up the mock response
        	Test.setMock(HTTPCalloutMock.class, new PRM_GenericListViewMocTest());
            PRM_GenericListViewController.ResultWrapper wrapperData = PRM_GenericListViewController.getListViewQuery(List_View_Name,Sobject_Name,Field_To_Show);
            Test.stopTest();
            System.assertEquals('My Opportunities', wrapperData.listViewLabel);
        }
    }
}