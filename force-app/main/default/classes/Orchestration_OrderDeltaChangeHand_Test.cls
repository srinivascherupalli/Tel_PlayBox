@isTest
public class Orchestration_OrderDeltaChangeHand_Test {
    
     @Testsetup
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
      List<Orchestration_Technical__c>technicalObj= new List<Orchestration_Technical__c>();
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
    offerList[2].Name = OrchestratorConstants.ProductConfigMarketableOffer.DeviceOutrightPurchase;
    offerList[2].Config__c = '{"noLineItem":true,"skipBasketSyncValidations":true,"isSOWrequired":true}';
    offerList[0].Config__c = '{"markServicesConnected":true,"skipBasketSyncValidations":true,"isSOWrequired":true}';
    offerList[0].Offer_ID__c =System.Label.ManagedService_MarketableOfferId;
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
  /*  orderList[0].csord__Primary_Order__c = ord.id;
    orderList[1].csord__Primary_Order__c = ord.id;
    orderList[8].csord__Primary_Order__c = ord.id;*/
     orderList[8].Name='TestMarkServicesConnected';
    insert orderList;
    processTempList = Orchestration_TestUtility.buildProcessTemplate(true, 1);
    prdList = Orchestration_TestUtility.buildProductDefination(false, 1);
    prdList[0].product_Specification__c = OrchestratorConstants.SpecName.DMCAT_ProductSpecification_000623;
    insert prdList;

    cscfga__Product_Configuration__c pcNewMdm = new cscfga__Product_Configuration__c();
   // pcNewMdm.name = 'Enterprise Mobility Managed Service ';
    pcNewMdm.Type__c = 'Cancel';
    pcNewMdm.Quantity_Product_Configuration__c = 111;
    pcNewMdm.ConfigurationType1__c = OrchestratorConstants.ProductConfigType.SolutionComponent;
    pcNewMdm.Remaining_Term__c = 0;
    insert pcNewMdm;

    productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(false, 3);
    productconfiglistList[0].ConfigurationType1__c = 'Product Component';
    productconfiglistList[0].name='Test PC';
    productconfiglistList[0].cscfga__Product_Definition__c = prdList[0].id;
    productconfiglistList[1].cscfga__Product_Definition__c = prdList[0].id;
    productconfiglistList[1].Remaining_Term__c = 0;
    productconfiglistList[0].Remaining_Term__c = 0;
    productconfiglistList[2].Type__c = 'Cancel';
    productconfiglistList[2].cscfga__Root_Configuration__c = pcNewMdm.id;
    productconfiglistList[0].Marketable_Offer__c = offerList[1].id;
      productconfiglistList[2].Marketable_Offer__c = offerList[2].id;
      
      ////Onkar start
	productconfiglistList[0].ConfigurationType1__c = 'SolutionComponent';
	productconfiglistList[1].ConfigurationType1__c = 'SolutionComponent';
	productconfiglistList[2].ConfigurationType1__c = 'SolutionComponent';
      ////Onkar end
      
    insert productconfiglistList;

    solutionList = Orchestration_TestUtility.buildSolution(true, 1);

    subscriptionList = Orchestration_TestUtility.buildSubscriptionWOReplace(false, 9, accountList[0].id, orderList, productconfiglistList[0].id, solutionList[0].id);
   // subscriptionList[5].csord__order__c = null;
    subscriptionList[1].csord__order__c = orderList[1].id;
    subscriptionList[2].csord__order__c = orderList[1].id;
    /*subscriptionList[3].csord__order__c = orderList[3].id;
    subscriptionList[4].csord__order__c = orderList[4].id;
    subscriptionList[7].csord__order__c = orderList[1].id;
    subscriptionList[8].csord__order__c =  orderList[8].id;*/
   // subscriptionList[0].csord__order__c = ord.id;
   subscriptionList[0].triggerBill_RTB__c=false;
    subscriptionList[0].csord__Status__c = OrchestratorConstants.SubscriptionStatus.Pending;
    subscriptionList[1].csord__Status__c = OrchestratorConstants.SubscriptionStatus.ProvisioningInProgress;
    subscriptionList[2].csord__Status__c = OrchestratorConstants.SubscriptionStatus.DisconnectPending;
    subscriptionList[3].csord__Status__c = OrchestratorConstants.SubscriptionStatus.DisconnectInProgress;
    subscriptionList[4].csord__Status__c = OrchestratorConstants.SubscriptionStatus.DisconnectInProgress;
    subscriptionList[5].csord__Status__c = 'Cancellation In Progress';
    subscriptionList[0].csordtelcoa__Product_Configuration__c = productconfiglistList[0].id;
    subscriptionList[1].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
          subscriptionList[8].csordtelcoa__Product_Configuration__c = productconfiglistList[2].id;
    subscriptionList[0].MarketableOffer__c = offerList[0].id;
    subscriptionList[1].MarketableOffer__c = offerList[0].id;
    subscriptionList[2].MarketableOffer__c = offerList[0].id;
    subscriptionList[3].MarketableOffer__c = offerList[0].id;
    subscriptionList[4].MarketableOffer__c = offerList[0].id;
      subscriptionList[8].MarketableOffer__c = offerList[2].id;     
     // subscriptionList[0].csordtelcoa__Replacement_Subscription__c=null;
    insert subscriptionList;

    servlist = Orchestration_TestUtility.buildServiceWOReplace(false, 10, subscriptionList[0].id, orderReqList[0].id, orderList[0].id, productconfiglistList[0].id);
    servlist[1].csord__Subscription__c = subscriptionList[1].id;
    servlist[1].csordtelcoa__Replaced_Service__c = null;
    servlist[2].csord__Subscription__c = subscriptionList[2].id;
    servlist[3].csord__Subscription__c = subscriptionList[1].id;
    //servlist[0].csord__Order__c = ord.id;
   // servlist[1].csord__Order__c = ord.id;
     servlist[1].csord__Order__c = orderList[1].id;     
    servlist[0].csord__Order__c = orderList[0].id;
    servlist[2].csord__Order__c = orderList[1].id;
   /* servlist[4].csord__Order__c = ord.id;
    servlist[5].csord__Order__c = ord.id;
    servlist[6].csord__Order__c = ord.id;
    servlist[7].csord__Order__c = ord.id;*/
      servlist[0].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
    servlist[4].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
    servlist[5].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
    servlist[6].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
    servlist[7].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
    servlist[0].Action_Type__c = 'Modify';
    servlist[3].Action_Type__c = OrchestratorConstants.ServiceActionType.None;
    servlist[2].Action_Type__c = OrchestratorConstants.ServiceActionType.PayOut;
    servlist[1].Action_Type__c = OrchestratorConstants.ServiceActionType.PaidOut;
    servlist[4].Action_Type__c = 'Modify';
      servlist[2].Action_Type__c = 'Modify';
    servlist[5].Action_Type__c = OrchestratorConstants.ServiceActionType.None;
    servlist[6].Action_Type__c = OrchestratorConstants.ServiceActionType.PayOut;
    servlist[7].Action_Type__c = OrchestratorConstants.ServiceActionType.PaidOut;
    servlist[0].Payment_Type__c = 'Not Rental';
      servlist[2].Payment_Type__c = 'Not Rental';
    servlist[4].Payment_Type__c = 'Not Rental';
    servlist[8].csord__Order__c = ord.id;
  servlist[9].csord__Order__c = orderList[8].id;
    servlist[9].csordtelcoa__Product_Configuration__c = productconfiglistList[2].id;
      servlist[9].csord__Subscription__c=subscriptionList[8].id;
      servlist[1].changeType__c='Change of Mobile Number';
      //servlist[1].csordtelcoa__Product_Configuration__r.cscfga__Root_Configuration__c=null;
      //servlist[0].csordtelcoa__Product_Configuration__r.cscfga__Root_Configuration__c=null;
    insert servlist;

    processList = Orchestration_TestUtility.buildProcess(false, 9, processTempList[0].id, orderList, subscriptionList, accountList[0].id, servlist[0].id);
   // processList[4].csordtelcoa__Subscription__c = null;
   // processList[0].Order__c = ord.id; // process whose orderId is primary order id of a order
    //  processList[1].Order__c = ord.id;
    processList[1].Order__c = orderList[1].id;
    //  processList[0].Order__c = orderList[0].id;
   // processList[5].Order__c = null;
   // processList[6].Order__c = ord1.id; // process whose order doesnot have any subscription
    processList[7].Order__c = orderList[1].id; // process whose order doesnot have any subscription
    processList[8].Order__c = orderList[8].id;
    insert processList;
    orchStepList = Orchestration_TestUtility.buildOrchStep(false, 9, processList);

  //  for (CSPOFA__Orchestration_Step__c step : orchStepList) {
     // step.JSON__c = null;
  //  }
    insert orchStepList;

      for(Integer i=0;i<=3;i++){
            Orchestration_Technical__c techObj = new Orchestration_Technical__c();
            techObj.Field_1__c='FULFILMENT';            
            techObj.Service__c=servlist[i].id;
            techObj.Field_14__c='DMCAT_ProductSpecification_000263';
            techObj.Field_3__c='Complete';
          techObj.Field_11__c='G003';
      technicalObj.add(techObj);
      }
      technicalObj[2].Field_1__c='BILLING';            
           // technicalObj[1].Service__c=servlist[0].id;
            technicalObj[2].Field_14__c='DMCAT_ProductSpecification_000423';     
            
        
        insert technicalObj;
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
    
     
     static testMethod void testProcessUpdate() {
        String str='';
        Set<Id>orderIds=new Set<Id>();
        Map<String,Object> payloadMap=new Map<String,Object>();   
        
      //  Orchestration_ProcessedRecords processedRecords= new Orchestration_ProcessedRecords();
        List<CSPOFA__Orchestration_Step__c> stepList = new List<CSPOFA__Orchestration_Step__c>();
      //   Orchestration_ProcessedRecords OP = new Orchestration_ProcessedRecords();
        
        System.Test.startTest();
        //Query to get the Data for Processing  
        stepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, 
                    CSPOFA__Message__c, cspofa__Orchestration_Process__r.csordtelcoa__Subscription__c,CSPOFA__Orchestration_Process__r.Order__c,
                    CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Product_Configuration__r.ConfigurationType1__c, 
                    CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__status__c, 
                    CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c,
                    CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name,
                    CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__c,
                    CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.cssdm__solution_association__c, 
                    cspofa__Orchestration_Process__r.Order__r.csord__Start_Date__c, JSON__c
                    FROM CSPOFA__Orchestration_Step__c];
        
       /* for (CSPOFA__Orchestration_Step__c step : stepList) {
            if (step.CSPOFA__Orchestration_Process__r.Order__c != null) {
                orderIds.add(step.CSPOFA__Orchestration_Process__r.Order__c);
            }
        }*/
       // for(Id ord:orderIds){
            Coms_PlatformCacheUtil.insertOrderSubscriptionAndServicesToCache(stepList[1].CSPOFA__Orchestration_Process__r.Order__c,false);
        //}
        
      //  for (CSPOFA__Orchestration_Step__c step : stepList) {
            
            		payloadMap.put('OrderId',stepList[1].CSPOFA__Orchestration_Process__r.Order__c);
                    payloadMap.put('StepId',stepList[1].Id);
                   // payloadMap.put('Current',step.CSPOFA__Orchestration_Process__r.order__c);
                    payloadMap.put('ProcessName',stepList[1].CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name);
                   // payloadMap.put('processedRecordIds','');
                    str=(String)JSON.serialize(payloadMap);
                    system.debug('payload '+str);
        
            Orchestration_OrderDeltaChange_Handler orderDeltaHandler = new Orchestration_OrderDeltaChange_Handler();
    		 orderDeltaHandler.processUpdate(str);
                        
            System.assert(stepList[0].CSPOFA__Status__c!=null);
      //  }
        Test.stopTest();
    }
    
     static testMethod void testProcessReplaceSrvUpdate() {
        String str='';
        Set<Id>orderIds=new Set<Id>();
        Map<String,Object> payloadMap=new Map<String,Object>();   
        List<CSPOFA__Orchestration_Process__c> processList = new List<CSPOFA__Orchestration_Process__c>();
         Account objAccount = [select id from Account Limit 1 ];
         CSPOFA__Orchestration_Process_Template__c processTemp = [select id from CSPOFA__Orchestration_Process_Template__c Limit 1 ];
         cscfga__Product_Definition__c prdDef = [SELECT Id,Name from cscfga__Product_Definition__c LIMIT 1];
        List<csord__Order__c> orderLists = [SELECT Id, Name,csord__Order_Request__c, csord__Identification__c from csord__Order__c];
        List<csord__Subscription__c> subList = [SELECT Id, Name ,csordtelcoa__Subscription_Number__c ,csord__Order__c,
                                                csord__Identification__c,triggerBill_RTB__c,csord__Status__c,MarketableOffer__r.Auto_Expired_Entity__c,
                                                csord__Order__r.csord__Primary_Order__r.Billing_Account__c,
                                                csordtelcoa__Product_Configuration__r.ConfigurationType1__c
                                                from csord__Subscription__c Limit 1];
        
             cscfga__Product_Configuration__c pcNewMdm = [SELECT Id,Name,Type__c,ConfigurationType1__c,cscfga__Product_Definition__c,Quantity_Product_Configuration__c,cscfga__Root_Configuration__c FROM cscfga__Product_Configuration__c LIMIT 1];
    pcNewMdm.Name = 'TestProductConfig';
    pcNewMdm.Type__c = 'New';
    pcNewMdm.ConfigurationType1__c = '';
         pcNewMdm.cscfga__Product_Definition__c=prdDef.id;
    pcNewMdm.Quantity_Product_Configuration__c = 111;
        pcNewMdm.cscfga__Root_Configuration__c=null;
    update pcNewMdm;
           List<csord__Service__c> services = [SELECT Id, Name, csordtelcoa__Product_Configuration__c,csord__Order__c,csordtelcoa__Product_Configuration__r.Name,csordtelcoa__Product_Configuration__r.ConfigurationType1__c,csord__Status__c,csordtelcoa__Replaced_Service__c,csord__Subscription__c FROM csord__Service__c LIMIT 2];
         services[0].csordtelcoa__Product_Configuration__c=pcNewMdm.id;
         services[0].csordtelcoa__Product_Configuration__r=pcNewMdm;
         system.debug('csordtelcoa__Product_Configuration__c '+services[0].csordtelcoa__Product_Configuration__r.Name);
         services[0].csordtelcoa__Replaced_Service__c= services[1].id;
         services[0].csord__Subscription__c=subList[0].id;
         
         //services[0].csordtelcoa__Product_Configuration__r.cscfga__Root_Configuration__c=null;
         services[0].csord__Order__c=orderLists[0].id;
        // services[0].csordtelcoa__Product_Configuration__r=pcNewMdm;
               //  services[0].csordtelcoa__Product_Configuration__r.ConfigurationType1__c='';
        // services[0].csordtelcoa__Product_Configuration__r.Name='Test Product Config';
         services[0].Action_Type__c = OrchestratorConstants.ServiceActionType.PaidOut;
         update services;        
         
        processList = Orchestration_TestUtility.buildProcess(true,1,processTemp.id,orderLists,subList,objAccount.id,services[0].id);
        processList[0].csordtelcoa__Service__c = services[0].Id;
        update processList;        
        
        List<CSPOFA__Orchestration_Step__c> stepList = Orchestration_TestUtility.buildOrchStep(false,1,processList);        
        insert stepList;     
         List<Attachment> attList = [SELECT Id, body FROM Attachment LIMIT 2];
        for (Attachment att : attList) {
            att.body = Blob.valueOf(
                '{ "legacyAttributes":[ ], "serviceId":"' +
                services[0].Id +
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

/*Orchestration_Technical__c techObj = new Orchestration_Technical__c();//[SELECT Id,Service__c,Field_1__c,Field_14__c,Field_3__c,Field_11__c FROM Orchestration_Technical__c];
            techObj.Field_1__c='BILLING';            
            techObj.Service__c=services[0].id;
            techObj.Field_14__c='DMCAT_ProductSpecification_000423';
         techObj.Field_3__c='Complete';
          techObj.Field_11__c='G003';
         techObj.CorrelationId__c=services[0].csord__Order__c+'Serv1TO2';
            insert techObj;
        List<sobject>sobj=new List<sobject>();
         sobj.add(techObj);*/
         
        System.Test.startTest();
        //Query to get the Data for Processing  
        stepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, 
                    CSPOFA__Message__c, cspofa__Orchestration_Process__r.csordtelcoa__Subscription__c,CSPOFA__Orchestration_Process__r.Order__c,
                    CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Product_Configuration__r.ConfigurationType1__c, 
                    CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__status__c, 
                    CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c,
                    CSPOFA__Orchestration_Process__r.csordtelcoa__Service__c,
                    CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name,
                    CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__c,
                    CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.cssdm__solution_association__c, 
                    cspofa__Orchestration_Process__r.Order__r.csord__Start_Date__c, JSON__c
                    FROM CSPOFA__Orchestration_Step__c LIMIT 8];
        
      //  for (CSPOFA__Orchestration_Step__c step : stepList) {
      //      if (step.CSPOFA__Orchestration_Process__r.Order__c != null) {
      //          orderIds.add(step.CSPOFA__Orchestration_Process__r.Order__c);
      //      }
      //  }
       // for(Id ord:orderIds){
            Coms_PlatformCacheUtil.insertOrderSubscriptionAndServicesToCache(stepList[0].CSPOFA__Orchestration_Process__r.Order__c,false);
         //Coms_PlatformCacheUtil.insertSobjectsToPlatformCache(sobj);
        //}
        
       // for (CSPOFA__Orchestration_Step__c step : stepList) {
            
            		payloadMap.put('OrderId',stepList[0].CSPOFA__Orchestration_Process__r.Order__c);
                    payloadMap.put('StepId',stepList[0].Id);
                   // payloadMap.put('Current',step.CSPOFA__Orchestration_Process__r.order__c);
                    payloadMap.put('ProcessName',stepList[0].CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name);
                   // payloadMap.put('ProcessedIds',processedIds);
                    str=(String)JSON.serialize(payloadMap);
                    system.debug('payload '+str);
        
            Orchestration_OrderDeltaChange_Handler orderDeltaHandler = new Orchestration_OrderDeltaChange_Handler();
    		 orderDeltaHandler.processUpdate(str);
                        
            System.assert(stepList[0].CSPOFA__Status__c!=null);
        //}
        Test.stopTest();
    }

}