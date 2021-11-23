public with sharing class ObserverImplOrderHelper{
    
    /*@TestVisible
    private class specUpdate{
        public String guid;
        public String serviceId;
        public Map<String, String> addAttrMap;
    }*/
    
public static void getTotalFixedUsersOnAccount(List<String> SubscriptionIds){
        
    Map<Id,Integer> mapList = new Map<Id,Integer>();
    set<Id> accountIds = new set<Id>();
    
    
    
    for(csord__Subscription__c subcription : [SELECT Id,csord__Account__c,csordtelcoa__Product_Configuration__r.Quantity_Product_Configuration__c
                                              FROM csord__Subscription__c WHERE id IN: SubscriptionIds]){
        accountIds.add(subcription.csord__Account__c);
    }
    if(accountIds.size() > 0){
        for(csord__Service__c  serviceList : [select id, name, csord__Subscription__r.csord__Account__c, csord__Subscription__r.name, csordtelcoa__Product_Configuration__r.Quantity_Product_Configuration__c 
                                                from csord__Service__c where name like '%User - Fixed Seat%' AND csordtelcoa__Product_Configuration__r.Quantity_Product_Configuration__c != NULL AND 
                                                csord__Subscription__r.csord__Account__c IN: accountIds]){
            if(mapList.containsKey(serviceList.csord__Subscription__r.csord__Account__c)){
                Integer i = mapList.get(serviceList.csord__Subscription__r.csord__Account__c) + Integer.valueOf(serviceList.csordtelcoa__Product_Configuration__r.Quantity_Product_Configuration__c); 
                mapList.put(serviceList.csord__Subscription__r.csord__Account__c, i); 
            }else{
                     mapList.put(serviceList.csord__Subscription__r.csord__Account__c, Integer.ValueOf(serviceList.csordtelcoa__Product_Configuration__r.Quantity_Product_Configuration__c));
                 }     
        }
    }         
    totalFixedUserQuantity(mapList);
    //return mapList;
}
    
public static void totalFixedUserQuantity(Map<Id,Integer> mapList)
{
    //List<specUpdate> specificationsToUpdate = new List<specUpdate>();
    //List<String> serviceSpecsForUpdate = new List<String>();
    Map<String,String> addAttrMap = new Map<String,String>();
    for(csord__Service__c serv : [select id, name,csord__Subscription__r.csord__Account__c FROM csord__Service__c where 
                                  name like: 'IP Network' AND 
                                  csord__Subscription__r.csord__Account__c IN: mapList.keySet()]){
        List<CS_SpecificationDTO.ServiceSpecification> srvSpecList = 
        CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecificationsById(serv.Id),'FULFILMENT');
        for(CS_SpecificationDTO.ServiceSpecification srvSpec : srvSpecList){
            //if(srvSpec.code.equals('DMCAT_ProductSpecification_000163_Fulfilment'))
            if('DMCAT_ProductSpecification_000163_Fulfilment'.equals(srvSpec.code))
            {
                addAttrMap = new Map<String,String>();
                addAttrMap.put('TotalNumberofUsers',String.valueOf(mapList.get(serv.csord__Subscription__r.csord__Account__c)));
                for(CS_SpecificationDTO.SimpleAttributes attr :srvSpec.additionalAttributes){
                    addAttrMap.put(attr.name,attr.value);
                }
                csedm.API_1.addCharacteristic(srvSpec.serviceId, srvSpec.guid, addAttrMap);
                /*if(!addAttrMap.isEmpty()) 
                {
                    //csedm.API_1.addCharacteristic(srvSpec.serviceId, srvSpec.guid, addAttrMap);
                    specUpdate specToUpdate = new specUpdate();
                    specToUpdate.serviceId = srvSpec.serviceId;
                    specToUpdate.guid = srvSpec.guid;
                    specToUpdate.addAttrMap = addAttrMap;
                    specificationsToUpdate.add(specToUpdate);
                    serviceSpecsForUpdate.add(srvSpec.serviceId);
                }*/
            }
        }
    }
}
}