/*
* Updates -
* 1. Ritika Jaiswal :  EDGE - 66137 : ETC when Portout
* 2. Vaibhav        :  EDGE-128090  : Changes covered 
* 3. Sandip       :  EDGE-144389 - Changed billing subtype as per Sigma
* 4. Aruna Aware  :  DPG-1891 & DPG-1892 - Suspend IoT Services and Resume IoT Services
* 5. Vaibhav      :  EDGE-159332 - Portout order code overwrite fix
* 6. Gnana        :  EDGE-154370 - Added Test Medthods for incident-INC000092634429 fix
* 7. Gnana        :  EDGE-167554 - Added Test Method for API Issue
* 8. Gnana        :  EDGE-165552 - Added test method for adding ROETC BillingSubType condition
* 9. Gnana		  :  EDGE-185450 - Added Assert for changeType__c changes 
*/ 
@isTest
public class OrderGeneratorUtilTest {
    @TestSetup static void dataSetup()
    {
        list<CSPOFA__Orchestration_Process_Template__c> orcheList = new list<CSPOFA__Orchestration_Process_Template__c>();
        String ProcessingMode='Foreground';      
        CSPOFA__Orchestration_Process_Template__c orchProcessTemplate = new CSPOFA__Orchestration_Process_Template__c();
        orchProcessTemplate.Name = 'Order Fulfilment Process';
        orchProcessTemplate.CSPOFA__Process_Type__c = 'New Provide';
        orchProcessTemplate.CSPOFA__Processing_Mode__c = ProcessingMode;        
        insert orchProcessTemplate;
        
        Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        testAccount.Customer_Status__c = 'ACTIVE';
        insert testAccount;
        
        Billing_Account__c billingAccount = ProductTestFactory.getBillingAccount();
        billingAccount.Billing_Account_Number__c = '700000449806';
        insert billingAccount;
        
        Opportunity opp = ProductTestFactory.getOpportunityBasic(testAccount);
        opp.StageName = 'Define';
        opp.CloseDate = System.Date.today();
        //opp.Type = 'Disconnect';
        insert opp;
        
        
        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = testAccount.Id;
        testBasket.Name = 'ShowSubTestBasket';
        testBasket.cscfga__Opportunity__c = opp.Id;
        insert testBasket;
        
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>();
        cscfga__Product_Definition__c CW_PD = new cscfga__Product_Definition__c(Name = 'Connected Workplace', cscfga__Description__c = 'Connected Workplace');
        pdList.add(CW_PD);
        cscfga__Product_Definition__c ucePD = new cscfga__Product_Definition__c(Name = 'Unified Communication', cscfga__Description__c = 'Unified Communication');
        pdList.add(ucePD);
        cscfga__Product_Definition__c IPNet_PD = new cscfga__Product_Definition__c(Name = 'IP Network', cscfga__Description__c = 'IP Network');
        pdList.add(IPNet_PD);
        cscfga__Product_Definition__c Mob_PD = new cscfga__Product_Definition__c(Name = 'Mobility', cscfga__Description__c = 'Mobility');
        pdList.add(Mob_PD);
        cscfga__Product_Definition__c CMP_DevicePD = new cscfga__Product_Definition__c(Name = 'Device', cscfga__Description__c = 'Mobility',product_Specification__c='DMCAT_ProductSpecification_000423');
        pdList.add(CMP_DevicePD);
        // DPG-1891 & DPG-1892 Suspend IoT Services and Resume IoT Services - Created IOT Susbcription Product Definition record
        cscfga__Product_Definition__c IoT_PD = new cscfga__Product_Definition__c(Name = 'IOT Subscription', cscfga__Description__c = 'IOT Subscription',product_Specification__c='DMCAT_ProductSpecification_000965');
        pdList.add(IoT_PD);
        insert pdList;
        
        
        List<cscfga__Product_Configuration__c> prodconfigList=new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c testConfig = new cscfga__Product_Configuration__c();
        testConfig.Name = 'Connected Workplace';
        testConfig.cscfga__Product_Basket__c = testBasket.Id;
        testConfig.cscfga__Product_Definition__c=CW_PD.id;
        prodconfigList.add(testConfig);
        cscfga__Product_Configuration__c testConfig1 = new cscfga__Product_Configuration__c();
        testConfig1.Name = System.Label.IP_Network;
        testConfig1.cscfga__Product_Basket__c = testBasket.Id;
        testConfig1.cscfga__Product_Definition__c=ucePD.id;
        prodconfigList.add(testConfig1);
        cscfga__Product_Configuration__c testConfig2 = new cscfga__Product_Configuration__c();
        testConfig2.Name = System.Label.UC_Enterprise;
        testConfig2.cscfga__Product_Basket__c = testBasket.Id;
        testConfig2.cscfga__Product_Definition__c=IPNet_PD.id;
        prodconfigList.add(testConfig2); 
        cscfga__Product_Configuration__c testConfig3 = new cscfga__Product_Configuration__c();
        testConfig3.Name = System.Label.Mobility;
        testConfig3.cscfga__Product_Basket__c = testBasket.Id;
        testConfig3.cscfga__Product_Definition__c=Mob_PD.id;
        prodconfigList.add(testConfig3);       
        cscfga__Product_Configuration__c testConfigCMP = new cscfga__Product_Configuration__c();
        testConfigCMP.Name = 'CMP Device';
        testConfigCMP.cscfga__Product_Basket__c = testBasket.Id;
        testConfigCMP.cscfga__Product_Definition__c=CMP_DevicePD.id;
        testConfigCMP.csedm__CFS_Mapping_List__c = '';
        testConfigCMP.cscfga__Contract_Term__c = 24;
        prodconfigList.add(testConfigCMP);
        
        // DPG-1891 & DPG-1892 Suspend IoT Services and Resume IoT Services - added Product Configuration record
        cscfga__Product_Configuration__c testConfig4 = new cscfga__Product_Configuration__c();
        testConfig4.Name = 'IOT Susbcription';
        testConfig4.cscfga__Product_Basket__c = testBasket.Id;
        testConfig4.cscfga__Product_Definition__c=IoT_PD.id;
        prodconfigList.add(testConfig4); 
        insert prodconfigList;
        
        cscfga__Attribute_Definition__c InstalmentChargeAD = new cscfga__Attribute_Definition__c(name='InstalmentCharge',cscfga__Product_Definition__c=CMP_DevicePD.id);
        cscfga__Attribute_Definition__c OfferIdAD = new cscfga__Attribute_Definition__c(name='OfferId',cscfga__Product_Definition__c=CMP_DevicePD.id);
        cscfga__Attribute_Definition__c MobileDeviceETCAD = new cscfga__Attribute_Definition__c(name='MobileDeviceETC',cscfga__Product_Definition__c=CMP_DevicePD.id);        
        cscfga__Attribute_Definition__c EarlyTerminationChargeAD = new cscfga__Attribute_Definition__c(name='EarlyTerminationCharge',cscfga__Product_Definition__c=CMP_DevicePD.id);
        cscfga__Attribute_Definition__c DisconnectionDateAD = new cscfga__Attribute_Definition__c(name='DisconnectionDate',cscfga__Product_Definition__c=CMP_DevicePD.id);
        cscfga__Attribute_Definition__c ColourStringAD = new cscfga__Attribute_Definition__c(name='ColourString',cscfga__store_as_json__c=true,cscfga__Product_Definition__c=CMP_DevicePD.id);
        cscfga__Attribute_Definition__c ModelStringAD = new cscfga__Attribute_Definition__c(name='ModelString',cscfga__store_as_json__c=true,cscfga__Product_Definition__c=CMP_DevicePD.id);
        cscfga__Attribute_Definition__c BillDescTextAD = new cscfga__Attribute_Definition__c(name='BillDescText',cscfga__store_as_json__c=true,cscfga__Product_Definition__c=CMP_DevicePD.id);
        cscfga__Attribute_Definition__c ChangeTypeAD = new cscfga__Attribute_Definition__c(name='ChangeType',cscfga__Product_Definition__c=CMP_DevicePD.id);
        List<cscfga__Attribute_Definition__c> attributedefinitions = new List<cscfga__Attribute_Definition__c>{InstalmentChargeAD,OfferIdAD,MobileDeviceETCAD,EarlyTerminationChargeAD,DisconnectionDateAD,ColourStringAD,ModelStringAD,BillDescTextAD,ChangeTypeAD};
            insert attributedefinitions;
        List<cscfga__Attribute__c> attributes = new List<cscfga__Attribute__c>();
        cscfga__Attribute__c testAttribute = new cscfga__Attribute__c();
        testAttribute.Name = 'testAttributeForTest';
        testAttribute.cscfga__Product_Configuration__c = testConfig.Id;
        attributes.add(testAttribute);       
        cscfga__Attribute__c InstalmentCharge = new cscfga__Attribute__c(cscfga__Value__c = '20.0',cscfga__Display_Value__c = '20.0');
        InstalmentCharge.Name = 'InstalmentCharge';
        InstalmentCharge.cscfga__Attribute_Definition__c = InstalmentChargeAD.id;
        InstalmentCharge.cscfga__Product_Configuration__c = testConfigCMP.Id;
        attributes.add(InstalmentCharge);
        cscfga__Attribute__c OfferId = new cscfga__Attribute__c(cscfga__Value__c = 'DMCAT_Offer_000646',cscfga__Display_Value__c = 'DMCAT_Offer_000646');
        OfferId.Name = 'OfferId';
        OfferId.cscfga__Product_Configuration__c = testConfigCMP.Id;
        OfferId.cscfga__Attribute_Definition__c = OfferIdAD.id;
        attributes.add(OfferId);
        cscfga__Attribute__c MobileDeviceETC = new cscfga__Attribute__c();
        MobileDeviceETC.Name = 'MobileDeviceETC';
        MobileDeviceETC.cscfga__Product_Configuration__c = testConfigCMP.Id;
        MobileDeviceETC.cscfga__Attribute_Definition__c = MobileDeviceETCAD.id;
        attributes.add(MobileDeviceETC);
        cscfga__Attribute__c EarlyTerminationCharge = new cscfga__Attribute__c();
        EarlyTerminationCharge.Name = 'EarlyTerminationCharge';
        EarlyTerminationCharge.cscfga__Product_Configuration__c = testConfigCMP.Id;
        EarlyTerminationCharge.cscfga__Attribute_Definition__c = EarlyTerminationChargeAD.id;
        attributes.add(EarlyTerminationCharge);
        cscfga__Attribute__c DisconnectionDate = new cscfga__Attribute__c();
        DisconnectionDate.Name = 'DisconnectionDate';
        DisconnectionDate.cscfga__Attribute_Definition__c = DisconnectionDateAD.id;
        DisconnectionDate.cscfga__Product_Configuration__c = testConfigCMP.Id;
        attributes.add(DisconnectionDate);
        //Changes Start for EDGE-148420
        cscfga__Attribute__c ColourString = new cscfga__Attribute__c();
        ColourString.Name = 'ColourString';
        ColourString.cscfga__Attribute_Definition__c = ColourStringAD.id;
        ColourString.cscfga__Product_Configuration__c = testConfigCMP.Id;
        attributes.add(ColourString);
        
        cscfga__Attribute__c ModelString = new cscfga__Attribute__c();
        ModelString.Name = 'ModelString';
        ModelString.cscfga__Attribute_Definition__c = ModelStringAD.id;
        ModelString.cscfga__Product_Configuration__c = testConfigCMP.Id;
        attributes.add(ModelString);
        
        cscfga__Attribute__c ChangeType = new cscfga__Attribute__c();
        ChangeType.Name = 'ChangeType';
        ChangeType.cscfga__Attribute_Definition__c = DisconnectionDateAD.id;
        ChangeType.cscfga__Product_Configuration__c = testConfigCMP.Id;
        attributes.add(ChangeType);
        
        cscfga__Attribute__c BillDescText = new cscfga__Attribute__c();
        BillDescText.Name = 'BillDescText';
        BillDescText.cscfga__Attribute_Definition__c = DisconnectionDateAD.id;
        BillDescText.cscfga__Product_Configuration__c = testConfigCMP.Id;
        attributes.add(BillDescText);
        //Changes End for EDGE-148420
        insert attributes;
        
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
        csord__Order__c order = ProductTestFactory.buildOrder('PrimaryOrder', testAccount.id, 'Created', ordReq.id);
        order.telstra_ord_Start_DateTime__c=System.now();//EDGE-182667
        order.csord__Order_Request__c = ordReq.Id;
        insert order;
        
        csord__Order__c testOrder = ProductTestFactory.buildOrder('TestOrder', testAccount.id, 'Created', ordReq.id);
        testOrder.telstra_ord_Start_DateTime__c=System.now();//EDGE-182667
        testOrder.csord__Order_Request__c = ordReq.Id;
        testOrder.csord__Primary_Order__c = order.Id;
        insert testOrder;
        
        csordtelcoa__Orders_Subscriptions_Options__c testOso = new csordtelcoa__Orders_Subscriptions_Options__c();
        testOso.csordtelcoa__Subscription_Closed_Replaced_State__c = 'test2';
        testOso.csordtelcoa__Statuses_Not_Allowing_Change__c = 'false';
        insert testOso;
        
        csord__Subscription__c testSubscription = new csord__Subscription__c();
        testSubscription.Name = 'TestSubsforTest';
        testSubscription.csord__Account__c = testAccount.Id;
        testSubscription.csord__Order__c = testOrder.Id;
        testSubscription.csord__Identification__c = 'test';
        testSubscription.serviceMSISDN__c='12346789';
        testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription.csord__Status__c = 'Active';
        
        csord__Subscription__c testSubscription2 = new csord__Subscription__c();
        testSubscription2.Name = 'TestSubsforTest2';
        testSubscription2.csord__Account__c = testAccount.Id;
        testSubscription2.csord__Order__c = testOrder.Id;
        testSubscription2.csord__Identification__c = 'test2';
        //testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription2.csord__Status__c = 'Pending';
        
        csord__Subscription__c testSubscription3 = new csord__Subscription__c();
        testSubscription3.Name = 'TestSubsforTest3';
        testSubscription3.csord__Account__c = testAccount.Id;
        testSubscription3.csord__Order__c = testOrder.Id;
        testSubscription3.csord__Identification__c = 'test3';
        //testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription3.csord__Status__c = null;
        
        csord__Subscription__c testSubscription4 = new csord__Subscription__c();
        testSubscription4.Name = 'TestSubsforTest4';
        testSubscription4.csord__Account__c = testAccount.Id;
        testSubscription4.csord__Order__c = testOrder.Id;
        testSubscription4.csord__Identification__c = 'test';
        testSubscription4.csordtelcoa__Product_Configuration__c = testConfig1.Id;
        
        testSubscription4.Suspension_reason__c='Requested By Customer';
        testSubscription4.csord__Status__c = 'Active';
        
        csord__Subscription__c testSubscription5 = new csord__Subscription__c();
        testSubscription5.Name = 'TestSubsforTest5';
        testSubscription5.csord__Account__c = testAccount.Id;
        testSubscription5.csord__Order__c = testOrder.Id;
        testSubscription5.csord__Identification__c = 'test';
        testSubscription5.csordtelcoa__Product_Configuration__c = testConfig3.Id;
        testSubscription5.csord__Status__c = 'Closed Replaced';
        
        csord__Subscription__c lockedSubscriptionPortout=new csord__Subscription__c(Name ='portoutSub');
        lockedSubscriptionPortout.csord__Order__c = testOrder.Id;
        lockedSubscriptionPortout.Billing_Account__c = billingAccount.id;
        lockedSubscriptionPortout.csord__Status__c=Label.Subscription_status_for_PortOut;
        lockedSubscriptionPortout.serviceMSISDN__c='1234556877';
        lockedSubscriptionPortout.csord__Identification__c='subscription';
        lockedSubscriptionPortout.csordtelcoa__Product_Configuration__c = testConfigCMP.Id;
        lockedSubscriptionPortout.csord__Account__c = testAccount.Id;
        
        csord__Subscription__c lockedSubscriptionPortout1=new csord__Subscription__c(Name ='portoutSub1234');
        lockedSubscriptionPortout1.csord__Order__c = testOrder.Id;
        lockedSubscriptionPortout1.Billing_Account__c = billingAccount.id;
        lockedSubscriptionPortout1.csord__Status__c=Label.Subscription_status_for_PortOut;
        lockedSubscriptionPortout1.serviceMSISDN__c='1234556877';
        lockedSubscriptionPortout1.csord__Identification__c='subscription';
        lockedSubscriptionPortout1.csordtelcoa__Product_Configuration__c = testConfigCMP.Id;
        lockedSubscriptionPortout1.csord__Account__c = testAccount.Id;
        
        // DPG-1891 Suspend IoT Services - Created Subscription record to Suspend
        csord__Subscription__c testSubscription6 = new csord__Subscription__c();
        testSubscription6.Name = 'IoT Right Plan';
        testSubscription6.csord__Account__c = testAccount.Id;
        testSubscription6.csord__Order__c = testOrder.Id;
        testSubscription6.csord__Identification__c = 'test';
        testSubscription6.csordtelcoa__Product_Configuration__c = testConfig4.Id;
        testSubscription6.csord__Status__c = 'Active';
        testSubscription6.Suspension_reason__c='Requested By Customer';
        
        // DPG-1892 Resume IoT Services - Created Subscription record to Resume
        csord__Subscription__c testSubscription7 = new csord__Subscription__c();
        testSubscription7.Name = 'IoT Right Plan';
        testSubscription7.csord__Account__c = testAccount.Id;
        testSubscription7.csord__Order__c = order.Id;
        testSubscription7.csord__Identification__c = 'test';
        testSubscription7.csordtelcoa__Product_Configuration__c = testConfig4.Id;
        testSubscription7.csord__Status__c = 'Suspended';
        testSubscription7.Suspension_reason__c='Requested By Customer';
        
        List<csord__Subscription__c> testSubsList = new List<csord__Subscription__c>{testSubscription,testSubscription2,testSubscription3,testSubscription4,testSubscription5,lockedSubscriptionPortout,testSubscription6,testSubscription7, lockedSubscriptionPortout1};
            insert testSubsList;
        
        //service
        List<csord__Service__c> servlist=new List<csord__Service__c>();
        List<Attachment> atts = new List<Attachment>();
        for(csord__Subscription__c testSubs:[SELECT Id,csord__Status__c,csord__Order__c FROM csord__Subscription__c])
        {
            csord__Service__c serv = new csord__Service__c();
            serv.name ='testService_'+testSubs.id;
            serv.csord__Identification__c  = 'testIdentify_4';
            serv.csordtelcoa__Service_Number__c = '3';
            serv.csord__Subscription__c = testSubscription.Id;
            serv.csord__Status__c = 'Created';
            serv.substage__c = 'Product Requirements Validation';
            serv.csord__Order_Request__c = ordReq.Id;
            serv.csord__Order__c = testSubs.csord__Order__c;
            serv.Scenario_Type__c = 'Change of Mobile Number';
            servlist.add(serv);
            
            csord__Service__c serv1 = new csord__Service__c();
            serv1.name ='testService_4';
            serv1.csord__Identification__c  = 'testIdentify_4';
            serv1.csordtelcoa__Service_Number__c = '3';
            serv1.csord__Subscription__c = testSubscription4.Id;
            serv1.csord__Status__c = 'Created';
            serv1.substage__c = 'Product Requirements Validation';
            serv1.Scenario_Type__c = 'Suspend';
            servlist.add(serv1);
        }
        cscfga__Product_Configuration__c config = new cscfga__Product_Configuration__c();
        config.Type__c = 'cancel';
        insert config;
        
        csord__Service__c servPortOut1 = new csord__Service__c();
        servPortOut1.name ='Parent'+lockedSubscriptionPortout.id;
        servPortOut1.csord__Identification__c  = 'testIdentify_5';
        servPortOut1.csordtelcoa__Service_Number__c = '4';
        servPortOut1.csord__Subscription__c = lockedSubscriptionPortout.Id;
        servPortOut1.csord__Status__c = 'Connected';
        servPortOut1.csord__Order_Request__c = ordReq.Id;
        servPortOut1.Initial_Activation_Date__c = System.today() - 90;
        servPortOut1.Scenario_Type__c = System.Label.PortOut;
        servPortOut1.csordtelcoa__Product_Configuration__c = config.id;
        servlist.add(servPortOut1);
        
                csord__Service__c servPortOut123 = new csord__Service__c();
        servPortOut123.name ='Parent'+lockedSubscriptionPortout1.id;
        servPortOut123.csord__Identification__c  = 'testIdentify_5';
        servPortOut123.csordtelcoa__Service_Number__c = '4';
        servPortOut123.csord__Subscription__c = lockedSubscriptionPortout1.Id;
        servPortOut123.csord__Status__c = 'Connected';
        servPortOut123.csord__Order_Request__c = ordReq.Id;
        servPortOut123.Initial_Activation_Date__c = System.today() - 90;
        servPortOut123.Scenario_Type__c = System.Label.PortOut;
        servPortOut123.csordtelcoa__Product_Configuration__c = config.id;
        servlist.add(servPortOut123);
        
        csord__Service__c servPortOut2 = new csord__Service__c();
        servPortOut2.name =lockedSubscriptionPortout.id;
        servPortOut2.csord__Identification__c  = 'testIdentify_6';
        servPortOut2.csordtelcoa__Service_Number__c = '4';
        servPortOut2.csord__Subscription__c = lockedSubscriptionPortout.Id;
        servPortOut2.csord__Status__c = 'Connected';
        servPortOut2.Scenario_Type__c = System.Label.PortOut;
        servPortOut2.csord__Order_Request__c = ordReq.Id;
        servPortOut2.Initial_Activation_Date__c = System.today() - 90;
        servPortOut2.csordtelcoa__Product_Configuration__c = testConfigCMP.id;
        servPortOut1.csordtelcoa__Product_Configuration__c = config.id;
        servlist.add(servPortOut2);
        
        // DPG-1891 Suspend IoT Services - Created Service record to Suspend
        csord__Service__c servIOTSuspend= new csord__Service__c();
        servIOTSuspend.name ='IoT Right Plan';
        servIOTSuspend.csord__Identification__c  = 'testIdentify_6';
        servIOTSuspend.csordtelcoa__Service_Number__c = '4';
        servIOTSuspend.csord__Subscription__c = testSubscription6.Id;
        servIOTSuspend.csord__Status__c = 'Connected';
        servIOTSuspend.Scenario_Type__c ='Suspend' ;
        servIOTSuspend.csord__Order_Request__c = ordReq.Id;
        servIOTSuspend.Initial_Activation_Date__c = System.today() - 90;
        servIOTSuspend.csordtelcoa__Product_Configuration__c = testConfig4.id;
        servlist.add(servIOTSuspend);
        
        // DPG-1892 Resume IoT Services - Created Service record to Resume
        csord__Service__c servIOTResume= new csord__Service__c();
        servIOTResume.name ='IoT Shared Plan';
        servIOTResume.csord__Identification__c  = 'testIdentify_7';
        servIOTResume.csordtelcoa__Service_Number__c = '4';
        servIOTResume.csord__Subscription__c = testSubscription7.Id;
        servIOTResume.csord__Status__c = 'Connected';
        servIOTResume.Scenario_Type__c ='Resume' ;
        servIOTResume.csord__Order_Request__c = ordReq.Id;
        servIOTResume.Initial_Activation_Date__c = System.today() - 90;
        servIOTResume.csordtelcoa__Product_Configuration__c = testConfig4.id;
        servlist.add(servIOTResume);
        
        //create service
        insert servlist;
        
        servPortOut2.csord__Service__c = servPortOut1.id;
        upsert servPortOut2;
        for(csord__Service__c serv:servlist){
            Attachment att1 = new Attachment();
            if(serv.Scenario_Type__c != System.Label.PortOut){
                att1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Disconnect Pending","startDate":"","specification":"30a0f36c-b496-185e-6330-c7a9c317d22c","productConfigurationId":"a0b0Y000001oXmtQAE","name":"CWPSpec","instanceId":"1234","guid":"3072dad2-5546-eb71-8e13-bd04b7f9824a","endDate":"","description":"CWP CFS Specification","code":"DMCAT_ProductSpecification_000263","attributes":{"__targetSystem":"FULFILMENT","Zone":"Zone 3","TotalMRC":1500,"Seat":5,"complexIPAccess":[{"attributes":{"complexAttrPort":8080,"complexAttrTech":"Fibre"},"productConfigurationId":"a0b0Y000001oXmyQAE"},{"attributes":{"complexAttrPort":9090,"complexAttrTech":"Ethernet"},"productConfigurationId":"a0b0Y000001oXn3QAE"}],"constantName":"contantValue"}},{"version":"1","status":"Cancellation Pending","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXmyQAE","name":"IPAccessSpec","instanceId":"3456","guid":"3df57fcf-7c28-c50a-140b-0d21e80714e7","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","Port":8080,"Technology":"Fibre","constantAttr":"constantValue"}},{"version":"1","status":"Pending","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXn3QAE","name":"IPAccessSpec","instanceId":"6789","guid":"495bbebb-5166-6dce-24cd-648084f6241c","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","Port":9090,"Technology":"Ethernet","constantAttr":"constantValue"},"additionalAttributes":{"SuspensionContext":"CUSTOMER"}}],"serviceId":"'+serv.id+'","legacyAttributes":[]}');
                att1.Name = 'ServiceSpecifications.json';
                att1.ParentId = serv.Id;
                atts.add(att1);
            }
        }  
        
            // DPG-1892 - Resume IoT Services - Added attachment to service         
            Attachment att2 = new Attachment();
          att2.Body = Blob.valueOf('{"specifications":[{"additionalAttributes":{"CALLRESTRICTION":"BAR_PREMIUM","INTROAM":"FALSE","CustomerFacingServiceId":"61459014352","MESSAGEBANK":"NA","SERVICEPROFILE":"TABLET","IMSI":"","ShippingRequired":"FALSE","parentSpec":"4ab32e59-e86b-29b9-a3a8-f09434ad0a91","AccessRole":"Primary","SuspensionContext":"NA","CONTEXT":"CUSTOMER","SIMSerialNumber":" ","SKU":"100119211","__targetSystem":"FULFILMENT"},"attributes":{"__targetSystem":"FULFILMENT","SKU":"100119211","SIMSerialNumber":" ","CONTEXT":"CUSTOMER","SuspensionContext":"NA","AccessRole":"Primary","parentSpec":"DMCAT_ProductSpecification_000965_Fulfilment","ShippingRequired":"TRUE","IMSI":"","SERVICEPROFILE":"TABLET","MESSAGEBANK":"NA","CustomerFacingServiceId":"","INTROAM":"FALSE","CALLRESTRICTION":"BAR_PREMIUM"},"code":"DMCAT_ProductSpecification_000966_Fulfilment","description":"IOT Access_Fulfilment","endDate":"","guid":"7a32b330-86ae-83f1-57b5-49bff92008d2","includeBilling":false,"instanceId":"","metadata":{},"name":"IOT Access_Fulfilment","productConfigurationId":"a3T5P0000001XRZUA2","specification":"DMCAT_ProductSpecification_000965DMCAT_ProductSpecification_000966","startDate":"","status":"Resume","version":"1"}],"serviceId":"'+servlist[19].Id+'","legacyAttributes":[]}');
            att2.Name = 'ServiceSpecifications.json';
            att2.ParentId = servlist[19].Id;
            atts.add(att2);
        
          // DPG-1891 - Suspend IoT Services - Added attachment to service
          Attachment att3 = new Attachment();
            att3.Body = Blob.valueOf('{"specifications":[{"additionalAttributes":{"CALLRESTRICTION":"BAR_PREMIUM","INTROAM":"FALSE","CustomerFacingServiceId":"61459014352","MESSAGEBANK":"NA","SERVICEPROFILE":"TABLET","IMSI":"","ShippingRequired":"FALSE","parentSpec":"4ab32e59-e86b-29b9-a3a8-f09434ad0a91","AccessRole":"Primary","SuspensionContext":"CUSTOMER","CONTEXT":"CUSTOMER","SIMSerialNumber":" ","SKU":"100119211","__targetSystem":"FULFILMENT"},"attributes":{"__targetSystem":"FULFILMENT","SKU":"100119211","SIMSerialNumber":" ","CONTEXT":"CUSTOMER","SuspensionContext":"CUSTOMER","AccessRole":"Primary","parentSpec":"DMCAT_ProductSpecification_000965_Fulfilment","ShippingRequired":"TRUE","IMSI":"","SERVICEPROFILE":"TABLET","MESSAGEBANK":"NA","CustomerFacingServiceId":"","INTROAM":"FALSE","CALLRESTRICTION":"BAR_PREMIUM"},"code":"DMCAT_ProductSpecification_000966_Fulfilment","description":"IOT Access_Fulfilment","endDate":"","guid":"7a32b330-86ae-83f1-57b5-49bff92008d2","includeBilling":false,"instanceId":"","metadata":{},"name":"IOT Access_Fulfilment","productConfigurationId":"a3T5P0000001XRZUA2","specification":"DMCAT_ProductSpecification_000965DMCAT_ProductSpecification_000966","startDate":"","status":"Suspend","version":"1"}],"serviceId":"'+servlist[18].Id+'","legacyAttributes":[]}');
            att3.Name = 'ServiceSpecifications.json';
            att3.ParentId = servlist[18].Id;
            atts.add(att3); 
        //create attachment

        insert atts;
        
        cspmb__Price_Item__c testPriceItem = new cspmb__Price_Item__c();
        testPriceItem.Name = 'Mobile Device';
        testPriceItem.Manufacturer__c = 'TestMan';
        testPriceItem.Model__c = 'TestMod';
        testPriceItem.ProdSpecId__c = 'DMCAT_ProductSpecification_000423';
        testPriceItem.cspmb__Contract_Term__c = '24';
        testPriceItem.ChargeType__c = 'RC';
        testPriceItem.cspmb__Recurring_Charge__c = 20;
        testPriceItem.Billing_Description__c ='Test';
        testPriceItem.taxTreatment__c = 'GST Exempt';
        testPriceItem.Unit_Of_Measure__c='per device';
        testPriceItem.Offer_Id__c = 'DMCAT_Offer_000646';
        testPriceItem.billingSubtype__c = 'ROETC';
        //EDGE-144389 - Changed billing subtype as per Sigma
        
        cspmb__Price_Item__c testPriceItem2 = new cspmb__Price_Item__c();
        testPriceItem2.Name = 'Mobile Device 2';
        testPriceItem2.Manufacturer__c = 'TestMan1';
        testPriceItem2.Model__c = 'TestMod1';
        testPriceItem2.ProdSpecId__c = 'DMCAT_ProductSpecification_000263';
        testPriceItem2.cspmb__Contract_Term__c = '24';
        testPriceItem2.ChargeType__c = 'OC';
        testPriceItem2.Billing_Description__c ='Test1';
        testPriceItem2.taxTreatment__c = 'GST Exempt';
        testPriceItem2.Unit_Of_Measure__c='per device';
        testPriceItem2.Offer_Id__c = 'DMCAT_Offer_000646';
        testPriceItem2.billingSubtype__c = 'ROETC';
         
        List<cspmb__Price_Item__c> PIList = new List<cspmb__Price_Item__c> {testPriceItem,testPriceItem2};
        insert PIList; 
        
        Number__c num=new Number__c();
        num.Name='Test Num';
        num.Service_Number__c=testSubscription.serviceMSISDN__c;
        num.Status__c='RESERVED';
        num.Account__c=testSubscription.csord__Account__c;
        num.Subscription_number__c=testSubscription.csordtelcoa__Subscription_Number__c;
        num.Mobile__c='Mobile';
        num.Type__c='New';
        insert num;
    }
    
    
    @isTest
    static void generateOrderForScenarioTypeChangeinMobTest(){
        List<String> subsIdList=new List<String>();
        Id accountId;
        String scenarioType;
        
        /*CSPOFA__Orchestration_Process_Template__c orchProcessTemp = new CSPOFA__Orchestration_Process_Template__c();
orchProcessTemp.Name = 'Order Fulfilment Process';
orchProcessTemp.CSPOFA__Process_Type__c = 'New Provide';
orchProcessTemp.CSPOFA__Processing_Mode__c = 'Foreground';
insert orchProcessTemp;*/
        
        csord__Service__c ser = [SELECT Id,csord__Subscription__r.Id, csord__Subscription__r.csord__Account__c, Scenario_Type__c FROM csord__Service__c where Scenario_Type__c = 'Change of Mobile Number' LIMIT 1];
        subsIdList.add(ser.csord__Subscription__r.Id);
        accountId= ser.csord__Subscription__r.csord__Account__c;
        scenarioType = ser.Scenario_Type__c;
        Test.startTest();
        String tNowCaseRef='TCN123456789';
        List<csord__Order__c> orderList =OrderGeneratorUtil.generateOrderForScenarioType(subsIdList,accountId,scenarioType,tNowCaseRef);
        
        system.assert(orderList!=null);
        Test.stopTest();        
    }
    
    @isTest
    static void generateOrderForScenarioTypeSuspendTest(){
        List<String> subsIdList=new List<String>();
        Id accountId;
        String scenarioType;
        
        String reason;
        
        /*CSPOFA__Orchestration_Process_Template__c orchProcessTemp = new CSPOFA__Orchestration_Process_Template__c();
orchProcessTemp.Name = 'Order Fulfilment Process';
orchProcessTemp.CSPOFA__Process_Type__c = 'New Provide';
orchProcessTemp.CSPOFA__Processing_Mode__c = 'Foreground';
insert orchProcessTemp;*/
        
        
        csord__Service__c ser = [SELECT Id,csord__Subscription__r.Id, csord__Subscription__r.csord__Account__c, Scenario_Type__c,csord__Subscription__r.Suspension_reason__c FROM csord__Service__c where Scenario_Type__c = 'Suspend' LIMIT 1];
        subsIdList.add(ser.csord__Subscription__r.Id);
        accountId= ser.csord__Subscription__r.csord__Account__c;
        scenarioType = ser.Scenario_Type__c;
        reason=ser.csord__Subscription__r.Suspension_reason__c;
        Test.startTest();
        String tNowCaseRef='TCN123456789';
        
        List<csord__Order__c> orderList =OrderGeneratorUtil.generateOrderForScenarioType(subsIdList,accountId,scenarioType,tNowCaseRef);
        
        system.assert(orderList!=null);
        Test.stopTest();        
    }
    
    @isTest
    static void generateOrderForScenarioTypePortOutTest(){
        csord__Subscription__c testRecord = [Select csord__Status__c,csord__Account__c,serviceMSISDN__c,id,csordtelcoa__Subscription_Number__c,csordtelcoa__Product_Configuration__c from csord__Subscription__c where csord__Status__c=:Label.Subscription_status_for_PortOut limit 1];        
        DisconnectionRequest__c dr = new DisconnectionRequest__c(BillingCycleDay__c='1',Disconnect_Type__c='Port Out',E2ECorrelationID__c='3247862345-43543-2342',MSISDN__c='61474839046',Originating_System__c='TRAMAS',Requested_DateTime__c=String.valueOf(datetime.now()),Subscription__c=testRecord.id);
        Test.startTest();
        insert dr;
        String tNowCaseRef='TCN123456789';
        List<csord__Order__c> ord = OrderGeneratorUtil.generateOrderForScenarioType(new List<String> {testRecord.id}, testRecord.csord__Account__c,System.Label.PortOut,tNowCaseRef);
        Test.stopTest();
        //Added Attribute Query for  EDGE-148420
        cscfga__Attribute__c attlistfor=[select cscfga__Value__c from cscfga__Attribute__c where cscfga__Product_Configuration__c=:testRecord.csordtelcoa__Product_Configuration__c and name='ChangeType' limit 1 ];
        system.assert(ord!=null);
        csord__Subscription__c testSubsCT = [Select changetype__c,id from csord__Subscription__c where id = :testRecord.Id]; // Added as part of EDGE-185450
        system.assertEquals('Port Out',testSubsCT.changetype__c); // Added as part of EDGE-185450
        // system.assert(attlistfor.cscfga__Value__c=='Cancel');// For EDGE-148420
    }
    
     //EDGE-159332
    @isTest
    static void generateOrderForScenarioTriggerRTS(){
        csord__Subscription__c testRecord = [Select Trigger_RTS__c, csord__Status__c,csord__Account__c,serviceMSISDN__c,id,csordtelcoa__Subscription_Number__c,csordtelcoa__Product_Configuration__c from csord__Subscription__c where Name ='portoutSub1234' limit 1];        

        testRecord.Trigger_RTS__c = false;  //setting false and then method should not make it true
        update testRecord;
        Test.startTest();

        String tNowCaseRef='TCN123456780';
        List<csord__Order__c> ord = OrderGeneratorUtil.generateOrderForScenarioType(new List<String> {testRecord.id}, testRecord.csord__Account__c,System.Label.PortOut,tNowCaseRef);
        Test.stopTest();
     
        csord__Subscription__c outPutSub = [Select id, Trigger_RTS__c  from csord__Subscription__c where id =: testRecord.id];
        
        system.assertEquals(outPutSub.Trigger_RTS__c, false);
    }   
    
    @isTest
    static void generateOrderForSuspendResumeTest(){
        List<String> subsIdList=new List<String>();
        Id accountId;
        String scenarioType;
        //String reason;
        Map<String, String> subToReason =new Map<String, String>();// DPG-4543 || DPG-4544, Ila || Krunal
        csord__Service__c ser = [SELECT Id,csord__Subscription__r.Id, csord__Subscription__r.csord__Account__c, Scenario_Type__c,csord__Subscription__r.Suspension_reason__c FROM csord__Service__c where Scenario_Type__c = 'Suspend' LIMIT 1];
        subsIdList.add(ser.csord__Subscription__r.Id);
        accountId= ser.csord__Subscription__r.csord__Account__c;
        scenarioType = ser.Scenario_Type__c;
        //reason=ser.csord__Subscription__r.Suspension_reason__c;
        subToReason.put(ser.csord__Subscription__r.Id,ser.csord__Subscription__r.Suspension_reason__c);// DPG-4543 || DPG-4544, Ila || Krunal
        Test.startTest();
        String tNowCaseRef='TCN123456789';
        List<csord__Order__c> orderList1=OrderGeneratorUtil.generateOrderForSuspendResume(subsIdList,accountId,scenarioType,tNowCaseRef, subToReason); // DPG-4543 || DPG-4544, Ila || Krunal, Parameter changed
        system.assert(orderList1!=null);
        Test.stopTest();
    }
    
    // DPG-1891 Suspend IoT Services
    @isTest
    static void generateOrderForSuspendIOTTest(){
        List<String> subsIdList=new List<String>();
        Id accountId;
        String scenarioType;
        //String reason;
        Map<String, String> subToReason =new Map<String, String>(); // DPG-4543 || DPG-4544, Ila || Krunal, Map of Sub Reason

        csord__Service__c ser = [SELECT Id,csord__Subscription__r.Id, csord__Subscription__r.csord__Account__c, Scenario_Type__c,csord__Subscription__r.Suspension_reason__c FROM csord__Service__c where Scenario_Type__c = 'Suspend' AND Name LIKE '%IoT%' LIMIT 1];
        
        subsIdList.add(ser.csord__Subscription__r.Id);
        accountId= ser.csord__Subscription__r.csord__Account__c;
        scenarioType = ser.Scenario_Type__c;
        //reason=ser.csord__Subscription__r.Suspension_reason__c;
        subToReason.put(ser.csord__Subscription__r.Id,ser.csord__Subscription__r.Suspension_reason__c); // DPG-4543 || DPG-4544, Ila || Krunal, Map of Sub Reason

        Test.startTest();
        String tNowCaseRef='TCN123456799';
        List<csord__Order__c> orderList1=OrderGeneratorUtil.generateOrderForSuspendResume(subsIdList,accountId,scenarioType,tNowCaseRef,subToReason); 
        system.assert(orderList1!=null);
        Test.stopTest();
        String updatedBody = '';
        for(Attachment att : [SELECT id, name, body, parentId FROM Attachment WHERE parentId =:ser.Id]){
            updatedBody = att.Body.toString();
        }
        System.assertNotEquals(null, updatedBody);
    }

    // DPG-1892 Resume IoT Services
    @isTest
    static void generateOrderForResumeIOTTest(){
        List<String> subsIdList=new List<String>();
        Id accountId;
        String scenarioType;
        //String reason;
        Map<String, String> subToReason =new Map<String, String>();// DPG-4543 || DPG-4544, Ila || Krunal

        csord__Service__c ser = [SELECT Id,csord__Subscription__r.Id, csord__Subscription__r.csord__Account__c, Scenario_Type__c,csord__Subscription__r.Suspension_reason__c FROM csord__Service__c where Scenario_Type__c = 'Resume' AND Name LIKE '%IoT%' LIMIT 1];
        
        subsIdList.add(ser.csord__Subscription__r.Id);
        accountId= ser.csord__Subscription__r.csord__Account__c;
        scenarioType = ser.Scenario_Type__c;
        //reason=ser.csord__Subscription__r.Suspension_reason__c;
        subToReason.put(ser.csord__Subscription__r.Id,ser.csord__Subscription__r.Suspension_reason__c);// DPG-4543 || DPG-4544, Ila || Krunal

        Test.startTest();
        String tNowCaseRef='TCN123456899';
        List<csord__Order__c> orderList1=OrderGeneratorUtil.generateOrderForSuspendResume(subsIdList,accountId,scenarioType,tNowCaseRef,subToReason); // DPG-4543 || DPG-4544, Ila || Krunal, Parameter changed
        system.assert(orderList1!=null);
        Test.stopTest();
        String updatedBody = '';
        for(Attachment att : [SELECT id, name, body, parentId FROM Attachment WHERE parentId =:ser.Id]){
            updatedBody = att.Body.toString();
        }
        System.assertNotEquals(null, updatedBody);
        //system.assert(updatedBody.contains('ShippingRequired'));
    }
      
    @isTest
    static void NumberRecordtest(){
        List<String> subsIdList=new List<String>();
        Id accountId;
        String scenarioType;
        
        Number__c num=[select id,name,Service_Number__c from Number__c where name='Test Num'];
        csord__Service__c ser = [SELECT Id,csord__Subscription__r.Id, csord__Subscription__r.csord__Account__c, Scenario_Type__c,csord__Subscription__r.serviceMSISDN__c FROM csord__Service__c where Scenario_Type__c = 'Change of Mobile Number' LIMIT 1];
        subsIdList.add(ser.csord__Subscription__r.Id);
        accountId= ser.csord__Subscription__r.csord__Account__c;
        scenarioType = ser.Scenario_Type__c;
        Test.startTest();
        String tNowCaseRef='TCN123456789';
        List<csord__Order__c> orderList =OrderGeneratorUtil.generateOrderForScenarioType(subsIdList,accountId,scenarioType,tNowCaseRef);
        
        system.assertEquals(ser.csord__Subscription__r.serviceMSISDN__c, num.Service_Number__c);
        Test.stopTest();  
    }
    
    @isTest
    static void calculateETCForServicestest(){
        
        csord__Service__c ser = [SELECT Id,csord__Subscription__r.Id,csordtelcoa__Product_Configuration__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name, csord__Subscription__r.csord__Account__c, Scenario_Type__c,csord__Subscription__r.Billing_Account__r.Billing_Account_Number__c FROM csord__Service__c where Scenario_Type__c = 'Change of Mobile Number' LIMIT 1];
        Map<String,csord__Subscription__c> SubIdMap = new Map<String,csord__Subscription__c> ();
        SubIdMap.put(ser.csord__Subscription__r.Id,ser.csord__Subscription__r);
        List<csord__Service__c> serviceList = new List<csord__Service__c>();
        serviceList.add(ser);
        Map<Id,Decimal> result = new Map<Id,Decimal>();
        Test.startTest();
        result =OrderGeneratorUtil.calculateETCForServices(SubIdMap,serviceList);
        
        system.assertNotEquals(serviceList,null);
        Test.stopTest();  
    } 
    
    // Added as part of EDGE-154370
    @isTest
    static void generateOrderForResume_DateFieldsCheck(){
        List<String> subsIdList=new List<String>();
        Id accountId;
        String scenarioType;
        //String reason;
       Map<String, String> subToReason =new Map<String, String>(); // DPG-4543 || DPG-4544, Ila || Krunal, Map of Subscription to Reason

        csord__Service__c ser = [SELECT Id,csord__Subscription__r.Id, csord__Subscription__r.csord__Account__c, Scenario_Type__c,csord__Subscription__r.Suspension_reason__c FROM csord__Service__c where Scenario_Type__c = 'Resume' AND Name LIKE '%IoT%' LIMIT 1];
        
        subsIdList.add(ser.csord__Subscription__r.Id);
        accountId= ser.csord__Subscription__r.csord__Account__c;
        scenarioType = ser.Scenario_Type__c;
        //reason=ser.csord__Subscription__r.Suspension_reason__c;
        subToReason.put(ser.csord__Subscription__r.Id,ser.csord__Subscription__r.Suspension_reason__c); // DPG-4543 || DPG-4544, Ila || Krunal

        Test.startTest();
        String tNowCaseRef='TCN123456899';
        List<csord__Order__c> orderList1=OrderGeneratorUtil.generateOrderForSuspendResume(subsIdList,accountId,scenarioType,tNowCaseRef,subToReason); // DPG-4543 || DPG-4544, Ila || Krunal, Parameter changed
        system.assert(orderList1!=null);
        System.debug('orderList1...'+orderList1);
        List<csord__Service__c> servList1 = [SELECT Id,Telstra_Committed_Date__c,Forecasted_Delivery_Date__c FROM csord__Service__c WHERE csord__Order__c = :orderList1[0].Id];
        for(csord__Service__c ser1 : servList1){
            System.assertEquals(null, ser1.Telstra_Committed_Date__c);
            System.assertEquals(null, ser1.Forecasted_Delivery_Date__c);
        }
        Test.stopTest();

    }
    
    // Added as part of EDGE-154370
    @isTest
    static void generateOrderForChangeinMob_DateFieldsCheck(){
        List<String> subsIdList=new List<String>();
        Id accountId;
        String scenarioType;
        
        csord__Service__c ser = [SELECT Id,csord__Subscription__r.Id, csord__Subscription__r.csord__Account__c, Scenario_Type__c FROM csord__Service__c where Scenario_Type__c = 'Change of Mobile Number' LIMIT 1];
        subsIdList.add(ser.csord__Subscription__r.Id);
        accountId= ser.csord__Subscription__r.csord__Account__c;
        scenarioType = ser.Scenario_Type__c;
        Test.startTest();
        String tNowCaseRef='TCN123456789';
        List<csord__Order__c> orderList =OrderGeneratorUtil.generateOrderForScenarioType(subsIdList,accountId,scenarioType,tNowCaseRef);
        system.assert(orderList!=null);
        List<csord__Service__c> servList1 = [SELECT Id,Telstra_Committed_Date__c,Forecasted_Delivery_Date__c,changetype__c FROM csord__Service__c WHERE csord__Order__c = :orderList[0].Id];
        for(csord__Service__c ser1 : servList1){
            System.assertEquals(null, ser1.Telstra_Committed_Date__c);
            System.assertEquals(null, ser1.Forecasted_Delivery_Date__c);
            System.assertEquals('Change of Mobile Number', ser1.changetype__c);  // Added as part of EDGE-185450
        }
        Test.stopTest();        
    }
    
    // Added as part of EDGE-167554
    @isTest
    static void generateOrderForPortOut_GenerateSpecTest(){
        csord__Subscription__c testRecord = [Select csord__Status__c,csord__Account__c,serviceMSISDN__c,id,csordtelcoa__Subscription_Number__c,csordtelcoa__Product_Configuration__c from csord__Subscription__c where csord__Status__c=:Label.Subscription_status_for_PortOut and name = 'portoutSub1234' limit 1];        
        DisconnectionRequest__c dr = new DisconnectionRequest__c(BillingCycleDay__c='1',Disconnect_Type__c='Port Out',E2ECorrelationID__c='3247862345-43543-2342',MSISDN__c='61474839046',Originating_System__c='TRAMAS',Requested_DateTime__c=String.valueOf(datetime.now()),Subscription__c=testRecord.id);
        Test.startTest();
        insert dr;
        String tNowCaseRef='TCN123456789';
        List<csord__Order__c> ord = OrderGeneratorUtil.generateOrderForScenarioType(new List<String> {testRecord.id}, testRecord.csord__Account__c,System.Label.PortOut,tNowCaseRef);
        Test.stopTest();
        csord__Service__c serv= [SELECT Id,csord__Subscription__c,csord__Subscription__r.Id FROM csord__Service__c WHERE csord__Subscription__r.Id =: testRecord.Id];
        Attachment spec = [SELECT Id,Name FROM Attachment WHERE ParentId =: serv.Id and name='ServiceSpecifications.json' LIMIT 1];
        system.assert(spec!=null);
    }

    // Added test method as part of EDGE-165552 
    @isTest
    static void testPortOutCancelETCBasedOnBillingType(){
        csord__Subscription__c testRecord = [Select csord__Status__c,csord__Account__c,serviceMSISDN__c,id,csordtelcoa__Subscription_Number__c,csordtelcoa__Product_Configuration__c from csord__Subscription__c where csord__Status__c=:Label.Subscription_status_for_PortOut limit 1];        
        csord__Service__c serv= [SELECT Id,csord__Subscription__c,csord__Subscription__r.Id FROM csord__Service__c WHERE csord__Subscription__r.Id =: testRecord.Id LIMIT 1];
        Attachment att = [SELECT Id,body,ParentID FROM Attachment WHERE ParentID =: serv.id];
        att.Body=Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+serv.id+'","specifications":[{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","ocsProdID":"T22E_IR_USAGE","currency":"AUD","type":"OC","billingSubtype":"ROETC","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","billDescription":"IR Pay as you go charge","rateExcludeGST":"0.00","unitofMeasure":"each","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000263_DMCAT_NonRecurringCharge_000601_108"},"code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","description":"Mobile Access_Billing_NonRecurringCharge_000601","endDate":"","guid":"a9e4497b-2754-7221-e6ca-6751671ef2a8","includeBilling":false,"instanceId":"","metadata":{},"name":"263_NRC_601","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"parentSpec":"908fe418-a109-e766-2517-363f5f32cd05"},"attributes":{"__targetSystem":"ASSURANCE","parentSpec":"DMCAT_ProductSpecification_000326_Assurance","ResponseTarget":"SLA0010001","RestoreTarget":"SLA0010006"},"code":"DMCAT_ProductSpecification_000151_Assurance","description":"Incident Management_Assurance","endDate":"","guid":"4f374952-2bf4-8fa5-85a7-e8a30727635c","includeBilling":false,"instanceId":"","metadata":{},"name":"151_ASR","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151_2","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"ServiceManagementOption":"1","__targetSystem":"ASSURANCE"},"code":"DMCAT_ProductSpecification_000326_Assurance","description":"Telstra Managed Service Option 1_Assurance","endDate":"","guid":"908fe418-a109-e766-2517-363f5f32cd05","includeBilling":false,"instanceId":"","metadata":{},"name":"326_ASR","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductOffering_000420DMCAT_ProductSpecification_000326","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_IRDAYPASS","type":"International Roaming Data","unitofMeasure":"MB","value":"200","billingSubtype":"ROETC","billDescription":"IR Day Pass"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000606","description":"Mobility_Billing_DMCAT_Allowance_000606","endDate":"","guid":"068b988d-18d3-78e8-407a-13d896f581b5","includeBilling":false,"instanceId":"","metadata":{},"name":"263_AW_606","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000606_5","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_IR_AUTOTOPUP","type":"International Roaming Data","unitofMeasure":"MB","value":"500","billingSubtype":"ROETC","billDescription":"IR Data Topup"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000607","description":"Mobility_Billing_DMCAT_Allowance_000607","endDate":"","guid":"805764a7-d9e5-01a8-65b0-52b23c81d1a8","includeBilling":false,"instanceId":"","metadata":{},"name":"263_AW_607","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000607_6","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","quantity":"1","recurringChargePeriod":"Months","description":"MRO Bonus Plan Discount","alteredPrice":1448.5,"applicationDuration":24,"type":"Data","currency":"AUD","frequency":"Monthly","billingSpecId":"BSRC001_CB","billInAdvance":"true","prorate":"false","billDescription":"Corporate mobile plus - global data sim plan","rateExcludeGST":"145.50","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_4910"},"code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","description":"Mobility_Billing_RecurringCharge_000654","endDate":"","guid":"50f59975-ac13-db8c-163c-477df5092dcc","includeBilling":false,"instanceId":"","metadata":{},"name":"420_RC_654","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"ASSURANCE"},"code":"DMCAT_ProductSpecification_000421_Assurance","description":"Mobile Device Management_Assurance","endDate":"","guid":"9292a251-590b-bd78-ac23-47da3755d4ff","includeBilling":false,"instanceId":"","metadata":{},"name":"421_ASR","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000421","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"SERVICEPROFILE":"TABLET","IMSI":"","CustomerFacingServiceId":"61473603212","MESSAGEBANK":"NA","SKU":"100119211","parentSpec":"7200c94d-ad78-0078-c8d3-b5c586d50313","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","__targetSystem":"FULFILMENT"},"attributes":{"__targetSystem":"FULFILMENT","IPWirelessProductInstanceID":"NA","BillofMaterialID":"NA","AccessRole":"Primary","CONTEXT":"CUSTOMER","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","SKU":"100119211","SuspensionContext":"NA","CustomerFacingServiceId":"","ShippingRequired":"TRUE","IMSI":"","SERVICEPROFILE":"TABLET"},"code":"DMCAT_ProductSpecification_000263_Fulfilment","description":"Mobile Access_Fulfilment","endDate":"","guid":"fc8e7088-a0ba-6b6c-ef69-3e6b3d281a89","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","startDate":"","status":"Suspend","version":"1"},{"additionalAttributes":{"__targetSystem":"FULFILMENT","IPWirelessProductInstanceID":"NA","BillofMaterialID":"NA","AccessRole":"Primary","CONTEXT":"CUSTOMER","SKU":"100119211","MESSAGEBANK":"NA","CustomerFacingServiceId":"61473603212","IMSI":"","SERVICEPROFILE":"TABLET"},"attributes":{"__targetSystem":"FULFILMENT"},"code":"DMCAT_ProductSpecification_000420_Fulfilment","description":"Mobility_Fulfilment","endDate":"","guid":"7200c94d-ad78-0078-c8d3-b5c586d50313","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobility_Fulfilment","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000420","startDate":"","status":"Modified","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","value":"250","unitofMeasure":"GB","type":"FairPlay Data","ocsProdID":"T22EM_MBB-L","billingSpecId":"BSUSG001_CB","billDescription":"Includes 250 GB Domestic Data"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000637","description":"Mobility_Billing_DMCAT_Allowance_000637","endDate":"","guid":"ebba38ae-33c5-6b11-f8ce-50f6b74520fe","includeBilling":false,"instanceId":"","metadata":{},"name":"420_AW_637","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000637_7","startDate":"","status":"Created","version":"1"}]}');
        update att;
        DisconnectionRequest__c dr = new DisconnectionRequest__c(BillingCycleDay__c='1',Disconnect_Type__c='Port Out',E2ECorrelationID__c='3247862345-43543-2342',MSISDN__c='61474839046',Originating_System__c='TRAMAS',Requested_DateTime__c=String.valueOf(datetime.now()),Subscription__c=testRecord.id);
        Test.startTest();
        insert dr;
        
        String tNowCaseRef='TCN123456789';
        List<csord__Order__c> ord = OrderGeneratorUtil.generateOrderForScenarioType(new List<String> {testRecord.id}, testRecord.csord__Account__c,System.Label.PortOut,tNowCaseRef);
        Test.stopTest();
        
        cscfga__Product_Configuration__c pc = [SELECT Id,Type__c FROM cscfga__Product_Configuration__c WHERE Id =:testRecord.csordtelcoa__Product_Configuration__c];
        csord__Service__c serv1= [SELECT Id,action_type__c, csord__Subscription__c,csord__Subscription__r.Id FROM csord__Service__c WHERE csord__Subscription__r.Id =: testRecord.Id LIMIT 1];
    
        System.assertEquals('Cancel', pc.Type__c);
       
    }  
    
   // Added test method as part of EDGE-165552 
    @isTest
    static void testPortOut_ShippingRequired(){
        csord__Subscription__c testRecord = [Select csord__Status__c,csord__Account__c,serviceMSISDN__c,id,csordtelcoa__Subscription_Number__c,csordtelcoa__Product_Configuration__c,orderversion__c from csord__Subscription__c where csord__Status__c=:Label.Subscription_status_for_PortOut limit 1];        
        csord__Service__c serv= [SELECT Id,csord__Subscription__c,csord__Subscription__r.Id FROM csord__Service__c WHERE csord__Subscription__r.Id =: testRecord.Id LIMIT 1];
        Attachment att = [SELECT Id,body,ParentID FROM Attachment WHERE ParentID =: serv.id];
        att.Body=Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+serv.id+'","specifications":[{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","ocsProdID":"T22E_IR_USAGE","currency":"AUD","type":"OC","billingSubtype":"ROETC","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","billDescription":"IR Pay as you go charge","rateExcludeGST":"0.00","unitofMeasure":"each","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000263_DMCAT_NonRecurringCharge_000601_108"},"code":"DMCAT_ProductSpecification_000423_Billing_NonRecurringCharge_000601","description":"Mobile Access_Billing_NonRecurringCharge_000601","endDate":"","guid":"a9e4497b-2754-7221-e6ca-6751671ef2a8","includeBilling":false,"instanceId":"","metadata":{},"name":"263_NRC_601","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"parentSpec":"908fe418-a109-e766-2517-363f5f32cd05"},"attributes":{"__targetSystem":"ASSURANCE","parentSpec":"DMCAT_ProductSpecification_000326_Assurance","ResponseTarget":"SLA0010001","RestoreTarget":"SLA0010006"},"code":"DMCAT_ProductSpecification_000151_Assurance","description":"Incident Management_Assurance","endDate":"","guid":"4f374952-2bf4-8fa5-85a7-e8a30727635c","includeBilling":false,"instanceId":"","metadata":{},"name":"151_ASR","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151_2","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"ServiceManagementOption":"1","__targetSystem":"ASSURANCE"},"code":"DMCAT_ProductSpecification_000326_Assurance","description":"Telstra Managed Service Option 1_Assurance","endDate":"","guid":"908fe418-a109-e766-2517-363f5f32cd05","includeBilling":false,"instanceId":"","metadata":{},"name":"326_ASR","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductOffering_000420DMCAT_ProductSpecification_000326","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_IRDAYPASS","type":"International Roaming Data","unitofMeasure":"MB","value":"200","billingSubtype":"ROETC","billDescription":"IR Day Pass"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000606","description":"Mobility_Billing_DMCAT_Allowance_000606","endDate":"","guid":"068b988d-18d3-78e8-407a-13d896f581b5","includeBilling":false,"instanceId":"","metadata":{},"name":"263_AW_606","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000606_5","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"T22E_IR_AUTOTOPUP","type":"International Roaming Data","unitofMeasure":"MB","value":"500","billingSubtype":"ROETC","billDescription":"IR Data Topup"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000607","description":"Mobility_Billing_DMCAT_Allowance_000607","endDate":"","guid":"805764a7-d9e5-01a8-65b0-52b23c81d1a8","includeBilling":false,"instanceId":"","metadata":{},"name":"263_AW_607","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000607_6","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","quantity":"1","recurringChargePeriod":"Months","description":"MRO Bonus Plan Discount","alteredPrice":1448.5,"applicationDuration":24,"type":"Data","currency":"AUD","frequency":"Monthly","billingSpecId":"BSRC001_CB","billInAdvance":"true","prorate":"false","billDescription":"Corporate mobile plus - global data sim plan","rateExcludeGST":"145.50","externalId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000654_4910"},"code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","description":"Mobility_Billing_RecurringCharge_000654","endDate":"","guid":"50f59975-ac13-db8c-163c-477df5092dcc","includeBilling":false,"instanceId":"","metadata":{},"name":"420_RC_654","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000654","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"ASSURANCE"},"code":"DMCAT_ProductSpecification_000421_Assurance","description":"Mobile Device Management_Assurance","endDate":"","guid":"9292a251-590b-bd78-ac23-47da3755d4ff","includeBilling":false,"instanceId":"","metadata":{},"name":"421_ASR","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000421","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"SERVICEPROFILE":"TABLET","IMSI":"","CustomerFacingServiceId":"61473603212","MESSAGEBANK":"NA","SKU":"100119211","parentSpec":"7200c94d-ad78-0078-c8d3-b5c586d50313","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","__targetSystem":"FULFILMENT"},"attributes":{"__targetSystem":"FULFILMENT","IPWirelessProductInstanceID":"NA","BillofMaterialID":"NA","AccessRole":"Primary","CONTEXT":"CUSTOMER","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","SKU":"100119211","SuspensionContext":"NA","CustomerFacingServiceId":"","ShippingRequired":"TRUE","IMSI":"","SERVICEPROFILE":"TABLET"},"code":"DMCAT_ProductSpecification_000263_Fulfilment","description":"Mobile Access_Fulfilment","endDate":"","guid":"fc8e7088-a0ba-6b6c-ef69-3e6b3d281a89","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","startDate":"","status":"Suspend","version":"1"},{"additionalAttributes":{"__targetSystem":"FULFILMENT","IPWirelessProductInstanceID":"NA","BillofMaterialID":"NA","AccessRole":"Primary","CONTEXT":"CUSTOMER","SKU":"100119211","MESSAGEBANK":"NA","CustomerFacingServiceId":"61473603212","IMSI":"","SERVICEPROFILE":"TABLET"},"attributes":{"__targetSystem":"FULFILMENT"},"code":"DMCAT_ProductSpecification_000420_Fulfilment","description":"Mobility_Fulfilment","endDate":"","guid":"7200c94d-ad78-0078-c8d3-b5c586d50313","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobility_Fulfilment","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000420","startDate":"","status":"Modified","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","value":"250","unitofMeasure":"GB","type":"FairPlay Data","ocsProdID":"T22EM_MBB-L","billingSpecId":"BSUSG001_CB","billDescription":"Includes 250 GB Domestic Data"},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000637","description":"Mobility_Billing_DMCAT_Allowance_000637","endDate":"","guid":"ebba38ae-33c5-6b11-f8ce-50f6b74520fe","includeBilling":false,"instanceId":"","metadata":{},"name":"420_AW_637","productConfigurationId":"a3T2O000000N9AFUA0","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000420_Billing_Allowance_000637_7","startDate":"","status":"Created","version":"1"}]}');
        update att;
        DisconnectionRequest__c dr = new DisconnectionRequest__c(BillingCycleDay__c='1',Disconnect_Type__c='Port Out',E2ECorrelationID__c='3247862345-43543-2342',MSISDN__c='61474839046',Originating_System__c='TRAMAS',Requested_DateTime__c=String.valueOf(datetime.now()),Subscription__c=testRecord.id);
        Test.startTest();
        insert dr;
        
        String tNowCaseRef='TCN123456789';
        List<csord__Order__c> ord = OrderGeneratorUtil.generateOrderForScenarioType(new List<String> {testRecord.id}, testRecord.csord__Account__c,System.Label.PortOut,tNowCaseRef);
        Test.stopTest(); 
        String shippingRequired = 'FALSE';
        Attachment attUpdated = [SELECT Id,body,Name,ParentID FROM Attachment WHERE id = :att.id];
        
        List<Object> lstSpecifications = new List<Object>();
        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(attUpdated.body.toString());
        lstSpecifications = (List<Object>)results.get('specifications');
        for (Object specification : lstSpecifications) {
            //fetch the attributes block in the specs
            Map<String, Object> specificationAttributes = (Map<String, Object>)specification;
            //fetch only the simple attributes
            Map<String,Object> attributesMap = (Map<String,Object>)specificationAttributes.get('additionalAttributes');
            //iterate over the simple attributes
            for(String atrributeattName: attributesMap.keyset()){
                String tempValue1 = '';
                //check ShippingRequired flag set to flase.
                if(atrributeattName.contains('ShippingRequired')){
                    tempValue1 = (String)JSON.deserialize(JSON.serialize(attributesMap.get(atrributeattName)), String.class);
                    //filter and populate the list of deserialized specs
                   system.debug('tempValue1'+tempValue1);
                   shippingRequired = tempValue1;
                }
            }
        }
        System.assertEquals('FALSE', shippingRequired);
        system.assertEquals(1, testRecord.orderversion__c);
    }  
    
}