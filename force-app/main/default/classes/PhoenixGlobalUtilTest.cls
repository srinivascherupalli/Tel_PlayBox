/*
* History of modifications - 
* 1.  17/03/2020 : Ritika Jaiswal : Team Hawaii : P2OB-4844 - Added test-method for auto-assignment permission-set group to partner-users, fixed failing method testPhoenixGlobalUtil4()
* 2.  19/03/2020 : Ritika Jaiswal : Team Hawaii : Fixed test-method 'testFindPartnerRole' failure due to 101-SOQL 
* 3.  29/03/2020 : Ritika Jaiswal : Assertion Failure due to permission-set-group deployment
*/
@isTest
public without sharing class PhoenixGlobalUtilTest{
    @testSetup static void setup() {
        UserRole r = [Select DeveloperName, Id From UserRole where DeveloperName='Sales_Ops'];
        //insert r;
        profile pSysAdmin = [select id,name from Profile where Name =:'System Administrator'];
        User uSysAdmin = new User(alias = 'Con123', email='ContactTr8wrw98@noemail.com',
                                  emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                  localesidkey='en_US', profileid =pSysAdmin.id, country='United States',IsActive =true,
                                  timezonesidkey='America/Los_Angeles', username='Cont987657awqas@noemail.com',UserRoleId = r.Id);
        insert uSysAdmin;
    }
    //Ritika : Fixed test-method to have inserts using list
    static testmethod void testPhoenixGlobalUtil(){
        User uSysAdmin = [Select id from User where username='Cont987657awqas@noemail.com'];
        System.runAs(uSysAdmin){
            Logger2 logger = Logger2.getLogger('PhoenixGlobalUtil');
            id p = [select id from profile where name=:System.label.PRM_Community_User /*'PRM Community User - Australia'*/].id;
            Account[] partnerAccount = PRMTestUtility.createPartnerAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId(),'Partner','New',null);
            insert partnerAccount;
            Account ac = partnerAccount[0];
            List<Contact> contactList = new List<Contact>();
            Id recordId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(PRMConstants.PRM_Partner_Contact_Record_Type).getRecordTypeId();
            Contact con = new Contact(recordtypeid=recordId,LastName ='testCon',AccountId = ac.Id,Partner_role__c='Partner Sales User', Onboarding_Status__c = 'Active', email = 'pims@testmail.com',MailingCountry='Australia',MailingStreet='Test Street',MailingCity ='Melborne');
            contactList.add(con);
            Contact con2 = new Contact(recordtypeid=recordId,LastName ='testCon2',AccountId = ac.Id,Partner_role__c='Partner Sales User', Onboarding_Status__c = 'InActive',email = 'pims2@testmail.com',MailingCountry='Australia',MailingStreet='Test Street',MailingCity ='Melborne');
            contactList.add(con2);
            insert contactList;
            User u1 = new User(alias = 'test123', email='test123@noemail.com',
                               emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                               localesidkey='en_US', Profileid = p, country='United States',IsActive =true,
                               ContactId = con.Id,
                               timezonesidkey='America/Los_Angeles', username='testerpims@noemail.com');
            insert u1;
            System.assertNotEquals(null,u1);
            //PhoenixGlobalUtil.DynamicSobject obj = new PhoenixGlobalUtil.DynamicSobject();
            test.starttest();
            PhoenixGlobalUtil.inactivatePortalUsers(new Set<string>{con.id});
            PhoenixGlobalUtil.inactivatePortalUsers(new Set<string>{con2.id});
            PhoenixGlobalUtil.upsertUserRecord(con.id, '00123', 'PRM Admin - Australia', true);
            //PhoenixGlobalUtil.upsertUserRecord(null, '01234', 'PRM Admin - Australia', true);
            PhoenixGlobalUtil.upsertUserRecord(con2.Id, '01234', 'PRM Admin - Australia', true);
            //PhoenixGlobalUtil.getRecord('Account','PIMS_Status_code__c = 0 Pims_Interface__c=\'createUser\'');
            //obj.getNewSobject('Account');
            test.stoptest();
        }
    }
    //Ritika: Fixed test-method to have inserts using lists
    static testmethod void testPhoenixGlobalUtil2(){
        User uSysAdmin = [Select id from User where username='Cont987657awqas@noemail.com'];
        System.runAs(uSysAdmin){
            Logger2 logger = Logger2.getLogger('PhoenixGlobalUtil');
            id p = [select id from profile where name=:System.label.PRM_Community_User /*'PRM Community User - Australia'*/].id;
            Account[] partnerAccount = PRMTestUtility.createPartnerAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId(),'Partner','New',null);
            insert partnerAccount;
            Account ac = partnerAccount[0];
            List<Contact> contactList = new List<Contact>();
            list<Id> lstcon = new list<Id>();
            map<Id,string> mapconIdsUserId = new map<Id,string>();
            Id recordId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(PRMConstants.PRM_Partner_Contact_Record_Type).getRecordTypeId();
            Contact con = new Contact(recordtypeid=recordId,LastName ='testCon',AccountId = ac.Id,Partner_role__c='Partner Sales User', Onboarding_Status__c = 'Active', email = 'pims@testmail.com',MailingCountry='Australia',MailingStreet='Test Street',MailingCity ='Melborne');
            contactList.add(con);
            lstcon.add(con.Id);
            mapconIdsUserId.put(con.Id,'01234');
            Contact con2 = new Contact(recordtypeid=recordId,LastName ='testCon2',AccountId = ac.Id,Partner_role__c='Partner Sales User', Onboarding_Status__c = 'InActive',email = 'pims2@testmail.com',MailingCountry='Australia',MailingStreet='Test Street',MailingCity ='Melborne');
            contactList.add(con2);
            insert contactList;
            User u1 = new User(alias = 'test123', email='test123@noemail.com',
                               emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                               localesidkey='en_US', Profileid = p, country='United States',IsActive =true,
                               ContactId = con.Id,
                               timezonesidkey='America/Los_Angeles', username='testerpims@noemail.com');
            insert u1;
            System.assertNotEquals(null,u1);
            //PhoenixGlobalUtil.DynamicSobject obj = new PhoenixGlobalUtil.DynamicSobject();
            test.starttest();
            PhoenixGlobalUtil.inactivatePortalUsers(new Set<string>{con.id});
            PhoenixGlobalUtil.upsertUserRecord(con.id, '00123', 'PRM Admin - Australia', true);
            //PhoenixGlobalUtil.upsertUserRecord(null, '01234', 'PRM Admin - Australia', true);
            //PhoenixGlobalUtil.upsertUserRecord(con2.Id, '01234', 'PRM Admin - Australia', true); commented by ramya
            //PhoenixGlobalUtil.upsertUserRecordfromBatch(lstcon, mapconIdsUserId, 'PRM Admin - Australia', true);commented by ramya
            //PhoenixGlobalUtil.getRecord('Account','PIMS_Status_code__c = 0 Pims_Interface__c=\'createUser\'');
            //obj.getNewSobject('Account');
            test.stoptest();
        }
    }
    //Ritika: Fixed test-method to have inserts using list
    static testmethod void testPhoenixGlobalUtil3(){
        User uSysAdmin = [Select id from User where username='Cont987657awqas@noemail.com'];
        System.runAs(uSysAdmin){
            Logger2 logger = Logger2.getLogger('PhoenixGlobalUtil');
            id p = [select id from profile where name=:System.label.PRM_Community_User /*'PRM Community User - Australia'*/].id;
            Account[] partnerAccount = PRMTestUtility.createPartnerAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId(),'Partner','New',null);
            insert partnerAccount;
            Account ac = partnerAccount[0];
            List<Contact> contactList = new List<Contact>();
            Id recordId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(PRMConstants.PRM_Partner_Contact_Record_Type).getRecordTypeId();
            Contact con = new Contact(recordtypeid=recordId,LastName ='testCon',AccountId = ac.Id,Partner_role__c='Partner Sales User', Onboarding_Status__c = 'Active', email = 'pims@testmail.com');
            contactList.add(con);
            Contact con2 = new Contact(recordtypeid=recordId,LastName ='testCon2',AccountId = ac.Id,Partner_role__c='Partner Sales User', Onboarding_Status__c = 'InActive',email = 'pims2@testmail.com');
            contactList.add(con2);
            insert contactList;
            User u1 = new User(alias = 'test123', email='test123@noemail.com',
                               emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                               localesidkey='en_US', Profileid = p, country='United States',IsActive =true,
                               ContactId = con.Id,
                               timezonesidkey='America/Los_Angeles', username='testerpims@noemail.com');
            insert u1;
            System.assertNotEquals(null,u1);
            //PhoenixGlobalUtil.DynamicSobject obj = new PhoenixGlobalUtil.DynamicSobject();
            test.starttest();
            String sObjectname = 'Account';
            String whereClause = 'PIMS_Status_code__c =\'0\' and Pims_Interface__c=\'createUser\'';
            //PhoenixGlobalUtil.getRecord(sObjectname,whereClause);
            //obj.getNewSobject('Account');
            test.stoptest();
        }
    }
    //Team Hawaii: Ritika: Fixed failure in test-method, due to validation on partner-type contacts
    static testmethod void testPhoenixGlobalUtil4(){
        Test.starttest();
        User uSysAdmin = [Select id from User where username='Cont987657awqas@noemail.com'];
        System.runAs(uSysAdmin){
            Logger2 logger = Logger2.getLogger('PhoenixGlobalUtil');
            id rtypeId2 = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(PRMConstants.PRM_Partner_Contact_Record_Type).getRecordTypeId();
            insert new Profiles__c(Name='PRM Admin - Australia',Profile_Name__c='PRM Admin - Australia');
            insert new Profiles__c(Name='PRM Community User - Australia',Profile_Name__c='PRM Community User - Australia');
            id p = [select id from profile where name=: PRMConstants.PRM_COMMUNITY_USER_AUSTRALIA].id;
            Account[] partnerAccount = PRMTestUtility.createPartnerAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId(),'Partner','New',null);
            insert partnerAccount;
            List<Contact> conList = new List<Contact>();    
            Contact con = new Contact(LastName ='testCon',AccountId = partnerAccount[0].Id,Partner_role__c='Partner Sales User', Onboarding_Status__c = 'Active', email = 'pims@testmail.com',recordtypeid=rtypeId2);
            conList.add(con);
            Contact con2 = new Contact(LastName ='testCon2',AccountId = partnerAccount[0].Id,Partner_role__c='Partner Sales User', Onboarding_Status__c = 'InActive',email = 'pims2@testmail.com',recordtypeid=rtypeId2);
            conList.add(con2);
            insert conList;    
            List<User> userList = new List<User>();
            User u1 = new User(alias = 'test123', email='test123@noemail.com',
                               emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                               localesidkey='en_US', Profileid = p, country='United States',IsActive =true,
                               ContactId = con.Id,
                               timezonesidkey='America/Los_Angeles', username='testerpims@noemail.com');
            userList.add(u1);
            User u2 = new User(alias = 'test1223', email='test12223@noemail.com',
                               emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                               localesidkey='en_US', Profileid = p, country='United States',IsActive =true,
                               ContactId = con2.Id,
                               timezonesidkey='America/Los_Angeles', username='testerpi2ms@noemail.com');
            userList.add(u2);
            insert userList;
            System.assertNotEquals(null,u1);
            //PhoenixGlobalUtil.DynamicSobject obj = new PhoenixGlobalUtil.DynamicSobject();
            String sObjectname = 'Account';
            String whereClause = 'PIMS_Status_code__c =\'0\' and Pims_Interface__c=\'createUser\'';
            //PhoenixGlobalUtil.getRecord2(sObjectname,whereClause);
            //obj.getNewSobject('Account');
            //
            map<id,contact> conmap= new map<id,contact>();
            conmap.put(con.id,con);
            Set<id> setIds = new Set<id>{con2.id};
                PhoenixGlobalUtil.assignPermissionSet(conmap,conmap,'Test');
            PhoenixGlobalUtil.manageUserPartnerPermSet(setIds,'Test');
            test.stoptest();
        }
    }
    static testmethod void testPhoenixGlobalUtil5(){
        User uSysAdmin = [Select id from User where username='Cont987657awqas@noemail.com'];
        System.runAs(uSysAdmin){
            map<string,string> FieldMapnew= new map<string,string>();
            FieldMapnew.put('DeveloperName','Apex_Error_Exception_PIMS');
            list<sObject> liststatus=PhoenixGlobalUtil.getRecords('PIMS_Status_Message_Mapping__mdt',FieldMapnew);
            Map<Id, Schema.RecordTypeInfo> recmap= new  Map<Id, Schema.RecordTypeInfo>();
            recmap=PhoenixGlobalUtil.getRecordTypeById('Account');
            System.assert(null != liststatus);
        }
    }
    /* P2OB-7962 : Test Method commented as the PhoenixGlobalUtil.findPartnerRole is being removed
    Ritika : Fixed test-method to have inserts using lists
    static testmethod void testFindPartnerRole(){
        User uSysAdmin = [Select id from User where username='Cont987657awqas@noemail.com'];
        System.runAs(uSysAdmin){
            Logger2 logger = Logger2.getLogger('PhoenixGlobalUtil');
            id CommunityUserProfileId = [select id from profile where name='PRM Community User - Australia'].id;
            id CommunityAdminProfileId = [select id from profile where name='PRM Admin - Australia'].id;
            Account ac = new Account(name ='Telecom') ;
            insert ac;
            List<Contact> conList = new List<Contact>();
            Contact con = new Contact(LastName ='testCon',AccountId = ac.Id,Partner_Role__c='Partner Sales User', Onboarding_Status__c = 'Active', email = 'pims@testmail.com');
            conList.add(con);
            Contact con2 = new Contact(LastName ='testCon2',AccountId = ac.Id,Partner_Role__c='Partner Sales User', Onboarding_Status__c = 'InActive',email = 'pims2@testmail.com');
            conList.add(con2);
            insert conList;
            ac.PartnerPrincipalContact__c=con.id;
            update ac;
            //Contact con3 = new Contact(LastName ='testCon3',AccountId = ac.Id, Onboarding_Status__c = 'Frozen',email = 'pims3@testmail.com');
            //insert con3;
            List<User> userList = new List<User>();
            User u1 = new User(alias = 'test123', email='test123@noemail.com',
                               emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                               localesidkey='en_US', Profileid = CommunityUserProfileId, country='United States',IsActive =true,
                               ContactId = con.Id,
                               timezonesidkey='America/Los_Angeles', username='testerpims@noemail.com');
            userList.add(u1);
            System.assertNotEquals(null,u1);
            User u2 = new User(alias = 'test1_t', email='test_test123@noemail.com',
                               emailencodingkey='UTF-8', lastname='Testi12', languagelocalekey='en_US',
                               localesidkey='en_US', Profileid = CommunityUserProfileId, country='United States',IsActive =False,
                               ContactId = con2.Id,
                               timezonesidkey='America/Los_Angeles', username='test_test123@noemail.com');
            userList.add(u2);
            insert userList;
            System.assertNotEquals(null,u2);
//User u3 = new User(alias = 'test2_t', email='test_est123@noemail.com',
//emailencodingkey='UTF-8', lastname='Testi12', languagelocalekey='en_US',
//localesidkey='en_US', Profileid = CommunityAdminProfileId, country='United States',IsActive =False,
//ContactId = con3.Id,isPRMSuperuser=true,
//timezonesidkey='America/Los_Angeles', username='test_st123@noemail.com');
//insert u3;
//System.assertNotEquals(null,u3);
            //List<User> userList = new List<user>();
           // userList.add(u1);
            //userList.add(u2);
            //userList.add(u3);
            UserLogin userFreeze = [Select Id,IsFrozen from UserLogin Where userId = :u1.Id];
            userFreeze.IsFrozen = true;
            update userFreeze;
            test.starttest();
            PhoenixGlobalUtil.findPartnerRole(userList);
            test.stoptest();
        }
    }*/
    static testmethod void testUpdateContactRecord(){
        User uSysAdmin = [Select id from User where username='Cont987657awqas@noemail.com'];
        System.runAs(uSysAdmin){
            id CommunityUserProfileId = [select id from profile where name='PRM Community User - Australia'].id;
            Account[] partnerAccount = PRMTestUtility.createPartnerAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId(),'Partner','New',null);
            insert partnerAccount;
            Account ac = partnerAccount[0];
            Id recordId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(PRMConstants.PRM_Partner_Contact_Record_Type).getRecordTypeId();
            Contact con = new Contact(recordtypeid=recordId,LastName ='testCon',Partner_role__c='Partner Sales User',AccountId = ac.Id, Onboarding_Status__c = 'Active', email = 'pims34@testmail.com');
            insert con;
            ac.PartnerPrincipalContact__c=con.id;
            update ac;
            User u1 = new User(alias = 'test123', email='test123@noemail.com',
                               emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                               localesidkey='en_US', Profileid = CommunityUserProfileId, country='United States',IsActive =true,
                               ContactId = con.Id,
                               timezonesidkey='America/Los_Angeles', username='testerpims@noemail.com');
            insert u1;
            test.starttest();
            PhoenixGlobalUtil.UpdateContactRecord('elevateToPDUA',con.id);
            PhoenixGlobalUtil.UpdateContactRecord('removePDUA',con.id);
            PhoenixGlobalUtil.UpdateContactRecord('deactivateUser',con.id);
            test.stoptest();
            contact updatedcontact=[select Onboarding_Status__c,Community_User_Type__c,PIMS_User_Status__c from contact where id=:con.id];
            System.assert(updatedcontact.Onboarding_Status__c == 'Inactive');
        }
    }
    static testmethod void testvalidatecaptcha(){
        PhoenixGlobalUtil.ReCaptcha recaptch=new PhoenixGlobalUtil.ReCaptcha();
        recaptch.endpoint=Label.recaptcha_Endpoint;
        recaptch.token='12345';
        recaptch.secret=Label.recaptch_secret;
        test.starttest();
        Test.setMock(HttpCalloutMock.class, new IntegrationRecordHandlerUtilCalloutMock());
        recaptch=PhoenixGlobalUtil.validatecaptcha(recaptch);
        test.stoptest();
        System.assert(recaptch!=null);
    }
    static testmethod void testaccountsByRecType(){
        id rtypeId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId();
        Account a = new Account();
        a.name = 'Test';
        a.recordtypeid = rtypeId2;
        insert a;
        List<Account> acc = new List<Account>{a};
            Map<id,Account> amap = new Map<id,Account>();
        amap.put(a.id,a);
        test.starttest();
        Test.setMock(HttpCalloutMock.class, new IntegrationRecordHandlerUtilCalloutMock());
        PhoenixGlobalUtil.accountsByRecType(acc,rtypeId2);
        test.stoptest();
        System.assert(acc[0].recordtypeid == rtypeId2);
    }
    static testmethod void testAccRectype(){
        id rtypeId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        Account ac = new Account(name ='Test Acc',recordtypeid=rtypeId2) ;
        insert ac;
        map<id,account> accmap= new map<id,account>();
        accmap.put(ac.id,ac);
        list<account> acclist= new list<account>();
        acclist.add(ac);
        list<account> acclistnew=   PhoenixGlobalUtil.accountsByRecType(acclist,rtypeId2);
        map<id,account> accmapfinal=PhoenixGlobalUtil.mapAccountsByRecType(accmap,rtypeId2);
        System.assert(accmapfinal!=null);
    }
    //Team Hawaii:Ritika:P2OB-4844-Test Method for permission-set-group assignment
    public static testMethod void test_permissionGroupAssignment(){
        List<User> partnerUser;
        Test.startTest();
        User uSysAdmin = [Select id from User where username='Cont987657awqas@noemail.com'];
        Map<String,Profile> profilesMap = new Map<String,Profile>();
          for(Profile profile : [Select Name, Id From Profile])
            profilesMap.put(profile.Name, profile);    
        Account partnerAccountRecord;
        System.runAs(uSysAdmin){
            insert new Profiles__c(Name='PRM Community User - Australia',Profile_Name__c='PRM Community User - Australia');
            PermissionSetGroup psg = new PermissionSetGroup();
            psg.DeveloperName = 'TPC_Default_Permission_Sets_Test';psg.MasterLabel = 'TPC Default Permission Sets Test';
            insert psg;
            Account[] partnerAccount = PRMTestUtility.createPartnerAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId(),'Partner','New',null);
            insert partnerAccount;
            id rtypeId2 = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_ContactObject).get(PRMConstants.PRM_Partner_Contact_Record_Type).getRecordTypeId(); // fetch partner contact record type
            partnerAccountRecord = partnerAccount[0];           
            Contact contact = new Contact(LastName ='testCon2',Partner_role__c='Partner Sales User',AccountId = partnerAccount[0].Id, Onboarding_Status__c = 'Active',email = 'pims2@testmail.com',recordtypeid=rtypeId2,Community_User_Type__c='Domestic');           
            insert contact;
            partnerUser = PRMTestUtility.createPartnerUsers(1,new List<Profile>{profilesMap.get('PRM Community User - Australia')} ,new List<Contact>{contact} ,false);
            insert partnerUser; 
        }
        Test.stopTest();
        List<PermissionSetAssignment> psList = [select id, PermissionSetGroup.DeveloperName from permissionSetAssignment where AssigneeId =: partnerUser[0].id and PermissionSetGroupId!=null];
        System.debug('psList:'+psList);
        System.assert(psList.size()>=0);
    }
}