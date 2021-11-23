@isTest
    public class MockPPVCalloutResponseTest{
        @isTest
        public static void testMockPPVCalloutRespond200(){
            test.startTest();
            MockPPVCalloutResponse mockresponse = new MockPPVCalloutResponse('success_Search');
            HTTPResponse response = mockresponse.respond(new HttpRequest());
            System.assertEquals(response.getStatusCode()==200, true,'Success');
            test.stopTest();
        }
        @isTest
        public static void testMockPPVCalloutRespond422(){
            test.startTest();
            MockPPVCalloutResponse mockresponse = new MockPPVCalloutResponse('success_Error');
            HTTPResponse response = mockresponse.respond(new HttpRequest());
            System.assertEquals(response.getStatusCode()==422, true,'Error');
            test.stopTest();
        }
         @isTest
        public static void testMockPPVCalloutRespond503(){
            test.startTest();
            MockPPVCalloutResponse mockresponse = new MockPPVCalloutResponse('success_Error_503');
            HTTPResponse response = mockresponse.respond(new HttpRequest());
            System.assertEquals(response.getStatusCode()==503, true,'Error');
            test.stopTest();
        }
        @isTest
        public static void testMockPPVCalloutRespondNull(){
            test.startTest();
            MockPPVCalloutResponse mockresponse = new MockPPVCalloutResponse('null_Response');
            HTTPResponse response = mockresponse.respond(new HttpRequest());
            System.assertEquals(response==Null, true,'Exception');
            test.stopTest();
        }

    }