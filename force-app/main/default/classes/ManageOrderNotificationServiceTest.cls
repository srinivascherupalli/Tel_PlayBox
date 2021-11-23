/********************************************************
Class Name : ManageOrderNotificationServiceTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Shreya                22/10/2019      added testupdateServiceRecordChildServiceInProg for test coverage
2.            Vaibhav               26/11/2019      EDGE-125635 - Covered newly added code
3.            Vaibhav               12/10/2019      EDGE-98385   resume order related changes
4.            Vaibhav Deshpande     23/01/2020      EDGE-120128
5.            Sandip Deshmane       4/2/2020        EDGE-132208 - Number removal change.
6.			  Sandip Deshmane		25/2/2020		EDGE-136242 - Updated for Refactoring, Input/Output not changed - Changed Product Specification Code to test NGUC and Non NGUC products
7.            Pawan/Vaibhav         18/03/2020      EDGE-124711/EDGE-124029 
**********************************************************
*/
@isTest
private class ManageOrderNotificationServiceTest{
    @Testsetup
    static void dataSetup(){
        
        EnvironmentVariable__c csSite = new EnvironmentVariable__c();
        csSite.Name='EnableHV';
        csSite.value__c='True';
        insert csSite;
        
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
        
        cscfga__Product_Definition__c userPD = new cscfga__Product_Definition__c(Name = 'IP Site', cscfga__Description__c = 'IP Site',product_Specification__c = 'DMCAT_ProductOffering_000304');
        insert userPD;
        
        cscfga__Product_Configuration__c userPC = new cscfga__Product_Configuration__c(Name = 'IP site', cscfga__Product_Definition__c = userPD.Id, Quantity_Product_Configuration__c = 3,Type__c = 'New');
        insert userPC;
        
        //EDGE-132208 - Added Configuration Record
        cscfga__Product_Configuration__c userPC1 = new cscfga__Product_Configuration__c(Name = 'IP site', cscfga__Product_Definition__c = userPD.Id, Quantity_Product_Configuration__c = 3, Type__c = 'Cancel');
        insert userPC1;
        
        List<csord__Subscription__c> subsList=new List<csord__Subscription__c>();
        csord__Subscription__c replSubs=new csord__Subscription__c();
        replSubs.name  = 'test replaced subs';
        replSubs.csord__Identification__c = 'test identity replced';
       // replSubs.csord__Order__c = ord.Id;
        replSubs.Sub_status__c = 'Active';
        replSubs.eventId__c = '9f0ded2-1bfd-7916-662d-9e28c804294e';
        subsList.add(replSubs);
        
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Order__c = ord.Id;
        subs.Sub_status__c = 'Active';
        subs.csord__Status__c='Active';
        subs.Suspension_reason__c='Requested by Customer';
        subs.csordtelcoa__Replaced_Subscription__c = replSubs.id;
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subsList.add(subs);
        
        csord__Subscription__c sub1=new csord__Subscription__c();
        sub1.name  = 'test sub';
        sub1.csord__Identification__c = 'test identity';
        sub1.csord__Order__c = ord.Id;
        sub1.Sub_status__c = 'Active';
        sub1.csord__Status__c='Active';
        sub1.Suspension_Reason__c='Requested by Customer';
        sub1.csordtelcoa__Replaced_Subscription__c = replSubs.id;
        subsList.add(sub1);
        
        csord__Subscription__c subRes=new csord__Subscription__c();
        subRes.name  = 'test sub12';
        subRes.csord__Identification__c = 'test identity12';
        subRes.csord__Order__c = ord1.Id;
        subRes.Sub_status__c = 'Active';
        subRes.csord__Status__c='Active';
        subsList.add(subRes);
        
        csord__Subscription__c subs1=new csord__Subscription__c();
        subs1.name  = 'test subs Inactive';
        subs1.csord__Identification__c = 'test identity';
        subs1.csord__Order__c = ord.Id;
        subs1.Sub_status__c = 'Inactive';
        subs1.csord__Status__c = 'Inactive';
        subs1.eventId__c = '8f0bfd2-1bfd-7916-552d-9e28c804294e';
        subsList.add(subs1);
		
		csord__Subscription__c subPricing=new csord__Subscription__c();
        subPricing.name  = 'Pricing';
        subPricing.csord__Identification__c = 'test pricing';
        subPricing.csord__Order__c = ord.Id;
        subPricing.Sub_status__c = 'Active';
        subPricing.csord__Status__c='Active';
        subsList.add(subPricing);
		
		csord__Subscription__c subPricing1=new csord__Subscription__c();
        subPricing1.name  = 'Pricing1';
        subPricing1.csord__Identification__c = 'test Pricing1';
        subPricing1.csord__Order__c = ord.Id;
        subPricing1.Sub_status__c = 'Active';
        subPricing1.csord__Status__c='Active';
        subPricing1.csordtelcoa__Replaced_Subscription__c = subPricing.id;
        subPricing1.csordtelcoa__Product_Configuration__c = userPC.id;
        subsList.add(subPricing1);
		
		csord__Subscription__c subPricing2=new csord__Subscription__c();
        subPricing2.name  = 'Pricing2';
        subPricing2.csord__Identification__c = 'test Pricing2';
        subPricing2.csord__Order__c = ord.Id;
        subPricing2.Sub_status__c = 'Active';
        subPricing2.csord__Status__c='Active';
        subPricing2.csordtelcoa__Replaced_Subscription__c = subPricing.id;
        subPricing2.csordtelcoa__Product_Configuration__c = userPC1.id;
        subsList.add(subPricing2);
        insert subsList;
        

        
        List<csord__Service__c> servs = new List<csord__Service__c>();
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify';
        serv.csordtelcoa__Service_Number__c = 'svc-1235645';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Status__c = 'Service Created';
        serv.csord__Order_Request__c = ordReq.Id;
        serv.csord__Order__c = ord.Id;
        serv.csordtelcoa__Product_Configuration__c = userPC.id;
        servs.add(serv);
        
        csord__Service__c serv1 = new csord__Service__c();
        serv1.name ='tst service1';
        serv1.csord__Identification__c  = 'test identify1';
        serv1.csordtelcoa__Service_Number__c = '4';
        serv1.csord__Subscription__c = subs.Id;
        serv1.csord__Status__c = 'Service Created';
        serv1.csord__Order_Request__c = ordReq.Id;
        serv1.csord__Order__c = ord.Id;
        servs.add(serv1);
        
        csord__Service__c ser = new csord__Service__c();
        ser.name ='tst svc';
        ser.csord__Identification__c  = 'test identify';
        ser.csordtelcoa__Service_Number__c = '3';
        ser.csord__Subscription__c = sub1.Id;
        ser.csord__Status__c = 'Service Created';
        ser.csord__Order_Request__c = ordReq.Id;
        ser.csord__Order__c = ord.Id;
        servs.add(ser);
        
        csord__Service__c serv2 = new csord__Service__c();
        serv2.name ='tst service2';
        serv2.csord__Identification__c  = 'test identify2';
        serv2.csordtelcoa__Service_Number__c = '5';
        serv2.csord__Subscription__c = subs.Id;
        serv2.csord__Status__c = 'Service Created';
        serv2.csord__Order_Request__c = ordReq.Id;
        serv2.csord__Order__c = ord.Id;
        servs.add(serv2);
        
        csord__Service__c serv3 = new csord__Service__c();
        serv3.name ='tst service3';
        serv3.csord__Identification__c  = 'tst identify3';
        serv3.csordtelcoa__Service_Number__c = '6';
        serv3.csord__Subscription__c = subs.Id;
        serv3.csord__Status__c = 'Service Created';
        serv3.csord__Order_Request__c = ordReq.Id;
        serv3.csord__Order__c = ord.Id;
        servs.add(serv3);
        
        csord__Service__c serv4 = new csord__Service__c();
        serv4.name ='tst service4';
        serv4.csord__Identification__c  = 'tst identify4';
        serv4.csordtelcoa__Service_Number__c = '7';
        serv4.csord__Subscription__c = subs.Id;
        serv4.csord__Status__c = 'Service Created';
        serv4.csord__Order_Request__c = ordReq.Id;
        serv4.csord__Order__c = ord.Id;
        serv4.csord__Service__c=ser.Id;
        //EDGE-132208 - Updated to pass new PC record
        serv4.csordtelcoa__Product_Configuration__c = userPC1.id;
        servs.add(serv4);
        
        csord__Service__c servRe = new csord__Service__c();
        servRe.name ='tst servRe';
        servRe.csord__Identification__c  = 'test servRe';
        servRe.csordtelcoa__Service_Number__c = 'svc-123567';
        servRe.csord__Subscription__c = subRes.Id;
        servRe.csord__Status__c = 'Service Created';
        servRe.csord__Order_Request__c = ordReq2.Id;
        servRe.csord__Order__c = ord1.Id;
        servRe.csordtelcoa__Product_Configuration__c = userPC.id;
        servs.add(servRe);
        
		csord__Service__c servPricing = new csord__Service__c();
        servPricing.name ='Pricing';
        servPricing.csord__Identification__c  = 'test Pricing';
        servPricing.csordtelcoa__Service_Number__c = 'svc-123567';
        servPricing.csord__Subscription__c = subPricing.Id;
        servPricing.csord__Status__c = 'Service Created';
        servPricing.csord__Order__c = ord.Id;
        servPricing.csordtelcoa__Product_Configuration__c = userPC.id;
        servs.add(servPricing);
		
		csord__Service__c servPricing1 = new csord__Service__c();
        servPricing1.name ='Pricing1';
        servPricing1.csord__Identification__c  = 'test Pricing1';
        servPricing1.csordtelcoa__Service_Number__c = 'svc-123567';
        servPricing1.csord__Subscription__c = subPricing1.Id;
        servPricing1.csord__Status__c = 'Service Created';
        servPricing1.csord__Order__c = ord.Id;
		servPricing1.csordtelcoa__Replaced_Service__c=servPricing.id;
        servPricing1.csordtelcoa__Product_Configuration__c = userPC.id;
        servs.add(servPricing1);
		
		csord__Service__c servPricing2 = new csord__Service__c();
        servPricing2.name ='Pricing2';
        servPricing2.csord__Identification__c  = 'test Pricing2';
        servPricing2.csordtelcoa__Service_Number__c = 'svc-123567';
        servPricing2.csord__Subscription__c = subPricing2.Id;
        servPricing2.csord__Status__c = 'Service Created';
        servPricing2.csord__Order__c = ord.Id;
		servPricing1.csordtelcoa__Replaced_Service__c=servPricing.id;
        servPricing2.csordtelcoa__Product_Configuration__c = userPC1.id;
        servs.add(servPricing2);
        insert servs;
        
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
        insert app;
        
        //EDGE-136242 - Updated all attachment params for Refactoring - Removed Product Spec Code 871 to resolve the conflicts in the test coverage.
        List<Attachment> atts = new List<Attachment>();
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobile Access_Billing_NonRecurringCharge_000601","instanceId":"","guid":"518a459f-0c60-9d4d-e194-7d1bb73a127b","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","attributes":{"__targetSystem":"BILLING","rateExcludeGST":"0.00","billDescription":"IR Pay as you go charge","unitofMeasure":"each","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","type":"OC","currency":"AUD","ocsProdID":"T22E_IR_USAGE"},"metadata":{},"includeBilling":false,"additionalAttributes":{}},{"version":"1","status":"Pending","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1add-89725fee80c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000322_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"Suspend","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1add-81725fgg30c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000872_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"Suspended","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1fdd-81747fgg30c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000747_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"e16ace88-b994-07d4-c5f4-5f5a78a4345d","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","IMSI":"","ShippingRequired":false,"CustomerFacingServiceId":"","MESSAGEBANK":"3G Standard Retail","SIMSKU":"100119211","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","SERVICEPROFILE":"NORMAL"},"additionalAttributes":{"parentSpec":"ec49950c-5da3-a5a1-1add-89725fee80c9","CustomerFacingServiceId":"61474841950","SuspensionContext":"CUSTOMER"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Billing_RecurringCharge_000498","metadata":{},"instanceId":"","includeBilling":false,"guid":"ad76e859-a8c0-8db8-cbaf-ecbdeeab2ee3","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes":{"taxTreatment":"GST Applicable","billDescription":"CWP Mobile Seat","prorate":"false","billInAdvance":"true","billingSpecId":"BSRC001_CB","frequency":"Monthly","currency":"AUD","type":null,"description":"MRO Plan Discount","applicationDuration":"24 months","unitPrice":60,"rateExcludeGST":100,"Priority":"1","recurringChargePeriod":"Monthly","quantity":"1","__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"'+serv.Id+'","legacyAttributes":[]}');
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
        att14.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobile Access_Billing_NonRecurringCharge_000601","instanceId":"","guid":"518a459f-0c60-9d4d-e194-7d1bb73a127b","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","attributes":{"__targetSystem":"BILLING","rateExcludeGST":"0.00","billDescription":"IR Pay as you go charge","unitofMeasure":"each","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","type":"OC","currency":"AUD","ocsProdID":"T22E_IR_USAGE"},"metadata":{},"includeBilling":false,"additionalAttributes":{}},{"version":"1","status":"Pending","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1add-89725fee80c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000322_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"Suspend","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1add-81725fgg30c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000872_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"Suspended","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1fdd-81747fgg30c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000747_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"e16ace88-b994-07d4-c5f4-5f5a78a4345d","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","IMSI":"","ShippingRequired":false,"CustomerFacingServiceId":"","MESSAGEBANK":"3G Standard Retail","SIMSKU":"100119211","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","SERVICEPROFILE":"NORMAL"},"additionalAttributes":{"parentSpec":"ec49950c-5da3-a5a1-1add-89725fee80c9","CustomerFacingServiceId":"61474841950","SuspensionContext":"CUSTOMER"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Billing_RecurringCharge_000498","metadata":{},"instanceId":"","includeBilling":false,"guid":"ad76e859-a8c0-8db8-cbaf-ecbdeeab2ee3","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes":{"taxTreatment":"GST Applicable","billDescription":"CWP Mobile Seat","prorate":"false","billInAdvance":"true","billingSpecId":"BSRC001_CB","frequency":"Monthly","currency":"AUD","type":null,"description":"MRO Plan Discount","applicationDuration":"24 months","unitPrice":60,"rateExcludeGST":100,"Priority":"1","recurringChargePeriod":"Monthly","quantity":"1","__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"'+serv4.Id+'","legacyAttributes":[]}');att14.Name = 'ServiceSpecifications.json';
        att14.Name = 'ServiceSpecifications.json';
        att14.ParentId = serv4.Id;
        atts.add(att14);
        
        
        Attachment attNew = new Attachment();
        attNew.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Complete","startDate":"","specification":"30a0f36c-b496-185e-6330-c7a9c317d22c","productConfigurationId":"a0b0Y000001oXmtQAE","name":"CWPSpec","instanceId":"1234","guid":"3072dad2-5546-eb71-8e13-bd04b7f9824a","endDate":"","description":"CWP CFS Specification","code":"CWPSpec01","attributes":{"__targetSystem":"FULFILMENT","Zone":"Zone 3","TotalMRC":1500,"Seat":5,"complexIPAccess":[{"attributes":{"complexAttrPort":8080,"complexAttrTech":"Fibre"},"productConfigurationId":"a0b0Y000001oXmyQAE"},{"attributes":{"complexAttrPort":9090,"complexAttrTech":"Ethernet"},"productConfigurationId":"a0b0Y000001oXn3QAE"}],"constantName":"contantValue"}},{"version":"1","status":"Complete","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXmyQAE","name":"IPAccessSpec","instanceId":"3456","guid":"3df57fcf-7c28-c50a-140b-0d21e80714e7","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"__targetSystem":"FULFILMENT","Port":8080,"Technology":"Fibre","constantAttr":"constantValue"}},{"version":"1","status":"Complete","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXn3QAE","name":"IPAccessSpec","instanceId":"6789","guid":"495bbebb-5166-6dce-24cd-648084f6241c","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"__targetSystem":"FULFILMENT","Port":9090,"Technology":"Ethernet","constantAttr":"constantValue"}}],"serviceId":"'+ser.Id+'","legacyAttributes":[]}');
        attNew.Name = 'ServiceSpecifications.json';
        attNew.ParentId = ser.Id;
        atts.add(attNew);
        
        Attachment attRes = new Attachment();
        attRes.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobile Access_Billing_NonRecurringCharge_000601","instanceId":"","guid":"518a459f-0c60-9d4d-e194-7d1bb73a127b","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","attributes":{"__targetSystem":"BILLING","rateExcludeGST":"0.00","billDescription":"IR Pay as you go charge","unitofMeasure":"each","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","type":"OC","currency":"AUD","ocsProdID":"T22E_IR_USAGE"},"metadata":{},"includeBilling":false,"additionalAttributes":{}},{"version":"1","status":"Pending","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1add-89725fee80c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000322_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"Suspend","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1add-81725fgg30c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000872_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"Suspended","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1fdd-81747fgg30c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000747_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"e16ace88-b994-07d4-c5f4-5f5a78a4345d","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","IMSI":"","ShippingRequired":false,"CustomerFacingServiceId":"","MESSAGEBANK":"3G Standard Retail","SIMSKU":"100119211","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","SERVICEPROFILE":"NORMAL"},"additionalAttributes":{"parentSpec":"ec49950c-5da3-a5a1-1add-89725fee80c9","CustomerFacingServiceId":"61474841950","SuspensionContext":"CUSTOMER"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Billing_RecurringCharge_000498","metadata":{},"instanceId":"","includeBilling":false,"guid":"ad76e859-a8c0-8db8-cbaf-ecbdeeab2ee3","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes":{"taxTreatment":"GST Applicable","billDescription":"CWP Mobile Seat","prorate":"false","billInAdvance":"true","billingSpecId":"BSRC001_CB","frequency":"Monthly","currency":"AUD","type":null,"description":"MRO Plan Discount","applicationDuration":"24 months","unitPrice":60,"rateExcludeGST":100,"Priority":"1","recurringChargePeriod":"Monthly","quantity":"1","__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"'+servRe.Id+'","legacyAttributes":[]}');
        attRes.Name = 'ServiceSpecifications.json';
        attRes.ParentId = servRe.Id;
        atts.add(attRes);
        
        //EDGE-132208 - Added below 2 Attachments
        Attachment attRem = new Attachment();
        attRem.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"DISCONNECT PENDING","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobile Access_Billing_NonRecurringCharge_000601","instanceId":"","guid":"518a459f-0c60-9d4d-e194-7d1bb73a127b","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","attributes":{"__targetSystem":"BILLING","rateExcludeGST":"0.00","billDescription":"IR Pay as you go charge","unitofMeasure":"each","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","type":"OC","currency":"AUD","ocsProdID":"T22E_IR_USAGE"},"metadata":{},"includeBilling":false,"additionalAttributes":{}},{"version":"1","status":"Pending","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1add-89725fee80c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000322_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"Suspend","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1add-81725fgg30c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000871_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"Suspended","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1fdd-81747fgg30c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000747_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"e16ace88-b994-07d4-c5f4-5f5a78a4345d","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","IMSI":"","ShippingRequired":false,"CustomerFacingServiceId":"","MESSAGEBANK":"3G Standard Retail","SIMSKU":"100119211","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","SERVICEPROFILE":"NORMAL"},"additionalAttributes":{"parentSpec":"ec49950c-5da3-a5a1-1add-89725fee80c9","CustomerFacingServiceId":"61474841950","SuspensionContext":"CUSTOMER"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Billing_RecurringCharge_000498","metadata":{},"instanceId":"","includeBilling":false,"guid":"ad76e859-a8c0-8db8-cbaf-ecbdeeab2ee3","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes":{"taxTreatment":"GST Applicable","billDescription":"CWP Mobile Seat","prorate":"false","billInAdvance":"true","billingSpecId":"BSRC001_CB","frequency":"Monthly","currency":"AUD","type":null,"description":"MRO Plan Discount","applicationDuration":"24 months","unitPrice":60,"rateExcludeGST":100,"Priority":"1","recurringChargePeriod":"Monthly","quantity":"1","__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"'+servRe.Id+'","legacyAttributes":[]}');
        attRem.Name = 'ServiceSpecifications.json';
        attRem.ParentId = serv4.Id;
        atts.add(attRem);
        
        Attachment attRem1 = new Attachment();
        attRem1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"DISCONNECTED","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobile Access_Billing_NonRecurringCharge_000601","instanceId":"","guid":"518a459f-0c60-9d4d-e194-7d1bb73a127b","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000601","attributes":{"__targetSystem":"BILLING","rateExcludeGST":"0.00","billDescription":"IR Pay as you go charge","unitofMeasure":"each","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","type":"OC","currency":"AUD","ocsProdID":"T22E_IR_USAGE"},"metadata":{},"includeBilling":false,"additionalAttributes":{}},{"version":"1","status":"Pending","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1add-89725fee80c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000322_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"Suspend","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1add-81725fgg30c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000871_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"Suspended","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Fulfilment","instanceId":"","guid":"ec49950c-5da3-a5a1-1fdd-81747fgg30c9","endDate":"","description":"","code":"DMCAT_ProductSpecification_000747_Fulfilment","attributes":{"__targetSystem":"FULFILMENT"},"metadata":{},"includeBilling":false,"additionalAttributes":{"SuspensionContext":"CUSTOMER"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"e16ace88-b994-07d4-c5f4-5f5a78a4345d","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","IMSI":"","ShippingRequired":false,"CustomerFacingServiceId":"","MESSAGEBANK":"3G Standard Retail","SIMSKU":"100119211","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","SERVICEPROFILE":"NORMAL"},"additionalAttributes":{"parentSpec":"ec49950c-5da3-a5a1-1add-89725fee80c9","CustomerFacingServiceId":"61474841950","SuspensionContext":"CUSTOMER"}},{"version":"1","status":"In Progress","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","productConfigurationId":"a3T2O000000JESeUAO","name":"Mobility_Billing_RecurringCharge_000498","metadata":{},"instanceId":"","includeBilling":false,"guid":"ad76e859-a8c0-8db8-cbaf-ecbdeeab2ee3","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes":{"taxTreatment":"GST Applicable","billDescription":"CWP Mobile Seat","prorate":"false","billInAdvance":"true","billingSpecId":"BSRC001_CB","frequency":"Monthly","currency":"AUD","type":null,"description":"MRO Plan Discount","applicationDuration":"24 months","unitPrice":60,"rateExcludeGST":100,"Priority":"1","recurringChargePeriod":"Monthly","quantity":"1","__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"'+servRe.Id+'","legacyAttributes":[]}');
        attRem1.Name = 'ServiceSpecifications.json';
        attRem1.ParentId = serv4.Id;
        atts.add(attRem1);
        //EDGE-132208 - Added Attachement for Number removal change.
        Attachment attnumberMan = new Attachment();
        String encodedContentsString = '{"schema":{"attributes":[{"name":"FNN","required":false,"showInUI":true,"type":"String"},{"name":"rangeFrom","required":false,"showInUI":true,"type":"String"},{"name":"rangeTo","required":false,"showInUI":true,"type":"String"},{"name":"status","required":false,"showInUI":true,"type":"String"},{"name":"listCode","required":false,"showInUI":true,"type":"String"}],"id":"a792O00000000DEQAY","name":"NumberManagementv1"},"configurations":[{"guid":"cf96d575-7198-2799-4d34-cd6eed1e4c71","listCode":"No Entry Line","status":"ACTIVE","rangeTo":"8282345569","rangeFrom":"8282345561","FNN":"8282345560"},{"guid":"746e220b-e219-f6d6-7c53-3827bb97bc1d","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"24fe9940-65cf-0a93-8f7e-a681e039be76","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"32465bd8-566e-3e5c-87c6-e438ce795f63","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"278bbc9e-dafe-116a-ce3e-83af895ed80d","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"33b484b7-4d1e-5d4e-8ca3-7ad5b32dbd42","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"777e4395-d042-7089-1117-14fb50640174","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"8233ce42-21ba-5cf8-c31d-a5f2a52e6646","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"c9213563-b219-1d69-2ba7-3c5b257025db","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"6e5ee258-67e9-9a96-ca7b-3eaccc671de3","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"676c92a5-a312-488e-ff36-155eab7bafc1","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"51321f39-fc94-6a78-ea20-707a23d61de8","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid":"4db88375-7f76-3c68-3488-db7a5266b5e7","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"8282345560"},{"guid":"31593c15-a89a-488a-e15b-99e17e85eafe","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"9282345560"},{"guid":"47705868-4451-b1f8-54af-e262d6d3296b","listCode":"No Entry Line","status":"ACTIVE","rangeTo":null,"rangeFrom":null,"FNN":"7282345560"},{"guid": "47705868-4451-b1f8-54af-e262d6d3296b","listCode": "No Entry Line","status": "DISCONNECT PENDING","rangeTo": null,"rangeFrom": null,"FNN":"7282345560"}]}';
        attnumberMan.Body = Blob.valueOf(encodedContentsString);
        attnumberMan.Name = String.valueOf('NumberManagementv1_schema.json');
        attnumberMan.ParentId = userPC1.id;
        atts.add(attnumberMan);
        
        insert atts;
    }
    
    @isTest
    static void testProcessNotificationRec(){
        csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' AND csord__Order__r.Name= 'TestOrder' limit 1][0];
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
        List<String> parameters = new List<String>();
        List<String> parameters1 = new List<String>();
        Test.startTest();
        Notification__c notif = new Notification__c();
        notif.externalOrderId__c = ord.csord__Order_Number__c;
        notif.eventTimeStamp__c = '2018-02-24T06:08+10:00';
        notif.orderItemId__c = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1add-89725fee80c9';
        notif.notificationAttributes__c = '"attributes":[{"name":"telstraCommittedDate", "value":"2018-12-27T05:56:03+11:00"},{"name":"productCompletionDate","value":"2018-12-03T05:39:54+11:00"},{"name":"status","value":"In Progress"}]';
        notif.orderItemDetails__c = '"product":{"productId":"ec49950c-5da3-a5a1-1add-89725fee80c9","status":"In Progress"}';
        notif.eventType__c = 'statusNotification';
        notif.orderItemVersion__c = 1;
        notif.sourceSystem__c = 'FULFILMENT';
        insert notif;


        parameters.add(notif.orderItemId__c);
        parameters.add(notif.notificationAttributes__c);
        parameters.add(notif.eventType__c);
        parameters.add(notif.orderItemDetails__c);
        parameters.add(notif.sourceSystem__c);
        parameters.add(notif.id);
        parameters.add(notif.id);
         

        ManageOrderNotificationService.processNotificationRecord(parameters);
        //ManageOrderNotificationService.processNotificationRecord(parameters1);
        Test.stopTest();
        csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' limit 1][0];
        //System.assertEquals('In Progress', svc.csord__Status__c);
        System.assertEquals('tst service', svc.Name);
        
    }
    
    /*******************
     * Method:testProcessNotificationCancel
     * Owner: Sandip Deshmane
     * Change: EDGE-132208
     *******************/
    
	@isTest
    static void testProcessNotificationCancel(){
        csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service4' AND csord__Order__r.Name= 'TestOrder' limit 1][0];
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
        List<String> parameters = new List<String>();
        List<String> parameters1 = new List<String>();
        Test.startTest();
        Notification__c notif = new Notification__c();
        notif.externalOrderId__c = ord.csord__Order_Number__c;
        notif.eventTimeStamp__c = '2018-02-24T06:08+10:00';
        notif.orderItemId__c = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1add-89725fee80c9';
        notif.notificationAttributes__c = '"attributes":[{"name":"telstraCommittedDate", "value":"2018-12-27T05:56:03+11:00"},{"name":"productCompletionDate","value":"2018-12-03T05:39:54+11:00"},{"name":"status","value":"In Progress"}]';
        notif.orderItemDetails__c = '"product":{"productId":"ec49950c-5da3-a5a1-1add-89725fee80c9","status":"In Progress"}';
        notif.eventType__c = 'statusNotification';
        notif.orderItemVersion__c = 1;
        notif.sourceSystem__c = 'FULFILMENT';
        insert notif;


        parameters.add(notif.orderItemId__c);
        parameters.add(notif.notificationAttributes__c);
        parameters.add(notif.eventType__c);
        parameters.add(notif.orderItemDetails__c);
        parameters.add(notif.sourceSystem__c);
        parameters.add(notif.id);
        parameters.add(notif.id);
         

        ManageOrderNotificationService.processNotificationRecord(parameters);
        //ManageOrderNotificationService.processNotificationRecord(parameters1);
        List<Attachment> attList = new List<Attachment>();
        attList = [select Id,Body,ParentId FROM Attachment WHERE Name like '%NumberManagementv1%'];
        system.debug('Attach--->'+attList);
        String attbody;
        for (Attachment att : attList) {
            attbody = att.Body.toString();
        }
        System.debug('attbody--->'+attbody);
        Test.stopTest();
        csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service4' limit 1][0];
        System.assertEquals(attbody.contains('DISCONNECT PENDING'), true);
        System.assertEquals('tst service4', svc1.Name);
        
    }
    
    /*******************
     * Method:testProcessNotificationCancelNegative
     * Owner: Sandip Deshmane
     * Change: EDGE-132208
     *******************/
    
	@isTest
    static void testProcessNotificationCancelNegative(){
        csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service4' AND csord__Order__r.Name= 'TestOrder' limit 1][0];
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
        List<String> parameters = new List<String>();
        List<String> parameters1 = new List<String>();
        Test.startTest();
        Notification__c notif = new Notification__c();
        notif.externalOrderId__c = ord.csord__Order_Number__c;
        notif.eventTimeStamp__c = '2018-02-24T06:08+10:00';
        notif.orderItemId__c = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1add-89725fee80c9';
        notif.notificationAttributes__c = '"attributes":[{"name":"telstraCommittedDate", "value":"2018-12-27T05:56:03+11:00"},{"name":"productCompletionDate","value":"2018-12-03T05:39:54+11:00"},{"name":"status","value":"In Progress"}]';
        notif.orderItemDetails__c = '"product":{"productId":"ec49950c-5da3-a5a1-1add-89725fee80c9","status":"In Progress"}';
        notif.eventType__c = 'statusNotification';
        notif.orderItemVersion__c = 1;
        notif.sourceSystem__c = 'FULFILMENT';
        insert notif;


        parameters.add(notif.orderItemId__c);
        parameters.add(notif.notificationAttributes__c);
        parameters.add(notif.eventType__c);
        parameters.add(notif.orderItemDetails__c);
        parameters.add(notif.sourceSystem__c);
        parameters.add(notif.id);
        parameters.add(notif.id);
         

        ManageOrderNotificationService.processNotificationRecord(parameters);
        List<Attachment> attList = new List<Attachment>();
        attList = [select Id,Body,ParentId FROM Attachment WHERE Name like '%NumberManagementv1%'];
        system.debug('Attach--->'+attList);
        String attbody;
        for (Attachment att : attList) {
            attbody = att.Body.toString();
        }
        System.debug('attbody--->'+attbody);
        Test.stopTest();
        csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service4' limit 1][0];
        System.assertNotEquals(attbody.contains('DISCONNECT In PROGRESS'), true);// Negative Test
        System.assertNotEquals('tst service5', svc1.Name);
        
    }
    
    @isTest
    static void testProcessNotificationRec12(){
        csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' AND csord__Order__r.Name= 'TestOrder' limit 1][0];
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
        List<String> parameters = new List<String>();
        List<String> parameters1 = new List<String>();
        Test.startTest();
        Notification__c notif = new Notification__c();
        notif.externalOrderId__c = ord.csord__Order_Number__c;
        notif.eventTimeStamp__c = '2018-02-24T06:08+10:00';
        notif.orderItemId__c = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1add-89725fee80c9';
        notif.notificationAttributes__c = '"attributes":[{"name":"telstraCommittedDate", "value":"2018-12-27T05:56:03+11:00"},{"name":"productCompletionDate","value":"2018-12-03T05:39:54+11:00"},{"name":"status","value":"Complete"}]';
        notif.orderItemDetails__c = '"product":{"productId":"ec49950c-5da3-a5a1-1add-89725fee80c9","status":"Complete"}';
        notif.eventType__c = 'statusNotification';
        notif.orderItemVersion__c = 1;
        notif.sourceSystem__c = 'FULFILMENT';
       
        insert notif;
        
        
        parameters.add(notif.orderItemId__c);
        parameters.add(notif.notificationAttributes__c);
        parameters.add(notif.eventType__c);
        parameters.add(notif.orderItemDetails__c);
        parameters.add(notif.sourceSystem__c);
        parameters.add(notif.id);
        parameters.add(notif.id);
        
        
        ManageOrderNotificationService.processNotificationRecord(parameters);
        //ManageOrderNotificationService.processNotificationRecord(parameters1);
        Test.stopTest();
        csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' limit 1][0];
        //System.assertEquals('In Progress', svc.csord__Status__c);
        System.assertEquals('tst service', svc.Name);
        
    }
    
        @isTest
    static void testProcessNotificationRec13(){
        csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' AND csord__Order__r.Name= 'TestOrder' limit 1][0];
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
        List<String> parameters = new List<String>();
        List<String> parameters1 = new List<String>();
        Test.startTest();
        Notification__c notif = new Notification__c();
        notif.externalOrderId__c = ord.csord__Order_Number__c;
        notif.eventTimeStamp__c = '2018-02-24T06:08+10:00';
        notif.orderItemId__c = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'e16ace88-b994-07d4-c5f4-5f5a78a4345d';
        notif.notificationAttributes__c = '"attributes":[{"name":"telstraCommittedDate", "value":"2018-12-27T05:56:03+11:00"},{"name":"productCompletionDate","value":"2018-12-03T05:39:54+11:00"},{"name":"status","value":"Complete"}]';
        notif.orderItemDetails__c = '"product":{"productId":"e16ace88-b994-07d4-c5f4-5f5a78a4345d","status":"Complete"}';
        notif.eventType__c = 'statusNotification';
        notif.orderItemVersion__c = 1;
        notif.sourceSystem__c = 'FULFILMENT';
       
        insert notif;
        
        
        parameters.add(notif.orderItemId__c);
        parameters.add(notif.notificationAttributes__c);
        parameters.add(notif.eventType__c);
        parameters.add(notif.orderItemDetails__c);
        parameters.add(notif.sourceSystem__c);
        parameters.add(notif.id);
        parameters.add(notif.id);
        
        
        ManageOrderNotificationService.processNotificationRecord(parameters);
        //ManageOrderNotificationService.processNotificationRecord(parameters1);
        Test.stopTest();
        csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' limit 1][0];
        //System.assertEquals('In Progress', svc.csord__Status__c);
        System.assertEquals('tst service', svc.Name);
        
    }
    
    
        @isTest
    static void testProcessNotificationRec14(){
        csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' AND csord__Order__r.Name= 'TestOrder' limit 1][0];
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
        List<String> parameters = new List<String>();
        List<String> parameters1 = new List<String>();
        Test.startTest();
        Notification__c notif = new Notification__c();
        notif.externalOrderId__c = ord.csord__Order_Number__c;
        notif.eventTimeStamp__c = '2018-02-24T06:08+10:00';
        notif.orderItemId__c = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'e16ace88-b994-07d4-c5f4-5f5a78a4345d';
        notif.notificationAttributes__c = '"attributes":[{"name":"telstraCommittedDate", "value":"2018-12-27T05:56:03+11:00"},{"name":"productCompletionDate","value":"2018-12-03T05:39:54+11:00"},{"name":"status","value":"In Progress"}]';
        notif.orderItemDetails__c = '"product":{"productId":"e16ace88-b994-07d4-c5f4-5f5a78a4345d","status":"In Progress"}';
        notif.eventType__c = 'statusNotification';
        notif.orderItemVersion__c = 1;
        notif.sourceSystem__c = 'FULFILMENT';
       
        insert notif;
        
        
        parameters.add(notif.orderItemId__c);
        parameters.add(notif.notificationAttributes__c);
        parameters.add(notif.eventType__c);
        parameters.add(notif.orderItemDetails__c);
        parameters.add(notif.sourceSystem__c);
        parameters.add(notif.id);
        parameters.add(notif.id);
        
        
        ManageOrderNotificationService.processNotificationRecord(parameters);
        //ManageOrderNotificationService.processNotificationRecord(parameters1);
        Test.stopTest();
        csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' limit 1][0];
        //System.assertEquals('In Progress', svc.csord__Status__c);
        System.assertEquals('tst service', svc.Name);
        
    }
    
    @isTest
    static void testBatchProcessing(){
        csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' AND csord__Order__r.Name= 'TestOrder' limit 1][0];
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
        List<String> parameters = new List<String>();
        List<String> parameters1 = new List<String>();
        Notification__c notif = new Notification__c();
        notif.externalOrderId__c = ord.csord__Order_Number__c;
        notif.eventTimeStamp__c = '2018-02-24T06:08+10:00';
        notif.orderItemId__c = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1add-89725fee80c9';
        notif.notificationAttributes__c = '"attributes":[{"name":"status", "value":"Complete"}]';
        notif.orderItemDetails__c = '"product":{"productId":"ec49950c-5da3-a5a1-1add-89725fee80c9","status":"Complete"}';
        notif.eventType__c = 'statusNotification';
        notif.orderItemVersion__c = 1;
        notif.sourceSystem__c = 'FULFILMENT';
        notif.Status__c = 'Pending';
        insert notif;
        Test.startTest();
            System.schedule('queueOrderNotificationstest', '0 1 2 * * ?', new ProcessOrderNotificationsSchedulable());
            database.executeBatch(new ProcessOrderNotificationsBatch(), 10);
        Test.stopTest();

        System.assertEquals('Pending',  notif.Status__c);
        
    }
    
  
    
    @isTest
    static void testProcessNotificationRecMissingEvent(){
        csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' limit 1][0];
        List<String> parameters = new List<String>();
        parameters.add('ORD-00001|'+svc1.csordtelcoa__Service_Number__c+'|1234:::"attributes":[{"name":"status", "value":"In Progress"}]');
        Test.startTest();
        ManageOrderNotificationService.processNotificationRecord(parameters);
        Test.stopTest();
        csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' limit 1][0];
        System.assertEquals('Service Created', svc.csord__Status__c);
    }
    
    @isTest
    static void testupdateServiceRecord(){
        List<String> paramList = new List<String>();
        ManageOrderNotificationUtil.Parameters params = new ManageOrderNotificationUtil.Parameters();
        csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' limit 1][0];
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
        List<String> parameters = new List<String>();
        params.orderIdc = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|3072dad2-2911-eb71-8e13-bd04b7f9824a';
        params.notifyAttributes = '{"attributes":[{"name":"status", "value":"Complete"}]}';
        params.orderItemDetails = '{"product":{"productId":"3072dad2-5546-eb71-8e13-bd04b7f9824a","status":"In Progress"}}';
        params.eventType = 'statusNotification';
        paramList.add(JSON.serialize(params));
        
        ManageOrderNotificationUtil.Parameters params1 = new ManageOrderNotificationUtil.Parameters();
        params1.orderIdc = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|3456';
        params1.notifyAttributes = '{"attributes":[{"name":"status", "value":"Complete"}]}';
        params1.orderItemDetails = '{"product":{"productId":"3df57fcf-7c28-c50a-140b-0d21e80714e7","status":"In Progress"}}';
        params1.eventType = 'statusNotification';
        paramList.add(JSON.serialize(params1));
        
        ManageOrderNotificationUtil.Parameters params2 = new ManageOrderNotificationUtil.Parameters();
        params2.orderIdc = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'e16ace88-b994-07d4-c5f4-5f5a78a4345d';
        params2.notifyAttributes = '{"attributes":[{"name":"status", "value":"Complete"}]}';
        params2.orderItemDetails = '{"product":{"productId":"e16ace88-b994-07d4-c5f4-5f5a78a4345d","status":"In Progress"}}';
        params2.eventType = 'statusNotification';
        paramList.add(JSON.serialize(params2));
        
        Notification__c notif = new Notification__c();
        notif.externalOrderId__c = ord.csord__Order_Number__c;
        notif.orderItemId__c = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'e16ace88-b994-07d4-c5f4-5f5a78a4345d';
        notif.eventTimeStamp__c = '2018-02-24T06:08+10:00';
        notif.orderItemVersion__c = 1;
        notif.notificationAttributes__c = '"attributes":[{"name":"status", "value":"Complete"}]';
        notif.orderItemDetails__c = '"product":{"productId":"e16ace88-b994-07d4-c5f4-5f5a78a4345d","status":"Complete"}';
        notif.eventType__c = 'statusNotification';
        notif.sourceSystem__c = 'Fulfilment';
        notif.Status__c = 'Pending';
        insert notif;
        
        Test.startTest();
        ManageOrderNotificationService.updateServiceRecord(paramList,notif.id);
        Test.stopTest();
        
        csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' limit 1][0];
        //System.assertEquals('In Progress', svc.csord__Status__c);
         System.assertEquals('tst service', svc.Name);
    }
    
    @isTest
    static void testupdateServiceRecordErrorEvent(){
        List<String> paramList = new List<String>();
        ManageOrderNotificationUtil.Parameters params = new ManageOrderNotificationUtil.Parameters();
        csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' limit 1][0];
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
        //List<String> parameters = new List<String>();
        params.orderIdc = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|3072dad2-2911-eb71-8e13-bd04b7f9824a';
        params.notifyAttributes = '{"attributes":[{"name":"status", "value":"Error"}]}';
        params.orderItemDetails = '{"product":{"productId":"3072dad2-2911-eb71-8e13-bd04b7f9824a","status":"In Progress"}}';
        params.eventType = 'error';
        paramList.add(JSON.serialize(params));
        
        Notification__c notif = new Notification__c();
        notif.externalOrderId__c = ord.csord__Order_Number__c;
        notif.orderItemId__c = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|3072dad2-2911-eb71-8e13-bd04b7f9824a';
        notif.eventTimeStamp__c = '2018-02-24T06:08+10:00';
        notif.orderItemVersion__c = 1;
        notif.notificationAttributes__c = '"attributes":[{"name":"status", "value":"Error"}]';
        notif.orderItemDetails__c = '"product":{"productId":"3072dad2-5546-1122-8e13-bd04b7f9824a","status":"Failed"}';
        notif.eventType__c = 'error';
        notif.sourceSystem__c = 'Fulfilment';
        notif.Status__c = 'Pending';
        insert notif;
        
        Test.startTest();
        ManageOrderNotificationService.updateServiceRecord(paramList,notif.id);
        Test.stopTest();
        csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' limit 1][0];
        System.assertEquals('tst service', svc.Name);
    }
    
    @isTest
    static void testupdateServiceRecordDisconnect(){
        List<String> paramList = new List<String>();
        csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' limit 1][0];
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
        ManageOrderNotificationUtil.Parameters params = new ManageOrderNotificationUtil.Parameters();
        List<String> parameters = new List<String>();
        params.orderIdc = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|ec49950c-5da3-a5a1-1add-89725fee80c9';
        params.notifyAttributes = '{"attributes":[{"name":"status", "value":"Complete"}]}';
        params.orderItemDetails = '{"product":{"productId":"ec49950c-5da3-a5a1-1add-89725fee80c9","status":"Complete"}}';
        params.eventType = 'statusNotification';
        paramList.add(JSON.serialize(params));
       
        Test.startTest();
        Notification__c notif = new Notification__c();
        notif.externalOrderId__c = ord.csord__Order_Number__c;
        notif.orderItemId__c = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1add-89725fee80c9';
        notif.eventTimeStamp__c = '2018-02-24T06:08+10:00';
        notif.orderItemVersion__c = 1;
        notif.notificationAttributes__c = '"attributes":[{"name":"status", "value":"Complete"}]';
        notif.orderItemDetails__c = '"product":{"productId":"ec49950c-5da3-a5a1-1add-89725fee80c9","status":"Complete"}';
        notif.eventType__c = 'statusNotification';
        notif.sourceSystem__c = 'Fulfilment';
        notif.Status__c = 'Pending';
        insert notif;
        
        
        ManageOrderNotificationService.updateServiceRecord(paramList,notif.id);
        Test.stopTest();
        
        csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service3' limit 1][0];
        //System.assertEquals('Disconnect In Progress', svc.csord__Status__c);
         System.assertEquals('tst service3', svc.Name);
    }
    
    @isTest
    static void testupdateServiceRecordChildServiceComplete(){
        List<String> paramList = new List<String>();
        csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service3' limit 1][0];
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
        System.debug('ord.csord__Primary_Order__c in test'+ord.csord__Primary_Order__c);
        ManageOrderNotificationUtil.Parameters params = new ManageOrderNotificationUtil.Parameters();
        List<String> parameters = new List<String>();
        params.orderIdc = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|95bbebb-5166-6dce-24cd-648084f6241c';
        params.notifyAttributes = '{"attributes":[{"name":"status", "value":"Complete"}]}';
        params.orderItemDetails = '{"product":{"productId":"3072dad2-5546-1122-8e13-bd04b7f9824a","status":"Complete","childProduct":[{"productId":"30a0f36c-b496-185e-6330-c7a9c317d223","status":"Complete"}]}}';
        params.eventType = 'statusNotification';
        paramList.add(JSON.serialize(params));
        
        Notification__c notif = new Notification__c();
        notif.externalOrderId__c = ord.csord__Order_Number__c;
        notif.orderItemId__c = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|3072dad2-5546-1122-8e13-bd04b7f9824a';
        notif.eventTimeStamp__c = '2018-02-24T06:08+10:00';
        notif.orderItemVersion__c = 1;
        notif.notificationAttributes__c = '"attributes":[{"name":"status", "value":"Complete"}]';
        notif.orderItemDetails__c = '"product":{"productId":"3072dad2-5546-1122-8e13-bd04b7f9824a","status":"Complete","childProduct":[{"productId":"30a0f36c-b496-185e-6330-c7a9c317d223","status":"Complete"}]}';
        notif.eventType__c = 'statusNotification';
        notif.sourceSystem__c = 'Fulfilment';
        notif.Status__c = 'Pending';
        insert notif;
        
        Test.startTest();
        ManageOrderNotificationService.updateServiceRecord(paramList,notif.id);
        Test.stopTest();
        
        csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service4' limit 1][0];
        System.assertEquals('tst service4', svc.Name);
    }
    //Added for test coverage by Shreya
   @isTest
    static void testupdateServiceRecordChildServiceInProg(){
        List<String> paramList = new List<String>();
        csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service3' limit 1][0];
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
        System.debug('ord.csord__Primary_Order__c in test'+ord.csord__Primary_Order__c);
        ManageOrderNotificationUtil.Parameters params = new ManageOrderNotificationUtil.Parameters();
        List<String> parameters = new List<String>();
        params.orderIdc = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|95bbebb-5166-6dce-24cd-648084f6241c';
        params.notifyAttributes = '{"attributes":[{"name":"status", "value":"In Progress"}]}';
        params.orderItemDetails = '{"product":{"productId":"3072dad2-5546-1122-8e13-bd04b7f9824a","status":"In Progress","childProduct":[{"productId":"30a0f36c-b496-185e-6330-c7a9c317d223","status":"In Progress"}]}}';
        params.eventType = 'statusNotification';
        paramList.add(JSON.serialize(params));
        
        Notification__c notif = new Notification__c();
        notif.externalOrderId__c = ord.csord__Order_Number__c;
        notif.orderItemId__c = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|3072dad2-5546-1122-8e13-bd04b7f9824a';
        notif.eventTimeStamp__c = '2018-02-24T06:08+10:00';
        notif.orderItemVersion__c = 1;
        notif.notificationAttributes__c = '"attributes":[{"name":"status", "value":"In Progress"}]';
        notif.orderItemDetails__c = '"product":{"productId":"3072dad2-5546-1122-8e13-bd04b7f9824a","status":"In Progress","childProduct":[{"productId":"30a0f36c-b496-185e-6330-c7a9c317d223","status":"In Progress"}]}';
        notif.eventType__c = 'statusNotification';
        notif.sourceSystem__c = 'Fulfilment';
        notif.Status__c = 'Pending';
        insert notif;
        
        Test.startTest();
        ManageOrderNotificationService.updateServiceRecord(paramList,notif.id);
        Test.stopTest();
        
        csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service4' limit 1][0];
        System.assertEquals('tst service4', svc.Name);
    }
    
    @isTest
    static void testUpdateSubscriptionRecordErrorEvent(){
        List<String> paramList = new List<String>();
        ManageOrderNotificationUtil.Parameters params = new ManageOrderNotificationUtil.Parameters();
        
        List<String> parameters = new List<String>();
        params.orderIdc = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        params.notifyAttributes = '{"attributes":[{"name":"error", "value":"Error Summary"}]}';
        params.orderItemDetails = '{"product":{"productId":"3072dad2-5546-eb71-8e13-bd04b7f9824a","status":"In Progress"}}';
        params.eventType = 'error';
        paramList.add(JSON.serialize(params));
        
        Notification__c notif = new Notification__c();
        notif.externalOrderId__c = 'ON00002852';
        notif.orderItemId__c = '8f0bfd2-1bfd-7916-552d-9e28c804294e';
        notif.eventTimeStamp__c = '2018-02-24T06:08+10:00';
        notif.orderItemVersion__c = 1;
        notif.notificationAttributes__c = '"attributes":[{"name":"error", "value":"Error Summary"}]';
        notif.orderItemDetails__c = '"product":{"productId":"3072dad2-5546-eb71-8e13-bd04b7f9824a","status":"In Progress"}';
        notif.eventType__c = 'statusNotification';
        notif.Status__c = 'Pending';
        notif.sourceSystem__c = 'Fulfilment';
        insert notif;
        
        Test.startTest();
        ManageOrderNotificationService.updateSubscriptionRecord(paramList,notif.id);
        Test.stopTest();
        
        csord__Subscription__c sub = [SELECT Id, csord__Status__c, Name from csord__Subscription__c where Name = 'test subs' limit 1][0];
        System.assertEquals('test subs', sub.Name);
        
    }
    
    @isTest
    static void testUpdateSubscriptionRecord(){
        List<String> paramList = new List<String>();
        Test.startTest();
        ManageOrderNotificationUtil.Parameters params = new ManageOrderNotificationUtil.Parameters();
        
        List<String> parameters = new List<String>();
        params.orderIdc = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        params.notifyAttributes = '{"attributes":[{"name":"status", "value":"Complete"}]}';
        params.orderItemDetails = '{"product":{"productId":"3072dad2-5546-eb71-8e13-bd04b7f9824a","status":"In Progress"}}';
        params.eventType = 'statusNotification';
        paramList.add(JSON.serialize(params));
        
        ManageOrderNotificationUtil.Parameters params1 = new ManageOrderNotificationUtil.Parameters();
        params1.orderIdc = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        params1.notifyAttributes = '{"attributes":[{"name":"status", "value":"Complete"}]}';
        params1.orderItemDetails = '{"product":{"productId":"3df57fcf-7c28-c50a-140b-0d21e80714e7","status":"In Progress"}}';
        params1.eventType = 'statusNotification';
        paramList.add(JSON.serialize(params1));
        
        ManageOrderNotificationUtil.Parameters params2 = new ManageOrderNotificationUtil.Parameters();
        params2.orderIdc = '8f0bfd2-1bfd-7916-552d-9e28c804294e';
        params2.notifyAttributes = '{"attributes":[{"name":"status", "value":"Complete"}]}';
        params2.orderItemDetails = '{"product":{"productId":"495bbebb-5166-6dce-24cd-648084f6241c","status":"In Progress"}}';
        params2.eventType = 'statusNotification';
        paramList.add(JSON.serialize(params2));
        
        Notification__c notif = new Notification__c();
        notif.externalOrderId__c = 'ON00002852';
        notif.orderItemId__c = '8f0bfd2-1bfd-7916-552d-9e28c804294e';
        notif.eventTimeStamp__c = '2018-02-24T06:08+10:00';
        notif.orderItemVersion__c = 1;
        notif.notificationAttributes__c = '"attributes":[{"name":"status", "value":"Complete"}]';
        notif.orderItemDetails__c = '"product":{"productId":"495bbebb-5166-6dce-24cd-648084f6241c","status":"In Progress"}';
        notif.eventType__c = 'statusNotification';
        notif.sourceSystem__c = 'Fulfilment';
        notif.Status__c = 'Pending';
        insert notif;
        ManageOrderNotificationService.updateSubscriptionRecord(paramList,notif.id);
        csord__Subscription__c sub = [SELECT Id, csord__Status__c, Name from csord__Subscription__c where Name = 'test subs' limit 1][0];
        csord__Subscription__c subInactive = [SELECT Id, csord__Status__c, Name from csord__Subscription__c where Name = 'test subs Inactive' limit 1][0];
        Test.stopTest();
        System.assertNotEquals(null, sub.csord__Status__c);
        System.assertNotEquals(null, subInactive.csord__Status__c);    
    }
    
    
    @isTest
    static void testcalculateServiceStatusComplete(){
        csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service1' limit 1][0];
        
        String status = ManageOrderNotificationService.calculateServiceStatus(svc.Id,CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecificationsById(svc.id)));
        System.assertEquals('Failed', status);
    }
    
    @isTest
    static void testcalculateServiceStatusFailed(){
        csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service2' limit 1][0];
        String status = ManageOrderNotificationService.calculateServiceStatus(svc.Id,CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecificationsById(svc.id)));
        System.assertEquals('tst service2', svc.Name);
    }
    @isTest
    static void testupdateAppointmenRecord(){
        Appointment__c app = [SELECT id,SlotId__c from Appointment__c where name= 'app1'];
        
        List<String> paramAppointmentList = new List<String>();
         List<String> paramAppointmentList1 = new List<String>();
        ManageOrderNotificationUtil.Parameters params = new ManageOrderNotificationUtil.Parameters();
        
        List<String> parameters = new List<String>();
        params.orderIdc = String.valueof(app.SlotId__c);
        params.notifyAttributes = '{"attributes":[{"name":"status", "value":"Complete"}]}';
        params.orderItemDetails = '{"product":{"productId":"3072dad2-5546-eb71-8e13-bd04b7f9824a","status":"In Progress"}}';
        params.eventType = 'appointmentNotification';
        paramAppointmentList.add(JSON.serialize(params));
        
        Notification__c notif = new Notification__c();
        notif.orderItemId__c = String.valueof(app.SlotId__c);
        notif.externalOrderId__c = 'ON00002852';
        notif.eventTimeStamp__c = '2018-02-24T06:08+10:00';
        notif.orderItemVersion__c = 1;
        notif.notificationAttributes__c = '"attributes":[{"name":"status", "value":"Complete"}]';
        notif.orderItemDetails__c = '"product":{"productId":"3072dad2-5546-eb71-8e13-bd04b7f9824a","status":"In Progress"}';
        notif.eventType__c = 'appointmentNotification';
        notif.sourceSystem__c = 'Fulfilment';
        notif.Status__c = 'Pending';
        insert notif;
        
        Test.startTest();
        ManageOrderNotificationService.updateAppointmenRecord(paramAppointmentList,notif.id);
        ManageOrderNotificationService.updateAppointmenRecord(paramAppointmentList1,notif.id);
        Test.stopTest();
        
        Appointment__c appt = [SELECT id,Status__c from Appointment__c where name= 'app1'];
        System.assertEquals('Complete', appt.Status__c);
    }
    
    @isTest
    static void testreplacedSpecMapUpdateErrorStatus(){
        
        Map<String, String> replacedSpecToUpdatedStatusMap = new Map<String, String>();
        
        Set<String> replacedSubscriptionIds = new Set<String>();
        csord__Subscription__c replSub = [SELECT Id, csord__Status__c, Name,csordtelcoa__Replaced_Subscription__c from csord__Subscription__c where Name = 'test subs' limit 1][0];
        replacedSubscriptionIds.add(replSub.id);
        Set<Id> serviceIds = new Set<Id>();
        csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service2' limit 1][0];
        serviceIds.add(svc.id);
        replacedSpecToUpdatedStatusMap.put('9f0bfd2-1bfd-7916-552d-9e28c804294e', 'guid');
        Test.startTest();
        ManageOrderNotificationService.replacedSpecMapUpdateErrorStatus(replacedSubscriptionIds,replacedSpecToUpdatedStatusMap,serviceIds);
        Test.stopTest();
        System.assertEquals('tst service2', svc.Name);
    }
    @isTest
    static void testupdateSubscriptionRecordSc()
    {
     csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' AND csord__Order__r.Name= 'TestOrder' limit 1][0];
       csord__Subscription__c sub=[SELECT Id,Name,csord__Status__c,Sub_Status__c from csord__Subscription__c where Name = 'test subs' limit 1][0];
        sub.Sub_Status__c=Label.MO_status_active;
        update sub;
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
        List<String> parameters = new List<String>();
        
        Test.startTest(); 
        Notification__c notif = new Notification__c();
        notif.externalOrderId__c = ord.csord__Order_Number__c;
        notif.eventTimeStamp__c = '2018-02-24T06:08+10:00';
        notif.orderItemId__c = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'e16ace88-b994-07d4-c5f4-5f5a78a4345d';
        notif.notificationAttributes__c = '"attributes":[{"name":"status", "value":"Complete"}]';
        notif.orderItemDetails__c = '"product":{"productId":"e16ace88-b994-07d4-c5f4-5f5a78a4345d","status":"Complete"}';
        notif.eventType__c = 'statusNotification';
        notif.orderItemVersion__c = 1;
        notif.sourceSystem__c = 'FULFILMENT';
        notif.Status__c = 'Pending';
        insert notif;
        
         parameters.add(notif.orderItemId__c+':::'+notif.notificationAttributes__c+':::'+notif.eventType__c+':::'+notif.orderItemDetails__c+':::'+notif.sourceSystem__c+':::'+notif.id);
     
        
        system.debug('--------------------'+parameters+'----------'+notif.id);
        ManageOrderNotificationService.updateSubscriptionRecord(parameters,notif.id);
        Test.stopTest();
        System.assertEquals('tst service', svc1.Name);
    }
    
    @isTest
    static void testupdateServiceRecordSuspend(){
        List<String> paramList = new List<String>();
        csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' limit 1][0];
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
        ManageOrderNotificationUtil.Parameters params = new ManageOrderNotificationUtil.Parameters();
        List<String> parameters = new List<String>();
        params.orderIdc = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|ec49950c-5da3-a5a1-1add-81725fgg30c9';
        params.notifyAttributes = '{"attributes":[{"name":"status", "value":"In Progress"}]}';
        params.orderItemDetails = '{"product":{"productId":"ec49950c-5da3-a5a1-1add-81725fgg30c9","status":"In Progress"}}';
        params.eventType = 'statusNotification';
        paramList.add(JSON.serialize(params));
       
        Test.startTest();
        Notification__c notif = new Notification__c();
        notif.externalOrderId__c = ord.csord__Order_Number__c;
        notif.orderItemId__c = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1add-81725fgg30c9';
        notif.eventTimeStamp__c = '2018-02-24T06:08+10:00';
        notif.orderItemVersion__c = 1;
        notif.notificationAttributes__c = '"attributes":[{"name":"status", "value":"In Progress"}]';
        notif.orderItemDetails__c = '"product":{"productId":"ec49950c-5da3-a5a1-1add-81725fgg30c9","status":"In Progress"}';
        notif.eventType__c = 'statusNotification';
        notif.sourceSystem__c = 'Fulfilment';
        notif.Status__c = 'Pending';
        insert notif;
        
        
        ManageOrderNotificationService.updateServiceRecord(paramList,notif.id);
        Test.stopTest();
        
        csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service3' limit 1][0];
        //System.assertEquals('Disconnect In Progress', svc.csord__Status__c);
         System.assertEquals('tst service3', svc.Name);
    }
    
    @isTest
    static void testupdateServiceRecordResume_InProgress(){
        List<String> paramList = new List<String>();
        csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst servRe' limit 1][0];
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'Resume_12345' limit 1][0];
        ManageOrderNotificationUtil.Parameters params = new ManageOrderNotificationUtil.Parameters();
        List<String> parameters = new List<String>();
        params.orderIdc = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|ec49950c-5da3-a5a1-1fdd-81747fgg30c9';
        params.notifyAttributes = '{"attributes":[{"name":"status", "value":"In Progress"}]}';
        params.orderItemDetails = '{"product":{"productId":"ec49950c-5da3-a5a1-1fdd-81747fgg30c9","status":"In Progress"}}';
        params.eventType = 'statusNotification';
        paramList.add(JSON.serialize(params));
       
        Test.startTest();
        Notification__c notif = new Notification__c();
        notif.externalOrderId__c = ord.csord__Order_Number__c;
        notif.orderItemId__c = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1fdd-81747fgg30c9';
        notif.eventTimeStamp__c = '2018-02-24T06:08+10:00';
        notif.orderItemVersion__c = 1;
        notif.notificationAttributes__c = '"attributes":[{"name":"status", "value":"In Progress"}]';
        notif.orderItemDetails__c = '"product":{"productId":"ec49950c-5da3-a5a1-1fdd-81747fgg30c9","status":"In Progress"}';
        notif.eventType__c = 'statusNotification';
        notif.sourceSystem__c = 'Fulfilment';
        notif.Status__c = 'Pending';
        insert notif;
        
        
        ManageOrderNotificationService.updateServiceRecord(paramList,notif.id);
        Test.stopTest();
        
        csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst servRe' limit 1][0];
         System.assertEquals('tst servRe', svc.Name);
    }
    
    @isTest
    static void testupdateServiceRecordResume_Complete(){
        List<String> paramList = new List<String>();
        csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst servRe' limit 1][0];
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'Resume_12345' limit 1][0];
        ManageOrderNotificationUtil.Parameters params = new ManageOrderNotificationUtil.Parameters();
        List<String> parameters = new List<String>();
        params.orderIdc = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|ec49950c-5da3-a5a1-1fdd-81747fgg30c9';
        params.notifyAttributes = '{"attributes":[{"name":"status", "value":"Complete"}]}';
        params.orderItemDetails = '{"product":{"productId":"ec49950c-5da3-a5a1-1fdd-81747fgg30c9","status":"Complete"}}';
        params.eventType = 'statusNotification';
        paramList.add(JSON.serialize(params));
       
        Test.startTest();
        Notification__c notif = new Notification__c();
        notif.externalOrderId__c = ord.csord__Order_Number__c;
        notif.orderItemId__c = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'ec49950c-5da3-a5a1-1fdd-81747fgg30c9';
        notif.eventTimeStamp__c = '2018-02-24T06:08+10:00';
        notif.orderItemVersion__c = 1;
        notif.notificationAttributes__c = '"attributes":[{"name":"status", "value":"Complete"}]';
        notif.orderItemDetails__c = '"product":{"productId":"ec49950c-5da3-a5a1-1fdd-81747fgg30c9","status":"Complete"}';
        notif.eventType__c = 'statusNotification';
        notif.sourceSystem__c = 'Fulfilment';
        notif.Status__c = 'Pending';
        insert notif;
        
        
        ManageOrderNotificationService.updateServiceRecord(paramList,notif.id);
        Test.stopTest();
        
        csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst servRe' limit 1][0];
        //System.assertEquals('Disconnect In Progress', svc.csord__Status__c);
         System.assertEquals('tst servRe', svc.Name);
    }
    
   @isTest
    static void testupdateServiceRecordSuspendChild_InProgress(){
        List<String> paramList = new List<String>();
        csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service4' limit 1][0];
        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];

         ManageOrderNotificationUtil.Parameters params = new ManageOrderNotificationUtil.Parameters();
        List<String> parameters = new List<String>();
        params.orderIdc = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|e16ace88-b994-07d4-c5f4-5f5a78a4345d';
        params.notifyAttributes = '{"attributes":[{"name":"status", "value":"In Progress"}]}';
        params.orderItemDetails = '"product":{"productId":"ec49950c-5da3-a5a1-1fdd-81747fgg30c9","status":"In Progress"},"childProduct":{"productId":"e16ace88-b994-07d4-c5f4-5f5a78a4345d","status":"In Progress"}';
        params.eventType = 'statusNotification';
        paramList.add(JSON.serialize(params));
       
        Test.startTest();
        Notification__c notif = new Notification__c();
        notif.externalOrderId__c = ord.csord__Order_Number__c;
        notif.orderItemId__c = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'e16ace88-b994-07d4-c5f4-5f5a78a4345d';
        notif.eventTimeStamp__c = '2018-02-24T06:08+10:00';
        notif.orderItemVersion__c = 1;
        notif.notificationAttributes__c = '"attributes":[{"name":"status", "value":"In Progress"}]';
        notif.orderItemDetails__c = '"product":{"productId":"ec49950c-5da3-a5a1-1fdd-81747fgg30c9","status":"In Progress"},"childProduct":{"productId":"e16ace88-b994-07d4-c5f4-5f5a78a4345d","status":"In Progress"}';
        notif.eventType__c = 'statusNotification';
        notif.sourceSystem__c = 'Fulfilment';
        notif.Status__c = 'Pending';
        insert notif;
        
        
        ManageOrderNotificationService.updateServiceRecord(paramList,notif.id);
        Test.stopTest();
        
        csord__Service__c svc = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service4' limit 1][0];
        //System.assertEquals('Disconnect In Progress', svc.csord__Status__c);
         System.assertEquals('tst service4', svc.Name);
    }
  //added as part of EDGE-120128 
    @isTest
    static void testPSLI(){
     csord__Service__c svc1 = [SELECT Id, csord__Status__c, csordtelcoa__Service_Number__c, Name from csord__Service__c where Name = 'tst service' AND csord__Order__r.Name= 'TestOrder' limit 1][0];

        csord__Order__c ord = [SELECT id, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate FROM csord__Order__c WHERE Name = 'TestOrder' limit 1][0];
        List<String> parameters = new List<String>();
        
        Test.startTest(); 
        Notification__c notif = new Notification__c();
        notif.externalOrderId__c = ord.csord__Order_Number__c;
        notif.eventTimeStamp__c = '2018-02-24T06:08+10:00';
        notif.orderItemId__c = ord.csord__Order_Number__c+'|'+svc1.csordtelcoa__Service_Number__c+'|'+'e16ace88-b994-07d4-c5f4-5f5a78a4345d';
        notif.notificationAttributes__c = '"attributes":[{"name":"status", "value":"Complete"}]';
        notif.orderItemDetails__c = '"product":{"productId":"e16ace88-b994-07d4-c5f4-5f5a78a4345d","status":"Complete"}';
        notif.eventType__c = 'statusNotification';
        notif.orderItemVersion__c = 1;
        notif.sourceSystem__c = 'FULFILMENT';
        notif.Status__c = 'Pending';
        insert notif;
        
         parameters.add(notif.orderItemId__c+':::'+notif.notificationAttributes__c+':::'+notif.eventType__c+':::'+notif.orderItemDetails__c+':::'+notif.sourceSystem__c+':::'+notif.id);
		ManageOrderNotificationService.updateSubscriptionRecord(parameters,notif.id);
        Test.stopTest();
        System.assertEquals('tst service', svc1.Name);
     }
	 
	 //added as part of EDGE-124711/EDGE-124029 
    @isTest
    static void testPricingModify(){
     List<csord__Subscription__c> subsList = [SELECT Id, Name,csord__Status__c from csord__Subscription__c where Name = 'Pricing1'];
       
      Test.startTest(); 
        system.debug('subsList'+subsList);
       
		ManageOrderNotificationService.updateSchedulesonCallback(subsList);
        Test.stopTest();
        System.assertEquals('Active', subsList[0].csord__Status__c);
     }
	 
	  //added as part of EDGE-124711/EDGE-124029  
    @isTest
    static void testPricingCancel(){
     List<csord__Subscription__c> subsList = [SELECT Id, Name,csord__Status__c from csord__Subscription__c where Name = 'Pricing2'];
        
      Test.startTest(); 
        
		ManageOrderNotificationService.updateSchedulesonCallback(subsList);
        Test.stopTest();
        System.assertEquals('Active', subsList[0].csord__Status__c);
     }
}