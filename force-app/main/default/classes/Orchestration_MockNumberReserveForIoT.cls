@isTest
global class Orchestration_MockNumberReserveForIoT implements HttpCalloutMock{
    
    protected String resType;
    
    public Orchestration_MockNumberReserveForIoT(String resType){
        this.resType = resType;
    }
    
    global HTTPResponse respond(HTTPRequest req) {
      	String success_Search='{"status":200,"code":200,"time":"2018-10-31T09:05:05.456+0000","correlationId":"64ad66a9-78da-431a-bd94-a528870c2c02","path":"/v2/logical-resources/reservations/msisdn","method":"POST","responseCode":"LRM-SUCCESS","data":{"requestedQuantity":"5","returnedQuantity":"5","resources":[{"resourceId":"61402022091","resourceType":"MSISDN","resourceState":"AVAILABLE"},{"resourceId":"61402022082","resourceType":"MSISDN","resourceState":"AVAILABLE"},{"resourceId":"61402022093","resourceType":"MSISDN","resourceState":"AVAILABLE"},{"resourceId":"61402022123","resourceType":"MSISDN","resourceState":"AVAILABLE"},{"resourceId":"61402022456","resourceType":"MSISDN","resourceState":"AVAILABLE"}]}}'; 
        String success_Reserve='{"status":200,"responseCode":"LRM-SUCCESS","time":"2018-07-26T05:03:20.299+0000","correlationId":"58fb5c78-77ed-4f58-97e3-6e0ae3ce498e","data":{"resources":[{"resourceId":61429736822,"resourceType":"MSISDN","resourceState":"AVAILABLE"}]}}';
        String success_Unreserve='{"status":204, "code":204}';
        String errorResponse='{"status":404,"responseCode":"LRM-RESOURCE_NOT_FOUND","message":"The Resource cannot be found","time":"2018-07-09T15:44:48.983+0530","correlationId":"6c0ec67f-4e02-4011-9c62-b21d1bf4041c"}';
        //DPG-1802;DPG-1803;DPG-1797: UNMS 
        String success_ReserveUNMS ='{"status":200,"code":200,"time":"2020-03-25T23:30:36.145+0000","correlationId":"68b332ca-2cf6-4897-bda9-70c15c5a7601","data":{"requestedQuantity":2,"returnedQuantity":2,"ageOut":"29","resources":[{"resourceType":"Mobile","resourceState":"Held Order","resourceId":"61411000184","countryCode":"61","countryName":"AU","nationalDestinationCode":"04","subscriberNumber":"11000184","poolName":"UNMS Postpaid","premiumType":"Regular"},{"resourceType":"Mobile","resourceState":"Held Order","resourceId":"61411000185","countryCode":"61","countryName":"AU","nationalDestinationCode":"04","subscriberNumber":"11000185","poolName":"UNMS Postpaid","premiumType":"Regular"}],"ageOutDate":"2020-04-23T23:30:39.000384Z"},"request":{"params":{},"data":{"resourceType":"Mobile","quantity":2,"activityName":"Reserve Next Available"}}}';
        String partial_Success ='{"status":200,"code":200,"time":"2020-03-25T23:30:36.145+0000","correlationId":"68b332ca-2cf6-4897-bda9-70c15c5a7601","responseCode":"UNMSPARTIAL_SUCCESS","data":{"requestedQuantity":2,"returnedQuantity":1,"ageOut":"29","resources":[{"resourceType":"Mobile","resourceState":"Held Order","resourceId":"61411000184","countryCode":"61","countryName":"AU","nationalDestinationCode":"04","subscriberNumber":"11000184","poolName":"UNMS Postpaid","premiumType":"Regular"}],"ageOutDate":"2020-04-23T23:30:39.000384Z"},"request":{"params":{},"data":{"resourceType":"Mobile","quantity":2,"activityName":"Reserve Next Available"}}}';
        String errorResponse_422 ='{"status":422,"code":422,"time":"2020-03-24T07:51:39.300+0000","correlationId":"4abf61ea-ac5d-4442-8845-0229e326e75e","responseCode":"UNMS-INVALID_DATA","message":"The data validation failed. Invalid input: activityNameactivityName=Reserve-Next-Available","data":{},"request":{"params":{},"data":{"activityName":"Reserve-Next-Available","resourceType":"Mobile","nationalDestinationCode":"04","quantity":"2","ageOut":"66"}}}';
        HttpResponse res = new HttpResponse();
        if(resType.contains('Reserve')){
            res.setBody(success_Reserve);
        	res.setStatusCode(200);
        }
        else if(resType.contains('ReserveUNMS'))
        {
            res.setBody(success_ReserveUNMS);
        	res.setStatusCode(200);
        }
        else if(resType.contains('Partial200')){
            res.setBody(partial_Success);
        	res.setStatusCode(200);
        }
        else if(resType.contains('Error422')){
            res.setBody(errorResponse_422);
        	res.setStatusCode(422);
        }
       else if(resType.contains('success_Search')){
            res.setBody(success_Search);
        	res.setStatusCode(409);
        }

        else if(resType.contains('Reserve')){
            res.setBody(success_Reserve);
        	res.setStatusCode(200);
        }

        else if(resType.contains('Unreserve')){
            res.setBody(success_Unreserve);
        	res.setStatusCode(204);
        }

        else if(resType.contains('Error')){
            res.setBody(errorResponse);
        	res.setStatusCode(400);
        }
        return res;
    }
}