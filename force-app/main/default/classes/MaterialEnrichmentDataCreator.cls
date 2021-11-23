/*
* @Author : Suyash Chiplunkar
* @Desc : Create Material Attachments on Product Configurations
*/
/****History of Updates 
 * 1. Suyash Chiplunkar DPG-4560 - Material Attachments not getting created when basket have multiple sites
****/

global with sharing class MaterialEnrichmentDataCreator implements cssmgnt.RemoteActionDataProvider {
    global static Map<Id, Id> m_config2cp = new Map<Id, Id>();
    global static Map<Id, List<cspmb__Material__c>> m_commercialProduct2MaterialsList = new Map<Id, List<cspmb__Material__c>>();
    global static Map<Id, Map<Id, List<cspmb__Material__c>>> m_commercialProduct2MaterialsBySchemaMap = new Map<Id, Map<Id, List<cspmb__Material__c>>>();
    global static Map<Id, csoe__Non_Commercial_Schema__c> m_NonCommercialSchemas;
    global static Map<Id, List<Id>> m_CP2materialGroupIDs = new Map<Id, List<Id>>();
    global static Map<Id, List<Id>> m_MGIDs2Materials = new Map<Id, List<Id>>();
    global static Map<Id, List<Id>> m_CPIDs2Materials = new Map<Id, List<Id>>();

    @remoteAction
    global static Map<String, Object> getData(Map<String, Object> inputMap) {
        Map<String, Object> returnMap = new Map<String, Object>();
        StoreInputData(inputMap);
//      Map<String, List<cspmb__Material__c>> pc2MaterialsMap = new Map<String, List<cspmb__Material__c>>();
        CreateNonCommercialSchema();
        String s = '';
        returnMap.put('createOE', s);
        return returnMap;
    }

    global static void StoreInputData(Map<String, Object> inputMap) {
        Object CPM = inputMap.get('CommercialProductMap');
        System.debug(CPM);
        Map<String, Object> CommercialProductMap = (Map<String, Object>)JSON.deserializeUntyped((String)CPM);
        for (String configId : CommercialProductMap.keyset()) {
            System.debug('configId'+configId);
            String CPID = (String)CommercialProductMap.get(configId);
            m_config2cp.put((Id)configId, (Id)CPID);
        }
        System.debug('m_config2cp'+m_config2cp);
        BuildCP2Materials();
    }

    global static List<Id> GetMaterialGroupIds(List<Id> CPIDs) {
        List<Id> MGIDs = new List<Id>();
        for (cspmb__Commercial_Product_Material_Group_Assoc__c cpmga : [
                SELECT cspmb__commercial_product__c, cspmb__material_group__c 
                FROM cspmb__Commercial_Product_Material_Group_Assoc__c 
                WHERE cspmb__commercial_product__c in :CPIDs
        ]) {
            Id CPID = cpmga.cspmb__commercial_product__c;
            Id MGID = cpmga.cspmb__material_group__c;
            if (!m_CP2materialGroupIDs.containsKey(CPID)) { m_CP2materialGroupIDs.put(CPID, new List<Id>()); }
            m_CP2materialGroupIDs.get(CPID).add(MGID);
            MGIDs.add(MGID);
        }
        return MGIDs;
    }

    global static List<Id> GetMaterialsForGroups(List<Id> MGIDs) {
        List<Id> materialIds = new List<Id>();
        for (
                cspmb__Material_Group_Material_Association__c mgma : [
                SELECT cspmb__material__c, cspmb__material_group__c 
                FROM cspmb__Material_Group_Material_Association__c 
                WHERE cspmb__material_group__c in :MGIDs 
                ]
            ) {
            Id mgId = mgma.cspmb__material_group__c;
            Id materialId = mgma.cspmb__material__c;
            if (!m_MGIDs2Materials.containsKey(mgId)) { m_MGIDs2Materials.put(mgId, new List<Id>()); }
            m_MGIDs2Materials.get(mgId).add(materialId);
            materialIds.add(materialId);
            }
        return materialIds;
    }

    global static void MergeMaterialsCatalogue() {
        for (Id CPID : m_CP2materialGroupIDs.keySet()) {
            for (Id MGID : m_CP2materialGroupIDs.get(CPID)) {
                for (Id materialId : m_MGIDs2Materials.get(MGID)) {
                    if (!m_CPIDs2Materials.containsKey(CPID)) {
                        m_CPIDs2Materials.put(CPID, new List<Id>() );
                    }
                    m_CPIDs2Materials.get(CPID).add(materialId);
                }
            }
        }
    }

    global static List<Id> RemapByNCSchema (Map<Id, cspmb__Material__c> materialData) {
        List<Id> ncSchemaIds = new List<Id>();
        for (Id CPID : m_CPIDs2Materials.keySet()) {
            Map<Id, List<cspmb__Material__c>> ncSchema2Materials = new Map<Id, List<cspmb__Material__c>>();
            List<cspmb__Material__c> materialsList = new List<cspmb__Material__c>();
            for (Id materialId : m_CPIDs2Materials.get(CPID)) {
                cspmb__Material__c material = materialData.get(materialId);
                materialsList.add(material);
                Id ncSchemaId = material.Non_Commercial_Schema__c;
                ncSchemaIds.add(ncSchemaId);
                if (!ncSchema2Materials.containsKey(ncSchemaId)) { ncSchema2Materials.put(ncSchemaId, new List<cspmb__Material__c>()); }
                ncSchema2Materials.get(ncSchemaId).add(material);
            }
            m_commercialProduct2MaterialsList.put(CPID, materialsList);
            m_commercialProduct2MaterialsBySchemaMap.put(CPID, ncSchema2Materials);
            // Map CommercialProductId -> {Map NonCommercialSchemaId -> [List of Material records]
        }
        
        return ncSchemaIds;
    }

    global static Map<Id, csoe__Non_Commercial_Schema__c> GetNCSchemaData(List<Id> ncSchemaIds) { return new Map<Id, csoe__Non_Commercial_Schema__c>(
                [
                SELECT id, name, csoe__Schema__c, csoe__Description__c
                FROM csoe__Non_Commercial_Schema__c
                WHERE Id in :ncSchemaIds
                ]
                );
    }

    global static void BuildCP2Materials() {
        //Initialise data storage
        List<Id> CPIDs = (List<Id>)m_config2cp.values();
        List<Id> MGIDs = GetMaterialGroupIds(CPIDs);
        List<Id> materialIds = GetMaterialsForGroups(MGIDs);
        MergeMaterialsCatalogue();
        Map<Id, cspmb__Material__c> materialData = getAllMaterialData(materialIds);
        List<Id> ncSchemaIds = RemapByNCSchema(materialData);
        m_NonCommercialSchemas = GetNCSchemaData(ncSchemaIds);
        System.debug('m_NonCommercialSchemas'+m_NonCommercialSchemas);
    }
    global static void CreateNonCommercialSchema() {

        Map<Id, List<Object>> oeData = new Map<Id, List<Object>>();
        Map<Id, List<Object>> oeDataToBeInserted = new Map<Id, List<Object>>();
        Map<Id, List<Object>> oeDataToBeUpdated = new Map<Id, List<Object>>();
        for (Id prodConfigId : m_config2cp.keySet()) {
            List<Object> nceList = new List<Object>(); //list of non commercial entities for this configuration
            Id commercialProductId = m_config2cp.get(prodConfigId);
            Map<Id, List<cspmb__Material__c>> ncSchemaToMaterialMap = m_commercialProduct2MaterialsBySchemaMap.get(commercialProductId);
            for (Id ncSchemaId : ncSchemaToMaterialMap.keySet()) { // for each (Device, License, Maintenance)
                List<cspmb__Material__c> materials = ncSchemaToMaterialMap.get(ncSchemaId); // get list of materials for e.g. Device & Velocloud S bundle ==> [Velocloud 510 LTE Device]
                nceList.add(BuildNCE(ncSchemaId, materials));
            }
            oeData.put(prodConfigId, nceList);
        }
        System.Debug('oeData' + oeData.size());
        Map<String,Map<String,String>> mapPcIdSchemaNameGUID = GetMapSchemaNameGUID(oeData.keySet());
        CheckIfMaterialAttachmentsExists(oeData, mapPcIdSchemaNameGUID);
        //DPG-4560
        for(String PCID : oeData.keySet()){
            if(mapPcIdSchemaNameGUID.containskey(PCID)){
                oeDataToBeUpdated.put(PCID, oeData.get(PCID));
            }else{
                oeDataToBeInserted.put(PCID, oeData.get(PCID));
            }
        }
        System.Debug('oeDataToBeInserted' + oeDataToBeInserted);
        System.Debug('oeDataToBeUpdated' + oeDataToBeUpdated.size());
        //DPG-4560
        if(oeDataToBeInserted != NULL && !oeDataToBeInserted.isEmpty()){
            csoe.API_1.createOEConfigurations(oeDataToBeInserted);
        }
        if(oeDataToBeUpdated != NULL && !oeDataToBeUpdated.isEmpty()){
            csoe.API_1.updateOEConfigurations(oeDataToBeUpdated);
        }
    }
    
    global static void CheckIfMaterialAttachmentsExists(Map<Id, List<Object>> oeData, Map<String,Map<String,String>> mapPcIdSchemaNameGUID) {
        for(Id PCID : oeData.keySet()){
            //DPG-4560
            if(mapPcIdSchemaNameGUID.containsKey(PCID)){
                //DPG-4560
                Map<String,String> mapSchemaNameGUID = mapPcIdSchemaNameGUID.get(PCID);
                List<Object> schemaConfigurations= oeData.get(PCID);
                for(Object row : schemaConfigurations){
                    Map<String, Object> record = (Map<String, Object>)row;
                    List<Object> configurations = (List<Object>)record.get('configurations');
                    for(Object data : configurations){
                        Map<String, String> schemaDataMap = (Map<String, String>)data;
                        if(!schemaDataMap.containsKey('guid')){
                            if(record.containsKey('name') && mapSchemaNameGUID.get((String)record.get('name'))!=NULL ){
                                schemaDataMap.put('guid',mapSchemaNameGUID.get((String)record.get('name')));
                            }
                        }
                    }  
                }
            }
        }
    }
    
    global static Map<String,Map<String,String>> GetMapSchemaNameGUID(Set<Id> PCSet) {
        Map<String,String> mapGuidSchemaName = new Map<String,String>();
        //DPG-4560
        Map<String,Map<String,String>> mapPCGuidSchemaName = new Map<String,Map<String,String>>();
        Map<Id, List<csoe.SchemaWrapper>> mapPCOE = new Map<Id, List<csoe.SchemaWrapper>>();
        mapPCOE = csoe.API_1.getOEData(new List<Id>(PCSet), False);
        for (String pcId : mapPCOE.keySet()) {
            mapGuidSchemaName = new Map<String,String>();
            List<csoe.SchemaWrapper> row =  mapPCOE.get(pcId);
            for(csoe.SchemaWrapper record : row){
               Map<String,List<csoe.SchemaWrapper.SimpleAttribute>> mapGuidSimpleAttr = new Map<String,List<csoe.SchemaWrapper.SimpleAttribute>>();
               mapGuidSimpleAttr = record.configurationsGuid;
               for(String guid : mapGuidSimpleAttr.keySet()){
                   if(guid != null){
                       mapGuidSchemaName.put(record.schemaName, guid);
                   }
               }
            }
            //DPG-4560
            mapPCGuidSchemaName.put(pcId, mapGuidSchemaName);
        }
        System.debug('mapPCGuidSchemaName'+mapPCGuidSchemaName);
        System.debug('mapGuidSchemaName'+mapGuidSchemaName);
        return mapPCGuidSchemaName;
    }

    global static Map<String, Object> BuildNCE(Id ncSchemaId, List<cspmb__Material__c> materials) { //e.g. create NCE for device and list [Velocloud 510 LTE Device] 
        Map<String, Object> nce = new Map<String, Object>(); //Non Commercial Entity for this NCSchema on a specific product configuration
        csoe__Non_Commercial_Schema__c ncSchema = m_NonCommercialSchemas.get(ncSchemaId);
        nce.put('id', ncSchemaId);
        system.debug('ncSchemaId'+ncSchemaId);
        nce.put('name', ncSchema.Name);
        Map<String, Object> schema = (Map<String, Object>)JSON.deserializeUntyped( ncSchema.csoe__Schema__c);
        List<Object> attributeList = (List<Object>)schema.get('attributes'); //{e.g. [{name: Model, ...}, {name: Vendor, ...}] (read from Device Schema)
        List<Object> configList = new List<Object>();
        for (cspmb__Material__c material : materials) {
            configList.add(BuildConfigFromMaterial(material, attributeList));
        }
        nce.put('configurations', configList); //e.g. [{Model: 510LTE, Vendor: Velocloud, etc.}]
        System.Debug('configurations' + configList);
        return nce;
    }

    global static Object BuildConfigFromMaterial(cspmb__Material__c material, List<Object> attributeList) {
        Map<String, String> config = new Map<String, String>();
        for (Object attr0 : attributeList) {
            Map<String, Object> attributeData = (Map<String, Object>)attr0;
            String attributeName = (String)attributeData.get('name');
            String fieldName = ConvertToSalesforceName(attributeName);
            System.debug('fieldName'+fieldName);
            String value = (String)material.get(fieldName);
            config.put(attributeName, value);
        }
        System.Debug('config' + config);
        return (Object)config;
    }

    global static List<String> getMaterialFieldNames() {
        Map<String, Schema.SObjectField> fieldMap = cspmb__Material__c.sObjectType.getDescribe().fields.getMap();
        Set<String> fieldNames = fieldMap.keySet();
        List<String> fieldNamesList = new List<String>();
        fieldNamesList.addAll(fieldNames);
        return fieldNamesList;
    }

    global static Map<Id, cspmb__Material__c> getAllMaterialData(List<Id> materialIds) {
        List<String> fieldNamesList = getMaterialFieldNames();
        
        Map<Id, cspmb__Material__c> materials = new Map<Id, cspmb__Material__c>((List<cspmb__Material__c>)Database.query('select ' + String.join(fieldNamesList, ',') + 
                                                                                                                         ' FROM cspmb__Material__c ' + 
                                                                                                                         'WHERE Id in :materialIds'));
        System.debug('Material Keys'+materials.keySet());
        return materials;
    }

    global static String ConvertToSalesforceName(String attributeName) {
        if (attributeName == 'Name') {
            return 'Name';
        }
        return (String)attributeName.replace(' ', '_') + '__c';
    }
}