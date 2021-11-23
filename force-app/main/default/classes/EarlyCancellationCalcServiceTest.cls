/* ****************************************************************************
* Author : Manoj Kumar : EDGE-81053
* Date : 16 Sept 2019
* Description : Test class to cover : EarlyCancellationCalcService
* Updates : Ritika Jaiswal : EDGE - 66137 : PortOut ETC calculation
*           Sandip Deshmane:  5/Nov/2019	   EDGE-11053: Cancellation Charges

* *****************************************************************************/ 
@IsTest
public class EarlyCancellationCalcServiceTest {

          /* ****************************************************************************
 * Author : Manoj Kumar : EDGE-104678
 * Date : 8/Aug/2019
 * Description : Method to Cover : CancelChargesCalc
 * *****************************************************************************/
        @isTest
    public static void CancelChargesCalcTest() {
        Billing_Account__c billingAccount = ProductTestFactory.getBillingAccount();
        billingAccount.Billing_Account_Number__c = '700000449806';
        insert billingAccount;
        System.assertNotEquals(billingAccount.Id, null);
        
        Decimal maxETC = 100.00;
        Date RTB = System.today();
        Date RCD = System.today();
        Integer Term = 24;
        Decimal UnitPrice = 20.00;
        boolean Device_cancellation_applicable = true; 
        String billingAccNum = billingAccount.Billing_Account_Number__c;
        Test.setMock(HttpCalloutMock.class, new MockBillingOrderResponseGenerator(200, 'OK', 'retrieveFullSuccessResponse', new Map<String, String>()));
            
        Test.startTest();
         Map<String,String> resultValue =  EarlyCancellationCalcService.CancelChargesCalc(maxETC,RTB,RCD,Term,UnitPrice, Device_cancellation_applicable, billingAccNum);
        System.assert(resultValue!=null);
        Test.stopTest();
        
    }
    
    //EDGE - 66137 : PortOut ETC calculation
     @isTest
    public static void CancelChargesCalcWithBillDayTest() {
        Billing_Account__c billingAccount = ProductTestFactory.getBillingAccount();
        billingAccount.Billing_Account_Number__c = '700000449806';
        insert billingAccount;
        System.assertNotEquals(billingAccount.Id, null);
        
        Decimal maxETC = 100.00;
        Date RTB = System.today();
        Date RCD = System.today();
        Integer Term = 24;
        Decimal UnitPrice = 20.00;
        boolean Device_cancellation_applicable = true; 
        String billingAccNum = billingAccount.Billing_Account_Number__c;
         Test.startTest();
         String resultValue =  EarlyCancellationCalcService.CancelChargesCalcWithBillDay(maxETC,RTB,RCD,Term,UnitPrice, Device_cancellation_applicable, billingAccNum,'1');
        System.assert(String.isNotBlank(resultValue)); 
        Test.stopTest();
        
    }
    //EDGE-11053
    @isTest
    public static void CancelChargesCalcforTIDTest(){
        Billing_Account__c billingAccount = ProductTestFactory.getBillingAccount();
        billingAccount.Billing_Account_Number__c = '700000449806';
        insert billingAccount;
        System.assertNotEquals(billingAccount.Id, null);
        Test.setMock(HttpCalloutMock.class, new MockBillingOrderResponseGenerator(200, 'OK', 'retrieveFullSuccessResponse', new Map<String, String>()));
        Integer maxETC = 100;
        Date RTB = System.today();
        Date RCD = System.today();
        Integer Term = 24;
        Decimal UnitPrice = 20.00;
        boolean Device_cancellation_applicable = true; 
        String billingAccNum = billingAccount.Billing_Account_Number__c;
        Test.startTest();
        Map<String, String> resultValue = EarlyCancellationCalcService.CancelChargesCalcforTID(maxETC, RTB, RCD, Term, UnitPrice, Device_cancellation_applicable, billingAccNum);
        Test.stopTest();
        System.assert(resultValue!=null);
    }
    //EDGE-11053
    @isTest
    public static void CancelChargesCalcforTIDNegativeTest(){
        Billing_Account__c billingAccount = ProductTestFactory.getBillingAccount();
        billingAccount.Billing_Account_Number__c = '700000449806';
        insert billingAccount;
        System.assertNotEquals(billingAccount.Id, null);
        Test.setMock(HttpCalloutMock.class, new MockBillingOrderResponseGenerator(200, 'OK', 'retrieveFullSuccessResponse', new Map<String, String>()));
        Integer maxETC = 0;
        Date RTB = System.today();
        Date RCD = System.today();
        Integer Term = 24;
        Decimal UnitPrice = 20.00;
        boolean Device_cancellation_applicable = true; 
        String billingAccNum = billingAccount.Billing_Account_Number__c;
        Test.startTest();
        Map<String, String> resultValue = EarlyCancellationCalcService.CancelChargesCalcforTID(maxETC, RTB, RCD, Term, UnitPrice, Device_cancellation_applicable, billingAccNum);
        Test.stopTest();
        System.assert(resultValue!=null);
    }
}