@isTest
public class Onefundlineitemmock implements HttpCalloutMock {
    protected string status;
    
    public Onefundlineitemmock(string status){
        this.status = status;
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        String success_Response2='{"code": 201,"status":201,"message": "Success"}';
        String error_Response='{"code": 422,"status": 422,"message": "Validation failed","errors": [{"code": 1004,"field":"productId","message":"productId is a mandatory field"}]}';
        String exception_Response='{"code": 500,"status": 500,"message": "Internal Server Error","errors": []}';
        
        if(status== 'success_Response'){
            res.setBody(success_Response2);
            res.setStatusCode(201); 
        }  
        else if(status== 'success_error'){
            res.setBody(error_Response);
            res.setStatusCode(422);
        }
        else if(status== 'success_error'){
            res.setBody(exception_Response);
            res.setStatusCode(500);
        }
        return res;
    }
 
}