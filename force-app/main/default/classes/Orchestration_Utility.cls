/*================================================================
 * Appirio, Inc
 * Name: Orchestration_Utility
 * Description: Class to with all the common used methods
 * Created Date: June 01, 2020
 * Created By: Gaurang Maheshwari
 *     Developer             Date         Changes
 *     Martand Atrey      28/07/2020      Added Parent Id to the Attachment [EDGE-165190]
 ==================================================================*/

public without sharing class Orchestration_Utility {
    //EDGE-154518 - Adding variables to define string literal
    public static final String PRIME_SERVICE_ASSOCIATION_ROLE = 'prime';
    public static final String AUXILIARY_SERVICE_ASSOCIATION_ROLE = 'auxiliary';
    public static final String GDN_SERVICE_ASSOCIATION_ROLE = 'gdn';
    //EDGE-156658 - Added gdn Association Role

    //checks if high volume call is enabled
    public static Boolean HighVolumeOrderCheck() {
        return (EnvironmentVariable__c.getValues('EnableHV').Value__c.equalsIgnoreCase('true') ? true : false);
    }

    public static String getUID() {
        Blob aes = Crypto.generateAesKey(128);
        String hex = EncodingUtil.convertToHex(aes);
        String uuid = hex.substring(0, 8) + '-' + hex.substring(8, 12) + '-' + hex.substring(12, 16) + '-' + hex.substring(16, 20) + '-' + hex.substring(20, 32);
        return uuid;
    }

    // This method will expect start time and end time and return the difference time in millisecond format
    public static Long getRequestTimeDifference(DateTime startTime, DateTime endTime) {
        return (endTime.getTime() - startTime.getTime());
    }

    public static SObject getAttachment(csord__Service__c serv, String specType, JSONGenerator serviceSpecJSON, String adborId, Map<String, List<TransitionDataDTO.serviceDTOMobile>> ngUcServiceListMap, Map<String, List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2>> servlistmap, String groupId) {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        if (serv.Id != null) {
            gen.writeStringField('serviceId', serv.Id);
        }
        gen.writeFieldName('specifications');
        gen.writeStartArray();
        String guid = generateGuid();

        CS_SpecificationDTO.serviceSpecification spec = new CS_SpecificationDTO.serviceSpecification();

        if (specType == 'NGUC') {
            System.debug('ngUcServiceListMap ::' + ngUcServiceListMap);
            System.debug('serv.Transition_Id__c ::' + serv.Transition_Id__c);

            List<TransitionDataDTO.serviceDTOMobile> service = ngUcServiceListMap.get(serv.Transition_Id__c + '#' + groupId);
            serviceSpecJSON = createNGUCLegacyServiceSpec(spec, serv, gen, guid, service, adborId, serv.Transition_Id__c);
        } else if (specType == 'DTO') {
            List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2> service = servlistmap.get(serv.Offer_Type__c);
            system.debug('@@service@@' + service);

            serviceSpecJSON = createLegacyServiceSpec(spec, serv, gen, guid, service);
        }

        gen.writeEndArray();
        gen.writeEndObject();
        String serializedBody = gen.getAsString().replace('\\"', '');
        System.debug('****serializedBody' + serializedBody);
        String tempJson1 = serializedBody.replaceAll('\\[ ', '[');
        //String tempJson2 = tempJson1.replaceAll('[]','[]');
        String tempJson3 = tempJson1.replaceAll(' \\]', ']');
        Blob body = Blob.valueOf(tempJson3);

        Attachment att = new Attachment();
        att.Name = 'ServiceSpecifications.json';

        if (serv.Id != null) {
            att.ParentId = serv.Id;
        }

        att.Body = body;
        //sObjectsToInsert.add(att);
        return att;
    }

    //generate service specification CWP
    private static JSONGenerator createLegacyServiceSpec(CS_SpecificationDTO.serviceSpecification spec, csord__Service__c serv, JSONGenerator gen, String guid, List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2> service) {
        spec.ServiceId = serv.Id;
        gen.writeStartObject();
        spec.code = System.Label.LegacyVoiceSpecCode;
        //spec.code='DMCAT_ProductSpecification_000343_Fulfilment';
        spec.version = '1';
        spec.status = System.Label.LegacySpecStatus;
        spec.startDate = String.valueOf(Date.today());
        spec.name = System.Label.LegacySpecName;
        spec.instanceId = guid;
        spec.guid = guid;
        gen.writeStringField('code', spec.code);
        gen.writeStringField('version', spec.version);
        gen.writeStringField('status', spec.status);
        gen.writeStringField('startDate', spec.startDate);
        gen.writeStringField('name', spec.name);
        gen.writeStringField('instanceId', spec.instanceId);
        gen.writeStringField('guid', spec.guid);
        List<CS_SpecificationDTO.SimpleAttributes> saList = new List<CS_SpecificationDTO.SimpleAttributes>();
        CS_SpecificationDTO.SimpleAttributes sa1 = new CS_SpecificationDTO.SimpleAttributes();
        sa1.name = System.Label.LegacyProductType;
        sa1.value = serv.Offer_Type__c;
        saList.add(sa1);
        CS_SpecificationDTO.SimpleAttributes sa2 = new CS_SpecificationDTO.SimpleAttributes();
        sa2.name = System.Label.UCInstanceId; //'UCSiteProductInstanceID';
        sa2.value = System.Label.UCSiteProductInstanceID_Value; //'DMCAT_ProductSpecification_000322_Fulfilment';
        saList.add(sa2);
        CS_SpecificationDTO.SimpleAttributes sa3 = new CS_SpecificationDTO.SimpleAttributes();
        sa3.name = System.Label.LegacyTargetSystem;
        sa3.value = System.Label.LegacyTargetSystemValue; //'FULFILMENT';
        saList.add(sa3);
        CS_SpecificationDTO.SimpleAttributes sa4 = new CS_SpecificationDTO.SimpleAttributes();
        sa4.name = System.label.BSServiceTypeProductInstanceID;
        sa4.value = System.label.BSServiceTypeProductInstanceValue; //'DMCAT_ProductSpecification_000312_Fulfilment';
        saList.add(sa4);
        spec.simpleAttributes = new List<CS_SpecificationDTO.simpleAttributes>();
        spec.simpleAttributes.addAll(saList);
        gen.writeFieldName('attributes');
        gen.writeStartObject();
        for (CS_SpecificationDTO.SimpleAttributes saa : spec.simpleAttributes) {
            if (String.isNotBlank(saa.value)) {
                gen.writeStringField(saa.name, saa.value);
            }
        }
        //****PrimaryFNN Json*****

        //gen.writeFieldName(System.Label.PrimaryFNN);
        //gen.writeStartArray();
        List<String> sList = new List<String>();
        for (ReplicatorGetServiceDataObject_V2.ServiceDTO_V2 ser : service) {
            if ((ser.Association_Role == '' || ser.Association_Role == null || ser.Association_Role == 'Primary')) {
                JSONGenerator gen2 = JSON.createGenerator(true);
                gen2.writeStartObject();
                gen2.writeStringField('Number', ser.Service_Id);
                //gen2.writeStringField('action',system.label.PrimaryFNNAction);
                gen2.writeEndObject();
                String s = gen2.getAsString();
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(s);
                String serializedresult = JSON.serialize(results);
                system.debug('@@' + serializedresult);
                sList.add(serializedresult);
            }
        }
        system.debug(sList);
        String serializedresult2 = System.JSON.serializePretty(sList);
        system.debug('@@' + serializedresult2);
        gen.writeStringField(System.Label.PrimaryFNN, serializedresult2.replace('\\"', '\''));
        //NumberJson
        //gen.writeFieldName('Numbers');
        List<String> sList1 = new List<String>();
        for (ReplicatorGetServiceDataObject_V2.ServiceDTO_V2 ser : service) {
            if (ser.Association_Role == 'Auxiliary') {
                JSONGenerator gen2 = JSON.createGenerator(true);
                gen2.writeStartObject();
                gen2.writeStringField('Number', ser.Service_Id);
                //gen2.writeStringField('action',system.label.PrimaryFNNAction);
                gen2.writeEndObject();
                String s = gen2.getAsString();
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(s);
                String serializedresult = JSON.serialize(results);
                system.debug('@@' + serializedresult);
                sList1.add(serializedresult);
            }
            List<ServiceExtentionComparableWrapper> serEXtList = new List<ServiceExtentionComparableWrapper>();
            //List<ReplicatorGetServiceDataObject_V2.ServiceExtensionDTO_V2> serEXtList=new List<ReplicatorGetServiceDataObject_V2.ServiceExtensionDTO_V2>();
            for (ReplicatorGetServiceDataObject_V2.ServiceExtensionDTO_V2 serExt : ser.serviceExtension) {
                serEXtList.add(new ServiceExtentionComparableWrapper(serExt.Services_To, serExt.Services_From));
            }
            if (serEXtList != null && serEXtList.size() > 0) {
                serEXtList.sort();
                //serEXtList.addAll(serEXtList);
            }

            system.debug('serEXtList**' + serEXtList);

            for (integer i = 0; i < serEXtList.size(); i++) {
                JSONGenerator gen2 = JSON.createGenerator(true);
                gen2.writeStartObject();
                system.debug('@@i@@' + i);
                if (i + 1 <= serEXtList.size() - 1 && Integer.valueOf(serEXtList[i + 1].Services_FROM) - Integer.valueOf(serEXtList[i].Services_TO) == 2) {
                    /*Integer index=0;
for(integer j=i+2; j<serEXtList.size(); j++){
system.debug('@@@Services_FROM@@@'+Integer.valueOf(serEXtList[j].Services_FROM));
system.debug('@@@Services_TO@@@'+Integer.valueOf(serEXtList[j-1].Services_TO));
if(j<= serEXtList.size()-1 && j-1>0 && Integer.valueOf(serEXtList[j].Services_FROM) - Integer.valueOf(serEXtList[j-1].Services_TO) == 1){
system.debug('inside for j');
index=j;
}else{
break;
}

}
if(index==0){
gen2.writeStringField('Range',serEXtList[i].Services_From+':'+serEXtList[i+1].Services_To);
}else{
gen2.writeStringField('Range',serEXtList[i].Services_From+':'+serEXtList[index].Services_To);
}
i=index;*/
                    gen2.writeStringField('Range', serEXtList[i].Services_From + ':' + serEXtList[i + 1].Services_To);
                    i++;
                } else if (i + 1 <= serEXtList.size() - 1 && Integer.valueOf(serEXtList[i + 1].Services_FROM) - Integer.valueOf(serEXtList[i].Services_TO) == 1) {
                    gen2.writeStringField('Range', serEXtList[i].Services_From + ':' + serEXtList[i + 1].Services_To);
                    i++;
                } else if (i + 1 <= serEXtList.size() - 1 && (Integer.valueOf(serEXtList[i + 1].Services_TO) - Integer.valueOf(serEXtList[i].Services_FROM) < 2 || Integer.valueOf(serEXtList[i + 1].Services_TO) - Integer.valueOf(serEXtList[i].Services_FROM) > 2)) {
                    gen2.writeStringField('Range', serEXtList[i].Services_From + ':' + serEXtList[i].Services_To);
                    i++;
                } else {
                    gen2.writeStringField('Range', serEXtList[i].Services_From + ':' + serEXtList[i].Services_To);
                }
                //gen2.writeStringField('action',system.label.PrimaryFNNAction);
                gen2.writeEndObject();
                String s = gen2.getAsString();
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(s);
                String serializedresult = JSON.serialize(results);
                system.debug('@@' + serializedresult);
                sList1.add(serializedresult);
            }
        }
        system.debug(sList1);
        String serializedresult21 = System.JSON.serializePretty(sList1);
        system.debug('@@' + serializedresult21);
        String finalNumbers = serializedresult21.replace('\\"', '\'');
        system.debug('@@' + finalNumbers);
        gen.writeStringField('Numbers', finalNumbers);
        gen.writeEndObject();
        gen.writeEndObject();
        return gen;
    }
    //generate service specification ngUC EDGE-101066
    private static JSONGenerator createNGUCLegacyServiceSpec(CS_SpecificationDTO.serviceSpecification spec, csord__Service__c serv, JSONGenerator gen, String guid, List<TransitionDataDTO.serviceDTOMobile> service, String adborId, String transitionId) {
        spec.ServiceId = serv.Id;
        gen.writeStartObject();
        spec.code = System.Label.LegacyVoiceSpecCode;
        //spec.code='DMCAT_ProductSpecification_000343_Fulfilment';
        spec.version = '1';
        spec.status = System.Label.LegacySpecStatus;
        spec.startDate = String.valueOf(Date.today());
        spec.name = System.Label.LegacySpecName;
        spec.instanceId = guid;
        spec.guid = guid;
        gen.writeStringField('code', spec.code);
        gen.writeStringField('version', spec.version);
        gen.writeStringField('status', spec.status);
        gen.writeStringField('startDate', spec.startDate);
        gen.writeStringField('name', spec.name);
        gen.writeStringField('instanceId', spec.instanceId);
        gen.writeStringField('guid', spec.guid);
        List<CS_SpecificationDTO.SimpleAttributes> saList = new List<CS_SpecificationDTO.SimpleAttributes>();
        CS_SpecificationDTO.SimpleAttributes sa1 = new CS_SpecificationDTO.SimpleAttributes();
        sa1.name = System.Label.LegacyProductType;
        sa1.value = serv.Offer_Type__c;
        saList.add(sa1);
        /**CS_SpecificationDTO.SimpleAttributes sa2 = new CS_SpecificationDTO.SimpleAttributes();
sa2.name = System.Label.UCInstanceId;//'UCSiteProductInstanceID';
sa2.value = System.Label.UCSiteProductInstanceID_Value;//'DMCAT_ProductSpecification_000322_Fulfilment';
saList.add(sa2);**/
        CS_SpecificationDTO.SimpleAttributes sa3 = new CS_SpecificationDTO.SimpleAttributes();
        sa3.name = System.Label.LegacyTargetSystem;
        sa3.value = System.Label.LegacyTargetSystemValue; //'FULFILMENT';
        saList.add(sa3);
        /**CS_SpecificationDTO.SimpleAttributes sa4 = new CS_SpecificationDTO.SimpleAttributes();
sa4.name = System.label.BSServiceTypeProductInstanceID;
sa4.value = System.label.BSServiceTypeProductInstanceValue;//'DMCAT_ProductSpecification_000312_Fulfilment';
saList.add(sa4);**/

        //EDGE-149573 - Added to pass to O2A
        CS_SpecificationDTO.SimpleAttributes sa4 = new CS_SpecificationDTO.SimpleAttributes();
        sa4.name = System.label.NextGenerationVoiceProductInstanceID;
        sa4.value = System.label.NextGenerationVoiceProductInstanceValue; //'DMCAT_ProductSpecification_000871_Fulfilment';
        saList.add(sa4);

        CS_SpecificationDTO.SimpleAttributes sa5 = new CS_SpecificationDTO.SimpleAttributes();
        sa5.name = 'transitionId';
        sa5.value = transitionId;
        saList.add(sa5);
        CS_SpecificationDTO.SimpleAttributes sa6 = new CS_SpecificationDTO.SimpleAttributes();
        sa6.name = 'ADBOR ID';
        sa6.value = adborId;
        saList.add(sa6);
        spec.simpleAttributes = new List<CS_SpecificationDTO.simpleAttributes>();
        spec.simpleAttributes.addAll(saList);
        gen.writeFieldName('attributes');
        gen.writeStartObject();
        if (spec.simpleAttributes != null) {
            System.debug('spec.simpleAttributes :::' + spec.simpleAttributes);

            for (CS_SpecificationDTO.SimpleAttributes saa : spec.simpleAttributes) {
                if (String.isNotBlank(saa.value)) {
                    gen.writeStringField(saa.name, saa.value);
                }
            }
        }
        //****PrimaryFNN Json*****

        //gen.writeFieldName(System.Label.PrimaryFNN);
        //gen.writeStartArray();
        List<String> sList = new List<String>();
        for (TransitionDataDTO.serviceDTOMobile ser : service) {
            if ((ser.service_association_role == '' || ser.service_association_role == null || ser.service_association_role == PRIME_SERVICE_ASSOCIATION_ROLE)) {
                JSONGenerator gen2 = JSON.createGenerator(true);
                gen2.writeStartObject();

                if (String.isBlank(ser.Service_Id)) {
                    gen.writeNullField('Number');
                } else {
                    gen2.writeStringField('Number', ser.Service_Id);
                }
                gen2.writeStringField('action', system.label.PrimaryFNNAction);
                gen2.writeEndObject();
                String s = gen2.getAsString();
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(s);
                String serializedresult = JSON.serialize(results);
                system.debug('@@' + serializedresult);
                sList.add(serializedresult);
            }
        }
        system.debug(sList);
        String serializedresult2 = System.JSON.serializePretty(sList);
        system.debug('@@' + serializedresult2);
        gen.writeStringField(System.Label.PrimaryFNN, serializedresult2.replace('\\"', '\''));
        //NumberJson
        //gen.writeFieldName('Numbers');
        List<String> sList1 = new List<String>();
        for (TransitionDataDTO.serviceDTOMobile ser : service) {
            //if (ser.service_association_role == 'Auxiliary') {
            if (String.isBlank(ser.service_association_role) || ser.service_association_role == AUXILIARY_SERVICE_ASSOCIATION_ROLE || ser.service_association_role == PRIME_SERVICE_ASSOCIATION_ROLE || ser.service_association_role == GDN_SERVICE_ASSOCIATION_ROLE) {
                JSONGenerator gen2 = JSON.createGenerator(true);
                gen2.writeStartObject();
                if (String.isBlank(ser.Service_Id)) {
                    gen.writeNullField('Number');
                } else {
                    gen2.writeStringField('Number', ser.Service_Id);
                }
                gen2.writeStringField('action', system.label.PrimaryFNNAction);
                gen2.writeEndObject();
                String s = gen2.getAsString();
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(s);
                String serializedresult = JSON.serialize(results);
                system.debug('@@' + serializedresult);
                sList1.add(serializedresult);
            }
            List<ServiceExtentionComparableWrapper> serEXtList = new List<ServiceExtentionComparableWrapper>();
            //List<ReplicatorGetServiceDataObject_V2.ServiceExtensionDTO_V2> serEXtList=new List<ReplicatorGetServiceDataObject_V2.ServiceExtensionDTO_V2>();
            System.debug('ser.serviceExtensions ::' + ser.serviceExtensions + ser);

            if (ser.serviceExtensions != null) {
                for (TransitionDataDTO.serviceExtensionDTO serExt : ser.serviceExtensions) {
                    serEXtList.add(new ServiceExtentionComparableWrapper(serExt.serviceExtensionTo, serExt.serviceExtensionFrom));
                }
            }
            if (serEXtList != null && serEXtList.size() > 0) {
                serEXtList.sort();
                //serEXtList.addAll(serEXtList);
            }

            system.debug('serEXtList**' + serEXtList);

            for (integer i = 0; i < serEXtList.size(); i++) {
                JSONGenerator gen2 = JSON.createGenerator(true);
                gen2.writeStartObject();
                system.debug('@@i@@' + i);
                if (i + 1 <= serEXtList.size() - 1 && Integer.valueOf(serEXtList[i + 1].Services_FROM) - Integer.valueOf(serEXtList[i].Services_TO) == 2) {
                    gen2.writeStringField('Range', serEXtList[i].Services_From + ':' + serEXtList[i + 1].Services_To);
                    i++;
                } else if (i + 1 <= serEXtList.size() - 1 && Integer.valueOf(serEXtList[i + 1].Services_FROM) - Integer.valueOf(serEXtList[i].Services_TO) == 1) {
                    gen2.writeStringField('Range', serEXtList[i].Services_From + ':' + serEXtList[i + 1].Services_To);
                    i++;
                } else if (i + 1 <= serEXtList.size() - 1 && (Integer.valueOf(serEXtList[i + 1].Services_TO) - Integer.valueOf(serEXtList[i].Services_FROM) < 2 || Integer.valueOf(serEXtList[i + 1].Services_TO) - Integer.valueOf(serEXtList[i].Services_FROM) > 2)) {
                    gen2.writeStringField('Range', serEXtList[i].Services_From + ':' + serEXtList[i].Services_To);
                    i++;
                } else {
                    gen2.writeStringField('Range', serEXtList[i].Services_From + ':' + serEXtList[i].Services_To);
                }
                gen2.writeStringField('action', system.label.PrimaryFNNAction);
                gen2.writeEndObject();
                String s = gen2.getAsString();
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(s);
                String serializedresult = JSON.serialize(results);
                system.debug('@@' + serializedresult);
                sList1.add(serializedresult);
            }
        }
        system.debug(sList1);
        String serializedresult21 = System.JSON.serializePretty(sList1);
        system.debug('@@' + serializedresult21);
        String finalNumbers = serializedresult21.replace('\\"', '\'');
        system.debug('@@' + finalNumbers);
        gen.writeStringField('Numbers', finalNumbers);
        gen.writeEndObject();
        gen.writeEndObject();
        return gen;
    }

    //generate GUID
    private static string generateGuid() {
        //generate GUID
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0, 8) + '-' + h.SubString(8, 12) + '-' + h.SubString(12, 16) + '-' + h.SubString(16, 20) + '-' + h.substring(20);

        return guid;
    }

    //Used in Orchestration_ServiceSubscription
    /**
     * getOrchestrationTemplates description to get the Templates Ids for the Passed Template Names.
     *
     * ## templateNames (List<String>): templateNames description}
     * @@ Return Map<String,CSPOFA__Orchestration_Process_Template__c>: Return description
     */
    public static Map<String, CSPOFA__Orchestration_Process_Template__c> getOrchestrationTemplates(List<String> templateNames) {
        Map<String, CSPOFA__Orchestration_Process_Template__c> orchesTemplates = new Map<String, CSPOFA__Orchestration_Process_Template__c>();
        //CHANGED  From query all to only those required
        for (CSPOFA__Orchestration_Process_Template__c orctemp : [SELECT Id, Name FROM CSPOFA__Orchestration_Process_Template__c WHERE Name IN :templateNames]) {
            orchesTemplates.put(orctemp.Name, orctemp);
        }
        System.debug('orchesTemplates in cls' + orchesTemplates);
        return orchesTemplates;
    }

    public static String updateSpecStatus(String attbody, String property, String propertyValue) {
        String updattBody = attbody;
        String statusVal = propertyValue;
        String isChanged = 'false';
        List<CS_AttributeSpecsDTO.ServiceSpecification> specs = CS_AttributeSpecsDTO.parseSpec(attbody, 'Fulfilment');

        for (CS_AttributeSpecsDTO.ServiceSpecification spec : specs) {
            System.debug('spec.guid::' + spec.guid);
            System.debug('spec.status::' + spec.status);
            System.debug('propertyValue::' + propertyValue);
            if (property == 'status') {
                statusVal = getStatus(spec.status, propertyValue);
                System.debug('statusVal:::' + statusVal);

                System.debug('updattBody before update:::' + updattBody);

                if (spec.status != Label.MO_status_disconnect_in_progress && spec.status != Label.MO_status_cancel_in_progress && spec.status != Label.MO_status_in_progress && spec.status != Label.MO_Status_Complete && spec.status != Label.MO_status_cancel && spec.status != 'Disconnected') {
                    updattBody = csedm.API_1.updateServiceSpecificationProperty(updattBody, spec.guid, 'status', statusVal);
                    isChanged = 'true';
                }
                System.debug('updattBody after Update:::' + updattBody);
            }
        }
        if (isChanged == 'false') {
            return isChanged;
        }
        return updattBody;
    }

    //GM - 13 July'20 - Added for additional attribute update
    public static String addAdditionalAttribute(String body, Map<String, String> additionalAttrs, List<String> targetSystems, List<String> specCodes) {
        String isChanged = 'false';
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(body);
        if (results.containsKey('specifications')) {
            List<Object> lstSpecifications = (List<Object>) results.get('specifications');
            Map<String, Object> specificationAttributes = new Map<String, Object>();
            for (Object specification : lstSpecifications) {
                Boolean specChange = false;
                specificationAttributes = (Map<String, Object>) specification;
                Map<String, Object> tempAdditionalAttMap = new Map<String, Object>();
                String target;
                if (specificationAttributes.containsKey(OrchestratorConstants.ServiceSpecificationKey.Attributes)) {
                    Map<String, Object> attributesMap = (Map<String, Object>) specificationAttributes.get(OrchestratorConstants.ServiceSpecificationKey.Attributes);
                    target = String.valueOf(attributesMap.get(OrchestratorConstants.ServiceSpecificationKey.TargetSystem));
                }
                if (specificationAttributes.containsKey('additionalAttributes')) {
                    tempAdditionalAttMap = (Map<String, Object>) specificationAttributes.get('additionalAttributes');
                }
                String code = (String) specificationAttributes.get(OrchestratorConstants.ServiceSpecificationKey.Code);
                for (String specode : specCodes) {
                    if (!String.IsBlank(target) && code.contains(specode) && targetSystems.contains(target)) {
                        for (String attrName : additionalAttrs.keyset()) {
                            if (!tempAdditionalAttMap.containsKey(attrName) || (tempAdditionalAttMap.containsKey(attrName) && tempAdditionalAttMap.get(attrName) != additionalAttrs.get(attrName))) {
                                tempAdditionalAttMap.put(attrName, additionalAttrs.get(attrName));
                                specChange = true;
                            }
                        }

                        if (specChange) {
                        specificationAttributes.put('additionalAttributes', tempAdditionalAttMap);
                        isChanged = 'true';
                    }
                }
            }
        }
        }

        if (isChanged.equals('false')) {
            return isChanged;
        }

        return JSON.serializePretty(results);
    }

    public static Map<Id, Map<String, String>> getServiceTOCodeGUIDMap(Set<Id> servicesList, Map<Id, Blob> serviceAttachmentMap) {
        Map<Id, Map<String, String>> servTOCodeGUIDMap = new Map<Id, Map<String, String>>();
        for (Id servId : servicesList) {
            if (serviceAttachmentMap.containsKey(servId)) {
                Map<String, String> servCodetoGUIDMap = new Map<String, String>();
                List<CS_SpecificationDTO.ServiceSpecification> srvspecList = CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serviceAttachmentMap.get(servId).toString()), 'BILLING');
                for (CS_SpecificationDTO.ServiceSpecification spec : srvspecList) {
                    String code = 'DMCAT_' + spec.code.split('Billing_')[1];
                    servCodetoGUIDMap.put(code, spec.guid);
                    servTOCodeGUIDMap.put(spec.serviceId, servCodetoGUIDMap);
                }
            }
        }
        return servTOCodeGUIDMap;
    }

    //returns transition status following service spec status trainsitions
    public static String getStatus(String previousstatus, String updatestatus) {
        String targetStatus = updatestatus;
        if (targetStatus.contains('In Progress')) {
            if (previousstatus.contains(Label.MO_status_disconnect_pending))
                targetStatus = Label.MO_status_disconnect_in_progress;
            else if (previousstatus.contains(Label.MO_status_cancel_pending))
                targetStatus = Label.MO_status_cancel_in_progress;
            else
                targetStatus = Label.MO_status_in_progress;
        }

        return targetStatus;
    }
    
    // Upadte for simple attributes of specs  
    public static String addSimpleAttributes(String body, Map<String, String> AttrsMap, String targetSystems ) {
        String isChanged = 'false';
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(body);
        if (results.containsKey('specifications')) {
            List<Object> lstSpecifications = (List<Object>) results.get('specifications');
            Map<String, Object> specificationAttributes = new Map<String, Object>();
            for (Object specification : lstSpecifications) {
                Boolean specChange = false;
                specificationAttributes = (Map<String, Object>) specification;
                Map<String, Object> tempAttMap = new Map<String, Object>();
                String target;
                if (specificationAttributes.containsKey(OrchestratorConstants.ServiceSpecificationKey.Attributes)) {
                    Map<String, Object> attributesMap = (Map<String, Object>) specificationAttributes.get(OrchestratorConstants.ServiceSpecificationKey.Attributes);
                    target = String.valueOf(attributesMap.get(OrchestratorConstants.ServiceSpecificationKey.TargetSystem));
                }
                if (specificationAttributes.containsKey('attributes')) {
                    tempAttMap = (Map<String, Object>) specificationAttributes.get('attributes');
                }
              
                    if (!String.IsBlank(target) && targetSystems.equals(target)) {
                        for (String attrName : AttrsMap.keyset()) {
                            if ((tempAttMap.containsKey(attrName) )) {
                                tempAttMap.put(attrName, AttrsMap.get(attrName));
                                specChange = true;
                            }
                        }

                        if (specChange) {
                        specificationAttributes.put('attributes', tempAttMap);
                        isChanged = 'true';
                    }
                }
            
        }
        }

        if (isChanged.equals('false')) {
            return isChanged;
        }

        return JSON.serializePretty(results);
    }
    
    public static String updatespec(String body, String status,  List<String> targetSystems){
        system.debug('targetSystems:'+targetSystems);
        
         String isChanged = 'false';
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(body);
        Map<String, Object> updatedResults = new Map<String, Object> ();
        if (results.containsKey('specifications')) {
            List<Object> lstSpecifications = (List<Object>) results.get('specifications');
              Map<String, Object> specificationAttributes = new Map<String, Object>();
             
             for (Object specification : lstSpecifications) {
             Boolean specChange = false;
              specificationAttributes = (Map<String, Object>) specification;
              String target;
                if (specificationAttributes.containsKey(OrchestratorConstants.ServiceSpecificationKey.Attributes)) {
                    Map<String, Object> attributesMap = (Map<String, Object>) specificationAttributes.get(OrchestratorConstants.ServiceSpecificationKey.Attributes);
                    target = String.valueOf(attributesMap.get(OrchestratorConstants.ServiceSpecificationKey.TargetSystem));
                }
               
               
               if (!String.IsBlank(target) && targetSystems.contains(target)) {
                      Map<String, Object> updatespecificationAttributes = (Map<String, Object>) specification;
                    if (specificationAttributes.containsKey(OrchestratorConstants.ServiceSpecificationKey.Status)) {
                         specificationAttributes.put(OrchestratorConstants.ServiceSpecificationKey.Status, 'Complete');
                     specChange = true;
                      isChanged = 'true';
               }
               }
        }
        
        }    
              if (isChanged.equals('false')) { return isChanged;
        }

        return JSON.serializePretty(results);
        
    }
}