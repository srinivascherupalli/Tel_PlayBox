/*****************************************************************
@Name: EnableProductTypeSelectionTest
@Description: EDGE-134166: Enable Opp Product Type selection at time of Opportunity creation
Test class for EnableProductTypeSelection

******************************************************************/
@isTest
public class EnableProductTypeSelectionTest{

    @testSetup static void setup() {
		  UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
          insert r;

         profile pSysAdmin = [select id,name from Profile where Name =:'System Administrator'];

               User uSysAdmin = new User(alias = 'Con123', email='ContactTr8wrw98@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid =pSysAdmin.id, country='United States',IsActive =true,
                timezonesidkey='America/Los_Angeles', username='Cont987657awqas@noemail.com', userroleid=r.id);

        insert uSysAdmin;

         PermissionSetGroup psg = new PermissionSetGroup();
           psg.DeveloperName = 'Enabled_to_sell_Modular_Products_Test';
		   psg.MasterLabel = 'Enabled_to_sell_Modular_Products_Test';          
		   insert psg;
	
        System.debug('psg'+psg.id);
        
        }

     static testmethod void testEnablePSG() {
		User uSysAdmin = [Select id from User where username='Cont987657awqas@noemail.com'];
        System.runAs(uSysAdmin){
          
        Logger2 logger = Logger2.getLogger('EnableProductTypeSelection');
        id p = [select id from profile where name=:System.label.PRM_Community_User /*'PRM Community User - Australia'*/].id;
       
        Account ac = new Account(name ='Telecom', CWP_Eligible_Partner__c = false) ;
        insert ac;
        List<Account> accList = new List<Account>();
        accList.add(ac);
        System.assertNotEquals(null,accList);
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Onboarding_Status__c = 'Active', email = 'pims@testmail.com',MailingCountry='Australia',MailingStreet='Test Street',MailingCity ='Melborne');
        insert con;
        Contact con2 = new Contact(LastName ='testCon2',AccountId = ac.Id, Onboarding_Status__c = 'InActive',email = 'pims2@testmail.com',MailingCountry='Australia',MailingStreet='Test Street',MailingCity ='Melborne');
        insert con2;

        User u1 = new User(alias = 'test123', email='test123@noemail.com',
                           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                           localesidkey='en_US', Profileid = p, country='United States',IsActive =true,
                           ContactId = con.Id,
                           timezonesidkey='America/Los_Angeles', username='testerpims@noemail.com');

        insert u1;
            
        
        test.starttest();
        ac.CWP_Eligible_Partner__c = true;
        update ac;
       // EnableProductTypeSelection.assignPermissionSetGroupInvocable(accList);
        Test.stopTest();
      //  System.assertNotEquals(null,u1);
      List<PermissionSetAssignment> psList = [select id, PermissionSetGroup.DeveloperName from permissionSetAssignment where AssigneeId =: u1.id and PermissionSetGroupId!=null];
      System.debug('psList Testclass add'+psList);
      System.assert(psList.size()>0);
        }
        
     }
    
    static testmethod void testDisablePSG(){
        User uSysAdmin = [Select id from User where username='Cont987657awqas@noemail.com'];
        
        System.runAs(uSysAdmin){
        Logger2 logger = Logger2.getLogger('EnableProductTypeSelection');
        id p = [select id from profile where name=:System.label.PRM_Community_User /*'PRM Community User - Australia'*/].id;
        Account ac = new Account(name ='Telecom', CWP_Eligible_Partner__c = true) ;
        insert ac;
        List<Account> accList = new List<Account>();
        accList.add(ac);
        System.assertNotEquals(null,accList);
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id, Onboarding_Status__c = 'Active', email = 'pims@testmail.com',MailingCountry='Australia',MailingStreet='Test Street',MailingCity ='Melborne');
        insert con;
        Contact con2 = new Contact(LastName ='testCon2',AccountId = ac.Id, Onboarding_Status__c = 'InActive',email = 'pims2@testmail.com',MailingCountry='Australia',MailingStreet='Test Street',MailingCity ='Melborne');
        insert con2;

        User u1 = new User(alias = 'test123', email='test123@noemail.com',
                           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                           localesidkey='en_US', Profileid = p, country='United States',IsActive =true,
                           ContactId = con.Id,
                           timezonesidkey='America/Los_Angeles', username='testerpims@noemail.com');

        insert u1;
      
        
        test.starttest();
        ac.CWP_Eligible_Partner__c = false;
        update ac;
       // EnableProductTypeSelection.assignPermissionSetGroupInvocable(accList);
       
        Test.stopTest();
        List<PermissionSetAssignment> psList = [select id, PermissionSetGroup.DeveloperName from permissionSetAssignment where AssigneeId =: u1.id and PermissionSetGroupId!=null];
        System.debug('psList Testclass remove'+psList);
        System.assert(psList.size()==0);
        //System.assertNotEquals(null,u1);
        }
        
    }
    
    
}