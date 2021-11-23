@isTest(SeeAllData=false)
public class Orchestration_GenTransDataV1Hand_Test {
    
     public static List<CSPOFA__Orchestration_Process__c> processList = new List<CSPOFA__Orchestration_Process__c>();
    public static List<CSPOFA__Orchestration_Process_Template__c> processTempList = new List<CSPOFA__Orchestration_Process_Template__c>();
    public static List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
    public static List<account> accountList = new List<account>();
    public static List<csord__Order_Request__c> orderReqList = new List<csord__Order_Request__c>();
    public static List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
    public static List<csord__Subscription__c> subscriptionListNew = new List<csord__Subscription__c>();
    public static List<csord__Order__c> orderList = new List<csord__Order__c>();
    public static list<cscfga__Product_Configuration__c> productconfiglistList= new list<cscfga__Product_Configuration__c>();
    public static list<csord__Solution__c> solutionList= new list<csord__Solution__c>();
    public static List<csord__Service__c> servlist = new List<csord__Service__c>();
    public static Governor_Limits__c governerLimit = new Governor_Limits__c();
    public static list<Attachment> attachmentList= new list<Attachment>();
    public static List<Marketable_Offer__c> offerList = new List<Marketable_Offer__c>();
    public static List<Asset> assetList = new List<Asset>();
    public static List<Product_Attribute_Metadata__c> listMetadata = new List<Product_Attribute_Metadata__c>();
    public static EnvironmentVariable__c env = new EnvironmentVariable__c();
	public static List<Orchestration_Technical__c>technicalObj= new List<Orchestration_Technical__c>();
    public static List<cscfga__Product_Definition__c> prdList = new List<cscfga__Product_Definition__c>();
    public static List<Opportunity> oppList = new List<Opportunity>();
    public static List<Case> caseList = new List<Case>();
    public static csordtelcoa__Orders_Subscriptions_Options__c subsSettings = new csordtelcoa__Orders_Subscriptions_Options__c();
     @Testsetup 
    static void dataSetup(){
        
        
         subsSettings = Orchestration_TestUtility.buildsubOption();
    governerLimit = Orchestration_TestUtility.buildLimits();
    accountList = Orchestration_TestUtility.buildAccount(true, 1);
    oppList = Orchestration_TestUtility.buildOpp(true, 1, accountList);
    caseList = Orchestration_TestUtility.buildCase(false, 1, oppList, accountList);
    caseList[0].subject = null;
    insert caseList;
        orderReqList = Orchestration_TestUtility.buildOrderRequest(true,1);
        orderList = Orchestration_TestUtility.buildOrder('order', accountList[0].id, 'Complete', orderReqList[0].id, false , 5);
        orderList[0].scenario_type__c = Label.Device_Replacement;
        insert orderList;  
		    

        //Creating data for process
    offerList = Orchestration_TestUtility.buildMarkertableOffer(false, 3);
    offerList[2].Name = OrchestratorConstants.ProductConfigMarketableOffer.DeviceOutrightPurchase;
    offerList[2].Config__c = '{"noLineItem":true,"skipBasketSyncValidations":true,"isSOWrequired":true}';
    offerList[0].Config__c = '{"markServicesConnected":true,"skipBasketSyncValidations":true,"isSOWrequired":true}';
    offerList[0].Offer_ID__c ='DMCAT_Offer_000303';//System.Label.ManagedService_MarketableOfferId;
    insert offerList;
   

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

   // orderList = Orchestration_TestUtility.buildOrder('order', accountList[0].id, 'Complete', orderReqList[0].id, false, 9);
  /*  orderList[0].csord__Primary_Order__c = ord.id;
    orderList[1].csord__Primary_Order__c = ord.id;
    orderList[8].csord__Primary_Order__c = ord.id;*/
    // orderList[8].Name='TestMarkServicesConnected';
    //insert orderList;
    processTempList = Orchestration_TestUtility.buildProcessTemplate(false, 1);
        insert processTempList;
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
    subscriptionList[0].csord__order__c = orderList[0].id;
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
    servlist[0].csord__Subscription__c = subscriptionList[0].id;
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
  servlist[9].csord__Order__c = orderList[1].id;
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
            techObj.Field_14__c='DMCAT_ProductSpecification_000263_Fulfilment';
            techObj.Field_3__c='Created';
          techObj.Field_11__c='963263ce-cb0a-64cd-17d6-06b524f533e2';
      technicalObj.add(techObj);
      }
    //  technicalObj[2].Field_1__c='BILLING';            
           // technicalObj[1].Service__c=servlist[0].id;
        //    technicalObj[2].Field_14__c='DMCAT_ProductSpecification_000423';     
            
        
        insert technicalObj;
		 attachmentList = Orchestration_TestUtility.buildAttachment(false,3,servlist,productconfiglistList[0].id);
         attachmentList[2].Body = Blob.valueOf('{ "legacyAttributes" : [ ], "serviceId" : "'+servlist[2].id+'", "specifications" : [ { "additionalAttributes" : { "IPWirelessProductInstanceID" : "91699412-512f-f8bd-2950-dedb06b0d13b", "DMCAT_ProductSpecification_000263_CPEDeliveryDate" : "2019-03-14T08:00:00" }, "attributes" : { "IPWirelessProductInstanceID" : "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem" : "FULFILMENT", "SERVICEPROFILE" : "DATA_BACKUP", "MESSAGEBANK" : "NA", "INTROAM" : "NA", "CONTEXT" : "NA", "CALLCONTROL" : "NA", "AccessRole" : "Primary", "BillofMaterialID" : "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID" : "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate" : "", "ShippingRequired" : "TRUE", "IMSI" : "", "SIMSerialNumber" : "" }, "code" : "DMCAT_ProductSpecification_000263_Fulfilment", "description" : "", "endDate" : "", "guid" : "963263ce-cb0a-64cd-17d6-06b524f533e2", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "Mobile Access_Fulfilment", "productConfigurationId" : "a3T2O000000GuQXUA0", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate" : "", "status" : "modified", "version" : "1" }, { "additionalAttributes" : { }, "attributes" : { "__targetSystem" : "ASSURANCE", "ServiceManagementOption " : "1" }, "code" : "DMCAT_ProductSpecification_000326_Assurance", "description" : "", "endDate" : "", "guid" : "68af7760-5543-670c-1454-489b1e40d1ca", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "Telstra Managed Service Option 1_Assurance", "productConfigurationId" : "a3T2O000000GuQXUA0", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000326", "startDate" : "", "status" : "Disconnect Pending", "version" : "1" }, { "additionalAttributes" : { }, "attributes" : { "__targetSystem" : "BILLING", "billingSpecId" : "BSUSG001_CB", "ocsProdID" : "T22E_MIA_DATPLAN", "type" : "Domestic Data", "unitofMeasure" : "GB", "value" : "Unlimited", "RoutingServiceType" : "Mobile", "billDescription" : "Mobile Interim Access Allowance", "SERVICEID" : "61429751286", "IMSI" : "" }, "code" : "DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3", "description" : "", "endDate" : "", "guid" : "4acc4396-bddd-31c9-71f8-77930cb5a68c", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "Mobile Access_Bill_AW", "productConfigurationId" : "a3T2O000000GuQXUA0", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3", "startDate" : "", "status" : "Disconnect Pending", "version" : "1" }, { "additionalAttributes" : { }, "attributes" : { "__targetSystem" : "BILLING", "billingSpecId" : "BSUSG001_CB", "ocsProdID" : "ocsProd3", "type" : "Dummy ngUC", "unitofMeasure" : "GB", "value" : "Unlimited", "RoutingServiceType" : "Voice", "billDescription" : "ngUC Dummy Usage Specification Allowance" }, "code" : "DMCAT_ProductSpecification_000313_Billing_Allowance_000512_4", "description" : "", "endDate" : "", "guid" : "960b0d11-c4b0-21e9-d2a9-6f1aa15cd193", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "UC Numbers_Bill_AW", "productConfigurationId" : "a3T2O000000GuQXUA0", "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313_Billing_Allowance_000512_4", "startDate" : "", "status" : "Disconnect Pending", "version" : "1" }, { "additionalAttributes" : { "BSServiceTypeProductInstanceID" : "c557bd15-31b3-ccea-b9da-a9182979ac51", "DMCAT_ProductSpecification_000322_CPEDeliveryDate" : "2019-03-14T08:00:00" }, "attributes" : { "BSServiceTypeProductInstanceID" : "DMCAT_ProductSpecification_000312_Fulfilment", "__targetSystem" : "FULFILMENT", "CustomerFacingServiceId" : "", "CustomerPreferredName" : "", "DMCAT_ProductSpecification_000322_CPEDeliveryDate" : "" }, "code" : "DMCAT_ProductSpecification_000322_Fulfilment", "description" : "", "endDate" : "", "guid" : "70e2316f-6e03-54f5-38e6-d0d3eedb7c22", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "UC Site_Fulfilment", "productConfigurationId" : "a3T2O000000GuQXUA0", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000322", "startDate" : "", "status" : "Created", "version" : "1" }, { "additionalAttributes" : { "InternetProtectionSolutionProductInstanceID" : "97754883-23a9-375b-3af8-b991e4733a61" }, "attributes" : { "__targetSystem" : "FULFILMENT", "UserProtectionType" : "Web and Mail", "InternetProtectionSolutionProductInstanceID" : "DMCAT_ProductSpecification_000163_Fulfilment", "Quantity" : "3" }, "code" : "DMCAT_ProductSpecification_000162_Fulfilment", "description" : "", "endDate" : "", "guid" : "79d6ca6f-8288-aadc-8247-e939262c37d3", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "Web and Mail Internet Protection User_Fulfilment", "productConfigurationId" : "a3T2O000000GuQXUA0", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000162", "startDate" : "", "status" : "Created", "version" : "1" }, { "additionalAttributes" : { "parentSpec" : "68af7760-5543-670c-1454-489b1e40d1ca" }, "attributes" : { "__targetSystem" : "ASSURANCE", "parentSpec" : "DMCAT_ProductSpecification_000326_Assurance", "ResponseTarget" : "", "RestoreTarget" : "" }, "code" : "DMCAT_ProductSpecification_000151_Assurance", "description" : "", "endDate" : "", "guid" : "88893db5-4da5-93eb-45bf-73425cf7ce51", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "Incident Management_Assurance", "productConfigurationId" : "a3T2O000000GuQXUA0", "specification" : "DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151", "startDate" : "", "status" : "Disconnect Pending", "version" : "1" }, { "additionalAttributes" : { "parentSpec" : "70e2316f-6e03-54f5-38e6-d0d3eedb7c22" }, "attributes" : { "__targetSystem" : "FULFILMENT", "name" : "Hosted UC", "CustomerFacingServiceId" : "", "id" : "", "parentSpec" : "DMCAT_ProductSpecification_000322_Fulfilment", "Quantity" : "3" }, "code" : "DMCAT_ProductSpecification_000315_Fulfilment", "description" : "", "endDate" : "", "guid" : "c362d71e-94a3-8415-528a-26f1e09cf39f", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "Feature Packs_Fulfilment", "productConfigurationId" : "a3T2O000000GuQXUA0", "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000315", "startDate" : "", "status" : "Created", "version" : "1" }, { "additionalAttributes" : { "parentSpec" : "70e2316f-6e03-54f5-38e6-d0d3eedb7c22" }, "attributes" : { "parentSpec" : "DMCAT_ProductSpecification_000322_Fulfilment", "__targetSystem" : "FULFILMENT", "VoicePlan" : "Complete Premium", "id" : "", "CustomerFacingServiceId" : "", "Number" : [ { "schemaId" : "832ab1bd-4f74-5292-981d-7004e1ba8e58", "attributes" : { "FNN" : "3333333333", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "LE" } }, { "schemaId" : "5efc4e53-4f93-df2f-8a95-afbfb462cdab", "attributes" : { "FNN" : "8282345568", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "0e129064-fdef-fa98-94ed-5be9dbb49e74", "attributes" : { "FNN" : "8282345526", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } } ] }, "code" : "DMCAT_ProductSpecification_000313_Fulfilment", "description" : "", "endDate" : "", "guid" : "033ce46a-f7de-48ca-23e6-41165dba9b65", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "UC Numbers_Fulfilment", "productConfigurationId" : "a3T2O000000GuQXUA0", "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313", "startDate" : "", "status" : "Created", "version" : "1" } ] }');
         attachmentList[0].Body = Blob.valueOf('{ "legacyAttributes" : [ ], "serviceId" : "'+servlist[0].id+'", "specifications" : [ { "additionalAttributes" : { "IPWirelessProductInstanceID" : "91699412-512f-f8bd-2950-dedb06b0d13b", "DMCAT_ProductSpecification_000263_CPEDeliveryDate" : "2019-03-14T08:00:00" }, "attributes" : { "IPWirelessProductInstanceID" : "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem" : "FULFILMENT", "SERVICEPROFILE" : "DATA_BACKUP", "MESSAGEBANK" : "NA", "INTROAM" : "NA", "CONTEXT" : "NA", "CALLCONTROL" : "NA", "AccessRole" : "Primary", "BillofMaterialID" : "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID" : "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate" : "", "ShippingRequired" : "TRUE", "IMSI" : "", "SIMSerialNumber" : "" }, "code" : "DMCAT_ProductSpecification_000263_Fulfilment", "description" : "", "endDate" : "", "guid" : "963263ce-cb0a-64cd-17d6-06b524f533e2", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "Mobile Access_Fulfilment", "productConfigurationId" : "a3T2O000000GuQXUA0", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate" : "", "status" : "Created", "version" : "1" }, { "additionalAttributes" : { }, "attributes" : { "__targetSystem" : "ASSURANCE", "ServiceManagementOption " : "1" }, "code" : "DMCAT_ProductSpecification_000326_Assurance", "description" : "", "endDate" : "", "guid" : "68af7760-5543-670c-1454-489b1e40d1ca", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "Telstra Managed Service Option 1_Assurance", "productConfigurationId" : "a3T2O000000GuQXUA0", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000326", "startDate" : "", "status" : "Disconnect Pending", "version" : "1" }, { "additionalAttributes" : { }, "attributes" : { "__targetSystem" : "BILLING", "billingSpecId" : "BSUSG001_CB", "ocsProdID" : "T22E_MIA_DATPLAN", "type" : "Domestic Data", "unitofMeasure" : "GB", "value" : "Unlimited", "RoutingServiceType" : "Mobile", "billDescription" : "Mobile Interim Access Allowance", "SERVICEID" : "61429751286", "IMSI" : "" }, "code" : "DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3", "description" : "", "endDate" : "", "guid" : "4acc4396-bddd-31c9-71f8-77930cb5a68c", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "Mobile Access_Bill_AW", "productConfigurationId" : "a3T2O000000GuQXUA0", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3", "startDate" : "", "status" : "Disconnect Pending", "version" : "1" }, { "additionalAttributes" : { }, "attributes" : { "__targetSystem" : "BILLING", "billingSpecId" : "BSUSG001_CB", "ocsProdID" : "ocsProd3", "type" : "Dummy ngUC", "unitofMeasure" : "GB", "value" : "Unlimited", "RoutingServiceType" : "Voice", "billDescription" : "ngUC Dummy Usage Specification Allowance" }, "code" : "DMCAT_ProductSpecification_000313_Billing_Allowance_000512_4", "description" : "", "endDate" : "", "guid" : "960b0d11-c4b0-21e9-d2a9-6f1aa15cd193", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "UC Numbers_Bill_AW", "productConfigurationId" : "a3T2O000000GuQXUA0", "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313_Billing_Allowance_000512_4", "startDate" : "", "status" : "Disconnect Pending", "version" : "1" }, { "additionalAttributes" : { "BSServiceTypeProductInstanceID" : "c557bd15-31b3-ccea-b9da-a9182979ac51", "DMCAT_ProductSpecification_000322_CPEDeliveryDate" : "2019-03-14T08:00:00" }, "attributes" : { "BSServiceTypeProductInstanceID" : "DMCAT_ProductSpecification_000312_Fulfilment", "__targetSystem" : "FULFILMENT", "CustomerFacingServiceId" : "", "CustomerPreferredName" : "", "DMCAT_ProductSpecification_000322_CPEDeliveryDate" : "" }, "code" : "DMCAT_ProductSpecification_000322_Fulfilment", "description" : "", "endDate" : "", "guid" : "70e2316f-6e03-54f5-38e6-d0d3eedb7c22", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "UC Site_Fulfilment", "productConfigurationId" : "a3T2O000000GuQXUA0", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000322", "startDate" : "", "status" : "Created", "version" : "1" }, { "additionalAttributes" : { "InternetProtectionSolutionProductInstanceID" : "97754883-23a9-375b-3af8-b991e4733a61" }, "attributes" : { "__targetSystem" : "FULFILMENT", "UserProtectionType" : "Web and Mail", "InternetProtectionSolutionProductInstanceID" : "DMCAT_ProductSpecification_000163_Fulfilment", "Quantity" : "3" }, "code" : "DMCAT_ProductSpecification_000162_Fulfilment", "description" : "", "endDate" : "", "guid" : "79d6ca6f-8288-aadc-8247-e939262c37d3", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "Web and Mail Internet Protection User_Fulfilment", "productConfigurationId" : "a3T2O000000GuQXUA0", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000162", "startDate" : "", "status" : "Created", "version" : "1" }, { "additionalAttributes" : { "parentSpec" : "68af7760-5543-670c-1454-489b1e40d1ca" }, "attributes" : { "__targetSystem" : "ASSURANCE", "parentSpec" : "DMCAT_ProductSpecification_000326_Assurance", "ResponseTarget" : "", "RestoreTarget" : "" }, "code" : "DMCAT_ProductSpecification_000151_Assurance", "description" : "", "endDate" : "", "guid" : "88893db5-4da5-93eb-45bf-73425cf7ce51", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "Incident Management_Assurance", "productConfigurationId" : "a3T2O000000GuQXUA0", "specification" : "DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151", "startDate" : "", "status" : "Disconnect Pending", "version" : "1" }, { "additionalAttributes" : { "parentSpec" : "70e2316f-6e03-54f5-38e6-d0d3eedb7c22" }, "attributes" : { "__targetSystem" : "FULFILMENT", "name" : "Hosted UC", "CustomerFacingServiceId" : "", "id" : "", "parentSpec" : "DMCAT_ProductSpecification_000322_Fulfilment", "Quantity" : "3" }, "code" : "DMCAT_ProductSpecification_000315_Fulfilment", "description" : "", "endDate" : "", "guid" : "c362d71e-94a3-8415-528a-26f1e09cf39f", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "Feature Packs_Fulfilment", "productConfigurationId" : "a3T2O000000GuQXUA0", "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000315", "startDate" : "", "status" : "Created", "version" : "1" }, { "additionalAttributes" : { "parentSpec" : "70e2316f-6e03-54f5-38e6-d0d3eedb7c22" }, "attributes" : { "parentSpec" : "DMCAT_ProductSpecification_000322_Fulfilment", "__targetSystem" : "FULFILMENT", "VoicePlan" : "Complete Premium", "id" : "", "CustomerFacingServiceId" : "", "Number" : [ { "schemaId" : "832ab1bd-4f74-5292-981d-7004e1ba8e58", "attributes" : { "FNN" : "3333333333", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "LE" } }, { "schemaId" : "5efc4e53-4f93-df2f-8a95-afbfb462cdab", "attributes" : { "FNN" : "8282345568", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "0e129064-fdef-fa98-94ed-5be9dbb49e74", "attributes" : { "FNN" : "8282345526", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } } ] }, "code" : "DMCAT_ProductSpecification_000313_Fulfilment", "description" : "", "endDate" : "", "guid" : "033ce46a-f7de-48ca-23e6-41165dba9b65", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "UC Numbers_Fulfilment", "productConfigurationId" : "a3T2O000000GuQXUA0", "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313", "startDate" : "", "status" : "Created", "version" : "1" } ] }');
   
         attachmentList[1].ParentId = servlist[0].id;
         attachmentList[2].ParentId = servlist[2].id;
         attachmentList[1].Body = Blob.valueOf('{ "legacyAttributes": [], "serviceId": "'+servlist[0].id+'", "specifications": [ { "additionalAttributes": { "IPWirelessProductInstanceID": "91699412-512f-f8bd-2950-dedb06b0d13b", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "2019-03-14T08:00:00" }, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "FULFILMENT", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "DMCAT_ProductSpecification_000263_Fulfilment", "description": "", "endDate": "", "guid": "963263ce-cb0a-64cd-17d6-06b524f533e0", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Tele Access_Fulfilment", "productConfigurationId": "'+productconfiglistList[0].id+'", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "Created", "version": "1" }, { "additionalAttributes": { "IPWirelessProductInstanceID": "91699412-512f-f8bd-2950-dedb06b0d13b", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "2019-03-14T08:00:00" }, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "FULFILMENT", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "DMCAT_ProductSpecification_000423_Fulfilment", "description": "", "endDate": "", "guid": "963263ce-cb0a-64cd-17d6-06b524f533e1", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Tele Access_Fulfilment", "productConfigurationId": "'+productconfiglistList[0].id+'", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "Disconnect In Progress", "version": "1" }, { "additionalAttributes": { "IPWirelessProductInstanceID": "91699412-512f-f8bd-2950-dedb06b0d13b", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "2019-03-14T08:00:00" }, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "FULFILMENT", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "DMCAT_ProductSpecification_000263_Fulfilment", "description": "", "endDate": "", "guid": "963263ce-cb0a-64cd-17d6-06b524f533e2", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Tele Access_Fulfilment", "productConfigurationId": "'+productconfiglistList[0].id+'", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "Modified", "version": "1" } ] }');
         insert attachmentList;
        
		/* attachmentList = Orchestration_TestUtility.buildAttachment(false, 8, servlist, productconfiglistList[0].id);
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
	
	    insert attachmentList;*/

        // processList = Orchestration_TestUtility.buildProcess(false, 5, processTempList[0].id, orderList, subscriptionList,accountList[0].id,servlist[0].id); 
         //processList[4].Order__c = ord.id; // Ord it the order which doesnit have any service
      //   insert processList;
      // Insert process template for Inflight Order Starts
       CSPOFA__Orchestration_Process_Template__c inflightProcessTemplate = new CSPOFA__Orchestration_Process_Template__c();
         inflightProcessTemplate.Name='Inflight Orchestration Process';
         inflightProcessTemplate.CSPOFA__Process_Type__c = 'New Provide';
         inflightProcessTemplate.CSPOFA__Processing_Mode__c = 'Foreground';
         insert inflightProcessTemplate;
      
     CSPOFA__Orchestration_Process_Template__c baseProcessTemplate = new CSPOFA__Orchestration_Process_Template__c();
         baseProcessTemplate.Name='Order Fulfilment Process';
         baseProcessTemplate.CSPOFA__Process_Type__c = 'New Provide';
         baseProcessTemplate.CSPOFA__Processing_Mode__c = 'Foreground';
         insert baseProcessTemplate;  
     
          CSPOFA__Orchestration_Process__c orchProcess = new CSPOFA__Orchestration_Process__c();
          orchProcess.Name = 'Test Orch Process';
          orchProcess.Order__c = orderList[0].Id;
          orchProcess.has_Inactive_Children__c = 'NA';
          orchProcess.CSPOFA__Orchestration_Process_Template__c = inflightProcessTemplate.Id;
          orchProcess.cspofa__account__c = accountList[0].id;
          orchProcess.csordtelcoa__Subscription__c = subscriptionList[0].id;
          orchProcess.csordtelcoa__Service__c = servlist[0].id;
          insert orchProcess;
         
         CSPOFA__Orchestration_Process__c orchProcessBase = new CSPOFA__Orchestration_Process__c();
          orchProcessBase.Name = 'Test Orch Process';
          orchProcessBase.Order__c = orderList[0].Id;
          orchProcessBase.has_Inactive_Children__c = 'NA';
          orchProcessBase.CSPOFA__Orchestration_Process_Template__c = baseProcessTemplate.Id;
          orchProcessBase.cspofa__account__c = accountList[0].id;
          orchProcessBase.csordtelcoa__Subscription__c = subscriptionList[0].id;
          orchProcessBase.csordtelcoa__Service__c = servlist[0].id;
          insert orchProcessBase;
         
         CSPOFA__Orchestration_Step__c inflightStep = new CSPOFA__Orchestration_Step__c();
         inflightStep.name = 'step1';
         inflightStep.CSPOFA__Orchestration_Process__c = orchProcess.Id;
         inflightStep.CSPOFA__Completed_Date__c = Date.Today(); 
         inflightStep.JSON__c =  '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';
         inflightStep.CSPOFA__Message__c = 'In Progress';
         insert inflightStep; 
         
         CSPOFA__Orchestration_Step__c baseStep = new CSPOFA__Orchestration_Step__c();
         baseStep.name = 'step1';
         baseStep.CSPOFA__Orchestration_Process__c = orchProcessBase.Id;
         baseStep.CSPOFA__Completed_Date__c = Date.Today(); 
         baseStep.JSON__c =  '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';
         baseStep.CSPOFA__Message__c = 'In Progress';
         insert baseStep; 
             
       /* orchStepList = Orchestration_TestUtility.buildOrchStep(false,5,processList);
        orchStepList[0].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'","'+orderList[1].id+'"]}';
        orchStepList[1].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';
        orchStepList[2].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';
        orchStepList[3].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';
        orchStepList[4].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';
        insert orchStepList;*/
         
        listMetadata = Orchestration_TestUtility.buildAttribute(false,3);
         listMetadata[1].Change_Type__c='New';
         listMetadata[1].Change_SubType__c=null;
         listMetadata[2].Product_ID__c='DMCAT_ProductSpecification_000263_Fulfilment';
         insert listMetadata;
        env = Orchestration_TestUtility.buildENV(false,1); 
         env.Value__c ='false';
         insert env;
        assetList = Orchestration_TestUtility.buildAsset(true,1,accountList[0].id);
        
    }
    
    static testMethod void testProcessUpdate() {
        String str=''; 
        Map<String,Object> payloadMap=new Map<String,Object>(); 
        Set<Id>orderIds=new Set<Id>();
        
        
        Orchestration_ProcessedRecords processedRecords= new Orchestration_ProcessedRecords();
        List<CSPOFA__Orchestration_Step__c> stepList = new List<CSPOFA__Orchestration_Step__c>();
         Orchestration_ProcessedRecords OP = new Orchestration_ProcessedRecords();
        Map<Id,boolean>inflightFlagMap = new Map<Id,boolean>();
         Test.startTest();

        //Query to get the Data for Processing  
        stepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, 
                    CSPOFA__Message__c, cspofa__Orchestration_Process__r.csordtelcoa__Subscription__c,
                    CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Product_Configuration__r.ConfigurationType1__c, 
                    CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__status__c, 
                    CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csord__Order__c,
                    CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.csordtelcoa__Replacement_Subscription__r.csord__Order__c,
                    CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__r.cssdm__solution_association__c, 
                    cspofa__Orchestration_Process__r.Order__r.csord__Start_Date__c, JSON__c
                    FROM CSPOFA__Orchestration_Step__c ];

        
         for (CSPOFA__Orchestration_Step__c step : stepList) {
            if (step.CSPOFA__Orchestration_Process__r.csordtelcoa__Subscription__c != null) {
                orderIds.add(step.CSPOFA__Orchestration_Process__r.Order__c);
            }
        }
       // system.debug('orderIds '+orderIds);
        //for(Id ord:orderIds){
            Coms_PlatformCacheUtil.insertOrderSubscriptionAndServicesToCache(stepList[0].CSPOFA__Orchestration_Process__r.Order__c,false);
                      inflightFlagMap.put(stepList[0].CSPOFA__Orchestration_Process__r.Order__c,false);

       // }
        
     Orchestration_ProcessedRecords processedRecordIds = new Orchestration_ProcessedRecords();
        
        //for (CSPOFA__Orchestration_Step__c step : stepList) {
                  payloadMap.put('OrderId',stepList[0].CSPOFA__Orchestration_Process__r.Order__c);
                    payloadMap.put('StepId',stepList[0].Id);
                    payloadMap.put('processedRecordIds',processedRecordIds);

                   payloadMap.put('inflightFlagMap',inflightFlagMap);
            
                    str=(String)JSON.serialize(payloadMap);
            system.debug('str### '+str);
            Orchestration_GenTransDataV1_Handler orderDeltaHandler = new Orchestration_GenTransDataV1_Handler();
            orderDeltaHandler.processUpdate(str);
                        
            System.assert(stepList[0].CSPOFA__Status__c!=null);
        //}
        Test.stopTest();
    }


}