/**================================================================
* Wipro
* Name: Orchestration_updateServicesforDiscTest
* Created Date: 11-10-2021
* Created By: Aman Gupta
==================================================================*/

@isTest
public class Orchestration_updateServicesforDiscTest {
    
    @Testsetup
    static void dataSetup() {
        List<CSPOFA__Orchestration_Process__c> processList = new List<CSPOFA__Orchestration_Process__c>();
        List<CSPOFA__Orchestration_Process_Template__c> processTempList = new List<CSPOFA__Orchestration_Process_Template__c>();
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<account> accountList = new List<account>();
        List<csord__Order_Request__c> orderReqList = new List<csord__Order_Request__c>();
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        list<cscfga__Product_Configuration__c> productconfiglistList = new List<cscfga__Product_Configuration__c>();
        list<csord__Solution__c> solutionList = new List<csord__Solution__c>();
        List<csord__Service__c> servlist = new List<csord__Service__c>();
        List<csord__Service_Line_Item__c> servLineList = new List<csord__Service_Line_Item__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        list<Attachment> attachmentList = new List<Attachment>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<cscrm__Site__c> siteList = new List<cscrm__Site__c>();
        
        governerLimit = Orchestration_TestUtility.buildLimits();
        accountList = Orchestration_TestUtility.buildAccount(true, 2);
        oppList = Orchestration_TestUtility.buildOpp(true, 1, accountList);
        orderReqList = Orchestration_TestUtility.buildOrderRequest(true, 1);
        
        orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, false, 4);
        orderList[0].csordtelcoa__Opportunity__c = oppList[0].id;
        orderList[1].csordtelcoa__Opportunity__c = oppList[0].id;
        orderList[2].csordtelcoa__Opportunity__c = oppList[0].id;
        insert orderList;
        
        processTempList = Orchestration_TestUtility.buildProcessTemplate(true, 1);
        productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(true, 1);
		solutionList = Orchestration_TestUtility.buildSolution(true, 1);
		 siteList = Orchestration_TestUtility.buildsite(false, 2, accountList);
		 siteList[0].name = 'Google';
		 siteList[1].name = 'Google Chrome';
		 siteList[1].cscrm__Account__c = accountList[0].id;
		 insert siteList;
        
        subscriptionList = Orchestration_TestUtility.buildSubscription(false, 4, accountList[0].id, orderList, productconfiglistList[0].id, solutionList[0].id);
        subscriptionList[0].Site__c = siteList[0].id;
        subscriptionList[1].Site__c = siteList[1].id;
        subscriptionList[2].Site__c = siteList[0].id;
        subscriptionList[3].Site__c = siteList[0].id;
        insert subscriptionList;
        
        servlist = Orchestration_TestUtility.buildService(false, 4, subscriptionList[0].id, orderReqList[0].id, orderList[0].id, productconfiglistList[0].id);
        servlist[0].name = 'User - Fixed Seat';
        servlist[0].containsDiscount__c = false ;
        servlist[0].csord__Subscription__c = subscriptionList[1].id;
        servlist[0].csord__Order__c = orderList[0].id;
        insert servlist;
		System.debug('Order Test' +servlist[0].csord__Order__c);
        
        csord__Service_Line_Item__c ServiceLineRecord = new csord__Service_Line_Item__c();
        ServiceLineRecord.csord__Is_Adhoc__c = false;
        ServiceLineRecord.csord__Is_Active__c = true;
        ServiceLineRecord.csord__Discount_Type__c = 'Amount';
        ServiceLineRecord.csord__Line_Description__c = 'Sli description x 2';
        ServiceLineRecord.csord__Identification__c = 'IDENTIFICATION';
        ServiceLineRecord.csord__Service__c = servlist[0].id ;
        insert ServiceLineRecord;
        
        attachmentList = Orchestration_TestUtility.buildAttachment(false, 4, servlist, productconfiglistList[0].id);
        attachmentList[0].Body = Blob.valueOf(
            '{ "legacyAttributes": [], "serviceId": "' +
            servlist[0].Id +
            '", "specifications": [ { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "FULFILMENT", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "DMCAT_ProductSpecification_000053_Fulfilment", "description": "", "endDate": "", "guid": "G001", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "' +
            OrchestratorConstants.ServiceStatus.Created +
            '", "version": "1" }, { "additionalAttributes": { }, "attributes": { "parentSpec": "DMCAT_ProductSpecification_000028_Fulfilment", "ManagedRadiusProductInstanceID": "DMCAT_ProductSpecification_000053_Fulfilment", "__targetSystem": "FULFILMENT", "GlobalRoaming": "FALSE", "APNtype": "Shared", "CustomerFacingServiceId": "", "RequiredPoolTypes": "Static" }, "code": "DMCAT_ProductSpecification_000622", "description": "", "endDate": "", "guid": "4d9f3701-912a-fc43-48d7-b3b565a135d0", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "IP Wireless_Fulfilment", "productConfigurationId": "a3T2O000000JFlPUAW", "specification": "DMCAT_ProductSpecification_000028DMCAT_ProductSpecification_000018", "startDate": "", "status": "Created", "version": "1" }, { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "' +
            OrchestratorConstants.TargetSystem.BILLING +
            '", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "DMCAT_ProductSpecification_000028_Fulfilment", "description": "", "endDate": "", "guid": "G004", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "Complete", "version": "1" }, { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "' +
            OrchestratorConstants.TargetSystem.FULFILMENT +
            '", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code":"DMCAT_ProductSpecification_000018_Fulfilment", "description": "", "endDate": "", "guid": "G005", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "' +
            OrchestratorConstants.ServiceStatus.Disconnected +
            '", "version": "1" } ] }'
        );
        
        insert attachmentList;
        
		processList = Orchestration_TestUtility.buildProcess(false, 4, processTempList[0].id, orderList, subscriptionList, accountList[0].id, servlist[0].id);
        processList[0].csordtelcoa__Subscription__c = subscriptionList[1].id;
		processList[0].Order__c = orderList[0].id;
        insert processList;
        
        orchStepList = Orchestration_TestUtility.buildOrchStep(false, 4, processList);
        orchStepList[0].JSON__c = '{"' + OrchestratorConstants.OrchestrationObjectType.Order + '":["' + orderList[0].id + '","' + orderList[1].id + '"]}';
		orchStepList[0].CSPOFA__Orchestration_Process__c = processList[0].id;
        insert orchStepList;
    }
    @isTest
    static void mainTestMethod() {        
        List<csord__Order__c> ordList = [SELECT id, name,csordtelcoa__Opportunity__c FROM csord__Order__c LIMIT 1];
        
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, 
                        CSPOFA__Message__c,CSPOFA__Orchestration_Process__r.Order__c
                        FROM CSPOFA__Orchestration_Step__c LIMIT 1];
        for (CSPOFA__Orchestration_Step__c step : orchStepList) {
            step.JSON__c = '';
            step.CSPOFA__Orchestration_Process__r.Order__c = ordList[0].id;
        }
		update orchStepList;
        
        List<csord__Service__c> ServiceList = [SELECT id,name,containsDiscount__c,csord__Order__c FROM csord__Service__c LIMIT 1];
        for (csord__Service__c service : ServiceList) {
            service.csord__Order__c = ordList[0].id;
			service.containsDiscount__c = false;
        }
        update ServiceList;
        
        List<csord__Service_Line_Item__c> ServiceLineList = [SELECT id,name,csord__Is_Adhoc__c,csord__Is_Active__c,
                                                             csord__Discount_Type__c,csord__Service__c
                                                             FROM csord__Service_Line_Item__c
															 ];        
        for (csord__Service_Line_Item__c serviceLine : ServiceLineList) {
            serviceLine.csord__Is_Adhoc__c = false;                                                             
			serviceLine.csord__Is_Active__c = true;
			serviceLine.csord__Discount_Type__c = 'Percentage';
			serviceLine.csord__Service__c = ServiceList[0].id;
        }
        update serviceLineList;
        Test.startTest();
        Orchestration_updateServicesforDiscount updateServicesforDiscount = new Orchestration_updateServicesforDiscount();
        updateServicesforDiscount.process(orchStepList);
        Test.stopTest();
    }  
		
    
}