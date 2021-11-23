global with sharing class ReadEventLogBatch implements Database.batchable<String>, Database.Stateful
{
/*
    @name ReadEventLogBatch
    @CreateDate 07/25/2016
    @Description Batch to read different event log data from EvenetLogFile object and load into custom object Event_Log__c
*/  

    //This is the variable to store event log csv file as string
    public String m_csvFile; 
    //This variable to store event type for log file
    private String m_eventType;
    private List<Event_log__c> lstElog;
    private List<Event_log__c> allLstElog;
    Integer logcount ;
    
    Boolean issuccess;
    PLRAudit_log__c auditLog;
    
    public ReadEventLogBatch(String eventType) {
        this.m_eventType = eventType;
        allLstElog = new List<Event_log__c>();
        
        //Retrieve Event log file for the event type
        if(Test.isRunningTest())
        {
            m_csvFile = ReadEventLogBatchTest.getreadTestData(m_eventType);
        }
        else {
            List<EventLogFile > elf = Util_PLR.getEventLog(eventType);
            If(elf.size()>0 && elf!=null )
            {
                m_csvFile = elf[0].Logfile.tostring();
            }
            else
            {
                m_csvFile = '';
            }
        }
        
        System.debug('CSVFile: ' + m_csvFile);
    }
    
    global Iterable<String> start(Database.batchableContext batchableContext) {
        //Logging batch start into PLRAudit_log__c sObject
        auditLog = Util_PLR.logbatchstart(Constants_PLR.Read_EventLog_Batch + m_eventType);
        logcount = 0;
        issuccess = true;
        // Calling CSVIterator class to read event log file line by line
        return new CSVIterator(m_csvFile, Constants_PLR.NEWLINE_CHAR);
    }
    
    global void execute(Database.BatchableContext batchableContext, List<String> scope){
        Savepoint sp = Database.setSavepoint();
        System.debug('In execute: ' + m_eventType);
        try
        {
            If(scope != null && Scope.size() >0)
            {
                lstElog = new  List<Event_log__c>();
                if(m_eventType == Constants_PLR.URI)
                {
                    //read URI event log and return List of Event_log__c records
                    lstElog = CSVReader.readURIlog(scope);
                }
                else if(m_eventType == Constants_PLR.VF_PAGE)
                {
                    //read VisualforceRequest event log and return List of Event_log__c records
                    lstElog = CSVReader.readVFlog(scope);
                }
                else if(m_eventType == Constants_PLR.UI_TRACKING)
                {
                    //read UITracking event log and return List of Event_log__c records
                    lstElog = CSVReader.readUIlog(scope);
                }
                else if(m_eventType == Constants_PLR.LIGHTNING_INTERACTION) {
                    //read LightningInteraction event log and return List of Event_log__c records
                    lstElog = CSVReader.readLightningInteractionLog(scope);
                }
                
                // upsert Event_log__c records
                System.debug('LstElog: ' + lstElog.size());
                //oslo
                if(lstElog.size()>0){
                Upsert lstElog REQUEST_ID__c ;
                }
                else system.debug('lstElog null'+lstElog.size());
                logcount = logcount + lstElog.size();
                allLstElog.addAll(lstElog);
                issuccess = true;
            }
        }
         // Logging error in case of any exception
        catch(Exception e)
        {
            System.debug('Exception: ' + e.getStackTraceString());
            Database.rollback(sp);
            Util_PLR.logerror(e,auditLog);
            issuccess = false;
            system.abortJob(batchableContext.getJobId());
        }
    }
    
    global void finish(Database.BatchableContext batchableContext) {
        If(issuccess)
        {
            //Logging success if batch runs successfully
            Util_PLR.logSuccess(auditLog,logcount) ;
            //Invoking getrecordTypeBatch to populate recordType , Layout, KeyIds to Event_Log__c records generated
            //oslo            
            if(allLstElog.size()>0){
            getrecordTypeBatch btRtype = new getrecordTypeBatch(allLstElog , m_eventType);
            database.executebatch(btRtype,50);
            }
            else system.debug('lstElog null'+allLstElog.size());
        }
        
    }
}