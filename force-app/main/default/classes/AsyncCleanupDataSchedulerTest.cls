@isTest
public class AsyncCleanupDataSchedulerTest {
    @testSetup static void createTestData() {
        List<Account> lstAccount= new List<Account>();
        for(Integer i=0 ;i <50;i++)
        {
            Account acc = new Account();
            acc.Name ='Name'+i;
            lstAccount.add(acc);
        }
        
        insert lstAccount;
    }
    static testMethod void testMethod1() 
    {        
        List<Account> lstAccount = [SELECT id FROM Account];
        Test.startTest();        
            AsyncCleanupDataScheduler obj = new AsyncCleanupDataScheduler();
            DataBase.executeBatch(obj); 
            System.assertEquals(lstAccount.size(), 50); 
        Test.stopTest();
    }
}