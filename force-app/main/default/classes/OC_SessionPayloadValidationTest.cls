/**************
* Description   : Implement tests for functions in OC_SessionPayloadValidation
*
* Version        Date               Author                      Modification
* ----------------------------------------------------------------------------
* 1.0            05/04/2021         Arunkumar V              Created
**************/
@isTest
private class OC_SessionPayloadValidationTest {
    private static String correlationId;
    private static String cacheKey;
    private static MockFlow flow;

    private final static String NO_CACHE_OR_SESSION_ERROR = 'No cache or session found';
    private final static String MISSING_CORRELATION_ID_ERROR = 'No correlationId found';

    private final static String KEY = 'key';
    private final static String VALUE = 'value';
    private final static String KEY1 = 'key1';
    private final static String VALUE1 = 'value1';
    private final static String KEY2 = 'key2';
    private final static String VALUE2 = 'value2';

    @testSetup
    static void initTest() {
        correlationId = '123';//GuidUtil.NewGuid();
        cacheKey = correlationId.replace('-', '');
        flow = new MockFlow();
    }

    static String assertErrorDescription(String key, String expectedValue, String sessionValue) {
        return key + ' mismatch: Expected value = ' + expectedValue + ', Session value = ' + sessionValue;
    }

    @isTest
    static void testCreateSessionMissingCorrelationId() {
        initTest();
        final String methodName = 'testCreateSessionMissingCorrelationId';
        Boolean result = OC_SessionPayloadValidation.createSession('', methodName, flow);
        // Exception_Log__c log = [SELECT Id, Error_Description__c FROM Exception_Log__c WHERE ElementName__c = :methodName];

        System.assertEquals(result, false);
        // System.assertEquals(log.Error_Description__c, MISSING_CORRELATION_ID_ERROR);
    }

    @isTest
    static void testVerifyFlowTrue() {
        initTest();
        final String methodName = 'testVerifyFlowTrue';
        OC_SessionPayloadValidation.createSession(correlationId, methodName, flow);
        Boolean result = OC_SessionPayloadValidation.verifyFlow(correlationId, methodName, flow);

        System.assertEquals(result, true);
    }

    @isTest
    static void testVerifyFlowFalse() {
        initTest();
        final String methodName = 'testVerifyFlowFalse';
        OC_SessionPayloadValidation.createSession(correlationId, methodName, flow);
        AnotherMockFlow flow2 = new AnotherMockFlow();
        Boolean result = OC_SessionPayloadValidation.verifyFlow(correlationId, methodName, flow2);
        // Exception_Log__c log = [SELECT Id, Error_Description__c FROM Exception_Log__c WHERE ElementName__c = :methodName];

        System.assertEquals(result, false);
        // System.assertEquals(log.Error_Description__c, assertErrorDescription('flowName', 'AnotherMockFlow', 'MockFlow'));
    }

    @isTest
    static void testAddSessionDataNotCreated() {
        initTest();
        final String methodName = 'testAddSessionDataNotCreated';
        Boolean result = OC_SessionPayloadValidation.addSessionData(correlationId, methodName, KEY, VALUE);
        // Exception_Log__c log = [SELECT Id, Error_Description__c FROM Exception_Log__c WHERE Correlation_ID__c= :correlationId];

        System.assertEquals(result, false);
        // System.assertEquals(log.Error_Description__c, NO_CACHE_OR_SESSION_ERROR);
    }

    @isTest
    static void testAddSessionData() {
        initTest();
        final String methodName = 'testAddSessionData';

        OC_SessionPayloadValidation.createSession(correlationId, methodName, flow);
        Boolean result1 = OC_SessionPayloadValidation.addSessionData(correlationId, methodName, KEY1, VALUE1);
        Boolean result2 = OC_SessionPayloadValidation.addSessionData(correlationId, methodName, KEY2, VALUE2);

        TLS_Session__c session = [SELECT Id, TLS_PayLoad__c FROM TLS_Session__c WHERE TLS_CorrelationID__c = :correlationId];
        Map<String,Object> sessionObjectMap = (Map<String,Object>) JSON.deserializeUntyped(session.TLS_PayLoad__c);
        Map<String,Object> cacheMap = (Map<String,Object>) CacheManager.get(CacheType.SESSION, cacheKey);

        System.assertEquals(result1, true);
        System.assertEquals(result2, true);
        System.assertEquals(sessionObjectMap.get(KEY1), VALUE1);
        System.assertEquals(sessionObjectMap.get(KEY2), VALUE2);
        //System.assertEquals(cacheMap.get(KEY1), VALUE1);
        //System.assertEquals(cacheMap.get(KEY2), VALUE2);
    }

    @isTest
    static void testGetSessionField() {
        initTest();
        final String methodName = 'testGetSessionField';

        OC_SessionPayloadValidation.createSession(correlationId, methodName, flow);
        OC_SessionPayloadValidation.addSessionData(correlationId, methodName, KEY, VALUE);
        Object result = OC_SessionPayloadValidation.getSessionField(correlationId, methodName, KEY);

        System.assertEquals(result, VALUE);
    }

    @isTest
    static void testVerifyPreviousStep() {
        initTest();
        final String successfulMethod = 'successfulMethod';
        final String failedMethod = 'failedMethod';
        final String methodName = 'testVerifyPreviousStep';

        OC_SessionPayloadValidation.createSession(correlationId, methodName, flow);
        OC_SessionPayloadValidation.stepResult(correlationId, successfulMethod, true);
        OC_SessionPayloadValidation.stepResult(correlationId, failedMethod, false);
        
        System.assertEquals(OC_SessionPayloadValidation.verifyPreviousStep(correlationId, methodName, successfulMethod), true);
        System.assertEquals(OC_SessionPayloadValidation.verifyPreviousStep(correlationId, methodName, failedMethod), false);
    }

    @isTest
    static void testAssertEqualsFalseNotSet() {
        initTest();
        final String methodName = 'testAssertEqualsFalseNotSet';

        OC_SessionPayloadValidation.createSession(correlationId, methodName, flow);
        Boolean result = OC_SessionPayloadValidation.assertEquals(correlationId, methodName, KEY, VALUE);

        // Exception_Log__c log = [SELECT Id, Error_Description__c FROM Exception_Log__c WHERE Correlation_ID__c= :correlationId];

        System.assertEquals(result, false);
        // System.assertEquals(log.Error_Description__c, assertErrorDescription(KEY, VALUE, 'null'));
    }

    @isTest
    static void testAssertEqualsFalseNotEquals() {
        initTest();
        final String methodName = 'testAssertEqualsFalseNotEquals';
        final String wrongValue = 'wrongValue';

        OC_SessionPayloadValidation.createSession(correlationId, methodName, flow);
        OC_SessionPayloadValidation.addSessionData(correlationId, methodName, KEY, wrongValue);
        Boolean result = OC_SessionPayloadValidation.assertEquals(correlationId, methodName, KEY, VALUE);

        // Exception_Log__c log = [SELECT Id, Error_Description__c FROM Exception_Log__c WHERE Correlation_ID__c= :correlationId];

        System.assertEquals(result, false);
        // System.assertEquals(log.Error_Description__c, assertErrorDescription(KEY, VALUE, wrongValue));
    }

    @isTest
    static void testAssertEqualsTrue() {
        initTest();
        final String methodName = 'testAssertEqualsTrue';

        OC_SessionPayloadValidation.createSession(correlationId, methodName, flow);
        OC_SessionPayloadValidation.addSessionData(correlationId, methodName, KEY, VALUE);
        Boolean result = OC_SessionPayloadValidation.assertEquals(correlationId, methodName, KEY, VALUE);

        System.assertEquals(result, true);
    }

    @isTest
    static void testAddSessionDataRegeneratesCache() {
        initTest();
        final String methodName = 'testAddSessionDataRegeneratesCache';

        OC_SessionPayloadValidation.createSession(correlationId, methodName, flow);
        Boolean result = OC_SessionPayloadValidation.addSessionData(correlationId, methodName, KEY1, VALUE1);

        CacheManager.remove(CacheType.SESSION, cacheKey); // destroy cache entry
        Map<String,Object> cacheMap = (Map<String,Object>) CacheManager.get(CacheType.SESSION, cacheKey);

        System.assertEquals(result, true);
        System.assertEquals(cacheMap, null);

        result = OC_SessionPayloadValidation.addSessionData(correlationId, methodName, KEY2, VALUE2);
        // cache should be regenerated by addSessionData
        cacheMap = (Map<String,Object>) CacheManager.get(CacheType.SESSION, cacheKey);

        System.assertEquals(result, true);
        //System.assertEquals(cacheMap.get(KEY1), VALUE1);
        //System.assertEquals(cacheMap.get(KEY2), VALUE2);
    }

    @isTest
    static void testAssertEqualsRegeneratesCache() {
        initTest();
        final String methodName = 'testAssertEqualsRegeneratesCache';

        OC_SessionPayloadValidation.createSession(correlationId, methodName, flow);
        Boolean result = OC_SessionPayloadValidation.addSessionData(correlationId, methodName, KEY, VALUE);

        CacheManager.remove(CacheType.SESSION, cacheKey); // destroy cache entry
        Map<String,Object> cacheMap = (Map<String,Object>) CacheManager.get(CacheType.SESSION, cacheKey);
        System.assertEquals(result, true);
        System.assertEquals(cacheMap, null);

        result = OC_SessionPayloadValidation.assertEquals(correlationId, methodName, KEY, VALUE);
        // cache should be regenerated by assertEquals
        cacheMap = (Map<String,Object>) CacheManager.get(CacheType.SESSION, cacheKey);

        System.assertEquals(result, true);
        //System.assertEquals(cacheMap.get(KEY), VALUE);
    }

    @isTest
    static void testAddSessionDataMap() {
        initTest();
        final String methodName = 'testAddSessionDataMap';
        final Map<String,Object> dataMap = new Map<String,Object> {
            KEY1 => VALUE1,
            KEY2 => VALUE2
        };

        OC_SessionPayloadValidation.createSession(correlationId, methodName, flow);
        Boolean result = OC_SessionPayloadValidation.addSessionData(correlationId, methodName, dataMap);

        TLS_Session__c session = [SELECT Id, TLS_PayLoad__c FROM TLS_Session__c WHERE TLS_CorrelationID__c = :correlationId];
        Map<String,Object> sessionObjectMap = (Map<String,Object>) JSON.deserializeUntyped(session.TLS_PayLoad__c);
        Map<String,Object> cacheMap = (Map<String,Object>) CacheManager.get(CacheType.SESSION, cacheKey);

        System.assertEquals(result, true);
        System.assertEquals(sessionObjectMap.get(KEY1), VALUE1);
       // System.assertEquals(cacheMap.get(KEY1), VALUE1);
    }

    @isTest
    static void testGetSessionData() {
        initTest();
        final String methodName = 'testAddSessionDataMap';
        final Map<String,Object> dataMap = new Map<String,Object> {
            KEY1 => VALUE1,
            KEY2 => VALUE2
        };

        OC_SessionPayloadValidation.createSession(correlationId, methodName, flow);
        OC_SessionPayloadValidation.addSessionData(correlationId, methodName, dataMap);
        Map<String,Object> sessionDataMap = OC_SessionPayloadValidation.getSessionData(correlationId, methodName);

        System.assertEquals(sessionDataMap.get(KEY1), VALUE1);
        System.assertEquals(sessionDataMap.get(KEY2), VALUE2);
    }
 
    @isTest
    static void testSessionExists() {
        initTest();
        final String methodName = 'testSessionExists';

        System.assertEquals(OC_SessionPayloadValidation.sessionExists(correlationId), false);
        OC_SessionPayloadValidation.createSession(correlationId, methodName, flow);
        System.assertEquals(OC_SessionPayloadValidation.sessionExists(correlationId), true);
    }

    @isTest
    static void testGetSessionDataNoSession() {
        initTest();
        final String methodName = 'testGetSessionDataNoSession';

        Map<String,Object> sessionDataMap = OC_SessionPayloadValidation.getSessionData(correlationId, methodName);
        Boolean emptyMap = sessionDataMap.keySet().isEmpty();
        System.assertEquals(emptyMap, true);
    }

    @isTest
    static void testAddSessionDataNoSession() {
        initTest();
        final String methodName = 'testAddSessionDataNoSession';
        final Map<String, Object> dataMap = new Map<String, Object> {
            KEY => VALUE
        };

        Boolean result = OC_SessionPayloadValidation.addSessionData(correlationId, methodName, dataMap);
        System.assertEquals(result, false);
    }

    @isTest
    static void testAssertEqualsNoSession() {
        initTest();
        final String methodName = 'testAssertEqualsNoSession';

        Boolean result = OC_SessionPayloadValidation.assertEquals(correlationId, methodName, KEY, VALUE);
        System.assertEquals(result, false);
    }

   @isTest
    static void testClearSession() {
        initTest();
        final String methodName = 'testClearSession';
        OC_SessionPayloadValidation.createSession(correlationId, methodName, flow);
        List<TLS_Session__c> sessionList = [SELECT Id, TLS_PayLoad__c FROM TLS_Session__c WHERE TLS_CorrelationID__c = :correlationId LIMIT 1];
        System.assertEquals(sessionList.size(), 1);
        
        Boolean result = OC_SessionPayloadValidation.clearSession(correlationId, methodName);
        System.assertEquals(result, true);
        Map<String, Object> sessionData = OC_SessionPayloadValidation.getSessionData(correlationId, methodName);
        System.assertEquals('{}', JSON.serialize(sessionData));
        TLS_Session__c session = [SELECT Id, TLS_PayLoad__c FROM TLS_Session__c WHERE TLS_CorrelationID__c = :correlationId];
        System.assertEquals('{}', session.TLS_Payload__c);
    }

    @isTest
    static void testRefreshSessionCache() {
        initTest();
        final String methodName = 'testRefreshSessionCache';
        final Map<String,Object> dataMap = new Map<String,Object> {
            KEY1 => VALUE1,
            KEY2 => VALUE2
        };
        OC_SessionPayloadValidation.createSession(correlationId, methodName, flow);
        
        TLS_Session__c session = [SELECT Id, TLS_PayLoad__c FROM TLS_Session__c WHERE TLS_CorrelationID__c = :correlationId LIMIT 1];
        String jsonPayload = JSON.serialize(dataMap);
        session.TLS_PayLoad__c = jsonPayload;
        update session;
        
        OC_SessionPayloadValidation.refreshSessionCache(correlationId);
        
        Map<String,Object> cacheMap = (Map<String,Object>) CacheManager.get(CacheType.SESSION, cacheKey);
        //System.assertEquals(cacheMap.get(KEY1), VALUE1);
    }
    
    @isTest
    static void testMergeSessionSuccess(){
        initTest();
        Map<String, Object > inputMap =new Map<String,Object>();
        final String methodName = 'testMergeSessionSuccess';
        final String mergemethodName = 'testMerge';
           Test.startTest();
                OC_SessionPayloadValidation.createSession(correlationId + mergemethodName, methodName, mergemethodName);
                OC_SessionPayloadValidation.addSessionData(correlationId + mergemethodName, methodName, KEY, VALUE);
                inputMap.put('correlationId', correlationId);
                inputMap.put('SourceSessions', new list<String> {mergemethodName});     
                Boolean result = OC_SessionPayloadValidation.mergeSessionData(correlationId, inputMap);
                system.assertEquals(true,result,'mergeSessionData returned sucess');
            Test.stopTest();
    }

    @isTest
    static void testMergeSessionFailure(){
        initTest();
        Map<String, Object > inputMap =new Map<String,Object>();
        final String methodName = 'testMergeSessionFailure';
        final String mergemethodName = 'testMerge';
           Test.startTest();
                OC_SessionPayloadValidation.createSession(correlationId + mergemethodName, methodName, mergemethodName);
                OC_SessionPayloadValidation.addSessionData(correlationId + mergemethodName, methodName, KEY, VALUE);
                inputMap.put('correlationId', correlationId);
                Boolean result = OC_SessionPayloadValidation.mergeSessionData(correlationId, inputMap);
                system.assertEquals(false,result,'mergeSessionData returned failure');
            Test.stopTest();
    }

    private class MockFlow {
    }

    private class AnotherMockFlow {
    }
}