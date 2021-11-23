/*
===============================================================================================================================
Class : BDSNotifyServiceTest
Developer Name :Anand Shekhar
===============================================================================================================================
Sr.No.  Developer Name      Date        Story Description
1.      Anand Shekhar       11/11/2020   DPG-3292 DPG | Adaptive Mobility Care | P2O | Send order "Complete" status notification for New and Cancel Order Type
2.      Anand Shekhar       11/11/2020   DPG-3293 DPG | Adaptive Mobility Managed Services | P2O | Send order "In Progress" and "Complete" status notification for New, Modify and Cancel Order Type
3.      Anand Shekhar       11/11/2020   DPG-3294 DPG | Professional Services | P2O | Send order "In Progress" and "Complete" status notification for New Order Type
4. 		Nikhil Sharma		30/08/2021	 DIGI-4694 | Fire BDS_Notification_Event platform event for DMS.
===============================================================================================================================
*/
@isTest
public with sharing class BDSNotifyServiceTest {

    
    @isTest
    public static void triggerPlatformEventNewCompleteTest() {

        Test.startTest();
         SYS_TriggerHandler.bypass('C2O_SubscriptionTriggerHandler');
         FeatureToggle__mdt toggle = new FeatureToggle__mdt();
         toggle = [Select developerName,EnableForAll__c from FeatureToggle__mdt where developerName = 'enableTED217'];
         toggle.EnableForAll__c = false;
        List<csord__Subscription__c> subscriptionList = BDSNotifyTestFactory.createTestDataNewComplete();        
        BDSNotifyService.triggerPlatformEvent(subscriptionList, 'Complete');
        Test.stopTest();
        System.debug('Notify Events size :: ' + BDSNotifyService.notifyEvents.size());
        System.assert(BDSNotifyService.notifyEvents.size() > 0, 'There should be at least one element in the list' );
        
    }
    
    @isTest
    public static void triggerPlatformEventCancelCompleteTest() {

        Test.startTest();   
        FeatureToggle__mdt toggle = new FeatureToggle__mdt();
        toggle = [Select developerName,EnableForAll__c from FeatureToggle__mdt where developerName = 'enableTED217'];
        toggle.EnableForAll__c = false;         
        List<csord__Subscription__c> subscriptionList = BDSNotifyTestFactory.createTestDataCancelComplete();        
        BDSNotifyService.triggerPlatformEvent(subscriptionList, 'Complete');
        Test.stopTest();
        System.debug('Notify Events size :: ' + BDSNotifyService.notifyEvents.size());
        System.assert(BDSNotifyService.notifyEvents.size() > 0, 'There should be at least one element in the list' );
        
    }
    
    @isTest
    public static void triggerPlatformEventModifyCompleteTest() {

        Test.startTest();    
        FeatureToggle__mdt toggle = new featureToggle__mdt();
        toggle = [Select developerName,EnableForAll__c from FeatureToggle__mdt where developerName = 'enableTED217'];         
        List<csord__Subscription__c> subscriptionList = BDSNotifyTestFactory.createTestDataModifyComplete();        
        BDSNotifyService.triggerPlatformEvent(subscriptionList, 'Complete');
        Test.stopTest();
        System.debug('Notify Events size :: ' + BDSNotifyService.notifyEvents.size());
        System.assert(BDSNotifyService.notifyEvents.size() > 0, 'There should be at least one element in the list' );
        
    }
    
    @isTest
    public static void triggerPlatformEventNewInProgressTest() {

        Test.startTest();   
        FeatureToggle__mdt toggle = new FeatureToggle__mdt();
        toggle = [Select developerName,EnableForAll__c from FeatureToggle__mdt where developerName = 'enableTED217'];        
        List<csord__Subscription__c> subscriptionList = BDSNotifyTestFactory.createTestDataNewInProgress();        
        BDSNotifyService.triggerPlatformEvent(subscriptionList, 'InProgress');
        Test.stopTest();
        System.debug('Notify Events size :: ' + BDSNotifyService.notifyEvents.size());
        System.assert(BDSNotifyService.notifyEvents.size() > 0, 'There should be at least one element in the list' );
        
    }
    
    @isTest
    public static void triggerPlatformEventModifyInProgressTest() {

        Test.startTest(); 
        FeatureToggle__mdt toggle = new FeatureToggle__mdt();
        toggle = [Select developerName,EnableForAll__c from FeatureToggle__mdt where developerName = 'enableTED217'];          
        List<csord__Subscription__c> subscriptionList = BDSNotifyTestFactory.createTestDataModifyInProgress();        
        BDSNotifyService.triggerPlatformEvent(subscriptionList, 'InProgress');
        Test.stopTest();
        System.debug('Notify Events size :: ' + BDSNotifyService.notifyEvents.size());
        System.assert(BDSNotifyService.notifyEvents.size() > 0, 'There should be at least one element in the list' );
        
    }
    
    @isTest
    public static void createBDSPlatformEventTest(){

        Test.startTest(); 
        FeatureToggle__mdt toggle = new FeatureToggle__mdt();
        toggle = [Select developerName,EnableForAll__c from FeatureToggle__mdt where developerName = 'enableTED217'];
        SYS_TriggerHandler.bypass('C2O_SubscriptionTriggerHandler');
        List<csord__Subscription__c> subscriptionList = BDSNotifyTestFactory.createTestDataNewComplete();        
        List<BDS_Notification_Event__e> notifyEvents = BDSNotifyService.nonAMMSFlow(subscriptionList, 'Complete', OrderEmailServiceWrapperHelper.createPORMap(subscriptionList));
        BDSNotifyService.createBDSPlatformEvent(notifyEvents);
        Test.stopTest();
        
    }
    
    @isTest
    public static void createTimeBasedBDSPlatformEventTest(){

        Test.startTest();  
        FeatureToggle__mdt toggle = new FeatureToggle__mdt();
        toggle = [Select developerName,EnableForAll__c from FeatureToggle__mdt where developerName = 'enableTED217'];
        BDSNotifyTestFactory.createTestDataTimeBound(-30);    
        List<BDS_Notification_Event__e> notifyEvents = BDSNotifyService.triggerTimeBoundPlatformEvent();
        Test.stopTest();
        System.assert(notifyEvents.size() > 0, 'There should be atleast one element in the list' );
        
    }
    @isTest
    public static void testNotifyEventsForSubscriptions(){
        Test.startTest();                
        BDSNotifyService.logException('notifyEventsForSubscriptions','','123', 'Error', 'Send order notification for DMS failed.','BDSNotifyService');
        List<Exception_Log__c> logExceptionList = [SELECT ID FROM Exception_Log__c];
        Test.stopTest();
        System.assert(logExceptionList.size() > 0, 'There should be atleast one log in the list' );
    }

}