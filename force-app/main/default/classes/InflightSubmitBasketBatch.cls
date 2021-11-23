/*************************************************************************************************************************************************
 * Name         :   InflightSubmitBasketBatch  
 * Description  :   To handle Inflight Submit Basket functionality
 * Test Class   :   InflightSubmitBasketBatchTest
    
 Sr.No.     Developer Name      Date            Story           Description
    1.      Vamsi            05/FEB/2021      EDGE-199696     Align Colombo Submit Basket functionality with Istanbul framework
    2.      Aman Soni        12/MAR/2021      EDGE-202203     Chatter Feed Implementation  
    3.      Shubhi v         12/03/2021      Edge-202203     error handling
**************************************************************************************************************************************************/
global with sharing class InflightSubmitBasketBatch implements Database.Batchable<cscfga__Product_Basket__c>,Database.Stateful {
    public class MyException extends Exception {}
    Set<String> lstProdId = new Set<String>();
    List<cscfga__Product_Basket__c> lstOfProdBasket = new List<cscfga__Product_Basket__c>();
    List<cscfga__Product_Basket__c> basketSuccessList = new List<cscfga__Product_Basket__c>();
    public List<cscfga__Product_Basket__c> basketFailureList = new List<cscfga__Product_Basket__c>();
    public Map<String,String> finalUpdateSynJobId = new Map<String,String>(); 
    global InflightSubmitBasketBatch(Set<String> setProdBasketIds) {
        if(!setProdBasketIds.isEmpty()) {
            lstProdId.addAll(setProdBasketIds); 
        }
    }
    
    global Iterable<cscfga__Product_Basket__c> start(Database.BatchableContext bc)
    {
        for(cscfga__Product_Basket__c pb : Model_ProductBasket.getProductBasketAccount(lstProdId)) {
            if(pb.OF_Reversal_Inserted__c){
                lstOfProdBasket.add(pb);
            }
            finalUpdateSynJobId.put(pb.id,pb.sync_job_Id__c);
        }
        return lstOfProdBasket;
    }
    global void execute(Database.BatchableContext bc,List<cscfga__Product_Basket__c> lstOfProdBasket)
    {
        Map<String,String> updateSyncJobId          =   new Map<String,String>();
        if(lstOfProdBasket != null && !lstOfProdBasket.isEmpty()){
            //EDGE-202203  start---------------
            for(cscfga__Product_Basket__c prodBasket:lstOfProdBasket){
                try{
                    if(!updateSyncJobId.containsKey(prodBasket.id)) {
                        updateSyncJobId.put(prodBasket.id,prodBasket.sync_job_Id__c);
                    }
                    if(!test.isRunningTest()){
                        csordtelcoa.API_V1.applyInflightChanges(prodBasket.id,true);
                    }
                    basketSuccessList.add(prodBasket);
                    System.debug('prodBasket-->' +prodBasket);
                    if(test.isRunningTest()){
                        throw new MyException('My exception');
                    }      
                }catch(Exception e) {
                    for(String id : updateSyncJobId.keySet()) {
                        String jsonMessage = GenericUtilityClass.createSyncJobMessage(updateSyncJobId.get(id),'submitJobId',false,true); 
                        if(updateSyncJobId.containsKey(id) && String.isNotBlank(jsonMessage)) {
                            updateSyncJobId.put(id,jsonMessage);  
                        }
                    }
                    if(!updateSyncJobId.isEmpty()) {
                        System.debug('updateSyncJobId' +updateSyncJobId);
                        ProductUtilityForModular.updateBasketwithJobId('','submitJobId',new Set<String>(),updateSyncJobId); 
                    }
                    Logger2 logger = Logger2.getlogger('InflightSubmitBasketBatch');
                    logger.logMessages('batch details:'+lstOfProdBasket, '', '', 'Technical', 'Exception in order generationon',e.getMessage(), false, false);
                    logger.exitLogger();
                    basketFailureList.add(prodBasket);    
                }
            } //EDGE-202203 end
        }
    }
    
    global void finish(Database.BatchableContext bc)
    {
        Map<String,String> updateJobIdMap = new Map<String,String>();
        Map<String,String> updateFailedJob = new Map<String,String>();
        try{
            if(basketSuccessList!=null && !basketSuccessList.isEmpty())
            {
                List<cscfga__Product_Basket__c> prodBasketfinalList = new List<cscfga__Product_Basket__c>();
                for(cscfga__Product_Basket__c prodBasketfinal:basketSuccessList){
                    prodBasketfinal.csordtelcoa__Basket_Stage__c = 'Submitted'; 
                    prodBasketfinalList.add(prodBasketfinal);
                    String jsonMessage = GenericUtilityClass.createSyncJobMessage(finalUpdateSynJobId.get(prodBasketfinal.id),'submitJobId',true,false);
                    if(String.isNotBlank(jsonMessage)) {
                        updateJobIdMap.put(prodBasketfinal.id,jsonMessage);  
                    }
                }
                if(prodBasketfinalList!=null && !prodBasketfinalList.isEmpty()){
                    update prodBasketfinalList;
                }
                if(!updateJobIdMap.isEmpty()) {
                    ProductUtilityForModular.updateBasketwithJobId('','submitJobId',new Set<String>(),updateJobIdMap); 
                } 
                System.debug('prodBasketfinalList-->' +prodBasketfinalList);  
            }
            if(basketFailureList!=null && !basketFailureList.isEmpty()){
                ///EDGE-202203 || Start
                List<InflightProcessHelper.ChatterFeedWrapper> feedsLst =   new List<InflightProcessHelper.ChatterFeedWrapper>();
                for(cscfga__Product_Basket__c pb:basketFailureList){
                    //String basketId     =   pb.id;
                    String currentUserId=   UserInfo.getUserId();
                    String feedMessage  =   Label.ChatterFeed_BasketSubmitFailure;
                    List<String> params =   new List<String>{'{'+currentUserId+'}','{record:' + pb.id + '}'};
                    feedsLst.add(new InflightProcessHelper.ChatterFeedWrapper(null,pb.id,String.format(feedMessage, params)));
                    String jsonMessage = GenericUtilityClass.createSyncJobMessage(finalUpdateSynJobId.get(pb.id),'submitJobId',true,true);
                    if(String.isNotBlank(jsonMessage)) {
                        updateFailedJob.put(pb.id,jsonMessage );  
                    }
                }
                if(!updateFailedJob.isEmpty()) {
                    ProductUtilityForModular.updateBasketwithJobId('','submitJobId',new Set<String>(),updateFailedJob); 
                }
                if(feedsLst!=null && feedsLst.size() > 0) {
                    InflightProcessHelper.inflightSubmitChatterNotification(feedsLst);
                } 
                if(test.isRunningTest())throw new MyException('My exception');
                /////EDGE-202203 || End
            }
            if(lstOfProdBasket.isEmpty() || (basketSuccessList!=null && basketSuccessList.isEmpty() && basketFailureList!=null && basketFailureList.isEmpty())){
                for(String id : lstProdId) {
                    String jsonMessage = GenericUtilityClass.createSyncJobMessage(finalUpdateSynJobId.get(id),'submitJobId',true,false);
                    if(!updateFailedJob.containsKey(id) && String.isNotBlank(jsonMessage)) {
                        updateFailedJob.put(id,jsonMessage );  
                    }
                }
                System.debug('lstProdId-->' +lstProdId);  
                if(!updateFailedJob.isEmpty()) {
                    ProductUtilityForModular.updateBasketwithJobId('','submitJobId',new Set<String>(),updateFailedJob); 
                }     
            }
        }catch(Exception e) {
            Map<String,String> updateFailedSynJob = new Map<String,String>();
            Logger2 logger = Logger2.getlogger('InflightSubmitBasketBatch');
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception in finish method',e.getLineNumber() + ' ' + e.getMessage(), false, false);
            logger.exitLogger();
            List<InflightProcessHelper.ChatterFeedWrapper> feedsLst =   new List<InflightProcessHelper.ChatterFeedWrapper>();
            for(String id : lstProdId) {
                String jsonMessage = GenericUtilityClass.createSyncJobMessage(finalUpdateSynJobId.get(id),'submitJobId',true,true);
                if(!updateFailedSynJob.containsKey(id) && String.isNotBlank(jsonMessage)) {
                    updateFailedSynJob.put(id,jsonMessage );  
                }
                String currentUserId=   UserInfo.getUserId();
                String feedMessage  =   Label.ChatterFeed_BasketSubmitFailure;
                List<String> params =   new List<String>{'{'+currentUserId+'}','{record:' +id + '}'};
                feedsLst.add(new InflightProcessHelper.ChatterFeedWrapper(null,id,String.format(feedMessage, params)));
            }
            if(updateFailedSynJob.size()>0) {
                ProductUtilityForModular.updateBasketwithJobId('','submitJobId',new Set<String>(),updateFailedSynJob); 
            }
            if(feedsLst!=null && feedsLst.size() > 0) {
                InflightProcessHelper.inflightSubmitChatterNotification(feedsLst);
            } 
              
        }
    }
}