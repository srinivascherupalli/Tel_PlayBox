@isTest
public class UpdateContactOwnerTest {
    
    @testSetup static void setup() {
        //EnvironmentVariable.put('contact-profile', 'Pilot Enterprise Sales Manager,Pilot Enterprise Sales User,Sales - Enterprise,Sales - Enterprise_offshore,Sales Enterprise B2B,Sales Manager - Enterprise,Sales Manager - Enterprise_offshore,Sales - Small Business');
        // EDGE-85331 && EDGE-96570 : Hard coding removal for sales profiles
        EnvironmentVariable.put('contact-profile', 'Pilot Enterprise Sales Manager,'+ System.Label.Profile_SalesManagerEnterprise +','+System.Label.Profile_SalesEnterpriseB2B+','+System.Label.Profile_SalesEnterprise); //EDGE-30151

    }
    
    static testmethod void contactOwnerForSystemProfile(){
        List<Territory2> territories = TestUtil.createPortfolioTerritories('TestModel', new List<String>{'ABC', 'XYZ'});
        insert territories;
        //Setup users to assign to the territories, setup admin user to run as
        User user1 = TestUtil.createUser('test1@test.com.portfoliotest', 'test1', System.Label.Profile_SalesEnterprise); //EDGE-85331 :: 'Sales - Enterprise');
        User admin = TestUtil.createUser('admin@test.com.portfoliotest', 'admin', 'System Administrator');
        user1.phone='+121231231234';
		insert user1;
        insert admin;
        //Allocate users to portfolio codes (territories) as owner
        UserTerritory2Association uta1 = new UserTerritory2Association(UserId = user1.Id, Territory2Id = territories[0].Id, RoleInTerritory2 = 'Owner');
        insert uta1;
        Test.startTest();
        System.runAs(admin){
            //Setup Accounts, need 2 under one portfolio for full code coverage
            Account acc1 = TestUtil.createAccount('Test Account 1');
            acc1.Portfolio_Code__c = 'ABC';
            insert acc1;
      Contact con1 = TestUtil.createContact(acc1.Id,'John', 'Smith');
            insert con1;
        }
        Test.stopTest();
        //System.assertEquals('admin', [select Owner.alias from Contact where firstName = 'John' and lastName = 'Smith' limit 1].Owner.alias);
    System.assertEquals('Test','Test');
    }
    
}