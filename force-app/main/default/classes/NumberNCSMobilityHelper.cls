global with sharing class NumberNCSMobilityHelper {
FINAL String userPDSpec = 'DMCAT_ProductSpecification_000074';  

//----- Check NCS exists on specified Product Configuration -----//
   public Boolean checkForExistingNCS(String UCEConfigId, String ncsName){
        try{
            if(UCEConfigId != NULL){
                for(attachment att : [select id,body from Attachment where ParentId  =: UCEConfigId and Name =: ncsName]){
                    String jsonStr = att.body.toString();
                        NumberNCSMobilityDTO ncsDTO = NumberNCSMobilityDTO.parse(jsonStr);
                        if(ncsDTO!=null && ncsDTO.configurations!=null && ncsDTO.configurations.size()>0){
                            return true;
                        }
                        return false;
                    }
                }
                else {return false;}
            return false;
        }
        catch(Exception e){
            system.debug('Exception in checkForExistingMobilityNCS ' + e);
            return false;
        }
    }
    
//----- Read List of Numbers from Mobility NCS -----//   
    global List<String> getNumbersFromNCS(String UCEConfigId){
       // Map<String,List<String>> numberMap = new Map<String,List<String>>();
        //List<String> activeNumbers = new List<String>();
        //List<String> transitionNumbers = new List<String>();
        List<String> reservedNumbers = new List<String>();
        try{
            for(attachment att : [select id,body from attachment where ParentId  =: UCEConfigId AND name LIKE '%MobileNumberManagementv1_schema%']){ //EDGE-84670
                String jsonStr = att.body.toString();
                NumberNCSMobilityDTO ncsDTO = NumberNCSMobilityDTO.parse(jsonStr);
                for(NumberNCSMobilityDTO.Configuration config : ncsDTO.configurations){
                    if(config.status == Label.NumberStatus_RESERVED && config.MobileNumber != NULL){
                        reservedNumbers.add(config.MobileNumber);
                                    system.debug('reservedNumbers'+reservedNumbers);

                    }
                    /*else if(config.status == Label.NumberStatus_ACTIVE && config.MobileNumber != NULL){
                        activeNumbers.add(config.MobileNumber);
                    }
                    else if(config.status == Label.NumberStatus_TRANSITION && config.MobileNumber != NULL){
                        transitionNumbers.add(config.MobileNumber);
                    }*/
                }
               /* if(reservedNumbers!= null && reservedNumbers.size()>0){
                    numberMap.put(Label.NumberStatus_RESERVED,reservedNumbers);
                }
                /*if(activeNumbers!= null && activeNumbers.size()>0){
                    numberMap.put(Label.NumberStatus_ACTIVE,activeNumbers);
                }
                if(transitionNumbers!= null && transitionNumbers.size()>0){
                    numberMap.put(Label.NumberStatus_TRANSITION,transitionNumbers);
                }*/
            }
        }
        catch(Exception e){
            system.debug('Exception in getNumbersFromMobilityNCS ' + e);
        }
        return reservedNumbers;
    }
    
    
//----- Create New Mobility NCS -----//
    public String createNewNCS(String rootConfigId, String ncsName, List<NumberNCSMobilityDTO.Configuration> numberList){
        try{
            //fetch MobileNumberManagementv1 from custom label
            csoe__Non_Commercial_Schema__c ncs = fetchNCSInstance(ncsName);
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
            system.debug('Exception while creating new NCS ' + e);
            return 'Failure';
        }
    }

    public String createNewNCS(String rootConfigId, String ncsName, List<NumberNCSMobilityDTO.Configuration> numberList, csoe__Non_Commercial_Schema__c ncs){
        try{
            //fetch MobileNumberManagementv1 from custom label
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
            system.debug('Exception while creating new NCS ' + e);
            return 'Failure';
        }
    }
    
    
//----- Update Mobility NCS -----//
    public String updateExistingNCS(String rootConfigId, String ncsName, List<NumberNCSMobilityDTO.Configuration> numberList){
        try{
            //fetch MobileNumberManagementv1 from custom label
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

     public String updateExistingNCS(String rootConfigId, String ncsName, List<NumberNCSMobilityDTO.Configuration> numberList, csoe__Non_Commercial_Schema__c ncs){
        try{
            //fetch MobileNumberManagementv1 from custom label
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
    
//----- Upsert Configuration List in Mobility NCS -----//
    public List<Object> populateConfigListToUpsert(List<NumberNCSMobilityDTO.Configuration> numberList){
        try{
            List<Object> configList = new List<Object>();
            for(NumberNCSMobilityDTO.Configuration conf : numberList){
                Map<String, Object> config = new Map<String, Object>();
                config.put('guid', conf.guid);
                config.put('MobileNumber', conf.MobileNumber);
                config.put('Status', conf.Status);
                config.put('listCode', conf.listCode);
                configList.add((Object) config);
            }
            system.debug('updated ConfigList  ' + configList);
            return configList;
        }catch(Exception e){
            system.debug('Exception in populateConfigListToUpsert ' + e);
            return null;
        }
    }
    
//----- Fetch Instance of Mobility NCS-----//
    public csoe__Non_Commercial_Schema__c fetchNCSInstance(String ncsName){
        try{
            csoe__Non_Commercial_Schema__c ncs = [select id from csoe__Non_Commercial_Schema__c where name =: ncsName  LIMIT 1];
            return ncs;
        }catch(Exception e){
            system.debug('Exception in fetchNCSInstance ' + e);
            return null;
        }
    }
    
//----- Delete Mobility NCS -----//
    public String deleteExistingNCS(String rootConfigId, String ncsName,List<String> deleteList){
     try{
         List<NumberNCSMobilityDTO.Configuration> ncsConfigList = new List<NumberNCSMobilityDTO.Configuration>();
         csoe__Non_Commercial_Schema__c ncs = [select id from csoe__Non_Commercial_Schema__c where name =: ncsName LIMIT 1];
         if(ncs!=null){
             List<String> reservedNumbersList = new List<String>();
            for(Attachment att : [select id,body from attachment where ParentId  =:rootConfigId AND name LIKE '%MobileNumberManagementv1_schema%']){ //EDGE-84670
                String jsonStr = att.body.toString();
                NumberNCSMobilityDTO ncsDTO = NumberNCSMobilityDTO.parse(jsonStr);
                for(NumberNCSMobilityDTO.Configuration config : ncsDTO.configurations){
                        if(config.MobileNumber != NULL && deleteList.contains(config.MobileNumber)){
                            reservedNumbersList.add(config.guid); 
                        }
                }
            }
             if(reservedNumbersList!=null && reservedNumbersList.size()>0){
                System.debug('reservedNumbersList::' + reservedNumbersList);
                List<Object> configList = new List<Object>();
                configList.addAll((List<Object>)reservedNumbersList);
                Map<String,Object> nce = new Map<String,Object>();
                nce.put('name',(Object) ncsName);
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
    
//----- Read Total Number Count from Mobility NCS -----//
    public Integer getTotalCountOfNumbers(String UCEConfigId){
        List<String> fnnList = new List<String>();
        List<String> rangeList = new List<String>();
        Integer numberCount = 0;
        try{
            for(attachment att : [select id,body from attachment where ParentId  =: UCEConfigId AND name LIKE '%MobileNumberManagementv1_schema%']){ //EDGE-84670
                String jsonStr = att.body.toString();
                NumberNCSMobilityDTO ncsDTO = NumberNCSMobilityDTO.parse(jsonStr);
                for(NumberNCSMobilityDTO.Configuration config : ncsDTO.configurations){
                    if(config.MobileNumber != NULL){
                        fnnList.add(config.MobileNumber);
                    }
                }
            }
            numberCount =  fnnList.size();
            return numberCount;
        }
        catch(Exception e){
            system.debug('Exception in getTotalCountOfNumbers ' + e);
            return 0;
        }
    }
//
//
//
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
    
//----- Update Existing NCS after Complete Status Notification from AMDOCS for nextGenUC Product -----//
    public void updateNCSForStatus(String rootConfigId){
        List<NumberNCSMobilityDTO.Configuration> numberList = new List<NumberNCSMobilityDTO.Configuration>();
        NumberNCSMobilityHelper ncs = new NumberNCSMobilityHelper();
        for(Attachment att : [select Id,Body FROM Attachment WHERE ParentId  =: rootConfigId AND name LIKE '%MobileNumberManagementv1_schema%']) //EDGE-84670
        {
            String jsonStr = att.body.toString();
            NumberNCSMobilityDTO ncsDTO = NumberNCSMobilityDTO.parse(jsonStr);
            for(NumberNCSMobilityDTO.Configuration config : ncsDTO.configurations){         
                if((config.status == Label.NumberStatus_RESERVED || config.status == Label.NumberStatus_TRANSITION)){
                    config.status = Label.NumberStatus_ACTIVE;
                }
            numberList.add(config);
        }
        System.debug('numberList::' + numberList);
        ncs.updateExistingNCS(rootConfigId,'MobileNumberManagementv1',numberList);
    }   
    }
}