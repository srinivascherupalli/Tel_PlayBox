/*************************************************************************************************
Name : InvoiceResponseDTO
Description : Response DTO for Invoice by Number/PDF Callout
Author: Kalashree Borgaonkar
Story: EDGE-88307
***************************************************************************************************/
@IsTest
public class InvoiceRequestDTOTest {
	
	static testMethod void testParse() {
		String json = '{"customerAccountNumber":"700000002978","invoiceNumber":9900000202350}';
		InvoiceRequestDTO obj = InvoiceRequestDTO.parse(json);
		System.assert(obj != null);
	}
}