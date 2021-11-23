/*************************************************************************************************************************
 @Name: APTPS_AgreementAttachmentWrapper
 @Author: Shishir Bose
 @Created Date: 05/20/2016
 @Descripton: This is the wrapper class used to display the attachments of agreements
 @Used By: APTPS_AgreementSelection class
**************************************************************************************************************************/
public class APTPS_AgreementAttachmentWrapper {
    
     //This field helps in determining whether the attachment is selected or not
    public Boolean selected{get; set;}
    
    public Attachment agreementAttachment{get; set;}
    
    public APTPS_AgreementAttachmentWrapper(Attachment agreementAttachment)
    {
        this.agreementAttachment = agreementAttachment;
        selected = false;
        
    }

}