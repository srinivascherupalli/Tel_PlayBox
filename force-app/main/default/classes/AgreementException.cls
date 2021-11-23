public class AgreementException extends Exception {
    
    public String methodName;
    public String referenceNumber;
    public String errorMessage;
    public String businessDescription;
    
    public AgreementException(String methodNameEx,String referenceNumberEx,String errorMessageEx,String businessDescriptionEX){
        methodName = methodNameEx;
        referenceNumber = referenceNumberEx;
        errorMessage = errorMessageEx;
        businessDescription = businessDescriptionEX;
        
    }

}