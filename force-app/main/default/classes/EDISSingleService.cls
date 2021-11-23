/***************************************************************************************************************************
*Class Name : EDISSingleService
*Description: EDIS interface
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1. 			Vanita Mude				30/12/2019   EDGE-127368- CLF changes done under the tech debt story
2.          Sayantan Halder         17/06/2021   EDGE-222599- Bypassing json parsing
****************************************************************************************************************************/
public with sharing class EDISSingleService {
    
    
    public static void searchlisting(EDISSingleRequestDTO EDISDto, String handlerName){
        Blob aesKey = Crypto.GenerateAESKey(128);
        String GUID = EncodingUtil.ConvertTohex(aesKey);
        IntegrationRecordHandlerUtil.createRequests(handlerName, new List<String>{GUID},JSON.serialize(EDISDto));
    }
    
    @future(callout=true)
    public static void callEDISSingleService(String param, String handlerName){
        System.debug('I am inside::' +':param:' + param  + ':handlerName:'+handlerName);
        Integer status = NULL;
        String responseCode = NULL;
        String res_time = NULL;
        //  String correlationId = NULL;
        
        Logger2 logger2 = Logger2.getLogger(handlerName);
        Integration_Record__c paramRequest = [SELECT Id, params__c, paramPayload__c FROM Integration_Record__c WHERE params__c = :param LIMIT 1 ];
        System.debug('paramRequest::' + paramRequest);
        String EDISDtoJson =  paramRequest.paramPayload__c;
        system.debug('EDISDtoJson '+EDISDtoJson);
        EDISSingleRequestDTO dto = (EDISSingleRequestDTO) JSON.deserialize(EDISDtoJson, EDISSingleRequestDTO.class);
        String token = AuthenticationManager.getOauthToken(handlerName);
        String correlationId = IntegrationRecordHandlerUtil.getCorrelationId();
        
        //String token= 'abcdefghijk';
        
        //System.debug('AuthenticationToken::' + token);
        Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer '+ token};
            EDISSingleRequestDTO EdisReq = EDISSingleTransformer.fromDTOtoRequest(dto);
        //CLF changes startTime,endTime
        DateTime startTime = DateTime.now();
        HTTPResponse reponse = IntegrationRecordHandlerUtil.callout(JSON.serialize(EdisReq), IntegrationRecordHandlerUtil.HTTP_METHOD_POST,headerMap, handlerName, new List<String>{param},null);
        System.debug('reponse-> '+reponse);
        DateTime endTime = DateTime.now();
        Long requestTime = logger2.getRequestTimeDifference(startTime, endTime);
        //Request was successfully accepted
        if(reponse != null && reponse.getStatusCode() == IntegrationRecordHandlerUtil.HTTP_ACCEPTED) {EDISSingleResponseDTO EDISRes = EDISSingleResponseDTO.parse(reponse.getBody());
                                                                                                      System.debug('Response::' + EDISRes);
                                                                                                      //logger2.logMessages(JSON.serialize(EdisReq), reponse.getBody(), '', '', '', '', false, false, Integer.valueOf(reponse.getStatusCode()) , null, null, null);
                                                                                                      
                                                                                                      //CLF start
                                                                                                      logger2.logMessages(JSON.serialize(EdisReq), reponse.getBody(), '', '', '', 
                                                                                                                          '', String.valueOf(reponse.getStatusCode()), correlationId, '','','Read','',requestTime ,'POST',false, false);
                                                                                                      //CLF end
                                                                                                     }
        
        else
        {
            if(reponse != null && !String.isEmpty(reponse.getBody())) {
                //EDISSingleErrorResponseDTO EDISRes = EDISSingleErrorResponseDTO.parse(reponse.getBody()); //EDGE-222599
                //System.debug('Response::' + EDISRes);
                // logger2.logMessages(JSON.serialize(EdisReq), reponse.getBody(), '', '', '', '', false, false, Integer.valueOf(reponse.getStatusCode()) , null, null, null);
                //CLF Start - EDGE-127368
                logger2.logMessages(JSON.serialize(EdisReq), reponse.getBody(), '', '',  '', 
                                    '', String.valueOf(reponse.getStatusCode()), correlationId, '','','Read','',requestTime ,'POST',false, false);
                //CLF end - EDGE-127368
            }
            else { 
                //logger2.logMessages(JSON.serialize(EdisReq), null, '', '', '', '', false, false, null , null, null, null);
                ////CLF Start - EDGE-127368
                logger2.logMessages(JSON.serialize(EdisReq), null, '', '',  '', 
                                    '', null, correlationId, '','','Read','',requestTime ,'POST',false, false);
                //CLF end - EDGE-127368
                
            }            
        }
        
    }
    
}