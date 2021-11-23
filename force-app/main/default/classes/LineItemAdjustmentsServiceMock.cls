/*----------------------------------------------------------------------------
EDGE        -88306
Class Name  -LineItemAdjustmentsServiceMock
Description -Mock response Class  for LineItemAdjustmentsService API callout.
Author      -Dheeraj Bhatt
-------------------------------------------------------------------------------*/
@IsTest
public class LineItemAdjustmentsServiceMock implements HttpCalloutMock {
    protected Integer status;
    
    public lineItemAdjustmentsServiceMock(Integer status){
        this.status = status;
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        String success_Response='{"code": 201,"status": 201,"message": "Success"}';
        String error_Response='{"code": 422,"status": 422,"message": "Validation failed","errors": [{"code": 1004,"field":"productId","message":"productId is a mandatory field"}]}';
        String exception_Response='{"code": 500,"status": 500,"message": "Internal Server Error","errors": []}';
        
        if(status==200){
            res.setBody(success_Response);
            res.setStatusCode(200);
        }
        else if(status==422){
            res.setBody(error_Response);
            res.setStatusCode(422);
        }
        else if(status==500){
            res.setBody(exception_Response);
            res.setStatusCode(500);
        }
        return res;
    }
}