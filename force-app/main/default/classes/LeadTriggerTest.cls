/*
@Last Modified        : 07/01/2021 21.01 by sravanthi, Team SFO
                        as part of P2OB-9943/P2OB-6772 Removing Commented Code, debug Statements and updating API version to 50.
v1.1                    08/03/2021     Vivian Charlie    Team Hawaii    Adding test class for Partner Principal Contact missing validation
S21.04::P2OB-12075      16/03/2021     Pallavi B         Team SFO       As part of Tech Debt (Removed References for the Label of Enterprise Record Type)
S21.11::DIGI-3187       25/08/2021     Pallavi B         Team SFO       Test Coverage for assignAccTeamMemToOwnerId method.
S21.11::DIGI-5740       21/09/2021     Chhaveel          Team SFO       Test Coverage for customLeadRouting, customLeadRoutingNS and customLeadRoutingMMS method.
S21.15::DIGI-34447      01/1/2021      Pallavi B         TeaM SFO       Test code coverage for FirstBillTaskOnUpdate,MigrationLeadConversion methods
S21.15::DIGI-11413      09/11/2021     Pallavi B         TeaM SFO       Test code coverage for EnterpriseLeadConversionErrorOnStage
*/
@isTest
public class LeadTriggerTest {
    
    @testSetup
    public static void createData(){
                id p1 = [select id from profile where name='System Administrator'].id;
        UserRole r = [Select id,DeveloperName From UserRole where DeveloperName = 'Sales_Ops' limit 1];
            User uSysAdmin = TestUtil.createUser('b2btestewwr@noemail.com','SA User',Label.Profile_SystemAdmin);
             
            //Added as part of DIGI-3187 S21.12
            Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise];
            Profile pfAdmin = [select id from profile where name = 'System Administrator'];  
            List<user> userList = new List<user>();
            
            User admin = TestUtil.createTestUser(r.id,pfAdmin.id,'salesuser','Testing');
            admin.username='adminuser@testsales.com';
            admin.email='adminuser@testsales.com';
            admin.phone='+121221231234';
            
            User sales = TestUtil.createTestUser(r.id,pf.id,'salesuser','Testing');
            sales.username='salesuser@testsales.com';
            sales.email='salesuser@testsales.com';
            sales.phone='+121231231234';
            User usr1 = TestUtil.createUser('test1@test.com.portfoliotest', 'test1', System.Label.Profile_SalesEnterprise);
            usr1.phone='+121231231231';
            userList.add(usr1);
            userList.add(uSysAdmin);
            userList.add(sales);
            userList.add(admin);
            insert userList;
        
         // Query your permission set name 
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Allow_All_Lead_Type_Selection'];
       
        // Assigning the Permission Set to the above user as part of P2OB-8984 to allow acess to 'cal me now' and ' MQL Threshold' values.
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = uSysAdmin.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;
           //DIGI-3187 ::Ends here

        System.runAs(uSysAdmin){
        Test.startTest();
        list<Countries_region__c> cList=new list<Countries_region__c>();
        Countries_region__c cRnew=new Countries_region__c(name='INDIA',region__c='APAC');
        Countries_region__c cRnew1=new Countries_region__c(name='AUSTRALIA',region__c='APAC');
        cList.add(cRnew);
        cList.add(cRnew1);
        insert cList;
        list<Account> accList = new list<Account>();
            
            Account a = TestUtil.createAccount('name'); 
            a.CIDN__c='123445';
            a.APTPS_Tier__c = 'Enterprise & Government';
            accList.add(a); 
            
            Account b = TestUtil.createAccount('name1'); 
            b.CIDN__c='1234455';
            b.APTPS_Tier__c = 'Mid-market';
            accList.add(b); 
            // SFO/21.13 Added for DIGI-5740 
            Account c = TestUtil.createAccount('name2'); 
            c.CIDN__c='1234456';
            c.APTPS_Tier__c = 'Enterprise & Government';
            c.Portfolio_Code__c = 'TST01';
            accList.add(c); 
            //DIGI-5740   ends here
            insert accList;
            
        List<Contact> conList=new  List<Contact>();
        Contact source=TestUtil.createContact(a.id,'Shambo', 'Rayssq');
        source.UUID__c='90636127';
        conList.add(source);
        
            // SFO/21.13 Added for DIGI-5740       
            
            List<Territory2> territories = TestUtil.createPortfolioTerritories('TestModel', new List<String>{'TST01'});
            insert territories;
            
            
            List<AccountTeamMember> accTeamList = new List<AccountTeamMember>();
            AccountTeamMember member1 = TestUtil.createAccountTeamMember(sales.id,'Edit','Network Sales Specialist',a.id);
            accTeamList.add(member1);
            insert accTeamList;
            //DIGI-5740   ends here
            
        Contact source1=TestUtil.createContact(a.id,'ShamboTest', 'RayssqTest');
        source.UUID__c='906361272';
        conList.add(source1);
        insert conList;
        
        
        AssignmentRule ar = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Lead' AND Active = True LIMIT 1];
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.assignmentRuleId= ar.id;
        list<lead> leadLst=new list<lead>();
        for(integer i=0;i<20;i++){
            lead l=new lead(lastname='acbc'+i,firstname='frst'+i,company='telstra test inc.',Country__c='India',recordtypeid=Schema.SObjectType.lead.getRecordTypeInfosByName().get('TE-I Partner Expression of Interest').getRecordTypeId(), //Replaced with Developer Name of Enterprise Lead Record Type
                            phone='031245678');
            l.setOptions(dmlOpts);
            leadLst.add(l);
        }
        lead s=new lead(lastname='acbc',firstname='frst',company='telstra test inc.',recordtypeid=Schema.SObjectType.lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId(), //Replaced with Developer Name of Enterprise Lead Record Type
                        phone='031245678',Lead_Type__c='Call Me Now',Lead_Source_Original__c='Events',CIDN__c='123445',Contact_Id__c = source.id);
        leadLst.add(s);
        lead t=new lead(lastname='acbcd',firstname='frst',company='telstra test inc.',recordtypeid=Schema.SObjectType.lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId(), //Replaced with Developer Name of Enterprise Lead Record Type
                        phone='031245678',Lead_Source_Original__c='Events',CIDN__c='123445');
        leadLst.add(t);
        
            //Added below lead insertions as part of DIGI-34437 S21.15
            Id leadMigrationRecordTypeId = Schema.SObjectType.lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Migration).getRecordTypeId();
            Id leadEnterpriseRecordTypeId = Schema.SObjectType.lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId(); //Modified as part of DIGI-11413 S21.15
            
            lead EntLead =TestUtil.createLead(null,'lead', 'Migration', leadEnterpriseRecordTypeId,'testemail12@gmail.com'); //Modified as part of DIGI-11413 S21.15
            EntLead.Lead_Source_Original__c='Events';
            EntLead.CIDN__c='123445';
            
            lead MigrationLeadError = TestUtil.createLead(c.id,'lead', 'MigrationError', leadMigrationRecordTypeId,'testemailerror@gmail.com');//Modified as part of DIGI-11413 S21.15
            MigrationLeadError.Lead_Source_Original__c='Events';
            MigrationLeadError.Status='Accepted';
            MigrationLeadError.Digital_ready_date__c = system.today();
            MigrationLeadError.CIDN__c='123445';
            
            leadLst.add(EntLead);  //Modified as part of DIGI-11413 S21.15
            leadLst.add(MigrationLeadError);
            //Ends here.    
            
            //Aded as part of DIGI-11413 S21.15 .Starts here
            lead EnterpriseLead = TestUtil.createLead(c.id,'lead', 'Enterprise', leadEnterpriseRecordTypeId,'testEnterpriseLeademail@gmail.com');
            EnterpriseLead.Lead_Source_Original__c='Events';
            EnterpriseLead.Status='Qualified';
            EnterpriseLead.Digital_ready_date__c = system.today();
            EnterpriseLead.CIDN__c='123445';
            leadLst.add(EnterpriseLead);
            //ends here.

        insert leadLst;
            
        lead l3 = [SELECT id FROM lead WHERE lastname='acbcd' ];
        l3.Lead_Type__c='Call Me Now';
        l3.Contact_Name__c = source1.id;
        update l3;
            
            //Added as part of DIGI-34437 S21.15.starts here. Modified as part of DIGI-11413 S21.15
            Task MigrationLeadTask = TestUtil.createTask(EntLead.Id, 'Completed' ,'First Bill Check Task');
            insert MigrationLeadTask;
            //ends here.
            
            List<Account> acc = new List<Account>();
            for(Integer i=0;i<=5; i++){
               Account lstAcc = TestUtil.createAccount('Test Account'+i); 
                lstAcc.APTPS_Tier__c = System.Label.AccountSegmentMidMarket;
                lstAcc.Vertical__c = System.Label.AccountVerticalNBCGrowth;
                acc.add(lstAcc);
            }
            insert acc;
            Account oneAcc = [Select id from Account where Name =:'Test Account2'];
            User salesuser = [select id,username from User where username =:'salesuser@testsales.com' limit 1];
            AccountTeamMember atm1 = TestUtil.createAccountTeamMember(salesuser.Id,'Edit',System.Label.AccountTeamMemberOpportunityApprover,oneAcc.Id);
            insert atm1;
            
             //DIGI-3187 ::Ends here
        Test.stopTest();        
        }}
    
    public static testMethod void  unittest(){
        test.starttest();
        Lead l=[SELECT id, region__c FROM lead limit 1];
        system.assertEquals(l.Region__c, 'APAC');
        test.stoptest();
    }
    
    @isTest
    static void updateLeadOwnerOnLeadUpdateTest(){
        test.startTest();
        Account ac = new Account(Name = 'name1',Pref_Comm_Method__c = 'Phone',Phone = '0400111222',Migrated_Customer__c = true,CIDN__c='12344566',Customer_Status__c='ACTIVE',APTPS_Tier__c = 'Enterprise & Government');
        insert ac; 
        
        Contact co = new Contact (lastname='lastname',Accountid=ac.id);
        insert co;
        
        list<lead> leadLst = new list<lead>();
        lead t=new lead(lastname='lead1',firstname='frst',company='telstra test inc.',recordtypeid=Schema.SObjectType.lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId(), //Replaced with Developer Name of Enterprise Lead Record Type
                        phone='031245678',Lead_Source_Original__c='Events',CIDN__c='12344566',Contact_Id__c=Co.id);
        leadLst.add(t);
        lead t1=new lead(lastname='lead2',firstname='frst',company='telstra test inc.',recordtypeid=Schema.SObjectType.lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId(),  //Replaced with Developer Name of Enterprise Lead Record Type
                         phone='031245678',Lead_Source_Original__c='Events',Customer_name__c=ac.id,Contact_Name__c=Co.id);
        leadLst.add(t1);
        
        insert leadLst;
        
        system.assertEquals(t.OwnerId, Ac.OwnerId);
        test.stopTest();
    }
    
   static testMethod void leadBulkInsert(){
        UserRole r = [Select DeveloperName, Id From UserRole where DeveloperName='Sales_Ops' limit 1]; 
        id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise').getRecordTypeId();
        id accRecordTypeIdpartner = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        id pconRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Partner Contact').getRecordTypeId();
        id conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact layout').getRecordTypeId();
        id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId();
        
        profile pSysAdmin = [select id,name from Profile where Name =:'System Administrator'];
        list<profile> prmProfile = [select id,name from Profile where Name =:'PRM Community User - Australia']; // fetching PRM profile

        User uSysAdmin = new User(alias = 'Con123', email = 'ContactTr8wrw98@noemail.com', emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = pSysAdmin.id, country = 'United States', IsActive = true, timezonesidkey = 'America/Los_Angeles', username = 'Cont987657awqas@noemail.com', userroleid = r.id);
        // v1.1 creating additional Admin user
        User uSysAdmin1 = new User(alias = 'Con1234', email = 'ContactTr8wrw99@noemail.com', emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = pSysAdmin.id, country = 'United States', IsActive = true, timezonesidkey = 'America/Los_Angeles', username = 'Cont987658awqas@noemail.com', userroleid = r.id);

        insert uSysAdmin;
        system.debug('uSysAdmin***********'+uSysAdmin);
        list<Account> acc;
        list<Contact> con;
        list<Account> partneracc;
        // v1.1 adding account / contact records
        System.runAs(uSysAdmin){
            // creating business account
            acc = PRMTestUtility.createAccounts(1,accRecordTypeId);
            insert acc;
            
            // creating partner contact
            con = PRMTestUtility.createContact(1, conRecordTypeId, acc[0].Id);
            con.addAll(PRMTestUtility.createContact(1, pconRecordTypeId,null));
            insert con;
            
            // creating partner account
            partneracc = PRMTestUtility.createPartnerAccounts(1,accRecordTypeIdpartner,'Partner','Active',null);
            partneracc[0].PartnerPrincipalContact__c = con[0].id;
            insert partneracc;
            
            // enabling account as partner
            partneracc[0].isPartner = true;
            update partneracc;
        }
        
        // v1.1 running as a different user to prevent Mix DML error
        System.runAs(uSysAdmin1){
            Test.startTest();
            // creating partner principal contact user
            list<User> lstPPCUsers = PRMTestUtility.createPartnerUsers(1, prmProfile, con,true);
            insert lstPPCUsers;
            
            list<lead> leadLst = PRMTestUtility.createLeads(10, leadRecordtypeId, acc[0].Id, partneracc[0].Id, con[0].Id, 'MOBILES'); //Modified count of rec from 20 to 10 as part of s21.12 to elminate cpu time limit error
            for(Lead objL : leadLst){
                objL.Trigger_Share_with_Partner__c = true;
                objL.isBulkSharedLead__c = false;
            }
            leadLst.addAll(PRMTestUtility.createLeads(10, leadRecordtypeId, acc[0].Id, partneracc[0].Id, con[0].Id, 'MOBILES')); //Modified count of rec from 20 to 10 as part of s21.12 to elminate cpu time limit
            for(Lead objL : leadLst){
                objL.Trigger_Share_with_Partner__c = false;
                objL.isBulkSharedLead__c = false;
            }
            
            //Modified as part of S21.12 to stop from Cpu time limit exceeded error.
           // Test.startTest();
            insert leadLst;
             for(Lead objL : leadLst){
                objL.Trigger_Share_with_Partner__c = true;
            }
            update leadLst;
            Test.stopTest();
            
            list<Lead> l = [Select Id, isBulkSharedLead__c from Lead where Id IN :leadLst and isBulkSharedLead__c = false];
            system.assertEquals(l.size(), 0);
        }
    }
/****************************************************************************
    @Method Name: assignAccTeamMemToOwnerIdTest
    @Author: SFO/pallavi
    @Sprint :sprint 21.12 [DIGI-3187]
    @CreateDate: 25/08/2021
******************************************************************************/     
    @istest
    public static void assignAccTeamMemToOwnerIdTest(){
        id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId();
        Account acc = [Select id from Account where Name =:'Test Account2'];
        User adminuser1 = [select id,username from User where username =:'adminuser@testsales.com' limit 1];
        User salesuser = [select id,username from User where username =:'salesuser@testsales.com' limit 1];
        
        system.runAs(adminuser1){
            Test.startTest();
            Lead objLead = new Lead();
            objLead.RecordtypeId = leadRecordTypeId;
            objLead.FirstName = 'First';
            objLead.LastName = 'Last';
            objLead.Company = 'Company ';
            objLead.Customer_Name__c = acc.Id;
            objLead.Email = 'lead@test.com';
            objLead.Phone = '+61 99998800';
            insert objLead;
            Test.stopTest();
        }
        list<Lead> lstLeads = [select id, OwnerId from lead where FirstName = 'first' LIMIT 1];
        system.assertequals(lstLeads[0].OwnerId ,salesuser.id);
    } 
/****************************************************************************
    @Method Name: assignAccTeamMemToOwnerId
    @Author: SFO/pallavi
    @Sprint :sprint 21.12 [DIGI-3187]
    @CreateDate: 25/08/2021
******************************************************************************/ 
 @istest
    public static void assignAccTeamMemToOwnerIdTest1(){
        id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId();
        list<Group> queueList = [select Id,name,developerName from Group where Type = 'Queue' AND developerName = :System.Label.QueueBCSLeadQueue LIMIT 1];
        Account acc1 = [Select id from Account where Name =:'Test Account1'];
        User adminuser2 = [select id,username from User where username =:'adminuser@testsales.com' limit 1];
        system.runAs(adminuser2){
            Test.startTest();
            Lead objLead = new Lead();
            objLead.RecordtypeId = leadRecordTypeId;
            objLead.FirstName = 'First';
            objLead.LastName = 'Last';
            objLead.Company = 'Company ';
            objLead.Customer_Name__c = acc1.Id;
            objLead.Email = 'lead@test.com';
            objLead.Phone = '+61 99998800';
            insert objLead;
            Test.stopTest();
        }
        list<Lead> lstLeads = [select id, OwnerId from lead where FirstName = 'first' LIMIT 1];
        system.assertequals(lstLeads[0].OwnerId , queueList[0].id);  
        system.assertNotEquals(lstLeads[0].OwnerId, adminuser2.Id);
    } 
/****************************************************************************
@Method Name: customLeadRoutingNS
@Author: SFO/Chhaveel
@Sprint :sprint 21.13 [DIGI-5740]
@CreateDate: 17/09/2021
@scenario : When a lead is created with 'Network Solutions' Domain and routed to Account team Member with 'Network Sales Specialist' role
******************************************************************************/ 
    @istest
    public static void customLeadRoutingNSTest1(){
        id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId();
        Account acc1 = [Select id from Account where Name =:'Name'];
        User adminuser2 = [select id,username from User where username =:'adminuser@testsales.com' limit 1];
        User salesuser = [select id,username from User where username =:'salesuser@testsales.com' limit 1];
        system.runAs(adminuser2){
            Test.startTest();
            Lead objLead = new Lead();
            objLead.RecordtypeId = leadRecordTypeId;
            objLead.FirstName = 'First';
            objLead.LastName = 'Last';
            objLead.Company = 'Company ';
            objLead.Customer_Name__c = acc1.Id;
            objLead.Email = 'lead@test.com';
            objLead.Phone = '+61 99998800';
            objLead.Domains__c = 'Network Solutions';
            insert objLead;
            Test.stopTest();
        }
        list<Lead> lstLeads = [select id, OwnerId from lead where FirstName = 'first' LIMIT 1];
        system.assertequals(lstLeads[0].OwnerId ,salesuser.id);  
        system.assertNotEquals(lstLeads[0].OwnerId, adminuser2.Id);
        
    }
/****************************************************************************
@Method Name: customLeadRoutingNS
@Author: SFO/Chhaveel
@Sprint :sprint 21.13 [DIGI-5740]
@CreateDate: 17/09/2021
@scenario : When a lead is created with 'Network Solutions' Domain and routed to Network Solutions Lead Queue
******************************************************************************/ 
    @istest
    public static void customLeadRoutingNSTest2(){
        id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId();
        list<Group> queueList = [select Id,name,developerName from Group where Type = 'Queue' AND developerName = 'Network_Solutions_Lead_Queue'];
        Account acc1 = [Select id from Account where Name =:'Name2'];
        User adminuser2 = [select id,username from User where username =:'adminuser@testsales.com' limit 1];
        system.runAs(adminuser2){
            Test.startTest();
            Lead objLead = new Lead();
            objLead.RecordtypeId = leadRecordTypeId;
            objLead.FirstName = 'First';
            objLead.LastName = 'Last';
            objLead.Company = 'Company ';
            objLead.Customer_Name__c = acc1.Id;
            objLead.Email = 'lead@test.com';
            objLead.Phone = '+61 99998800';
            objLead.Domains__c = 'Network Solutions';
            insert objLead;
            Test.stopTest();
        }
        list<Lead> lstLeads = [select id, OwnerId from lead where FirstName = 'first' LIMIT 1];
        system.assertequals(lstLeads[0].OwnerId , queueList[0].id); 
        system.assertNotEquals(lstLeads[0].OwnerId, adminuser2.Id);
        
    }
    
    /****************************************************************************
@Method Name: customLeadRoutingMMS
@Author: SFO/Chhaveel
@Sprint :sprint 21.13 [DIGI-5740]
@CreateDate: 17/09/2021
@scenario : When a lead is created with 'Mobility & Managed Services' Domain and routed to Territory user with 'Client Partner' role
******************************************************************************/ 
    @istest
    public static void customLeadRoutingMMSTest1(){
        id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId();
        Account acc1 = [Select id from Account where Name =:'Name2'];
        User adminuser2 = [select id,username from User where username =:'adminuser@testsales.com' limit 1];
        User roleUser = [select id,username from User where username =:'test1@test.com.portfoliotest' limit 1];
        Territory2 trty2 = [select id , DeveloperName  from Territory2 where DeveloperName = 'TST01' limit 1];
        system.runAs(adminuser2){
            Test.startTest();
            UserTerritory2Association uta1 = new UserTerritory2Association(UserId = roleUser.Id, Territory2Id = trty2.Id , RoleInTerritory2 = System.Label.Territory_Role_Client_Partner);
            insert uta1;
            Lead objLead = new Lead();
            objLead.RecordtypeId = leadRecordTypeId;
            objLead.FirstName = 'First';
            objLead.LastName = 'Last';
            objLead.Company = 'Company ';
            objLead.Customer_Name__c = acc1.Id;
            objLead.Email = 'lead@test.com';
            objLead.Phone = '+61 99998800';
            objLead.Domains__c = System.Label.LeadDomainMobility_Managed_Services;
            insert objLead;
            Test.stopTest();
        }
        list<Lead> lstLeads = [select id, OwnerId from lead where FirstName = 'first' LIMIT 1];
        system.assertequals(lstLeads[0].OwnerId ,roleUser.Id); 
        system.assertNotEquals(lstLeads[0].OwnerId, adminuser2.Id);
    }
    
    /****************************************************************************
@Method Name: customLeadRoutingMMS
@Author: SFO/Chhaveel
@Sprint :sprint 21.13 [DIGI-5740]
@CreateDate: 17/09/2021
@scenario : When a lead is created with 'Mobility & Managed Services' Domain and routed to Territory user with 'General Manager' role
******************************************************************************/ 
    @istest
    public static void customLeadRoutingMMSTest2(){
        id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId();
        Group queueList = [select Id,name,developerName from Group where Type = 'Queue' AND developerName = 'Network_Solutions_Lead_Queue'];
        Account acc1 = [Select id from Account where Name =:'Name2'];
        User adminuser2 = [select id,username from User where username =:'adminuser@testsales.com' limit 1];
        User roleUser = [select id,username from User where username =:'test1@test.com.portfoliotest' limit 1];
        Territory2 trty2 = [select id , DeveloperName  from Territory2 where DeveloperName = 'TST01' limit 1];
        system.runAs(adminuser2){
            Test.startTest();
            UserTerritory2Association uta2 = new UserTerritory2Association(UserId = roleUser.Id, Territory2Id = trty2.Id , RoleInTerritory2 = System.Label.Territory_Role_General_Manager);
            insert uta2;
            Lead objLead = new Lead();
            objLead.RecordtypeId = leadRecordTypeId;
            objLead.FirstName = 'First';
            objLead.LastName = 'Last';
            objLead.Company = 'Company ';
            objLead.Customer_Name__c = acc1.Id;
            objLead.Email = 'lead@test.com';
            objLead.Phone = '+61 99998800';
            objLead.Domains__c = System.Label.LeadDomainMobility_Managed_Services;
            insert objLead;
            Test.stopTest();
        }
        list<Lead> lstLeads = [select id, OwnerId from lead where FirstName = 'first' LIMIT 1];
        system.assertequals(lstLeads[0].OwnerId ,roleUser.Id); 
        system.assertNotEquals(lstLeads[0].OwnerId, adminuser2.Id);
    }
    
    /****************************************************************************
@Method Name: customLeadRoutingMMS
@Author: SFO/Chhaveel
@Sprint :sprint 21.13 [DIGI-5740]
@CreateDate: 17/09/2021
@scenario : When a lead is created with 'Mobility & Managed Services' Domain and routed to Territory user with 'Group Account Owner' role
******************************************************************************/ 
    @istest
    public static void customLeadRoutingMMSTest3(){
        id leadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Enterprise).getRecordTypeId();
        Group queueList = [select Id,name,developerName from Group where Type = 'Queue' AND developerName = 'Network_Solutions_Lead_Queue'];
        Account acc1 = [Select id from Account where Name =:'Name2'];
        User adminuser2 = [select id,username from User where username =:'adminuser@testsales.com' limit 1];
        User roleUser = [select id,username from User where username =:'test1@test.com.portfoliotest' limit 1];
        Territory2 trty2 = [select id , DeveloperName  from Territory2 where DeveloperName = 'TST01' limit 1];
        system.runAs(adminuser2){
            Test.startTest();
            UserTerritory2Association uta3 = new UserTerritory2Association(UserId = roleUser.Id, Territory2Id = trty2.Id , RoleInTerritory2 = System.Label.Territory_Role_Group_Account_Owner);
            insert uta3;
            Lead objLead = new Lead();
            objLead.RecordtypeId = leadRecordTypeId;
            objLead.FirstName = 'First';
            objLead.LastName = 'Last';
            objLead.Company = 'Company ';
            objLead.Customer_Name__c = acc1.Id;
            objLead.Email = 'lead@test.com';
            objLead.Phone = '+61 99998800';
            objLead.Domains__c = System.Label.LeadDomainMobility_Managed_Services;
            insert objLead;
            Test.stopTest();
        }
        list<Lead> lstLeads = [select id, OwnerId from lead where FirstName = 'first' LIMIT 1];
        system.assertequals(lstLeads[0].OwnerId ,roleUser.Id); 
        system.assertNotEquals(lstLeads[0].OwnerId, adminuser2.Id);
    }
    

/****************************************************************************
    @Method Name: TestFirstBillTaskOnUpdate
    @Author: SFO/pallavi
    @Sprint :sprint 21.15 [DIGI-34437]
    @CreateDate: 29/10/2021
******************************************************************************/ 
    @istest
    public static void TestFirstBillTaskOnUpdate(){
        User adminuser2 = [select id,username from User where username =:'adminuser@testsales.com' limit 1];
        Lead MigrationLead = [select id from Lead where Email ='testemail12@gmail.com' limit 1 ];
        Task FirstBillTask = [Select id,Subject from Task where WhoId =:MigrationLead.Id and Subject like : Label.TaskSubjectFirstBillPercentile and Status =:System.Label.Task_Status_Completed];
        system.runAs(adminuser2){
            Test.startTest();
            MigrationLead.RecordTypeId =Schema.SObjectType.lead.getRecordTypeInfosByDeveloperName().get(Label.Lead_Recordtype_Migration).getRecordTypeId();
            Update MigrationLead;
            Test.stopTest();
        }
        Lead lstLeads = [select id,FirstBillTaskOnLead__c from lead where Email ='testemail12@gmail.com' limit 1];
        system.assertequals(lstLeads.FirstBillTaskOnLead__c , true);  
   }
    /****************************************************************************
    @Method Name: TestFirstBillTaskOnUpdate
    @Author: SFO/pallavi
    @Sprint :sprint 21.15 [DIGI-34437]
    @CreateDate: 29/10/2021
   ******************************************************************************/ 
    @istest
    public static void TestMigrationLeadConversion(){
        User adminuser2 = [select id,username from User where username =:'adminuser@testsales.com' limit 1];
        Lead MigrationLead = [select id,Customer_Name__c,status,Name from Lead where Email ='testemailerror@gmail.com' limit 1 ];
        system.runAs(adminuser2){
          Test.startTest();
            Database.LeadConvert lc = new database.LeadConvert(); 
            Database.LeadConvertResult lcr ;
            LeadStatus convertStatus4 = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
                lc.setLeadId( MigrationLead.Id ); 
                lc.setAccountId(MigrationLead.Customer_Name__c);
                lc.setDoNotCreateOpportunity( true );  
                lc.setConvertedStatus(convertStatus4.MasterLabel);
            try{
                lcr = Database.convertLead(lc, false); 
            }catch(Exception e){
               system.debug( 'Errors are ' + lcr.getErrors() ); 
            }
            
          Test.stopTest();
        }
        Lead lstLeads = [select id,FirstBillTaskOnLead__c,IsConverted from lead where Email ='testemail12@gmail.com' limit 1];
        system.assertequals(lstLeads.IsConverted , false);  
   }
    /****************************************************************************
    @Method Name: TestEnterpriseLeadConversionErrorOnStage
    @Author: SFO/pallavi
    @Sprint :sprint 21.15 [DIGI-11413]
    @CreateDate: 09/11/2021
   ******************************************************************************/ 
  @istest
  public static void TestEnterpriseLeadConversionErrorOnStage(){
      User adminuser2 = [select id,username from User where username =:'adminuser@testsales.com' limit 1];
      Lead EnterpriseLead = [select id,Customer_Name__c,status,Name from Lead where Email ='testEnterpriseLeademail@gmail.com' limit 1 ];
      system.runAs(adminuser2){
        Test.startTest();
          Database.LeadConvert lc = new database.LeadConvert(); 
          Database.LeadConvertResult lcr ;
          LeadStatus convertStatus4 = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
              lc.setLeadId( EnterpriseLead.Id ); 
              lc.setAccountId(EnterpriseLead.Customer_Name__c);
              lc.setDoNotCreateOpportunity( true );  
              lc.setConvertedStatus(convertStatus4.MasterLabel);
          try{
              lcr = Database.convertLead(lc, false); 
          }catch(Exception e){
             system.debug( 'Errors are ' + lcr.getErrors() ); 
          }
          
        Test.stopTest();
      }
      Lead lstLeads = [select id,FirstBillTaskOnLead__c,IsConverted from lead where Email ='testemail12@gmail.com' limit 1];
      system.assertequals(lstLeads.IsConverted , false);  
 }
}