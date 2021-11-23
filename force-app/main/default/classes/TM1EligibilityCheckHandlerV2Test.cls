/*
* @Author : Robin/Ritika
* @Date : 5 June 2019
* @Desc : Test class for Tramas-TM1EligibilityCheckHandlerV2 (for Mobile Transition)
* @Jira Cloud : EDGE-85155
*/
@isTest
public class TM1EligibilityCheckHandlerV2Test {

    @testsetup static void testsetUpData(){
        
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
    } 
    
    @isTest
    Public static void checkHandlerTestSuccess(){
        List<String> param=new List<String>();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TM1EligibilityCheckServiceV2Mock('success_acknowledgement'));
        String json='{ "CIDN" : "6898327073", "Correlation_Id" : "abcd_1234", "Error_Code" : "", "Error_Description" : "", "productList" : [ { "checkValue" : null, "disableCheck" : null, "eligibilityReason" : null, "eligibilityStatus" : null, "Product_Type" : "Mobile PostPaid HandHeld", "site" : [ { "ADBOR_Id" : "0999", "Error_Code" : null, "Error_Description" : null, "serviceList" : [ { "checkReserved" : false, "checkValue" : true, "disableCheck" : null, "groupType" : [ { "groupId" : "mobileGroup", "service" : [ { "calling_line_identifier" : "off", "contract_term" : "12", "directory_listing" : null, "Eligibility_status" : null, "idd" : "BFIDD100 | Bus Fleet Plus IDD $100", "imsi_number" : "505013438393119", "international_roaming" : "EFPAIR01| EFP Intl. Roaming $0 $50 Pack", "message_bank" : "3GPPMSGK | 3G Pre-Paid Video Message Bank", "plan_name" : "3OB*049 | 3G Cap 49 Business Mobile Plan", "Reason" : "", "Reserve_status" : null, "Service_Id" : "0429701813", "service_status" : "AC", "service_type" : null, "service_type_code" : "NORM", "sim_serial_number" : "89610179078138000029" } ], "transitionId" : null } ], "Service_Type" : null } ], "siteName" : null } ] } ], "serviceCount" : 0, "Source_System_Id" : "Replicator" }';
         cscfga__Product_Basket__c basket=[SELECT id FROM cscfga__Product_Basket__c LIMIT 1];
        TM1EligibilityCheckServiceV2.tramasEligibilityRequestMethod(json,basket.Id);
        List<Integration_Record__c> paramRequest=[SELECT Id, params__c, paramPayload__c FROM Integration_Record__c limit 1];
        param.add(paramRequest[0].params__c);
        new TM1EligibilityCheckHandlerV2().executeWork(param);
        Test.stopTest();
        //List<TramasElgibilityCallbackResponse__c> responserecord = [SELECT id,TranasactionId__c FROM TramasElgibilityCallbackResponse__c LIMIT 1];      
        System.assert(!paramRequest.isEmpty());
    }
    
    
    @isTest
    Public static void checkHandlerTestFailure(){
        List<String> param=new List<String>();
        Test.startTest();        
        String json='{ "CIDN": "6898327073", "Correlation_Id": "abcd_1234", "Error_Code": "", "Error_Description": "", "productList": [ { "checkValue": null, "disableCheck": null, "eligibilityReason": null, "eligibilityStatus": null, "Product_Type": "Mobile PostPaid HandHeld", "site": [ { "ADBOR_Id": "0999", "Error_Code": null, "Error_Description": null, "serviceList": [ { "checkReserved": false, "checkValue": false, "disableCheck": null, "groupType": [ { "groupId": "mobileGroup", "service": [ { "calling_line_identifier": "off", "contract_term": "12", "directory_listing": null, "Eligibility_status": null, "idd": "BFIDD100 | Bus Fleet Plus IDD $100", "imsi_number": "505013438393119", "international_roaming": "EFPAIR01| EFP Intl. Roaming $0 $50 Pack", "message_bank": "3GPPMSGK | 3G Pre-Paid Video Message Bank", "plan_name": "3OB*049 | 3G Cap 49 Business Mobile Plan", "Reason": "", "Reserve_status": null, "Service_Id": "0429701813", "service_status": "AC", "service_type": null, "service_type_code": "NORM", "sim_serial_number": "89610179078138000029" } ], "transitionId": null } ], "Service_Type": null } ], "siteName": null } ] } ], "serviceCount": 0, "Source_System_Id": "Replicator" }';
         cscfga__Product_Basket__c basket=[SELECT id FROM cscfga__Product_Basket__c LIMIT 1];
        TM1EligibilityCheckServiceV2.tramasEligibilityRequestMethod(json,basket.Id);
        List<Integration_Record__c> paramRequest=[SELECT Id, params__c, paramPayload__c FROM Integration_Record__c limit 1];
        //param.add(paramRequest[0].params__c);  
        new TM1EligibilityCheckHandlerV2().executeWork(param);       
        Test.stopTest();
        //List<TramasElgibilityCallbackResponse__c> responserecord = [SELECT id,TranasactionId__c FROM TramasElgibilityCallbackResponse__c LIMIT 1];      
        System.assert(paramRequest.isEmpty());        
    }
}