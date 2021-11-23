public class StandaloneEASTClient {
    String Certificate_name = 'SF_tb2bqa1_massl';
    String token ='';
    public void getToken(){
    Http h = new Http();
    HttpRequest req = new HttpRequest();
    
    // retrieve tokenurl from custom settings
    req.setEndpoint('https://qa.org006.nonprod-api.in.telstra.com.au/v1/oauth/token');
    
    // retrieve tokenurl from custom settings
    req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
    
    // retrieve tokenurl from custom settings
    req.setBody('client_id=' + EncodingUtil.urlEncode('4ooDWao0raAoLnfC10ON3RAdD5wyIjOz', 'UTF-8') +
                '&client_secret=' + EncodingUtil.urlEncode('2yW2V7byaft2XJZ6', 'UTF-8') +
                '&grant_type=' + EncodingUtil.urlEncode('client_credentials', 'UTF-8') +
                '&scope=' + EncodingUtil.urlEncode('ADDRESSSEARCH', 'UTF-8'));
    
    req.setMethod('POST');
    if(Certificate_name != null){
        req.setClientCertificateName(Certificate_name);
    }
    HttpResponse res = h.send(req);
    
    // parse the access token and store into the custom settings for subsequent use.
    Map<String, String> result = (Map<String, String>)JSON.deserialize(res.getBody(), Map<String, String>.class);
    token = result.get('access_token');
    
    system.debug(token);
    
    }
    
    public void getAddress(){
    String Certificate_name = 'SF_tb2bqa1_massl';
    HttpRequest request = new HttpRequest();
    
    
    String ep = 'https://qa.org006.nonprod-api.in.telstra.com.au/v3/address-search';
    //https://cb.test.dev.telstra.com/org006/qa/v2/customer-self-management/tcm/customer-accounts/10000142588?limit=50&offset=0
    request.setEndpoint(ep);
    
    
    
    request.setMethod('POST');
    
    
    if(Certificate_name != null){
        request.setClientCertificateName(Certificate_name);
    }
    //request.setBody(req);
    request.setTimeout(30000);
    
    request.setHeader('Content-Type', 'application/json');
    request.setHeader('Authorization', 'Bearer ' + token);
    //request.setHeader('Content-Length', '1024');
    
    System.debug('!@#$% Request : ' + request);
    System.debug('!@#$% ManageCustomerRequest Body : ' + request.getBody());
    
    // Send Request
    Http httpClient = new Http();
    HttpResponse resp = httpClient.send(request);
    System.debug('!@#$% ManageCustomer Response : ' + resp);
    }
    
}