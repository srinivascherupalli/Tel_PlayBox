@isTest
public class BillingAccountErrorDTOTest
{
    @istest static void test_parse() {
    String jsonstr = '{"code": "400","status": "400","message": "No BAN Available","errors": [{"code":"1000","field":"ban","message":"no BAN available"}], "correlationId": "328fdbb9-a4e5-4c4c-b72f-0be6b9422917"}';
    Test.startTest();
    BillingAccountErrorDTO billingError = BillingAccountErrorDTO.parse(jsonstr);
    Test.stopTest();
    System.assertEquals('No BAN Available', billingError.message);
    System.assertEquals('400', billingError.code);
    System.assertEquals('400', billingError.status);
    System.assertEquals('1000', billingError.errors[0].code);
    System.assertEquals('328fdbb9-a4e5-4c4c-b72f-0be6b9422917', billingError.correlationId);
        
    } 
}