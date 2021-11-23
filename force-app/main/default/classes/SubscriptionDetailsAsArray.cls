/******************************************************************
EDGE          -149915
Class         -SubscriptionDetailsAsArray
Description   -Subscription API v2 to support duplicate number/subscription records
Author        -Dheeraj Bhatt
*******************************************************************/
@RestResource(urlMapping='/v2/subscription-details/*') 
global with sharing class SubscriptionDetailsAsArray {
    @HttpGet 
    global static void getSubscriptionDetails(){ 
        RestRequest req = RestContext.request; 
        String correlationID = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        RestResponse res = GetSubscriptionHandler.generateResponseForArray(RestContext.response,correlationID); 
    } 
}