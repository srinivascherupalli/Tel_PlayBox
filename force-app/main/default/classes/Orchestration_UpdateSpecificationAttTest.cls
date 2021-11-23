/**================================================================
 * Appirio, Inc
 * Name: Orchestration_UpdateSpecificationAtt
 * Description: Update the Specifications in the Attachments
 * Created Date: June 11, 2020
 * Created By: Shweta Khandelwal
 * 1.  Gnana	       08-06-2021		EDGE-222326 : Modified assert to check for empty list instead of null
 ==================================================================*/

@isTest
public class Orchestration_UpdateSpecificationAttTest {
	//Test Data Setup
	@Testsetup
	static void dataSetup() {
		//Orchestration Processes list
		List<CSPOFA__Orchestration_Process__c> processList = new List<CSPOFA__Orchestration_Process__c>();
		//Process Templates for Processes
		List<CSPOFA__Orchestration_Process_Template__c> processTempList = new List<CSPOFA__Orchestration_Process_Template__c>();
		//List of Orchestration Steps which needs to be executed
		List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
		//List of Accounts for order
		List<account> accountList = new List<account>();
		//Order request on Order
		List<csord__Order_Request__c> orderReqList = new List<csord__Order_Request__c>();
		//List of Subscription
		List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
		// List of Orders
		List<csord__Order__c> orderList = new List<csord__Order__c>();
		//Product Configuration List
		list<cscfga__Product_Configuration__c> productconfiglistList = new List<cscfga__Product_Configuration__c>();
		//Solutions list
		list<csord__Solution__c> solutionList = new List<csord__Solution__c>();
		//Service List
		List<csord__Service__c> servlist0 = new List<csord__Service__c>();
		List<csord__Service__c> servlist1 = new List<csord__Service__c>();
		List<csord__Service__c> servlist2 = new List<csord__Service__c>();
		List<csord__Service__c> servlist3 = new List<csord__Service__c>();
        List<csord__Service__c> servlist4 = new List<csord__Service__c>();
		List<csord__Service__c> allServ = new List<csord__Service__c>();
		//Record to create the Custom Settings with Custom Limits
		Governor_Limits__c governerLimit = new Governor_Limits__c();

		//Attachment for the services
		list<Attachment> attachmentList0 = new List<Attachment>();
		list<Attachment> attachmentList1 = new List<Attachment>();
		list<Attachment> attachmentList2 = new List<Attachment>();
		list<Attachment> attachmentList3 = new List<Attachment>();
        list<Attachment> attachmentList4 = new List<Attachment>();
		list<Attachment> allAttachment = new List<Attachment>();
		List<Opportunity> oppList = new List<Opportunity>();
		List<cscrm__Site__c> siteList = new List<cscrm__Site__c>();

		//Build Data to Perform Actions on
		governerLimit = Orchestration_TestUtility.buildLimits();
		governerLimit.CWP_Activated__c = true;
		governerLimit.Update_Config_Counter__c = 20;
		update governerLimit;

		accountList = Orchestration_TestUtility.buildAccount(true, 2);
		oppList = Orchestration_TestUtility.buildOpp(true, 1, accountList);
		orderReqList = Orchestration_TestUtility.buildOrderRequest(true, 1);
		orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, false, 5);
		for (csord__Order__c order : orderList) {
			order.csordtelcoa__Opportunity__c = oppList[0].id;
		}
		insert orderList;
		processTempList = Orchestration_TestUtility.buildProcessTemplate(false, 2);
        processTempList[0].Name='Order Fulfilment Process';
        processTempList[1].Name='Inflight Orchestration Process';
        insert processTempList;
		productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(true, 1);
		solutionList = Orchestration_TestUtility.buildSolution(true, 1);
		siteList = Orchestration_TestUtility.buildsite(false, 2, accountList);
		siteList[0].name = 'Google';
		siteList[1].name = 'Google Chrome';
		siteList[1].cscrm__Account__c = accountList[0].id;
		insert siteList;
		subscriptionList = Orchestration_TestUtility.buildSubscription(false, 5, accountList[0].id, orderList, productconfiglistList[0].id, solutionList[0].id);
		subscriptionList[0].Site__c = siteList[0].id;
		subscriptionList[1].Site__c = siteList[1].id;
		subscriptionList[2].Site__c = siteList[0].id;
		subscriptionList[3].Site__c = siteList[0].id;
        subscriptionList[4].Site__c = siteList[0].id;
		insert subscriptionList;

		Orchestration_TestUtility.servlist = new List<csord__Service__c>();
		servlist0 = Orchestration_TestUtility.buildService(false, 4, subscriptionList[0].id, orderReqList[0].id, orderList[0].id, productconfiglistList[0].id);
		for (csord__Service__c service : servlist0) {
			service.name = 'User - Fixed Seat';
		}
		allServ.addAll(servlist0);
		Orchestration_TestUtility.servlist = new List<csord__Service__c>();
		servlist1 = Orchestration_TestUtility.buildService(false, 4, subscriptionList[1].id, orderReqList[0].id, orderList[1].id, productconfiglistList[0].id);
		for (csord__Service__c service : servlist1) {
			service.name = 'User - Fixed Seat';
		}
		allServ.addAll(servlist1);
		Orchestration_TestUtility.servlist = new List<csord__Service__c>();
		servlist2 = Orchestration_TestUtility.buildService(false, 4, subscriptionList[2].id, orderReqList[0].id, orderList[2].id, productconfiglistList[0].id);
		for (csord__Service__c service : servlist2) {
			service.name = 'IP Networktype';
		}
		allServ.addAll(servlist2);
		Orchestration_TestUtility.servlist = new List<csord__Service__c>();
		servlist3 = Orchestration_TestUtility.buildService(false, 4, subscriptionList[3].id, orderReqList[0].id, orderList[3].id, productconfiglistList[0].id);
		for (csord__Service__c service : servlist3) {
			service.name = 'IP Networktype';
		}
        allServ.addAll(servlist3);
        Orchestration_TestUtility.servlist = new List<csord__Service__c>();
		servlist4 = Orchestration_TestUtility.buildService(false, 1, subscriptionList[4].id, orderReqList[0].id, orderList[4].id, productconfiglistList[0].id);
		allServ.addAll(servlist4);
		insert allServ;

		Orchestration_TestUtility.attachmentList = new List<Attachment>();
		attachmentList0 = Orchestration_TestUtility.buildAttachment(false, 4, servlist0, productconfiglistList[0].id);
		for (Integer i = 0; i < attachmentList0.size(); i++) {
			attachmentList0[i].Body = Blob.valueOf(
				'{ "legacyAttributes": [], "serviceId": "' +
				servlist0[i].Id +
				'", "specifications": [ { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "FULFILMENT", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "DMCAT_ProductSpecification_000163", "description": "", "endDate": "", "guid": "G001", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "' +
				OrchestratorConstants.ServiceStatus.Created +
				'", "version": "1" }, { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "' +
				OrchestratorConstants.TargetSystem.FULFILMENT +
				'", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "DMCAT_ProductSpecification_000263_Fulfilment", "description": "", "endDate": "", "guid": "G002", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "Complete", "version": "1" }, { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "' +
				OrchestratorConstants.TargetSystem.BILLING +
				'", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "' +
				OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000622 +
				'", "description": "", "endDate": "", "guid": "G004", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "Complete", "version": "1" }, { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "' +
				OrchestratorConstants.TargetSystem.BILLING +
				'", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "' +
				OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000423 +
				'", "description": "", "endDate": "", "guid": "G003", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "Complete", "version": "1" }, { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "' +
				OrchestratorConstants.TargetSystem.BILLING +
				'", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "' +
				OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000423 +
				'", "description": "", "endDate": "", "guid": "G003", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "Complete", "version": "1" }, { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "' +
				OrchestratorConstants.TargetSystem.FULFILMENT +
				'", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "' +
				OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000622 +
				'", "description": "", "endDate": "", "guid": "G004", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "' +
				OrchestratorConstants.ServiceStatus.PaidOut +
				'", "version": "1" }, { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "' +
				OrchestratorConstants.TargetSystem.FULFILMENT +
				'", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "' +
				OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000622 +
				'", "description": "", "endDate": "", "guid": "G004", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "' +
				OrchestratorConstants.ServiceStatus.Disconnected +
				'", "version": "1" } ] }'
			);
		}
		allAttachment.addAll(attachmentList0);

		Orchestration_TestUtility.attachmentList = new List<Attachment>();
		attachmentList1 = Orchestration_TestUtility.buildAttachment(false, 4, servlist1, productconfiglistList[0].id);
		for (Integer i = 0; i < servlist1.size(); i++) {
			attachmentList1[i].Body = Blob.valueOf(
				'{ "legacyAttributes": [], "serviceId": "' +
				servlist1[i].Id +
				'", "specifications": [ { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "FULFILMENT", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "DMCAT_ProductSpecification_000163", "description": "", "endDate": "", "guid": "G001", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "' +
				OrchestratorConstants.ServiceStatus.Created +
				'", "version": "1" }, { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "' +
				OrchestratorConstants.TargetSystem.FULFILMENT +
				'", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "DMCAT_ProductSpecification_000263_Fulfilment", "description": "", "endDate": "", "guid": "G002", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "Complete", "version": "1" }, { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "' +
				OrchestratorConstants.TargetSystem.BILLING +
				'", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "' +
				OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000622 +
				'", "description": "", "endDate": "", "guid": "G004", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "Complete", "version": "1" }, { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "' +
				OrchestratorConstants.TargetSystem.BILLING +
				'", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "' +
				OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000423 +
				'", "description": "", "endDate": "", "guid": "G003", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "Complete", "version": "1" }, { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "' +
				OrchestratorConstants.TargetSystem.BILLING +
				'", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "' +
				OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000423 +
				'", "description": "", "endDate": "", "guid": "G003", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "Complete", "version": "1" }, { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "' +
				OrchestratorConstants.TargetSystem.FULFILMENT +
				'", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "' +
				OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000622 +
				'", "description": "", "endDate": "", "guid": "G004", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "' +
				OrchestratorConstants.ServiceStatus.PaidOut +
				'", "version": "1" }, { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "' +
				OrchestratorConstants.TargetSystem.FULFILMENT +
				'", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "' +
				OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000622 +
				'", "description": "", "endDate": "", "guid": "G004", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "' +
				OrchestratorConstants.ServiceStatus.Disconnected +
				'", "version": "1" } ] }'
			);
		}
		allAttachment.addAll(attachmentList1);

		Orchestration_TestUtility.attachmentList = new List<Attachment>();
		attachmentList2 = Orchestration_TestUtility.buildAttachment(false, 4, servlist2, productconfiglistList[0].id);
		for (Integer i = 0; i < servlist2.size(); i++) {
			attachmentList2[i].Body = Blob.valueOf(
				'{ "legacyAttributes": [], "serviceId": "' +
				servlist2[i].Id +
				'", "specifications": [ { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "FULFILMENT", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "DMCAT_ProductSpecification_000163", "description": "", "endDate": "", "guid": "G001", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "' +
				OrchestratorConstants.ServiceStatus.Created +
				'", "version": "1" }, { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "' +
				OrchestratorConstants.TargetSystem.FULFILMENT +
				'", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "DMCAT_ProductSpecification_000263_Fulfilment", "description": "", "endDate": "", "guid": "G002", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "Complete", "version": "1" }, { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "' +
				OrchestratorConstants.TargetSystem.BILLING +
				'", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "' +
				OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000622 +
				'", "description": "", "endDate": "", "guid": "G004", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "Complete", "version": "1" }, { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "' +
				OrchestratorConstants.TargetSystem.BILLING +
				'", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "' +
				OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000423 +
				'", "description": "", "endDate": "", "guid": "G003", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "Complete", "version": "1" }, { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "' +
				OrchestratorConstants.TargetSystem.BILLING +
				'", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "' +
				OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000423 +
				'", "description": "", "endDate": "", "guid": "G003", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "Complete", "version": "1" }, { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "' +
				OrchestratorConstants.TargetSystem.FULFILMENT +
				'", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "' +
				OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000622 +
				'", "description": "", "endDate": "", "guid": "G004", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "' +
				OrchestratorConstants.ServiceStatus.PaidOut +
				'", "version": "1" }, { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "' +
				OrchestratorConstants.TargetSystem.FULFILMENT +
				'", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "' +
				OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000622 +
				'", "description": "", "endDate": "", "guid": "G004", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "' +
				OrchestratorConstants.ServiceStatus.Disconnected +
				'", "version": "1" } ] }'
			);
		}
		allAttachment.addAll(attachmentList2);

		Orchestration_TestUtility.attachmentList = new List<Attachment>();
		attachmentList3 = Orchestration_TestUtility.buildAttachment(false, 4, servlist3, productconfiglistList[0].id);
		for (Integer i = 0; i < servlist3.size(); i++) {
			attachmentList3[i].Body = Blob.valueOf(
				'{ "legacyAttributes": [], "serviceId": "' +
				servlist3[i].Id +
				'", "specifications": [ { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "FULFILMENT", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "DMCAT_ProductSpecification_000163", "description": "", "endDate": "", "guid": "G001", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "' +
				OrchestratorConstants.ServiceStatus.Created +
				'", "version": "1" }, { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "' +
				OrchestratorConstants.TargetSystem.FULFILMENT +
				'", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "DMCAT_ProductSpecification_000263_Fulfilment", "description": "", "endDate": "", "guid": "G002", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "Complete", "version": "1" }, { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "' +
				OrchestratorConstants.TargetSystem.BILLING +
				'", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "' +
				OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000622 +
				'", "description": "", "endDate": "", "guid": "G004", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "Complete", "version": "1" }, { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "' +
				OrchestratorConstants.TargetSystem.BILLING +
				'", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "' +
				OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000423 +
				'", "description": "", "endDate": "", "guid": "G003", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "Complete", "version": "1" }, { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000163", "__targetSystem": "' +
				OrchestratorConstants.TargetSystem.BILLING +
				'", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "' +
				OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000423 +
				'", "description": "", "endDate": "", "guid": "G003", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "Complete", "version": "1" }, { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "' +
				OrchestratorConstants.TargetSystem.FULFILMENT +
				'", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "' +
				OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000622 +
				'", "description": "", "endDate": "", "guid": "G004", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "' +
				OrchestratorConstants.ServiceStatus.PaidOut +
				'", "version": "1" }, { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "' +
				OrchestratorConstants.TargetSystem.FULFILMENT +
				'", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "' +
				OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000622 +
				'", "description": "", "endDate": "", "guid": "G004", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "' +
				OrchestratorConstants.ServiceStatus.Disconnected +
				'", "version": "1" } ] }'
			);
		}
		allAttachment.addAll(attachmentList3);
        
        Orchestration_TestUtility.attachmentList = new List<Attachment>();
		attachmentList4 = Orchestration_TestUtility.buildAttachment(false, 1, servlist4, productconfiglistList[0].id);
        attachmentList4[0].Body = Blob.valueOf(
            '{ "legacyAttributes": [], "serviceId": "' +
            servlist4[0].Id +
            '", "specifications": [ { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "FULFILMENT", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "DMCAT_ProductSpecification_000163", "description": "", "endDate": "", "guid": "G001", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "' +
            OrchestratorConstants.ServiceStatus.Created +
            '", "version": "1" }, { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "' +
            OrchestratorConstants.TargetSystem.FULFILMENT +
            '", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "DMCAT_ProductSpecification_000263_Fulfilment", "description": "", "endDate": "", "guid": "G002", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "Complete", "version": "1" }, { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "' +
            OrchestratorConstants.TargetSystem.BILLING +
            '", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "' +
            OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000622 +
            '", "description": "", "endDate": "", "guid": "G004", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "Complete", "version": "1" }, { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "' +
            OrchestratorConstants.TargetSystem.BILLING +
            '", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "' +
            OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000423 +
            '", "description": "", "endDate": "", "guid": "G003", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "Complete", "version": "1" }, { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "' +
            OrchestratorConstants.TargetSystem.BILLING +
            '", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "' +
            OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000423 +
            '", "description": "", "endDate": "", "guid": "G003", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "Complete", "version": "1" }, { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "' +
            OrchestratorConstants.TargetSystem.FULFILMENT +
            '", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "' +
            OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000622 +
            '", "description": "", "endDate": "", "guid": "G004", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "' +
            OrchestratorConstants.ServiceStatus.PaidOut +
            '", "version": "1" }, { "additionalAttributes": {}, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "' +
            OrchestratorConstants.TargetSystem.FULFILMENT +
            '", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "' +
            OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000622 +
            '", "description": "", "endDate": "", "guid": "G004", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Mobile Access_Fulfilment", "productConfigurationId": "a3T2O000000GuQXUA0", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "' +
            OrchestratorConstants.ServiceStatus.Disconnected +
            '", "version": "1" } ] }'
        );
		allAttachment.addAll(attachmentList4);
		insert allAttachment;

		//Build Process Records through which the Steps will be executed.
		processList = Orchestration_TestUtility.buildProcess(false, 5, processTempList[0].id, orderList, subscriptionList, accountList[0].id, servlist0[0].id);
		processList[1].csordtelcoa__Subscription__c = subscriptionList[1].id;
		processList[3].csordtelcoa__Subscription__c = null; // Process where sub is null
        processList[4].CSPOFA__Orchestration_Process_Template__c = processTempList[1].id;
		insert processList;
		orchStepList = Orchestration_TestUtility.buildOrchStep(false, 5, processList);
		for (integer i = 0; i < orchStepList.size(); i++) {
			orchStepList[i].JSON__c = '{"orderIds":["' + orderList[0].id + '","' + orderList[1].id + '"]}';
		}
        orchStepList[4].name = 'Test Inflight Order 1';
		insert orchStepList;
	}

	static testMethod void ProcessTest() {
		//get data for processing
		List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
		orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
		Test.startTest();
		Orchestration_UpdateSpecificationAtt updateSpecificationAtt = new Orchestration_UpdateSpecificationAtt();
		orchStepList = updateSpecificationAtt.process(orchStepList);
		List<Attachment> attList = [SELECT id, name, body, parentId FROM Attachment];

		String serviceattachmentstr = attList[3].body.toString(); //  name contains IP network
		Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(serviceattachmentstr);
		List<Object> lstSpecifications = (List<Object>) results.get('specifications');
		Map<String, Object> specificationAttributes = (Map<String, Object>) lstSpecifications[0];
		System.assertEquals(specificationAttributes.get('additionalAttributes') != null, true);
		Map<String, Object> attributesPropertyInSpecification = (Map<String, Object>) specificationAttributes.get('additionalAttributes');
		System.assertEquals(attributesPropertyInSpecification.get('TotalNumberOfUsers'), null);

		//Query Updated Data for Assertion
		String serviceattachmentstr1 = attList[0].body.toString(); //  name doesnot contains IP network
		Map<String, Object> results1 = (Map<String, Object>) JSON.deserializeUntyped(serviceattachmentstr1);
		List<Object> lstSpecifications1 = (List<Object>) results1.get('specifications');
		Map<String, Object> specificationAttributes1 = (Map<String, Object>) lstSpecifications1[0];
		System.assertEquals(specificationAttributes1.get('additionalAttributes') != null, true);
		Map<String, Object> attributesPropertyInSpecification1 = (Map<String, Object>) specificationAttributes1.get('additionalAttributes');
		//Assert To check TotalNumberOfUsers
		System.assertEquals(attributesPropertyInSpecification1.get('TotalNumberOfUsers'), null);
		System.assertEquals(orchStepList[3].CSPOFA__Message__c, 'Success: Records processed');
		System.assertEquals(orchStepList[0].CSPOFA__Message__c, 'Success - No update required');

		Test.stopTest();
	}

	// specificationAttributesMap gets updated
	@isTest
	static void mainWithOutAttachmentsTest() {
		List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
		Governor_Limits__c governerLimit = new Governor_Limits__c();
		// Query form datasetup
		governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
		governerLimit.DML_Rows_limit__c = '2';
		update governerLimit; // Updation for further process
		orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
		Test.startTest();
		Orchestration_UpdateSpecificationAtt updateSpecificationAtt = new Orchestration_UpdateSpecificationAtt();
		orchStepList = updateSpecificationAtt.process(orchStepList);
		List<Attachment> attList = [SELECT id, name, body, parentId FROM Attachment];

		String serviceattachmentstr = attList[3].body.toString(); //  name contains IP network
		Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(serviceattachmentstr);
		List<Object> lstSpecifications = (List<Object>) results.get('specifications');
		Map<String, Object> specificationAttributes = (Map<String, Object>) lstSpecifications[0];
		System.assertEquals(specificationAttributes.get('additionalAttributes') != null, true);
		Map<String, Object> attributesPropertyInSpecification = (Map<String, Object>) specificationAttributes.get('additionalAttributes');
		System.assertEquals(attributesPropertyInSpecification.get('TotalNumberOfUsers'), null);

		//Query Updated Data for Assertion
		String serviceattachmentstr1 = attList[0].body.toString(); //  name doesnot contains IP network
		Map<String, Object> results1 = (Map<String, Object>) JSON.deserializeUntyped(serviceattachmentstr1);
		List<Object> lstSpecifications1 = (List<Object>) results1.get('specifications');
		Map<String, Object> specificationAttributes1 = (Map<String, Object>) lstSpecifications1[0];
		System.assertEquals(specificationAttributes1.get('additionalAttributes') != null, true);
		Map<String, Object> attributesPropertyInSpecification1 = (Map<String, Object>) specificationAttributes1.get('additionalAttributes');
		Test.stopTest();
	}

	// Where opp is not associated with order
	static testMethod void ProcessTestOppNull() {
		List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
		List<Id> subscriptionIds = new List<Id>();
		//get data for processing
		List<csord__Order__c> ordList = [SELECT id, name, csordtelcoa__Opportunity__c FROM csord__Order__c];
		for (csord__Order__c ord : ordList) {
			ord.csordtelcoa__Opportunity__c = null;
		}
		update ordList;
		//Query Updated Data for Assertion
		orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];

		Test.startTest();
		Orchestration_UpdateSpecificationAtt updateSpecificationAtt = new Orchestration_UpdateSpecificationAtt();
		orchStepList = updateSpecificationAtt.process(orchStepList);

		System.assertEquals(orchStepList[3].CSPOFA__Message__c, 'Success: No Opportunities Found.');

		Test.stopTest();
	}

	// Limits got hit
	static testMethod void breakingLimits() {
		//Query to get the Data for Processing
		List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
		Governor_Limits__c governerLimit = new Governor_Limits__c();
		//Updatation to update theLImit to perform partial updation
		governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
		governerLimit.SOQL_limit__c = '1';
		update governerLimit;
		Test.startTest();
		orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
		Orchestration_UpdateSpecificationAtt updateSpecificationAtt = new Orchestration_UpdateSpecificationAtt();
		orchStepList = updateSpecificationAtt.process(orchStepList);
		//Assert to check if the Step is in progress as the Limits were reached.
		System.assertEquals(orchStepList[1].CSPOFA__Message__c, 'In Progress');
		Test.stopTest();
	}
	//Run class without any limits left
	static testMethod void breakingLimitsInStart() {
		List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
		Governor_Limits__c governerLimit = new Governor_Limits__c();
		// Update the Custom Limits to check no updation is done
		// Query from datasetup
		governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
		governerLimit.SOQL_limit__c = '0';
		update governerLimit; // updation for further processing
		Test.startTest();
		orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
		Orchestration_UpdateSpecificationAtt updateSpecificationAtt = new Orchestration_UpdateSpecificationAtt();
		orchStepList = updateSpecificationAtt.process(orchStepList);
		//boolean isNull = orchStepList == null ? true : false;
		//No Steps will be returned and nothing will be updated as Limits were reached
		System.assertEquals(orchStepList.isEmpty(), true);
		Test.stopTest();
	}

	//covering innerCatch by bad Json (Error condition)
	static testMethod void innerCatch() {
		List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
		// Query from datasetup
		orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
		orchStepList[0].JSON__C = 'OrchestratorConstants.SystemConstant.AttachmentMsg ';
		update orchStepList; // updation for further processing
		Test.startTest();
		Orchestration_UpdateSpecificationAtt updateSpecificationAtt = new Orchestration_UpdateSpecificationAtt();
		orchStepList = updateSpecificationAtt.process(orchStepList);
		// Assert to check error condition
		System.assertEquals(orchStepList[0].CSPOFA__Status__c, OrchestratorConstants.OrchestratorStep.Error);
		Test.stopTest();
	}

	//Run class without any limits left DML limit
	static testMethod void breakingLimitsInStartDML() {
		List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
		Governor_Limits__c governerLimit = new Governor_Limits__c();
		// Update the Vustom Limits to check no updation is done
		Test.startTest();
		governerLimit = [SELECT Id, SOQL_limit__c, DML_limit__c FROM Governor_Limits__c];
		governerLimit.DML_limit__c = '0';
		update governerLimit;

		orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
		Orchestration_UpdateSpecificationAtt updateSpecificationAtt = new Orchestration_UpdateSpecificationAtt();
		orchStepList = updateSpecificationAtt.process(orchStepList);
		//No Steps will be returned and nothing will be updated as Limits were reached
		System.assertEquals(orchStepList.isEmpty(), true, 'No Steps returned as Limit Reached.');
		Test.stopTest();
	}
    
    static testMethod void ProcessTest_InflightOrders() {
        //get data for processing
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c WHERE Name = 'Test Inflight Order 1'];
        Test.startTest();
        Orchestration_UpdateSpecificationAtt updateSpecificationAtt = new Orchestration_UpdateSpecificationAtt();
        orchStepList = updateSpecificationAtt.process(orchStepList);
        List<Attachment> attList = [SELECT id, name, body, parentId FROM Attachment];
        
        String serviceattachmentstr = attList[4].body.toString();
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(serviceattachmentstr);
        List<Object> lstSpecifications = (List<Object>) results.get('specifications');
        Map<String, Object> specificationAttributes = (Map<String, Object>) lstSpecifications[0];
        System.assertEquals(specificationAttributes.get('additionalAttributes') != null, true);
        Map<String, Object> attributesPropertyInSpecification = (Map<String, Object>) specificationAttributes.get('additionalAttributes');
        System.assertEquals(attributesPropertyInSpecification.get('TotalNumberOfUsers'), null);
        
        //Query Updated Data for Assertion
        String serviceattachmentstr1 = attList[0].body.toString(); //  name doesnot contains IP network
        Map<String, Object> results1 = (Map<String, Object>) JSON.deserializeUntyped(serviceattachmentstr1);
        List<Object> lstSpecifications1 = (List<Object>) results1.get('specifications');
        Map<String, Object> specificationAttributes1 = (Map<String, Object>) lstSpecifications1[0];
        System.assertEquals(specificationAttributes1.get('additionalAttributes') != null, true);
        Map<String, Object> attributesPropertyInSpecification1 = (Map<String, Object>) specificationAttributes1.get('additionalAttributes');
        //Assert To check TotalNumberOfUsers
        System.assertEquals(attributesPropertyInSpecification1.get('TotalNumberOfUsers'), null);
        System.assertEquals(orchStepList[0].CSPOFA__Message__c, 'Success - No update required');
        
        Test.stopTest();
    }

}