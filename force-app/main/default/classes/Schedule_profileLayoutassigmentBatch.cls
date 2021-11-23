global class Schedule_profileLayoutassigmentBatch implements Schedulable {
    
 
    global void execute(SchedulableContext SC) {
        profileLayoutassigmentBatch btPlayout = new profileLayoutassigmentBatch();
        database.executebatch(btPlayout,2);
        
    }
}