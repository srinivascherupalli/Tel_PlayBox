public with sharing class EDMRelationshipService_V2 {

    public static void createRelationShip(List<Id> oppIds) {
        // get all services on opportunity list
        Map<Id, csord__Service__c> servicesMap = new Map<Id, csord__Service__c>(
            [
                SELECT Id,
                csord__Subscription__c,
                csord__Subscription__r.csord__Order_Request__c,
                csord__Order__r.csordtelcoa__Opportunity__c
                FROM csord__Service__c
                Where csord__Order__r.csordtelcoa__Opportunity__c IN: oppIds
            ]
        );

        // get all ServiceSpecs in services in mentioned opportunities
        Map<Id, Attachment> serviceAttachments = new Map<Id, Attachment>(
            [
                SELECT id,
                name,
                body,
                parentId
                FROM Attachment
                WHERE parentId IN: servicesMap.keySet() and
                name = 'ServiceSpecifications.json'
            ]
        );

        Map<String, String> specificationGUIDMap = new Map<String, String>();
        Map<String, String> specificationGUIDOppMap = new Map<String, String>();
        // iterate through attachment to get each specification code name and guid and other details
        for (Id attId : serviceAttachments.keyset()) {
            Attachment att = serviceAttachments.get(attId);
            csord__Service__c service = servicesMap.get(att.parentId);

            String serviceattachmentstr = serviceAttachments.get(attId).body.toString();
            Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(serviceattachmentstr);
            List<Object> lstSpecifications = (List<Object>)results.get('specifications');
            if (lstSpecifications != null) {
                for (Object specification : lstSpecifications) {
                    // now get attributes for this specification.
                    Map<String, Object> specificationAttributes = (Map<String, Object>)specification;
                    string code = (String) specificationAttributes.get('code');
                    string guid = (String) specificationAttributes.get('guid');

                    String specificationKeyForMap = code + '-' + service.csord__Subscription__c;
                    specificationGUIDMap.put(specificationKeyForMap, guid);

                    specificationKeyForMap = code + '-' + service.csord__Order__r.csordtelcoa__Opportunity__c;
                    specificationGUIDOppMap.put(specificationKeyForMap, guid);
                }
            }
        }
        System.debug(LoggingLevel.INFO, 'EDMRelationshipService_V2.specificationGUIDMap = ' + specificationGUIDMap.values());
        System.debug(LoggingLevel.INFO, 'EDMRelationshipService_V2.specificationGUIDOppMap = ' + specificationGUIDOppMap.values());

        Map<Id, Attachment> attsMapToUpdate = new Map<Id, Attachment>();
        //update children with parent guids and update through attsMapToUpdate
        for (Id attId : serviceAttachments.keyset()) {
            Attachment att = serviceAttachments.get(attId);
            String serviceattachmentstr = serviceAttachments.get(attId).body.toString();
            Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(serviceattachmentstr);
            List<Object> lstSpecifications = (List<Object>)results.get('specifications');
            Boolean attachmentChanged = false;
            if (lstSpecifications != null) {
                for (Object specification : lstSpecifications) {
                    Map<String, Object> specificationAttributesMap = (Map<String, Object>)specification;
                    Map<String, Object> attributesPropertyInSpecification = (Map<String, Object>) specificationAttributesMap.get('attributes');

                    for (String currAtt : attributesPropertyInSpecification.keySet()) {
                        if(currAtt != null && currAtt != '' && attributesPropertyInSpecification.get(currAtt) instanceof String){
                            String currentAttributeValue = (String) attributesPropertyInSpecification.get(currAtt);
                            if (currentAttributeValue != null && currentAttributeValue != '' && currentAttributeValue.contains('DMCAT_ProductSpecification')) {
                                //if currAtt is present in attributes than fetch parent and add his guid to additionalAttributes
                                csord__Service__c service = servicesMap.get(att.parentId);
                                String specificationKeyForMap = currentAttributeValue + '-' + service.csord__Subscription__c;
                                String specificationKeyForOppMap = currentAttributeValue + '-' + service.csord__Order__r.csordtelcoa__Opportunity__c;
                                if (specificationAttributesMap.get('additionalAttributes') != null) {
                                    if (specificationGUIDMap.get(specificationKeyForMap) != null && specificationGUIDMap.get(specificationKeyForMap) != '') {
                                        Map<String, Object> addtionalAttributes = (Map<String, Object>)specificationAttributesMap.get('additionalAttributes');
                                        addtionalAttributes.put(currAtt, specificationGUIDMap.get(specificationKeyForMap));
                                        specificationAttributesMap.put('additionalAttributes', addtionalAttributes);
                                    } else if (specificationGUIDOppMap.get(specificationKeyForOppMap) != null && specificationGUIDOppMap.get(specificationKeyForOppMap) != '') {
                                        Map<String, Object> addtionalAttributes = (Map<String, Object>)specificationAttributesMap.get('additionalAttributes');
                                        addtionalAttributes.put(currAtt, specificationGUIDOppMap.get(specificationKeyForOppMap));
                                        specificationAttributesMap.put('additionalAttributes', addtionalAttributes);
                                    }
                                } else {
                                    //if additionalAttributes do not exist create it and put in JSON
                                    Map<String, String> addtionalAttributesObjectMap = new Map<String, String>();

                                    if (specificationGUIDMap.get(specificationKeyForMap) != null && specificationGUIDMap.get(specificationKeyForMap) != '') {
                                        addtionalAttributesObjectMap.put(currAtt, specificationGUIDMap.get(specificationKeyForMap));
                                        specificationAttributesMap.put('additionalAttributes', addtionalAttributesObjectMap);
                                    } else if (specificationGUIDOppMap.get(specificationKeyForOppMap) != null && specificationGUIDOppMap.get(specificationKeyForOppMap) != '') {
                                        addtionalAttributesObjectMap.put(currAtt, specificationGUIDOppMap.get(specificationKeyForOppMap));
                                        specificationAttributesMap.put('additionalAttributes', addtionalAttributesObjectMap);
                                    }
                                }
                                attachmentChanged = true;
                            }
                        }
                    }
                }
            }
            if (attachmentChanged) {
                System.debug(LoggingLevel.INFO, 'EDMRelationshipService_V2.att = ' + att.Id);
                att.body = blob.valueOf(JSON.serialize(results));
                attsMapToUpdate.put(att.Id, att);
            }
        }

        System.debug(LoggingLevel.INFO, 'EDMRelationshipService_V2.attsMapToUpdate = ' + attsMapToUpdate.size());
        if (attsMapToUpdate.size() > 0)
            update attsMapToUpdate.values();
    }
}