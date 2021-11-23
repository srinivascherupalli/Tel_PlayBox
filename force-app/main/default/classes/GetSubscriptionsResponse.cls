global with sharing class GetSubscriptionsResponse extends OnlineOrderingResponse {
	
    public GetSubscriptionsResponse(APIConstants.AUTHORIZE_CONTACT_STATUS status, String errCode) {
    	this.code = errCode;
    	this.message = GetSubscriptionsForAccountErrorCodes.getErrorMessage(errCode);
    	this.isError = true;
    	this.status = status;
    }
    
    public GetSubscriptionsResponse(APIConstants.AUTHORIZE_CONTACT_STATUS status, String errCode, String errMsg) {
    	this.code = errCode;
    	this.message = errMsg;
    	this.isError = true;
    	this.status = status;
    }
    
    public List<CS_SubscriptionDataMapper.Subscription> subscriptions { get; set; }
    
    public GetSubscriptionsResponse() {
    	this.isError = false;
    	this.status = APIConstants.AUTHORIZE_CONTACT_STATUS.VALID;
    }
    
    public APIConstants.AUTHORIZE_CONTACT_STATUS status { get; set; }

}