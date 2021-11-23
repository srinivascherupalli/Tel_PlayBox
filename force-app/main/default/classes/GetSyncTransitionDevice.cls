/******************************************************************************************************************************
Class Name : GetSyncTransitionDevice
Test Class : GetSyncTransitionDeviceTest
===============================================================================================================================
Sr.No.  Developer           Date          Story Description                Sprint
1.      Aman Soni           13/10/2020    EDGE-173469(New Class)           20.14
2.      Aman Soni           29/10/2020    EDGE-176697                      20.15
3.      Aman Soni           19/01/2021    EDGE-191076                      21.01
4.      Aman Soni           28/01/2021    EDGE-191077                      21.02
5.      Aman Soni           05/02/2021    EDGE-194029                      21.02
6.      Aman Soni           17/02/2021    EDGE-203220                      21.03
7.      Aman Soni           08/04/2021    EDGE-207355                      21.05
******************************************************************************************************************************/
global with sharing class GetSyncTransitionDevice implements cssmgnt.RemoteActionDataProvider{

 /*  
 * Method Name      : getData
 * Input Parameter  : Map<String,Object> inputMap
 * Return Parameter : Map<String, Object> returnMap
 * Description      : It will inputMap from JS and returnMap with the required values.  
 * Owner            : Aman Soni
 * Jira             : EDGE-176693 
 */  
  @RemoteAction
    global static Map<String,Object> getData(Map<String,Object> inputMap){
        Map<String,Map<String,Service_Add_On__c>> retStat_InsIdServAddOn_Map = new Map<String,Map<String,Service_Add_On__c>>();
        Map<String, Object> returnMap = new Map<String, Object>(); 
        Set<String> inputKey = inputMap.keySet();
        List<String> insLstForStatusUpd = new List<String>();
        String basketId = '';
        String solutionId = '';
        String category = '';
        String contractType = '';
        String instanceIdListStr = '';
        String insIdLstStrForStatusUpd = '';
        for(String k :inputKey){
            switch on k{
                when 'basketId'{
                    basketId = (String)inputMap.get(k);                   
                }
                when 'solutionId'{
                    solutionId = (String)inputMap.get(k);                   
                }
                when 'category'{
                    category = (String)inputMap.get(k);                   
                }
                when 'contractType'{
                    contractType = (String)inputMap.get(k);                   
                }
                when 'insLstForStatusUpd'{
                    insIdLstStrForStatusUpd = (String)inputMap.get('insLstForStatusUpd');
                    insLstForStatusUpd = insIdLstStrForStatusUpd.split(',');                  
                }
            }
        }
        
        if(!insLstForStatusUpd.isEmpty()){
            updateSyncTransDeviceStatus(basketId, solutionId, contractType, category, insLstForStatusUpd);
        }
        
       return returnMap;               
    }
    
    /*  
     * Method Name      : updateSyncTransDeviceStatus
     * Input Parameter  : String basketId, List<String> instanceIdList
     * Return Parameter : void
     * Description      : will update the Status__c on Service Add On records based on requirement 
     * Owner            : Aman Soni
     * Jira             : EDGE-176693 || EDGE-191077 || EDGE-194029
     */
    public static void updateSyncTransDeviceStatus(String basketId, String solutionId, String contractType,String category, List<String> instanceIdList){                          
        Set<Service_Add_On__c> StatusSyncCompetedSet = new Set<Service_Add_On__c>();
        Map<String, Service_Add_On__c> servAddOnMap = new Map<String, Service_Add_On__c>(); 
        List<string> statusList = Label.ServiceAddOnStatus.split(',');//Added for EDGE-191077 by Aman Soni
        Id accountId;
        String opptyType;   
        
        if(String.isNotBlank(basketId)){
            cscfga__Product_Basket__c prodBasket = Model_ProductBasket.getProductBasket(basketId);
            if(prodBasket != null){
                accountId = prodBasket.csbb__Account__c;
                opptyType = prodBasket.Opportunity_Type__c;
            }
        }
        StatusSyncCompetedSet = Model_ServiceAddOns.returnServiceAddonRecords(basketId, solutionId, contractType, category, accountId, opptyType);
        //Desc: Will update the Status__c='Sync Completed' when it is 'Ready for Sync/Sync Removal Completed' for Service_Add_On__c
        if(!StatusSyncCompetedSet.isEmpty()){
            for(Service_Add_On__c servAddOn : StatusSyncCompetedSet){
                if(statusList.contains(servAddOn.Status__c) && instanceIdList.contains(servAddOn.Instance_Id__c)){
                    servAddOn.Status__c = Label.ServiceAddOnSyncCompleted;
                    servAddOn.Product_Basket__c = basketId;//Added for EDGE-191076 by Aman Soni
                    servAddOn.Solution_Id__c = solutionId;//Added for EDGE-194029 by Aman Soni
                    servAddOnMap.put(servAddOn.Instance_Id__c, servAddOn);
                }
            }
        }
        update servAddOnMap.values();                  
    }
    
     /*  
     * Method Name      : getBasketOpptyType 
     * Input Parameter  : String basketId
     * Return Parameter : String
     * Description      : will return oppty Type against the input basket to LWC Comp  
     * Owner            : Aman Soni
     * Jira             : EDGE-194029
     */
    @AuraEnabled(cacheable=true)
    public static String getBasketOpptyType(String basketId){ 
        String opptyType;       
        if(String.isNotBlank(basketId)){
            cscfga__Product_Basket__c prodBasket = Model_ProductBasket.getProductBasket(basketId);
            if(prodBasket != null){
                opptyType = prodBasket.Opportunity_Type__c;
            }
        }
        return opptyType;     
    }
    
     /*  
     * Method Name      : getServiceAddOns 
     * Input Parameter  : String basketId
     * Return Parameter : List<Service_Add_On__c>
     * Description      : will return all the service add ons records against the input basket to LWC Comp  
     * Owner            : Aman Soni
     * Jira             : EDGE-191076
     */
    @AuraEnabled(cacheable=true)
    public static List<ServiceAddOnWrapperData> getServiceAddOns(String basketId, String solutionId, String contractType, String category, List<String> instIdList){ 
        Set<Service_Add_On__c> servAddOnSet = new Set<Service_Add_On__c>();
        List<ServiceAddOnWrapperData> servAddWrapList = new List<ServiceAddOnWrapperData>();        
        Id accountId;
        String opptyType;       
        if(String.isNotBlank(basketId)){
            cscfga__Product_Basket__c prodBasket = Model_ProductBasket.getProductBasket(basketId);
            if(prodBasket != null){
                accountId = prodBasket.csbb__Account__c;
                opptyType = prodBasket.Opportunity_Type__c;
            }
        }
        servAddOnSet = Model_ServiceAddOns.returnServiceAddonRecords(basketId, solutionId, contractType, category, accountId, opptyType);          
        if(!(servAddOnSet.isEmpty())){
            servAddWrapList = finalServAddOns(servAddOnSet, instIdList);
        }           
        return servAddWrapList;     
    }
    
    /*  
     * Method Name      : getFilteredRecForSelectedBAN
     * Input Parameter  : String basketId
     * Return Parameter : List<String>
     * Description      : will return legacyBillingAccount against the input basket to LWC Comp  
     * Owner            : Aman Soni
     * Jira             : EDGE-191076
     */
    @AuraEnabled(cacheable=true)
    public static List<ServiceAddOnWrapperData> getFilteredRecForSelectedBAN(String basketId, String solutionId, String contractType, String category, String mainBAN, List<String> instIdList){ 
        Set<Service_Add_On__c> filteredServAddOnSet = new Set<Service_Add_On__c>();
        List<ServiceAddOnWrapperData> servAddWrapList = new List<ServiceAddOnWrapperData>();        
        Id accountId;
        String opptyType;       
        if(String.isNotBlank(basketId)){
            cscfga__Product_Basket__c prodBasket = Model_ProductBasket.getProductBasket(basketId);
            if(prodBasket != null){
                accountId = prodBasket.csbb__Account__c;
                opptyType = prodBasket.Opportunity_Type__c;
            }           
            filteredServAddOnSet = Model_ServiceAddOns.returnServiceAddonRecords(basketId, solutionId, contractType, category, accountId, opptyType);
            if(!(filteredServAddOnSet.isEmpty())){
                Set<Service_Add_On__c> filteredServAddOnNewSet = new Set<Service_Add_On__c>();
                for(Service_Add_On__c servAdd : filteredServAddOnSet){
                   if(mainBAN == servAdd.Legacy_Billing_Account_Number__c){                 
                    filteredServAddOnNewSet.add(servAdd);
                   }
                   //Added for EDGE-207355 by Aman Soni || Start
                   else if(mainBAN == 'All'){
                    filteredServAddOnNewSet.add(servAdd);
                   }
                    //Added for EDGE-207355 by Aman Soni || End
                }
                servAddWrapList = finalServAddOns(filteredServAddOnNewSet, instIdList);
            }           
        }
        return servAddWrapList;     
    }   
    
    /*  
     * Method Name      : getLegacyBillAccount
     * Input Parameter  : String basketId
     * Return Parameter : List<String>
     * Description      : will return legacyBillingAccount against the input basket to LWC Comp  
     * Owner            : Aman Soni
     * Jira             : EDGE-191076
     */
    @AuraEnabled(cacheable=true)
    public static List<String> getLegacyBillAccount(String basketId, String solutionId, String category, String contractType){ 
        Set<Service_Add_On__c> servAddOnSet = new Set<Service_Add_On__c>();
        Set<String> banSet = new Set<String>();
        List<String> banLst = new List<String>();
        Id accountId;
        String opptyType;       
        if(String.isNotBlank(basketId)){
            cscfga__Product_Basket__c prodBasket = Model_ProductBasket.getProductBasket(basketId);
            if(prodBasket != null){
                accountId = prodBasket.csbb__Account__c;
                opptyType = prodBasket.Opportunity_Type__c;
            }           
            servAddOnSet = Model_ServiceAddOns.returnServiceAddonRecords(basketId, solutionId, contractType, category, accountId, opptyType);
            if(!(servAddOnSet.isEmpty())){
                for(Service_Add_On__c servAdd : servAddOnSet){
                    banSet.add('All');//Added for EDGE-207355 by Aman Soni 
                    banSet.add(servAdd.Legacy_Billing_Account_Number__c);
                }
            }
            banLst = new List<String>(banSet);          
        }
        return banLst;     
    }
    
     /*  
     * Method Name      : getSynRemPendingRecs 
     * Input Parameter  : String basketId, List<Id> addOnList
     * Return Parameter : Void
     * Description      : update Service Add On records status as Ready for Sync in case of Migration Scenario 
     * Owner            : Aman Soni
     * Jira             : EDGE-191077
     */
    @AuraEnabled
    public static void getSynRemPendingRecs(String basketId, List<Id> addOnList){ 
        Map<String, Service_Add_On__c> servAddOnMap = new Map<String, Service_Add_On__c>();
        Set<Service_Add_On__c> servAddOnSet = new Set<Service_Add_On__c>();
        String opptyType = '';       
        if(String.isNotBlank(basketId)){
            cscfga__Product_Basket__c prodBasket = Model_ProductBasket.getProductBasket(basketId);
            if(prodBasket != null){
                opptyType = prodBasket.Opportunity_Type__c;
            }
            if(opptyType == null){
                opptyType = '';
            }           
        }
                
        if(!addOnList.isEmpty()){
            servAddOnSet = Model_ServiceAddOns.retSyncRemPendingBeforeSave(addOnList);
            if(!(servAddOnSet.isEmpty())){
                for(Service_Add_On__c servAdd : servAddOnSet){
                    if(opptyType.equalsIgnoreCase('Migration')){
                        servAdd.Status__c = 'Ready for Sync';
                    }
                    else if(opptyType != 'Migration'){
                        servAdd.Status__c = 'Sync Removal Completed';
                    }
                    servAdd.Product_Basket__c = null;
                    servAdd.Solution_Id__c = '';
                    servAddOnMap.put(servAdd.Instance_Id__c, servAdd);
                }
            }
        update servAddOnMap.values();
        } 
    }
   
    /*  
    * Method Name      : getSyncPendingRecsForTransition 
    * Input Parameter  : String basketId, String solutionId, String contractType, String category, List<String> instIdList
    * Return Parameter : List<ServiceAddOnWrapperData>
    * Description      : get serviceAddOn records of status Sync Removal Pending
    * Owner            : Aman Soni
    * Jira             : EDGE-203220(20.03)
    */
    @AuraEnabled(cacheable=true)
    public static List<ServiceAddOnWrapperData> getSyncPendingRecsForTransition(String basketId, String solutionId, String contractType, String category, List<String> instIdList){ 
        Set<Service_Add_On__c> servAddOnSet = new Set<Service_Add_On__c>();
        Set<Service_Add_On__c> servAddOnToBeRemSet = new Set<Service_Add_On__c>();
        List<ServiceAddOnWrapperData> servAddWrapList = new List<ServiceAddOnWrapperData>();        
        String opptyType;       
        if(String.isNotBlank(basketId)){
            cscfga__Product_Basket__c prodBasket = Model_ProductBasket.getProductBasket(basketId);
            if(prodBasket != null){
                opptyType = prodBasket.Opportunity_Type__c;
            }
            servAddOnSet = Model_ServiceAddOns.getSynRemPendingAddOnsForTransition(basketId, solutionId, contractType, category, opptyType);
        }          
        if(!servAddOnSet.isEmpty() && !instIdList.isEmpty()){
            for(Service_Add_On__c servAddOn : servAddOnSet){
                if(instIdList.contains(servAddOn.Instance_Id__c)){
                    servAddOnToBeRemSet.add(servAddOn);
                }                   
            }
            servAddWrapList = finalServAddOns(servAddOnToBeRemSet, instIdList);
        }           
        return servAddWrapList;     
    }
    
    /*  
     * Method Name      : finalServAddOns
     * Input Parameter  : Set<Service_Add_On__c> servAddSet,List<String> instIdList
     * Return Parameter : List<ServiceAddOnWrapperData>
     * Description      : will return all the service add ons records against the input Service Add on List
     * Owner            : Aman Soni
     * Jira             : EDGE-191076
        */
    public static List<ServiceAddOnWrapperData> finalServAddOns(Set<Service_Add_On__c> servAddSet,List<String> instIdList){
        List<ServiceAddOnWrapperData> servAddWrapFinalList = new List<ServiceAddOnWrapperData>();
        //Start of EDGE-208433 (Collecting SKU from ServiceAddOns and Billing Description from Price Item)
        Set<String> billingDescriptionSet = new Set<String>();
        Set<String> skuSetFromPriceItem = new Set<String>();

        Map<String, String> priceItemMap = new Map<String, String>();
        map<String, String> billingSkuMap = new map<String, String> ();
        List<String> billingDescriptionList = new List<String> ();
        List<String> skuListFromPriceItem = new List<String> ();
        List<String> skuBillingMap = new List<String> ();
        String finalSku = '';
        String finalBilling = '';
        priceItemMap = fetchBillingDescriptionFromPriceItem(servAddSet);
        Set<String> priceItemKeySet = priceItemMap.keySet();
        System.debug('priceItemKeySet in existing method ' + priceItemKeySet);

        //End of EDGE-208433
        if(!(servAddSet.isEmpty())){
            for(Service_Add_On__c servAddOns : servAddSet){
                System.debug('servAddOns SKU Value ' + servAddOns.SKU__c);
                ServiceAddOnWrapperData servAddWrapObj = new ServiceAddOnWrapperData();             
                servAddWrapObj.legacyBillingAccount = servAddOns.Legacy_Billing_Account_Number__c;
                servAddWrapObj.deviceType = servAddOns.Device_Type__c;
                servAddWrapObj.deviceIDType = servAddOns.Device_ID_Type__c;
                servAddWrapObj.deviceID = servAddOns.Device_Id__c;
                servAddWrapObj.deviceManufacturer = servAddOns.Mobile_Handset_Manufacturer__c;
                servAddWrapObj.deviceModel = servAddOns.Mobile_Handset_Model__c;
                servAddWrapObj.deviceDescription = servAddOns.Device_Description__c;

                String transactionType = servAddOns.Transaction_Type__c;
                String sku = servAddOns.SKU__c;
                System.debug('deviceDescription first value' + servAddWrapObj.deviceDescription); 
                // Start of EDGE-208433
                if(transactionType == 'Migration' && sku != NULL && priceItemKeySet != NULL && priceItemKeySet.contains(sku) ){
					servAddWrapObj.deviceDescription = priceItemMap.get(sku);
                    System.debug('deviceDescription inside If ' + servAddWrapObj.deviceDescription);

                }
                //End Of EDGE-208433
                System.debug('deviceDescription final Value ' + servAddWrapObj.deviceDescription);
                servAddWrapObj.paymentType = servAddOns.Contract_Type__c;
                servAddWrapObj.remainingBalance = servAddOns.Residual_Remaining_Amount__c;
                servAddWrapObj.remainingTerm = servAddOns.Residual_Remaining_Term__c;
                servAddWrapObj.recChargeIncGst = servAddOns.Monthly_Amount__c;
                servAddWrapObj.Id = servAddOns.id;
                servAddWrapObj.deviceInstanceId = servAddOns.Instance_Id__c;                
                servAddWrapObj.status = servAddOns.Status__c;
                if(instIdList.contains(servAddWrapObj.deviceInstanceId)){
                    servAddWrapObj.isgreyedout = true;
                }else 
                    servAddWrapObj.isgreyedout = false;  
                
                //START: Added for EDGE-215103
                Integer days = 0;
                if(servAddOns.Product_End_Date__c != null){
                    servAddWrapObj.ProductEndDate = servAddOns.Product_End_Date__c;
                    days = Date.today().daysBetween(servAddOns.Product_End_Date__c);
                    if(servAddOns.Product_End_Date__c < Date.today()){
                        servAddWrapObj.TermStatus = 'Expired';
                        servAddWrapObj.isgreyedout = true;
                    }
                    else if(days < Integer.valueOf(System.Label.ProductRemainingEndDays)){
                        servAddWrapObj.TermStatus = 'Expiring Soon';
                    }
                    else{
                        servAddWrapObj.TermStatus = 'Active';
                    }
                }
                //END for EDGE-215103   
                        
                servAddWrapFinalList.add(servAddWrapObj);
            }
        }
        return servAddWrapFinalList;
    }     
    
    /**
    * @Author   :   Jayghosh Mishra
    * @Team     :   Osaka
    * @US       :   EDGE-208433
    * @Desc     :   <B2B-1701> Bill Literal Population for HRO/ARO Migration
    * */

    public static Map<String, String> fetchBillingDescriptionFromPriceItem(Set<Service_Add_On__c> servAddSet){
        Map<String, String> priceItemMap = new Map<String, String> ();
        Map<String, String> billLiteralMap = new Map<String, String> ();
        List<cspmb__Price_Item__c> priceItems = new List<cspmb__Price_Item__c>();
        String isSku = '';
        String billingDesc = '';
        String skuInPriceItem = '';
        String finalPiSku = '';
        System.debug('fetchBillingDescriptionFromPriceItem called');
        List<Service_Add_On__c> servAddOnList = new List <Service_Add_On__c> (servAddSet);
        System.debug('servAddOnList for Billing ' + servAddOnList);
        List<String> SKUList = new List <String> ();
        String billingDescription = '';
        String SKUFromServAddOn = '';
        String transactionType = '';
        if(servAddOnList != NULL){
            for(Service_Add_On__c servAddOns : servAddOnList){
                transactionType = servAddOns.Transaction_Type__c;
                if(transactionType == 'Migration'){
                    SKUFromServAddOn = servAddOns.SKU__c; 
                    SKUList.add(SKUFromServAddOn);
                }
                //priceItemMap.put(isSku, SKUList);
                System.debug('priceItemMap with sku mapping ' + priceItemMap);
            }
        }
        Set<String> skuSet = new Set<String> ();
        Set<String> billingDescSet = new Set<String> ();
        List<String> billingDescriptionList = new List<String> ();
        if(SKUList != NULL ){
         System.debug('SKUList final value ' + SKUList);
        priceItems = [SELECT Id, Billing_Description__c, cspmb__Is_Active__c, SKU__c, Contract_Type__c FROM cspmb__Price_Item__c where SKU__c IN: SKUList AND cspmb__Is_Active__c = true AND Contract_Type__c = 'Hardware Repayment'];
		}
        Set<Id> piFinalId = new Set <Id> ();
        Set<cspmb__Price_Item__c> piSet = new Set<cspmb__Price_Item__c> ();
        List<cspmb__Price_Item__c> piListForSkuBillingMapping = new List<cspmb__Price_Item__c> ();
        System.debug('priceItems List  ' + priceItems);
		System.debug('priceItems size ' + priceItems.size());
        if(!priceItems.isEmpty()){
         for(cspmb__Price_Item__c piValue : priceItems){
             String skuInstance = piValue.SKU__c;
             String newBillingLiteral = piValue.Billing_Description__c;
             if(skuInstance != NULL){
             billLiteralMap.put(skuInstance, newBillingLiteral);
             }
		 }   
		 }
          
        return billLiteralMap;
    }
    
    //End of EDGE-208433
}