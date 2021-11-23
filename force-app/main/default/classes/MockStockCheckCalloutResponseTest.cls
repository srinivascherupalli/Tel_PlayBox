@isTest
    public class MockStockCheckCalloutResponseTest{
        @isTest
        public static void testMockStockCheckRespond200(){
            test.startTest();
            MockStockCheckCalloutResponse mockresponse = new MockStockCheckCalloutResponse('success_Search');
            HTTPResponse response = mockresponse.respond(new HttpRequest());
            System.assertEquals(response.getStatusCode()==200, true,'Success');
            test.stopTest();
        }
        @isTest
        public static void testMockStockCheckRespond422(){
            test.startTest();
            MockStockCheckCalloutResponse mockresponse = new MockStockCheckCalloutResponse('success_Error');
            HTTPResponse response = mockresponse.respond(new HttpRequest());
            System.assertEquals(response.getStatusCode()==422, true,'Error');
            test.stopTest();
        }
        @isTest
        public static void testMockStockCheckResserveRespondNull(){
            test.startTest();
            MockStockCheckCalloutResponse mockresponse = new MockStockCheckCalloutResponse('null_Response');
            HTTPResponse response = mockresponse.respond(new HttpRequest());
            System.assertEquals(response==Null, true,'Exception');
            test.stopTest();
        }
         /*-------------------------------------------------------- 
EDGE-80860
Method: testMockStockCheckMultiple
Description: Test method for StockCheckMultiple Success
Author:Kalashree Borgaonkar
--------------------------------------------------------*/
        @isTest
        public static void testMockStockCheckMultiple(){
            test.startTest();
            MockStockCheckCalloutResponse mockresponse = new MockStockCheckCalloutResponse('success_multiple');
            HTTPResponse response = mockresponse.respond(new HttpRequest());
            System.assertEquals(response!=Null, true,'Success');
            test.stopTest();
        }

    }