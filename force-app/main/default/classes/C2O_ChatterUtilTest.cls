/********************************************************************************
* Class Name  : C2O_ChatterUtilTest
* Description : This class is test class for C2O_ChatterUtil functionality 
* Created By  : Sri     

********************************************************************************/
@isTest
public class C2O_ChatterUtilTest {
    @testSetup static void setup() {
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise]; 
        Profile pfAdmin = [select id from profile where name =:Label.Profile_SystemAdmin]; 
        
        List<user> userList = new List<user>();
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        User sales = TestUtil.createTestUser(r.id,pf.id,'salesuser','Testing');
        sales.username='salesuser@testsales.com';
        sales.email='salesuser@testsales.com';
        sales.phone='+121231231234';
        
        User admin = TestUtil.createTestUser(r.id,pfAdmin.id,'adminUser','Testing2');
        admin.username='TestingAdmin@TestingAdmin.com';
        admin.email='adminuser@testadmin.com';
        admin.phone='+121231231234';
        
        userList.add(sales);
        userList.add(admin);
        insert userList;
        
        system.runAs(admin){
            Account customerAccount=TestUtil.createAccount('Test Account');
            customerAccount.OwnerId=sales.id;
            insert customerAccount;
            
            Id myRecordTypeStandard  = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.label.Opp_RecordType_Defined).getRecordTypeId();
            Opportunity Opp =TestUtil.createOpportunity(customerAccount.Id);
            Opp.Name='standard opportunity';
            Opp.RecordTypeId = myRecordTypeStandard;
            Opp.Type = 'Renewal';
            Opp.Billing_Solution__c = 'Standard';
            Opp.Product_Domain__c = 'CLOUD SERVICES';
            Opp.Product_Type__c = 'Non Modular';
            Opp.ownerId = sales.id;
            insert Opp;
            
        }
    }
    @isTest
    public static void testCreateChatter(){
        User sales = [select id, name from User where username='salesuser@testsales.com'];
        System.runAs(sales){
            Opportunity Opp = [select id from Opportunity limit 1 ];
		C2O_ChatterUtil.ChatterFeedInfo feedInfo;
        List<C2O_ChatterUtil.ChatterFeedInfo> listOfchatterFeeds = new List<C2O_ChatterUtil.ChatterFeedInfo>();
		feedInfo = new C2O_ChatterUtil.ChatterFeedInfo(opp.Id,new set<Id>{sales.id},'Test Chatter');
		listOfchatterFeeds.add(feedInfo);
		test.startTest();
            if (!listOfchatterFeeds.isEmpty() ) {
                System.enqueueJob(new C2O_ChatterUtil.InvokeBulkChatterFeedQueueable(listOfchatterFeeds));
            }
            test.stopTest();
        }
    }
    
}