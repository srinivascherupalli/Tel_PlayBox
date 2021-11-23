public class CreateMSISDNSchedulable implements Schedulable{
    public ReactivateMSISDNService MSISDNJob {get;set;}
    public CreateMSISDNSchedulable(ReactivateMSISDNService inputJob){
        MSISDNJob = inputJob;
    }
 public void execute(SchedulableContext sc) {System.enqueueJob(MSISDNJob);System.abortJob(sc.getTriggerId());
    }
}