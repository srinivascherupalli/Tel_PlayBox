@isTest
public class MockManageOrderResponseGenerator implements HttpCalloutMock {

    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    public MockManageOrderResponseGenerator(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }

    public HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        String endPoint = req.getEndpoint();
        for (String key : this.responseHeaders.keySet()) {
            res.setHeader(key, this.responseHeaders.get(key));
        }
        if(endPoint.contains('/manageorder')) {
            String js = respAcknowledgment();
            res.setBody(js);
        } else if (endPoint.contains('token')) {
            res.setBody('{ "access_token": "tElsAddR32156teSt","expires_in": "2000"}');
        } 
        res.setStatusCode(this.code);
        //res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;
    }

    public String respAcknowledgment(){
        return '{"status", "received"}'; 
    }

}