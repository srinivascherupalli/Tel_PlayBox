/*************************************************************************************************************************************************
* Name         :   PostOrderUpdatestoHerokuBatch  
* Description  :   Sending AssetID__c to Heroku API.
* Test Class   :   PostOrderUpdatestoHerokuBatchTest

Sr.No.     Developer Name               Date            Story           Description
1.      Vamsi Krishna Vaddipalli    08/MAR/2021          EDGE-178892    Device Id to be updated in Heroku to enable quick search in solution console
**************************************************************************************************************************************************/
global with sharing class PostOrderUpdatestoHerokuBatch implements Database.Batchable<SObject>,Database.Stateful,Database.AllowsCallouts {
    
    public Set<Id> recordIdSet = new Set<Id>(); //Set to be used across the batch class
    public List<Id> solutionIdList = new List<Id>(); //
    Map<String,List<Id>> solutionResultMap = new Map<String,List<Id>>(); 
    Map<String,Set<Id>> inputMap = new Map<String,Set<Id>>();
    String startKey ;
    String executeKey;
    String finishKey;
    global PostOrderUpdatestoHerokuBatch(Set<Id> inputIds,String argStartKey,String argExecuteKey,String argFinishKey) {
        if(!inputIds.isEmpty())
        { 
            recordIdSet.addAll(inputIds);
            inputMap.put('startRecordId',inputIds);
            this.startKey = String.isNotEmpty(argStartKey) ? argStartKey : 'Incomplete'; 
            this.executeKey = String.isNotEmpty(argExecuteKey) ? argExecuteKey : 'Incomplete'; 
            this.finishKey = String.isNotEmpty(argFinishKey) ? argFinishKey : 'Incomplete';
        }
    } 
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        PostOrderUpdatestoHerokuHelper startInstance = new PostOrderUpdatestoHerokuHelper();
        String query = (String)startInstance.call(startKey,inputMap);
        return Database.getQueryLocator(query); 
    }
    
    global void execute (Database.BatchableContext bc,List<SObject> scope)
    {
        Map<String,List<Asset>> mapExecuteRecords = new Map<String,List<Asset>>();
        if(scope != null && !scope.isEmpty())
        {
            mapExecuteRecords.put('executeRecordId',scope);
            PostOrderUpdatestoHerokuHelper executeInstance = new PostOrderUpdatestoHerokuHelper();
            Map<String,List<Id>> tempResultMap = (Map<String,List<Id>>)executeInstance.call(executeKey,mapExecuteRecords);
            solutionResultMap = (Map<String,List<Id>>)CustomCollectionUtility.copyMap(solutionResultMap,tempResultMap);
        }
    }
    
    global void finish (Database.BatchableContext bc)
    {
        Map<String,List<Id>> finishProcessMap;
        if(solutionResultMap != null && !solutionResultMap.isEmpty()){finishProcessMap= solutionResultMap;}
        else{finishProcessMap = new Map<String,List<Id>>();}
        finishProcessMap.put('startRecordId',new List<Id>(recordIdSet));
        PostOrderUpdatestoHerokuHelper finishInstance = new PostOrderUpdatestoHerokuHelper();
        finishInstance.call(finishKey,finishProcessMap);
    }
}