/*************************************************************************************************************************************************
* Name         :   PostOrderUpdatestoHerokuHelper  
* Description  :   Reusing PostOrderUpdatestoHerokuBatch functionality.
* Test Class   :   PostOrderUpdatestoHerokuBatchTest

Sr.No.     Developer Name               Date            Story           Description
1.      Vamsi Krishna Vaddipalli    08/MAR/2021        EDGE-178892    Call batch class methods from callable class  
**************************************************************************************************************************************************/

public with sharing class PostOrderUpdatestoHerokuHelper implements Callable{
    // Call from Start method of batch class
    String startAsset() {
        String query = 'SELECT id,AssetID__c,HerokuUpdateStatus__c,Status,csord__Service__c,csord__Service__r.csordtelcoa__Product_Configuration__r.configGUID__c,csord__Service__r.cssdm__solution_association__c FROM Asset WHERE id IN : recordIdSet';
        return query;
    }
    
    // Call from Execute method of batch class
    Map<String,List<Id>> executeAsset(List<Asset> assetList) {
        Map<String,List<Id>> solutionResultMap = new Map<String,List<Id>>(); 
        Map<String,Map<String,Map<String,String>>> mapSolution = new Map<String,Map<String,Map<String,String>>>();
        Map<String,Map<String,String>> mapServiceConfig = new Map<String,Map<String,String>>();
        Map<String,String> attributeMap ;
        for(Asset asset:assetList)
        {
            attributeMap = new Map<String,String>();
            mapServiceConfig = new Map<String,Map<String,String>>();
            String guid = asset.csord__Service__r.csordtelcoa__Product_Configuration__r.configGUID__c;
            if(String.isNotBlank(guid)){
                if(mapSolution.containskey(asset.csord__Service__r.cssdm__solution_association__c)){
                    mapServiceConfig.putAll(mapSolution.get(asset.csord__Service__r.cssdm__solution_association__c));
                }
                if(mapServiceConfig!=null && mapServiceConfig.containsKey(guid))
                {
                    attributeMap = mapServiceConfig.get(guid);
                    attributeMap.put('DeviceID',attributeMap.get('DeviceID')+','+asset.AssetID__c); 
                }
                else{
                    attributeMap.put('DeviceID',asset.AssetID__c);
                }
                mapServiceConfig.put(guid,attributeMap);
                mapSolution.put(asset.csord__Service__r.cssdm__solution_association__c,mapServiceConfig);
            }
            
        }
        system.debug('mapSolution -->'+mapSolution);
        //Calling Heroku API 
        if(mapSolution != null && !mapSolution.isEmpty())
        {
        for(Id solutionId : mapSolution.keySet())
        {
            if(!String.isBlank(solutionId))
            {
                cssmgnt.API_1 api = new cssmgnt.API_1();
                String response = '';
                if(!test.isRunningTest())
                     response = api.updateConfigurations(solutionId, mapSolution.get(solutionId));//API will return response for success records.
                //Checking response from API and adding failed solution to list.
                JSONParser parser = JSON.createParser(response);
                if(response.contains(solutionId))
                {
                    List<Id> idList=new List<Id>();
                    if(solutionResultMap.containsKey('successSolutionId')){
                        idList= solutionResultMap.get('successSolutionId')!=null ? (List<Id>)solutionResultMap.get('successSolutionId') : new List<Id>();
                    }
                    idList.add(solutionId);
                    solutionResultMap.put('successSolutionId',idList);
                }else{
                    List<Id> idList=new List<Id>();
                    if(solutionResultMap.containsKey('failedSolutionId')){
                        idList= solutionResultMap.get('failedSolutionId')!=null ? (List<Id>)solutionResultMap.get('failedSolutionId') : new List<Id>();
                    }
                    idList.add(solutionId);
                    solutionResultMap.put('failedSolutionId',idList);  
                }
            }
        }
    }
        return solutionResultMap;
    }
    
    // Call from finish method of batch class
    String finishAsset(Map<String,Object> argMap) {
        //Final
        List<Asset> upadteAssetList = new List<Asset>();
        
        Map<String,List<Id>> finishProcessMap = (Map<String,List<Id>>)argMap;
        List<Id> startRecordList = finishProcessMap.get('startRecordId');
        List<Id> failedSolutionList = finishProcessMap.get('failedSolutionId');
        
        for(Asset assetRecord:[SELECT id,AssetID__c,HerokuUpdateStatus__c,Status,csord__Service__c,csord__Service__r.csordtelcoa__Product_Configuration__r.configGUID__c,csord__Service__r.cssdm__solution_association__c FROM Asset WHERE ID IN: startRecordList])
        {
            if(failedSolutionList!=null && failedSolutionList.contains(assetRecord.csord__Service__r.cssdm__solution_association__c))
            {
                String currentStatus = assetRecord.HerokuUpdateStatus__c; 
                if(currentStatus.equalsIgnoreCase('Failed'))
                    continue;
                else if(currentStatus.equalsIgnoreCase('Retry 2')){
                    assetRecord.HerokuUpdateStatus__c = 'Failed';
                    upadteAssetList.add(assetRecord);
                }
                else{
                    Integer retryCount = String.isNotEmpty(currentStatus) ? Integer.valueof(currentStatus.split(' ')[1]) +1 : 1;
                    assetRecord.HerokuUpdateStatus__c = 'Retry '+retryCount;
                    upadteAssetList.add(assetRecord);
                }
            }
            else{
                assetRecord.HerokuUpdateStatus__c = 'Success';
                upadteAssetList.add(assetRecord);
            }
        }
        Database.update(upadteAssetList, false);
        String ret = 'Success';
        return ret;
    }
    
    // Dispatch actual methods
    public Object call(String action, Map<String, Object> args) {
        switch on action {
            when 'startAsset' {
                return this.startAsset();
            }
            when 'executeAsset' {
                return this.executeAsset((List<Asset>)args.get('executeRecordId'));
            }
            when 'finishAsset' {
                return this.finishAsset(args);
            }
            when else {
                throw new PostOrderUpdatestoHerokuException('Method not implemented');
            }
        }
    }
    public class PostOrderUpdatestoHerokuException extends Exception{}
}