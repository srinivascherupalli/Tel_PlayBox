@isTest
public class Orchestration_UpdateMSISDNMock implements HttpCalloutMock {
    static HttpResponse response = new HttpResponse();

    public Orchestration_UpdateMSISDNMock(Integer code) {
        response.setStatusCode(code);
    }

    public HttpResponse respond(HttpRequest request) {
        String endPoint = request.getEndpoint();
        System.debug('httpEndPoint:: ' + endPoint + ',httpMethod::' + request.getMethod() + ',httpRequest::' + request.getBody());
        if (request.getBody() != null && response.getStatusCode() == IntegrationRecordHandlerUtil.HTTP_ACCEPTED) {
            return getSuccessResponse();
        } else if (request.getBody() != null && response.getStatusCode() == IntegrationRecordHandlerUtil.ERROR_404_CODE) {
            return getErrorResponse();
        }
        return null;
    }

    private HttpResponse getSuccessResponse() {
        response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(202);
        response.setBody(
            '{"data":{"result":[{"fnn":"0282345560","status":"SUCCESS"}],"resources":[{"resourceId":"0732722177","resourceType":"FNN","resourceState":"HELD PRESENTATION","poolId":25,"characteristics":[{"name":"ESA","value":"APPX"},{"name":"Potential Line Type","value":"SS"}],"category":[{"type":"FNN_Type","value":"Regular"}]}]},"status":200,"responseCode":"LRM-SUCCESS","time":"2018-07-26T05:03:20.299+0000","correlationId":"58fb5c78-77ed-4f58-97e3-6e0ae3ce498e","path":"/networks/v2/logical-resources/locks?attributes=all","request":{"data":{"geoParam":"ESA","geoParamValues":"BULA","type":"REGULAR","quantity":1,"pattern":"*2","searchType":"RANDOM","systemId":"MSPA","serviceIds":["9922145874","9822154789"],"fnns":["9922145874","9822154789"]}}}'
        );
        return response;
    }

    private HttpResponse getErrorResponse() {
        response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(404);
        response.setBody('{"status":404,"responseCode":"LRM-RESOURCE_NOT_FOUND","message":"Failed to fetch requested resource","time":"2018-07-09T15:44:48.983+0530","correlationId":"6c0ec67f-4e02-4011-9c62-b21d1bf4041c"}');
        return response;
    }
}