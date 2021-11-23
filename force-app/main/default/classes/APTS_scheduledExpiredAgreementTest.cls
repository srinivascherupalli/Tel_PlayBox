/*************************************************************************************************************************
@Name: APTS_scheduledExpiredAgreement
@Author: Lokesh D
@Created Date: 07/03/2020
@Descripton: Rolling status functionality.
*************************************************************************************************************************/
@istest
public Without sharing class APTS_scheduledExpiredAgreementTest {
    
    static testMethod void testMethod1(){
        
        Test.StartTest();
        APTS_scheduledExpiredAgreement testsche = new APTS_scheduledExpiredAgreement();
        String sch = '0 0 23 * * ?';
         String jobId =system.schedule('APTS_scheduledExpiredAgreementTest', sch, testsche );
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
         System.assertEquals(sch, ct.CronExpression);
        Test.stopTest();
    }

}