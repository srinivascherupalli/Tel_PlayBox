public class NumberReservationTM2CallOut {  
    public static map<string,Sobject> customMetadataNameValueMap=ConstantMetadataUtility.getConstantMetadataUtilityRecords('ConstantMetadataUtility__mdt');//EDGE-206365-Dheeraj Bhatt- Get the constant value from metadata
    public static List<TransitionResponseCodes__c> responseCodeList = ConstantMetadataUtility.getTransitionResponse(); //Moved SOQL to constantMetadataUtility, as part of production incident Fix
    
    /*************************************************************************************************
Name        : getStatusAndReason
Description : get status and reason related to the TRAMAS error code.
Author      : Kalashree Borgaonkar
Story       : EDGE-202851
***************************************************************************************************/   
    public static Map<String,ErrorWrapper> getStatusAndReason(){
        
        Map<String,ErrorWrapper> errorCodetoStausMap= new Map<String,ErrorWrapper>();
        for(TransitionResponseCodes__c responseCode : responseCodeList){
            ErrorWrapper wrap = new ErrorWrapper();
            wrap.status = responseCode.Status__c;
            wrap.reason = responseCode.Reason__c;
            wrap.toastMessage = responseCode.Toast_Message__c;
            errorCodetoStausMap.put(responseCode.TRAMAS_Code__c,wrap);
        }
        return errorCodetoStausMap; 
    }
    //wrapper for error response
    public class ErrorWrapper{
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String reason;
        @AuraEnabled
        public String tramasErrorcode;
        @AuraEnabled
        public String toastMessage;
        @AuraEnabled
        public String executiontype;
        
    }
    public class NgucErrorWrapper{
        public DateTime createdDate;
        public String errorCode; 
        public String id;      
    }
    /*************************************************************************************************
Name        : fetchEligibleProdConfig
Description : method to filter eligible PC Id's and basket.
Author      : Veena Putta
Story       : EDGE-195766
***************************************************************************************************/ 
    public void fetchEligibleProdConfig(String basketid){ 
        
        String productSpecMobile = Label.ProductSpecificationMobile;
        List<String> listproductSpecMobile = productSpecMobile.split(',');
        Map<Id,Id> attachmentPC_Map = new Map<Id,Id>();
        try{
            if(String.isNotEmpty(basketid)){ 
                fetchReserveProdConfig(basketid);
                
                Map<Id,Id> PCBasketIdMap = new Map<Id,Id>();
                
                //fetching product config & attachment
                List<cscfga__Product_Configuration__c> pcAttachmentList =  [SELECT Id, cscfga__Product_Basket__c,cscfga__Product_Definition__r.product_Specification__c,(SELECT Id,Name,ParentId FROM Attachments WHERE Name = :Label.MobileTransitionName ORDER BY CreatedDate Limit 1)
                                                                            FROM cscfga__Product_Configuration__c 
                                                                            WHERE cscfga__Product_Basket__c   =:basketid AND cscfga__Product_Definition__r.product_Specification__c IN: listproductSpecMobile ];
                
                System.debug('pcAttachmentList----->>>>>>>> '+pcAttachmentList);
                for(cscfga__Product_Configuration__c prCon : pcAttachmentList){
                    PCBasketIdMap.put(prCon.Id,prCon.cscfga__Product_Basket__c);
                    if(!prCon.Attachments.IsEmpty()){
                        for(Attachment att : prCon.Attachments){
                            attachmentPC_Map.put(att.Id,att.ParentId);
                        }
                    }
                }
                
                System.debug('attachmentPC_Map ------>>>>>>>>:'+attachmentPC_Map);
                //Creating MobileTramasElgibility__c record 
                if(!attachmentPC_Map.isEmpty()){                    
                    List<MobileTramasElgibility__c> MobileTramasElgibilityList = new List<MobileTramasElgibility__c>();
                    List<Attachment> newAttList = new List<Attachment>();
                    
                    for(Id attId : attachmentPC_Map.KeySet()){
                        MobileTramasElgibility__c mt = new MobileTramasElgibility__c();
                        mt.Name = 'MobileTramasElgibility';
                        mt.Product_Configuration__c = attachmentPC_Map.get(attId);
                        mt.Product_Basket__c = PCBasketIdMap.get(attachmentPC_Map.get(attId));
                        mt.Type__c = 'TM2';
                        MobileTramasElgibilityList.add(mt);
                    }
                    
                    //Creating attachment record with parent MobileTramasElgibility__c
                    if(!MobileTramasElgibilityList.IsEmpty()){
                        insert MobileTramasElgibilityList;
                        for(MobileTramasElgibility__c mt : MobileTramasElgibilityList){
                            Attachment att = new Attachment();
                            att.Name =  'MobileTramasElgibility.json';
                            att.ParentId = mt.Id;
                            att.Body = blob.valueof('');
                            newAttList.add(att);
                        }
                        if(!newAttList.IsEmpty()){
                            insert newAttList;
                        }                       
                    }
                    
                    //Async web callout : TM2 Tramase Execution
                    TM2WebCalloutAsync(attachmentPC_Map,PCBasketIdMap,basketid); 
                }           
            }           
        }catch(Exception e) {
            System.debug('error Caught :: '+e.getMessage());
        }       
    }
    
    /*************************************************************************************************
Name        : fetchReserveProdConfig
Description : create MobileTramasElgibility__c and attachment record.
Author      : Veena Putta
Story       : EDGE-195766
***************************************************************************************************/    
    public static void fetchReserveProdConfig(String basketid){
        String productSpecMobile = Label.ProductSpecificationMobile;
        //List<String> listproductSpecMobile = productSpecMobile.split(',');
        List<String> listproductSpecCwp= (Label.Product_Specification_for_Cwp).split(',');
        List<String> listproductSpecNguc=(Label.ProductSpecificationNgUc).split(',');
        if(String.isNotEmpty(basketid)){
            
            List<cscfga__Product_Configuration__c>pcAttachmentList =  [SELECT Id,name, cscfga__Product_Basket__c,cscfga__Product_Definition__r.product_Specification__c,(SELECT Id,Name,ParentId FROM Attachments WHERE Name like 'Transition%')
                                                                       FROM cscfga__Product_Configuration__c 
                                                                       WHERE cscfga__Product_Basket__c   =:basketid AND (cscfga__Product_Definition__r.product_Specification__c IN:listproductSpecNguc OR cscfga__Product_Definition__r.product_Specification__c IN:listproductSpecCwp)];
            system.debug('pcAttachmentList '+pcAttachmentList );
            set<id> attachmentidSetforcwp= new set<id>();
            set<id> attachmentidSetfornguc= new set<id>();
            for(cscfga__Product_Configuration__c prCon : pcAttachmentList){
                System.debug('listproductSpecCwp :'+listproductSpecCwp);
                if(listproductSpecCwp.contains(prCon.cscfga__Product_Definition__r.product_Specification__c) && prCon.name=='IP Site'){
                    system.debug('pciid :'+prCon.id+' prCon.Name : '+prCon.name);
                    if(!prCon.Attachments.IsEmpty()){
                        for(Attachment att : prCon.Attachments){
                            attachmentidSetforcwp.add(att.Id);
                        }
                    }
                }
                if(listproductSpecNguc.contains(prCon.cscfga__Product_Definition__r.product_Specification__c)){
                    if(!prCon.Attachments.IsEmpty()){
                        for(Attachment att : prCon.Attachments){
                            attachmentidSetfornguc.add(att.Id);
                        }
                    }
                }
            }
            
            system.debug('attachmentidSetforcwpdebug'+attachmentidSetforcwp);
            system.debug('attachmentidSetforngucdebug'+attachmentidSetfornguc);
            Map<id, List<String>> secondMap = new Map<id, List<String>>(); 
            if(attachmentidSetforcwp.size()>0){
                for(Attachment attloop:[select id,name,parentid,body,description from attachment where id in:attachmentidSetforcwp]){
                    ReplicatorGetServiceDataObject_V2 serviceObjDTO = ReplicatorGetServiceDataObject_V2.parse(attloop.body.toString());
                    for(ReplicatorGetServiceDataObject_V2.SiteDTO_V2 siteObj : serviceObjDTO.site){
                        for(ReplicatorGetServiceDataObject_V2.productListDTO product: siteObj.productList){
                            for(ReplicatorGetServiceDataObject_V2.serviceListDTO serlis:product.serviceList ){
                                if(!secondMap.containsKey(attloop.parentid)){
                                    secondMap.put(attloop.parentid, new List<String>{serlis.transitionId});
                                }else{
                                    secondMap.get(attloop.parentid).add(serlis.transitionId);
                                }                                   
                            }
                        }
                    }
                }
                
            }
            if(attachmentidSetfornguc.size()>0){
                for(Attachment attloop:[select id,name,parentid,body,description from attachment where id in:attachmentidSetfornguc]){
                    TransitionDataDTO transitionDTO=TransitionDataDTO.parse(attloop.body.toString());
                    for(TransitionDataDTO.productListDTO productList:transitionDTO.productList){
                        for(TransitionDataDTO.SiteDTOMobile siteDTO:productList.site ){
                            for(TransitionDataDTO.serviceListDTOMobile serviceListDTO:siteDTO.serviceList ){
                                for(TransitionDataDTO.groupDTOMobile groupDTO:serviceListDTO.groupType ){
                                    if(groupDTO.checkValue==true){
                                        if(!secondMap.containsKey(attloop.parentid)){
                                            secondMap.put(attloop.parentid, new List<String>{groupDTO.transitionId});
                                        }else{
                                            secondMap.get(attloop.parentid).add(groupDTO.transitionId);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if(secondMap.size()>0)
                TramasBatchEligibilityCheckService.executionTransition(secondMap,'reserve');
        }
    } 
    
    /*************************************************************************************************
Name        : TM2WebCalloutAsync
Description : API callout method : TM2 tramas Execution
Story       : EDGE-195766
***************************************************************************************************/
    @future(callout=true)
    public Static void TM2WebCalloutAsync(Map<Id,Id> attachmentPC_Map, Map<Id,Id> PCBasketMap, String basketRecid){
        final String TM2TramasExecutionOath = 'TM2TramasExecution';
        Logger2 logger2 = Logger2.getLogger(TM2TramasExecutionOath);
        List<Attachment> attachments=[SELECT id,body,ParentId FROM Attachment WHERE ID IN :attachmentPC_Map.KeySet()];
        System.debug('attachmentss: '+attachments);
        
        Map<Id,MobileTramasElgibility__c> mbTramtoUpdateMap = new Map<Id,MobileTramasElgibility__c>();
        List<MobileTramasElgibility__c> mbTramUpdateList = new List<MobileTramasElgibility__c>();
        
        cscfga__Product_Basket__c prodBasket = [Select id , isEligibilityCheckComplete__c , isEligibilityTriggered__c,Transition_basket_stage__c from cscfga__Product_Basket__c where id = : basketRecid ];                        
        //prodBasket.Transition_basket_stage__c = 'Reservation Triggered';
        List<MobileTramasElgibility__c> mbTramList = [SELECT Id,Product_Configuration__c,ResponsePayload__c,(SELECT Id,Name FROM Attachments WHERE Name = 'MobileTramasElgibility.json' ORDER BY CreatedDate Limit 1) FROM MobileTramasElgibility__c WHERE Product_Configuration__c in : PCBasketMap.KeySet() AND Type__c = 'TM2' ];
        Map<Id,Id> mobTramAttachMap = new Map<Id,Id>();
        if(!mbTramList.IsEmpty()){
            for(MobileTramasElgibility__c mRec : mbTramList){
                mbTramtoUpdateMap.put(mRec.Product_Configuration__c,mRec);
                if(!mRec.Attachments.IsEmpty()){
                    for(Attachment att : mRec.Attachments){
                        mobTramAttachMap.put(mRec.Product_Configuration__c,att.id);
                    }
                }
            }
        } 
        System.debug('mobTramAttachMap **'+mobTramAttachMap);
        System.debug('mbTramtoUpdateMap **'+mbTramtoUpdateMap);
        //Fetching Token:
        String token;
        try{
            token = AuthenticationManager.getOauthToken('TM2TramasExecution');
           // token='AMJHUEKDAJDRFZAS';
            System.debug('token: '+token); 
        }
        catch(Exception ex){
            System.debug('Exception caught '+ex.getMessage());
        }
        
        String correId = IntegrationRecordHandlerUtil.getCorrelationId();
        System.debug('correId: '+correId);
        String reqBody = '';
        Set<String> transitionIdSet = new Set<String>(); 
        
        //creating callout header : TM2
        Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json',
            'Originating-System' => 'Salesforce',           
            'Authorization'=> 'Bearer ' + token,
            'Service-Provider-Id'=> '',
            'Correlation-Id'=> correId};   
                Map<String, List<String>> transitionIdwithServiceIdMap = new Map<String, List<String>>(); 
        Map<String,String> transitionIdwithattach= new Map<String,String>();
        if(!attachments.isEmpty()){
            String newAttId='';
            for(Attachment att : attachments){
                String mobileTransitionDTO= att.body.toString();
                TransitionDataDTO transitionDTO=TransitionDataDTO.parse(mobileTransitionDTO);
                
                List<String> serviceIdList=new List<String>();          
                List<TransitionDataDTO.SiteDTOMobile> siteMobileList=new list<TransitionDataDTO.SiteDTOMobile>();
                
                //Iterating TransitionDataDTO to create callout request body
                for(TransitionDataDTO.productListDTO productList:transitionDTO.productList){
                    System.debug('***Telstra:TM1EligibilityCheckServiceV2:productList: '+ productList);
                    for(TransitionDataDTO.SiteDTOMobile siteDTO:productList.site ){
                        for(TransitionDataDTO.serviceListDTOMobile serviceListDTO:siteDTO.serviceList ){
                            for(TransitionDataDTO.groupDTOMobile groupDTO:serviceListDTO.groupType ){
                                for(TransitionDataDTO.serviceDTOMobile serviceDTO:groupDTO.service ){
                                    if((groupDTO.transitionId!=null && serviceListDTO.checkValue==true)){
                                        String transitionId = groupDTO.transitionId;
                                        String resourceId = serviceDTO.Service_Id;
                                        newAttId = mobTramAttachMap.get(attachmentPC_Map.get(att.id));
                                        
                                        // serviceIdList.add(serviceDTO.Service_Id);
                                        transitionIdwithattach.put(groupDTO.transitionId,newAttId);
                                        // EDGE-206365-Dheeraj Bhatt-Retrigger of TM2 call for the failed numbers
                                        if(!transitionIdwithServiceIdMap.containsKey(groupDTO.transitionId)){
                                            if(String.isBlank(serviceDTO.Reserve_status) || (customMetadataNameValueMap.containsKey('Completed') && !serviceDTO.Reserve_status.equalsIgnoreCase(String.valueOf(customMetadataNameValueMap.get('Completed').get('Value__c'))))){
                                                transitionIdwithServiceIdMap.put(groupDTO.transitionId, new List<String>{serviceDTO.Service_Id});
                                            }
                                        }else{
                                            if(String.isBlank(serviceDTO.Reserve_status) || (customMetadataNameValueMap.containsKey('Completed') && !serviceDTO.Reserve_status.equalsIgnoreCase(String.valueOf(customMetadataNameValueMap.get('Completed').get('Value__c'))))){
                                                transitionIdwithServiceIdMap.get(groupDTO.transitionId).add(serviceDTO.Service_Id);
                                            }
                                        }
                                    }
                                }
                            }
                            
                        }
                    }
                }
            }
            
            //extracting resourceId's from json
            for(String tid:transitionIdwithServiceIdMap.keySet()){
                String resoursidvalue='';
                for(String tString:transitionIdwithServiceIdMap.get(tid)){
                    if(resoursidvalue=='')
                        resoursidvalue='"'+tString+'"';
                    else
                        resoursidvalue=resoursidvalue+','+'"'+tString+'"';
                }
                reqBody = '{"transitionId":"'+tid+'","resourceIds":['+resoursidvalue+'],"action":"reserve","mode":"continue-on-fail","metadata":{"salesforceId": "'+transitionIdwithattach.get(tid)+'" }}';
            }
            List<String>param=new List<String>{newAttId };
                HttpResponse res = new HttpResponse();
            try{
                res = IntegrationRecordHandlerUtil.callout(reqBody, IntegrationRecordHandlerUtil.HTTP_METHOD_POST, headerMap, 'TM2TramasExecution', param , correId);           
                System.debug('ResponseStatus: '+res.getStatusCode()  + ' Response: ' + res.getBody() );
                if(res.getStatusCode()==201 || res.getStatusCode()==202){
                    for(Attachment att : attachments){
                        MobileTramasElgibility__c mtRec = mbTramtoUpdateMap.get(attachmentPC_Map.get(att.id));
                        mtRec.ResponsePayload__c = res.getBody();
                        mbTramUpdateList.add(mtRec);
                        logger2.logMessages(JSON.serialize(reqBody), res.getBody(), '', '', '', '', false, false, Integer.valueOf(res.getStatusCode()) , null, null, null);
                        
                    }
                    if(!mbTramUpdateList.IsEmpty()){
                        update mbTramUpdateList;
                    }
                }
                else{
                    for(Attachment att : attachments){
                        MobileTramasElgibility__c mtRec = mbTramtoUpdateMap.get(attachmentPC_Map.get(att.id));
                         system.debug('mtRec: '+mtRec);
                        MobileTramasCallBackResponseDTO dto= MobileTramasCallBackResponseDTO.parse( res.getBody());
                        system.debug('dto: '+dto);
                        if(dto!=null && dto.Error!=null){
                            mtRec.ErrorCode__c  = dto.Error.code;
                            mtRec.Type__c='Execution Error';
                        }
                        mbTramUpdateList.add(mtRec);
                        logger2.logMessages(JSON.serialize(reqBody), res.getBody(), '', '', '', '', false, false, Integer.valueOf(res.getStatusCode()) , null, null, null);
                        prodBasket.Transition_basket_stage__c = 'Reserved with Errors';
                    }
                    if(!mbTramUpdateList.IsEmpty()){
                        update mbTramUpdateList;
                    }
                    system.debug('mbTramUpdateList: '+mbTramUpdateList);
                }
                
                if(prodBasket!=null){                    
                    update prodBasket;
                }
            }
            catch(Exception ex){
                System.debug('Exc caught '+ex.getMessage());
                System.debug('Exc caught '+ex.getStackTraceString());
                try{
                    logger2.logMessages(JSON.serialize(reqBody), res.getBody(), '', '', '', '', false, false, Integer.valueOf(res.getStatusCode()) , null, null, null);
                }Catch(Exception exc){
                }
            }                    
        }       
    }
    /*************************************************************************************************
Name        : getTramsErrorCode
Description : get status and reason related to the TRAMAS error code.
Author      : Kalashree Borgaonkar
Story       : EDGE-198375
***************************************************************************************************/   
    
     public static ErrorWrapper getTramsErrorCode(String offerType,String basketid,String exetype,DateTime currentDate){
        ErrorWrapper errorWrap ;
        if(offerType=='Mobile' || offerType=='Mobility' ){
            errorWrap = getTramsErrorCodeMobile(basketid,exetype,currentDate);
        }
        else{
            errorWrap = getTramsErrorCodeNguc(basketid,exetype,currentDate);
        }  
        return errorWrap;
    }
    /*************************************************************************************************
Name        : getTramsErrorCodeMobile
Description : get status and reason related to the TRAMAS error code.
Author      : Kalashree Borgaonkar
Story       : EDGE-198375
***************************************************************************************************/      
    
     public static ErrorWrapper getTramsErrorCodeMobile(String basketid,String exetype, Datetime currentdate){
        
         currentdate  = currentdate.addMinutes(-1);
          System.debug('currentdate: '+currentdate);
        ErrorWrapper errorWrap ;
        set<Id> productConfigId=new set<Id>();
        for(cscfga__Product_Configuration__c productConfig:[select id,cscfga__Product_Basket__r.csbb__Account__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =:basketid]){
            productConfigId.add(productConfig.id);
        }
        Map<String,ErrorWrapper> errorMap = getStatusAndReason();
        List<MobileTramasElgibility__c> mobileEligiblitylist = [SELECT Id,ErrorCode__c,type__c,CreatedDate
                                                                FROM MobileTramasElgibility__c 
                                                                WHERE product_configuration__c IN :productConfigId  
                                                                 AND createdDate>=:currentdate order by createdDate DESC LIMIT 1]; 
         System.debug('mobileEligiblitylist: '+mobileEligiblitylist);
         if(!mobileEligiblitylist.isempty()){
            errorWrap = new ErrorWrapper();
            //errorWrap.executiontype = mobileEligiblitylist[0].type__c; 
            System.debug(' errorWrap.type: '+ errorWrap.executiontype);
              System.debug(' mobileEligiblitylist[0].createdDate: '+ mobileEligiblitylist[0].createdDate);
              System.debug(' mobileEligiblitylist[0].createdDate: '+ currentdate);
              System.debug(' mobileEligiblitylist[0].createdDate: '+((mobileEligiblitylist[0].createdDate) >= currentdate.addMinutes(-2)));
            if(mobileEligiblitylist[0].ErrorCode__c!=null &&  mobileEligiblitylist[0].type__c=='Execution Error' ){
              
                if(errorMap.keySet().contains(mobileEligiblitylist[0].ErrorCode__c)){
                    errorWrap= errorMap.get(mobileEligiblitylist[0].ErrorCode__c);
                }
                errorWrap.tramasErrorcode = mobileEligiblitylist[0].ErrorCode__c;
                System.debug('errorWrap: '+errorWrap);
                updateAttachment(basketid,label.MobileTransitionName,mobileEligiblitylist[0].ErrorCode__c,null,exetype);
            }
            if(mobileEligiblitylist[0].type__c=='TM0 Execution Error'){
                errorWrap.toastMessage = 'Unable to proceed with eligibility check due to technical errors. Retry check eligibility or Request Support to proceed';
                updateAttachmentTm0(basketid,label.MobileTransitionName);
            }
            errorWrap.executiontype = mobileEligiblitylist[0].type__c; 
        }
        else 
        {
            //errorWrap.tramasErrorcode = '';
        }
        System.debug(' errorWrap: '+ errorWrap);
        return  errorWrap ;
    }
    /*************************************************************************************************
Name        : getTramsErrorCodeNguc
Description : get status and reason related to the TRAMAS error code.
Author      : Kalashree Borgaonkar
Story       : EDGE-198375
***************************************************************************************************/      
    public static ErrorWrapper getTramsErrorCodeNguc(String basketid,string exetype,Datetime currentdate){
        System.debug('currentdate: '+currentdate);
        set<Id> productConfigId=new set<Id>();
         currentdate  = currentdate.addMinutes(-1);
        String errorCode ;
        set<String> transitionidSet=new set<String>();
        for(cscfga__Product_Configuration__c productConfig:[select id,cscfga__Product_Basket__r.csbb__Account__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =:basketid]){
            productConfigId.add(productConfig.id);
        }
        ErrorWrapper errorWrap ;
        Map<String,ErrorWrapper> errorMap = getStatusAndReason();
        map<string,String> tIdToErrorCodeMap = new map<string,String>();
        List<TramasElgibilityCallbackResponse__c> ngucEligiblitylist = [SELECT Id,Error_code__c,type__c,TranasactionId__c,CreatedDate
                                                                        FROM TramasElgibilityCallbackResponse__c 
                                                                        WHERE Product_Configuration__c IN :productConfigId 
                                                                        AND createdDate>=:currentdate order by createdDate desc]; 
        Map<String,NgucErrorWrapper> transitionToErrorMap = new  Map<String,NgucErrorWrapper>();
        Map<String,NgucErrorWrapper> transitionToSuccessMap = new  Map<String,NgucErrorWrapper>();
        set<String> tidsfSet = new Set<String>();
        if(!ngucEligiblitylist.isEmpty() && ngucEligiblitylist[0].type__c=='TM0 Execution Error' ){
            errorWrap = new ErrorWrapper();
            errorWrap.toastMessage = 'Unable to proceed with eligibility check due to technical errors. Retry check eligibility or Request Support to proceed';
            errorWrap.executiontype  = ngucEligiblitylist[0].type__c;
            updateAttachmentTm0(basketid,'TransitionDataNgUc.json');
        }
        else{
            for(TramasElgibilityCallbackResponse__c response : ngucEligiblitylist){
                transitionidSet.add(response.TranasactionId__c);
                System.debug('response.type__c: '+response.type__c);
                if(response.type__c=='Execution Error' ){
                    NgucErrorWrapper wrap = new NgucErrorWrapper();
                    wrap.errorCode = response.Error_code__c;
                    wrap.createddate = response.CreatedDate;
                    wrap.id=response.id;
                    transitionToErrorMap.put(response.TranasactionId__c,wrap);
                }
                else{
                    NgucErrorWrapper wrap = new NgucErrorWrapper();
                    wrap.createddate = response.CreatedDate;
                    wrap.id=response.id;
                    transitionToSuccessMap.put(response.TranasactionId__c,wrap);
                }           
            }
            
            //case1; All failed
            if(transitionToSuccessMap.keyset().isEmpty()){
                //indicator = 'failed';
                System.debug('here');
                for(String str : transitionToErrorMap.keyset()){
                    tidsfSet.add(transitionToErrorMap.get(str).id);
                }
            }
            
            else if(transitionToSuccessMap.keyset().size()< transitionidSet.size()){
                for(String tid : transitionToErrorMap.keyset()){
                    // System.debug('transitionToSuccessMap:;'+(transitionToSuccessMap.get(tid).createdDate > transitionToErrorMap.get(tid).createdDate));
                    if(transitionToSuccessMap.get(tid)!=null  && transitionToSuccessMap.get(tid).createdDate > transitionToErrorMap.get(tid).createdDate){
                        //indicator = 'Success';
                        if(tidsfSet.contains(tid)){
                            tidsfSet.remove(transitionToErrorMap.get(tid).id);
                        }   
                    }
                    else{
                        //indicator = 'failed';
                        tidsfSet.add(transitionToErrorMap.get(tid).id);
                    }
                }
            } 
            System.debug('tidsfSet: '+tidsfSet);
            if(!tidsfSet.isEmpty()){
                for(TramasElgibilityCallbackResponse__c response : ngucEligiblitylist){
                    if(tidsfSet.contains(response.id)){
                        if(response.Error_code__c!=null){
                            tIdToErrorCodeMap.put(response.TranasactionId__c,response.Error_code__c);
                            errorCode = response.Error_code__c;
                        }
                        
                    }
                }
            }
            System.debug('tIdToErrorCodeMap: '+tIdToErrorCodeMap);
            if(!tIdToErrorCodeMap.keyset().isEmpty()){
                System.debug('tIdToErrorCodeMap: '+tIdToErrorCodeMap);
                updateAttachment(basketid,'TransitionDataNgUc.json',null,tIdToErrorCodeMap,exetype);
                
            }
            if(tIdToErrorCodeMap.keyset().size()==transitionidSet.size()){
                System.debug('errorcode: '+errorcode);
                errorWrap = new ErrorWrapper();
                errorWrap.executiontype = 'Execution Error';
                
                errorWrap.toastMessage = (!errorMap.keyset().isempty() && errorMap.get(errorcode)!=null)?errorMap.get(errorcode).toastMessage:null; 
                errorWrap.tramasErrorcode = errorcode; 
            }
            else{
                errorWrap = new ErrorWrapper();
                errorWrap.tramasErrorcode = 'Success'; 
                errorWrap.executiontype = exetype; 
            }
            System.debug('errorWrap: '+errorWrap); 
        }
        
        return  errorWrap ;
    }
    
    public static ReplicatorGetServiceManager.TableWrapper setMobileServiceStatusAndReasonTM1(ReplicatorGetServiceManager.TableWrapper mobileTableWrapper,String tramasErrorcode){
        //EDGE-198376-Aishwarya:Get Status and Reason code for TM1 callback failure
        Map<String,ErrorWrapper> errorCodetoStausMap= getStatusAndReason();   
        ErrorWrapper wrap = errorCodetoStausMap.get(tramasErrorcode);
        if(wrap!=null){
            //mobileTableWrapper.eligibilityStatus = wrap.status;
            mobileTableWrapper.eligibilityReason = wrap.reason; 
        } 
        return mobileTableWrapper;
        
    }
    
    public static TransitionController.transitionWrapper setMobileServiceStatusAndReasonTM2(TransitionController.transitionWrapper mobileTableWrapper,String tramasErrorcode,String status){
        //EDGE-202851-Kalashree:Get Status and Reason code for TM2 callback failure
        Map<String,ErrorWrapper> errorCodetoStausMap= getStatusAndReason();   
        if(tramasErrorcode!=null){
            ErrorWrapper wrap = errorCodetoStausMap.get(tramasErrorcode);
            System.debug('wrap: '+wrap);
            if(wrap!=null){
                //mobileTableWrapper.tramasStatus = status;
                mobileTableWrapper.tramasReason = wrap.reason; 
            } 
        }
        else{
            mobileTableWrapper.tramasStatus =status;
            
        } 
        System.debug('mobileTableWrapper: '+mobileTableWrapper);
        return mobileTableWrapper;       
    }
    /*************************************************************************************************
Name        : updateAttachment
Description : get status and reason related to the TRAMAS error code.
Author      : Kalashree Borgaonkar
Story       : EDGE-198375
***************************************************************************************************/      
    public static void updateAttachment(String basketid,String jsonName,String errorCode,map<string,String> tIdToErrorCodeMap,String exeType){
        Try{    
            //EDGE-150430 - Get Basket Id from Numbers 
            Map<String,ErrorWrapper> errorCodetoStausMap= getStatusAndReason();  
            set<Id> productConfigId=new set<Id>();
            for(cscfga__Product_Configuration__c productConfig:[select id,cscfga__Product_Basket__r.csbb__Account__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =:basketid]){
                productConfigId.add(productConfig.id);
            }
            
            List<Attachment> updateAttachmentlist= new List<Attachment>();
            for(Attachment attachList:[SELECT Name,ParentId,body FROM Attachment WHERE ParentId =:productConfigId AND Name = :jsonName]){
                //if(attachList.size()>0){
                String attachmentbody=attachList.body.toString();
                TransitionDataDTO transitionDTO=TransitionDataDTO.parse(attachmentbody);
                for(TransitionDataDTO.productListDTO productList:transitionDTO.productList){
                    for(TransitionDataDTO.SiteDTOMobile siteDTO:productList.site ){
                        for(TransitionDataDTO.serviceListDTOMobile serviceListDTO:siteDTO.serviceList ){
                            for(TransitionDataDTO.groupDTOMobile groupDTO:serviceListDTO.groupType ){
                                for(TransitionDataDTO.serviceDTOMobile serviceDTO:groupDTO.service ){
                                    if(tIdToErrorCodeMap!=null && !tIdToErrorCodeMap.keySet().isempty() && tIdToErrorCodeMap.keySet().contains(groupDTO.transitionId)){
                                      
                                        System.debug('groupDTO.transitionId'+tIdToErrorCodeMap.get(groupDTO.transitionId));
                                         System.debug('exeType'+exeType);
                                         System.debug('exeType'+groupDTO.checkValue);
                                        if(exeType=='TM2' && groupDTO.checkValue==true &&  serviceDTO.Reserve_status!='Completed'){
                                               serviceDTO.tramasErrorCode = tIdToErrorCodeMap.get(groupDTO.transitionId); 
                                              System.debug('exeType tm2 failure');
                                            serviceDTO.Reserve_status = errorCodetoStausMap.get(serviceDTO.tramasErrorCode).status;
                                            serviceDTO.Reason = errorCodetoStausMap.get(serviceDTO.tramasErrorCode).reason;
                                        }  
                                        else if(exeType=='TM1' && groupDTO.checkValue==true){
                                                serviceDTO.tramasErrorCode = tIdToErrorCodeMap.get(groupDTO.transitionId); 
                                              System.debug('exeType tm1 failure');
                                            serviceDTO.eligibilityReason = errorCodetoStausMap.get(serviceDTO.tramasErrorCode).reason;
                                            groupDTO.EligibilityStatus =  errorCodetoStausMap.get(serviceDTO.tramasErrorCode).status;
                                            groupDTO.EligibilityReason =  errorCodetoStausMap.get(serviceDTO.tramasErrorCode).reason;
                                            serviceDTO.Eligibility_status = errorCodetoStausMap.get(serviceDTO.tramasErrorCode).status;
                                        }                                       
                                    }
                                    else{
                                         System.debug('exeType'+exeType);
                                         System.debug('exeType'+groupDTO.checkValue);
                                         System.debug('serviceDTO.Reserve_status'+serviceDTO.Reserve_status);
                                        
                                      
                                        if(exeType=='TM2' && groupDTO.checkValue==true && serviceDTO.Reserve_status!='Completed'){
                                              serviceDTO.tramasErrorCode = errorCode;
                                            System.debug('serviceDTOMobile.serviceid'+serviceDTO.Service_Id);
                                             System.debug('exeType tm2 failure mobile');
                                            serviceDTO.Reserve_status =serviceDTO.tramasErrorCode!=null?errorCodetoStausMap.get(serviceDTO.tramasErrorCode).status:'Failed'; 
                                            serviceDTO.Reason =serviceDTO.tramasErrorCode!=null? errorCodetoStausMap.get(serviceDTO.tramasErrorCode).reason:'Technical Error';
                                        }
                                        else if(exeType=='TM1' && groupDTO.checkValue==true){
                                              serviceDTO.tramasErrorCode = errorCode;
                                            System.debug('serviceDTOMobile.serviceid'+serviceDTO.Service_Id);
                                               System.debug('exeType tm1 failure mobile');
                                            System.debug('groupDTO.tramasErrorCode: '+groupDTO.tramasErrorCode);
                                            serviceListDTO.EligibilityReason = serviceDTO.tramasErrorCode!=null?errorCodetoStausMap.get(serviceDTO.tramasErrorCode).reason:'Technical Error';
                                            groupDTO.EligibilityStatus =  serviceDTO.tramasErrorCode!=null?errorCodetoStausMap.get(serviceDTO.tramasErrorCode).status:'Failed';
                                            groupDTO.EligibilityReason =  serviceDTO.tramasErrorCode!=null?errorCodetoStausMap.get(serviceDTO.tramasErrorCode).reason:'Technical Error';
                                            serviceListDTO.Eligibilitystatus =serviceDTO.tramasErrorCode!=null?errorCodetoStausMap.get(serviceDTO.tramasErrorCode).status:'Failed';
                                        }                                        
                                    }
                                    if(serviceDTO.serviceExtensions!=null){
                                        for(TransitionDataDTO.serviceExtensionDTO extDTO:serviceDTO.serviceExtensions){
                                            if(tIdToErrorCodeMap!=null && !tIdToErrorCodeMap.keySet().isempty() && tIdToErrorCodeMap.keySet().contains(groupDTO.transitionId)){
                                                extDTO.tramasErrorCode = tIdToErrorCodeMap.get(groupDTO.transitionId);
                                                if(exeType=='TM2'){
                                                    extDTO.Reserve_status = errorCodetoStausMap.get(extDTO.tramasErrorCode).status;
                                                    extDTO.Reason = errorCodetoStausMap.get(extDTO.tramasErrorCode).reason;
                                                }
                                            }
                                            else{
                                                extDTO.tramasErrorCode = errorCode;
                                                if(exeType=='TM2'){
                                                    extDTO.Reserve_status = extDTO.tramasErrorCode!=null?errorCodetoStausMap.get(extDTO.tramasErrorCode).status:'Failed';
                                                    extDTO.Reason = extDTO.tramasErrorCode!=null?errorCodetoStausMap.get(extDTO.tramasErrorCode).reason:'Technical Error';
                                                }
                                            } 
                                        }
                                    }  
                                }
                            }  
                        }
                    }
                }
                String body=JSON.serialize(transitionDTO);
                System.debug('body'+body);
                attachList.body=blob.valueOf(body);
                updateAttachmentlist.add(attachList);
                //update attachList;
            }
            if(updateAttachmentlist.size()>0)
                update updateAttachmentlist;
        }
        catch (Exception ex){
            system.debug('Exception occured in NumberReservationTM2Callout Class at line number '+ex.getLineNumber()+' due to '+ex.getMessage());
        }
    }
     /*************************************************************************************************
Name        : updateAttachmentTm0
Description : update transition json for TM0 failure
Author      : Kalashree Borgaonkar
Story       : EDGE-198380
***************************************************************************************************/    
    public static void updateAttachmentTm0(String basketid,String jsonName){
        Try{    
            //EDGE-150430 - Get Basket Id from Numbers 
            Map<String,ErrorWrapper> errorCodetoStausMap= getStatusAndReason();  
            set<Id> productConfigId=new set<Id>();
            for(cscfga__Product_Configuration__c productConfig:[select id,cscfga__Product_Basket__r.csbb__Account__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =:basketid]){
                productConfigId.add(productConfig.id);
            }
            
            List<Attachment> updateAttachmentlist= new List<Attachment>();
            for(Attachment attachList:[SELECT Name,ParentId,body FROM Attachment WHERE ParentId =:productConfigId AND Name = :jsonName]){
                //if(attachList.size()>0){
                String attachmentbody=attachList.body.toString();
                //Parsing attachment body jason to TransitionDataDTO class
                TransitionDataDTO transitionDTO=TransitionDataDTO.parse(attachmentbody);
                //iterating to find the checkReserved value in TransitionDataDTO Class
                for(TransitionDataDTO.productListDTO productList:transitionDTO.productList){
                    for(TransitionDataDTO.SiteDTOMobile siteDTO:productList.site ){
                        for(TransitionDataDTO.serviceListDTOMobile serviceListDTO:siteDTO.serviceList ){
                            if(jsonName==label.MobileTransitionName && serviceListDTO.checkValue==true){
                                serviceListDTO.EligibilityStatus = 'Failed';
                                serviceListDTO.EligibilityReason = 'Technical error';
                            }
                            if(jsonName=='TransitionDataNgUc.json'){
                                for(TransitionDataDTO.groupDTOMobile groupDTO:serviceListDTO.groupType ){
                                    //for nguc
                                    System.debug('groupDTO.checkValue: '+groupDTO.checkValue);
                                    if(groupDTO.checkValue==true){
                                        groupDTO.EligibilityStatus = 'Failed';
                                        groupDTO.EligibilityReason = 'Technical error';
                                        for(TransitionDataDTO.serviceDTOMobile serviceDTO:groupDTO.service ){
                                            serviceDTO.EligibilityStatus = 'Failed';
                                            serviceDTO.Eligibility_Status = 'Failed';
                                            serviceDTO.EligibilityReason = 'Technical error'; 
                                        }
                                    } 
                                }
                            }  
                        }
                    }
                }
                String body=JSON.serialize(transitionDTO);
                System.debug('body'+body);
                attachList.body=blob.valueOf(body);
                updateAttachmentlist.add(attachList);
                //update attachList;
            }
            if(updateAttachmentlist.size()>0)
                update updateAttachmentlist;
        }
        catch (Exception ex){
            system.debug('Exception occured in NumberReservationTM2Callout Class at line number '+ex.getLineNumber()+' due to '+ex.getMessage());
        }
    }
      /*************************************************************************************************
Name        : updateTransitionJson
Description : update transition json after call callback responses have been received
Author      : Kalashree Borgaonkar
Story       : EDGE-203022
Revision	: Making the code dormant as story is on hold
***************************************************************************************************/ 
    /*public static void updateTransitionJson(Set<Id> basketIdSet){
        Set<Id> productConfigSet = new Set<Id> ();
        Set<Id> tramasErrorSet = new Set<Id> ();
        List<Id> recordId = new List<Id>();
        List<Id> parentId = new List<Id>();
        List<String> attachBody = new List<String>();
        Map<id,Sobject> tramasElgSobjectMap= new Map<id,Sobject>();
        List<Attachment> attachmentList ;
        List<TramasElgibilityCallbackResponse__c> tramasList =new   List<TramasElgibilityCallbackResponse__c>();

        List<cscfga__Product_Configuration__c> pcList =  [SELECT id,(SELECT id FROM TramasElgibilityCallbackResponses__r) 
                                                          FROM cscfga__Product_Configuration__c 
                                                          WHERE cscfga__Product_Basket__c IN :basketIdSet AND cscfga__Product_Definition__r.product_Specification__c =:Label.NextGenerationVoice ];
        
        for(cscfga__Product_Configuration__c pc : pcList){
            for(TramasElgibilityCallbackResponse__c tramaserr : pc.TramasElgibilityCallbackResponses__r){
                tramasErrorSet.add(tramaserr.id);
            }                                                               
        }
        System.debug('tramasErrorSet: '+tramasErrorSet);
        if(!tramasErrorSet.isEmpty()){
            attachmentList = [SELECT id,Body,parentid FROM Attachment WHERE parentid IN :tramasErrorSet AND BodyLength > 0];
        }
        System.debug('attachmentList: '+attachmentList);
        if(attachmentList!=null){
            for(Attachment att : attachmentList){
                tramasElgSobjectMap.put(att.id,att);
                recordId.add(att.id);
                parentId.add(att.id);
                attachBody.add((att.body).toString());
            }
            if(tramasElgSobjectMap.size()>0){
                system.debug('TramasEligibilityObjectblock');
                TramasBatchCallbackResponseUpdate.tramasAttachmentsUpdate(recordId,parentId,attachBody);
            }
        }  
    }*/
  /*************************************************************************************************
Name        : checkforNumberAssignment
Description : check if transition number is assigned
Author      : Kalashree Borgaonkar
Story       : EDGE-203928
***************************************************************************************************/     
        public static Map<String,Boolean> checkforNumberAssignment(String basketId,List<String> serviceidList){
        Map<String,Boolean> serviceTogreyMap = new Map<String,Boolean>();
		List<Number__c> numberList = [SELECT Product_Configuration__c ,Service_Number__c,Number_Range__c
									  FROM Number__c 
									  WHERE Basket__c  = :basketId
									  AND (Service_Number__c IN :serviceidList OR Number_Range__c IN :serviceidList) ];
		for(Number__c num : numberList){
			String serviceid = getserviceid(num.Number_Range__c,num.Service_Number__c);
			if(num.Product_Configuration__c!=null){
				serviceTogreyMap.put(serviceid,true);				
			}
			else{
				serviceTogreyMap.put(serviceid,false);	
			}
		}
            return serviceTogreyMap;
    }
	
	public static String getserviceid(String numberRange, String serviceNumber){
		String serviceID;
		if(numberRange.trim()!='-'){
			serviceID = numberRange.remove(' '); 
		}
		else{
			serviceID = serviceNumber; 
		}
        return serviceID;
    }
    /*************************************************************************************************
Name        : populateAssignedToinLegacyTable
Description : populate Assigned to value in transition legacy service table
Author      : Aishwarya
Story       : DIGI-1944
***************************************************************************************************/     
    public static Map<String,String> populateAssignedToinLegacyTable(String basketId,List<String> serviceidList){
        Map<String,String> serviceToAssignedto = new Map<String,String>();
        List<Number__c> numberList = [SELECT Product_Configuration__c ,Product_Configuration__r.cssdm__solution_association__r.Name,Product_Configuration__r.Name,Product_Configuration__r.OfferName__c,Service_Number__c,Number_Range__c
                                      FROM Number__c 
                                      WHERE Basket__c  = :basketId
                                      AND (Service_Number__c IN :serviceidList OR Number_Range__c IN :serviceidList) ];
        List<csord__Subscription__c> pcSubscriptions = new List<csord__Subscription__c>();
        Set<id> pcIdList=new set<id>();
        for(Number__c numrec : numberList ){
            pcIdList.add(numrec.Product_Configuration__c);
        }
        pcSubscriptions = [SELECT  csordtelcoa__Product_Configuration__c,customerFacingServiceId__c
                           from csord__Subscription__c
                           where csordtelcoa__Product_Configuration__c IN : pcIdList];
        Map<Id,String> cfsMap= new Map<Id,String>();
        for(csord__Subscription__c cfsdetail :pcSubscriptions)
        {
            cfsMap.put(cfsdetail.csordtelcoa__Product_Configuration__c,cfsdetail.customerFacingServiceId__c);
        }   
        for(Number__c numrec : numberList){
            String serviceid = getserviceid(numrec.Number_Range__c,numrec.Service_Number__c);
            String customerFacingId= (cfsMap.get(numrec.Product_Configuration__c)!=null)?cfsMap.get(numrec.Product_Configuration__c):null;
            if(numrec.Product_Configuration__c!=null){
                String assignedTo= numrec.Product_Configuration__r.OfferName__c
                    +' | '+ numrec.Product_Configuration__r.Name
                    + ((customerFacingId!=null)?' | '+ customerFacingId :'');
                serviceToAssignedto.put(serviceid,assignedTo);
            }
            else{
                serviceToAssignedto.put(serviceid,'');
            }
            
            
            system.debug('serviceToAssignedto***' +serviceToAssignedto);
        }
        return serviceToAssignedto;
    }
}