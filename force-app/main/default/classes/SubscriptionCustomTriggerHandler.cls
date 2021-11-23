/*************************************************************************************************
Name : SubscriptionCustomTriggerHandler 
Description : EDGE-138284 : Refactor Subscription trigger
TestClass : SubscriptionCustomTriggerHandlerTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Gnana               08-Apr-2020   EDGE-138284 : Refactor Subscription trigger
2.        Gnana               22-Apr-2020   EDGE-138284 : Added beforeUpdate method and modified afterUpdate & setPreviousSubscriptionStatusToArchive
                                            to change update Suscription logic to beforeUpdate event
3.       Prajakta             30/04/2020     EDGE-146655
===============================================================================================================================
***************************************************************************************************/

public with sharing class SubscriptionCustomTriggerHandler {
    
    // Added as part of EDGE-138284
    public static List<csord__Subscription__c> getSubscriptionsWithOrderDetails(Set<Id> subsIds){
        return [Select Id, csord__Account__c, csord__Status__c, csordtelcoa__Replacement_Subscription__c, 
                             csordtelcoa__Replaced_Subscription__c, csordtelcoa__Closed_Replaced__c, Forecasted_Delivery_Date__c, 
                             Telstra_Committed_Date__c ,csord__Order__c, csord__Order__r.csord__Primary_Order__c  
                             from csord__Subscription__c where Id in :subsIds];
    }
    
    // Added as part of EDGE-138284
    /*public static void beforeUpdate(Map<Id,csord__Subscription__c> newSubsMap, List<csord__Subscription__c> listOfSubs){
        List<csord__Subscription__c> lstSubsForArchive = new List<csord__Subscription__c>();
        
        for(csord__Subscription__c subs : listOfSubs){
            if(subs.csord__Order__c != null && (subs.Forecasted_Delivery_Date__c != null || subs.Telstra_Committed_Date__c != null )){
                if(subs.csord__Order__c != null && subs.csord__Status__c == 'Active' || subs.csord__Status__c == 'Inactive' ){
                    lstSubsForArchive.add(subs);
                }
            }  
        }
        if(lstSubsForArchive!=null && lstSubsForArchive.size()>0){
            setPreviousSubscriptionStatusToArchive(lstSubsForArchive,newSubsMap);
        }
    }*/
    
    // Added as part of EDGE-138284
    public static void afterInsert(Map<Id,csord__Subscription__c> newSubsMap, List<csord__Subscription__c> listOfSubs){
        
        ProcesssOrderStatusUpdate(listOfSubs);  
    }
    
    // Added as part of EDGE-138284
    public static void afterUpdate(Map<Id,csord__Subscription__c> newSubsMap, Map<Id,csord__Subscription__c> oldSubsMap, List<csord__Subscription__c> listOfSubs){
        setPreviousSubscriptionStatusToArchive(newSubsMap.keyset());
        ProcesssOrderStatusUpdate(listOfSubs);
    }
    //Added as part of DIGI-13385
    public static void beforeUpdate(Map<Id,csord__Subscription__c> newSubsMap, Map<Id,csord__Subscription__c> oldSubsMap){
        updateInvokeBDSNotificationOnNumbers(newSubsMap,oldSubsMap);
    }
    
    
    // Added as part of EDGE-138284
    public static void ProcesssOrderStatusUpdate(List<csord__Subscription__c> listOfSubs){
        Set<Id> orderIds = new Set<Id>(); 
        List<Id> subsIds= new List<Id>();
        List<csord__Subscription__c> lstSubs = new List<csord__Subscription__c>();
        
        for(csord__Subscription__c subs : listOfSubs){
            if(subs.csord__Order__c != null && (subs.Forecasted_Delivery_Date__c != null || subs.Telstra_Committed_Date__c != null )){
                orderIds.add(subs.csord__Order__c);
                if(subs.csord__Order__r.csord__Primary_Order__c != null){
                    orderIds.add(subs.csord__Order__r.csord__Primary_Order__c); 
                }
                subsIds.add(subs.Id); 
                //lstSubs.add(subs);
            }
        }
        if(!orderIds.IsEmpty() && !subsIds.IsEmpty()){
            //UpdateOrderStatus(subsIds,orderIds);
            UpdateOrderStatusDecision(subsIds,orderIds);
        }
    }
    
    public static void UpdateOrderStatusDecision(List<Id> subList, Set<Id> orderIds){
        
        if(system.isBatch()){
            UpdateOrderStatus(subList, orderIds);
        }else{
            UpdateOrderStatusinFuture(subList, orderIds);
        }
        
    }

    @future
    public static void UpdateOrderStatusinFuture(List<Id> subList, Set<Id> orderIds){
        
        UpdateOrderStatus(subList, orderIds);
        
    }
    public static void UpdateOrderStatus(List<Id> subList, Set<Id> orderIds){
        Map<String,csord__Order__c > OrderMap = new Map<String, csord__Order__c>([Select Id, Forecasted_Delivery_Date__c,Telstra_Committed_Date__c from csord__Order__c where (Id IN:orderIds)]);
        //List<csord__Subscription__c> SubMap = new List<csord__Subscription__c>([Select Id,csord__Order__r.csord__Primary_Order__c, csord__Order__c, Forecasted_Delivery_Date__c,Telstra_Committed_Date__c from csord__Subscription__c where Id IN:subscriptionIds]);
        Map<Id, csord__Order__c> OrdMaptoUpdate = new Map<Id, csord__Order__c>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        for(csord__Subscription__c subs :[select Id,csord__Order__c,Forecasted_Delivery_Date__c,Telstra_Committed_Date__c,csord__Order__r.csord__Primary_Order__c from csord__Subscription__c where Id IN :subList]){
            csord__Order__c updateOrder = OrderMap.get(subs.csord__Order__c);
            system.debug('updateOrder '+updateOrder);
            if(updateOrder.Forecasted_Delivery_Date__c == null || updateOrder.Forecasted_Delivery_Date__c < subs.Forecasted_Delivery_Date__c)
                updateOrder.Forecasted_Delivery_Date__c = subs.Forecasted_Delivery_Date__c;
            
            if(updateOrder.Telstra_Committed_Date__c == null || updateOrder.Telstra_Committed_Date__c < subs.Telstra_Committed_Date__c)
                updateOrder.Telstra_Committed_Date__c = subs.Telstra_Committed_Date__c;
            orderList.add(updateOrder);
            OrdMaptoUpdate.put(updateOrder.Id, updateOrder);
            if(subs.csord__Order__r.csord__Primary_Order__c != null){
                csord__Order__c updatePrimaryOrder = OrderMap.get(subs.csord__Order__r.csord__Primary_Order__c);
                system.debug('updateOrder '+updateOrder);
                if(updatePrimaryOrder .Forecasted_Delivery_Date__c == null || updatePrimaryOrder .Forecasted_Delivery_Date__c < subs.Forecasted_Delivery_Date__c)
                    updatePrimaryOrder .Forecasted_Delivery_Date__c = subs.Forecasted_Delivery_Date__c;
                
                if(updatePrimaryOrder .Telstra_Committed_Date__c == null || updatePrimaryOrder .Telstra_Committed_Date__c < subs.Telstra_Committed_Date__c)
                    updatePrimaryOrder .Telstra_Committed_Date__c = subs.Telstra_Committed_Date__c;
                orderList.add(updatePrimaryOrder );
                OrdMaptoUpdate.put(updatePrimaryOrder.Id, updatePrimaryOrder);
            }
        }
        system.debug('orderList'+orderList);
        if(!OrdMaptoUpdate.values().IsEmpty())
            update OrdMaptoUpdate.values();
        
    }
    
    /*
    Public static void combineMethod(Set<Id> subscriptionIds) {
        List<csord__Subscription__c> subIdsStatusToUpdate=new List<csord__Subscription__c>();
        System.debug('in combineMethod');
        for(csord__Subscription__c cs:[Select Id,csord__Account__c,csord__Status__c,csordtelcoa__Replacement_Subscription__c,csordtelcoa__Replaced_Subscription__c, csordtelcoa__Closed_Replaced__c ,csord__Order__c from csord__Subscription__c where (csordtelcoa__Replacement_Subscription__c IN:subscriptionIds OR  Id IN:subscriptionIds)])
        {    
            System.debug('in for loop '+cs);
            if(subscriptionIds.contains(cs.id))
            {
                System.debug('cs.id '+cs.id);
                if(cs.csord__Status__c.equals('Inactive')){
                    System.debug('inactive if '+cs.csord__Status__c);
                    EDISSingleManager.processEDISCeaseCompletion(cs.id);
                }
                //  }
                if(cs.csordtelcoa__Replacement_Subscription__c != null) {
                    System.debug('in else if ');
                    if(cs.csord__Status__c.equals('Active') || cs.csord__Status__c.equals('Inactive')){ 
                        System.debug('in active if '+cs.csord__Status__c);
                        cs.csord__Status__c =SYstem.Label.ClosedReplaced;
                        subIdsStatusToUpdate.add(cs);
                        System.debug('subIdsStatusToUpdate '+subIdsStatusToUpdate);
                    }
                    
                }
                
                
            }
            if(!subIdsStatusToUpdate.isEmpty()){
                system.debug('Updated successfully');
                update subIdsStatusToUpdate;
            }
        }
    }*/
        
   /* public static void setPreviousSubscriptionStatusToArchive(List<csord__Subscription__c> listOfSubs,Map<Id,csord__Subscription__c> newSubsMap){
        List<csord__Subscription__c> subIdsStatusToUpdate = new List<csord__Subscription__c>(); 
        for(csord__Subscription__c sub : listOfSubs ){               
            if(sub.csordtelcoa__Replaced_Subscription__c == null && newSubsMap.containsKey(sub.Id)){
                newSubsMap.get(sub.Id).csord__Status__c = System.Label.ClosedReplaced;
            }              
        }
    }*/
    
    
    public static void setPreviousSubscriptionStatusToArchive(Set<Id> subscriptionIds){
        List<csord__Subscription__c> subIdsStatusToUpdate = new List<csord__Subscription__c>(); 
        List<csord__Subscription__c> subMapClosed = new List<csord__Subscription__c>([Select Id,csord__Account__c,csord__Status__c,csordtelcoa__Replacement_Subscription__c,csordtelcoa__Replaced_Subscription__c, csordtelcoa__Closed_Replaced__c ,csord__Order__c from csord__Subscription__c where csordtelcoa__Replaced_Subscription__c = null AND csordtelcoa__Replacement_Subscription__c IN:subscriptionIds]);
        for(csord__Subscription__c sub : subMapClosed ){            
            if(sub.csord__Status__c == 'Active' || sub.csord__Status__c == 'Inactive')
            {                   
                sub.csord__Status__c =System.Label.ClosedReplaced;
                subIdsStatusToUpdate.add(sub);
                System.debug('subIdsStatusToUpdate===>'+subIdsStatusToUpdate);
            }
            
        }
        if(!subIdsStatusToUpdate.isEmpty()){
            update subIdsStatusToUpdate;
        }
    }
    
   /* public static void triggerEDISOnCeaseCompletion(Set<Id> subscriptionId){
        try{
            if(!Test.isRunningTest()){
                List<csord__Subscription__c> subList = new List<csord__Subscription__c>([Select Id,csord__Account__c,csord__Status__c,csordtelcoa__Replacement_Subscription__c,csordtelcoa__Replaced_Subscription__c, csordtelcoa__Closed_Replaced__c ,csord__Order__c from csord__Subscription__c where Id IN:subscriptionId]);
                for(csord__Subscription__c sub :subList){
                    if(sub.csord__Status__c =='Inactive'){
                        EDISSingleManager.processEDISCeaseCompletion(sub.id);
                    }
                }
            }
        }catch(Exception e){
            system.debug('Exception in triggerEDISOnCeaseCompletion ' + e);
        } 
        
    }*/

    //Add by Nikhil Date: - 20/05/2021 for EDGE-219683
    public static void updateInvokeBDSNotificationOnNumbers(Map<Id,csord__Subscription__c> newSubsMap, Map<Id,csord__Subscription__c> oldSubsMap){
        List<BDSNotificationForNumber__e> invokeBDSNotificationForNumbers = new List<BDSNotificationForNumber__e>();
        Logger2 logger = Logger2.getLogger('BDSNotificationForNumberTriggerHandler');
        for(csord__Subscription__c subscription : newSubsMap.values()){       
            if(String.isNotBlank(subscription.csord__Status__c) && subscription.csord__Status__c == 'Active'  
              && oldSubsMap.get(subscription.Id).csord__Status__c != subscription.csord__Status__c
                   ){

                BDSNotificationForNumber__e eve = new BDSNotificationForNumber__e();
                eve.SubscriptionNumber__c = subscription.csordtelcoa__Subscription_Number__c ;
                invokeBDSNotificationForNumbers.add(eve);
            }
        }
        if(!invokeBDSNotificationForNumbers.isEmpty()){
            List<Database.SaveResult> responses = EventBus.publish(invokeBDSNotificationForNumbers);
            String statusCode = '';
            String errorMssg = '';
            for(Database.SaveResult res : responses){
                if(!res.isSuccess()){
                    for(Database.Error err : res.getErrors()) {
                        System.debug('Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
                        statusCode = statusCode + ','  + err.getStatusCode();
                        errorMssg = errorMssg + ',' + err.getMessage();
                    }
                }
            }
            logger.logMessages(JSON.serialize(invokeBDSNotificationForNumbers), JSON.serialize(responses), '', 'Functional', statusCode, errorMssg, false, false,null ,null,null,null);
            logger.exitLogger();
        }
    }
}