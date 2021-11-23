/******************************************
Name : PONROrderItemHandlerTest
EDGE-> 186512,186513
Description : Test class for callout to the order status API to get the PONR status details of the line items for selected order
================================================================================================================================
Sr.No.    Developer Name          Date                  Story Description
1.        Rajiv Singh          29/10/2020       As a salesforce user, I want to Perform PONR status Check for specific
                                                     order number: PONR status Enquiry API Consumption
2.        Martand Atrey           4/02/2021         Updated test class for EDGE-199064

3.		  Pallavi D				5/17/2021		QA2|| AM- Remediation|| Not able to submit remediation basket EDGE-217693
================================================================================================================================
*******************************************/
@isTest
public class PONROrderItemHandlerTest {
	public static cscfga__Product_Basket__c productBasketToCheck = new cscfga__Product_Basket__c();
    @TestSetup
    public static void setup(){

        BDS_Notify_Settings__c bdsNotifySettingFeatureLevel = (BDS_Notify_Settings__c) SYS_TestDataFactory.createCustomSetting(BDS_Notify_Settings__c.sObjectType);
        bdsNotifySettingFeatureLevel.Name = 'Feature Level';
        bdsNotifySettingFeatureLevel.Value__c = 'FeatureLevelShadow';
        BDS_Notify_Settings__c bdsNotifySettingTechnicalSupport = (BDS_Notify_Settings__c) SYS_TestDataFactory.createCustomSetting(BDS_Notify_Settings__c.sObjectType);
        bdsNotifySettingTechnicalSupport.Name = 'Technical Support';
        bdsNotifySettingTechnicalSupport.Value__c = 'TechnicalSupportShadow';
        
        insert new List<BDS_Notify_Settings__c>{bdsNotifySettingFeatureLevel, bdsNotifySettingTechnicalSupport};

        
        String IDENTIFICATION ='IDE1322';

        //Create Account
        Account acc = new Account();
        acc.Name = 'test Account 1' ;
        acc.Customer_Status__c = 'Active'; 
        insert acc;

		Contact cont = new Contact(FirstName='Test',LastName='Test',Email='test@test.com',AccountId=acc.id,Phone='');
        insert cont;
        
        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c = 'Modular';
		insert opp;
		
        //Create Order
        csord__Order__c  ord1 = new csord__Order__c();
        ord1.name = 'Order 1';
        ord1.csord__Account__c = acc.Id;
        ord1.csord__Status2__c = 'In Progress';
        ord1.csord__Identification__c = IDENTIFICATION;
        ord1.stage__c = 'Being Fulfilled';
        ord1.csord__Start_Date__c = Date.newInstance(2016, 12, 9);    
        insert ord1;
        
		cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'IoT Basket';
        basket.Device_Care_Contact__c = cont.Id;
        basket.cscfga__Basket_Status__c = 'valid';
        basket.Order_Requester__c =cont.Id;
        basket.csordtelcoa__Basket_Stage__c ='Draft';
        basket.csbb__Synchronised_with_Opportunity__c =false;
        insert basket;																   
        //Created Product Configurations
        cscfga__Product_Configuration__c pcNew1 = new cscfga__Product_Configuration__c();
        pcNew1.name='PC1';
        pcNew1.Type__c='New';
        pcNew1.subType__c='';
        pcNew1.ConfigurationType1__c = '';
        pcNew1.Quantity_Product_Configuration__c = 111;
        insert pcNew1;

        cscfga__Product_Configuration__c pcNew2= new cscfga__Product_Configuration__c();
        pcNew2.name='PC2';
        pcNew2.Type__c='New';
        pcNew2.subType__c='Rollback Amend';
        pcNew2.ConfigurationType1__c = 'SolutionComponent';
        pcNew2.Quantity_Product_Configuration__c = 111;
		pcNew2.csordtelcoa__Replaced_Product_Configuration__c = pcNew1.id;
        pcNew2.cscfga__Product_Basket__c =basket.id;														  
        insert pcNew2;

        //Create Subscription 
        csord__Subscription__c testSubscription1 = new csord__Subscription__c();
        testSubscription1.Name = 'TestSubsforTest 1';
        testSubscription1.csord__Account__c = acc.Id;
        testSubscription1.csord__Identification__c = IDENTIFICATION; //required Field
        //testSubscription1.csordtelcoa__Product_Configuration__c = productconfiglistId;   
        insert testSubscription1;
        csord__Subscription__c testSubscription2 = new csord__Subscription__c();
        testSubscription2.Name = 'TestSubsforTest 2';
        testSubscription2.csord__Account__c = acc.Id;
        testSubscription2.csord__Identification__c = IDENTIFICATION; //required Field
        //testSubscription2.csordtelcoa__Product_Configuration__c = productconfiglistId;   
        insert testSubscription2;

        //Create Replaced Service
        csord__Service__c testReplacedService = new csord__Service__c();
        testReplacedService.name ='testReplacedService';
        testReplacedService.csord__Subscription__c = testSubscription1.Id; //requried Field
        testReplacedService.csord__Identification__c = Identification; //requried Field
        testReplacedService.csordtelcoa__Product_Configuration__c = pcNew1.Id; //requried Field
        //testReplacedService.csordtelcoa__Service_Number__c = 'SVC-000107096';
        insert testReplacedService;

        //Create Services  for Sub1
        csord__Service__c testService1 = new csord__Service__c();
        testService1.name ='testService1';
        testService1.csord__Subscription__c = testSubscription1.Id; //requried Field
        testService1.csord__Identification__c = Identification; //requried Field
        testService1.csordtelcoa__Product_Configuration__c = pcNew1.Id; //requried Field
        //testService1.csordtelcoa__Service_Number__c = 'SVC-000107097';
        testService1.csord__Status__c = 'In progress';
        testService1.csord__Order__c = ord1.id;
        insert testService1;
        csord__Service__c testService2 = new csord__Service__c();
        testService2.name ='testService2';
        testService2.csord__Subscription__c = testSubscription1.Id; //requried Field
        testService2.csord__Identification__c = Identification; //requried Field
        testService2.csordtelcoa__Product_Configuration__c = pcNew1.Id; //requried Field
        //testService2.csordtelcoa__Service_Number__c = 'SVC-000107098';
        testService2.csord__Status__c = 'In progress';
        testService2.csord__Order__c = ord1.id;
        insert testService2;

        //Create Services  for Sub2
        csord__Service__c testService3 = new csord__Service__c();
        testService3.name ='testService3';
        testService3.csord__Subscription__c = testSubscription2.Id; //requried Field
        testService3.csord__Identification__c = Identification; //requried Field
        testService3.csordtelcoa__Product_Configuration__c = pcNew1.Id; //requried Field
        //testService3.csordtelcoa__Service_Number__c = 'SVC-000107099';
        testService3.csord__Status__c = 'In progress';
        testService3.csord__Order__c = ord1.id;
        insert testService3;
        csord__Service__c testService4 = new csord__Service__c();
        testService4.name ='testService4';
        testService4.csord__Subscription__c = testSubscription2.Id; //requried Field
        testService4.csord__Identification__c = Identification; //requried Field
        testService4.csordtelcoa__Product_Configuration__c = pcNew2.Id; //requried Field
        //testService4.csordtelcoa__Service_Number__c = 'SVC-000107100';
        testService4.csord__Status__c = 'In progress';
        testService4.csord__Order__c = ord1.id;
        insert testService4;

    }

    @isTest
    public static void case1test(){
        //Check for a new service and where Rollback is not present and Solution componnet is alsonot present
        csord__Order__c order = [SELECT Id, csord__Order_Number__c FROM csord__Order__c];
        //get list of Service numbers
        List<csord__Service__c> servList = [SELECT id,csordtelcoa__Service_Number__c FROM csord__Service__c LIMIT 1];
        List<String> servNumList = new List<String>();
        System.debug('servList' + servList);
        for(csord__Service__c serv : servList){
            servNumList.add(serv.csordtelcoa__Service_Number__c);
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockStockCheckCalloutResponse('oneService', order.csord__Order_Number__c , servNumList));
        Boolean result = PONROrderItemHandler.syncExecute(order.csord__Order_Number__c);
        Test.stopTest();
        System.assert(result);
        for(csord__Service__c serv : [SELECT id,csordtelcoa__Service_Number__c,csordtelcoa__Point_of_No_Return_Reached__c, cancel_Point_of_No_Return_Reached__c,csord__Subscription__r.Point_of_No_Return_Reached__c, csord__Subscription__r.cancel_Point_of_No_Return_Reached__c  FROM csord__Service__c WHERE csordtelcoa__Service_Number__c IN :servNumList ]){
            System.assert(serv.csordtelcoa__Point_of_No_Return_Reached__c);
            System.assert(serv.cancel_Point_of_No_Return_Reached__c);
            System.assert(serv.csord__Subscription__r.Point_of_No_Return_Reached__c);
            System.assert(serv.csord__Subscription__r.cancel_Point_of_No_Return_Reached__c);
        }
        
    }

    @isTest
    public static void case2test(){
        //Check for a MACD service and where Rollback is not present
        csord__Order__c order = [SELECT csord__Order_Number__c FROM csord__Order__c];
        cscfga__Product_Configuration__c pc = [SELECT Id FROM cscfga__Product_Configuration__c WHERE NOT subType__c  LIKE 'Rollback%' LIMIT 1];
        pc.subType__c = 'Rollback Amend';
        update pc;
        List<csord__Service__c> servList = [SELECT id,csordtelcoa__Service_Number__c FROM csord__Service__c];

        List<String> servNumList = new List<String>();
        for(csord__Service__c serv : servList){
            servNumList.add(serv.csordtelcoa__Service_Number__c);
        }
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockStockCheckCalloutResponse('noService', order.csord__Order_Number__c, servNumList));
        Boolean result = PONROrderItemHandler.syncExecute(order.csord__Order_Number__c);
        Test.stopTest();
        System.assert(!result);
        for(csord__Service__c serv : [SELECT id,csordtelcoa__Service_Number__c,csordtelcoa__Point_of_No_Return_Reached__c, cancel_Point_of_No_Return_Reached__c,csord__Subscription__r.Point_of_No_Return_Reached__c, csord__Subscription__r.cancel_Point_of_No_Return_Reached__c  FROM csord__Service__c WHERE csordtelcoa__Replaced_Service__c != '' AND csordtelcoa__Product_Configuration__r.ConfigurationType1__c = 'SolutionComponent']){
            System.assert(serv.csordtelcoa__Point_of_No_Return_Reached__c);
            System.assert(serv.cancel_Point_of_No_Return_Reached__c);
            System.assert(serv.csord__Subscription__r.Point_of_No_Return_Reached__c);
            System.assert(serv.csord__Subscription__r.cancel_Point_of_No_Return_Reached__c);
        }
        
    }

    @isTest
    public static void case3test(){
        //Check for a MACD service and where Rollback is present
        csord__Order__c order = [SELECT csord__Order_Number__c FROM csord__Order__c];
        csord__Service__c replacedService = [SELECT Id FROM csord__Service__c WHERE Name = 'testReplacedService'];
        List<csord__Service__c> servList = [SELECT id, csordtelcoa__Service_Number__c FROM csord__Service__c WHERE Name != 'testReplacedService' LIMIT 1];
        List<String> servNumList = new List<String>();
        for(csord__Service__c serv : servList){
            servNumList.add(serv.csordtelcoa__Service_Number__c);
            serv.csordtelcoa__Replaced_Service__c = replacedService.Id;
        }
        update servList;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockStockCheckCalloutResponse('noService', order.csord__Order_Number__c, servNumList));
        Boolean result = PONROrderItemHandler.syncExecute(order.csord__Order_Number__c);
        Test.stopTest();
        System.assert(!result);
        for(csord__Service__c serv : [SELECT id,csordtelcoa__Service_Number__c,csordtelcoa__Point_of_No_Return_Reached__c, cancel_Point_of_No_Return_Reached__c,csord__Subscription__r.Point_of_No_Return_Reached__c, csord__Subscription__r.cancel_Point_of_No_Return_Reached__c  FROM csord__Service__c WHERE csordtelcoa__Replaced_Service__c != '' AND csordtelcoa__Product_Configuration__r.ConfigurationType1__c = 'SolutionComponent']){
            System.assert(!serv.csordtelcoa__Point_of_No_Return_Reached__c);
            System.assert(!serv.cancel_Point_of_No_Return_Reached__c);
            System.assert(!serv.csord__Subscription__r.Point_of_No_Return_Reached__c);
            System.assert(!serv.csord__Subscription__r.cancel_Point_of_No_Return_Reached__c);
        }
    }
    @isTest
    public static void case4Errortest(){
        //Check for a new service and where Rollback is present
        csord__Order__c order = [SELECT csord__Order_Number__c FROM csord__Order__c];
        csord__Service__c replacedService = [SELECT Id FROM csord__Service__c WHERE Name = 'testReplacedService'];
        List<csord__Service__c> servList = [SELECT id, csordtelcoa__Service_Number__c FROM csord__Service__c WHERE Name != 'testReplacedService'];
        List<String> servNumList = new List<String>();
        for(csord__Service__c serv : servList){
            servNumList.add(serv.csordtelcoa__Service_Number__c);
            serv.csordtelcoa__Replaced_Service__c = replacedService.Id;
        }
        update servList;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockStockCheckCalloutResponse('success_Error', order.csord__Order_Number__c, servNumList));
        Boolean result = PONROrderItemHandler.syncExecute(order.csord__Order_Number__c);
        Test.stopTest();
        System.assert(result);
        for(csord__Service__c serv : [SELECT id,csordtelcoa__Service_Number__c,csordtelcoa__Point_of_No_Return_Reached__c, cancel_Point_of_No_Return_Reached__c,csord__Subscription__r.Point_of_No_Return_Reached__c, csord__Subscription__r.cancel_Point_of_No_Return_Reached__c  FROM csord__Service__c WHERE csordtelcoa__Service_Number__c IN :servNumList ]){
            System.assert(!serv.csordtelcoa__Point_of_No_Return_Reached__c);
            System.assert(!serv.cancel_Point_of_No_Return_Reached__c);
            System.assert(!serv.csord__Subscription__r.Point_of_No_Return_Reached__c);
            System.assert(!serv.csord__Subscription__r.cancel_Point_of_No_Return_Reached__c);
        }
    }
    
    @isTest
    public static void case5test(){
        //Check for a new service and where Rollback is present, no serices in responce 
        csord__Order__c order = [SELECT csord__Order_Number__c FROM csord__Order__c];
        csord__Service__c replacedService = [SELECT Id FROM csord__Service__c WHERE Name = 'testReplacedService'];
        List<csord__Service__c> servList = [SELECT id, csordtelcoa__Service_Number__c FROM csord__Service__c WHERE Name != 'testReplacedService' LIMIT 1];
        List<String> servNumList = new List<String>();
        for(csord__Service__c serv : servList){
            servNumList.add(serv.csordtelcoa__Service_Number__c);
            serv.csordtelcoa__Replaced_Service__c = replacedService.Id;
        }
        update servList;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockStockCheckCalloutResponse('noService', order.csord__Order_Number__c, servNumList));
        Boolean result = PONROrderItemHandler.syncExecute(order.csord__Order_Number__c);
        Test.stopTest();
        System.assert(!result);
        for(csord__Service__c serv : [SELECT id,csordtelcoa__Service_Number__c,csordtelcoa__Point_of_No_Return_Reached__c, cancel_Point_of_No_Return_Reached__c,csord__Subscription__r.Point_of_No_Return_Reached__c, csord__Subscription__r.cancel_Point_of_No_Return_Reached__c  FROM csord__Service__c WHERE csordtelcoa__Replaced_Service__c != '' AND csordtelcoa__Product_Configuration__r.ConfigurationType1__c = 'SolutionComponent' ]){
            System.assert(!serv.csordtelcoa__Point_of_No_Return_Reached__c);
            System.assert(!serv.cancel_Point_of_No_Return_Reached__c);
            System.assert(!serv.csord__Subscription__r.Point_of_No_Return_Reached__c);
            System.assert(!serv.csord__Subscription__r.cancel_Point_of_No_Return_Reached__c);
        }
    }
    
    @isTest
    public static void case6test(){
        //Check for a new service and where Rollback is not present, only one service in response.
        csord__Order__c order = [SELECT csord__Order_Number__c FROM csord__Order__c];
        List<csord__Service__c> servList = [SELECT id, csordtelcoa__Service_Number__c FROM csord__Service__c WHERE Name = 'testService1' LIMIT 1];
        List<String> servNumList = new List<String>();
        for(csord__Service__c serv : servList){
            servNumList.add(serv.csordtelcoa__Service_Number__c);
        }
                
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockStockCheckCalloutResponse('oneService', order.csord__Order_Number__c, servNumList));
        Boolean result = PONROrderItemHandler.syncExecute(order.csord__Order_Number__c);
        Test.stopTest();
        System.assert(result);
        for(csord__Service__c serv : [SELECT id,csordtelcoa__Service_Number__c,csordtelcoa__Point_of_No_Return_Reached__c, cancel_Point_of_No_Return_Reached__c,csord__Subscription__r.Point_of_No_Return_Reached__c, csord__Subscription__r.cancel_Point_of_No_Return_Reached__c  FROM csord__Service__c WHERE csordtelcoa__Service_Number__c IN :servNumList ]){
            System.assert(serv.csordtelcoa__Point_of_No_Return_Reached__c);
            System.assert(serv.cancel_Point_of_No_Return_Reached__c);
            System.assert(serv.csord__Subscription__r.Point_of_No_Return_Reached__c);
            System.assert(serv.csord__Subscription__r.cancel_Point_of_No_Return_Reached__c);
        }
    }

/* 
    @isTest
    public static void callStockCheckService_Success(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockStockCheckCalloutResponse('success_Search'));
        PONROrderItemHandler hdlr = new PONROrderItemHandler();
        getPONROrderItemDTD dto = PONROrderItemHandler.syncExecute('2433222'); 
        System.assertEquals((dto!=null), true, 'Callout Failed');
        Test.setMock(HttpCalloutMock.class, new MockStockCheckCalloutResponse('success_Error'));
        dto = PONROrderItemHandler.syncExecute('8876366');
        System.assertEquals((dto!=null), true, 'Callout Failed');       
        Test.stopTest();
    }  
    
    @isTest
    public static void CreateTestData(){
        
        csord__Subscription__c subs = new csord__Subscription__c();
        subs.Name = 'test subscription';
        subs.csord__Identification__c = 'sub - 1234';
        insert subs;
        
       
         csord__Service__c csr = new csord__Service__c();
        csr.name = 'test';
        csr.csordtelcoa__Point_of_No_Return_Reached__c = false;
        csr.csordtelcoa__Service_Number__c = '010276687';
        csr.csord__Subscription__c = subs.Id;
        csr.csord__Identification__c = 'testing';
        insert csr;
        system.debug('csr '+csr.Id+' cdr servicenum '+csr.csordtelcoa__Service_Number__c);
        csord__Service__c csr2 = [SELECT Id,csordtelcoa__Service_Number__c,csord__Identification__c FROM csord__Service__c WHERE Id=:csr.Id];
        System.assertEquals('testing',csr2.csord__Identification__c);
        system.debug('Assertvalue'+csr2.csord__Identification__c);
        Test.startTest();
        PONRReturnCheckHandler handler = new PONRReturnCheckHandler();
        handler.updateOrderSerice(new List<String>{'ON12314|'+csr2.csordtelcoa__Service_Number__c+'|9000b2ae-cecc-9205-e0a6-ed2e6447b5iu'});
         Test.stopTest();
    }
        */
        /*
		
	//Rollback Amend PONR exculde
     @isTest
    public static void case7test(){
        //Check for a new service and where Rollback is present, no serices in responce 
        cscfga__Product_Basket__c basket = [select id from cscfga__Product_Basket__c];
        productBasketToCheck = basket;
        csord__Order__c order = [SELECT csord__Order_Number__c,csord__Status2__c FROM csord__Order__c LIMIT 1];
        order.csord__Status2__c = Label.AmendRejectStatus;
        update order;
        csord__Service__c replacedService = [SELECT Id FROM csord__Service__c WHERE Name = 'testReplacedService'];
        List<csord__Service__c> servList = [SELECT id, csordtelcoa__Service_Number__c FROM csord__Service__c WHERE Name = 'testService3' LIMIT 1];
        List<String> servNumList = new List<String>();
        for(csord__Service__c serv : servList){
            servNumList.add(serv.csordtelcoa__Service_Number__c);
            serv.csordtelcoa__Replaced_Service__c = replacedService.Id;
            serv.csordtelcoa__Service_Number__c = 'SVC-000092730';
        }
        System.debug('servList == '+servList);
        update servList;			 
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockStockCheckCalloutResponse('noService', order.csord__Order_Number__c, servNumList));
        Boolean result = PONROrderItemHandler.syncExecute(order.csord__Order_Number__c);
        System.debug('resulttt '+result);
        Test.stopTest();
        System.assert(!result);
    }
    */

}