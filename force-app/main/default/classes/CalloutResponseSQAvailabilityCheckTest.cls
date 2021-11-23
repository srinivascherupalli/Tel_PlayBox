@isTest
public class CalloutResponseSQAvailabilityCheckTest {
    @isTest static void dummyTesting() {
        CalloutResponseSQAvailabilityCheck sqC = new CalloutResponseSQAvailabilityCheck();
        System.assertEquals(0, sqC.processResponseRaw(new Map<String, Object>()).size());
        System.assertEquals(0, sqC.getDynamicRequestParameters(new Map<String, Object>()).size());
        //sqC.runBusinessRules('');
        System.assert(sqC.canOffer(new Map<String, String>(), new Map<String, String>(), new csbb.CalloutProduct.ProductResponse()) != null);                     
    }
}