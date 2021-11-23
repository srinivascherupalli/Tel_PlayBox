@isTest
global class SyncUpMockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        System.debug('PP response : '+res);
        res.setBody('{}');
        res.setStatusCode(202);
        return res;
    }
    
    
}