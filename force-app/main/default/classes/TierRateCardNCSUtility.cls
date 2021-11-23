/********************************************************
Class Name      :   TierRateCardNCSUtility
Test Class : TierRateCardNCSHelperTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Venkata Ramanan G     11/10/2019      EDGE-112869  Created for Rate Card population Framework
2.            Varun/Monali          12/12/2019      EDGE-123778  Uncommented attribute "externalId" in "populateConfigListToUpsert"
3.            Shubhi                12/5/2020       EDge-137067
********************************************************************/

public with sharing class TierRateCardNCSUtility {


    public List<Object> populateConfigListToUpsert(List<TierRateCardNCSDTO.Configuration> rateCardConfigList){
        try{
            List<Object> configList = new List<Object>();
            for(TierRateCardNCSDTO.Configuration conf : rateCardConfigList){
                Map<String, Object> config = new Map<String, Object>();
                config.put('rangeFrom', conf.rangeFrom );
                config.put('rangeTo', conf.rangeTo);
                config.put('price', conf.price);
                config.put('externalId', conf.externalId);  //EDGE-123778
                if(String.isNotBlank(conf.guid))
                    config.put('guid', conf.guid);  // EDge-137067
                 system.debug('EXTERNAL ID IN UTILITY -  ' + conf.externalId);
                configList.add((Object) config);
            }
            system.debug('updated ConfigList  ' + configList);
            return configList;
        }catch(Exception e){
            system.debug('Exception in populateConfigListToUpsert ' + e);
            return null;
        }
    }
    //Method to insert NCS attachment using the API
    public List<Object> createNewNCS(String rootConfigId, String ncsName, List<TierRateCardNCSDTO.Configuration> rateCardConfigList,csoe__Non_Commercial_Schema__c ncs){
        try{
            //fetch NumberManagementv1 from custom label
           // csoe__Non_Commercial_Schema__c ncs = fetchNCSInstance(ncsName);
            List<Object> configList = populateConfigListToUpsert(rateCardConfigList);
            System.debug('rootConfigId::'+rootConfigId);
            if(ncs != null && configList != null && configList.size()>0){
                List<Object> nceList = createNCSConfig(ncsName,ncs,configList);
                /*if(nceList!=null){
                    Map<Id,List<Object>> oeMap = new Map<Id, List<Object>>();
                    oeMap.put(rootConfigId, nceList);
                    return oeMap;
                    //csoe.API_1.createOEData(oeMap);
                    //return 'Success';
                }
            }*/
            
            return nceList;
           } 
           return null;
        }catch(Exception e){
            system.debug('Exception while creating new NCS ' + e);
            return null;
        }
    }
    //Method to fetch the NCS recods. Only schemas associated to PD will be considered
    public Map<String,csoe__Non_Commercial_Schema__c> fetchNCSInstance(List<String> ncsName){
        try{
            Map<String,csoe__Non_Commercial_Schema__c> ncsmap = new Map<String,csoe__Non_Commercial_Schema__c>();
            List<csoe__Non_Commercial_Schema__c> ncslst = [select id,csoe__Description__c,Name,(select id from csoe__Non_Commercial_Product_Associations1__r) from csoe__Non_Commercial_Schema__c where name in :ncsName];
            for(csoe__Non_Commercial_Schema__c ncs :ncslst){
                if(!ncs.csoe__Non_Commercial_Product_Associations1__r.isEmpty()){
                    ncsmap.put(ncs.Name,ncs);
            }}
            return ncsmap;
        }catch(Exception e){
            system.debug('Exception in fetchNCSInstance ' + e);
            return null;
        }
    }
    
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
}