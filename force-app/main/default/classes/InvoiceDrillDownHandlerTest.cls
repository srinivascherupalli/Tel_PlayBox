@isTest
public class InvoiceDrillDownHandlerTest {
    @TestSetup static void dataSetup()
  {
      Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        testAccount.Customer_Status__c = 'ACTIVE';
        insert testAccount;
         Billing_Account__c billAccount = new Billing_Account__c(Status__c = 'Created', Include_related_Customer_Account_Contact__c=false, 
                                                                Account__c=testAccount.Id, Billing_Account_Number__c='992216148101',Balance_Amount__c=100.00);
                                                               
        insert billAccount;
  }
 public static testmethod void testGetBillingAccNum() 
     {
         Billing_Account__c billAccount = [Select Id,Billing_Account_Number__c from Billing_Account__c LIMIT 1 ];
        
         Test.startTest();
        String billAccNum= InvoiceDrillDownHandler.getBillingAccNum(billAccount.Id);
         Test.stopTest();
         System.assertNotEquals(billAccNum, null);
     }
}