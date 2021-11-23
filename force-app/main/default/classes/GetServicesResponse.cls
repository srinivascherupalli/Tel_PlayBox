global with sharing class GetServicesResponse extends OnlineOrderingResponse {
	
    public GetServicesResponse(String errCode, String errMsg) {
    	this.code = errCode;
    	this.message = errMsg;
    	this.isError = true;
    }
    
    public List<CS_SubscriptionDataMapper.Service> services { get; set; }

    public GetServicesResponse() {
    	this.isError = false;
    }
    
    public String SubscriptionNumber { get; set; }
    public String SubscriptionName { get; set; }
    public Decimal TotalRecurringCharges { get; set; }

}