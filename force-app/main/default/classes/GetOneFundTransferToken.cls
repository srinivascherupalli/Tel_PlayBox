/*
    AUTHOR : Sajal Shah    
    DESCRIPTION : This class is used to callout the external interfaces for One Fund Transfer
*/

@RestResource(urlMapping='/onefund/*')
global with sharing class GetOneFundTransferToken {
    global static String accessToken = '';
    global static String CIDN = '';
    private static final C2O_ExceptionHandler.Capability CONST_CAPABILITY = C2O_ExceptionHandler.Capability.BSK;
    private static final String CONST_INTERFACENAME = 'GetOneFundTransferToken';

    @HttpPost
    global static Map<String, String> getOneFundAuthToken(String CIDNval){ 
        Map<String, String> responseMap = GetOneFundTransferToken.getResponse(EnvironmentVariable.get('onefund_okapi_token_endpoint'), 'POST', '');
    
        Object tokenResponse = (Object) responseMap.get('access_token');
        accessToken = String.valueOf(tokenResponse);
        CIDN = CIDNval;
        if(accessToken != ''){
            Map<String, String> responseFromTransaction = GetOneFundTransferToken.getOneFundTransactionDetails();
            System.debug('---responseMap getOneFundAuthToken responseFromTransaction---'+responseFromTransaction);
            return responseFromTransaction;
        }
        System.debug('---responseMap getOneFundAuthToken---'+responseMap);
        return responseMap;
    } 

    @HttpGet
    global static Map<String, String> getOneFundTransactionDetails(){
            Map<String, String> responseMap = GetOneFundTransferToken.getResponse(EnvironmentVariable.get('onefund_okapi_transaction_endpoint'), 'GET', CIDN);
            if(responseMap.get('cidn') == CIDN && (responseMap.get('fundBalance') != null && responseMap.get('contributionBalance') != null && (Double.valueOf(responseMap.get('fundBalance')) + Double.valueOf(responseMap.get('contributionBalance'))) > 0.0)){
                Map<String, String> responseFromTransfer = GetOneFundTransferToken.getOneFundTransactionTransfer();
                System.debug('---responseFromTransfer---'+responseFromTransfer);
                responseMap.putAll(responseFromTransfer);
                if(responseFromTransfer.get('Error') == 'false'){
                    System.debug('---in error---');
                    responseMap.put('message',ConstantMetadataUtility__mdt.getInstance('One_Fund_Success_Message').Value__c);
                    System.debug('---responseMap 38---'+responseMap);
                    return responseMap;
                }
                else{
                    System.debug('---responseMap 42---'+responseMap);
                    return responseMap;
                }
            }
            else if(responseMap.get('fundBalance') != null && responseMap.get('contributionBalance') != null && (Double.valueOf(responseMap.get('fundBalance')) + Double.valueOf(responseMap.get('contributionBalance'))) <= 0.0){
                if(responseMap.get('Error') == 'false'){
                    responseMap.put('message', EnvironmentVariable.get('onefund_okapi_zerobalance_error'));
                }
            }
            System.debug('---responseMap---'+responseMap);
            return responseMap;
    }

    @HttpPatch
    global static Map<String, String> getOneFundTransactionTransfer(){
        Map<String, String> responseMap = GetOneFundTransferToken.getResponse(EnvironmentVariable.get('onefund_okapi_transaction_endpoint'), 'PATCH', CIDN);
        return responseMap;
    }

    public static Map<String, String> getResponse(String endpoint, String method, String CIDN) {
        Map<String, String> result = new Map<String, String>();
        String errorMessage,statusCode;
        String error40001 = ConstantMetadataUtility__mdt.getInstance('Error_Message_40001').Value__c;
        String error40002 = ConstantMetadataUtility__mdt.getInstance('Error_Message_40002').Value__c;
        String error401 = ConstantMetadataUtility__mdt.getInstance('Error_Message_401').Value__c;
        try{
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod(method);
            if(method == 'GET' || method == 'PATCH'){
                req.setHeader('Authorization', 'Bearer ' + accessToken);
                if(method == 'GET'){
                    req.setEndpoint(endpoint+'?CIDN='+CIDN);
                    req.setHeader('Content-Type', EnvironmentVariable.get('onefund_okapi_contenttype'));
                }
                else{
                    
                    req.setBody('{"CIDN":"'+CIDN+'"}');
                    req.setHeader('Content-Type', 'application/json');
                }
                
            }
            else{
                req.setBody('client_id=' + EncodingUtil.urlEncode(EnvironmentVariable.get('onefund_okapi_clientId'), 'UTF-8') +
                '&client_secret=' + EncodingUtil.urlEncode(EnvironmentVariable.get('onefund_okapi_clientSecret') , 'UTF-8') +
                '&grant_type=' + EncodingUtil.urlEncode(EnvironmentVariable.get('onefund_okapi_grantType'), 'UTF-8') +
                '&scope='+ EncodingUtil.urlEncode(EnvironmentVariable.get('onefund_okapi_scope'), 'UTF-8'));
            }
            req.setClientCertificateName(EnvironmentVariable.get('onefund_okapi_certificate_name'));
            HttpResponse res = h.send(req);
            System.debug('---res body---'+res.getBody());
            statusCode = json.serialize(res.getStatusCode());
            result = (Map<String, String>)JSON.deserialize(res.getBody(), Map<String, String>.class);
            if(statusCode == '200'){
                result.put('Error', 'false');
            }
            if(statusCode == '400'){
                if(result.get('code') == '40001'){
                    errorMessage = error40001;
                }
                else if(result.get('code') == '40002'){
                    errorMessage = error40002;
                }
                else{
                    errorMessage = 'Error: Status Code-'+statusCode+': Internal server error! ';
                }
            }
            else if(statusCode == '401'){
                errorMessage = error401;
            }
            else if(statusCode != '200'){
                errorMessage = 'Error: Status Code-'+statusCode+': Internal server error! ';
            }
            if(errorMessage != null && errorMessage != ''){
                result.put('message',errorMessage);
                result.put('Error', 'true');
            }
            return result;
        }
        catch (Exception ex) {
            Map<String, Object> eLogMap = new Map<String, Object>();
            eLogMap.put('capability', CONST_CAPABILITY);
            eLogMap.put('interfaceName', CONST_INTERFACENAME);
            eLogMap.put('elementName', 'getOneFundTransactionTransfer');
            eLogMap.put('referenceNumber', '');
            eLogMap.put('correlationId', '');
            eLogMap.put('errorDescription', ex.getMessage());
            eLogMap.put('businessDescription', 'read response of callback');
            C2O_Utilities.logException(eLogMap, false);
            if(statusCode == '400'){
                if(result.get('code') == '40001'){
                    errorMessage = error40001;
                }
                else if(result.get('code') == '40002'){
                    errorMessage = error40002;
                }
                else{
                    errorMessage = 'Error: Status Code-'+statusCode+': Internal server error! ';
                }
            }
            else if(statusCode == '401'){
                errorMessage = error401;
            }
            else{
                errorMessage = 'Error: Status Code-'+statusCode+': Internal server error! ';
            }
            if(errorMessage != null && errorMessage != ''){
                result.put('message',errorMessage);
                result.put('Error', 'true');
            }
            System.debug('---result---'+result);
            return result;
        }
    }
}