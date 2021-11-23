/*************************************************************************************************
Name : MockNumberReservationFixedTest
Description : Mock Test class for Fixed Number Reservation
Author: Ila
Story: EDGE-59987
***************************************************************************************************/
@isTest
    public class MockNumberReservationFixedTest {
/*************************************************************************************************
Name : mockNumberReservationFixedSuccess
Author: Ila
Story: EDGE-59987
***************************************************************************************************/
        @isTest
        public static void mockNumberReservationFixedSuccess(){
            test.startTest();
            MockNumberReservationFixed mockresponse = new MockNumberReservationFixed('success_fixed');
            HTTPResponse response = mockresponse.respond(new HttpRequest());
            System.assertEquals(response.getStatusCode()==200, true,'Success');
            test.stopTest();
        }
/*************************************************************************************************
Name : mockNumberReservationFixedError
Author: Ila
Story: EDGE-59987
***************************************************************************************************/
        @isTest
        public static void mockNumberReservationFixedError(){
            test.startTest();
            MockNumberReservationFixed mockresponse = new MockNumberReservationFixed('errorResponse');
            HTTPResponse response = mockresponse.respond(new HttpRequest());
            System.assertEquals(response.getStatusCode()==422, false,'Error');
            test.stopTest();
        }
/*************************************************************************************************
Name : mockNumResFixedPartialSuccess
Author: Ila
Story: EDGE-59987
***************************************************************************************************/
         @isTest
        public static void mockNumResFixedPartialSuccess(){
            test.startTest();
            MockNumberReservationFixed mockresponse = new MockNumberReservationFixed('partialSuccess');
            HTTPResponse response = mockresponse.respond(new HttpRequest());
            System.assertEquals(response.getStatusCode()==200, true,'Success');
            test.stopTest();
        }
/*************************************************************************************************
Name : mockNumResRangePartialSuccess
Author: Ila
Story: EDGE-100660
***************************************************************************************************/
         @isTest
        public static void mockNumResRangePartialSuccess(){
            test.startTest();
            MockNumberReservationFixed mockresponse = new MockNumberReservationFixed('partialSuccessRange');
            HTTPResponse response = mockresponse.respond(new HttpRequest());
            System.assertEquals(response.getStatusCode()==200, true,'Success');
            test.stopTest();
        }
/*************************************************************************************************
Name : mockNumResRangeFail
Author: Ila
Story: EDGE-100660
***************************************************************************************************/
         @isTest
        public static void mockNumResRangeFail(){
            test.startTest();
            MockNumberReservationFixed mockresponse = new MockNumberReservationFixed('rangeFailure');
            HTTPResponse response = mockresponse.respond(new HttpRequest());
            System.assertEquals(response.getStatusCode()==409, true,'Error');
            test.stopTest();
        }
/*************************************************************************************************
Name : mockNumResRangeSuccess
Author: Ila
Story: EDGE-100660
***************************************************************************************************/
         @isTest
        public static void mockNumResRangeSuccess(){
            test.startTest();
            MockNumberReservationFixed mockresponse = new MockNumberReservationFixed('rangeSuccess');
            HTTPResponse response = mockresponse.respond(new HttpRequest());
            System.assertEquals(response.getStatusCode()==200, true,'Success');
            test.stopTest();
        }
/*************************************************************************************************
Name : mockNumResRangePartial
Author: Ila
Story: EDGE-100660
***************************************************************************************************/
         @isTest
        public static void mockNumResRangePartial(){
            test.startTest();
            MockNumberReservationFixed mockresponse = new MockNumberReservationFixed('rangePartial');
            HTTPResponse response = mockresponse.respond(new HttpRequest());
            System.assertEquals(response.getStatusCode()==200, true,'Success');
            test.stopTest();
        }
        /*************************************************************************************************
Name : mockNumSearchSuccess
Author: Aishwarya
Story: EDGE-100659
***************************************************************************************************/
         @isTest
        public static void mockNumSearchSuccess(){
            test.startTest();
            MockNumberReservationFixed mockresponse = new MockNumberReservationFixed('search_nonCon');
            HTTPResponse response = mockresponse.respond(new HttpRequest());
            System.assertEquals(response.getStatusCode()==200, true,'Success');
            test.stopTest();
        }
        
    }