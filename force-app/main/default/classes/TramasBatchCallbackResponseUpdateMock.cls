/*
* @Author : Rahul Asarma
* @Date : 17 Nov 2019
* @Desc : Class for generating MockResponses for AttachmentTriggerHelpertest class
* @Jira Cloud : 
*/

global  class TramasBatchCallbackResponseUpdateMock implements HttpCalloutMock {
    protected String resType;
    
    global TramasBatchCallbackResponseUpdateMock(String resType){
        this.resType = resType;
    }
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        
        String success_acknowledgement ='{"_links":[{"rel":"self","href":"https://localhost:8080/transition-dm/api/v1/resource/ad38c6b2-1211-4ef3-975b-966f25642b14"}],"resourceId":"f8df162d-60c3-4074-b622-0d5c997c8708","type":"service","identifier":"4333432424324","family":"mobile","target":{"type":"uc-calling"},"status":"active","state":"validated","validation":{"status":"completed","results":[]},"attributes":[{"key":"customerId","value":"12345"},{"key":"creditManagement","value":true}],"states":[{"state":"created","timestamp":"2019-05-03T04:56:57.690Z"},{"state":"discovered","timestamp":"2019-05-03T04:56:57.690Z"},{"state":"validated","timestamp":"2019-05-03T04:56:57.690Z"}],"metadata":{"createdAt":"2019-05-03T04:56:57.690Z","updatedAt":"2019-05-03T04:56:57.690Z","systems":["mica"]}}';      
        if(resType.contains('success_acknowledgement')){
            res.setBody(success_acknowledgement);
            res.setStatusCode(201);
        }
         if(resType.contains('Warning_acknowledgement')){
            String Warning_acknowledgement ='{ "_links": [ { "rel": "self", "href": "https://localhost:8080/transition-dm/api/v1/resource/ad38c6b2-1211-4ef3-975b-966f25642b14" } ], "resourceId": "f8df162d-60c3-4074-b622-0d5c997c8708", "type": "service", "identifier": "4333432424324", "family": "mobile", "target": { "type": "uc-calling" }, "status": "active", "state": "reserved", "validation": { "status": "warning", "results": [ { "type": "eligibility", "level": "warning", "code": "TMV00004", "description": "Service is in credit management" } ] }, "attributes": [ { "key": "customerId", "value": "12345" }, { "key": "creditManagement", "value": true } ], "states": [ { "state": "created", "timestamp": "2019-05-03T04:56:57.690Z" }, { "state": "discovered", "timestamp": "2019-05-03T04:56:57.690Z" }, { "state": "validated", "timestamp": "2019-05-03T04:56:57.690Z" } ], "metadata": { "createdAt": "2019-05-03T04:56:57.690Z", "updatedAt": "2019-05-03T04:56:57.690Z", "systems": [ "mica" ] } }';      
            res.setBody(Warning_acknowledgement);
            res.setStatusCode(201);
        }
        if(resType.contains('Warning_acknowledgement2')){
            String Warning_acknowledgement ='{ "_links": [ { "rel": "self", "href": "https://localhost:8080/transition-dm/api/v1/resource/ad38c6b2-1211-4ef3-975b-966f25642b14" } ], "resourceId": "f8df162d-60c3-4074-b622-0d5c997c8708", "type": "service", "identifier": "4333432424324", "family": "mobile", "target": { "type": "uc-calling" }, "status": "active", "state": "validated", "validation": { "status": "warning", "results": [ { "type": "eligibility", "level": "warning", "code": "TMV00006", "description": "Service is in credit management" } ] }, "attributes": [ { "key": "customerId", "value": "12345" }, { "key": "creditManagement", "value": true } ], "states": [ { "state": "created", "timestamp": "2019-05-03T04:56:57.690Z" }, { "state": "discovered", "timestamp": "2019-05-03T04:56:57.690Z" }, { "state": "validated", "timestamp": "2019-05-03T04:56:57.690Z" } ], "metadata": { "createdAt": "2019-05-03T04:56:57.690Z", "updatedAt": "2019-05-03T04:56:57.690Z", "systems": [ "mica" ] } }';      
            res.setBody(Warning_acknowledgement);
            res.setStatusCode(201);
        }
         if(resType.contains('Business_Error')){
            String Warning_acknowledgement ='{ "_links": [ { "rel": "self", "href": "https://localhost:8080/transition-dm/api/v1/resource/ad38c6b2-1211-4ef3-975b-966f25642b14" } ], "resourceId": "f8df162d-60c3-4074-b622-0d5c997c8708", "type": "service", "identifier": "4333432424324", "family": "mobile", "target": { "type": "uc-calling" }, "status": "active", "state": "validated", "validation": { "status": "failed", "results": [ { "type": "eligibility", "level": "warning", "code": "TM4006", "description": "Service is in credit management" } ] }, "attributes": [ { "key": "customerId", "value": "12345" }, { "key": "creditManagement", "value": true } ], "states": [ { "state": "created", "timestamp": "2019-05-03T04:56:57.690Z" }, { "state": "discovered", "timestamp": "2019-05-03T04:56:57.690Z" }, { "state": "validated", "timestamp": "2019-05-03T04:56:57.690Z" } ], "metadata": { "createdAt": "2019-05-03T04:56:57.690Z", "updatedAt": "2019-05-03T04:56:57.690Z", "systems": [ "mica" ] } }';      
            res.setBody(Warning_acknowledgement);
            res.setStatusCode(201);
        }
         if(resType.contains('failed_acknowledgement')){
            String failed_acknowledgement ='{ "_links": [ { "rel": "self", "href": "https://localhost:8080/transition-dm/api/v1/resource/ad38c6b2-1211-4ef3-975b-966f25642b14" } ], "resourceId": "f8df162d-60c3-4074-b622-0d5c997c8708", "type": "service", "identifier": "4333432424324", "family": "mobile", "target": { "type": "uc-calling" }, "status": "active", "state": "reserved", "validation": { "status": "failed", "results": [ { "type": "eligibility", "level": "warning", "code": "TMV00001", "description": "Service is in credit management" } ] }, "attributes": [ { "key": "customerId", "value": "12345" }, { "key": "creditManagement", "value": true } ], "states": [ { "state": "created", "timestamp": "2019-05-03T04:56:57.690Z" }, { "state": "discovered", "timestamp": "2019-05-03T04:56:57.690Z" }, { "state": "validated", "timestamp": "2019-05-03T04:56:57.690Z" } ], "metadata": { "createdAt": "2019-05-03T04:56:57.690Z", "updatedAt": "2019-05-03T04:56:57.690Z", "systems": [ "mica" ] } }';      
            res.setBody(failed_acknowledgement);
            res.setStatusCode(201);
        }
        if(resType.contains('failed_callback')){
            String failed_callback='{"target":{"type":"nguc"},"validation":{"status":"unknown","results":[]},"metadata":{"batchId":"af3450cc-5426-4356-afdf-96b430026e12","correlationId":"ce1fbe3f-536f5d3e-e48e35a1-b16a1fcc","originatingSystem":"Salesforce","providedFamily":"pstn","createdAt":"2021-04-29T01:12:26.360Z","updatedAt":"2021-04-29T06:04:04.432Z"},"transitionId":"95fea99e-ec76-4990-94fb-47be31c48073","type":"service","identifier":"0372213105","family":"pstn","attributes":[],"state":"withdrawn","creationType":"transition","states":[{"state":"created","timestamp":"2021-04-29T01:12:26.355Z"},{"state":"withdrawn","timestamp":"2021-04-29T06:04:04.433Z"}],"status":"unknown","resourceId":"5714b873-5f07-47c6-8ac9-def09ded2d21","_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/5714b873-5f07-47c6-8ac9-def09ded2d21"}]}';
            res.setBody(failed_callback);
            res.setStatusCode(200);
        }
         if(resType.contains('failed_callback404')){
             String failed_callback404='{"error":{"code":"TM4011","message":"Resource not found","details":"Requested resource not found: 7c3b81ad-741a-40d9-83b3-707852cb5a31","timestamp":"2021-04-19T10:03:03+00:00"}}';
             res.setBody(failed_callback404);
            res.setStatusCode(404);
        }
        
        return res;
    }
}