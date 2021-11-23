/***********************************************************************************************************************************************************************
 * Class Name   :   ProductBasketTriggerHandler
 * Test Class   :   ProductBasketTriggerHandlerTest
========================================================================================================================================================================
Sr.No.  Developer Name          Date            Story           Description
1.      Pooja Bhat              22/09/2020      EDGE-178203     Technical Refactoring - Opportunity Sync - DML Operations
2.      Pooja Bhat              09/10/2020      EDGE-181579     Technical Refactoring - Enable Number Reservation for 500 configurations for Adaptive Mobility
3.      Ankit Goswami           02/11/2020      EDGE-181996     Tech Story-Product Basket Enahanchment
4.      Pooja Bhat              29/12/2020                      QA2 Regression Testing Fix, To uncheck Primary Basket flag on Draft Stage
5.      Payal Popat             4/02/2021       EDGE-198027     Sync functionality- Change Async Process of createOLI from future to batch
6.      Aman Soni               05/02/2021      EDGE-194029     cleanupServAddOnRecords - update service Add on Records against baskets
7.      Venkat T                3/03/2021       EDGE-206362     Defect Fix
8.      Kamlesh Kumar           25/02/2021      Edge-199074     updateBasketwithJobId method - removed from this class and added in ProductUtilityForModula
***********************************************************************************************************************************************************************/

public with sharing class ProductBasketTriggerHandler {
    
    private static String PRODUCT_BASKET_STAGE = 'Contract Accepted';

    public static void AfterInsertHandle(List<cscfga__Product_Basket__c> lstNewPB,Map<Id,cscfga__Product_Basket__c> mapNewPB) {
        System.debug(LoggingLevel.INFO, 'ProductBasketTriggerHandler.AfterInsertHandle.lstNewPB = ' + lstNewPB.size() + ' ' + lstNewPB);
        //UnSyncProductBasketsAfterInsertUpdate(lstNewPB, null);
        unSyncProductBasketAfterInsertUpdate(lstNewPB, mapNewPB, null, true);
        //updateOpportunityDetailsInsertUpdate(lstNewPB, mapNewPB, null, true);
    }

    public static void AfterUpdateHandle(List<cscfga__Product_Basket__c> lstNewPB, List<cscfga__Product_Basket__c> lstOldPB, Map<Id,cscfga__Product_Basket__c> mapNewPB, Map<Id,cscfga__Product_Basket__c> mapOldPB) {
        System.debug(LoggingLevel.INFO, 'ProductBasketTriggerHandler.AfterUpdateHandle.lstOldPB = ' + lstOldPB);
        System.debug(LoggingLevel.INFO, 'ProductBasketTriggerHandler.AfterUpdateHandle.lstNewPB = ' + lstNewPB);
        //ModifyBasketNamesForUpdate(lstNewPB,lstOldPB);
        //UnSyncProductBasketsAfterInsertUpdate(lstNewPB, lstOldPB);
        //DeleteOLIsProductDetailsAfterUpdate(lstNewPB,lstOldPB);
        //InsertOLIsProductDetailsAfterUpdate(lstNewPB, lstOldPB);
        unSyncProductBasketAfterInsertUpdate(lstNewPB, mapNewPB, mapOldPB, false);
        deleteOLIsProductDetailsAfterUpdate(mapNewPB, mapOldPB);
        insertOLIsProductDetailsAfterUpdate(mapNewPB, mapOldPB);
        updateOpportunityDetailsInsertUpdate(lstNewPB, mapNewPB, mapOldPB, false);
        revalidateProductBasketsAfterUpdate(lstNewPB, lstOldPB);
        
        //Added for EDGE-194029 by Aman Soni || Start
        if(!lstNewPB.isEmpty()){
            List<cscfga__Product_Basket__c> basketLst = new List<cscfga__Product_Basket__c>();
            for(cscfga__Product_Basket__c basket : lstNewPB){
                if(basket.csordtelcoa__Basket_Stage__c == 'Cancelled' && basket.cscfga__Opportunity__c != null){
                    basketLst.add(basket);      
                }
            }
            cleanupServAddOnRecords(basketLst);
        }
        //Added for EDGE-194029 by Aman Soni || End
    }

    /*Method Name   :   cleanupServAddOnRecords
    * Purpose       :   To unlink Basket and solution from Service Add On Records and unlink basket from Legacy Service when Basket is cancelled
    * Params        :   List<cscfga__Product_Basket__c> basketLst
    * Return Type   :   void
    * Called from   :   ProductBasketTriggerHandler - AfterUpdateHandle
    * EDGE(Sprint)  :   EDGE-194029(21.02)
    */
    public static void cleanupServAddOnRecords(List<cscfga__Product_Basket__c> basketLst){
        List<Service_Add_On__c> servAddOnLst = new List<Service_Add_On__c>();
        List<Service_Add_On__c> addOnLstToBeUpdated = new List<Service_Add_On__c>();
        if(!basketLst.isEmpty()){
            servAddOnLst = Model_ServiceAddOns.getServAddOnsForCleanUp(basketLst);
            if(!servAddOnLst.isEmpty()){
                for(Service_Add_On__c servAddOn : servAddOnLst){
                    servAddOn.Product_Basket__c = null;
                    servAddOn.Solution_Id__c = '';
                    if(servAddOn.Transaction_Type__c.equalsIgnoreCase('Migration')){
                        servAddOn.Status__c = 'Ready for Sync';
                    }else if(servAddOn.Transaction_Type__c.equalsIgnoreCase('Transition')){
                        servAddOn.Status__c = 'Pending';
                    }
                    addOnLstToBeUpdated.add(servAddOn);             
                }
                update addOnLstToBeUpdated; 
            }
        }
    }
    
    /*  * Method Name   :   unSyncProductBasketAfterInsertUpdate
        * Purpose       :   To unsync and uncheck primary basket flag, update opportunity details 
        * Params        :   trigger.newList, trigger.newMap, trigger.oldMap, boolean
        * Return Type   :   void
        * Called from   :   ProductBasketTriggerHandler - methods AfterInsertHandle, AfterUpdateHandle
    */
    private static void unSyncProductBasketAfterInsertUpdate(List<cscfga__Product_Basket__c> lstNewPB, Map<Id,cscfga__Product_Basket__c> mapNewPB, Map<Id,cscfga__Product_Basket__c> mapOldPB, Boolean isInsert) {
        Set<Id> setOpportunityId        =   new Set<Id>();
        Set<Id> setSyncedProdBasketId   =   new Set<Id>();
        if(!mapNewPB.isEmpty()) {
            for(cscfga__Product_Basket__c oPB : mapNewPB.values()) {
                if(oPB.cscfga__Opportunity__c != null){// added by ankit as part of EDGE-181996 
                    if(isInsert && (oPB.csordtelcoa__Synchronised_with_Opportunity__c || OPB.csbb__Synchronised_with_Opportunity__c)) {
                        setOpportunityId.add(oPB.cscfga__Opportunity__c);
                        setSyncedProdBasketId.add(oPB.Id);
                    } else if(!isInsert &&  mapOldPB.containsKey(oPB.Id) &&
                                ((oPB.csordtelcoa__Synchronised_with_Opportunity__c && !mapOldPB.get(oPB.Id).csordtelcoa__Synchronised_with_Opportunity__c)
                                || OPB.csbb__Synchronised_with_Opportunity__c && !mapOldPB.get(oPB.Id).csbb__Synchronised_with_Opportunity__c)) {
                        setOpportunityId.add(oPB.cscfga__Opportunity__c);
                        setSyncedProdBasketId.add(oPB.Id);
                    }                   
                }
            }
            if(!setSyncedProdBasketId.isEmpty() && !setOpportunityId.isEmpty()) {
                List<cscfga__Product_Basket__c> lstUnSyncOldBaskets = new List<cscfga__Product_Basket__c>();
                List<cscfga__Product_Basket__c> lstAllProductBasket = [SELECT Id,csbb__Synchronised_with_Opportunity__c,csordtelcoa__Synchronised_with_Opportunity__c, 
                                                                        cscfga__Opportunity__c,Primary_Basket__c
                                                                        FROM cscfga__Product_Basket__c
                                                                        WHERE cscfga__Opportunity__c IN:setOpportunityId 
                                                                        AND Id NOT IN:setSyncedProdBasketId
                                                                         AND csordtelcoa__Basket_Stage__c != 'Submitted'  //added exclude incase of submitted basket- as part of Defct fix EDGE-206362
                                                                        AND (csordtelcoa__Synchronised_with_Opportunity__c = true OR Primary_Basket__c = true)];    //Added: Condition Primary_Basket__c = true 29/12/2020 
                for (cscfga__Product_Basket__c tmpPB : lstAllProductBasket) {
                    tmpPB.csbb__Synchronised_with_Opportunity__c        =   false;
                    tmpPB.csordtelcoa__Synchronised_with_Opportunity__c =   false;
                    tmpPB.Primary_Basket__c                             =   false;
                    lstUnSyncOldBaskets.add(tmpPB);
                }
                if (lstUnSyncOldBaskets.size() > 0) {
                    update lstUnSyncOldBaskets;
                }
            }       
        }
    }   //End of unSyncProductBasketAfterInsertUpdate()

    /*  * Method Name   :   deleteOLIsProductDetailsAfterUpdate
        * Purpose       :   To delete all the Opportunity Products on Basket unsync
        * Params        :   trigger.newMap, trigger.oldMap
        * Return Type   :   void
        * Called from   :   ProductBasketTriggerHandler  - method AfterUpdateHandle
    */
    private static void deleteOLIsProductDetailsAfterUpdate(Map<Id,cscfga__Product_Basket__c> mapNewPB, Map<Id,cscfga__Product_Basket__c> mapOldPB) {
        Set<Id> setUnSyncedOpportunityId = new Set<Id>();
        for(cscfga__Product_Basket__c oPB : mapNewPB.values()) {
            if(oPB.cscfga__Opportunity__c !=null && (!oPB.csordtelcoa__Synchronised_with_Opportunity__c && mapOldPB.get(oPB.Id).csordtelcoa__Synchronised_with_Opportunity__c)
                || (!oPB.csbb__Synchronised_with_Opportunity__c && mapOldPB.get(oPB.Id).csbb__Synchronised_with_Opportunity__c)) {
                    setUnSyncedOpportunityId.add(oPB.cscfga__Opportunity__c);
            }
        }
        if(!setUnSyncedOpportunityId.isEmpty()) {
            ProductUtility.deleteOpportunityOLIs(setUnSyncedOpportunityId);
        }
    } //End of deleteOLIsProductDetailsAfterUpdate

    /*  * Method Name   :   insertOLIsProductDetailsAfterUpdate
        * Purpose       :   To delete all the Opportunity Products on Basket unsync
        * Params        :   trigger.newMap, trigger.oldMap
        * Return Type   :   void
        * Called from   :   ProductBasketTriggerHandler - method AfterUpdateHandle
    */
    private static void insertOLIsProductDetailsAfterUpdate(Map<Id,cscfga__Product_Basket__c> mapNewPB, Map<Id,cscfga__Product_Basket__c> mapOldPB) {
        Set<string> setSyncedNonModularBasketId = new Set<string>();        
        Set<string> setSyncedModularBasketId    = new Set<string>();        
        
        for(cscfga__Product_Basket__c oPB : mapNewPB.values()) {
            if(oPB.cscfga__Opportunity__c !=null && (oPB.csordtelcoa__Synchronised_with_Opportunity__c && !mapOldPB.get(oPB.Id).csordtelcoa__Synchronised_with_Opportunity__c)
                || (oPB.csbb__Synchronised_with_Opportunity__c && !mapOldPB.get(oPB.Id).csbb__Synchronised_with_Opportunity__c)) {
                    if(oPB.BasketOppType__c == 'Non Modular') {
                        setSyncedNonModularBasketId.add(oPB.Id);
                    } else {
                        setSyncedModularBasketId.add(oPB.Id);
                    }
            }
        }
        if (!setSyncedNonModularBasketId.isEmpty()) { //For Non Modular Opportunity OLIs are created in future methods to avoid CPU time limit
            ProductUtility.createOLIs(setSyncedNonModularBasketId);
        }
        if (!setSyncedModularBasketId.isEmpty() && !Test.isRunningTest()) {  //For Modular Opportunity OLIs are created in future methods to avoid CPU time limit
            if(label.oldOliProcess=='true') ProductUtility.createOLIsAsync(setSyncedModularBasketId);
            //EDGE-198027//Edge-199074
            //else productUtilityForModular.createOLIsAsync(setSyncedModularBasketId);
            else {
                createOLIsBatch objBatchJob = new createOLIsBatch(setSyncedModularBasketId);
                Id jobId = Database.executeBatch(objBatchJob);
                productUtilityForModular.updateBasketwithJobId(jobId,'',setSyncedModularBasketId,new Map<String,String>());
            }
            //END EDGE-198027
        }
    } //End of insertOLIsProductDetailsAfterUpdate

    /*  * Method Name   :   updateOpportunityDetailsInsertUpdate
        * Purpose       :   Update opportunity details 
        * Params        :   trigger.newList, trigger.newMap, trigger.oldMap, boolean
        * Return Type   :   void
        * Called from   :   ProductBasketTriggerHandler - methods AfterInsertHandle, AfterUpdateHandle
    */
    private static void updateOpportunityDetailsInsertUpdate(List<cscfga__Product_Basket__c> lstNewPB, Map<Id,cscfga__Product_Basket__c> mapNewPB, Map<Id,cscfga__Product_Basket__c> mapOldPB, Boolean isInsert) {
        Set<Id> setOpportunityId                                    =   new Set<Id>();
        Map<Id,cscfga__Product_Basket__c> mapSyncedProductBasket    =   new Map<Id,cscfga__Product_Basket__c>();
        if(!mapNewPB.isEmpty()) {
            for(cscfga__Product_Basket__c oPB : mapNewPB.values()) {
                if(oPB.cscfga__Opportunity__c !=null){// added by ankit as part of EDGE-181996
                    if(isInsert && oPB.csordtelcoa__Synchronised_with_Opportunity__c) {
                        setOpportunityId.add(oPB.cscfga__Opportunity__c);
                        mapSyncedProductBasket.put(oPB.Id,oPB);
                    } else if(!isInsert && mapOldPB.containsKey(oPB.Id) 
                                && ((oPB.BasketOppType__c == 'Non Modular' && oPB.csordtelcoa__Synchronised_with_Opportunity__c && !mapOldPB.get(oPB.Id).csordtelcoa__Synchronised_with_Opportunity__c) 
                                     || (oPB.csordtelcoa__Synchronised_with_Opportunity__c && oPB.csordtelcoa__Basket_Stage__c != mapOldPb.get(oPB.Id).csordtelcoa__Basket_Stage__c && oPB.csordtelcoa__Basket_Stage__c!='Submitted' && oPB.csordtelcoa__Basket_Stage__c!='Cancelled' && (oPB.csordtelcoa__Basket_Stage__c == 'Enriched' || oPB.csordtelcoa__Basket_Stage__c=='Contract Accepted')))
                            ) {
                        setOpportunityId.add(oPB.cscfga__Opportunity__c);
                        mapSyncedProductBasket.put(oPB.Id,oPB);
                    }
                }
            }
            //Updated by Romil to check Basketredemption amount.   
            if(!mapSyncedProductBasket.isEmpty() && !setOpportunityId.isEmpty()) {
                Environment_Configurations__c ecCusSetting  =   Environment_Configurations__c.getInstance(UserInfo.getUserId());    // Custom setting used to disable all the validation rules for the current running user. 
                if (ecCusSetting.No_Validations__c == false) {  
                    ecCusSetting.No_Validations__c = true;
                    upsert ecCusSetting;
                }
                BasketOpportunityUpdateHelper.updateOpportunityDetails(mapSyncedProductBasket,setOpportunityId);
                if (ecCusSetting.Id != null && ecCusSetting.No_Validations__c == true) {    //After Basket sync, enable the validation rules for the current running user.
                    ecCusSetting.No_Validations__c = false;
                    update ecCusSetting;
                }
            }       
        }
    }   //End of updateOpportunityDetailsInsertUpdate()

    //check if basket is Eligible For Revalidation
    public static void revalidateProductBasketsAfterUpdate(List<cscfga__Product_Basket__c> lstNewPB, List<cscfga__Product_Basket__c> lstOldPB) {
        Set<Id> newEligiblePbStageIdSet = new Set<Id>();
        Set<Id> oldEligibleOldPbStageIdSet = new Set<Id>();
        for (cscfga__Product_Basket__c pb : lstOldPB) {
            if (pb.csordtelcoa__Basket_Stage__c != PRODUCT_BASKET_STAGE ) {
                oldEligibleOldPbStageIdSet.add(pb.Id);         
            }
        }
        
        Map<Id, cscfga__Product_Basket__c> basketMapForRedemption = new Map<Id, cscfga__Product_Basket__c>();
        for (cscfga__Product_Basket__c pb : lstNewPB) {
            //System.debug('ProductBasketTriggerHandler ----->'+lstNewPB);
            if(pb.cscfga__Opportunity__c !=null){// added by ankit as part of EDGE-181996
                if (pb.csordtelcoa__Basket_Stage__c == PRODUCT_BASKET_STAGE && oldEligibleOldPbStageIdSet.contains(pb.Id)) {
                    newEligiblePbStageIdSet.add(pb.Id);             
                } else if (pb.csordtelcoa__Basket_Stage__c != PRODUCT_BASKET_STAGE) {      
                    //Updated by Romil to check EDGE-116121 Basketredemption amount.
                    basketMapForRedemption.put(pb.Id, pb);
                }
            }
        }
        //Updated By Romil
        if (!basketMapForRedemption.isEmpty()) {
            //passes in the map so that we don't need additional SOQLs to get basket stage
            BasketRedemptionHelper.updateRedemptionTransactions(basketMapForRedemption);            
        }
        // commented below call due to Spring 20 upgrade - 04/08/2020
        /* if (!newEligiblePbStageIdSet.isEmpty()) {
            System.debug(LoggingLevel.INFO, 'ProductBasketTriggerHandler.revalidateProductBasketsAfterUpdate.newEligiblePbStageIdSet = ' + newEligiblePbStageIdSet);
            revalidateProductConfigurations(newEligiblePbStageIdSet);
        } */
    }

    
  
    

    /*private static void InsertOLIsProductDetailsAfterUpdate(List<cscfga__Product_Basket__c> lstNewPB, List<cscfga__Product_Basket__c> lstOldPB) {
        System.debug(LoggingLevel.INFO, 'ProductBasketTriggerHandler.InsertOLIsProductDetailsAfterUpdate.lstOldPB = ' + lstOldPB);
        System.debug(LoggingLevel.INFO, 'ProductBasketTriggerHandler.InsertOLIsProductDetailsAfterUpdate.lstNewPB = ' + lstNewPB);
        set<string> setSyncedProductBasketId = new set<string>();
        set<string> setSyncedOppId = new set<string>();
        
        for (integer i = 0; i < lstNewPB.size(); ++i) {
            if ((lstNewPB[i].csordtelcoa__Synchronised_with_Opportunity__c) && (!lstOldPB[i].csordtelcoa__Synchronised_with_Opportunity__c)) {
                setSyncedProductBasketId.add(lstNewPB[i].Id);
                setSyncedOppId.add(lstNewPB[i].cscfga__Opportunity__c);
            }
        }
        
        if (setSyncedProductBasketId.size() > 0) {
            //before insert - delete the ones we know for sure will not be needed
            list<cscfga__Product_Basket__c> lstAllProductBasket = [SELECT Id, cscfga__Opportunity__c
                                                                   FROM cscfga__Product_Basket__c
                                                                   WHERE cscfga__Opportunity__c IN :setSyncedOppId];
            
            set<string> setUnsyncedProductBasketId = new set<string>();
            
            for (cscfga__Product_Basket__c tmpProductBasket : lstAllProductBasket) {
                if (!setSyncedProductBasketId.contains(tmpProductBasket.Id)) {
                    setUnsyncedProductBasketId.add(tmpProductBasket.Id);
                }
            }
            
            if (setUnsyncedProductBasketId.size() > 0)
                ProductUtility.DeleteHardOLIs(setUnSyncedProductBasketId);
            
            if (setSyncedProductBasketId.size() > 0)
                ProductUtility.CreateOLIs(setSyncedProductBasketId);
        }
    }*/


    /*private static void UnSyncProductBasketsAfterInsertUpdate(List<cscfga__Product_Basket__c> lstNewPB, List<cscfga__Product_Basket__c> lstOldPB) {
        //to be called after insert or after update,
        //if newly updated Product Baskets were synced then un-sync all others which have same Opportunity
        //if newly inserted Product Baskets are synced then un-sync all others which have same Opportunity
        set<string> setOpportunityId = new set<string>();
        set<string> setSyncedProductBasketId = new set<string>();
        Boolean Pass;
        
        for (integer i = 0; i < lstNewPB.size(); ++i) {
            Pass = false;
            
            if (lstOldPB == null) {
                if  (lstNewPB[i].csordtelcoa__Synchronised_with_Opportunity__c)
                    Pass = true;
            } else {
                if ((lstNewPB[i].csordtelcoa__Synchronised_with_Opportunity__c) && (!lstOldPB[i].csordtelcoa__Synchronised_with_Opportunity__c))
                    Pass = true;
            }
            
            if ((Pass) && (lstNewPB[i].cscfga__Opportunity__c != null)) {
                setOpportunityId.add(lstNewPB[i].cscfga__Opportunity__c);
                setSyncedProductBasketId.add(lstNewPB[i].Id);
                //Updated by Romil to check Basketredemption amount.   
                //AB: warning: consumes 2 SOQLs and 1 DML (Opp update)
                BasketRedemptionHelper.getBasket(lstNewPB[i].Name); 
            } 
        }
        
        if (setOpportunityId.size() > 0) {
            list<cscfga__Product_Basket__c> lstAllProductBasket = [SELECT Id, csordtelcoa__Synchronised_with_Opportunity__c, cscfga__Opportunity__c
                                                                   FROM cscfga__Product_Basket__c
                                                                   WHERE cscfga__Opportunity__c IN :setOpportunityId];
            
            list<cscfga__Product_Basket__c> lstProductBasketUpdate = new list<cscfga__Product_Basket__c>();
            
            for (cscfga__Product_Basket__c tmpPB : lstAllProductBasket) {
                if (!setSyncedProductBasketId.contains(tmpPB.Id)) {
                    if (tmpPB.csordtelcoa__Synchronised_with_Opportunity__c) {
                        tmpPB.csordtelcoa__Synchronised_with_Opportunity__c = false;
                        lstProductBasketUpdate.add(tmpPB);
                    }
                }
            }
            
            if (lstProductBasketUpdate.size() > 0)
                update lstProductBasketUpdate;
        }
    }*/

    
    /*
  private static void ModifyBasketNames(List<cscfga__Product_Basket__c> lstPB, map<Id,Opportunity> mapOpportunity)
    {
      set<string> setPBId = new set<string>();
      set<string> setOppId = new set<string>();

      for (cscfga__Product_Basket__c tmpPB : lstPB)
      {
        setPBId.add(tmpPB.Id);
      }

      if (setPBId.size()>0)
      {
        map<Id,cscfga__Product_Basket__c> mapProductBasketUpdate = new map<Id,cscfga__Product_Basket__c>([select Id,Name from cscfga__Product_Basket__c
          where Id in : setPBId]);

        list<cscfga__Product_Basket__c> lstProductBasketUpdate = new list<cscfga__Product_Basket__c>();

        for (cscfga__Product_Basket__c tmpPB : lstPB)
        {
          if (tmpPB.cscfga__Opportunity__c!=null)
          {
            if  (mapOpportunity.containsKey(tmpPB.cscfga__Opportunity__c))
            {
              Opportunity tmpOpportunity = mapOpportunity.get(tmpPB.cscfga__Opportunity__c);
              cscfga__Product_Basket__c tmpPBUpdate = mapProductBasketUpdate.get(tmpPB.Id);


              tmpPBUpdate.Name='Basket for ' + tmpOpportunity.Name;

              lstProductBasketUpdate.add(tmpPBUpdate);

              system.debug('***tmpPBUpdate.Name=' + tmpPBUpdate.Name);
            }
          }
        }

        system.debug('***lstProductBasketUpdate=' + lstProductBasketUpdate);
        if (lstProductBasketUpdate.size()>0)
        {
          update lstProductBasketUpdate;

        }
      }
    }
  */
    
    /*private static void DeleteOLIsProductDetailsAfterUpdate(List<cscfga__Product_Basket__c> lstNewPB, List<cscfga__Product_Basket__c> lstOldPB) {
        set<string> setUnSyncedProductBasketId = new set<string>();
        
        for (integer i = 0; i < lstNewPB.size(); ++i) {
            if ((!lstNewPB[i].csordtelcoa__Synchronised_with_Opportunity__c) && (lstOldPB[i].csordtelcoa__Synchronised_with_Opportunity__c)) {
                setUnSyncedProductBasketId.add(lstNewPB[i].Id);
            }
        }
        
        if (setUnSyncedProductBasketId.size() > 0) {
            ProductUtility.deleteHardOLIs(setUnSyncedProductBasketId);
        }
    }*/ 
    
    /*public static void revalidateProductConfigurations(Set<Id> productBasketIdSet) {
        System.debug(LoggingLevel.INFO, 'ProductBasketTriggerHandler.revalidateProductConfigurations.productBasketIdSet = ' + productBasketIdSet);
        List<cscfga__Product_Configuration__c> pcList = new List<cscfga__Product_Configuration__c>();
        
        pcList = [SELECT  id
                  FROM    cscfga__Product_Configuration__c
                  WHERE   cscfga__Product_Basket__c = :productBasketIdSet
                  AND     cscfga__Parent_Configuration__c = ''
                  AND     cscfga__Product_Definition__r.RecordType.Name != 'Package Definition'];
        
        Set<ID> productConfigurationIdSet = new Set<ID>();
        for (cscfga__Product_Configuration__c pc : pcList) {
            productConfigurationIdSet.add(pc.id);
        }
        Id jobID = cscfga.ProductConfigurationBulkActions.revalidateConfigurationsAsync(productConfigurationIdSet);
        //cscfga.ProductConfigurationBulkActions.revalidateConfigurations(productConfigurationIdSet);
        //System.debug('[ProductBasketTriggerHandler:revalidateProductConfigurations] AsyncJobID:' + jobID);
    }*/

  /*
  private static map<Id,Opportunity> GetmapOpportunityForUpdate(List<cscfga__Product_Basket__c> lstNewPB, List<cscfga__Product_Basket__c> lstOldPB)
  {
    set<string> setOppId = new set<string>();
    map<Id,Opportunity> mapOpportunity = new map<Id,Opportunity>();

    for (integer i=0;i<lstNewPB.size();++i)
    {
      if ((lstNewPB[i].cscfga__Opportunity__c!=lstOldPB[i].cscfga__Opportunity__c) || (lstNewPB[i].Name=='New Basket'))
      {

      if (lstNewPB[i].cscfga__Opportunity__c!=null)
        setOppId.add(lstNewPB[i].cscfga__Opportunity__c);

      }
    }

    if (setOppId.size()>0)
    {
      mapOpportunity = new map<Id,Opportunity>([select Id,Name from Opportunity
        where Id in : setOppId]);
    }

    return mapOpportunity;

  }
  */

  /*
  private static void ModifyBasketNamesForUpdate(List<cscfga__Product_Basket__c> lstNewPB, List<cscfga__Product_Basket__c> lstOldPB)
  {

    map<Id,Opportunity> mapOpportunity = GetmapOpportunityForUpdate(lstNewPB, lstOldPB);
    system.debug('before update mapOpportunity=' + mapOpportunity);
    ModifyBasketNames(lstNewPB,mapOpportunity);

  }
  */
}