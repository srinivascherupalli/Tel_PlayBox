/*
* @Author : Robin/Ritika
* @Date : 5 June 2019
* @Desc : Service class for requesting an eligibity-check to Tramas-TM1 (for Mobile Transition)
* @Jira Cloud : EDGE-85155/EDGE-85154
*/


public with sharing class TM1EligibilityCheckServiceV2 {
    
    //List of legacy-products related to site - for which the below logic should not be called
    public static final List<String> siteProduct=new List<String>{'PSTN','ISDN2','ISDN2DID'};
    
    //Start of DIGI-33080 by Abhishek(Osaka) to introduce IoT for Check Eligiblity
    public static Map<string,Sobject> MTMMetadataUtilityMap = ConstantMetadataUtility.getConstantMetadataUtilityRecords('MTM_Metadata_Utility__mdt');
    public static String IoT_Dormancy = String.valueOf(MTMMetadataUtilityMap.get('IoT_Dormancy').get('Value__c'));
    
    //End of DIGI-33080
    
    /*Purpose : Method to createRequest using IntegrationRecord(from Integration-handler framework)
     * Parameters : mobileTransitionDTO - JSON-string from TransitionJSONData.json(for Mobile-services) , 
     * basketid - record-id of basket which initiated the request
     */
    public static void tramasEligibilityRequestMethod(string mobileTransitionDTO, string pcId){            
            
            
            TransitionDataDTO transitionDTO=TransitionDataDTO.parse(mobileTransitionDTO);
            String cidn=transitionDTO.CIDN;
              List<String> serviceIdList=new List<String>();          
              Set<String> CIDNList = new Set<String>();
              Set<String> sourceCIDNList = new Set<String>();              
              Map<String,String> serviceToCIDN = new Map<String, String>();
            List<TransitionDataDTO.SiteDTOMobile> siteMobileList=new list<TransitionDataDTO.SiteDTOMobile>();
            for(TransitionDataDTO.productListDTO productList:transitionDTO.productList){
                System.debug('***Telstra:TM1EligibilityCheckServiceV2:productList'+ productList);
               // if(productList.checkValue==true && !siteProduct.contains(productList.Product_Type) ){
                   if(!siteProduct.contains(productList.Product_Type)){
                    for(TransitionDataDTO.SiteDTOMobile siteDTO:productList.site ){
                        for(TransitionDataDTO.serviceListDTOMobile serviceListDTO:siteDTO.serviceList ){
                            for(TransitionDataDTO.groupDTOMobile groupDTO:serviceListDTO.groupType ){
                                for(TransitionDataDTO.serviceDTOMobile serviceDTO:groupDTO.service ){
                                    //if((groupDTO.transitionId==null && serviceListDTO.checkValue==true)||(groupDTO.transitionId!=null &&serviceListDTO.checkValue!=true)){
                                    if(serviceListDTO.checkValue==true){//EDGE-147106/INC000092792205 Fix
                                    serviceIdList.add(serviceDTO.Service_Id);
                                        //START OF EDGE-198198: Fetching source CIDN:Osaka:Ramya

										if(serviceDTO!=null && serviceDTO.accountDetails!=null){

                                        TransitionDataDTO.accountDTO accountDTObj =serviceDTO.accountDetails;
                                        if(accountDTObj.sourceCIDN != null) {
                                            serviceToCIDN.put(serviceDTO.Service_Id,accountDTObj.sourceCIDN);
                                            sourceCIDNList.add(accountDTObj.sourceCIDN);
                                        }

										}

                                        //END OF EDGE-198198: Fetching source CIDN:Osaka:Ramya
                                    }
                                }
                            }
                            
                        }
                    }
                            
                    //siteMobileList.addAll(productList.site);
                    System.debug('***Telstra:TM1EligibilityCheckServiceV2:productList'+ productList.site);
                }
                
            }
            system.debug('serviceIdList000000000000000'+serviceIdList);
            ////EDGE-198198: Added arguments for sourceCIDN and its association with service for TM0 enhancement:Osaka:Ramya
            if(serviceIdList.size()>0)
            createTransitionRequest(serviceIdList,cidn,pcId,sourceCIDNList,serviceToCIDN);
  
        
        
    }
/*************************************************************************************************
EDGE-198198
Name:createTransitionRequest
Description: Overriding an existing method

***************************************************************************************************/
    
    public static void createTransitionRequest(List<String> serviceIdList,string cidn,String pcId){
        Set<String>sourceCIDNList;
        Map<String,String> serviceToCIDN;
        createTransitionRequest(serviceIdList,cidn,pcId,sourceCIDNList,serviceToCIDN);
    }
/*************************************************************************************************
EDGE-198198
Name:createTransitionRequest
Description: Adding additional arguments for CIDN hierarchy
Modified by:Ramya G 
***************************************************************************************************/
    //From the list of Mobile-service-ids, create TM1TransitionRequest
    Public static void createTransitionRequest(List<String> serviceIdList,string cidn,String pcId, Set<String> sourceCIDNList,Map<String,String> serviceToCIDN){                 
        MobileTransitionTM1DTO mobile=new  MobileTransitionTM1DTO();
        
         //Start of DIGI-33080 by Abhishek(Osaka) to enable Check Eligibility for IoT
         String IoTFamilyName = '';
         String mobileFamilyName = '';
         String prodSpecIoT = '';
         String target_IoT = '';
         String product_family = 'mobile';
             if(IoT_Dormancy == 'true'){
                 IoTFamilyName = String.valueOf(MTMMetadataUtilityMap.get('family_iot').get('Value__c'));
                 mobileFamilyName = String.valueOf(MTMMetadataUtilityMap.get('family_mobile').get('Value__c'));
                 prodSpecIoT = String.valueOf(MTMMetadataUtilityMap.get('IoT_Marketable_Offer').get('Value__c'));
                 target_IoT = String.valueOf(MTMMetadataUtilityMap.get('target_type_iot').get('Value__c'));
                 
                 List<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
                 prodConfigList = [SELECT id , name ,cscfga__Product_Definition__r.product_Specification__c FROM cscfga__Product_Configuration__c WHERE Id = :pcId];
                 if(prodConfigList!= Null && prodConfigList.size()>0){
                     for(cscfga__Product_Configuration__c prodRec : prodConfigList){
                         if(prodRec.cscfga__Product_Definition__r.product_Specification__c == prodSpecIoT){
                             product_family = IoTFamilyName;
                         }
                     }
                 }
             }
         
         
         //End of DIGI-33080
        //For every service-id in the list, add Transition(containing attribute,property,target) in the request
        for(String serviceId:serviceIdList){             
            //adding attribute
            MobileTransitionTM1DTO.attributesDTO attribute=new MobileTransitionTM1DTO.attributesDTO();
            //START OF EDGE-198198: Renamed attribute key and mapped source CIDN in case of CIDN hierarchy:Osaka:Ramya
            //attribute.key='accountNumber';
            //attribute.value=cidn;
       
            attribute.key='customerIdentifier';
                if(sourceCIDNList.size()>1 || (serviceToCIDN.get(serviceId)!=null && serviceToCIDN.get(serviceId)!=cidn)) {
                    attribute.value=serviceToCIDN.get(serviceId);
                    system.debug('attribute.value for source CIDN is: ' +attribute.value);
                } else {
            attribute.value=cidn;
                    system.debug('attribute.value for target CIDN is: ' +attribute.value);
                }
            //END OF EDGE-198198: Renamed attribute key and mapped source CIDN in case of CIDN hierarchy:Osaka:Ramya
            //adding property
            MobileTransitionTM1DTO.PropertiesDTO properties=new MobileTransitionTM1DTO.PropertiesDTO();
            properties.identifier=serviceId; 
            //Start of DIGI-33080 by Abhishek(Osaka) to enable Check Eligibility for IoT
            if(IoT_Dormancy == 'true'){
                properties.family=(product_family == IoTFamilyName) ? IoTFamilyName : mobileFamilyName;
            }
            else{
                properties.family = 'mobile';
            }
            
            //End of DIGI-33080 
            
            properties.attributes.add(attribute);           
            
            //creating target
            MobileTransitionTM1DTO.TargetDTO target=new MobileTransitionTM1DTO.TargetDTO();
            //Start of DIGI-33080 by Abhishek(Osaka) to enable Check Eligibility for IoT
            if(IoT_Dormancy == 'true'){
                target.type=(product_family == IoTFamilyName) ? target_IoT : system.label.target_type;//'port-out';//DIGI-33080 Modifying request structure to re-use mobile logic for IoT enablement
            }
            else{
                target.type=system.label.target_type;//'port-out';
            }
             //End of DIGI-33080
            
            MobileTransitionTM1DTO.transitionsDTO transition=new  MobileTransitionTM1DTO.transitionsDTO();
            transition.type='service';
            transition.properties=properties;
            transition.target=target;
            mobile.transitions.add(transition);
            
        }
        String requestToSend=JSON.serialize(mobile);
        System.debug('***Telstra:TM1EligibilityCheckService:requestFormed:'+requestToSend);
        List<String> corrlationIdList=new List<String>{getCorrelationId()+':'+pcId};
        System.debug('***size'+corrlationIdList.size());
        IntegrationRecordHandlerUtil.createRequests('TM1EligibilityCheckHandlerV2',corrlationIdList,requestToSend); 
       
        
    }
    
    //Callout method which is invoked by Integration-Handler Framework
    @future(callout=true)
    public static void sendEligibilityCheckRequest(String param) {
        //Start of DIGI-33080 by Abhishek(Osaka)
        String IoTJsonName = 'IoT_Dormancy_False';
        if(IoT_Dormancy == 'true'){
            IoTJsonName = String.valueOf(MTMMetadataUtilityMap.get('IoTTransitionName').get('Value__c'));
        }
        //End of DIGI-33080
        // START of EDGE-199057 by Abhishek from Osaka Team
        
        String validateOperation = 'validate';
        List<String> transactionIdList = new List<String>();
        Map<id, List<String>> PcIdTransitionIDListMap = new Map<id, List<String>>();
        
        //END of EDGE-199057 by Abhishek from Osaka Team
        String handlerName = 'TM1EligibilityCheckHandlerV2';
        Logger2 logger2 = Logger2.getLogger(handlerName);
        System.debug('***Telstra:TM1EligibilityCheckServiceV2:sendEligibilityCheckRequest:'+param);
            try{       
            String responseBody=TramasCallout(param,handlerName);
            system.debug('valueofResponse'+responseBody);
            String[] params=param.split(':'); 
            // START of EDGE-188064
            String productConfigId = params[1];   //EDGE-188064 
                
            Map<String, object> responseValues = (Map<String, object>)JSON.deserializeUntyped(responseBody);
            
            String transactionId=responseValues.get('transitionId').toString();
            System.debug('***Telstra:TM1EligibilityCheckServiceV2:transaction id'+transactionId+' -params:'+params);   
            String correlationId=getCorrelationId();
            //Transition-ID is recorded in TramasElgibilityCallbackResponse__c for future use
            if(params.size()>=2){
                System.debug('params:'+param);
            }
            map<String,String> attachmentMap= new map<String,String>();
            //Osaka:  updated from String to Blob
            map<String,blob> attachmentUpdateMap= new map<String,blob>();
            //DIGI-33080 : Modified OR condition to reuse this method to update json file for IoT by Abhishek(Osaka)
            for(Attachment attch:[Select id,ParentId,body from Attachment where Parentid=:params[1] and (Name=:system.label.MobileTransitionName OR Name=:IoTJsonName)])//This Code has written the Transistion Json that attached under Mobile PC.
            {
                attachmentMap.put(attch.id,attch.body.toString());
            }
            //This For loop has writtern to update the Transition Json
            for(String attid:attachmentMap.keyset()){
                Map<String, Object> meta = (Map<String, Object>) JSON.deserializeUntyped(attachmentMap.get(attid));
                List<Object> prdlst =(List<Object>)meta.get('productList');
                system.debug('ProductList'+prdlst );
                    for(object prd:prdlst){
                       Map<String, Object> sites=(Map<String, Object>)prd;
                       List<Object> sitelst = (List<Object>)sites.get('site');
                       system.debug('Sites'+sitelst );
                           for(Object serv:sitelst){
                               Map<String, Object> services=(Map<String, Object>)serv;
                               List<object> servlst= (List<Object>)services.get('serviceList');
                               system.debug('servlst'+servlst );
                               for(Object grp:servlst){
                                 Map<String, Object> grps=(Map<String, Object>)grp;
                                 List<object> grplst=(List<Object>)grps.get('groupType');
                                 system.debug('grplst'+grplst );
                                 for(Object gp:grplst){
                                   Map<String, Object> grpmap=(Map<String, Object>)gp;
                                    for (String attributeName : grpmap.keyset()) {
                                       if(attributeName=='transitionId'){ 
                                          //if(((grpmap.get('transitionId')==null)&& grps.get('checkValue')==true)||(grpmap.get('transitionId')!=null && grps.get('checkValue')!=true)){
                                          if(grps.get('checkValue')==true){//EDGE-147106/INC000092792205 Fix
                                            system.debug('SomeTHing');
                                            grpmap.put('transitionId',transactionId);
                                          }
                                    }
                                 }
                               }
                           }
                    }
                }
                system.debug('valueofUpdatedJSON'+blob.valueof(JSON.serializePretty(meta)));
                //Osaka update to blob from string
                attachmentUpdateMap.put(attid,blob.valueof(JSON.serializePretty(meta)));
                system.debug('attachmentUpdateMap.size' + attachmentUpdateMap.size());
                system.debug('JSON update' +blob.valueof(JSON.serializePretty(meta)));
                system.debug('#attachmentUpdateMap.get  #ID:' +attid+ '#Map');
            }
             List<Attachment> listAttachment = new List<Attachment>();
            List<attachment> dltlist= new List<attachment>();
            if(attachmentUpdateMap.size()>0){
                for(attachment attloop:[Select id,Parentid,body from attachment where id in:attachmentUpdateMap.keyset()]){
                
                Attachment att = new Attachment();
                att.Name =  system.label.MobileTransitionName;
                att.ParentId = attloop.Parentid;
                //att.Body = blob.valueof(attachmentUpdateMap.get(attloop.id));
                //Osaka Update
                att.Body = attachmentUpdateMap.get(attloop.id);
                listAttachment.add(att);
                dltlist.add(attloop);
               // attachmentPCR.put(attloop.Parentid, attloop.id);
            }
            if(listAttachment.size()>0)
                delete dltlist;
            insert listAttachment;
                // START of EDGE-199057 by Abhishek from Osaka Team
                //No condition added specifically for Mobile Products as sendEligibilityCheckRequest is only called for Mobile products.
                transactionIdList.add(transactionId);
                PcIdTransitionIDListMap.put(productConfigId, transactionIdList);
                if(!transactionIdList.isEmpty()){
                    TramasBatchEligibilityCheckService.executionTransitionService(PcIdTransitionIDListMap,validateOperation);
                }
                // END of EDGE-199057 by Abhishek from Osaka Team
            }
        }
        catch(Exception e){
            System.debug('***Telstra:TM1EligibilityCheckServiceV2:trException:'+e.getMessage() +e.getStackTraceString());
            
        }
        finally{
            logger2.exitLogger();
        }
        
    }
    
    //Method fr forming the httpRequest, and processing the response
    public static String TramasCallout(String param,String handlerName){
        Logger2 logger2 = Logger2.getLogger(handlerName);
       try{            
            //Get the request details from Integration-record
            List<Integration_Record__c> paramRequest = [SELECT Id, params__c, paramPayload__c
                                                  FROM Integration_Record__c
                                                  WHERE params__c = :param order by CreatedDate desc LIMIT 1 ];
            Map<String,String> headerMap = new Map<String, String>(); 
           	String token = AuthenticationManager.getOauthToken(TM1EligibilityCheckHandlerV2.class.getName());
            //String token ='tGzv3JOkF0XG5Qx2TlKWIA';
                headerMap = new Map<String, String>{'Content-Type' => 'application/json',
                                                               'Authorization'=> 'Bearer '+token,'Correlation-Id'=>getCorrelationId()};           
                              
            
            if(!paramRequest.isEmpty()){
                
                 
                  String requestDtoJson = paramRequest[0].paramPayload__c;
                  System.debug('***Telstra:TM1EligibilityCheckServiceV2:Telstra:requestDtoJson:' + requestDtoJson );          
                  //Callout to TRAMAS
                  HTTPResponse response = IntegrationRecordHandlerUtil.callout(requestDtoJson,
                                                                         IntegrationRecordHandlerUtil.HTTP_METHOD_POST,
                                                                         headerMap, handlerName, new List<String>{param},null);
            
                  System.debug('***Telstra:TM1EligibilityCheckServiceV2:sendEligibilityCheckRequest:Response:'+response);
                  //Adding the request-response in Application-logs
                  if(response!= null && response.getStatusCode() == IntegrationRecordHandlerUtil.HTTP_CREATED) { //Request was successfully accepted
                  logger2.logMessages(requestDtoJson, response.getBody(), '', '', '', '', false, false, Integer.valueOf(response.getStatusCode()) , null, null, null);
                  return response.getBody();
                } 
                else{
                    
                 logger2.logMessages(requestDtoJson, response.getBody(), '', '', '', '', false, false, Integer.valueOf(response.getStatusCode()) , null, null, null);
				 String[] params=param.split(':');
                 system.debug('params**' +params);
                      //EDGE-198380
                MobileTramasElgibility__c tramasMobile=new MobileTramasElgibility__c();
                tramasMobile.Name = System.Label.MobileTramasRecName; 
                tramasMobile.Type__c='TM0 Execution Error';
                tramasMobile.Correlation_ID__c = string.valueof(getCorrelationId());
                tramasMobile.Product_Configuration__c = params[1];
                insert tramasMobile;
                    
                }
             }
            
            
            return null;                       
       }
        catch(Exception e){
            System.debug('***Telstra:TM1EligibilityCheckServiceV2:trException:'+e.getMessage());
            logger2.logMessages('TM1EligibilityCheckServiceV2:TramasCallout:Exception:'+handlerName,e.getMessage() , '', '', '', '', false, false, null , null, null, null);                     
            return null;
        }
        finally{
            logger2.exitLogger();
        }
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
    
}