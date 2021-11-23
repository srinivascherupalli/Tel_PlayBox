public class AsyncExecutionReplicatorGetSite implements Queueable, Database.AllowsCallouts{
	public String finCIDN;
    public String adBorID;
    public AsyncExecutionReplicatorGetSite(String finCIDN,String adBorID){
        this.finCIDN = finCIDN;
        this.adBorID = adBorID;
        //
    }
    public void execute(QueueableContext context) {
        UpdateLegacyFlagOnBasketHelper.insertLegacySiteFuture(this.finCIDN,this.adBorID);
    }
}