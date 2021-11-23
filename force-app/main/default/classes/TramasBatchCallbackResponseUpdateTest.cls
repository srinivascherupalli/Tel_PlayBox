/* *
* @Author : Rahul Asarma
* @Date :  11 Nov 2019
* @Desc :  Test Class for TramasBatchCallbackResponseUpdate
* @Jira Cloud : EDGE-92541
*/
@isTest
public class TramasBatchCallbackResponseUpdateTest {
@isTest
    Public static void tramasBatchCallbackResponseUpdateSuccess(){
         Account acc = new Account(Name = 'Test Account for CBQ');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.AccountId=acc.Id;
        opp.CloseDate=System.today();
        opp.StageName = 'Develop';
        opp.Product_Type__c = 'Modular';
        opp.Name = 'TestingOpp';
        insert opp;
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket.cscfga__Opportunity__c = opp.id;
        basket.csbb__Account__c = acc.Id;
        basket.Name = 'testBasketforCBQ';
        insert basket;
        
        cscfga__Product_Configuration__c PC = new cscfga__Product_Configuration__c();
        PC.cscfga__Product_Basket__c =basket.id;
        PC.name= 'IP Site';
        PC.cscfga__Description__c = 'Test description';
        insert PC; 
        
        String jsona='{ "Source_System_Id": "Replicator", "site": [{ "siteName": "", "productList": [{ "serviceList": [{ "Service_Type": "voice", "transitionId": "f8df162d-60c3-4074-b622-0d5c997c8708", "service": [{ "User_Type": "", "serviceExtension": [{ "Reason": "", "Reserve_status": "", "Services_To": "0385990499", "Services_From": "0314419400", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "checkValue": false }], "Service_Type": "voice", "Service_Id": "0314419400", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "", "In_Flight_Flag": null, "Reason": "", "Reserve_status": "", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "", "Association_Role": "AUX" }], "disableCheck": null, "checkValue": false }], "Product_Type": "isdn2", "eligibilityStatus": "Ready for assessment", "eligibilityReason": null, "disableCheck": null, "checkValue": true }], "Error_Description": "", "Error_Code": "", "ADBOR_Id": "50484597" }], "serviceCount": 0, "Error_Description": "", "Error_Code": "", "Correlation_Id": "90baead7919646040e", "CIDN": "3867475038" }';
        
        Attachment attc = new Attachment();
                attc.Name =  'TransitionJSONData.json';
                attc.ParentId = PC.id;
                attc.Body = blob.valueof(jsona);
                insert attc;
                
        TramasElgibilityCallbackResponse__c newResponse = new TramasElgibilityCallbackResponse__c();
        newResponse.name='TMBatchCallback';
        newResponse.TranasactionId__c='f8df162d-60c3-4074-b622-0d5c997c8708';
        newResponse.Type__c='TM1';
        newResponse.Product_Configuration__c=PC.id;
        newResponse.Correlation_ID__c='f8df162d-60c3-4074-b622-0d5c997c8708';
        insert  newResponse;        
                
        
        
        String json='{"_links":[{"rel":"self","href":"https://localhost:8080/transition-dm/api/v1/execution/3e878473-61bd-4480-88ac-f935fb213414"},{"rel":"transition","href":"https://localhost:8080/transition-dm/api/v1/transition/f8df162d-60c3-4074-b622-0d5c997c8708"}],"executionId":"3e878473-61bd-4480-88ac-f935fb213414","transitionId":"f8df162d-60c3-4074-b622-0d5c997c8708","action":"reserve","status":"completed","steps":[{"name":"discover","status":"completed","results":[]},{"name":"validate","status":"warning","results":[{"code":"TM3001","description":"validation finished with warnings","_links":[{"rel":"resource","href":"https://localhost:8080/transition-dm/api/v1/resource/ad38c6b2-1211-4ef3-975b-966f25642b14"}]}]},{"name":"reserve","status":"warning","results":[{"code":"TM3001XXX","description":"validation finished with warningsXXX","_links":[{"rel":"resource1","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/d1e01de9-613c-4ac0-a673-45d252bc2f13"},{"rel":"resource2","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/d1e01de9-613c-4ac0-a673-45d252bc2f13"}]}]}],"metadata":{"createdAt":"2019-05-03T04:56:57.690Z","updatedAt":"2019-05-03T04:56:57.690Z","salesforceId":"00P2O000001A2zP"}}';
        //String json = 'Test';
        Attachment att = new Attachment();
        att.Name =  'EligibilityResults.txt';
        att.parentId = newResponse.id;
        att.body = blob.valueof(json);
        att.Description = 'Aniket';
        insert att;
        Test.startTest();
        map<id,attachment> attMap= new map<id,attachment>();
        //Attachment attTest  = testsetUpData();
        //Attachment attTest  = [Select id,Description,body from attachment where name='EligibilityResults.txt' limit 1];
       // system.assert(attTest != null);
            //system.debug('description : ' + attTest.Description);
            //system.debug('Name : ' + attTest.Name);
            //system.debug('Body : ' + attTest.body.toString());
            att.Description = '1234';
            update att;
            attMap.put(att.id,att);
            String attId = att.Id;
            
            List<Id> recordId = new List<Id>();
            recordId.add(att.Id);
            List<Id> parentId = new List<Id>();
            parentId.add(att.parentid);
            List<String> body = new List<String>();
            body.add('{ "_links": [ { "rel": "self", "href": "https://localhost:8080/transition-dm/api/v1/execution/3e878473-61bd-4480-88ac-f935fb213414" }, { "rel": "transition", "href": "https://localhost:8080/transition-dm/api/v1/transition/f8df162d-60c3-4074-b622-0d5c997c8708" } ], "executionId": "3e878473-61bd-4480-88ac-f935fb213414", "transitionId": "f8df162d-60c3-4074-b622-0d5c997c8708", "action": "validate", "status": "completed", "steps": [ { "name": "discover", "status": "completed", "results": [ ] }, { "name": "validate", "status": "warning", "results": [ { "code": "TM3001", "description": "validation finished with warnings", "_links": [ { "rel": "resource", "href": "https://localhost:8080/transition-dm/api/v1/resource/ad38c6b2-1211-4ef3-975b-966f25642b14" } ] } ] }, { "name": "reserve", "status": "warning", "results": [ { "code": "TM3001XXX", "description": "validation finished with warningsXXX", "_links": [ { "rel": "resource1", "href": "https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008" }, { "rel": "resource2", "href": "https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008" } ] }, { "code": "TM300YYY", "description": "validation finished with warningsXXX", "_links": [ { "rel": "resource1", "href": "https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008" }, { "rel": "resource2", "href": "https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008" } ] } ] } ], "metadata": { "createdAt": "2019-05-03T04:56:57.690Z", "updatedAt": "2019-05-03T04:56:57.690Z", "salesforceId": "00P2O000001A2zP" } }');
        TramasBatchCallbackResponseUpdate.tramasAttachmentsUpdate(recordId,parentId,body);
        //system.debug('attMap:' + attMap);
            Test.setMock(HttpCalloutMock.class, new TramasBatchCallbackResponseUpdateMock('success_acknowledgement'));
            
        //String serialized = JSON.serialize(attMap);
        //TramasCallbackResponseUpdate.tamasAttachmentsUpdate(serialized,serialized);
        //delete(attTest);
        Attachment_TriggerHandler attTrigger = new Attachment_TriggerHandler();
        attTrigger.bulkBefore();
        attTrigger.beforeInsert(att);
        system.assert(att!=null);
        Test.stopTest();
    }
    
    @isTest
    Public static void tramasBatchCallbackResponseUpdateSuccessReserve(){
         Account acc = new Account(Name = 'Test Account for CBQ');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.AccountId=acc.Id;
        opp.CloseDate=System.today();
        opp.StageName = 'Develop';
        opp.Product_Type__c = 'Modular';
        opp.Name = 'TestingOpp';
        insert opp;
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket.cscfga__Opportunity__c = opp.id;
        basket.csbb__Account__c = acc.Id;
        basket.Name = 'testBasketforCBQ';
        insert basket;
        
        cscfga__Product_Configuration__c PC = new cscfga__Product_Configuration__c();
        PC.cscfga__Product_Basket__c =basket.id;
        PC.name= 'IP Site';
        PC.cscfga__Description__c = 'Test description';
        insert PC; 
        
        String jsona='{ "Source_System_Id": "Replicator", "site": [{ "siteName": "", "productList": [{ "serviceList": [{ "Service_Type": "voice", "transitionId": "f8df162d-60c3-4074-b622-0d5c997c8708", "service": [{ "User_Type": "", "serviceExtension": [{ "Reason": "", "Reserve_status": "", "Services_To": "0385990499", "Services_From": "0314419400", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "checkValue": false }], "Service_Type": "voice", "Service_Id": "4333432424324", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "", "In_Flight_Flag": null, "Reason": "", "Reserve_status": "", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "", "Association_Role": "AUX" }], "disableCheck": null, "checkValue": false }], "Product_Type": "isdn2", "eligibilityStatus": "Ready for assessment", "eligibilityReason": null, "disableCheck": null, "checkValue": true }], "Error_Description": "", "Error_Code": "", "ADBOR_Id": "50484597" }], "serviceCount": 0, "Error_Description": "", "Error_Code": "", "Correlation_Id": "90baead7919646040e", "CIDN": "3867475038" }';
        
        Attachment attc = new Attachment();
                attc.Name =  'TransitionJSONData.json';
                attc.ParentId = PC.id;
                attc.Body = blob.valueof(jsona);
                insert attc;
                
                TramasElgibilityCallbackResponse__c newResponse = new TramasElgibilityCallbackResponse__c();
                newResponse.name='TMBatchCallback';
                newResponse.TranasactionId__c='f8df162d-60c3-4074-b622-0d5c997c8708';
                newResponse.Type__c='TM2';
                 newResponse.Product_Configuration__c=PC.id;
                  newResponse.Correlation_ID__c='f8df162d-60c3-4074-b622-0d5c997c8708';
                insert  newResponse;        
                
        
        
        String json='{ "_links": [ { "rel": "self", "href": "https://localhost:8080/transition-dm/api/v1/execution/3e878473-61bd-4480-88ac-f935fb213414" }, { "rel": "transition", "href": "https://localhost:8080/transition-dm/api/v1/transition/f8df162d-60c3-4074-b622-0d5c997c8708" } ], "executionId": "3e878473-61bd-4480-88ac-f935fb213414", "transitionId": "f8df162d-60c3-4074-b622-0d5c997c8708", "action": "reserve", "status": "completed", "steps": [ { "name": "discover", "status": "completed", "results": [ ] }, { "name": "validate", "status": "completed", "results": [] }, { "name": "reserve", "status": "warning", "results": [ { "code": "TM3001XXX", "description": "validation finished with warningsXXX", "_links": [ { "rel": "resource1", "href": "https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/d1e01de9-613c-4ac0-a673-45d252bc2f13" }, { "rel": "resource2", "href": "https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/d1e01de9-613c-4ac0-a673-45d252bc2f13" } ] } ] } ], "metadata": { "createdAt": "2019-05-03T04:56:57.690Z", "updatedAt": "2019-05-03T04:56:57.690Z", "salesforceId": "00P2O000001A2zP" } }';
        //String json = 'Test';
        Attachment att = new Attachment();
        att.Name =  'ReserveResults.txt';
        att.parentId = newResponse.id;
        att.body = blob.valueof(json);
        att.Description = 'Aniket';
        insert att;
        Test.startTest();
        map<id,attachment> attMap= new map<id,attachment>();
        //Attachment attTest  = testsetUpData();
        //Attachment attTest  = [Select id,Description,body from attachment where name='EligibilityResults.txt' limit 1];
       // system.assert(attTest != null);
            //system.debug('description : ' + attTest.Description);
            //system.debug('Name : ' + attTest.Name);
            //system.debug('Body : ' + attTest.body.toString());
            att.Description = '1234';
            update att;
            attMap.put(att.id,att);
            String attId = att.Id;
            
            List<Id> recordId = new List<Id>();
            recordId.add(att.Id);
            List<Id> parentId = new List<Id>();
            parentId.add(att.parentid);
            List<String> body = new List<String>();
            body.add('{"_links":[{"rel":"self","href":"https://localhost:8080/transition-dm/api/v1/execution/3e878473-61bd-4480-88ac-f935fb213414"},{"rel":"transition","href":"https://localhost:8080/transition-dm/api/v1/transition/f8df162d-60c3-4074-b622-0d5c997c8708"}],"executionId":"3e878473-61bd-4480-88ac-f935fb213414","transitionId":"f8df162d-60c3-4074-b622-0d5c997c8708","action":"reserve","status":"completed","steps":[{"name":"discover","status":"completed","results":[]},{"name":"validate","status":"warning","results":[{"code":"TM3001","description":"validation finished with warnings","_links":[{"rel":"resource","href":"https://localhost:8080/transition-dm/api/v1/resource/ad38c6b2-1211-4ef3-975b-966f25642b14"}]}]},{"name":"reserve","status":"warning","results":[{"code":"TM3001XXX","description":"validation finished with warningsXXX","_links":[{"rel":"resource1","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"},{"rel":"resource2","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"}]},{"code":"TM300YYY","description":"validation finished with warningsXXX","_links":[{"rel":"resource1","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"},{"rel":"resource2","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"}]}]}],"metadata":{"createdAt":"2019-05-03T04:56:57.690Z","updatedAt":"2019-05-03T04:56:57.690Z","salesforceId":"00P2O000001A2zP"}}');
        TramasBatchCallbackResponseUpdate.tramasAttachmentsUpdate(recordId,parentId,body);
        //system.debug('attMap:' + attMap);
            Test.setMock(HttpCalloutMock.class, new TramasBatchCallbackResponseUpdateMock('success_acknowledgement'));
          
        //String serialized = JSON.serialize(attMap);
        //TramasCallbackResponseUpdate.tamasAttachmentsUpdate(serialized,serialized);
        //delete(attTest);
        Attachment_TriggerHandler attTrigger = new Attachment_TriggerHandler();
        attTrigger.bulkBefore();
        attTrigger.beforeInsert(att);
        system.assert(att!=null);
        Test.stopTest();
    }
    
    @isTest
    Public static void tramasBatchCallbackResponseUpdateSuccessReserveCompleted(){
         Account acc = new Account(Name = 'Test Account for CBQ');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.AccountId=acc.Id;
        opp.CloseDate=System.today();
        opp.StageName = 'Develop';
        opp.Product_Type__c = 'Modular';
        opp.Name = 'TestingOpp';
        insert opp;
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket.cscfga__Opportunity__c = opp.id;
        basket.csbb__Account__c = acc.Id;
        basket.Name = 'testBasketforCBQ';
        insert basket;
        
        cscfga__Product_Configuration__c PC = new cscfga__Product_Configuration__c();
        PC.cscfga__Product_Basket__c =basket.id;
        PC.name= 'IP Site';
        PC.cscfga__Description__c = 'Test description';
        insert PC; 
        
        String jsona='{ "Source_System_Id": "Replicator", "site": [{ "siteName": "", "productList": [{ "serviceList": [{ "Service_Type": "voice", "transitionId": "f8df162d-60c3-4074-b622-0d5c997c8708", "service": [{ "User_Type": "", "serviceExtension": [{ "Reason": "", "Reserve_status": "", "Services_To": "0385990499", "Services_From": "0314419400", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "checkValue": false }], "Service_Type": "voice", "Service_Id": "4333432424324", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "", "In_Flight_Flag": null, "Reason": "", "Reserve_status": "", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "", "Association_Role": "AUX" }], "disableCheck": null, "checkValue": false }], "Product_Type": "isdn2", "eligibilityStatus": "Ready for assessment", "eligibilityReason": null, "disableCheck": null, "checkValue": true }], "Error_Description": "", "Error_Code": "", "ADBOR_Id": "50484597" }], "serviceCount": 0, "Error_Description": "", "Error_Code": "", "Correlation_Id": "90baead7919646040e", "CIDN": "3867475038" }';
        
        Attachment attc = new Attachment();
                attc.Name =  'TransitionJSONData.json';
                attc.ParentId = PC.id;
                attc.Body = blob.valueof(jsona);
                insert attc;
                
                TramasElgibilityCallbackResponse__c newResponse = new TramasElgibilityCallbackResponse__c();
                newResponse.name='TMBatchCallback';
                newResponse.TranasactionId__c='f8df162d-60c3-4074-b622-0d5c997c8708';
                newResponse.Type__c='TM2';
                 newResponse.Product_Configuration__c=PC.id;
                  newResponse.Correlation_ID__c='f8df162d-60c3-4074-b622-0d5c997c8708';
                insert  newResponse;        
                
        
        
        String json='{ "_links": [ { "rel": "self", "href": "https://localhost:8080/transition-dm/api/v1/execution/3e878473-61bd-4480-88ac-f935fb213414" }, { "rel": "transition", "href": "https://localhost:8080/transition-dm/api/v1/transition/f8df162d-60c3-4074-b622-0d5c997c8708" } ], "executionId": "3e878473-61bd-4480-88ac-f935fb213414", "transitionId": "f8df162d-60c3-4074-b622-0d5c997c8708", "action": "reserve", "status": "completed", "steps": [ { "name": "discover", "status": "completed", "results": [ ] }, { "name": "validate", "status": "completed", "results": [] }, { "name": "reserve", "status": "warning", "results": [ { "code": "TM3001XXX", "description": "validation finished with warningsXXX", "_links": [ { "rel": "resource1", "href": "https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/d1e01de9-613c-4ac0-a673-45d252bc2f13" }, { "rel": "resource2", "href": "https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/d1e01de9-613c-4ac0-a673-45d252bc2f13" } ] } ] } ], "metadata": { "createdAt": "2019-05-03T04:56:57.690Z", "updatedAt": "2019-05-03T04:56:57.690Z", "salesforceId": "00P2O000001A2zP" } }';
        //String json = 'Test';
        Attachment att = new Attachment();
        att.Name =  'ReserveResults.txt';
        att.parentId = newResponse.id;
        att.body = blob.valueof(json);
        att.Description = 'Aniket';
        insert att;
        Test.startTest();
        map<id,attachment> attMap= new map<id,attachment>();
        //Attachment attTest  = testsetUpData();
        //Attachment attTest  = [Select id,Description,body from attachment where name='EligibilityResults.txt' limit 1];
       // system.assert(attTest != null);
            //system.debug('description : ' + attTest.Description);
            //system.debug('Name : ' + attTest.Name);
            //system.debug('Body : ' + attTest.body.toString());
            att.Description = '1234';
            update att;
            attMap.put(att.id,att);
            String attId = att.Id;
            
            List<Id> recordId = new List<Id>();
            recordId.add(att.Id);
            List<Id> parentId = new List<Id>();
            parentId.add(att.parentid);
            List<String> body = new List<String>();
            body.add('{ "_links": [ { "rel": "self", "href": "https://slot1.org009.t-dev.telstra.net/v1/tramas/executions/ee21c297-9c0d-4d0b-804a-8c1a98889530" }, { "rel": "transition", "href": "https://slot1.org009.t-dev.telstra.net/v1/tramas/transitions/f8df162d-60c3-4074-b622-0d5c997c8708" } ], "executionId": "ee21c297-9c0d-4d0b-804a-8c1a98889530", "transitionId": "f8df162d-60c3-4074-b622-0d5c997c8708", "action": "reserve", "status": "completed", "steps": [ { "name": "create", "status": "completed", "results": [ ] }, { "name": "discover", "status": "completed", "results": [ ] }, { "name": "validate", "status": "completed", "results": [ ] }, { "name": "reserve", "status": "completed", "results": [ ] } ], "metadata": { "salesforceId": "00P2O000001fa3CUAQ", "createdAt": "2020-06-15T03:46:22.972Z", "updatedAt": "2020-06-15T03:49:40.519Z", "correlationId": "1f020fb6-4dddb603-92f1c3aa-cf7589a0", "host": "https://slot1.org009.t-dev.telstra.net/v1/tramas", "originatingSystem": "Salesforce", "stepFunctions": [ { "executionArn": "arn:aws:states:ap-southeast-2:450340460944:execution:transition-elrod-tramas-preprod:5780af52-6b7d-4955-bd77-dbccaaf9e9f3", "startDate": "2020-06-15T03:46:23.207Z" } ], "elrodJobs": [ { "jobId": "6def5aca-8b2d-4d65-b8dc-99ebae46c31a", "startDate": "2020-06-15T13:46:28+10:00", "workflowAction": "discover" }, { "jobId": "b6e10163-f4c1-48fc-9062-9eb8e14a5283", "startDate": "2020-06-15T13:49:22+10:00", "workflowAction": "reserve" } ] } }');
        TramasBatchCallbackResponseUpdate.tramasAttachmentsUpdate(recordId,parentId,body);
        //system.debug('attMap:' + attMap);
            Test.setMock(HttpCalloutMock.class, new TramasBatchCallbackResponseUpdateMock('success_acknowledgement'));
          
        //String serialized = JSON.serialize(attMap);
        //TramasCallbackResponseUpdate.tamasAttachmentsUpdate(serialized,serialized);
        //delete(attTest);
        Attachment_TriggerHandler attTrigger = new Attachment_TriggerHandler();
        attTrigger.bulkBefore();
        attTrigger.beforeInsert(att);
        system.assert(att!=null);
        Test.stopTest();
    }
    
    
    @isTest
    Public static void tramasBatchCallbackResponseUpdateSuccessReserveSuccess(){
         Account acc = new Account(Name = 'Test Account for CBQ');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.AccountId=acc.Id;
        opp.CloseDate=System.today();
        opp.StageName = 'Develop';
        opp.Product_Type__c = 'Modular';
        opp.Name = 'TestingOpp';
        insert opp;
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket.cscfga__Opportunity__c = opp.id;
        basket.csbb__Account__c = acc.Id;
        basket.Name = 'testBasketforCBQ';
        insert basket;
        
        cscfga__Product_Configuration__c PC = new cscfga__Product_Configuration__c();
        PC.cscfga__Product_Basket__c =basket.id;
        PC.name= 'IP Site';
        PC.cscfga__Description__c = 'Test description';
        insert PC; 
        
        String jsona='{ "Source_System_Id": "Replicator", "site": [{ "siteName": "", "productList": [{ "serviceList": [{ "Service_Type": "voice", "transitionId": "f8df162d-60c3-4074-b622-0d5c997c8708", "service": [{ "User_Type": "", "serviceExtension": [{ "Reason": "", "Reserve_status": "", "Services_To": "0385990499", "Services_From": "0314419400", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "checkValue": false }], "Service_Type": "voice", "Service_Id": "4333432424324", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "", "In_Flight_Flag": null, "Reason": "", "Reserve_status": "", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "", "Association_Role": "AUX" }], "disableCheck": null, "checkValue": false }], "Product_Type": "isdn2", "eligibilityStatus": "Ready for assessment", "eligibilityReason": null, "disableCheck": null, "checkValue": true }], "Error_Description": "", "Error_Code": "", "ADBOR_Id": "50484597" }], "serviceCount": 0, "Error_Description": "", "Error_Code": "", "Correlation_Id": "90baead7919646040e", "CIDN": "3867475038" }';
        
        Attachment attc = new Attachment();
                attc.Name =  'TransitionJSONData.json';
                attc.ParentId = PC.id;
                attc.Body = blob.valueof(jsona);
                insert attc;
                
                TramasElgibilityCallbackResponse__c newResponse = new TramasElgibilityCallbackResponse__c();
                newResponse.name='TMBatchCallback';
                newResponse.TranasactionId__c='f8df162d-60c3-4074-b622-0d5c997c8708';
                newResponse.Type__c='TM2';
                 newResponse.Product_Configuration__c=PC.id;
                  newResponse.Correlation_ID__c='f8df162d-60c3-4074-b622-0d5c997c8708';
                insert  newResponse;        
                
        
        
        String json='{ "_links": [ { "rel": "self", "href": "https://localhost:8080/transition-dm/api/v1/execution/3e878473-61bd-4480-88ac-f935fb213414" }, { "rel": "transition", "href": "https://localhost:8080/transition-dm/api/v1/transition/f8df162d-60c3-4074-b622-0d5c997c8708" } ], "executionId": "3e878473-61bd-4480-88ac-f935fb213414", "transitionId": "f8df162d-60c3-4074-b622-0d5c997c8708", "action": "reserve", "status": "completed", "steps": [ { "name": "discover", "status": "completed", "results": [ ] }, { "name": "validate", "status": "completed", "results": [ ] }, { "name": "reserve", "status": "completed", "results": [ ] } ], "metadata": { "createdAt": "2019-05-03T04:56:57.690Z", "updatedAt": "2019-05-03T04:56:57.690Z", "salesforceId": "00P2O000001A2zP" } }';
        //String json = 'Test';
        Attachment att = new Attachment();
        att.Name =  'ReserveResults.txt';
        att.parentId = newResponse.id;
        att.body = blob.valueof(json);
        att.Description = 'Aniket';
        insert att;
        Test.startTest();
        map<id,attachment> attMap= new map<id,attachment>();
        //Attachment attTest  = testsetUpData();
        //Attachment attTest  = [Select id,Description,body from attachment where name='EligibilityResults.txt' limit 1];
       // system.assert(attTest != null);
            //system.debug('description : ' + attTest.Description);
            //system.debug('Name : ' + attTest.Name);
            //system.debug('Body : ' + attTest.body.toString());
            att.Description = '1234';
            update att;
            attMap.put(att.id,att);
            String attId = att.Id;
            
            List<Id> recordId = new List<Id>();
            recordId.add(att.Id);
            List<Id> parentId = new List<Id>();
            parentId.add(att.parentid);
            List<String> body = new List<String>();
            body.add('{"_links":[{"rel":"self","href":"https://localhost:8080/transition-dm/api/v1/execution/3e878473-61bd-4480-88ac-f935fb213414"},{"rel":"transition","href":"https://localhost:8080/transition-dm/api/v1/transition/f8df162d-60c3-4074-b622-0d5c997c8708"}],"executionId":"3e878473-61bd-4480-88ac-f935fb213414","transitionId":"f8df162d-60c3-4074-b622-0d5c997c8708","action":"reserve","status":"completed","steps":[{"name":"discover","status":"completed","results":[]},{"name":"validate","status":"warning","results":[{"code":"TM3001","description":"validation finished with warnings","_links":[{"rel":"resource","href":"https://localhost:8080/transition-dm/api/v1/resource/ad38c6b2-1211-4ef3-975b-966f25642b14"}]}]},{"name":"reserve","status":"warning","results":[{"code":"TM3001XXX","description":"validation finished with warningsXXX","_links":[{"rel":"resource1","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"},{"rel":"resource2","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"}]},{"code":"TM300YYY","description":"validation finished with warningsXXX","_links":[{"rel":"resource1","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"},{"rel":"resource2","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"}]}]}],"metadata":{"createdAt":"2019-05-03T04:56:57.690Z","updatedAt":"2019-05-03T04:56:57.690Z","salesforceId":"00P2O000001A2zP"}}');
        TramasBatchCallbackResponseUpdate.tramasAttachmentsUpdate(recordId,parentId,body);
        //system.debug('attMap:' + attMap);
            Test.setMock(HttpCalloutMock.class, new TramasBatchCallbackResponseUpdateMock('success_acknowledgement'));
            
        //String serialized = JSON.serialize(attMap);
        //TramasCallbackResponseUpdate.tamasAttachmentsUpdate(serialized,serialized);
        //delete(attTest);
        Attachment_TriggerHandler attTrigger = new Attachment_TriggerHandler();
        attTrigger.bulkBefore();
        attTrigger.beforeInsert(att);
        system.assert(att!=null);
        Test.stopTest();
    }
    
    @isTest
    Public static void tramasBatchCallbackResponseUpdateSuccessNguc(){
         Account acc = new Account(Name = 'Test Account for CBQ');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.AccountId=acc.Id;
        opp.CloseDate=System.today();
        opp.StageName = 'Develop';
        opp.Product_Type__c = 'Modular';
        opp.Name = 'TestingOpp';
        insert opp;
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket.cscfga__Opportunity__c = opp.id;
        basket.csbb__Account__c = acc.Id;
        basket.Name = 'testBasketforCBQ';
        insert basket;
        
        cscfga__Product_Configuration__c PC = new cscfga__Product_Configuration__c();
        PC.cscfga__Product_Basket__c =basket.id;
        PC.name= 'IP Site';
        PC.cscfga__Description__c = 'Test description';
        insert PC; 
        
        String jsona='{ "Source_System_Id": "Replicator", "serviceCount": 0, "productList": [ { "site": [ { "siteName": null, "serviceList": [ { "Service_Type": "NORM", "groupType": [ { "transitionId": "f8df162d-60c3-4074-b622-0d5c997c8708", "service": [ { "sim_serial_number": null, "serviceExtensions": [ { "serviceExtensionFrom": "0362835301", "serviceExtensionTo": "0362835320", "eligibilityStatus":null, "eligibilityReason":null }, { "serviceExtensionFrom": "0362835321", "serviceExtensionTo": "0362835399", "eligibilityStatus":null, "eligibilityReason":null } ], "service_type_code": null, "service_type": "NORM", "eligibilityStatus ":null, "eligibilityReason ":null, "service_status": "AC", "Service_Id": "4333432424324", "Reserve_status": null, "replicatorUpdateDateTime": "2019-07-26 11:11:49.593", "Reason": null, "service_association_role": "Prime", "plan_name": "Go Business Data SIM $5", "message_bank": "Video MessageBank", "international_roaming": "Access to Use Mobile Overseas", "imsi_number": null, "idd": null, "Eligibility_status": null, "directory_listing": null, "devices": [ { "physicalId": "89610163267640000029", "networkId": "505013485041069", "deviceType": "sim" }, { "physicalId": "89610163267640000029", "networkId": "505013485041069", "deviceType": "sim" } ], "contract_term": "36", "calling_line_identifier": "ON", "accountDetails": { "serviceWithEtcFlag": "N", "creditManagementFlag": "N", "complexBillingIndicator": "N", "accountNumber": "2212356398" } } ], "groupId": "mobileGroup", "disableCheck": null, "checkValue": true } ], "EligibilityStatus": "Eligible", "EligibilityReason": "", "disableCheck": false, "checkValue": true, "checkReserved": false } ], "Error_Description": null, "Error_Code": null, "ADBOR_Id": "0" }, { "siteName": null, "serviceList": [ { "Service_Type": "NORM", "groupType": [ { "transitionId": null, "service": [ { "sim_serial_number": null, "serviceExtensions": [ { "serviceExtensionFrom": "0362835302", "serviceExtensionTo": "0362835329", "eligibilityStatus":null, "eligibilityReason":null }, { "serviceExtensionFrom": "0362835324", "serviceExtensionTo": "03628353100", "eligibilityStatus":null, "eligibilityReason":null } ], "service_type_code": null, "service_type": "NORM", "service_status": "AC", "Service_Id": "2323232388", "Reserve_status": null, "replicatorUpdateDateTime": "2019-07-26 11:11:49.593", "Reason": null, "eligibilityStatus":null, "eligibilityReason":null, "service_association_role": "Prime", "plan_name": "Go Business Data SIM $5", "message_bank": "Video MessageBank", "international_roaming": "Access to Use Mobile Overseas", "imsi_number": null, "idd": null, "Eligibility_status": null, "directory_listing": null, "devices": [ { "physicalId": "89610163267640000029", "networkId": "505013485041069", "deviceType": "sim" }, { "physicalId": "89610163267640000029", "networkId": "505013485041069", "deviceType": "sim" } ], "contract_term": "36", "calling_line_identifier": "ON", "accountDetails": { "serviceWithEtcFlag": "N", "creditManagementFlag": "N", "complexBillingIndicator": "N", "accountNumber": "2212356398" } } ], "groupId": "mobileGroup", "disableCheck": null, "checkValue": true } ], "EligibilityStatus": "Eligible", "EligibilityReason": "", "disableCheck": false, "checkValue": true, "checkReserved": false } ], "Error_Description": null, "Error_Code": null, "ADBOR_Id": "0" } ], "Product_Type": "ISDN30", "eligibilityStatus": null, "eligibilityReason": null, "disableCheck": null, "checkValue": null } ], "Error_Description": "", "Error_Code": "", "Correlation_Id": "5465764671208", "CIDN": "1234567890" }';
        
        Attachment attc = new Attachment();
                attc.Name =  system.label.NgUcTransitionName;
                attc.ParentId = PC.id;
                attc.Body = blob.valueof(jsona);
                insert attc;
                
                TramasElgibilityCallbackResponse__c newResponse = new TramasElgibilityCallbackResponse__c();
                newResponse.name='TMBatchCallback';
                newResponse.TranasactionId__c='f8df162d-60c3-4074-b622-0d5c997c8708';
                newResponse.Type__c='TM1';
                 newResponse.Product_Configuration__c=PC.id;
                  newResponse.Correlation_ID__c='f8df162d-60c3-4074-b622-0d5c997c8708';
                insert  newResponse;        
                
        
        
        String json='{ "_links": [ { "rel": "self", "href": "https://localhost:8080/transition-dm/api/v1/execution/3e878473-61bd-4480-88ac-f935fb213414" }, { "rel": "transition", "href": "https://localhost:8080/transition-dm/api/v1/transition/f8df162d-60c3-4074-b622-0d5c997c8708" } ], "executionId": "3e878473-61bd-4480-88ac-f935fb213414", "transitionId": "f8df162d-60c3-4074-b622-0d5c997c8708", "action": "reserve", "status": "completed", "steps": [ { "name": "discover", "status": "completed", "results": [ ] }, { "name": "validate", "status": "completed", "results": [   ] }, { "name": "reserve", "status": "completed", "results": [ ] } ], "metadata": { "createdAt": "2019-05-03T04:56:57.690Z", "updatedAt": "2019-05-03T04:56:57.690Z", "salesforceId": "00P2O000001A2zP" } }';
        //String json = 'Test';
        Attachment att = new Attachment();
        att.Name =  'EligibilityResults.txt';
        att.parentId = newResponse.id;
        att.body = blob.valueof(json);
        att.Description = 'Aniket';
        insert att;
         map<string,string> eligibilityWithTramasRecordMap= new map<String,String>(); 
         eligibilityWithTramasRecordMap.put(newResponse.id,'Eligible');
        Test.startTest();
        map<id,attachment> attMap= new map<id,attachment>();
        //Attachment attTest  = testsetUpData();
        //Attachment attTest  = [Select id,Description,body from attachment where name='EligibilityResults.txt' limit 1];
       // system.assert(attTest != null);
            //system.debug('description : ' + attTest.Description);
            //system.debug('Name : ' + attTest.Name);
            //system.debug('Body : ' + attTest.body.toString());
            att.Description = '1234';
            update att;
            attMap.put(att.id,att);
            String attId = att.Id;
            
            List<Id> recordId = new List<Id>();
            recordId.add(att.Id);
            List<Id> parentId = new List<Id>();
            parentId.add(att.parentid);
            List<String> body = new List<String>();
            body.add('{"_links":[{"rel":"self","href":"https://localhost:8080/transition-dm/api/v1/execution/3e878473-61bd-4480-88ac-f935fb213414"},{"rel":"transition","href":"https://localhost:8080/transition-dm/api/v1/transition/f8df162d-60c3-4074-b622-0d5c997c8708"}],"executionId":"3e878473-61bd-4480-88ac-f935fb213414","transitionId":"f8df162d-60c3-4074-b622-0d5c997c8708","action":"validate","status":"completed","steps":[{"name":"discover","status":"completed","results":[]},{"name":"validate","status":"warning","results":[{"code":"TM3001","description":"validation finished with warnings","_links":[{"rel":"resource","href":"https://localhost:8080/transition-dm/api/v1/resource/ad38c6b2-1211-4ef3-975b-966f25642b14"}]}]},{"name":"reserve","status":"warning","results":[{"code":"TM3001XXX","description":"validation finished with warningsXXX","_links":[{"rel":"resource1","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"},{"rel":"resource2","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"}]},{"code":"TM300YYY","description":"validation finished with warningsXXX","_links":[{"rel":"resource1","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"},{"rel":"resource2","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"}]}]}],"metadata":{"createdAt":"2019-05-03T04:56:57.690Z","updatedAt":"2019-05-03T04:56:57.690Z","salesforceId":"00P2O000001A2zP"}}');
        TramasBatchCallbackResponseUpdate.tramasAttachmentsUpdate(recordId,parentId,body);
        //system.debug('attMap:' + attMap);
            Test.setMock(HttpCalloutMock.class, new TramasBatchCallbackResponseUpdateMock('success_acknowledgement'));
         TramasEligiblityUpdate.updateTramasRecord(eligibilityWithTramasRecordMap); 
        //String serialized = JSON.serialize(attMap);
        //TramasCallbackResponseUpdate.tamasAttachmentsUpdate(serialized,serialized);
        //delete(attTest);
        Attachment_TriggerHandler attTrigger = new Attachment_TriggerHandler();
        attTrigger.bulkBefore();
        attTrigger.beforeInsert(att);
        system.assert(att!=null);
        Test.stopTest();
        String eligiblityCriteriaValue=[select Eligibility_Criteria__c from TramasElgibilityCallbackResponse__c where id=:newResponse.id].Eligibility_Criteria__c;
        system.assert(eligiblityCriteriaValue=='Eligible');//Added Assert for EDGE-151424
         List<Attachment> attlist= [select id,body from Attachment where ParentId =:PC.id];
        String attachmentbody=attlist[0].body.toString();
         System.assertEquals(true, attachmentbody.contains('Eligible'));//EDGE-158682
    }
    
    @isTest
    Public static void tramasBatchCallbackResponseUpdateSuccessNgucReserve(){
         Account acc = new Account(Name = 'Test Account for CBQ');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.AccountId=acc.Id;
        opp.CloseDate=System.today();
        opp.StageName = 'Develop';
        opp.Product_Type__c = 'Modular';
        opp.Name = 'TestingOpp';
        insert opp;
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket.cscfga__Opportunity__c = opp.id;
        basket.csbb__Account__c = acc.Id;
        basket.Name = 'testBasketforCBQ';
        insert basket;
        
        cscfga__Product_Configuration__c PC = new cscfga__Product_Configuration__c();
        PC.cscfga__Product_Basket__c =basket.id;
        PC.name= 'IP Site';
        PC.cscfga__Description__c = 'Test description';
        insert PC; 
        
        String jsona='{ "Source_System_Id": "Replicator", "serviceCount": 0, "productList": [ { "site": [ { "siteName": null, "serviceList": [ { "Service_Type": "NORM", "groupType": [ { "transitionId": "f8df162d-60c3-4074-b622-0d5c997c8708", "service": [ { "sim_serial_number": null, "serviceExtensions": [ { "serviceExtensionFrom": "0362835301", "serviceExtensionTo": "0362835320", "eligibilityStatus":null, "eligibilityReason":null }, { "serviceExtensionFrom": "0362835321", "serviceExtensionTo": "0362835399", "eligibilityStatus":null, "eligibilityReason":null } ], "service_type_code": null, "service_type": "NORM", "eligibilityStatus ":null, "eligibilityReason ":null, "service_status": "AC", "Service_Id": "4333432424324", "Reserve_status": null, "replicatorUpdateDateTime": "2019-07-26 11:11:49.593", "Reason": null, "service_association_role": "Prime", "plan_name": "Go Business Data SIM $5", "message_bank": "Video MessageBank", "international_roaming": "Access to Use Mobile Overseas", "imsi_number": null, "idd": null, "Eligibility_status": null, "directory_listing": null, "devices": [ { "physicalId": "89610163267640000029", "networkId": "505013485041069", "deviceType": "sim" }, { "physicalId": "89610163267640000029", "networkId": "505013485041069", "deviceType": "sim" } ], "contract_term": "36", "calling_line_identifier": "ON", "accountDetails": { "serviceWithEtcFlag": "N", "creditManagementFlag": "N", "complexBillingIndicator": "N", "accountNumber": "2212356398" } } ], "groupId": "mobileGroup", "disableCheck": null, "checkValue": true } ], "EligibilityStatus": "Eligible", "EligibilityReason": "", "disableCheck": false, "checkValue": true, "checkReserved": false } ], "Error_Description": null, "Error_Code": null, "ADBOR_Id": "0" }, { "siteName": null, "serviceList": [ { "Service_Type": "NORM", "groupType": [ { "transitionId": null, "service": [ { "sim_serial_number": null, "serviceExtensions": [ { "serviceExtensionFrom": "0362835302", "serviceExtensionTo": "0362835329", "eligibilityStatus":null, "eligibilityReason":null }, { "serviceExtensionFrom": "0362835324", "serviceExtensionTo": "03628353100", "eligibilityStatus":null, "eligibilityReason":null } ], "service_type_code": null, "service_type": "NORM", "service_status": "AC", "Service_Id": "2323232388", "Reserve_status": null, "replicatorUpdateDateTime": "2019-07-26 11:11:49.593", "Reason": null, "eligibilityStatus":null, "eligibilityReason":null, "service_association_role": "Prime", "plan_name": "Go Business Data SIM $5", "message_bank": "Video MessageBank", "international_roaming": "Access to Use Mobile Overseas", "imsi_number": null, "idd": null, "Eligibility_status": null, "directory_listing": null, "devices": [ { "physicalId": "89610163267640000029", "networkId": "505013485041069", "deviceType": "sim" }, { "physicalId": "89610163267640000029", "networkId": "505013485041069", "deviceType": "sim" } ], "contract_term": "36", "calling_line_identifier": "ON", "accountDetails": { "serviceWithEtcFlag": "N", "creditManagementFlag": "N", "complexBillingIndicator": "N", "accountNumber": "2212356398" } } ], "groupId": "mobileGroup", "disableCheck": null, "checkValue": true } ], "EligibilityStatus": "Eligible", "EligibilityReason": "", "disableCheck": false, "checkValue": true, "checkReserved": false } ], "Error_Description": null, "Error_Code": null, "ADBOR_Id": "0" } ], "Product_Type": "ISDN30", "eligibilityStatus": null, "eligibilityReason": null, "disableCheck": null, "checkValue": null } ], "Error_Description": "", "Error_Code": "", "Correlation_Id": "5465764671208", "CIDN": "1234567890" }';
        
        Attachment attc = new Attachment();
                attc.Name =  system.label.NgUcTransitionName;
                attc.ParentId = PC.id;
                attc.Body = blob.valueof(jsona);
                insert attc;
                
                TramasElgibilityCallbackResponse__c newResponse = new TramasElgibilityCallbackResponse__c();
                newResponse.name='TMBatchCallback';
                newResponse.TranasactionId__c='f8df162d-60c3-4074-b622-0d5c997c8708';
                newResponse.Type__c='TM2';
                 newResponse.Product_Configuration__c=PC.id;
                  newResponse.Correlation_ID__c='f8df162d-60c3-4074-b622-0d5c997c8708';
                insert  newResponse;        
                
        
        
        String json='{ "_links": [ { "rel": "self", "href": "https://localhost:8080/transition-dm/api/v1/execution/3e878473-61bd-4480-88ac-f935fb213414" }, { "rel": "transition", "href": "https://localhost:8080/transition-dm/api/v1/transition/f8df162d-60c3-4074-b622-0d5c997c8708" } ], "executionId": "3e878473-61bd-4480-88ac-f935fb213414", "transitionId": "f8df162d-60c3-4074-b622-0d5c997c8708", "action": "reserve", "status": "completed", "steps": [ { "name": "discover", "status": "completed", "results": [ ] }, { "name": "validate", "status": "completed", "results": [   ] }, { "name": "reserve", "status": "completed", "results": [ ] } ], "metadata": { "createdAt": "2019-05-03T04:56:57.690Z", "updatedAt": "2019-05-03T04:56:57.690Z", "salesforceId": "00P2O000001A2zP" } }';
        //String json = 'Test';
        Attachment att = new Attachment();
        att.Name =  'ReserveResults.txt';
        att.parentId = newResponse.id;
        att.body = blob.valueof(json);
        att.Description = 'Aniket';
        insert att;
        Test.startTest();
        map<id,attachment> attMap= new map<id,attachment>();
        //Attachment attTest  = testsetUpData();
        //Attachment attTest  = [Select id,Description,body from attachment where name='EligibilityResults.txt' limit 1];
       // system.assert(attTest != null);
            //system.debug('description : ' + attTest.Description);
            //system.debug('Name : ' + attTest.Name);
            //system.debug('Body : ' + attTest.body.toString());
            att.Description = '1234';
            update att;
            attMap.put(att.id,att);
            String attId = att.Id;
            
            List<Id> recordId = new List<Id>();
            recordId.add(att.Id);
            List<Id> parentId = new List<Id>();
            parentId.add(att.parentid);
            List<String> body = new List<String>();
            body.add('{"_links":[{"rel":"self","href":"https://localhost:8080/transition-dm/api/v1/execution/3e878473-61bd-4480-88ac-f935fb213414"},{"rel":"transition","href":"https://localhost:8080/transition-dm/api/v1/transition/f8df162d-60c3-4074-b622-0d5c997c8708"}],"executionId":"3e878473-61bd-4480-88ac-f935fb213414","transitionId":"f8df162d-60c3-4074-b622-0d5c997c8708","action":"reserve","status":"completed","steps":[{"name":"discover","status":"completed","results":[]},{"name":"validate","status":"warning","results":[{"code":"TM3001","description":"validation finished with warnings","_links":[{"rel":"resource","href":"https://localhost:8080/transition-dm/api/v1/resource/ad38c6b2-1211-4ef3-975b-966f25642b14"}]}]},{"name":"reserve","status":"warning","results":[{"code":"TM3001XXX","description":"validation finished with warningsXXX","_links":[{"rel":"resource1","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"},{"rel":"resource2","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"}]},{"code":"TM300YYY","description":"validation finished with warningsXXX","_links":[{"rel":"resource1","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"},{"rel":"resource2","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"}]}]}],"metadata":{"createdAt":"2019-05-03T04:56:57.690Z","updatedAt":"2019-05-03T04:56:57.690Z","salesforceId":"00P2O000001A2zP"}}');
        TramasBatchCallbackResponseUpdate.tramasAttachmentsUpdate(recordId,parentId,body);
        //system.debug('attMap:' + attMap);
            Test.setMock(HttpCalloutMock.class, new TramasBatchCallbackResponseUpdateMock('success_acknowledgement'));
            
        //String serialized = JSON.serialize(attMap);
        //TramasCallbackResponseUpdate.tamasAttachmentsUpdate(serialized,serialized);
        //delete(attTest);
        Attachment_TriggerHandler attTrigger = new Attachment_TriggerHandler();
        attTrigger.bulkBefore();
        attTrigger.beforeInsert(att);
        system.assert(att!=null);
        Test.stopTest();
        List<Attachment> attlist= [select id,body from Attachment where ParentId =:PC.id];
        String attachmentbody=attlist[0].body.toString();
         System.assertEquals(true, attachmentbody.contains('Completed'));//EDGE-156518
    }
     @isTest  Public static void tramasBatchCallbackResponseUpdateWarningReserveSuccess(){
         Account acc = new Account(Name = 'Test Account for CBQ');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.AccountId=acc.Id;
        opp.CloseDate=System.today();
        opp.StageName = 'Develop';
        opp.Product_Type__c = 'Modular';
        opp.Name = 'TestingOpp';
        insert opp;
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket.cscfga__Opportunity__c = opp.id;
        basket.csbb__Account__c = acc.Id;
        basket.Name = 'testBasketforCBQ';
        insert basket;
        
        cscfga__Product_Configuration__c PC = new cscfga__Product_Configuration__c();
        PC.cscfga__Product_Basket__c =basket.id;
        PC.name= 'IP Site';
        PC.cscfga__Description__c = 'Test description';
        insert PC; 
        
        String jsona='{ "Source_System_Id": "Replicator", "site": [{ "siteName": "", "productList": [{ "serviceList": [{ "Service_Type": "voice", "transitionId": "dea02598-8737-4db7-b517-bceff5d1cc39", "service": [{ "User_Type": "", "serviceExtension": [{ "Reason": "", "Reserve_status": "", "Services_To": "0385990499", "Services_From": "0314419400", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "checkValue": false }], "Service_Type": "voice", "Service_Id": "4333432424143", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "", "In_Flight_Flag": null, "Reason": "", "Reserve_status": "", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "", "Association_Role": "AUX" }], "disableCheck": null, "checkValue": false }], "Product_Type": "isdn2", "eligibilityStatus": "Ready for assessment", "eligibilityReason": null, "disableCheck": null, "checkValue": true }], "Error_Description": "", "Error_Code": "", "ADBOR_Id": "50484597" }], "serviceCount": 0, "Error_Description": "", "Error_Code": "", "Correlation_Id": "90baead7919646040e", "CIDN": "3867475038" }';
        
        Attachment attc = new Attachment();
                attc.Name =  'TransitionJSONData.json';
                attc.ParentId = PC.id;
                attc.Body = blob.valueof(jsona);
                insert attc;
                
                TramasElgibilityCallbackResponse__c newResponse = new TramasElgibilityCallbackResponse__c();
                newResponse.name='TMBatchCallback';
                newResponse.TranasactionId__c='f8df162d-60c3-4074-b622-0d5c997c8708';
                newResponse.Type__c='TM1';
                 newResponse.Product_Configuration__c=PC.id;
                newResponse.Correlation_ID__c='f8df162d-60c3-4074-b622-0d5c997c8708';
                insert  newResponse;        
                
        
        
       // String json='{ "_links": [ { "rel": "self", "href": "https://localhost:8080/transition-dm/api/v1/execution/3e878473-61bd-4480-88ac-f935fb213414" }, { "rel": "transition", "href": "https://localhost:8080/transition-dm/api/v1/transition/f8df162d-60c3-4074-b622-0d5c997c8708" } ], "executionId": "3e878473-61bd-4480-88ac-f935fb213414", "transitionId": "f8df162d-60c3-4074-b622-0d5c997c8708", "action": "reserve", "status": "completed", "steps": [ { "name": "discover", "status": "completed", "results": [ ] }, { "name": "validate", "status": "completed", "results": [ ] }, { "name": "reserve", "status": "completed", "results": [ ] } ], "metadata": { "createdAt": "2019-05-03T04:56:57.690Z", "updatedAt": "2019-05-03T04:56:57.690Z", "salesforceId": "00P2O000001A2zP" } }';
        String json = '{"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/executions/ee21c297-9c0d-4d0b-804a-8c1a98889530"},{"rel":"transition","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/transitions/dea02598-8737-4db7-b517-bceff5d1cc39"}],"executionId":"ee21c297-9c0d-4d0b-804a-8c1a98889530","transitionId":"dea02598-8737-4db7-b517-bceff5d1cc39","action":"reserve","status":"completed","steps":[{"name":"create","status":"completed","results":[]},{"name":"discover","status":"completed","results":[]},{"name":"validate","status":"completed","results":[]},{"name":"reserve","status":"warning","results":[{"code":"TM4001","description":"Validation finished with errors","details":"Some/all rules did not pass","_links":[{"rel":"resource","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/7c3b81ad-741a-40d9-83b3-707852cb5a31"}]}]}],"metadata":{"salesforceId":"00P2N000003DUpaUAG","createdAt":"2020-06-15T03:46:22.972Z","updatedAt":"2020-06-15T03:49:40.519Z","correlationId":"1f020fb6-4dddb603-92f1c3aa-cf7589a0","host":"https://slot1.org009.t-dev.telstra.net/v1/tramas","originatingSystem":"Salesforce","stepFunctions":[{"executionArn":"arn:aws:states:ap-southeast-2:450340460944:execution:transition-elrod-tramas-preprod:5780af52-6b7d-4955-bd77-dbccaaf9e9f3","startDate":"2020-06-15T03:46:23.207Z"}],"elrodJobs":[{"jobId":"6def5aca-8b2d-4d65-b8dc-99ebae46c31a","startDate":"2020-06-15T13:46:28+10:00","workflowAction":"discover"},{"jobId":"b6e10163-f4c1-48fc-9062-9eb8e14a5283","startDate":"2020-06-15T13:49:22+10:00","workflowAction":"reserve"}]}}';
        Attachment att = new Attachment();
        att.Name =  'ReserveResults.txt';
        att.parentId = newResponse.id;
        att.body = blob.valueof(json);
        att.Description = 'Aniket';
        insert att;
        Test.startTest();
        map<id,attachment> attMap= new map<id,attachment>();
        //Attachment attTest  = testsetUpData();
        //Attachment attTest  = [Select id,Description,body from attachment where name='EligibilityResults.txt' limit 1];
       // system.assert(attTest != null);
            //system.debug('description : ' + attTest.Description);
            //system.debug('Name : ' + attTest.Name);
            //system.debug('Body : ' + attTest.body.toString());
            att.Description = '1234';
            update att;
            attMap.put(att.id,att);
            String attId = att.Id;
            
            List<Id> recordId = new List<Id>();
            recordId.add(att.Id);
            List<Id> parentId = new List<Id>();
            parentId.add(att.parentid);
            List<String> body = new List<String>();
            body.add('{"_links":[{"rel":"self","href":"https://localhost:8080/transition-dm/api/v1/execution/3e878473-61bd-4480-88ac-f935fb213414"},{"rel":"transition","href":"https://localhost:8080/transition-dm/api/v1/transition/f8df162d-60c3-4074-b622-0d5c997c8708"}],"executionId":"3e878473-61bd-4480-88ac-f935fb213414","transitionId":"f8df162d-60c3-4074-b622-0d5c997c8708","action":"reserve","status":"completed","steps":[{"name":"discover","status":"completed","results":[]},{"name":"validate","status":"warning","results":[{"code":"TM3001","description":"validation finished with warnings","_links":[{"rel":"resource","href":"https://localhost:8080/transition-dm/api/v1/resource/ad38c6b2-1211-4ef3-975b-966f25642b14"}]}]},{"name":"reserve","status":"warning","results":[{"code":"TM3001XXX","description":"validation finished with warningsXXX","_links":[{"rel":"resource1","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"},{"rel":"resource2","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"}]},{"code":"TM300YYY","description":"validation finished with warningsXXX","_links":[{"rel":"resource1","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"},{"rel":"resource2","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"}]}]}],"metadata":{"createdAt":"2019-05-03T04:56:57.690Z","updatedAt":"2019-05-03T04:56:57.690Z","salesforceId":"00P2O000001A2zP"}}');
        TramasBatchCallbackResponseUpdate.tramasAttachmentsUpdate(recordId,parentId,body);
        //system.debug('attMap:' + attMap);
            Test.setMock(HttpCalloutMock.class, new TramasBatchCallbackResponseUpdateMock('Warning_acknowledgement'));
            
        //String serialized = JSON.serialize(attMap);
        //TramasCallbackResponseUpdate.tamasAttachmentsUpdate(serialized,serialized);
        //delete(attTest);
        Attachment_TriggerHandler attTrigger = new Attachment_TriggerHandler();
        attTrigger.bulkBefore();
        attTrigger.beforeInsert(att);
        system.assert(att!=null);
        Test.stopTest();
    }
     @isTest  Public static void tramasBatchCallbackResponseUpdateWarningReserveSuccess2(){
         Account acc = new Account(Name = 'Test Account for CBQ');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.AccountId=acc.Id;
        opp.CloseDate=System.today();
        opp.StageName = 'Develop';
        opp.Product_Type__c = 'Modular';
        opp.Name = 'TestingOpp';
        insert opp;
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket.cscfga__Opportunity__c = opp.id;
        basket.csbb__Account__c = acc.Id;
        basket.Name = 'testBasketforCBQ';
        insert basket;
        
        cscfga__Product_Configuration__c PC = new cscfga__Product_Configuration__c();
        PC.cscfga__Product_Basket__c =basket.id;
        PC.name= 'IP Site';
        PC.cscfga__Description__c = 'Test description';
        insert PC; 
        
        String jsona='{ "Source_System_Id": "Replicator", "site": [{ "siteName": "", "productList": [{ "serviceList": [{ "Service_Type": "voice", "transitionId": "dea02598-8737-4db7-b517-bceff5d1cc39", "service": [{ "User_Type": "", "serviceExtension": [{ "Reason": "", "Reserve_status": "", "Services_To": "0385990499", "Services_From": "0314419400", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "checkValue": false }], "Service_Type": "voice", "Service_Id": "4333432424143", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "", "In_Flight_Flag": null, "Reason": "", "Reserve_status": "", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "", "Association_Role": "AUX" }], "disableCheck": null, "checkValue": false }], "Product_Type": "isdn2", "eligibilityStatus": "Ready for assessment", "eligibilityReason": null, "disableCheck": null, "checkValue": true }], "Error_Description": "", "Error_Code": "", "ADBOR_Id": "50484597" }], "serviceCount": 0, "Error_Description": "", "Error_Code": "", "Correlation_Id": "90baead7919646040e", "CIDN": "3867475038" }';
        
        Attachment attc = new Attachment();
                attc.Name =  'TransitionJSONData.json';
                attc.ParentId = PC.id;
                attc.Body = blob.valueof(jsona);
                insert attc;
                
                TramasElgibilityCallbackResponse__c newResponse = new TramasElgibilityCallbackResponse__c();
                newResponse.name='TMBatchCallback';
                newResponse.TranasactionId__c='f8df162d-60c3-4074-b622-0d5c997c8708';
                newResponse.Type__c='TM1';
                 newResponse.Product_Configuration__c=PC.id;
                newResponse.Correlation_ID__c='f8df162d-60c3-4074-b622-0d5c997c8708';
                insert  newResponse;        
                
        
        
       // String json='{ "_links": [ { "rel": "self", "href": "https://localhost:8080/transition-dm/api/v1/execution/3e878473-61bd-4480-88ac-f935fb213414" }, { "rel": "transition", "href": "https://localhost:8080/transition-dm/api/v1/transition/f8df162d-60c3-4074-b622-0d5c997c8708" } ], "executionId": "3e878473-61bd-4480-88ac-f935fb213414", "transitionId": "f8df162d-60c3-4074-b622-0d5c997c8708", "action": "reserve", "status": "completed", "steps": [ { "name": "discover", "status": "completed", "results": [ ] }, { "name": "validate", "status": "completed", "results": [ ] }, { "name": "reserve", "status": "completed", "results": [ ] } ], "metadata": { "createdAt": "2019-05-03T04:56:57.690Z", "updatedAt": "2019-05-03T04:56:57.690Z", "salesforceId": "00P2O000001A2zP" } }';
        String json = '{"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/executions/ee21c297-9c0d-4d0b-804a-8c1a98889530"},{"rel":"transition","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/transitions/dea02598-8737-4db7-b517-bceff5d1cc39"}],"executionId":"ee21c297-9c0d-4d0b-804a-8c1a98889530","transitionId":"dea02598-8737-4db7-b517-bceff5d1cc39","action":"reserve","status":"completed","steps":[{"name":"create","status":"completed","results":[]},{"name":"discover","status":"completed","results":[]},{"name":"validate","status":"completed","results":[]},{"name":"reserve","status":"warning","results":[{"code":"TM4001","description":"Validation finished with errors","details":"Some/all rules did not pass","_links":[{"rel":"resource","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/7c3b81ad-741a-40d9-83b3-707852cb5a31"}]}]}],"metadata":{"salesforceId":"00P2N000003DUpaUAG","createdAt":"2020-06-15T03:46:22.972Z","updatedAt":"2020-06-15T03:49:40.519Z","correlationId":"1f020fb6-4dddb603-92f1c3aa-cf7589a0","host":"https://slot1.org009.t-dev.telstra.net/v1/tramas","originatingSystem":"Salesforce","stepFunctions":[{"executionArn":"arn:aws:states:ap-southeast-2:450340460944:execution:transition-elrod-tramas-preprod:5780af52-6b7d-4955-bd77-dbccaaf9e9f3","startDate":"2020-06-15T03:46:23.207Z"}],"elrodJobs":[{"jobId":"6def5aca-8b2d-4d65-b8dc-99ebae46c31a","startDate":"2020-06-15T13:46:28+10:00","workflowAction":"discover"},{"jobId":"b6e10163-f4c1-48fc-9062-9eb8e14a5283","startDate":"2020-06-15T13:49:22+10:00","workflowAction":"reserve"}]}}';
        Attachment att = new Attachment();
        att.Name =  'ReserveResults.txt';
        att.parentId = newResponse.id;
        att.body = blob.valueof(json);
        att.Description = 'Aniket';
        insert att;
        Test.startTest();
        map<id,attachment> attMap= new map<id,attachment>();
        //Attachment attTest  = testsetUpData();
        //Attachment attTest  = [Select id,Description,body from attachment where name='EligibilityResults.txt' limit 1];
       // system.assert(attTest != null);
            //system.debug('description : ' + attTest.Description);
            //system.debug('Name : ' + attTest.Name);
            //system.debug('Body : ' + attTest.body.toString());
            att.Description = '1234';
            update att;
            attMap.put(att.id,att);
            String attId = att.Id;
            
            List<Id> recordId = new List<Id>();
            recordId.add(att.Id);
            List<Id> parentId = new List<Id>();
            parentId.add(att.parentid);
            List<String> body = new List<String>();
            body.add('{"_links":[{"rel":"self","href":"https://localhost:8080/transition-dm/api/v1/execution/3e878473-61bd-4480-88ac-f935fb213414"},{"rel":"transition","href":"https://localhost:8080/transition-dm/api/v1/transition/f8df162d-60c3-4074-b622-0d5c997c8708"}],"executionId":"3e878473-61bd-4480-88ac-f935fb213414","transitionId":"f8df162d-60c3-4074-b622-0d5c997c8708","action":"reserve","status":"completed","steps":[{"name":"discover","status":"completed","results":[]},{"name":"validate","status":"warning","results":[{"code":"TM3001","description":"validation finished with warnings","_links":[{"rel":"resource","href":"https://localhost:8080/transition-dm/api/v1/resource/ad38c6b2-1211-4ef3-975b-966f25642b14"}]}]},{"name":"reserve","status":"warning","results":[{"code":"TM3001XXX","description":"validation finished with warningsXXX","_links":[{"rel":"resource1","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"},{"rel":"resource2","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"}]},{"code":"TM300YYY","description":"validation finished with warningsXXX","_links":[{"rel":"resource1","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"},{"rel":"resource2","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"}]}]}],"metadata":{"createdAt":"2019-05-03T04:56:57.690Z","updatedAt":"2019-05-03T04:56:57.690Z","salesforceId":"00P2O000001A2zP"}}');
        TramasBatchCallbackResponseUpdate.tramasAttachmentsUpdate(recordId,parentId,body);
        //system.debug('attMap:' + attMap);
            Test.setMock(HttpCalloutMock.class, new TramasBatchCallbackResponseUpdateMock('Warning_acknowledgement2'));
            
        //String serialized = JSON.serialize(attMap);
        //TramasCallbackResponseUpdate.tamasAttachmentsUpdate(serialized,serialized);
        //delete(attTest);
        Attachment_TriggerHandler attTrigger = new Attachment_TriggerHandler();
        attTrigger.bulkBefore();
        attTrigger.beforeInsert(att);
        system.assert(att!=null);
        Test.stopTest();
    }
     @isTest  Public static void tramasBatchCallbackResponseUpdateBusinessError(){
         Account acc = new Account(Name = 'Test Account for CBQ');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.AccountId=acc.Id;
        opp.CloseDate=System.today();
        opp.StageName = 'Develop';
        opp.Product_Type__c = 'Modular';
        opp.Name = 'TestingOpp';
        insert opp;
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket.cscfga__Opportunity__c = opp.id;
        basket.csbb__Account__c = acc.Id;
        basket.Name = 'testBasketforCBQ';
        insert basket;
        
        cscfga__Product_Configuration__c PC = new cscfga__Product_Configuration__c();
        PC.cscfga__Product_Basket__c =basket.id;
        PC.name= 'IP Site';
        PC.cscfga__Description__c = 'Test description';
        insert PC; 
        
        String jsona='{ "Source_System_Id": "Replicator", "site": [{ "siteName": "", "productList": [{ "serviceList": [{ "Service_Type": "voice", "transitionId": "dea02598-8737-4db7-b517-bceff5d1cc39", "service": [{ "User_Type": "", "serviceExtension": [{ "Reason": "", "Reserve_status": "", "Services_To": "0385990499", "Services_From": "0314419400", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "checkValue": false }], "Service_Type": "voice", "Service_Id": "4333432424143", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "", "In_Flight_Flag": null, "Reason": "", "Reserve_status": "", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "", "Association_Role": "AUX" }], "disableCheck": null, "checkValue": false }], "Product_Type": "isdn2", "eligibilityStatus": "Ready for assessment", "eligibilityReason": null, "disableCheck": null, "checkValue": true }], "Error_Description": "", "Error_Code": "", "ADBOR_Id": "50484597" }], "serviceCount": 0, "Error_Description": "", "Error_Code": "", "Correlation_Id": "90baead7919646040e", "CIDN": "3867475038" }';
        
        Attachment attc = new Attachment();
                attc.Name =  'TransitionJSONData.json';
                attc.ParentId = PC.id;
                attc.Body = blob.valueof(jsona);
                insert attc;
                
                TramasElgibilityCallbackResponse__c newResponse = new TramasElgibilityCallbackResponse__c();
                newResponse.name='TMBatchCallback';
                newResponse.TranasactionId__c='f8df162d-60c3-4074-b622-0d5c997c8708';
                newResponse.Type__c='TM1';
                 newResponse.Product_Configuration__c=PC.id;
                newResponse.Correlation_ID__c='f8df162d-60c3-4074-b622-0d5c997c8708';
                insert  newResponse;        
                
        
        
       // String json='{ "_links": [ { "rel": "self", "href": "https://localhost:8080/transition-dm/api/v1/execution/3e878473-61bd-4480-88ac-f935fb213414" }, { "rel": "transition", "href": "https://localhost:8080/transition-dm/api/v1/transition/f8df162d-60c3-4074-b622-0d5c997c8708" } ], "executionId": "3e878473-61bd-4480-88ac-f935fb213414", "transitionId": "f8df162d-60c3-4074-b622-0d5c997c8708", "action": "reserve", "status": "completed", "steps": [ { "name": "discover", "status": "completed", "results": [ ] }, { "name": "validate", "status": "completed", "results": [ ] }, { "name": "reserve", "status": "completed", "results": [ ] } ], "metadata": { "createdAt": "2019-05-03T04:56:57.690Z", "updatedAt": "2019-05-03T04:56:57.690Z", "salesforceId": "00P2O000001A2zP" } }';
        String json = '{"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/executions/ee21c297-9c0d-4d0b-804a-8c1a98889530"},{"rel":"transition","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/transitions/dea02598-8737-4db7-b517-bceff5d1cc39"}],"executionId":"ee21c297-9c0d-4d0b-804a-8c1a98889530","transitionId":"dea02598-8737-4db7-b517-bceff5d1cc39","action":"reserve","status":"completed","steps":[{"name":"create","status":"completed","results":[]},{"name":"discover","status":"completed","results":[]},{"name":"validate","status":"completed","results":[]},{"name":"reserve","status":"warning","results":[{"code":"TM4001","description":"Validation finished with errors","details":"Some/all rules did not pass","_links":[{"rel":"resource","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/7c3b81ad-741a-40d9-83b3-707852cb5a31"}]}]}],"metadata":{"salesforceId":"00P2N000003DUpaUAG","createdAt":"2020-06-15T03:46:22.972Z","updatedAt":"2020-06-15T03:49:40.519Z","correlationId":"1f020fb6-4dddb603-92f1c3aa-cf7589a0","host":"https://slot1.org009.t-dev.telstra.net/v1/tramas","originatingSystem":"Salesforce","stepFunctions":[{"executionArn":"arn:aws:states:ap-southeast-2:450340460944:execution:transition-elrod-tramas-preprod:5780af52-6b7d-4955-bd77-dbccaaf9e9f3","startDate":"2020-06-15T03:46:23.207Z"}],"elrodJobs":[{"jobId":"6def5aca-8b2d-4d65-b8dc-99ebae46c31a","startDate":"2020-06-15T13:46:28+10:00","workflowAction":"discover"},{"jobId":"b6e10163-f4c1-48fc-9062-9eb8e14a5283","startDate":"2020-06-15T13:49:22+10:00","workflowAction":"reserve"}]}}';
        Attachment att = new Attachment();
        att.Name =  'ReserveResults.txt';
        att.parentId = newResponse.id;
        att.body = blob.valueof(json);
        att.Description = 'Aniket';
        insert att;
        Test.startTest();
        map<id,attachment> attMap= new map<id,attachment>();
        //Attachment attTest  = testsetUpData();
        //Attachment attTest  = [Select id,Description,body from attachment where name='EligibilityResults.txt' limit 1];
       // system.assert(attTest != null);
            //system.debug('description : ' + attTest.Description);
            //system.debug('Name : ' + attTest.Name);
            //system.debug('Body : ' + attTest.body.toString());
            att.Description = '1234';
            update att;
            attMap.put(att.id,att);
            String attId = att.Id;
            
            List<Id> recordId = new List<Id>();
            recordId.add(att.Id);
            List<Id> parentId = new List<Id>();
            parentId.add(att.parentid);
            List<String> body = new List<String>();
            body.add('{"_links":[{"rel":"self","href":"https://localhost:8080/transition-dm/api/v1/execution/3e878473-61bd-4480-88ac-f935fb213414"},{"rel":"transition","href":"https://localhost:8080/transition-dm/api/v1/transition/f8df162d-60c3-4074-b622-0d5c997c8708"}],"executionId":"3e878473-61bd-4480-88ac-f935fb213414","transitionId":"f8df162d-60c3-4074-b622-0d5c997c8708","action":"reserve","status":"completed","steps":[{"name":"discover","status":"completed","results":[]},{"name":"validate","status":"warning","results":[{"code":"TM3001","description":"validation finished with warnings","_links":[{"rel":"resource","href":"https://localhost:8080/transition-dm/api/v1/resource/ad38c6b2-1211-4ef3-975b-966f25642b14"}]}]},{"name":"reserve","status":"warning","results":[{"code":"TM3001XXX","description":"validation finished with warningsXXX","_links":[{"rel":"resource1","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"},{"rel":"resource2","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"}]},{"code":"TM300YYY","description":"validation finished with warningsXXX","_links":[{"rel":"resource1","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"},{"rel":"resource2","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"}]}]}],"metadata":{"createdAt":"2019-05-03T04:56:57.690Z","updatedAt":"2019-05-03T04:56:57.690Z","salesforceId":"00P2O000001A2zP"}}');
        TramasBatchCallbackResponseUpdate.tramasAttachmentsUpdate(recordId,parentId,body);
        //system.debug('attMap:' + attMap);
            Test.setMock(HttpCalloutMock.class, new TramasBatchCallbackResponseUpdateMock('Business_Error'));
            
        //String serialized = JSON.serialize(attMap);
        //TramasCallbackResponseUpdate.tamasAttachmentsUpdate(serialized,serialized);
        //delete(attTest);
        Attachment_TriggerHandler attTrigger = new Attachment_TriggerHandler();
        attTrigger.bulkBefore();
        attTrigger.beforeInsert(att);
        system.assert(att!=null);
        Test.stopTest();
    }
     @isTest  Public static void tramasBatchCallbackResponseUpdateFailedReserveSuccess(){
         Account acc = new Account(Name = 'Test Account for CBQ');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.AccountId=acc.Id;
        opp.CloseDate=System.today();
        opp.StageName = 'Develop';
        opp.Product_Type__c = 'Modular';
        opp.Name = 'TestingOpp';
        insert opp;
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket.cscfga__Opportunity__c = opp.id;
        basket.csbb__Account__c = acc.Id;
        basket.Name = 'testBasketforCBQ';
        insert basket;
        
        cscfga__Product_Configuration__c PC = new cscfga__Product_Configuration__c();
        PC.cscfga__Product_Basket__c =basket.id;
        PC.name= 'IP Site';
        PC.cscfga__Description__c = 'Test description';
        insert PC; 
        
        String jsona='{ "Source_System_Id": "Replicator", "site": [{ "siteName": "", "productList": [{ "serviceList": [{ "Service_Type": "voice", "transitionId": "dea02598-8737-4db7-b517-bceff5d1cc39", "service": [{ "User_Type": "", "serviceExtension": [{ "Reason": "", "Reserve_status": "", "Services_To": "0385990499", "Services_From": "0314419400", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "checkValue": false }], "Service_Type": "voice", "Service_Id": "4333432424143", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "", "In_Flight_Flag": null, "Reason": "", "Reserve_status": "", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "", "Association_Role": "AUX" }], "disableCheck": null, "checkValue": false }], "Product_Type": "isdn2", "eligibilityStatus": "Ready for assessment", "eligibilityReason": null, "disableCheck": null, "checkValue": true }], "Error_Description": "", "Error_Code": "", "ADBOR_Id": "50484597" }], "serviceCount": 0, "Error_Description": "", "Error_Code": "", "Correlation_Id": "90baead7919646040e", "CIDN": "3867475038" }';
        
        Attachment attc = new Attachment();
                attc.Name =  'TransitionJSONData.json';
                attc.ParentId = PC.id;
                attc.Body = blob.valueof(jsona);
                insert attc;
                
                TramasElgibilityCallbackResponse__c newResponse = new TramasElgibilityCallbackResponse__c();
                newResponse.name='TMBatchCallback';
                newResponse.TranasactionId__c='f8df162d-60c3-4074-b622-0d5c997c8708';
                newResponse.Type__c='TM1';
                 newResponse.Product_Configuration__c=PC.id;
                newResponse.Correlation_ID__c='f8df162d-60c3-4074-b622-0d5c997c8708';
                insert  newResponse;        
                
        
        
       // String json='{ "_links": [ { "rel": "self", "href": "https://localhost:8080/transition-dm/api/v1/execution/3e878473-61bd-4480-88ac-f935fb213414" }, { "rel": "transition", "href": "https://localhost:8080/transition-dm/api/v1/transition/f8df162d-60c3-4074-b622-0d5c997c8708" } ], "executionId": "3e878473-61bd-4480-88ac-f935fb213414", "transitionId": "f8df162d-60c3-4074-b622-0d5c997c8708", "action": "reserve", "status": "completed", "steps": [ { "name": "discover", "status": "completed", "results": [ ] }, { "name": "validate", "status": "completed", "results": [ ] }, { "name": "reserve", "status": "completed", "results": [ ] } ], "metadata": { "createdAt": "2019-05-03T04:56:57.690Z", "updatedAt": "2019-05-03T04:56:57.690Z", "salesforceId": "00P2O000001A2zP" } }';
        String json = '{"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/executions/ee21c297-9c0d-4d0b-804a-8c1a98889530"},{"rel":"transition","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/transitions/dea02598-8737-4db7-b517-bceff5d1cc39"}],"executionId":"ee21c297-9c0d-4d0b-804a-8c1a98889530","transitionId":"dea02598-8737-4db7-b517-bceff5d1cc39","action":"reserve","status":"completed","steps":[{"name":"create","status":"completed","results":[]},{"name":"discover","status":"completed","results":[]},{"name":"validate","status":"completed","results":[]},{"name":"reserve","status":"warning","results":[{"code":"TM4001","description":"Validation finished with errors","details":"Some/all rules did not pass","_links":[{"rel":"resource","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/7c3b81ad-741a-40d9-83b3-707852cb5a31"}]}]}],"metadata":{"salesforceId":"00P2N000003DUpaUAG","createdAt":"2020-06-15T03:46:22.972Z","updatedAt":"2020-06-15T03:49:40.519Z","correlationId":"1f020fb6-4dddb603-92f1c3aa-cf7589a0","host":"https://slot1.org009.t-dev.telstra.net/v1/tramas","originatingSystem":"Salesforce","stepFunctions":[{"executionArn":"arn:aws:states:ap-southeast-2:450340460944:execution:transition-elrod-tramas-preprod:5780af52-6b7d-4955-bd77-dbccaaf9e9f3","startDate":"2020-06-15T03:46:23.207Z"}],"elrodJobs":[{"jobId":"6def5aca-8b2d-4d65-b8dc-99ebae46c31a","startDate":"2020-06-15T13:46:28+10:00","workflowAction":"discover"},{"jobId":"b6e10163-f4c1-48fc-9062-9eb8e14a5283","startDate":"2020-06-15T13:49:22+10:00","workflowAction":"reserve"}]}}';
        Attachment att = new Attachment();
        att.Name =  'ReserveResults.txt';
        att.parentId = newResponse.id;
        att.body = blob.valueof(json);
        att.Description = 'Aniket';
        insert att;
        Test.startTest();
        map<id,attachment> attMap= new map<id,attachment>();
        //Attachment attTest  = testsetUpData();
        //Attachment attTest  = [Select id,Description,body from attachment where name='EligibilityResults.txt' limit 1];
       // system.assert(attTest != null);
            //system.debug('description : ' + attTest.Description);
            //system.debug('Name : ' + attTest.Name);
            //system.debug('Body : ' + attTest.body.toString());
            att.Description = '1234';
            update att;
            attMap.put(att.id,att);
            String attId = att.Id;
            
            List<Id> recordId = new List<Id>();
            recordId.add(att.Id);
            List<Id> parentId = new List<Id>();
            parentId.add(att.parentid);
            List<String> body = new List<String>();
            body.add('{"_links":[{"rel":"self","href":"https://localhost:8080/transition-dm/api/v1/execution/3e878473-61bd-4480-88ac-f935fb213414"},{"rel":"transition","href":"https://localhost:8080/transition-dm/api/v1/transition/f8df162d-60c3-4074-b622-0d5c997c8708"}],"executionId":"3e878473-61bd-4480-88ac-f935fb213414","transitionId":"f8df162d-60c3-4074-b622-0d5c997c8708","action":"reserve","status":"completed","steps":[{"name":"discover","status":"completed","results":[]},{"name":"validate","status":"warning","results":[{"code":"TM3001","description":"validation finished with warnings","_links":[{"rel":"resource","href":"https://localhost:8080/transition-dm/api/v1/resource/ad38c6b2-1211-4ef3-975b-966f25642b14"}]}]},{"name":"reserve","status":"warning","results":[{"code":"TM3001XXX","description":"validation finished with warningsXXX","_links":[{"rel":"resource1","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"},{"rel":"resource2","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"}]},{"code":"TM300YYY","description":"validation finished with warningsXXX","_links":[{"rel":"resource1","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"},{"rel":"resource2","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"}]}]}],"metadata":{"createdAt":"2019-05-03T04:56:57.690Z","updatedAt":"2019-05-03T04:56:57.690Z","salesforceId":"00P2O000001A2zP"}}');
        TramasBatchCallbackResponseUpdate.tramasAttachmentsUpdate(recordId,parentId,body);
        //system.debug('attMap:' + attMap);
            Test.setMock(HttpCalloutMock.class, new TramasBatchCallbackResponseUpdateMock('failed_acknowledgement'));
            
        //String serialized = JSON.serialize(attMap);
        //TramasCallbackResponseUpdate.tamasAttachmentsUpdate(serialized,serialized);
        //delete(attTest);
        Attachment_TriggerHandler attTrigger = new Attachment_TriggerHandler();
        attTrigger.bulkBefore();
        attTrigger.beforeInsert(att);
        system.assert(att!=null);
        Test.stopTest();
    }
    //EDGE-217096 :TM1 callback Failure response update
    @isTest
Public static void tramasBatchCallbackResponseFailure(){
         Account acc = new Account(Name = 'Test Account for CBQ');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.AccountId=acc.Id;
        opp.CloseDate=System.today();
        opp.StageName = 'Develop';
        opp.Product_Type__c = 'Modular';
        opp.Name = 'TestingOpp';
        insert opp;
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket.cscfga__Opportunity__c = opp.id;
        basket.csbb__Account__c = acc.Id;
        basket.Name = 'testBasketforCBQ';
        insert basket;
        
        cscfga__Product_Configuration__c PC = new cscfga__Product_Configuration__c();
        PC.cscfga__Product_Basket__c =basket.id;
        PC.name= 'IP Site';
        PC.cscfga__Description__c = 'Test description';
        insert PC; 
        
        String jsona='{ "Source_System_Id": "Replicator", "site": [{ "siteName": "", "productList": [{ "serviceList": [{ "Service_Type": "voice", "transitionId": "f8df162d-60c3-4074-b622-0d5c997c8708", "service": [{ "User_Type": "", "serviceExtension": [{ "Reason": "", "Reserve_status": "", "Services_To": "0385990499", "Services_From": "0314419400", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "checkValue": false }], "Service_Type": "voice", "Service_Id": "0314419400", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "", "In_Flight_Flag": null, "Reason": "", "Reserve_status": "", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "", "Association_Role": "AUX" }], "disableCheck": null, "checkValue": false }], "Product_Type": "isdn2", "eligibilityStatus": "Ready for assessment", "eligibilityReason": null, "disableCheck": null, "checkValue": true }], "Error_Description": "", "Error_Code": "", "ADBOR_Id": "50484597" }], "serviceCount": 0, "Error_Description": "", "Error_Code": "", "Correlation_Id": "90baead7919646040e", "CIDN": "3867475038" }';
        
        Attachment attc = new Attachment();
                attc.Name =  'TransitionJSONData.json';
                attc.ParentId = PC.id;
                attc.Body = blob.valueof(jsona);
                insert attc;
                
        TramasElgibilityCallbackResponse__c newResponse = new TramasElgibilityCallbackResponse__c();
        newResponse.name='TMBatchCallback';
        newResponse.TranasactionId__c='f8df162d-60c3-4074-b622-0d5c997c8708';
        newResponse.Type__c='TM1';
        newResponse.Product_Configuration__c=PC.id;
        newResponse.Correlation_ID__c='f8df162d-60c3-4074-b622-0d5c997c8708';
        insert  newResponse;        
                
        
        
        String json='{"_links":[{"rel":"self","href":"https://localhost:8080/transition-dm/api/v1/execution/3e878473-61bd-4480-88ac-f935fb213414"},{"rel":"transition","href":"https://localhost:8080/transition-dm/api/v1/transition/f8df162d-60c3-4074-b622-0d5c997c8708"}],"executionId":"3e878473-61bd-4480-88ac-f935fb213414","transitionId":"f8df162d-60c3-4074-b622-0d5c997c8708","action":"reserve","status":"completed","steps":[{"name":"discover","status":"completed","results":[]},{"name":"validate","status":"warning","results":[{"code":"TM3001","description":"validation finished with warnings","_links":[{"rel":"resource","href":"https://localhost:8080/transition-dm/api/v1/resource/ad38c6b2-1211-4ef3-975b-966f25642b14"}]}]},{"name":"reserve","status":"warning","results":[{"code":"TM3001XXX","description":"validation finished with warningsXXX","_links":[{"rel":"resource1","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/d1e01de9-613c-4ac0-a673-45d252bc2f13"},{"rel":"resource2","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/d1e01de9-613c-4ac0-a673-45d252bc2f13"}]}]}],"metadata":{"createdAt":"2019-05-03T04:56:57.690Z","updatedAt":"2019-05-03T04:56:57.690Z","salesforceId":"00P2O000001A2zP"}}';
        //String json = 'Test';
        Attachment att = new Attachment();
        att.Name =  'EligibilityResults.txt';
        att.parentId = newResponse.id;
        att.body = blob.valueof(json);
        att.Description = 'Aniket';
        insert att;
        Test.startTest();
        map<id,attachment> attMap= new map<id,attachment>();
            att.Description = '1234';
            update att;
            attMap.put(att.id,att);
            String attId = att.Id;
            
            List<Id> recordId = new List<Id>();
            recordId.add(att.Id);
            List<Id> parentId = new List<Id>();
            parentId.add(att.parentid);
            List<String> body = new List<String>();
            body.add('{ "_links": [ { "rel": "self", "href": "https://localhost:8080/transition-dm/api/v1/execution/3e878473-61bd-4480-88ac-f935fb213414" }, { "rel": "transition", "href": "https://localhost:8080/transition-dm/api/v1/transition/f8df162d-60c3-4074-b622-0d5c997c8708" } ], "executionId": "3e878473-61bd-4480-88ac-f935fb213414", "transitionId": "f8df162d-60c3-4074-b622-0d5c997c8708", "action": "validate", "status": "completed", "steps": [ { "name": "discover", "status": "completed", "results": [ ] }, { "name": "validate", "status": "warning", "results": [ { "code": "TM3001", "description": "validation finished with warnings", "_links": [ { "rel": "resource", "href": "https://localhost:8080/transition-dm/api/v1/resource/ad38c6b2-1211-4ef3-975b-966f25642b14" } ] } ] }, { "name": "reserve", "status": "warning", "results": [ { "code": "TM3001XXX", "description": "validation finished with warningsXXX", "_links": [ { "rel": "resource1", "href": "https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008" }, { "rel": "resource2", "href": "https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008" } ] }, { "code": "TM300YYY", "description": "validation finished with warningsXXX", "_links": [ { "rel": "resource1", "href": "https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008" }, { "rel": "resource2", "href": "https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008" } ] } ] } ], "metadata": { "createdAt": "2019-05-03T04:56:57.690Z", "updatedAt": "2019-05-03T04:56:57.690Z", "salesforceId": "00P2O000001A2zP" } }');
           TramasBatchCallbackResponseUpdate.tramasAttachmentsUpdate(recordId,parentId,body);
            Test.setMock(HttpCalloutMock.class, new TramasBatchCallbackResponseUpdateMock('failed_callback'));
    		TramasElgibilityCallbackResponse__c failureResponse=[SELECT id, Eligibility_Criteria__c FROM TramasElgibilityCallbackResponse__c WHERE Product_Configuration__c=:PC.id limit 1];
   			 system.assert(failureResponse !=null);
        Test.stopTest();
    }
    @isTest
Public static void tramasBatchCallbackFailed404(){
         Account acc = new Account(Name = 'Test Account for CBQ');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.AccountId=acc.Id;
        opp.CloseDate=System.today();
        opp.StageName = 'Develop';
        opp.Product_Type__c = 'Modular';
        opp.Name = 'TestingOpp';
        insert opp;
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket.cscfga__Opportunity__c = opp.id;
        basket.csbb__Account__c = acc.Id;
        basket.Name = 'testBasketforCBQ';
        insert basket;
        
        cscfga__Product_Configuration__c PC = new cscfga__Product_Configuration__c();
        PC.cscfga__Product_Basket__c =basket.id;
        PC.name= 'IP Site';
        PC.cscfga__Description__c = 'Test description';
        insert PC; 
        
		String jsona='{"Source_System_Id":"Replicator","serviceCount":0,"productList":[{"site":[{"siteName":null,"serviceList":[{"Service_Type":"NORM","groupType":[{"transitionId":"f8df162d-60c3-4074-b622-0d5c997c8708","service":[{"sim_serial_number":null,"serviceExtensions":[{"serviceExtensionFrom":"0362835301","serviceExtensionTo":"0362835320","eligibilityStatus":null,"eligibilityReason":null},{"serviceExtensionFrom":"0362835321","serviceExtensionTo":"0362835399","eligibilityStatus":null,"eligibilityReason":null}],"service_type_code":null,"service_type":"NORM","eligibilityStatus ":null,"eligibilityReason ":null,"service_status":"AC","Service_Id":"4333432424324","Reserve_status":null,"replicatorUpdateDateTime":"2019-07-26 11:11:49.593","Reason":null,"service_association_role":"Prime","plan_name":"Go Business Data SIM $5","message_bank":"Video MessageBank","international_roaming":"Access to Use Mobile Overseas","imsi_number":null,"idd":null,"Eligibility_status":null,"directory_listing":null,"devices":[{"physicalId":"89610163267640000029","networkId":"505013485041069","deviceType":"sim"},{"physicalId":"89610163267640000029","networkId":"505013485041069","deviceType":"sim"}],"contract_term":"36","calling_line_identifier":"ON","accountDetails":{"serviceWithEtcFlag":"N","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"2212356398"}}],"groupId":"mobileGroup","disableCheck":null,"checkValue":true}],"EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":false,"checkValue":true,"checkReserved":false}],"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0"},{"siteName":null,"serviceList":[{"Service_Type":"NORM","groupType":[{"transitionId":null,"service":[{"sim_serial_number":null,"serviceExtensions":[{"serviceExtensionFrom":"0362835302","serviceExtensionTo":"0362835329","eligibilityStatus":null,"eligibilityReason":null},{"serviceExtensionFrom":"0362835324","serviceExtensionTo":"03628353100","eligibilityStatus":null,"eligibilityReason":null}],"service_type_code":null,"service_type":"NORM","service_status":"AC","Service_Id":"2323232388","Reserve_status":null,"replicatorUpdateDateTime":"2019-07-26 11:11:49.593","Reason":null,"eligibilityStatus":null,"eligibilityReason":null,"service_association_role":"Prime","plan_name":"Go Business Data SIM $5","message_bank":"Video MessageBank","international_roaming":"Access to Use Mobile Overseas","imsi_number":null,"idd":null,"Eligibility_status":null,"directory_listing":null,"devices":[{"physicalId":"89610163267640000029","networkId":"505013485041069","deviceType":"sim"},{"physicalId":"89610163267640000029","networkId":"505013485041069","deviceType":"sim"}],"contract_term":"36","calling_line_identifier":"ON","accountDetails":{"serviceWithEtcFlag":"N","creditManagementFlag":"N","complexBillingIndicator":"N","accountNumber":"2212356398"}}],"groupId":"mobileGroup","disableCheck":null,"checkValue":true}],"EligibilityStatus":"Eligible","EligibilityReason":"","disableCheck":false,"checkValue":true,"checkReserved":false}],"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0"}],"Product_Type":"ISDN30","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":null}],"Error_Description":"","Error_Code":"","Correlation_Id":"5465764671208","CIDN":"1234567890"}';       
        Attachment attc = new Attachment();
                attc.Name =  'TransitionDataNguc.json';
                attc.ParentId = PC.id;
                attc.Body = blob.valueof(jsona);
                insert attc;
                
        TramasElgibilityCallbackResponse__c newResponse = new TramasElgibilityCallbackResponse__c();
        newResponse.name='TMBatchCallback';
        newResponse.TranasactionId__c='f8df162d-60c3-4074-b622-0d5c997c8708';
        newResponse.Type__c='TM1';
        newResponse.Product_Configuration__c=PC.id;
        newResponse.Correlation_ID__c='f8df162d-60c3-4074-b622-0d5c997c8708';
        insert  newResponse;        
                
        
        
        String json='{"_links":[{"rel":"self","href":"https://localhost:8080/transition-dm/api/v1/execution/3e878473-61bd-4480-88ac-f935fb213414"},{"rel":"transition","href":"https://localhost:8080/transition-dm/api/v1/transition/f8df162d-60c3-4074-b622-0d5c997c8708"}],"executionId":"3e878473-61bd-4480-88ac-f935fb213414","transitionId":"f8df162d-60c3-4074-b622-0d5c997c8708","action":"reserve","status":"completed","steps":[{"name":"discover","status":"completed","results":[]},{"name":"validate","status":"warning","results":[{"code":"TM3001","description":"validation finished with warnings","_links":[{"rel":"resource","href":"https://localhost:8080/transition-dm/api/v1/resource/ad38c6b2-1211-4ef3-975b-966f25642b14"}]}]},{"name":"reserve","status":"warning","results":[{"code":"TM3001XXX","description":"validation finished with warningsXXX","_links":[{"rel":"resource1","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/d1e01de9-613c-4ac0-a673-45d252bc2f13"},{"rel":"resource2","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/d1e01de9-613c-4ac0-a673-45d252bc2f13"}]}]}],"metadata":{"createdAt":"2019-05-03T04:56:57.690Z","updatedAt":"2019-05-03T04:56:57.690Z","salesforceId":"00P2O000001A2zP"}}';
        //String json = 'Test';
        Attachment att = new Attachment();
        att.Name =  'EligibilityResults.txt';
        att.parentId = newResponse.id;
        att.body = blob.valueof(json);
        att.Description = 'Aniket';
        insert att;
        Test.startTest();
        map<id,attachment> attMap= new map<id,attachment>();
            att.Description = '1234';
            update att;
            attMap.put(att.id,att);
            String attId = att.Id;
            
            List<Id> recordId = new List<Id>();
            recordId.add(att.Id);
            List<Id> parentId = new List<Id>();
            parentId.add(att.parentid);
            List<String> body = new List<String>();
            body.add('{ "_links": [ { "rel": "self", "href": "https://localhost:8080/transition-dm/api/v1/execution/3e878473-61bd-4480-88ac-f935fb213414" }, { "rel": "transition", "href": "https://localhost:8080/transition-dm/api/v1/transition/f8df162d-60c3-4074-b622-0d5c997c8708" } ], "executionId": "3e878473-61bd-4480-88ac-f935fb213414", "transitionId": "f8df162d-60c3-4074-b622-0d5c997c8708", "action": "validate", "status": "completed", "steps": [ { "name": "discover", "status": "completed", "results": [ ] }, { "name": "validate", "status": "warning", "results": [ { "code": "TM3001", "description": "validation finished with warnings", "_links": [ { "rel": "resource", "href": "https://localhost:8080/transition-dm/api/v1/resource/ad38c6b2-1211-4ef3-975b-966f25642b14" } ] } ] }, { "name": "reserve", "status": "warning", "results": [ { "code": "TM3001XXX", "description": "validation finished with warningsXXX", "_links": [ { "rel": "resource1", "href": "https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008" }, { "rel": "resource2", "href": "https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008" } ] }, { "code": "TM300YYY", "description": "validation finished with warningsXXX", "_links": [ { "rel": "resource1", "href": "https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008" }, { "rel": "resource2", "href": "https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008" } ] } ] } ], "metadata": { "createdAt": "2019-05-03T04:56:57.690Z", "updatedAt": "2019-05-03T04:56:57.690Z", "salesforceId": "00P2O000001A2zP" } }');
           TramasBatchCallbackResponseUpdate.tramasAttachmentsUpdate(recordId,parentId,body);
            Test.setMock(HttpCalloutMock.class, new TramasBatchCallbackResponseUpdateMock('failed_callback404'));
        Test.stopTest();
    }
    
}