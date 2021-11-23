@IsTest
public class BillingAccountPaymentsServiceTest {
    @TestSetup public static void testSetup(){
        account acc=TestDataFactory.generateAccount();
        
        contact con=testDataFactory.generateContact( 'Test_FirstName', acc.id,'Active','Test_LastName',system.today(),'Mobile');
        insert con;
        
        Billing_Account__c billingAccount=TestDataFactory.generateBillingAccount('700000335518','Created',acc.id, con.id);
        insert billingAccount;
        
        
        List<EnvironmentVariable__c> variableList=new List<EnvironmentVariable__c>();
        EnvironmentVariable__c certificate =new EnvironmentVariable__c();
        certificate.Name='massl_certificate_name';
        certificate.Value__c='telstrab2b_sandbox';
        variableList.add(certificate);
        
        EnvironmentVariable__c certificate1 =new EnvironmentVariable__c();
        certificate1.Name='PlatformCache_Expiry_Time';
        certificate1.Value__c='3599';
        variableList.add(certificate1);
        
    }
    @IsTest  public static void  paymentServiceRequestTestSuccessResponse(){
        Billing_Account__c billingAccount = [SELECT Id,Billing_Account_Number__c FROM Billing_Account__c WHERE Billing_Account_Number__c='700000335518' LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BillingAccountPaymentsServiceMock(200));
        HTTPResponse response= BillingAccountPaymentsService.paymentServiceRequest('BillingAccountPayments', billingAccount.Billing_Account_Number__c, system.today(),system.today());
        Test.stopTest();
        system.assertEquals(200, response.getstatusCode());
        
    }
    
    @IsTest public static void paymentServiceRequestTestErrorResponse(){
        Billing_Account__c billingAccount = [SELECT Id,Billing_Account_Number__c FROM Billing_Account__c WHERE Billing_Account_Number__c='700000335518' LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BillingAccountPaymentsServiceMock(422));
        HTTPResponse  response=   BillingAccountPaymentsService.paymentServiceRequest('BillingAccountPayments', billingAccount.Billing_Account_Number__c, system.today(),system.today());
        Test.stopTest();
        system.assertEquals(422, response.getstatusCode());
        
    }
    @IsTest public static void paymentServiceRequestTestException(){
        Billing_Account__c billingAccount = [SELECT Id,Billing_Account_Number__c FROM Billing_Account__c WHERE Billing_Account_Number__c='700000335518' LIMIT 1];
        Test.startTest();
        HTTPResponse  response=   BillingAccountPaymentsService.paymentServiceRequest('', billingAccount.Billing_Account_Number__c, system.today(),system.today());
        system.assertEquals(null, response);
        Test.stopTest(); 
    }
    
    /*
    *@Created By : Kamlesh Kumar
    *@Breif : EDGE : 212793, The method test the transactionalPaymentServiceRequest
    */
    @IsTest public static void paymentServiceRequesttransactionalPaymentServiceRequestTest(){
        Billing_Account__c billingAccount = [SELECT Id,Billing_Account_Number__c FROM Billing_Account__c WHERE Billing_Account_Number__c='700000335518' LIMIT 1];
        Test.startTest();
        HTTPResponse  response=   BillingAccountPaymentsService.transactionalPaymentServiceRequest('BillingAccountPayments', billingAccount.Billing_Account_Number__c, '123');
        system.assertEquals(null, response);
        Test.stopTest(); 
    }
}