/**================================================================
* Appirio, Inc
* Name: Orchestration_TestUtility
* Description: Class to create data at one place for all the test class
* Created Date: May 05, 2020
* Created By: Shweta Khandelwal
==================================================================*/
@isTest
public class Orchestration_TestUtility{
    public static string IDENTIFICATION ='IDE1322';
    public static List<csord__Order__c> orderList = new List<csord__Order__c>();
    public static List<account> accountList = new List<account>();
    public static List<csord__Order_Request__c> orderReqList = new List<csord__Order_Request__c>();
    public static List<CSPOFA__Orchestration_Process__c> processList = new List<CSPOFA__Orchestration_Process__c>();
    public static List<CSPOFA__Orchestration_Process_Template__c> processTempList = new List<CSPOFA__Orchestration_Process_Template__c>();
    public static List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
    public static List<csord__Service__c> servlist = new List<csord__Service__c>();
    public static List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
	public static list<cscfga__Product_Configuration__c> productconfiglistList = new List<cscfga__Product_Configuration__c>();
	public static list<csord__Solution__c> solutionList = new List<csord__Solution__c>();
	public static list<Attachment> attachmentList = new List<Attachment>();
    
    public static csordtelcoa__Orders_Subscriptions_Options__c buildsubOption(){
        csordtelcoa__Orders_Subscriptions_Options__c subsSettings = new csordtelcoa__Orders_Subscriptions_Options__c();
        subsSettings.csordtelcoa__Service_Initial_State__c = 'In progress';
        insert subsSettings;
        return subsSettings;
    }    
    
    public static FCR_Settings__c buildFCR(){
        FCR_Settings__c fcr = new FCR_Settings__c();
        fcr.Name = 'Model5';
        fcr.File_Name__c = 'File Name';
        fcr.Product_Configuration_code__c = 'Model5';
        fcr.Role_Name__c = 'role';
        insert fcr;
        return fcr;
    }
    
    // Method for creating custom setting 
    public static EnvironmentVariable__c buildENV(boolean isInsert, integer count){
        EnvironmentVariable__c env = new EnvironmentVariable__c();
        //env.getValues('EnableHV');
        env.name = 'EnableHV';
        env.Value__c = 'true';
        if(isInsert){
            insert env;
        }
        return env;
    }
    
    public static Governor_Limits__c buildLimits(){
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit.Call_Out_limit__c = '80';
        governerLimit.CPU_limit__c = '8000';
        governerLimit.DML_limit__c = '120';
        governerLimit.DML_Rows_limit__c = '8000';
        governerLimit.Heap_Size_LImit__c = 	'5033164';
        governerLimit.SOQL_limit__c = '80';
        governerLimit.Orchestration_Process_Limit__c =	'10';
        insert governerLimit;
        return governerLimit;
    }
    
    //Method for creating account
    public static List<account> buildAccount(Boolean isInsert , integer count) {
        for(integer i=0; i<=count; i++){
            Account acc = new Account();
            acc.Name = 'test Account '+i ;
            acc.Customer_Status__c = 'Active'; // used in Orchestration_AccountStatusUpdateTest
            accountList.add(acc);
        }
        
        if(isInsert){
            insert accountList;
        }
        
        return accountList;
    }
    
    //Method for creating OrderRequest
    public static List<csord__Order_Request__c> buildOrderRequest(Boolean isInsert , integer count) {
        for(integer i=0; i<count; i++){
            csord__Order_Request__c orderReq = new csord__Order_Request__c();
            orderReq.name = 'OR-12121';
            orderReq.csord__Module_Name__c = 'TestReq';
            orderReq.csord__Module_Version__c = '12';
            orderReqList.add(orderReq);
        }
        
        if(isInsert){
            insert orderReqList;
        }
        
        return orderReqList;
    }
    
    //Method for creating order
    public static List<csord__Order__c>  buildOrder(String name, Id accountId, String status, Id orderReqId, Boolean isInsert , integer count) {
        for(integer i=0; i<count; i++){
            csord__Order__c  ord = new csord__Order__c();
            ord.name = name+i;
            ord.csord__Account__c = accountId;
            ord.csord__Status2__c = status;
            ord.csord__Order_Request__c = orderReqId;
            ord.csord__Identification__c = IDENTIFICATION;
            ord.stage__c = 'Being Fulfilled';
            ord.csord__Start_Date__c = Date.newInstance(2016, 12, 9);    
            ord.isTransientComplete__c = false;
            orderList.add(ord);
        }
        
        if(isInsert){
            insert orderList;
        }
        
        return orderList;
    }
    
    //Method for creating Process
	public static List<CSPOFA__Orchestration_Process__c> buildProcess(Boolean isInsert, integer count, Id orchProcessTemplateId, List<csord__Order__c> orderList, List<csord__Subscription__c> subscriptionList, Id accountId, Id serviceId) {
		for (integer i = 0; i < count; i++) {
			CSPOFA__Orchestration_Process__c orchProcess = new CSPOFA__Orchestration_Process__c();
			orchProcess.Name = 'Test Orch Process ' + i;
			orchProcess.Order__c = orderList.size() >= i + 1 ? orderList[i].id : orderList[1].id;
                                                                              orchProcess.has_Inactive_Children__c = 'NA';
                                                                              orchProcess.CSPOFA__Orchestration_Process_Template__c = orchProcessTemplateId;
                                                                              orchProcess.cspofa__account__c = accountId;
                                                                              orchProcess.csordtelcoa__Subscription__c = subscriptionList[i].id;
                                                                              orchProcess.csordtelcoa__Service__c = serviceId;  
                                                                              processList.add(orchProcess);
                                                                          }
                                                                          
                                                                          if(isInsert){
                                                                              insert processList;
                                                                          }
                                                                          
                                                                          return processList;
                                                                      }
    
    //Method for creating ProcessTemplate
    public static List<CSPOFA__Orchestration_Process_Template__c> buildProcessTemplate(Boolean isInsert, integer count) {
        for(integer i=0; i<count; i++){
            CSPOFA__Orchestration_Process_Template__c orchProcessTemplate = new CSPOFA__Orchestration_Process_Template__c();
            orchProcessTemplate.Name='Order Fulfilment Process '+i;
            orchProcessTemplate.CSPOFA__Process_Type__c = 'New Provide';
            orchProcessTemplate.CSPOFA__Processing_Mode__c = 'Foreground';
            processTempList.add(orchProcessTemplate);
        }
        
        if(isInsert){
            insert processTempList;
        }
        
        return processTempList;
    }
    
    //Method for creating Orchestration Step
    public static List<CSPOFA__Orchestration_Step__c> buildOrchStep(Boolean isInsert, integer count, List <CSPOFA__Orchestration_Process__c> processList) {
        string jsonString = '[ "test1", "test2" ]';
        // this.json = jsonString;
        
        for(integer i=0; i<count; i++){
            CSPOFA__Orchestration_Step__c step = new CSPOFA__Orchestration_Step__c();
            step.name = 'step '+i;
            step.CSPOFA__Orchestration_Process__c = processList[i].Id;
            step.CSPOFA__Completed_Date__c = Date.Today();
            step.JSON__c = jsonString;
            step.CSPOFA__Message__c = 'In Progress';
            orchStepList.add(step);
        }
        
        if(isInsert){
            insert orchStepList;
        }
        
        return orchStepList;
    }
    
    //Method for creating Service
    // As part EDGE-170949 & 170948 - inserted new records for Service and Maincharge
    public static List<csord__Service__c> buildService(Boolean isInsert, integer count, Id SubsId, Id ordReqId, Id orderId, Id productconfiglistId) {
                
        cscfga__Product_Configuration__c pcNewMdm = new cscfga__Product_Configuration__c();
        pcNewMdm.name='Enterprise Mobility Managed Service';
        pcNewMdm.Type__c='New';
        pcNewMdm.ConfigurationType1__c = 'SolutionComponent';
        pcNewMdm.Quantity_Product_Configuration__c = 111;
        insert pcNewMdm;
        
        csord__Subscription__c testSerSub = new csord__Subscription__c();
        testSerSub.Name = 'testSerSub';
        testSerSub.csord__Order__c = orderId; // used in Orchestration_EvaluateOrderStatusTest
        testSerSub.csord__Identification__c = Identification;
        testSerSub.triggerBill_RTB__c = false;
        testSerSub.csordtelcoa__Replacement_Subscription__c = SubsId;
        insert testSerSub; 
        
        cspmb__Price_Item__c maincharge = new cspmb__Price_Item__c();
        maincharge.Name = 'Enterprise Mobility';
        maincharge.cspmb__Price_Item_Code__c = 'Enterprise Mobility';
        maincharge.cspmb__Product_Definition_Name__c = 'Enterprise Mobility';
        //maincharge.cspmb__Is_Active__c = true;
        maincharge.Type__c = 'Handheld'; 
        insert maincharge;
                
        csord__Service__c servReplacement = new csord__Service__c();
        servReplacement.name ='testService';
        servReplacement.csord__Subscription__c = testSerSub.Id; //requried Field
        servReplacement.csord__Identification__c = Identification; //requried Field
        servReplacement.csord__Status__c = 'In progress';
        servReplacement.Payment_Type__c = 'Cash';
        servReplacement.mainCharge__c = maincharge.id;        
        insert servReplacement;
        
        
        //Attachement releated to replacement service should not be null , requried in Orchestration_RecreateDeletedSpecs
        Attachment att1 = new Attachment();
		att1.body = Blob.valueOf(
			'{ "legacyAttributes" : [ ], "serviceId" : "' +
			servReplacement.id +
			'", "specifications" : [ { "additionalAttributes" : { "IPWirelessProductInstanceID" : "abcd", "DMCAT_ProductSpecification_000263_CPEDeliveryDate" : "2019-03-14T08:00:00" }, "attributes" : { "IPWirelessProductInstanceID" : "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem" : "FULFILMENT", "SERVICEPROFILE" : "DATA_BACKUP", "MESSAGEBANK" : "NA", "INTROAM" : "NA", "CONTEXT" : "NA", "CALLCONTROL" : "NA", "AccessRole" : "Primary", "BillofMaterialID" : "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID" : "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate" : "", "ShippingRequired" : "TRUE", "IMSI" : "", "SIMSerialNumber" : "" }, "code" :"DMCAT_ProductSpecification_000263_Fulfilment", "description" : "", "endDate" : "", "guid" : "963263ce-cb0a-64cd-17d6-06b524f533e1", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "Mobile Access_Fulfilment", "productConfigurationId" : "' +
			pcNewMdm.id +
			'", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate" : "", "status" : "Disconnect In Progressss", "version" : "1" }]}'
		);
		att1.Name = 'ServiceSpecifications.json';
		att1.ParentId = servReplacement.id;
		insert att1;

		for (integer i = 0; i < count; i++) {
			csord__Service__c serv = new csord__Service__c();
			serv.name = 'testService ' + i;
			serv.csord__Identification__c = 'testIdentify_4'; //requried Field
			serv.csordtelcoa__Service_Number__c = '3';
			serv.csord__Subscription__c = SubsId; //requried Field
			serv.csord__Status__c = 'Created';
			serv.substage__c = 'Product Requirements Validation';
			serv.csord__Order_Request__c = ordReqId;
			serv.csord__Order__c = orderId;
			serv.csordtelcoa__Product_Configuration__c = productconfiglistId;
			serv.csordtelcoa__Replaced_Service__c = servReplacement.Id;
			serv.csord__Status__c = 'In progress';
			serv.Payment_Type__c = OrchestratorConstants.ServicePaymentType.Rental; // Used in Orchestration_OrderDeltaHandler
			serv.Action_Type__c = OrchestratorConstants.ServiceActionType.PayOut; // Used in Orchestration_OrderDeltaHandler
			servlist.add(serv);
		}

		if (isInsert) {
			insert servlist;
		}

		return servlist;
	}

	public static List<csord__Service__c> buildServiceWOReplace(Boolean isInsert, integer count, Id SubsId, Id ordReqId, Id orderId, Id productconfiglistId) {
		cscfga__Product_Configuration__c pcNewMdm = new cscfga__Product_Configuration__c();
		pcNewMdm.name = 'Enterprise Mobility Managed Service';
		pcNewMdm.Type__c = 'New';
		pcNewMdm.ConfigurationType1__c = 'SolutionComponent';
		pcNewMdm.Quantity_Product_Configuration__c = 111;
		insert pcNewMdm;

		csord__Service__c servReplacement = new csord__Service__c();
		servReplacement.name = 'testService';
		servReplacement.csord__Subscription__c = SubsId; //requried Field
		servReplacement.csord__Identification__c = Identification; //requried Field
		servReplacement.csord__Status__c = 'In progress';
		servReplacement.Payment_Type__c = 'Cash';
		insert servReplacement;

		//Attachement releated to replacement service should not be null , requried in Orchestration_RecreateDeletedSpecs
		Attachment att1 = new Attachment();
		att1.body = Blob.valueOf(
			'{ "legacyAttributes" : [ ], "serviceId" : "' +
			servReplacement.id +
			'", "specifications" : [ { "additionalAttributes" : { "IPWirelessProductInstanceID" : "abcd", "DMCAT_ProductSpecification_000263_CPEDeliveryDate" : "2019-03-14T08:00:00" }, "attributes" : { "IPWirelessProductInstanceID" : "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem" : "FULFILMENT", "SERVICEPROFILE" : "DATA_BACKUP", "MESSAGEBANK" : "NA", "INTROAM" : "NA", "CONTEXT" : "NA", "CALLCONTROL" : "NA", "AccessRole" : "Primary", "BillofMaterialID" : "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID" : "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate" : "", "ShippingRequired" : "TRUE", "IMSI" : "", "SIMSerialNumber" : "" }, "code" :"DMCAT_ProductSpecification_000263_Fulfilment", "description" : "", "endDate" : "", "guid" : "963263ce-cb0a-64cd-17d6-06b524f533e1", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "Mobile Access_Fulfilment", "productConfigurationId" : "' +
			pcNewMdm.id +
			'", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate" : "", "status" : "Disconnect In Progressss", "version" : "1" }]}'
		);
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = servReplacement.id;
        insert att1;
        
        for(integer i=0; i<count; i++){
            csord__Service__c serv = new csord__Service__c();
            serv.name ='testService '+i;
            serv.csord__Identification__c  = 'testIdentify_4'; //requried Field
            serv.csordtelcoa__Service_Number__c = '3';
            serv.csord__Subscription__c = SubsId; //requried Field
            serv.csord__Status__c = 'Created';
            serv.substage__c = 'Product Requirements Validation';
            serv.csord__Order_Request__c = ordReqId;
            serv.csord__Order__c = orderId;
            serv.csordtelcoa__Product_Configuration__c = productconfiglistId;
            serv.csordtelcoa__Replaced_Service__c = servReplacement.Id;
            serv.csord__Status__c = 'In progress';
            serv.Payment_Type__c = OrchestratorConstants.ServicePaymentType.Rental; // Used in Orchestration_OrderDeltaHandler
            serv.Action_Type__c = OrchestratorConstants.ServiceActionType.PayOut; // Used in Orchestration_OrderDeltaHandler
            servlist.add(serv);
        }
        
        if(isInsert){
            insert servlist;
        }
        
        return servlist;
    }
    
    //Method for creating Subscription
    public static List<csord__Subscription__c> buildSubscription(Boolean isInsert, integer count, Id accID, List<csord__Order__c> orderList, Id productconfiglistId, Id solutionId) {
        // Don't add status to testSubscriptionReplacement
        csord__Subscription__c testSubscriptionReplacement = new csord__Subscription__c();
        testSubscriptionReplacement.Name = 'testSubscriptionReplacement';
        testSubscriptionReplacement.csord__Order__c = orderList[1].id; // used in Orchestration_EvaluateOrderStatusTest
        testSubscriptionReplacement.csord__Identification__c = Identification;
        testSubscriptionReplacement.triggerBill_RTB__c = false;
        insert testSubscriptionReplacement;
        
        for(integer i=0; i<count; i++){
            csord__Subscription__c testSubscription = new csord__Subscription__c();
            testSubscription.Name = 'TestSubsforTest'+i;
            testSubscription.csord__Account__c = accId;
            testSubscription.csord__Identification__c = 'test';
            testSubscription.csord__Status__c = OrchestratorConstants.SubscriptionStatus.Active; // used in Orchestration_EvaluateOrderStatusTest
            testSubscription.csord__Identification__c = Identification; //required Field
            testSubscription.csord__Order__c = orderList[0].id; // used in Orchestration_EvaluateOrderStatusTest
            testSubscription.csordtelcoa__Product_Configuration__c = productconfiglistId;   
            testSubscription.csordtelcoa__Replacement_Subscription__c = testSubscriptionReplacement.Id;
            testSubscription.triggerBill_RTB__c = false;
            testSubscription.cssdm__solution_association__c = solutionId;
            subscriptionList.add(testSubscription);
        }
        
        if(isInsert){
            insert subscriptionList;
        }
        
        return subscriptionList;
    }
    
	//Method for creating Subscription
	public static List<csord__Subscription__c> buildSubscriptionWOReplace(Boolean isInsert, integer count, Id accID, List<csord__Order__c> orderList, Id productconfiglistId, Id solutionId) {
		for (integer i = 0; i < count; i++) {
			csord__Subscription__c testSubscription = new csord__Subscription__c();
			testSubscription.Name = 'TestSubsforTest' + i;
			testSubscription.csord__Account__c = accId;
			testSubscription.csord__Identification__c = 'test';
			testSubscription.csord__Status__c = OrchestratorConstants.SubscriptionStatus.Active; // used in Orchestration_EvaluateOrderStatusTest
			testSubscription.csord__Identification__c = Identification; //required Field
			testSubscription.csord__Order__c = orderList[0].id; // used in Orchestration_EvaluateOrderStatusTest
			testSubscription.csordtelcoa__Product_Configuration__c = productconfiglistId;
			//testSubscription.csordtelcoa__Replacement_Subscription__c = testSubscriptionReplacement.Id;
			testSubscription.triggerBill_RTB__c = false;
			testSubscription.cssdm__solution_association__c = solutionId;
			testSubscription.eventId__c = 'Test' + i;
			subscriptionList.add(testSubscription);
		}

		if (isInsert) {
			insert subscriptionList;
		}

		return subscriptionList;
	}

	public static List<cscfga__Product_Configuration__c> buildProductConfiguration(Boolean isInsert, integer count) {
		List<cscfga__Product_Definition__c> prdList = buildProductDefination(true, 1);
        for(integer i=0; i<count; i++){
            cscfga__Product_Configuration__c pcNewMdm = new cscfga__Product_Configuration__c();
            pcNewMdm.name='Enterprise Mobility Managed Service '+i;
            pcNewMdm.Type__c='New';
            pcNewMdm.cscfga__Product_Definition__c = prdList[0].id;
            pcNewMdm.Quantity_Product_Configuration__c = 111;   
            pcNewMdm.ConfigurationType1__c = OrchestratorConstants.ProductConfigType.SolutionComponent; // used in Orchestration_EvaluateOrderStatusTest
            productconfiglistList.add(pcNewMdm);
        }
        
        if(isInsert){
            insert productconfiglistList;
        }
        
        return productconfiglistList;
    }
    
    public static List<csord__Solution__c> buildSolution(Boolean isInsert, integer count) {
        for(integer i=0; i<count; i++){
            csord__Solution__c sol = new csord__Solution__c();
            sol.csord__Identification__c = Identification; // required Field
            solutionList.add(sol);
        }
        
        if(isInsert){
            insert solutionList;
        }
        
        return solutionList;
    }
    
    public static List<Attachment> buildAttachment(Boolean isInsert, integer count, List<csord__Service__c> listService,Id productconfigId) {
		List<Attachment> atts = new List<Attachment>();
		for (integer i = 0; i < count; i++) {
			Attachment att1 = new Attachment();
			att1.Body = Blob.valueOf(
				'{ "legacyAttributes":[ ], "serviceId":"' +
				listService[i].Id +
        '", "specifications":[ { "additionalAttributes":{ "IPWirelessProductInstanceID":"91699412-512f-f8bd-2950-dedb06b0d13b", "DMCAT_ProductSpecification_000263_CPEDeliveryDate":"2019-03-14T08:00:00" }, "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000190_Fulfilment", "__targetSystem":"FULFILMENT", "SERVICEPROFILE":"DATA_BACKUP", "MESSAGEBANK":"NA", "INTROAM":"NA", "CONTEXT":"NA", "CALLCONTROL":"NA", "AccessRole":"Primary", "BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID":"61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate":"", "ShippingRequired":"TRUE", "IMSI":"", "SIMSerialNumber":"" }, "code":"DMCAT_ProductSpecification_000263_Fulfilment", "description":"", "endDate":"", "guid":"963263ce-cb0a-64cd-17d6-06b524f533e2", "includeBilling":false, "instanceId":"", "metadata":{"autoComplete":"true"}, "name":"Mobile Access_Fulfilment", "productConfigurationId":"a3T2O000000GuQXUA0", "specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate":"", "status":"Disconnect In Progress", "version":"1" }, { "additionalAttributes":{ }, "attributes":{ "__targetSystem":"ASSURANCE", "ServiceManagementOption ":"1" }, "code":"DMCAT_ProductSpecification_000326_Assurance", "description":"", "endDate":"", "guid":"68af7760-5543-670c-1454-489b1e40d1ca", "includeBilling":false, "instanceId":"", "metadata":{ }, "name":"Telstra Managed Service Option 1_Assurance", "productConfigurationId":"a3T2O000000GuQXUA0", "specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000326", "startDate":"", "status":"Disconnect Pending", "version":"1" }, { "additionalAttributes":{ }, "attributes":{ "__targetSystem":"BILLING", "billingSpecId":"BSUSG001_CB", "ocsProdID":"T22E_MIA_DATPLAN", "type":"Domestic Data", "unitofMeasure":"GB", "value":"Unlimited", "RoutingServiceType":"Mobile", "billDescription":"Mobile Interim Access Allowance", "SERVICEID":"61429751286", "IMSI":"" }, "code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3", "description":"", "endDate":"", "guid":"4acc4396-bddd-31c9-71f8-77930cb5a68c", "includeBilling":false, "instanceId":"", "metadata":{ }, "name":"Mobile Access_Bill_AW", "productConfigurationId":"a3T2O000000GuQXUA0", "specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3", "startDate":"", "status":"Disconnect Pending", "version":"1" }, { "additionalAttributes":{ }, "attributes":{ "__targetSystem":"BILLING", "billingSpecId":"BSUSG001_CB", "ocsProdID":"ocsProd3", "type":"Dummy ngUC", "unitofMeasure":"GB", "value":"Unlimited", "RoutingServiceType":"Voice", "billDescription":"ngUC Dummy Usage Specification Allowance" }, "code":"DMCAT_ProductSpecification_000313_Billing_Allowance_000512_4", "description":"", "endDate":"", "guid":"960b0d11-c4b0-21e9-d2a9-6f1aa15cd193", "includeBilling":false, "instanceId":"", "metadata":{ }, "name":"UC Numbers_Bill_AW", "productConfigurationId":"a3T2O000000GuQXUA0", "specification":"DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313_Billing_Allowance_000512_4", "startDate":"", "status":"Disconnect Pending", "version":"1" }, { "additionalAttributes":{ "BSServiceTypeProductInstanceID":"c557bd15-31b3-ccea-b9da-a9182979ac51", "DMCAT_ProductSpecification_000322_CPEDeliveryDate":"2019-03-14T08:00:00" }, "attributes":{ "BSServiceTypeProductInstanceID":"DMCAT_ProductSpecification_000312_Fulfilment", "__targetSystem":"FULFILMENT", "CustomerFacingServiceId":"", "CustomerPreferredName":"", "DMCAT_ProductSpecification_000322_CPEDeliveryDate":"" }, "code":"DMCAT_ProductSpecification_000322_Fulfilment", "description":"", "endDate":"", "guid":"70e2316f-6e03-54f5-38e6-d0d3eedb7c22", "includeBilling":false, "instanceId":"", "metadata":{ }, "name":"UC Site_Fulfilment", "productConfigurationId":"a3T2O000000GuQXUA0", "specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000322", "startDate":"", "status":"Disconnect In Progress", "version":"1" }, { "additionalAttributes":{ "InternetProtectionSolutionProductInstanceID":"97754883-23a9-375b-3af8-b991e4733a61" }, "attributes":{ "__targetSystem":"FULFILMENT", "UserProtectionType":"Web and Mail", "InternetProtectionSolutionProductInstanceID":"DMCAT_ProductSpecification_000163_Fulfilment", "Quantity":"3" }, "code":"DMCAT_ProductSpecification_000162_Fulfilment", "description":"", "endDate":"", "guid":"79d6ca6f-8288-aadc-8247-e939262c37d3", "includeBilling":false, "instanceId":"", "metadata":{ }, "name":"Web and Mail Internet Protection User_Fulfilment", "productConfigurationId":"a3T2O000000GuQXUA0", "specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000162", "startDate":"", "status":"Disconnect In Progress", "version":"1" }, { "additionalAttributes":{ "parentSpec":"68af7760-5543-670c-1454-489b1e40d1ca" }, "attributes":{ "__targetSystem":"ASSURANCE", "parentSpec":"DMCAT_ProductSpecification_000326_Assurance", "ResponseTarget":"", "RestoreTarget":"" }, "code":"DMCAT_ProductSpecification_000151_Assurance", "description":"", "endDate":"", "guid":"88893db5-4da5-93eb-45bf-73425cf7ce51", "includeBilling":false, "instanceId":"", "metadata":{ }, "name":"Incident Management_Assurance", "productConfigurationId":"a3T2O000000GuQXUA0", "specification":"DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151", "startDate":"", "status":"Disconnect Pending", "version":"1" }, { "additionalAttributes":{ "parentSpec":"70e2316f-6e03-54f5-38e6-d0d3eedb7c22" }, "attributes":{ "__targetSystem":"FULFILMENT", "name":"Hosted UC", "CustomerFacingServiceId":"", "id":"", "parentSpec":"DMCAT_ProductSpecification_000322_Fulfilment", "Quantity":"3" }, "code":"DMCAT_ProductSpecification_000315_Fulfilment", "description":"", "endDate":"", "guid":"c362d71e-94a3-8415-528a-26f1e09cf39f", "includeBilling":false, "instanceId":"", "metadata":{ }, "name":"Feature Packs_Fulfilment", "productConfigurationId":"a3T2O000000GuQXUA0", "specification":"DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000315", "startDate":"", "status":"Disconnect In Progress", "version":"1" }, { "additionalAttributes":{ "parentSpec":"70e2316f-6e03-54f5-38e6-d0d3eedb7c22" }, "attributes":{ "parentSpec":"DMCAT_ProductSpecification_000322_Fulfilment", "__targetSystem":"FULFILMENT", "VoicePlan":"Complete Premium", "id":"", "CustomerFacingServiceId":"", "Number":[ { "schemaId":"832ab1bd-4f74-5292-981d-7004e1ba8e58", "attributes":{ "FNN":"3333333333", "rangeFrom":null, "rangeTo":null, "status":"RESERVED", "listCode":"LE" } }, { "schemaId":"5efc4e53-4f93-df2f-8a95-afbfb462cdab", "attributes":{ "FNN":"8282345568", "rangeFrom":null, "rangeTo":null, "status":"RESERVED", "listCode":"No Entry Line" } }, { "schemaId":"0e129064-fdef-fa98-94ed-5be9dbb49e74", "attributes":{ "FNN":"8282345526", "rangeFrom":null, "rangeTo":null, "status":"RESERVED", "listCode":"No Entry Line" } } ] }, "code":"DMCAT_ProductSpecification_000313_Fulfilment", "description":"", "endDate":"", "guid":"033ce46a-f7de-48ca-23e6-41165dba9b65", "includeBilling":false, "instanceId":"", "metadata":{ }, "name":"UC Numbers_Fulfilment", "productConfigurationId":"a3T2O000000GuQXUA0", "specification":"DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313", "startDate":"", "status":"Disconnect In Progress", "version":"1" } ] }'
			);
			att1.Name = 'ServiceSpecifications.json';
			att1.ParentId = listService[i].id;
			attachmentList.add(att1);
        }
        
        if(isInsert){
            insert attachmentList;
        }
        
        return attachmentList;
    }
    
    public static List<Marketable_Offer__c> buildMarkertableOffer(Boolean isInsert, integer count){
        List<Marketable_Offer__c> offerList = new List<Marketable_Offer__c>();
        for(integer i=0;i<count;i++){
            Marketable_Offer__c offer = new Marketable_Offer__c();
            offer.name = 'Connected Workplace';
            offer.Offer_ID__c = 'DMCAT_Offer_000303';
            offer.Config__c='{"noLineItem":true,"skipBasketSyncValidations":true,"isSOWrequired":true,"SOMOpenAir":true}';   
            offerList.add(offer);  
        }
        if(isInsert){
            insert offerList;
        }
        
        return offerList;
    } 
    
    public static List<Asset> buildAsset(Boolean isInsert, integer count, Id accountId){
        DeviceReplacementController.shellProductDetailsWrapper shellProduct = new DeviceReplacementController.shellProductDetailsWrapper();
        shellProduct.replacedDeviceID='234435345345';
        shellProduct.replacementDeviceSKU = '34334534';
        shellProduct.replacementDeviceManufacturer = 'Apple';
        shellProduct.replacementDeviceModel = 'Apple 7 68GB';
        shellProduct.telstraNowCaseID = 'TNC1234';
        shellProduct.recoveryMethod = 'test';
        shellProduct.deviceCareCaseID = '534534345';
        shellProduct.returnReason ='warrenty';
        List<Asset> assetList = new List<Asset>();
        for(integer i=0;i<count;i++){
            Asset assetRecord = new Asset();
            assetRecord.AssetID__c= '456456456456';
            assetRecord.Status = 'Active';
            assetRecord.OfferID__c = '4534543';
            assetRecord.accountId= accountId;
            assetRecord.name= shellProduct.replacementDeviceManufacturer+' '+shellProduct.replacementDeviceModel;
            assetList.add(assetRecord);
        }
        
        if(isInsert){
            insert assetList;
        }
        
        return assetList;
    }
    
    public static List<Product_Attribute_Metadata__c> buildAttribute(Boolean isInsert, integer count){  
        List<Product_Attribute_Metadata__c> listMetadata = new List<Product_Attribute_Metadata__c>();
        for(integer i=0;i<count;i++){
            Product_Attribute_Metadata__c metadata1=new Product_Attribute_Metadata__c();
            metadata1.Name='Mobile Access';
            metadata1.Offer_Name__c='Connected Workplace';
            metadata1.Offer_Id__c='DMCAT_Offer_000303';
            metadata1.Metadata_Type__c='IsAssetable';
            metadata1.Metadata_Value__c='False';
            metadata1.Product_Name__c='Mobile Access';
            metadata1.Product_ID__c='DMCAT_ProductSpecification_000263';//used in Orchestration_GenerateTransientDataTest
            metadata1.Attribute_Name__c='SIMSerialNumber';
            metadata1.Change_Type__c='Modify';
            metadata1.Change_SubType__c='Modify';
            metadata1.IsReference__c=true;
            metadata1.ReferenceField__c='Sim_Serial_Number__c';
            metadata1.Identifier__c='DMCAT_ProductSpecification_000263_SIMSerialNumber';
            listMetadata.add(metadata1);
        }
        if(isInsert){
            insert listMetadata;
        }
        
        return listMetadata;
    }
    
    /*public static List<EnvironmentVariable__c> buildEnv(Boolean isInsert, integer count){
List<EnvironmentVariable__c> envList = new List<EnvironmentVariable__c>();
for(integer i=0;i<count;i++){
EnvironmentVariable__c env = new EnvironmentVariable__c();
env.Name = 'EnableHV';
env.Value__c ='false';
envList.add(env);
}
if(isInsert){
insert envList;
}

return envList;
}*/
    public static List<Opportunity> buildOpp(Boolean isInsert, integer count, List<Account> accList){
        List<Opportunity> oppList = new List<Opportunity>();
        for(integer i=0;i<count;i++){
            Opportunity opp = new Opportunity();
            opp.Name = 'Order Opp '+i;
            opp.AccountId = accList[i].id;
            opp.Product_Domain__c = 'MOBILES';
            opp.CloseDate = Date.today();
            opp.StageName = 'Devlope';
            opp.Description__c = 'To check functionality of testclass';
            opp.Billing_Solution__c = 'In Contract';
            opp.Contract_Type__c = 'Telstra Purple';
            opp.Pricing_Method__c = 'PET';
            oppList.add(opp);
        }
        if(isInsert){
            insert oppList;
        }
        
        return oppList;
    }
    public static List<cscrm__Site__c> buildsite(Boolean isInsert, integer count, List<Account> accList){
        List<cscrm__Site__c> siteList = new List<cscrm__Site__c>();
        for(integer i=0;i<count;i++){
            cscrm__Site__c site = new cscrm__Site__c();
            site.Name = 'site '+i;
            site.cscrm__Account__c = accList[i].id;
            siteList.add(site);
        }
        if(isInsert){
            insert siteList;
        }
        
        return siteList;
    }
    
    public static List<cscfga__Product_Definition__c> buildProductDefination(Boolean isInsert, integer count){
        List<cscfga__Product_Definition__c> prdList = new List<cscfga__Product_Definition__c>();
        for(integer i=0;i<count;i++){
            cscfga__Product_Definition__c prd = new cscfga__Product_Definition__c();
            prd.Name = 'prd '+i;
            prd.EDMSpecToSuppressInRTB__c = '965_NRC_984';
            prd.cscfga__Description__c = 'product defination des';
            prd.product_Specification__c = 'Model5';
            prdList.add(prd);
        }
        if(isInsert){
            insert prdList;
        }
        
        return prdList;
    }
    
    public static List<Case> buildCase(Boolean isInsert, integer count, List<Opportunity> oppList, List<account> accList){
        List<Case> caseList = new List<Case>();
        for(integer i=0;i<count;i++){
            case caseObj = new Case();
            caseObj.subject = 'Case Subject';
            caseObj.OpportunityId__c = oppList[i].id;
            caseObj.AccountId = accList[i].id; 
            caseList.add(caseObj);   
        }
        if(isInsert){
            insert caseList;
        }
        
        return caseList;
    }
    
     public static List<Number__c> buildNumber(Boolean isInsert, integer count, List<cscfga__Product_Configuration__c> prdList, String serId, String subId){
        List<Number__c> numList  = new List<Number__c>();
        for(integer i=0;i<count;i++){
            Number__c num = new Number__c();
            num.Product_Configuration__c = prdList[i].Id;
            num.Subscription_number__c = subId;
            num.Service_Id__c = serId;
            numList.add(num);         
        }
        if(isInsert){
            insert numList;
        }
        
        return numList;
    }
    
    public static List<Charge_Line_Item__c> buildCLIs(Boolean isInsert, integer count, List<csord__Service__c> serviceList){
        List<Charge_Line_Item__c> cliList  = new List<Charge_Line_Item__c>();
        for(integer i=0;i<count;i++){
            Charge_Line_Item__c cli = new Charge_Line_Item__c();
            cli.CorrelationId__c = 'CLI-ID123';
            cli.chargeType__c = 'NonChargeable';
            cli.basketId__c = 'Basket-ID123';
            cli.status__c = 'In Progress';
            cli.unitPrice__c = 123;
            cli.contractTerm__c = 456;
            cli.serviceId__c = serviceList[i].Id;
            cli.billingSpecIdentifier__c = null;
            cli.BusinessID__c = 'DMCAT_Allowance_000494_3';
            cliList.add(cli);         
        }
        if(isInsert){
            insert cliList;
        }
        
        return cliList;
    }
    
    public static List<Discount_Line_Item__c> buildDLIs(Boolean isInsert, integer count, List<Charge_Line_Item__c> cLIs){
        List<Discount_Line_Item__c> dSLIs  = new List<Discount_Line_Item__c>();

        for(Charge_Line_Item__c cLI : cLIs) {
            for(integer i=0;i<count;i++){
                Discount_Line_Item__c dSLI = new Discount_Line_Item__c();
                dSLI.Name = 'Test'+i;
                dSLI.chargeInstance__c = cLI.Id;
                dSLIs.add(dSLI);         
            }
        }
        if(isInsert){
            insert dSLIs;
        }
        
        return dSLIs;
    }
    
    public static List<Price_Schedule_Line_Item__c> buildPSLIs(Boolean isInsert, integer count, List<Charge_Line_Item__c> cLIs){
        List<Price_Schedule_Line_Item__c> pSLIs  = new List<Price_Schedule_Line_Item__c>();

        for(Charge_Line_Item__c cLI : cLIs) {
            for(integer i=0;i<count;i++){
                Price_Schedule_Line_Item__c pSLI = new Price_Schedule_Line_Item__c();
                pSLI.Name = 'Test'+i;
                pSLI.chargeInstance__c = cLI.Id;
                pSLIs.add(pSLI);         
            }
        }
        if(isInsert){
            insert pSLIs;
        }
        
        return pSLIs;
    }

	public static List<ApplicationLog__c> buildApp(Boolean isInsert, integer count, List<CSPOFA__Orchestration_Step__c> orchStepList, List<CSPOFA__Orchestration_Process__c> processList) {
		List<ApplicationLog__c> appLog = new List<ApplicationLog__c>();

		for (integer i = 0; i < count; i++) {
			ApplicationLog__c log = new ApplicationLog__c();
			log.Reference_Info__c = 'Rajani Sharma';
			log.Debug_Level__c = 'Warning';
			log.Request_Message__c = 'This is for request Message';
			log.Message__c = OrchestratorConstants.SystemConstant.AttachmentMsg;
			log.Stack_Trace__c = 'This is for Stack trace';
			log.Error_Category__c = 'Technical';
			log.Step__c = orchStepList[i].Id;
			log.Related_Record_Id__c = processList[i].Id;
			appLog.add(log);
		}

		if (isInsert) {
			insert appLog;
		}

		return appLog;
	}

    public static List<Tier_Line_Item__c> buildTLIs(Boolean isInsert, integer count, List<Price_Schedule_Line_Item__c> pSLIs){
        List<Tier_Line_Item__c> tLIs  = new List<Tier_Line_Item__c>();

        for(Price_Schedule_Line_Item__c pLI : pSLIs) {
            for(integer i=0;i<count;i++){
                Tier_Line_Item__c tLI = new Tier_Line_Item__c();
                tLI.Name = 'Test'+i;
                tLI.PSLIInstance__c = pLI.Id;
                tLIs.add(tLI);         
            }
        }
        if(isInsert){
            insert tLIs;
        }
        
        return tLIs;
    }

	public static List<cscfga__Attribute__c> buildAttr(Boolean isInsert, Integer count, String attrName, String attrValue, Id productConfigId) {
		List<cscfga__Attribute__c> attrList = new List<cscfga__Attribute__c>();
		for (integer i = 0; i < count; i++) {
			cscfga__Attribute__c attr = new cscfga__Attribute__c();
			attr.Name = String.isNotBlank(attrName) ? attrName + ' ' + i : 'Test' + i;
			attr.cscfga__Product_Configuration__c = productConfigId;
			attr.cscfga__Value__c = attrValue;
			attrList.add(attr);
		}
		if (isInsert) {
			insert attrList;
		}

		return attrList;
	}

    public static List<PricingMSResponseObject__c> buildPMSs(Boolean isInsert, integer count, List<Charge_Line_Item__c> CLIList){
        List<PricingMSResponseObject__c> pmsList  = new List<PricingMSResponseObject__c>();
        Discount_Line_Item__c dis = new Discount_Line_Item__c();
        insert dis;
        for(integer i=0;i<count;i++){
            PricingMSResponseObject__c pms = new PricingMSResponseObject__c();
            pms.CLI_Instance_ID__c = String.valueOf(CLIList[i].Id);
            pms.CorrelationId__c = 'CLI-ID123';
			pms.ResponsePayload__c =
				'{ "chargeLineItems": { "unitPrice__c": 68.18, "contractTerm__c": 24, "businessID__c": "DMCAT_RecurringCharge_000654", "unitTotalContractValue__c": 820.68, "priceScheduleLineItem": [ { "id": "PSLI1", "fromPeriod__c": 1, "toPeriod__c": 3, "unitPrice__c": 22.12, "applicationDuration__c": 3, "applicableDiscounts": [ { "id": "' +
				dis.id +
				'", "description": "MRO Bonus", "discountAmount": "10.0", "appliedDiscountAmount__c": 10.15 }, { "id": "' +
				dis.id +
				'", "description": "Activation Credit", "discountAmount": "100.0 %", "appliedDiscountAmount__c": 100.65 } ], "tierLineItems": [ { "fromUnit__c": "0", "toUnit__c": "100", "discounted_Price__c": 5.2, "appliedDiscountAmount__c": 2.1, "rateCardLineIdentifier__c": "DMCAT_Offer_000618_DMCAT_ProductSpecification_000872_DMCAT_RecurringCharge_000808_6953" }, { "fromUnit__c": "101", "toUnit__c": "200", "discounted_Price__c": 4.5, "appliedDiscountAmount__c": 2.1, "rateCardLineIdentifier__c": "DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000808_6953" }, { "fromUnit__c": "201", "toUnit__c": "500", "discounted_Price__c": 4.1, "appliedDiscountAmount__c": 2.1, "rateCardLineIdentifier__c": "DMCAT_Offer_000618_DMCAT_ProductSpecification_000873_DMCAT_RecurringCharge_000808_6953" } ] } ] } }';
            pmsList.add(pms);         
        }
        if(isInsert){
            insert pmsList;
        }
        
        return pmsList;
    }
    
    public static User buildUserWithContact(boolean isInsert){
        UserRole portalRole = new UserRole(DeveloperName = 'NewUser', Name = 'TestRole', PortalType = 'None');
        insert portalRole;
        /* UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
system.debug('portalRole is ' + portalRole);*/
        
		Profile profile1 = [SELECT Id FROM Profile WHERE name = 'System Administrator'];
        User portalAccountOwner1 = new User(
            UserRoleId = portalRole.Id,
            ProfileId = profile1.Id,
            Username = System.now().millisecond() + 'test2@test.com',
            Alias = 'batman',
            Email='bruce.wayne@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
        );
        Database.insert(portalAccountOwner1);
        
        //User u1 = [Select ID From User Where Id =: portalAccountOwner1.Id];
        User user1 ;
        System.runAs ( portalAccountOwner1 ) {
            //Create account
			Account portalAccount1 = new Account(Name = 'TestAccount', OwnerId = portalAccountOwner1.Id);
			Database.insert(portalAccount1);

			//Create contact
			Contact contact1 = new Contact(FirstName = 'Test', Lastname = 'McTesty', AccountId = portalAccount1.Id, Email = System.now().millisecond() + 'test@test.com');
			Database.insert(contact1);

			//Create user
			Profile portalProfile = [SELECT Id FROM Profile LIMIT 1];
            user1 = new User(
                Username = System.now().millisecond() + 'test12345@test.com',
                ContactId = contact1.Id,
                ProfileId = portalProfile.Id,
                Alias = 'test123',
                Email = 'test12345@test.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'McTesty',
                CommunityNickname = 'test12345',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US'
            );
            Database.insert(user1);
        }
        if(isInsert){
            insert user1;
        }
        
        return user1;
    }
    
    public static List<User> buildUser(Boolean isInsert, integer count){
        List<User> userList = new List<User>();
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        //Create user
        User user1 = new User(
            Username = uniqueName+'test12345@test.com',
            UserRoleId = r.Id,
			ProfileId = [SELECT Id FROM Profile WHERE name = 'System Administrator']
			.Id,
            Alias = 'test123',
            Email = 'test12345@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'McTesty',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        
        userList.add(user1);
        
        if(isInsert){
            insert userList;
        }
        
        return userList;
    }
}