public with sharing class ManageBillingService {
 
    /**
    * Based on the eventAction will make a Create, Update, or Delete request
    * @params list of subscription ids
    */
    public static void buildCalloutRequest(String handlerName, List<String> subscriptionIDs, String eventAction) {
        //build the request payload based on the passed in subscription Ids         
        String queryString = ' SELECT ' + SObjectHelper.getFieldListForSOQL('csord__Subscription__c') + 
                             ' FROM csord__Subscription__c '+ 
                             ' WHERE Id IN :subscriptionIDs';
                              
        System.debug('QueryString: ' + queryString);
         
        List<csord__Subscription__c> subList = Database.query(queryString);
        //@TODO
        //Once the JSON structure of the request is known need to replace JSON2TCMCustomerDataObject with the relevent DTO class 
        JSON2TCMCustomerDataObject manageBillDTO = buildManageBillingDTO(subList, eventAction);
        String jsonStr = System.JSON.serialize(manageBillDTO);
		
		//@TODO
		//Remove this line when the JSON structure of the request is known
        jsonStr = '{ "data": "test"}';
        System.debug('jsonStr: ' + jsonStr);  
            
        callout(handlerName, subscriptionIDs, jsonStr, eventAction);
    }
     
    @Future(callout=true)
    private static void callout(String handlerName, List<String> params, String jsonString, String event) {
    	//@TODO
    	//Is this the correct token for this interface? 
    	String token = APIUtils.getToken(EnvironmentVariable.get('okapi_token_url'), event);
        System.debug('Token: ' + token);
         
        Map<String, String> headerMap = new Map<String, String>();
        headerMap.put('Content-Type', 'application/json');
        headerMap.put('Authorization', 'Bearer ' + token);
         
        IntegrationRecordHandlerUtil.callout(jsonString, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName, params, null);
    }
     
    private static JSON2TCMCustomerDataObject buildManageBillingDTO(List<csord__Subscription__c> subList, String eventAction) {
        JSON2TCMCustomerDataObject mcDTO = new JSON2TCMCustomerDataObject();
        /* Logic to build the json payload for the passed Subscription records based on the eventAction */
        //@TODO: payload generation
        return mcDTO;
    }   
}