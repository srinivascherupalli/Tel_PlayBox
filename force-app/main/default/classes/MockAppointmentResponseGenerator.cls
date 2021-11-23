@isTest
public class MockAppointmentResponseGenerator implements HttpCalloutMock {

    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    public MockAppointmentResponseGenerator(Integer code, String status, String body, Map<String, String> responseHeaders) {
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
        res.setHeader('location','/appointments/telstra/appointments/TAPT223');
        
        if(endPoint.contains('/available-slots') && code == 200 || code == 201) {
        system.debug('test');
            res.setBody(appiontmentResponse());
        } 
        else if(endPoint.contains('/available-slots') && code == 400){
            res.setBody('{"code": "400","message": "No BAN Available","errors": [{"code":"1000","field":"ban","message":"no BAN available"}]}');
        }else if (endPoint.contains('token')) {
          res.setBody('{ "access_token": "tElsAddR32156teSt","expires_in": "2000"}');
       }
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        system.debug('res'+res);
        
        return res;
    }
    
    private string appiontmentResponse(){
     system.debug('test1');
        String json ='{'+
            ' \"data\":'+
            '{'+
                ' \"availableSlots\":['+
                 '{'+
                  ' \"id\": \"123456\",'+
                  ' \"startDate\" : \"2017-09-10T08:00:00.0Z\" ,'+      
                  ' \"endDate\" : \"2017-09-11T10:00:00.0Z\" ,'+       
                  ' \"committedPeriod\" :' +
                   '  { '+
                    '   \"startDate\": \" \" ,'+         
                     '  \"endDate\":\" \" '+     
                    ' }'+
                 '}'+
                 '],'+
                 ' \"taskItems\":['+
                 '{'+
                   ' \"id\" : \"xxxx\",'+
                    ' \"jobItems\" : '+
                    '[{ '+
                        ' \"id\": \"xxxxxx\" ,'+
                        ' \"technology\": \"xx\" ,'+
                        ' \"action\": \"xx\" ,'+
                        ' \"resourceType\": \"xx\" '+
                     '}]'+
                  '}]'+
            '}' +
            '}';
         system.debug('test='+json);
        return json;
        }
		
    static testMethod void test1(){
        Test.startTest();       
        String json ='{'+
            ' \"data\":'+
            '{'+
            ' \"availableSlots\":['+
            '{'+
            ' \"id\": \"SLOT-ID\",'+
            ' \"startDate\" : \" \" ,'+      
            ' \"endDate\" : \" \" ,'+       
            ' \"committedPeriod\" :' +
            '  { '+
            '   \"startDate\": \" \" ,'+         
            '  \"endDate\":\" \" '+     
            ' }'+
            '}'+
            '],'+
            ' \"taskItems\":['+
            '{'+
            ' \"id\" : \"xxxx\",'+
            ' \"jobItems\" : '+
            '[{ '+
            ' \"id\": \"xxxxxx\" ,'+
            ' \"technology\": \"xx\" ,'+
            ' \"action\": \"xx\" ,'+
            ' \"resourceType\": \"xx\" '+
            '}]'+
            '}],'+
            ' \"estimatedDuration\":\"xxx\",'+
            ' \"obligatoryCompletionDate\": \"XX\" '+
            '}' +
            '}';
        System.assert(json != null);
        Test.stopTest();
    }
}