/*************************************************************************************************
Name : RepaymentRequestDTOTest
Description : Test class for RepaymentRequestDTO class
Author: Jawahar M
Story: EDGE-108333
***************************************************************************************************/
@IsTest
public class RepaymentRequestDTOTest {
  static testMethod void testParse() {
        String json = '{"statementNumber":"9900000182889","chargeId":148442927}';
        RepaymentRequestDTO obj = RepaymentRequestDTO.parse(json);
    System.assert(obj != null);
    }
}