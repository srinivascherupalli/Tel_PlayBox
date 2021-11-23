/*********** 
 * Team : Hawaii
 * Description : Test class to covers 'PRMContactRecordEditFormController' apex class.
 * Jira : P2OB-10028
 * Created Date : 6 October 2020
*****************/
@isTest
public class PRMContactRecordEditFormControllerTest {
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
        Account[] customerAccount  = PRMTestUtility.createAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Enterprise').getRecordTypeId());
        
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
        }
        Test.stopTest();
    }
    
    //test method to get contact info field set members from field set
    public static testmethod void getContactInfoFieldSetMemberTest(){
        Test.startTest();
        User[] usr = [Select Id,Profile.Name From User where (email='test@noemail45345555.com0')];
        //run as partner user
        system.runAs(usr[0]){
          String fieldSetFields =  PRMContactRecordEditFormController.getFieldSetMember('Contact','Record_Form_Contact_Info_Section_Fields');
          List<Object> deserializeFieldSet = (List<Object>)json.deserializeUntyped(fieldSetFields);
          system.assertEquals(true, deserializeFieldSet.size()>0);
        }
        Test.stopTest();
    }
    
    //test method to get address info field set members from field set
    public static testmethod void getAddressInfoFieldSetMemberTest(){
        Test.startTest();
        User[] usr = [Select Id,Profile.Name From User where (email='test@noemail45345555.com0')];
        //run as partner user
        system.runAs(usr[0]){
          String fieldSetFields =  PRMContactRecordEditFormController.getFieldSetMember('Contact','Record_Form_Contact_Info_Section_Fields');
          List<Object> deserializeFieldSet = (List<Object>)json.deserializeUntyped(fieldSetFields);
          system.assertEquals(true, deserializeFieldSet.size()>0);
        }
        Test.stopTest();
    }
    
   	//test method to get record type id from record type name
    public static testmethod void getRecordTypeId(){
        
        Test.startTest();
        User[] usr = [Select Id,Profile.Name From User where (email='test@noemail45345555.com0')];
        //run as partner user
        system.runAs(usr[0]){
          String recordTypeId =  PRMContactRecordEditFormController.getRecordTypeId('Contact','Partner Contact');
          system.assertEquals(true, string.isNotBlank(recordTypeId));
        }
        Test.stopTest();
    }
}