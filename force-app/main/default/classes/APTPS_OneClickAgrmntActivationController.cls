/*************************************************************************************************************************
 @Name: APTPS_OneClickAgrmntActivationController
 @Author: Shishir Bose
 @Created Date: 04/15/2016
 @Descripton: This controller is created for handling the One Click Agreement Activation functionality which helps in 
 activating more than one agreement attachment
 @Used By: APTPS_AgreementTriggerHandler VF page
*************************************************************************************************************************/
/************************************************************************************************************************
@ModifiedBy: Shishir Bose
@ModifiedDate: 05/23/2016
@ChangeDescription: Modified the code for the new screen of agreement activation
***************************************************************************************************************************/
/************************************************************************************************************************
@ModifiedBy: Shishir Bose
@ModifiedDate: 05/27/2016
@ChangeDescription: Modified the code for including the Mass Agreement activation functionality
***************************************************************************************************************************/
public class APTPS_OneClickAgrmntActivationController {
public List<APTPS_AgreementSelection> agreementListToBeDisplayed {get; set;}

public map<Id, APTPS_AgreementSelection> selectedAgreementList {get; set;}

public Map<Id, string> failedAgreementsForActivation {get; set;}
public Map<Id, string> successfulAgreementsForActivation {get; set;}

public Integer selectedAgreementListSize{get; set;}

public List<string> selectedAgreementListIds {get; set;}
public string agreementName{get;set;}

public Apttus__APTS_Agreement__c parentAgreement{get;set;}

public APTPS_Paginate paginater {get;set;} 

//This list holds the agreements record on one page
public List<APTPS_AgreementSelection> genericList{get;set;} 

//This list holds all the agreements record eligible for activation
public List<List<APTPS_AgreementSelection>> fullGenericList{get;set;} 

public boolean displayError {get; set;}

public string pageName{get;set;}
public string displayActivateButton {get; set;}
public string displayActivateButtonMessage {get; set;}
//This is the constructor of the class. Here we will store the agreement id for further operations
public APTPS_OneClickAgrmntActivationController(ApexPages.StandardController  stdController)
{
    //If the page name is populated the controller is called from the Home screen else from the
    //individual agreement screen
    pageName = ApexPages.currentPage().getParameters().get('page');
    failedAgreementsForActivation = new Map<Id, string>();
    successfulAgreementsForActivation = new Map<Id, string>();
    displayActivateButton = 'visible';
    displayActivateButtonMessage = 'none';
    
    //This section is for activation a single Head terms and its schedules
    if(pageName == null )
    {
        if(!test.isRunningTest()){
            stdController.addFields(new List<string>{'Name','Apttus_Approval__Approval_Status__c'});
        }
        parentAgreement = (Apttus__APTS_Agreement__c)stdController.getRecord();
        agreementName = parentAgreement.Name;
        
        if(parentAgreement.Apttus_Approval__Approval_Status__c != null && 
           (parentAgreement.Apttus_Approval__Approval_Status__c == 'Approval Required'
            || parentAgreement.Apttus_Approval__Approval_Status__c == 'Pending Approval'
           || parentAgreement.Apttus_Approval__Approval_Status__c == 'Rejected'))
        {
            displayActivateButton = 'hidden';
            displayActivateButtonMessage = 'block';
        }
    }
    else
    {
        //Populating the agreements for Mass activation
        agreementListToBeDisplayed = new List<APTPS_AgreementSelection>();
            
            for(Apttus__APTS_Agreement__c agrmnt : [select Id, Name, Apttus__Account__r.Name,(select Id, Name,createddate from Attachments order by createddate desc ),
                                                        Apttus__FF_Agreement_Number__c, Apttus__Status_Category__c, 
                                                        Apttus__Status__c,  Apttus__Agreement_Category__c,  Apttus__Subtype__c, 
                                                        Apttus__Parent_Agreement__c, Apttus__Company_Signed_Date__c, createddate,
                                                        Apttus__Contract_Start_Date__c, Apttus__Term_Months__c, Apttus__Contract_End_Date__c from Apttus__APTS_Agreement__c
                                                        where Apttus__Status_Category__c = 'In Signatures' and Apttus__Status__c = 'Fully Signed – Migrated' 
                                                        order by createddate])
            {
                //Converting the agreement record into APTPS_AgreementSelection wrapper class
                agreementListToBeDisplayed.add(new APTPS_AgreementSelection(agrmnt));
            }
        
        //Getting the page size from comply system properties 
        Apttus__ComplySystemProperties__c complyCustomSettings = Apttus__ComplySystemProperties__c.getValues('System Properties');
        boolean textField = null;
    
        Integer pageSize = complyCustomSettings.APTPS_Mass_Activation_Page_Size__c.intValue(); 
            
        //Create a new instance of Paginate passing in the overall size of 
        //the list of data and the page size you want 
        this.paginater = new APTPS_Paginate(agreementListToBeDisplayed.size(), pageSize);
        
        
        genericList = new List<APTPS_AgreementSelection>();
        fullGenericList = new List<List<APTPS_AgreementSelection>>();
    
        //Break out the full list into a list of lists 
        if(agreementListToBeDisplayed.size() > 0)
        { 
            List<APTPS_AgreementSelection> tempCC = new List<APTPS_AgreementSelection>(); 
            Integer i = 0; 
            integer pageNumber = 1;
            for(APTPS_AgreementSelection cc : agreementListToBeDisplayed)
            { 
                cc.pageNumber = pageNumber;
                tempCC.add(cc); 
                i++; 
                if(i == pageSize)
                { 
                    this.fullGenericList.add(tempCC); 
                    tempCC = new List<APTPS_AgreementSelection>(); 
                    i = 0; 
                    pageNumber++;
                } 
            } 
            
            if(!tempCC.isEmpty())
            { 
                this.fullGenericList.add(tempCC); 
            } 
            
            //Gets the correct list of data to show on the page 
            this.genericList = this.fullGenericList.get(this.paginater.index); 
        } 
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
        agreementListToBeDisplayed = new List<APTPS_AgreementSelection>();
        APTPS_AgreementSelection agreementSelection = null;
        for(Apttus__APTS_Agreement__c agrmnt : [select Id, Name, Apttus__Account__r.Name,(select Id, Name,createddate from Attachments order by createddate desc ),
                                                    Apttus__FF_Agreement_Number__c, Apttus__Status_Category__c, 
                                                    Apttus__Status__c,  Apttus__Agreement_Category__c,  Apttus__Subtype__c, 
                                                    Apttus__Parent_Agreement__c, Apttus__Company_Signed_Date__c, createddate,
                                                    Apttus__Contract_Start_Date__c, Apttus__Term_Months__c, Apttus__Contract_End_Date__c from Apttus__APTS_Agreement__c
                                                     where   ((Apttus__Status_Category__c = 'In Signatures' and (Apttus__Status__c ='Fully Signed - Migrated' or Apttus__Status__c ='Fully Signed'))
                                                           or (Apttus__Status_Category__c = 'In Filing' and Apttus__Status__c = 'To Be Activated'))
                                               and 
                                                    (Id =:parentAgreement.Id or Apttus__Parent_Agreement__c =:parentAgreement.Id )
                                                    order by createddate])
        {
            //Converting the agreement record into APTPS_AgreementSelection wrapper class
           agreementSelection = new APTPS_AgreementSelection(agrmnt);
           agreementSelection.selected = true;
           agreementListToBeDisplayed.add(agreementSelection);
        }
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
 @Name: cancel
 @Author: Shishir Bose
 @Created Date: 04/12/2016
 @Descripton: This method is called on clicking cancel button on VF page and takes the user back on agreement page
*************************************************************************************************************************/
public PageReference cancel()
{
    try
    {
        if(successfulAgreementsForActivation.size() > 0 || failedAgreementsForActivation.size() > 0)
        {
            sendMail();
        }
        PageReference pageRef = new PageReference('/home/home.jsp');
        if(pageName == null)
        {
            pageRef = new PageReference('/'+parentAgreement.Id);
        }
        pageRef.setredirect(true);
        
        return pageRef;
    }catch(Exception e)
    {
        System.debug('CaLMs System exception caught: ' + e.getMessage());  
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'An exception has occuered. Please contact the system administrator'));   
        return null;
    }
}

/*************************************************************************************************************************
 @Name: sendMail
 @Author: Shishir Bose
 @Created Date: 05/27/2016
 @Descripton: This method is called for sending mails in case an error occurs while activation agreements
*************************************************************************************************************************/
@testVisible private void sendMail()
{
    // Now create a new single email message object
    // that will send out a single email to the addresses in the To, CC & BCC list.
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    
    // Strings to hold the email addresses to which you are sending the email.
    string userEmail = Userinfo.getUserEmail();
    
    String[] toAddresses = new String[] {userEmail}; 
     
    // Assign the addresses for the To lists to the mail object.
    mail.setToAddresses(toAddresses);
    
    
    // Specify the address used when the recipients reply to the email. 
    //mail.setReplyTo('support@acme.com');
    
    // Specify the name used as the display name.
    mail.setSenderDisplayName('Salesforce Support');
    
    // Specify the subject line for your email address.
    mail.setSubject('Mass Agreement(s) Activation status');
    
    
    
    // Specify the text content of the email.
  
    APTPS_AgreementSelection selectedAgreement = null;
    
    
    string mailBody = 'Dear ' + Userinfo.getName();
    
    //These agreements are successfully activated
    if(successfulAgreementsForActivation.size() > 0)
    {
        mailBody = mailBody + ',<br/><br/><br/> The following Agreement(s) are activated: <br/><br/>';
        
        for(Id agreementId : successfulAgreementsForActivation.keySet() )
        {
            selectedAgreement = selectedAgreementList.get(agreementId);         
            mailBody = mailBody + 'Agreement Name: ' + '<b><i><ins>' +   selectedAgreement.agreement.Name +'</ins></i></b>' +', Agreement Number: ' + '<b><i><ins>' + selectedAgreement.agreement.Apttus__FF_Agreement_Number__c +'</ins></i></b>'+'<br/>';
           
        }
    }
    
    //These agreements failed to activate
    if(failedAgreementsForActivation.size() > 0)
    {
        mailBody = mailBody + '<br/><br/><br/> The following Agreement(s) are not activated: <br/><br/>';
        string errorMsg = null;
        for(Id agreementId : failedAgreementsForActivation.keySet() )
        {
          selectedAgreement = selectedAgreementList.get(agreementId);         
          mailBody = mailBody + 'Agreement Name: ' + '<b><i><ins>' +   selectedAgreement.agreement.Name +'</ins></i></b>' +', Agreement Number: ' + '<b><i><ins>' + selectedAgreement.agreement.Apttus__FF_Agreement_Number__c +'</ins></i></b>'+'<br/>';

          errorMsg = failedAgreementsForActivation.get(agreementId);
          mailBody = mailBody + 'Error Message: ' + errorMsg + '<br/><br/>' ;

        }
    }
    
    mail.setHtmlBody(mailBody);
    if(!Test.isRunningTest()){
     Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}

    /*************************************************************************************************************************
    @Name: previousPage
    @Author: Shishir Bose
    @Created Date: 05/27/2016
    @Descripton: This method is called for setting the previous page. Called from pagination control
    *************************************************************************************************************************/
    public PageReference previousPage()
    { 
        this.paginater.decrement(); 
        return changeData(); 
    } 
    
    /*************************************************************************************************************************
    @Name: nextPage
    @Author: Shishir Bose
    @Created Date: 05/27/2016
    @Descripton: This method is called for setting the next page. Called from pagination control
    *************************************************************************************************************************/
    public PageReference nextPage()
    { 
        this.paginater.increment(); 
        return changeData(); 
    } 
    
    /*************************************************************************************************************************
    @Name: updatePage
    @Author: Shishir Bose
    @Created Date: 05/27/2016
    @Descripton: This method is called for setting the page as per selected page number. Called from pagination control
    *************************************************************************************************************************/
    public PageReference updatePage()
    { 
        this.paginater.updateNumbers(); 
        return changeData(); 
    } 
    
    /*************************************************************************************************************************
    @Name: changeData
    @Author: Shishir Bose
    @Created Date: 05/27/2016
    @Descripton: This method populates the list of agreements to be displayed on mass activation screen from the list 
    of all eligible agreements
    *************************************************************************************************************************/
    public PageReference changeData()
    {
        this.genericList = this.fullGenericList.get(this.paginater.index); 
        return null; 
    } 


/*************************************************************************************************************************
 @Name: createListForActivateAgreements
 @Author: Shishir Bose
 @Created Date: 04/12/2016
 @Descripton: This method is called on clicking activate button. It populates a list of selected agreement and kicks off 
 the agreement activation process
*************************************************************************************************************************/
public PageReference createListForActivateAgreements()
{
    try
    {
        selectedAgreementList = new map<Id, APTPS_AgreementSelection>();
        selectedAgreementListIds = new List<string>();
        selectedAgreementListSize = 0;
        boolean companySignedDateExist = true;
        string errorMessage;
        displayError = false;
        for(APTPS_AgreementSelection agrGen : agreementListToBeDisplayed)
        {
            //Adding the selected agreement to the list
            if(agrGen.selected == true)
            {
                //Validation for Agreement Company Signed date
                if(agrGen.agreement.Apttus__Company_Signed_Date__c != null)
                {
                    //Validation to check whether agreement is selected for activation
                    if(CheckDocumentsandValidate(agrGen))
                    {
                       selectedAgreementList.put(agrGen.agreement.Id,agrGen);
                       selectedAgreementListIds.add(agrGen.agreement.Id);
                    }
                }
                else
                {
                    if(pageName == null)
                    {
                        errorMessage = 'Company Signed Date must be populated before activating the agreement - ' + agrGen.agreement.Apttus__FF_Agreement_Number__c;
                    }
                    else
                    {
                        errorMessage = 'Company Signed Date must be populated before activating the agreement - ' + agrGen.agreement.Apttus__FF_Agreement_Number__c  + ', Page Number: ' + agrGen.pageNumber;
                    }
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,errorMessage));
                    
                    companySignedDateExist = false;
                }
            }
        }
        
        if(companySignedDateExist)
        {
            //Checking if any agreement is selected or not to send the error message on screen
            if(selectedAgreementList.size() == 0 && !displayError)
            {
                selectedAgreementListSize = 0;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'Please select at least one agreement record for activation.'));
            }
            
            else
            {
                selectedAgreementListSize = selectedAgreementList.size();
                
            }
        }
        
        return null;
   }
    catch(Exception e)
    {
        System.debug('CaLMs System exception caught: ' + e.getMessage());  
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'public PageReference createListForActivateAgreements()'));   
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'An exception has occuered. Please contact the system administrator'));   
        return null;
    }
}

/*************************************************************************************************************************
 @Name: CheckDocumentsandValidate
 @Author: Shishir Bose
 @Created Date: 05/23/2016
 @Descripton: This method is to validate whether attachments are selected for agreements which are selected for activation 
 and also that the selected attachments should not be selected for removal from notes and attachments
 the agreement activation process
*************************************************************************************************************************/
@testVisible private boolean CheckDocumentsandValidate(APTPS_AgreementSelection agreementSelection)
{
    string errorMessage;
    set<string> tempSet = new set<string>();
    agreementSelection.agreementsToBeActivated = new List<string>(); 
    if(agreementSelection.attachmentsForActivation != null && agreementSelection.attachmentsForActivation.size() > 0)
    {
        for(APTPS_AgreementAttachmentWrapper attach : agreementSelection.attachmentsForActivation)
        {
            if(attach.selected)
            {
                //Create a list of selected attachments
                agreementSelection.agreementsToBeActivated.add(attach.agreementAttachment.Id); 
                tempSet.add(attach.agreementAttachment.Id);
            }
        }
    }
    else
    {
        if(pageName == null)
        {
            errorMessage = 'No document or attachment found. This agreement must have a document or attachment to continue. - ' + agreementSelection.agreement.Name;
        }
        else
        {
            errorMessage = 'No document or attachment found. This agreement must have a document or attachment to continue. - ' + agreementSelection.agreement.Name + ', Page Number: ' + agreementSelection.pageNumber;
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,errorMessage ));
                
        displayError = true;
        
        return !displayError;
    }
    
    if(agreementSelection.agreementsToBeActivated.size() == 0)
    {
        //If the page name is populated the controller is called from the Home screen else from the
        //individual agreement screen
        if(pageName == null)
        {
            errorMessage = 'Attachment needs to be selected for Activation and Content Search. - ' + agreementSelection.agreement.Name;
        }
        else
        {
            errorMessage = 'Attachment needs to be selected for Activation and Content Search. - ' + agreementSelection.agreement.Name + ', Page Number: ' + agreementSelection.pageNumber;
        }
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,errorMessage ));
                
        displayError = true;
    }
    
    agreementSelection.attachmentsSelectedForRemoving = new List<string>();
    for(APTPS_AgreementAttachmentWrapper attach : agreementSelection.attachmentsForRemoving)
    {
        if(attach.selected)
        {
            //agreementSelection.attachmentsSelectedForRemoving.add(attach.agreementAttachment.Id); 
            if(tempSet.contains(String.valueOf(attach.agreementAttachment.Id)))
            {
                //If the page name is populated the controller is called from the Home screen else from the
                //individual agreement screen
                if(pageName == null)
                {
                    errorMessage = 'Attachment selected for activation cannot be removed. - ' + agreementSelection.agreement.Name;
                }
                else
                {
                    errorMessage = 'Attachment selected for activation cannot be removed. - ' + agreementSelection.agreement.Name + ', Page Number: ' + agreementSelection.pageNumber;
                }
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,errorMessage ));
                
                displayError = true;
            }
            else
            {
               agreementSelection.attachmentsSelectedForRemoving.add(attach.agreementAttachment.Id); 
                
            }
            
        }
    }
    return !displayError;
}

/*************************************************************************************************************************
 @Name: activateAgreementAsync
 @Author: Shishir Bose
 @Created Date: 04/12/2016
 @Descripton: This method is called by VF page. This method calls the APTPS_AgreementActivationUtil 
*************************************************************************************************************************/

public void activateAgreementAsync()
{
    try
    {
        string agreementId = String.valueOf(ApexPages.currentPage().getParameters().get('agreementId')).trim();
         
         APTPS_AgreementSelection selectedAgreement = selectedAgreementList.get(Id.valueOf(agreementId));
         
         string returnMessage = null;
         
         //String[] activateDocIds = new String[]{selectedAgreement.agreementToBeActivatedId}; 
         returnMessage = APTPS_AgreementActivationUtil.activateAgreement(selectedAgreement.agreement.Id, selectedAgreement.agreementsToBeActivated, selectedAgreement.attachmentsSelectedForRemoving);
         
        
         if(returnMessage != null)
         {
            failedAgreementsForActivation.put(selectedAgreement.agreement.Id, returnMessage);
         }
        else
        {
            successfulAgreementsForActivation.put(selectedAgreement.agreement.Id, returnMessage);
        }
        
    }
    catch(Exception e)
    {
        System.debug('CaLMs System exception caught: ' + e.getMessage());  
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'An exception has occuered. Please contact the system administrator'));   
    }
      
}




}