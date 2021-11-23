/****************************************************************************
   @Name: ContentDocumentLinkTriggerHandler.
   @Author: Shaik Mahaboob Subani.
   @CreateDate: 15/11/2017.
   @Description: This is a Trigger on ContentDocumentLink object for Updating
   @Modified Date when File is Added to the Opportunity.
   @Modified by : Vamshi (Napier Team) as part of EDGE-135560
 ********************************************************************************/
trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert,after insert,after update, before delete,after delete) {

  if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
    ContentDocumentLinkTriggerHandler.Modifieddateupdate(trigger.new,'AttachDate');
    //Added below line by Vamshi as part of EDGE-135560  
    ContentDocumentLinkTriggerHandler.attachmentCountUpdate(trigger.new,'Attachcountinsert');
  }
  
  if(Trigger.isBefore && Trigger.isdelete) {
    ContentDocumentLinkTriggerHandler.Modifieddateupdate(trigger.old,'Attachcountdelete');
    //Added below line by Vamshi as part of EDGE-135560 
    ContentDocumentLinkTriggerHandler.attachmentCountUpdate(trigger.old,'Attachcountdelete');

  }
  if(Trigger.isBefore && Trigger.isInsert) {  
    ContentDocumentLinkContract.modifyFileVisibility(trigger.new, 'ChangeVisibility');
    ContentDocumentLinkTriggerHandler.modifyFileVisibility(trigger.new, 'ChangeVisibility');
     // ContentDocumentLinkTriggerHandler.attachmentCountUpdate(trigger.new,'Attachcountinsert');
     //EDGE-140813. Kalashree Borgaonkar. Change visibilty of CAF document
    ContentDocumentLinkTriggerHandler.modifyCAVisibility(trigger.new);
  }

  if(Trigger.isAfter && Trigger.isInsert) {
    ContentDocumentLinkTriggerHandler.Modifieddateupdate(trigger.new,'Attachcountinsert');
    ContentDocumentLinkContract.modifiedContractFlag(trigger.new,'fileGenerate');
    ContentDocumentLinkCongaTemplate.activateVersion(trigger.new);
    ContentDocumentLinkTriggerHandler.ownerUpdate(trigger.new);
    ContentDocumentLinkTriggerHandler.priceScheduleOFormFile(trigger.new);   /*EDGE-170431*/
      
      
  }
  if(Trigger.isAfter && Trigger.isdelete) {
    ContentDocumentLinkContract.modifiedContractFlag(trigger.old,'fileDelete');
    system.debug('inside delete after');
     ContentDocumentLinkTriggerHandler.attachmentCountUpdate(trigger.old,'Attachcountdelete');
  }
  if(Trigger.isAfter && Trigger.isInsert) {
      serviceTermAttachmentPRM.attchSTAssign(trigger.new); //Added By Orlando for ServiceTerm Attachments

      //EGEG-88882

  }
}