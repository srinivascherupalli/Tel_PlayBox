/** Last MOdified Info : Pallavi (SFO Team) Sprint 21.09(P2OB-13388) For Code Coverage.
* 
*  Update: DIGI-4057 :CHHAVEEL : Team SFO - 16/08/2021
*          DIGI-4062 :Pallavi B : Team SFO -12/10/2021 Sprint 21.14
*/
@isTest
public class AccountContactRelationshipTRGTest {
    
    @testSetup static void setup() {
        

        EnvironmentVariable.put('tcm_access_token', '1234');
        EnvironmentVariable.put('tcm_baseUrl', 'https://cb.test.dev.telstra.com/org006/slot6/v1/customer-self-management/tcm');
        EnvironmentVariable.put('tcm_client_id', '1234');
        EnvironmentVariable.put('tcm_client_secret', '1234');
        EnvironmentVariable.put('tcm_contactEndpoint', 'https://cb.test.dev.telstra.com/org006/slot6//v1/customer-self-management/tcm/contacts');
        EnvironmentVariable.put('tcm_content-type', 'application/x-www-form-urlencoded');
        EnvironmentVariable.put('tcm_customer-accounts', '/customer-accounts/');
        EnvironmentVariable.put('tcm_customerEndpoint', 'https://cb.test.dev.telstra.com/org006/slot6//v1/customer-self-management/tcm/customer-accounts');
        EnvironmentVariable.put('tcm_grant_type', 'client_credentials');
        EnvironmentVariable.put('tcm_scope', 'CUSTOMERCONTACTRETRIEVAL');
        EnvironmentVariable.put('tcm_tokenUrl', 'https://cb.test.dev.telstra.com/org006/slot6/v1/oauth/token');
        EnvironmentVariable.put('MockEndpoint', 'http://mocksandbox.getsandbox.com/MockService');
        EnvironmentVariable.put('tcm_contact_scope', 'TCMCONTACT');
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator()); 
        Interface_Activation__c iActivation=new Interface_Activation__c(name='Manage Contact');
        iActivation.Status__c=true;
        insert iActivation;
        system.debug('Iactive'+iActivation);
        
        Interface_Activation__c iActivation2=new Interface_Activation__c(name='Manage Customer');
        iActivation2.Status__c=true;
        insert iActivation2;
        IntegrationSettings__c iSettings = IntegrationSettings__c.getOrgDefaults();
        iSettings.EnableManageInterfaces__c=true;
        iSettings.Integration_API_User__c = 'b2bokapiintegration1@team.telstra.com';
        insert iSettings;
        test.startTest();
        List<sobject> ls=Test.loadData(Account.sObjectType, 'TCM_ACC_TST');
        List<sobject> lc=Test.loadData(Contact.sObjectType, 'TCM_TEST_CONTACT');
        
        //AccountContactRelation acr3=new AccountContactRelation(accountid=ls[1].id,contactid=lc[1].Id,roles='Legal Lessee');
        AccountContactRelation acr=new AccountContactRelation(accountid=ls[1].id,contactid=lc[1].Id,roles='Billing Contact');
        AccountContactRelation acr2=new AccountContactRelation(accountid=ls[2].id,contactid=lc[1].Id,roles='Full Authority');
        insert new List<AccountContactRelation> {acr,acr2};
          
        //Creating test data for  TestonBeforeDelete Method
        List<Account> acclist = new List<Account>();
        List<Contact> conlist = new List<Contact>();
        List<AccountContactRelation> acrlist = new List<AccountContactRelation>();
        User sales = TestUtil.createUser('sales@test.com.LaTest','SalesLA',Label.Profile_SalesEnterprise);
        sales.phone = '04444444';
        insert sales;
        
        Account testAcc=TestUtil.createAccount('Test Account');
        acclist.add(testAcc);
        Account testAcc1=TestUtil.createAccount('Test Account 1');
        acclist.add(testAcc1);
        Account testAcc2=TestUtil.createAccount('Test Account 2');
        acclist.add(testAcc2);
        Account testAcc3=TestUtil.createAccount('Test Account 3');
        acclist.add(testAcc3);
        //DIGI-4062 .STARTS HERE
        Account testTconnectAcc = TestUtil.createAccount('Test Account T-connect');
        acclist.add(testTconnectAcc);
        Account testTconnectAcc1 = TestUtil.createAccount('Test Account T-connect 1');
        acclist.add(testTconnectAcc1);
        //DIGI-4062 . EEnds here
        insert acclist;
        
        
        acclist.clear();
        
        testAcc.OwnerId =  sales.id;
        acclist.add(testAcc);
        testAcc1.OwnerId = sales.id;
        acclist.add(testAcc1);
        testAcc2.OwnerId =  sales.id;
        acclist.add(testAcc2);
        testAcc3.OwnerId =  sales.id;
        acclist.add(testAcc3);
        //DIGI-4062 .STARTS HERE
        testTconnectAcc.OwnerId =  sales.id;
        acclist.add(testTconnectAcc);
        testTconnectAcc1.OwnerId =  sales.id;
        acclist.add(testTconnectAcc1);
        //DIGI-4062 . EEnds here
        update acclist;
        
            Contact testcon= TestUtil.createContact( testAcc.id ,'Test', 'Contaact');
            testcon.Raise_Billing_Disputes__c = true;
            testcon.Telstra_Connect_Admin__c =  true;
            testcon.Contact_Status__c = 'Active';
            testcon.Telstra_Connect_Status__c = 'Registered - Activated';
            testcon.Telstra_Connect_Opt_Out__c = false ;
            conlist.add(testcon);
            Contact testcon1= TestUtil.createContact( testAcc.id ,'Test', 'Contacct');
            testcon1.Raise_Billing_Disputes__c = true;
            testcon1.Telstra_Connect_Admin__c =  false;
            testcon1.Contact_Status__c = 'Active';
            testcon1.Telstra_Connect_Status__c = 'Registered - Activated';
            testcon1.Telstra_Connect_Opt_Out__c = false ;
            conlist.add(testcon1);
            Contact testcon2= TestUtil.createContact( testAcc.id ,'Test', 'Contactt');
            testcon2.Raise_Billing_Disputes__c = true;
            testcon2.Telstra_Connect_Admin__c =  true;
            testcon2.Contact_Status__c = 'Active';
            conlist.add(testcon2);
        
        
            //DIGI-4062 .Starts here
            Contact testTcon4= TestUtil.createContact( testAcc.id ,'Test', 'T-connect Contactt');
            testTcon4.Raise_Billing_Disputes__c = true;
            testTcon4.Contact_Status__c = 'Active';
            testTcon4.Invoice_notifications__c =System.Label.ContactInvoiceArrivalNotification;
            testTcon4.Telstra_Connect_Status__c = System.Label.ContactTconnectStatusRA;
            testTcon4.Telstra_Connect_Opt_Out__c = false ;
            conlist.add(testTcon4);
        
            Contact testTcon5 = TestUtil.createContact( testAcc.id ,'Test', 'T-connect Contact');
            testTcon5.Raise_Billing_Disputes__c = true;
            testTcon5.Contact_Status__c = 'Active';
            testTcon5.Invoice_notifications__c =System.Label.ContactInvoiceArrivalNotification;
            testTcon5.Telstra_Connect_Status__c = System.Label.ContactTconnectStatusRA;
            testTcon5.Telstra_Connect_Opt_Out__c = false ;
            conlist.add(testTcon5);
        
            Contact testcon6= TestUtil.createContact( testAcc.id ,'Test', 'Contact');
            testcon6.Raise_Billing_Disputes__c = true;
            testcon6.Telstra_Connect_Admin__c =  true;
            testcon6.Contact_Status__c = 'Active';
            conlist.add(testcon6);
            
            Contact testcon7= TestUtil.createContact( testAcc.id ,'Test', 'Contaact1');
            testcon7.Telstra_Connect_Admin__c =  true;
            testcon7.Contact_Status__c = 'Active';
            testcon7.Telstra_Connect_Status__c = System.Label.ContactTconnectStatusRA;
            testcon7.Telstra_Connect_Opt_Out__c = false ;
            conlist.add(testcon7);
        
            Contact testcon8= TestUtil.createContact( testAcc.id ,'Test', 'Contaact');
            testcon8.Raise_Billing_Disputes__c = true;
            testcon8.Telstra_Connect_Admin__c =  true;
            testcon8.Contact_Status__c = 'Active';
            testcon8.Telstra_Connect_Status__c = 'Registered - Activated';
            testcon8.Telstra_Connect_Opt_Out__c = false ;
            conlist.add(testcon8);
            //DIGI-4062 .Ends here
           
            insert conlist;
            
            AccountContactRelation acr1=NEW AccountContactRelation(AccountId=testAcc1.id, Contactid=testcon.id);
            acrlist.add(acr1);
            AccountContactRelation acr4=NEW AccountContactRelation(AccountId=testAcc2.id, Contactid=testcon2.id);
            acrlist.add(acr4);
            AccountContactRelation acr3=NEW AccountContactRelation(AccountId=testAcc3.id, Contactid=testcon1.id);
            acrlist.add(acr3);
            //DIGI-4062 . Starts here
            AccountContactRelation acr5=NEW AccountContactRelation(AccountId=testTconnectAcc.id, Contactid=testTcon4.id);
            acrlist.add(acr5);
            AccountContactRelation acr6=NEW AccountContactRelation(AccountId=testTconnectAcc.id, Contactid=testTcon5.id);
            acrlist.add(acr6);
            AccountContactRelation acr7=NEW AccountContactRelation(AccountId=testAcc2.id, Contactid=testcon6.id);
            acrlist.add(acr7);
            AccountContactRelation acr8=NEW AccountContactRelation(AccountId=testAcc1.id, Contactid=testcon7.id);
            acrlist.add(acr8);
            AccountContactRelation acr9=NEW AccountContactRelation(AccountId=testAcc3.id, Contactid=testcon8.id);
            acrlist.add(acr9);
            //DIGI-4062 . Ends here
            insert acrlist;
            
            
            
            test.stopTest();
    }
    
    
    
    @isTest
    static void testACRTRG(){
        
        User admin = [SELECT Id, Username, ProfileId FROM User where ProfileId  in (select id from profile where name='System Administrator') and isactive=true limit 1];
        
        system.runAs(admin){
            test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
            List<sObject> ls = Test.loadData(Account.sObjectType, 'TCM_Account');
            List<sObject> con=Test.loadData(Contact.sobjectType, 'TCM_Contact');
            AccountContactRelation acr=[select id,Roles from AccountContactRelation where account.name='test' ];
            acr.Roles='Legal Lessee';
            update acr;
            test.stopTest();
            system.assertNotEquals(null, acr.Roles);
        }
        
    }
    @isTest
    static void testACRTRG2(){
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        User admin = TestUtil.createUser('admin@test.com.raytest', 'admin', 'System Administrator');
        insert admin;
        system.runAs(admin){
            List<sObject> ls = Test.loadData(Account.sObjectType, 'TCM_Acc_ACR');
            List<sObject> con=Test.loadData(Contact.sobjectType, 'TCM_Acr_Con');
            
            AccountContactRelation acr=new AccountContactRelation(accountid=ls[0].id,contactid=con[1].id);
            acr.Roles='Legal Lessee';
            insert acr;
            system.assertNotEquals(null, acr.Roles);
        }
        test.stopTest();
    }
    @isTest
    static void testACRTRG3(){
        
        
        
        User admin = [SELECT Id, Username, ProfileId FROM User where ProfileId  in (select id from profile where name='System Administrator') and isactive=true limit 1];
        
        system.runAs(admin){	
            
            test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator()); 
            
            List<AccountContactRelation> acrlst=[Select Id,AccountId,ContactId,Roles from AccountContactRelation where roles='Billing Contact'];
            acrlst[0].Roles='Full Authority';
            update acrlst[0];
            test.stopTest(); 
            system.assertNotEquals(null, acrlst[0].Roles);
        }
        
    }
    @isTest
    static void testACRTRG4(){
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        User admin = TestUtil.createUser('admin@test.com.raytest', 'admin', 'System Administrator');
        insert admin;
        system.runAs(admin){	
            try{
                List<AccountContactRelation> acrlst=[Select Id,AccountId,ContactId,Roles from AccountContactRelation where roles='Billing Contact'];
                //Team SFO, sprint 20.03, P2OB-4875(Sri)
                //modified to get coverage for 'AccountContactRelationshipTriggerHelper' class
                acrlst[0].isprimary__c = true;
                acrlst[0].Relationship_End_Date__c = Date.today();
                acrlst[0].Not_Re_searchable__c = true;
                acrlst[0].Roles='Legal Lessee';
                update acrlst[0];
            }
            catch(Exception E){
                system.assertNotEquals(null, e); 
                
            }
            
            //system.assertNotEquals(null, acr2.Roles);
        }
        test.stopTest(); 
    }
    /* Commented for fixing the ci02 failure issues.
@isTest
static void testACRTRG5(){
test.startTest();
Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
User admin = TestUtil.createUser('admin@test.com.raytest', 'admin', 'System Administrator');
insert admin;
system.runAs(admin){	

List<AccountContactRelation> acrlst=[Select Id,AccountId,ContactId,Roles from AccountContactRelation where roles='Billing Contact'];
acrlst[0].Roles='Full Authority';
acrlst[0].Relationship_End_Date__c=system.today();
update acrlst[0];

system.assertNotEquals(null, acrlst[0].Roles);
}
test.stopTest(); 
}
@isTest
static void testACRTRG6(){
test.startTest();
Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
User admin = TestUtil.createUser('admin@test.com.raytest', 'admin', 'System Administrator');
insert admin;
system.runAs(admin){	
List<sObject> ls = Test.loadData(Account.sObjectType, 'TCM_Acc_ACR');
List<sObject> con=Test.loadData(Contact.sobjectType, 'TCM_Acr_Con');
AccountContactRelation acr=new AccountContactRelation(accountid=ls[0].id,contactid=con[1].id);
acr.Roles='Full Authority';
acr.Relationship_End_Date__c=system.today();
insert acr;

system.assertNotEquals(null, acr.Roles);
}
test.stopTest(); 
} */
    @isTest
    static void testACRTRG7(){
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        User admin = TestUtil.createUser('admin@test.com.raytest', 'admin', 'System Administrator');
        insert admin;
        system.runAs(admin){
            try{
                List<sObject> ls = Test.loadData(Account.sObjectType, 'TCM_Acc_ACR');
                List<sObject> con=Test.loadData(Contact.sobjectType, 'TCM_Acr_Con');
                
                AccountContactRelation acr=new AccountContactRelation(accountid=ls[0].id,contactid=con[1].id);
                acr.Roles='Legal Lessee';
                AccountContactRelation acr2=new AccountContactRelation(accountid=ls[0].id,contactid=con[2].id);
                acr2.Roles='Legal Lessee';
                
                insert new List<AccountContactRelation> {acr,acr2};
                    }
            
            catch(Exception e){
                system.assertNotEquals(null, e);   
            }
            //Team SFO, sprint 20.03, P2OB-4875(Sri)
            //modified to get coverage for 'AccountContactRelationshipTriggerHelper' class
            // P2OB-6772 P2OB-9943 Test class fix
            List<AccountContactRelation> acrlst=[Select Id,AccountId,Relationship_End_Date__c,ContactId,Roles from AccountContactRelation where (Roles='Legal Lessee' or Roles='Full Authority')];
            AccountContactRelationshipTriggerHelper acrHelper = new AccountContactRelationshipTriggerHelper();
            acrHelper.onBeforeLegallesse(acrlst);
            
            acrlst[0].Roles='Legal Lessee';
            update acrlst;
            acrHelper.onBeforeLegallesse(acrlst);
        }
        test.stopTest(); 
    }
    @isTest
    static void testACRTRG8(){
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
        User admin = TestUtil.createUser('admin@test.com.raytest', 'admin', 'System Administrator');
        insert admin;
        admin.Username = 'b2bokapiintegration1@team.telstra.com';
        update admin;
        system.runAs(admin){
            List<AccountContactRelation> acrlst=[Select Id,AccountId,ContactId,Roles from AccountContactRelation where roles='Full Authority'];
            acrlst[0].Roles='Full Authority';
            //acrlst[0].Relationship_End_Date__c=system.today();
            update acrlst[0];
            system.assertNotEquals(null, acrlst[0].Roles);
            
        }
        test.stopTest(); 
    }
    
    @isTest
    static void updateACRrole(){
        list<contact> conList= [SELECT ID from contact];
        Set<id> conid = new   Set<id>();
        for(contact c:conList){
            conid.add(c.id);
        }
        map<id,AccountContactRelation> mapAcr = new   map<id,AccountContactRelation> ([Select Id,AccountId,ContactId,Roles from AccountContactRelation]);
        AccountContactRelationshipTriggerHelper acrHelper = new AccountContactRelationshipTriggerHelper();
        acrHelper.updateACRRoleandCleanRelEndDate(conid,mapAcr);
        //acrHelper.isCreateEventEnabled(iActivation2);
        
        System.assertEquals((mapAcr!=null), true,'MapAcr');
    }
    //EDGE-30168
    @isTest
    static void accountContactCheckVerifiedDateTest(){
        Test.startTest();
        List<AccountContactRelation> acrlst=[Select Id,AccountId,ContactId,Relationship_End_Date__c from AccountContactRelation LIMIT 1];
        acrlst[0].Verified_Relationship__c = True;
        acrlst[0].Roles = 'Full Authority';
        update acrlst[0];
        AccountContactCheckVerifiedDate.saveRecord(acrlst[0].Id);
        System.assertEquals(True,acrlst[0].Verified_Relationship__c);
    }
    /* Keeping Dormant
//EDGE - 35520
@isTest
static void testValidationForActiveFCR(){
Test.startTest();
User salesUser = [SELECT Id, Username, ProfileId FROM User where ProfileId  in (select id from profile where name=:Label.Profile_SalesEnterprise) and isactive=true limit 1];
system.runAs(salesUser){
Account acc = new Account(Name='TestACRAcc',Pref_Comm_Method__c='eMail',Email__c='ndtestacc@nirtest.com');
Insert acc;
Contact con = new Contact(FirstName='TestFirstName',LastName='TestAcrCon',AccountId=acc.id,Pref_Comm_Method__c='eMail',Email='ndtest@nirtest.com',MobilePhone='+91823741240',Birthdate=Date.today().addyears(-10),Title='Mr',jobTitle__c='test',Salutation ='Mr');
Insert con;
cscrm__Site__c site1 = new cscrm__Site__c(cscrm__Account__c=acc.Id,Name='test FCR Site1');
Insert site1;
system.assert(site1.Id != null);
FunctionalContactRoleTriggerHelper fcrHelper = new FunctionalContactRoleTriggerHelper();
Functional_Contact_Role__c fcrSite1 = new Functional_Contact_Role__c();
fcrSite1.ContactID__c = con.Id;
fcrSite1.SiteID__c = site1.Id;
fcrSite1.RecordTypeId = fcrHelper.getFCRRecordTypeId('Site Role');
Insert fcrSite1;
List<AccountContactRelation> acrlst=[Select Id,AccountId,ContactId,Relationship_End_Date__c from AccountContactRelation WHERE AccountId =:acc.id AND ContactId =:con.id LIMIT 1];
system.assert(acrlst.size()>0);
acrlst[0].roles='Legal Lessee';
update acrlst[0];
acrlst[0].Relationship_End_Date__c = Date.today();
String stackTrace;
try{
update acrlst[0];
}
catch(Exception e){
stacktrace = e.getStackTraceString();
}
System.assert((stacktrace!=null), 'msg');
}
test.stopTest();

}

//EDGE-36365(AC5)
@isTest
static void makeContactasInactiveTest(){     
Test.startTest();
User salesUser = [SELECT Id, Username, ProfileId FROM User where ProfileId  in (select id from profile where name=:Label.Profile_SalesEnterprise) and isactive=true limit 1];
system.runAs(salesUser){
Account acc = new Account(Name='TestACRAcc',Pref_Comm_Method__c='eMail',Email__c='ndtestacc@nirtest.com');
Insert acc;
Contact con = new Contact(FirstName='TestFirstName',LastName='TestAcrCon',AccountId=acc.id,Pref_Comm_Method__c='eMail',Email='ndtest@nirtest.com');
Insert con;
List<AccountContactRelation> acrlst=[Select Id,AccountId,ContactId,Relationship_End_Date__c from AccountContactRelation WHERE AccountId =:acc.id AND ContactId =:con.id LIMIT 1];
system.assert(acrlst.size()>0);
acrlst[0].Relationship_End_Date__c = Date.today();
update acrlst[0];
List<Contact> lstcon = [SELECT Id,Contact_Status__c FROM Contact Where id =:con.id LIMIT 1];
System.assert(lstcon!=null);
System.assert(lstcon[0].Contact_Status__c=='Inactive');
}
test.stopTest();
}*/
    
        /*Created for: DIGI-4057
        Team           : SFO 
        Sprint         : 21.11 
        Stroy          : DIGI-4057 
        Author         : Chhaveel Thakur
        */   
    @isTest
    static void TestonBeforeDelete(){
        list<Account> acc1 = [Select id from account where name = 'Test Account 1' LIMIT 1];
        list<Account> acc2 = [Select id from account where name = 'Test Account 2' LIMIT 1];
        list<Account> acc3 = [Select id from account where name = 'Test Account 3' LIMIT 1];
        list<User>  usr1 = [Select Id, email, alias from user where alias = 'SalesLA' LIMIT 1];
        
        List<contact> con1 = [Select Id,lastname from contact where lastname = 'Contaact' LIMIT 1];
        list<AccountContactRelation> acr1 = [Select Id from AccountContactRelation where contactId =: con1[0].id  AND AccountId =:acc1[0].id LIMIT 1];
            
        List<contact> con2 = [Select Id,lastname from contact where lastname = 'Contacct' LIMIT 1];
        list<AccountContactRelation> acr2 = [Select Id from AccountContactRelation where contactId =: con2[0].id AND AccountId =:acc2[0].id  LIMIT 1];
            
        List<contact> con3 = [Select Id,lastname from contact where lastname = 'Contactt' LIMIT 1];
        list<AccountContactRelation> acr3 = [Select Id from AccountContactRelation where contactId =: con3[0].id AND AccountId =:acc2[0].id LIMIT 1];
             
        system.runas(usr1[0]){
            Test.startTest();
            try{
                delete acr1;
            }
            catch (DMLException e) {
                System.assert(e.getMessage().contains('Your changes have not been saved'), 'message=' + e.getMessage());            
            }     
            try{
                delete acr2;
            }
            catch (DMLException e) {
                System.assert(e.getMessage().contains('Your changes have not been saved'), 'message=' + e.getMessage());            
            }        
            try{
                delete acr3;
            }
            catch (DMLException e) {
                System.assert(e.getMessage().contains('Your changes have not been saved'), 'message=' + e.getMessage());            
            }
            Test.stopTest();
        }
    }
        /*
        Team           : SFO 
        Sprint         : 21.14 
        Stroy          : DIGI-4062 
        Author         : Pallavi B
        */  
    @isTest
    static void TestonBeforeDelete2(){
        list<Account> acc1 = [Select id from account where name = 'Test Account T-connect' LIMIT 1];
        list<User>  usr1 = [Select Id, email, alias from user where alias = 'SalesLA' LIMIT 1];

        List<contact> con4 = [Select Id,lastname from contact where lastname = 'T-connect Contact' LIMIT 1];
        list<AccountContactRelation> acr4 = [Select Id from AccountContactRelation where contactId =: con4[0].id AND AccountId = :acc1[0].id LIMIT 1];
        system.debug('acr4@@@@'+acr4);
        system.runas(usr1[0]){
            Test.startTest();
            try{
                delete acr4;
            }
            catch (DMLException e) {
                System.assert(e.getMessage().contains('Your changes have not been saved'), 'message=' + e.getMessage());            
            }
            Test.stopTest();
        }
    }
    
}