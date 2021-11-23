/*************************************************************************************************
Name : InvoiceChargeTypeRequestDTOTest
Description : Test class for InvoiceChargeTypeRequestDTO class
Author: Pawan Singh
Story: EDGE-207241
***************************************************************************************************/
@IsTest
public class InvoiceChargeTypeRequestDTOTest {
	static testMethod void testParse() {
        String json = '{"chargeId":112753 , "statementNumber":"9900000090669" ,"accountNumber":"700000015101"}';
		InvoiceChargeTypeRequestDTO obj = InvoiceChargeTypeRequestDTO.parse(json);
		System.assert(obj != null);
    }
}