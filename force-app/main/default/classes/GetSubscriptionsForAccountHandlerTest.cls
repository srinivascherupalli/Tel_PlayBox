@isTest
private class GetSubscriptionsForAccountHandlerTest {

    static testMethod void testAuthErr001() {
        APIHandler handler = APIHandlerFactory.getHandler('GetSubscriptionsForAccount');
        RestRequest req  = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        Test.startTest();
        
        AuthorizeContactResponse response = (AuthorizeContactResponse ) handler.handle(req, res);
        Boolean testResult = response.hasError() == true &&
            response.code == 'AUTHERR_001' &&
            response.status == APIConstants.AUTHORIZE_CONTACT_STATUS.INVALID;
        Test.stopTest();
        
        system.assertEquals(testResult, true, 
                'expected errorCode = AUTHERR_001, status=' + APIConstants.AUTHORIZE_CONTACT_STATUS.INVALID);

    }
    
    static testMethod void testAuthErr002() {
        APIHandler handler = APIHandlerFactory.getHandler('GetSubscriptionsForAccount');
        RestRequest req  = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.headers.put('emailId', 'test@test.com');
        
        Test.startTest();
        
        AuthorizeContactResponse response = (AuthorizeContactResponse) handler.handle(req, res);
        Boolean testResult = response.hasError() == true &&
            response.code == 'AUTHERR_002' &&
            response.status == APIConstants.AUTHORIZE_CONTACT_STATUS.INVALID;

        Test.stopTest();

        system.assertEquals(testResult, true, 
                'expected errorCode = AUTHERR_002, status=' + APIConstants.AUTHORIZE_CONTACT_STATUS.INVALID);

    }
}