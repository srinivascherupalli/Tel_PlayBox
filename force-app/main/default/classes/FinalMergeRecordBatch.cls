global class FinalMergeRecordBatch implements Database.Batchable<SObject>,Database.AllowsCallouts,Database.Stateful {

  	Private final String Query;
    public FinalMergeRecordBatch(){
        Query = 'SELECT  Source_Id__c,Target_Id__c, Type__c,Status__c FROM Merge_Request__c  where Status__c = \'FAILED RETRY\' ';

    }
    
	global Database.queryLocator start(Database.BatchableContext ctx)
	{

        return Database.getQueryLocator(Query);
    }
    global void execute(Database.BatchableContext ctx, List<Merge_Request__c> scope){
        map<MergeRecordFactory.type, RecordMerge> mergeResult =  new map<MergeRecordFactory.type, RecordMerge>();
        mergeResult = MergeRecordFactory.getMergeRecords(scope);
        system.debug('Failed Retry records>>>'+mergeResult);
        try{
        for(MergeRecordFactory.type key : mergeResult.keySet()){
            RecordMerge instmerge = mergeResult.get(key);
            instmerge.executeMerge();
                   
        }
        
        } catch(exception ex){
            system.debug('exception Failed Retry=='+ex);
        }
        
    }
                            
                           
    global void finish(Database.BatchableContext ctx){
    }
}