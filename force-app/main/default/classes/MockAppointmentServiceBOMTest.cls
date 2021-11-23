@isTest
    public class MockAppointmentServiceBOMTest {
        @isTest
        public static void testMockSBOMServiceRespond200(){
            test.startTest();
            MockAppointmentServiceBOM mockresponse = new MockAppointmentServiceBOM('success_GenerateAppo');
            HTTPResponse response = mockresponse.respond(new HttpRequest());
            System.assertEquals(response.getStatusCode()==200, true,'Success');
            test.stopTest();
        }
        @isTest
        public static void testMockSBOMServiceRespond422(){
            test.startTest();
            MockAppointmentServiceBOM mockresponse = new MockAppointmentServiceBOM('Error');
            HTTPResponse response = mockresponse.respond(new HttpRequest());
            System.assertEquals(response.getStatusCode()==422, true,'Error');
            test.stopTest();
        }
        @isTest
        public static void testMockSBOMServiceResserveRespond200(){
            test.startTest();
            MockAppointmentServiceBOM mockresponse = new MockAppointmentServiceBOM('reserve');
            HTTPResponse response = mockresponse.respond(new HttpRequest());
            System.assertEquals(response.getStatusCode()==200, true,'Success');
            test.stopTest();
        }
         @isTest
        public static void testMockSBOMServiceReserveRebook(){
            test.startTest();
            MockAppointmentServiceBOM mockresponse = new MockAppointmentServiceBOM('rebook');
            HTTPResponse response = mockresponse.respond(new HttpRequest());
            System.assertEquals(response.getStatusCode()==200, true,'Success');
            test.stopTest();
        }

    }