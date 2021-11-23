/*
* @Author : Robin/Ritika
* @Date : 5 June 2019
* @Desc : Test class for TM1EligibilityCheckServiceV2
* @Jira Cloud : EDGE-85155
*/


@isTest
public class TM1EligibilityCheckServiceV2Test {
    
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
        
        cscfga__Product_Configuration__c PC = new cscfga__Product_Configuration__c();
        PC.cscfga__Product_Basket__c =basket.id;
        PC.name='Mobility';
        PC.Type__c='New';
        insert PC;
        
        String json='{ "Source_System_Id": "Replicator", "serviceCount": 0, "productList": [ { "site": [ { "siteName": null, "serviceList": [ { "Service_Type": null, "groupType": [ { "service": [ { "sim_serial_number": "89610179078138000029", "service_type_code": "NORM", "service_type": null, "service_status": "AC", "Service_Id": "0438034768", "plan_name": "3OB*049 &#124; 3G Cap 49 Business Mobile Plan", "message_bank": "3GPPMSGK &#124; 3G Pre-Paid Video Message Bank", "international_roaming": "EFPAIR01&#124; EFP Intl. Roaming $0 $50 Pack", "imsi_number": "505013438393119", "idd": "BFIDD100 &#124; Bus Fleet Plus IDD $100", "directory_listing": null, "contract_term": "0", "calling_line_identifier": "off" } ], "groupId": "mobileGroup", "transitionId":"bc37573b-4694-463e-123a-eb1484d123al" } ], "disableCheck": null, "checkValue": false } ], "Error_Description": null, "Error_Code": null, "ADBOR_Id": "0" }, { "siteName": null, "serviceList": [ { "Service_Type": null, "groupType": [ { "service": [ { "sim_serial_number": "89610179078138000029", "service_type_code": "NORM", "service_type": null, "service_status": "NOVA", "Service_Id": "0480126680", "plan_name": "3OB*049 &#124; 3G Cap 49 Business Mobile Plan", "message_bank": "3GPPMSGK &#124; 3G Pre-Paid Video Message Bank", "international_roaming": "EFPAIR01&#124; EFP Intl. Roaming $0 $50 Pack", "imsi_number": "505013438393120", "idd": "BFIDD100 &#124; Bus Fleet Plus IDD $100", "directory_listing": null, "contract_term": "120", "calling_line_identifier": "on" } ], "groupId": "mobileGroup", "transitionId": null } ], "disableCheck": null, "checkValue": false } ], "Error_Description": null, "Error_Code": null, "ADBOR_Id": "0000" } ], "Product_Type": "Mobile PostPaid HandHeld", "eligibilityStatus": null, "eligibilityReason": null, "disableCheck": null, "checkValue": true }, { "site": [ { "siteName": null, "serviceList": [ { "Service_Type": null, "groupType": [ { "service": [ { "sim_serial_number": "89610179078138000029", "service_type_code": "NORM", "service_type": null, "service_status": "AC", "Service_Id": "8910", "plan_name": "3OB*049 &#124; 3G Cap 49 Business Mobile Plan", "message_bank": "3GPPMSGK &#124; 3G Pre-Paid Video Message Bank", "international_roaming": "EFPAIR01&#124; EFP Intl. Roaming $0 $50 Pack", "imsi_number": "505013438393119", "idd": "BFIDD100 &#124; Bus Fleet Plus IDD $100", "directory_listing": null, "contract_term": "0", "calling_line_identifier": "off" } ], "groupId": "mobileGroup", "transitionId": null } ], "disableCheck": null, "checkValue": false } ], "Error_Description": null, "Error_Code": null, "ADBOR_Id": "123" } ], "Product_Type": "Mobile PrePaid HandHeld", "eligibilityStatus": null, "eligibilityReason": null, "disableCheck": null, "checkValue": false } ], "Error_Description": "", "Error_Code": "", "Correlation_Id": "abcd_1234", "CIDN": "6898327073" }';
        
        Attachment att = new Attachment();
                att.Name =  'TransitionData.json';
                att.ParentId = PC.id;
                att.Body = blob.valueof(json);
                insert att;
    } 
    @isTest
    Public static void tramasEligibilityRequestMethodTestSuccess(){
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TM1EligibilityCheckServiceV2Mock('success_acknowledgement'));
        cscfga__Product_Configuration__c config=[SELECT id FROM cscfga__Product_Configuration__c LIMIT 1];
        String json='{ "CIDN" : "6898327073", "Correlation_Id" : "abcd_1234", "Error_Code" : "", "Error_Description" : "", "productList" : [ { "checkValue" : null, "disableCheck" : null, "eligibilityReason" : null, "eligibilityStatus" : null, "Product_Type" : "Mobile PostPaid HandHeld", "site" : [ { "ADBOR_Id" : "0999", "Error_Code" : null, "Error_Description" : null, "serviceList" : [ { "checkReserved" : false, "checkValue" : true, "disableCheck" : null, "groupType" : [ { "groupId" : "mobileGroup", "service" : [ { "calling_line_identifier" : "off", "contract_term" : "12", "directory_listing" : null, "Eligibility_status" : null, "idd" : "BFIDD100 | Bus Fleet Plus IDD $100", "imsi_number" : "505013438393119", "international_roaming" : "EFPAIR01| EFP Intl. Roaming $0 $50 Pack", "message_bank" : "3GPPMSGK | 3G Pre-Paid Video Message Bank", "plan_name" : "3OB*049 | 3G Cap 49 Business Mobile Plan", "Reason" : "", "Reserve_status" : null, "Service_Id" : "0429701813", "service_status" : "AC", "service_type" : null, "service_type_code" : "NORM", "sim_serial_number" : "89610179078138000029","accountDetails": {"sourceCIDN":"6898327074"} } ], "" : null } ], "Service_Type" : null } ], "siteName" : null } ] } ], "serviceCount" : 0, "Source_System_Id" : "Replicator" }';
        TM1EligibilityCheckServiceV2.tramasEligibilityRequestMethod(json,config.id);
        List<Integration_Record__c> paramRequest=[SELECT Id, params__c, paramPayload__c FROM Integration_Record__c   LIMIT 1 ];
        system.debug('paramRequestdebug'+paramRequest);
        TM1EligibilityCheckServiceV2.sendEligibilityCheckRequest(paramRequest[0].params__c);        
        Test.stopTest();
        //List<TramasElgibilityCallbackResponse__c> responserecord = [SELECT id,TranasactionId__c FROM TramasElgibilityCallbackResponse__c LIMIT 1];      
        System.assert(!paramRequest.isEmpty());        
       }
    
    @isTest
    Public static void tramasEligibilityRequestMethodTestException(){        
        Test.startTest();        
        String json='{ "CIDN": "6898327073", "Correlation_Id": "abcd_1234", "Error_Code": "", "Error_Description": "", "productList": [ { "checkValue": null, "disableCheck": null, "eligibilityReason": null, "eligibilityStatus": null, "Product_Type": "Mobile PostPaid HandHeld", "site": [ { "ADBOR_Id": "0999", "Error_Code": null, "Error_Description": null, "serviceList": [ { "checkReserved": false, "checkValue": false, "disableCheck": null, "groupType": [ { "groupId": "mobileGroup", "service": [ { "calling_line_identifier": "off", "contract_term": "12", "directory_listing": null, "Eligibility_status": null, "idd": "BFIDD100 | Bus Fleet Plus IDD $100", "imsi_number": "505013438393119", "international_roaming": "EFPAIR01| EFP Intl. Roaming $0 $50 Pack", "message_bank": "3GPPMSGK | 3G Pre-Paid Video Message Bank", "plan_name": "3OB*049 | 3G Cap 49 Business Mobile Plan", "Reason": "", "Reserve_status": null, "Service_Id": "0429701813", "service_status": "AC", "service_type": null, "service_type_code": "NORM", "sim_serial_number": "89610179078138000029" } ], "transitionId": null } ], "Service_Type": null } ], "siteName": null } ] } ], "serviceCount": 0, "Source_System_Id": "Replicator" }';
        cscfga__Product_Configuration__c config=[SELECT id FROM cscfga__Product_Configuration__c LIMIT 1];
        TM1EligibilityCheckServiceV2.tramasEligibilityRequestMethod(json,config.id);
        List<Integration_Record__c> paramRequest=[SELECT Id, params__c, paramPayload__c FROM Integration_Record__c LIMIT 1];
        //TM1EligibilityCheckServiceV2.sendEligibilityCheckRequest(paramRequest[0].params__c);
        Test.stopTest();
        //List<TramasElgibilityCallbackResponse__c> responserecord = [SELECT id,TranasactionId__c FROM TramasElgibilityCallbackResponse__c LIMIT 1];      
        System.assert(paramRequest.isEmpty());
    }
     /**********************************************************
     * Story: EDGE-198380
     * Team : Nirvana
     * Description: Test method for TM0 execution callout failure.
     * *********************************************************/
    @isTest
    Public static void tramasEligibilityRequestMethodTestError(){
        MobileTramasElgibility__c mobileTramRec = new MobileTramasElgibility__c();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TM1EligibilityCheckServiceV2Mock('error_ack'));
        cscfga__Product_Configuration__c config=[SELECT id FROM cscfga__Product_Configuration__c LIMIT 1];
        String json='{ "CIDN" : "6898327073", "Correlation_Id" : "abcd_1234", "Error_Code" : "", "Error_Description" : "", "productList" : [ { "checkValue" : null, "disableCheck" : null, "eligibilityReason" : null, "eligibilityStatus" : null, "Product_Type" : "Mobile PostPaid HandHeld", "site" : [ { "ADBOR_Id" : "0999", "Error_Code" : null, "Error_Description" : null, "serviceList" : [ { "checkReserved" : false, "checkValue" : true, "disableCheck" : null, "groupType" : [ { "groupId" : "mobileGroup", "service" : [ { "calling_line_identifier" : "off", "contract_term" : "12", "directory_listing" : null, "Eligibility_status" : null, "idd" : "BFIDD100 | Bus Fleet Plus IDD $100", "imsi_number" : "505013438393119", "international_roaming" : "EFPAIR01| EFP Intl. Roaming $0 $50 Pack", "message_bank" : "3GPPMSGK | 3G Pre-Paid Video Message Bank", "plan_name" : "3OB*049 | 3G Cap 49 Business Mobile Plan", "Reason" : "", "Reserve_status" : null, "Service_Id" : "0429701813", "service_status" : "AC", "service_type" : null, "service_type_code" : "NORM", "sim_serial_number" : "89610179078138000029","accountDetails": {"sourceCIDN":"6898327074"} } ], "transitionId" : null } ], "Service_Type" : null } ], "siteName" : null } ] } ], "serviceCount" : 0, "Source_System_Id" : "Replicator" }';
        TM1EligibilityCheckServiceV2.tramasEligibilityRequestMethod(json,config.id);
        List<Integration_Record__c> paramRequest=[SELECT Id, params__c, paramPayload__c FROM Integration_Record__c   LIMIT 1 ];
        system.debug('paramRequestdebug'+paramRequest);
        TM1EligibilityCheckServiceV2.sendEligibilityCheckRequest(paramRequest[0].params__c);        
        Test.stopTest();
		mobileTramRec = [SELECT id, Type__c from MobileTramasElgibility__c where Product_Configuration__c = :config.id];
        System.assert(mobileTramRec.Type__c == 'TM0 Execution Error');        
             
       }
       
    

}