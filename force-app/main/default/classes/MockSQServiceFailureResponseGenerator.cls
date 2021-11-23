@isTest
global class MockSQServiceFailureResponseGenerator implements HttpCalloutMock{
    static final String SUCCESSTEST_SQFORSITE = 'testSuccess_checkSQForSite';
    static final String SUCCESSTEST_SQFORTRANSITION = 'testSuccess_checkSQForTransition';
    static final String SUCCESSTEST_SQFORMOVE = 'testSuccess_checkSQForMove';
    public static final String SITESQ_RESPONSE503 = 'testError503_checkSQForSite';
    static final Integer HTTP400 = 400;
    static final Integer HTTP500 = 500;
    static final Integer HTTP503 = 503;

    protected String testName;

    public MockSQServiceFailureResponseGenerator(String testName) {
        this.testName = testName;
    }

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        if(this.testName == SITESQ_RESPONSE503){
            res.setStatusCode(HTTP503);
            res.setBody(getResponse503());
        }else if(this.testName == SUCCESSTEST_SQFORTRANSITION){
            res.setStatusCode(HTTP400);
            res.setBody(getResponse400());
        }else if(this.testName == SUCCESSTEST_SQFORMOVE){
            res.setStatusCode(HTTP500);
            res.setBody(getResponse500());
        }
        return res;
    }

    static String getResponse503(){
        return '{'+
        '    \"code\": 503,'+
        '    \"errors\": ['+
        '        {'+
        '            \"message\": \"A technical error occurred during the processing of this request by downstream system.\",'+
        '            \"code\": \"000000\"'+
        '        }'+
        '    ]'+
        '}';
    }

    static String getResponse400(){
        return '{'+
        '    \"code\": 400,'+
        '    \"errors\": ['+
        '        {'+
        '            \"message\": \"Bad Request.\",'+
        '            \"code\": \"000000\"'+
        '        }'+
        '    ]'+
        '}';
    }

    static String getResponse500(){
        return '{'+
        '    \"code\": 500,'+
        '    \"errors\": ['+
        '        {'+
        '            \"message\": \"Bad Request.\",'+
        '            \"code\": \"000000\"'+
        '        }'+
        '    ]'+
        '}';
    }

    static String getResponse404_ForSQMove(){
        return '{'+
        '    \"status\": 404,'+
        '    \"data\": {},'+
        '    \"errors\": {'+
        '        \"errorDetails\":['+
        '        {'+
        '            \"message\": \"Given Address Id {{addressId}} not found\",'+
        '            \"code\": \"ADDRESS_ID_NOT_FOUND\"'+
        '        }]'+
        '    }'+
        '}';
    }

    static String getResponse502_ForSQMove(){
        return '{'+
        '    \"status\": 502,'+
        '    \"data\": {},'+
        '    \"errors\": {'+
        '        \"errorDetails\":['+
        '        {'+
        '            \"message\": \"Unable to process the request. Downstream service error\",'+
        '            \"code\": \"SERVICE_ERROR\"'+
        '        }]'+
        '    }'+
        '}';
    }

    static String getResponse500_ForSQMove(){
        return '{'+
        '    \"status\": 500,'+
        '    \"data\": {},'+
        '    \"errors\": {'+
        '        \"errorDetails\":['+
        '        {'+
        '            \"message\": \"A technical error occurred during the processing of this request by downstream system.\",'+
        '            \"code\": \"INTERNAL_ERROR\"'+
        '        }]'+
        '    }'+
        '}';
    }
    
    static testMethod void TestMethod1(){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://example.com/example/test');
        req.setMethod('GET');
        System.assertEquals('http://example.com/example/test', req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
    }
}