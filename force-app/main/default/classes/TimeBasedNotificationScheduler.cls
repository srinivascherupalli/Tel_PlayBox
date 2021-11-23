/*
===============================================================================================================================
Class : TimeBasedNotificationScheduler
Developer Name :Anand Shekhar
Test Class : TimeBasedNotificationSchedulerTest
===============================================================================================================================
Sr.No.  Developer Name      Date        Story Description
1.      Anand Shekhar       26/8/2020   DPG-2018 | Adaptive Mobility | T-MDM | Integration of framework with BDS Services
===============================================================================================================================
*/
global class TimeBasedNotificationScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new TimeBasedNotification(), 200);
    }
}