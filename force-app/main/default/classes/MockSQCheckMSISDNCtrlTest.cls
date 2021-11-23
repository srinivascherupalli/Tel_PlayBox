/*Author: Ila
Company: Tesltra 
User Story :EDGE-80745
Description: Mock response Test class for Mobile/MSISDN SQ Check Lightning UI controller.
*/
@isTest
public class MockSQCheckMSISDNCtrlTest {
 @isTest
        public static void testMockSQRespond200(){
            Test.startTest();
            MockSQCheckMSISDNCtrl mockresponse = new MockSQCheckMSISDNCtrl('Success');
            HTTPResponse response = mockresponse.respond(new HttpRequest());
            System.assertEquals(response.getStatusCode()==200, true,'Success');
            Test.stopTest();
        }
        @isTest
        public static void testMockSQRespond401(){
            Test.startTest();
            MockSQCheckMSISDNCtrl mockresponse = new MockSQCheckMSISDNCtrl('Failure');
            HTTPResponse response = mockresponse.respond(new HttpRequest());
            System.assertEquals(response.getStatusCode()==401, true,'Error');
            Test.stopTest();
        }
    @isTest
        public static void testMockSQRespond429(){
            Test.startTest();
            MockSQCheckMSISDNCtrl mockresponse = new MockSQCheckMSISDNCtrl('Error429');
            HTTPResponse response = mockresponse.respond(new HttpRequest());
            System.assertEquals(response.getStatusCode()==429, true,'Error');
            Test.stopTest();
        }
     @isTest
        public static void testMockMultipleSQRespond200(){
            Test.startTest();
            MockSQCheckMSISDNCtrl mockresponse = new MockSQCheckMSISDNCtrl('success_multiple');
            HTTPResponse response = mockresponse.respond(new HttpRequest());
            System.assertEquals(response.getStatusCode()==200, true,'Success');
            Test.stopTest();
        }
     @isTest
        public static void testMockMultipleSQRespond404(){
            Test.startTest();
            MockSQCheckMSISDNCtrl mockresponse = new MockSQCheckMSISDNCtrl('failure_multiple');
            HTTPResponse response = mockresponse.respond(new HttpRequest());
            System.assertEquals(response.getStatusCode()==404, true,'Error');
            Test.stopTest();
        }
}