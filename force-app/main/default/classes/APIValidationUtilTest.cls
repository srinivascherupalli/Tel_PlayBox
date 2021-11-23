@istest
Private class APIValidationUtilTest{

    private static testMethod void vaidateAPI(){

        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        res.addHeader('Content-Type', 'application/json');

        String emailId = 'test@test.com';
        String CIDN = '12345678';

        req.addHeader('emailId', emailId);
        req.addHeader('CIDN', CIDN);        

        RestContext.request = req;
        RestContext.response = res;       
        APIValidationUtil.validateHeaders(req);
        AuthorizeContactForAccountHandler.getInstance();
        AuthorizeContactForAccountHandler.handle(req, res);
        try {
            AuthorizeContactResponse validation_result = AuthorizeContactForAccountUtil.validate(emailId,CIDN);
        } catch(AuthorizationException aex) {
            system.debug('expected exception: ' + aex);
            system.assert(aex.getMessage() == 'AUTHERR_003', 'expected error code to be AUTHERR_003');
        }

        Test.stopTest();

    }

}