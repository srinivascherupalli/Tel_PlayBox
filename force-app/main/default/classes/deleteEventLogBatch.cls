/*
@Author 
@name deleteEventLogBatch
@CreateDate 08/10/2016
@Description - Batch class to delete event log after 15 days

*/ 

global Without sharing class deleteEventLogBatch implements Database.Batchable<sObject> ,  Database.Stateful{
    PLRAudit_log__c auditLog;
    Integer count;
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        auditLog = Util_PLR.logbatchstart(Constants_PLR.deleteEventLog_Batch);
        count=0;
        Date dt = Date.today().addDays(-15);
        string Query = Constants_PLR.DELETE_BATCH_QUERY;
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<Event_Log__c> scope){
        Try
        {
            delete scope;
            count = count + scope.size();
        }
        Catch(exception e)
        {
            Util_PLR.logerror(e,auditLog);
            system.abortJob(BC.getJobId());
        }
    }
    
    global void finish(Database.BatchableContext BC){
        Util_PLR.logSuccess(auditLog,count) ;
        
    }
}