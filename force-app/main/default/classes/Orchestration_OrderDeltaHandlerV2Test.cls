/**================================================================
* Appirio, Inc
* Name: Orchestration_OrderDeltaHandlerV2Test
* Main Class : Orchestration_OrderDeltaHandlerV2
* Created Date: June 13, 2020
* Created By: Shweta Khandelwal

1.            Pawan         04-Sep-2020      EDGE-164355
2.            Milos Djordjevic        08-06-2021    EDGE-222326 : Modified assert to check for empty list instead of null
==================================================================*/
@isTest(SeeAllData=false)
public class Orchestration_OrderDeltaHandlerV2Test {
    @Testsetup // setup of data
    static void dataSetup() {
        
        //Declare different list to store data
        List<CSPOFA__Orchestration_Process__c> processList = new List<CSPOFA__Orchestration_Process__c>();
        List<CSPOFA__Orchestration_Process_Template__c> processTempList = new List<CSPOFA__Orchestration_Process_Template__c>();
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<account> accountList = new List<account>();
        list<Attachment> attachmentList = new List<Attachment>();
        List<csord__Order_Request__c> orderReqList = new List<csord__Order_Request__c>();
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        list<cscfga__Product_Configuration__c> productconfiglistList = new List<cscfga__Product_Configuration__c>();
        list<csord__Solution__c> solutionList = new List<csord__Solution__c>();
        List<csord__Service__c> servlist = new List<csord__Service__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        List<cscfga__Product_Definition__c> prdList = new List<cscfga__Product_Definition__c>();
        List<Marketable_Offer__c> offerList = new List<Marketable_Offer__c>();
        List<Opportunity> oppList = new List<Opportunity>();
        List<Case> caseList = new List<Case>();
        csordtelcoa__Orders_Subscriptions_Options__c subsSettings = new csordtelcoa__Orders_Subscriptions_Options__c();
        
        //Creating data for process
        offerList = Orchestration_TestUtility.buildMarkertableOffer(false, 3);
        offerList[0].Name = OrchestratorConstants.ProductConfigMarketableOffer.DeviceOutrightPurchase;
        offerList[0].Config__c = '{"noLineItem":true,"skipBasketSyncValidations":true,"isSOWrequired":true}';
        offerList[2].Config__c = '{"markServicesConnected":true,"skipBasketSyncValidations":true,"isSOWrequired":true}';
        offerList[2].Offer_ID__c =System.Label.ManagedService_MarketableOfferId;
        insert offerList;
        subsSettings = Orchestration_TestUtility.buildsubOption();
        governerLimit = Orchestration_TestUtility.buildLimits();
        accountList = Orchestration_TestUtility.buildAccount(true, 1);
        oppList = Orchestration_TestUtility.buildOpp(true, 1, accountList);
        caseList = Orchestration_TestUtility.buildCase(false, 1, oppList, accountList);
        caseList[0].subject = null;
        insert caseList;
        orderReqList = Orchestration_TestUtility.buildOrderRequest(true, 1);
        
        csord__Order__c ord = new csord__Order__c();
        ord.name = 'Primary Order';
        ord.csord__Account__c = accountList[0].id;
        ord.csord__Status2__c = 'Complete';
        ord.csord__Order_Request__c = orderReqList[0].id;
        ord.csord__Identification__c = 'IDE1322';
        ord.stage__c = 'Being Fulfilled';
        ord.isTransientComplete__c = false;
        ord.csord__Start_Date__c = Date.newInstance(2016, 12, 9);
        insert ord;
        
        csord__Order__c ord1 = new csord__Order__c(); // not related to any sub
        ord1.name = 'Primary Order';
        ord1.csord__Account__c = accountList[0].id;
        ord1.csord__Status2__c = 'Complete';
        ord1.csord__Order_Request__c = orderReqList[0].id;
        ord1.csord__Identification__c = 'IDE1322';
        ord1.stage__c = 'Being Fulfilled';
        ord1.isTransientComplete__c = false;
        ord1.csord__Start_Date__c = Date.newInstance(2016, 12, 9);
        insert ord1;
        
        orderList = Orchestration_TestUtility.buildOrder('order', accountList[0].id, 'Complete', orderReqList[0].id, false, 9);
        orderList[0].csord__Primary_Order__c = ord.id;
        orderList[1].csord__Primary_Order__c = ord.id;
        orderList[8].csord__Primary_Order__c = ord.id;
        orderList[8].Name='TestMarkServicesConnected';
        insert orderList;
        processTempList = Orchestration_TestUtility.buildProcessTemplate(true, 1);
        prdList = Orchestration_TestUtility.buildProductDefination(false, 2);
        prdList[0].product_Specification__c = OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000623;
        prdList[1].product_Specification__c='DMCAT_ProductSpecification_001342';
        insert prdList;
        
        cscfga__Product_Configuration__c pcNewMdm = new cscfga__Product_Configuration__c();
        pcNewMdm.name = 'Enterprise Mobility Managed Service ';
        pcNewMdm.Type__c = 'Cancel';
        pcNewMdm.Quantity_Product_Configuration__c = 111;
        pcNewMdm.ConfigurationType1__c = OrchestratorConstants.ProductConfigType.SolutionComponent;
        pcNewMdm.Remaining_Term__c = 0;
        insert pcNewMdm;
        
        productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(false, 4);
        productconfiglistList[1].ConfigurationType1__c = 'Product Component';
        productconfiglistList[0].cscfga__Product_Definition__c = prdList[0].id;
        productconfiglistList[1].cscfga__Product_Definition__c = prdList[0].id;
        productconfiglistList[1].Remaining_Term__c = 0;
        productconfiglistList[0].Remaining_Term__c = 0;
        productconfiglistList[0].Type__c = 'Cancel';
        productconfiglistList[0].cscfga__Root_Configuration__c = pcNewMdm.id;
        productconfiglistList[0].Marketable_Offer__c = offerList[1].id;
        productconfiglistList[2].Marketable_Offer__c = offerList[2].id;
        productconfiglistList[3].cscfga__Product_Definition__c = prdList[1].id;
        insert productconfiglistList;
        
        solutionList = Orchestration_TestUtility.buildSolution(true, 1);
        
        subscriptionList = Orchestration_TestUtility.buildSubscription(false, 10, accountList[0].id, orderList, productconfiglistList[0].id, solutionList[0].id);
        subscriptionList[5].csord__order__c = null;
        subscriptionList[1].csord__order__c = orderList[2].id;
        subscriptionList[2].csord__order__c = orderList[2].id;
        subscriptionList[3].csord__order__c = orderList[3].id;
        subscriptionList[4].csord__order__c = orderList[4].id;
        subscriptionList[7].csord__order__c = orderList[1].id;
        subscriptionList[8].csord__order__c =  orderList[8].id;
        subscriptionList[0].csord__order__c = ord.id;
        subscriptionList[9].csord__order__c = ord.id;
        subscriptionList[0].csord__Status__c = OrchestratorConstants.SubscriptionStatus.Pending;
        subscriptionList[1].csord__Status__c = OrchestratorConstants.SubscriptionStatus.ProvisioningInProgress;
        subscriptionList[2].csord__Status__c = OrchestratorConstants.SubscriptionStatus.DisconnectPending;
        subscriptionList[3].csord__Status__c = OrchestratorConstants.SubscriptionStatus.DisconnectInProgress;
        subscriptionList[4].csord__Status__c = OrchestratorConstants.SubscriptionStatus.DisconnectInProgress;
        subscriptionList[5].csord__Status__c = 'Cancellation In Progress';
        subscriptionList[1].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
        subscriptionList[0].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
        subscriptionList[8].csordtelcoa__Product_Configuration__c = productconfiglistList[2].id;
        subscriptionList[0].MarketableOffer__c = offerList[0].id;
        subscriptionList[1].MarketableOffer__c = offerList[0].id;
        subscriptionList[2].MarketableOffer__c = offerList[0].id;
        subscriptionList[3].MarketableOffer__c = offerList[0].id;
        subscriptionList[4].MarketableOffer__c = offerList[0].id;
        subscriptionList[8].MarketableOffer__c = offerList[2].id;
        subscriptionList[9].csordtelcoa__Product_Configuration__c = productconfiglistList[3].id;
        insert subscriptionList;
        
        servlist = Orchestration_TestUtility.buildService(false, 11, subscriptionList[0].id, orderReqList[0].id, orderList[0].id, productconfiglistList[0].id);
        servlist[1].csord__Subscription__c = subscriptionList[1].id;
        servlist[1].csordtelcoa__Replaced_Service__c = null;
        servlist[2].csord__Subscription__c = subscriptionList[2].id;
        servlist[3].csord__Subscription__c = subscriptionList[0].id;
        servlist[0].csord__Order__c = ord.id;
        servlist[1].csord__Order__c = ord.id;
        servlist[2].csord__Order__c = ord.id;
        servlist[3].csord__Order__c = ord.id;
        servlist[4].csord__Order__c = ord.id;
        servlist[5].csord__Order__c = ord.id;
        servlist[6].csord__Order__c = ord.id;
        servlist[7].csord__Order__c = ord.id;
        servlist[10].csord__Order__c = ord.id;
        servlist[4].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
        servlist[5].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
        servlist[6].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
        servlist[7].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
        servlist[0].Action_Type__c = 'Modify';
        servlist[1].Action_Type__c = OrchestratorConstants.ServiceActionType.None;
        servlist[2].Action_Type__c = OrchestratorConstants.ServiceActionType.PayOut;
        servlist[3].Action_Type__c = OrchestratorConstants.ServiceActionType.PaidOut;
        servlist[4].Action_Type__c = 'Modify';
        servlist[5].Action_Type__c = OrchestratorConstants.ServiceActionType.None;
        servlist[6].Action_Type__c = OrchestratorConstants.ServiceActionType.PayOut;
        servlist[7].Action_Type__c = OrchestratorConstants.ServiceActionType.PaidOut;
        servlist[0].Payment_Type__c = 'Not Rental';
        servlist[4].Payment_Type__c = 'Not Rental';
        servlist[8].csord__Order__c = ord.id;
        servlist[9].csord__Order__c = orderList[8].id;
        servlist[9].csordtelcoa__Product_Configuration__c = productconfiglistList[2].id;
        servlist[9].csord__Subscription__c=subscriptionList[8].id;
        servlist[10].csordtelcoa__Product_Configuration__c =  productconfiglistList[3].id;
        servlist[10].changeType__c='Migration';
        servlist[10].Transition_Id__c='123456789';
        insert servlist;
        
        processList = Orchestration_TestUtility.buildProcess(false, 9, processTempList[0].id, orderList, subscriptionList, accountList[0].id, servlist[0].id);
        processList[4].csordtelcoa__Subscription__c = null;
        processList[0].Order__c = ord.id; // process whose orderId is primary order id of a order
        processList[1].Order__c = ord.id;
        processList[5].Order__c = null;
        processList[6].Order__c = ord1.id; // process whose order doesnot have any subscription
        processList[7].Order__c = orderList[1].id; // process whose order doesnot have any subscription
        processList[8].Order__c = orderList[8].id;
        insert processList;
        
        Service_Add_On__c add1 =  new Service_Add_On__c();
        add1.Instance_Id__c = servlist[10].Transition_Id__c;
        add1.Final_Remaining_Term__c = 2;
        add1.Final_Remaining_Amount__c = 300;
        add1.Monthly_Amount__c = 20;
        add1.Device_Id__c ='1234';
        add1.Status__c = 'Processed';
        add1.isMicaDependency__c=false;
        insert add1;
        orchStepList = Orchestration_TestUtility.buildOrchStep(false, 9, processList);
        
        for (CSPOFA__Orchestration_Step__c step : orchStepList) {
            step.JSON__c = null;
        }
        insert orchStepList;
        
        attachmentList = Orchestration_TestUtility.buildAttachment(false, 8, servlist, productconfiglistList[0].id);
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
        attachmentList[1].body = Blob.valueOf(
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
        attachmentList[2].body = Blob.valueOf(
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
        attachmentList[3].body = Blob.valueOf(
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
        attachmentList[4].body = Blob.valueOf(
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
        attachmentList[5].body = Blob.valueOf(
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
        attachmentList[6].body = Blob.valueOf(
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
        attachmentList[7].body = Blob.valueOf(
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
    
    //Changed Attribute
    static testMethod void ProcessTestNoCOMInAttribute() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c, cspofa__Orchestration_Process__r.Order__c FROM CSPOFA__Orchestration_Step__c WHERE CSPOFA__Orchestration_Process__r.Order__c != null LIMIT 1];
        csord__Service__c service = [SELECT Id, name FROM csord__Service__c WHERE name = 'testService'];
        List<Attachment> attList = [SELECT Id, body FROM Attachment];
        for (Attachment att : attList) {
            att.body = Blob.valueOf(
                '{ "legacyAttributes": [], "serviceId": "a4e2O0000008giRQAQ", "specifications": [ { "attributes": { "parentSpec": "DMCAT_ProductSpecification_000322_Fulfilment", "__targetSystem": "FULFILMENT", "VoicePlan": "Complete Premium", "id": "", "CustomerFacingServiceId": "", "Number": [ { "schemaId": "09a9c459-5f4d-fd2d-3fb3-f875813fb109", "attributes": { "FNN": "0363414185", "rangeTo": null, "status": "ACTIVE", "listCode": "LE" } }, { "schemaId" : "09a9c459-5f4d-fd2d-3fb3-f875813fb109", "attributes" : { "FNN" : "0363414185", "rangeFrom" : null, "rangeTo" : null, "status" : "ACTIVE", "listCode" : "LE" } } ] }, "code": "DMCAT_ProductSpecification_000313_Fulfilment", "description": "UC Numbers_Fulfilment", "endDate": "", "guid": "b5195a82-c601-8c05-1e5a-0ce632a49c2e", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "UC Numbers_Fulfilment", "productConfigurationId": "a3T2O000000S3v3UAC", "specification": "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313", "startDate": "", "status": "In Progress", "version": "1" } ] }'
            );
        }
        update attList;
        List<Attachment> attListReplaced = [SELECT Id, body FROM Attachment WHERE parentID = :service.Id];
        for (Attachment att : attListReplaced) {
            att.body = Blob.valueOf(
                '{"legacyAttributes":[],"serviceId":"a4e2O0000008giRQAQ","specifications":[{"attributes":{"parentSpec":"DMCAT_ProductSpecification_000322_Fulfilment","__targetSystem":"FULFILMENT","VoicePlan":"Complete Premium","id":"","CustomerFacingServiceId":"","Number":[{"schemaId":"09a9c459-5f4d-fd2d-3fb3-f875813fb109","attributes":{"FNN":"0363414188","rangeFrom":null,"status":"ACTIVE","listCode":"Listed"}},{"schemaId":"6d4052b2-cfc9-637f-f6ab-23c552d4b05d","attributes":{"FNN":"0363414194","rangeFrom":null,"rangeTo":null,"status":"ACTIVE","listCode":"Unlisted"}}]},"code":"DMCAT_ProductSpecification_000313_Fulfilment","description":"UC Numbers_Fulfilment","endDate":"","guid":"b5195a82-c601-8c05-1e5a-0ce632a49c2e","includeBilling":false,"instanceId":"","metadata":{},"name":"UC Numbers_Fulfilment","productConfigurationId":"a3T2O000000S3v3UAC","specification":"DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313","startDate":"","status":"In Progress","version":"1"}]}'
            );
        }
        update attListReplaced;
        Orchestration_OrderDeltaHandlerV2 orderDeltaHandler = new Orchestration_OrderDeltaHandlerV2();
        SYS_TriggerHandler.bypass('C2O_SubscriptionTriggerHandler');
        orchStepList = orderDeltaHandler.process(orchStepList);
        System.assert(orchStepList.size() > 0);
        Test.stopTest();
    }
    //Added Attribute
    static testMethod void ProcessTestNoCOMInAttribute2() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c, cspofa__Orchestration_Process__r.Order__c FROM CSPOFA__Orchestration_Step__c WHERE CSPOFA__Orchestration_Process__r.Order__c != null LIMIT 1];
        csord__Service__c service = [SELECT Id, name FROM csord__Service__c WHERE name = 'testService'];
        List<Attachment> attList = [SELECT Id, body FROM Attachment];
        for (Attachment att : attList) {
            att.body = Blob.valueOf(
                '{"legacyAttributes":[],"serviceId":"a4e2O0000008giRQAQ","specifications":[{"attributes":{"parentSpec":"DMCAT_ProductSpecification_000322_Fulfilment","__targetSystem":"FULFILMENT","VoicePlan":"Complete Premium","id":"","CustomerFacingServiceId":"","Number":[{"schemaId":"09a9c459-5f4d-fd2d-3fb3-f875813fb109","attributes":{"FNN":"0363414185","rangeFrom":null,"rangeTo":null,"status":"ACTIVE","listCode":"LE"}},{ "schemaId" : "6d4052b2-cfc9-637f-f6ab-23c552d4b05d", "attributes" : { "FNN" : "0363414194", "rangeFrom" : null, "rangeTo" : null, "status" : "ACTIVE", "listCode" : "Unlisted" } }]},"code":"DMCAT_ProductSpecification_000313_Fulfilment","description":"UC Numbers_Fulfilment","endDate":"","guid":"b5195a82-c601-8c05-1e5a-0ce632a49c2e","includeBilling":false,"instanceId":"","metadata":{},"name":"UC Numbers_Fulfilment","productConfigurationId":"a3T2O000000S3v3UAC","specification":"DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313","startDate":"","status":"In Progress","version":"1"}]}'
            );
        }
        update attList;
        List<Attachment> attListReplaced = [SELECT Id, body FROM Attachment WHERE parentID = :service.Id];
        for (Attachment att : attListReplaced) {
            att.body = Blob.valueOf(
                '{"legacyAttributes":[],"serviceId":"a4e2O0000008giRQAQ","specifications":[{"attributes":{"parentSpec":"DMCAT_ProductSpecification_000322_Fulfilment","__targetSystem":"FULFILMENT","VoicePlan":"Complete Premium","id":"","CustomerFacingServiceId":"","Number":[{"schemaId":"09a9c459-5f4d-fd2d-3fb3-f875813fb109","attributes":{"FNN":"0363414132","rangeFrom":null,"rangeTo":null,"status":"ACTIVE","listCode":"Listed"}}]},"code":"DMCAT_ProductSpecification_000313_Fulfilment","description":"UC Numbers_Fulfilment","endDate":"","guid":"b5195a82-c601-8c05-1e5a-0ce632a49c2e","includeBilling":false,"instanceId":"","metadata":{},"name":"UC Numbers_Fulfilment","productConfigurationId":"a3T2O000000S3v3UAC","specification":"DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313","startDate":"","status":"In Progress","version":"1"}]}'
            );
        }
        update attListReplaced;
        Orchestration_OrderDeltaHandlerV2 orderDeltaHandler = new Orchestration_OrderDeltaHandlerV2();
        orchStepList = orderDeltaHandler.process(orchStepList);
        System.assert(orchStepList.size() > 0);
        Test.stopTest();
    }
    
    //Added changedAdditionalAttributes
    static testMethod void ProcessTestInAddAttribute() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c, cspofa__Orchestration_Process__r.Order__c FROM CSPOFA__Orchestration_Step__c WHERE CSPOFA__Orchestration_Process__r.Order__c != null LIMIT 1];
        csord__Service__c service = [SELECT Id, name FROM csord__Service__c WHERE name = 'testService'];
        List<Attachment> attList = [SELECT Id, body FROM Attachment];
        for (Attachment att : attList) {
            att.body = Blob.valueOf(
                '{ "legacyAttributes":[ ], "serviceId":"' +
                service.Id +
                '", "specifications":[ { "additionalAttributes":{ "parentSpecss" : "203b58ad-133e-df84-36b3-5b452f1e2bhu" }, "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
                OrchestratorConstants.TargetSystem.BILLING +
                '" }, "code":"DMCAT_ProductSpecification_000263_Fulfilment", "name":"Mobile Access_Fulfilment", "productConfigurationId":"a3T2O000000GuQXUA0", "specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate":"", "status":"' +
                OrchestratorConstants.ServiceStatus.Created +
                '", "version":"1" }, { "additionalAttributes":{ }, "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
                OrchestratorConstants.TargetSystem.ASSURANCE +
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
        }
        update attList;
        List<csord__Subscription__c> subscriptionList = [SELECT id, MarketableOffer__c FROM csord__Subscription__c];
        for (csord__Subscription__c obj : subscriptionList) {
            obj.MarketableOffer__c = null;
        }
        SYS_TriggerHandler.bypass('C2O_SubscriptionTriggerHandler');//DIGI-18237
        update subscriptionList;
        List<Attachment> attListReplaced = [SELECT Id, body FROM Attachment WHERE parentID = :service.Id];
        for (Attachment att : attListReplaced) {
            att.body = Blob.valueOf(
                '{ "legacyAttributes":[ ], "serviceId":"' +
                service.Id +
                '", "specifications":[ { "additionalAttributes":{ "parentSpec" : "203b58ad-133e-df84-36b3-5b452f1e25c6" }, "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
                OrchestratorConstants.TargetSystem.BILLING +
                '" }, "code":"DMCAT_ProductSpecification_000263_Fulfilment", "name":"Mobile Access_Fulfilment", "productConfigurationId":"a3T2O000000GuQXUA0", "specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate":"", "status":"' +
                OrchestratorConstants.ServiceStatus.Created +
                '", "version":"1" }, { "additionalAttributes":{ }, "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
                OrchestratorConstants.TargetSystem.ASSURANCE +
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
        }
        update attListReplaced;
        Orchestration_OrderDeltaHandlerV2 orderDeltaHandler = new Orchestration_OrderDeltaHandlerV2();
        orchStepList = orderDeltaHandler.process(orchStepList);
        System.assert(orchStepList.size() > 0);
        Test.stopTest();
    }
    
    // requirementType = OrchestratorConstants.ProductRequirementType.BothRequired
    static testMethod void ProcessTest() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c, cspofa__Orchestration_Process__r.Order__c FROM CSPOFA__Orchestration_Step__c LIMIT 1];
        csord__Service__c service = [SELECT Id, name FROM csord__Service__c WHERE name = 'testService'];
        List<Attachment> attList = [SELECT Id, body FROM Attachment WHERE parentID = :service.Id];
        attList[0].body = Blob.valueOf(
            '{ "legacyAttributes":[ ], "serviceId":"' +
            service.Id +
            '", "specifications":[ { "additionalAttributes":{ }, "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
            OrchestratorConstants.TargetSystem.BILLING +
            '" }, "code":"DMCAT_ProductSpecification_000263_Fulfilment", "name":"Mobile Access_Fulfilment", "productConfigurationId":"a3T2O000000GuQXUA0", "specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate":"", "status":"' +
            OrchestratorConstants.ServiceStatus.Created +
            '", "version":"1" }, { "additionalAttributes":{ }, "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
            OrchestratorConstants.TargetSystem.ASSURANCE +
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
        update attList;
        Orchestration_OrderDeltaHandlerV2 orderDeltaHandler = new Orchestration_OrderDeltaHandlerV2();
        orchStepList = orderDeltaHandler.process(orchStepList);
        System.assert(orchStepList != null);
        Test.stopTest();
    }
    
    // replaced service is null
    static testMethod void ProcessTestRepServNull() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c, cspofa__Orchestration_Process__r.Order__c FROM CSPOFA__Orchestration_Step__c LIMIT 1];
        csord__Subscription__c sub = [SELECT Id FROM csord__Subscription__c WHERE csord__Order__c = :orchStepList[0].cspofa__Orchestration_Process__r.Order__c LIMIT 1];
        
        csord__Service__c service = [SELECT Id, name, csordtelcoa__Replaced_Service__c FROM csord__Service__c WHERE csord__Subscription__c != null LIMIT 1];
        update service;
        
        List<Attachment> attList = [SELECT Id, body FROM Attachment WHERE parentID = :service.Id];
        attList[0].body = Blob.valueOf(
            '{ "legacyAttributes":[ ], "serviceId":"' +
            service.Id +
            '", "specifications":[ { "additionalAttributes":{ }, "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
            OrchestratorConstants.TargetSystem.BILLING +
            '" }, "code":"DMCAT_ProductSpecification_000263_Fulfilment", "name":"Mobile Access_Fulfilment", "productConfigurationId":"a3T2O000000GuQXUA0", "specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate":"", "status":"' +
            OrchestratorConstants.ServiceStatus.Created +
            '", "version":"1" }, { "additionalAttributes":{ }, "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
            OrchestratorConstants.TargetSystem.ASSURANCE +
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
        update attList;
        Orchestration_OrderDeltaHandlerV2 orderDeltaHandler = new Orchestration_OrderDeltaHandlerV2();
        orchStepList = orderDeltaHandler.process(orchStepList);
        List<csord__Service__c> serviceList = [SELECT Id, name, Action_Type__c, toBeCancelled__c, csord__Status__c FROM csord__Service__c WHERE csord__Status__c = :OrchestratorConstants.ServiceStatus.DisconnectPending];
        System.debug('service name in test' + serviceList[0].name);
        System.assert(serviceList.size() > 0);
        
        Test.stopTest();
    }
    
    // requirementType = OrchestratorConstants.ProductRequirementType.BothRequired
    static testMethod void ProcessTestWithAllData() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c, cspofa__Orchestration_Process__r.Order__c FROM CSPOFA__Orchestration_Step__c];
        csord__Service__c service = [SELECT Id, name FROM csord__Service__c WHERE name = 'testService'];
        List<Attachment> attList = [SELECT Id, body FROM Attachment WHERE parentID = :service.Id];
        attList[0].body = Blob.valueOf(
            '{ "legacyAttributes":[ ], "serviceId":"' +
            service.Id +
            '", "specifications":[ { "additionalAttributes":{ }, "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
            OrchestratorConstants.TargetSystem.BILLING +
            '" }, "code":"DMCAT_ProductSpecification_000263_Fulfilment", "name":"Mobile Access_Fulfilment", "productConfigurationId":"a3T2O000000GuQXUA0", "specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate":"", "status":"' +
            OrchestratorConstants.ServiceStatus.Created +
            '", "version":"1" }, { "additionalAttributes":{ }, "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
            OrchestratorConstants.TargetSystem.ASSURANCE +
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
        update attList;
        Orchestration_OrderDeltaHandlerV2 orderDeltaHandler = new Orchestration_OrderDeltaHandlerV2();
        orchStepList = orderDeltaHandler.process(orchStepList);
        List<csord__Service__c> serviceList = [SELECT Id, name, Action_Type__c, toBeCancelled__c, csord__Status__c FROM csord__Service__c WHERE toBeCancelled__c = 'true'];
        System.assert(orchStepList.size() > 0);
        Test.stopTest();
    }
    
    // Service and replaced service has same attachment
    // requirementType = OrchestratorConstants.ProductRequirementType.BothRequired
    static testMethod void ProcessTestWithSameAttachment() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        List<Sobject> updateSojects = new List<Sobject>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
        List<csord__Service__c> serviceList = [SELECT Id, name, Action_Type__c FROM csord__Service__c WHERE Action_Type__c = :OrchestratorConstants.ServiceActionType.PaidOut OR Action_Type__c = :OrchestratorConstants.ServiceActionType.PayOut];
        serviceList[0].Action_Type__c = OrchestratorConstants.ServiceActionType.NONE;
        serviceList[1].Action_Type__c = 'Modify';
        updateSojects.addAll(serviceList);
        csord__Service__c service = [SELECT Id, name FROM csord__Service__c WHERE name = 'testService'];
        List<Attachment> attList = [SELECT Id, body FROM Attachment WHERE parentID = :service.Id];
        attList[0].body = Blob.valueOf(
            '{ "legacyAttributes":[ ], "specifications":[ { "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000019_Fulfilment", "__targetSystem":"' +
            OrchestratorConstants.TargetSystem.FULFILMENT +
            '" }, "code":"DMCAT_ProductSpecification_000263_Fulfilment", "name":"Mobile Access_Fulfilment", "status":"' +
            Label.Complete +
            '", "version":"1", "guid":"G001" }, { "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000019_Fulfilment", "__targetSystem":"' +
            OrchestratorConstants.TargetSystem.BILLING +
            '" }, "code":"DMCAT_ProductSpecification_000263_Fulfilment", "guid":"G002", "name":"Mobile Access_Fulfilment1", "version":"1", "status":"' +
            Label.Complete +
            '" } ] }'
        );
        updateSojects.addAll(attList);
        
        List<Attachment> attListNew = [SELECT Id, body FROM Attachment WHERE parentID != :service.Id];
        System.debug('attlist size ' + attListNew.size());
        for (Attachment attach : attListNew) {
            attach.body = Blob.ValueOf(
                '{ "legacyAttributes":[ ],  "specifications":[ { "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
                OrchestratorConstants.TargetSystem.FULFILMENT +
                '" }, "code":"DMCAT_ProductSpecification_000263_Fulfilment", "name":"Mobile Access_Fulfilment", "status":"' +
                Label.Complete +
                '", "version":"1", "guid":"G001" }, { "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
                OrchestratorConstants.TargetSystem.BILLING +
                '" }, "code":"DMCAT_ProductSpecification_000263_Fulfilment", "guid":"G002", "name":"Mobile Access_Fulfilment1", "version":"1", "status":"' +
                Label.Complete +
                '" } ] }'
            );
        }
        updateSojects.addAll(attListNew);
        
        Test.startTest();
        Orchestration_OrderDeltaHandlerV2 orderDeltaHandler = new Orchestration_OrderDeltaHandlerV2();
        orchStepList = orderDeltaHandler.process(orchStepList);
        List<csord__Service__c> serviceListNew = [SELECT Id, name, Action_Type__c, toBeCancelled__c, csord__Status__c FROM csord__Service__c WHERE toBeCancelled__c = 'true'];
        System.assert(orchStepList.size() > 0);
        Test.stopTest();
    }
    
    //requirementType = OrchestratorConstants.ProductRequirementType.NotRequired
    static testMethod void ProcessTestWith3() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        //csord__Subscription__c sub = new csord__Subscription__c();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
        List<cscfga__Product_Configuration__c> productConfigs = [SELECT Id, type__c FROM cscfga__Product_Configuration__c];
        for (cscfga__Product_Configuration__c prd : productConfigs) {
            prd.type__c = 'modify';
        }
        update productConfigs;
        List<Attachment> attList = [SELECT Id, body FROM Attachment];
        System.debug('attlist size ' + attList.size());
        for (Attachment attach : attList) {
            attach.body = Blob.ValueOf(
                '{ "legacyAttributes":[ ], "specifications":[ { "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
                OrchestratorConstants.TargetSystem.FULFILMENT +
                '" }, "code":"DMCAT_ProductSpecification_000263_Fulfilment", "name":"Mobile Access_Fulfilment", "status":"' +
                OrchestratorConstants.ServiceStatus.Disconnected +
                '", "version":"1", "guid":"G001" }, { "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
                OrchestratorConstants.TargetSystem.BILLING +
                '" }, "code":"DMCAT_ProductSpecification_000263_Fulfilment", "guid":"G002", "name":"Mobile Access_Fulfilment1", "version":"1", "status":"' +
                OrchestratorConstants.ServiceStatus.Disconnected +
                '" } ] }'
            );
        }
        update attList;
        
        Test.startTest();
        Orchestration_OrderDeltaHandlerV2 orderDeltaHandler = new Orchestration_OrderDeltaHandlerV2();
        orchStepList = orderDeltaHandler.process(orchStepList);
        
        List<csord__Service__c> serviceListNew = [SELECT Id, name, Action_Type__c, toBeCancelled__c, csord__Status__c FROM csord__Service__c WHERE csord__Status__c = :OrchestratorConstants.ServiceStatus.Connected];
        
        System.assert(serviceListNew.size() > 0);
        
        Test.stopTest();
    }
    
    //requirementType = OrchestratorConstants.ProductRequirementType.OnlyBillingRequired
    static testMethod void ProcessTestWith4() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
        
        cscfga__Product_Configuration__c prdCOnfig = [SELECT ID FROM cscfga__Product_Configuration__c WHERE ConfigurationType1__c = 'Product Component'];
        
        List<csord__Service__c> serviceList = [SELECT Id, name, csordtelcoa__Product_Configuration__c FROM csord__Service__c WHERE csordtelcoa__Product_Configuration__r.ConfigurationType1__c != 'Product Component'];
        for (csord__Service__c ser : serviceList) {
            ser.csordtelcoa__Product_Configuration__c = prdCOnfig.Id;
        }
        update serviceList;
        
        List<Attachment> attList = [SELECT Id, body FROM Attachment];
        for (Attachment attach : attList) {
            attach.body = Blob.ValueOf(
                '{ "legacyAttributes":[ ], "specifications":[ { "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
                OrchestratorConstants.TargetSystem.FULFILMENT +
                '" }, "code":"DMCAT_ProductSpecification_000263_Fulfilment", "name":"Mobile Access_Fulfilment", "status":"' +
                Label.Complete +
                '", "version":"1", "guid":"G001" }, { "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
                OrchestratorConstants.TargetSystem.BILLING +
                '" }, "code":"DMCAT_ProductSpecification_000263_Fulfilment", "guid":"G002", "name":"Mobile Access_Fulfilment1", "version":"1", "status":"' +
                OrchestratorConstants.ServiceStatus.Disconnected +
                '" },{ "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
                OrchestratorConstants.TargetSystem.BILLING +
                '" }, "code":"DMCAT_ProductSpecification_000263_Fulfilment", "guid":"G002", "name":"Mobile Access_Fulfilment1", "version":"1", "status":"Connected With Wire" } ] } '
            );
        }
        update attList;
        Test.startTest();
        Orchestration_OrderDeltaHandlerV2 orderDeltaHandler = new Orchestration_OrderDeltaHandlerV2();
        orchStepList = orderDeltaHandler.process(orchStepList);
        System.assert(orchStepList.size() > 0);
        Test.stopTest();
    }
    //requirementType = OrchestratorConstants.ProductRequirementType.OnlyFulfilmentRequired
    static testMethod void ProcessTestWith5() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        //csord__Subscription__c sub = new csord__Subscription__c();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
        cscfga__Product_Configuration__c prdCOnfig = [SELECT ID FROM cscfga__Product_Configuration__c WHERE ConfigurationType1__c = 'Product Component'];
        List<csord__Service__c> serviceList = [SELECT Id, name, csordtelcoa__Product_Configuration__c FROM csord__Service__c WHERE csordtelcoa__Product_Configuration__r.ConfigurationType1__c != 'Product Component'];
        for (csord__Service__c ser : serviceList) {
            ser.csordtelcoa__Product_Configuration__c = prdCOnfig.Id;
        }
        update serviceList;
        List<Attachment> attList = [SELECT Id, body FROM Attachment];
        
        for (Attachment attach : attList) {
            attach.body = Blob.ValueOf(
                '{ "legacyAttributes":[ ], "specifications":[ { "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
                OrchestratorConstants.TargetSystem.FULFILMENT +
                '" }, "code":"DMCAT_ProductSpecification_000263_Fulfilment", "name":"Mobile Access_Fulfilment", "status":"' +
                Label.Complete +
                '", "version":"1", "guid":"G001" }, { "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
                OrchestratorConstants.TargetSystem.BILLING +
                '" }, "code":"DMCAT_ProductSpecification_000263_Fulfilment", "guid":"G002", "name":"Mobile Access_Fulfilment1", "version":"1", "status":"' +
                OrchestratorConstants.ServiceStatus.Disconnected +
                '" },{ "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
                OrchestratorConstants.TargetSystem.FULFILMENT +
                '" }, "code":"DMCAT_ProductSpecification_000263_Fulfilment", "guid":"G002", "name":"Mobile Access_Fulfilment1", "version":"1", "status":"Connected With Wire" } ] } '
            );
        }
        update attList;
        Test.startTest();
        Orchestration_OrderDeltaHandlerV2 orderDeltaHandler = new Orchestration_OrderDeltaHandlerV2();
        orchStepList = orderDeltaHandler.process(orchStepList);
        System.assert(orchStepList.size() > 0);
        Test.stopTest();
    }
    
    // Limits got hit
    static testMethod void breakingLimits() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
        governerLimit.SOQL_limit__c = '1';
        update governerLimit;
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c LIMIT 1];
        
        Orchestration_OrderDeltaHandlerV2 orderDeltaHandler = new Orchestration_OrderDeltaHandlerV2();
        orchStepList = orderDeltaHandler.process(orchStepList);
        boolean isNull = orchStepList == null ? true : false;
        //Assert to check step
        System.assertEquals(false, isNull);
        
        Test.stopTest();
    }
    //Breaking SoqlLimit
    static testMethod void breakingLimitsSQL4() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
        governerLimit.SOQL_limit__c = '4';
        update governerLimit;
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c LIMIT 1];
        
        Orchestration_OrderDeltaHandlerV2 orderDeltaHandler = new Orchestration_OrderDeltaHandlerV2();
        orchStepList = orderDeltaHandler.process(orchStepList);
        boolean isNull = orchStepList == null ? true : false;
        System.assertEquals(false, isNull);
        Test.stopTest();
    }
    //Breaking SoqlLimit
    static testMethod void breakingLimitsSQL5() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
        governerLimit.SOQL_limit__c = '5';
        update governerLimit;
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c LIMIT 1];
        
        Orchestration_OrderDeltaHandlerV2 orderDeltaHandler = new Orchestration_OrderDeltaHandlerV2();
        orchStepList = orderDeltaHandler.process(orchStepList);
        System.assert(orchStepList != null);
        Test.stopTest();
    }
    //Breaking SoqlLimit
    static testMethod void breakingLimitsSQL6() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
        governerLimit.SOQL_limit__c = '6';
        update governerLimit;
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c LIMIT 1];
        
        Orchestration_OrderDeltaHandlerV2 orderDeltaHandler = new Orchestration_OrderDeltaHandlerV2();
        orchStepList = orderDeltaHandler.process(orchStepList);
        System.assert(orchStepList.size() > 0);
        Test.stopTest();
    }
    //Breaking SoqlLimit
    static testMethod void breakingLimitsSQL3() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
        governerLimit.SOQL_limit__c = '3';
        update governerLimit;
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c LIMIT 1];
        
        Orchestration_OrderDeltaHandlerV2 orderDeltaHandler = new Orchestration_OrderDeltaHandlerV2();
        orchStepList = orderDeltaHandler.process(orchStepList);
        boolean isNull = orchStepList == null ? true : false;
        //No step found check
        System.assertEquals(false, isNull);
        Test.stopTest();
    }
    //Breaking DML limit
    static testMethod void breakingLimitsInStart() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
        governerLimit.SOQL_limit__c = '0';
        update governerLimit;
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
        Orchestration_OrderDeltaHandlerV2 orderDeltaHandler = new Orchestration_OrderDeltaHandlerV2();
        orchStepList = orderDeltaHandler.process(orchStepList);
        //No step found check
        System.assertEquals(orchStepList == null, false);
        Test.stopTest();
    }
    
    // Limits got hit
    static testMethod void breakingLimitsDML1() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '1';
        update governerLimit;
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c FROM CSPOFA__Orchestration_Step__c WHERE CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c != null LIMIT 1];
        
        Orchestration_OrderDeltaHandlerV2 orderDeltaHandler = new Orchestration_OrderDeltaHandlerV2();
        orchStepList = orderDeltaHandler.process(orchStepList);
        List<csord__Service__c> serviceList = [SELECT Id, name, toBeCancelled__c, csord__Status__c FROM csord__Service__c WHERE toBeCancelled__c = 'true'];
        
        System.assert(orchStepList.size() > 0);
        Test.stopTest();
    }
    //Breaking DML limit
    static testMethod void breakingLimitDML4() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '4';
        update governerLimit;
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c, cspofa__Orchestration_Process__r.Order__c FROM CSPOFA__Orchestration_Step__c];
        csord__Service__c service = [SELECT Id, name FROM csord__Service__c WHERE name = 'testService'];
        List<Attachment> attList = [SELECT Id, body FROM Attachment WHERE parentID = :service.Id];
        attList[0].body = Blob.valueOf(
            '{ "legacyAttributes":[ ], "serviceId":"' +
            service.Id +
            '", "specifications":[ { "additionalAttributes":{ }, "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
            OrchestratorConstants.TargetSystem.BILLING +
            '" }, "code":"DMCAT_ProductSpecification_000263_Fulfilment", "name":"Mobile Access_Fulfilment", "productConfigurationId":"a3T2O000000GuQXUA0", "specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate":"", "status":"' +
            OrchestratorConstants.ServiceStatus.Created +
            '", "version":"1" }, { "additionalAttributes":{ }, "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
            OrchestratorConstants.TargetSystem.ASSURANCE +
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
        update attList;
        Orchestration_OrderDeltaHandlerV2 orderDeltaHandler = new Orchestration_OrderDeltaHandlerV2();
        orchStepList = orderDeltaHandler.process(orchStepList);
        List<csord__Service__c> serviceList = [SELECT Id, name, Action_Type__c, toBeCancelled__c, csord__Status__c FROM csord__Service__c WHERE csord__Status__c = 'In progress'];
        System.assert(serviceList.size() > 0);
        Test.stopTest();
    }
    //Breaking DML limit
    static testMethod void breakingLimitDML6() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        
        Test.startTest();
        governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '6';
        update governerLimit;
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c, cspofa__Orchestration_Process__r.Order__c FROM CSPOFA__Orchestration_Step__c];
        csord__Service__c service = [SELECT Id, name FROM csord__Service__c WHERE name = 'testService'];
        List<Attachment> attList = [SELECT Id, body FROM Attachment WHERE parentID = :service.Id];
        attList[0].body = Blob.valueOf(
            '{ "legacyAttributes":[ ], "serviceId":"' +
            service.Id +
            '", "specifications":[ { "additionalAttributes":{ }, "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
            OrchestratorConstants.TargetSystem.BILLING +
            '" }, "code":"DMCAT_ProductSpecification_000263_Fulfilment", "name":"Mobile Access_Fulfilment", "productConfigurationId":"a3T2O000000GuQXUA0", "specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate":"", "status":"' +
            OrchestratorConstants.ServiceStatus.Created +
            '", "version":"1" }, { "additionalAttributes":{ }, "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
            OrchestratorConstants.TargetSystem.ASSURANCE +
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
        update attList;
        Orchestration_OrderDeltaHandlerV2 orderDeltaHandler = new Orchestration_OrderDeltaHandlerV2();
        orchStepList = orderDeltaHandler.process(orchStepList);
        List<csord__Service__c> serviceList = [SELECT Id, name, Action_Type__c, toBeCancelled__c, csord__Status__c FROM csord__Service__c WHERE csord__Status__c = 'In progress'];
        System.assert(serviceList.size() > 0);
        Test.stopTest();
    }
    //Breaking DML limit
    static testMethod void breakingLimitDML7() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        
        Test.startTest();
        governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '7';
        update governerLimit;
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c, cspofa__Orchestration_Process__r.Order__c FROM CSPOFA__Orchestration_Step__c];
        csord__Service__c service = [SELECT Id, name FROM csord__Service__c WHERE name = 'testService'];
        List<Attachment> attList = [SELECT Id, body FROM Attachment WHERE parentID = :service.Id];
        attList[0].body = Blob.valueOf(
            '{ "legacyAttributes":[ ], "serviceId":"' +
            service.Id +
            '", "specifications":[ { "additionalAttributes":{ }, "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
            OrchestratorConstants.TargetSystem.BILLING +
            '" }, "code":"DMCAT_ProductSpecification_000263_Fulfilment", "name":"Mobile Access_Fulfilment", "productConfigurationId":"a3T2O000000GuQXUA0", "specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate":"", "status":"' +
            OrchestratorConstants.ServiceStatus.Created +
            '", "version":"1" }, { "additionalAttributes":{ }, "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
            OrchestratorConstants.TargetSystem.ASSURANCE +
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
        update attList;
        Orchestration_OrderDeltaHandlerV2 orderDeltaHandler = new Orchestration_OrderDeltaHandlerV2();
        orchStepList = orderDeltaHandler.process(orchStepList);
        List<csord__Service__c> serviceList = [SELECT Id, name, Action_Type__c, toBeCancelled__c, csord__Status__c FROM csord__Service__c WHERE csord__Status__c = 'In progress'];
        System.assert(serviceList.size() > 0);
        Test.stopTest();
    }
    
    // Breaking DML limit
    static testMethod void breakingLimitDML18() {
        Test.startTest();
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, SOQL_limit__c FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '18';
        update governerLimit;
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c, cspofa__Orchestration_Process__r.Order__c FROM CSPOFA__Orchestration_Step__c];
        csord__Service__c service = [SELECT Id, name FROM csord__Service__c WHERE name = 'testService'];
        List<Attachment> attList = [SELECT Id, body FROM Attachment WHERE parentID = :service.Id];
        attList[0].body = Blob.valueOf(
            '{ "legacyAttributes":[ ], "serviceId":"' +
            service.Id +
            '", "specifications":[ { "additionalAttributes":{ }, "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
            OrchestratorConstants.TargetSystem.BILLING +
            '" }, "code":"DMCAT_ProductSpecification_000263_Fulfilment", "name":"Mobile Access_Fulfilment", "productConfigurationId":"a3T2O000000GuQXUA0", "specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate":"", "status":"' +
            OrchestratorConstants.ServiceStatus.Created +
            '", "version":"1" }, { "additionalAttributes":{ }, "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
            OrchestratorConstants.TargetSystem.ASSURANCE +
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
            OrchestratorConstants.ServiceActionType.None +
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
            OrchestratorConstants.ServiceActionType.None +
            '", "version":"1" }, { "additionalAttributes":{ }, "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
            OrchestratorConstants.TargetSystem.FULFILMENT +
            '", "SERVICEPROFILE":"DATA_BACKUP", "MESSAGEBANK":"NA", "INTROAM":"NA", "CONTEXT":"NA", "CALLCONTROL":"NA", "AccessRole":"Primary", "BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID":"61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate":"", "ShippingRequired":"TRUE", "IMSI":"", "SIMSerialNumber":"" }, "code":"' +
            OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000423 +
            '", "description":"", "endDate":"", "guid":"G003", "includeBilling":false, "instanceId":"", "metadata":{ }, "name":"Mobile Access_Fulfilment6", "productConfigurationId":"a3T2O000000GuQXUA0", "specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate":"", "status":"' +
            OrchestratorConstants.ServiceActionType.None +
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
        update attList;
        
        Orchestration_OrderDeltaHandlerV2 orderDeltaHandler = new Orchestration_OrderDeltaHandlerV2();
        orchStepList = orderDeltaHandler.process(orchStepList);
        List<csord__Service__c> serviceList = [SELECT Id, name, Action_Type__c, toBeCancelled__c, csord__Status__c FROM csord__Service__c WHERE toBeCancelled__c = 'true'];
        //Assert to check service status
        System.assertEquals(serviceList[0].csord__Status__c, 'Disconnect Pending');
        Test.stopTest();
    }
    
    // To cover inner catch : Provinding Invalid JSON (covering error condition)
    static testMethod void breakingLimitsInnerCatch() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        //Query from datasetup
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c FROM CSPOFA__Orchestration_Step__c WHERE CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c != null LIMIT 1];
        
        Orchestration_OrderDeltaHandlerV2 orderDeltaHandler = new Orchestration_OrderDeltaHandlerV2();
        orchStepList = orderDeltaHandler.process(orchStepList);
        
        Set<String> attachIds = new Set<String>();
        
        for (Attachment attachment : [SELECT Id FROM Attachment]) {
            attachIds.add(attachment.Id);
        }
        
        Orchestration_ProcessedRecords perStepSuccessIds = new Orchestration_ProcessedRecords();
        
        //Initializing the attachmentIds Set
        perStepSuccessIds.attachmentIds = attachIds;
        
        orchStepList[0].JSON__C = JSON.serialize(perStepSuccessIds);
        update orchStepList;
        
        orderDeltaHandler = new Orchestration_OrderDeltaHandlerV2();
        orchStepList = orderDeltaHandler.process(orchStepList);
        //Assert to check orchStepList
        System.assert(orchStepList.size() > 0);
        Test.stopTest();
    }
    
    //EDGE-164355
    static testMethod void ProcessTestParentSvcPaidOut() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c, cspofa__Orchestration_Process__r.Order__c FROM CSPOFA__Orchestration_Step__c LIMIT 1];
        csord__Subscription__c sub = [SELECT Id FROM csord__Subscription__c WHERE csord__Order__c = :orchStepList[0].cspofa__Orchestration_Process__r.Order__c LIMIT 1];
        
        csord__Service__c service = [SELECT Id, name, csord__Service__c, Action_Type__c, csordtelcoa__Replaced_Service__c FROM csord__Service__c WHERE csord__Subscription__c = :sub.id LIMIT 1];
        
        service.csord__Service__c = null;
        service.Action_Type__c = 'PaidOut';
        update service;
        
        List<Attachment> attList = [SELECT Id, body FROM Attachment WHERE parentID = :service.Id];
        attList[0].body = Blob.valueOf(
            '{ "legacyAttributes":[ ], "serviceId":"' +
            service.Id +
            '", "specifications":[ { "additionalAttributes":{ }, "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
            OrchestratorConstants.TargetSystem.BILLING +
            '" }, "code":"DMCAT_ProductSpecification_000263_Fulfilment", "name":"Mobile Access_Fulfilment", "productConfigurationId":"a3T2O000000GuQXUA0", "specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate":"", "status":"' +
            OrchestratorConstants.ServiceStatus.Created +
            '", "version":"1" }, { "additionalAttributes":{ }, "attributes":{ "IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem":"' +
            OrchestratorConstants.TargetSystem.ASSURANCE +
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
        update attList;
        Orchestration_OrderDeltaHandlerV2 orderDeltaHandler = new Orchestration_OrderDeltaHandlerV2();
        orchStepList = orderDeltaHandler.process(orchStepList);
        
        csord__Subscription__c subExpected = [SELECT Id, csord__Status__c FROM csord__Subscription__c WHERE id = :sub.id LIMIT 1];
        
        csord__Service__c serviceExpected = [SELECT Id, name, csord__Status__c, csord__Service__c, Action_Type__c, csordtelcoa__Replaced_Service__c FROM csord__Service__c WHERE csord__Subscription__c = :sub.id LIMIT 1];
        
        System.assertEquals(serviceExpected.csord__Status__c, 'Paid Out');
        //System.assertEquals(subExpected.csord__Status__c, 'Paid Out');
        //System.assertEquals(subExpected.csord__Status__c, 'Paid Out');
        //  System.assertEquals(subExpected.csord__Status__c, 'Pending');
        
        Test.stopTest();
    }
    // Where opp is not associated with order
    static testMethod void ProcessTestOrderNull() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<Id> subscriptionIds = new List<Id>();
        // Query form datasetup
        List<CSPOFA__Orchestration_Process__c> oppProcessList = [SELECT id FROM CSPOFA__Orchestration_Process__c];
        Integer i = 0;
        for (CSPOFA__Orchestration_Process__c oppProcess : oppProcessList) {
            oppProcess.Order__c = null;
            i++;
            if (i == 1)
                break;
        }
        update oppProcessList; // updation for further process
        System.debug('ordList ' + oppProcessList);
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
        
        Test.startTest();
        Orchestration_OrderDeltaHandlerV2 deltaHandler = new Orchestration_OrderDeltaHandlerV2();
        orchStepList = deltaHandler.process(orchStepList);
        // Assert to check message status
        System.assertEquals(orchStepList[0].CSPOFA__Message__c, 'Error: Step do not have an order or subscriptions');
        
        Test.stopTest();
    }
    // Where opp is not associated with order
    static testMethod void ProcessTestwithAlreadySkipped() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<Id> subscriptionIds = new List<Id>();
        // Query form datasetup
        
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Order__r.csordtelcoa__Opportunity__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c LIMIT 1];
        
        List<csord__Service__c> serviceList = [SELECT ID FROM csord__Service__c WHERE csord__Order__r.csordtelcoa__Opportunity__c = :orchStepList[0].CSPOFA__Orchestration_Process__r.Order__r.csordtelcoa__Opportunity__c];
        List<Attachment> attList = [SELECT Id FROM Attachment WHERE ParentId IN :serviceList];
        System.debug('Attachment List' + attList);
        Orchestration_ProcessedRecords processRecords = new Orchestration_ProcessedRecords();
        processRecords.skipRecordsIds = new Set<String>();
        processRecords.attachmentIds = new Set<String>();
        for (Attachment att : attList) {
            processRecords.skipRecordsIds.add(att.Id);
            //processRecords.attachmentIds.add(att.Id);
        }
        for (CSPOFA__Orchestration_Step__c step : orchStepList) {
            step.json__c = JSON.serialize(processRecords);
        }
        update orchStepList;
        Test.startTest();
        Orchestration_OrderDeltaHandlerV2 deltaHandler = new Orchestration_OrderDeltaHandlerV2();
        orchStepList = deltaHandler.process(orchStepList);
        // Assert to check message status
        System.assertEquals(orchStepList[0].CSPOFA__Message__c, 'Success: Records processed');
        
        Test.stopTest();
    }
    
    // Where opp is not associated with order
    static testMethod void ProcessTestwithAlreadyProcessed() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<Id> subscriptionIds = new List<Id>();
        // Query form datasetup
        
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Order__r.csordtelcoa__Opportunity__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
        
        List<csord__Service__c> serviceList = [SELECT ID FROM csord__Service__c WHERE csord__Order__r.csordtelcoa__Opportunity__c = :orchStepList[0].CSPOFA__Orchestration_Process__r.Order__r.csordtelcoa__Opportunity__c];
        List<Attachment> attList = [SELECT Id FROM Attachment WHERE ParentId IN :serviceList];
        System.debug('Attachment List' + attList);
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, DML_Rows_limit__c FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '3';
        update governerLimit;
        Orchestration_ProcessedRecords processRecords = new Orchestration_ProcessedRecords();
        processRecords.skipRecordsIds = new Set<String>();
        processRecords.attachmentIds = new Set<String>();
        for (Attachment att : attList) {
            //processRecords.skipRecordsIds.add(att.Id);
            processRecords.attachmentIds.add(att.Id);
            break;
        }
        for (CSPOFA__Orchestration_Step__c step : orchStepList) {
            step.json__c = JSON.serialize(processRecords);
        }
        update orchStepList;
        Test.startTest();
        Orchestration_OrderDeltaHandlerV2 deltaHandler = new Orchestration_OrderDeltaHandlerV2();
        orchStepList = deltaHandler.process(orchStepList);
        // Assert to check message status
        System.assertEquals(orchStepList[0].CSPOFA__Message__c, 'Success: Partial records processed');
        
        Test.stopTest();
    }
    
    // Where opp is not associated with order
    static testMethod void ProcessTestwithSkipProcessed() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<Id> subscriptionIds = new List<Id>();
        // Query form datasetup
        
        List<Attachment> attList = [SELECT ID FROM Attachment];
        Integer i = 0;
        for (Attachment att : attList) {
            i++;
            if (i < 3) {
                //to skip 1 attachment
                continue;
            }
            att.Body = Blob.valueOf('{ "legacyAttributes": [], "serviceId": "" , "specifications": [] }');
        }
        update attList;
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Order__r.csordtelcoa__Opportunity__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c];
        
        Orchestration_OrderDeltaHandlerV2 deltaHandler = new Orchestration_OrderDeltaHandlerV2();
        orchStepList = deltaHandler.process(orchStepList);
        Test.startTest();
        orchStepList = deltaHandler.process(orchStepList);
        // Assert to check message status
        System.assertEquals(orchStepList[0].CSPOFA__Message__c, 'Success: Records processed');
        
        Test.stopTest();
    }
    
    static testMethod void breaking125() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, DML_Rows_limit__c FROM Governor_Limits__c];
        governerLimit.DML_Rows_limit__c = '1';
        update governerLimit;
        
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c, CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c FROM CSPOFA__Orchestration_Step__c WHERE CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c != null LIMIT 1];
        
        Orchestration_OrderDeltaHandlerV2 orderDeltaHandler = new Orchestration_OrderDeltaHandlerV2();
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
    
    
    static testMethod void testMarkServicesConnected() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c  WHERE CSPOFA__Orchestration_Process__r.Order__r.Name = 'TestMarkServicesConnected' LIMIT 1];
        
        Test.startTest();
        Orchestration_OrderDeltaHandlerV2 orderDeltaHandler = new Orchestration_OrderDeltaHandlerV2();
        SYS_TriggerHandler.bypass('C2O_SubscriptionTriggerHandler');//DIGI-18237
        orchStepList = orderDeltaHandler.process(orchStepList);
        System.assert(orchStepList.size() > 0);
        Test.stopTest();
    }
    
}