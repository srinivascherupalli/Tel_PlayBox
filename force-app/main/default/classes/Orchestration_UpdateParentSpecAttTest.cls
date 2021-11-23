/**================================================================
 * Appirio, Inc
 * Name: Orchestration_UpdateSpecificationAtt
 * Description: Update the Specifications in the Attachments
 * Created Date: June 11, 2020
 * Created By: Shweta Khandelwal/Martand Atrey
 ==================================================================*/

 @isTest
 public class Orchestration_UpdateParentSpecAttTest {
 
	 @Testsetup
	 static void dataSetup() {
		  // List declartion for various objects to create data
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
		 List<Opportunity> oppList = new List<Opportunity>();
		 List<cscrm__Site__c> siteList = new List<cscrm__Site__c>();
 
		  //Build Data to Perform Actions on
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
		 servlist[1].name = 'User - Fixed Seat';
		 servlist[2].name = 'IP Networktype';
		 servlist[3].name = 'IP Networktype';
		 servlist[1].csord__Subscription__c = subscriptionList[1].id;
		 insert servlist;
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
		 attachmentList[1].Body = Blob.valueOf(
			 '{ "legacyAttributes": [], "serviceId": "' +
			 servlist[1].Id +
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
		 attachmentList[2].Body = Blob.valueOf(
			 '{ "legacyAttributes": [], "serviceId": "' +
			 servlist[2].Id +
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
 
		 // "parentSpec": "9b4624d2-b67d-8593-7379-477cffadd076", "ManagedRadiusProductInstanceID": "ffc9f120-dd27-bc23-e629-6fad5255b2fa"
 
		 attachmentList[3].Body = Blob.valueOf(
			 '{ "legacyAttributes": [], "serviceId": "' +
			 servlist[3].Id +
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
		 //Build Process Records through wich the Steps will be executed.
		 processList = Orchestration_TestUtility.buildProcess(false, 4, processTempList[0].id, orderList, subscriptionList, accountList[0].id, servlist[0].id);
		 processList[1].csordtelcoa__Subscription__c = subscriptionList[1].id;
		 processList[3].csordtelcoa__Subscription__c = null; // Process where sub is null
		 insert processList;
		 orchStepList = Orchestration_TestUtility.buildOrchStep(false, 4, processList);
		 orchStepList[0].JSON__c = '{"' + OrchestratorConstants.OrchestrationObjectType.Order + '":["' + orderList[0].id + '","' + orderList[1].id + '"]}';
		 orchStepList[1].JSON__c = '{"' + OrchestratorConstants.OrchestrationObjectType.Order + '":["' + orderList[0].id + '"]}';
		 orchStepList[2].JSON__c = '{"' + OrchestratorConstants.OrchestrationObjectType.Order + '":["' + orderList[0].id + '"]}';
		 orchStepList[3].JSON__c = '{"' + OrchestratorConstants.OrchestrationObjectType.Order + '":["' + orderList[0].id + '"]}';
		 insert orchStepList;
	 }
	  
	 // specificationAttributesMap gets updated
	 @isTest
	 static void mainTest() {
		 List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
		 List<Id> subscriptionIds = new List<Id>();
		 // Query form datasetup
		 List<csord__Order__c> ordList = [SELECT id, name, csordtelcoa__Opportunity__c FROM csord__Order__c];
 
		 orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
 
		 for (CSPOFA__Orchestration_Step__c step : orchStepList) {
			 step.JSON__c = '';
		 }
		 update orchStepList; // Updation for further process
		 Test.startTest();
		 Orchestration_UpdateParentSpecAtt updateSpecificationAtt = new Orchestration_UpdateParentSpecAtt();
		 orchStepList = updateSpecificationAtt.process(orchStepList);
		 Test.stopTest();
 
		 for (Attachment att : [SELECT id, name, ParentId, Body FROM Attachment]) {
			 String attBody = att.Body.toString();
			 Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(attBody);
			 List<Object> lstSpecifications = (List<Object>) results.get('specifications');
			 if (lstSpecifications != null) {
				 for (Object specification : lstSpecifications) {
					 Map<String, Object> specificationAttributesMap = (Map<String, Object>) specification;
					 if (specificationAttributesMap.get('guid') == '963263ce-cb0a-64cd-17d6-06b524f533e1')
						 continue;
					 Map<String, Object> attributesPropertyInSpecification = (Map<String, Object>) specificationAttributesMap.get(
						 OrchestratorConstants.ServiceSpecificationKey.Attributes
					 );
					 Map<String, Object> additionalAttrs = (Map<String, Object>) specificationAttributesMap.get('additionalAttributes');
					 if (attributesPropertyInSpecification.containsKey('parentSpec')) {
						 System.debug('===> parentSpec');
						 System.assert(additionalAttrs.containsKey('parentSpec'));
						 System.assertEquals('G004', additionalAttrs.get('parentSpec'));
					 }
					 if (attributesPropertyInSpecification.containsKey('IPWirelessProductInstanceID')) {
						 System.debug('===> IPWirelessProductInstanceID');
 
						 System.assert(additionalAttrs.containsKey('IPWirelessProductInstanceID'));
						 System.assertEquals('G005', additionalAttrs.get('IPWirelessProductInstanceID'));
					 }
					 if (attributesPropertyInSpecification.containsKey('ManagedRadiusProductInstanceID')) {
						 System.debug('===> ManagedRadiusProductInstanceID');
 
						 System.assert(additionalAttrs.containsKey('ManagedRadiusProductInstanceID'));
						 System.assertEquals('G001', additionalAttrs.get('ManagedRadiusProductInstanceID'));
					 }
				 }
			 }
		 }
	 }
 
	 // Where opp is not associated with order
	 static testMethod void ProcessTestOppNull() {
		 List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
		 List<Id> subscriptionIds = new List<Id>();
		 // Query form datasetup
		 List<csord__Order__c> ordList = [SELECT id, name, csordtelcoa__Opportunity__c FROM csord__Order__c];
		 for (csord__Order__c ord : ordList) {
			 ord.csordtelcoa__Opportunity__c = null;
		 }
		 update ordList; // updation for further process
		 System.debug('ordList ' + ordList);
		 orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
 
		 Test.startTest();
		 Orchestration_UpdateParentSpecAtt updateSpecificationAtt = new Orchestration_UpdateParentSpecAtt();
		 orchStepList = updateSpecificationAtt.process(orchStepList);
		 // Assert to check message status
		 System.assertEquals(orchStepList[3].CSPOFA__Message__c, 'Success: No Opportunities Found.');
 
		 Test.stopTest();
	 }
 
	 // Limits got hit
	 static testMethod void breakingLimits() {
		 List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
		 Governor_Limits__c governerLimit = new Governor_Limits__c();
		 // Query form datasetup
		 governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
		 governerLimit.SOQL_limit__c = '1';
		 update governerLimit; // Updation for further process
		 Test.startTest();
		 orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
		 Orchestration_UpdateParentSpecAtt updateSpecificationAtt = new Orchestration_UpdateParentSpecAtt();
		 orchStepList = updateSpecificationAtt.process(orchStepList);
		 // Assert to check message step
		 System.assertEquals(orchStepList[1].CSPOFA__Message__c, 'In Progress');
		 Test.stopTest();
	 }
 
	 static testMethod void breakingLimitsInStart() {
		 List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
		 Governor_Limits__c governerLimit = new Governor_Limits__c();
		 // Query form datasetup
		 governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
		 governerLimit.SOQL_limit__c = '0';
		 update governerLimit; // Updation for further process
		 Test.startTest();
		 orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
		 Orchestration_UpdateParentSpecAtt updateSpecificationAtt = new Orchestration_UpdateParentSpecAtt();
		 orchStepList = updateSpecificationAtt.process(orchStepList);
	 //boolean isNull = orchStepList == null ? true : false;
	 //Assert to check if the Step is in progress as the Limits were reached.
	 System.assertEquals(orchStepList.isEmpty(), true);
	 Test.stopTest();
	 }
 
	 //covering innerCatch by bad Json : Error condition
	 static testMethod void innerCatch() {
		 List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
		 // Query form datasetup
		 orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
		 orchStepList[0].JSON__C = OrchestratorConstants.SystemConstant.AttachmentMsg;
		 update orchStepList; // Updation for further process
		 Test.startTest();
		 Orchestration_UpdateParentSpecAtt updateSpecificationAtt = new Orchestration_UpdateParentSpecAtt();
		 orchStepList = updateSpecificationAtt.process(orchStepList);
		 // Assert to check Error condition
		 System.assertEquals(orchStepList[0].CSPOFA__Status__c, OrchestratorConstants.OrchestratorStep.Error);
		 Test.stopTest();
	 }
 }