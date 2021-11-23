/*******************************************************************
Created By          :   Team Hawaii
Created Date        :   15/5/2020
Jira                :   P2OB-6000
Desc                :   This trigger calls method to execute different method based on before/after context.
***********************************************************************/
trigger PartnerFundClaimTrigger on PartnerFundClaim (before Update) {
    
    Public Static Final String PartnerFundClaimTrigger = 'PartnerFundClaimTrigger';
    // This node is to enable aur disable trigger based on 'No Trigger' field value of custom setting 'Environment Configurations'.
    if(EnvironmentalSettings.isTriggerDisabled(PartnerFundClaimTrigger)){
        return;
    }
    
    //Check if trigger is before update
    if(Trigger.isBefore && Trigger.isUpdate){
    	//Initialize class
        PartnerFundClaimTriggerHelper claimTrigger = new PartnerFundClaimTriggerHelper();
        //Call checkClaimCanBeApproved method
        claimTrigger.checkClaimCanBeApproved(Trigger.New,Trigger.oldMap);
    }
}