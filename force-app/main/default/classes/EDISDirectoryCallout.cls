/********************************************************

    Class Name : EDISDirectoryCallout

    ===============================================================================================================================

    Change.No.    Developer Name          Date              Story Description

    1.             Milos                 12/07/2021          DIGI-869

    **********************************************************/
    public with sharing class EDISDirectoryCallout {
        private final static String CONST_INTERFACENAME = 'EDISDirectoryCallout';
        public Map<String, EDISSingleRequestDTO> edisRequestDtoMap;
        public Map<String, Number__c> numberMap;
        public List<appLog> appLogList;
        public Logger2 logger;
        public String handlerName;
        public String token;
        
        public EDISDirectoryCallout(Map<String, EDISSingleRequestDTO> mapOfDTOs, Map<String, Number__c> numberMap){
            this.numberMap = numberMap;
            this.edisRequestDtoMap = mapOfDTOs;
            this.handlerName = 'SingleFNNListingHandler';
            this.logger = Logger2.getLogger(handlerName);
            this.token = AuthenticationManager.getOauthToken(handlerName);
        }
            
        public void callEDISSingleService() {
            List<Number__c> numListToUpdate = new List<Number__c>();
            appLogList = new List<appLog>();
            HttpResponse adResponse;
    
            try {
                for (String num : edisRequestDtoMap.keySet()) {
                    String reqBody = JSON.serialize(edisRequestDtoMap.get(num), true);
    
                    Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json', 'Authorization' => 'Bearer ' + token};
    
                    adResponse = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName);
                    System.debug('adResponse  ::  '+adResponse);
                    System.debug('adResponse  ::  '+adResponse.getbody());
                    if (adResponse != null) {
                        Number__c numberRec = getUpdatedNumber(num, reqBody, adResponse);
                        System.debug('numberRec31::  '+numberRec);
                        if (numberRec != null) {
                            numListToUpdate.add(numberRec);
                        }
                    }
                }
    
                logger.exitLogger();
                System.debug('numListToUpdate38   :: '+numListToUpdate);
    
                if (!numListToUpdate.isEmpty()) {
                    update numListToUpdate;
                }
    
                if (!appLogList.isEmpty() && appLogList.size() > 0) {
                    for(applog log : appLogList){
                        logger.logMessages(log.reqBody, log.resBody, '', '', '', '', false, false, log.statusCode, log.orderIdValue, null, null);
    
                    }
                }
            } catch (Exception e) {
                logException('callEDISSingleService', String.valueOf(e.getLineNumber()), '', e.getMessage(), 'Error while calling EDIS Service API!');
                logger.exitLogger();
            }
        }
    
        private String getOrderIdValue(String reqBody, Boolean debugValue) {
            String ordrIdStr = reqBody?.substringBetween('orderID', 'listCode');
            String orderIdValue = ordrIdStr?.replaceALL('[,:""]', '');
        
            if (debugValue) {
                System.debug('orderIdValue ====>' + orderIdValue);
            }
        
            return orderIdValue;
        }
    
        private Number__c getUpdatedNumber(String num, String reqBody, HttpResponse adResponse) {
            Integer statusCode = adResponse.getStatusCode();
            String resBody = adResponse.getBody();
            Boolean isSuccesful = statusCode == 200 || statusCode == 201 || statusCode == 202;
            String orderIdValue = getOrderIdValue(reqBody, true);
    
            Number__c numberRec = numberMap.get(num);
            numberRec.DL_API_response_code__c = String.valueOf(statusCode);
            numberRec.Directory_Listing_DateTime__c = Datetime.now();
            // numberRec.DL_API_response_msg__c = 'Success';
            
            System.debug('numberRec  :: '+numberRec);
            System.debug('statusCode  :: '+statusCode);
            System.debug('isSuccesful  :: '+isSuccesful);
            System.debug('resBody  :: '+resBody);
    
            // if (!isSuccesful) {
                /*
                EDISSingleErrorResponseDTO edisResErr = EDISSingleErrorResponseDTO.parse(resBody);
                String errors = '';
                System.debug('edisResErr  :: '+edisResErr);
                if (edisResErr?.errors != null) {
                    for (EDISSingleErrorResponseDTO.ErrorObject errObject : edisResErr.errors) {
                        errors += errObject.message + '; ';
                        System.debug('errObject.message  :: '+errObject.message);
                    }
                }
                numberRec.DL_API_response_msg__c = errors;
                */
            // }
            
            System.debug('numberRec97  :: '+numberRec);
    
           // logger.logMessages(reqBody, resBody, '', '', '', '', false, false, statusCode, orderIdValue, null, null);
           appLog log = new appLog();
           log.reqBody = reqBody;
           log.resBody = resBody;
           log.statusCode = statusCode;
           log.orderIdValue = orderIdValue;
           appLogList.add(log);
    
            return numberRec;
        }
    
        /**  
        * @description Exception Handling Framework  
        */  
        public static void logException(String methodName, String referenceNumber, String correlationId, String errorMessage, String businessDescription) {  
            Map<String, Object> eLogMap = new Map<String, Object>();  
            eLogMap.put('interfaceName', CONST_INTERFACENAME);
            eLogMap.put('elementName', methodName);  
            eLogMap.put('referenceNumber', referenceNumber);
            eLogMap.put('correlationId', correlationId);
            eLogMap.put('errorDescription', errorMessage);
            eLogMap.put('businessDescription', businessDescription);  
            C2O_Utilities.logException(eLogMap, false);  
        }
    
    Public class appLog{
        public String reqBody;
        public String resBody;
        public Integer statusCode;
        public String orderIdValue;
        
    }
    
    }