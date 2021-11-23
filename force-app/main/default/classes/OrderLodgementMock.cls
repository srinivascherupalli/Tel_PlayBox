/*
===============================================================================================================================
Class : OrderLodgementMock
Developer Name : Dheeraj Bhatt
Test Class : OrderLodgementTest
===============================================================================================================================
Sr.No.    Developer Name        Date          Story Description
1.        Dheeraj Bhatt         06 Aept 2021   DIGI-1939 - Enable an API call to the MS to initiate digi plan configuration
===============================================================================================================================*/
global class OrderLodgementMock implements HttpCalloutMock {
    protected String resType;
    
    global OrderLodgementMock(String resType){
        this.resType = resType;
    }
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        
        String success_Response ='{"ds-correlation-id":"5a42a9fe-dc29-45e2-a895-553a9d24c08c","basketId":"a3Q2N0000005dPSUAY","solutionName":"Adaptive Mobility","status":"SUCCESS","statusMessage":"Auto-configuration in progress"}';
        string failure_Response='{"errorCode":401,"message":"The access token provided is invalid"}';
        if(resType.contains('success_acknowledgement')){
            res.setBody(success_Response);
            res.setStatusCode(200);
        }
        else if(resType.contains('failure_acknowledgement')){
            res.setBody(failure_Response);
            res.setStatusCode(401);  
        }
        return res;
    }
    
}