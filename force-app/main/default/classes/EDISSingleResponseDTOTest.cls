@istest 
public class EDISSingleResponseDTOTest {
    @istest 
    static void test_parse() {
       String jsonStr = '{"data": {"result": "Pass"},"correlationId": "58fb5c78-77ed-4f58-97e3-6e0ae3ce498e","code": "200","res_time": "2018-07-26T05:03:20.299+0000","respondTo": "abc"}';
    
    Test.startTest();
    EDISSingleResponseDTO edissingleresdto = EDISSingleResponseDTO.parse(jsonStr);
    Test.stopTest();
    System.assertEquals('58fb5c78-77ed-4f58-97e3-6e0ae3ce498e', edissingleresdto.correlationId); 
    System.assertEquals(200, edissingleresdto.code);
    System.assertEquals('2018-07-26T05:03:20.299+0000', edissingleresdto.res_time);
    System.assertEquals('abc', edissingleresdto.respondTo);
    System.assertEquals('Pass', edissingleresdto.data.result);
        System.assertEquals(null, edissingleresdto.request);
        
    }
}