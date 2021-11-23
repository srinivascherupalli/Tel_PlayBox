/*
===============================================================================================================================
Class : orderDMLControllerTest
Developer Name : Shweta Khandelwal
base Class : orderDMLController
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1      Shweta Khandelwal   6/4/2020      EDGE-209292
2      Gokul P             17-09-2021    DIGI-16926- TON: Create MACD Basket with Solution in single API call
===============================================================================================================================
*/
@isTest
public class orderDMLControllerTest {
       
    @TestSetup static void dataSetup()
    {
      Account testAccount = new Account();
      testAccount.Name = 'testAccount';
      testAccount.Customer_Status__c = 'ACTIVE';
      insert testAccount;
     
       csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
       insert ordReq;
        
        cscrm__Address__c addrs = new cscrm__Address__c();
        addrs.Address_ID__c = '152365895123';
        addrs.Name = 'Test Address';
        addrs.cscrm__Account__c = testAccount.id;
        insert addrs;
        
        Contact con = new Contact(FirstName = 'Test', LastName = 'Sam', Email='test@test.com');
        con.AccountId=testAccount.id;
        insert con;  
        
        Id RecordTypeIdOrder = Schema.SObjectType.csord__Order__c.getRecordTypeInfosByName().get('Order Submitted with Appointment').getRecordTypeId();

        csord__Order__c testOrder = ProductTestFactory.buildOrder('TestOrder', testAccount.id, 'Created', ordReq.id);
        testOrder.telstra_ord_Start_DateTime__c=System.now(); //EDGE-182667
        testOrder.csord__Order_Request__c = ordReq.Id;
        insert testOrder; 

        csord__Order__c prord = new csord__Order__c();
        prord.csord__Identification__c = 'test identification';
        prord.Name = 'test order';
        prord.csord__Order_Request__c=ordReq.id;
        prord.csord__Status2__c = 'Pending';
        prord.RecordTypeId=RecordTypeIdOrder;
        prord.Scenario_Type__c='';
        insert prord;
        
        CSPOFA__Orchestration_Process_Template__c opt=new CSPOFA__Orchestration_Process_Template__c();
        opt.Name='Order Fulfilment Process';
        insert opt;
        
        csord__Subscription__c testSubscription = new csord__Subscription__c();
        testSubscription.Name = 'TestSubsforTest';
        testSubscription.csord__Account__c = testAccount.Id;
        testSubscription.csord__Order__c = testOrder.Id;
        testSubscription.csord__Identification__c = 'test';
        testSubscription.serviceMSISDN__c = '9876567656';
        //testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription.csord__Status__c = 'Active';

        csord__Subscription__c testSubscription2 = new csord__Subscription__c();
        testSubscription2.Name = 'TestSubsforTest2';
        testSubscription2.csord__Account__c = testAccount.Id;
        testSubscription2.csord__Order__c = testOrder.Id;
        testSubscription2.csord__Identification__c = 'test2';
        testSubscription2.serviceMSISDN__c = '9876567656';
        //testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription2.csord__Status__c = 'Pending';

        csord__Subscription__c testSubscription3 = new csord__Subscription__c();
        testSubscription3.Name = 'TestSubsforTest3';
        testSubscription3.csord__Account__c = testAccount.Id;
        testSubscription3.csord__Order__c = testOrder.Id;
        testSubscription3.csord__Identification__c = 'test3';
        testSubscription3.serviceMSISDN__c = '9876567656';
        //testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription3.csord__Status__c = null;
        
        List<csord__Subscription__c> testSubsList = new List<csord__Subscription__c>{testSubscription,testSubscription2,testSubscription3};
        insert testSubsList;
        
        List<csord__Service__c> servlist=new List<csord__Service__c>();
        List<Attachment> atts = new List<Attachment>();
        List<csord__Subscription__c> testSubs = [SELECT Id,csord__Status__c,csord__Order__c FROM csord__Subscription__c];
            
            csord__Service__c serv2 = new csord__Service__c();
            serv2.name ='testService_'+testSubs[0].id;
            serv2.csord__Identification__c  = 'testIdentify_4';
            serv2.csordtelcoa__Service_Number__c = '3';
            serv2.csord__Subscription__c = testSubs[0].Id;
            serv2.csord__Status__c = 'Created';
            serv2.substage__c = 'Product Requirements Validation';
            serv2.csord__Order_Request__c = ordReq.Id;
            serv2.csord__Order__c = testSubs[0].csord__Order__c;
            insert serv2;
            servlist.add(serv2);
        
            csord__Service__c serv1 = new csord__Service__c();
            serv1.name ='testService_'+testSubs[1].id;
            serv1.csord__Identification__c  = 'testIdentify_4';
            serv1.csordtelcoa__Service_Number__c = '3';
            serv1.csord__Subscription__c = testSubs[1].Id;
            serv1.csord__Status__c = 'Created';
            serv1.csord__Service__c = serv2.Id;
            serv1.substage__c = 'Product Requirements Validation';
            serv1.csord__Order_Request__c = ordReq.Id;
            serv1.csord__Order__c = testSubs[1].csord__Order__c;
            insert serv1;
        servlist.add(serv1);
        //DIGI-16926 start
		cscfga__Product_Definition__c def =  ProductTestFactory.buildProductDefinition('IoT subscription','testplan');
        insert def;
        //Creating Basket test data
        List<cscfga__Product_Basket__c> basketList  =   new List<cscfga__Product_Basket__c>();
        cscfga__Product_Basket__c basket1   =   ProductTestFactory.buildEmptyBasket(); basket1.csordtelcoa__Basket_Stage__c = 'Commercial Configuration'; basketList.add(basket1);
        insert basketList;
        //Creating Solution test data
        List<csord__Solution__c> solutionList = new List<csord__Solution__c>();
        csord__Solution__c solution1    =   new csord__Solution__c(name ='IoT solutions1', csord__Identification__c = 'test', cssdm__product_basket__c=basket1.id, csord__Status__c = 'New');
        solutionList.add(solution1);
        insert solutionList;
        //Creating Product Configuration test data
        List<cscfga__Product_Configuration__c> pcList   =   new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c config1    =   ProductTestFactory.buildProductConfig(def.id);
        config1.cscfga__Product_Basket__c           =   basket1.id;
        config1.cssdm__solution_association__c      =   solution1.id;
        pcList.add(config1);
        insert pcList;
        //Creating Attribute test data
        List<cscfga__Attribute__c> attributeList    =   new List<cscfga__Attribute__c>();
        cscfga__Attribute__c att2   =   ProductTestFactory.buildAttribute('OfferTypeString', 'Right Plan', config1.Id);
        insert attributeList;
        //DIGI-16926 end
        
        for(csord__Service__c serv:servlist){
            Attachment att1 = new Attachment();
            att1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"829aa859-b630-3838-a1f6-0cc45d1254b6","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"IMSI":"","ShippingRequired":"TRUE","DMCAT_ProductSpecification_000263_CPEDeliveryDate":"","SERVICEID":"","BillofMaterialID":"","AccessRole":"","SIMSKU":"NA","CONTEXT":"NA","MESSAGEBANK":"NA","SERVICEPROFILE":"DATA_BACKUP","__targetSystem":"FULFILMENT","IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment"},"additionalAttributes":{"IPWirelessProductInstanceID":"3abb8c65-723c-f4c8-35bf-9230430b0236"}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Bill_AW","metadata":{},"instanceId":"","includeBilling":false,"guid":"21f31282-4d7e-d137-0bd1-6a68d175f9fb","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","attributes":{"IMSI":"","SERVICEID":"","billDescription":"Mobile Interim Access Allowance","RoutingServiceType":"Mobile","value":"Unlimited","unitofMeasure":"GB","type":"Domestic Data","ocsProdID":"T22E_MIA_DATPLAN","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000571","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Billing_NonRecurringCharge_000571","metadata":{},"instanceId":"","includeBilling":false,"guid":"f0ce4f66-186f-5591-62de-e46b9fc877b7","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000571","attributes":{"rateExcludeGST":"","unitofMeasure":"each","billDescription":"IR Day Pass Charge","ocsProdID":"T22E_EMOB_IRDP","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","currency":"AUD","type":"OC","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000572","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Billing_NonRecurringCharge_000572","metadata":{},"instanceId":"","includeBilling":false,"guid":"4e0b2e72-db35-0892-f5fb-d572984ebd6b","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000572","attributes":{"rateExcludeGST":"","billDescription":"IR Data topup Charge","ocsProdID":"T22E_EMOB_IRDTP","unitofMeasure":"each","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","currency":"AUD","type":"OC","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobility_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"5311e403-e5e1-5d83-b2c1-ac90b78e1289","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Fulfilment","attributes":{"MobilityPlan":"CWP Mobile Seat","__targetSystem":"FULFILMENT"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"4c53e7fc-bd0e-9dfc-0c86-c21d3d9a45e7","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"IMSI":"","ShippingRequired":"TRUE","SERVICEID":"","MESSAGEBANK":"","SIMSKU":"100119211","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","SERVICEPROFILE":"NORMAL","__targetSystem":"FULFILMENT"},"additionalAttributes":{"parentSpec":"5311e403-e5e1-5d83-b2c1-ac90b78e1289"}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobility_Billing_RecurringCharge_000498","metadata":{},"instanceId":"","includeBilling":false,"guid":"11966645-20ef-a35d-8f66-bcbccfff31a2","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes":{"billDescription":"CWP Mobile Seat","prorate":"false","billInAdvance":"true","billingSpecId":"BSRC001_CB","frequency":"Monthly","currency":"AUD","type":null,"rateExcludeGST":100,"quantity":"1","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_Allowance_000484_1","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Bill_AW","metadata":{},"instanceId":"","includeBilling":false,"guid":"c72c6680-a658-c856-1234-1a1a5744f7cd","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000484_1","attributes":{"SERVICEID":"","IMSI":"","billDescription":"Mobile Access Allowance","RoutingServiceType":"Mobile","value":"50","unitofMeasure":"GB","type":"Domestic Data","ocsProdID":"T22E_CWP_MOBPLAN","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_Allowance_000607_6","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Bill_AW","metadata":{},"instanceId":"","guid":"8547aa94-68db-f68c-137f-24f04c58c1ef","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000607_6","attributes":{"value":"500","unitofMeasure":"MB","type":"International Roaming Data","ocsProdID":"T22E_EMOB_IRDTP","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_Allowance_000606_5","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Bill_AW","metadata":{},"instanceId":"","guid":"af68080e-e161-399d-7250-40ea06f19506","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000606_5","attributes":{"value":"200","unitofMeasure":"MB","type":"International Roaming Data","ocsProdID":"T22E_EMOB_IRDP","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"'+servlist[0].Id+'","legacyAttributes":[]}');
            att1.Name = 'ServiceSpecifications.json';
            att1.ParentId = serv.Id;          
            atts.add(att1);
        }        
        insert atts;
        
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
    
    @isTest
    public static void createOrderResumne(){
        String tNowCaseRef='TCN123456789';
        Account testAccount = [SELECT id, Name FROM Account LIMIT 1];
        Map<String,String> orderDetails = new Map<String,String>();
        orderDetails.put('AccountId',testAccount.id);
        orderDetails.put('ReferenceNumber',tNowCaseRef);
        orderDetails.put('Reason','eSIM faulty');
        orderDetails.put('OwnerId',UserInfo.getUserId());
        orderDetails.put('ActionType', 'Resume');
        Map<String,String> resultMap=orderDMLController.createOrderRecord(orderDetails);
        System.assertEquals(resultMap.get('code'), '200');
    }
    
    @isTest
    public static void createOrderSIMReplacement(){
        String tNowCaseRef='TCN123456789';
        Account testAccount = [SELECT id, Name FROM Account LIMIT 1];
        Map<String,String> orderDetails = new Map<String,String>();
        orderDetails.put('AccountId',testAccount.id);
        orderDetails.put('ReferenceNumber',tNowCaseRef);
        orderDetails.put('Reason','eSIM faulty');
        orderDetails.put('OwnerId',UserInfo.getUserId());
        orderDetails.put('ActionType', 'SIM Replacement');
        Map<String,String> resultMap=orderDMLController.createOrderRecord(orderDetails);
        System.assertEquals(resultMap.get('code'), '200');
    } 
    
    @isTest
    public static void createOrderSuspend(){ 
        String tNowCaseRef='TCN123456789';
        Account testAccount = [SELECT id, Name FROM Account LIMIT 1];
        Map<String,String> orderDetails = new Map<String,String>();
        orderDetails.put('AccountId',testAccount.id);
        orderDetails.put('ReferenceNumber',tNowCaseRef);
        orderDetails.put('Reason','eSIM faulty');
        orderDetails.put('OwnerId',UserInfo.getUserId());
        orderDetails.put('ActionType', 'Suspend');
        Map<String,String> resultMap=orderDMLController.createOrderRecord(orderDetails);
        System.assertEquals(resultMap.get('code'), '200');
    }
    
    @isTest
    public static void updateServicesDataTestPositive(){
        cscrm__Address__c addrs = [SELECT Id FROM cscrm__Address__c LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        csord__Order__c order = [SELECT Id,csord__Order_Request__c FROM csord__Order__c LIMIT 1];
        List<csord__Subscription__c> subscriptionList = [SELECT csordtelcoa__Subscription_Number__c,serviceMSISDN__c FROM csord__Subscription__c LIMIT 2];
        String serviceData = '[{"Site_Delivery_Contact__c":"'+con.id+'","Delivery_Address__c":"'+addrs.id+'","Subscription_Number__c": "'+subscriptionList[0].csordtelcoa__Subscription_Number__c+'","serviceMSISDN__c": "'+subscriptionList[0].serviceMSISDN__c+'","Sim_Serial_Number__c": "","Requested_SIM_Type__c": "eSIM","Dispatch_Required__c":"YES"},{"Subscription_Number__c": "'+subscriptionList[1].csordtelcoa__Subscription_Number__c+'","serviceMSISDN__c": "'+subscriptionList[0].serviceMSISDN__c+'","Sim_Serial_Number__c": "123456789123A","Requested_SIM_Type__c": "SIM Card","Dispatch_Required__c":"No"}]';
        Map<String, string> cachedDataMap = new Map<String, string>();
        cachedDataMap.put('CorrelationId__c', '008415e6-f785-66b8-811b-bc94838');
        cachedDataMap.put('orderId', order.id);
        cachedDataMap.put('Order_Request__c', order.csord__Order_Request__c);
        cachedDataMap.put('services', serviceData);
        cachedDataMap.put('ActionType', 'Resume');
        Map<String,String> resultMap=orderDMLController.updateServicesData(cachedDataMap);
        System.assertEquals(resultMap.get('code'), '200');               
        
    }
    
        @isTest
    public static void updateServicesDataTestPositiveSIMReplacement(){
        cscrm__Address__c addrs = [SELECT Id FROM cscrm__Address__c LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        csord__Order__c order = [SELECT Id,csord__Order_Request__c FROM csord__Order__c LIMIT 1];
        List<csord__Subscription__c> subscriptionList = [SELECT csordtelcoa__Subscription_Number__c,serviceMSISDN__c FROM csord__Subscription__c LIMIT 2];
        String serviceData = '[{"Site_Delivery_Contact__c":"'+con.id+'","Delivery_Address__c":"'+addrs.id+'","Subscription_Number__c": "'+subscriptionList[0].csordtelcoa__Subscription_Number__c+'","serviceMSISDN__c": "'+subscriptionList[0].serviceMSISDN__c+'","Sim_Serial_Number__c": "","Requested_SIM_Type__c": "eSIM","Dispatch_Required__c":"YES"},{"Subscription_Number__c": "'+subscriptionList[1].csordtelcoa__Subscription_Number__c+'","serviceMSISDN__c": "'+subscriptionList[0].serviceMSISDN__c+'","Sim_Serial_Number__c": "123456789123A","Requested_SIM_Type__c": "SIM Card","Dispatch_Required__c":"No"}]';
        Map<String, string> cachedDataMap = new Map<String, string>();
        cachedDataMap.put('CorrelationId__c', '008415e6-f785-66b8-811b-bc94838');
        cachedDataMap.put('orderId', order.id);
        cachedDataMap.put('Order_Request__c', order.csord__Order_Request__c);
        cachedDataMap.put('services', serviceData);
        cachedDataMap.put('ActionType', 'SIM Replacement');
        Map<String,String> resultMap=orderDMLController.updateServicesData(cachedDataMap);
        System.assertEquals(resultMap.get('code'), '200');               
        
    }
    
    @isTest
    public static void updateServicesDataTestP2(){
        cscrm__Address__c addrs = [SELECT Id FROM cscrm__Address__c LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        csord__Order__c order = [SELECT Id,csord__Order_Request__c FROM csord__Order__c LIMIT 1];
        List<csord__Subscription__c> subscriptionList = [SELECT csordtelcoa__Subscription_Number__c,serviceMSISDN__c FROM csord__Subscription__c LIMIT 2];
        String serviceData = '[{"Site_Delivery_Contact__c":"'+con.id+'","Delivery_Address__c":"'+addrs.id+'","Subscription_Number__c": "'+subscriptionList[0].csordtelcoa__Subscription_Number__c+'","serviceMSISDN__c": "'+subscriptionList[0].serviceMSISDN__c+'","Sim_Serial_Number__c": "","Requested_SIM_Type__c": "eSIM","Dispatch_Required__c":"YES"},{"Subscription_Number__c": "'+subscriptionList[1].csordtelcoa__Subscription_Number__c+'","serviceMSISDN__c": "'+subscriptionList[0].serviceMSISDN__c+'","Sim_Serial_Number__c": "123456789123A","Requested_SIM_Type__c": "SIM Card","Dispatch_Required__c":"No"}]';
        Map<String, string> cachedDataMap = new Map<String, string>();
        cachedDataMap.put('CorrelationId__c', '008415e6-f785-66b8-811b-bc94838');
        cachedDataMap.put('orderId', order.id);
        cachedDataMap.put('Order_Request__c', order.csord__Order_Request__c);
        cachedDataMap.put('services', serviceData);
        cachedDataMap.put('ActionType', 'Suspend');
        Map<String,String> resultMap=orderDMLController.updateServicesData(cachedDataMap);
        System.assertEquals(resultMap.get('code'), '500');               
        
    }
        @isTest
    public static void updateServicesDataTestP3(){
        cscrm__Address__c addrs = [SELECT Id FROM cscrm__Address__c LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        csord__Order__c order = [SELECT Id,csord__Order_Request__c FROM csord__Order__c LIMIT 1];
        List<csord__Subscription__c> subscriptionList = [SELECT csordtelcoa__Subscription_Number__c,serviceMSISDN__c FROM csord__Subscription__c LIMIT 2];
        String serviceData = '[{"Site_Delivery_Contact__c":"'+con.id+'","Delivery_Address__c":"'+addrs.id+'","Subscription_Number__c": "'+subscriptionList[0].csordtelcoa__Subscription_Number__c+'","serviceMSISDN__c": "'+subscriptionList[0].serviceMSISDN__c+'","Sim_Serial_Number__c": "","Requested_SIM_Type__c": "eSIM","Dispatch_Required__c":"YES"},{"Subscription_Number__c": "'+subscriptionList[1].csordtelcoa__Subscription_Number__c+'","serviceMSISDN__c": "'+subscriptionList[0].serviceMSISDN__c+'","Sim_Serial_Number__c": "123456789123A","Requested_SIM_Type__c": "SIM Card","Dispatch_Required__c":"No"}]';
        Map<String, string> cachedDataMap = new Map<String, string>();
        //cachedDataMap.put('CorrelationId__c', '008415e6-f785-66b8-811b-bc94838');
        cachedDataMap.put('orderId', order.id);
        //cachedDataMap.put('Order_Request__c', order.csord__Order_Request__c);
        cachedDataMap.put('services', serviceData);
        //cachedDataMap.put('ActionType', 'Suspend');
        Map<String,String> resultMap=orderDMLController.updateServicesData(cachedDataMap);
        System.assertEquals(resultMap.get('code'), '200');               
        
    }
    

    //invalid contactID
    @isTest
    public static void updateServicesDataTestNegative(){
        cscrm__Address__c addrs = [SELECT Id FROM cscrm__Address__c LIMIT 1];
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        csord__Order__c order = [SELECT Id,csord__Order_Request__c FROM csord__Order__c LIMIT 1];
        List<csord__Subscription__c> subscriptionList = [SELECT csordtelcoa__Subscription_Number__c,serviceMSISDN__c FROM csord__Subscription__c LIMIT 2];
        String serviceData = '[{"Site_Delivery_Contact__c":"345678","Delivery_Address__c":"'+addrs.id+'","Subscription_Number__c": "'+subscriptionList[0].csordtelcoa__Subscription_Number__c+'","serviceMSISDN__c": "'+subscriptionList[0].serviceMSISDN__c+'","Sim_Serial_Number__c": "","Requested_SIM_Type__c": "eSIM","Dispatch_Required__c":"YES"},{"Subscription_Number__c": "'+subscriptionList[1].csordtelcoa__Subscription_Number__c+'","serviceMSISDN__c": "'+subscriptionList[0].serviceMSISDN__c+'","Sim_Serial_Number__c": "123456789123A","Requested_SIM_Type__c": "SIM Card","Dispatch_Required__c":"No"}]';
        Map<String, string> cachedDataMap = new Map<String, string>();
        //cachedDataMap.put('CorrelationId__c', '008415e6-f785-66b8-811b-bc94838');
        cachedDataMap.put('orderId', order.id);
        //cachedDataMap.put('Order_Request__c', order.csord__Order_Request__c);
        cachedDataMap.put('services', serviceData);
        Map<String,String> resultMap=orderDMLController.updateServicesData(cachedDataMap);
        System.assertEquals(resultMap.get('code'), '500');                      
    }

        @isTest
        public static void submitOrderTest(){
        String orderIds = null;
        List<csord__Order__c> ords = [SELECT Id, Name, csord__Status2__c,csord__Identification__c from csord__Order__c where csord__Identification__c='test identification'];
        for(csord__Order__c c:ords){
            orderIds= String.valueOf(c.id);
            system.debug('orderIds'+orderIds);
        }
        orderDMLController.submitOrder(orderIds); 
        csord__Order__c orderRequest =[Select id,csord__Order_Request__c from csord__Order__c where id = :orderIds LIMIT 1];
        List<csord__Service__c> serviceList = [SELECT id,Name,Appointment_Required__c,csord__Order__c FROM csord__Service__c where Appointment_Required__c = 'true' and csord__Order_Request__c = :orderRequest.csord__Order_Request__c];
        List<csord__Order__c> ordsAll = [SELECT Id, Name, recordtypeId,csord__Status2__c,csord__Identification__c from csord__Order__c where id=:orderIds LIMIT 1];
        
        //List<csord__Service__c> servsAll = [SELECT ID,csord__Status__c FROM csord__Service__c WHERE csord__Order__c= : orderIds LIMIT 1];
        List<csord__Subscription__c> subsAll = [SELECT ID,csord__Status__c FROM csord__Subscription__c where csord__Order__c=:orderIds LIMIT 1];
        
        system.debug('list'+ordsAll);
        
        system.assertEquals(ordsAll!=NULL,True,'Order not created');
        //system.assertEquals('Order Submitted', Schema.SObjectType.csord__Order__c.getRecordTypeInfosById().get(ordsAll[0].recordtypeid).getname());    
    }
    
    //DIGI-16926
     @isTest
    public static void createMACDSolutionTest1(){
		       
        Map<String, string> cachedDataMap = new Map<String, string>();
        cachedDataMap.put('CorrelationId__c', '008415e6-f785-66b8-811b-bc94838');
        cachedDataMap.put('serviceMSISDN', '9876567656');
        cachedDataMap.put('ActionType', 'Opportunity Less Basket');
        Map<String,String> resultMap=orderDMLController.createMACDSolution(cachedDataMap);
        System.assertEquals(resultMap.get('code'), '500'); 
    }
     @isTest
    public static void createMACDSolutionTest2(){
		       
        Map<String, string> cachedDataMap = new Map<String, string>();
        cachedDataMap.put('CorrelationId__c', '008415e6-f785-66b8-811b-bc94838');
        cachedDataMap.put('serviceMSISDN', '9876567656');
        cachedDataMap.put('ActionType', 'Opportunity Less Basket');
        String ServiceMISDN1 = '9876567656';
        List <csord__Service__c> subList = [select id,serviceMSISDN__c, csord__Subscription__r.cssdm__solution_association__c from csord__Service__c where serviceMSISDN__c =: ServiceMISDN1 limit 1];
        //string oldsolutionId = subList[0].csord__Subscription__r.cssdm__solution_association__c;
        //List<csord__Solution__c> oldBas=[SELECT Id,cssdm__product_basket__r.id FROM csord__Solution__c where id =: oldsolutionId /*oldbasket*/];
        //String oldBasketid = oldBas[0].cssdm__product_basket__r.id;
        List<Id> solutionIds = new List<Id>();
        for(csord__Solution__c sol:[SELECT Id, cssdm__product_basket__c, cssdm__product_basket__r.csordtelcoa__Basket_Stage__c FROM csord__Solution__c]){
            solutionIds.add(sol.Id);
        }
		String oldsolutionId = solutionIds[0];
        Map<String,String> resultMap=orderDMLController.createMACDSolution(cachedDataMap);
        System.assertEquals(resultMap.get('code'), '500'); 
    }
	@isTest
    public static void getConfigurationSolutionTest1(){

        Map<String, string> cachedDataMap = new Map<String, string>();
        cachedDataMap.put('CorrelationId__c', '008415e6-f785-66b8-811b-bc94838');
        cachedDataMap.put('serviceMSISDN', '9876567656');
        cachedDataMap.put('TargetSolutionId', '123456678');
        String ServiceMISDN1 = '9876567656';
		Map<String,String> resultMap1=orderDMLController.getConfigurationSolution(cachedDataMap);
        /*List <csord__Service__c> subList = [select id,serviceMSISDN__c, csord__Subscription__r.cssdm__solution_association__c from csord__Service__c where serviceMSISDN__c =: ServiceMISDN1 limit 1];
        List<Id> solutionIds = new List<Id>();
        for(csord__Solution__c sol:[SELECT Id, cssdm__product_basket__c, cssdm__product_basket__r.csordtelcoa__Basket_Stage__c FROM csord__Solution__c]){
           solutionIds.add(sol.Id);
        }
        String SolID = solutionIds[0];
        List<csord__Solution__c> listSol =[select cssdm__main_product__c from csord__Solution__c where Id=:SolID];
        csord__Service__c oldService = [SELECT Id, csordtelcoa__Product_Configuration__c, csordtelcoa__Product_Configuration__r.configGUID__c FROM csord__Service__c where serviceMSISDN__c =: ServiceMISDN1 order by CreatedDate Desc limit 1];
        Map<String,String> resultMap=orderDMLController.getConfigurationSolution(cachedDataMap);*/
        System.assertEquals(resultMap1.get('code'), '500'); 

    }
@isTest
        public static void submitOrderMainTestPositive(){
            cscrm__Address__c addrs = [SELECT Id FROM cscrm__Address__c LIMIT 1];
            Contact con = [SELECT Id FROM Contact LIMIT 1];
            csord__Order__c order = [SELECT Id,csord__Order_Request__c FROM csord__Order__c LIMIT 1];
            List<csord__Subscription__c> subscriptionList = [SELECT csordtelcoa__Subscription_Number__c,serviceMSISDN__c FROM csord__Subscription__c LIMIT 2];
            String serviceData = '[{"Site_Delivery_Contact__c":"'+con.id+'","Delivery_Address__c":"'+addrs.id+'","Subscription_Number__c": "'+subscriptionList[0].csordtelcoa__Subscription_Number__c+'","serviceMSISDN__c": "'+subscriptionList[0].serviceMSISDN__c+'","Sim_Serial_Number__c": "","Requested_SIM_Type__c": "eSIM","Dispatch_Required__c":"YES"},{"Subscription_Number__c": "'+subscriptionList[1].csordtelcoa__Subscription_Number__c+'","serviceMSISDN__c": "'+subscriptionList[0].serviceMSISDN__c+'","Sim_Serial_Number__c": "123456789123A","Requested_SIM_Type__c": "SIM Card","Dispatch_Required__c":"No"}]';
            Map<String, string> cachedDataMap = new Map<String, string>();
            cachedDataMap.put('CorrelationId__c', '008415e6-f785-66b8-811b-bc94838');
            cachedDataMap.put('Order_Rec_Id', order.id);
            cachedDataMap.put('Order_Request__c', order.csord__Order_Request__c);
            cachedDataMap.put('services', serviceData);
            cachedDataMap.put('ActionType', 'SIM Replacement');
            Map<String,String> resultMap=orderDMLController.submitOrderMain(cachedDataMap);
            System.assertEquals(resultMap.get('code'), '200');               
            
        }
        // @isTest
        // public static void submitOrderMainTestNegative(){
            
        //     Map<String, string> cachedDataMap = new Map<String, string>();
        //     cachedDataMap.put('ActionType', 'SIM Replacement');
        //     Map<String,String> resultMap=orderDMLController.submitOrderMain(cachedDataMap);
        //     System.assertEquals(resultMap.get('code'), '500');               
            
        // }

        @isTest
        public static void createMACDSolutionTest3(){
                   
            Map<String, string> cachedDataMap = new Map<String, string>();
            cachedDataMap.put('CorrelationId__c', '008415e6-f785-66b8-811b-bc94838');
            cachedDataMap.put('serviceMSISDN', '9876567656');
            cachedDataMap.put('ActionType', 'Opportunity Less Basket');
            List <csord__Service__c> subList = [select id,serviceMSISDN__c, csord__Subscription__r.cssdm__solution_association__c from csord__Service__c where csord__Subscription__r.cssdm__solution_association__c <> null limit 1];
            //string oldsolutionId = subList[0].csord__Subscription__r.cssdm__solution_association__c;
                
            List<csord__Solution__c> oldBas=[SELECT Id,cssdm__product_basket__r.id FROM csord__Solution__c limit 1];
            String oldBasketid = oldBas[0].cssdm__product_basket__r.id;

            Map<String,String> resultMap=orderDMLController.createMACDSolution(cachedDataMap);
            System.assertEquals(resultMap.get('code'), '500'); 
        }
         @isTest
        public static void CreateEventTest(){                   
            orderDMLController.Pl_Event_records_CRU('','','','',true);
        }
        @isTest
        public static void CreateEventTest2(){                   
            orderDMLController.Pl_Event_records_CRU('','','','',false);
        }

    @isTest
    public static void skipContractTest1(){

        List<cscfga__Product_Basket__c> prdBsk = [SELECT id from cscfga__Product_Basket__c limit 1] ;                   
        List<csord__Solution__c> oldBas=[SELECT Id,cssdm__product_basket__r.id FROM csord__Solution__c limit 1];

        String oldBasketid = oldBas[0].cssdm__product_basket__r.id;
        Map<String, string> cachedDataMap = new Map<String, string>();
        cachedDataMap.put('correlationId', '008415e6-f785-66b8-811b-bc94838');
        cachedDataMap.put('TargetBasketId', prdBsk[0].id);
        cachedDataMap.put('OldSolutionId', oldBas[0].id);   
        Map<String,String> resultMap=orderDMLController.skipContractForBasket(cachedDataMap);
        System.assertEquals(resultMap.get('code'), '500');               
        
    }
}