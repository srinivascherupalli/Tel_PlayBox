global with sharing class updatePORstatusBatch implements Database.Batchable<sObject>,Schedulable {
    public static boolean isBatchOppAssignment=false;
    //String strEndDays = '1';
    DateTime dt = System.today();
    String dtFormatted = dt.format('YYYY-MM-dd');
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String soql = 'SELECT id,name,Status__c,Customer__c,createddate  FROM Partner_of_Record__c WHERE end_Date__c <'+dtFormatted;
        return Database.getQueryLocator(soql);
    }
    global void execute(Database.BatchableContext bc, List<Partner_of_Record__c> recs) {
        isBatchOppAssignment=true;
        try{
            list<Partner_of_Record__c> PORupdate = new list<Partner_of_Record__c>();
            list<string> successIds = new List<String>();
            list<string> Ids = new List<String>();
            if(!recs.isEmpty()){
                for(Partner_of_Record__c por : recs){
                    por.Status__c = 'Expired';
                    Ids.add(por.Customer__c);
                    PORupdate.add(por);
                }
            }
            if(!PORupdate.isEmpty()){
                update PORupdate;
            }
            if(!Ids.isEmpty()){
                list<Opportunity> updateOpp = new List<Opportunity>();
                list<Opportunity> oppList = [select id,isPOROpportunity__c,StageName from Opportunity where accountId in:Ids and (StageName = 'Cancelled' or StageName = 'Closed Lost')]; 
                for(Opportunity opp : oppList){
                    opp.isPOROpportunity__c = false;
                    updateOpp.add(opp);
                }
                if(!updateOpp.isEmpty()){
                    update updateOpp;
                }
                
            }
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    global void finish(Database.BatchableContext bc) { 
        PORChatterRemainder_Batch chatterPost = new PORChatterRemainder_Batch();
        Database.executeBatch(chatterPost,70);
    }
    global void execute(SchedulableContext sc) {
        updatePORstatusBatch runBatch = new updatePORstatusBatch();
        //String sch = '0 30 23 ? * * *';
        //system.schedule(runBatch, sch, job);
        Database.executeBatch(runBatch, 70);
    }
}