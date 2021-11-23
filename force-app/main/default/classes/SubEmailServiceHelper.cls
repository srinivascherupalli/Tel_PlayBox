/**
* Developer: Yash Rathod
* Description: Helper class to generate EmailDTO instance for SubscriptionEmailService class
**/

public with sharing class SubEmailServiceHelper{

    //method to generate EmailDTO
    public static EmailDTO generateEmailDTO(Id cTemplateId,csord__Subscription__c sub){
        String fromEmail=null;
        List<String> toEmails=new List<String>();
        List<String> ccEmails=new List<String>();
        List<String> bccEmails=new List<String>();
        String templateId;
        String subject;
        List<Id> attachmentIds=new List<Id>();
        String entityType = 'NOT_APPLICABLE';
        String entityId = 'NOT_APPLICABLE';
        String notificationEventType ='EDGESF_ORDER_1';
        String msisdn='';
        Map<String, String> otherKayValues = null;
        String relatedtoId = String.valueOf(sub.id).substring(0,15);
        EmailDTO emailDTO;
        try{
            if(cTemplateId!=null){
                String queryEmailTemplate ='SELECT '+String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('APXTConga4__Conga_Email_Template__c'))+' FROM APXTConga4__Conga_Email_Template__c WHERE Id = :cTemplateId' ;
                APXTConga4__Conga_Email_Template__c template=Database.query(queryEmailTemplate);
                templateId=template.APXTConga4__Name__c;
                csord__Subscription__c subscription =new csord__Subscription__c();
                subscription = [SELECT Id,MarketableOffer__r.Name,ContractJunction__c,csordtelcoa__Product_Configuration__c,csord__Order__r.csordtelcoa__Opportunity__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c FROM csord__Subscription__c WHERE id = : sub.id LIMIT 1];
                subject =  subscription.MarketableOffer__r.Name + ' cancellation confirmation';
                System.debug('queryEmailTemplate-->'+queryEmailTemplate);
                System.debug('subject-->'+subject);
				//to add order requestor
                Contact orderRequestor = [SELECT EMAIL FROM CONTACT WHERE ID IN (SELECT CONTACTID FROM OPPORTUNITYCONTACTROLE WHERE OPPORTUNITYID = :sub.csord__Order__r.csordtelcoa__Opportunity__c AND ISPRIMARY = true AND ROLE = 'Decision Maker')];
                //to add Contract Signatory
                cscfga__Product_Basket__c basket = [SELECT id FROM cscfga__Product_Basket__c WHERE Primary_Basket__c = true and csbb__Synchronised_With_Opportunity__c = true and cscfga__Opportunity__c = :sub.csord__Order__r.csordtelcoa__Opportunity__c];
				System.debug('orderRequestor-->'+orderRequestor);
                System.debug('basket-->'+basket);
                fromEmail = null;
                ccEmails = null;
                Set<String> toEmailsSet=new Set<String>();
                toEmailsSet.addAll(OrderEmailService.getContractSignatories(basket.Id));
                toEmailsSet.add(orderRequestor.Email);
                //add all emails to original list
                toEmails.addAll(toemailsSet);       
            }
        } catch(Exception e) {
            System.debug('exception caught '+e.getMessage());
            System.debug('exception caught '+e.getLineNumber());
            Logger2 logger=Logger2.getLogger(OrderEmailServiceHelper.class);
            logger.logMessages(null,null,e.getStackTraceString(),'Technical','Exception',e.getMessage(), false, false);
            logger.exitLogger();
        }
        emailDTO = new EmailDTO(fromEmail, toEmails,ccEmails,bccEmails,templateId, subject, attachmentIds, entityType, entityId, notificationEventType, msisdn, relatedtoId, otherKayValues);
       	System.debug('emailDTO-->'+emailDTO); 
        return emailDTO;
    }
}