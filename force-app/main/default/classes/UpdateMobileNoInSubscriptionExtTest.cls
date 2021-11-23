/* ****************************************************************************
Class Name      : UpdateMobileNoInSubscriptionExtTest 
* Author        : Vitap Ramdevputra : DPG-2396
* Date          : 14 Aug 2020
* Description   : Update Mobile number from additional attribute.
* *****************************************************************************/
@isTest
public class UpdateMobileNoInSubscriptionExtTest {
    public static List<csord__Subscription__c> lstSubs = new list<csord__Subscription__c>();
    public static List<Attachment> atts = new List<Attachment>();
    public static LIst<csord__Service__c> lstService = new list<csord__Service__c>();

    @TestSetup static void dataSetup() {
        id prmAdmin = [select id from profile where name='Standard User'].id;

        User stuser = new User(alias = 'test123', email='b2btestewwr@noemail.com',
                                   emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                   localesidkey='en_US', Profileid = prmAdmin , country='United States',IsActive =true,
                                   timezonesidkey='America/Los_Angeles', username='b2btestewwrpdua@noemail.com');
        insert stuser;


        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        insert acc;
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        csord__Order__c SOrd = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        SOrd.csord__Order_Request__c = ordReq.Id;
        insert SOrd;


        cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('IOT Subscription','IOT Subscription');
        pd.product_Specification__c='DMCAT_ProductSpecification_000965';
        insert pd; 
        cscfga__Product_Definition__c pd1 = ProductTestFactory.buildProductDefinition('Test','Test');
        pd1.product_Specification__c='DMCAT_ProductSpecification_000871';
        insert pd1;
        cscfga__Product_Configuration__c replacedConfig = new cscfga__Product_Configuration__c();
        replacedConfig.name='IoT Annual Data Plan 1MB';
        replacedConfig.cscfga__Product_Definition__c=pd.id;
        //replacedConfig.cscfga__Product_Basket__c=basket.id;
        replacedConfig.cscfga__Description__c = 'test Description';
        replacedConfig.cscfga__Contract_Term__c = 36;
        replacedConfig.Commercial_Config__c='Yes';
        replacedConfig.Quantity_Product_Configuration__c=1;
        replacedConfig.cscfga__total_one_off_charge__c=100;
        replacedConfig.cscfga__total_recurring_charge__c=100;
        insert replacedConfig;
        cscfga__Product_Configuration__c replacedConfig2 = new cscfga__Product_Configuration__c();
        replacedConfig2.name='IoT Annual Data Plan 1MB';
        replacedConfig2.cscfga__Product_Definition__c=pd1.id;
        //replacedConfig.cscfga__Product_Basket__c=basket.id;
        replacedConfig2.cscfga__Description__c = 'test Description';
        replacedConfig2.cscfga__Contract_Term__c = 36;
        replacedConfig2.Commercial_Config__c='Yes';
        replacedConfig2.Quantity_Product_Configuration__c=1;
        replacedConfig2.cscfga__total_one_off_charge__c=100;
        replacedConfig2.cscfga__total_recurring_charge__c=100;
        insert replacedConfig2;
        csord__Subscription__c testSubscription = new csord__Subscription__c();
        testSubscription.csordtelcoa__Product_Configuration__c = replacedConfig.id;
        testSubscription.Name = 'TestSubsforTest';
        testSubscription.csord__Account__c = acc.Id;
        testSubscription.csord__Order__c = SOrd.Id;
        testSubscription.serviceMSISDN__c = '6665559999';
        testSubscription.csord__Identification__c = 'test';
        testSubscription.csord__Status__c = 'Active';
        lstSubs.add(testSubscription);


        csord__Subscription__c testSubscription2 = new csord__Subscription__c();
        testSubscription2.csordtelcoa__Product_Configuration__c = replacedConfig.id;
        testSubscription2.Name = 'TestSubsforTest2';
        testSubscription2.csord__Account__c = acc.Id;
        testSubscription2.csord__Order__c = SOrd.Id;
        testSubscription2.serviceMSISDN__c = '6665559999';
        testSubscription2.csord__Identification__c = 'test';
        testSubscription2.csord__Status__c = 'Active';
        lstSubs.add(testSubscription2);
         csord__Subscription__c testSubscription3 = new csord__Subscription__c();
        testSubscription3.csordtelcoa__Product_Configuration__c = replacedConfig2.id;
        testSubscription3.Name = 'TestSubsforTest3';
        testSubscription3.csord__Account__c = acc.Id;
        testSubscription3.csord__Order__c = SOrd.Id;
        testSubscription3.serviceMSISDN__c = '6665559999';
        testSubscription3.csord__Identification__c = 'test';
        testSubscription3.csord__Status__c = 'Active';
        lstSubs.add(testSubscription3);
        insert lstSubs;


        csord__Service__c servMobile = new csord__Service__c();
        servMobile.name ='Mobile 1';
        servMobile.csord__Identification__c  = 'testIdentify_4';
        servMobile.csordtelcoa__Service_Number__c = 'SVC-123456';
        servMobile.serviceMSISDN__c = '6665554449';
        servMobile.csord__Subscription__c = testSubscription.Id;
        servMobile.csord__Status__c = 'Created';
        servMobile.substage__c = 'Product Requirements Validation';
        servMobile.csord__Order_Request__c = ordReq.Id;
        servMobile.csord__Order__c = testSubscription.csord__Order__c;
        lstService.add(servMobile);


        csord__Service__c servMobile2 = new csord__Service__c();
        servMobile2.name ='Mobile 1x';
        servMobile2.csord__Identification__c  = 'testIdentify_4';
        servMobile2.csordtelcoa__Service_Number__c = 'SVC-123477';
        servMobile2.serviceMSISDN__c = '6665558889';
        servMobile2.csord__Subscription__c = testSubscription2.Id;
        servMobile2.csord__Status__c = 'Created';
        servMobile2.substage__c = 'Product Requirements Validation';
        servMobile2.csord__Order_Request__c = ordReq.Id;
        servMobile2.csord__Order__c = testSubscription2.csord__Order__c;
        lstService.add(servMobile2);
        csord__Service__c servMobile3 = new csord__Service__c();
        servMobile3.name ='Mobile 1xy';
        servMobile3.csord__Identification__c  = 'testIdentify_5';
        servMobile3.csordtelcoa__Service_Number__c = 'SVC-123477';
        servMobile3.serviceMSISDN__c = '6665558889';
        servMobile3.csord__Subscription__c = testSubscription3.Id;
        servMobile3.csord__Status__c = 'Created';
        servMobile3.substage__c = 'Product Requirements Validation';
        servMobile3.csord__Order_Request__c = ordReq.Id;
        servMobile3.csord__Order__c = testSubscription3.csord__Order__c;
        lstService.add(servMobile3);
        insert lstService;


        Attachment att1= new Attachment();
        att1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"829aa859-b630-3838-a1f6-0cc45d1254b6","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"IMSI":"","ShippingRequired":"TRUE","DMCAT_ProductSpecification_000263_CPEDeliveryDate":"","SERVICEID":"","BillofMaterialID":"","AccessRole":"","SIMSKU":"NA","CONTEXT":"NA","MESSAGEBANK":"NA","SERVICEPROFILE":"DATA_BACKUP","__targetSystem":"FULFILMENT","IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment"},"additionalAttributes":{"CustomerFacingServiceId":"987654154"}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Bill_AW","metadata":{},"instanceId":"","includeBilling":false,"guid":"21f31282-4d7e-d137-0bd1-6a68d175f9fb","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","attributes":{"IMSI":"","SERVICEID":"","billDescription":"Mobile Interim Access Allowance","RoutingServiceType":"Mobile","value":"Unlimited","unitofMeasure":"GB","type":"Domestic Data","ocsProdID":"T22E_MIA_DATPLAN","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000571","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Billing_NonRecurringCharge_000571","metadata":{},"instanceId":"","includeBilling":false,"guid":"f0ce4f66-186f-5591-62de-e46b9fc877b7","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000571","attributes":{"rateExcludeGST":"","unitofMeasure":"each","billDescription":"IR Day Pass Charge","ocsProdID":"T22E_EMOB_IRDP","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","currency":"AUD","type":"OC","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000572","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Billing_NonRecurringCharge_000572","metadata":{},"instanceId":"","includeBilling":false,"guid":"4e0b2e72-db35-0892-f5fb-d572984ebd6b","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000572","attributes":{"rateExcludeGST":"","billDescription":"IR Data topup Charge","ocsProdID":"T22E_EMOB_IRDTP","unitofMeasure":"each","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","currency":"AUD","type":"OC","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobility_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"5311e403-e5e1-5d83-b2c1-ac90b78e1289","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Fulfilment","attributes":{"MobilityPlan":"CWP Mobile Seat","__targetSystem":"FULFILMENT"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"4c53e7fc-bd0e-9dfc-0c86-c21d3d9a45e7","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"IMSI":"","ShippingRequired":"TRUE","SERVICEID":"","MESSAGEBANK":"","SIMSKU":"100119211","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","SERVICEPROFILE":"NORMAL","__targetSystem":"FULFILMENT"},"additionalAttributes":{"parentSpec":"5311e403-e5e1-5d83-b2c1-ac90b78e1289"}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobility_Billing_RecurringCharge_000498","metadata":{},"instanceId":"","includeBilling":false,"guid":"11966645-20ef-a35d-8f66-bcbccfff31a2","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes":{"billDescription":"CWP Mobile Seat","prorate":"false","billInAdvance":"true","billingSpecId":"BSRC001_CB","frequency":"Monthly","currency":"AUD","type":null,"rateExcludeGST":100,"quantity":"1","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_Allowance_000484_1","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Bill_AW","metadata":{},"instanceId":"","includeBilling":false,"guid":"c72c6680-a658-c856-1234-1a1a5744f7cd","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000484_1","attributes":{"SERVICEID":"","IMSI":"","billDescription":"Mobile Access Allowance","RoutingServiceType":"Mobile","value":"50","unitofMeasure":"GB","type":"Domestic Data","ocsProdID":"T22E_CWP_MOBPLAN","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_Allowance_000607_6","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Bill_AW","metadata":{},"instanceId":"","guid":"8547aa94-68db-f68c-137f-24f04c58c1ef","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000607_6","attributes":{"value":"500","unitofMeasure":"MB","type":"International Roaming Data","ocsProdID":"T22E_EMOB_IRDTP","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_Allowance_000606_5","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Bill_AW","metadata":{},"instanceId":"","guid":"af68080e-e161-399d-7250-40ea06f19506","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000606_5","attributes":{"value":"200","unitofMeasure":"MB","type":"International Roaming Data","ocsProdID":"T22E_EMOB_IRDP","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"'+servMobile.Id+'","legacyAttributes":[]}');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = servMobile.Id;
        atts.add(att1);


        Attachment att2= new Attachment();
        att2.Body = Blob.valueOf('{"specifications":{"version":"1""status":"Created",startDate":"""specification""DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"829aa859-b630-3838-a1f6-0cc45d1254b6","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"IMSI":"","ShippingRequired":"TRUE","DMCAT_ProductSpecification_000263_CPEDeliveryDate":"","SERVICEID":"","BillofMaterialID":"","AccessRole":"","SIMSKU":"NA","CONTEXT":"NA","MESSAGEBANK":"NA","SERVICEPROFILE":"DATA_BACKUP","__targetSystem":"FULFILMENT","IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment"},"additionalAttributes":{"CustomerFacingServiceId":"987654154"}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Bill_AW","metadata":{},"instanceId":"","includeBilling":false,"guid":"21f31282-4d7e-d137-0bd1-6a68d175f9fb","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","attributes":{"IMSI":"","SERVICEID":"","billDescription":"Mobile Interim Access Allowance","RoutingServiceType":"Mobile","value":"Unlimited","unitofMeasure":"GB","type":"Domestic Data","ocsProdID":"T22E_MIA_DATPLAN","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000571","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Billing_NonRecurringCharge_000571","metadata":{},"instanceId":"","includeBilling":false,"guid":"f0ce4f66-186f-5591-62de-e46b9fc877b7","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000571","attributes":{"rateExcludeGST":"","unitofMeasure":"each","billDescription":"IR Day Pass Charge","ocsProdID":"T22E_EMOB_IRDP","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","currency":"AUD","type":"OC","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000572","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Billing_NonRecurringCharge_000572","metadata":{},"instanceId":"","includeBilling":false,"guid":"4e0b2e72-db35-0892-f5fb-d572984ebd6b","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000572","attributes":{"rateExcludeGST":"","billDescription":"IR Data topup Charge","ocsProdID":"T22E_EMOB_IRDTP","unitofMeasure":"each","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","currency":"AUD","type":"OC","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobility_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"5311e403-e5e1-5d83-b2c1-ac90b78e1289","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Fulfilment","attributes":{"MobilityPlan":"CWP Mobile Seat","__targetSystem":"FULFILMENT"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"4c53e7fc-bd0e-9dfc-0c86-c21d3d9a45e7","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"IMSI":"","ShippingRequired":"TRUE","SERVICEID":"","MESSAGEBANK":"","SIMSKU":"100119211","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","SERVICEPROFILE":"NORMAL","__targetSystem":"FULFILMENT"},"additionalAttributes":{"parentSpec":"5311e403-e5e1-5d83-b2c1-ac90b78e1289"}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobility_Billing_RecurringCharge_000498","metadata":{},"instanceId":"","includeBilling":false,"guid":"11966645-20ef-a35d-8f66-bcbccfff31a2","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes":{"billDescription":"CWP Mobile Seat","prorate":"false","billInAdvance":"true","billingSpecId":"BSRC001_CB","frequency":"Monthly","currency":"AUD","type":null,"rateExcludeGST":100,"quantity":"1","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_Allowance_000484_1","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Bill_AW","metadata":{},"instanceId":"","includeBilling":false,"guid":"c72c6680-a658-c856-1234-1a1a5744f7cd","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000484_1","attributes":{"SERVICEID":"","IMSI":"","billDescription":"Mobile Access Allowance","RoutingServiceType":"Mobile","value":"50","unitofMeasure":"GB","type":"Domestic Data","ocsProdID":"T22E_CWP_MOBPLAN","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_Allowance_000607_6","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Bill_AW","metadata":{},"instanceId":"","guid":"8547aa94-68db-f68c-137f-24f04c58c1ef","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000607_6","attributes":{"value":"500","unitofMeasure":"MB","type":"International Roaming Data","ocsProdID":"T22E_EMOB_IRDTP","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_Allowance_000606_5","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Bill_AW","metadata":{},"instanceId":"","guid":"af68080e-e161-399d-7250-40ea06f19506","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000606_5","attributes":{"value":"200","unitofMeasure":"MB","type":"International Roaming Data","ocsProdID":"T22E_EMOB_IRDP","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"'+servMobile.Id+'","legacyAttributes":[]}');
        att2.Name = 'ServiceSpecifications2.json';
        att2.ParentId = servMobile2.Id;
        atts.add(att2);


        insert atts;
    }
    @isTest static void testOtherUser(){
        system.debug('other user');
        User u = [select id,profileId from user where alias = 'test123' limit 1];

        System.runAs(u){
            csord__Subscription__c subs = [Select id,serviceMSISDN__c from csord__Subscription__c where name='TestSubsforTest' limit 1];
            List<Attachment> atts = [select Id, Name, body, parentId FROM Attachment WHERE name = 'ServiceSpecifications.json'];
            List<string> lstSubsString = new list<string>{subs.id};
                Test.startTest();
            UpdateMobileNoInSubscriptionExt.updateMobileNumber(lstSubsString);
            Test.stopTest();

            system.assertEquals('Permission denied.', UpdateMobileNoInSubscriptionExt.finalMessage);
        }
    }
    @isTest static void testUpdateMobileNegative() {


        csord__Subscription__c subs = [Select id from csord__Subscription__c where name='TestSubsforTest3' limit 1];
        List<Attachment> atts = [select Id, Name, body, parentId FROM Attachment WHERE name = 'ServiceSpecifications.json'];
        List<string> lstSubsString = new list<string>{subs.id};
            Test.startTest();

        UpdateMobileNoInSubscriptionExt.updateMobileNumber(lstSubsString);
        Test.stopTest();
        system.debug('UpdateMobileNoInSubscriptionExt.finalMessage = ' + UpdateMobileNoInSubscriptionExt.finalMessage);
        system.assert(UpdateMobileNoInSubscriptionExt.finalMessage.contains('This functionality works only for updating mobile number for IoT subscriptions.'));

    }
    @isTest static void testUpdateMobileNegative2() {
        csord__Subscription__c subs = [Select id from csord__Subscription__c where name='TestSubsforTest2' limit 1];
        List<Attachment> atts = [select Id, Name, body, parentId FROM Attachment WHERE name = 'ServiceSpecifications2.json'];
        List<string> lstSubsString = new list<string>{subs.id};
            Test.startTest();


        UpdateMobileNoInSubscriptionExt.updateMobileNumber(lstSubsString);
        Test.stopTest();
        system.debug('UpdateMobileNoInSubscriptionExt.finalMessage = ' + UpdateMobileNoInSubscriptionExt.finalMessage);
        system.assert(UpdateMobileNoInSubscriptionExt.finalMessage.contains('Error'));


    }
    @isTest static void testUpdateMobileNumber() {
        csord__Subscription__c subs = [Select id, serviceMSISDN__c,Name,csordtelcoa__Product_Configuration__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name from csord__Subscription__c limit 1];
        system.debug('subsss = ' + subs);


        List<Attachment> atts = [select Id, Name, body, parentId FROM Attachment WHERE name = 'ServiceSpecifications.json'];
        List<string> lstSubsString = new list<string>{subs.id};
        Test.startTest();
        UpdateMobileNoInSubscriptionExt.updateMobileNumber(lstSubsString);
        Test.stopTest();
        csord__service__c servUpdated = [select id, name, serviceMSISDN__c from csord__service__c where name='Mobile 1'];
        System.assertEquals('6665559999',servUpdated.serviceMSISDN__c);
        system.assert(UpdateMobileNoInSubscriptionExt.finalMessage.contains('6665559999'));
    }
}