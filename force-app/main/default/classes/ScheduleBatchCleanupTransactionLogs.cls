/*****************************************************************************************************************
Sr.No.      Author              Date            Sprint          Story Number    Description
1           Aditya              30/08/2021       21.11           DIGI-3162      Delete last 7 days TransactionLogs 
*******************************************************************************************************************/
public class ScheduleBatchCleanupTransactionLogs implements System.Schedulable, Database.Batchable<sObject>{
    public ScheduleBatchCleanupTransactionLogs(){}
     static Date today6 = Date.today().addDays(-6);

    public Database.QueryLocator start(Database.BatchableContext BC){
    return Database.getQueryLocator('Select ID from Transaction_Log__c where CreatedDate < :today6');
    }
    
    public void execute(Database.BatchableContext BC,List<Transaction_Log__c> records){
        delete records;
    }
    
    public void execute(SchedulableContext ctx) 
    {
    
        Database.executeBatch(new ScheduleBatchCleanupTransactionLogs());
   
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
}