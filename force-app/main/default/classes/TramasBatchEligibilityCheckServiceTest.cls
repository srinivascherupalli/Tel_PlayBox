/*
* @Author : Rahul
* @Date : 5 Nov 2019
* @Desc : Test class for TM1EligibilityCheckServiceV2
* @Jira Cloud  : EDGE-92541
*/


@isTest
public class TramasBatchEligibilityCheckServiceTest{
    //Start of DIGI-33080 by Abhishek(Osaka)
    public static Map<string,Sobject> MTMMetadataUtilityMap = ConstantMetadataUtility.getConstantMetadataUtilityRecords('MTM_Metadata_Utility__mdt');
    public static String IoT_Dormancy = String.valueOf(MTMMetadataUtilityMap.get('IoT_Dormancy').get('Value__c'));
    public static String TramasRecName_IoT = String.valueOf(MTMMetadataUtilityMap.get('TramasRecName_IoT').get('Value__c'));
    //End of DIGI-33080

    static String serviceDTO_V2 = '{ "Source_System_Id": "Replicator", "site": [ { "siteName": "", "productList": [ { "serviceList": [ { "Service_Type": "voice", "service": [ { "User_Type": "", "serviceExtension": [ { "Reason": "", "Reserve_status": "", "Services_To": "0385990499", "Services_From": "0314419400", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "checkValue": false } ], "Service_Type": "voice", "Service_Id": "0314419400", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "", "In_Flight_Flag": null, "Reason": "", "Reserve_status": "", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "", "Association_Role": "AUX" } ], "disableCheck": null, "checkValue": false, "transitionId": null } ], "Product_Type": "isdn2", "eligibilityStatus": "Ready for assessment", "eligibilityReason": null, "disableCheck": null, "checkValue": true } ], "Error_Description": "", "Error_Code": "", "ADBOR_Id": "50484597" } ], "serviceCount": 0, "Error_Description": "", "Error_Code": "", "Correlation_Id": "90baead7919646040e", "CIDN": "3867475038" }';
    @testsetup static void testsetUpData(){
       Account acc = new Account(Name = 'Test Account for CBQ');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        System.assert(acc !=null); 
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
        
        //Start of EDGE-188064
        cscfga__Product_Basket__c prodBasketRec = new cscfga__Product_Basket__c();
        prodBasketRec.Name = 'TM1 Mobile Basket';
        prodBasketRec.csbb__Account__c = acc.Id;
        prodBasketRec.cscfga__Opportunity__c = opp.Id;
        prodBasketRec.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        insert prodBasketRec;
        
        cscfga__Product_Configuration__c configRec = new cscfga__Product_Configuration__c();
        configRec.cscfga__Product_Basket__c = prodBasketRec.Id;
        configRec.name= 'Committed Data-Data SIM $40';
        configRec.cscfga__Description__c = 'TM1 Mobile Test description';
        insert configRec;
        //End of EDGE-188064
        
        /*TramasElgibilityCallbackResponse__c tramasNguc=new TramasElgibilityCallbackResponse__c();
        tramasNguc.TranasactionId__c='418368ec-8b40-45a2-a93a-aa30a59b3787';
        insert tramasNguc;*/
     
        
    }
    @isTest
    Public static void testSuccessCwp(){
        Test.startTest();
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
        List<Integration_Record__c> paramRequest=[SELECT Id, params__c, paramPayload__c FROM Integration_Record__c LIMIT 1];
        TramasBatchEligibilityCheckService.sendEligibilityCheckRequest(paramRequest[0].params__c);
        TramasBatchEligibilityCheckService.sendBulkEligibilityCheckRequest(paramRequest[0].params__c);
       // TramasElgibilityCallbackResponse__c responserecord = [SELECT id,UUID__c,Product_Configuration__c FROM TramasElgibilityCallbackResponse__c LIMIT 1];
        Test.stopTest();
        //Assert, to check if a response-record is created with the related PC-record 
        System.assert(!paramRequest.isEmpty()); 
        //EDGE-80772 - END SolutionConsole RetroFit for TM1
    }
    
    @isTest
    Public static void testfailureCwp(){
        Test.startTest();
        String serviceDTO='{ "Source_System_Id": "Replicator", "site": [ { "siteName": "", "productList": [ { "serviceList": [ { "Service_Type": "voice", "service": [ { "User_Type": "", "serviceExtension": [ { "Reason": "", "Reserve_status": "", "Services_To": "0385990499", "Services_From": "0314419400", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "checkValue": false } ], "Service_Type": "voice", "Service_Id": "0314419400", "IsInflight": null, "In_Flight_Order_Id": "", "In_Flight_Legacy_System": "", "In_Flight_Flag": null, "Reason": "", "Reserve_status": "", "eligibilityStatus": "", "eligibilityReason": "", "disableCheck": null, "Directory_Option": null, "checkValue": false, "Association_Type": "", "Association_Role": null } ], "disableCheck": null, "checkValue": false, "transitionId": "" } ], "Product_Type": "isdn2", "eligibilityStatus": "Ready for assessment", "eligibilityReason": null, "disableCheck": null, "checkValue": false } ], "Error_Description": "", "Error_Code": "", "ADBOR_Id": "50484597" } ], "serviceCount": 0, "Error_Description": "", "Error_Code": "", "Correlation_Id": "90baead7919646040e", "CIDN": "3867475038" }';
        Test.setMock(HttpCalloutMock.class, new MockTramasBatchEligibilityCheckService ('success_Error'));
        //EDGE-80772 - START SolutionConsole RetroFit for TM1
        cscfga__Product_Configuration__c prodConfig = [SELECT id FROM cscfga__Product_Configuration__c where name= 'IP Site' LIMIT 1];
        
        Attachment att = new Attachment();
        att.Name = 'TransitionJSONData.json';
        //EDGE-80772 - SolutionConsole RetroFit for TM1
        att.ParentId = prodConfig.Id; 
        att.Body = Blob.valueOf(serviceDTO);
        insert att;
        System.assert(att != null);
        Map<String,ReplicatorGetServiceDataObject_V2> mapPcrToServiceDTO = new Map<String,ReplicatorGetServiceDataObject_V2>();
        ReplicatorGetServiceDataObject_V2 ServiceDTOrecord = ReplicatorGetServiceDataObject_V2.parse(serviceDTO);
        if(prodConfig !=null) 
            mapPcrToServiceDTO.put(prodConfig.id,ServiceDTOrecord);
        TramasBatchEligibilityCheckService.constructBatchCreateRequest(mapPcrToServiceDTO,'cwp');
        List<Integration_Record__c> paramRequest=[SELECT Id, params__c, paramPayload__c FROM Integration_Record__c LIMIT 1];
       // TramasBatchEligibilityCheckService.sendEligibilityCheckRequest(paramRequest[0].params__c);
       // TramasBatchEligibilityCheckService.sendBulkEligibilityCheckRequest(paramRequest[0].params__c);
       // TramasElgibilityCallbackResponse__c responserecord = [SELECT id,UUID__c,Product_Configuration__c FROM TramasElgibilityCallbackResponse__c LIMIT 1];
        Test.stopTest();
        //Assert, to check if a response-record is created with the related PC-record 
        //System.assert(paramRequest.isEmpty()); 
        //EDGE-80772 - END SolutionConsole RetroFit for TM1
    }
    
    @isTest
    Public static void i(){
        String transitionJson='{ "Source_System_Id": "Replicator", "serviceCount": 0, "productList": [ { "site": [ { "siteName": null, "serviceList": [ { "Service_Type": "NORM", "groupType": [ { "transitionId": "", "service": [ { "sim_serial_number": null, "serviceExtensions": [ { "serviceExtensionFrom": "0362835301", "serviceExtensionTo": "0362835320", "eligibilityStatus":null, "eligibilityReason":null }, { "serviceExtensionFrom": "0362835321", "serviceExtensionTo": "0362835399", "eligibilityStatus":null, "eligibilityReason":null } ], "service_type_code": null, "service_type": "NORM", "eligibilityStatus ":null, "eligibilityReason ":null, "service_status": "AC", "Service_Id": "4333432424324", "Reserve_status": null, "replicatorUpdateDateTime": "2019-07-26 11:11:49.593", "Reason": null, "service_association_role": "Prime", "plan_name": "Go Business Data SIM $5", "message_bank": "Video MessageBank", "international_roaming": "Access to Use Mobile Overseas", "imsi_number": null, "idd": null, "Eligibility_status": null, "directory_listing": null, "devices": [ { "physicalId": "89610163267640000029", "networkId": "505013485041069", "deviceType": "sim" }, { "physicalId": "89610163267640000029", "networkId": "505013485041069", "deviceType": "sim" } ], "contract_term": "36", "calling_line_identifier": "ON", "accountDetails": { "serviceWithEtcFlag": "N", "creditManagementFlag": "N", "complexBillingIndicator": "N", "accountNumber": "2212356398" } } ], "groupId": "mobileGroup", "disableCheck": null, "checkValue": true } ], "EligibilityStatus": "Eligible", "EligibilityReason": "", "disableCheck": false, "checkValue": true, "checkReserved": false } ], "Error_Description": null, "Error_Code": null, "ADBOR_Id": "0" }, { "siteName": null, "serviceList": [ { "Service_Type": "NORM", "groupType": [ { "transitionId": null, "service": [ { "sim_serial_number": null, "serviceExtensions": [ { "serviceExtensionFrom": "0362835302", "serviceExtensionTo": "0362835329", "eligibilityStatus":null, "eligibilityReason":null }, { "serviceExtensionFrom": "0362835324", "serviceExtensionTo": "03628353100", "eligibilityStatus":null, "eligibilityReason":null } ], "service_type_code": null, "service_type": "NORM", "service_status": "AC", "Service_Id": "2323232388", "Reserve_status": null, "replicatorUpdateDateTime": "2019-07-26 11:11:49.593", "Reason": null, "eligibilityStatus":null, "eligibilityReason":null, "service_association_role": "Prime", "plan_name": "Go Business Data SIM $5", "message_bank": "Video MessageBank", "international_roaming": "Access to Use Mobile Overseas", "imsi_number": null, "idd": null, "Eligibility_status": null, "directory_listing": null, "devices": [ { "physicalId": "89610163267640000029", "networkId": "505013485041069", "deviceType": "sim" }, { "physicalId": "89610163267640000029", "networkId": "505013485041069", "deviceType": "sim" } ], "contract_term": "36", "calling_line_identifier": "ON", "accountDetails": { "serviceWithEtcFlag": "N", "creditManagementFlag": "N", "complexBillingIndicator": "N", "accountNumber": "2212356398" } } ], "groupId": "mobileGroup", "disableCheck": null, "checkValue": true } ], "EligibilityStatus": "Eligible", "EligibilityReason": "", "disableCheck": false, "checkValue": true, "checkReserved": false } ], "Error_Description": null, "Error_Code": null, "ADBOR_Id": "0" } ], "Product_Type": "ISDN30", "eligibilityStatus": null, "eligibilityReason": null, "disableCheck": null, "checkValue": null } ], "Error_Description": "", "Error_Code": "", "Correlation_Id": "5465764671208", "CIDN": "1234567890" }';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockTramasBatchEligibilityCheckService ('success_acknowledgement'));
        //EDGE-80772 - START SolutionConsole RetroFit for TM1
        cscfga__Product_Configuration__c prodConfig = [SELECT id FROM cscfga__Product_Configuration__c where name='Unified Communication Enterprise' LIMIT 1];
        
        Attachment att = new Attachment();
        att.Name = system.label.NgUcTransitionName;
        //EDGE-80772 - SolutionConsole RetroFit for TM1
        att.ParentId = prodConfig.Id; 
        att.Body = Blob.valueOf(transitionJson);
        insert att;
         
        
        TramasBatchEligibilityCheckService.constructNgucBatchRequest(transitionJson,prodConfig.id,'nguc');
        List<Integration_Record__c> paramRequest=[SELECT Id, params__c, paramPayload__c FROM Integration_Record__c LIMIT 1];
        system.debug('paramRequest.paramPayload__c '+paramRequest[0].paramPayload__c );
        TramasBatchEligibilityCheckService.sendEligibilityCheckRequest(paramRequest[0].params__c);
       // TramasElgibilityCallbackResponse__c responserecord = [SELECT id,UUID__c,Product_Configuration__c FROM TramasElgibilityCallbackResponse__c LIMIT 1];
        Test.stopTest();
        //Assert, to check if a response-record is created with the related PC-record 
       System.assert(!paramRequest.isEmpty());
        system.assert((paramRequest[0].paramPayload__c).Contains('0362835302')==true);//nguc transition Issue fix  
         system.assert((paramRequest[0].paramPayload__c).Contains('0362835302-0362835329')==true);//EDGE-159089 fix
        //EDGE-80772 - END SolutionConsole RetroFit for TM1
    }
    
    /**********************************************************
     * Story: EDGE-199057
     * Team : Osaka
     * Description: Positive Test method for executionTransitionService.
     * *********************************************************/
    @isTest
    public static void executionTransitionServiceTestPositive(){
        String actionType = 'validate';
        String transitionId = '9c8ed1c3-f5b9-4f4e-9f56-2e3c7e2762d7';
        List<String> transactionIdList = new List<String>();
        MobileTramasElgibility__c mobileTramRec = new MobileTramasElgibility__c();
        transactionIdList.add(transitionId);
        Map<id, List<String>> PcIdTransitionIDListMap = new Map<id, List<String>> ();
        cscfga__Product_Configuration__c configRec = new cscfga__Product_Configuration__c();
        configRec = [select id,cscfga__Product_Basket__c from cscfga__Product_Configuration__c where name = 'Committed Data-Data SIM $40'];
        String productConfigId = configRec.Id;
        PcIdTransitionIDListMap.put(productConfigId,transactionIdList);
        Test.startTest();
        TramasBatchEligibilityCheckService.executionTransitionService(PcIdTransitionIDListMap,actionType);
        mobileTramRec = [SELECT id, Type__c from MobileTramasElgibility__c where Product_Configuration__c = :productConfigId];
        System.assert(mobileTramRec.Type__c == 'TM1');
        Test.stopTest();
    }
    
    /**********************************************************
     * Story: EDGE-199057
     * Team : Osaka
     * Description: Negative Test method for executionTransitionService.
     * *********************************************************/
    @isTest
    public static void executionTransitionServiceTestNegative(){
        String actionType = '';
        String transitionId = '9c8ed1c3-f5b9-4f4e-9f56-2e3c7e2762d7';
        List<String> transactionIdList = new List<String>();
        MobileTramasElgibility__c mobileTramRec = new MobileTramasElgibility__c();
        transactionIdList.add(transitionId);
        Map<id, List<String>> PcIdTransitionIDListMap = new Map<id, List<String>> ();
        cscfga__Product_Configuration__c configRec = new cscfga__Product_Configuration__c();
        configRec = [select id,cscfga__Product_Basket__c from cscfga__Product_Configuration__c where name = 'Committed Data-Data SIM $40'];
        String productConfigId = configRec.Id;
        PcIdTransitionIDListMap.put(productConfigId,transactionIdList);
        Test.startTest();
        TramasBatchEligibilityCheckService.executionTransitionService(PcIdTransitionIDListMap,actionType);
        mobileTramRec = [SELECT id, Type__c from MobileTramasElgibility__c where Product_Configuration__c = :productConfigId];
        System.assert(mobileTramRec.Type__c != 'TM1');
        Test.stopTest();
    }
    /**********************************************************
     * Story: EDGE-198380
     * Team : Nirvana
     * Description: Test method for TM0 execution callout failure.
     * *********************************************************/
    @isTest
    Public static void testTM0ExecutionfailureNguc(){
        Test.startTest();
        String transitionJson='{ "Source_System_Id": "Replicator", "serviceCount": 0, "productList": [ { "site": [ { "siteName": null, "serviceList": [ { "Service_Type": "NORM", "groupType": [ { "transitionId": "", "service": [ { "sim_serial_number": null, "serviceExtensions": [ { "serviceExtensionFrom": "0362835301", "serviceExtensionTo": "0362835320", "eligibilityStatus":null, "eligibilityReason":null }, { "serviceExtensionFrom": "0362835321", "serviceExtensionTo": "0362835399", "eligibilityStatus":null, "eligibilityReason":null } ], "service_type_code": null, "service_type": "NORM", "eligibilityStatus ":null, "eligibilityReason ":null, "service_status": "AC", "Service_Id": "4333432424324", "Reserve_status": null, "replicatorUpdateDateTime": "2019-07-26 11:11:49.593", "Reason": null, "service_association_role": "Prime", "plan_name": "Go Business Data SIM $5", "message_bank": "Video MessageBank", "international_roaming": "Access to Use Mobile Overseas", "imsi_number": null, "idd": null, "Eligibility_status": null, "directory_listing": null, "devices": [ { "physicalId": "89610163267640000029", "networkId": "505013485041069", "deviceType": "sim" }, { "physicalId": "89610163267640000029", "networkId": "505013485041069", "deviceType": "sim" } ], "contract_term": "36", "calling_line_identifier": "ON", "accountDetails": { "serviceWithEtcFlag": "N", "creditManagementFlag": "N", "complexBillingIndicator": "N", "accountNumber": "2212356398" } } ], "groupId": "mobileGroup", "disableCheck": null, "checkValue": true } ], "EligibilityStatus": "Eligible", "EligibilityReason": "", "disableCheck": false, "checkValue": true, "checkReserved": false } ], "Error_Description": null, "Error_Code": null, "ADBOR_Id": "0" }, { "siteName": null, "serviceList": [ { "Service_Type": "NORM", "groupType": [ { "transitionId": null, "service": [ { "sim_serial_number": null, "serviceExtensions": [ { "serviceExtensionFrom": "0362835302", "serviceExtensionTo": "0362835329", "eligibilityStatus":null, "eligibilityReason":null }, { "serviceExtensionFrom": "0362835324", "serviceExtensionTo": "03628353100", "eligibilityStatus":null, "eligibilityReason":null } ], "service_type_code": null, "service_type": "NORM", "service_status": "AC", "Service_Id": "2323232388", "Reserve_status": null, "replicatorUpdateDateTime": "2019-07-26 11:11:49.593", "Reason": null, "eligibilityStatus":null, "eligibilityReason":null, "service_association_role": "Prime", "plan_name": "Go Business Data SIM $5", "message_bank": "Video MessageBank", "international_roaming": "Access to Use Mobile Overseas", "imsi_number": null, "idd": null, "Eligibility_status": null, "directory_listing": null, "devices": [ { "physicalId": "89610163267640000029", "networkId": "505013485041069", "deviceType": "sim" }, { "physicalId": "89610163267640000029", "networkId": "505013485041069", "deviceType": "sim" } ], "contract_term": "36", "calling_line_identifier": "ON", "accountDetails": { "serviceWithEtcFlag": "N", "creditManagementFlag": "N", "complexBillingIndicator": "N", "accountNumber": "2212356398" } } ], "groupId": "mobileGroup", "disableCheck": null, "checkValue": true } ], "EligibilityStatus": "Eligible", "EligibilityReason": "", "disableCheck": false, "checkValue": true, "checkReserved": false } ], "Error_Description": null, "Error_Code": null, "ADBOR_Id": "0" } ], "Product_Type": "ISDN30", "eligibilityStatus": null, "eligibilityReason": null, "disableCheck": null, "checkValue": null } ], "Error_Description": "", "Error_Code": "", "Correlation_Id": "5465764671208", "CIDN": "1234567890" }';
        Test.setMock(HttpCalloutMock.class, new MockTramasBatchEligibilityCheckService ('error_422'));
        cscfga__Product_Configuration__c prodConfig = [SELECT id FROM cscfga__Product_Configuration__c where name='Unified Communication Enterprise' LIMIT 1];
        Attachment att = new Attachment();
        att.Name = system.label.NgUcTransitionName;
        att.ParentId = prodConfig.Id; 
        att.Body = Blob.valueOf(transitionJson);
        insert att;
        TramasBatchEligibilityCheckService.constructNgucBatchRequest(transitionJson,prodConfig.id,'nguc');
        List<Integration_Record__c> paramRequest=[SELECT Id, params__c, paramPayload__c FROM Integration_Record__c LIMIT 1];
        TramasBatchEligibilityCheckService.sendEligibilityCheckRequest(paramRequest[0].params__c);
        System.assert(!paramRequest.isEmpty());
        Test.stopTest();  
        
    }
    /***********************************************************
     * Story: EDGE-198375
     * Team : Nirvana
     * Description: Test method for TM1 execution callout failure.
     * *********************************************************/
    @isTest
    Public static void testTM1ExecutionfailureNguc(){
         TramasElgibilityCallbackResponse__c mobileTramRec = new TramasElgibilityCallbackResponse__c();
        Test.startTest();
        String transitionJson='{ "Source_System_Id": "Replicator", "serviceCount": 0, "productList": [ { "site": [ { "siteName": null, "serviceList": [ { "Service_Type": "NORM", "groupType": [ { "transitionId": "", "service": [ { "sim_serial_number": null, "serviceExtensions": [ { "serviceExtensionFrom": "0362835301", "serviceExtensionTo": "0362835320", "eligibilityStatus":null, "eligibilityReason":null }, { "serviceExtensionFrom": "0362835321", "serviceExtensionTo": "0362835399", "eligibilityStatus":null, "eligibilityReason":null } ], "service_type_code": null, "service_type": "NORM", "eligibilityStatus ":null, "eligibilityReason ":null, "service_status": "AC", "Service_Id": "4333432424324", "Reserve_status": null, "replicatorUpdateDateTime": "2019-07-26 11:11:49.593", "Reason": null, "service_association_role": "Prime", "plan_name": "Go Business Data SIM $5", "message_bank": "Video MessageBank", "international_roaming": "Access to Use Mobile Overseas", "imsi_number": null, "idd": null, "Eligibility_status": null, "directory_listing": null, "devices": [ { "physicalId": "89610163267640000029", "networkId": "505013485041069", "deviceType": "sim" }, { "physicalId": "89610163267640000029", "networkId": "505013485041069", "deviceType": "sim" } ], "contract_term": "36", "calling_line_identifier": "ON", "accountDetails": { "serviceWithEtcFlag": "N", "creditManagementFlag": "N", "complexBillingIndicator": "N", "accountNumber": "2212356398" } } ], "groupId": "mobileGroup", "disableCheck": null, "checkValue": true } ], "EligibilityStatus": "Eligible", "EligibilityReason": "", "disableCheck": false, "checkValue": true, "checkReserved": false } ], "Error_Description": null, "Error_Code": null, "ADBOR_Id": "0" }, { "siteName": null, "serviceList": [ { "Service_Type": "NORM", "groupType": [ { "transitionId": null, "service": [ { "sim_serial_number": null, "serviceExtensions": [ { "serviceExtensionFrom": "0362835302", "serviceExtensionTo": "0362835329", "eligibilityStatus":null, "eligibilityReason":null }, { "serviceExtensionFrom": "0362835324", "serviceExtensionTo": "03628353100", "eligibilityStatus":null, "eligibilityReason":null } ], "service_type_code": null, "service_type": "NORM", "service_status": "AC", "Service_Id": "2323232388", "Reserve_status": null, "replicatorUpdateDateTime": "2019-07-26 11:11:49.593", "Reason": null, "eligibilityStatus":null, "eligibilityReason":null, "service_association_role": "Prime", "plan_name": "Go Business Data SIM $5", "message_bank": "Video MessageBank", "international_roaming": "Access to Use Mobile Overseas", "imsi_number": null, "idd": null, "Eligibility_status": null, "directory_listing": null, "devices": [ { "physicalId": "89610163267640000029", "networkId": "505013485041069", "deviceType": "sim" }, { "physicalId": "89610163267640000029", "networkId": "505013485041069", "deviceType": "sim" } ], "contract_term": "36", "calling_line_identifier": "ON", "accountDetails": { "serviceWithEtcFlag": "N", "creditManagementFlag": "N", "complexBillingIndicator": "N", "accountNumber": "2212356398" } } ], "groupId": "mobileGroup", "disableCheck": null, "checkValue": true } ], "EligibilityStatus": "Eligible", "EligibilityReason": "", "disableCheck": false, "checkValue": true, "checkReserved": false } ], "Error_Description": null, "Error_Code": null, "ADBOR_Id": "0" } ], "Product_Type": "ISDN30", "eligibilityStatus": null, "eligibilityReason": null, "disableCheck": null, "checkValue": null } ], "Error_Description": "", "Error_Code": "", "Correlation_Id": "5465764671208", "CIDN": "1234567890" }';
        Test.setMock(HttpCalloutMock.class, new MockTramasBatchEligibilityCheckService ('success_acknowledgement'));
        cscfga__Product_Configuration__c prodConfig = [SELECT id FROM cscfga__Product_Configuration__c where name='Unified Communication Enterprise' LIMIT 1];
        Attachment att = new Attachment();
        att.Name = system.label.NgUcTransitionName;
        att.ParentId = prodConfig.Id; 
        att.Body = Blob.valueOf(transitionJson);
        insert att;
        TramasBatchEligibilityCheckService.constructNgucBatchRequest(transitionJson,prodConfig.id,'nguc');
        List<Integration_Record__c> paramRequest=[SELECT Id, params__c, paramPayload__c FROM Integration_Record__c LIMIT 1];
        TramasBatchEligibilityCheckService.sendEligibilityCheckRequest(paramRequest[0].params__c);
        Test.setMock(HttpCalloutMock.class, new MockTramasBatchEligibilityCheckService ('error_422'));

       TramasBatchEligibilityCheckService.sendBulkEligibilityCheckRequest(paramRequest[0].params__c);
        System.assert(!paramRequest.isEmpty());
        Test.stopTest();
        
    }
    /**********************************************************
     * Story: FIGI-33080
     * Team : Osaka
     * Developer: Abhishek
     * *********************************************************/
    @isTest
    public static void executionTransitionServiceTestIoT(){
        String actionType = 'validate';
        String transitionId = '9c8ed1c3-f5b9-4f4e-9f56-2e3c7e2762d7';
        String product_family = 'iot' ;
        List<String> transactionIdList = new List<String>();
        MobileTramasElgibility__c mobileTramRec = new MobileTramasElgibility__c();
        transactionIdList.add(transitionId);
        Map<id, List<String>> PcIdTransitionIDListMap = new Map<id, List<String>> ();
        cscfga__Product_Configuration__c configRec = new cscfga__Product_Configuration__c();
        configRec = [select id,cscfga__Product_Basket__c from cscfga__Product_Configuration__c where name = 'Committed Data-Data SIM $40'];
        String productConfigId = configRec.Id;
        PcIdTransitionIDListMap.put(productConfigId,transactionIdList);
        Test.startTest();
        TramasBatchEligibilityCheckService.createMobileTramasRec(PcIdTransitionIDListMap,actionType,product_family);
        mobileTramRec = [SELECT id,Name, Type__c from MobileTramasElgibility__c where Product_Configuration__c = :productConfigId];
        if(IoT_Dormancy == 'true'){
            System.assert(mobileTramRec.Name == TramasRecName_IoT);
        }
        else{
            System.assert(mobileTramRec.Name != TramasRecName_IoT);
        }
        Test.stopTest();
    }
    
}