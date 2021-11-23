/*Author: Ila
Company: Tesltra 
User Story :EDGE-80745
Description: SQ Check for Mobile/MSISDN Lightning ResponseDTO Test.
*/

@IsTest
public class SQCheckMobileResponseDTOTest {

    static testMethod void testParseMsisdn() {
        String json = '{"status":200,"data":{"numberDetails":[{"mobileNumber":"msisdn2","mobileNumberPortabilityIndicator":"Y","reason":"The MSISDN can be Ported within Telstra network","code":"PORT_SUCCESS"}]}}';
        Test.startTest();
        SQCheckMobileResponseDTO dto = SQCheckMobileResponseDTO.parse(json);
        Test.stopTest();
        System.assertEquals(dto!=null, true,'DTO created');
    }
}