/*
    AUTHOR : Vineeth Batreddy    
    DESCRIPTION : This class is used to fetch OAuth access token from external systems
*/

public with sharing class OauthLogin {

    public static final String SYSTEM_TCM = 'TCM';
    public static final String SYSTEM_EAST = 'EAST';
    public static final String SYSTEM_AMDOCS = 'AMDOCS';
    
    private static final String ENDPOINT = 'endpoint';
    private static final String CLIENT_ID = 'client_id';
    private static final String CLIENT_SECRET = 'client_secret';
    private static final String GRANT_TYPE = 'grant_type';
    private static final String SCOPE = 'scope';
    private static final String ENABLE_MOCKS = 'enable_mocks';
    private static final String METHOD = 'method';
    private static final String MOCK_ENDPOINT = 'mock_endpoint';
    private static final String ACCESS_TOKEN = 'access_token';
    // @author: Akshay Deuskar | Added new field to support MASSL as part of NFB:1218
    private static final String ENABLE_MASSL = 'enable_massl';

    public static String getAMDOCSToken() {
        return getToken(SYSTEM_AMDOCS);
    }

    public static Boolean isMock(String systemName) {
        
        Map<String, String> config = getConfiguration(systemName);

            if(ConversionUtils.stringtoBoolean(config.get(ENABLE_MOCKS))){
                return true;
            }else{
                return false;
            }

    }

    public static String getToken(String systemName) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        
        Map<String, String> config = getConfiguration(systemName);
        
        if(config != null) {
        	// Set Endpoint
            if(ConversionUtils.stringtoBoolean(config.get(ENABLE_MOCKS))){
                req.setEndpoint(config.get(MOCK_ENDPOINT));
            } else {
                req.setEndpoint(config.get(ENDPOINT));    
            }
            
            // Set Method
            req.setMethod(config.get(METHOD));
            
            // Set Body
            String body = '';
            String cId = config.get(CLIENT_ID);
            String cSecret = config.get(CLIENT_SECRET);
            String gType = config.get(GRANT_TYPE);
            String scp = config.get(scope);
    
            if(!String.isBlank(cId)){
                body = body+CLIENT_ID+'='+cId+'&';
            }
            if(!String.isBlank(cSecret)){
                body = body+CLIENT_SECRET+'='+cSecret+'&';
            }
            if(!String.isBlank(gType)){
                body = body+GRANT_TYPE+'='+gType+'&';
            }
            if(!String.isBlank(scp)){
                body = body+SCOPE+'='+scp;
            }
            if(!String.isBlank(body)){
                req.setBody(body);
            }    
            
            //@author Akshay Deuskar | block added to set the MASSL based on custom settings
			if(config.get(ENABLE_MASSL) != null && ConversionUtils.stringtoBoolean(config.get(ENABLE_MASSL))){
                System.debug('MASSL is enabled for interface');
                String certificate_name = EnvironmentVariable.get('massl_certificate_name');
                System.debug('Setting ' + certificate_name + ' certificate for http call');
                if(certificate_name!=null){
                	req.setClientCertificateName(certificate_name);
                }
            }
        }
        
        // Callout
        String token = '';
        try {
        	HttpResponse res = http.send(req);
            Map<String, String> result = (Map<String, String>)JSON.deserialize(res.getBody(), Map<String, String>.class);
            token = result.get(ACCESS_TOKEN);    
        }
        
        catch(Exception e) {
            
            Logger.getLogger(OauthLogin.class).debug(e);
            Logger.exitLogger();
            return null;
        }
        
        return token;
    }

    private static Map<String, String> getConfiguration(String configName) {
        Map<String, String> configMap = new Map<String, String>();
        
        if(configName == SYSTEM_AMDOCS) {
            try{
            	amdocs_integration_configuration__c config = amdocs_integration_configuration__c.getInstance();
                
                if(config != null) {
                    configMap.put(ENDPOINT, config.endpoint__c);
                    configMap.put(CLIENT_ID, config.client_id__c);
                    configMap.put(CLIENT_SECRET, config.client_secret__c);
                    configMap.put(GRANT_TYPE, config.grant_type__c);
                    configMap.put(SCOPE, config.scope__c);
                    configMap.put(ENABLE_MOCKS, ConversionUtils.booleanToString(config.enable_mocks__c));
                    configMap.put(METHOD, config.method__c);
                    configMap.put(MOCK_ENDPOINT, config.mock_endpoint__c);  
                }    
            }
            catch(Exception e) {
                return null;
            }
        }   

        else if(configName == SYSTEM_EAST) {
            try{
                east_integration_configuration__c config = east_integration_configuration__c.getInstance();
                
                if(config != null) {
                    configMap.put(ENDPOINT, config.endpoint__c);
                    configMap.put(CLIENT_ID, config.client_id__c);
                    configMap.put(CLIENT_SECRET, config.client_secret__c);
                    configMap.put(GRANT_TYPE, config.grant_type__c);
                    configMap.put(SCOPE, config.scope__c);
                    configMap.put(ENABLE_MOCKS, ConversionUtils.booleanToString(config.enable_mocks__c));
                    configMap.put(METHOD, config.method__c);
                    configMap.put(MOCK_ENDPOINT, config.mock_endpoint__c);  
		    configMap.put(ENABLE_MASSL, ConversionUtils.booleanToString(config.enable_massl__c));   	
                }    
            }
            catch(Exception e) {
                return null;
            }
        }  
        
 //Fetch Oauth config for SQ
        else if(configName == SQService.SITE_SQ_EVENT || configName == SQService.SITE_SQ_TRANSITION_EVENT || configName == SQService.SITE_SQ_MOVE_EVENT ||
               configName == SQService.SITE_SQ_FULLSERVICEABILITY_EVENT || configName == SQService.SITE_SQ_NUMBER_PORTABILITY_EVENT) {
            try {
        		Integration_Handler__mdt config = getIntegrationHandlerSettings(configName);
        		if(config != null) {
        			configMap.put(ENDPOINT, config.Auth_End_Point__c);
                    configMap.put(CLIENT_ID, config.Client_Id__c);
                    configMap.put(CLIENT_SECRET, config.Client_Secret__c);
                    configMap.put(GRANT_TYPE, config.Grant_Type__c);
                    configMap.put(SCOPE, config.Scope__c);
                    configMap.put(ENABLE_MOCKS, ConversionUtils.booleanToString(config.Enable_Mock_Integration__c));
                    configMap.put(METHOD, config.oauth_Method__c);
                    configMap.put(MOCK_ENDPOINT, config.Oauth_Mock_Endpint__c);		
        			configMap.put(ENABLE_MASSL, ConversionUtils.booleanToString(config.enable_massl__c));   	
        		}
        	}
        	catch(Exception e) {
                return null;
            }

        }  
        //Fetch config for Replicator 
        else if(configName == ReplicatorLegacyAssetService.GETSERVICE_EVENT || configName == ReplicatorGetSiteService.GETSITE_EVENT ){
        	try {
        		Integration_Handler__mdt config = getIntegrationHandlerSettings(configName);
        		if(config != null) {
        			configMap.put(ENDPOINT, config.Auth_End_Point__c);
                    configMap.put(CLIENT_ID, config.Client_Id__c);
                    configMap.put(CLIENT_SECRET, config.Client_Secret__c);
                    configMap.put(GRANT_TYPE, config.Grant_Type__c);
                    configMap.put(SCOPE, config.Scope__c);
                    configMap.put(ENABLE_MOCKS, ConversionUtils.booleanToString(config.Enable_Mock_Integration__c));
                    configMap.put(METHOD, IntegrationRecordHandlerUtil.HTTP_METHOD_POST);
                    configMap.put(MOCK_ENDPOINT, config.Oauth_Mock_Endpint__c); 
                    configMap.put(ENABLE_MASSL, ConversionUtils.booleanToString(config.enable_massl__c)); 
                }
            }
            catch(Exception e) {
                return null;
            }
        }else {
        	try {
        		Integration_Handler__mdt config = getIntegrationHandlerSettings(configName);
        		if(config != null) {
        			configMap.put(ENDPOINT, config.Auth_End_Point__c);
                    configMap.put(CLIENT_ID, config.Client_Id__c);
                    configMap.put(CLIENT_SECRET, config.Client_Secret__c);
                    configMap.put(GRANT_TYPE, config.Grant_Type__c);
                    configMap.put(SCOPE, config.Scope__c);
                    configMap.put(ENABLE_MOCKS, ConversionUtils.booleanToString(config.Enable_Mock_Integration__c));
                    configMap.put(METHOD, IntegrationRecordHandlerUtil.HTTP_METHOD_POST);
                    configMap.put(MOCK_ENDPOINT, config.Oauth_Mock_Endpint__c); 
                    configMap.put(ENABLE_MASSL, ConversionUtils.booleanToString(config.enable_massl__c)); 
                }
            }
            catch(Exception e) {
                return null;
            }
        }  
       
        return configMap;
    }
	
	@TestVisible 
    private static Integration_Handler__mdt getIntegrationHandlerSettings(String hName) {
        Integration_Handler__mdt handleSettingRecord = null;
        String queryStr = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('Integration_Handler__mdt')) + '\n ' +
                          ' FROM Integration_Handler__mdt \n ' +
                          ' WHERE DeveloperName = \'' + String.escapeSingleQuotes(hName) + '\' LIMIT 1 ';
        
        System.debug('QueryStr: ' + queryStr);
        List<Integration_Handler__mdt> handleSettingRecordList = Database.query(queryStr);
                                                  
        if(handleSettingRecordList != null && !handleSettingRecordList.isEmpty() && handleSettingRecordList.get(0) != null) {
            handleSettingRecord = handleSettingRecordList.get(0);
        }
        System.debug('HandleSettingRecord: ' + handleSettingRecord);         
        return handleSettingRecord;                          
    }	  
}