@isTest
public class IntegrationRecordHandlerUtilCalloutMock implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest req) {
        System.debug('HTTP Endpoint: '+ req.getEndpoint());
        System.debug('HTTP Method: '+ req.getMethod());
        System.debug('HTTP Request: '+ req.getBody());
        if(req.getEndpoint().contains('publish/publication?')){
            return getCalloutResponse();
        }
    
     if(req.getEndpoint().contains('servicequalification/service')){
            return getDefaultResponse(200);
        }

     if(req.getEndpoint().contains('recaptcha/api')){
            return getCalloutResponseCaptcha();
        }
        
        /** Code modified - Padmesh Soni (19 feb 2020) - DPA-55 - Start */
        if(req.getEndpoint().contains('/notification-mgmt/events')){
            return getNotifyCalloutResponse();
        }
        /** Code modified - Padmesh Soni (19 feb 2020) - DPA-55 - End */
        
        return getDefaultResponse(200);
    }
    //method added to resolve a bug (given class is test class so it should have test method)
    @isTest static void testIntegrationRecordHandler(){
        Test.startTest();
        System.assert(1 == 1);
        Test.stopTest();
    }
    private HttpResponse getCalloutResponse(){
        HttpResponse res = getDefaultResponse(202);
        res.setBody('{"response": [{"publicationInstructionId": 123},{"publicationInstructionId": 456}]}');
        return res;
    }

    private HttpResponse getCalloutResponseCaptcha(){
        HttpResponse res = getDefaultResponse(202);
        res.setBody('{"success": true,"challenge_ts": "2019-08-21T05:59:10Z","hostname": "copadoorl2-telstra.cs116.force.com"}');
        return res;
    }
      private HttpResponse getCalloutResponseManageOrg(){
        HttpResponse res = getDefaultResponse(200);
        res.setBody('{"title":"Success","status":200,"description":"Org created : Key: 5182 Name: Partner Source Account. Parent: TEG. ParentKey: 1222","pimsStatus":0,"orgId":"5182"}');
        return res;
    }
    
    /** Code modified - Padmesh Soni (19 feb 2020) - DPA-55 - Start 
     * Change: Set mock response for notify integration for live chat
    */
    private HttpResponse getNotifyCalloutResponse(){
        HttpResponse res = getDefaultResponse(202);
        res.setBody('{"code":202,"applicationLabel":"Phoenix Support Prod OKAPI2","time":"2020-01-08T06:28:14.425+0000","correlationId":"2701ea22-ecf0-476d-8de2-cec35acec329","data":{"eventId":"2701ea22-ecf0-476d-8de2-cec35acec329"},"status":202,"message":null,"errors":null,"path":"/v1/notification/gateway","method":"POST"}');
        return res;
    }
    /** Code modified - Padmesh Soni (19 feb 2020) - DPA-55 - End */
    
    private HttpResponse getDefaultResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(StatusCode);
        res.setHeader('Content-Type', 'application/json');
        return res;
    }

}