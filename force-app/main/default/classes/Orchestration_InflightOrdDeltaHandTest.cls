/**================================================================
* Name: Orchestration_InflightOrdDeltaHandTest
* Main Class : Orchestration_InflightOrdDeltaHandler
* Created Date: Jan 18, 2021
* Created By: Gnana
* Sr.No.    Developer Name      Date          Story Description
  1.       Gnana               08/02/2021   EDGE-195797 : Added test method
  2.     Gnana         10/03/2021   Modified to include Service Orch Process OnHold Logic
==================================================================*/
@isTest(SeeAllData=false)
public class Orchestration_InflightOrdDeltaHandTest {
    @Testsetup
    static void dataSetup() {
        List<CSPOFA__Orchestration_Process__c> processList = new List<CSPOFA__Orchestration_Process__c>();
        List<CSPOFA__Orchestration_Process_Template__c> processTempList = new List<CSPOFA__Orchestration_Process_Template__c>();
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        csordtelcoa__Orders_Subscriptions_Options__c subsSettings = new csordtelcoa__Orders_Subscriptions_Options__c();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        List<account> accountList = new List<account>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<csord__Order_Request__c> orderReqList = new List<csord__Order_Request__c>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        List<cscfga__Product_Definition__c> prdList = new List<cscfga__Product_Definition__c>();
        list<cscfga__Product_Configuration__c> productconfiglistList = new List<cscfga__Product_Configuration__c>();
        list<csord__Solution__c> solutionList = new List<csord__Solution__c>();
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        List<csord__Service__c> servlist = new List<csord__Service__c>();
        list<Attachment> attachmentList = new List<Attachment>();
        
        subsSettings = Orchestration_TestUtility.buildsubOption();
        governerLimit = Orchestration_TestUtility.buildLimits();
        accountList = Orchestration_TestUtility.buildAccount(true, 1);
        oppList = Orchestration_TestUtility.buildOpp(true, 1, accountList);
        orderReqList = Orchestration_TestUtility.buildOrderRequest(true, 1);
        
        processTempList = Orchestration_TestUtility.buildProcessTemplate(false, 3);
        processTempList[1].Name='Subscription Fulfilment Process';
        processTempList[2].Name='Service Fulfilment Process';
        insert processTempList;
        
        orderList = Orchestration_TestUtility.buildOrder('order', accountList[0].id, 'Complete', orderReqList[0].id, true, 8);
        orderList[0].Fulfilment_Order_Version__c = 1;
        prdList = Orchestration_TestUtility.buildProductDefination(true, 1);
    
        productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(false, 2);
        productconfiglistList[1].ConfigurationType1__c = 'Product Component';
        productconfiglistList[0].cscfga__Product_Definition__c = prdList[0].id;
        productconfiglistList[1].cscfga__Product_Definition__c = prdList[0].id;
        productconfiglistList[1].Remaining_Term__c = 0;
        productconfiglistList[0].Remaining_Term__c = 0;
        insert productconfiglistList;
        
        solutionList = Orchestration_TestUtility.buildSolution(true, 1);
        
        subscriptionList = Orchestration_TestUtility.buildSubscription(false, 3, accountList[0].id, orderList, productconfiglistList[0].id, solutionList[0].id);
        subscriptionList[0].orderversion__c = 1;
        subscriptionList[2].orderversion__c = 1;
        subscriptionList[1].Action_Type__c = 'Rollback Amend';
        //subscriptionList[2].Action_Type__c = 'Rollback Amend';
        insert subscriptionList;
    System.debug('subscriptionList[1]...'+subscriptionList[1].Id);
        
        servlist = Orchestration_TestUtility.buildService(false,3, subscriptionList[0].id, orderReqList[0].id, orderList[0].id, productconfiglistList[0].id);
        servlist[1].csord__Subscription__c = subscriptionList[1].id;
        //servlist[2].csord__Subscription__c = subscriptionList[2].id;
        //servlist[2].Action_Type__c = 'New';
        servlist[1].changeType__c = 'New';
        servlist[0].Name = 'Test Service 1';
        servlist[0].changeType__c = 'Modify';
        servlist[2].csord__Subscription__c = subscriptionList[2].id;
        insert servlist;
    System.debug('subscriptionList[1]...'+servlist[1].csord__Subscription__c);
        
        processList = Orchestration_TestUtility.buildProcess(false, 3, processTempList[0].id, orderList, subscriptionList, accountList[0].id, servlist[0].id);
        processList[1].CSPOFA__Orchestration_Process_Template__c = processTempList[1].Id;
        processList[1].csordtelcoa__Subscription__c = subscriptionList[1].id;
        //processList[1].csordtelcoa__Service__c = servlist[1].id;
        processList[0].CSPOFA__Orchestration_Process_Template__c = processTempList[1].Id;
        processList[2].CSPOFA__Orchestration_Process_Template__c = processTempList[2].Id;
        processList[2].csordtelcoa__Service__c = servlist[2].id;
        insert processList;
    System.debug('subscriptionList[1]...'+processList[1].csordtelcoa__Subscription__c);
        
        orchStepList = Orchestration_TestUtility.buildOrchStep(false, 2, processList);
        orchStepList[0].name = 'Process Test';
        orchStepList[1].name = 'Provisioned Test';
        //orchStepList[1].CSPOFA__Orchestration_Process__c = processList[2].Id;
        for (CSPOFA__Orchestration_Step__c step : orchStepList) {
            step.JSON__c = null;
        }
        insert orchStepList;
        System.debug('orchStepList...'+orchStepList);
    
        attachmentList = Orchestration_TestUtility.buildAttachment(false, 1, servlist, productconfiglistList[0].id);
        attachmentList[0].body = Blob.valueOf(
            '{ "legacyAttributes":[ ], "serviceId":"' +
            servlist[0].Id +
            '", "specifications":[ { "additionalAttributes":{ }, "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
            OrchestratorConstants.TargetSystem.ASSURANCE +
            '" }, "code":"DMCAT_ProductSpecification_000263_Fulfilment", "name":"Mobile Access_Fulfilment", "productConfigurationId":"a3T2O000000GuQXUA0", "specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate":"", "status":"' +
            OrchestratorConstants.ServiceStatus.Created +
            '", "version":"1" }, { "additionalAttributes":{ }, "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
            OrchestratorConstants.TargetSystem.FULFILMENT +
            '", "SERVICEPROFILE":"DATA_BACKUP", "MESSAGEBANK":"NA", "INTROAM":"NA", "CONTEXT":"NA", "CALLCONTROL":"NA", "AccessRole":"Primary", "BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID":"61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate":"", "ShippingRequired":"TRUE", "IMSI":"", "SIMSerialNumber":"" }, "code":"DMCAT_ProductSpecification_000263_Fulfilment", "description":"", "endDate":"", "guid":"G002", "includeBilling":false, "instanceId":"", "metadata":{ }, "name":"Mobile Access_Fulfilment1", "productConfigurationId":"a3T2O000000GuQXUA0", "specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate":"", "status":"' +
            Label.Complete +
            '", "version":"1" }, { "additionalAttributes":{ }, "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
            OrchestratorConstants.TargetSystem.BILLING +
            '", "SERVICEPROFILE":"DATA_BACKUP", "MESSAGEBANK":"NA", "INTROAM":"NA", "CONTEXT":"NA", "CALLCONTROL":"NA", "AccessRole":"Primary", "BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID":"61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate":"", "ShippingRequired":"TRUE", "IMSI":"", "SIMSerialNumber":"" }, "code":"' +
            OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000622 +
            '", "description":"", "endDate":"", "guid":"G003", "includeBilling":false, "instanceId":"", "metadata":{ }, "name":"Mobile Access_Fulfilment2", "productConfigurationId":"a3T2O000000GuQXUA0", "specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate":"", "status":"' +
            Label.Complete +
            '", "version":"1" }, { "additionalAttributes":{ }, "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
            OrchestratorConstants.TargetSystem.BILLING +
            '", "SERVICEPROFILE":"DATA_BACKUP", "MESSAGEBANK":"NA", "INTROAM":"NA", "CONTEXT":"NA", "CALLCONTROL":"NA", "AccessRole":"Primary", "BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID":"61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate":"", "ShippingRequired":"TRUE", "IMSI":"", "SIMSerialNumber":"" }, "code":"' +
            OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000423 +
            '", "description":"", "endDate":"", "guid":"G003", "includeBilling":false, "instanceId":"", "metadata":{ }, "name":"Mobile Access_Fulfilment3", "productConfigurationId":"a3T2O000000GuQXUA0", "specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate":"", "status":"' +
            OrchestratorConstants.ServiceActionType.PaidOut +
            '", "version":"1" }, { "additionalAttributes":{ }, "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
            OrchestratorConstants.TargetSystem.BILLING +
            '", "SERVICEPROFILE":"DATA_BACKUP", "MESSAGEBANK":"NA", "INTROAM":"NA", "CONTEXT":"NA", "CALLCONTROL":"NA", "AccessRole":"Primary", "BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID":"61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate":"", "ShippingRequired":"TRUE", "IMSI":"", "SIMSerialNumber":"" }, "code":"' +
            OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000423 +
            '", "description":"", "endDate":"", "guid":"G003", "includeBilling":false, "instanceId":"", "metadata":{ }, "name":"Mobile Access_Fulfilment3", "productConfigurationId":"a3T2O000000GuQXUA0", "specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate":"", "status":"' +
            OrchestratorConstants.ServiceStatus.Disconnected +
            '", "version":"1" }, { "additionalAttributes":{ }, "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
            OrchestratorConstants.TargetSystem.FULFILMENT +
            '", "SERVICEPROFILE":"DATA_BACKUP", "MESSAGEBANK":"NA", "INTROAM":"NA", "CONTEXT":"NA", "CALLCONTROL":"NA", "AccessRole":"Primary", "BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID":"61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate":"", "ShippingRequired":"TRUE", "IMSI":"", "SIMSerialNumber":"" }, "code":"' +
            OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000423 +
            '", "description":"", "endDate":"", "guid":"G003", "includeBilling":false, "instanceId":"", "metadata":{ }, "name":"Mobile Access_Fulfilment4", "productConfigurationId":"a3T2O000000GuQXUA0", "specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate":"", "status":"' +
            Label.Complete +
            '", "version":"1" }, { "additionalAttributes":{ }, "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
            OrchestratorConstants.TargetSystem.FULFILMENT +
            '", "SERVICEPROFILE":"DATA_BACKUP", "MESSAGEBANK":"NA", "INTROAM":"NA", "CONTEXT":"NA", "CALLCONTROL":"NA", "AccessRole":"Primary", "BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID":"61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate":"", "ShippingRequired":"TRUE", "IMSI":"", "SIMSerialNumber":"" }, "code":"' +
            OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000423 +
            '", "description":"", "endDate":"", "guid":"G003", "includeBilling":false, "instanceId":"", "metadata":{ }, "name":"Mobile Access_Fulfilment5", "productConfigurationId":"a3T2O000000GuQXUA0", "specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate":"", "status":"' +
            OrchestratorConstants.ServiceActionType.PaidOut +
            '", "version":"1" }, { "additionalAttributes":{ }, "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
            OrchestratorConstants.TargetSystem.FULFILMENT +
            '", "SERVICEPROFILE":"DATA_BACKUP", "MESSAGEBANK":"NA", "INTROAM":"NA", "CONTEXT":"NA", "CALLCONTROL":"NA", "AccessRole":"Primary", "BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID":"61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate":"", "ShippingRequired":"TRUE", "IMSI":"", "SIMSerialNumber":"" }, "code":"' +
            OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000423 +
            '", "description":"", "endDate":"", "guid":"G003", "includeBilling":false, "instanceId":"", "metadata":{ }, "name":"Mobile Access_Fulfilment6", "productConfigurationId":"a3T2O000000GuQXUA0", "specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate":"", "status":"' +
            OrchestratorConstants.ServiceActionType.PaidOut +
            '", "version":"1" }, { "additionalAttributes":{ }, "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
            OrchestratorConstants.TargetSystem.FULFILMENT +
            '", "SERVICEPROFILE":"DATA_BACKUP", "MESSAGEBANK":"NA", "INTROAM":"NA", "CONTEXT":"NA", "CALLCONTROL":"NA", "AccessRole":"Primary", "BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID":"61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate":"", "ShippingRequired":"TRUE", "IMSI":"", "SIMSerialNumber":"" }, "code":"' +
            OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000423 +
            '", "description":"", "endDate":"", "guid":"G003", "includeBilling":false, "instanceId":"", "metadata":{ }, "name":"Mobile Access_Fulfilment7", "productConfigurationId":"a3T2O000000GuQXUA0", "specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate":"", "status":"' +
            Label.Complete +
            '", "version":"1" }, { "additionalAttributes":{ }, "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
            OrchestratorConstants.TargetSystem.FULFILMENT +
            '", "SERVICEPROFILE":"DATA_BACKUP", "MESSAGEBANK":"NA", "INTROAM":"NA", "CONTEXT":"NA", "CALLCONTROL":"NA", "AccessRole":"Primary", "BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID":"61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate":"", "ShippingRequired":"TRUE", "IMSI":"", "SIMSerialNumber":"" }, "code":"' +
            OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000423 +
            '", "description":"", "endDate":"", "guid":"G003", "includeBilling":false, "instanceId":"", "metadata":{ }, "name":"Mobile Access_Fulfilment8", "productConfigurationId":"a3T2O000000GuQXUA0", "specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate":"", "status":"' +
            Label.Complete +
            '", "version":"1" }, { "additionalAttributes":{ }, "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
            OrchestratorConstants.TargetSystem.FULFILMENT +
            '", "SERVICEPROFILE":"DATA_BACKUP", "MESSAGEBANK":"NA", "INTROAM":"NA", "CONTEXT":"NA", "CALLCONTROL":"NA", "AccessRole":"Primary", "BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID":"61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate":"", "ShippingRequired":"TRUE", "IMSI":"", "SIMSerialNumber":"" }, "code":"' +
            OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000423 +
            '", "description":"", "endDate":"", "guid":"G003", "includeBilling":false, "instanceId":"", "metadata":{ }, "name":"Mobile Access_Fulfilment9", "productConfigurationId":"a3T2O000000GuQXUA0", "specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate":"", "status":"' +
            OrchestratorConstants.ServiceStatus.Disconnected +
            '", "version":"1" } ] }'
        );
        insert attachmentList;
    }
    
    static testMethod void testProcess_OrchProcessUpdate() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c Where Name = 'Process Test' ];
        
        Test.startTest();
        Orchestration_InflightOrdDeltaHandler inflightDeltaHandler = new Orchestration_InflightOrdDeltaHandler();
        orchStepList = inflightDeltaHandler.process(orchStepList);
        System.assert(orchStepList.size() > 0);
        List<CSPOFA__Orchestration_Process__c> processList = [SELECT Id,Name,CSPOFA__Process_On_Hold__c FROM CSPOFA__Orchestration_Process__c Where CSPOFA__Orchestration_Process_Template__r.Name = 'Subscription Fulfilment Process'];
        System.assertEquals(true, processList[0].CSPOFA__Process_On_Hold__c);
        Test.stopTest();
    }
    
    // Added test method as part of EDGE-195797
    static testMethod void testProcess_SubsStatusUpdate1() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c Where Name = 'Process Test' ];
        
        Test.startTest();
        Orchestration_InflightOrdDeltaHandler inflightDeltaHandler = new Orchestration_InflightOrdDeltaHandler();
        orchStepList = inflightDeltaHandler.process(orchStepList);
        System.assert(orchStepList.size() > 0);
        List<csord__subscription__c> subsList = [SELECT Id,Name,csord__status__c FROM csord__subscription__c];
        System.assertEquals('Provisioned', subsList[2].csord__status__c);
        Test.stopTest();
    }
    
    static testMethod void testProcess_ServtoBeChanged() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c,CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c Where Name = 'Process Test' ];
        List<csord__Service__c> servList = [SELECT Id,Name FROM csord__Service__c where csord__Subscription__c= :orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c];
        servList[0].csordtelcoa__Cancelled_By_Change_Process__c = true;
        update servList;
        Test.startTest();
        Orchestration_InflightOrdDeltaHandler inflightDeltaHandler = new Orchestration_InflightOrdDeltaHandler();
        orchStepList = inflightDeltaHandler.process(orchStepList);
        System.assert(orchStepList.size() > 0);
        Test.stopTest();
    }
    
    static testMethod void testProcess_ServtoBeChanged1() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c,CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c Where Name = 'Process Test' ];
        List<csord__Service__c> servList = [SELECT Id,Name FROM csord__Service__c where csord__Subscription__c= :orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c];
        servList[0].csordtelcoa__Cancelled_By_Change_Process__c = true;
        servList[0].csord__Status__c = 'Amend Rejected';
        update servList;
        Test.startTest();
        Orchestration_InflightOrdDeltaHandler inflightDeltaHandler = new Orchestration_InflightOrdDeltaHandler();
        orchStepList = inflightDeltaHandler.process(orchStepList);
        System.assert(orchStepList.size() > 0);
        Test.stopTest();
    }
    
    static testMethod void testProcess_SubstoBeChanged() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c,CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c Where Name = 'Process Test' ];
        List<csord__subscription__c> subsList = [SELECT Id,Name,csord__status__c FROM csord__subscription__c where id =:orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c];
        subsList[0].csordtelcoa__Cancelled_By_Change_Process__c = true;
        update subsList;
        Test.startTest();
        Orchestration_InflightOrdDeltaHandler inflightDeltaHandler = new Orchestration_InflightOrdDeltaHandler();
        orchStepList = inflightDeltaHandler.process(orchStepList);
        System.assert(orchStepList.size() > 0);
        Test.stopTest();
    }
    
    static testMethod void testProcess_SubstoBeChanged1() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c,CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c Where Name = 'Process Test' ];
        List<csord__subscription__c> subsList = [SELECT Id,Name,csord__status__c FROM csord__subscription__c where id =:orchStepList[0].CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c];
        subsList[0].csordtelcoa__Cancelled_By_Change_Process__c = true;
        subsList[0].csord__Status__c = 'Amend Rejected';
        update subsList;
        Test.startTest();
        Orchestration_InflightOrdDeltaHandler inflightDeltaHandler = new Orchestration_InflightOrdDeltaHandler();
        orchStepList = inflightDeltaHandler.process(orchStepList);
        System.assert(orchStepList.size() > 0);
        Test.stopTest();
    }
    
    static testMethod void breakingLimits() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
        governerLimit.SOQL_limit__c = '0';
        update governerLimit;
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c LIMIT 1];
        
        Orchestration_InflightOrdDeltaHandler orderDeltaHandler = new Orchestration_InflightOrdDeltaHandler();
        orchStepList = orderDeltaHandler.process(orchStepList);
        boolean isNull = orchStepList == null ? true : false;

        System.assertEquals(orchStepList == null, true);
        Test.stopTest();
    }
    
    static testMethod void testIncompleteStep() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, DML_Rows_limit__c FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '1';
        update governerLimit;
        
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c FROM CSPOFA__Orchestration_Step__c WHERE CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c != null LIMIT 1];
        
        Orchestration_InflightOrdDeltaHandler orderDeltaHandler = new Orchestration_InflightOrdDeltaHandler();
        orchStepList = orderDeltaHandler.process(orchStepList);
        List<csord__Service__c> serviceList = [SELECT Id, name, toBeCancelled__c, csord__Status__c FROM csord__Service__c WHERE toBeCancelled__c = 'true'];
        Test.startTest();
        System.assert(orchStepList.size() > 0);
        governerLimit = [SELECT Id, DML_Rows_limit__c FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '5000';
        update governerLimit;
        orchStepList = orderDeltaHandler.process(orchStepList);
        Test.stopTest();
    }
    
    static testMethod void testProcess_ServSpecStatusUpdate() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c Where Name = 'Process Test' ];
        
        Test.startTest();
        Orchestration_InflightOrdDeltaHandler inflightDeltaHandler = new Orchestration_InflightOrdDeltaHandler();
        orchStepList = inflightDeltaHandler.process(orchStepList);
        System.assert(orchStepList.size() > 0);
        Map<Id, Orchestration_AttachmentWrapper> serviceToAttachWrapperMap = new Map<Id, Orchestration_AttachmentWrapper>();
        Map<Id, csord__Service__c> servMap = new Map<Id, csord__Service__c>([SELECT Id,Name FROM csord__Service__c WHERE Name ='Test Service 1']);
        Map<Id, Attachment> servSpecAttMap =new Map<Id, Attachment>([SELECT Id,Name,body,parentId FROM Attachment WHERE parentId IN :servMap.keySet() AND Name = 'ServiceSpecifications.json']);
        for (Attachment att : servSpecAttMap.values()) {
            serviceToAttachWrapperMap.put(att.parentId, new Orchestration_AttachmentWrapper(att.Id, att.body));
        }
        for (csord__service__c service : servMap.values()) {
            if (serviceToAttachWrapperMap != null && serviceToAttachWrapperMap.containskey(service.Id)) {
                String serviceattachmentstr = serviceToAttachWrapperMap.get(service.Id).attchBody.toString();
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(serviceattachmentstr);
                List<Object> lstSpecifications = (List<Object>) results.get(OrchestratorConstants.ServiceSpecificationKey.Specifications);
                for (Object specification : lstSpecifications) {
                    Map<String, Object> specificationObject = (Map<String, Object>) specification;
                    System.debug('serv spec status...'+specificationObject.get('status'));
                }
            }
        }
        Test.stopTest();
    }

}