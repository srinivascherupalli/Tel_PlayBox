/***************************************************************************************************************************
*Class Name : EmailTransformer
*Description: To get Email Request called from EmailService
*Code refactoring as a part of EDGE-109480
1. Shreya Jaiswal    QA2 Test Fail Fix  18/11/2019
2. Shreya Jaiswal    QA2 Fix for cc value (EDGE-125017)  25/11/2019
3. Pradeep     extended attachment feature for Billing Enquiry  04/09/2020
4. Vishal Arbune     EDGE-169633 : Use NOTIFY to send an FYI email with Order form to the customer
5. Vishal Arbune     INC000094907583       AM Pilot: the file that is sent to the customer has '.docx.docx'
****************************************************************************************************************************/

public with sharing class EmailTransformer {
    
    public static EmailRequest fromEmailDToToEmailRequest(EmailDto emailDto) {
        //populate Recipient info
        //EDGE-36289-------------------
        EmailRequest.Recipient toEmailRecipient = new EmailRequest.Recipient();
        List<EmailRequest.Recipient> toEmailRecipientList = new List<EmailRequest.Recipient>();
        EmailRequest.Recipient ccEmailRecipient = new EmailRequest.Recipient();
        List<EmailRequest.Recipient> ccEmailRecipientList = new List<EmailRequest.Recipient>();
        EmailRequest.Recipient bccEmailRecipient = new EmailRequest.Recipient();
        List<EmailRequest.Recipient> bccEmailRecipientList = new List<EmailRequest.Recipient>();
        EmailRequest emailReq = new EmailRequest();
        
        try{
            emailReq.entityType = emailDto.entityType;
                emailReq.notificationEventType = emailDto.notificationEventType; 
            emailReq.entityId = emailDto.entityId;
            for(String emails:emailDto.toEmails){
            toEmailRecipient = new EmailRequest.Recipient();
            toEmailRecipient.emailAddress = emails;
            toEmailRecipient.msisdn = emailDto.msisdn;
            toEmailRecipient.emailDeliveryType ='TO';
            toEmailRecipientList.add(toEmailRecipient);
      }
         //Fix QA2 Test fail by Shreya on 18Nov19
          if(emailDto.ccEmails!=null){  
      for(String emails:emailDto.ccEmails){
        ccEmailRecipient = new EmailRequest.Recipient();
        ccEmailRecipient.emailAddress = emails;
                ccEmailRecipient.emailDeliveryType='CC';
                ccEmailRecipient.msisdn = emailDto.msisdn;
                //Fix for cc value (EDGE-125017)
        ccEmailRecipientList.add(ccEmailRecipient);
      }
          }
        //Fix QA2 Test fail by Shreya on 18Nov19
          if(emailDto.bccEmails!=null){
      for(String emails:emailDto.bccEmails){
        bccEmailRecipient = new EmailRequest.Recipient();
        bccEmailRecipient.emailAddress = emails;
                bccEmailRecipient.msisdn = emailDto.msisdn;
                bccEmailRecipient.emailDeliveryType ='BCC';
        bccEmailRecipientList.add(bccEmailRecipient);
      }
      }
            List<EmailRequest.Recipient> recs = new List <EmailRequest.Recipient>();
            
            //Changes Start from here//
      if(!toEmailRecipientList.isEmpty()){
        recs.addAll(toEmailRecipientList);
      }
      if(!ccEmailRecipientList.isEmpty()){
        recs.addAll(ccEmailRecipientList);
      }
      if(!bccEmailRecipientList.isEmpty()){
        recs.addAll(bccEmailRecipientList); 
      }
            emailReq.recipients=recs;
            //EDGE-157963: Handled file attachments for case billing enquiry for resolved status 
            //populate Attachment info
            system.debug('****line 71***'+emailDto);
            if(emailDto != null && emailDto.attachmentIds != null && emailDto.attachmentIds.size() > 0) {
                system.debug('****line 73***'+emailDto.attachmentIds);
                EmailRequest.AttachmentParameters fileParam =new EmailRequest.AttachmentParameters();
                List<EmailRequest.AttachmentParameters> attParams = new List<EmailRequest.AttachmentParameters>(); 
                List<Attachment> atts = [SELECT body, contenttype, Name FROM Attachment WHERE id in :emailDto.attachmentIds];
                List<ContentVersion> contentVersionList;
                contentVersionList=[SELECT id,Title,ContentSize,FileType,FileExtension,VersionData,internal__c FROM ContentVersion where ContentDocumentId in :emailDto.attachmentIds];
                Map<String,String> mapType=new Map<String,String>();    
                Notification_File_Type__mdt[] notifyType = [SELECT DeveloperName,ContentType__c FROM Notification_File_Type__mdt];
                for (Notification_File_Type__mdt notifyMap : notifyType) {
                mapType.put(notifyMap.DeveloperName,notifyMap.ContentType__c);      
                 } 
                for(Attachment att :  atts){
                    Blob attachmentbod=att.body;
                    EmailRequest.AttachmentParameters attParam = new EmailRequest.AttachmentParameters();
                    attParam.binaryContent = EncodingUtil.base64Encode(attachmentbod);
                    attParam.contentType  = att.contenttype;
                    attParam.filename = att.Name;
                    attParams.add(attParam);
                }
               
               //EDGE-169633 : Added notification Event Type in check
                if (emailDto.notificationEventType == 'B2B_U2C_CHOWN' || emailDto.notificationEventType == System.Label.Billing_Enquiry_Event_Type_Resolved || emailDto.notificationEventType == System.Label.B2B_P2O_ORDER_REQUEST)  {              
                for (ContentVersion ExtFiles: contentVersionList) 
                        {
                        fileParam = new EmailRequest.AttachmentParameters();
                        fileParam.binaryContent=EncodingUtil.base64Encode(ExtFiles.VersionData);
                        String extension=ExtFiles.FileExtension;
                            if (!String.isBlank(extension)){
                        fileParam.contentType  = mapType.get(extension.toLowerCase());  }
                        //INC000094907583
                        //fileParam.filename = ExtFiles.Title+'.'+ExtFiles.FileExtension;
                        if(ExtFiles.Title.contains(ExtFiles.FileExtension)){
                        	fileParam.filename = ExtFiles.Title;
                        }else{
                            fileParam.filename = ExtFiles.Title+'.'+ExtFiles.FileExtension;
                        }                       
                        attParams.add(fileParam);
                        }
                }
                emailReq.AttachmentParameters = attParams;
            }
            
            //populate ContentParameter info
            List<EmailRequest.ContentParameters> contentParams = new List<EmailRequest.ContentParameters>();
            if(emailDto != null && !String.isEmpty(emailDto.subject)) {
                System.debug('-------> emailDto.subject  ' + emailDto.subject);
                EmailRequest.ContentParameters cpSubject = new EmailRequest.ContentParameters();
                cpSubject.name = 'email_subject';
                cpSubject.value = emailDto.subject;
                contentParams.add(cpSubject);
            }
            
            if(emailDto != null && emailDto.templateId != null) {
                System.debug('-------> emailDto.templateId  ' + emailDto.templateId);
                EmailRequest.ContentParameters cpBody = new EmailRequest.ContentParameters();
                cpBody.name = 'email_body';
                //start EDGE-49450
                ID recordId=Id.valueOf(emailDto.relatedtoId);
                if(recordId.getSObjectType().getDescribe().getName() =='ContractJunction__c')
                {cpBody.value = EmailUtils.cisEmailBodyByTemplateId(emailDto.templateId, emailDto.relatedtoId, emailDto.toEmails);
                }
                //end EDGE-49450
                else            
                    cpBody.value = EmailUtils.emailBodyByTemplateId(emailDto.templateId, emailDto.relatedtoId, emailDto.toEmails);
                contentParams.add(cpBody);
            }
            
            if(emailDto != null && emailDto.otherKayValues != null && emailDto.otherKayValues.size() > 0) {
                for(String key : emailDto.otherKayValues.keySet()) {
                    EmailRequest.ContentParameters cpKV = new EmailRequest.ContentParameters();
                    cpKV.name = key;
                    cpKV.value = emailDto.otherKayValues.get(key);
                    contentParams.add(cpKV);
                }
            }
            
            System.debug('--------> contentParams ' + contentParams.size());
            emailReq.ContentParameters = contentParams; }catch(Exception e){System.debug('Exception in fromEmailDToToEmailRequest :: '+e.getMessage()+' > ' +e.getLineNumber()+ ' > '+e.getStackTraceString());throw e;
        }
        
        return emailReq;
    }
    
}