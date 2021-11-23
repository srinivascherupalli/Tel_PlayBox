/*
* @Author : Rahul/Ritika
* @Date : 17 April 2019
* @Desc : Class for generating MockResponses for TM1EligibilityCheckServiceTest
* @Jira Cloud : EDGE-66569
*/
global class MockTM1EligibilitycheckPostbackResponse implements HttpCalloutMock{
    protected String resType;
    
    global MockTM1EligibilitycheckPostbackResponse(String resType){
        this.resType = resType;
    }
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        //String success_Search = '{"code":200,"status":200,"time":"2019-03-05T13:12:45+10:00","data":{"addressId":"161152457","additionalTrafficClassAvailability":[{"name":"High Speed TC2 (greater or equal to 20Mbps)","value":"No"},{"name":"TC2","value":"No"},{"name":"NCAS TC2 5Mbps Capacity","value":"No"},{"name":"NCAS TC2 10Mbps Capacity","value":"No"},{"name":"NCAS TC2 20Mbps Capacity","value":"No"},{"name":"NCAS TC2 30Mbps Capacity","value":"No"},{"name":"NCAS TC2 40Mbps Capacity","value":"No"},{"name":"NCAS TC4 High Speed Tiers (greater or equal to 250Mbps)","value":"No"},{"name":"NCAS TC1 High Speed Tiers (greater or equal to 0.3Mbps)","value":"No"},{"name":"NCAS TC1 High Speed Tiers (greater or equal to 2Mbps)","value":"No"},{"name":"Multicast","value":"No"}],"serviceTypeQualifications":[{"serviceabilityClass":"12","demandType":"Standard Install","technologyType":"Fibre","csaId":"CSA200000000199","serviceTransferIndicator":"N","serviceType":"Internet","locationId":"LOC160829045445","status":"Available","providerResources":[{"resourceType":"Copper Pair","id":"New Path","status":"","sicIndicator":"Y","sicCode":"SIC_NEW_PATH_SELECTED_INFLIGHT_INPLACE","sicReason":"SIC is applicable due to In flight order in place","serviceabilityClass":"12"}],"statusReason":"NBN Internet is serviceable at this address","characteristics":[{"name":"TC4 Downstream Upper Rate","value":"25 Mbps"},{"name":"TC4 Downstream Lower Rate","value":""},{"name":"TC4 Upstream Upper Rate","value":"5 Mbps"},{"name":"TC4 Upstream Lower Rate","value":""}],"readyForServiceDate":"2011-10-09","appointmentRequired":"Yes","copperPairIndicator":"Y"}],"messages":[{"code":"SQNTT002","message":"The dates cannot be retrieved due to downstream errors"}],"scheduledDates":{"ceaseSaleDate":"","orderStabilityPeriodDate":""}},"request":{"params":{"addressId":"161152457","serviceFilter":"Internet"},"data":{},"path":"/service-addresses","method":"GET","requestId":"cec27ea8-d1f4-4f05-89ac-d11ddaa67774","correlationId":"00d3e37a-82e2-454f-9b66-a8104945973b"},"correlationId":"00d3e37a-82e2-454f-9b66-a8104945973b"}';
        String success_acknowledgement ='{"UUID": "cb94eb66-a650-4b92-827e-9c1aa522364c","Status": "Started","error": null,"Object_Category": "Product","Started_Date": "2019-04-17T18:11:22.193Z","Status_Date": "2019-04-17T18:11:22.193Z","Client_ID": "24447","CallBack_URL": null}';
        String success_Error = '{"code": "500","message": "Discovery service failed with error:ValidationException: One or more parameter values were invalid: An AttributeValue may not contain an empty string"}';
        String success_Exception = '';
        if(resType.contains('success_acknowledgement')){
            res.setBody(success_acknowledgement);
            res.setStatusCode(200);
        }
        else  if(resType.contains('success_Error')){
            res.setBody(success_Error);
            res.setStatusCode(404);
        }
        else if(resType.contains('success_Exception')){
            res.setBody(success_Exception);
            res.setStatusCode(500);
        }
        else if(resType.contains('notfound_Exception')){
            res.setBody(success_Exception);
            res.setStatusCode(503);
        }
        return res;
    }
}