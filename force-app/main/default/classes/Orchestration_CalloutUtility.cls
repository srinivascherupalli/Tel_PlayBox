/**================================================================
 * Appirio, Inc
 * Name: Orchestration_CalloutUtility
 * Description: Class contains utility method to make callouts from orchestration step handlers
 * Created Date: June 17, 2020
 * Created By: Ashish Agarwal
 ==================================================================*/
public with sharing class Orchestration_CalloutUtility {
    private static final String CLIENT_ID = 'client_id';
    private static final String CLIENT_SECRET = 'client_secret';
    private static final String GRANT_TYPE = 'grant_type';
    private static final String SCOPE = 'scope';
    private static final String ACCESS_TOKEN = 'access_token';
    public static final String HTTP_METHOD_GET = 'GET';
    public static final String HTTP_METHOD_POST = 'POST';

    private Boolean exceptionInCallOut = false;
    
    /***********
    Util method for genrating oAuthToken for the specified handler record in IntegrationHandler metadata
    ***********/
    public static String getOauthToken(Integration_Handler__mdt integrationHandlerRecord) {
        String retVal;
        String handlerName = integrationHandlerRecord.DeveloperName;
        String token = AuthenticationService.retrieveToken(handlerName);
        if (String.isEmpty(token)) {
            token = getNewOauthToken(integrationHandlerRecord);
        }

        if (!String.isEmpty(token)) {
            retVal = token;
        }
        return retVal;
    }

    public static String getNewOauthToken(Integration_Handler__mdt integrationHandlerRecord) {
        String retVal;
        String handlerName = integrationHandlerRecord.DeveloperName;
        String envExpiryTime = EnvironmentVariable.get('PlatformCache_Expiry_Time');
        Integer expiryTime = (envExpiryTime != null && envExpiryTime != '') ? integer.valueof(envExpiryTime) : Cache.Org.MAX_TTL_SECS;

        String token = getToken(integrationHandlerRecord);
        if (!String.isEmpty(token) && !integrationHandlerRecord.Enable_Mock_Integration__c) {
            AuthenticationService.storeToken(handlerName, token, expiryTime);
        }
        return token;
    }

    public static String getToken(Integration_Handler__mdt integrationHandlerRecord) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        if (integrationHandlerRecord != null) {
            // Set Endpoint
            if (integrationHandlerRecord.Enable_Mock_Integration__c) {
                req.setEndpoint(integrationHandlerRecord.Oauth_Mock_Endpint__c);
            } else {
                req.setEndpoint(integrationHandlerRecord.Auth_End_Point__c);
            }
            // Set Method
            req.setMethod(HTTP_METHOD_POST);
            // Set Body
            String body = '';
            String cId = integrationHandlerRecord.Client_Id__c;
            String cSecret = integrationHandlerRecord.Client_Secret__c;
            String gType = integrationHandlerRecord.Grant_Type__c;
            String scp = integrationHandlerRecord.Scope__c;
            if (!String.isBlank(cId)) {
                body = body + CLIENT_ID + '=' + cId + '&';
            }
            if (!String.isBlank(cSecret)) {
                body = body + CLIENT_SECRET + '=' + cSecret + '&';
            }
            if (!String.isBlank(gType)) {
                body = body + GRANT_TYPE + '=' + gType + '&';
            }
            if (!String.isBlank(scp)) {
                body = body + SCOPE + '=' + scp;
            }
            if (!String.isBlank(body)) {
                req.setBody(body);
            }
            if (integrationHandlerRecord.enable_massl__c) {
                System.debug('MASSL is enabled for interface');
                String certificate_name = EnvironmentVariable.get('massl_certificate_name');
                if (certificate_name != null) {
                    req.setClientCertificateName(certificate_name);
                }
            }
        }
        // Callout to oAuth generating hosted service
        String token = '';
        try {
            HttpResponse res = http.send(req);
            Map<String, String> result = (Map<String, String>) JSON.deserialize(res.getBody(), Map<String, String>.class);
            token = result.get(ACCESS_TOKEN);
        } catch (Exception e) {
            return null;
        }
        return token;
    }
    /**
	Method for http callouts using integration handler metadata records
	**/
    public static HTTPResponse sendRequestGeneric(String requestBody, String method, Map<String, String> headerMap, Integration_Handler__mdt integrationHandlerRecord, Map<String,String> pathMap) {
        String endPoint = null;
        if (integrationHandlerRecord != null) {
            if (integrationHandlerRecord.Enable_Mock_Integration__c) {
                endPoint = integrationHandlerRecord.Mock_End_Point__c != null ? integrationHandlerRecord.Mock_End_Point__c : '';
            } else {
                endPoint = integrationHandlerRecord.End_Point__c != null ? integrationHandlerRecord.End_Point__c : '';
            }
        }
        
        Integer timeout = integrationHandlerRecord != null && integrationHandlerRecord.Timeout__c != null ? integrationHandlerRecord.Timeout__c.intValue() : Integer.valueOf(Label.INT_MAX_TIMEOUT);
        if (String.isBlank(endPoint)) {
            return null;
        }
        if(pathMap != null && !pathMap.isEmpty()){
            for(String path : pathMap.keySet()){

                if(pathMap.get(path) != null) {
                    endPoint += '/' + path + '/' + pathMap.get(path);
                }
            }
        }
        HttpRequest req = new HttpRequest();
        if (method == HTTP_METHOD_GET) {
            if (integrationHandlerRecord.Append_URL_Params_without_question_mark__c) {
                req.setEndpoint(endPoint + '/' + requestBody);
            } else {
                req.setEndpoint(endPoint + '?' + requestBody);
            }
        } else {
            req.setEndpoint(endPoint);
            req.setBody(requestBody);
        }
        if (integrationHandlerRecord.Enable_MASSL__c) {
            System.debug('MASSL is enabled for interface');
            String certificateName = EnvironmentVariable.get('massl_certificate_name');
            if (certificateName != null) {
                req.setClientCertificateName(certificateName);
            }
        }
        req.setMethod(method);
        req.setTimeout(timeout);
        if (headerMap != null) {
            for (String hdName : headerMap.keySet()) {

                if(headerMap.get(hdName) != null) {
                    
                    req.setHeader(hdName, headerMap.get(hdName));
                }
            }
        }
        Http http = new Http();
        //HTTPResponse res = http.send(req);
        return http.send(req);
    }
    
    public static Long getRequestTimeDifference(DateTime startTime, DateTime endTime){
        Long dt1Long = startTime.getTime();
        Long dt2Long = endTime.getTime();
        Long milliseconds = dt2Long - dt1Long;
        Long seconds = milliseconds / 1000;
        Long minutes = seconds / 60;
        Long hours = minutes / 60;
        Long days = hours / 24;
        
        return milliseconds;//hours+':'+minutes+':'+seconds;
    }
    
}