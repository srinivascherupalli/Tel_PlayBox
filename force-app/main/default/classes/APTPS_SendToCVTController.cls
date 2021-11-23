/*************************************************************************************************************************
 @Name: APTPS_SendToCVTController
 @Author: Shishir Bose
 @Created Date: 03/20/2017
 @Descripton: This controller is created for handling the Manual Send to CVT process
 @Used By: APTPS__Init_SendToCVT VF page
*************************************************************************************************************************/

public with sharing class APTPS_SendToCVTController {
public List<APTPS_AgreementSelection> agreementListToBeDisplayed {get; set;}

public map<Id, Apttus__APTS_Agreement__c> selectedAgreementList {get; set;}

public APTPS_Paginate paginater {get;set;} 

//This list holds the agreements record on one page
public List<APTPS_AgreementSelection> genericList{get;set;} 

//This list holds all the agreements record eligible for activation
public List<List<APTPS_AgreementSelection>> fullGenericList{get;set;} 

public boolean displayError {get; set;}

public string displayActivateButton {get; set;}
public string displayActivateButtonMessage {get; set;}
//This is the constructor of the class. Here we will store the agreement id for further operations
public APTPS_SendToCVTController(ApexPages.StandardController  stdController)
{   
    displayActivateButton = 'visible';
    displayActivateButtonMessage = 'none';
    
    //Populating the agreements for Mass activation
    agreementListToBeDisplayed = new List<APTPS_AgreementSelection>();
        
        for(Apttus__APTS_Agreement__c agrmnt : [select Id, Name, Apttus__Account__r.Name,
                                                    Apttus__FF_Agreement_Number__c, Apttus__Status_Category__c, 
                                                    Apttus__Status__c,  Apttus__Agreement_Category__c,APTPS_Agreement_Subcategory__c,   Apttus__Subtype__c, 
                                                    Apttus__Parent_Agreement__c, createddate,
                                                    Apttus__Contract_Start_Date__c, Apttus__Term_Months__c, Apttus__Contract_End_Date__c, APTPS_Is_Eligible_For_CVT_Transfer__c,
                                                    APTPS_Send_Message_To_CVT_Manually__c, APTPS_Is_Custom_Update__c from Apttus__APTS_Agreement__c
                                                    where APTPS_Is_Eligible_For_CVT_Transfer__c = True
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



/*************************************************************************************************************************
 @Name: cancel
 @Author: Shishir Bose
 @Created Date: 04/12/2016
 @Descripton: This method is called on clicking cancel button on VF page and takes the user back on Home Page
*************************************************************************************************************************/
public PageReference cancel()
{
    try
    {
        PageReference pageRef = new PageReference('/home/home.jsp');
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
public PageReference createListForAgreementsToBeSent()
{
    try
    {
        selectedAgreementList = new map<Id, Apttus__APTS_Agreement__c>();
        string errorMessage;
        displayError = false;
        for(APTPS_AgreementSelection agrGen : agreementListToBeDisplayed)
        {
            selectedAgreementList.put(agrGen.agreement.Id,agrGen.agreement);
        }
        
        updateFieldToSendAgreementToCVT(selectedAgreementList.values());
        sendMail(selectedAgreementList.values());
        return cancel();
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
 @Name: updateFieldToSendAgreementToCVT
 @Author: Shishir Bose
 @Created Date: 03/20/2017
 @Descripton: This method is used to update APTPS_Send_Message_To_CVT_Manually__c field which will trigger workflow
*************************************************************************************************************************/

public void updateFieldToSendAgreementToCVT(List<Apttus__APTS_Agreement__c> agreementsToBeSentToCVT)
{
    try
    {
        string returnMessage = null;
        
        for(Apttus__APTS_Agreement__c agrmnt : agreementsToBeSentToCVT)
        {
            agrmnt.APTPS_Is_Eligible_For_CVT_Transfer__c = false;
            agrmnt.APTPS_Send_Message_To_CVT_Manually__c = true;
            agrmnt.APTPS_Is_Custom_Update__c = true;
            
        }
        
        Update agreementsToBeSentToCVT;
         
        
    }
    catch(Exception e)
    {
        System.debug('CaLMs System exception caught: ' + e.getMessage());  
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'An exception has occuered. Please contact the system administrator'));   
    }
      
}

/*************************************************************************************************************************
 @Name: sendMail
 @Author: Shishir Bose
 @Created Date: 05/27/2016
 @Descripton: This method is called for sending mails in case an error occurs while activation agreements
*************************************************************************************************************************/
@testVisible private void sendMail(List<Apttus__APTS_Agreement__c> agreementsToBeSentToCVT)
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
    mail.setSubject('Agreement(s) Notified to CVT');
    
    
    
    // Specify the text content of the email.
  
    APTPS_AgreementSelection selectedAgreement = null;
    
    
    string mailBody = 'Dear ' + Userinfo.getName();
    
    mailBody = mailBody + ',<br/><br/><br/> The following Agreement(s) are Notified to CVT: <br/><br/>';
    
    for(Apttus__APTS_Agreement__c agrmnt : agreementsToBeSentToCVT)
    {
        mailBody = mailBody + 'Agreement Name: ' + '<b><i><ins>' +   agrmnt.Name +'</ins></i></b>' +', Agreement Number: ' + '<b><i><ins>' + agrmnt.Apttus__FF_Agreement_Number__c +'</ins></i></b>'+'<br/>';
        
    }
        
    
    mail.setHtmlBody(mailBody);
    
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    
    
}


}