/* class Name: UpdateMRODetailsSchedulableTest
 * Description: Test class for class to enable a daily batch process to update final MRO commercial details as received from Replicator in staging object
1.  Prajakta          16/10/2020          EDGE-179345
================================================================================================================================*/

@isTest 
public class UpdateMRODetailsSchedulableTest {
 public static Governor_Limits__c governerLimit = new Governor_Limits__c();
  public static List<account> accountList = new List<account>();
  public static List<Opportunity> OpportunityList = new List<Opportunity>();
  public static List<csord__Order_Request__c> orderReqList = new List<csord__Order_Request__c>();
  public static List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
  public static List<csord__Service__c> servlist = new List<csord__Service__c>();
  public static List<csord__Order__c> orderList = new List<csord__Order__c>();
  public static list<cscfga__Product_Configuration__c> productconfiglistList = new List<cscfga__Product_Configuration__c>();
  public static list<cscfga__Product_Configuration__c> productconfiglistList1 = new List<cscfga__Product_Configuration__c>();
  public static list<csord__Solution__c> solutionList = new List<csord__Solution__c>();


 @Testsetup
  static void dataSetup() {
    governerLimit = Orchestration_TestUtility.buildLimits();

    accountList = Orchestration_TestUtility.buildAccount(false, 2);
    accountList[1].Customer_Status__c = 'Acquired';
    insert accountList;

    OpportunityList = Orchestration_TestUtility.buildOpp(false, 1, accountList);
    OpportunityList[0].Model_Change__c = false;
    insert OpportunityList;
    cscfga__Product_Definition__c productDef = new cscfga__Product_Definition__c(
      Name = 'Mobile Subscription', // Name
      csordtelcoa__Product_Type__c = 'Subscription', // Product Type
      cscfga__Description__c = 'Mobile Subscription', // Description
      cscfga__Label__c = 'Mobile Subscription', // Label
      product_Specification__c = 'DMCAT_ProductSpecification_000420' // product Specification
      
    );
    insert productDef;

    orderReqList = Orchestration_TestUtility.buildOrderRequest(true, 1);
    orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, false, 2);
    insert orderList;

    //orderList[0].csord__Primary_Order__c = orderList[0].Id;
    orderList[1].csord__Primary_Order__c = orderList[0].Id;
    update orderList;

        Orchestration_TestUtility.productconfiglistList = new list<cscfga__Product_Configuration__c>();
        productconfiglistList1 = Orchestration_TestUtility.buildProductConfiguration(true, 1);
      Orchestration_TestUtility.productconfiglistList = new list<cscfga__Product_Configuration__c>();
      productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(true, 7);
      productconfiglistList[0].ConfigurationType1__c = '';
      productconfiglistList[0].cscfga__Product_Definition__c = productDef.Id;
      productconfiglistList[0].csordtelcoa__Replaced_Product_Configuration__c = productconfiglistList1[0].id;
      update productconfiglistList[0];
      
      List<cscfga__Product_Configuration__c> pcList=new List<cscfga__Product_Configuration__c>();
      cscfga__Product_Configuration__c productConfig = new cscfga__Product_Configuration__c();
      productConfig.cscfga__Product_Definition__c = productDef.Id;
      productConfig.ConfigurationType1__c='SolutionComponent';
      productConfig.Remaining_Term__c  = 24;
      pcList.add(productConfig);
      insert pcList;

    solutionList = Orchestration_TestUtility.buildSolution(false, 1);
    solutionList[0].Name = 'TestSubsforTest0';
    insert solutionList;


    subscriptionList = Orchestration_TestUtility.buildSubscription(false, 2, accountList[0].id, orderList, productconfiglistList[0].id, solutionList[0].id);
    csord__Subscription__c sbs = [SELECT Id FROM csord__Subscription__c];
    subscriptionList[0].csord__Account__c = accountList[1].id; // account which is already in Acquired state.
    subscriptionList[0].Name = 'Unified Communication Tenancy Solution';
    subscriptionList[0].csordtelcoa__Product_Configuration__c = productconfiglistList[0].id;
    subscriptionList[0].isAggregationPoint__c = true;
    subscriptionList[0].oldServiceMSISDN__c = 'Testing';
    subscriptionList[1].csordtelcoa__Replaced_Subscription__c = sbs.Id;
    subscriptionList[0].csordtelcoa__Replaced_Subscription__c = sbs.Id;
        subscriptionList[0].autoExpiry__c = true;
        subscriptionList[1].autoExpiry__c = true;
    subscriptionList[0].TenancyID__c = 'T1002';
    csord__Subscription__c subPrdChar=new csord__Subscription__c();
        subPrdChar.name  = 'TestPrdChar';
        subPrdChar.csord__Identification__c = 'TestPrdChar';
        subPrdChar.csord__Status__c='Provisioned';
        subPrdChar.csord__Order__c = orderList[0].Id;
        subPrdChar.csordtelcoa__Product_Configuration__c=productconfiglistList[0].id;
        //subPrdChar.Billing_Account__c=billingAccount.id;
        subscriptionList.add(subPrdChar);
    
    csord__Subscription__c subFNN=new csord__Subscription__c();
        subFNN.name  = 'TestPrdCharFNN';
        subFNN.csord__Identification__c = 'TestPrdCharFNN';
        subFNN.csord__Status__c='Provisioning In Progress';
        subFNN.csord__Order__c = orderList[0].Id;
        subFNN.csordtelcoa__Product_Configuration__c=productconfiglistList[0].id;
        subscriptionList.add(subFNN);
    
        csord__Subscription__c subCOMN =new csord__Subscription__c();
        subCOMN.name  = 'TestChangeOfNum';
        subCOMN.csord__Identification__c = 'TestChangeOfNum';
        subCOMN.csord__Status__c='Provisioned';
        subCOMN.csord__Order__c = orderList[0].Id;
        subCOMN.csordtelcoa__Product_Configuration__c=productconfiglistList[0].id;
        subCOMN.serviceMSISDN__c = '61244547317';
        subCOMN.oldServiceMSISDN__c = '61244547316';
        subscriptionList.add(subCOMN);
        
      
      csord__Subscription__c solutionSubscription=new csord__Subscription__c();
      solutionSubscription.name  = 'test subs';
      solutionSubscription.csord__Identification__c = 'test identity';
      solutionSubscription.csord__Status__c = 'Pending';
      solutionSubscription.csord__Order__c =  orderList[0].Id;
      solutionSubscription.csordtelcoa__Product_Configuration__c=productConfig.id;
      solutionSubscription.csordtelcoa__Subscription_Number__c='SN-000172209';
      solutionSubscription.cssdm__solution_association__c=solutionList[0].id;
      subscriptionList.add(solutionSubscription);
      insert subscriptionList;

    servlist = Orchestration_TestUtility.buildService(false, 2, subscriptionList[0].id, orderReqList[0].id, orderList[0].id, productconfiglistList[0].id);
    servList[0].Scenario_Type__c = 'Change of Mobile Number';
        servList[1].Scenario_Type__c = 'Replace SIM';
    servList[0].Offer_Type__c = 'Committed Data';
    servList[0].Mobility_Plan__c = 'Local Data SIM BYO';
    servlist[0].csordtelcoa__Product_Configuration__c = productconfiglistList[0].id;
	
    
    csord__Service__c prdCharServ = new csord__Service__c();
        prdCharServ.name ='TestProdChar';
        prdCharServ.csord__Identification__c  = 'TestProdChar';
        prdCharServ.csord__Subscription__c = subPrdChar.Id;
        prdCharServ.csord__Status__c = 'Connected'; 
        prdCharServ.csord__Order__c = orderList[0].Id;
        servlist.add(prdCharServ);
    
    csord__Service__c prdCharFNN = new csord__Service__c();
        prdCharFNN.name ='TestProdCharFNN1';
        prdCharFNN.csord__Identification__c  = 'TestProdCharFNN';
        prdCharFNN.csord__Subscription__c = subFNN.Id;
        prdCharFNN.csord__Status__c = 'In Progress'; 
        prdCharFNN.csord__Order__c = orderList[0].Id;
       prdCharFNN.Transition_Id__c = 'a477098';
        servlist.add(prdCharFNN);
      
      csord__Service__c prdCharCOMN = new csord__Service__c();
      prdCharCOMN.name ='TestProdCharFNN';
      prdCharCOMN.csord__Identification__c  = 'TestProdCharFNN';
      prdCharCOMN.csord__Subscription__c = subCOMN.Id;
      prdCharCOMN.csord__Status__c = 'In progress'; 
      prdCharCOMN.csord__Order__c = orderList[0].Id;
      prdCharCOMN.Transition_Id__c = 'a456789';
      prdCharCOMN.csordtelcoa__Product_Configuration__c = productconfiglistList[0].id;
      servlist.add(prdCharCOMN);
      
      csord__Service__c serv= new csord__Service__c();
      serv.name = 'MigrationService';
      serv.csord__Subscription__c=solutionSubscription.id;
      serv.csord__Identification__c='Test';
      serv.Transition_Id__c = '123456789';
      servlist.add(serv);
      insert servlist;

       List<Attachment> attachmentList = Orchestration_TestUtility.buildAttachment(false, 1, servlist, productconfiglistList[0].id);
    attachmentList[0].Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+servlist[0].Id+'","specifications":[{"additionalAttributes":{},"attributes":{"IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment","__targetSystem":"FULFILMENT","SERVICEPROFILE":"DATA_BACKUP","MESSAGEBANK":"NA","INTROAM":"NA","CONTEXT":"NA","CALLCONTROL":"NA","AccessRole":"Primary","BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b","SERVICEID":"61429751286","DMCAT_ProductSpecification_000263_CPEDeliveryDate":"","ShippingRequired":"TRUE","IMSI":"","SIMSerialNumber":""},"code":"DMCAT_ProductSpecification_000053_Fulfilment","description":"","endDate":"","guid":"G001","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2O000000GuQXUA0","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"IMSI":"Test"},"attributes":{"parentSpec":"DMCAT_ProductSpecification_000028_Fulfilment","ManagedRadiusProductInstanceID":"DMCAT_ProductSpecification_000053_Fulfilment","__targetSystem":"FULFILMENT","GlobalRoaming":"FALSE","APNtype":"Shared","CustomerFacingServiceId":"","RequiredPoolTypes":"Static"},"code":"DMCAT_ProductSpecification_000622","description":"","endDate":"","guid":"4d9f3701-912a-fc43-48d7-b3b565a135d0","includeBilling":false,"instanceId":"","metadata":{},"name":"IP Wireless_Fulfilment","productConfigurationId":"a3T2O000000JFlPUAW","specification":"DMCAT_ProductSpecification_000028DMCAT_ProductSpecification_000018","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"IMSI":"Test"},"attributes":{"IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment","__targetSystem":"BILLING","SERVICEPROFILE":"DATA_BACKUP","MESSAGEBANK":"NA","INTROAM":"NA","CONTEXT":"NA","CALLCONTROL":"NA","AccessRole":"Primary","BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b","SERVICEID":"61429751286","DMCAT_ProductSpecification_000263_CPEDeliveryDate":"","ShippingRequired":"TRUE","IMSI":"","SIMSerialNumber":""},"code":"DMCAT_ProductSpecification_000028_Fulfilment","description":"","endDate":"","guid":"G004","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2O000000GuQXUA0","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{"IMSI":"Test"},"attributes":{"IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment","__targetSystem":"FULFILMENT","SERVICEPROFILE":"DATA_BACKUP","MESSAGEBANK":"NA","INTROAM":"NA","CONTEXT":"NA","CALLCONTROL":"NA","AccessRole":"Primary","BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b","SERVICEID":"61429751286","DMCAT_ProductSpecification_000263_CPEDeliveryDate":"","ShippingRequired":"TRUE","IMSI":"","SIMSerialNumber":""},"code":"DMCAT_ProductSpecification_000018_Fulfilment","description":"","endDate":"","guid":"G005","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2O000000GuQXUA0","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263","startDate":"","status":"Disconnected","version":"1"},{"additionalAttributes":{"IMSI":"Test"},"attributes":{"IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment","__targetSystem":"FULFILMENT","SERVICEPROFILE":"DATA_BACKUP","MESSAGEBANK":"NA","INTROAM":"NA","CONTEXT":"NA","CALLCONTROL":"NA","AccessRole":"Primary","BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b","SERVICEID":"61429751286","DMCAT_ProductSpecification_000263_CPEDeliveryDate":"","ShippingRequired":"TRUE","IMSI":"","SIMSerialNumber":""},"code":"DMCAT_ProductSpecification_000313_Billing","description":"","endDate":"","guid":"G006","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2O000000GuQXUA0","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"IMSI":"Test"},"attributes":{"IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment","__targetSystem":"BILLING","SERVICEPROFILE":"DATA_BACKUP","MESSAGEBANK":"NA","INTROAM":"NA","CONTEXT":"NA","CALLCONTROL":"NA","AccessRole":"Primary","BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b","SERVICEID":"61429751286","DMCAT_ProductSpecification_000263_CPEDeliveryDate":"","ShippingRequired":"TRUE","IMSI":"","SIMSerialNumber":"","billingSpecId":"BSUSG003_CB"},"code":"DMCAT_ProductSpecification_000537_Fulfilment","description":"","endDate":"","guid":"G007","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2O000000GuQXUA0","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{"IMSI":"Test"},"attributes":{"IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment","__targetSystem":"BILLING","SERVICEPROFILE":"DATA_BACKUP","MESSAGEBANK":"NA","INTROAM":"NA","CONTEXT":"NA","CALLCONTROL":"NA","AccessRole":"Primary","BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b","SERVICEID":"61429751286","DMCAT_ProductSpecification_000263_CPEDeliveryDate":"","ShippingRequired":"TRUE","IMSI":"","SIMSerialNumber":""},"code":"DMCAT_ProductSpecification_000690_Fulfilment","description":"","endDate":"","guid":"G008","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2O000000GuQXUA0","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{"IMSI":"Test"},"attributes":{"IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment","__targetSystem":"BILLING","SERVICEPROFILE":"DATA_BACKUP","MESSAGEBANK":"NA","INTROAM":"NA","CONTEXT":"NA","CALLCONTROL":"NA","AccessRole":"Primary","BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b","SERVICEID":"61429751286","DMCAT_ProductSpecification_000263_CPEDeliveryDate":"","ShippingRequired":"TRUE","IMSI":"","SIMSerialNumber":"","billingSpecId":"BSUSG001_CB"},"code":"DMCAT_ProductSpecification_000966_Fulfilment","description":"","endDate":"","guid":"G009","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2O000000GuQXUA0","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{"CustomerFacingServiceId":"test","tenancyId":"test1","IMSI":"Test"},"attributes":{"IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment","__targetSystem":"BILLING","SERVICEPROFILE":"DATA_BACKUP","MESSAGEBANK":"NA","INTROAM":"NA","CONTEXT":"NA","CALLCONTROL":"NA","AccessRole":"Primary","BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b","SERVICEID":"61429751286","DMCAT_ProductSpecification_000263_CPEDeliveryDate":"","ShippingRequired":"TRUE","IMSI":"","SIMSerialNumber":"","billingSpecId":"BSUSG001_CB"},"code":"DMCAT_ProductSpecification_000263_Fulfilment","description":"","endDate":"","guid":"G010","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2O000000GuQXUA0","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{"CustomerFacingServiceId":"test","tenancyId":"test1","IMSI":"Test"},"attributes":{"IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment","__targetSystem":"BILLING","SERVICEPROFILE":"DATA_BACKUP","MESSAGEBANK":"NA","INTROAM":"NA","CONTEXT":"NA","CALLCONTROL":"NA","AccessRole":"Primary","BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b","SERVICEID":"61429751286","DMCAT_ProductSpecification_000263_CPEDeliveryDate":"","ShippingRequired":"TRUE","SIMSerialNumber":"","billingSpecId":"BSUSG001_CB","customRate":[{"schemaId":"37a354d3-1aac-7718-5439-7c941add6706","attributes":{"rangeFrom":"11","rangeTo":"20","price":"5.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6946"}},{"schemaId":"e84bb967-88f0-129a-8b0b-4d77900eb7ed","attributes":{"rangeFrom":"501","rangeTo":"99999","price":"5.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6952"}},{"schemaId":"eda8a53d-ae35-6485-d6fd-accbf47ebccb","attributes":{"rangeFrom":"201","rangeTo":"500","price":"5.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6950"}},{"schemaId":"050bb815-38b3-caba-29e2-7ed80785468b","attributes":{"rangeFrom":"51","rangeTo":"200","price":"5.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6949"}}]},"code":"DMCAT_ProductSpecification_000313_Billing","description":"","endDate":"","guid":"G011","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2O000000GuQXUA0","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263","startDate":"","status":"Modified","version":"1"},{"additionalAttributes":{"CustomerFacingServiceId":"test","tenancyId":"test1","IMSI":"Test"},"attributes":{"IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment","__targetSystem":"BILLING","SERVICEPROFILE":"DATA_BACKUP","MESSAGEBANK":"NA","INTROAM":"NA","CONTEXT":"NA","CALLCONTROL":"NA","AccessRole":"Primary","BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b","SERVICEID":"61429751286","DMCAT_ProductSpecification_000263_CPEDeliveryDate":"","ShippingRequired":"TRUE","IMSI":"Test","SIMSerialNumber":"",'
    +'"billingSpecId":"BSUSG001_CB","CustomerFacingServiceId":"test","tenancyId":"test1"},"code":"DMCAT_ProductSpecification_000313_Billing","description":"","endDate":"","guid":"G012","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2O000000GuQXUA0","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263","startDate":"","status":"Disconnect","version":"1"},{"additionalAttributes":{"IMSI":"Test"},"attributes":{"IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment","__targetSystem":"BILLING","SERVICEPROFILE":"DATA_BACKUP","MESSAGEBANK":"NA","INTROAM":"NA","CONTEXT":"NA","CALLCONTROL":"NA","AccessRole":"Primary","BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b","SERVICEID":"61429751286","DMCAT_ProductSpecification_000263_CPEDeliveryDate":"","ShippingRequired":"TRUE","IMSI":"Test","SIMSerialNumber":"","billingSpecId":"BSUSG001_CB","featureID":"featureValue","quantity":"2","rateExcludeGST":"234","monthlyPrice":300,"billDescription":"billDescriptionval","frequency":"2","currency":"10","billInAdvance":"20","prorate":"20","ocsProdID":"ocsProdIDval","billingSubtype":"subtype","taxTreatment":"Valid","otcDescription":"otcDescriptionVal","creditDescription":"creditDescriptionval", "refundFlag":"true", "ContractTerm":12, "contractType":"Purchase",  "chargeId":"Purchase", "externalId":"Purchase"},'
    +'"code":"DMCAT_ProductSpecification_000313_Billing_Allowance_000494_3","description":"","endDate":"","guid":"G013","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2O000000GuQXUA0","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263","startDate":"","status":"In Progress","version":"1"}]}');
    
    System.debug(attachmentList[0].Body.toString() + '===>attachmentList[0].Body.toString()');
    
    Attachment attprdchr= new Attachment();
    attprdchr.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+prdCharServ.id+'","specifications":[{"additionalAttributes":{"CustomerFacingServiceId":"61474663325","parentSpec":"dd7a2442-bd58-20e6-891a-2fd078b3d210","IMSI":"5286475123"},"attributes":{"__targetSystem":"FULFILMENT","IPWirelessProductInstanceID":"NA","BillofMaterialID":"NA","AccessRole":"Primary","CONTEXT":"CUSTOMER","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","SKU":"100119211","SuspensionContext":"NA","MESSAGEBANK":"3G Standard Retail","CustomerFacingServiceId":"","ShippingRequired":"TRUE","IMSI":"","SERVICEPROFILE":"NORMAL","PlanType":"Voice and Data"},"code":"DMCAT_ProductSpecification_000263_Fulfilment","description":"Mobile Access_Fulfilment","endDate":"","guid":"d5291cc4-f4a6-114e-de4d-369bcdf080f8","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","ocsProdID":"T22E_IR_USAGE","currency":"AUD","type":"OC","billingSubtype":"IR","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","billDescription":"IR Pay as you go charge","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000263_DMCAT_NonRecurringCharge_000601_108","chargeId":"DMCAT_NonRecurringCharge_000601"},"code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","description":"Mobile Access_Billing_NonRecurringCharge_000601","endDate":"","guid":"20e0d4f9-d12d-d5f4-7478-b424f5a34f1e","includeBilling":false,"instanceId":"","metadata":{},"name":"263_NRC_601","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"FULFILMENT"},"code":"DMCAT_ProductSpecification_000420_Fulfilment","description":"Mobility_Fulfilment","endDate":"","guid":"dd7a2442-bd58-20e6-891a-2fd078b3d210","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobility_Fulfilment","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","currency":"AUD","quantity":"1","chargeId":"DMCAT_RecurringCharge_000669","rateExcludeGST":13.63,"type":null,"frequency":"Monthly","billingSpecId":"BSRC001_CB","billInAdvance":"true","prorate":"false","billDescription":"International call pack - premium","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000669_102"},"code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000669","description":"Mobility_Billing_RecurringCharge_000669","endDate":"","guid":"39075166-8924-2c0b-e8e9-2adfa9cb48fb","includeBilling":false,"instanceId":"","metadata":{},"name":"420_RC_669","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000669","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","value":"40","unitofMeasure":"GB","type":"FairPlay Data","ocsProdID":"T22EM_PLAN-S","billingSpecId":"BSUSG001_CB","billDescription":"Includes 40 GB Domestic Data+Unlimited Standard Voice+SMS+MMS","chargeId":"DMCAT_Allowance_000637"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000637","description":"Mobility_Billing_DMCAT_Allowance_000637","endDate":"","guid":"ed810ffb-a419-74b6-867e-c10f0baab01d","includeBilling":false,"instanceId":"","metadata":{},"name":"420_AW_637","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000637_7","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","quantity":"1","DiscountedPrice":"","type":"Voice and Data","currency":"AUD","frequency":"Monthly","billingSpecId":"BSRC001_CB","billInAdvance":"true","prorate":"false","billDescription":"Bring your own - local plan","rateExcludeGST":"50.00","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_4911","chargeId":"DMCAT_RecurringCharge_000654"},"code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","description":"Mobility_Billing_RecurringCharge_000654","endDate":"","guid":"27b89bb2-431c-16cd-bd54-650f33dde86e","includeBilling":false,"instanceId":"","metadata":{},"name":"420_RC_654","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","value":"Premium","type":"International Direct Dial","ocsProdID":"T22E_EMOB_IDD2","billingSpecId":"BSUSG001_CB","billDescription":"International call pack - premium","chargeId":"DMCAT_Allowance_000643"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000644","description":"Mobility_Billing_DMCAT_Allowance_000644","endDate":"","guid":"7e8d7df0-ecdc-1e49-03ff-d08eda855fdd","includeBilling":false,"instanceId":"","metadata":{},"name":"420_AW_644","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000644_27","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_IRDAYPASS","type":"International Roaming Data","unitofMeasure":"MB","value":"200","billingSubtype":"IR","billDescription":"IR Day Pass","chargeId":"DMCAT_Allowance_000606"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000606","description":"Mobility_Billing_DMCAT_Allowance_000606","endDate":"","guid":"2dd0a1d6-8ed3-edf5-652f-26a3b296d1df","includeBilling":false,"instanceId":"","metadata":{},"name":"263_AW_606","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000606_5","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_IR_AUTOTOPUP","type":"International Roaming Data","unitofMeasure":"MB","value":"500","billingSubtype":"IR","billDescription":"IR Data Topup","chargeId":"DMCAT_Allowance_000607"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000607","description":"Mobility_Billing_DMCAT_Allowance_000607","endDate":"","guid":"88684d27-205d-528a-488e-151d84b4503e","includeBilling":false,"instanceId":"","metadata":{},"name":"263_AW_607","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000607_6","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"parentSpec":"0a4f2805-1d50-7767-fa82-8ff9435913e7"},"attributes":{"__targetSystem":"ASSURANCE","parentSpec":"DMCAT_ProductSpecification_000326_Assurance","ResponseTarget":"SLA0010001","RestoreTarget":"SLA0010006"},"code":"DMCAT_ProductSpecification_000151_Assurance","description":"Incident Management_Assurance","endDate":"","guid":"a08b1510-b8b6-4d1d-6899-14bf513d68e4","includeBilling":false,"instanceId":"","metadata":{},"name":"151_ASR","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151_2","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"ServiceManagementOption":"1","__targetSystem":"ASSURANCE"},"code":"DMCAT_ProductSpecification_000326_Assurance","description":"Telstra Managed Service Option 1_Assurance","endDate":"","guid":"0a4f2805-1d50-7767-fa82-8ff9435913e7","includeBilling":false,"instanceId":"","metadata":{},"name":"326_ASR","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductOffering_000420DMCAT_ProductSpecification_000326","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"ASSURANCE"},"code":"DMCAT_ProductSpecification_000421_Assurance","description":"Mobile Device Management_Assurance","endDate":"","guid":"c67e4144-dc39-6bd2-85b1-a8a40673cb31","includeBilling":false,"instanceId":"","metadata":{},"name":"421_ASR","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000421","startDate":"","status":"Created","version":"1"}]}');
    attprdchr.Name = 'ServiceSpecifications.json';
    attprdchr.ParentId = prdCharServ.Id;
    attachmentList.add(attprdchr);    
    
    Attachment attprdFNN= new Attachment();
        attprdFNN.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+prdCharFNN.id+'","specifications":[{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","taxTreatment":"GST Applicable","billingSubtype":"HWM","currency":"AUD","type":"RC","billingSpecId":"BSUSG003_CB","featureID":"ucUsers","billDescription":"Cloud user","customRate":[{"schemaId":"8a887be9-e2c0-aedb-f047-aa7bd636408b","attributes":{"rangeFrom":"1","rangeTo":"10","price":"3.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000813_6971"}},{"schemaId":"5feac23a-15b7-159e-0cb8-0af3745d2939","attributes":{"rangeFrom":"11","rangeTo":"20","price":"3.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000813_6972"}},{"schemaId":"bdc2f1af-eb82-839b-2b7f-e382edbd0418","attributes":{"rangeFrom":"21","rangeTo":"50","price":"3.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000813_6973"}},{"schemaId":"48462240-1733-835c-54d4-2f83eb88298c","attributes":{"rangeFrom":"51","rangeTo":"200","price":"3.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000813_6974"}},{"schemaId":"761f16d7-27de-ad36-d7cf-77ec5e5c855c","attributes":{"rangeFrom":"201","rangeTo":"500","price":"3.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000813_6975"}},{"schemaId":"98039cd9-a053-a575-d235-c73d6fa62cf6","attributes":{"rangeFrom":"501","rangeTo":"99999","price":"3.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000813_6976"}}]},"code":"DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000813","description":"Business Calling_Billing_RecurringCharge_000813","endDate":"","guid":"997878ff-9abe-3023-e5e1-a8b19592dec4","includeBilling":false,"instanceId":"","metadata":{},"name":"871_RC_813","productConfigurationId":"a3T2N0000003htFUAQ","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000813","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","taxTreatment":"GST Applicable","billingSubtype":"HWM","currency":"AUD","type":"RC","billingSpecId":"BSUSG003_CB","featureID":"Hosted UC","billDescription":"Cloud user add-on - unified communications","customRate":[{"schemaId":"4516b180-3248-22c0-cb2c-76bbb638483b","attributes":{"rangeFrom":"51","rangeTo":"200","price":"6.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000816_6977"}},{"schemaId":"316b741a-7af0-f123-7200-1c83cd607050","attributes":{"rangeFrom":"501","rangeTo":"99999","price":"6.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000816_6982"}},{"schemaId":"112ab8b4-1daa-b2ba-0b13-4b6aca254fb7","attributes":{"rangeFrom":"201","rangeTo":"500","price":"6.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000816_6981"}},{"schemaId":"a8e68904-3188-d659-ab09-56f513c6fcbf","attributes":{"rangeFrom":"21","rangeTo":"50","price":"6.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000816_6980"}},{"schemaId":"4cf56aa0-f04f-c21e-3d21-2d4df51c3d76","attributes":{"rangeFrom":"11","rangeTo":"20","price":"6.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000816_6979"}},{"schemaId":"19cea5ed-d550-b395-64e9-3fade6adf6a7","attributes":{"rangeFrom":"1","rangeTo":"10","price":"6.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000816_6978"}}]},"code":"DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000816","description":"Business Calling_Billing_RecurringCharge_000816","endDate":"","guid":"6f3812f3-1db5-e67b-edc2-63ca7128a38d","includeBilling":false,"instanceId":"","metadata":{},"name":"871_RC_816","productConfigurationId":"a3T2N0000003htFUAQ","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000816","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","taxTreatment":"GST Applicable","billingSubtype":"HWM","currency":"AUD","type":"RC","billingSpecId":"BSUSG003_CB","featureID":"ucAutoAttendants","billDescription":"Group feature - auto attendant","customRate":[{"schemaId":"56a360f8-80a7-8b6d-cf99-a92ca3e545ce","attributes":{"rangeFrom":"11","rangeTo":"20","price":"5.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6946"}},{"schemaId":"85683ae9-18ae-998d-01ef-9962eaed2a73","attributes":{"rangeFrom":"1","rangeTo":"10","price":"5.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6947"}},{"schemaId":"cd30e9b0-f9a2-4491-a846-08af6b6a1732","attributes":{"rangeFrom":"21","rangeTo":"50","price":"5.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6948"}},{"schemaId":"da2c4355-363f-921a-321b-98ae50dee49d","attributes":{"rangeFrom":"51","rangeTo":"200","price":"5.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6949"}},{"schemaId":"18bf7bdb-4595-79d0-fddb-2ec4dd3248f2","attributes":{"rangeFrom":"201","rangeTo":"500","price":"5.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6950"}},{"schemaId":"bc2e5ae6-78e7-83c0-6c11-e768ef42cdd7","attributes":{"rangeFrom":"501","rangeTo":"99999","price":"5.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6952"}}]},"code":"DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000810","description":"Business Calling_Billing_RecurringCharge_000810","endDate":"","guid":"22140270-069d-824d-6c23-b1f1c22d0e51","includeBilling":false,"instanceId":"","metadata":{},"name":"871_RC_810","productConfigurationId":"a3T2N0000003htFUAQ","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000810","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","taxTreatment":"GST Applicable","billingSubtype":"HWM","currency":"AUD","type":"RC","billingSpecId":"BSUSG003_CB","featureID":"ucHuntGroups","billDescription":"Group feature - hunt group","customRate":[{"schemaId":"c703e5c3-7853-58a1-680e-36e8435b1b84","attributes":{"rangeFrom":"1","rangeTo":"10","price":"5.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000811_7020"}},{"schemaId":"a20997ca-fcd9-9f35-8080-09803ae395ec","attributes":{"rangeFrom":"11","rangeTo":"20","price":"5.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000811_7021"}},{"schemaId":"cb690468-273e-480d-4e2f-80f15d8f4821","attributes":{"rangeFrom":"21","rangeTo":"50","price":"5.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000811_7022"}},{"schemaId":"2359d186-2348-8983-1a28-968148659e6e","attributes":{"rangeFrom":"51","rangeTo":"200","price":"5.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000811_7023"}},{"schemaId":"3dc387d2-d48a-13fd-51c9-74fcfafc741f","attributes":{"rangeFrom":"201","rangeTo":"500","price":"5.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000811_7024"}},{"schemaId":"068a85f1-91ca-82ca-732a-3637070472fb","attributes":{"rangeFrom":"501","rangeTo":"99999","price":"5.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000811_7025"}}]},"code":"DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000811","description":"Business Calling_Billing_RecurringCharge_000811","endDate":"","guid":"a529da14-23fb-d2cf-16b4-e1a2c2ae1389","includeBilling":false,"instanceId":"","metadata":{},"name":"871_RC_811","productConfigurationId":"a3T2N0000003htFUAQ","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000811","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","taxTreatment":"GST Applicable","billingSubtype":"HWM","currency":"AUD","type":"RC","billingSpecId":"BSUSG003_CB","featureID":"concurrencyLimit","customRate":[{"schemaId":"ab911548-7c8b-d73b-2b3c-3aa3d17c6933","attributes":{"rangeFrom":"1","rangeTo":"10","price":"20.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_6959"}},{"schemaId":"2194574d-2817-5ca3-0f54-9cfe4bd22ee2","attributes":{"rangeFrom":"21","rangeTo":"50","price":"20.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_6961"}},{"schemaId":"dc16e0e0-74be-35ed-bc71-6ac31256b5fd","attributes":{"rangeFrom":"11","rangeTo":"20","price":"20.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_6960"}},{"schemaId":"1eaea7ee-e599-630b-724e-736691723c79","attributes":{"rangeFrom":"51","rangeTo":"200","price":"18.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_6962"}},{"schemaId":"9958da67-cb32-9bd6-0e2a-9e7d6b40e0c2","attributes":{"rangeFrom":"201","rangeTo":"500","price":"18.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_6963"}},{"schemaId":"38466da7-6e61-03ae-4b9e-eeaf9b2581c8","attributes":{"rangeFrom":"501","rangeTo":"99999","price":"17.00","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_6964"}}],"callingPlans":"Standard","billDescription":"Standard calling plan - shared line","concurrencyLimitMode":"Shared Line"},"code":"DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000814","description":"Business Calling_Billing_RecurringCharge_000814","endDate":"","guid":"4b695fe3-efca-37da-ce41-02d9d79aa512","includeBilling":false,"instanceId":"","metadata":{},"name":"871_RC_814","productConfigurationId":"a3T2N0000003htFUAQ","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000814","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG004_CB","type":"Fixed Voice","value":"Fixed Voice Plan - Standard","billDescription":"Included PayG","ocsProdID":"T22E_FVOICE-S"},"code":"DMCAT_ProductSpecification_000871_Billing_Allowance_000876","description":"Business Calling UC Plan Allowance_Billing_DMCAT_Allowance_000876","endDate":"","guid":"fd4de340-cbde-88d9-8e5d-2cc188a8bee6","includeBilling":false,"instanceId":"","metadata":{},"name":"871_AW_876","productConfigurationId":"a3T2N0000003htFUAQ","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_Allowance_000825_87","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"BSTenancyProductInstanceId":"c8031013-24a7-1009-c652-2cfcd944b3bd"},"attributes":{"__targetSystem":"FULFILMENT","BSTenancyProductInstanceId":"DMCAT_ProductSpecification_000311_Fulfilment","type":"ucServiceSiteAgnosticConcurrencyOffer","Number":[{"schemaId":"e8da8f27-adf1-16f2-8114-db8d73be4425","attributes":{"FNN":"61244547317","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}}],"concurrencyLimitMode":"explicit","CustomerFacingServiceId":"","NetworkServiceId":""},"code":"DMCAT_ProductSpecification_000871_Fulfilment","description":"Business Calling_Fulfilment","endDate":"","guid":"c0e71224-7363-88d5-6ad6-a7f73ec67db3","includeBilling":false,"instanceId":"","metadata":{},"name":"Business Calling_Fulfilment","productConfigurationId":"a3T2N0000003htFUAQ","specification":"DMCAT_ProductSpecification_000871","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"ASSURANCE","parentSpec":"DMCAT_ProductSpecification_000871_Assurance","ResponseTarget":"SLA0010001","RestoreTarget":"SLA0010002"},"code":"DMCAT_ProductSpecification_000151_Assurance","description":"Incident Management_Assurance","endDate":"","guid":"56121be1-d4c7-8b8b-ae98-eb9734987364","includeBilling":false,"instanceId":"","metadata":{},"name":"151_ASR","productConfigurationId":"a3T2N0000003htFUAQ","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000151","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"ASSURANCE","ServiceManagementOption":"1"},"code":"DMCAT_ProductSpecification_000326_Assurance","description":"Telstra Managed Service Option 1_Assurance","endDate":"","guid":"133e533c-492a-6709-b2e8-388e24b111b6","includeBilling":false,"instanceId":"","metadata":{},"name":"326_ASR","productConfigurationId":"a3T2N0000003htFUAQ","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000326","startDate":"","status":"Created","version":"1"}]}');
        attprdFNN.Name = 'ServiceSpecifications.json';
        attprdFNN.ParentId = prdCharFNN.Id;
        attachmentList.add(attprdFNN);
    
        Attachment attprdchrCOM= new Attachment();
    attprdchrCOM.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+prdCharCOMN.id+'","specifications":[{"additionalAttributes":{"CustomerFacingServiceId":"61474663325","parentSpec":"dd7a2442-bd58-20e6-891a-2fd078b3d210","IMSI":"5286475123"},"attributes":{"__targetSystem":"FULFILMENT","IPWirelessProductInstanceID":"NA","BillofMaterialID":"NA","AccessRole":"Primary","CONTEXT":"CUSTOMER","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","SKU":"100119211","SuspensionContext":"NA","MESSAGEBANK":"3G Standard Retail","CustomerFacingServiceId":"","ShippingRequired":"TRUE","IMSI":"","SERVICEPROFILE":"NORMAL","PlanType":"Voice and Data"},"code":"DMCAT_ProductSpecification_000263_Fulfilment","description":"Mobile Access_Fulfilment","endDate":"","guid":"d5291cc4-f4a6-114e-de4d-369bcdf080f8","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","ocsProdID":"T22E_IR_USAGE","currency":"AUD","type":"OC","billingSubtype":"IR","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","billDescription":"IR Pay as you go charge","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000263_DMCAT_NonRecurringCharge_000601_108","chargeId":"DMCAT_NonRecurringCharge_000601"},"code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","description":"Mobile Access_Billing_NonRecurringCharge_000601","endDate":"","guid":"20e0d4f9-d12d-d5f4-7478-b424f5a34f1e","includeBilling":false,"instanceId":"","metadata":{},"name":"263_NRC_601","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"FULFILMENT"},"code":"DMCAT_ProductSpecification_000420_Fulfilment","description":"Mobility_Fulfilment","endDate":"","guid":"dd7a2442-bd58-20e6-891a-2fd078b3d210","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobility_Fulfilment","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","currency":"AUD","quantity":"1","chargeId":"DMCAT_RecurringCharge_000669","rateExcludeGST":13.63,"type":null,"frequency":"Monthly","billingSpecId":"BSRC001_CB","billInAdvance":"true","prorate":"false","billDescription":"International call pack - premium","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000669_102"},"code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000669","description":"Mobility_Billing_RecurringCharge_000669","endDate":"","guid":"39075166-8924-2c0b-e8e9-2adfa9cb48fb","includeBilling":false,"instanceId":"","metadata":{},"name":"420_RC_669","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000669","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","value":"40","unitofMeasure":"GB","type":"FairPlay Data","ocsProdID":"T22EM_PLAN-S","billingSpecId":"BSUSG001_CB","billDescription":"Includes 40 GB Domestic Data+Unlimited Standard Voice+SMS+MMS","chargeId":"DMCAT_Allowance_000637"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000637","description":"Mobility_Billing_DMCAT_Allowance_000637","endDate":"","guid":"ed810ffb-a419-74b6-867e-c10f0baab01d","includeBilling":false,"instanceId":"","metadata":{},"name":"420_AW_637","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000637_7","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","quantity":"1","DiscountedPrice":"","type":"Voice and Data","currency":"AUD","frequency":"Monthly","billingSpecId":"BSRC001_CB","billInAdvance":"true","prorate":"false","billDescription":"Bring your own - local plan","rateExcludeGST":"50.00","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_4911","chargeId":"DMCAT_RecurringCharge_000654"},"code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","description":"Mobility_Billing_RecurringCharge_000654","endDate":"","guid":"27b89bb2-431c-16cd-bd54-650f33dde86e","includeBilling":false,"instanceId":"","metadata":{},"name":"420_RC_654","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","value":"Premium","type":"International Direct Dial","ocsProdID":"T22E_EMOB_IDD2","billingSpecId":"BSUSG001_CB","billDescription":"International call pack - premium","chargeId":"DMCAT_Allowance_000643"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000644","description":"Mobility_Billing_DMCAT_Allowance_000644","endDate":"","guid":"7e8d7df0-ecdc-1e49-03ff-d08eda855fdd","includeBilling":false,"instanceId":"","metadata":{},"name":"420_AW_644","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000644_27","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_IRDAYPASS","type":"International Roaming Data","unitofMeasure":"MB","value":"200","billingSubtype":"IR","billDescription":"IR Day Pass","chargeId":"DMCAT_Allowance_000606"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000606","description":"Mobility_Billing_DMCAT_Allowance_000606","endDate":"","guid":"2dd0a1d6-8ed3-edf5-652f-26a3b296d1df","includeBilling":false,"instanceId":"","metadata":{},"name":"263_AW_606","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000606_5","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_IR_AUTOTOPUP","type":"International Roaming Data","unitofMeasure":"MB","value":"500","billingSubtype":"IR","billDescription":"IR Data Topup","chargeId":"DMCAT_Allowance_000607"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000607","description":"Mobility_Billing_DMCAT_Allowance_000607","endDate":"","guid":"88684d27-205d-528a-488e-151d84b4503e","includeBilling":false,"instanceId":"","metadata":{},"name":"263_AW_607","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000607_6","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"parentSpec":"0a4f2805-1d50-7767-fa82-8ff9435913e7"},"attributes":{"__targetSystem":"ASSURANCE","parentSpec":"DMCAT_ProductSpecification_000326_Assurance","ResponseTarget":"SLA0010001","RestoreTarget":"SLA0010006"},"code":"DMCAT_ProductSpecification_000151_Assurance","description":"Incident Management_Assurance","endDate":"","guid":"a08b1510-b8b6-4d1d-6899-14bf513d68e4","includeBilling":false,"instanceId":"","metadata":{},"name":"151_ASR","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151_2","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"ServiceManagementOption":"1","__targetSystem":"ASSURANCE"},"code":"DMCAT_ProductSpecification_000326_Assurance","description":"Telstra Managed Service Option 1_Assurance","endDate":"","guid":"0a4f2805-1d50-7767-fa82-8ff9435913e7","includeBilling":false,"instanceId":"","metadata":{},"name":"326_ASR","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductOffering_000420DMCAT_ProductSpecification_000326","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"ASSURANCE"},"code":"DMCAT_ProductSpecification_000421_Assurance","description":"Mobile Device Management_Assurance","endDate":"","guid":"c67e4144-dc39-6bd2-85b1-a8a40673cb31","includeBilling":false,"instanceId":"","metadata":{},"name":"421_ASR","productConfigurationId":"a3T2N0000004aIEUAY","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000421","startDate":"","status":"Created","version":"1"}]}');
    attprdchrCOM.Name = 'ServiceSpecifications.json';
    attprdchrCOM.ParentId = prdCharCOMN.Id;
    attachmentList.add(attprdchrCOM);              
    insert attachmentList;

      List<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>();
     cscfga__Attribute__c attr1 = ProductTestFactory.buildAttribute('OC', '100.00', productconfiglistList[0].id);
     cscfga__Attribute__c attr2 = ProductTestFactory.buildAttribute('ContractTerm', '3', productconfiglistList[0].id);
     attList.add(attr1);
     attList.add(attr2);
     insert attList;
                                      
 }
   
static testMethod void UpdateMRODetailstest() 
    {
         Test.startTest();
        List<csord__Service__c>servlist = [select id, Transition_Id__c,expiryDuration__c,csord__Status__c,csord__Subscription__c,csord__Subscription__r.triggerBill_RTB__c,csord__Subscription__r.csord__Status__c,csord__Subscription__r.expiryDuration__c,csord__Order__c  from csord__Service__c where name ='TestProdCharFNN' LIMIT 1 ];
        
        List<Service_Add_On__c> addonList= new List<Service_Add_On__c>();
        
        Service_Add_On__c add1 =  new Service_Add_On__c();
        add1.Instance_Id__c = servlist[0].Transition_Id__c;
        add1.Final_Remaining_Term__c = 2;
        add1.Final_Remaining_Amount__c = 300;
        add1.Monthly_Amount__c = 20;
        add1.Device_Id__c ='1234';
        add1.Status__c = 'Processed';
        add1.isMicaDependency__c=true;
        addonList.add(add1);
        
        List<csord__Service__c>servlist1 = [select id, Transition_Id__c,expiryDuration__c,csord__Status__c,csord__Subscription__c,csord__Subscription__r.triggerBill_RTB__c,csord__Subscription__r.csord__Status__c,csord__Subscription__r.expiryDuration__c,csord__Order__c  from csord__Service__c where name ='TestProdCharFNN1'LIMIT 1 ];

        Service_Add_On__c add2 =  new Service_Add_On__c();
        add2.Instance_Id__c = servlist1[0].Transition_Id__c;    
        add2.Final_Remaining_Amount__c = 500;
        add2.Monthly_Amount__c = 40;
        add2.Device_Id__c ='8899';
        add2.Status__c = 'Processed';
        add2.isMicaDependency__c=true;
        addonList.add(add2);
           
        
        Service_Add_On__c add3 =  new Service_Add_On__c();
        add3.Monthly_Amount__c = 40;
        add3.Device_Id__c ='8899';
        add3.Status__c = 'Processed';
        add3.isMicaDependency__c=true;
        addonList.add(add3);
        
         Service_Add_On__c add4 =  new Service_Add_On__c();
        add4.Device_Id__c ='8899';
        add4.Status__c = 'Processed';
        add4.isMicaDependency__c=true;
        addonList.add(add4);
        
        Service_Add_On__c add5 =  new Service_Add_On__c();
        add5.Final_Remaining_Term__c = 2;
        add5.Monthly_Amount__c = 20;
        add5.Device_Id__c ='1234';
        add5.Status__c = 'Processed';
        add5.isMicaDependency__c=true;
        addonList.add(add5);
        
         Service_Add_On__c add7 =  new Service_Add_On__c();
        add7.Final_Remaining_Term__c = 2;
        add7.Monthly_Amount__c = 20;
        add7.Device_Id__c ='1234';
        add7.Status__c = 'Processed';
        add7.isMicaDependency__c=true;
        addonList.add(add7);
        
        Service_Add_On__c add6 =  new Service_Add_On__c();
        add6.Final_Remaining_Amount__c = 500;
        add6.Final_Remaining_Term__c = 2;
        add6.Device_Id__c ='1234';
        add6.Status__c = 'Processed';
        add6.isMicaDependency__c=false;
        addonList.add(add6);
        
        
        Service_Add_On__c add8 =  new Service_Add_On__c();
        add8.Instance_Id__c ='123456789'; 
        add8.Final_Remaining_Amount__c = 500;
        add8.Final_Remaining_Term__c = 2;
        add8.Device_Id__c ='1234';
        add8.Status__c = 'Processed';
        add8.isMicaDependency__c=false;
        addonList.add(add8);
        
        insert addonList;
      
            UpdateMRODetailsSchedulable obj = new UpdateMRODetailsSchedulable();
            Id dbID= DataBase.executeBatch(obj); 
        
        AsyncApexJob aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: dbID ];
		System.assertEquals(aaj.Id,dbID);	
        Test.stopTest();
     system.assertNotEquals(null, addonList);
    }
}