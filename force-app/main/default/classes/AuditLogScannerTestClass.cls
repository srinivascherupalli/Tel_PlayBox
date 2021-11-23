/**
   *  Description : Test class for AuditlogsScanner Class
   *@ <Jira Story Ref>EDGE-96588<Jira Story Ref>
*/
@isTest
public class AuditLogScannerTestClass {

    public static testMethod void logScannerCase1(){
        AuditTrail_Sections__c sectionName = new AuditTrail_Sections__c();
        sectionName.Name = 'Apex Class';
        insert sectionName;
        AuditTrail_Emails__c email = new AuditTrail_Emails__c();
        email.Email__c = 'suyash.chiplunkar@infosys.com';
        email.Name = 'Suyash Chiplunkar';
        insert email; 
        AuditTrail_UsersToExclude__c userName = new AuditTrail_UsersToExclude__c();
        userName.Name = 'Kunal Mannan';
        userName.User_Name__c = 'kunal.mannan@infosys.com';
        insert userName;
        Test.startTest();
        AuditLogsScanner log = new AuditLogsScanner();
        log.parseAuditLogs();
        Test.stopTest();
    }
    
    public static testMethod void logScannerCase2(){
        Test.startTest();
        AuditLogsScanner log = new AuditLogsScanner();
        log.parseAuditLogs();
        Test.stopTest();
        System.assertequals(auditLogsScanner.sendEmailto.size(), 0);
        System.assertequals(auditLogsScanner.includeSections.size(), 0);
    }
}