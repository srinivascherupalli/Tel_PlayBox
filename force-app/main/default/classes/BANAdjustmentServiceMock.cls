/*************************************************************************************************
EDGE -104930
Name: BANAdjustmentServiceMock
Description: A test mockclass created to validate the API call of Adjustment API
Author:Mahima 
***************************************************************************************************/
@IsTest
Global class BANAdjustmentServiceMock implements HttpCalloutMock {
protected Integer status;
    
    global BANAdjustmentServiceMock(Integer status){
        this.status = status;
    }
    
    /**********************************
    EDGE-104930 
    Description: method to return succes or error mock data
    Author: Mahima
    ************************************/
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        String success_Response='{"code":200,"status":200,"message":"Success","billingAccountNumber":700000335518,"adjustments": [{ "description": "Goodwill Credit", "dateApplied": "14/05/2019", "adjustmentAmount": 135802.7, "amountApplied": 0, "amountUnapplied": 135802.7, "adjustmentId": 198081013 }]}';
        String error_Response='{"code":422,"status":422,"message":"Validation Failed","errors":[{"code":1002,"field":"billingAccountNumber","message":"billingAccountNumber does not exist in the Billing system"}]}';
        if(status==200){
            res.setBody(success_Response);
            res.setStatusCode(200);
        }
        
        else if(status==422){
            res.setBody(error_Response);
            res.setStatusCode(422);
        }
        return res;
    }
}