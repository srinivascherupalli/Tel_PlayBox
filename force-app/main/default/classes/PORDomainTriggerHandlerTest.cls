@isTest
public with sharing class PORDomainTriggerHandlerTest {
    static final String CONTACT_EMAIL = 'test@tester.com';
    static final String CONTACTPRM_EMAIL = 'testPartner@tester.com';
    static final String SYSADMIN = 'System Administrator';

    @TestSetup
    static void testData(){
        Id profileId = [Select Id from Profile where Name=:SYSADMIN].Id;
        Id partnerProfileId = [select id from profile where name=:System.label.PRM_Community_User].id;
        Id userRoleId = createUserRole('TestPartner').Id;
        User systemAdminUser = createUser(profileId,CONTACT_EMAIL,'testAdmin');
        systemAdminUser.UserRoleId=userRoleId;
        Database.insert(systemAdminUser);
        List<Account> accList = new List<Account>();
        List<Contact> conList = new List<Contact>();
        System.runAs(systemAdminUser){
            accList.add(new Account(Name='Test Account'));
            accList.add(new Account(Name='Partner Account'));
            Database.insert(accList);
            conList.add(new Contact(LastName='TestContact',Email=CONTACT_EMAIL));
            conList.add(new Contact(LastName='TestPartnerContact',Email=CONTACTPRM_EMAIL));
            Database.insert(conList);            
        }
        Account testAccount = [Select Id from Account where Name='Test Account'];
        Account testPRMAccount = [Select Id from Account where Name='Partner Account'];
        Contact testContact = [Select Id from Contact where Email=:CONTACT_EMAIL];
        
        
        System.runAs(systemAdminUser){
            testContact.AccountId = testAccount.Id;
            testContact.Contact_Status__c = 'Active';
            testContact.Authority__c = 'Full Authority';
            Update testContact;
            Contact testPRMContact = [Select Id from Contact where Email=:CONTACTPRM_EMAIL];
            testPRMContact.AccountId=testPRMAccount.Id;
            testPRMContact.Onboarding_Status__c = 'Active';
            Update testPRMContact;
            Partner_of_Record__c testPORRecord = createPOR(testAccount.Id,testContact.Id,testPRMAccount.Id,testPRMContact.Id,'Active');
            Database.insert(testPORRecord);

            List<Partner_of_Record_Domain__c> domainList = new List<Partner_of_Record_Domain__c>();
            domainList.add(new Partner_of_Record_Domain__c(Partner_of_Record__c = testPORRecord.Id,Status__c='Active',Domain_Name__c='Mobile'));
            domainList.add(new Partner_of_Record_Domain__c(Partner_of_Record__c = testPORRecord.Id,Status__c='Cancelled',Sub_Status__c='Cancelled',Domain_Name__c='Data and IP'));
            domainList.add(new Partner_of_Record_Domain__c(Partner_of_Record__c = testPORRecord.Id,Status__c='Active',Sub_Status__c='Partner Review',Domain_Name__c='NAS'));
            Database.insert(domainList);
        }
    }


    @isTest static void testProductDomainOnUpdateToActive(){
        Partner_of_Record_Domain__c porDomain = [SELECT Id,Domain_Name__c,Partner_of_Record__c, Sub_Status__c, Status__c from Partner_of_Record_Domain__c where Status__c = 'Cancelled' LIMIT 1];
        porDomain.status__c = 'Active';
        Database.update(porDomain);
        Partner_of_Record__c porRecord = [SELECT Id,TLS_ProductDomain__c from Partner_of_Record__c where Id=:porDomain.Partner_of_Record__c];
        System.assertEquals('Mobile,Data and IP,NAS',porRecord.TLS_ProductDomain__c,'Check on updating to Active for a BLANK product domain value');
    }

    @isTest static void testExistingDomainOnUpdateToActive(){
        Partner_of_Record__c porExistingRecord = [Select Id,TLS_ProductDomain__c from Partner_of_Record__c];
        porExistingRecord.TLS_ProductDomain__c = 'Mobile,Data and IP,NAS';
        Database.update(porExistingRecord);
        Partner_of_Record_Domain__c porDomain = [SELECT Id,Domain_Name__c,Partner_of_Record__c, Sub_Status__c, Status__c from Partner_of_Record_Domain__c where Status__c = 'Cancelled' LIMIT 1];
        porDomain.status__c = 'Active';
        Database.update(porDomain);
        Partner_of_Record__c porRecord = [SELECT Id,TLS_ProductDomain__c from Partner_of_Record__c where Id=:porDomain.Partner_of_Record__c];

        System.assertEquals(porExistingRecord.TLS_ProductDomain__c,porRecord.TLS_ProductDomain__c,'Check on updating to Active for a Existing product domain value');

    }

    @isTest static void testExistingDomainOnUpdateToCancelled(){
        Partner_of_Record__c porExistingRecord = [Select Id,TLS_ProductDomain__c from Partner_of_Record__c];
        porExistingRecord.TLS_ProductDomain__c = 'Mobile;Data and IP';
        Database.update(porExistingRecord);
        Partner_of_Record_Domain__c porDomain = [SELECT Id,Domain_Name__c,Partner_of_Record__c, Sub_Status__c, Status__c from Partner_of_Record_Domain__c where Domain_Name__c = 'Mobile' LIMIT 1];
        porDomain.status__c = 'Cancelled';
        Database.update(porDomain);
        Partner_of_Record__c porRecord = [SELECT Id,TLS_ProductDomain__c from Partner_of_Record__c where Id=:porDomain.Partner_of_Record__c];
        System.assertNotEquals(porExistingRecord.TLS_ProductDomain__c,porRecord.TLS_ProductDomain__c,'Check on updating to Cancelled for a Existing product domain value');
    }
    /**
	* This method creates POR
	*
    * @param    AccountId      AccountId
    * @param    AccountContact ContactId
    * @param    PartnerId      PartnerId
    * @param    PartnerContact PartnerContactId
	* @return   POR    		   instance of POR object
    */
    public static Partner_of_Record__c createPOR(Id AccountId,Id AccountContact,Id PartnerId, Id PartnerContact,String Status) {
        Partner_of_Record__c porObj = new Partner_of_Record__c();
        porObj.Customer__c = AccountId;
        porObj.Customer_Signatories__c = AccountContact;
        porObj.Partner__c = PartnerId;
        porObj.Partner_Signatories__c = PartnerContact;
        porObj.Status__c = Status;
        return porObj;
    }
    /**
	* This method creates User
	*
    * @param    ProfileId      ProfileId
    * @param    Email          Email
    * @param    LastName       LastName
	* @return   User  		   instance of User object
    */
    public static User createUser(Id profileId, String email,String lastName){
        User userObj = new User(Email=email, LastName=lastName , alias = lastName.substring(0,4),timezonesidkey='America/Los_Angeles',languagelocalekey='en_US',
                                localesidkey='en_US',emailencodingkey='UTF-8',ProfileId= profileId);
        userObj.UserName= CONTACT_EMAIL+Integer.valueof((Math.random() * 100));

        return userObj;
    }

    public static UserRole createUserRole(String roleName) {
        UserRole usrRoleObj = new UserRole();
        usrRoleObj.Name = roleName;
        usrRoleObj.DeveloperName = roleName;
        Database.insert(usrRoleObj);
        return usrRoleObj;
    }
}