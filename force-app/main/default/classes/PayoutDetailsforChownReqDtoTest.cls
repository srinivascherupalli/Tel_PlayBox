//DIGI-30045
@IsTest
public class PayoutDetailsforChownReqDtoTest {
	
	static testMethod void testParse() {
		String json = '{'+
		'\"billingAccounts\":'+
		'  ['+
		'    {'+
		'      \"billingAccountNumber\": 700000000012,'+
		'      \"chargesDetails\":'+
		'        ['+
		'          {'+
		'            \"subscriptionId\": \"SN-000033817\",'+
		'            \"instanceId\": \"c846491d-d696-cc07-912a-6f76109be6fc\"'+
		'          }'+
		'        ]'+
		'    }'+
		'  ]'+
		'}';
		PayoutDetailsforChownReqDto obj = PayoutDetailsforChownReqDto.parse(json);
		System.assert(obj != null);
	}
}