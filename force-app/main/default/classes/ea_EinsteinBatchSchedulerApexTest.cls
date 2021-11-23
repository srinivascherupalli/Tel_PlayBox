/**
* Author : Shreyansh Sharma(Jaipur)
* Date : 5/24/2021
* Description: P2OB-14430, Test class for ea_EinsteinBatchSchedulerApex
**/
@isTest(seeAllData=false)
public class ea_EinsteinBatchSchedulerApexTest {
    public static testMethod void testschedule() {
       // public static String CRON_EXP = '0 15 * * * ?';
        Test.StartTest();
        ea_EinsteinBatchSchedulerApex sh1 = new ea_EinsteinBatchSchedulerApex();
        
        String sch = '0 15 * * * ?'; 
        string jobId =  system.schedule('ea_EinsteinBatchSchedulerApex', sch, sh1); 
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                              FROM CronTrigger WHERE id = :jobId];
            System.assertEquals(sch,ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        Test.stopTest(); 
    }
}