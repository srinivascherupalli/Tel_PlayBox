global Without Sharing class BatchUpdateProgramRecordsSchedulable implements Schedulable {
    global void execute(SchedulableContext ctx) {
        system.debug('-----BatchUpdateProgramRecordsSchedulable---------');
        BatchUpdateProgramRecords batchUpdate = new BatchUpdateProgramRecords();
        Database.executeBatch(batchUpdate);
     }   
}