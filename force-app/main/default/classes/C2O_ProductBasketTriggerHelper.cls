/********************************************************************************
* Class Name  : C2O_ProductBasketTriggerHelper
* Description : C2O_ProductBasketTriggerHelper runs logic on Product configuration records which are filtered
based on certain filter conditions which are defined in handler
* Created By  : Uday Dunna 
* Change Log  : Created
* Date : 16/09/2021
********************************************************************************/
public with sharing class C2O_ProductBasketTriggerHelper { 
    private static String PRODUCT_BASKET_STAGE = 'Contract Accepted';
    private static String OFT_Accrual_RecordType  = Schema.SObjectType.OneFund_Transactions__c.RecordTypeInfosByName.get('Fund Allocation').RecordTypeId;
    private static String OFT_Redemption_RecordType  = Schema.SObjectType.OneFund_Transactions__c.RecordTypeInfosByName.get('Fund Redemptions').RecordTypeId;    
    public static void updateProductBasketName(List<cscfga__Product_Basket__c> productBasketRecsList){
        try{
            List<cscfga__Product_Basket__c> productBasketRecsToUpdate = new List<cscfga__Product_Basket__c>();
            for(cscfga__Product_Basket__c pb : [Select Id,Bakset_Number_Format__c FROM cscfga__Product_Basket__c Where Id IN :productBasketRecsList]){  
                cscfga__Product_Basket__c prodBasketRec = new cscfga__Product_Basket__c();
                prodBasketRec.Id = pb.Id;
                prodBasketRec.Description__c = null;
                prodBasketRec.Name = pb.Bakset_Number_Format__c; 
                productBasketRecsToUpdate.add(prodBasketRec);
            }        
            if(!productBasketRecsToUpdate.isEmpty()) update productBasketRecsToUpdate;
        } catch(Exception e){
            System.debug('Exception occurred in updateProductBasketName(): ' + e.getMessage());
            Map<String,Object> inputLogMap = new Map<String,Object>();
            inputLogMap.put('severity', C2O_ExceptionHandler.SEVERITY.HIGH); 
            inputLogMap.put('errorDescription', e.getMessage());
            inputLogMap.put('LoggingLevel.INFO', e.getStackTraceString()); 
            C2O_Utilities.logException(inputLogMap,false);
        }            
    }
    
    public static void unSyncProductBasketAfterInsertUpdate(Map<Id,cscfga__Product_Basket__c> mapNewPB) {
        Set<Id> setOpportunityId        =   new Set<Id>();
        Set<Id> setSyncedProdBasketId   =   new Set<Id>();
        
        if(!mapNewPB.isEmpty()){

           
            for(cscfga__Product_Basket__c oPB : mapNewPB.values()){
                if(oPB.cscfga__Opportunity__c != null)  setOpportunityId.add(oPB.cscfga__Opportunity__c);
                setSyncedProdBasketId.add(oPB.Id);

            }
            if(!setSyncedProdBasketId.isEmpty() && !setOpportunityId.isEmpty()) {
                List<cscfga__Product_Basket__c> lstUnSyncOldBaskets = new List<cscfga__Product_Basket__c>();
                List<cscfga__Product_Basket__c> lstAllProductBasket = [SELECT Id,csbb__Synchronised_with_Opportunity__c,csordtelcoa__Synchronised_with_Opportunity__c, 
                                                                       cscfga__Opportunity__c,Primary_Basket__c
                                                                       FROM cscfga__Product_Basket__c
                                                                       WHERE cscfga__Opportunity__c IN:setOpportunityId 
                                                                       AND Id NOT IN:setSyncedProdBasketId
                                                                       AND (csordtelcoa__Synchronised_with_Opportunity__c = true OR Primary_Basket__c = true)];    //Added 29/12/2020: Condition Primary_Basket__c = true 

                for (cscfga__Product_Basket__c tmpPB : lstAllProductBasket) {

                    tmpPB.csbb__Synchronised_with_Opportunity__c        =   false;
                    tmpPB.csordtelcoa__Synchronised_with_Opportunity__c =   false;
                    tmpPB.Primary_Basket__c                             =   false;
                    lstUnSyncOldBaskets.add(tmpPB);
                }
                if (lstUnSyncOldBaskets.size() > 0 ) {
                    update lstUnSyncOldBaskets;
                }
            }       
        }
    }  
    
    /*  * Method Name   :   deleteOLIsProductDetailsAfterUpdate
* Purpose       :   To delete all the Opportunity Products on Basket unsync
* Params        :   trigger.newMap, trigger.oldMap
* Return Type   :   void
* Called from   :   ProductBasketTriggerHandler  - method AfterUpdateHandle
*/
    public static void deleteOLIsProductDetailsAfterUpdate(Set<Id> setUnSyncedOpportunityId) {
        if(!setUnSyncedOpportunityId.isEmpty()) {
            ProductUtility.deleteOpportunityOLIs(setUnSyncedOpportunityId);
        }  
    }
    
    /*  * Method Name   :   insertOLIsProductDetailsAfterUpdate
* Purpose       :   To delete all the Opportunity Products on Basket unsync
* Params        :   trigger.newMap, trigger.oldMap
* Return Type   :   void
* Called from   :   ProductBasketTriggerHandler - method AfterUpdateHandle
*/
    public static void insertOLIsProductDetailsAfterUpdate(Map<Id,cscfga__Product_Basket__c> mapNewPB) {
        Set<string> setSyncedNonModularBasketId = new Set<string>();        
        Set<string> setSyncedModularBasketId    = new Set<string>();   
        for(cscfga__Product_Basket__c oPB : mapNewPB.values()) {            
            if(oPB.BasketOppType__c == 'Non Modular') {
                setSyncedNonModularBasketId.add(oPB.Id);
            } else {
                setSyncedModularBasketId.add(oPB.Id);
            }
        }
        if (!setSyncedNonModularBasketId.isEmpty()) { //For Non Modular Opportunity OLIs are created in future methods to avoid CPU time limit
            ProductUtility.createOLIs(setSyncedNonModularBasketId);
        }
        if (!setSyncedModularBasketId.isEmpty() && !Test.isRunningTest()) {  //For Modular Opportunity OLIs are created in future methods to avoid CPU time limit
            if(label.oldOliProcess=='true') ProductUtility.createOLIsAsync(setSyncedModularBasketId);
            // else productUtilityForModular.createOLIsAsync(setSyncedModularBasketId);
            else{//DIGI-1607 
                createOLIsBatch objBatchJob = new createOLIsBatch(setSyncedModularBasketId);
                Id jobId = Database.executeBatch(objBatchJob);
                productUtilityForModular.updateBasketwithJobId(jobId,'',setSyncedModularBasketId,new Map<String,String>());
            }
        }   
    }
    
    /*  * Method Name   :   updateOpportunityDetailsInsertUpdate
* Purpose       :   Update opportunity details 
* Params        :   trigger.newList, trigger.newMap, trigger.oldMap, boolean 
* Return Type   :   void
* Called from   :   ProductBasketTriggerHandler - methods AfterInsertHandle, AfterUpdateHandle
*/
    public static void updateOpportunityDetailsInsertUpdate(Map<Id,cscfga__Product_Basket__c> mapNewPB) {
        Set<Id> setOpportunityId                                    =   new Set<Id>();
        Map<Id,cscfga__Product_Basket__c> mapSyncedProductBasket    =   new Map<Id,cscfga__Product_Basket__c>();
        if(!mapNewPB.isEmpty()) {
            for(cscfga__Product_Basket__c oPB : mapNewPB.values()) {
                if(oPB.cscfga__Opportunity__c != null)   setOpportunityId.add(oPB.cscfga__Opportunity__c);
                mapSyncedProductBasket.put(oPB.Id,oPB);
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
    } 
    
    //check if basket is Eligible For Revalidation
    public static void revalidateProductBasketsAfterUpdate(List<cscfga__Product_Basket__c> lstNewPB) {
        Set<Id> newEligiblePbStageIdSet = new Set<Id>();
        Map<Id, cscfga__Product_Basket__c> basketMapForRedemption = new Map<Id, cscfga__Product_Basket__c>();
        for (cscfga__Product_Basket__c pb : lstNewPB) {           
            basketMapForRedemption.put(pb.Id, pb);
        }
        //Updated By Romil
        if (!basketMapForRedemption.isEmpty()) {
            //passes in the map so that we don't need additional SOQLs to get basket stage
            BasketRedemptionHelper.updateRedemptionTransactions(basketMapForRedemption);            
        }
    }
    
    
    /*
*  Method to update the attribute informations.
*/
    public static void updateAttributeInfo(Map<ID, cscfga__Product_Basket__c> oldBsktsMap,Map<ID, cscfga__Product_Basket__c> updateBsktsMap){        
        String [] attNameLst = new String[]{'Customer Requested Date','Aggregator', 'Financial CIDN' , 'Invoice Arrangement ID', 'Purchase Order Number','Basket Status', 'ProductType'};
            String [] confgNameLst = null;
        String serviceDetailStatus;
        Boolean isEnrichment = false;            
        CustomConfigurationOptions__c config = CustomConfigurationOptions__c.getValues('MarketableOfferList');
        CustomConfigurationOptions__c serviceDetailing = CustomConfigurationOptions__c.getValues('ServiceDetailing');            
        if(config!=null && String.isNotBlank(config.MarketableOfferList__c)){
            confgNameLst = config.MarketableOfferList__c.split(',');
        }            
        if(serviceDetailing != null && String.isNotBlank(serviceDetailing.Enrichment_Basket_Stage__c)) {
            serviceDetailStatus = serviceDetailing.Enrichment_Basket_Stage__c;                                      
        }
        if(confgNameLst!=null){
            Map<Id,cscfga__Attribute__c> updatedAttributes = new Map<Id,cscfga__Attribute__c>();            
            for(cscfga__Attribute__c att : [SELECT cscfga__Product_Configuration__c, cscfga__Product_Configuration__r.cscfga__Product_Basket__c,
                                            cscfga__Display_Value__c,cscfga__is_active__c,cscfga__Value__c,Id,Name 
                                            FROM cscfga__Attribute__c where cscfga__Product_Configuration__r.cscfga__Product_Basket__c 
                                            IN :updateBsktsMap.keyset() AND cscfga__Product_Configuration__c != null
                                            AND cscfga__Product_Configuration__r.cscfga__Product_Basket__c !=null AND NAME IN :attNameLst] ){
                                                cscfga__Product_Basket__c newBskt = updateBsktsMap.get(att.cscfga__Product_Configuration__r.cscfga__Product_Basket__c);
                                                cscfga__Product_Basket__c oldBskt = oldBsktsMap.get(att.cscfga__Product_Configuration__r.cscfga__Product_Basket__c);
                                                
                                                if(att.Name.equalsIgnoreCase('Customer Requested Date') && ((String.isBlank(att.cscfga__Value__c) && oldBskt.Customer_Request_Date__c==null )
                                                                                                            || (oldBskt.Customer_Request_Date__c!=null && String.valueOf(oldBskt.Customer_Request_Date__c).equalsIgnoreCase(att.cscfga__Value__c)))){
                                                                                                                updatedAttributes.put(att.id, getUpdatedAttribute(att, String.valueOf(newBskt.Customer_Request_Date__c), (newBskt.Customer_Request_Date__c!=null?newBskt.Customer_Request_Date__c.format():null)));
                                                                                                            }
                                                
                                                if(att.Name.equalsIgnoreCase('Aggregator') && ((String.isBlank(att.cscfga__Value__c) && String.isBlank(oldBskt.Aggregator__c) )
                                                                                               || (String.isNotBlank(oldBskt.Aggregator__c) && oldBskt.Aggregator__c.equalsIgnoreCase(att.cscfga__Value__c)))){
                                                                                                   updatedAttributes.put(att.id, getUpdatedAttribute(att, newBskt.Aggregator__c, newBskt.Aggregator__c));
                                                                                               }
                                                
                                                if(att.Name.equalsIgnoreCase('Invoice Arrangement ID') && ((String.isBlank(att.cscfga__Value__c) && String.isBlank(oldBskt.Invoice_Arrangement_ID__c) )
                                                                                                           || (String.isNotBlank(oldBskt.Invoice_Arrangement_ID__c) && oldBskt.Invoice_Arrangement_ID__c.equalsIgnoreCase(att.cscfga__Value__c)))){
                                                                                                               updatedAttributes.put(att.id, getUpdatedAttribute(att, newBskt.Invoice_Arrangement_ID__c, newBskt.Invoice_Arrangement_ID__c));
                                                                                                           }
                                                
                                                if(att.Name.equalsIgnoreCase('Financial CIDN') && ((String.isBlank(att.cscfga__Value__c) && String.isBlank(oldBskt.Financial_CIDN__c) )
                                                                                                   || (String.isNotBlank(oldBskt.Financial_CIDN__c) && oldBskt.Financial_CIDN__c.equalsIgnoreCase(att.cscfga__Value__c)))){
                                                                                                       updatedAttributes.put(att.id, getUpdatedAttribute(att, newBskt.Financial_CIDN__c, newBskt.Financial_CIDN__c));
                                                                                                   }
                                                
                                                if(att.Name.equalsIgnoreCase('Purchase Order Number') && ((String.isBlank(att.cscfga__Value__c) && String.isBlank(oldBskt.Purchase_Order_Number__c) )
                                                                                                          || (String.isNotBlank(oldBskt.Purchase_Order_Number__c) && oldBskt.Purchase_Order_Number__c.equalsIgnoreCase(att.cscfga__Value__c)))){
                                                                                                              updatedAttributes.put(att.id, getUpdatedAttribute(att, newBskt.Purchase_Order_Number__c, newBskt.Purchase_Order_Number__c));
                                                                                                          }
                                                
                                                if(att.Name.equalsIgnoreCase('Basket Status') && (
                                                    (String.isNotBlank(oldBskt.csordtelcoa__basket_stage__c) && !oldBskt.csordtelcoa__basket_stage__c.equalsIgnoreCase(newBskt.csordtelcoa__basket_stage__c))
                                                    || (String.isNotBlank(newBskt.csordtelcoa__basket_stage__c) && !newBskt.csordtelcoa__basket_stage__c.equalsIgnoreCase(oldBskt.csordtelcoa__basket_stage__c)))){
                                                        updatedAttributes.put(att.id, getUpdatedAttribute(att, newBskt.csordtelcoa__basket_stage__c, newBskt.csordtelcoa__basket_stage__c));
                                                    }
                                                
                                                if(att.Name.equalsIgnoreCase('ProductType')) {
                                                    if(newBskt.csordtelcoa__basket_stage__c == serviceDetailStatus) {
                                                        isEnrichment = true;
                                                    }
                                                    cscfga__Attribute__c modAtt;
                                                    if(isEnrichment) { 
                                                        modAtt = getUpdatedAttribute(att, 'None', 'None');
                                                        
                                                    } else {  
                                                        modAtt = getUpdatedAttribute(att, 'Inline', 'Inline');
                                                    }
                                                    updatedAttributes.put(modAtt.id, modAtt);
                                                }                                                    
                                            }
            
            //WE ARE ASSUMMING THE NUMBER OF ATTRIBUTES MODIFIED IS LESS THAN 10000 RECORDS.                
            if(updatedAttributes.size()>0){
                update updatedAttributes.values();
            }                
        }
    }
    
    @TestVisible
    private static cscfga__Attribute__c getUpdatedAttribute(cscfga__Attribute__c att, String value, String displayValue) {
        cscfga__Attribute__c updatedAtt = att;
        updatedAtt.cscfga__Value__c = value;
        updatedAtt.cscfga__Display_Value__c = displayValue;
        return updatedAtt;
    }
    
    /* JIRA - EDGE-25504 - MAQ - START*/
    public static String updateOldQuotesToVoid(cscfga__Product_Basket__c[] updatedBskts) {
        try{
            system.debug('Enter updateOldQuotesToVoid ');
            list < Quote > updateQuote = new list < Quote > ();
            map <id,cscfga__Product_Basket__c> updateQuoteMap = new map <id,cscfga__Product_Basket__c> ();// EDGE-127666
            for (cscfga__Product_Basket__c basketRec: updatedBskts) {
                // EDGE-127666  start
                if (basketRec.csordtelcoa__Basket_Stage__c == 'Contract Initiated' && basketRec.cscfga__Opportunity__c != NULL) {
                    updateQuoteMap.put(basketRec.cscfga__Opportunity__c,basketRec);   
                }
                // EDGE-127666 end
            } 
            if(updateQuoteMap != null){ 
                updateQuote=getUpdatedQuoteStatus(updateQuoteMap);
            }
            
            if(updateQuote.size() > 0){
                UPDATE updateQuote;
            }
            return null;
        } catch(Exception e){
            System.debug('Exception occurred in updateOldQuotesToVoid(): ' + e.getMessage());
            Map<String,Object> inputLogMap = new Map<String,Object>();
            inputLogMap.put('severity', C2O_ExceptionHandler.SEVERITY.HIGH); 
            inputLogMap.put('errorDescription', e.getMessage());
            inputLogMap.put('LoggingLevel.INFO', e.getStackTraceString()); 
            C2O_Utilities.logException(inputLogMap,false);
            return null;
        }           
    }
    /* JIRA - EDGE-25504 - MAQ - END*/
    
    //start EDGE-127666
    public static List<Quote> getUpdatedQuoteStatus(map <id,cscfga__Product_Basket__c> updateQuoteMap){  
        list < Quote > updateQuote = new list < Quote > ();
        list < Quote > AllQuotes =  new list < Quote > ();
        for (Quote quoteRecords: [SELECT ID, Product_Basket__c, Status,OpportunityId  FROM Quote WHERE OpportunityId != NULL AND OpportunityId IN : updateQuoteMap.keyset() ORDER BY createddate DESC]) {
            if(updateQuoteMap.containskey(quoteRecords.OpportunityId) && quoteRecords.Product_Basket__c == updateQuoteMap.get(quoteRecords.OpportunityId).id){
                Quote updateQ = new Quote();
                updateQ.ID = quoteRecords.ID;
                updateQ.Status = 'Customer Validated';
                updateQuote.add(updateQ);
            }
            else{
                Quote updateQ = new Quote();
                updateQ.ID = quoteRecords.ID;
                updateQ.Status = 'Void';
                updateQuote.add(updateQ);     
            }
        }
        return updateQuote;                         
    }
    
    public static void InsertProductBasket(List<cscfga__Product_Basket__c> newBskt) {
        set<Id> productBasketId = new set<Id>();
        List<account> accountObject= new List<account>();
        List<Opportunity> opportunityData;
        set <Id> accountList = new set <Id> ();
        set <Id> accountList1 = new set <Id> ();
        List <cscfga__Product_Basket__c> prodBasketList;
        List <ContractJunction__c> contractJunList;
        Boolean updateRequired = false;
        Boolean contractStatus = false; 
        //Check if user has Skip_Contract_Basket_Express_Order permission set assigned        
        Boolean hasCustomPermission = FeatureManagement.checkPermission('Express_Order_Enabled');
        ProductBasketFieldsUpdate.updateNameAndAccountInfo(newBskt);
        //START: Added for DIGI-3338
        ProductBasketFieldsUpdate.updateFrameAgreementOnBasket(newBskt);
        //END for DIGI-3338
        //Below FOR Loop checks if the opportunity has more than 0 primary basket, then do make the
        //primary basket and sync flags as false for the new basket to be inserted- To handle the Cloned Basket issue
        Integer basketCount = 0;
        //EDGE-181996 
        List<cscfga__Product_Basket__c> listProductBasket =
            [SELECT Id, Primary_Basket__c
             FROM cscfga__Product_Basket__c
             WHERE cscfga__Opportunity__c = : newBskt[0].cscfga__Opportunity__c
            ];
        basketCount = listProductBasket.size();
        //Sets Primary_Basket__c = true for the first basket
        if(basketCount <1) {
            newBskt[0].Primary_Basket__c = true;
        }
        Boolean isPrimaryBasketPresent =false;
        //Below code checks if the basket to be inserted is the first basket, then make the basket as primary
        for(cscfga__Product_Basket__c prodBasket :listProductBasket) {
            if(prodBasket.Primary_Basket__c) {
                isPrimaryBasketPresent=true; 
                break;
            }
        }
        //Below code checks if the previous basket has primary as true then it updates the is Primary false 
        if(isPrimaryBasketPresent) {
            for(cscfga__Product_Basket__c newBasket :newbskt) {  
                if(newBasket.Primary_Basket__c){
                    newBasket.Primary_Basket__c = false;
                    newBasket.csordtelcoa__Synchronised_with_Opportunity__c = false;
                    newBasket.csbb__Synchronised_With_Opportunity__c = false;   
                }
            }
        }
        //Start of EDGE-144055-Enable only online users to skip the contract/order form approval process
        if(hasCustomPermission && newBskt[0].cscfga__Opportunity__c !=null) {//EDGE-181996 
            opportunityData =[ SELECT AccountId FROM OPPORTUNITY WHERE ID  =: newBskt[0].cscfga__Opportunity__c LIMIT 1];
            for(OPPORTUNITY opp: opportunityData ){
                accountList1.add(opp.AccountId);
            }
            contractJunList = [SELECT Id, Account__C, BSA_Generated__c, Status__c FROM ContractJunction__c where Account__C IN: accountList1];
            //Set a hidden flag based on the BSA flag in contract and the status in contract junction.
            for (ContractJunction__c contractJun: contractJunList) {
                contractStatus= contractJun.BSA_Generated__c && !System.Label.contract_Status.contains(contractJun.Status__c); 
                // If BSA flag is true on Contract junction set BSA Generated flag on Product Basket
                if (contractStatus) {
                    for (cscfga__Product_Basket__c updateBasket: newBskt) {
                        updateBasket.BSA_Generated__c = true;
                        updateRequired = true;    
                    }
                    //End of EDGE-144055-Enable only online users to skip the contract/order form approval process 
                }
            }
        } 
    }
    
    public static void updateBasketStage(cscfga__Product_Basket__c[] updatedBskts){        
        Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.cscfga__Product_Basket__c.getRecordTypeInfosById();
        String recordTypeName='';
        if (updatedBskts !=null) {
            for(cscfga__Product_Basket__c updateBsk:updatedBskts){
                if((rtMap.size() > 0) &&updateBsk.RecordTypeId != null ){
                    recordTypeName= rtMap.get(updateBsk.RecordTypeId).getName();
                    system.debug('recordTypeName' + recordTypeName);            
                    if(updateBsk.csordtelcoa__Basket_Stage__c == 'Contract Accepted' && recordTypeName!='Inflight Change'){
                        updateBsk.csordtelcoa__Synchronised_with_Opportunity__c = true;
                        updateBsk.csbb__Synchronised_With_Opportunity__c = true;
                    }
                }
                if((updateBsk.Project_Complexity__c == 'Complex' || updateBsk.Project_Complexity__c == 'Complex Plus') && updateBsk.csordtelcoa__Basket_Stage__c == 'Contract Accepted'){
                    updateBsk.PM_Required__c = true; 
                }
                if(updateBsk.Project_Complexity__c == 'Simplex' || updateBsk.Project_Complexity__c == 'Simplex Plus'){
                    updateBsk.PM_Required__c = false;
                }
            }
        }
    }
    
    public static void oneFundTransactionBasedOnExpiryDate(List<cscfga__Product_Basket__c> prodBaskRecs){
        Map<String,String> prodBaskVsAccMap = new Map<String,String>();
        Set<Id> oppSet = new Set<Id>();
        Map<Id,Account> accMap = new Map<Id,Account>();
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>();
        Map<Id,OneFund__c> oneFundMap = new Map<Id,OneFund__c>();
        Set<Id> parentIdSet = new Set<Id>();
        Set<Id> ultimateParentAccSet = new Set<Id>();
        
        //Fetch the Product Basket details
        for(cscfga__Product_Basket__c pb : [Select Id,Name,csbb__Account__c,
                                            cscfga__Opportunity__c,csordtelcoa__Basket_Stage__c
                                            FROM cscfga__Product_Basket__c WHERE Id IN :prodBaskRecs]){
                                                prodBaskVsAccMap.put(pb.csbb__Account__c,pb.Id);
                                                oppSet.add(pb.cscfga__Opportunity__c);
                                            }
        
        //Fetch the Account details 
        for(Account acc : [Select Id, 
                           ParentId,Ultimate_Parent_Account__c,
                           Ultimate_CIDN__c,Parent_CIDN__c
                           FROM Account WHERE Id IN :prodBaskVsAccMap.keySet()]){
                               parentIdSet.add(acc.ParentId);
                               ultimateParentAccSet.add(acc.Ultimate_Parent_Account__c);
                               accMap.put(acc.Id,acc); 
                           }
        
        //Fetch the Opportunity details
        for(Opportunity opp : [Select Id,Basket_Redemption_amount__c
                               FROM Opportunity 
                               WHERE Id IN :oppSet]){
                                   oppMap.put(opp.Id,opp);
                               }        
        
        for(OneFund__c oneFund : [Select Id,CIDN__c  
                                  FROM OneFund__c 
                                  WHERE (CIDN__c IN :prodBaskVsAccMap.keySet()) OR (CIDN__c IN :parentIdSet) OR (CIDN__c IN :ultimateParentAccSet)]){
                                      oneFundMap.put(oneFund.Id, oneFund); 
                                  } 
        
        List<OneFund_Transactions__c> oneFundRecs = new List<OneFund_Transactions__c>();
        Map<Id,OneFund_Transactions__c> oneFundRecsMapToUpdate = new Map<Id,OneFund_Transactions__c>();
        for(OneFund_Transactions__c tran : [Select Id,OneFund__c,Current_Amount__c,Product_Basket_ID__c,
                                            Expiry_Date__c,RecordTypeId,Transaction_Status__c,Redeemed_Amount__c
                                            FROM OneFund_Transactions__c 
                                            WHERE OneFund__c IN :oneFundMap.keySet()]){
                                                tran.Product_Basket_ID__c = prodBaskVsAccMap.get(oneFundMap.get(tran.OneFund__c).CIDN__c);  //Update Product Basket Id.
                                                oneFundRecsMapToUpdate.put(tran.Id,tran);
                                                if(tran.Current_Amount__c > 0 &&
                                                   tran.Expiry_Date__c >= Date.today() &&
                                                   tran.RecordTypeId == OFT_Accrual_RecordType &&
                                                   tran.Transaction_Status__c == 'Active'){ 
                                                       oneFundRecs.add(tran);
                                                   } 
                                            }
        
        if(oneFundRecsMapToUpdate.isEmpty()){
            update oneFundRecsMapToUpdate.values(); 
        }
        
        if(!oppMap.isEmpty() && !oneFundRecs.isEmpty()){
            updateOpportunityOneFund(oppMap,oneFundRecs);
        }
    } 
    
    public static void updateOpportunityOneFund(Map<Id,Opportunity> oppMap,List<OneFund_Transactions__c> oneFundRecs){        
        try{
            List<OneFund_Transactions__c> oneFundRecsToInsert = new List<OneFund_Transactions__c>();
            List<OneFund_Transactions__c> oneFundRecsToUpdate = new List<OneFund_Transactions__c>();
            List<Opportunity> oppsToUpdate = new List<Opportunity>();
            Map<Id,Opportunity> oppUpdatedMap = new Map<Id,Opportunity>();
            for(Opportunity opp : oppMap.values()){
                for(OneFund_Transactions__c oneFund : oneFundRecs){ 
                    //Check if Opportunity Amount is Greater
                    if((opp.Basket_Redemption_amount__c > 0) && (opp.Basket_Redemption_amount__c >= oneFund.Current_Amount__c)){
                        OneFund_Transactions__c oneFundTrans = new OneFund_Transactions__c();
                        oneFundTrans.RecordTypeId = OFT_Redemption_RecordType;//Set record type
                        oneFundTrans.OneFund__c = oneFund.OneFund__c;
                        oneFundTrans.Product_Basket__c = oneFund.Product_Basket_ID__c;
                        oneFundTrans.Redemption_date__c = Date.today();
                        oneFundTrans.Related_Accrual__c = oneFund.Id;
                        oneFundTrans.Sub_Type__c = 'POS';
                        //oneFundTrans.Transaction_Amount__c = opp.Basket_Redemption_amount__c;
						oneFundTrans.Transaction_Amount__c = oneFund.Current_Amount__c;
                        oneFundTrans.Transaction_Status__c = 'Active'; 
                        oneFundRecsToInsert.add(oneFundTrans);
						
                        /*DN: Initial code 
						if(oneFund.Redeemed_Amount__c != null){
                            oneFund.Redeemed_Amount__c = oneFund.Redeemed_Amount__c + opp.Basket_Redemption_amount__c;
                            oneFundRecsToUpdate.add(oneFund);
                        } else {
                            oneFund.Redeemed_Amount__c = opp.Basket_Redemption_amount__c;
                            oneFundRecsToUpdate.add(oneFund);
                        }*/
						
						//DN: swapped if() conditions start...
						if(oneFund.Redeemed_Amount__c != null){
                            oneFund.Redeemed_Amount__c = oneFund.Redeemed_Amount__c + oneFund.Current_Amount__c;	//"Current_Amount__c":500.00,"Redeemed_Amount__c":0.00,"Basket_Redemption_amount__c":11.00
                            oneFundRecsToUpdate.add(oneFund);
                        } else {
                            oneFund.Redeemed_Amount__c = oneFund.Current_Amount__c;
                            oneFundRecsToUpdate.add(oneFund);
                        } //DN: ...end swapped if() conditions
						
                        opp.Basket_Redemption_amount__c = 0;
                        oppsToUpdate.add(opp);
                    } else if((opp.Basket_Redemption_amount__c > 0) && (oneFund.Current_Amount__c > opp.Basket_Redemption_amount__c)){
						OneFund_Transactions__c oneFundTrans = new OneFund_Transactions__c();
                        oneFundTrans.RecordTypeId = OFT_Redemption_RecordType;//Set record type
                        oneFundTrans.OneFund__c = oneFund.OneFund__c;
                        oneFundTrans.Product_Basket__c = oneFund.Product_Basket_ID__c;
                        oneFundTrans.Redemption_date__c = Date.today();
                        oneFundTrans.Related_Accrual__c = oneFund.Id;
                        oneFundTrans.Sub_Type__c = 'POS';
                        //oneFundTrans.Transaction_Amount__c = oneFund.Current_Amount__c;
						oneFundTrans.Transaction_Amount__c = opp.Basket_Redemption_amount__c;
                        oneFundTrans.Transaction_Status__c = 'Active';
                        oneFundRecsToInsert.add(oneFundTrans);
						
						//DN: sample data: "Current_Amount__c":500.00,"Redeemed_Amount__c":0.00,"Basket_Redemption_amount__c":11.00
						
                        /*DN: Initial code 
						if(oneFund.Redeemed_Amount__c != null){
                            oneFund.Redeemed_Amount__c = oneFund.Redeemed_Amount__c + oneFund.Current_Amount__c;	
                            oneFundRecsToUpdate.add(oneFund);
                        } else {
                            oneFund.Redeemed_Amount__c = oneFund.Current_Amount__c;
                            oneFundRecsToUpdate.add(oneFund);
                        }*/
						
						//DN: swapped if() conditions start...
						if(oneFund.Redeemed_Amount__c != null){
                            oneFund.Redeemed_Amount__c = oneFund.Redeemed_Amount__c + opp.Basket_Redemption_amount__c;
                            oneFundRecsToUpdate.add(oneFund);
                        } else {
                            oneFund.Redeemed_Amount__c = opp.Basket_Redemption_amount__c;
                            oneFundRecsToUpdate.add(oneFund);
                        } //DN: ...end swapped if() conditions
						
                        opp.Basket_Redemption_amount__c = opp.Basket_Redemption_amount__c - oneFund.Current_Amount__c; //DN: will result in negative value
                        oppsToUpdate.add(opp);
                    }                
                }
            }
            if(!oneFundRecsToInsert.isEmpty() && oneFundRecsToInsert.size() > 0){
                insert oneFundRecsToInsert;
            }
            
            if(!oneFundRecsToUpdate.isEmpty() && oneFundRecsToUpdate.size() > 0){
                update oneFundRecsToUpdate;
            }
            
            if(!oppsToUpdate.isEmpty() && oppsToUpdate.size() > 0){ 
                update oppsToUpdate;
            }
        } catch(Exception e){ 
            Map<String,Object> inputLogMap = new Map<String,Object>();
            inputLogMap.put('severity', C2O_ExceptionHandler.SEVERITY.HIGH); 
            inputLogMap.put('errorDescription', e.getMessage());
            inputLogMap.put('LoggingLevel.INFO', e.getStackTraceString()); 
            C2O_Utilities.logException(inputLogMap,false);
        }
    } 
    
    public static void updateAccountonProductBasketduringSync(List<cscfga__Product_Basket__c> prdBasRecs){
        for(cscfga__Product_Basket__c pb : prdBasRecs){
            pb.csordtelcoa__Account__c = pb.csbb__Account__c;
        }
    }
    //DIGI-22658
    public static void autoSyncPlatformEvent(cscfga__Product_Basket__c[] updatedBskts,Map<ID, cscfga__Product_Basket__c> oldBsktsMap){
        Set<Id> setOfBasketId = new Set<Id>();
        for(cscfga__Product_Basket__c bas : updatedBskts) {
            setOfBasketId.add(bas.Id);
        }
        
        List<cscfga__Product_Basket__c> productBaskets = new List<cscfga__Product_Basket__c>([Select id,LastModifiedBy.Name from cscfga__Product_Basket__c where Id IN: setOfBasketId]);
        Map<Id, cscfga__Product_Basket__c> mapOfBasket = new Map<Id,cscfga__Product_Basket__c>(productBaskets);
        
        List<AutoSync__e> syncEvents = new List<AutoSync__e>();
        for (cscfga__Product_Basket__c bas : updatedBskts) {
            System.debug(LoggingLevel.INFO, 'OnAfterUpdate.cscfga__Basket_Status__c = ' + bas.cscfga__Basket_Status__c + bas.cscfga__Products_Id_Qty_In_Basket__c);
            System.debug(LoggingLevel.INFO, 'OnAfterUpdate.Primary_Basket__c = ' + bas.Primary_Basket__c);
            System.debug(LoggingLevel.INFO, 'OnAfterUpdate.csbb__Synchronised_with_Opportunity__c = ' + bas.csbb__Synchronised_with_Opportunity__c);
            
            //Start:DIGI-6869 Added to stop invoking AutoSync process on reopening of opportunity
            if(FeatureEligibilityChecker.determineFeatureEligiblity('StandardOpportunityReopen', 'New') && oldBsktsMap.containsKey(bas.Id) && String.isNotEmpty(bas.csordtelcoa__Basket_Stage__c) && bas.csordtelcoa__Basket_Stage__c.equalsIgnoreCase('Commercial Configuration') && String.isNotEmpty(oldBsktsMap.get(bas.Id).csordtelcoa__Basket_Stage__c) && oldBsktsMap.get(bas.Id).csordtelcoa__Basket_Stage__c.equalsIgnoreCase('Submitted')) { 
                continue;
            }
            //End: DIGI-6869 Added to stop invoking AutoSync process on reopening of opportunity
            
            String lastModifiedBasName;
            if(mapOfBasket != null &&  mapOfBasket.get(bas.Id) != null) {
                lastModifiedBasName =  mapOfBasket.get(bas.Id).LastModifiedBy.Name;     
            }
            System.debug(LoggingLevel.INFO, 'OnAfterUpdate.LastModifiedBy.Name = ' + lastModifiedBasName); 
            
            //P2OB-10782 Adding condition that Autosync platform event should NOT be fired for ‘TESA User’
            if (!String.isBlank(lastModifiedBasName) && lastModifiedBasName != System.Label.TESAIntegrationUserName && bas.BasketOppType__c != Label.Modular && bas.Primary_Basket__c &&
                ((bas.cscfga__Basket_Status__c == 'Valid' && !bas.csbb__Synchronised_with_Opportunity__c) ||
                 (oldBsktsMap.get(bas.Id).cscfga__Products_Id_Qty_In_Basket__c != bas.cscfga__Products_Id_Qty_In_Basket__c)) &&
                StaticUtilForRecursion.runAutoSyncOnce())
                syncEvents.add(new AutoSync__e(Basket_Id__c = bas.id, SyncFlag__c = false)) ;
            //P2OB-13544 Fix for Manual Sync- Revenue details on the opportunity are not synced For Standard Opportunities
            else if (!String.isBlank(lastModifiedBasName) && lastModifiedBasName != System.Label.TESAIntegrationUserName && bas.BasketOppType__c != Label.Modular && bas.Primary_Basket__c &&
                     ((bas.cscfga__Basket_Status__c == 'Valid' && bas.csbb__Synchronised_with_Opportunity__c) ||
                      (oldBsktsMap.get(bas.Id).cscfga__Products_Id_Qty_In_Basket__c != bas.cscfga__Products_Id_Qty_In_Basket__c)) &&
                     StaticUtilForRecursion.runAutoSyncOnce())
                syncEvents.add(new AutoSync__e(Basket_Id__c = bas.id, SyncFlag__c = false)) ;
        }
        
        System.debug(LoggingLevel.INFO, 'C2O_ProductBasketTriggerHelper.syncEvents = ' + syncEvents);
        if (syncEvents.size() > 0)
            EventBus.publish(syncEvents);
    }
}