trigger AccountTrigger on Account (before insert, before update, before delete,
        after insert, after update, after delete,
        after undelete) {

    if(EnvironmentalSettings.isTriggerDisabled('AccountTrigger') || BatchAccountAssignment.isBatchAccountAssignment){
        return;
    }

    AccountTriggerHandler handler = new AccountTriggerHandler();
    AccountTriggerHandlerPRM handlerPRM = new AccountTriggerHandlerPRM(Trigger.new);

    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsert(Trigger.new);
        if(handlerPRM.hasPRMAccounts()){
            handlerPRM.OnBeforeInsert(Trigger.new);
        }
    }
    else if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new);
        if(handlerPRM.hasPRMAccounts()){
            handlerPRM.OnAfterInsert(Trigger.new);
        }
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        if(handlerPRM.hasPRMAccounts()){
            handlerPRM.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.oldMap, Trigger.newMap);
        }
    }
    else if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterUpdate(Trigger.old,Trigger.oldMap, Trigger.new, Trigger.newMap);
        if(handlerPRM.hasPRMAccounts()){
            handlerPRM.OnAfterUpdate(Trigger.old,Trigger.oldMap, Trigger.new, Trigger.newMap);
        }
    }

    else if(Trigger.isDelete && Trigger.isBefore){
        //handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
    }
    else if(Trigger.isDelete && Trigger.isAfter){
        handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
    }
    // jira - NFB1696 - Remove insert event as Automation Customer Creation is not in scope for relase 2A
    if(((Trigger.isAfter && Trigger.isInsert) || (Trigger.isAfter && Trigger.isUpdate)) && !EnvironmentalSettings.isSeedingEnabled()){
        if(Trigger.isAfter && Trigger.isUpdate){
            system.debug('!@#$ Inside after trigger ::');
            if(AccountTriggerHandler.runOnce()){
                IntegrationSettings__c iSettings = IntegrationSettings__c.getOrgDefaults();
                if(isettings!=null && iSettings.EnableManageInterfaces__c){
                    //EDGE-38 : Dynamic Manage Invocation
                    if(!TestRun.Uirun){
                        AccountTriggerHandler.ManageCustomer();
                    } else {
                        AccountTriggerHandler.identifyFieldUpdates(Trigger.newMap, Trigger.oldMap);
                    }
                }
            }
        } else {
            system.debug('!@#$ Inside after trigger ::');
            IntegrationSettings__c iSettings = IntegrationSettings__c.getOrgDefaults();
            if(iSettings!=null && iSettings.EnableManageInterfaces__c){
                AccountTriggerHandler.ManageCustomer();
            }
        }
    }
}