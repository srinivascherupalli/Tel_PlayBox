trigger APTPS_FundTransactionTrigger on Fund_Transaction__c (before update,after update) {
    
    APTPS_FundTransactionTriggerHandler fundTransactionHander = new APTPS_FundTransactionTriggerHandler();
    
    if(trigger.isupdate && trigger.isafter){
        fundTransactionHander.afterUpdate(trigger.oldMap,trigger.newMap);
    }
    
}