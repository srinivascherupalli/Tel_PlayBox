public class RunTerritoryRulesMock implements HttpCalloutMock {

    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.debug('*********Territory Http Callout Mock Called');
        //System.assertEquals(System.URL.getSalesforceBaseUrl().toExternalForm()+'/services/Soap/u/41.0/'+UserInfo.getOrganizationId(), req.getEndpoint());
        //System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
    //    res.setHeader('Content-Type', 'application/json');
  	//    res.setBody('{"foo":"bar"}');
  	    res.setBody('Territory Rules have been triggered');
        System.debug('**********Response body has been set');
        res.setStatusCode(200);
        return res;
    }
}