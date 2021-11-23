public with sharing class EmailDTOUtil {
    //EmailDTO emailDTO = new EmailDTO();
    
    @InvocableMethod
    public static void processSubscriptionRecord(List<String> parameters1){
        system.debug('I am in'+parameters1);
        List<String> subsIdList = new List<String>();
        
        for(String paramString: parameters1){
            List<String> parameters = paramString.split(':::');
            String subsId = parameters[1];
            subsIdList.add(subsId);
        }
        List<String> signtoryList = new List<String>();
        List<csord__Service__c> ipSiteServList = [SELECT Id,Primary_Contact__c,Order_Primary_Contact__r.Email,toBeCancelled__c, Primary_Contact__r.Pref_Comm_Method__c, Primary_Contact__r.Email, Primary_Contact__r.MobilePhone,
                                                  Project_Contact__c, Project_Contact__r.Pref_Comm_Method__c, Project_Contact__r.Email, Project_Contact__r.MobilePhone,
                                                  Technical_Contact__c, Technical_Contact__r.Pref_Comm_Method__c, Technical_Contact__r.Email, Technical_Contact__r.MobilePhone,
                                                  csord__Order__r.csordtelcoa__Opportunity__r.owner.id, csord__Order__r.csordtelcoa__Opportunity__r.owner.name, csord__Order__r.csordtelcoa__Opportunity__r.owner.email,
                                                  csord__Order__r.csordtelcoa__Opportunity__r.owner.MobilePhone,
                                                  csord__Subscription__r.id,csord__Order__r.csordtelcoa__Opportunity__r.id FROM csord__Service__c WHERE Name='IP Site' and csord__Subscription__c IN: subsIdList ];
        system.debug('size'+ipSiteServList.size());
        if(ipSiteServList != null && ipSiteServList.size()!= 0){
            
        List<cscfga__Product_Basket__c> basket = [SELECT id FROM cscfga__Product_Basket__c WHERE Primary_Basket__c = true and csbb__Synchronised_With_Opportunity__c = true and cscfga__Opportunity__c = :ipSiteServList[0].csord__Order__r.csordtelcoa__Opportunity__r.id]; 
          
        List<Contact> orderRequestor = [SELECT EMAIL FROM CONTACT WHERE ID IN (SELECT CONTACTID FROM OPPORTUNITYCONTACTROLE WHERE OPPORTUNITYID = :ipSiteServList[0].csord__Order__r.csordtelcoa__Opportunity__r.id AND ISPRIMARY = true AND ROLE = 'Decision Maker')];
        List<Contact> siteContact = [SELECT ID, EMAIL FROM CONTACT WHERE ID = :ipSiteServList[0].Primary_Contact__c]; 
        for(csord__Service__c ipSiteServ: ipSiteServList){
            //System.debug('orderRequestor = '+orderRequestor[0]+ 'basketId ='+basket[0].id);
			if(basket!= null && basket.size()!= 0){
         signtoryList = OrderEmailService.getContractSignatories(basket[0].id);}
            Set<String> contacts = new Set<String>();
            contacts.add(ipSiteServ.Primary_Contact__c);
            contacts.add(ipSiteServ.Project_Contact__c);
            contacts.add(ipSiteServ.Technical_Contact__c);
            contacts.add(ipSiteServ.csord__Order__r.csordtelcoa__Opportunity__r.owner.id);
            
            system.debug('ContactList+'+contacts);
            
            if(ipSiteServ.toBeCancelled__c!='true'){  
                if(ipSiteServ.Primary_Contact__c!= NULL && contacts.contains(ipSiteServ.Primary_Contact__c) && ipSiteServ.Project_Contact__c != NULL && contacts.contains(ipSiteServ.Project_Contact__c) && ipSiteServ.csord__Order__r.csordtelcoa__Opportunity__r.owner.id!=NULL && contacts.contains(ipSiteServ.csord__Order__r.csordtelcoa__Opportunity__r.owner.id) && ipSiteServ.Technical_Contact__c!=NULL && contacts.contains(ipSiteServ.Technical_Contact__c)){
                    system.debug('I am inside primary con');
                    
                    String fromEmail = null;
                    List<String> toEmails = new List<String>(signtoryList);
					if(orderRequestor!= null && orderRequestor.size()!= 0){
                    toEmails.add(orderRequestor[0].Email);}
					if(siteContact!= null && siteContact.size()!= 0){
                    toEmails.add(siteContact[0].Email);}
                    toEmails.add(ipSiteServ.Order_Primary_Contact__r.Email);  
                    List<String> ccEmails = null;
                    List<String> bccEmails = null;
                    String templateId = Label.EmailTemplateId;
                    String subject = OrderEmailService.getSubject(Label.EmailTemplateId);
                    List<id> attachmentIds = null;
                    String entityType = 'NOT_APPLICABLE';
                    String entityId = 'NOT_APPLICABLE';
                    String notificationEventType ='EDGESF_ORDER_1';
                    String msisdn = ipSiteServ.Primary_Contact__r.MobilePhone;
                    String relatedtoId = ipSiteServ.csord__Subscription__r.id;
                    Map<String, String> otherKayValues = null;
                    
                    
                    
                    EmailDTO emailDTO = new EmailDTO(fromEmail, toEmails,ccEmails,bccEmails,templateId, subject
                                                     , attachmentIds, entityType, entityId
                                                     , notificationEventType, msisdn, relatedtoId, otherKayValues);
                    
                    if(ipSiteServ.Primary_Contact__r.Pref_Comm_Method__c == 'eMail' && ipSiteServ.Project_Contact__r.Pref_Comm_Method__c == 'eMail' && ipSiteServ.Technical_Contact__r.Pref_Comm_Method__c == 'eMail'){
                        system.debug('Successful callout');
                        new EmailService().send(emailDTO);
                    }
                }
            }
        }
        } 
            /* if(ipSiteServ.Project_Contact__c != NULL && contacts.contains(ipSiteServ.Project_Contact__c)){
system.debug('I am inside project con');
String fromEmail = null;
List<String> toEmails = new List<String>{ipSiteServ.Project_Contact__r.Email};
String templateId = Label.EmailTemplateId;
String subject = 'Your Connected Workplace service is up and running';
List<id> attachmentIds = null;
String entityType = 'NOT_APPLICABLE';
String entityId = 'NOT_APPLICABLE';
String notificationEventType ='EDGESF_ORDER_1';
String msisdn = ipSiteServ.Project_Contact__r.MobilePhone;
String relatedtoId = ipSiteServ.csord__Subscription__r.id;
Map<String, String> otherKayValues = null;



EmailDTO emailDTO = new EmailDTO(fromEmail, toEmails, templateId, subject
, attachmentIds, entityType, entityId
, notificationEventType, msisdn, relatedtoId, otherKayValues);

if(ipSiteServ.Project_Contact__r.Pref_Comm_Method__c == 'eMail'){
new EmailService().send(emailDTO);
}
}

if(ipSiteServ.csord__Order__r.csordtelcoa__Opportunity__r.owner.id!=NULL && contacts.contains(ipSiteServ.csord__Order__r.csordtelcoa__Opportunity__r.owner.id)){
system.debug('I am inside opp owner');
String fromEmail = null;
List<String> toEmails = new List<String>{ipSiteServ.csord__Order__r.csordtelcoa__Opportunity__r.owner.email};
String templateId = Label.EmailTemplateId;
String subject = 'Your Connected Workplace service is up and running';
List<id> attachmentIds = null;
String entityType = 'NOT_APPLICABLE';
String entityId = 'NOT_APPLICABLE';
String notificationEventType ='EDGESF_ORDER_1';
String msisdn = ipSiteServ.csord__Order__r.csordtelcoa__Opportunity__r.owner.MobilePhone;
String relatedtoId = ipSiteServ.csord__Subscription__r.id;
Map<String, String> otherKayValues = null;



EmailDTO emailDTO = new EmailDTO(fromEmail, toEmails, templateId, subject
, attachmentIds, entityType, entityId
, notificationEventType, msisdn, relatedtoId, otherKayValues);

new EmailService().send(emailDTO);

}

if(ipSiteServ.Technical_Contact__c!=NULL && contacts.contains(ipSiteServ.Technical_Contact__c)){
system.debug('I am inside technical con');
String fromEmail = null;
List<String> toEmails = new List<String>{ipSiteServ.Technical_Contact__r.Email};
String templateId = Label.EmailTemplateId;
String subject = 'Your Connected Workplace service is up and running';
List<id> attachmentIds = null;
String entityType = 'NOT_APPLICABLE';
String entityId = 'NOT_APPLICABLE';
String notificationEventType ='EDGESF_ORDER_1';
String msisdn = ipSiteServ.Technical_Contact__r.MobilePhone;
String relatedtoId = ipSiteServ.csord__Subscription__r.id;
Map<String, String> otherKayValues = null;



EmailDTO emailDTO = new EmailDTO(fromEmail, toEmails, templateId, subject
, attachmentIds, entityType, entityId
, notificationEventType, msisdn, relatedtoId, otherKayValues);

if(ipSiteServ.Technical_Contact__r.Pref_Comm_Method__c == 'eMail'){

new EmailService().send(emailDTO);
}

}*/
            
            
       // }
    }
}