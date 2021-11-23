@isTest
public class SendEmailMockResponse implements HttpCalloutMock {
    static HttpResponse response = new HttpResponse();
    public HttpResponse respond(HttpRequest request){
        System.debug('HTTpEndPoint : '+ request.getEndpoint());
        System.debug('HTTP Method :' + request.getMethod());
        System.debug('HTTP request : ' + request.getBody());
        
        if(request.getBody() != null)
        {
            return getCalloutCorelationId();
        }
        return getNullResponse();
        
    }
    
    private HttpResponse getCalloutCorelationId(){
        response = new HttpResponse();
        response.setstatuscode(202);
        response.setBody('{"correlationId":"1245789"}');
        return response;
    }
    
    private HttpResponse getNullResponse(){
        response = new HttpResponse();
        //response.setstatuscode(202);
        response.setBody('{}');
        return null;
    }
    
}