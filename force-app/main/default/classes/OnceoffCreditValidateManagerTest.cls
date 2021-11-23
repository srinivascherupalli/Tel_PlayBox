/*------------------------------------------------------------------------ 
Author: Mahima Gandhe 
Company: Telstra 
Description: A test class created to validate class OnceoffCreditValidateManager and OnceOffCreditBillingService
Tests executed: 
1 - ApplyOnceOffCredit_Test() 
Submits the API Call and get a success response after using Mock class MockOnceOffcreditResponse.
2 - ApplyOnceOffCredit_Negative_Test() 
Submits the API Call and get a failure response after using Mock class MockOnceOffcreditResponse.
History 
<16-04-2019> <Mahima Gandhe> <EDGE- 64232 : Class is Created>  
----------------------------------------------------------------------------*/

@isTest
public class OnceoffCreditValidateManagerTest {

    private static  Account acc=null;
    private static Contact con=null;
    private static Non_Marketable_Product__c nmp= null;
    private static AccountContactRelation acr= null;
    private static Billing_Account__c billAcc= null;
    private static Credits_And_Adjustments__C cad= null;
    private static Case cs= null;
    
     /*------------------------------------------------------------ 
    Metohd: testData
    Description: method to setup the Testdata
    History 
    <16-04-2019> <Mahima Gandhe>
    ------------------------------------------------------------*/
    @testSetup static void testData() {
          acc=new account(name='TestAccount',CIDN__c='12345',ABN__c='1234');
          insert acc;
          ID id=acc.Id;
           con=new contact(lastname='TestContact',accountId=id);
            //contact con1=new contact(lastname='TestContact1',accountId=id);
          insert con;
        //insert con1;
          acr=NEW AccountContactRelation(Account=acc, Contact=con);
        //AccountContactRelation acr1=NEW AccountContactRelation(Account=acc, Contact=con1);
        List<Billing_Account__c>billingAccList=new List<Billing_Account__c>();
        billAcc=new Billing_Account__c(Billing_Account_Number__c='123456789012',Billing_Account_Owner__c=con.Id);
        billAcc.IsUpdated__c = true;
        billingAccList.add(billAcc);
        
        Billing_Account__c  billAcc2=new Billing_Account__c(Billing_Account_Number__c='012345678900',Billing_Account_Owner__c=con.Id);
        billAcc2.IsUpdated__c = true;
        billingAccList.add(billAcc2);
        
        insert billingAccList;
        //EDGE-157139. Kalashree Borgaonkar. Setting name atribute
        nmp = new Non_Marketable_Product__c(currency__c='AUD',specId__c='prod-1234',productDescription__c='test',taxTreatment__c='GST Applicable',name='Insolvency Credit');       
        insert nmp;
        //DPG-3598 start Updated The Record Type Name to Biling Credit or Debit Adjustment.
        Id stExam = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Billing Credit or Debit Adjustment').getRecordTypeId();
        //DPG-3598 end.
        cs = new Case(accountId=acc.id);
        cs.Status='New';
        cs.RecordTypeId= stExam;
        cs.Description='test class';
        // cs.Sub_Type__c='General';
        insert cs;
        
        cad= new Credits_And_Adjustments__C();
        cad.Billing_Account_Number_BAN__c=billAcc.id;
        cad.Non_Marketable_Product__c= nmp.id;
        cad.Case_Number__c= cs.id;
        cad.Credit_Change_Amount__c= 23;
        cad.Date_when_credit_was_given_to_customer__c= Date.newInstance(2018, 4, 9); 
        cad.Reason_Code__c='Compensation Credits – Telstra Issue';
        insert cad;
        
    }
    
    /*------------------------------------------------------------ 
    Metohd: ApplyOnceOffCredit_Test
    Description: to test ApplyOnceOffCredit with Mock response and success case.
    History 
    <16-04-2019> <Mahima Gandhe>
    ------------------------------------------------------------*/
    @isTest static void applyOnceOffCredit_Test()
    {
        
        Credits_And_Adjustments__C cad1= [select id,Billing_Account_Number_BAN__c, Non_Marketable_Product__c,Credit_Change_Amount__c,Case_Number__c,Reason_Code__c from Credits_And_Adjustments__C limit 1];
        String caseNumber;
        system.debug(cad1);
        test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockOnceOffcreditResponse());           
        Map<string, string> response=OnceoffCreditValidateManager.ApplyOnceOffCredit(cad1,caseNumber);
        System.assertEquals(response.size()>0, true);
        test.stopTest();
    }
    
    /*------------------------------------------------------------ 
    Metohd: ApplyOnceOffCredit_Negative_Test
    Description: to test ApplyOnceOffCredit with Mock response and failure case.
    History 
    <16-04-2019> <Mahima Gandhe>
    ------------------------------------------------------------*/
    @isTest static void applyOnceOffCredit_Negative_Test()
    {
        
        
        Credits_And_Adjustments__C cad1= [select Billing_Account_Number_BAN__c,id, Non_Marketable_Product__c,Credit_Change_Amount__c,Case_Number__c,Reason_Code__c from Credits_And_Adjustments__C limit 1];
        cad1.Billing_Account_Number_BAN__c=null;
        update cad1;
		String caseNumber;
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockOnceOffcreditResponse());           
        Map<string, string> mapres=OnceoffCreditValidateManager.ApplyOnceOffCredit(cad1,caseNumber);
        system.assertEquals(mapres.size()>0, true);
        test.stopTest();
    }
        /*------------------------------------------------------------ 
    Metohd: applyOnceOffCreditResponseNull_Test
    Description: to test ApplyOnceOffCredit with Mock response and null response case.
    ------------------------------------------------------------*/
    @isTest static void applyOnceOffCreditResponseNull_Test()
    {
        
        Billing_Account__c billingAccount=[Select id,Billing_Account_Number__c FROM Billing_Account__c WHERE Billing_Account_Number__c ='012345678900' LIMIT 1];
        Credits_And_Adjustments__C cad1= [select Billing_Account_Number_BAN__c,id, Non_Marketable_Product__c,Credit_Change_Amount__c,Case_Number__c,Reason_Code__c from Credits_And_Adjustments__C limit 1];
        cad1.Billing_Account_Number_BAN__c=billingAccount.id;
        update cad1;
		String caseNumber;
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockOnceOffcreditResponse());           
       Map<string, string> responseMap = OnceoffCreditValidateManager.ApplyOnceOffCredit(cad1,caseNumber);
        system.assertEquals(responseMap.size()>0, true);
        test.stopTest();
    }
     /*------------------------------------------------------------ 
    Metohd: ApplyOnceOffDedit_Test
    Description: to test ApplyOnceOffDebit with Mock response and success case.
    History 
    <26-06-2020> <Pradeep>
    ------------------------------------------------------------*/
    @isTest static void applyOnceOffDebit_Test()
    {
        
        Credits_And_Adjustments__C cad1= [select id,Date_when_credit_was_given_to_customer__c,Billing_Account_Number_BAN__c, Non_Marketable_Product__c,Credit_Change_Amount__c,Case_Number__c,Reason_Code__c from Credits_And_Adjustments__C limit 1];
        String caseNumber;
        system.debug(cad1);
        test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new MockOnceOffcreditResponse());           
        Map<string, string> response=OnceoffCreditValidateManager.ApplyOnceOffDebit(cad1,caseNumber);
        System.assertEquals(response.size()>0, true);
        test.stopTest();
    }
    
   
        /*------------------------------------------------------------ 
    Metohd: applyOnceOffDebitResponseNull_Test
    Description: to test ApplyOnceOffDebit with Mock response and null response case.
    ------------------------------------------------------------*/
    @isTest static void applyOnceOffDebitResponseNull_Test()
    {
        
        Billing_Account__c billingAccount=[Select id,Billing_Account_Number__c FROM Billing_Account__c WHERE Billing_Account_Number__c ='012345678900' LIMIT 1];
        Credits_And_Adjustments__C cad1= [select Billing_Account_Number_BAN__c,Date_when_credit_was_given_to_customer__c,id, Non_Marketable_Product__c,Credit_Change_Amount__c,Case_Number__c,Reason_Code__c from Credits_And_Adjustments__C limit 1];
        cad1.Billing_Account_Number_BAN__c=billingAccount.id;
        update cad1;
		String caseNumber;
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockOnceOffcreditResponse());           
       Map<string, string> responseMap = OnceoffCreditValidateManager.ApplyOnceOffDebit(cad1,caseNumber);
        system.assertEquals(responseMap.size()>0, true);
        test.stopTest();
    }
}