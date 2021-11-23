trigger AttributeTrigger on cscfga__Attribute__c (after update,before delete) {
if(EnvironmentalSettings.isTriggerDisabled('AttributeTrigger')) {
    return;
}
    //Added the code for EDGE-3458 deletion
       if(trigger.isDelete)
       {
         AllAttributeTriggerHelper.handleAttributeDeletion(Trigger.old); 
       }   
       /* 
        * Gnana: CS Spring'20 Upgrade Start
        * Moved this logic to AfterSave hook in respective JS Plugins
        if(trigger.isUpdate)
       {
         AllAttributeTriggerHelper.updateProductBasketSyncFlag(Trigger.new,Trigger.oldMap);
       } */
}