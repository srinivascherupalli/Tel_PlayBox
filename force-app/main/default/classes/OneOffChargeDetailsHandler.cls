/**************************************************************************
EDGE        - 215747
component   -
Description - Controller to fetch Once-Off Charges details
Author      - Pawan Singh
Team        - Munich
*********************************************************************************/
public with sharing class OneOffChargeDetailsHandler {

    private static final String CONST_INTERFACENAME = 'OnceOffChargeDetailsHandler';
    @AuraEnabled(cacheable=true)
    public static String calloutOneOffChargeDetails(Long chargeId, String statementNumber, String accountNumber, String handlerName)
    {
        system.debug('inside apex controller');
        // populating request DTO 
        InvoiceChargeTypeRequestDTO requestDTO = new InvoiceChargeTypeRequestDTO();
        requestDTO.accountNumber = accountNumber;
        requestDTO.chargeId = chargeId;
        requestDTO.statementNumber = statementNumber;

        String request = JSON.serialize(requestDTO,true); // parsing DTO to string 
        Logger2 log = Logger2.getLogger(handlerName);

        HttpResponse invoiceResponse;
    
        OnceOffChargeResponseDTO responseDTO = new OnceOffChargeResponseDTO();
        list<OnceOffChargeResponseDTO.OrderDetails> orderDetails = new list<OnceOffChargeResponseDTO.OrderDetails>();
    	list<OnceOffChargeResponseDTO.OrderDetails> finalList = new list<OnceOffChargeResponseDTO.OrderDetails>();
        try{
            String correlationId = IntegrationRecordHandlerUtil.getCorrelationId();
            String token = ''; 
            Integration_Handler__mdt handleSettingRecord = IntegrationRecordHandlerUtil.getIntegrationHandlerSettings(handlerName);
            if(handleSettingRecord!=null) {
                if(handleSettingRecord.Enable_Mock_Integration__c) {
                    token=System.Label.QLI_Token; 
                }
                else {
                    token = AuthenticationManager.getOauthToken(handlerName);
                }
            }
            Map < String, String > headerMap = new Map < String, String > {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer ' + token,
                'correlationId' => correlationId,
                'caller-app' =>'Salesforce' 
            };
     
        invoiceResponse = IntegrationRecordHandlerUtil.calloutSync(request, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName);
        system.debug('response=========>'+invoiceResponse);
        
         String responseCode = String.valueOf(invoiceResponse.getStatusCode());
            if (responseCode.startsWith('2')) {
                responseDTO = OnceOffChargeResponseDTO.parse(invoiceResponse.getBody());
                orderDetails =  responseDTO.OrderDetails;
                 for(OnceOffChargeResponseDTO.OrderDetails ordDetails: orderDetails)
                        {
                            for(OnceOffChargeResponseDTO.invoiceLineAttributes invoiceAttrib: ordDetails.invoiceLineAttributes)
                            {
                                ordDetails.invoiceTransactionId =invoiceAttrib.invoiceTransactionId;
                            }
                            finalList.add(ordDetails);
                        }
                system.debug('responseDTO==================>' + finalList);
                log.logMessages(request, invoiceResponse.getBody(), '', '', '', '', false, false,Integer.valueof(invoiceResponse.getStatusCode()) , null, null, null);
                
            }else if (responseCode.startsWith('4') || responseCode.startsWith('5')) {
                log.logMessages(request, invoiceResponse.getBody(), '', '', '', '', false, false, Integer.valueOf(invoiceResponse.getStatusCode()) , null, null, null);
            }
         

        
        DateTime startTime = DateTime.now();
        DateTime endTime = DateTime.now();
        Long requestTime = log.getRequestTimeDifference(startTime, endTime);
        log.logMessages(request, invoiceResponse.getBody(), '', '', '','', String.valueOf(invoiceResponse.getStatusCode()), correlationId, '','','Create','',requestTime,'POST',false, false);
        log.exitLogger();
    }

    catch (Exception e) {
        logException('calloutOneOffChargeDetails', '', '',  e.getMessage(), 'Exception occured while querying for once off charge billing details');
    } 
    
    return (String)JSON.serialize(finalList);
    
}



    /*===============Error Logging Framework=============== */
    private static void logException(String methodName, String referenceNumber, String correlationId, String errorMessage, String businessDescription){
        Map<String, Object> eLogMap = new Map<String, Object>();
        eLogMap.put('interfaceName', CONST_INTERFACENAME); 
        eLogMap.put('elementName', methodName);
        eLogMap.put('referenceNumber', referenceNumber); 
        eLogMap.put('correlationId', correlationId);
        eLogMap.put('errorDescription', errorMessage); 
        eLogMap.put('businessDescription', businessDescription);
        C2O_Utilities.logException(eLogMap, false);
    }
   
}