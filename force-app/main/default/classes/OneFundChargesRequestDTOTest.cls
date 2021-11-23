/*-------------------------------------------------------- 
EDGE-123565
Class: OneFundChargesRequestDTOTest
Description: Test class for OneFundChargesRequestDTO
Author:Tejes
--------------------------------------------------------*/
@isTest
public class OneFundChargesRequestDTOTest {
	
    @isTest
    static void OneFundChargesRequestTest(){
        String jsonData = '{"units":1,"unitPrice":1020.00,"productId":"","taxTreatment":"GST Applicable","instanceId":"5c0f5ec9-139a-bcbc-920b-885dc5c5dca9","effectiveDate":"2020-01-01T11:33:13.043Z","description":"OneFund Termination Charge","currencyCode":"AUD","chargeTarget":{"subscriptionId":"SN","billingAccountNumber":700000375019},"billingSpecId":"BSOTC001_CB"}';
        OneFundChargesRequestDTO req = OneFundChargesRequestDTO.parse(jsonData);
        System.assertEquals(req.unitPrice, 1020.00);
        System.assertnotEquals(req.instanceId, null);
    }
}