public with sharing class APIHandlerFactory {
	
	public static APIHandler getHandler(String api) {
		APIHandler handler;
		
		switch on api {
			when 'AuthorizeContactForAccount' { 
				handler = (APIHandler) AuthorizeContactForAccountHandler.getInstance();
			}
			when 'GetSubscriptionsForAccount' { 
				handler = (APIHandler) GetSubscriptionsForAccountHandler.getInstance();
			}
			when 'GetServicesForSubscription' {
				handler = (APIHandler) GetServicesForSubscriptionHandler.getInstance();
			}
			when else { 
				handler = FallbackHandler.getInstance();
			}
		}
		
		return handler;
	}
	
}