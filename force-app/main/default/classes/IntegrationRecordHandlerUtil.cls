/******************************************************** 
* Class Name      :   IntegrationRecordHandlerUtil
Test Class : IntegrationRecordHandlerUtilTest
* ===============================================================================================================================
* Change.No.    Developer Name          Date          Story Description
* 1.            Shreya Jaiswal       15/10/19     added class description
*********************************************************
*//*
*    Captures the utility methods that are needed for Handlers to interact with the Integration framework 
*/
//EDGE-112498 -Refactor Order Fulfilment Orchestation
global with sharing class IntegrationRecordHandlerUtil {
    private static final Integer DEFAULT_MAX_PARALLELS = 1;
    public static final Integer HTTP_SUCCESS = 200;
    public static final Integer HTTP_CREATED = 201;
    public static final Integer HTTP_ACCEPTED = 202;
    public static final String HTTP_METHOD_POST = 'POST';
    public static final String HTTP_METHOD_PUT = 'PUT';
    public static final String HTTP_METHOD_GET = 'GET';
    public static final Integer ERROR_404_CODE = 404;
    public static final String ERROR_404_DESC = 'Not Found';
    public static final Integer ERROR_500_CODE = 500;
    public static final String ERROR_500_DESC = 'Internal Server Error';
    public static final Integer ERROR_503_CODE = 503;
    public static final String ERROR_503_DESC = 'The service requested is currently unavailable';

    public static Integer getMaxNoOfRetries(String handlerName) {
        Integer maxRtry = 0;
        // Get max number of retriess from the handler's custom configuration if set
        Integration_Handler__mdt handleSettingRecord = getIntegrationHandlerSettings(handlerName);
        Integer maxNoOfRtriesFromConfig = handleSettingRecord != null && handleSettingRecord.Max_Num_of_Retries__c != null? handleSettingRecord.Max_Num_of_Retries__c.intValue() : 0;
        System.debug('MaxNoOfRtriesFromConfig: ' + maxNoOfRtriesFromConfig);
        // Set max retries
        if (maxNoOfRtriesFromConfig != null && maxNoOfRtriesFromConfig > 0) {
            maxRtry = maxNoOfRtriesFromConfig;
        } else {
            maxRtry = Integer.valueOf(Label.INT_MAX_RETRY);
        }
        
        return maxRtry;
    }

    public static Integer getMaxNoOfRows(String handlerName, Integer maxRows) {
        Integer maxR = 0;
        // Get max number of rows from the handler's custom configuration if set
        Integration_Handler__mdt handleSettingRecord = getIntegrationHandlerSettings(handlerName);
        Integer maxNoOfRowsFromConfig = handleSettingRecord != null && handleSettingRecord.Max_Num_of_Rows__c != null ? handleSettingRecord.Max_Num_of_Rows__c.intValue() : 0;
        
        // Set max rows
        if (maxRows != null) {
            maxR = maxRows;
        } else if (maxNoOfRowsFromConfig != null && maxNoOfRowsFromConfig > 0) {
            maxR = maxNoOfRowsFromConfig;
        } else {
            maxR = Integer.valueOf(Label.INT_MAX_RECORD_NUM);
        }
        
        return maxR;
    }
    
    public static Integer getMaxNoOfParallels(String handlerName, Integer maxParallels) {
        Integer maxP = 0;
        // Get max number of parallels from the handler's custom configuration if set       
        Integration_Handler__mdt handleSettingRecord = getIntegrationHandlerSettings(handlerName);
        Integer maxNoOfParallelsFromConfig = handleSettingRecord != null && handleSettingRecord.Max_Num_of_Parallels__c != null ? handleSettingRecord.Max_Num_of_Parallels__c.intValue() : 0;
            
        // Set max parallels
        if (maxParallels != null) {
            maxP = maxParallels;
        } else if (maxNoOfParallelsFromConfig != null && maxNoOfParallelsFromConfig > 0) {
            maxP = maxNoOfParallelsFromConfig;
        } else {
            maxP = DEFAULT_MAX_PARALLELS;
        }
        
        // Validate against Salesforce's max future call limit          
        if (maxP > Integer.valueOf(Label.SF_MAX_FUTURE_CALLS)) {
            maxP = Integer.valueOf(Label.SF_MAX_FUTURE_CALLS);
        }
        
        return maxP;
    }
     /*
    *   This is the calloutContinuation request that will be made to the external interface. Can be Sync or Async. will be decided by is Continuation flag
    *   - At this point the authorization between SFDC and the external interface should already be handled.
    */
    
    public static Object calloutContinuation(
        String continuationCallBack,
        Object pageParams,
        String payloadURI,
        String jsonPayload,
        String method,
        Map<String, String> headerMap,
        String handlerName,
        List<String> params,
        String correlationId) {
        System.debug('Callout Invoked');
        System.debug('Payload: ' + payloadURI);
        System.debug('HeaderMap: ' + headerMap);
        String errorMessage;
        String endPoint=null;
        Logger log = String.isBlank(correlationId) ? Logger.getLogger(handlerName) : Logger.getLogger(handlerName + ':' + correlationId);
        Object   res;
        Integration_Handler__mdt handleSettingRecord = IntegrationRecordHandlerUtil.getIntegrationHandlerSettings(handlerName);
        if (handleSettingRecord != null) {
            if (handleSettingRecord.Enable_Mock_Integration__c) {endPoint = handleSettingRecord.Mock_End_Point__c != null ? handleSettingRecord.Mock_End_Point__c : '';
            } else {
                endPoint = handleSettingRecord.End_Point__c != null ? handleSettingRecord.End_Point__c : '';
            }
        }
        //System.debug('EndPoint: ' + endPoint + ', Method: ' + method);
        Integer timeout = handleSettingRecord != null && handleSettingRecord.Timeout__c != null ? handleSettingRecord.Timeout__c.intValue() : Integer.valueOf(Label.INT_MAX_TIMEOUT);
        if (String.isBlank(endPoint)) {
            System.debug('Cannot make a callout without an Endpoint');return null;
            //log.debug('Cannot make a callout without an Endpoint');
        }
        HttpRequest req = new HttpRequest();
            if(!String.isEmpty(payloadURI) && payloadURI!=''){
                if (handleSettingRecord.Append_URL_Params_without_question_mark__c) {
                    endPoint += '/' + payloadURI;
                } else {endPoint += '?' + payloadURI;}
            }
        if (!String.isEmpty(jsonPayload)) {
            req.setBody(jsonPayload);
        }
        System.debug('jsonPayload***' + jsonPayload);
        System.debug('endPoint***' + endPoint);
        req.setEndpoint(endPoint);
        if (handleSettingRecord.Enable_MASSL__c) {
            System.debug('MASSL is enabled for interface');
            String certificate_name = EnvironmentVariable.get('massl_certificate_name');
            System.debug('Setting ' + certificate_name + ' certificate for http call');
            if(!test.isRunningTest() && String.isNotBlank(certificate_name)){
                req.setClientCertificateName(certificate_name);
            }
        }
        req.setMethod(method);
        req.setTimeout(timeout);
        headerMap.put('correlationId',correlationId);
        if (headerMap != null) {
            for (String hdName : headerMap.keySet()) {
                req.setHeader(hdName, headerMap.get(hdName));
            }
        }
        try {
            if (handleSettingRecord.Is_Continuation_Call__c) {
                // Create a Continuation for the HTTPRequest
                Continuation con = new Continuation(120);
                ContinuationController.WrapperState state = new ContinuationController.WrapperState();
                state.request = con.addHttpRequest(req);
                //save the state of the system
                state.pageParams = pageParams;
                state.requestBody =jsonPayload;
        		state.requestCid =correlationId;
                state.requestTime=DateTime.now(); //EDGE-127154 - CLF Changes
                con.state = state;
                con.continuationMethod = continuationCallBack;
                // Return it to the system for processing
                res =  con;
            } else {
                Http http = new Http();
                res = http.send(req);
            } } catch (System.Exception e) {
            System.debug(e.getStackTraceString() + '*****Exception');
            System.debug(e);
        } finally {
            if (handleSettingRecord.Is_Sync_Call__c) {
                Logger.exitLogger();
            }
        }
        return res;
    }
    
    /*
    *   This is the callout request that will be made to the external interface. Can be Sync or Async. willbe decided by Is_Sync_Call__c flag
    *   - At this point the authorization between SFDC and the external interface should already be handled. 
    */
    public static HTTPResponse callout(String payload, String method, Map<String,String> headerMap, String handlerName, List<String> params, String correlationId) {
        
        System.debug('Callout Invoked');
        System.debug('Payload: ' + payload);
        System.debug('HeaderMap: ' + headerMap);
        String errorMessage = null;
        String endPoint = null;
        Logger log = String.isBlank(correlationId) ? Logger.getLogger(handlerName) : Logger.getLogger(handlerName + ':' + correlationId);
        HTTPResponse res; 

        Integration_Handler__mdt handleSettingRecord = getIntegrationHandlerSettings(handlerName);
        if(handleSettingRecord != null) {
            if(handleSettingRecord.Enable_Mock_Integration__c) {  endPoint = handleSettingRecord.Mock_End_Point__c != null? handleSettingRecord.Mock_End_Point__c : '';
            }
            else {
                endPoint = handleSettingRecord.End_Point__c != null? handleSettingRecord.End_Point__c : '';
            }
        }
        System.debug('EndPoint: ' + endPoint + ', Method: ' + method);
        
        Integer timeout = handleSettingRecord != null && handleSettingRecord.Timeout__c != null? handleSettingRecord.Timeout__c.intValue() : Integer.valueOf(Label.INT_MAX_TIMEOUT);
        if(String.isBlank(endPoint)) {
            System.debug('Cannot make a callout without an Endpoint');
            //log.debug('Cannot make a callout without an Endpoint');
            return null;
        }
                
        HttpRequest req = new HttpRequest();

        if(method ==HTTP_METHOD_GET){
        if(handleSettingRecord.Append_URL_Params_without_question_mark__c){
            req.setEndpoint(endPoint+ '/' +payload);    
        }else{
            req.setEndpoint(endPoint+ '?' +payload);    
        }
        
        }else{

            req.setEndpoint(endPoint);
            req.setBody(payload);

        }
        
        // @author : Akshay Deuskar | Added to enable MASSL for integration as part of NFB-1218
        if(handleSettingRecord.Enable_MASSL__c) {
            System.debug('MASSL is enabled for interface');
            String certificateName = null;
            certificateName = EnvironmentVariable.get('massl_certificate_name');
            System.debug('Setting ' + certificateName + ' certificate for http call');
            if(certificateName!=null){ req.setClientCertificateName(certificateName);
            }
        }
        
        req.setMethod(method);
        req.setTimeout(timeout);

        if(headerMap != null) {
            for(String hdName : headerMap.keySet()) {
                req.setHeader(hdName, headerMap.get(hdName));   
            }
        }
        
        try {
            Http http = new Http();
            res = http.send(req);
            //log.logRequest(payload);
            System.debug('Response: ' + res.getBody());
            //log.logResponse(res.getBody());
            /*if(res.getStatusCode() == 200){
                logger.logMessages(req.getBody(), res.getBody(), '', '', '', '', false, false);
            } else {
                logger.logMessages(req.getBody(), res.getBody(), '', '', res.getStatus()+': '+res.getStatusCode(), '', false, false);
            }
            */
            if(!handleSettingRecord.Is_Sync_Call__c){
                
                if(res.getStatusCode() != HTTP_SUCCESS && res.getStatusCode() != HTTP_ACCEPTED && res.getStatusCode() != HTTP_CREATED) { 
                    System.debug('##### INVALID STATUS CODE ' + res.getStatusCode());        
                    errorMessage = 'A HTTP error occurred' +  '\n' + 'Status Code: ' + res.getStatusCode() + '\n' + 'Status Message: ' + res.getStatus();   
                    IntegrationQueuableUtils.retry(handlerName, params, errorMessage); //retry                
                    System.debug('For handler: ' + handlerName + ' Error Response: '+ errorMessage);
                } else {
                    System.debug('##### Success');              
                    System.debug('For handler: ' + handlerName + ' got success Response');
                    IntegrationQueuableUtils.updateOnSucess(handlerName, params);
                }
                
            }
            
        } catch(System.Exception e) {
            System.debug(e);
            //log.debug(e);
            //Logger.exitLogger();
            /*logger.logMessages(req.getBody(), res.getBody(), e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();*/
            if(!handleSettingRecord.Is_Sync_Call__c){
            IntegrationQueuableUtils.retry(handlerName, params, (e.getMessage() + '\n\n' + e.getStackTraceString())); //retry     
            }       
        }
        finally {
            if(handleSettingRecord.Is_Sync_Call__c) { Logger.exitLogger();    
            }
        }
        
        return res;
        
    }
    
    public static HTTPResponse callout(String payload, String method, Map<String,String> headerMap, String handlerName, List<String> params, String correlationId, Map<String,String> pathMap) {
        String errorMessage;
        String endPoint = null;
        Logger log = String.isBlank(correlationId) ? Logger.getLogger(handlerName) : Logger.getLogger(handlerName + ':' + correlationId);
        HTTPResponse res;
        Integration_Handler__mdt handleSettingRecord = getIntegrationHandlerSettings(handlerName);
        if(handleSettingRecord != null) {
            if(handleSettingRecord.Enable_Mock_Integration__c) {endPoint = handleSettingRecord.Mock_End_Point__c != null? handleSettingRecord.Mock_End_Point__c : '';
            }
            else {
                endPoint = handleSettingRecord.End_Point__c != null? handleSettingRecord.End_Point__c : '';
            }
            for(String path : pathMap.keySet()){
                endPoint += '/' + path + '/' + pathMap.get(path);
            }
        }
        Integer timeout = handleSettingRecord != null && handleSettingRecord.Timeout__c != null? handleSettingRecord.Timeout__c.intValue() : Integer.valueOf(Label.INT_MAX_TIMEOUT);
        if(String.isBlank(endPoint)) {
            return null;
        }
        HttpRequest req = new HttpRequest();
        if(method ==HTTP_METHOD_GET){
        if(handleSettingRecord.Append_URL_Params_without_question_mark__c){
            req.setEndpoint(endPoint+ '/' +payload);    
        }else{ req.setEndpoint(endPoint+ '?' +payload);    
        }
        }else{
            req.setEndpoint(endPoint);
            req.setBody(payload);
        }
        if(handleSettingRecord.Enable_MASSL__c) {
            System.debug('MASSL is enabled for interface');
            String certificateName = null;
            certificateName = EnvironmentVariable.get('massl_certificate_name');
            System.debug('Setting ' + certificateName + ' certificate for http call');
            if(certificateName!=null){
                   req.setClientCertificateName(certificateName);
            }} req.setMethod(method);
        req.setTimeout(timeout);
        if(headerMap != null) {
            for(String hdName : headerMap.keySet()) {
                req.setHeader(hdName, headerMap.get(hdName));    
            }
        }
        try {
            Http http = new Http();
            res = http.send(req);
            if(!handleSettingRecord.Is_Sync_Call__c){
                if(res.getStatusCode() != HTTP_SUCCESS && res.getStatusCode() != HTTP_ACCEPTED) { 
                    System.debug('##### INVALID STATUS CODE ' + res.getStatusCode());        
                    errorMessage = 'A HTTP error occurred' +  '\n' + 'Status Code: ' + res.getStatusCode() + '\n' + 'Status Message: ' + res.getStatus();  
                    IntegrationQueuableUtils.retry(handlerName, params, errorMessage); //retry                
                    System.debug('For handler: ' + handlerName + ' Error Response: '+ errorMessage);
                } else {
                    System.debug('##### Success'); System.debug('For handler: ' + handlerName + ' got success Response');
                    IntegrationQueuableUtils.updateOnSucess(handlerName, params);
                }}
        } catch(System.Exception e) {
            if(!handleSettingRecord.Is_Sync_Call__c){
            IntegrationQueuableUtils.retry(handlerName, params, (e.getMessage() + '\n\n' + e.getStackTraceString())); //retry    
            }      
        }
        finally {
            if(handleSettingRecord.Is_Sync_Call__c) {
                Logger.exitLogger();     }
        } return res;}
    
    public static HTTPResponse calloutSync(String payload, String method, Map<String,String> headerMap, String handlerName, Map<String,String> pathMap) {    
        return callout(payload,method,headerMap,handlerName, null,null,pathMap);    
    }
    
 public static void createRequests(String handlerName, List<String> params) {
        createRequests(handlerName, params, null);
    }
    /*
    *   This is the Syncronous callout request that will be made to the external interface.
    *   - At this point the authorization between SFDC and the external interface should already be handled. 
    */
    public static HTTPResponse calloutSync(String payload, String method, Map<String,String> headerMap, String handlerName) {   
        return callout(payload,method,headerMap,handlerName, null,null);    
    }
    
    /*
    *   Use this method when the request payload cannot be built at run time using data within SFDC. 
    *   In this case 'paramPayload' will consist of the full request payload
    */
    public static void createRequests(String handlerName, List<String> params, String paramPayload) {
        List<Integration_Record__c> requests = new List<Integration_Record__c>();
        
        if (EnvironmentalSettings.isValidHandler(handlerName)) {
            List<Integration_Record__c> existingRequests = [SELECT Id, params__c 
                                                            FROM Integration_Record__c 
                                                            WHERE params__c IN :CollectionUtil.removeNull(params)
                                                            AND handler__c = :handlerName 
                                                            AND (Status__c = :IntegrationQueueHandler.PENDING OR Status__c = :IntegrationQueueHandler.IN_PROGRESS)];
                                                        
            system.debug('CreateRequests existingRequests: ' + existingRequests);
            system.debug('CreateRequests requests: ' + requests);
            system.debug('CreateRequests handlerName: ' + handlerName);
            system.debug('CreateRequests params: ' + params);
            
            Map<String, Integration_Record__c> existingMap = new Map<String, Integration_Record__c>();
                
            for (Integration_Record__c existingRequest : existingRequests) {
                existingMap.put(existingRequest.params__c, existingRequest);
            }
                
            for (String param : params) {
                if (!existingMap.containsKey(param)) {
                    Integration_Record__c request = new Integration_Record__c();
                    request.Params__c = param;
                    request.Handler__c = handlerName;
                if(String.isNotBlank(paramPayload)) {
                        request.paramPayload__c = paramPayload; }
                    request.Status__c = IntegrationQueueHandler.PENDING;
                    requests.add(request);
                }
            }
            
            system.debug('CreateRequests method - requests: ' + requests);
            if(handlerName != 'ManageOrderSumbitHandler'){
                if(requests != null){
                    insert requests;
                }
                if(!Test.isRunningTest()){
                    IntegrationQueuableUtils.queueHandlerJob(handlerName, null);
                }    
            }
            else{
               if(!Test.isRunningTest()) {
                ManageOrderService.sendOrderSync(params);
             } 
             If(requests != null){
                    new IntegrationRecordsManipulationQueueble(requests,TRUE).executeIntegrationRecords();
             }           
           }
            
                      
            //EDGE-112498        
        } else {System.debug('method createRequests - handlerName ' + handlerName + ' was excluded from the Integration Framework due to user settings.'); }
    }      
    
    //Start Changes for EDGE-127536 Code Refector 
    public static void createRequestsForTramas(String handlerName, List<String> params, String paramPayload,List<Integration_Record__c>existingRequests) {
        List<Integration_Record__c> requests = new List<Integration_Record__c>();
        
        if (EnvironmentalSettings.isValidHandler(handlerName)) {
           /* List<Integration_Record__c> existingRequests = [SELECT Id, params__c 
                                                            FROM Integration_Record__c 
                                                            WHERE params__c IN :CollectionUtil.removeNull(params)
                                                            AND handler__c = :handlerName 
                                                            AND (Status__c = :IntegrationQueueHandler.PENDING OR Status__c = :IntegrationQueueHandler.IN_PROGRESS)];*/
                                                        
            system.debug('CreateRequests existingRequests: ' + existingRequests);
            system.debug('CreateRequests requests: ' + requests);
            system.debug('CreateRequests handlerName: ' + handlerName);
            system.debug('CreateRequests params: ' + params);
            
            Map<String, Integration_Record__c> existingMap = new Map<String, Integration_Record__c>();
                
            for (Integration_Record__c existingRequest : existingRequests) {
                existingMap.put(existingRequest.params__c, existingRequest);
            }
                
            for (String param : params) {
                if (!existingMap.containsKey(param)) {
                    Integration_Record__c request = new Integration_Record__c();
                    request.Params__c = param;
                    request.Handler__c = handlerName;
                if(String.isNotBlank(paramPayload)) {
                        request.paramPayload__c = paramPayload; }
                    request.Status__c = IntegrationQueueHandler.PENDING;
                    requests.add(request);
                }
            }
            
            system.debug('CreateRequests method - requests: ' + requests);
           // if(handlerName != 'ManageOrderSumbitHandler'){
                     if(requests != null){
                        insert requests;}
                     if(!Test.isRunningTest()){
                        IntegrationQueuableUtils.queueHandlerJob(handlerName, null);
                    }    
                    
       // }
           
            
                      
            //EDGE-112498        
        } else {System.debug('method createRequests - handlerName ' + handlerName + ' was excluded from the Integration Framework due to user settings.'); }
    } 
    //End Changes for EDGE-127536 Code Refector 
    

    @TestVisible 
    public static Integration_Handler__mdt getIntegrationHandlerSettings(String hName) {
        Integration_Handler__mdt handleSettingRecord = new Integration_Handler__mdt();
        String queryStr = ' SELECT ' + SObjectHelper.getFieldListForSOQL('Integration_Handler__mdt') + '\n ' +
                          ' FROM Integration_Handler__mdt \n ' +
                          ' WHERE DeveloperName = \'' + hName + '\' LIMIT 1 ';
        
        System.debug('QueryStr: ' + queryStr);
        List<Integration_Handler__mdt> handleSettingRecordList = Database.query(queryStr);
                                                  
        if(handleSettingRecordList != null && !handleSettingRecordList.isEmpty() && handleSettingRecordList.get(0) != null) {
            handleSettingRecord = handleSettingRecordList.get(0);
        }
        System.debug('HandleSettingRecord: ' + handleSettingRecord);         
        return handleSettingRecord;                          
    }
    
    public static String getCorrelationId() {
        String hashString = String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        String regExp = '[-:\\s]';
        String replacement = '';
        String uniqueString = hashString.replaceAll(regExp, replacement);
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(uniqueString));
        String hexDigest = EncodingUtil.convertToHex(hash).subString(0, 18);
        System.debug('Generated Unique Key: ' + hexDigest);
        return hexDigest;       
    } 
    
    // This method is added as a temp fix. All the failing test classes should use the updated callout() method
    // as strategic fix. Post that this method should again be removed from the class.
    /*
    *   This is the callout request that will be made to the external interface. Can be Sync or Async. willbe decided by Is_Sync_Call__c flag
    *   - At this point the authorization between SFDC and the external interface should already be handled. 
    */
    public static HTTPResponse callout(String payload, String method, Map<String,String> headerMap, String handlerName, List<String> params) {
        
        System.debug('Callout Invoked');
        System.debug('Payload: ' + payload);
        System.debug('HeaderMap: ' + headerMap);
        String errorMessage;
        String endPoint;
        //Logger2 logger = Logger2.getLogger('AddressSearchIntegrationRecordHandlerUtil');
        HTTPResponse res; 
        
        Integration_Handler__mdt handleSettingRecord = getIntegrationHandlerSettings(handlerName);
        if(handleSettingRecord != null) {
            if(handleSettingRecord.Enable_Mock_Integration__c) {
                endPoint = handleSettingRecord.Mock_End_Point__c != null? handleSettingRecord.Mock_End_Point__c : '';
            }
            else {
                endPoint = handleSettingRecord.End_Point__c != null? handleSettingRecord.End_Point__c : '';
            }
        }
        System.debug('EndPoint: ' + endPoint + ', Method: ' + method);
        
        Integer timeout = handleSettingRecord != null && handleSettingRecord.Timeout__c != null? handleSettingRecord.Timeout__c.intValue() : Integer.valueOf(Label.INT_MAX_TIMEOUT);
        if(String.isBlank(endPoint)) { System.debug('Cannot make a callout without an Endpoint');
            //log.debug('Cannot make a callout without an Endpoint');
            return null;
        }
                
        HttpRequest req = new HttpRequest();

        if(method ==HTTP_METHOD_GET){
        if(handleSettingRecord.Append_URL_Params_without_question_mark__c){
            req.setEndpoint(endPoint+ '/' +payload);    
        }else{
            req.setEndpoint(endPoint+ '?' +payload);    
        }
        
        }else{

            req.setEndpoint(endPoint);
            req.setBody(payload); }
        
        // @author : Akshay Deuskar | Added to enable MASSL for integration as part of NFB-1218
        if(handleSettingRecord.Enable_MASSL__c) {
            System.debug('MASSL is enabled for interface');
            String certificateName = null;
            certificateName = EnvironmentVariable.get('massl_certificate_name');
            System.debug('Setting ' + certificateName + ' certificate for http call');
            req.setClientCertificateName(certificateName);
        }
        
        req.setMethod(method);
        req.setTimeout(timeout);

        if(headerMap != null) {
            for(String hdName : headerMap.keySet()) {
                req.setHeader(hdName, headerMap.get(hdName));   
            } }
        
        try {
            Http http = new Http();
            res = http.send(req);
            //log.logRequest(payload);
            System.debug('Response: ' + res.getBody());
            //log.logResponse(res.getBody());
            /*if(res.getStatusCode() == 200){
                logger.logMessages(req.getBody(), res.getBody(), '', '', '', '', false, false);
            } else {
                logger.logMessages(req.getBody(), res.getBody(), '', '', res.getStatus()+': '+res.getStatusCode(), '', false, false);
            }
            */
            if(!handleSettingRecord.Is_Sync_Call__c){
                
                if(res.getStatusCode() != HTTP_SUCCESS && res.getStatusCode() != HTTP_ACCEPTED) { 
                    System.debug('##### INVALID STATUS CODE ' + res.getStatusCode());        
                    errorMessage = 'A HTTP error occurred' +  '\n' + 'Status Code: ' + res.getStatusCode() + '\n' + 'Status Message: ' + res.getStatus();   
                    IntegrationQueuableUtils.retry(handlerName, params, errorMessage); //retry                
                    System.debug('For handler: ' + handlerName + ' Error Response: '+ errorMessage);
                } else {
                    System.debug('##### Success');              
                    System.debug('For handler: ' + handlerName + ' got success Response');
                    IntegrationQueuableUtils.updateOnSucess(handlerName, params);
                }
                
            }} catch(System.Exception e) {
            System.debug(e);
            //log.debug(e);
            //Logger.exitLogger();
            /*logger.logMessages(req.getBody(), res.getBody(), e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();*/
            if(!handleSettingRecord.Is_Sync_Call__c){
            IntegrationQueuableUtils.retry(handlerName, params, (e.getMessage() + '\n\n' + e.getStackTraceString())); //retry     
            }       
        }
        /*logger.exitLogger();*/
        return res;
        
    }
    public static String getUUID() {
        String hashString = String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        String regExp = '[-:\\s]';
        String replacement = '';
        String uniqueString = hashString.replaceAll(regExp, replacement);
        //system.debug('uniqueString+'+uniqueString);
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(uniqueString));
        //system.debug('hash+'+hash);
        String hexDigestValue = EncodingUtil.convertToHex(hash).subString(0, 32);
        //System.debug('Generated Unique Key: ' + hexDigestValue);
        String firstValue=hexDigestValue.substring(0,8);
        String secondValue=hexDigestValue.substring(8,12);
        String thirdValue=hexDigestValue.substring(12,16);
        String fourthValue=hexDigestValue.substring(16,20);
        String fifthValue=hexDigestValue.substring(20,32);
        String finalValue=firstValue+'-'+secondValue+'-'+thirdValue+'-'+fourthValue+'-'+fifthValue;
        //system.debug('finalValue++'+finalValue);
        return finalValue;       
    }
     
    

    
}//end of class IntegrationRecordHandlerUtil