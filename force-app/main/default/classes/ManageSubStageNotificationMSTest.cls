/******************************************************** 
Class Name : ManageSubStageNotificationMSTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1             Prajakta                15/02/2020
2             Vaibhav                 06-07-2020      EDGE-158047 : populate DeviceID/DeviceIDType for child products on Asset object 
3             Vaibhav/Pawan           24-07-2020       EDGE-160369  : Network ServiceID fix 
4             vaibhav                 27-07-2020       EDGE-164886 
5.            Prajakta                6/11/2020        EDGE-188475
6.            Gnana                   02/12/2020       EDGE-187675 Added Test Method for ReadyForActivation SubStage Notification
7.            Vaibhav                 02/12/2020       EDGE-170550
8.            Pawan Singh             22/04/2021       EDGE-215225 Added custom setting instance
9.            Anuj                    04/05/2021       EDGE-204029
10.           Pawan S./Vaibhav        18/05/2021       B2B-328 - Solution Supress
24.             Pawan           08-June-2021    EDGE-189974 - Enhanced Cancel logic to handle multiple deactivation notification
25.             Suyash          23-07-2021      DIGI-5141 - Tenancy ID is not populating for SDWAN Tenancy service on SFDC UI
**********************************************************/
@isTest
public class ManageSubStageNotificationMSTest {
    @Testsetup
    static void dataSetup(){
        EnvironmentVariable__c csSite = new EnvironmentVariable__c();
        csSite.Name='EnableHV';
        csSite.value__c='True';
        insert csSite;
        
        //EDGE-215225
        EnvironmentVariable__c tokenCustomSetting = new EnvironmentVariable__c();         
      tokenCustomSetting.Name = 'EnableThrowException';        
       tokenCustomSetting.Value__c = 'true';        
      insert tokenCustomSetting;
        
       /* Environment_Configurations__c envtConfig = Environment_Configurations__c.getOrgDefaults();
        envtConfig.EnableSolutionSupress__c = false;
        insert envtConfig;*/
        
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
        
        
        List<cscfga__Product_Configuration__c> pcList = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c testConfig1 = new cscfga__Product_Configuration__c();
        testConfig1.Name = System.Label.IP_Network;
        testConfig1.cscfga__Product_Basket__c = testBasket.Id;
        testConfig1.Type__c = 'Cancel'; 
        pcList.add(testConfig1);
    
    cscfga__Product_Configuration__c pcRFA = new cscfga__Product_Configuration__c();
        pcRFA.Name = 'AM';
        pcRFA.cscfga__Product_Basket__c = testBasket.Id;
        pcRFA.Type__c = 'New'; 
    pcRFA.ConfigurationType1__c = 'SolutionComponent';
        pcList.add(pcRFA);
    
    cscfga__Product_Configuration__c pcRFA1 = new cscfga__Product_Configuration__c();
        pcRFA1.Name = 'AM Plan';
        pcRFA1.cscfga__Product_Basket__c = testBasket.Id;
        pcRFA1.Type__c = 'New';
        pcList.add(pcRFA1);
    insert pcList;
        
    List<csord__Order_Request__c> ordreqList = new List<csord__Order_Request__c>();
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        ordreqList.add(ordReq);
        
        csord__Order_Request__c ordReq1 = ProductTestFactory.buildOrderRequest();
        ordreqList.add(ordReq1);
        
        csord__Order_Request__c ordReq2 = ProductTestFactory.buildOrderRequest();
        ordreqList.add(ordReq2);
        
        csord__Order_Request__c ordReq3 = ProductTestFactory.buildOrderRequest();
        ordreqList.add(ordReq3);
    
    csord__Order_Request__c ordReq4 = ProductTestFactory.buildOrderRequest();
        ordreqList.add(ordReq4);
    insert ordreqList;
        
    List<csord__Order__c> ordList = new List<csord__Order__c>();
        csord__Order__c priOrd = ProductTestFactory.buildOrder('PrimaryOrder', acc.id, 'Created', ordReq1.id);
        priOrd.csordtelcoa__Opportunity__c = testOpp.Id;
        priOrd.csord__Order_Request__c = ordReq1.Id;        
        insert priOrd;
        
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csordtelcoa__Opportunity__c = testOpp.Id;
        ord.csord__Order_Request__c = ordReq.Id;
        ord.csord__Primary_Order__c = priOrd.Id;
        ordList.add(ord); 
        
        csord__Order__c ord1 = ProductTestFactory.buildOrder('TestOrder1', acc.id, 'Created', ordReq2.id);
        ord1.csordtelcoa__Opportunity__c = testOpp.Id;
        ord1.csord__Order_Request__c = ordReq2.Id;
        ord1.csord__Primary_Order__c = priOrd.Id;
        ord1.stage__c = System.Label.OrderReadyForUse;
        ordList.add(ord1);
        
        csord__Order__c ord2 = ProductTestFactory.buildOrder('TestOrder2', acc.id, 'Created', ordReq3.id);
        ord2.csordtelcoa__Opportunity__c = testOpp.Id;
        ord2.csord__Order_Request__c = ordReq3.Id;
        ord2.csord__Primary_Order__c = priOrd.Id;
        ord2.stage__c = System.Label.OrderClosed;
        ordList.add(ord2); 
    
    csord__Order__c ord3 = ProductTestFactory.buildOrder('TestOrder3', acc.id, 'Created', ordReq4.id);
        ord3.csordtelcoa__Opportunity__c = testOpp.Id;
        ord3.csord__Order_Request__c = ordReq4.Id;
        ord3.stage__c = System.Label.OrderReadyForUse;
        ordList.add(ord3); 
        
    insert ordList;
    
        csord__Solution__c sol= PricingTestDataFactory.generateSolution('CMP');
    csord__Solution__c sol1= PricingTestDataFactory.generateSolution('AM');
        insert new List<csord__Solution__c>{sol,sol1};
            
        List<csord__Subscription__c> subList=new List<csord__Subscription__c>();
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'testSubscription';
        subs.csord__Identification__c = 'testIdentity';
        subs.csord__Order__c = ord.Id;
        subs.Sub_status__c = 'Active';
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subs.csord__Account__c=acc.id;
        subList.add(subs);
        
        csord__Subscription__c subs1=new csord__Subscription__c();
        subs1.name  = 'testSubscription1';
        subs1.csord__Identification__c = 'testIdentity1';
        subs1.csord__Order__c = ord.Id;
        subs1.Sub_status__c = 'Active';
        subs1.eventId__c = '9f0bfd2-2bfd-9816-552d-9e28c804294r';
        subs1.csordtelcoa__Product_Configuration__c = testConfig1.Id;
        subs1.csord__Account__c=acc.id;
        subList.add(subs1);
        
        csord__Subscription__c subs2=new csord__Subscription__c();
        subs2.name  = 'testSubscription2';
        subs2.csord__Identification__c = 'testIdentity2';
        subs2.csord__Order__c = ord1.Id;
        subs2.Sub_status__c = 'Active';
        subs2.Trigger_RTS__c = true;
        subs2.eventId__c = '9e0bfd2-2bfd-9816-552d-9e28c804294r';
        subs2.csord__Account__c=acc.id;
        //subs2.csordtelcoa__Product_Configuration__c = testConfig1.Id;
        subList.add(subs2);
        
        csord__Subscription__c subs3=new csord__Subscription__c();
        subs3.name  = 'Connected Workplace';
        subs3.csord__Identification__c = 'Subscription_a3T2O000000BQ8WUAW_0';
        subs3.csord__Order__c = ord1.Id;
        subs3.Sub_status__c = 'Active';
        subs3.eventId__c = '9e1bfd2-2bfd-9816-552d-9e28c804294r';
        subs3.csord__Account__c=acc.id;
        //subs2.csordtelcoa__Product_Configuration__c = testConfig1.Id;
    subList.add(subs3);
    
    csord__Subscription__c subV=new csord__Subscription__c();
        subV.name  = 'TestDeviceID';
        subV.csord__Identification__c = 'TestDeviceID';
        subV.csord__Order__c = ord.Id;
         subV.csord__Account__c=acc.id;
        subList.add(subV);
  
      csord__Subscription__c subDevice=new csord__Subscription__c();
        subDevice.name  = 'TestsubDevice';
        subDevice.csord__Identification__c = 'TestsubDevice';
        subDevice.csord__Order__c = ord.Id;
         subDevice.csord__Account__c=acc.id;
        subList.add(subDevice);
    
    csord__Subscription__c subDevice2=new csord__Subscription__c();
        subDevice2.name  = 'TestsubDevice2';
        subDevice2.csord__Identification__c = 'TestsubDevice';
        subDevice2.csord__Order__c = ord.Id;
          subDevice2.csord__Account__c=acc.id;
        subList.add(subDevice2);
    
  csord__Subscription__c subDevice3=new csord__Subscription__c();
        subDevice3.name  = 'subDevice3';
        subDevice3.csord__Identification__c = 'subDevice3';
        subDevice3.csord__Order__c = ord.Id;
        subDevice3.csord__Account__c=acc.id;
        subDevice3.cssdm__solution_association__c = sol.Id;
        subList.add(subDevice3);
        
    csord__Subscription__c subRFA=new csord__Subscription__c();
        subRFA.name  = 'subRFA';
        subRFA.csord__Identification__c = 'subRFA';
        subRFA.csord__Order__c = ord3.Id;
        subRFA.csord__Account__c=acc.id;
        subRFA.cssdm__solution_association__c = sol1.Id;
    subRFA.csord__status__c = 'Provisioned';
    subRFA.Trigger_RFA__c = true;
    subRFA.csordtelcoa__Product_Configuration__c =pcRFA.id;
        subList.add(subRFA);
    
    csord__Subscription__c subRFA1=new csord__Subscription__c();
        subRFA1.name  = 'subRFA1';
        subRFA1.csord__Identification__c = 'subRFA1';
        subRFA1.csord__Order__c = ord3.Id;
        subRFA1.csord__Account__c=acc.id;
        subRFA1.cssdm__solution_association__c = sol1.Id;
    subRFA1.csord__status__c = 'Provisioning In Progress';
    subRFA1.csordtelcoa__Product_Configuration__c =pcRFA1.id;
        subRFA1.Trigger_RFA__c = true;
        subList.add(subRFA1);
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
        serv1.substage__c = 'Product Requirements Validation';
        serv1.stage__c = 'Received';
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
    
    csord__Service__c servV = new csord__Service__c();
        servV.name ='Mobility';
        servV.csord__Identification__c  = 'Mobility';
        servV.csordtelcoa__Service_Number__c = 'SVC-000023459';
        servV.csord__Subscription__c = subV.Id;
        servV.csord__Status__c = 'In Progress'; 
        servV.csord__Order__c = ord.Id;
        //servs.add(servV);
        insert servV;
    
    csord__Service__c servD = new csord__Service__c();
        servD.name ='Device';
        servD.csord__Identification__c  = 'Device';
        servD.csordtelcoa__Service_Number__c = 'SVC-000023460';
        servD.csord__Subscription__c = subV.Id;
        servD.csord__Status__c = 'In Progress'; 
        servD.csord__Order__c = ord.Id;
        servD.csord__Service__c =servV.Id;
        servs.add(servD);
  
  csord__Service__c srvcD = new csord__Service__c();
        srvcD.name ='mobDevice';
        srvcD.csord__Identification__c  = 'mobDevice';
        srvcD.csordtelcoa__Service_Number__c = 'SVC-000084319';
        srvcD.csord__Subscription__c = subDevice.Id;
        srvcD.csord__Status__c = 'In Progress'; 
        srvcD.csord__Order__c = ord.Id;
        servs.add(srvcD);
    
  csord__Service__c srvcD2 = new csord__Service__c();
        srvcD2.name ='mobDevice2';
        srvcD2.csord__Identification__c  = 'mobDevice2';
        srvcD2.csordtelcoa__Service_Number__c = 'SVC-000084320';
        srvcD2.csord__Subscription__c = subDevice2.Id;
        srvcD2.csord__Status__c = 'In Progress'; 
        srvcD2.csord__Order__c = ord.Id;
        servs.add(srvcD2);
    
   csord__Service__c servDev = new csord__Service__c();
        servDev.name ='servDev';
        servDev.csord__Identification__c  = 'servDev';
        servDev.csordtelcoa__Service_Number__c = 'SVC-000023481';
        servDev.csord__Subscription__c = subDevice3.Id;
        servDev.csord__Status__c = 'In Progress'; 
        servDev.csord__Order__c = ord.Id;
        insert servDev;
    
    csord__Service__c servDev1 = new csord__Service__c();
        servDev1.name ='servDev1';
        servDev1.csord__Identification__c  = 'servDev1';
        servDev1.csordtelcoa__Service_Number__c = 'SVC-000023482';
        servDev1.csord__Subscription__c = subDevice3.Id;
        servDev1.csord__Status__c = 'In Progress'; 
        servDev1.csord__Order__c = ord.Id;
        servDev1.csord__Service__c =servDev.Id;
        servs.add(servDev1);
    
     csord__Service__c servRFA = new csord__Service__c();
        servRFA.name ='servRFA';
        servRFA.csord__Identification__c  = 'servRFA';
        servRFA.csordtelcoa__Service_Number__c = 'SVC-000023474';
        servRFA.csord__Subscription__c = subRFA.Id;
        servRFA.csord__Status__c = 'In Progress'; 
        servRFA.csord__Order__c = ord3.Id;
        servs.add(servRFA);
    
    csord__Service__c servRFA1 = new csord__Service__c();
        servRFA1.name ='servRFA1';
        servRFA1.csord__Identification__c  = 'servRFA1';
        servRFA1.csordtelcoa__Service_Number__c = 'SVC-0000234415';
        servRFA1.csord__Subscription__c = subRFA1.Id;
        servRFA1.csord__Status__c = 'In Progress'; 
        servRFA1.csord__Order__c = ord3.Id;
        servs.add(servRFA1);
        insert servs;
    
    List<Asset> asetList=new List<Asset>();
    Asset aset=new Asset();
    aset.Name='Mobile Device';
    aset.csord__Service__c = servD.id;
    aset.Subscription__c = subV.id;
        aset.AccountId=acc.id;
        asetList.add(aset);
    
    Asset aset1=new Asset();
    aset1.Name='IAD Device';
    aset1.csord__Service__c = srvcD.id;
    aset1.Subscription__c = subDevice.id;
        aset1.AccountId=acc.id;
        asetList.add(aset1);
    
      Asset aset2=new Asset();
    aset2.Name='IAD Device2';
    aset2.csord__Service__c = srvcD2.id;
    aset2.Subscription__c = subDevice2.id;
        aset2.AccountId=acc.id;
        asetList.add(aset2);
    
        Asset aset3=new Asset();
    aset3.Name='IAD Device3';
    aset3.csord__Service__c = servDev1.id;
    aset3.Subscription__c = subDevice3.id;
  aset3.AssetID__c = '4045322878914276';
  aset3.AssetIDType__c = 'MAC'; 
        aset3.AccountId=acc.id;
        asetList.add(aset3);
  
    insert asetList;
        
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
        att1.Body = Blob.valueOf('{ "specifications" :[{ "version" : "1", "status" : "Created", "startDate" : "", "specification" : "DMCAT_ProductOffering_000302DMCAT_ProductSpecification_000163", "productConfigurationId" : "a3T2O000000AyAnUAK", "name" : "Internet Protection Solution_Fulfilment", "instanceId" : "", "includeBilling" : false, "guid" : "df7b0d41-a1e4-d108-a8fb-8d5548ded172", "endDate" : "", "description" : "", "code" : "DMCAT_ProductSpecification_000163_Fulfilment", "attributes" : { "TotalNumberofUsers" : "", "CustomerFacingServiceId" : "", "InternetProtectionSolutionType" : "web and mail", "__targetSystem" : "FULFILMENT", "EnterpriseInternetProductInstanceID" : "" }, "additionalAttributes" : { "ServiceDeactivationDate" : "2018-08-18T05:30:30Z", "currentForecastedDeliveryDate" : "2018-08-18T05:30:30Z", "CustomerFacingServiceId" : "CFS11" } }, { "version" : "1", "status" : "Created", "startDate" : "", "specification" : "DMCAT_ProductOffering_000302DMCAT_ProductSpecification_000028", "productConfigurationId" : "a3T2O000000AyAnUAK", "name" : "IP VPN_Fulfilment", "instanceId" : "", "includeBilling" : false, "guid" : "32a9f7b0-d67e-d567-f6f8-d698ff62f621", "endDate" : "", "description" : "", "code" : "DMCAT_ProductSpecification_000028_Fulfilment", "attributes" : { "CustomerPreferredName" : "", "CustomerFacingServiceId" : "", "MulticastEnabled" : "FALSE", "__targetSystem" : "FULFILMENT" }, "additionalAttributes" : { } }, { "version" : "1", "status" : "Created", "startDate" : "", "specification" : "DMCAT_ProductSpecification_000028DMCAT_ProductSpecification_000018", "productConfigurationId" : "a3T2O000000AyAnUAK", "name" : "IP Wireless_Fulfilment", "instanceId" : "", "includeBilling" : false, "guid" : "fefaa9dd-7fa2-933e-4589-a8374adfe28d", "endDate" : "", "description" : "", "code" : "DMCAT_ProductSpecification_000018_Fulfilment", "attributes" : { "RequiredPoolTypes" : "Static", "CustomerFacingServiceId" : "", "APNtype" : "Shared", "GlobalRoaming" : "FALSE", "__targetSystem" : "FULFILMENT", "ManagedRadiusProductInstanceID" : "DMCAT_ProductSpecification_000053_Fulfilment", "parentSpec" : "DMCAT_ProductSpecification_000028_Fulfilment" }, "additionalAttributes" : { } }, { "version" : "1", "status" : "Created", "startDate" : "", "specification" : "DMCAT_ProductOffering_000302DMCAT_ProductSpecification_000338", "productConfigurationId" : "a3T2O000000AyAnUAK", "name" : "Firewall_Fulfilment", "instanceId" : "", "includeBilling" : false, "guid" : "675d778e-611c-ceda-e5ad-28a3e5aa4955", "endDate" : "", "description" : "", "code" : "DMCAT_ProductSpecification_000338_Fulfilment", "attributes" : { "NetworkServiceRef" : "", "CustomerFacingServiceId" : "", "LicenseSize" : "VM-50", "Bandwidth" : "100 Mbps", "Latency" : "Best Effort", "__targetSystem" : "FULFILMENT", "IPVPNProductInstanceID" : "DMCAT_ProductSpecification_000028_Fulfilment" }, "additionalAttributes" : { } }, { "version" : "1", "status" : "Created", "startDate" : "", "specification" : "DMCAT_ProductSpecification_000028DMCAT_ProductSpecification_000053", "productConfigurationId" : "a3T2O000000AyAnUAK", "name" : "Managed Radius_Fulfilment", "instanceId" : "", "includeBilling" : false, "guid" : "a4660660-47c8-0b49-757e-9601bad98951", "endDate" : "", "description" : "", "code" : "DMCAT_ProductSpecification_000053_Fulfilment", "attributes" : { "RADIUSServerType" : "Basic Telstra Managed RADIUS", "AuthenticationType" : "Username/Password Authentication", "RadiusUsers" : "TRUE", "__targetSystem" : "FULFILMENT", "parentSpec" : "DMCAT_ProductSpecification_000028_Fulfilment" }, "additionalAttributes" : { } } ], "serviceId":"'+serv.Id+'","legacyAttributes":[]}');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        atts.add(att1);
        
       /* Attachment att2 = new Attachment();
        att2.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","productConfigurationId":"a3T2O0000008D0IUAU","name":"Unified Communication Enterprise_Fulfilment","instanceId":"","guid":"cf0159c5-997f-f39b-5233-dbedc2cecdbf","endDate":"","description":"","code":"DMCAT_ProductSpecification_000087_Fulfilment","attributes":{"DomainName":"","OverviewofProposedSolution":"","CustomerPreferredName":"","CustomerFacingServiceId":"","ModuleGroupType":"","EnterpriseExtensionDialling":"TRUE","__targetSystem":"FULFILMENT"},"additionalAttributes":{}}],"serviceId":"'+serv1.Id+'","legacyAttributes":[]}');
        att2.Name = 'ServiceSpecifications.json';
        att2.ParentId = serv1.Id;
        atts.add(att2);*/
        
        Attachment att3 = new Attachment();
        att3.Body = Blob.valueOf('{ "specifications" :[{ "version" : "1", "status" : "Created", "startDate" : "", "specification" : "DMCAT_ProductOffering_000302DMCAT_ProductSpecification_000163", "productConfigurationId" : "a3T2O000000AyAnUAK", "name" : "Internet Protection Solution_Fulfilment", "instanceId" : "", "includeBilling" : false, "guid" : "df7b0d41-a1e4-d108-a8fb-8d5548ded172", "endDate" : "", "description" : "", "code" : "DMCAT_ProductSpecification_000163_Fulfilment", "attributes" : { "TotalNumberofUsers" : "", "CustomerFacingServiceId" : "", "InternetProtectionSolutionType" : "web and mail", "__targetSystem" : "FULFILMENT", "EnterpriseInternetProductInstanceID" : "" }, "additionalAttributes" : { "ServiceDeactivationDate" : "2018-08-18T05:30:30Z", "currentForecastedDeliveryDate" : "2018-08-18T05:30:30Z", "CustomerFacingServiceId" : "CFS11" } }, { "version" : "1", "status" : "Created", "startDate" : "", "specification" : "DMCAT_ProductOffering_000302DMCAT_ProductSpecification_000028", "productConfigurationId" : "a3T2O000000AyAnUAK", "name" : "IP VPN_Fulfilment", "instanceId" : "", "includeBilling" : false, "guid" : "32a9f7b0-d67e-d567-f6f8-d698ff62f621", "endDate" : "", "description" : "", "code" : "DMCAT_ProductSpecification_000028_Fulfilment", "attributes" : { "CustomerPreferredName" : "", "CustomerFacingServiceId" : "", "MulticastEnabled" : "FALSE", "__targetSystem" : "FULFILMENT" }, "additionalAttributes" : { } }, { "version" : "1", "status" : "Created", "startDate" : "", "specification" : "DMCAT_ProductSpecification_000028DMCAT_ProductSpecification_000018", "productConfigurationId" : "a3T2O000000AyAnUAK", "name" : "IP Wireless_Fulfilment", "instanceId" : "", "includeBilling" : false, "guid" : "fefaa9dd-7fa2-933e-4589-a8374adfe28d", "endDate" : "", "description" : "", "code" : "DMCAT_ProductSpecification_000018_Fulfilment", "attributes" : { "RequiredPoolTypes" : "Static", "CustomerFacingServiceId" : "", "APNtype" : "Shared", "GlobalRoaming" : "FALSE", "__targetSystem" : "FULFILMENT", "ManagedRadiusProductInstanceID" : "DMCAT_ProductSpecification_000053_Fulfilment", "parentSpec" : "DMCAT_ProductSpecification_000028_Fulfilment" }, "additionalAttributes" : { } }, { "version" : "1", "status" : "Created", "startDate" : "", "specification" : "DMCAT_ProductOffering_000302DMCAT_ProductSpecification_000338", "productConfigurationId" : "a3T2O000000AyAnUAK", "name" : "Firewall_Fulfilment", "instanceId" : "", "includeBilling" : false, "guid" : "675d778e-611c-ceda-e5ad-28a3e5aa4955", "endDate" : "", "description" : "", "code" : "DMCAT_ProductSpecification_000338_Fulfilment", "attributes" : { "NetworkServiceRef" : "", "CustomerFacingServiceId" : "", "LicenseSize" : "VM-50", "Bandwidth" : "100 Mbps", "Latency" : "Best Effort", "__targetSystem" : "FULFILMENT", "IPVPNProductInstanceID" : "DMCAT_ProductSpecification_000028_Fulfilment" }, "additionalAttributes" : { } }, { "version" : "1", "status" : "Created", "startDate" : "", "specification" : "DMCAT_ProductSpecification_000028DMCAT_ProductSpecification_000053", "productConfigurationId" : "a3T2O000000AyAnUAK", "name" : "Managed Radius_Fulfilment", "instanceId" : "", "includeBilling" : false, "guid" : "a4660660-47c8-0b49-757e-9601bad98951", "endDate" : "", "description" : "", "code" : "DMCAT_ProductSpecification_000053_Fulfilment", "attributes" : { "RADIUSServerType" : "Basic Telstra Managed RADIUS", "AuthenticationType" : "Username/Password Authentication", "RadiusUsers" : "TRUE", "__targetSystem" : "FULFILMENT", "parentSpec" : "DMCAT_ProductSpecification_000028_Fulfilment" }, "additionalAttributes" : { } } ], "serviceId":"'+serv2.Id+'","legacyAttributes":[]}');
        att3.Name = 'ServiceSpecifications.json';
        att3.ParentId = serv2.Id;
        atts.add(att3);
        
        
        Attachment att4 = new Attachment();
        att4.Body = Blob.valueOf('{ "legacyAttributes" : [ ], "serviceId" : "a4e2O0000004sO6QAI", "specifications" : [ { "additionalAttributes" : { "SERVICEID" : "61474821599", "IPWirelessProductInstanceID" : "9051ae65-fe01-f77c-ab34-bf926c97288a" }, "attributes" : { "IPWirelessProductInstanceID" : "DMCAT_ProductSpecification_000018_Fulfilment", "__targetSystem" : "FULFILMENT", "SERVICEPROFILE" : "DATA_BACKUP", "ShippingRequired" : "TRUE", "Plan" : "Backup", "IMSI" : "", "AccessRole" : "Primary", "BillofMaterialID" : "160f44ab-6be5-433f-ab5e-750f44b8b19b", "SERVICEID" : "", "DMCAT_ProductSpecification_000263_CPEDeliveryDate" : "" }, "code" : "DMCAT_ProductSpecification_000263_Fulfilment", "description" : "", "endDate" : "", "guid" : "413d96f7-d8b1-84fe-9681-17f4b3b0518a", "includeBilling" : false, "instanceId" : "", "name" : "Mobile Access_Fulfilment", "productConfigurationId" : "a3T2O000000B2LpUAK", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263", "startDate" : "", "status" : "In Progress", "version" : "1" }, { "additionalAttributes" : { }, "attributes" : { "__targetSystem" : "ASSURANCE", "ServiceManagementOption " : "1" }, "code" : "DMCAT_ProductSpecification_000326_Assurance", "description" : "", "endDate" : "", "guid" : "5b5b91d6-8afe-304b-bec8-e64b94408777", "includeBilling" : false, "instanceId" : "", "name" : "Telstra Managed Service Option 1_Assurance", "productConfigurationId" : "a3T2O000000B2LpUAK", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000326", "startDate" : "", "status" : "Created", "version" : "1" }, { "additionalAttributes" : { "BSServiceTypeProductInstanceID" : "2de07d13-9ad0-b127-9381-06bff58e4caa" }, "attributes" : { "BSServiceTypeProductInstanceID" : "DMCAT_ProductSpecification_000312_Fulfilment", "__targetSystem" : "FULFILMENT", "CustomerFacingServiceId" : "", "CustomerPreferredName" : "", "DMCAT_ProductSpecification_000322_CPEDeliveryDate" : "" }, "code" : "DMCAT_ProductSpecification_000322_Fulfilment", "description" : "", "endDate" : "", "guid" : "0fe39634-5caf-9786-5804-95623e065e39", "includeBilling" : false, "instanceId" : "", "name" : "UC Site_Fulfilment", "productConfigurationId" : "a3T2O000000B2LpUAK", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000322", "startDate" : "", "status" : "In Progress", "version" : "1" }, { "additionalAttributes" : { "InternetProtectionSolutionProductInstanceID" : "74701806-0b7f-afa1-d088-7cf4012ed6dc" }, "attributes" : { "__targetSystem" : "FULFILMENT", "UserProtectionType" : "Web and Mail", "InternetProtectionSolutionProductInstanceID" : "DMCAT_ProductSpecification_000163_Fulfilment", "Quantity" : "4" }, "code" : "DMCAT_ProductSpecification_000162_Fulfilment", "description" : "", "endDate" : "", "guid" : "a657ffa6-5872-e96e-1c2d-93f53f2b4708", "includeBilling" : false, "instanceId" : "", "name" : "Web and Mail Internet Protection User_Fulfilment", "productConfigurationId" : "a3T2O000000B2LpUAK", "specification" : "DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000162", "startDate" : "", "status" : "In Progress", "version" : "1" }, { "additionalAttributes" : { "parentSpec" : "5b5b91d6-8afe-304b-bec8-e64b94408777" }, "attributes" : { "__targetSystem" : "ASSURANCE", "parentSpec" : "DMCAT_ProductSpecification_000326_Assurance", "ResponseTarget" : "2 Hours", "RestoreTarget" : "12 Hours" }, "code" : "DMCAT_ProductSpecification_000151_Assurance", "description" : "", "endDate" : "", "guid" : "098e8726-4356-4475-df5b-daaa829510fc", "includeBilling" : false, "instanceId" : "", "name" : "Incident Management_Assurance", "productConfigurationId" : "a3T2O000000B2LpUAK", "specification" : "DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151", "startDate" : "", "status" : "Created", "version" : "1" }, { "additionalAttributes" : { "parentSpec" : "0fe39634-5caf-9786-5804-95623e065e39" }, "attributes" : { "__targetSystem" : "FULFILMENT", "name" : "Hosted UC", "CustomerFacingServiceId" : "", "id" : "", "Quantity" : "", "parentSpec" : "DMCAT_ProductSpecification_000322_Fulfilment" }, "code" : "DMCAT_ProductSpecification_000315_Fulfilment", "description" : "", "endDate" : "", "guid" : "c4dacc21-073c-057c-39e8-86f7f5cac50a", "includeBilling" : false, "instanceId" : "", "name" : "Feature Packs_Fulfilment", "productConfigurationId" : "a3T2O000000B2LpUAK", "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000315", "startDate" : "", "status" : "In Progress", "version" : "1" }, { "additionalAttributes" : { "parentSpec" : "0fe39634-5caf-9786-5804-95623e065e39" }, "attributes" : { "parentSpec" : "DMCAT_ProductSpecification_000322_Fulfilment", "__targetSystem" : "FULFILMENT", "VoicePlan" : "Complete Premium", "id" : "", "CustomerFacingServiceId" : "", "Number" : [ { "schemaId" : "25e92124-d637-4b90-4b1d-e5602d51c955", "attributes" : { "FNN" : "1111111111", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "298c8f72-ac0d-8352-bc4d-c16580ee9e5b", "attributes" : { "FNN" : "2222222222", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "59980903-98db-85f6-7412-295b72f2c7d2", "attributes" : { "FNN" : "3333333333", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "12657f70-e296-8bf1-a28f-5429d9557c29", "attributes" : { "FNN" : "8282345567", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "405c8734-e4f1-27bb-080d-418df5c11b84", "attributes" : { "FNN" : "8282345566", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "de85e26d-cf15-2218-eea5-9737788de49c", "attributes" : { "FNN" : "8282345568", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "c9999e2f-4fce-5f19-4163-9164a0608e9a", "attributes" : { "FNN" : "8282345569", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "fb2a51cc-a339-04ad-d79c-cb65fd47b50c", "attributes" : { "FNN" : "8282345516", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "59227f11-f3c5-66cc-0c63-014f99a1dcfd", "attributes" : { "FNN" : "8282345526", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "2c524a20-853e-3964-7726-7b0bd54bc83b", "attributes" : { "FNN" : "8282345536", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } }, { "schemaId" : "d9da20fc-288d-6f33-faa5-9d62a63e8555", "attributes" : { "FNN" : "8282345546", "rangeFrom" : null, "rangeTo" : null, "status" : "RESERVED", "listCode" : "No Entry Line" } } ] }, "code" : "DMCAT_ProductSpecification_000313_Fulfilment", "description" : "", "endDate" : "", "guid" : "cadee771-3fdc-28fa-2df6-ef5608e8c916", "includeBilling" : false, "instanceId" : "", "name" : "UC Numbers_Fulfilment", "productConfigurationId" : "a3T2O000000B2LpUAK", "specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313", "startDate" : "", "status" : "In Progress", "version" : "1" } ] }');
        att4.Name = 'ServiceSpecifications.json';
        att4.ParentId = serv3.Id;
        atts.add(att4);
        
    Attachment att5 = new Attachment();
        att5.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000670_26","productConfigurationId":"a3T2O000000M9VuUAK","name":"420_AW_670","metadata":{},"instanceId":"","includeBilling":false,"guid":"a748215c-94bd-b3a5-c4da-2bb89b0991dd","endDate":"","description":"Mobility_Billing_DMCAT_Allowance_000670","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000670","attributes":{"billDescription":"International roaming add-on - 4GB","billingSubtype":"IR","value":"4","unitofMeasure":"GB","type":"International Roaming Data","ocsProdID":"T22E_EMOB_MOBPLAN","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","productConfigurationId":"a3T2O000000M9VuUAK","name":"263_NRC_601","metadata":{},"instanceId":"","includeBilling":false,"guid":"29b0cf9c-8bf8-8d1d-a0a8-40d7c451c9ee","endDate":"","description":"Mobile Access_Billing_NonRecurringCharge_000601","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","attributes":{"externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000263_DMCAT_NonRecurringCharge_000601_108","unitofMeasure":"each","rateExcludeGST":"0.00","billDescription":"IR Pay as you go charge","billingSpecId":"BSUSG002_CB","taxTreatment":"TAX Exempt","billingSubtype":"IR","type":"OC","currency":"AUD","ocsProdID":"T22E_IR_USAGE","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151_2","productConfigurationId":"a3T2O000000M9VuUAK","name":"151_ASR","metadata":{},"instanceId":"","includeBilling":false,"guid":"3cfce79e-a8a6-6cfb-da95-da2f72ea9ccc","endDate":"","description":"Incident Management_Assurance","code":"DMCAT_ProductSpecification_000151_Assurance","attributes":{"RestoreTarget":"SLA0010006","ResponseTarget":"SLA0010001","parentSpec":"DMCAT_ProductSpecification_000326_Assurance","__targetSystem":"ASSURANCE"},"additionalAttributes":{"parentSpec":"5ab4e64c-3c88-061e-2731-7c271dd92ce3"}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000420DMCAT_ProductSpecification_000326","productConfigurationId":"a3T2O000000M9VuUAK","name":"326_ASR","metadata":{},"instanceId":"","includeBilling":false,"guid":"5ab4e64c-3c88-061e-2731-7c271dd92ce3","endDate":"","description":"Telstra Managed Service Option 1_Assurance","code":"DMCAT_ProductSpecification_000326_Assurance","attributes":{"__targetSystem":"ASSURANCE","ServiceManagementOption":"1"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000606_5","productConfigurationId":"a3T2O000000M9VuUAK","name":"263_AW_606","metadata":{},"instanceId":"","includeBilling":false,"guid":"62ebbf80-2eaf-5dca-7275-03282898eeb4","endDate":"","description":"Mobility_Billing_DMCAT_Allowance_000606","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000606","attributes":{"billDescription":"IR Day Pass","billingSubtype":"IR","value":"200","unitofMeasure":"MB","type":"International Roaming Data","ocsProdID":"T22E_IRDAYPASS","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000607_6","productConfigurationId":"a3T2O000000M9VuUAK","name":"263_AW_607","metadata":{},"instanceId":"","includeBilling":false,"guid":"8495bfe4-dc6e-6adc-ca29-3f531a6eaa7b","endDate":"","description":"Mobility_Billing_DMCAT_Allowance_000607","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000607","attributes":{"billDescription":"IR Data Topup","billingSubtype":"IR","value":"500","unitofMeasure":"MB","type":"International Roaming Data","ocsProdID":"T22E_IR_AUTOTOPUP","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000644_27","productConfigurationId":"a3T2O000000M9VuUAK","name":"420_AW_644","metadata":{},"instanceId":"","includeBilling":false,"guid":"be0fac3c-28d7-52ee-9547-57f0744fe4f5","endDate":"","description":"Mobility_Billing_DMCAT_Allowance_000644","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000644","attributes":{"billDescription":"International call pack - premium","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_EMOB_IDD2","type":"International Direct Dial","value":"Premium","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","productConfigurationId":"a3T2O000000M9VuUAK","name":"420_RC_654","metadata":{},"instanceId":"","includeBilling":false,"guid":"4f9237c3-bfe8-5a70-a640-cae725c89e31","endDate":"","description":"Mobility_Billing_RecurringCharge_000654","code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","attributes":{"externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_5175","rateExcludeGST":"109.10","billDescription":"Corporate Mobile Plus - Executive Plan","prorate":"FALSE","billInAdvance":"TRUE","billingSpecId":"BSRC001_CB","frequency":"Monthly","currency":"AUD","type":"Voice and Data","applicationDuration":24,"alteredPrice":57.2,"description":"MRO Bonus Plan Discount","recurringChargePeriod":"Months","quantity":"1","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000421","productConfigurationId":"a3T2O000000M9VuUAK","name":"421_ASR","metadata":{},"instanceId":"","includeBilling":false,"guid":"755fd6e9-4107-db93-94d1-aa342bcf40b0","endDate":"","description":"Mobile Device Management_Assurance","code":"DMCAT_ProductSpecification_000421_Assurance","attributes":{"__targetSystem":"ASSURANCE"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000806","productConfigurationId":"a3T2O000000M9VuUAK","name":"420_AW_806","metadata":{},"instanceId":"","includeBilling":false,"guid":"f70a4c44-3689-fb6c-3c01-24aaff275867","endDate":"","description":"Mobility_Billing_DMCAT_Allowance_000806","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000806","attributes":{"billDescription":"Committed Base Plan Allowance","billingSpecId":"BSUSG001_CB","ocsProdID":"T22EM_CDV-04","type":"Committed Data","unitofMeasure":null,"value":null,"__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000M9VuUAK","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"173f6a4f-b2a9-92b2-b6f6-79c64bc00975","endDate":"","description":"Mobile Access_Fulfilment","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"SERVICEPROFILE":"NORMAL","IMSI":"","ShippingRequired":"TRUE","CustomerFacingServiceId":"","MESSAGEBANK":"3G Standard Retail","SuspensionContext":"NA","SKU":"100119211","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","__targetSystem":"FULFILMENT"},"additionalAttributes":{"parentSpec":"ac3a05d6-7059-502d-8b02-cc3c1c906c03","CustomerFacingServiceId":"61429757046"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000M9VuUAK","name":"Mobility_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"ac3a05d6-7059-502d-8b02-cc3c1c906c03","endDate":"","description":"Mobility_Fulfilment","code":"DMCAT_ProductSpecification_000420_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"additionalAttributes":{"currentForecastedDeliveryDate":"2020-05-07T05:21:33+10:00","ConsignmentNumber":"I3AZ10755430","TrackingURL":"https://msto.startrack.com.au/track-trace/?id=I3AZ10755430"}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000669","productConfigurationId":"a3T2O000000M9VuUAK","name":"420_RC_669","metadata":{},"instanceId":"","includeBilling":false,"guid":"82d253e5-88a4-bcb5-a9a9-5368b0f77375","endDate":"","description":"Mobility_Billing_RecurringCharge_000669","code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000669","attributes":{"externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000669_102","billDescription":"International call pack - premium","prorate":"false","billInAdvance":"true","billingSpecId":"BSRC001_CB","frequency":"Monthly","type":null,"rateExcludeGST":0,"quantity":"1","currency":"AUD","__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"'+servV.Id+'","legacyAttributes":[]}');
        att5.Name = 'ServiceSpecifications.json';
        att5.ParentId = servV.Id;
        atts.add(att5);
    
      Attachment att6 = new Attachment();
        att6.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000423_Billing_RecurringCharge_000510","productConfigurationId":"a3T2O000000M9VvUAK","name":"423_RC_510","metadata":{},"instanceId":"","includeBilling":false,"guid":"187e169c-9541-0786-4e98-f27cb9642386","endDate":"","description":"Mobile Device_Billing_RecurringCharge_000510","code":"DMCAT_ProductSpecification_000423_Billing_RecurringCharge_000510","attributes":{"externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000423_DMCAT_RecurringCharge_000510_4981","otcDescription":"Samsung Galaxy S8+ Gold full payment","creditDescription":"Samsung Galaxy S8+ Gold","ContractType":"Hardware Repayment","ContractTerm":"24","billDescription":"Samsung Galaxy S8+ Gold repayment","rateExcludeGST":"51.90","unitofMeasure":"per device","taxTreatment":"GST Applicable","prorate":"FALSE","billInAdvance":"TRUE","billingSpecId":"BSRO001_CB","frequency":"Monthly","currency":"AUD","type":"RC","quantity":"1","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000423DMCAT_Offer_000646_","productConfigurationId":"a3T2O000000M9VvUAK","name":"Mobile Device_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"192a11f8-9563-5e1f-66e6-4943b26737cf","endDate":"","description":"Mobile Device_Fulfilment","code":"DMCAT_ProductSpecification_000423_Fulfilment","attributes":{"SKU":"100115227","DeviceType":"Mobile Handset","Quantity":1,"parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","ShippingRequired":"TRUE","MobileHandsetColour":"GOLD","MobileHandsetModel":"SAMSUNG GALAXY S8+ 4GX HANDSET","MobileHandsetManufacturer":"SAMSUNG","DeviceIDType":"","DeviceID":"","__targetSystem":"FULFILMENT","MobileHandsetVendor":""},"additionalAttributes":{"parentSpec":"ac3a05d6-7059-502d-8b02-cc3c1c906c03"}}],"serviceId":"'+servD.Id+'","legacyAttributes":[]}');
        att6.Name = 'ServiceSpecifications.json';
        att6.ParentId = servD.Id;
        atts.add(att6);
    
    Attachment att7 = new Attachment();
        att7.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151_4","productConfigurationId":"a3T2O000000TlItUAK","name":"151_ASR","metadata":{},"instanceId":"","includeBilling":false,"guid":"a51ce24a-77fd-c347-bd8c-5506c8ced036","endDate":"","description":"Incident Management_Assurance","code":"DMCAT_ProductSpecification_000151_Assurance","attributes":{"RestorationTime":"SLA0010002","ResponseTime":"SLA0010001","parentSpec":"DMCAT_ProductSpecification_000326_Assurance","__targetSystem":"ASSURANCE"},"additionalAttributes":{"parentSpec":"3c65905f-22ed-f7a7-f1e7-54db4e73a50f"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000622","productConfigurationId":"a3T2O000000TlItUAK","name":"Unified Communication Device_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"2d478d6c-6669-f219-b1ae-759128726d32","endDate":"","description":"Unified Communication Device_Fulfilment","code":"DMCAT_ProductSpecification_000622_Fulfilment","attributes":{"DeviceType":"IP Handsets Device","ContractType":"Hardware Repayment","SKU":"100159376","model":"Cisco CP-6851 MPP IP Handset","ShippingRequired":"TRUE","Quantity":1,"id":"","CustomerFacingServiceId":"","DeviceIDType":"","DeviceID":"","NextGenerationVoiceProductInstanceID":"DMCAT_ProductSpecification_000871_Fulfilment","__targetSystem":"FULFILMENT"},"additionalAttributes":{"currentForecastedDeliveryDate":"2020-06-26T07:13:48+10:00","NextGenerationVoiceProductInstanceID":"9a05d09a-05c7-88bd-63a5-14a985ddfe91"}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000622DMCAT_ProductSpecification_000622_Billing_RecurringCharge_000789","productConfigurationId":"a3T2O000000TlItUAK","name":"622_RC_789","metadata":{},"instanceId":"","includeBilling":false,"guid":"ca02b2b7-cbfc-6e28-4764-66220de4253a","endDate":"","description":"Unified Communication Device_Billing_RecurringCharge_000789","code":"DMCAT_ProductSpecification_000622_Billing_RecurringCharge_000789","attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000622_DMCAT_RecurringCharge_000789_7567","ContractTerm":"24","ContractType":"Hardware Repayment","otcDescription":"Cisco IP phone 6851","creditDescription":"Cisco IP phone 6851","billDescription":"Cisco IP phone 6851 repayment","rateExcludeGST":"9.40","frequency":"Monthly","prorate":"false","type":"IP Handsets Device","currency":"AUD","unitofMeasure":"per device","taxTreatment":"GST Applicable","billInAdvance":"true","billingSpecId":"BSRO001_CB","quantity":1,"__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000622DMCAT_ProductSpecification_000326_4","productConfigurationId":"a3T2O000000TlItUAK","name":"326_ASR","metadata":{},"instanceId":"","includeBilling":false,"guid":"3c65905f-22ed-f7a7-f1e7-54db4e73a50f","endDate":"","description":"Telstra Managed Service Option 1_Assurance","code":"DMCAT_ProductSpecification_000326_Assurance","attributes":{"__targetSystem":"ASSURANCE","ServiceManagementOption":"1"},"additionalAttributes":{}}],"serviceId":"'+srvcD.Id+'","legacyAttributes":[]}');
        att7.Name = 'ServiceSpecifications.json';
        att7.ParentId = srvcD.Id;
        atts.add(att7);
    
    Attachment att8 = new Attachment();
        att8.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151_4","productConfigurationId":"a3T2O000000TlItUAK","name":"151_ASR","metadata":{},"instanceId":"","includeBilling":false,"guid":"a51ce24a-77fd-c347-bd8c-5506c8ced036","endDate":"","description":"Incident Management_Assurance","code":"DMCAT_ProductSpecification_000151_Assurance","attributes":{"RestorationTime":"SLA0010002","ResponseTime":"SLA0010001","parentSpec":"DMCAT_ProductSpecification_000326_Assurance","__targetSystem":"ASSURANCE"},"additionalAttributes":{"parentSpec":"3c65905f-22ed-f7a7-f1e7-54db4e73a50f"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000622","productConfigurationId":"a3T2O000000TlItUAK","name":"Unified Communication Device_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"2d478d6c-6669-f219-b1ae-759128725h85","endDate":"","description":"Unified Communication Device_Fulfilment","code":"DMCAT_ProductSpecification_000622_Fulfilment","attributes":{"DeviceType":"IP Handsets Device","ContractType":"Hardware Repayment","SKU":"100159376","model":"Cisco CP-6851 MPP IP Handset","ShippingRequired":"TRUE","Quantity":1,"id":"","CustomerFacingServiceId":"","DeviceIDType":"","DeviceID":"","NextGenerationVoiceProductInstanceID":"DMCAT_ProductSpecification_000871_Fulfilment","__targetSystem":"FULFILMENT"},"additionalAttributes":{"currentForecastedDeliveryDate":"2020-06-26T07:13:48+10:00","NextGenerationVoiceProductInstanceID":"9a05d09a-05c7-88bd-63a5-14a985ddfe91"}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000622DMCAT_ProductSpecification_000622_Billing_RecurringCharge_000789","productConfigurationId":"a3T2O000000TlItUAK","name":"622_RC_789","metadata":{},"instanceId":"","includeBilling":false,"guid":"ca02b2b7-cbfc-6e28-4764-66220de4253a","endDate":"","description":"Unified Communication Device_Billing_RecurringCharge_000789","code":"DMCAT_ProductSpecification_000622_Billing_RecurringCharge_000789","attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000622_DMCAT_RecurringCharge_000789_7567","ContractTerm":"24","ContractType":"Hardware Repayment","otcDescription":"Cisco IP phone 6851","creditDescription":"Cisco IP phone 6851","billDescription":"Cisco IP phone 6851 repayment","rateExcludeGST":"9.40","frequency":"Monthly","prorate":"false","type":"IP Handsets Device","currency":"AUD","unitofMeasure":"per device","taxTreatment":"GST Applicable","billInAdvance":"true","billingSpecId":"BSRO001_CB","quantity":1,"__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000622DMCAT_ProductSpecification_000326_4","productConfigurationId":"a3T2O000000TlItUAK","name":"326_ASR","metadata":{},"instanceId":"","includeBilling":false,"guid":"3c65905f-22ed-f7a7-f1e7-54db4e73a50f","endDate":"","description":"Telstra Managed Service Option 1_Assurance","code":"DMCAT_ProductSpecification_000326_Assurance","attributes":{"__targetSystem":"ASSURANCE","ServiceManagementOption":"1"},"additionalAttributes":{}}],"serviceId":"'+srvcD2.Id+'","legacyAttributes":[]}');
        att8.Name = 'ServiceSpecifications.json';
        att8.ParentId = srvcD2.Id;
        atts.add(att8);
    
    Attachment att9 = new Attachment();
        att9.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000670_26","productConfigurationId":"a3T2O000000M9VuUAK","name":"420_AW_670","metadata":{},"instanceId":"","includeBilling":false,"guid":"a748215c-94bd-b3a5-c4da-2bb89b0991dd","endDate":"","description":"Mobility_Billing_DMCAT_Allowance_000670","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000670","attributes":{"billDescription":"International roaming add-on - 4GB","billingSubtype":"IR","value":"4","unitofMeasure":"GB","type":"International Roaming Data","ocsProdID":"T22E_EMOB_MOBPLAN","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","productConfigurationId":"a3T2O000000M9VuUAK","name":"263_NRC_601","metadata":{},"instanceId":"","includeBilling":false,"guid":"29b0cf9c-8bf8-8d1d-a0a8-40d7c451c9ee","endDate":"","description":"Mobile Access_Billing_NonRecurringCharge_000601","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","attributes":{"externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000263_DMCAT_NonRecurringCharge_000601_108","unitofMeasure":"each","rateExcludeGST":"0.00","billDescription":"IR Pay as you go charge","billingSpecId":"BSUSG002_CB","taxTreatment":"TAX Exempt","billingSubtype":"IR","type":"OC","currency":"AUD","ocsProdID":"T22E_IR_USAGE","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151_2","productConfigurationId":"a3T2O000000M9VuUAK","name":"151_ASR","metadata":{},"instanceId":"","includeBilling":false,"guid":"3cfce79e-a8a6-6cfb-da95-da2f72ea9ccc","endDate":"","description":"Incident Management_Assurance","code":"DMCAT_ProductSpecification_000151_Assurance","attributes":{"RestoreTarget":"SLA0010006","ResponseTarget":"SLA0010001","parentSpec":"DMCAT_ProductSpecification_000326_Assurance","__targetSystem":"ASSURANCE"},"additionalAttributes":{"parentSpec":"5ab4e64c-3c88-061e-2731-7c271dd92ce3"}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000420DMCAT_ProductSpecification_000326","productConfigurationId":"a3T2O000000M9VuUAK","name":"326_ASR","metadata":{},"instanceId":"","includeBilling":false,"guid":"5ab4e64c-3c88-061e-2731-7c271dd92ce3","endDate":"","description":"Telstra Managed Service Option 1_Assurance","code":"DMCAT_ProductSpecification_000326_Assurance","attributes":{"__targetSystem":"ASSURANCE","ServiceManagementOption":"1"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000606_5","productConfigurationId":"a3T2O000000M9VuUAK","name":"263_AW_606","metadata":{},"instanceId":"","includeBilling":false,"guid":"62ebbf80-2eaf-5dca-7275-03282898eeb4","endDate":"","description":"Mobility_Billing_DMCAT_Allowance_000606","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000606","attributes":{"billDescription":"IR Day Pass","billingSubtype":"IR","value":"200","unitofMeasure":"MB","type":"International Roaming Data","ocsProdID":"T22E_IRDAYPASS","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000607_6","productConfigurationId":"a3T2O000000M9VuUAK","name":"263_AW_607","metadata":{},"instanceId":"","includeBilling":false,"guid":"8495bfe4-dc6e-6adc-ca29-3f531a6eaa7b","endDate":"","description":"Mobility_Billing_DMCAT_Allowance_000607","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000607","attributes":{"billDescription":"IR Data Topup","billingSubtype":"IR","value":"500","unitofMeasure":"MB","type":"International Roaming Data","ocsProdID":"T22E_IR_AUTOTOPUP","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000644_27","productConfigurationId":"a3T2O000000M9VuUAK","name":"420_AW_644","metadata":{},"instanceId":"","includeBilling":false,"guid":"be0fac3c-28d7-52ee-9547-57f0744fe4f5","endDate":"","description":"Mobility_Billing_DMCAT_Allowance_000644","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000644","attributes":{"billDescription":"International call pack - premium","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_EMOB_IDD2","type":"International Direct Dial","value":"Premium","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","productConfigurationId":"a3T2O000000M9VuUAK","name":"420_RC_654","metadata":{},"instanceId":"","includeBilling":false,"guid":"4f9237c3-bfe8-5a70-a640-cae725c89e31","endDate":"","description":"Mobility_Billing_RecurringCharge_000654","code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","attributes":{"externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_5175","rateExcludeGST":"109.10","billDescription":"Corporate Mobile Plus - Executive Plan","prorate":"FALSE","billInAdvance":"TRUE","billingSpecId":"BSRC001_CB","frequency":"Monthly","currency":"AUD","type":"Voice and Data","applicationDuration":24,"alteredPrice":57.2,"description":"MRO Bonus Plan Discount","recurringChargePeriod":"Months","quantity":"1","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000421","productConfigurationId":"a3T2O000000M9VuUAK","name":"421_ASR","metadata":{},"instanceId":"","includeBilling":false,"guid":"755fd6e9-4107-db93-94d1-aa342bcf40b0","endDate":"","description":"Mobile Device Management_Assurance","code":"DMCAT_ProductSpecification_000421_Assurance","attributes":{"__targetSystem":"ASSURANCE"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000806","productConfigurationId":"a3T2O000000M9VuUAK","name":"420_AW_806","metadata":{},"instanceId":"","includeBilling":false,"guid":"f70a4c44-3689-fb6c-3c01-24aaff275867","endDate":"","description":"Mobility_Billing_DMCAT_Allowance_000806","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000806","attributes":{"billDescription":"Committed Base Plan Allowance","billingSpecId":"BSUSG001_CB","ocsProdID":"T22EM_CDV-04","type":"Committed Data","unitofMeasure":null,"value":null,"__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000M9VuUAK","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"173f6a4f-b2a9-92b2-b6f6-79c64bc00975","endDate":"","description":"Mobile Access_Fulfilment","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"SERVICEPROFILE":"NORMAL","IMSI":"","ShippingRequired":"TRUE","CustomerFacingServiceId":"","MESSAGEBANK":"3G Standard Retail","SuspensionContext":"NA","SKU":"100119211","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","__targetSystem":"FULFILMENT"},"additionalAttributes":{"parentSpec":"ac3a05d6-7059-502d-8b02-cc3c1c906c03","CustomerFacingServiceId":"61429757046"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000M9VuUAK","name":"Mobility_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"ac3a05d6-7059-502d-8b02-cc3c1c906c03","endDate":"","description":"Mobility_Fulfilment","code":"DMCAT_ProductSpecification_000420_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"additionalAttributes":{"currentForecastedDeliveryDate":"2020-05-07T05:21:33+10:00","ConsignmentNumber":"I3AZ10755430","TrackingURL":"https://msto.startrack.com.au/track-trace/?id=I3AZ10755430"}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000669","productConfigurationId":"a3T2O000000M9VuUAK","name":"420_RC_669","metadata":{},"instanceId":"","includeBilling":false,"guid":"82d253e5-88a4-bcb5-a9a9-5368b0f77375","endDate":"","description":"Mobility_Billing_RecurringCharge_000669","code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000669","attributes":{"externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000669_102","billDescription":"International call pack - premium","prorate":"false","billInAdvance":"true","billingSpecId":"BSRC001_CB","frequency":"Monthly","type":null,"rateExcludeGST":0,"quantity":"1","currency":"AUD","__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"'+servDev.Id+'","legacyAttributes":[]}');
        att9.Name = 'ServiceSpecifications.json';
        att9.ParentId = servDev.Id;
        atts.add(att9);
        
     Attachment att10 = new Attachment();
        att10.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000423_Billing_RecurringCharge_000510","productConfigurationId":"a3T2O000000M9VvUAK","name":"423_RC_510","metadata":{},"instanceId":"","includeBilling":false,"guid":"187e169c-9541-0786-4e98-f27cb9642386","endDate":"","description":"Mobile Device_Billing_RecurringCharge_000510","code":"DMCAT_ProductSpecification_000423_Billing_RecurringCharge_000510","attributes":{"externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000423_DMCAT_RecurringCharge_000510_4981","otcDescription":"Samsung Galaxy S8+ Gold full payment","creditDescription":"Samsung Galaxy S8+ Gold","ContractType":"Hardware Repayment","ContractTerm":"24","billDescription":"Samsung Galaxy S8+ Gold repayment","rateExcludeGST":"51.90","unitofMeasure":"per device","taxTreatment":"GST Applicable","prorate":"FALSE","billInAdvance":"TRUE","billingSpecId":"BSRO001_CB","frequency":"Monthly","currency":"AUD","type":"RC","quantity":"1","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000423DMCAT_Offer_000646_","productConfigurationId":"a3T2O000000M9VvUAK","name":"Mobile Device_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"192a11f8-9563-5e1f-66e6-4943b26737cf","endDate":"","description":"Mobile Device_Fulfilment","code":"DMCAT_ProductSpecification_000423_Fulfilment","attributes":{"SKU":"100115227","DeviceType":"Mobile Handset","Quantity":1,"parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","ShippingRequired":"TRUE","MobileHandsetColour":"GOLD","MobileHandsetModel":"SAMSUNG GALAXY S8+ 4GX HANDSET","MobileHandsetManufacturer":"SAMSUNG","DeviceIDType":"","DeviceID":"","__targetSystem":"FULFILMENT","MobileHandsetVendor":""},"additionalAttributes":{"parentSpec":"ac3a05d6-7059-502d-8b02-cc3c1c906c03","DeviceID":"4045322878914276","DeviceIDType":"MAC"}}],"serviceId":"'+servDev1.Id+'","legacyAttributes":[]}');
        att10.Name = 'ServiceSpecifications.json';
        att10.ParentId = servDev1.Id;
        atts.add(att10);
    
    Attachment att11 = new Attachment();
        att11.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000M9VuUAK","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"173f6a4f-b2a9-92b2-b6f6-79c64bc00975","endDate":"","description":"Mobile Access_Fulfilment","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"SERVICEPROFILE":"NORMAL","IMSI":"","ShippingRequired":"TRUE","CustomerFacingServiceId":"","MESSAGEBANK":"3G Standard Retail","SuspensionContext":"NA","SKU":"100119211","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","__targetSystem":"FULFILMENT"},"additionalAttributes":{"CustomerFacingServiceId":"61429757046"}}],"serviceId":"'+servRFA1.Id+'","legacyAttributes":[]}');
        att11.Name = 'ServiceSpecifications.json';
        att11.ParentId = servRFA1.Id;
        atts.add(att11);
    
        insert atts;    
    }
    
    @isTest
    static void processSubStageNotificationTest(){
        Test.startTest();
        csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'testService_1' AND csord__Order__r.Name= 'TestOrder' limit 1][0];
        List<csord__Service__c>servList =[SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'testService_3' limit 2];       
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
       
        List<Service_Specification__c> servSpList = new List<Service_Specification__c>();
        Service_Specification__c servSpe = new Service_Specification__c();
        servSpe.Name = 'Mobile Access_Fulfilment';
        servSpe.Service__c = svc1.id;
        servSpe.Code__c ='DMCAT_ProductSpecification_000263';
        servSpe.GUID__c = 'dabc3fdb-332e-c8ee-e853-24f41182c4d7';
        servSpList.add(servSpe);
        
        Service_Specification__c servSpe1 = new Service_Specification__c();
        servSpe1.Name = 'UC Site_Fulfilment';
        servSpe1.Service__c = svc1.id;
        servSpe1.Code__c ='DMCAT_ProductSpecification_000322';
        servSpe1.GUID__c = 'e4b35ea7-c933-80cc-f3a1-4969969dbf8b';
        servSpList.add(servSpe1);
        
        insert servSpList; 
        
        subStageNotification__c subStageNot = new subStageNotification__c();
        subStageNot.Name = 'Logical Deactivation';
        subStageNot.Service_Specification__c= servSpe.id;
        subStageNot.Substage_Completion_Date__c=System.Date.today();
        insert subStageNot;
        
        List<ID> orderIdList = new List<ID>();
        orderIdList.ADD(ord.id);
        Map<String,List<NotificationParameters>> orderItemIdNotifMap = new Map<String,List<NotificationParameters>>();
        List<NotificationParameters> paramsList = new  List<NotificationParameters>();
        NotificationParameters  notif = new NotificationParameters();
        notif.externalOrderId = ord.csord__Order_Number__c;
        notif.eventTimestamp = '2018-02-24T06:08+10:00';
        notif.orderItemId = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1add-89725fee80c9';
        notif.notificationAttributes = '"attributes":[{"name":"subStage","value":"Equipment Ordered"}, {"name":"currentForecastedDeliveryDate","value":"2020-01-09T01:04:09+11:00"}, {"name":"EquipmentOrderedDate","value":"2020-01-09T00:53:11+11:00"}, {"name":"LogisticOrderNumber","value":"1000007518"}]';
        notif.orderItemDetails = '"product":{"productId": "d1cbe67e-4954-2f5d-b5bd-ec26e906c7ce","status": "In Progress","attributes": [],"childProduct": [{"productId": "69468501-cf96-3b5c-edb1-030d5b6687c4","status": "In Progress","attributes": []}]}';
        notif.eventType = 'subStageNotification';
        notif.orderItemVersion = 1;
        notif.sourceSystem = 'FULFILMENT';
        paramsList.add(notif);
        
        
        NotificationParameters  notif1 = new NotificationParameters();
        notif1.externalOrderId = ord.csord__Order_Number__c;
        notif1.eventTimestamp = '2018-02-24T06:08+10:00';
        notif1.orderItemId = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1add-89725fee80c9';
        notif1.notificationAttributes = '"attributes":[{"name":"subStage","value":"Delivery Tracking"}, {"name":"currentForecastedDeliveryDate","value":"2020-01-09T01:04:09+11:00"}, {"name":"EquipmentOrderedDate","value":"2020-01-09T00:53:11+11:00"}, {"name":"ConsignmentNumber","value":"1000007518"}]';
        notif1.orderItemDetails = '"product":{"productId": "d1cbe67e-4954-2f5d-b5bd-ec26e906c7ce","status": "In Progress","attributes": [],"childProduct": [{"productId": "69468501-cf96-3b5c-edb1-030d5b6687c4","status": "In Progress","attributes": []}]}';
        notif1.eventType = 'subStageNotification';
        notif1.orderItemVersion = 1;
        notif1.sourceSystem = 'FULFILMENT';
         paramsList.add(notif1);
        
        
        NotificationParameters  notif3 = new NotificationParameters();
        notif3.externalOrderId = ord.csord__Order_Number__c;
        notif3.eventTimestamp = '2018-02-24T06:08+10:00';
        notif3.orderItemId = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1add-89725fee80c9';
        notif3.notificationAttributes = '"attributes":[{"name":"subStage","value":"Delivery Tracking"}, {"name":"currentForecastedDeliveryDate","value":"2020-01-09T01:04:09+11:00"}, {"name":"EquipmentOrderedDate","value":"2020-01-09T00:53:11+11:00"}, {"name":"TrackingURL","value":"1000007518"}]';
        notif3.orderItemDetails = '"product":{"productId": "d1cbe67e-4954-2f5d-b5bd-ec26e906c7ce","status": "In Progress","attributes": [],"childProduct": [{"productId": "69468501-cf96-3b5c-edb1-030d5b6687c4","status": "In Progress","attributes": []}]}';
        notif3.eventType = 'subStageNotification';
        notif3.orderItemVersion = 1;
        notif3.sourceSystem = 'FULFILMENT';
         paramsList.add(notif3);
        
        NotificationParameters  notif2 = new NotificationParameters();
        notif2.externalOrderId = ord.csord__Order_Number__c;
        notif2.eventTimestamp = '2018-02-24T06:08+10:00';
        notif2.orderItemId = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1add-89725fee80c9';
        notif2.notificationAttributes = '"attributes":[{"name":"subStage","value":"Picking & Packing"}, {"name":"currentForecastedDeliveryDate","value":"2020-01-09T01:04:09+11:00"}, {"name":"EquipmentOrderedDate","value":"2020-01-09T00:53:11+11:00"}, {"name":"EstimatedDeliveryDate","value":"2020-01-09T00:53:11+11:00"}]';
        notif2.orderItemDetails = '"product":{"productId": "d1cbe67e-4954-2f5d-b5bd-ec26e906c7ce","status": "In Progress","attributes": [],"childProduct": [{"productId": "69468501-cf96-3b5c-edb1-030d5b6687c4","status": "In Progress","attributes": []}]}';
        notif2.eventType = 'subStageNotification';
        notif2.orderItemVersion = 1;
        notif2.sourceSystem = 'FULFILMENT';
         paramsList.add(notif2);
        
         NotificationParameters  notif4 = new NotificationParameters();
        notif4.externalOrderId = ord.csord__Order_Number__c;
        notif4.eventTimestamp = '2018-02-24T06:08+10:00';
        notif4.orderItemId = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1add-89725fee80c9';
        notif4.notificationAttributes = '"attributes":[{"name":"subStage","value":"Product Requirements Validation"}, {"name":"currentForecastedDeliveryDate","value":"2020-01-09T01:04:09+11:00"}, {"name":"EquipmentOrderedDate","value":"2020-01-09T00:53:11+11:00"}, {"name":"EstimatedDeliveryDate","value":"2020-01-09T00:53:11+11:00"}]';
        notif4.orderItemDetails = '"product":{"productId": "d1cbe67e-4954-2f5d-b5bd-ec26e906c7ce","status": "In Progress","attributes": [],"childProduct": [{"productId": "69468501-cf96-3b5c-edb1-030d5b6687c4","status": "In Progress","attributes": [{"name":"NetworkServiceId","value":"1f8a7ee1-da9c-4cd6-9054-953cc11980d8"}]}]}';
        notif4.eventType = 'subStageNotification';
        notif4.orderItemVersion = 1;
        notif4.sourceSystem = 'FULFILMENT';
        
       paramsList.add(notif4);
        
        orderItemIdNotifMap.put(notif.orderItemId,paramsList);
        
        List<Service_Specification__c> servSpecList = new List<Service_Specification__c>();
        Service_Specification__c servSpec = new Service_Specification__c();
        servSpec.Name = 'Mobile Access_Fulfilment';
        servSpec.Service__c = svc1.id;
        servSpec.Code__c ='DMCAT_ProductSpecification_000263';
        servSpec.GUID__c = 'dabc3fdb-332e-c8ee-e853-24f41182c4d7';
        servSpecList.add(servSpec);
        
        Service_Specification__c servSpec1 = new Service_Specification__c();
        servSpec1.Name = 'UC Site_Fulfilment';
        servSpec1.Service__c = svc1.id;
        servSpec1.Code__c ='DMCAT_ProductSpecification_000322';
        servSpec1.GUID__c = 'e4b35ea7-c933-80cc-f3a1-4969969dbf8b';
        servSpecList.add(servSpec1);
        
        //insert servSpecList;
        
        
        subStageNotification__c subStageNotif = new subStageNotification__c();
        subStageNotif.Name = 'Logical Deactivation';
        //subStageNotif.Service_Specification__c= servSpec.id;
        subStageNotif.Substage_Completion_Date__c=System.Date.today();
        insert subStageNotif;
            
        ManageSubStageNotificationMSUpdate.processSubStageNotification(orderItemIdNotifMap,paramsList);
        
        ManageSubStageNotificationMSUpdate.updateOrderSubStage(orderIdList);
        ManageSubStageNotificationMSUpdate.checkSubscriptionDeactivation(orderIdList);
        
       csord__Order__c ord1 = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
        List<ID> orderIdList1 = new List<ID>();
        orderIdList1.ADD(ord1.id);
    List<String> serSet = new List<String>();
    csord__Service__c service = [SELECT Id, Name,Tenancy_Id__c, substage__c, stage__c, csord__Status__c,toBeCancelled__c , csord__Subscription__c FROM csord__Service__c WHERE name ='testService_1'];
  serSet.add(service.id);
    Map<Id,string> servIdSubstageMap = new Map<Id,string>();
    servIdSubstageMap.put(service.id,'Equipment Ordered');
    ManageSubStageNotificationMSUpdate.updateServices(serSet,servIdSubstageMap); //EDGE -EDGE-174900
       // ManageSubStageNotificationMSUpdate.getGuidList(servList);
        System.assertNotEquals(orderIdList,null);
        Test.stopTest();
    }
    
   /* @isTest
    static void getGuidListTest(){
        Test.startTest();
        
        List<csord__Service__c>servList =[SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'testService_1' Or Name ='testService_2' limit 2];       
        Map<String,List<String>> guidMap= ManageSubStageNotificationMSUpdate.getGuidList(servList);
         
        Test.stopTest();
    }*/
    
    /*@isTest
    static void getGuidAdditionalAttributesTest(){
        Test.startTest();
        List<Id>serId= new List<Id>();
       List<csord__Service__c>servList =[SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'testService_1' Or Name ='testService_2' limit 2];       
        for(csord__Service__c ser:servList){
            serId.add(ser.id);
        }
       // Map<String,Map<String,String>>guidAddAttrMap = ManageSubStageNotificationMSUpdate.getGuidAdditionalAttributes(servList,serId);
        
        Test.stopTest();
         System.assertNotEquals(null, servList);
    }*/
    
    @isTest
    static void getGuidAttrTest(){
        Test.startTest();
        List<NotificationParameters> paramsList =  new List<NotificationParameters>();
        Map<String,Map<String,String>> guidAddAttribMap= new  Map<String,Map<String,String>>();
        List<Id>serviceIdList = new List<Id>();
    List<csord__Service__c> childService = new List<csord__Service__c> ();
      ManageSubStageNotificationMSUpdate.getGuidAttr(paramsList,childService,guidAddAttribMap,serviceIdList);
        System.assertNotEquals(serviceIDList,null);
        Test.stopTest();
    }
    
    @isTest
    static void updateAssetsTest(){
        Test.startTest();
        Map<String,Map<String,String>>servnumDeviceMap = new Map<String,Map<String,String>>();
        List<String>serviceIDList = new List<String>();
        Map<String,String> servDeviceblankmap = new Map<String,String>();
        ManageSubStageNotificationMSUpdate.updateAssets(servnumDeviceMap,serviceIDList,servDeviceblankmap);
        System.assertNotEquals(serviceIDList,null);
         Test.stopTest();
    }
    
    @isTest
    static void getChildServicesTest(){
    Test.startTest();
      List<Id> subscriptionIdList = new List<Id>();
     csord__Subscription__c sub = [Select id,name from csord__Subscription__c where name  = 'testSubscription' LIMIT 1 ];
    subscriptionIdList.add(sub.Id); 
    Set<String> guidSet = new Set<String>();
    List<String> childList = ManageSubStageNotificationMSUpdate.getChildServices(subscriptionIdList,guidSet);
        System.assertNotEquals(guidSet,null);
    Test.stopTest();
    }
    
     @isTest
    static void updateServicesTest(){
     Test.startTest();
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
        List<ID> orderIdList = new List<ID>();
        orderIdList.ADD(ord.id);
    List<String> serSet = new List<String>();
    csord__Service__c service = [SELECT Id, Name,Tenancy_Id__c, substage__c, stage__c, csord__Status__c,toBeCancelled__c , csord__Subscription__c FROM csord__Service__c WHERE name ='testService_1'];
  serSet.add(service.id);
    Map<Id,string> servIdSubstageMap = new Map<Id,string>();
    servIdSubstageMap.put(service.id,'Equipment Ordered');
    //ManageSubStageNotificationMSUpdate.updateServices(serSet,servIdSubstageMap);
    ManageSubStageNotificationMSUpdate.getSubStageMatrix(orderIdList,servIdSubstageMap,servIdSubstageMap);
    ManageSubStageNotificationMSUpdate.updateOrder(ord.id);
        System.assertNotEquals(service,null);
    Test.stopTest();
    }
    
   /*  @isTest
    static void getSubstageMatrixTest(){
     Test.startTest();
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
        List<ID> orderIdList = new List<ID>();
        orderIdList.ADD(ord.id);
    List<String> serSet = new List<String>();
    csord__Service__c service = [SELECT Id, Name,Tenancy_Id__c, substage__c, stage__c, csord__Status__c,toBeCancelled__c , csord__Subscription__c FROM csord__Service__c WHERE name ='IP Site'];
  serSet.add(service.id);
    Map<Id,string> servIdSubstageMap = new Map<Id,string>();
    servIdSubstageMap.put(service.id,'logical deactivation');
    Map<Id,String> servicesToBeCancelled = new Map<Id,String>();
    servicesToBeCancelled.put(service.id,'true');
    //ManageSubStageNotificationMSUpdate.updateServices(serSet,servIdSubstageMap);
    ManageSubStageNotificationMSUpdate.getSubStageMatrix(serSet,servIdSubstageMap,servicesToBeCancelled);
    //ManageSubStageNotificationMSUpdate.updateOrder(ord.id);
        System.assertNotEquals(service,null);
    Test.stopTest();
    }*/
     @isTest
    static void updateSubscriptionsTest(){
     Test.startTest();
    List<Id> subIdList = new List<Id>();
    csord__Subscription__c sub = [Select id,name from csord__Subscription__c where name  = 'testSubscription1' LIMIT 1 ];
    subIdList.add(sub.Id);
    String notificationType = 'subStage';
    ManageSubStageNotificationMSUpdate.updateSubscriptions(subIdList,notificationType);
    System.assertNotEquals(notificationType,null);
    
    Test.stopTest();
    }
    
    /* @isTest
    static void getGuidNotifAttrTest(){
        Test.startTest();
         csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'testService_1' AND csord__Order__r.Name= 'TestOrder' limit 1][0];
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
      
        List<NotificationParameters> paramsList =  new List<NotificationParameters>();
         NotificationParameters  notif3 = new NotificationParameters();
        notif3.externalOrderId = ord.csord__Order_Number__c;
        notif3.eventTimestamp = '2018-02-24T06:08+10:00';
        notif3.orderItemId = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1add-89725fee80c9';
        notif3.notificationAttributes = '"attributes":[{"name":"subStage","value":"Delivery Tracking"}, {"name":"currentForecastedDeliveryDate","value":"2020-01-09T01:04:09+11:00"}, {"name":"EquipmentOrderedDate","value":"2020-01-09T00:53:11+11:00"}, {"name":"TrackingURL","value":"1000007518"}]';
        notif3.orderItemDetails = '"product":{"productId": "d1cbe67e-4954-2f5d-b5bd-ec26e906c7ce","status": "In Progress","attributes": [],"childProduct": [{"productId": "69468501-cf96-3b5c-edb1-030d5b6687c4","status": "In Progress","attributes": []}]}';
        notif3.eventType = 'subStageNotification';
        notif3.orderItemVersion = 1;
        notif3.sourceSystem = 'FULFILMENT';
         paramsList.add(notif3);
        
        Map<String,Map<String,String>> guidAddAttribMap= new  Map<String,Map<String,String>>();
       Map<String,Id>seridNumberMap = new Map<String,Id>();
     // ManageSubStageNotificationMSUpdate.getGuidNotifAttr(guidAddAttribMap,paramsList,seridNumberMap);
        System.assertNotEquals(svc1,null);
        Test.stopTest();
    }*/
    
    
     @isTest
    static void updateAssetTest(){
     Test.startTest();
     csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
        List<ID> orderIdList = new List<ID>();
        orderIdList.ADD(ord.id);
    String notificationType = 'subStage';
    ManageSubStageNotificationMSUpdate.updateOrder(ord.id);
    System.assertNotEquals(notificationType,null);
    
    Test.stopTest();
    }
    @isTest ////EDGE-144111
    static void getGuidAttrTest2(){
        Test.startTest();
         csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'testService_1' AND csord__Order__r.Name= 'TestOrder' limit 1][0];
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
      List<Number__c> lstNumber = new List<Number__c>();
        lstNumber.add(new Number__c(Service_Id__c = svc1.csordtelcoa__Service_Number__c,Type__c='New',
        Service_Number__c='9876786876'));
        
        Insert lstNumber;
        List<NotificationParameters> paramsList =  new List<NotificationParameters>();
         NotificationParameters  notif3 = new NotificationParameters();
        notif3.externalOrderId = ord.csord__Order_Number__c;
        notif3.eventTimestamp = '2018-02-24T06:08+10:00';
        notif3.orderItemId = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1add-89725fee80c9';
        notif3.notificationAttributes = '"attributes":[{"name":"subStage","value":"Delivery Tracking"}, {"name":"currentForecastedDeliveryDate","value":"2020-01-09T01:04:09+11:00"}, {"name":"EquipmentOrderedDate","value":"2020-01-09T00:53:11+11:00"}, {"name":"TrackingURL","value":"1000007518"}]';
        notif3.orderItemDetails = '"product":{"productId": "d1cbe67e-4954-2f5d-b5bd-ec26e906c7ce","status": "In Progress","attributes": [],"childProduct": [{"productId": "69468501-cf96-3b5c-edb1-030d5b6687c4","status": "In Progress","attributes": [{"name":"IMSI","value":"45665756768678"},{"name":"SIMSerialNumber","value":"69601123456789012365"}]}]}';
        notif3.eventType = 'subStageNotification';
        notif3.orderItemVersion = 1;
        notif3.sourceSystem = 'FULFILMENT';
         paramsList.add(notif3);
        
        Map<String,Map<String,String>> guidAddAttribMap= new  Map<String,Map<String,String>>();
       List<Id>serviceIdList = new List<Id>();
        List<csord__Service__c> lstService = new List<csord__Service__c>();
        lstService.add(svc1);
        serviceIdList.add(svc1.id);
        ManageSubStageNotificationMSUpdate.getGuidAttr(paramsList,lstService,guidAddAttribMap,serviceIdList);
        System.assertNotEquals(svc1,null);
        List<String> setserviceNumber = new List<String>();
        setserviceNumber.add(svc1.csordtelcoa__Service_Number__c);
        
        List<Number__C> lstupdatedNumber=[SELECT Id, Type__c,IMSI__c, Sim_Serial_Number__c,Service_Id__c,Status__c 
                                       FROM Number__c WHERE 
                                       Service_Id__c != null AND Service_Id__c IN:setserviceNumber];
       // System.assertEquals(lstupdatedNumber[0].IMSI__c,'45665756768678');
        Test.stopTest();
    }
    
    @isTest 
    static void testDeviceID(){ //added as part of EDGE-158047
     csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder'];
     csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name,csord__Identification__c,csord__Service__c from csord__Service__c where Name = 'Mobility' and csord__Identification__c='Mobility'];
      //system.assertEquals(svc,null);
     List<NotificationParameters> notifParamList=new List<NotificationParameters>();
     NotificationParameters notif=new NotificationParameters();
      notif.errorDetails='';
      notif.notificationAttributes='"attributes":[{"name":"ConsignmentNumber","value":"I3AZ10755430"}, {"name":"TrackingURL","value":"https://msto.startrack.com.au/track-trace/?id=I3AZ10755430"}, {"name":"currentForecastedDeliveryDate","value":"2020-05-07T05:21:33+10:00"}, {"name":"subStage","value":"Delivery Tracking"}]';
      notif.orderItemDetails='"product":{"productId": "ac3a05d6-7059-502d-8b02-cc3c1c906c03","status": "In Progress","attributes": [],"childProduct": [{"productId": "192a11f8-9563-5e1f-66e6-4943b26737cf","status": "In Progress","attributes": [{"name":"DeviceID","value":"869400010717819"},{"name":"DeviceIDType","value":"IMEI"}]},{"productId": "173f6a4f-b2a9-92b2-b6f6-79c64bc00975","status": "In Progress","attributes": []}]}';
      notif.eventType='subStageNotification';
      notif.eventTimestamp='2018-12-03T20:39:54+11:00';
      notif.sourceSystem='Fulfilment';
      notif.externalOrderId=ord.csord__Order_Number__c;
      notif.orderItemId=ord.csord__Order_Number__c+'|'+svc.csordtelcoa__Service_Number__c+'|ac3a05d6-7059-502d-8b02-cc3c1c906c03';
      notif.orderItemVersion=1;
      notifParamList.add(notif);
    Map<String, List<NotificationParameters >> orderItemIdNotifMap = new Map< String, List<NotificationParameters >> ();
    ManageOrderNotificationServiceMSUpdate.processNotification(orderItemIdNotifMap,notifParamList);
        
        Asset aset=[select id,name,AssetID__c,AssetIDType__c from Asset where Name='Mobile Device'];
        if(aset.AssetIDType__c!=null){
             system.assertEquals('IMEI',aset.AssetIDType__c);
        }
       
    }
  
  @isTest 
    static void testDeviceIDmultipleSubstage(){
    csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder'];
        csord__Service__c serv = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name,csord__Identification__c,csord__Service__c from csord__Service__c where Name = 'mobDevice' and csord__Identification__c='mobDevice'];
    List<OrderNotification__e> eventList = new List<OrderNotification__e>();
        OrderNotification__e event1 = new OrderNotification__e();
        event1.errorDetails__c = null;
    event1.notificationAttributes__c ='"attributes":[{"name":"currentForecastedDeliveryDate","value":"2020-06-04T20:42:11+10:00"},{"name":"subStage","value":"Delivery Tracking"}]';
        event1.orderItemDetails__c = '"product":{"productId": "2d478d6c-6669-f219-b1ae-759128726d32","status": "In Progress","attributes": [{"name":"DeviceIDType","value":"MAC Address"},{"name":"DeviceID","value":"2CE4F1BEFD31"}]}';
        event1.eventType__c = 'subStageNotification';
        event1.orderItemId__c = ord.csord__Order_Number__c +'|'+serv.csordtelcoa__Service_Number__c+'|'+'2d478d6c-6669-f219-b1ae-759128726d32';
        event1.sourceSystem__c = 'Fulfilment';
        event1.sequence__c = 1;
        event1.msCorrelationId__c = '5463873930';
        event1.eventTimeStamp__c = '2020-02-20T20:39:54+11:00';
        event1.externalOrderId__c = ord.csord__Order_Number__c;
        eventList.add(event1);    
    
    OrderNotification__e event2 = new OrderNotification__e();
        event2.errorDetails__c = null;
    event2.notificationAttributes__c = '"attributes":[{"name":"ServiceActivationDate","value":"2020-04-29T13:12:54+10:00"}, {"name":"currentForecastedDeliveryDate","value":"2020-05-18T20:06:39+10:00"}, {"name":"subStage","value":"Product Activation and Testing"}]';
        event2.orderItemDetails__c = '"product":{"productId": "2d478d6c-6669-f219-b1ae-759128726d32","status": "In Progress","attributes": []}';
        event2.eventType__c = 'subStageNotification';
        event2.orderItemId__c = ord.csord__Order_Number__c +'|'+serv.csordtelcoa__Service_Number__c+'|'+'2d478d6c-6669-f219-b1ae-759128726d32';
        event2.sourceSystem__c = 'Fulfilment';
        event2.sequence__c = 2;
        event2.msCorrelationId__c = '5463873931';
        event2.eventTimeStamp__c = '2020-02-20T20:39:54+11:00';
        event2.externalOrderId__c = ord.csord__Order_Number__c;
        eventList.add(event2);  
    
        OrderNotification__e event3 = new OrderNotification__e();
        event3.errorDetails__c = null;
    event3.notificationAttributes__c = '"attributes":[{"name":"CustomerOrderAcceptanceDate","value":"2020-04-29T13:12:54+10:00"}, {"name":"currentForecastedDeliveryDate","value":"2020-05-18T20:06:39+10:00"}, {"name":"subStage","value":"Customer Order Acceptance"}]';
        event3.orderItemDetails__c = '"product":{"productId": "2d478d6c-6669-f219-b1ae-759128726d32","status": "In Progress","attributes": []}';
        event3.eventType__c = 'subStageNotification';
        event3.orderItemId__c = ord.csord__Order_Number__c +'|'+serv.csordtelcoa__Service_Number__c+'|'+'2d478d6c-6669-f219-b1ae-759128726d32';
        event3.sourceSystem__c = 'Fulfilment';
        event3.sequence__c = 3;
        event3.msCorrelationId__c = '5463873932';
        event3.eventTimeStamp__c = '2020-02-20T20:39:54+11:00';
        event3.externalOrderId__c = ord.csord__Order_Number__c;
        eventList.add(event3);  
        
        Test.startTest();
        Database.SaveResult[] result = EventBus.publish(eventList);
        Test.StopTest();
    
     Asset aset=[select id,name,AssetID__c,AssetIDType__c from Asset where Name='IAD Device'];
        if(aset.AssetID__c!=null){
             system.assertEquals('2CE4F1BEFD31',aset.AssetID__c);
        }
        if(aset.AssetIDType__c!=null){
            system.assertEquals('MAC Address',aset.AssetIDType__c);
        }
         
    }
    
    @isTest 
    static void testDeviceIDservicespecTest(){
    csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder'];
        csord__Service__c serv = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name,csord__Identification__c,csord__Service__c from csord__Service__c where Name = 'mobDevice' and csord__Identification__c='mobDevice'];
    List<OrderNotification__e> eventList = new List<OrderNotification__e>();
        OrderNotification__e event1 = new OrderNotification__e();
        event1.errorDetails__c = null;
    event1.notificationAttributes__c ='"attributes":[{"name":"currentForecastedDeliveryDate","value":"2020-06-04T20:42:11+10:00"},{"name":"subStage","value":"Delivery Tracking"}]';
        event1.orderItemDetails__c = '"product":{"productId": "2d478d6c-6669-f219-b1ae-759128726d32","status": "In Progress","attributes": [{"name":"DeviceIDType","value":"MAC Address"},{"name":"DeviceID","value":"2CE4F1BEFD31"}]}';
        event1.eventType__c = 'subStageNotification';
        event1.orderItemId__c = ord.csord__Order_Number__c +'|'+serv.csordtelcoa__Service_Number__c+'|'+'2d478d6c-6669-f219-b1ae-759128726d32';
        event1.sourceSystem__c = 'Fulfilment';
        event1.sequence__c = 1;
        event1.msCorrelationId__c = '5463873930';
        event1.eventTimeStamp__c = '2020-02-20T20:39:54+11:00';
        event1.externalOrderId__c = ord.csord__Order_Number__c;
        eventList.add(event1);    
    
    OrderNotification__e event2 = new OrderNotification__e();
        event2.errorDetails__c = null;
    event2.notificationAttributes__c = '"attributes":[{"name":"ServiceActivationDate","value":"2020-04-29T13:12:54+10:00"}, {"name":"currentForecastedDeliveryDate","value":"2020-05-18T20:06:39+10:00"}, {"name":"subStage","value":"Product Activation and Testing"}]';
        event2.orderItemDetails__c = '"product":{"productId": "2d478d6c-6669-f219-b1ae-759128726d32","status": "In Progress","attributes": []}';
        event2.eventType__c = 'subStageNotification';
        event2.orderItemId__c = ord.csord__Order_Number__c +'|'+serv.csordtelcoa__Service_Number__c+'|'+'2d478d6c-6669-f219-b1ae-759128726d32';
        event2.sourceSystem__c = 'Fulfilment';
        event2.sequence__c = 2;
        event2.msCorrelationId__c = '5463873931';
        event2.eventTimeStamp__c = '2020-02-20T20:39:54+11:00';
        event2.externalOrderId__c = ord.csord__Order_Number__c;
        eventList.add(event2);  
    
        OrderNotification__e event3 = new OrderNotification__e();
        event3.errorDetails__c = null;
    event3.notificationAttributes__c = '"attributes":[{"name":"CustomerOrderAcceptanceDate","value":"2020-04-29T13:12:54+10:00"}, {"name":"currentForecastedDeliveryDate","value":"2020-05-18T20:06:39+10:00"}, {"name":"subStage","value":"Customer Order Acceptance"}]';
        event3.orderItemDetails__c = '"product":{"productId": "2d478d6c-6669-f219-b1ae-759128726d32","status": "In Progress","attributes": []}';
        event3.eventType__c = 'subStageNotification';
        event3.orderItemId__c = ord.csord__Order_Number__c +'|'+serv.csordtelcoa__Service_Number__c+'|'+'2d478d6c-6669-f219-b1ae-759128726d32';
        event3.sourceSystem__c = 'Fulfilment';
        event3.sequence__c = 3;
        event3.msCorrelationId__c = '5463873932';
        event3.eventTimeStamp__c = '2020-02-20T20:39:54+11:00';
        event3.externalOrderId__c = ord.csord__Order_Number__c;
        eventList.add(event3);  
        
        Test.startTest();
        Database.SaveResult[] result = EventBus.publish(eventList);
        Test.StopTest();
        Map<Id,Attachment> servAttachmentRecordMap = new Map <Id,Attachment>(); 
        for(Attachment att: [Select id,body,parentId from Attachment where parentId =:serv.id ]){
            servAttachmentRecordMap.put(att.parentId,att);
            }
        
           List<CS_SpecificationDTO.ServiceSpecification> srvspecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(servAttachmentRecordMap.get(serv.id)),'FULFILMENT');
                    
                 for(CS_SpecificationDTO.ServiceSpecification spec:srvspecList){
                    for(CS_SpecificationDTO.SimpleAttributes attr: spec.additionalAttributes){
                    if(attr.name == 'DeviceIDType'){
                       System.assertEquals('MAC Address', attr.value); 
                    }
                    if(attr.name == 'DeviceID'){
                       System.assertEquals('2CE4F1BEFD31', attr.value); 
                    }
                }
                    
      }
    
  }
  
   @isTest 
    static void testDeviceIDdifOrderItem(){ //added as part of EDGE-158047
     csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder'];
     csord__Service__c serv = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name,csord__Identification__c,csord__Service__c from csord__Service__c where Name = 'mobDevice' and csord__Identification__c='mobDevice'];
   csord__Service__c serv1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name,csord__Identification__c,csord__Service__c from csord__Service__c where Name = 'mobDevice2' and csord__Identification__c='mobDevice2'];
    
    List<OrderNotification__e> eventList = new List<OrderNotification__e>();
        OrderNotification__e event1 = new OrderNotification__e();
        event1.errorDetails__c = null;
    event1.notificationAttributes__c ='"attributes":[{"name":"currentForecastedDeliveryDate","value":"2020-06-04T20:42:11+10:00"},{"name":"subStage","value":"Delivery Tracking"}]';
        event1.orderItemDetails__c = '"product":{"productId": "2d478d6c-6669-f219-b1ae-759128726d32","status": "In Progress","attributes": [{"name":"DeviceIDType","value":"MAC Address"},{"name":"DeviceID","value":"2CE4F1BEFD31"}]}';
        event1.eventType__c = 'subStageNotification';
        event1.orderItemId__c = ord.csord__Order_Number__c +'|'+serv.csordtelcoa__Service_Number__c+'|'+'2d478d6c-6669-f219-b1ae-759128726d32';
        event1.sourceSystem__c = 'Fulfilment';
        event1.sequence__c = 1;
        event1.msCorrelationId__c = '5463873930';
        event1.eventTimeStamp__c = '2020-02-20T20:39:54+11:00';
        event1.externalOrderId__c = ord.csord__Order_Number__c;
        eventList.add(event1);  
    
      OrderNotification__e event2 = new OrderNotification__e();
        event2.errorDetails__c = null;
    event2.notificationAttributes__c ='"attributes":[{"name":"ConsignmentNumber","value":"I3AZ10755430"}, {"name":"TrackingURL","value":"https://msto.startrack.com.au/track-trace/?id=I3AZ10755430"}, {"name":"currentForecastedDeliveryDate","value":"2020-05-07T05:21:33+10:00"}, {"name":"subStage","value":"Delivery Tracking"}]';
        event2.orderItemDetails__c = '"product":{"productId": "2d478d6c-6669-f219-b1ae-759128725h85","status": "In Progress","attributes": [{"name":"DeviceIDType","value":"IMEI"},{"name":"DeviceID","value":"2CE4F1BEFD33"}]}';
        event2.eventType__c = 'subStageNotification';
        event2.orderItemId__c = ord.csord__Order_Number__c +'|'+serv1.csordtelcoa__Service_Number__c+'|'+'2d478d6c-6669-f219-b1ae-759128725h85';
        event2.sourceSystem__c = 'Fulfilment';
        event2.sequence__c = 1;
        event2.msCorrelationId__c = '5463873931';
        event2.eventTimeStamp__c = '2020-02-20T20:39:54+11:00';
        event2.externalOrderId__c = ord.csord__Order_Number__c;
        eventList.add(event2);  
       
      Test.startTest();
        Database.SaveResult[] result = EventBus.publish(eventList);
        Test.StopTest();
    
     for(Asset aset : [select id,name,AssetID__c,AssetIDType__c from Asset where Name='IAD Device2' or Name='IAD Device'])
         {
       if(aset.Name=='IAD Device2'){
           if(aset.AssetID__c!=null){
               system.assertEquals('2CE4F1BEFD33',aset.AssetID__c);
           }
           if(aset.AssetIDType__c!=null){
                system.assertEquals('IMEI',aset.AssetIDType__c);
           }
         
                
       }
         
        if(aset.Name=='IAD Device'){
            if(aset.AssetID__c!=null){
                system.assertEquals('2CE4F1BEFD31',aset.AssetID__c);
            }
            if(aset.AssetIDType__c!=null){
                system.assertEquals('MAC Address',aset.AssetIDType__c);
            }
                 
       }
     }
     
    }
    
    // EDGE-160369  : Network ServiceID fix 
    @isTest
    static void processSubStageNotificationTestNtwkId(){
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        acc.Customer_Status__c='Active';
        insert acc;
        
        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        opp.StageName = 'Define';
        opp.CloseDate = System.Date.today();
        insert opp;
        
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;  
        
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder12345', acc.id, 'Created', ordReq.id);
        ord.csordtelcoa__Opportunity__c = opp.Id;
        insert ord;
        
        list<csord__Subscription__c> subsList=new list<csord__Subscription__c>();
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Order__c = ord.Id;
        subs.csord__Status__c='Pending';
        subs.csordtelcoa__Subscription_Number__c ='SN-12345';
        subsList.add(subs);
        
        insert subsList;
        List<csord__Service__c> servsList = new List<csord__Service__c>();
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify5';
        serv.csordtelcoa__Service_Number__c = 'SVC-000164098';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Status__c = 'in progress';
        serv.csord__Order_Request__c = ordReq.Id;
        serv.csord__Order__c =  ord.Id;
        serv.NetworkServiceId__c = 'intialNwId-12345';
        insert serv;
        List<Attachment> attsList = new List<Attachment>();
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","productConfigurationId":"a3T2O000000N9AFUA0","name":"263_NRC_601","instanceId":"","guid":"a9e4497b-2754-7221-e6ca-6751671ef2a8","endDate":"","description":"Mobile Access_Billing_NonRecurringCharge_000601","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","attributes":{"__targetSystem":"BILLING","rateExcludeGST":"0.00","billDescription":"IR Pay as you go charge","unitofMeasure":"each","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","type":"OC","currency":"AUD","ocsProdID":"T22E_IR_USAGE","billingSubtype":"IR","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000263_DMCAT_NonRecurringCharge_000601_108"},"metadata":{},"includeBilling":false,"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151_2","productConfigurationId":"a3T2O000000N9AFUA0","name":"151_ASR","instanceId":"","guid":"4f374952-2bf4-8fa5-85a7-e8a30727635c","endDate":"","description":"Incident Management_Assurance","code":"DMCAT_ProductSpecification_000151_Assurance","attributes":{"__targetSystem":"ASSURANCE","parentSpec":"DMCAT_ProductSpecification_000326_Assurance","ResponseTarget":"SLA0010001","RestoreTarget":"SLA0010006"},"metadata":{},"includeBilling":false,"additionalAttributes":{"parentSpec":"908fe418-a109-e766-2517-363f5f32cd05"}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000420DMCAT_ProductSpecification_000326","productConfigurationId":"a3T2O000000N9AFUA0","name":"326_ASR","instanceId":"","guid":"908fe418-a109-e766-2517-363f5f32cd05","endDate":"","description":"Telstra Managed Service Option 1_Assurance","code":"DMCAT_ProductSpecification_000326_Assurance","attributes":{"__targetSystem":"ASSURANCE","ServiceManagementOption":"1"},"metadata":{},"includeBilling":false,"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000606_5","productConfigurationId":"a3T2O000000N9AFUA0","name":"263_AW_606","instanceId":"","guid":"068b988d-18d3-78e8-407a-13d896f581b5","endDate":"","description":"Mobility_Billing_DMCAT_Allowance_000606","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000606","attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_IRDAYPASS","type":"International Roaming Data","unitofMeasure":"MB","value":"200","billingSubtype":"IR","billDescription":"IR Day Pass"},"metadata":{},"includeBilling":false,"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000607_6","productConfigurationId":"a3T2O000000N9AFUA0","name":"263_AW_607","metadata":{},"instanceId":"","includeBilling":false,"guid":"805764a7-d9e5-01a8-65b0-52b23c81d1a8","endDate":"","description":"Mobility_Billing_DMCAT_Allowance_000607","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000607","attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_IR_AUTOTOPUP","type":"International Roaming Data","unitofMeasure":"MB","value":"500","billingSubtype":"IR","billDescription":"IR Data Topup"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","productConfigurationId":"a3T2O000000N9AFUA0","name":"420_RC_654","metadata":{},"instanceId":"","includeBilling":false,"guid":"50f59975-ac13-db8c-163c-477df5092dcc","endDate":"","description":"Mobility_Billing_RecurringCharge_000654","code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","attributes":{"billDescription":"Corporate mobile plus - global data sim plan","prorate":"false","billInAdvance":"true","billingSpecId":"BSRC001_CB","frequency":"Monthly","currency":"AUD","type":"Data","description":"MRO Bonus Plan Discount","applicationDuration":24,"rateExcludeGST":"145.50","recurringChargePeriod":"Months","quantity":"1","__targetSystem":"BILLING","alteredPrice":145.5,"externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_4910"},"additionalAttributes":{}},{"additionalAttributes":{},"attributes":{"__targetSystem":"ASSURANCE"},"code":"DMCAT_ProductSpecification_000421_Assurance","description":"Mobile Device Management_Assurance","endDate":"","guid":"9292a251-590b-bd78-ac23-47da3755d4ff","includeBilling":false,"instanceId":"","metadata":{},"name":"421_ASR","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000421","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"SERVICEPROFILE":"TABLET","IMSI":"","CustomerFacingServiceId":"61473603212","MESSAGEBANK":"NA","SKU":"100119211","parentSpec":"7200c94d-ad78-0078-c8d3-b5c586d50313","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","__targetSystem":"FULFILMENT"},"attributes":{"__targetSystem":"FULFILMENT","IPWirelessProductInstanceID":"NA","BillofMaterialID":"NA","AccessRole":"Primary","CONTEXT":"CUSTOMER","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","SKU":"100119211","SuspensionContext":"NA","CustomerFacingServiceId":"","ShippingRequired":"TRUE","IMSI":"","SERVICEPROFILE":"TABLET"},"code":"DMCAT_ProductSpecification_000263_Fulfilment","description":"Mobile Access_Fulfilment","endDate":"","guid":"fc8e7088-a0ba-6b6c-ef69-3e6b3d281a89","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"__targetSystem":"FULFILMENT","IPWirelessProductInstanceID":"NA","BillofMaterialID":"NA","AccessRole":"Primary","CONTEXT":"CUSTOMER","SKU":"100119211","MESSAGEBANK":"NA","CustomerFacingServiceId":"61473603212","IMSI":"","SERVICEPROFILE":"TABLET"},"attributes":{"__targetSystem":"FULFILMENT"},"code":"DMCAT_ProductSpecification_000420_Fulfilment","description":"Mobility_Fulfilment","endDate":"","guid":"7200c94d-ad78-0078-c8d3-b5c586d50313","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobility_Fulfilment","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000420","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","value":"250","unitofMeasure":"GB","type":"FairPlay Data","ocsProdID":"T22EM_MBB-L","billingSpecId":"BSUSG001_CB","billDescription":"Includes 250 GB Domestic Data"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000637","description":"Mobility_Billing_DMCAT_Allowance_000637","endDate":"","guid":"ebba38ae-33c5-6b11-f8ce-50f6b74520fe","includeBilling":false,"instanceId":"","metadata":{},"name":"420_AW_637","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000637_7","startDate":"","status":"Created","version":"1"}],"serviceId":"'+serv.Id+'","legacyAttributes":[]}');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        attsList.add(att1);
    
        insert attsList;
            
        csord__Service__c svc5 = [SELECT Id, csord__Status__c,NetworkServiceId__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' AND csord__Order__r.Name= 'TestOrder12345'];
                 csord__Order__c ord4 = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder12345' ];
        
        
        List<OrderNotification__e> eventList = new List<OrderNotification__e>();
        
           OrderNotification__e event4 = new OrderNotification__e();
        
        event4.errorDetails__c = null;
        event4.notificationAttributes__c = '"attributes":[{"name":"currentForecastedDeliveryDate","value":"2020-07-14T05:34:56+10:00"}, {"name":"subStage","value":"Product Requirements Validation"}]';
        event4.orderItemDetails__c = '"product": { "productId": "7200c94d-ad78-0078-c8d3-b5c586d50313", "status": "In Progress", "attributes": [ { "name": "NetworkServiceId", "value": "6428957a-bdbd-4ece-932e-fb8a85712cf9" } ], "childProduct": [ { "productId": "fc8e7088-a0ba-6b6c-ef69-3e6b3d281a89", "status": "In Progress", "attributes": [] } ] }';
        
        event4.eventType__c = 'subStageNotification';
        event4.orderItemId__c = ord4.csord__Order_Number__c +'|'+svc5.csordtelcoa__Service_Number__c+'|'+'7200c94d-ad78-0078-c8d3-b5c586d50313';
        event4.sourceSystem__c = 'Fulfilment';
        event4.sequence__c = 4;
        event4.msCorrelationId__c = '5463873931';
        event4.eventTimeStamp__c = '2020-02-20T20:39:54+11:00';
        event4.externalOrderId__c = ord4.csord__Order_Number__c;
        eventList.add(event4);    
        Database.SaveResult[] result2 = EventBus.publish(eventList);
        csord__Service__c svc1 = [SELECT Id, csord__Status__c,NetworkServiceId__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' AND csord__Order__r.Name= 'TestOrder12345'];
        //System.assertEquals(svc1.NetworkServiceId__c, '6428957a-bdbd-4ece-932e-fb8a85712cf9'); //Check for N/wSvcId updated for 1st time
        System.assertNotEquals(svc1.NetworkServiceId__c, null);
    }
     @isTest 
    static void testDeviceIDNewOverwrite(){ //added as part of EDGE-164886 
     csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder'];
     csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name,csord__Identification__c,csord__Service__c from csord__Service__c where Name = 'servDev' and csord__Identification__c='servDev'];
     Test.startTest();
     List<NotificationParameters> notifParamList=new List<NotificationParameters>();
     NotificationParameters notif=new NotificationParameters();
      notif.errorDetails='';
      notif.notificationAttributes='"attributes":[{"name":"currentForecastedDeliveryDate","value":"2020-05-07T05:21:33+10:00"}, {"name":"subStage","value":"Product Activation and Testing"}]';
      notif.orderItemDetails='"product":{"productId": "ac3a05d6-7059-502d-8b02-cc3c1c906c03","status": "In Progress","attributes": [],"childProduct": [{"productId": "192a11f8-9563-5e1f-66e6-4943b26737cf","status": "In Progress","attributes": []},{"productId": "173f6a4f-b2a9-92b2-b6f6-79c64bc00975","status": "In Progress","attributes": [{"name":"IMSI","value":"405013487490537"},{"name":"SIMSerialNumber","value":"7334115827570"}]}]}';
      notif.eventType='subStageNotification';
      notif.eventTimestamp='2018-12-03T20:39:54+11:00';
      notif.sourceSystem='Fulfilment';
      notif.externalOrderId=ord.csord__Order_Number__c;
      notif.orderItemId=ord.csord__Order_Number__c+'|'+svc.csordtelcoa__Service_Number__c+'|ac3a05d6-7059-502d-8b02-cc3c1c906c03';
      notif.orderItemVersion=1;
      notifParamList.add(notif);
    Map<String, List<NotificationParameters >> orderItemIdNotifMap = new Map< String, List<NotificationParameters >> ();
    ManageOrderNotificationServiceMSUpdate.processNotification(orderItemIdNotifMap,notifParamList);
         Map<Id,Attachment> servAttachmentRecordMap = new Map <Id,Attachment>(); 
        for(Attachment att: [Select id,body,parentId from Attachment where parentId =:svc.id ]){
            servAttachmentRecordMap.put(att.parentId,att);
            }
        
           List<CS_SpecificationDTO.ServiceSpecification> srvspecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(servAttachmentRecordMap.get(svc.id)),'FULFILMENT');
                    
                 for(CS_SpecificationDTO.ServiceSpecification spec:srvspecList){
                    for(CS_SpecificationDTO.SimpleAttributes attr: spec.additionalAttributes){
                    if(attr.name == 'DeviceIDType'){
                       System.assertEquals('MAC', attr.value); 
                    }
                    if(attr.name == 'DeviceID'){
                       System.assertEquals('4045322878914276', attr.value); 
                    }
                }
                    
      }
        Asset aset=[select id,name,AssetID__c,AssetIDType__c from Asset where Name='IAD Device3'];
        system.assertEquals('4045322878914276',aset.AssetID__c);
        system.assertEquals('MAC',aset.AssetIDType__c);
    Test.stopTest();
  
    }  
    
    //Added as part of EDGE-187675
    @isTest 
    static void testReadyForActivationNot(){ 
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder'];
        csord__Service__c svc = [SELECT Id,csord__Subscription__c , csord__Status__c, csordtelcoa__Service_Number__c, Name,csord__Identification__c,csord__Service__c from csord__Service__c where Name = 'servDev' and csord__Identification__c='servDev'];
        Test.startTest();
        List<NotificationParameters> notifParamList=new List<NotificationParameters>();
        NotificationParameters notif=new NotificationParameters();
        notif.errorDetails='';
        notif.notificationAttributes='"attributes":[{"name":"ReadyForActivationDate","value":"2020-07-14T12:49:37+10:00"}, {"name":"subStage","value":"Ready for Activation"}]';
        notif.orderItemDetails='"product":{"productId": "ac3a05d6-7059-502d-8b02-cc3c1c906c03","status": "In Progress","attributes": [],"childProduct": [{"productId": "192a11f8-9563-5e1f-66e6-4943b26737cf","status": "In Progress","attributes": []},{"productId": "173f6a4f-b2a9-92b2-b6f6-79c64bc00975","status": "In Progress","attributes": [{"name":"IMSI","value":"405013487490537"},{"name":"SIMSerialNumber","value":"7334115827570"}]}]}';
        notif.eventType='subStageNotification';
        notif.eventTimestamp='2018-12-03T20:39:54+11:00';
        notif.sourceSystem='Fulfilment';
        notif.externalOrderId=ord.csord__Order_Number__c;
        notif.orderItemId=ord.csord__Order_Number__c+'|'+svc.csordtelcoa__Service_Number__c+'|ac3a05d6-7059-502d-8b02-cc3c1c906c03';
        notif.orderItemVersion=1;
        notifParamList.add(notif);
        Map<String, List<NotificationParameters >> orderItemIdNotifMap = new Map< String, List<NotificationParameters >> ();
        ManageOrderNotificationServiceMSUpdate.processNotification(orderItemIdNotifMap,notifParamList);
        Map<Id,Attachment> servAttachmentRecordMap = new Map <Id,Attachment>(); 
        for(Attachment att: [Select id,body,parentId from Attachment where parentId =:svc.id ]){
            servAttachmentRecordMap.put(att.parentId,att);
        }
        
        List<CS_SpecificationDTO.ServiceSpecification> srvspecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(servAttachmentRecordMap.get(svc.id)),'FULFILMENT');
        
        for(CS_SpecificationDTO.ServiceSpecification spec:srvspecList){
            for(CS_SpecificationDTO.SimpleAttributes attr: spec.additionalAttributes){
                if(attr.name == 'SIMSerialNumber'){
                    System.assertEquals('7334115827570', attr.value); 
                }
                if(attr.name == 'IMSI'){
                    System.assertEquals('405013487490537', attr.value); 
                }
            }
            
        }
        csord__Subscription__c  subs=[select id,Ready_for_Activation_Date__c  from csord__Subscription__c  where Id=:svc.csord__Subscription__c ];
        System.debug('subs Ready_for_Activation_Date__c ...'+subs.Ready_for_Activation_Date__c );
        if(subs.Ready_for_Activation_Date__c!=null){
            system.assertEquals(DateTime.newInstanceGMT(2020, 07, 14,02,49,37),subs.Ready_for_Activation_Date__c);
        }
        
        Test.stopTest();
    }
    
    @isTest 
    static void testEquipmentDeliveryFailed(){ //added as part of EDGE-170550
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder'];
        csord__Service__c svc = [SELECT Id,csord__Subscription__c , csord__Status__c, csordtelcoa__Service_Number__c, Name,csord__Identification__c,csord__Service__c from csord__Service__c where Name = 'servDev' and csord__Identification__c='servDev'];
        Test.startTest();
        List<NotificationParameters> notifParamList=new List<NotificationParameters>();
        NotificationParameters notif=new NotificationParameters();
        notif.errorDetails='';
        notif.notificationAttributes='"attributes": [{"name": "subStage","value": "Equipment Delivery Failed"},{"name":"currentForecastedDeliveryDate","value": "2018-05-13T16:48:39-11:00"},{"name": "EquipmentDeliveryFailedDate","value": "2018-05-13T16:48:39-11:00"},{"name": "LogisticOrderNumber","value": ""},{"name": "ConsignmentNumber","value": ""},{"name": "TrackingURL","value": ""}]';
        notif.orderItemDetails='"product":{"productId": "ac3a05d6-7059-502d-8b02-cc3c1c906c03","status": "In Progress","attributes": [],"childProduct": [{"productId": "192a11f8-9563-5e1f-66e6-4943b26737cf","status": "In Progress","attributes": []},{"productId": "173f6a4f-b2a9-92b2-b6f6-79c64bc00975","status": "In Progress","attributes": [{"name": "DeviceID","value": ""},{"name": "DeviceIDType","value": ""}]}]}';
        notif.eventType='subStageNotification';
        notif.eventTimestamp='2018-12-03T20:39:54+11:00';
        notif.sourceSystem='Fulfilment';
        notif.externalOrderId=ord.csord__Order_Number__c;
        notif.orderItemId=ord.csord__Order_Number__c+'|'+svc.csordtelcoa__Service_Number__c+'|ac3a05d6-7059-502d-8b02-cc3c1c906c03';
        notif.orderItemVersion=1;
        notifParamList.add(notif);
        Map<String, List<NotificationParameters >> orderItemIdNotifMap = new Map< String, List<NotificationParameters >> ();
        ManageOrderNotificationServiceMSUpdate.processNotification(orderItemIdNotifMap,notifParamList);
        Map<Id,Attachment> servAttachmentRecordMap = new Map <Id,Attachment>(); 
        for(Attachment att: [Select id,body,parentId from Attachment where parentId =:svc.id ]){
            servAttachmentRecordMap.put(att.parentId,att);
        }
        
        List<CS_SpecificationDTO.ServiceSpecification> srvspecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(servAttachmentRecordMap.get(svc.id)),'FULFILMENT');
        
        for(CS_SpecificationDTO.ServiceSpecification spec:srvspecList){
            for(CS_SpecificationDTO.SimpleAttributes attr: spec.additionalAttributes){
                 if(attr.name == 'EquipmentDeliveryFailedDate'){
                    System.assertEquals('2018-05-13T16:48:39-11:00', attr.value); 
                }
                if(attr.name == 'DeviceID'){
                    System.assertEquals('', attr.value); 
                }
                if(attr.name == 'DeviceIDType'){
                    System.assertEquals('', attr.value); 
                }
            }
            
        }
      
        Test.stopTest();
    }  
  
  @isTest 
    static void testEstimatedPONRdate(){ //added as part of EDGE-170550
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder'];
        csord__Service__c svc = [SELECT Id,csord__Subscription__c ,Estimated_PoNR_Date__c, csord__Status__c, csordtelcoa__Service_Number__c, Name,csord__Identification__c,csord__Service__c from csord__Service__c where Name = 'servDev' and csord__Identification__c='servDev'];
        List<NotificationParameters> notifParamList=new List<NotificationParameters>();
        NotificationParameters notif=new NotificationParameters();
        notif.errorDetails='';
        notif.notificationAttributes='"attributes":[{"name": "subStage","value": "Picking & Packing"},{"name":"currentForecastedDeliveryDate","value":"2018-05-13T16:48:39-11:00"},{"name": "EstimatedDeliveryDate","value":"2018-05-13T16:48:39-11:00"},{"name":"EstimatedPoNRDate","value": "2021-03-19T18:30:00+00:00"}]';
        notif.orderItemDetails='"product":{"productId": "ac3a05d6-7059-502d-8b02-cc3c1c906c03","status": "In Progress","attributes": [],"childProduct": [{"productId": "192a11f8-9563-5e1f-66e6-4943b26737cf","status": "In Progress","attributes": []}]}';
        notif.eventType='subStageNotification';
        notif.eventTimestamp='2018-12-03T20:39:54+11:00';
        notif.sourceSystem='Fulfilment';
        notif.externalOrderId=ord.csord__Order_Number__c;
        notif.orderItemId=ord.csord__Order_Number__c+'|'+svc.csordtelcoa__Service_Number__c+'|ac3a05d6-7059-502d-8b02-cc3c1c906c03';
        notif.orderItemVersion=1;
        notifParamList.add(notif);
        Test.startTest();
        Map<String, List<NotificationParameters >> orderItemIdNotifMap = new Map< String, List<NotificationParameters >> ();
        ManageOrderNotificationServiceMSUpdate.processNotification(orderItemIdNotifMap,notifParamList);
        Map<Id,Attachment> servAttachmentRecordMap = new Map <Id,Attachment>(); 
        for(Attachment att: [Select id,body,parentId from Attachment where parentId =:svc.id ]){
            servAttachmentRecordMap.put(att.parentId,att);
        }
        
        List<CS_SpecificationDTO.ServiceSpecification> srvspecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(servAttachmentRecordMap.get(svc.id)),'FULFILMENT');
        
        for(CS_SpecificationDTO.ServiceSpecification spec:srvspecList){
            for(CS_SpecificationDTO.SimpleAttributes attr: spec.additionalAttributes){
                 if(attr.name == 'EstimatedPoNRDate'){
                    System.assertEquals('2021-03-19T18:30:00+00:00', attr.value); 
                }
               
            }
            
        }
       Test.stopTest();
    }  
    
     @isTest 
    static void testRFA(){ 
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder'];
        csord__Service__c svc = [SELECT Id,csord__Subscription__c , csord__Status__c, csordtelcoa__Service_Number__c, Name,csord__Identification__c,csord__Service__c from csord__Service__c where Name = 'servDev' and csord__Identification__c='servDev'];
        Test.startTest();
        List<NotificationParameters> notifParamList=new List<NotificationParameters>();
        NotificationParameters notif=new NotificationParameters();
        notif.errorDetails='';
        notif.notificationAttributes='"attributes":[{"name":"ReadyForActivationDate","value":"2020-07-14T12:49:37+10:00"}, {"name":"subStage","value":"Ready for Activation"}]';
        notif.orderItemDetails='"product":{"productId": "ac3a05d6-7059-502d-8b02-cc3c1c906c03","status": "In Progress","attributes": [],"childProduct": [{"productId": "192a11f8-9563-5e1f-66e6-4943b26737cf","status": "In Progress","attributes": []},{"productId": "173f6a4f-b2a9-92b2-b6f6-79c64bc00975","status": "In Progress","attributes": [{"name":"IMSI","value":"405013487490537"},{"name":"SIMSerialNumber","value":"7334115827570"}]}]}';
        notif.eventType='subStageNotification';
        notif.eventTimestamp='2018-12-03T20:39:54+11:00';
        notif.sourceSystem='Fulfilment';
        notif.externalOrderId=ord.csord__Order_Number__c;
        notif.orderItemId=ord.csord__Order_Number__c+'|'+svc.csordtelcoa__Service_Number__c+'|ac3a05d6-7059-502d-8b02-cc3c1c906c03';
        notif.orderItemVersion=1;
        notifParamList.add(notif);
        Map<String, List<NotificationParameters >> orderItemIdNotifMap = new Map< String, List<NotificationParameters >> ();
        ManageOrderNotificationServiceMSUpdate.processNotification(orderItemIdNotifMap,notifParamList);
        Map<Id,Attachment> servAttachmentRecordMap = new Map <Id,Attachment>(); 
        for(Attachment att: [Select id,body,parentId from Attachment where parentId =:svc.id ]){
            servAttachmentRecordMap.put(att.parentId,att);
        }
        
        List<CS_SpecificationDTO.ServiceSpecification> srvspecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(servAttachmentRecordMap.get(svc.id)),'FULFILMENT');
        
        for(CS_SpecificationDTO.ServiceSpecification spec:srvspecList){
            for(CS_SpecificationDTO.SimpleAttributes attr: spec.additionalAttributes){
                if(attr.name == 'SIMSerialNumber'){
                    System.assertEquals('7334115827570', attr.value); 
                }
                if(attr.name == 'IMSI'){
                    System.assertEquals('405013487490537', attr.value); 
                }
            }
            
        }
        csord__Subscription__c  subs=[select id,name,csord__Identification__c,Ready_for_Activation_Date__c,csord__Status__c  from csord__Subscription__c  where name='subDevice3' and csord__Identification__c='subDevice3' ];
        System.debug('subs Ready_for_Activation_Date__c ...'+subs.Ready_for_Activation_Date__c );
        if(subs.csord__Status__c!=null){
            system.assertEquals('Ready For Activation', subs.csord__Status__c);
        }
        
        if(subs.Ready_for_Activation_Date__c!=null){
            system.assertEquals(DateTime.newInstanceGMT(2020, 07, 14,02,49,37),subs.Ready_for_Activation_Date__c);
        }
        Test.stopTest();
        
    }
  
  
    @isTest 
    static void testCFSId(){ //added as part of EDGE-204029
        Final String CFSID ='CustomerFacingServiceId';
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder'];
        csord__Service__c svc = [SELECT Id,csord__Subscription__c ,Estimated_PoNR_Date__c, csord__Status__c, csordtelcoa__Service_Number__c, Name,csord__Identification__c,csord__Service__c from csord__Service__c where Name = 'servDev' and csord__Identification__c='servDev'];
        
        Test.startTest();
        List<NotificationParameters> notifParamList=new List<NotificationParameters>();
        NotificationParameters notif=new NotificationParameters();
        notif.errorDetails='';
        notif.notificationAttributes='"attributes":[{"name": "subStage","value": "Product Requirements Validation"},{"name":"currentForecastedDeliveryDate","value":"2018-05-13T16:48:39-11:00"}]';
        notif.orderItemDetails='"product":{"productId": "ac3a05d6-7059-502d-8b02-cc3c1c906c03","status": "In Progress","attributes": [{"name":"CustomerFacingServiceId","value":"61429757046"}]}';
        notif.eventType='subStageNotification';
        notif.eventTimestamp='2018-12-03T20:39:54+11:00';
        notif.sourceSystem='Fulfilment';
        notif.externalOrderId=ord.csord__Order_Number__c;
        notif.orderItemId=ord.csord__Order_Number__c+'|'+svc.csordtelcoa__Service_Number__c+'|ac3a05d6-7059-502d-8b02-cc3c1c906c03';
        notif.orderItemVersion=1;
        notifParamList.add(notif);
        Map<String, List<NotificationParameters >> orderItemIdNotifMap = new Map< String, List<NotificationParameters >> ();
        ManageOrderNotificationServiceMSUpdate.processNotification(orderItemIdNotifMap,notifParamList);
        Map<Id,Attachment> servAttachmentRecordMap = new Map <Id,Attachment>(); 
        for(Attachment att: [Select id,body,parentId from Attachment where parentId =:svc.id ]){
            servAttachmentRecordMap.put(att.parentId,att);
        }
        
        List<CS_SpecificationDTO.ServiceSpecification> srvspecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(servAttachmentRecordMap.get(svc.id)),'FULFILMENT');
        
        for(CS_SpecificationDTO.ServiceSpecification spec:srvspecList){
            for(CS_SpecificationDTO.SimpleAttributes attr: spec.additionalAttributes){
                 if(attr.name == CFSID){
                     
                    System.assertEquals('61429757046', attr.value); 
                }
               
            }
            
        }
        Test.stopTest();
       
    } 
         @isTest 
    static void testRFANew(){ //added as part of INC000095547173 
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder3'];
        csord__Service__c svc = [SELECT Id,csord__Subscription__c , csord__Status__c, csordtelcoa__Service_Number__c, Name,csord__Identification__c,csord__Service__c,csord__Subscription__r.Trigger_RFA__c from csord__Service__c where Name = 'servRFA1' and csord__Identification__c='servRFA1'];
        List<NotificationParameters> notifParamList=new List<NotificationParameters>();
        NotificationParameters notif=new NotificationParameters();
        notif.errorDetails='';
        notif.notificationAttributes='"attributes":[{"name":"ReadyForActivationDate","value":"2020-07-14T12:49:37+10:00"}, {"name":"subStage","value":"Ready for Activation"}]';
        notif.orderItemDetails='"product":{"productId": "173f6a4f-b2a9-92b2-b6f6-79c64bc00975","status": "In Progress","attributes": []}';
        notif.eventType='subStageNotification';
        notif.eventTimestamp='2018-12-03T20:39:54+11:00';
        notif.sourceSystem='Fulfilment';
        notif.externalOrderId=ord.csord__Order_Number__c;
        notif.orderItemId=ord.csord__Order_Number__c+'|'+svc.csordtelcoa__Service_Number__c+'|173f6a4f-b2a9-92b2-b6f6-79c64bc00975';
        notif.orderItemVersion=1;
        notifParamList.add(notif);
        Map<String, List<NotificationParameters >> orderItemIdNotifMap = new Map< String, List<NotificationParameters >> ();
    Test.startTest();
        ManageOrderNotificationServiceMSUpdate.processNotification(orderItemIdNotifMap,notifParamList);
        Test.StopTest();
       
       
        //csord__Subscription__c  subs=[select id,name,csord__Identification__c,Ready_for_Activation_Date__c,csord__Status__c,Trigger_RFA__c  from csord__Subscription__c  where name='subRFA1' and csord__Identification__c='subRFA1' Limit 1];
        System.assertEquals(true,svc.csord__Subscription__r.Trigger_RFA__c);
        
       
        
        
    }
}