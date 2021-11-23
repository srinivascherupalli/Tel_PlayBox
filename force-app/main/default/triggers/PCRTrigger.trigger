trigger PCRTrigger on csbb__Product_Configuration_Request__c (before insert, after delete, after insert, after update, after undelete , before delete, before update) {

    if (EnvironmentalSettings.isTriggerDisabled('PCRTrigger')) {
        return;
    }
	
    //code for checking sq callout - before trigger
    if (Trigger.isBefore && Trigger.isInsert) {
        //PCRTriggerHandler.checkSQCallout(Trigger.new);
    }    

    //code for checking sq callout - after trigger
    if (Trigger.isAfter && Trigger.isInsert) {
        //PCRTriggerHandler.checkSQCallout2(Trigger.new);
    }
    
    //Code added for clearing site address from console
    //@Author: Pooja, Modified Date: 16/July/2020 
    //This is commented as part of CS Spring'20 Release Update.
    /*if (Trigger.isBefore && (Trigger.IsUpdate || Trigger.isInsert)) { //added for Edge-91796
        PCRTriggerHandler.clearAddress(Trigger.new);
    }*/ 
    //Pooja: CS Spring'20 Upgrade End

    /*if (Trigger.isAfter) {
        PCRTriggerHandler.updateRollUpFieldsOnProductBasket(Trigger.new, Trigger.oldMap);
    }*/

    //code added to update basket field values when PCRs are created and not PCs
    if (Trigger.isAfter && Trigger.isInsert) {
        PCRTriggerHandler.updateBasketFieldsAfterPCRCreation(Trigger.new);
        //PCRTriggerHandler.UpdateLegacyFlagOnBasket(Trigger.new); Gnana : Commented as part of Spring'20 Upgrade Activity 
    }
    //code added to throw error on delete of synced products
    if (Trigger.isBefore && Trigger.isDelete) {
        PCRTriggerHandler.deleteErrorOnSync(Trigger.Old);
        //PCRTriggerHandler.updateLegacyFlagOnBasketOnDelete(Trigger.Old); Gnana : Commented as part of Spring'20 Upgrade Activity
    }
    if (trigger.isAfter && trigger.isDelete) {
        PCRTriggerHandler.stageChangeOnDelete(Trigger.Old);
    }

}