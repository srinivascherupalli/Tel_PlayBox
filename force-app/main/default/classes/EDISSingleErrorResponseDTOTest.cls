@istest
public class EDISSingleErrorResponseDTOTest {
	@istest 
    static void test_parse() {
        String jsonStr = '{ "correlationId": "58fb5c78-77ed-4f58-97e3-6e0ae3ce498e","code": "400","res_time": "2018-07-26T05:03:20.299+0000","respondTo": "abc", "message": "error", "errors":[{"code": "400","message": "error1"},{"code": "400","message": "error2"}]}';
    
    Test.startTest();
    EDISSingleErrorResponseDTO edissingleerrorresdto = EDISSingleErrorResponseDTO.parse(jsonStr);
    Test.stopTest();
    System.assertEquals('58fb5c78-77ed-4f58-97e3-6e0ae3ce498e', edissingleerrorresdto.correlationId); 
    System.assertEquals(400, edissingleerrorresdto.code);
    System.assertEquals('2018-07-26T05:03:20.299+0000', edissingleerrorresdto.res_time);
    System.assertEquals('error', edissingleerrorresdto.message);
    System.assertEquals('abc', edissingleerrorresdto.respondTo);
    System.assertEquals(400, edissingleerrorresdto.errors.get(0).code);
    System.assertEquals('error1', edissingleerrorresdto.errors.get(0).message);
    System.assertEquals(null, edissingleerrorresdto.request); 
    }
}