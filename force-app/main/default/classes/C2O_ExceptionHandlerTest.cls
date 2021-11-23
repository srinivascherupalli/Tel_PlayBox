@isTest
global class C2O_ExceptionHandlerTest {
    private static String correlationId;
    
    @isTest
    static void createExceptionLogTest_valid() {
        correlationId = GuidUtil.NewGuid();
        C2O_ExceptionHandler.ExceptionHandlerWrapper eLogParams = new C2O_ExceptionHandler.ExceptionHandlerWrapper();
        eLogParams = prepParams(eLogParams, correlationId);
        
        Test.startTest();
        C2O_ExceptionHandler.createExceptionLog(eLogParams);
        List<Exception_Log__c> eLogRecord = [SELECT Id FROM Exception_Log__c WHERE Correlation_ID__c = :correlationId AND Severity__c = '2' AND Capability__c = 'Basket' AND Source_Name__c = 'OTHERS'];
        System.assertEquals(1, eLogRecord.size(), 'Exception Log creation for all valid scenario');
        Test.stopTest();
    }

    @isTest
    static void createExceptionLogTest_invalidSeverity() {
        correlationId = GuidUtil.NewGuid();
        C2O_ExceptionHandler.ExceptionHandlerWrapper eLogParams = new C2O_ExceptionHandler.ExceptionHandlerWrapper();
        eLogParams = prepParams(eLogParams, correlationId);
        eLogParams.severity = C2O_ExceptionHandler.Severity.INVALID;
        
        Test.startTest();
        C2O_ExceptionHandler.createExceptionLog(eLogParams);
        List<Exception_Log__c> eLogRecord = [SELECT Id FROM Exception_Log__c WHERE Correlation_ID__c = :correlationId AND Severity__c = 'INVALID' AND Capability__c = 'Basket' AND Source_Name__c = 'OTHERS'];
        System.assertEquals(1, eLogRecord.size(), 'Exception Log creation for invalid Severity scenario');
        Test.stopTest();
    }

    @isTest
    static void createExceptionLogTest_invalidCapabilityCode() {
        correlationId = GuidUtil.NewGuid();
        C2O_ExceptionHandler.ExceptionHandlerWrapper eLogParams = new C2O_ExceptionHandler.ExceptionHandlerWrapper();
        eLogParams = prepParams(eLogParams, correlationId);
        eLogParams.capability = NULL;
        
        Test.startTest();
        C2O_ExceptionHandler.createExceptionLog(eLogParams);
        List<Exception_Log__c> eLogRecord = [SELECT Id FROM Exception_Log__c WHERE Correlation_ID__c = :correlationId AND Severity__c = '2' AND Capability__c = 'INVALID' AND Source_Name__c = 'OTHERS'];
        System.assertEquals(1, eLogRecord.size(), 'Exception Log creation for invalid Capability Code scenario');
        Test.stopTest();
    }

    @isTest
    static void createExceptionLogTest_unmappedCapabilityCode() {
        correlationId = GuidUtil.NewGuid();
        C2O_ExceptionHandler.ExceptionHandlerWrapper eLogParams = new C2O_ExceptionHandler.ExceptionHandlerWrapper();
        eLogParams = prepParams(eLogParams, correlationId);
        eLogParams.capability = C2O_ExceptionHandler.Capability.NOVAL;
        
        Test.startTest();
        C2O_ExceptionHandler.createExceptionLog(eLogParams);
        List<Exception_Log__c> eLogRecord = [SELECT Id FROM Exception_Log__c WHERE Correlation_ID__c = :correlationId AND Severity__c = '2' AND Capability__c = 'NOVAL' AND Source_Name__c = 'OTHERS'];
        System.assertEquals(1, eLogRecord.size(), 'Exception Log creation for unmapped Capability Code scenario');
        Test.stopTest();
    }

    @isTest
    static void createExceptionLogTest_exceptionErrorCode() {
        correlationId = GuidUtil.NewGuid();
        C2O_ExceptionHandler.ExceptionHandlerWrapper eLogParams = new C2O_ExceptionHandler.ExceptionHandlerWrapper();
        eLogParams = prepParams(eLogParams, correlationId);
        eLogParams.errorCode = '12345678901234567890123456789012345678901';
        
        Test.startTest();
        C2O_ExceptionHandler.createExceptionLog(eLogParams);
        List<Exception_Log__c> eLogRecord = [SELECT Id FROM Exception_Log__c WHERE Correlation_ID__c = :correlationId AND Severity__c = '2' AND Capability__c = 'INVALID' AND Source_Name__c = 'OTHERS'];
        System.assertNotEquals(1, eLogRecord.size(), 'Exception handling scenario');
        Test.stopTest();
    }

    static C2O_ExceptionHandler.ExceptionHandlerWrapper prepParams(C2O_ExceptionHandler.ExceptionHandlerWrapper eLogParams, String correlationId) {
        eLogParams.severity = C2O_ExceptionHandler.Severity.HIGH;
        eLogParams.interfaceName = 'Apex Unit Test';
        eLogParams.elementName = 'createExceptionLogTest';
        eLogParams.referenceNumber = '030320211120';
        eLogParams.capability = C2O_ExceptionHandler.Capability.BSK;
        eLogParams.endpointURL = 'https://www.salesforce.com/';
        eLogParams.integrationPayload = '{"data":{"param":"integrationPayload"}}';
        eLogParams.correlationId = correlationId;
        eLogParams.httpStatusCode = '500';
        eLogParams.errorCode = '500';
        eLogParams.errorDescription = 'Apex Unit Test Error Description';
        eLogParams.responseMessage = '{"data":{"success":false}}';
        eLogParams.destinationSystem = 'Heroku';
        eLogParams.sourceName = C2O_ExceptionHandler.SourceName.OTHERS;
        eLogParams.businessDescription = 'Apex Unit Test coverage for Exception Handling framework';
        eLogParams.errorCategory = 'Functional';
        return eLogParams;
    }
    
}