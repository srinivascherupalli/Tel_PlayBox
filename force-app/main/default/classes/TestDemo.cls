public class TestDemo{

public void testcall(){

String Certificate_name = 'SF_tb2bqa1_massl';
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
    '&scope=' + EncodingUtil.urlEncode('TCMCONTACT', 'UTF-8'));
    
req.setMethod('POST');
if(Certificate_name != null){
     req.setClientCertificateName(Certificate_name);
}
HttpResponse res = h.send(req);

// parse the access token and store into the custom settings for subsequent use.
Map<String, String> result = (Map<String, String>)JSON.deserialize(res.getBody(), Map<String, String>.class);
String token = result.get('access_token');

system.debug(token);
 }
}