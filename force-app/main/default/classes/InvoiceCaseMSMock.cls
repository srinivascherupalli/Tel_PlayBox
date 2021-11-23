/************************************************************ 
* @version      - 0.1
* @createdBy    - Shubhi
* @team         - Colombo
* @jirastoryRef - EDGE-212404
******************************************************************/ 
@isTest
public class InvoiceCaseMSMock implements HttpCalloutMock{
    private Integer status;
    
    public InvoiceCaseMSMock(Integer status){
        this.status = status;
    }
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        String success_Response = '{"code": 202,"status": 202,"message": "OK","errors": []}';
        String exception_Response = '{"code": 500,"status": 500,"message": "Internal Server Error","errors": []}';

        if(status == 200){
            res.setBody(success_Response);
            res.setStatusCode(status);
        }
        else{
            res.setBody(exception_Response);
            res.setStatusCode(status);
        }
        return res;
    }
}