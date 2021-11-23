/*-----------------------------------------------------------------------------------------
EDGE        -87057
Class       -AssetTriggerHandler
Description -Trigger Handler Class for asset Trigger
Author      -Dheeraj Bhatt

 Vamsi 25MAR2021 EDGE-178892 Device Id to be updated in Heroku to enable quick search in solution console

============================================================================================
*  //EDGE-184694-Dheeraj Bhatt-removed the code for the update old service functionality as logic
                        has been moved to ServiceTriggerCustomHelper class
---------------------------------------------------------------------------------------------*/

public with sharing class AssetTriggerHandler {
    /*-----------------------------------------------------------------------------------------
    EDGE        -87057
    Method      -afterUpdate
    Description -Method for after trigger event
    Author      -Dheeraj Bhatt
    ---------------------------------------------------------------------------------------------*/    
        public static void afterUpdate(Map<id,Asset> newRecordsMap,Map<id,Asset> oldRecordsMap){
            List<asset> replacedAssetList=new List<asset>();
          //  List<csord__Service__c> replacedServiceList=new List<csord__Service__c>();
            Set<Id> assetIds = new Set<Id>();//Added by Vamsi for EDGE-178892 on 25Mar2021
            set<Id> replacedAssetIdSet=new set<Id>();
            set<Id> replacedAssetServiceIdSet=new set<Id>();
            for(Asset asst:newRecordsMap.values()){
                if(asst.Status.equalsIgnoreCase('Active') && oldRecordsMap.get(asst.id).status != asst.Status && asst.csordtelcoa__Replaced_Asset__c != NULL){
                   replacedAssetIdSet.add(asst.csordtelcoa__Replaced_Asset__c); 
                }
                //Added by vamsi for EDGE-178892 on 25Mar2021 starts
                if(asst.Status.equalsIgnoreCase('Active') && (String.isEmpty(asst.HerokuUpdateStatus__c) || asst.HerokuUpdateStatus__c.contains('Retry')))
                {
                  assetIds.add(asst.id);
                }
                //Added by vamsi for EDGE-178892 on 25Mar2021 ends
            } 
            /*Change status of replaced asset to InActive */
            if(replacedAssetIdSet.size() > 0){
                for(Asset replaceAsset:[SELECT id,status,csord__Service__c FROM Asset WHERE ID in :replacedAssetIdSet]){
                    replaceAsset.status=Constants.Asset_Status;
                    replacedAssetList.add(replaceAsset);
                }
            }
            if(replacedAssetList.size() > 0){
               update replacedAssetList;
            }
            //Added by vamsi for EDGE-178892 on 25Mar2021 starts
            if(assetIds != null && !assetIds.isEmpty())
            {
                String startKey = 'startAsset';
                String executeKey = 'executeAsset';
                String finishKey = 'finishAsset';
                EnvironmentVariable__c batchSize=EnvironmentVariable__c.getValues('batchSizeAssetUpdate');
                Id jobId = Database.executeBatch(new PostOrderUpdatestoHerokuBatch(assetIds,startKey,executeKey,finishKey), Integer.valueof(batchSize.value__c));
            }
            //Added by vamsi for EDGE-178892 on 25Mar2021 ends
           
        }
    }