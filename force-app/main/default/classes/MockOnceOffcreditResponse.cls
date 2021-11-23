@isTest
global class MockOnceOffcreditResponse implements HTTPCalloutMock{ 

    public MockOnceOffcreditResponse(){
    }
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String endPoint = req.getEndpoint();
        system.debug('endpoint mock'+endPoint);
        
        if(endPoint.contains('billing-accounts//adjustments')) {
            String js = resOnceOffErr();
            res.setBody(js);
        }else if( endPoint.contains('billing-accounts/123456789012/adjustments')) 
        {
         String js = resOnceOffSucc();
            res.setBody(js);
        }
        else if (endPoint.contains('token')) {
            res.setBody('{ "access_token": "tElsAddR32156teSt","expires_in": "2000"}');
        } 
        res.setStatusCode(200);
        return res;
    }
    
    
    public string resOnceOffErr()
    {
          string reserror='{     \"code\": 422,     \"status\": 422,     \"message\": \"Validation failed\",     \"errors\": [       {       \"code\": 1004,       \"field\":\"productId\",       \"message\":\"productId is a mandatory field\"     }   ]}';
          //'{   \"description\": \"Once-off Credit Adjustment\",    \"productId\": \"DMCAT_ProductSpecification_000099\",    \"instanceId\": \"b8905354-a164-b480-9fb2-75c2d1a8499a1\",    \"adjustmentType\":\"Once-off\",    \"amount\":100.90,    \"currencyCode\":\"AUD\",    \"gstIndicator\":\"GST Applicable\",    \"reasonCode\":\"2001\" }';
        return reserror;
    }
    
     public string resOnceOffSucc()
    {
          string resSuccess='{  \"code\": 201,  \"status\": 201,  \"message\": \"Success\"}';
            return resSuccess;
    }
    
    static testMethod void TestMethod1(){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://example.com/example/test');
        req.setMethod('GET');
        System.assertEquals('http://example.com/example/test', req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
    }
}