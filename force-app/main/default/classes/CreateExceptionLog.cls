/**
* @Author     :   Shashank
* @Date       :   28th May 2021
* @Desc       :   This class is written for creationg Exception logs.
* @Initial US :   EDGE-221893
* 
* */
public class CreateExceptionLog{
  public void logException(C2O_ExceptionHandler.Capability capability,String interfaceName,String methodName, String referenceNumber, String correlationId, String errorMessage, String businessDescription,Boolean hasAPICall){
        Map<String, Object> eLogMap = new Map<String, Object>();
        eLogMap.put('capability', capability);
        eLogMap.put('interfaceName', interfaceName);
        eLogMap.put('elementName', methodName);
        eLogMap.put('referenceNumber', referenceNumber);
        eLogMap.put('correlationId', correlationId);
        eLogMap.put('errorDescription', errorMessage);
        eLogMap.put('businessDescription', businessDescription);
        C2O_Utilities.logException(eLogMap, hasAPICall);
    }
}