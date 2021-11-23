/*************************************************************************************************************************
 @Name: APTPS_AgreementActivationUtil
 @Author: Shishir Bose
 @Created Date: 04/15/2016
 @Descripton: This utility is used to activate the agreement by calling the API and on successful activation
 post the activated agreement to chatter
 @Used By: APTPS_PerformAgreementActivationBatch and APTPS_OneClickAgrmntActivationController
*************************************************************************************************************************/
public class APTPS_AgreementActivationUtil {
    

 /*************************************************************************************************************************
 @Name: activateAgreement
 @Author: Shishir Bose
 @Created Date: 04/14/2016
 @Descripton: This method activates the agreement
*************************************************************************************************************************/

    public Static void activateAgreement(Apttus__APTS_Agreement__c agreement)
    {
        try
        {
            Attachment agreementAttachment = null;
            List<Attachment> attachments = agreement.attachments;
            
            //Check if the agreement has "_signed.pdf" in the name
            for(attachment attch : attachments)
            {
                if(attch.Name.contains('_signed.pdf'))
                {
                    agreementAttachment = new Attachment();
                    agreementAttachment = attch;
                }
            }
            
           if(attachments != null && attachments.size() > 0)
            {
                //In case there are no agreements with "_signed.pdf" in the name pick the latest agreement
                if(agreementAttachment == null)
                {
                    for(integer index = 0; index < attachments.size(); index++)
                    {
                        if(!attachments[index].Name.contains(APTPS_Constants.MERGED_DOCUMENT_FILE_NAME))
                        {
                            agreementAttachment = attachments[index];
                            break;
                        }
                    }
                }
            
                String[] activateDocIds = new String[]{agreementAttachment.Id}; 
                String[] remDocIds = new String[]{};
                
                Boolean response = null;
                if(!Test.isRunningTest()){
                    response = Apttus.AgreementWebService.activateAgreement (agreement.Id, activateDocIds, remDocIds);
                }
                if(Test.isRunningTest()){
                    response =true;
                }
                if(response)
                {
                    postToChatter(agreement.Id, agreementAttachment.Id);
                }
            }
        }
        catch(Exception e)
        {
            System.debug('CaLMs System exception caught: ' + e.getMessage());  
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'An exception has occuered. Please contact the system administrator'));   
        }
    
    }
    
    /*************************************************************************************************************************
     @Name: activateAgreement
     @Author: Shishir Bose
     @Created Date: 05/15/2016
     @Descripton: This method activates the agreement. This method will receive the list of attachments to activate and
                  attachments to remove from the calling method
    *************************************************************************************************************************/
    public Static string activateAgreement(Id agreementId, String[] activateDocIds, String[] remDocIds)
    {
        try{
            Boolean response = null;
            if(!Test.isRunningTest()){
                response = Apttus.AgreementWebService.activateAgreement (agreementId, activateDocIds, remDocIds);
            }
            if(Test.isRunningTest()){
                response =true;
            }
			if(response)
            {
                for(string docId : activateDocIds)
                {
                    postToChatter(agreementId, Id.valueOf(docId));
                }
            }
        } 
        catch (Exception ex)
        {
            if (ex.getMessage().contains('[Apttus__Contract_End_Date__c]'))
            {
                return 'Please enter the Agreement End Date or mark the Agreement as Perpetual prior to activating the agreement.';
            }
            return ex.getMessage();
        }
      return null;
    }
    
 /*************************************************************************************************************************
 @Name: postToChatter
 @Author: Shishir Bose
 @Created Date: 04/14/2016
 @Descripton: This method posts the activated agreement to chatter
*************************************************************************************************************************/    
    private Static void postToChatter(Id agreementId, Id attachmentId)
    {
        Boolean response = null;
        if(!Test.isRunningTest()){
            response = Apttus.AgreementWebService.publishToChatterRepository (agreementId, attachmentId);
        }
        if(Test.isRunningTest()){
            response =true;
        }
    }

}