@isTest
public class FeaturePackDetailsHandlerTest { 
   @TestSetup static void dataSetup()
  {
      Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        testAccount.Customer_Status__c = 'ACTIVE';
        insert testAccount;
         Billing_Account__c billAccount = new Billing_Account__c(Status__c = 'Created', Include_related_Customer_Account_Contact__c=false, 
                                                                Account__c=testAccount.Id, Billing_Account_Number__c='992216148101',Balance_Amount__c=100.00);
                                                               
        insert billAccount;
      	Invoice__c testInvoice = new Invoice__c(Billing_Account__c=billAccount.Id,Name='9900000013687',Aria_Invoice_Number__c='148921506');
      insert testInvoice;
  } 
         public static testmethod void testGetDetailCharges() 
     {
         Billing_Account__c billAccount = [Select Billing_Account_Number__c from Billing_Account__c LIMIT 1 ];
         Invoice__c testInvoice = [Select Name from Invoice__c LIMIT 1];
         String req =  '{"chargeId":77778888,"statementNumber":9900000013687,"accountNumber":555666444}';
         Test.setMock(HttpCalloutMock.class, new getRCMockBillingResponseGenerator(200, 'OK', '200ResponseFP', new Map<String, String>()));
         Test.startTest();
         String calloutRes = FeaturePackDetailsHandler.getFeaturePackDetails(77778888,'9900000013687','555666444','FeaturePackHandler');
         FeaturePackDetailsHandler.logException('testlogException','test','test','test','test');
         Test.stopTest();
         System.assertNotEquals(calloutRes, null);
     }
    public static testmethod void testErrorResponse() 
     {
         Billing_Account__c billAccount = [Select Billing_Account_Number__c from Billing_Account__c LIMIT 1 ];
         Invoice__c testInvoice = [Select Name from Invoice__c LIMIT 1];
         Test.setMock(HttpCalloutMock.class, new getRCMockBillingResponseGenerator(404, 'OK', '404ResponseFP', new Map<String, String>()));
         Test.startTest();
         String calloutRes =FeaturePackDetailsHandler.getFeaturePackDetails(77778888,'9900000013687','555666444','FeaturePackHandler');
         Test.stopTest();
         System.assertNotEquals(testInvoice, null);
     }
}