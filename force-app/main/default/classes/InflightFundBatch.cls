/*************************************************************************************************************************************************
 *Name         :   InflightFundBatch  
 * Description  :   To handle Inflight funds 
 * Test Class   :   InflightFundBatchTest
    
 Sr.No.     Developer Name      Date            Story           Description
    1.      Shubhi V            17/FEB/2021     EDGE-193068     Inflight fund reversal(new)
    2.      shubhi v            12/03/2021      Edge-202203     error handling
**************************************************************************************************************************************************/
global  with sharing class InflightFundBatch implements Database.Batchable<cscfga__Product_Basket__c>,Database.Stateful {
    public class MyException extends Exception {}
   public String basketId ='';
   public List<cscfga__Product_Basket__c> lstOfProdBasket = new List<cscfga__Product_Basket__c>();
   public List<cscfga__Product_Basket__c> lstOfAllProdBasket = new List<cscfga__Product_Basket__c>();
   public cscfga__Product_Basket__c prodBasket = new cscfga__Product_Basket__c();
   //Added by Vamsi
   public Set<String> setProdBasketIds         =   new Set<String>();
   public List<cscfga__Product_Basket__c> basketSuccessList = new List<cscfga__Product_Basket__c>();
   public List<cscfga__Product_Basket__c> basketFailureList = new List<cscfga__Product_Basket__c>();
   public Map<String,String> finalUpdateSynJobId = new Map<String,String>(); 
   //Added by Vamsi
     public InflightFundBatch(Set<String> setProdBasketIds) {
         if(!setProdBasketIds.isEmpty()) {
             this.setProdBasketIds.addAll(setProdBasketIds); 
         }
     }
     public  Iterable<cscfga__Product_Basket__c> start(Database.BatchableContext bC)
     {
        for(cscfga__Product_Basket__c pb : Model_ProductBasket.getProductBasketAccount(setProdBasketIds)) {
            if(!pb.OF_Reversal_Inserted__c && pb.csbb__Synchronised_With_Opportunity__c){
                lstOfProdBasket.add(pb);
                system.debug('pb.sync_job_Id__c'+pb.sync_job_Id__c);
                
            }
            lstOfAllProdBasket.add(pb); // for final method
            finalUpdateSynJobId.put(pb.id,pb.sync_job_Id__c);
        }
        
        return lstOfProdBasket;
     }
     public void execute(Database.BatchableContext bC,List<cscfga__Product_Basket__c> lstOfProdBasket)
     {
            if(lstOfProdBasket != null && !lstOfProdBasket.isEmpty())
            {
                FundReversalhandler.insertTransactions(setProdBasketIds,lstOfProdBasket);
                if(FundReversalhandler.failureBasketList!=null && !FundReversalhandler.failureBasketList.isEmpty()){
                    basketFailureList.addAll(FundReversalhandler.failureBasketList); //Edge-202203 
                }
                if(FundReversalhandler.successBasketList!=null && !FundReversalhandler.successBasketList.isEmpty()){
                    basketSuccessList.addAll(FundReversalhandler.successBasketList); //Edge-202203 
                }
                system.debug('basketSuccessList-->'+basketSuccessList);
            }
     }
    public  void finish(Database.BatchableContext bC)
     {
        Map<String,String> updateJobIdMap = new Map<String,String>();
        Map<String,String> updateFailedJob = new Map<String,String>();
        try{
            //Edge-202203  shubhi start --------------- code to execute one fund 
            //if block t execute only if exceute method is success based on haserror if false than update basket else post chatter notification
            if(basketSuccessList!=null && !basketSuccessList.isEmpty()){
                List<cscfga__Product_Basket__c> basketFinalList = new List<cscfga__Product_Basket__c>();
                Set<String> successBaksetIdset=new Set<String>();
                for(cscfga__Product_Basket__c pb:basketSuccessList){
                    successBaksetIdset.add(pb.id);
                    pb.OF_Reversal_Inserted__c = true; 
                    basketFinalList.add(pb);
                    system.debug('pb.sync_job_Id__c'+finalUpdateSynJobId.get(pb.id));
                    String jsonMessage = GenericUtilityClass.createSyncJobMessage(finalUpdateSynJobId.get(pb.id),'fundJobId',true,false);
                    if(String.isNotBlank(jsonMessage)) {
                        updateJobIdMap.put(pb.id,jsonMessage);  
                    }
                }
                update basketFinalList;
                if(!updateJobIdMap.isEmpty()) {
                    ProductUtilityForModular.updateBasketwithJobId('','fundJobId',new Set<String>(),updateJobIdMap); 
                } 
                //Added by Shubhi for EDGE-193068/ Edge-202203  start --
                if(!successBaksetIdset.isEmpty()){
                    Id jobId = Database.executeBatch(new InflightSubmitBasketBatch(successBaksetIdset));
                    String jobMessage = '{"name":"submitJobId","id":"'+jobId+'","isCompleted":false,"error":false}';
                    ProductUtilityForModular.updateBasketwithJobId(jobMessage,'submitJobId',successBaksetIdset,new Map<String,String>());
                }
            }
            if(basketFailureList!=null && !basketFailureList.isEmpty()){
                //chatter notification code
                List<cscfga__Product_Basket__c> productBasketList       =   new List<cscfga__Product_Basket__c>();
                List<InflightProcessHelper.ChatterFeedWrapper> feedsLst =   new List<InflightProcessHelper.ChatterFeedWrapper>();
                for(cscfga__Product_Basket__c pb:basketSuccessList){
                    String currentUserId                                    =   UserInfo.getUserId();
                    String feedMessage                                      =   Label.ChatterFeed_BasketSubmitFailure;
                    List<String> params =   new List<String>{'{'+currentUserId+'}','{record:' + pb.id + '}'};
                    feedsLst.add(new InflightProcessHelper.ChatterFeedWrapper(null,pb.id,String.format(feedMessage, params)));
                    String jsonMessage = GenericUtilityClass.createSyncJobMessage(finalUpdateSynJobId.get(pb.id),'fundJobId',true,true);
                    if(String.isNotBlank(jsonMessage)) {
                        updateFailedJob.put(pb.id,jsonMessage );  
                    }
                }
                if(!updateFailedJob.isEmpty()) {
                    ProductUtilityForModular.updateBasketwithJobId('','fundJobID',new Set<String>(),updateFailedJob); 
                }
                if(feedsLst!=null && !feedsLst.isEmpty()) {
                    InflightProcessHelper.inflightSubmitChatterNotification(feedsLst);
                }  
            }
            if((lstOfProdBasket.isEmpty() && !lstOfAllProdBasket.isEmpty() )|| (basketSuccessList.isEmpty() && basketFailureList.isEmpty())){
                Set<String> baksetIdset=new Set<String>();
                for(cscfga__Product_Basket__c pb: lstOfAllProdBasket) {
                    String jsonMessage = GenericUtilityClass.createSyncJobMessage(finalUpdateSynJobId.get(pb.id),'fundJobId',true,false);
                    baksetIdset.add(pb.id);
                    if(!updateFailedJob.containsKey(pb.id) && String.isNotBlank(jsonMessage)) {
                        updateFailedJob.put(pb.id,jsonMessage );  
                    }
                }
                if(!updateFailedJob.isEmpty()) {
                    ProductUtilityForModular.updateBasketwithJobId('','fundJobId',new Set<String>(),updateFailedJob); 
                } 
                if(!baksetIdset.isEmpty()){
                    Id jobId = Database.executeBatch(new InflightSubmitBasketBatch(baksetIdset));
                    String jobMessage = '{"name":"submitJobId","id":"'+jobId+'","isCompleted":false,"error":false}';
                    ProductUtilityForModular.updateBasketwithJobId(jobMessage,'submitJobId',baksetIdset,new Map<String,String>());
                }    
            }
            if(Test.isRunningTest()) { 
                throw new MyException('My exception');
            }
            ////Edge-202203  shubhi end  --------------- 
        }catch (Exception e) {
            System.debug('InflightFundBatch:Finish error' + e.getLineNumber() + ' ' + e.getMessage());
            //chatter notification code
            //Edge-202203  shubhi start ---------------
            for(String id : setProdBasketIds) {
                String jsonMessage = GenericUtilityClass.createSyncJobMessage(finalUpdateSynJobId.get(id),'fundJobId',true,true);
                if(!updateFailedJob.containsKey(id) && String.isNotBlank(jsonMessage)) {
                    updateFailedJob.put(id,jsonMessage );  
                }
            }
            if(updateFailedJob.size()>0) {
                ProductUtilityForModular.updateBasketwithJobId('','fundJobId',new Set<String>(),updateFailedJob); 
            }
            ////Edge-202203  shubhi end  ---------------  
            Logger2 logger = Logger2.getlogger('InflightFundBatch');
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception in finish method',e.getLineNumber() + ' ' + e.getMessage(), false, false);
            logger.exitLogger();
        }
     }
 }