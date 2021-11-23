/**************************************************************************************
1.            Sayantan               17/06/2021     EDGE-222599 EDGE-222599- Bypassing json parsing
***************************************************************************************/
global with sharing class EDISDirectoryService implements Queueable, Database.AllowsCallouts{
    public List<EDISSingleRequestDTO> EDISRequestDtoList;
    public Integer calloutCounter;
    public Logger2 logger;
    public String handlerName;
    
    
    
    public EDISDirectoryService(List<EDISSingleRequestDTO> ListOfDTO){
        this.EDISRequestDtoList=ListOfDTO;
        this.calloutCounter = 0;
        this.handlerName = 'SingleFNNListingHandler';
        this.logger = Logger2.getLogger(handlerName);
    }
       
    public void execute(QueueableContext context) {
        //String token = 'lFYpKM2LkokcsbzQFKfsMTiPeFcA';
        String token = AuthenticationManager.getOauthToken(handlerName);
        callEDISSingleService(token);
        
    }
        
    public void callEDISSingleService(String token){
        Integer status = NULL;
        String responseCode = NULL;
        String res_time = NULL;
        String correlationId = NULL;
        EDISSingleResponseDTO EDISRes = new EDISSingleResponseDTO() ;
        Map<String, HttpResponse> HttpResponseMap = new Map<String, HttpResponse>();
        HttpResponse adResponse;
        String orderIdValue = '';
        try {
            for(EDISSingleRequestDTO edto:EDISRequestDtoList){
                String reqBody = JSON.serialize(edto,true);
                String ordrIdStr =reqBody.substringBetween('orderID','listCode');
                orderIdValue =ordrIdStr.replaceALL('[,:""]','');
                System.debug('orderIdValue ====>'+orderIdValue );
                Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token};
                    adResponse = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName);
                calloutCounter++;
                HttpResponseMap.put(reqBody, adResponse);
            }
            if(calloutCounter == EDISRequestDtoList.size()){
                for(String reqBody : HttpResponseMap.keySet()){
                   HttpResponse res = HttpResponseMap.get(reqBody);
                    if (res.getStatusCode() == 200 || res.getStatusCode() == 201 || res.getStatusCode() == 202) {
                        EDISRes = EDISSingleResponseDTO.parse(res.getBody());
                        logger.logMessages(reqBody, res.getBody(), '', '', '', '', false, false,Integer.valueof(res.getStatusCode()) ,orderIdValue, null, null);
                        }
                    else{
                        //EDISSingleErrorResponseDTO EDISResErr = EDISSingleErrorResponseDTO.parse(res.getBody());
                        logger.logMessages(reqBody, res.getBody(), '', '', '', '', false, false, Integer.valueOf(res.getStatusCode()) ,orderIdValue, null, null);
                        }
                    }
                    logger.exitLogger();
        }
        }
        catch (Exception e) {
                logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
                logger.exitLogger();
        }
        }
        
    }