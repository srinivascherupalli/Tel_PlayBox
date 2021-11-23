/*************************************************************************************************************************
@Name: APTPS_SendForSignatureController
@Author: Shishir Bose
@Created Date: 08/24/2016
@Descripton: This controller is created for handling the custom send for review and send for signature process.
@Used By: APTPS_Init_SendForReview and APTPS_Init_SendForSignature VF page
*************************************************************************************************************************/
public with sharing class APTPS_SendForSignatureController
{
    public Apttus__APTS_Agreement__c parentAgreement {get; set;}
    
    public string agreementName{get;set;}
    public List<APTPS_AttachmenttSelectionWrapper> attachmentListToBeDisplayed {get; set;}

    public String addlRecipientsPlainText {get; set;}
    public String addlRecipientsHTML {get; set;}
     
    //public Case   ourCase {get; set;}
    public EmailMessage plainTextEmailMsg {get; private set;}
    public EmailMessage hTMLEmailMsg {get; private set;}

    private OrgWideEmailAddress sender = null;
    private String recordTypeName= 'Schedule';// Added for EDGE-207628
    private static final String SUPPORT_EMAIL_ADDRESS = 'sbose@apttus.com';
    private static final String SUPPORT_NAME = 'Support Email';   
    public Id selectedFolderId {get; set;}
    public Id selectedEmailTemplateId {get; set;}
    Map<Id, EmailTemplate> allEmailTemplatesMap {get; set;}
    public List<Attachment> attachmentsToBeSentForReview {get; set;}
    public string displayOutputText {get;set;}
    public string displayInputTextarea {get;set;}
    List<Id> selectedAttachmentIds {get; set;}
    public Id contactId {get; set;}
    Set<Id> agreementIdToBeUpdated {get; set;}
    public boolean displayError {get; set;}  
public List<APTPS_AgreementSelection> agreementListToBeDisplayed {get; set;}
    public string actionName{get;set;}
    public string hiddenInput{get;set;}
    Public boolean variationScenario = false; 
    //private static final Id AGREEMENT_Schedule_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
    /*************************************************************************************************************************
     @Name: Constructor of APTPS_SendForSignatureController class
     @Author: Shishir Bose
     @Created Date: 08/24/2016
     @Descripton: This is the constructor of the class. Here data is stored for further processing and variables are initialized.
    *************************************************************************************************************************/
    public APTPS_SendForSignatureController(ApexPages.StandardController  stdController)
    {
        if(!test.isRunningTest()){ // added as addFields method is not Testable.
        stdController.addFields(new List<string>{'Name','Apttus__Status_Category__c', 'Apttus__Status__c'});
        
        }
        actionName = ApexPages.currentPage().getParameters().get('actionName');
        parentAgreement = (Apttus__APTS_Agreement__c)stdController.getRecord();
        parentAgreement = APTPS_CommonUtilities.getAgreementData(parentAgreement.Id);
        agreementName = parentAgreement.Name;
        
        plainTextEmailMsg = new EmailMessage();
        hTMLEmailMsg = new EmailMessage();
        
        EmailTemplate temp = [SELECT Id, folder.Name,FolderId
FROM EmailTemplate where folder.developerName <> '' and folder.Name= 'Apttus Email Templates' limit 1];
        EmailTemplate review = [SELECT Id, folder.Name,FolderId
                             FROM EmailTemplate where folder.developerName <> '' and folder.Name= 'Send for Review' limit 1];
       
        if(('Send_For_Billing_Review').equalsIgnoreCase(actionName)){ 
           selectedFolderId = review.FolderId;
        }else{
           selectedFolderId = temp.FolderId;
        }
            
        contactId = null;
        
        displayError = false;
        hiddenInput = '';
    }
    
     /*************************************************************************************************************************
     @Name: getAgreements
     @Author: Shishir Bose
     @Created Date: 04/12/2016
     @Descripton: This method returns the list of Child agreements along with the parent agreement for displaying on the screen
    *************************************************************************************************************************/
   public PageReference cancelSignatures()
    {
       try
       {
           parentAgreement.Apttus__Status_Category__c='In Authoring';
           parentAgreement.Apttus__Status__c='Ready for Signatures';
           upsert parentAgreement;
           return cancel();
       }
        catch(Exception e)
        {
           System.debug('CaLMs System exception caught: ' + e.getMessage());  
           ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'An exception has occuered. Please contact the system administrator'));
           return null;
        }
    }
    
    /*************************************************************************************************************************
     @Name: getAgreements
     @Author: Shishir Bose
     @Created Date: 04/12/2016
     @Descripton: This method returns the list of Child agreements along with the parent agreement for displaying on the screen
    *************************************************************************************************************************/
   public List<APTPS_AgreementSelection> getAgreements()
    {
       try
       {
           APTPS_AgreementSelection agrmntSelection = null;
            if(agreementListToBeDisplayed == null)
            {
                agreementListToBeDisplayed = new List<APTPS_AgreementSelection>();
                
                for(Apttus__APTS_Agreement__c agrmnt : [select Id, Name, Apttus__FF_Agreement_Number__c, Apttus__Status_Category__c, 
                                                            Apttus__Status__c,  Apttus__Agreement_Category__c,  Apttus__Subtype__c,
                                                            APTPS_Agreement_Subcategory__c,Apttus__Parent_Agreement__c,createddate, RecordTypeId,RecordType.name
                                                            , APTPS_Schedule_Number_Text__c, Apttus_Approval__Approval_Status__c,Apttus__Version_Number__c  
                                                            from Apttus__APTS_Agreement__c
                                                            where (Id =:parentAgreement.Id or Apttus__Parent_Agreement__c =:parentAgreement.Id)
                                                            and (Apttus__Status_Category__c =: APTPS_Constants.IN_AUTHORING_STATUS_CATEGORY
                                                                or Apttus__Status_Category__c =: APTPS_Constants.IN_SIGNATURES_STATUS_CATEGORY)
                                                            and Apttus_Approval__Approval_Status__c !=: 'Approval Required' 
                                                            and Apttus_Approval__Approval_Status__c !=: 'Rejected' 
                                                            order by createddate])//EDGE-207628 added recordtypeName field
                {
                    //Converting the agreement record into AgreementForGeneration wrapper class
                   if(agrmnt.Apttus__Parent_Agreement__c == null)
                    {
                        agrmntSelection = new APTPS_AgreementSelection(agrmnt, true);
                    }
                    else
                    {
                        agrmntSelection = new APTPS_AgreementSelection(agrmnt, false);
                    }

                    if(agrmntSelection.relationship == 'Parent')
                    {
                        agrmntSelection.selected = true;
                    }                
                    agreementListToBeDisplayed.add(agrmntSelection);
                    //EDGE-207628 added new condition for variation scenario
                    if(agrmnt.Apttus__Version_Number__c>0 && agrmnt.RecordType.name==recordTypeName){
                        variationScenario=true;
                    }
                }
            }
            if(agreementListToBeDisplayed != null && agreementListToBeDisplayed.size() > 0)
            {
                agreementListToBeDisplayed.sort();
            }
            system.debug('variationScenariovalueStart'+variationScenario);//EDGE-207628
            return agreementListToBeDisplayed;
       }
       catch(Exception e)
        {
           System.debug('CaLMs System exception caught: ' + e.getMessage());  
           ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'An exception has occuered. Please contact the system administrator'));
           return null;
        }

    }
    
    
    /*************************************************************************************************************************
     @Name: getAgreements
     @Author: Shishir Bose
     @Created Date: 04/12/2016
     @Descripton: This method returns the list of Child agreements along with the parent agreement for displaying on the screen
    *************************************************************************************************************************/
    public List<APTPS_AttachmenttSelectionWrapper> getAttachments()
    {
        try
        {
            Id agreementId = null;
            if(attachmentListToBeDisplayed == null)
            {
                attachmentListToBeDisplayed = new List<APTPS_AttachmenttSelectionWrapper>();
                List<Attachment> attachments;

                for(Apttus__APTS_Agreement__c agrmnt : [select Id, Name, Apttus__FF_Agreement_Number__c, Apttus__Status_Category__c, 
                                                            Apttus__Status__c, Apttus__Parent_Agreement__c,createddate, APTPS_Schedule_Number_Text__c,
                                                            Apttus_Approval__Approval_Status__c,
                                                            (select Id, Name,Bodylength, createddate from Attachments order by createddate desc )  from Apttus__APTS_Agreement__c
                                                            where (Id =:parentAgreement.Id or Apttus__Parent_Agreement__c =:parentAgreement.Id) 
                                                        and (Apttus__Status_Category__c =: APTPS_Constants.IN_AUTHORING_STATUS_CATEGORY
                                                                or Apttus__Status_Category__c =: APTPS_Constants.IN_SIGNATURES_STATUS_CATEGORY)
                                                        and Apttus_Approval__Approval_Status__c !=: 'Approval Required'   
                                                                                                                                                                                                                                and Apttus_Approval__Approval_Status__c !=: 'Rejected' 
                                                             order by Apttus__FF_Agreement_Number__c ])
                {
                    //Converting the agreement attachment record into APTPS_AttachmenttSelectionWrapper wrapper class

                    attachments = agrmnt.attachments;

                    if(attachments != null && attachments.size() > 0)
                    {
                        for(attachment attch : attachments)
                        {
                             if(agrmnt.Id != agreementId)
                                {
                                    attachmentListToBeDisplayed.add(new APTPS_AttachmenttSelectionWrapper(agrmnt,attch));
                                    agreementId = agrmnt.Id;
                                }
                                else
                                {
                                    attachmentListToBeDisplayed.add(new APTPS_AttachmenttSelectionWrapper(agrmnt,attch));
                                }
                        }    
                    }

                }
            }

            if(attachmentListToBeDisplayed != null && attachmentListToBeDisplayed.size() > 0)
            {
                attachmentListToBeDisplayed.sort();

            }

            return attachmentListToBeDisplayed;
        }
        catch(Exception e)
        {
            System.debug('CaLMs System exception caught: ' + e.getMessage());  
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'An exception has occuered. Please contact the system administrator'));
            return null;
        }

    }
    
    
    public List<SelectOption> getTemplateFolders()
    {
    try
        {
        List<SelectOption> folders = new List<SelectOption>();
            Map<Id,string> uniqueFolders = new Map<Id,string>();
            for(EmailTemplate emlTmpt : [ SELECT Id, Name, DeveloperName, FolderId, Folder.DeveloperName,folder.Name
            FROM EmailTemplate where folder.developerName <> ''])
            {
                if(uniqueFolders.get(emlTmpt.FolderId) == null)
                {
                    uniqueFolders.put(emlTmpt.FolderId, emlTmpt.folder.Name);
                }
            }

            for(Id folderId : uniqueFolders.keySet() )
            {
               folders.add(new SelectOption(folderId, uniqueFolders.get(folderId)));
            }

            return folders;
        }
        catch(Exception e)
        {
            System.debug('CaLMs System exception caught: ' + e.getMessage());  
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'An exception has occuered. Please contact the system administrator'));
            return null;
        }
    }
    
    public List<TemplateWrapper> getTemplates()
    {
        try
        {
            List<TemplateWrapper>  templatesToBeDisplayed = new List<TemplateWrapper>();
            allEmailTemplatesMap = new Map<Id,EmailTemplate>(); 
            for(EmailTemplate emlTmpt : [SELECT Id, Name,  Subject, BrandTemplateId, DeveloperName, 
                                         TemplateType, description, FolderId, Folder.DeveloperName,folder.Name
                                         FROM EmailTemplate where folder.developerName <> '' and FolderId =: selectedFolderId
                                         ORDER by DeveloperName])
            {
                templatesToBeDisplayed.add(new TemplateWrapper(emlTmpt));
                allEmailTemplatesMap.put(emlTmpt.Id, emlTmpt);
            }
            return templatesToBeDisplayed;
        }
        catch(Exception e)
        {
            System.debug('CaLMs System exception caught: ' + e.getMessage());  
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'An exception has occuered. Please contact the system administrator'));
            return null;
        }
    }
    
    public void updateTemplateFolderId()
    {
       selectedFolderId = String.valueOf(ApexPages.currentPage().getParameters().get('folderId')).trim();
    }
     public Attachment attachment {
        get {
            if (attachment==null) {
                System.debug('==========> creating new empty Attachment.');
                attachment = new Attachment();
            }
            return attachment;
        }
        set;
    }
    
    
    
    /*************************************************************************************************************************
@Name: cancel
@Author: Shishir Bose
@Created Date: 04/12/2016
@Descripton: This method is called on clicking cancel button on VF page and takes the user back on agreement page
*************************************************************************************************************************/
   public void getSelected() 
   {
      selectedEmailTemplateId = ApexPages.currentPage().getParameters().get('selectedEmailTemplateid');  
                
   }

    public PageReference selectAgreementAndAttachment()
    {
        system.debug(' entered selectAgreementAndAttachment mtd');
        try
        {
           system.debug(' entered inside try block selectAgreementAndAttachment mtd');
            displayError = false;
            attachmentsToBeSentForReview = new List<Attachment>();
            agreementIdToBeUpdated = new Set<Id>();
            boolean parentattachmentSelected = false;
            selectedAttachmentIds = new List<Id>();
            boolean parentAgreementSelected = false;
            //selectedFolderId = null;
            system.debug('agreementListToBeDisplayed@@@@@'+agreementListToBeDisplayed);
            system.debug('variationScenariovalue'+variationScenario);
            for(APTPS_AgreementSelection agrmntSelection : agreementListToBeDisplayed)
            {
               system.debug('APTPS_AgreementSelection@@@@@'+agrmntSelection);
               system.debug('agrmntSelection.selected@@@@@'+agrmntSelection.selected);
               system.debug('agrmntSelection.relationship@@@@@'+agrmntSelection.relationship);
               system.debug('agrmntSelection.agreement.Id@@@@@'+agrmntSelection.agreement.Id);
                if(agrmntSelection.selected)
                {   
                            
                    if(agrmntSelection.relationship == 'Parent')
                    {
                        parentAgreementSelected = true;
                    }                
                    agreementIdToBeUpdated.add(agrmntSelection.agreement.Id);
                    system.debug('agreementIdToBeUpdated@@@@@'+agreementIdToBeUpdated);
                }
            }
            system.debug('agreementIdToBeUpdated@@@@@ outside '+agreementIdToBeUpdated);

            system.debug('attachmentListToBeDisplayed@@@@@'+attachmentListToBeDisplayed);
            for(APTPS_AttachmenttSelectionWrapper agrmntAttachment : attachmentListToBeDisplayed)
            {
               system.debug('agrmntAttachment.selected@@@@@'+agrmntAttachment.selected);
         system.debug('agrmntAttachment.attachmentId@@@@@'+agrmntAttachment.attachmentId);
         system.debug('agrmntAttachment.relationship@@@@@'+agrmntAttachment.relationship);
               //system.debug('agrmntAttachment.agreementId@@@@@'+aagrmntAttachment.agreementId);
               //system.debug('agrmntSelection.agreement.Id@@@@@'+agrmntSelection.agreement.Id);
                if(agrmntAttachment.selected)
                {   
                    selectedAttachmentIds.add(agrmntAttachment.attachmentId);
          system.debug('selectedAttachmentIds@@@@@'+selectedAttachmentIds);
                    if(agrmntAttachment.relationship == 'Parent')
                    {
                        parentattachmentSelected = true;
                    }

                    if(!agreementIdToBeUpdated.contains(agrmntAttachment.agreementId))
                    {
                        agreementIdToBeUpdated.add(agrmntAttachment.agreementId);
                    }
           system.debug('agreementIdToBeUpdated@@@@@ outside '+agreementIdToBeUpdated);
                }
            }


            if(!variationScenario){//EDGE-207628 Condition added to run if variation is applicable

               if(parentAgreementSelected == false && parentattachmentSelected == false)
                {
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please choose parent agreement'));
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please choose attachment of the parent agreement'));
                   displayError = true;
                   return null;
                }

                if(!parentAgreementSelected)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please choose parent agreement'));
                    displayError = true;
                    return null;
                }

                if(!parentattachmentSelected)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please choose attachment of the parent agreement'));
                    displayError = true;
                    return null;
                }
            }
            return null;
            
        }
        catch(Exception e)
        {
            System.debug('CaLMs System exception caught: ' + e.getMessage());  
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'An exception has occuered. Please contact the system administrator'));
            return null;
        }
    }
    public PageReference populateTemplate() 
    {
       try
       {
           
            // we need to perform the merge for this email template before displaying to end-user.

            displayError = false;

            EmailTemplate emailTemplate = null; //EDGE-69042 Sonar Fix

                //Repeating this as body cannot be extracted in join query of attachments in the GetAttachments method
           for(Attachment agrmntAttachment : [select Id, Name, Body, BodyLength from Attachment where Id in : selectedAttachmentIds])
            {
                attachmentsToBeSentForReview.add(agrmntAttachment);
            }


           if(selectedEmailTemplateId != null)
           {
               emailTemplate = allEmailTemplatesMap.get(selectedEmailTemplateId);
               system.debug('@@@@ emailTemplate'+emailTemplate.id);
           }


            // construct dummy email to have Salesforce merge BrandTemplate (HTML letterhead) with our email



            Messaging.SingleEmailMessage dummyEmailMsg = new Messaging.SingleEmailMessage();
            if(emailTemplate != null)
            {
            dummyEmailMsg.setTemplateId(emailTemplate.Id);


                // This ensures that sending this email is not saved as an activity for the targetObjectId. 
                dummyEmailMsg.setSaveAsActivity(false);

                // send dummy email to populate HTML letterhead in our EmailMessage object's html body.
                String[] toAddresses = new String[]{'sbose@apttus.com'};
                dummyEmailMsg.setToAddresses(toAddresses);
                dummyEmailMsg.setReplyTo(SUPPORT_EMAIL_ADDRESS); 

                //select Id, Name,createddate,body from Attachments order by createddate desc



                // now send email and then roll it back but invocation of sendEmail() 
                // means merge of letterhead & body is done

                // TargetObject is User. This tells the emailMsg to use the email message
                // associated with our dummy User. This is necessary so we can populate our
                // email message body & subject with merge fields from template
                Savepoint sp = Database.setSavepoint();

                Account dummyAcct = new Account(Name='dummy account');
                insert dummyAcct;

                Contact dummyContact        = new Contact(AccountId=dummyAcct.Id);
                dummyContact.FirstName      = 'First';
                dummyContact.LastName       = 'Last';
                dummyContact.Email          = 'nobody@nowhere.com';
                insert dummyContact;

                dummyEmailMsg.setTargetObjectId(dummyContact.Id);
                dummyEmailMsg.setWhatId(parentAgreement.Id);
                
               // dummyEmailMsg.setSubject('Test Subject');
                //dummyEmailMsg.setHtmlBody(emailTemplate.Body);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {dummyEmailMsg});
                // now rollback our changes.
                
               // Database.rollback(sp);
              
                //Added under case 00162947
                if(dummyAcct.id !=null)
        {
          list<account> dummyAcctlst=[select id from account where id=:dummyAcct.id];
          
          set<id> dummyAcctid=new set<id>();
          for(account a: dummyAcctlst){
            dummyAcctid.add(a.id);
          }

          list<contact> dummyContactlst=[select id from contact where accountid=:dummyAcctid];
          
            if(dummyContactlst.size()>0)
            {
              delete dummyContactlst;
            }
            delete dummyAcctlst;

        }

                  // now populate our fields with values from SingleEmailMessage.
                hTMLEmailMsg.BccAddress  = UserInfo.getUserEmail();
                hTMLEmailMsg.Subject     = dummyEmailMsg.getSubject();
                hTMLEmailMsg.TextBody    = dummyEmailMsg.getHTMLBody();
                //emailMsg.ToAddress   = dummyEmailMsg.getToAddresses().get(0);
                hTMLEmailMsg.FromAddress = SUPPORT_EMAIL_ADDRESS; 
                hTMLEmailMsg.CcAddress   = '';
               // emailMsg.ParentId    = parentAgreement.Id;

                displayOutputText = 'block';
        displayInputTextarea = 'none';
                
                delete dummyContact;
                delete dummyAcct;
                Database.rollback(sp);
            }
            else
            {
                plainTextEmailMsg.BccAddress  = UserInfo.getUserEmail();
                //emailMsg.Subject     = '[Please enter subject here]';
                //emailMsg.TextBody    = '[Please enter body here]';
              //  emailMsg.ToAddress   = dummyEmailMsg.getToAddresses().get(0);
                plainTextEmailMsg.FromAddress = SUPPORT_EMAIL_ADDRESS; 
                plainTextEmailMsg.CcAddress   = '';
                displayOutputText = 'none';
        displayInputTextarea = 'block';
                // singleEmailMsg.setFileAttachments(new List<Messaging.EmailFileAttachment> {emailAttachment});
            }

            return null;
       }
        catch(Exception e)
        {
            System.debug('CaLMs System exception caught: ' + e.getMessage());  
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'An exception has occuered. Please contact the system administrator'));
            return null;
        }
    }
    
  
    
    public PageReference send() 
    {
try
        {
            Contact mailContact = null;
            User mailUser = null;
            EmailMessage emailMsg;
            string addlRecipients;
            system.debug('APTPS_User_Lookup__c===='+parentAgreement.APTPS_User_Lookup__c);
            system.debug('APTPS_User_Lookup2__c===='+parentAgreement.APTPS_User_Lookup2__c);
             // for action =Send_For_Billing_Review mail to User
           if(('Send_For_Billing_Review').equalsIgnoreCase(actionName)){ 
                if(parentAgreement.APTPS_User_Lookup__c != null)
                {
                     mailUser = [select Id, Email from User where Id =: parentAgreement.APTPS_User_Lookup__c];               
                }
    
                if(parentAgreement.APTPS_User_Lookup2__c != null)
                {
                    mailUser = [select Id, Email from User where Id =: parentAgreement.APTPS_User_Lookup2__c];            
                }
           }else{
                if(parentAgreement.APTPS_Contacts_Lookup2__c != null)
                {
                mailContact = [select Id, Email from Contact where Id =: parentAgreement.APTPS_Contacts_Lookup2__c];               
                }
    
                if(parentAgreement.APTPS_Contacts_Lookup__c != null)
                {
                    mailContact = [select Id, Email from Contact where Id =: parentAgreement.APTPS_Contacts_Lookup__c];            
                }

            }
            
            system.debug('mailUser===='+mailUser);
            if(selectedEmailTemplateId != null)
            {
                emailMsg = hTMLEmailMsg;
                //hTMLEmailMsg.TextBody = hiddenInput;
                addlRecipients = addlRecipientsHTML;
            }
            else
            {
                emailMsg = plainTextEmailMsg;
                addlRecipients = addlRecipientsPlainText;
            }


            if((mailUser == null && mailContact == null) && (addlRecipients == null || addlRecipients == ''))  
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'To Address or Additional To Address is required'));
                displayError = true;
                return null;
            }



            if(emailMsg.Subject == null || emailMsg.Subject == '')
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Subject is required'));
                displayError = true;
                return null;
            }


            List<Messaging.EmailFileAttachment> emailAttachmentsList = new  List<Messaging.EmailFileAttachment>();
            Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();

             //Repeating this as body cannot be extracted in join query of attachments in the GetAttachments method
            for(Attachment agrmntAttachment : [select Id, Name, Body, BodyLength from Attachment where Id in : selectedAttachmentIds])
            {
                emailAttachment = new Messaging.EmailFileAttachment();
                emailAttachment.setBody(agrmntAttachment.Body);
                emailAttachment.setFileName(agrmntAttachment.Name);
                emailAttachmentsList.add(emailAttachment);
            }
           // try {
                // now create our SingleEmailMessage to send out.
                Messaging.SingleEmailMessage singleEmailMsg = new Messaging.SingleEmailMessage();


                // concatenate all Bcc Addresses
                if (emailMsg.BccAddress != null && emailMsg.BccAddress != '') {
                    singleEmailMsg.setBccAddresses(emailMsg.BccAddress.split(';'));
                }

                // concatenate all CC Addresses
                if (emailMsg.CcAddress != null && emailMsg.CcAddress != '') {
                    singleEmailMsg.setCcAddresses(emailMsg.CcAddress.split(';'));
                }
                //singleEmailMsg.setOrgWideEmailAddressId(sender.Id); 

                singleEmailMsg.setSubject(emailMsg.Subject);
                singleEmailMsg.setHTMLBody(emailMsg.TextBody);

            if(emailAttachmentsList.size() > 0)
                {
            singleEmailMsg.setFileAttachments(emailAttachmentsList);
                }

                // now add additional recipients
                String[] addlToAddresses = null;
            if (addlRecipients != null && addlRecipients != '') {
                    addlToAddresses = addlRecipients.split(';');
                }

            // now lets add any additional recipients to our list of recipients.
                List<String> lstToAddresses = null;
                if (addlToAddresses != null) {
                    // now append these to our main recipient.
                    lstToAddresses = new List<String>(addlToAddresses);
                } else {
                    lstToAddresses = new List<String>();
                }

            if(mailContact != null)
                {
                lstToAddresses.add(mailContact.Email);
                }
             // for action =Send_For_Billing_Review mail to User
             if(mailUser != null)
             {
                lstToAddresses.add(mailUser.Email);
             }
                singleEmailMsg.setToAddresses(lstToAddresses); 

            // now we need to reset the ToAddress for our EmailMessage.
            if(mailContact != null)
                {
              emailMsg.ToAddress = mailContact.Email;
                }
            // for action =Send_For_Billing_Review mail to User
            if(mailUser != null)
             {
              emailMsg.ToAddress = mailUser.Email;
             }
            if(emailMsg.ToAddress != null)
                {
                emailMsg.ToAddress += (addlRecipients != null ? ';' + addlRecipients : '');
                }
                else
                {
                    if (addlRecipients != null && addlRecipients != '')
                    {
    emailMsg.ToAddress = addlRecipients;
                    }
                }

            if(mailContact != null)
                {
               singleEmailMsg.setTargetObjectId(mailContact.Id);
                }
            // for action =Send_For_Billing_Review mail to User
            if(mailUser != null)
             {
                singleEmailMsg.setTargetObjectId(mailUser.Id);
             }
            if(mailContact != null)
                {
                singleEmailMsg.setWhatId(parentAgreement.Id);
                }   
            
                singleEmailMsg.setSaveAsActivity(false);
                // now attach file to email if there is one. Have to check the Body as Attachment
                // itself will never be null as it is always created first time it is accessed.
                List<Messaging.SendEmailResult> results =  Messaging.sendEmail(
                    new List<Messaging.SingleEmailMessage> {singleEmailMsg});

                // now parse  our results
                // on success, return to calling page - Case view.
                if (results[0].success) {
                    List<Apttus__APTS_Agreement__c> agreementToBeUpdated = new List<Apttus__APTS_Agreement__c>();
                    for(Apttus__APTS_Agreement__c agreement : [select Id,Apttus__Status_Category__c, Apttus__Status__c from Apttus__APTS_Agreement__c
                                                              where Id in: agreementIdToBeUpdated])
                    {
                        if(actionName == 'Send_For_Signature')
                        {
                            agreement.Apttus__Status_Category__c = 'In Signatures';
                            agreement.Apttus__Status__c = 'Other Party Signatures';
                            agreement.APTPS_Sent_for_Wet_Signatures__c =true;
                        }
                        else if(actionName == 'Send_For_Review')
                        {
                            agreement.Apttus__Status_Category__c = 'In Authoring';
                        agreement.Apttus__Status__c = 'Other Party Review';
                        }
                         else if(actionName == 'Send_For_Billing_Review')
                        {
                            agreement.Apttus__Status_Category__c = 'In Authoring';
                            agreement.Apttus__Status__c = 'In Billing Review';
                            agreement.Is_Billing_Reviewed__c= true;
                        }
                        agreementToBeUpdated.add(agreement);
                    }

                    update agreementToBeUpdated;

                    insert emailMsg;
                    // and insert attachment into database as well, associating it with our emailMessage
                    if (attachment.Body != null) {
                        attachment.parentId=emailMsg.Id;
                        insert attachment;
                    }

                    PageReference pgRef = new PageReference('/' + parentAgreement.Id);
                    pgRef.setRedirect(true);
                    return pgRef;
                } else {
                    // on failure, display error message on existing page so return null to return there.
                    String errorMsg = 'Error sending Email Message. Details = ' + results.get(0).getErrors()[0].getMessage();
                    System.debug('==========> ' + errorMsg);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));
                    return null;
                }
          /*  }
            catch (Exception e) {
                // on failure, display error message on existing page so return null to return there.
                String errorMsg = 'Exception thrown trying to send Email Message. Details = ' + e;
                System.debug('==========> ' + errorMsg);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMsg));
                return null;
            }*/

            return null;
        }
        catch(Exception e)
        {
            System.debug('CaLMs System exception caught: ' + e.getMessage());  
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'An exception has occuered. Please contact the system administrator'));
            return null;
        }
    }
    
public PageReference cancel()
{
    PageReference pageRef = new PageReference('/'+parentAgreement.Id);
    return pageRef;
}
    
   
public class TemplateWrapper
   {
       public EmailTemplate emailTemplate{get; set;}

       //This field helps in determining whether the agreement is selected or not
       public Boolean selected{get; set;}
       
       public TemplateWrapper(EmailTemplate template)
       {
           emailTemplate = template;
           selected = false;
       }
   }
}