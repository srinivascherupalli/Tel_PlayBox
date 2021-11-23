/****************************************************************************
@Author: Maq
@CreateDate: 08/11/2018.
@Description: QuoteTrigger trigger to handle before update event.
@TestCoverageClass: QuoteTriggerTest
@ChangeLog: v1 - Created
********************************************************************************/
trigger QuoteTrigger on Quote (before update) {
	    // Trigger Switch to disable trigger 
    if(EnvironmentalSettings.isTriggerDisabled('QuoteTrigger')) {
        return;
    }
    GenerateQuoteHelper genQuoteHelper = new GenerateQuoteHelper();
    if(Trigger.isbefore && Trigger.isUpdate){
        genQuoteHelper.validateRelatedContact(Trigger.new, Trigger.newMap, Trigger.old,Trigger.oldMap);
    }
}