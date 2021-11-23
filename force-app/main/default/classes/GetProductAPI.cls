/*Story number: EDGE-865
Description: Retrieve the details for a specific product (service specifications)
*/

@RestResource(urlMapping='/v1/product-details/*')
global with sharing class GetProductAPI {
    @HttpGet 
    global static void getProductDetails() {
        
        RestRequest req = RestContext.request;
        String correlationID = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        RestResponse res = GetServSpecHandler.generateResponse(RestContext.response, correlationID);
        
        
    }   
}