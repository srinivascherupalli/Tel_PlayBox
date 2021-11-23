/**
   *  Description : Test class for AuditLogScannerCron Class
   *@ <Jira Story Ref>EDGE-96588<Jira Story Ref>
*/
@isTest
public class AuditLogSchedulerTestClass {
	public static testMethod void auditLogSchedulerCase1(){
        Test.startTest();
        AuditTrail_Sections__c sectionName = new AuditTrail_Sections__c();
        sectionName.Name = 'Apex Class';
        insert sectionName;
        AuditTrail_Emails__c email = new AuditTrail_Emails__c();
        email.Name = 'Suyash Chiplunkar';
        email.Email__c = 'suyash.chiplunkar@infosys.com';
        insert email;
        AuditTrail_UsersToExclude__c userName = new AuditTrail_UsersToExclude__c();
        userName.Name = 'Kunal Mannan';
        userName.User_Name__c = 'kunal.mannan@infosys.com';
        insert userName;
        
        AuditLogScannerCron auditLogCron = new AuditLogScannerCron();
        String sch = '0 0 23 * * ?'; 
        String jobId = system.schedule('Audit Log Cron Test', sch, auditLogCron); 
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch, ct.CronExpression);
        Test.stopTest();
    }
    
    public static testMethod void auditLogSchedulerCase2(){
        Test.startTest();
        AuditLogScannerCron auditLogCron = new AuditLogScannerCron();
        String sch = '0 0 23 * * ?'; 
        String jobId = system.schedule('Audit Log Cron Test', sch, auditLogCron); 
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        Test.stopTest();
        System.assertEquals(sch, ct.CronExpression);
        System.assertequals(auditLogsScanner.sendEmailto.size(), 0);
        System.assertequals(auditLogsScanner.includeSections.size(), 0);
    }
}