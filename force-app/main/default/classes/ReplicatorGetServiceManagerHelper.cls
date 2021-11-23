public class ReplicatorGetServiceManagerHelper {
    public static Map<String, String> getABNBasedOnSourceCIDN(Set<String> sourceCidn){
        Map<String, String> CIDNABNMap = new map<String, String>();
        String cidn = '';
        String abn = '';
        List<Account> accList = [Select Id, Name, ABN__c, CIDN__c From Account where CIDN__c IN : sourceCidn];
        if(accList != NULL){
            for(Account acc : accList){
                abn = acc.ABN__c;
                cidn = acc.CIDN__c;
                CIDNABNMap.put(cidn, abn);
            }
        }
        return CIDNABNMap;
    }
    
     /**
* @Author   :   Jayghosh Mishra
* @Date     :   Feb 2021
* @Desc     :   Getting Profile info for sales users and assurance User
* @US       :   EDGE-201124
* @Status   :   Development
* */
    public static Boolean getProfileInfoForSalesUser (){
        Id profile_id=userinfo.getProfileId();
        system.debug('~~'+profile_id);
        boolean allowUploadMultiCIDN = false;
        String profile_name = [select Name from Profile where id = :profile_id].Name;
        System.debug('Sales-Enterprise-Unified ~~'+profile_name);
        if(profile_name == 'Sales-Enterprise-Unified' || profile_name == 'Assurance Service Agent'){
            allowUploadMultiCIDN = true;
        }
        System.debug('applicableMultiCIDNValidation ' + allowUploadMultiCIDN);
        return allowUploadMultiCIDN;
    }
/******************************************************************
* @Author   :   Abhishek Mallick
* @Desc     :   Wrapper to construct Data for Grid View Display
* @US       :   EDGE-211350
* @Status   :   Development
* *****************************************************************/

    public class CIDNWrapper {
        @AuraEnabled
        public string Id { get; set; }
        @AuraEnabled
        public string source_CIDN { get; set; }
        @AuraEnabled
        public List<ReplicatorGetServiceManager.TableWrapper> tableWrapperList { get; set; }
        
    }
    
/******************************************************************
* @Author   :   Abhishek Mallick
* @Desc     :   This method constructs input into CIDNWrapper format
* @US       :   EDGE-211350
* @Status   :   Development
* *****************************************************************/
    public static String populateCidnWrapper(List<ReplicatorGetServiceManager.TableWrapper> tableWrapperList){
        String returnWrapperList;
        Set<String> uniqueCidn = new Set<String>();
        System.debug('Input:::'+tableWrapperList);
        List<CIDNWrapper> cidnWrapperList = new List<CIDNWrapper>();
        
        for(ReplicatorGetServiceManager.TableWrapper tableRec : tableWrapperList){
            if(tableRec.source_CIDN!= null && tableRec.source_CIDN!= ''){
                uniqueCidn.add(tableRec.source_CIDN);
            }
        }
        System.debug('Unique Set::'+uniqueCidn);
        for(String cidnRec : uniqueCidn){
            CIDNWrapper cidnWrapRec = new CIDNWrapper();
            List<ReplicatorGetServiceManager.TableWrapper> listTableWrap = new List<ReplicatorGetServiceManager.TableWrapper>();
            cidnWrapRec.tableWrapperList = new List<ReplicatorGetServiceManager.TableWrapper>();
            String uniqueId = '';
            for(ReplicatorGetServiceManager.TableWrapper wrapTableRec : tableWrapperList){
                if(cidnRec == String.valueOf(wrapTableRec.source_CIDN)){
                    System.debug('CIDN Value:::'+wrapTableRec.source_CIDN);
                    System.debug('Check Value'+wrapTableRec.checkValue);
                    wrapTableRec.source_CIDN = '';
                    cidnWrapRec.tableWrapperList.add(wrapTableRec);
                }
                
            }
            //System.debug('ListTableWrapper::'+listTableWrap);
            
            cidnWrapRec.source_CIDN = cidnRec;
            cidnWrapRec.Id = 'CIDN~!@@!~'+cidnWrapRec.source_CIDN;
            //cidnWrapRec.tableWrapperList = listTableWrap;
            cidnWrapperList.add(cidnWrapRec);
        }
        returnWrapperList = JSON.serializePretty(cidnWrapperList);
        System.debug('Wrapper List::'+returnWrapperList);
        return JSON.serializePretty(cidnWrapperList);
    }
    /**
     * @Author   :   Jayghosh Mishra
     * @Desc     :   1) getAMFromReplicator, getFNNs, getDuplicateServiceIds, getReplicatorEligibilityRules:- Existing methods have been taken out from ReplicatorGetServiceMager
     				 class as part of this story.
					 2) prepareHeader:- new method has been created to centralize request header logic for getSiteAgnosticServices and getSiteAgnosticServicesNGUC
     * @US       :   DIGI-1746:- Technical changes for ReplicatorGetServiceManager 
	*/
    // Start of EDGE-186493: Osaka: Jay: Fetching the Opportunity detail for the given basket
    @AuraEnabled
    public static String getAMFromReplicator(String basketId) {
        String migrationTransitionType = '';
        List < cscfga__Product_Basket__c > prodBasketList = [Select id, name, cscfga__Opportunity__c, cscfga__Opportunity__r.Type from cscfga__Product_Basket__c where id =: basketId];
        if (prodBasketList != null) {
            // Iterating once for unique basketId
            for (cscfga__Product_Basket__c filteredBasket: prodBasketList) {
                if (filteredBasket.cscfga__Opportunity__r.Type == 'Migration') {
                    migrationTransitionType = 'Migration';
                }
            }
        }
        return migrationTransitionType;
    }
    // End of EDGE-186493
    
     @AuraEnabled
    public static String getFNNs(String finCIDN, List < String > prodFamilies, String basketId) {
        List < Legacy_Service__c > legacyServiceList = new List < Legacy_Service__c > ();
        List < String > filteredServiceList = new List < String > ();
        
        String fnn = '';
        List < Id > serviceId = new List < Id > ();
        
        Boolean allowUploadMultiCIDN = ReplicatorGetServiceManagerHelper.getProfileInfoForSalesUser();
        
        if (allowUploadMultiCIDN) {
            legacyServiceList = [Select id, Service_Id__c, Account__r.CIDN__c from Legacy_Service__c where Product_Basket__r.Id =: basketId and Product_Type__c IN: prodFamilies];
        } else {
            legacyServiceList = [Select id, Service_Id__c, Account__r.CIDN__c from Legacy_Service__c where Product_Basket__r.Id =: basketId and Account__r.CIDN__c =: finCIDN and Product_Type__c IN: prodFamilies];
        }
        if (legacyServiceList.size() > 0) {
            for (Legacy_Service__c fsl: legacyServiceList) {
                
                filteredServiceList.add(fsl.Service_Id__c);
                
            }
            
            if (filteredServiceList.size() > 0) {
                fnn = String.join(filteredServiceList, ',');
            }
        }
        System.debug('Final values in fnn ' + fnn);
        return fnn;
    }
    // End of EDGE-189352                                        
    
    
    /**
* @Author   :   Jayghosh Mishra
* @Desc     :   This method returns list of duplicate Service Id which are present in another basket to mark it as ineligible for current basket
* @US       :   EDGE-198138
* @Status   :   Development
* */
   /* public static set < String > getDuplicateServiceIds(String basketId) {
        System.debug('Inside getDuplicateServiceIds');
        Set < String > allExistingServiceIds = new set < String > ();
        String serviceId = '';
        //Added Select__c in Select and Where clause as a part of EDGE-212146 by Abhishek(Osaka)
        List < Legacy_Service__c > existingLegecyServices = [Select id, Service_Id__c, Account__r.CIDN__c, Product_Basket__r.csordtelcoa__Basket_Stage__c, Product_Basket__r.cscfga__Opportunity__r.StageName,Select__c from Legacy_Service__c where Product_Basket__c !=: basketId AND Product_Basket__r.csordtelcoa__Basket_Stage__c != 'Cancelled' AND Select__c = true];
        //Changes to remove SonarQube vulnerabilities  by Abhishek(Osaka)(Adding Null and size check for legacy service object list)
        if(existingLegecyServices!=Null && existingLegecyServices.size()>0){
            for (Legacy_Service__c existingServiceIds: existingLegecyServices) {
                if (existingServiceIds.Service_Id__c != NULL || existingServiceIds.Service_Id__c != '') {
                    serviceId = ExistingServiceIds.Service_Id__c;
                    allExistingServiceIds.add(serviceId);
                }
            }
        }
        System.debug('allExistingServiceIds' + allExistingServiceIds);
        return allExistingServiceIds;
    }*/

    public static set < String > getDuplicateServiceIds(TransitionDataDTO transitionMoblileData,String basketId) {
        System.debug('Inside getDuplicateServiceIds');
        Set < String > allExistingServiceIds = new set < String > ();
        List<String> serviceIdList = new List<String>();
        String serviceId = '';
        for (TransitionDataDTO.productListDTO tMobileDataProduct: transitionMoblileData.productList) {
        for (TransitionDataDTO.SiteDTOMobile tMobileDataSite: tMobileDataProduct.site) {
        for (TransitionDataDTO.serviceListDTOMobile tMobileDataServiceList: tMobileDataSite.serviceList) {
        for (TransitionDataDTO.groupDTOMobile tMobileDataGroupType: tMobileDataServiceList.groupType) {
        for (TransitionDataDTO.serviceDTOMobile tMobileDataService: tMobileDataGroupType.service) {
        ServiceId = tMobileDataService.Service_Id;
        serviceIdList.add(ServiceId);
        }
        }
        }
        }
        }
        System.debug('serviceIdList coming from TransitionDataDTO ' + serviceIdList);
        System.debug('serviceIdList size in helper ' + serviceIdList.size());
        //Added Select__c in Select and Where clause as a part of EDGE-212146 by Abhishek(Osaka)
        List < Legacy_Service__c > existingLegecyServices = new List < Legacy_Service__c >();
        if(serviceIdList != NULL){
        existingLegecyServices = [Select id, Service_Id__c, Account__r.CIDN__c, Product_Basket__r.csordtelcoa__Basket_Stage__c, Product_Basket__r.cscfga__Opportunity__r.StageName,Select__c from Legacy_Service__c where Product_Basket__c !=: basketId AND Product_Basket__r.csordtelcoa__Basket_Stage__c != 'Cancelled' AND Select__c = true AND Service_Id__c IN: serviceIdList];
        }
        System.debug('existingLegecyServices in replicatorGetServiceManagerHelper ' + existingLegecyServices);
        System.debug('existingLegecyServices size in replicatorGetServiceManagerHelper ' + existingLegecyServices.size());
        //Changes to remove SonarQube vulnerabilities by Abhishek(Osaka)(Adding Null and size check for legacy service object list)
        if(existingLegecyServices!=Null && existingLegecyServices.size()>0){
        for (Legacy_Service__c existingServiceIds: existingLegecyServices) {
        if (existingServiceIds.Service_Id__c != NULL || existingServiceIds.Service_Id__c != '') {
        serviceId = ExistingServiceIds.Service_Id__c;
        allExistingServiceIds.add(serviceId);
        }
        }
        }
        System.debug('allExistingServiceIds' + allExistingServiceIds);
        System.debug('allExistingServiceIds size in helper ' + allExistingServiceIds.size());
        return allExistingServiceIds;
        }
    
     @AuraEnabled
    public static Map < String, Replicator_Eligibility_Rule__mdt > getReplicatorEligibilityRules() {
        Map < String, Replicator_Eligibility_Rule__mdt > metaDataMap = new Map < String, Replicator_Eligibility_Rule__mdt > ();
        for (Replicator_Eligibility_Rule__mdt obj: [SELECT MasterLabel, Compatibility__c, Identifier_Value__c, Reason__c From Replicator_Eligibility_Rule__mdt])
            metaDataMap.put(obj.MasterLabel, obj);
        return metaDataMap;
    }
    
     public static map<String, String> prepareHeader (String finCIDN, List < String > prodFamilies, String basketId, String cidnHierarchy, Boolean isCidnHierarchy, String selectedProdFamily, String sioConfigMode){//Added sioConfigMode for DIGI-1681){
        System.debug('---prepareHeader---'+sioConfigMode);
        Set<String> markatableOfferIdSet = new Set<String> ();
         map <String, String> headerMap = new map <String, String> ();
       	String cidn = finCIDN;
		// Start of EDGE-186493: Osaka: Jay: Enhance get Service API for the AM migration.
        String transitionType = ReplicatorGetServiceManagerHelper.getAMFromReplicator(basketId);
        // End of EDGE-186493
        // Preparing head for HTTP request --
        String GETSERVICE_EVENT = 'ReplicatorLegacyAssetService';
        String token = AuthenticationManager.getOauthToken(GETSERVICE_EVENT);
       String correId = IntegrationRecordHandlerUtil.getCorrelationId();
       String FNNs = '';
        String legacyServiceCount;
        //Added hierarchy check:Osaka:Ramya:EDGE-190192
        FNNs = ReplicatorGetServiceManagerHelper.getFNNs(finCIDN, prodFamilies, basketId);
        System.debug('FNNs returned by getFNNs ' + FNNs);
        
        
        // End of EDGE-189352
        // Start of EDGE-173830: Osaka: Ramya: Read from custom label for number of services.
        legacyServiceCount = Label.TransitionLegacyServiceLimit;
        // End of EDGE-173830
        //Added if else condition for DIGI-1681
        Boolean sioConfigModeToggle =  FeatureEligibilityChecker.determineFeatureEligiblity('sioConfigMode',null);
        if(transitionType == 'Migration' && sioConfigModeToggle && String.isNotBlank(sioConfigMode) && sioConfigMode.containsIgnoreCase('Auto')){
            legacyServiceCount = ConstantMetadataUtility__mdt.getInstance('AutoTransitionLegacyServiceLimit').Value__c;
        }
        //END for DIGI-1681
        System.debug('---legacyServiceCount---'+legacyServiceCount);
        
       String productFamilyString = '';
        if (prodFamilies.size() > 0) {
            productFamilyString = String.join(prodFamilies, ',');
        }
        //Start of EDGE-209885 by Abhishek(Osaka) to append Target CIDN for CIDN Hierarchy only
        String selectedProdFamilyList = selectedProdFamily;
        String cidnValueList = cidnHierarchy+','+cidn;//This will be only used in case of CIDN Hierarchy.
        System.debug('Appended Target CIND:'+cidnValueList);
        //End of EDGE-209885 by Abhishek(Osaka)
        //START: Added for DIGI-1681
        String sendAddOnsConfig = '';
        if(sioConfigModeToggle){
            sendAddOnsConfig = String.isNotBlank(sioConfigMode) && sioConfigMode.containsIgnoreCase('Auto')?'Y':'N';
        }
        //END for DIGI-1681
       
			if (isCidnHierarchy) {
            System.debug('Inside isCidnHierarchy');
            headerMap = new Map < String,
                String > {
                    'Content-Type' => 'application/json',
                        'Authorization' => 'Bearer ' + token,
                        'correlationId' => correId,
                        //Start of EDGE-209885 by Abhishek(Osaka)
                        'productFamily' => selectedProdFamilyList,
                        'cidn' => cidnValueList,
                        'sendAddOnsConfig' => sendAddOnsConfig//Added for DIGI-1681
                        };
                            } else {
                                if (FNNs == '') {
                                    System.debug('Inside bank FNN');
                                    headerMap = new Map < String,
                                        String > {
                                            'Content-Type' => 'application/json',
                                                'Authorization' => 'Bearer ' + token,
                                                'correlationId' => correId,
                                                'productFamily' => selectedProdFamilyList,
                                                'cidn' => cidn,
												'sendAddOnsConfig' => sendAddOnsConfig//Added for DIGI-1681
                                                };
                                                    } else {
                                                        System.debug('Inside FNNList');
                                                        headerMap = new Map < String,
                                                            String > {
                                                                'Content-Type' => 'application/json',
                                                                    'Authorization' => 'Bearer ' + token,
                                                                    'correlationId' => correId,
                                                                    'cidn' => cidn,
                                                                    'service' => FNNs,
                                                                    'sendAddOnsConfig' => sendAddOnsConfig//Added for DIGI-1681
                                                                    };
                                                                        }
                            }
        
          Map<string,Sobject> MTMMetadataUtilityMap = ConstantMetadataUtility.getConstantMetadataUtilityRecords('MTM_Metadata_Utility__mdt');
          String mobilityOfferId = String.valueOf(MTMMetadataUtilityMap.get('Adaptive_Mobility_Markatable_Offer_Check').get('Value__c'));
         List<cscfga__Product_Configuration__c> prodConfigList = [Select Id, Name,Marketable_Offer__c, cscfga__Product_Basket__c, Marketable_Offer__r.Offer_ID__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =: basketId];
		if(prodConfigList != NULL){
            for(cscfga__Product_Configuration__c prodConfigRec : prodConfigList){
                if(prodConfigRec.Marketable_Offer__r.Offer_ID__c != NULL){
                    String markatableOfferId = prodConfigRec.Marketable_Offer__r.Offer_ID__c;
                    markatableOfferIdSet.add(markatableOfferId);
                }
            }
        }
         if(markatableOfferIdSet.contains(mobilityOfferId)){
            headerMap.put('serviceCount', legacyServiceCount); 
            headerMap.put('transitionType',transitionType);
         }
        return headerMap;
    }
    // End of DIGI-1746
        
}