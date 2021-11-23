/***********************************************************************************************************
Name          : SCSQCheckCalloutMock
Created By    : Mahaboob Basha
Created Date  : July 03 2019
Description   : This is a Mock class to simulate the callouts of SQ Check in SCAddressSearchController
-------
History                                                            
-------                                                            
VERSION     AUTHOR          DATE            DETAIL                   
-------     ------          -----           ---------                 
1.1         Mahaboob        03-07-2019      Created
1.1         Mahaboob        03-07-2019      Added methods respond, getCalloutResponse, getDefaultResponse
1.2         Pawan           27-09-2019      Added constructor SCSQCheckCalloutMock(for testing changes of EDGE-111452)
**********************************************************************************************************/
@isTest(SeeAllData=FALSE)
global class SCSQCheckCalloutMock implements HttpCalloutMock {
 
        protected Integer r_code;
        protected String r_status;
        protected String r_bodyAsString;
        protected Blob r_bodyAsBlob;
        protected Map<String, String> r_responseHeaders;
        
        public SCSQCheckCalloutMock (){
        }

        public SCSQCheckCalloutMock (Integer code, String status, String body,
                                         Map<String, String> responseHeaders) {
            this.r_code = code;
            this.r_status = status;
            this.r_bodyAsString = body;
            this.r_bodyAsBlob = null;
            this.r_responseHeaders = responseHeaders;
        }
 
 
    global HTTPResponse respond(HTTPRequest req) {
        System.debug('HTTP Endpoint: '+ req.getEndpoint());
        System.debug('HTTP Method: '+ req.getMethod());
        System.debug('HTTP Request: '+ req.getBody());
        if(req.getEndpoint().contains('publish/publication?')){
            return getCalloutResponse();
        }
        else if(r_code == IntegrationRecordHandlerUtil.ERROR_500_CODE || r_code == IntegrationRecordHandlerUtil.ERROR_404_CODE || r_code == IntegrationRecordHandlerUtil.ERROR_503_CODE){
        return getDefaultResponse(r_code);
        }
        
        return getDefaultResponse(200);
    }

    private HttpResponse getCalloutResponse(){
        HttpResponse res = getDefaultResponse(202);
        res.setBody('{"response": [{"publicationInstructionId": 123},{"publicationInstructionId": 456}]}');
        return res;
    }
    
    private HttpResponse getDefaultResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        String mockBody = '{"code":200,"status":200,"time":"2019-07-03T23:42:56+10:00","data":{"messages":[{"code":"SQNTT002","message":"The dates cannot be retrieved due to downstream errors"}],"addressId":"200094163","serviceTypeQualifications":[{"serviceabilityClass":"10","technologyType":"Fibre To The Building","networkCoexistence":"","csaId":"CSA200000000384","serviceType":"Internet","locationId":"LOC150520190132","status":"Unavailable","providerResources":[],"statusReason":"NBN is not serviceable at this address","characteristics":[{"name":"Downstream","value":"40"}],"copperPairIndicator":"No","readyForServiceDate":"2011-10-09"}],"scheduledDates":{"ceaseSaleDate":"","orderStabilityPeriodDate":""}},"request":{"params":{"addressId":"200094163","serviceFilter":"Internet"},"data":{},"path":"/service-addresses","method":"GET","requestId":"2eb7ee79-ca33-4bde-908d-1a1bb8831ea3","correlationId":"977a35d5-9fc4-4b0a-0fc2-4560b2205277"},"correlationId":"67391111-bf22-4e4c-c7d0-e960fc1393bb"}';        res.setBody(mockBody);
        res.setStatusCode(StatusCode);
        res.setHeader('Content-Type', 'application/json');
        return res;
    }

}