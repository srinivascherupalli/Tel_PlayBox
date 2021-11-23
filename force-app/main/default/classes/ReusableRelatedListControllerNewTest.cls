/********************************************************************/
// Class Name:  ReusableRelatedListControllerNewTest
// Description: For EDGE-150237
// Author:  Ravi Shankar V
// Date Created:    10-Jun-2020
// Revision History:
/*********************************************************************/
@isTest
public class ReusableRelatedListControllerNewTest {
    @TestSetup static void dataSetup(){
        Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        testAccount.Customer_Status__c = 'ACTIVE';
        testAccount.ACN__c = '123456';
        insert testAccount;
        
        Contact con = new Contact();
        con.LastName = 'test last name';
        con.FirstName = 'Fname';
        con.AccountId = testAccount.Id;
        insert con;
        
        Case c = new Case();
        c.AccountId = testAccount.Id;
        insert c;
    }
    @isTest 
    static void controllerMessageTest(){
        List<Account> accLst = [SELECT Id FROM Account WHERE ACN__c='123456'];
        Test.startTest();
            string listParams = accLst[0].Id+'-Case-Account-Account.ACN__c=param1-ACN__c-CaseNumber';
            ReusableRelatedListControllerNew.RelatedListWrapper objWrap = ReusableRelatedListControllerNew.fetchRecords(listParams);
        Test.stopTest();
        System.assertNotEquals(0, objWrap.recordCount, 'Case data not returned');
    }
    @isTest 
    static void controllerMessageNegativeTest(){
        List<Account> accLst = [SELECT Id FROM Account WHERE ACN__c='123456'];
        Test.startTest();
            string listParams = accLst[0].Id+'aaa-Case-Account-Account.ACN__c=param1-ACN__c-CaseNumber';
            ReusableRelatedListControllerNew.RelatedListWrapper objWrap = ReusableRelatedListControllerNew.fetchRecords(listParams);
        Test.stopTest();
        System.assertEquals(null, objWrap.recordCount, 'Case data returned');
    }    
}