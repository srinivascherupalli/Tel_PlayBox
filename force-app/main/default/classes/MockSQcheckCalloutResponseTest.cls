@isTest
public class MockSQcheckCalloutResponseTest {
    @isTest
    public static void testMockSQService_respond_200(){
        test.startTest();
        MockSQcheckCalloutResponse mockresponse = new MockSQcheckCalloutResponse('success_Search');
        HTTPResponse response = mockresponse.respond(new HttpRequest());
        System.assertEquals(response.getStatusCode()==200, true,'Success');
        test.stopTest();
    }
    @isTest
    public static void testMockSQService_respond_422(){
        test.startTest();
        MockSQcheckCalloutResponse mockresponse = new MockSQcheckCalloutResponse('success_Error');
        HTTPResponse response = mockresponse.respond(new HttpRequest());
        System.assertEquals(response.getStatusCode()==422, true,'Error');
        test.stopTest();
    }
    @isTest
    public static void testMockSQService_respond_Exception(){
        test.startTest();
        MockSQcheckCalloutResponse mockresponse = new MockSQcheckCalloutResponse('success_Exception');
        HTTPResponse response = mockresponse.respond(new HttpRequest());
        System.assertEquals(response.getStatusCode()==500,true,'Exception');
        test.stopTest();
    }
    @isTest
    public static void testMockWidefeasSQ_respond_Success(){
        test.startTest();
        MockSQcheckCalloutResponse mockresponse = new MockSQcheckCalloutResponse('success_Widefeas');
        HTTPResponse response = mockresponse.respond(new HttpRequest());
        System.assertEquals(response.getStatusCode()==200,true,'success');
        test.stopTest();
    }
    @isTest
    public static void testMockWidefeasSQ_respond_Error(){
        test.startTest();
        MockSQcheckCalloutResponse mockresponse = new MockSQcheckCalloutResponse('Error_Widefeas');
        HTTPResponse response = mockresponse.respond(new HttpRequest());
        System.assertEquals(response.getStatusCode()==400,true,'Error');
        test.stopTest();
    }
    	 /****************************************************************
      * P20B : 7333 For newly added Technology Type
      * Author:Ravi Dodiya
      * *********************************************************************/
    @isTest
    public static void testMockNBN_Ethernet_respond_Success(){
        test.startTest();
        MockSQcheckCalloutResponse mockresponse = new MockSQcheckCalloutResponse('success_NBN_Ethernet');
        HTTPResponse response = mockresponse.respond(new HttpRequest());
        System.assertEquals(response.getStatusCode()==200,true,'success');
        test.stopTest();
    }
    @isTest
    public static void testMockNBN_Ethernet_respond_Error(){
        test.startTest();
        MockSQcheckCalloutResponse mockresponse = new MockSQcheckCalloutResponse('Error_NBN_Ethernet');
        HTTPResponse response = mockresponse.respond(new HttpRequest());
        System.assertEquals(response.getStatusCode()==422,true,'Error');
        test.stopTest();
    }
}