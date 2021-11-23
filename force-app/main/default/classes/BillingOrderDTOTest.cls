@isTest
public class BillingOrderDTOTest {
 @istest static void test_parse() {
     
     String jsonstr = '{"billingAccountNumber": "123456789","correlationId": "328fdbb9-a4e5-4c4c-b72f-0be6b9422917"}';

    Test.startTest();
    BillingOrderDTO billingDTO = BillingOrderDTO.parse(jsonstr);
    Test.stopTest();
    System.assertEquals('123456789', billingDTO.billingAccountNumber);
     System.assertEquals('328fdbb9-a4e5-4c4c-b72f-0be6b9422917', billingDTO.correlationId);}
}