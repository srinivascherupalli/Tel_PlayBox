/************************************************************ 
* @version      - 0.1
* @createdBy    - Ramesh Somalagari
* @team         - OSAKA
* @jirastoryRef - EDGE-111167
******************************************************************/ 
@isTest
public class QLIAdjustmentHandlerMock implements HttpCalloutMock{
    private Integer status;
    
    public QLIAdjustmentHandlerMock(Integer status){
        this.status = status;
    }
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        String success_Response = '{"creditAdjustmentEligibility": [{"chargeIdentifier": 654321,"invoiceLineNumber": 112233,"maxCreditAmount": 1000}]}';
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