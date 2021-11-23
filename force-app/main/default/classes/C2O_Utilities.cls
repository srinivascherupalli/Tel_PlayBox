public without sharing class C2O_Utilities {
    //@description initialise variables used for Exception Handling Framework
	private static C2O_ExceptionHandler.Severity DEFAULT_LOGEX_SEVERITY = C2O_ExceptionHandler.Severity.MEDIUM;
    private static C2O_ExceptionHandler.SourceName DEFAULT_LOGEX_SOURCENAME = C2O_ExceptionHandler.SourceName.OTHERS;
    private static C2O_ExceptionHandler.Capability LOGEX_CAPABILITY = C2O_ExceptionHandler.Capability.NOVAL;
    private static final String DEFAULT_LOGEX_ERRORCODE = '400';
	private static final String DEFAULT_LOGEX_ERRORCATEGORY = 'Technical';
	private static final String DEFAULT_LOGEX_NA = 'N/A';			//logged value if hasAPICall is passed as false
    private static final String DEFAULT_LOGEX_NP = 'NOT PROVIDED';	//logged value if hasAPICall is passed as true but no details provided
    private static final String CONST_ERRORDESCRIPTION_PREFIX = 'Exception occurred in ';
    private static final String CONST_SEVERITY_KEY = 'severity';
    private static final String CONST_CAPABILITY_KEY = 'capability';
    private static final String CONST_SOURCENAME_KEY = 'sourceName';
    
    //@description method for Exception Handling Framework
	public static void logException(Map<String, Object> inputMap, Boolean hasAPICall) {
		C2O_ExceptionHandler.ExceptionHandlerWrapper eLogParams = new C2O_ExceptionHandler.ExceptionHandlerWrapper();
		C2O_ExceptionHandler.Severity severity = getSeverity(inputMap);
        C2O_ExceptionHandler.Capability capability = getCapability(inputMap);
        C2O_ExceptionHandler.SourceName sourceName = getSourceName(inputMap);
        String interfaceName = getStringValue('interfaceName', inputMap);
        String elementName = getStringValue('elementName', inputMap);
        String errorCode = getStringValue('errorCode', inputMap);
        String errorDescription = getStringValue('errorDescription', inputMap);
        String errorDescriptionGeneric = CONST_ERRORDESCRIPTION_PREFIX + interfaceName + '.' + elementName + '()';
		String errorCategory = getStringValue('errorCategory', inputMap);
        
        //@description pre-default to 'N/A' for all API-specific fields
		String endPointURL = DEFAULT_LOGEX_NA;
		String integrationPayload = DEFAULT_LOGEX_NA;
		String httpStatusCode = DEFAULT_LOGEX_NA;
		String responseMessage = DEFAULT_LOGEX_NA;
		String destinationSystem = DEFAULT_LOGEX_NA;
		
        //@description fetch explicitly provided values for all API-specific fields
		if (hasAPICall) {
			endPointURL = getStringValue('endpointURL', inputMap);
			integrationPayload = getStringValue('integrationPayload', inputMap);
			httpStatusCode = getStringValue('httpStatusCode', inputMap);
			responseMessage = getStringValue('responseMessage', inputMap);
			destinationSystem = getStringValue('destinationSystem', inputMap);
		}
		
        //@description prepare exception values to be logged
		eLogParams.severity = severity;
		eLogParams.interfaceName = interfaceName;
		eLogParams.elementName = elementName;
		eLogParams.referenceNumber = getStringValue('referenceNumber', inputMap);
		eLogParams.endpointURL = (endpointURL != '') ? endPointURL : DEFAULT_LOGEX_NP;
		eLogParams.integrationPayload = (integrationPayload != '') ? integrationPayload : DEFAULT_LOGEX_NP;
		eLogParams.correlationId = getStringValue('correlationId', inputMap);
		eLogParams.httpStatusCode = (httpStatusCode != '') ? httpStatusCode : DEFAULT_LOGEX_NP;
		eLogParams.errorCode = (errorCode != '') ? errorCode : DEFAULT_LOGEX_ERRORCODE;
		eLogParams.errorDescription = (errorDescription != '') ? errorDescription : errorDescriptionGeneric;
		eLogParams.responseMessage = (responseMessage != '') ? responseMessage : DEFAULT_LOGEX_NP;
		eLogParams.destinationSystem = (destinationSystem != '') ? destinationSystem : DEFAULT_LOGEX_NP;
		eLogParams.sourceName = sourceName;
		eLogParams.businessDescription = getStringValue('businessDescription', inputMap);
		eLogParams.errorCategory = (errorCategory != '') ? errorCategory : DEFAULT_LOGEX_ERRORCATEGORY;
        
        //@description only include logging the capability if a value is provided
        if (String.valueOf(capability) != 'NOVAL') {
            eLogParams.capability = capability;
        }
        
        try {
            C2O_ExceptionHandler.createExceptionLog(eLogParams);
        } catch (Exception e) {
            System.debug('Exception occurred in logException(): ' + e.getMessage());
        }
	}
	//code merge: MT
	public static void createException(Exception ex){
        Map<String,Object> inputLogMap = new Map<String,Object>();
        inputLogMap.put('severity', C2O_ExceptionHandler.SEVERITY.HIGH); 
        inputLogMap.put('errorDescription', ex.getMessage());
        inputLogMap.put('LoggingLevel.INFO', ex.getStackTraceString()); 
        C2O_Utilities.logException(inputLogMap,false);
    }
    //@description method for Exception Handling Framework
    private static C2O_ExceptionHandler.Severity getSeverity(Map<String, Object> json) {
        Object val = json.get(CONST_SEVERITY_KEY);
        return (val == null) ? DEFAULT_LOGEX_SEVERITY : (C2O_ExceptionHandler.Severity) val;
    }
    
    //@description method for Exception Handling Framework
    private static C2O_ExceptionHandler.Capability getCapability(Map<String, Object> json) {
        Object val = json.get(CONST_CAPABILITY_KEY);
        return (val == null) ? LOGEX_CAPABILITY : (C2O_ExceptionHandler.Capability) val;
    }
    
    //@description method for Exception Handling Framework
    private static C2O_ExceptionHandler.SourceName getSourceName(Map<String, Object> json) {
        Object val = json.get(CONST_SOURCENAME_KEY);
        return (val == null) ? DEFAULT_LOGEX_SOURCENAME : (C2O_ExceptionHandler.SourceName) val;
    }
    
    //@description method to fetch String value of a given key in a JSON structure
	private static String getStringValue(String key, Map<String, Object> json) {
		Object val = json.get(key);
		return (val == null) ? '' : String.valueOf(val);
	}
}