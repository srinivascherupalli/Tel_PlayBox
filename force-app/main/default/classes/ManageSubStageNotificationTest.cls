/********************************************************
Class Name : ManageSubStageNotificationTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
**********************************************************/
@isTest
public class ManageSubStageNotificationTest
{
    @Testsetup
    static void dataSetup(){
        Account acc = new Account();
        acc.Name = 'testAccount' ;
        acc.Type = 'Competitor' ;
        acc.Customer_Status__c = 'ACTIVE';
        insert acc;
        
        Opportunity testOpp = ProductTestFactory.getOpportunityBasic(acc);
        testOpp.Name = 'testOpp';
        testOpp.StageName = 'Define';
        testOpp.RetiedAccOpp__c = true;
        testOpp.CloseDate = System.Date.today();
        insert testOpp;
        
        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = acc.Id;
        testBasket.Name = 'CancelOrderTest';
        testBasket.cscfga__Opportunity__c = testOpp.Id;
        insert testBasket;
        
        
        
        cscfga__Product_Configuration__c testConfig1 = new cscfga__Product_Configuration__c();
        testConfig1.Name = System.Label.IP_Network;
        testConfig1.cscfga__Product_Basket__c = testBasket.Id;
        testConfig1.Type__c = 'Cancel'; 
        insert testConfig1;
        
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
        csord__Order_Request__c ordReq1 = ProductTestFactory.buildOrderRequest();
        insert ordReq1;
        
        csord__Order_Request__c ordReq2 = ProductTestFactory.buildOrderRequest();
        insert ordReq2;
        
        csord__Order_Request__c ordReq3 = ProductTestFactory.buildOrderRequest();
        insert ordReq3;
        
        csord__Order__c priOrd = ProductTestFactory.buildOrder('PrimaryOrder', acc.id, 'Created', ordReq1.id);
        priOrd.csordtelcoa__Opportunity__c = testOpp.Id;
        priOrd.csord__Order_Request__c = ordReq1.Id;        
        insert priOrd;
        
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csordtelcoa__Opportunity__c = testOpp.Id;
        ord.csord__Order_Request__c = ordReq.Id;
        ord.csord__Primary_Order__c = priOrd.Id;
        insert ord; 
        
        csord__Order__c ord1 = ProductTestFactory.buildOrder('TestOrder1', acc.id, 'Created', ordReq2.id);
        ord1.csordtelcoa__Opportunity__c = testOpp.Id;
        ord1.csord__Order_Request__c = ordReq2.Id;
        ord1.csord__Primary_Order__c = priOrd.Id;
        ord1.stage__c = System.Label.OrderReadyForUse;
        insert ord1;
        
        csord__Order__c ord2 = ProductTestFactory.buildOrder('TestOrder2', acc.id, 'Created', ordReq3.id);
        ord2.csordtelcoa__Opportunity__c = testOpp.Id;
        ord2.csord__Order_Request__c = ordReq3.Id;
        ord2.csord__Primary_Order__c = priOrd.Id;
        ord2.stage__c = System.Label.OrderClosed;
        insert ord2; 
        
        List<csord__Subscription__c> subList=new List<csord__Subscription__c>();
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'testSubscription';
        subs.csord__Identification__c = 'testIdentity';
        subs.csord__Order__c = ord.Id;
        subs.Sub_status__c = 'Active';
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subList.add(subs);
        
        csord__Subscription__c subs1=new csord__Subscription__c();
        subs1.name  = 'testSubscription1';
        subs1.csord__Identification__c = 'testIdentity1';
        subs1.csord__Order__c = ord.Id;
        subs1.Sub_status__c = 'Active';
        subs1.eventId__c = '9f0bfd2-2bfd-9816-552d-9e28c804294r';
        subs1.csordtelcoa__Product_Configuration__c = testConfig1.Id;
        subList.add(subs1);
        
        csord__Subscription__c subs2=new csord__Subscription__c();
        subs2.name  = 'testSubscription2';
        subs2.csord__Identification__c = 'testIdentity2';
        subs2.csord__Order__c = ord1.Id;
        subs2.Sub_status__c = 'Active';
        subs2.Trigger_RTS__c = true;
        subs2.eventId__c = '9e0bfd2-2bfd-9816-552d-9e28c804294r';
        //subs2.csordtelcoa__Product_Configuration__c = testConfig1.Id;
        subList.add(subs2);
        
        csord__Subscription__c subs3=new csord__Subscription__c();
        subs3.name  = 'Connected Workplace';
        subs3.csord__Identification__c = 'Subscription_a3T2O000000BQ8WUAW_0';
        subs3.csord__Order__c = ord1.Id;
        subs3.Sub_status__c = 'Active';
        subs3.eventId__c = '9e1bfd2-2bfd-9816-552d-9e28c804294r';
        //subs2.csordtelcoa__Product_Configuration__c = testConfig1.Id;
        subList.add(subs3);
        
        insert subList;
        
        List<csord__Service__c> servs = new List<csord__Service__c>();
        csord__Service__c serv = new csord__Service__c();
        serv.name ='testService_1';
        serv.csord__Identification__c  = 'testIdentify_1';
        serv.csordtelcoa__Service_Number__c = '3';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Status__c = 'Created';
        serv.substage__c = 'Product Activation and Testing';
        serv.stage__c = 'Being Fulfilled';
        serv.csord__Order_Request__c = ordReq.Id;
        serv.csord__Order__c = ord.Id;
        servs.add(serv);
        
        csord__Service__c serv1 = new csord__Service__c();
        serv1.name ='testService_2';
        serv1.csord__Identification__c  = 'testIdentify_2';
        serv1.csordtelcoa__Service_Number__c = '3';
        serv1.csord__Subscription__c = subs.Id;
        serv1.csord__Status__c = 'Created';
        serv.substage__c = 'Product Requirements Validation';
        serv.stage__c = 'Received';
        serv1.csord__Order_Request__c = ordReq.Id;
        serv1.csord__Order__c = ord.Id;
        servs.add(serv1);
        
        csord__Service__c serv2 = new csord__Service__c();
        serv2.name ='testService_3';
        serv2.csord__Identification__c  = 'testIdentify_3';
        serv2.csordtelcoa__Service_Number__c = '3';
        serv2.csord__Subscription__c = subs1.Id;
        serv2.csord__Status__c = 'Created';
        serv2.substage__c = 'Logical Deactivation';
        serv2.csordtelcoa__Product_Configuration__c = testConfig1.Id;
        serv2.csord__Order_Request__c = ordReq.Id;
        serv2.csord__Order__c = ord.Id;
        servs.add(serv2);
        
        csord__Service__c serv3 = new csord__Service__c();
        serv3.name ='testService_4';
        serv3.csord__Identification__c  = 'testIdentify_4';
        serv3.csordtelcoa__Service_Number__c = '3';
        serv3.csord__Subscription__c = subs1.Id;
        serv3.csord__Status__c = 'Created';
        serv3.substage__c = 'Product Requirements Validation';
        serv3.csordtelcoa__Product_Configuration__c = testConfig1.Id;
        serv3.csord__Order_Request__c = ordReq.Id;
        serv3.csord__Order__c = ord.Id;
        servs.add(serv3);
        
        csord__Service__c serv4 = new csord__Service__c();
        serv4.name ='testService_5';
        serv4.csord__Identification__c  = 'testIdentify_5';
        serv4.csordtelcoa__Service_Number__c = '3';
        serv4.csord__Subscription__c = subs1.Id;
        serv4.csord__Status__c = 'Created';
        serv4.substage__c = 'Customer Order Acceptance';
        serv4.csordtelcoa__Product_Configuration__c = testConfig1.Id;
        serv4.csord__Order_Request__c = ordReq.Id;
        serv4.csord__Order__c = ord.Id;
        servs.add(serv4);
        
        csord__Service__c serv5 = new csord__Service__c();
        serv5.name ='testService_6';
        serv5.csord__Identification__c  = 'testIdentify_6';
        serv5.csordtelcoa__Service_Number__c = '3';
        serv5.csord__Subscription__c = subs1.Id;
        serv5.csord__Status__c = 'Created';
        serv5.substage__c = System.Label.ProductCompletionNotice;
        serv5.csordtelcoa__Product_Configuration__c = testConfig1.Id;
        serv5.csord__Order_Request__c = ordReq.Id;
        serv5.csord__Order__c = ord.Id;
        servs.add(serv5);
        
        csord__Service__c serv6 = new csord__Service__c();
        serv6.name ='IP Site';
        serv6.csord__Identification__c  = 'Service_a3T2O000000BQ8XUAW_0';
        serv6.csordtelcoa__Service_Number__c = 'SVC-000023451';
        serv6.csord__Subscription__c = subs3.Id;
        serv6.csord__Status__c = 'Disconnect Pending';          
        serv6.substage__c = 'Logical Deactivation';
        serv6.csordtelcoa__Product_Configuration__c = testConfig1.Id;
        serv6.csord__Order_Request__c = ordReq.Id;
        serv6.csord__Order__c = ord.Id;
        servs.add(serv6);
        insert servs;
        
        List<Service_Specification__c> servSpecList = new List<Service_Specification__c>();
        Service_Specification__c servSpec = new Service_Specification__c();
        servSpec.Name = 'Mobile Access_Fulfilment';
        servSpec.Service__c = serv6.id;
        servSpec.Code__c ='DMCAT_ProductSpecification_000263';
        servSpec.GUID__c = 'dabc3fdb-332e-c8ee-e853-24f41182c4d7';
        servSpecList.add(servSpec);
        
        Service_Specification__c servSpec1 = new Service_Specification__c();
        servSpec1.Name = 'UC Site_Fulfilment';
        servSpec1.Service__c = serv6.id;
        servSpec1.Code__c ='DMCAT_ProductSpecification_000322';
        servSpec1.GUID__c = 'e4b35ea7-c933-80cc-f3a1-4969969dbf8b';
        servSpecList.add(servSpec1);
        
        insert servSpecList;
        
        
        
        subStageNotification__c subStageNotif = new subStageNotification__c();
        subStageNotif.Name = 'Logical Deactivation';
        subStageNotif.Service_Specification__c= servSpec.id;
        subStageNotif.Substage_Completion_Date__c=System.Date.today();
        insert subStageNotif;
        
        List<Attachment> atts = new List<Attachment>();
        Attachment att1 = new Attachment();
        //updated for EDGE-116041
        att1.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+serv.Id+'","specifications":[{"additionalAttributes":{"parentSpec":"1fba066a-4e7d-bb28-7bfe-495fae2b2066","ManagedRadiusProductInstanceID":"26eb46ab-e4e3-eb7b-4726-af867590d48f"},"attributes":{"parentSpec":"DMCAT_ProductSpecification_000028_Fulfilment","__targetSystem":"FULFILMENT","GlobalRoaming":"FALSE","APNtype":"Shared","RequiredPoolTypes":"Static IP Pool","CustomerFacingServiceId":"","ManagedRadiusProductInstanceID":"DMCAT_ProductSpecification_000053_Fulfilment","NetworkServiceId":""},"code":"DMCAT_ProductSpecification_000018_Fulfilment","description":"","endDate":"","guid":"364b883e-2759-0bf4-8adb-96c93be01ef9","instanceId":"","name":"IP Wireless_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"FULFILMENT","MulticastEnabled":"FALSE","CustomerFacingServiceId":"","CustomerPreferredName":"","NetworkServiceId":""},"code":"DMCAT_ProductSpecification_000028_Fulfilment","description":"","endDate":"","guid":"1fba066a-4e7d-bb28-7bfe-495fae2b2066","instanceId":"","name":"IP VPN_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"parentSpec":"1fba066a-4e7d-bb28-7bfe-495fae2b2066"},"attributes":{"parentSpec":"DMCAT_ProductSpecification_000028_Fulfilment","__targetSystem":"FULFILMENT","RadiusUsers":"TRUE","AuthenticationType":"Username/Password Authentication","RADIUSServerType":"Basic Telstra Managed RADIUS","NetworkServiceId":""},"code":"DMCAT_ProductSpecification_000053_Fulfilment","description":"","endDate":"","guid":"26eb46ab-e4e3-eb7b-4726-af867590d48f","instanceId":"","name":"Managed Radius_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"}]}');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        atts.add(att1);
        
        Attachment att2 = new Attachment();
        att2.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","productConfigurationId":"a3T2O0000008D0IUAU","name":"Unified Communication Enterprise_Fulfilment","instanceId":"","guid":"cf0159c5-997f-f39b-5233-dbedc2cecdbf","endDate":"","description":"","code":"DMCAT_ProductSpecification_000087_Fulfilment","attributes":{"DomainName":"","OverviewofProposedSolution":"","CustomerPreferredName":"","CustomerFacingServiceId":"","ModuleGroupType":"","EnterpriseExtensionDialling":"TRUE","__targetSystem":"FULFILMENT"},"additionalAttributes":{}}],"serviceId":"'+serv1.Id+'","legacyAttributes":[]}');
        att2.Name = 'ServiceSpecifications.json';
        att2.ParentId = serv1.Id;
        atts.add(att2);
        
        Attachment att3 = new Attachment();
        att3.Body = Blob.valueOf('{ "specifications" :[{ "version" : "1", "status" : "Created", "startDate" : "", "specification" : "DMCAT_ProductOffering_000302DMCAT_ProductSpecification_000163", "productConfigurationId" : "a3T2O000000AyAnUAK", "name" : "Internet Protection Solution_Fulfilment", "instanceId" : "", "includeBilling" : false, "guid" : "df7b0d41-a1e4-d108-a8fb-8d5548ded172", "endDate" : "", "description" : "", "code" : "DMCAT_ProductSpecification_000163_Fulfilment", "attributes" : { "TotalNumberofUsers" : "", "CustomerFacingServiceId" : "", "InternetProtectionSolutionType" : "web and mail", "__targetSystem" : "FULFILMENT", "EnterpriseInternetProductInstanceID" : "" }, "additionalAttributes" : { "ServiceDeactivationDate" : "2018-08-18T05:30:30Z", "currentForecastedDeliveryDate" : "2018-08-18T05:30:30Z", "CustomerFacingServiceId" : "CFS11" } }, { "version" : "1", "status" : "Created", "startDate" : "", "specification" : "DMCAT_ProductOffering_000302DMCAT_ProductSpecification_000028", "productConfigurationId" : "a3T2O000000AyAnUAK", "name" : "IP VPN_Fulfilment", "instanceId" : "", "includeBilling" : false, "guid" : "32a9f7b0-d67e-d567-f6f8-d698ff62f621", "endDate" : "", "description" : "", "code" : "DMCAT_ProductSpecification_000028_Fulfilment", "attributes" : { "CustomerPreferredName" : "", "CustomerFacingServiceId" : "", "MulticastEnabled" : "FALSE", "__targetSystem" : "FULFILMENT" }, "additionalAttributes" : { } }, { "version" : "1", "status" : "Created", "startDate" : "", "specification" : "DMCAT_ProductSpecification_000028DMCAT_ProductSpecification_000018", "productConfigurationId" : "a3T2O000000AyAnUAK", "name" : "IP Wireless_Fulfilment", "instanceId" : "", "includeBilling" : false, "guid" : "fefaa9dd-7fa2-933e-4589-a8374adfe28d", "endDate" : "", "description" : "", "code" : "DMCAT_ProductSpecification_000018_Fulfilment", "attributes" : { "RequiredPoolTypes" : "Static", "CustomerFacingServiceId" : "", "APNtype" : "Shared", "GlobalRoaming" : "FALSE", "__targetSystem" : "FULFILMENT", "ManagedRadiusProductInstanceID" : "DMCAT_ProductSpecification_000053_Fulfilment", "parentSpec" : "DMCAT_ProductSpecification_000028_Fulfilment" }, "additionalAttributes" : { } }, { "version" : "1", "status" : "Created", "startDate" : "", "specification" : "DMCAT_ProductOffering_000302DMCAT_ProductSpecification_000338", "productConfigurationId" : "a3T2O000000AyAnUAK", "name" : "Firewall_Fulfilment", "instanceId" : "", "includeBilling" : false, "guid" : "675d778e-611c-ceda-e5ad-28a3e5aa4955", "endDate" : "", "description" : "", "code" : "DMCAT_ProductSpecification_000338_Fulfilment", "attributes" : { "NetworkServiceRef" : "", "CustomerFacingServiceId" : "", "LicenseSize" : "VM-50", "Bandwidth" : "100 Mbps", "Latency" : "Best Effort", "__targetSystem" : "FULFILMENT", "IPVPNProductInstanceID" : "DMCAT_ProductSpecification_000028_Fulfilment" }, "additionalAttributes" : { } }, { "version" : "1", "status" : "Created", "startDate" : "", "specification" : "DMCAT_ProductSpecification_000028DMCAT_ProductSpecification_000053", "productConfigurationId" : "a3T2O000000AyAnUAK", "name" : "Managed Radius_Fulfilment", "instanceId" : "", "includeBilling" : false, "guid" : "a4660660-47c8-0b49-757e-9601bad98951", "endDate" : "", "description" : "", "code" : "DMCAT_ProductSpecification_000053_Fulfilment", "attributes" : { "RADIUSServerType" : "Basic Telstra Managed RADIUS", "AuthenticationType" : "Username/Password Authentication", "RadiusUsers" : "TRUE", "__targetSystem" : "FULFILMENT", "parentSpec" : "DMCAT_ProductSpecification_000028_Fulfilment" }, "additionalAttributes" : { } } ], "serviceId":"'+serv2.Id+'","legacyAttributes":[]}');
        att3.Name = 'ServiceSpecifications.json';
        att3.ParentId = serv2.Id;
        atts.add(att3);
        
        
        Attachment att4 = new Attachment();
        att4.Body = Blob.valueOf('{ "legacyAttributes" : [ ], "serviceId" : "a4e2O0000004sO6QAI", "specifications" : [ { "additionalAttributes" : { "SERVICEID" : "61474821599", "IPWirelessProductInstanceID" : "9051ae65-fe01-f77c-ab34-bf926c97288a" }, "attributes" : { "IPWirelessProductInstanceID" : "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem" : "FULFILMENT", "SERVICEPROFILE" : "DATA_BACKUP", "ShippingRequired" : "TRUE", "Plan" : "Backup", "IMSI" : "", "AccessRole" : "Primary", "BillofMaterialID" : "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID" : "", "DMCAT_ProductSpecification_000263_CPEDeliveryDate" : "" }, "code" : "DMCAT_ProductSpecification_000263_Fulfilment", "description" : "", "endDate" : "", "guid" : "413d96f7-d8b1-84fe-9681-17f4b3b0518a", "includeBilling" : false, "instanceId" : "", "name" : "Mobile Access_Fulfilment", "productConfigurationId" : "a3T2O000000B2LpUAK", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate" : "", "status" : "In Progress", "version" : "1" }, { "additionalAttributes" : { }, "attributes" : { "__targetSystem" : "ASSURANCE", "ServiceManagementOption " : "1" }, "code" : "DMCAT_ProductSpecification_000326_Assurance", "description" : "", "endDate" : "", "guid" : "5b5b91d6-8afe-304b-bec8-e64b94408777", "includeBilling" : false, "instanceId" : "", "name" : "Telstra Managed Service Option 1_Assurance", "productConfigurationId" : "a3T2O000000B2LpUAK", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000326", "startDate" : "", "status" : "Created", "version" : "1" }, { "additionalAttributes" : { "BSServiceTypeProductInstanceID" : "2de07d13-9ad0-b127-9381-06bff58e4caa" }, "attributes" : { "BSServiceTypeProductInstanceID" : "DMCAT_ProductSpecification_000312_Fulfilment", "__targetSystem" : "FULFILMENT", "CustomerFacingServiceId" : "", "CustomerPreferredName" : "", "DMCAT_ProductSpecification_000322_CPEDeliveryDate" : "" }, "code" : "DMCAT_ProductSpecification_000322_Fulfilment", "description" : "", "endDate" : "", "guid" : "0fe39634-5caf-9786-5804-95623e065e39", "includeBilling" : false, "instanceId" : "", "name" : "UC Site_Fulfilment", "productConfigurationId" : "a3T2O000000B2LpUAK", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000322", "startDate" : "", "status" : "In Progress", "version" : "1" }, { "additionalAttributes" : { "InternetProtectionSolutionProductInstanceID" : "74701806-0b7f-afa1-d088-7cf4012ed6dc" }, "attributes" : { "__targetSystem" : "FULFILMENT", "UserProtectionType" : "Web and Mail", "InternetProtectionSolutionProductInstanceID" : "DMCAT_ProductSpecification_000163_Fulfilment", "Quantity" : "4" }, "code" : "DMCAT_ProductSpecification_000162_Fulfilment", "description" : "", "endDate" : "", "guid" : "a657ffa6-5872-e96e-1c2d-93f53f2b4708", "includeBilling" : false, "instanceId" : "", "name" : "Web and Mail Internet Protection User_Fulfilment", "productConfigurationId" : "a3T2O000000B2LpUAK", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000162", "startDate" : "", "status" : "In Progress", "version" : "1" }, { "additionalAttributes" : { "parentSpec" : "5b5b91d6-8afe-304b-bec8-e64b94408777" }, "attributes" : { "__targetSystem" : "ASSURANCE", "parentSpec" : "DMCAT_ProductSpecification_000326_Assurance", "ResponseTarget" : "2 Hours", "RestoreTarget" : "12 Hours" }, "code" : "DMCAT_ProductSpecification_000151_Assurance", "description" : "", "endDate" : "", "guid" : "098e8726-4356-4475-df5b-daaa829510fc", "includeBilling" : false, "instanceId" : "", "name" : "Incident Management_Assurance", "productConfigurationId" : "a3T2O000000B2LpUAK", "specification" : "DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151", "startDate" : "", "status" : "Created", "version" : "1" }, { "additionalAttributes" : { "parentSpec" : "0fe39634-5caf-9786-5804-95623e065e39" }, "attributes" : { "__targetSystem" : "FULFILMENT", "name" : "Hosted UC", "CustomerFacingServiceId" : "", "id" : "", "Quantity" : "", "parentSpec" : "DMCAT_ProductSpecification_000322_Fulfilment" }, "code" : "DMCAT_ProductSpecification_000315_Fulfilment", "description" : "", "endDate" : "", "guid" : "c4dacc21-073c-057c-39e8-86f7f5cac50a", "includeBilling" : false, "instanceId" : "", "name" : "Feature Packs_Fulfilment", "productConfigurationId" : "a3T2O000000B2LpUAK", "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000315", "startDate" : "", "status" : "In Progress", "version" : "1" }, { "additionalAttributes" : { "parentSpec" : "0fe39634-5caf-9786-5804-95623e065e39" }, "attributes" : { "parentSpec" : "DMCAT_ProductSpecification_000322_Fulfilment", "__targetSystem" : "FULFILMENT", "VoicePlan" : "Complete Premium", "id" : "", "CustomerFacingServiceId" : "", "Number" : [ { "schemaId" : "25e92124-d637-4b90-4b1d-e5602d51c955", "attributes" : { "FNN" : "1111111111", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "298c8f72-ac0d-8352-bc4d-c16580ee9e5b", "attributes" : { "FNN" : "2222222222", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "59980903-98db-85f6-7412-295b72f2c7d2", "attributes" : { "FNN" : "3333333333", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "12657f70-e296-8bf1-a28f-5429d9557c29", "attributes" : { "FNN" : "8282345567", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "405c8734-e4f1-27bb-080d-418df5c11b84", "attributes" : { "FNN" : "8282345566", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "de85e26d-cf15-2218-eea5-9737788de49c", "attributes" : { "FNN" : "8282345568", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "c9999e2f-4fce-5f19-4163-9164a0608e9a", "attributes" : { "FNN" : "8282345569", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "fb2a51cc-a339-04ad-d79c-cb65fd47b50c", "attributes" : { "FNN" : "8282345516", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "59227f11-f3c5-66cc-0c63-014f99a1dcfd", "attributes" : { "FNN" : "8282345526", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "2c524a20-853e-3964-7726-7b0bd54bc83b", "attributes" : { "FNN" : "8282345536", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "d9da20fc-288d-6f33-faa5-9d62a63e8555", "attributes" : { "FNN" : "8282345546", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } } ] }, "code" : "DMCAT_ProductSpecification_000313_Fulfilment", "description" : "", "endDate" : "", "guid" : "cadee771-3fdc-28fa-2df6-ef5608e8c916", "includeBilling" : false, "instanceId" : "", "name" : "UC Numbers_Fulfilment", "productConfigurationId" : "a3T2O000000B2LpUAK", "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313", "startDate" : "", "status" : "In Progress", "version" : "1" } ] }');
        att4.Name = 'ServiceSpecifications.json';
        att4.ParentId = serv2.Id;
        atts.add(att4);
        
        insert atts;
        
    }
    
    @isTest
    static void testProcessNotificationRec(){
        
        csord__Subscription__c sub1 = [SELECT Id, Sub_status__c, Name from csord__Subscription__c where name ='testSubscription1' LIMIT 1];
        String subId = sub1.id;
        
        Set<String> guidSet = new Set<String>();
        csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c,csord__Subscription__r.Name, Name from csord__Service__c where Name = 'testService_1' limit 1][0];
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
        List<String> parameters = new List<String>();
        Notification__c notif = new Notification__c();
        notif.externalOrderId__c = ord.csord__Order_Number__c;
        notif.eventTimeStamp__c = '2018-08-15T06:08+05:00';
        notif.orderItemId__c = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|1fba066a-4e7d-bb28-7bfe-495fae2b2066';
        notif.notificationAttributes__c = '"attributes": [{"name": "LogisticOrderNumber","value": "Product Activation and Testing"},{"name": "Equipment Ordered","value": "Product Activation and Testing"},{"name": "subStage","value": "Product Activation and Testing"},{"name": "ServiceActivationDate","value": "2018-08-10T16:48:39Z"}]';
        notif.orderItemDetails__c = '"product": {"productId": "1fba066a-4e7d-bb28-7bfe-495fae2b2066","status": "In Progress","attributes": [{"name": "CustomerFacingServiceId","value": "N1111"}],"childProduct": [{"productId": "364b883e-2759-0bf4-8adb-96c93be01ef9","status": "complete","attributes": [{"name": "CustomerFacingServiceId","value": "N2222"}]},{"productId": "26eb46ab-e4e3-eb7b-4726-af867590d48f","status": "complete","attributes": [{"name": "CustomerFacingServiceId","value": "N3333"}]}]}';
        notif.eventType__c = 'subStageNotification';
        notif.sourceSystem__c = 'Fulfilment';
        notif.Status__c = 'Pending';
        notif.orderItemVersion__c = 1;
        insert notif;
        
        //parameters.add(ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|6789:::"attributes": [{"name": "subStage","value": "Product Activation and Testing"},{"name": "ServiceActivationDate","value": "2018-08-10T16:48:39Z"}]:::subStageNotification:::"product": {"productId": "1fba066a-4e7d-bb28-7bfe-495fae2b2066","status": "In Progress","attributes": [{"name": "CustomerFacingServiceId","value": "N1111"}],"childProduct": [{"productId": "364b883e-2759-0bf4-8adb-96c93be01ef9","status": "complete","attributes": [{"name": "CustomerFacingServiceId","value": "N2222"}]},{"productId": "26eb46ab-e4e3-eb7b-4726-af867590d48f","status": "complete","attributes": [{"name": "CustomerFacingServiceId","value": "N3333"}]}]}:::Fulfilment'+':::'+notif.Id);
        parameters.add(ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|6789');
        parameters.add('"attributes": [{"name": "subStage","value": "Product Activation and Testing"},{"name": "ServiceActivationDate","value": "2018-08-10T16:48:39Z"}]');
        parameters.add('subStageNotification');
        parameters.add('"product": {"productId": "1fba066a-4e7d-bb28-7bfe-495fae2b2066","status": "In Progress","attributes": [{"name": "CustomerFacingServiceId","value": "N1111"}],"childProduct": [{"productId": "364b883e-2759-0bf4-8adb-96c93be01ef9","status": "complete","attributes": [{"name": "CustomerFacingServiceId","value": "N2222"}]},{"productId": "26eb46ab-e4e3-eb7b-4726-af867590d48y","status": "complete","attributes": [{"name": "CustomerFacingServiceId","value": "N3333"}]}]}');
        parameters.add(notif.id);
        
        Test.startTest();
        ManageSubStageNotification.processNotificationRecord(parameters);   
        
        List<Service_Specification__c> serSpecList = [Select Id, Service__c, Code__c, guid__c, (Select Name,Service_Specification__c from subStageNotifications__r where Name =:'Product Activation and Testing') from Service_Specification__c where service__c =: svc1.id];
        for(Service_Specification__c serSpec : serSpecList){
            guidSet.add(serSpec.guid__c);
        }
        ManageSubStageNotification.getChildServices(subId,guidSet);
        Test.stopTest();
        
        csord__Service__c svc2 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'testService_1' limit 1][0];
        
        String svcSpecsJSON = csedm.API_1.getServiceSpecificationsById(svc2.Id);
        List<CS_SpecificationDTO.ServiceSpecification> svcSpecList = CS_SpecificationDTO.parseServiceSpec(svcSpecsJSON, 'FULFILMENT');
        
        for(CS_SpecificationDTO.ServiceSpecification spec: svcSpecList){
            System.debug('spec.guid::'+spec.guid);
            System.debug('spec.status::'+spec.status);
            System.debug('spec.code::'+spec.code);
            if(spec.guid == '1fba066a-4e7d-bb28-7bfe-495fae2b2066'){
                for(CS_SpecificationDTO.SimpleAttributes attr: spec.additionalAttributes){
                    if(attr.name == 'CustomerFacingServiceId'){
                        System.assertEquals('CustomerFacingServiceId', attr.name); 
                        System.assertEquals('N1111', attr.value); 
                    }
                }
            }
        }
        
    }
    
    @isTest
    static void testProcessNotificationRecForCancel(){
        csord__Service__c ser = [SELECT Id, csord__Status__c,toBeCancelled__c,csordtelcoa__Product_Configuration__r.Type__C, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'testService_3' limit 1][0];
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
        List<String> parameters = new List<String>();
        Notification__c notif = new Notification__c();
        notif.externalOrderId__c = ord.csord__Order_Number__c;
        notif.eventTimeStamp__c = '2018-12-27T06:08+05:00';
        notif.orderItemId__c = ord.csord__Order_Number__c+'|'+ser.csordtelcoa__Service_Number__c+'|df7b0d41-a1e4-d108-a8fb-8d5548ded172';
        notif.notificationAttributes__c = '"attributes": [{"name": "subStage","value": "Logical Deactivation"},{"name": "ServiceDeactivationDate","value": "2018-08-10T16:48:39Z"},{\"name\": \"currentForecastedDeliveryDate\",\"value\": \"2018-08-18T05:30:30Z\"}]';
        notif.orderItemDetails__c = '"product": {"productId": "df7b0d41-a1e4-d108-a8fb-8d5548ded172","status": "In Progress","attributes": [{"name": "CustomerFacingServiceId","value": "N1111"}],"childProduct": [{"productId": "364b883e-2759-0bf4-8adb-96c93be01ef9","status": "complete","attributes": [{"name": "CustomerFacingServiceId","value": "N2222"}]},{"productId": "26eb46ab-e4e3-eb7b-4726-af867590d48f","status": "complete","attributes": [{"name": "CustomerFacingServiceId","value": "N3333"}]}]}';
        notif.eventType__c = 'subStageNotification';
        notif.sourceSystem__c = 'Fulfilment';
        notif.Status__c = 'Completed';
        notif.orderItemVersion__c = 1;
        insert notif;
        
        //parameters.add(ord.csord__Order_Number__c+'|'+ser.csordtelcoa__Service_Number__c+'|6789:::"attributes": [{"name": "subStage","value": "Logical Deactivation"},{"name": "ServiceDeactivationDate","value": "2018-08-10T16:48:39Z"}]:::subStageNotification:::"product": {"productId": "1fba066a-4e7d-bb28-7bfe-495fae2b2066","status": "In Progress","attributes": [{"name": "CustomerFacingServiceId","value": "N1111"}],"childProduct": [{"productId": "364b883e-2759-0bf4-8adb-96c93be01ef9","status": "complete","attributes": [{"name": "CustomerFacingServiceId","value": "N2222"}]},{"productId": "26eb46ab-e4e3-eb7b-4726-af867590d48f","status": "complete","attributes": [{"name": "CustomerFacingServiceId","value": "N3333"}]}]}:::Fulfilment'+':::'+notif.Id);
        parameters.add(ord.csord__Order_Number__c+'|'+ser.csordtelcoa__Service_Number__c+'|6789');
        parameters.add('"attributes": [{"name": "subStage","value": "Product Activation and Testing"},{"name": "ServiceActivationDate","value": "2018-08-10T16:48:39Z"}]');
        parameters.add('subStageNotification');
        parameters.add('"product": {"productId": "1fba066a-4e7d-bb28-7bfe-495fae2b2066","status": "In Progress","attributes": [{"name": "CustomerFacingServiceId","value": "N1111"}],"childProduct": [{"productId": "364b883e-2759-0bf4-8adb-96c93be01ef9","status": "complete","attributes": [{"name": "CustomerFacingServiceId","value": "N2222"}]},{"productId": "26eb46ab-e4e3-eb7b-4726-af867590d48y","status": "complete","attributes": [{"name": "CustomerFacingServiceId","value": "N3333"}]}]}');
        parameters.add(notif.id);
        Test.startTest();
        ManageSubStageNotification.processNotificationRecord(parameters);
        Test.stopTest();
        
        csord__Service__c svc2 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'testService_3' limit 1][0];
        
        String svcSpecsJSON = csedm.API_1.getServiceSpecificationsById(svc2.Id);
        List<CS_SpecificationDTO.ServiceSpecification> svcSpecList = CS_SpecificationDTO.parseServiceSpec(svcSpecsJSON, 'FULFILMENT');
        
        for(CS_SpecificationDTO.ServiceSpecification spec: svcSpecList){
            System.debug('spec.guid::'+spec.guid);
            System.debug('spec.status::'+spec.status);
            System.debug('spec.code::'+spec.code);
            if(spec.guid == 'df7b0d41-a1e4-d108-a8fb-8d5548ded172'){
                for(CS_SpecificationDTO.SimpleAttributes attr: spec.additionalAttributes){
                    if(attr.name == 'CustomerFacingServiceId'){
                        System.assertEquals('CustomerFacingServiceId', attr.name); 
                        System.assertEquals('CFS11', attr.value); 
                    }
                }
            }
        }
        
    }
    
   @isTest
    static void testCheckSubscriptionDeactivation(){
        csord__Service__c serv = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c,csord__Subscription__c,csord__Service__c.csord__Subscription__r.id, Name from csord__Service__c where Name = 'IP Site' limit 1][0];
    
    String subscriptionId = serv.csord__Subscription__c;
    
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
        List<String> parameters = new List<String>();
        Notification__c notif = new Notification__c();
        notif.externalOrderId__c = ord.csord__Order_Number__c;
        notif.eventTimeStamp__c = '2018-12-27T06:08+05:00';
        notif.orderItemId__c = ord.csord__Order_Number__c+'|'+serv.csordtelcoa__Service_Number__c+'|df7b0d41-a1e4-d108-a8fb-8d5548ded172';
        notif.notificationAttributes__c = '"attributes": [{"name": "subStage","value": "Logical Deactivation"},{"name": "ServiceDeactivationDate","value": "2018-08-10T16:48:39Z"},{\"name\": \"currentForecastedDeliveryDate\",\"value\": \"2018-08-18T05:30:30Z\"}]';
        notif.orderItemDetails__c = '"product": {"productId": "df7b0d41-a1e4-d108-a8fb-8d5548ded172","status": "In Progress","attributes": [{"name": "CustomerFacingServiceId","value": "N1111"}],"childProduct": [{"productId": "364b883e-2759-0bf4-8adb-96c93be01ef9","status": "complete","attributes": [{"name": "CustomerFacingServiceId","value": "N2222"}]},{"productId": "26eb46ab-e4e3-eb7b-4726-af867590d48f","status": "complete","attributes": [{"name": "CustomerFacingServiceId","value": "N3333"}]}]}';
        notif.eventType__c = 'subStageNotification';
        notif.sourceSystem__c = 'Fulfilment';
        notif.Status__c = 'Completed';
        notif.orderItemVersion__c = 1;
        insert notif;
        
        subStageNotification__c subStage = [Select id,name,Service_Specification__c,Substage_Completion_Date__c from subStageNotification__c where Name= 'Logical Deactivation' LIMIT 1];
        String subStageName = subStage.Name;
    
        Test.startTest();
        ManageSubStageNotification.checkSubscriptionDeactivation(serv.id,subscriptionId,subStageName);
        Test.stopTest();
        System.assertEquals('Logical Deactivation',subStage.Name);
    }
    
    @isTest
    static void testUpdateServices(){
        Set<String> serSet = new Set<String>();       
        csord__Subscription__c sub1 = [SELECT Id, Sub_status__c, Name from csord__Subscription__c where name ='testSubscription1' LIMIT 1];
        csord__Service__c ser = [SELECT Id, csord__Status__c,substage__c, csordtelcoa__Service_Number__c,csord__Subscription__r.Name, Name from csord__Service__c where csord__Subscription__r.Name= 'testSubscription1' AND name ='testService_3' LIMIT 1][0];
        serSet.add(ser.id);
        String substage = ser.substage__c;
        Test.startTest();
        ManageSubStageNotification.updateServices(serSet,substage);
        ManageSubStageNotification.updateSubscriptions(sub1.id,'subStage');
        
        Test.stopTest();
        System.assertEquals('Logical Deactivation',substage);
    }
    
    @isTest
    static void testUpdateServices1(){
        Set<String> serSet1 = new Set<String>();        
        csord__Subscription__c sub1 = [SELECT Id, Sub_status__c, Name from csord__Subscription__c where name ='testSubscription1' LIMIT 1];
        csord__Service__c ser1 = [SELECT Id, stage__c,csord__Status__c,substage__c, csordtelcoa__Service_Number__c,csord__Subscription__r.Name, Name from csord__Service__c where csord__Subscription__r.Name = 'testSubscription1' AND name ='testService_4'  LIMIT 1][0];
        
        
        serSet1.add(ser1.id);
        String substage = ser1.substage__c;
        Test.startTest();
        ManageSubStageNotification.updateServices(serSet1,substage);
        ManageSubStageNotification.updateSubscriptions(sub1.id,'subStage');
        
        Test.stopTest();
        System.assertEquals('Product Requirements Validation',substage);
    }
    
    
    @isTest
    static void testUpdateServices2(){
        Set<String> serSet2 = new Set<String>();      
        csord__Subscription__c sub1 = [SELECT Id, Sub_status__c, Name from csord__Subscription__c where name ='testSubscription1' LIMIT 1];
        csord__Service__c ser2 = [SELECT Id, csord__Status__c,substage__c, csordtelcoa__Service_Number__c, csord__Subscription__r.Name, Name from csord__Service__c where csord__Subscription__r.Name = 'testSubscription1' AND name ='testService_5' LIMIT 1][0];
        serSet2.add(ser2.id);
        String substage = ser2.substage__c;
        Test.startTest();
        ManageSubStageNotification.updateServices(serSet2,substage);
        ManageSubStageNotification.updateSubscriptions(sub1.id,'subStage');
        Test.stopTest();
        System.assertEquals('Customer Order Acceptance',substage);
    }
    
    @isTest
    static void testUpdateServices3(){
        Set<String> serSet3 = new Set<String>();     
        csord__Subscription__c sub1 = [SELECT Id, Sub_status__c, Name from csord__Subscription__c where name ='testSubscription1' LIMIT 1];
        csord__Service__c ser3 = [SELECT Id, csord__Status__c,substage__c, csordtelcoa__Service_Number__c, csord__Subscription__r.Name, Name from csord__Service__c where csord__Subscription__r.Name = 'testSubscription1' AND name ='testService_6' LIMIT 1][0];
        serSet3.add(ser3.id);
        String substage = ser3.substage__c;
        Test.startTest();
        ManageSubStageNotification.updateServices(serSet3,substage);            
        ManageSubStageNotification.updateSubscriptions(sub1.id,'subStage');
        Test.stopTest();
        System.assertNotEquals(null,substage);//EDGE-80847
    }
    
    @isTest
    static void testUpdateSubscriptions(){
        
        csord__Subscription__c sub1 = [SELECT Id, Sub_status__c, Name from csord__Subscription__c where name ='testSubscription1' LIMIT 1];
        String subId =sub1.id; 
        String notifictaionType = 'subStage';
        Test.startTest();
        ManageSubStageNotification.updateSubscriptions(subId,notifictaionType);
        Test.stopTest();
        System.assertEquals('subStage',notifictaionType);
    }
    
    @isTest
    static void testUpdateSubscriptions1(){
        
        csord__Subscription__c sub2 = [SELECT Id, Sub_status__c,Trigger_RTS__c, Name from csord__Subscription__c where name ='testSubscription2' LIMIT 1];
        String subId =sub2.id; 
        String notifictaionType = 'subStage';
        Test.startTest();
        ManageSubStageNotification.updateSubscriptions(subId,notifictaionType);
        Test.stopTest();
        System.assertEquals('subStage',notifictaionType);
        System.assertEquals(true,sub2.Trigger_RTS__c);
        
    }
    
    
    @isTest
    static void testUpdateOrder(){
        
        csord__Order__c Ordr = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' LIMIT 1];
        String priOrd =Ordr.csord__Primary_Order__c; 
        
        Test.startTest();
        ManageSubStageNotification.updateOrder(priOrd);
        Test.stopTest();
        System.assertNotEquals('a4b2O0000004HikQAE',priOrd);
        
    }
    
    @isTest
    static void testUpdateOrder1(){
        
        csord__Order__c Ordr = [SELECT id, csord__Order_Number__c,stage__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder1' LIMIT 1];
        String priOrd =Ordr.csord__Primary_Order__c; 
        
        Test.startTest();
        ManageSubStageNotification.updateOrder(priOrd);
        Test.stopTest();
        System.assertEquals('Ready for Use',Ordr.stage__c);
        
    }
    
    @isTest
    static void testUpdateOrder2(){
        
        csord__Order__c Ordr = [SELECT id, csord__Order_Number__c,stage__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder2' LIMIT 1];
        String priOrd =Ordr.csord__Primary_Order__c; 
        
        Test.startTest();
        ManageSubStageNotification.updateOrder(priOrd);
        Test.stopTest();
        System.assertEquals('Closed',Ordr.stage__c);
        
    }
    ////EDGE-80847
    @isTest
    static void testUpdateOrderSubStage(){
        
        csord__Order__c Ordr = [SELECT id,stage__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder1' LIMIT 1];
        String ordId =Ordr.id; 
        
        Test.startTest();
        ManageSubStageNotification.updateOrderSubStage(ordId);
        Test.stopTest();
        System.assertEquals('Ready for Use',Ordr.stage__c);
        
    }
    
    @isTest
    static void testProcessNotificationRec2(){
        
        csord__Subscription__c sub1 = [SELECT Id, Sub_status__c, Name from csord__Subscription__c where name ='testSubscription1' LIMIT 1];
        String subId = sub1.id;
        
        Set<String> guidSet = new Set<String>();
        csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c,csord__Subscription__r.Name, Name from csord__Service__c where Name = 'testService_1' limit 1][0];
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
        List<String> parameters = new List<String>();
        Notification__c notif = new Notification__c();
        notif.externalOrderId__c = ord.csord__Order_Number__c;
        notif.eventTimeStamp__c = '2018-08-15T06:08+05:00';
        notif.orderItemId__c = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|1fba066a-4e7d-bb28-7bfe-495fae2b2066';
        notif.notificationAttributes__c = '"attributes": [{"name": "Logistic Order Number","value": "Product Activation and Testing"},{"name": "Equipment Ordered","value": "Product Activation and Testing"},{"name": "subStage","value": "Equipment Ordered"},{"name": "ServiceActivationDate","value": "2018-08-10T16:48:39Z"}]';
        notif.orderItemDetails__c = '"product": {"productId": "1fba066a-4e7d-bb28-7bfe-495fae2b2066","status": "In Progress","attributes": [{"name": "CustomerFacingServiceId","value": "N1111"},{"name": "DeviceID","value": "N3333"},{"name": "DeviceIDType","value": "N3333"}],"childProduct": [{"productId": "364b883e-2759-0bf4-8adb-96c93be01ef9","status": "complete","attributes": [{"name": "CustomerFacingServiceId","value": "N2222"},{"name": "DeviceID","value": "N3333"},{"name": "DeviceIDType","value": "N3333"}]},{"productId": "26eb46ab-e4e3-eb7b-4726-af867590d48f","status": "complete","attributes": [{"name": "CustomerFacingServiceId","value": "N3333"},{"name": "DeviceID","value": "N3333"},{"name": "DeviceIDType","value": "N3333"}]}]}';
        notif.eventType__c = 'subStageNotification';
        notif.sourceSystem__c = 'Fulfilment';
        notif.Status__c = 'Pending';
        notif.orderItemVersion__c = 1;
        insert notif;
        
        //parameters.add(ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|6789:::"attributes": [{"name": "subStage","value": "Product Activation and Testing"},{"name": "ServiceActivationDate","value": "2018-08-10T16:48:39Z"}]:::subStageNotification:::"product": {"productId": "1fba066a-4e7d-bb28-7bfe-495fae2b2066","status": "In Progress","attributes": [{"name": "CustomerFacingServiceId","value": "N1111"}],"childProduct": [{"productId": "364b883e-2759-0bf4-8adb-96c93be01ef9","status": "complete","attributes": [{"name": "CustomerFacingServiceId","value": "N2222"}]},{"productId": "26eb46ab-e4e3-eb7b-4726-af867590d48f","status": "complete","attributes": [{"name": "CustomerFacingServiceId","value": "N3333"}]}]}:::Fulfilment'+':::'+notif.Id);
        parameters.add(ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|6789');
        parameters.add('"attributes": [{"name": "LogisticOrderNumber","value": "Product Activation and Testing"},{"name": "Equipment Ordered","value": "Product Activation and Testing"},{"name": "subStage","value": "Equipment Ordered"},{"name": "ServiceActivationDate","value": "2018-08-10T16:48:39Z"}]');
        parameters.add('subStageNotification');
        parameters.add('"product": {"productId": "1fba066a-4e7d-bb28-7bfe-495fae2b2066","status": "In Progress","attributes": [{"name": "CustomerFacingServiceId","value": "N1111"},{"name": "DeviceID","value": "N3333"},{"name": "DeviceIDType","value": "N3333"}],"childProduct": [{"productId": "364b883e-2759-0bf4-8adb-96c93be01ef9","status": "complete","attributes": [{"name": "CustomerFacingServiceId","value": "N2222"}]},{"productId": "26eb46ab-e4e3-eb7b-4726-af867590d48y","status": "complete","attributes": [{"name": "CustomerFacingServiceId","value": "N3333"},{"name": "DeviceID","value": "N3333"},{"name": "DeviceIDType","value": "N3333"}]}]}');
        parameters.add(notif.id);
        
        Test.startTest();
        ManageSubStageNotification.processNotificationRecord(parameters);   
        
        List<Service_Specification__c> serSpecList = [Select Id, Service__c, Code__c, guid__c, (Select Name,Service_Specification__c from subStageNotifications__r where Name =:'Product Activation and Testing') from Service_Specification__c where service__c =: svc1.id];
        for(Service_Specification__c serSpec : serSpecList){
            guidSet.add(serSpec.guid__c);
        }
        ManageSubStageNotification.getChildServices(subId,guidSet);
        Test.stopTest();
        
        csord__Service__c svc2 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'testService_1' limit 1][0];
        
        String svcSpecsJSON = csedm.API_1.getServiceSpecificationsById(svc2.Id);
        List<CS_SpecificationDTO.ServiceSpecification> svcSpecList = CS_SpecificationDTO.parseServiceSpec(svcSpecsJSON, 'FULFILMENT');
        
        for(CS_SpecificationDTO.ServiceSpecification spec: svcSpecList){
            System.debug('spec.guid::'+spec.guid);
            System.debug('spec.status::'+spec.status);
            System.debug('spec.code::'+spec.code);
            if(spec.guid == '1fba066a-4e7d-bb28-7bfe-495fae2b2066'){
                for(CS_SpecificationDTO.SimpleAttributes attr: spec.additionalAttributes){
                    if(attr.name == 'CustomerFacingServiceId'){
                        System.assertEquals('CustomerFacingServiceId', attr.name); 
                        System.assertEquals('N1111', attr.value); 
                    }
                }
            }
        }
        
    }
    
}