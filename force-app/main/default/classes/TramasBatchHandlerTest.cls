/*
* @Author : Rahul
* @Date : 19 Nov 2019
* @Desc : Test class for Tramas-TramasBatchHandler (for Nguc-cwp)
* @Jira Cloud : EDGE-92541
*/
@isTest
public class TramasBatchHandlerTest {

    static String serviceDTO_V2 = '{ "Source_System_Id": "Replicator", "site": [ { "siteName": "", "productList": [ { "serviceList": [ { "Service_Type": "voice", "service": [ { "User_Type": "", "serviceExtension": [ { "Reason": "", "Reserve_status": "", "Services_To": "0385990499", "Services_From": "0314419400", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "checkValue": false } ], "Service_Type": "voice", "Service_Id": "0314419400", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "", "In_Flight_Flag": null, "Reason": "", "Reserve_status": "", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "", "Association_Role": "AUX" } ], "disableCheck": null, "checkValue": false, "transitionId": "" } ], "Product_Type": "isdn2", "eligibilityStatus": "Ready for assessment", "eligibilityReason": null, "disableCheck": null, "checkValue": true } ], "Error_Description": "", "Error_Code": "", "ADBOR_Id": "50484597" } ], "serviceCount": 0, "Error_Description": "", "Error_Code": "", "Correlation_Id": "90baead7919646040e", "CIDN": "3867475038" }';
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
         cscfga__Product_Basket__c prodBasket = ProductTestService.getNewBasketWithRealConfigVal(acc);
        prodBasket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        update prodBasket;
        List<cscfga__Product_Definition__c> prdlist= new List<cscfga__Product_Definition__c>();
        
        cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Test','Test');
        prdlist.add( pd);
        
        cscfga__Product_Definition__c pd2 = ProductTestFactory.buildProductDefinition('Test2','Test2');
        pd2.product_Specification__c='DMCAT_ProductOffering_000323';
        prdlist.add( pd2);
        
        insert prdlist;
        
        cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(pd.Id);
        config.name= 'IP Site';
        config.cscfga__Description__c = 'Test description';
        insert config;   
         
        cscfga__Product_Configuration__c config2 = ProductTestFactory.buildProductConfig(pd2.Id);
        config2.name= 'Unified Communication Enterprise';
        config2.cscfga__Description__c = 'Test description';
        insert config2;
        //EDGE-80772 - SolutionConsole RetroFit for TM1
        /*csbb__Product_Configuration_Request__c prodConfigReq = ProductTestFactory.buildConfigRequest(prodBasket.Id,config.Id);
        prodConfigReq.csbb__Optionals__c = '{"selectedAddressDisplay":"Phase 2, Maharashtra, Pune, 411057, India","hiddenParam1":"152365895123","cscrm_installation_address_r_cscrm_state_province_c":"TAS","cscrm_installation_address_r_cscrm_zip_postal_code_c":"456","cscrm_installation_address_r_locality_c":"CURRIE","cscrm_installation_address_r_cscrm_street_name_c":"EDWARD","cscrm_installation_address_r_cscrm_street_type_c":"ST","cscrm_installation_addressr_street_number_from_calc_c":"0","cscrm_installation_address_r_street_number_to_c":"0"}';       
        insert prodConfigReq;*/
        cscfga__Product_Category__c prodCat= new cscfga__Product_Category__c();
        prodCat.Name = 'Modular Products';
        insert prodCat;
        
        
    }
    @isTest
    Public static void testSuccessCwp(){
        Test.startTest();
        List<String> param=new List<String>();
        Test.setMock(HttpCalloutMock.class, new MockTramasBatchEligibilityCheckService ('success_acknowledgement'));
        //EDGE-80772 - START SolutionConsole RetroFit for TM1
        cscfga__Product_Configuration__c prodConfig = [SELECT id FROM cscfga__Product_Configuration__c where name= 'IP Site' LIMIT 1];
        
        Attachment att = new Attachment();
        att.Name = 'TransitionJSONData.json';
        //EDGE-80772 - SolutionConsole RetroFit for TM1
        att.ParentId = prodConfig.Id; 
        att.Body = Blob.valueOf(serviceDTO_V2);
        insert att;
        
        Map<String,ReplicatorGetServiceDataObject_V2> mapPcrToServiceDTO = new Map<String,ReplicatorGetServiceDataObject_V2>();
        ReplicatorGetServiceDataObject_V2 ServiceDTOrecord = ReplicatorGetServiceDataObject_V2.parse(serviceDTO_V2);
        if(prodConfig !=null) 
            mapPcrToServiceDTO.put(prodConfig.id,ServiceDTOrecord);
        TramasBatchEligibilityCheckService.constructBatchCreateRequest(mapPcrToServiceDTO,'cwp');
        
        //TramasBatchEligibilityCheckService.sendEligibilityCheckRequest(paramRequest[0].params__c);
         List<Integration_Record__c> paramRequest=[SELECT Id, params__c, paramPayload__c FROM Integration_Record__c limit 1];
        param.add(paramRequest[0].params__c);
         new TramasBatchHandler().executeWork(param);
         new TM2TramasExecution().executeWork(param);
       // TramasElgibilityCallbackResponse__c responserecord = [SELECT id,UUID__c,Product_Configuration__c FROM TramasElgibilityCallbackResponse__c LIMIT 1];
        Test.stopTest();
        //Assert, to check if a response-record is created with the related PC-record 
        System.assert(!paramRequest.isEmpty()); 
        //EDGE-80772 - END SolutionConsole RetroFit for TM1
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
        new TramasBatchHandler().executeWork(param);       
        Test.stopTest();
        //List<TramasElgibilityCallbackResponse__c> responserecord = [SELECT id,TranasactionId__c FROM TramasElgibilityCallbackResponse__c LIMIT 1];      
        System.assert(paramRequest.isEmpty());        
    }
}