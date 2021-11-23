/*
===============================================================================================================================
Class : SDWANServiceTenancyHandler
Developer Name : Payel
Test Class : SDWANServiceTenancyHandlerTest
===============================================================================================================================
Sr.No.    Developer Name        Date          Story Description
1          Payel             20/05/2021      DPG-5387/DPG-5649
2          Suyash            24/08/2021      DIGI-11880
3			Payel            17/09/2021		DIGI-18412
3			Suyash            27/09/2021		DIGI-14133
===============================================================================================================================*/
global with sharing class SDWANServiceTenancyHandler implements cssmgnt.RemoteActionDataProvider {
    @RemoteAction
    global static Map < String, Object > getData(Map < String, Object > inputMap) {
        System.debug('inputMap' + inputMap);
        Map < String, Object > returnMap = new Map < String, Object > ();
        Set < String > inputKey = inputMap.keySet();
        for (String k: inputKey) {
            if (k == 'GetTenancyDetailsforService') {
                String accIds = (String) inputMap.get('GetTenancyDetailsforService');
                System.debug('GetTenancyDetailsforService: ' + accIds);
                String res = GetTenancyDetailsforService(accIds);
                returnMap.put('GetTenancyDetailsforService', res);
            }
            if (k == 'GetInterConDetails') {
                String accIds = (String) inputMap.get('GetInterConDetails');
                System.debug('GetInterConDetails: ' + accIds);
                String res = GetInterConDetails(accIds);
                returnMap.put('GetInterConDetails', res);
            }
            if (k == 'GetCommercialProductDetails') {
                String commercialProductId = (String) inputMap.get('GetCommercialProductDetails');
                System.debug('GetCommercialProductDetails: ' + commercialProductId);
                String res = GetCommercialProductDetails(commercialProductId);
                returnMap.put('GetCommercialProductDetails', res);
            }
        }
        return returnMap;
    }
    global static string GetTenancyDetailsforService(String accountId) {
        try {
            Map < id, csord__Service__c > serviceMap = new Map < id, csord__Service__c > ();
            List < csord__Service__c > serviceList = [SELECT id,
                tenancy_id__c,
                csord__subscription__c,
                csord__subscription__r.configspecid__c
                FROM csord__service__c
                WHERE csord__subscription__r.csord__account__c =: accountId
                AND csord__subscription__r.csord__status__c =: System.label.active
                AND csord__subscription__r.configspecid__c IN(: System.label.ConfigSpecID_for_SDWAN_VeloCloud,: System.label.ConfigSpecID_for_SDWAN_SecureEdge,: System.label.ConfigSpecID_for_SDWAN_SecureEdgeCloudTenancy,: System.label.ConfigSpecID_for_SDWAN_InterCon)
            ];
            system.debug('serviceList:' + serviceList);
            String vCguId = '';
            String sEgu_Id = '';
            String sETengu_Id = '';
            String TenancyId = '';
            String TenancySecId = '';
            if (serviceList != null && !serviceList.isEmpty()) {
                for (csord__Service__c seer: serviceList) {
                    serviceMap.put(seer.id, seer);
                    system.debug('seer:' + seer);
                    if (seer.csord__Subscription__r.ConfigSpecID__c == System.label.ConfigSpecID_for_SDWAN_VeloCloud) {
                        TenancyId = seer.Tenancy_Id__c;
                        system.debug('TenancyId:' + TenancyId);
                    }
                    //Added for DIGI-11880
                    if (seer.csord__Subscription__r.ConfigSpecID__c == System.label.ConfigSpecID_for_SDWAN_SecureEdgeCloudTenancy) {
                        TenancySecId = seer.Tenancy_Id__c;
                        system.debug('TenancySecId:' + TenancySecId);
                    }
                }
                for (Attachment att: [select ID, name, body, parentId from Attachment where parentId in: serviceMap.keyset() and name = 'ServiceSpecifications.json']) {
                    String newServiceAttachmentStr = att.body.toString();
                    Map < String, Object > updatedResults = (Map < String, Object > ) JSON.deserializeUntyped(newServiceAttachmentStr);
                    List < Object > lstSpecifications = (List < Object > ) updatedResults.get('specifications');
                    List < Object > newlstSpecifications = new List < Object > ();
                    for (Object spec: lstSpecifications) {
                        Map < String, Object > specificationAttributes = (Map < String, Object > ) spec;
                        if (specificationAttributes != null) {
                            if (String.valueOf(specificationAttributes.get('code')).contains(System.label.VeloCloud_Tenancy_Fulfilment)) {
                                vCguId = String.valueOf(specificationAttributes.get('guid'));
                                system.debug('vCguId:' + vCguId);
                            }
                            if (String.valueOf(specificationAttributes.get('code')).contains(System.label.SecureEdge_Cloud_Fulfilment)) {
                                sEgu_Id = String.valueOf(specificationAttributes.get('guid'));
                                system.debug('sEgu_Id:' + sEgu_Id);
                            }
                            if (String.valueOf(specificationAttributes.get('code')).contains(System.label.SecureEdge_CloudTenancy_Fulfilment)) {
                                sETengu_Id = String.valueOf(specificationAttributes.get('guid'));
                                system.debug('sETengu_Id:' + sETengu_Id);
                            }
                        }
                    }
                }
            }

            Map < String, String > outputmap = new Map < String, String > ();
            outputmap.put('vCguId', vCguId);
            outputmap.put('Tenancy_Id', TenancyId);
            outputmap.put('sEgu_Id', sEgu_Id);
            outputmap.put('TenancySecId', TenancySecId);
            outputmap.put('TenancySecIdCloud', sETengu_Id);
            String json = JSON.serialize(outputmap);
            system.debug('json:' + json);
            return json;
        } catch (Exception e) {
            System.debug('SDWANServiceTenancyHandler.GetTenancyDetailsforService: ' + e.getMessage());
        }
        return '';
    }
    //Added related to DIGI-18412
    global static string GetInterConDetails(String accountId) {
        try {
            Map < id, csord__Service__c > serviceMap = new Map < id, csord__Service__c > ();
            List < cscfga__Product_Configuration__c > PCList;
            List < cscfga__Attribute__c > Listofvalues;
            Map < id, cscfga__Product_Configuration__c > PCListMap = new Map < id, cscfga__Product_Configuration__c > ();
            Map < Id, Map < String, String >> allAttributesRelatedPrdt = new Map < Id, Map < String, String >> ();
            List < csord__Service__c > serviceList = [SELECT id,
                csord__subscription__r.configspecid__c,
                csordtelcoa__Product_Configuration__r.id
                FROM csord__service__c
                WHERE csord__subscription__r.csord__account__c =: accountId
                AND csord__subscription__r.csord__status__c =: System.label.active
                AND csord__subscription__r.configspecid__c =: System.label.ConfigSpecID_for_SDWAN_InterCon
            ];
            system.debug('serviceList:' + serviceList);
            //system.debug('serviceList:' + serviceList.get(3));

            if (serviceList != null && !serviceList.isEmpty()) {
                for (csord__Service__c seer: serviceList) {
                    //serviceMap.put(seer.id, seer);
                    serviceMap.put(seer.csordtelcoa__Product_Configuration__r.id, seer);
                   //system.debug('seer:' + seer);
                   // system.debug('seer:' + serviceMap);
                  //  system.debug('serviceMap.keyset():' + serviceMap.keyset());
                }
                    PCList = [
                        SELECT Id, (SELECT Id, Name, cscfga__Display_Value__c, cscfga__Value__c FROM cscfga__Attributes__r WHERE Name IN('PoP'))
                        FROM cscfga__Product_Configuration__c
                        WHERE id =: serviceMap.keyset()
                    ];
                    system.debug('PCList:' + PCList);
                    if (PCList != null && !PCList.isEmpty()) {
                        for (cscfga__Product_Configuration__c pc: PCList) {
                            for (cscfga__Attribute__c attributeRecord: pc.cscfga__Attributes__r) {
                                system.debug('attributeRecord:' + attributeRecord);
                                //Map < String, String > mapAttrNameRecord = allAttributesRelatedPrdt.get(pc.id);
                                if (allAttributesRelatedPrdt.containskey(pc.id)) {
                                    Map < String, String > mapAttrNameRecord = allAttributesRelatedPrdt.get(pc.id);
                                    mapAttrNameRecord.put(attributeRecord.Name, attributeRecord.cscfga__Value__c);
                                   //system.debug('mapAttrNameRecord:' + mapAttrNameRecord);
                                } else {
                                    Map < String, String > mapAttrNameRecord = new Map < String, String > ();
                                    mapAttrNameRecord.put(attributeRecord.Name, attributeRecord.cscfga__Value__c);
                                    allAttributesRelatedPrdt.put(pc.id, mapAttrNameRecord);
                                    //allAttributesRelatedPrdt.put('Config', mapAttrNameRecord);
                                   // system.debug('mapAttrNameRecord:' + mapAttrNameRecord);
                                }
                                system.debug('allAttributesRelatedPrdt:' + allAttributesRelatedPrdt);
                            }
                        }
                        //system.debug('mapAttrNameRecord:' + mapAttrNameRecord);
                    }


                
            }
            String json = JSON.serialize(allAttributesRelatedPrdt);
            system.debug('json:' + json);
            return json;
        } catch (Exception e) {
            System.debug('SDWANServiceTenancyHandler.GetInterConDetails: ' + e.getMessage());
        }
        return '';
    }
    //DIGI-14133 - To get Commercial product based id
    global static String GetCommercialProductDetails(String commercialProductId){
        if(String.isNotBlank(commercialProductId)){
            cspmb__Price_Item__c commercialProduct = [SELECT Id,Bandwidth__c, cspmb__Recurring_Charge__c FROM cspmb__Price_Item__c 
                                                           WHERE id = :commercialProductId];
            Map < String, String > outputmap = new Map < String, String > ();
            outputmap.put('id', commercialProduct.id);
            outputmap.put('RecurringCharge', String.valueOf(commercialProduct.cspmb__Recurring_Charge__c));
            outputmap.put('Bandwidth', (String)commercialProduct.Bandwidth__c);
            String json = JSON.serialize(outputmap);
            system.debug('json:' + json);
            return json;
        }
        return null;
    }
}