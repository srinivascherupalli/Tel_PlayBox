/*********************************************************************************************************************************
Class Name : BDSNotificationForNumberTriggerTest
Created By : Nikhil Sharma
Created On : 07/10/2021
Decription : Test class for BDSNotificationForNumberTrigger
===============================================================================================================================
*/
@isTest
public class BDSNotificationForNumberTriggerTest {
    
    @testSetup
    static void setupTestData() {
        Marketable_Offer__c marketableOffer = new Marketable_Offer__c();
        marketableOffer.Offer_ID__c = 'DMCAT_Offer_000618';
        marketableOffer.Name = 'Adaptive Collaboration';
        insert marketableOffer;
        
        Account acc = new Account();         
        acc.name = 'Test';
        acc.Pref_Comm_Method__c = 'B2B';
        acc.Customer_Status__c = 'ACTIVE';
        insert acc;
        
        List<csord__Subscription__c> subscriptions = new List<csord__Subscription__c>();
        csord__Subscription__c subscription = new csord__Subscription__c();
        subscription.csord__Identification__c='NGUC';
        subscription.MarketableOffer__c = marketableOffer.Id;
        //subscription.csordtelcoa__Subscription_Number__c='SN-000223173';
        subscription.csord__Status__c = 'Provisioned';
        subscription.serviceMSISDN__c='0123456789';
        subscriptions.add(subscription); 
        insert subscriptions;
        
        csord__Service__c ser = new csord__Service__c();
        ser.csordtelcoa__Service_Number__c = 'SVC-123456789';
        ser.csord__Subscription__c = subscriptions[0].Id;
        ser.csord__Identification__c = 'Service_Test_0';
        insert ser;
        
        Number_Group__c numberGroup = new Number_Group__c();
        numberGroup.Subscription_Number__c = 'SN-000223173';
        numberGroup.Status__c = 'Reserved';
        numberGroup.Scenario_Type__c = 'Add';
        insert numberGroup;
        
        csord__Subscription__c sub = [select Id,csord__Status__c,csordtelcoa__Subscription_Number__c from csord__Subscription__c limit 1];
        
        Number__c num = new Number__c();
        num.Service_Number__c = '61260452045';
        num.Subscription_Number__c =sub.csordtelcoa__Subscription_Number__c;
        num.Status__c = 'Reserved';
        num.Service_Id__c = 'SVC-123456789';
        num.Account__c = acc.Id ;
        num.Mobile__c = 'Fixed';
        num.Number_Group__c = numberGroup.Id;
        insert num;
        
        
    }
    
    @isTest
    public static void handleAfterInsertTest(){
        Test.startTest();
        BypassTrigger.isRunningTestCheck = true;
        csord__Subscription__c sub = [select Id,csord__Status__c,csordtelcoa__Subscription_Number__c from csord__Subscription__c limit 1];
        system.debug('Status::'+ sub.csord__Status__c);
        sub.csord__Status__c = 'Active';
        update sub;
        List<BDSNotificationForNumber__e> invokeBDSNotificationForNumbers = new List<BDSNotificationForNumber__e>();
        BDSNotificationForNumber__e eve = new BDSNotificationForNumber__e();
        eve.SubscriptionNumber__c = sub.csordtelcoa__Subscription_Number__c ;
        invokeBDSNotificationForNumbers.add(eve);
        List<Database.SaveResult> responses = EventBus.publish(invokeBDSNotificationForNumbers);
        system.assert(!responses.isEmpty());
        Test.stopTest();
    }
}