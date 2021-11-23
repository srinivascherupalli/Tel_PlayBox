public with sharing class ManageOrderSumbitHandler  extends IntegrationQueueHandler {
	public ManageOrderSumbitHandler () {
		super(ManageOrderSumbitHandler.class.getName());
	}


	/*
    *    The params will be a list of order Ids that needs to be sent to fulfilment application
    */
	public override void executeWork( List<String> params) {
		ManageOrderService.sendOrder(params);
	}
}