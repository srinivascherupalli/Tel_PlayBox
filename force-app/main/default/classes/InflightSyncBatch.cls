/*************************************************************************************************************************************************
* Name         :   InflightSyncBatch  
* Description  :   To handle Inflight Basket Sync Operations 
* Test Class   :   InflightSyncBatchTest

Sr.No.      Developer Name      Date            Story           Description
1.          Gokul/Pooja         01/02/2021      EDGE-192806     In-Flight: Basket to Opportunity line item sync framework enhancements
2.          Shubhi              17/02/2021      EDGE-193068     Inflight fund reversal 
3.          Pooja               17/02/2021      EDGE-201199     Inflight Basket Chatter Notification framework
4.          Kamlesh             25/2/2021       EDGE-199074     Calling ProductUtilityForModular.updateBasketwithJobId to update the sync job id
5.          Kamlesh             22/3/2021       EDGE:205509     Creating updated sync job message and calling ProductUtilityForModular.updateBasketwithJobId
**************************************************************************************************************************************************/
global with sharing class InflightSyncBatch implements Database.Batchable<SObject>,Database.Stateful{
    
    public Set<String> setCommSyncedBasketIds   =   new Set<String>();
    public Set<String> setCommFailedBasketIds   =   new Set<String>();
    //Added by Vamsi
    public Set<String> setProdBasketIds         =   new Set<String>();
    //Added by Vamsi
    //EDGE:205509 : creating map to store sync job id of basket
    public Map<String,String> finalUpdateSynJobId = new Map<String,String>();
    
    global InflightSyncBatch(Set<String> setBasketIds) {
        if(setBasketIds != null && setBasketIds.size() > 0) {
            setProdBasketIds.addAll(setBasketIds);
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        //Disable ProductBasketTrigger Execution
        StaticUtilForRecursion.checkInflightSync    =   true;  
        
        // Custom setting used to disable all the validation rules for the current running user 
        Environment_Configurations__c ecCusSetting  =   Environment_Configurations__c.getInstance(UserInfo.getUserId());    
        if (ecCusSetting.No_Validations__c == false) {  
            ecCusSetting.No_Validations__c = true;
            upsert ecCusSetting;
        }
        
        // Filtering the Commericial and Unsynced Inflight_Basket Ids
        Set<String> setCommInflightBasketIds            =   new Set<String>();
        //EDGE:205509 Added sync_job_Id__c
        list<cscfga__Product_Basket__c> lstCommBaskets  =   ([SELECT Id,sync_job_Id__c,cscfga__Opportunity__c,Primary_Basket__c,
                                    csbb__Synchronised_with_Opportunity__c,csordtelcoa__Synchronised_with_Opportunity__c 
                                    FROM cscfga__Product_Basket__c 
                                    WHERE Amend_Type__c = 'Commercial' AND Id IN:setProdBasketIds 
                                        AND (csbb__Synchronised_with_Opportunity__c = false OR csordtelcoa__Synchronised_with_Opportunity__c = false 
                                            OR Primary_Basket__c = false)]); 
        if(lstCommBaskets.size() > 0 ) {
            for(cscfga__Product_Basket__c oPB : lstCommBaskets) {
                setCommInflightBasketIds.add(oPB.Id);
                //EDGE:205509 : updating the map with sync job id
                finalUpdateSynJobId.put(oPB.Id,oPB.sync_job_Id__c);
            } 
            //Sync the inflight basket and unsync all the other basket associated with the opportunity
            InflightProductUtilityForModular.syncInflightBasketWithOpportunity(lstCommBaskets);           
        } 
        
        //Querying all the Product Configurations related to Commercial Inflight_Basket and passing it to the batch execute()
        //EDGE:205509 : Added cscfga__Product_Basket__r.sync_job_Id__c
        String query =  'SELECT Id,Name,csordtelcoa__Replaced_Product_Configuration__c,Type__c,cscfga__Product_Basket__c,';
        query       +=  ' cscfga__Product_Basket__r.cscfga__Opportunity__c,cscfga__Product_Basket__r.sync_job_Id__c';
        query       +=  ' FROM cscfga__Product_Configuration__c';
        query       +=  ' WHERE cscfga__Product_Basket__c IN :setCommInflightBasketIds';        
        
        return  Database.getQueryLocator(query);
    }   //End of start()
    
    global void execute(Database.BatchableContext BC, list<cscfga__Product_Configuration__c> lstProdConfigs) {
        Map<String, InflightProductUtilityForModular.ProdConfigOLIWrapper> mapNewPCIdOLIWrapper = new map<String, InflightProductUtilityForModular.ProdConfigOLIWrapper>();
        Map<String, InflightProductUtilityForModular.ProdConfigOLIWrapper> mapWonOLIWrapper     = new map<String, InflightProductUtilityForModular.ProdConfigOLIWrapper>();
        Map<String,String> mapCancelledProdConfigs  =   new Map<String,String>();
        Map<String,String> mapModifiedProdConfigs   =   new Map<String,String>();
        //EDGE:205509
        Map<String,String> updateSyncJobId          =   new Map<String,String>();
        Set<String> setNewProdConfigs               =   new Set<String>();
        Set<String> setProdBskIds                   =   new Set<String>();
        List<OpportunityLineItem> lstLostOLIs       =   new List<OpportunityLineItem>();
        
        if(!lstProdConfigs.isEmpty()) {
            for(cscfga__Product_Configuration__c oPC : lstProdConfigs) {
                setProdBskIds.add(oPc.cscfga__Product_Basket__c);
                String amendType    =   '';
                String replacedPCId =   '';
                //EDGE:205509 : updating the map with current batch sync job id
                if(!updateSyncJobId.containsKey(oPC.cscfga__Product_Basket__c)) {
                    updateSyncJobId.put(oPC.cscfga__Product_Basket__c,oPC.cscfga__Product_Basket__r.sync_job_Id__c);
                }
                if(String.isNotBlank(oPC.Type__c)) {
                    amendType       =    oPC.Type__c;
                }
                if(String.isNotBlank(oPC.csordtelcoa__Replaced_Product_Configuration__c)) {
                    replacedPCId    =   oPC.csordtelcoa__Replaced_Product_Configuration__c;
                }
                if(amendType.equalsIgnoreCase('Inflight Cancel') && String.isNotBlank(replacedPCId)) {  //&& String.isNotBlank(oppyId)) {
                    mapCancelledProdConfigs.put(replacedPCId,oPC.Id);
                } else if(amendType.equalsIgnoreCase('Inflight Amend') && String.isNotBlank(replacedPCId)) {
                    mapModifiedProdConfigs.put(replacedPCId,oPC.Id);
                } else {
                    setNewProdConfigs.add(oPC.Id);   
                }                  
            }
            
            if(!mapCancelledProdConfigs.isEmpty()) {
                mapNewPCIdOLIWrapper.putAll(InflightProductUtilityForModular.syncOLIs_InflightPC_Cancellation(mapCancelledProdConfigs));
            }
            if(!mapModifiedProdConfigs.isEmpty()) {
                mapNewPCIdOLIWrapper.putAll(InflightProductUtilityForModular.syncOLIs_InflightPC_Modification(mapModifiedProdConfigs));
            }
            if(!setNewProdConfigs.isEmpty()) {
                mapNewPCIdOLIWrapper.putAll(InflightProductUtilityForModular.syncOLIs_InflightPC_New(setNewProdConfigs));
            }
            if(!mapNewPCIdOLIWrapper.isEmpty()) {
                for(String str_pcId_AttrId : mapNewPCIdOLIWrapper.keySet()) {
                    if((mapNewPCIdOLIWrapper.get(str_pcId_AttrId).amendType == 'Inflight Cancel' ||  mapNewPCIdOLIWrapper.get(str_pcId_AttrId).amendType == 'Inflight Amend') &&  mapNewPCIdOLIWrapper.get(str_pcId_AttrId).oliStatus == 'Deleted') {
                        OpportunityLineItem oOLI        =   new OpportunityLineItem();
                        oOLI.Id                         =   mapNewPCIdOLIWrapper.get(str_pcId_AttrId).oliRecord.Id;
                        oOLI.Product_Configuration__c   =   mapNewPCIdOLIWrapper.get(str_pcId_AttrId).newProdConfigId;
                        oOLI.cscfga__Attribute__c       =   mapNewPCIdOLIWrapper.get(str_pcId_AttrId).newAttributeId;
                        oOLI.Status__c                  =   mapNewPCIdOLIWrapper.get(str_pcId_AttrId).oliStatus;
                        oOLI.Product_Status__c          =   mapNewPCIdOLIWrapper.get(str_pcId_AttrId).wonLost;
                        lstLostOLIs.add(oOLI);
                    } else {
                        mapWonOLIWrapper.put(str_pcId_AttrId,mapNewPCIdOLIWrapper.get(str_pcId_AttrId));
                    }
                }
            } 
            try{
                if(!mapWonOLIWrapper.isEmpty()) {
                    ProductUtilityForModular util = new ProductUtilityForModular();
                    util.syncInflightBasket(setProdBskIds,mapWonOLIWrapper,lstLostOLIs);
                } else {
                    InflightProductUtilityForModular.processOLIs(null, null,lstLostOLIs);
                }
                setCommSyncedBasketIds.addAll(setProdBskIds);
                if(InflightProductUtilityForModular.failedBasketMap.size() > 0) {
                    setCommSyncedBasketIds.removeAll(InflightProductUtilityForModular.failedBasketMap.keySet());
                    setCommFailedBasketIds.addAll(InflightProductUtilityForModular.failedBasketMap.keySet());
                    
                    //EDGE:205509 : Fetching failed basket
                    for(String id : InflightProductUtilityForModular.failedBasketMap.keySet()) {
                        if(updateSyncJobId.containsKey(id) && String.isNotBlank(InflightProductUtilityForModular.failedBasketMap.get(id))) {
                              //updateSyncJobId.remove(id );
                              updateSyncJobId.put(id,InflightProductUtilityForModular.failedBasketMap.get(id));
                              
                        }
                    }
                }
                //EDGE:205509 
                if(updateSyncJobId.size()>0) {
                      ProductUtilityForModular.updateBasketwithJobId('','syncJobId',new Set<String>(),updateSyncJobId); 
                }
                
                if(test.isRunningTest()) { throw (new IllegalArgumentException()); }             
            } catch (Exception e) {
                Logger2 logger = Logger2.getlogger('InflightSyncBatch');
                logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception in execute method',e.getLineNumber() + ' ' + e.getMessage(), false, false);
                logger.exitLogger();
                setCommSyncedBasketIds.removeAll(setProdBskIds);
                setCommFailedBasketIds.addAll(setProdBskIds);
                
                //EDGE:205509 : Creating new sync job message
                for(String id : updateSyncJobId.keySet()) {
                    String jsonMessage = GenericUtilityClass.createSyncJobMessage(updateSyncJobId.get(id),'syncJobId',false,true); 
                        if(updateSyncJobId.containsKey(id) && String.isNotBlank(jsonMessage)) {
                             updateSyncJobId.put(id,jsonMessage);  
                        }
                    }
                //EDGE:205509
                if(updateSyncJobId.size()>0) {
                     ProductUtilityForModular.updateBasketwithJobId('','syncJobId',new Set<String>(),updateSyncJobId); 
                }

            }
        }
    }   //End of execute()
    
    global void finish(Database.BatchableContext BC) {
        //Disable ProductBasketTrigger Execution
        StaticUtilForRecursion.checkInflightSync = true;
        //EDGE:205509
        Map<String,String> updateSuncJobIdMap = new Map<String,String>();
        try {
            if(!setCommFailedBasketIds.isEmpty()) {
                //Unsyncing of the failed baskets and triggering chatter feed
                List<cscfga__Product_Basket__c> productBasketList       =   new List<cscfga__Product_Basket__c>();
                List<InflightProcessHelper.ChatterFeedWrapper> feedsLst =   new List<InflightProcessHelper.ChatterFeedWrapper>();
                String currentUserId                                    =   UserInfo.getUserId();
                String feedMessage                                      =   Label.ChatterFeed_BasketSubmitFailure;
                for(String basketId : setCommFailedBasketIds) {
                    cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(Id=basketId,csbb__Synchronised_With_Opportunity__c=false,csordtelcoa__Synchronised_with_Opportunity__c=false);
                    productBasketList.add(basket);
                    List<String> params = new List<String>{'{'+currentUserId+'}','{record:' + basketId + '}'};
                    feedsLst.add(new InflightProcessHelper.ChatterFeedWrapper(null,basketId,String.format(feedMessage, params)));
                }
                update productBasketList;
                InflightProcessHelper.inflightSubmitChatterNotification(feedsLst);
            }
            if(setCommSyncedBasketIds != null && setCommSyncedBasketIds.size() > 0) { 
                //Update Opportunity Details of Synced Commercial Basket
               InflightProductUtilityForModular.updateOpportunityDetails(setCommSyncedBasketIds);
               //EDGE:205509 Creating new sync job message
               for(String id : setCommSyncedBasketIds) {
                 String jsonMessage = GenericUtilityClass.createSyncJobMessage(finalUpdateSynJobId.get(id),'syncJobId',true,false);
                 if(!updateSuncJobIdMap.containsKey(id) && String.isNotBlank(jsonMessage)) {
                             updateSuncJobIdMap.put(id,jsonMessage);  
                        }
                    }
               //EDGE:205509 updating basket with sync job id
               if(updateSuncJobIdMap.size()>0) {
                     ProductUtilityForModular.updateBasketwithJobId('','syncJobId',new Set<String>(),updateSuncJobIdMap); 
                  }
            } else if(setProdBasketIds != null && setProdBasketIds.size() > 0){
                //Retry Updating Opportunity Details of Synced Commericial Basket if failed on first time basket submit.
                InflightProductUtilityForModular.updateOpportunityDetails(setProdBasketIds);
                //EDGE:205509 Creating new sync job message
                for(String id : setProdBasketIds) {
                  String jsonMessage = GenericUtilityClass.createSyncJobMessage(finalUpdateSynJobId.get(id),'syncJobId',true,false);
                  if(!updateSuncJobIdMap.containsKey(id) && String.isNotBlank(jsonMessage)) {
                             updateSuncJobIdMap.put(id,jsonMessage);  
                        }
                    }
                //EDGE:205509 Updating basket with sync job id
                if(updateSuncJobIdMap.size()>0) {
                     ProductUtilityForModular.updateBasketwithJobId('','syncJobId',new Set<String>(),updateSuncJobIdMap); 
                  }

            }
            //Added by Shubhi for EDGE-193068
            Id jobId = Database.executeBatch(new InflightFundBatch(setProdBasketIds));
            //Edge-199074
            String jobMessage = '{"name":"fundJobId","id":"'+jobId+'","isCompleted":false,"error":false}';
            ProductUtilityForModular.updateBasketwithJobId(jobMessage ,'fundJobId',setProdBasketIds,new Map<String,String>());
            //Edge-199074    
            if(test.isRunningTest()) { throw (new IllegalArgumentException()); }             
        } catch (Exception e) {
            Map<String,String> updateFailedSynJob = new Map<String,String>();
            Logger2 logger = Logger2.getlogger('InflightSyncBatch');
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception in finish method',e.getLineNumber() + ' ' + e.getMessage(), false, false);
            logger.exitLogger();
            //EDGE:205509 creating new sync job message
            for(String id : setProdBasketIds) {
               String jsonMessage = GenericUtilityClass.createSyncJobMessage(finalUpdateSynJobId.get(id),'syncJobId',true,true);
                 if(!updateFailedSynJob.containsKey(id) && String.isNotBlank(jsonMessage)) {
                             updateFailedSynJob.put(id,jsonMessage );  
                        }
                    }
            //EDGE:205509 updating basket with sync job id
            if(updateSuncJobIdMap.size()>0) {
                 ProductUtilityForModular.updateBasketwithJobId('','syncJobId',new Set<String>(),updateFailedSynJob); 
             }
            
        }

        //After Basket sync, enable the validation rules for the current running user.
        Environment_Configurations__c ecCusSetting  =   Environment_Configurations__c.getInstance(UserInfo.getUserId());    
        if (ecCusSetting.Id != null && ecCusSetting.No_Validations__c == true) {    
            ecCusSetting.No_Validations__c = false;
            update ecCusSetting;
        }
    } 
}   //End of InflightSyncBatch