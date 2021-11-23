/*****************************************************************************
@Name : DeleteProposalAttachments
@Description : This class is rest resource to delete proposal documents and it will be utilize by Mulesoft integration user 
				to delete attachment once it is uploaded on sharepoint 
@Created by : Ravi Dodiya as part of P2OB-14470.Sprint 21.07
*******************************************************************************/
@RestResource(urlMapping = '/DeleteProposalAttachments')
global class DeleteProposalAttachments {
    @HttpPost 
     global static Boolean DeleteProposalAttachments(String RecordId)
     {
         	System.debug('Attachment Id to delete :'+RecordId);
         	Attachment att= [Select Id,ParentId,Name,CreatedById from Attachment where Id = :RecordId limit 1];
			User calmsUser = [Select Id,Username from User where Id =: att.CreatedById limit 1 ];

         	//Custom Permission check on User to allow Delete Attachment
         	Boolean hasCustomPermission = FeatureManagement.checkPermission('Delete_Proposal_Attachments');
         if(hasCustomPermission){
        	//Only Proposal Documents should be deleted and it should be genereated by Integration user : CALMS Integration User
            if(string.valueOf(att.ParentId).startsWith('006') && string.valueOf(calmsUser.Username).containsIgnoreCase(System.Label.Delete_Proposal_Attachments_User)){
                 delete att;
                 return true;
            }
            else {   
                //Do nothing as it is not proposal document attachment or user doesn't have permission
                 return False;
            }
         }else {
             // User is not Authorised to Delete this proposal Document
             return False;
         }

     }

}