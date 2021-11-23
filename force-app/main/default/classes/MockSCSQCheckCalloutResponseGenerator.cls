/***********************************************************************************************************
Name          : MockSCSQCheckCalloutResponseGenerator
Created By    : Venkata Ramanan G
Created Date  : July 22 2019
Description   : This is a Mock class to simulate the callouts of SQ Check for Site in SCSQCheckController
-------
History                                                            
-------                                                            
VERSION     AUTHOR          DATE            DETAIL                   
-------     ------          -----           ---------                 
1.1         Venkata         22-07-2019      Created
**********************************************************************************************************/
@isTest(SeeAllData=FALSE)
global class MockSCSQCheckCalloutResponseGenerator implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        
        return getDefaultResponse(200);
    }
    private HttpResponse getDefaultResponse(Integer statusCode) {
        
        HttpResponse res = new HttpResponse();
                String mockBody = '{"code":200,"status":200,"time":"2018-06-19T12:12:37+10:00","data":{"addressId":"444444428","serviceTypeQualifications":[{"serviceType":"Calling","technologyType":"HFC","readyForServiceDate":"2009-12-10","serviceabilityClass":"24","newDevelopmentChargesApply":"No","locationId":"LOC000099111125","csaId":"CSA300000000170","demandType":"Standard Install","providerResources":[],"characteristics":[{"name":"Telephony Type","value":"IP Telephony"}],"statusReason":"NBN Calling is serviceable at this address","status":"Available","serviceTransferIndicator":"YN","tc2EnabledCsa":true,"priorityAssistApplicable":"","appointmentRequired":"No"},{"serviceType":"Internet","technologyType":"HFC","readyForServiceDate":"2009-12-10","serviceabilityClass":"24","newDevelopmentChargesApply":"No","locationId":"LOC000099111125","csaId":"CSA300000000170","demandType":"Standard Install","providerResources":[],"characteristics":[{"name":"maxDownstreamSpeed","value":"100 Mbps"},{"name":"maxUpstreamSpeed","value":"40 Mbps"}],"statusReason":"NBN Internet is serviceable at this address","status":"Available","serviceTransferIndicator":"YN","appointmentRequired":"No"},{"serviceType":"Broadband ADSL","technologyType":"ADSL","status":"Available","statusReason":"BigPond Broadband ADSL is available","properties":{"subStatus":"Y002","maxDownloadSpeed":"8000","minDownstreamSpeed":"1800 kbps","maxDownstreamSpeed":"6000 kbps","estimatedDownstreamSpeed":"4100 kbps","fieldWorkRequired":"N","exchangeWorkRequired":"Y"}},{"serviceType":"Broadband ADSL","technologyType":"ADSL2+","status":"Available","statusReason":"BigPond Broadband ADSL is available","properties":{"subStatus":"Y002","maxDownloadSpeed":"24000","minDownstreamSpeed":"2100 kbps","maxDownstreamSpeed":"6400 kbps","estimatedDownstreamSpeed":"4500 kbps","fieldWorkRequired":"N","exchangeWorkRequired":"Y"}},{"serviceType":"Broadband Velocity","technologyType":"FIBRE","status":"Available","statusReason":"This is a Telstra Velocity address. This customer is to be warm transferred to the Telstra Smart Community Call Centre on 1800 008 994 for order creation/customer management. The TSC call centre is operational 9am to 5pm Mon-Fri EST.","properties":{"subStatus":"Y001","maxDownloadSpeed":"800000"}},{"serviceType":"Broadband Cable","technologyType":"Broadband Cable","status":"Available","statusReason":"BigPond Broadband Cable is available","properties":{"maxDownloadSpeed":"10000","serviceLocation":{"locationType":"SDR"}}},{"serviceType":"FOXTEL","technologyType":"Satellite","status":"Available","properties":{}}],"resourceDetails":[{"ntdId":"NTD400000353005","ntdLoc":"INDOOR","ntdInstallDate":"2016-10-16T01:06:17Z","ntdType":"INTERNAL","ntdPowerType":"AC","batteryPowerUnit":"Yes","powerSupplyWithBatteryBackupInstallDate":"2014-10-16T01:06:17Z","batteryPowerUnitMonitored":"ENABLED","portDetails":[{"uniPortType":"UNI-D","portId":"1-UNI-D1","portStatus":"Used"},{"uniPortType":"UNI-D","portId":"1-UNI-D2","portStatus":"Free"},{"uniPortType":"UNI-D","portId":"1-UNI-D3","portStatus":"Free"},{"uniPortType":"UNI-D","portId":"1-UNI-D4","portStatus":"Used"},{"uniPortType":"UNI-V","portId":"1-UNI-V1","portStatus":"Used"},{"uniPortType":"UNI-V","portId":"1-UNI-V2","portStatus":"Free"}]}],"additionalTrafficClassAvailability":[{"name":"NHAS TC1 High Speed Tiers (greater or equal to 2Mbps)","value":"No"},{"name":"NHAS TC1 2Mbps Capacity","value":"No"},{"name":"NHAS TC1 5Mbps Capacity","value":"No"},{"name":"TC2","value":"No"},{"name":"NHAS TC2 5Mbps Capacity","value":"No"},{"name":"NHAS TC2 10Mbps Capacity","value":"No"},{"name":"NHAS TC2 20Mbps Capacity","value":"No"},{"name":"NHAS TC2 30Mbps Capacity","value":"No"},{"name":"NHAS TC2 40Mbps Capacity","value":"No"}],"messages":[{"code":"SQNTT002","message":"The dates cannot be retrieved due to downstream errors"}],"scheduledDates":{"ceaseSaleDate":"","orderStabilityPeriodDate":""}},"request":{"params":{"addressId":"444444428"},"data":{},"path":"/service-addresses","method":"GET","requestId":"e4d6386e-3423-4e17-8ee4-2852651a012c","correlationId":"052e8a9c-331f-4f39-91c1-8522de9fedf7"},"correlationId":"052e8a9c-331f-4f39-91c1-8522de9fedf7"}';

        res.setBody(mockBody);
        res.setStatusCode(StatusCode);
        res.setHeader('Content-Type', 'application/json');
        
        return res;
    }

}