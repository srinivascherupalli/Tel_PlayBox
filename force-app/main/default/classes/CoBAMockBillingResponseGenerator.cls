/**================================================================
* Name: CoBAMockBillingResponseGenerator
* Description: Class to generate Mock response for COBA
* Created Date: April 29, 2021
* Created By: Akanksha Jain 
==================================================================*/
@isTest
public class CoBAMockBillingResponseGenerator implements HttpCalloutMock {
    public Integer code;
    public String status;
    public String body;
    public Map<String, String> responseHeaders;

    public CoBAMockBillingResponseGenerator(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.body = body;
        this.responseHeaders = responseHeaders;
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        system.debug('InsideHTTPResponse');
        String endPoint = req.getEndpoint();
        for (String key : this.responseHeaders.keySet()) {
            res.setHeader(key, this.responseHeaders.get(key));
        }
         if(body.equalsIgnoreCase('retrieveFullSuccessResponse')){
          res.setBody('{"code":202,"status":202,"message":"Success","eventId":"385113da-8de9-43f7-b6fa-63e8ac158db3"}');
        } else if(body.equalsIgnoreCase('404Response')){
            res.setBody('{"code":422,"status":422,"message":"Validation failed","errors":[{"code":1002,"field":"billingAccountNumber","message":"Mismatch in URI and request payload billingAccountNumber"}]}');
        } else {
            res.setBody('');
        }
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;    
    }
}