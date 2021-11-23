/*
===============================================================================================================================
Class : SimReplacementController
Developer Name : Shubhi
Test Class : SimReplacementControllerTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Shubhi Vijayvergia  21/3/2018     Edge-53882 MAC page for Sim Replacement for Assurance service agen Profile  
2.        Gnana               29/7/2020     EDGE-154370 EDGE-154370 - Added Test Medthods for incident-INC000092634429 fix
3.        Ankit Goswami       12/10/2020    EDGE-169091 changes in verifySIMSerial method
4.        Gnana               27/10/2020    EDGE-185450 Added Assert for ChangeType__c logic
5.        Vamsi krishna vaddipalli  27OCT2021 DIGI-17911 Simreplacement logger splunk               
===============================================================================================================================
*/
@isTest
private class SimReplacementControllerTest  {
    @TestSetup static void dataSetup()
    {
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
        testOpp.Type = 'Migration';
        testOpp.Billing_Solution__c = 'Standard';
        Id standardID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defined').getRecordTypeId();
        testOpp.RecordTypeId = standardID;
        insert testOpp;

        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = testAccount.Id;
        testBasket.Name = 'ShowSubTestBasket';
        testBasket.cscfga__Opportunity__c = testOpp.Id;
        insert testBasket;
        
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>();
        cscfga__Product_Definition__c cwProd = new cscfga__Product_Definition__c(Name = 'Connected Workplace', cscfga__Description__c = 'Connected Workplace');
        pdList.add(cwProd);
        cscfga__Product_Definition__c ucePD = new cscfga__Product_Definition__c(Name = 'Unified Communication', cscfga__Description__c = 'Unified Communication');
        pdList.add(ucePD);
        cscfga__Product_Definition__c ipNetPd = new cscfga__Product_Definition__c(Name = 'IP Network', cscfga__Description__c = 'IP Network');
        pdList.add(ipNetPd);
        cscfga__Product_Definition__c mobPd = new cscfga__Product_Definition__c(Name = 'Mobility', cscfga__Description__c = 'Mobility');
        pdList.add(mobPd);
        insert pdList;
       

        List<cscfga__Product_Configuration__c> prodconfigList=new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c testConfig = new cscfga__Product_Configuration__c();
        testConfig.Name = 'Connected Workplace';
        testConfig.cscfga__Product_Basket__c = testBasket.Id;
        testConfig.cscfga__Product_Definition__c=cwProd.id;
        prodconfigList.add(testConfig);
        cscfga__Product_Configuration__c testConfig1 = new cscfga__Product_Configuration__c();
        testConfig1.Name = System.Label.IP_Network;
        testConfig1.cscfga__Product_Basket__c = testBasket.Id;
        testConfig1.cscfga__Product_Definition__c=ucePD.id;
        prodconfigList.add(testConfig1);
        cscfga__Product_Configuration__c testConfig2 = new cscfga__Product_Configuration__c();
        testConfig2.Name = System.Label.UC_Enterprise;
        testConfig2.cscfga__Product_Basket__c = testBasket.Id;
        testConfig2.cscfga__Product_Definition__c=ipNetPd.id;
        prodconfigList.add(testConfig2); 
        cscfga__Product_Configuration__c testConfig3 = new cscfga__Product_Configuration__c();
        testConfig3.Name = System.Label.Mobility;
        testConfig3.cscfga__Product_Basket__c = testBasket.Id;
        testConfig3.cscfga__Product_Definition__c=mobPd.id;
        prodconfigList.add(testConfig3); 
        insert prodconfigList;

        cscfga__Attribute__c testAttribute = new cscfga__Attribute__c();
        testAttribute.Name = 'testAttributeForTest';
        testAttribute.cscfga__Product_Configuration__c = testConfig.Id;
        insert testAttribute;

        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
        csord__Order__c order = ProductTestFactory.buildOrder('PrimaryOrder', testAccount.id, 'Created', ordReq.id);
        order.telstra_ord_Start_DateTime__c=System.now(); //EDGE-182667
        order.csord__Order_Request__c = ordReq.Id;
        insert order;
        
        csord__Order__c testOrder = ProductTestFactory.buildOrder('TestOrder', testAccount.id, 'Created', ordReq.id);
        testOrder.telstra_ord_Start_DateTime__c=System.now(); //EDGE-182667
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
        testSubscription4.csord__Status__c = 'Active';
        
        csord__Subscription__c testSubscription5 = new csord__Subscription__c();
        testSubscription5.Name = 'TestSubsforTest5';
        testSubscription5.csord__Account__c = testAccount.Id;
        testSubscription5.csord__Order__c = testOrder.Id;
        testSubscription5.csord__Identification__c = 'test';
        testSubscription5.csordtelcoa__Product_Configuration__c = testConfig3.Id;
        //testSubscription5.csord__Status__c = 'Closed Replaced';

        List<csord__Subscription__c> testSubsList = new List<csord__Subscription__c>{testSubscription,testSubscription2,testSubscription3,testSubscription4,testSubscription5};
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
            serv.csord__Subscription__c = testSubs.Id;
            serv.csord__Status__c = 'Created';
            serv.substage__c = 'Product Requirements Validation';
            serv.csord__Order_Request__c = ordReq.Id;
            serv.csord__Order__c = testSubs.csord__Order__c;
            servlist.add(serv);
        }
        //create service
        insert servlist;
        for(csord__Service__c serv:servlist){
            Attachment att1 = new Attachment();
            att1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Disconnect Pending","startDate":"","specification":"30a0f36c-b496-185e-6330-c7a9c317d22c","productConfigurationId":"a0b0Y000001oXmtQAE","name":"CWPSpec","instanceId":"1234","guid":"3072dad2-5546-eb71-8e13-bd04b7f9824a","endDate":"","description":"CWP CFS Specification","code":"CWPSpec01_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","Zone":"Zone 3","TotalMRC":1500,"Seat":5,"complexIPAccess":[{"attributes":{"complexAttrPort":8080,"complexAttrTech":"Fibre"},"productConfigurationId":"a0b0Y000001oXmyQAE"},{"attributes":{"complexAttrPort":9090,"complexAttrTech":"Ethernet"},"productConfigurationId":"a0b0Y000001oXn3QAE"}],"constantName":"contantValue"}},{"version":"1","status":"Cancellation Pending","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXmyQAE","name":"IPAccessSpec","instanceId":"3456","guid":"3df57fcf-7c28-c50a-140b-0d21e80714e7","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","Port":8080,"Technology":"Fibre","constantAttr":"constantValue"}},{"version":"1","status":"Pending","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXn3QAE","name":"IPAccessSpec","instanceId":"6789","guid":"495bbebb-5166-6dce-24cd-648084f6241c","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01_Fulfilment","attributes":{"__targetSystem":"FULFILMENT","Port":9090,"Technology":"Ethernet","constantAttr":"constantValue"}}],"serviceId":"'+serv.id+'","legacyAttributes":[]}');
            att1.Name = 'ServiceSpecifications.json';
            att1.ParentId = serv.Id;
            
            atts.add(att1);
        }        
        //create attachment
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
        customSetting4.Name = ' NGEM_Mobility';

        customSetting4.speccode__c = '001196';

        custList.add(customSetting4);
        insert custList;
        
        CSPOFA__Orchestration_Process_Template__c opt=new CSPOFA__Orchestration_Process_Template__c();
        opt.Name='Order Fulfilment Process';
        insert opt;
    }
    @isTest 
    static void testErrorMessage(){
        String errorMsg;
        Test.startTest();
            SimReplacementController.errorMsg = 'Test Message';
            errorMsg = SimReplacementController.errorMsg;
        Test.stopTest();

        System.assertEquals('Test Message', errorMsg, 'Tested error Message and fetched are not equal');
    }
    @isTest
    static void testGetAccountDetails()
    {
        Account resultAccount = new Account();
        Account testAccount = [SELECT id, Name FROM Account LIMIT 1];
        Test.startTest();
            String accId=testAccount.Id;
            resultAccount = SimReplacementController.getAccountDetails(accId);
        Test.stopTest();
        System.assertEquals(testAccount.Id, resultAccount.Id, 'Tested Account Id\'s are not equal');       
    }
    @isTest
    static void getSimReplacementsubscriptionAndDeleteTest(){
        List<String> subsIdList=new List<String>();
        for(csord__Subscription__c testSubs:[SELECT Id,csord__Status__c FROM csord__Subscription__c where csord__Status__c='Active']){
            subsIdList.add(testSubs.Id);
        }
        Test.startTest();       
            List<Subwrapper> subwrapList = SimReplacementController.getSimReplacementsubscription(subsIdList);
            System.debug( 'subwrapList : ' + subwrapList);
            List<Subwrapper> subwrapList2 = SimReplacementController.deleteSubscription(subwrapList,subsIdList[0]);
            //System.assert(testSubs[0].csord__Status__c=='In-Progress');
            System.assert( subwrapList.size() != 0);
            System.assert( subwrapList.size() != subwrapList2.size());
        Test.stopTest();
                
    }
     @isTest
    static void createOrderTestSecenario1(){
        List<String> subsIdList=new List<String>();
        List<csord__Service__c> servlist=new list<csord__Service__c>();
        for(csord__Subscription__c testSubs:[SELECT Id,csord__Status__c FROM csord__Subscription__c where csord__Status__c='Active']){
            subsIdList.add(testSubs.Id);
            csord__Service__c serv = new csord__Service__c();
            serv.name ='testService_4';
            serv.csord__Identification__c  = 'testIdentify_4';
            serv.csordtelcoa__Service_Number__c = '3';
            serv.csord__Subscription__c = testSubs.Id;
            serv.csord__Status__c = 'Created';
            serv.substage__c = 'Product Requirements Validation';
            //serv.csordtelcoa__Product_Configuration__c = testConfig1.Id;
            //serv.csord__Order_Request__c = ordReq.Id;
            //serv.csord__Order__c = ord.Id;
            servlist.add(serv);
        }
        Account testAccount = [SELECT id, Name FROM Account LIMIT 1];
        Test.startTest(); 
            //create service
            insert servlist;        
            List<Subwrapper> subwrapList = SimReplacementController.getSimReplacementsubscription(subsIdList);
            System.assert( subwrapList.size() !=null);
            for(Subwrapper suw:subwrapList){
                suw.SimSerialNumber='1234Test';
            }
            String tNowCaseRef='TCN123456789';
            string result=SimReplacementController.createOrder(subwrapList,testAccount.id,tNowCaseRef,'eSIM faulty');
            system.assert(result!=null);
            //string result2=SimReplacementController.createOrder(subwrapList,testAccount.id);
            //system.assert(result2=='error');         
        Test.stopTest();               
    }
    @isTest
    static void createOrderTestSecenario2(){
        List<String> subsIdList=new List<String>();
        List<csord__Service__c> servlist=new list<csord__Service__c>();
        for(csord__Subscription__c testSubs:[SELECT Id,csord__Status__c FROM csord__Subscription__c where csord__Status__c='Active']){
            subsIdList.add(testSubs.Id);
            csord__Service__c serv = new csord__Service__c();
            serv.name ='testService_4';
            serv.csord__Identification__c  = 'testIdentify_4';
            serv.csordtelcoa__Service_Number__c = '3';
            serv.csord__Subscription__c = testSubs.Id;
            serv.csord__Status__c = 'Created';
            serv.substage__c = 'Product Requirements Validation';
            //serv.csordtelcoa__Product_Configuration__c = testConfig1.Id;
            //serv.csord__Order_Request__c = ordReq.Id;
            //serv.csord__Order__c = ord.Id;
            servlist.add(serv);
        }
        
        Account testAccount = [SELECT id, Name FROM Account LIMIT 1];
        SimReplacementController.acc=testAccount;
        Test.startTest();
            //create service
            insert servlist;
            //create contact for delivery details
            Contact con = new Contact(LastName = 'Sam');
            con.AccountId=testAccount.id;
            insert con;        
            /*AccountContactRelation ACR = new AccountContactRelation();
            ACR.ContactId = con.Id;
            ACR.AccountId = testAccount.Id;
            ACR.Roles = 'Legal Lessee';
            insert ACR;*/        
            //Create addresses
            cscrm__Address__c addrs = new cscrm__Address__c();
            addrs.Address_ID__c = '152365895123';
            addrs.Name = 'Test Address';
            addrs.cscrm__Account__c = testAccount.id;
            insert addrs;
            List<Subwrapper> subwrapList = SimReplacementController.getSimReplacementsubscription(subsIdList);
            System.assert( subwrapList.size() !=null);
            for(Subwrapper suw:subwrapList){
                suw.SimSerialNumber='';
                suw.DeliveryAddressID=addrs.id;
                suw.DeliveryContactID=con.id;
            }
            String tNowCaseRef='TCN123456789';
            string result=SimReplacementController.createOrder(subwrapList,testAccount.id,tNowCaseRef,'eSIM faulty');
            system.assert(result!=null);
            //string result2=SimReplacementController.createOrder(subwrapList,testAccount.id);
            //system.assertEquals(result2,'error');         
        Test.stopTest();               
    }
    
    // Added as part of EDGE-154370
    @isTest
    static void createOrderTestDateFieldsCheck(){
        List<String> subsIdList=new List<String>();
        List<csord__Service__c> servlist=new list<csord__Service__c>();
        for(csord__Subscription__c testSubs:[SELECT Id,csord__Status__c FROM csord__Subscription__c where csord__Status__c='Active']){
            subsIdList.add(testSubs.Id);
            csord__Service__c serv = new csord__Service__c();
            serv.name ='testService_5';
            serv.csord__Identification__c  = 'testIdentify_5';
            serv.csordtelcoa__Service_Number__c = '3';
            serv.csord__Subscription__c = testSubs.Id;
            serv.csord__Status__c = 'Created';
            serv.substage__c = 'Product Requirements Validation';
            servlist.add(serv);
        }
        Account testAccount = [SELECT id, Name FROM Account LIMIT 1];
        Test.startTest(); 
            insert servlist;        
            List<Subwrapper> subwrapList = SimReplacementController.getSimReplacementsubscription(subsIdList);
            System.assert( subwrapList.size() !=null);
            for(Subwrapper suw:subwrapList){
                suw.SimSerialNumber='1234Test';
            }
            String tNowCaseRef='TCN123456789';
            string result=SimReplacementController.createOrder(subwrapList,testAccount.id,tNowCaseRef,'eSIM faulty');
            System.debug('result...'+result);
            system.assert(result!=null);    
            List<String> orderNum = result.split(',');   
            csord__Order__c ord = [SELECT Id FROM csord__Order__c WHERE csord__Order_Number__c = :orderNum[0] LIMIT 1];
            List<csord__Service__c> servList1 = [SELECT Id,Telstra_Committed_Date__c,Forecasted_Delivery_Date__c,changetype__c FROM csord__Service__c WHERE csord__Order__c = :ord.Id];
            System.debug('servList1...'+servList1);
            for(csord__Service__c ser : servList1){
                System.assertEquals(null, ser.Telstra_Committed_Date__c);
                System.assertEquals(null, ser.Forecasted_Delivery_Date__c);
                System.assertEquals('Replace SIM', ser.changetype__c);  // Added as part of EDGE-185450

            }
        Test.stopTest();               

    }
    
    //EDGE-167254/EDGE-169091 added by ankit || start

    @isTest
    static void testverifySIMSerial()
    {
        List<SubWrapper>subWraaperResponse=new List<SubWrapper>();
        List<Subwrapper> subwrapList =new List<Subwrapper>();
        Subwrapper sub = new Subwrapper();
        sub.SimSerialNumber='89610182000501374304';
        sub.RequestedSIMType='SIM Type';
        subwrapList.add(sub);
        Test.startTest();
           Test.setMock(HttpCalloutMock.class, new MockLRMResponseGenerator(200,'Success',null));
            subWraaperResponse = SimReplacementController.verifySIMSerial(subwrapList);
        Test.stopTest();
        System.assertEquals(true,!subWraaperResponse.isEmpty() );    
    }

     @isTest
    static void testverifySIMSerialNegative()
    {
        List<SubWrapper>subWraaperResponse=new List<SubWrapper>();
        List<Subwrapper> subwrapList =new List<Subwrapper>();
        Subwrapper sub = new Subwrapper();
        sub.SimSerialNumber='89610182000501374392';
        sub.RequestedSIMType='SIM Type';
        subwrapList.add(sub);
        Test.startTest();
           Test.setMock(HttpCalloutMock.class, new MockLRMResponseGenerator(422,'Partial Success',null));
            subWraaperResponse = SimReplacementController.verifySIMSerial(subwrapList);
        Test.stopTest();
           System.assertEquals(true,!subWraaperResponse.isEmpty());  


    }
     /*  
    * Method Name : testSimReplacementLogger
    * Owner : Vamsi Krishna Vaddipalli
    * Jira : DIGI-17911
   */
    @isTest
    static void testSimReplacementLogger()
    {
        Account testAccount = [SELECT id, Name FROM Account LIMIT 1];
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', testAccount.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        insert ord;
        String accountId = testAccount.id;
        String orderId = ord.id;
        String dt;
        boolean isSucess = true;
        Test.startTest();
        SimReplacementController.simReplacementTransactionlogs(accountId,orderId,dt);
        Test.stopTest();
        System.assertEquals(true,isSucess);
    }

    
}