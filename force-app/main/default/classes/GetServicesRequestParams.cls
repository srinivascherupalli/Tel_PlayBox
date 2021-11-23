public with sharing class GetServicesRequestParams {
	public GetServicesRequestParams(String subscriptionId) {
		this.subscriptionId = subscriptionId;
	}
	
	public String subscriptionId { get; set; }
}