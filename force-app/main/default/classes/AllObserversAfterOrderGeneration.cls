/******************************************************************************************************************************
Class Name : AllObserversAfterOrderGeneration
Test Class : AllObserversAfterOrderGeneration_Test 
===============================================================================================================================
Sr.No.  Developer           Date          Story Description                Sprint

******************************************************************************************************************************/
global with sharing class AllObserversAfterOrderGeneration implements csordcb.ObserverApi.IObserver{  
   
    //method need to be implemented for csordcb.ObserverApi.IObserver
    global void execute(csordcb.ObserverApi.Observable o, Object arg){
        List<Id> subscriptionIds = new List<Id>();
        List<Id> temporderIds = new List<Id>();
        csordtelcoa.OrderGenerationObservable observable = (csordtelcoa.OrderGenerationObservable)o;
        temporderIds = observable.getOrderIds();
        subscriptionIds = observable.getSubscriptionIds();
        if(system.isFuture()){
            system.debug('enterd future observer---<><>');
            AllObserversAfterOrderGeneration.observerExecutionForFutureMethod(temporderIds);
            
        }else{
            OrderObserverInvoker.observerChainingMethod(subscriptionIds, o, temporderIds); 
        }
    }
    public static void observerExecutionForFutureMethod(List<Id> orderIds){
    
    
          system.debug('enterd future observerExecutionForFutureMethod---<><>');
          csordtelcoa__Orders_Subscriptions_Options__c onsOptions = csordtelcoa__Orders_Subscriptions_Options__c.getInstance();
          //csordtelcoa.OrderGenerationObservable observable = (csordtelcoa.OrderGenerationObservable)o;
          //List<Id> orderIds = observable.getOrderIds();
          list<csord__order__c> orderToUpdate =  new List<csord__Order__c>();
          list<csord__Subscription__c> subsToUpdate =  new List<csord__Subscription__c>();
          list<csord__service__c> servicesToUpdate =  new List<csord__service__c>();
          for(csord__order__c ordRec: [Select Id, csord__status2__c from csord__order__c where Id IN: orderIds]){
              ordRec.csord__status2__c = onsOptions.csordtelcoa__Order_Initial_State__c;
              orderToUpdate.add(ordRec);
          }
          for(csord__subscription__c subRec: [Select Id, csord__status__c from csord__Subscription__c where csord__order__c IN: orderIds]){
              if(subRec.csord__status__c != onsOptions.csordtelcoa__Subscription_Initial_State__c){
                  subRec.csord__status__c = onsOptions.csordtelcoa__Subscription_Initial_State__c;
                  subsToUpdate.add(subRec);
              }
              
          }
          
          for(csord__service__c servRec: [Select Id, csord__status__c from csord__service__c where csord__order__c IN: orderIds]){
              if(servRec.csord__status__c != onsOptions.csordtelcoa__Service_Initial_State__c){
                  servRec.csord__status__c = onsOptions.csordtelcoa__Service_Initial_State__c;
                  servicesToUpdate.add(servRec);
              }
          }
          update orderToUpdate;
          update subsToUpdate;
          update servicesToUpdate;
          
          List<order_decomposition_request__e> orderObserverEvents= new list<order_decomposition_request__e>();
          for(String orderId : orderIds){
            orderObserverEvents.add(new order_decomposition_request__e(order_Id__c=orderId, observer_Invocation__c=true));
          }
          //Publish the event
          OrderGenrationHelper.publishOrderDecompositionEvents(orderObserverEvents, orderIds );
    }

    
}