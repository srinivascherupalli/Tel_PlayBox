global class ExceptionHandlerHelper {
        
    /** 
    * As part of new Exception logging framework, ExceptionLogHandlerWrapper 
    * will be used to hold values passed from VIP or Apex to create Exception
    * Log Record.
    */
    
    global class ExceptionLogHandlerWrapper{
        
        global Severity severity;
        global string interfaceName;
        global String elementName;
        global String referenceNumber;
        global Capability capability;
        global String endPointURL;
        global String integrationPayload;
        global String correlationID;
        global String httpStatusCode;
        global String errorCode;
        global String errorDescription;
        global String responseMessage;
        global String destinationSystem;
        global SourceName sourceName;
        global string BusinessDescription;
        global String errorCategory;
    }
    
    /** 
    * Capability enum created to allow only specified Capability   
    * values (except INVALID) to be used while creating Exception 
    * Log Record. INVALID will be used when incorrect Capability 
    * value is used to create record.
    */
    public enum Capability {
        TestLabel,
    	INVALID,
        SYS_LOG
    }
    
    /** 
    * SourceName enum created to allow only specified Source name   
    * values (except INVALID) to be used while creating Exception 
    * Log Record. INVALID will be used when incorrect Source name 
    * value is used to create record.
    */
    public enum SourceName {
        OTHERS,
        INVALID
    }
    
    /** 
    * Severity enum created to allow only specified Severity  
    * values (except INVALID) to be used while creating Exception 
    * Log Record. INVALID will be used when incorrect Severity 
    * value is used to create record.
    * Pleaes don't change the sequence of values defined in enum
    * as their positioning is used to define the severity.
    * INVALID --> 0
    * CRITICAL --> 1
    * HIGH --> 2
    * MEDIUM --> 3
    * LOW --> 4
    */
	public enum Severity {
        INVALID,
        CRITICAL,
        HIGH,
        MEDIUM, 
        LOW   
	}
}