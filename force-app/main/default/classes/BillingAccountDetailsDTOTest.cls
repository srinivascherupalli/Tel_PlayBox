@IsTest
public class BillingAccountDetailsDTOTest {
	
	static testMethod void testParse() {
		String json = '{\"code\": 201,'+
		'    \"status\": 201,'+
		'    \"message\": \"Success\",'+
		'    \"billingAccount\": {'+
		'    \"billingAccountNumber\": 700000030481,'+
		'    \"status\": \"\",'+
		'    \"billCycleDay\": 1,'+
		'    \"paymentTerms\": 14,'+
		'    \"currencyCode\": \"AUD\",'+
		'    \"language\": \"English\" },'+
		'	\"errors\": [{'+
		'        \"code\": 1002,'+
		'        \"field\": \"billingAccountNumber\",'+
		'        \"message\": \"BAN doesnot exist in the Billing System\"'+
		'    }],'+
		'    \"correlationId\": \"\"'+
		'	}';
		BillingAccountDetailsDTO obj = BillingAccountDetailsDTO.parse(json);
        obj.code = 123;
        obj.billingAccount.billingAccountNumber=122345;
         obj.billingAccount.status = '';
              obj.billingAccount.billCycleDay =1;
              obj.billingAccount.paymentTerms=14;
              obj.billingAccount.currencyCode='';
        obj.correlationId='';
        obj.errors[0].code='201';
        obj.errors[0].message='OK';
        obj.errors[0].field='test';
		System.assert(obj != null);
	}
}