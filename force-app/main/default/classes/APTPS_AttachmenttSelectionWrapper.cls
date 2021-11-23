/*************************************************************************************************************************
 @Name: APTPS_AttachmenttSelectionWrapper
 @Author: Shishir Bose
 @Created Date: 05/20/2016
 @Descripton: This is the wrapper class used to display the attachments of agreements
 @Used By: APTPS_AgreementSelection class
**************************************************************************************************************************/
global class APTPS_AttachmenttSelectionWrapper  implements Comparable{
    
    public id attachmentId{get; private set;}
    public id agreementId{get; private set;}
    
    public string attachmentName{get; private set;}
    
    public integer sequence{get; set;}
    
    public string agreementName{get; private set;}
    
    public string agreementNumber{get; private set;}
    
   // public string agreementId{get; private set;}

    //This field helps in determining whether the agreement relationship
    public string relationship{get; private set;}
    
    public string status{get; private set;}
    
    public string statusCategory{get; private set;}
    
    //This field helps in determining whether the agreement is selected or not
    public Boolean selected{get; set;}
    
	
    public APTPS_AttachmenttSelectionWrapper(Apttus__APTS_Agreement__c agmt, Attachment attchmnt)
    {
        attachmentId = attchmnt.Id;
        attachmentName = attchmnt.Name;
        agreementName = agmt.Name;
        agreementNumber = agmt.Apttus__FF_Agreement_Number__c;
        status = agmt.Apttus__Status__c;
        statusCategory = agmt.Apttus__Status_Category__c;
        selected = false;
       	agreementId = agmt.Id;
        //If Parent Agreement ID is null then the agreement is Parent else Chilc
        if(agmt.Apttus__Parent_Agreement__c == null)
        {
            relationship = 'Parent';
            selected = true;
        }
        else
        {
            relationship = 'Child';
        }
       //  commented by akanksha for schedule number type change 
       /* if (agmt.Apttus__Parent_Agreement__c == null)
			{
				sequence = 1;
			}
			else
			{
				if (agmt.APTPS_Schedule_Number__c != null)
				{
				
					sequence = agmt.APTPS_Schedule_Number__c.intValue();
				}
				
			}*/
    }
    
    public APTPS_AttachmenttSelectionWrapper(Apttus__APTS_Agreement__c agmt, Attachment attchmnt, boolean isLatestAttachment)
    {
        attachmentId = attchmnt.Id;
        attachmentName = attchmnt.Name;
        agreementName = agmt.Name;
        agreementNumber = agmt.Apttus__FF_Agreement_Number__c;
        status = agmt.Apttus__Status__c;
        statusCategory = agmt.Apttus__Status_Category__c;
        selected = false;
        agreementId = agmt.Id;
		if (isLatestAttachment)
		{
			if (agmt.Apttus__Parent_Agreement__c == null)
			{
				sequence = 0;
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

        //If Parent Agreement ID is null then the agreement is Parent else Chilc
        if(agmt.Apttus__Parent_Agreement__c == null)
        {
            relationship = 'Parent';
        }
        else
        {
            relationship = 'Child';
        }
    }
    
    // Compare attachments based on the sequence.
    global Integer compareTo(Object compareTo) {
        // Cast argument to OpportunityWrapper
        APTPS_AttachmenttSelectionWrapper compareToAttachmentWrapper = (APTPS_AttachmenttSelectionWrapper)compareTo;
        
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if (sequence > compareToAttachmentWrapper.sequence) {
            // Set return value to a positive value.
            returnValue = 1;
        } else if (sequence < compareToAttachmentWrapper.sequence) {
            // Set return value to a negative value.
            returnValue = -1;
        }
        
        return returnValue;       
    }

}