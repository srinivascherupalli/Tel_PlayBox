/**
* Version        Date               Author                      Modification
* ----------------------------------------------------------------------------
* 1.0            05/04/2021         Arunkumar V               Created
*
* @description Performs validations on the flow.  Session data is stored in the session cache, as well as in a TLS_Session__c
* object to ensure data persistence.  Write operations go to both the session cache and the TLS_Session__c object.
* Read operations are retrieved from the session cache, unless the session cache has expired.  In this case, the session 
* cache entry is rebuilt from the TLS_Session__c object. 
* 
* correlationId is used to identify the session/flow.
*/
public with sharing class OC_SessionPayloadValidation {
    //Get Logger Instance
    // private static Logger logger = LoggerFactory.getLogger(OC_SessionPayloadValidation.CLASS);
    
    public final static String SUCCESS_RESULT = 'Success';
    public final static String ERROR_RESULT = 'Error';
    private final static String FLOWNAME_KEY = 'flowName';	
    private final static String NO_CACHE_OR_SESSION_ERROR = 'No cache or session found';
    private final static String MISSING_CORRELATION_ID_ERROR = 'No correlationId found';
    private final static String GUEST_LICENSE_NAME = 'Guest User License';
       
    
    // Exception logging    
    
    private static Map<String, Object> eLogMap = new Map<String, Object>();
    @TestVisible
    private void assignValuesToMap(){
        String errorDescription;
        String errorCode = '500';
        String Capability = 'OC';
        String interfaceName = 'OC_SessionPayloadValidation';
        String errorCategory = 'Technical';
        String severity = '3';
        
        eLogMap.put( 'Capability', Capability);
        eLogMap.put( 'interfaceName', interfaceName);
        eLogMap.put( 'errorCategory', errorCategory);
        eLogMap.put( 'severity', severity); //WARNING
        eLogMap.put( 'errorCode', errorCode);  
    }
    
    @TestVisible private static Boolean isGuestProfile;
    
    // Constructor is private - since all methods are static.
    @TestVisible
    private OC_SessionPayloadValidation() {}
    
    static{
        Profile usrProfile = [Select Id, UserLicense.Name From Profile Where Id = :UserInfo.getProfileId()];
        isGuestProfile = usrProfile.UserLicense.Name.equalsIgnorecase(GUEST_LICENSE_NAME);
    }
    
    /*******************************************************************************************************
* @description Creates the session data in the session cache and a TLS_Session__c object
* @param correlationId Used to identify the session
* @param methodName The executing step
* @param flow An Object that encapsulates the flow.  The class name becomes the flowName stored in the session data
* @return true if the session was successfully created, false if correlationId was null or empty string
* @example
* OC_AC_ServiceMigrationBFF bff = new OC_AC_ServiceMigrationBFF();
* OC_SessionPayloadValidation.createSession('1234', 'checkMigrationEligibilityAndCreateCart', bff);
*/
    public static Boolean createSession(String correlationId, String methodName, Object flow) {
        // logger.info('Entering createSession Method and parameters are'+
        // ' correlationId-->'+correlationId+
        // ' methodName-->'+methodName+
        // ' flow-->'+getFlowName(flow));
        
        if (String.isBlank(correlationId)) {
            eLogMap.put( 'correlationId', correlationId);
            eLogMap.put( 'elementName', methodName);
            eLogMap.put( 'errorDescription', MISSING_CORRELATION_ID_ERROR);
            C2O_Utilities.logException(eLogMap, false);			
            // OrderingUtil.logException(CAPABILITY, INTERFACE_NAME, TECHNICAL_ERROR, correlationId, methodName, WARNING, ERROR_CODE, MISSING_CORRELATION_ID_ERROR);
            return false; // Failed: No correlationId found
        }
        
        TLS_Session__c existingSession = getSessionObject(correlationId);
        if (existingSession != null) {
            return true;
        }
        
        Map<String, Object> sessionData = new Map<String, Object>();
        sessionData.put(FLOWNAME_KEY, getFlowName(flow));
        CacheManager.put(CacheType.SESSION, cacheKey(correlationId), sessionData);
        String jsonPayload = JSON.serialize(sessionData);
        try {
            TLS_Session__c session = new TLS_Session__c(TLS_CorrelationId__c = correlationId, TLS_PayLoad__c = jsonPayload);
            insert session;
        } catch(DmlException e) {
            eLogMap.put( 'correlationId', correlationId);
            eLogMap.put( 'elementName', methodName);
            eLogMap.put( 'errorDescription', e.getMessage());
            C2O_Utilities.logException(eLogMap, false);	
            //OrderingUtil.logException(CAPABILITY, INTERFACE_NAME, TECHNICAL_ERROR, correlationId, methodName, NO_INPUT, WARNING, ERROR_CODE, e.getMessage());
            return false;
        }
        // logger.info('Exiting createSession Method');
        return true;
    }

    public static Boolean createSessionOrderOrchestration(Set<string> correlationId, String methodName, Map<String, Object> flow) {
        // logger.info('Entering createSession Method and parameters are'+
        // ' correlationId-->'+correlationId+
        // ' methodName-->'+methodName+
        // ' flow-->'+getFlowName(flow));
        
        if (correlationId.isEmpty()) {
            eLogMap.put( 'correlationId', 'correlationId');
            eLogMap.put( 'elementName', methodName);
            eLogMap.put( 'errorDescription', MISSING_CORRELATION_ID_ERROR);
            C2O_Utilities.logException(eLogMap, false);			
            // OrderingUtil.logException(CAPABILITY, INTERFACE_NAME, TECHNICAL_ERROR, correlationId, methodName, WARNING, ERROR_CODE, MISSING_CORRELATION_ID_ERROR);
            return false; // Failed: No correlationId found
        }
        
        // List<TLS_Session__c> listExistingSession = getlistOfSessionObject(correlationId);
        //     if (existingSession != null) {
        //     return true;
        // }
        List<TLS_Session__c> listExistingSession = new List<TLS_Session__c>();
        try {
            for(string iterator : correlationId){
                Map<String, Object> sessionData = new Map<String, Object>();
                sessionData.put(FLOWNAME_KEY, getFlowName(flow.get(iterator)));
                CacheManager.put(CacheType.ORG, cacheKey(iterator), sessionData);
                String jsonPayload = JSON.serialize(sessionData);
                TLS_Session__c session = new TLS_Session__c(TLS_CorrelationId__c = iterator, TLS_PayLoad__c = jsonPayload);
                listExistingSession.add(session);
            }
            insert listExistingSession;
        } catch(DmlException e) {
            eLogMap.put( 'correlationId', 'correlationId');
            eLogMap.put( 'elementName', methodName);
            eLogMap.put( 'errorDescription', e.getMessage());
            C2O_Utilities.logException(eLogMap, false);	
            //OrderingUtil.logException(CAPABILITY, INTERFACE_NAME, TECHNICAL_ERROR, correlationId, methodName, NO_INPUT, WARNING, ERROR_CODE, e.getMessage());
            return false;
        }
        // logger.info('Exiting createSession Method');
        return true;
    }
    /*******************************************************************************************************
* @description Verifies if a session has been created in the session cache and a TLS_Session__c object for the specified correlationId
* @param correlationId Used to identify the session
* @return true if the session exists, false otherwise
* @example
* Boolean exists = OC_SessionPayloadValidation.sessionExists('1234');
*/
    public static Boolean sessionExists(String correlationId) {    
        if (String.isBlank(correlationId)) {
            return false; // Failed: No correlationId found
        }
        System.debug('sessionExists :: found correlationId ---> ' + correlationId);
        // retrieves cache/session by correlationId
        if (!isGuestProfile && CacheManager.get(CacheType.SESSION, cacheKey(correlationId)) != null) {
            return true;
        }
        return (getSessionObject(correlationId) != null);
    }

    /**
    * @description 
    * @author Rohit Pal | 10-21-2021 
    * @param correlationId 
    * @return Boolean 
    **/
    public static Boolean sessionExistsOrder(String correlationId) {    
        if (String.isBlank(correlationId)) {
            return false; // Failed: No correlationId found
        }
        System.debug('sessionExists :: found correlationId ---> ' + correlationId);
        // retrieves cache/session by correlationId
        if (!isGuestProfile && CacheManager.get(CacheType.ORG, cacheKey(correlationId)) != null) {
            return true;
        }
        return (getSessionObject(correlationId) != null);
    }
    
    /*******************************************************************************************************
* @description Verifies that the requested flow matches the flow stored in session data
* @param correlationId Used to identify the session
* @param methodName The executing step
* @param flow An Object that encapsulates the flow.  The class name becomes the flowName stored in the session data
* @return true if the requested flow matches the stored flow, false otherwise
* @example
* OC_AC_ServiceMigrationBFF bff = new OC_AC_ServiceMigrationBFF();
* Boolean valid = OC_SessionPayloadValidation.verifyFlow('1234', 'checkMigrationEligibilityAndCreateCart', bff);
*/
    public static Boolean verifyFlow(String correlationId, String methodName, Object flow) {
        return assertEquals(correlationId, methodName, FLOWNAME_KEY, getFlowName(flow));
    }
    
    /*******************************************************************************************************
* @description Adds a key/value pair to the session data
* @param correlationId Used to identify the session
* @param methodName The executing step
* @param key The key for adding the data to the session cache and payLoad__c field of the TLS_Session__c object
* @param value The value of the data to add the session cache and payLoad__c field of the TLS_Session__c object
* @return true if the data was added, false if the session could not be retrieved
* @example
* OC_SessionPayloadValidation.addSessionData('1234', 'checkMigrationEligibilityAndCreateCart', 'cartId', '8015O000000FfrlQAC');
*/
    public static Boolean addSessionData(String correlationId, String methodName, String key, Object value) {
        // logger.info('Entering addSessionData Method and parameters are'+
        // ' correlationId-->'+correlationId+
        // ' methodName-->'+methodName+
        // ' key-->'+key+
        // ' flow-->'+String.valueOf(value));
        try {
            Map<String,Object> cacheMap = retrieveCache(correlationId);
            cacheMap.put(key, value);
            system.debug(cacheMap);
            
            if(!isGuestProfile){
                CacheManager.put(CacheType.SESSION, cacheKey(correlationId), cacheMap);
            }
            
            if (!updateSessionObject(correlationId, cacheMap)) {
                return false;
            }
        } catch(Exception e) {
            eLogMap.put( 'correlationId', correlationId);
            eLogMap.put( 'elementName', methodName);
            eLogMap.put( 'errorDescription', e.getMessage());
            C2O_Utilities.logException(eLogMap, false);
            //OrderingUtil.logException(CAPABILITY, INTERFACE_NAME, TECHNICAL_ERROR, correlationId, methodName, WARNING, ERROR_CODE, e.getMessage());
            return false;
        }
        // logger.info('Exiting addSessionData Method');
        return true;
    }
    
    /*******************************************************************************************************
* @description Adds a map of key/value pairs to the session data
* @param correlationId Used to identify the session
* @param methodName The executing step
* @param values The Map of values for adding to the session cache and payLoad__c field of the TLS_Session__c object
* @return true if the data was added, false if the session could not be retrieved
* @example
* Map<String, Object> values = new Map<String, Object>{'key1' => 'value1', 'key2' => 'value2'};
* OC_SessionPayloadValidation.addSessionData('1234', 'checkMigrationEligibilityAndCreateCart', values);
*/
    public static Boolean addSessionData(String correlationId, String methodName, Map<String, Object> values) {
        // logger.Info('Entering addSessionData Method and parameters are'+
        // ' correlationId-->'+correlationId+
        // ' methodName-->'+methodName+
        // ' values-->'+Json.serialize(values));
        try {
            Map<String,Object> cacheMap = retrieveCache(correlationId);
            cacheMap.putAll(values);
            CacheManager.put(CacheType.SESSION, cacheKey(correlationId), cacheMap);
            if (!updateSessionObject(correlationId, cacheMap)) {
                return false;
            }
        } catch(Exception e) {
            eLogMap.put( 'correlationId', correlationId);
            eLogMap.put( 'elementName', methodName);
            eLogMap.put( 'errorDescription', e.getMessage());
            C2O_Utilities.logException(eLogMap, false);
            // OrderingUtil.logException(CAPABILITY, INTERFACE_NAME, TECHNICAL_ERROR, correlationId, methodName, WARNING, ERROR_CODE, e.getMessage());
            return false;
        }
        // logger.info('Exiting addSessionData Method');
        return true;
    }

    public static Boolean addSessionDataOrder(set<string> correlationId, String methodName, Map<String, Object> values) {
        // logger.Info('Entering addSessionData Method and parameters are'+
        // ' correlationId-->'+correlationId+
        // ' methodName-->'+methodName+
        // ' values-->'+Json.serialize(values));
        try {
            Map<String,Object> cacheMapWithExisting = new Map<String,Object>();
            List<TLS_Session__c> session = getlistOfSessionObject(correlationId);
            List<TLS_Session__c> toUpdate = new List<TLS_Session__c>();
            List<csord__Order__c> listOrder = new List<csord__Order__c>();
            List<csord__Subscription__c> listSubscription = new List<csord__Subscription__c>();
            List<csord__Service__c> listService = new List<csord__Service__c>();
            List<Orchestration_Technical__c> listOrchestration= new List<Orchestration_Technical__c>();
            string strCorrelationId;
            string sObjName;
            for(TLS_Session__c iterator : session){
                cacheMapWithExisting.put(iterator.TLS_CorrelationId__c , iterator.TLS_PayLoad__c);
                System.debug('OC_SessionPayloadValidation ::  addSessionDataOrder :: Found cacheMapWithExisting --->' + cacheMapWithExisting);
            }
            //System.debug('OC_SessionPayloadValidation ::  addSessionDataOrder :: Found cacheMapWithExisting --->' + cacheMapWithExisting);
            for(string iterator : correlationId){
                System.debug('OC_SessionPayloadValidation ::  addSessionDataOrder :: Found iterator --->' + iterator);
                Map<String,Object> cacheMap = new Map<String,Object>();
                //cacheMap.put(iterator,cacheMapWithExisting.get(iterator));
                cacheMap.put(iterator , values.get(iterator));
                CacheManager.put(CacheType.ORG, cacheKey(iterator), cacheMap);
                strCorrelationId = iterator;
            }
            // sObjName = Coms_PlatformCacheUtil.findSObject(strCorrelationId);
            // System.debug('OC_SessionPayloadValidation ::  addSessionDataOrder :: Found sObjName --->' + sObjName);
            for(TLS_Session__c iterator : session){
                System.debug('OC_SessionPayloadValidation ::  addSessionDataOrder :: Found iterator --->' + iterator);
                Map<String,Object> cacheMap = new Map<String,Object>();
                cacheMap.put(iterator.TLS_CorrelationId__c, values.get(iterator.TLS_CorrelationId__c));
                String jsonPayload = JSON.serialize(cacheMap);
                iterator.TLS_PayLoad__c = jsonPayload;
                toUpdate.add(iterator);
                // if(sObjName == 'csord__Order__c'){
                //     listOrder.add(new csord__Order__c(Id =  iterator.TLS_CorrelationId__c , Platform_Cache_Timestamp__c = system.now()));
                // }
                // if(sObjName == 'csord__Subscription__c'){
                //     listSubscription.add(new csord__Subscription__c(CorrelationId__c = iterator.TLS_CorrelationId__c , Platform_Cache_Timestamp__c = system.now()));
                // }
                // if(sObjName == 'csord__Service__c'){
                //     listService.add(new csord__Service__c(CorrelationId__c = iterator.TLS_CorrelationId__c , Platform_Cache_Timestamp__c = system.now()));
                // }
                // if(sObjName == 'Orchestration_Technical__c'){
                //     listOrchestration.add(new Orchestration_Technical__c(CorrelationId__c = iterator.TLS_CorrelationId__c , Platform_Cache_Timestamp__c = system.now()));
                // }
            }
            System.debug('OC_SessionPayloadValidation ::  addSessionDataOrder :: Found toUpdate --->' + toUpdate);
            System.debug('OC_SessionPayloadValidation ::  addSessionDataOrder :: Found listOrder --->' + listOrder);
            update toUpdate;
            // if(!listOrder.isEmpty()){
            //     upsert listOrder CorrelationId__c;
            // }
            // if(!listSubscription.isEmpty()){
            //     upsert listSubscription CorrelationId__c;
            // }
            // if(!listService.isEmpty()){
            //     upsert listService CorrelationId__c;
            // }
            // if(!listOrchestration.isEmpty()){
            //     upsert listOrchestration CorrelationId__c;
            // }
            
            // if (!updateSessionObject(correlationId, cacheMap)) {
            //     return false;
            // }

        } catch(Exception e) {
            eLogMap.put( 'correlationId', correlationId);
            eLogMap.put( 'elementName', methodName);
            eLogMap.put( 'errorDescription', e.getMessage());
            C2O_Utilities.logException(eLogMap, false);
            // OrderingUtil.logException(CAPABILITY, INTERFACE_NAME, TECHNICAL_ERROR, correlationId, methodName, WARNING, ERROR_CODE, e.getMessage());
            return false;
        }
        // logger.info('Exiting addSessionData Method');
        return true;
    }
    
    
    /*******************************************************************************************************
* @description Retrieves all the session data
* @param correlationId Used to identify the session
* @param methodName The executing step
* @return the complete session data, or an empty map if the session data could not be retrieved
* @example
* Map<String, Object> data = OC_SessionPayloadValidation.getSessionField('1234', 'creditAssessment');
*/
    public static Map<String, Object> getSessionData(String correlationId, String methodName) {
        try {
            return retrieveCache(correlationId);
        } catch(Exception e) {
            // logger.Warn('Value for method: ' +methodName+ ' does not exist for corrId: '+correlationId);
            return new Map<String, Object>(); // no session data, so return empty map
        }
    }
    
    public static Map<String, Object> getSessionDataOrder(set<string> correlationId, String methodName) {
        try {
            return retrieveCacheOrder(correlationId);
        } catch(Exception e) {
            // logger.Warn('Value for method: ' +methodName+ ' does not exist for corrId: '+correlationId);
            return new Map<String, Object>(); // no session data, so return empty map
        }
    }
    /*******************************************************************************************************
* @description Retrieves a value previously stored in the session data
* @param correlationId Used to identify the session
* @param methodName The executing step
* @param key The key for retrieving the data from the session cache (or payLoad__c field of the TLS_Session__c object)
* @return the value retrieved from the session data, or null if the session data could not be retrieved
* @example
* String cartId = OC_SessionPayloadValidation.getSessionField('1234', 'creditAssessment', 'cartId');
*/
    public static Object getSessionField(String correlationId, String methodName, String key) {        
        if (!OC_SessionPayloadValidation.sessionExists(correlationId)) {
            return null;
        }
        
        try {
            Map<String,Object> cacheMap = retrieveCache(correlationId);
            return cacheMap.get(key);
        } catch(Exception e) {
            // logger.Warn('Value for key: ' +key+ ' does not exist for corrId: '+correlationId);
            return null;
        }
    }
    
    /*******************************************************************************************************
* @description Marks a step as being completed successfully, or with errors
* @param correlationId Used to identify the session
* @param methodName The name of the step that was executed
* @param success Whether the step completely successfully or with errors
* @return true if the step result was added, false if the session could not be retrieved
* @example
* OC_SessionPayloadValidation.stepResult('1234', 'processPayment', true);
*/
    public static Boolean stepResult(String correlationId, String methodName, Boolean success) {
        return addSessionData(correlationId, methodName, methodName, success ? SUCCESS_RESULT : ERROR_RESULT);
    }
    
    /*******************************************************************************************************
* @description Verifies a previous step has been run, and gave a success response
* @param correlationId Used to identify the session
* @param methodName The executing step
* @param previousStep The name of the step to verify
* @return true if the step has been previously executed with a success result, false otherwise
* @example
* Boolean alreadyPaid = OC_SessionPayloadValidation.verifyPreviousStep('1234', 'submitOrder', 'processPayment');
*/
    public static Boolean verifyPreviousStep(String correlationId, String methodName, String previousStep) {
        return assertEquals(correlationId, methodName, previousStep, SUCCESS_RESULT);
    }
    
    /*******************************************************************************************************
* @description Verifies a key/value pair is matching with a key/value pair stored in the session data
* @param correlationId Used to identify the session
* @param methodName The executing step
* @param key The key for verifying against the session data
* @param value The value for verifying against the session data
* @return true if the key exists in the session data with the same value
* @example
* Boolean alreadyPaid = OC_SessionPayloadValidation.assertEquals('1234', 'submitOrder', 'processPayment', 'Success');
*/
    public static Boolean assertEquals(String correlationId, String methodName, String key, Object expectedValue) {
        try {
            Map<String,Object> cacheMap = retrieveCache(correlationId);
            Object sessionValue = cacheMap.get(key);
            if (expectedValue == sessionValue) {
                return true;
            } else {
                eLogMap.put( 'correlationId', correlationId);
                eLogMap.put( 'elementName', methodName );
                eLogMap.put( 'errorDescription', key + ' mismatch: Expected value = ' + expectedValue + ', Session value = ' + sessionValue);
                C2O_Utilities.logException(eLogMap, false);
                //OrderingUtil.logException(CAPABILITY, INTERFACE_NAME, TECHNICAL_ERROR, correlationId, methodName, WARNING, ERROR_CODE, key + ' mismatch: Expected value = ' + expectedValue + ', Session value = ' + sessionValue);
                return false;
            }
        } catch(Exception e) {
            eLogMap.put( 'correlationId', correlationId);
            eLogMap.put( 'elementName', methodName );
            eLogMap.put( 'errorDescription', e.getMessage());
            C2O_Utilities.logException(eLogMap, false);
            // OrderingUtil.logException(CAPABILITY, INTERFACE_NAME, TECHNICAL_ERROR, correlationId, methodName, WARNING, ERROR_CODE, e.getMessage());
            return false;
        }
    }
    
    /*******************************************************************************************************
* @description Clears the session data from the session cache and the TLS_Payload__c field of the TLS_Session__c object
* @param correlationId Used to identify the session
* @param methodName The executing step
* @return true if the session was successfully cleared, false if correlationId was null or empty string
* @example
* Boolean cleared = OC_SessionPayloadValidation.clearSession('1234', 'submitOrder');
*/
    public static Boolean clearSession(String correlationId, String methodName) {
        if (String.isBlank(correlationId)) {
            eLogMap.put( 'correlationId', correlationId);
            eLogMap.put( 'elementName', methodName);
            eLogMap.put( 'errorDescription', MISSING_CORRELATION_ID_ERROR );
            C2O_Utilities.logException(eLogMap, false);
            // OrderingUtil.logException(CAPABILITY, INTERFACE_NAME, TECHNICAL_ERROR, correlationId, methodName, WARNING, ERROR_CODE, MISSING_CORRELATION_ID_ERROR);
            return false; // Failed: No correlationId found
        }
        
        Map<String, Object> emptyMap = new Map<String, Object>();
        CacheManager.put(CacheType.SESSION, cacheKey(correlationId), emptyMap);
        return updateSessionObject(correlationId, emptyMap);
    }
    
    /*******************************************************************************************************
* @description Refreshes the cache from the session record of the TLS_Session__c object
* @param correlationId Used to identify the session
* @example
* OC_SessionPayloadValidation.refreshSessionCache('1234');
*/
    public static void refreshSessionCache(String correlationId) {
        if (String.isBlank(correlationId)) {
            throw new IllegalArgumentException(MISSING_CORRELATION_ID_ERROR); // Failed: No correlationId found
        }
        
        Object oCache;
        TLS_Session__c session = getSessionObject(correlationId);
        if (session != null) {
            oCache = JSON.deserializeUntyped(session.TLS_PayLoad__c);
            CacheManager.put(CacheType.SESSION, cacheKey(correlationId), oCache);
        }
        if (oCache == null) {
            throw new IllegalArgumentException(NO_CACHE_OR_SESSION_ERROR); // Failed: No cache or session found
        }
    }
    
    /*******************************************************************************************************
* @description merge the two session data which is having two different session names(correlationId and correlationId + methodname)
* @param correlationId Used to identify the session
* @param inputMap Used to get the session name(correlationId + methodname)
* @example
* OC_SessionPayloadValidation.mergeSessionData('1234','1234methodname');
*/
    public static Boolean mergeSessionData(String correlationId, Map<String, Object> inputMap) {
        
        // logger.Info('Entering OC_SessionPayloadValidation.mergeSessionData Method and parameter is inputMap-->'+inputMap);
        List<string> sourceSessions =  (List<string>)inputMap.get('SourceSessions');
        Map<String, Object> finalSessionMap = new Map<String, Object>();
        if(inputMap.size() > 0)
        {
            finalSessionMap.putAll(inputMap);
        }
        try {
            for(String sessionName : sourceSessions)
            {
                Map<String,Object> SessionMap = (Map<String,Object>)getSessionData(correlationId + sessionName,sessionName);
                if(SessionMap.size() > 0)
                {
                    finalSessionMap.putAll(SessionMap); 
                }
                
            }
            boolean isaddsucess = addSessionData(correlationId, 'mergeSessionData', finalSessionMap);
            // logger.Info('Exiting OC_SessionPayloadValidation.mergeSessionData  Method and returning true');        
        } catch (Exception e) {
            // logger.error('mergeSessionData exception details: ' + e.getMessage() +'Stracktrace '+e.getStackTraceString());
            eLogMap.put( 'correlationId', correlationId);
            eLogMap.put( 'errorDescription', e.getMessage() );
            C2O_Utilities.logException(eLogMap, false);
            // OrderingUtil.logException(CAPABILITY, INTERFACE_NAME, TECHNICAL_ERROR, correlationId, 'mergeSessionData', inputMap, WARNING, ERROR_CODE, e.getMessage());
            return false;
        } 
        return true;
    }
    
    private static Map<String, Object> retrieveCache(String correlationId) {
        if (String.isBlank(correlationId)) {
            throw new IllegalArgumentException(MISSING_CORRELATION_ID_ERROR); // Failed: No correlationId found
        }
        
        // retrieves cache/session by correlationId
        Object oCache = null;
        
        if(!isGuestProfile){
            oCache = CacheManager.get(CacheType.SESSION, cacheKey(correlationId));
            System.debug('oCache ---> ' + oCache);
        }
        if (oCache == null) {
            TLS_Session__c session = getSessionObject(correlationId);
            if (session != null) {
                oCache = JSON.deserializeUntyped(session.TLS_PayLoad__c);
                if(!isGuestProfile){
                    CacheManager.put(CacheType.SESSION, cacheKey(correlationId), oCache);
                }
            }
            if (oCache == null) {
                throw new IllegalArgumentException(NO_CACHE_OR_SESSION_ERROR); // Failed: No cache or session found
            }
        }
        return (Map<String, Object>) oCache;
    }
    private static Map<String, Object> retrieveCacheOrder(set<string> correlationId) {
        
        if (correlationId.isEmpty()) {
            throw new IllegalArgumentException(MISSING_CORRELATION_ID_ERROR); // Failed: No correlationId found
        }
        Map<string , object> mapFindRecordsInCache = new Map<string , object>();
        Map<string , object> mapNotFindRecordsInCache = new Map<string , object>();
        // retrieves cache/session by correlationId
        Object oCache = null;

        if(!isGuestProfile){
            for(string sCorrelationId : correlationId){
                oCache = CacheManager.get(CacheType.ORG, cacheKey(sCorrelationId));
                System.debug('oCache ---> ' + oCache);
                if(oCache != null){
                    String jsonPayload = JSON.serialize(oCache);
                    mapFindRecordsInCache.put( sCorrelationId, jsonPayload);
                }else{
                    mapNotFindRecordsInCache.put(sCorrelationId, oCache);
                }
            }
        }
        System.debug('OC_SessionPayloadValidation ::  retrieveCacheOrder :: Found mapFindRecordsInCache --->' + mapFindRecordsInCache);
        System.debug('OC_SessionPayloadValidation ::  retrieveCacheOrder :: Found mapNotFindRecordsInCache --->' + mapNotFindRecordsInCache);

        if (!mapNotFindRecordsInCache.isEmpty()) {
            //TLS_Session__c session = getSessionObject(correlationId);
            List<TLS_Session__c> session =getlistOfSessionObject(mapNotFindRecordsInCache.keySet());
            System.debug('OC_SessionPayloadValidation ::  retrieveCacheOrder :: Found session --->' + session);
            for(TLS_Session__c iterator : session){
                if(!mapFindRecordsInCache.containsKey(iterator.TLS_CorrelationId__c)){
                    mapFindRecordsInCache.put(iterator.TLS_CorrelationId__c , iterator.TLS_PayLoad__c);
                }
            }
            // if (session != null) {
            //     oCache = JSON.deserializeUntyped(mapSession.get(correlationId).TLS_PayLoad__c);
                for(string objCorrelation : mapFindRecordsInCache.keySet()){
                    if(!isGuestProfile){
                        CacheManager.put(CacheType.ORG, cacheKey(objCorrelation), mapFindRecordsInCache.get(objCorrelation));
                    }
                }
            // }
            if (mapFindRecordsInCache.isEmpty()) {
                throw new IllegalArgumentException(NO_CACHE_OR_SESSION_ERROR); // Failed: No cache or session found
            }
            for(string ss : mapNotFindRecordsInCache.keySet()){
                if(!mapFindRecordsInCache.containsKey(ss)){
                    mapFindRecordsInCache.put(ss , null);
                }
            }
        }
        System.debug('OC_SessionPayloadValidation ::  retrieveCacheOrder :: Found mapFindRecordsInCache --->' + mapFindRecordsInCache);
        return mapFindRecordsInCache;
    }

    
    private static TLS_Session__c getSessionObject(String correlationId) {
        List<TLS_Session__c> session = [SELECT Id, TLS_CorrelationId__c, TLS_PayLoad__c FROM TLS_Session__c WHERE TLS_CorrelationId__c = :correlationId LIMIT 1];
        if (session.isEmpty()) {
            return null;
        }
        return (TLS_Session__c) session.get(0);
    }
    
    private static Boolean updateSessionObject(String correlationId, Map<String, Object> cacheMap) {
        TLS_Session__c session = getSessionObject(correlationId);
        if (session == null) {
            return false;
        }
        String jsonPayload = JSON.serialize(cacheMap);
        session.TLS_PayLoad__c = jsonPayload;
        update session;
        return true;
    }
    
    private static String cacheKey(String correlationId) {
        return correlationId.replace('-', '');
    }
    
    private static String getFlowName(Object flow) {
        if (flow instanceof String) {
            return (String) flow;
        }
        return String.valueOf(flow).substringBefore(':');
    }

    private static List<TLS_Session__c> getlistOfSessionObject(set<string> setSeesionids) {
        List<TLS_Session__c> session = [SELECT Id, TLS_CorrelationId__c, TLS_PayLoad__c FROM TLS_Session__c WHERE TLS_CorrelationId__c IN : setSeesionids];
        if (session.isEmpty()) {
            return null;
        }
        return session;
    }
}