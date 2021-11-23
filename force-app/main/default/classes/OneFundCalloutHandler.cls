/*-------------------------------------------------------- 
EDGE-124053
Class: OneFundCalloutHandler
Description: Created for Handling OneFund callouts
Author:Hari
--------------------------------------------------------*/

public with sharing class OneFundCalloutHandler {
public static final String  handlerName = 'OneFundInvoiceByNumberHandler';
public static final String token;



/*-------------------------------------------------------- 
EDGE-124053
Method: createPayload
Description: Method to create payload for Invoice Number
Author:Hari
--------------------------------------------------------*/
    public static HttpResponse calloutInvoiceByNumber(OneFundInvoiceRequestDTO  invoiceRequest){
        OneFundInvoiceResponseDTO res = null;
        Logger2 logger = Logger2.getLogger(handlerName);
        String reqBody = JSON.serialize(invoiceRequest,true);
        String correlationId = EDISSingleManager.getUID();
        HttpResponse response;
        try {
            
           // String token = AuthenticationManager.getOauthToken(handlerName);
           String token = AuthenticationManager.getOauthToken(handlerName);
            //String token = 'xQS1L5gsi9TlQarU5G5AvJAaG7pp';
            Map < String, String > headerMap = new Map < String, String > {
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer ' + token,
                'correlationId' => correlationId
            };
                response = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName);
            system.debug('response::' + response.getBody());
            String responseCode = String.valueOf(response.getStatusCode());
            if (responseCode.startsWith('2')) {
                res = OneFundInvoiceResponseDTO.parse(response.getBody());
                System.debug('res: '+res);
              // logger.logMessages(reqBody, response.getBody(), '', '', '', '', false, false,Integer.valueof(response.getStatusCode()) , null, null, null);
               
            } else if (responseCode.startsWith('4') || responseCode.startsWith('5')) {
                res = OneFundInvoiceResponseDTO.parse(response.getBody());
                logger.logMessages(reqBody, response.getBody(), '', '', '', '', false, false, Integer.valueOf(response.getStatusCode()) , null, null, null);
            }
            logger.exitLogger();
        } catch (Exception e) {
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();
        }
        return response;
    }




/*-------------------------------------------------------- 
EDGE-124053
Method: createPayload
Description: Method to create payload for Invoice Number
Author:Hari
--------------------------------------------------------*/

public static OneFundInvoiceRequestDTO createPayload(String customerAccountNumber,Long invoiceNumber){
    
        OneFundInvoiceRequestDTO requestDto = new OneFundInvoiceRequestDTO();
        requestDto.customerAccountNumber=customerAccountNumber;
        requestDto.invoiceNumber=invoiceNumber;
        return requestDto;
    }
    
    
    
    
        public static EligibleRedemptionAmountResponseDTO calloutQLI1(EligibleRedemAmountRequestDTO QLI_DTO){
            system.debug('111========>2');
            String INTEGRATION_HANDLER_NAME = 'OneFundEligibleRedemptionAmount';
        //HttpResponse response        = null;
        Logger2 logger2               = Logger2.getLogger(INTEGRATION_HANDLER_NAME);
        String reqBody               = JSON.serialize(QLI_DTO,true);
        System.debug('2nd call request body'+reqBody);
        String correlationId         = EDISSingleManager.getUID();
        Integration_Handler__mdt handleSettingRecord = IntegrationRecordHandlerUtil.getIntegrationHandlerSettings(INTEGRATION_HANDLER_NAME);
        String token;
         
         token = AuthenticationManager.getOauthToken(INTEGRATION_HANDLER_NAME);
        
        Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token,'correlationId'=>correlationId};
        Datetime sdt = Datetime.now();
        Long requestStartTime  = sdt.getTime();
   HttpResponse  response  = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, INTEGRATION_HANDLER_NAME);
        Datetime edt = Datetime.now();
        Long requestEndTime = edt.getTime();
        Long finalTime = requestStartTime-requestEndTime;
        System.debug('calloutQLI :: response :: '+response);
        System.debug('calloutQLI :: response.getBody() :: '+response.getBody());
        if(response != null && response.getStatusCode() == IntegrationRecordHandlerUtil.HTTP_SUCCESS)//200
        {    
            logger2.logMessages(JSON.serialize(reqBody), response.getBody(),'', '', '', '',''+response.getStatusCode(),correlationId, NULL,NULL,NULL, 'Read',finalTime,IntegrationRecordHandlerUtil.HTTP_METHOD_POST,false,false);
           
            EligibleRedemptionAmountResponseDTO resData  = EligibleRedemptionAmountResponseDTO.parse(response.getBody());

             return resData;
             
        } 
        else{
            String errorMessage = 'calloutQLI :: Invalid response code for "Billing Line Item Adjustment. "'+response+' :: '+response.getBody();
            logger2.logMessages(JSON.serialize(reqBody), response.getBody(),'', '', '', '',''+response.getStatusCode(),correlationId, NULL,NULL,NULL, 'Read',finalTime,IntegrationRecordHandlerUtil.HTTP_METHOD_POST,false,false);           
            throw new CustomException(errorMessage);
        }
        
        
            
        }
    
}