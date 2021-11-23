/*************************************************************************************************
Name : MockNumberReservationFixed
Description : Mock class for Fixed Number Reservation
Author: Ila
Story: EDGE-59987
***************************************************************************************************/
global class MockNumberReservationFixed implements HttpCalloutMock{
    protected String resType;
    
    global MockNumberReservationFixed(String resType){
        this.resType = resType;
    }
    
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        String success_fixed='{"status":200,"code":200,"time":"2019-09-13T06:52:36.542+0000","correlationId":"53425d83-1d66-4bfe-80af-a3e4e5665750","path":"/v1/logical-resources/dialable-numbers","method":"PATCH","responseCode":"UNMS-SUCCESS","data":{"resources":[{"resourceId":"61359816905","countryCode":"61","countryName":"AU","nationalDestinationCode":"3","providedToKey":"2d1bfa7b-790b-4dcf-becf-5cd0e36c525d","activityStatus":"SUCCESS","resourceState":"Held Order","ageOut":"180","ageOutDate":"2020-03-11T06:52:36.000372Z"}]},"request":{"params":{},"method":"PATCH","path":"/v1/logical-resources/dialable-numbers","data":{"resourceState":"Held Order","resources":[{"resourceId":"61359816905"}]}}}';
        String errorResponse='{"status":409,"code":409,"time":"2019-09-13T06:57:22.263+0000","correlationId":"08865a82-594a-4568-bbbf-cb913025b7ad","path":"/v1/logical-resources/dialable-numbers","method":"PATCH","responseCode":"UNMS-INVALID_ACTION","message":"The requested activity cannot be performed on the resource because it does not support a status change from Pending Port Out to Held Order","data":{},"errors":[{"resourceId":"61386479994","system":"UNMS","code":"UNMS-INVALID_ACTION","message":"The requested activity cannot be performed on the resource because it does not support a status change from Pending Port Out to Held Order"}],"request":{"params":{},"method":"PATCH","path":"/v1/logical-resources/dialable-numbers","data":{"resourceState":"Held Order","resources":[{"resourceId":"61386479994"}]}}}';
        String partialSuccess='{"status":200,"code":200,"responseCode":" UNMS-PARTIAL_SUCCESS","message":"Partial success. Data block must be referred for successful numbers and error block must be referred for failed numbers","time":"2018-11-27T04:49:47.144+0000","correlationId":"999acbac-df02-4bcd-8e58-5589a4406418","path":"v1/logical-resources/dialable-numbers","method":"PATCH","data":{"resources":[{"resourceId":"61212345678","countryCode":"61","countryName":"AU","nationalDestinationCode":"02","subscriberNumber":"12345678","providedToKey":"c3d1185c-61dc-4180-bd78-c8bf9e225be4","activityStatus":"SUCCESS","resourceState":"Pending Connect"}]},"errors":[{"resourceId":"61212345679","system":"SNRM","code":"404","message":"The FNN does not exist on the system"}]}';
        String partialSuccessRange='{"status":200,"code":200,"responseCode":" UNMS-PARTIAL_SUCCESS","message":"Partial success. Data block must be referred for successful numbers and error block must be referred for failed numbers","time":"2018-11-27T04:49:47.144+0000","correlationId":"999acbac-df02-4bcd-8e58-5589a4406418","path":"v1/logical-resources/dialable-numbers","method":"PATCH","data":{"resources":[{"resourceId":"61212345678","countryCode":"61","countryName":"AU","nationalDestinationCode":"02","subscriberNumber":"12345678","providedToKey":"c3d1185c-61dc-4180-bd78-c8bf9e225be4","activityStatus":"SUCCESS","resourceState":"Pending Connect"},{"startRange":"61339185736","endRange":"61339185737","countryCode":"61","countryName":"AU","nationalDestinationCode":"03","providedToKey":"c3d1185c-61dc-4180-bd78-c8bf9e225be5","activityStatus":"SUCCESS","resourceState":"Pending Connect"}]},"errors":[{"resourceId":"61212345679","system":"SNRM","code":"404","message":"The FNN does not exist on the system"},{"startRange":"61339185112","endRange":"61339185113","resourceId":"61339185112","system":"UNMS","code":"UNMS-INVALID_ACTION","message":"The requested activity cannot be performed on the resource because it does not support a status change from Quarantine to Pending Connect."}],"request":{"params":{},"method":"PATCH","path":"v1/logical-resources/dialable-numbers","data":{"resourceState":"Pending Connect","resources":[{"resourceId":"61212345678"},{"resourceId":"61212345679"},{"startRange":"61339185736","endRange":"61339185737"},{"startRange":"61339185112","endRange":"61339185113"}]}},"header":{"correlationId":"999acbac-df02-4bcd-8e58-5589a4406418"}}';
		String rangeFailure='{"status":409,"code":409,"time":"2019-09-13T07:03:13.433+0000","correlationId":"02f1e485-9204-43ac-af7c-c3dce050edf7","path":"/v1/logical-resources/dialable-numbers","method":"PATCH","responseCode":"UNMS-INVALID_ACTION","message":"The requested activity cannot be performed on the resource because it does not support a status change from Pending Port Out to Held Order","data":{},"errors":[{"resourceId":"61386479913","startRange":"61386479913","endRange":"61386479914","system":"UNMS","code":"UNMS-INVALID_ACTION","message":"The requested activity cannot be performed on the resource because it does not support a status change from Pending Port Out to Held Order"},{"resourceId":"61386479914","startRange":"61386479913","endRange":"61386479914","system":"UNMS","code":"UNMS-INVALID_ACTION","message":"The requested activity cannot be performed on the resource because it does not support a status change from Pending Port Out to Held Order"}],"request":{"params":{},"method":"PATCH","path":"/v1/logical-resources/dialable-numbers","data":{"resourceState":"Held Order","resources":[{"startRange":"61386479913","endRange":"61386479914"}]}}}';
        String rangeSuccess = '{"status":200,"code":200,"time":"2019-09-13T07:01:15.159+0000","correlationId":"23394f43-3257-478a-a6e4-6ba8a007890a","path":"/v1/logical-resources/dialable-numbers","method":"PATCH","responseCode":"UNMS-SUCCESS","data":{"resources":[{"countryCode":"61","countryName":"AU","nationalDestinationCode":"2","providedToKey":"70843ac2-f2fc-4219-a693-70a8a3c24d3e","startRange":"61298660348","endRange":"61298660349","activityStatus":"SUCCESS","resourceState":"Held Order","ageOut":"180","ageOutDate":"2020-03-11T07:01:14.000930Z"}]},"request":{"params":{},"method":"PATCH","path":"/v1/logical-resources/dialable-numbers","data":{"resourceState":"Held Order","resources":[{"startRange":"61298660348","endRange":"61298660349"}]}}}';
        String rangePartial ='{"status":200,"code":200,"responseCode":" UNMS-PARTIAL_SUCCESS","message":"Partial success. Data block must be referred for successful numbers and error block must be referred for failed numbers","time":"2018-11-27T04:49:47.144+0000","correlationId":"999acbac-df02-4bcd-8e58-5589a4406418","path":"v1/logical-resources/dialable-numbers","method":"PATCH","data":{"resources":[{"startRange":"61339185736","endRange":"61339185737","countryCode":"61","countryName":"AU","nationalDestinationCode":"03","providedToKey":"c3d1185c-61dc-4180-bd78-c8bf9e225be5","activityStatus":"SUCCESS","resourceState":"Pending Connect"}]},"errors":[{"startRange":"61339185736","endRange":"61339185737","resourceId":"61339185735","system":"UNMS","code":"UNMS-INVALID_ACTION","message":"The requested activity cannot be performed on the resource because it does not support a status change from Quarantine to Pending Connect."}],"request":{"params":{},"method":"PATCH","path":"v1/logical-resources/dialable-numbers","data":{"resourceState":"Pending Connect","resources":[{"startRange":"61339185736","endRange":"61339185737"}]}},"header":{"correlationId":"999acbac-df02-4bcd-8e58-5589a4406418"}}';
        String search_nonCon='{"status":200,"code":200,"time":"2019-09-13T06:52:36.542+0000","correlationId":"53425d83-1d66-4bfe-80af-a3e4e5665750","path":"/v1/logical-resources/dialable-numbers","method":"POST","responseCode":"UNMS-SUCCESS","data":{"requestedQuantity":"5","returnedQuantity":"2","resources":[{"resourceId":"61359816905","countryCode":"61","countryName":"AU","nationalDestinationCode":"3","providedToKey":"2d1bfa7b-790b-4dcf-becf-5cd0e36c525d","activityStatus":"SUCCESS","resourceState":"Held Order","ageOut":"180","ageOutDate":"2020-03-11T06:52:36.000372Z"}]}}';
        if(resType.contains('success_fixed')){
            res.setBody(success_fixed);
            res.setStatusCode(200);
        }
        else if(resType.contains('partialSuccessRange')){
            res.setBody(partialSuccessRange);
            res.setStatusCode(200);
        }
        else if(resType.contains('rangeSuccess')){
            res.setBody(RangeSuccess);
            res.setStatusCode(200);
        }
        else if(resType.contains('rangeFailure')){
            res.setBody(rangeFailure);
            res.setStatusCode(409);
        } 
        else if(resType.contains('errorResponse')){
            res.setBody(errorResponse);
            res.setStatusCode(409);
        }
        else if(resType.contains('rangePartial')){
             res.setBody(rangePartial);
            res.setStatusCode(200);
        }
        else if(resType.contains('partialSuccess')){
            res.setBody(partialSuccess);
            res.setStatusCode(200);
        }
         else if(resType.contains('search_nonCon')){
            res.setBody(search_nonCon);
            res.setStatusCode(200);
        }
        
        
        return res;
    }
    
}