/*===============================================================================================================================
Class : AssetUpsertionHelper
Developer Name : Shubhi
Test Class : AssetUpsertionHelperTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Shubhi Vijayvergia  3/9/2019     Edge-107843 CS should maintain the association of account to 
                                            subscription / service to device identifiers during 
                                            NEW / MAC scenarios so that reverse logistics solution can be supported
2.        shubhi Vijayvergia  24/9/2019     <Forward Logistics> Device Modelling : Mobile Device and Broadsoft Device Product 
                                            Module change to rename the device identifier
                                            attribute name and introduce device identifier type
3.        Shubhi Vijayvergia         EDGE-119580
4.        Vaibhav            13/07/2020        EDGE-158047
5.         shubhhi V           8/03/2021     fdr test class fix
6.         Suyash Chiplunkar   10/08/2021     DIGI-4289 - DPG | SD-WAN | CloudSense to create assets for SD-WAN related subscriptions
===============================================================================================================================
*/
@isTest
public class AssetUpsertionHelperTest {
    
    public static Id standardID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defined').getRecordTypeId();   

    @TestSetup static void dataSetup()
    {
        Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        testAccount.Customer_Status__c = 'ACTIVE';
        insert testAccount;
        
        Opportunity testOpp = new Opportunity();
        testOpp.Account = testAccount;
        testOpp.Name = 'testOpp';
        testOpp.StageName = 'Develop';//fdr test class fix
        testOpp.Product_Type__c = 'Modular';
        testOpp.CloseDate = System.Date.today();
        testOpp.RecordTypeId=standardID;
        testOpp.Type ='Migration'; //'Disconnect';
        testOpp.Billing_Solution__c='Standard';
        insert testOpp;

        //DIGI-4289
        Opportunity testOppSdwan = new Opportunity();
        testOppSdwan.Account = testAccount;
        testOppSdwan.Name = 'testOppSDWAN';
        testOppSdwan.StageName = 'Develop';//fdr test class fix
        testOppSdwan.Product_Type__c = 'Modular';
        testOppSdwan.CloseDate = System.Date.today();
        testOppSdwan.RecordTypeId=standardID;
        testOppSdwan.Type ='Migration'; //'Disconnect';
        testOppSdwan.Billing_Solution__c='Standard';
        insert testOppSdwan;
    
        cscfga__Product_Definition__c CW_PD = new cscfga__Product_Definition__c(Name = 'Mobile device', cscfga__Description__c = 'Mobile device',product_Specification__c='DMCAT_ProductSpecification_000423');
    insert CW_PD;

        //DIGI-4289
        cscfga__Product_Definition__c SDWAN_PD = new cscfga__Product_Definition__c(Name = 'SDWAN', cscfga__Description__c = 'SDWAN',product_Specification__c=System.label.SDWAN_ADAPT_OFFER);
    insert SDWAN_PD;
        
        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = testAccount.Id;
        testBasket.Name = 'ShowSubTestBasket';
        testBasket.cscfga__Opportunity__c = testOpp.Id;
        insert testBasket;

        //DIGI-4289
        cscfga__Product_Basket__c testBasketSDWAN = new cscfga__Product_Basket__c();
        testBasketSDWAN.csbb__Account__c = testAccount.Id;
        testBasketSDWAN.Name = 'ShowSubTestBasketSDWAN';
        testBasketSDWAN.cscfga__Opportunity__c = testOppSdwan.Id;
        insert testBasketSDWAN;
        
        cscfga__Product_Configuration__c testConfig = new cscfga__Product_Configuration__c();
        testConfig.Name = 'Connected Workplace';
        testConfig.cscfga__Product_Basket__c = testBasket.Id;
        testConfig.cscfga__Product_Definition__c=CW_PD.id;
        insert testConfig;

        //DIGI-4289
        cscfga__Product_Configuration__c testConfigSDWAN = new cscfga__Product_Configuration__c();
        testConfigSDWAN.Name = 'SDWAN';
        testConfigSDWAN.cscfga__Product_Basket__c = testBasketSDWAN.Id;
        testConfigSDWAN.cscfga__Product_Definition__c=SDWAN_PD.id;
        insert testConfigSDWAN;
        
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        csord__Order__c order = ProductTestFactory.buildOrder('PrimaryOrder', testAccount.id, 'Created', ordReq.id);

        order.csord__Status2__c='Ready for submit';
        insert order;
        csord__Subscription__c testSubscription = new csord__Subscription__c();
        testSubscription.Name = 'TestSubsforTest';
        testSubscription.csord__Account__c = testAccount.Id;
        testSubscription.csord__Order__c = order.Id;
        testSubscription.csord__Identification__c = 'test';
        testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription.csord__Status__c = 'Active';
        insert testSubscription;

        //DIGI-4289
        csord__Subscription__c testSubscriptionSDWAN = new csord__Subscription__c();
        testSubscriptionSDWAN.Name = 'SDWAN';
        testSubscriptionSDWAN.csord__Account__c = testAccount.Id;
        testSubscriptionSDWAN.csord__Order__c = order.Id;
        testSubscriptionSDWAN.csord__Identification__c = 'test';
        testSubscriptionSDWAN.csordtelcoa__Product_Configuration__c = testConfigSDWAN.Id;
        testSubscriptionSDWAN.csord__Status__c = 'Active';
        insert testSubscriptionSDWAN;

        List <csord__Service__c> servList=new List<csord__Service__c>();
    csord__Service__c serv = new csord__Service__c();
        serv.name ='testService_'+testSubscription.id;
        serv.csord__Identification__c  = 'testIdentify_4';
        serv.csordtelcoa__Service_Number__c = '3';
        serv.csord__Subscription__c = testSubscription.Id;
        serv.csord__Status__c = 'Created';
        serv.substage__c = 'Product Requirements Validation';
        serv.csord__Order_Request__c = ordReq.Id;
        serv.csordtelcoa__Product_Configuration__c = testConfig.Id;
        serv.csord__Order__c = testSubscription.csord__Order__c;
    servList.add(serv);
    csord__Service__c serv1 = new csord__Service__c();
        serv1.name ='testService1_'+testSubscription.id;
        serv1.csord__Identification__c  = 'testIdentify_4';
        serv1.csordtelcoa__Service_Number__c = '3';
        serv1.csord__Subscription__c = testSubscription.Id;
        serv1.csord__Status__c = 'Created';
        serv1.substage__c = 'Product Requirements Validation';
        serv1.csord__Order_Request__c = ordReq.Id;
        serv1.csordtelcoa__Product_Configuration__c = testConfig.Id;
        serv1.csord__Order__c = testSubscription.csord__Order__c;
    servList.add(serv1);
    
      csord__Service__c srvcD = new csord__Service__c();
        srvcD.name ='mobDevice';
        srvcD.csord__Identification__c  = 'mobDevice';
        srvcD.csordtelcoa__Service_Number__c = 'SVC-000084319';
        srvcD.csord__Status__c = 'In Progress'; 
        srvcD.csord__Subscription__c = testSubscription.Id;
        srvcD.csord__Order__c = order.Id;
        servList.add(srvcD);
    
      csord__Service__c srvcD2 = new csord__Service__c();
        srvcD2.name ='mobDevice2';
        srvcD2.csord__Identification__c  = 'mobDevice2';
        srvcD2.csordtelcoa__Service_Number__c = 'SVC-000084320';
        srvcD2.csord__Status__c = 'In Progress'; 
        srvcD2.csord__Subscription__c = testSubscription.Id;
        srvcD2.csord__Order__c = order.Id;
        servList.add(srvcD2);
        
        csord__Service__c srvcD3 = new csord__Service__c();
        srvcD3.name ='mobDevice3';
        srvcD3.csord__Identification__c  = 'mobDevice3';
        srvcD3.csordtelcoa__Service_Number__c = 'SVC-000084321';
        srvcD3.csord__Status__c = 'Complete'; 
        srvcD3.csord__Subscription__c = testSubscription.Id;
        srvcD3.csord__Order__c = order.Id;
        srvcD3.Scenario_Type__c ='No Fault Return';
        servList.add(srvcD3);

        //DIGI-4289
        csord__Service__c servSDWAN = new csord__Service__c();
        servSDWAN.name ='testService1_'+testSubscriptionSDWAN.id;
        servSDWAN.csord__Identification__c  = 'SDWAN Identity';
        servSDWAN.csordtelcoa__Service_Number__c = 'SDWAN-33';
        servSDWAN.csord__Subscription__c = testSubscriptionSDWAN.Id;
        servSDWAN.csord__Status__c = 'Created';
        servSDWAN.substage__c = 'Product Requirements Validation';
        servSDWAN.csord__Order_Request__c = ordReq.Id;
        servSDWAN.csordtelcoa__Product_Configuration__c = testConfigSDWAN.Id;
        servSDWAN.csord__Order__c = testSubscriptionSDWAN.csord__Order__c;
    servList.add(servSDWAN);
        
        insert servList;
    

    List<Asset> asetList=new List<Asset>();
    
        //Added by Vamsi
        EnvironmentVariable__c env_var=  new EnvironmentVariable__c();
        env_var.name='batchSizeAssetUpdate';
        env_var.value__c='20';
        insert env_var; 
        //Added by Vamsi
    
    Asset aset1=new Asset();
    aset1.Name='IAD Device';
    aset1.csord__Service__c = srvcD.id;
        aset1.AccountId=testAccount.id;
        asetList.add(aset1);
    
      Asset aset2=new Asset();
    aset2.Name='IAD Device2';
    aset2.csord__Service__c = srvcD2.id;
        aset2.AccountId=testAccount.id;
        asetList.add(aset2);
    
        Asset aset3=new Asset();
    aset3.Name='IAD Device3';
    aset3.csord__Service__c = srvcD3.id;
        aset3.AccountId=testAccount.id;
        asetList.add(aset3);
    
    insert asetList;
        
        
    List<attachment> attlist =new List<attachment>();
    Attachment att1 = new Attachment();
        att1.Name = 'ServiceSpecifications.json';
        String specficationjson1='{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000622","productConfigurationId":"a3T5O0000000MC0UAM","name":"Unified Communication Device_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"d37d57fc-87e2-48a8-258d-5b497196bab9","endDate":"","description":"Unified Communication Device_Fulfilment","code":"DMCAT_ProductSpecification_000622_Fulfilment","attributes":{"SKU":"100116056","model":"OneAccess One100 (8 Port)","DeviceUUID":"","Quantity":2,"id":"","BroadSoftProductProductInstanceId":"","CustomerFacingServiceId":"","__targetSystem":"FULFILMENT","ShippingRequired":"TRUE"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000622DMCAT_ProductSpecification_000622_Billing_NonRecurringCharge_000751","productConfigurationId":"a3T5O0000000MC0UAM","name":"622_NRC_751","metadata":{},"instanceId":"","includeBilling":false,"guid":"b1fb5d5e-27d0-4391-c6ab-c988f82dc501","endDate":"","description":"Unified Communication Device_Billing_NonRecurringCharge_000751","code":"DMCAT_ProductSpecification_000622_Billing_NonRecurringCharge_000751","attributes":{"ContractType":"Purchase","ContractTerm":"","billingSubtype":"","unitofMeasure":"per device","taxTreatment":"GST Applicable","prorate":"","billInAdvance":"","currency_x":"AUD","frequency_x":"","billDescription":"OneAccess One100 (8 Port) Outright Charge","billingSpecId":"BSOTC001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000622DMCAT_ProductSpecification_000622_Billing_NonRecurringCharge_000788","productConfigurationId":"a3T5O0000000MC0UAM","name":"622_NRC_788","metadata":{},"instanceId":"","includeBilling":false,"guid":"60115c2a-188e-b0be-174b-8992e9794981","endDate":"","description":"Unified Communication Device_Billing_NonRecurringCharge_000788","code":"DMCAT_ProductSpecification_000622_Billing_NonRecurringCharge_000788","attributes":{"ContractType":"Purchase","ContractTerm":"","billingSubtype":"","unitofMeasure":"per device","taxTreatment":"GST Applicable","prorate":"","billInAdvance":"","currency_x":"AUD","frequency_x":"","billDescription":"OneAccess One100 (8 Port) Outright Charge","billingSpecId":"BSOTC001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000622DMCAT_ProductSpecification_000622_Billing_NonRecurringCharge_000790","productConfigurationId":"a3T5O0000000MC0UAM","name":"622_NRC_790","metadata":{},"instanceId":"","includeBilling":false,"guid":"1973110d-90f0-1e69-b749-e4fefa5cd2a1","endDate":"","description":"Unified Communication Device_Billing_NonRecurringCharge_000790","code":"DMCAT_ProductSpecification_000622_Billing_NonRecurringCharge_000790","attributes":{"ContractType":"Purchase","ContractTerm":"","billingSubtype":"","unitofMeasure":"per device","taxTreatment":"GST Applicable","prorate":"","billInAdvance":"","currency_x":"AUD","frequency_x":"","billDescription":"OneAccess One100 (8 Port) Outright Charge","billingSpecId":"BSOTC001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"a7aa4eab-425a-0b27-e013-0b8e90810ad3","productConfigurationId":"a3T5O0000000MC0UAM","name":"326_ASR","metadata":{},"instanceId":"","includeBilling":false,"guid":"664f225e-51c6-39a5-855d-e358794615bc","endDate":"","description":"Telstra Managed Service Option 1_Assurance","code":"DMCAT_ProductSpecification_000326_Assurance","attributes":{"__targetSystem":"__targetSystem","ServiceManagementOption":"1"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"f94d6153-2cb8-c809-d8e3-300fdda77139","productConfigurationId":"a3T5O0000000MC0UAM","name":"151_ASR","metadata":{},"instanceId":"","includeBilling":false,"guid":"6623c746-62b8-565e-264f-f12cc87107a3","endDate":"","description":"Incident Management_Assurance","code":"DMCAT_ProductSpecification_000151_Assurance","attributes":{"parentSpec":"DMCAT_ProductSpecification_000326_Assurance","__targetSystem":"ASSURANCE"},"additionalAttributes":{}}],"serviceId":"'+serv1.id+'","legacyAttributes":[]}';
        att1.Body = Blob.valueOf(specficationjson1);
        att1.ParentId = serv.Id;
        attlist.add(att1);
    Attachment att2 = new Attachment();
        att2.Name = 'ServiceSpecifications.json';
        String specficationjson='{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000622","productConfigurationId":"a3T5O0000000MC0UAM","name":"Unified Communication Device_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"d37d57fc-87e2-48a8-258d-5b497196bab9","endDate":"","description":"Unified Communication Device_Fulfilment","code":"DMCAT_ProductSpecification_000622_Fulfilment","attributes":{"SKU":"100116056","model":"OneAccess One100 (8 Port)","DeviceUUID":"","Quantity":0,"id":"","BroadSoftProductProductInstanceId":"","CustomerFacingServiceId":"","__targetSystem":"FULFILMENT","ShippingRequired":"TRUE"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000622DMCAT_ProductSpecification_000622_Billing_NonRecurringCharge_000751","productConfigurationId":"a3T5O0000000MC0UAM","name":"622_NRC_751","metadata":{},"instanceId":"","includeBilling":false,"guid":"b1fb5d5e-27d0-4391-c6ab-c988f82dc501","endDate":"","description":"Unified Communication Device_Billing_NonRecurringCharge_000751","code":"DMCAT_ProductSpecification_000622_Billing_NonRecurringCharge_000751","attributes":{"ContractType":"Purchase","ContractTerm":"","billingSubtype":"","unitofMeasure":"per device","taxTreatment":"GST Applicable","prorate":"","billInAdvance":"","currency_x":"AUD","frequency_x":"","billDescription":"OneAccess One100 (8 Port) Outright Charge","billingSpecId":"BSOTC001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000622DMCAT_ProductSpecification_000622_Billing_NonRecurringCharge_000788","productConfigurationId":"a3T5O0000000MC0UAM","name":"622_NRC_788","metadata":{},"instanceId":"","includeBilling":false,"guid":"60115c2a-188e-b0be-174b-8992e9794981","endDate":"","description":"Unified Communication Device_Billing_NonRecurringCharge_000788","code":"DMCAT_ProductSpecification_000622_Billing_NonRecurringCharge_000788","attributes":{"ContractType":"Purchase","ContractTerm":"","billingSubtype":"","unitofMeasure":"per device","taxTreatment":"GST Applicable","prorate":"","billInAdvance":"","currency_x":"AUD","frequency_x":"","billDescription":"OneAccess One100 (8 Port) Outright Charge","billingSpecId":"BSOTC001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000622DMCAT_ProductSpecification_000622_Billing_NonRecurringCharge_000790","productConfigurationId":"a3T5O0000000MC0UAM","name":"622_NRC_790","metadata":{},"instanceId":"","includeBilling":false,"guid":"1973110d-90f0-1e69-b749-e4fefa5cd2a1","endDate":"","description":"Unified Communication Device_Billing_NonRecurringCharge_000790","code":"DMCAT_ProductSpecification_000622_Billing_NonRecurringCharge_000790","attributes":{"ContractType":"Purchase","ContractTerm":"","billingSubtype":"","unitofMeasure":"per device","taxTreatment":"GST Applicable","prorate":"","billInAdvance":"","currency_x":"AUD","frequency_x":"","billDescription":"OneAccess One100 (8 Port) Outright Charge","billingSpecId":"BSOTC001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"a7aa4eab-425a-0b27-e013-0b8e90810ad3","productConfigurationId":"a3T5O0000000MC0UAM","name":"326_ASR","metadata":{},"instanceId":"","includeBilling":false,"guid":"664f225e-51c6-39a5-855d-e358794615bc","endDate":"","description":"Telstra Managed Service Option 1_Assurance","code":"DMCAT_ProductSpecification_000326_Assurance","attributes":{"__targetSystem":"__targetSystem","ServiceManagementOption":"1"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"f94d6153-2cb8-c809-d8e3-300fdda77139","productConfigurationId":"a3T5O0000000MC0UAM","name":"151_ASR","metadata":{},"instanceId":"","includeBilling":false,"guid":"6623c746-62b8-565e-264f-f12cc87107a3","endDate":"","description":"Incident Management_Assurance","code":"DMCAT_ProductSpecification_000151_Assurance","attributes":{"parentSpec":"DMCAT_ProductSpecification_000326_Assurance","__targetSystem":"ASSURANCE"},"additionalAttributes":{}}],"serviceId":"'+serv1.id+'","legacyAttributes":[]}';
        att2.Body = Blob.valueOf(specficationjson);
        att2.ParentId = serv1.Id;
    attList.add(att2);

        //DIGI-4289
        Attachment attSDWAN = new Attachment();
        attSDWAN.Name = 'ServiceSpecifications.json';
        String specficationjsonSDWAN ='{"legacyAttributes":[],"serviceId":"'+servSDWAN.id+'","specifications":[{"additionalAttributes":{"parentSpec":"57504cbc-7867-4cd4-8b8d-7fdf352ccfbb"},"attributes":{"__targetSystem":"ASSURANCE","parentSpec":"DMCAT_ProductSpecification_000326_Assurance","ResponseTarget":"SLA0010001","RestoreTarget":"SLA0010006"},"code":"DMCAT_ProductSpecification_000151_Assurance","description":"Incident Management_Assurance","endDate":"","guid":"89c86aef-b09e-f908-2a75-e8af832f717e","includeBilling":false,"instanceId":"","metadata":{},"name":"151_ASR","productConfigurationId":"a3T2N000000Fo56UAC","specification":"9eec78b8-017d-60f5-2497-cbd8f9e64379","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"ServiceManagementOption":"1","__targetSystem":"ASSURANCE"},"code":"DMCAT_ProductSpecification_000326_Assurance","description":"Telstra Managed Service Option 1_Assurance","endDate":"","guid":"57504cbc-7867-4cd4-8b8d-7fdf352ccfbb","includeBilling":false,"instanceId":"","metadata":{},"name":"326_ASR","productConfigurationId":"a3T2N000000Fo56UAC","specification":"91a51b0d-228c-651a-1c61-79656398db2a","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"EnterpriseWirelessProductInstanceID":"f2287a41-4ede-4350-5630-2f8c5f416591"},"attributes":{"__targetSystem":"FULFILMENT","IMEI":"","IMEISKU":"IMEINUMBER","manageDeviceID":"","DeviceID":"","DeviceIDType":"Device Serial Number","CustomerFacingServiceId":"","Device":[{"schemaId":"e113ed44-005a-f439-002a-ded1e1aa20a6","attributes":{"type":"SD-WAN Device","SDWANDeviceModel":"VeloCloud 510LTE","Vendor":"VeloCloud","sku":"VC-510LTE-AP-HO-12-P"}}],"lteMode":"Active","EnterpriseWirelessProductInstanceID":"DMCAT_ProductSpecification_001447_Fulfilment","ShippingRequired":"TRUE","tenancyId":"","SDWANTenancyProductInstanceID":"DMCAT_ProductSpecification_001302_Fulfilment"},"code":"DMCAT_ProductSpecification_001345_Fulfilment","description":"SDWAN_Device_Fulfilment","endDate":"","guid":"978e65e1-2327-d08d-89e1-e47dcc5d3c05","includeBilling":false,"instanceId":"","metadata":{},"name":"SDWAN_Device_Fulfilment","productConfigurationId":"a3T2N000000Fo56UAC","specification":"a36fc023-14d1-c807-0665-9342c60327f0","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"parentSpec":"978e65e1-2327-d08d-89e1-e47dcc5d3c05"},"attributes":{"__targetSystem":"FULFILMENT","parentSpec":"DMCAT_ProductSpecification_001345_Fulfilment","Maintainance":[{"schemaId":"e2fc57c2-c885-d403-7d8f-3c29d168f844","attributes":{"type":"SD-WAN Maintenance","SDWANMaintenance":"VeloCloud 510LTE Maintenance","Vendor":"VeloCloud","sku":"VC-EDG-NDD-510LTE-AP-UPG-12P"}}]},"code":"DMCAT_ProductSpecification_001360_Fulfilment","description":"SDWAN_Maintenance","endDate":"","guid":"9ea39456-53c6-1382-13cc-31e1dd1459b3","includeBilling":false,"instanceId":"","metadata":{},"name":"SDWAN_Maintenance","productConfigurationId":"a3T2N000000Fo56UAC","specification":"9d3cb199-192d-5c9d-e868-446dfc8060d6","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","currencyCode":"AUD","quantity":"1","frequency":"Monthly","billingSpecId":"BSRC001_CB","billInAdvance":"true","prorate":"false","billDescription":"SD-WAN Adapt S1 Small Bundle","rateExcludeGST":"380.00","externalId":"DMCAT_Offer_001343_DMCAT_ProductSpecification_001358_DMCAT_RecurringCharge_001350_8162","chargeId":"DMCAT_RecurringCharge_001350","taxTreatment":"GST Applicable"},"code":"DMCAT_ProductSpecification_001358_Billing_RecurringCharge_001350","description":"SD-WAN ADAPT S1_Billing_RecurringCharge_001350","endDate":"","guid":"f86ebd99-a328-cf57-bcbe-fef0a77c9756","includeBilling":false,"instanceId":"","metadata":{},"name":"1358_RC_1350","productConfigurationId":"a3T2N000000Fo56UAC","specification":"d69db935-490d-0c55-d6ed-025671a1bc66","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","currencyCode":"AUD","billingSpecId":"BSOTC001_CB","unitofMeasure":"each","billDescription":"SD-WAN Adapt S1 Activation Charge","rateExcludeGST":"0","externalId":"DMCAT_Offer_001343_DMCAT_ProductSpecification_001358_DMCAT_NonRecurringCharge_001349_8095","chargeId":"DMCAT_NonRecurringCharge_001349","taxTreatment":"GST Applicable","quantity":"1"},"code":"DMCAT_ProductSpecification_001358_Billing_NonRecurringCharge_001349","description":"SD-WAN ADAPT S1_Billing_NonRecurringCharge_001349","endDate":"","guid":"b33eba4a-de2d-18dd-804b-534e3b096df9","includeBilling":false,"instanceId":"","metadata":{},"name":"1358_NRC_1349","productConfigurationId":"a3T2N000000Fo56UAC","specification":"78beb8ca-42ba-1a09-1a4b-146984158410","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"parentSpec":"978e65e1-2327-d08d-89e1-e47dcc5d3c05"},"attributes":{"__targetSystem":"FULFILMENT","parentSpec":"DMCAT_ProductSpecification_001345_Fulfilment","License":[{"schemaId":"451796dc-af89-a398-fd54-0c8e2549be13","attributes":{"type":"SD-WAN License","SDWANLicense":"VeloCloud 100M Enterprise License","Vendor":"VeloCloud","sku":"VC100M-ENT-HO-SG-L34S1-12P"}}]},"code":"DMCAT_ProductSpecification_001359_Fulfilment","description":"SDWAN_License","endDate":"","guid":"062294f0-1d31-7b20-d2ba-bc2d98b70d61","includeBilling":false,"instanceId":"","metadata":{},"name":"SDWAN_License","productConfigurationId":"a3T2N000000Fo56UAC","specification":"a2805518-9879-93cb-568b-a9eeb0b33709","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"FULFILMENT","Prisma":[{"schemaId":"86369936-d50a-8dc4-6ba7-b721bc0e0902","attributes":{"Bandwidth":"10 Mbps"}}],"secureEdgeCloudProductInstanceID":"DMCAT_ProductSpecification_001368_Fulfilment"},"code":"DMCAT_ProductSpecification_001363_Fulfilment","description":"SDWAN_DEVICE_Fulfilment","endDate":"","guid":"1aaf980f-6c26-2a98-70fb-7b876eaecc8a","includeBilling":false,"instanceId":"","metadata":{},"name":"SDWAN_SecureEdge","productConfigurationId":"a3T2N000000Fo56UAC","specification":"1c230654-07a7-5f72-8f38-b93626f25261","startDate":"","status":"Created","version":"1"}]}';
        attSDWAN.Body = Blob.valueOf(specficationjsonSDWAN);
        attSDWAN.ParentId = servSDWAN.Id;
    attList.add(attSDWAN);
        insert attList;     
    }
     @isTest 
    static void testUpsertAsset(){
        List<ID> orderIDs=new List<ID>();
        List<csord__Order__c> orderList=[Select id,csord__Status2__c from csord__Order__c];
        for(csord__Order__c ord:orderList){
            orderIDs.add(ord.id); 
            ord.csord__Status2__c= System.Label.OrderStatus;
        }
        update orderList; 
        List<ID> orderIDsnew=AssetUpsertionHelper.processAssetCreation(orderIDs); //EDGE-119580     
        List<Asset> Assetlist=[Select id from asset where csord__Service__r.csord__Order__c IN: orderIDs];
        system.debug('@@Assets@@@-->'+AssetList);
        system.assert(Assetlist.size()>0);   
        List<String> deviceIdList=new List<String>();
        csord__Service__c serv1=[Select id from csord__Service__c limit 1];
        deviceIdList.add('12345');
        AssetUpsertionHelper.updateAsset(deviceIdList,serv1.id,'Test');//EDGE-119580
    }
     @isTest 
    static void testUpsertAssetCatch(){
        AssetCreateDTO assetDTo=new AssetCreateDTO();
        assetDTo.accountID='Test1234';
        assetDTo.name='Test1234';
        assetDTo.specCode='Test1234';
        assetDTo.description='Test1234';
        assetDTo.SKU='Test1234';
        assetDTo.assetStatus='Test1234';
        assetDTo.serviceId='Test1234';
        assetDTo.subcriptionId='Test1234';
        assetDTo.offerId='Test1234';
        assetDTo.assetUUID='Test1234';
        assetDTo.ownership='Test1234';
        assetDTo.assetInstanceId='Test1234';  
        assetDTo.quantity=2;
        assetDTo.deviceQuantity=1;      
        Map<String,AssetCreateDTO> AssetCreateDTOMap=new Map<String,AssetCreateDTO>();
        Map<String,Integer> guidmap=new Map<String,Integer>();
        AssetCreateDTOMap.put('Test1234',assetDTo);
        guidmap.put('12345test',1);
         AssetUpsertionHelper.upsertAsset(AssetCreateDTOMap,guidmap);
        List<String> deviceIdList=new List<String>();
        csord__Service__c serv1=[Select id from csord__Service__c limit 1];
        deviceIdList.add('12345');
        AssetUpsertionHelper.updateAsset(deviceIdList,serv1.id,'Test');//EDGE-119580
        system.assert(assetDTo!=null);
        //List<Asset> Assetlist=[Select id from asset where csord__Service__r.csord__Order__c IN: orderIDs];
        //system.debug('@@Assets@@@-->'+AssetList);
        //system.assert(Assetlist.size()==0);        
    }
  
   @isTest 
    static void testupdateAssetMSUpdate(){
    Map<String,Map<String,String>> servnumDeviceMap=new Map<String,Map<String,String>>();
    List<string> srvcNumberList=new List<string>();
   for(csord__Service__c serv : [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name,csord__Identification__c,csord__Service__c from csord__Service__c where Name = 'mobDevice' or Name = 'mobDevice2'])
   {
     Map<String,String> tempMap=new Map<String,String>();
     tempMap.put('2CE4F1BEFD33','IMEI');
     servnumDeviceMap.put(serv.csordtelcoa__Service_Number__c,tempMap);
     srvcNumberList.add(serv.csordtelcoa__Service_Number__c);
   }
        Map<String,String> serviceDeviceBlankMap = new Map<String,String>();
        serviceDeviceBlankMap.put('SVC-1234','Blank');
     Test.startTest();
     AssetUpsertionHelper.updateAssetMSUpdate(servnumDeviceMap,srvcNumberList,serviceDeviceBlankMap);
     Test.StopTest();
     
      for(Asset aset : [select id,name,AssetID__c,AssetIDType__c from Asset where Name='IAD Device2' or Name='IAD Device'])
         {
       if(aset.Name=='IAD Device2'){
         system.assertEquals('2CE4F1BEFD33',aset.AssetID__c);
                 system.assertEquals('IMEI',aset.AssetIDType__c);
       }
         
        if(aset.Name=='IAD Device'){
         system.assertEquals('2CE4F1BEFD33',aset.AssetID__c);
                 system.assertEquals('IMEI',aset.AssetIDType__c);
       }
     }
    }
   @isTest 
    static void testupdateAssetToReturned(){
   csord__Service__c serv =[SELECT Id,name from csord__Service__c where Name = 'mobDevice3'];
     list<Id> serId = new List<Id>();
     serId.add(serv.Id);
         AssetUpsertionHelper.updateAssetToReturned(serId);
     System.assertEquals('Asset Updated', 'Asset Updated');
    }

    @isTest 
    static void testSDWANAssetSKU(){//DIGI-4289
        List<ID> orderIDs=new List<ID>();
        List<csord__Order__c> orderList=[Select id,csord__Status2__c from csord__Order__c];
        for(csord__Order__c ord:orderList){
            orderIDs.add(ord.id); 
            ord.csord__Status2__c= System.Label.OrderStatus;
        }
        update orderList; 
        Test.StartTest();
        List<ID> orderIDsnew=AssetUpsertionHelper.processAssetCreation(orderIDs);  
        Test.StopTest();
        cscfga__Product_Configuration__c SdwandPC = [Select ID,Name from cscfga__Product_Configuration__c where Name = 'SDWAN'];
        Asset SdwanAsset =[Select id,Stock_Keeping_Unit__c,csord__Service__r.csordtelcoa__Product_Configuration__c,csord__Service__r.csord__Identification__c from Asset where csord__Service__r.csord__Identification__c='SDWAN Identity'];
        //system.assertNotEquals(SdwanAsset==null);
        System.assertEquals('VC-510LTE-AP-HO-12-P', SdwanAsset.Stock_Keeping_Unit__c);
        System.assertEquals(SdwandPC.Id ,SdwanAsset.csord__Service__r.csordtelcoa__Product_Configuration__c);

    }
}