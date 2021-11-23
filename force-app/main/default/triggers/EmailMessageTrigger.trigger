trigger EmailMessageTrigger on EmailMessage (Before Insert) {
    if(Trigger.isBefore){
        list<ID> relatedToID = New list<ID>();
        for(EmailMessage EM : trigger.new){
            if(EM.RelatedToId != NULL){
                if(String.valueOf(EM.RelatedToId).startsWith('0Q0') == true){
                    relatedToID .add(EM.RelatedToId);
                }
            }
        }
        Boolean errorOccured = false;   
        list<quote> QuoteList = new list<quote>();   
        QuoteList = [SELECT ID FROM QUOTE WHERE ID IN: relatedToID AND (Status = 'Void' OR Status = 'Expired')];
        if(QuoteList.size() > 0){
            for(EmailMessage EM : trigger.new){
                EM.status.addError('Email cannot be sent for Quote with status Void or Expired');
                errorOccured = true;
            }           
        }
        list<quote> QuoteListAttachment = [SELECT ID,isAttachmentAvailable__c FROM QUOTE WHERE ID IN: relatedToID AND isAttachmentAvailable__c = false];
        if(QuoteListAttachment.size() > 0){
            if(errorOccured == false){
                for(EmailMessage EM : trigger.new){              
                    EM.addError('Please add a quote as an attachment before emailing it to customer');
                }  
            }
        }
    }
}