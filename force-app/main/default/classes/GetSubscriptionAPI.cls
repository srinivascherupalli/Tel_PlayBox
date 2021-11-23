@RestResource(urlMapping='/v1/subscription-details/*') 
global with sharing class GetSubscriptionAPI {
    @HttpGet 
    global static void getSubscriptionDetails(){ 
        RestRequest req = RestContext.request; 
        String correlationID = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        system.debug('corrId::'+correlationID);
        RestResponse res = GetSubscriptionHandler.generateResponse(RestContext.response,correlationID); 
    } 

}