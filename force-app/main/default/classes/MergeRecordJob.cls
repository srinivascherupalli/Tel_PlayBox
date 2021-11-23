global class MergeRecordJob implements Schedulable  {
    MergeRecordFactory.type type;
    public MergeRecordJob(MergeRecordFactory.type type){
        this.type = type;
    }
    public void execute(SchedulableContext sc) 
    {
       
        Database.executeBatch(new MergeRecordBatch(type), 5);
        
    }
    
  
    
}