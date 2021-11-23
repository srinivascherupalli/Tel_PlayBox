/* ****************************************************************************
 Class Name      : UpdateServiceAndSpecsTest 
* Author        :  Ankit Goswami : EDGE-143015
* Date          :  22 may 2020
* Description   :  update specs, service obj and number obj via Phython Script
* *****************************************************************************/
@isTest
private class UpdateServiceAndSpecsTest {
    @TestSetup static void dataSetup() {
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        insert acc;
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        csord__Order__c SOrd = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        SOrd.csord__Order_Request__c = ordReq.Id;
        insert SOrd;
        csord__Subscription__c testSubscription = new csord__Subscription__c();
        testSubscription.Name = 'TestSubsforTest';
        testSubscription.csord__Account__c = acc.Id;
        testSubscription.csord__Order__c = SOrd.Id;
        testSubscription.csord__Identification__c = 'test';
        testSubscription.csord__Status__c = 'Active';
        insert testSubscription;
        csord__Service__c servMobile = new csord__Service__c();
        servMobile.name ='Mobile 1';
        servMobile.csord__Identification__c  = 'testIdentify_4';
        servMobile.csordtelcoa__Service_Number__c = 'SVC-123456';
        servMobile.csord__Subscription__c = testSubscription.Id;
        servMobile.csord__Status__c = 'Created';
        servMobile.substage__c = 'Product Requirements Validation';
        servMobile.csord__Order_Request__c = ordReq.Id;
        servMobile.csord__Order__c = testSubscription.csord__Order__c;
        insert servMobile;
        Number__c NumberObj =new Number__c();
        NumberObj.Name='TestNumber';
        NumberObj.Type__c='New';
        NumberObj.Status__c='RESERVED';
        NumberObj.Sim_Serial_Number__c='';
        NumberObj.Service_Id__c='SVC-123456';
        NumberObj.IMSI__c='';
        insert NumberObj;
        List<Attachment> atts = new List<Attachment>();
        Attachment att1= new Attachment();
        att1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"829aa859-b630-3838-a1f6-0cc45d1254b6","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"IMSI":"","ShippingRequired":"TRUE","DMCAT_ProductSpecification_000263_CPEDeliveryDate":"","SERVICEID":"","BillofMaterialID":"","AccessRole":"","SIMSKU":"NA","CONTEXT":"NA","MESSAGEBANK":"NA","SERVICEPROFILE":"DATA_BACKUP","__targetSystem":"FULFILMENT","IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment"},"additionalAttributes":{"IPWirelessProductInstanceID":"3abb8c65-723c-f4c8-35bf-9230430b0236"}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Bill_AW","metadata":{},"instanceId":"","includeBilling":false,"guid":"21f31282-4d7e-d137-0bd1-6a68d175f9fb","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","attributes":{"IMSI":"","SERVICEID":"","billDescription":"Mobile Interim Access Allowance","RoutingServiceType":"Mobile","value":"Unlimited","unitofMeasure":"GB","type":"Domestic Data","ocsProdID":"T22E_MIA_DATPLAN","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000571","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Billing_NonRecurringCharge_000571","metadata":{},"instanceId":"","includeBilling":false,"guid":"f0ce4f66-186f-5591-62de-e46b9fc877b7","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000571","attributes":{"rateExcludeGST":"","unitofMeasure":"each","billDescription":"IR Day Pass Charge","ocsProdID":"T22E_EMOB_IRDP","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","currency":"AUD","type":"OC","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000572","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Billing_NonRecurringCharge_000572","metadata":{},"instanceId":"","includeBilling":false,"guid":"4e0b2e72-db35-0892-f5fb-d572984ebd6b","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000572","attributes":{"rateExcludeGST":"","billDescription":"IR Data topup Charge","ocsProdID":"T22E_EMOB_IRDTP","unitofMeasure":"each","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","currency":"AUD","type":"OC","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobility_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"5311e403-e5e1-5d83-b2c1-ac90b78e1289","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Fulfilment","attributes":{"MobilityPlan":"CWP Mobile Seat","__targetSystem":"FULFILMENT"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"4c53e7fc-bd0e-9dfc-0c86-c21d3d9a45e7","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"IMSI":"","ShippingRequired":"TRUE","SERVICEID":"","MESSAGEBANK":"","SIMSKU":"100119211","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","SERVICEPROFILE":"NORMAL","__targetSystem":"FULFILMENT"},"additionalAttributes":{"parentSpec":"5311e403-e5e1-5d83-b2c1-ac90b78e1289"}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobility_Billing_RecurringCharge_000498","metadata":{},"instanceId":"","includeBilling":false,"guid":"11966645-20ef-a35d-8f66-bcbccfff31a2","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes":{"billDescription":"CWP Mobile Seat","prorate":"false","billInAdvance":"true","billingSpecId":"BSRC001_CB","frequency":"Monthly","currency":"AUD","type":null,"rateExcludeGST":100,"quantity":"1","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_Allowance_000484_1","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Bill_AW","metadata":{},"instanceId":"","includeBilling":false,"guid":"c72c6680-a658-c856-1234-1a1a5744f7cd","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000484_1","attributes":{"SERVICEID":"","IMSI":"","billDescription":"Mobile Access Allowance","RoutingServiceType":"Mobile","value":"50","unitofMeasure":"GB","type":"Domestic Data","ocsProdID":"T22E_CWP_MOBPLAN","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_Allowance_000607_6","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Bill_AW","metadata":{},"instanceId":"","guid":"8547aa94-68db-f68c-137f-24f04c58c1ef","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000607_6","attributes":{"value":"500","unitofMeasure":"MB","type":"International Roaming Data","ocsProdID":"T22E_EMOB_IRDTP","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_Allowance_000606_5","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Bill_AW","metadata":{},"instanceId":"","guid":"af68080e-e161-399d-7250-40ea06f19506","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000606_5","attributes":{"value":"200","unitofMeasure":"MB","type":"International Roaming Data","ocsProdID":"T22E_EMOB_IRDP","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"'+servMobile.Id+'","legacyAttributes":[]}');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = servMobile.Id;
        atts.add(att1);
        insert atts;
    }
    @isTest static void testgetServiceSpec() {
        csord__service__c serv = [select id,Sim_Serial_Number__c,csordtelcoa__Service_Number__c from csord__Service__c ];
        Number__c Numberatt=[select id,Sim_Serial_Number__c,Service_Id__c,IMSI__c,Service_Number__c from Number__c];
        List<Attachment> atts = [select Id, Name, body, parentId FROM Attachment WHERE name = 'ServiceSpecifications.json'];
        Map<string,map<string,string>>ScriptMap=new Map<string,map<string,string>>();
        Map<String, String> serviceAttachmentMap = new Map<String, String>();
         serviceAttachmentMap.put('guid','4c53e7fc-bd0e-9dfc-0c86-c21d3d9a45e7');
         serviceAttachmentMap.put('SIMSerialNumber','67735364777');
         ScriptMap.put(serv.csordtelcoa__Service_Number__c ,serviceAttachmentMap);
       Test.startTest();
        UpdateServiceAndSpecs.UpdateServiceObject(ScriptMap);
       Test.stopTest();
        csord__service__c servUpdated = [select id,Sim_Serial_Number__c,csordtelcoa__Service_Number__c from csord__Service__c ];
       System.assertEquals('67735364777',servUpdated.Sim_Serial_Number__c);
    }
    @isTest static void testgetNumberObj() {
        csord__service__c serv = [select id,Sim_Serial_Number__c,csordtelcoa__Service_Number__c from csord__Service__c];
        Number__c Numberatt=[select id,Sim_Serial_Number__c,Service_Id__c,IMSI__c,Service_Number__c from Number__c];
        List<Attachment> atts = [select Id, Name, body, parentId FROM Attachment WHERE name = 'ServiceSpecifications.json'];
        Map<string,map<string,string>>ScriptMap=new Map<string,map<string,string>>();
        Map<String, String> serviceAttachmentMap = new Map<String, String>();
         serviceAttachmentMap.put('guid','4c53e7fc-bd0e-9dfc-0c86-c21d3d9a45e7');
         serviceAttachmentMap.put('SIMSerialNumber','67735364777');
         ScriptMap.put ('SVC-123456',serviceAttachmentMap);
       Test.startTest();
        UpdateServiceAndSpecs.UpdateNumberObject(ScriptMap,'123455');
       Test.stopTest();
        Number__c NumberattUpdate=[select id,Sim_Serial_Number__c,Service_Id__c,IMSI__c,Service_Number__c from Number__c];
       System.assertEquals('123455',NumberattUpdate.IMSI__c);
    }
     @isTest static void testNegativescNumberObj() {
        csord__service__c serv = [select id,Sim_Serial_Number__c,csordtelcoa__Service_Number__c from csord__Service__c];
        Number__c Numberatt=[select id,Sim_Serial_Number__c,Service_Id__c,IMSI__c,Service_Number__c from Number__c];
        List<Attachment> atts = [select Id, Name, body, parentId FROM Attachment WHERE name = 'ServiceSpecifications.json'];
        Map<string,map<string,string>>ScriptMap=new Map<string,map<string,string>>();
        Map<String, String> serviceAttachmentMap = new Map<String, String>();
         serviceAttachmentMap.put('guid','4c53e7fc-bd0e-9dfc-0c86-c21d3d9a45e7');
         serviceAttachmentMap.put('SIMSerialNumber','67735364777');
         ScriptMap.put ('SVC-123456',serviceAttachmentMap);
       Test.startTest();
        UpdateServiceAndSpecs.UpdateNumberObject(ScriptMap,'123455');
       Test.stopTest();
       System.assertEquals(null,Numberatt.IMSI__c);
    }
 }