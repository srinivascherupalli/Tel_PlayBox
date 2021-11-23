/*
* @Author : Aniket
* @Date : 17 July 2019
* @Desc : Class for generating MockResponses for AttachmentTriggerHelpertest class
* @Jira Cloud : EDGE-94797
* @Modified: EDGE-215821 :Aishwarya
*/

global  class TramasCallbackResponseUpdateMock implements HttpCalloutMock {
    protected String resType;
    
    global TramasCallbackResponseUpdateMock(String resType){
        this.resType = resType;
    }
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        //String success_Search = '{"code":200,"status":200,"time":"2019-03-05T13:12:45+10:00","data":{"addressId":"161152457","additionalTrafficClassAvailability":[{"name":"High Speed TC2 (greater or equal to 20Mbps)","value":"No"},{"name":"TC2","value":"No"},{"name":"NCAS TC2 5Mbps Capacity","value":"No"},{"name":"NCAS TC2 10Mbps Capacity","value":"No"},{"name":"NCAS TC2 20Mbps Capacity","value":"No"},{"name":"NCAS TC2 30Mbps Capacity","value":"No"},{"name":"NCAS TC2 40Mbps Capacity","value":"No"},{"name":"NCAS TC4 High Speed Tiers (greater or equal to 250Mbps)","value":"No"},{"name":"NCAS TC1 High Speed Tiers (greater or equal to 0.3Mbps)","value":"No"},{"name":"NCAS TC1 High Speed Tiers (greater or equal to 2Mbps)","value":"No"},{"name":"Multicast","value":"No"}],"serviceTypeQualifications":[{"serviceabilityClass":"12","demandType":"Standard Install","technologyType":"Fibre","csaId":"CSA200000000199","serviceTransferIndicator":"N","serviceType":"Internet","locationId":"LOC160829045445","status":"Available","providerResources":[{"resourceType":"Copper Pair","id":"New Path","status":"","sicIndicator":"Y","sicCode":"SIC_NEW_PATH_SELECTED_INFLIGHT_INPLACE","sicReason":"SIC is applicable due to In flight order in place","serviceabilityClass":"12"}],"statusReason":"NBN Internet is serviceable at this address","characteristics":[{"name":"TC4 Downstream Upper Rate","value":"25 Mbps"},{"name":"TC4 Downstream Lower Rate","value":""},{"name":"TC4 Upstream Upper Rate","value":"5 Mbps"},{"name":"TC4 Upstream Lower Rate","value":""}],"readyForServiceDate":"2011-10-09","appointmentRequired":"Yes","copperPairIndicator":"Y"}],"messages":[{"code":"SQNTT002","message":"The dates cannot be retrieved due to downstream errors"}],"scheduledDates":{"ceaseSaleDate":"","orderStabilityPeriodDate":""}},"request":{"params":{"addressId":"161152457","serviceFilter":"Internet"},"data":{},"path":"/service-addresses","method":"GET","requestId":"cec27ea8-d1f4-4f05-89ac-d11ddaa67774","correlationId":"00d3e37a-82e2-454f-9b66-a8104945973b"},"correlationId":"00d3e37a-82e2-454f-9b66-a8104945973b"}';
        String success_acknowledgement ='{ "_links":[ { "rel":"self", "href":"https://localhost:8080/transition-dm/api/v1/resource/ad38c6b2-1211-4ef3-975b-966f25642b14" } ], "resourceId":"f8df162d-60c3-4074-b622-0d5c997c8708", "type":"service", "identifier":"0429701813", "family":"mobile", "target":{ "type":"uc-calling" }, "status":"active", "state":"validated", "validation":{ "status":"warning", "results":[ { "type":"eligibility", "level":"warning", "code":"TMV00001", "description":"Service is in credit management" } ] }, "attributes":[ { "key":"customerId", "value":"12345" }, { "key":"creditManagement", "value":true } ], "states":[ { "state":"created", "timestamp":"2019-05-03T04:56:57.690Z" }, { "state":"discovered", "timestamp":"2019-05-03T04:56:57.690Z" }, { "state":"validated", "timestamp":"2019-05-03T04:56:57.690Z" } ], "metadata":{ "createdAt":"2019-05-03T04:56:57.690Z", "updatedAt":"2019-05-03T04:56:57.690Z", "systems":[ "mica" ] } }';      
        String Warning_acknowledgement='{"_links":[{"rel":"self","href":"https://private-tapi.telstra.com/v1/tramas/resources/0ddfa7a5-5ccb-4e73-818e-74cccd96043f"}],"resourceId":"7c3b81ad-741a-40d9-83b3-707852cb5a31","transitionId":"e0005146-6605-4f1e-ab9e-8aa823fa28b3","type":"service","identifier":"61472896640","family":"mobile","target":{"type":"enterprise-mobile"},"status":"inactive","state":"validated","validation":{"status":"Warning","results":[{"type":"eligibility","level":"error","code":"TMV00001","description":"Legacy Subscription status is inactive"}]},"attributes":[{"key":"billingId","value":"1001177680","mapped":true,"origin":"discovered"}],"states":[{"state":"created","timestamp":"2020-09-15T03:48:25.233Z"},{"state":"discovered","timestamp":"2020-09-15T03:48:40.674Z"},{"state":"validated","timestamp":"2020-09-15T03:48:43.154Z"}],"metadata":{"createdAt":"2020-09-15T03:48:25.237Z","updatedAt":"2020-09-15T03:48:43.153Z","systems":["mica"]}}';
        String businessError_acknowledgement='{"_links":[{"rel":"self","href":"https://private-tapi.telstra.com/v1/tramas/resources/0ddfa7a5-5ccb-4e73-818e-74cccd96043f"}],"resourceId":"7c3b81ad-741a-40d9-83b3-707852cb5a31","transitionId":"e0005146-6605-4f1e-ab9e-8aa823fa28b3","type":"service","identifier":"61472896640","family":"mobile","target":{"type":"enterprise-mobile"},"status":"inactive","state":"validated","validation":{"status":"failed","results":[{"type":"eligibility","level":"error","code":"TMV00001","description":"Legacy Subscription status is inactive"}]},"attributes":[{"key":"billingId","value":"1001177680","mapped":true,"origin":"discovered"}],"states":[{"state":"created","timestamp":"2020-09-15T03:48:25.233Z"},{"state":"discovered","timestamp":"2020-09-15T03:48:40.674Z"},{"state":"validated","timestamp":"2020-09-15T03:48:43.154Z"}],"metadata":{"createdAt":"2020-09-15T03:48:25.237Z","updatedAt":"2020-09-15T03:48:43.153Z","systems":["mica"]}}';
		String Error_acknowledgement='{"error":{"code":"TM4011","message":"Resource not found","details":"Requested resource not found: 7c3b81ad-741a-40d9-83b3-707852cb5a31","timestamp":"2021-04-23T06:37:40+00:00"}}';
        if(resType.contains('success_acknowledgement')){
            res.setBody(success_acknowledgement);
            res.setStatusCode(201);
        }
        //EDGE-215821 Start
        else if(resType.contains('Warning_acknowledgement')){
            res.setBody(Warning_acknowledgement);
            res.setStatusCode(201);
        }
        else if(resType.contains('businessError_acknowledgement')){
            res.setBody(businessError_acknowledgement);
            res.setStatusCode(201);
        }
        else if(resType.contains('Error_acknowledgement')){
            res.setBody(Error_acknowledgement);
            res.setStatusCode(404);
        }//EDGE-215821 End
        return res;
    }
}