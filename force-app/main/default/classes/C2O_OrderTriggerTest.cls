//Added by P.M
@isTest
public class C2O_OrderTriggerTest {
    @testSetup
    static void setupTestData() {
        User enterpriseUser= SYS_TestDataFactory.createUser('Sales-Enterprise-Unified', 'Agribusiness');
        insert enterpriseUser;
        BypassTrigger.isRunningTestCheck = True;
        System.runAs(new User(Id = UserInfo.getUserId())) {

             // EDGE-215986 
            Sync_Control_and_Constants__c s1 = new Sync_Control_and_Constants__c(Name = 'Order Chatter Notification',Order_Completed_Chatter_Notification__c = 'Test', Order_In_Progress_Chatter_Notification__c  = 'Test');
            insert s1;
            
            BDS_Notify_Settings__c bdsNotifySettingFeatureLevel = (BDS_Notify_Settings__c) SYS_TestDataFactory.createCustomSetting(BDS_Notify_Settings__c.sObjectType);
            bdsNotifySettingFeatureLevel.Name = 'Feature Level';
            bdsNotifySettingFeatureLevel.Value__c = 'FeatureLevelShadow';
            BDS_Notify_Settings__c bdsNotifySettingTechnicalSupport = (BDS_Notify_Settings__c) SYS_TestDataFactory.createCustomSetting(BDS_Notify_Settings__c.sObjectType);
            bdsNotifySettingTechnicalSupport.Name = 'Technical Support';
            bdsNotifySettingTechnicalSupport.Value__c = 'TechnicalSupportShadow';

            insert new List<BDS_Notify_Settings__c>{bdsNotifySettingFeatureLevel, bdsNotifySettingTechnicalSupport};
            
            Account testAccount = SYS_TestDataFactory.createAccount('1234565');
            testAccount.Name = 'testAccount';
            testAccount.Customer_Status__c = 'ACTIVE';
            insert testAccount;

            
            Opportunity testOpp = SYS_TestDataFactory.createOpportunity(testAccount.Id);
            testOpp.Product_Type__c = 'Modular';
            testOpp.Type = 'Price Review';
            testOpp.Billing_Solution__c= 'In Contract';
            insert testOpp;
            
            list<csord__Order__c> ordList = new list<csord__Order__c>();

        csord__Order__c testOrder = new csord__Order__c();
        testOrder.csord__Account__c = testAccount.Id;
        testOrder.csordtelcoa__Opportunity__c = testOpp.Id;
        testOrder.Name = 'TestOrderNameForTest';
        testOrder.csord__Identification__c = 'test';
        testOrder.csord__status2__c = 'New';
        testOrder.isMSISDNHeld__c = false;


        testOrder.OwnerId = UserInfo.getUserId();
        ordList.add(testOrder);

        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = testAccount.Id;
        testBasket.Name = 'ShowSubTestBasket';
        testBasket.cscfga__Opportunity__c = testOpp.Id;
        testBasket.channelFrom__c = 'TED-81 onlineAPI';
        testBasket.correlation_id__c = '008415e6-f785-66b8-811b-bc94838dde4d';
        insert testBasket;

        csord__Solution__c sol = new csord__Solution__c(Name = 'Adaptive Mobility', csord__Account__c = testAccount.Id, csord__External_Identifier__c = '12345', csord__External_Identifier2__c = '1234', csord__Identification__c = '12');
        insert sol;
        
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>();
        cscfga__Product_Definition__c cwProdDef = new cscfga__Product_Definition__c(Name = 'Apdaptive Mobility', cscfga__Description__c = 'Adaptive Mobility');
        pdList.add(cwProdDef);  
        insert pdList;

        List<cscfga__Product_Configuration__c> prodconfigList=new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c testConfig = new cscfga__Product_Configuration__c();
        testConfig.Name = 'Adaptive Mobility';
        testConfig.ConfigurationType1__c = 'SolutionComponent';
        testConfig.cscfga__Product_Basket__c = testBasket.Id;
        testConfig.cscfga__Product_Definition__c=cwProdDef.Id;
        prodconfigList.add(testConfig);
        insert prodconfigList;
        
        csord__Order__c testOrder1 = new csord__Order__c();
        testOrder1.csord__Account__c = testAccount.Id;
        testOrder1.csordtelcoa__Opportunity__c = testOpp.Id;
        testOrder1.Name = 'TestOrd';
        testOrder1.csord__Identification__c = 'test';
        testOrder1.csord__status2__c = 'In Progress';
        testOrder1.isMSISDNHeld__c = false;
        testOrder1.OwnerId = UserInfo.getUserId();
        testOrder1.Product_Basket__c = testBasket.Id;
        ordList.add(testOrder1);
        
        csord__Order__c testOrder2 = new csord__Order__c();
        testOrder2.csord__Account__c = testAccount.Id;
        testOrder2.csordtelcoa__Opportunity__c = testOpp.Id;
        testOrder2.Name = 'TestOrd1';
        testOrder2.csord__Identification__c = 'test';
        testOrder2.csord__status2__c = 'Completed';
        testOrder2.isMSISDNHeld__c = false;
        testOrder2.OwnerId = UserInfo.getUserId();
        ordList.add(testOrder2);
            
        csord__Order__c testOrder3 = new csord__Order__c();
        testOrder3.csord__Account__c = testAccount.Id;
        testOrder3.csordtelcoa__Opportunity__c = testOpp.Id;
        testOrder3.Name = 'TestOrd1';
        testOrder3.csord__Identification__c = 'test';
        testOrder3.csord__status2__c = 'Ready For Submit';
        testOrder3.isMSISDNHeld__c = false;
        testOrder3.OwnerId = enterpriseUser.Id;
        ordList.add(testOrder3);    
            
        csord__Order__c testOrder4 = new csord__Order__c();
        testOrder4.csord__Account__c = testAccount.Id;
        testOrder4.csordtelcoa__Opportunity__c = testOpp.Id;
        testOrder4.Name = 'TestOrd1';
        testOrder4.csord__Identification__c = 'test';
        testOrder4.csord__status2__c = 'Submitting';
        testOrder4.isMSISDNHeld__c = false;
        testOrder4.OwnerId = UserInfo.getUserId();
        ordList.add(testOrder4);   
            
        csord__Order__c testOrder5 = new csord__Order__c();
        testOrder2.csord__Account__c = testAccount.Id;
        //testOrder5.csordtelcoa__Opportunity__c = testOpp.Id;
        testOrder5.Name = 'TestOrd1';
        testOrder5.csord__Identification__c = 'test';
        testOrder5.csord__status2__c = 'Completed';
        testOrder5.isMSISDNHeld__c = false;
        testOrder5.OwnerId = UserInfo.getUserId();
        ordList.add(testOrder5);    
        insert ordList;

        List<csord__Subscription__c> subslist=new List<csord__Subscription__c>();
            csord__Subscription__c testSubscription = new csord__Subscription__c();
            testSubscription.Name = 'TestSubsforTest';
            testSubscription.csord__Account__c = testAccount.Id;
            testSubscription.csord__Identification__c = 'test';
            testSubscription.csordtelcoa__Subscription_Number__c = 'SN-000552601';
            testSubscription.csord__Status__c = 'Active';
            testSubscription.csord__Order__c = testOrder1.Id;
            testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
            testSubscription.cssdm__solution_association__c = sol.id;
            subslist.add(testSubscription);
       
        }
    }
    
    @isTest static void testSubscriptionTrigger() {
        test.starttest();
            BypassTrigger.isRunningTestCheck = true;
            List<csord__Order__c> listOfOrderToUpdate = [SELECT Id, csord__Status2__c FROM csord__Order__c LIMIT 5];
            listOfOrderToUpdate[0].csord__Status2__c = C2O_OrderConstants.STATUS_IN_PROGRESS;
            listOfOrderToUpdate[1].csord__Status2__c = C2O_OrderConstants.STATUS_READY_FOR_SUBMIT;
            listOfOrderToUpdate[2].csord__Status2__c = C2O_OrderConstants.STATUS_COMPLETED;
            listOfOrderToUpdate[3].csord__Status2__c = Label.OrderStatus;
            update listOfOrderToUpdate;
        test.stoptest();
    }
    
    @isTest
    static void testOrderEventPublishing()
    {
        Test.startTest();
        BypassTrigger.isRunningTestCheck = true;
        csord__Order__c testOrder = [select id,csord__status2__c from csord__Order__c limit 1];
        testOrder.csord__status2__c = 'Ready for Submit';
        update testOrder;
        Test.stopTest();
        //system.assertEquals(C2O_OrderTriggerHelper.orderEventList.size(),1);
        system.assertEquals(OrderCustomTriggerHandler.orderEventList.size(),0);
    }
    @isTest
    static void testOrderEventPublishingException()
    {
        Test.startTest();
        OrderCustomTriggerHandler.testException = true;
          BypassTrigger.isRunningTestCheck = true;
        csord__Order__c testOrder = [select id,csord__status2__c from csord__Order__c where Name = 'TestOrd' limit 1];
        testOrder.csord__status2__c = 'Ready for Submit';
        update testOrder;
        Test.stopTest();
        system.assertNotEquals([select id from Exception_Log__c].size(),0);
        //system.assertEquals([select id from Exception_Log__c].size(),2);
    }


    //EDGE-215986 -- Start
    @isTest
    static void postChatterNotificationTest()
    {  
        list<csord__Order__c> orderList = new list<csord__Order__c>();
        map<id,csord__Order__c> orderMap = new map<id,csord__Order__c>();
        for(csord__Order__c ord : [select id,csord__Order_Number__c,csord__Status2__c,csordtelcoa__Opportunity__r.owner.id,
                                   csord__Account__r.name,owner.id,csordtelcoa__Opportunity__r.owner.profile.name, owner.profile.name 
                                   from csord__Order__c where name = 'TestOrd1']){
                                       orderList.add(ord);
                                         
                                   }
        for(csord__Order__c ord : [select id,csord__Order_Number__c,csord__Status2__c,csordtelcoa__Opportunity__r.owner.id,
                                   csord__Account__r.name,owner.id,csordtelcoa__Opportunity__r.owner.profile.name, owner.profile.name 
                                   from csord__Order__c where name = 'TestOrd1']){
                                       
                                       ord.csord__Status2__c = 'In Progress';
                                      orderMap.put(ord.id,ord);   
                                   }
       test.startTest();
        BypassTrigger.isRunningTestCheck = true;
        OrderCustomTriggerHandler.postChatterNotification(orderList, orderMap);
        test.stopTest();
    }
    @isTest
    static void postChatterNotificationCompletedTest()
    {  
        list<csord__Order__c> orderList = new list<csord__Order__c>();
        map<id,csord__Order__c> orderMap = new map<id,csord__Order__c>();
        for(csord__Order__c ord : [select id,csord__Order_Number__c,csord__Status2__c,csordtelcoa__Opportunity__r.owner.id,
                                   csord__Account__r.name,owner.id,csordtelcoa__Opportunity__r.owner.profile.name, owner.profile.name,Base_URL__c 
                                   from csord__Order__c where name = 'TestOrd']){
                                       orderList.add(ord);
                                         
                                   }
        for(csord__Order__c ord : [select id,csord__Order_Number__c,csord__Status2__c,csordtelcoa__Opportunity__r.owner.id,
                                   csord__Account__r.name,owner.id,csordtelcoa__Opportunity__r.owner.profile.name, owner.profile.name 
                                   from csord__Order__c where name = 'TestOrd']){
                                       
                                       ord.csord__Status2__c = 'Completed';
                                      orderMap.put(ord.id,ord);   
                                   }
       test.startTest();
        BypassTrigger.isRunningTestCheck = true;
        OrderCustomTriggerHandler.postChatterNotification(orderList, orderMap);
        ConnectApi.FeedItemInput chat = C2O_OrderTriggerHelper.createChatterPostForReadyForSubmit(orderList[0]);
        test.stopTest();
    }
    //EDGE-215986 - End
    
        @isTest static void testOrderTrigger() {
        test.starttest();
            BypassTrigger.bypassTriggerAtOG = true;
            BypassTrigger.isRunningTestCheck = true;
            List<csord__Order__c> listOfOrderToUpdate = [SELECT Id, csord__Status2__c FROM csord__Order__c LIMIT 5];
            listOfOrderToUpdate[0].csord__Status2__c = C2O_OrderConstants.STATUS_IN_PROGRESS;
            listOfOrderToUpdate[1].csord__Status2__c = C2O_OrderConstants.STATUS_READY_FOR_SUBMIT;
            listOfOrderToUpdate[2].csord__Status2__c = C2O_OrderConstants.STATUS_COMPLETED;
            listOfOrderToUpdate[3].csord__Status2__c = Label.OrderStatus;
            update listOfOrderToUpdate;
        test.stoptest();
    }
}