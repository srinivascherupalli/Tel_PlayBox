/*
AUTHOR : Lok Jackson
DESCRIPTION : Covers test coverage for Account Trigger
@LastModified:  Modified by Sri, team SFO on 16/01/2020 
P2OB-4278: Addded 'Imported__c = True'  to bypass the validation rule 'SalesUsers_not_allowed_to_Import_Accs' on account creation  
@LastModified:  Modified by Ravi, team Hawaii on 23/01/2020 
P2OB - 4275 implemented validation rule : Primary_Distributor_is_must_for_Nominate account 
Modified By: Team Hawaii
Modified Date : 17/3/2030
Description : Modified only test data to fix test class failure due to introduction
of validation rule on contact object
Key Note : Partner Contact record type of contact only use to create contact which is associated to partner user.
Jira : P2OB-5160

Modified Date : 3/6/2020
Des : Remove role creation to avoid maximum role creation error
Jira No : P2OB-6527 & P2OB-6037
Date : 5/6/2020

@Last Modified      : 
No.       Developer Name      Date            Story Description 
********************************************************************************
1.        Pallavi(SFO)      13/09/2021     Sprint 21.13 - DIGI-8909 Created methods:testsendChatterNotesOnPortCodeChange
2.        Sri(SFO)		    23/09/2021     Sprint 21.13 - DIGI-15107 implemented a mehtod updateManualNoSellCreditHealthTest
3.                                         Just Sending for contact trigger helper code coverage for DIGI-3444.

*******************************************************************************/

//TODO: Currently there are pre-existing methods on the Account Trigger without full coverage - this class should be extended with extra methods to handle this
@isTest
public class AccountTriggerTest  {
    @testSetup static void setup() {
        UserRole r = [Select id,DeveloperName From UserRole where DeveloperName = 'Sales_Ops' limit 1];
        profile pSysAdmin = [select id,name from Profile where Name =:'System Administrator'];
        id rtypeId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId(); 
        List<User> userList = new List<User>();
        User uSysAdmin = new User(alias = 'Con123', email='ContactTr8wrw98@noemail.com',
                                  emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                  localesidkey='en_US', profileid =pSysAdmin.id, country='United States',IsActive =true,                
                                  timezonesidkey='America/Los_Angeles', username='Cont987657awqas@noemail.com', userroleid=r.id);
        userList.add(uSysAdmin);
        
        //Setup users to assign to the territories, setup admin user to run as
        User user1 = TestUtil.createUser('test1@test.com.portfoliotestassign', 'test1', System.Label.Profile_SalesEnterprise); //EDGE-85331 :: 'Sales - Enterprise');
        User user2 = TestUtil.createUser('test2@test.com.portfoliotestassign', 'test2', System.Label.Profile_SalesEnterprise); //EDGE-85331 :: 'Sales - Enterprise');
        User admin = TestUtil.createUser('admin@test.com.portfoliotestassign', 'admin', 'System Administrator');
        user1.Phone='+911231231234';
        user2.Phone='+911231231234';
        
        userList.add(user1);
        userList.add(user2);
        userList.add(admin);
        
        insert userList;
        
        //Setup Portfolio Territories (assumes existing model and type are in place)
        List<Territory2> territories = TestUtil.createPortfolioTerritories('TestModel', new List<String>{'ABC', 'XYZ'});
        insert territories;
        
        //Allocate users to portfolio codes (territories) as owner
        List<UserTerritory2Association> uTAList = new List<UserTerritory2Association>();
        UserTerritory2Association uta1 = new UserTerritory2Association(UserId = user1.Id, Territory2Id = territories[0].Id, RoleInTerritory2 = 'Owner');
        UserTerritory2Association uta2 = new UserTerritory2Association(UserId = user2.Id, Territory2Id = territories[1].Id, RoleInTerritory2 = 'Owner');
        uTAList.add(uta1);
        uTAList.add(uta2);
        insert uTAList;
        
        
        System.runAs(uSysAdmin){
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
            Interface_Activation__c iActivation=new Interface_Activation__c(name='Manage Contact');
            iActivation.Status__c=true;
            insert iActivation;
            Interface_Activation__c iActivation2=new Interface_Activation__c(name='Manage Customer');
            iActivation2.Status__c=true;
            insert iActivation2;
            IntegrationSettings__c iSettings = IntegrationSettings__c.getOrgDefaults();
            iSettings.EnableManageInterfaces__c=true;
            insert iSettings;
            List<Account> ls = Test.loadData(Account.sObjectType, 'TCM_Account');
            //EDGE-27948: Feature flagging the process builder logic which moved to trigger 
            Interface_Activation__c iActivationProcBuild = new Interface_Activation__c(Name='PROCESS_BUILDER',Status__c=true);
            Insert iActivationProcBuild;
            insert new EnvironmentVariable__c(Name='massl_certificate_name',Value__c = 'telstrab2b_sandbox');   
            
            //for P2OB - 4275 implemented validation rule : Primary_Distributor_is_must_for_Nominate
            Account accdis2 = new Account(Name = 'Test Accountdit2',Partner_Type__c='Distributor',customer_status__c = 'ACTIVE');
            insert accdis2;
            System.assertEquals(accdis2.Name, 'Test Accountdit2');
            list<account> acclist= new list<account>();
            list<Contact> conlist= new list<Contact>();
            Account ac1 = new Account(name ='TestAccManagePIMSTest',Account_Status__c = 'Pending Activation',recordtypeid=rtypeId2,Imported__c = true,customer_ID__c = '345528');
            acclist.add(ac1);
            Account ac = new Account(name ='TestAccManagePIMSTest2',Account_Status__c = PRMConstants.PRM_Account_Status_Frozen);
            acclist.add(ac);        
            Account ac2 = new Account(name ='TestAccManagePIMSTest3',Account_Status__c = 'New', Telstra_Online_Service_Agreement__c = true);
            acclist.add(ac2);
            Account ac3 = new Account(Name='TestAccManagePIMSTest4',Overall_Accreditation__c='Silver', Telstra_Online_Service_Agreement__c = True,Partner_Type__c = 'Nominate',recordtypeid=rtypeId2,Primary_Distributor__c=accdis2.id);
            acclist.add(ac3);   
            Account ac4 = new Account(Name='TestOverallAccreditationrec1', Telstra_Online_Service_Agreement__c = True,Partner_Type__c = 'Nominate',recordtypeid=rtypeId2,Overall_Accreditation__c='Platinum',Primary_Distributor__c=accdis2.id);
            acclist.add(ac4); 
            Account ac5 = AccountTestFactory.buildAccount('Test Account PartnerRole') ;
            acclist.add(ac5);
            Account testTosaAcc = new Account(Name='testTosaAcc',Telstra_Online_Service_Agreement__c = True,Partner_Type__c = 'Nominate',Overall_Accreditation__c='Platinum',Pref_Comm_Method__c ='B2B',Phone='0412354323',recordtypeid=rtypeId2,Primary_Distributor__c=accdis2.id);
            acclist.add(testTosaAcc);    
            Account acc = new Account(name ='TelecomAC',Account_Status__c = 'Active',PRM_Remaining_License__c=25);
            acclist.add(acc); 
            Account acc1 = new Account(name ='TelecomAC1',Account_Status__c = 'New',Overall_Accreditation__c='Platinum');
            acclist.add(acc1); 
            Account accter1 = TestUtil.createAccount('Test Account 1 testAccountAndOpptyAssignment');
            Account accter2 = TestUtil.createAccount('Test Account 2 testAccountAndOpptyAssignment');
            Account accter3 = TestUtil.createAccount('Test Account 3 testAccountAndOpptyAssignment');
            accter1.Portfolio_Code__c = 'ABC';
            accter2.Portfolio_Code__c = 'XYZ';
            accter3.Portfolio_Code__c = 'XYZ';
            acclist.add(accter1); 
            acclist.add(accter2); 
            acclist.add(accter3); 
            //adding to use in updateManualNoSellCreditHealthTest
            Account customerAccount = TestUtil.createAccount('customerAccount');
            customerAccount.OwnerId = user1.id;
            acclist.add(customerAccount); 
            
            
            cscrm__Address__c add=TestUtil.createAddress();
            add.Sub_Address1_Type__c = 'Bourke';
            add.Sub_Address2_Type__c = 'Spencers';
            add.Sub_Address_3_Type__c = '12353';
            add.Sub_Address_4_Type__c = '363863';
            add.Sub_Address1_Number__c='11';
            add.Sub_Address2_Number__c='11';
            add.Sub_Address_3_Number__c='11';
            add.Sub_Address_4_Number__c='11';
            add.cscrm__Building_Name__c='test';
            insert add;
            Account acctest = TestUtil.createAccount('PrimaryAddressAccount');
            //acctest.AAR_to_Account__c = FALSE;
            acctest.Primary_Address__c = add.id;
            acctest.Customer_Last_Verified_Date__c=null;
            acclist.add(acctest);
            
            Account acctAtm = TestUtil.createAccount('AccountTeamMember1');
            acctAtm.Portfolio_Code__c = 'SAT01';
            acclist.add(acctAtm);
            
            Test.startTest();
            insert acclist; 
            Test.stopTest();
            id recType = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_ContactObject).get(PRMConstants.PRM_Partner_Contact_Record_Type).getRecordTypeId();  // fetch partner contact record type           
            Contact con = new Contact(LastName ='testCon',AccountId = acc.Id, Onboarding_Status__c = 'Active',PIMS_User_Type__c='TEG',OTP_Mobile_Phone_Number__c = '+911234567891',Community_User_Type__c='Domestic');
            conlist.add(con);
            Contact con1 = new Contact(LastName ='testCon1',AccountId = acc1.Id, Onboarding_Status__c = 'Active',PIMS_User_Type__c='TEG',OTP_Mobile_Phone_Number__c='+911234567890',Community_User_Type__c='Domestic');
            conlist.add(con1);
            Contact con2 = new Contact(RecordTypeId=recType,LastName ='testCon2',AccountId = ac4.Id, Onboarding_Status__c = 'Active',PIMS_User_Type__c='TEG',OTP_Mobile_Phone_Number__c='+911234567890',Community_User_Type__c='Domestic'); // Hawaii
            conlist.add(con2);
            insert conlist;
            
            Portfolio_Code__c portcode = TestUtil.createPortfolioCode('ABC');
            portcode.Tier__c ='Mid Market';
            insert portcode;
            //Added as part of DIGI-8909 Sprint SFO 21.13   
            List<FeatureToggle__mdt> ftmList = new List<FeatureToggle__mdt>();
            FeatureToggle__mdt ftm = new FeatureToggle__mdt();
            ftm.Additional_Logic__c = uSysAdmin.email;
            ftmList.add(ftm);
            
            List<AccountTeamMember> lstAtm = new List<AccountTeamMember>();
            AccountTeamMember atm1 = new AccountTeamMember();
            atm1.AccountId = acctAtm.Id;
            atm1.TeamMemberRole = System.Label.AccountTeamMemberOpportunityApprover;
            atm1.UserId = admin.Id;
            insert atm1;
            lstAtm.add(atm1); //ends here :: DIGI-8909 Sprint SFO 21.13      
        }  
    }
    @isTest
    static void testAccountAndOpptyAssignmentonUpdate(){
        //Covers auto assignment of Accounts and child Opportunities based on Portfolio Code owner
        //Includes coverage of methods updateAccountOwner and updateOpportunityOwner
        Test.startTest();
        User admin = [SELECT id from User WHERE username = 'admin@test.com.portfoliotestassign' LIMIT 1];
        Account acc1 =[select id,Owner.alias from Account where Name = 'Test Account 1 testAccountAndOpptyAssignment' limit 1];
        Account acc2 =[select id,Owner.alias from Account where Name = 'Test Account 2 testAccountAndOpptyAssignment' limit 1];
        Account acc3 =[select id,Owner.alias from Account where Name = 'Test Account 3 testAccountAndOpptyAssignment' limit 1];
        //Swap Port Codes
        System.runAs(admin){
            acc1.Portfolio_Code__c = 'XYZ';
            acc2.Portfolio_Code__c = 'ABC';
            acc3.Portfolio_Code__c = 'ABC';
            
            List<Account> accountUpdateList = new List<Account>{acc1, acc2, acc3};
                update accountUpdateList;
            //Confirm that Account and associated open Opportunity has been transferred to owner of new portfolio
            System.assertEquals('test2', [select Owner.alias from Account where Id = :acc1.Id limit 1].Owner.alias);
            //System.assertEquals('test2', [select Owner.alias from Opportunity where Id = :o1.Id limit 1].Owner.alias);
            //Confirm that Account and associated open Opportunity has been transferred to owner of new portfolio
            System.assertEquals('test1', [select Owner.alias from Account where Id = :acc2.Id limit 1].Owner.alias);
            System.assertEquals('test1', [select Owner.alias from Account where Id = :acc3.Id limit 1].Owner.alias);
            //System.assertEquals('test1', [select Owner.alias from Opportunity where Id = :o2.Id limit 1].Owner.alias);
            // Confirm that closed Opportunity was not transferred
            //System.assertNotEquals('test1', [select Owner.alias from Opportunity where Id = :o3.Id limit 1].Owner.alias);
        }
        Test.stopTest();
    }
    @isTest
    static void testfieldidentifiermethod(){
        Test.startTest();
        User admin = TestUtil.createUser('admin@test.com.raytest', 'admin', 'System Administrator');
        insert admin;
        system.runAs(admin){
            Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
            List<Account> ls=[select id,ABN__C,customer_ID__c,Imported__c from Account where name='test'];
            List<Monitored_Field__mdt> objectTypeFields = [select Id, Field_API_Name__c,QualifiedApiName,DeveloperName,Object_Field_Monitor__r.DeveloperName,Object_Field_Monitor__r.Active__c from Monitored_Field__mdt where Object_Field_Monitor__r.DeveloperName='Account' and Object_Field_Monitor__r.Active__c=true and test_data__c=true];
            if(objectTypeFields!=null && objectTypeFields.size()!=0){
                TestDataCheck.datacheck=true;
            }
            else
                TestDataCheck.datacheck=false;
            ls[0].ABN__c='123456';
            update ls;
            system.assertNotEquals(Null, ls[0].ABN__c);    
        }
        TestRun.Uirun = false;
        Test.stopTest();
    }
    // Added this method to cover recordUpdate method in AccountTriggerHandler
    @isTest
    static void testfieldidentifiermethodAccountUpdate(){
        Test.startTest();
        User admin = TestUtil.createUser('admin@test.com.raytest', 'admin', 'System Administrator');
        insert admin;
        system.runAs(admin){
            Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
            List<Account> ls=[select id,ABN__C,customer_ID__c from Account where name='test'];
            List<Monitored_Field__mdt> objectTypeFields = [select Id, Field_API_Name__c,QualifiedApiName,DeveloperName,Object_Field_Monitor__r.DeveloperName,Object_Field_Monitor__r.Active__c from Monitored_Field__mdt where Object_Field_Monitor__r.DeveloperName='Account' and Object_Field_Monitor__r.Active__c=true and test_data__c=true];
            if(objectTypeFields!=null && objectTypeFields.size()!=0){
                TestDataCheck.datacheck=true;
            }
            else
                TestDataCheck.datacheck=false;
            ls[0].ABN__c='123456';
            ls[0].customer_ID__c = '345346';
            update ls;
            system.assertNotEquals(Null, ls[0].ABN__c);  
            //  delete  ls[0];
        }
        Test.stopTest();
    }
    // Added this method to cover overridingActionTemporaryly method in AccountTriggerHandler
    @isTest
    static void testfieldidentifiermethodoverrideAction(){
        Test.startTest();
        User admin = TestUtil.createUser('admin@test.com.raytest', 'admin', 'System Administrator');
        insert admin;
        system.runAs(admin){
            Test.setMock(HttpCalloutMock.class, new MockTCMHttpResponseGenerator());
            List<Account> ls=[select id,ABN__C,customer_ID__c,Send_Create_Event__c from Account where name='test'];
            List<Monitored_Field__mdt> objectTypeFields = [select Id, Field_API_Name__c,QualifiedApiName,DeveloperName,Object_Field_Monitor__r.DeveloperName,Object_Field_Monitor__r.Active__c from Monitored_Field__mdt where Object_Field_Monitor__r.DeveloperName='Account' and Object_Field_Monitor__r.Active__c=true and test_data__c=true];
            if(objectTypeFields!=null && objectTypeFields.size()!=0){
                TestDataCheck.datacheck=true;
            }
            else
                TestDataCheck.datacheck=false;
            ls[0].ABN__c='123456';
            ls[0].Imported__c = true;
            ls[0].customer_ID__c = '34534667';
            ls[0].Send_Create_Event__c = true;
            update ls;
            system.assertNotEquals(Null, ls[0].ABN__c);    
        }
        Test.stopTest();
    }
    //EDGE-27948
    @isTest
    static void testAccountVerified(){
        Test.startTest();
        Account testAcc1 = new Account(Name='testAcc',Customer_Last_Verified_Date__c = Date.today().addDays(250));
        Insert testAcc1;
        Account newTestAcc = [SELECT Id,Reviewed_Account__c FROM Account WHERE id =:testAcc1.Id];
        system.assert(newTestAcc.id != null && newTestAcc.Reviewed_Account__c);
        Account testAcc2 = new Account(Name='testAcc',Customer_Last_Verified_Date__c = Date.today().addDays(400));
        Insert testAcc2;
        system.assert(testAcc2.id != null && !testAcc2.Reviewed_Account__c );
        testAcc2.Customer_Last_Verified_Date__c = Date.today().addDays(350);
        update testAcc2;
        Account updatedTestAcc = [SELECT Id,Reviewed_Account__c FROM Account WHERE id =:testAcc2.Id];
        system.assert(updatedTestAcc.Reviewed_Account__c);        
        Test.stopTest();
        /*Test.setMock(HttpCalloutMock.class, new MockCalloutManagePIMS());      
try{AccountTriggerHandler.triggerManageCustomerHandler('testEvent', testAcc1);}
catch(Exception e){}
try{AccountTriggerHelperPRM.updatePartnerRole(new list<Account>{testAcc1}, new Map<ID, Account>(new list<Account>{testAcc1}));}
catch(Exception e){}*/                  
    }
    //EDGE-27948
    @isTest
    static void testupdateAccountBusinessUnit(){
        Test.startTest();
        Account testAcc1 = new Account(Name='testAcc',Type='Residential',Customer_Status__c='PENDING');
        Insert testAcc1;
        Account newTestAcc1 = [SELECT Id,Business_Unit__c FROM Account WHERE id =:testAcc1.Id];
        system.assert(newTestAcc1.id != null && newTestAcc1.Business_Unit__c == 'Consumer');
        Account testAcc2 = new Account(Name='testAcc',Type='Company',Customer_Status__c='PENDING');
        Insert testAcc2;
        Account newTestAcc2 = [SELECT Id,Business_Unit__c FROM Account WHERE id =:testAcc2.Id];
        system.assert(newTestAcc2.id != null && newTestAcc2.Business_Unit__c == 'Business');
        Account testAcc3 = new Account(Name='testAcc',Type='Sole Trader',Customer_Status__c='PENDING');
        Insert testAcc3;
        Account newTestAcc3 = [SELECT Id,Business_Unit__c FROM Account WHERE id =:testAcc3.Id];
        system.assert(newTestAcc3.id != null && newTestAcc3.Business_Unit__c == 'Business');
        Test.stopTest();  
    }
    @isTest
    static void testupdateAccountBusinessUnit1(){
        Test.startTest();
        Account testAcc4 = new Account(Name='testAcc',Type='Organisation',Customer_Status__c='PENDING');
        Insert testAcc4;
        Account newTestAcc4 = [SELECT Id,Business_Unit__c FROM Account WHERE id =:testAcc4.Id];
        system.assert(newTestAcc4.id != null && newTestAcc4.Business_Unit__c == 'Business');
        Account testAcc5 = new Account(Name='testAcc',Type='Internal',Customer_Status__c='PENDING');
        Insert testAcc5;
        Account newTestAcc5 = [SELECT Id,Business_Unit__c FROM Account WHERE id =:testAcc5.Id];
        system.assert(newTestAcc5.id != null && newTestAcc5.Business_Unit__c == 'Telstra');
        Test.stopTest();  
    }
    //EDGE-30951
    @isTest
    static void testcreateTOSAApplication(){
        id rtypeId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId(); 
        profile ICMProfile = [select id,name from Profile where Name =:prmconstants.PRM_Profile_IndirectChannelManager];
        User ICM = new User(alias = 'Con123', email='ContactTr8wrw98@noemail.com',
                            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                            localesidkey='en_US', profileid =ICMProfile.id, country='United States',IsActive =true,                
                            timezonesidkey='America/Los_Angeles', username='Cont987657awqas12@noemail.com',Phone='+911231231234');
        PRM_Default__c prmDefault = PRM_Default__c.getOrgDefaults();
        Test.startTest();
        //Modified by Sri, team SFO on 16/01/2020
        //P2OB-4278: Addded 'Imported__c = True'  to bypass the validation rule 'SalesUsers_not_allowed_to_Import_Accs' on account creation
        Account testAcc1 = new Account(Name='testAcc', Imported__c=true, Telstra_Online_Service_Agreement__c = True,Pref_Comm_Method__c ='Phone',Phone='0412354323',recordtypeid=rtypeId2);
        System.runAs(ICM){   
            Insert testAcc1;
        }
        if(testAcc1.Telstra_Online_Service_Agreement__c == true ){
            Application__c app = new Application__c();
            app.RecordTypeId = prmDefault.TOSARecordTypeId__c;
            app.Status__c = 'Draft';
            app.Account__c = testAcc1.Id;
            app.ApplicationType__c = 'Telstra Online Services Agreement';
        }
        else if(testAcc1.Partner_Application__c != null && testAcc1.IsNominateContactCreated__c == False){
            Contact con = new Contact();
            con.AccountId = testAcc1.Id;
            con.LastName = testAcc1.Partner_Application__r.Nominated_Contact_Person__c;
            con.Email = testAcc1.Partner_Application__r.NominateContactEmail__c;
            con.OTP_Mobile_Phone_Number__c = testAcc1.Partner_Application__r.NominateContactPhone__c;
        }        
        system.assert(testAcc1.name=='testAcc');  
        Test.stopTest();
    }
    //EDGE-30922
    @isTest
    static void testupdateDistributorName(){
        Test.startTest();
        Account testTosaAcc = [select id,name,Account_Status__c,PRM_Remaining_License__c,Partner_Type__c,Telstra_Online_Service_Agreement__c,Phone,Primary_Distributor__c from account where name='testTosaAcc' limit 1];         
        if(testTosaAcc.Primary_Distributor__c == null && testTosaAcc.Partner_Type__c == 'NOMINATE')  {
            testTosaAcc.Primary_Distributor_Name__c = '';
        }         
        system.assert(testTosaAcc.name=='testTosaAcc');  
        Test.stopTest();
    }
    /*    
// Test Class To Cover UpdateOpportunitiesForInactiveAccounts EDGE-24836
@isTest
static void testUpdateOpportunitiesForInactiveAccounts(){
Test.startTest();
List<Account> lsAcc=[select id,Customer_Status__c from Account where name='test'];
if(lsAcc.size()<>null){lsAcc[0].Customer_Status__c='PENDING';}
update lsAcc;
Opportunity opp =new Opportunity();
opp.Name='testopporunity';
opp.StageName = 'Develop';
opp.CloseDate = Date.today();
opp.accountId = lsAcc[0].id;
insert opp;
if(lsAcc.size()<>null){lsAcc[0].Customer_Status__c='RETIRED';}
update lsAcc;
system.assertEquals('RETIRED', lsAcc[0].Customer_Status__c);
Test.stopTest();
}
*/
    @isTest
    static void testupdatecontactOnBoardingstatus(){    
        User uSysAdmin = [Select id from User where username='Cont987657awqas@noemail.com'];
        System.runAs(uSysAdmin){  
            Test.startTest();    
            id rtypeId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId(); 
            profile pSysAdmin = [select id,name from Profile where Name =:'System Administrator'];
            User uSysAdmin1= TestUtil.createRoleId('Cont987657awqas1@noemail.com', 'Con123', PRMConstants.PRM_SystemAdmin, 'CEO');  
            insert uSysAdmin1;
            System.runAs(uSysAdmin1){
                Contact con1 = [Select id from Contact where lastname = 'testCon2'];
                User u2= TestUtil.createUser('Cont987657w@noemail.com', 'Con12', PRMConstants.PRM_COMMUNITY_USER_AUSTRALIA);
                u2.contactid= con1.id;
                u2.PortalRole = 'Manager';
                insert u2; 
                PRM_Default__c objCS = new PRM_Default__c();
                objCS.Name = 'Test';
                objCS.SetupOwnerId=UserInfo.getOrganizationId();
                objCS.isChannelAcquisitionTeamMember__c = true;
                insert objCS;
                Test.setMock(HttpCalloutMock.class, new MockCalloutManagePIMS());      
                Account testAcc2 = [Select id,recordtypeid,IsPartner,Account_Status__c,Customer_Trading_Name__c ,
                                    ABN__c,ACN__c,PartnerPrincipalContact__c,State_Coverage__c,Partner_Type__c,
                                    Website,Phone,Overall_Accreditation__c,Mobility_Accreditation__c,
                                    Cloud_Accreditation__c,Data_Security_Accreditation__c,Collaboration_Accreditation__c from Account where Name = 'TelecomAC1'];
                testAcc2.recordtypeid=rtypeId2;
                testAcc2.IsPartner=TRUE;
                testAcc2.Account_Status__c='Active';
                testAcc2.Customer_Trading_Name__c = 'Test';
                testAcc2.ABN__c='aaaa';
                testAcc2.ACN__c='ccc';
                testAcc2.PartnerPrincipalContact__c=con1.id;
                testAcc2.State_Coverage__c = 'SA';
                testAcc2.Partner_Type__c='Partner';
                testAcc2.Website='www.vsygwoci.com';
                testAcc2.Phone='0412354323';
                testAcc2.Overall_Accreditation__c='Platinum';
                testAcc2.Mobility_Accreditation__c='Platinum';
                testAcc2.Cloud_Accreditation__c='Platinum';
                testAcc2.Data_Security_Accreditation__c='Platinum';
                testAcc2.Collaboration_Accreditation__c='Platinum';
                update testAcc2;
                list<Contact> conlist= [select id,Onboarding_Status__c,PIMS_Sync_Status__c,Community_User_Type__c from contact where id=:con1.id];
                system.assert(conlist[0].Onboarding_Status__c=='Active');  
            }   
            Test.stopTest();
        }
    }
    // Test Class To Cover updateAgreement method EDGE-32392
    @isTest
    static void testUpdateAgreement(){
        Test.startTest();
        /* Account acc1 = new Account(Name='Acc1',Type='Internal',APTPS_Tier__c='1',APTPS_Off_Shore_Restricted__c=true);
insert acc1;
Apttus__APTS_Agreement__c agr1 = new Apttus__APTS_Agreement__c(Name='Acc1Agreement',Apttus__Account__c=acc1.id,Apttus__Agreement_Category__c='abc',APTPS_Agreement_Subcategory__c='efg');
insert agr1;
Apttus__APTS_Agreement__c agreement1Inserted = [SELECT id,name,Offshore_Restricted__c,Apttus__Account__r.id,Apttus__Account__r.name FROM Apttus__APTS_Agreement__c WHERE name='Acc1Agreement' LIMIT 1];
System.debug('Acc1Agreement----> name: '+agreement1Inserted.name+' : Acoount : '+Apttus__Account__r.name+' : Offshore_Restricted__c : 'agreement1Inserted.Offshore_Restricted__c);
//system.assertEquals(true, agr1.Offshore_Restricted__c);
Account acc2 = new Account(Name='Acc2',Type='Internal',APTPS_Tier__c='3',APTPS_Off_Shore_Restricted__c=false);
insert acc2;
Apttus__APTS_Agreement__c agr2 = new Apttus__APTS_Agreement__c(Name='Acc1Agreement',Apttus__Account__c=acc2.id,Apttus__Agreement_Category__c='xyz',APTPS_Agreement_Subcategory__c='suv');
insert agr2;
system.assertEquals(false, agr2.Offshore_Restricted__c);
acc1 = [SELECT id,Name  FROM Account where Name='Acc1' LIMIT 1];
acc1.name='Acc1';
update acc1;
agreement1Inserted = [SELECT id,name,Offshore_Restricted__c,Apttus__Account__r.id,Apttus__Account__r.name FROM Apttus__APTS_Agreement__c WHERE name='Acc1Agreement' LIMIT 1];
System.debug('Acc1Agreement----> name: '+agreement1Inserted.name+' : Acoount : '+Apttus__Account__r.name+' : Offshore_Restricted__c : 'agreement1Inserted.Offshore_Restricted__c);
system.assertEquals(true, agr1.Offshore_Restricted__c);*/
        try{
            //CREATE ACCOUNT
            Account acc = AccountTestFactory.buildAccount('Test Account') ;
            acc.APTPS_Off_Shore_Restricted__c=true;
            acc.APTPS_Tier__c='1';
            insert acc;  
            //CREATE CONTACT 
            Contact contact = new Contact(
                AccountId = acc.id,
                LastName = 'Last',
                FirstName = 'First',
                Contact_Role__c = 'Consultant',
                MobilePhone = '+612345678',
                Email = 'test@tele2.com'   
            );
            Insert contact;
            //CREATE OPPORTUNITY
            Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
            opp.amount = 4600;
            insert opp;
            //Create Basket
            cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
            basket.csbb__Account__c = acc.id;
            basket.cscfga__Opportunity__c = opp.id;
            basket.Name = 'basket1';
            insert basket;
            OpportunityContactRole oppContact = new OpportunityContactRole();
            oppContact.ContactId = contact.Id;
            oppContact.IsPrimary = true;
            oppContact.OpportunityId = basket.cscfga__Opportunity__c;
            oppContact.Role = 'Inside Sales Account Manager';
            insert oppContact;
            APXTConga4__Conga_Template__c template = new APXTConga4__Conga_Template__c();
            template.APXTConga4__Name__c = 'OrderForm';
            template.Sequence__c = 1;
            template.APXTConga4__Template_Group__c = 'Contract'; 
            insert template;
            APXTConga4__Conga_Merge_Query__c query1 = new APXTConga4__Conga_Merge_Query__c();
            query1.APXTConga4__Name__c = 'BasketSnapshot'; 
            insert query1;
            APXTConga4__Conga_Merge_Query__c query2 = new APXTConga4__Conga_Merge_Query__c();
            query2.APXTConga4__Name__c = 'AccountDetails'; 
            insert query2;
            APXTConga4__Conga_Merge_Query__c query3 = new APXTConga4__Conga_Merge_Query__c();
            query3.APXTConga4__Name__c = 'BasketProductDetails'; 
            insert query3;
            APXTConga4__Conga_Merge_Query__c query4 = new APXTConga4__Conga_Merge_Query__c();
            query4.APXTConga4__Name__c = 'OpportunityDetails'; 
            insert query4;
            ContractJunction__c record = new ContractJunction__c();
            record.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
            record.Email__c = oppContact.contact.Email;
            record.Phone__c = oppContact.contact.MobilePhone;
            record.Customer_Primary_Contact__c = oppContact.ContactId;
            record.Related_Basket__c = basket.id;
            record.CongaStatus__c = 'NotStarted';
            record.Account__c = basket.csbb__Account__c;
            record.Related_Opportunity__c = basket.cscfga__Opportunity__c;
            record.Contract_Activated_Date__c = System.today();
            record.Contract_Term_Months__c = 36;
            record.Name = 'CN' + basket.Name.substring(2);
            record.Status__c='In Signature';
            insert record;
            record = [Select id,Status__c from ContractJunction__c where Related_Basket__r.Name ='basket1' LIMIT 1];
            record.Status__c='Fully Signed';
            update record;
            list<ContentVersion> ContentVersionList = New list<ContentVersion>();
            for(Integer i=1; i<= 8; i++){
                ContentVersion contentVersion = new ContentVersion(
                    Title = 'Penguins'+i+'.pdf',
                    PathOnClient = 'Penguins'+i+'.pdf',
                    VersionData = Blob.valueOf('Test Content'),
                    IsMajorVersion = true
                );
                ContentVersionList.add(contentVersion);
            }
            insert ContentVersionList;    
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            //create ContentDocumentLink  record 
            list<ContentDocumentLink> ContentDocumentLinkList = New list<ContentDocumentLink>();
            for(ContentDocument document : documents){
                ContentDocumentLink cdl = New ContentDocumentLink();
                cdl.LinkedEntityId = record.id;
                cdl.ContentDocumentId = document.Id;
                cdl.shareType = 'V';
                ContentDocumentLinkList.add(cdl);
            }
            insert ContentDocumentLinkList;
            insert new EnvironmentVariable__c(Name= 'ContractInitiate', Value__c = '1');
            insert new EnvironmentVariable__c(Name= 'AgreementGenerateContract', Value__c = '1');
            Insert new CustomConfigurationOptions__c(Name = 'ContractInitiate',Enrichment_Basket_Stage__c ='Contract Initiated' , External_Id__c ='7842', MarketableOfferList__c = '', Opportunity_Stage__c = 'Propose');
            List<String> fields = new List<String>(ContractJunction__c.SObjectType.getDescribe().fields.getMap().keySet());
            String soql = ''
                + ' SELECT ' + String.join(fields, ',')
                + ' from ContractJunction__c'
                + ' where ID != NULL';
            AgreementRecordCreation.createAgreementData(Database.query(soql));
            System.debug('Hurray!!! Agreement created');
            Apttus__APTS_Agreement__c  agreement1Inserted = [SELECT id,name,Offshore_Restricted__c,Apttus__Account__r.id,Apttus__Account__r.name FROM Apttus__APTS_Agreement__c WHERE Apttus__Account__r.name='Test Account' LIMIT 1];
            System.debug('Agreement before account update Acc1Agreement----> name: '+agreement1Inserted.name+' : Acoount : '+agreement1Inserted.Apttus__Account__r.name+' : Offshore_Restricted__c : '+agreement1Inserted.Offshore_Restricted__c);
            Account acc1 = [SELECT id,Name  FROM Account where Name='Test Account' LIMIT 1];
            acc1.name='Acc1';
            acc1.APTPS_Tier__c='1';
            update acc1;
            acc1 = [SELECT id,Name  FROM Account where Name='Acc1' LIMIT 1];
            system.debug('Test Account updated as Acc1'+acc1.name);
            List<Apttus__APTS_Agreement__c> listAgreement1Inserted = [SELECT id,name,Apttus__Status_Category__c,Apttus__Status__c,Offshore_Restricted__c,APTS_Acc_Tier__c,Apttus__Account__r.id,Apttus__Account__r.name FROM Apttus__APTS_Agreement__c WHERE Apttus__Account__r.name='Acc1'];
            System.debug('listAgreement1Inserted size ='+listAgreement1Inserted.size());
            for(Apttus__APTS_Agreement__c agreementUpdated : listAgreement1Inserted)
            {
                System.debug('Acc1Agreement----> name: '+agreementUpdated.name+'Agreement Id: '+agreementUpdated.id+'Status : '+agreementUpdated.Apttus__Status__c+'Status Category'+agreementUpdated.Apttus__Status_Category__c+' : Acoount : '+agreementUpdated.Apttus__Account__r.name+' : Offshore_Restricted__c : '+agreementUpdated.Offshore_Restricted__c);
                system.assertEquals(true, agreementUpdated.Offshore_Restricted__c);
                system.assertEquals('1', agreementUpdated.APTS_Acc_Tier__c);
            }
        }
        catch(Exception e){
            system.debug('exception--->'+e);
        }
        Test.stopTest();
    }
    @isTest   
    static void UpdateOverallAccreditationRelegatedTest(){        
        PRM_Default__c prmDefault = PRM_Default__c.getOrgDefaults();
        account testAcc3=[select id,Overall_Accreditation__c from account where name='TestOverallAccreditationrec1' limit 1];
        Id partnerAccRecID = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_AccountObject).get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId();
        Test.startTest(); 
        testAcc3.Overall_Accreditation__c='Silver';  
        testAcc3.recordtypeid = partnerAccRecID;
        update testAcc3;          
        Test.stopTest();  
        system.assert(testAcc3.Overall_Accreditation__c=='Silver');
        account testAcc4 = new account();
        testAcc4.Id = testAcc3.Id;
        testAcc4.recordtypeid = partnerAccRecID;
        testAcc4.Overall_Accreditation__c='Platinum';
        try{AccountTriggerHandler.UpdateAccreditationStatus(new Map<ID, Account>(new list<Account>{testAcc3}), new Map<ID, Account>(new list<Account>{testAcc4}));}
        catch(Exception e){}    
        try{AccountTriggerHandler.UpdateAccreditationStatus(new Map<ID, Account>(new list<Account>{testAcc4}), new Map<ID, Account>(new list<Account>{testAcc3}));}
        catch(Exception e){}    
    }
    @isTest   
    static void UpdateOverallAccreditationPromotedTest(){        
        PRM_Default__c prmDefault = PRM_Default__c.getOrgDefaults();
        //id rtypeId2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId(); 
        //Account testAcc3 = new Account(Name='testAcc',Overall_Accreditation__c='Silver', Telstra_Online_Service_Agreement__c = True,Partner_Type__c = 'Nominate',recordtypeid=rtypeId2);
        //Insert testAcc3;
        account testAcc3=[select id,name,Overall_Accreditation__c from account where name='TestAccManagePIMSTest4'];
        Test.startTest(); 
        testAcc3.Overall_Accreditation__c='Platinum';        
        update testAcc3;          
        Test.stopTest();  
        system.assert(testAcc3.Overall_Accreditation__c=='Platinum');  
    }
    @isTest
    static void testcreateAAR(){
        //CREATE ACCOUNT
        Test.startTest();
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        insert acc;
        cscrm__Address__c addId = AccountTestFactory.buildAddress('124230934');
        insert addid;
        Account acc1 = [SELECT id, Name FROM Account where Name='Test Account' LIMIT 1];
        cscrm__Account_Address_Relationship__c aar = AccountTriggerHelper.createAAR(acc1.id, addid.id, 'Primary Address');
        system.assert(aar != null);
        Test.stopTest();
    }
    @isTest   
    static void updatePartnerRoleMethodTest(){  
        //CREATE ACCOUNT    
        Account acc = [select id,name,Account_Status__c,PRM_Remaining_License__c from account where name='TelecomAC' limit 1];
        Contact con = [select id,LastName,AccountId,Onboarding_Status__c,PIMS_User_Type__c from Contact where LastName = 'testCon' limit 1];
        Test.startTest();
        acc.PartnerPrincipalContact__c=con.id;
        update acc;        
        Contact con1 = new Contact(LastName ='testCon1',AccountId = acc.Id, Onboarding_Status__c = 'Inactive', email = 'tpims@testmail.com'); // Hawaii
        insert con1;
        update acc;
        system.assert(acc.PartnerPrincipalContact__c != null);
        Test.stopTest();        
    }
    @isTest static void CallPIMsToManageTest() {   
        Test.setMock(HttpCalloutMock.class, new MockCalloutManagePIMS('200'));      
        //Account ac = new Account(name ='Test123',Account_Status__c = 'New');
        //insert ac;  
        account ac=[select id,name from account where name='TestAccManagePIMSTest3' limit 1];  
        insert new EnvironmentVariable__c(Name='massl_certificate_name',Value__c = 'telstrab2b_sandbox');
        list<id> accids= new list<id>();
        accids.add(ac.id);
        test.startTest();
        AccountTriggerHelperPRM.CallPIMsToManage(accids,'MANAGEORG','deactivateOrg','PimsMicroserviceManageOrgBatch');
        test.stopTest();
        System.assert(null != ac);
    }
    @isTest static void CallPIMsToManageErrorTest() {   
        Test.setMock(HttpCalloutMock.class, new MockCalloutManagePIMS('400'));      
        //Account ac = new Account(name ='Test123',Account_Status__c = PRMConstants.PRM_Account_Status_Frozen);
        //insert ac; 
        //Account ac1 = new Account(name ='Test',Account_Status__c = 'Pending Activation');
        //insert ac1; 
        account ac1= [select id,name from account where name='TestAccManagePIMSTest' limit 1];
        account ac= [select id,name from account where name='TestAccManagePIMSTest2' limit 1];
        insert new EnvironmentVariable__c(Name='massl_certificate_name',Value__c = 'telstrab2b_sandbox');
        list<id> accids= new list<id>();
        accids.add(ac1.id);
        list<id> accids1= new list<id>();
        accids.add(ac.id);
        test.startTest();
        AccountTriggerHelperPRM.CallPIMsToManage(accids,'MANAGEORG','deactivateOrg','PimsMicroserviceManageOrgBatch');
        AccountTriggerHelperPRM.CallPIMsToManage(accids1,'MANAGEORG','deactivateOrg','PimsMicroserviceManageOrgBatch');
        AccountTriggerHelperPRM.CallPIMsToManage(null,'MANAGEORG','deactivateOrg','PimsMicroserviceManageOrgBatch');
        test.stopTest();
        System.assert(null != ac);
    }
    @isTest static void CallPIMsTest() {  
        User uSysAdmin = [Select id from User where username='Cont987657awqas@noemail.com'];
        System.runAs(uSysAdmin){   
            Test.setMock(HttpCalloutMock.class, new MockCalloutManagePIMS('200'));
            account ac1= [select id,name from account where name='TestAccManagePIMSTest' limit 1];
            Contact con = [select id,LastName,AccountId,Onboarding_Status__c,PIMS_User_Type__c from Contact where LastName = 'testCon' limit 1];
            test.startTest();
            User u2 = TestUtil.createUser('test1@test.com.portfoliotest', 'test1', PRMConstants.PRM_COMMUNITY_USER_AUSTRALIA);
            u2.contactid = con.id;        
            insert u2;        
            insert new EnvironmentVariable__c(Name='massl_certificate_name',Value__c = 'telstrab2b_sandbox');
            list<id> conids= new list<id>();
            conids.add(con.id);       
            AccountTriggerHelperPRM.CallPIMs(conids,'MANAGEUSER','updateUser','PimsMicroserviceManageUserBatch');
            test.stopTest();         
            System.assert(null != ac1);
        }
    }
    /****************************************************************************
@Class/Method Name:testUpdatePrimaryAccountAddress()
@Author: SFO/Pallavi B
@Sprint : Sprint SFO 20.05 [P2OB-5483]
@CreateDate: 14/04/2020
@Description: method to cover updateAccountAddressRelationship,updatePrimaryAddress,updateAccountBillingAddress
******************************************************************************/
    @isTest
    static void testUpdatePrimaryAccountAddress(){
        User admin = TestUtil.createUser('admin@test.com.raytest', 'admin', 'System Administrator');
        insert admin;
        System.runAs(admin){ 
            Test.startTest(); 
            List<Account> acctestList = [SELECT Id,Primary_Address__c,Customer_Last_Verified_Date__c FROM Account ];
            system.assertNotEquals(acctestList, null);
            cscrm__Address__c address;
            List<cscrm__Address__c> addressList=new List<cscrm__Address__c>();
            for(Integer i=0;i<acctestList.size();i++){
                address=TestUtil.createAddress();
                address.cscrm__Street__c = 'test street'+i;
                address.Sub_Address1_Type__c = 'Bourke';
                address.Sub_Address2_Type__c = 'Spencers';
                address.Sub_Address_3_Type__c = '12353';
                address.Sub_Address_4_Type__c = '363863';
                address.cscrm__Building_Name__c = '668';
                address.Sub_Address1_Number__c='11';
                address.Sub_Address2_Number__c='11';
                address.Sub_Address_3_Number__c='11';
                address.Sub_Address_4_Number__c='11';
                address.cscrm__Building_Name__c='test';
                addressList.add(address);
            }
            insert addressList;
            for(Integer i=0;i<acctestList.size();i++){
                acctestList.get(i).Primary_Address__c=addressList.get(i).id;
                acctestList.get(i).Customer_Last_Verified_Date__c = null;
            }
            update acctestList;
            system.assertNotEquals(acctestList, null);
            cscrm__Address__c add=TestUtil.createAddress();
            insert add;
            List<Account> acctestList1 = [SELECT Id,Primary_Address__c,Customer_Last_Verified_Date__c FROM Account ];
            system.assertNotEquals(acctestList1, null);
            list<cscrm__Account_Address_Relationship__c> aadrList=new list<cscrm__Account_Address_Relationship__c>();
            for(Integer i=0;i<acctestList1.size();i++){
                cscrm__Account_Address_Relationship__c accAddRel = new cscrm__Account_Address_Relationship__c(cscrm__Account__c=acctestList1.get(i).id ,cscrm__Active__c=True,cscrm__Address__c=addressList.get(i).Id);
                aadrList.add(accAddRel);
            }
            insert aadrList;
            system.assertNotEquals(aadrList, null);
            cscrm__Account_Address_Relationship__c cscrmList = [select id,cscrm__Account__c,cscrm__Active__c,cscrm__Address__c from cscrm__Account_Address_Relationship__c where cscrm__Account__c= :acctestList.get(0).id limit 1];
            cscrmList.cscrm__Active__c =false;
            update cscrmList;
            system.assertNotEquals(cscrmList,null);
            Test.stopTest();
        }   
    }
    /****************************************************************************
@Class/Method Name:testaccountexeception()
@Author: SFO/Pallavi B
@Sprint : Sprint SFO 20.05 [P2OB-5483]
@CreateDate: 14/04/2020
@Description: method to cover updateAccountAddressRelationship,updatePrimaryAddress,updateAccountBillingAddress
******************************************************************************/
    @isTest
    static void testaccountexeception(){
        AccountTriggerHelper.updatePrimaryAddress(null,null,null);
        Account acctest = TestUtil.createAccount('Delete Account');
        Test.startTest();
        insert acctest;
        system.assert(acctest.Name=='Delete Account');
        delete acctest;
        Test.stopTest();
    }
    
    @isTest
    static void testaccountManage(){
        Test.setMock(HttpCalloutMock.class, new MockCalloutManagePIMS('400'));
        String event = ManageCustomerHandler.EVENT_ACTION_CREATE;
        Account ac = new Account(name ='Test123',Account_Status__c = PRMConstants.PRM_Account_Status_Frozen);
        Test.startTest();
        insert ac; 
        AccountTriggerHandler.triggerManageCustomerHandler(event,ac);
        system.assert(ac.Name=='Test123');
        Test.stopTest();
    }
    
    /****************************************************************************
@Class/Method Name:testsendChatterNotesOnPortCodeChange()
@Author: SFO/Pallavi B
@Sprint : Sprint SFO 21.13 [DIGI-8909]
@CreateDate: 14/09/2021
@Description: method to cover sendChatterNotesOnPortCodeChange
******************************************************************************/
    @isTest
    static void testsendChatterNotesOnPortCodeChange(){
        User adminUser = [Select id,username from User where username=:'Cont987657awqas@noemail.com'];
        System.runAs(adminUser){
            Test.startTest();
            Account acc = [select id from Account where Name =:'AccountTeamMember1'];
            acc.Portfolio_Code__c ='STA01';
            Update acc;    
        }
        Account acctestList1 = [SELECT Id,Portfolio_Code__c FROM Account where Name =:'AccountTeamMember1'];
        system.assert(acctestList1.Portfolio_Code__c == 'STA01');
        Test.stopTest();
        
    }
    
    /****************************************************************************
@Class/Method Name	: updateManualNoSellCreditHealthTest()
@Author				: SFO/Sri
@Sprint 			: sprint 21.13 [DIGI-15107]
@CreateDate			: 22/09/2021
@Description		: method to cover updateManualNoSellCreditHealth
******************************************************************************/
    @isTest
    static void updateManualNoSellCreditHealthTest(){
        User sales = [select id, name from User where username='test1@test.com.portfoliotestassign'];
        PermissionSet pSet = [SELECT ID From PermissionSet WHERE Name = 'Manual_No_Sell'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = sales.Id;
        psa.PermissionSetId = pSet.Id;
        insert psa;
        
        System.runAs(sales){
            try{
                Test.startTest();
                Account cusAct = [select id, name, Manual_No_Sell__c, Reason_For_Manual_No_Sell__c, Credit_Health__c from Account where name = 'customerAccount' limit 1];
                cusAct.Manual_No_Sell__c = true;
                cusAct.Reason_For_Manual_No_Sell__c = 'Credit Risk';
                update cusAct;
                Test.stopTest();
                Account cusActUpdated = [select id, name, Manual_No_Sell__c, Reason_For_Manual_No_Sell__c, Credit_Health__c from Account where name = 'customerAccount' limit 1];
                System.assertEquals('High Risk', cusActUpdated.Credit_Health__c) ;
            }
            catch(Exception ex){
                system.debug('Exception::::AccountTriggerTest :::: updateManualNoSellCreditHealthTest Method'+ ex.getMessage());
            }
        }
    }
}