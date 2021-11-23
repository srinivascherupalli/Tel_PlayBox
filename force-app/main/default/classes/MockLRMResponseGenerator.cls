@isTest
public class MockLRMResponseGenerator implements HttpCalloutMock{
    
    public Integer code;
    public String status;
    public String body;    

    public MockLRMResponseGenerator(Integer code, String status, String body) {
        this.code = code;
        this.status = status;
        this.body = body;
    }
    
    public HTTPResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
         res.setHeader('Content-Type', 'application/json');
        if(code == 200 && status =='Success'){
            res.setBody('{"status":200,"code":200,"time":"2020-08-14T11:18:56.670+0000","correlationId":"80658d1e-5102-496f-980f-b23f4e040b2f","path":"/v2/logical-resources/sim/resources/fetch","method":"POST","responseCode":"LRM-SUCCESS","requestId":"9b0f7605-3744-4f38-a303-1bc1aab5628c","data":{"resources":[{"resourceId":"89610182000501374304","resourceType":"ICCID","resourceState":"AVAILABLE","characteristics":[{"name":"SIM Type","value":"3GUniversal"},{"name":"SIM Category","value":"3G Standard SIM"},{"name":"Order ID","value":"0300898383"}]},{"resourceId":"89610182000501374402","resourceType":"ICCID","resourceState":"AVAILABLE","characteristics":[{"name":"SIM Type","value":"3GUniversal"},{"name":"SIM Category","value":"3G Standard SIM"},{"name":"Order ID","value":"0300898389"}]}]}}');
        }else if(code == 200 && status =='Partial Success')
        {
            res.setBody('{ "status": 200, "code": 200, "time": "2020-08-14T11:18:56.670+0000", "correlationId": "80658d1e-5102-496f-980f-b23f4e040b2f", "path": "/v2/logical-resources/sim/resources/fetch", "method": "POST", "responseCode": "LRM-PARTIAL-SUCCESS", "message": "Requested SIM[s] details partially found. Please refer to errors for further assistance", "requestId": "9b0f7605-3744-4f38-a303-1bc1aab5628c", "errors": [ { "simNumber": "89610182000501374392", "message": "SIM details not found", "code": "LRM-RESOURCE_NOT_FOUND" }, { "simNumber": "82000501374402", "message": "Invalid SIM number", "code": "LRM-LRM-INVALID_DATA" }, { "simNumber": "82000501374403", "message": "LRM ERROR", "code": "LRM-ERROR" } ], "data": { "resources": [ { "resourceId": "89610182000501374304", "resourceType": "ICCID", "resourceState": "AVAILABLE", "characteristics": [ { "name": "SIM Type", "value": "3GUniversal" }, { "name": "SIM Category", "value": "3G Standard SIM" }, { "name": "Order ID", "value": "0300898383" } ] }, { "resourceId": "89610182000501374305", "resourceType": "ICCID", "resourceState": "Active", "characteristics": [ { "name": "SIM Type", "value": "3GUniversal" }, { "name": "SIM Category", "value": "3G Standard SIM" }, { "name": "Order ID", "value": "0300898383" } ] } ] } }');        }else if(code == 422)
        {
            res.setBody('{"status":422,"code":422,"time":"2020-08-14T11:18:56.670+0000","correlationId":"80658d1e-5102-496f-980f-b23f4e040b2f","path":"/v2/logical-resources/sim/resources/fetch","method":"POST","responseCode":"LRM-INVALID_DATA","requestId":"9b0f7605-3744-4f38-a303-1bc1aab5628c","message":"Invalid request. simSerialNumbers cannot be null/empty"}');
        }else if(code == 404)
        {
            res.setBody('{"status":404,"code":404,"time":"2020-08-14T11:18:56.670+0000","correlationId":"80658d1e-5102-496f-980f-b23f4e040b2f","path":"/v2/logical-resources/sim/resources/fetch","method":"POST","responseCode":"LRM-RESOURCE_NOT_FOUND","requestId":"9b0f7605-3744-4f38-a303-1bc1aab5628c","message":"Requested SIM[s] details not found from LRM"}');
        }
        else if(code == 503)
        {
            res.setBody('{"status":503,"code":503,"time":"2020-08-14T11:18:56.670+0000","correlationId":"80658d1e-5102-496f-980f-b23f4e040b2f","path":"/v2/logical-resources/sim/resources/fetch","method":"POST","responseCode":"LRM-RESOURCE_NOT_FOUND","requestId":"9b0f7605-3744-4f38-a303-1bc1aab5628c","message":"Requested SIM[s] details not found from LRM"}');
        }else if(code == 400)
        {
            res.setBody('{"status":400,"code":400,"time":"2020-08-14T11:18:56.670+0000","correlationId":"80658d1e-5102-496f-980f-b23f4e040b2f","path":"/v2/logical-resources/sim/resources/fetch","method":"POST","responseCode":"LRM-RESOURCE_NOT_FOUND","requestId":"9b0f7605-3744-4f38-a303-1bc1aab5628c","message":"Requested SIM[s] details not found from LRM"}');
        }else if(code == 502)
        {
            res.setBody('{"status":502,"code":502,"time":"2020-08-14T11:18:56.670+0000","correlationId":"80658d1e-5102-496f-980f-b23f4e040b2f","path":"/v2/logical-resources/sim/resources/fetch","method":"POST","responseCode":"LRM-RESOURCE_NOT_FOUND","requestId":"9b0f7605-3744-4f38-a303-1bc1aab5628c","message":"Requested SIM[s] details not found from LRM"}');
        }
        else if(code == 401)
        {
            res.setBody('{"status":401,"code":401,"time":"2020-08-14T11:18:56.670+0000","correlationId":"80658d1e-5102-496f-980f-b23f4e040b2f","path":"/v2/logical-resources/sim/resources/fetch","method":"POST","responseCode":"LRM-RESOURCE_NOT_FOUND","requestId":"9b0f7605-3744-4f38-a303-1bc1aab5628c","message":"Requested SIM[s] details not found from LRM"}');
        }else{
            res.setBody('{"status":500,"code":500,"time":"2020-08-14T11:18:56.670+0000","correlationId":"80658d1e-5102-496f-980f-b23f4e040b2f","path":"/v2/logical-resources/sim/resources/fetch","method":"POST","responseCode":"LRM-INTERNAL_SERVER_ERROR","requestId":"9b0f7605-3744-4f38-a303-1bc1aab5628c","message":"Internal server error"}');
        }
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;
    }

}