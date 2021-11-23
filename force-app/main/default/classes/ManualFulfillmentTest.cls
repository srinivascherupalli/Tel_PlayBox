/**
This class is written for story EDGE-118623.
This is the test class for ManualFulfillmentTest
**/
/***History of Updates
Purushottama Sahu: 29/04/2020  EDGE-137134  Added fflib_SObjectUnitOfWork Framework and For NGUC FCR will create for the Parent Subscription
**/
@isTest
public class ManualFulfillmentTest {
        @TestSetup static void dataSetup() {

            list<CSPOFA__Orchestration_Process_Template__c> orcheList = new list<CSPOFA__Orchestration_Process_Template__c>();
        CSPOFA__Orchestration_Process_Template__c orchProcessTemplate1 = new CSPOFA__Orchestration_Process_Template__c();
        orchProcessTemplate1.Name = 'Service Fulfilment Process';
        orchProcessTemplate1.CSPOFA__Process_Type__c = 'New Provide';
        orchProcessTemplate1.CSPOFA__Processing_Mode__c = 'Foreground';
        orcheList.add(orchProcessTemplate1);
        insert orcheList;
        List<Marketable_Offer__c> listOfOffers= new List<Marketable_Offer__c>();
        Marketable_Offer__c momdm = new Marketable_Offer__c();
        momdm.OfferDefinationName__c ='MDM Tenancy' ;
        momdm.Name = 'Test MOdfs';
        momdm.Offer_ID__c = 'D12sd333s';
        momdm.Config__c='{"noLineItem":true,"skipBasketSyncValidations":true,"isSOWrequired":true,"SOMOpenAir":true}';
       // listOfOffers.add(momdm);
         Marketable_Offer__c moMob = new Marketable_Offer__c();
        moMob.OfferDefinationName__c ='Professional Services-MDM Config' ;
        moMob.Name = 'Professional Services-MDM Config';
        moMob.type__c = 'Professional Service'; //EDGE-137134 >> +
        moMob.Offer_ID__c = 'D12sd337s';
        moMob.Config__c='{"noLineItem":true,"skipBasketSyncValidations":true,"isSOWrequired":true,"SOMOpenAir":true}';
        listOfOffers.add(moMob);
        
        Marketable_Offer__c moMob1 = new Marketable_Offer__c();
        moMob1.OfferDefinationName__c ='Mobility Managed Serive' ;
        moMob1.Name = 'Mobility Managed Serive';
        moMob1.Offer_ID__c = 'D12sd337s';
        moMob1.type__c = 'Managed Service'; //EDGE-137134 >> +
        moMob1.Config__c='{"noLineItem":true,"skipBasketSyncValidations":true,"isSOWrequired":false,"SOMOpenAir":true}';
        listOfOffers.add(moMob1);
		
         //DPG-1914: Adaptive Care
         Marketable_Offer__c moMob2 = new Marketable_Offer__c();
        moMob2.OfferDefinationName__c ='Mobility Managed Serive' ;
        moMob2.Name = 'Mobility Managed Serive';
        moMob2.Offer_ID__c = 'DMCAT_Offer_001251';
        moMob2.type__c = 'Managed Service'; //EDGE-137134 >> +
        moMob2.Config__c='{"noLineItem":true,"skipBasketSyncValidations":true,"isSOWrequired":false,"SOMOpenAir":true}';
          listOfOffers.add(moMob2);
            
        insert listOfOffers;
          //  csordtelcoa__Product_Configuration__c 
        cscfga__Configuration_Offer__c offername1= new cscfga__Configuration_Offer__c();
        offername1.name='Professional Services Solution';
        offername1.cscfga__Active__c=true;
        offername1.cscfga__Description__c='Professional Services Solution';
        insert offername1;
        //New Change                
        cscfga__Product_Definition__c productDefinition = new cscfga__Product_Definition__c();
        productDefinition.Name = 'Test Product Definition';
        productDefinition.cscfga__Description__c = 'Test Product Definition Description';
        productDefinition.RecordTypeId = '012280000011E6gAAE';
        productDefinition.product_Specification__c = 'DMCAT_ProductSpecification_000718';
        insert productDefinition;
           list<cscfga__Product_Configuration__c>productconfiglist= new list<cscfga__Product_Configuration__c>();
           cscfga__Product_Configuration__c PCNewMdm = new cscfga__Product_Configuration__c();
            PCNewMdm.cscfga__Product_Definition__c = productDefinition.Id; //New Change
      //  PCNewMdm.cscfga__Product_Basket__c = basketMAC.id;
        PCNewMdm.name='Professional Services-MDM Config';
        PCNewMdm.Type__c='New';
        PCNewMdm.cscfga__originating_offer__c=offername1.id;
       // PCNewMdm.csordtelcoa__Replaced_Product_Configuration__c = oldPC.id;
        PCNewMdm.Marketable_Offer__c = moMob.id;
        productconfiglist.add(PCNewMdm); 

        cscfga__Product_Configuration__c pcMMs = ProductTestFactory.buildProductConfig(productDefinition.id);
        pcMMs.name= 'Mobility Managed Serive';
        pcMMs.Marketable_Offer__c=moMob1.id;
        pcMMs.ConfigurationType1__c = 'SolutionComponent';
        productconfiglist.add(pcMMs);   
        
        //DPG-1914: Adaptive Care  
         cscfga__Product_Configuration__c pcMMs1 = ProductTestFactory.buildProductConfig(productDefinition.id);
        pcMMs1.name= 'Mobility Managed Serive';
        pcMMs1.Marketable_Offer__c=moMob1.id;
        pcMMs1.ConfigurationType1__c = '';
        pcMMs1.Type__c='Cancel';
        productconfiglist.add(pcMMs1); 
        
        //DPG-1914: Adaptive Care
        cscfga__Product_Configuration__c pcMMs2 = ProductTestFactory.buildProductConfig(productDefinition.id);
        pcMMs2.name= 'Mobility Managed Serive';
        pcMMs2.Marketable_Offer__c=moMob2.id;
        pcMMs2.ConfigurationType1__c = 'SolutionComponent';
        productconfiglist.add(pcMMs2); 
        
       insert productconfiglist; 
       
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        acc.Customer_Status__c = 'ACTIVE';
        insert acc;
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
            
		 //DPG-1914: Adaptive Care
         Billing_Account__c billingAccount = ProductTestFactory.getBillingAccount();
        insert billingAccount;
            
        profile pSysAdmin = [select id,name from Profile where Name =:'System Administrator'];
        User SysAdmin = new User(alias = 'Con123', email='ContactTr8wrw98@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid =pSysAdmin.id, country='United States',IsActive =true,                
                timezonesidkey='America/Los_Angeles', username=uniqueName+'Cont987657awqas@noemail.com');
          
        insert SysAdmin;
        User u1 ;
        System.runAs(SysAdmin){ 
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        SysAdmin.userroleid=r.id;
        update SysAdmin;

        id p = [select id from profile where name=:System.label.PRM_Community_User /*'PRM Community User - Australia'*/].id;
        Account parnerAcc = new Account(name ='Telecom') ;
        insert parnerAcc; 
        Contact con = new Contact(FirstName = 'Contact', LastName ='testCon',AccountId = parnerAcc.Id, Onboarding_Status__c = 'Active',Contact_Status__c='Active',Partner_Role__c='Telstra Collaboration Operations User;Engineering User');
        insert con; 

      u1 = new User(alias = 'test123', email='test12345@noemail.com',
                           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                           localesidkey='en_US', Profileid = p, country='United States',IsActive =true,
                           ContactId = con.Id,
                           timezonesidkey='America/Los_Angeles', username=uniqueName+'test12345@noemail.com');
        
        insert u1;
       }
  
        Opportunity opp  = new Opportunity();
        opp.Name = 'TestOpp';
        opp.AccountID = acc.id;
       // opp.StageName = 'Committed';
        opp.StageName = 'Define';
        opp.Product_Type__c = 'Modular';
        opp.CloseDate = System.today();
      //  opp.Ownerid=u1.id;
        insert opp;
            
                 
                 
        cscfga__Product_Definition__c pd2= ProductTestFactory.buildProductDefinition('Professional Services','Professional Services');
        pd2.product_Specification__c = 'DMCAT_ProductSpecification_000537';
        insert pd2;
        cscfga__Product_Configuration__c pc2 = ProductTestFactory.buildProductConfig(pd2.id);
        pc2.name= 'Professional Services-MDM Config';
        pc2.Marketable_Offer__c=moMob.id;
        insert pc2;
            
        
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
        list<csord__Order__c> ordlist= new list<csord__Order__c>();
        csord__Order__c order = ProductTestFactory.buildOrder('PrimaryOrder', acc.id, 'Created', ordReq.id);
        order.csord__Order_Request__c = ordReq.Id;
        order.csordtelcoa__Opportunity__c = opp.id;
        ordlist.add(order); //insert order; 
        
        csord__Order__c SOrd = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        SOrd.csord__Order_Request__c = ordReq.Id;
        SOrd.csord__Primary_Order__c = order.Id;
        ordlist.add(SOrd); //insert SOrd;
        
        csord__Order__c order1 = ProductTestFactory.buildOrder('Test Order1', acc.id, 'Created', ordReq.id);
        order1.csord__Order_Request__c = ordReq.Id;
        order1.csordtelcoa__Opportunity__c = opp.id;
       ordlist.add(order1); 
        
        
        insert ordlist;
       
        //Subscription 
        csord__Subscription__c testSubscription6 = new csord__Subscription__c();
        testSubscription6.Name = 'TestSubsforTest12';
        testSubscription6.csord__Account__c = acc.Id;
        testSubscription6.csord__Order__c = order1.Id;
        testSubscription6.csord__Identification__c = 'test';
        testSubscription6.csordtelcoa__Product_Configuration__c = pcMMs.Id;
        testSubscription6.csord__Status__c = 'Active';
        testSubscription6.MarketableOffer__c=moMob1.id;
        
        csord__Subscription__c testSubscription1 = new csord__Subscription__c();
        testSubscription1.Name = 'TestSubsforTest1';
        testSubscription1.MarketableOffer__c=moMob.id;
        testSubscription1.csord__Account__c = acc.Id;
        testSubscription1.csord__Order__c = order.Id;
        testSubscription1.csord__Identification__c = 'test';
        testSubscription1.csordtelcoa__Product_Configuration__c = PCNewMdm.Id;
        testSubscription1.csord__Status__c = 'Active';
           //New Change 
       
        csord__Subscription__c testSubscription = new csord__Subscription__c();
        testSubscription.Name = 'TestSubsforTest';
        testSubscription.csord__Account__c = acc.Id;
        testSubscription.csord__Order__c = SOrd.Id;
        testSubscription.csord__Identification__c = 'test';
        //testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription.csordtelcoa__Product_Configuration__c = pc2.Id;
        testSubscription.csord__Status__c = 'Active';
        csord__Subscription__c testSubscription2 = new csord__Subscription__c();
        testSubscription2.Name = 'TestSubsforTest2';
        testSubscription2.csord__Account__c = acc.Id;
        testSubscription2.csord__Order__c = SOrd.Id;
        testSubscription2.csord__Identification__c = 'test2';
        //testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription2.csord__Status__c = 'Pending';
        csord__Subscription__c testSubscription3 = new csord__Subscription__c();
        testSubscription3.Name = 'TestSubsforTest3';
        testSubscription3.csord__Account__c = acc.Id;
        testSubscription3.csord__Order__c = SOrd.Id;
        testSubscription3.csord__Identification__c = 'test3';
        //testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription3.csord__Status__c = 'Active';
        csord__Subscription__c testSubscription4 = new csord__Subscription__c();
        testSubscription4.Name = 'TestSubsforTest4';
        testSubscription4.csord__Account__c = acc.Id;
        testSubscription4.csord__Order__c = SOrd.Id;
        testSubscription4.csord__Identification__c = 'test';
        //testSubscription4.csordtelcoa__Product_Configuration__c = testConfig1.Id;
        testSubscription4.csord__Status__c = 'Active';
        csord__Subscription__c testSubscription5 = new csord__Subscription__c();
        testSubscription5.Name = 'TestSubsforTest5';
        testSubscription5.csord__Account__c = acc.Id;
        testSubscription5.csord__Order__c = SOrd.Id;
        testSubscription5.csord__Identification__c = 'test';
        //testSubscription5.csordtelcoa__Product_Configuration__c = testConfig3.Id;
        testSubscription5.csord__Status__c = 'Closed Replaced';
         
        //DPG-1914: Adaptive Care
         csord__Subscription__c testSubscription7 = new csord__Subscription__c();
        testSubscription7.Name = 'TestSubsforTest17';
        testSubscription7.csord__Account__c = acc.Id;
        testSubscription7.csord__Order__c = order.Id;
        testSubscription7.csord__Identification__c = 'test';
        testSubscription7.csordtelcoa__Product_Configuration__c = pcMMs1.Id;
        testSubscription7.csord__Status__c = 'Active';
        testSubscription7.MarketableOffer__c=moMob1.id;
         
         //DPG-1914: Adaptive Care
        csord__Subscription__c testSubscription8 = new csord__Subscription__c();
        testSubscription8.Name = 'TestSubsforTest18';
        testSubscription8.csord__Account__c = acc.Id;
        testSubscription8.csord__Order__c = order.Id;
        testSubscription8.csord__Identification__c = 'test';
        testSubscription8.csordtelcoa__Product_Configuration__c = pcMMs2.Id;
        testSubscription8.csord__Status__c = 'Active';
        testSubscription8.MarketableOffer__c=moMob2.id;
        testSubscription8.Billing_Account__c=billingAccount.id;
          testSubscription8.triggerBill_RTB__c=true;
            
        List<csord__Subscription__c> testSubsList = new List<csord__Subscription__c>{testSubscription,testSubscription1,testSubscription2,testSubscription3,testSubscription4,testSubscription5,testSubscription6,testSubscription7,testSubscription8};
        insert testSubsList;
       system.debug('testSubscription7' +testSubscription7);
            //service
        List<csord__Service__c> servlist=new List<csord__Service__c>();
        integer i=0;
        for(csord__Subscription__c testSubs:[SELECT Id,csord__Status__c,csord__Order__c FROM csord__Subscription__c])
        {           
            csord__Service__c serv = new csord__Service__c();
            serv.name ='testService_'+i;
            serv.csord__Identification__c  = 'testIdentify_4';
            serv.csordtelcoa__Service_Number__c = '3';
            serv.csord__Subscription__c = testSubs.Id;
            serv.csord__Status__c = 'Created';
            serv.substage__c = 'Product Requirements Validation';
            serv.csord__Order_Request__c = ordReq.Id;
            serv.csord__Order__c = testSubs.csord__Order__c;
            servlist.add(serv);
            i++;
        }
        insert servlist;
        // Test Data for getServiceSpecFromSubsIdForMobility
            csord__Service__c servMobile = new csord__Service__c();
            servMobile.name ='CWP Mobile 1';
            servMobile.csord__Identification__c  = 'testIdentify_4';
            servMobile.csordtelcoa__Service_Number__c = '3';
            servMobile.csord__Subscription__c = testSubscription2.Id;
            servMobile.csord__Status__c = 'Created';
            servMobile.substage__c = 'Product Requirements Validation';
            servMobile.csord__Order_Request__c = ordReq.Id;
            servMobile.csord__Order__c = testSubscription2.csord__Order__c;
        insert servMobile;
        //////
        List<Attachment> atts = new List<Attachment>();
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Disconnect Pending","startDate":"","specification":"30a0f36c-b496-185e-6330-c7a9c317d22c","productConfigurationId":"a0b0Y000001oXmtQAE","name":"CWPSpec","instanceId":"1234","guid":"3072dad2-5546-eb71-8e13-bd04b7f9824a","endDate":"","description":"CWP CFS Specification","code":"CWPSpec01_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","Zone":"Zone 3","TotalMRC":1500,"Seat":5,"complexIPAccess":[{"attributes":{"complexAttrPort":8080,"complexAttrTech":"Fibre"},"productConfigurationId":"a0b0Y000001oXmyQAE"},{"attributes":{"complexAttrPort":9090,"complexAttrTech":"Ethernet"},"productConfigurationId":"a0b0Y000001oXn3QAE"}],"constantName":"contantValue"}},{"version":"1","status":"Cancellation Pending","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXmyQAE","name":"IPAccessSpec","instanceId":"3456","guid":"3df57fcf-7c28-c50a-140b-0d21e80714e7","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","Port":8080,"Technology":"Fibre","constantAttr":"constantValue"}},{"version":"1","status":"Pending","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXn3QAE","name":"IPAccessSpec","instanceId":"6789","guid":"495bbebb-5166-6dce-24cd-648084f6241c","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","Port":9090,"Technology":"Ethernet","constantAttr":"constantValue"}}],"serviceId":"'+servlist[0].Id+'","legacyAttributes":[]}');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = servlist[0].Id;
        atts.add(att1);
        Attachment att2 = new Attachment();
        att2.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Disconnect Pending","startDate":"","specification":"30a0f36c-b496-185e-6330-c7a9c317d22c","productConfigurationId":"a0b0Y000001oXmtQAE","name":"CWPSpec","instanceId":"1234","guid":"3072dad2-5546-eb71-8e13-bd04b7f9824a","endDate":"","description":"CWP CFS Specification","code":"CWPSpec01_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","Zone":"Zone 3","TotalMRC":1500,"Seat":5,"complexIPAccess":[{"attributes":{"complexAttrPort":8080,"complexAttrTech":"Fibre"},"productConfigurationId":"a0b0Y000001oXmyQAE"},{"attributes":{"complexAttrPort":9090,"complexAttrTech":"Ethernet"},"productConfigurationId":"a0b0Y000001oXn3QAE"}],"constantName":"contantValue"}},{"version":"1","status":"Cancellation Pending","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXmyQAE","name":"IPAccessSpec","instanceId":"3456","guid":"3df57fcf-7c28-c50a-140b-0d21e80714e7","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","Port":8080,"Technology":"Fibre","constantAttr":"constantValue"}},{"version":"1","status":"Pending","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXn3QAE","name":"IPAccessSpec","instanceId":"6789","guid":"495bbebb-5166-6dce-24cd-648084f6241c","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","Port":9090,"Technology":"Ethernet","constantAttr":"constantValue"}}],"serviceId":"'+servlist[1].Id+'","legacyAttributes":[]}');
        att2.Name = 'ServiceSpecifications.json';
        att2.ParentId = servlist[1].Id;
        atts.add(att2);
        Attachment att3= new Attachment();
        att3.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"829aa859-b630-3838-a1f6-0cc45d1254b6","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"IMSI":"","ShippingRequired":"TRUE","DMCAT_ProductSpecification_000263_CPEDeliveryDate":"","SERVICEID":"","BillofMaterialID":"","AccessRole":"","SIMSKU":"NA","CONTEXT":"NA","MESSAGEBANK":"NA","SERVICEPROFILE":"DATA_BACKUP","__targetSystem":"FULFILMENT","IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment"},"additionalAttributes":{"IPWirelessProductInstanceID":"3abb8c65-723c-f4c8-35bf-9230430b0236"}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Bill_AW","metadata":{},"instanceId":"","includeBilling":false,"guid":"21f31282-4d7e-d137-0bd1-6a68d175f9fb","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","attributes":{"IMSI":"","SERVICEID":"","billDescription":"Mobile Interim Access Allowance","RoutingServiceType":"Mobile","value":"Unlimited","unitofMeasure":"GB","type":"Domestic Data","ocsProdID":"T22E_MIA_DATPLAN","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000571","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Billing_NonRecurringCharge_000571","metadata":{},"instanceId":"","includeBilling":false,"guid":"f0ce4f66-186f-5591-62de-e46b9fc877b7","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000571","attributes":{"rateExcludeGST":"","unitofMeasure":"each","billDescription":"IR Day Pass Charge","ocsProdID":"T22E_EMOB_IRDP","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","currency":"AUD","type":"OC","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000572","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Billing_NonRecurringCharge_000572","metadata":{},"instanceId":"","includeBilling":false,"guid":"4e0b2e72-db35-0892-f5fb-d572984ebd6b","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000572","attributes":{"rateExcludeGST":"","billDescription":"IR Data topup Charge","ocsProdID":"T22E_EMOB_IRDTP","unitofMeasure":"each","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","currency":"AUD","type":"OC","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobility_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"5311e403-e5e1-5d83-b2c1-ac90b78e1289","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Fulfilment","attributes":{"MobilityPlan":"CWP Mobile Seat","__targetSystem":"FULFILMENT"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"4c53e7fc-bd0e-9dfc-0c86-c21d3d9a45e7","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"IMSI":"","ShippingRequired":"TRUE","SERVICEID":"","MESSAGEBANK":"","SIMSKU":"100119211","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","SERVICEPROFILE":"NORMAL","__targetSystem":"FULFILMENT"},"additionalAttributes":{"parentSpec":"5311e403-e5e1-5d83-b2c1-ac90b78e1289"}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobility_Billing_RecurringCharge_000498","metadata":{},"instanceId":"","includeBilling":false,"guid":"11966645-20ef-a35d-8f66-bcbccfff31a2","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes":{"billDescription":"CWP Mobile Seat","prorate":"false","billInAdvance":"true","billingSpecId":"BSRC001_CB","frequency":"Monthly","currency":"AUD","type":null,"rateExcludeGST":100,"quantity":"1","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_Allowance_000484_1","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Bill_AW","metadata":{},"instanceId":"","includeBilling":false,"guid":"c72c6680-a658-c856-1234-1a1a5744f7cd","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000484_1","attributes":{"SERVICEID":"","IMSI":"","billDescription":"Mobile Access Allowance","RoutingServiceType":"Mobile","value":"50","unitofMeasure":"GB","type":"Domestic Data","ocsProdID":"T22E_CWP_MOBPLAN","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_Allowance_000607_6","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Bill_AW","metadata":{},"instanceId":"","guid":"8547aa94-68db-f68c-137f-24f04c58c1ef","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000607_6","attributes":{"value":"500","unitofMeasure":"MB","type":"International Roaming Data","ocsProdID":"T22E_EMOB_IRDTP","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_Allowance_000606_5","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Bill_AW","metadata":{},"instanceId":"","guid":"af68080e-e161-399d-7250-40ea06f19506","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000606_5","attributes":{"value":"200","unitofMeasure":"MB","type":"International Roaming Data","ocsProdID":"T22E_EMOB_IRDP","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"'+servlist[2].Id+'","legacyAttributes":[]}');
        att3.Name = 'ServiceSpecifications.json';
        att3.ParentId = servlist[2].Id;
        atts.add(att3);
        //create attachment
        Attachment att4= new Attachment();
        att4.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"829aa859-b630-3838-a1f6-0cc45d1254b6","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"IMSI":"","ShippingRequired":"TRUE","DMCAT_ProductSpecification_000263_CPEDeliveryDate":"","SERVICEID":"","BillofMaterialID":"","AccessRole":"","SIMSKU":"NA","CONTEXT":"NA","MESSAGEBANK":"NA","SERVICEPROFILE":"DATA_BACKUP","__targetSystem":"FULFILMENT","IPWirelessProductInstanceID":"DMCAT_ProductSpecification_000018_Fulfilment"},"additionalAttributes":{"IPWirelessProductInstanceID":"3abb8c65-723c-f4c8-35bf-9230430b0236"}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Bill_AW","metadata":{},"instanceId":"","includeBilling":false,"guid":"21f31282-4d7e-d137-0bd1-6a68d175f9fb","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000494_3","attributes":{"IMSI":"","SERVICEID":"","billDescription":"Mobile Interim Access Allowance","RoutingServiceType":"Mobile","value":"Unlimited","unitofMeasure":"GB","type":"Domestic Data","ocsProdID":"T22E_MIA_DATPLAN","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000571","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Billing_NonRecurringCharge_000571","metadata":{},"instanceId":"","includeBilling":false,"guid":"f0ce4f66-186f-5591-62de-e46b9fc877b7","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000571","attributes":{"rateExcludeGST":"","unitofMeasure":"each","billDescription":"IR Day Pass Charge","ocsProdID":"T22E_EMOB_IRDP","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","currency":"AUD","type":"OC","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000572","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Billing_NonRecurringCharge_000572","metadata":{},"instanceId":"","includeBilling":false,"guid":"4e0b2e72-db35-0892-f5fb-d572984ebd6b","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_NonRecurringCharge_000572","attributes":{"rateExcludeGST":"","billDescription":"IR Data topup Charge","ocsProdID":"T22E_EMOB_IRDTP","unitofMeasure":"each","taxTreatment":"TAX Exempt","billingSpecId":"BSUSG002_CB","currency":"AUD","type":"OC","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobility_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"5311e403-e5e1-5d83-b2c1-ac90b78e1289","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Fulfilment","attributes":{"MobilityPlan":"CWP Mobile Seat","__targetSystem":"FULFILMENT"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"4c53e7fc-bd0e-9dfc-0c86-c21d3d9a45e7","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Fulfilment","attributes":{"IMSI":"","ShippingRequired":"TRUE","SERVICEID":"","MESSAGEBANK":"","SIMSKU":"100119211","parentSpec":"DMCAT_ProductSpecification_000420_Fulfilment","CONTEXT":"CUSTOMER","AccessRole":"Primary","BillofMaterialID":"NA","IPWirelessProductInstanceID":"NA","SERVICEPROFILE":"NORMAL","__targetSystem":"FULFILMENT"},"additionalAttributes":{"parentSpec":"5311e403-e5e1-5d83-b2c1-ac90b78e1289"}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductOffering_000419DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobility_Billing_RecurringCharge_000498","metadata":{},"instanceId":"","includeBilling":false,"guid":"11966645-20ef-a35d-8f66-bcbccfff31a2","endDate":"","description":"","code":"DMCAT_ProductSpecification_000420_Billing_RecurringCharge_000498","attributes":{"billDescription":"CWP Mobile Seat","prorate":"false","billInAdvance":"true","billingSpecId":"BSRC001_CB","frequency":"Monthly","currency":"AUD","type":null,"rateExcludeGST":100,"quantity":"1","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_Allowance_000484_1","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Bill_AW","metadata":{},"instanceId":"","includeBilling":false,"guid":"c72c6680-a658-c856-1234-1a1a5744f7cd","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000484_1","attributes":{"SERVICEID":"","IMSI":"","billDescription":"Mobile Access Allowance","RoutingServiceType":"Mobile","value":"50","unitofMeasure":"GB","type":"Domestic Data","ocsProdID":"T22E_CWP_MOBPLAN","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_Allowance_000607_6","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Bill_AW","metadata":{},"instanceId":"","guid":"8547aa94-68db-f68c-137f-24f04c58c1ef","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000607_6","attributes":{"value":"500","unitofMeasure":"MB","type":"International Roaming Data","ocsProdID":"T22E_EMOB_IRDTP","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000420DMCAT_ProductSpecification_000263_Billing_Allowance_000606_5","productConfigurationId":"a3T2O000000HO18UAG","name":"Mobile Access_Bill_AW","metadata":{},"instanceId":"","guid":"af68080e-e161-399d-7250-40ea06f19506","endDate":"","description":"","code":"DMCAT_ProductSpecification_000263_Billing_Allowance_000606_5","attributes":{"value":"200","unitofMeasure":"MB","type":"International Roaming Data","ocsProdID":"T22E_EMOB_IRDP","billingSpecId":"BSUSG001_CB","__targetSystem":"BILLING"},"additionalAttributes":{}}],"serviceId":"'+servlist[2].Id+'","legacyAttributes":[]}');
        att4.Name = 'ServiceSpecifications.json';
        att4.ParentId = servMobile.Id;
        atts.add(att4);
        //create attachment
        Attachment att5= new Attachment();
        att5.Body = Blob.valueOf('{"configurations":[{"guid":"7965fd63-f8df-8832-08e6-e8955657cf8f","NetworkServiceOffer":"DMCAT_ProductSpecification_000537","Basketid":"a3Q5O0000000k3JUAQ","Status":"Active","Tenancy":"1111111","Subscription":"SN-000046815","Network_Display":"MDM Tenancy","Network":"'+testSubscription.id+'","SolutionId":"a4f5O0000000CgZQAU","GUID":"7965fd63-f8df-8832-08e6-e8955657cf8f"}]}');
        att5.Name = 'Tenancy_schema.json';
        att5.ParentId = PCNewMdm.Id;
        atts.add(att5);
        user uSysAdmin=[select id from user where profile.Name='System Administrator' and isactive=true limit 1];
        Attachment att6= new Attachment();
        string str='{"configurations":[{"OfferName":"T-MDM Professional Services","Operational User_Display":"Test","Operational User":"'+u1.id+'","description":"Operations User Selection","name":"Operations User Selection"}]}';     
        att6.Body = Blob.valueOf(str);
        att6.Name = 'Operations User_schema.json';
        att6.ParentId = PCNewMdm.Id;
        atts.add(att6);
        insert atts;
        FCR_Settings__c fcr= new FCR_Settings__c(Name='DMCAT_ProductSpecification_000718',
                                                 File_Name__c='Tenancy_schema.json',
                                                 Product_Configuration_code__c='DMCAT_ProductSpecification_000537',
                                                 Role_Name__c='MDM Operations User');
        insert fcr;
    }
    static testMethod void processTest(){
          csord__order__c order = [SELECT Id from csord__order__c where name ='PrimaryOrder'];
          csord__order__c secorder = [SELECT Id from csord__order__c where name ='TestOrder'];
         //Orchestaction Process
        CSPOFA__Orchestration_Process_Template__c orchProcessTemplate = new CSPOFA__Orchestration_Process_Template__c();
        orchProcessTemplate.Name='Order Fulfilment Process';
        orchProcessTemplate.CSPOFA__Process_Type__c = 'New Provide';
        orchProcessTemplate.CSPOFA__Processing_Mode__c = 'Foreground';
        insert orchProcessTemplate;
        CSPOFA__Orchestration_Process__c orchProcess = new CSPOFA__Orchestration_Process__c();
        orchProcess.Name = 'Test Orch Process';
        orchProcess.Order__c= order.Id;
        orchProcess.has_Inactive_Children__c = 'NA';
        orchProcess.CSPOFA__Orchestration_Process_Template__c = orchProcessTemplate.Id;
        insert orchProcess;
        CSPOFA__Orchestration_Step__c step = new CSPOFA__Orchestration_Step__c();
        step.CSPOFA__Orchestration_Process__c = orchProcess.Id;
        List<CSPOFA__Orchestration_Step__c> steps = new List<CSPOFA__Orchestration_Step__c>();
        steps.add(step);
         Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"30a0f36c-b496-185e-6330-c7a9c317d22c","productConfigurationId":"a0b0Y000001oXmtQAE","name":"CWPSpec","instanceId":"1234","guid":"3072dad2-2911-eb71-8e13-bd04b7f9824a","additionalAttributes" : {"ServiceId" : "61402022091","IPWirelessProductInstanceID" : "9127db1b-b9f7-4b69-d55b-f856689c1b7e"},"endDate":"","description":"CWP CFS Specification","code":"DMCAT_ProductSpecification_000263","attributes":{"__targetSystem":"FULFILMENT","Zone":"Zone 3","TotalMRC":1500,"Seat":5,"complexIPAccess":[{"attributes":{"complexAttrPort":8080,"complexAttrTech":"Fibre"},"productConfigurationId":"a0b0Y000001oXmyQAE"},{"attributes":{"complexAttrPort":9090,"complexAttrTech":"Ethernet"},"productConfigurationId":"a0b0Y000001oXn3QAE"}],"constantName":"contantValue"}},{"version":"1","status":"Created","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXmyQAE","name":"IPAccessSpec","instanceId":"3456","guid":"3df57fcf-7c28-c50a-140b-0d21e80714e7","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"__targetSystem":"FULFILMENT","Port":8080,"Technology":"Fibre","constantAttr":"constantValue"}},{"version":"1","status":"Created","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXn3QAE","name":"IPAccessSpec","instanceId":"6789","guid":"495bbebb-5166-6dce-24cd-648084f6241c","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"__targetSystem":"FULFILMENT","Port":9090,"Technology":"Ethernet","constantAttr":"constantValue"}}],"serviceId":"'+order.Id+'","legacyAttributes":[]}');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = secorder.Id;
        insert att1;
        //
      Test.startTest();
        List<Id> OrderId = new List<Id>();
        OrderId.add(order.Id);
         System.debug('OrderId111'+OrderId);
        ValidateOrderFulfillment submitOrder = new ValidateOrderFulfillment ();
        String token = 'aJ1AUZuZdKBUWb7s22OhejvWKRzU';
        List<SObject> result1 = submitOrder.process((List<SObject>)steps);
       // Boolean result = submitOrder .performCallouts((List<SObject>)steps);
        ManualFulfillment manualFulfillment = new ManualFulfillment();
        List<csord__Subscription__c> subscriptionList =  manualFulfillment.getSubscriptionByOrderId(OrderId);
          System.debug('subscriptionList111'+subscriptionList);
        List<csord__Subscription__c> subscriptionList1 = [SELECT Id,Name,csord__Order__c,csord__Order__r.csord__Order_Number__c,csord__Order__r.csord__Status2__c,cssdm__solution_association__c,
        csord__Order__r.csordtelcoa__Opportunity__c,csord__Order__r.csordtelcoa__Opportunity__r.OwnerId,csord__Account__c,ConfigSpecID__c,csordtelcoa__Product_Configuration__c,csord__Order__r.csordtelcoa__Opportunity__r.Owner.ContactId,
        MarketableOffer__c, MarketableOffer__r.Config__c,MarketableOffer__r.Name,MarketableOffer__r.Offer_ID__c,toBeCancelled__c,Billing_Account__c,csordtelcoa__Product_Configuration__r.ConfigurationType1__c,MarketableOffer__r.Type__c,Parent_Subscription__c,
        (SELECT Id,Tenancy_Id__c,Purchase_Order_No__c,csord__Status__c from csord__Services__r)
        from csord__Subscription__c where csord__Order__c IN :OrderId];
        //System.debug('subscriptionList1'+subscriptionList1);
        //System.assertEquals(subscriptionList, subscriptionList1);
        manualFulfillment.isFulfillmentRequired(subscriptionList1);
        manualFulfillment.fulfillmentByCASE(subscriptionList1);
         manualFulfillment.updateRTSAdaptive(subscriptionList1); //DPG-1914: Adaptive Care
        manualFulfillment.commitWork(); 
        manualFulfillment.processAdaptiveCare(subscriptionList1); //DPG-1914: Adaptive Care
          csord__order__c orderasset = [SELECT Id,skipFulfillment__c from csord__order__c where name ='PrimaryOrder'];
        //orderasset.skipFulfillment__c should be set to TRUE
        System.assertEquals(orderasset.skipFulfillment__c,TRUE);
    //  List<CSPOFA__Orchestration_Step__c> result = new List<CSPOFA__Orchestration_Step__c>();
    //  rcr.process(result);
        Test.stopTest();
    }
  static testMethod void processOrchestration(){
        csord__order__c order = [SELECT Id from csord__order__c where name ='PrimaryOrder'];
        csord__order__c secorder = [SELECT Id from csord__order__c where name ='TestOrder'];
         //Orchestaction Process
        CSPOFA__Orchestration_Process_Template__c orchProcessTemplate = new CSPOFA__Orchestration_Process_Template__c();
        orchProcessTemplate.Name='Order Fulfilment Process';
        orchProcessTemplate.CSPOFA__Process_Type__c = 'New Provide';
        orchProcessTemplate.CSPOFA__Processing_Mode__c = 'Foreground';
        insert orchProcessTemplate;
        CSPOFA__Orchestration_Process__c orchProcess = new CSPOFA__Orchestration_Process__c();
        orchProcess.Name = 'Test Orch Process';
        orchProcess.Order__c= order.Id;
        orchProcess.has_Inactive_Children__c = 'NA';
        orchProcess.CSPOFA__Orchestration_Process_Template__c = orchProcessTemplate.Id;
        insert orchProcess;
        CSPOFA__Orchestration_Step__c step = new CSPOFA__Orchestration_Step__c();
        step.CSPOFA__Orchestration_Process__c = orchProcess.Id;
        List<CSPOFA__Orchestration_Step__c> steps = new List<CSPOFA__Orchestration_Step__c>();
        steps.add(step);
         Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"30a0f36c-b496-185e-6330-c7a9c317d22c","productConfigurationId":"a0b0Y000001oXmtQAE","name":"CWPSpec","instanceId":"1234","guid":"3072dad2-2911-eb71-8e13-bd04b7f9824a","additionalAttributes" : {"ServiceId" : "61402022091","IPWirelessProductInstanceID" : "9127db1b-b9f7-4b69-d55b-f856689c1b7e"},"endDate":"","description":"CWP CFS Specification","code":"DMCAT_ProductSpecification_000263","attributes":{"__targetSystem":"FULFILMENT","Zone":"Zone 3","TotalMRC":1500,"Seat":5,"complexIPAccess":[{"attributes":{"complexAttrPort":8080,"complexAttrTech":"Fibre"},"productConfigurationId":"a0b0Y000001oXmyQAE"},{"attributes":{"complexAttrPort":9090,"complexAttrTech":"Ethernet"},"productConfigurationId":"a0b0Y000001oXn3QAE"}],"constantName":"contantValue"}},{"version":"1","status":"Created","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXmyQAE","name":"IPAccessSpec","instanceId":"3456","guid":"3df57fcf-7c28-c50a-140b-0d21e80714e7","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"__targetSystem":"FULFILMENT","Port":8080,"Technology":"Fibre","constantAttr":"constantValue"}},{"version":"1","status":"Created","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXn3QAE","name":"IPAccessSpec","instanceId":"6789","guid":"495bbebb-5166-6dce-24cd-648084f6241c","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"__targetSystem":"FULFILMENT","Port":9090,"Technology":"Ethernet","constantAttr":"constantValue"}}],"serviceId":"'+order.Id+'","legacyAttributes":[]}');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = secorder.Id;
        insert att1;
        //
      Test.startTest();
        List<Id> OrderId = new List<Id>();
        OrderId.add(order.Id);
         System.debug('OrderId111'+OrderId);
        ValidateOrderFulfillment submitOrder = new ValidateOrderFulfillment ();
        String token = 'aJ1AUZuZdKBUWb7s22OhejvWKRzU';
        List<SObject> result1 = submitOrder.process((List<SObject>)steps);
       // Boolean result = submitOrder .performCallouts((List<SObject>)steps);
        ManualFulfillment manualFulfillment = new ManualFulfillment();
        List<csord__Subscription__c> subscriptionList =  manualFulfillment.getSubscriptionByOrderId(OrderId);
          System.debug('subscriptionList111'+subscriptionList);
        List<csord__Subscription__c> subscriptionList1 = [SELECT Id,Name,csord__Order__c,csord__Order__r.csord__Order_Number__c,csord__Order__r.csord__Status2__c,cssdm__solution_association__c,
        csord__Order__r.csordtelcoa__Opportunity__c,csord__Order__r.csordtelcoa__Opportunity__r.OwnerId,csord__Account__c,ConfigSpecID__c,csordtelcoa__Product_Configuration__c,csord__Order__r.csordtelcoa__Opportunity__r.Owner.ContactId,
        MarketableOffer__c, MarketableOffer__r.Config__c,MarketableOffer__r.Name,csordtelcoa__Product_Configuration__r.ConfigurationType1__c,MarketableOffer__r.Type__c,Parent_Subscription__c,
        (SELECT Id,Tenancy_Id__c,Purchase_Order_No__c,csord__Status__c from csord__Services__r)
        from csord__Subscription__c where csord__Order__c IN :OrderId];
        //System.assertEquals(subscriptionList, subscriptionList1);
        manualFulfillment.isFulfillmentRequired(subscriptionList1);
        manualFulfillment.fulfillmentByCASE(subscriptionList1);
        manualFulfillment.commitWork();
          csord__order__c orderasset = [SELECT Id,skipFulfillment__c from csord__order__c where name ='PrimaryOrder'];
        //orderasset.skipFulfillment__c should be set to TRUE
        System.assertEquals(orderasset.skipFulfillment__c,TRUE);
    //  List<CSPOFA__Orchestration_Step__c> result = new List<CSPOFA__Orchestration_Step__c>();
    //  rcr.process(result);
        Test.stopTest();
    }
    static testMethod void processnotopenair(){
        csord__order__c order = [SELECT Id,csord__Order_Number__c from csord__order__c where name ='PrimaryOrder'];
        csord__order__c secorder = [SELECT Id from csord__order__c where name ='TestOrder'];
      Test.startTest();
        List<Id> OrderId = new List<Id>();
        OrderId.add(order.Id);
         System.debug('OrderId111'+OrderId);
        ManualFulfillment manualFulfillment = new ManualFulfillment();
        List<csord__Subscription__c> subscriptionList =  manualFulfillment.getSubscriptionByOrderId(OrderId);
          System.debug('subscriptionList111'+subscriptionList);
        List<csord__Subscription__c> subscriptionList1 = [SELECT Id,Name,csord__Order__c,csord__Order__r.csord__Order_Number__c,csord__Order__r.csord__Status2__c,cssdm__solution_association__c,
        csord__Order__r.csordtelcoa__Opportunity__c,csord__Order__r.csordtelcoa__Opportunity__r.OwnerId,csord__Account__c,ConfigSpecID__c,csordtelcoa__Product_Configuration__c,csord__Order__r.csordtelcoa__Opportunity__r.Owner.ContactId,
        MarketableOffer__c, MarketableOffer__r.Config__c,MarketableOffer__r.Name,csordtelcoa__Product_Configuration__r.ConfigurationType1__c,MarketableOffer__r.Type__c,Parent_Subscription__c,
        (SELECT Id,Tenancy_Id__c,Purchase_Order_No__c,csord__Status__c from csord__Services__r)
        from csord__Subscription__c where csord__Order__c IN :OrderId];
        //System.assertEquals(subscriptionList, subscriptionList1);
        manualFulfillment.isFulfillmentRequired(subscriptionList1);
        manualFulfillment.fulfillmentByCASE(subscriptionList1);
        manualFulfillment.commitWork();
          csord__order__c orderasset = [SELECT Id,skipFulfillment__c from csord__order__c where name ='PrimaryOrder'];
        //orderasset.skipFulfillment__c should be set to TRUE
        System.assertEquals(orderasset.skipFulfillment__c,TRUE);
        Test.stopTest();
    }
    
    static testMethod void TestOwnerAssignment_ps(){
        csord__order__c order = [SELECT Id,csord__Order_Number__c from csord__order__c where name ='PrimaryOrder'];
        csord__order__c secorder = [SELECT Id from csord__order__c where name ='TestOrder'];
      Test.startTest();
        List<Id> OrderId = new List<Id>();
        OrderId.add(order.Id);
        ManualFulfillment manualFulfillment = new ManualFulfillment();
        List<csord__Subscription__c> subscriptionList1 = [SELECT Id,Name,csord__Order__c,csord__Order__r.csord__Order_Number__c,csord__Order__r.csord__Status2__c,cssdm__solution_association__c,
        csord__Order__r.csordtelcoa__Opportunity__c,csord__Order__r.csordtelcoa__Opportunity__r.OwnerId,csord__Account__c,ConfigSpecID__c,csordtelcoa__Product_Configuration__c,csord__Order__r.csordtelcoa__Opportunity__r.Owner.ContactId,
        MarketableOffer__c, MarketableOffer__r.Config__c,MarketableOffer__r.Name,csordtelcoa__Product_Configuration__r.ConfigurationType1__c,MarketableOffer__r.Type__c,Parent_Subscription__c,
        (SELECT Id,Tenancy_Id__c,Purchase_Order_No__c,csord__Status__c from csord__Services__r)
        from csord__Subscription__c where csord__Order__c IN :OrderId];
        system.debug('subscriptionList1'+subscriptionList1);
        manualFulfillment.isFulfillmentRequired(subscriptionList1);
        manualFulfillment.fulfillmentByCASE(subscriptionList1); 
        manualFulfillment.commitWork();
        List<FulfillmentLineItem__c> FLIItems=[select id,Ownerid from FulfillmentLineItem__c];
        List<Case> FLICases=[select id,Ownerid from Case];  
        Attachment att= [select id,Body from Attachment where Name='Operations User_schema.json' limit 1] ;       
        String strbody = att.body.tostring();
        String Ownerid;
        Map<String, Object> request = (Map<String, Object>) JSON.deserializeUntyped(strbody);
        List<Object> reqAttrList = (List<Object>) request.get('configurations');            
        for (Object simpleAttr : reqAttrList) {
            Map<String, Object> smpObj = (Map<String, Object>) simpleAttr;
            Ownerid=(string)smpObj.get('Operational User');
        }
        System.assertEquals(FLIItems[0].Ownerid,Ownerid);   
        System.assertEquals(FLICases[0].Ownerid,Ownerid);   
        Test.stopTest();
    }
    
static testMethod void TestOwnerAssignment_Mms(){     
        List<Id> OrderId = new List<Id>();
        csord__Order__c order = [select id from csord__Order__c where name='Test Order1' limit 1];      
        OrderId.add(order.Id);
        ManualFulfillment manualFulfillment = new ManualFulfillment();
        List<csord__Subscription__c> subscriptionList1 = [SELECT Id,Name,csord__Order__c,csord__Order__r.csord__Order_Number__c,csord__Order__r.csord__Status2__c,cssdm__solution_association__c,
        csord__Order__r.csordtelcoa__Opportunity__c,csord__Order__r.csordtelcoa__Opportunity__r.OwnerId,csord__Account__c,ConfigSpecID__c,csordtelcoa__Product_Configuration__c,csord__Order__r.csordtelcoa__Opportunity__r.Owner.ContactId,
        MarketableOffer__c, MarketableOffer__r.Config__c,MarketableOffer__r.Name,csordtelcoa__Product_Configuration__r.ConfigurationType1__c,MarketableOffer__r.Type__c,Parent_Subscription__c,
        (SELECT Id,Tenancy_Id__c,Purchase_Order_No__c,csord__Status__c from csord__Services__r)
        from csord__Subscription__c where csord__Order__c IN :OrderId];
        Test.startTest();
        manualFulfillment.isFulfillmentRequired(subscriptionList1);
        manualFulfillment.fulfillmentByCASE(subscriptionList1); 
        manualFulfillment.commitWork();
        
        List<csord__Subscription__c> ManagedServicesubscriptions = [SELECT Id,Name from csord__Subscription__c where csord__Order__c IN :OrderId and 
                                                                                                      MarketableOffer__r.Type__c = 'Managed Service' and
                                                                                                      csord__Status__c = 'Provisioned'];
       
      System.assertnotequals(ManagedServicesubscriptions.size(),0);
    Test.stopTest();
    }
}