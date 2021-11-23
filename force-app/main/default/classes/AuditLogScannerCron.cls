/**
   *  Description : Schedular class which calls AuditlogsScanner Class
   *@ <Jira Story Ref>EDGE-96588<Jira Story Ref>
*/
global with Sharing class AuditLogScannerCron implements Schedulable {
	global void execute(SchedulableContext sc) {
		AuditLogsScanner logScanner = new AuditLogsScanner();
		logScanner.parseAuditLogs();
	}
}