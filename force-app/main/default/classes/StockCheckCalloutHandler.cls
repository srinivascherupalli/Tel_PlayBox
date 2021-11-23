/*******************************************************************************************************************
Name : StockCheckCalloutHandler
EDGE-> 80857, 80860
Description : To make a callout to the Stock Check API to get the stock availability details of the selected product
====================================================================================================================
Sr.No.    Developer Name            Date                         Story Description
1.        Ravi Shankar          12/06/2019          As a salesforce user, I want to Perform Stock Check for the selected device
                                                    so that I can present the information to customer : Stock Enquiry API Consumption
2.      Kalashree Borgaonkar    10/102019           As a salesforce user, I want to perform Stock Check for multiple selected 
                                                    Mobile/NGUC devices 
====================================================================================================================
********************************************************************************************************************/

public without sharing class StockCheckCalloutHandler{
    public static final String HANDLER =  'ProductStockCheckHandler';
    public static final String HANDLER_MULTIPLE =  'MultipleStockCheckHandler';
    public String productNum = null;
    public String lobCode = Label.Stock_Check_LOB;
    public Static Logger2 logger = Logger2.getLogger(HANDLER);
    
    public StockCheckResponseDto syncExecute(String ProductId) {//token request
        this.productNum = ProductId;
        StockCheckResponseDto resDto = new StockCheckResponseDto();
        try{
            if(!String.isBlank(ProductId)){
                String token = AuthenticationManager.getOauthToken(HANDLER);
                resDto = callStockCheckService(token);
            }
        }
        catch(exception e){
            system.debug(e.getMessage() + ';' + string.valueOf(e.getLineNumber()));
            logger.logMessages('StockCheckTokenRequestCalloutException', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
        }
        return resDto;
    }
    
    public StockCheckResponseDto callStockCheckService(String token){//api call
        StockCheckResponseDto responseDTO =null;        
        HttpResponse res;
        String payload = '';
        try{
            String correlationId = IntegrationRecordHandlerUtil.getCorrelationId();
            payload = productNum+'/inventory?includeDescription=true&lineOfBusinessCode='+lobCode;
            Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token,'Correlation_Id'=> +correlationId};
            DateTime startTime = DateTime.now();    
            res = IntegrationRecordHandlerUtil.callout(payload,'GET',headerMap,HANDLER,null,null);
            DateTime endTime = DateTime.now();
            Long requestTime = Logger.getRequestTimeDifference(startTime, endTime);
            System.debug('stockCheckRes: '+res);            
            if (res.getStatusCode() == 200 || res.getStatusCode() == 201 || res.getStatusCode() == 202) {
                responseDTO = StockCheckResponseDto.parse(res.getBody());
                System.debug('stockCheckRes: '+responseDTO);
                //logger.logMessages(payload, res.getBody(), '', '', '', '', false, false,Integer.valueof('200') , null, null, null);
                logger.logMessages(payload, res.getBody(), '', '', '', 
                                       '', String.valueOf(res.getStatusCode()), correlationId, '','','','Create',requestTime ,'POST',false, false);
                    
            }
            else {
                responseDTO = StockCheckResponseDto.parse(res.getBody());
                system.debug('responseDTO' +responseDTO);
                //logger.logMessages(payload, res.getBody(), '', '', '', '', false, false, Integer.valueOf('111') , null, null, null);
                logger.logMessages(payload, res.getBody(), '', '', '', 
                                       '', String.valueOf(res.getStatusCode()), correlationId, '','','','Create',requestTime ,'POST',false, false);
            
            }
                
        }catch (Exception e) {
            logger.logMessages('StockCheckCalloutException', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage()+';'+e.getLineNumber(), false, false);            
        }       
        logger.exitLogger();
        return responseDTO ;
    }
    /*-------------------------------------------------------- 
EDGE-80860
Method: createPayload
Description: create Payload for multiple stock check
Author:Kalashree Borgaonkar
--------------------------------------------------------*/
    public static StockCheckRequestDto createPayload(List<String> skuIdList){
        StockCheckRequestDto requestDto = new StockCheckRequestDto();
        StockCheckRequestDto.Products product=null;
        List<StockCheckRequestDto.Products> productList= new List<StockCheckRequestDto.Products>();
        requestDto.lineOfBusinessCode=Label.LineOfBusinessCode;
        for(String skuId: skuIdList){
             product = new StockCheckRequestDto.Products();
             product.id = skuId;
             productList.add(product);
        }
        requestDto.products = productList;
        return requestDto;
    }
     /*-------------------------------------------------------- 
EDGE-80860
Method: 
Description: callout for multpile stock check api
Author:Kalashree Borgaonkar
--------------------------------------------------------*/
     public static StockCheckResponseDto calloutToStockCheck(StockCheckRequestDto stockRequest)
    {
        Logger2 logger = Logger2.getLogger(HANDLER_MULTIPLE);
        StockCheckResponseDto res = new StockCheckResponseDto();
        String reqBody = JSON.serialize(StockRequest,true);
        HttpResponse response;
        try {
           String correlationId = IntegrationRecordHandlerUtil.getCorrelationId();
           //String token = AuthenticationManager.getOauthToken(HANDLER_MULTIPLE);
           String token;
           Integration_Handler__mdt handleSettingRecord = IntegrationRecordHandlerUtil.getIntegrationHandlerSettings(HANDLER_MULTIPLE);
           if(handleSettingRecord!=null) {
                if(handleSettingRecord.Enable_Mock_Integration__c) {
                    token=System.Label.QLI_Token;
                }
                else {
                    token = AuthenticationManager.getOauthToken(HANDLER_MULTIPLE);
                }
            }
            Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token,'Correlation_Id'=> +correlationId};
            DateTime startTime = DateTime.now();    
            response = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, HANDLER_MULTIPLE);
            DateTime endTime = DateTime.now();
            Long requestTime = Logger.getRequestTimeDifference(startTime, endTime);
                
            system.debug('response::' + response.getBody());
            String responseCode = String.valueOf(response.getStatusCode());
            if (responseCode.startsWith('2')) {
                res = StockCheckResponseDto.parse(response.getBody());
                System.debug('res: '+res);
                //logger.logMessages(reqBody, response.getBody(), '', '', '', '', false, false,Integer.valueof(response.getStatusCode()) , null, null, null);
                logger.logMessages(reqBody, response.getBody(), '', '', '', 
                                       '', String.valueOf(response.getStatusCode()), correlationId, '','','','Create',requestTime ,'POST',false, false);
            
            }
            else if (responseCode.startsWith('4') || responseCode.startsWith('5')){
                res = StockCheckResponseDto.parse(response.getBody());
                logger.logMessages(reqBody, response.getBody(), '', '', '','', String.valueOf(response.getStatusCode()), 
                                   correlationId, '','','','Create',requestTime ,'POST',false, false);
            
                //logger.logMessages(reqBody, response.getBody(), '', '', '', '', false, false, Integer.valueOf(response.getStatusCode()) , null, null, null);
            }
            logger.exitLogger();
        }
        catch (Exception e) {
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();
        }
        return res;
    }  
}