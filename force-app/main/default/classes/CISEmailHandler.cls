public class CISEmailHandler extends IntegrationQueueHandler {
    
    public CISEmailHandler() {
        super(CISEmailHandler.class.getName());
    }
     
    /*
    *    The params will be a list of subscription Ids related to Services that needs to be 
    *    Created in Flexcab
    */
    public override void executeWork(List<String> params) {
        CISEmailService.sendEmail(params.get(0));
    }

}