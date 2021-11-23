/*
    AUTHOR : Kai Wang    
    DESCRIPTION : This class is used to callout the external interfaces
*/

public class TCMApiHelper {

    public static final String Certificate_name = EnvironmentVariable.get('certificate_name');
    
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
        
        //Chained continuation
        String url = EnvironmentVariable.get(endPoint) + params;
        
        System.debug('!@#$% Invoking URL : ' + url);
        HttpResponse resp = callout(url, token);
        
        return resp;
    }
    
    public static String handleTokenResponse(HttpResponse res, String endPoint, String params) {
        // parse the access token and store into the custom settings for subsequent use.
        Map<String, String> result = (Map<String, String>)JSON.deserialize(res.getBody(), Map<String, String>.class);
        String token = result.get('access_token');
        
        //Chained continuation
        String url = EnvironmentVariable.get(endPoint) + params;
        
        System.debug('!@#$% Invoking URL : ' + url);
        HttpResponse resp = callout(url, token);
        
        return resp.getBody();
    }
   
    public static HttpResponse tcmCallout(String url, String token){
        Http httpObj = null;
        HttpRequest httpReq = null;
        HttpResponse httpRes = null;
		//Logger2 logger = Logger2.getLogger('TCMInterface');
        try{
            httpObj = new Http();
            httpReq = new HttpRequest();
            httpReq.setEndpoint(url);
            httpReq.setMethod('GET');
            httpReq.setTimeout(120000);
            if(Certificate_name != null){
                httpReq.setClientCertificateName(Certificate_name);
            }
            httpReq.setHeader('Authorization', 'Bearer ' + token);
            httpReq.setHeader('Content-Type', 'application/json');
            httpRes = httpObj.send(httpReq);
            if(httpRes.getStatusCode() == 200){
                //logger.logMessages(httpReq.getBody(), httpRes.getBody(), '', '', '', '', false, false);
            } else {
                //logger.logMessages(httpReq.getBody(), httpRes.getBody(), '', '', httpRes.getStatus()+' : '+httpRes.getStatusCode(), '', false, false);
            }
        } catch(Exception e){
            //logger.logMessages(httpReq.getBody(), httpRes.getBody(), e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
        } finally {
            //logger.exitLogger();
        }
        return httpRes;
    }
    
    public static HttpResponse callout(String url, String token) {
    
        System.debug('!@#$% Method entry - callout');
        System.debug('!@#$% @param url : ' + url);
        System.debug('!@#$% @param token : ' + token);
        set<String> errorcodes =  new set<String>{'WS0001','WS0002','FUNC-MAP-0003','FUNC-MAP-0002','FUNC-DAT-0111','GEN-0001'};
        
        Logger2 logger = Logger2.getLogger('TCMInterface');
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        // Set endpoint & method
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setTimeout(120000);
        //Set Certificate
         if(Certificate_name != null){
          req.setClientCertificateName(Certificate_name);
        }
        // Set headers
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setHeader('Content-Type', 'application/json');
       
        System.debug('!@#$% Request : ' + req);
        System.debug('!@#$% Request Header ## Authorization : ' + req.getHeader('Authorization'));
        System.debug('!@#$% Request Header ## Content-Type : ' + req.getHeader('Content-Type'));
        
        try{
            res = h.send(req);

            System.debug('!@#$% Response : ' + res);
            System.debug('!@#$% Response Body : ' + res.getBody());
            
            if(res.getStatusCode() == 200){
                logger.logMessages(req.getBody(), res.getBody(), '', '', '', '', false, false);
            } else {
                logger.logMessages(req.getBody(), res.getBody(), '', '', res.getStatus()+': '+res.getStatusCode(), '', false, false);
            }

            if(res.getStatusCode() == 401) {
                token = TCMApiHelper.getToken();
                req.setHeader('Authorization', 'Bearer ' + token);
                res = h.send(req);
                if(token != null && token != '') {
                    EnvironmentVariable.put('tcm_access_token', token);
                }
                if(res.getStatusCode() == 200){
                    logger.logMessages(req.getBody(), res.getBody(), '', '', '', '', false, false);
            
                } else{
                    logger.logMessages(req.getBody(), res.getBody(), '', '', res.getStatus()+': '+res.getStatusCode(), '', false, false);
                }
            }
            
            System.debug(res.getStatusCode());
            String errorCode = res.getBody();
            
            JSON2TCMCustomerContactObject.ErrorMessage errorcodeobj = (JSON2TCMCustomerContactObject.ErrorMessage)JSON.deserialize(errorCode, JSON2TCMCustomerContactObject.ErrorMessage.class);    
            
            system.debug('errorcodeobj=='+errorcodeobj);
            
            if(errorcodeobj != null){
                if(errorcodes.contains(errorcodeobj.code)){
                    Exception__c e = new Exception__c();
                    e.Status__c = 'Unresolved';
                    e.Fault_Code__c = errorcodeobj.code;
                    e.Fault_String__c = errorcodeobj.message;
                    e.Fault_String__c = errorcodeobj.message;
                    e.Fault_Actor__c = 'TCMCustomerSearch';
                    insert e;
                }
            } 
        } catch (Exception e){
            logger.logMessages(req.getBody(), res.getBody(), e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();
        }
        logger.exitLogger();
        return res;
    }
    
    public static String getEASTToken() {
        return getScopedAccessToken('ADDRESSSEARCH');
    }
    
    public static String getTCMToken() {
        String scope = EnvironmentVariable.get('tcm_scope');
        return getScopedAccessToken((scope != null && String.isNotBlank(scope)) ? scope : 'TCMCUSTOMER');
    }
    
    public static String getTCMContactToken() {    
        String scope = EnvironmentVariable.get('tcm_contact_scope');
        return getScopedAccessToken((scope != null && String.isNotBlank(scope)) ? scope : 'TCMCONTACT');
    }

    private static String getScopedAccessToken(String scope) {
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
        HttpResponse res = h.send(req);
        
        // parse the access token and store into the custom settings for subsequent use.
        Map<String, String> result = (Map<String, String>)JSON.deserialize(res.getBody(), Map<String, String>.class);
        String token = result.get('access_token');
        
        return token;    
    }

}