trigger FrameAgreementTrigger on csconta__Frame_Agreement__c (after delete, after insert, after update, before delete, before insert, before update) {
  csfam__fac_settings__c facSettings = csfam__fac_settings__c.getInstance();
  //Get value for active FA, if not defined default to 'Active'
  string START_SYNC_ON_STATUS = facSettings.csfam__active_status__c != null ? facSettings.csfam__active_status__c : 'Active';
  No_Triggers__c notriggers   = No_Triggers__c.getInstance(UserInfo.getUserId());

  if (notriggers == null || !notriggers.Flag__c) {
  system.debug('Trigger Entry 0');
    Boolean syncToOpty = false;
    if ((trigger.isUpdate) && (trigger.IsAfter)) {
      Boolean syncRequired = false;
      syncToOpty =true;
      for (csconta__Frame_Agreement__c fa : trigger.new) {
        //if any of the FA was activated then fire resync as we have changes to push
        if (fa.csconta__Status__c == START_SYNC_ON_STATUS && trigger.oldMap.containsKey(fa.Id) && trigger.oldMap.get(fa.Id).csconta__Status__c != START_SYNC_ON_STATUS) {
                    syncRequired = true;
                    break;
        }
      }
      if (syncRequired) {
        PRESyncInvoker.futureSynchronise();
      }
    }
    if ((trigger.isUpdate) && (trigger.IsBefore)) {
        syncToOpty =true;  
    }
    /*if(syncToOpty){
    system.debug('Trigger Entry');
        fflib_SObjectDomain.triggerHandler(ATF_SObjectDomain.class);
    }*/
  }
  if(trigger.isUpdate && trigger.IsAfter){
      FrameAgreementTriggerHandler.doInit(trigger.New);
      FrameAgreementTriggerHandler.afterUpdateHandler(trigger.New,trigger.oldMap);
  }
}