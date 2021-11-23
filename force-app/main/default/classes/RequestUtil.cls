public with sharing class RequestUtil {
    public static HttpCalloutMock mock = null;
    //public static Integration_Handler__mdt preConstants;
    @testVisible static Integration_Handler__mdt preConstants { 
        get {
            if ( preConstants == null )
                preConstants = [select id, Mock_End_Point__c,End_Point__c,Client_Id__c,Client_Secret__c,oauth_Method__c from Integration_Handler__mdt where MasterLabel = 'PRE Constants' limit 1]; 
            return preConstants;
        } set; }
  
    @TestVisible public static HttpResponse sendRequest(String method, String endpoint, String payload) {
       // Query to get the PRE Constant values from Custom metadata.
      //preConstants = [select id, Mock_End_Point__c,End_Point__c,Client_Id__c,Client_Secret__c,oauth_Method__c from Integration_Handler__mdt where MasterLabel = 'PRE Constants' limit 1];
      HttpRequest request = new HttpRequest();
      system.debug('preconst'+preConstants);
      // Setting headers using shared secret strategy
      SharedSecretSignService svc = new SharedSecretSignService();
      request = svc.getHeadersSharedSecret(request, method, endpoint, payload,preConstants );
        
      // Setting header using rsa signing strategy
      // RSASignService rsasvc = new RSASignService();
      // request = rsasvc.getHeadersRsa(request, method, endpoint, payload);
  
      request.setMethod(method);
      request.setEndpoint(preConstants.End_Point__c+ endpoint);
      request.setTimeout(60000); //increasing default timeout from 10s to 60s to give more time for large pricing service requests
      if (payload != null && payload != '') {
        request.setBody(payload);
      }
  //if (Test.isRunningTest() && (mock!=null)) {
   //           return null;
    //      } 
    //      else {
    system.debug('PRE Request: '+request);
        system.debug('Pre values from Metadata -> '+preConstants);
              Http h = new Http();
              return h.send(request);
          //}
    
    }
  }