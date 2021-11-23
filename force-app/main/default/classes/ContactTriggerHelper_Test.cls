/************
Modified By: Team Hawaii
Modified Date : 17/3/2030
Description : Modified only test data for fixing method 'testManageUserPartnerPermSet'.This failure is due to introduction 
of validation rule on contact object 
Key Note : Partner Contact record type of contact only use to create contact which is associated to partner user. 
Jira : P2OB-5160
Version : 2
Modified Date : Team Hawaii - 3/6/2020
Description : P2OB-6527 & P2OB-6037 - Remove reference to method 'toUpdateUserAsSuperUser' as method removed from main class

Last Update: DIGI-4057 :CHHAVEEL : Team SFO - 16/08/2021
             DIGI-4062 : Pallavi B  :Team SFO - 10/10/2021
             DIGI-3444 : Sri  :Team SFO - 18/10/2021

***********/
@isTest
public class ContactTriggerHelper_Test {
    
    //Updated for: DIGI-4057   
    @testSetup static void setup() {
        
        
        Test.startTest();
        list<User> usrlist = new list<User>();
        //Hawaii - Instead of creating role query on role to avoid error 'System.DmlException: Insert failed. First exception on row 0; first error: LIMIT_EXCEEDED, reached maximum number of roles: []'
        UserRole r = [Select id,DeveloperName From UserRole where DeveloperName = 'Sales_Ops' limit 1];
        
        profile pSysAdmin = [select id,name from Profile where Name = 'System Administrator' limit 1];
        
        User uSysAdmin = new User(alias = 'Con123', email='ContactTr8wrw98@noemail.com',
                                  emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                  localesidkey='en_US', profileid =pSysAdmin.id, country='United States',IsActive =true,                
                                  timezonesidkey='America/Los_Angeles', username='Cont987657ctht@noemail.com', UserRoleId = r.Id);
        usrlist.add(uSysAdmin);
        User sales = TestUtil.createUser('sales@test.com.LaTest','SalesLA',Label.Profile_SalesEnterprise);
        sales.phone = '04444444';
        usrlist.add(sales);
        insert usrlist;
        
        List<Account> acclist = new List<Account>();
        List<Contact> conlist = new List<Contact>();
        
        System.runAs(uSysAdmin){
            Account testAcc=TestUtil.createAccount('Test Account 123');
            acclist.add(testAcc);
            Account testAcc1=TestUtil.createAccount('Test Account 1234');
            acclist.add(testAcc1);
            Account testAcc2=TestUtil.createAccount('Test Account 12345');
            acclist.add(testAcc2);
            Account testAcc3=TestUtil.createAccount('Test Account 123456');
            acclist.add(testAcc3);
            Account testAcc4=TestUtil.createAccount('Test Account 1234566');
            acclist.add(testAcc4);
            Account testAcc6=TestUtil.createAccount('Test Account 12345667');
            acclist.add(testAcc6);
            Account testAcc8=TestUtil.createAccount('Test Account 123456677');
            acclist.add(testAcc8);
            //Added as part of DIGI-4062
            Account testInvAcc=TestUtil.createAccount('Invoice Test Account');
            acclist.add(testInvAcc);
            //Ends here
            insert acclist;
            
            acclist.clear();
            
            
            testAcc.OwnerId =  sales.id;
            acclist.add(testAcc);
            testAcc1.OwnerId =  sales.id;
            acclist.add(testAcc1);
            testAcc2.OwnerId =  sales.id;
            acclist.add(testAcc2);
            testAcc3.OwnerId =  sales.id;
            acclist.add(testAcc3);
            testAcc4.OwnerId =  sales.id;
            acclist.add(testAcc4);
            testAcc6.OwnerId =  sales.id;
            acclist.add(testAcc6);
            testAcc8.OwnerId =  sales.id;
            acclist.add(testAcc8);
            update acclist;
            
            Contact testcon= TestUtil.createContact(testAcc.id , 'Test', 'Contact');
            testcon.Raise_Billing_Disputes__c = true;
            testcon.Telstra_Connect_Admin__c =  true;
            testcon.Contact_Status__c = 'Active';
            testcon.Telstra_Connect_Status__c = 'Registered - Activated';
            testcon.Telstra_Connect_Opt_Out__c = false ;
            conlist.add(testcon);
            
            Contact testcon1= TestUtil.createContact(testAcc1.id , 'Test', 'Contact 1');
            testcon1.Raise_Billing_Disputes__c = true;
            testcon1.Telstra_Connect_Admin__c =  false;
            testcon1.Contact_Status__c = 'Active';
            testcon1.Telstra_Connect_Status__c = 'Registered - Activated';
            testcon1.Telstra_Connect_Opt_Out__c = false ;
            conlist.add(testcon1);
            
            Contact testcon2= TestUtil.createContact(testAcc2.id , 'Test', 'Contact 2');
            testcon2.Raise_Billing_Disputes__c = true;
            testcon2.Telstra_Connect_Admin__c =  true;
            testcon2.Contact_Status__c = 'Active';
            testcon2.Telstra_Connect_Status__c = 'Registered - Activated';
            testcon2.Telstra_Connect_Opt_Out__c = false ;
            conlist.add(testcon2);
            
            Contact testcon3= TestUtil.createContact(testAcc3.id , 'Test', 'Contact 3');
            testcon3.Raise_Billing_Disputes__c = true;
            testcon3.Telstra_Connect_Admin__c =  true;
            testcon3.Contact_Status__c = 'Active';
            conlist.add(testcon3);
            
            Contact testcon4= TestUtil.createContact(testAcc4.id , 'Test', 'Contact 4');
            testcon4.Raise_Billing_Disputes__c = true;
            testcon4.Telstra_Connect_Admin__c =  true;
            testcon4.Contact_Status__c = 'Active';
            conlist.add(testcon4);
            
            Contact testcon5= TestUtil.createContact(testAcc6.id , 'Test', 'Contact 5');
            testcon5.Raise_Billing_Disputes__c = true;
            testcon5.Telstra_Connect_Admin__c =  false;
            testcon5.Contact_Status__c = 'Active';
            testcon5.Telstra_Connect_Status__c = 'Registered - Activated';
            testcon5.Telstra_Connect_Opt_Out__c = false ;
            conlist.add(testcon5);
            
            Contact testcon6= TestUtil.createContact(testAcc8.id , 'Test', 'Contact 6');
            testcon6.Raise_Billing_Disputes__c = true;
            testcon6.Telstra_Connect_Admin__c =  false;
            testcon6.Contact_Status__c = 'Active';
            testcon6.Telstra_Connect_Status__c = 'Registered - Activated';
            testcon6.Telstra_Connect_Opt_Out__c = false ;
            conlist.add(testcon6);
            
            
            Contact testcon7= TestUtil.createContact(testAcc1.id , 'Test', 'Contact 1');
            testcon7.Raise_Billing_Disputes__c = false;
            testcon7.Telstra_Connect_Admin__c =  false;
            testcon7.Contact_Status__c = 'Active';
            conlist.add(testcon7);

            //Modified as part of DIGI-4062 Sprint 21.14.Starts here
            Contact testcon8= TestUtil.createContact(testAcc2.id , 'Test', 'Contact 8');
            testcon8.Invoice_notifications__c ='Invoice arrival notification';
            testcon8.Raise_Billing_Disputes__c = true;
            testcon8.Contact_Status__c = 'Active';
            testcon8.Telstra_Connect_Status__c = 'Registered - Activated';
            testcon8.Telstra_Connect_Opt_Out__c = false ;
            conlist.add(testcon8);
          
            Contact Tcon = new Contact();
			 for(Integer i=0;i<=5;i++){
				    Tcon = TestUtil.createContact(testInvAcc.id , 'Test', 'Invoice Contact '+i);
				    Tcon.Invoice_notifications__c ='Invoice arrival notification';
					Tcon.Raise_Billing_Disputes__c = true;
					Tcon.Contact_Status__c = 'Active';
					Tcon.Telstra_Connect_Opt_Out__c = false ;
					conlist.add(Tcon);
			 }
             
            //DIGI-4062 .Ends Here
            insert conlist;
            
            Test.stopTest();
        }
    }
    
    @isTest 
    public  static void testManageUserPartnerPermSet(){
        test.starttest();
        ContactTriggerHelper conTriggerHelper = new ContactTriggerHelper();
        User uSysAdmin = [Select id,Userrole.Id from User where username='Cont987657ctht@noemail.com' and UserRoleId!=null];
        System.runAs(uSysAdmin){
            
            // Hawaii - Fetch Partner record type
            Id partnerAccRecTypeId = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_AccountObject).get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId(); // fetch partner record type
            // Hawaii - Fetch Partner Contact record type
            Id contactRecTypeId = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_ContactObject).get(PRMConstants.PRM_Partner_Contact_Record_Type).getRecordTypeId(); // fetch partner contact record type
            
            //Hawaii - create Partner Principle contact
            Contact con = new Contact(Partner_Role__c = 'Principal Partner Contact',LastName ='testPrinCon',Work_Phone_Number__c= '+61123456789',OTP_Mobile_Phone_Number__c='+61123456789',RecordtypeId=contactRecTypeId, Onboarding_Status__c = 'InActive',PIMS_User_Type__c='TEG');
            insert con;
            //Hawaii - Modified existing account creation logic to create partner account
            Account ac = new Account(name ='Telecom',Account_Status__c = 'Active',PRM_Remaining_License__c=25,RecordtypeId = partnerAccRecTypeId,
                                     Customer_Trading_Name__c = 'Test',
                                     ABN__c = 'aaaa',
                                     ACN__c = 'ccc',
                                     State_Coverage__c = 'VIC',
                                     Partner_Type__c = 'Distributor',
                                     Website = 'www.vsygqwoci.com',
                                     Phone = '0412354323',
                                     Overall_Accreditation__c = 'Platinum',
                                     Mobility_Accreditation__c = 'Platinum',
                                     Cloud_Accreditation__c = 'Platinum',
                                     Data_Security_Accreditation__c = 'Platinum',
                                     Collaboration_Accreditation__c = 'Platinum',
                                     PartnerPrincipalContact__c = con.id,
                                     OwnerId = uSysAdmin.Id
                                    );
            insert ac; 
            con.Onboarding_Status__c = 'Active';
            con.AccountId = ac.id;
            update con;
            id p = [select id from profile where name='PRM Community User - Australia'].id;
            User u1 = new User(alias = 'Con123', email='ContactTr898@noemail.com',
                               emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                               localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                               ContactId = con.Id,
                               timezonesidkey='America/Los_Angeles', username='Cont989@noemail.com');
            
            insert u1;
            
            PRM_Default__c objCS = new PRM_Default__c();
            objCS.Name = 'Test';
            objCS.SetupOwnerId=UserInfo.getOrganizationId();
            objCS.isChannelAcquisitionTeamMember__c = true;
            insert objCS;
            
            
            
            Map<id,contact> mp =  new Map<id,contact>();  
            mp.put(con.id,con);
            conTriggerHelper.setOnboardingStatus(new List<Contact>{con});
            Set <id> conset= new Set<Id>();
            conset.add(con.Id);
            system.assertEquals('Testing', u1.lastname);
            system.assertEquals('Con123', u1.alias);
            test.stoptest();
        }
    }
    
    @isTest
    static void TestContacttriggerHlprPRM(){
        User uSysAdmin = [Select id,Userrole.Id from User where username='Cont987657ctht@noemail.com' and UserRoleId!=null];
        System.runAs(uSysAdmin){
            Id ContactRecTypeId = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_ContactObject).get(PRMConstants.PRM_Partner_Contact_Record_Type).getRecordTypeId(); // fetch partner contact record type
            Id partnerAccRecID = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_AccountObject).get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId();
            Test.startTest();
            
            //Hawaii - create Partner Principle contact
            Contact con = new Contact(Partner_Role__c = 'Principal Partner Contact',LastName ='testPrinCon',Work_Phone_Number__c= '+61123456789',OTP_Mobile_Phone_Number__c='+61123456789',RecordtypeId=contactRecTypeId, Onboarding_Status__c = 'InActive',PIMS_User_Type__c='TEG');
            insert con;
            
            // Hawaii - Fetch Partner record type
            Id partnerAccRecTypeId = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_AccountObject).get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId(); // fetch partner record type
            //Hawaii - Modified existing account creation logic to create partner account
            Account acctest = new Account(name ='Telecom',Account_Status__c = 'Active',PRM_Remaining_License__c=25,RecordtypeId = partnerAccRecTypeId,
                                          Customer_Trading_Name__c = 'Test',
                                          ABN__c = 'aaaa',
                                          ACN__c = 'ccc',
                                          State_Coverage__c = 'VIC',
                                          Partner_Type__c = 'Distributor',
                                          Website = 'www.vsygqwoci.com',
                                          Phone = '0412354323',
                                          Overall_Accreditation__c = 'Platinum',
                                          Mobility_Accreditation__c = 'Platinum',
                                          Cloud_Accreditation__c = 'Platinum',
                                          Data_Security_Accreditation__c = 'Platinum',
                                          Collaboration_Accreditation__c = 'Platinum',
                                          PartnerPrincipalContact__c = con.id
                                         );
            insert acctest; 
            
            //EDGE-88445 PartnerRole__c updated to Partner_Role__c (multi picklist field) by Saran
            con.Partner_Role__c =PRMConstants.PRM_PartnerRole_Partner_Sales_manager; //'Super User';
            con.Onboarding_Status__c='Active';
            update con;
            system.assertEquals('Telecom',acctest.Name);
            Test.stopTest();
        }
    }
    /*Created for: DIGI-4057
        Team           : SFO 
        Sprint         : 21.11 
        Stroy          : DIGI-4057 
        Author         : Chhaveel Thakur
        */
    @isTest
    static void TestlastContactwithBillingAccessCheck(){
        list<contact> con1 = [Select Id, Raise_Billing_Disputes__c, Contact_Status__c from contact where lastname ='Contact' LIMIT 1 ];
        list<User>  usr1 = [Select Id, alias from user where alias = 'SalesLA' LIMIT 1];
        Test.startTest();
        system.runas(usr1[0]){
            try{
                con1[0].Contact_Status__c = 'Inactive';
                update con1;
            }
            catch (DMLException e) {
                System.assert(e.getMessage().contains('Your changes have not been saved'), 'message=' + e.getMessage());            
            } 
        }
        Test.stopTest();
    }
    /*Created for: DIGI-4057
        Team           : SFO 
        Sprint         : 21.11 
        Stroy          : DIGI-4057 
        Author         : Chhaveel Thakur
        */
    @isTest
    static void TestlastContactwithBillingAccessCheck_Raise_Billing_Disputes_False(){
        
        list<contact> con1 = [Select Id, Raise_Billing_Disputes__c, Contact_Status__c from contact where lastname = 'Contact 1' LIMIT 1 ];
        list<User>  usr1 = [Select Id, email, alias from user where alias = 'SalesLA' LIMIT 1];
        Test.startTest(); 
        system.runas(usr1[0]){
            try{
                con1[0].Raise_Billing_Disputes__c = false;
                
                update con1;
            }
            catch (DMLException e) {
                System.assert(e.getMessage().contains('Your changes have not been saved'), 'message=' + e.getMessage());            
            } 
        }
        Test.stopTest();
    }
    /*Created for: DIGI-4057
        Team           : SFO 
        Sprint         : 21.11 
        Stroy          : DIGI-4057 
        Author         : Chhaveel Thakur
        */
    @isTest
    static void TestlastContactwithBillingAccessCheck_Raise_Billing_Disputes_False2(){
        
        list<contact> con1 = [Select Id, Raise_Billing_Disputes__c, Contact_Status__c from contact where lastname = 'Contact' LIMIT 1 ];
        list<User>  usr1 = [Select Id, email, alias from user where alias = 'SalesLA' LIMIT 1];
        Test.startTest(); 
        system.runas(usr1[0]){
            try{
                con1[0].Raise_Billing_Disputes__c = false;
                
                update con1;
            }
            catch (DMLException e) {  
                System.assert(e.getMessage().contains('user management and billing permissions selected'), 'message=' + e.getMessage());          
            } 
        }
        Test.stopTest();
    }
    /*Created for: DIGI-4057
        Team           : SFO 
        Sprint         : 21.11 
        Stroy          : DIGI-4057 
        Author         : Chhaveel Thakur
        */
    @isTest
    static void TestlastContactwithBillingAccessCheck_Telstra_Connect_Opt_Out_True(){
        
        list<contact> con1 = [Select Id, Telstra_Connect_Opt_Out__c, Contact_Status__c from contact where lastname = 'Contact' LIMIT 1 ];
        list<User>  usr1 = [Select Id, email, alias from user where alias = 'SalesLA' LIMIT 1];
        Test.startTest(); 
        system.runas(usr1[0]){
            try{
                con1[0].Telstra_Connect_Opt_Out__c = true;
                
                update con1;
            }
            catch (DMLException e) {
                System.assert(e.getMessage().contains('Your changes have not been saved'), 'message=' + e.getMessage());            
            } 
        }
        Test.stopTest();
    }
    /*Created for: DIGI-4057
        Team           : SFO 
        Sprint         : 21.11 
        Stroy          : DIGI-4057 
        Author         : Chhaveel Thakur
        */
    @isTest
    static void TestlastContactwithBillingAccessCheck_Telstra_Connect_Admin_False(){
        
        list<contact> con1 = [Select Id, Telstra_Connect_Admin__c, Contact_Status__c from contact where lastname = 'Contact 2' LIMIT 1 ];
        list<User>  usr1 = [Select Id, email, alias from user where alias = 'SalesLA' LIMIT 1];
        Test.startTest(); 
        system.runas(usr1[0]){
            try{
                con1[0].Telstra_Connect_Admin__c = false;
                
                update con1;
            }
            catch (DMLException e) {
                System.assert(e.getMessage().contains('Your changes have not been saved'), 'message=' + e.getMessage());            
            } 
        }
        Test.stopTest();
    }
    /*Created for: DIGI-4057
        Team           : SFO 
        Sprint         : 21.11 
        Stroy          : DIGI-4057 
        Author         : Chhaveel Thakur
        */
    @isTest
    static void TestlastContactwithBillingAccessCheck_Telstra_Connect_Admin_False2(){
        
        list<contact> con1 = [Select Id, Telstra_Connect_Admin__c, Contact_Status__c from contact where lastname = 'Contact 3' LIMIT 1 ];
        list<User>  usr1 = [Select Id, email, alias from user where alias = 'SalesLA' LIMIT 1];
        Test.startTest(); 
        system.runas(usr1[0]){
            try{
                con1[0].Telstra_Connect_Admin__c = false;
                
                update con1;
            }
            catch (DMLException e) {
                System.assert(e.getMessage().contains('Your changes have not been saved'), 'message=' + e.getMessage());            
            } 
        }
        Test.stopTest();
    }
	/*Created for: DIGI-4057
        Team           : SFO 
        Sprint         : 21.11 
        Stroy          : DIGI-4057 
        Author         : Chhaveel Thakur
        */    @isTest
    static void TestlastContactwithBillingAccessCheck_Contact_Status_Inactive(){
        
        list<contact> con1 = [Select Id, Raise_Billing_Disputes__c, Contact_Status__c from contact where lastname ='Contact 4' LIMIT 1 ];
        list<User>  usr1 = [Select Id, email, alias from user where alias = 'SalesLA' LIMIT 1];
        Test.startTest();
        system.runas(usr1[0]){
            try{
                con1[0].Contact_Status__c = 'Inactive';
                update con1;
            }
            catch (DMLException e) {
                System.assert(e.getMessage().contains('Your changes have not been saved'), 'message=' + e.getMessage());            
            } 
        }
        Test.stopTest();
    }
    /*Created for: DIGI-4057
        Team           : SFO 
        Sprint         : 21.11 
        Stroy          : DIGI-4057 
        Author         : Chhaveel Thakur
        */
    @isTest
    static void TestlastContactwithBillingAccessCheck_Telstra_Connect_Opt_Out_True2(){
        
        list<contact> con1 = [Select Id, Telstra_Connect_Opt_Out__c, Contact_Status__c from contact where lastname = 'Contact 5' LIMIT 1 ];
        list<User>  usr1 = [Select Id, email, alias from user where alias = 'SalesLA' LIMIT 1];
        Test.startTest(); 
        system.runas(usr1[0]){
            try{
                con1[0].Telstra_Connect_Opt_Out__c = true;
                
                update con1;
            }
            catch (DMLException e) {
                System.assert(e.getMessage().contains('Your changes have not been saved'), 'message=' + e.getMessage());            
            }
        }
        Test.stopTest();
    }
    /*Created for: DIGI-4057
        Team           : SFO 
        Sprint         : 21.11 
        Stroy          : DIGI-4057 
        Author         : Chhaveel Thakur
        */ 
    @isTest
    static void TestlastContactwithBillingAccessCheck_Telstra_Connect_Opt_Out_True3(){
        
        list<contact> con1 = [Select Id, Telstra_Connect_Opt_Out__c, Contact_Status__c from contact where lastname = 'Contact 6' LIMIT 1 ];
        list<User>  usr1 = [Select Id, email, alias from user where alias = 'SalesLA' LIMIT 1];
        Test.startTest(); 
        system.runas(usr1[0]){
            try{
                con1[0].Telstra_Connect_Opt_Out__c = true;
                
                update con1;
            }
            catch (DMLException e) {
                System.assert(e.getMessage().contains('Your changes have not been saved'), 'message=' + e.getMessage());            
            } 
        }
        Test.stopTest();
    }
        /*
        Team           : SFO 
        Sprint         : 21.14 
        Stroy          : DIGI-4062
        Author         : Pallavi B
        */
    @isTest
    static void TestduplicateCheckOnInvoiceNotification(){
        
        list<Account> acc = [Select Id,name from Account where name = 'Invoice Test Account'  LIMIT 1 ];
        list<contact> con1 = [Select Id, Telstra_Connect_Opt_Out__c, Invoice_notifications__c from contact where AccountId =:acc[0].id];
        list<User>  usr1 = [Select Id, email, alias from user where alias = 'SalesLA' LIMIT 1];
		Contact cont= new Contact();
		List<Contact> lstcont= new List<Contact>();
        Boolean expectedExceptionThrown;
		for(Integer i=0;i<=con1.size()-1;i++){
			cont.Invoice_notifications__c = 'Invoice arrival notification;Invoice arrival notification';
			lstcont.add(cont);
		}
        Test.startTest(); 
        system.runas(usr1[0]){
            try{
                update lstcont;
            }
            catch (DMLException e) {
                expectedExceptionThrown=true;
                Boolean expectedExceptionThrownMsg =  (e.getMessage().contains(System.Label.DuplicateContactInvoiceArrNotf)) ? true : false; 
                System.AssertEquals(true, expectedExceptionThrown, e.getMessage()); 
            } 
        }
        Test.stopTest();
    }
        /*
        Team           : SFO 
        Sprint         : 21.14 
        Stroy          : DIGI-4062
        Author         : Pallavi B
        */
     @isTest
    static void TestRemoveOfInvoiceNotification(){
        list<Account> acc = [Select Id,name from Account where name = 'Invoice Test Account'  LIMIT 1 ];
        list<User>  usr1 = [Select Id, email, alias from user where alias = 'SalesLA' LIMIT 1];
		List<Contact> lstcons = new List<Contact>();
            Boolean expectedExceptionThrown;
                 for(Integer i=0;i<=5;i++){
                        Contact Tcons = TestUtil.createContact(acc[0].id, 'Test', ' Invoice Arr Contact '+i);
                        Tcons.Invoice_notifications__c ='Invoice arrival notification;Invoice arrival notification;';
                        Tcons.Raise_Billing_Disputes__c = true;
                        Tcons.Contact_Status__c = 'Active';
                        Tcons.Telstra_Connect_Opt_Out__c = false ;
                        lstcons.add(Tcons);
                 }
        Test.startTest(); 
        
        system.runas(usr1[0]){
            try{
                insert lstcons;
            }
            catch (DMLException e) {
                expectedExceptionThrown=true;
                Boolean expectedExceptionThrownMsg =  (e.getMessage().contains(System.Label.DuplicateContactInvoiceArrNotf)) ? true : false; 
                System.AssertEquals(true, expectedExceptionThrown, e.getMessage());           
            } 
        }
        Test.stopTest();
    }
    
     /*Created for: DIGI-4062
        Team           : SFO 
        Sprint         : 21.14 
        Stroy          : DIGI-4062
        Author         : Pallavi B
        */ 
    @isTest
    static void TestlastContactwithInvoiceArrivalNotification(){
        
        list<contact> con1 = [Select Id, Telstra_Connect_Opt_Out__c, Contact_Status__c,Invoice_notifications__c from contact where lastname = 'Contact 8' LIMIT 1 ];
        list<User>  usr1 = [Select Id, email, alias from user where alias = 'SalesLA' LIMIT 1];
        Test.startTest(); 
        system.runas(usr1[0]){
            try{
                con1[0].Invoice_notifications__c = '';
                update con1;
            }
            catch (DMLException e) {
                System.assert(e.getMessage().contains('Your changes have not been saved'), 'message=' + e.getMessage());            
            } 
        }
        Test.stopTest();
    }
    
     /*Created for: DIGI-3444
        Team           : SFO 
        Sprint         : 21.14 
        Stroy          : DIGI-3444
        Author         : Sri
        */ 
    @isTest
    static void verifyAccountOnContactUpdateTest(){
        list<Account> testActList = new list<Account>();
        list<Contact> testConList = new list<Contact>();
        User admin = [select id, name from User where username='Cont987657ctht@noemail.com'];
        system.runAs(admin){
            Account testActU1 =TestUtil.createAccount('Test Ultimate Account One');
            testActU1.CIDN__c = '696969691';
            testActList.add(testActU1);
            
            Account testActU2 =TestUtil.createAccount('Test Ultimate Account Two');
            testActU2.CIDN__c = '696969692';
            testActList.add(testActU2);
            
            Account testActC1 =TestUtil.createAccount('Test Child Account Two');
            testActC1.Ultimate_Parent_CIDN__c = testActU1.CIDN__c;
            testActList.add(testActC1);
            
            Account testActC2 =TestUtil.createAccount('Test Child Account Two');
            testActC2.Ultimate_Parent_CIDN__c = testActU2.CIDN__c;
            testActList.add(testActC2);
            Test.startTest();
            insert testActList;
            
            Contact con1 = TestUtil.createContact(testActU1.Id , 'Contact', 'One');
            testConList.add(con1);
            Contact con2 = TestUtil.createContact(testActU2.Id , 'Contact', 'Two');
            testConList.add(con2);
            Contact con3 = TestUtil.createContact(testActC2.Id , 'Contact', 'Three');
            testConList.add(con3);
            insert testConList;
            Test.stopTest();
            
            list<Contact>  testConList1 = new list<Contact>();
            con1.accountId = testActU2.Id; // old con1 has testActU1 and updating to testActU2
            testConList1.add(con1);
            
            con2.accountId = testActC1.Id; // old con2 has testActU2 and updating to testActC1
            testConList1.add(con2);
            
            con3.accountId = testActU2.Id; // old con3 has testActC2 and updating to testActU2
            testConList1.add(con3);
            Database.SaveResult[] srList = Database.update(testConList1,false);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    system.assertEquals(con3.Id, sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    }
                }
            }
        }
    }


}