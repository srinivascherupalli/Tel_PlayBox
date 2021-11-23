/*
===============================================================================================================================
Developer Name : Payel
Test Class : SDWANServiceTenancyHandlerTest
===============================================================================================================================
Sr.No.    Developer Name        Date          Story Description
1.          Payel             09/06/2021      DPG-5387/DPG-5649
2.          Suyash            24/08/2021      DIGI-11880
3.          Suyash            27/09/2021      DIGI-14133
4.		   Payel			27/09/2021		DIGI-18412
===============================================================================================================================*/
@isTest
public class SDWANServiceTenancyHandlerTest {
    @TestSetup static void dataSetup() {
        Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        testAccount.Customer_Status__c = 'ACTIVE';
        insert testAccount;

        Opportunity testOpp = new Opportunity();
        testOpp.Account = testAccount;
        testOpp.Name = 'testOpp';
        testOpp.StageName = 'Define';
        testOpp.Product_Type__c = 'Modular';
        testOpp.CloseDate = System.Date.today();
        //testOpp.Type = 'New To Market';
        testOpp.Product_Domain__c = 'FIXED TELEPHONY';
        testOpp.Pricing_Method__c = 'PET';
        //testOpp.Billing_Solution__c = 'Standard';
        insert testOpp;

        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = testAccount.Id;
        testBasket.Name = 'ShowSubTestBasket';
        testBasket.cscfga__Opportunity__c = testOpp.Id;
        insert testBasket;

        List < cscfga__Product_Definition__c > pdList = new List < cscfga__Product_Definition__c > ();
        cscfga__Product_Definition__c CW_PD = new cscfga__Product_Definition__c();
        CW_PD.Name = 'SD-WAN Tenancy';
        CW_PD.product_Specification__c = 'DMCAT_ProductSpecification_001302';
        CW_PD.cscfga__Description__c = 'The root container that contains all services/offers belonging to a customer';
        CW_PD.cscfga__Active__c = true;
        CW_PD.csordtelcoa__Product_Type__c = 'Subscription';
        pdList.add(CW_PD);
		
		cscfga__Product_Definition__c CW_PD_SET = new cscfga__Product_Definition__c();
        CW_PD_SET.Name = 'SecureEdge Cloud Tenancy';
        CW_PD_SET.product_Specification__c = 'DMCAT_ProductSpecification_001370';
        CW_PD_SET.cscfga__Description__c = 'SecureEdge Cloud Tenancy';
        CW_PD_SET.cscfga__Active__c = true;
        CW_PD_SET.csordtelcoa__Product_Type__c = 'Subscription';
        pdList.add(CW_PD_SET);
        
        cscfga__Product_Definition__c CW_PD_VPN = new cscfga__Product_Definition__c();
        CW_PD_VPN.Name = 'VeloCloud SDWAN-VPN Interconnect solution';
        CW_PD_VPN.product_Specification__c = 'DMCAT_Offer_001555';
        CW_PD_VPN.cscfga__Description__c = 'VeloCloud SDWAN-VPN Interconnect solution';
        CW_PD_VPN.cscfga__Active__c = true;
        CW_PD_VPN.csordtelcoa__Product_Type__c = 'Subscription';
        pdList.add(CW_PD_VPN);
        
        cscfga__Product_Definition__c CW_PD_VPNInt = new cscfga__Product_Definition__c();
        CW_PD_VPNInt.Name = 'VeloCloud SDWAN-VPN Interconnect';
        CW_PD_VPNInt.product_Specification__c = 'DMCAT_ProductSpecification_001556';
        CW_PD_VPNInt.cscfga__Description__c = 'The root container that contains all services/offers belonging to a customer';
        CW_PD_VPNInt.cscfga__Active__c = true;
        CW_PD_VPNInt.csordtelcoa__Product_Type__c = 'Subscription';
        pdList.add(CW_PD_VPNInt);

        insert pdList;

        List < cscfga__Product_Configuration__c > prodconfigList = new List < cscfga__Product_Configuration__c > ();
        cscfga__Product_Configuration__c testConfig = new cscfga__Product_Configuration__c();
        testConfig.Name = 'SD-WAN Tenancy';
        testConfig.cscfga__Product_Basket__c = testBasket.Id;
        testConfig.cscfga__Product_Definition__c = CW_PD.id;
        prodconfigList.add(testConfig);
		
		cscfga__Product_Configuration__c testConfig_SET = new cscfga__Product_Configuration__c();
        testConfig_SET.Name = 'SecureEdge Cloud Tenancy';
        testConfig_SET.cscfga__Product_Basket__c = testBasket.Id;
        testConfig_SET.cscfga__Product_Definition__c = CW_PD_SET.id;
        prodconfigList.add(testConfig_SET);
        
        cscfga__Product_Configuration__c testConfig_VPN = new cscfga__Product_Configuration__c();
        testConfig_VPN.Name = 'Interconnect – VMWare SDWAN VPN Solution';
        testConfig_VPN.cscfga__Product_Basket__c = testBasket.Id;
        testConfig_VPN.cscfga__Product_Definition__c = CW_PD_VPN.id;
        prodconfigList.add(testConfig_VPN);
        
        cscfga__Product_Configuration__c testConfig_VPNIntr = new cscfga__Product_Configuration__c();
        testConfig_VPNIntr.Name = 'VeloCloud SDWAN-VPN Interconnect';
        testConfig_VPNIntr.cscfga__Product_Basket__c = testBasket.Id;
        testConfig_VPNIntr.cscfga__Product_Definition__c = CW_PD_VPNInt.id;
        prodconfigList.add(testConfig_VPNIntr);	
		
        insert prodconfigList;

        csord__Order__c testOrder = new csord__Order__c();
        testOrder.csord__Account__c = testAccount.Id;
        testOrder.csordtelcoa__Opportunity__c = testOpp.Id;
        testOrder.Name = 'TestOrderNameForTest';
        testOrder.csord__Identification__c = 'test';
        testOrder.isMSISDNHeld__c = false;
        insert testOrder;

        csordtelcoa__Orders_Subscriptions_Options__c testOso = new csordtelcoa__Orders_Subscriptions_Options__c();
        testOso.csordtelcoa__Subscription_Closed_Replaced_State__c = 'test2';
        testOso.csordtelcoa__Statuses_Not_Allowing_Change__c = 'false';
        insert testOso;
        
        List < csord__Subscription__c > subslist = new List < csord__Subscription__c > ();

        csord__Subscription__c testSubscription = new csord__Subscription__c();
        testSubscription.Name = 'TestSubsforTest';
        testSubscription.csord__Account__c = testAccount.Id;
        testSubscription.csord__Order__c = testOrder.Id;
        testSubscription.csord__Identification__c = 'test';
        testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
        //testSubscription.ConfigSpecID__c = 'DMCAT_ProductSpecification_001302';
        testSubscription.csord__Status__c = 'Active';
        subslist.add(testSubscription);

        csord__Subscription__c testSubscription4 = new csord__Subscription__c();
        testSubscription4.Name = 'TestSubsforTest4';
        testSubscription4.csord__Account__c = testAccount.Id;
        testSubscription4.csord__Order__c = testOrder.Id;
        testSubscription4.csord__Identification__c = 'test';
        //testSubscription4.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription4.csord__Status__c = 'Suspended';
        subslist.add(testSubscription4);
        
        csord__Subscription__c testSubscription2 = new csord__Subscription__c();
        testSubscription2.Name = 'TestSubsforTest2';
        testSubscription2.csord__Account__c = testAccount.Id;
        testSubscription2.csord__Order__c = testOrder.Id;
        testSubscription2.csord__Identification__c = 'test';
        testSubscription2.csordtelcoa__Product_Configuration__c = testConfig_SET.Id;
        //testSubscription.ConfigSpecID__c = 'DMCAT_ProductSpecification_001302';
        testSubscription2.csord__Status__c = 'Active';
        subslist.add(testSubscription2);
        
        csord__Subscription__c testSubscription_VPN = new csord__Subscription__c();
        testSubscription_VPN.Name = 'Interconnect – VMWare SDWAN VPN Solution';
        testSubscription_VPN.csord__Account__c = testAccount.Id;
        testSubscription_VPN.csord__Order__c = testOrder.Id;
        testSubscription_VPN.csord__Identification__c = 'test';
        testSubscription_VPN.csordtelcoa__Product_Configuration__c = testConfig_VPN.Id;
        //testSubscription.ConfigSpecID__c = 'DMCAT_ProductSpecification_001302';
        testSubscription_VPN.csord__Status__c = 'Active';
        subslist.add(testSubscription_VPN);
        
        csord__Subscription__c testSubscription_VPNInter = new csord__Subscription__c();
        testSubscription_VPNInter.Name = 'VeloCloud SDWAN-VPN Interconnect';
        testSubscription_VPNInter.csord__Account__c = testAccount.Id;
        testSubscription_VPNInter.csord__Order__c = testOrder.Id;
        testSubscription_VPNInter.csord__Identification__c = 'test';
        testSubscription_VPNInter.csordtelcoa__Product_Configuration__c = testConfig_VPNIntr.Id;
        //testSubscription.ConfigSpecID__c = 'DMCAT_ProductSpecification_001302';
        testSubscription_VPNInter.csord__Status__c = 'Active';
        subslist.add(testSubscription_VPNInter);
        
        insert subslist;

        List < csord__Service__c > serlist = new List < csord__Service__c > ();
        
        csord__Service__c serv = new csord__Service__c();
        serv.name = 'tst service';
        serv.csord__Identification__c = 'test identify';
        serv.csord__Subscription__c = testSubscription.id;
        serv.csord__Order__c = testOrder.id;
        serv.csordtelcoa__Service_Number__c = '3';
        serv.Tenancy_Id__c = '123';
        serlist.add(serv);
        
        csord__Service__c serv_SECT = new csord__Service__c();
        serv_SECT.name = 'tst service_SECT';
        serv_SECT.csord__Identification__c = 'test identify';
        serv_SECT.csord__Subscription__c = testSubscription2.id;
        serv_SECT.csord__Order__c = testOrder.id;
        serv_SECT.csordtelcoa__Service_Number__c = '3';
        serv_SECT.Tenancy_Id__c = '1234';
        serlist.add(serv_SECT);
        
        csord__Service__c serv_VPN = new csord__Service__c();
        serv_VPN.name = 'Interconnect – VMWare SDWAN VPN Solution';
        serv_VPN.csord__Identification__c = 'test identify';
        serv_VPN.csord__Subscription__c = testSubscription_VPN.id;
        serv_VPN.csordtelcoa__Product_Configuration__c = testConfig_VPN.id;
        serv_VPN.csord__Order__c = testOrder.id;
        serv_VPN.csordtelcoa__Service_Number__c = '3';
        serlist.add(serv_VPN);
        
        csord__Service__c serv_VPNInter = new csord__Service__c();
        serv_VPNInter.name = 'VeloCloud SDWAN-VPN Interconnect';
        serv_VPNInter.csord__Identification__c = 'test identify';
        serv_VPNInter.csord__Subscription__c = testSubscription_VPNInter.id;
        serv_VPNInter.csordtelcoa__Product_Configuration__c = testConfig_VPNIntr.id;
        serv_VPNInter.csord__Order__c = testOrder.id;
        serv_VPNInter.csordtelcoa__Service_Number__c = '3';
        serlist.add(serv_VPNInter);	
        
        insert serlist;


        List < Attachment > atts = new List < Attachment > ();
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"a4e2N0000005L2wQAE","specifications":[{"additionalAttributes":{"telstraCommittedDate":"2021-05-24T08:14:21+00:00","currentForecastedDeliveryDate":"2021-05-21T08:17:05+00:00","TenancyID":"Demo-DPG-5387","tenancyName":"Demo-DPG-5387","ServiceActivationDate":"2021-05-21T08:16:02+00:00","completionDate":"2021-05-21 18:17:08","productCompletionDate":"2021-05-21T08:16:06+00:00"},"attributes":{"__targetSystem":"FULFILMENT","TenancyID":"","template":"ADAPT S1","tenancyType":"Velocloud","tenancyName":""},"code":"DMCAT_ProductSpecification_001302_Fulfilment","description":"VeloCloud Tenancy_Fulfilment","endDate":"","guid":"1dcab76a-fd53-3823-c479-a294b481bf3b","includeBilling":false,"instanceId":"","metadata":{},"name":"VeloCloud Tenancy_Fulfilment","productConfigurationId":"a3T2N000000CPInUAO","specification":"0794ad54-35c1-71e4-07c0-68102e25c008","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{"parentSpec":"feb62663-b96d-7afd-f5b3-2b54d699ffe1"},"attributes":{"parentSpec":"DMCAT_ProductSpecification_000326_Assurance","__targetSystem":"ASSURANCE","ResponseTarget":"SLA0010001","RestoreTarget":"SLA0010006"},"code":"DMCAT_ProductSpecification_000151_Assurance","description":"Incident Management_Assurance","endDate":"","guid":"1323510f-c6ba-8d17-74b2-13a6f9b4983d","includeBilling":false,"instanceId":"","metadata":{},"name":"151_ASR","productConfigurationId":"a3T2N000000CPInUAO","specification":"05929fcb-6545-351a-5bd9-6226d653661f","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"ServiceManagementOption":"1","__targetSystem":"ASSURANCE"},"code":"DMCAT_ProductSpecification_000326_Assurance","description":"Telstra Managed Service Option 1_Assurance","endDate":"","guid":"feb62663-b96d-7afd-f5b3-2b54d699ffe1","includeBilling":false,"instanceId":"","metadata":{},"name":"326_ASR","productConfigurationId":"a3T2N000000CPInUAO","specification":"7eaf7ccc-99c4-cafa-213f-5ceab926ad21","startDate":"","status":"Created","version":"1"}]}');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        atts.add(att1);

        Attachment att2 = new Attachment();
        att2.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"c89735b8-283a-2e4b-f073-613bd822f152","productConfigurationId":"a3T2N000000DOtaUAG","name":"326_ASR","metadata":{},"instanceId":"","includeBilling":false,"guid":"ff0a3ce4-67e7-52ca-158c-c7f109832f8a","endDate":"","description":"Telstra Managed Service Option 1_Assurance","code":"DMCAT_ProductSpecification_000326_Assurance","attributes":{"__targetSystem":"ASSURANCE","ServiceManagementOption":"1"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"1fa56fc3-27d7-a761-12bd-b60805d1578e","productConfigurationId":"a3T2N000000DOtaUAG","name":"SecureEdge Cloud_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"d15060ac-4d8a-3fd5-d82d-6881dde4b72a","endDate":"","description":"SecureEdge Cloud_Fulfilment","code":"DMCAT_ProductSpecification_001368_Fulfilment","attributes":{"Bandwidth":"100 Mbps","TenancyID":"","SecureEdgeCloudTenancyProductInstanceID":"DMCAT_ProductSpecification_001370_Fulfilment","__targetSystem":"FULFILMENT"},"additionalAttributes":{"SecureEdgeCloudTenancyProductInstanceID":"fd567b8c-cd15-a673-fe5d-43a6a1e1c613"}},{"version":"1","status":"Created","startDate":"","specification":"521de632-3a80-68ab-bb1c-0df8749fdb5d","productConfigurationId":"a3T2N000000DOtaUAG","name":"1368_RC_1372","metadata":{},"instanceId":"","includeBilling":false,"guid":"a6e4453e-5dd0-7971-446a-0b0361891767","endDate":"","description":"","code":"DMCAT_ProductSpecification_001368_Billing_RecurringCharge_001372","attributes":{"chargeId":"DMCAT_RecurringCharge_001372","externalId":"DMCAT_Offer_001367_DMCAT_ProductSpecification_001368_DMCAT_RecurringCharge_001372_8227","rateExcludeGST":"420.00","billDescription":"100Mbps additional bandwidth","prorate":"false","billInAdvance":"true","billingSpecId":"BSRC001_CB","frequency":"Monthly","currencyCode":null,"quantity":"1","currency":"AUD","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"a1b28e32-dce1-ba48-fd89-67b0de80703d","productConfigurationId":"a3T2N000000DOtaUAG","name":"151_ASR","metadata":{},"instanceId":"","includeBilling":false,"guid":"c3664380-cf74-0bff-641e-0a8c7dde1b89","endDate":"","description":"Incident Management_Assurance","code":"DMCAT_ProductSpecification_000151_Assurance","attributes":{"RestoreTarget":"SLA0010006","ResponseTarget":"SLA0010001","parentSpec":"DMCAT_ProductSpecification_000326_Assurance","__targetSystem":"ASSURANCE"},"additionalAttributes":{"parentSpec":"ff0a3ce4-67e7-52ca-158c-c7f109832f8a"}}],"serviceId":"a4e2N0000005pO3QAI","legacyAttributes":[]}');
        att2.Name = 'ServiceSpecifications.json';
        att2.ParentId = serv.Id;
        atts.add(att2);

        insert atts;

        cspmb__Price_Item__c commProd = new cspmb__Price_Item__c();
        commProd.name = 'SecureEdge Add-on Bandwidth Monthly Charge';
        commProd.Bandwidth__c = '100 Mbps';
        commProd.cspmb__Recurring_Charge__c = 150.00;
        insert commProd;
        
		List<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>();

        cscfga__Attribute__c att_VPNInter = new cscfga__Attribute__c ();
		att_VPNInter.name = 'PoP';
		att_VPNInter.cscfga__Display_Value__c = 'VIC and TAS';
		att_VPNInter.cscfga__Value__c = 'VIC and TAS';
		att_VPNInter.cscfga__Product_Configuration__c = testConfig_VPNIntr.id;
		attList.add(att_VPNInter);	

		insert 	attList;

    }

    @isTest
    static void testgetData() {
        Map < String, Object > inputMap = new Map < String, Object > ();
        inputMap.put('GetTenancyDetailsforService', 'Test');
        Map < String, Object > returnMap = new Map < String, Object > ();
        Test.startTest();
        returnMap = SDWANServiceTenancyHandler.getData(inputMap);
        Test.stopTest();
        System.assert(returnMap.containsKey('GetTenancyDetailsforService'));
        System.assertNotEquals('', returnMap.get('GetTenancyDetailsforService'));
    }

    @isTest
    static void testGetTenancyDetailsforService() {
        Account resultAccount = new Account();
        Map < String, Object > updatedResults;
        Account testAccount = [SELECT id, Name FROM Account LIMIT 1];
        List < csord__Service__c > serviceList = [SELECT id,
            tenancy_id__c,
            csord__subscription__c
            FROM csord__service__c
            WHERE csord__subscription__r.csord__account__c =: testAccount.id
            AND csord__subscription__r.csord__status__c =: System.label.active
            AND csord__subscription__r.configspecid__c IN(: System.label.ConfigSpecID_for_SDWAN_VeloCloud,: System.label.ConfigSpecID_for_SDWAN_SecureEdge, : System.label.ConfigSpecID_for_SDWAN_SecureEdgeCloudTenancy)
        ];
        System.assertEquals( serviceList.size() > 0 , true);
        Test.startTest();
        String result = SDWANServiceTenancyHandler.GetTenancyDetailsforService(testAccount.id);
        Test.stopTest();
        System.assert(result != null);
        updatedResults = (Map < String, Object > ) JSON.deserializeUntyped(result);
 		System.assertNotEquals(updatedResults.get('vCguId'), '');
        System.assertNotEquals(updatedResults.get('sEgu_Id'), '');
 		System.assertEquals(updatedResults.get('sEgu_Id'), 'd15060ac-4d8a-3fd5-d82d-6881dde4b72a');
 		System.assertEquals(updatedResults.get('vCguId'), '1dcab76a-fd53-3823-c479-a294b481bf3b');
       
    }
    //DIGI-14133
    @isTest
    static void testGetCommercialProductDetails() {
        Map < String, Object > updatedResults;
        cspmb__Price_Item__c commProd = [SELECT Id, name, Bandwidth__c, cspmb__Recurring_Charge__c FROM cspmb__Price_Item__c WHERE name = 'SecureEdge Add-on Bandwidth Monthly Charge'];
        Test.startTest();
        String result = SDWANServiceTenancyHandler.GetCommercialProductDetails(commProd.id);
        Test.stopTest();
        updatedResults = (Map < String, Object > ) JSON.deserializeUntyped(result);
        System.debug('Test'+updatedResults);
        System.assertNotEquals(updatedResults.get('RecurringCharge'), '');
        System.assertNotEquals(updatedResults.get('Bandwidth'), '');
 		System.assertEquals(updatedResults.get('Bandwidth'), '100 Mbps');
 		System.assertEquals(updatedResults.get('RecurringCharge'), '150.00');
    }
    
     @isTest
    static void testGetInterConDetails() {
        Account resultAccount = new Account();
        Map < String, Object > updatedResults;
        Account testAccount = [SELECT id, Name FROM Account LIMIT 1];
        List < csord__Service__c > serviceList = [SELECT id,
                csord__subscription__r.configspecid__c,
                csordtelcoa__Product_Configuration__r.id
                FROM csord__service__c
                WHERE csord__subscription__r.csord__account__c =: testAccount.id
                AND csord__subscription__r.csord__status__c =: System.label.active
                AND csord__subscription__r.configspecid__c IN(: System.label.ConfigSpecID_for_SDWAN_InterCon)
        ];
        System.assertEquals( serviceList.size() > 0 , true);
        Test.startTest();
        cscfga__Product_Configuration__c prodConfig = [SELECT Id, Name
														FROM cscfga__Product_Configuration__c
													    WHERE Name = 'VeloCloud SDWAN-VPN Interconnect' LIMIT 1];
        String result = SDWANServiceTenancyHandler.GetInterConDetails(testAccount.id);
        Test.stopTest();
        System.assert(result != null);
        updatedResults = (Map < String, Object > ) JSON.deserializeUntyped(result);
 		System.debug ('updatedResults.ketset()====  '+updatedResults.keyset());
        System.debug ('updatedResults.get(prodConfig.id)====  '+updatedResults.get(prodConfig.id));
        Map<String, Object> Pop_Attr =  (Map<String, Object>) updatedResults.get(prodConfig.id);
        System.assertNotEquals(Pop_Attr.get('PoP'), '');
        System.assertNotEquals(Pop_Attr.get('PoP'), 'DIGI-18412');
 		System.assertEquals(Pop_Attr.get('PoP'), 'VIC and TAS');
		//System.assertEquals(updatedResults.get('vCguId'), '1dcab76a-fd53-3823-c479-a294b481bf3b');
       
    }
}