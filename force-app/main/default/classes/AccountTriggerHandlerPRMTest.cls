/* P2OB-6753 -Hawaii - 08/06/2020 - Updated main class and some validation is failing on test class so update only because of it */
@isTest
public class AccountTriggerHandlerPRMTest  {

@isTest
    public static void testAccountAndOpptyAssignment(){
      Test.startTest();
              //Setup Portfolio Territories (assumes existing model and type are in place)
        List<Territory2> territories = TestUtil.createPortfolioTerritories('TestModel', new List<String>{'ABC', 'XYZ'});
        insert territories;
        
        //  P2OB-6753 - init userList
        List<User> userList = new List<User>();
        //Setup users to assign to the territories, setup admin user to run as
        User user1 = TestUtil.createUser('test1@test.com.portfoliotest', 'test1', System.Label.Profile_SalesEnterprise); //EDGE-85331 :: 'Sales - Enterprise');
        user1.Phone = '1231312321';  // P2OB-6753 - added Phone
        User user2 = TestUtil.createUser('test2@test.com.portfoliotest', 'test2', System.Label.Profile_SalesEnterprise); //EDGE-85331 :: 'Sales - Enterprise');
        user2.Phone = '2342342333';// P2OB-6753 - added Phone
        User admin = TestUtil.createUser('admin@test.com.portfoliotest', 'admin', 'System Administrator');
        admin.Phone = '3433233223';// P2OB-6753 - added Phone
        //insert user1;
        //insert user2;
        //insert admin;
        //  P2OB-6753 - fixes related to bulk insert 
        userList.add(user1);
        userList.add(user2);
        userList.add(admin);
        insert userList;

        //Allocate users to portfolio codes (territories) as owner
        //  P2OB-6753 - fixes related to bulk insert 
        List<UserTerritory2Association> userTerritoryAssociationList = new List<UserTerritory2Association>();
        userTerritoryAssociationList.add(new UserTerritory2Association(UserId = user1.Id, Territory2Id = territories[0].Id, RoleInTerritory2 = 'Owner'));
        userTerritoryAssociationList.add(new UserTerritory2Association(UserId = user2.Id, Territory2Id = territories[1].Id, RoleInTerritory2 = 'Owner'));
        //insert uta1;
        //insert uta2;
        insert userTerritoryAssociationList;


        System.runAs(admin){
            Id partnerRecordID =  Schema.SObjectType.Account.getRecordTypeInfosByName().get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId();
            List<Account> a = new List<Account>();
            Account ac = new Account();
            ac.name = 'Test';
            ac.RecordTypeId = partnerRecordID;
            a.add(ac);
            insert a;

            Map<id,Account> accountInsertMap = new Map<id, Account>();
            accountInsertMap.put(ac.id,ac);
            
            List<Account> accountUpdateList = new List<Account>();
            ac.Name = 'Test12';
            accountUpdateList.add(ac);
            update accountUpdateList;

            Map<id,Account> accountUpdateMap= new Map<id, Account>();
            accountUpdateMap.put(ac.id,ac);
    
            Interface_Activation__c i = new Interface_Activation__c();
            i.name = 'PROCESS_BUILDER';
            i.Status__c = true;
            insert i;
            
            AccountTriggerHandlerPRM accPRM = new AccountTriggerHandlerPRM(a);
            accPRM.hasPRMAccounts();
            accPRM.OnBeforeInsert(a);
            accPRM.OnAfterInsert(a);
            accPRM.OnBeforeUpdate(a,accountUpdateList,accountInsertMap,accountUpdateMap);
            accPRM.OnAfterUpdate(a,accountInsertMap,accountUpdateList,accountUpdateMap);
            // P2OB-6753 - added assert because it is missing
            System.assert(ac.Id != null);
        }

        Test.stopTest();
    }
    

}