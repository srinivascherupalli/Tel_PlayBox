global with sharing class NumberNCSHelper {
    FINAL String userPDSpec = 'DMCAT_ProductSpecification_000074';  
        public Boolean checkForExistingNCS(String UCEConfigId){
            try{
                //List<String> prodDefId = new List<String>();
                //String UCEConfigId = null;
                // make DMCAT_ProductSpecification_00007 as custom label
                /*for(cscfga__Product_Definition__c prodDef : [select id from cscfga__Product_Definition__c where product_Specification__c = 'DMCAT_ProductOffering_000304' and cscfga__Active__c = true]){ 
                    prodDefId.add(prodDef.id);
                }*/
                //if(prodDefId!=null){
                   /* for(cscfga__product_configuration__c config : [select id,cscfga__Root_Configuration__c from cscfga__product_configuration__c where cscfga__Product_Basket__c =:basketId and cscfga__Product_Definition__c IN :prodDefId]){
                        UCEConfigId = config.id;
                    }*/
                    if(UCEConfigId!=null){
                        for(attachment att : [select id,body from attachment where ParentId  =:UCEConfigId and Name like '%NumberManagement%']){
                            System.debug('');
                            String jsonStr = att.body.toString();
                            NumberNCSDTO ncsDTO = NumberNCSDTO.parse(jsonStr);
                            if(ncsDTO!=null && ncsDTO.configurations!=null && ncsDTO.configurations.size()>0){
                                return true;
                            }
                            return false;
                        }
                    }else {return false;}
           
                return false;
            }catch(Exception e){
                system.debug('Exception in checkForExistingNCS ' + e);
                return false;
            }
        }
        
        global Map<String,List<String>> getNumbersFromNCS(String UCEConfigId){
            Map<String,List<String>> numberMap = new Map<String,List<String>>();
            List<String> activeNumbers = new List<String>();
            List<String> transitionNumbers = new List<String>();
            List<String> reservedNumbers = new List<String>();
            try{
                /*for(attachment att : [select id,body from attachment where ParentId  =:UCEConfigId and Name like '%NumberManagement%']){*/
                //CheckMarx ERR FIX
                string qryAtt='select id,body from attachment where ParentId =\''+ String.escapeSingleQuotes(UCEConfigId) +'\' and Name like \'%NumberManagement%\'';        
                for(attachment att:Database.query(qryAtt)){
                    String jsonStr = att.body.toString();
                    System.debug('JSON :: '+jsonStr);
                    NumberNCSDTO ncsDTO = NumberNCSDTO.parse(jsonStr);
                    for(NumberNCSDTO.Configuration config : ncsDTO.configurations){
                        if(config.status == Label.NumberStatus_ACTIVE){
                            if(config.FNN != NULL){
                                activeNumbers.add(config.FNN);    
                            }else if(config.rangeFrom != NULL){
                                activeNumbers.add(config.rangeFrom + ' : ' + config.rangeTo);    
                            }
                        }else if(config.status == Label.NumberStatus_TRANSITION){
                            System.debug('config.FNN::'+config.FNN);
                            System.debug('range::'+config.rangeFrom + ' : ' + config.rangeTo);
                            if(config.FNN != NULL){
                                transitionNumbers.add(config.FNN);    
                            } else {
                                if(config.rangeFrom != NULL){
                                    transitionNumbers.add(config.rangeFrom + ' : ' + config.rangeTo);
                                }
                            }
                            System.debug('transitionNumbers::'+transitionNumbers);
                        }
                        else if(config.status == Label.NumberStatus_RESERVED){
                            if(config.FNN != NULL){
                                reservedNumbers.add(config.FNN);    
                            }else if(config.rangeFrom != NULL){
                                reservedNumbers.add(config.rangeFrom + ' : ' + config.rangeTo);    
                            }
                        }
                    }
                    if(activeNumbers!= null && activeNumbers.size()>0){
                        numberMap.put(Label.NumberStatus_ACTIVE,activeNumbers);
                    }
                    if(transitionNumbers!= null && transitionNumbers.size()>0){
                        numberMap.put(Label.NumberStatus_TRANSITION,transitionNumbers);
                    }
                    if(reservedNumbers!= null && reservedNumbers.size()>0){
                        numberMap.put(Label.NumberStatus_RESERVED,reservedNumbers);
                    }
                }
            }catch(Exception e){
                system.debug('Exception in getNumbersFromNCS ' + e);
            }
            return numberMap;
        }
        
        public Integer getTotalCountOfNumbers(String UCEConfigId){
            List<String> fnnList = new List<String>();
            List<String> rangeList = new List<String>();
            Integer numberCount = 0;
            try{
                for(attachment att : [select id,body from attachment where ParentId  =:UCEConfigId and Name like '%NumberManagement%']){
                    String jsonStr = att.body.toString();
                    NumberNCSDTO ncsDTO = NumberNCSDTO.parse(jsonStr);
                    for(NumberNCSDTO.Configuration config : ncsDTO.configurations){
                        if(config.FNN != NULL){
                            fnnList.add(config.FNN);
                        }else if(config.rangeFrom != NULL){
                            rangeList.add(config.rangeFrom + ':' + config.rangeTo);
                        }
                    }
                }
                numberCount =  fnnList.size();
                Integer tempCount = 0;
                for(String range : rangeList){
                    List<String> splitNumbers = range.split(':');
                    if(splitNumbers.size() > 1){
                        tempCount += 1 + Integer.valueOf(splitNumbers[1]) - Integer.valueOf(splitNumbers[0]);
                    } 
                }
                return numberCount + tempCount;
            }catch(Exception e){
                system.debug('Exception in getTotalCountOfNumbers ' + e);
                return 0;
            }
        }
        
        public List<Object> populateConfigListToUpsert(List<NumberNCSDTO.Configuration> numberList){
            try{
                List<Object> configList = new List<Object>();
                for(NumberNCSDTO.Configuration conf : numberList){
                    Map<String, Object> config = new Map<String, Object>();
                    config.put('FNN', conf.FNN);
                    config.put('rangeFrom', conf.rangeFrom );
                    config.put('rangeTo', conf.rangeTo);
                    config.put('status', conf.status);
                    config.put('listCode', conf.listCode);
                     system.debug('listCode  ' + conf.listCode);
                    config.put('guid', conf.guid);
                    configList.add((Object) config);
                }
                system.debug('updated ConfigList  ' + configList);
                return configList;
            }catch(Exception e){
                system.debug('Exception in populateConfigListToUpsert ' + e);
                return null;
            }
        }
        
        public String updateExistingNCS(String rootConfigId, String ncsName, List<NumberNCSDTO.Configuration> numberList){
            try{
                //fetch NumberManagementv1 from custom label
                csoe__Non_Commercial_Schema__c ncs = fetchNCSInstance(ncsName);
                List<Object> configList = populateConfigListToUpsert(numberList);
                if(ncs != null && configList != NULL && configList.size()>0){
                    List<Object> nceList = createNCSConfig(ncsName,ncs,configList);
                    if(nceList!=null){
                        Map<Id,List<Object>> oeMapUpdate = new Map<Id, List<Object>>();
                        oeMapUpdate.put(rootConfigId, nceList);
                        system.debug('oeMapUpdate ' +  oeMapUpdate);
                        csoe.API_1.updateOEData(oeMapUpdate);
                        return 'Success';
                    }
                }
                return 'Failure';
            }catch(Exception e){
                system.debug('Exception while updating exisitng NCS ' + e);
                return 'Failure';
            }
        }
        
        /**
         * updateExistingNCSbulk Same as updateExistingNCS (3 param) but bulkified
         * EDGE-90967
         */
        public String updateExistingNCSbulk(List<String> rootConfigIdList, String ncsName, Map<String,List<NumberNCSDTO.Configuration>> configIdToNumberList){
            try{
                //fetch NumberManagementv1 from custom label
                system.debug('rootConfigIdList...'+rootConfigIdList);
                system.debug('configIdToNumberList...'+configIdToNumberList.values());
                Map<Id,List<Object>> oeMapUpdate = new Map<Id, List<Object>>();
                csoe__Non_Commercial_Schema__c ncs = fetchNCSInstance(ncsName);
                system.debug('ncs171'+ncs);
                for (String rootConfigId: rootConfigIdList) {
                    system.debug('rootConfigId172'+rootConfigId);
                    List<Object> configList = populateConfigListToUpsert(configIdToNumberList.get(rootConfigId));
                    system.debug('configList174'+configList);
                    if(ncs != null && configList != NULL && configList.size()>0){
                        system.debug('configList177'+configList);
                        List<Object> nceList = createNCSConfig(ncsName,ncs,configList);
                        system.debug('nceList179'+nceList);
                        if(nceList!=null){
                            oeMapUpdate.put(rootConfigId, nceList);
                        }
                    }
                }
                 system.debug('oeMapUpdate185'+oeMapUpdate);
                if (!oeMapUpdate.isEmpty()) {
                    system.debug('oeMapUpdate ' +  oeMapUpdate);
                    csoe.API_1.updateOEData(oeMapUpdate);
                    system.debug('oeMapUpdate191'+oeMapUpdate);
              
                    return 'Success';
                }
                 
                return 'Failure';
            }catch(Exception e){
                system.debug('Exception while updating existing NCS in bulk' + e);
                return 'Failure';
            }
        }
    
         public String updateExistingNCS(String rootConfigId, String ncsName, List<NumberNCSDTO.Configuration> numberList, csoe__Non_Commercial_Schema__c ncs){
            try{
                //fetch NumberManagementv1 from custom label
                //csoe__Non_Commercial_Schema__c ncs = fetchNCSInstance(ncsName);
                List<Object> configList = populateConfigListToUpsert(numberList);
                if(ncs != null && configList != null && configList.size()>0){
                    List<Object> nceList = createNCSConfig(ncsName,ncs,configList);
                    if(nceList!=null){
                        Map<Id,List<Object>> oeMapUpdate = new Map<Id, List<Object>>();
                        oeMapUpdate.put(rootConfigId, nceList);
                        system.debug('oeMapUpdate ' +  oeMapUpdate);
                        csoe.API_1.updateOEData(oeMapUpdate);
                        return 'Success';
                    }
                }
                return 'Failure';
            }catch(Exception e){
                system.debug('Exception while updating exisitng NCS ' + e);
                return 'Failure';
            }
        }
        
        public String createNewNCS(String rootConfigId, String ncsName, List<NumberNCSDTO.Configuration> numberList){
            try{
                //fetch NumberManagementv1 from custom label
                csoe__Non_Commercial_Schema__c ncs = fetchNCSInstance(ncsName);
                List<Object> configList = populateConfigListToUpsert(numberList);
                System.debug('rootConfigId::'+rootConfigId);
                if(ncs != null && configList != null && configList.size()>0){
                    List<Object> nceList = createNCSConfig(ncsName,ncs,configList);
                    if(nceList!=null){
                        Map<Id,List<Object>> oeMap = new Map<Id, List<Object>>();
                        oeMap.put(rootConfigId, nceList);
                        System.debug('oeMap:'+oeMap);
                        csoe.API_1.createOEData(oeMap);
                        return 'Success';
                    }
                }
                return 'Failure';
            }catch(Exception e){
                system.debug('Exception while creating new NCS ' + e.getStackTraceString());
                return 'Failure';
            }
        }
    
        public String createNewNCS(String rootConfigId, String ncsName, List<NumberNCSDTO.Configuration> numberList, csoe__Non_Commercial_Schema__c ncs){
            try{
                //fetch NumberManagementv1 from custom label
                //csoe__Non_Commercial_Schema__c ncs = fetchNCSInstance(ncsName);
                List<Object> configList = populateConfigListToUpsert(numberList);
                if(ncs != null && configList != null && configList.size()>0){
                    List<Object> nceList = createNCSConfig(ncsName,ncs,configList);
                    if(nceList!=null){
                        Map<Id,List<Object>> oeMap = new Map<Id, List<Object>>();
                        oeMap.put(rootConfigId, nceList);
                        csoe.API_1.createOEData(oeMap);
                        return 'Success';
                    }
                }
                return 'Failure';
            }catch(Exception e){
                system.debug('Exception while creating new NCS ' + e.getStackTraceString());
                return 'Failure';
            }
        }
        
        public csoe__Non_Commercial_Schema__c fetchNCSInstance(String ncsName){
            try{
                csoe__Non_Commercial_Schema__c ncs = [select id from csoe__Non_Commercial_Schema__c where name =: ncsName  LIMIT 1];
                return ncs;
            }catch(Exception e){
                system.debug('Exception in fetchNCSInstance ' + e);
                return null;
            }
        }
        
        //This method populates a list of NCS to be created to insert the data. It uses List for cases when there are requirements to create multiple NCS within a rootConfig
        public List<Object> createNCSConfig(String ncsName,csoe__Non_Commercial_Schema__c ncs, List<Object> configList){
            try{
                List<Object> nceList = new List<Object>();
                // Insert configs for queried schema (create non commercial entity)
                Map<String,Object> nce = new Map<String,Object>();
                nce.put('name', (Object) ncsName);
                nce.put('id', (Object) ncs.id);
                nce.put('configurations', configList);
                nceList.add((Object) nce);
                return nceList;
            }catch(Exception e){
                system.debug('Exception in createNCSConfig ' + e);
                return null;
            }   
        }
        
    //----Update Existing NCS after Complete Status Notification from AMDOCS for nextGenUC Product
        public void updateNCSForStatus(String rootConfigId){
            List<NumberNCSDTO.Configuration> numberList = new List<NumberNCSDTO.Configuration>();
            NumberNCSHelper ncs = new NumberNCSHelper();
            for(Attachment att : [select Id,Body FROM Attachment WHERE ParentId  =: rootConfigId and Name like '%NumberManagement%'])
            {
                String jsonStr = att.body.toString();
                NumberNCSDTO ncsDTO = NumberNCSDTO.parse(jsonStr);
                for(NumberNCSDTO.Configuration config : ncsDTO.configurations){         
                    if((config.status == Label.NumberStatus_RESERVED || config.status == Label.NumberStatus_TRANSITION)){
                        config.status = Label.NumberStatus_ACTIVE;
                    }
                numberList.add(config);
            }
            System.debug('numberList::' + numberList);
            ncs.updateExistingNCS(rootConfigId,'NumberManagementv1',numberList);
        }   
    }
        
        
        public String deleteExistingNCS(String rootConfigId, List<String> deleteList){
         try{
             List<NumberNCSDTO.Configuration> ncsConfigList = new List<NumberNCSDTO.Configuration>();
             csoe__Non_Commercial_Schema__c ncs = [select id from csoe__Non_Commercial_Schema__c where name = 'NumberManagementv1'  LIMIT 1];
             if(ncs!=null){
                 List<String> reservedNumbersList = new List<String>();
                for(Attachment att : [select id,body from attachment where ParentId  =:rootConfigId and Name like '%NumberManagement%']){
                    String jsonStr = att.body.toString();
                    NumberNCSDTO ncsDTO = NumberNCSDTO.parse(jsonStr);
                    for(NumberNCSDTO.Configuration config : ncsDTO.configurations){
                            if((config.FNN != NULL && deleteList.contains(config.FNN)) || (config.rangeFrom != NULL && deleteList.contains(config.rangeFrom+':'+config.rangeTo))){
                                reservedNumbersList.add(config.guid); 
                            }
                    }
                }
                 if(reservedNumbersList!=null && reservedNumbersList.size()>0){
                    System.debug('reservedNumbersList::' + reservedNumbersList);
                    List<Object> configList = new List<Object>();
                    configList.addAll((List<Object>)reservedNumbersList);
                    Map<String,Object> nce = new Map<String,Object>();
                    nce.put('name',(Object) 'NumberManagementv1');
                    nce.put('id',(Object) ncs.Id);//ncs id
                    nce.put('configurations', configList);
                    List<Object> nceList = new List<Object>();
                    nceList.add((Object) nce);
                    Map<Id,List<Object>> oeMapUpdate = new Map<Id,List<Object>>();
                    oeMapUpdate.put(rootConfigId, nceList);//pc id
                    System.debug('oeMapUpdate::' + oeMapUpdate);
                    csoe.API_1.deleteOEData(oeMapUpdate);
                 }
             }
            return 'Success'; 
        }
        catch(Exception e){
            system.debug('Exception while updating exisitng NCS ' + e);
            return 'Failure';
        }
        }
        
        /******************************************************************
         Method: deleteExistingNCSMultiplePC
         Descritpion: Modified existing method deleteExistingNCS for bulkification
         Story: EDGE-100660
         Author: Ila
         ***************************************************************/
         public String deleteExistingNCSMultiplePC(Map<Id,List<String>> multiplePCNCS){
         try{ 
             List<NumberNCSDTO.Configuration> ncsConfigList = new List<NumberNCSDTO.Configuration>();
             csoe__Non_Commercial_Schema__c ncs = [select id from csoe__Non_Commercial_Schema__c where name = 'NumberManagementv1'  LIMIT 1];
             if(ncs!=null){
                 Map<Id,List<Object>> oeMapUpdate = new Map<Id,List<Object>>();
                for(Attachment att : [select id,body,ParentId from attachment where ParentId IN:multiplePCNCS.keySet() and Name like '%NumberManagement%']){
                   List<String> reservedNumbersList = new List<String>();
                  String jsonStr = att.body.toString();
                    NumberNCSDTO ncsDTO = NumberNCSDTO.parse(jsonStr);
                    for(NumberNCSDTO.Configuration config : ncsDTO.configurations){
                        List<String> lstfnn = multiplePCNCS.get(att.ParentId);
                            if((config.FNN != NULL && multiplePCNCS.get(att.ParentId).contains(config.FNN)) || (config.rangeFrom != NULL && multiplePCNCS.get(att.ParentId).contains(config.rangeFrom+':'+config.rangeTo))){
                                reservedNumbersList.add(config.guid); 
                            }
                    }
                    
                    if(reservedNumbersList!=null && reservedNumbersList.size()>0){
                        System.debug('reservedNumbersList::' + reservedNumbersList);
                        List<Object> configList = new List<Object>();
                        configList.addAll((List<Object>)reservedNumbersList);
                        Map<String,Object> nce = new Map<String,Object>();
                        nce.put('name',(Object) 'NumberManagementv1');
                        nce.put('id',(Object) ncs.Id);//ncs id
                        nce.put('configurations', configList);
                        List<Object> nceList = new List<Object>();
                        nceList.add((Object) nce);
                        oeMapUpdate.put(att.ParentId, nceList);//pc id
                    }
                }
                 if(!oeMapUpdate.isEmpty()){
                     csoe.API_1.deleteOEData(oeMapUpdate);
                 }
             }
            return 'Success'; 
        }
        catch(Exception e){
            system.debug('Exception while updating exisitng NCS ' + e);
            return 'Failure';
        }
        }
        
       /* public Integer getTotalUserQty(String rootConfigId, String basketId){
            try{
                Integer userQty = 0;
                String accountId = '';
                //Query User Configuration
                List<cscfga__Product_Configuration__c> bsktConfigs = [SELECT Id, Name, cscfga__Product_Basket__r.csbb__Account__c, Quantity_Product_Configuration__c, csordtelcoa__Replaced_Product_Configuration__c 
                                            FROM cscfga__Product_Configuration__c
                                            WHERE cscfga__product_definition__r.product_Specification__c = :userPDSpec
                                            AND cscfga__Product_Basket__c = :basketId
                                            AND Quantity_Product_Configuration__c != null];
            
                //PCs which are replaced by the PCs in current basket should not be reconsidered
                List<Id> pcListToExclude = new List<Id>();
                for(cscfga__Product_Configuration__c pc: bsktConfigs){
                  pcListToExclude.add(pc.csordtelcoa__Replaced_Product_Configuration__c);
                  userQty += Integer.valueOf(pc.Quantity_Product_Configuration__c);
                  accountId = pc.cscfga__Product_Basket__r.csbb__Account__c;
                }
            
                //Users from Customer's active subscriptions
                //Users from other baskets should not be considered as the final stage of those basket cannot be ascertained
            
                List<csord__service__c> prodConfigs = [Select Id, Name, csordtelcoa__Product_Configuration__r.Quantity_Product_Configuration__c 
                                            FROM csord__service__c 
                                            where csordtelcoa__Product_Configuration__r.cscfga__product_definition__r.product_Specification__c = :userPDSpec
                                            AND csordtelcoa__Replaced_Service__c = null
                                            AND csord__Subscription__r.csord__Account__c =: accountId
                                            AND csord__Status__c NOT IN ('Cancelled','Disconnected') 
                                                                     AND csordtelcoa__Product_Configuration__c NOT IN :pcListToExclude
                                            AND csordtelcoa__Product_Configuration__r.Quantity_Product_Configuration__c != null];
            
                System.debug('prodConfig : ' + prodConfigs);
            
                //sum the quantity at the 
                for (csord__service__c prodConfig : prodConfigs) {
                   System.debug(prodConfig.csordtelcoa__Product_Configuration__r.Quantity_Product_Configuration__c);
                   userQty += Integer.valueOf(prodConfig.csordtelcoa__Product_Configuration__r.Quantity_Product_Configuration__c);
                }
                return userQty;
            }catch(Exception e){
                system.debug('Exception in getTotalUserQty ' + e);
                return 0;
            }
            
        }*/
        
        // EDGE - 61597
        public static String fetchNumberUsingGUID(String configId, String guid){
            String MobileNumber = '';
            try{
               
                for(attachment attach : [select id,body from attachment where ParentId  =:configId and Name like  '%MobileNumberManagementv1_schema%']){
                    String jsonSt = attach.body.toString();
                    System.debug('JSON :: '+jsonSt);
                    NumberNCSMobilityDTO mobilityDTO = NumberNCSMobilityDTO.parse(jsonSt);
                    for(NumberNCSMobilityDTO.Configuration config : mobilityDTO.configurations){
                        if(config.guid == guid)
                        {
                            MobileNumber = config.MobileNumber;
                            system.debug('MobileNumber ' + MobileNumber);
                        }
                    }
                }
               
            }catch(Exception e){
                system.debug('Exception in fetchNumberUsingGUID ' + e);
            }
            return MobileNumber;
        }
        
    //----- numberList for BDS Interface -----//
        public Set<String> getNumbersforBDS(String srvNumber){
            //srvNumber = 'SVC-000011175';
            try{
            System.debug('srvNumber: '+srvNumber);
                 List<csord__Service__c> serviceList = [Select Id,csordtelcoa__Product_Configuration__c from csord__Service__c where csordtelcoa__Service_Number__c =:srvNumber order by createddate desc limit 1];
            System.debug('serviceList: '+serviceList);
            cscfga__Product_Configuration__c config = [Select Id,csordtelcoa__Replaced_Product_Configuration__c from cscfga__Product_Configuration__c where id = :serviceList[0].csordtelcoa__Product_Configuration__c];
            String configId = config.Id;
            System.debug('config: '+config);
            
            String replacedconfigId = NULL;
            
            if(config.csordtelcoa__Replaced_Product_Configuration__c != NULL){
                replacedconfigId = config.csordtelcoa__Replaced_Product_Configuration__c;
            }
            System.debug('replacedconfigId: '+replacedconfigId);
            Map<String,List<String>> fnnMap = new Map<String,List<String>>();
            Set<String> fnnSet = new set<String>();
            fnnMap = getNumbersFromNCS(configId);
            for(String key : fnnMap.keySet()){
                fnnSet.addAll(fnnMap.get(key));
            }
             System.debug('fnnSet: '+fnnSet);
    
            System.debug('fnnMap: '+fnnMap);
    
            //for modify Order
            if(replacedconfigId != NULL){
                Map<String,List<String>> replacedFnnMap = new Map<String,List<String>>();
                Set<String> replacedFnnSet = new Set<String>();
                replacedFnnMap = getNumbersFromNCS(replacedconfigId);
                System.debug('replacedFnnMap: '+replacedFnnMap);
                for(String key : replacedFnnMap.keySet()){
                    replacedFnnSet.addAll(replacedFnnMap.get(key));
                }
                 System.debug('replacedFnnSet: '+replacedFnnSet);
                fnnSet.removeAll(replacedFnnSet);
            }
             System.debug('fnnSet: '+fnnSet);
                return fnnSet;
            }
            catch(Exception e){
                 system.debug('Exception in getNumbersforBDS ' + e);
                   return null;
            }
           
        }
        
    }