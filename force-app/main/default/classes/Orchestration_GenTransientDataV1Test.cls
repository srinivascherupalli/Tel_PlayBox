@isTest
public class Orchestration_GenTransientDataV1Test {
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
     @Testsetup static void dataSetup(){
        
        governerLimit = Orchestration_TestUtility.buildLimits();
        accountList = Orchestration_TestUtility.buildAccount(true,1);
        orderReqList = Orchestration_TestUtility.buildOrderRequest(true,1);
        orderList = Orchestration_TestUtility.buildOrder('order', accountList[0].id, 'Complete', orderReqList[0].id, false , 5);
        orderList[0].scenario_type__c = Label.Device_Replacement;
        insert orderList;  
        processTempList = Orchestration_TestUtility.buildProcessTemplate(true,1);

        productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(true,1);
        //productconfiglistList[1].ConfigurationType1__c = 'Solution Component';
        //insert productconfiglistList;

         solutionList = Orchestration_TestUtility.buildSolution(true,1);
         offerList = Orchestration_TestUtility.buildMarkertableOffer(true,1);
         subscriptionList = Orchestration_TestUtility.buildSubscription(false,5,accountList[0].id,orderList, productconfiglistList[0].id, solutionList[0].id);
         subscriptionList[2].csord__Order__c = null;
         subscriptionList[0].csord__Status__c = 'Failed';
         subscriptionList[1].csord__Status__c = 'Billing Complete';
         subscriptionList[2].csord__Status__c = 'Cancellation In Progress';
         subscriptionList[0].MarketableOffer__c = offerList[0].id;
         subscriptionList[1].MarketableOffer__c = offerList[0].id;
         subscriptionList[2].MarketableOffer__c = offerList[0].id;
         subscriptionList[3].MarketableOffer__c = offerList[0].id;
         insert subscriptionList;
       /* subscriptionList[0].csordtelcoa__Product_Configuration__r.ConfigurationType1__c = productconfiglistList[0].id;
        subscriptionList[0].csord__Order__c = orderList[0].id;
        subscriptionList[0].csord__Status__c = 'ActiveS';
        insert subscriptionList;*/
         
        servlist= Orchestration_TestUtility.buildService(false,5,subscriptionList[0].id,orderReqList[0].id,orderList[0].id,productconfiglistList[0].id);
        servlist[1].csord__Order__c = orderList[1].id;
         servlist[2].csord__Order__c = orderList[2].id;
         servlist[3].csord__Order__c = orderList[3].id;
         servlist[1].Scenario_Type__c = 'New';
         servlist[2].Scenario_Type__c = 'Modify';
         servlist[3].Scenario_Type__c = 'New';
         //servlist[4].csord__Order__c = null;
         insert servlist; 
         
          // Ord it the order which doesnit have any service
         csord__Order__c ord = new csord__Order__c();
         ord.name = 'ExtraOrder';
         ord.csord__Account__c = accountList[0].id;
         ord.csord__Status2__c = 'Complete';
         ord.csord__Order_Request__c = orderReqList[0].id;
         ord.csord__Identification__c = 'IDE1322';
         ord.stage__c = 'Being Fulfilled';
         ord.isTransientComplete__c = false;
         insert ord;
         
         attachmentList = Orchestration_TestUtility.buildAttachment(false,3,servlist,productconfiglistList[0].id);
         attachmentList[2].Body = Blob.valueOf('{ "legacyAttributes" : [ ], "serviceId" : "'+servlist[2].id+'", "specifications" : [ { "additionalAttributes" : { "IPWirelessProductInstanceID" : "91699412-512f-f8bd-2950-dedb06b0d13b", "DMCAT_ProductSpecification_000263_CPEDeliveryDate" : "2019-03-14T08:00:00" }, "attributes" : { "IPWirelessProductInstanceID" : "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem" : "FULFILMENT", "SERVICEPROFILE" : "DATA_BACKUP", "MESSAGEBANK" : "NA", "INTROAM" : "NA", "CONTEXT" : "NA", "CALLCONTROL" : "NA", "AccessRole" : "Primary", "BillofMaterialID" : "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID" : "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate" : "", "ShippingRequired" : "TRUE", "IMSI" : "", "SIMSerialNumber" : "" }, "code" : "DMCAT_ProductSpecification_000263_Fulfilment", "description" : "", "endDate" : "", "guid" : "963263ce-cb0a-64cd-17d6-06b524f533e2", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "Mobile Access_Fulfilment", "productConfigurationId" : "a3T2O000000GuQXUA0", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate" : "", "status" : "modified", "version" : "1" }, { "additionalAttributes" : { }, "attributes" : { "__targetSystem" : "ASSURANCE", "ServiceManagementOption " : "1" }, "code" : "DMCAT_ProductSpecification_000326_Assurance", "description" : "", "endDate" : "", "guid" : "68af7760-5543-670c-1454-489b1e40d1ca", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "Telstra Managed Service Option 1_Assurance", "productConfigurationId" : "a3T2O000000GuQXUA0", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000326", "startDate" : "", "status" : "Disconnect Pending", "version" : "1" }, { "additionalAttributes" : { }, "attributes" : { "__targetSystem" : "BILLING", "billingSpecId" : "BSUSG001_CB", "ocsProdID" : "T22E_MIA_DATPLAN", "type" : "Domestic Data", "unitofMeasure" : "GB", "value" : "Unlimited", "RoutingServiceType" : "Mobile", "billDescription" : "Mobile Interim Access Allowance", "SERVICEID" : "61429751286", "IMSI" : "" }, "code" : "DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3", "description" : "", "endDate" : "", "guid" : "4acc4396-bddd-31c9-71f8-77930cb5a68c", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "Mobile Access_Bill_AW", "productConfigurationId" : "a3T2O000000GuQXUA0", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3", "startDate" : "", "status" : "Disconnect Pending", "version" : "1" }, { "additionalAttributes" : { }, "attributes" : { "__targetSystem" : "BILLING", "billingSpecId" : "BSUSG001_CB", "ocsProdID" : "ocsProd3", "type" : "Dummy ngUC", "unitofMeasure" : "GB", "value" : "Unlimited", "RoutingServiceType" : "Voice", "billDescription" : "ngUC Dummy Usage Specification Allowance" }, "code" : "DMCAT_ProductSpecification_000313_Billing_Allowance_000512_4", "description" : "", "endDate" : "", "guid" : "960b0d11-c4b0-21e9-d2a9-6f1aa15cd193", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "UC Numbers_Bill_AW", "productConfigurationId" : "a3T2O000000GuQXUA0", "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313_Billing_Allowance_000512_4", "startDate" : "", "status" : "Disconnect Pending", "version" : "1" }, { "additionalAttributes" : { "BSServiceTypeProductInstanceID" : "c557bd15-31b3-ccea-b9da-a9182979ac51", "DMCAT_ProductSpecification_000322_CPEDeliveryDate" : "2019-03-14T08:00:00" }, "attributes" : { "BSServiceTypeProductInstanceID" : "DMCAT_ProductSpecification_000312_Fulfilment", "__targetSystem" : "FULFILMENT", "CustomerFacingServiceId" : "", "CustomerPreferredName" : "", "DMCAT_ProductSpecification_000322_CPEDeliveryDate" : "" }, "code" : "DMCAT_ProductSpecification_000322_Fulfilment", "description" : "", "endDate" : "", "guid" : "70e2316f-6e03-54f5-38e6-d0d3eedb7c22", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "UC Site_Fulfilment", "productConfigurationId" : "a3T2O000000GuQXUA0", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000322", "startDate" : "", "status" : "Created", "version" : "1" }, { "additionalAttributes" : { "InternetProtectionSolutionProductInstanceID" : "97754883-23a9-375b-3af8-b991e4733a61" }, "attributes" : { "__targetSystem" : "FULFILMENT", "UserProtectionType" : "Web and Mail", "InternetProtectionSolutionProductInstanceID" : "DMCAT_ProductSpecification_000163_Fulfilment", "Quantity" : "3" }, "code" : "DMCAT_ProductSpecification_000162_Fulfilment", "description" : "", "endDate" : "", "guid" : "79d6ca6f-8288-aadc-8247-e939262c37d3", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "Web and Mail Internet Protection User_Fulfilment", "productConfigurationId" : "a3T2O000000GuQXUA0", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000162", "startDate" : "", "status" : "Created", "version" : "1" }, { "additionalAttributes" : { "parentSpec" : "68af7760-5543-670c-1454-489b1e40d1ca" }, "attributes" : { "__targetSystem" : "ASSURANCE", "parentSpec" : "DMCAT_ProductSpecification_000326_Assurance", "ResponseTarget" : "", "RestoreTarget" : "" }, "code" : "DMCAT_ProductSpecification_000151_Assurance", "description" : "", "endDate" : "", "guid" : "88893db5-4da5-93eb-45bf-73425cf7ce51", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "Incident Management_Assurance", "productConfigurationId" : "a3T2O000000GuQXUA0", "specification" : "DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151", "startDate" : "", "status" : "Disconnect Pending", "version" : "1" }, { "additionalAttributes" : { "parentSpec" : "70e2316f-6e03-54f5-38e6-d0d3eedb7c22" }, "attributes" : { "__targetSystem" : "FULFILMENT", "name" : "Hosted UC", "CustomerFacingServiceId" : "", "id" : "", "parentSpec" : "DMCAT_ProductSpecification_000322_Fulfilment", "Quantity" : "3" }, "code" : "DMCAT_ProductSpecification_000315_Fulfilment", "description" : "", "endDate" : "", "guid" : "c362d71e-94a3-8415-528a-26f1e09cf39f", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "Feature Packs_Fulfilment", "productConfigurationId" : "a3T2O000000GuQXUA0", "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000315", "startDate" : "", "status" : "Created", "version" : "1" }, { "additionalAttributes" : { "parentSpec" : "70e2316f-6e03-54f5-38e6-d0d3eedb7c22" }, "attributes" : { "parentSpec" : "DMCAT_ProductSpecification_000322_Fulfilment", "__targetSystem" : "FULFILMENT", "VoicePlan" : "Complete Premium", "id" : "", "CustomerFacingServiceId" : "", "Number" : [ { "schemaId" : "832ab1bd-4f74-5292-981d-7004e1ba8e58", "attributes" : { "FNN" : "3333333333", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "LE" } }, { "schemaId" : "5efc4e53-4f93-df2f-8a95-afbfb462cdab", "attributes" : { "FNN" : "8282345568", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "0e129064-fdef-fa98-94ed-5be9dbb49e74", "attributes" : { "FNN" : "8282345526", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } } ] }, "code" : "DMCAT_ProductSpecification_000313_Fulfilment", "description" : "", "endDate" : "", "guid" : "033ce46a-f7de-48ca-23e6-41165dba9b65", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "UC Numbers_Fulfilment", "productConfigurationId" : "a3T2O000000GuQXUA0", "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313", "startDate" : "", "status" : "Created", "version" : "1" } ] }');
         attachmentList[0].Body = Blob.valueOf('{ "legacyAttributes" : [ ], "serviceId" : "'+servlist[0].id+'", "specifications" : [ { "additionalAttributes" : { "IPWirelessProductInstanceID" : "91699412-512f-f8bd-2950-dedb06b0d13b", "DMCAT_ProductSpecification_000263_CPEDeliveryDate" : "2019-03-14T08:00:00" }, "attributes" : { "IPWirelessProductInstanceID" : "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem" : "FULFILMENT", "SERVICEPROFILE" : "DATA_BACKUP", "MESSAGEBANK" : "NA", "INTROAM" : "NA", "CONTEXT" : "NA", "CALLCONTROL" : "NA", "AccessRole" : "Primary", "BillofMaterialID" : "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID" : "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate" : "", "ShippingRequired" : "TRUE", "IMSI" : "", "SIMSerialNumber" : "" }, "code" : "DMCAT_ProductSpecification_000263_Fulfilment", "description" : "", "endDate" : "", "guid" : "963263ce-cb0a-64cd-17d6-06b524f533e2", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "Mobile Access_Fulfilment", "productConfigurationId" : "a3T2O000000GuQXUA0", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate" : "", "status" : "Created", "version" : "1" }, { "additionalAttributes" : { }, "attributes" : { "__targetSystem" : "ASSURANCE", "ServiceManagementOption " : "1" }, "code" : "DMCAT_ProductSpecification_000326_Assurance", "description" : "", "endDate" : "", "guid" : "68af7760-5543-670c-1454-489b1e40d1ca", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "Telstra Managed Service Option 1_Assurance", "productConfigurationId" : "a3T2O000000GuQXUA0", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000326", "startDate" : "", "status" : "Disconnect Pending", "version" : "1" }, { "additionalAttributes" : { }, "attributes" : { "__targetSystem" : "BILLING", "billingSpecId" : "BSUSG001_CB", "ocsProdID" : "T22E_MIA_DATPLAN", "type" : "Domestic Data", "unitofMeasure" : "GB", "value" : "Unlimited", "RoutingServiceType" : "Mobile", "billDescription" : "Mobile Interim Access Allowance", "SERVICEID" : "61429751286", "IMSI" : "" }, "code" : "DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3", "description" : "", "endDate" : "", "guid" : "4acc4396-bddd-31c9-71f8-77930cb5a68c", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "Mobile Access_Bill_AW", "productConfigurationId" : "a3T2O000000GuQXUA0", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3", "startDate" : "", "status" : "Disconnect Pending", "version" : "1" }, { "additionalAttributes" : { }, "attributes" : { "__targetSystem" : "BILLING", "billingSpecId" : "BSUSG001_CB", "ocsProdID" : "ocsProd3", "type" : "Dummy ngUC", "unitofMeasure" : "GB", "value" : "Unlimited", "RoutingServiceType" : "Voice", "billDescription" : "ngUC Dummy Usage Specification Allowance" }, "code" : "DMCAT_ProductSpecification_000313_Billing_Allowance_000512_4", "description" : "", "endDate" : "", "guid" : "960b0d11-c4b0-21e9-d2a9-6f1aa15cd193", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "UC Numbers_Bill_AW", "productConfigurationId" : "a3T2O000000GuQXUA0", "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313_Billing_Allowance_000512_4", "startDate" : "", "status" : "Disconnect Pending", "version" : "1" }, { "additionalAttributes" : { "BSServiceTypeProductInstanceID" : "c557bd15-31b3-ccea-b9da-a9182979ac51", "DMCAT_ProductSpecification_000322_CPEDeliveryDate" : "2019-03-14T08:00:00" }, "attributes" : { "BSServiceTypeProductInstanceID" : "DMCAT_ProductSpecification_000312_Fulfilment", "__targetSystem" : "FULFILMENT", "CustomerFacingServiceId" : "", "CustomerPreferredName" : "", "DMCAT_ProductSpecification_000322_CPEDeliveryDate" : "" }, "code" : "DMCAT_ProductSpecification_000322_Fulfilment", "description" : "", "endDate" : "", "guid" : "70e2316f-6e03-54f5-38e6-d0d3eedb7c22", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "UC Site_Fulfilment", "productConfigurationId" : "a3T2O000000GuQXUA0", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000322", "startDate" : "", "status" : "Created", "version" : "1" }, { "additionalAttributes" : { "InternetProtectionSolutionProductInstanceID" : "97754883-23a9-375b-3af8-b991e4733a61" }, "attributes" : { "__targetSystem" : "FULFILMENT", "UserProtectionType" : "Web and Mail", "InternetProtectionSolutionProductInstanceID" : "DMCAT_ProductSpecification_000163_Fulfilment", "Quantity" : "3" }, "code" : "DMCAT_ProductSpecification_000162_Fulfilment", "description" : "", "endDate" : "", "guid" : "79d6ca6f-8288-aadc-8247-e939262c37d3", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "Web and Mail Internet Protection User_Fulfilment", "productConfigurationId" : "a3T2O000000GuQXUA0", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000162", "startDate" : "", "status" : "Created", "version" : "1" }, { "additionalAttributes" : { "parentSpec" : "68af7760-5543-670c-1454-489b1e40d1ca" }, "attributes" : { "__targetSystem" : "ASSURANCE", "parentSpec" : "DMCAT_ProductSpecification_000326_Assurance", "ResponseTarget" : "", "RestoreTarget" : "" }, "code" : "DMCAT_ProductSpecification_000151_Assurance", "description" : "", "endDate" : "", "guid" : "88893db5-4da5-93eb-45bf-73425cf7ce51", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "Incident Management_Assurance", "productConfigurationId" : "a3T2O000000GuQXUA0", "specification" : "DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151", "startDate" : "", "status" : "Disconnect Pending", "version" : "1" }, { "additionalAttributes" : { "parentSpec" : "70e2316f-6e03-54f5-38e6-d0d3eedb7c22" }, "attributes" : { "__targetSystem" : "FULFILMENT", "name" : "Hosted UC", "CustomerFacingServiceId" : "", "id" : "", "parentSpec" : "DMCAT_ProductSpecification_000322_Fulfilment", "Quantity" : "3" }, "code" : "DMCAT_ProductSpecification_000315_Fulfilment", "description" : "", "endDate" : "", "guid" : "c362d71e-94a3-8415-528a-26f1e09cf39f", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "Feature Packs_Fulfilment", "productConfigurationId" : "a3T2O000000GuQXUA0", "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000315", "startDate" : "", "status" : "Created", "version" : "1" }, { "additionalAttributes" : { "parentSpec" : "70e2316f-6e03-54f5-38e6-d0d3eedb7c22" }, "attributes" : { "parentSpec" : "DMCAT_ProductSpecification_000322_Fulfilment", "__targetSystem" : "FULFILMENT", "VoicePlan" : "Complete Premium", "id" : "", "CustomerFacingServiceId" : "", "Number" : [ { "schemaId" : "832ab1bd-4f74-5292-981d-7004e1ba8e58", "attributes" : { "FNN" : "3333333333", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "LE" } }, { "schemaId" : "5efc4e53-4f93-df2f-8a95-afbfb462cdab", "attributes" : { "FNN" : "8282345568", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "0e129064-fdef-fa98-94ed-5be9dbb49e74", "attributes" : { "FNN" : "8282345526", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } } ] }, "code" : "DMCAT_ProductSpecification_000313_Fulfilment", "description" : "", "endDate" : "", "guid" : "033ce46a-f7de-48ca-23e6-41165dba9b65", "includeBilling" : false, "instanceId" : "", "metadata" : { }, "name" : "UC Numbers_Fulfilment", "productConfigurationId" : "a3T2O000000GuQXUA0", "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313", "startDate" : "", "status" : "Created", "version" : "1" } ] }');
   
         attachmentList[1].ParentId = servlist[0].id;
         attachmentList[2].ParentId = servlist[2].id;
         attachmentList[1].Body = Blob.valueOf('{ "legacyAttributes": [], "serviceId": "'+servlist[0].id+'", "specifications": [ { "additionalAttributes": { "IPWirelessProductInstanceID": "91699412-512f-f8bd-2950-dedb06b0d13b", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "2019-03-14T08:00:00" }, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "FULFILMENT", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "DMCAT_ProductSpecification_000263_Fulfilment", "description": "", "endDate": "", "guid": "963263ce-cb0a-64cd-17d6-06b524f533e0", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Tele Access_Fulfilment", "productConfigurationId": "'+productconfiglistList[0].id+'", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "Created", "version": "1" }, { "additionalAttributes": { "IPWirelessProductInstanceID": "91699412-512f-f8bd-2950-dedb06b0d13b", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "2019-03-14T08:00:00" }, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "FULFILMENT", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "DMCAT_ProductSpecification_000423_Fulfilment", "description": "", "endDate": "", "guid": "963263ce-cb0a-64cd-17d6-06b524f533e1", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Tele Access_Fulfilment", "productConfigurationId": "'+productconfiglistList[0].id+'", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "Disconnect In Progress", "version": "1" }, { "additionalAttributes": { "IPWirelessProductInstanceID": "91699412-512f-f8bd-2950-dedb06b0d13b", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "2019-03-14T08:00:00" }, "attributes": { "IPWirelessProductInstanceID": "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem": "FULFILMENT", "SERVICEPROFILE": "DATA_BACKUP", "MESSAGEBANK": "NA", "INTROAM": "NA", "CONTEXT": "NA", "CALLCONTROL": "NA", "AccessRole": "Primary", "BillofMaterialID": "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID": "61429751286", "DMCAT_ProductSpecification_000263_CPEDeliveryDate": "", "ShippingRequired": "TRUE", "IMSI": "", "SIMSerialNumber": "" }, "code": "DMCAT_ProductSpecification_000263_Fulfilment", "description": "", "endDate": "", "guid": "963263ce-cb0a-64cd-17d6-06b524f533e2", "includeBilling": false, "instanceId": "", "metadata": {}, "name": "Tele Access_Fulfilment", "productConfigurationId": "'+productconfiglistList[0].id+'", "specification": "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate": "", "status": "Modified", "version": "1" } ] }');
         insert attachmentList;
         
         processList = Orchestration_TestUtility.buildProcess(false, 5, processTempList[0].id, orderList, subscriptionList,accountList[0].id,servlist[0].id); 
         
         processList[4].Order__c = ord.id; // Ord it the order which doesnit have any service
         insert processList;
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
             
        orchStepList = Orchestration_TestUtility.buildOrchStep(false,5,processList);
        orchStepList[0].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'","'+orderList[1].id+'"]}';
        orchStepList[1].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';
        orchStepList[2].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';
        orchStepList[3].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';
        orchStepList[4].JSON__c = '{"'+OrchestratorConstants.OrchestrationObjectType.Order+'":["'+orderList[0].id+'"]}';
        insert orchStepList;
         
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
    
    static testMethod void ProcessTest() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<Product_Attribute_Metadata__c> MetadataList = new List<Product_Attribute_Metadata__c>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        List<csord__Order__c> orderList2 = new List<csord__Order__c>();
        Asset aset = new Asset();
        List<Attachment> attList = new List<Attachment>();
        EnvironmentVariable__c env = new EnvironmentVariable__c();
                Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, 
                        CSPOFA__Message__c,CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name
                        FROM CSPOFA__Orchestration_Step__c where CSPOFA__Orchestration_Process__r.CSPOFA__Orchestration_Process_Template__r.Name ='Order Fulfilment Process'];
        
        MetadataList = [SELECT Id, ReferenceField__c
                     FROM Product_Attribute_Metadata__c];
        aset = [SELECT Id,AssetID__c
                 FROM Asset];
        env = [SELECT Id, Name, Value__c
               FROM EnvironmentVariable__c];
        Orchestration_GenerateTransientDataV1 GenerateTransientData = new Orchestration_GenerateTransientDataV1();
        orchStepList = GenerateTransientData.process(orchStepList);
        orderList = [SELECT Id, isTransientComplete__c
                     FROM csord__Order__c 
                     WHERE scenario_type__c =: Label.Device_Replacement]; // There is only one order like this in datasetup
         /* attList = [SELECT id , name FROM Attachment
                        Where Name = 'TransientDataDetails.json'];*/
        orderList2 = [SELECT Id, isTransientComplete__c
                     FROM csord__Order__c 
                     WHERE scenario_type__c !=: Label.Device_Replacement];
      //  boolean IsMoreThanZero = attList.size()>0 ? true : false;
        System.assertNotEquals(orchStepList[0], null);
        
        //System.assertEquals(IsMoreThanZero, true);
        
        Test.stopTest();
        
    }
    
    static testMethod void ProcessPartialTest() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<Product_Attribute_Metadata__c> MetadataList = new List<Product_Attribute_Metadata__c>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        List<csord__Order__c> orderList2 = new List<csord__Order__c>();
        insert new Attachment(Name = 'TransientDataDetails.json', ParentId = [Select Id from csord__order__c LIMIT 1].Id, Body = Blob.valueOf(''));
        Asset aset = new Asset();
        List<Attachment> attList = new List<Attachment>();
        List<csord__Service__c> servicesList = [SELECT Id
                     FROM csord__Service__c];
        EnvironmentVariable__c env = new EnvironmentVariable__c();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, 
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c];
                        orchStepList[0].JSON__c = '{"serviceIds":["'+servicesList[0].Id+'"]}';
        MetadataList = [SELECT Id, ReferenceField__c
                     FROM Product_Attribute_Metadata__c];
        aset = [SELECT Id,AssetID__c
                 FROM Asset];
        env = [SELECT Id, Name, Value__c
               FROM EnvironmentVariable__c];
        Test.startTest();
        Orchestration_GenerateTransientDataV1 GenerateTransientData = new Orchestration_GenerateTransientDataV1();
        orchStepList = GenerateTransientData.process(orchStepList);
        orderList = [SELECT Id, isTransientComplete__c
                     FROM csord__Order__c 
                     WHERE scenario_type__c =: Label.Device_Replacement]; // There is only one order like this in datasetup
          attList = [SELECT id , name FROM Attachment
                        Where Name = 'TransientDataDetails.json'];
        orderList2 = [SELECT Id, isTransientComplete__c
                     FROM csord__Order__c 
                     WHERE scenario_type__c !=: Label.Device_Replacement];
        boolean IsMoreThanZero = attList.size()>0 ? true : false;
        
        System.assertEquals(IsMoreThanZero, true);
        
        Test.stopTest();
        
    }
    
    //When service is Empty
      static testMethod void ProcessTestNOService() {
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
          //csord__Order__c ord = new csord__Order__c();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c, 
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c];
          for(csord__Order__c ord : [SELECT Id, Name, isTransientComplete__c FROM csord__Order__c]){
              ord.isTransientComplete__c = true;
              orderList.add(ord);
          }
                update orderList;        
          Test.startTest();
        Orchestration_GenerateTransientDataV1 GenerateTransientData = new Orchestration_GenerateTransientDataV1();
        orchStepList = GenerateTransientData.process(orchStepList);
        System.assertEquals(orchStepList[0].CSPOFA__Status__c, OrchestratorConstants.OrchestratorStep.Complete);
        Test.stopTest();
    }
    
    // Limits got hit
    static testMethod void breakingLimits(){
         
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, SOQL_limit__c
                         FROM Governor_Limits__c];
        governerLimit.SOQL_limit__c = '1';
        update governerLimit;
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c];
        Orchestration_GenerateTransientDataV1 GenerateTransientData = new Orchestration_GenerateTransientDataV1();
        orchStepList = GenerateTransientData.process(orchStepList);
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c];
        System.assertEquals(orchStepList[1].CSPOFA__Message__c, 'In Progress');
        Test.stopTest();
    }
    
    static testMethod void breakingLimitsInStart(){
         
        List<CSPOFA__Orchestration_Step__c> orchStepList = new List<CSPOFA__Orchestration_Step__c>();
        Governor_Limits__c governerLimit = new Governor_Limits__c();
        governerLimit = [SELECT Id, SOQL_limit__c
                         FROM Governor_Limits__c];
        governerLimit.SOQL_limit__c = '0';
        update governerLimit;
        Test.startTest();
        orchStepList = [SELECT ID, CSPOFA__Orchestration_Process__c, CSPOFA__Status__c, CSPOFA__Completed_Date__c,
                        CSPOFA__Message__c
                        FROM CSPOFA__Orchestration_Step__c];
        Orchestration_GenerateTransientDataV1 GenerateTransientData = new Orchestration_GenerateTransientDataV1();
        orchStepList = GenerateTransientData.process(orchStepList);
        boolean isNull = orchStepList == null ? true : false;
        System.assertEquals(orchStepList.isEmpty(), true);
        Test.stopTest();
    }

}