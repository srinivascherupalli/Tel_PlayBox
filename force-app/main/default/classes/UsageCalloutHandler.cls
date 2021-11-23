/*************************************************************************************************
Name : UsageCalloutHandler
Description : Service class for Usage API
Author: Sasidhar Devarapalli
Story: EDGE-108332
Team: Osaka
***************************************************************************************************/
public with sharing class UsageCalloutHandler {
    public static final String  handlerName = 'UsageDetailsHandler'; 
    
    public static String calloutUsageDetails(UsageRequestDTO  usageRequest){
        Logger2 logger = Logger2.getLogger(handlerName);
        String reqBody = JSON.serialize(usageRequest,true);
        String correlationId = EDISSingleManager.getUID();
        HttpResponse usageResponse;
        try {
 			String token = 'xQS1L5gsi9TlQarU5G5AvJAaG7pp';
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
                    'correlationId' => correlationId
                    };
                        usageResponse = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName);
            System.debug('usageResponse::' + usageResponse.getBody());
            String responseCode = String.valueOf(usageResponse.getStatusCode());
            if (responseCode.startsWith('2')) {
                String responseTemp = usageResponse.getBody();
                responseTemp = responseTemp.replace('"date"','"date_x"');
                responseTemp = responseTemp.replace('"time"','"time_x"');
                System.debug('reqBody--->'+reqBody);
                logger.logMessages(reqBody, usageResponse.getBody(), '', '', '', '', false, false,Integer.valueof(usageResponse.getStatusCode()) , null, null, null);
                
            }else if (responseCode.startsWith('4') || responseCode.startsWith('5')) {
                logger.logMessages(reqBody, usageResponse.getBody(), '', '', '', '', false, false, Integer.valueOf(usageResponse.getStatusCode()) , null, null, null);
            }
            logger.exitLogger();
        } catch (Exception e) {
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();
        }
        return usageResponse.getBody();
    }
    
    /*----------------------------------------------------------------
Method     : getInvoiceDetails
Description: Method to get Invoice charge details for corresponding Invoice
Author     : Pradeep
Story      : EDGE-163366 
-------------------------------------------------------------------------------------*/  
    public static Map<Integer,String> calloutInvoiceDetails(String requestDTO,String handler)
    {
         Logger2 logger = Logger2.getLogger(handler);
         HttpResponse invoiceResponse;
         Map<Integer,String> mapResponse=new Map<Integer,String>();
         Integer httpCode; 
         String correlationId = EDISSingleManager.getUID();
         String token = 'xQS1L5gsi9TlQarU5G5AvJAaG7pp';
        try{
         token = InvoiceCalloutHandler.setToken(handler);
         Map < String, String > headerMap = new Map < String, String > {'Content-Type' => 'application/json','Authorization' => 'Bearer ' + token,'correlationId' => correlationId};
         invoiceResponse=IntegrationRecordHandlerUtil.calloutSync(requestDTO, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handler);
         mapResponse.put(invoiceResponse.getStatusCode(),invoiceResponse.getBody());
         logger.logMessages(requestDTO, invoiceResponse.getBody(), '', '', '', '', false, false, Integer.valueof(invoiceResponse.getStatusCode()), null, null, null); 
         logger.exitLogger();
        }
         catch (Exception e) {
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();
        }
        return mapResponse;
    }
}