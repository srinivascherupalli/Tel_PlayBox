/*
    AUTHOR : Lok Jackson
    DESCRIPTION : Covers test coverage for UserTerritory2Association Trigger
*/

@IsTest
public class UserTerritory2AssociationTest  {

	// Based on insert of the Owner role on a Territory, all Accounts and Open Opportunities within that Territory should be reassigned to the Territory owner
	// Note in this context Territory and Portfolio Code are analogous
	@isTest
    static void testTerritoryOwnerInsert(){
    	//Setup Portfolio Territories (assumes existing model and type are in place)
        List<Territory2> territories = TestUtil.createPortfolioTerritories('TestModel', new List<String>{'ABC'});
        insert territories;
		list<User> UserList = new list<User>();
        //Setup users to assign to the territories, setup admin user to run as
        User user1 = TestUtil.createUser('test1@test.com.portfoliotest', 'test1', System.Label.Profile_SalesEnterprise); // EDGE-85331 :: 'Sales - Enterprise');
        User user2 = TestUtil.createUser('test2@test.com.portfoliotest', 'test2', System.Label.Profile_SalesEnterprise); // EDGE-85331 :: 'Sales - Enterprise');
        User admin = TestUtil.createUser('admin@test.com.portfoliotest', 'admin', 'System Administrator');
		user1.phone='+121231231231';
        user2.phone='+121231231231';
        
        UserList.add(user1);
        UserList.add(user2);
        UserList.add(admin);	
        insert UserList;
        System.runAs(admin){
			//Setup Account and Opportunities, need to do this in different context to avoid mixed DML
			Account acc1 = TestUtil.createAccount('Test Account 1');
			acc1.Portfolio_Code__c = 'ABC';
            acc1.Customer_Status__c ='Active';
			insert acc1;
			Opportunity o1 = new Opportunity(Name='Test1', StageName = 'Develop', CloseDate = Date.today(), AccountId = acc1.Id);
			insert o1;
			Opportunity o2 = new Opportunity(Name='Test2', StageName = 'Develop', CloseDate = Date.today(), AccountId = acc1.Id, Attachment_Count__c=1, Won_Lost_Reason__c = 'Quality of Service');
			insert o2;
			//Now close the opportunity
			o2.StageName = 'Closed Won';
			update o2;
		}

		Test.startTest();
        //Allocate user1 to portfolio code (territories) as owner
		UserTerritory2Association uta1 = new UserTerritory2Association(UserId = user1.Id, Territory2Id = territories[0].Id, RoleInTerritory2 = 'Owner');
		insert uta1;
		//Stop test so we can assert results of async call that runs the update job
		Test.stopTest();

		System.assertEquals('test1', [select Owner.alias from Account where Name = 'Test Account 1' limit 1].Owner.alias);
		//System.assertEquals('test1', [select Owner.alias from Opportunity where Name = 'Test1' limit 1].Owner.alias);
		//System.assertNotEquals('test1', [select Owner.alias from Opportunity where Name = 'Test2' limit 1].Owner.alias);

    }

    // Based on Updates to the Owner role on a Territory, all Accounts and Open Opportunities within that Territory should be reassigned to the new Territory owner
	// Note in this context Territory and Portfolio Code are analogous
	@isTest
    static void testTerritoryOwnerUpdate(){
    	//Setup Portfolio Territories (assumes existing model and type are in place)
        List<Territory2> territories = TestUtil.createPortfolioTerritories('TestModel', new List<String>{'ABC'});
        insert territories;
		list<User> UserList = new list<User>();
        //Setup users to assign to the territories, setup admin user to run as
        User user1 = TestUtil.createUser('test1@test.com.portfoliotest', 'test1', System.Label.Profile_SalesEnterprise); // EDGE-85331 :: 'Sales - Enterprise');
        User user2 = TestUtil.createUser('test2@test.com.portfoliotest', 'test2', System.Label.Profile_SalesEnterprise); // EDGE-85331 :: 'Sales - Enterprise');
        User admin = TestUtil.createUser('admin@test.com.portfoliotest', 'admin', 'System Administrator');
		user1.phone='+121231231231';
        user2.phone='+121231231231';
		
		UserList.add(user1);
        UserList.add(user2);
        UserList.add(admin);	
        insert UserList;
        System.runAs(admin){
			//Setup Account and Opportunities, need to do this in different context to avoid mixed DML
			Account acc1 = TestUtil.createAccount('Test Account 1');
			acc1.Portfolio_Code__c = 'ABC';
            acc1.Customer_Status__c ='Active';
			insert acc1;
			Opportunity o1 = new Opportunity(Name='Test1', StageName = 'Develop', CloseDate = Date.today(), AccountId = acc1.Id);
			insert o1;
			Opportunity o2 = new Opportunity(Name='Test2', StageName = 'Develop', CloseDate = Date.today(), Attachment_Count__c=1, AccountId = acc1.Id, Won_Lost_Reason__c = 'Quality of Service');
			insert o2;
			//Now close the opportunity
			o2.StageName = 'Closed Won';
			update o2;
		}

        //Allocate user1 to portfolio code (territories) as owner
		UserTerritory2Association uta1 = new UserTerritory2Association(UserId = user1.Id, Territory2Id = territories[0].Id, RoleInTerritory2 = 'Owner');
		insert uta1;
		UserTerritory2Association uta2 = new UserTerritory2Association(UserId = user2.Id, Territory2Id = territories[0].Id, RoleInTerritory2 = '');
		insert uta2;

		Test.startTest();
		//Modify Owner of Territory
		uta2.RoleInTerritory2 = 'Owner';
		update uta2;
		//Stop test so we can assert results of async call that runs the update job
		Test.stopTest();

		System.assertEquals('test2', [select Owner.alias from Account where Name = 'Test Account 1' limit 1].Owner.alias);
		//System.assertEquals('test2', [select Owner.alias from Opportunity where Name = 'Test1' limit 1].Owner.alias);
		//System.assertNotEquals('test2', [select Owner.alias from Opportunity where Name = 'Test2' limit 1].Owner.alias);
	}

}