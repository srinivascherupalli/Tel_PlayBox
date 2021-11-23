/************************************************************ 
 * @version      - 0.1
 * @createdBy    - Manjunath Ediga
 * @ModifiedBy   - Pradeep Bhumi
 * @team         - OSAKA
 * @jirastoryRef - EDGE-72273, EDGE-88300,EDGE-113045
 * @Description  - This class will process the email notification params from Case  
 ******************************************************************/


public with sharing class CaseEmailService {

    /**
     *  The method will execute from the "Send Email to Agent" Process Builder.
     *  @name processCaseRecord
     *  @param CaseId - List of CaseIds
     */
    @InvocableMethod
    public static void processCaseRecord(List < Id > CaseId) {

        if (!CaseId.isEmpty())
            processNotifyEmailParams(CaseId);

    }

    /**
     *  The method will process process email request params for case Online Ordering and Billing Enquiry
     *  @name processNotifyEmailParams
     *  @param CaseId - List of CaseIds
     *  @return void - 
     *  @throws exception - Throw an error if contact email is BLANK.
     *  @Jira Story Ref - EDGE-72273,EDGE-88300,EDGE-113045
     */

    public static void processNotifyEmailParams(List < Id > CaseId) {
        set < Id > contactIds = new set < Id > ();
        String notificationEventType = '';
        String templateName = '';
        String subject = '';
        String entityType = '';
        String entityId = '';
        String relatedtoId = '';
        String accountId = '';
        String contactId = '';
        //EDGE-113045 initialized existing List 
        List < String > ccEmails = new List < String > ();
        Map < String, String > contentParamMap = new Map < String, String > ();
        //EDGE-157963:  initialized list for attachments
        List<Id> attachmentIds=new List<Id>();
        List<Id> fileIdList = new List<Id>();
        ContentVersion contentFiles;
        Map<Id,ContentVersion> contentVersionMap;
        List <ContentDocumentLink> attachments=[SELECT ContentDocumentId FROM ContentDocumentLink where LinkedEntityId IN :CaseId];
        for (ContentDocumentLink caseFiles:attachments)
        {
        attachmentIds.add(caseFiles.ContentDocumentId);   
        }
        contentVersionMap=new Map<Id,ContentVersion>([SELECT id,ContentDocumentId,ContentSize FROM ContentVersion where ContentDocumentId in :attachmentIds and internal__c=false]);        
        for (Id contentMap:contentVersionMap.keySet())
        {
        contentFiles=contentVersionMap.get(contentMap);
        fileIdList.add(contentFiles.ContentDocumentId);
         }
    
        try {
            //Start of  EDGE-113045 
            List < Case > caseIdList = [SELECT Id, RecordTypeID, Status,Billing_Account__c, Resolution_Email_Comments__c, RecordType.name, CaseNumber, ContactId, Billing_Account__r.Billing_Account_Number__c, Accountid, Contact.FirstName, Contact.Email, Account.Name, (SELECT id, Invoice_Line_Item__r.Invoice__r.name FROM Queried_Line_Items__r LIMIT 1), (select id, Determination_Status__c from Credits__r where Determination_Status__c = 'Approved') FROM Case WHERE Id IN: CaseId AND ContactID <> null AND AccountId <> null AND Contact.FirstName <> null];
            //End of  EDGE-113045
            for (Case accCase: caseIdList) {
                accountId = accCase.Billing_Account__c;
                contactId = accCase.Contact.Email;
            }
            List <Functional_Contact_Role__c> associatedContacts = [SELECT Id,ContactID__c,ContactID__r.email, Is_Primary__c, Billing_Account_Number__c FROM Functional_Contact_Role__c where Billing_Account_Number__c=: accountId ];
            if (contactId == null) {
                throw new CustomException(System.Label.CaseCustomExeception);
            }
            for (Case caseData: caseIdList) {
                EmailDTO emailParams = new EmailDTO();
                List < String > toEmails = new List < String > ();
                //Common DTO fields for all case email Notifications 
                toEmails.add(caseData.Contact.Email);
                entityType = System.Label.EmailEntityType;
                entityId = System.Label.EmailEntityId;
                relatedtoId = String.valueOf(caseData.id).substring(0, 15);
                system.debug('Record Name   ' + caseData.RecordType.name);
                system.debug('Status   ' + caseData.Status);                
                

                //Online Ordering Email Notification params
                if (caseData.RecordType.name == System.Label.Case_Online_RecordType) {
                    notificationEventType = System.Label.EmailNotificationEventType;
                    templateName = System.Label.EmailTemplateOnlineOrdering;
                    subject = System.Label.Email_Subject;
                    ccEmails = null;

                    //Dynamic Content Parameters
                    contentParamMap.put('FIRST_NAME', caseData.Contact.FirstName);
                    contentParamMap.put('CASE_NUMBER', caseData.CaseNumber);
                    contentParamMap.put('COMPANY_NAME', caseData.Account.Name);
                }

                //Start of  EDGE-113045 : BillingEnquiry Email Notification params
                if (caseData.RecordType.name == System.Label.Case_Billing_Enquiry_RecordType) {

                    for (Functional_Contact_Role__c contactEmail: associatedContacts) {
                        if (contactEmail.Billing_Account_Number__c != null  && contactEmail.is_Primary__c == true && contactEmail.ContactID__r.email != null) {
                            ccEmails.add(contactEmail.ContactID__r.email);
                        }
                    }

                    //Mapping the Not null record queried from case
                    contentParamMap.put('first_name', caseData.Contact.FirstName);
                    contentParamMap.put('company_name', caseData.Account.Name);
                    contentParamMap.put('account_number', caseData.Billing_Account__r.Billing_Account_Number__c);
                    contentParamMap.put('case_number', caseData.CaseNumber);
                    if (caseData.Queried_Line_Items__r != null && !caseData.Queried_Line_Items__r.isEmpty() && caseData.Queried_Line_Items__r[0].Invoice_Line_Item__r != null && caseData.Queried_Line_Items__r[0].Invoice_Line_Item__r.Invoice__r != null) {
                        contentParamMap.put('invoice_number', caseData.Queried_Line_Items__r[0].Invoice_Line_Item__r.Invoice__r.name);
                    }
                    //Start of  EDGE-116123 : Case Resolved and Closed email Notifications
                    if (caseData.Status == 'New') {
                        contentParamMap.put('enquiry', caseData.CaseNumber);
                        notificationEventType = System.Label.Email_Billing_Enquiry_Event_Type;
                        templateName = System.Label.EmailTemplateBillingEnquiry;
                        subject = System.Label.Billing_Enquiry_Subject + ' ' + caseData.CaseNumber;
                        system.debug('New Status ...  ' ); 

                    } else if (caseData.Status == 'Resolved' && !caseData.Credits__r.isEmpty()) {
                        notificationEventType = System.Label.Billing_Enquiry_Event_Type_Resolved;
                        templateName = System.Label.TemplateBillingEnquiryResolved;
                        subject = System.Label.Billing_Enquiry_Subject_Outcome + ' ' + caseData.CaseNumber;
                        contentParamMap.put('reason1_1', caseData.Resolution_Email_Comments__c);
                        //EDGE-157963: sending attachments ids if not null
                        If(!fileIdList.isEmpty()){
                        emailParams.attachmentIds= fileIdList;} 
                        system.debug('ResolvedStatus ...  ' ); 
                                                                                    
                    } else if (caseData.Status == 'Closed') {
                        contentParamMap.put('enquiry', caseData.CaseNumber);
                        notificationEventType = System.Label.Billing_Enquiry_Event_Type_Closed;
                        templateName = System.Label.TemplateBillingEnquiryClosed;
                        subject = System.Label.Billing_Enquiry_Subject + ' ' + caseData.CaseNumber;
                         system.debug('Closed Status ...  ' ); 
                    }
                    //End of  EDGE-116123
                }
                emailParams.toEmails = toEmails;
                emailParams.ccEmails = ccEmails;
                emailParams.templateId = templateName;
                emailParams.subject = subject;
                emailParams.entityType = entityType;
                emailParams.entityId = entityId;
                emailParams.notificationEventType = notificationEventType;
                emailParams.otherKayValues = contentParamMap;
                emailParams.relatedtoId = relatedtoId;
                if (!contentParamMap.isEmpty()) {
                    new EmailService().send(emailParams, caseData.Status);
                }
                //End of  EDGE-113045
            }
        } catch (Exception e) {
            Logger2 logger2 = Logger2.getLogger('CaseEmailService');
            logger2.logMessages(String.valueOf(e), String.valueOf(e.getMessage()), '', '', '', '', false, false, null, null, null, null);

        }
    }
     /**
     *  The method will update case comments for error scenario for resolved status
     *  @name handleErrorScenario
     *  @EDGE:EDGE-157963
     */      
    public static void handleErrorScenario(EmailRequest request,String response) 
    {
    String caseNum;
    Case caseRecord;
    String errorMessage;
    CaseComment caseComm = new CaseComment();
    
    if (response != null && !request.attachmentParameters.isEmpty())
    { 
    for (EmailRequest.ContentParameters content:request.contentParameters)
    {
    if(content.name == 'case_number'){
    caseNum=content.value;         }
    } 
    JSONParser parser = JSON.createParser(response);
    while (parser.nextToken() != null) {
    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'message'))  {
    parser.nextToken();
    errorMessage=parser.getText();
    }
    }   
    caseRecord = [select id,status from case where caseNumber=:caseNum];
    if(caseRecord != null && caseRecord.status == 'Resolved')  {
    String caseId=caseRecord.id;
    String status=caseRecord.status;
    caseComm.CommentBody = status.touppercase()+':'+errorMessage;
    caseComm.ParentId = caseRecord.id;
    insert caseComm ;  
    caseRecord.status='Obtaining Internal Approval';
    update caseRecord;
    String strWord=caseId.substring(0,caseId.length()-3);
    String searchKeyword='%'+strWord+'%'+status;
    //EDGE:EDGE-157963: Updating integration record to error for resolved error sceanrio
    List<Integration_Record__c> intRecord=[SELECT Id, params__c,handler__c,Status__c,createddate FROM Integration_Record__c where Params__C Like:searchKeyword order by createddate desc Limit 1];
    if(intRecord.size() != 0)  {
    intRecord[0].Status__c='Error';
    update intRecord;
    }
        } 
    }
    } 
}