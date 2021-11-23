/*******************************************************************
Created By          :   Team Hawaii
Created Date        :   01/06/2020
Jira                :   P2OB-6797
Desc                :   This trigger calls method to execute different method based on before/after context.
***********************************************************************/
trigger PartnerIncrementalFundTrigger on Partner_Incremental_Fund_Allocation__c (before insert) {
    
    Public Static Final String PartnerIncrementalFundTrigger = 'PartnerIncrementalFundTrigger';
    // This node is to enable aur disable trigger based on 'No Trigger' field value of custom setting 'Environment Configurations'.
    if(EnvironmentalSettings.isTriggerDisabled(PartnerIncrementalFundTrigger)){
        return;
    }
    
    //Check if trigger is before insert
    if(Trigger.isBefore && Trigger.isInsert){
      PartnerIncrementalFundTriggerHandler.beforeInsert(Trigger.New);
    }
}