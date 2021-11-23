/*************************************************************************************************
Name : UsageResponseDTOTest
Description : Test class for UsageResponseDTO class
Author: Sasidhar Devarapalli
Story: EDGE-108332
***************************************************************************************************/
@IsTest
public class UsageResponseDTOTest {
	static testMethod void testParse() {
        String json = '{   "usageType": "Int roaming day pass - zone 1 (2)",   "invoicePeriod": "01 Jun 19 - 23 Jun 19",   "accountNumber": "700000005112",   "invoiceNumber": "9900000182889",   "ariaInvoiceNumber": 148442927,   "totalExGST": 10,   "totalIncGST": 10,   "usageDetails": [     {       "date": "17 May 2019",       "time": "10:20am",       "amountExGST": 5,       "amountIncGST": 5,       "isTaxable": false,       "isQueryable": true,       "isDisputable": true,       "chargeIdentifier": 10002891,       "chargeType": "UsageDetail",       "invoiceLineAttributes": [         {           "invoiceLineNumber": 9,           "invoiceTransactionId": 197167980,           "chargeExcludingGST": 5,           "chargeIncludingGST": 5         }       ]     },     {       "date": "18 May 2019",       "time": "11:20am",       "amountExGST": 5,       "amountIncGST": 5,       "isTaxable": false,       "isQueryable": true,       "isDisputable": true,       "chargeIdentifier": 10002892,       "chargeType": "UsageDetail",       "invoiceLineAttributes": [         {           "invoiceLineNumber": 9,           "invoiceTransactionId": 197167980,           "chargeExcludingGST": 5,           "chargeIncludingGST": 5         }       ]     },     {       "date": "18 May 2019",       "time": "11:20am",       "amountExGST": 5,       "amountIncGST": 5,       "isTaxable": false,       "isQueryable": true,       "isDisputable": true,       "chargeIdentifier": 10002893,       "chargeType": "UsageDetail",       "invoiceLineAttributes": [         {           "invoiceLineNumber": 10,           "invoiceTransactionId": 197167981,           "chargeExcludingGST": 5,           "chargeIncludingGST": 5         }       ]     }   ] }';
		UsageResponseDTO obj = UsageResponseDTO.parse(json);
		System.assert(obj != null);
    }
}