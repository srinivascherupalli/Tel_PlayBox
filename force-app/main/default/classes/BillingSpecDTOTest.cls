@isTest
public with sharing class BillingSpecDTOTest {
	@istest static void testParse() {
    	String jsonstr = '{"correlationId": "328fdbb9-a4e5-4c4c-b72f-0be6b9422917","sourceSystem": "CloudSense","billingAccountNumber": 71234567,"productActionType": "add","effectiveDate": "2017-09-29T05:00:16.000Z","additionalBillInfo": [{"value": "Australia","name": "siteName"}],"productOffering":{"productId":"CWP_OFFER_123","invoiceDefinition": "Invoice_Def_1","productInstanceId": "b8905354-a164-b480-9fb2-75c2d1a8498a","description": "Connected Workplace Package"},"orderItems": [{"productInstanceId": "b8905354-a164-b480-9fb2-75c2d1a8499b","parentProductInstanceId":"b8905354-a164-b480-9fb2-75c2d1a8499a","productId": "SEAT_123","billingSpecId": "BSRC001_CB","description": "CWP Zone 1 Seat Charges","frequency": "Monthly","currencyCode": "AUD","billInAdvance": "Y","prorateType": "prorate","productActionType": "add","effectiveDate": "2017-09-29T05:00:16.000Z","units": 25,"unitPrice": 50.00,"invoiceDefinition": "Invoice_Def_1","services": [{"id": "0386545400-0386545450"}]}]}';
		Test.startTest();
        BillingSpecDTO billSpecDTO = BillingSpecDTO.parse(jsonstr);
        Test.stopTest();
       // System.assertEquals('328fdbb9-a4e5-4c4c-b72f-0be6b9422917', billSpecDTO.correlationId);
       // System.assertEquals('CloudSense',billSpecDTO.sourceSystem);
        System.assertEquals(71234567,billSpecDTO.billingAccountNumber);
        System.assertEquals('add',billSpecDTO.productActionType);
        System.assertNotEquals(billSpecDTO.effectiveDate,null);
        System.assertEquals('CWP_OFFER_123',billSpecDTO.productOffering.productId);
        System.assertNotEquals(billSpecDTO.productOffering.productInstanceId,null);
        System.assertEquals('Invoice_Def_1',billSpecDTO.productOffering.invoiceDefinition);
		System.assertEquals('Connected Workplace Package',billSpecDTO.productOffering.description);
        System.assertEquals('b8905354-a164-b480-9fb2-75c2d1a8499b',billSpecDTO.orderItems[0].productInstanceId);
        System.assertEquals('b8905354-a164-b480-9fb2-75c2d1a8499a',billSpecDTO.orderItems[0].parentProductInstanceId);
        System.assertEquals('SEAT_123',billSpecDTO.orderItems[0].productId);
        System.assertEquals('BSRC001_CB',billSpecDTO.orderItems[0].billingSpecId);
        System.assertEquals('add',billSpecDTO.orderItems[0].productActionType);
        System.assertNotEquals(billSpecDTO.orderItems[0].effectiveDate,null);
        System.assertEquals(25,billSpecDTO.orderItems[0].units);
        System.assertEquals(50.00,billSpecDTO.orderItems[0].unitPrice);
        System.assertEquals('CWP Zone 1 Seat Charges',billSpecDTO.orderItems[0].description);
        System.assertEquals('Monthly',billSpecDTO.orderItems[0].frequency);
        System.assertEquals('AUD',billSpecDTO.orderItems[0].currencyCode);
        System.assertEquals('Y',billSpecDTO.orderItems[0].billInAdvance);
        System.assertEquals('prorate',billSpecDTO.orderItems[0].prorateType);
        System.assertEquals('siteName',billSpecDTO.additionalBillInfo[0].name);
        System.assertEquals('Australia',billSpecDTO.additionalBillInfo[0].value);
    }
}