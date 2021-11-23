/******************************************************************************************************
Name          :PREApiv4PricingandRequestUtilTest
Created By    : Shradha Kapsikar
Created Date  : Aug 4 2020
Description   : This is a test class to simulate and test the logic of PREApiv4Pricing,RequestUtil,PRESyncInvoker,PRE_Constant and SharedSecretSignService.
History                                                            
-------                                                            
VERSION     AUTHOR          DATE            DETAIL                   
-------     ------          -----           ---------                 
1.1        Shradha       3-08-2020      Created
1.1        Shradha       4-08-2020     Added methods service_call

******************************************************************************************************/


@isTest(SeeAllData=false)
public class PREApiv4PricingandRequestUtilTest {
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
       
        Map<string,object> inputMap=new Map<string,object> ();
        inputMap.put('payload',payload);
        PREApiV4Pricings.getData(inputMap);
        PRESyncInvoker.synchronise();
        PRESyncInvoker.futureSynchronise();
        PRESyncInvoker.getLastSynchronisations();
        PRESyncInvoker.getPromotionsGroupCodes();
        Test.startTest();
        HttpResponse res= RequestUtil.sendRequest('method', 'endpoint', 'payload1');
        
        String contentType = res.getHeader('Content-Type');
       // System.assert(contentType == 'application/json');
        String actualValue = res.getBody();
        String expectedValue = '{"example":"test"}';
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, res.getStatusCode());
        

        Test.StopTest();


    
    }
}