global class CS_BasketSnapshotCleanupBatch implements Database.Batchable<sObject>
{
    private Set<Id> pbSet;
    private String usedSnapshotObject;
    private DateTime dt;
    public CS_BasketSnapshotCleanupBatch(Set<Id> pbSetParam, String usedSnapshotObjectParam, DateTime dtParam) {
        pbSet = pbSetParam;
        usedSnapshotObject = usedSnapshotObjectParam;
        dt = dtParam;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('SELECT Id FROM '+usedSnapshotObject.replace('[','').replace(']','')+' WHERE Product_Basket__c IN :pbSet and CreatedDate < :dt');
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        delete scope;
    }
    
    global void finish(Database.BatchableContext BC){
    }
}