/*************************************************************************************************
Name : SubscriptionCustomTrigger 
Description : EDGE-138284 : Refactor Subscription trigger
TestClass : SubscriptionTriggerCustomTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Gnana               09-Apr-2020   Modified as part of EDGE-138284 : Refactor Subscription trigger
2.        Gnana               22-Apr-2020   EDGE-138284 : Introduced before Update event
3.       Prajakta             30/04/2020     EDGE-146655
===============================================================================================================================
***************************************************************************************************/

trigger SubscriptionCustomTrigger  on csord__Subscription__c (after insert,after update) {

    if(EnvironmentalSettings.isTriggerDisabled(' SubscriptionCustomTriggerHandler ')) {return;}
    
    List<csord__Subscription__c> listOfSubsWithOrderDetails = new List<csord__Subscription__c>();
        
   
        // SOQL to get List of Suscriptions with Order details
        listOfSubsWithOrderDetails = SubscriptionCustomTriggerHandler.getSubscriptionsWithOrderDetails(Trigger.newMap.keySet());
    
    
        
        
        
        if(Trigger.isInsert){
            SubscriptionCustomTriggerHandler.afterInsert(Trigger.newMap,listOfSubsWithOrderDetails);
        }
        else if(Trigger.isUpdate){
            SubscriptionCustomTriggerHandler.afterUpdate(Trigger.newMap,Trigger.oldMap,listOfSubsWithOrderDetails);
        }
        
        CSPOFA.Events.emit('update', Trigger.newMap.keySet()); 
    
}