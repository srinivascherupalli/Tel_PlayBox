global class MergeRecordBatch implements Database.Batchable<SObject>,Database.AllowsCallouts,Database.Stateful {
	Private final String Query;
    Private String typess;
    Private String Statuss;
    public MergeRecordBatch(){
        Query = 'SELECT  Source_Id__c,Target_Id__c, Type__c,Status__c,Error_Code__c,Error_Message__c FROM Merge_Request__c  where Status__c IN ( \'PENDING\' , \'In Progress\') ';

    }
    
    public MergeRecordBatch(MergeRecordFactory.type types){
        System.debug('MergeRecordFactory.type=='+types);
        this.typess = String.valueof(types);
        Query = 'SELECT  Source_Id__c,Target_Id__c ,Type__c,Status__c,Error_Code__c,Error_Message__c FROM Merge_Request__c  where Status__c IN ( \'PENDING\' , \'In Progress\') AND Type__c =:typess';

    }
    
    public MergeRecordBatch(MergeRecordFactory.type types, String Status){
        System.debug('MergeRecordFactory.type and status');
         this.Statuss = String.valueOf(Status);
       Query = 'SELECT  Source_Id__c,Target_Id__c, Type__c,Status__c,Error_Code__c,Error_Message__c FROM Merge_Request__c  where Status__c IN ( \'PENDING\' , \'In Progress\') AND Type__c =:typess';

    }
    
    global Database.queryLocator start(Database.BatchableContext ctx){
        System.debug('Query=='+Query);
        return Database.getQueryLocator(Query);
    }
    global void execute(Database.BatchableContext ctx, List<Merge_Request__c> scope){
        list<Merge_Settings__c> mergesett =  Merge_Settings__c.getall().values();
        System.debug('mergesett++==' +mergesett);
       
        map<MergeRecordFactory.type,RecordMerge> mergeResult =  new map<MergeRecordFactory.type, RecordMerge>();
        mergeResult = MergeRecordFactory.getMergeRecords(scope);
        system.debug('test=='+mergeResult);
       try{
        for(MergeRecordFactory.type key : mergeResult.keySet()){

                system.debug('key=='+mergeResult.get(key));
                RecordMerge instmerge = mergeResult.get(key);
              
                if(instmerge instanceof CustomerMerge){
                  
					Merge_Settings__c setting =  Merge_Settings__c.getValues('AccountMerge');
                    
                    Datetime GMTDate1 = Datetime.now();
					String strConvertedDate1 = GMTDate1.format('MM/dd/yyyy','Australia/Sydney');
                    String starttime =  strConvertedDate1+' '+setting.Process_Window_Start__c ;
                    String endtime =  strConvertedDate1+' '+setting.Process_Window_End__c ;
                  
                    Datetime GMTDate = Datetime.now();
					String strConvertedDate = GMTDate.format('MM/dd/yyyy HH:mm:ss','Australia/Sydney');
                    
                    if(strConvertedDate>= starttime && strConvertedDate <=endtime){
                      system.debug('window time');
                      instmerge.executeMerge();
                    }
                    else {
                        system.debug('window end time');
                    	system.abortJob(ctx.getJobId());
                	}
                }  
                    
                if(instmerge instanceof ContactMerge){
                    Merge_Settings__c setting =  Merge_Settings__c.getValues('ContactMerge');
                    
                    Datetime GMTDate1 = Datetime.now();
					String strConvertedDate1 = GMTDate1.format('MM/dd/yyyy','Australia/Sydney');
                    String starttime =  strConvertedDate1+' '+setting.Process_Window_Start__c ;
                    String endtime =  strConvertedDate1+' '+setting.Process_Window_End__c ;
                  
                    Datetime GMTDate = Datetime.now();
					String strConvertedDate = GMTDate.format('MM/dd/yyyy HH:mm:ss','Australia/Sydney');
                    
                    if(strConvertedDate>= starttime && strConvertedDate <=endtime){
                      system.debug('window time');
                      instmerge.executeMerge();
                    }
                    else {
                        system.debug('window end time');
                    	system.abortJob(ctx.getJobId());
                	}
                }
                
                
        }
        } catch(exception ex){
            system.debug('exception=='+ex);
        }
        
    }
                            
                           
    global void finish(Database.BatchableContext ctx)
    {
     
     FinalMergeRecordBatch batch=new FinalMergeRecordBatch();
     Database.executeBatch(batch,5);
        
    }
         
}