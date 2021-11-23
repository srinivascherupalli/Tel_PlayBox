/*Author: Ila
Company: Tesltra 
User Story :EDGE-80745
Description: SQ Check for Mobile/MSISDN Lightning UI controller.
*/
public with sharing class SQCheckMSISDNCtrl {
    
    public Static String PORTINSQ = 'Port in SQ';
    public static final String HANDLER_MULTIPLE =  'MultipleSQCheckPortin';
    
    //EDGE-80745, Callout Method to trigger on Qualify 
    public static SQCheckMobileResponseDTO qualifyMsisdn(String msisdn)
    {
        String handlerName = 'SQCheckMSISDNPortIn';
        Logger2 logger = Logger2.getLogger(handlerName);
        SQCheckMobileResponseDTO res = new SQCheckMobileResponseDTO();
        HttpResponse response;
        try{
            //String token = 'aJ1AUZuZdKBUWb7s22OhejvWKRzU';
            String token= AuthenticationManager.getOauthToken(handlerName);
            String correlationId= EDISSingleManager.getUID();
            Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token,'correlationId'=> +correlationId};
                DateTime startTime = DateTime.now();
            response = IntegrationRecordHandlerUtil.callout(msisdn,'GET',headerMap,handlerName,null, null);
            DateTime endTime = DateTime.now();
            Long requestTime = Logger.getRequestTimeDifference(startTime, endTime);
            String responseCode = String.valueOf(response.getStatusCode());
            System.debug('SQRes: '+response);   
            if (responseCode.startsWith('2')) {
                res=SQCheckMobileResponseDTO.parse(response.getBody());
                System.debug('SQRes: '+res);
                //logger.logMessages(msisdn, response.getBody(), '', '', '', '', false, false,Integer.valueof(response.getStatusCode()) , null, null, null);
                logger.logMessages(msisdn, response.getBody(), '', '', '', 
                                   '', String.valueOf(response.getStatusCode()), correlationId, '','','','Create',requestTime ,'POST',false, false);
            }
            else if (responseCode.startsWith('4') || responseCode.startsWith('5')){
                res=SQCheckMobileResponseDTO.parse(response.getBody());
                //logger.logMessages(msisdn, response.getBody(), '', '', '', '', false, false, Integer.valueOf(response.getStatusCode()) , null, null, null);
                logger.logMessages(msisdn, response.getBody(), '', '', '', 
                                   '', String.valueOf(response.getStatusCode()), correlationId, '','','','Create',requestTime ,'POST',false, false);
            }
            logger.exitLogger();
            return res;
            
        }catch (Exception e) {
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();
        }
        return res;        
    }    
    
    //EDGE-80745, Method to map and save response in SQ
    public static String saveMsisdn(List<PortInController.NumberWrapper> sqPortInList, String basketid){
        system.debug('sqPortInList+' +sqPortInList);
        /********************************************
EDGE-88795: Populate Account on SQ for PortIn
Author:Ila
*********************************************/
        List<cscfga__Product_Basket__c> bsktAcc = [Select id,csbb__Account__c from cscfga__Product_Basket__c where id=:basketid];
        String saveStatus='';
        Service_Qualification__c sqPortIn ;      
        List<Service_Qualification__c> sqList =new List<Service_Qualification__c>(); 
        List<Service_Qualification__c> sqUniqueList = [Select Id, UniqueBasketMSISDN__c,Portability_Code__c,Service_Number__c,Account__c from Service_Qualification__c where Account__c=:bsktAcc[0].csbb__Account__c];
        Map<String,Service_Qualification__c> sqMap= new Map<String,Service_Qualification__c>();
        try{
            saveStatus='Success';
            if(sqPortInList.size()>0 &&!bsktAcc.isEmpty()){
                for(PortInController.NumberWrapper wrap:sqPortInList ){
                    if(wrap.indicator!=null){
                        if(wrap.uniqueBakset==null){
                            wrap.uniqueBakset= '614' + wrap.num + bsktAcc[0].csbb__Account__c;
                        }
                        if(sqUniqueList.size()>0){
                            for(Service_Qualification__c sq: sqUniqueList){
                                String num ='614'+wrap.num;
                                if(wrap.uniqueBakset==sq.UniqueBasketMSISDN__c && num == sq.Service_Number__c){
                                    sq.Service_Number__c=num;
                                    sq.Portability_Status__c= wrap.indicator;
                                    sq.Status_Reason__c= wrap.reason;
                                    sq.Portability_Code__c=wrap.code;
                                    sq.Incumbent_Account_Number__c = wrap.accountNumber;
                                    //EDGE-137593 Kalashree Borgaonkar. Populate carrier value
                                    sq.Incumbent_Carrier__c = wrap.carrier;
                                    sq.SQ_Type__c= PORTINSQ;
                                    sq.basket_id__c =basketid; //DIGI-867
                                    //sqList.add(sq);
                                    sqMap.put(sq.UniqueBasketMSISDN__c,sq);   
                                }
                                else  if(!sqMap.containskey(wrap.uniqueBakset) ){
                                    sqPortIn = new Service_Qualification__c();
                                    sqPortIn.UniqueBasketMSISDN__c= wrap.uniqueBakset;
                                    sqPortIn.Account__c= bsktAcc[0].csbb__Account__c;
                                    sqPortIn.Service_Number__c= '614'+wrap.num;
                                    sqPortIn.Portability_Status__c= wrap.indicator;
                                    sqPortIn.Status_Reason__c= wrap.reason;
                                    sqPortIn.Portability_Code__c=wrap.code;
                                    sqPortIn.Incumbent_Account_Number__c = wrap.accountNumber;
                                    //EDGE-137593 Kalashree Borgaonkar. Populate carrier value   
                                    sqPortIn.Incumbent_Carrier__c = wrap.carrier;
                                    sqPortIn.SQ_Type__c= PORTINSQ;
                                    sqPortIn.basket_id__c =basketid; //DIGI-867
                                    sqMap.put(wrap.uniqueBakset,sqPortIn); 
                                }
                            }
                        }
                        else{
                            sqPortIn = new Service_Qualification__c();
                            sqPortIn.UniqueBasketMSISDN__c= wrap.uniqueBakset;
                            sqPortIn.Account__c= bsktAcc[0].csbb__Account__c;
                            sqPortIn.Service_Number__c= '614'+wrap.num;
                            sqPortIn.Portability_Status__c= wrap.indicator;
                            sqPortIn.Status_Reason__c= wrap.reason;
                            sqPortIn.Portability_Code__c=wrap.code;
                            sqPortIn.Incumbent_Account_Number__c = wrap.accountNumber;
                            //EDGE-137593 Kalashree Borgaonkar. Populate carrier value       
                            sqPortIn.Incumbent_Carrier__c = wrap.carrier;
                            sqPortIn.SQ_Type__c= PORTINSQ;
                            sqPortIn.basket_id__c =basketid; //DIGI-867
                            system.debug('sqPortIn+' +sqPortIn);
                            //sqList.add(sqPortIn);
                            sqMap.put(wrap.uniqueBakset,sqPortIn); 
                        }
                    }                    
                }  
            }
            system.debug('sqMap+' +sqMap.Values());
            if(!sqMap.isEmpty()){
                Database.upsert(sqMap.values(), Service_Qualification__c.fields.UniqueBasketMSISDN__c, false);
                saveStatus='Record saved';
            }
            
        }
        catch(Exception e){
            saveStatus=e.getMessage();
            system.debug(e.getStackTraceString());
        }
        return saveStatus; 
    }
    /*-------------------------------------------------------- 
EDGE-107149
Method: createPayload
Description: create Payload for multiple portin SQ check
Author:Aishwarya
--------------------------------------------------------*/
    public static SQCheckMobileRequestDTO createPayload(List<String> msisdnList){
        SQCheckMobileRequestDTO requestDto = new SQCheckMobileRequestDTO();
        SQCheckMobileRequestDTO.Data requestData = new SQCheckMobileRequestDTO.Data();
        SQCheckMobileRequestDTO.Attributes attributes = new SQCheckMobileRequestDTO.Attributes();
        SQCheckMobileRequestDTO.Resources resource=null;
        List<SQCheckMobileRequestDTO.Resources> resourceList= new List<SQCheckMobileRequestDTO.Resources>();
        attributes.fieldList='all';
        requestData.attributes=attributes;
        for(String msisdn: msisdnList){
            resource = new SQCheckMobileRequestDTO.Resources();
            resource.resourceId = msisdn;
            resourceList.add(resource);
        }
        requestData.resources = resourceList;
        requestDto.data=requestData;
        return requestDto;
    }
    /*-------------------------------------------------------- 
EDGE-107149
Method: createPayload
Description: Callout for multiple portin SQ check API
Author:Aishwarya
--------------------------------------------------------*/
    public static SQCheckMobileResponseDTO calloutToSQCheck(SQCheckMobileRequestDTO sqRequest)
    {
        Logger2 logger = Logger2.getLogger(HANDLER_MULTIPLE);
        SQCheckMobileResponseDTO res = new SQCheckMobileResponseDTO();
        String reqBody = JSON.serialize(sqRequest,true);
        HttpResponse response;
        try {
            String token = AuthenticationManager.getOauthToken(HANDLER_MULTIPLE);
            //String token = 'xQS1L5gsi9TlQarU5G5AvJAaG7pp';
            
            Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token};
                DateTime startTime = DateTime.now();
            response = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, HANDLER_MULTIPLE);
            DateTime endTime = DateTime.now();
            Long requestTime = Logger.getRequestTimeDifference(startTime, endTime);
            system.debug('response::' + response.getBody());
            String responseCode = String.valueOf(response.getStatusCode());
            if (responseCode.startsWith('2')) {
                res = SQCheckMobileResponseDTO.parse(response.getBody());
                System.debug('res: '+res);
                //logger.logMessages(reqBody, response.getBody(), '', '', '', '', false, false,Integer.valueof(response.getStatusCode()) , null, null, null);
                logger.logMessages(reqBody, response.getBody(), '', '', '', 
                                   '', String.valueOf(response.getStatusCode()), '', '','','','Create',requestTime ,'POST',false, false);
            }
            else if (responseCode.startsWith('4') || responseCode.startsWith('5')){
                res = SQCheckMobileResponseDTO.parse(response.getBody());
                //logger.logMessages(reqBody, response.getBody(), '', '', '', '', false, false, Integer.valueOf(response.getStatusCode()) , null, null, null);
                logger.logMessages(reqBody, response.getBody(), '', '', '', 
                                   '', String.valueOf(response.getStatusCode()), '', '','','','Create',requestTime ,'POST',false, false);
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