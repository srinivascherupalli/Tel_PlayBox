/*Author: Ila
Company: Tesltra 
User Story :EDGE-80745
Description: Mock response for Mobile/MSISDN SQ Check Lightning UI controller.
*/

global class MockSQCheckMSISDNCtrl implements HttpCalloutMock{

     protected String resType;
    public MockSQCheckMSISDNCtrl(String resType){
        this.resType = resType;
    }
    //Method to mock response conditionally
    global HTTPResponse respond(HTTPRequest req) {
        String msisdn_success = '{"status":200,"data":{"numberDetails":[{"mobileNumber":"12345","mobileNumberPortabilityIndicator":"Y","reason":"The MSISDN can be Ported within Telstra network","code":"PORT_SUCCESS"}]}}';
        String msisdn_failure = '{"status":401,"data":{},"errors":{"errorDetails":[{"message":"Invalid token, authenticaton failed","code":"AUTHENTICATION_FAILED"}]}}';
        String msisdn_Error429 = '{"status":429,"errors":[{"code":429,"message":"Concurrency limit exceeded, unable to process the request. Try later"}],"code":429,"time":"2018-10-08T17:42:55+11:00","correlationId":"5fb7eb1c-b97b-4009-9a2e-b51d944737f1","message":"Concurrency limit exceeded, unable to process the request. Try later"}';
        String success_multiple='{"status":200,"data":{"numberDetails":[{"mobileNumber":"6142459872","mobileNumberPortabilityIndicator":"Y","reason":"The MSISDN can be Ported within Telstra network","code":"PORT_SUCCESS"},{"mobileNumber":"61424598721","mobileNumberPortabilityIndicator":"Y","reason":"The MSISDN can be Ported within Telstra network","code":"PORT_SUCCESS"},{"mobileNumber":"msisdn4","mobileNumberPortabilityIndicator":"Y","reason":"The MSISDN can be Ported within Telstra network","code":"PORT_SUCCESS"}]}}';
        String failure_multiple='{"status":404,"data":{},"errors":{"errorDetails":[{"message":"The Mobile Number cannot be found","code":"RESOURCE_NOT_FOUND"}]}}';
        HttpResponse res = new HttpResponse();
        if(resType.contains('Success')){
            res.setBody(msisdn_success);
            res.setStatusCode(200);
        }else if(resType.contains('Failure')){
            res.setBody(msisdn_failure);
            res.setStatusCode(401);
        }
        else if(resType.contains('Error429')){
            res.setBody(msisdn_Error429);
            res.setStatusCode(429);
        }
         else if(resType.contains('success_multiple')){
            res.setBody(success_multiple);
            res.setStatusCode(200);
        }
         else if(resType.contains('failure_multiple')){
            res.setBody(failure_multiple);
            res.setStatusCode(404);
        }
        return res;
    }

}