/*****************************************************************
@Name: APTPS_AgreementClauseTrigger
@Author: Ruchika Patil 
@CreateDate: 24/06/2016 
@Description: This is the trigger on Agreement Clause object for the events: before insert & after update
@UsedBy: Agreement 
******************************************************************/ 
trigger APTPS_AgreementClauseTrigger on Apttus__Agreement_Clause__c (before insert) {
    APTPS_AgreementClauseTriggerHandler handler = new APTPS_AgreementClauseTriggerHandler();
    if(Trigger.isInsert && Trigger.isBefore){
        handler.populateApprovalGuidance(trigger.new);
    }
}