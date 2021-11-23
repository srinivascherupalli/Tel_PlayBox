/**
**/
@isTest
private class CS_SpecificationDTOTest {
    
     @TestSetup static void dataSetup() {
        
        Account acc=new Account();
        acc.Name='testacc';
        acc.CIDN__c='987654321';
        acc.ABN__c='1235';
        acc.Customer_Status__c='ACTIVE';
        insert acc;
        
        Contact contact = AccountTestFactory.buildContact(acc, 'Smiths');
        insert contact;
        
        cscrm__Address__c address = new cscrm__Address__c();
        address.Name='Unit 1 1234 Lostmy Way';
        address.Address_Line_1__c='Unit 4 Mahatma';
        address.Locality__c='Sydney';
        address.cscrm__Zip_Postal_Code__c='2000';
        address.cscrm__State_Province__c='NSW';
        address.cscrm__Country__c='Australia';
        address.cscrm__Street_Name__c ='Melbourne';
        
        insert address;
        
        Billing_Account__c billingAccount=new Billing_Account__c();
        billingAccount.Billing_Account_Number__c='123456789322';
        billingAccount.Billing_Address__c=address.id;
        billingAccount.Billing_Account_Owner__c=contact.Id;
        billingAccount.Account__c=acc.Id;
        insert billingAccount;
        
        
        cscrm__Site__c  site = AccountTestFactory.buildSite(address.Id, acc.Id);
        site.Primary_Contact__c = contact.Id;
        site.cscrm__Installation_Address__r = address;
        insert site;
      
        csord__Order__c ord = new csord__Order__c();
        ord.csord__Identification__c = 'test identification';
        ord.csord__Account__c = acc.id;
        ord.csord__Order_Type__c = 'test order' ;
        ord.Billing_Account__c = billingAccount.id;
        insert ord;
        
        csord__Order__c secOrd = new csord__Order__c();
        secOrd.csord__Identification__c = 'test identification';
        secOrd.csord__Account__c = acc.id;
        secOrd.csord__Order_Type__c = 'test order' ;
        secOrd.Billing_Account__c = billingAccount.id;
        secOrd.csord__Primary_Order__c = ord.id;
        insert secOrd;
        
        cscfga__Configuration_Offer__c OriginatingOffer = new cscfga__Configuration_Offer__c(name ='Test Originating offer');
        insert OriginatingOffer;
        
        cscfga__Product_Configuration__c productConfig = new cscfga__Product_Configuration__c();
        productConfig.Offer_Reference__c = OriginatingOffer.id;
    productConfig.Type__c = 'Cancel';
        insert productConfig;
        
    
    csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.Site__c = site.Id;
        subs.csord__Status__c='Subscription Created';
        subs.csordtelcoa__Subscription_Number__c = 'SN-000003199';
        subs.csord__Order__c = secOrd.id;
        subs.csordtelcoa__Product_Configuration__c = productConfig.id;
    subs.Serviceability_Location__c = 'Urban';
        insert subs;
        
       
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify';
        serv.csord__Subscription__c  = subs.id;
        serv.csord__Order__c = ord.id;
        serv.csordtelcoa__Service_Number__c = '3';
        insert serv;
    
      /*csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Status__c = 'Pending';
        //subs.csord__Order__c = ord.id;
        insert subs;
    System.debug('subs inserted:'+subs);         
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service1';
        serv.csord__Identification__c  = 'test identify1';
        serv.csordtelcoa__Service_Number__c = '3';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Status__c = 'Pending';
        insert serv;
        System.debug('service inserted:'+serv);*/
    
    
        Attachment attUCMobile = new Attachment();
        attUCMobile.Name = 'ServiceSpecifications.json';
        attUCMobile.ParentId = serv.Id;
        attUCMobile.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"a4e2O0000004xwG","specifications":[{"additionalAttributes":{"SERVICEID":"61429751286","DMCAT_ProductSpecification_000263_CPEDeliveryDate":"2019-02-15T08:00:00","IPWirelessProductInstanceID":"6eb08c83-b098-2ca8-b7a5-14a884585c30"},"attributes":{"IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment","__targetSystem":"FULFILMENT","SERVICEPROFILE":"DATA_BACKUP","MESSAGEBANK":"NA","INTROAM":"NA","CONTEXT":"NA","CALLCONTROL":"NA","AccessRole":"Primary","BillofMaterialID":"160f44ab-6be5-433f-ab5e-750f44b8b19b","SERVICEID":"","DMCAT_ProductSpecification_000263_CPEDeliveryDate":"","ShippingRequired":"TRUE","IMSI":"","SIMSerialNumber":""},"code":"DMCAT_ProductSpecification_000263_Fulfilment","description":"","endDate":"","guid":"cbc76a67-4404-29d8-5e11-308955d90822","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2O000000GV3GUAW","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263","startDate":"","status":"In Progress","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"ASSURANCE","ServiceManagementOption ":"1"},"code":"DMCAT_ProductSpecification_000326_Assurance","description":"","endDate":"","guid":"2fd726fd-f547-b136-8f32-0aa323a5e3ea","includeBilling":false,"instanceId":"","metadata":{},"name":"Telstra Managed Service Option 1_Assurance","productConfigurationId":"a3T2O000000GV3GUAW","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000326","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"ocsProd2","type":"Domestic Data","unitofMeasure":"GB","value":"Unlimited","RoutingServiceType":"Mobile","SERVICEID":"","IMSI":""},"code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","description":"","endDate":"","guid":"040265c5-13b0-28b0-1965-0b091adae7ba","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobile Access_Bill_AW","productConfigurationId":"a3T2O000000GV3GUAW","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"ocsProd3","type":"Dummy ngUC","unitofMeasure":"GB","value":"Unlimited","RoutingServiceType":"Voice"},"code":"DMCAT_ProductSpecification_000313_Billing_Allowance_000512_4","description":"","endDate":"","guid":"4a094253-e91a-62b4-f6f0-bb354ded8868","includeBilling":false,"instanceId":"","metadata":{},"name":"UC Numbers_Bill_AW","productConfigurationId":"a3T2O000000GV3GUAW","specification":"DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313_Billing_Allowance_000512_4","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"DMCAT_ProductSpecification_000322_CPEDeliveryDate":"2019-02-15T08:00:00","BSServiceTypeProductInstanceID":"403d93a3-5c71-1663-8dc7-e51ab07bf4b8"},"attributes":{"BSServiceTypeProductInstanceID":"DMCAT_ProductSpecification_000312_Fulfilment","__targetSystem":"FULFILMENT","CustomerFacingServiceId":"","CustomerPreferredName":"","DMCAT_ProductSpecification_000322_CPEDeliveryDate":""},"code":"DMCAT_ProductSpecification_000322_Fulfilment","description":"","endDate":"","guid":"197ae1b8-9901-402c-290a-efd6e0740459","includeBilling":false,"instanceId":"","metadata":{},"name":"UC Site_Fulfilment","productConfigurationId":"a3T2O000000GV3GUAW","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000322","startDate":"","status":"In Progress","version":"1"},{"additionalAttributes":{"InternetProtectionSolutionProductInstanceID":"b03fd5dd-c2f5-3fec-82dd-b621e16368b5"},"attributes":{"__targetSystem":"FULFILMENT","UserProtectionType":"Web and Mail","InternetProtectionSolutionProductInstanceID":"DMCAT_ProductSpecification_000163_Fulfilment","Quantity":"3"},"code":"DMCAT_ProductSpecification_000162_Fulfilment","description":"","endDate":"","guid":"e634201f-a357-ca27-92ec-d5368b8c8bed","includeBilling":false,"instanceId":"","metadata":{},"name":"Web and Mail Internet Protection User_Fulfilment","productConfigurationId":"a3T2O000000GV3GUAW","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000162","startDate":"","status":"In Progress","version":"1"},{"additionalAttributes":{"parentSpec":"2fd726fd-f547-b136-8f32-0aa323a5e3ea"},"attributes":{"__targetSystem":"ASSURANCE","parentSpec":"DMCAT_ProductSpecification_000326_Assurance","ResponseTarget":"SLA0010001","RestoreTarget":"SLA0010002"},"code":"DMCAT_ProductSpecification_000151_Assurance","description":"","endDate":"","guid":"5f735f33-0af6-8fb7-644a-8681ca0d258c","includeBilling":false,"instanceId":"","metadata":{},"name":"Incident Management_Assurance","productConfigurationId":"a3T2O000000GV3GUAW","specification":"DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"parentSpec":"197ae1b8-9901-402c-290a-efd6e0740459"},"attributes":{"__targetSystem":"FULFILMENT","name":"Hosted UC","CustomerFacingServiceId":"","id":"","parentSpec":"DMCAT_ProductSpecification_000322_Fulfilment","Quantity":3},"code":"DMCAT_ProductSpecification_000315_Fulfilment","description":"","endDate":"","guid":"2a0ef56f-f963-1faf-828c-a21967099d85","includeBilling":false,"instanceId":"","metadata":{},"name":"Feature Packs_Fulfilment","productConfigurationId":"a3T2O000000GV3GUAW","specification":"DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000315","startDate":"","status":"In Progress","version":"1"},{"additionalAttributes":{"parentSpec":"197ae1b8-9901-402c-290a-efd6e0740459"},"attributes":{"parentSpec":"DMCAT_ProductSpecification_000322_Fulfilment","__targetSystem":"FULFILMENT","VoicePlan":"Complete Premium","id":"","CustomerFacingServiceId":"","Number":[{"schemaId":"2c3f0a69-f86c-fcfe-86ff-42e2f58bc3ab","attributes":{"FNN":"1111111111","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}},{"schemaId":"6c9ca3f1-bde7-43a2-06ce-5625f3cfa3e8","attributes":{"FNN":"2222222222","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}},{"schemaId":"43ebbd8e-27e6-3d72-2235-76cdc32b33df","attributes":{"FNN":"3333333333","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}},{"schemaId":"e058b794-660f-e00b-34b5-ee92f0973d6e","attributes":{"FNN":"8282345567","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}},{"schemaId":"7503f70d-8252-ceca-511a-9c97ccf4061d","attributes":{"FNN":"8282345566","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}},{"schemaId":"5679bbbb-5bf3-f3e9-b80f-3138cf48c21e","attributes":{"FNN":"8282345568","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}},{"schemaId":"042b8d27-541b-bec4-cb6f-7c95d2198afe","attributes":{"FNN":"8282345569","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}},{"schemaId":"458791cb-9671-da71-c352-5bc182e529d5","attributes":{"FNN":"8282345516","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}},{"schemaId":"ccd8dc11-5a51-831d-18c0-2cadc85b500d","attributes":{"FNN":"8282345526","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}},{"schemaId":"4b76e4bc-6fdb-14cf-fdb5-2ea1b5135801","attributes":{"FNN":"8282345536","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}},{"schemaId":"e78aa0ce-d9a2-4607-0d2b-07c73d7aade4","attributes":{"FNN":"8282345546","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}}]},"code":"DMCAT_ProductSpecification_000313_Fulfilment","description":"","endDate":"","guid":"2d59449c-0097-46e3-b555-ebed20aaec3e","includeBilling":false,"instanceId":"","metadata":{},"name":"UC Numbers_Fulfilment","productConfigurationId":"a3T2O000000GV3GUAW","specification":"DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313","startDate":"","status":"In Progress","version":"1"}]}');
        insert attUCMobile;

        //

        Test.StartTest();
        List<Account> lstOfAccount =Coms_TestDataFactory.createAccount();
        insert lstOfAccount;
        System.assertEquals(10,lstOfAccount.size());
        //create opportunities
        List<Opportunity> lstOpp=Coms_TestDataFactory.createOpportunity(lstOfAccount);
        insert lstOpp;
        System.assertEquals(10,lstOpp.size());
        //create orders
        List<csord__Order__c> lstOrder=Coms_TestDataFactory.createOrder(lstOfAccount,lstOpp);
        insert lstOrder;
        System.assertEquals(10,lstOrder.size());
        //create subscriptions
        List<csord__Subscription__c> lstSubscription=Coms_TestDataFactory.createSubscription(lstOfAccount,lstOrder);
        insert lstSubscription;
        System.assertEquals(10,lstSubscription.size());
        //create services
        List<csord__Service__c> lstServices=Coms_TestDataFactory.createServicesWithOrders(lstSubscription,lstOrder);
        insert lstServices;
        System.assertEquals(10,lstServices.size());
        //create orchestration
        List<Orchestration_Technical__c> lstOrchestration=Coms_TestDataFactory.createOrchestration(lstServices);
        insert lstOrchestration;
        System.assertEquals(10,lstOrchestration.size());
        // create Technical_Child_Attribute__c
        List<Technical_Child_Attribute__c> lsttestOrchestrationChild=Coms_TestDataFactory.createOrchestrationChild(lstOrchestration);
        insert lsttestOrchestrationChild;
        System.assertEquals(50,lsttestOrchestrationChild.size());
        //create Charge_Line_Item__c
        List<Charge_Line_Item__c> lstcli=Coms_TestDataFactory.createChargeLIneItem(lstServices);
        insert lstcli;
        System.assertEquals(10,lstcli.size());
        //create Number__c
        List<Number__c> lstnum=Coms_TestDataFactory.createNumber(lstOfAccount,lstcli);
        insert lstnum;
        System.assertEquals(10,lstnum.size());
        //create Price_Schedule_Line_Item__c
        List<Price_Schedule_Line_Item__c> lstpsli=Coms_TestDataFactory.createPSLI(lstcli);
        insert lstpsli;
        System.assertEquals(10,lstpsli.size());
        //create Discount_Line_Item__c
        List<Discount_Line_Item__c> lstdli=Coms_TestDataFactory.createDLI(lstcli);
        insert lstdli;
     }
    
    @isTest static void test_SpecificationDTO() {
        // Implement test code
        //String json =  '[{"version":"1","status":"Created","startDate":"","simpleAttributes":[{"value":"Zone 3","name":"Zone"},{"value":"1500.00","name":"TotalMRC"},{"value":"5","name":"Seat"},{"value":"contantValue","name":"constantName"}],"replacedSpecification":"","productConfigurationId":"ConfigId","name":"CWPSpec","instanceId":"","identifier":"30a0f36c-b496-185e-6330-c7a9c317d22c","guid":"3072dad2-5546-eb71-8e13-bd04b7f9824a","endDate":"","description":"CWP CFS Specification","complexAttributes":{"complexIPAccess":[{"simpleAttributes":[{"value":"8080","name":"complexAttrPort"},{"value":"Fibre","name":"complexAttrTech"}],"productConfigurationId":"ConfigId1"},{"simpleAttributes":[{"value":"FULFILMENT","name":"complexAttrPort_targetSystem"},{"value":"Ethernet","name":"complexAttrTech"}],"productConfigurationId":"ConfigId2"}]},"code":"CWPSpec01"},{"version":"1","status":"Created","startDate":"","simpleAttributes":[{"value":"8080","name":"Port"},{"value":"Fibre","name":"Technology"},{"value":"constantValue","name":"constantAttr"}],"replacedSpecification":"","productConfigurationId":"ConfiId3","name":"IPAccessSpec","instanceId":"","identifier":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","guid":"3df57fcf-7c28-c50a-140b-0d21e80714e7","endDate":"","description":"IP Access Specification","complexAttributes":{},"code":"IPAccessSpec01"},{"version":"1","status":"Created","startDate":"","simpleAttributes":[{"value":"9090","name":"Port"},{"value":"Ethernet","name":"Technology"},{"value":"constantValue","name":"constantAttr"}],"replacedSpecification":"","productConfigurationId":"ConfigId4","name":"IPAccessSpec","instanceId":"","identifier":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","guid":"495bbebb-5166-6dce-24cd-648084f6241c","endDate":"","description":"IP Access Specification","complexAttributes":{},"code":"IPAccessSpec01"}]';
        String json =  '[{"version":"1","status":"Created","startDate":"","simpleAttributes":[{"value":"FULFILMENT","name":"Zone_targetSystem"},{"value":"FULFILMENT","name":"TotatMRC_targetSystem"},{"value":"FULFILMENT","name":"Seat_targetSystem"},{"value":"FULFILMENT","name":"constantName_targetSystem"}],"replacedSpecification":"","productConfigurationId":"ConfigId","name":"CWPSpec","instanceId":"","identifier":"30a0f36c-b496-185e-6330-c7a9c317d22c","guid":"3072dad2-5546-eb71-8e13-bd04b7f9824a","endDate":"","description":"CWP CFS Specification","complexAttributes":{"complexIPAccess":[{"simpleAttributes":[{"value":"FULFILMENT","name":"complexAttrPort_targetSystem"},{"value":"FULFILMENT","name":"complexAttrTech_targetSystem"}],"productConfigurationId":"ConfigId1"},{"simpleAttributes":[{"value":"FULFILMENT","name":"complexAttrPort_targetSystem"},{"value":"FULFILMENT","name":"complexAttrTech_targetSystem"}],"productConfigurationId":"ConfigId2"}]},"code":"CWPSpec01"},{"version":"1","status":"Created","startDate":"","simpleAttributes":[{"value":"FULFILMENT","name":"Port_targetSystem"},{"value":"FULFILMENT","name":"Technology_targetSystem"},{"value":"FULFILMENT","name":"constantAttr_targetSystem"}],"replacedSpecification":"","productConfigurationId":"ConfiId3","name":"IPAccessSpec","instanceId":"","identifier":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","guid":"3df57fcf-7c28-c50a-140b-0d21e80714e7","endDate":"","description":"IP Access Specification","complexAttributes":{},"code":"IPAccessSpec01"},{"version":"1","status":"Created","startDate":"","simpleAttributes":[{"value":"FULFILMENT","name":"Port_targetSystem"},{"value":"FULFILMENT","name":"Technology_targetSystem"},{"value":"constantValue","name":"constantAttr"}],"replacedSpecification":"","productConfigurationId":"ConfigId4","name":"IPAccessSpec","instanceId":"","identifier":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","guid":"495bbebb-5166-6dce-24cd-648084f6241c","endDate":"","description":"IP Access Specification","complexAttributes":{},"code":"IPAccessSpec01"}]';
        List<String> specCodeList = new List<String>();
        specCodeList.add('DMCAT_ProductSpecification_000263_Fulfilment');
        specCodeList.add('DMCAT_ProductOffering_000302');
        specCodeList.add('CWPSpec01');
        List<CS_SpecificationDTO.ServiceSpecification> svcSpec = new List<CS_SpecificationDTO.ServiceSpecification>();
        List<CS_SpecificationDTO.ServiceSpecification> subSpec = new List<CS_SpecificationDTO.ServiceSpecification>();
        
        svcSpec = CS_SpecificationDTO.parseServiceSpec(json);
        subSpec = CS_SpecificationDTO.parseSubscriptionSpec(json);
         CS_SpecificationDTO.parseSubscriptionSpec(json);
        // CS_SpecificationDTO.parseSubscriptionSpec(json, 'FULFILMENT');
        CS_SpecificationDTO.parseServiceSpec(json, 'FULFILMENT');
        CS_SpecificationDTO.parse(json);
        CS_SpecificationDTO.parse(json, 'FULFILMENT');
        CS_SpecificationDTO.parseServiceSpec(json,'FULFILMENT',specCodeList);
        System.debug(svcSpec);
        
        System.debug(svcSpec[0].version);
        System.assert(svcSpec[0].version == String.valueOf(1));
        System.debug(svcSpec[0].status);
        System.assert(svcSpec[0].status == 'Created');
        System.debug(svcSpec[0].startDate);
        System.assert(svcSpec[0].startDate == '');
        System.debug(svcSpec[0].replacedSpecification);
        System.assert(svcSpec[0].replacedSpecification == '');
        System.debug(svcSpec[0].productConfigurationId);
        System.assert(svcSpec[0].productConfigurationId == 'ConfigId');
        System.debug(svcSpec[0].name);
        System.assert(svcSpec[0].name == 'CWPSpec');
        System.debug(svcSpec[0].instanceId);
        System.assert(svcSpec[0].instanceId == '');
        System.debug(svcSpec[0].identifier );
        System.assert(svcSpec[0].identifier == '30a0f36c-b496-185e-6330-c7a9c317d22c');
        System.debug(svcSpec[0].guid);
        System.assert(svcSpec[0].guid == '3072dad2-5546-eb71-8e13-bd04b7f9824a');
        System.debug(svcSpec[0].code);
        System.assert(svcSpec[0].code == 'CWPSpec01');
        System.debug(svcSpec[0].endDate);
        System.assert(svcSpec[0].endDate == '');
        System.debug(svcSpec[0].description);
        System.assert(svcSpec[0].description == 'CWP CFS Specification');
        System.debug(svcSpec[0].simpleAttributes[0].name);
        //System.assert(svcSpec[0].simpleAttributes[0].name == 'Zone');
        System.debug(svcSpec[0].simpleAttributes[0].value);
        //System.assert(svcSpec[0].simpleAttributes[0].value == 'Zone 3');
        System.debug(svcSpec[0].complexAttributes.get('complexIPAccess')[0].simpleAttributes[0].name );
        System.assert(svcSpec[0].complexAttributes.get('complexIPAccess')[0].simpleAttributes[0].name == 'complexAttrPort_targetSystem');
        System.debug(svcSpec[0].complexAttributes.get('complexIPAccess')[0].simpleAttributes[0].value);
        System.assert(svcSpec[0].complexAttributes.get('complexIPAccess')[0].simpleAttributes[0].value == 'FULFILMENT');
        System.debug(svcSpec[0].complexAttributes.get('complexIPAccess')[0].productConfigurationId);
        System.assert(svcSpec[0].complexAttributes.get('complexIPAccess')[0].productConfigurationId == 'ConfigId1');

   }
    @isTest
    public static void testparseSpecs(){
        String json =  '[{"version":"1","status":"Created","startDate":"","simpleAttributes":[{"value":"FULFILMENT","name":"Zone_targetSystem"},{"value":"FULFILMENT","name":"TotatMRC_targetSystem"},{"value":"FULFILMENT","name":"Seat_targetSystem"},{"value":"FULFILMENT","name":"constantName_targetSystem"}],"replacedSpecification":"","productConfigurationId":"ConfigId","name":"CWPSpec","instanceId":"","identifier":"30a0f36c-b496-185e-6330-c7a9c317d22c","guid":"3072dad2-5546-eb71-8e13-bd04b7f9824a","endDate":"","description":"CWP CFS Specification","complexAttributes":{"complexIPAccess":[{"simpleAttributes":[{"value":"FULFILMENT","name":"complexAttrPort_targetSystem"},{"value":"FULFILMENT","name":"complexAttrTech_targetSystem"}],"productConfigurationId":"ConfigId1"},{"simpleAttributes":[{"value":"FULFILMENT","name":"complexAttrPort_targetSystem"},{"value":"FULFILMENT","name":"complexAttrTech_targetSystem"}],"productConfigurationId":"ConfigId2"}]},"code":"CWPSpec01"},{"version":"1","status":"Created","startDate":"","simpleAttributes":[{"value":"FULFILMENT","name":"Port_targetSystem"},{"value":"FULFILMENT","name":"Technology_targetSystem"},{"value":"FULFILMENT","name":"constantAttr_targetSystem"}],"replacedSpecification":"","productConfigurationId":"ConfiId3","name":"IPAccessSpec","instanceId":"","identifier":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","guid":"3df57fcf-7c28-c50a-140b-0d21e80714e7","endDate":"","description":"IP Access Specification","complexAttributes":{},"code":"IPAccessSpec01"},{"version":"1","status":"Created","startDate":"","simpleAttributes":[{"value":"FULFILMENT","name":"Port_targetSystem"},{"value":"FULFILMENT","name":"Technology_targetSystem"},{"value":"constantValue","name":"constantAttr"}],"replacedSpecification":"","productConfigurationId":"ConfigId4","name":"IPAccessSpec","instanceId":"","identifier":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","guid":"495bbebb-5166-6dce-24cd-648084f6241c","endDate":"","description":"IP Access Specification","complexAttributes":{},"code":"IPAccessSpec01"}]';
        List<String> specCodeList = new List<String>();
        specCodeList.add('CWPSpec01');
        csord__Service__c serv = [SELECT Id, Name, csord__Subscription__r.Id from csord__Service__c limit 1];
        System.debug('serv selected:'+serv);
        String targetSystem = 'FULFILMENT';
        CS_SpecificationDTO.ServiceSpecification srvSpec = new CS_SpecificationDTO.ServiceSpecification();
        String servId = serv.Id;
        System.debug('servId'+servId);
        srvSpec.serviceId = servId;
        //srvSpec.simpleAttributes[0].name= 'test_targetsystem';
        //srvSpec.simpleAttributes[0].value= 'FULFILMENT';
        List<CS_SpecificationDTO.ServiceSpecification> srvSpecList = new List<CS_SpecificationDTO.ServiceSpecification>();
        srvSpecList.add(srvSpec);
        CS_SpecificationDTO.SubscriptionSpecifications subSpec = new CS_SpecificationDTO.SubscriptionSpecifications();
        subSpec.serviceSpecificationList = srvSpecList;
        subSpec.serviceName = serv.name;
        subSpec.subscriptionId = serv.csord__Subscription__r.Id;
        List<CS_SpecificationDTO.SubscriptionSpecifications> subSpecList = new List<CS_SpecificationDTO.SubscriptionSpecifications>();
        subSpecList.add(subSpec);
        CS_SpecificationDTO.OrderSpecifications ordSpec = new CS_SpecificationDTO.OrderSpecifications();
        ordSpec.orderId= [Select Id from csord__Order__c limit 1].id;
        ordSpec.subscriptionSpecificationList = subSpecList;
        List<CS_SpecificationDTO.OrderSpecifications> ordSpecList = new List<CS_SpecificationDTO.OrderSpecifications>();
        ordSpecList.add(ordSpec);
        CS_SpecificationDTO.parseSpecs(srvSpecList, subSpec, targetSystem);
        CS_SpecificationDTO.parse(json);
        CS_SpecificationDTO.parse(json, targetSystem);
        system.assertNotEquals(json, NULL);
    }
  
  @isTest
  public static void testparseSubscriptionSpec(){
    
    for(csord__Subscription__c sub : [select id, Site__r.Display_Name__c,csordtelcoa__Replacement_Subscription__c,csordtelcoa__Product_Configuration__r.Type__c,site__r.Address__c,Serviceability_Location__c,csord__Order__r.csord__Order_Number__c from csord__Subscription__c where name = 'test subs' LIMIT 1]){
        String subSpec = csedm.API_1.getSubscriptionSpecificationsById(sub.id);
         
       // subSpec.serviceSpecificationList = srvSpecList;
       // subSpec.serviceName = serv.name;
        //subSpec.subscriptionId = serv.csord__Subscription__r.Id;
        List<CS_SpecificationDTO.ServiceSpecification> srvSpecList = CS_SpecificationDTO.parseSubscriptionSpec(subSpec, 'FULFILMENT');
        System.debug('srvSpecList::: ' + srvSpecList);
    System.assertNotEquals(subSpec, NULL);
  }
  }
 /**
    * @description 
    * @author Rohit Pal | 10-05-2021 
    **/
    @isTest
    static void testgetObjectSobject() {
        Test.StartTest();
        Map<string , object> mapObject = new Map<string , object>();
        csord__Order__c getRecor=[SELECT Id,Name,CorrelationId__c,Platform_Cache_Timestamp__c,csord__Status2__c FROM csord__Order__c WHERE name='TestOrderNameForTest' limit 1];
        system.debug('getRecor --- > ' + getRecor) ;
        // getRecor.CorrelationId__c = getRecor.id;
        // getRecor.Platform_Cache_Timestamp__c = system.now();
        List<csord__Service__c> serviceId=[SELECT  Id, Name,CorrelationId__c,Platform_Cache_Timestamp__c, 
                                                csord__Order__c, csordtelcoa__Product_Configuration__c, 
                                                csordtelcoa__Replaced_Service__c, toBeCancelled__c, csord__Status__c, 
                                                csord__Order_Request__c,  csordtelcoa__Service_Number__c, 
                                                csord__Subscription__c, csord__Subscription__r.CorrelationId__c,
                                                csordtelcoa__Replaced_Service__r.csord__Status__c, 
                                                csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__c, 
                                                csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.EDMSpecToSuppressInRTB__c,
                                                CreatedDate, csordtelcoa__Replaced_Service__r.CorrelationId__c, 
                                                csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,
                                                Billing_Account__r.Billing_Account_Owner__c,csord__Subscription__r.csord__Account__c,
                                                mainCharge__r.Type__c,csordtelcoa__Product_Configuration__r.cssdm__solution_association__r.Name,
                                                csord__Subscription__r.csordtelcoa__Subscription_Number__c,csord__Subscription__r.csord__Order__c,
                                                csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c,changeType__c,
                                                csord__Subscription__r.Suspension_reason__c,Scenario_Type__c,Sim_Serial_Number__c,csord__Service__c,
                                                csord__Service__r.changeType__c,csord__Order__r.Scenario_Type__c,csord__Subscription__r.orderversion__c,
                                                csord__Order__r.Fulfilment_Order_Version__c,csord__Order__r.Product_Basket__r.BasketType__c,
                                                Marketable_Offer__c,csord__Subscription__r.cssdm__solution_association__c,csord__Subscription__r.Trigger_RTS__c,
                                                csord__Order__r.name,Action_Type__c,OrderTransientDataDetails__c 
                                        FROM csord__Service__c WHERE csord__Order__c=: getRecor.id limit 1];
        //serviceId[0].CorrelationId__c = getRecor.id+'Serv1';
        system.debug('serviceId --- > ' + serviceId) ;
        List<Orchestration_Technical__c> orchesId=[SELECT Id,Name,CorrelationId__c,
                                                            Platform_Cache_Timestamp__c,External_Id_1__c,Service__c,	
                                                            Field_1__c,Field_3__c,Field_7__c,Field_13__c,Field_15__c,Field_10__c,
                                                            Field_4__c,Field_19__c,Field_8__c,Field_9__c,Field_6__c,Field_14__c,
                                                            Field_2__c,Field_11__c,Field_5__c,Field_12__c 
                                                    FROM Orchestration_Technical__c WHERE Service__c =: serviceId[0].Id ];
        //orchesId[0].CorrelationId__c = getRecor.id+'Serv1'+'OT';
       // serviceId[0].csord__Order__r =getRecor;
        //orchesId[0].Platform_Cache_Timestamp__c = system.now();
      // orchesId[0].Service__c = serviceId[0].id;
       // orchesId[0].Service__r = serviceId[0];
        //orchesId[0].Service__r = serviceId[0];
        system.debug('orchesId --- > ' + orchesId);
        update orchesId;
        Technical_Child_Attribute__c objTechnicalChildAttribute = new Technical_Child_Attribute__c ();
        objTechnicalChildAttribute.put('Orchestration_Technical__c' , orchesId[0].id);
        objTechnicalChildAttribute.put('Complex_Attribute_Schema_Id__c' , '345678');
        objTechnicalChildAttribute.put('Field_1__c' ,'Test 1');
        objTechnicalChildAttribute.put('Field_5__c' , 'Test 2');
        objTechnicalChildAttribute.put('Field_3__c' , 'Test 3');
        objTechnicalChildAttribute.put('Field_2__c' , 'Test 4');
        objTechnicalChildAttribute.put('Field_4__c' , 'Test 5');
        objTechnicalChildAttribute.put('Field_6__c' , 'Test 5');
        objTechnicalChildAttribute.put('Category__c' , 'Simple Attributes');
        objTechnicalChildAttribute.put('Platform_Cache_Timestamp__c' , system.now());
        insert objTechnicalChildAttribute;
        Technical_Child_Attribute__c objTechnicalChildAttributeCom = new Technical_Child_Attribute__c ();
        objTechnicalChildAttributeCom.put('Orchestration_Technical__c' , orchesId[0].id);
        objTechnicalChildAttributeCom.put('Complex_Attribute_Schema_Id__c' , '3456781');
        objTechnicalChildAttributeCom.put('Field_1__c' ,'Test 1');
        objTechnicalChildAttributeCom.put('Field_5__c' , 'Test 2');
        objTechnicalChildAttributeCom.put('Field_3__c' , 'Test 3');
        objTechnicalChildAttributeCom.put('Field_2__c' , 'Test 4');
        objTechnicalChildAttributeCom.put('Field_4__c' , 'Test 5');
        objTechnicalChildAttributeCom.put('Field_6__c' , 'Test 5');
        objTechnicalChildAttributeCom.put('Category__c' , 'Simple Attributes');
        objTechnicalChildAttributeCom.put('Platform_Cache_Timestamp__c' , system.now());
        insert objTechnicalChildAttributeCom;
        Technical_Child_Attribute__c objTechnicalChildAttribute1 = new Technical_Child_Attribute__c ();
        objTechnicalChildAttribute1.put('Orchestration_Technical__c' , orchesId[0].id);
        objTechnicalChildAttribute1.put('Complex_Attribute_Schema_Id__c' , '3456789');
        objTechnicalChildAttribute1.put('Field_1__c' ,'Test 1');
        objTechnicalChildAttribute1.put('Field_5__c' , 'Test 2');
        objTechnicalChildAttribute1.put('Field_3__c' , 'Test 3');
        objTechnicalChildAttribute1.put('Field_2__c' , 'Test 4');
        objTechnicalChildAttribute1.put('Field_4__c' , 'Test 5');
        objTechnicalChildAttribute1.put('Field_6__c' , 'Test 5');
        objTechnicalChildAttribute1.put('Category__c' , 'Complex Attributes');
        objTechnicalChildAttribute1.put('Platform_Cache_Timestamp__c' , system.now());
        insert objTechnicalChildAttribute1;
        Technical_Child_Attribute__c objTechnicalChildAttribute11 = new Technical_Child_Attribute__c ();
        objTechnicalChildAttribute11.put('Orchestration_Technical__c' , orchesId[0].id);
        objTechnicalChildAttribute11.put('Complex_Attribute_Schema_Id__c' , '34567891');
        objTechnicalChildAttribute11.put('Field_1__c' ,'Test 1');
        objTechnicalChildAttribute11.put('Field_5__c' , 'Test 2');
        objTechnicalChildAttribute11.put('Field_3__c' , 'Test 3');
        objTechnicalChildAttribute11.put('Field_2__c' , 'Test 4');
        objTechnicalChildAttribute11.put('Field_4__c' , 'Test 5');
        objTechnicalChildAttribute11.put('Field_6__c' , 'Test 5');
        objTechnicalChildAttribute11.put('Category__c' , 'Complex Attributes');
        objTechnicalChildAttribute11.put('Platform_Cache_Timestamp__c' , system.now());
        insert objTechnicalChildAttribute11;
        //getSubscription[0].csord__Order__r =getRecor;
        // objTechnicalChildAttribute.Orchestration_Technical__r = orchesId[0];
        // update objTechnicalChildAttribute;
        system.debug('objTechnicalChildAttribute --- > ' + objTechnicalChildAttribute) ;
        //String jsonPayload = '{"a4b2N000000jCFbQAM":{"attributes":{"type":"csord__Order__c","url":"/services/data/v52.0/sobjects/csord__Order__c/a4b2N000000jCFbQAM"},"Id":"a4b2N000000jCFbQAM","Name":"Test11","CorrelationId__c":"a4b2N000000jCFbQAM","Platform_Cache_Timestamp__c":"2021-09-28T11:14:36.595+0000"}}	';
        //mapObject.put('a4b2N000000jCFbQAM' , jsonPayload);
        mapObject.put(objTechnicalChildAttribute.Id , objTechnicalChildAttribute);
        String jsonPayload = JSON.serialize(mapObject);
        Map<string , object> newMap = new Map<string , object>();
        //newMap.put(objTLSSession.TLS_CorrelationId__c , objTLSSession.TLS_PayLoad__c );
        Coms_PlatformCacheUtil.insertTechnicalChildAttribute(new set<id>{orchesId[0].id} , getRecor.id);
        List<sobject> listTechnical = Coms_PlatformCacheUtil.getTechnicalChildAttributes(getRecor.id , new set<id>{serviceId[0].id});
        System.debug('listTechnical ---> ' + listTechnical);
        CS_SpecificationDTO.parseServiceSpec(new set<id>{serviceId[0].id} , getRecor.id);
        Test.StopTest();
    }

}