/*
* @Author : Ravindran Shanmugam
* @Date :  21 October 2019
* @Desc :  Tramas Batch Eligbility Check 
* @Jira Cloud : EDGE-92541
1. Ankit/Vivek  EDGE-101034  Bypass mapping of service id for TIPT-SIPC Product
*/
public with sharing class TramasBatchEligibilityCheckService {
    //Manoj : variable declarations for nguc & cwp Tramas callout
    public Static final String ngucText = 'nguc';
    public Static final String cwpText = 'cwp';
    public Static final String TramasBatchHandler = 'TramasBatchHandler';
    public Static final String serviceType = 'service';
    public Static final String oprTypeCreate = 'transition::create';
    public Static final String TransitionJSONData = 'TransitionJSONData.json';
    public Static final String validateOperation = 'validate';
    public Static final String TM1 = 'TM1';
    public Static final String TM2 = 'TM2';
    public Static final String reserveOperation = 'reserve';

    //Start of DIGI-33080 by Abhishek(Osaka) to introduce IoT for Check Eligiblity
    public static Map<string,Sobject> MTMMetadataUtilityMap = ConstantMetadataUtility.getConstantMetadataUtilityRecords('MTM_Metadata_Utility__mdt');
    public static String IoT_Dormancy = String.valueOf(MTMMetadataUtilityMap.get('IoT_Dormancy').get('Value__c'));
    //End of DIGI-33080
    
    
    //This Method will be called from CompUtilityReplicatorManager class to Initiate Call 
    public static void constructBatchCreateRequest (Map<String,ReplicatorGetServiceDataObject_V2> pc_ServiceDtoMap,String prdFamily){
        constructBatchRequest (pc_ServiceDtoMap, oprTypeCreate,prdFamily);
    }
    
    
    //This Method has writter to parse attachment and create request JSON for Transition Call of cwp product
    public static void constructBatchRequest (Map<String,ReplicatorGetServiceDataObject_V2> mapPCToServiceDTO, String operationType,String prdFamily){

        Logger2 logger2 = Logger2.getLogger('TramasBatchEligibilityCheckService :: constructBatchRequest');
    
       try {    
        system.debug('valueofmapPCToServiceDTO'+mapPCToServiceDTO);
            //Retrieve all PCR records for obtaining PC and Basket details
            map<id,TramasBatchRequestDTO> mapofbulkrequest= new map<id,TramasBatchRequestDTO>();
            set<TramasBatchRequestDTO> setofbulkrequest= new set<TramasBatchRequestDTO>();
            Map<String,cscfga__Product_Configuration__c> pcMap = new Map<String,cscfga__Product_Configuration__c>();
            for(cscfga__Product_Configuration__c pc :[SELECT id,cscfga__Product_Basket__c, name FROM cscfga__Product_Configuration__c WHERE Id in:mapPCToServiceDTO.keySet()]){
                pcMap.put(pc.Id , pc);
            }
            //Logic to create TramasBatchRequestDTO for each site, and inserting a callout-request for each site
           // System.debug(' pcMap ' +pcMap);
            Integer index=0;
            Attachment attachmentRecord = null; // Attachment record where the callback response would be appended.
            TramasElgibilityCallbackResponse__c newResponse = null;
            
            List<TramasElgibilityCallbackResponse__c> listOfResponseRecords= new List<TramasElgibilityCallbackResponse__c>();
            List<Attachment> listOfAttachments =new List<Attachment>();
            TramasBatchRequestDTO batchEligibilityReq= new TramasBatchRequestDTO();

            for(Id pcID:pcMap.keySet()){
                
                //batchEligibilityReq.Correlation_ID=getCorrelationId();
               // batchEligibilityReq.Service_Provider_ID='Retail (002)'; 
                TramasBatchRequestDTO.operationList oprn = null;
                TramasBatchRequestDTO.identifierList identifiers = null;                       
                TramasBatchRequestDTO.attributesList attributs = null;
               // System.debug('batchEligibilityReq '+batchEligibilityReq);
               // System.debug('batchEligibilityReq '+mapPCToServiceDTO.get(pcID));
                system.debug('***Telstra:TM1EligibilityCheckService:value of pcID:'+ pcID +' serviceObjDTO:'+mapPCToServiceDTO.get(pcID));
                for(ReplicatorGetServiceDataObject_V2.SiteDTO_V2 siteObj : (mapPCToServiceDTO.get(pcID)).site)  
                {
                    
                    for(ReplicatorGetServiceDataObject_V2.productListDTO product: siteObj.productList)
                    {
                        // Instantiate a new Operations everytime a new product is to be added to the request DTO.
                        
                        oprn = new TramasBatchRequestDTO.operationList ();
                        oprn.type= operationType;
                        //target block
                        TramasBatchRequestDTO.target trgt= new TramasBatchRequestDTO.target();
                        trgt.type=prdFamily;
                        //properties block of transition
                        TramasBatchRequestDTO.trnpropr  trnasitionproprty= new TramasBatchRequestDTO.trnpropr();
                        trnasitionproprty.family =(product.Product_Type).toLowerCase();
                        //transition block
                        TramasBatchRequestDTO.transitionList transition = new TramasBatchRequestDTO.transitionList();
                        transition.type= serviceType;
                        transition.target=trgt;
                        transition.properties=trnasitionproprty;
                        //properties block of operation
                        TramasBatchRequestDTO.opnProperties oprnProperties = new TramasBatchRequestDTO.opnProperties ();
                        //oprnProperties.family =product.Product_Type;
                        oprnProperties.transitions.add(transition);
                        oprn.properties=oprnProperties;
                        batchEligibilityReq.operations.add(oprn);
                      
                        
                        System.debug('***Telstra:TM1EligibilityCheckService:value of Product List:'+product);
                        if(product.checkValue) {  // indicates the product is selected 
                
                            for(ReplicatorGetServiceDataObject_V2.serviceListDTO svcList:product.serviceList ) {
                                if(svcList.transitionId==null){
                                    for(ReplicatorGetServiceDataObject_V2.ServiceDTO_V2 svc:svcList.service ) {
                                       // if (svc.checkValue) { // service selected for the transition.
                                       
                                        TramasBatchRequestDTO.identifierList identifiers1 = new TramasBatchRequestDTO.identifierList ();
                                            if (svc.serviceExtension != null && svc.serviceExtension.size() > 0) {
                                                for(ReplicatorGetServiceDataObject_V2.ServiceExtensionDTO_V2 servExt:svc.serviceExtension){
                                                    identifiers1.identifier = svc.Service_Id;
                                                    identifiers = new TramasBatchRequestDTO.identifierList ();
                                                    //if(servExt.size()>0) {
                                                       identifiers.identifier = servExt.Services_From + '-' + servExt.Services_To;  
                                                        trnasitionproprty.identifiers.add(identifiers1);                                                   
                                                       trnasitionproprty.identifiers.add(identifiers);
                                                   // }                                                   
                                                }
                                            } else {
                                                identifiers = new TramasBatchRequestDTO.identifierList();
                                                identifiers.identifier = svc.Service_Id;
                                                trnasitionproprty.identifiers.add(identifiers);
                                            }
                                                if ( svc.Association_Role != '' && svc.Association_Role != null ) { // && !svc.Association_Role.trim() == ''
                                                    attributs = new TramasBatchRequestDTO.attributesList ();
                                                    attributs.key= 'role'; 
                                                    attributs.value =svc.Association_Role.trim();
                                                    //identifiers.attributes = attributes;
                                                    //identifiers.attributesList = new List<TramasBatchRequestDTO.attributes>();
                                                    identifiers.attributes.add(attributs);
                                                    if(identifiers!=null)
                                                    identifiers1.attributes.add(attributs);
                                                }
                                               // txnProperties.identifierList.add(identifiers);
                                            //}
                                     //  }
                                    }
                                }
                            }
                        }
                    }
                    system.debug('BatchDebug'+JSON.serialize(batchEligibilityReq));
                  //Manoj Kumar
                    setofbulkrequest.add(batchEligibilityReq);
                    mapofbulkrequest.put(pcID,batchEligibilityReq);
                }
                
            }

            for(Id prcid:mapofbulkrequest.keyset()){
                        String param=prcid+':'+cwpText+':'+getCorrelationId();
                         IntegrationRecordHandlerUtil.createRequests(TramasBatchHandler, new List<String>{param},JSON.serialize(mapofbulkrequest.get(prcid)));                
                    }
        } catch (Exception e) { 
           System.debug('***Telstra:TM1EligibilityCheckServiceV2:trException:'+e.getMessage());   
           System.debug('***Telstra:TM1EligibilityCheckServiceV2:trException:'+e.getLineNumber());
        }
        finally{
            logger2.exitLogger();
       }
    }
      //Future method for integration-handler-framework, for making a callout to Tramas interface
    @future(callout=true)
    public static void sendEligibilityCheckRequest(String param) {
        System.debug('***Telstra:TramasBatchEligibilityCheckService:sendEligibilityCheckRequest:'+param);
        String handlerName = 'TramasBatchHandler';
        map<String,String> pcwithresponsemap= new map<String,String>();
        String prdType =  '';
        Logger2 logger2 = Logger2.getLogger(handlerName);
try{            
            //Get the request details from Integration-record
            Integration_Record__c paramRequest = [SELECT Id, params__c, paramPayload__c
                                                  FROM Integration_Record__c
                                                  WHERE params__c = :param order by CreatedDate desc LIMIT 1 ];
            Map<String,String> headerMap = new Map<String, String>();
          
                String token = AuthenticationManager.getOauthToken(TramasBatchHandler.class.getName());
       			//String token ='tGzv3JOkF0XG5Qx2TlKWIA';
                headerMap = new Map<String, String>{'Content-Type' => 'application/json','Originating-System' => 'Salesforce','Correlation-Id'=>getCorrelationId(),'Authorization'=> 'Bearer '+token};
              
            String requestDtoJson =  paramRequest.paramPayload__c;
            System.debug('***Telstra:TramasBatchEligibilityCheckService:Telstra:TramasBatchEligibilityCheckService:sendEligibilityCheckRequest:requestDtoJson:' + requestDtoJson );
            TramasBatchRequestDTO trEligibilityRequest= (TramasBatchRequestDTO) JSON.deserialize(requestDtoJson, TramasBatchRequestDTO.class);
            
            //Callout to TRAMAS
            HTTPResponse response = IntegrationRecordHandlerUtil.callout(JSON.serialize(trEligibilityRequest),
                                                                         IntegrationRecordHandlerUtil.HTTP_METHOD_POST,
                                                                         headerMap, handlerName, new List<String>{param},null);
            String[] params=param.split(':'); 
            System.debug('param ##'+param);            
            System.debug('params ##'+params); 
            System.debug('***Telstra:TramasBatchEligibilityCheckService:sendEligibilityCheckRequest:Response:'+response);
            
            //Logic to update UUID in TramasElgibilityCallbackResponse
            //Map<String, String> responseValues = (Map<String, String>)JSON.deserialize(response.getBody(), Map<String, String>.class);
           // System.debug('***Telstra:TramasBatchEligibilityCheckService:responseValues:'+responseValues);        
          /*  TramasElgibilityCallbackResponse__c responseRecord = [SELECT id,Correlation_ID__c,UUID__c FROM TramasElgibilityCallbackResponse__c WHERE Correlation_ID__c=:trEligibilityRequest.Correlation_ID];
            if(responseRecord!=null){
                responseRecord.UUID__c  =responseValues.get('UUID');         
                update responseRecord; 
                System.debug('responseRecord:'+responseRecord);                              
            }   */       
            //Adding the request-response in Application-logs
            if(response!= null && response.getStatusCode() ==IntegrationRecordHandlerUtil.HTTP_ACCEPTED ) { //Request was successfully accepted
                
               // prdType = params[1];
                pcwithresponsemap.put(params[0],response.getBody());
                
                system.debug('pcwithresponsemap'+pcwithresponsemap);
                logger2.logMessages(JSON.serialize(trEligibilityRequest), response.getBody(), '', '', '', '', false, false, Integer.valueOf(response.getStatusCode()) , null, null, null);
            } else {
                System.debug('***Telstra:TramasBatchEligibilityCheckService:ERROR sending email');
                String corId='';           
                //EDGE-198380
                TramasElgibilityCallbackResponse__c tramasNguc=new TramasElgibilityCallbackResponse__c();
                tramasNguc.Type__c='TM0 Execution Error';
                tramasNguc.Correlation_ID__c = string.valueof(getCorrelationId());
                tramasNguc.Product_Configuration__c = params[0];
                tramasNguc.name='TMBatchCallback';
                insert tramasNguc;
                   
                if(response!= null && !String.isEmpty(response.getBody()))               
                    logger2.logMessages(JSON.serialize(trEligibilityRequest), response.getBody(), '', '', '', '', false, false, Integer.valueOf(response.getStatusCode()) , null, null, null);
                 else 
                    logger2.logMessages(JSON.serialize(trEligibilityRequest), null, '', '', '', '', false, false, null , null, null, null);                         
                   }
            system.debug('valueofpcwithresponsemap'+pcwithresponsemap);
            if(pcwithresponsemap.size()>0){
                updateTransitionJson(pcwithresponsemap);
            }
           
}
        catch(Exception e){
            System.debug('***Telstra:TramasBatchEligibilityCheckService:trException:'+e.getMessage());
            System.debug('***Telstra:TramasBatchEligibilityCheckService:trException:'+e.getLineNumber());
            logger2.logMessages('TramasBatchEligibilityCheckService:sendEligibilityCheckRequest',e.getMessage() , '', '', '', '', false, false, null , null, null, null);                     
        }
        finally{
            logger2.exitLogger();
        }
    }
    //This method is to parse response and update on TranstionJson
    public static void updateTransitionJson(Map<String,String> pcwithresponsemap){
        Map<String,String> transitionWithServiceIdmap= new Map<String,String>();
       // Fetch custom metadata value ----EDGE-101034 || start
       map<string,boolean>transGroupStructHybridNew =new map<string,boolean>();
       for (Transition_Group_Structure_New__mdt transGroupStruct: [SELECT Hybrid__c, Product_Family__c FROM Transition_Group_Structure_New__mdt]) {
           transGroupStructHybridNew.put(transGroupStruct.Product_Family__c,transGroupStruct.Hybrid__c);//EDGE-152495
       }
        // Fetch custom metadata value ----EDGE-101034 || end
        for(String pcid:pcwithresponsemap.keyset()){
            TramasBatchResponseDTO trEligibilityRequest = TramasBatchResponseDTO.parse(pcwithresponsemap.get(pcid));
            for(TramasBatchResponseDTO.datalstdto dt:trEligibilityRequest.operations.data){
                system.debug('dataloop'+dt);
                string trnstring=dt.output.transitionId;
                system.debug('transitionvalue'+trnstring);
                //TramasBatchResponseDTO.outpt opt=trEligibilityRequest.operations.data.output;
                for(TramasBatchResponseDTO.transitionlstdto trloop:dt.output.transitions){
                    system.debug('transitionvalue'+trloop);
                    for(TramasBatchResponseDTO.identifierlstdto identloop: trloop.properties.identifiers ){
                        //system.debug('transitionvalue'+identloop);
                        if(!(identloop.identifier).contains('-')){
                            transitionWithServiceIdmap.put(identloop.identifier,dt.output.transitionId);
                            }
                          // Put transitionId on map ----EDGE-101034 || start
                         else if((identloop.identifier).contains('-') && trloop.properties.family != null && transGroupStructHybridNew.containsKey((trloop.properties.family).toUpperCase()) && transGroupStructHybridNew.get((trloop.properties.family).toUpperCase())){
                            List<string>serviceIdentifier=(identloop.identifier).split('-');
                            transitionWithServiceIdmap.put(serviceIdentifier[0],dt.output.transitionId);

                         }
                           // Put transitionId on map ----EDGE-101034 || End
                    }
                }
            }
        }
        
        system.debug('transitionWithServiceIdmap'+transitionWithServiceIdmap);
        map<String,String> prcWithAttachmentMap= new map<String,String>();
        map<String,String> attachmentWithPCRidmap= new map<String,String>();
        //Map for nguc
        map<String,String> nguc_pcAttachmentMap= new map<String,String>();
        map<String,String> nguc_attachmentPCMap= new map<String,String>();
        system.debug('pcwithresponsemap **'+pcwithresponsemap);
        
        for(Attachment attloop:[select id,name,body,parentid from Attachment where parentid in: pcwithresponsemap.keyset() and (name =:TransitionJSONData or Name=:system.label.NgUcTransitionName)]){
            if(attloop.Name == TransitionJSONData){
                 prcWithAttachmentMap.put(attloop.parentid,attloop.body.toString());
                attachmentWithPCRidmap.put(attloop.ParentId,attloop.id);
            }
            if(attloop.Name==system.label.NgUcTransitionName){
                nguc_pcAttachmentMap.put(attloop.parentid,attloop.body.toString());
                nguc_attachmentPCMap.put(attloop.ParentId,attloop.id);
            }
               
        }   
        system.debug('prcWithAttachmentMap##'+prcWithAttachmentMap);
        system.debug('attachmentWithPCRidmap##'+attachmentWithPCRidmap);
        system.debug('nguc_pcAttachmentMap##'+nguc_pcAttachmentMap);
        system.debug('nguc_attachmentPCMap##'+nguc_attachmentPCMap);
        //------------- cwp flow ------------------//
        if(!prcWithAttachmentMap.IsEmpty()){//This Block is for update TranstionId in TransitionJson.
            map<string,String> attachmentWithIdUpdatemap= new map<string,String>();
        Map<id, List<String>> secondMap = new Map<id, List<String>>(); 
        for(Id tmId:pcwithresponsemap.keyset()){
            
            Map<String, Object> meta = (Map<String, Object>) JSON.deserializeUntyped(prcWithAttachmentMap.get(tmId));
            List<Object> sites = (List<Object>)meta.get('site');
            for(object site:sites){
                Map<String, Object> products=(Map<String, Object>)site;
                List<Object> productlst = (List<Object>)products.get('productList');
                for(object product:productlst){
                    Map<String, Object> servs=(Map<String, Object>)product;
                    List<Object> servlst = (List<Object>)servs.get('serviceList');
                    for(object serv:servlst){
                        Map<String, Object> services=(Map<String, Object>)serv;
                        List<Object> serviceslst = (List<Object>)services.get('service');
                        for(object service:serviceslst){
                            Map<String, Object> servicextns=(Map<String, Object>)service;
                            List<object> extnlist=(List<Object>)servicextns.get('serviceExtension');
                            
                            if(services.get('transitionId')==null){
                                for(String attributeName : servicextns.keyset()) {
                                    if(attributeName=='Service_Id'){
                                        for(String fnnNumber:transitionWithServiceIdmap.keyset()){
                                            if(fnnNumber==servicextns.get('Service_Id')){
                                                services.put('transitionId',transitionWithServiceIdmap.get(fnnNumber));
                                                 if(!secondMap.containsKey(tmId)){
                                                    secondMap.put(tmId, new List<String>{transitionWithServiceIdmap.get(fnnNumber)});
                                                 }else{
                                                    secondMap.get(tmId).add(transitionWithServiceIdmap.get(fnnNumber));
                                                }
                                                //servicextns.put('eligibilityReason',eligibiltyReasonMap.get(fnnNumber));
                                            }
                                        }
                                    }
                                }
                            
                        }
                            
                        }
                       
                    }
                }
            }
            
            attachmentWithIdUpdatemap.put((attachmentWithPCRidmap.get(tmId)),string.valueof(JSON.serializePretty(meta)));
            
            //System.debug('***Telstra:TramasEligiblityUpdate:NewJSON'+string.valueof(JSON.serializePretty(meta)));
            System.debug('***Telstra:TramasEligiblityUpdate:NewJSON'+attachmentWithIdUpdatemap);
            system.debug('*****Secondmap*******'+secondMap);
            
        }       
        
        if(attachmentWithIdUpdatemap.size()>0){
            List<Attachment> listAttachment = new List<Attachment>();
            List<attachment> dltlist= new List<attachment>();
            map<string, string> attachmentPCR = new map<string, string>();
            for(attachment attloop:[Select id,Parentid,name,body from attachment where id in:attachmentWithIdUpdatemap.keyset()]){
                
                Attachment att = new Attachment();
                att.Name =  attloop.name;//'TransitionJSONData.json';
                att.ParentId = attloop.Parentid;
                att.Body = blob.valueof(attachmentWithIdUpdatemap.get(attloop.id));
                listAttachment.add(att);
                dltlist.add(attloop);
                attachmentPCR.put(attloop.Parentid, attloop.body.tostring());
            }
            if(listAttachment.size()>0){
                delete dltlist;
                insert listAttachment;
            }
        }
        if(secondMap.size()>0){
            system.debug('secondmap'+secondMap);
            executionTransition(secondMap,validateOperation);
        }
        }
        //-------------- nguc flow ----- //
        if(!nguc_pcAttachmentMap.IsEmpty()){
             map<string,String> attachmentWithIdUpdatemap= new map<string,String>();
             Map<id, List<String>> secondMap = new Map<id, List<String>>(); 
            for(String pc_Id:nguc_pcAttachmentMap.keyset()){
                Map<String, Object> meta = (Map<String, Object>) JSON.deserializeUntyped(nguc_pcAttachmentMap.get(pc_Id));
                List<Object> prdlst =(List<Object>)meta.get('productList');
                system.debug('ProductList'+prdlst );
                    for(object prd:prdlst){
                       Map<String, Object> sites=(Map<String, Object>)prd;
                       List<Object> sitelst = (List<Object>)sites.get('site');
                       system.debug('Sites## '+sitelst );
                           for(Object serv:sitelst){
                               Map<String, Object> services=(Map<String, Object>)serv;
                               List<object> servlst= (List<Object>)services.get('serviceList');
                               system.debug('servlst## '+servlst );
                               for(Object grp:servlst){
                                 Map<String, Object> grps=(Map<String, Object>)grp;
                                 List<object> grplst=(List<Object>)grps.get('groupType');
                                 system.debug('grplst## '+grplst );
                                   for(Object gp:grplst){
                                       Map<String, Object> grpmap=(Map<String, Object>)gp;
                                       List < object > serlst = (List < Object > ) grpmap.get('service');
                                       
                                       for (String attributeName : grpmap.keyset()) {
                                            system.debug('####attributeName ' + attributeName);
                                           if(attributeName=='transitionId'){ 
                                               
                                               if((grpmap.get('transitionId')==null) && grpmap.get('checkValue')==true){
                                               
                                             for (object ser: serlst) {
                                                if(grpmap.get('transitionId')==null){
                                                       Map < String, Object > servmap = (Map < String, Object > ) ser;
                                                       for (String attribute_Name: servmap.keyset()) {
                                                            system.debug('####attribute_Name ' + attribute_Name);
                                                           if (attribute_Name == 'Service_Id') {
                                                               system.debug('#############' + servmap.get('Service_Id'));
                                                               system.debug('########transitionWithServiceIdmap#####' + transitionWithServiceIdmap);
                                                               String serviceId = String.valueOf(servmap.get('Service_Id'));
                                                          grpmap.put('transitionId',transitionWithServiceIdmap.get(serviceId));
                                                          system.debug('#############' + grpmap.get('transitionId'));  
                                                    
                                             if(!secondMap.containsKey(pc_Id)){
                                                    secondMap.put(pc_Id, new List<String>{transitionWithServiceIdmap.get(serviceId)});
                                                    
                                                 }else{
                                                     
                                                    secondMap.get(pc_Id).add(transitionWithServiceIdmap.get(serviceId));
                                                     
                                                }
                                                               
                                                }}}}         
                                                   //
                                                   //grpmap.put('transitionId',transactionId);
                                          }
                                    }
                                 }
                               }
                           }
                    }
                        
             attachmentWithIdUpdatemap.put((nguc_attachmentPCMap.get(pc_Id)),string.valueof(JSON.serializePretty(meta))); 
            //System.debug('***Telstra:TramasEligiblityUpdate:NewJSON'+string.valueof(JSON.serializePretty(meta)));
            System.debug('***Telstra:TramasEligiblityUpdate:NewJSON'+attachmentWithIdUpdatemap);
            system.debug('*****Secondmap*******'+secondMap);
                }
                system.debug('valueofUpdatedJSON'+string.valueof(JSON.serializePretty(meta)));
               // attachmentUpdateMap.put(attid,string.valueof(JSON.serializePretty(meta)));
            }
            
             //Update logic
         if(attachmentWithIdUpdatemap.size()>0){
             System.debug('inside att list');
            List<Attachment> listAttachment = new List<Attachment>();
            List<attachment> dltlist= new List<attachment>();
            map<string, string> attachmentPCR = new map<string, string>();
            for(attachment attloop:[Select id,Parentid,name,body from attachment where id in:attachmentWithIdUpdatemap.keyset()]){
                
                Attachment att = new Attachment();
                att.Name =  attloop.name;//'TransitionJSONData.json';
                att.ParentId = attloop.Parentid;
                att.Body = blob.valueof(attachmentWithIdUpdatemap.get(attloop.id));
                listAttachment.add(att);
                dltlist.add(attloop);
                attachmentPCR.put(attloop.Parentid, attloop.body.tostring());
            }
            if(listAttachment.size()>0){
                delete dltlist;
                insert listAttachment;
            }
        }
        if(secondMap.size()>0){
            system.debug('secondmap'+secondMap);
            executionTransition(secondMap,validateOperation); 
        }
        }
       
    }
    //This method is used to Create Request for Tramas-Execution-Validate/Reseve Call
    public static void executionTransition(Map<id, List<String>> secondMap,String actionType){
        List<TramasElgibilityCallbackResponse__c> trmreqlist= new List<TramasElgibilityCallbackResponse__c>();
        Set<String> transactionIdSet= new Set<String>();
        //Set<String> mobilePC = new Set<String>();
        List<MobileTramasElgibility__c> MobileTramasElgibilityList = new List<MobileTramasElgibility__c>();
        map<String,String> pcWithBasketMap= new map<String,String>();
        for(cscfga__Product_Configuration__c pcloop:[select id,cscfga__Product_Basket__c,OfferName__c from cscfga__Product_Configuration__c where id in:secondMap.keySet()] ){
            pcWithBasketMap.put(pcloop.id,pcloop.cscfga__Product_Basket__c);
            //mobilePC.add(pcloop.OfferName__c);
        }
        String type='';
            for(String str:secondMap.keyset()){
                    system.debug('strvalue'+str);
                for(string inStr:secondMap.get(str)){
                    if(inStr!=null){
                        TramasElgibilityCallbackResponse__c newResponse = new TramasElgibilityCallbackResponse__c();
                        newResponse.name='TMBatchCallback';
                        newResponse.TranasactionId__c=inStr;
                        transactionIdSet.add(inStr);
                        if(actionType==validateOperation){
                            newResponse.Type__c=TM1;
                            newResponse.Product_Basket__c=pcWithBasketMap.get(str);
                            type=TM1;
                        }
                        else if(actionType==reserveOperation){
                            newResponse.Type__c=TM2;
                            newResponse.Product_Basket__c=pcWithBasketMap.get(str); //Incident Fix INC000097969196
                            type=TM2;
                        }
                            newResponse.Product_Configuration__c=str;
                            newResponse.Correlation_ID__c=string.valueof(getCorrelationId()); 
                            
                        trmreqlist.add(newResponse);                            
                        system.debug('inStr'+inStr);
                    }
                }
            }
            if(trmreqlist.size()>0)
            insert trmreqlist;
        
            Attachment attachmentRecord = null; 
            List<Attachment> listOfAttachments =new List<Attachment>();
            map<String,Attachment> tmreqwithAttachMap= new map<String,Attachment>();
            map<Id,cscfga__Product_Basket__c> basketUpdateMap= new map<Id,cscfga__Product_Basket__c>();
            for(TramasElgibilityCallbackResponse__c tmrequestloop:[select id, name,TranasactionId__c,type__c,Product_Configuration__c,Product_Configuration__r.cscfga__Product_Basket__c from TramasElgibilityCallbackResponse__c where Product_Configuration__c in:secondMap.keyset() and type__c=:type and TranasactionId__c in:transactionIdSet]){
                system.debug('tmrequestloop'+tmrequestloop);
                attachmentRecord = new Attachment();
                attachmentRecord.parentid=tmrequestloop.id;
                attachmentRecord.Body = Blob.valueOf('');
                if(actionType==validateOperation)
                attachmentRecord.Name = String.valueOf('EligibilityResults.txt');
                else if(actionType==reserveOperation)   +       
                attachmentRecord.Name = String.valueOf('ReserveResults.txt');
            
                attachmentRecord.Description=tmrequestloop.TranasactionId__c;
                listOfAttachments.add(attachmentRecord);
                tmreqwithAttachMap.put(tmrequestloop.TranasactionId__c,attachmentRecord);
                if(actionType==validateOperation){
                    cscfga__Product_Basket__c bsktRecord= new cscfga__Product_Basket__c();
                    bsktRecord.id=tmrequestloop.Product_Configuration__r.cscfga__Product_Basket__c;
                    bsktRecord.isEligibilityTriggered__c=false;
                    //bsktRecord.Transition_basket_stage__c='Check Eligibility Triggered';//EDGE-198380 commented 
                    bsktRecord.isEligibilityCheckComplete__c=false;
                    basketUpdateMap.put(tmrequestloop.Product_Configuration__r.cscfga__Product_Basket__c,bsktRecord);
                }
            }

        if(listOfAttachments.size()>0)
        insert listOfAttachments;
        
        if(basketUpdateMap.size()>0)
            update basketUpdateMap.values();
        
        map<String,TramasExecutionRequestDTO> mapOftramasExecutionRequest= new map<String,TramasExecutionRequestDTO>();
        system.debug('tmreqwithAttachMapvalue'+tmreqwithAttachMap);
        for(String tramasrecodid:tmreqwithAttachMap.keyset()){
                TramasExecutionRequestDTO trmExReq= new TramasExecutionRequestDTO();
                trmExReq.transitionId=tramasrecodid;
                trmExReq.mode=null;
                if(actionType==validateOperation)
                trmExReq.action=validateOperation;
                else if(actionType==reserveOperation)  
                trmExReq.action=reserveOperation;
            
                TramasExecutionRequestDTO.mtd mt= new TramasExecutionRequestDTO.mtd();
                String sfdcid=tmreqwithAttachMap.get(tramasrecodid).id;
                system.debug('sfdcid'+sfdcid);
                mt.salesforceId=sfdcid;
                trmExReq.metadata=mt;
                //system.debug('trmExReq'+trmExReq);
                 system.debug('trmExReq'+JSON.serialize(trmExReq));
                 mapOftramasExecutionRequest.put(tramasrecodid,trmExReq);
        }
        system.debug('mapOftramasExecutionRequest'+mapOftramasExecutionRequest);
        //Start Changes for EDGE-127536 Code Refector 
        List<String> paramList= new List<String>();
        map<String,TramasExecutionRequestDTO> requestWithbodyMap= new map<String,TramasExecutionRequestDTO>();
         for(String requestDTO:mapOftramasExecutionRequest.keySet()){
                //requestDTO.CallBack_URL = Label.TM1okapiAPI_baseURL+'/services/data/v45.0/sobjects/Attachment/'+mapRequestVsAttachment.get(requestDTO).id;                
                //IntegrationRecordHandlerUtil.createRequests('TM2TramasExecution', new List<String>{requestDTO+getCorrelationId()},JSON.serialize(mapOftramasExecutionRequest.get(requestDTO)));  
                String paramValue= requestDTO+getCorrelationId();
                paramList.add(paramValue);  
                requestWithbodyMap.put(paramValue,mapOftramasExecutionRequest.get(requestDTO));         
            }
            String handlerName='TM2TramasExecution';
            List<Integration_Record__c> existingRequests = [SELECT Id, params__c 
                                                            FROM Integration_Record__c 
                                                            WHERE params__c IN :CollectionUtil.removeNull(paramList)
                                                            AND handler__c = :handlerName 
                                                            AND (Status__c = :IntegrationQueueHandler.PENDING OR Status__c = :IntegrationQueueHandler.IN_PROGRESS)];
            for(String paramloop:paramList){
                IntegrationRecordHandlerUtil.createRequestsForTramas('TM2TramasExecution', new List<String>{paramloop},JSON.serialize(requestWithbodyMap.get(paramloop)),existingRequests); 
            }
            //End Changes for EDGE-127536 Code Refector 
    }
    /*Method to form correlation-id 
    * AES-key generated from Crypto-library, is used for forming correlation-id. 32-digits of AES-key(main-string) is divided into 4 groups(substring) of length 8.
    */
    public static String getCorrelationId() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String CorrelationId = h.SubString(0,8)+ '-' + h.SubString(8,16) + '-' + h.SubString(16,24) + '-' + h.substring(24);
        return CorrelationId;
    }
    
//This Method has written to send request to Tramas for Execution-Validate/Reseve call
    @future(callout=true)
    public static void sendBulkEligibilityCheckRequest(String param) {
        System.debug('***Telstra:TramasBatchEligibilityCheckService:sendBulkEligibilityCheckRequest:'+param);
        String handlerName = 'TM2TramasExecution';
      //  map<String,String> pcwithresponsemap= new map<String,String>();
        Logger2 logger2 = Logger2.getLogger(handlerName);
try{            
            //Get the request details from Integration-record
            Integration_Record__c paramRequest = [SELECT Id, params__c, paramPayload__c
                                                  FROM Integration_Record__c
                                                  WHERE params__c = :param order by CreatedDate desc LIMIT 1 ];
            Map<String,String> headerMap = new Map<String, String>();
          
                String token = AuthenticationManager.getOauthToken(TM2TramasExecution.class.getName());
               // String token='AMJHUEKDAJDRFZAS';
       
                headerMap = new Map<String, String>{'Content-Type' => 'application/json','Originating-System' => 'Salesforce','Correlation-Id'=>getCorrelationId(),'Authorization'=> 'Bearer '+token};
              
            String requestDtoJson =  paramRequest.paramPayload__c;
            System.debug('***Telstra:TramasBatchEligibilityCheckService:Telstra:TramasBatchEligibilityCheckService:sendBulkEligibilityCheckRequest:requestDtoJson:' + requestDtoJson );
            TramasExecutionRequestDTO trEligibilityRequest= (TramasExecutionRequestDTO) JSON.deserialize(requestDtoJson, TramasExecutionRequestDTO.class);
            
            //Callout to TRAMAS
            HTTPResponse response = IntegrationRecordHandlerUtil.callout(JSON.serialize(trEligibilityRequest),
                                                                         IntegrationRecordHandlerUtil.HTTP_METHOD_POST,
                                                                         headerMap, 'TM2TramasExecution', new List<String>{param},null);
            String[] params=param.split(':'); 
                        
            
            System.debug('***Telstra:TramasBatchEligibilityCheckService:sendBulkEligibilityCheckRequest:Response:'+response);
            
            //Logic to update UUID in TramasElgibilityCallbackResponse
            //Map<String, String> responseValues = (Map<String, String>)JSON.deserialize(response.getBody(), Map<String, String>.class);
           // System.debug('***Telstra:TramasBatchEligibilityCheckService:responseValues:'+responseValues);        
          /*  TramasElgibilityCallbackResponse__c responseRecord = [SELECT id,Correlation_ID__c,UUID__c FROM TramasElgibilityCallbackResponse__c WHERE Correlation_ID__c=:trEligibilityRequest.Correlation_ID];
            if(responseRecord!=null){
                responseRecord.UUID__c  =responseValues.get('UUID');         
                update responseRecord; 
                System.debug('responseRecord:'+responseRecord);                              
            }   */       
            //Adding the request-response in Application-logs
            if(response!= null && response.getStatusCode() ==IntegrationRecordHandlerUtil.HTTP_ACCEPTED ) { //Request was successfully accepted
              // pcwithresponsemap.put(params[0],response.getBody());
                logger2.logMessages(JSON.serialize(trEligibilityRequest), response.getBody(), '', '', '', '', false, false, Integer.valueOf(response.getStatusCode()) , null, null, null);
            } else {
                System.debug('***Telstra:TramasBatchEligibilityCheckService:ERROR sending email');
                String corId='';           
                if(response!= null && String.valueOF(response.getstatusCode()).startsWith('4')){
                    logger2.logMessages(JSON.serialize(trEligibilityRequest), response.getBody(), '', '', '', '', false, false, Integer.valueOf(response.getStatusCode()) , null, null, null);
				//EDGE-198375:NGUC-update type and errorcode in case of callout failure
                    List<TramasElgibilityCallbackResponse__c> tramasNgucRecs=[SELECT id,TranasactionId__c,Type__c,Error_code__c 
                                                                         FROM TramasElgibilityCallbackResponse__c WHERE TranasactionId__c =: trEligibilityRequest.transitionId];                    
                     system.debug('trEligibilityRequest**'+trEligibilityRequest);
                    MobileTramasCallBackResponseDTO dto= MobileTramasCallBackResponseDTO.parse( response.getBody());
                   
                    for(TramasElgibilityCallbackResponse__c tramasRec :tramasNgucRecs ){
                       
                        if(dto!=null && dto.Error!=null){
                       	 	tramasRec.Type__c='Execution Error';
                        	tramasRec.Error_code__c=dto.Error.code;
                         }
                    }
                //EDGE-198375: Mobility-update type and errorcode in case of callout failure
                List<MobileTramasElgibility__c> tramasMobileRecs=[SELECT id,TranasactionId__c,Type__c,ErrorCode__c 
                                                                         FROM MobileTramasElgibility__c WHERE TranasactionId__c =: trEligibilityRequest.transitionId];                    
                    for(MobileTramasElgibility__c tramasRec :tramasMobileRecs ){
                       
                        if(dto!=null && dto.Error!=null){
                       	 	tramasRec.Type__c='Execution Error';
                        	tramasRec.ErrorCode__c=dto.Error.code;
                         }
                    }
                    
                    if(!tramasNgucRecs.isEmpty()) {
                        update tramasNgucRecs;
                    }
                    system.debug('tramasNgucRecs :' +tramasNgucRecs);
                     if(!tramasMobileRecs.isEmpty()) {
                        update tramasMobileRecs;
                    }
                }           
                else {
                    logger2.logMessages(JSON.serialize(trEligibilityRequest), null, '', '', '', '', false, false, null , null, null, null);                         
  
                }
                   }
                   
           // system.debug('valueofpcwithresponsemap'+pcwithresponsemap);
            
}
        catch(Exception e){
            System.debug('***Telstra:TramasBatchEligibilityCheckService:trException:'+e.getMessage());
            System.debug('***Telstra:TramasBatchEligibilityCheckService:trException:'+e.getLineNumber());
            logger2.logMessages('TramasBatchEligibilityCheckService:sendEligibilityCheckRequest',e.getMessage() , '', '', '', '', false, false, null , null, null, null);                     
        }
        finally{
            logger2.exitLogger();
        }
    }
    
    /*************************************************************************************************
Date : 12 Nov 2019
EDGE-> 
Author: Manoj Kumar
Description : Method to cunstruct tramas transition request for NGUC
***********************************************************************************************/   
   public static void constructNgucBatchRequest (string ngucTransitionDTO, string pcId, String prdFamily){
        
        TramasBatchRequestDTO batchEligibilityReq= new TramasBatchRequestDTO();
        TramasBatchRequestDTO.operationList oprn = new TramasBatchRequestDTO.operationList();
        TramasBatchRequestDTO.identifierList identifiers = null;                       
        TramasBatchRequestDTO.attributesList attributes = null;
        // Fetch custom metadata value ----EDGE-101034 || start
           map<string,boolean>transGroupStructHybrid =new map<string,boolean>();
           for (Transition_Group_Structure_New__mdt transGroupStruct: [SELECT Hybrid__c, Product_Family__c FROM Transition_Group_Structure_New__mdt]) {
               transGroupStructHybrid.put(transGroupStruct.Product_Family__c,transGroupStruct.Hybrid__c);//EDGE-152495
           }
        //EDGE-101034|| end
        
        String handlerName = 'TramasBatchHandler';
        
        Logger2 logger2 = Logger2.getLogger(handlerName);
        try{
            map<String,TramasBatchRequestDTO> mapofbulkrequest= new map<String,TramasBatchRequestDTO>();
            
            TransitionDataDTO transitionDTO=TransitionDataDTO.parse(ngucTransitionDTO);
            String cidn=transitionDTO.CIDN;
            List<String> serviceIdList=new List<String>(); 
            List<TransitionDataDTO.SiteDTOMobile> siteList=new list<TransitionDataDTO.SiteDTOMobile>();
            
            for(TransitionDataDTO.productListDTO productList:transitionDTO.productList){
      System.debug('*** :productList '+ productList);
      System.debug('*** :productListSize '+ transitionDTO.productList.Size());
       //TramasBatchRequestDTO.trnpropr  trnasitionproprty= new TramasBatchRequestDTO.trnpropr(); // EDGE-101034 commented by ankit
       // batchEligibilityReq.operations.add(oprn);
       
      for(TransitionDataDTO.SiteDTOMobile siteDTO:productList.site ){
        for(TransitionDataDTO.serviceListDTOMobile serviceListDTO:siteDTO.serviceList ){
          
          for(TransitionDataDTO.groupDTOMobile groupDTO:serviceListDTO.groupType ){
            TramasBatchRequestDTO.trnpropr  trnasitionproprty= new TramasBatchRequestDTO.trnpropr();// EDGE-101034 Added by ankit

            if((groupDTO.transitionId==null && groupDTO.checkValue==true)){// nguc transition Issue fix
                for(TransitionDataDTO.serviceDTOMobile serviceDTO:groupDTO.service ){
                  TramasBatchRequestDTO.identifierList identifiers1 = new TramasBatchRequestDTO.identifierList ();
                //  if((groupDTO.transitionId==null && groupDTO.checkValue==true)){// nguc transition Issue fix
                     //system.debug();
                    oprn = new TramasBatchRequestDTO.operationList ();
                    oprn.type= oprTypeCreate;
                    
                    TramasBatchRequestDTO.target trgt= new TramasBatchRequestDTO.target();
                    trgt.type=prdFamily;
                    
                    
                    trnasitionproprty.family =(productList.Product_Type).toLowerCase();
                    //transition block
                    TramasBatchRequestDTO.transitionList transition = new TramasBatchRequestDTO.transitionList();
                    transition.type= 'service';
                    transition.target=trgt;
                    
                    
                    if(transition!=null){// nguc transition Issue fix
                        TramasBatchRequestDTO.opnProperties oprnProperties = new TramasBatchRequestDTO.opnProperties ();
                    oprnProperties.transitions.add(transition);
                    if(oprnProperties!=null){// nguc transition Issue fix
                    oprn.properties=oprnProperties;}}
                    //batchEligibilityReq.operations.add(oprn);
                    //identifiers = new TramasBatchRequestDTO.identifierList();
                    System.debug('groupDTO.groupId '+groupDTO.groupId);
                    if (serviceDTO.serviceExtensions != null && serviceDTO.serviceExtensions.size() > 0) {
                        identifiers = new TramasBatchRequestDTO.identifierList();
                        if(productList.Product_Type != null && transGroupStructHybrid.containsKey(productList.Product_Type) && !transGroupStructHybrid.get(productList.Product_Type)){ //EDGE-101034 Condition Added by ankit
                        identifiers1.identifier = serviceDTO.Service_Id;//EDGE-159089 fix
                        trnasitionproprty.identifiers.add(identifiers1);//EDGE-159089 fix
                        } //EDGE-101034 close if loop
                      for(TransitionDataDTO.serviceExtensionDTO servExt:serviceDTO.serviceExtensions){
                        
                       // identifiers1.identifier = serviceDTO.Service_Id;//Commented for EDGE-159089 fix
                        identifiers = new TramasBatchRequestDTO.identifierList ();
                        
                        identifiers.identifier = servExt.serviceExtensionFrom + '-' + servExt.serviceExtensionTo;  
                        //trnasitionproprty.identifiers.add(identifiers1);  //Commented for EDGE-159089 fix                                                 
                        trnasitionproprty.identifiers.add(identifiers);
                      }                                                   
                      
                    }
                    else {
                        identifiers = new TramasBatchRequestDTO.identifierList();
                       //TramasBatchRequestDTO.identifierList identifiers2 = new TramasBatchRequestDTO.identifierList();
                      identifiers.identifier = serviceDTO.Service_Id;
                      system.debug('ServiceIDDetails'+ identifiers);
                      trnasitionproprty.identifiers.add(identifiers);
                    }
                      system.debug('trnasitionproprtydetails'+serviceDTO.service_association_role);
                   // if (String.valueof(serviceDTO.service_association_role).trim() != '' && serviceDTO.service_association_role != null) {//EDGE-134151 Defect fix
                     if ( serviceDTO.service_association_role != null && String.valueof(serviceDTO.service_association_role).trim() != ''){//EDGE-144767 Defect fix
                      attributes = new TramasBatchRequestDTO.attributesList ();
                      attributes.key= 'role'; 
                      attributes.value =serviceDTO.service_association_role.trim();
                      identifiers.attributes.add(attributes);
                      if(identifiers!=null)
                        identifiers1.attributes.add(attributes);
                    }
                    system.debug('@@@@@@@@@@'+trnasitionproprty);
                    transition.properties=trnasitionproprty;
                    system.debug('#############'+transition.properties);
                    //System.debug('**batchEligibilityReq** '+JSON.serialize(batchEligibilityReq));
                     // mapofbulkrequest.put(pcID,batchEligibilityReq);
                    
                //  }
                  
                }
                if(oprn.type!=null){// nguc transition Issue fix
                    batchEligibilityReq.operations.add(oprn);
                }
            }
          }
          
        }
      }
      //if(oprn.type!=null)
      //batchEligibilityReq.operations.add(oprn);
      
       System.debug('**batchEligibilityReq** '+JSON.serialize(batchEligibilityReq));
        mapofbulkrequest.put(pcID,batchEligibilityReq);
      
    }
           
            if(!mapofbulkrequest.IsEmpty()){
                //String param=prcid+':nguc:'+getCorrelationId();
                System.debug('**mapofbulkrequest** '+JSON.serialize(mapofbulkrequest.get(pcID)));
                String param=pcID+':'+ngucText+':'+getCorrelationId();
                System.debug('param : '+param);
                IntegrationRecordHandlerUtil.createRequests(TramasBatchHandler, new List<String>{param},JSON.serialize(mapofbulkrequest.get(pcID)));                
            }
        }
        catch(Exception e){
            System.debug('***Telstra:TramasBatchEligibilityCheckService:trException:'+e.getMessage());
            System.debug('***Telstra:TramasBatchEligibilityCheckService:trException:'+e.getLineNumber());
            logger2.logMessages('TramasBatchEligibilityCheckService:sendEligibilityCheckRequest',e.getMessage() , '', '', '', '', false, false, null , null, null, null);                     
        }
        finally{
            logger2.exitLogger();
        }
    
       }
    
    
    /*****************************************************************************************************************************
 * Story: EDGE-199057
 * Team : Osaka
 * Developer : Abhishek
 * Description: This method is used for Mobile TM1 call which has been introduced as modular method(can be reused for nguc while code refactoring)
 * 				
 * ************************************************************************************************************************************/
    
    public static void executionTransitionService(Map<id, List<String>> PcIdTransitionIDListMap,String actionType){
        //Start of DIGI-33080 by Abhishek(Osaka) to enable Elibility for IoT
        String prodSpecIoT = 'IoT_Dormancy_False';
        String product_family = 'mobile';
        String IoTFamilyName = '';
        //DIGI-33080 : Dormancy added as a part by Abhishek(Osaka)
        if(IoT_Dormancy == 'true'){
            prodSpecIoT = String.valueOf(MTMMetadataUtilityMap.get('IoT_Marketable_Offer').get('Value__c'));
            IoTFamilyName = String.valueOf(MTMMetadataUtilityMap.get('family_iot').get('Value__c'));
            List<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
            prodConfigList = [SELECT id , name ,cscfga__Product_Definition__r.product_Specification__c FROM cscfga__Product_Configuration__c WHERE Id in :PcIdTransitionIDListMap.keySet()];
            if(prodConfigList!= Null && prodConfigList.size()>0){
                for(cscfga__Product_Configuration__c prodRec : prodConfigList){
                    if(prodRec.cscfga__Product_Definition__r.product_Specification__c == prodSpecIoT){
                        product_family = IoTFamilyName;
                    }
                }
            }
        }
        //End of DIGI-33080
        
        //Start of DIGI-33080 Modified existing method signature to include IoT
        MobileTramasElgibility__c mobileTramasRec = createMobileTramasRec(PcIdTransitionIDListMap,actionType,product_family);
        
        //callback response will be updated in success scenarios from tramas
        Attachment mobileTramAttachment = createMobileTramAttachment(mobileTramasRec,product_family);
        //End of DIGI-33080
        
        if(actionType==validateOperation){
            cscfga__Product_Basket__c bsktRecord= new cscfga__Product_Basket__c();
            bsktRecord.id=mobileTramasRec.Product_Basket__c;
            bsktRecord.isEligibilityTriggered__c=false;
            //bsktRecord.Transition_basket_stage__c=System.Label.CheckEligibilityTriggered; //custom label EDGE-198380 commented
            bsktRecord.isEligibilityCheckComplete__c=false;
            update bsktRecord;
        }
        map<String,Attachment> tmreqwithAttachMap= new map<String,Attachment>();
        tmreqwithAttachMap.put(mobileTramasRec.TranasactionId__c,mobileTramAttachment);
        
        map<String,TramasExecutionRequestDTO> mapOftramasExecutionRequest= new map<String,TramasExecutionRequestDTO>();
        system.debug('tmreqwithAttachMapvalue'+tmreqwithAttachMap);
        for(String tramasrecodid:tmreqwithAttachMap.keyset()){
            TramasExecutionRequestDTO trmExReq= new TramasExecutionRequestDTO();
            trmExReq.transitionId=tramasrecodid;
            trmExReq.mode=null;
            if(actionType==validateOperation){
                trmExReq.action=validateOperation;
            }
            //Product agnostic TM1 request generation
            TramasExecutionRequestDTO.mtd mt= new TramasExecutionRequestDTO.mtd();
            String sfdcid=tmreqwithAttachMap.get(tramasrecodid).id;  //attachmentId 
            system.debug('sfdcid'+sfdcid);
            mt.salesforceId=sfdcid;
            trmExReq.metadata=mt;
            //system.debug('trmExReq'+trmExReq);
            system.debug('trmExReq'+JSON.serialize(trmExReq));
            mapOftramasExecutionRequest.put(tramasrecodid,trmExReq);
        }
        system.debug('mapOftramasExecutionRequest'+mapOftramasExecutionRequest);
        List<String> paramList= new List<String>();
        map<String,TramasExecutionRequestDTO> requestWithbodyMap= new map<String,TramasExecutionRequestDTO>();
        for(String requestDTO:mapOftramasExecutionRequest.keySet()){
            String paramValue= requestDTO+getCorrelationId();
            paramList.add(paramValue);  
            requestWithbodyMap.put(paramValue,mapOftramasExecutionRequest.get(requestDTO));         
        }
        //Request Structure : {"transitionId":"c79f75ec-d2b9-4405-87b3-837d373b7e08","resourceIds":[],"mode":null,"metadata":{"salesforceId":"00P2N000002xi7pUAA"},"action":"validate"}
        //TM1 and TM2 have a same logger name
        String handlerName='TM2TramasExecution';
        List<Integration_Record__c> existingRequests = [SELECT Id, params__c 
                                                        FROM Integration_Record__c 
                                                        WHERE params__c IN :CollectionUtil.removeNull(paramList)
                                                        AND handler__c = :handlerName 
                                                        AND (Status__c = :IntegrationQueueHandler.PENDING OR Status__c = :IntegrationQueueHandler.IN_PROGRESS)];
        for(String paramloop:paramList){
            //placing the TM1 request - Single request for Mobile
            IntegrationRecordHandlerUtil.createRequestsForTramas('TM2TramasExecution', new List<String>{paramloop},JSON.serialize(requestWithbodyMap.get(paramloop)),existingRequests); 
        }
    }
    
     /*****************************************************************************************************************************
 * Story: EDGE-199057
 * Team : Osaka
 * Developer : Abhishek
 * Description: This method is used to created MobileTramasEligibility record with Type TM1 for recording callback response for a TM1 call.
 * 				For Mobility actionType will only be Validate.
 * ************************************************************************************************************************************/							
public static MobileTramasElgibility__c createMobileTramasRec(Map<id, List<String>> PcIdTransitionIDListMap,String actionType, String product_family){          
        String tramasRecName = '';
        String IoTFamilyName = '';
        //DIGI-33080 : Dormancy added as a part by Abhishek(Osaka)
        if(IoT_Dormancy == 'true'){
            tramasRecName = String.valueOf(MTMMetadataUtilityMap.get('TramasRecName_IoT').get('Value__c'));
            IoTFamilyName = String.valueOf(MTMMetadataUtilityMap.get('family_iot').get('Value__c'));
        
        }
        //List<MobileTramasElgibility__c> trmreqlist= new List<MobileTramasElgibility__c>();
        
        //This record will be applicable for mobility alone.(callback response)
        MobileTramasElgibility__c mobileTramasRec = new MobileTramasElgibility__c();
        cscfga__Product_Configuration__c productConfig = [select id,cscfga__Product_Basket__c
                                                          from cscfga__Product_Configuration__c where id=:PcIdTransitionIDListMap.keyset()];
        
        //Creating MobileTramasElgibility__c record 
        //DIGI-33080 : Dormancy added as a part by Abhishek(Osaka)
        if(IoT_Dormancy == 'true'){
            //DIGI-33080 Re-using Mobile logic for IoT by Abhishek(Osaka)
            mobileTramasRec.Name = (product_family == IoTFamilyName) ? tramasRecName : System.Label.MobileTramasRecName;  //custom Label
        }
        else{
            mobileTramasRec.Name = System.Label.MobileTramasRecName;  //custom Label
        }
        mobileTramasRec.Product_Configuration__c = productConfig.Id;
        mobileTramasRec.Product_Basket__c = productConfig.cscfga__Product_Basket__c;
        mobileTramasRec.Correlation_ID__c = string.valueof(getCorrelationId());
        mobileTramasRec.TranasactionId__c = PcIdTransitionIDListMap.get(productConfig.Id)[0];
        if(actionType==validateOperation){
            mobileTramasRec.Type__c = 'TM1';
        }
        insert mobileTramasRec;
        
        return mobileTramasRec;
    }
    /*****************************************************************************************************************************
 * Story: EDGE-199057
 * Team : Osaka
 * Developer : Abhishek
 * Description: This method is used to create an empty attachment with MobileTramasEligibility(created in the above method) as parent.
 * 				Callback response will be updated in this attachment in case of success scenarios.
 * ************************************************************************************************************************************/
    
public static Attachment createMobileTramAttachment(MobileTramasElgibility__c mobileTramasRec,String product_family){
        String tramasAttName = '';
        String IoTFamilyName = '';
        //DIGI-33080 : Dormancy added as a part by Abhishek(Osaka)
        if(IoT_Dormancy == 'true'){
            tramasAttName = String.valueOf(MTMMetadataUtilityMap.get('IotTramasAttName').get('Value__c'));
            IoTFamilyName = String.valueOf(MTMMetadataUtilityMap.get('family_iot').get('Value__c'));
        }
        Attachment attachmentRec = new Attachment();
        //DIGI-33080 : Dormancy added as a part by Abhishek(Osaka)
        if(IoT_Dormancy == 'true'){
            //DIGI-33080 Re-using Mobile logic for IoT by Abhishek(Osaka)
            attachmentRec.Name =  (product_family == IoTFamilyName) ? tramasAttName : System.Label.MobileTramasAttName; //custom Label
        }
        else{
            attachmentRec.Name =  System.Label.MobileTramasAttName; //custom Label
        }
        attachmentRec.ParentId = mobileTramasRec.Id;
        attachmentRec.Body = blob.valueof('');
        insert attachmentRec;
        
        return attachmentRec;
    }
}