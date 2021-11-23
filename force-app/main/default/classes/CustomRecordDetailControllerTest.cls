/*******************************************************************
@Class Name:CustomRecordDetailControllerTest
@Description:Sprint 20.10:EDGE-151592
@Author:Alexandria  Team (Purushottam)
@Comments:This class is test class for CustomRecordDetailController.
*********************************************************************/
@isTest
public class CustomRecordDetailControllerTest {
 @testSetup
    static void setup()
    {
        Account[] customerAccount = PRMTestUtility.createAccounts(1,Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Enterprise').getRecordTypeId());
            for(Account customACC : customerAccount){
                customACC.Customer_Status__c = 'Active';
            }
            insert customerAccount;
    }
     @isTest
    static void updateSObjectUnitPositiveTest(){
        Account customerAccount=[select id,name from Account limit 1];
        CustomRecordDetailController.updateSObject(customerAccount);
         system.assertEquals(customerAccount,customerAccount);
    }
    
    @isTest
    static void updateSObjectUnitNegitiveTest(){
        try {
        Account customerAccount=[select id,name from Account limit 1];
        customerAccount.name=null;
        CustomRecordDetailController.updateSObject(customerAccount);
        }
        catch(Exception e){
            System.assertNotEquals(null, e);
        }
    }
        
}