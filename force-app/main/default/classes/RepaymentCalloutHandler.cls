/*************************************************************************************************
Name : RepaymentCalloutHandler
Description : Service class for Repayment API
Author: Jawahar M
Story: EDGE-108333
Team: Osaka
***************************************************************************************************/
public with sharing class RepaymentCalloutHandler {
    public static final String  handlerName = 'RepaymentDetailsHandler'; 
    private static final String CONST_INTERFACENAME = 'RepaymentCalloutHandler';

    /*-------------------------------------------------------- 
    EDGE-108333
    Method: createPayload
    Description: Method to create payload for Repayment details
    Author:Jawahar M
    --------------------------------------------------------*/
    public static RepaymentRequestDTO createPayload(String statementNumber,Integer chargeId){
        RepaymentRequestDTO requestDto = new RepaymentRequestDTO();
        
        requestDto.statementNumber=statementNumber;
        
        requestDto.chargeId=Integer.ValueOf(chargeId);
        
        return requestDto;
    }
    
    /*-------------------------------------------------------- 
    EDGE-108333
    Method: calloutRepaymentDetails
    Description: Method to make callout to Repayment API
    Author: Jawahar M
    Team: Osaka
    --------------------------------------------------------*/
    /*public static RepaymentResponseDTO calloutUsageDetails(RepaymentRequestDTO usageRequest){
        RepaymentResponseDTO res = null;
        Logger2 logger = Logger2.getLogger(handlerName);
        String reqBody = JSON.serialize(usageRequest,true);
        system.debug('Request Body--->>>'+reqBody);
        String correlationId = EDISSingleManager.getUID();
        HttpResponse response;
        try {
            String token = AuthenticationManager.getOauthToken(handlerName);
            //String token = 'xQS1L5gsi9TlQarU5G5AvJAaG7pp';
            Map < String, String > headerMap = new Map < String, String > {
                'Content-Type' => 'application/json',
                    'Authorization' => 'Bearer ' + token,
                    'correlationId' => correlationId
                    };
                        response = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName);
            System.debug('response::-->>' + response.getBody());
            String responseCode = String.valueOf(response.getStatusCode());
             if (responseCode.startsWith('2')) {
                 String responseTemp = response.getBody();
                 //responseTemp = responseTemp.replace('"date"','"date_x"');
                 //responseTemp = responseTemp.replace('"time"','"time_x"');
                 res = RepaymentResponseDTO.parse(response.getBody());

                 System.debug('res: '+res);
                 logger.logMessages(reqBody, response.getBody(), '', '', '', '', false, false,Integer.valueof(response.getStatusCode()) , null, null, null);
             }else if (responseCode.startsWith('4') || responseCode.startsWith('5')) {
                res = RepaymentResponseDTO.parse(response.getBody());
                logger.logMessages(reqBody, response.getBody(), '', '', '', '', false, false, Integer.valueOf(response.getStatusCode()) , null, null, null);
             }
             logger.exitLogger();
            } catch (Exception e) {
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();
        }
        return res;
    }*/

    /*----------------------------------------------------------------
    Method     : calloutRepaymentDetails
    Description: Method to get repayment details for corresponding Invoice
    Author     : Gnana
    Story      : EDGE-215748 
    -------------------------------------------------------------------------------------*/ 

    public static String calloutRepaymentDetails(InvoiceChargeTypeRequestDTO repaymentRequest){
        system.debug('inside apex controller');
        // populating request DTO 
        String request = JSON.serialize(repaymentRequest,true); // parsing DTO to string 
        Logger2 log = Logger2.getLogger(handlerName);

        HttpResponse invoiceResponse;
    
        RepaymentResponseDTO responseDTO = new RepaymentResponseDTO();
        list<RepaymentResponseDTO.repaymentDetails> repaymentDetailsList = new list<RepaymentResponseDTO.repaymentDetails>();
        list<RepaymentResponseDTO.repaymentDetails> finalList = new list<RepaymentResponseDTO.repaymentDetails>();
        //RepaymentResponseDTO.repaymentSummary sum = new RepaymentResponseDTO.repaymentSummary();
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
        system.debug('response=========>'+invoiceResponse.getBody());
        
         String responseCode = String.valueOf(invoiceResponse.getStatusCode());
            if (responseCode.startsWith('2')) {
                responseDTO = RepaymentResponseDTO.parse(invoiceResponse.getBody());
                //system.debug('responseDTO------'+responseDTO);
                repaymentDetailsList = responseDTO.repaymentDetails;
               //system.debug('responseDTO==================>' +responseDTO.repaymentDetails.invoiceLineAttributes);
                
                for(RepaymentResponseDTO.repaymentDetails repaymentData: repaymentDetailsList)
                {
                    
                  for(RepaymentResponseDTO.invoiceLineAttributes invoiceAttrib: repaymentData.invoiceLineAttributes)
                  {
                      repaymentData.excludingGSTcostFmtd = invoiceAttrib.excludingGSTcostFmtd;
                      repaymentData.includingGSTcostFmtd = invoiceAttrib.includingGSTcostFmtd;
                  }
                    finalList.add(repaymentData);
                }
                system.debug('responseDTO------'+finalList);
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
    
    return (String)JSON.serialize(finalList,true);
    }

    /*----------------------------------------------------------------
    Method     : logException
    Description: Method to log Exceptions
    Author     : Gnana
    Story      : EDGE-215748 
    -------------------------------------------------------------------------------------*/ 
    @TestVisible
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