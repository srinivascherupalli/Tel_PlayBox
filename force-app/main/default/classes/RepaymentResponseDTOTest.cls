/*************************************************************************************************
Name : RepaymentResponseDTOTest
Description : Test class for RepaymentResponseDTO class
Author: Jawahar M
Story: EDGE-108333
***************************************************************************************************/
@IsTest
public class RepaymentResponseDTOTest{
    static testMethod void testParse() {
        String json = '{ "repaymentSummary": { "deviceName": "Apple Watch S6 Cell 40mm Blue with Deep Navy Sport Band Repayment (1)", "invoicePeriod": "1 Nov 21 - 30 Nov 21", "accountNumber": "700000767918", "invoiceNumber": "9900000108260", "ariaInvoiceNumber": "152019882", "chargedThisInvoice": 62.42, "chargedSoFar": 312.1, "totalRemaining": 187.26, "isTaxable": false, "repaymentType": 0, "repaymentDetails": [ { "purchaseDate": "2 Aug 21", "installment": "5 of 8", "unitPrice": 62.42, "chargedSoFar": 312.10, "totalRemaining": 187.26, "isDisputable": true, "isQueryable": true, "chargeType": "RecurringCharge", "chargeIdentifier": 136710, "isTaxable": false, "chargedThisInvoice": 0.0, "invoiceLineAttributes": [ { "invoiceLineNumber": 2, "invoiceTransactionId": 207543026, "chargeExcludingGST": 62.42, "chargeIncludingGST": 62.42 } ] } ] } }';
        RepaymentResponseDTO obj = RepaymentResponseDTO.parse(json);
        System.assert(obj != null);
        RepaymentResponseDTO.RepaymentSummary repSummary =(RepaymentResponseDTO.RepaymentSummary)obj.repaymentSummary;
        List<RepaymentResponseDTO.RepaymentSummary> recList = new List<RepaymentResponseDTO.RepaymentSummary>();
        recList.add(repSummary);
        for(RepaymentResponseDTO.RepaymentSummary repaymentSum:recList)
        {
            for(RepaymentResponseDTO.repaymentDetails repaymentDet:repaymentSum.repaymentDetails)
            {
                system.assertEquals(null, repaymentDet.uniqueId);
                system.assertEquals(null, repaymentDet.orderNumber);
                system.assertEquals('2 Aug 21', repaymentDet.purchaseDate);
                system.assertEquals(null, repaymentDet.quantity);
                system.assertEquals(62.42, repaymentDet.unitPrice);
                system.assertEquals('5 of 8', repaymentDet.installment);
                system.assertEquals(312.10, repaymentDet.chargedSoFar);
                system.assertEquals(0.0, repaymentDet.chargedThisInvoice);

                
                for(RepaymentResponseDTO.invoiceLineAttributes invoiceAttrib: repaymentDet.invoiceLineAttributes)
                {
                    repaymentDet.excludingGSTcostFmtd = invoiceAttrib.excludingGSTcostFmtd;
                    repaymentDet.includingGSTcostFmtd = invoiceAttrib.includingGSTcostFmtd;
                    repaymentDet.invoiceTransactionId= invoiceAttrib.invoiceTransactionId;
                }
            } 
        }
    }
}