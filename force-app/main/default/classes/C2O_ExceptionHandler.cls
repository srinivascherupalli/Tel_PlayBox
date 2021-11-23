global class C2O_ExceptionHandler {
    private static final String CONST_INVALID = 'INVALID';

    /** 
    * @description To allow only specified Severity codes to be used while creating Exception Log Record
    * Do NOT change the sequence of values defined in enum as their positioning is used to define the severity
    * INVALID  --> 0
    * CRITICAL --> 1
    * HIGH     --> 2
    * MEDIUM   --> 3
    * LOW      --> 4
    */
    public enum Severity {
        INVALID, CRITICAL, HIGH, MEDIUM, LOW   
    }

    /** 
    * @description To allow only specified Capability codes to be used while creating Exception Log Record
    * INVALID will be used when incorrect Capability code is provided
    * NOVAL is for Apex Unit Test Coverage purposes only
    */
    public enum Capability {

        BSK, CON, OPP, ORD, OC, PRD, QUO, SOL, NOVAL,SYS_TRG,AGR

    }

    /** 
    * @description To allow only specified Source Name values to be used while creating Exception Log Record
    * INVALID will be used when incorrect Source Name is provided
    */
    public enum SourceName {
        AGENT, OTHERS
    }
    
    global class ExceptionHandlerWrapper {
        global Severity severity;
        global String interfaceName;
        global String elementName;
        global String referenceNumber;
        global Capability capability;
        global String endpointURL;
        global String integrationPayload;
        global String correlationId;
        global String httpStatusCode;
        global String errorCode;
        global String errorDescription;
        global String responseMessage;
        global String destinationSystem;
        global SourceName sourceName;
        global String businessDescription;
        global String errorCategory;
    }
    
    public static void createExceptionLog(ExceptionHandlerWrapper logParams) {
        String capabilityCode;
        Exception_Log__c exceptionLog = new Exception_Log__c();
        List<Exception_Log__c> exceptionLogInsert = new List<Exception_Log__c>();
        
        if (String.isNotBlank(String.valueOf(logParams.capability))) {
            List<TicketGroup__mdt> ticketGroup = [SELECT DeveloperName FROM TicketGroup__mdt WHERE Code__c = :String.valueOf(logParams.capability) LIMIT 1];
            capabilityCode = (!ticketGroup.isEmpty()) ? ticketGroup[0].developerName : String.valueOf(logParams.capability);
        } else {
            capabilityCode = CONST_INVALID;
        }
        exceptionLog.Severity__c = (String.valueOf(logParams.severity.ordinal()) == '0') ? CONST_INVALID : String.valueOf(logParams.severity.ordinal());
        exceptionLog.Interface_Name__c = logParams.interfaceName;
        exceptionLog.ElementName__c = logParams.elementName;
        exceptionLog.ReferenceInfo__c = logParams.referenceNumber;
        exceptionLog.Capability__c = capabilityCode;
        exceptionLog.End_Point_URL__c = logParams.endpointURL;
        exceptionLog.Integration_Payload__c = logParams.integrationPayload;
        exceptionLog.Correlation_ID__c = logParams.correlationId;
        exceptionLog.HTTP_Status_Code__c = logParams.httpStatusCode;
        exceptionLog.ErrorCode__c = logParams.errorCode;
        exceptionLog.Error_Description__c = logParams.errorDescription;
        exceptionLog.ResponseMessage__c = logParams.responseMessage;
        exceptionLog.Destination_System__c = logParams.destinationSystem;
        exceptionLog.Source_Name__c = String.valueOf(logParams.sourceName);
        exceptionLog.Business_Description__c = logParams.businessDescription;
        exceptionLog.ErrorCategory__c = logParams.errorCategory;
        exceptionLog.ExceptionUUID__c = logParams.correlationId;
        exceptionLogInsert.add(exceptionLog);
        
        try {
            if (!exceptionLogInsert.isEmpty()) {
                insert exceptionLogInsert;
                //LogPlatformEvent('ExceptionLogCreation',exceptionLog);
            }
        } catch (Exception e) {
            System.debug('Exception occurred in ExceptionHandler.createExceptionLog(): ' + e.getMessage());
        }
    }

    /**
     * @description Method to create Platform Event for Severity 1 & 2 Exceptions that gets logged
     */ 
    /*public static void LogPlatformEvent(String type, Exception_Log__c exceptionLog) {
        List<ExceptionLog__e> events = new List<ExceptionLog__e>();
        List<Event__mdt> custData = new List<Event__mdt>([SELECT EventKey__c, SystemId__c, Version__c, Label, resourceURI__c
                                                        FROM  Event__mdt
                                                        WHERE DeveloperName = :type]);
        
        if (!custData.isEmpty() && custData.size() > 0) {
            if (String.isNotBlank(exceptionLog.Capability__c) && String.isNotBlank(exceptionLog.Severity__c) && ((String.valueOf(exceptionLog.Severity__c) > '0') && (String.valueOf(exceptionLog.Severity__c) <= '2'))) {
                ExceptionLog__e e = new ExceptionLog__e();
                e.Severity__c = Integer.ValueOf(exceptionLog.Severity__c);
                e.InterfaceName__c = exceptionLog.Interface_Name__c;
                e.ErrorDescription__c = exceptionLog.Error_Description__c;
                e.Capability__c = exceptionLog.Capability__c;
                e.ElementName__c = exceptionLog.ElementName__c;
                e.ErrorCategory__c = exceptionLog.ErrorCategory__c;
                e.ErrorCode__c = exceptionLog.ErrorCode__c;
                e.IntegrationPayload__c = exceptionLog.Integration_Payload__c;
                e.CorrelationId__c = exceptionLog.Correlation_ID__c;
                e.ExceptionUUID__c = exceptionLog.ExceptionUUID__c ;
                e.SystemId__c = custData[0].SystemId__c;
                e.EventKey__c = custData[0].EventKey__c;
                e.Version__c = custData[0].Version__c;
                events.add(e);
            }
            
            if (!events.isEmpty() && events.size() > 0) {
                //system.debug('PRINT Before published Exception Log event--' + events);
                List<Database.SaveResult> results = EventBus.publish(events);
                //system.debug('PRINT Successfully  Exception Log event--'+results);
            } else {
                system.Debug(LoggingLevel.ERROR, 'EventList is empty');
            }
        }
    }*/
}