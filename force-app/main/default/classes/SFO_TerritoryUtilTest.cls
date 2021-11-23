/********************************************************************************
* Class Name  : SFO_TerritoryUtilTest
* Description : This class is test class for SFO_TerritoryUtil functionality 
* Created By  : Sri    
* Modified By : Pallavi B (DIGI-8909) Sprint 21.13 Team SFO
********************************************************************************/
@isTest
public class SFO_TerritoryUtilTest {
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
            
            
            //Territory insertions
            List<Territory2> territoryInsList = new List<Territory2>();
            Territory2 terCodeUParent = TestUtil.createPortfolioTerritories('TestModel', 'N0010');
            territoryInsList.add(terCodeUParent);
            Territory2 terCode1 = TestUtil.createPortfolioTerritories('TestModel', 'M0010');
            territoryInsList.add(terCode1);
            Territory2 terCodeParent = TestUtil.createPortfolioTerritories('TestModel', 'S0010');
            territoryInsList.add(terCodeParent);
            Territory2 terCodeChild = TestUtil.createPortfolioTerritories('TestModel', 'T0010');
            territoryInsList.add(terCodeChild);
            insert territoryInsList;
            //Territory Heirarchy changes
            List<Territory2> territoryUpList = new List<Territory2>();
            terCodeParent.ParentTerritory2Id = terCodeUParent.Id;
            territoryUpList.add(terCodeParent);            
            terCodeChild.ParentTerritory2Id = terCodeParent.Id;
            territoryUpList.add(terCodeChild);            
            update territoryUpList;
            
            //Assign owner for the created Territory
            List<UserTerritory2Association> listUser2Territory = new List<UserTerritory2Association>();
            UserTerritory2Association user2Territory1= TestUtil.createUserTerritory2Association(sales.Id,terCodeUParent.id,'Owner');
            listUser2Territory.add(user2Territory1);
            UserTerritory2Association user2Territory2= TestUtil.createUserTerritory2Association(sales.Id,terCodeChild.id,Label.ClosureApproverTerritoryUserRole);
            listUser2Territory.add(user2Territory2);
            UserTerritory2Association user2Territory3= TestUtil.createUserTerritory2Association(admin.Id,terCodeChild.id,Label.ClosureApproverTerritoryUserRole);
            listUser2Territory.add(user2Territory3);
            UserTerritory2Association user2Territory4= TestUtil.createUserTerritory2Association(sales.Id,terCodeParent.id,'Owner');
            listUser2Territory.add(user2Territory4);
            insert listUser2Territory;
            
        }
    }
    @isTest
    public static void testCreateChatter(){
        User sales = [select id, name from User where username='salesuser@testsales.com'];
        System.runAs(sales){
            Test.startTest();
            list<UserTerritory2Association> usersTravelHirarchy = SFO_TerritoryUtil.getTerritoryUsersByRole('T0010','Owner',true);
            Test.stopTest();
            system.assertEquals(1, usersTravelHirarchy.size());
            
            list<UserTerritory2Association> usersNotTravelHirarchy = SFO_TerritoryUtil.getTerritoryUsersByRole('T0010',null,false);
            system.assertEquals(false, usersNotTravelHirarchy.isEmpty());

            list<String> portCodes = new list<String>();
            portCodes.add('T0010');
            portCodes.add('S0010');
            portCodes.add('N0010');
            Map<String, list<Id>> users = SFO_TerritoryUtil.getTerritoryUsers(portCodes); // Modified as part of DIGI-8909 
            system.assertEquals(3, users.size());  // Modified as part of DIGI-8909 
        }
    }
}