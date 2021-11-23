@isTest
public class AccountStatusUpdateTest {
    @isTest static void testAccountStatus()
    {
        Account customerAccount=new Account(Name='acc',Customer_Status__c='ACTIVE');
		insert customerAccount;
        AccountStatusUpdateonServiceActivation.updateAccountStatus(customerAccount);
        System.assertEquals('ACQUIRED',customerAccount.Customer_Status__c);
    }

}