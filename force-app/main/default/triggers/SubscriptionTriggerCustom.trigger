Trigger SubscriptionTriggerCustom on csord__Subscription__c (after insert,after update) { 
    /*
      if(EnvironmentalSettings.isTriggerDisabled(' SubscriptionCustomTriggerHandler ')) {return;}
      
   
      //after insert, update logic
        if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate) && SubscriptionCustomTriggerHandler.isUpdate){  
        
         SubscriptionCustomTriggerHandler.isUpdate = false;  
            CSPOFA.Events.emit('update', Trigger.newMap.keySet()); 
            Set<Id> orderIds = new Set<Id>(); 
            Set<Id> subsIds= new Set<Id>();
            Set<Id> subcriptionIdSet= new Set<Id>();
           /* for(csord__Subscription__c subs :[Select Id, Forecasted_Delivery_Date__c,Telstra_Committed_Date__c ,csord__Account__c,csord__Status__c,csordtelcoa__Replaced_Subscription__c,csord__Order__c, csord__Order__r.csord__Primary_Order__c  from csord__Subscription__c where Id IN: Trigger.New]){
                if(subs.csord__Order__c != null && (subs.Forecasted_Delivery_Date__c != null || subs.Telstra_Committed_Date__c != null )){
                    system.debug('orderIds'+subs.csord__Order__c);
                    orderIds.add(subs.csord__Order__c);
                    system.debug('orderIds11'+subs.csord__Order__r.csord__Primary_Order__c);
                    if(subs.csord__Order__r.csord__Primary_Order__c != null)
                    orderIds.add(subs.csord__Order__r.csord__Primary_Order__c);
                    subsIds.add(subs.Id);
                   
                }
                
                
                
                if(subs.csord__Order__c != null && subs.csord__Status__c == 'Active' || subs.csord__Status__c == 'Inactive'){
                    subcriptionIdSet.add(subs.Id);
                     System.debug('SubscriptionTriggerCustom subsIds'+subcriptionIdSet);
                }
                
            }
            
            List<csord__Subscription__c> lstSubs = new List<csord__Subscription__c>();
            for(csord__Subscription__c subs : Trigger.New){
                if(subs.csord__Order__c != null && (subs.Forecasted_Delivery_Date__c != null || subs.Telstra_Committed_Date__c != null )){
                    system.debug('orderIds'+subs.csord__Order__c);
                    orderIds.add(subs.csord__Order__c);
                    system.debug('orderIds11'+subs.csord__Order__r.csord__Primary_Order__c);
                    System.debug('Primary_Order__c...'+subs.csord__Order__r.csord__Primary_Order__c);
                    if(subs.csord__Order__r.csord__Primary_Order__c != null){
                        System.debug('inside Primary_Order__c...'+subs.csord__Order__r.csord__Primary_Order__c);
                        orderIds.add(subs.csord__Order__r.csord__Primary_Order__c); 
                    }
                    subsIds.add(subs.Id); lstSubs.add(subs);
                }
                if(subs.csord__Order__c != null && subs.csord__Status__c == 'Active' || subs.csord__Status__c == 'Inactive'){
                    subcriptionIdSet.add(subs.Id);
                    System.debug('SubscriptionTriggerCustom subsIds'+subcriptionIdSet);
                }
            }
            system.debug('orderIds'+orderIds);
            
            if(!subcriptionIdSet.IsEmpty() && Trigger.isUpdate){
                SubscriptionCustomTriggerHandler.setPreviousSubscriptionStatusToArchive(subcriptionIdSet);
            }
            if(!orderIds.IsEmpty() && !subsIds.IsEmpty()){
                SubscriptionCustomTriggerHandler.UpdateOrderStatus(lstSubs,orderIds);
            }
            
         }
         */
}