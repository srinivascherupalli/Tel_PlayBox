/**
* Description : Class for generating mock responses for PPV_Check_API.                   
* Jira        : P2OB - 11853
* Author      : Team Hawaii : Ritika Jaiswal
* Date        : 15-Jan-2020 
**/
global class Mock_PRM_PPV_Response implements HttpCalloutMock{
    protected String resType;
    
    global Mock_PRM_PPV_Response(String resType){
        this.resType = resType;
    }
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        
        //P2OB - 11853:strings of JSON-response as will be returned from PPV_api

       
        //P2OB - 11853: For successful PPV_CreateVerificationRequest: JSON Response string having status and responseCode as per PPV-API
        String success_PPV_Creation ='{"status": 200,"responseCode": "PPV-SUCCESS","time": "2018-11-12T12:33:49.404Z","correlationId": "f1bc3577-8889-48b5-9197-d17a182","data": {"mobileNumber": "0456876999"}}';
        
        //P2OB - 11853: For successful PPV_OTPVerification : JSON Response string having status and responseCode as per PPV-Verfiy-API
        String success_PPV_Verify = '{"status": 200,"responseCode": "PPV-SUCCESS","time": "2018-11-12T12:33:49.404Z","correlationId": "f1bc3577-8889-48b5-9197-d17a182","data": {"mobileNumber": "0456876999","attemptsRemaining": 2}}';
        
        //P2OB - 11853: For failure sceanrio : JSON Response string having status and responseCode as per PPV-API
        String failure = '{"status": 503,"responseCode": "PPV-INTERNAL-SERVER-ERROR","time": "2018-11-19T09:09:02.059Z","correlationId": "31e9763f-b38e-4624-a6fd-7f12a63","errors": [{"message": "Internal error.Please retry","code": "1000"}]}';
        
        //P2OB - 11651 : for token expiration scenario
        String PPV_auth_expire = '{"fault":{"faultstring":"Access Token expired","detail":{"errorcode":"keymanagement.service.access_token_expired"}}}';        
        

        //P2OB - 11853:Creating Response-Body and setting status-code depending on response-type requested
        if(resType.contains('success_PPV_Creation')){
            res.setBody(success_PPV_Creation);
            res.setStatusCode(200);
        }
        else  if(resType.contains('success_PPV_Verify')){
            res.setBody(success_PPV_Verify);
            res.setStatusCode(200);
        }
        else if(resType.contains('PPV_Creation_Fail')){
            res.setBody(failure);
            res.setStatusCode(500);
        }
        else if(resType.contains('notfound_Exception')){
            res.setBody(failure);
            res.setStatusCode(503);

        }else if(resType.contains('PPV_auth_expire')){
            res.setBody(PPV_auth_expire);
            res.setStatusCode(401);

        }
        return res;
    }
}