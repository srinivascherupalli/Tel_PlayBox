/**************************************************************************
EDGE-207239
Description -DTO for recurring charge for billing enquiry 
Author      - Prajakta 
Team        -Munich
Test class for RecurringChargeTypeResponseDTO 
*********************************************************************************/

@isTest
public class RecurringChargeTypeResponseDTOTest {
    static testMethod void testParse() {
        Test.startTest();
        String json = '{'+
		'  \"accountNumber\": \"700000693114\",'+
		'  \"invoiceNumber\": \"9900000074715\",'+
		'  \"ariaInvoiceNumber\": \"151125592\",'+
		'  \"serviceType\": \"Licence fee (8)\",'+
		'  \"invoicePeriod\": \"25 Mar 21 - 26 Mar 21\",'+
		'  \"totalExGST\": 34.5,'+
		'  \"totalIncGST\": 37.95,'+
		'  \"recurringType\": 3,'+
		'  \"isTaxable\": true,'+
		'  \"invoiceDate\": \"26 Feb 21\",'+
		'  \"recurringDetails\": ['+
		'    {'+
		'      \"orderNumber\": \"CN000-327-523\",'+
		'      \"serviceId\": \"12345\",'+
		'      \"amountExGST\": 9.08,'+
		'      \"amountIncGST\": 9.99,'+
		'      \"startDate\": \"25 Feb 21\",'+
		'      \"endDate\": \"25 Feb 21\",'+
		'      \"quantity\": \"2\",'+
		'      \"isDiscounted\": false,'+
		'      \"isTaxable\": true,'+
		'      \"isQueryable\": true,'+
		'      \"isDisputable\": true,'+
		'      \"chargeIdentifier\": 90583,'+
		'      \"chargeType\": \"RecurringCharge\",'+
		'      \"invoiceLineAttributes\": ['+
		'        {'+
		'          \"invoiceLineNumber\": 8,'+
		'          \"invoiceTransactionId\": 205367632,'+
		'          \"chargeExcludingGST\": 9.08,'+
		'          \"chargeIncludingGST\": 9.99,'+
		'          \"chargeCharacteristics\": {'+
		'            \"serviceInstanceId\": \"SVC-000151899\",'+
		'            \"chargeInstanceId\": \"9fbe7646-4a85-878b-14cc-de59ce25276e\",'+
		'            \"isRedeemable\": false,'+
		'            \"orderReference\": \"CN000-327-523\"'+
		'          }'+
		'        }'+
		'      ],'+
		'      \"basePlan\": \"Mobile Broadband Essential\",'+
		'      \"unitPrice\": 4.54,'+
		'      \"dateCalculated\": \"25 Feb 21\",'+
		'      \"tenancyId\": \"20162\"'+
		'    }'+
		'  ]'+
		'}';
		RecurringChargeTypeResponseDTO obj = RecurringChargeTypeResponseDTO.parse(json);
		System.assert(obj != null);
        list<RecurringChargeTypeResponseDTO.RecurringDetails> rec = obj.recurringDetails;
        system.assertEquals('CN000-327-523', rec[0].orderNumber);
         system.assertEquals('Mobile Broadband Essential', rec[0].basePlan);
         system.assertEquals('2', rec[0].quantity);
         system.assertEquals(9.08, rec[0].excludingGSTcostFmtd);
         system.assertEquals(9.99, rec[0].includingGSTcostFmtd);
         system.assertEquals('12345', rec[0].uniqueId);
         system.assertEquals(90583, rec[0].chargeIdentifier);
        Test.stopTest();
	}

}