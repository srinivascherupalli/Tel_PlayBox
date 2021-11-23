public with sharing class FNNService
{  
    public FNNResponseDTO searchFNN(FNNDTO fnnDto){
        String handlerName = 'SearchFNNHandler';
        String reqBody = JSON.serialize(fnnDto,true);
        Logger2 logger = Logger2.getLogger(handlerName);
        FNNResponseDTO fnnRes = new FNNResponseDTO() ;
        HttpResponse adResponse;
        try {
            String token = AuthenticationManager.getOauthToken(handlerName);
            //String token = 'AuthenticationManager.getOauthToken(handlerName)';
          
            System.debug('AuthenticationToken::' + token);
            Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token};
            adResponse = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName);
            system.debug('adResponse::'+adResponse.getBody());
            if (adResponse.getStatusCode() == 200 || adResponse.getStatusCode() == 201 || adResponse.getStatusCode() == 202) {
                fnnRes = FNNResponseDTO.parse(adResponse.getBody());
                logger.logMessages(reqBody, adResponse.getBody(), '', '', '', '', false, false,Integer.valueof(adResponse.getStatusCode()) , null, null, null);
            }
            else{
                logger.logMessages(reqBody, adResponse.getBody(), '', '', '', '', false, false, Integer.valueOf(adResponse.getStatusCode()) , null, null, null);
            }
            logger.exitLogger();
        }
        catch (Exception e) {
                logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
                logger.exitLogger();
        }
        return fnnRes;
    }

    public FNNResponseDTO reserveFNN(FNNDTO fnnDto){
        String handlerName = 'ReserveFNNHandler';
        String reqBody = JSON.serialize(fnnDto,true);
        Logger2 logger = Logger2.getLogger(handlerName);
        FNNResponseDTO fnnRes = new FNNResponseDTO() ;
        HttpResponse adResponse;
        try {
            String token = AuthenticationManager.getOauthToken(handlerName);
            //String token = 'AuthenticationManager.getOauthToken(handlerName)';
            
            System.debug('AuthenticationToken::' + token);
            Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token};
            adResponse = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName);
            system.debug('adResponse::'+adResponse.getBody());
            if (adResponse.getStatusCode() == 200 || adResponse.getStatusCode() == 201 || adResponse.getStatusCode() == 202) {
                fnnRes = FNNResponseDTO.parse(adResponse.getBody());
                logger.logMessages(reqBody, adResponse.getBody(), '', '', '', '', false, false,Integer.valueof(adResponse.getStatusCode()) , null, null, null);
            }
            else{
                logger.logMessages(reqBody, adResponse.getBody(), '', '', '', '', false, false, Integer.valueOf(adResponse.getStatusCode()) , null, null, null);
            }
            logger.exitLogger();
        }
        catch (Exception e) {
                logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
                logger.exitLogger();
        }
        return fnnRes;
    }
    
    public FNNResponseDTO searchReserveMSISDN(FNNDTO fnnDto){
        String handlerName = 'SearchReserveMSISDNHandler';
        String reqBody = JSON.serialize(fnnDto,true);
        Logger2 logger = Logger2.getLogger(handlerName);
        FNNResponseDTO fnnRes = new FNNResponseDTO() ;
        HttpResponse adResponse;
        try {
            String token = AuthenticationManager.getOauthToken(handlerName);
            System.debug('AuthenticationToken::' + token);
            Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token};
            adResponse = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName);
            system.debug('adResponse::'+adResponse.getBody());
            if (adResponse.getStatusCode() == 200 || adResponse.getStatusCode() == 201 || adResponse.getStatusCode() == 202) {
                fnnRes = FNNResponseDTO.parse(adResponse.getBody());
                logger.logMessages(reqBody, adResponse.getBody(), '', '', '', '', false, false,Integer.valueof(adResponse.getStatusCode()) , null, null, null);
            }
            else{
                logger.logMessages(reqBody, adResponse.getBody(), '', '', '', '', false, false, Integer.valueOf(adResponse.getStatusCode()) , null, null, null);
            }
                logger.exitLogger();
            }
            catch (Exception e) {
                logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
                logger.exitLogger();
            }
            return fnnRes;
        }
        
        
    public FNNResponseDTO unReserveFNN(FNNDTO fnnDto){
        String handlerName = 'UnReserveFNNHandler';
        String reqBody = JSON.serialize(fnnDto,true);
        Logger2 logger = Logger2.getLogger(handlerName);
        FNNResponseDTO fnnRes = new FNNResponseDTO() ;
        HttpResponse adResponse;
        try {
            String token = AuthenticationManager.getOauthToken(handlerName);
          
            System.debug('AuthenticationToken::' + token);
            Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token};
            adResponse = IntegrationRecordHandlerUtil.calloutSync(reqBody,'DELETE',headerMap, handlerName);
            system.debug('adResponse::'+adResponse.getBody());
            if (adResponse.getStatusCode() == 200 || adResponse.getStatusCode() == 201 || adResponse.getStatusCode() == 202) {
                fnnRes = FNNResponseDTO.parse(adResponse.getBody());
                logger.logMessages(reqBody, adResponse.getBody(), '', '', '', '', false, false,Integer.valueof(adResponse.getStatusCode()) , null, null, null);
            }
            else{
                logger.logMessages(reqBody, adResponse.getBody(), '', '', '', '', false, false, Integer.valueOf(adResponse.getStatusCode()) , null, null, null);
            }
            logger.exitLogger();
        }
        catch (Exception e) {
                logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
                logger.exitLogger();
        }
        return fnnRes;
    }
}