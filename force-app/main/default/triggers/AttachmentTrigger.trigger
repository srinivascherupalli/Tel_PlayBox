/* 
* AttachmentTrigger : Trigger on Attachment insert  
* After insertion of attachment, this trigger will execute and
* call performQuoteCreationAndAttachmentDeletion of AttachmentTriggerHelper class to create QuotePDF and
* delete old attachments from notes & attachment section
* 
* @story : EDGE-9883
* @author : Om Deshmukh
*/

trigger AttachmentTrigger on Attachment (after insert,after update) {
    
    if(BypassTrigger.bypassTriggerAtOG == true){
        return;
    }  
    else{
        if(EnvironmentalSettings.isTriggerDisabled('AttachmentTrigger')) {
            return; 
        }
        Trigger_Factory.createHandler(Attachment.sObjectType);
		//added by Vamsi for TED-383 on 29SEP2021 starts
    String PROP_SYSTEM_PROPERTIES = 'System Properties';
    boolean updateRelatedAgreements = false;
    
    // if after insert transaction, call the helper class method to process further
    if((Trigger.isInsert) && (Trigger.isAfter)) {
        
        List<Attachment> signedAttachmentList = new List<Attachment>();
        Apttus_EchoSign__ApttusAdobeESignatureProperties__c  objectApttusAdobeESignatureProperties = Apttus_EchoSign__ApttusAdobeESignatureProperties__c.getInstance(PROP_SYSTEM_PROPERTIES);
        
        if(objectApttusAdobeESignatureProperties != null) {
            if(objectApttusAdobeESignatureProperties.Apttus_EchoSign__UpdateRelatedAgreements__c != null){
                updateRelatedAgreements = objectApttusAdobeESignatureProperties.Apttus_EchoSign__UpdateRelatedAgreements__c;
            }
        }
        
        for(Attachment objAttachment: Trigger.new){
            Id parentId = objAttachment.parentId;
            String parentType = ''+parentId.getSObjectType();
            //Check if attachment's parent is an echosign_dev1__SIGN_Agreement__c record
            if(parentType.equalsIgnoreCase(ApttusAdobeESignAttachmentTriggerHelper.ES_SIGN_AGMT_OBJECT_NAME)) {
                signedAttachmentList.add(objAttachment);
            }
        }
        
        if(signedAttachmentList.size() > 0 && updateRelatedAgreements) {
            ApttusAdobeESignAttachmentTriggerHelper.updateAttachmentList(signedAttachmentList);
            
        } 
    
    }//added by Vamsi for TED-383 on 29SEP2021 ends
    }
}