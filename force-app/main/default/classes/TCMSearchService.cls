/**
 * See https://github.com/financialforcedev/fflib-apex-common for more info
 *
 * Install library via
 *   https://githubsfdeploy.herokuapp.com/app/githubdeploy/financialforcedev/fflib-apex-common
 */

/**
 * Encapsulates all service layer logic for a given function or module in the application
 * 
 * For more guidelines and details see 
 *   https://developer.salesforce.com/page/Apex_Enterprise_Patterns_-_Service_Layer
 *
 **/
public with sharing class TCMSearchService
{
    public static final String Certificate_name = EnvironmentVariable.get('certificate_name');
    public static HttpResponse callout(String url, String token) {
    
        Logger2 logger = Logger2.getLogger('TCMSearchService');
        set<String> errorcodes =  new set<String>{'WS0001','WS0002','FUNC-MAP-0003','FUNC-MAP-0002','FUNC-DAT-0111','GEN-0001'};
        
        System.debug('!@#$% Method entry - callout');
        System.debug('!@#$% @param url : ' + url);
        System.debug('!@#$% @param token : ' + token);
    
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
            
            System.debug('++req=='+req.getBody());
            
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
                    e.Fault_Actor__c = 'TCMContactSearch';
                    insert e;
                }
            }
        if(!system.isBatch()){
            if(res.getStatusCode() == 200){
                    logger.logMessages(req.getEndpoint(), res.getBody(), '', '', '', '', false, false);
        
        } else {
                    logger.logMessages(req.getEndpoint() , res.getBody(), '', '', res.getStatus()+': '+res.getStatusCode(), '', false, false);
            }
        }

            System.debug('!@#$% Responsee : ' + res);
            System.debug('!@#$% Response Body : ' + res.getBody());
        }
        catch(Exception e){
            System.debug(e);
            logger.logMessages(req.getEndpoint(), res.getBody(), e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();
        }
        if(res.getStatusCode() == 401) {
            token = TCMSearchManager.getToken();
            req.setHeader('Authorization', 'Bearer ' + token);
            
            res = h.send(req);
            if(!system.isBatch()){
                if(res.getStatusCode() == 200){
                    logger.logMessages(req.getEndpoint(), res.getBody(), '', '', '', '', false, false);
        
                } else {
                    logger.logMessages(req.getEndpoint(), res.getBody(), '', '', res.getStatus()+': '+res.getStatusCode(), '', false, false);
                }
            }

            if(token != null && token != '') {
                EnvironmentVariable.put('tcm_access_token', token);
            }
        }
        logger.exitLogger();
        System.debug(res.getStatusCode());
        return res;
    }
	
	public static HttpResponse tcmCallOut(String url, String token){
		System.debug('!@#$% Method entry - tcmCallOut');
        System.debug('!@#$% @param url : ' + url);
        System.debug('!@#$% @param token : ' + token);
        Http httpObj = new Http();
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        httpReq.setEndpoint(url);
        httpReq.setMethod('GET');
        httpReq.setTimeout(120000);
        if(Certificate_name != null) httpReq.setClientCertificateName(Certificate_name);
        httpReq.setHeader('Authorization', 'Bearer ' + token);
        httpReq.setHeader('Content-Type', 'application/json');
		System.debug('!@#$% Request : ' + httpReq);
        System.debug('!@#$% Request Header ## Authorization : ' + httpReq.getHeader('Authorization'));
        System.debug('!@#$% Request Header ## Content-Type : ' + httpReq.getHeader('Content-Type'));
        httpRes = httpObj.send(httpReq);
        System.debug('!@#$% Response : ' + httpRes);
        System.debug('!@#$% Response Body : ' + httpRes.getBody());
        return httpRes;
    }
	
}