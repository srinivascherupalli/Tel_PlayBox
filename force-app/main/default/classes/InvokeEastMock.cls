/** 
    This class used in InvokeEASTCalloutBatch_Test Method for Mock test 
**/

@isTest
global class InvokeEastMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        System.debug('PP response : '+res);
        res.setBody('{"code":200,"status":200,"time":"2019-06-17T21:13:40+10:00","data":{"transactionStatus":"Success","matchingresultscount":1,"structured":{"addresses":{"addressSummaryType":"PropertyAddressSummary","addressId":"180006695","addressType":"Property with Number","confirmed":true,"reqaddformatout":"structured","planNumber":"DP605828","parcelDescriptor1":"104","parcelDescriptionType1":"L","parcelType1":"F","condorCode":"UNDRA","fsam":"2PKE-07","numSubaddresses":0,"postcode":"2526","state":"NSW","localityName":"UNANDERRA","propertyNumberFrom":1,"propertyNumberTo":"","streetName":"SYLVESTER","streetType":"AVENUE"},"serviceLocation":{"latitude":"-34:28:07.2","longitude":"150:50:06.0","locationId":"LOC000017297964","customerServiceAreaId":"CSA200000010939","readyForServiceDate":"2016-10-07","exchangeServiceArea":"UNAN","facsRealm":"34"}},"unstructuredAUPost":{"addresses":{"addressSummaryType":"FormattedAddressSummary","addressId":"180006695","addressType":"Property with Number","reqaddformatout":"unstructuredAUPost","confirmed":true,"postcode":"2526","state":"NSW","localityName":"UNANDERRA","planNumber":"DP605828","parcelDescriptor1":"104","parcelDescriptionType1":"L","parcelType1":"F","condorCode":"UNDRA","fsam":"2PKE-07","addressline1":"1 SYLVESTER AVE,"},"serviceLocation":{"latitude":"-34:28:07.2","longitude":"150:50:06.0","locationId":"LOC000017297964","customerServiceAreaId":"CSA200000010939","readyForServiceDate":"2016-10-07"}}},"request":{"params":{"addressId":"180006695","reqaddformatout":"unstructuredAUPost,structured"},"data":{},"path":"/addresses/:addressId","method":"GET","requestId":"b0c3866c-aa14-4db1-a9ea-ae4cb0094b67","correlationId":"9709d9dc-b6cf-471e-98b4-31707b707a90"},"correlationId":"b7f445ae-04d1-46b4-fe60-c0eab7a88dee"}');
        res.setStatusCode(200);
        return res;
    }
    
    
}