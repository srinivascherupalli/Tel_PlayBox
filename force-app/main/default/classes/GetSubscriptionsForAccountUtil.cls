public with sharing class GetSubscriptionsForAccountUtil {
	
	public static GetSubscriptionsResponse getSubscriptions(String accountId) {
		GetSubscriptionsResponse retval = new GetSubscriptionsResponse();

		try {
			 /***
            * @modifiedby   - Ramesh Somalagari
            * @team         - OSAKA
            * @jirastoryRef - EDGE-106634
            * @description  - Method 'getSubscriptions' parameter is changed to Label_IPSite instead of Label_CWP.
            ***/
            //START :Changes for EDGE-106634 
			retval.subscriptions = CS_SubscriptionDataMapper.getSubscriptions(accountId,System.label.Label_IPSite,System.label.Active_Status);
            //END :Changes for EDGE-106634
		} catch (Exception ex) {
			throw new GetSubscriptionsForAccountException(ex.getMessage(), ex);
		}
		return retval;
	}
    
    public static GetSubscriptionsResponse genErrorResponse(String errCode) {
    	return new GetSubscriptionsResponse(APIConstants.AUTHORIZE_CONTACT_STATUS.INVALID, errCode);
    }
    
    public static GetSubscriptionsResponse genErrorResponse(String errCode, String errMsg) {
    	return new GetSubscriptionsResponse(APIConstants.AUTHORIZE_CONTACT_STATUS.INVALID, errCode, errMsg);
    }
    //START :Changes for EDGE-106634 
    @testVisible
    //END :Changes for EDGE-106634 
    private static void removeAttributes(Map<String,Object> jsonObj)  {
	    for(String key : jsonObj.keySet()) {
	        if('attributes' == key) {
	            jsonObj.remove(key);
	        } else {
	            if(jsonObj.get(key) instanceof Map<String,Object>) {
	                removeAttributes((Map<String,Object>)jsonObj.get(key));
	            } else if(jsonObj.get(key) instanceof List<Object>) {
	                for(Object listItem : (List<Object>)jsonObj.get(key)) {
	                    if(listItem instanceof Map<String,Object>)  {
	                        removeAttributes((Map<String,Object>)listItem);
	                    }
	                }
	            }
	        }
	    }
    }
}