/*
DESCRIPTION: This class is used to identify the Primary Order from all the orders created for the basket.
*/
public with sharing class OrderMerge{
    
    public static List<ID> singleOrder(List<ID> orderList){
        List<ID> primaryOrderIDList = new List<ID>();
        Map<Id, List<csord__Order__c>> ordReqIdOrdIdSetMap = new Map<Id, List<csord__Order__c>>();
        for(csord__Order__c order: [Select id, csord__Primary_Order__c, csord__Order_Request__c from csord__Order__c where Id IN:orderList]){
            if(order.csord__Order_Request__c != null){
                if(ordReqIdOrdIdSetMap.containsKey(order.csord__Order_Request__c)){
                    List<csord__Order__c> orderLst =ordReqIdOrdIdSetMap.get(order.csord__Order_Request__c);
                    orderLst.add(order);
                    ordReqIdOrdIdSetMap.put(order.csord__Order_Request__c,orderLst);
                }
                else{
                    List<csord__Order__c> orderLst = new List<csord__Order__c>();
                    orderLst.add(order);
                    ordReqIdOrdIdSetMap.put(order.csord__Order_Request__c,orderLst);
                }
            }
        }
        System.debug('ordReqIdOrdIdSetList<><>'+ordReqIdOrdIdSetMap);
        Set<Id> ordReqIDs = new Set<Id>(ordReqIdOrdIdSetMap.keySet());
        
         for(Id ordReqID: ordReqIDs){
            List<csord__Order__c> oList = ordReqIdOrdIdSetMap.get(ordReqID);
            for(csord__Order__c ord: oList){
                if(ord.csord__Primary_Order__c == null  ){
                    primaryOrderIDList.add(ord.id);
                }
            }
        }  
        return primaryOrderIDList;
    }
}