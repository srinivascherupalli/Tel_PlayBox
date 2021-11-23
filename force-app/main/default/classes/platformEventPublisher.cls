public class platformEventPublisher {
	public static DocumentGenerationNotification__e createProposalPlatformEvent(Opportunity opp, Attachment att) {
		
		DocumentGenerationNotification__e docGeneratingNotification = new DocumentGenerationNotification__e();
		docGeneratingNotification.OpportunityId__c = opp.Id;
		docGeneratingNotification.DocType__c = 'Proposal';
		docGeneratingNotification.AttachmentId__c = att.Id;
		docGeneratingNotification.AttachmentName__c = att.Name;
        return docGeneratingNotification;
    }
}