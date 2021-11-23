global class Schedule_deleteEventLogBatch implements Schedulable {

    global void execute(SchedulableContext SC) {
        
        deleteEventLogBatch btDel = new deleteEventLogBatch();
        database.executebatch(btDel,1000);
        
    }
}