/****/
@isTest
public class AttachmentTriggerHelperTest {
    static testMethod void testPerformQuoteCreationAndAttachmentDeletion(){
        Account acc = AccountTestFactory.buildAccount('Test Name');
        acc.CIDN__c = 'Test Trans';
        acc.Customer_Status__c = 'ACTIVE';
        insert acc;
        Allow_For_Attachment__c attach = new Allow_For_Attachment__c(Name='Quote');
        insert attach;
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.Name = 'Test Opp';
        opp.StageName = 'Define';
        opp.CloseDate = date.ValueOf('2018-01-31');
        insert opp;
        
        
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(
            Name = 'Test Account Opportunity Basket',
            OwnerId = UserInfo.getUserId(),
            cscfga__Opportunity__c = opp.Id,
            csbb__Account__c = acc.Id,
            csordtelcoa__Basket_Stage__c = 'Enriched'
        );
        insert basket;
        
        Quote quote = new Quote();
        quote.Name = 'Test';
        quote.OpportunityId = opp.Id;
        quote.Product_Basket__c = basket.id;
        insert quote;
        
        Attachment attachmentForSuccess = new Attachment();
        attachmentForSuccess.Body = Blob.valueOf('Unit Test Attachment Body');
        attachmentForSuccess.ParentId = quote.Id;
        attachmentForSuccess.Name = 'Test Attachment';
        insert attachmentForSuccess;
        
        Map<Id, Attachment> attachmentMap = new Map<Id, Attachment>();
        attachmentMap.put(attachmentForSuccess.Id, attachmentForSuccess);
        
        //AttachmentTriggerHelper triggerHelper = new AttachmentTriggerHelper();
        //triggerHelper.performQuoteCreationAndAttachmentDeletion(attachmentMap);
        
        List<QuoteDocument> quoteDocs = [SELECT name, id, QuoteId FROM QuoteDocument WHERE QuoteId =: quote.Id];
        if(!quoteDocs.isEmpty()){
            
            system.assert(quoteDocs[0].Name != null);
            
            List<Attachment> alist = [SELECT id FROM attachment WHERE ParentID =:quoteDocs[0].QuoteId];
            system.assert(alist.isEmpty());
        }
    }
    //Added new testvmethod for EDGE-176683--Start here
    static testMethod void testPerformQuoteCreationAndAttachmentDeletionForFrameAgreement(){
        Account acc = AccountTestFactory.buildAccount('Test Name');
        acc.CIDN__c = 'Test Trans';
        acc.Customer_Status__c = 'ACTIVE';
        insert acc;
        Allow_For_Attachment__c attach = new Allow_For_Attachment__c(Name='Quote');
        insert attach;
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.Name = 'Test Opp';
        opp.StageName = 'Define';
        opp.CloseDate = date.ValueOf('2018-01-31');
        insert opp;
        
        Delegated_Pricing_Request__c dpr= new Delegated_Pricing_Request__c();
        dpr.Opportunity__c=opp.id;
        dpr.Commitment_Frequency__c='Quarterly';
        insert dpr;
        
        csconta__Frame_Agreement__c framAg= new csconta__Frame_Agreement__c();
        framAg.csconta__Account__c=acc.id;
        framAg.Opportunity__c=opp.id;
        framAg.Delegated_Pricing_Request__c=dpr.id;
        framAg.csconta__Agreement_Name__c='AGR-TEST';
        insert framAg;
        
        Quote quote = new Quote();
        quote.Name = 'Test';
        quote.OpportunityId = opp.Id;
        quote.Frame_Agreement__c = framAg.id;
        insert quote;
        
        Attachment attachmentForSuccess = new Attachment();
        attachmentForSuccess.Body = Blob.valueOf('Unit Test Attachment Body');
        attachmentForSuccess.ParentId = quote.Id;
        attachmentForSuccess.Name = 'Test Attachment';
        insert attachmentForSuccess;
        
        Map<Id, Attachment> attachmentMap = new Map<Id, Attachment>();
        attachmentMap.put(attachmentForSuccess.Id, attachmentForSuccess);
        
        //AttachmentTriggerHelper triggerHelper = new AttachmentTriggerHelper();
        //triggerHelper.performQuoteCreationAndAttachmentDeletion(attachmentMap);
        
        List<QuoteDocument> quoteDocs = [SELECT name, id, QuoteId FROM QuoteDocument WHERE QuoteId =: quote.Id];
        if(!quoteDocs.isEmpty()){
            
            system.assert(quoteDocs[0].Name != null);
            system.assertEquals(framAg.id,quote.Frame_Agreement__c);//Assert added for EDGE-176683
            
            List<Attachment> alist = [SELECT id FROM attachment WHERE ParentID =:quoteDocs[0].QuoteId];
            system.assert(alist.isEmpty());
        }
    }
    //Added new testvmethod for EDGE-176683--End here
    //Start EDGE-94797
    static attachment testsetUpData(){
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
        PC.name='Mobility';
        PC.Type__c='New';
        insert PC;
        String jsona='{ "CIDN" : "6898327073", "Correlation_Id" : "abcd_1234", "Error_Code" : "", "Error_Description" : "", "productList" : [ { "checkValue" : null, "disableCheck" : null, "eligibilityReason" : null, "eligibilityStatus" : null, "Product_Type" : "Mobile PostPaid HandHeld", "site" : [ { "ADBOR_Id" : "0999", "Error_Code" : null, "Error_Description" : null, "serviceList" : [ { "checkReserved" : false, "checkValue" : true, "disableCheck" : null, "groupType" : [ { "groupId" : "mobileGroup","checkValue" : true, "service" : [ { "calling_line_identifier" : "off", "contract_term" : "12", "directory_listing" : null, "Eligibility_status" : null, "idd" : "BFIDD100 | Bus Fleet Plus IDD $100", "imsi_number" : "505013438393119", "international_roaming" : "EFPAIR01| EFP Intl. Roaming $0 $50 Pack", "message_bank" : "3GPPMSGK | 3G Pre-Paid Video Message Bank", "plan_name" : "3OB*049 | 3G Cap 49 Business Mobile Plan", "Reason" : "", "Reserve_status" : null, "Service_Id" : "0429701813", "service_status" : "AC", "service_type" : null, "service_type_code" : "NORM", "sim_serial_number" : "89610179078138000029" } ], "transitionId" : "f8df162d-60c3-4074-b622-0d5c997c8708" } ], "Service_Type" : null } ], "siteName" : null } ] } ], "serviceCount" : 0, "Source_System_Id" : "Replicator" }';
        Attachment attc = new Attachment();
        attc.Name =  system.label.MobileTransitionName;
        attc.ParentId = PC.id;
        attc.Body = blob.valueof(jsona);
        insert attc;
        MobileTramasElgibility__c mobileTramas = new MobileTramasElgibility__c(Name = 'Test Tramas',Product_Configuration__c=PC.id,Type__c='TM1');
        insert mobileTramas;
        
        String json='{"_links":[{"rel":"self","href":"https://localhost:8080/transition-dm/api/v1/execution/3e878473-61bd-4480-88ac-f935fb213414"},{"rel":"transition","href":"https://localhost:8080/transition-dm/api/v1/transition/f8df162d-60c3-4074-b622-0d5c997c8708"}],"executionId":"3e878473-61bd-4480-88ac-f935fb213414","transitionId":"f8df162d-60c3-4074-b622-0d5c997c8708","action":"reserve","status":"completed","steps":[{"name":"discover","status":"completed","results":[]},{"name":"validate","status":"warning","results":[{"code":"TM3001","description":"validation finished with warnings","_links":[{"rel":"resource","href":"https://localhost:8080/transition-dm/api/v1/resource/ad38c6b2-1211-4ef3-975b-966f25642b14"}]}]},{"name":"reserve","status":"warning","results":[{"code":"TM3001XXX","description":"validation finished with warningsXXX","_links":[{"rel":"resource1","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/d1e01de9-613c-4ac0-a673-45d252bc2f13"},{"rel":"resource2","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/d1e01de9-613c-4ac0-a673-45d252bc2f13"}]}]}],"metadata":{"createdAt":"2019-05-03T04:56:57.690Z","updatedAt":"2019-05-03T04:56:57.690Z","salesforceId":"00P2O000001A2zP"}}';
        //String json = 'Test';
        Attachment att = new Attachment();
        att.Name =  'EligibilityResults.txt';
        att.parentId = mobileTramas.id;
        att.body = blob.valueof(json);
        att.Description = 'Aniket';
        insert att;
        return att;
    } 
    static attachment testsetUpDataNegative(){
        MobileTramasElgibility__c mobileTramas = new MobileTramasElgibility__c(Name = 'Test Tramas');
        insert mobileTramas;
        
        String json='{"_links":[{"rel":"self","href":"https://localhost:8080/transition-dm/api/v1/execution/3e878473-61bd-4480-88ac-f935fb213414"},{"rel":"transition","href":"https://localhost:8080/transition-dm/api/v1/transition/f8df162d-60c3-4074-b622-0d5c997c8708"}],"executionId":"3e878473-61bd-4480-88ac-f935fb213414","transitionId":"f8df162d-60c3-4074-b622-0d5c997c8708","action":"reserve","status":"completed","steps":[{"name":"discover","status":"completed","results":[]},{"name":"validate","status":"warning","results":[{"code":"TM3001","description":"validation finished with warnings","_links":[{"rel":"resource","href":"https://localhost:8080/transition-dm/api/v1/resource/ad38c6b2-1211-4ef3-975b-966f25642b14"}]}]},{"name":"reserve","status":"warning","results":[{"code":"TM3001XXX","description":"validation finished with warningsXXX","_links":[{"rel":"resource1","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/d1e01de9-613c-4ac0-a673-45d252bc2f13"},{"rel":"resource2","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/d1e01de9-613c-4ac0-a673-45d252bc2f13"}]}]}],"metadata":{"createdAt":"2019-05-03T04:56:57.690Z","updatedAt":"2019-05-03T04:56:57.690Z","salesforceId":"00P2O000001A2zP"}}';
        //String json = 'Test';
        Attachment att = new Attachment();
        att.Name =  'EligibilityResults123.txt';
        att.parentId = mobileTramas.id;
        att.body = blob.valueof(json);
        att.Description = 'Aniket';
        //insert att;
        return null;
    }
    
    @isTest
    Public static void tramasCallbackResponseUpdateSuccess(){
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
        PC.name='Mobility';
        PC.Type__c='New';
        insert PC;
        String jsona='{ "CIDN": "6898327073", "Correlation_Id": "abcd_1234", "Error_Code": "", "Error_Description": "", "productList": [ { "checkValue": null, "disableCheck": null, "eligibilityReason": null, "eligibilityStatus": null, "Product_Type": "Mobile PostPaid HandHeld", "site": [ { "ADBOR_Id": "0999", "Error_Code": null, "Error_Description": null, "serviceList": [ { "checkReserved": false, "checkValue": true, "disableCheck": null, "groupType": [ { "groupId": "mobileGroup", "service": [ { "calling_line_identifier": "off", "contract_term": "12", "directory_listing": null, "Eligibility_status": null, "idd": "BFIDD100 | Bus Fleet Plus IDD $100", "imsi_number": "505013438393119", "international_roaming": "EFPAIR01| EFP Intl. Roaming $0 $50 Pack", "message_bank": "3GPPMSGK | 3G Pre-Paid Video Message Bank", "plan_name": "3OB*049 | 3G Cap 49 Business Mobile Plan", "Reason": "", "Reserve_status": null, "Service_Id": "0429701813", "service_status": "AC", "service_type": null, "service_type_code": "NORM", "sim_serial_number": "89610179078138000029" } ], "transitionId": "f8df162d-60c3-4074-b622-0d5c997c8708" } ], "Service_Type": null } ], "siteName": null } ] } ], "serviceCount": 0, "Source_System_Id": "Replicator" }';
        Attachment attc = new Attachment();
        attc.Name =  system.label.MobileTransitionName;
        attc.ParentId = PC.id;
        attc.Body = blob.valueof(jsona);
        insert attc;
        MobileTramasElgibility__c mobileTramas = new MobileTramasElgibility__c(Name = 'Test Tramas',Product_Configuration__c=PC.id);
        insert mobileTramas;
        
        String json='{"_links":[{"rel":"self","href":"https://localhost:8080/transition-dm/api/v1/execution/3e878473-61bd-4480-88ac-f935fb213414"},{"rel":"transition","href":"https://localhost:8080/transition-dm/api/v1/transition/f8df162d-60c3-4074-b622-0d5c997c8708"}],"executionId":"3e878473-61bd-4480-88ac-f935fb213414","transitionId":"f8df162d-60c3-4074-b622-0d5c997c8708","action":"reserve","status":"completed","steps":[{"name":"discover","status":"completed","results":[]},{"name":"validate","status":"warning","results":[{"code":"TM4001","description":"validation finished with warnings","_links":[{"rel":"resource","href":"https://localhost:8080/transition-dm/api/v1/resource/ad38c6b2-1211-4ef3-975b-966f25642b14"}]}]},{"name":"reserve","status":"warning","results":[{"code":"TM3001XXX","description":"validation finished with warningsXXX","_links":[{"rel":"resource1","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/d1e01de9-613c-4ac0-a673-45d252bc2f13"},{"rel":"resource2","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/d1e01de9-613c-4ac0-a673-45d252bc2f13"}]}]}],"metadata":{"createdAt":"2019-05-03T04:56:57.690Z","updatedAt":"2019-05-03T04:56:57.690Z","salesforceId":"00P2O000001A2zP"}}';
        //String json = 'Test';
        Attachment att = new Attachment();
        att.Name =  'EligibilityResults.txt';
        att.parentId = mobileTramas.id;
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
        body.add('{"_links":[{"rel":"self","href":"https://localhost:8080/transition-dm/api/v1/execution/3e878473-61bd-4480-88ac-f935fb213414"},{"rel":"transition","href":"https://localhost:8080/transition-dm/api/v1/transition/f8df162d-60c3-4074-b622-0d5c997c8708"}],"executionId":"3e878473-61bd-4480-88ac-f935fb213414","transitionId":"f8df162d-60c3-4074-b622-0d5c997c8708","action":"reserve","status":"completed","steps":[{"name":"discover","status":"completed","results":[]},{"name":"validate","status":"warning","results":[{"code":"TM4001","description":"validation finished with warnings","_links":[{"rel":"resource","href":"https://localhost:8080/transition-dm/api/v1/resource/ad38c6b2-1211-4ef3-975b-966f25642b14"}]}]},{"name":"reserve","status":"warning","results":[{"code":"TM3001XXX","description":"validation finished with warningsXXX","_links":[{"rel":"resource1","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"},{"rel":"resource2","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"}]},{"code":"TM300YYY","description":"validation finished with warningsXXX","_links":[{"rel":"resource1","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"},{"rel":"resource2","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"}]}]}],"metadata":{"createdAt":"2019-05-03T04:56:57.690Z","updatedAt":"2019-05-03T04:56:57.690Z","salesforceId":"00P2O000001A2zP"}}');
        
        TramasCallbackResponseUpdate.tamasAttachmentsUpdate(recordId,parentId,body);
        //system.debug('attMap:' + attMap);
        Test.setMock(HttpCalloutMock.class, new TramasCallbackResponseUpdateMock('success_acknowledgement'));
        
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
    Public static void tramasCallbackResponseUpdateFailure(){
        Test.startTest();
        map<id,attachment> attMap= new map<id,attachment>();
        Attachment attTest  = testsetUpDataNegative();
        system.assert(attTest == null);
        
        
        Test.stopTest();
    }
    //End EDGE-94797
    @isTest
    Public static void tramasbatchCallbackResponseUpdate(){
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
        body.add('{"_links":[{"rel":"self","href":"https://localhost:8080/transition-dm/api/v1/execution/3e878473-61bd-4480-88ac-f935fb213414"},{"rel":"transition","href":"https://localhost:8080/transition-dm/api/v1/transition/f8df162d-60c3-4074-b622-0d5c997c8708"}],"executionId":"3e878473-61bd-4480-88ac-f935fb213414","transitionId":"f8df162d-60c3-4074-b622-0d5c997c8708","action":"reserve","status":"completed","steps":[{"name":"discover","status":"completed","results":[]},{"name":"validate","status":"warning","results":[{"code":"TM3001","description":"validation finished with warnings","_links":[{"rel":"resource","href":"https://localhost:8080/transition-dm/api/v1/resource/ad38c6b2-1211-4ef3-975b-966f25642b14"}]}]},{"name":"reserve","status":"warning","results":[{"code":"TM3001XXX","description":"validation finished with warningsXXX","_links":[{"rel":"resource1","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"},{"rel":"resource2","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"}]},{"code":"TM300YYY","description":"validation finished with warningsXXX","_links":[{"rel":"resource1","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"},{"rel":"resource2","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"}]}]}],"metadata":{"createdAt":"2019-05-03T04:56:57.690Z","updatedAt":"2019-05-03T04:56:57.690Z","salesforceId":"00P2O000001A2zP"}}');
        //TramasBatchCallbackResponseUpdate.tramasAttachmentsUpdate(recordId,parentId,body);
        //system.debug('attMap:' + attMap);
        // Test.setMock(HttpCalloutMock.class, new TramasBatchCallbackResponseUpdateMock('success_acknowledgement'));
        
        //String serialized = JSON.serialize(attMap);
        //TramasCallbackResponseUpdate.tamasAttachmentsUpdate(serialized,serialized);
        //delete(attTest);
        Map<Id, sObject> objRecordsMap = new Map<Id, sObject>();
        objRecordsMap.putAll( [select id,name,body,description,parentid,BodyLength from attachment where id=:att.id ] );
        
        AttachmentTriggerHelper attTrigger = new AttachmentTriggerHelper();
        AttachmentTriggerHelper.onTRAMASAttachmentsUpdate(objRecordsMap,objRecordsMap);
        Attachment_TriggerHandler attCtr = new Attachment_TriggerHandler();
        attCtr.beforeDelete(null);
        attCtr.afterDelete(null);
        //attTrigger.bulkBefore();
        //attTrigger.beforeInsert(att);
        system.assert(att!=null);
        Test.stopTest();
    }
    
    @isTest
    static void testSetStatusToSuccessAndPublishEvent() {
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.label.Account_RecordType_Enterprise).getRecordTypeId();
        Account testAccount = new Account();
        testAccount.name = 'TestClassEvent';
        testAccount.CIDN__c = 'ASDF1234';
        testAccount.RecordTypeId = accRecordTypeId;
        testAccount.Migrated_Customer__c = true;
        testAccount.Customer_status__c = 'ACTIVE';
        insert testAccount;
        
        Opportunity testOpp=new Opportunity();
        testOpp.AccountId=testAccount.Id;
        testOpp.Name='TestOppCreateForEventCreate';
        testOpp.Proposal_Required_Date__c=System.today()+2;
        testOpp.CloseDate=System.today()+10;
        testOpp.StageName=System.label.Opp_Stage_Develop;
        testOpp.Description__c='Test';
        testOpp.Product_Domain__c='MOBILES';
        testOpp.Shared_Opportunity__c=True;
        testOpp.Product_Type__c = 'Non Modular';
        testOpp.Conga_Status__c = 'InProgress';
        insert testOpp;
        
        Attachment testAttachment = new Attachment();
        testAttachment.ParentId = testOpp.Id;
        testAttachment.Name = 'Test Attachment';
        testAttachment.Body = Blob.valueOf('Unit Test Attachment Body');
        insert testAttachment;
        
        Test.startTest();
        AttachmentTriggerHelper.setStatusToSuccessAndPublishEvent(new List<Attachment>{testAttachment});
        Test.stopTest();
        
        Opportunity testOppAfterUpdate = [SELECT Id, Conga_Status__c FROM Opportunity WHERE Name = 'TestOppCreateForEventCreate'];
        System.assertEquals(testOppAfterUpdate.Conga_Status__c,'Success', 'Value should be Success');
    }  
    @isTest
    Public static void tramasCallbackResponseUpdateWarningSuccess(){
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
        PC.name='Mobility';
        PC.Type__c='New';
        insert PC;
        String jsona='{ "CIDN": "6898327073", "Correlation_Id": "abcd_1234", "Error_Code": "", "Error_Description": "", "productList": [ { "checkValue": null, "disableCheck": null, "eligibilityReason": null, "eligibilityStatus": null, "Product_Type": "Mobile PostPaid HandHeld", "site": [ { "ADBOR_Id": "0999", "Error_Code": null, "Error_Description": null, "serviceList": [ { "checkReserved": false, "checkValue": true, "disableCheck": null, "groupType": [ { "groupId": "mobileGroup", "service": [ { "calling_line_identifier": "off", "contract_term": "12", "directory_listing": null, "Eligibility_status": null, "idd": "BFIDD100 | Bus Fleet Plus IDD $100", "imsi_number": "505013438393119", "international_roaming": "EFPAIR01| EFP Intl. Roaming $0 $50 Pack", "message_bank": "3GPPMSGK | 3G Pre-Paid Video Message Bank", "plan_name": "3OB*049 | 3G Cap 49 Business Mobile Plan", "Reason": "", "Reserve_status": null, "Service_Id": "0429701813", "service_status": "AC", "service_type": null, "service_type_code": "NORM", "sim_serial_number": "89610179078138000029" } ], "transitionId": "f8df162d-60c3-4074-b622-0d5c997c8708" } ], "Service_Type": null } ], "siteName": null } ] } ], "serviceCount": 0, "Source_System_Id": "Replicator" }';
        Attachment attc = new Attachment();
        attc.Name =  system.label.MobileTransitionName;
        attc.ParentId = PC.id;
        attc.Body = blob.valueof(jsona);
        insert attc;
        MobileTramasElgibility__c mobileTramas = new MobileTramasElgibility__c(Name = 'Test Tramas',Product_Configuration__c=PC.id);
        insert mobileTramas;
        
        String json='{"_links":[{"rel":"self","href":"https://localhost:8080/transition-dm/api/v1/execution/3e878473-61bd-4480-88ac-f935fb213414"},{"rel":"transition","href":"https://localhost:8080/transition-dm/api/v1/transition/f8df162d-60c3-4074-b622-0d5c997c8708"}],"executionId":"3e878473-61bd-4480-88ac-f935fb213414","transitionId":"f8df162d-60c3-4074-b622-0d5c997c8708","action":"reserve","status":"completed","steps":[{"name":"discover","status":"completed","results":[]},{"name":"validate","status":"warning","results":[{"code":"TM3000","description":"validation finished with warnings","_links":[{"rel":"resource","href":"https://localhost:8080/transition-dm/api/v1/resource/ad38c6b2-1211-4ef3-975b-966f25642b14"}]}]},{"name":"reserve","status":"warning","results":[{"code":"TM3001XXX","description":"validation finished with warningsXXX","_links":[{"rel":"resource1","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/d1e01de9-613c-4ac0-a673-45d252bc2f13"},{"rel":"resource2","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/d1e01de9-613c-4ac0-a673-45d252bc2f13"}]}]}],"metadata":{"createdAt":"2019-05-03T04:56:57.690Z","updatedAt":"2019-05-03T04:56:57.690Z","salesforceId":"00P2O000001A2zP"}}';
        //String json = 'Test';
        Attachment att = new Attachment();
        att.Name =  'EligibilityResults.txt';
        att.parentId = mobileTramas.id;
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
        body.add('{"_links":[{"rel":"self","href":"https://localhost:8080/transition-dm/api/v1/execution/3e878473-61bd-4480-88ac-f935fb213414"},{"rel":"transition","href":"https://localhost:8080/transition-dm/api/v1/transition/f8df162d-60c3-4074-b622-0d5c997c8708"}],"executionId":"3e878473-61bd-4480-88ac-f935fb213414","transitionId":"f8df162d-60c3-4074-b622-0d5c997c8708","action":"reserve","status":"completed","steps":[{"name":"discover","status":"completed","results":[]},{"name":"validate","status":"warning","results":[{"code":"TM3000","description":"validation finished with warnings","_links":[{"rel":"resource","href":"https://localhost:8080/transition-dm/api/v1/resource/ad38c6b2-1211-4ef3-975b-966f25642b14"}]}]},{"name":"reserve","status":"warning","results":[{"code":"TM3001XXX","description":"validation finished with warningsXXX","_links":[{"rel":"resource1","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"},{"rel":"resource2","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"}]},{"code":"TM300YYY","description":"validation finished with warningsXXX","_links":[{"rel":"resource1","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"},{"rel":"resource2","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"}]}]}],"metadata":{"createdAt":"2019-05-03T04:56:57.690Z","updatedAt":"2019-05-03T04:56:57.690Z","salesforceId":"00P2O000001A2zP"}}');
        TramasCallbackResponseUpdate.tamasAttachmentsUpdate(recordId,parentId,body);
        //system.debug('attMap:' + attMap);
        Test.setMock(HttpCalloutMock.class, new TramasCallbackResponseUpdateMock('Warning_acknowledgement'));
        
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
    Public static void tramasCallbackResponseUpdateFailedSuccess(){
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
        PC.name='Mobility';
        PC.Type__c='New';
        insert PC;
        String jsona='{ "CIDN": "6898327073", "Correlation_Id": "abcd_1234", "Error_Code": "", "Error_Description": "", "productList": [ { "checkValue": null, "disableCheck": null, "eligibilityReason": null, "eligibilityStatus": null, "Product_Type": "Mobile PostPaid HandHeld", "site": [ { "ADBOR_Id": "0999", "Error_Code": null, "Error_Description": null, "serviceList": [ { "checkReserved": false, "checkValue": true, "disableCheck": null, "groupType": [ { "groupId": "mobileGroup", "service": [ { "calling_line_identifier": "off", "contract_term": "12", "directory_listing": null, "Eligibility_status": null, "idd": "BFIDD100 | Bus Fleet Plus IDD $100", "imsi_number": "505013438393119", "international_roaming": "EFPAIR01| EFP Intl. Roaming $0 $50 Pack", "message_bank": "3GPPMSGK | 3G Pre-Paid Video Message Bank", "plan_name": "3OB*049 | 3G Cap 49 Business Mobile Plan", "Reason": "", "Reserve_status": null, "Service_Id": "0429701813", "service_status": "AC", "service_type": null, "service_type_code": "NORM", "sim_serial_number": "89610179078138000029" } ], "transitionId": "f8df162d-60c3-4074-b622-0d5c997c8708" } ], "Service_Type": null } ], "siteName": null } ] } ], "serviceCount": 0, "Source_System_Id": "Replicator" }';
        Attachment attc = new Attachment();
        attc.Name =  system.label.MobileTransitionName;
        attc.ParentId = PC.id;
        attc.Body = blob.valueof(jsona);
        insert attc;
        MobileTramasElgibility__c mobileTramas = new MobileTramasElgibility__c(Name = 'Test Tramas',Product_Configuration__c=PC.id);
        insert mobileTramas;
        
        String json='{"_links":[{"rel":"self","href":"https://localhost:8080/transition-dm/api/v1/execution/3e878473-61bd-4480-88ac-f935fb213414"},{"rel":"transition","href":"https://localhost:8080/transition-dm/api/v1/transition/f8df162d-60c3-4074-b622-0d5c997c8708"}],"executionId":"3e878473-61bd-4480-88ac-f935fb213414","transitionId":"f8df162d-60c3-4074-b622-0d5c997c8708","action":"reserve","status":"completed","steps":[{"name":"discover","status":"completed","results":[]},{"name":"validate","status":"warning","results":[{"code":"TM3001","description":"validation finished with warnings","_links":[{"rel":"resource","href":"https://localhost:8080/transition-dm/api/v1/resource/ad38c6b2-1211-4ef3-975b-966f25642b14"}]}]},{"name":"reserve","status":"warning","results":[{"code":"TM3001XXX","description":"validation finished with warningsXXX","_links":[{"rel":"resource1","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/d1e01de9-613c-4ac0-a673-45d252bc2f13"},{"rel":"resource2","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/d1e01de9-613c-4ac0-a673-45d252bc2f13"}]}]}],"metadata":{"createdAt":"2019-05-03T04:56:57.690Z","updatedAt":"2019-05-03T04:56:57.690Z","salesforceId":"00P2O000001A2zP"}}';
        //String json = 'Test';
        Attachment att = new Attachment();
        att.Name =  'EligibilityResults.txt';
        att.parentId = mobileTramas.id;
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
        TramasCallbackResponseUpdate.tamasAttachmentsUpdate(recordId,parentId,body);
        //system.debug('attMap:' + attMap);
        Test.setMock(HttpCalloutMock.class, new TramasCallbackResponseUpdateMock('failed_acknowledgement'));
        
        //String serialized = JSON.serialize(attMap);
        //TramasCallbackResponseUpdate.tamasAttachmentsUpdate(serialized,serialized);
        //delete(attTest);
        Attachment_TriggerHandler attTrigger = new Attachment_TriggerHandler();
        attTrigger.bulkBefore();
        attTrigger.beforeInsert(att);
        system.assert(att!=null);
        Test.stopTest();
    }
     /*EDGE  :EDGE-215821
      Method: tramasCallbackResponseError
      Description: Test method to handle callback business Error*/
    @isTest
    Public static void tramasCallbackResponseUpdatebusinessError(){
        Attachment att=testsetUpData();
        String json = '{"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/executions/ee21c297-9c0d-4d0b-804a-8c1a98889530"},{"rel":"transition","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/transitions/f8df162d-60c3-4074-b622-0d5c997c8708"}],"executionId":"ee21c297-9c0d-4d0b-804a-8c1a98889530","transitionId":"f8df162d-60c3-4074-b622-0d5c997c8708","action":"reserve","status":"completed","steps":[{"name":"create","status":"completed","results":[]},{"name":"discover","status":"completed","results":[]},{"name":"validate","status":"failed","results":[{"code":"TM4001","description":"Validation finished with errors","details":"Some/all rules did not pass","_links":[{"rel":"resource","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/7c3b81ad-741a-40d9-83b3-707852cb5a31"}]}]}],"metadata":{"salesforceId":"00P2N000003RbDMUA0","createdAt":"2020-06-15T03:46:22.972Z","updatedAt":"2020-06-15T03:49:40.519Z","correlationId":"1f020fb6-4dddb603-92f1c3aa-cf7589a0","host":"https://slot1.org009.t-dev.telstra.net/v1/tramas","originatingSystem":"Salesforce","stepFunctions":[{"executionArn":"arn:aws:states:ap-southeast-2:450340460944:execution:transition-elrod-tramas-preprod:5780af52-6b7d-4955-bd77-dbccaaf9e9f3","startDate":"2020-06-15T03:46:23.207Z"}],"elrodJobs":[{"jobId":"6def5aca-8b2d-4d65-b8dc-99ebae46c31a","startDate":"2020-06-15T13:46:28+10:00","workflowAction":"discover"},{"jobId":"b6e10163-f4c1-48fc-9062-9eb8e14a5283","startDate":"2020-06-15T13:49:22+10:00","workflowAction":"reserve"}]}}';
        
        Test.startTest();
        map<id,attachment> attMap= new map<id,attachment>();
        att.Description = '1234';
        att.body = blob.valueof(json);
        update att;
        attMap.put(att.id,att);        
        List<Id> recordId = new List<Id>();
        recordId.add(att.Id);
        List<Id> parentId = new List<Id>();
        parentId.add(att.parentid);
        List<String> body = new List<String>();
        body.add('{"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/executions/ee21c297-9c0d-4d0b-804a-8c1a98889530"},{"rel":"transition","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/transitions/f8df162d-60c3-4074-b622-0d5c997c8708"}],"executionId":"ee21c297-9c0d-4d0b-804a-8c1a98889530","transitionId":"f8df162d-60c3-4074-b622-0d5c997c8708","action":"reserve","status":"completed","steps":[{"name":"create","status":"completed","results":[]},{"name":"discover","status":"completed","results":[]},{"name":"validate","status":"failed","results":[{"code":"TM4001","description":"Validation finished with errors","details":"Some/all rules did not pass","_links":[{"rel":"resource","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/7c3b81ad-741a-40d9-83b3-707852cb5a31"}]}]}],"metadata":{"salesforceId":"00P2N000003RbDMUA0","createdAt":"2020-06-15T03:46:22.972Z","updatedAt":"2020-06-15T03:49:40.519Z","correlationId":"1f020fb6-4dddb603-92f1c3aa-cf7589a0","host":"https://slot1.org009.t-dev.telstra.net/v1/tramas","originatingSystem":"Salesforce","stepFunctions":[{"executionArn":"arn:aws:states:ap-southeast-2:450340460944:execution:transition-elrod-tramas-preprod:5780af52-6b7d-4955-bd77-dbccaaf9e9f3","startDate":"2020-06-15T03:46:23.207Z"}],"elrodJobs":[{"jobId":"6def5aca-8b2d-4d65-b8dc-99ebae46c31a","startDate":"2020-06-15T13:46:28+10:00","workflowAction":"discover"},{"jobId":"b6e10163-f4c1-48fc-9062-9eb8e14a5283","startDate":"2020-06-15T13:49:22+10:00","workflowAction":"reserve"}]}}');
        
        //body.add('{"_links":[{"rel":"self","href":"https://localhost:8080/transition-dm/api/v1/execution/3e878473-61bd-4480-88ac-f935fb213414"},{"rel":"transition","href":"https://localhost:8080/transition-dm/api/v1/transition/f8df162d-60c3-4074-b622-0d5c997c8708"}],"executionId":"3e878473-61bd-4480-88ac-f935fb213414","transitionId":"f8df162d-60c3-4074-b622-0d5c997c8708","action":"reserve","status":"completed","steps":[{"name":"discover","status":"completed","results":[]},{"name":"validate","status":"failed","results":[{"code":"TM4001","description":"validation finished with errors","_links":[{"rel":"resource","href":"https://localhost:8080/transition-dm/api/v1/resource/ad38c6b2-1211-4ef3-975b-966f25642b14"}]}]},{"name":"reserve","status":"warning","results":[{"code":"TM3001XXX","description":"validation finished with warningsXXX","_links":[{"rel":"resource1","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"},{"rel":"resource2","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"}]},{"code":"TM300YYY","description":"validation finished with warningsXXX","_links":[{"rel":"resource1","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"},{"rel":"resource2","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/cb9c125f-3635-4cca-a53d-f2e67a843008"}]}]}],"metadata":{"createdAt":"2019-05-03T04:56:57.690Z","updatedAt":"2019-05-03T04:56:57.690Z","salesforceId":"00P2O000001A2zP"}}');
        TramasCallbackResponseUpdate.tamasAttachmentsUpdate(recordId,parentId,body);
        //system.debug('attMap:' + attMap);
        Test.setMock(HttpCalloutMock.class, new TramasCallbackResponseUpdateMock('businessError_acknowledgement'));
        Attachment_TriggerHandler attTrigger = new Attachment_TriggerHandler();
        attTrigger.bulkBefore();
        attTrigger.beforeInsert(att);
        system.assert(att!=null);
        Test.stopTest();
    }
    /*EDGE  :EDGE-215821
      Method: tramasCallbackResponseError
      Description: Test Method to handle resource api error response*/
      
    @isTest
    Public static void tramasCallbackResponseError(){
        Attachment att=testsetUpData();
        String json = '{"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/executions/ee21c297-9c0d-4d0b-804a-8c1a98889530"},{"rel":"transition","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/transitions/f8df162d-60c3-4074-b622-0d5c997c8708"}],"executionId":"ee21c297-9c0d-4d0b-804a-8c1a98889530","transitionId":"f8df162d-60c3-4074-b622-0d5c997c8708","action":"reserve","status":"completed","steps":[{"name":"create","status":"completed","results":[]},{"name":"discover","status":"completed","results":[]},{"name":"validate","status":"failed","results":[{"code":"TM4001","description":"Validation finished with errors","details":"Some/all rules did not pass","_links":[{"rel":"resource","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/7c3b81ad-741a-40d9-83b3-707852cb5a31"}]}]}],"metadata":{"salesforceId":"00P2N000003RbDMUA0","createdAt":"2020-06-15T03:46:22.972Z","updatedAt":"2020-06-15T03:49:40.519Z","correlationId":"1f020fb6-4dddb603-92f1c3aa-cf7589a0","host":"https://slot1.org009.t-dev.telstra.net/v1/tramas","originatingSystem":"Salesforce","stepFunctions":[{"executionArn":"arn:aws:states:ap-southeast-2:450340460944:execution:transition-elrod-tramas-preprod:5780af52-6b7d-4955-bd77-dbccaaf9e9f3","startDate":"2020-06-15T03:46:23.207Z"}],"elrodJobs":[{"jobId":"6def5aca-8b2d-4d65-b8dc-99ebae46c31a","startDate":"2020-06-15T13:46:28+10:00","workflowAction":"discover"},{"jobId":"b6e10163-f4c1-48fc-9062-9eb8e14a5283","startDate":"2020-06-15T13:49:22+10:00","workflowAction":"reserve"}]}}';
        
        Test.startTest();
        map<id,attachment> attMap= new map<id,attachment>();
        att.Description = '1234';
        att.body = blob.valueof(json);
        update att;
        attMap.put(att.id,att);        
        List<Id> recordId = new List<Id>();
        recordId.add(att.Id);
        List<Id> parentId = new List<Id>();
        parentId.add(att.parentid);
        List<String> body = new List<String>();
        body.add('{"_links":[{"rel":"self","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/executions/ee21c297-9c0d-4d0b-804a-8c1a98889530"},{"rel":"transition","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/transitions/f8df162d-60c3-4074-b622-0d5c997c8708"}],"executionId":"ee21c297-9c0d-4d0b-804a-8c1a98889530","transitionId":"f8df162d-60c3-4074-b622-0d5c997c8708","action":"reserve","status":"completed","steps":[{"name":"create","status":"completed","results":[]},{"name":"discover","status":"completed","results":[]},{"name":"validate","status":"failed","results":[{"code":"TM4001","description":"Validation finished with errors","details":"Some/all rules did not pass","_links":[{"rel":"resource","href":"https://slot1.org009.t-dev.telstra.net/v1/tramas/resources/7c3b81ad-741a-40d9-83b3-707852cb5a31"}]}]}],"metadata":{"salesforceId":"00P2N000003RbDMUA0","createdAt":"2020-06-15T03:46:22.972Z","updatedAt":"2020-06-15T03:49:40.519Z","correlationId":"1f020fb6-4dddb603-92f1c3aa-cf7589a0","host":"https://slot1.org009.t-dev.telstra.net/v1/tramas","originatingSystem":"Salesforce","stepFunctions":[{"executionArn":"arn:aws:states:ap-southeast-2:450340460944:execution:transition-elrod-tramas-preprod:5780af52-6b7d-4955-bd77-dbccaaf9e9f3","startDate":"2020-06-15T03:46:23.207Z"}],"elrodJobs":[{"jobId":"6def5aca-8b2d-4d65-b8dc-99ebae46c31a","startDate":"2020-06-15T13:46:28+10:00","workflowAction":"discover"},{"jobId":"b6e10163-f4c1-48fc-9062-9eb8e14a5283","startDate":"2020-06-15T13:49:22+10:00","workflowAction":"reserve"}]}}');
        
        TramasCallbackResponseUpdate.tamasAttachmentsUpdate(recordId,parentId,body);
        Test.setMock(HttpCalloutMock.class, new TramasCallbackResponseUpdateMock('Error_acknowledgement'));
        Attachment_TriggerHandler attTrigger = new Attachment_TriggerHandler();
        attTrigger.bulkBefore();
        attTrigger.beforeInsert(att);
        system.assert(att!=null);
        Test.stopTest();
    }
    @testSetup
    static void setupTestData() {
        //create Accounts
        List<Account> lstOfAccount =Coms_TestDataFactory.createAccount();
        insert lstOfAccount;
        System.assertEquals(10,lstOfAccount.size());
        
        //create Billing Accounts
        List<Billing_Account__c> lstBillacc=Coms_TestDataFactory.createBillingAccount(lstOfAccount);
        System.debug('lstBillacc'+lstBillacc);
        insert lstBillacc;
        System.assertEquals(1,lstBillacc.size());

        //create opportunities
        List<Opportunity> lstOpp=Coms_TestDataFactory.createOpportunity(lstOfAccount);
        insert lstOpp;
        System.assertEquals(10,lstOpp.size());
 
        //create opportunities
        List<cscfga__Product_Definition__c> lstProDef=Coms_TestDataFactory.createCWPD();
        insert lstProDef;
        System.assertEquals(10,lstProDef.size());
       
        //create basket
        List<cscfga__Product_Basket__c> lsttestBasket=Coms_TestDataFactory.createBasket(lstOfAccount,lstOpp);
        insert lsttestBasket;
        System.assertEquals(10,lstProDef.size());
        

         //create config
         List<cscfga__Product_Configuration__c> lsttestConfig=Coms_TestDataFactory.createConfig(lsttestBasket,lstProDef);
         insert lsttestConfig;
         System.assertEquals(10,lsttestConfig.size());
 
         //create request
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
        //create order
        csord__Order__c testOrder = ProductTestFactory.buildOrder('PrimaryOrder', lstOfAccount[0].id, 'Created', ordReq.id);
        testOrder.csord__Status2__c='Ready for submit';
        testOrder.Name = 'testCOBA';
        insert testOrder;

        //createSubscription
         List<csord__Subscription__c> lsttestSubscription=Coms_TestDataFactory.createSubscription(testOrder.Id,lstOfAccount,lsttestConfig,lstBillacc[0].id);
         insert lsttestSubscription;
         System.assertEquals(3,lsttestSubscription.size());

       // create Service
        List<csord__Service__c> lsttestService=Coms_TestDataFactory.createService(testOrder.Id,lsttestSubscription);
        for(csord__Service__c lstService:lsttestService){
            lstService.Type__c='csord__Service__c';
        }
         insert lsttestService;
         System.assertEquals(3,lsttestService.size());

        // create Attach
        List<Attachment> lsttesAttach=Coms_TestDataFactory.createAttach(lsttestService[0].Id);
         insert lsttesAttach;
         System.assertEquals(2,lsttesAttach.size());
    }
    /**
    * @description 
    * @author Rohit Pal | 09-27-2021 
    **/
    @isTest
    static  void testSendAttachmentPlatformEvent(){
        User adminUser = Coms_TestDataFactory.getAdminUser();
        System.runAs(adminUser){
        Test.startTest();
            List<Attachment> lstAttachment=[SELECT id,
                                                    Name,
                                                    parentId,
                                                    Parent.Type,
                                                    BodyLength FROM 
                                                    Attachment WHERE name='ServiceSpecifications.json'];
            System.debug('lstAttachment'+lstAttachment);
            Map<Id, Attachment> attachmentMap = new Map<Id, Attachment>();
            for(Attachment attachmentForSuccess:lstAttachment){
                attachmentMap.put(attachmentForSuccess.Id, attachmentForSuccess);
            }
            AttachmentTriggerHelper.createSubscriptionPlatformEvent(attachmentMap);
            Test.stopTest();
            //System.assertEquals(1, [SELECT count() FROM Orchestration_Technical__c limit 1],'Orchestration_Technical Record Created Successfully');
        } 
    }
    /**
    * @description 
    * @author Rohit Pal | 09-27-2021 
    **/
    @isTest
    static  void testCreateSubscriptionPlatformEvent(){
        User adminUser = Coms_TestDataFactory.getAdminUser();
        System.runAs(adminUser){
        Test.startTest();
        List<Attachment> lstAttachment=[SELECT id,
                                                    Name,
                                                    parentId,
                                                    Parent.Type,
                                                    BodyLength FROM 
                                                    Attachment WHERE name='ServiceSpecifications.json'];
            System.debug('lstAttachment'+lstAttachment);
            Map<Id, Attachment> attachmentMap = new Map<Id, Attachment>();
            for(Attachment attachmentForSuccess:lstAttachment){
                attachmentMap.put(attachmentForSuccess.Id, attachmentForSuccess);
            }
            AttachmentTriggerHelper.createSubscriptionPlatformEvent(attachmentMap);
            Test.stopTest();
            //System.assertEquals(1, [SELECT count() FROM Orchestration_Technical__c limit 1] ,'Orchestration_Technical Record Created Successfully');
        }
    }
    
}