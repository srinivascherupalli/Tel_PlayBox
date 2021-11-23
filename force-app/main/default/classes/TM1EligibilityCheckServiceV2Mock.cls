/*
* @Author : Robin/Ritika
* @Date : 5 June 2019
* @Desc : Class for generating MockResponses for TM1EligibilityCheckServiceV2Test
* @Jira Cloud : EDGE-85155
*/

global  class TM1EligibilityCheckServiceV2Mock implements HttpCalloutMock {
    protected String resType;
    
    global TM1EligibilityCheckServiceV2Mock(String resType){
        this.resType = resType;
    }
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        //String success_Search = '{"code":200,"status":200,"time":"2019-03-05T13:12:45+10:00","data":{"addressId":"161152457","additionalTrafficClassAvailability":[{"name":"High Speed TC2 (greater or equal to 20Mbps)","value":"No"},{"name":"TC2","value":"No"},{"name":"NCAS TC2 5Mbps Capacity","value":"No"},{"name":"NCAS TC2 10Mbps Capacity","value":"No"},{"name":"NCAS TC2 20Mbps Capacity","value":"No"},{"name":"NCAS TC2 30Mbps Capacity","value":"No"},{"name":"NCAS TC2 40Mbps Capacity","value":"No"},{"name":"NCAS TC4 High Speed Tiers (greater or equal to 250Mbps)","value":"No"},{"name":"NCAS TC1 High Speed Tiers (greater or equal to 0.3Mbps)","value":"No"},{"name":"NCAS TC1 High Speed Tiers (greater or equal to 2Mbps)","value":"No"},{"name":"Multicast","value":"No"}],"serviceTypeQualifications":[{"serviceabilityClass":"12","demandType":"Standard Install","technologyType":"Fibre","csaId":"CSA200000000199","serviceTransferIndicator":"N","serviceType":"Internet","locationId":"LOC160829045445","status":"Available","providerResources":[{"resourceType":"Copper Pair","id":"New Path","status":"","sicIndicator":"Y","sicCode":"SIC_NEW_PATH_SELECTED_INFLIGHT_INPLACE","sicReason":"SIC is applicable due to In flight order in place","serviceabilityClass":"12"}],"statusReason":"NBN Internet is serviceable at this address","characteristics":[{"name":"TC4 Downstream Upper Rate","value":"25 Mbps"},{"name":"TC4 Downstream Lower Rate","value":""},{"name":"TC4 Upstream Upper Rate","value":"5 Mbps"},{"name":"TC4 Upstream Lower Rate","value":""}],"readyForServiceDate":"2011-10-09","appointmentRequired":"Yes","copperPairIndicator":"Y"}],"messages":[{"code":"SQNTT002","message":"The dates cannot be retrieved due to downstream errors"}],"scheduledDates":{"ceaseSaleDate":"","orderStabilityPeriodDate":""}},"request":{"params":{"addressId":"161152457","serviceFilter":"Internet"},"data":{},"path":"/service-addresses","method":"GET","requestId":"cec27ea8-d1f4-4f05-89ac-d11ddaa67774","correlationId":"00d3e37a-82e2-454f-9b66-a8104945973b"},"correlationId":"00d3e37a-82e2-454f-9b66-a8104945973b"}';
        String success_acknowledgement ='{ "_links": [ { "rel": "self", "href": "https://localhost:8080/transition-dm/api/v1/transition/f8df162d-60c3-4074-b622-0d5c997c8708" } ], "transitionId": "f8df162d-60c3-4074-b622-0d5c997c8708", "transitions": [ { "type": "service", "properties": { "identifier": "0438034768", "family": "mobile", "attributes": [ { "key": "customerId", "value": "12345" } ] }, "target": { "type": "port-out" } } ], "states": [ { "state": "created", "timestamp": "2019-05-03T04:56:57.690Z" } ], "resource": { "_links": [ { "rel": "self", "href": "https://localhost:8080/transition-dm/api/v1/transition/f8df162d-60c3-4074-b622-0d5c997c8708/resource" } ], "data": [ { "_links": [ { "rel": "self", "href": "https://localhost:8080/transition-dm/api/v1/resource/ad38c6b2-1211-4ef3-975b-966f25642b14" } ], "resourceId": "ad38c6b2-1211-4ef3-975b-966f25642b14", "type": "service", "identifier": "0438034768", "family": "mobile", "status": "unknown", "state": "created", "validation": { "status": "unknown" }, "attributes": [ { "key": "customerId", "value": "12345" } ] } ] }, "metadata": { "createdAt": "2019-05-03T04:56:57.690Z", "updatedAt": "2019-05-03T04:56:57.690Z" } }';
     	String error_ack='{"error":{"code":"TM4009","message":"string","details":"string","timestamp":"2021-03-18T11:27:57.701Z"}}';
        if(resType.contains('success_acknowledgement')){
            res.setBody(success_acknowledgement);
            res.setStatusCode(201);
        }
        else  if(resType.contains('error_ack')){
            res.setBody(error_ack);
            res.setStatusCode(400);
        }
        
        return res;
    }
}