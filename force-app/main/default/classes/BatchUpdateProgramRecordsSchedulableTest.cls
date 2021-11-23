@isTest
public without sharing class BatchUpdateProgramRecordsSchedulableTest {

    private static testMethod void WhenbatchUpdateProgramRecordScheduleSuccess(){

        String CRON_EXP = '0 0 0 ? * * *';

        Test.startTest();
        String jobId = System.schedule('ScheduleApexClassTest',  CRON_EXP, new BatchUpdateProgramRecordsSchedulable());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest();
   }
}