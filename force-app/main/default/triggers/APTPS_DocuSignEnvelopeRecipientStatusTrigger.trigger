trigger APTPS_DocuSignEnvelopeRecipientStatusTrigger on Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c(after insert) {
   APTPS_DocuSignEnvRecpStatTriggerHandler handler = new APTPS_DocuSignEnvRecpStatTriggerHandler();
    if(Trigger.isInsert && Trigger.isAfter)
    {
        handler.handleAfterInsertEvents(Trigger.New);
    }
}