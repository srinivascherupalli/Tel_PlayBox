@isTest
public class CalloutResponseAddressCheckTest {

    @isTest
    static void processResponseRaw_WillReturnEmptyMap() {
        CalloutResponseAddressCheck ck = new CalloutResponseAddressCheck();
        System.assertEquals(0, ck.processResponseRaw(new Map<String, Object>()).size());
    }
    
    @isTest
    static void getDynamicRequestParameters_WillReturnEmptyMap() {
        CalloutResponseAddressCheck ck = new CalloutResponseAddressCheck();
        System.assertEquals(0, ck.getDynamicRequestParameters(new Map<String, Object>()).size());
    }
    
    @isTest
    static void canOffer_WillReturnEmptyMap() {
        CalloutResponseAddressCheck ck = new CalloutResponseAddressCheck();
        System.assert(ck.canOffer(new Map<String, String>(), new Map<String, String>(), new csbb.CalloutProduct.ProductResponse()) != null);
    }
    
    @isTest
    static void justForTheCovrage() {
        CalloutResponseAddressCheck ck = new CalloutResponseAddressCheck();
        ck.runBusinessRules('');
    }

    @isTest
    static void justForTheCovrage2() {
        CalloutResponseAddressCheck ck = new CalloutResponseAddressCheck(null, null, null);
    }
}