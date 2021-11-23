/*************************************************************************************************
Name : UsageRequestDTOTest
Description : Test class for UsageRequestDTO class
Author: Sasidhar Devarapalli
Story: EDGE-108332
***************************************************************************************************/
@IsTest
public class UsageRequestDTOTest {
	static testMethod void testParse() {
        String json = '{"usageTypeCode":"7001","statementNumber":"9900000182889","invoiceNumber":"148442927","accountNumber":"700000005112","invoicePeriod":"01 Jun 19 - 23 Jun 19","planInstanceDetailsList":[14485289,14485293,14485295],"taxInclusive":0,"taxRate":0}';
        UsageRequestDTO obj = UsageRequestDTO.parse(json);
		System.assert(obj != null);
    }
}