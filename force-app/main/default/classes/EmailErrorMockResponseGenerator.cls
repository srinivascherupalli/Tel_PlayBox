@isTest
global class EmailErrorMockResponseGenerator implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        String endPoint = req.getEndpoint();
        HttpResponse res = new HttpResponse();
        res.setStatusCode(400);
        return res;
    }

}