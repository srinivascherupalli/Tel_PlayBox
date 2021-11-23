/*
===============================================================================================================================
Class : TimeBasedNotificationSchedulerTest
Developer Name :Anand Shekhar
===============================================================================================================================
Sr.No.  Developer Name      Date        Story Description
1.      Anand Shekhar       26/8/2020   DPG-2018 | Adaptive Mobility | T-MDM | Integration of framework with BDS Services
===============================================================================================================================
*/
@isTest
public with sharing class TimeBasedNotificationSchedulerTest {
    
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';

    @isTest
    public static void publishBDSNotifyEventOneDayAfter() {

        Test.startTest();
        BDSNotifyTestFactory.createTestDataTimeBound(-30);
        String jobId = System.schedule('ScheduledApexTest', CRON_EXP, new TimeBasedNotificationScheduler());        
        Test.stopTest();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
    System.assertEquals(CRON_EXP, ct.CronExpression);
    System.assertEquals(0, ct.TimesTriggered);

    }

}