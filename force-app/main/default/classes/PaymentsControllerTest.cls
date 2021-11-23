/*----------------------------------------------------------------------------
EDGE        -88306
Class Name  -PaymentsControllerTest
Description -Test class for PaymentsController and  BillingAccountPaymentsService class .
Author      -Dheeraj Bhatt
Modified By - EDGE : 212793 Kamlesh Kumar added getPaymentByTransactionIdTestSuccessResponse,getPaymentByTransactionIdTestErrorResponse,getPaymentByTransactionIdTestException
-------------------------------------------------------------------------------*/    
@IsTest(seeAllData=false)
public class PaymentsControllerTest {
    @TestSetup public static void testSetup(){
        account acc=TestDataFactory.generateAccount();
        
        contact con=testDataFactory.generateContact( 'Test_FirstName', acc.id,'Active','Test_LastName',system.today(),'Mobile');
        insert con;
        
        Billing_Account__c billingAccount=TestDataFactory.generateBillingAccount('700000335518','Created',acc.id, con.id);
        insert billingAccount;
        
        //EnvironmentVariable__c certificate =TestDataFactory.generateEnvironmentVariable('massl_certificate_name','telstrab2b_sandbox');
        EnvironmentVariable__c certificate =TestDataFactory.generateEnvironmentVariable('massl_certificate_name','sfdc_prod_client');
        insert certificate;
        
    }
    @IsTest  public static void  getBanTest(){
        Billing_Account__c billingAccount = [SELECT Id,Billing_Account_Number__c FROM Billing_Account__c WHERE Billing_Account_Number__c='700000335518' LIMIT 1];
        Test.startTest();
        string ban= PaymentsController.getBAN(billingAccount.id);
        system.assertEquals(billingAccount.Billing_Account_Number__c, ban);
        Test.stopTest();
    }
    @IsTest  public static void  getBanTestError(){
        Billing_Account__c billingAccount = [SELECT Id,Billing_Account_Number__c FROM Billing_Account__c WHERE Billing_Account_Number__c='700000335518' LIMIT 1];
        Test.startTest();
        string ban= PaymentsController.getBAN('123456789');
        system.assertEquals('', ban);
        Test.stopTest();
    }
    @IsTest  public static void  paymentServiceRequestTestSuccessResponse(){
        Billing_Account__c billingAccount = [SELECT Id,Billing_Account_Number__c FROM Billing_Account__c WHERE Billing_Account_Number__c='700000335518' LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BillingAccountPaymentsServiceMock(200));
        PaymentsController.responseWrapper   response= PaymentsController.getPayments('BillingAccountPayments', billingAccount.Billing_Account_Number__c, system.today(),system.today());
        system.assertNotEquals(null, response.responsePayments);
        Test.stopTest();
    }
    
    @IsTest public static void paymentServiceRequestTestErrorResponse(){
        Billing_Account__c billingAccount = [SELECT Id,Billing_Account_Number__c FROM Billing_Account__c WHERE Billing_Account_Number__c='700000335518' LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BillingAccountPaymentsServiceMock(422));
        PaymentsController.responseWrapper  response=   PaymentsController.getPayments('BillingAccountPayments', billingAccount.Billing_Account_Number__c, system.today(),system.today());
        system.assertNotEquals(null, response.responseErrors);
        Test.stopTest(); 
    } 

    @IsTest public static void paymentServiceRequestTestException(){
        Billing_Account__c billingAccount = [SELECT Id,Billing_Account_Number__c FROM Billing_Account__c WHERE Billing_Account_Number__c='700000335518' LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BillingAccountPaymentsServiceMock(400));
        PaymentsController.responseWrapper  response=   PaymentsController.getPayments('BillingAccountPayments', billingAccount.Billing_Account_Number__c, system.today(),system.today());
        system.assertNotEquals(null, response.responsePayments);
        Test.stopTest(); 
    }
    
    /*
    *@Created By : Kamlesh Kumar
    *@Breif : EDGE : 212793, The method test the success scenario for getPaymentByTransactionId
    */
    @IsTest  public static void  getPaymentByTransactionIdTestSuccessResponse(){
        Billing_Account__c billingAccount = [SELECT Id,Billing_Account_Number__c FROM Billing_Account__c WHERE Billing_Account_Number__c='700000335518' LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BillingAccountPaymentsServiceMock(200));
        BillingAccountPaymentsResponseDto response= PaymentsController.getPaymentByTransactionId('BillingAccountPayments', billingAccount.Billing_Account_Number__c,'123456');
        system.assertNotEquals(null, response);
        Test.stopTest();
    }
    
     /*
    *@Created By : Kamlesh Kumar
    *@Breif : EDGE : 212793, The method test the error scenario for getPaymentByTransactionId
    */
    @IsTest public static void getPaymentByTransactionIdTestErrorResponse(){
        Billing_Account__c billingAccount = [SELECT Id,Billing_Account_Number__c FROM Billing_Account__c WHERE Billing_Account_Number__c='700000335518' LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BillingAccountPaymentsServiceMock(422));
        BillingAccountPaymentsResponseDto  response=   PaymentsController.getPaymentByTransactionId('BillingAccountPayments', billingAccount.Billing_Account_Number__c,'123456');
        system.assertNotEquals(null, response);
        Test.stopTest(); 
    } 
    
    /*
    *@Created By : Kamlesh Kumar
    *@Breif : EDGE : 212793, The method test the exception scenario for getPaymentByTransactionId
    */
    @IsTest public static void getPaymentByTransactionIdTestException(){
        Billing_Account__c billingAccount = [SELECT Id,Billing_Account_Number__c FROM Billing_Account__c WHERE Billing_Account_Number__c='700000335518' LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new BillingAccountPaymentsServiceMock(400));
        BillingAccountPaymentsResponseDto  response=   PaymentsController.getPaymentByTransactionId('', '','123456');
        system.assertNotEquals(null, response);
        Test.stopTest(); 
    }
    
	@isTest public static void checkPaymentDormanceTest1() {
        Utility_Settings__c utilSettings    =   new Utility_Settings__c();
        utilSettings.Enable_Dormancy__c     =   '';
        insert utilSettings;
        Test.startTest();
            Boolean checkDormance1 = PaymentsController.checkPaymentDormance();
            System.assertEquals(false, checkDormance1);
            utilSettings.Enable_Dormancy__c =   'BillAccTransactionIdBtn';
            update utilSettings;
            Boolean checkDormance2 = PaymentsController.checkPaymentDormance();
            System.assertNotEquals(false, checkDormance2);
        Test.stopTest();
    }    
}