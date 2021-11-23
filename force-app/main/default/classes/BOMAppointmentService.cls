/**
  Author: Ila/Aishwarya/Jawahar/Ravi/Kala
  Company: Tesltra 
   User Story :EDGE-66226/66239/66474/70304
   Description : This class exposes BOM Slot Availability related operations to BOM SlotManager class
     */
    public with sharing class BOMAppointmentService {
       
        private static BOMAppointmentService singleton = new BOMAppointmentService( );
        private BOMAppointmentService(){
        }
        private static final String ENDPOINT = 'endpoint';
        private static final String CLIENT_ID = 'client_id';
        private static final String CLIENT_SECRET = 'client_secret';
        private static final String GRANT_TYPE = 'grant_type';
        private static final String SCOPE = 'scope';
        private static final String ENABLE_MOCKS = 'enable_mocks';
        private static final String METHOD = 'method';
        private static final String MOCK_ENDPOINT = 'mock_endpoint';
        private static final String ACCESS_TOKEN = 'access_token';
        // Added new field to support MASSL 
        private static final String ENABLE_MASSL = 'enable_massl';
        public static BOMAppointmentService getInstance( ) {
          return singleton;
        }    
         
        /**
         * EDGE-66466
         * <15-04-2019> <Jawahar>
         * Method to call QueryAppointmentAPI to check Availability for Site
         *
         * @params  AppointmentSearchRequestDTO - DTO Class for BOM Slot Availability Request   
         * @return  AppointmentSearchResponseDTO Class - DTO Class for BOM Slot Availability Response
         */
        public static AppointmentSearchResponseDTO searchAppointment(AppointmentSearchRequestDTO request){
            //String handlerName = 'SearchAppoimentSlot';
            //String handlerName ='GenerateAppointmentHandler';
            String handlerName = 'SearchAppointment';
            String reqBody = JSON.serialize(request,true);
            Logger2 logger = Logger2.getLogger(handlerName);
            AppointmentSearchResponseDTO slotdetails = new AppointmentSearchResponseDTO() ;
                HttpResponse adResponse;
                try {
                    //String token = 'aJ1AUZuZdKBUWb7s22OhejvWKRzU';//ila
                    //String token = 'sdk23sdf5asASDe45dfgdRRF';
                    String token = AuthenticationManager.getOauthToken(handlerName);
                    Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token,'callingSystemID' => 'COM-B2B-FORCE'};
                    adResponse = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName);
                    system.debug('adResponse'+adResponse.getBody() +'Response Code '+adResponse.getStatusCode());
                    system.debug('Response ---->>>>'+adResponse.getBody());
                    if (adResponse.getStatusCode() == 200 || adResponse.getStatusCode() == 201 || adResponse.getStatusCode() == 202) {
                        
                        system.debug('Status Code --->>>>'+adResponse.getBody());
                        slotdetails = AppointmentSearchResponseDTO.parse(adResponse.getBody());
                        system.debug('Slot Details -->>>>'+slotdetails);
                        logger.logMessages(reqBody, adResponse.getBody(), '', '', '', '', false, false,Integer.valueof(adResponse.getStatusCode()) , null, null, null);
                    }else{
                        logger.logMessages(reqBody, adResponse.getBody(), '', '', '', '', false, false, Integer.valueOf(adResponse.getStatusCode()) , null, null, null);
                    }
                    logger.exitLogger();
                } catch (Exception e) {
                    logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
                    logger.exitLogger();
                }
            return slotdetails;
        }

    /**
         * Method to call ReserveAppointmentAPI to check Availability for Site
         *
         * @params  AppointmentBOMReserveRequestDTO - DTO Class for BOM Slot Reserve Request   
         * @return  AppointmentBOMReserveResponseDTO  Class - DTO Class for BOM Slot Reserve Response
         */
        public static AppointmentBOMReserveResponseDTO reserveAppointment(AppointmentBOMReserveRequestDTO request, String slotId){
            String handlerName = 'ReserveAppointmentBOM';
            String reqBody = JSON.serialize(request,true);
            Logger2 logger = Logger2.getLogger(handlerName);
            //string slotid=slotId;
            //Map<String, String> pathMap = new Map<String, String>{slotId => ''};
            AppointmentBOMReserveResponseDTO resDetails=new AppointmentBOMReserveResponseDTO();
            HttpResponse adResponse;
            try {
                //String token = 'aJ1AUZuZdKBUWb7s22OhejvWKRzU';
                String token = AuthenticationManager.getOauthToken(handlerName);
                Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token, 'callingSystemID' => 'COM-B2B-FORCE'};
                adResponse = calloutLRM(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName,null,null,slotId);
                system.debug('adResponse'+adResponse.getBody());
                if (adResponse.getStatusCode() == 200 || adResponse.getStatusCode() == 201 || adResponse.getStatusCode() == 202) {
                    resDetails = AppointmentBOMReserveResponseDTO.parse(adResponse.getBody());
                    logger.logMessages(reqBody, adResponse.getBody(), '', '', '', '', false, false,Integer.valueof(adResponse.getStatusCode()) , null, null, null);
                }else{
                    logger.logMessages(reqBody, adResponse.getBody(), '', '', '', '', false, false, Integer.valueOf(adResponse.getStatusCode()) , null, null, null);
                }
                logger.exitLogger();
            } catch (Exception e) {
                logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
                logger.exitLogger();
            }

            return resDetails;
        }
        public static HTTPResponse calloutLRM(String payload, String method, Map<String,String> headerMap, String handlerName, List<String> params, String correlationId,String url) {
            String errorMessage;
            String endPoint = null;
            Logger log = String.isBlank(correlationId) ? Logger.getLogger(handlerName) : Logger.getLogger(handlerName + ':' + correlationId);
            HTTPResponse res;
            Integration_Handler__mdt handleSettingRecord = IntegrationRecordHandlerUtil.getIntegrationHandlerSettings(handlerName);
            if(handleSettingRecord != null) {
                if(handleSettingRecord.Enable_Mock_Integration__c) {
                    endPoint = handleSettingRecord.Mock_End_Point__c != null? handleSettingRecord.Mock_End_Point__c : '';
                }
                else {
                    endPoint = handleSettingRecord.End_Point__c != null? handleSettingRecord.End_Point__c : '';
                }
                
                    endPoint += '/' + url;
                
            }
            Integer timeout = handleSettingRecord != null && handleSettingRecord.Timeout__c != null? handleSettingRecord.Timeout__c.intValue() : Integer.valueOf(Label.INT_MAX_TIMEOUT);
            if(String.isBlank(endPoint)) {
                System.debug('Cannot make a callout without an Endpoint');
                return null;
            }
            HttpRequest req = new HttpRequest();
            if(method =='GET'){
            if(handleSettingRecord.Append_URL_Params_without_question_mark__c){
                req.setEndpoint(endPoint+ '/' +payload);    
            }else{
                req.setEndpoint(endPoint+ '?' +payload);    
            }
            }else{
                req.setEndpoint(endPoint);
                if(payload != NULL){
                    req.setBody(payload);}
            }
            if(handleSettingRecord.Enable_MASSL__c) {
                System.debug('MASSL is enabled for interface');
                String certificateName = null;
                certificateName = EnvironmentVariable.get('massl_certificate_name');
                System.debug('Setting ' + certificateName + ' certificate for http call');
                if(certificateName!=null){
                       req.setClientCertificateName(certificateName);
                }
            }
            req.setMethod(method);
            req.setTimeout(timeout);
            if(headerMap != null) {
                for(String hdName : headerMap.keySet()) {
                    req.setHeader(hdName, headerMap.get(hdName));    
                }
            }
            try {
                Http http = new Http();
                res = http.send(req);
                if(!handleSettingRecord.Is_Sync_Call__c){
                    if(res.getStatusCode() != 200 && res.getStatusCode() != 202) { 
                        System.debug('##### INVALID STATUS CODE ' + res.getStatusCode());        
                        errorMessage = 'A HTTP error occurred' +  '\n' + 'Status Code: ' + res.getStatusCode() + '\n' + 'Status Message: ' + res.getStatus();  
                        IntegrationQueuableUtils.retry(handlerName, params, errorMessage); //retry                
                        System.debug('For handler: ' + handlerName + ' Error Response: '+ errorMessage);
                    } else {
                        System.debug('##### Success'); System.debug('For handler: ' + handlerName + ' got success Response');
                        IntegrationQueuableUtils.updateOnSucess(handlerName, params);
                    }
                }
            } catch(System.Exception e) {
                if(!handleSettingRecord.Is_Sync_Call__c){
                IntegrationQueuableUtils.retry(handlerName, params, (e.getMessage() + '\n\n' + e.getStackTraceString())); //retry    
                }      
            }
            finally {
                if(handleSettingRecord.Is_Sync_Call__c) {
                    Logger.exitLogger();    
               }
            }
            return res;
        }
        
        /*------------------------------------------------------------ 
        //EDGE-66449 and EDGE-66475
        Method: rebookAppointment 
        Description: Search slots for Rebook Appointment
        <29-04-2019> <Jawahar> <Ila>
        ------------------------------------------------------------*/
         public static AppointmentSearchResponseDTO searchRebookAppointment(AppointmentBOMRebookSearchRequestDTO request, String appointmentId){
            String handlerName = 'SearchRebookAppointment';
            String reqBody = JSON.serialize(request,true);
            Logger2 logger = Logger2.getLogger(handlerName);
            Map<String, String> pathMap = new Map<String, String>{appointmentId => 'generate-rebook-slot'};
            AppointmentSearchResponseDTO rescheduleSlotdetails = new AppointmentSearchResponseDTO() ;
                HttpResponse adResponse;
                try {
                    //String token = 'aJ1AUZuZdKBUWb7s22OhejvWKRzU';
                    String token = AuthenticationManager.getOauthToken(handlerName);
                    Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token, 'callingSystemID' => 'COM-B2B-FORCE'};
                    adResponse = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName,pathMap);
                    system.debug('adResponse'+adResponse.getBody());
                    if (adResponse.getStatusCode() == 200 || adResponse.getStatusCode() == 201 || adResponse.getStatusCode() == 202) {
                        rescheduleSlotdetails = AppointmentSearchResponseDTO.parse(adResponse.getBody());
                        logger.logMessages(reqBody, adResponse.getBody(), '', '', '', '', false, false,Integer.valueof(adResponse.getStatusCode()) , null, null, null);
                    }else{
                        logger.logMessages(reqBody, adResponse.getBody(), '', '', '', '', false, false, Integer.valueOf(adResponse.getStatusCode()) , null, null, null);
                    }
                    logger.exitLogger();
                } catch (Exception e) {
                    logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
                    logger.exitLogger();
                }
            return rescheduleSlotdetails;
        }

        /*------------------------------------------------------------ 
        //EDGE -70303
        Method: rescheduleAppointment 
        Description: Search slots for Reschedule Appointment
        <29-04-2019> <Ravi Shankar>
        ------------------------------------------------------------*/
         public static AppointmentSearchResponseDTO searchReschedAppointment(AppointmentSearchRequestDTO request, String appointmentId){
            String handlerName = 'AppointmentReschedule';
            String reqBody = JSON.serialize(request,true);
            Logger2 logger = Logger2.getLogger(handlerName);
            Map<String, String> pathMap = new Map<String, String>{appointmentId => 'generate-reschedule-slot'};
            AppointmentSearchResponseDTO rescheduleSlotdetails = new AppointmentSearchResponseDTO() ;
                HttpResponse adResponse;
                try {              
                    String token = AuthenticationManager.getOauthToken(handlerName);
                    //String token ='sdfsdsg486583jfnkjdsngkj';
                    Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token,'callingSystemID' => 'COM-B2B-FORCE'};              
                    adResponse = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName,pathMap);
                    system.debug('adResponse'+adResponse.getBody());
                    if (adResponse.getStatusCode() == 200 || adResponse.getStatusCode() == 201 || adResponse.getStatusCode() == 202) {
                        rescheduleSlotdetails = AppointmentSearchResponseDTO.parse(adResponse.getBody());
                        logger.logMessages(reqBody, adResponse.getBody(), '', '', '', '', false, false,Integer.valueof(adResponse.getStatusCode()) , null, null, null);
                    }else{
                        logger.logMessages(reqBody, adResponse.getBody(), '', '', '', '', false, false, Integer.valueOf(adResponse.getStatusCode()) , null, null, null);
                    }
                    logger.exitLogger();
                } catch (Exception e) {
                    logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage()+';'+e.getLineNumber(), false, false);
                    logger.exitLogger();
                }
            return rescheduleSlotdetails;
        }    
         /*------------------------------------------------------------ 
    //EDGE -66470
    Method: rescheduleAppointment 
    Description: Initiate Appointment BOM API for reschedule
    History 
    <26-04-2019> <Kalashree Borgaonkar>
    ------------------------------------------------------------*/
        public static AppointmentBOMReserveResponseDTO rescheduleAppointment(AppointmentBOMReserveRequestDTO request, String slotId,String appointmentid){
            String handlerName = 'RescheduleAppointmentBOM';
            String reqBody = JSON.serialize(request,true);
            Logger2 logger = Logger2.getLogger(handlerName);
            //string slotid=slotId;
            Map<String, String> pathMap = new Map<String, String>();
            pathMap.put(appointmentid,'slots');
            pathMap.put(slotId,'reschedule');
            system.debug('appointmentid' +appointmentid);
              system.debug('slotId' +slotId);
            AppointmentBOMReserveResponseDTO resDetails=new AppointmentBOMReserveResponseDTO();
            HttpResponse adResponse;
            try {
                //String token = 'aJ1AUZuZdKBUWb7s22OhejvWKRzU';
                String token = AuthenticationManager.getOauthToken(handlerName);
                Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token, 'callingSystemID' => 'COM-B2B-FORCE'};
                adResponse = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName, pathMap);
                system.debug('adResponse'+adResponse.getBody());
                if (adResponse.getStatusCode() == 200 || adResponse.getStatusCode() == 201 || adResponse.getStatusCode() == 202) {
                    resDetails = AppointmentBOMReserveResponseDTO.parse(adResponse.getBody());
                    logger.logMessages(reqBody, adResponse.getBody(), '', '', '', '', false, false,Integer.valueof(adResponse.getStatusCode()) , null, null, null);
                }else{
                    logger.logMessages(reqBody, adResponse.getBody(), '', '', '', '', false, false, Integer.valueOf(adResponse.getStatusCode()) , null, null, null);
                }
                logger.exitLogger();
            } catch (Exception e) {
                logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
                logger.exitLogger();
            }

            return resDetails;
        }
        
        /**
         * EDGE-66474
         * Method: RebookAppointment to check Availability for Site
         *
         * @params  AppointmentBOMReserveRequestDTO - DTO Class for BOM Slot Reserve Request   
         * @return  AppointmentBOMReserveResponseDTO  Class - DTO Class for BOM Slot Reserve Response
         */
         public static AppointmentBOMReserveResponseDTO rebookAppointment(AppointmentBOMReserveRequestDTO request, String slotId, String appointmentId){
            String handlerName = 'RescheduleAppointmentBOM';
            String reqBody = JSON.serialize(request,true);
            //String reqBody = JSON.serialize(request,true).replace('customerclass','class');
            Logger2 logger = Logger2.getLogger(handlerName);
            //Map<String, String> pathMap = new Map<String, String>{appointmentId => 'available-slots',slotId => 'partial-tasks-reservations'};
             Map<String, String> pathMap = new Map<String, String>();
            pathMap.put(appointmentid,'slots');
            pathMap.put(slotId,'rebook');
            AppointmentBOMReserveResponseDTO rebookDetails=new AppointmentBOMReserveResponseDTO();
            HttpResponse adResponse;
            try {
                //String token = 'aJ1AUZuZdKBUWb7s22OhejvWKRzU';
                String token = AuthenticationManager.getOauthToken(handlerName);
                Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token,'callingSystemID' => 'COM-B2B-FORCE'};
                adResponse = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName, pathMap);
                system.debug('adResponse'+adResponse.getBody());
                if (adResponse.getStatusCode() == 200 || adResponse.getStatusCode() == 201 || adResponse.getStatusCode() == 202) {
                    rebookDetails = AppointmentBOMReserveResponseDTO.parse(adResponse.getBody());
                    logger.logMessages(reqBody, adResponse.getBody(), '', '', '', '', false, false,Integer.valueof(adResponse.getStatusCode()) , null, null, null);
                }else{
                    logger.logMessages(reqBody, adResponse.getBody(), '', '', '', '', false, false, Integer.valueOf(adResponse.getStatusCode()) , null, null, null);
                }
                logger.exitLogger();
            } catch (Exception e) {
                logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
                logger.exitLogger();
            }

            return rebookDetails;
        }
    }