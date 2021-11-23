// EDGE-191531 and EDGE-198578 user stories.
// Created SendCaseWebFormEmailService class to send Email from Flow using 'SendCaseWebFormEmailServices' flow.
// Refer EmailTransformer class for attachments

public with sharing class SendCaseWebFormEmailService{   
    //class to get multiple inputs from flow    
    public class flowInput {                    
        @InvocableVariable(required=true)   
        public String outGoingEmail;    
            
        @InvocableVariable(required=true)   
        public String inComingEmail;    
            
        @InvocableVariable(required=true)   
        public string currentCaseId;    
            
        @InvocableVariable(required=true)   
        public List<Id> docid;  
            
    }   
    //invocable method  
    @InvocableMethod(label='Email with Attachments' description='Used to send email to outgoing and incoming cutomers from Flow')   
    public static void sendEmailtoCustomers(list<flowInput> currentInput){      
        string rId; 
        NotifyEmail__mdt chownMDT = [Select MasterLabel,Support_Hours__c,Event_Type__c,subject__C   
                                    from NotifyEmail__mdt where Event_Type__c='B2B_U2C_CHOWN' limit 1]; 
        EmailDTO emailDTO = new EmailDTO(); 
        for(flowInput singleID :currentInput ){                 
            rId = singleID.currentCaseId;   
            case cs = [select id,CaseNumber from case where id=:rId limit 1];   
            String fromEmail = null;    
            List<String> toEmails = new List<String>{singleID.inComingEmail,singleID.outGoingEmail};    
            String subject = chownMDT.subject__c;       
            String relatedtoId = rId;   
            String notificationEventType =chownMDT.Event_Type__c;       
            string supportingHrs = chownMDT.Support_Hours__c;   
            List<id> attachmentIds = singleID.docid;    
            emailDTO.fromEmail = fromEmail; 
            emailDTO.toEmails = toEmails;   
            emailDTO.ccEmails = null;   
            emailDTO.bccEmails = null;  
            emailDTO.subject = subject; 
            emailDTO.attachmentIds = attachmentIds; 
            emailDTO.entityType = 'NOT_APPLICABLE'; 
            emailDTO.entityId = 'NOT_APPLICABLE';   
            emailDTO.notificationEventType = notificationEventType; 
            emailDTO.msisdn = '';           
            emailDTO.relatedtoId = singleID.docid[0];   
            emailDTO.otherKayValues = new Map<String, String>{'case_ref_no'=>cs.CaseNumber,'support_hrs'=>chownMDT.Support_Hours__c};   
                    
                }   
        try{    
            EmailService eService =  new EmailService();    
            eService.send(emailDTO);    
                
                
        }catch(exception e){    
            System.debug('Exception caught '+e.getMessage());   
        }   
    }   
}