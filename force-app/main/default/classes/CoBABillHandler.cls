/**================================================================
* Appirio, Inc
* Name: CoBABillHandler
* Description: Class to build Request and Parse Response from Billing API (BDS) for COBA
* Created Date: April 14, 2021
* Created By: Prajakta Patil 
*Test class: CoBABillHandlerTest
 
1.  Akanksha    15/04/2021      EDGE-205527 Added changes to build header for billing request 
==================================================================*/
global with sharing class CoBABillHandler implements Database.AllowsCallouts {
   
    public static HttpResponse processBillingCalloutCOBA(List<Id> listOfSubscriptionIds,String targetBillAccNumber , String OrderNumber)
    {
        try{ 
            String handlerName = 'PostSubscriptionHandler';
            Logger2 log = Logger2.getLogger(handlerName);
            String oAuthToken = AuthenticationManager.getOauthToken(handlerName);
            String correlationId = IntegrationRecordHandlerUtil.getCorrelationId();
            correlationId = correlationId + OrderNumber;
            Map<String, String> headerMap = new Map<String, String>{ 'Content-Type' => 'application/json', 'Authorization' => 'Bearer ' + oAuthToken, 'Correlation-Id' => correlationId, 'Source-System' => 'SFDC' };
            headerMap.put('X-HTTP-Method-Override', 'PATCH');
            Map<String, String> pathMap = new Map<String, String>();
            String newvalue = 'subscriptions';
            pathMap.put(targetBillAccNumber, newvalue);
            HttpResponse adResponse;
            AdditionalBillPayloadGenerator objCoBAPayload = new AdditionalBillPayloadGenerator(listOfSubscriptionIds,false,false,'PostSubscriptionHandler',targetBillAccNumber);
            String requestBody = objCoBAPayload.generateCOBABillingPayLoad(targetBillAccNumber);
            DateTime startTime = DateTime.now();
            system.debug('Request----'+requestBody);
            adResponse = IntegrationRecordHandlerUtil.calloutSync(requestBody,IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName,pathMap);    
            DateTime endTime = DateTime.now();
            Long requestTime = log.getRequestTimeDifference(startTime, endTime);
            if(adResponse!=null)
            {
                log.logMessages(requestBody, adResponse.getBody(), '', '', '', 
                                '', String.valueOf(adResponse.getStatusCode()), correlationId, '','','Create','',requestTime ,'POST',false, false);
                log.exitLogger();
            }
            system.debug('adResponse'+adResponse);
            return adResponse;
        }
        catch(Exception e)
        {
            logException('processBillingCalloutCOBA', '', '',  e.getMessage() + '-' + e.getStackTraceString(), 'Request to BDS failed');
            throw e;
        }
    }
    /**
     * @description Exception Handling Framework 
     */
    public static void logException(String methodName, String referenceNumber, String correlationId, String errorMessage, String businessDescription){
      Map<String, Object> eLogMap = new Map<String, Object>();
      eLogMap.put('interfaceName', 'COBA');
      eLogMap.put('elementName', methodName);
      eLogMap.put('referenceNumber', referenceNumber);
      eLogMap.put('correlationId', correlationId);
      eLogMap.put('errorDescription', errorMessage);
      eLogMap.put('businessDescription', businessDescription);
      C2O_Utilities.logException(eLogMap, false);
  }
}