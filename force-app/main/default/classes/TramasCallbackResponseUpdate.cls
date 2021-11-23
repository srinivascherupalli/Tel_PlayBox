/**
* @Author   :   Aniket Srivastava
* @Date     :   08 July 2019
* @Desc     :   Class to parse TM callback response and make a callout in case of failed number reservation for Mobility
* @US       :   EDGE-94797
* @Status   :   Developemnt
* */
public with sharing class TramasCallbackResponseUpdate {
    public static map<string,Sobject> customMetadataNameValueMap=ConstantMetadataUtility.getConstantMetadataUtilityRecords('ConstantMetadataUtility__mdt');//EDGE-207443-Dheeraj Bhatt- Get the constant value from metadata
    public static List<String> callbackResponseBusinessError=Label.CallbackResponseBusinessError.split(',');
    public static List<String> callbackResponseWarning=Label.CallbackResponseWarning.split(',');	
	private static String correlationId = GuidUtil.NewGuid();
    private static final String CONST_INTERFACENAME = 'TramasCallbackResponseUpdate';
    private static final C2O_ExceptionHandler.Capability CONST_CAPABILITY = C2O_ExceptionHandler.Capability.BSK;
    @future(callout = true)
    
    //tamasAttachmentsUpdate is a future method which is invoked when the attachment trigger is fired when an update happens
    //on an attachment record.
    //public Static void tamasAttachmentsUpdate(string newMapPara, string oldMapPara) {
    public Static void tamasAttachmentsUpdate(List < Id > recordId, List < Id > parentId, List < String > attachBody) {
        String handlerName = 'TramasCallbackResponseUpdate';
        Integration_Handler__mdt handleSettingRecord = IntegrationRecordHandlerUtil.getIntegrationHandlerSettings(handlerName);
        set < id > attachmentParentId = new set < id > ();
        Logger2 logger2 = Logger2.getLogger(handlerName);
        String loggerRes = '';
        String errorResponse='';
        try {
            
            String loggerReq = '';
            
            String loggerResCode = '';
            Integer statusCode;
            
            
            system.debug('Inside tamasAttachmentsUpdate');
            //map < id, Sobject > newMap = (map < id, Sobject > ) JSON.deserialize(newMapPara, map < id, Sobject > .class);
            //map < id, Sobject > oldMap = (map < id, Sobject > ) JSON.deserialize(oldMapPara, map < id, Sobject > .class);
            
            //system.debug('Keyset' + newMap.keyset());
            List < Attachment > listAttachment = new List < Attachment > ();
            List < attachment > dltlist = new List < attachment > ();
            map < String, String > serviceIdWithStatusmap = new map < String, String > ();
            map < String, String > serviceIdWithDescsmap = new map < String, String > ();
            map < String, String > transitionWithStatusmap = new map < String, String > ();
            map < String, String > serviceIdWithTramasCodemap = new map < String, String > ();//EDGE-198376/202851 Aishwarya



            //   EDGE-207450-Dheeraj Bhatt-Optimization of code by removing SOQL from for loop
            for( Attachment att : [select Id,parentId, Name,body from attachment where ID IN: recordId]){
                //EDGE-207450-Start
                /*for (Integer i = 0; i < recordId.size(); i++) {
                         system.debug(stringList[i]);
                         Id sRecordId = recordId[i];
                         Attachment att = [select Id, Name,body from attachment where id =: sRecordId];
                         for (attachment att: [SELECT Id, name, body, BodyLength, Description, ParentId FROM Attachment WHERE id in: newMap.keyset()]) {
                         attTemp.Name = 'EligibilityResults';
                         attTemp.ParentId = parentId[i];
                         attachmentParentId.add(parentId[i]); 
                          String tempAttachBody = attachBody[i];
                          String callbackResponseDTO = attachBody[i]; */
                Attachment attTemp = new Attachment();
                attTemp.Name = att.Name;
                attTemp.ParentId = att.parentId;
                attachmentParentId.add(att.parentId);
                String tempAttachBody = att.body.toString(); 
                String callbackResponseDTO = att.body.toString();
                // EDGE-207450-Stop
                //system.debug('callbackResponseDTO@@@@@@@@@@@@@@:' + callbackResponseDTO);
                //Replacing _links with links in below statement since _links cannot be handled in DTO class TM2CallbackResponseDTO
                String callbackResponseDTOFinal = callbackResponseDTO.replace('_links', 'links');
                //callbackResponseDTOFinal = callbackResponseDTOFinal + '}';
                system.debug('CallbackResponseDTOwolinks@@@@@@@@:' + callbackResponseDTOFinal);
                //TM2CallbackResponseDTO trEligibilityRequest= (TM2CallbackResponseDTO) JSON.deserialize(callbackResponseDTO, TM2CallbackResponseDTO.class);
                TM2CallbackResponseDTO trEligibilityRequest = TM2CallbackResponseDTO.parse(callbackResponseDTOFinal);
                System.debug('trEligibilityRequest::: '+trEligibilityRequest);
                
                //for(TM2CallbackResponseDTO.links b:trEligibilityRequest.links)
                //{String test = b.rel;}
                List < String > responsString = new List < String > ();
                String errorDesc='';
                String tramasErrorCode='';
                for (TM2CallbackResponseDTO.steps respSteps: trEligibilityRequest.steps) {
                    //system.debug('a.name@@@@@ ' + a.name);
                    //if (respSteps.name == 'reserve' && respSteps.status != 'completed') {
                    //EDGE-199057 changes by abhishek from Osaka Team
                    if ((respSteps.name == 'discover' || respSteps.name == 'reserve' || respSteps.name == 'validate') && respSteps.status != 'completed')  {
                        transitionWithStatusmap.put(trEligibilityRequest.transitionId, respSteps.status);
                        System.debug('transitionWithStatusmap: '+transitionWithStatusmap);
                        for (TM2CallbackResponseDTO.results respResults: respSteps.results) {
                            system.debug('code: ' + respResults.code);	
                            system.debug('desc: ' + respResults.description);	
                            errorDesc=respResults.description;
                            tramasErrorCode=respResults.code;
                            for (TM2CallbackResponseDTO.links links: respResults.links) {
                                
                                String str = links.href;
                                //system.debug('links:' + str);
                                Integer index = str.lastIndexOf('/');	
                                String transitionId = str.substring(index + 1);	
                                
                                String getServiceEvent = 'TramasCallbackResponseUpdate';	
                                //EDGE-213584. Kalashree Borgaonkar. 
                                
                               String token = AuthenticationManager.getOauthToken(getServiceEvent);	
                              //  String token = 'aJ1AUZuZdKBUWb7s22OhejvWKRzU'; 
                                Map < String, String > headerMap = new Map < String, String > {
                                    'Content-Type' => 'application/json',
                                        'Authorization' => 'Bearer ' + token,
                                        'Originating-System' => 'Salesforce'
                                        };
                                            // if (!Test.isRunningTest()) {
                                            //Below callout is being made inside loop because there can be multiple numbers for which reservation can fail . A link would be sent in response for each failure and callout has to be made for each link separately in loop.
                                            HttpResponse res = IntegrationRecordHandlerUtil.callout(transitionId, IntegrationRecordHandlerUtil.HTTP_METHOD_GET, headerMap, TramasCallbackResponseUpdate.class.getName(), null, null);
                                loggerReq = loggerReq + str + '\n\n';
                                loggerRes = loggerRes + res.getBody() + '\n\n';
                                statusCode = res.getStatusCode();
                                system.debug('@@@@respbody resource API' + res.getBody());
                                tempAttachBody = res.getBody();
                                responsString.add(res.getBody());
                            }
                            
                        }
                        //EDGE-199057 changes by Abhishek from Osaka Team to add validate for TM1
                        // EDGE-207443-Dheeraj Bhatt- Warning numbers from TRAMAS Resource API response to be considerer  as as Eligible/Locked
                    } 
                    else if ((respSteps.name == 'reserve' || respSteps.name == 'validate') && respSteps.status == 'completed' ) {//(reserve or validate)
                        System.debug('Inside Steps::::'+respSteps.name);
                        transitionWithStatusmap.put(trEligibilityRequest.transitionId, respSteps.status);
                        System.debug('transitionStatusMap::'+transitionWithStatusmap);
                    }
                    
                    //attTemp.Body = Blob.valueOf(tempAttachBody);
                    //listAttachment.add(attTemp);
                    //dltlist.add(att);
                    
                }
                for (String lstring: responsString) {
                    System.debug('inside :  responsString');
                    MobileTramasCallBackResponseDTO mobTDTO = MobileTramasCallBackResponseDTO.parse(lstring);
                    MobileTramasCallBackResponseDTO.validationDto valDTO = mobTDTO.validation;
                    //EDGE-213584 - Kalashree Borgaonkar. Adding null check to avoid exception
                    System.debug('mobTDTO :  valDTO.results'+mobTDTO);	
                    if(valDTO!=null){
                        for (MobileTramasCallBackResponseDTO.resultsdto reDTO: valDTO.results) {
                            System.debug('inside :  valDTO.results');
                            // EDGE-207443-Dheeraj Bhatt- Warning numbers from TRAMAS Resource API response to be considerer  as as Eligible/Locked
                            if(mobTDTO.state =='validated' && customMetadataNameValueMap.containsKey('TMCallWarningStatus') &&  valDTO.status.equalsIgnoreCase(String.valueOf(customMetadataNameValueMap.get('TMCallWarningStatus').get('Value__c')))){
                                serviceIdWithStatusmap.put(mobTDTO.identifier,'Eligible');
                            }
                            else if(mobTDTO.state =='reserved' && customMetadataNameValueMap.containsKey('TMCallWarningStatus') &&  valDTO.status.equalsIgnoreCase(String.valueOf(customMetadataNameValueMap.get('TMCallWarningStatus').get('Value__c')))) {
                                serviceIdWithStatusmap.put(mobTDTO.identifier, 'Completed');
                            }
                            //EDGE-215821:Set status for callback business Error
                           else if(mobTDTO.state =='validated' &&  CallbackResponseBusinessError.Contains(tramasErrorCode)){
                                serviceIdWithStatusmap.put(mobTDTO.identifier, 'Not Eligible');
                            }
                            else{
                                serviceIdWithStatusmap.put(mobTDTO.identifier, valDTO.status);
                            }
                         //EDGE-215821:Capturing of Business/Technical errors in the Transition/NM UI Start
                            if(CallbackResponseBusinessError.Contains(tramasErrorCode) || CallbackResponseWarning.Contains(tramasErrorCode)){
                            serviceIdWithDescsmap.put(mobTDTO.identifier, reDTO.description);
                        }else{
                           serviceIdWithDescsmap.put(mobTDTO.identifier, ErrorDesc); 
                        }	
                             system.debug('serviceIdWithDescsmap: ' + serviceIdWithDescsmap);	
                            //EDGE-215821:End
                            serviceIdWithTramasCodemap.put(mobTDTO.identifier, reDTO.code);//EDGE-198376/202815
                        }
                        //EDGE-213584 - Kalashree Borgaonkar. Set error message for status==unknown and result block as empty
                        if(valDTO.results!=null && valDTO.results.isempty()){
                            //errorResponse = 'Technical error';
                            serviceIdWithDescsmap.put(mobTDTO.identifier, 'Technical error');
                            serviceIdWithStatusmap.put(mobTDTO.identifier, 'Failed');
                            System.debug('serviceIdWithDescsmap: '+serviceIdWithDescsmap);
                            System.debug('serviceIdWithStatusmap: '+serviceIdWithStatusmap);
                        }
                    }
                    else{
                        //EDGE-213584 - Kalashree Borgaonkar. Set error message
                        errorResponse = mobTDTO.error.message;
                        System.debug('errorResponse: '+errorResponse);
                    }    
                }
                	
                system.debug('serviceIdWithStatusmap=='+serviceIdWithStatusmap);
            }
            List < MobileTramasElgibility__c > mobiletramaslst = new List < MobileTramasElgibility__c > ();
            if(MobileTramasElgibility__c.sObjectType.getDescribe().isAccessible()){
                mobiletramaslst = [select Product_Configuration__c,Type__c from MobileTramasElgibility__c where id in: attachmentParentId order by CreatedDate DESC limit 1 ];	
            }	
            
            map < id, String > attachmentWithIdUpdatemap = new map < id, String > ();
            for (Attachment att: [Select id, body, parentid from attachment where parentid =: mobiletramaslst[0].Product_Configuration__c and name = 'TransitionData.json']) {
                Map < String, Object > meta = (Map < String, Object > ) JSON.deserializeUntyped(att.body.toString());
                List < Object > prdlst = (List < Object > ) meta.get('productList');
                system.debug('ProductList' + prdlst);
                for (object prd: prdlst) {
                    Map < String, Object > sites = (Map < String, Object > ) prd;
                    List < Object > sitelst = (List < Object > ) sites.get('site');
                    system.debug('Sites' + sitelst);
                    for (Object serv: sitelst) {
                        Map < String, Object > services = (Map < String, Object > ) serv;
                        List < object > servlst = (List < Object > ) services.get('serviceList');
                        system.debug('servlst' + servlst);
                        for (Object grp: servlst) {
                            Map < String, Object > grps = (Map < String, Object > ) grp;
                            List < object > grplst = (List < Object > ) grps.get('groupType');
                            system.debug('grplst' + grplst);
                            for (Object gp: grplst) {
                                Map < String, Object > grpmap = (Map < String, Object > ) gp;
                                List < object > serlst = (List < Object > ) grpmap.get('service');
                                system.debug('#############transitionId' + (String.valueof(grpmap.get('transitionId'))));
                                if (transitionWithStatusmap.containsKey(String.valueof(grpmap.get('transitionId')))) {
                                    
                                    for (object ser: serlst) {
                                        Map < String, Object > servmap = (Map < String, Object > ) ser;
                                        for (String attributeName: servmap.keyset()) {
                                            if (attributeName == 'Service_Id') {
                                                system.debug('#############' + servmap.get('Service_Id'));
                                                //START OF EDGE-199057 by Abhishek From Osaka Team
                                                // Re-setting eligibility after TM1 call in TransitionData.json file
                                                System.debug('checkValue: '+String.valueof(grpmap.get('checkValue')));
                                                
                                                if(mobiletramaslst[0].Type__c == 'TM1'){
                                                    grps = getResponseForTM1 (grps,
                                                    serviceIdWithStatusmap,servmap,serviceIdWithDescsmap,
                                                    grpmap,errorResponse,serviceIdWithTramasCodemap);
                                                    /*if (serviceIdWithStatusmap.containskey(String.valueof(servmap.get('Service_Id')))) {	
                                                        System.debug('Inside ineligible');
                                                        grps.put('EligibilityStatus', serviceIdWithStatusmap.get(String.valueof(servmap.get('Service_Id'))));
                                                        grps.put('EligibilityReason', serviceIdWithDescsmap.get(String.valueof(servmap.get('Service_Id'))));
                                                    } 
                                                    //EDGE-213584 - Kalashree Borgaonkar. Set error message
                                                    else if(serviceIdWithTramasCodemap.isEmpty() && String.valueof(grpmap.get('checkValue'))=='true' && errorResponse !='' ){
                                                        grps.put('EligibilityReason',errorResponse);
                                                        grps.put('EligibilityStatus','Failed');
                                                        
                                                    }
                                                    else{
                                                        grps.put('EligibilityReason','');
                                                        grps.put('EligibilityStatus','Eligible'); 
                                                    }*/	
                                                    
                                                }
                                                //END OF EDGE-199057 by Abhishek From Osaka Team 
                                                else{
                                                    servmap =  getResponseForOthers(servmap,serviceIdWithStatusmap,servmap,
                                                    serviceIdWithDescsmap,grpmap,errorResponse,serviceIdWithTramasCodemap);
                                                    //system.debug('@@@@@@@@@@@@@@@@@@@@@'+grplst.get('transitionId'));
                                                    /*if (serviceIdWithStatusmap.containskey(String.valueof(servmap.get('Service_Id')))) {	
                                                        servmap.put('Reserve_status', serviceIdWithStatusmap.get(String.valueof(servmap.get('Service_Id'))));
                                                        servmap.put('Reason', serviceIdWithDescsmap.get(String.valueof(servmap.get('Service_Id'))));
                                                    } 
                                                    //EDGE-213584 - Kalashree Borgaonkar. Set error message
                                                    else if(serviceIdWithTramasCodemap.isEmpty() && String.valueof(grpmap.get('checkValue'))=='true'  &&  String.valueof(servmap.get('Reserve_status'))!='Completed' && errorResponse!=''){
                                                        servmap.put('Reason',errorResponse);
                                                        servmap.put('Reserve_status','Failed');
                                                    }
                                                    else {
                                                        servmap.put('Reserve_status', 'Completed');
                                                        servmap.put('Reason', '');
                                                    }	*/
                                                }
                                                System.debug('serviceIdWithTramasCodemap: '+serviceIdWithTramasCodemap.containskey(String.valueof(servmap.get('Service_Id'))));
                                                
                                                //EDGE-198376/202815 Insert Tramas code in Transition JSON Start
                                                /*if (serviceIdWithTramasCodemap.containskey(String.valueof(servmap.get('Service_Id'))) && (serviceIdWithStatusmap.get(String.valueof(servmap.get('Service_Id')))!='Completed' || serviceIdWithStatusmap.get(String.valueof(servmap.get('Service_Id'))) != 'Eligible')) {
servmap.put('tramasErrorCode', serviceIdWithTramasCodemap.get(String.valueof(servmap.get('Service_Id'))));
}
else{
servmap.put('tramasErrorCode', null);
}*/
                                                //EDGE-198376/202815 Insert Tramas code in Transition JSON End
                                            }
                                        }
                                        
                                    }
                                }
                                
                            }
                        }
                    }
                }
                system.debug('finalJSON' + string.valueof(JSON.serializePretty(meta)));
                attachmentWithIdUpdatemap.put(att.id, string.valueof(JSON.serializePretty(meta)));
            }
            if (attachmentWithIdUpdatemap.size() > 0) {
                //List<Attachment> listAttachment = new List<Attachment>();
                // List<attachment> dltlist= new List<attachment>();
                for (attachment attloop: [Select id, Parentid, body from attachment where id in: attachmentWithIdUpdatemap.keyset()]) {
                    
                    Attachment att = new Attachment();
                    att.Name = 'TransitionData.json';
                    //att.Name = System.Label.MobileTransitionName;
                    att.ParentId = attloop.Parentid;
                    att.Body = blob.valueof(attachmentWithIdUpdatemap.get(attloop.id));
                    listAttachment.add(att);
                    dltlist.add(attloop);
                    
                }
                
                if (listAttachment.size() > 0 && Schema.sObjectType.Attachment.isDeletable()){	
                    delete dltlist;	
                }
                if (listAttachment.size() > 0 && Schema.sObjectType.Attachment.isCreateable()){	
                insert listAttachment;
            }
            
            }	 
            	
            
            
            logger2.logMessages(loggerReq, loggerRes, '', '', '', '', false, false, statusCode, null, null, null);
        } 
        catch (Exception ex) {	
            
            //System.debug('***Telstra:TramasCallbackResponseUpdate:trException:' + e.getMessage());	
            logger2.logMessages('TramasCallbackResponseUpdate:TramasCallout:Exception:' + 'TramasCallbackResponseUpdate', loggerRes+'\n'+ ex.getStacktraceString() , '', '', '', '', false, false, null, null, null, null);	
            logException('tamasAttachmentsUpdate', '', correlationId, ex.getMessage(), 'make a callout in case of failed number reservation for Mobility');	
        }	
            
        }
        
    public static Map<String,object> getResponseForTM1 (Map<String,object> mabObj,
    map <String, String> serviceIdWithStatusmap,Map < String, Object > servmap,map <String, String> serviceIdWithDescsmap,
    Map < String, Object > grpmap,String errorResponse,map <String, String> serviceIdWithTramasCodemap){
            if (serviceIdWithStatusmap.containskey(String.valueof(servmap.get('Service_Id')))) {	
                System.debug('Inside ineligible');	
                mabObj.put('EligibilityStatus', serviceIdWithStatusmap.get(String.valueof(servmap.get('Service_Id'))));	
                mabObj.put('EligibilityReason', serviceIdWithDescsmap.get(String.valueof(servmap.get('Service_Id'))));	
            } 	
            //EDGE-213584 - Kalashree Borgaonkar. Set error message	
            else if(serviceIdWithTramasCodemap.isEmpty() && String.valueof(grpmap.get('checkValue'))=='true' && errorResponse !='' ){	
                mabObj.put('EligibilityReason',errorResponse);	
                mabObj.put('EligibilityStatus','Failed');	
                    
            }	
            else{	
                mabObj.put('EligibilityReason','');	
                mabObj.put('EligibilityStatus','Eligible'); 	
            }

            return mabObj;
    }
    
    public static Map<String,object> getResponseForOthers (Map<String,object> mabObj,
    map <String, String> serviceIdWithStatusmap,Map < String, Object > servmap,map <String, String> serviceIdWithDescsmap,
    Map < String, Object > grpmap,String errorResponse,map <String, String> serviceIdWithTramasCodemap){
        if (serviceIdWithStatusmap.containskey(String.valueof(servmap.get('Service_Id')))) {	
            mabObj.put('Reserve_status', serviceIdWithStatusmap.get(String.valueof(servmap.get('Service_Id'))));	
            mabObj.put('Reason', serviceIdWithDescsmap.get(String.valueof(servmap.get('Service_Id'))));	
        } 	
        //EDGE-213584 - Kalashree Borgaonkar. Set error message	
        else if(serviceIdWithTramasCodemap.isEmpty() && String.valueof(grpmap.get('checkValue'))=='true'  &&  String.valueof(servmap.get('Reserve_status'))!='Completed' && errorResponse!=''){	
            mabObj.put('Reason',errorResponse);	
            mabObj.put('Reserve_status','Failed');	
        }	
        else {	
            mabObj.put('Reserve_status', 'Completed');	
            mabObj.put('Reason', '');	
        }

            return mabObj;
    }

    	/**
     * @description Exception Handling Framework 
       */
		private static void logException(String methodName, String referenceNumber, String correlationId, String errorMessage, String businessDescription){
        Map<String, Object> eLogMap = new Map<String, Object>();
        eLogMap.put('capability', CONST_CAPABILITY);
        eLogMap.put('interfaceName', CONST_INTERFACENAME);
        eLogMap.put('elementName', methodName);
        eLogMap.put('referenceNumber', referenceNumber);
        eLogMap.put('correlationId', correlationId);
        eLogMap.put('errorDescription', errorMessage);
        eLogMap.put('businessDescription', businessDescription);
        C2O_Utilities.logException(eLogMap, false);
    }
    
    private static void logException(String severity, string methodName, String referenceNumber, String endpointURL, String integrationPayload, String correlationId, String httpStatusCode, String errorCode, String errorMessage,  String responseMessage, String destinationSystem, String sourceName, String businessDescription, String errorCategory) {
        Map<String, Object> eLogMap = new Map<String, Object>();
        eLogMap.put('severity', severity);
        eLogMap.put('interfaceName', CONST_INTERFACENAME);
        eLogMap.put('elementName', methodName);
        eLogMap.put('referenceNumber', referenceNumber);
        eLogMap.put('capability', CONST_CAPABILITY);
        eLogMap.put('endpointURL', endpointURL);
        eLogMap.put('integrationPayload', integrationPayload);
        eLogMap.put('correlationId', correlationId);
        eLogMap.put('httpStatusCode', httpStatusCode);
        eLogMap.put('errorCode', errorCode);
        eLogMap.put('errorDescription', errorMessage);
        eLogMap.put('responseMessage', responseMessage);
        eLogMap.put('destinationSystem', destinationSystem);
        eLogMap.put('sourceName', sourceName);
        eLogMap.put('businessDescription', businessDescription);
        eLogMap.put('errorCategory', errorCategory);
        C2O_Utilities.logException(eLogMap, false);
       }
}