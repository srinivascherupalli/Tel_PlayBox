trigger OrderDecompositionRequestTrigger on order_decomposition_request__e (after insert) {
    
    system.debug('Inside platform vent ---<><>');
    order_Utilites__c orderUtilSetting = order_Utilites__c.getInstance();
    if(orderUtilSetting.use_process_builder_as_subscriber__c){
        return;
    }
    
    List<Id> tempopportunityIds = new List<Id>();
    List<Id> temporderIds = new List<Id>();
    
    for(order_decomposition_request__e rec: trigger.new){
        if(rec.Opportunity_Id__c != null){
            tempopportunityIds.add(rec.Opportunity_Id__c);
        }
        if(rec.Order_Id__c != null && rec.observer_Invocation__c){
            temporderIds.add(rec.Order_Id__c );
        }
    }
    if(!tempopportunityIds.isEmpty()){
        orderGenerationAPIInvoker.orderGeneration(tempopportunityIds, orderUtilSetting);
    }
    
    if(!temporderIds.isEmpty()){
        csordcb.ObserverApi.Observable o;
        List<Id> subscriptionIds = new List<Id>();
        for(csord__subscription__c subs: [Select Id from csord__subscription__c WHERE csord__order__c IN: temporderIds]){
            subscriptionIds.add(subs.Id);
        }
        OrderObserverInvoker.observerChainingMethod(subscriptionIds, o, temporderIds);
    }
}