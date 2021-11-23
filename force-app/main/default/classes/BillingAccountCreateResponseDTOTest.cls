@isTest
public class BillingAccountCreateResponseDTOTest {
    
    @istest static void test_parse(){
        String jsonstr = '{"code": "202","status": "202","message": "Success","correlationId": "328fdbb9-a4e5-4c4c-b72f-0be6b9422917"}';
    Test.startTest();
    BillingAccountCreateResponseDTO billingError = BillingAccountCreateResponseDTO.parse(jsonstr);
    Test.stopTest();
    System.assertEquals('202', billingError.code);
    System.assertEquals('Success', billingError.message);
    System.assertEquals('202', billingError.status);    
    System.assertEquals('328fdbb9-a4e5-4c4c-b72f-0be6b9422917', billingError.correlationId);   
    }

}