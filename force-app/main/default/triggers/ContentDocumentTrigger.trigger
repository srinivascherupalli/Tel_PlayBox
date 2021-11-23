trigger ContentDocumentTrigger on ContentDocument ( before delete,after delete ) {
if(Trigger.isBefore && Trigger.isdelete){         
        ContentDocumentTriggerHandler.GetContentDocumentLink(trigger.old);
        
    }
if(Trigger.isAfter && Trigger.isdelete){  
        ContentDocumentTriggerHandler.ContentDocumentLinkContractInvoke(trigger.old);
    }       
   
}