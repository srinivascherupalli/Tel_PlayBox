/*************************************************************************************************************************
 @Name: APTPS_MergeAgrmntAttachmentsController
 @Author: Shishir Bose
 @Created Date: 05/10/2016
 @Descripton: This controller is created for merging the attachments for Conform Agreements functionality
 activating more than one agreement attachment
 @Used By: APTPS_Init_MergeAgreementAttachments VF page
*************************************************************************************************************************/

public class APTPS_MergeAgrmntAttachmentsController {

public List<APTPS_AttachmenttSelectionWrapper> attachmentListToBeDisplayed {get; set;}

public Apttus__APTS_Agreement__c parentAgreement {get; set;}

public string agreementName{get;set;}

public boolean showError {get; set;}

//This is the constructor of the class. Here we will store the agreement id for further operations
public APTPS_MergeAgrmntAttachmentsController(ApexPages.StandardController  stdController)
{
    if(!Test.isRunningTest()){
    stdController.addFields(new List<string>{'Name','Apttus__FF_Agreement_Number__c'});
}
    parentAgreement = (Apttus__APTS_Agreement__c)stdController.getRecord();
    agreementName = parentAgreement.Name;
}


/*************************************************************************************************************************
 @Name: getAttachments
 @Author: Shishir Bose
 @Created Date: 05/10/2016
 @Descripton: This method returns the list of attachments for Parent and Child Agreement
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
                                                        Apttus__Status__c, Apttus__Parent_Agreement__c,createddate,APTPS_Schedule_Number_Text__c,
                                                        (select Id, Name,createddate from Attachments order by createddate desc )  from Apttus__APTS_Agreement__c
                                                        where Id =:parentAgreement.Id or Apttus__Parent_Agreement__c =:parentAgreement.Id 
                                                         order by Apttus__FF_Agreement_Number__c ])
            {
                //Converting the agreement attachment record into APTPS_AttachmenttSelectionWrapper wrapper class

                attachments = agrmnt.attachments;

                if(attachments != null && attachments.size() > 0)
                {
                    for(attachment attch : attachments)
                    {
                        if(!attch.Name.contains(APTPS_Constants.MERGED_DOCUMENT_FILE_NAME))
                        {
                            if(agrmnt.Id != agreementId)
                            {
                                attachmentListToBeDisplayed.add(new APTPS_AttachmenttSelectionWrapper(agrmnt,attch, true));
                                agreementId = agrmnt.Id;
                            }
                            else
                            {
                                attachmentListToBeDisplayed.add(new APTPS_AttachmenttSelectionWrapper(agrmnt,attch, false));
                            }
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

/*************************************************************************************************************************
 @Name: createListofAgreementsToMerge
 @Author: Shishir Bose
 @Created Date: 05/10/2016
 @Descripton: This method is called on Merge button. It validates the user input then populate a list of selected 
 attachments for merging
*************************************************************************************************************************/
public PageReference createListofAgreementsToMerge()
{
    List<APTPS_AttachmenttSelectionWrapper> attachmentsToBeMerged = new List<APTPS_AttachmenttSelectionWrapper>();
    map<integer,Id> attachmentMap = new map<integer,Id>();
    string errorMessage;
    List<id> documentIds;
    showError = false;
    
    try
    {
        for(APTPS_AttachmenttSelectionWrapper attchmnt : attachmentListToBeDisplayed)
        {
            //Adding the selected attachment to the list
            if(attchmnt.selected == true)
            {
                //Validation for attachment sequence
                if(attchmnt.sequence != 0)
                {
                    //Unique Sequence Number validation
                    if(attachmentMap.containsKey(attchmnt.sequence))
                    {
                        errorMessage = 'Please enter unique sequence number for the selected attachments';
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,errorMessage));
                        showError = true;
                        return null;
                    }
                    else
                    {
                        attachmentMap.put(attchmnt.sequence, attchmnt.attachmentId);
                        attachmentsToBeMerged.add(attchmnt);
                    }
                }
                else
                {

                    if(attchmnt.agreementId != parentAgreement.Id)
                    {
                        errorMessage = 'Please enter sequence for the selected attachments';
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,errorMessage));
                        showError = true;
                        return null;
                    }
                    else
                    {
                        //Special condition for parent agreement only
                          //Unique Sequence Number validation
                        if(attachmentMap.containsKey(attchmnt.sequence))
                        {
                            errorMessage = 'Please enter unique sequence number for the selected attachments';
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,errorMessage));
                            showError = true;
                            return null;
                        }
                        else
                        {
                            attachmentMap.put(attchmnt.sequence, attchmnt.attachmentId);
                            attachmentsToBeMerged.add(attchmnt);
                        }                    
                    }
                }
            }
        }

        //Validation to check whether at least 2 attachments are selected for merging
        if(attachmentsToBeMerged.size() == 0 || attachmentsToBeMerged.size() == 1)
        {
            errorMessage = 'Please select at least two attachment record for merge.';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,errorMessage));
            showError = true;
        }
        else
        {
            attachmentsToBeMerged.sort();
            documentIds = new List<id>();
            for(APTPS_AttachmenttSelectionWrapper wrp : attachmentsToBeMerged)
            {
                documentIds.add(wrp.attachmentId);
            }
            //Calling the method to merge agreements
            mergeDocument(documentIds);
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

/*************************************************************************************************************************
 @Name: mergeDocument
 @Author: Shishir Bose
 @Created Date: 05/10/2016
 @Descripton: This method is called to merge the selected attachments
*************************************************************************************************************************/
private void mergeDocument(List<id> documentIds)
{
    String apiSessionId = UserInfo.getSessionId(); 
    String apiServerURL = System.Url.getSalesforceBaseUrl(). toExternalForm() + APTPS_Constants.SOAP_API_ADDRESS + UserInfo.getOrganizationId(); 
    string fileName = APTPS_Constants.MERGED_DOCUMENT_FILE_NAME + '.pdf';
    if(!Test.isRunningTest()){
    String generatedDocId = Apttus.MergeWebService.mergeDocsToPDF(parentAgreement.Id, documentIds, fileName, apiSessionId,apiServerURL);
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
    PageReference pageRef = new PageReference('/'+parentAgreement.Id);
    return pageRef;
}




}