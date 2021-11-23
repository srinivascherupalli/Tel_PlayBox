/*******************************************************************
@Class Name:ReturnListViewDetailsTest
@Sprint :20.06  & P2OB-5923
@Author:SFO Team (Sri)
@CreateDate: 22/04/2020
@Description:Test class for ReturnListViewDetails .
@Last Modified        : 07/01/2021 21.01 by sravanthi, Team SFO
                        as part of P2OB-9943/P2OB-6772 updating API version to 50.
                        11/11/2021 21.15.03 fastlane duplicate username fix
*********************************************************************/
@isTest
public class ReturnListViewDetailsTest {
    @testSetup static void setup() {
        User adminUser = TestUtil.createUser('admina1s2@test.com', 'adm', System.Label.Profile_SystemAdmin);
        insert adminUser;
        system.runas(adminUser){
            Test.startTest();
            UserRole r = [Select id,DeveloperName From UserRole where DeveloperName = 'Sales_Ops' limit 1];
            Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise];
            User salesUser1 = TestUtil.createTestUser(r.id,pf.id,'salesone','Testing');
            salesUser1.Phone = '0445678001';
            insert salesUser1;
            User salesUser2 = TestUtil.createTestUser(r.id,pf.id,'salestwo','Testing');
            salesUser2.Phone = '0445678002';
            insert salesUser2;

            User salesUser3 = TestUtil.createTestUser(r.id,pf.id,'salesthree','Testing');
            salesUser3.Phone = '0445678002';
            insert salesUser3;

            Id accEnterpriseRecTypeId = PhoenixGlobalUtil.getRecordTypeByName('Account').get(System.Label.Account_RecordType_Enterprise).getRecordTypeId(); // fetch account's enterprise record type id
            Id conContactLayoutRecTypeId = PhoenixGlobalUtil.getRecordTypeByName('Contact').get(System.Label.Contact_layout_record_type).getRecordTypeId(); // fetch contact's contact layout record type id
            List<Account> accList = new List<Account>();
            List<Contact> conList = new List<Contact>();
            
            Account accMidMarket = TestUtil.createAccount('NBA Account Positive');
            accMidMarket.RecordtypeId = accEnterpriseRecTypeId;
            accMidMarket.APTPS_Tier__c = system.label.AccountSegmentMidMarket;
            accMidMarket.OwnerId=salesUser1.id;
            accList.add(accMidMarket);
            
            Account acc2 = TestUtil.createAccount('Test Account');
            acc2.RecordtypeId = accEnterpriseRecTypeId;
            acc2.OwnerId=salesUser2.id;
            accList.add(acc2);
            

            Account accTConnect = TestUtil.createAccount('NBA TConnect Account Positive');
            accTConnect.RecordtypeId = accEnterpriseRecTypeId;
            accTConnect.APTPS_Tier__c = system.label.AccountSegmentEntAndGovt;
            accTConnect.OwnerId=salesUser3.id;
            accList.add(accTConnect);
			
			insert accList;

            for(integer i=0;i<10;i++){
                Contact con = TestUtil.createContact(acc2.id,'First'+i,'Last'+i);
                con.OwnerId=salesUser2.id;
                con.Email_status__c = true;
                con.lastVerifiedDate__c = Date.today().addDays(-200);
                conlist.add(con);
            }
            insert conList;
            Test.stopTest();
        }
    }
    
    /*
Team SFO, sprint 20.06, P2OB-5923(Sri)  
Testmethod to cover NBA recomendation for Accounts
Main class is ReturnListViewDetails
*/
    @isTest
    static void testNBAAccounts(){
        User salesUser = [Select id from User where FirstName='salesone'];
        system.runas(salesUser){
            Test.startTest();
            List<ReturnListViewDetails.ListViewInfo> listViews = ReturnListViewDetails.getNBAListViewsInfo();
            System.assertEquals(1,listViews.size());
            
            Account acc = [select id, Name, Recent_Activity_Date__c, Reaching_out_to_Customer__c  from Account where name ='NBA Account Positive'];
            Task healcheck= new Task(Subject= 'Health Check test',Priority= 'Normal',Status='Not Started',OwnerId=salesUser.ID,WhatId=acc.id);
            insert healcheck;
            List<ReturnListViewDetails.ListViewInfo> listViewsUpdated = ReturnListViewDetails.getNBAListViewsInfo();  
            System.assertEquals(null,listViewsUpdated);
            acc.Recent_Activity_Date__c = null;
            update acc;
            ReturnListViewDetails.getNBAListViewsInfo();  
            Test.stopTest();            
        }
    }
/*
Team SFO, sprint 20.07, P2OB-6501(Sravanthi)  
Testmethod to cover NBA T Connect recomendation for Accounts
Main class is ReturnListViewDetails
*/
    @isTest
    static void testNBATConnectAccounts(){
        User salesUser = [Select id from User where FirstName='salesthree'];
        system.runas(salesUser){
            Test.startTest();
            List<ReturnListViewDetails.ListViewInfo> listViews = ReturnListViewDetails.getNBAListViewsInfo();
            System.assertEquals(1,listViews.size());
            
            Account acc = [select id, Name, Recent_Activity_Date__c, Reaching_out_to_Customer__c  from Account where name ='NBA TConnect Account Positive'];
            Task tConnect= new Task(Subject= 'Health Check test',Priority= 'Normal',Status='Not Started',Type=System.Label.Telstra_Connect_Task_Type,OwnerId=salesUser.ID,WhatId=acc.id);
            insert tConnect;
            List<ReturnListViewDetails.ListViewInfo> listViewsUpdated = ReturnListViewDetails.getNBAListViewsInfo();  
            acc.Recent_Activity_Date__c = null;
            update acc;
            System.assertEquals(null,acc.Recent_Activity_Date__c);
            ReturnListViewDetails.getNBAListViewsInfo();  
            Test.stopTest();            
        }
    }

    /*
Team SFO, sprint 20.06, P2OB-5923(Sri)  
Testmethod to cover NBA recomendation for invalid emial contacts and contacts need to verify
Main class is ReturnListViewDetails
*/
    @isTest
    static void testNBAContacts(){
        User salesUser = [Select id from User where FirstName='salestwo'];
        system.runas(salesUser){
            try{
                Test.startTest();
                List<ReturnListViewDetails.ListViewInfo> listViews = ReturnListViewDetails.getNBAListViewsInfo();
                System.assertEquals(3,listViews.size());
                List<Contact> conInvalidEmailUpdate = new List<Contact>();
                List<Contact> conInvalidEmail = [SELECT Id,name, Phone,Relationship_Verified_Date__c,Email,Contact_Status__c,Email_status__c,isEmailBounced,lastVerifiedDate__c,RecordType.name,Pref_Comm_Method__c from Contact where ownerid =:salesUser.id];
                for(Contact con:conInvalidEmail){
                    con.Pref_Comm_Method__c = 'eMail';
                    con.Email = 'testVerify@test.com';
                    conInvalidEmailUpdate.add(con);
                }
                update conInvalidEmailUpdate;
                List<ReturnListViewDetails.ListViewInfo> listViewsMailUpdated = ReturnListViewDetails.getNBAListViewsInfo();  
                System.assertNotEquals(3,listViewsMailUpdated.size());
                Test.stopTest();            
            }catch(Exception ex){
                system.debug('Exception in testNBAContacts method ::: '+ex.getMessage());
                
            }}
    }
    
    /*
Team SFO, sprint 20.07, P2OB-6502(Sri,Amar)  
Testmethod to cover NBA recomendation for Opportunities
Main class is ReturnListViewDetails
*/
    @isTest
    static void approveRejectPartnerOpportunityNBA(){
        List<user> userList = new List<user>();
        test.starttest();
        UserRole r = [Select id,DeveloperName From UserRole where DeveloperName = 'Sales_Ops' limit 1];
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise];
        Profile pfAdmin = [select id from profile where name =:Label.Profile_SystemAdmin];
        User sales = TestUtil.createTestUser(r.id,pf.id,'salesLaTest','Testing');
        User admin = TestUtil.createTestUser(r.id,pfAdmin.id,'adminLaTest','Testing');
        sales.Phone = '0444444444';
        userList.add(sales);
        userList.add(admin);
        insert userList;
        Account customerAccount;
        Contact con;
        system.runas(admin){
            customerAccount=TestUtil.createAccount('Testacc');
            insert customerAccount;
            customerAccount.ownerid = sales.id;
            update customerAccount;
            con = TestUtil.createContact(customerAccount.id, 'TestNBAFN', 'TestNBALN');
            insert con;
        }
        
        system.runas(sales){
            Opportunity partnerOpp = TestUtil.createOpportunity(customerAccount.id);
            partnerOpp.Partner_Opportunity_Verification__c = 'Verification Required';
            insert partnerOpp;
            OpportunityContactRole oppConRole = TestUtil.createOCR(con, partnerOpp);
            insert oppConRole;
            
            List<ReturnListViewDetails.ListViewInfo> PartnerCreatedOpp = ReturnListViewDetails.getNBAListViewsInfo();
            System.assertNotEquals(0,PartnerCreatedOpp.size());
            test.stopTest();
        }
    }
}