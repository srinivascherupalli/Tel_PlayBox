global class MockPPVCalloutResponse implements HttpCalloutMock{
    protected String resType;
    
    global MockPPVCalloutResponse(String resType){
        this.resType = resType;
    }
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        String success_Search ='{"status":202,"code":202,"responseCode":"MPPV-ACCEPTED","correlationId":"58fb5c78-77ed-4f58-97e3-6e0ae3ce498e","timeStamp":"2019-02-27T00:22:19.737Z","path":"/generate-code","method":"POST","data":{"externalId":"abc1234","resourceId":"145sdhju176-wh2327-9474f-f56g5"}}';
        String success_Error = '{"status":422,"code":422,"responseCode":"MPPV-VALIDATION-FAILED","correlationId":"58fb5c78-77ed-4f58-97e3-6e0ae3ce498e","timestamp":"2019-02-27T00:23:58.568Z","path":"/generate-code","method":"POST","errors":[{"fields":"data.portNumber","message":"data.portNumber is in an invalid format.","code":1002},{"fields":"correlationId","message":"correlationId has not been provided.","code":1001}]}';
        String success_Error_503 = '{"code":503,"status":503,"responseCode":"MPPV-CODE-GENERATION-FAILED","timestamp":"2019-02-27T00:14:05.835Z","path":"/generate-code","method":"POST","errors":[{"code":503,"message":"connect ECONNREFUSED 127.0.0.1:8000"}]}';
        String null_Response=Null;
        if(resType.contains('success_Search')){
            res.setBody(success_Search);
            res.setStatusCode(200);
        }
        else if(resType.equalsIgnoreCase('success_Error')){
            res.setBody(success_Error);
            res.setStatusCode(422);
        }
        else if(resType.contains('null_Response')){
            res=Null;
            //res.setStatusCode(422);
        }
        else if(resType.equalsIgnoreCase('success_Error_503')){
            res.setBody(success_Error_503);
            res.setStatusCode(503);
        }
        return res;
    }
    }