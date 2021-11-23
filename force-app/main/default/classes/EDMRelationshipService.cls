/*
===============================================================================================================================
Class : EDMRelationshipService
Developer Name : Pulkit Gupta
Date : 19/02/2018
Test Class : EDMRelationshipServiceTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Pulkit Gupta        19/02/2018    EDGE-9945 : (Technical Story) Introduce Parent-Child and Associated to Relationships
between various specifications generated as a part of Order Decomposition so that
the payload sent to AMDOCS has the correct associations defined for fulfilment.
===============================================================================================================================
*/
public with sharing class EDMRelationshipService {

    // MG fix for SOQL101 issue - 3 or more sites
    @TestVisible
    private class specUpdate{
        public String guid;
        public String serviceId;
        public Map<String, String> additionalAttrs;
    }

    public static void createRelationShip(List<Id> orderList) {
    
        // MG fix for SOQL101 start
        List<specUpdate> specificationsToUpdate = new List<specUpdate>();
        List<String> serviceSpecsForUpdate = new List<String>();
        // MG fix for SOQL101 start  

        Set<ID> accSet = new Set<ID>();
        Map<Id,List<csord__Subscription__c>> accIDSubListMap = new Map<Id,List<csord__Subscription__c>>();
        Map<Id, List<csord__Order__c>> ordReqIdOrdIdSetMap = new Map<Id, List<csord__Order__c>>();
        Map<Id,Id> legacyAndNewSubMap = new Map<Id,Id>();
        Feature_Flag__mdt ft= FeatureFlagUtility.getFeatureTogglingByName('B2B2');
        for(csord__Order__c order: [Select id, Name, csord__Primary_Order__c, csord__Account__c, csord__Order_Request__c from csord__Order__c where Id IN:orderList]){
            if(order.csord__Order_Request__c != null){
                accSet.add(order.csord__Account__c);
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
        Map<Id,csord__Subscription__c> legacySub = new Map<Id,csord__Subscription__c>([SELECT Id, Name, csord__Account__c,csordtelcoa__Replacement_Subscription__c FROM csord__Subscription__c WHERE name  Like 'Legacy%' and csordtelcoa__Replacement_Subscription__r.csord__Order__c IN: orderList]);
        if(accSet != null){
            for(csord__Subscription__c sub:[SELECT Id, Name, csord__Account__c FROM csord__Subscription__c WHERE (Name =: System.Label.IP_Network OR Name =: System.Label.UC_Config_Name) AND csord__Account__c IN:accSet]){
                if(accIDSubListMap.containsKey(sub.csord__Account__c)){
                    List<csord__Subscription__c> subLst =accIDSubListMap.get(sub.csord__Account__c);
                    subLst.add(sub);
                    accIDSubListMap.put(sub.csord__Account__c,subLst);
                }
                else{
                    List<csord__Subscription__c> subLst = new List<csord__Subscription__c>();
                    subLst.add(sub);
                    accIDSubListMap.put(sub.csord__Account__c,subLst);
                }
            }

        }
        System.debug('<><><>orderRequestID'+ordReqIdOrdIdSetMap.keyset());
        for(Id orderrequestID: ordReqIdOrdIdSetMap.keyset()){
            System.debug('OrderRequestID<><><><><>'+orderrequestID);
            Map<String, Map<String, String>> productSubsSepcMap = new Map<String, Map<String, String>>();
            Map<String, String> productSepcMapForFailOver = new Map<String, String>();
            Map<String,String> productSpecLegacyMap = new Map<String,String>();
            Map<string, String> ipUCECodeGUIDMap = new Map<string, String>();
            Map<Id, csord__Order__c> orderMap = new Map<Id, csord__Order__c>(ordReqIdOrdIdSetMap.get(orderrequestID));
            Map<Id, List<CS_SpecificationDTO.ServiceSpecification>> mapServiceSpecification = getOrderSpecs(orderMap);
               
            System.debug('****mapServiceSpecification'+mapServiceSpecification);
            if(accIDSubListMap.get(ordReqIdOrdIdSetMap.get(orderrequestID)[0].csord__Account__c) != null){
                ipUCECodeGUIDMap = getCodesANDGUIDsOFExistingIPNetworkUCE(accIDSubListMap.get(ordReqIdOrdIdSetMap.get(orderrequestID)[0].csord__Account__c));
                System.debug('<><><>ipUCECodeGUIDMap'+ipUCECodeGUIDMap);
            }
            if(!legacySub.isEmpty())
            {
                for(csord__Subscription__c sub:legacySub.values())
                {
                  legacyAndNewSubMap.put(sub.id,sub.csordtelcoa__Replacement_Subscription__c);
                }
                mapServiceSpecification.putAll(getSubscriptionSpecs(legacySub));
            } 
            system.debug('inside edm'+mapServiceSpecification.keyset()+'-----'+mapServiceSpecification.values());

            for(List<CS_SpecificationDTO.ServiceSpecification> lstSerSpec : mapServiceSpecification.values()) {
                for(CS_SpecificationDTO.ServiceSpecification serSpec : lstSerSpec) {                    
                    Map<String, String> productSepcMap;
                    if(productSubsSepcMap.containsKey(serSpec.subscriptionId)) {
                        productSepcMap = productSubsSepcMap.get(serSpec.subscriptionId);
                    }
                    else {
                        productSepcMap  = new Map<String, String>();
                    }
                    
                    if( ft.IsActive__c ==true){
                    if(serSpec.code == 'DMCAT_ProductSpecification_000104_Fulfilment')
                    {
                      productSepcMap.put(serSpec.code, serSpec.guid);
                    
                    }
                    else
                    {
                      productSepcMap.put(serSpec.code+serSpec.serviceId, serSpec.guid);
                    
                    }
                    } else{
                    if(serSpec.code == 'PS_000104_Fulfilment')
                    {
                      productSepcMap.put(serSpec.code, serSpec.guid);
                    
                    }
                    else
                    {
                      productSepcMap.put(serSpec.code+serSpec.serviceId, serSpec.guid);
                    
                    }   
                    }
                   
                    productSpecLegacyMap.put(serSpec.code+serSpec.subscriptionId, serSpec.guid);
                    // In case of the reference are cross Subs
                    productSepcMapForFailOver.put(serSpec.code+serSpec.subscriptionId, serSpec.guid); 
                    productSubsSepcMap.put(serSpec.subscriptionId, productSepcMap);
                }
            }
             System.debug('****productSubsSepcMap'+productSubsSepcMap);
             System.debug('*****productSepcMapForFailOver'+productSepcMapForFailOver);
             System.debug('*****productSpecLegacyMap'+productSpecLegacyMap);
            for(List<CS_SpecificationDTO.ServiceSpecification> lstSerSpec : mapServiceSpecification.values()) {
                for(CS_SpecificationDTO.ServiceSpecification serSpec : lstSerSpec) {
                    Map<String, String> additionalAttrs = new Map<String, String>();
                    System.debug('Simpleattributes<><>'+serSpec.simpleAttributes);
                    for(CS_SpecificationDTO.SimpleAttributes simpleAttr : serSpec.simpleAttributes) {
                        if(string.isNotBlank(simpleAttr.value)) {
                            if( ft.IsActive__c ==true){
                                if(simpleAttr.value.startsWith('DMCAT_ProductSpecification_') && simpleAttr.value == 'DMCAT_ProductSpecification_000104_Fulfilment' && productSubsSepcMap.get(serSpec.subscriptionId).containsKey(simpleAttr.value)) {
                                    additionalAttrs.put(simpleAttr.name, productSubsSepcMap.get(serSpec.subscriptionId).get(simpleAttr.value));
                                    System.debug('---------------------> SUBS LEVEL1-->' + simpleAttr.name + ':' + simpleAttr.value+':'+serSpec.subscriptionId+':'+productSubsSepcMap.get(serSpec.subscriptionId)+':'+productSubsSepcMap.get(serSpec.subscriptionId).get(simpleAttr.value));
                                } 
                                else  if(simpleAttr.value.startsWith('DMCAT_ProductSpecification_') && simpleAttr.value != 'DMCAT_ProductSpecification_000104_Fulfilment'&& productSubsSepcMap.get(serSpec.subscriptionId).containsKey(simpleAttr.value+serSpec.serviceId)) {
                                    additionalAttrs.put(simpleAttr.name, productSubsSepcMap.get(serSpec.subscriptionId).get(simpleAttr.value+serSpec.serviceId));
                                    System.debug('---------------------> SUBS LEVEL2-->' + simpleAttr.name + ':' + simpleAttr.value+':'+serSpec.subscriptionId+':'+productSubsSepcMap.get(serSpec.subscriptionId)+':'+productSubsSepcMap.get(serSpec.subscriptionId).get(simpleAttr.value+serSpec.serviceId));
                                } 
                                else if(simpleAttr.value.startsWith('DMCAT_ProductSpecification_') && legacyAndNewSubMap.containsKey(serSpec.subscriptionId) && productSpecLegacyMap.containsKey(simpleAttr.value + legacyAndNewSubMap.get(serSpec.subscriptionId))) {
                                    additionalAttrs.put(simpleAttr.name, productSpecLegacyMap.get(simpleAttr.value + legacyAndNewSubMap.get(serSpec.subscriptionId)));
                                    System.debug('---------------------> ORDER LEVEL1-->' + simpleAttr.name + ':' + simpleAttr.value + legacyAndNewSubMap.get(serSpec.subscriptionId));
                                }
                                else if(simpleAttr.value.startsWith('DMCAT_ProductSpecification_') &&  productSepcMapForFailOver.containsKey(simpleAttr.value+serSpec.subscriptionId)) {
                                    additionalAttrs.put(simpleAttr.name, productSepcMapForFailOver.get(simpleAttr.value+serSpec.subscriptionId));
                                    System.debug('---------------------> ORDER LEVEL2-->' + simpleAttr.name + ':' + simpleAttr.value+':'+serSpec.subscriptionId);
                                }
                                
                                else if(simpleAttr.value.startsWith('DMCAT_ProductSpecification_') && ipUCECodeGUIDMap.containsKey(simpleAttr.value)) {
                                    additionalAttrs.put(simpleAttr.name, ipUCECodeGUIDMap.get(simpleAttr.value));
                                    System.debug('---------------------> ORDER LEVEL3-->' + simpleAttr.name + ':' + simpleAttr.value);
                                }
                                else if(simpleAttr.value.startsWith('DMCAT_ProductSpecification_') && simpleAttr.name.contains('TIPT') && ipUCECodeGUIDMap.containsKey(simpleAttr.value)) {
                                    additionalAttrs.put(simpleAttr.name, ipUCECodeGUIDMap.get(simpleAttr.value));
                                    System.debug('---------------------> LEGACY LEVEL-->' + simpleAttr.name + ':' + simpleAttr.value);
                                }
                            }else{
                                
                                if(simpleAttr.value.startsWith('PS_') && simpleAttr.value == 'PS_000104_Fulfilment' && productSubsSepcMap.get(serSpec.subscriptionId).containsKey(simpleAttr.value)) {
                                    additionalAttrs.put(simpleAttr.name, productSubsSepcMap.get(serSpec.subscriptionId).get(simpleAttr.value));
                                    System.debug('---------------------> SUBS LEVEL1-->' + simpleAttr.name + ':' + simpleAttr.value+':'+serSpec.subscriptionId+':'+productSubsSepcMap.get(serSpec.subscriptionId)+':'+productSubsSepcMap.get(serSpec.subscriptionId).get(simpleAttr.value));
                                } 
                                else  if(simpleAttr.value.startsWith('PS_') && simpleAttr.value != 'PS_000104_Fulfilment'&& productSubsSepcMap.get(serSpec.subscriptionId).containsKey(simpleAttr.value+serSpec.serviceId)) {
                                    additionalAttrs.put(simpleAttr.name, productSubsSepcMap.get(serSpec.subscriptionId).get(simpleAttr.value+serSpec.serviceId));
                                    System.debug('---------------------> SUBS LEVEL2-->' + simpleAttr.name + ':' + simpleAttr.value+':'+serSpec.subscriptionId+':'+productSubsSepcMap.get(serSpec.subscriptionId)+':'+productSubsSepcMap.get(serSpec.subscriptionId).get(simpleAttr.value+serSpec.serviceId));
                                } 
                                else if(simpleAttr.value.startsWith('PS_') && legacyAndNewSubMap.containsKey(serSpec.subscriptionId) && productSpecLegacyMap.containsKey(simpleAttr.value + legacyAndNewSubMap.get(serSpec.subscriptionId))) {
                                    additionalAttrs.put(simpleAttr.name, productSpecLegacyMap.get(simpleAttr.value + legacyAndNewSubMap.get(serSpec.subscriptionId)));
                                    System.debug('---------------------> ORDER LEVEL1-->' + simpleAttr.name + ':' + simpleAttr.value + legacyAndNewSubMap.get(serSpec.subscriptionId));
                                }
                                else if(simpleAttr.value.startsWith('PS_') &&  productSepcMapForFailOver.containsKey(simpleAttr.value+serSpec.subscriptionId)) {
                                    additionalAttrs.put(simpleAttr.name, productSepcMapForFailOver.get(simpleAttr.value+serSpec.subscriptionId));
                                    System.debug('---------------------> ORDER LEVEL2-->' + simpleAttr.name + ':' + simpleAttr.value+':'+serSpec.subscriptionId);
                                }
                                
                                else if(simpleAttr.value.startsWith('PS_') && ipUCECodeGUIDMap.containsKey(simpleAttr.value)) {
                                    additionalAttrs.put(simpleAttr.name, ipUCECodeGUIDMap.get(simpleAttr.value));
                                    System.debug('---------------------> ORDER LEVEL3-->' + simpleAttr.name + ':' + simpleAttr.value);
                                }
                                else if(simpleAttr.value.startsWith('PS_') && simpleAttr.name.contains('TIPT') && ipUCECodeGUIDMap.containsKey(simpleAttr.value)) {
                                    additionalAttrs.put(simpleAttr.name, ipUCECodeGUIDMap.get(simpleAttr.value));
                                    System.debug('---------------------> LEGACY LEVEL-->' + simpleAttr.name + ':' + simpleAttr.value);
                                }
                            
                            }
                            
                        }
                    }
                    if(!additionalAttrs.isEmpty()) {
                        // MG fix for SOQL101 start
                        //csedm.API_1.addCharacteristic(serSpec.serviceId, serSpec.guid, additionalAttrs);
                        specUpdate specToUpdate = new specUpdate();
                        specToUpdate.serviceId = serSpec.serviceId;
                        specToUpdate.guid = serSpec.guid;
                        specToUpdate.additionalAttrs = additionalAttrs;
                        specificationsToUpdate.add(specToUpdate);
                        
                        serviceSpecsForUpdate.add(serSpec.serviceId);
                        // MG fix for SOQL101 end
                    }
                }
            }
            
        }
        
        // MG fix for SOQL101 start
        List<Attachment> atts =  [
            select Id, Name, body, parentId
            from Attachment
            where parentId IN :serviceSpecsForUpdate
            and name = 'ServiceSpecifications.json'
        ];
        //List<Attachment> attsToUpdate = new List<Attachment>();
        Map<Id, Attachment> attsMapToUpdate = new Map<Id, Attachment>();
        for (specUpdate currentSpec : specificationsToUpdate) {
            for (Attachment att : atts) {
                if (att.parentID == currentSpec.serviceId) {
                    //attsToUpdate.add(addCharacteristics(currentSpec.serviceId, currentSpec.guid, currentSpec.additionalAttrs, att));
                    Attachment attToUpdate = addCharacteristics(currentSpec.serviceId, currentSpec.guid, currentSpec.additionalAttrs, att);
                    attsMapToUpdate.put(attToUpdate.Id, attToUpdate);
                }
            }
        }
        if (attsMapToUpdate.size() > 0){
            /*for(Attachment attToUpdate : attsToUpdate){
                update attToUpdate;
            }*/
            update attsMapToUpdate.values();         
        }
        // MG fix for SOQL101 end
        
    }
    
    // MG fix for SOQL101 issue helper method
    private static Attachment addCharacteristics(String serviceId, String identifier, Map<String, String> nameValuePairs, Attachment at) {

        String str = at.Body.toString();
        
        // helper method start
        String serviceAttachment = str;
        Map<String, Object> attachmentMap = (Map<String, Object>) JSON.deserializeUntyped(serviceAttachment);
        List<Object> specificationList = (List<Object>) attachmentMap.get('specifications');

        if (specificationList != null) {
            for (Object o : specificationList) {
                Map<String, Object> specMap = (Map<String, Object>) o;
                String specGuid = (String) specMap.get('guid');
                String specInstanceId = (String) specMap.get('instanceId');

                if (specGuid == identifier || specInstanceId == serviceId) {
                    specMap.put('additionalAttributes', nameValuePairs);
                }
            }
        }
        serviceAttachment = JSON.serializePretty(attachmentMap);
        str = serviceAttachment;
        // helper method end
        
        at.body = blob.valueOf(str);

        return at;
    }
    
    public static Map<Id, List<CS_SpecificationDTO.ServiceSpecification>> getOrderSpecs(Map<Id, csord__Order__c> orders) {
        
        Map<Id, List<CS_SpecificationDTO.ServiceSpecification>> specMap = new Map<Id, List<CS_SpecificationDTO.ServiceSpecification>>();
        List<Id> orderIds = new List<Id>(orders.keySet());
        for (Id ordId: orderIds) {
            List<CS_SpecificationDTO.ServiceSpecification>  specList = new List<CS_SpecificationDTO.ServiceSpecification>();
            String orderSpec = csedm.API_1.getOrderSpecificationsById(ordId);
            if(!String.isEmpty(orderSpec)){
                system.debug('**************orderSpec : '+orderSpec);
                specList = CS_SpecificationDTO.parse(orderSpec);
                system.debug('**************specList<><>: '+specList);
                if(orders.get(ordId) != null){
                    if(specMap.get(orders.get(ordId).Id) != null) {
                        specMap.get(orders.get(ordId).Id).addAll(specList);
                    }
                    else {
                        specMap.put(orders.get(ordId).Id, specList);
                    }
                }
            }
        }
        return specMap;
    }
    public static Map<Id, List<CS_SpecificationDTO.ServiceSpecification>> getSubscriptionSpecs(Map<Id, csord__Subscription__c> subs) {
        
        Map<Id, List<CS_SpecificationDTO.ServiceSpecification>> specMap = new Map<Id, List<CS_SpecificationDTO.ServiceSpecification>>();
        List<Id> subIds = new List<Id>(subs.keySet());
        for (Id subId: subIds) {
            List<CS_SpecificationDTO.ServiceSpecification>  specList = new List<CS_SpecificationDTO.ServiceSpecification>();
            String subSpec = csedm.API_1.getSubscriptionSpecificationsById(subId);
            if(!String.isEmpty(subSpec)){ 
                system.debug('**************subSpec : '+subSpec);
                specList = CS_SpecificationDTO.parseSubscriptionSpec(subSpec);
                system.debug('**************specList<><>: '+specList);
                if(subs.get(subId) != null){
                    if(specMap.get(subId) != null) {
                        specMap.get(subId).addAll(specList);
                    }
                    else {
                        specMap.put(subId, specList);
                    }
                }
            }
        }
        System.debug('****specMap'+specMap);
        return specMap;
    }

    public static Map<String, String> getCodesANDGUIDsOFExistingIPNetworkUCE(List<csord__Subscription__c> subList){
        
        Map<string, String> ipUCECodeGUIDMap= new Map<String,String>();

        for(csord__Subscription__c sub: subList){
            String cc = csedm.API_1.getSubscriptionSpecificationsById(sub.Id);
            system.debug('specList<><>'+cc); 
            List<CS_SpecificationDTO.ServiceSpecification>  specList = new List<CS_SpecificationDTO.ServiceSpecification>();
            if(cc != null){
                specList = CS_SpecificationDTO.parseSubscriptionSpec(cc);
                system.debug('specList<><>'+specList);
                for(CS_SpecificationDTO.ServiceSpecification ss: specList){	
                   ipUCECodeGUIDMap.put(ss.code, ss.guid);
                }
                system.debug('ipUCECodeGUIDMap<><>'+ipUCECodeGUIDMap);
            }    
            
        }
        return ipUCECodeGUIDMap;
    }
}