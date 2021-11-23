/**************************************************************************
EDGE-207239
Description -DTO for feature pack charge for billing enquiry 
Author      - AKanksha 
Team        -Munich
Test class for FeaturePackResponseDTO
*********************************************************************************/

@isTest
public class FeaturePackDetailsResponseDTOTest {
  static testMethod void testParse() {
        Test.startTest();
        String json=		' {"accountNumber": "700000656848",'+
		'    "invoiceNumber": "9900000073760",'+
		'    "ariaInvoiceNumber": "151049513",'+
		'    "serviceType": "Licence fee (2)",'+
		'    "invoicePeriod": "13 Jan 21 - 07 Feb 21",'+
		'    "totalExGST": 9.08,'+
		'    "totalIncGST": 9.99,'+
		'    "totalQuantity": 3,'+
		'    "totalSubscriptions": 5,'+
		'    "isTaxable": true,'+
		'    "invoiceDate": "08 Feb 21",'+
		'    "featurePackDetails": [{'+
		'        "orderNumber": "CN000-302-908",'+
		'        "amountExGST": 9.08,'+
		'        "amountIncGST": 9.99,'+
		'        "subscriptionIdentifier": "SVN-99999",'+
		'        "date": "07 Feb 21",'+
		'        "quantity": "6",'+
		'        "unitRate": 10,'+
		'        "isTaxable": true,'+
		'        "isBilled": true,'+
		'        "isDisputable": true,'+
		'        "isDiscounted": false,'+
		'        "isQueryable": true,'+
		'        "chargeIdentifier": 86927,'+
		'        "chargeType": "RecurringCharge",'+
		'        "invoiceLineAttributes": [{'+
		'            "invoiceLineNumber": 3,'+
		'            "invoiceTransactionId": 205273729,'+
		'            "chargeExcludingGST": 9.08,'+
		'            "chargeIncludingGST": 9.99,'+
		'            "chargeCharacteristics": {'+
		'                "serviceInstanceId": "SVC-000124595",'+
		'                "chargeInstanceId": "7b4dd1e6-caeb-2a69-5437-23b82eeab6aa",'+
		'                "isRedeemable": false,'+
		'                "orderReference": "CN000-302-908"'+
		'            }'+
		'        }],'+
		'        "unitPrice": 4.54,'+
		'        "dateCalculated": "06 Feb 21"'+
		'    }]'+
		'}';
		FeaturePackResponseDTO obj = FeaturePackResponseDTO.parse(json);
		System.assert(obj != null);
        list<FeaturePackResponseDTO.featurePackDetails> res = obj.featurePackDetails;
        system.assertEquals('CN000-302-908', res[0].orderNumber);
         system.assertEquals('SVN-99999', res[0].uniqueId);
         system.assertEquals('6', res[0].quantity);
         system.assertEquals(9.08, res[0].excludingGSTcostFmtd);
         system.assertEquals(9.99, res[0].includingGSTcostFmtd);
         system.assertEquals(10, res[0].unitRate);
         system.assertEquals(86927, res[0].chargeIdentifier);
       system.assertEquals(null, res[0].invoiceTransactionId);
        Test.stopTest();
	}
}