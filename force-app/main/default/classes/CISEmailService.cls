public with sharing class CISEmailService {
    public static final String IN_PROGRESS = 'In Progress';
    public static final String SENT = 'Sent';
    public static final String ERROR = 'Error';
    //Manoj : EDGE-98247 :
    public static final String ConnectedWorkplace = 'Connected Workplace';
    public static final String MDMOffer = 'MDM Offer';
    //DIGI-3352 B2B-1762 - Offer Name Change
    public static final String NGUC_OFFER_NAME = Offer_Id__mdt.getInstance('Telstra_Collaboration')?.Template_family__c;
    //public static final String TC_Offer = 'Telstra Collaboration';
    public static final String TC_Offer = NGUC_OFFER_NAME;
    public static final String TID_Offer = 'Telstra Internet Direct';//EDGE-117742
    public static final String Adaptive_Mobility = 'Adaptive Mobility';//EDGE-207342
    public static final String CIS_AdaptiveMobility = 'CIS_AdaptiveMobility';//EDGE-207342
    public static final String IoT_Connectivity = 'IoT Connectivity';
    //Murli : DPG-753
    public static final String IoT_Offer = Label.IoTOfferName;
    public static final String CIS_MDM = 'CIS_MDM';
    public static final String CIS_Connected_Workplace = 'CIS_Connected_Workplace';
    public static final String CIS_TelstraCollaboration = 'CIS_TelstraCollaboration';
    public static final String CIS_IoTConnectivity = 'CIS_IoTConnectivity';
    //Murli : DPG-753
    public static final String CIS_InternetofThings = 'CIS_InternetofThings';
    public static final String CIS_TID = 'CIS_TID';//EDGE-117742
    @InvocableMethod(label='Send CIS Notification' description='Send CIS Notification when Contract move to In Signature')
   public static void processCISMail(List<Id> ContractId){
System.debug('Send_CIS_for_Contract ....'+EnvironmentVariable__c.getValues('Send_CIS_for_Contract').Value__c);
        if(EnvironmentVariable__c.getValues('Send_CIS_for_Contract').Value__c=='True'){
            String soqlForData = 'select Account__c,IsCISGenerated__c,Customer_Primary_Contact__r.FirstName,Customer_Primary_Contact__r.Email,Related_Opportunity__r.Owner.Name,Related_Opportunity__r.Owner.Phone,Related_Opportunity__r.Owner.Email,Related_Opportunity__r.Owner.MobilePhone,CIS_Dispatched_Offers__c,Account__r.YTD_Total_Revenue__c from ContractJunction__c where id IN :ContractId';
            List<ContractJunction__c> CJList = Database.query(soqlForData);
   System.debug('CJList... '+CJList[0]);            
            System.debug('isCSILinked '+isCSILinkedToAccountWithOffers(CJList[0].Account__c,'check',CJList[0].CIS_Dispatched_Offers__c));
        System.debug(CJList[0].Account__r.YTD_Total_Revenue__c);
            System.debug(CJList[0].CIS_Dispatched_Offers__c);
            //EDGE-98247 : Manoj Kumar : added CIS_Dispatched_Offers__c check
            //Murli : DPG-753           
            //EDGE-117742 Added condition for TID  
            //EDGE-207342 Added Adoptive Mobility Product Family
            if((CJList[0].CIS_Dispatched_Offers__c.contains(ConnectedWorkplace) || CJList[0].CIS_Dispatched_Offers__c.contains(MDMOffer) || CJList[0].CIS_Dispatched_Offers__c.contains(TC_Offer) || CJList[0].CIS_Dispatched_Offers__c.contains(IoT_Offer) || CJList[0].CIS_Dispatched_Offers__c.contains(TID_Offer) || CJList[0].CIS_Dispatched_Offers__c.contains(Adaptive_Mobility) || CJList[0].CIS_Dispatched_Offers__c.contains(IoT_Connectivity)) && isCSILinkedToAccountWithOffers(CJList[0].Account__c,'check',CJList[0].CIS_Dispatched_Offers__c)==false &&
            //if(CJList[0].CIS_Dispatched_Offers__c != offerName && isCSILinkedToAccountWithOffers(CJList[0].Account__c,'check',CJList[0].CIS_Dispatched_Offers__c)==false &&
            (CJList[0].Account__r.YTD_Total_Revenue__c<=Decimal.valueof(system.label.CIS_YTD_Total)|| CJList[0].Account__r.YTD_Total_Revenue__c==null)){
            EmailDTO emailDto = createEmailDTO(CJList);
            System.debug('emailDto '+emailDto);
            IntegrationRecordHandlerUtil.createRequests('CISEmailHandler', new List<String>{emailDto.relatedtoId+':'+emailDto.toEmails[0]},JSON.serialize(emailDto));
        }
        else
            System.debug('CIS already sent to this account for offers:'+CJList[0].CIS_Dispatched_Offers__c);     
        }       
    } 
    public static EmailDTO createEmailDTO(List<ContractJunction__c> ContractId){
        //String soqlForData = 'select Customer_Primary_Contact__r.FirstName,Customer_Primary_Contact__r.Email,Related_Opportunity__r.Owner.Name,Related_Opportunity__r.Owner.Phone,Related_Opportunity__r.Owner.Email,Related_Opportunity__r.Owner.MobilePhone from ContractJunction__c where id IN :ContractId';
        //List<ContractJunction__c> CJList = Database.query(soqlForData);
        String fromEmail = null;
        List<String> toEmails = new List<String>{ContractId[0].Customer_Primary_Contact__r.Email};
        String templateId='';
        String relatedtoId = ContractId[0].id; // should hold contractjunction-id
        if(Test.isRunningTest())
        {
            System.debug('In test');
            templateId ='CISEmailHandler';
        }
        else    
            templateId = system.Label.CISCommunicationForContract;
        String subject = 'Your Critical Information Summary';
        //Manoj Kumar : EDGE-98247 : setting attachment ID based on : CIS_Dispatched_Offers__c field : Start
        ContractJunction__c conRec = [SELECT Id, CIS_Dispatched_Offers__c FROM ContractJunction__c WHERE Id =:relatedtoId LIMIT 1]; 
        Map <String,String> congaTempRecMap = fetchAttachmentId();
        List<id> attachmentIds = new List<Id>();
        if(conRec != null){
              if(conRec.CIS_Dispatched_Offers__c.Contains(ConnectedWorkplace)){
                attachmentIds.add(congaTempRecMap.get(CIS_Connected_Workplace));
               }
         if(conRec.CIS_Dispatched_Offers__c.Contains(MDMOffer)){
                     attachmentIds.add(congaTempRecMap.get(CIS_MDM));
               }
         if(conRec.CIS_Dispatched_Offers__c.Contains(TC_Offer)){
                 attachmentIds.add(congaTempRecMap.get(CIS_TelstraCollaboration));
            }
        //Murli : DPG-753
         if(conRec.CIS_Dispatched_Offers__c.Contains(IoT_Offer)){
                 attachmentIds.add(congaTempRecMap.get(CIS_InternetofThings));
            }
         //EDGE-117742
         if(conRec.CIS_Dispatched_Offers__c.Contains(TID_Offer)){
                 attachmentIds.add(congaTempRecMap.get(CIS_TID));
            }
         //EDGE-207342
        if(conRec.CIS_Dispatched_Offers__c.Contains(Adaptive_Mobility)){
                 attachmentIds.add(congaTempRecMap.get(CIS_AdaptiveMobility));
            }
        if(conRec.CIS_Dispatched_Offers__c.Contains(IoT_Connectivity)){
            attachmentIds.add(congaTempRecMap.get(CIS_IoTConnectivity));
        } 
                  
        }
        System.debug('attachmentIds **'+attachmentIds);
       // List<id> attachmentIds = new List<String>{system.label.CIS_Attachment_Id}; 
        //Manoj Kumar : End
        String entityType = 'NOT_APPLICABLE';
        String entityId = 'NOT_APPLICABLE';
        String notificationEventType ='EDGESF_ORDER_2'; //need to check with Ravi
        String msisdn = '';
        Map<String, String> otherKayValues = null;
        EmailDTO emailDTO = new EmailDTO(fromEmail, toEmails, null, null, templateId, subject, attachmentIds, entityType, entityId , notificationEventType, msisdn, relatedtoId, otherKayValues);
        try{
             EmailTransformer.fromEmailDToToEmailRequest(emailDTO);
        }
        Catch(Exception Ex){
            System.debug('Exception caught '+Ex.getMessage());
        }
        return emailDTO;
    }
     //This method is for intergration handler to use
    @future(callout=true)
    public static void sendEmail(String param) {
    System.debug('--Send Email--'+param);
    String handlerName = 'CISEmailHandler';
      Logger2 logger2 = Logger2.getLogger(handlerName);
        Integration_Record__c paramRequest = [SELECT Id, params__c, paramPayload__c
                                                            FROM Integration_Record__c
                                                            WHERE params__c = :param order by CreatedDate desc LIMIT 1 ];
        system.debug('paramRequest -->' + paramRequest);
        String emailDtoJson =  paramRequest.paramPayload__c;
        System.debug('-------------> emailDtoJson ' + emailDtoJson);
        EmailDTO dto = (EmailDTO) JSON.deserialize(emailDtoJson, EmailDTO.class);
        String token = AuthenticationManager.getOauthToken(CISEmailHandler.class.getName());
        Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json',
                                                               'Authorization'=> 'Bearer '+token};
        //EDGE-132483 Fix start from Here
        String Correlation_id=IntegrationRecordHandlerUtil.getCorrelationId();
        EmailRequest emailReq;
               try{
                   emailReq = EmailTransformer.fromEmailDToToEmailRequest(dto);
                   emailReq.correlationId =Correlation_id;
               } Catch(Exception Ex){
               }
       // EmailRequest emailReq = EmailTransformer.fromEmailDToToEmailRequest(dto);
        System.debug('----------> sendEmail payload ' + JSON.serialize(emailReq));
        HTTPResponse reponse = IntegrationRecordHandlerUtil.callout(JSON.serialize(emailReq),
                                                               IntegrationRecordHandlerUtil.HTTP_METHOD_POST,
                                                                    headerMap, CISEmailHandler.class.getName(), new List<String>{param},Correlation_id);
          //EDGE-132483 Fix End Here  
        System.debug('Response:'+reponse);
        if(reponse != null && reponse.getStatusCode() == IntegrationRecordHandlerUtil.HTTP_ACCEPTED) { //Request was successfully accepted
            EmailResponse emailRes = (EmailResponse) JSON.deserialize(reponse.getBody(), EmailResponse.class);
            System.debug('CreateEM'+emailRes.correlationId);
            createEmailMessage(dto, SENT, emailRes.correlationId);
          logger2.logMessages(JSON.serialize(emailReq), reponse.getBody(), '', '', '', '', false, false, Integer.valueOf(reponse.getStatusCode()) , null, null, null);
        } else {
            System.debug('-------------->>>>>>> ERROR sending email');
            String corId='';
            String errorMsg='';
            if(reponse != null && !String.isEmpty(reponse.getBody())) {
                EmailResponse emailRes = (EmailResponse) JSON.deserialize(reponse.getBody(), EmailResponse.class);
                corId = emailRes.correlationId;
                errorMsg = ': Email Sent request failed with code ' + reponse.getStatusCode() + ' and error ' + reponse.getBody();
            logger2.logMessages(JSON.serialize(emailReq), reponse.getBody(), '', '', '', '', false, false, Integer.valueOf(reponse.getStatusCode()) , null, null, null);
            } else {
                errorMsg = ': Email Sent request failed';
                logger2.logMessages(JSON.serialize(emailReq), null, '', '', '', '', false, false, null , null, null, null);
            }
            createEmailMessage(dto, ERROR, corId);
            //updateContractJunction(dto); //update CIS-flag on contractjunction to true when CIS-mail-request is sent
        }
        logger2.exitLogger();
    }
    public static Boolean isCSILinkedToAccountWithOffers(Id recordId,String mthod,String offerlist){
     if(mthod=='check'){    
        Set<String> CISsentOffers = new Set<String>();
         for(ContractJunction__c cjloop:[select id,name,CIS_Dispatched_Offers__c,Status__c from ContractJunction__c where Account__c =:recordId and IsCISGenerated__c =true]){
             if(cjloop.Status__c!='Cancelled')
             CISsentOffers.add(cjloop.CIS_Dispatched_Offers__c);
         }
        //INC000092359622 --Changes Start from Here
         String fixAfter=(CISsentOffers.toString()).replace(';', ',');
         system.debug('offerlist'+offerlist);
         system.debug('CISsentOffers'+CISsentOffers);
         for(String s:offerlist.split(';')){
             system.debug('valueofS'+s);
             
             if(!fixAfter.contains(s) && (s.Contains(ConnectedWorkplace) || s.Contains(MDMOffer) || s.Contains(TC_Offer) || s.Contains(IoT_Offer) || s.Contains(TID_Offer)|| s.Contains(Adaptive_Mobility) || s.Contains(IoT_Connectivity))){//EDGE-207342 added Adaptive Mobility
             return false;
             }  
         }
         //INC000092359622 --Changes Ehd Here
         return true;
     }
     if(mthod=='update'){
            ContractJunction__c cjupdate=[select id,IsCISGenerated__c from ContractJunction__c where id=:recordId];
            cjupdate.IsCISGenerated__c=true;
            update cjupdate;
        return true;
     }
     system.debug('valueof 175true');
     return false;
    }
    @TestVisible
    private static EmailMessage createEmailMessage(EmailDto dto, String status, String correlationId) {
        EmailMessage emailMsg = new EmailMessage();
        emailMsg.FromAddress = dto.fromEmail;
        emailMsg.ToAddress = dto.toEmails.get(0);
        emailMsg.Subject = dto.subject;
        emailMsg.status__c = status;
        emailMsg.status = '0';
        emailMsg.TextBody = '';
        emailMsg.Correlation_Id__c = correlationId;
        ID recordId=Id.valueOf(dto.relatedtoId);
        if(recordId.getSObjectType().getDescribe().getName() =='ContractJunction__c')
            emailMsg.HtmlBody = EmailUtils.cisEmailBodyByTemplateId(dto.templateId,dto.relatedtoId, dto.toEmails);
        emailMsg.RelatedtoId = dto.relatedtoId;
        emailMsg.IsExternallyVisible = true;
        insert emailMsg;
        if(recordId.getSObjectType().getDescribe().getName() =='ContractJunction__c'){
            List<Attachment> attlist= new List<Attachment>();
             //Manoj Kumar : EDGE-98247 : creating attachment record based on CIS_Dispatched_Offers__c field value : Start
            ContractJunction__c conRec = [SELECT Id, CIS_Dispatched_Offers__c FROM ContractJunction__c WHERE Id =:recordId LIMIT 1]; 
            Map <String,String> congaTempRecMap = fetchAttachmentId();
            Set<Id> attIdSet = new Set<Id>();
            List<Attachment> att_List = new List<Attachment>();
            if(conRec != null){
                if(conRec.CIS_Dispatched_Offers__c.Contains(ConnectedWorkplace)){
                    attIdSet.add(congaTempRecMap.get(CIS_Connected_Workplace));
                }
                if(conRec.CIS_Dispatched_Offers__c.Contains(MDMOffer)){
                    attIdSet.add(congaTempRecMap.get(CIS_MDM));
                }
                if(conRec.CIS_Dispatched_Offers__c.Contains(TC_Offer)){
                    attIdSet.add(congaTempRecMap.get(CIS_TelstraCollaboration));
                }
                if(conRec.CIS_Dispatched_Offers__c.Contains(Adaptive_Mobility)){
                    attIdSet.add(congaTempRecMap.get(CIS_AdaptiveMobility));
                }
                if(conRec.CIS_Dispatched_Offers__c.Contains(IoT_Connectivity)){
                    attIdSet.add(congaTempRecMap.get(CIS_IoTConnectivity));
                }
            }
            if(!attIdSet.IsEmpty()){
                  att_List = [SELECT Body,BodyLength,ContentType,Name,ParentId FROM Attachment WHERE Id in :attIdSet ];
                  System.debug('att_List '+att_List);
            }
            //Manoj Kumar : End
            if(!att_List.IsEmpty()){
            for(Attachment att: att_List){
                Attachment atnew=new Attachment();
                atnew.Body=att.Body;
                atnew.ContentType=att.ContentType;
                atnew.Name=att.Name;
                atnew.ParentId=emailMsg.id;
                attlist.add(atnew);
            }
            }
            EmailMessage  em=[SELECT ActivityId FROM EmailMessage where id=:emailMsg.id];
            map<id,task> taskmap= new map<id,task>();
            for(Task tsk:[select id,Status from Task where id=:em.ActivityId]){
                tsk.Status='Completed';
                taskmap.put(tsk.id,tsk);
            }
            Boolean contractUpdate=isCSILinkedToAccountWithOffers(recordId,'update','');
            if(contractUpdate==true){
                if(attlist.size()>0)
                    insert attlist;
                if(taskmap.size()>0)
                    update taskmap.values();
              }
        }
        System.debug('EM:'+emailMsg.FromAddress);
        return emailMsg;
    }
     /* ****************************************************************************
* Author : Manoj Kumar : EDGE-98247
* Date : 08 Aug 2019
* Description : fetch CongaEmailTemplateAttachment__mdt metadata records
* Return Type: Map of String,String 
* *****************************************************************************/
    public Static Map<String,String> fetchAttachmentId() {
         List<CongaEmailTemplateAttachment__mdt> congaTempRecList = [SELECT DeveloperName,RecordId__c FROM CongaEmailTemplateAttachment__mdt];
        Map<String,String> congaTempRecMap = new Map<String,String>();
            if(!congaTempRecList.IsEmpty()){
                for(CongaEmailTemplateAttachment__mdt conga : congaTempRecList){
                    congaTempRecMap.put(conga.DeveloperName,conga.RecordId__c);
                }
            }
        return congaTempRecMap;
    }
}