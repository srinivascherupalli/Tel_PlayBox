/*************************************************************************************************************************************************
* Name         :   InflightProductUtilityForModular
* Description  :   To handle Inflight Basket Sync Operations
* Test Class   :   InflightSyncBatchTest

Sr.No.      Developer Name      Date            Story           Description
1.          Gokul/Pooja         01/02/2021      EDGE-192806     In-Flight: Basket to Opportunity line item sync framework enhancements
2.          Pooja               17/02/2021      EDGE-201199     Inflight Basket Chatter Notification framework
3.          Kamlesh             18/2/2021       EDGE-205509     Added failedBasketMap,Sync job id custom field in query
**************************************************************************************************************************************************/
public with sharing class InflightProductUtilityForModular {
    
    //public static Set<String> failedBasketIds = new Set<String>();
    //EDGE-205509
    public static Map<String,String> failedBasketMap = new Map<String,String>();

    /********************************************************************************************************************************************
    * Method Name:  syncInflightBasketWithOpportunity
    * Description:  This method is invoked from Class: InflighSyncBatch Method:start.
                    To SYNC the given basket in scope and to UNSYNC all the other baskets associated with the opportunity.
                    SYNC => Check synchronised fields and primary basket fields 
                    UNSYNC => Uncheck synchronised fields and primary basket fields
    ********************************************************************************************************************************************/
    public static void syncInflightBasketWithOpportunity(List<cscfga__Product_Basket__c> lstProductBasket) {
        Map<Id,cscfga__Product_Basket__c> mapUpdateProdBasket   =   new Map<Id,cscfga__Product_Basket__c>();
        Set<String> setOpportunityIds                           =   new Set<String>();
        if(!lstProductBasket.isEmpty()) {
            //SYNC Operation of the baskets
            for(cscfga__Product_Basket__c oPB : lstProductBasket) {                
                oPB.Primary_Basket__c                               =   true;
                oPB.csbb__Synchronised_with_Opportunity__c          =   true;
                oPB.csordtelcoa__Synchronised_with_Opportunity__c   =   true;                
                if(oPB.cscfga__Opportunity__c != null) {
                    setOpportunityIds.add(oPB.cscfga__Opportunity__c);                       
                }
                mapUpdateProdBasket.put(oPB.Id,oPB);
            }
            //UNSYNC Operations of the baskets
            if(!setOpportunityIds.isEmpty()) {
                List<cscfga__Product_Basket__c> lstUnSyncOldBaskets =   [SELECT Id, Primary_Basket__c, csbb__Synchronised_with_Opportunity__c,  
                                                                         csordtelcoa__Synchronised_with_Opportunity__c, cscfga__Opportunity__c
                                                                         FROM cscfga__Product_Basket__c
                                                                         WHERE cscfga__Opportunity__c IN:setOpportunityIds AND Id NOT IN: mapUpdateProdBasket.keySet()
                                                                         AND (csordtelcoa__Synchronised_with_Opportunity__c = true 
                                                                              OR csordtelcoa__Synchronised_with_Opportunity__c = true 
                                                                              OR Primary_Basket__c = true)]; 
                if(!lstUnSyncOldBaskets.isEmpty()) {
                    for(cscfga__Product_Basket__c oPB : lstUnSyncOldBaskets) { 
                        oPB.csbb__Synchronised_with_Opportunity__c        =   false;
                        oPB.csordtelcoa__Synchronised_with_Opportunity__c =   false;
                        oPB.Primary_Basket__c                             =   false;
                        mapUpdateProdBasket.put(oPB.Id,oPB);
                    } 
                }                                                                            
            }
            if (!mapUpdateProdBasket.isEmpty()) {
                update mapUpdateProdBasket.values();
            }
        }
    }   //End of syncBasketWithOpportunity()
    
    /********************************************************************************************************************************************
    * Method Name:  syncOLIs_InflightPC_Cancellation
    * Description:  This method is invoked from Class:InflighSyncBatch Method:execute.
                    Inflight Amend: On an Inflight basket if Add-On/New Devices or any of Charge Item is removed. 
                    On the basket sync with the existing opportunity, the OLI associated with the removed Charge item should be update to  
                    a. Won/Lost = Lost
                    b. Status = Deleted
                    c. Reparent OLI with new ProdConfigs and Attributes
                    d. Retain the pricing information (handled in method processOLIs)
    ********************************************************************************************************************************************/
    public static Map<String,ProdConfigOLIWrapper> syncOLIs_InflightPC_Cancellation(Map<String,String> mapCancelledPcIdNewPcId) {        
        Map<String,ProdConfigOLIWrapper> mapPcOliWrapper    =   new Map<String,ProdConfigOLIWrapper>();
        Map<String,String> mapNewPCIdAtrrCombi              =   new Map<String,String>();        
        if(mapCancelledPcIdNewPcId != null && mapCancelledPcIdNewPcId.size() > 0) {
            // Retrieving all the OLIs related to new productConfigs and replaced productConfigs found in Inflight Basket. 
            // New ProductConfigs Id is considered to handle re-sync of inflight basket.
            List<OpportunityLineItem> lstOLIs   =   new List<OpportunityLineItem>();
            Set<String> setPcIds                =   new Set<String>();
            setPcIds.addAll(mapCancelledPcIdNewPcId.keySet());
            setPcIds.addAll(mapCancelledPcIdNewPcId.values());
            lstOLIs.addAll(getOLIRelatedToProdConfigs(setPcIds));
            
            //Querying Attributes with LineItem as False related to new productConfigs found in Inflight Basket
            List<cscfga__Attribute__c> lstNewAttributes =   getAttributesList(new Set<String>(mapCancelledPcIdNewPcId.values()), new Set<String>{'LineItem'}, new Set<String>{'False'});                                         
            for(cscfga__Attribute__c oAttr: lstNewAttributes) {
                mapNewPCIdAtrrCombi.put((oAttr.cscfga__Product_Configuration__c+'_'+oAttr.Name),oAttr.Id);
            }
            
            //Iterating over OLI list to udpate the field Won/Lost=Lost, Status=Deleted and Reparent with new productCongfigs and attributes
            for(OpportunityLineItem oOLI : lstOLIs) {
                String attrName                 =   (oOLI.cscfga__Attribute__c!=null && oOLI.cscfga__Attribute__r.Name!=null ? oOLI.cscfga__Attribute__r.Name : '');
                String newPCId                  =   (mapCancelledPcIdNewPcId.containsKey(oOLI.Product_Configuration__c) ? mapCancelledPcIdNewPcId.get(oOLI.Product_Configuration__c) : oOLI.Product_Configuration__c);
                String newAttrId                =   (mapNewPCIdAtrrCombi.containsKey(newPCId+'_'+attrName) ? mapNewPCIdAtrrCombi.get(newPCId+'_'+attrName) : '');
                String orderType                =   (String.isNotBlank(oOLI.Order_Type__c) ? oOLI.Order_Type__c : '');
                if(!string.isBlank(newPCId) && !string.isBlank(newAttrId)){
                    ProdConfigOLIWrapper oPcWrapper =   new ProdConfigOLIWrapper('Inflight Cancel','Lost','Deleted',orderType,oOLI.Product_Configuration__c,newPCId,newAttrId,oOLI);
                    mapPcOliWrapper.put((newPCId+'_'+newAttrId),oPcWrapper); 
                }
            }       
        }
        return mapPcOliWrapper;
    }   //End of syncOLIs_InflightPC_Cancellation()
    
    /********************************************************************************************************************************************
    * Method Name:  syncOLIs_InflightPC_Modification
    * Description:  This method is invoked from Class:InflighSyncBatch Method:execute.
                    Inflight Amend: On an Inflight basket if any Charge Item is udpated
                    On the basket sync with the existing opportunity, the OLI associated with the removed Charge item should be update to  
                    a. Won/Lost = Won
                    b. Status = Modified
                    c. Reparent OLI with new ProdConfigs and Attributes
                    d. Update the pricing info accordingly (handled in method processOLIs)
    ********************************************************************************************************************************************/
    public static Map<String,ProdConfigOLIWrapper> syncOLIs_InflightPC_Modification(Map<String,String> mapModifiedPcIdNewPcId) {
        Map<String,ProdConfigOLIWrapper> mapPcOliWrapper        =   new Map<String,ProdConfigOLIWrapper>();
        Map<String,OpportunityLineItem> mapReplacedPCOLI        =   new Map<String,OpportunityLineItem>();
        Map<String,OpportunityLineItem> mapNewPCOLI             =   new Map<String,OpportunityLineItem>();
        if(mapModifiedPcIdNewPcId != null && mapModifiedPcIdNewPcId.size() > 0) {
            // Retrieving all the OLIs related to new productConfigs and replaced productConfigs found in Inflight Basket. 
            // New ProductConfigs Id is considered to handle re-sync of inflight basket.
            List<OpportunityLineItem> lstOLIs   =   new List<OpportunityLineItem>();
            Set<String> setPcIds                =   new Set<String>();
            setPcIds.addAll(mapModifiedPcIdNewPcId.keySet()); 
            setPcIds.addAll(mapModifiedPcIdNewPcId.values()); 
            lstOLIs.addAll(getOLIRelatedToProdConfigs(setPcIds));
            for(OpportunityLineItem oOLI : lstOLIs) {
                if(mapModifiedPcIdNewPcId.containsKey(oOLI.Product_Configuration__c)) {
                    mapReplacedPCOLI.put((oOLI.Product_Configuration__c+'_'+oOLI.cscfga__Attribute__r.name),oOLI); 
                } else {
                    if(oOLI.cscfga__Attribute__c!=null && oOLI.cscfga__Attribute__r.name != null) {
                        mapNewPCOLI.put((oOLI.Product_Configuration__c+'_'+oOLI.cscfga__Attribute__r.name),oOLI);
                    }
                }
            }
            //Querying Attributes with LineItem as False related to new productConfigs found in Inflight Basket
            List<cscfga__Attribute__c> lstOldAttributes         =   getAttributesList(mapModifiedPcIdNewPcId.keySet(), new Set<String>{'LineItem'}, new Set<String>{'True'});
            //Querying Attributes with LineItem as False,True related to new productConfigs found in Inflight Basket
            List<cscfga__Attribute__c> lstNewAttributes         =   getAttributesList(new Set<String>(mapModifiedPcIdNewPcId.values()), new Set<String>{'LineItem'}, new Set<String>{'False','True'});
            //Creating a set of old ProdConfig and Attribute name found in the original basket
            Set<String> setOldPCIdAttNameCombiOriginalBasket    =   new Set<String>();
            for(cscfga__Attribute__c oAttOld : lstOldAttributes) {
                setOldPCIdAttNameCombiOriginalBasket.add(oAttOld.cscfga__Product_Configuration__c+'_'+oAttOld.Name);
            }
            
            for(cscfga__Attribute__c oAttNew : lstNewAttributes) {
                String replacedPCId         =   (oAttNew.cscfga__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c!=null ? oAttNew.cscfga__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c : ''); 
                String newPCId              =   oAttNew.cscfga__Product_Configuration__c;
                String newAttId             =   oAttNew.Id;
                String newAttName           =   oAttNew.Name;
                String oldPCIdAttNameCombi  =   replacedPCId+'_'+newAttName;
                String newPCIdAttNameCombi  =   newPCId+'_'+newAttName;
                Boolean isNewAttLineItem    =   false;
                
                if(!oAttNew.cscfga__Attribute_Fields__r.isEmpty()) {
                    for(cscfga__Attribute_Field__c oAttNewFields : oAttNew.cscfga__Attribute_Fields__r) {
                        if(oAttNewFields.Name.equalsIgnoreCase('LineItem') && oAttNewFields.cscfga__Value__c.equalsIgnoreCase('True')) {
                            isNewAttLineItem    =   true;
                        }
                    }
                }
                
                if(!mapNewPCOLI.isEmpty() && mapNewPCOLI.containsKey(newPCIdAttNameCombi) && mapNewPCOLI.get(newPCIdAttNameCombi)!=null ) {
                    // If OLIs are associated with new ProductConfigs in inflight basket 
                    // If Attribute exists as lineItem in inflight basket and original basket ==> OLI Fields Won/Lost=Won, Status=Modified
                    // If Attribute exists as lineItem in inflight basket only ==> OLI Fields Won/Lost=Won, Status=Added
                    // If Attribute doesnt not exists as lineItem in inflight basket ==> OLI Fields Won/Lost=Lost, Status=Deleted
                    OpportunityLineItem oOLI    =   mapNewPCOLI.get(newPCIdAttNameCombi);
                    String orderType            =   (String.isNotBlank(oOLI.Order_Type__c) ? oOLI.Order_Type__c : '');
                    ProdConfigOLIWrapper oPcWrapper;
                    if(isNewAttLineItem) {
                        if(!setOldPCIdAttNameCombiOriginalBasket.isEmpty() && setOldPCIdAttNameCombiOriginalBasket.contains(oldPCIdAttNameCombi)) {
                            oPcWrapper  =   new ProdConfigOLIWrapper('Inflight Amend','Won','Modified',orderType,replacedPCId,newPCId,newAttId,oOLI);
                        } else {
                            oPcWrapper  =   new ProdConfigOLIWrapper('Inflight Amend','Won','Added',orderType,replacedPCId,newPCId,newAttId,oOLI);
                        }
                    } else {
                        oPcWrapper      =   new ProdConfigOLIWrapper('Inflight Amend','Lost','Deleted',orderType,replacedPCId,newPCId,newAttId,oOLI);
                    }
                    mapPcOliWrapper.put((newPCId+'_'+newAttId),oPcWrapper);
                } else if(!mapReplacedPCOLI.isEmpty() && mapReplacedPCOLI.containsKey(oldPCIdAttNameCombi) && mapReplacedPCOLI.get(oldPCIdAttNameCombi)!=null ) {
                    // If OLIs are associated with old ProductConfigs in inflight basket 
                    // If Attribute exists as lineItem in inflight basket and original basket ==> OLI Fields Won/Lost=Won, Status=Modified
                    // If Attribute doesnt not exists as lineItem in inflight basket and as lineItem in original basket ==> OLI Fields Won/Lost=Lost, Status=Deleted
                    if(!setOldPCIdAttNameCombiOriginalBasket.isEmpty() && setOldPCIdAttNameCombiOriginalBasket.contains(oldPCIdAttNameCombi)) {
                        OpportunityLineItem oOLI    =   mapReplacedPCOLI.get(oldPCIdAttNameCombi);
                        String orderType            =   (String.isNotBlank(oOLI.Order_Type__c) ? oOLI.Order_Type__c : '');
                        ProdConfigOLIWrapper oPcWrapper;
                        if(isNewAttLineItem) {
                            oPcWrapper  =   new ProdConfigOLIWrapper('Inflight Amend','Won','Modified',orderType,replacedPCId,newPCId,newAttId,oOLI);
                        } else {
                            oPcWrapper  =   new ProdConfigOLIWrapper('Inflight Amend','Lost','Deleted',orderType,replacedPCId,newPCId,newAttId,oOLI);
                        }
                        mapPcOliWrapper.put((newPCId+'_'+newAttId),oPcWrapper);
                    } 
                } else if(isNewAttLineItem) {
                    //If Attribute exists and LineItem in Inflight Basket and not in original basket, since no OLI is found.
                    // New OLI is inserted with Won/Lost=Won, Status=Added, parenting with new ProdConfigs and new Attribute
                    ProdConfigOLIWrapper oPcWrapper =   new ProdConfigOLIWrapper('Inflight Amend','Won','Added','New',replacedPCId,newPCId,newAttId,null);
                    mapPcOliWrapper.put((newPCId+'_'+newAttId),oPcWrapper);
                }
            }
        }
        return mapPcOliWrapper;
    }   //End of syncOLIs_InflightPC_Modification()

    /********************************************************************************************************************************************
    * Method Name:  syncOLIs_InflightPC_Modification
    * Description:  This method is invoked from Class:InflighSyncBatch Method:execute.
                    To handle OLI creation for New Configs added to the Inflight Basket. 
    ********************************************************************************************************************************************/
    public static Map<String,ProdConfigOLIWrapper> syncOLIs_InflightPC_New(Set<String> setNewPcIds) {
        Map<String,ProdConfigOLIWrapper> mapPcOliWrapper    =   new Map<String,ProdConfigOLIWrapper>();
        if(setNewPcIds != null && setNewPcIds.size() > 0) {
            Map<String,OpportunityLineItem> mapNewPCOLI =   new Map<String,OpportunityLineItem>();
            List<OpportunityLineItem> lstOLIs           =   new List<OpportunityLineItem>();
            lstOLIs.addAll(getOLIRelatedToProdConfigs(setNewPcIds));
            for(OpportunityLineItem oOLI : lstOLIs) {
                if(oOLI.Product_Configuration__c != null &&  oOLI.cscfga__Attribute__c != null && oOLI.cscfga__Attribute__r.name != null) {
                    mapNewPCOLI.put((oOLI.Product_Configuration__c+'_'+oOLI.cscfga__Attribute__c),oOLI);
                }
            }
            List<cscfga__Attribute__c> lstNewAttributes = getAttributesList(new Set<String>(setNewPcIds), new Set<String>{'LineItem'}, new Set<String>{'True'});
            for(cscfga__Attribute__c oAttNew : lstNewAttributes) {
                String newPCId              =   oAttNew.cscfga__Product_Configuration__c;
                String newAttId             =   oAttNew.Id;
                OpportunityLineItem oOLI    =   (mapNewPCOLI.containsKey(newPCId+'_'+newAttId) ? mapNewPCOLI.get(newPCId+'_'+newAttId) : null);
                String orderType            =   (oOLI !=null && String.isNotBlank(oOLI.Order_Type__c) ? oOLI.Order_Type__c : '');
                ProdConfigOLIWrapper oPcWrapper = new ProdConfigOLIWrapper('New','Won','Added',orderType,'',newPCId,newAttId,oOLI);
                mapPcOliWrapper.put(newPCId+'_'+newAttId,oPcWrapper);
            }
        }
        return mapPcOliWrapper;
    }
    
    /**********************************************************************************************************************************************************
    * Method Name:  getOLIRelatedToProdConfigs
    * Description:  This method is invoked from same class, methods: syncOLIs_InflightPC_Cancellation,syncOLIs_InflightPC_Modification,syncOLIs_InflightPC_New. 
                    To query all the OpportunityLineItem related to the ProdConfigs. 
    **********************************************************************************************************************************************************/
    private static List<OpportunityLineItem> getOLIRelatedToProdConfigs(Set<String> setProdConfigIds) {
        List<OpportunityLineItem> lstOLIs = new List<OpportunityLineItem>();
        //Querying OLIs related to new productConfigs and replaced productConfigs found in Inflight Basket. New productConfigs is considered to handle re-sync of inflight basket.
        lstOLIs = [SELECT Id,Name,Order_Type__c,Product_Configuration__c,OpportunityId,Product_Status__c,Status__c,cscfga__Attribute__c,
                    cscfga__Attribute__r.Name FROM OpportunityLineItem WHERE Product_Configuration__c IN :setProdConfigIds];
        return lstOLIs;
    }   //End of getOLIRelatedToProdConfigs()
    
    /**********************************************************************************************************************************************************
    * Method Name:  getAttributesList
    * Description:  This method is invoked from same class, methods: syncOLIs_InflightPC_Cancellation,syncOLIs_InflightPC_Modification,syncOLIs_InflightPC_New. 
                    To query all the LineItem attributes related to the ProdConfigs. 
    **********************************************************************************************************************************************************/
    //try to reuse attributeFieldSelectorHelper/attributeSelectorHelper
    private static List<cscfga__Attribute__c>  getAttributesList(Set<String> setProdConfigIds, Set<String> lineItems, Set<String> lineItemValue) {
        List<cscfga__Attribute__c>  listAttributes  =   new List<cscfga__Attribute__c>();
        String query    =   'SELECT Id,Name,cscfga__Line_Item_Description__c,cscfga__Product_Configuration__c,';
        query           +=  'cscfga__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c,';
        query           +=  '(SELECT Id,Name,cscfga__Value__c FROM cscfga__Attribute_Fields__r WHERE Name IN :lineItems AND cscfga__Value__c IN :lineItemValue)';
        query           +=  'FROM cscfga__Attribute__c ';
        query           +=  'WHERE Id IN (select cscfga__Attribute__c from cscfga__Attribute_Field__c WHERE Name IN :lineItems AND cscfga__Value__c IN :lineItemValue) ';
        query           +=  'AND cscfga__Product_Configuration__c IN: setProdConfigIds';
        listAttributes  =   Database.query(query);
        return listAttributes;         
    }   //End of getAttributesList()
    
    /********************************************************************************************************************************************
    * Method Name:  getAttributesList
    * Description:  This method is invoked from Class:ProductUtilityForModular, Method:createOppLineItemsNew.
                    To create/update OpportunityLineItems for the Inflight Basket  
    ********************************************************************************************************************************************/    
    public static void processOLIs(List<OpportunityLineItem> lstOLI,Map<String, InflightProductUtilityForModular.ProdConfigOLIWrapper> newPCIdOLIWrapperMap,list<opportunitylineitem> oldOLIList){
        List<OpportunityLineItem> upsertOLIList =   new List<OpportunityLineItem>();
        if(lstOLI != null && lstOLI.size() > 0) {
            for(OpportunityLineItem oli : lstOLI) { 
                if(newPCIdOLIWrapperMap.containsKey(oli.Product_Configuration__c+'_'+oli.cscfga__Attribute__c)) {
                    //OLI to update Id,PCId=NewPcId, Attribute = NewAttributeId, Won/Lost, Status
                    if(newPCIdOLIWrapperMap.get(oli.Product_Configuration__c+'_'+oli.cscfga__Attribute__c).oliRecord != null)
                        oli.id = newPCIdOLIWrapperMap.get(oli.Product_Configuration__c+'_'+oli.cscfga__Attribute__c).oliRecord.id;
                    if(newPCIdOLIWrapperMap.get(oli.Product_Configuration__c+'_'+oli.cscfga__Attribute__c).newProdConfigId != null)
                        Oli.Product_Configuration__c = newPCIdOLIWrapperMap.get(oli.Product_Configuration__c+'_'+oli.cscfga__Attribute__c).newProdConfigId;
                    if(newPCIdOLIWrapperMap.get(oli.Product_Configuration__c+'_'+oli.cscfga__Attribute__c).newAttributeId != null)
                        oli.cscfga__Attribute__c = newPCIdOLIWrapperMap.get(oli.Product_Configuration__c+'_'+oli.cscfga__Attribute__c).newAttributeId;
                    if(newPCIdOLIWrapperMap.get(oli.Product_Configuration__c+'_'+oli.cscfga__Attribute__c).oliStatus != null)
                        oli.Status__c = newPCIdOLIWrapperMap.get(oli.Product_Configuration__c+'_'+oli.cscfga__Attribute__c).oliStatus;
                    if(newPCIdOLIWrapperMap.get(oli.Product_Configuration__c+'_'+oli.cscfga__Attribute__c).wonLost != null)
                        oli.Product_Status__c = newPCIdOLIWrapperMap.get(oli.Product_Configuration__c+'_'+oli.cscfga__Attribute__c).wonLost;
                    if(newPCIdOLIWrapperMap.get(oli.Product_Configuration__c+'_'+oli.cscfga__Attribute__c).orderType != null && newPCIdOLIWrapperMap.get(oli.Product_Configuration__c+'_'+oli.cscfga__Attribute__c).orderType != '')
                        oli.Order_Type__c = newPCIdOLIWrapperMap.get(oli.Product_Configuration__c+'_'+oli.cscfga__Attribute__c).orderType;
                    upsertOLIList.add(oli);
                }                
            }    
        }
        if(oldOLIList!=null && oldOLIList.size() > 0) {
            upsertOLIList.addAll(oldOLIList);
        }       
        if(!upsertOLIList.isEmpty()){
            Database.UpsertResult[] rsltList    =   Database.upsert(upsertOLIList, false);
            Set<String> setFailedPcIds          =   new Set<String>();
            Set<String> setSuccessOliIds        =   new Set<String>();
            for (Database.UpsertResult sr : rsltList) {
                if(sr.isSuccess()) {
                    setSuccessOliIds.add(sr.getId());
                }
            }
            for(OpportunityLineItem oOLI : upsertOLIList) {
                if((oOLI.Id == null)  || (oOLI.Id != null && !setSuccessOliIds.contains(oOLI.Id)) && oOLI.Product_Configuration__c!=null) {
                    setFailedPcIds.add(oOLI.Product_Configuration__c);
                }
            }
             //EDGE:205509 Added cscfga__Product_Basket__r.sync_job_Id__c in query
            List<cscfga__Product_Configuration__c> lstProdConfigs = [SELECT cscfga__Product_Basket__c,cscfga__Product_Basket__r.sync_job_Id__c FROM cscfga__Product_Configuration__c WHERE Id IN:setFailedPcIds];
            for(cscfga__Product_Configuration__c ls :lstProdConfigs) {
               //EDGE-205509
               String jsonMessage = GenericUtilityClass.createSyncJobMessage(ls.cscfga__Product_Basket__r.sync_job_Id__c,'syncJobId',false,true);
               failedBasketMap.put(ls.cscfga__Product_Basket__c,jsonMessage ); 
               //END-205509
            }
        }   
    }   //End of processOLIs()

    /********************************************************************************************************************************************
    * Method Name:  updateOpportunityDetails
    * Description:  This method is invoked from Class:InflighSyncBatch Method:finish.
                    To update Opportunity details after sync operation of the Inflight Basket  
    ********************************************************************************************************************************************/    
    public static void updateOpportunityDetails(Set<String> setBasketIds) {
        if(setBasketIds!=null && setBasketIds.size() > 0) {
            Map<String,cscfga__Product_Basket__c> mapSyncedBasket   =   new Map<String,cscfga__Product_Basket__c>();
            Map<String,String> mapOppIdBasketId                     =   new Map<String,String>();
            //EDGE-205509 Creating Map to store updated sync job id message
            Map<String,String> updateSuncJobIdMap = new Map<String,String>();
            //EDGE:205509 Added sync_job_Id__c,cscfga__Opportunity__r.StageName 
            List<cscfga__Product_Basket__c> listProductBakset   =   [SELECT Id,sync_job_Id__c,cscfga__Opportunity__c,cscfga__total_contract_value__c,
                                                                    csordtelcoa__Basket_Stage__c,Primary_Basket__c,cscfga__Opportunity__r.StageName 
                                                                    FROM cscfga__Product_Basket__c WHERE Id IN:setBasketIds 
                                                                    AND Amend_Type__c = 'Commercial'
                                                                    AND csbb__Synchronised_with_Opportunity__c = true 
                                                                    AND csordtelcoa__Synchronised_with_Opportunity__c = true 
                                                                    AND Primary_Basket__c = true
                                                                    AND csordtelcoa__Basket_Stage__c = 'Enriched'
                                                                    ];
            for(cscfga__Product_Basket__c oPB : listProductBakset) {
                if(oPB.cscfga__Opportunity__c != null && oPB.cscfga__Opportunity__r.StageName!= Label.Opp_Stage_ClosedWon) {
                    mapSyncedBasket.put(oPB.Id,oPB);
                    mapOppIdBasketId.put(oPB.cscfga__Opportunity__c,oPB.Id);  
                } 
                //EDGE-205509
                String jsonMessage = GenericUtilityClass.createSyncJobMessage(oPB.sync_job_Id__c,'syncJobId',true,false); 
                if(!updateSuncJobIdMap.containsKey(oPB.Id) && String.isNotBlank(jsonMessage)) {
                        updateSuncJobIdMap.put(oPB.Id,jsonMessage);  
                  } 
            }
            
            if(!mapSyncedBasket.isEmpty() && !mapOppIdBasketId.isEmpty()) {
                List<InflightProcessHelper.ChatterFeedWrapper> feedsLst =   new List<InflightProcessHelper.ChatterFeedWrapper>();
                List<Opportunity> updateOppLst  =   new List<Opportunity>();
                String currentUserId            =   UserInfo.getUserId();
                String feedMessage              =   Label.ChatterFeed_BasketSubmitFailure;
                
                updateOppLst.addAll(BasketOpportunityUpdateHelper.updateOppOnInflightSync(mapSyncedBasket, mapOppIdBasketId.keySet()));
                if(!updateOppLst.isEmpty()){
                    
                    Database.SaveResult[] rsltList  =   Database.update(updateOppLst, false);
                    Set<String> setSuccessOppIds    =   new Set<String>();
                    for(Database.SaveResult sr : rsltList) {
                        if (sr.isSuccess()) {
                            setSuccessOppIds.add(sr.getId());
                        }
                    }
                    for(String oppId : mapOppIdBasketId.keySet()) {
                        if(!setSuccessOppIds.contains(oppId)) {
                            String basketId     =   mapOppIdBasketId.get(oppId);
                            List<String> params =   new List<String>{'{'+currentUserId+'}','{record:' + basketId + '}'};
                            feedsLst.add(new InflightProcessHelper.ChatterFeedWrapper(null,basketId,String.format(feedMessage, params)));
                            //EDGE-205509
                            String jsonMessage = GenericUtilityClass.createSyncJobMessage(updateSuncJobIdMap.get(basketId),'syncJobId',true,true); 
                            if(updateSuncJobIdMap.containsKey(basketId) && String.isNotBlank(jsonMessage)) {
                                updateSuncJobIdMap.put(basketId,jsonMessage);  
                              } 
                        }
                    }
                    if(feedsLst.size() > 0) {
                        InflightProcessHelper.inflightSubmitChatterNotification(feedsLst);
                    }                    
                }
            }
             //EDGE-205509
            if(updateSuncJobIdMap.size()>0) {
                ProductUtilityForModular.updateBasketwithJobId('','syncJobId',new Set<String>(),updateSuncJobIdMap); 
             }
        }   //End of if(setBasketIds!=null && setBasketIds.size() > 0) {
    }   //End of updateOpportunityDetails

    public class ProdConfigOLIWrapper {
        public String amendType;
        public String wonLost;
        public String oliStatus;
        public String orderType;
        public String replacedProgConfigId;
        public String newProdConfigId;
        public String newAttributeId;
        public OpportunityLineItem oliRecord;
        
        public ProdConfigOLIWrapper() {
            this.amendType              =   '';
            this.wonLost                =   '';
            this.oliStatus              =   '';
            this.orderType              =   '';
            this.replacedProgConfigId   =   '';
            this.newProdConfigId        =   '';
            this.newAttributeId         =   '';
            this.oliRecord              =   new OpportunityLineItem();
        }
        
        public ProdConfigOLIWrapper(String type, String wnlst, String status, String ordType, String replacePCId, String newPCId, String newAttrId, OpportunityLineItem oliRec ) {
            this.amendType              =   type;
            this.wonLost                =   wnlst;
            this.oliStatus              =   status;
            this.orderType              =   ordType;
            this.replacedProgConfigId   =   replacePCId;
            this.newProdConfigId        =   newPCId;
            this.newAttributeId         =   newAttrId;
            this.oliRecord              =   oliRec;
        }        
    }   //End of ProdConfigOLIWrapper
    
}   //End of InflightProductUtilityForModular