/*
===============================================================================================================================
Class : UpdateFixedSeatCountOnIPNetwork
Test Class : UpdateFixedSeatCountOnIPNetwork_Test
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Shubhi Vijayvergia 9/4/2018       EDGE-79472 (bug fix)

===============================================================================================================================
*/
public with sharing class UpdateFixedSeatCountOnIPNetwork{
     
    /*@TestVisible
    private class specUpdate{
        public String guid;
        public String serviceId;
        public Map<String, String> addAttrMap;
    }*/
     
    public static void getTotalFixedUsersOnAccount(set<Id> accountIds, Set<Id> oppIds){
             
        Map<Id,Integer> mapList = new Map<Id,Integer>();
      	Set<String> SitePresent= new Set<String>(); //EDGE-79472
         
        if(accountIds.size() > 0){
            //sr 1. updated query to exclude all subscription but include only pending subscriptions 
            string userType='%'+System.label.UserfixedSeatName+'%';
            string SubsStatus=System.label.PendingSubscriptionStatus;

            for(csord__Service__c  serviceList : [select id, name, 
                                                  csord__Subscription__r.csord__Account__c, 
                                                  csord__Subscription__r.name,csord__Subscription__r.Site__c,
                                                  csordtelcoa__Product_Configuration__r.Quantity_Product_Configuration__c
                                                   from csord__Service__c where 
                                                  name like :userType 
                                                  AND csordtelcoa__Product_Configuration__r.Quantity_Product_Configuration__c != NULL 
                                                  AND csord__Subscription__r.csord__Account__c IN :accountIds  order by CreatedDate DESC]){
                                                      
                 if(!SitePresent.contains(serviceList.csord__Subscription__r.Site__c)) //EDGE-79472
                 {
					SitePresent.add(serviceList.csord__Subscription__r.Site__c); //EDGE-79472                                     
				 	if(mapList.containsKey(serviceList.csord__Subscription__r.csord__Account__c)){
                    	Integer i = mapList.get(serviceList.csord__Subscription__r.csord__Account__c) + Integer.valueOf(serviceList.csordtelcoa__Product_Configuration__r.Quantity_Product_Configuration__c);
                    	mapList.put(serviceList.csord__Subscription__r.csord__Account__c, i);
                	}else{
                         mapList.put(serviceList.csord__Subscription__r.csord__Account__c, Integer.ValueOf(serviceList.csordtelcoa__Product_Configuration__r.Quantity_Product_Configuration__c));
                     }
                 }
            }
        }        
        totalFixedUserQuantity(mapList, oppIds);
        //return mapList;
    }
     
public static void totalFixedUserQuantity(Map<Id,Integer> mapList, Set<Id> oppIds)
{
    Map<Id, Attachment> attsMapToUpdate = new Map<Id, Attachment>();
     
    List<csord__Service__c> serviceList = new List<csord__Service__c>([Select Id, csord__Subscription__c,
              csord__Subscription__r.csord__Order_Request__c, csord__Order__r.csordtelcoa__Opportunity__c, 
              csord__Order__r.csord__Account__c FROM csord__Service__c Where 
              csord__Order__r.csordtelcoa__Opportunity__c IN: oppIds AND name like: 'IP Network%']);
    Set<Id> serviceIdset = new Set<Id>();
    //Map<Id, Id> serviceToSubscriptionId= new Map<Id, Id>();
    Map<Id, Id> serviceIdToAccountIdMap= new Map<Id, Id>();
    for(csord__Service__c service : serviceList){
        //serviceToSubscriptionId.put(service.Id, service.csord__Subscription__c);
        serviceIdToAccountIdMap.put(service.Id, service.csord__Order__r.csord__Account__c);
        serviceIdset.add(service.id);
    }
    Map<Id, Attachment> attmAP = new Map<Id, Attachment>([SELECT id, name, body, parentId FROM Attachment WHERE parentId IN: serviceIdset and name = 'ServiceSpecifications.json']);
     
    FOR(Id attId : attmAP.keyset()  ){
                String serviceattachmentstr = attmAP.get(attId).body.toString();
                //system.debug('serviceattachmentstr'+serviceattachmentstr);
                Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(serviceattachmentstr);
                //system.debug('results'+results);
                List<Object> lstSpecifications = (List<Object>)results.get('specifications');
                //system.debug(lstSpecifications[0]);
                Map<string, string> codeToGuidMap = new Map<String, String>();
                for (Object specification : lstSpecifications) {
                    Map<String, String> additionalAttrs = new Map<String, String>();
                    Map<String, Object> specificationAttributes = (Map<String, Object>)specification;
                    string code = (String) specificationAttributes.get('code');
                    if(code.contains('DMCAT_ProductSpecification_000163')){
                     
                                             
                        // now get attributes for this specification.               
                        additionalAttrs.put('TotalNumberOfUsers',String.valueOf(mapList.get(serviceIdToAccountIdMap.get(attmAP.get(attId).parentId))));
                    }
                    if(!additionalAttrs.isEmpty()) {
                                    if(specificationAttributes.get('additionalAttributes')!=null){
                                        Map<String, Object> tempAdditionalAttMap = (Map<String, Object>) specificationAttributes.get('additionalAttributes');
                                        tempAdditionalAttMap.putall(additionalAttrs);
                                        specificationAttributes.put('additionalAttributes', tempAdditionalAttMap);
                                    }else{
                                        specificationAttributes.put('additionalAttributes', additionalAttrs);
                                    }
                                    serviceattachmentstr = JSON.serializePretty(results);
                                    String str = serviceattachmentstr;
                                    attmAP.get(attId).body = blob.valueOf(str);
                                    attsMapToUpdate.put(attId, attmAP.get(attId));
                    }                  
                }          
    }
     
    if (attsMapToUpdate.size() > 0){
                update attsMapToUpdate.values();        
            }    
}
}