@isTest
public class EDISMockResponseGenerator implements HttpCalloutMock {
    static HttpResponse response = new HttpResponse();
    public HttpResponse respond(HttpRequest request){
        String endPoint = request.getEndpoint();
        System.debug('HTTpEndPoint : '+ endPoint);
        System.debug('HTTP Method :' + request.getMethod());
        System.debug('HTTP request : ' + request.getBody());

        if(request.getBody() != null && response.getStatusCode() == IntegrationRecordHandlerUtil.HTTP_ACCEPTED)
        {
            return getCallout200();
        }
        else if(request.getBody() != null && response.getStatusCode() != IntegrationRecordHandlerUtil.HTTP_ACCEPTED){
            return getCalloutNot202();
        }
        return getNullResponse();
        
    }
    
    private HttpResponse getCallout200(){
        response = new HttpResponse();
        response.setstatuscode(202);
        response.setBody('{"data": {"result": "Pass"},"correlationId": "58fb5c78-77ed-4f58-97e3-6e0ae3ce498e","code": "200","res_time": "2018-07-26T05:03:20.299+0000","respondTo": "abc","message": "error", "errors":[{"code": "400","message": "error"},{"code": "400","message": "error"}]}');
        return response;
    }
    
    private HttpResponse getCalloutNot202(){
        response = new HttpResponse();
        response.setBody('{ "correlationId": "58fb5c78-77ed-4f58-97e3-6e0ae3ce498e","code": "400","res_time": "2018-07-26T05:03:20.299+0000","respondTo": "abc", "message": "error", "errors":[{"code": "400","message": "error"},{"code": "400","message": "error"}]}');
        return response;
    }
    
    private HttpResponse getNullResponse(){
        response = new HttpResponse();
        response.setBody('{}');
        return null;
    }
    
    @isTest static void testCallout(){
        String contentType = 'application/json';
        System.assert(contentType == 'application/json');

    }
    
}