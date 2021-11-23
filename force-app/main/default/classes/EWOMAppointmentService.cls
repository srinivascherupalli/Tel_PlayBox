/**
 * Description : This class exposes EWOM Slot Availability related operations to EWOM SlotManager class
 */
public with sharing class EWOMAppointmentService {
   
    private static EWOMAppointmentService singleton = new EWOMAppointmentService( );
    private EWOMAppointmentService(){
    }
    
    public static EWOMAppointmentService getInstance( ) {
      return singleton;
    }    
    
    /**
     * Method to call QueryAppointmentAPI to check Availability for Site
     *
     * @params  AppointmentSlotRequestDTO - DTO Class for EWOM Slot Availability Request   
     * @return  AppointmentSlotResponseDTO Class - DTO Class for EWOM Slot Availability Response
     */
    public static AppointmentSlotResponseDTO searchAppointment(AppointmentSlotRequestDTO request){
        String handlerName = 'SearchAppoimentSlot';
        String reqBody = JSON.serialize(request,true);
        Logger2 logger = Logger2.getLogger(handlerName);
        AppointmentSlotResponseDTO slotdetails = new AppointmentSlotResponseDTO() ;
            HttpResponse adResponse;
            try {
                String token = AuthenticationManager.getOauthToken(handlerName);
                Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token};
                adResponse = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName);
                system.debug('adResponse'+adResponse.getBody());
                if (adResponse.getStatusCode() == 200 || adResponse.getStatusCode() == 201 || adResponse.getStatusCode() == 202) {
                    slotdetails = AppointmentSlotResponseDTO.parse(adResponse.getBody());
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
     * @params  AppointmentReserveRequestDTO - DTO Class for EWOM Slot Reserve Request   
     * @return  HttpResponse Class - DTO Class for EWOM Slot Reserve Response
     */
    public static HttpResponse reserveAppointment(AppointmentReserveRequestDTO request, String slotId){
        String handlerName = 'ReserveAppointmentSlot';
        String reqBody = JSON.serialize(request,true).replace('customerclass','class');
        Logger2 logger = Logger2.getLogger(handlerName);
        Map<String, String> pathMap = new Map<String, String>{slotId => 'reservations'};
        HttpResponse adResponse;
        try {
            String token = AuthenticationManager.getOauthToken(handlerName);
            Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token};
            adResponse = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName, pathMap);
            system.debug('adResponse'+adResponse.getBody());
            if (adResponse.getStatusCode() == 200 || adResponse.getStatusCode() == 201 || adResponse.getStatusCode() == 202) {
                logger.logMessages(reqBody, adResponse.getBody(), '', '', '', '', false, false,Integer.valueof(adResponse.getStatusCode()) , null, null, null);
            }else{
                logger.logMessages(reqBody, adResponse.getBody(), '', '', '', '', false, false, Integer.valueOf(adResponse.getStatusCode()) , null, null, null);
            }
            logger.exitLogger();
        } catch (Exception e) {
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();
        }

        return adResponse;
    }
    
   
    public static AppointmentSlotResponseDTO searchRescheduleAppointment(AppointmentRescheduleRequestDTO request, String appointmentId){
        String handlerName = 'SearchRescheduleAppoimentSlot';
        String reqBody = JSON.serialize(request,true);
        Logger2 logger = Logger2.getLogger(handlerName);
        Map<String, String> pathMap = new Map<String, String>{appointmentId => 'available-slots'};
        AppointmentSlotResponseDTO rescheduleSlotdetails = new AppointmentSlotResponseDTO() ;
            HttpResponse adResponse;
            try {
                String token = AuthenticationManager.getOauthToken(handlerName);
                Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token};
                adResponse = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName,pathMap);
                system.debug('adResponse'+adResponse.getBody());
                if (adResponse.getStatusCode() == 200 || adResponse.getStatusCode() == 201 || adResponse.getStatusCode() == 202) {
                    rescheduleSlotdetails = AppointmentSlotResponseDTO.parse(adResponse.getBody());
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
    
    public static HttpResponse reserveRescheduleAppointment(AppointmentReserveRequestDTO request, String slotId, String appointmentId){
        String handlerName = 'ReserveRescheduleAppointmentSlot';
        String reqBody = JSON.serialize(request,true);
        Logger2 logger = Logger2.getLogger(handlerName);
        Map<String, String> pathMap = new Map<String, String>{appointmentId => 'available-slots',slotId => 'reservations'};
        HttpResponse adResponse;
        try {
            String token = AuthenticationManager.getOauthToken(handlerName);
            Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token};
            adResponse = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName, pathMap);
            system.debug('adResponse'+adResponse.getBody());
            if (adResponse.getStatusCode() == 200 || adResponse.getStatusCode() == 201 || adResponse.getStatusCode() == 202) {
                logger.logMessages(reqBody, adResponse.getBody(), '', '', '', '', false, false,Integer.valueof(adResponse.getStatusCode()) , null, null, null);
            }else{
                logger.logMessages(reqBody, adResponse.getBody(), ' ', '', '', '', false, false, Integer.valueOf(adResponse.getStatusCode()) , null, null, null);
            }
            logger.exitLogger();
        } catch (Exception e) {
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();
        }

        return adResponse;
    }
    
    //Rebook Code starts here..
    public static AppointmentSlotResponseDTO searchRebookAppointment(AppointmentRescheduleRequestDTO request, String appointmentId){
        String handlerName = 'SearchRebookAppoimentSlot';
        String reqBody = JSON.serialize(request,true);
        Logger2 logger = Logger2.getLogger(handlerName);
        Map<String, String> pathMap = new Map<String, String>{appointmentId => 'available-slots'};
        AppointmentSlotResponseDTO rescheduleSlotdetails = new AppointmentSlotResponseDTO() ;
            HttpResponse adResponse;
            try {
                String token = AuthenticationManager.getOauthToken(handlerName);
                Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token};
                adResponse = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName,pathMap);
                system.debug('adResponse'+adResponse.getBody());
                if (adResponse.getStatusCode() == 200 || adResponse.getStatusCode() == 201 || adResponse.getStatusCode() == 202) {
                    rescheduleSlotdetails = AppointmentSlotResponseDTO.parse(adResponse.getBody());
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
    
    public static HttpResponse reserveRebookAppointment(AppointmentReserveRequestDTO request, String slotId, String appointmentId){
        String handlerName = 'ReserveRebookAppointmentSlot';
        //String reqBody = JSON.serialize(request,true);
        String reqBody = JSON.serialize(request,true).replace('customerclass','class');
        Logger2 logger = Logger2.getLogger(handlerName);
        Map<String, String> pathMap = new Map<String, String>{appointmentId => 'available-slots',slotId => 'partial-tasks-reservations'};
        HttpResponse adResponse;
        try {
            String token = AuthenticationManager.getOauthToken(handlerName);
            Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token};
            adResponse = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName, pathMap);
            system.debug('adResponse'+adResponse.getBody());
            if (adResponse.getStatusCode() == 200 || adResponse.getStatusCode() == 201 || adResponse.getStatusCode() == 202) {
                logger.logMessages(reqBody, adResponse.getBody(), '', '', '', '', false, false,Integer.valueof(adResponse.getStatusCode()) , null, null, null);
            }else{
                logger.logMessages(reqBody, adResponse.getBody(), '', '', '', '', false, false, Integer.valueOf(adResponse.getStatusCode()) , null, null, null);
            }
            logger.exitLogger();
        } catch (Exception e) {
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();
        }

        return adResponse;
    }
    
}