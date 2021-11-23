/**================================================================
 * Appirio, Inc
 * Name: Orchestration_UtilityTest
 * Main Class : Orchestration_Utility
 * Created Date: JUNE 19, 2020
 * Created By: Shweta Khandelwal
 ==================================================================*/
 // Comment for TC
@isTest(SeeAllData=false)
private class Orchestration_UtilityTest {


    @Testsetup
    private static void dataSetup() {
         //Declare different list to store data 
        List<CSPOFA__Orchestration_Process__c> processList = new List<CSPOFA__Orchestration_Process__c>();
        List<CSPOFA__Orchestration_Process_Template__c> processTempList = new List<CSPOFA__Orchestration_Process_Template__c>();
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<account> accountList = new List<account>();
        List<csord__Order_Request__c> orderReqList = new List<csord__Order_Request__c>();
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        List<csord__Subscription__c> subscriptionListNew = new List<csord__Subscription__c>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        list<cscfga__Product_Configuration__c> productconfiglistList = new List<cscfga__Product_Configuration__c>();
        list<csord__Solution__c> solutionList = new List<csord__Solution__c>();
        List<csord__Service__c> servlist = new List<csord__Service__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        list<Attachment> attachmentList = new List<Attachment>();
        EnvironmentVariable__c env = new EnvironmentVariable__c();
        
        //Creating data for process
        governerLimit = Orchestration_TestUtility.buildLimits();
        accountList = Orchestration_TestUtility.buildAccount(true, 1);
        orderReqList = Orchestration_TestUtility.buildOrderRequest(true, 1);
        orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, true, 3);
        processTempList = Orchestration_TestUtility.buildProcessTemplate(true, 1);

        productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(true, 1);

        solutionList = Orchestration_TestUtility.buildSolution(true, 1);
        subscriptionList = Orchestration_TestUtility.buildSubscription(true, 3, accountList[0].id, orderList, productconfiglistList[0].id, solutionList[0].id);

        servlist = Orchestration_TestUtility.buildService(false, 3, subscriptionList[0].id, orderReqList[0].id, orderList[0].id, productconfiglistList[0].id);
        servlist[0].Transition_Id__c = 'b9a61db0-8500-4e6f-9ad5-ffe36e8cbccf';
         servlist[0].name ='TEST7';
        servlist[1].Transition_Id__c = 'b9a61db0-8500-4e6f-9ad5-ffe36e8cbccf';
        servlist[2].Transition_Id__c = 'b9a61db0-8500-4e6f-9ad5-ffe36e8cbccf';
        servlist[0].Offer_Type__c = 'PSTN';
        servlist[1].Offer_Type__c = 'PSTN';
        servlist[2].Offer_Type__c = 'PSTN';

        servlist[2].csordtelcoa__Replaced_Service__c = null;
        insert servlist;
        
        //Build Process Records through wich the Steps will be executed.
        processList = Orchestration_TestUtility.buildProcess(false, 3, processTempList[0].id, orderList, subscriptionList, accountList[0].id, servlist[0].id);
        processList[1].csordtelcoa__Service__c = servlist[2].id;
        processList[2].Order__c = null;
        insert processList;

        orchStepList = Orchestration_TestUtility.buildOrchStep(false, 3, processList);
        orchStepList[1].CSPOFA__Orchestration_Process__c = processList[1].Id;
        orchStepList[0].JSON__c = '{"' + OrchestratorConstants.OrchestrationObjectType.Order + '":["' + orderList[0].id + '"]}';
        orchStepList[1].JSON__c = '{"' + OrchestratorConstants.OrchestrationObjectType.Order + '":["' + orderList[0].id + '"]}';
        orchStepList[2].JSON__c = '{"' + OrchestratorConstants.OrchestrationObjectType.Order + '":["' + orderList[0].id + '"]}';
        insert orchStepList;

        attachmentList = Orchestration_TestUtility.buildAttachment(true, 2, servlist, productconfiglistList[0].id);
        env = Orchestration_TestUtility.buildENV(true, 1);
    }
    
    // Checking Attachment size of NGUC & DTO
    private static testMethod void ProcessTest() {
        ReplicatorGetServiceDataObject_V2.serviceListDTO serviceListDTO = new ReplicatorGetServiceDataObject_V2.serviceListDTO();
        serviceListDTO.Service_Type = 'Voice';
        serviceListDTO.service = new List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2>();
        serviceListDTO.checkValue = false;
        serviceListDTO.disableCheck = false;

        csord__Service__c service = [SELECT ID, Offer_Type__c, Transition_Id__c FROM csord__Service__c WHERE Transition_Id__c != null AND Offer_Type__c = 'PSTN' LIMIT 1];
        //Assert to check service
        System.assert(service != null);

        List<CSPOFA__Orchestration_Process_Template__c> orctemp = [SELECT Id, Name FROM CSPOFA__Orchestration_Process_Template__c LIMIT 1];
        //Orchestration_Utility utility = new Orchestration_Utility();
        Orchestration_Utility.HighVolumeOrderCheck();
        Orchestration_Utility.getUID();
        Orchestration_Utility.getRequestTimeDifference(Datetime.newInstance(1960, 2, 17), Datetime.newInstance(1960, 2, 19));
        //Orchestration_Utility.generateGuid();
        Orchestration_Utility.getOrchestrationTemplates(new List<String>{ orctemp[0].Name });
        String json =
            '{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"95f3f970-3828-4bae-b219-b8b2089ddf02",' +
            '"productConfigurationId":"a3T0l0000004qK0EAI","name":"IP VPN Port_Fulfilment","instanceId":"",' +
            '"guid":"fd163885-4b6a-5b7f-a387-3d12bae7d2a7","endDate":"","description":"","code":"PS_000030_Fulfilment",' +
            '"attributes":{"Class of Service":"DCOS","Port Role":"Primary","Multicast Enabled":"FALSE","__targetSystem":"FULFILMENT"},' +
            '"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"07cbfa3f-f93a-4962-83fb-c2c41b156cd4",' +
            '"productConfigurationId":"a3T0l0000004qK0EAI","name":"Telstra Fibre Access_Fulfilment","instanceId":"",' +
            '"guid":"8609e29f-502c-d0e6-3a33-7252111e2f9a","endDate":"","description":"","code":"PS_000027_Fulfilment",' +
            '"attributes":{"IP Access Configuration":"Single Uplink","Access Role":"Primary","Class of Service":"DCOS","Multicast Enabled":"FALSE",' +
            '"__targetSystem":"FULFILMENT"},"additionalAttributes":{}}],"serviceId":"a4e0l00000006IJAAY","legacyAttributes":[]}';

        String ngucDTOService =
            '{ "CIDN": "3807484688", "Correlation_Id": "a61801573fff96f536", "Error_Code": "", "Error_Description": "", "productList": [ ' +
            '{ "checkValue": null, "disableCheck": null, "eligibilityReason": null, "eligibilityStatus": null, "Product_Type": "PSTN", "site": ' +
            '[ { "ADBOR_Id": "50487631", "Error_Code": null, "Error_Description": null, "linkedSiteId": "", "serviceList": [ { "checkReserved": false, ' +
            '"checkValue": false, "disableCheck": null, "EligibilityReason": null, "EligibilityStatus": null, "groupType": [ { "checkValue": false, ' +
            '"disableCheck": null, "groupId": "0360001381", "service": [ { "accountDetails": null, "association_type": "MULTI NUMBER", ' +
            '"calling_line_identifier": null, "contract_term": null, "devices": null, "directory_listing": null, "Eligibility_status": "Eligible", ' +
            '"eligibilityReason": null, "eligibilityStatus": null, "idd": null, "imsi_number": null, "international_roaming": null, "message_bank": null, ' +
            '"plan_name": null, "Reason": null, "Redirection_product": null, "replicatorUpdateDateTime": "2020-05-05 03:21:35.96", "Reserve_status": null, ' +
            '"Reserved_ranges": null, "service_association_role": "Primary", "Service_Id": "0360001381", "service_status": null, "service_type": "voice", ' +
            '"service_type_code": null, "serviceExtensions": [{ "checkReserved": false, ' +
            '"eligibilityReason": null, "eligibilityStatus": "Eligible", "Reason": null, "Reserve_status": null, "serviceExtensionFrom": "0360001383", ' +
            '"serviceExtensionTo": "0360001392" } ], "silent_line": null, "sim_serial_number": null, "tenancy_name": null }, { "accountDetails": null, ' +
            '"association_type": "MULTI NUMBER", "calling_line_identifier": null, "contract_term": null, "devices": null, "directory_listing": null, ' +
            '"Eligibility_status": "Eligible", "eligibilityReason": null, "eligibilityStatus": null, "idd": null, "imsi_number": null, "international_roaming": null, ' +
            '"message_bank": null, "plan_name": null, "Reason": null, "Redirection_product": null, "replicatorUpdateDateTime": "2020-05-05 03:21:35.717", ' +
            '"Reserve_status": null, "Reserved_ranges": null, "service_association_role": "Auxiliary", "Service_Id": "0360001380", "service_status": null, ' +
            '"service_type": "voice", "service_type_code": null, "serviceExtensions": [{ "checkReserved": false, ' +
            '"eligibilityReason": null, "eligibilityStatus": "Eligible", "Reason": null, "Reserve_status": null, "serviceExtensionFrom": "0360001383", ' +
            '"serviceExtensionTo": "0360001392" } ], "silent_line": null, "sim_serial_number": null, "tenancy_name": null } ],' +
            ' "serviceAssociations": null, "transitionId": "b9a61db0-8500-4e6f-9ad5-ffe36e8cbccf" } ], "Service_Type": "voice" } ], "siteName": null } ] }, ' +
            '{ "checkValue": null, "disableCheck": null, "eligibilityReason": null, "eligibilityStatus": null, "Product_Type": "ISDN30", ' +
            '"site": [ { "ADBOR_Id": "50866881", "Error_Code": null, "Error_Description": null, "linkedSiteId": "A_END_ADDRESS", "serviceList": [ { "checkReserved": false, ' +
            '"checkValue": false, "disableCheck": null, "EligibilityReason": null, "EligibilityStatus": null, "groupType": [ { "checkValue": false, "disableCheck": null, ' +
            '"groupId": "0360001382", "service": [ { "accountDetails": null, "association_type": null, "calling_line_identifier": null, "contract_term": null, ' +
            '"devices": null, "directory_listing": null, "Eligibility_status": "Eligible", "eligibilityReason": null, "eligibilityStatus": null, "idd": null, ' +
            '"imsi_number": null, "international_roaming": null, "message_bank": null, "plan_name": null, "Reason": null, "Redirection_product": "Call Forward Variable", ' +
            '"replicatorUpdateDateTime": "2020-05-05 03:21:36.053", "Reserve_status": null, "Reserved_ranges": "Y", "service_association_role": null, ' +
            '"Service_Id": "0360001382", "service_status": null, "service_type": null, "service_type_code": null, "serviceExtensions": [ { "checkReserved": false, ' +
            '"eligibilityReason": null, "eligibilityStatus": "Eligible", "Reason": null, "Reserve_status": null, "serviceExtensionFrom": "0360001383", ' +
            '"serviceExtensionTo": "0360001392" } ], "silent_line": null, "sim_serial_number": null, "tenancy_name": null } ], "serviceAssociations": null, ' +
            '"transitionId": "fd0821c4-3734-4a40-a936-79dffb25d3b1" } ], "Service_Type": null } ], "siteName": null } ] } ], "serviceCount": 0, ' +
            '"Source_System_Id": "Replicator" }';

        String jsonDTO =
            '{"Source_System_Id":"Replicator","site":[{"siteName":"","productList":[{"serviceList":[{"transitionId":null,' +
            '"serviceAssociations":null,"Service_Type":"voice","service":[{"User_Type":"","serviceExtension":[{"Services_To":"0360001315",' +
            '"Services_From":"0360001215","Reserve_status":null,"Reason":null,"eligibilityStatus":"","eligibilityReason":"","disableCheck":null,' +
            '"checkValue":false,"checkReserved":false}],"Service_Type":"voice","Service_Id":"0360001215","Reserve_status":null,"Reason":null,' +
            '"IsInflight":null,"In_Flight_Order_Id":"","In_Flight_Legacy_System":"","In_Flight_Flag":null,"eligibilityStatus":"","eligibilityReason":"",' +
            '"disableCheck":null,"Directory_Option":null,"checkValue":false,"Association_Type":"","Association_Role":null},' +
            '{"User_Type":"","serviceExtension":[{"Services_To":"0360001315",' +
            '"Services_From":"0360001215","Reserve_status":null,"Reason":null,"eligibilityStatus":"","eligibilityReason":"","disableCheck":null,' +
            '"checkValue":false,"checkReserved":false}],"Service_Type":"voice","Service_Id":"0360001215","Reserve_status":null,"Reason":null,' +
            '"IsInflight":null,"In_Flight_Order_Id":"","In_Flight_Legacy_System":"","In_Flight_Flag":null,"eligibilityStatus":"","eligibilityReason":"",' +
            '"disableCheck":null,"Directory_Option":null,"checkValue":false,"Association_Type":"","Association_Role":"Auxiliary"}' +
            '],"disableCheck":null,"checkValue":false,' +
            '"checkReserved":false}],"Product_Type":"PSTN","eligibilityStatus":"Ready for assessment","eligibilityReason":null,"disableCheck":null,"checkValue":true}],' +
            '"Error_Description":"","Error_Code":"","ADBOR_Id":"50457565"}],"serviceCount":2,"Error_Description":"","Error_Code":"",' +
            '"Correlation_Id":"58615fd4302e41123e","CIDN":"4822224558"}';

        TransitionDataDTO transitionDTO = TransitionDataDTO.parse(ngucDTOService);

        Map<String, List<TransitionDataDTO.serviceDTOMobile>> ngUcServiceListMap = new Map<String, List<TransitionDataDTO.serviceDTOMobile>>();

        String uniqueCombo = transitionDTO.productList[0].site[0].serviceList[0].groupType[0].transitionId + '#' + transitionDTO.productList[0].site[0].serviceList[0].groupType[0].groupId;
        ngUcServiceListMap.put(uniqueCombo, transitionDTO.productList[0].site[0].serviceList[0].groupType[0].service);

        Orchestration_Utility.updateSpecStatus(json, 'status', 'propertyValue');
        Orchestration_Utility.getStatus(Label.MO_status_disconnect_pending, 'In Progress');
        Orchestration_Utility.getStatus(Label.MO_status_cancel_pending, 'In Progress');
        Orchestration_Utility.getStatus('Disconnect', 'In Progress');

        ReplicatorGetServiceDataObject_V2 siteDTO = ReplicatorGetServiceDataObject_V2.parse(jsonDTO);
        Map<String, List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2>> servlistmap = new Map<String, List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2>>();

        List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2> servList1 = new List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2>();

        for (ReplicatorGetServiceDataObject_V2.serviceListDTO servlist : siteDTO.site[0].productList[0].serviceList) {
            if (servlistmap.containsKey(siteDTO.site[0].productList[0].Product_Type)) {
                servList1 = servlistmap.get(siteDTO.site[0].productList[0].Product_Type);
                servList1.addAll(servlist.service);
            } else {
                servList1.addAll(servlist.service);
            }
            servlistmap.put(siteDTO.site[0].productList[0].Product_Type, servList1);
        }

        Test.startTest();
        Sobject attach = Orchestration_Utility.getAttachment(service, 'NGUC', null, null, ngUcServiceListMap, null, transitionDTO.productList[0].site[0].serviceList[0].groupType[0].groupId);
        //Assert to check attachment size in case of NGUC
        System.assert(attach != null);

        attach = Orchestration_Utility.getAttachment(service, 'DTO', null, null, null, servlistmap, null);
        //Assert to check attachment size in case of DTO
        System.assert(attach != null);

        Test.stopTest();
    }

    private static testMethod void testAdditionalAttribute() {
         Test.startTest();
        Map<String, String> AttrMap = new Map<String, String>();
        AttrMap.put('CustomerFacingServiceId', '9998887772');
        List<String> targetSystem = new List<String>{ 'FULFILMENT' };
        List<String> specCodes = new List<String>{ 'DMCAT_ProductSpecification_000263' };

        Attachment attach = [SELECT Id, Body FROM Attachment LIMIT 1];

        String bodyToUpdate = Orchestration_Utility.addAdditionalAttribute(attach.body.toString(), AttrMap, targetSystem, specCodes);
        //Assert to check boday updation
        Test.stopTest();
        System.assertEquals(bodyToUpdate.equals('false'), false);
    }
	
	
	 private static testMethod void testSimpleAttributes() {
         Test.startTest();
        Map<String, String> AttrMap = new Map<String, String>();
        AttrMap.put('ContractTerm', '10');
		AttrMap.put('rateExcludeGST', '10.2');
		AttrMap.put('monthlyPrice', '11.2');
      String targetSystem = 'FULFILMENT';
         
        list<csord__Service__c> servlist =  [select id, name from csord__Service__c where name ='TEST7' LIMIT 1];
       Attachment att= new Attachment();
        att.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+servlist[0].id+'","specifications":[{"additionalAttributes":{"CustomerFacingServiceId":"61474663325","parentSpec":"dd7a2442-bd58-20e6-891a-2fd078b3d210","IMSI":"5286475123"},"attributes":{"__targetSystem":"FULFILMENT","IPWirelessProductInstanceID":"NA","BillofMaterialID":"NA","AccessRole":"Primary","CONTEXT":"CUSTOMER","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","SKU":"100119211","SuspensionContext":"NA","MESSAGEBANK":"3G Standard Retail","CustomerFacingServiceId":"","ShippingRequired":"TRUE","IMSI":"","SERVICEPROFILE":"NORMAL","PlanType":"Voice and Data"},"code":"DMCAT_ProductSpecification_000263_Fulfilment","description":"Mobile Access_Fulfilment","endDate":"","guid":"d5291cc4-f4a6-114e-de4d-369bcdf080f8","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","ocsProdID":"T22E_IR_USAGE","currency":"AUD","type":"OC","billingSubtype":"IR","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","billDescription":"IR Pay as you go charge","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000263_DMCAT_NonRecurringCharge_000601_108","chargeId":"DMCAT_NonRecurringCharge_000601"},"code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","description":"Mobile Access_Billing_NonRecurringCharge_000601","endDate":"","guid":"20e0d4f9-d12d-d5f4-7478-b424f5a34f1e","includeBilling":false,"instanceId":"","metadata":{},"name":"263_NRC_601","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"FULFILMENT"},"code":"DMCAT_ProductSpecification_000420_Fulfilment","description":"Mobility_Fulfilment","endDate":"","guid":"dd7a2442-bd58-20e6-891a-2fd078b3d210","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobility_Fulfilment","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","currency":"AUD","quantity":"1","chargeId":"DMCAT_RecurringCharge_000669","rateExcludeGST":13.63,"type":null,"frequency":"Monthly","billingSpecId":"BSRC001_CB","billInAdvance":"true","prorate":"false","billDescription":"International call pack - premium","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000669_102"},"code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000669","description":"Mobility_Billing_RecurringCharge_000669","endDate":"","guid":"39075166-8924-2c0b-e8e9-2adfa9cb48fb","includeBilling":false,"instanceId":"","metadata":{},"name":"420_RC_669","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000669","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","value":"40","unitofMeasure":"GB","type":"FairPlay Data","ocsProdID":"T22EM_PLAN-S","billingSpecId":"BSUSG001_CB","billDescription":"Includes 40 GB Domestic Data+Unlimited Standard Voice+SMS+MMS","chargeId":"DMCAT_Allowance_000637"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000637","description":"Mobility_Billing_DMCAT_Allowance_000637","endDate":"","guid":"ed810ffb-a419-74b6-867e-c10f0baab01d","includeBilling":false,"instanceId":"","metadata":{},"name":"420_AW_637","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000637_7","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","quantity":"1","DiscountedPrice":"","type":"Voice and Data","currency":"AUD","frequency":"Monthly","billingSpecId":"BSRC001_CB","billInAdvance":"true","prorate":"false","billDescription":"Bring your own - local plan","rateExcludeGST":"50.00","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_4911","chargeId":"DMCAT_RecurringCharge_000654"},"code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","description":"Mobility_Billing_RecurringCharge_000654","endDate":"","guid":"27b89bb2-431c-16cd-bd54-650f33dde86e","includeBilling":false,"instanceId":"","metadata":{},"name":"420_RC_654","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","value":"Premium","type":"International Direct Dial","ocsProdID":"T22E_EMOB_IDD2","billingSpecId":"BSUSG001_CB","billDescription":"International call pack - premium","chargeId":"DMCAT_Allowance_000643"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000644","description":"Mobility_Billing_DMCAT_Allowance_000644","endDate":"","guid":"7e8d7df0-ecdc-1e49-03ff-d08eda855fdd","includeBilling":false,"instanceId":"","metadata":{},"name":"420_AW_644","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000644_27","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_IRDAYPASS","type":"International Roaming Data","unitofMeasure":"MB","value":"200","billingSubtype":"IR","billDescription":"IR Day Pass","chargeId":"DMCAT_Allowance_000606"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000606","description":"Mobility_Billing_DMCAT_Allowance_000606","endDate":"","guid":"2dd0a1d6-8ed3-edf5-652f-26a3b296d1df","includeBilling":false,"instanceId":"","metadata":{},"name":"263_AW_606","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000606_5","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_IR_AUTOTOPUP","type":"International Roaming Data","unitofMeasure":"MB","value":"500","billingSubtype":"IR","billDescription":"IR Data Topup","chargeId":"DMCAT_Allowance_000607"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000607","description":"Mobility_Billing_DMCAT_Allowance_000607","endDate":"","guid":"88684d27-205d-528a-488e-151d84b4503e","includeBilling":false,"instanceId":"","metadata":{},"name":"263_AW_607","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000607_6","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"parentSpec":"0a4f2805-1d50-7767-fa82-8ff9435913e7"},"attributes":{"__targetSystem":"ASSURANCE","parentSpec":"DMCAT_ProductSpecification_000326_Assurance","ResponseTarget":"SLA0010001","RestoreTarget":"SLA0010006"},"code":"DMCAT_ProductSpecification_000151_Assurance","description":"Incident Management_Assurance","endDate":"","guid":"a08b1510-b8b6-4d1d-6899-14bf513d68e4","includeBilling":false,"instanceId":"","metadata":{},"name":"151_ASR","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151_2","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"ServiceManagementOption":"1","__targetSystem":"ASSURANCE"},"code":"DMCAT_ProductSpecification_000326_Assurance","description":"Telstra Managed Service Option 1_Assurance","endDate":"","guid":"0a4f2805-1d50-7767-fa82-8ff9435913e7","includeBilling":false,"instanceId":"","metadata":{},"name":"326_ASR","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductOffering_000420DMCAT_ProductSpecification_000326","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"ASSURANCE"},"code":"DMCAT_ProductSpecification_000421_Assurance","description":"Mobile Device Management_Assurance","endDate":"","guid":"c67e4144-dc39-6bd2-85b1-a8a40673cb31","includeBilling":false,"instanceId":"","metadata":{},"name":"421_ASR","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000421","startDate":"","status":"Created","version":"1"}]}');
        att.Name = 'ServiceSpecifications.json';
        att.ParentId = servlist[0].id;
       insert att;

        String bodyToUpdate = Orchestration_Utility.addSimpleAttributes(att.Body.toString(), AttrMap, targetSystem);
        Test.stopTest();
        System.assertNotEquals(bodyToUpdate, null);
    }
	
	private static testMethod void testupdatespec() {
       Test.startTest();
        List<String> targetSystem = new List<String>{ 'FULFILMENT' ,'ASSURANCE'};
     
        Attachment attach = [SELECT Id, Body FROM Attachment LIMIT 1];

        String bodyToUpdate = Orchestration_Utility.updatespec(attach.body.toString(), 'Complete', targetSystem);
      Test.stopTest();
        System.assertEquals(bodyToUpdate.equals('false'), false);
    }
}