@isTest
global class EmailSuccessMockResponseGenerator implements HttpCalloutMock {
    public static final String SUCCESSTEST = 'testSuccess_CISEmail';
    protected String testName;

    public EmailSuccessMockResponseGenerator(String testName) {
        this.testName = testName;
    }
    
    global HTTPResponse respond(HTTPRequest req) {
        req.getEndpoint();
        HttpResponse res = new HttpResponse();
        if(this.testName == SUCCESSTEST){
             res.setStatusCode(202);
             res.setBody('{"code":40005,"applicationLabel":"Notify-TVT","time":"2018-11-02T07:10:36.487+0000","correlationId":"6c8d3fb8-de0c-42d8-8e2d-c2516f6c0198","data":{},"status":422,"message":"No HTML markup allowed for content parameters","errors":[{"code":"202","message":""}],"path":"/v1/notification/gateway","method":"POST"}');
        }
        else{            
          res.setBody(ABRTestUtils.getStaticResourceBody('EmailMockSuccessResponse'));
          res.setStatusCode(202);
        }        
        return res;
    }

}