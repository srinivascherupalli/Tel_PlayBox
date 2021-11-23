/*************************************************************************************************
Name : AutoSync
Description : Trigger on Platform Event for Auto  Sync of Valid Primary Baskets
***************************************************************************************************/
trigger AutoSync on AutoSync__e (after Insert) {
if(EnvironmentalSettings.isTriggerDisabled('AutoSync')) {
        return;
    }
    String syncMsg;
    String displayMsg;
    public static boolean isRun = false;
    for(AutoSync__e ae:trigger.new){
        if(!ae.SyncFlag__c && !isRun && StaticUtilForRecursion.runAutoSyncOnce()){
            StaticUtilForRecursion.autoSyncRunFlag = false; 
            isRun = true;
            CustomButtonOpportunitySync sy = new CustomButtonOpportunitySync();
            syncMsg = sy.syncMessage(ae.basket_Id__c, false);
            displayMsg = CustomButtonOpportunitySync.displayMessage;
            if(syncMsg.contains('error') && displayMsg != null)
                ae.addError(displayMsg);
        }
    }
}