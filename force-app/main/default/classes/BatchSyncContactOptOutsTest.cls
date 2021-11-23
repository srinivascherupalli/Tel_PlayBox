/*******************************************************************
@Class Name		:BatchSyncContactOptOutsTest
@Sprint 		:21.08  & P2OB-13388
@Author			:SFO Team (Pallavi B)
@CreateDate		: 21/06/2021
@description	: Test class for BatchSyncContactOptOuts.
@Last Modified	: 
*********************************************************************/
@isTest
public class BatchSyncContactOptOutsTest {
    Contact objCon;
     List<ApplicationLog__c> lstApplicationLog = new List<ApplicationLog__c>();
/*******************************************************************
    @Method Name    :   setup
    @Sprint         :   21.09 & P2OB-13388
    @Author         :   SFO Team (Pallavi B)
    @CreateDate     :   21-06-2021
    @TestCoverage   :   Coverage for BatchSyncContactOptOuts
    @Description    :   Set up method .. created user, required account and contact records
    @Last Modified Info :   
*********************************************************************/
    @testSetUp
    static void setup() {
        List<user> userList = new List<user>();
        Profile pfAdmin = [select id from profile where name =:Label.Profile_SystemAdmin];
        User admin = new User(alias = 'standt',email='adminuser@testadmin.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='TestingAdmin', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pfAdmin.id,
                              timezonesidkey='Australia/Sydney',
                              username='TestingAdmin@TestingAdmin.com');
        userList.add(admin);
        insert userList;
        List<Contact> conts = new List<Contact>();
        List<Contact> contacts = new List<Contact>();
        List<Contact> errcontacts = new List<Contact>();
        List<Account> accounts = new List<Account>();
        List<Account> retiredaccounts = new List<Account>();
        System.runAs(admin){
            //Insert Accounts
            for(Integer i=0;i<10;i++){
            Account objAcc = TestUtil.createAccount('Testacc Channel'+i);
            accounts.add(objAcc);
            }
            insert accounts;
            
            //Inserting accounts to check for application log.
            for(Integer i=0;i<10;i++){
            Account retiredAcc = TestUtil.createAccount('Testacc Channel1'+i);
            retiredaccounts.add(retiredAcc);
            }
            insert retiredaccounts;
            
            //Insert Contacts
            for(Integer i=0;i<10;i++){
             Contact errCon = TestUtil.createContact(retiredaccounts[i].id,'firstname'+i,'lastname'+i); 
             errcontacts.add(errCon);
            }
            insert errcontacts;
            
            for(Integer i=0;i<10;i++){
             Contact objCon = TestUtil.createContact(accounts[i].id,'fname'+i,'lname'+i); 
             conts.add(objCon);
            }
            insert conts;
            
            for(Integer i=0;i<10;i++){
             Contact objCons = TestUtil.createContact('fnames'+i,'lnames'+i); 
             objCons.Email ='test@infosys.com';
             objCons.Opt_Out_Emails__c = false;
             contacts.add(objCons);
            }
          insert contacts;
         //contacts with same email and updating opt out sms true
        Contact con  = [select id,Opt_Out_SMS_MMS__c,Phone from Contact where FirstName = 'fname1'];
        con.Opt_Out_SMS_MMS__c = True;
        Update con;
            
        //contacts with same email and opt out emails true       
        Contact cons  = [select id,Opt_Out_Emails__c from Contact where FirstName = 'fnames1'];
        cons.Opt_Out_Emails__c = True;
        Update cons;
            
        //contacts with same email and related to retired accounts    
        Contact errcons  = [select id,Opt_Out_Emails__c from Contact where FirstName = 'firstname1'];
        errcons.Opt_Out_Emails__c = True;
        Update errcons;
         
        //Updating Account status to retired to cover negative scenario
        Account objAcc = [Select id,Customer_Status__c from Account where id = :retiredaccounts[0].id];  
        objAcc.Customer_Status__c = 'Retired';
        update objAcc;
		}
	}
    
    /*******************************************************************
    @Method Name    :   batchSynchContacts
    @Sprint         :   21.09 & P2OB-13388
    @Author         :   SFO Team (Pallavi B)
    @CreateDate     :   21-06-2021
    @TestCoverage   :   Coverage for BatchSyncContactOptOuts
    @Description    :   Method to call batch class.
    @Last Modified Info :   
    *********************************************************************/   
         @isTest
		static void batchSynchContacts() {
        List<Contact> lstcon = [SELECT Id, Opt_Out_SMS_MMS__c, Opt_Out_Emails__c, Email, Phone, MobilePhone FROM Contact WHERE SystemModStamp >= LAST_N_DAYS:7 AND (Opt_Out_SMS_MMS__c = True OR Opt_Out_Emails__c = True) AND Contact_Status__c = 'Active'];
        
        Test.startTest();
        BatchSyncContactOptOuts batchSynchContact = new BatchSyncContactOptOuts();
        Database.executeBatch(batchSynchContact);
        Test.stopTest();
        // after the testing stops, assert records were updated properly
    }
    
}