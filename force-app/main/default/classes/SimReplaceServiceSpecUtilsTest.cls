/*********************************************************************************************************************************
 *Class Name      :   SimReplaceServiceSpecUtils

Test Class : SimReplaceServiceSpecUtilsTest
===============================================================================================================================

 *********************************************************************************************************************************
*/

@isTest
private class SimReplaceServiceSpecUtilsTest{
@TestSetup static void dataSetup() {
          Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        insert acc;
        
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
        csord__Order__c order = ProductTestFactory.buildOrder('PrimaryOrder', acc.id, 'Created', ordReq.id);
        order.csord__Order_Request__c = ordReq.Id;
        insert order;
        
        csord__Order__c SOrd = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        SOrd.csord__Order_Request__c = ordReq.Id;
        SOrd.csord__Primary_Order__c = order.Id;
        insert SOrd;
        
        csord__Subscription__c testSubscription = new csord__Subscription__c();
        testSubscription.Name = 'TestSubsforTest';
        testSubscription.csord__Account__c = acc.Id;
        testSubscription.csord__Order__c = SOrd.Id;
        testSubscription.csord__Identification__c = 'test';
        //testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription.csord__Status__c = 'Active';

        csord__Subscription__c testSubscription2 = new csord__Subscription__c();
        testSubscription2.Name = 'TestSubsforTest2';
        testSubscription2.csord__Account__c = acc.Id;
        testSubscription2.csord__Order__c = SOrd.Id;
        testSubscription2.csord__Identification__c = 'test2';
        //testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription2.csord__Status__c = 'Pending';

        
        csord__Subscription__c testSubscription3 = new csord__Subscription__c();
        testSubscription3.Name = 'TestSubsforTest3';
        testSubscription3.csord__Account__c = acc.Id;
        testSubscription3.csord__Order__c = SOrd.Id;
        testSubscription3.csord__Identification__c = 'test3';
        //testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription3.csord__Status__c = 'Active';

        csord__Subscription__c testSubscription4 = new csord__Subscription__c();
        testSubscription4.Name = 'TestSubsforTest4';
        testSubscription4.csord__Account__c = acc.Id;
        testSubscription4.csord__Order__c = SOrd.Id;
        testSubscription4.csord__Identification__c = 'test';
        //testSubscription4.csordtelcoa__Product_Configuration__c = testConfig1.Id;
        testSubscription4.csord__Status__c = 'Active';
        
        csord__Subscription__c testSubscription5 = new csord__Subscription__c();
        testSubscription5.Name = 'TestSubsforTest5';
        testSubscription5.csord__Account__c = acc.Id;
        testSubscription5.csord__Order__c = SOrd.Id;
        testSubscription5.csord__Identification__c = 'test';
        //testSubscription5.csordtelcoa__Product_Configuration__c = testConfig3.Id;
        testSubscription5.csord__Status__c = 'Closed Replaced';

        List<csord__Subscription__c> testSubsList = new List<csord__Subscription__c>{testSubscription,testSubscription2,testSubscription3,testSubscription4,testSubscription5};
        insert testSubsList;
        
        //service
        List<csord__Service__c> servlist=new List<csord__Service__c>();
        integer i=0;
        for(csord__Subscription__c testSubs:[SELECT Id,csord__Status__c,csord__Order__c FROM csord__Subscription__c])
        {           
            csord__Service__c serv = new csord__Service__c();
            serv.name ='testService_'+i;
            serv.csord__Identification__c  = 'testIdentify_4';
            serv.csordtelcoa__Service_Number__c = '3';
            serv.csord__Subscription__c = testSubs.Id;
            serv.csord__Status__c = 'Created';
            serv.substage__c = 'Product Requirements Validation';
            serv.csord__Order_Request__c = ordReq.Id;
            serv.csord__Order__c = testSubs.csord__Order__c;
            servlist.add(serv);
            i++;
            
        }
        insert servlist;
        // Test Data for getServiceSpecFromSubsIdForMobility
            csord__Service__c servMobile = new csord__Service__c();
            servMobile.name ='CWP Mobile 1';
            servMobile.csord__Identification__c  = 'testIdentify_4';
            servMobile.csordtelcoa__Service_Number__c = '3';
            servMobile.csord__Subscription__c = testSubscription2.Id;
            servMobile.csord__Status__c = 'Created';
            servMobile.substage__c = 'Product Requirements Validation';
            servMobile.csord__Order_Request__c = ordReq.Id;
            servMobile.csord__Order__c = testSubscription2.csord__Order__c;
        insert servMobile;
        
        //////
        List<Attachment> atts = new List<Attachment>();
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Disconnect Pending","startDate":"","specification":"30a0f36c-b496-185e-6330-c7a9c317d22c","productConfigurationId":"a0b0Y000001oXmtQAE","name":"CWPSpec","instanceId":"1234","guid":"3072dad2-5546-eb71-8e13-bd04b7f9824a","endDate":"","description":"CWP CFS Specification","code":"CWPSpec01_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","Zone":"Zone 3","TotalMRC":1500,"Seat":5,"complexIPAccess":[{"attributes":{"complexAttrPort":8080,"complexAttrTech":"Fibre"},"productConfigurationId":"a0b0Y000001oXmyQAE"},{"attributes":{"complexAttrPort":9090,"complexAttrTech":"Ethernet"},"productConfigurationId":"a0b0Y000001oXn3QAE"}],"constantName":"contantValue"}},{"version":"1","status":"Cancellation Pending","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXmyQAE","name":"IPAccessSpec","instanceId":"3456","guid":"3df57fcf-7c28-c50a-140b-0d21e80714e7","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","Port":8080,"Technology":"Fibre","constantAttr":"constantValue"}},{"version":"1","status":"Pending","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXn3QAE","name":"IPAccessSpec","instanceId":"6789","guid":"495bbebb-5166-6dce-24cd-648084f6241c","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","Port":9090,"Technology":"Ethernet","constantAttr":"constantValue"}}],"serviceId":"'+servlist[0].Id+'","legacyAttributes":[]}');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = servlist[0].Id;
        atts.add(att1);
        
        Attachment att2 = new Attachment();
        att2.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Disconnect Pending","startDate":"","specification":"30a0f36c-b496-185e-6330-c7a9c317d22c","productConfigurationId":"a0b0Y000001oXmtQAE","name":"CWPSpec","instanceId":"1234","guid":"3072dad2-5546-eb71-8e13-bd04b7f9824a","endDate":"","description":"CWP CFS Specification","code":"CWPSpec01_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","Zone":"Zone 3","TotalMRC":1500,"Seat":5,"complexIPAccess":[{"attributes":{"complexAttrPort":8080,"complexAttrTech":"Fibre"},"productConfigurationId":"a0b0Y000001oXmyQAE"},{"attributes":{"complexAttrPort":9090,"complexAttrTech":"Ethernet"},"productConfigurationId":"a0b0Y000001oXn3QAE"}],"constantName":"contantValue"}},{"version":"1","status":"Cancellation Pending","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXmyQAE","name":"IPAccessSpec","instanceId":"3456","guid":"3df57fcf-7c28-c50a-140b-0d21e80714e7","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","Port":8080,"Technology":"Fibre","constantAttr":"constantValue"}},{"version":"1","status":"Pending","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXn3QAE","name":"IPAccessSpec","instanceId":"6789","guid":"495bbebb-5166-6dce-24cd-648084f6241c","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","Port":9090,"Technology":"Ethernet","constantAttr":"constantValue"}}],"serviceId":"'+servlist[1].Id+'","legacyAttributes":[]}');
        att2.Name = 'ServiceSpecifications.json';
        att2.ParentId = servlist[1].Id;
        atts.add(att2);
        
        Attachment att3= new Attachment();
        att3.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"829aa859-b630-3838-a1f6-0cc45d1254b6","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"IMSI":"","ShippingRequired":"TRUE","DMCAT_ProductSpecification_000263_CPEDeliveryDate":"","SERVICEID":"","BillofMaterialID":"","AccessRole":"","SIMSKU":"NA","CONTEXT":"NA","MESSAGEBANK":"NA","SERVICEPROFILE":"DATA_BACKUP","__targetSystem":"FULFILMENT","IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment"},"additionalAttributes":{"IPWirelessProductInstanceID":"3abb8c65-723c-f4c8-35bf-9230430b0236"}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Bill_AW","metadata":{},"instanceId":"","includeBilling":false,"guid":"21f31282-4d7e-d137-0bd1-6a68d175f9fb","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","attributes":{"IMSI":"","SERVICEID":"","billDescription":"Mobile Interim Access Allowance","RoutingServiceType":"Mobile","value":"Unlimited","unitofMeasure":"GB","type":"Domestic Data","ocsProdID":"T22E_MIA_DATPLAN","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000571","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Billing_NonRecurringCharge_000571","metadata":{},"instanceId":"","includeBilling":false,"guid":"f0ce4f66-186f-5591-62de-e46b9fc877b7","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000571","attributes":{"rateExcludeGST":"","unitofMeasure":"each","billDescription":"IR Day Pass Charge","ocsProdID":"T22E_EMOB_IRDP","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","currency":"AUD","type":"OC","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000572","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Billing_NonRecurringCharge_000572","metadata":{},"instanceId":"","includeBilling":false,"guid":"4e0b2e72-db35-0892-f5fb-d572984ebd6b","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000572","attributes":{"rateExcludeGST":"","billDescription":"IR Data topup Charge","ocsProdID":"T22E_EMOB_IRDTP","unitofMeasure":"each","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","currency":"AUD","type":"OC","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobility_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"5311e403-e5e1-5d83-b2c1-ac90b78e1289","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Fulfilment","attributes":{"MobilityPlan":"CWP Mobile Seat","__targetSystem":"FULFILMENT"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"4c53e7fc-bd0e-9dfc-0c86-c21d3d9a45e7","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"IMSI":"","ShippingRequired":"TRUE","SERVICEID":"","MESSAGEBANK":"","SIMSKU":"100119211","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","SERVICEPROFILE":"NORMAL","__targetSystem":"FULFILMENT"},"additionalAttributes":{"parentSpec":"5311e403-e5e1-5d83-b2c1-ac90b78e1289"}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobility_Billing_RecurringCharge_000498","metadata":{},"instanceId":"","includeBilling":false,"guid":"11966645-20ef-a35d-8f66-bcbccfff31a2","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes":{"billDescription":"CWP Mobile Seat","prorate":"false","billInAdvance":"true","billingSpecId":"BSRC001_CB","frequency":"Monthly","currency":"AUD","type":null,"rateExcludeGST":100,"quantity":"1","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_Allowance_000484_1","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Bill_AW","metadata":{},"instanceId":"","includeBilling":false,"guid":"c72c6680-a658-c856-1234-1a1a5744f7cd","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000484_1","attributes":{"SERVICEID":"","IMSI":"","billDescription":"Mobile Access Allowance","RoutingServiceType":"Mobile","value":"50","unitofMeasure":"GB","type":"Domestic Data","ocsProdID":"T22E_CWP_MOBPLAN","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_Allowance_000607_6","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Bill_AW","metadata":{},"instanceId":"","guid":"8547aa94-68db-f68c-137f-24f04c58c1ef","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000607_6","attributes":{"value":"500","unitofMeasure":"MB","type":"International Roaming Data","ocsProdID":"T22E_EMOB_IRDTP","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_Allowance_000606_5","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Bill_AW","metadata":{},"instanceId":"","guid":"af68080e-e161-399d-7250-40ea06f19506","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000606_5","attributes":{"value":"200","unitofMeasure":"MB","type":"International Roaming Data","ocsProdID":"T22E_EMOB_IRDP","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"'+servlist[2].Id+'","legacyAttributes":[]}');
        att3.Name = 'ServiceSpecifications.json';
        att3.ParentId = servlist[2].Id;
        atts.add(att3);
        //create attachment
        
        Attachment att4= new Attachment();
        att4.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"829aa859-b630-3838-a1f6-0cc45d1254b6","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"IMSI":"","ShippingRequired":"TRUE","DMCAT_ProductSpecification_000263_CPEDeliveryDate":"","SERVICEID":"","BillofMaterialID":"","AccessRole":"","SIMSKU":"NA","CONTEXT":"NA","MESSAGEBANK":"NA","SERVICEPROFILE":"DATA_BACKUP","__targetSystem":"FULFILMENT","IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment"},"additionalAttributes":{"IPWirelessProductInstanceID":"3abb8c65-723c-f4c8-35bf-9230430b0236"}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Bill_AW","metadata":{},"instanceId":"","includeBilling":false,"guid":"21f31282-4d7e-d137-0bd1-6a68d175f9fb","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","attributes":{"IMSI":"","SERVICEID":"","billDescription":"Mobile Interim Access Allowance","RoutingServiceType":"Mobile","value":"Unlimited","unitofMeasure":"GB","type":"Domestic Data","ocsProdID":"T22E_MIA_DATPLAN","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000571","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Billing_NonRecurringCharge_000571","metadata":{},"instanceId":"","includeBilling":false,"guid":"f0ce4f66-186f-5591-62de-e46b9fc877b7","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000571","attributes":{"rateExcludeGST":"","unitofMeasure":"each","billDescription":"IR Day Pass Charge","ocsProdID":"T22E_EMOB_IRDP","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","currency":"AUD","type":"OC","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000572","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Billing_NonRecurringCharge_000572","metadata":{},"instanceId":"","includeBilling":false,"guid":"4e0b2e72-db35-0892-f5fb-d572984ebd6b","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000572","attributes":{"rateExcludeGST":"","billDescription":"IR Data topup Charge","ocsProdID":"T22E_EMOB_IRDTP","unitofMeasure":"each","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","currency":"AUD","type":"OC","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobility_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"5311e403-e5e1-5d83-b2c1-ac90b78e1289","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Fulfilment","attributes":{"MobilityPlan":"CWP Mobile Seat","__targetSystem":"FULFILMENT"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"4c53e7fc-bd0e-9dfc-0c86-c21d3d9a45e7","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"IMSI":"","ShippingRequired":"TRUE","SERVICEID":"","MESSAGEBANK":"","SIMSKU":"100119211","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","SERVICEPROFILE":"NORMAL","__targetSystem":"FULFILMENT"},"additionalAttributes":{"parentSpec":"5311e403-e5e1-5d83-b2c1-ac90b78e1289"}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobility_Billing_RecurringCharge_000498","metadata":{},"instanceId":"","includeBilling":false,"guid":"11966645-20ef-a35d-8f66-bcbccfff31a2","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes":{"billDescription":"CWP Mobile Seat","prorate":"false","billInAdvance":"true","billingSpecId":"BSRC001_CB","frequency":"Monthly","currency":"AUD","type":null,"rateExcludeGST":100,"quantity":"1","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_Allowance_000484_1","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Bill_AW","metadata":{},"instanceId":"","includeBilling":false,"guid":"c72c6680-a658-c856-1234-1a1a5744f7cd","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000484_1","attributes":{"SERVICEID":"","IMSI":"","billDescription":"Mobile Access Allowance","RoutingServiceType":"Mobile","value":"50","unitofMeasure":"GB","type":"Domestic Data","ocsProdID":"T22E_CWP_MOBPLAN","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_Allowance_000607_6","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Bill_AW","metadata":{},"instanceId":"","guid":"8547aa94-68db-f68c-137f-24f04c58c1ef","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000607_6","attributes":{"value":"500","unitofMeasure":"MB","type":"International Roaming Data","ocsProdID":"T22E_EMOB_IRDTP","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_Allowance_000606_5","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Bill_AW","metadata":{},"instanceId":"","guid":"af68080e-e161-399d-7250-40ea06f19506","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000606_5","attributes":{"value":"200","unitofMeasure":"MB","type":"International Roaming Data","ocsProdID":"T22E_EMOB_IRDP","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"'+servlist[2].Id+'","legacyAttributes":[]}');
        att4.Name = 'ServiceSpecifications.json';
        att4.ParentId = servMobile.Id;
        atts.add(att4);
        //create attachment
        
        
        Attachment att5= new Attachment();
        att5.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000243","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"829aa859-b630-3838-a1f6-0cc45d1254b6","endDate":"","description":"","code":"DMCAT_ProductSpecification_000243_Fulfilment","attributes":{"IMSI":"","ShippingRequired":"TRUE","DMCAT_ProductSpecification_000263_CPEDeliveryDate":"","SERVICEID":"","BillofMaterialID":"","AccessRole":"","SIMSKU":"NA","CONTEXT":"NA","MESSAGEBANK":"NA","SERVICEPROFILE":"DATA_BACKUP","__targetSystem":"FULFILMENT","IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment"},"additionalAttributes":{"IPWirelessProductInstanceID":"3abb8c65-723c-f4c8-35bf-9230430b0236"}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Bill_AW","metadata":{},"instanceId":"","includeBilling":false,"guid":"21f31282-4d7e-d137-0bd1-6a68d175f9fb","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","attributes":{"IMSI":"","SERVICEID":"","billDescription":"Mobile Interim Access Allowance","RoutingServiceType":"Mobile","value":"Unlimited","unitofMeasure":"GB","type":"Domestic Data","ocsProdID":"T22E_MIA_DATPLAN","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000571","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Billing_NonRecurringCharge_000571","metadata":{},"instanceId":"","includeBilling":false,"guid":"f0ce4f66-186f-5591-62de-e46b9fc877b7","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000571","attributes":{"rateExcludeGST":"","unitofMeasure":"each","billDescription":"IR Day Pass Charge","ocsProdID":"T22E_EMOB_IRDP","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","currency":"AUD","type":"OC","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000572","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Billing_NonRecurringCharge_000572","metadata":{},"instanceId":"","includeBilling":false,"guid":"4e0b2e72-db35-0892-f5fb-d572984ebd6b","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000572","attributes":{"rateExcludeGST":"","billDescription":"IR Data topup Charge","ocsProdID":"T22E_EMOB_IRDTP","unitofMeasure":"each","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","currency":"AUD","type":"OC","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobility_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"5311e403-e5e1-5d83-b2c1-ac90b78e1289","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Fulfilment","attributes":{"MobilityPlan":"CWP Mobile Seat","__targetSystem":"FULFILMENT"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"4c53e7fc-bd0e-9dfc-0c86-c21d3d9a45e7","endDate":"","description":"","code":"DMCAT_ProductSpecification_000243_Fulfilment","attributes":{"IMSI":"","ShippingRequired":"TRUE","SERVICEID":"","MESSAGEBANK":"","SIMSKU":"100119211","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","SERVICEPROFILE":"NORMAL","__targetSystem":"FULFILMENT"},"additionalAttributes":{"parentSpec":"5311e403-e5e1-5d83-b2c1-ac90b78e1289"}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobility_Billing_RecurringCharge_000498","metadata":{},"instanceId":"","includeBilling":false,"guid":"11966645-20ef-a35d-8f66-bcbccfff31a2","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes":{"billDescription":"CWP Mobile Seat","prorate":"false","billInAdvance":"true","billingSpecId":"BSRC001_CB","frequency":"Monthly","currency":"AUD","type":null,"rateExcludeGST":100,"quantity":"1","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_Allowance_000484_1","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Bill_AW","metadata":{},"instanceId":"","includeBilling":false,"guid":"c72c6680-a658-c856-1234-1a1a5744f7cd","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000484_1","attributes":{"SERVICEID":"","IMSI":"","billDescription":"Mobile Access Allowance","RoutingServiceType":"Mobile","value":"50","unitofMeasure":"GB","type":"Domestic Data","ocsProdID":"T22E_CWP_MOBPLAN","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_Allowance_000607_6","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Bill_AW","metadata":{},"instanceId":"","guid":"8547aa94-68db-f68c-137f-24f04c58c1ef","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000607_6","attributes":{"value":"500","unitofMeasure":"MB","type":"International Roaming Data","ocsProdID":"T22E_EMOB_IRDTP","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_Allowance_000606_5","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Bill_AW","metadata":{},"instanceId":"","guid":"af68080e-e161-399d-7250-40ea06f19506","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000606_5","attributes":{"value":"200","unitofMeasure":"MB","type":"International Roaming Data","ocsProdID":"T22E_EMOB_IRDP","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"'+servlist[2].Id+'","legacyAttributes":[]}');
        att5.Name = 'ServiceSpecifications.json';
        att5.ParentId = servlist[3].Id;
        atts.add(att5);
        //create attachment
        
        
        
        insert atts;
        
        
        
        
        /////INC000092992238
        List<ProductIdentifier__c> custList=new List<ProductIdentifier__c>();
         ProductIdentifier__c customSetting2 = new ProductIdentifier__c();
        customSetting2.Name = 'mobility';
        customSetting2.speccode__c = '000263';
        custList.add(customSetting2);
        
        ProductIdentifier__c customSetting3 = new ProductIdentifier__c();
        customSetting3.Name = 'mob_device';
        customSetting3.speccode__c = '000243';
        custList.add(customSetting3);
        
        ProductIdentifier__c customSetting4 = new ProductIdentifier__c();
        customSetting4.Name = 'NGEM_Mobility';
        customSetting4.speccode__c = '001196';
        custList.add(customSetting4 );
        
        insert custList;
    }

@isTest static void testupdateServiceSpecAttachment() {
        String speccode='DMCAT_ProductSpecification_000263_Fulfilment';
        List<String> subsIdList=new List<String>();
        for(csord__Subscription__c testSubs:[SELECT Id,csord__Status__c FROM csord__Subscription__c where csord__Status__c='Active']){
            subsIdList.add(testSubs.Id);
        }
        List<Subwrapper> subwrapList = SimReplacementController.getSimReplacementsubscription(subsIdList);
        
        Map<String,Subwrapper> SubWrapperToIdMap=new Map<String,Subwrapper>();
        for(Subwrapper subw:SimReplacementController.getSimReplacementsubscription(subsIdList)){
              SubWrapperToIdMap.put(subw.SubscriptionID,subw);
         }
        
        Map<id,csord__Service__c> Servicemap=new Map<id,csord__Service__c>([select id,
                                                     name,
                                                     csord__Status__c,
                                                     csord__Order__c,
                                                     Delivery_Address__c,
                                                     Site_Delivery_Contact__c,
                                                     Sim_Serial_Number__c,
                                                     csord__Subscription__c 
                                                     from 
                                                     csord__Service__c where csord__Subscription__c In:SubWrapperToIdMap.keySet()]);        
        Test.startTest();
        SimReplaceServiceSpecUtils.updateServiceSpecAttachment(speccode,Servicemap,SubWrapperToIdMap);
        Attachment att=[select ID, name, body, parentId from Attachment where parentId In:
        Servicemap.keyset() AND name = 'ServiceSpecifications.json' limit 1];
        String newServiceAttachmentStr = att.body.toString();
        Map<String, Object> updatedResults = (Map<String, Object>)JSON.deserializeUntyped(newServiceAttachmentStr);
        List<Object>lstSpecifications=(List<Object>)updatedResults.get('specifications');
        for(Object spec:lstSpecifications){
            Map<String, Object> specificationAttributes = (Map<String, Object>)spec;
            Map<String,Object> attributesMap = (Map<String,Object>)specificationAttributes.get('additionalAttributes');
            if(specificationAttributes!=null && specificationAttributes.get('code')=='DMCAT_ProductSpecification_000263_Fulfilment')
                System.assert(attributesMap.containskey('ShippingRequired'));
            break;
        }
        Test.stopTest();
        System.assert(SubWrapperToIdMap!=null);
    }
    
    @isTest static void testupdateServiceSpecAttachment1() {
        String speccode='DMCAT_ProductSpecification_000243_Fulfilment';
        List<String> subsIdList=new List<String>();
        for(csord__Subscription__c testSubs:[SELECT Id,csord__Status__c FROM csord__Subscription__c where csord__Status__c='Active']){
            subsIdList.add(testSubs.Id);
        }
        List<Subwrapper> subwrapList = SimReplacementController.getSimReplacementsubscription(subsIdList);
        
        Map<String,Subwrapper> SubWrapperToIdMap=new Map<String,Subwrapper>();
        for(Subwrapper subw:SimReplacementController.getSimReplacementsubscription(subsIdList)){
              SubWrapperToIdMap.put(subw.SubscriptionID,subw);
         }
        
        Map<id,csord__Service__c> Servicemap=new Map<id,csord__Service__c>([select id,
                                                     name,
                                                     csord__Status__c,
                                                     csord__Order__c,
                                                     Delivery_Address__c,
                                                     Site_Delivery_Contact__c,
                                                     Sim_Serial_Number__c,
                                                     csord__Subscription__c 
                                                     from 
                                                     csord__Service__c where csord__Subscription__c In:SubWrapperToIdMap.keySet()]);        
        Test.startTest();
        SimReplaceServiceSpecUtils.updateServiceSpecAttachment(speccode,Servicemap,SubWrapperToIdMap);
        Attachment att=[select ID, name, body, parentId from Attachment where parentId In:
        Servicemap.keyset() AND name = 'ServiceSpecifications.json' limit 1];
        String newServiceAttachmentStr = att.body.toString();
        Map<String, Object> updatedResults = (Map<String, Object>)JSON.deserializeUntyped(newServiceAttachmentStr);
        List<Object>lstSpecifications=(List<Object>)updatedResults.get('specifications');
        for(Object spec:lstSpecifications){
            Map<String, Object> specificationAttributes = (Map<String, Object>)spec;
            Map<String,Object> attributesMap = (Map<String,Object>)specificationAttributes.get('additionalAttributes');
            if(specificationAttributes!=null && specificationAttributes.get('code')=='DMCAT_ProductSpecification_000243_Fulfilment')
                System.assert(attributesMap.containskey('ShippingRequired'));
            break;
        }
        Test.stopTest();
        System.assert(SubWrapperToIdMap!=null);
    }
}