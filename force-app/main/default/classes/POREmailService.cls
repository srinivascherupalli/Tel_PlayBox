public with sharing class POREmailService {
    @InvocableMethod
    public static void processOrderRecord(List<Id> porId){
        List<Partner_of_Record__c> partnerList =[Select id,Customer_Signatories__r.Lastname,Partner__r.Name,Customer_Signatories__r.Email,Partner_Signatories__r.Email,Customer_Signatories__r.firstname,Status__c from Partner_of_Record__c where id in : PorId];
        EmailDTO emailDTO;
        String relatedtoId ;
        list<string> toemails = new list<string>();
        List<EmailDTO> emailDTOList = new List<EmailDTO>();
        if(!partnerList.isEmpty()){
            for(Partner_of_Record__c patner : partnerList){
                relatedtoId = String.valueOf(patner.id).substring(0,15);
                toemails.add(patner.Customer_Signatories__r.Email);
                system.debug(toemails+'toemails**********');
                EmailDTO ParnerDTO = new EmailDTO();
                ParnerDTO.notificationEventType = 'PARTNER_OF_RECORD_AGREEMENT';
                ParnerDTO.entityId = 'NOT_APPLICABLE';
                ParnerDTO.entityType = 'NOT_APPLICABLE';
                ParnerDTO.toEmails = toemails;
                ParnerDTO.relatedtoId = relatedtoId;
                ParnerDTO.subject = 'Cancelled - Telstra partner authorisation';
                ParnerDTO.otherKayValues = new Map<String, String>{'first_name'=>patner.Customer_Signatories__r.firstname,'partner_name'=>patner.Partner__r.Name};
                    system.Debug(ParnerDTO.otherKayValues+'**********************');
                emailDTOList.add(ParnerDTO);
                
            }
        }
        for(EmailDTO emails: emailDTOList){
            system.debug('emails'+emails);
            new EmailService().send(emails);
        }
    }
}