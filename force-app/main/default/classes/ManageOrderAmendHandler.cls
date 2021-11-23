/*
*	This need to be removed as part of 1710 NFB-4098
*/
@isTest
public class ManageOrderAmendHandler extends IntegrationQueueHandler {    
	public ManageOrderAmendHandler() {
        super(ManageOrderAmendHandler.class.getName());
    }
    
    public override void executeWork(List<String> params) {
        //ManageOrderService.send(ManageOrderAmendHandler.class.getName(), params, 'AMEND');
    }    
}