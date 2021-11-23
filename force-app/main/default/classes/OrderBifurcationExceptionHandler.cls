/**********************************************************************************************
@description: OrderBifurcationExceptionHandler class is used to construct exception logs 
for order generation apex methods

***********************************************************************************************/


public without sharing class OrderBifurcationExceptionHandler {
    
    private static C2O_ExceptionHandler.Severity DEFAULT_LOGEX_SEVERITY = C2O_ExceptionHandler.Severity.CRITICAL;
    private static final String CONST_INTERFACENAME = 'Order Generation';
    
    /**
     * @description constructor for calling Exception Handling Framework 
     */
    public static void logException(String methodName, String referenceNumber, String correlationId, String errorMessage, String businessDescription){
        Map<String, Object> eLogMap = new Map<String, Object>();
        eLogMap.put('severity', DEFAULT_LOGEX_SEVERITY );
        eLogMap.put('interfaceName', CONST_INTERFACENAME);
        eLogMap.put('elementName', methodName);
        eLogMap.put('referenceNumber', referenceNumber);
        eLogMap.put('correlationId', correlationId);
        eLogMap.put('errorDescription', errorMessage);
        eLogMap.put('businessDescription', businessDescription);
        C2O_Utilities.logException(eLogMap, false);
    }
    
    public static void logException(String methodName, List<Id> referenceNumbers, String correlationId, String errorMessage, String businessDescription){
        string referenceNumber = 'None';
        if(referenceNumbers !=null){
            referenceNumber = string.join(referenceNumbers,',');
        }
        if(referenceNumber.length() >50 ){
            referenceNumber = referenceNumber.substring(0,49);
        }
        OrderBifurcationExceptionHandler.logException(methodName, referenceNumber, correlationId, errorMessage, businessDescription);
    }
    
    
    
    
}