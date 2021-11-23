/********************************************************************************
* Class Name  : C2O_ProductBasketTriggerHandler
* Description : This class is Handler Class to call the helper to execute the logic.   
* Created By  : Uday Dunna 
* Change Log  : Created
* Last Modified Date: 14/10/2021
********************************************************************************/
public with sharing class C2O_ProductBasketTriggerHandler{
    private List<cscfga__Product_Basket__c> newProdBasketList; 
    private List<cscfga__Product_Basket__c> oldProdBasketList;
    private Map<Id, cscfga__Product_Basket__c> newProductBasketMap;
    private Map<Id, cscfga__Product_Basket__c> productBasketOldMap;
    private static String PRODUCT_BASKET_STAGE = 'Contract Accepted';
      
    /***************************************************************************************
* Method Name - beforeInsert
* Description - This method is used to call the before Insert operation on record.
****************************************************************************************/
    public static void beforeInsert(List<cscfga__Product_Basket__c> newProdBasketList){
        //determine featureEligibility for logged in user. Params - metadataname, flowName
        if(FeatureEligibilityChecker.determineFeatureEligiblity('Telstra_Product_Basket','triggerBeforeInsert')){
            List<cscfga__Product_Basket__c> prodBasketInsertList = new List<cscfga__Product_Basket__c>();
            List<cscfga__Product_Basket__c> updateAccountonSyncList = new List<cscfga__Product_Basket__c>();
            for(cscfga__Product_Basket__c pdBt : newProdBasketList){
                if(pdBt.cscfga__Opportunity__c != null){ 
                    prodBasketInsertList.add(pdBt);
                }
                if(pdBt.csbb__Synchronised_with_Opportunity__c && pdBt.csbb__Account__c != null){
					updateAccountonSyncList.add(pdBt);                                                          
                }
            } 
            if(!prodBasketInsertList.isEmpty() && prodBasketInsertList.size() > 0){
                C2O_ProductBasketTriggerHelper.InsertProductBasket(prodBasketInsertList);
            }   
            if(!updateAccountonSyncList.isEmpty() && updateAccountonSyncList.size() > 0){
				C2O_ProductBasketTriggerHelper.updateAccountonProductBasketduringSync(updateAccountonSyncList);                
            }
        } 
    }
    
    /***************************************************************************************
* Method Name - beforeUpdate
* Description - This method is used to call the before Update operation on record.
****************************************************************************************/
    public static void beforeUpdate(List<cscfga__Product_Basket__c> newProdBasketList,Map<Id, cscfga__Product_Basket__c> productBasketOldMap){
        //determine featureEligibility for logged in user. Params - metadataname, flowName
        if(FeatureEligibilityChecker.determineFeatureEligiblity('Telstra_Product_Basket','triggerBeforeUpdate')){
            List<cscfga__Product_Basket__c> prodBasketUpdateList = new List<cscfga__Product_Basket__c>();  
            List<cscfga__Product_Basket__c> updateAccountonSyncList = new List<cscfga__Product_Basket__c>();
            for(cscfga__Product_Basket__c pdBast : newProdBasketList){
                if(pdBast.csordtelcoa__Basket_Stage__c != null || pdBast.Project_Complexity__c != null || (pdBast.Project_Complexity__c != null && pdBast.csordtelcoa__Basket_Stage__c != null)){
                    prodBasketUpdateList.add(pdBast);
                } 
                //Changed if condition by apple team 
                if((!productBasketOldMap.get(pdBast.Id).csbb__Synchronised_with_Opportunity__c && pdBast.csbb__Synchronised_with_Opportunity__c) && (pdBast.csbb__Account__c != null)){
					updateAccountonSyncList.add(pdBast);                                                          
                }
            }  
            if(!prodBasketUpdateList.isEmpty() && prodBasketUpdateList.size() > 0){
                C2O_ProductBasketTriggerHelper.updateBasketStage(prodBasketUpdateList);
            }  
            if(!updateAccountonSyncList.isEmpty() && updateAccountonSyncList.size() > 0){
				C2O_ProductBasketTriggerHelper.updateAccountonProductBasketduringSync(updateAccountonSyncList);                
            }
        }
    }
    
    /***************************************************************************************
* Method Name - afterInsert
* Description - This method is used to call the after Insert operation on record.
****************************************************************************************/
    public static void afterInsert(List<cscfga__Product_Basket__c> newProdBasketList) {   
        //determine featureEligibility for logged in user. Params - metadataname, flowName
        if(FeatureEligibilityChecker.determineFeatureEligiblity('Telstra_Product_Basket','triggerAfterInsert')){
            List<cscfga__Product_Basket__c> prodBasketNameUpdateList = new List<cscfga__Product_Basket__c>();
            List<cscfga__Product_Basket__c> prodBasketRecsForOneFund = new List<cscfga__Product_Basket__c>();
            List<Id> pbStatusCheckList = new List<Id>();
            Map<Id,cscfga__Product_Basket__c> unSyncProdBasketMap = new Map<Id,cscfga__Product_Basket__c>();
            for(cscfga__Product_Basket__c pdBas : [Select Id,Basket_Number__c,
                                                   cscfga__Opportunity__c,csordtelcoa__Synchronised_with_Opportunity__c,
                                                   csbb__Synchronised_with_Opportunity__c,csordtelcoa__Basket_Stage__c,
                                                   cscfga__Opportunity__r.Basket_Redemption_amount__c,csbb__Account__c
                                                   FROM cscfga__Product_Basket__c WHERE Id IN :newProdBasketList
                                                  ]){
                if(pdBas.Basket_Number__c != null){
                    prodBasketNameUpdateList.add(pdBas);
                }
               if(pdBas.csordtelcoa__Basket_Stage__c == 'CE POR Basket Review' ||
                  pdBas.csordtelcoa__Basket_Stage__c == 'Approved' ||
                  pdBas.csordtelcoa__Basket_Stage__c == 'Rejected'){
                    pbStatusCheckList.add(pdBas.Id);
                }
                
                if(pdBas.cscfga__Opportunity__c != null && (pdBas.csordtelcoa__Synchronised_with_Opportunity__c || pdBas.csbb__Synchronised_with_Opportunity__c)){
                    unSyncProdBasketMap.put(pdBas.Id,pdBas);
                }
                System.debug('debug log 79***'+pdBas.csordtelcoa__Basket_Stage__c+pdBas.cscfga__Opportunity__r.Basket_Redemption_amount__c+pdBas.cscfga__Opportunity__r.Basket_Redemption_amount__c);
                if((pdBas.csordtelcoa__Basket_Stage__c == PRODUCT_BASKET_STAGE) && 
                   (pdBas.cscfga__Opportunity__r.Basket_Redemption_amount__c > 0) &&
                   pdBas.csbb__Synchronised_With_Opportunity__c){
                    prodBasketRecsForOneFund.add(pdBas);
                }                                
            } 
            
            if(!prodBasketNameUpdateList.isEmpty() && prodBasketNameUpdateList.size() > 0){
                C2O_ProductBasketTriggerHelper.updateProductBasketName(prodBasketNameUpdateList);
            } 
            
            if(!unSyncProdBasketMap.isEmpty()){
                C2O_ProductBasketTriggerHelper.unSyncProductBasketAfterInsertUpdate(unSyncProdBasketMap);
            } 
            
            if(!prodBasketRecsForOneFund.isEmpty() && prodBasketRecsForOneFund.size() > 0){
                C2O_ProductBasketTriggerHelper.oneFundTransactionBasedOnExpiryDate(prodBasketRecsForOneFund);
            }
            
            if(!pbStatusCheckList.isEmpty() && pbStatusCheckList.size() > 0){
				ProductBasketChatterCls.sendChattertoCE(pbStatusCheckList);                
            }
        }         
    } 
    
    /***************************************************************************************
* Method Name - afterUpdate
* Description - This method is used to call the after Update operation on record.
****************************************************************************************/
    public static void afterUpdate(Map<Id, cscfga__Product_Basket__c> newProductBasketMap,Map<Id, cscfga__Product_Basket__c> productBasketOldMap){ 
        //determine featureEligibility for logged in user. Params - metadataname, flowName
        if(FeatureEligibilityChecker.determineFeatureEligiblity('Telstra_Product_Basket','triggerAfterUpdate')){ 
            Map<Id,cscfga__Product_Basket__c> prodBasketToUpdateMap = new Map<Id,cscfga__Product_Basket__c>();
            Map<Id,cscfga__Product_Basket__c> prodBasketMap = new Map<Id,cscfga__Product_Basket__c>();
            Map<Id,cscfga__Product_Basket__c> prodBasketUpdateMap = new Map<Id,cscfga__Product_Basket__c>();
            Map<Id,cscfga__Product_Basket__c> mapNewPB = new Map<Id,cscfga__Product_Basket__c>();
            List<cscfga__Product_Basket__c> UpdateQuoteLst = new List<cscfga__Product_Basket__c>();
            List<cscfga__Product_Basket__c> lstNewPB = new List<cscfga__Product_Basket__c>();
            List<cscfga__Product_Basket__c> prodBasketRecsForOneFunds = new List<cscfga__Product_Basket__c>();
            List<Id> pbStatusCheckList = new List<Id>();
            Set<Id> setUnSyncedOpportunityId = new Set<Id>(); 
            List<id> basketId = new List<id>();
            List<id> opportunityIds = new List<id>();
            Map<Id,Decimal> oppIdRedemptionAmountMap = new Map<Id,Decimal>();
            //List<String> changesToMonitor = new List<String>{'cscfga__Opportunity__c'};
            //Map<Id,Set<String>> recordsWithChanges = SYS_UtilityClass.getChangedFields(Trigger.oldMap,Trigger.newMap,changesToMonitor);
            for(cscfga__Product_Basket__c productBasket: newProductBasketMap.values()){
                opportunityIds.add(productBasket.cscfga__Opportunity__c);
            }
            for(Opportunity opp :[SELECT Id,Basket_Redemption_amount__c FROM Opportunity WHERE Id IN :opportunityIds] ){
                if(opp.Basket_Redemption_amount__c > 0){
                    oppIdRedemptionAmountMap.put(opp.Id,opp.Basket_Redemption_amount__c);
                }
            }
            for(cscfga__Product_Basket__c oPB : newProductBasketMap.values()){
                if(productBasketOldMap.containsKey(oPB.Id) &&
                   ((oPB.csordtelcoa__Synchronised_with_Opportunity__c && !productBasketOldMap.get(oPB.Id).csordtelcoa__Synchronised_with_Opportunity__c)
                    || OPB.csbb__Synchronised_with_Opportunity__c && !productBasketOldMap.get(oPB.Id).csbb__Synchronised_with_Opportunity__c)){
                        prodBasketMap.put(oPB.Id,oPB);
                        if(oPB.cscfga__Opportunity__c !=null){
                            prodBasketUpdateMap.put(oPB.Id,oPB);
                        }                            
                    }
                if(oPB.cscfga__Opportunity__c !=null && (!oPB.csordtelcoa__Synchronised_with_Opportunity__c && productBasketOldMap.get(oPB.Id).csordtelcoa__Synchronised_with_Opportunity__c)
                   || (oPB.csbb__Synchronised_with_Opportunity__c && !productBasketOldMap.get(oPB.Id).csbb__Synchronised_with_Opportunity__c)) {
                       setUnSyncedOpportunityId.add(oPB.cscfga__Opportunity__c);
                   }
                if(productBasketOldMap.containsKey(oPB.Id) && ((oPB.BasketOppType__c == 'Non Modular' && oPB.csordtelcoa__Synchronised_with_Opportunity__c && !productBasketOldMap.get(oPB.Id).csordtelcoa__Synchronised_with_Opportunity__c) 
                                                               || (oPB.csordtelcoa__Synchronised_with_Opportunity__c && oPB.csordtelcoa__Basket_Stage__c != productBasketOldMap.get(oPB.Id).csordtelcoa__Basket_Stage__c && oPB.csordtelcoa__Basket_Stage__c!='Submitted' && 
                                                                   oPB.csordtelcoa__Basket_Stage__c!='Cancelled' && (oPB.csordtelcoa__Basket_Stage__c == 'Enriched' || oPB.csordtelcoa__Basket_Stage__c=='Contract Accepted')))){
                                                                       mapNewPB.put(oPB.Id,oPB);  
                                                                   }
                if(oPB.cscfga__Opportunity__c !=null && oPB.csordtelcoa__Basket_Stage__c != PRODUCT_BASKET_STAGE){
                    lstNewPB.add(oPB);
                }
                if(oPB.csordtelcoa__Basket_Stage__c != productBasketOldMap.get(oPB.Id).csordtelcoa__Basket_Stage__c){
                    UpdateQuoteLst.add(oPB);
                }
                if((productBasketOldMap.get(oPB.Id).csordtelcoa__Basket_Stage__c != oPB.csordtelcoa__Basket_Stage__c) && (oPB.csordtelcoa__Basket_Stage__c == PRODUCT_BASKET_STAGE) && 
                   (oppIdRedemptionAmountMap.get(oPB.cscfga__Opportunity__c) != null && oppIdRedemptionAmountMap.get(oPB.cscfga__Opportunity__c) > 0 ) && 
                   oPB.csbb__Synchronised_With_Opportunity__c){   
                    prodBasketRecsForOneFunds.add(oPB); 
                }
                if((productBasketOldMap.get(oPB.Id).csordtelcoa__Basket_Stage__c != 'CE POR Basket Review' && oPB.csordtelcoa__Basket_Stage__c == 'CE POR Basket Review') ||
                  (productBasketOldMap.get(oPB.Id).csordtelcoa__Basket_Stage__c != 'Approved' && oPB.csordtelcoa__Basket_Stage__c == 'Approved') ||
                  (productBasketOldMap.get(oPB.Id).csordtelcoa__Basket_Stage__c != 'Rejected' && oPB.csordtelcoa__Basket_Stage__c == 'Rejected')){
                    pbStatusCheckList.add(oPB.Id);
                }
                if(oPB.AutoConfigStage__c != null && (productBasketOldMap.get(oPB.Id).AutoConfigStage__c != oPB.AutoConfigStage__c)){
                    basketId.add(oPB.Id);
                }
            }
            //DIGI-23388	
            if(!newProductBasketMap.values().isEmpty() && !productBasketOldMap.isEmpty()){
                C2O_ProductBasketTriggerHelper.autoSyncPlatformEvent(newProductBasketMap.values(),productBasketOldMap);
            }
            
            if(!prodBasketMap.isEmpty() && !StaticUtilForRecursion.checkInflightSync){
                C2O_ProductBasketTriggerHelper.unSyncProductBasketAfterInsertUpdate(prodBasketMap);
            }            
            
            if(!setUnSyncedOpportunityId.isEmpty() && setUnSyncedOpportunityId.size() > 0 && !StaticUtilForRecursion.checkInflightSync){
                C2O_ProductBasketTriggerHelper.deleteOLIsProductDetailsAfterUpdate(setUnSyncedOpportunityId);
            }
            
            if(!prodBasketUpdateMap.isEmpty() && !StaticUtilForRecursion.checkInflightSync){
                C2O_ProductBasketTriggerHelper.insertOLIsProductDetailsAfterUpdate(prodBasketUpdateMap);
            }           
            
            if(!mapNewPB.isEmpty() && !StaticUtilForRecursion.checkInflightSync){
                C2O_ProductBasketTriggerHelper.updateOpportunityDetailsInsertUpdate(mapNewPB);
            }
            
            if(!lstNewPB.isEmpty() && lstNewPB.size() > 0 && !StaticUtilForRecursion.checkInflightSync){
                C2O_ProductBasketTriggerHelper.revalidateProductBasketsAfterUpdate(lstNewPB);
            }
            
            if(!UpdateQuoteLst.isEmpty() && UpdateQuoteLst.size() > 0){
                C2O_ProductBasketTriggerHelper.updateOldQuotesToVoid(UpdateQuoteLst);
            }
            
            if(!productBasketOldMap.isEmpty() && !newProductBasketMap.isEmpty()){
                C2O_ProductBasketTriggerHelper.updateAttributeInfo(productBasketOldMap,newProductBasketMap);  
            } 
            
            if(!prodBasketRecsForOneFunds.isEmpty() && prodBasketRecsForOneFunds.size() > 0){
                C2O_ProductBasketTriggerHelper.oneFundTransactionBasedOnExpiryDate(prodBasketRecsForOneFunds);
            }
            
            if(!pbStatusCheckList.isEmpty() && pbStatusCheckList.size() > 0){
				ProductBasketChatterCls.sendChattertoCE(pbStatusCheckList);                
            }
            
            if(!basketId.isEmpty() && basketId.size() > 0){
				TransitionAutoConfigHelper.checkBasketAutoConfigStatus(basketId);                
            }
            
        }
    }
}