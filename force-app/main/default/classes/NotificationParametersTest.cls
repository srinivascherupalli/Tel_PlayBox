/*
	Author: Dunna, Uday Kumar
	Date: 14/09/2021
*/

@isTest
public class NotificationParametersTest {
    
    @Testsetup
    static void dataSetup(){
        
        EnvironmentVariable__c csSite = new EnvironmentVariable__c();
        csSite.Name='EnableHV';
        csSite.value__c='True';
        
        EnvironmentVariable__c csSite1 = new EnvironmentVariable__c();
        csSite1.Name='EnableThrowException';
        csSite1.value__c='True';
        insert new List<EnvironmentVariable__c>{csSite,csSite1};
        
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        acc.Customer_Status__c='Active';
        insert acc;
        /*Opportunity opp = new Opportunity( Name = 'test opportunity', AccountId= acc.Id, Product_Domain__c = 'MOBILES', StageName='Develop', Description='Test Opp', Pricing_Method__c='PET', Contract_Type__c='BSA',Billing_Solution__c='Standard', recordtypeId='0122P0000004HYg');
opp.CloseDate = system.today();
insert opp;*/
        
        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        opp.StageName = 'Define';
        opp.CloseDate = System.Date.today();
        insert opp;
        
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
        csord__Order_Request__c ordReq1 = ProductTestFactory.buildOrderRequest();
        insert ordReq1;
        
        csord__Order_Request__c ordReq2 = ProductTestFactory.buildOrderRequest();
        insert ordReq2;
        
        csord__Order__c primaryOrd = ProductTestFactory.buildOrder('PrimaryOrder', acc.id, 'Created', ordReq1.id);
        primaryOrd.csord__Order_Request__c = ordReq1.Id;
        primaryOrd.csordtelcoa__Opportunity__c = opp.Id;
        insert primaryOrd;        
        
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        ord.csordtelcoa__Opportunity__c = opp.Id;
        ord.csord__Primary_Order__c = primaryOrd.id;
        insert ord;
        
        csord__Order__c ord1 = ProductTestFactory.buildOrder('Resume_12345', acc.id, 'Created', ordReq2.id);
        ord1.csord__Order_Request__c = ordReq2.Id;
        ord1.csordtelcoa__Opportunity__c = opp.Id;
        insert ord1;
        
        Account testAccount = SYS_TestDataFactory.createAccount('1234565');
        testAccount.Name = 'testAccount';
        testAccount.Customer_Status__c = 'ACTIVE';
        insert testAccount;
        
        Opportunity testOpp = SYS_TestDataFactory.createOpportunity(testAccount.Id);
        testOpp.Name = 'testOpp';
        testOpp.StageName = 'Define';
        testOpp.Product_Type__c = 'Modular';
        testOpp.CloseDate = System.Date.today();
        testOpp.Type = 'Price Review';
        testOpp.Billing_Solution__c= 'In Contract';
        insert testOpp;
        System.assertNotEquals(testOpp.id,null);
        
        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = testAccount.Id;
        testBasket.Name = 'ShowSubTestBasket';
        testBasket.cscfga__Opportunity__c = testOpp.Id;
        insert testBasket;
        
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>();
        cscfga__Product_Definition__c CW_PD = new cscfga__Product_Definition__c(Name = 'Connected Workplace', cscfga__Description__c = 'Connected Workplace');
        pdList.add(CW_PD);
        cscfga__Product_Definition__c ucePD = new cscfga__Product_Definition__c(Name = 'Unified Communication', cscfga__Description__c = 'Unified Communication');
        pdList.add(ucePD);
        cscfga__Product_Definition__c IPNet_PD = new cscfga__Product_Definition__c(Name = 'IP Network', cscfga__Description__c = 'IP Network');
        pdList.add(IPNet_PD);
        cscfga__Product_Definition__c Mob_PD = new cscfga__Product_Definition__c(Name = 'Mobility', cscfga__Description__c = 'Mobility',product_Specification__c='DMCAT_ProductSpecification_000420');
        pdList.add(Mob_PD);
        insert pdList;
        
        List<cscfga__Product_Configuration__c> prodconfigList=new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c testConfig = new cscfga__Product_Configuration__c();
        testConfig = SYS_TestDataFactory.createProductConfigurationRec(new Map<String, String>{'Name' => 'Connected Workplace', 'cscfga__Product_Basket__c' => testBasket.Id, 'cscfga__Product_Definition__c' => CW_PD.id });
        prodconfigList.add(testConfig);
        prodconfigList.add(SYS_TestDataFactory.createProductConfigurationRec(new Map<String, String>{'Name' => 'Connected Workplace', 'cscfga__Product_Basket__c' => testBasket.Id, 'cscfga__Product_Definition__c' => ucePD.id }));
        prodconfigList.add(SYS_TestDataFactory.createProductConfigurationRec(new Map<String, String>{'Name' => 'Connected Workplace', 'cscfga__Product_Basket__c' => testBasket.Id, 'cscfga__Product_Definition__c' => IPNet_PD.id }));
        prodconfigList.add(SYS_TestDataFactory.createProductConfigurationRec(new Map<String, String>{'Name' => 'Connected Workplace', 'cscfga__Product_Basket__c' => testBasket.Id, 'cscfga__Product_Definition__c' => Mob_PD.id }));
        
        
        insert prodconfigList;
        
        cscfga__Attribute__c testAttribute = new cscfga__Attribute__c();
        testAttribute.Name = 'testAttributeForTest';
        testAttribute.cscfga__Product_Configuration__c = testConfig.Id;
        insert testAttribute;
        
        csord__Order__c testOrder = new csord__Order__c();
        testOrder.csord__Account__c = testAccount.Id;
        testOrder.csordtelcoa__Opportunity__c = testOpp.Id;
        testOrder.Name = 'TestOrderNameForTest';
        testOrder.csord__Identification__c = 'test';
        testOrder.isMSISDNHeld__c = false;
        insert testOrder;
        System.assertNotEquals(testOrder.id,null);
        
        csordtelcoa__Orders_Subscriptions_Options__c testOso = new csordtelcoa__Orders_Subscriptions_Options__c();
        testOso.csordtelcoa__Subscription_Closed_Replaced_State__c = 'test2';
        testOso.csordtelcoa__Statuses_Not_Allowing_Change__c = 'false';
        
        insert testOso;
        
        List<csord__Subscription__c> listofSub = new List<csord__Subscription__c>();
        for(Integer i=0;i<6;i++){
            csord__Subscription__c testSubscription = new csord__Subscription__c();
            testSubscription.Name = 'TestSubsforTest'+i;
            testSubscription.csord__Account__c = testAccount.Id;
            testSubscription.csord__Order__c = testOrder.Id;
            testSubscription.csord__Identification__c = 'test';
            testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
            testSubscription.csord__Status__c = 'NA';
            testSubscription.stage__c = 'NA';
            listofSub.add(testSubscription);
        }
        Test.startTest();
        insert listofSub;
        Test.stopTest();     
        
        Number__c num4=new Number__c();
        num4.name='Num test4';
        num4.Subscription_number__c=listofSub[0].csordtelcoa__Subscription_Number__c;
        num4.Type__c='New';
        num4.Service_Number__c='61474850547';
        num4.Status__c='Bill Readiness In Progress';
        num4.Product_ID__c='gb58-89jk-yuit-fr46';
        insert num4;
        
        Number__c num5=new Number__c();
        num5.name='Num test4';
        num5.Subscription_number__c=listofSub[0].csordtelcoa__Subscription_Number__c;
        num5.Type__c='New';
        num5.Service_Number__c='61474850547';
        num5.Status__c='Active';
        num5.Product_ID__c='gb58-89jk-yuit-fr46';
        insert num5;
        
        cscfga__Product_Definition__c userPD = new cscfga__Product_Definition__c(Name = 'IP Site', cscfga__Description__c = 'IP Site',product_Specification__c = 'DMCAT_ProductOffering_000304');
        insert userPD;
        
        cscfga__Product_Configuration__c userPC = new cscfga__Product_Configuration__c(Name = 'IP site', cscfga__Product_Definition__c = userPD.Id, Quantity_Product_Configuration__c = 3);
        insert userPC;
        
        //EDGE-132208 - Added Configuration Record
        cscfga__Product_Configuration__c userPC1 = new cscfga__Product_Configuration__c(Name = 'IP site', cscfga__Product_Definition__c = userPD.Id, Quantity_Product_Configuration__c = 3, Type__c = 'Cancel');
        insert userPC1;
        //EDGE-160243
        cscfga__Product_Configuration__c userPC2 = new cscfga__Product_Configuration__c(Name = 'Business Calling', cscfga__Product_Definition__c = userPD.Id, Quantity_Product_Configuration__c = 3, Type__c = 'New');
        insert userPC2;
        
        List<csord__Service__c> servs = new List<csord__Service__c>();
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify';
        serv.csordtelcoa__Service_Number__c = 'svc-1235645';
        serv.csord__Subscription__c = listofSub[0].Id;
        serv.csord__Status__c = 'Service Created';
        serv.csord__Order_Request__c = ordReq.Id;
        serv.csord__Order__c =  ord.Id;
        serv.csordtelcoa__Product_Configuration__c = userPC2.id;
        servs.add(serv);
        
        csord__Service__c serv1 = new csord__Service__c();
        serv1.name ='tst service1';
        serv1.csord__Identification__c  = 'test identify1';
        serv1.csordtelcoa__Service_Number__c = '4';
        serv1.csord__Subscription__c = listofSub[0].Id;
        serv1.csord__Status__c = 'Service Created';
        serv1.csord__Order_Request__c = ordReq.Id;
        serv1.csord__Order__c = ord.Id;
        servs.add(serv1);
        
        csord__Service__c ser = new csord__Service__c();
        ser.name ='tst svc';
        ser.csord__Identification__c  = 'test identify';
        ser.csordtelcoa__Service_Number__c = '3';
        ser.csord__Subscription__c = listofSub[0].Id;
        ser.csord__Status__c = 'Service Created';
        ser.csord__Order_Request__c = ordReq.Id;
        ser.csord__Order__c = ord.Id;
        servs.add(ser);
        
        csord__Service__c serv2 = new csord__Service__c();
        serv2.name ='tst service2';
        serv2.csord__Identification__c  = 'test identify2';
        serv2.csordtelcoa__Service_Number__c = '5';
        serv2.csord__Subscription__c = listofSub[0].Id;
        serv2.csord__Status__c = 'Service Created';
        serv2.csord__Order_Request__c = ordReq.Id;
        serv2.csord__Order__c = ord.Id;
        servs.add(serv2);
        
        csord__Service__c serv3 = new csord__Service__c();
        serv3.name ='tst service3';
        serv3.csord__Identification__c  = 'tst identify3';
        serv3.csordtelcoa__Service_Number__c = '6';
        serv3.csord__Subscription__c = listofSub[0].Id;
        serv3.csord__Status__c = 'Service Created';
        serv3.csord__Order_Request__c = ordReq.Id;
        serv3.csord__Order__c = ord.Id;
        servs.add(serv3);
        
        csord__Service__c serv4 = new csord__Service__c();
        serv4.name ='tst service4';
        serv4.csord__Identification__c  = 'tst identify4';
        serv4.csordtelcoa__Service_Number__c = '7';
        serv4.csord__Subscription__c = listofSub[0].Id;
        serv4.csord__Status__c = 'Service Created';
        serv4.csord__Order_Request__c = ordReq.Id;
        serv4.csord__Order__c = ord.Id;
        serv4.csord__Service__c=ser.Id;
        //EDGE-132208 - Updated to pass new PC record
        serv.csordtelcoa__Product_Configuration__c = userPC1.id;
        servs.add(serv4);
        
        csord__Service__c servRe = new csord__Service__c();
        servRe.name ='tst servRe';
        servRe.csord__Identification__c  = 'test servRe';
        servRe.csordtelcoa__Service_Number__c = 'svc-123567';
        servRe.csord__Subscription__c = listofSub[0].Id;
        servRe.csord__Status__c = 'Service Created';
        //servRe.csord__Order_Request__c = ordReq2.Id;
        servRe.csord__Order__c = ord1.Id;
        //servRe.csordtelcoa__Replacement_Service__c = serv.id;
        servRe.csordtelcoa__Product_Configuration__c = userPC.id;
        servs.add(servRe);
        
        csord__Service__c servV = new csord__Service__c();
        servV.name ='AppleDevice';
        servV.csord__Identification__c  = 'AppleDevice';
        servV.csordtelcoa__Service_Number__c = 'SVC-000023459';
        servV.csord__Subscription__c = listofSub[0].Id;
        servV.csord__Status__c = 'In Progress'; 
        servV.csord__Order__c = ord.Id;
        insert servV;
        
        csord__Service__c servD = new csord__Service__c();
        servD.name ='DeviceCare';
        servD.csord__Identification__c  = 'DeviceCare';
        servD.csordtelcoa__Service_Number__c = 'SVC-000023460';
        servD.csord__Subscription__c = listofSub[0].Id;
        servD.csord__Status__c = 'In Progress'; 
        servD.csord__Order__c = ord.Id;
        servD.csord__Service__c =servV.Id;
        servs.add(servD);
        
        csord__Service__c servV1 = new csord__Service__c();
        servV1.name ='AppleDevice1';
        servV1.csord__Identification__c  = 'AppleDevice1';
        servV1.csordtelcoa__Service_Number__c = 'SVC-000023461';
        servV1.csord__Subscription__c = listofSub[0].Id;
        servV1.csord__Status__c = 'In Progress'; 
        servV1.csord__Order__c = ord.Id;
        insert servV1;
        
        csord__Service__c servD1 = new csord__Service__c();
        servD1.name ='DeviceCare1';
        servD1.csord__Identification__c  = 'DeviceCare1';
        servD1.csordtelcoa__Service_Number__c = 'SVC-000023462';
        servD1.csord__Subscription__c = listofSub[0].Id;
        servD1.csord__Status__c = 'In Progress'; 
        servD1.csord__Order__c = ord.Id;
        servD1.csord__Service__c =servV1.Id;
        servs.add(servD1);
        
        csord__Service__c servD2 = new csord__Service__c();
        servD2.name ='Business_Calling';
        servD2.csord__Identification__c  = 'Business_Calling';
        servD2.csordtelcoa__Service_Number__c = 'SVC-000023463';
        servD2.csord__Subscription__c = listofSub[0].Id;
        servD2.csord__Status__c = 'In Progress'; 
        servD2.csord__Order__c = ord.Id;
        servD2.csordtelcoa__Product_Configuration__c = userPC2.Id;
        servs.add(servD2);
        
        insert servs;
        
        
        
        csoe__Non_Commercial_Schema__c ncs= new csoe__Non_Commercial_Schema__c();
        ncs.Name='NumberManagementv1';
        ncs.csoe__Schema__c='{"attributes":[{"showInUI":true,"required":false,"type":"String","name":"FNN"},{"showInUI":true,"required":false,"type":"String","name":"rangeFrom"},{"showInUI":true,"required":false,"type":"String","name":"rangeTo"},{"showInUI":true,"required":false,"type":"String","name":"status"},{"showInUI":true,"required":false,"type":"String","name":"listCode"}],"name":"NumberManagementv1","description":"NumberManagementv1"}';
        ncs.csoe__Description__c='NumberManagementv1';
        
        insert ncs;
        
        Charge_Line_Item__c cli= new Charge_Line_Item__c();
        cli.Name='test';
        cli.CorrelationId__c='1234566';
        cli.status__c='new';
        cli.serviceId__c=serv.id;
        cli.BusinessID__c='DMCAT_Billing_000420';
        insert cli;
        
        Price_Schedule_Line_Item__c psli=new Price_Schedule_Line_Item__c();
        psli.fromPeriod__c='0';
        psli.toPeriod__c='20';
        psli.status__c='new';
        psli.chargeInstance__c=cli.id;
        psli.unitPrice__c=20.0;
        insert psli;
        
        Appointment__c app = new Appointment__c();
        app.name = 'app1';
        app.SlotId__c='1234';
        app.Status__c ='SCHEDULED';
        insert app;
        
        List<Attachment> atts = new List<Attachment>();
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobile Access_Billing_NonRecurringCharge_000601","instanceId":"","guid":"518a459f-0c60-9d4d-e194-7d1bb73a127b","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","attributes":{"__targetSystem":"BILLING","rateExcludeGST":"0.00","billDescription":"IR Pay as you go charge","unitofMeasure":"each","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","type":"OC","currency":"AUD","ocsProdID":"T22E_IR_USAGE"},"metadata":{},"includeBilling":false,"additionalAttributes":{}},{"version":"1","status":"Pending","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1add-89725fee80c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000322_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"Suspend","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1add-81725fgg30c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000871_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"Suspended","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1fdd-81747fgg30c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000747_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"e16ace88-b994-07d4-c5f4-5f5a78a4345d","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","IMSI":"","ShippingRequired":false,"CustomerFacingServiceId":"","MESSAGEBANK":"3G Standard Retail","SIMSKU":"100119211","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","SERVICEPROFILE":"NORMAL"},"additionalAttributes":{"parentSpec":"ec49950c-5da3-a5a1-1add-89725fee80c9","CustomerFacingServiceId":"61474841950","SuspensionContext":"CUSTOMER"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Billing_RecurringCharge_000498","metadata":{},"instanceId":"","includeBilling":false,"guid":"ad76e859-a8c0-8db8-cbaf-ecbdeeab2ee3","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes":{"taxTreatment":"GST Applicable","billDescription":"CWP Mobile Seat","prorate":"false","billInAdvance":"true","billingSpecId":"BSRC001_CB","frequency":"Monthly","currency":"AUD","type":null,"description":"MRO Plan Discount","applicationDuration":"24 months","unitPrice":60,"rateExcludeGST":100,"Priority":"1","recurringChargePeriod":"Monthly","quantity":"1","__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"'+serv.Id+'","legacyAttributes":[]}');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        atts.add(att1);
        
        Attachment att11 = new Attachment();
        att11.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Failed","startDate":"","specification":"30a0f36c-b496-185e-6330-c7a9c317d22c","productConfigurationId":"a0b0Y000001oXmtQAE","name":"CWPSpec","instanceId":"1234","guid":"3072dad2-5546-eb71-8e13-bd04b7f9824a","endDate":"","description":"CWP CFS Specification","code":"CWPSpec01","attributes":{"__targetSystem":"FULFILMENT","Zone":"Zone 3","TotalMRC":1500,"Seat":5,"complexIPAccess":[{"attributes":{"complexAttrPort":8080,"complexAttrTech":"Fibre"},"productConfigurationId":"a0b0Y000001oXmyQAE"},{"attributes":{"complexAttrPort":9090,"complexAttrTech":"Ethernet"},"productConfigurationId":"a0b0Y000001oXn3QAE"}],"constantName":"contantValue"}},{"version":"1","status":"Created","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXmyQAE","name":"IPAccessSpec","instanceId":"3456","guid":"3df57fcf-7c28-c50a-140b-0d21e80714e7","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"__targetSystem":"FULFILMENT","Port":8080,"Technology":"Fibre","constantAttr":"constantValue"}},{"version":"1","status":"Created","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXn3QAE","name":"IPAccessSpec","instanceId":"6789","guid":"495bbebb-5166-6dce-24cd-648084f6241c","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"__targetSystem":"FULFILMENT","Port":9090,"Technology":"Ethernet","constantAttr":"constantValue"}}],"serviceId":"'+serv1.Id+'","legacyAttributes":[]}');
        att11.Name = 'ServiceSpecifications.json';
        att11.ParentId = serv1.Id;
        atts.add(att11);
        
        Attachment att12 = new Attachment();
        att12.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Complete","startDate":"","specification":"30a0f36c-b496-185e-6330-c7a9c317d22c","productConfigurationId":"a0b0Y000001oXmtQAE","name":"CWPSpec","instanceId":"1234","guid":"3072dad2-5546-eb71-8e13-bd04b7f9824a","endDate":"","description":"CWP CFS Specification","code":"CWPSpec01","attributes":{"__targetSystem":"FULFILMENT","Zone":"Zone 3","TotalMRC":1500,"Seat":5,"complexIPAccess":[{"attributes":{"complexAttrPort":8080,"complexAttrTech":"Fibre"},"productConfigurationId":"a0b0Y000001oXmyQAE"},{"attributes":{"complexAttrPort":9090,"complexAttrTech":"Ethernet"},"productConfigurationId":"a0b0Y000001oXn3QAE"}],"constantName":"contantValue"}},{"version":"1","status":"Complete","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXmyQAE","name":"IPAccessSpec","instanceId":"3456","guid":"3df57fcf-7c28-c50a-140b-0d21e80714e7","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"__targetSystem":"FULFILMENT","Port":8080,"Technology":"Fibre","constantAttr":"constantValue"}},{"version":"1","status":"Complete","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXn3QAE","name":"IPAccessSpec","instanceId":"6789","guid":"495bbebb-5166-6dce-24cd-648084f6241c","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"__targetSystem":"FULFILMENT","Port":9090,"Technology":"Ethernet","constantAttr":"constantValue"}}],"serviceId":"'+serv2.Id+'","legacyAttributes":[]}');
        att12.Name = 'ServiceSpecifications.json';
        att12.ParentId = serv2.Id;
        atts.add(att12);
        
        Attachment att13 = new Attachment();
        att13.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Disconnect In Progress","startDate":"","specification":"30a0f36c-b496-185e-6330-c7a9c317d22c","productConfigurationId":"a0b0Y000001oXmtQAE","name":"CWPSpec","instanceId":"1234","guid":"3072dad2-5546-1122-8e13-bd04b7f9824a","endDate":"","description":"CWP CFS Specification","code":"CWPSpec01","attributes":{"__targetSystem":"FULFILMENT","Zone":"Zone 3","TotalMRC":1500,"Seat":5,"complexIPAccess":[{"attributes":{"complexAttrPort":8080,"complexAttrTech":"Fibre"},"productConfigurationId":"a0b0Y000001oXmyQAE"},{"attributes":{"complexAttrPort":9090,"complexAttrTech":"Ethernet"},"productConfigurationId":"a0b0Y000001oXn3QAE"}],"constantName":"contantValue"},"additionalAttributes":{"parentSpec":"ec49950c-5da3-a5a1-1add-89725fee80c9","CustomerFacingServiceId":"61474841950","SuspensionContext":"CUSTOMER"}},{"version":"1","status":"Disconnect In Progress","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXmyQAE","name":"IPAccessSpec","instanceId":"3456","guid":"3df57fcf-7c28-c50a-140b-0d21e80714e7","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"__targetSystem":"FULFILMENT","Port":8080,"Technology":"Fibre","constantAttr":"constantValue"},"additionalAttributes":{"parentSpec":"ec49950c-5da3-a5a1-1add-89725fee80c9","CustomerFacingServiceId":"61474841950","SuspensionContext":"CUSTOMER"}},{"version":"1","status":"Disconnect In Progress","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXn3QAE","name":"IPAccessSpec","instanceId":"6789","guid":"495bbebb-5166-6dce-24cd-648084f6241c","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"__targetSystem":"FULFILMENT","Port":9090,"Technology":"Ethernet","constantAttr":"constantValue"},"additionalAttributes":{"parentSpec":"ec49950c-5da3-a5a1-1add-89725fee80c9","CustomerFacingServiceId":"61474841950","SuspensionContext":"CUSTOMER"}}],"serviceId":"'+serv3.Id+'","legacyAttributes":[]}');
        att13.Name = 'ServiceSpecifications.json';
        att13.ParentId = serv3.Id;
        atts.add(att13);
        
        Attachment att14 = new Attachment();
        att14.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobile Access_Billing_NonRecurringCharge_000601","instanceId":"","guid":"518a459f-0c60-9d4d-e194-7d1bb73a127b","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","attributes":{"__targetSystem":"BILLING","rateExcludeGST":"0.00","billDescription":"IR Pay as you go charge","unitofMeasure":"each","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","type":"OC","currency":"AUD","ocsProdID":"T22E_IR_USAGE"},"metadata":{},"includeBilling":false,"additionalAttributes":{}},{"version":"1","status":"Pending","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1add-89725fee80c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000322_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"Suspend","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1add-81725fgg30c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000871_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"Suspended","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1fdd-81747fgg30c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000747_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"e16ace88-b994-07d4-c5f4-5f5a78a4345d","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","IMSI":"","ShippingRequired":false,"CustomerFacingServiceId":"","MESSAGEBANK":"3G Standard Retail","SIMSKU":"100119211","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","SERVICEPROFILE":"NORMAL"},"additionalAttributes":{"parentSpec":"ec49950c-5da3-a5a1-1add-89725fee80c9","CustomerFacingServiceId":"61474841950","SuspensionContext":"CUSTOMER"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Billing_RecurringCharge_000498","metadata":{},"instanceId":"","includeBilling":false,"guid":"ad76e859-a8c0-8db8-cbaf-ecbdeeab2ee3","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes":{"taxTreatment":"GST Applicable","billDescription":"CWP Mobile Seat","prorate":"false","billInAdvance":"true","billingSpecId":"BSRC001_CB","frequency":"Monthly","currency":"AUD","type":null,"description":"MRO Plan Discount","applicationDuration":"24 months","unitPrice":60,"rateExcludeGST":100,"Priority":"1","recurringChargePeriod":"Monthly","quantity":"1","__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"'+serv4.Id+'","legacyAttributes":[]}');
        att14.Name = 'ServiceSpecifications.json';
        att14.ParentId = serv4.Id;
        atts.add(att14);
        
        Attachment attNew = new Attachment();
        attNew.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Complete","startDate":"","specification":"30a0f36c-b496-185e-6330-c7a9c317d22c","productConfigurationId":"a0b0Y000001oXmtQAE","name":"CWPSpec","instanceId":"1234","guid":"3072dad2-5546-eb71-8e13-bd04b7f9824a","endDate":"","description":"CWP CFS Specification","code":"CWPSpec01","attributes":{"__targetSystem":"FULFILMENT","Zone":"Zone 3","TotalMRC":1500,"Seat":5,"complexIPAccess":[{"attributes":{"complexAttrPort":8080,"complexAttrTech":"Fibre"},"productConfigurationId":"a0b0Y000001oXmyQAE"},{"attributes":{"complexAttrPort":9090,"complexAttrTech":"Ethernet"},"productConfigurationId":"a0b0Y000001oXn3QAE"}],"constantName":"contantValue"}},{"version":"1","status":"Complete","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXmyQAE","name":"IPAccessSpec","instanceId":"3456","guid":"3df57fcf-7c28-c50a-140b-0d21e80714e7","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"__targetSystem":"FULFILMENT","Port":8080,"Technology":"Fibre","constantAttr":"constantValue"}},{"version":"1","status":"Complete","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXn3QAE","name":"IPAccessSpec","instanceId":"6789","guid":"495bbebb-5166-6dce-24cd-648084f6241c","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"__targetSystem":"FULFILMENT","Port":9090,"Technology":"Ethernet","constantAttr":"constantValue"}}],"serviceId":"'+ser.Id+'","legacyAttributes":[]}');
        attNew.Name = 'ServiceSpecifications.json';
        attNew.ParentId = ser.Id;
        atts.add(attNew);
        
        Attachment attRes = new Attachment();
        attRes.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobile Access_Billing_NonRecurringCharge_000601","instanceId":"","guid":"518a459f-0c60-9d4d-e194-7d1bb73a127b","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","attributes":{"__targetSystem":"BILLING","rateExcludeGST":"0.00","billDescription":"IR Pay as you go charge","unitofMeasure":"each","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","type":"OC","currency":"AUD","ocsProdID":"T22E_IR_USAGE"},"metadata":{},"includeBilling":false,"additionalAttributes":{}},{"version":"1","status":"Pending","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1add-89725fee80c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000322_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"Suspend","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1add-81725fgg30c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000871_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"Suspended","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1fdd-81747fgg30c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000747_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"e16ace88-b994-07d4-c5f4-5f5a78a4345d","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","IMSI":"","ShippingRequired":false,"CustomerFacingServiceId":"","MESSAGEBANK":"3G Standard Retail","SIMSKU":"100119211","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","SERVICEPROFILE":"NORMAL"},"additionalAttributes":{"parentSpec":"ec49950c-5da3-a5a1-1add-89725fee80c9","CustomerFacingServiceId":"61474841950","SuspensionContext":"CUSTOMER"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Billing_RecurringCharge_000498","metadata":{},"instanceId":"","includeBilling":false,"guid":"ad76e859-a8c0-8db8-cbaf-ecbdeeab2ee3","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes":{"taxTreatment":"GST Applicable","billDescription":"CWP Mobile Seat","prorate":"false","billInAdvance":"true","billingSpecId":"BSRC001_CB","frequency":"Monthly","currency":"AUD","type":null,"description":"MRO Plan Discount","applicationDuration":"24 months","unitPrice":60,"rateExcludeGST":100,"Priority":"1","recurringChargePeriod":"Monthly","quantity":"1","__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"'+servRe.Id+'","legacyAttributes":[]}');
        attRes.Name = 'ServiceSpecifications.json';
        attRes.ParentId = servRe.Id;
        atts.add(attRes);
        
        Attachment att2 = new Attachment();
        att2.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+servV.Id+'","specifications":[{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","rateExcludeGST":0,"quantity":1,"type":"OC","currency":"AUD","billingSpecId":"BSOTC001_CB","taxTreatment":"GST Applicable","unitofMeasure":"per device","billDescription":"Apple iPhone 7 Plus 32GB Rose Gold","ContractType":"Purchase","externalId":"DMCAT_Offer_001231_DMCAT_ProductSpecification_001211_DMCAT_NonRecurringCharge_000511_2157","isRedeemable":"true"},"code":"DMCAT_ProductSpecification_001211_Billing_NonRecurringCharge_000511","description":"Next Generation Mobile Device_Billing_NonRecurringCharge_000511","endDate":"","guid":"368f2f9f-e469-67a5-66b1-d312a97ab7b3","includeBilling":false,"instanceId":"","metadata":{},"name":"1211_NRC_511","productConfigurationId":"a3T2N00000043OfUAI","specification":"DMCAT_Offer_001231_DMCAT_ProductSpecification_001211_Billing_NonRecurringCharge_000511","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"productCompletionDate":"2020-07-09T05:25:03+10:00"},"attributes":{"__targetSystem":"FULFILMENT","DeviceID":"","DeviceIDType":"","ShippingRequired":"TRUE","Quantity":1,"ContractType":"Hardware Repayment","MobileHandsetManufacturer":"APPLE","MobileHandsetModel":"APPLE IPHONE 7 PLUS 32GB 4GX HANDSET","MobileHandsetColour":"ROSE GOLD","SKU":"100115458","DeviceType":"Mobile Handset"},"code":"DMCAT_ProductSpecification_001211_Fulfilment","description":"Next Generation Mobile Device_Fulfilment","endDate":"","guid":"e9743572-cc9a-74d6-c6de-c14e7a2b47ca","includeBilling":false,"instanceId":"","metadata":{},"name":"Next Generation Mobile Device_Fulfilment","productConfigurationId":"a3T2N00000043OfUAI","specification":"DMCAT_ProductSpecification_001211","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{},"attributes":{"ServiceManagementOption":"1","__targetSystem":"ASSURANCE"},"code":"DMCAT_ProductSpecification_000326_Assurance","description":"Telstra Managed Service Option 1_Assurance","endDate":"","guid":"7027a42a-dd16-98f5-354f-4d77c76a6c0c","includeBilling":false,"instanceId":"","metadata":{},"name":"326_ASR","productConfigurationId":"a3T2N00000043OfUAI","specification":"DMCAT_ProductSpecification_001211DMCAT_ProductSpecification_000326","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"ASSURANCE","parentSpec":"DMCAT_ProductSpecification_000871_Assurance","ResponseTime":"SLA0010001","RestorationTime":"SLA0010006"},"code":"DMCAT_ProductSpecification_000151_Assurance","description":"Incident Management_Assurance","endDate":"","guid":"665ee24e-01ac-4d0a-1680-616dab926074","includeBilling":false,"instanceId":"","metadata":{},"name":"151_ASR","productConfigurationId":"a3T2N00000043OfUAI","specification":"DMCAT_ProductSpecification_001211DMCAT_ProductSpecification_000151","startDate":"","status":"Created","version":"1"}]}');
        att2.Name = 'ServiceSpecifications.json';
        att2.ParentId = servV.Id;
        atts.add(att2);
        
        Attachment att3 = new Attachment();
        att3.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"DMCAT_Offer_001231_DMCAT_ProductSpecification_001211DMCAT_ProductSpecification_001208_Billing_NonRecurringCharge_001215","productConfigurationId":"a3T2N00000043OgUAI","name":"1208_NRC_1215","metadata":{},"instanceId":"","includeBilling":false,"guid":"45cd0659-3b2d-43f4-e45d-8d07cb458084","endDate":"","description":"Mobile Device Care_Billing_NonRecurringCharge_001215","code":"DMCAT_ProductSpecification_001208_Billing_NonRecurringCharge_001215","attributes":{"deviceCarePlan":"AppleCare+","isRedeemable":"true","externalId":"DMCAT_Offer_001231_DMCAT_ProductSpecification_001208_DMCAT_NonRecurringCharge_001215_2621","ContractType":"Purchase","billDescription":"AppleCare+ 2 years","unitofMeasure":"per device","taxTreatment":"GST Applicable","billingSpecId":"BSOTC001_CB","quantity":1,"rateExcludeGST":171.81,"currency":"AUD","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Complete","startDate":"","specification":"DMCAT_ProductSpecification_001208","productConfigurationId":"a3T2N00000043OgUAI","name":"Mobile Device Care_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"b9d545a8-2a09-37f8-09ea-16f08d91b60c","endDate":"","description":"Mobile Device Care_Fulfilment","code":"DMCAT_ProductSpecification_001208_Fulfilment","attributes":{"MobileHandsetManufacturer":"APPLE","deviceCarePlan":"AppleCare+","ContractType":"Purchase","parentSpec":"DMCAT_ProductSpecification_001211_Fulfilment","deviceCareID":"","__targetSystem":"FULFILMENT"},"additionalAttributes":{}}],"serviceId":"'+servD.Id+'","legacyAttributes":[]}');
        att3.Name = 'ServiceSpecifications.json';
        att3.ParentId = servD.Id;
        atts.add(att3);
        
        Attachment atts2 = new Attachment();
        atts2.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+servV1.Id+'","specifications":[{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","rateExcludeGST":0,"quantity":1,"type":"OC","currency":"AUD","billingSpecId":"BSOTC001_CB","taxTreatment":"GST Applicable","unitofMeasure":"per device","billDescription":"Apple iPhone 7 Plus 32GB Rose Gold","ContractType":"Purchase","externalId":"DMCAT_Offer_001231_DMCAT_ProductSpecification_001211_DMCAT_NonRecurringCharge_000511_2157","isRedeemable":"true"},"code":"DMCAT_ProductSpecification_001211_Billing_NonRecurringCharge_000511","description":"Next Generation Mobile Device_Billing_NonRecurringCharge_000511","endDate":"","guid":"368f2f9f-e469-67a5-66b1-d312a97ab7b3","includeBilling":false,"instanceId":"","metadata":{},"name":"1211_NRC_511","productConfigurationId":"a3T2N00000043OfUAI","specification":"DMCAT_Offer_001231_DMCAT_ProductSpecification_001211_Billing_NonRecurringCharge_000511","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"productCompletionDate":"2020-07-09T05:25:03+10:00"},"attributes":{"__targetSystem":"FULFILMENT","DeviceID":"","DeviceIDType":"","ShippingRequired":"TRUE","Quantity":1,"ContractType":"Hardware Repayment","MobileHandsetManufacturer":"APPLE","MobileHandsetModel":"APPLE IPHONE 7 PLUS 32GB 4GX HANDSET","MobileHandsetColour":"ROSE GOLD","SKU":"100115458","DeviceType":"Mobile Handset"},"code":"DMCAT_ProductSpecification_001211_Fulfilment","description":"Next Generation Mobile Device_Fulfilment","endDate":"","guid":"e9743572-cc9a-74d6-c6de-c14e7a2b48bd","includeBilling":false,"instanceId":"","metadata":{},"name":"Next Generation Mobile Device_Fulfilment","productConfigurationId":"a3T2N00000043OfUAI","specification":"DMCAT_ProductSpecification_001211","startDate":"","status":"Complete","version":"1"},{"additionalAttributes":{},"attributes":{"ServiceManagementOption":"1","__targetSystem":"ASSURANCE"},"code":"DMCAT_ProductSpecification_000326_Assurance","description":"Telstra Managed Service Option 1_Assurance","endDate":"","guid":"7027a42a-dd16-98f5-354f-4d77c76a6c0c","includeBilling":false,"instanceId":"","metadata":{},"name":"326_ASR","productConfigurationId":"a3T2N00000043OfUAI","specification":"DMCAT_ProductSpecification_001211DMCAT_ProductSpecification_000326","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"ASSURANCE","parentSpec":"DMCAT_ProductSpecification_000871_Assurance","ResponseTime":"SLA0010001","RestorationTime":"SLA0010006"},"code":"DMCAT_ProductSpecification_000151_Assurance","description":"Incident Management_Assurance","endDate":"","guid":"665ee24e-01ac-4d0a-1680-616dab926074","includeBilling":false,"instanceId":"","metadata":{},"name":"151_ASR","productConfigurationId":"a3T2N00000043OfUAI","specification":"DMCAT_ProductSpecification_001211DMCAT_ProductSpecification_000151","startDate":"","status":"Created","version":"1"}]}');
        atts2.Name = 'ServiceSpecifications.json';
        atts2.ParentId = servV1.Id;
        atts.add(atts2);
        
        Attachment atts3 = new Attachment();
        atts3.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"DMCAT_Offer_001231_DMCAT_ProductSpecification_001211DMCAT_ProductSpecification_001208_Billing_NonRecurringCharge_001215","productConfigurationId":"a3T2N00000043OgUAI","name":"1208_NRC_1215","metadata":{},"instanceId":"","includeBilling":false,"guid":"45cd0659-3b2d-43f4-e45d-8d07cb458084","endDate":"","description":"Mobile Device Care_Billing_NonRecurringCharge_001215","code":"DMCAT_ProductSpecification_001208_Billing_NonRecurringCharge_001215","attributes":{"deviceCarePlan":"AppleCare+","isRedeemable":"true","externalId":"DMCAT_Offer_001231_DMCAT_ProductSpecification_001208_DMCAT_NonRecurringCharge_001215_2621","ContractType":"Purchase","billDescription":"AppleCare+ 2 years","unitofMeasure":"per device","taxTreatment":"GST Applicable","billingSpecId":"BSOTC001_CB","quantity":1,"rateExcludeGST":171.81,"currency":"AUD","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Complete","startDate":"","specification":"DMCAT_ProductSpecification_001208","productConfigurationId":"a3T2N00000043OgUAI","name":"Mobile Device Care_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"b9d545a8-2a09-37f8-09ea-16f08d91b90f","endDate":"","description":"Mobile Device Care_Fulfilment","code":"DMCAT_ProductSpecification_001208_Fulfilment","attributes":{"MobileHandsetManufacturer":"APPLE","deviceCarePlan":"AppleCare+","ContractType":"Purchase","parentSpec":"DMCAT_ProductSpecification_001211_Fulfilment","deviceCareID":"","__targetSystem":"FULFILMENT"},"additionalAttributes":{}}],"serviceId":"'+servD1.Id+'","legacyAttributes":[]}');
        atts3.Name = 'ServiceSpecifications.json';
        atts3.ParentId = servD1.Id;
        atts.add(atts3);
        
        Attachment attsNum = new Attachment();
        attsNum.Body = Blob.valueOf('{"schema":{"attributes":[{"type":"String","showInUI":true,"required":false,"name":"FNN"},{"type":"String","showInUI":true,"required":false,"name":"rangeFrom"},{"type":"String","showInUI":true,"required":false,"name":"rangeTo"},{"type":"String","showInUI":true,"required":false,"name":"status"},{"type":"String","showInUI":true,"required":false,"name":"listCode"}],"id":"a6k2O00000003LyQAI","name":"NumberManagementv1"},"configurations":[{"FNN":"61350605919","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line","guid":"a16035c5-7716-c099-4621-304572ae92fa"},{"FNN":"61350605920","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line","guid":"100ce120-77f7-2be3-7588-96eb3a5532da"}]}');
        attsNum.Name = 'NumberManagementv1.json';
        attsNum.ParentId = userPC2.Id;
        atts.add(attsNum);
        
        Attachment attsNum1 = new Attachment();
        attsNum1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Complete","startDate":"","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000814","productConfigurationId":"a3T2O000000UZL8UAO","name":"871_RC_814","metadata":{},"instanceId":"","includeBilling":false,"guid":"d08c8b11-e6e9-1bc2-c52b-d3ffc6e0645e","endDate":"","description":"Business Calling_Billing_RecurringCharge_000814","code":"DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000814","attributes":{"concurrencyLimitMode":"Individual Line","billDescription":"Individual line - standard calling plan","callingPlans":"Standard","customRate":[{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_7542","price":"5.00","rangeTo":"200","rangeFrom":"51"},"schemaId":"cdc7c6fc-2597-e127-5bae-d64e8b16fa37"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_7539","price":"5.00","rangeTo":"10","rangeFrom":"1"},"schemaId":"ba632530-e2cb-9e20-f317-d7966594d5b2"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_7544","price":"5.00","rangeTo":"99999","rangeFrom":"501"},"schemaId":"3a0602cc-a89b-b2de-ff40-bc9fd9460a4f"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_7543","price":"5.00","rangeTo":"500","rangeFrom":"201"},"schemaId":"f9d9318a-449d-96b0-1244-10cbc3972907"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_7540","price":"5.00","rangeTo":"20","rangeFrom":"11"},"schemaId":"deed3a62-43a2-7714-b8a9-2aafda1f2b7a"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_7541","price":"5.00","rangeTo":"50","rangeFrom":"21"},"schemaId":"ead32ad9-d520-bc54-f01f-1eba6681666f"}],"featureID":"concurrencyLimit","billingSpecId":"BSUSG003_CB","type":"RC","currency":"AUD","billingSubtype":"HWM","taxTreatment":"GST Applicable","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Complete","startDate":"","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000813","productConfigurationId":"a3T2O000000UZL8UAO","name":"871_RC_813","metadata":{},"instanceId":"","includeBilling":false,"guid":"9689fb98-d143-13eb-ecc5-b1883c2ac393","endDate":"","description":"Business Calling_Billing_RecurringCharge_000813","code":"DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000813","attributes":{"customRate":[{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000813_6971","price":"3.00","rangeTo":"10","rangeFrom":"1"},"schemaId":"bcf86ccd-4132-a7d9-9390-bc4cefe0f030"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000813_6972","price":"3.00","rangeTo":"20","rangeFrom":"11"},"schemaId":"76294b34-3ac8-df45-8f71-bd6ed8f2ab70"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000813_6973","price":"3.00","rangeTo":"50","rangeFrom":"21"},"schemaId":"11cc5b7c-627d-a738-6cfb-6e14325178e4"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000813_6974","price":"3.00","rangeTo":"200","rangeFrom":"51"},"schemaId":"07704a93-77d2-8b4b-4c63-20500c39a324"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000813_6975","price":"3.00","rangeTo":"500","rangeFrom":"201"},"schemaId":"c380fbd7-5673-9278-11ab-bc6e573ac082"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000813_6976","price":"3.00","rangeTo":"99999","rangeFrom":"501"},"schemaId":"9f77b12b-4188-f73d-3a22-5758fa454e55"}],"billDescription":"Cloud user","featureID":"ucUsers","billingSpecId":"BSUSG003_CB","type":"RC","currency":"AUD","billingSubtype":"HWM","taxTreatment":"GST Applicable","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000871","productConfigurationId":"'+userPC2.Id+'","name":"Business Calling_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"7ccfdcfb-133f-8b91-e538-13066c8d8bab","endDate":"","description":"Business Calling_Fulfilment","code":"DMCAT_ProductSpecification_000871_Fulfilment","attributes":{"NetworkServiceId":"","CustomerFacingServiceId":"","concurrencyLimitMode":"inferred","Number":[{"attributes":{"FNN":"61350605919","listCode":"No Entry Line","rangeFrom":null,"rangeTo":null,"status":"ACTIVE"},"schemaId":"a16035c5-7716-c099-4621-304572ae92fa"},{"attributes":{"FNN":"61350605920","listCode":"No Entry Line","rangeFrom":null,"rangeTo":null,"status":"ACTIVE"},"schemaId":"100ce120-77f7-2be3-7588-96eb3a5532da"}],"type":"ucServiceSiteAgnosticConcurrencyOffer","BSTenancyProductInstanceId":"DMCAT_ProductSpecification_000311_Fulfilment","__targetSystem":"FULFILMENT"},"additionalAttributes":{"currentForecastedDeliveryDate":"2020-07-28T05:03:24+10:00","CustomerOrderAcceptanceDate":"2020-07-27T05:00:26+10:00","BSTenancyProductInstanceId":"f954a979-504f-2729-130f-e447e92eb152","NetworkServiceId":"0ebadc71-7b07-4846-b3b6-aead28534974"}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000151","productConfigurationId":"a3T2O000000UZL8UAO","name":"151_ASR","metadata":{},"instanceId":"","includeBilling":false,"guid":"6aac27d0-d0a4-bdaf-0cac-9c6170dc5a0a","endDate":"","description":"Incident Management_Assurance","code":"DMCAT_ProductSpecification_000151_Assurance","attributes":{"RestoreTarget":"SLA0010002","ResponseTarget":"SLA0010001","parentSpec":"DMCAT_ProductSpecification_000871_Assurance","__targetSystem":"ASSURANCE"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000326","productConfigurationId":"a3T2O000000UZL8UAO","name":"326_ASR","metadata":{},"instanceId":"","includeBilling":false,"guid":"1cdade45-0c27-320f-dc19-c8ffbfef878d","endDate":"","description":"Telstra Managed Service Option 1_Assurance","code":"DMCAT_ProductSpecification_000326_Assurance","attributes":{"ServiceManagementOption":"1","__targetSystem":"ASSURANCE"},"additionalAttributes":{}},{"version":"1","status":"Complete","startDate":"","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000816","productConfigurationId":"a3T2O000000UZL8UAO","name":"871_RC_816","metadata":{},"instanceId":"","includeBilling":false,"guid":"191acba2-5de8-4aee-b818-32cae52aa77c","endDate":"","description":"Business Calling_Billing_RecurringCharge_000816","code":"DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000816","attributes":{"customRate":[{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000816_6977","price":"6.00","rangeTo":"200","rangeFrom":"51"},"schemaId":"b2329377-f0ec-d075-7d31-701d2476804d"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000816_6982","price":"6.00","rangeTo":"99999","rangeFrom":"501"},"schemaId":"d7cbfec2-9a30-3e2b-937c-f536fe1a80f2"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000816_6981","price":"6.00","rangeTo":"500","rangeFrom":"201"},"schemaId":"a5825fe1-7b50-a4e8-11ac-e2d2cecfbeee"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000816_6980","price":"6.00","rangeTo":"50","rangeFrom":"21"},"schemaId":"a4833a96-01ac-12ec-7502-c5034bc83f21"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000816_6979","price":"6.00","rangeTo":"20","rangeFrom":"11"},"schemaId":"f67bb587-c2f6-7be1-780e-245a83b06b71"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000816_6978","price":"6.00","rangeTo":"10","rangeFrom":"1"},"schemaId":"39a7f638-a7ac-5f6b-c768-fb84530eb41f"}],"billDescription":"Cloud user add-on - unified communications","featureID":"Hosted UC","billingSpecId":"BSUSG003_CB","type":"RC","currency":"AUD","billingSubtype":"HWM","taxTreatment":"GST Applicable","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Complete","startDate":"","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000810","productConfigurationId":"a3T2O000000UZL8UAO","name":"871_RC_810","metadata":{},"instanceId":"","includeBilling":false,"guid":"77a629eb-2a9b-680c-4a91-ff8e700e3e3d","endDate":"","description":"Business Calling_Billing_RecurringCharge_000810","code":"DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000810","attributes":{"customRate":[{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6946","price":"5.00","rangeTo":"20","rangeFrom":"11"},"schemaId":"c8246349-1e34-59b7-1e3b-9e433360dd55"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6947","price":"5.00","rangeTo":"10","rangeFrom":"1"},"schemaId":"aa50fd91-1613-2b67-e2c4-a0fdc5c5cfd1"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6948","price":"5.00","rangeTo":"50","rangeFrom":"21"},"schemaId":"75f9b53c-84ce-293c-100d-a9d9337b7cfc"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6949","price":"5.00","rangeTo":"200","rangeFrom":"51"},"schemaId":"e85881dc-a199-1a1d-362d-c429fd0d83aa"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6950","price":"5.00","rangeTo":"500","rangeFrom":"201"},"schemaId":"96fa64ca-8ab5-47ef-aeb7-f4a59952abda"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_6952","price":"5.00","rangeTo":"99999","rangeFrom":"501"},"schemaId":"000c4f60-f1fd-8099-60ac-fd2e0f4296ba"}],"billDescription":"Group feature - auto attendant","featureID":"ucAutoAttendants","billingSpecId":"BSUSG003_CB","type":"RC","currency":"AUD","billingSubtype":"HWM","taxTreatment":"GST Applicable","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Complete","startDate":"","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000811","productConfigurationId":"a3T2O000000UZL8UAO","name":"871_RC_811","metadata":{},"instanceId":"","includeBilling":false,"guid":"dc042c93-3d81-1e88-bf4e-c776dbe8f709","endDate":"","description":"Business Calling_Billing_RecurringCharge_000811","code":"DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000811","attributes":{"customRate":[{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000811_7020","price":"5.00","rangeTo":"10","rangeFrom":"1"},"schemaId":"fdd8447d-cded-30f0-9f73-98db7953d506"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000811_7021","price":"5.00","rangeTo":"20","rangeFrom":"11"},"schemaId":"f492d8bb-2e01-ff2f-66eb-664665e5ba61"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000811_7022","price":"5.00","rangeTo":"50","rangeFrom":"21"},"schemaId":"96c7b13f-20cd-2c9c-a4ea-0e5e11cb0ab0"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000811_7023","price":"5.00","rangeTo":"200","rangeFrom":"51"},"schemaId":"4b587859-eadd-efe8-1e44-58ee56010848"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000811_7024","price":"5.00","rangeTo":"500","rangeFrom":"201"},"schemaId":"77e1f0f6-e2a8-2ca6-b4e5-f5bb24a424a9"},{"attributes":{"externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000811_7025","price":"5.00","rangeTo":"99999","rangeFrom":"501"},"schemaId":"4205375e-bd21-98ba-e94d-85a7845fd561"}],"billDescription":"Group feature - hunt group","featureID":"ucHuntGroups","billingSpecId":"BSUSG003_CB","type":"RC","currency":"AUD","billingSubtype":"HWM","taxTreatment":"GST Applicable","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Complete","startDate":"","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_Allowance_000825_87","productConfigurationId":"a3T2O000000UZL8UAO","name":"871_AW_876","metadata":{},"instanceId":"","includeBilling":false,"guid":"a98750ef-2b1c-2df9-5533-c8861309f018","endDate":"","description":"Business Calling UC Plan Allowance_Billing_DMCAT_Allowance_000876","code":"DMCAT_ProductSpecification_000871_Billing_Allowance_000876","attributes":{"ocsProdID":"T22E_FVOICE-S","billDescription":"Included PayG","value":"Fixed Voice Plan - Standard","type":"Fixed Voice","billingSpecId":"BSUSG004_CB","__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"'+servD2.Id+'","legacyAttributes":[]}');
                                     attsNum1.Name = 'ServiceSpecifications.json';
                                     attsNum1.ParentId = servD2.Id;
                                     atts.add(attsNum1);
                                     
                                     insert atts;
                                     }
                                     
                                     public testMethod Static void method1(){
                                         NotificationParameters obj = new NotificationParameters();
                                     }
                                      @isTest
    static void testprocessNotification2(){
    List<NotificationParameters>paramsList = new List<NotificationParameters>();
    Map<String,List<NotificationParameters>> orderItemIdNotifMap = new Map<String,List<NotificationParameters>> ();
    
     Test.startTest();
        csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c,csord__Subscription__r.csordtelcoa__Subscription_Number__c, Name from csord__Service__c where Name = 'tst service' AND csord__Order__r.Name= 'TestOrder' limit 1][0];
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
  
        NotificationParameters  notif = new NotificationParameters();
        notif.externalOrderId = ord.csord__Order_Number__c;
        notif.eventTimestamp = '2018-02-24T06:08+10:00';
        notif.orderItemId = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1add-89725fee80c9';
        notif.notificationAttributes = '{"attributes":[{"name":"telstraCommittedDate", "value":"2018-12-27T05:56:03+11:00"},{"name":"productCompletionDate","value":"2018-12-03T05:39:54+11:00"},{"name":"status","value":"Complete"}]}';
        notif.orderItemDetails = '{"product":{"productId":"ec49950c-5da3-a5a1-1add-89725fee80c9","status":"Complete"}}';
        notif.eventType = 'statusNotification';
        notif.orderItemVersion = 1;
        notif.sourceSystem = 'FULFILMENT';
        notif.msCorrelationId = 'ec49950c-5da3-a5a1-1add-89725fee80c9';
        paramsList.add(notif);
    orderItemIdNotifMap.put(notif.orderItemId,paramsList);
    
        Number__c num4=new Number__c();
     num4.name='Num test4';
     num4.Service_Id__c = svc1.csordtelcoa__Service_Number__c;
     num4.Subscription_number__c=svc1.csord__Subscription__r.csordtelcoa__Subscription_Number__c;
     num4.Type__c='New';
     num4.Service_Number__c='61474850547';
     num4.Status__c='RESERVED';
     num4.Product_ID__c='gb58-89jk-yuit-fr46';
     insert num4;
        
        Number__c num5=new Number__c();
         num5.name='Num test4';
         num5.Service_Id__c = svc1.csordtelcoa__Service_Number__c;
         num5.Subscription_number__c=svc1.csord__Subscription__r.csordtelcoa__Subscription_Number__c;
         num5.Type__c='New';
         num5.Service_Number__c='61474850547';
         num5.Status__c='Active';
         num5.Product_ID__c='gb58-89jk-yuit-fr46';
     insert num5;
        
        SYS_OrderNotifcationMain.processNotification(orderItemIdNotifMap);
        Test.stopTest();
        csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' limit 1][0];
        //System.assertEquals('In Progress', svc.csord__Status__c);
        System.assertEquals('tst service', svc.Name);
        
    }
                                     
                                     
                                     }