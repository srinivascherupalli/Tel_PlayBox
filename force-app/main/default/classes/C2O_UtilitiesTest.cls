@isTest
global class C2O_UtilitiesTest {
    private static Map<String, Object> eLogMap = new Map<String, Object>();
    private static String correlationId;
    private static String elementName;
    private static String referenceNumber;
    private static String errorDescription;
    private static String businessDescription;
    private static final String DEFAULT_LOGEX_SEVERITY = '3';
    private static final String CONST_INTERFACENAME = 'UtilityTest';
    private static final String CONST_INVALID = 'INVALID';
    private static final String CONST_SOURCENAME = 'OTHERS';
    private static final String CONST_ERRORCODE = '400';
    private static final String CONST_ERRORCATEGORY = 'Technical';
    private static final String CONST_NA = 'N/A';
    private static final String CONST_NP = 'NOT PROVIDED';
    private static final String CONST_ERRORDESCRIPTION_PREFIX = 'Exception occurred in ';
    
    @isTest
    static void logExceptionTest_minimal() {
        correlationId = GuidUtil.NewGuid();
        elementName = 'logExceptionTest_minimal';
        referenceNumber = '0903211722';
        errorDescription = CONST_ERRORDESCRIPTION_PREFIX + CONST_INTERFACENAME + '.' + elementName + '()';
        businessDescription = 'Test Exception Handling Framework with minimal required info';
        
        eLogMap.put('interfaceName', CONST_INTERFACENAME);
        eLogMap.put('elementName', elementName);
        eLogMap.put('referenceNumber', referenceNumber);
        eLogMap.put('correlationId', correlationId);
        eLogMap.put('businessDescription', businessDescription);
        
        Test.startTest();
        C2O_Utilities.logException(eLogMap, false);
        List<Exception_Log__c> eLogRecord = [SELECT Severity__c, Interface_Name__c, ElementName__c, ReferenceInfo__c, Capability__c, End_Point_URL__c, Integration_Payload__c, Correlation_ID__c, HTTP_Status_Code__c, ErrorCode__c, Error_Description__c, ResponseMessage__c, Destination_System__c, Source_Name__c, Business_Description__c, ErrorCategory__c FROM Exception_Log__c WHERE Correlation_ID__c = :correlationId];
        System.assertEquals(DEFAULT_LOGEX_SEVERITY, String.valueOf(eLogRecord[0].Severity__c), '[logExceptionTest_minimal] Severity__c expected: ' + DEFAULT_LOGEX_SEVERITY + ' | actual: ' + eLogRecord[0].Severity__c);
        System.assertEquals(CONST_INTERFACENAME, String.valueOf(eLogRecord[0].Interface_Name__c), '[logExceptionTest_minimal] Interface_Name__c expected: ' + CONST_INTERFACENAME + ' | actual: ' + eLogRecord[0].Interface_Name__c);
        System.assertEquals(elementName, String.valueOf(eLogRecord[0].ElementName__c), '[logExceptionTest_minimal] ElementName__c expected: ' + elementName + ' | actual: ' + eLogRecord[0].ElementName__c);
        System.assertEquals(referenceNumber, String.valueOf(eLogRecord[0].ReferenceInfo__c), '[logExceptionTest_minimal] ReferenceInfo__c expected: ' + referenceNumber + ' | actual: ' + eLogRecord[0].ReferenceInfo__c);
        System.assertEquals(CONST_INVALID, String.valueOf(eLogRecord[0].Capability__c), '[logExceptionTest_minimal] Capability__c expected: ' + CONST_INVALID + ' | actual: ' + eLogRecord[0].Capability__c);
        System.assertEquals(CONST_NA, String.valueOf(eLogRecord[0].End_Point_URL__c), '[logExceptionTest_minimal] End_Point_URL__c expected: ' + CONST_NA + ' | actual: ' + eLogRecord[0].End_Point_URL__c);
        System.assertEquals(CONST_NA, String.valueOf(eLogRecord[0].Integration_Payload__c), '[logExceptionTest_minimal] Integration_Payload__c expected: ' + CONST_NA + ' | actual: ' + eLogRecord[0].Integration_Payload__c);
        System.assertEquals(CONST_NA, String.valueOf(eLogRecord[0].HTTP_Status_Code__c), '[logExceptionTest_minimal] HTTP_Status_Code__c expected: ' + CONST_NA + ' | actual: ' + eLogRecord[0].HTTP_Status_Code__c);
        System.assertEquals(CONST_ERRORCODE, String.valueOf(eLogRecord[0].ErrorCode__c), '[logExceptionTest_minimal] ErrorCode__c expected: ' + CONST_ERRORCODE + ' | actual: ' + eLogRecord[0].ErrorCode__c);
        System.assertEquals(errorDescription, String.valueOf(eLogRecord[0].Error_Description__c), '[logExceptionTest_minimal] Error_Description__c expected: ' + errorDescription + ' | actual: ' + eLogRecord[0].Error_Description__c);
        System.assertEquals(CONST_NA, String.valueOf(eLogRecord[0].ResponseMessage__c), '[logExceptionTest_minimal] ResponseMessage__c expected: ' + CONST_NA + ' | actual: ' + eLogRecord[0].ResponseMessage__c);
        System.assertEquals(CONST_NA, String.valueOf(eLogRecord[0].Destination_System__c), '[logExceptionTest_minimal] Destination_System__c expected: ' + CONST_NA + ' | actual: ' + eLogRecord[0].Destination_System__c);
        System.assertEquals(CONST_SOURCENAME, String.valueOf(eLogRecord[0].Source_Name__c), '[logExceptionTest_minimal] Source_Name__c expected: ' + CONST_SOURCENAME + ' | actual: ' + eLogRecord[0].Source_Name__c);
        System.assertEquals(businessDescription, String.valueOf(eLogRecord[0].Business_Description__c), '[logExceptionTest_minimal] Business_Description__c expected: ' + businessDescription + ' | actual: ' + eLogRecord[0].Business_Description__c);
        System.assertEquals(CONST_ERRORCATEGORY, String.valueOf(eLogRecord[0].ErrorCategory__c), '[logExceptionTest_minimal] ErrorCategory__c expected: ' + CONST_ERRORCATEGORY + ' | actual: ' + eLogRecord[0].ErrorCategory__c);
        Test.stopTest();
    }
    
    @isTest
    static void logExceptionTest_apiNotProvided() {
        correlationId = GuidUtil.NewGuid();
        elementName = 'logExceptionTest_apiNotProvided';
        referenceNumber = '0903211829';
        errorDescription = CONST_ERRORDESCRIPTION_PREFIX + CONST_INTERFACENAME + '.' + elementName + '()';
        businessDescription = 'Test Exception Handling Framework with hasAPICall set to true but no details given';
        
        eLogMap.put('interfaceName', CONST_INTERFACENAME);
        eLogMap.put('elementName', elementName);
        eLogMap.put('referenceNumber', referenceNumber);
        eLogMap.put('correlationId', correlationId);
        eLogMap.put('businessDescription', businessDescription);
        
        Test.startTest();
        C2O_Utilities.logException(eLogMap, true);
        List<Exception_Log__c> eLogRecord = [SELECT Severity__c, Interface_Name__c, ElementName__c, ReferenceInfo__c, Capability__c, End_Point_URL__c, Integration_Payload__c, Correlation_ID__c, HTTP_Status_Code__c, ErrorCode__c, Error_Description__c, ResponseMessage__c, Destination_System__c, Source_Name__c, Business_Description__c, ErrorCategory__c FROM Exception_Log__c WHERE Correlation_ID__c = :correlationId];
        System.assertEquals(DEFAULT_LOGEX_SEVERITY, String.valueOf(eLogRecord[0].Severity__c), '[logExceptionTest_minimal] Severity__c expected: ' + DEFAULT_LOGEX_SEVERITY + ' | actual: ' + eLogRecord[0].Severity__c);
        System.assertEquals(CONST_INTERFACENAME, String.valueOf(eLogRecord[0].Interface_Name__c), '[logExceptionTest_minimal] Interface_Name__c expected: ' + CONST_INTERFACENAME + ' | actual: ' + eLogRecord[0].Interface_Name__c);
        System.assertEquals(elementName, String.valueOf(eLogRecord[0].ElementName__c), '[logExceptionTest_minimal] ElementName__c expected: ' + elementName + ' | actual: ' + eLogRecord[0].ElementName__c);
        System.assertEquals(referenceNumber, String.valueOf(eLogRecord[0].ReferenceInfo__c), '[logExceptionTest_minimal] ReferenceInfo__c expected: ' + referenceNumber + ' | actual: ' + eLogRecord[0].ReferenceInfo__c);
        System.assertEquals(CONST_INVALID, String.valueOf(eLogRecord[0].Capability__c), '[logExceptionTest_minimal] Capability__c expected: ' + CONST_INVALID + ' | actual: ' + eLogRecord[0].Capability__c);
        System.assertEquals(CONST_NP, String.valueOf(eLogRecord[0].End_Point_URL__c), '[logExceptionTest_minimal] End_Point_URL__c expected: ' + CONST_NP + ' | actual: ' + eLogRecord[0].End_Point_URL__c);
        System.assertEquals(CONST_NP, String.valueOf(eLogRecord[0].Integration_Payload__c), '[logExceptionTest_minimal] Integration_Payload__c expected: ' + CONST_NP + ' | actual: ' + eLogRecord[0].Integration_Payload__c);
        System.assertEquals(CONST_NP, String.valueOf(eLogRecord[0].HTTP_Status_Code__c), '[logExceptionTest_minimal] HTTP_Status_Code__c expected: ' + CONST_NP + ' | actual: ' + eLogRecord[0].HTTP_Status_Code__c);
        System.assertEquals(CONST_ERRORCODE, String.valueOf(eLogRecord[0].ErrorCode__c), '[logExceptionTest_minimal] ErrorCode__c expected: ' + CONST_ERRORCODE + ' | actual: ' + eLogRecord[0].ErrorCode__c);
        System.assertEquals(errorDescription, String.valueOf(eLogRecord[0].Error_Description__c), '[logExceptionTest_minimal] Error_Description__c expected: ' + errorDescription + ' | actual: ' + eLogRecord[0].Error_Description__c);
        System.assertEquals(CONST_NP, String.valueOf(eLogRecord[0].ResponseMessage__c), '[logExceptionTest_minimal] ResponseMessage__c expected: ' + CONST_NP + ' | actual: ' + eLogRecord[0].ResponseMessage__c);
        System.assertEquals(CONST_NP, String.valueOf(eLogRecord[0].Destination_System__c), '[logExceptionTest_minimal] Destination_System__c expected: ' + CONST_NP + ' | actual: ' + eLogRecord[0].Destination_System__c);
        System.assertEquals(CONST_SOURCENAME, String.valueOf(eLogRecord[0].Source_Name__c), '[logExceptionTest_minimal] Source_Name__c expected: ' + CONST_SOURCENAME + ' | actual: ' + eLogRecord[0].Source_Name__c);
        System.assertEquals(businessDescription, String.valueOf(eLogRecord[0].Business_Description__c), '[logExceptionTest_minimal] Business_Description__c expected: ' + businessDescription + ' | actual: ' + eLogRecord[0].Business_Description__c);
        System.assertEquals(CONST_ERRORCATEGORY, String.valueOf(eLogRecord[0].ErrorCategory__c), '[logExceptionTest_minimal] ErrorCategory__c expected: ' + CONST_ERRORCATEGORY + ' | actual: ' + eLogRecord[0].ErrorCategory__c);
        Test.stopTest();
    }
    
    @isTest
    static void logExceptionTest_all() {
        String severity = '1';
        String capability = 'Basket';
        String endpointURL = 'https://www.salesforce.com/';
        String integrationPayload = '{"data":{"param":"integrationPayload"}}';
        String httpStatusCode = '500';
        String responseMessage = '{"data":{"success":false}}';
        String destinationSystem = 'Heroku';
        String sourceName = 'AGENT';
        String errorCategory = 'Functional';
        errorDescription = 'failure';
        
        correlationId = GuidUtil.NewGuid();
        elementName = 'logExceptionTest_apiNotProvided';
        referenceNumber = '0903211912';
        businessDescription = 'Test Exception Handling Framework with all info provided';
        
        eLogMap.put('severity', C2O_ExceptionHandler.Severity.CRITICAL);
        eLogMap.put('interfaceName', CONST_INTERFACENAME);
        eLogMap.put('elementName', elementName);
        eLogMap.put('referenceNumber', referenceNumber);
        eLogMap.put('capability', C2O_ExceptionHandler.Capability.BSK);
        eLogMap.put('endpointURL', endpointURL);
        eLogMap.put('integrationPayload', integrationPayload);
        eLogMap.put('correlationId', correlationId);
        eLogMap.put('httpStatusCode', httpStatusCode);
        eLogMap.put('errorCode', httpStatusCode);
        eLogMap.put('errorDescription', 'failure');
        eLogMap.put('responseMessage', responseMessage);
        eLogMap.put('destinationSystem', destinationSystem);
        eLogMap.put('sourceName', C2O_ExceptionHandler.SourceName.AGENT);
        eLogMap.put('businessDescription', businessDescription);
        eLogMap.put('errorCategory', errorCategory);
        
        Test.startTest();
        C2O_Utilities.logException(eLogMap, true);
        List<Exception_Log__c> eLogRecord = [SELECT Severity__c, Interface_Name__c, ElementName__c, ReferenceInfo__c, Capability__c, End_Point_URL__c, Integration_Payload__c, Correlation_ID__c, HTTP_Status_Code__c, ErrorCode__c, Error_Description__c, ResponseMessage__c, Destination_System__c, Source_Name__c, Business_Description__c, ErrorCategory__c FROM Exception_Log__c WHERE Correlation_ID__c = :correlationId];
        System.assertEquals(severity, String.valueOf(eLogRecord[0].Severity__c), '[logExceptionTest_minimal] Severity__c expected: ' + severity + ' | actual: ' + eLogRecord[0].Severity__c);
        System.assertEquals(CONST_INTERFACENAME, String.valueOf(eLogRecord[0].Interface_Name__c), '[logExceptionTest_minimal] Interface_Name__c expected: ' + CONST_INTERFACENAME + ' | actual: ' + eLogRecord[0].Interface_Name__c);
        System.assertEquals(elementName, String.valueOf(eLogRecord[0].ElementName__c), '[logExceptionTest_minimal] ElementName__c expected: ' + elementName + ' | actual: ' + eLogRecord[0].ElementName__c);
        System.assertEquals(referenceNumber, String.valueOf(eLogRecord[0].ReferenceInfo__c), '[logExceptionTest_minimal] ReferenceInfo__c expected: ' + referenceNumber + ' | actual: ' + eLogRecord[0].ReferenceInfo__c);
        System.assertEquals(capability, String.valueOf(eLogRecord[0].Capability__c), '[logExceptionTest_minimal] Capability__c expected: ' + capability + ' | actual: ' + eLogRecord[0].Capability__c);
        System.assertEquals(endpointURL, String.valueOf(eLogRecord[0].End_Point_URL__c), '[logExceptionTest_minimal] End_Point_URL__c expected: ' + endpointURL + ' | actual: ' + eLogRecord[0].End_Point_URL__c);
        System.assertEquals(integrationPayload.escapeHtml4(), String.valueOf(eLogRecord[0].Integration_Payload__c), '[logExceptionTest_minimal] Integration_Payload__c expected: ' + integrationPayload.escapeHtml4() + ' | actual: ' + eLogRecord[0].Integration_Payload__c);
        System.assertEquals(httpStatusCode, String.valueOf(eLogRecord[0].HTTP_Status_Code__c), '[logExceptionTest_minimal] HTTP_Status_Code__c expected: ' + httpStatusCode + ' | actual: ' + eLogRecord[0].HTTP_Status_Code__c);
        System.assertEquals(httpStatusCode, String.valueOf(eLogRecord[0].ErrorCode__c), '[logExceptionTest_minimal] ErrorCode__c expected: ' + httpStatusCode + ' | actual: ' + eLogRecord[0].ErrorCode__c);
        System.assertEquals(errorDescription, String.valueOf(eLogRecord[0].Error_Description__c), '[logExceptionTest_minimal] Error_Description__c expected: ' + errorDescription + ' | actual: ' + eLogRecord[0].Error_Description__c);
        System.assertEquals(responseMessage, String.valueOf(eLogRecord[0].ResponseMessage__c), '[logExceptionTest_minimal] ResponseMessage__c expected: ' + responseMessage + ' | actual: ' + eLogRecord[0].ResponseMessage__c);
        System.assertEquals(destinationSystem, String.valueOf(eLogRecord[0].Destination_System__c), '[logExceptionTest_minimal] Destination_System__c expected: ' + destinationSystem + ' | actual: ' + eLogRecord[0].Destination_System__c);
        System.assertEquals(sourceName, String.valueOf(eLogRecord[0].Source_Name__c), '[logExceptionTest_minimal] Source_Name__c expected: ' + sourceName + ' | actual: ' + eLogRecord[0].Source_Name__c);
        System.assertEquals(businessDescription, String.valueOf(eLogRecord[0].Business_Description__c), '[logExceptionTest_minimal] Business_Description__c expected: ' + businessDescription + ' | actual: ' + eLogRecord[0].Business_Description__c);
        System.assertEquals(errorCategory, String.valueOf(eLogRecord[0].ErrorCategory__c), '[logExceptionTest_minimal] ErrorCategory__c expected: ' + errorCategory + ' | actual: ' + eLogRecord[0].ErrorCategory__c);
        Test.stopTest();
    }
    
    @isTest
    static void logExceptionTest_exception() {
        correlationId = GuidUtil.NewGuid();
        elementName = 'logExceptionTest_exception';
        referenceNumber = '0903211729';
        errorDescription = CONST_ERRORDESCRIPTION_PREFIX + CONST_INTERFACENAME + '.' + elementName + '()';
        businessDescription = 'Test Exception Handling Framework with exception handling';
        
        eLogMap.put('interfaceName', CONST_INTERFACENAME);
        eLogMap.put('elementName', elementName);
        eLogMap.put('referenceNumber', referenceNumber);
        eLogMap.put('correlationId', correlationId);
        eLogMap.put('businessDescription', businessDescription);
        eLogMap.put('errorCode', '12345678901234567890123456789012345678901');
        
        Test.startTest();
        C2O_Utilities.logException(eLogMap, false);
        List<Exception_Log__c> eLogRecord = [SELECT Id FROM Exception_Log__c WHERE Correlation_ID__c = :correlationId];
        System.assertNotEquals(1, eLogRecord.size(), 'Exception handling scenario');
        Test.stopTest();
    }
}