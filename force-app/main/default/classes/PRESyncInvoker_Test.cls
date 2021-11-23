@isTest
public class PRESyncInvoker_Test {
    @TestVisible private static String method;
    @TestVisible private static String endpoint;
    @TestVisible private static String payload1;
    @TestVisible private static object payload='{"example":"test"}';
    private class RestMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(200);
            return res;
        }
    }
    static testMethod void service_call() {
        RequestUtil.preConstants  = (Integration_Handler__mdt) JSON.deserialize( '{"Mock_End_Point__c":"87b3718f-5737-4318-bc42-563dd23de62e","End_Point__c":"https://test.com","Client_Id__c":"64a57384-d18f-4aa0-848c-a3cca875ee64","Client_Secret__c":"23924a8acf3b3004e391f01a700698578c5a9b3d5d68a4bd23","oauth_Method__c":"POST", "MasterLabel":"PRE Constants"}',Integration_Handler__mdt.class );
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        PRESyncInvoker.synchronise();
        Test.StopTest();
    }
    
    static testMethod void service_call2() {
        RequestUtil.preConstants  = (Integration_Handler__mdt) JSON.deserialize( '{"Mock_End_Point__c":"87b3718f-5737-4318-bc42-563dd23de62e","End_Point__c":"https://test.com","Client_Id__c":"64a57384-d18f-4aa0-848c-a3cca875ee64","Client_Secret__c":"23924a8acf3b3004e391f01a700698578c5a9b3d5d68a4bd23","oauth_Method__c":"POST", "MasterLabel":"PRE Constants"}',Integration_Handler__mdt.class );
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        PRESyncInvoker.getLastSynchronisations();
        PRESyncInvoker.getPromotionsGroupCodes();
        Test.StopTest();
    }
}