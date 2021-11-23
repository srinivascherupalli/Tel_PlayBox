/*
AUTHOR : Lok Jackson
DESCRIPTION : Covers test coverage for Batch Assignment of Accounts and Open Opportunities based on Territory
This covers classes "BatchAccountAssignment" and "BatchOpportunityAssignment"
@Updated  : 20.12  & P2OB-8608 , Account owner assignment for portfolio codes not present in territory model
@Last Modified        : 07/01/2020 21.01 by Chhaveel, Team SFO
               				         as part of P2OB-9943/P2OB-6772 Removing Commented Code,debug Statements and updating API version to 50.
*/

@isTest
public class TerritoryBatchAssignmentTest  {
    
    @testSetup static void setup() {
        EnvironmentVariable.put('UpdateSalesAccExecutive', 'true');
    }
    
    @isTest
    static void testBatchAccountAndOpptyAssignment(){
        //Covers batch assignment of Accounts and child Opportunities based on Portfolio Code owner
        //Setup Portfolio Territories (assumes existing model and type are in place)
        List<Territory2> territories = TestUtil.createPortfolioTerritories('TestModel', new List<String>{'ABC', 'XYZ','EFG'});
        insert territories;
        
        //Setup users to assign to the territories, setup admin user to run as
        User user1 = TestUtil.createUser('test1@test.com.portfoliotest', 'test1', System.Label.Profile_SalesEnterprise); //EDGE-85331 :: 'Sales - Enterprise');
        User user2 = TestUtil.createUser('test2@test.com.portfoliotest', 'test2', System.Label.Profile_SalesEnterprise); //EDGE-85331 :: 'Sales - Enterprise');
        User admin = TestUtil.createUser('admin@test.com.portfoliotest', 'admin', 'System Administrator');
        //EDGE-30781:Replaced profiles hardcoding with Custompermission. Start
        User datahub = TestUtil.createUser('Datahub@test.com.portfoliotest', 'Datahub', System.label.Profile_Integration_Datahub);
        //EDGE-30781: End
        user1.phone='+121231231234';
        user2.phone='+121231231234';
        insert user1;
        insert user2;
        insert admin;
        insert datahub;
        
        //Allocate users to portfolio codes (territories) as owner
        UserTerritory2Association uta1 = new UserTerritory2Association(UserId = user1.Id, Territory2Id = territories[0].Id, RoleInTerritory2 = 'Owner');
        UserTerritory2Association uta2 = new UserTerritory2Association(UserId = user2.Id, Territory2Id = territories[1].Id, RoleInTerritory2 = 'Owner');
        insert uta1;
        insert uta2;
        
        Test.startTest();
        
        //Run as admin so that we don't get mixed DML exception due to setup objects earlier, and to reflect actual behaviour - 
        //Account creation and Portfolio Code updates would always be done via an Admin/Integration user
        System.runAs(admin){
            // 20.12  & P2OB-8608 Adding Custom Setting record
            Phoenix_Configurations__c phoenixConfigs = new Phoenix_Configurations__c();
            phoenixConfigs.BatchAccountOwnerUserID__c =datahub.id;
            insert phoenixConfigs;
            
            //Setup Accounts, need 2 under one portfolio for full code coverage
            Account acc1 = TestUtil.createAccount('Test Account 1');
            Account acc2 = TestUtil.createAccount('Test Account 2');
            Account acc3 = TestUtil.createAccount('Test Account 3');
            Account acc4 = TestUtil.createAccount('Test Account 4');
            Account acc5 = TestUtil.createAccount('Test Account 5');
            acc1.Portfolio_Code__c = 'ABC';
            acc1.CIDN__c = '7196277133';
            acc1.Customer_Status__c='ACTIVE';
            acc1.TCM_MasterID__c = '10012424554';
            acc2.Portfolio_Code__c = 'XYZ';
            acc2.CIDN__c = '7196277134';
            acc2.Customer_Status__c='ACTIVE';
            acc2.TCM_MasterID__c = '10012424555';
            acc3.Portfolio_Code__c = 'XYZ';
            acc3.CIDN__c = '7196277135';
            acc3.Customer_Status__c='ACTIVE';
            acc3.TCM_MasterID__c = '10012424556';
            acc4.Portfolio_Code__c = null;
            acc4.Customer_Status__c='ACTIVE';
            acc4.CIDN__c = '7196277136';
            acc4.TCM_MasterID__c = '10012424557';
            acc5.Portfolio_Code__c = 'EFG';
            acc5.Customer_Status__c='ACTIVE';
            acc5.CIDN__c = '7996277136';
            acc5.TCM_MasterID__c = '10012424257';
            List<Account> accountInsertList = new List<Account>{acc1, acc2, acc3, acc4, acc5 };
                insert accountInsertList;
            
            //Add an open opportunity to each and a closed to Account 2 (closed should not be transferred in the event of a port change)
            Opportunity o1 = new Opportunity(Name='Test1', StageName = 'Develop', CloseDate = Date.today(), AccountId = acc1.Id);
            Opportunity o2 = new Opportunity(Name='Test2', StageName = 'Develop', CloseDate = Date.today(), AccountId = acc2.Id);
            Opportunity o3 = new Opportunity(Name='Test3', StageName = 'Closed Won', CloseDate = Date.today(), AccountId = acc2.Id, Won_Lost_Reason__c = 'Quality of Service');
            List<Opportunity> oppInsertList = new List<Opportunity>{o1, o2, o3};
                insert oppInsertList;
            
            //Correct ownership will now exist due to triggers, so change to ensure we can test the batch is successful
            for(Account a: accountInsertList){
                if(String.isNotBlank(a.Portfolio_Code__c)){
                    a.OwnerId = admin.Id;
                }
            }
            update accountInsertList;
            
            for(Opportunity o: oppInsertList){
                o.OwnerId = admin.Id;
            }
            update oppInsertList;
            
            //Custom setting 
            insert new EnvironmentVariable__c(Name= 'UpdateSalesAccExecutive', Value__c = 'true');
            
            //Now run the reassigment Batch
            
            BatchAccountAssignment reassign = new BatchAccountAssignment();
            ID batchprocessid = Database.executeBatch(reassign);
            
        }
        
        Test.stopTest();
        
        //Confirm that the Accounts have been assigned to their respective portfolio owners
        System.assertEquals('test1', [select Owner.alias from Account where Name = 'Test Account 1' limit 1].Owner.alias);
        System.assertEquals('test2', [select Owner.alias from Account where Name = 'Test Account 2' limit 1].Owner.alias);
        System.assertEquals('test2', [select Owner.alias from Account where Name = 'Test Account 3' limit 1].Owner.alias);
        System.assertEquals('admin', [select Owner.alias from Account where Name = 'Test Account 5' limit 1].Owner.alias);
        Id accountOwnerId = [select Owner.Id from Account where Name = 'Test Account 4' limit 1].Owner.Id;
        // EDGE-30781:Replaced profiles hardcoding with Custompermission. Start
        System.assertEquals(System.label.Profile_Integration_Datahub, [SELECT Profile.Name FROM User WHERE Id = :accountOwnerId].Profile.Name);
        //EDGE-30781:End
        
    }
    
    @isTest
    static void testBatchAccountAccSegment(){
        User admin = TestUtil.createUser('admin@test.com.portfoliotest', 'admin', 'System Administrator');
        
        
        Test.startTest();
        System.runAs(admin){
            // 20.12  & P2OB-8608 Adding Custom Setting record
            Phoenix_Configurations__c phoenixConfigs = new Phoenix_Configurations__c();
        	phoenixConfigs.CALMS_Int_User_ID__c =admin.id;
        	insert phoenixConfigs;
            
            Account acc1 = TestUtil.createAccount('Test Account 1');
            Account acc2 = TestUtil.createAccount('Test Account 2');
            Account acc3 = TestUtil.createAccount('Test Account 3');
            Account acc4 = TestUtil.createAccount('Test Account 4');
            Account acc5 = TestUtil.createAccount('Test Account 5');
            acc1.Portfolio_Code__c = 'PCD01';
            acc1.CIDN__c = '7196277133';
            acc1.Customer_Status__c='ACTIVE';
            acc1.TCM_MasterID__c = '10012424554';
            acc1.APTPS_Tier__c = 'Mid-market';
            
            acc2.Portfolio_Code__c = 'PCD02';
            acc2.CIDN__c = '7196277134';
            acc2.Customer_Status__c='ACTIVE';
            acc2.TCM_MasterID__c = '10012424555';
            acc2.APTPS_Tier__c = 'Enterprise';
            
            acc3.Portfolio_Code__c = 'PCD02';
            acc3.CIDN__c = '7196277135';
            acc3.Customer_Status__c='ACTIVE';
            acc3.TCM_MasterID__c = '10012424556';
            acc3.APTPS_Tier__c = 'Government';
            
            acc4.Portfolio_Code__c = 'PCD03';
            acc4.Customer_Status__c='ACTIVE';
            acc4.CIDN__c = '7196277136';
            acc4.TCM_MasterID__c = '10012424557';
            acc4.APTPS_Tier__c = '';
            
            acc5.Portfolio_Code__c = '';
            acc5.Customer_Status__c='ACTIVE';
            acc5.CIDN__c = '7196277137';
            acc5.TCM_MasterID__c = '10012424558';
            acc5.APTPS_Tier__c = 'Government';
            
            List<Account> accountInsertList = new List<Account>{acc1, acc2, acc3, acc4, acc5};
                insert accountInsertList;
            
            Portfolio_Code__c portCode1 = TestUtil.createPortfolioCode('PCD01');
            Portfolio_Code__c portCode2 = TestUtil.createPortfolioCode('PCD02');
            Portfolio_Code__c portCode3 = TestUtil.createPortfolioCode('PCD03');
            portCode1.Tier__c = 'Enterprise';
            portCode2.Tier__c = 'Mid-market';
            portCode3.Tier__c = 'Government';
            List<Portfolio_Code__c> portCodeInsertList = new List<Portfolio_Code__c>{portCode1,portCode2,portCode3};
                insert portCodeInsertList;
            
            
            BatchAccountAssignment accSegmentUpdate = new BatchAccountAssignment();
            ID batchprocessid = Database.executeBatch(accSegmentUpdate);
        }
        Test.stopTest();
        
        System.assertEquals('Enterprise', [select APTPS_Tier__c from Account where Name = 'Test Account 1' limit 1].APTPS_Tier__c);
        System.assertEquals('Mid-market', [select APTPS_Tier__c from Account where Name = 'Test Account 2' limit 1].APTPS_Tier__c);
        System.assertEquals('Mid-market', [select APTPS_Tier__c from Account where Name = 'Test Account 3' limit 1].APTPS_Tier__c);
        System.assertEquals('Government', [select APTPS_Tier__c from Account where Name = 'Test Account 4' limit 1].APTPS_Tier__c);
        System.assertEquals('Government', [select APTPS_Tier__c from Account where Name = 'Test Account 5' limit 1].APTPS_Tier__c);
        
    }
    
}