/*******************************************************************
@Class Name     :   SFOIdentifyPortfolioCodeInfoTest
@Sprint         :   20.10  & P2OB-6270
@Author         :   SFO Team (Sri)
@CreateDate     :   14/07/2020
@Description    :   Test coverage for SFOIdentifyPortfolioCodeInfo 
@Last Modified    :     07/01/2020 21.01 by Sri, Team SFO
                    as part of P2OB-9943/P2OB-6772 removing commented code,debug statements and updating API version to 50.
@Last Modified    :   30/08/2021 21.01 by Chhaveel, Team SFO
                    as part of DIGI-8998 Replacing ‘Owner' role to 'General Manager’ 
                    11/11/2021 21.15.03 fastlane duplicate username fix
*********************************************************************/
@isTest
public class SFOIdentifyPortfolioCodeInfoTest {

 

    @testSetup static void setup() {
        User adminUser = TestUtil.createUser('admina1s2@test.com', 'adm', System.Label.Profile_SystemAdmin);
        insert adminUser;
        system.runas(adminUser){
            
            Test.startTest();
            
            //User Creation
            //User salesUser = TestUtil.createUser('salesone@test.com', 'seus', System.Label.Profile_SalesEnterprise);
            UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
            insert r;
            Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise];
            User salesUser = TestUtil.createTestUser(r.id,pf.id,'salesone','Testing');
            salesUser.Phone = '0445678001';
            insert salesUser; 
            
            //Portfolio code enter with revenue target
            Portfolio_Code__c portCode = TestUtil.createPortfolioCode('UP001');
            insert portCode;

 

            //Build TerritoryModel
            List<Territory2> territoryInsList = new List<Territory2>();
            Territory2 terCodeUParent = TestUtil.createPortfolioTerritories('TestModel', 'UP001');
            territoryInsList.add(terCodeUParent);
            Territory2 terCodeParent = TestUtil.createPortfolioTerritories('TestModel', 'PA001');
            territoryInsList.add(terCodeParent);
            //Below territory using in identifyPortfolioCodeInfoTest method for checking assert condition 
            Territory2 terCodeChild = TestUtil.createPortfolioTerritories('TestModel', 'CA001');
            territoryInsList.add(terCodeChild);
            insert territoryInsList;
            
            List<Territory2> territoryUpList = new List<Territory2>();
            terCodeParent.ParentTerritory2Id = terCodeUParent.Id;
            territoryUpList.add(terCodeParent);            
            terCodeChild.ParentTerritory2Id = terCodeParent.Id;
            territoryUpList.add(terCodeChild);            
            update territoryUpList;
            
            //Assign owner for the created Territory
            UserTerritory2Association user2Territory= TestUtil.createUserTerritory2Association(salesUser.Id,terCodeUParent.id,'General Manager');
            insert user2Territory;
            
            Test.stopTest();
            
        }
    }

 

    /*
Team SFO, sprint 20.10, P2OB-6270(Sri)  
Testmethod to cover identifyPortfolioCodeInfo method
Main class is SFOIdentifyPortfolioCodeInfo
*/
    @isTest
    static void identifyPortfolioCodeInfoTest(){
        User salesUser = [Select id from User where firstname='salesone'];
        system.runas(salesUser){    
            Test.startTest();
            
            List<String> portCodesList = new List<String>();
            portCodesList.add('CA001');
            List<String> userIdLsit = SFOIdentifyPortfolioCodeInfo.identifyPortfolioCodeInfo(portCodesList);
            for(String str:userIdLsit){
                system.assertEquals(str, salesUser.Id);
            }
            Test.stopTest();            
        }
        
    }
}