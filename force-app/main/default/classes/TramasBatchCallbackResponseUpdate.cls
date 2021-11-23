/*
* @Author : Rahul Asarma
* @Date :  11 Nov 2019
* @Desc :  Tramas Batch Callback Response Update
* @Jira Cloud : EDGE-92541
1. Ankit/Vivek  EDGE-101034  setting Eligiblity on group level on transtiondatarnguc for hybrid
2. Kalashree EDGE-203022 - Resource API callout to be done only once against each transition id
3. Dheeraj Bhatt-DIGI-861-Capturing of Business/Technical errors in the Transition/NM UI for NGUC
*/
Public with sharing class TramasBatchCallbackResponseUpdate {
    
    public Static final String COMPLETEDTEXT = 'completed';//Additional Fix of EDGE-156518
    public Static final String ELIGIBLITYFILENAMETEXT = 'EligibilityResults.txt';//Additional Fix of EDGE-156518
    public Static final String RESERVEFILENAMETEXT = 'ReserveResults.txt';//Additional Fix of EDGE-156518
    public Static final String ELIGIBLETEXT='Eligible';//Additional Fix of EDGE-158682
    public static map<string,Sobject> customMetadataNameValueMap=ConstantMetadataUtility.getConstantMetadataUtilityRecords('ConstantMetadataUtility__mdt');//EDGE-207443-Dheeraj Bhatt- Get the constant value from metadata
	private static String correlationId = GuidUtil.NewGuid();
    private static final String CONST_INTERFACENAME = 'TramasBatchCallbackResponseUpdate';
    private static final C2O_ExceptionHandler.Capability CONST_CAPABILITY = C2O_ExceptionHandler.Capability.BSK;
    public static List<String> callbackResponseBusinessError=Label.CallbackResponseBusinessError.split(',');
    public static List<String> callbackResponseWarning=Label.CallbackResponseWarning.split(',');
 //This Method has been written to read response of callback
    @future(callout = true)
    public Static void tramasAttachmentsUpdate(List < Id > recordId, List < Id > parentId, List < String > attachBody) {
        tramasAttachmentsUpdateNew(recordId, parentId,  attachBody);
    }
    
    public Static void tramasAttachmentsUpdateNew(List < Id > recordId, List < Id > parentId, List < String > attachBody) {
        try{
        String errorResponse='';
        String loggerReq = '';
        String loggerRes = '';
        String loggerResCode = '';
        integer statusCode;
        //Integer linkcount=0;
        String handlerName = 'TramasCallbackResponseUpdate';
        Logger2 logger2 = Logger2.getLogger(handlerName);
        map<string,Attachment> eligiblityAttachmentMap= new map<string,Attachment> ();
        map<string,Attachment> reserveAttachmentMap= new map<string,Attachment> ();
        map<string,string> eligibilityWithTramasRecordMap= new map<String,String>(); 
for(Attachment attloop:[select Id, parentid,Name,body from attachment where id in :recordId]){
            //if(attloop.name=='EligibilityResults.txt')
            eligiblityAttachmentMap.put(attloop.parentid,attloop);
           /* if(attloop.name=='ReserveResults.txt')
            reserveAttachmentMap.put(attloop.parentid,attloop);*/
        }
        map < String, String > serviceIdWithStatusmap = new map < String, String > ();
            map < String, String > serviceIdWithDescsmap = new map < String, String > ();
        map < String, String > transitionWithStatusmap = new map < String, String > ();
        map < String, GroupWrapper > transitionTostatusMap = new map < String, GroupWrapper > ();//EDGE-203022 Kalashree
    system.debug('eligiblityAttachmentMap'+eligiblityAttachmentMap);
    for(String attParentid:eligiblityAttachmentMap.keyset()){
            String callbackresponsebody =((eligiblityAttachmentMap.get(attParentid).body).toString()).replace('_links', 'links');
        system.debug('Callbackresponsebody'+Callbackresponsebody);
            String actionType='';
            if(eligiblityAttachmentMap.get(attParentid).name==eligiblityFileNameText){//Additional Fix of EDGE-156518
                actionType='validate';
            }
            else if(eligiblityAttachmentMap.get(attParentid).name==reserveFileNameText){//Additional Fix of EDGE-156518
                actionType='reserve';
        }
            system.debug('ACTIONType'+actionType);
        //system.debug('Callbackresponsebody'+Callbackresponsebody);
        TM2CallbackResponseDTO trEligibilityRequest = TM2CallbackResponseDTO.parse(Callbackresponsebody);
            //List < String > responsString = new List < String > ();
            String resourceApiResponse;
            String errorDesc='';//DIGI-861
            String tramasErrorCode='';//DIGI-861
        for (TM2CallbackResponseDTO.steps respSteps: trEligibilityRequest.steps) {
                //EDGE-202851, EDGE-198376 Extended condition for discover
                if ((respSteps.name == actionType || respSteps.name == 'discover') && respSteps.status != completedText) {
                    
                system.debug('underValidateblock');
                        transitionWithStatusmap.put(trEligibilityRequest.transitionId, respSteps.status);
                for (TM2CallbackResponseDTO.results respResults: respSteps.results) {
                        //EDGE-203022. Kalashree Borgaonkar. Make callout for one resource only
                        //for (TM2CallbackResponseDTO.links links: respResults.links) {
                        //linkcount = respResults.links!=null?respResults.links.size():0;
                         //Start-DIGI-861
                         errorDesc=respResults.description;
                         tramasErrorCode=respResults.code;
                         //End-DIGI-861
                        if(respResults.links!=null &&  !respResults.links.isEmpty()){
                            system.debug('valueoflinks'+respResults.links[0]);
                            String str = respResults.links[0].href;
                                //system.debug('links:' + str);

                                Integer Index = str.lastIndexOf('/');
                                String transitionId = str.substring(Index + 1);
                                String GETSERVICE_EVENT = 'TramasCallbackResponseUpdate';

                            String token = AuthenticationManager.getOauthToken(GETSERVICE_EVENT);

                            //String token = 'AKFIGMDITGKSGHA';

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
                                    //loggerReq = loggerReq + str + '\n\n';
                                   // loggerRes = loggerRes + res.getBody() + '\n\n';
                            // integer statusCode = res.getStatusCode();
                                    //loggerResCode = loggerResCode + Integer.valueOf(res.getStatusCode()) + '\n';
                                    /*system.debug('Before logger');
                                if(res!= null && res.getStatusCode() == IntegrationRecordHandlerUtil.HTTP_SUCCESS) { //Request was successfully accepted
                                    system.debug('Inside logger');
                                    logger2.logMessages(str, res.getBody(), '', '', '', '', false, false, Integer.valueOf(res.getStatusCode()) , null, null, null);
                                    }  
                                    system.debug('after logger');*/
                                    system.debug('@@@@respbody' + res.getBody());
                                   String tempAttachBody = res.getBody();
                                   //if(res.getStatusCode()==200)
                            //responsString.add(res.getBody());
                            resourceApiResponse = res.getBody();
                            //}
                    }
                }
            }
                else if (respSteps.name == actionType && respSteps.status == completedText) {//Additional Fix of EDGE-156518
                    if(actionType=='validate'){
                        transitionWithStatusmap.put(trEligibilityRequest.transitionId, 'Eligible');
            }
            else{
                        transitionWithStatusmap.put(trEligibilityRequest.transitionId, respSteps.status);
                    }
            }
            system.debug('valueoftransitionWithStatusmap'+transitionWithStatusmap);
        }
            //for (String lstring: responsString) {
            System.debug(' resourceApiResponse  '+ resourceApiResponse);
            if(resourceApiResponse!=null){
	    GroupWrapper wrap= new GroupWrapper();
                MobileTramasCallBackResponseDTO mobTDTO = MobileTramasCallBackResponseDTO.parse(resourceApiResponse);
            MobileTramasCallBackResponseDTO.validationDto valDTO = mobTDTO.validation;
                System.debug('valDTO: '+valDTO);
                if(valDTO!=null){
            for (MobileTramasCallBackResponseDTO.resultsdto reDTO: valDTO.results) {
                    // EDGE-207443-Dheeraj Bhatt- Warning numbers from TRAMAS Resource API response to be considerer  as as Eligible/Locked
                    
                    system.debug('mobTDTO.state=='+mobTDTO.state);
                    if(mobTDTO.state =='validated' && customMetadataNameValueMap.containsKey('TMCallWarningStatus') &&  valDTO.status.equalsIgnoreCase(String.valueOf(customMetadataNameValueMap.get('TMCallWarningStatus').get('Value__c')))){
                        serviceIdWithStatusmap.put(mobTDTO.identifier,'Eligible');
                        wrap.status ='Eligible';
                    }
                    else if(mobTDTO.state =='reserved' && customMetadataNameValueMap.containsKey('TMCallWarningStatus') &&  valDTO.status.equalsIgnoreCase(String.valueOf(customMetadataNameValueMap.get('TMCallWarningStatus').get('Value__c')))) {
                        serviceIdWithStatusmap.put(mobTDTO.identifier, 'Completed');
                        wrap.status = 'Completed';
                    }
                    //DIGI-861
                    else if(mobTDTO.state =='validated' &&  CallbackResponseBusinessError.Contains(tramasErrorCode)){
                        serviceIdWithStatusmap.put(mobTDTO.identifier, 'Not Eligible');
                         wrap.status = 'Not Eligible';
                    }
                    else {
                serviceIdWithStatusmap.put(mobTDTO.identifier, valDTO.status);
                        wrap.status = valDTO.status;
                    }
                //DIGI-861-Dheeraj Bhatt-Capturing of Business/Technical errors in the Transition/NM UI for NGUC
                if(CallbackResponseBusinessError.Contains(tramasErrorCode) || CallbackResponseWarning.Contains(tramasErrorCode)){
                    serviceIdWithDescsmap.put(mobTDTO.identifier, reDTO.description);
                    wrap.description = reDTO.description;
                }
                else {
                    serviceIdWithDescsmap.put(mobTDTO.identifier,ErrorDesc);
                    wrap.description = ErrorDesc;
                }
                //END-DIGI-861
                    transitionTostatusMap.put(mobTDTO.transitionId,wrap);
            }
                    //EDGE-217096 - Aishwarya. Set error message for status==unknown and result block as empty
                    if(valDTO.results!=null && valDTO.results.isempty()){
                            serviceIdWithDescsmap.put(mobTDTO.identifier, 'Technical error');
                            serviceIdWithStatusmap.put(mobTDTO.identifier, 'Failed');
                        wrap.status='Failed';
                        wrap.description='Technical error';
                         transitionTostatusMap.put(mobTDTO.transitionId,wrap);
                            System.debug('serviceIdWithDescsmap: '+serviceIdWithDescsmap);
                             System.debug('serviceIdWithStatusmap: '+serviceIdWithStatusmap);
                        }
        }

                else{
                     // Kalashree Borgaonkar. Set error message
                    errorResponse = mobTDTO.error.message;
                    System.debug('errorResponse: '+errorResponse);
                }

            }

            
            //}
    }
		
        
    system.debug('serviceIdWithStatusmapValue-->'+serviceIdWithStatusmap);
    system.debug('serviceIdWithDescsmapmapValue-->'+serviceIdWithDescsmap);
    map<String,String> prcidWithTypeMap= new map<String,String> ();
    map<String,String> attachmentWithIdUpdatemap= new map<String,String>();
    map<String,String> transitionIdWithTramasRecordMap= new map<String,String> ();//Added for EDGE-151424
    for(TramasElgibilityCallbackResponse__c tramasEligiblityloop:[select id,TranasactionId__c,Product_Configuration__c,Type__c from TramasElgibilityCallbackResponse__c where id in: eligiblityAttachmentMap.keyset()]){
        transitionIdWithTramasRecordMap.put(tramasEligiblityloop.TranasactionId__c,tramasEligiblityloop.id);//Added for EDGE-151424
        prcidWithTypeMap.put(tramasEligiblityloop.Product_Configuration__c,tramasEligiblityloop.Type__c);
        system.debug('prcidWithTypeMap'+prcidWithTypeMap);
        system.debug('transitionIdWithTramasRecordMap'+transitionIdWithTramasRecordMap);//Added for EDGE-151424
    }
    //List < TramasElgibilityCallbackResponse__c > tramasElgbltylst = [select Product_Configuration__c,Type__c from TramasElgibilityCallbackResponse__c where id in: eligiblityAttachmentMap.keyset()];
    //String type=tramasElgbltylst[0].Type__c;
    String[] filename= new String[]{system.label.NgUcTransitionName,'TransitionJSONData.json'};
    for (Attachment att: [Select id, name,body, parentid from attachment where parentid in: prcidWithTypeMap.keyset() and name in:filename]) {
        if(att.name=='TransitionJSONData.json'){//This Block is to update CWP transition JSON according to response has recieved
            system.debug('this block for cwp');
            Map<String, Object> meta = (Map<String, Object>) JSON.deserializeUntyped(att.body.toString());
                        List<Object> sites = (List<Object>)meta.get('site');
                        for(object site:sites){ 
                            Map<String, Object> products=(Map<String, Object>)site;
                            List<Object> productlst = (List<Object>)products.get('productList');
                            for(object product:productlst){
                                Map<String, Object> servs=(Map<String, Object>)product;
                                List<Object> servlst = (List<Object>)servs.get('serviceList');
                                //if (transitionWithStatusmap.containsKey(String.valueof(servs.get('transitionId')))) {
                                    for(object serv:servlst){
                                        Map<String, Object> services=(Map<String, Object>)serv;
                                        List<Object> serviceslst = (List<Object>)services.get('service');
                                        system.debug('valueofServiceList'+services.get('transitionId'));
                                        system.debug('transitionWithStatusmap'+transitionWithStatusmap);
                                        system.debug('TRANSITIIID'+transitionWithStatusmap.containsKey(String.valueof(services.get('transitionId'))));
                                        if (transitionWithStatusmap.containsKey(String.valueof(services.get('transitionId')))) {
                                        for(object service:serviceslst){
                                            Map<String, Object> servicextns=(Map<String, Object>)service;
                                            List<object> extnlist=(List<Object>)servicextns.get('serviceExtension');
                                            system.debug('servicextns'+servicextns);
                                            for(String attributeName : servicextns.keyset()) {
                                                if(attributeName=='Service_Id'){
                                                   // for(String fnnNumber:serviceIdWithStatusmap.keyset()){
                                                system.debug('serviceIdWithStatusmap=='+serviceIdWithStatusmap);
                                                        if(serviceIdWithStatusmap.containskey(String.valueof(servicextns.get('Service_Id')))){
                                                            if(prcidWithTypeMap.get(att.parentid)=='TM1'){
                                                            servicextns.put('eligibilityStatus',serviceIdWithStatusmap.get(String.valueof(servicextns.get('Service_Id'))));
                                                            servicextns.put('eligibilityReason',serviceIdWithDescsmap.get(String.valueof(servicextns.get('Service_Id'))));
                                                        if(serviceIdWithStatusmap.get(String.valueof(servicextns.get('Service_Id')))!='Completed'){
                                                                    eligibilityWithTramasRecordMap.put(transitionIdWithTramasRecordMap.get(String.valueof(services.get('transitionId'))),'Ineligible');//Added for EDGE-151424
                                                        }
                                                        else{
                                                                    eligibilityWithTramasRecordMap.put(transitionIdWithTramasRecordMap.get(String.valueof(services.get('transitionId'))),'Eligible');//Added for EDGE-151424
                                                            }
                                                    }
                                                            else if(prcidWithTypeMap.get(att.parentid)=='TM2'){
                                                                servicextns.put('Reserve_status',serviceIdWithStatusmap.get(String.valueof(servicextns.get('Service_Id'))));
                                                                servicextns.put('Reason',serviceIdWithDescsmap.get(String.valueof(servicextns.get('Service_Id'))));
                                                            }
                                                        }
                                                        else{
                                                            if(prcidWithTypeMap.get(att.parentid)=='TM1'){
                                                                servicextns.put('eligibilityStatus', 'Eligible');
                                                                servicextns.put('eligibilityReason', '');
                                                                eligibilityWithTramasRecordMap.put(transitionIdWithTramasRecordMap.get(String.valueof(services.get('transitionId'))),'Eligible');//Added for EDGE-151424
                                                            }
                                                            else if(prcidWithTypeMap.get(att.parentid)=='TM2'){
                                                                servicextns.put('Reserve_status', 'completed');
                                                                servicextns.put('Reason', '');
                                                            }
                                                        }
                                                  //  }
                                                }
                                                if(extnlist.size()>0){
                                                    for(Object ext:extnlist){
                                                        Map<String, Object> extnsmap=(Map<String, Object>)ext;
                                                        if(attributeName=='Service_Id'){
                                                              // for(String fnnNumber:serviceIdWithStatusmap.keyset()){
                                                                    if(serviceIdWithStatusmap.containskey(String.valueof(servicextns.get('Service_Id')))){
                                                                        if(prcidWithTypeMap.get(att.parentid)=='TM1'){
                                                                            extnsmap.put('eligibilityStatus',serviceIdWithStatusmap.get(String.valueof(servicextns.get('Service_Id'))));
                                                                            extnsmap.put('eligibilityReason',serviceIdWithDescsmap.get(String.valueof(servicextns.get('Service_Id'))));
                                                                        }
                                                                        else if(prcidWithTypeMap.get(att.parentid)=='TM2'){
                                                                            extnsmap.put('Reserve_status',serviceIdWithStatusmap.get(String.valueof(servicextns.get('Service_Id'))));
                                                                            extnsmap.put('Reason',serviceIdWithDescsmap.get(String.valueof(servicextns.get('Service_Id'))));
                                                                        }
                                                            
                                                                    }
                                                                    else{
                                                                        if(prcidWithTypeMap.get(att.parentid)=='TM1'){
                                                                            extnsmap.put('eligibilityStatus', 'Eligible');
                                                                            extnsmap.put('eligibilityReason', '');
                                                                        }
                                                                        else if(prcidWithTypeMap.get(att.parentid)=='TM2'){
                                                                            extnsmap.put('Reserve_status', 'completed');
                                                                            extnsmap.put('Reason', '');
                                                                        }
                                                                    }
//}
                                                            }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
            //attachmentWithIdUpdatemap.put((attachmentWithPCRidmap.get(tramasWithPCRmap.get(tmId))),string.valueof(JSON.serializePretty(meta)));
            attachmentWithIdUpdatemap.put(att.id,string.valueof(JSON.serializePretty(meta)));
            System.debug('***Telstra:TramasEligiblityUpdate:NewJSON'+JSON.serializePretty(meta));
        }
        else if(att.name==system.label.NgUcTransitionName){//This Block is to update NGUC transition JSON according to response has recieved
            system.debug('this block for nguc');
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
                                    boolean groupEligiblityFlag=false; //Added By ankit EDGE-101034
                                Map < String, Object > grpmap = (Map < String, Object > ) gp;
                                List < object > serlst = (List < Object > ) grpmap.get('service');
                                if (transitionWithStatusmap.containsKey(String.valueof(grpmap.get('transitionId')))) {
                                    for (object ser: serlst) {
                                        Map < String, Object > servmap = (Map < String, Object > ) ser;
                                        for (String attributeName: servmap.keyset()) {
                                            if (attributeName == 'Service_Id') {
                                                system.debug('#############' + servmap.get('Service_Id'));
                                                    if (serviceIdWithStatusmap.containskey(String.valueof(servmap.get('Service_Id'))) || transitionTostatusMap.containsKey(String.valueof(grpmap.get('transitionId')))) { //EDGE-203022.
                                                        GroupWrapper wrapper = transitionTostatusMap.get(String.valueof(grpmap.get('transitionId')));
                                                   if(prcidWithTypeMap.get(att.parentid)=='TM1'){
                                                            if((String.valueof(servmap.get('service_association_role'))=='prime' || String.valueof(servmap.get('service_association_role'))=='auxiliary') && transitionTostatusMap.containsKey(String.valueof(grpmap.get('transitionId')))){
                                                                servmap.put('eligibilityStatus', wrapper.status);
                                                               servmap.put('eligibilityReason', wrapper.description);
                                                            }
                                                            
                                                            else{
                                                    servmap.put('Eligibility_status', serviceIdWithStatusmap.get(String.valueof(servmap.get('Service_Id'))));
                                                    servmap.put('eligibilityReason', serviceIdWithDescsmap.get(String.valueof(servmap.get('Service_Id'))));
                                                            }
                                                            
                                                        if(serviceIdWithStatusmap.get(String.valueof(servmap.get('Service_Id')))!='Completed'){
                                                            eligibilityWithTramasRecordMap.put(transitionIdWithTramasRecordMap.get(String.valueof(grpmap.get('transitionId'))),'Ineligible');//Added for EDGE-151424
                                                        }else{
                                                            eligibilityWithTramasRecordMap.put(transitionIdWithTramasRecordMap.get(String.valueof(grpmap.get('transitionId'))),'Eligible');//Added for EDGE-151424
                                                             GroupEligiblityFlag=true;//Added By ankit EDGE-101034


                                                         }
                                                   }
                                                   else if(prcidWithTypeMap.get(att.parentid)=='TM2'){
                                                            if((String.valueof(servmap.get('service_association_role'))=='prime' || String.valueof(servmap.get('service_association_role'))=='auxiliary') && transitionTostatusMap.containsKey(String.valueof(grpmap.get('transitionId')))){
                                                                servmap.put('Reserve_status',wrapper.status);
                                                                servmap.put('Reason',wrapper.description);
                                                            }
                                                            else{
                                                                System.debug('servmap: '+servmap);
                                                    servmap.put('Reserve_status',serviceIdWithStatusmap.get(String.valueof(servmap.get('Service_Id'))));
                                                    servmap.put('Reason',serviceIdWithDescsmap.get(String.valueof(servmap.get('Service_Id'))));
                                                    }
                                                            
                                                    }
                                                    } 
                                                    //Kalashree Borgaonkar. Set error message for TM1/TM2 
                                                    else if(serviceIdWithStatusmap.isEmpty() && String.valueof(grpmap.get('checkValue'))=='true' && errorResponse !='' ){
                                                        if(prcidWithTypeMap.get(att.parentid)=='TM1'){
                                                            servmap.put('Eligibility_status', 'Failed');
                                                                servmap.put('eligibilityReason',errorResponse);
                                                            eligibilityWithTramasRecordMap.put(transitionIdWithTramasRecordMap.get(String.valueof(grpmap.get('transitionId'))),'Ineligible');//Added for EDGE-151424 
                                                        } 
                                                        else{
                                                             servmap.put('Reserve_status', 'Failed');
                                                                servmap.put('Reason', errorResponse);
                                                            eligibilityWithTramasRecordMap.put(transitionIdWithTramasRecordMap.get(String.valueof(grpmap.get('transitionId'))),'Ineligible');//Added for EDGE-151424 
                                                        }
                                                    }
                                                    else {
                                                        system.debug('Reached here due to  completed status'+transitionWithStatusmap);
                                                    if((transitionWithStatusmap.get(String.valueof(grpmap.get('transitionId')))==eligibleText)||(transitionWithStatusmap.get(String.valueof(grpmap.get('transitionId')))==completedText)){//EDGE-156518 fix && EDGE-158682 Fix
                                                    if(prcidWithTypeMap.get(att.parentid)=='TM1'){
                                                        servmap.put('Eligibility_status', 'Eligible');
                                                        servmap.put('eligibilityReason', '');
                                                         eligibilityWithTramasRecordMap.put(transitionIdWithTramasRecordMap.get(String.valueof(grpmap.get('transitionId'))),'Eligible');//Added for EDGE-151424
                                                         GroupEligiblityFlag=true;//Added By ankit EDGE-101034
                                                    }
                                                    else if(prcidWithTypeMap.get(att.parentid)=='TM2'){
                                                        servmap.put('Reserve_status', 'Completed');
                                                        servmap.put('Reason', '');
                                                    }
                                                    }
                                                }
                                                List<object> servextlst=(List<object>) servmap.get('serviceExtensions');
                                                system.debug('valueofServiceExt'+servextlst);
                                                for(object servExt:servextlst){
                                                    Map < String, Object > serExtmap = (Map < String, Object > ) servExt;
                                                        System.debug('transitionTostatusMap: '+transitionTostatusMap);
                                                        //if (serviceIdWithStatusmap.containskey(String.valueof(servmap.get('Service_Id')))) { //EDGE-203022. Kalashree Condition changed
                                                        if (transitionTostatusMap.containsKey(String.valueof(grpmap.get('transitionId')))) {
                                                            GroupWrapper wrapper = transitionTostatusMap.get(String.valueof(grpmap.get('transitionId')));
                                                         if(prcidWithTypeMap.get(att.parentid)=='TM1'){
                                                                serExtmap.put('eligibilityStatus', wrapper.status);
                                                                serExtmap.put('eligibilityReason', wrapper.description);
                                                         }
                                                        else if(prcidWithTypeMap.get(att.parentid)=='TM2'){
                                                                serExtmap.put('Reserve_status', wrapper.status);
                                                                serExtmap.put('Reason', wrapper.description);
                                                        }
                                                    } 
                                                    else {
                                                        system.debug('Reached here due to not completed status'+transitionWithStatusmap);
                                                        if((transitionWithStatusmap.get(String.valueof(grpmap.get('transitionId')))==eligibleText)||(transitionWithStatusmap.get(String.valueof(grpmap.get('transitionId')))==completedText)){//EDGE-156518 fix && EDGE-158682 Fix
                                                        if(prcidWithTypeMap.get(att.parentid)=='TM1'){
                                                            serExtmap.put('eligibilityStatus', 'Eligible');
                                                            serExtmap.put('eligibilityReason', '');
                                                        }
                                                        else if(prcidWithTypeMap.get(att.parentid)=='TM2'){
                                                            serExtmap.put('Reserve_status', 'Completed');
                                                            serExtmap.put('Reason', '');
                                                        }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        // EDGE-101034 Added by ankit ||strat
                                        if(GroupEligiblityFlag==true && prcidWithTypeMap.containsKey(att.parentid) && prcidWithTypeMap.get(att.parentid)=='TM1'){
                                            grpmap.put('EligibilityStatus','Eligible');
                                        }else if (prcidWithTypeMap.containsKey(att.parentid) && prcidWithTypeMap.get(att.parentid)=='TM1'){
                                            //EDGE-198376:To get group level eligibility status and reason
                                            system.debug('transitionId**'+String.valueof(grpmap.get('transitionId')));
                                            
                                            GroupWrapper wrapper = transitionTostatusMap.get(String.valueof(grpmap.get('transitionId')));
                                            system.debug('wrapper**'+wrapper);

                                            if(wrapper!=null && errorResponse ==''){//INC000096528422 Fix

                                            grpmap.put('EligibilityStatus',wrapper.status);                                            
                                            grpmap.put('EligibilityReason',wrapper.description);
                                                
                                            }
                                            else{
                                                grpmap.put('EligibilityStatus','Failed');                                            
                                            grpmap.put('EligibilityReason',errorResponse);
                                            eligibilityWithTramasRecordMap.put(transitionIdWithTramasRecordMap.get(String.valueof(grpmap.get('transitionId'))),'Ineligible');//Added for EDGE-151424 

                                    }

                                    }

                                    // EDGE-101034 Added by ankit ||end
                                }
                            }
                        }
                    }
                }
                system.debug('finalJSON' + string.valueof(JSON.serializePretty(meta)));
                system.debug('eligibilityWithTramasRecordMap'+eligibilityWithTramasRecordMap);
                //attachmentWithIdUpdatemap.put(att.id, string.valueof(JSON.serializePretty(meta)));
                attachmentWithIdUpdatemap.put(att.id,string.valueof(JSON.serializePretty(meta)));
        }
    }
        
          if(attachmentWithIdUpdatemap.size()>0){
             List<Attachment> listAttachment = new List<Attachment>();
            List<attachment> dltlist= new List<attachment>();
            map<string, string> attachmentPCR = new map<string, string>();
           //START OF DIGI-5234:21.11 SIT Fix: Declared attachment outside FOR loop:
           //Multiple NGUC transition data issue: Zeeshan/Ramya
            Attachment att = new Attachment();
            //END OF DIGI-5234:21.11 SIT Fix: Multiple NGUC transition data issue: Zeeshan/Ramya
            for(attachment attloop:[Select id,Parentid,name,body,description 
            from attachment where id in:attachmentWithIdUpdatemap.keyset()]){

                att.Name =  attloop.name;//'TransitionJSONData.json';
                att.ParentId = attloop.Parentid;
                att.Body = blob.valueof(attachmentWithIdUpdatemap.get(attloop.id));
                listAttachment.add(att);
                dltlist.add(attloop);
               // attachmentPCR.put(attloop.Parentid, attloop.body.tostring());
            }
            if(listAttachment.size()>0){
                if (listAttachment.size() > 0 && Schema.sObjectType.Attachment.isDeletable()){	
                delete dltlist;
                }
               // if (listAttachment.size() > 0 && Schema.sObjectType.Attachment.isCreateable()){
                   //START OF DIGI-5234:21.11 SIT Fix: Multiple NGUC transition data issue: Zeeshan/Ramya
                if (att!=null && att.Name!=null && Schema.sObjectType.Attachment.isCreateable()){	
               // insert listAttachment;
               insert att;
               //END OF DIGI-5234:21.11 SIT Fix: Zeeshan/Ramya
                }
                //Map<String,String>attachmentPCR1 = new Map<String,String>();
                map<string, string> mapPCAttachment = new map<string, string>();
                for(Attachment attRec :listAttachment){
                    attachmentPCR.put(attRec.Parentid,attRec.Id);
                }
                 String basketId;
                 for(cscfga__Product_Configuration__c pc : [SELECT ID,cscfga__Product_Basket__c,
                                                            (SELECT Id FROM TramasElgibilityCallbackResponses__r where Type__c ='TM1')
                                                            FROM cscfga__Product_Configuration__c
                                                           // (SELECT Id FROM TramasElgibilityCallbackResponses)
                                                            WHERE ID IN : attachmentPCR.keySet()]){
                 basketId = pc.cscfga__Product_Basket__c;
                if(pc!= null){
                    if(!pc.TramasElgibilityCallbackResponses__r.IsEmpty()){
                    if (attachmentPCR.get(pc.Id) != ''){
                        mapPCAttachment.put(pc.Id,attachmentPCR.get(pc.Id) );
                    }
                }
                }
            }
                System.debug('eligibilityWithTramasRecordMap: '+eligibilityWithTramasRecordMap);
            if(eligibilityWithTramasRecordMap.size()>0){
                    TramasEligiblityUpdate.updateTramasRecord(eligibilityWithTramasRecordMap);
                }
                TramasEligiblityUpdate.firePlatformEventTramas(basketId,mapPCAttachment);
            }
          }
        
        logger2.logMessages(loggerReq, loggerRes, '', '', '', '', false, false, statusCode, null, null, null);//EDGE-203022. Kalashree. Added for creating application logs
	}
		catch (Exception ex){
            Map<String, Object> eLogMap = new Map<String, Object>();
            eLogMap.put('capability', CONST_CAPABILITY);
            eLogMap.put('interfaceName', CONST_INTERFACENAME);
            eLogMap.put('elementName', 'tramasAttachmentsUpdateNew');
            eLogMap.put('referenceNumber', '');
            eLogMap.put('correlationId', correlationId);
            eLogMap.put('errorDescription', ex.getMessage());
            eLogMap.put('businessDescription', 'read response of callback');
            C2O_Utilities.logException(eLogMap, false);
            //logException('tramasAttachmentsUpdateNew', '', correlationId, ex.getMessage(), 'read response of callback');
        
    }
    }
    //EDGE-203022
    public class GroupWrapper{
        String description;
        String status;
    }
	/**
     * @description Exception Handling Framework 
       */
		/*private static void logException(String methodName, String referenceNumber, String correlationId, String errorMessage, String businessDescription){
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
    
    private static void logException(String severity, string methodName, String referenceNumber, String endpointURL, 
    String integrationPayload, String correlationId, String httpStatusCode, String errorCode, 
    String errorMessage,  String responseMessage, String destinationSystem, 
    String sourceName, String businessDescription, String errorCategory) {
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
       }*/
}