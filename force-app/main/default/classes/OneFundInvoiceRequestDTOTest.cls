/*************************************************************************************************
Name : OneFundInvoiceRequestDTO
Description : Response DTO for Invoice by Number/PDF Callout
Author: Vamshi
Story: EDGE-124053
***************************************************************************************************/
@IsTest
public class OneFundInvoiceRequestDTOTest {
	
	static testMethod void testParse() {
		String json = '{"customerAccountNumber":"700000002978","invoiceNumber":9900000202350}';
		OneFundInvoiceRequestDTO obj = OneFundInvoiceRequestDTO.parse(json);
		System.assert(obj != null);
	}
}