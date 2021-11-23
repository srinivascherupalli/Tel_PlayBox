/**
* Apex class to Insert UI Transaction Logs into Transaction Log object.
*/
public with sharing class FrontEndTransactionLog {
    
    private static String EMAIL                = 'Email';
    private static String TECHNICAL            = 'Technical';
    private static String INTERFACE_NAME       = 'LoggingEventBuilderImpl';
    private static String DESTINATION_SYSTEM   = 'Transaction Logging';
    private static String BUSINESS_DESCRIPTION = 'Exception while masking PII data';
    private static final String UILogs         = 'LoggingUILogs';
    
    private static Set<String> emailKeyWords = new Set<String>();
    private static List<String> keyWordsFromMetadata = new List<String>();
    
    @testvisible
    private static boolean throwTestException = false;

    public class LogWrapper {
        public String message;
        public LoggingLevel level;
        public String timestamp;
        public String loggerName;        
    }
 
    @AuraEnabled
    public static void transactionLogFromUI(String transactionLog, string correlationId){
        Logger3 Logger= LoggerFactory.getLogger(FrontEndTransactionLog.class);
        LoggingEventBuilderImpl logEventBuilderForMasking = new LoggingEventBuilderImpl();
        try{
            if(throwTestException){
                throw new DmlException('Exception thrown from test method run');
            }
            List<Default_Logger_Factory_Appender__mdt> isLoggingEnabled = [select Enabled__c, label from Default_Logger_Factory_Appender__mdt where label = :UILogs limit 1];
            if(!isLoggingEnabled.isEmpty() && isLoggingEnabled[0].Enabled__c == true){
                if(string.isNotBlank(transactionLog) && string.isNotBlank(correlationId)){
                    //For masking PII information

                    String[] txnLogs = transactionLog.split('\n');
                    for(String log : txnLogs) {                        
                        LogWrapper logWrapper = (LogWrapper) JSON.deserialize(log, LogWrapper.class);
                        if(logWrapper.level == LoggingLevel.ERROR) {
                            ExceptionHandlerHelper.ExceptionLogHandlerWrapper excepWrapper = (ExceptionHandlerHelper.ExceptionLogHandlerWrapper)JSON.deserialize(log, ExceptionHandlerHelper.ExceptionLogHandlerWrapper.class);
                            System.debug('Error found ' + excepWrapper);
                            logger.error(excepWrapper);
                            
                            LoggingEventBuilderImpl.LogPlatformEvent(excepWrapper);
                        }
                        else {
                            logEventBuilderForMasking.init(logWrapper.level, logWrapper.loggerName);
                            logEventBuilderForMasking.write(logWrapper.message);
                        }
                    }

                    LoggerFactory.flush(correlationId);

                }
            }
        }
        catch(Exception e){
            LoggingEventBuilderImpl loggingEventBuilderImpl = new LoggingEventBuilderImpl();
            ExceptionHandlerHelper.ExceptionLogHandlerWrapper excepHand = new ExceptionHandlerHelper.ExceptionLogHandlerWrapper();
            excepHand.severity            = ExceptionHandlerHelper.Severity.LOW;
            excepHand.interfaceName       = 'FronEndTransactionLog';
            excepHand.elementName         = 'transactionLogFromUI';
            excepHand.referenceNumber     = correlationId;
            excepHand.capability          = ExceptionHandlerHelper.Capability.SYS_LOG;
            excepHand.endPointURL         = '';
            excepHand.integrationPayload  = '';
            excepHand.correlationID       = correlationId;
            excepHand.httpStatusCode      = '';
            excepHand.errorCode           = '';
            excepHand.errorDescription    = e.getMessage()+e.getStackTraceString();
            excepHand.destinationSystem   = 'Front End Transaction Logging';
            excepHand.responseMessage     = '';
            excepHand.sourceName          = ExceptionHandlerHelper.SourceName.OTHERS;
            excepHand.BusinessDescription = 'Front End Transaction Logging';
            excepHand.errorCategory       = 'Technical';
            logger.error(excepHand);
            LoggerFactory.dispatch(LoggingLevel.ERROR, loggingEventBuilderImpl.getErrorContent(excepHand));
            
        }
    }

}