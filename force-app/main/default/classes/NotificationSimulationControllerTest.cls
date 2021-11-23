/********************************************************
Class Name : NotificationSimulationControllerTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Manish jha             10/04/2020       created

***************************************************************/
@isTest
private class NotificationSimulationControllerTest{
    
    @isTest
    private static void parsePayloadTest(){
        
         Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        acc.Customer_Status__c='Active';
        insert acc;
        System.assertNotEquals(acc.Id, null);
        //AccountTestFactory
        cscrm__Address__c addr = AccountTestFactory.buildAddress('ADR-00001');
        insert addr;
        Contact contact = AccountTestFactory.buildContact(acc, 'Smith');
        insert contact;
        cscrm__Site__c  site = AccountTestFactory.buildSite(addr.Id, acc.Id);
        site.Primary_Contact__c = contact.Id;
        insert site;
        
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.Site__c = site.Id;
        insert subs;
        //65707: Start
        //added
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
        csord__Order__c primaryOrd = ProductTestFactory.buildOrder('PrimaryOrder', acc.id, 'Created', ordReq.Id);
        primaryOrd.Csord__Order_Type__c ='test primary order';
        insert primaryOrd;
        
        csord__Order__c ord = new csord__Order__c();
        ord.csord__Identification__c = 'test identification';
        ord.csord__Account__c = acc.id;
        ord.csord__Order_Type__c = 'test order' ;
        ord.csord__Status2__c = 'In Progress';
        //added
        ord.csord__Primary_Order__c = primaryOrd.Id;
        //
        insert ord;
        //added
        cscfga__Product_Definition__c productDef = ProductTestFactory.buildProductDefinition('TestMobProduct', 'MobPlan');
        productDef.product_Specification__c = Label.MobilitySpecCode;
        insert productDef;
        
        cscfga__Product_Configuration__c prodConfig = ProductTestFactory.buildProductConfig(productDef.Id);
        insert prodConfig;
        //
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify';
        serv.csord__Subscription__c  = subs.id;
        serv.csord__Order__c = ord.id;
        serv.csordtelcoa__Service_Number__c = '3';
        //added
        serv.Site_Delivery_Contact__c = contact.Id;
        serv.csordtelcoa__Product_Configuration__c = prodConfig.id;
        insert serv;
        //End
        List<Attachment> atts = new List<Attachment>();
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+serv.id+'","specifications":[{"additionalAttributes":{"ShippingRequired":"FALSE","SimSerialNumber":"89610163332833832163","IMSI":"505013487472312","CustomerFacingServiceId":"0474872722","parentSpec":"4790c2b5-ace1-0128-e4b9-ba394253a5b6"},"attributes":{"__targetSystem":"FULFILMENT","IPWirelessProductInstanceID":"NA","BillofMaterialID":"NA","AccessRole":"Primary","CONTEXT":"CUSTOMER","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","SKU":"100119211","SuspensionContext":"NA","MESSAGEBANK":"3G Standard Retail","CustomerFacingServiceId":"","ShippingRequired":"TRUE","IMSI":"","SERVICEPROFILE":"NORMAL"},"code":"DMCAT_ProductSpecification_000263_Fulfilment","description":"Mobile Access_Fulfilment","endDate":"","guid":"884679d6-f6a7-b976-8b43-ff5c4c63cf8a","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2O000000OYdKUAW","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"FULFILMENT"},"code":"DMCAT_ProductSpecification_000420_Fulfilment","description":"Mobility_Fulfilment","endDate":"","guid":"4790c2b5-ace1-0128-e4b9-ba394253a5b6","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobility_Fulfilment","productConfigurationId":"a3T2O000000OYdKUAW","specification":"DMCAT_ProductSpecification_000420","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22EM_IR_ADDON","type":"International Roaming Data","unitofMeasure":"GB","value":"4","billingSubtype":"IR","billDescription":"International roaming add-on - 4GB"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000670","description":"Mobility_Billing_DMCAT_Allowance_000670","endDate":"","guid":"e230f1e6-d8ef-eca5-2140-14254f88e84c","includeBilling":false,"instanceId":"","metadata":{},"name":"420_AW_670","productConfigurationId":"a3T2O000000OYdKUAW","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000670_26","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","ocsProdID":"T22E_IR_USAGE","currency":"AUD","type":"OC","billingSubtype":"IR","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","billDescription":"IR Pay as you go charge","rateExcludeGST":"0.00","unitofMeasure":"each","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000263_DMCAT_NonRecurringCharge_000601_108"},"code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","description":"Mobile Access_Billing_NonRecurringCharge_000601","endDate":"","guid":"c0390411-0464-6fa0-ec17-03ead61c3e05","includeBilling":false,"instanceId":"","metadata":{},"name":"263_NRC_601","productConfigurationId":"a3T2O000000OYdKUAW","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"parentSpec":"98df0dc4-decc-62d1-a973-8bd03441fc57"},"attributes":{"__targetSystem":"ASSURANCE","parentSpec":"DMCAT_ProductSpecification_000326_Assurance","ResponseTarget":"SLA0010001","RestoreTarget":"SLA0010006"},"code":"DMCAT_ProductSpecification_000151_Assurance","description":"Incident Management_Assurance","endDate":"","guid":"fa5caf50-225e-bd79-3d3d-4ba28b3be578","includeBilling":false,"instanceId":"","metadata":{},"name":"151_ASR","productConfigurationId":"a3T2O000000OYdKUAW","specification":"DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151_2","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"ServiceManagementOption":"1","__targetSystem":"ASSURANCE"},"code":"DMCAT_ProductSpecification_000326_Assurance","description":"Telstra Managed Service Option 1_Assurance","endDate":"","guid":"98df0dc4-decc-62d1-a973-8bd03441fc57","includeBilling":false,"instanceId":"","metadata":{},"name":"326_ASR","productConfigurationId":"a3T2O000000OYdKUAW","specification":"DMCAT_ProductOffering_000420DMCAT_ProductSpecification_000326","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"ASSURANCE"},"code":"DMCAT_ProductSpecification_000421_Assurance","description":"Mobile Device Management_Assurance","endDate":"","guid":"701dc90e-9985-afff-0d39-1c8429b63ea3","includeBilling":false,"instanceId":"","metadata":{},"name":"421_ASR","productConfigurationId":"a3T2O000000OYdKUAW","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000421","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","quantity":"1","DiscountedPrice":57.27,"type":"Voice and Data","currency":"AUD","frequency":"Monthly","billingSpecId":"BSRC001_CB","billInAdvance":"true","prorate":"false","billDescription":"Corporate Mobile Plus - Executive Plan","rateExcludeGST":"109.09","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_7175"},"code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","description":"Mobility_Billing_RecurringCharge_000654","endDate":"","guid":"6c8e2399-99c0-9b7d-f4a3-b726ce381ac0","includeBilling":false,"instanceId":"","metadata":{},"name":"420_RC_654","productConfigurationId":"a3T2O000000OYdKUAW","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","value":"Premium","type":"International Direct Dial","ocsProdID":"T22E_EMOB_IDD2","billingSpecId":"BSUSG001_CB","billDescription":"International call pack - premium"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000644","description":"Mobility_Billing_DMCAT_Allowance_000644","endDate":"","guid":"4ba1bc04-c8c0-b9e6-a13f-5b14ce69b0a3","includeBilling":false,"instanceId":"","metadata":{},"name":"420_AW_644","productConfigurationId":"a3T2O000000OYdKUAW","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000644_27","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_IRDAYPASS","type":"International Roaming Data","unitofMeasure":"MB","value":"200","billingSubtype":"IR","billDescription":"IR Day Pass"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000606","description":"Mobility_Billing_DMCAT_Allowance_000606","endDate":"","guid":"442f00d4-557a-7cd4-9c8f-dfb5ed045fb4","includeBilling":false,"instanceId":"","metadata":{},"name":"263_AW_606","productConfigurationId":"a3T2O000000OYdKUAW","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000606_5","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_IR_AUTOTOPUP","type":"International Roaming Data","unitofMeasure":"MB","value":"500","billingSubtype":"IR","billDescription":"IR Data Topup"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000607","description":"Mobility_Billing_DMCAT_Allowance_000607","endDate":"","guid":"46aec056-f5d7-4d26-57b6-0a893f204093","includeBilling":false,"instanceId":"","metadata":{},"name":"263_AW_607","productConfigurationId":"a3T2O000000OYdKUAW","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000607_6","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","value":null,"unitofMeasure":null,"type":"Committed Data","ocsProdID":"T22EM_CDV-04","billingSpecId":"BSUSG001_CB","billDescription":"Committed Base Plan Allowance"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000806","description":"Mobility_Billing_DMCAT_Allowance_000806","endDate":"","guid":"70ee819a-42a0-301c-5c45-967e6f6fd225","includeBilling":false,"instanceId":"","metadata":{},"name":"420_AW_806","productConfigurationId":"a3T2O000000OYdKUAW","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000806","startDate":"","status":"Created","version":"1"}]}');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        insert att1;
        
        csord__Order__c ord1 = [SELECT id,csord__Order_Number__c FROM csord__Order__c where id = :primaryOrd.Id Limit 1];
        List<String> response = NotificationSimulationController.ParsePayload(ord1.csord__Order_Number__c, 'In Progress', 'Delivery Tracking');
        //Test.stopTest();
        System.assertNotEquals(response.size(),0);

    }

    
    

}