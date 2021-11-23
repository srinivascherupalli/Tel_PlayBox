global with sharing class NumberNCSMobilityBulkHelper {
    FINAL String userPDSpec = 'DMCAT_ProductSpecification_000074';
    
    public Boolean checkForExistingNCS(String basketId, String ncsName) {
        try {
            if (basketId != NULL) {
                for (attachment att : [
                    select id,body
                    from Attachment
                    where ParentId in (select id from cscfga__Product_Configuration__c where cscfga__product_basket__c = :basketId) and Name = :ncsName
                ]) {
                    String jsonStr = att.body.toString();
                    system.debug('Json in Number Mobility Bulk Helper ----->'+jsonStr);
                    NumberNCSMobilityDTO ncsDTO = NumberNCSMobilityDTO.parse(jsonStr);
                    if (ncsDTO != null && ncsDTO.configurations != null && ncsDTO.configurations.size() > 0) {
                        return true;
                    }
                    return false;
                }
            } else {
                return false;
            }
            return false;
        } catch (Exception e) {
            system.debug('Exception in checkForExistingMobilityNCS ' + e);
            return false;
        }
    }
    
    public Boolean checkForExistingNCSBulk(String basketId, String ncsName) {
        boolean flag=false;
        try {
            if (basketId != NULL) {
                Integer countNCS = 0;
                List<cscfga__Product_Configuration__c> prodConfigs = [
                    SELECT Id, Name,
                    (SELECT Id, Name
                     FROM Attachments WHERE Name = :ncsName) FROM cscfga__Product_Configuration__c
                    WHERE cscfga__product_basket__c = :basketId
                ];
                //EDGE-111074, Kalashree Borgaonkar. Fix for unreserving numbers - Start
                for (cscfga__Product_Configuration__c prodConfig : prodConfigs) {
                    if (prodConfig.attachments != NULL || prodConfig.attachments.size() > 0) {
                        flag=true;
                        break;                        
                    } 
                }
                if(flag=true){
                    for (attachment att : [
                        select id,body
                        from Attachment
                        where ParentId in (select id from cscfga__Product_Configuration__c where cscfga__product_basket__c = :basketId) and Name = :ncsName
                    ]) {
                        String jsonStr = att.body.toString();
                        NumberNCSMobilityDTO ncsDTO = NumberNCSMobilityDTO.parse(jsonStr);
                        if (ncsDTO != null && ncsDTO.configurations != null && ncsDTO.configurations.size() > 0) {
                            return true;
                        }
                        return false;
                    }
                }
                else {
                    return false;
                }
            }
            return false;
            //EDGE-111074, Kalashree Borgaonkar. Fix for unreserving numbers - end
        } catch (Exception e) {
            system.debug('Exception in checkForExistingMobilityNCSBulk ' + e);
            return false;
        }
    }
    
    global List<String> getNumbersFromNCS(String basketId) {
        List<String> reservedNumbers = new List<String>();
        try {
            for (attachment att : [
                select id,body
                from Attachment
                where ParentId in (select id from cscfga__Product_Configuration__c where cscfga__product_basket__c = :basketId)
                AND name LIKE '%MobileNumberManagementv1_schema%'
            ]) { //EDGE-84670
                String jsonStr = att.body.toString();
                system.debug('Json from NumberNCSMobilityBulkHelperCLass ----->'+jsonStr);
                
                NumberNCSMobilityDTO ncsDTO = NumberNCSMobilityDTO.parse(jsonStr);
                system.debug('ncsDTO from NumberNCSMobilityBulkHelperCLass ----->'+ncsDTO.configurations);
                for (NumberNCSMobilityDTO.Configuration config : ncsDTO.configurations) {
                    if (config.status == Label.NumberStatus_RESERVED && config.MobileNumber != NULL) {
                        reservedNumbers.add(config.MobileNumber);
                        system.debug('reservedNumbers' + reservedNumbers);
                    }
                }
            }
        } catch (Exception e) {
            system.debug('Exception in getNumbersFromMobilityNCS ' + e);
        }
        return reservedNumbers;
    }
    
    
    public String createNewNCS(String basketId, String ncsName, List<NumberNCSMobilityDTO.Configuration> numberList,String identifyProduct) {
        String productDef = null; 
        //Kalashree Borgaonkar, EDGE-105316 - Fix for PPHH number reservation, start
        if('Mobility'.equalsIgnorecase(identifyProduct)){
            productDef = 'Mobility';
        }
        else if('Subscription'.equalsIgnorecase(identifyProduct)){
            productDef = 'Mobile Subscription';
        }
        System.debug('productDef:'+productDef);
        
        try {
            List<cscfga__Product_Configuration__c> pcs = [
                select id
                from cscfga__Product_Configuration__c
                where cscfga__Product_Basket__c = :basketId
                and cscfga__product_definition__r.name = :productDef
            ];
            system.debug('KK' + pcs.size());
            List<Attachment> atts = [
                select id,body, parentId
                from Attachment
                where ParentId in (select id from cscfga__Product_Configuration__c where cscfga__product_basket__c = :basketId and cscfga__product_definition__r.name = :productDef)
                AND name LIKE '%MobileNumberManagementv1_schema%'
                
            ];
            //Kalashree Borgaonkar, EDGE-105316 - Fix for PPHH number reservation, end
            Map<Id, Boolean> configNumberMap = new Map<Id, Boolean>();
            for (cscfga__Product_Configuration__c pc : pcs) {
                configNumberMap.put(pc.Id, false);
                for (Attachment att : atts) {
                    if (att.parentId == pc.id) {
                        Boolean hasReservedNumber = false;
                        String jsonStr = att.body.toString();
                        NumberNCSMobilityDTO ncsDTO = NumberNCSMobilityDTO.parse(jsonStr);
                        for (NumberNCSMobilityDTO.Configuration config : ncsDTO.configurations) {
                            if (config.status == Label.NumberStatus_RESERVED && config.MobileNumber != NULL) {
                                hasReservedNumber = true;
                            }
                        }
                        if (hasReservedNumber) {
                            configNumberMap.put(pc.Id, true);
                        }
                    }
                }
            }
            csoe__Non_Commercial_Schema__c ncs = fetchNCSInstance(ncsName);
            List<Object> configList = populateConfigListToUpsert(numberList);
            if (ncs != null && configList != null && configList.size() > 0) {
                Map<Id, List<Object>> oeMap = new Map<Id, List<Object>>();
                List<Object> nceList = createNCSConfig(ncsName, ncs, configList);
                system.debug(nceList);
                system.debug('KK - data');
                system.debug(configNumberMap);
                for (Object config : nceList) {
                    String pcId = '';
                    for (String pc : configNumberMap.keySet()) {
                        if (!configNumberMap.get(pc) && pcId == '') {
                            pcId = pc;
                            configNumberMap.put(pc, true);
                            break;
                        }
                    }
                    if (pcId != '') {
                        oeMap.put(pcId, new List<Object>{
                            config
                                });
                    }
                }
                if (oeMap != null) {
                    system.debug('KK' + oeMap);
                    csoe.API_1.createOEData(oeMap);
                    return 'Success';
                }
            }
            return 'Failure';
        } catch (Exception e) {
            system.debug('Exception while creating new NCS ' + e);
            return 'Failure';
        }
    }
    
    public String createNewNCS(String rootConfigId, String ncsName, List<NumberNCSMobilityDTO.Configuration> numberList, csoe__Non_Commercial_Schema__c ncs) {
        try {
            //fetch MobileNumberManagementv1 from custom label
            //csoe__Non_Commercial_Schema__c ncs = fetchNCSInstance(ncsName);
            List<Object> configList = populateConfigListToUpsert(numberList);
            if (ncs != null && configList != null && configList.size() > 0) {
                List<Object> nceList = createNCSConfig(ncsName, ncs, configList);
                if (nceList != null) {
                    Map<Id, List<Object>> oeMap = new Map<Id, List<Object>>();
                    oeMap.put(rootConfigId, nceList);
                    csoe.API_1.createOEData(oeMap);
                    return 'Success';
                }
            }
            return 'Failure';
        } catch (Exception e) {
            system.debug('Exception while creating new NCS ' + e);
            return 'Failure';
        }
    }
    
    public String updateExistingNCS(String rootConfigId, String ncsName, List<NumberNCSMobilityDTO.Configuration> numberList) {
        try {
            //fetch MobileNumberManagementv1 from custom label
            csoe__Non_Commercial_Schema__c ncs = fetchNCSInstance(ncsName);
            List<Object> configList = populateConfigListToUpsert(numberList);
            if (ncs != null && configList != NULL && configList.size() > 0) {
                List<Object> nceList = createNCSConfig(ncsName, ncs, configList);
                if (nceList != null) {
                    Map<Id, List<Object>> oeMapUpdate = new Map<Id, List<Object>>();
                    oeMapUpdate.put(rootConfigId, nceList);
                    system.debug('oeMapUpdate ' + oeMapUpdate);
                    csoe.API_1.updateOEData(oeMapUpdate);
                    return 'Success';
                }
            }
            return 'Failure';
        } catch (Exception e) {
            system.debug('Exception while updating exisitng NCS ' + e);
            return 'Failure';
        }
    }
    
    public String updateExistingNCS(String rootConfigId, String ncsName, List<NumberNCSMobilityDTO.Configuration> numberList, csoe__Non_Commercial_Schema__c ncs) {
        try {
            //fetch MobileNumberManagementv1 from custom label
            //csoe__Non_Commercial_Schema__c ncs = fetchNCSInstance(ncsName);
            List<Object> configList = populateConfigListToUpsert(numberList);
            if (ncs != null && configList != null && configList.size() > 0) {
                List<Object> nceList = createNCSConfig(ncsName, ncs, configList);
                if (nceList != null) {
                    Map<Id, List<Object>> oeMapUpdate = new Map<Id, List<Object>>();
                    oeMapUpdate.put(rootConfigId, nceList);
                    system.debug('oeMapUpdate ' + oeMapUpdate);
                    csoe.API_1.updateOEData(oeMapUpdate);
                    return 'Success';
                }
            }
            return 'Failure';
        } catch (Exception e) {
            system.debug('Exception while updating exisitng NCS ' + e);
            return 'Failure';
        }
    }
    
    //----- Upsert Configuration List in Mobility NCS -----//
    public List<Object> populateConfigListToUpsert(List<NumberNCSMobilityDTO.Configuration> numberList) {
        try {
            List<Object> configList = new List<Object>();
            for (NumberNCSMobilityDTO.Configuration conf : numberList) {
                Map<String, Object> config = new Map<String, Object>();
                config.put('guid', conf.guid);
                config.put('MobileNumber', conf.MobileNumber);
                config.put('Status', conf.Status);
                config.put('listCode', conf.listCode);
                configList.add((Object) config);
            }
            system.debug('updated ConfigList  ' + configList);
            return configList;
        } catch (Exception e) {
            system.debug('Exception in populateConfigListToUpsert ' + e);
            return null;
        }
    }
    
    //----- Fetch Instance of Mobility NCS-----//
    public csoe__Non_Commercial_Schema__c fetchNCSInstance(String ncsName) {
        try {
            csoe__Non_Commercial_Schema__c ncs = [select id from csoe__Non_Commercial_Schema__c where name = :ncsName LIMIT 1];
            return ncs;
        } catch (Exception e) {
            system.debug('Exception in fetchNCSInstance ' + e);
            return null;
        }
    }
    
    public String deleteExistingNCS(String basketId, String ncsName, List<String> deleteList) {
        try {
            List<NumberNCSMobilityDTO.Configuration> ncsConfigList = new List<NumberNCSMobilityDTO.Configuration>();
            csoe__Non_Commercial_Schema__c ncs = [select id from csoe__Non_Commercial_Schema__c where name = :ncsName LIMIT 1];
            if (ncs != null) {
                List<String> reservedNumbersList = new List<String>();
                for (Attachment att : [
                    select id, body
                    from Attachment
                    where ParentId in (select id from cscfga__Product_Configuration__c where cscfga__product_basket__c = :basketId)
                    AND name LIKE '%MobileNumberManagementv1_schema%'
                ]) { //EDGE-84670
                    String jsonStr = att.body.toString();
                    NumberNCSMobilityDTO ncsDTO = NumberNCSMobilityDTO.parse(jsonStr);
                    for (NumberNCSMobilityDTO.Configuration config : ncsDTO.configurations) {
                        if (config.MobileNumber != NULL && deleteList.contains(config.MobileNumber)) {
                            reservedNumbersList.add(att.id);
                            System.debug('reservedNumbersList: '+reservedNumbersList);
                        }
                    }
                }
                if (reservedNumbersList != null && reservedNumbersList.size() > 0) {
                    delete [
                        select id
                        from attachment
                        where id in :reservedNumbersList
                    ];
                }
            }
            System.debug('Success');
            return 'Success';
        } catch (Exception e) {
            system.debug('Exception while updating exisitng NCS ' + e);
            return 'Failure';
        }
    }
    
    public Integer getTotalCountOfNumbers(String UCEConfigId) {
        List<String> fnnList = new List<String>();
        List<String> rangeList = new List<String>();
        Integer numberCount = 0;
        try {
            for (attachment att : [select id,body from attachment where ParentId = :UCEConfigId AND name LIKE '%MobileNumberManagementv1_schema%']) { //EDGE-84670
                String jsonStr = att.body.toString();
                NumberNCSMobilityDTO ncsDTO = NumberNCSMobilityDTO.parse(jsonStr);
                for (NumberNCSMobilityDTO.Configuration config : ncsDTO.configurations) {
                    if (config.MobileNumber != NULL) {
                        fnnList.add(config.MobileNumber);
                    }
                }
            }
            numberCount = fnnList.size();
            return numberCount;
        } catch (Exception e) {
            system.debug('Exception in getTotalCountOfNumbers ' + e);
            return 0;
        }
    }
    public List<Object> createNCSConfig(String ncsName, csoe__Non_Commercial_Schema__c ncs, List<Object> configList) {
        try {
            List<Object> nceList = new List<Object>();
            // Insert configs for queried schema (create non commercial entity)
            for (Object config : configList) {
                Map<String, Object> nce = new Map<String, Object>();
                nce.put('name', (Object) ncsName);
                nce.put('id', (Object) ncs.id);
                nce.put('configurations', new List<Object>{
                    config
                        });
                nceList.add((Object) nce);
            }
            
            return nceList;
        } catch (Exception e) {
            system.debug('Exception in createNCSConfig ' + e);
            return null;
        }
    }
    
    public void updateNCSForStatus(String rootConfigId) {
        List<NumberNCSMobilityDTO.Configuration> numberList = new List<NumberNCSMobilityDTO.Configuration>();
        NumberNCSMobilityHelper ncs = new NumberNCSMobilityHelper();
        for (Attachment att : [select Id,Body FROM Attachment WHERE ParentId = :rootConfigId AND name LIKE '%MobileNumberManagementv1_schema%']) //EDGE-84670
        {
            String jsonStr = att.body.toString();
            NumberNCSMobilityDTO ncsDTO = NumberNCSMobilityDTO.parse(jsonStr);
            for (NumberNCSMobilityDTO.Configuration config : ncsDTO.configurations) {
                if ((config.status == Label.NumberStatus_RESERVED || config.status == Label.NumberStatus_TRANSITION)) {
                    config.status = Label.NumberStatus_ACTIVE;
                }
                numberList.add(config);
            }
            System.debug('numberList::' + numberList);
            ncs.updateExistingNCS(rootConfigId, 'MobileNumberManagementv1', numberList);
        }
    }
}