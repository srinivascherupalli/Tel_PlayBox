public class ManageBillingCreateHandler extends IntegrationQueueHandler {       
     
    public ManageBillingCreateHandler() {
        super(ManageBillingCreateHandler.class.getName());
    }
     
    /*
    *    The params will be a list of subscription Ids related to Services that needs to be 
    *    Created in Flexcab
    */
    public override void executeWork(List<String> params) {
        BillingAccountManager.createBillingService(ManageBillingCreateHandler.class.getName(), params);
    }
}