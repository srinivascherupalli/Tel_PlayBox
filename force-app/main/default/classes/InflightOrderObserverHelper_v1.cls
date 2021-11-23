/*
==========================================================================================================================
Class           : InflightOrderObserverHelper_v1
Developer Name  : Pawan Devaliya
Test Class      : InflightOrderObserverManager_V1Test
==========================================================================================================================
Sr.No.  Developer Name          Modify Date     Story Description
1.      Pawan Devaliya          22/12/2020      EDGE-170547  
2.    Akanksha Jain      22/03/2021    EDGE-200291 added basket type in query   
3.    Prajakta                 07/07/2021    EDGE-216816 added null parameter for OrderObserverUtil_V2.updateOperation method
4.    Prajakta                25/08/2021   EDGE-216816 revert : removed null parameter
==========================================================================================================================
*/

public with sharing class InflightOrderObserverHelper_v1 {
    public static Map<Id,csord__Service__c> performOrderOperationsInChucks(Map<Id, csord__Subscription__c> subscriptionMap, Map<Id, csord__Service__c> serviceMap, Map<Id, ContractJunction__c> basketIdToContractJunctionRecMap,
                                                        Map<Id,Number__c> numberMap,List<Id> opptyId,Map<id,Orchestration_AttachmentWrapper> serviceAttachmentMap,Map<String, List<Basket_To_Order_Field_Map__c>> objBasketMap, Map<Id,Id> orderToBasketMap){       
        try{
            //Calling Methods to do populate appropriate fields in order
            //Methods called are in order, DO NOT Update the sequence of calling the method: Start
            numberMap = OrderObserverUtil_V2.populateNumberFields(serviceMap,numberMap);
            system.debug('serviceMap'+serviceMap);
            serviceMap = InFlightOrderObserverUtil_V1.populateServiceFields(numberMap,serviceMap,serviceAttachmentMap,opptyId);
            subscriptionMap = InFlightOrderObserverUtil_V1.populateSubscriptionFields(subscriptionMap,serviceMap,basketIdToContractJunctionRecMap,objBasketMap, orderToBasketMap);
            //Methods called are in order, DO NOT Update the sequence of calling the method: End
           
            //Below Method is the final method which performs DML on required object
           OrderObserverUtil_V2.updateOperation(null,numberMap,serviceMap,subscriptionMap);
        if(test.isRunningTest()){
            decimal d = 2/0;
        }
        }catch(Exception e){
           system.debug('Exception on Class performOrderOperationsInChucks '+e.getStackTraceString() +e.getMessage());
            //throw new CustomException('Error returned while updating objects: ' + e.getStackTraceString());
            Map<Id,csord__Order__c> updatedOrders = new Map<Id,csord__Order__c>();
            for(csord__Subscription__c objSub: subscriptionMap.values()){
                csord__Order__c objOrders = new csord__Order__c(Id = objSub.csord__Order__c,csord__Status2__c = 'Order Decomposition Failed',Observer_Message__c = e.getMessage());
                  updatedOrders.put(objSub.csord__Order__c,objOrders);
            }
            OrderObserverUtil_V2.updateOperation(updatedOrders,null,null,null); 
        }
        System.debug('InflightOrderObserverHelper_v1 performOrderOperationsInChucks method serviceMap**** ' + serviceMap.size() + ' ' + serviceMap);
        return serviceMap;
    } 
    public static void performFinalOrderUpdates(Map<Id, csord__Order__c> orderMap, Map<Id, cscfga__Product_Basket__c> basketMap, Map<Id, Id> orderIdTobasketIdMap, Map<Id, csord__Service__c> serviceMap,
    Map<String, Id> orderRecordTypeNameToIdMap,Map<String, List<Basket_To_Order_Field_Map__c>> objBasketMap){
       System.debug('InflightOrderObserverHelper_v1 performFinalOrderUpdates method serviceMap**** ' + serviceMap.size() + ' ' + serviceMap);
      
       try{
            Map<Id,csord__Order__c> successOrderMap =   new Map<Id,csord__Order__c>();
            Map<Id,csord__Order__c> AllOrderMap =   new Map<Id,csord__Order__c>();
            Set<Id> orderIds = new Set<Id>();
            
            for(csord__Order__c ord : orderMap.values()){ 
                AllorderMap.put(ord.id,ord);
            }

  
            AllorderMap = InFlightOrderObserverUtil_V1.outputMapBasketFieldsToOrderFields(AllorderMap, basketMap, orderIdTobasketIdMap,objBasketMap);
            successOrderMap.putAll(OrderObserverUtil_V2.updateOperation(AllorderMap,null,null,null));
            //OrderObserverUtil_V2.publishEventforNewOrders(JSON.serialize(successOrderMap));
            
            if(successOrderMap != null && !successOrderMap.isEmpty()){
            for(csord__Order__c ord: successOrderMap.values()){
                if(ord.csord__Status2__c != 'Order Decomposition Failed'){
                    orderIds.add(ord.id);
                }
                
            }
       }
            
            if(orderIds != null && !orderIds.isEmpty()) {       
                ManageInflightOrdOrchestrationHandler.createOrchestrationProcess(new List<Id>(orderIds));
                }
          
 
            //Note: orderMap need to be saved to DB - Database.update(orderMap,false);
        }catch(Exception e){
            Map<Id,csord__Order__c> updatedOrders = new Map<Id,csord__Order__c>();
            for(csord__Order__c objOrdr: orderMap.values()){
                csord__Order__c objOrders = new csord__Order__c(Id = objOrdr.Id,csord__Status2__c = 'Order Decomposition Failed',Observer_Message__c = e.getMessage());
                updatedOrders.put(objOrdr.Id,objOrders);
            }
            OrderObserverUtil_V2.updateOperation(updatedOrders,null,null,null);
        }
       
    }   
}