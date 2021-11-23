@isTest
public class transactionLogCaptureTest {
    
    static testMethod void testdata() {
        List<user> userList = new List<user>();
        Map<String,Profile> profilesMap = new Map<String,Profile>();
        for(Profile profile : [Select Name, Id From Profile where Name in ('System Administrator','PRM Community User - Australia','Migration BOH user')])
            profilesMap.put(profile.Name, profile);
        
        User migrationUser = new User(alias = 'migBoh', email='migrationBOHUser@test.com',
                                      emailencodingkey='UTF-8', lastname='BOHUser', languagelocalekey='en_US',
                                      localesidkey='en_US', profileid =profilesMap.get('Migration BOH user').id, country='United States',IsActive =true,                
                                      timezonesidkey='America/Los_Angeles', username='migrationBOHUser02@test.com');
        userList.add(migrationUser);
        
        User admin = TestUtil.createUser('admin@test.com.LaTest','AdminLA',Label.Profile_SystemAdmin);
        User sales = TestUtil.createUser('sales@test.com.LaTest','SalesLA',Label.Profile_SalesEnterprise);
        sales.Phone = '0444444444';
        admin.Phone = '0444444444';
        userList.add(sales);
        userList.add(admin);
        insert userList;
        id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Standard').getRecordTypeId();
        Account customerAccount =new account();
        System.runAs(admin){
            customerAccount=TestUtil.createAccount('TestAccountCloseOppFlow');
            customerAccount.OwnerId=migrationUser.id;
            Insert customerAccount;
            List<Opportunity> opportunityList=new List<Opportunity>();
            Opportunity closeOppFlowOpp = TestUtil.createOpportunity(customerAccount.id);
            closeOppFlowOpp.recordTypeId=oppRecordTypeId;
            closeOppFlowOpp.Name='Test Close Flow Opportunity';
            closeOppFlowOpp.Proposal_Required_Date__c=System.today()+2;
            closeOppFlowOpp.CloseDate=System.today()+10;
            closeOppFlowOpp.StageName='Develop';
            closeOppFlowOpp.Description__c='Test';
            closeOppFlowOpp.Product_Domain__c='MOBILES';
            closeOppFlowOpp.Shared_Opportunity__c=True;
            closeOppFlowOpp.Product_Type__c = 'Non Modular';
            opportunityList.add(closeOppFlowOpp);
            
            
            insert opportunityList;
            
            
        }
        system.runAs(migrationUser){
            
            Opportunity migrationOpp = new Opportunity();
            migrationOpp.AccountId = customerAccount.Id;
            migrationOpp.recordTypeId=oppRecordTypeId;
            migrationOpp.Name = 'Migration Opportunity';
            migrationOpp.Product_Domain__c = 'Other';
            migrationOpp.StageName = 'Develop';
            migrationOpp.Product_Type__c = 'Modular';
            migrationOpp.CloseDate = System.Date.today();
            migrationOpp.Description__c = 'test';
            migrationOpp.Type = 'Migration';
            insert  migrationOpp;
            
            cscfga__Product_Basket__c migrationOppBasket = new cscfga__Product_Basket__c();
            migrationOppBasket.csbb__Account__c = customerAccount.Id;
            migrationOppBasket.Name = 'Migration Opportunity Basket';
            migrationOppBasket.cscfga__Opportunity__c = migrationOpp.Id;
            migrationOppBasket.Express_Flow__c = false;
            migrationOppBasket.Primary_Basket__c = True;
            migrationOppBasket.csbb__Synchronised_With_Opportunity__c = True;
            migrationOppBasket.csordtelcoa__Synchronised_with_Opportunity__c  = True;
            migrationOppBasket.csordtelcoa__Basket_Stage__c = 'Enriched';
            insert migrationOppBasket;
            
            Test.startTest();
            list<Opportunity> Opplist = [Select id, Name From Opportunity];
            transactionLogCapture.transactionLogCaptureMethod(Opplist);
            Test.stopTest();
        }
    }
}