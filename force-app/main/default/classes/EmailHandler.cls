public class EmailHandler extends IntegrationQueueHandler {
    
    public EmailHandler() {
        super(EmailHandler.class.getName());
    }
     
    /*
    *    The params will be a list of subscription Ids related to Services that needs to be 
    *    Created in Flexcab
    */
    public override void executeWork(List<String> params) {
        EmailService.sendEmail(params.get(0));
    }

}