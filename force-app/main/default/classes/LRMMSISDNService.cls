/***************************************************************************************************************************
*Class Name : LRMMSISDNService
*Description: To search and reserve MSISDN numbers
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
2.          Vanita Mude             30/12/2019   EDGE-127368- CLF changes done under the tech debt story
3           Abinash         03/02/2020      (20.03)EDGE-92021 /EDGE-68661 <LRM><UNMS> Search and Reserve Next Available MSISDN
                                            <Interface Story> CS->LRM [UNMS] to enable bulk reserve of mobile numbers
****************************************************************************************************************************/
global with sharing class LRMMSISDNService implements Queueable, Database.AllowsCallouts
{  
    public Map<String,FNNDTO> serviceIDFNNDTOMap;
    public String primaryOrderID;
    public Integer successCounter;
    public Integer calloutCounter;
    public Integer inputListSize;
    public Logger2 logger;
    public String handlerName;
    public String MSISDNRecordType;
    public String scenarioType;
    public static Map<String,Attachment> AttMapTobeUpdated = new Map <String,Attachment>(); // Edge-92021
        
    
    
    public LRMMSISDNService(Map<String,FNNDTO> inputMap,String orderID,String MSISDNRecdType,String msisdnhandlerName, String scenarioType ){
        this.serviceIDFNNDTOMap = inputMap;
        this.primaryOrderID = orderID;
        this.successCounter = 0;
        this.calloutCounter = 0;
        this.handlerName = msisdnhandlerName;
        this.MSISDNRecordType = MSISDNRecdType;
        this.logger = Logger2.getLogger(handlerName);
        this.inputListSize = inputMap.size();
        this.scenarioType = scenarioType;
        
        
    }
    
    public void execute(QueueableContext context) {
        System.debug('handlerName-->'+handlerName);
        String token = AuthenticationManager.getOauthToken(handlerName);
        system.debug('entering callout');
        if (MSISDNRecordType == 'MSISDN_Reserved')
        {
            HeldToReserveMSISDN(token);
        }
        else
        {       
            searchReserveMSISDN(token);
        }
    }
    
    public void searchReserveMSISDN(String token){
        
        List <csord__Service__c> serviceList = [select Id,csord__Subscription__c,csord__Subscription__r.serviceMSISDN__c, 
                                                csord__Service__c,csordtelcoa__Product_Basket__c,csordtelcoa__Product_Basket__r.csbb__Account__c,
                                                csordtelcoa__Product_Basket__r.cscfga__Opportunity__c,Scenario_Type__c,csordtelcoa__Product_Configuration__c 
                                                from csord__Service__c where Id IN :serviceIDFNNDTOMap.keySet()];
        String resourceId = '';
        HttpResponse adResponse;
        Map<String,HttpResponse> responseMap = new Map<String,HttpResponse>();
        Long requestTime;
        String correlationId;
        HttpResponse msResponse;
        Map<Id,Long> requestTimeMap=new Map<Id,Long>();
         Map<Id,String> correlationIdMap=new Map<Id,String>();
        Map<String, String> servicewithFNN = new Map<String,String>();  // Edge-92021
        Map<String, csord__Service__c> servicewithSubcription = new Map<String,csord__Service__c>();
        set<string> setofServiceIdsString = new Set<String>();
        FNNSearchResponseDTO fnnResponse = new FNNSearchResponseDTO();
        try {
            for(csord__Service__c serv : serviceList){
                String serviceID = serv.Id;
                setofServiceIdsString.add(serv.id);
                calloutCounter++;
                 correlationId = IntegrationRecordHandlerUtil.getCorrelationId();               
                FNNDTO dto = new FNNDTO();
                if(serviceIDFNNDTOMap.containskey(serv.id)){
                    dto = serviceIDFNNDTOMap.get(serv.id);
                }
                
                system.debug('Quantity>>>>>>>>'+dto.data.quantity);
                //EDGE-92021 Start
                FNNSearchRequestDTO fnnDto = new FNNSearchRequestDTO();
                FNNSearchRequestDTO.data fdo=new FNNSearchRequestDTO.data();
                fdo.quantity = dto.data.quantity;
                fdo.resourceType = 'Mobile';
                fdo.activityName = 'Reserve Next Available';
                fnnDto.data = fdo;
                system.debug('fnnDto>>>>>>>>'+fnnDto);
                fnnResponse = NumberReservationFixedHandler.searchFNN(fnnDto);
                system.debug('fnnResponse>>>>>>>>'+fnnResponse);
                // Itterate over response and store in map against the service id,
                // Assuming one service has one Mobile Number
                if(fnnResponse.status == 200 || fnnResponse.status == 201 || fnnResponse.status == 202){
                    if(fnnResponse != NULL && fnnResponse.data != NULL && fnnResponse.data.resources != NULL){
                        for(FNNSearchResponseDTO.Resources res : fnnResponse.data.resources){
                            servicewithFNN.put(serv.id,res.resourceId);
                            servicewithSubcription.put(serviceID,serv);
                        }
                    }
                    logger.logMessages(JSON.serialize(fnnDto), JSON.serialize(fnnResponse), '', '', '', 
                                        '', String.valueof(fnnResponse.status), String.valueof(correlationId), '','',
                                       'Read','',requestTimeMap.get(serv.id) ,'POST',false, false);
                }else{
                    logger.logMessages(JSON.serialize(fnnDto), JSON.serialize(fnnResponse), '', '',  '', 
                                           '', String.valueof(fnnResponse.status), String.valueof(correlationId), 
                                       '','','Read','',requestTimeMap.get(serv.id) ,'POST',false, false);
                }                
            }   
            if(!servicewithSubcription.isEmpty()){
                if(scenarioType == 'Change of Mobile Number'){
                    MSISDNReserveServiceHandler.getNewMSISDNResponse(servicewithFNN, servicewithSubcription);
                }
                saveReserveNumbers(servicewithFNN, servicewithSubcription,'Mobile');
            }
            if(calloutCounter == servicewithFNN.size()){
                if(fnnResponse.status == 200 || fnnResponse.status == 201 || fnnResponse.status == 202){
                    system.debug('primaryOrderID>>>>' + primaryOrderID);
                    system.debug('setofServiceIdsString>>>>' + setofServiceIdsString);
                    system.debug('calloutCounter>>>>' + calloutCounter);
                    system.debug('servicewithFNN>>>>' + servicewithFNN.size());
                    processSuccessMSISDNReservation(setofServiceIdsString,calloutCounter,servicewithFNN.size(), primaryOrderID);
                }              
            }
            system.debug('servicewithFNN>>>>>>>>'+servicewithFNN);
            
            //EDGE-92021 End
            logger.exitLogger();
        }
        catch (Exception e) {
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), true, false);           
            logger.exitLogger();
        }
    }


 /******************************************************************
    EDGE-92021
    Method: saveReserveNumbers
    Description: save FFN/New reserved in Number object
    Author:Abinash Barik
    ******************************************************************/
    public static string saveReserveNumbers(Map<String, String> servicewithFNN,
        Map<String, csord__Service__c> servicewithSubcription,String selectedtype){ //EDGE-92021
        String status='Error';
        Number__c fnnNumber = null;
        List<Number__c> fnnNumberList = null;
        try{
            if(servicewithFNN.size() > 0){
                fnnNumberList = new List<Number__c>();
                for(String serviceId:servicewithFNN.keyset()){
                    if(servicewithSubcription.containsKey(serviceId)){
                        csord__Service__c service =servicewithSubcription.get(serviceId); 
                        fnnNumber = new Number__c();
                        fnnNumber.Basket__c = service.csordtelcoa__Product_Basket__c;
                        fnnNumber.Account__c = service!=null? service.csordtelcoa__Product_Basket__r.csbb__Account__c : null;
                        fnnNumber.Service_Number__c = servicewithFNN.get(serviceId);
                        fnnNumber.Status__c = 'RESERVED';
                        fnnNumber.Mobile__c=selectedtype;
                        fnnNumber.Type__c= selectedtype == 'Mobile'?'New':'FNN';
                        fnnNumberList.add(fnnNumber);
                    }
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
    public void HeldToReserveMSISDN(String token)
    {
        system.debug('Inside HeldToReserveMSISDN');
        List <csord__Service__c> serviceList = new List <csord__Service__c> ();
        Map<String,HttpResponse> msidnrespMap = new Map<String,HttpResponse>();
        HttpResponse ReserveResponse;
        String configId = '';
        String resourId = '';
        List<csord__Service__c> servList = new List<csord__Service__c>();
        List<cscfga__Attribute__c> attrList = new List<cscfga__Attribute__c>();
        List<String> configIdList = new List<String>();
        Long requestTime;
        String correlationId;
        Map<Id,Long> requestTimeMapHTR=new Map<Id,Long>();
        Map<Id,String> correlationIdMapHTR=new Map<Id,String>();
        try {
            for(csord__Service__c ser : [select id, name,csordtelcoa__Product_Configuration__c from csord__service__c where id IN : serviceIDFNNDTOMap.keySet()])
            {
                serviceList.add(ser);
                configIdList.add(ser.csordtelcoa__Product_Configuration__c);
            }
            
            attrList = [select id,name,cscfga__value__c from cscfga__attribute__c where cscfga__Product_Configuration__c IN :configIdList and name like '%MSISDN%'];
            for(csord__Service__c serv : serviceList)
            {
                if (serv!= null)
                {
                    configId = serv.csordtelcoa__Product_Configuration__c;
                }
                if(configId.length()>1){
                    for(cscfga__Attribute__c attr : attrList){
                        resourId =  attr.cscfga__value__c ;
                    }}
                correlationId = IntegrationRecordHandlerUtil.getCorrelationId();
                correlationIdMapHTR.put(serv.Id,correlationId);
                String  reqBody= JSON.serialize(serviceIDFNNDTOMap.get(serv.id),true);
                Map<String,String> headerMap = new Map<String, String>();
                headerMap.put('Accept','application/json'); 
                headerMap.put('Content-type','application/json');
                headerMap.put('Authorization','Bearer '+token);
                headerMap.put('X-HTTP-Method-Override','PATCH');
                Map<String, String> pathMap = new Map<String, String>{'msisdn' => resourId};
                    system.debug('pathMap::'+pathMap);
                DateTime startTime = DateTime.now();
                ReserveResponse = IntegrationRecordHandlerUtil.calloutSync(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST,headerMap,handlerName, pathMap);
                
                calloutCounter++;
                DateTime endTime = DateTime.now();
                requestTime = Logger.getRequestTimeDifference(startTime, endTime);
                requestTimeMapHTR.put(serv.Id,requestTime);
                System.debug('Respone  :'+ReserveResponse); 
                System.debug('Respone Body :'+ReserveResponse.getBody());
                msidnrespMap.put(serv.id,ReserveResponse);
            }
            
            
            if(calloutCounter == serviceIDFNNDTOMap.size()){
                system.debug('responseMap ' + msidnrespMap);
                for(String heldservID : msidnrespMap.keySet()){
                    HttpResponse mResponse = msidnrespMap.get(heldservID);
                    String reqBody = JSON.serialize(serviceIDFNNDTOMap.get(heldservID),true); 
                    if (mResponse.getStatusCode() == 200 || mResponse.getStatusCode() == 201 || mResponse.getStatusCode() == 202) {
                        //FNNResponseDTO fnnRes = FNNResponseDTO.parse(mResponse.getBody());
                        successCounter++;
                        //logger.logMessages(reqBody , mResponse.getBody(), '', '', '', '', false, false,Integer.valueof(mResponse.getStatusCode()) , null, null, null);
                        //CLF Start - EDGE-127368
                        logger.logMessages(reqBody, mResponse.getBody(), '', '', '', 
                                           '', String.valueOf(mResponse.getStatusCode()), correlationIdMapHTR.get(heldservID), '','','Read','',requestTimeMapHTR.get(heldservID) ,'POST',false, false);
                        //CLF end - EDGE-127368
                    }
                    else{
                        //CLF Start - EDGE-127368
                        logger.logMessages(reqBody, mResponse.getBody(), '', '', '', 
                                           '', String.valueOf(mResponse.getStatusCode()), correlationIdMapHTR.get(heldservID), '','','Read','',requestTimeMapHTR.get(heldservID) ,'POST',false, false);
                        //CLF end - EDGE-127368
                        //logger.logMessages(reqBody, mResponse.getBody(), '', '', '', '', false, false, Integer.valueOf(mResponse.getStatusCode()) , null, null, null);
                        
                    }
                }
                logger.exitLogger();
            }               
            processSuccessheldMSISDN(primaryOrderID,successCounter,inputListSize);
            
        }
        catch (Exception e) {
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), true, false);
           
            logger.exitLogger();
        }
        
    }
    
    @future
    public static void processSuccessheldMSISDN(String primaryOrderID, Integer successCounter, Integer inputListSize)
    {
        List<csord__Order__c> ordList = new List<csord__Order__c>();
        if(successCounter == inputListSize){
            for(csord__Order__c ord : [select id, isMSISDNReserved__c from csord__Order__c where id =:primaryOrderID])
            {
                ord.isMSISDNReserved__c = true;
                ordList.add(ord);
            }
            update ordList; 
        }
    }
    //Commented by Abinash- Edge-92021
    /*@future
    public static void processSuccessMSISDNReservation(String serviceID, String resourceID, Integer fnnListSize,Integer successCounter, String primaryOrderID)
    {   
        Map<String,Map<String,String>> guidAddAttrMap = new Map<String,Map<String,String>>();
        Map<String,String> addAttrMap = new Map<String,String>();
        Map<String,Map<String,String>> AttrMap = new Map<String,Map<String,String>>();
        system.debug('Service ' + serviceID);
        List<CS_SpecificationDTO.ServiceSpecification> srvSpecList = ServiceSpecificationUtils.getAllServSpecsByServId(serviceID,'FULFILMENT'); 
        
        Map<Id,Attachment> updatedAttMap = new Map <Id,Attachment>();
        
        for(CS_SpecificationDTO.ServiceSpecification srvSpec : srvSpecList){
            
            if(srvSpec.code.contains('DMCAT_ProductSpecification_000263'))
            {
                for(CS_SpecificationDTO.SimpleAttributes attr :srvSpec.additionalAttributes){
                    addAttrMap.put(attr.name,attr.value);
                }
                Map<String,String> newAddAttrMap = new Map<String,String>();
                newAddAttrMap.put('CustomerFacingServiceId',resourceId);
                guidAddAttrMap.put(srvSpec.guid,addAttrMap);
                Map<String,String> existingAttrMap = new Map<String,String>();
                
                for(String key : guidAddAttrMap.keyset())
                {
                    existingAttrMap.putAll(guidAddAttrMap.get(key));
                    existingAttrMap.putAll(newAddAttrMap);
                }
                AttrMap.put(srvSpec.guid,existingAttrMap);
                
                System.debug('AttrMap::' + AttrMap);
                
                for(String guid : AttrMap.keyset()) {
                    updatedAttMap.putAll(ServiceSpecificationUtils.getAddCharacteristic(serviceID,guid,AttrMap.get(guid)));       
                }                
            }
        }
        //taking DML statement out of for loop
        if(!updatedAttMap.isEmpty()) {
            update updatedAttMap.values();
        }
        
        String configId = '';
        for(csord__Service__c serv : [select id, name,csordtelcoa__Product_Configuration__c from csord__service__c where id =: serviceID]){
            configId = serv.csordtelcoa__Product_Configuration__c;
        }
        if(configId.length()>1){
            List<cscfga__Attribute__c> attrList = [select id,name,cscfga__value__c from cscfga__attribute__c where cscfga__Product_Configuration__c =: configId and name like '%MSISDN%'];
            for(cscfga__Attribute__c attr : attrList){
                attr.cscfga__value__c = resourceId;
            }
            update attrList;
        }
        
        if(successCounter == fnnListSize){
            List<csord__Order__c> orderList = new List<csord__Order__c>();
            List<RecordType> orderRecordTypeList = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'csord__Order__c' and name='MSISDN Required' limit 1];
            if (!orderRecordTypeList.isEmpty())
            {
                for(csord__Order__c ord : [select id, isMSISDNHeld__c,csord__Status2__c,RecordTypeId from csord__Order__c where id =:primaryOrderID]){
                    
                    ord.isMSISDNHeld__c = true;
                    //ord.csord__Status2__c='MSISDN Reserved';
                    //ord.RecordTypeId = orderRecordTypeList[0].Id;
                    orderList.add(ord);
                }
            }
            update orderList; 
            
        }
    }*/
    
    // Edge-92091 Start
    @future
    public static void processSuccessMSISDNReservation(set<string> setofServiceIdsString,Integer fnnListSize,Integer successCounter, String primaryOrderID)
    {  
        Map<String,csord__Service__c> servicewithSubcription = new Map<String,csord__Service__c>();
        map<String,String> servicewithFNN = new map<String,String>();
        List <csord__Service__c> serviceList = [select Id,csord__Subscription__c,serviceMSISDN__c,csord__Subscription__r.serviceMSISDN__c, 
                                                csord__Service__c, Scenario_Type__c,csordtelcoa__Product_Configuration__c 
                                                from csord__Service__c where Id IN :setofServiceIdsString];
        
        for(csord__Service__c service: serviceList){
            servicewithSubcription.put(service.id,service);
            servicewithFNN.put(service.id,service.serviceMSISDN__c);
        }
        Map<String, Attachment> servAttachmentRecordMap = new Map<String, Attachment>();
        Map<Id,String> serviceAttachmentMap = new Map<Id,String>();
        if(!servicewithSubcription.isEmpty()){          
            for(Attachment att: [Select id,body,parentId from Attachment where parentId in :servicewithSubcription.keySet()]){
                servAttachmentRecordMap.put(att.parentId,att);
                serviceAttachmentMap.put(att.parentId,att.body.toString());
            }  
        }
        if(!servAttachmentRecordMap.isEmpty()){
            for(String servId : servAttachmentRecordMap.keySet()){
                Attachment att = servAttachmentRecordMap.get(servId);
                List<CS_SpecificationDTO.ServiceSpecification> srvSpecList = getAllServSpecslist(att,'FULFILMENT');
                prepareServiceSpecsToupdate(servId,att.body.toString(),srvSpecList,servicewithSubcription,AttMapTobeUpdated,servAttachmentRecordMap); 
            }
        }
        system.debug('AttMapTobeUpdated>>>>>>'+AttMapTobeUpdated);
        if(!AttMapTobeUpdated.isEmpty()) {
           // update AttMapTobeUpdated.values();
            //EDGE-179268 : PRM Action Types change of mobile number.
           LRMMSISDNAttachUpdate.MISDANAttachUpdate(AttMapTobeUpdated);
        }
        
        /**
         * Update Attribute with resouceId or FNN against respective service 
         */
         updateServiceAttribute( servicewithSubcription, servicewithFNN);
        
        /**
          * Update Order if the total service and process service is same
         */
         if(successCounter == fnnListSize){
             List<csord__Order__c> orderList = new List<csord__Order__c>();
             if(primaryOrderID != null){
                 orderList.add(new csord__Order__c(Id=primaryOrderID,isMSISDNHeld__c = true));
             }
             if(!orderList.isEmpty())
                 update orderList;
        }
        
    }
    // EDGE-92021: Update Attribute with resouceId or FNN against respective service
    Public Static void updateServiceAttribute(map<String,csord__Service__c> servicewithSubcription, map<String,String> servicewithFNN){
        map<string,string> mapproductconfig = new map<string,string>();
        //Clarify One config can linked with one service
        for(csord__Service__c serv : servicewithSubcription.values()){
            mapproductconfig.put(serv.csordtelcoa__Product_Configuration__c,serv.id);
        }
        if(!mapproductconfig.isEmpty()){
            List<cscfga__Attribute__c> attrList = [SELECT id,name,cscfga__value__c,cscfga__Product_Configuration__c 
                                                   FROM cscfga__attribute__c 
                                                   WHERE cscfga__Product_Configuration__c IN: mapproductconfig.keyset() 
                                                   AND name like '%MSISDN%'];
            if(!attrList.isEmpty()){
                for(cscfga__Attribute__c attr : attrList){
                    String serviceId = mapproductconfig.get(attr.cscfga__Product_Configuration__c);
                    attr.cscfga__value__c = servicewithFNN.get(serviceId); // it will populate resourceId/FNN number
                }
                update attrList;
            }
        }
    }
    //EDGE-92021: Prepare spec for respective service to be updated
    public static Map<String,Attachment> prepareServiceSpecsToupdate(String serviceId, String body,
                                List<CS_SpecificationDTO.ServiceSpecification> srvSpecList,
                                Map<String,csord__Service__c> servicewithSubcription,
                                Map<String,Attachment> updatedAttMap,Map<String,Attachment> MapservAttachment){
        Map<String,String> addAttrMap = new Map<String,String>();
        Map<String,Map<String,String>> guidAddAttrMap = new Map<String,Map<String,String>>();
        Map<String,Map<String,String>> AttrMap = new Map<String,Map<String,String>>();
        for(CS_SpecificationDTO.ServiceSpecification srvSpec : srvSpecList){
            
            if(srvSpec.code.contains('DMCAT_ProductSpecification_000263'))
            {
                for(CS_SpecificationDTO.SimpleAttributes attr :srvSpec.additionalAttributes){
                    addAttrMap.put(attr.name,attr.value);
                }
                Map<String,String> newAddAttrMap = new Map<String,String>();
                newAddAttrMap.put('CustomerFacingServiceId',servicewithSubcription.get(serviceId).serviceMSISDN__c);
                guidAddAttrMap.put(srvSpec.guid,addAttrMap);
                Map<String,String> existingAttrMap = new Map<String,String>();
                
                for(String key : guidAddAttrMap.keyset())
                {
                    existingAttrMap.putAll(guidAddAttrMap.get(key));
                    existingAttrMap.putAll(newAddAttrMap);
                }
                AttrMap.put(srvSpec.guid,existingAttrMap);
                
                System.debug('AttrMap::' + AttrMap);
                
                for(String guid : AttrMap.keyset()) {
                    //TODO
                    getAddCharacteristic(serviceID,body,guid,AttrMap.get(guid),MapservAttachment,updatedAttMap);       
                }                
            }
        }
        return updatedAttMap;
    }
    //EDGE-92021 : It will return update spec against each Attachment
    public static Map<String,Attachment> getAddCharacteristic(String serviceID, String body,String guid,
            Map<String, String> additionalAttrs, Map<String,Attachment> MapservAttachment,Map<String,Attachment> updatedAttMap){
        
        String bodyAdditionalAttr = ServiceSpecificationUtils.addAdditionalAttributeNoSOQL(body,guid,additionalAttrs);
        Attachment attAdd = MapservAttachment.get(serviceID);
        
        attAdd.body = Blob.valueOf(bodyAdditionalAttr);     
        System.debug('bodyAdditionalAttr LRMMSISDNService===>'+bodyAdditionalAttr);
        updatedAttMap.put(attAdd.id,attAdd);
        return updatedAttMap;
    }
    
    //----- get All,Billing,Fulfilment,Assurance Specs based on Service Id ----- EDGE - 92021//
    public static List<CS_SpecificationDTO.ServiceSpecification> getAllServSpecslist(Attachment att, String targetSystem){
        List<CS_SpecificationDTO.ServiceSpecification> srvSpecList = new List<CS_SpecificationDTO.ServiceSpecification>();
        
        try{
            if(att != null){
                String body = att.body.toString();
                if(targetSystem == 'ALL'){                    
                    srvSpecList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(body)));
                }else if(targetSystem == 'BILLING'){
                    
                    srvSpecList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(body),'BILLING'));
                }else if(targetSystem == 'FULFILMENT'){                    
                    srvSpecList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(body),'FULFILMENT'));
                } else if(targetSystem == 'ASSURANCE'){
                    
                    srvSpecList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(body),'ASSURANCE'));
                }
            }
            System.debug('srvSpecList::' + srvSpecList);
            return srvSpecList;
        }
        catch (Exception e){
            System.debug(' Exception in getAllServSpecsByServId:' + e);
            return srvSpecList; 
        }
    }
    
    // EDGE-92021 End
    
}