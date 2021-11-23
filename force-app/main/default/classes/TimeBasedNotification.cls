/*
===============================================================================================================================
Class : TimeBasedNotification
Developer Name :Anand Shekhar
Test Class : TimeBasedNotificationTest
===============================================================================================================================
Sr.No.  Developer Name      Date        Story Description
1.      Anand Shekhar       26/8/2020   DPG-2013 DPG | Adaptive Mobility | T-MDM | P2O Time based Triggering of API notification framework
===============================================================================================================================
*/
global class TimeBasedNotification implements Database.Batchable<sObject> {
    
    
    @testVisible static List<BDS_Notification_Event__e> bdsNotificationEvents = new List<BDS_Notification_Event__e>();

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String tmdmMarketableOffer = BDS_Notify_Settings__c.getValues('TMDM Marketable Offer').Value__c;
        String query = 'SELECT Id, csord__Account__r.Id, MarketableOffer__r.Offer_ID__c, MarketableOffer__r.Name, TenancyID__c, Billing_Account__r.Billing_Account_Number__c FROM csord__Subscription__c WHERE MarketableOffer__r.Offer_ID__c =:tmdmMarketableOffer AND csordtelcoa__Product_Configuration__r.ConfigurationType1__c!=\'SolutionComponent\'';

        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<csord__Subscription__c> listOfSubscription) {

        bdsNotificationEvents = BDSNotifyService.triggerTimeBoundPlatformEvent();

        BDSNotifyService.createBDSPlatformEvent(bdsNotificationEvents);

    }

    global void finish(Database.BatchableContext bc) {

    }
}