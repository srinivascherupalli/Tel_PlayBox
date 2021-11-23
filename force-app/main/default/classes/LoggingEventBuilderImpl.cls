/**
* @description Logging builder
*
* @author   Anup Kabra
* @version  1.0
* @since    21/05/2020
* @link     https://git02.ae.sda.corp.telstra.com/projects/SBC/repos/b2c-common-dx/browse
*/
public class LoggingEventBuilderImpl implements LoggingEventBuilder {

    private String loggerName;
    private LoggingLevel level;
    private Map<String, Object> properties;
    private Exception ex;
    public String message;
    private static String EMAIL                = 'Email';
    private static String TECHNICAL            = 'Technical';
    private static String INTERFACE_NAME       = 'LoggingEventBuilderImpl';
    private static String DESTINATION_SYSTEM   = 'Transaction Logging';
    private static String BUSINESS_DESCRIPTION = 'Exception while masking PII data';
    private static Set<String> emailKeyWords = new Set<String>();
    private static List<String> keyWordsFromMetadata = new List<String>();
    @testvisible
    private boolean throwTestException = false;
 
    /**
     * @description constructor.
     */
    public LoggingEventBuilderImpl() {
        this.level = LoggingLevel.NONE;
        this.properties = new Map<String, Object>();
    }

    /**
     * @description adds a property to the log event
     * @param key the key
     * @param value the value
     * @return itself
     */
    public LoggingEventBuilder property(String key, Object value) {
        this.properties.put(key, value);
        return this;
    }

    /**
     * @description adds an exception to the log
     * @param exc the exception
     * @return itself
     */
    public LoggingEventBuilder exception(Exception exc) {
        this.ex = exc;
        return this;
    }

    /**
     * @description write and dispatch the log without a message
     */
    public void write() {
       LoggerFactory.dispatch(this.level, this.getContent());
    }

    /**
     * @description write, mask and dispatch the log with a message
     * @param message the log message
     */
    public void write(string message) {
        List<String> messageFromObject = new List<String>();
        List<String> messageFromString = new List<String>();
        try{
           /* if(keyWordsFromMetadata.isEmpty()){
                for(PII_Data_Mask_Keyword__mdt keywordList : [select Id,label,keywordDefiner__c,Enable__c from PII_Data_Mask_Keyword__mdt where Enable__c = True]){
                    if(keywordList.keywordDefiner__c == EMAIL){
                        emailKeyWords.add(keywordList.label.tolowercase());
                    }
                    keyWordsFromMetadata.add(keywordList.label);
                }
            }
         
            if(!keyWordsFromMetadata.isEmpty()){
                String regexValue = '(?i)[\"]?__replaceme__[\"]?\\s*(([=:]\\s*([\"])(?:(?=(\\\\?))\\4.)*?\\3)|[=:]\\s*([\\+\\*\\w-@\\.]+))';
                for(string keyWordsToMatch : keyWordsFromMetadata){
                Pattern logEntry = Pattern.compile(regexValue.replace('__replaceme__', keyWordsToMatch));
                Matcher matchPattern = logEntry.matcher(message);
                    while(matchPattern.find()) {
                        messageFromObject = matchPattern.group(0).split('=');
                        if(messageFromObject.size() == 2) {
                            if(emailKeyWords.contains(messageFromObject[0].tolowercase())){
                                message = maskEmail(message, messageFromObject[1], False);
                            }else{
                                message = maskGenericWords(message, matchPattern.group(0), messageFromObject[1], False);
                            }
                        }
                        messageFromString = matchPattern.group(0).split(':');
                        if (messageFromString.size() == 2) {
                            if(emailKeyWords.contains(messageFromString[0].tolowercase())){
                                message = maskEmail(message, messageFromString[1], True);
                            }else{
                                message = maskGenericWords(message, matchPattern.group(0), messageFromString[1], True);
                            }
                        }    
                    }
                }
            }*/
            this.message = message;
            LoggerFactory.dispatch(this.level, this.getContent());
            if(throwTestException){
                throw new DmlException('Exception thrown from test method run');
            }

        }catch(exception e){
           LoggerFactory.dispatch(LoggingLevel.ERROR, this.getErrorContent('3', INTERFACE_NAME, 'write(string message)', '', 'SYS_LOG', '', e.getMessage()+e.getStackTraceString(), DESTINATION_SYSTEM, 'OTHERS', BUSINESS_DESCRIPTION, TECHNICAL));
           ExceptionHandlerHelper.ExceptionLogHandlerWrapper excepHand = new ExceptionHandlerHelper.ExceptionLogHandlerWrapper();
        
           excepHand.severity            = ExceptionHandlerHelper.Severity.MEDIUM;
           excepHand.interfaceName       = INTERFACE_NAME;
           excepHand.elementName         = 'write(string message)';
           excepHand.referenceNumber     = '';
           excepHand.capability          = ExceptionHandlerHelper.Capability.SYS_LOG;
           excepHand.endPointURL         = '';
           excepHand.integrationPayload  = '';
           excepHand.correlationID       = '';
           excepHand.httpStatusCode      = '';
           excepHand.errorCode           = '';
           excepHand.errorDescription    = e.getMessage()+e.getStackTraceString();
           excepHand.destinationSystem   = DESTINATION_SYSTEM;
           excepHand.responseMessage     = '';
           excepHand.sourceName          = ExceptionHandlerHelper.SourceName.OTHERS;
           excepHand.BusinessDescription = BUSINESS_DESCRIPTION;
           excepHand.errorCategory       = TECHNICAL;
           LoggerFactory.dispatch(LoggingLevel.ERROR, this.getErrorContent(excepHand));
        }
    }

    /**
     * @description write, mask and dispatch the log with a message
     * @param excepLog the details of exception log
     */
    public void write(ExceptionHandlerHelper.ExceptionLogHandlerWrapper excepLog) {
        
        List<String> messageFromObject = new List<String>();
        List<String> messageFromString = new List<String>();
        try{
           /* if(keyWordsFromMetadata.isEmpty()){
                for(PII_Data_Mask_Keyword__mdt keywordList : [select Id,label,keywordDefiner__c,Enable__c from PII_Data_Mask_Keyword__mdt where Enable__c = True]){
                    if(keywordList.keywordDefiner__c == EMAIL){
                        emailKeyWords.add(keywordList.label.tolowercase());
                    }
                    keyWordsFromMetadata.add(keywordList.label);
                }
            }
         
            if(!keyWordsFromMetadata.isEmpty()){
                String regexValue = '(?i)[\"]?__replaceme__[\"]?\\s*(([=:]\\s*([\"])(?:(?=(\\\\?))\\4.)*?\\3)|[=:]\\s*([\\+\\*\\w-@\\.]+))';
                for(string keyWordsToMatch : keyWordsFromMetadata){
                Pattern logEntry = Pattern.compile(regexValue.replace('__replaceme__', keyWordsToMatch));
                Matcher matchPattern = logEntry.matcher(excepLog.errorDescription);
                    while(matchPattern.find()) {
                        messageFromObject = matchPattern.group(0).split('=');
                        if(messageFromObject.size() == 2) {
                            if(emailKeyWords.contains(messageFromObject[0].tolowercase())){
                                excepLog.errorDescription = maskEmail(excepLog.errorDescription, messageFromObject[1], False);
                            }else{
                                excepLog.errorDescription = maskGenericWords(excepLog.errorDescription, matchPattern.group(0), messageFromObject[1], False);
                            }
                        }
                        messageFromString = matchPattern.group(0).split(':');
                        if (messageFromString.size() == 2) {
                            if(emailKeyWords.contains(messageFromString[0].tolowercase())){
                                excepLog.errorDescription = maskEmail(excepLog.errorDescription, messageFromString[1], True);
                            }else{
                                excepLog.errorDescription = maskGenericWords(excepLog.errorDescription, matchPattern.group(0), messageFromString[1], True);
                            }
                        }    
                    }
                }
            }*/
            
            this.message = excepLog.errorDescription;
            LoggerFactory.dispatch(LoggingLevel.ERROR, this.getErrorContent(excepLog));
            LogPlatformEvent(excepLog);
            if(throwTestException){
                throw new DmlException('Exception thrown from test method run');
            }

        }catch(exception e){
            ExceptionHandlerHelper.ExceptionLogHandlerWrapper excepHand = new ExceptionHandlerHelper.ExceptionLogHandlerWrapper();
        
            excepHand.severity            = ExceptionHandlerHelper.Severity.MEDIUM;
            excepHand.interfaceName       = INTERFACE_NAME;
            excepHand.elementName         = 'write(ExceptionHandlerHelper.ExceptionLogHandlerWrapper excepLog)';
            excepHand.referenceNumber     = '';
            excepHand.capability          = ExceptionHandlerHelper.Capability.SYS_LOG;
            excepHand.endPointURL         = '';
            excepHand.integrationPayload  = '';
            excepHand.correlationID       = '';
            excepHand.httpStatusCode      = '';
            excepHand.errorCode           = '';
            excepHand.errorDescription    = e.getMessage()+e.getStackTraceString();
            excepHand.destinationSystem   = DESTINATION_SYSTEM;
            excepHand.responseMessage     = '';
            excepHand.sourceName          = ExceptionHandlerHelper.SourceName.OTHERS;
            excepHand.BusinessDescription = BUSINESS_DESCRIPTION;
            excepHand.errorCategory       = TECHNICAL;
            LoggerFactory.dispatch(LoggingLevel.ERROR, this.getErrorContent(excepHand));
        }
    }
    /**
     * @description write, mask and dispatch the log with a error/exception details
     * 
     * @param severity string.valueof(ExceptionHandlerHelper.Severity.ordinal())
     * @param capability string.valueof(ExceptionHandlerHelper.Capability)
     * @param sourceName string.valueof(ExceptionHandlerHelper.sourceName)
     */
    public void writeError(String severity, String interfaceName, String elementName, String referenceNumber, 
        String capability, String correlationID, String errorDescription, String destinationSystem, 
        String sourceName, String BusinessDescription, String errorCategory) {

        string capabilityCode;
        string severityCode;

        if(String.isNotBlank(capability)){
            List<TicketGroup__mdt> tktgrp=[Select developername from TicketGroup__mdt where Code__c=:capability LIMIT 1];
            if(!tktgrp.isEmpty()){      
                capabilityCode = tktgrp[0].developername;
            }else{
                capabilityCode= capability;
            }
        }else{
            capabilityCode = 'INVALID';
        }
        
        if(severity == '0'){
            severityCode = 'INVALID';
        }else{
            severityCode = severity;
        }

        List<String> messageFromObject = new List<String>();
        List<String> messageFromString = new List<String>();
        try{
            /*if(keyWordsFromMetadata.isEmpty()){
                for(PII_Data_Mask_Keyword__mdt keywordList : [select Id,label,keywordDefiner__c,Enable__c from PII_Data_Mask_Keyword__mdt where Enable__c = True]){
                    if(keywordList.keywordDefiner__c == EMAIL){
                        emailKeyWords.add(keywordList.label.tolowercase());
                    }
                    keyWordsFromMetadata.add(keywordList.label);
                }
            }
         
            if(!keyWordsFromMetadata.isEmpty()){
                String regexValue = '(?i)[\"]?__replaceme__[\"]?\\s*(([=:]\\s*([\"])(?:(?=(\\\\?))\\4.)*?\\3)|[=:]\\s*([\\+\\*\\w-@\\.]+))';
                for(string keyWordsToMatch : keyWordsFromMetadata){
                Pattern logEntry = Pattern.compile(regexValue.replace('__replaceme__', keyWordsToMatch));
                Matcher matchPattern = logEntry.matcher(errorDescription);
                    while(matchPattern.find()) {
                        messageFromObject = matchPattern.group(0).split('=');
                        if(messageFromObject.size() == 2) {
                            if(emailKeyWords.contains(messageFromObject[0].tolowercase())){
                                errorDescription = maskEmail(errorDescription, messageFromObject[1], False);
                            }else{
                                errorDescription = maskGenericWords(errorDescription, matchPattern.group(0), messageFromObject[1], False);
                            }
                        }
                        messageFromString = matchPattern.group(0).split(':');
                        if (messageFromString.size() == 2) {
                            if(emailKeyWords.contains(messageFromString[0].tolowercase())){
                                errorDescription = maskEmail(errorDescription, messageFromString[1], True);
                            }else{
                                errorDescription = maskGenericWords(errorDescription, matchPattern.group(0), messageFromString[1], True);
                            }
                        }    
                    }
                }
            }*/
            if(throwTestException){
                throw new DmlException('Exception thrown from test method run');
            }
            this.message = errorDescription;
            LoggerFactory.dispatch(LoggingLevel.ERROR, this.getErrorContent(severityCode, interfaceName, elementName, referenceNumber, capabilityCode, correlationID, errorDescription, destinationSystem, sourceName, BusinessDescription, errorCategory));
            
        }catch(exception e){
            LoggerFactory.dispatch(LoggingLevel.ERROR, this.getErrorContent('3', INTERFACE_NAME, 'write(string message)', '', 'SYS_LOG', '', e.getMessage()+e.getStackTraceString(), DESTINATION_SYSTEM, 'OTHERS', BUSINESS_DESCRIPTION, TECHNICAL));
        }
    }

    /**
     * @description method to create Platform event for exception log record that gets created
     */
    // 
    public static void LogPlatformEvent(ExceptionHandlerHelper.ExceptionLogHandlerWrapper excepLog){
        
        string capabilityCode;

        if(String.isNotBlank(string.valueof(excepLog.capability))){
            List<TicketGroup__mdt> tktgrp=[Select developername from TicketGroup__mdt where Code__c=:string.valueof(excepLog.capability) LIMIT 1];
            if(!tktgrp.isEmpty()){      
                capabilityCode = tktgrp[0].developername;
            }else{
                capabilityCode= string.valueof(excepLog.capability);
            }
        }else{
            capabilityCode = 'INVALID';
        }

        List<Event__mdt> CustData = new List<Event__mdt>([SELECT EventKey__c,SystemId__c,Version__c,Label,resourceURI__c
                                                          FROM  Event__mdt 
                                                          where DeveloperName =: capabilityCode]);
        
        List<ExceptionLog__e> events = new List<ExceptionLog__e>();
        if(!CustData.isEmpty() && CustData.size()>0){
            if(String.isNotBlank(capabilityCode) && String.isNotBlank(string.valueof(excepLog.severity.ordinal())) && ((String.valueOf(excepLog.severity.ordinal())>'0') && (String.valueOf(excepLog.severity.ordinal())<='2'))){ 
                ExceptionLog__e e = new ExceptionLog__e();
                e.Severity__c = Integer.ValueOf(excepLog.severity.ordinal()); 
                e.InterfaceName__c = excepLog.interfaceName;
                e.ErrorDescription__c = excepLog.errorDescription;
                e.Capability__c = capabilityCode;
                e.ElementName__c = excepLog.elementName;
                e.ErrorCategory__c = excepLog.errorCategory;
                e.ErrorCode__c = excepLog.errorCode;
                e.IntegrationPayload__c  = excepLog.integrationPayload;
                e.CorrelationId__c = excepLog.correlationID;
                e.ExceptionUUID__c = excepLog.correlationID;
                e.SystemId__c = CustData[0].SystemId__c;
                e.EventKey__c = CustData[0].EventKey__c;
                e.Version__c = CustData[0].Version__c;
                events.add(e);
            }
            if(!events.isEmpty() && events.size()>0) {
                system.debug('PRINT Before published Exception Log event--'+events);
                List<Database.SaveResult> results = EventBus.publish(events);
                system.debug('PRINT Successfully  Exception Log event--'+results);
            }
            else{
                system.debug(LoggingLevel.ERROR,'EventList is empty');
            }
        }
    }
    
    /**
     * @description Mask PII details
     * @param input the log message
     * @param valToReplace value to be masked
     * @param fromStringFormat if value is in a string or object format
     * @return Log message with masked value
     */
    /*public static String maskGenericWords(String input, String keyValuePair, String valToReplace, Boolean fromStringFormat){
        string modifiedKeyValuePair;
        if(string.isBlank(valToReplace) || valToReplace == '' || valToReplace == 'null'){
          return valToReplace;
        }
        if(fromStringFormat){
  			modifiedKeyValuePair = keyValuePair.replace(valToReplace, '\"XXXX-'+valToReplace.right(4));
            return input.replace(keyValuePair, modifiedKeyValuePair);
        }else{
            modifiedKeyValuePair = keyValuePair.replace(valToReplace, 'XXXX-'+valToReplace.right(3));
            return input.replace(keyValuePair, modifiedKeyValuePair);
        }
    }*/

    /**
     * @description Mask Emails 
     * @param input the log message
     * @param valToReplace value to be masked
     * @param fromStringFormat if value is in a string or object format
     * @return Log message with masked value
     */
    /*public static String maskEmail(String input, String valToReplace, Boolean fromStringFormat){
        if(string.isBlank(valToReplace) || valToReplace == '' || valToReplace == 'null'){
          return valToReplace;
        }
        if(fromStringFormat){
            return input.replace(valToReplace, valToReplace.replaceAll('(^[^@]{3}|(?!^)\\G)[^@]', '$1*'));
        }else{
            return input.replace(valToReplace, valToReplace.replaceAll('(^[^@]{2}|(?!^)\\G)[^@]', '$1*'));
        }
    }*/

	/**
     * @description Add log message with multiple details
     * @return Updated Log message
     */
    private String getContent() {
        Map<String, Object> data = new Map<String, Object>{
            'timestamp' => DateTime.now(),
            'loggerName' => this.loggerName,
            'level' => this.level,
            'message' => this.message
        };
        if (this.ex != null) {
            
            data.put('exception', new Map<String, Object>{
                'message' => ex.getMessage(),
                'lineNumber' => ex.getLineNumber(),
                'stacktrace' => ex.getStackTraceString(),
                'type' => ex.getTypeName(),
                'cause' => ex.getCause()
            });
        }
       
        return JSON.serialize(data);
    }
    /**
     * @description Add log message with multiple details for Error
     * @return Updated Log message
     */
    public String getErrorContent(String severity, String interfaceName, String elementName, String referenceNumber, String capability, String correlationID, String errorDescription, String destinationSystem, String sourceName, String BusinessDescription, String errorCategory) {
        Map<String, Object> data = new Map<String, Object>{
            'timestamp' => DateTime.now(),
            'loggerName' => this.loggerName,
            'level' => this.level,
            'message' => this.message,
            'severity' => severity,
            'interfaceName' => interfaceName,
            'elementName' => elementName,
            'referenceNumber' => referenceNumber,
            'capability' => capability,
            'correlationID' => correlationID,
            'errorDescription' => errorDescription,
            'destinationSystem' => destinationSystem,
            'sourceName' => sourceName,
            'BusinessDescription' => BusinessDescription,
            'errorCategory' => errorCategory        
        };

        if (this.ex != null) {
            
            data.put('exception', new Map<String, Object>{
                'message' => ex.getMessage(),
                'lineNumber' => ex.getLineNumber(),
                'stacktrace' => ex.getStackTraceString(),
                'type' => ex.getTypeName(),
                'cause' => ex.getCause()
            });
        }

        return JSON.serialize(data);
    }

    public String getErrorContent(ExceptionHandlerHelper.ExceptionLogHandlerWrapper excepLog) {
        string capabilityCode;
        string severityCode;

        if(String.isNotBlank(string.valueof(excepLog.capability))){
            List<TicketGroup__mdt> tktgrp=[Select developername from TicketGroup__mdt where Code__c=:string.valueof(excepLog.capability) LIMIT 1];
            if(!tktgrp.isEmpty()){      
                capabilityCode = tktgrp[0].developername;
            }else{
                capabilityCode= string.valueof(excepLog.capability);
            }
        }else{
            capabilityCode = 'INVALID';
        }
        
        if(string.valueof(excepLog.severity.ordinal()) == '0'){
            severityCode = 'INVALID';
        }else{
            severityCode = string.valueof(excepLog.severity.ordinal());
        }

        Map<String, Object> data = new Map<String, Object>{
            'timestamp' => DateTime.now(),
            'loggerName' => this.loggerName,
            'level' => this.level,
            'message' => this.message,
            'severity' => severityCode,
            'interfaceName' => excepLog.interfaceName,
            'elementName' => excepLog.elementName,
            'referenceNumber' => excepLog.referenceNumber,
            'capability' => capabilityCode,
            'endPointURL' => excepLog.endPointURL,
            'integrationPayload' => excepLog.integrationPayload,
            'correlationID' => excepLog.correlationID,
            'httpStatusCode' => excepLog.httpStatusCode,
            'errorCode' => excepLog.errorCode,
            'errorDescription' => excepLog.errorDescription,
            'responseMessage' => excepLog.responseMessage,
            'destinationSystem' => excepLog.destinationSystem,
            'sourceName' => string.valueof(excepLog.sourceName),
            'BusinessDescription' => excepLog.BusinessDescription,
            'errorCategory' => excepLog.errorCategory, 
            'exceptionUUID'=> excepLog.correlationID          
        };

        if (this.ex != null) {
            
            data.put('exception', new Map<String, Object>{
                'message' => ex.getMessage(),
                'lineNumber' => ex.getLineNumber(),
                'stacktrace' => ex.getStackTraceString(),
                'type' => ex.getTypeName(),
                'cause' => ex.getCause()
            });
        }

        return JSON.serialize(data);
    }
    /**
     * @description initialise the builder to make it reusable
     * @param level the logging level (cannot be null)
     * @param loggerName the name of the logger
     * @return itself
     */
    public LoggingEventBuilder init(LoggingLevel level, String loggerName) {
        this.loggerName = loggerName;
        this.level = level;
        this.properties.clear();
        this.ex = null;
        this.message = null;
        return this;
    }
}