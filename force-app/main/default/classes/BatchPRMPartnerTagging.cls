/* EDGE-84585, Bulk Tag Utility - To Update the product configuration attributes and execute the Sync logic to ensure the Opportunity is synced with updated data*/

global with sharing class BatchPRMPartnerTagging implements Database.batchable<sObject>, Database.Stateful
{
    /*
@name ReadEventLogBatch
@CreateDate 07/25/2016
@Description Batch to read different event log data from EvenetLogFile object and load into custom object Event_Log__c
*/  
    //This is the variable to store event log csv file as string
    public Set<String> opportunityIds; 
    public String sQuery; 
    public String m_csvFile; 
    //This variable to store event type for log file
    private String m_eventType;
    Integer logcount ;
    Boolean issuccess;
    PLRAudit_log__c auditLog;
    Map<String,Map<String,String>> mapBulkLoadData = new Map<String,Map<String,String>>();
    
    public BatchPRMPartnerTagging(String sQuery,Map<String,Map<String,String>> mapBulkLoadData) {
        //this.m_csvFile = m_csvFile;
        this.sQuery = sQuery;
        this.mapBulkLoadData = mapBulkLoadData;

        System.debug('CSVFile: ' + sQuery);
    }
    
global Database.QueryLocator start(Database.batchableContext batchableContext) {


        string batchid=String.valueOf(batchableContext.getJobId()).substring(0, 15);
        PartnerBulkLoadUtil.cleanup(); //for cleanup of staging object records.
        PartnerBulkLoadUtil.UpdateMissingbulkstageStatus(batchid,mapBulkLoadData); //to update the Bulk Staging records status if the corresponding Opportunityid,Product basket is missing
        PartnerBulkLoadUtil.UpdateOldRecStatusAsArchived();
        logcount = 0;
        set<string> oppids=mapBulkLoadData.keyset();
        System.debug('mapBulkLoadData===='+mapBulkLoadData);
        System.debug('oppids===='+oppids);
        sQuery = String.isEmpty(sQuery)
                ?'SELECT Id,cscfga__Opportunity__r.Opportunity_Number__c FROM cscfga__Product_Basket__c  WHERE cscfga__Opportunity__r.Opportunity_Number__c in:oppids AND Primary_Basket__c=true'
                :sQuery;
                System.debug(sQuery);
        issuccess = true;
        
        // Calling CSVIterator class to read event log file line by line
        return Database.getQueryLocator(sQuery);
        //return new CSVIterator(m_csvFile, '\r\n');
    }
    
    global void execute(Database.BatchableContext batchableContext, List<sobject> scope){
    //keep track of each partner code updates and store the data in variables to ensure each corresponding Bulk Staging Load record is updated based on business requirement
        Savepoint sp = Database.setSavepoint();
        try
        {
                string batchid=String.valueOf(batchableContext.getJobId()).substring(0, 15);
                issuccess = false;
                for(sObject eachBasket: scope){
                cscfga__Product_Basket__c  basket = (cscfga__Product_Basket__c) eachBasket;
                //eachRow=ss.split(',');
                 if(mapBulkLoadData.containsKey(basket.cscfga__Opportunity__r.Opportunity_Number__c)){
                 //To Update Partner details based on product code  
                        PartnerBulkLoadUtil.updatePartnerTags(basket.cscfga__Opportunity__r.Opportunity_Number__c,mapBulkLoadData.get(basket.cscfga__Opportunity__r.Opportunity_Number__c),batchid);
           }
            }
            //Team Hawaii
            PartnerBulkLoadUtil.shareAndUnshareOpportunityToTaggedPartner();
                        
        }
        // Logging error in case of any exception
        catch(Exception e)
        {
            System.debug('Exception: ' + e.getStackTraceString());
            Database.rollback(sp);
            issuccess = false;
            system.abortJob(batchableContext.getJobId());
        }
    }
    
    global void finish(Database.BatchableContext batchableContext) {
    
         string batchid=String.valueOf(batchableContext.getJobId()).substring(0, 15);
         PartnerBulkLoadUtil.UpdateSummaryRecFinalStatus(batchid); //update the Bulk Staging record(Summary record) final status
         PartnerBulkLoadUtil.generateOutputCSV(batchid); //generate and attach CSV file to related list
            
          
        }
        
    
    

}