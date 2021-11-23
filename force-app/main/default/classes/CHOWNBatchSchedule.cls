public class CHOWNBatchSchedule implements Schedulable{
    public void execute(SchedulableContext sc) {
        //invoke the batch class
        Database.executeBatch(new CHOWNChatterPost());
       
    }
}