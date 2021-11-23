/*************************************************************************************************
Name : OnceOffChargeResponseDTOTest
Description : Test class for InvoiceChargeTypeRequestDTO class
Author: Pawan Singh
Story: EDGE-207241 
***************************************************************************************************/
@IsTest
public class OnceOffChargeResponseDTOTest {
	static testMethod void testParse() {
        String json = '{"accountNumber":"700000015101","invoiceNumber":"9900000530358","ariaInvoiceNumber":"149267726","serviceType":"Professional Service Installation 24x7 (2)","invoicePeriod":"01 Jun 20 - 30 Jun 20","totalExGST":600,"totalIncGST":660,"orderType":1,"isTaxable":true,"orderDetails":[{"orderNumber":"ORD-127","poNum":"REF123","quantity":"3.5 hrs","unitRate":100,"date":"15 Jul 20","amountExGST":350,"amountIncGST":385,"isTaxable":true,"isQueryable":true,"isDisputeable":true,"chargeType":"OnceOffCharge","chargeIdentifier":166201,"deviceId":"12345","caseId":"6747353","invoiceLineAttributes":[{"invoiceLineNumber":37,"invoiceTransactionId":24320,"chargeExcludingGST":350,"chargeIncludingGST":385,"chargeCharacteristics":{"serviceInstanceId":"a4e2O0000003PBJQA5","chargeInstanceId":"2c110lp9-0dd0-127d-b6a8-6babx42b0244","isRedeemable":false,"orderReference":"ORD-127"}}]}]}';
		OnceOffChargeResponseDTO obj = OnceOffChargeResponseDTO.parse(json);
        for(OnceOffChargeResponseDTO.orderDetails val : obj.orderDetails){
            System.assert(val.chargeIdentifier != null);
            System.assert(val.orderNumber != null);
            System.assert(val.uniqueId != null);
            System.assert(val.quantity != null);
            System.assert(val.excludingGSTcostFmtd != null);
            System.assert(val.includingGSTcostFmtd != null);
            System.assert(val.orderDate != null);
        }
		System.assert(obj != null);
    }
}