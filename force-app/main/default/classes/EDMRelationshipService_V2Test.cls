@IsTest
public class EDMRelationshipService_V2Test {
    @testSetup static void setup() {
        Profile pf = [select Id, Name from profile where name = 'Sales Manager - Enterprise'];
        User usr = new User(Alias = 'standt', Email = 'standarduser@telestra.com',
                            EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                            LocaleSidKey = 'en_US', ProfileId = pf.Id,
                            TimeZoneSidKey = 'America/Los_Angeles', UserName = 'standarduser@telestra.com');
        insert usr;
        Account testAccount = new Account();
        testAccount.Name = 'TestAccount';
        insert testAccount;

        List<Contact> contactInsertList = new List<Contact>();

        Contact pconctact = AccountTestFactory.buildContact(testAccount, 'testPC', 'testabc122@test.com');
        contactInsertList.add(pconctact);
        Contact scontact = AccountTestFactory.buildContact(testAccount, 'testSC', 'estabc13222@testdom.com');
        contactInsertList.add(scontact);
        insert contactInsertList;

        Opportunity testOpp = new Opportunity();
        testOpp.Account = testAccount;
        testOpp.Name = 'Test Account Opportunity';
        testOpp.StageName = 'Define';
        testOpp.CloseDate = System.Date.today();
        insert testOpp;


        List<cscrm__Address__c> lstAddress = new List<cscrm__Address__c>();
        for (Integer i = 0 ; i < 100; i++) {
            cscrm__Address__c address = new cscrm__Address__c();
            address.Address_ID__c = testAccount + '--' + i;
            address.cscrm__Street__c  = testAccount + 'Street' + i;
            lstAddress.add(address);
        }
        insert lstAddress;

        List<cscrm__Site__c> lstSite = new List<cscrm__Site__c>();
        for (cscrm__Address__c address : lstAddress) {
            cscrm__Site__c  site = new cscrm__Site__c();
            site.cscrm__Floor__c = 'L-T' + address.Address_ID__c;
            site.cscrm__Installation_Address__c = address.id;
            site.cscrm__Account__c = testAccount.id;
            site.Primary_Contact__c = contactInsertList[0].id;
            site.Secondary_Contact__c = contactInsertList[1].id;
            lstSite.add(site);
        }
        insert lstSite;

        cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(
            Name = 'PD1',
            cscfga__Description__c = 'PD1 Desc',
            Snapshot_Object__c = 'CS_Basket_Snapshot_Transactional__c'
        );
        insert pd;

        List<cscfga__Attribute_Definition__c> lstAttributeDef = new List<cscfga__Attribute_Definition__c>();
        cscfga__Attribute_Definition__c ad = new cscfga__Attribute_Definition__c(
            cscfga__Product_Definition__c = pd.Id,
            Name = 'AD1',
            Snapshot_Attribute_Value_Field__c = 'Text__c',
            Snapshot_Attribute_Fields__c = 'Test'
        );

        cscfga__Attribute_Definition__c ad1 = new cscfga__Attribute_Definition__c(
            cscfga__Product_Definition__c = pd.Id,
            Name = 'Site name 2',
            Snapshot_Attribute_Value_Field__c = 'Text__c',
            Snapshot_Attribute_Fields__c = 'Test1'
        );

        cscfga__Attribute_Definition__c ad2 = new cscfga__Attribute_Definition__c(
            cscfga__Product_Definition__c = pd.Id,
            Name = 'Site Address 2',
            Snapshot_Attribute_Value_Field__c = 'Text__c',
            Snapshot_Attribute_Fields__c = 'Test2'
        );

        lstAttributeDef.add(ad);
        lstAttributeDef.add(ad1);
        lstAttributeDef.add(ad2);

        insert lstAttributeDef;

        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(
            Name = 'Test Account Opportunity Basket',
            OwnerId = UserInfo.getUserId(),
            cscfga__Opportunity__c = testOpp.Id,
            csbb__Account__c = testAccount.Id,
            csordtelcoa__Basket_Stage__c = 'Enriched'
        );
        insert basket;

        List<cscfga__Product_Configuration__c> lstpc = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c pc = new cscfga__Product_Configuration__c(
            cscfga__Product_Definition__c = pd.Id,
            cscfga__Product_Basket__c = basket.Id,
            Name = 'IP Network'
        );

        cscfga__Product_Configuration__c pc1 = new cscfga__Product_Configuration__c(
            cscfga__Product_Definition__c = pd.Id,
            cscfga__Product_Basket__c = basket.Id,
            Name = 'Connected Workplace'
        );


        lstpc.add(pc);
        lstpc.add(pc1);
        insert lstpc;
        List<cscfga__Attribute__c> lstAttribute = new List<cscfga__Attribute__c>();

        cscfga__Attribute__c att = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = lstpc[0].Id,
            Name = 'Test',
            cscfga__Value__c = '10',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = lstAttributeDef[0].Id
        );
        cscfga__Attribute__c att0 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = lstpc[1].Id,
            Name = 'Site name',
            cscfga__Value__c = '10',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = lstAttributeDef[0].Id
        );

        cscfga__Attribute__c att1 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = lstpc[1].Id,
            Name = 'Site Address',
            cscfga__Value__c = '10',
            cscfga__is_active__c = true,
            cscfga__Attribute_Definition__c = lstAttributeDef[0].Id
        );
        lstAttribute.add(att);
        lstAttribute.add(att0);
        lstAttribute.add(att1);

        insert lstAttribute;
        List<Basket_To_Order_Field_Map__c> lstBasketMap = new List<Basket_To_Order_Field_Map__c>();
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Basket_Field_Api_Name__c = 'Service_Number__c', Name = 'Service_Number__c', Order_Field_Api_Name__c = 'Service_Number__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Basket_Field_Api_Name__c = 'Billing_Account__c', Name = 'Billing_Account__c', Order_Field_Api_Name__c = 'Billing_Account__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Basket_Field_Api_Name__c = 'Maxim_Opportunity_ID__c', Name = 'Maxim_Opportunity_ID__c', Order_Field_Api_Name__c = 'Maxim_Opportunity_ID__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Basket_Field_Api_Name__c = 'Hot_Cutover__c', Name = 'Hot_Cutover__c', Order_Field_Api_Name__c = 'Hot_Cutover__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Basket_Field_Api_Name__c = 'Project_Manager_Contact_Number__c', Name = 'Project_Manager_Contact_Number__c', Order_Field_Api_Name__c = 'Project_Manager_Contact_Number__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Basket_Field_Api_Name__c = 'PM_Required__c', Name = 'PM_Required__c', Order_Field_Api_Name__c = 'PM_Required__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Basket_Field_Api_Name__c = 'Project_Complexity__c', Name = 'Project_Complexity__c', Order_Field_Api_Name__c = 'Project_Complexity__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Basket_Field_Api_Name__c = 'Project_ID__c', Name = 'Project_ID__c', Order_Field_Api_Name__c = 'Project_ID__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Basket_Field_Api_Name__c = 'Project_Manager_User_ID__c', Name = 'Project_Manager_User_ID__c', Order_Field_Api_Name__c = 'Project_Manager_User_ID__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Basket_Field_Api_Name__c = 'Hot_Cutover_Comments__c', Name = 'Hot_Cutover_Comments__c', Order_Field_Api_Name__c = 'Hot_Cutover_Comments__c'));
        lstBasketMap.add(new Basket_To_Order_Field_Map__c(Basket_Field_Api_Name__c = 'Project_Manager_Email__c', Name = 'Project_Manager_Email__c', Order_Field_Api_Name__c = 'Project_Manager_Email__c'));

        insert lstBasketMap;
    }

    @isTest static void testMethod2() {
        User usr = [select Id, UserName from User where UserName = 'standarduser@telestra.com'];

        Test.startTest();
        Account acc = [Select id from Account WHERE Name = 'TestAccount'];
        List<Id> subscriptionIds = new List<Id>();
        List<Id> orderIds = new List<Id>();
        List<Id> serviceIds = new List<Id>();

        List<csord__Order_Request__c> lstOrderReq = new List<csord__Order_Request__c>();
        for (Integer i = 0; i < 50; i++) {
            lstOrderReq.add(new csord__Order_Request__c(
                                name = 'OR-00' + i,
                                csord__Module_Name__c = 'TestReq-' + i,
                                csord__Module_Version__c = '12'
                            ));
        }
        insert lstOrderReq;
        List<Opportunity> lstOpp = [SELECT id FROM Opportunity WHERE Name = 'Test Account Opportunity'];
        List<csord__Order__c> lstOrder = new List<csord__Order__c>();
        for (csord__Order_Request__c oReq : lstOrderReq) {
            lstOrder.add(new csord__Order__c(
                             name = 'TestOrder ' + oReq.Name,
                             csord__Account__c = acc.id,
                             csord__Status2__c = 'Created',
                             csord__Order_Request__c = oReq.id,
                             csordtelcoa__Opportunity__c = lstOpp[0].id,
                             csord__Identification__c = ProductTestFactory.IDENTIFICATION,
                             stage__c = 'Being Fulfilled'));
        }
        insert lstOrder;


        List<csord__Subscription__c> lstSub = new List<csord__Subscription__c>();
        for (csord__Order__c order : lstOrder) {
            lstSub.add(new csord__Subscription__c(
                           name  = 'testSubscription ' + order.Name,
                           csord__Identification__c = 'testIdentity',
                           csord__Order__c = order.Id,
                           csord__Order_Request__c = order.csord__Order_Request__c,
                           Sub_status__c = 'Active',
                           eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e'
                       ));
        }
        insert lstSub;


        List<csord__Subscription__c> lstSubcreated = [SELECT id, csord__Order__c, csord__Order__r.csord__Order_Request__c
                FROM csord__Subscription__c];

        System.debug('>>>> lstSubcreated****' + lstSubcreated );
        List<cscfga__Product_Configuration__c> lstpc = [SELECT id FROM  cscfga__Product_Configuration__c];
        Integer i = 0;
        List<csord__Service__c> lstservs = new List<csord__Service__c>();
        for (csord__Subscription__c sub : lstSubcreated) {
            csord__Service__c serv = new csord__Service__c();
            serv.name = 'IP Network';
            serv.csord__Identification__c  = 'testIdentify_1';
            serv.csordtelcoa__Service_Number__c = '7';
            serv.csord__Subscription__c = sub.Id;
            serv.csord__Status__c = 'Service Created';
            serv.substage__c = 'Product Activation and Testing';
            serv.stage__c = 'Being Fulfilled';
            serv.csord__Order_Request__c = sub.csord__Order__r.csord__Order_Request__c;
            serv.csord__Order__c = sub.csord__Order__c;
            serv.csordtelcoa__Product_Configuration__c = lstpc[i].id;
            if (i == 0)
                i++;
            else
                i = 0;
            lstservs.add(serv);
        }

        insert lstservs;

        List<Id> serviceId = new List<Id>();
        List<Attachment> atts = new List<Attachment>();
        for (csord__Service__c serv : lstservs) {
            Attachment att1 = new Attachment();
            att1.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"' + serv.Id + '","specifications":[{"additionalAttributes":{"parentSpec":"1fba066a-4e7d-bb28-7bfe-495fae2b2066","ManagedRadiusProductInstanceID":"26eb46ab-e4e3-eb7b-4726-af867590d48f"},"attributes":{"parentSpec":"DMCAT_ProductSpecification_000028_Fulfilment","__targetSystem":"FULFILMENT","GlobalRoaming":"FALSE","APNtype":"Shared","RequiredPoolTypes":"Static IP Pool","CustomerFacingServiceId":"","ManagedRadiusProductInstanceID":"DMCAT_ProductSpecification_000053_Fulfilment"},"code":"DMCAT_ProductSpecification_000018_Fulfilment","description":"","endDate":"","guid":"364b883e-2759-0bf4-8adb-96c93be01ef9","instanceId":"","name":"IP Wireless_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"FULFILMENT","MulticastEnabled":"FALSE","CustomerFacingServiceId":"","CustomerPreferredName":""},"code":"DDMCAT_ProductSpecification_000163_Fulfilment","description":"","endDate":"","guid":"1fba066a-4e7d-bb28-7bfe-495fae2b2066","instanceId":"","name":"IP VPN_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"parentSpec":"1fba066a-4e7d-bb28-7bfe-495fae2b2066"},"attributes":{"parentSpec":"DMCAT_ProductSpecification_000028_Fulfilment","__targetSystem":"FULFILMENT","RadiusUsers":"TRUE","AuthenticationType":"Username/Password Authentication","RADIUSServerType":"Basic Telstra Managed RADIUS"},"code":"DDMCAT_ProductSpecification_000163_Fulfilment","description":"","endDate":"","guid":"26eb46ab-e4e3-eb7b-4726-af867590d48f","instanceId":"","name":"Managed Radius_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"}]}');
            att1.Name = 'ServiceSpecifications.json';
            att1.ParentId = serv.Id;
            atts.add(att1);
            serviceId.add(serv.id);
        }


        EnvironmentVariable__c envrn = new EnvironmentVariable__c(Name = 'TransitionVersion', Value__c = '3');
        insert envrn;

        insert atts;

        List<Id> lstOrderReqIds = new List<Id>();
        for (csord__Order_Request__c ordr : lstOrderReq) {
            lstOrderReqIds.add(ordr.id);
        }
        System.debug('>>>> lstOrderReqIds****' + lstOrderReqIds );
        System.debug('>>>>' + [Select Id, csord__Subscription__c,
                               csord__Subscription__r.csord__Order_Request__c
                               FROM csord__Service__c Where
                               csord__Subscription__r.csord__Order_Request__c IN: lstOrderReqIds]);

        List<Id> lstOppIds = new List<Id>();
        for (Opportunity opp : lstOpp) {
            lstOppIds.add(opp.id);
        }
        if (!lstOppIds.isEmpty()) {
            EDMRelationshipService_V2.createRelationShip(lstOppIds);
        }

        /*ObserverReferenceImplementation observer = new ObserverReferenceImplementation();
        csordtelcoa.OrderGenerationObservable o = new csordtelcoa.OrderGenerationObservable('ObserverReferenceImplementation', null,
                                                                   orderIds, subscriptionIds, serviceId,
                                                                   null, null,
                                                                   null, null,
                                                                   null);

        observer.execute(o,null);
        */
        system.assert(lstOppIds.size() > 0);
        Test.stopTest();

    }

    @isTest static void testMethod3() {
        User usr = [select Id, UserName from User where UserName = 'standarduser@telestra.com'];
        Test.startTest();
        Account acc = [Select id from Account WHERE Name = 'TestAccount'];
        List<Id> subscriptionIds = new List<Id>();
        List<Id> orderIds = new List<Id>();
        List<Id> serviceIds = new List<Id>();

        List<csord__Order_Request__c> lstOrderReq = new List<csord__Order_Request__c>();
        for (Integer i = 0; i < 50; i++) {
            lstOrderReq.add(new csord__Order_Request__c(
                                name = 'OR-00' + i,
                                csord__Module_Name__c = 'TestReq-' + i,
                                csord__Module_Version__c = '12'
                            ));
        }
        insert lstOrderReq;
        List<Opportunity> lstOpp = [SELECT id FROM Opportunity WHERE Name = 'Test Account Opportunity'];
        List<csord__Order__c> lstOrder = new List<csord__Order__c>();
        for (csord__Order_Request__c oReq : lstOrderReq) {
            lstOrder.add(new csord__Order__c(
                             name = 'TestOrder ' + oReq.Name,
                             csord__Account__c = acc.id,
                             csord__Status2__c = 'Created',
                             csord__Order_Request__c = oReq.id,
                             csordtelcoa__Opportunity__c = lstOpp[0].id,
                             csord__Identification__c = ProductTestFactory.IDENTIFICATION,
                             stage__c = 'Being Fulfilled'));
        }
        insert lstOrder;

        List<csord__Subscription__c> lstSub = new List<csord__Subscription__c>();
        for (csord__Order__c order : lstOrder) {
            lstSub.add(new csord__Subscription__c(
                           name  = 'testSubscription ' + order.Name,
                           csord__Identification__c = 'testIdentity',
                           csord__Order__c = order.Id,
                           csord__Order_Request__c = order.csord__Order_Request__c,
                           Sub_status__c = 'Active',
                           eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e'
                       ));
        }
        insert lstSub;

        List<csord__Subscription__c> lstSubcreated = [SELECT id, csord__Order__c, csord__Order__r.csord__Order_Request__c
                FROM csord__Subscription__c];

        List<cscfga__Product_Configuration__c> lstpc = [SELECT id FROM  cscfga__Product_Configuration__c];
        Integer i = 0;
        List<csord__Service__c> lstservs = new List<csord__Service__c>();
        for (csord__Subscription__c sub : lstSubcreated) {
            csord__Service__c serv = new csord__Service__c();
            serv.name = 'IP Network';
            serv.csord__Identification__c  = 'testIdentify_1';
            serv.csordtelcoa__Service_Number__c = '7';
            serv.csord__Subscription__c = sub.Id;
            serv.csord__Status__c = 'Service Created';
            serv.substage__c = 'Product Activation and Testing';
            serv.stage__c = 'Being Fulfilled';
            serv.csord__Order_Request__c = sub.csord__Order__r.csord__Order_Request__c;
            serv.csord__Order__c = sub.csord__Order__c;
            serv.csordtelcoa__Product_Configuration__c = lstpc[i].id;
            if (i == 0)
                i++;
            else
                i = 0;
            lstservs.add(serv);
        }

        insert lstservs;

        List<Id> serviceId = new List<Id>();
        List<Attachment> atts = new List<Attachment>();
        for (csord__Service__c serv : lstservs) {
            Attachment att1 = new Attachment();
            att1.Body = Blob.valueOf('{"legacyAttributes":[],"' + serv.Id + '":"a4e2O0000005Q0XQAU","specifications":[{"additionalAttributes":{},"attributes":{"__targetSystem":"FULFILMENT","MobilityPlan":"CWP Mobile Seat"},"code":"DMCAT_ProductSpecification_000420_Fulfilment","description":"","endDate":"","guid":"3dc543c0-9df9-2800-10a7-35a8788cabad","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobility_Fulfilment","productConfigurationId":"a3T2O000000In0EUAS","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"DMCAT_ProductSpecification_000420_Fulfilment":"3dc543c0-9df9-2800-10a7-35a8788cabad","parentSpec":"3dc543c0-9df9-2800-10a7-35a8788cabad"},"attributes":{"__targetSystem":"FULFILMENT","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","ShippingRequired":"TRUE","SERVICEPROFILE":"NORMAL","IPWirelessProductInstanceID":"NA","BillofMaterialID":"NA","AccessRole":"Primary","CONTEXT":"CUSTOMER","SIMSKU":"100119211","MESSAGEBANK":"3G Standard Retail","SERVICEID":"","IMSI":""},"code":"DMCAT_ProductSpecification_000263_Fulfilment","description":"","endDate":"","guid":"fdb0f9e9-6a76-b8d7-8038-373fd9c87945","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2O000000In0EUAS","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","quantity":"1","rateExcludeGST":100,"type":null,"currency":"AUD","frequency":"Monthly","billingSpecId":"BSRC001_CB","billInAdvance":"true","prorate":"false","billDescription":"CWP Mobile Seat"},"code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","description":"","endDate":"","guid":"b4703098-e806-f931-7ed3-120b621801a6","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobility_Billing_RecurringCharge_000498","productConfigurationId":"a3T2O000000In0EUAS","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_CWP_MOBPLAN","type":"Domestic Data","unitofMeasure":"GB","value":"50","RoutingServiceType":"Mobile","billDescription":"Mobile Access Allowance","IMSI":"","SERVICEID":""},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000484_1","description":"","endDate":"","guid":"44446132-7024-1610-ac24-a5627d820474","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Bill_AW","productConfigurationId":"a3T2O000000In0EUAS","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_Allowance_000484_1","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","type":"OC","currency":"AUD","billingSpecId":"BSUSG002_CB","taxTreatment":"TAX Exempt","ocsProdID":"T22E_EMOB_IRDP","billDescription":"IR Day Pass Charge","unitofMeasure":"each","rateExcludeGST":"0.00"},"code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000571","description":"","endDate":"","guid":"12ad5dcb-f59c-8f53-677f-ca65c9cee8f9","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Billing_NonRecurringCharge_000571","productConfigurationId":"a3T2O000000In0EUAS","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000571","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","type":"OC","currency":"AUD","billingSpecId":"BSUSG002_CB","taxTreatment":"TAX Exempt","unitofMeasure":"each","ocsProdID":"T22E_EMOB_IRDTP","billDescription":"IR Data topup Charge","rateExcludeGST":"0.00"},"code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000572","description":"","endDate":"","guid":"316f2d99-0b99-ee5d-7370-14a8b1aa5714","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Billing_NonRecurringCharge_000572","productConfigurationId":"a3T2O000000In0EUAS","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000572","startDate":"","status":"Created","version":"1"}]}');
            att1.Name = 'ServiceSpecifications.json';
            att1.ParentId = serv.Id;
            atts.add(att1);
            serviceId.add(serv.id);
        }

        EnvironmentVariable__c envrn = new EnvironmentVariable__c(Name = 'TransitionVersion', Value__c = '3');
        insert envrn;
        insert atts;

        List<Id> lstOrderReqIds = new List<Id>();
        for (csord__Order_Request__c ordr : lstOrderReq) {
            lstOrderReqIds.add(ordr.id);
        }

        List<Id> lstOppIds = new List<Id>();
        for (Opportunity opp : lstOpp) {
            lstOppIds.add(opp.id);
        }
        if (!lstOppIds.isEmpty()) {
            EDMRelationshipService_V2.createRelationShip(lstOppIds);
        }
        system.assert(lstOppIds.size() > 0);
        Test.stopTest();
    }

    @isTest static void testMethod4() {
        User usr = [select Id, UserName from User where UserName = 'standarduser@telestra.com'];
        Test.startTest();
        Account acc = [Select id from Account WHERE Name = 'TestAccount'];
        List<Id> subscriptionIds = new List<Id>();
        List<Id> orderIds = new List<Id>();
        List<Id> serviceIds = new List<Id>();

        List<csord__Order_Request__c> lstOrderReq = new List<csord__Order_Request__c>();
        for (Integer i = 0; i < 50; i++) {
            lstOrderReq.add(new csord__Order_Request__c(
                                name = 'OR-00' + i,
                                csord__Module_Name__c = 'TestReq-' + i,
                                csord__Module_Version__c = '12'
                            ));
        }
        insert lstOrderReq;
        List<Opportunity> lstOpp = [SELECT id FROM Opportunity WHERE Name = 'Test Account Opportunity'];
        List<csord__Order__c> lstOrder = new List<csord__Order__c>();
        for (csord__Order_Request__c oReq : lstOrderReq) {
            lstOrder.add(new csord__Order__c(
                             name = 'TestOrder ' + oReq.Name,
                             csord__Account__c = acc.id,
                             csord__Status2__c = 'Created',
                             csord__Order_Request__c = oReq.id,
                             csordtelcoa__Opportunity__c = lstOpp[0].id,
                             csord__Identification__c = ProductTestFactory.IDENTIFICATION,
                             stage__c = 'Being Fulfilled'));
        }
        insert lstOrder;

        List<csord__Subscription__c> lstSub = new List<csord__Subscription__c>();
        for (csord__Order__c order : lstOrder) {
            lstSub.add(new csord__Subscription__c(
                           name  = 'testSubscription ' + order.Name,
                           csord__Identification__c = 'testIdentity',
                           csord__Order__c = order.Id,
                           csord__Order_Request__c = order.csord__Order_Request__c,
                           Sub_status__c = 'Active',
                           eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e'
                       ));
        }
        insert lstSub;

        List<csord__Subscription__c> lstSubcreated = [SELECT id, csord__Order__c, csord__Order__r.csord__Order_Request__c
                FROM csord__Subscription__c];

        List<cscfga__Product_Configuration__c> lstpc = [SELECT id FROM  cscfga__Product_Configuration__c];
        Integer i = 0;
        List<csord__Service__c> lstservs = new List<csord__Service__c>();
        for (csord__Subscription__c sub : lstSubcreated) {
            csord__Service__c serv = new csord__Service__c();
            serv.name = 'IP Network';
            serv.csord__Identification__c  = 'testIdentify_1';
            serv.csordtelcoa__Service_Number__c = '7';
            serv.csord__Subscription__c = sub.Id;
            serv.csord__Status__c = 'Service Created';
            serv.substage__c = 'Product Activation and Testing';
            serv.stage__c = 'Being Fulfilled';
            serv.csord__Order_Request__c = sub.csord__Order__r.csord__Order_Request__c;
            serv.csord__Order__c = sub.csord__Order__c;
            serv.csordtelcoa__Product_Configuration__c = lstpc[i].id;
            if (i == 0)
                i++;
            else
                i = 0;
            lstservs.add(serv);
        }

        insert lstservs;

        List<Id> serviceId = new List<Id>();
        List<Attachment> atts = new List<Attachment>();
        for (csord__Service__c serv : lstservs) {
            Attachment att1 = new Attachment();
            att1.Body = Blob.valueOf('{"legacyAttributes":[],"'+serv.Id+'":"a4e2O0000005Q0XQAU","specifications":[{"attributes":{"__targetSystem":"FULFILMENT","MobilityPlan":"CWP Mobile Seat"},"code":"DMCAT_ProductSpecification_000420_Fulfilment","description":"","endDate":"","guid":"3dc543c0-9df9-2800-10a7-35a8788cabad","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobility_Fulfilment","productConfigurationId":"a3T2O000000In0EUAS","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","startDate":"","status":"Created","version":"1"},{"attributes":{"__targetSystem":"FULFILMENT","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","ShippingRequired":"TRUE","SERVICEPROFILE":"NORMAL","IPWirelessProductInstanceID":"NA","BillofMaterialID":"NA","AccessRole":"Primary","CONTEXT":"CUSTOMER","SIMSKU":"100119211","MESSAGEBANK":"3G Standard Retail","SERVICEID":"","IMSI":""},"code":"DMCAT_ProductSpecification_000263_Fulfilment","description":"","endDate":"","guid":"fdb0f9e9-6a76-b8d7-8038-373fd9c87945","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2O000000In0EUAS","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","startDate":"","status":"Created","version":"1"},{"attributes":{"__targetSystem":"BILLING","quantity":"1","rateExcludeGST":100,"type":null,"currency":"AUD","frequency":"Monthly","billingSpecId":"BSRC001_CB","billInAdvance":"true","prorate":"false","billDescription":"CWP Mobile Seat"},"code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","description":"","endDate":"","guid":"b4703098-e806-f931-7ed3-120b621801a6","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobility_Billing_RecurringCharge_000498","productConfigurationId":"a3T2O000000In0EUAS","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","startDate":"","status":"Created","version":"1"},{"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_CWP_MOBPLAN","type":"Domestic Data","unitofMeasure":"GB","value":"50","RoutingServiceType":"Mobile","billDescription":"Mobile Access Allowance","IMSI":"","SERVICEID":""},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000484_1","description":"","endDate":"","guid":"44446132-7024-1610-ac24-a5627d820474","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Bill_AW","productConfigurationId":"a3T2O000000In0EUAS","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_Allowance_000484_1","startDate":"","status":"Created","version":"1"},{"attributes":{"__targetSystem":"BILLING","type":"OC","currency":"AUD","billingSpecId":"BSUSG002_CB","taxTreatment":"TAX Exempt","ocsProdID":"T22E_EMOB_IRDP","billDescription":"IR Day Pass Charge","unitofMeasure":"each","rateExcludeGST":"0.00"},"code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000571","description":"","endDate":"","guid":"12ad5dcb-f59c-8f53-677f-ca65c9cee8f9","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Billing_NonRecurringCharge_000571","productConfigurationId":"a3T2O000000In0EUAS","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000571","startDate":"","status":"Created","version":"1"},{"attributes":{"__targetSystem":"BILLING","type":"OC","currency":"AUD","billingSpecId":"BSUSG002_CB","taxTreatment":"TAX Exempt","unitofMeasure":"each","ocsProdID":"T22E_EMOB_IRDTP","billDescription":"IR Data topup Charge","rateExcludeGST":"0.00"},"code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000572","description":"","endDate":"","guid":"316f2d99-0b99-ee5d-7370-14a8b1aa5714","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Billing_NonRecurringCharge_000572","productConfigurationId":"a3T2O000000In0EUAS","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000572","startDate":"","status":"Created","version":"1"}]}');
            att1.Name = 'ServiceSpecifications.json';
            att1.ParentId = serv.Id;
            atts.add(att1);
            serviceId.add(serv.id);
        }

        EnvironmentVariable__c envrn = new EnvironmentVariable__c(Name = 'TransitionVersion', Value__c = '3');
        insert envrn;
        insert atts;

        List<Id> lstOrderReqIds = new List<Id>();
        for (csord__Order_Request__c ordr : lstOrderReq) {
            lstOrderReqIds.add(ordr.id);
        }

        List<Id> lstOppIds = new List<Id>();
        for (Opportunity opp : lstOpp) {
            lstOppIds.add(opp.id);
        }
        if (!lstOppIds.isEmpty()) {
            EDMRelationshipService_V2.createRelationShip(lstOppIds);
        }
        system.assert(lstOppIds.size() > 0);
        Test.stopTest();
    }
}