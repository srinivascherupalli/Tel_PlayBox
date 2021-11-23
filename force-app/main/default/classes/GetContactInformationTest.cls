/********************************************************************************************
@Class Name                 :   GetContactInformationTest
@Description                :   Sprint-19.03,EDGE-58913
@Date                       :   28th Feb, 2019
@Author                     :   Team SFO(Amar Chakka)
@Comments                   :   EditName Component On Contact, Server side Controller Test Class

@Last Modified By           :   
@Last Modified Date         :   
@Last Modified Comments     :   

*********************************************************************************************/
@isTest
public with sharing class GetContactInformationTest {
        @testSetup static void setup() {
        
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise]; //EDGE-85331 :: =:'Sales - Enterprise'];
        Profile pfAdmin = [select id from profile where name =:Label.Profile_SystemAdmin]; //EDGE-85331 :: =:'Sales - Enterprise'];
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        List<user> userList = new List<user>();
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',phone='+121231231234',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesuser@testsales.com');
        User admin = new User(alias = 'standt',email='adminuser@testadmin.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='TestingAdmin', languagelocalekey='en_US',localesidkey='en_US',phone='+121231231234',
                              profileid = pfAdmin.id,
                              timezonesidkey='Australia/Sydney',userroleid=r.id,
                              username='TestingAdmin@TestingAdmin.com');
        userList.add(sales);
        userList.add(admin);
        insert userList;
        System.runAs(admin){
            //Sprint 20.07 :P2OB-6382
            list<Account> acclist =new list<Account>();
            for(integer a=0;a<2;a++){
                Account customerAccount=TestUtil.createAccount('Testacc'+a);
                customerAccount.OwnerId=sales.id;
                acclist.add(customerAccount);
       }
            insert acclist;
            
            list<Contact> conlist =new list<Contact>();
            for(integer i=0;i<10;i++){
                Contact con1 = TestUtil.createContact(acclist[0].id,'First'+i,'Last'+i);
                con1.OwnerId=sales.id;
                conlist.add(con1);
       }
            insert conlist;
         //Sprint 20.07 :P2OB-6382, creating acr to view secondary contacts in account related list    
             list<AccountContactRelation> ACRlist =new list<AccountContactRelation>();
             for(Contact currentContact : conlist){
               AccountContactRelation ACR=new AccountContactRelation(Accountid=acclist[1].id,Contactid=currentContact.id, roles = System.Label.Contact_Limited_Authority_Value);
                ACRlist.add(ACR);
            }
            insert ACRlist;
            
            //EDGE-51592
         //   Account[] acc = PRMTestUtility.createPartnerAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId(),'Partner','New',null);
          //  insert acc; 
          //  acc[0].ispartner=true;
          //  update acc[0];
            
          //  Contact con = new Contact(LastName ='testCon',AccountId = acc[0].Id, Onboarding_Status__c = 'Active',Contact_Status__c='Active',Partner_Role__c='Telstra Collaboration Operations User;Engineering User');
          //  insert con; 
          //  Profile prmProfile = [select id from profile where name ='PRM Community User - Australia'];
          //  User[] partnerUser = PRMTestUtility.createPartnerUsers(1,new List<Profile>{prmProfile} ,new List<Contact>{con} ,false);
          //  insert partnerUser;
         
Account[] enterpriseAccount = PRMTestUtility.createAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Enterprise').getRecordTypeId());
            for(Account customACC : enterpriseAccount){
                customACC.Customer_Status__c = 'Active';
            }
            insert enterpriseAccount;
            
            List<Contact> customerContacts = PRMTestUtility.createContact(1,SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact_layout').getRecordTypeId(),enterpriseAccount.get(0).Id);
          
            insert customerContacts;
            for(contact cont:customerContacts){
                cont.Authority__c = 'Full Authority';
                cont.Contact_Status__c = 'Active';
                cont.MobilePhone = '+61123456789';
            }
            update customerContacts;
        
          
          //  Partner_of_Record__c POR = new Partner_of_Record__c(Customer__c=enterpriseAccount.get(0).Id, 
       //                                                         Partner__c=acc[0].Id,Partner_Signatories__c= con.Id,Status__c='Active',Customer_Signatories__c= customerContacts.get(0).Id); 
          //  insert POR;
            
         
        }
    }
    
// Test Class to cover Event Pulish On Account Insertion.
    @isTest
    static void  contactEditName(){
        try{
            test.starttest();
            Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
            User thisUser = [select id from user where id =: userinfo.getUserId()];
            system.runas(thisUser){
                User u = new User(Email='testuser@test.com.sample', 
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_AU', ProfileId = p.Id, 
                TimeZoneSidKey='Australia/Sydney',FederationIdentifier='D878586',username='UseT55145@noemail.com',alias = 'Use1T');
                insert u;
        
            
                id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Opp_RecordType_Enterprise).getRecordTypeId();
                Account testAcc = new Account(name = 'TestClassEvent',  CIDN__c = 'ASDF1234', recordTypeId = recordTypeId);
                list<Account> accLst = new list<Account>();
                accLst.add(testAcc);
                insert accLst;
        
                Contact testcon = new Contact();
                testcon.LastName = 'TestlastName';
                testcon.Pref_Comm_Method__c = 'email';
                testcon.salutation = 'Mr';
                testcon.FirstName = 'TestFirstName';
                testcon.MiddleName = 'TestMiddleName';
                insert testcon;
                GetContactInformation.getContactDetails(testcon.id);
            //  GetContactInformation.getRecordTypeId();
                //GetContactInformation.getContactDetails();
                //system.debug(Label.ContactFirstAndMiddleName);
                GetContactInformation.getRecordType(Label.ContactFirstAndMiddleName);
                GetContactInformation.getRecordType(Label.ContactLastName);
                GetContactInformation.getRecordType(Label.Name_Marriage_or_Divorce);
                GetContactInformation.getRecordType(Label.Name_Legal_Name_Change_Deed_Poll);
                GetContactInformation.getRecordType(Label.Name_Gender_Reassignment);
                system.assertEquals(accLst[0].name,'TestClassEvent');
           
            }
        test.stopTest();
        }catch(Exception Ex){
            system.debug('Exception:::: GetContactInformation Class:::: contactEditName Method'+ Ex.getMessage());
        }
    }
    
    @isTest
    static void  PORActiveTest(){
                test.starttest();
            Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
            User thisUser = [select id from user where id =: userinfo.getUserId()];
        User  partneruser;
        id prmAdmin = [select id from profile where name='PRM Admin - Australia'].id;
        Account ac = new Account(name ='TelecomAC',Account_Status__c = 'Active',PRM_Remaining_License__c=25);
        insert ac;  
        Contact con = new Contact(FirstName = 'Contact', LastName ='testCon',AccountId = ac.Id, Onboarding_Status__c = 'Active',PIMS_User_Status__c='User Created',PIMS_User_Type__c='TEG');
        insert con; 
        partneruser = new User(alias = 'test123', email='b2btestewwr@noemail.com',
                               emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                               localesidkey='en_US', Profileid = prmAdmin , country='United States',IsActive =true,
                               timezonesidkey='America/Los_Angeles', username='b2btestewwrpdua@noemail.com',contactid=con.id);
        insert partneruser;

        id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Opp_RecordType_Enterprise).getRecordTypeId();
        Account testAcc = new Account(name = 'TestClassEvent',  CIDN__c = 'ASDF1234', recordTypeId = recordTypeId,OwnerId=thisUser.Id);
        list<Account> accLst = new list<Account>();
        accLst.add(testAcc);
        insert accLst;
        
          id conrecordTypeId1 = SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact_layout').getRecordTypeId();
           
        System.runAs(partneruser){
     
        //  system.runas(thisUser){
            /*
                User u = new User(Email='testuser@test.com.sample', 
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_AU', ProfileId = p.Id, 
                TimeZoneSidKey='Australia/Sydney',FederationIdentifier='D878586',username='UseT55145@noemail.com',alias = 'Use1T');
                insert u;
        */
            // id conrecordTypeId1 = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact_layout').getRecordTypeId();
           
             id recordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Opp_RecordType_Enterprise).getRecordTypeId();
            //  Account testAcc = new Account(name = 'TestClassEvent',  CIDN__c = 'ASDF1234', recordTypeId = recordTypeId);
            //  list<Account> accLst = new list<Account>();
            //  accLst.add(testAcc);
            //  insert accLst;
                Account AccId = [select id from Account where RecordTypeId =:recordTypeId1 limit 1];
            
           //   List<Contact> customerContacts = PRMTestUtility.createContact(1,SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Contact_layout').getRecordTypeId(),AccId.Id);
          
            //insert customerContacts;
               Contact testcon = new Contact();
                testcon.LastName = 'TestlastName';
                testcon.AccountId=AccId.Id;
                testcon.recordTypeId= conrecordTypeId1;
                testcon.Pref_Comm_Method__c = 'email';
                testcon.salutation = 'Mr';
                testcon.email = 'test@testemail.com';
                testcon.FirstName = 'TestFirstName';
                testcon.MiddleName = 'TestMiddleName';
                insert testcon;
                GetContactInformation.getporofcontact(testcon.id);
                system.assertEquals(testcon.LastName,'TestlastName');
           
        
        test.stopTest();
        }
        
    }
    
    @isTest
    static void  contactEditNamePRM(){
        try{
            test.starttest();
            Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
            //User thisUser = [select id from user where id =: userinfo.getUserId()];
            
                    User  partneruser;
                    id prmAdmin = [select id from profile where name='PRM Admin - Australia'].id;
                    Account ac = new Account(name ='TelecomAC',Account_Status__c = 'Active',PRM_Remaining_License__c=25);
                    insert ac;  
                    Contact con = new Contact(FirstName = 'Contact', LastName ='testCon',AccountId = ac.Id, Onboarding_Status__c = 'Active',PIMS_User_Status__c='User Created',PIMS_User_Type__c='TEG');
                    insert con; 
                    partneruser = new User(alias = 'test123', email='b2btestewwr@noemail.com',
                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                    localesidkey='en_US', Profileid = prmAdmin , country='United States',IsActive =true,
                    timezonesidkey='America/Los_Angeles', username='b2btestewwrpdua@noemail.com',contactid=con.id);
                    insert partneruser;
                    
              //      System.runAs(partneruser){
                    
            //system.runas(thisUser){
                User u = new User(Email='testuser@test.com.sample', 
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_AU', ProfileId = p.Id, 
                TimeZoneSidKey='Australia/Sydney',FederationIdentifier='D878586',username='UseT55145@noemail.com',alias = 'Use1T');
                insert u;
        
            
                id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Opp_RecordType_Enterprise).getRecordTypeId();
                Account testAcc = new Account(name = 'TestClassEvent',  CIDN__c = 'ASDF1234', recordTypeId = recordTypeId);
                list<Account> accLst = new list<Account>();
                accLst.add(testAcc);
                insert accLst;
        
                Contact testcon = new Contact();
                testcon.LastName = 'TestlastName';
                testcon.Pref_Comm_Method__c = 'email';
                testcon.salutation = 'Mr';
                testcon.FirstName = 'TestFirstName';
                testcon.MiddleName = 'TestMiddleName';
                insert testcon;
                 String recid=testcon.Id;       
                GetContactInformation.getContactDetails(testcon.id);
            //  GetContactInformation.getRecordTypeId();
                //GetContactInformation.getContactDetails();
                //system.debug(Label.ContactFirstAndMiddleName);
                GetContactInformation.getRecordType(Label.ContactFirstAndMiddleName);
                String recordTypeIdlname=GetContactInformation.getRecordType(Label.ContactLastName);
                GetContactInformation.getRecordType(Label.Name_Marriage_or_Divorce);
                GetContactInformation.getRecordType(Label.Name_Legal_Name_Change_Deed_Poll);
                GetContactInformation.getRecordType(Label.Name_Gender_Reassignment);
                GetContactInformation.prmUpdateContactdetails('Changereason', 'NewFirstName', 'NewLastName', 'NewMiddleName', true, 'NewTitle', 'FirstName', 'MiddleName', 'LastName', 'Title', recordTypeIdlname, recid);
   
                system.assertEquals(accLst[0].name,'TestClassEvent');
           
            //}
        test.stopTest();
        }catch(Exception Ex){
            system.debug('Exception:::: GetContactInformation Class:::: contactEditName Method'+ Ex.getMessage());
        }
    }
}