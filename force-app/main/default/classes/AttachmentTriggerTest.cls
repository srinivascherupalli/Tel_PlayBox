@isTest
public class AttachmentTriggerTest {
    @testSetup
    static void setupTestData() {
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
    }
    @isTest static void testAttachmentTriggerTest() {
        test.starttest();
        BypassTrigger.bypassTriggerAtOG = true;
        Attachment att1 = [SELECT Id,name FROM Attachment WHERE name = 'TransitionJSONData.json' LIMIT 1];
        att1.name = 'Testing.json';
        update att1;
        test.stoptest();
    }
}