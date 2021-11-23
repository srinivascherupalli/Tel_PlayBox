public with sharing class MSISDNService implements Queueable, Database.AllowsCallouts
{
    public Map<String,FNNDTO> fnnMap;
    public Integer calloutCounter;
    public Logger2 logger;
    public String handlerName;
    public String basketId;
    public String rootConfigId;
    // Added for EDGE-93081
    public Boolean numberReserveSource;
    
    //----- Constructor to initialize class variables -----//
    public MSISDNService(Map<String,FNNDTO> fnnMap, String handler, String basketId, String rootConfigId){
        this.fnnMap = fnnMap;
        this.calloutCounter = 0;
        this.handlerName = handler;
        this.logger = Logger2.getLogger(handlerName);
        this.basketId = basketId;
        this.rootConfigId = rootConfigId;
        // Added for EDGE-93081
        this.numberReserveSource =false;
    }
    
    //Construction to be called from Lightening Controller
    // Added for EDGE-93081
    public MSISDNService(Map<String,FNNDTO> fnnMap, String handler, String basketId, boolean numberReserveSource){
        this.fnnMap = fnnMap;
        this.calloutCounter = 0;
        this.handlerName = handler;
        this.logger = Logger2.getLogger(handlerName);
        this.basketId = basketId;
        this.numberReserveSource = numberReserveSource;
    }
    
    public MSISDNService(){
        // Added for EDGE-93081
        this.numberReserveSource =false;
    }
    
    //----- Search MMSISDN Numbers -----//
    public static FNNResponseDTO searchMSISDN(FNNDTO fnnDto){
        String handlerName = 'SearchMSISDNHandler';
        String reqBody = JSON.serialize(fnnDto,true);
        Logger2 logger = Logger2.getLogger(handlerName);
        FNNResponseDTO fnnRes = new FNNResponseDTO() ;
        HttpResponse adResponse;
        try {
            String token = AuthenticationManager.getOauthToken(handlerName);
            //String token = 'MLhlJPHAFdP38Z1CsAnEI1EDts6h';
            //System.debug('AuthenticationToken::' + token);
            //Adding this to send correlation id in the request header.
            String correlationId=EDISSingleManager.getUID(); 
            Map<String,String> headerMap = new Map<String, String>{'Accept'=>'application/json','Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token,'correlationId'=> +correlationId};
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
    
    //----- Put jobs in Queue
    public void execute(QueueableContext context) {
        system.debug('handlerName++' +handlerName);
        if(handlerName !='SearchReserveMSISDNHandler'){
            //String token = 'lFYpKM2LkokcsbzQFKfsMTiPeFcA';
            String token = AuthenticationManager.getOauthToken(handlerName);
            callMSISDNService(token);
        }
        else{
            //String token = 'lFYpKM2LkokcsbzQFKfsMTiPeFaC';
            String token = AuthenticationManager.getOauthToken(handlerName);
            
            callMSISDNService(token);
        }
    }
    
    //----- Perform Callouts to MSISDN Service using Queuable 
    public void callMSISDNService(String token){
        system.debug('In method misdn');
        String status = NULL;
        FNNResponseDTO fnnResDto = new FNNResponseDTO();
        List<FNNResponseDTO> fnnResDtoList = new List<FNNResponseDTO>();
        List<String> fnnReqList = new List<String>();
        Map<String, HttpResponse> HttpResponseMap = new Map<String, HttpResponse>();
        Map<String, String> HttpStatusMap = new Map<String, String>();
        String correlationId=EDISSingleManager.getUID();
        HttpResponse adResponse;
        System.debug('fnnMap::' + fnnMap);
        try {
            if(handlerName.equals('ReserveMSISDNHandler')){
                System.debug('fnnMap::' + fnnMap);
                for(String msisdn : fnnMap.keySet()){
                    String reqBody = JSON.serialize(fnnMap.get(msisdn),true);
                    
                    Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token,'correlationId'=> +correlationId};
                        adResponse = calloutLRM(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName,null,null,msisdn);
                    calloutCounter++;
                    HttpResponseMap.put(msisdn, adResponse);
                }
            }
            else if(handlerName.equals('SearchReserveMSISDNHandler')){
                System.debug('fnnMap::' + fnnMap);
                
                for(String msisdn : fnnMap.keySet()){
                    String reqBody = JSON.serialize(fnnMap.get(msisdn),true);
                    system.debug('Request body'+reqBody);
                    Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token,'correlationId'=> +correlationId};
                        adResponse = calloutLRM(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName,null,null,null);
                    system.debug('Response body'+adResponse);
                    calloutCounter++;
                    HttpResponseMap.put(msisdn, adResponse);
                }
                
            }
            else if(handlerName.equals('UnReserveMSISDNHandler')){
                for(String msisdn : fnnMap.keySet()){
                    Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token,'correlationId'=> +correlationId};
                        adResponse = calloutLRM(null,'DELETE', headerMap, handlerName,null,null,msisdn);
                    calloutCounter++;
                    HttpStatusMap.put(msisdn, String.valueOf(adResponse.getStatusCode()));
                }
            }
            
            if(calloutCounter == fnnMap.size()){
                if(handlerName.equals('ReserveMSISDNHandler')){
                    for(String reqBody : HttpResponseMap.keySet()){
                        HttpResponse res = HttpResponseMap.get(reqBody);
                        if (res.getStatusCode() == 200 || res.getStatusCode() == 201 || res.getStatusCode() == 202){
                            fnnResDto = FNNResponseDTO.parse(res.getBody());
                            fnnReqList.add(reqBody);
                            fnnResDtoList.add(fnnResDto);
                            logger.logMessages(reqBody, res.getBody(), '', '', '', '', false, false,Integer.valueof(res.getStatusCode()) , null, null, null);
                        }
                        else{
                            fnnResDto = FNNResponseDTO.parse(res.getBody());
                            logger.logMessages(reqBody, res.getBody(), '', '', '', '', false, false, Integer.valueOf(res.getStatusCode()) , null, null, null);
                        }
                    }
                }
                else if (handlerName.equals('SearchReserveMSISDNHandler'))
                {
                    
                    for(String reqBody : HttpResponseMap.keySet()){
                        HttpResponse res = HttpResponseMap.get(reqBody);
                        if (res.getStatusCode() == 200 || res.getStatusCode() == 201 || res.getStatusCode() == 202){
                            system.debug('Response body'+res);
                            fnnResDto = FNNResponseDTO.parse(res.getBody());
                            List<FNNResponseDTO.ResourcesDataObject> ResourceList = fnnResDto.data.resources;
                            
                            for(FNNResponseDTO.ResourcesDataObject reso :ResourceList)
                            {
                                if(reso !=NULL  || reso.resourceId !=NULL )
                                {
                                    fnnReqList.add(reso.resourceId);
                                    system.debug('list'+fnnReqList);
                                    logger.logMessages(reqBody, res.getBody(), '', '', '', '', false, false,Integer.valueof(res.getStatusCode()) , null, null, null);
                                }
                                else
                                {fnnReqList.add(reqBody);}
                                
                            }
                        }
                        else{
                            fnnResDto = FNNResponseDTO.parse(res.getBody());
                            logger.logMessages(reqBody, res.getBody(), '', '', '', '', false, false, Integer.valueOf(res.getStatusCode()) , null, null, null);
                        }
                    }
                }
                else if(handlerName.equals('UnReserveMSISDNHandler')){
                    for(String reqBody : HttpStatusMap.keySet()){
                        status = HttpStatusMap.get(reqBody);
                        logger.logMessages(reqBody, status, '', '', '', '', false, false,Integer.valueOf(status), null, null, null);
                        if(status.startsWith('2')){
                            fnnReqList.add(reqBody);
                        }
                    }
                }
                //EDGE-93081- condition added to identify Source for Callout.
                if(numberReserveSource!= null && numberReserveSource==false){
                    ncsOperation(handlerName,fnnReqList);
                }
                else{
                    // EDGE-93081: Call Save method for LRM Reserve and Auto Reserve
                    if('ReserveMSISDNHandler'.equalsIgnorecase(handlerName) || 'SearchReserveMSISDNHandler'.equalsIgnorecase(handlerName)){
                        saveReserveMSISDN(fnnReqList,basketId);
                    }
                    else if('UnReserveMSISDNHandler'.equalsIgnorecase(handlerName)){
                        deleteFromReservationPool(fnnReqList);
                        // updateServiceQualification(fnnReqList);
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
    
    //----- Perform CRUD on NCS -----//
    public void ncsOperation(String handler, List<String>fnnReqList){
        List<String> fnnList = new List<String>();
        String status;
        Boolean isFNNReserved;
        NumberNCSMobilityHelper ncs = new NumberNCSMobilityHelper();
        isFNNReserved = ncs.checkForExistingNCS(rootConfigId,'MobileNumberManagementv1_schema.json');
        System.debug('isFNNReserved::' + isFNNReserved);
        
        //----- Insert,Update Numbers in NCS          
        if(handler.equals('ReserveMSISDNHandler')|| handler.equals('SearchReserveMSISDNHandler'))
        {
            fnnList.addAll(fnnReqList);   
            List<NumberNCSMobilityDTO.Configuration> numberList = new List<NumberNCSMobilityDTO.Configuration>();
            NumberNCSMobilityDTO.Configuration numConfig = NULL;
            for(String fnn : fnnList) {
                numConfig = new NumberNCSMobilityDTO.Configuration();
                numConfig.MobileNumber = fnn;
                numConfig.listCode = 'No Entry Line';
                numConfig.Status = 'RESERVED';
                numberList.add(numConfig);
            }
            System.debug('numberList::' + numberList);
            if(isFNNReserved == true){
                status = ncs.updateExistingNCS(rootConfigId,'MobileNumberManagementv1',numberList);
                System.debug('status_Update::' + status);
            }
            else {
                status = ncs.createNewNCS(rootConfigId,'MobileNumberManagementv1', numberList);
                System.debug('status_CreateNew::' + status);
            }
        }
        
        //----- Delete Numbers from NCS
        else if(isFNNReserved == true && handler.equals('UnReserveMSISDNHandler')){
            status = ncs.deleteExistingNCS(rootConfigId,'MobileNumberManagementv1',fnnReqList);
        }
    }
    //Callout to LRM
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
            if(handlerName != 'SearchReserveMSISDNHandler')
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
                system.debug('payload unreserve=='+payload);
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
            system.debug('response unreserve=='+res);
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
    /*-------------------------------------------------------- 
EDGE -93081
Method: deleteFromReservationPool
Description:  method to delete from Number__c 
Author:Kalashree
--------------------------------------------------------*/
    public void deleteFromReservationPool(List<String> msisdnLstToDelete ){
        
        List<Number__c> numList = [SELECT ID FROM Number__c WHERE Basket__c = :basketId AND  Service_Number__c IN :msisdnLstToDelete];
        System.debug('numList: '+numList);
        try{
            if(!numList.isEmpty()){
                delete numList;	
            }
        }
        catch(DmlException de){
            System.debug('DmlException:'+de.getStackTraceString());
        }
        
        
    }	
    
    
    
    /*------------------------------------------------------------------
EDGE -93081
Method: saveReserveMSISDN
Description: Method to save LRM MSISDN Numbers in Number__c object
Author:Ila
-------------------------------------------------------------------*/
    
    public static String saveReserveMSISDN(List<String> fnnListToSave, String basketId){
        System.debug('fnnListToSave: '+fnnListToSave);
        String status=null;
        Number__c msisdn = null;
        //EDGE-108230. Kalashree Borgaonkar
        List<cscfga__Product_Basket__c> basketDetail = [SELECT cscfga__Opportunity__c,csbb__Account__c FROM cscfga__Product_Basket__c WHERE ID=:basketid ]; 
        List<Number__c> msisdnListToSave = null;
        List<String> msisdnLst =null;
        try{
            if(fnnListToSave!=null ){
                msisdnListToSave = new List<Number__c>();
                msisdnLst = new List<String>();
                for(String msisdns : fnnListToSave){
                    msisdn = new Number__c();
                    msisdn.Service_Number__c = msisdns;
                    msisdn.Basket__c = basketId;
                    msisdn.Type__c = 'New';
                    //EDGE-109230. Kalashree Borgaonkar
                    msisdn.Mobile__c='Mobile';
                    msisdn.Account__c = !basketDetail.isEmpty()? basketDetail[0].csbb__Account__c : null;
                    msisdn.status__c='RESERVED';
                    msisdnListToSave.add(msisdn);
                    system.debug('msisdnListToSave+' +msisdnListToSave);
                    
                }
                if(msisdnListToSave!=null && !msisdnListToSave.isEmpty()){
                    insert msisdnListToSave ;
                    status = 'Moved to Reservation Pool';
                } 
            }
            else{
                status = 'SaveError';
            }
        }
        catch(Exception e){
            status = 'SaveError';
        } 
        return status;
    }
}