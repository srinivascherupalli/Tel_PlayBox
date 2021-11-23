public class TCMBusinessErrorCode {

    private static TCMBusinessErrorCode instance = null;
    private Map<String,String> customerContactErrorMapping{set;get;}
    
    private TCMBusinessErrorCode(){
        customerContactErrorMapping = new Map<String,String>();
        getErrorMap();
    }
    
    public static TCMBusinessErrorCode getInstance(){
        if(instance == null) instance = new TCMBusinessErrorCode();
        return instance;
    }
       
   
    private void getErrorMap(){
        for(ValidationRuleErrors__c validationRuleErrors :ValidationRuleErrors__c.getAll().values()){
            System.debug('Name : ' + validationRuleErrors.Name + ' : ' + validationRuleErrors.Value__c);
            customerContactErrorMapping.put(validationRuleErrors.value__c.toLowercase(),validationRuleErrors.name);
        }
        system.debug('customerContactErrorMapping'+customerContactErrorMapping);
    }
    
    public String getCode(String errorMessage){
        for(String i:customerContactErrorMapping.keySet()) {
            if(errorMessage.contains(i.toLowerCase())){
                return customerContactErrorMapping.get(i);
            }
        }
        return 'VR0039';
    }
    
    public void logCustomerExcepction(String cidn, String errorType, Exception exceptionObj){
        TCMGetInterface instance = TCMGetInterface.getInstance();
        TCMGetInterface.TCMRequestResponseCapture responseCapture = instance.callOutDataCapture.get(cidn);
        logException(exceptionObj, errorType, responseCapture.url, instance.tcmCustomerObject.get(cidn), responseCapture.httpResponse);
    }

    //Handle Exception Handling.
    private void logException(Exception exceptionObj, String errortype, String url, CustomerObject.customer customerObj,HttpResponse httpResponse){
        Logger2 logger = Logger2.getLogger(errortype);
        logger.logMessages(url, httpResponse.getBody(), exceptionObj.getStackTraceString(), 
                           'Business', getCode(exceptionObj.getMessage().toLowerCase()), exceptionObj.getMessage(),
                           true, false,httpResponse.getStatusCode(),customerObj.cac,
                           customerObj.customerAccount.accountUuid,TCMCustomerContactConstants.TCMERRORCODE_FAILURE);
    }
    
	public void logCustomContactExcepction(String UUID, String errorType, String errorMessage, String[] errorFields){
        TCMGetInterface instance = TCMGetInterface.getInstance();
        TCMGetInterface.TCMRequestResponseCapture responseCapture = instance.callOutDataCapture.get(UUID);
        String stackMessage = (errorFields != null && !errorFields.isEmpty()) ? String.join(errorFields, ' --- ') : '';
        logContactException(errorType,responseCapture.url, UUID, errorMessage, stackMessage, responseCapture.httpResponse);
    }

	//Handle Exception Handling.
    private void logContactException(String errortype, String url, String UUID,String errorMessage,String stackTrace, HttpResponse httpResponse){
        Logger2 logger = Logger2.getLogger(errortype);
        logger.logMessages(url, httpResponse.getBody(), stackTrace, 
                           errortype,getCode(errorMessage.toLowerCase(UserInfo.getLocale())), errorMessage,
                           true, false,httpResponse.getStatusCode(),UUID,UUID, TCMCustomerContactConstants.TCMERRORCODE_FAILURE);
    }
    
}