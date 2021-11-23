/******************************************************************************************************
    *Class Name     : OrderCustomTriggerHandlerTest
    *Decription     : Test class for OrderCustomTriggerHandler
    
   Sr.No.      Developer Name          Date            Story           Description
    1.         Jagadeswary            31/3/21          EDGE-209486    Publish new platform event

    2.          Gokul                   14/05/21        EDGE-215986     Post chatter notification based on order status
    3.        Uday                     06-10-2021       DIGI-515         Commented this class as this class was no longer used 
**************************************************************************************************/
@isTest 
public class OrderCustomTriggerHandlerTest {
    /*
    @testSetup static void setup() {
        
        BDS_Notify_Settings__c bdsNotifySettingFeatureLevel = (BDS_Notify_Settings__c) SYS_TestDataFactory.createCustomSetting(BDS_Notify_Settings__c.sObjectType);
        bdsNotifySettingFeatureLevel.Name = 'Feature Level';
        bdsNotifySettingFeatureLevel.Value__c = 'FeatureLevelShadow';
        BDS_Notify_Settings__c bdsNotifySettingTechnicalSupport = (BDS_Notify_Settings__c) SYS_TestDataFactory.createCustomSetting(BDS_Notify_Settings__c.sObjectType);
        bdsNotifySettingTechnicalSupport.Name = 'Technical Support';
        bdsNotifySettingTechnicalSupport.Value__c = 'TechnicalSupportShadow';
        
        insert new List<BDS_Notify_Settings__c>{bdsNotifySettingFeatureLevel, bdsNotifySettingTechnicalSupport};
                
        Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        testAccount.Customer_Status__c = 'ACTIVE';
        testAccount.Cidn__c = '1212';
        insert testAccount;
        
        Opportunity testOpp = new Opportunity();
        testOpp.Account = testAccount;
        testOpp.Name = 'testOpp';
        testOpp.StageName = 'Define';
        testOpp.Product_Type__c = 'Modular';
        testOpp.CloseDate = System.Date.today();
        testOpp.Type = 'New To Market';
        testOpp.Product_Domain__c = 'FIXED TELEPHONY';
        testOpp.Pricing_Method__c = 'PET';
        testOpp.Billing_Solution__c = 'Non Standard';
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
        
        csord__Order__c testOrder1 = new csord__Order__c();
        testOrder1.csord__Account__c = testAccount.Id;
        testOrder1.csordtelcoa__Opportunity__c = testOpp.Id;
        testOrder1.Name = 'TestOrd';
        testOrder1.csord__Identification__c = 'test';
        testOrder1.csord__status2__c = 'In Progress';
        testOrder1.isMSISDNHeld__c = false;
        testOrder1.OwnerId = UserInfo.getUserId();
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
        insert ordList;
        // EDGE-215986 
        Sync_Control_and_Constants__c s1 = new Sync_Control_and_Constants__c(Name = 'Order Chatter Notification',Order_Completed_Chatter_Notification__c = 'Test', Order_In_Progress_Chatter_Notification__c  = 'Test');
        insert s1;
    
        
        
    }
    @isTest
    static void testOrderEventPublishing()
    {
        Test.startTest();
        csord__Order__c testOrder = [select id,csord__status2__c from csord__Order__c limit 1];
        testOrder.csord__status2__c = 'Ready for Submit';
        update testOrder;
        Test.stopTest();
        system.assertEquals(OrderCustomTriggerHandler.orderEventList.size(),1);
    }
    @isTest
    static void testOrderEventPublishingException()
    {
        Test.startTest();
        OrderCustomTriggerHandler.testException = true;
        csord__Order__c testOrder = [select id,csord__status2__c from csord__Order__c limit 1];
        testOrder.csord__status2__c = 'Ready for Submit';
        update testOrder;
        Test.stopTest();
        system.assertEquals([select id from Exception_Log__c].size(),1);
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
        OrderCustomTriggerHandler.postChatterNotification(orderList, orderMap);
        test.stopTest();
    }
   @isTest
    static void postChatterNotificationCompletedTest()
    {  
        list<csord__Order__c> orderList = new list<csord__Order__c>();
        map<id,csord__Order__c> orderMap = new map<id,csord__Order__c>();
        for(csord__Order__c ord : [select id,csord__Order_Number__c,csord__Status2__c,csordtelcoa__Opportunity__r.owner.id,
                                   csord__Account__r.name,owner.id,csordtelcoa__Opportunity__r.owner.profile.name, owner.profile.name 
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
        OrderCustomTriggerHandler.postChatterNotification(orderList, orderMap);
        test.stopTest();
    }
    //EDGE-215986 - End
*/
}