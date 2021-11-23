public class CreateDirectorySchedulable implements Schedulable{
    public EDISDirectoryService EDISJob {get;set;}
    public CreateDirectorySchedulable(EDISDirectoryService inputJob){
        EDISJob = inputJob;
    }
 public void execute(SchedulableContext sc) {
        System.enqueueJob(EDISJob);
        // Abort the job once the job is queued
        System.abortJob(sc.getTriggerId());
    }
}