/*
===============================================================================================================================
Class : CS_ServiceSpecificationV2
Developer Name : Shubhi
Test Class : CS_ServiceSpecificationV2Test
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Shubhi Vijayvergia  3/9/2019     Edge-107843 CS should maintain the association of account to 
                      subscription / service to device identifiers during 
                      NEW / MAC scenarios so that reverse logistics solution can be supported
2.        shubhi Vijayvergia  24/9/2019   <Forward Logistics> Device Modelling : Mobile Device and Broadsoft Device Product 
                      Module change to rename the device identifier
                      attribute name and introduce device identifier type
3.       Suyash Chiplunkar   10/08/2021     DIGI-4289 - DPG | SD-WAN | CloudSense to create assets for SD-WAN related subscriptions
===============================================================================================================================
*/
@isTest
public class CS_ServiceSpecificationV2Test {
    @TestSetup static void dataSetup()
    {
        Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        testAccount.Customer_Status__c = 'ACTIVE';
        insert testAccount;
        
        Id standardID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defined').getRecordTypeId(); 
        Opportunity testOpp = new Opportunity();
        testOpp.Account = testAccount;
        testOpp.Name = 'testOpp';
        testOpp.StageName = 'Define';
        testOpp.Product_Type__c = 'Modular';
        testOpp.CloseDate = System.Date.today();
        testOpp.Type = 'Migration';
        testOpp.Billing_Solution__c = 'Standard';
        testOpp.RecordTypeId = standardID;
        insert testOpp;
    
        cscfga__Product_Definition__c CW_PD = new cscfga__Product_Definition__c(Name = 'Mobile device', cscfga__Description__c = 'Mobile device',product_Specification__c='DMCAT_ProductSpecification_000423');
    insert CW_PD;
        
        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = testAccount.Id;
        testBasket.Name = 'ShowSubTestBasket';
        testBasket.cscfga__Opportunity__c = testOpp.Id;
        insert testBasket;
        
        cscfga__Product_Configuration__c testConfig = new cscfga__Product_Configuration__c();
        testConfig.Name = 'Connected Workplace';
        testConfig.cscfga__Product_Basket__c = testBasket.Id;
        testConfig.cscfga__Product_Definition__c=CW_PD.id;
        insert testConfig;
        
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
        insert serv;
        Attachment att1 = new Attachment();
        att1.Name = 'ServiceSpecifications.json';
        String specficationjson='{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000622","productConfigurationId":"a3T5O0000000MC0UAM","name":"Unified Communication Device_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"d37d57fc-87e2-48a8-258d-5b497196bab9","endDate":"","description":"Unified Communication Device_Fulfilment","code":"DMCAT_ProductSpecification_000622_Fulfilment","attributes":{"SKU":"100116056","model":"OneAccess One100 (8 Port)","DeviceUUID":"","Quantity":2,"id":"","BroadSoftProductProductInstanceId":"","CustomerFacingServiceId":"","__targetSystem":"FULFILMENT","ShippingRequired":"TRUE"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000622DMCAT_ProductSpecification_000622_Billing_NonRecurringCharge_000751","productConfigurationId":"a3T5O0000000MC0UAM","name":"622_NRC_751","metadata":{},"instanceId":"","includeBilling":false,"guid":"b1fb5d5e-27d0-4391-c6ab-c988f82dc501","endDate":"","description":"Unified Communication Device_Billing_NonRecurringCharge_000751","code":"DMCAT_ProductSpecification_000622_Billing_NonRecurringCharge_000751","attributes":{"ContractType":"Purchase","ContractTerm":"","billingSubtype":"","unitofMeasure":"per device","taxTreatment":"GST Applicable","prorate":"","billInAdvance":"","currency_x":"AUD","frequency_x":"","billDescription":"OneAccess One100 (8 Port) Outright Charge","billingSpecId":"BSOTC001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000622DMCAT_ProductSpecification_000622_Billing_NonRecurringCharge_000788","productConfigurationId":"a3T5O0000000MC0UAM","name":"622_NRC_788","metadata":{},"instanceId":"","includeBilling":false,"guid":"60115c2a-188e-b0be-174b-8992e9794981","endDate":"","description":"Unified Communication Device_Billing_NonRecurringCharge_000788","code":"DMCAT_ProductSpecification_000622_Billing_NonRecurringCharge_000788","attributes":{"ContractType":"Purchase","ContractTerm":"","billingSubtype":"","unitofMeasure":"per device","taxTreatment":"GST Applicable","prorate":"","billInAdvance":"","currency_x":"AUD","frequency_x":"","billDescription":"OneAccess One100 (8 Port) Outright Charge","billingSpecId":"BSOTC001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000622DMCAT_ProductSpecification_000622_Billing_NonRecurringCharge_000790","productConfigurationId":"a3T5O0000000MC0UAM","name":"622_NRC_790","metadata":{},"instanceId":"","includeBilling":false,"guid":"1973110d-90f0-1e69-b749-e4fefa5cd2a1","endDate":"","description":"Unified Communication Device_Billing_NonRecurringCharge_000790","code":"DMCAT_ProductSpecification_000622_Billing_NonRecurringCharge_000790","attributes":{"ContractType":"Purchase","ContractTerm":"","billingSubtype":"","unitofMeasure":"per device","taxTreatment":"GST Applicable","prorate":"","billInAdvance":"","currency_x":"AUD","frequency_x":"","billDescription":"OneAccess One100 (8 Port) Outright Charge","billingSpecId":"BSOTC001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"a7aa4eab-425a-0b27-e013-0b8e90810ad3","productConfigurationId":"a3T5O0000000MC0UAM","name":"326_ASR","metadata":{},"instanceId":"","includeBilling":false,"guid":"664f225e-51c6-39a5-855d-e358794615bc","endDate":"","description":"Telstra Managed Service Option 1_Assurance","code":"DMCAT_ProductSpecification_000326_Assurance","attributes":{"__targetSystem":"__targetSystem","ServiceManagementOption":"1"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"f94d6153-2cb8-c809-d8e3-300fdda77139","productConfigurationId":"a3T5O0000000MC0UAM","name":"151_ASR","metadata":{},"instanceId":"","includeBilling":false,"guid":"6623c746-62b8-565e-264f-f12cc87107a3","endDate":"","description":"Incident Management_Assurance","code":"DMCAT_ProductSpecification_000151_Assurance","attributes":{"parentSpec":"DMCAT_ProductSpecification_000326_Assurance","__targetSystem":"ASSURANCE"},"additionalAttributes":{}}],"serviceId":"a4e5O0000000l9mQAA","legacyAttributes":[]}';
        att1.Body = Blob.valueOf(specficationjson);
        att1.ParentId = serv.Id;
        insert att1;       
    }
    
    @isTest
    public static void TestParsingDTO(){
        Attachment att1= [SELECT id, name, body, parentId 
                                        FROM Attachment 
                                        WHERE name = 'ServiceSpecifications.json' limit 1];
        List<CS_ServiceSpecificationV2.ServiceSpecifications> specs1 = CS_ServiceSpecificationV2.parseSpec(att1.body.toString(), 'Fulfilment');
        CS_ServiceSpecificationV2 specDTo=new CS_ServiceSpecificationV2();
    //specDTo.legacyAttributes legacyatt=new CS_ServiceSpecificationV2.legacyAttributes();
  specDTo.serviceID='1223445';
  CS_ServiceSpecificationV2.Attributes att=new CS_ServiceSpecificationV2.Attributes();
  att.targetSystem='test1234'; 
  att.SERVICEPROFILE='test1234'; 
  att.IPWirelessProductInstanceID='test1234'; 
  att.BillofMaterialID='test1234'; 
  att.AccessRole='test1234'; 
  att.CONTEXT='test1234'; 
  att.parentSpec='test1234'; 
  att.SKU='test1234'; 
  att.SuspensionContext='test1234'; 
  att.CustomerFacingServiceId='test1234'; 
  att.ShippingRequired='test1234'; 
  att.IMSI='test1234'; 
  att.deviceUUID='test1234';
  att.MESSAGEBANK='test1234'; 
    att.deviceID='test1234'; 
    att.deviceIDType='test1234';        
        att.quantity=2;
        att.deviceQuantity=1;
  CS_ServiceSpecificationV2.AdditionalAttributes addAtt=new CS_ServiceSpecificationV2.AdditionalAttributes();
  addAtt.CustomerFacingServiceId='12345567';
  CS_ServiceSpecificationV2.ServiceSpecifications specs=new CS_ServiceSpecificationV2.ServiceSpecifications();
  specs.attributes=att;
  specs.additionalAttribute=addAtt;
  specs.version='1233';
  specs.status='1233';
  specs.startDate='1233';
  specs.specification='1233';
  specs.productConfigurationId='1233';
  specs.name='1233';
  specs.instanceId='1233';
  specs.identifier='1233';
  specs.guid='1233';
  specs.endDate='1233';
  specs.description='1233';
  specs.code='1233';
  specs.subscriptionId='1233';
  specs.serviceId='1233';
  specs.quantity='1233';
  specs.deviceQuantity='1233';
    List<CS_ServiceSpecificationV2.ServiceSpecifications> specificationsList =new List<CS_ServiceSpecificationV2.ServiceSpecifications>();
  specificationsList.add(specs);
  specDTo.specifications=specificationsList;       
        system.assert(specDTo!=null);
    }

}