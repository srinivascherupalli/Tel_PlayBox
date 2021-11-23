//DIGI-25050
@IsTest
public class FetchPayoutDetailsSyncRespDtoTest {
	
	static testMethod void testParse() {
		String json = '{'+
		'  \"code\": 200,'+
		'  \"status\": 200,'+
		'  \"message\": \"Success\",'+
		'  \"billingAccountNumber\": 700000000012,'+
		'  \"subscriptionId\": \"SN-000033817\",'+
		'  \"chargesDetails\": ['+
		'    {'+
		'      \"instanceId\": \"c846491d-d696-cc07-912a-6f76109be6fc\",'+
		'      \"durationUnit\": \"Months\",'+
		'      \"durationRemaining\": 15,'+
		'      \"chargeRemaining\": 300,'+
		'      \"units\": 1,'+
		'      \"taxTreatment\": \"TAX Exempt\",'+
		'      \"validTill\": \"10-SEP-2021\"'+
		'    },'+
		'    {'+
		'      \"instanceId\": \"c846491d-d696-cc07-912a-6f76109be6fd\",'+
		'      \"durationUnit\": \"Months\",'+
		'      \"durationRemaining\": 10,'+
		'      \"chargeRemaining\": 200,'+
		'      \"units\": 1,'+
		'      \"taxTreatment\": \"TAX Exempt\",'+
		'      \"validTill\": \"10-SEP-2021\"'+
		'    }'+
		'  ]'+
		'}';
		FetchPayoutDetailsSyncRespDto obj = FetchPayoutDetailsSyncRespDto.parse(json);
		System.assert(obj != null);
	}
}