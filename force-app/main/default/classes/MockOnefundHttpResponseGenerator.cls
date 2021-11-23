/*
    AUTHOR : Sajal Shah    
    DESCRIPTION : This class is the mock response class for One Fund Integration
*/


@isTest
global class MockOnefundHttpResponseGenerator implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        String endPoint = req.getEndpoint();
        String contentType = req.getHeader('Content-Type');
        res.setHeader('Content-Type', 'application/json');
        if(endPoint.contains('oauth/token')) {
            res.setStatusCode(200);
            res.setBody('{"access_token":"AoS7LZ5w4GA0X4BwU6kWABLZLqQb","token_type":"Bearer","expires_in":"3599","Error":"false"}');
        }
        if(endPoint.contains('OneFundTransaction') && contentType == EnvironmentVariable.get('onefund_okapi_contenttype')) {
            res.setStatusCode(200);
            res.setBody('{"contributionBalance":"10000.00","fundBalance":"20000.00","cidn":"3898757888","Error":"false"}');
        }
        if(endPoint.contains('OneFundTransaction') && contentType == EnvironmentVariable.get('onefund_okapi_patch_contenttype')) {
            res.setStatusCode(200);
            res.setBody('{"cidn":"3898757888","message":"One fund successfully transferred","Error":"false"}');
        }
        if(endPoint.contains('oauth/token') && EnvironmentVariable.get('onefund_okapi_transaction_endpoint') == null) {
            res.setStatusCode(400);
            res.setBody('{null, "Error":"true"}');
        }
        if(endPoint.contains('OneFundTransactionTest')) {
            res.setStatusCode(400);
            res.setBody('{null, "Error":"true"}');
        }
        if(endPoint.contains('OneFundTransactionTestPatch')) {
            res.setStatusCode(400);
            res.setBody('{null,"Error":"true"}');
        }
        return res;
    }
    
}