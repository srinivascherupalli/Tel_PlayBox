public with sharing class EDMConversionUtil {

public static List<CS_SpecificationDTO.ServiceSpecification> ConvertServiceEDMToSpecDTO(String edmString, String targetSystem){
   // system.debug('entering ConvertServiceEDMToSpec AAAAAAA '+limits.getCPUTime());
    
    Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(edmString);
    //system.debug('before first debug AAAAAAA '+limits.getCPUTime());
    //system.debug('results'+results);
    //system.debug('printing first debug AAAAAAA '+limits.getCPUTime());
    String serviceId = (String)results.get('serviceId');
    List<Object> lstSpecifications = (List<Object>)results.get('specifications');
    system.debug('getting lstSpecifications AAAAAAA '+limits.getCPUTime());
    //for each specification get its properties, simple attribute, complex attributes and additional attributes
    List<CS_SpecificationDTO.ServiceSpecification> returnSpecList = new List<CS_SpecificationDTO.ServiceSpecification>();
    //system.debug('before for Loop AAAAAAA '+limits.getCPUTime());
    if(lstSpecifications != null){
        for (Object specification : lstSpecifications) {
          //fetch all properties
            String specTargetSystem = '';
            CS_SpecificationDTO.ServiceSpecification spec = new CS_SpecificationDTO.ServiceSpecification();
            
            Map<String, Object> specificationAttributes = (Map<String, Object>)specification;
            
            //Map<String, Object> properties = fetchProperties(specificationAttributes);
          
            //properties.put('serviceId', serviceId);

            spec.serviceId = serviceId;
            spec.version = (String) specificationAttributes.get('version');
            spec.status = (String) specificationAttributes.get('status');
            spec.startDate = (String) specificationAttributes.get('startDate');
            spec.replacedSpecification = (String) specificationAttributes.get('replacedSpecification');
            spec.productConfigurationId = (String) specificationAttributes.get('productConfigurationId');
            spec.name = (String) specificationAttributes.get('name');
            spec.instanceId = (String) specificationAttributes.get('instanceId');
            spec.identifier = (String) specificationAttributes.get('identifier');
            spec.guid = (String) specificationAttributes.get('guid');
            spec.endDate = (String) specificationAttributes.get('endDate');
            spec.description = (String) specificationAttributes.get('description');
            spec.code = (String) specificationAttributes.get('code');
            spec.subscriptionId = (String) specificationAttributes.get('subscriptionId');
            //spec.billingDetails = (String) specificationAttributes.get('billingDetails')

          //fetch simple, complex and additional attributes

            List<CS_SpecificationDTO.SimpleAttributes> simpleAttList = new List<CS_SpecificationDTO.SimpleAttributes>();
            List<CS_SpecificationDTO.SimpleAttributes> additionalAttList = new List<CS_SpecificationDTO.SimpleAttributes>();
            Map<String, List<CS_SpecificationDTO.ComplexAttributes>> complexAttMap = new Map<String, List<CS_SpecificationDTO.ComplexAttributes>>();
            // Map<string, Object> simpleAttr = new Map<String, Object>();
            // Map<string, Object> compleAttr = new Map<String, Object>();
            // Map<string, Object> addnAttr = new Map<String, Object>();
            //get simple and complex attributes
            Map<String, Object> attrs = (Map<String, Object>)specificationAttributes.get('attributes');
            system.debug('before inside for Loop AAAAAAA '+limits.getCPUTime());
            for(String key: attrs.keySet()){
                Object attValue = attrs.get(key);
                if(attValue instanceof String ||  attValue instanceof Integer ||
                   attValue instanceof Double ||
                   attValue instanceof Decimal ||
                   attValue instanceof Boolean ||
                   attValue instanceof Id  ||
                   attValue instanceof Long  ||
                   attValue instanceof Date  ||
                   attValue instanceof Datetime   ){
                    CS_SpecificationDTO.SimpleAttributes simpleAttr = new CS_SpecificationDTO.SimpleAttributes();
                    simpleAttr.name = key;
                    simpleAttr.value = attValue!=null?string.valueOf(attValue):null;
                    simpleAttList.add(simpleAttr);
                    if(key!= null && key.contains('__targetSystem')){
                        specTargetSystem = attValue!=null?string.valueOf(attValue):null;
                    }
                } 
                else if ( attValue == null || attValue == ''){

                }
                else{
                    //compleAttr.put(key, attValue);
                    system.debug('complexAtts'+Json.serialize(attrs.get(key)));
                    List<CS_SpecificationDTO.ComplexAttributes> complexattList = new List<CS_SpecificationDTO.ComplexAttributes>();
                    
                    
                    //CS_SpecificationDTO.SimpleAttributes tempSimpleAtt = new CS_SpecificationDTO.SimpleAttributes();
                    //Map<String, Object> complexAtts = (Map<String, Object>) attrs.get(key);
                    if(attrs.get(key) != null){
                        List<Object> complAttObjList = (List<Object>)attrs.get(key);
                        for(Object complAttObj: complAttObjList){
                            CS_SpecificationDTO.ComplexAttributes complexAtt =  new CS_SpecificationDTO.ComplexAttributes();
                            List<CS_SpecificationDTO.SimpleAttributes> tempSimpleAttList = new List<CS_SpecificationDTO.SimpleAttributes>();
                            system.debug('complAttObj   '+complAttObj);
                            Map<String, Object> complAttObjAttr = (Map<String, Object>)complAttObj;
                            Map<String, Object> tempAttrs = (Map<String, Object>) complAttObjAttr.get('attributes');
                            system.debug('tempAttrs   '+tempAttrs);
                            for(String tempKey: tempAttrs.keySet()){
                                Object tempattValue = tempAttrs.get(tempKey);
                                //if(tempattValue){
                                    CS_SpecificationDTO.SimpleAttributes tempSimpleAtt = new CS_SpecificationDTO.SimpleAttributes();
                                    tempSimpleAtt.name = tempKey;
                                    tempSimpleAtt.value = tempattValue!=null?string.valueOf(tempattValue):null;
                                    tempSimpleAttList.add(tempSimpleAtt);
                                    
                                //} 
                            }
                            complexAtt.simpleAttributes = tempSimpleAttList;
                            complexAtt.productConfigurationId = null;
                            complexattList.add(complexAtt);
                            //CS_SpecificationDTO.SimpleAttributes tempSimpleAtt = new CS_SpecificationDTO.SimpleAttributes();
                        }
                    }

                    complexAttMap.put(key, complexattList);
                } 
            }
            system.debug('after inside for Loop AAAAAAA '+limits.getCPUTime());
            //System.debug(simpleAttr);
            //System.debug(compleAttr);

            //get additional attributes
            Map<String, Object> addnAttrs = (Map<String, Object>)specificationAttributes.get('additionalAttributes');
            if(addnAttrs!=null){
                for(String key: addnAttrs.keySet()){
                    Object attValue = addnAttrs.get(key);
                    if(attValue!=null ){
                        CS_SpecificationDTO.SimpleAttributes addnAttr = new CS_SpecificationDTO.SimpleAttributes();
                        addnAttr.name = key;
                        addnAttr.value = attValue!=null?string.valueOf(attValue):null;
                        additionalAttList.add(addnAttr);
                    } 
                    else if ( attValue == null || attValue == ''){
    
                    }
                }
            
            }
            

            //System.debug(addnAttr);

            // Map<String, Object> returnSpec = new Map<String, Object>();
            // returnSpec.putAll(properties);
            // if(simpleAttr != null && simpleAttr.size() > 0) returnSpec.put('simpleAttributes', convertToNameValuePairs(simpleAttr));
            //     if(addnAttr != null && addnAttr.size() > 0) returnSpec.put('additionalAttributes', convertToNameValuePairs(addnAttr));
            //     if(compleAttr !=null && compleAttr.size() > 0) returnSpec.put('complexAttributes', convertComplexAttr(compleAttr));
            
            if(simpleAttList != null && simpleAttList.size() > 0) spec.simpleAttributes = simpleAttList;
            if(complexAttMap != null && !complexAttMap.isEmpty() && complexAttMap.keyset()!= null ){ 
                system.debug('system====>>>'+complexAttMap.keyset());
                spec.complexAttributes = complexAttMap;
            }
            if(additionalAttList != null && additionalAttList.size() > 0) spec.additionalAttributes = additionalAttList;
            if(targetSystem == '' || targetSystem == null || targetSystem == specTargetSystem){
                returnSpecList.add(spec);
            }
            
        }

    }
    
    system.debug('after for Loop AAAAAAA '+limits.getCPUTime());
    return returnSpecList;
  }


  public static String ConvertServiceEDMToSpec(String edmString){
    system.debug('entering ConvertServiceEDMToSpec AAAAAAA '+limits.getCPUTime());
    
    Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(edmString);
    //system.debug('before first debug AAAAAAA '+limits.getCPUTime());
    //system.debug('results'+results);
    //system.debug('printing first debug AAAAAAA '+limits.getCPUTime());
    String serviceId = (String)results.get('serviceId');
    List<Object> lstSpecifications = (List<Object>)results.get('specifications');
    system.debug('getting lstSpecifications AAAAAAA '+limits.getCPUTime());
    //for each specification get its properties, simple attribute, complex attributes and additional attributes
    List<Object> returnSpecList = new List<Object>();
    //system.debug('before for Loop AAAAAAA '+limits.getCPUTime());
    if(lstSpecifications != null)
    for (Object specification : lstSpecifications) {
      //fetch all properties
        Map<String, Object> specificationAttributes = (Map<String, Object>)specification;
        Map<String, Object> properties = fetchProperties(specificationAttributes);
      properties.put('serviceId', serviceId);
      //fetch simple, complex and additional attributes
        Map<string, Object> simpleAttr = new Map<String, Object>();
        Map<string, Object> compleAttr = new Map<String, Object>();
        Map<string, Object> addnAttr = new Map<String, Object>();
        //get simple and complex attributes
        Map<String, Object> attrs = (Map<String, Object>)specificationAttributes.get('attributes');
        //system.debug('before inside for Loop AAAAAAA '+limits.getCPUTime());
        for(String key: attrs.keySet()){
            Object attValue = attrs.get(key);
            if(attValue instanceof String ||
               attValue instanceof Integer ||
               attValue instanceof Double ||
               attValue instanceof Decimal ||
               attValue instanceof Boolean ||
               attValue instanceof Id  ||
               attValue instanceof Long  ||
               attValue instanceof Date  ||
               attValue instanceof Datetime   ) simpleAttr.put(key, attValue);
            else if (
               attValue == null ||
                   attValue == ''){}
            else compleAttr.put(key, attValue);
        }
        //system.debug('after inside for Loop AAAAAAA '+limits.getCPUTime());
        //System.debug(simpleAttr);
        System.debug('complexAttribs '+compleAttr);

        //get additional attributes
        addnAttr = (Map<String, Object>)specificationAttributes.get('additionalAttributes');
        //System.debug(addnAttr);

        Map<String, Object> returnSpec = new Map<String, Object>();
        returnSpec.putAll(properties);
        if(simpleAttr != null && simpleAttr.size() > 0) returnSpec.put('simpleAttributes', convertToNameValuePairs(simpleAttr));
            if(addnAttr != null && addnAttr.size() > 0) returnSpec.put('additionalAttributes', convertToNameValuePairs(addnAttr));
            if(compleAttr !=null && compleAttr.size() > 0) returnSpec.put('complexAttributes', convertComplexAttr(compleAttr));
        returnSpecList.add(returnSpec);
    }
    //system.debug('after for Loop AAAAAAA '+limits.getCPUTime());
    return JSON.serialize(returnSpecList);
  }

  public static Map<String, Object> fetchProperties(Map<String, Object> specificationAttributes){
    Map<String, Object> properties = new Map<String, String>();
    properties.put('version', specificationAttributes.get('version'));
    properties.put('status', specificationAttributes.get('status'));
    properties.put('startDate', specificationAttributes.get('startDate'));
    properties.put('replacedSpecification', specificationAttributes.get('replacedSpecification'));
    properties.put('productConfigurationId', specificationAttributes.get('productConfigurationId'));
    properties.put('name', specificationAttributes.get('name'));
    properties.put('instanceId', specificationAttributes.get('instanceId'));
    properties.put('identifier', specificationAttributes.get('identifier'));
    properties.put('guid', specificationAttributes.get('guid'));
    properties.put('endDate', specificationAttributes.get('endDate'));
    properties.put('description', specificationAttributes.get('description'));
    properties.put('code', specificationAttributes.get('code'));
    properties.put('billingDetails', specificationAttributes.get('billingDetails'));
    return properties;
  }

  public static List<object> convertToNameValuePairs(Map<String, Object> simplettrs){
    List<Object> namevaluepairList = new List<Object>();
    for(String key : simplettrs.keySet()){
      Map<String, Object> namevaluepair = new Map<String, Object>();
      namevaluepair.put('name', key);
      namevaluepair.put('value', simplettrs.get(key));
      namevaluepairList.add((Object)namevaluepair);
    }
    return namevaluepairList;
  }

  public static Map<String, Object> convertComplexAttr(Map<string, Object> compleAttr){
    Map<string, Object> rtncomplexAttrList = new Map<string, Object>();
    for(String comKey: compleAttr.keySet()){
          List<Object> comAttrs = (List<Object>)compleAttr.get(comKey);
          Map<string, string> comsimpleAttr = new Map<String, String>();
          List<Object> rtncomplexAttr = new List<Object>();
          for(Object attrObj: comAttrs){
              Map<String, Object> singleComp = (Map<String, Object>)attrObj;
        Map<String, Object> comsimpleAttr2 = new Map<String, Object>();
              Map<String, Object> convertedSimpleAttrs = (Map<String, Object>)singleComp.get('attributes');
              comsimpleAttr2.put('simpleAttributes', convertToNameValuePairs(convertedSimpleAttrs));
              comsimpleAttr2.put('productConfigurationId', (Object)singleComp.get('productConfigurationId'));
              rtncomplexAttr.add(comsimpleAttr2);
              System.debug('comsimpleAttr2::'+comsimpleAttr2);
          }
          rtncomplexAttrList.put(comKey, (Object)rtncomplexAttr);

      }
    return rtncomplexAttrList;
  }

  
}