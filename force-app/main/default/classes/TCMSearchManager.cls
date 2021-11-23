public with sharing class TCMSearchManager {
    
    public static final String Certificate_name = EnvironmentVariable.get('certificate_name');

	public TCMSearchManager() {

	}

	public static String getToken() {

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        Interface_Activation__c iActivation = Interface_Activation__c.getValues('OKAPI2');
        // retrieve tokenurl from custom settings
        req.setEndpoint(EnvironmentVariable.get('tcm_tokenUrl'));
        
        // retrieve tokenurl from custom settings
        req.setHeader('Content-Type', EnvironmentVariable.get('tcm_content-type'));
        
        // retrieve tokenurl from custom settings
        req.setBody('client_id=' + EncodingUtil.urlEncode(EnvironmentVariable.get('tcm_client_id'), 'UTF-8') +
                    '&client_secret=' + EncodingUtil.urlEncode(EnvironmentVariable.get('tcm_client_secret'), 'UTF-8') +
                    '&grant_type=' + EncodingUtil.urlEncode(EnvironmentVariable.get('tcm_grant_type'), 'UTF-8') +
                    '&scope=' + EncodingUtil.urlEncode(EnvironmentVariable.get('tcm_scope'), 'UTF-8'));
		if(Certificate_name != null && iActivation != null && iActivation.Status__c){
          req.setClientCertificateName(Certificate_name);
        }   
        req.setMethod('POST');

        HttpResponse res = h.send(req);
        
        // parse the access token and store into the custom settings for subsequent use.
        Map<String, String> result = (Map<String, String>)JSON.deserialize(res.getBody(), Map<String, String>.class);
        system.debug('token ---- ' + res.getBody());
        String token = result.get('access_token');
        
        return token;
    }

	public static HttpRequest getTokenRequest(String scope) {

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        Interface_Activation__c iActivation = Interface_Activation__c.getValues('OKAPI2');
        // retrieve tokenurl from custom settings
        req.setEndpoint(EnvironmentVariable.get('tcm_tokenUrl'));
        
        // retrieve tokenurl from custom settings
        req.setHeader('Content-Type', EnvironmentVariable.get('tcm_content-type'));
        
        // retrieve tokenurl from custom settings
        req.setBody('client_id=' + EncodingUtil.urlEncode(EnvironmentVariable.get('tcm_client_id'), 'UTF-8') +
                    '&client_secret=' + EncodingUtil.urlEncode(EnvironmentVariable.get('tcm_client_secret'), 'UTF-8') +
                    '&grant_type=' + EncodingUtil.urlEncode(EnvironmentVariable.get('tcm_grant_type'), 'UTF-8') +
                    '&scope='+scope);
		if(Certificate_name != null && iActivation != null && iActivation.Status__c){
          req.setClientCertificateName(Certificate_name);
        }            
        req.setMethod('POST');
        
        return req;
    }

	public static HttpResponse handleResponse(HttpResponse res, String endpoint, String params) {
    
        System.debug('!@#$% Method entry - handleResponse');
        System.debug('!@#$% @param res : ' + res);
        System.debug('!@#$% Response Body : ' + res.getBody());
        System.debug('!@#$% @param endpoint : ' + endpoint);
        System.debug('!@#$% @param params : ' + params);
    
        // parse the access token and store into the custom settings for subsequent use.
        Map<String, String> result = (Map<String, String>)JSON.deserialize(res.getBody(), Map<String, String>.class);
        String token = result.get('access_token');
        System.debug('!@#$% Access Token for this session : ' + token);
        
        /*
        String url = EnvironmentVariable.get('baseUrl');
        if(params.size()>0){
            url = url + '/customer-accounts';
            
            if(!params.containsKey('masterId')){
                url = url + '?';
            }
            for(Integer i=0; i<params.values().size(); i++){
                url = url + params.values()[i];    
            }
        }
        */
        
        //Chained continuation
        String url = EnvironmentVariable.get(endPoint) + params;
        
        System.debug('!@#$% Invoking URL : ' + url);
        HttpResponse resp = TCMSearchService.callout(url, token);
        
        return resp;
    }
    
    public static String handleTokenResponse(HttpResponse res, String endPoint, String params) {

        // parse the access token and store into the custom settings for subsequent use.
        Map<String, String> result = (Map<String, String>)JSON.deserialize(res.getBody(), Map<String, String>.class);
        String token = result.get('access_token');
        
        //Chained continuation
        String url = EnvironmentVariable.get(endPoint) + params;
        
        System.debug('!@#$% Invoking URL : ' + url);
        HttpResponse resp = TCMSearchService.callout(url, token);
        
        return resp.getBody();
    }
    
    public static String getTCMToken() {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        Interface_Activation__c iActivation = Interface_Activation__c.getValues('OKAPI2');
        // retrieve tokenurl from custom settings
        req.setEndpoint(EnvironmentVariable.get('tcm_tokenUrl'));
        
        // retrieve tokenurl from custom settings
        req.setHeader('Content-Type', EnvironmentVariable.get('tcm_content-type'));
        
        // retrieve tokenurl from custom settings
        req.setBody('client_id=' + EncodingUtil.urlEncode(EnvironmentVariable.get('tcm_client_id'), 'UTF-8') +
                    '&client_secret=' + EncodingUtil.urlEncode(EnvironmentVariable.get('tcm_client_secret'), 'UTF-8') +
                    '&grant_type=' + EncodingUtil.urlEncode(EnvironmentVariable.get('tcm_grant_type'), 'UTF-8') +
                    '&scope=' + EncodingUtil.urlEncode(EnvironmentVariable.get('tcm_scope'), 'UTF-8'));
        if(Certificate_name != null && iActivation != null && iActivation.Status__c){
          req.setClientCertificateName(Certificate_name);
        }                    
        req.setMethod('POST');
        HttpResponse res = h.send(req);
        
        // parse the access token and store into the custom settings for subsequent use.
        Map<String, String> result = (Map<String, String>)JSON.deserialize(res.getBody(), Map<String, String>.class);
        String token = result.get('access_token');
        return token;
    }
    
    public static String getTCMContactToken() {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        Interface_Activation__c iActivation = Interface_Activation__c.getValues('OKAPI2');
        // retrieve tokenurl from custom settings
        req.setEndpoint(EnvironmentVariable.get('tcm_tokenUrl'));
        
        // retrieve tokenurl from custom settings
        req.setHeader('Content-Type', EnvironmentVariable.get('tcm_content-type'));
        
        // retrieve tokenurl from custom settings
        req.setBody('client_id=' + EncodingUtil.urlEncode(EnvironmentVariable.get('tcm_client_id'), 'UTF-8') +
                    '&client_secret=' + EncodingUtil.urlEncode(EnvironmentVariable.get('tcm_client_secret'), 'UTF-8') +
                    '&grant_type=' + EncodingUtil.urlEncode(EnvironmentVariable.get('tcm_grant_type'), 'UTF-8') +
                    '&scope=' + EncodingUtil.urlEncode(EnvironmentVariable.get('tcm_contact_scope'), 'UTF-8'));
        if(Certificate_name != null && iActivation != null && iActivation.Status__c){
          req.setClientCertificateName(Certificate_name);
        }                    
        req.setMethod('POST');
        HttpResponse res = h.send(req);
        
        // parse the access token and store into the custom settings for subsequent use.
        Map<String, String> result = (Map<String, String>)JSON.deserialize(res.getBody(), Map<String, String>.class);
        String token = result.get('access_token');
        
        return token;
    }


}