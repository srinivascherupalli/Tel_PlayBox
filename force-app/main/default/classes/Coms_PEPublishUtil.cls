/*************************************************************************************************************
 * @name            Coms_PEPublishUtil
 * @author          BLR\rohit.pal <rohit.pal@crmit.com>
 * @created         18 / 08 / 2021
 * @description     Description of your code
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 *              No.     Date            Author                  Description
 *              ----    ------------    --------------------    ----------------------------------------------
 * @version     1.0     2021-08-18      BLR\rohit.pal           Changes desription
 *
**************************************************************************************************************/
public with sharing class Coms_PEPublishUtil {


    /**
    * @description 
    * @author Rohit Pal | 08-19-2021 
    * @param mapServiceAttachments 
    **/
    public static void parseServiceAttachments(Map<id, Attachment> mapServiceAttachments , boolean isUpdatedFromBatch){
        List<CS_SpecificationDTO.ServiceSpecification> fulfilmentSrvspecList = new List<CS_SpecificationDTO.ServiceSpecification>();
        set<id> setServices = new set<id>();
        set<id> setOrders = new set<id>();
        List<csord__Service__c> listCSordService = new List<csord__Service__c>();
        Orchestration_Technical__c objOrchestrationTechnical;
        List<Technical_Child_Attribute__c> technicalChildAttributelist = new List<Technical_Child_Attribute__c>();
        List<Technical_Child_Attribute__c> insertTechnicalChildAttributelist = new List<Technical_Child_Attribute__c>();
        List<Orchestration_Technical__c> listOrchestrationAndTechnicalChildAttribute = new List<Orchestration_Technical__c>();
        Map<string, string> mdtTechnicalObjectFieldMappingMap = mdtTechnicalObjectFieldMapping();
        Map<string, List<Technical_Child_Attribute__c>> mapServiceAndTechnicalChildAttribute = new Map<string, List<Technical_Child_Attribute__c>>();
        Technical_Child_Attribute__c objTechnicalChildAttribute;
        Map<integer, string> mapChildAttributeFieldName =getChildAttributeMapping('Technical_Child_Attribute__c');
        System.debug('mapChildAttributeFieldName ---> ' + mapChildAttributeFieldName);
        //try{
            Map<id,string> serviceAttachmentMap = new Map<id,string>();
            for(Attachment iterator: mapServiceAttachments.values()){
                serviceAttachmentMap.put(iterator.parentId , iterator.body.toString());
                system.debug('serviceAttachmentMap++' +serviceAttachmentMap);
            }
            for(string eachService: serviceAttachmentMap.keySet()){
                fulfilmentSrvspecList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serviceAttachmentMap.get(eachService)),'FULFILMENT')) ;
                //fulfilmentSrvspecList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serviceAttachmentMap.get(eachService)))) ;
            
                System.debug('fulfilmentSrvspecList::' + fulfilmentSrvspecList);
                System.debug('fulfilmentSrvspecList:: Size () --> ' + fulfilmentSrvspecList.size());
            }
            //create a Orchestration Technical record
            // objOrchestrationTechnical will upsert all the time
            // insert this to platform cache also after change.
            for(CS_SpecificationDTO.ServiceSpecification iterator : fulfilmentSrvspecList){
                setServices.add(iterator?.serviceId);
                objOrchestrationTechnical = new Orchestration_Technical__c();
                objOrchestrationTechnical.put(string.valueof(mdtTechnicalObjectFieldMappingMap.get(Coms_PlatformConstants.STRING_IDENTIFIER)) , iterator.Identifier);
                objOrchestrationTechnical.put(string.valueof(mdtTechnicalObjectFieldMappingMap.get(Coms_PlatformConstants.STRING_GUID)) , iterator.guid);
                objOrchestrationTechnical.put(string.valueof(mdtTechnicalObjectFieldMappingMap.get(Coms_PlatformConstants.STRING_DESCRIPTION)) , iterator.description);
                objOrchestrationTechnical.put(string.valueof(mdtTechnicalObjectFieldMappingMap.get(Coms_PlatformConstants.STRING_CODE)) , iterator.code);
                objOrchestrationTechnical.put(string.valueof(mdtTechnicalObjectFieldMappingMap.get(Coms_PlatformConstants.STRING_VERSION)) , iterator.version);
                objOrchestrationTechnical.put(string.valueof(mdtTechnicalObjectFieldMappingMap.get(Coms_PlatformConstants.STRING_SUBSCRIPTIONID)) , iterator.SubscriptionId);
                objOrchestrationTechnical.put(string.valueof(mdtTechnicalObjectFieldMappingMap.get(Coms_PlatformConstants.STRING_STATUS)) , iterator.Status);
                objOrchestrationTechnical.put(string.valueof(mdtTechnicalObjectFieldMappingMap.get(Coms_PlatformConstants.STRING_STARTDATE)) , iterator.StartDate);
                objOrchestrationTechnical.put(string.valueof(mdtTechnicalObjectFieldMappingMap.get(Coms_PlatformConstants.STRING_REPLACEDSPECIFICATION)) , iterator.ReplacedSpecification);
                objOrchestrationTechnical.put(string.valueof(mdtTechnicalObjectFieldMappingMap.get(Coms_PlatformConstants.STRING_PRODUCTCONFIGURATIONID)) , iterator.productConfigurationId);
                objOrchestrationTechnical.put(string.valueof(mdtTechnicalObjectFieldMappingMap.get(Coms_PlatformConstants.STRING_NAME)) , iterator.name);
                objOrchestrationTechnical.put(string.valueof(mdtTechnicalObjectFieldMappingMap.get(Coms_PlatformConstants.STRING_INSTANCEID)) , iterator.InstanceId);
                objOrchestrationTechnical.Service__c =  iterator.serviceId;
                listOrchestrationAndTechnicalChildAttribute.add(objOrchestrationTechnical);
                system.debug('Coms_PEPublishUtil :: parseFuliment :: found listOrchestrationAndTechnicalChildAttribute --->' +listOrchestrationAndTechnicalChildAttribute);
                for(List<CS_SpecificationDTO.ComplexAttributes> complexChars :iterator.complexAttributes.values()){ 
                    //system.debug('Coms_PEPublishUtil :: parseFuliment :: found CS_SpecificationDTO.ServiceSpecification complexChars --->' +complexChars);
                    for(CS_SpecificationDTO.ComplexAttributes complexChar :complexChars){
                        
                        system.debug('Coms_PEPublishUtil :: parseFuliment :: found complexChar.simpleAttributes.size() --->' + complexChar.simpleAttributes.size());
                        for(CS_SpecificationDTO.SimpleAttributes objSimpleAttribute : complexChar.simpleAttributes){
                            if(!mapServiceAndTechnicalChildAttribute.containsKey(iterator.guid)){
                                objTechnicalChildAttribute = new Technical_Child_Attribute__c();
                                objTechnicalChildAttribute.Complex_Attribute_Schema_Id__c = objSimpleAttribute.name+'-'+complexChar.productConfigurationId;
                                objTechnicalChildAttribute.Category__c = Coms_PlatformConstants.STRING_COMPLEX_ATTRIBUTES;
                                objTechnicalChildAttribute.Field_6__c =  Coms_PlatformConstants.STRING_NUMBER;
                                // check this Number and make it dynamic
                                for (Integer i = 0; i <complexChar.simpleAttributes.size(); i++) {
                                    system.debug('Coms_PEPublishUtil :: parseFuliment :: found  i --->' +mapChildAttributeFieldName.get(i) + ' <---- > ' + complexChar.simpleAttributes[i].value);
                                    objTechnicalChildAttribute.put(mapChildAttributeFieldName.get(i) , complexChar.simpleAttributes[i].value);
                                }
                                mapServiceAndTechnicalChildAttribute.put(iterator.guid , new list<Technical_Child_Attribute__c>{objTechnicalChildAttribute});
                            }else if(mapServiceAndTechnicalChildAttribute.containsKey(iterator.guid)){
                                objTechnicalChildAttribute = new Technical_Child_Attribute__c();
                                objTechnicalChildAttribute.Complex_Attribute_Schema_Id__c = objSimpleAttribute.name+'-'+complexChar.productConfigurationId;
                                objTechnicalChildAttribute.Category__c = Coms_PlatformConstants.STRING_COMPLEX_ATTRIBUTES;
                                objTechnicalChildAttribute.Field_6__c =  Coms_PlatformConstants.STRING_NUMBER;
                                for (Integer i = 0; i <complexChar.simpleAttributes.size(); i++) {
                                    objTechnicalChildAttribute.put(mapChildAttributeFieldName.get(i) , complexChar.simpleAttributes[i].value);
                                }
                                list<Technical_Child_Attribute__c> listTechnicalChildAttribute = new list<Technical_Child_Attribute__c>(mapServiceAndTechnicalChildAttribute.get(iterator.guid));
                                listTechnicalChildAttribute.add(objTechnicalChildAttribute);
                                mapServiceAndTechnicalChildAttribute.put(iterator.guid , listTechnicalChildAttribute);
                            }
                            break;
                        }
                                system.debug('Coms_PEPublishUtil :: parseFuliment :: found mapServiceAndTechnicalChildAttribute --->' +mapServiceAndTechnicalChildAttribute);
                    }
                }
                for(CS_SpecificationDTO.SimpleAttributes objSimpleAttribute : iterator.simpleAttributes){
                    system.debug('Coms_PEPublishUtil :: parseFuliment :: found simpleAttributes iterator.objSimpleAttribute --->' + objSimpleAttribute.value);
                    if(mapServiceAndTechnicalChildAttribute.containsKey(iterator.guid)){
                        objTechnicalChildAttribute = new Technical_Child_Attribute__c();
                        objTechnicalChildAttribute.Complex_Attribute_Schema_Id__c = objSimpleAttribute.name;
                        objTechnicalChildAttribute.Category__c = Coms_PlatformConstants.STRING_SIMPLE_ATTRIBUTES;
                        objTechnicalChildAttribute.put('Field_1__c' , objSimpleAttribute.value);
                        list<Technical_Child_Attribute__c> listTechnicalChildAttribute = new list<Technical_Child_Attribute__c>(mapServiceAndTechnicalChildAttribute.get(iterator.guid));
                        listTechnicalChildAttribute.add(objTechnicalChildAttribute);
                        mapServiceAndTechnicalChildAttribute.put(iterator.guid , listTechnicalChildAttribute);
                    }else if(!mapServiceAndTechnicalChildAttribute.containsKey(iterator.guid)){
                        objTechnicalChildAttribute = new Technical_Child_Attribute__c();
                        objTechnicalChildAttribute.Complex_Attribute_Schema_Id__c = objSimpleAttribute.name;
                        objTechnicalChildAttribute.Category__c = Coms_PlatformConstants.STRING_SIMPLE_ATTRIBUTES;
                        objTechnicalChildAttribute.put('Field_1__c' , objSimpleAttribute.value);
                        mapServiceAndTechnicalChildAttribute.put(iterator.guid , new list<Technical_Child_Attribute__c>{objTechnicalChildAttribute});
                    }
                    //system.debug('Coms_PEPublishUtil :: parseFuliment :: found  mapServiceAndTechnicalChildAttribute --->' +mapServiceAndTechnicalChildAttribute);
                }
                //Additional
                for(CS_SpecificationDTO.SimpleAttributes objAdditionalAttribute : iterator.additionalAttributes){
                    if(objAdditionalAttribute.name !='' && objAdditionalAttribute.value != '')  {
                        if(mapServiceAndTechnicalChildAttribute.containsKey(iterator.guid)){
                            objTechnicalChildAttribute = new Technical_Child_Attribute__c();
                            objTechnicalChildAttribute.Complex_Attribute_Schema_Id__c = objAdditionalAttribute.name;
                            objTechnicalChildAttribute.Category__c = Coms_PlatformConstants.STRING_ADDITIONAL_ATTRIBUTES;
                            for (Integer i = 0; i < iterator.additionalAttributes.size(); i++) {
                                if(mapChildAttributeFieldName != null && mapChildAttributeFieldName.containsKey(i)){
                                    objTechnicalChildAttribute.put(mapChildAttributeFieldName.get(i) , objAdditionalAttribute.value);
                                }
                            }
                            list<Technical_Child_Attribute__c> listTechnicalChildAttribute = new list<Technical_Child_Attribute__c>(mapServiceAndTechnicalChildAttribute.get(iterator.guid));
                            listTechnicalChildAttribute.add(objTechnicalChildAttribute);
                            mapServiceAndTechnicalChildAttribute.put(iterator.guid , listTechnicalChildAttribute);
                        }else if(!mapServiceAndTechnicalChildAttribute.containsKey(iterator.guid)){
                                objTechnicalChildAttribute = new Technical_Child_Attribute__c();
                                objTechnicalChildAttribute.Complex_Attribute_Schema_Id__c = objAdditionalAttribute.name;
                                objTechnicalChildAttribute.Category__c = Coms_PlatformConstants.STRING_ADDITIONAL_ATTRIBUTES;
                                for (Integer i = 0; i < iterator.additionalAttributes.size(); i++) {
                                    if(mapChildAttributeFieldName != null && mapChildAttributeFieldName.containsKey(i)){
                                        objTechnicalChildAttribute.put(mapChildAttributeFieldName.get(i) , objAdditionalAttribute.value);
                                    }
                                }
                            mapServiceAndTechnicalChildAttribute.put(iterator.guid ,  new list<Technical_Child_Attribute__c>{objTechnicalChildAttribute});
                        }
                    }
                    //system.debug('Coms_PEPublishUtil :: parseFuliment :: found  mapServiceAndTechnicalChildAttribute --->' +mapServiceAndTechnicalChildAttribute);
                }
            }
            if(listOrchestrationAndTechnicalChildAttribute != null && !listOrchestrationAndTechnicalChildAttribute.isEmpty()){
                Map<string,Orchestration_Technical__c> mapOrchestrationTechnical = getOrchestrationTechnicals(setServices);
                for(Orchestration_Technical__c recOrchestration : listOrchestrationAndTechnicalChildAttribute){
                    if(mapOrchestrationTechnical != null && mapOrchestrationTechnical.containsKey(recOrchestration.Field_11__c)){
                        recOrchestration.id = mapOrchestrationTechnical?.get(recOrchestration.Field_11__c)?.id;
                    }
                }
                if(listOrchestrationAndTechnicalChildAttribute != null){
                    upsert listOrchestrationAndTechnicalChildAttribute;
                }
                // If it existing update else insert
                //update service from here if technical object created sucessfully 
                listCSordService = getcsordService(setServices);
                // it should only be checked if it is called from batch
                if(!isUpdatedFromBatch){
                    for(csord__Service__c iterator : listCSordService){
                        if(!iterator.Is_Converted_To_Technical_Object__c){
                            iterator.Is_Converted_To_Technical_Object__c = true;
                        }
                    }
                    update listCSordService;
                }
                Map<string , Technical_Child_Attribute__c> mapTechnicalChildAttribute = getTechnicalChildAttribute(listOrchestrationAndTechnicalChildAttribute);
                // remove this and add 
                //Changed the Technical Child Attribute Auto number field to Name and put the unique values for upsert
                system.debug('Coms_PEPublishUtil :: parseFuliment :: found mapTechnicalChildAttribute --->' +mapTechnicalChildAttribute.size());
                for(Orchestration_Technical__c recOrchestration : listOrchestrationAndTechnicalChildAttribute){
                    technicalChildAttributelist = mapServiceAndTechnicalChildAttribute.get(recOrchestration.Field_11__c);
                    if(technicalChildAttributelist != null && !technicalChildAttributelist.isEmpty()){
                        for(Technical_Child_Attribute__c recTechnicalAttribute : technicalChildAttributelist){
                            if(mapTechnicalChildAttribute.containsKey(recTechnicalAttribute.Field_1__c) ){
                                recTechnicalAttribute.id = mapTechnicalChildAttribute.get(recTechnicalAttribute.Field_1__c).id;
                                //System.debug(' if recOrchestration.id ---> ' + recTechnicalAttribute);
                            }else if(!mapTechnicalChildAttribute.containsKey(recTechnicalAttribute.Field_1__c)){
                                recTechnicalAttribute.Orchestration_Technical__c = recOrchestration.id;
                                //System.debug('else if recOrchestration.id ---> ' + recTechnicalAttribute);
                            }
                            System.debug('technicalChildAttributelist ---> '+recTechnicalAttribute+' Orchestration_Technical__c --- > '+recTechnicalAttribute.Orchestration_Technical__c +' Field_1__c-- > '+ recTechnicalAttribute.Field_1__c);
                            insertTechnicalChildAttributelist.add(recTechnicalAttribute);
                        }
                    }
                }
                system.debug('Coms_PEPublishUtil :: parseFuliment :: found insertTechnicalChildAttributelist --->' +insertTechnicalChildAttributelist);
                upsert insertTechnicalChildAttributelist;
                if(!setServices.isEmpty()){
                    system.debug('Coms_PEPublishUtil :: parseFuliment :: found setServices --->' +setServices);
                    getcsordService(setServices);
                    //Coms_PlatformCacheUtil.insertServicesAndOrchestrationTechnicalToCache(new  Map<id,csord__Service__c>(getcsordService(setServices)));
                }
            }
        //}catch (Exception e){
            //System.debug(' Exception in getAllServSpecs:' + e.getMessage());
        //}
    }
    /**
    * @description 
    * @author Rohit Pal | 08-21-2021 
    * @return Map<string, TechnicalObjectFieldMapping__mdt> 
    **/
    public static Map<string , string> mdtTechnicalObjectFieldMapping(){
        Map<string, string> mapTechnicalObjectlabelField = new Map<string, string>();
        Map<string , TechnicalObjectFieldMapping__mdt> mapTechnicalObjectFieldMapping = mdtGetTechnicalObjectFieldMapping();
        for(TechnicalObjectFieldMapping__mdt iterator : mapTechnicalObjectFieldMapping.values()){
            mapTechnicalObjectlabelField.put(iterator.MasterLabel,iterator.Object_Field_Name__c); 
        }
        System.debug('mdtTechnicalObjectFieldMapping :: mapTechnicalObjectlabelField ---> ' + mapTechnicalObjectlabelField);
        return mapTechnicalObjectlabelField;
    }

    /**
    * @description 
    * @author Rohit Pal | 08-30-2021 
    * @return Map<string, TechnicalObjectFieldMapping__mdt> 
    **/
    public static Map<string , TechnicalObjectFieldMapping__mdt> mdtGetTechnicalObjectFieldMapping(){
        Map<string , TechnicalObjectFieldMapping__mdt> mapTechnicalObjectFieldMapping = new Map<string , TechnicalObjectFieldMapping__mdt>();
        for(TechnicalObjectFieldMapping__mdt iterator : [SELECT MasterLabel,Object_Field_Name__c,Object_Name__c,Category__c FROM TechnicalObjectFieldMapping__mdt WHERE Process__c ='Order']){
            mapTechnicalObjectFieldMapping.put(iterator.MasterLabel , iterator);
        }
        return mapTechnicalObjectFieldMapping;
    }
    /**
    * @description : get Technical object Correlation id.
    * @author Rohit Pal | 08-21-2021
    * @param setServices 
    * @return Map<Id, Orchestration_Technical__c> 
    **/
    public static Map<String,Orchestration_Technical__c> getOrchestrationTechnicals(set<Id> setServices){
        Map<String,Orchestration_Technical__c> mapOrchestrationTechnical = new Map<String,Orchestration_Technical__c>();
        for(Orchestration_Technical__c iterator : [SELECT Id,
                                                            CorrelationId__c,
                                                            Field_11__c,
                                                            Service__c
                                                    FROM Orchestration_Technical__c 
                                                    WHERE Service__c IN : setServices]){
            //
            if(iterator.Field_11__c != null){
                mapOrchestrationTechnical.put(iterator.Field_11__c , iterator);
            }
        }
        return mapOrchestrationTechnical;
    }

    /**
    * @description 
    * @author Rohit Pal | 08-23-2021 
    * @return List<Technical_Child_Attribute__c> 
    **/
    public static Map<string , Technical_Child_Attribute__c> getTechnicalChildAttribute(List<Orchestration_Technical__c> listOrchestrationTechnical){
        Map<string, Technical_Child_Attribute__c> mapTechnicalChildAttribute = new Map<string, Technical_Child_Attribute__c>();
        for(Technical_Child_Attribute__c iterator : [SELECT Id,Name,Complex_Attribute_Schema_Id__c,Orchestration_Technical__r.Field_11__c,Field_1__c FROM Technical_Child_Attribute__c WHERE Orchestration_Technical__c IN : listOrchestrationTechnical]){
            mapTechnicalChildAttribute.put(iterator.Field_1__c , iterator);
        }
        return mapTechnicalChildAttribute;
    }

    /**
    * @description 
    * @author Rohit Pal | 08-25-2021 
    * @param setServices 
    * @return List<csord__Service__c> 
    **/
    public static List<csord__Order__c> generateCorrelationId(set<id> setServices){
        List<csord__Order__c> listcsordOrder = [SELECT Id,
                                                        CorrelationId__c 
                                                FROM csord__Order__c 
                                                WHERE Id IN (SELECT csord__Order__c FROM csord__Service__c WHERE Id IN : setServices)];
        return listcsordOrder;
    }

    /**
    * @description 
    * @author Rohit Pal | 08-26-2021 
    * @param setServices 
    * @return List<csord__Service__c> 
    **/
    public static List<csord__Service__c> getcsordService(set<id> setServices){
        List<csord__Service__c> listcsordService = [SELECT Id,Is_Converted_To_Technical_Object__c,csord__Order__c FROM csord__Service__c WHERE Id IN : setServices];
        return listcsordService;
    }

    /**
    * @description 
    * @author Rohit Pal | 08-29-2021 
    * @param type 
    * @return Map<integer, string> 
    **/
    public static Map<integer , string> getChildAttributeMapping(string type){
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        Map<integer , string> mapChildAttributsMapping = new Map<integer , string>();
        set<string> setCustomFields = new set<string>();
        integer i=0;
        for (String fieldName: fieldMap.keySet()) {
            // list of all field API name
            if(fieldMap.get(fieldName).getDescribe().getLabel().contains('Field')){
                System.debug('##Field API Name='+fieldName);
                //setCustomFields.add(fieldMap.get(fieldName).getDescribe().getName());
                mapChildAttributsMapping.put(i , fieldMap.get(fieldName).getDescribe().getName());
                i++;
            }
        }
        system.debug('mapChildAttributsMapping ----> ' + mapChildAttributsMapping);
        return mapChildAttributsMapping;
    }
}