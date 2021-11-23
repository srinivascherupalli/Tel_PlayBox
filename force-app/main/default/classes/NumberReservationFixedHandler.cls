/*************************************************************************************************
Name : NumberReservationFixedHandler
Description : Callout class for Fixed Number Reservation
Author: Ila
Story: EDGE-59987 
***************************************************************************************************/
public with sharing class NumberReservationFixedHandler {
    
/*************************************************************************************************
Name : ReserveFixedMSISDN
Description : Request DTO method for Fixed Number Reservation
Author: Ila
Story: EDGE-59987/EDGE-100660
***************************************************************************************************/
    
    public static ResponseWrapper reserveUnreserveFixedMSISDN(List<String> fnnListToReserve, String basketId, String resourceState, String selectedtype){//EDGE-92021
        system.debug('fnnListToReserve+' +fnnListToReserve);
        FixedNumberRequestDTO dto = new FixedNumberRequestDTO();
        FixedNumberRequestDTO.Data fdo = new FixedNumberRequestDTO.Data();
        ResponseWrapper responseWrapperList = new ResponseWrapper();
        //String flag='true';
        List<FixedNumberRequestDTO.Resources> resList = new List<FixedNumberRequestDTO.Resources>();
        if(!fnnListToReserve.isEmpty()){
            for(String fnn: fnnListToReserve) 
            {
                FixedNumberRequestDTO.Resources resDto = new FixedNumberRequestDTO.Resources();
                //EDGE-100660
                if(fnn.contains('-')){
                    resDto.startRange=fnn.substringbefore(' -');
                    resDto.endRange = fnn.substringafter('- ');
                    //flag='false';
                }
                else{
                    resDto.resourceId = fnn;
                    //flag='true';
                }
                resList.add(resDto);
            } 
        }
        
        
        system.debug('resList+' +resList);
        fdo.resourceState=resourceState;
        fdo.resources=resList;
         // EDGE-131248-Dheeraj Bhatt-Use Age Out Parameter in MSISDN Reservation Call to HOLD number till certain period.
        if(selectedtype == 'Mobile'){
        fdo.ageOut=Label.MSISDN_Reservation_AgeOut;
        }
        dto.data = fdo;
        system.debug('dto+' +resList);
        //EDGE-100660
        if(resourceState=='Held Order'){
            responseWrapperList = fixedResponseMSISDN(dto,basketid,selectedtype);////EDGE-92021
        }else
        {
            responseWrapperList = fixedUnreserveMSISDN(dto,basketid);
        }
        return responseWrapperList;
    }

    public static FixedNumberResponseDTO getMSISDNResponse(FixedNumberRequestDTO dto, Logger2 logger, ResponseWrapper responseWrapperList, string handlerName){
        String reqBody = JSON.serialize(dto,true);
        system.debug('reqBody+' +reqBody);

        
        FixedNumberResponseDTO fnnRes = new FixedNumberResponseDTO();
        String correlationId = IntegrationRecordHandlerUtil.getCorrelationId();
        DateTime startTime = DateTime.now();    
        HttpResponse adResponse = integrationRecordCallout(dto, handlerName, correlationId); 
        DateTime endTime = DateTime.now();
        Long requestTime = Logger.getRequestTimeDifference(startTime, endTime);
        system.debug('adResponse::'+adResponse.getBody());
        switch on adResponse.getStatusCode(){
            when 500, 503 {
                responseWrapperList.errList = getServerUnavailableError();
                responseWrapperList.status = false;
            }
            when 200, 201, 202 {
                fnnRes = FixedNumberResponseDTO.parse(adResponse.getBody());
                system.debug('fnnRes+' + fnnRes);
                system.debug('fnnRes.Errors+' + fnnRes.Errors);
                if(fnnRes != null && fnnRes.Errors != null) {
                    system.debug('responseWrapperList+' +responseWrapperList);
                    responseWrapperList.errList = getErrorFromSuccessResponse(fnnRes.Errors);
                }
                responseWrapperList.status = true;
            }
            when else {
                fnnRes = FixedNumberResponseDTO.parse(adResponse.getBody());
                if(fnnRes != null && fnnRes.Errors != null){
                    responseWrapperList.errList = getOtherError(fnnRes.Errors);
                }
                responseWrapperList.status = false;
            }
        }
        logger.logMessages(reqBody, adResponse.getBody(), '', '', '', 
                                    '', String.valueOf(adResponse.getStatusCode()), correlationId, '','','Create','',requestTime ,'POST',false, false);
    
        system.debug('responseWrapperList+' + responseWrapperList);
        system.debug('fnnRes+' + fnnRes);
        return fnnRes;
    }


    
    /*************************************************************************************************
Name : FixedResponseMSISDN
Description : Response callout method for Fixed Number Reservation
Author: Ila
Story: EDGE-59987
***************************************************************************************************/                
    public static ResponseWrapper fixedResponseMSISDN(FixedNumberRequestDTO dto,String basketid, String selectedtype){
        system.debug('Inside fixedResponseMSISDN>>>>>');
        String handlerName = 'ReserveBulkFnn';
        Logger2 logger = Logger2.getLogger(handlerName);

        FixedNumberResponseDTO.Resources resList = new FixedNumberResponseDTO.Resources();
        ResponseWrapper responseWrapperList = new ResponseWrapper();
        
        List<cscfga__Product_Basket__c> basketDetail = [SELECT cscfga__Opportunity__c,csbb__Account__c FROM cscfga__Product_Basket__c WHERE ID=:basketId ]; 
        String accId = !basketDetail.isEmpty()? basketDetail[0].csbb__Account__c : null;
        String saveMsg = 'Error';
        List<Number__c> numListSplit= new List<Number__c>();
        Integer resSize = 0;
        List<ErrorList> errWrapList= new List<ErrorList>();
        try {
            FixedNumberResponseDTO fnnRes = getMSISDNResponse(dto, logger, responseWrapperList, handlerName);
            system.debug('fnnRes+' +fnnRes);
            if(responseWrapperList.status){
                responseWrapperList.status = null;
                system.debug('fnnRes.Data.resources[0]+' +fnnRes.Data.resources[0]);
                system.debug('fnnRes.Errors+' +fnnRes.Errors);
                System.debug('fnnRes.Data.resources[0].startRange-'+fnnRes.Data.resources[0].startRange);
                System.debug('fnnRes.Data.resources[0].endRange-'+fnnRes.Data.resources[0].endRange);

                if(fnnRes.Data.resources[0].startRange == null){
                    saveMsg = saveReserveNumbers(fnnRes,basketid, selectedtype);
                } else if(fnnRes.Errors == null && fnnRes.Data.resources[0].endRange != null) { //EDGE-100660                    
                    numListSplit = NumberReservationHandler.splitRangeofNumbers(fnnRes.Data.resources[0].startRange,fnnRes.Data.Resources[0].endRange,basketid,accId,'RESERVED','FNN',null,null);
                } 

                if(!numListSplit.isEmpty()){
                    insert numListSplit;
                    saveMsg= String.ValueOf(numListSplit.size());
                }
                if(fnnRes.Errors == null){
                    system.debug('saveMsg>>>>'+saveMsg);
                    //errBlock.add(saveMsg);
                    //responseWrapper responseWrap=new responseWrapper();
                    //responseWrap.successMsg=saveMsg;
                    responseWrapperList.successMsg=saveMsg;
                }
            }
        }
        catch (Exception e) {
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
        } finally{
            logger.exitLogger();
        }
        system.debug('responseWrapperList+' +responseWrapperList);
        return responseWrapperList;
    }
    
    /*************************************************************************************************
Name : fixedUnreserveMSISDN
Description : Response callout method for Fixed Number Unreserve
Author: Ila
Story: EDGE-100660
***************************************************************************************************/                
    public static ResponseWrapper fixedUnreserveMSISDN(FixedNumberRequestDTO dto,String basketid){
        String handlerName = 'ReserveBulkFnn';
        Logger2 logger = Logger2.getLogger(handlerName);

        Integer resSize = 0;
        ResponseWrapper responseWrapperList = new ResponseWrapper();
        List<String> resIdList = new List<String>();
        List<String> startRangeList = new List<String>();
        List<ErrorList> errWrapList= new List<ErrorList>();
        try {
            FixedNumberResponseDTO fnnRes = getMSISDNResponse(dto, logger, responseWrapperList, handlerName);
            system.debug('fnnRes+' +fnnRes);
            if(responseWrapperList.status){
                responseWrapperList.status = null;
                system.debug('fnnRes.Errors+' +fnnRes.Errors);
                
                resSize = fnnRes.Data.resources.size();
                for(Integer i=0; i<resSize; i++){
                    if(fnnRes.data !=null && fnnRes.data.resources != null){
                        if(fnnRes.data.resources[i].startRange != null){
                            startRangeList.add(fnnRes.data.resources[i].StartRange);
                        }
                        system.debug('fnnRes.data.resources[i].StartRange+' +fnnRes.data.resources[i].StartRange);
                        system.debug('responseWrapperList.stRange+' +startRangeList);
                        system.debug('fnnRes.data.resources[i].resourceId+ before' +fnnRes.data.resources[i].resourceId);
                        
                        if(fnnRes.data.resources[i].resourceId != null){
                            resIdList.add(fnnRes.data.resources[i].resourceId); 
                        }
                        system.debug('fnnRes.data.resources[i].resourceId+' +fnnRes.data.resources[i].resourceId);
                        system.debug('responseWrapperList.resIds+' +resIdList);
                    }
                }
                if(!resIdList.isEmpty()){
                    responseWrapperList.resIds=resIdList;
                    responseWrapperList.status = true;
                }
                if(!startRangeList.isEmpty()){
                    responseWrapperList.stRange=startRangeList;
                    responseWrapperList.status = true;
                }
                
                if(fnnRes.Errors == null){
                    system.debug('in here');
                    responseWrapperList.status = true;
                }
            }
    
        } catch (Exception e) {
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false); 
        } finally {
            logger.exitLogger();
        }
        system.debug('responseWrapperList+' +responseWrapperList);
        return responseWrapperList;
    }
    
    private static HttpResponse integrationRecordCallout(FixedNumberRequestDTO dto, string handlerName, String correlationId){
        String reqBody = JSON.serialize(dto,true);
        system.debug('reqBody+' +reqBody);
        //get Oauth Token
        String token = AuthenticationManager.getOauthToken(handlerName);
        //Set header for request
        Map<String,String> headerMap = new Map<String, String>{'Accept'=>'application/json','Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token,'Correlation_Id'=> +correlationId};
        HttpResponse adResponse = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_PUT, headerMap, handlerName);
        return adResponse;
    }

    private static List<ErrorList> getServerUnavailableError() {
        List<ErrorList> errWrapList= new List<ErrorList>();
        ErrorList error = new ErrorList();
        error.resourceId='';
        error.message='Server Unavailable';
        errWrapList.add(error);
        return errWrapList;
    }

    private static List<ErrorList> getOtherError(List<FixedNumberResponseDTO.Errors> errorList) {
        List<ErrorList> errWrapList= new List<ErrorList>();
        for(FixedNumberResponseDTO.Errors err : errorList){
            ErrorList error = new ErrorList();
            error.resourceId = err.resourceId;
            error.message = err.message.remove('_Z');
            errWrapList.add(error);
        }
        return errWrapList;
    }
    
    private static List<ErrorList> getErrorFromSuccessResponse(List<FixedNumberResponseDTO.Errors> errorList){
        List<ErrorList> errWrapList= new List<ErrorList>();
        for(FixedNumberResponseDTO.Errors err : errorList){
            ErrorList error = new ErrorList();
            if(err.startRange!=null){
                error.StartRange = err.startRange;
                error.EndRange = err.endRange;
            }
            error.resourceId = err.resourceId;
            error.message = err.message.remove('_Z');
            errWrapList.add(error);
        }
        return errWrapList;
    }

    
    /******************************************************************
EDGE-108230
Method: saveReserveNumbers
    Description: save FFN/New reserved in Number object
Author:Kalashree Borgaonkar
******************************************************************/
    public static string saveReserveNumbers(FixedNumberResponseDTO fnnDto,String basketid,String selectedtype){ ////EDGE-92021
        System.debug('VKR Print '+ fnnDto);
        String status='Error';
        List<cscfga__Product_Basket__c> basketDetail = [SELECT cscfga__Opportunity__c,csbb__Account__c FROM cscfga__Product_Basket__c WHERE ID=:basketid ]; 
        
           
        Number__c fnnNumber = null;
        List<Number__c> fnnNumberList = null;
        try{
            if(fnnDto.Data!=null && fnnDto.Data.resources!=null){
                fnnNumberList = new List<Number__c>();
                for(FixedNumberResponseDTO.Resources resource:fnnDto.Data.resources){
                    fnnNumber = new Number__c();
                    fnnNumber.Basket__c = basketid;
                    fnnNumber.Account__c = !basketDetail.isEmpty()? basketDetail[0].csbb__Account__c : null;
                    fnnNumber.Service_Number__c = resource.resourceId;
                    fnnNumber.Status__c = 'RESERVED';
                    fnnNumber.Mobile__c=selectedtype;//EDGE-92021
                    fnnNumber.Type__c= selectedtype == 'Mobile'?'New':'FNN';//EDGE-92021
                    
                    fnnNumberList.add(fnnNumber);
                }
                if(!fnnNumberList.isEmpty()){
                    insert fnnNumberList;
                    status= String.ValueOf(fnnNumberList.size());
                }
                system.debug('fnnNumberList+' +fnnNumberList);
            }   
        }
        catch(Exception e){
            status='Error';
            System.debug('Exception in saveResverNumbers: '+e.getStackTraceString());
        }
        return   status;
    }

    /****************************************************************** 
EDGE-100659
Method: searchFNN
Description: searchFNN 
Author:Aishwarya
******************************************************************/
    
    public static FNNSearchResponseDTO searchFNN(FNNSearchRequestDTO fnnDto){
        String handlerName = 'SearchFNN';
        String reqBody = JSON.serialize(fnnDto,true);
        Logger2 logger = Logger2.getLogger(handlerName);
        FNNSearchResponseDTO fnnRes = new FNNSearchResponseDTO() ;
        HttpResponse adResponse;
        system.debug('Inside FNN Service::searchFNN..');
        try {
           String token = AuthenticationManager.getOauthToken(handlerName);
           // String token = 'FTRd33425n78xs';
            //System.debug('AuthenticationToken::' + token);
            String correlationId = IntegrationRecordHandlerUtil.getCorrelationId();
            system.debug('correlationId****'+correlationId);
            //Map<String,String> headerMap = new Map<String, String>{'Accept'=>'application/json','Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token,'Correlation_Id'=> +correlationId};
                
            DateTime startTime = DateTime.now();
            Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token,'Correlation_Id'=> +correlationId};
             adResponse = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, handlerName);
             
             DateTime endTime = DateTime.now();
            system.debug('requestTime>>>'+startTime + '>>>>' + endTime);
            Long requestTime = Logger.getRequestTimeDifference(startTime, endTime);
            system.debug('requestTime>>>'+requestTime);
            system.debug('adResponse::'+adResponse.getBody());
            fnnRes = FNNSearchResponseDTO.parse(adResponse.getBody());
            if (adResponse.getStatusCode() == 200 || adResponse.getStatusCode() == 201 || adResponse.getStatusCode() == 202) {
                //logger.logMessages(reqBody, adResponse.getBody(), '', '', '', '', false, false,Integer.valueof(adResponse.getStatusCode()) , null, null, null);
                logger.logMessages(reqBody, adResponse.getBody(), '', '', '', 
                                       '', String.valueOf(adResponse.getStatusCode()), correlationId, '','','Create','',requestTime ,'POST',false, false);
            }
            else{
                //logger.logMessages(reqBody, adResponse.getBody(), '', '', '', '', false, false, Integer.valueOf(adResponse.getStatusCode()) , null, null, null);
                logger.logMessages(reqBody, adResponse.getBody(), '', '', '', 
                                       '', String.valueOf(adResponse.getStatusCode()), correlationId, '','','Create','',requestTime ,'POST',false, false);
            }
            logger.exitLogger();
        }
        catch (Exception e) {
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();
        }
        return fnnRes;
    }
    /******************************************************************
EDGE-108230
Method: saveReserveNCS
Description: save FFN reserved in NCS schema
Author:Kalashree Borgaonkar
******************************************************************/
    public static string saveReserveNCS(List<Number__c> lstSelectedNumbers){
        String status = 'Error';
        String pcid;
        List<NumberWrapper> reservedFnnList = new List<NumberWrapper>();
        List<NumberNCSDTO.Configuration> numberList=new List<NumberNCSDTO.Configuration>();
        NumberNCSHelper ncs= new NumberNCSHelper();
        NumberWrapper numWrapper=null;
        system.debug('lstSelectedNumbers+' +lstSelectedNumbers);
        try{
            for(Number__c num:lstSelectedNumbers){
                numWrapper = new NumberWrapper(num.Service_Number__c,num.Product_Configuration__c,num.Start_Range__c,num.End_Range__c);
                numWrapper.type_c = num.Type__c;
                reservedFnnList.add(numWrapper);
            } 
            system.debug('reservedFnnList+' +reservedFnnList);
            system.debug('numWrapper+' +numWrapper);
            NumberNCSDTO.Configuration numConfig = NULL;
            for(NumberWrapper fnn : reservedFnnList) {
                pcid=fnn.pcid;
                numConfig = new NumberNCSDTO.Configuration();
                numConfig.fnn = fnn.fnnNumber;
                numConfig.listCode = 'No Entry Line';
                //EDGE-152029. Kalashree Borgaonkar. Adding check for transition number status
                if('Transition'.equalsIgnoreCase(fnn.type_c)){
                  numConfig.status = 'IN TRANSITION';
                }
                else{
                  numConfig.status = 'RESERVED';
                }                
                numConfig.rangeFrom =fnn.startR;
                numConfig.rangeTo= fnn.endR;
                numberList.add(numConfig);
            }
            system.debug('numberList+' +numberList);
            if(!numberList.isEmpty()){ // EDGE-150413
                if(ncs.checkForExistingNCS(pcid)){
                    ncs.updateExistingNCS(pcid,'NumberManagementv1', numberList);
                }else{
                    ncs.createNewNCS(pcid,'NumberManagementv1', numberList);
                }                
                status = 'Success';
            }
        }
        catch(Exception e){
            System.debug('Exception in saveResverNumbers: '+e.getStackTraceString());
            status = 'Error';
        }
        return status ;
    }
    //Wrapper for Number details
    public class NumberWrapper{
        String fnnNumber;
        String pcid;
        String startR;
        String endR;
        String type_c;//EDGE-152029. Kalashree Borgaonkar. Adding check for transition number status
        public NumberWrapper(String fnnNumber, String pcid, String startR, String endR){
            this.pcid=pcid;
            this.fnnNumber=fnnNumber;
            this.startR=startR;
            this.endR=endR;
        } 
    }
    
    //Wrapper to display response
    public class ResponseWrapper{
        @AuraEnabled
        public String successMsg {get;set;}
        @AuraEnabled
        public List<ErrorList> errList {get;set;}
        //EDGE-100660
        @AuraEnabled 
        public Boolean status {get;set;}
        @AuraEnabled
        public List<String> resIds {get;set;}
        @AuraEnabled
        public List<String> stRange{get;set;}
    }
    
    //Wrapper for errorList
    public class ErrorList{
        @AuraEnabled
        public String resourceId {get;set;}
        @AuraEnabled
        public String StartRange {get;set;}
        @AuraEnabled
        public String EndRange {get;set;}
        @AuraEnabled
        public String message {get;set;}
    }
}