/*----------------------------------------------------------------------------
EDGE        -88306
Class Name  -BillingAccountPaymentsServiceMock
Description -Mock response Class  for Billing account payments API callout.
Author      -Dheeraj Bhatt
-------------------------------------------------------------------------------*/
@IsTest
Global class BillingAccountPaymentsServiceMock implements HttpCalloutMock {
    protected Integer status;
    
    global BillingAccountPaymentsServiceMock(Integer status){
        this.status = status;
    }
    
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        String success_Response='{"code":200,"status":200,"message":"Success","billingAccountNumber":700000335518,"payments":[{"transactionId":198632330,"paymentAmount":15,"paymentDate":"09/07/2019","paymentUnappliedAmount":0},{"transactionId":198632190,"paymentAmount":10,"paymentDate":"09/07/2019","paymentUnappliedAmount":0},{"transactionId":198630533,"paymentAmount":10,"paymentDate":"09/07/2019","paymentUnappliedAmount":0},{"transactionId":197617063,"paymentAmount":1705,"paymentDate":"06/03/2019","paymentUnappliedAmount":0},{"transactionId":197617060,"paymentAmount":1,"paymentDate":"06/03/2019","paymentUnappliedAmount":0},{"transactionId":197617051,"paymentAmount":10,"paymentDate":"06/03/2019","paymentUnappliedAmount":0},{"transactionId":196475020,"paymentAmount":6,"paymentDate":"24/09/2018","paymentUnappliedAmount":0},{"transactionId":196309100,"paymentAmount":1000,"paymentDate":"30/08/2018","paymentUnappliedAmount":0},{"transactionId":196286349,"paymentAmount":2916,"paymentDate":"28/08/2018","paymentUnappliedAmount":0},{"transactionId":196286155,"paymentAmount":1000,"paymentDate":"28/08/2018","paymentUnappliedAmount":0}]}';
        String error_Response='{"code":422,"status":422,"message":"Validation Failed","errors":[{"code":1002,"field":"billingAccountNumber","message":"billingAccountNumber does not exist in the Billing system"}]}';
        string exception_Error='{"code":200,"status":200,"message":"Success","billingAccountNumber":"700000335518","payments":[{"transactionId":198632330,"paymentAmount":15,"paymentDate":"'+system.today()+'","paymentUnappliedAmount":1060.99}]}';
        
        if(status==200){
            res.setBody(success_Response);
            res.setStatusCode(200);
        }
        
        else if(status==422){
            res.setBody(error_Response);
            res.setStatusCode(422);
        }
        else{
            res.setBody(exception_Error);
            res.setStatusCode(404);
        }
        return res;
    }
    
}