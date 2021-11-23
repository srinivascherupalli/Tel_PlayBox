/*************************************************************************************************************************
 @Name: APTPS_AgreementSelection
 @Author: Shishir Bose 
 @Created Date: 04/12/2016
 @Descripton: This is the wrapper class used to display the agreements on the VF Page
 @Used By: APTS_OneClickAgrmntGenerationController controller
**************************************************************************************************************************/

/*************************************************************************************************************************
 @Modified By: Shishir Bose
 @Modified Date: 04/12/2016
 @Descripton: Created new constructors for send for signature functionality  public APTPS_AgreementSelection(Apttus__APTS_Agreement__c agmt, boolean isLatesAgreement)
 and made the class global to have Comparable interface so that the wrapper class can be sorted on sequence number.
**************************************************************************************************************************/

global class APTPS_AgreementSelection implements Comparable{

     public Apttus__APTS_Agreement__c agreement{get; set;}
    
    //This field helps in determining whether the agreement is selected or not
    public Boolean selected{get; set;}
    
    //This field helps in determining whether the agreement relationship
    public string relationship{get; set;}
    
    public string accountName{get; set;}
    
    public String[] agreementsToBeActivated {get; set;}
    
    public String[] attachmentsSelectedForRemoving {get; set;}
    
    public List<APTPS_AgreementAttachmentWrapper> attachmentsForActivation {get; set;}
    public List<APTPS_AgreementAttachmentWrapper> attachmentsForRemoving {get; set;}
    public string contract {get; Set;}
    //This field is required to capture page number in case the APTPS_AgreementSelection list is used with paging
    //will help in identifying the page number.
    public integer pageNumber {get; set;}
    
    //This field is to capture the sequence number so that the agreements can be sorted on Schedule number.
     public integer sequence{get; set;}
   
    public APTPS_AgreementSelection(Apttus__APTS_Agreement__c agmt)
    {
        agreement = agmt;
        selected = false;
        attachmentsSelectedForRemoving = null;
        agreementsToBeActivated = null;
        pageNumber = 0;
        List<Attachment> attachments = agmt.attachments;
        
        //If Parent Agreement ID is null then the agreement is Parent else Chilc
        if(agmt.Apttus__Parent_Agreement__c == null)
        {
            relationship = 'Parent';
        }
        else
        {
            relationship = 'Child';
        }
        //Creating two list of attachments for agreement, one for activation, other for removal
        if(attachments != null && attachments.size() > 0)
        {
            attachmentsForActivation = new List<APTPS_AgreementAttachmentWrapper>();
            attachmentsForRemoving = new List<APTPS_AgreementAttachmentWrapper>();
            for(attachment attach : attachments)
            {
                attachmentsForActivation.add(new APTPS_AgreementAttachmentWrapper(attach));
                attachmentsForRemoving.add(new APTPS_AgreementAttachmentWrapper(attach));
            }
        }
    }
    
    public APTPS_AgreementSelection(Apttus__APTS_Agreement__c agmt, string contractType)
    {
        agreement = agmt;
        selected = false;
        attachmentsSelectedForRemoving = null;
        agreementsToBeActivated = null;
        pageNumber = 0;
        List<Attachment> attachments = agmt.attachments;
        contract = contractType;
        //If Parent Agreement ID is null then the agreement is Parent else Chilc
        if(agmt.Apttus__Parent_Agreement__c == null)
        {
            relationship = 'Parent';
        }
        else
        {
            relationship = 'Child';
        }
        //Creating two list of attachments for agreement, one for activation, other for removal
        if(attachments != null && attachments.size() > 0)
        {
            attachmentsForActivation = new List<APTPS_AgreementAttachmentWrapper>();
            attachmentsForRemoving = new List<APTPS_AgreementAttachmentWrapper>();
            for(attachment attach : attachments)
            {
                attachmentsForActivation.add(new APTPS_AgreementAttachmentWrapper(attach));
                attachmentsForRemoving.add(new APTPS_AgreementAttachmentWrapper(attach));
            }
        }
    }
    
    public APTPS_AgreementSelection(Apttus__APTS_Agreement__c agmt, boolean isLatesAgreement)
    {
        agreement = agmt;
        selected = false;
        attachmentsSelectedForRemoving = null;
        agreementsToBeActivated = null;
        pageNumber = 0;
        List<Attachment> attachments = agmt.attachments;
        
        
        //If Parent Agreement ID is null then the agreement is Parent else Chilc
        if(agmt.Apttus__Parent_Agreement__c == null)
        {
            relationship = 'Parent';
        }
        else
        {
            relationship = 'Child';
        }
        
        //Asigning the schedule number that will be used for custom sort
       if (agmt.Apttus__Parent_Agreement__c == null)
			{
				sequence = 1;
			}
			else
			{
                  //  commented by akanksha for schedule number type change 
			/*	if (agmt.APTPS_Schedule_Number__c != null)
				{
					sequence = agmt.APTPS_Schedule_Number__c.intValue();
				}
			*/	
			}
       
    }
    
    // Compare agreements based on the sequence.
    global Integer compareTo(Object compareTo) {
        // Cast argument to APTPS_AgreementSelection wrapper
        APTPS_AgreementSelection compareToAgreementWrapper = (APTPS_AgreementSelection)compareTo;
        
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if (sequence > compareToAgreementWrapper.sequence) {
            // Set return value to a positive value.
            returnValue = 1;
        } else if (sequence < compareToAgreementWrapper.sequence) {
            // Set return value to a negative value.
            returnValue = -1;
        }
        
        return returnValue;       
    }
    
}