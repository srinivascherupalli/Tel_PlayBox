/* ****************************************************************************
* Author : Vishal Arbune 
* Date : 18 Sept 2020
* Description : To invoke action from Process builder: CIS Notification Send From Contract
* Process builder: CIS Notification Send From Contract
* Story : EDGE-169633
* *****************************************************************************/
public with sharing class SendOrderFormEmailService { 
    @InvocableMethod(label='Send Order Form Email' description='Send Order Form when Contract status moved to Initiated')
    public static void processSendOrderFormEmail(List<Id> ContractId){
        System.debug('In processSendOrderFormEmail ContractId ....:'+ContractId);  
        if(EnvironmentVariable__c.getValues('Send_OrderForm_for_Contract').Value__c=='True'){
            String soqlForData = 'select Account__c, Status__c, Related_Basket__r.csordtelcoa__Basket_Stage__c, DocuSign_Signer_3__c,Customer_Primary_Contact__r.FirstName, '+                       
                                    'Customer_Primary_Contact__r.Email, Related_Opportunity__r.Owner.Name, Related_Opportunity__r.Owner.Phone,'+ 
                                    'Related_Opportunity__r.Owner.Email, Related_Opportunity__r.Owner.MobilePhone, CIS_Dispatched_Offers__c,'+ 'Account__r.YTD_Total_Revenue__c '+ 
                                    'from ContractJunction__c '+
                                    'where id IN :ContractId';
            
            System.debug('soqlForData ....:'+soqlForData);                  
            List<ContractJunction__c> CJList = Database.query(String.escapeSingleQuotes(soqlForData));
            EmailDTO emailDto = createEmailDTO(CJList);            
        } else{
            System.debug('Order Form already sent to this');     
        }    
    }      
    
    
    /* ****************************************************************************
    * Author : Vishal Arbune : EDGE-169633
    * Date : 18 Sept 2020
    * Description : To construct the Email Request Param Payload dynamically to instantiate the JSON mapping
    * Return Type: EmailDTO 
    * *****************************************************************************/
    public static EmailDTO createEmailDTO(List<ContractJunction__c> ContractId){
        System.debug('In createEmailDTO ContractId....:'+ContractId);
        String fromEmail = null;
        List<String> toEmails = new List<String>{ContractId[0].Customer_Primary_Contact__r.Email};
        User docuSignUser=[Select Id, Email From User Where Id=:ContractId[0].DocuSign_Signer_3__c];        
        String subject = System.Label.Your_Telstra_Order_Request;   //Your Telstra Order Request        
        String relatedtoId = ContractId[0].id;   
        Map<String, String> otherKayValues = null;        
        String notificationEventType =System.Label.B2B_P2O_ORDER_REQUEST;  //B2B_P2O_MAC_ORDER_RECEIVED              
        //String msisdn = null;
        String entityType = 'NOT_APPLICABLE';
        String entityId = 'NOT_APPLICABLE';
        List<String> ccEmails = new List<String>{ContractId[0].Related_Opportunity__r.Owner.Email, docuSignUser.Email}; // ContractId[0].DocuSign_Signer_3__r.Email
        List<String> bccEmails = null;
        List<id> attachmentIds = fetchAttachmentId(ContractId[0].id);  
        System.debug('attachmentIds....:'+attachmentIds);
        
        EmailDTO emailDTO = new EmailDTO();
        emailDTO.fromEmail = fromEmail;
        emailDTO.toEmails = toEmails;
        emailDTO.ccEmails = ccEmails;
        emailDTO.bccEmails = bccEmails;
        emailDTO.subject = subject;
        emailDTO.attachmentIds = attachmentIds;
        emailDTO.entityType = entityType;
        emailDTO.entityId = entityId;
        emailDTO.notificationEventType = notificationEventType;
        //emailDTO.msisdn = msisdn;       
        emailDTO.relatedtoId = relatedtoId;
        try{
            EmailService eService =  new EmailService();
            eService.send(emailDTO);
        }
        Catch(Exception Ex){
            System.debug('Exception caught '+Ex.getMessage());
        }
        return emailDTO;
    }
    
    /* ****************************************************************************
    * Author : Vishal Arbune : EDGE-169633
    * Date : 18 Sept 2020
    * Description : To fetch files & Attachment attached to ContractJunction__r.ID record
    * Return Type: List<Id> 
    * *****************************************************************************/
    public Static List<Id> fetchAttachmentId(ID ContractId) {
        List<ContentDocumentLink> contentDocLinkList = [SELECT ContentDocumentId,ContentDocument.Title,
                                                            ContentDocument.fileextension, ContentDocument.Id, LinkedEntityId  FROM ContentDocumentLink
                                                        where LinkedEntityId in ( SELECT Id FROM ContractJunction__c) 
                                                        and LinkedEntity.Type='ContractJunction__c'                                                         
                                                        and LinkedEntityId =: ContractId];
        List<Id> attachmentOrderFormId = new List<Id>();
        if(!contentDocLinkList.isEmpty()){
            for(ContentDocumentLink cdl:contentDocLinkList){
                if(cdl.ContentDocument.Title.contains('Order Form')){
                    attachmentOrderFormId.add(cdl.ContentDocumentId);
                }
            }           
        }       
        return attachmentOrderFormId;
    }
}