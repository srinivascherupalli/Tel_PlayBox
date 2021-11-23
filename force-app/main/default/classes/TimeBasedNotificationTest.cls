/*
===============================================================================================================================
Class : TimeBasedNotificationTest
Developer Name :Anand Shekhar
===============================================================================================================================
Sr.No.  Developer Name      Date        Story Description
1.      Anand Shekhar       26/8/2020   DPG-2013 DPG | Adaptive Mobility | T-MDM | P2O Time based Triggering of API notification framework
===============================================================================================================================
*/
@isTest
public class TimeBasedNotificationTest {

    @isTest
    public static void publishBDSNotifyEventOneDayPrior() {

        Test.startTest();                
        BDSNotifyTestFactory.createTestDataTimeBound(-28);        
        Database.executeBatch(new TimeBasedNotification());
        Test.stopTest();
        System.assert(TimeBasedNotification.bdsNotificationEvents.size() == 1, 'There should be one element in the list' );

    }
    
    @isTest
    public static void publishBDSNotifyEventSevenDaysPrior() {

        Test.startTest();        
        BDSNotifyTestFactory.createTestDataTimeBound(-22);        
        Database.executeBatch(new TimeBasedNotification());
        Test.stopTest();
        System.assert(TimeBasedNotification.bdsNotificationEvents.size() == 1, 'There should be one element in the list' );

    }
    
    @isTest
    public static void publishBDSNotifyEventOneDayAfter() {

        Test.startTest();        
        BDSNotifyTestFactory.createTestDataTimeBound(-30);        
        Database.executeBatch(new TimeBasedNotification());
        Test.stopTest();
        System.assert(TimeBasedNotification.bdsNotificationEvents.size() > 0, 'There should be one element in the list' );

    }
    
    @isTest
    public static void publishBDSNotifyEventAnyOther() {

        Test.startTest();        
        BDSNotifyTestFactory.createTestDataTimeBound(-37);        
        Database.executeBatch(new TimeBasedNotification());
        Test.stopTest();
        System.assert(TimeBasedNotification.bdsNotificationEvents.size() == 0, 'There should be no element in the list' );

    }
    
    @isTest
    public static void publishBDSNotifyEventNoActivationDate() {

        Test.startTest();        
        BDSNotifyTestFactory.createTestDataTimeBoundNoActivationDate(-28);        
        Database.executeBatch(new TimeBasedNotification());
        Test.stopTest();
        System.assert(TimeBasedNotification.bdsNotificationEvents.size() == 0, 'There should be no element in the list' );

    }

}