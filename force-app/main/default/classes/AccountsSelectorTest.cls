@isTest
public class AccountsSelectorTest {
    @isTest
    public static void getSObjectFieldListTest(){
        AccountsSelector sObjectTestList = new AccountsSelector();
        test.startTest();
       	List<Schema.SObjectField> listOfAccountIdParentAccountId = sObjectTestList.getSObjectFieldList();
        System.assertNotEquals(NULL, listOfAccountIdParentAccountId);
        test.stopTest();
    }
    
    @isTest
    public static void getSObjectTypeTest(){
        AccountsSelector sObjectTestList1 = new AccountsSelector();
        test.startTest();
        Schema.sObjectType testSchemaType = sObjectTestList1.getSObjectType();
        System.assertNotEquals(NULL, testSchemaType);
        test.stopTest();
    }
    
    @isTest
    public static void selectByIdTest(){
        Set<ID> testIdSet=new Set<ID>();
        Account acct = new Account(name='testAccount');
        insert acct;
        Id setId=acct.id;
        testIdSet.add(setId);
        
        AccountsSelector sObjectTestList2 = new AccountsSelector();
        test.startTest();
        list<Account> testAccountList = sObjectTestList2.selectById(testIdSet);
        System.assertNotEquals(NULL, testAccountList);
        test.stopTest();
    }
}