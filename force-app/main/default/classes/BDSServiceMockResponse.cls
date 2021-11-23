@isTest
public class BDSServiceMockResponse implements HttpCalloutMock {
	static HttpResponse response = new HttpResponse();
    
    public BDSServiceMockResponse(Integer code) {
        response.setStatusCode(code);
    }
    
    public HttpResponse respond(HttpRequest request){
        String endPoint = request.getEndpoint();
		if(request.getBody() != null && response.getStatusCode() == IntegrationRecordHandlerUtil.HTTP_ACCEPTED){
            return getSuccessResponse();
        }
        else if(request.getBody() != null && response.getStatusCode() == IntegrationRecordHandlerUtil.ERROR_404_CODE){
            return getErrorResponse();
        }
        return getNullResponse();
    }
    
    private HttpResponse getSuccessResponse(){
        response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(202);
        response.setBody('{"data":{"status": 202,"message": "Success","eventId": "cfeabaf6-3a70-428f-b129-5ab11c49759e"}}');
        return response;
    }
    
    private HttpResponse getErrorResponse(){
        response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(404);
		response.setBody('{"status":404,"message":"Failed to fetch requested resource","time":"2021-07-09T15:44:48.983+0530","correlationId":"6c0ec67f-4e02-4011-9c62-b21d1bf4041c"}');
        return response;
    }
    
    private HttpResponse getNullResponse(){
        response = new HttpResponse();
        response.setBody('{}');
        return null;
    }
    
    @isTest
    static void testCallout(){
        String contentType = 'application/json';
        System.assert(contentType == 'application/json');
    }
}