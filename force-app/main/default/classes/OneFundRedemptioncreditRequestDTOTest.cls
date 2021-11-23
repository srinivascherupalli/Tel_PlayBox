/*************************************************************************************************
Name : OneFundRedemptioncreditRequestDTOTest
Description : Response DTO for credit request Callout
Author: Vamshi
Story: EDGE-124053
***************************************************************************************************/
@IsTest
public class OneFundRedemptioncreditRequestDTOTest {
    	static testMethod void testParse() {
		String json = '{"productId":"DMCAT_StandaloneProduct_000879","instanceId":"a8g5P00000002LaQAI","currencyCode":"AUD","comments":"Dispute Against Line Item","caseReferenceNumber":"","ariaInvoiceNumber":149311676,"adjustmentType":"Redemption-credit","adjustmentTarget":{"invoiceItem":[{"lineItemReasonCode":5001,"invoiceTransactionId":200989729,"invoiceLineNumber":7,"creditAmount":22.0,"chargeType":"OnceOffCharge"},{"lineItemReasonCode":5001,"invoiceTransactionId":200989730,"invoiceLineNumber":8,"creditAmount":22.0,"chargeType":"OnceOffCharge"},{"lineItemReasonCode":5001,"invoiceTransactionId":200989731,"invoiceLineNumber":9,"creditAmount":33.0,"chargeType":"OnceOffCharge"}]}}';
		OneFundRedemptioncreditRequestDTO obj = OneFundRedemptioncreditRequestDTO.parse(json);
		System.assert(obj != null);
	}
}