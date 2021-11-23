/*******************************************************************************************************
Name          : SCSQCheckController
Created By    : Mahaboob Basha
Created Date  : July 20 2019
Description   : This class is the controller for SCSQCheckPage invoked from IP Site Configuration Button
-------
History
-------
VERSION     AUTHOR          DATE            DETAIL
-------     ------          -----           ---------
1.1         Mahaboob        20-07-2019      Created
1.1         Mahaboob        20-07-2019      Added methods fetchSiteInfo, isSQCheckEnabled
                                                        , initiateSQCheck, callSQService
1.2         Venkata Ramanan 23-07-2019      Updated methods initiateSQCheck to restrict SQ if the SQ record available is within the configurable date range
*******************************************************************************************************/
global class SCSQCheckController {

    public String basketId;
    public String adborId;
    public String configGUID;
    public cscfga__Product_Basket__c basket;
    
    public List<SiteInfoWrapper> siteDetails {get; set;}
    public String sqCheckEnabled {get; set;}
    public String sqCheckCompleted {get; set;}
    public String sqResponsesString {get; set;}
    public List<String> adborIdsToSQ = new List<String>(); //Venkat
    
    
    public SCSQCheckController() {
        try{
            basketId = ApexPages.currentPage().getParameters().get('basketId');
            adborId = ApexPages.currentPage().getParameters().get('adborId');
            configGUID = ApexPages.currentPage().getParameters().get('configGUID');
            siteDetails = new List<SiteInfoWrapper>();
            if (String.isNotEmpty(basketId)) {
                basket = [SELECT Id, cscfga__Opportunity__r.AccountId FROM cscfga__Product_Basket__c WHERE Id =: basketId LIMIT 1];
                if (String.isNotEmpty(adborId) && String.isNotEmpty(configGUID) && basket != NULL && basket.cscfga__Opportunity__r.AccountId != NULL) {
                    fetchSiteInfo();
                }
            }
            isSQCheckEnabled();
            sqCheckCompleted = 'No';
        }catch (Exception e) {
            System.debug('Exception in SCSQCheckController : ' + e.getMessage());
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Exception while loading SQ Check Page : ' + e.getMessage()));
        }
    }
    
    private void fetchSiteInfo() {
        try{
            for (cscrm__Site__c site : [SELECT Id, AdborID__c, Name, Display_Name__c,
                        (SELECT CreatedDate, Copper_Pair_Indicator__c, Max_Downstream_Speed__c, Max_Upstream_Speed__c, Technology_Type__c, Ready_for_Service_Date__c, Serviceability_Class__c, Status__c
                         FROM Service_qualifications__r ORDER BY CreatedDate DESC LIMIT 1)
                     FROM cscrm__Site__c WHERE AdborID__c =: adborId AND cscrm__Account__c =: basket.cscfga__Opportunity__r.AccountId]) {
                if (site.Service_qualifications__r.isEmpty()) {
                   siteDetails.add(new SiteInfoWrapper(site, NULL, configGUID, NULL));
                } else {
                   siteDetails.add(new SiteInfoWrapper(site, site.Service_qualifications__r[0], configGUID, NULL));
                }  
            }
        }catch (Exception e) {
            System.debug('Exception in fetchSiteInfo : ' + e.getMessage());
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Exception while fetching Site Information : ' + e.getMessage()));
        }
    }
    
    private void isSQCheckEnabled() {
        try {
            List<SQ_Check_Enablement__c> sqCheckEnablements = SQ_Check_Enablement__c.getAll().Values();
            if (sqCheckEnablements != NULL && !sqCheckEnablements.isEmpty()) {
                sqCheckEnabled = sqCheckEnablements[0].Is_SQ_Check_Enabled__c ? 'Yes' : 'No';
            }
            else {
                sqCheckEnabled = 'No';
            }
        } catch (Exception e) {
            System.debug('Exception in isSQCheckEnabled : ' + e.getMessage());
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Exception while checking for SQ Check Enablement : ' + e.getMessage()));
        }
    }
    
    public void initiateSQCheck() {
        List<String> adborIds = new List<String>();
        //List<String> adborIdsNonSQlst = new List<String>();//Venkat
        Set<String> adborIdsSet = new Set<String>();//Venkat
        
        Map<String,HttpResponse> addressToResponseMap = new Map<String,HttpResponse>();
        Map<String, String> sqFailedAdborIds = new Map<String, String>();
        List<Service_Qualification__c> sqRecordsToBeInserted = new List<Service_Qualification__c>();
        List<SiteInfoWrapper> sqResponses = new List<SiteInfoWrapper>();
        try{
            if (sqCheckEnabled == 'Yes') {
                for (SiteInfoWrapper siteInfo : siteDetails) {
                    adborIds.add(siteInfo.siteAdborId);
                    
                }
                adborIdsSet.addAll(adborIds);
                //Venkat 
                if(!adborIds.isEmpty()){
                CustomButtonInitiateSQ sqcontroller = new CustomButtonInitiateSQ();
                adborIdsToSQ = sqcontroller.getConfigurableAddressIdList(adborIds,basket.cscfga__Opportunity__r.AccountId);
                
                    adborIdsSet.removeAll(new Set<String>(adborIdsToSQ));
                }
                /*if(!adborIdsSet.isEmpty()){
                adborIdsNonSQlst = new List<String>(adborIdsSet);
                    }*/
                    //Venkat changes ends
                if (!adborIdsToSQ.isEmpty()) { //Venkat Changes
                    addressToResponseMap = callSQService(adborIdsToSQ); //Venkat changes
                    if (addressToResponseMap.isEmpty() || addressToResponseMap == NULL) {
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'SQ Failed'));
                    }
                    else
                    {
                        SiteSQContractCalloutHandler siteSQ = new SiteSQContractCalloutHandler();
                        for (SiteInfoWrapper siteInfo : siteDetails) {
                            if (addressToResponseMap.ContainsKey(siteInfo.siteAdborId)) {
                                system.debug('StatusCode for ' + siteInfo.siteAdborId + ' is ' + addressToResponseMap.get(siteInfo.siteAdborId).getStatusCode());
                                if (addressToResponseMap.get(siteInfo.siteAdborId).getStatusCode() != 200) {
                                   sqFailedAdborIds.put(siteInfo.siteAdborId, 'Error');
                                }
                                else {
                                    HttpResponse res = addressToResponseMap.get(siteInfo.siteAdborId);
                                    Logger2 logger2 = Logger2.getLogger('SiteSQAddressHandler');
                                    logger2.logMessages(siteInfo.siteAdborId, res.getBody(), '', '', '', '', false, false,Integer.valueof(res.getStatusCode()) , NULL, NULL, NULL);
                                    logger2.exitLogger();
                                    SqResponseDTO responseDTO = SqResponseDTO.parse(res.getBody());
                                    if (responseDTO != NULL && responseDTO.data != NULL) {
                                        Service_Qualification__c sqRec = new Service_Qualification__c();
                                        sqRec = siteSQ.saveSQResponse(siteInfo.siteAdborId, responseDTO, basket.cscfga__Opportunity__r.AccountId);
                                        sqRecordsToBeInserted.add(sqRec);
                                        List<SqResponseDTO.ServiceTypeQualifications> srvQualifications = responseDTO.data.serviceTypeQualifications;
                                        if(!srvQualifications.isEmpty()) {
                                            SqResponseDTO.ServiceTypeQualifications sq = srvQualifications[0];
                                            siteInfo.sqDisplayStatus = sq.Status;
                                            siteInfo.sqResponseInfo.sqStatus = sq.Status;
                                            siteInfo.sqResponseInfo.nbnAvailability = sq.Status == 'Available' ? 'Available' : 'Not Available';
                                            siteInfo.sqResponseInfo.nbnRFSDate = sq.readyForServiceDate;
                                            siteInfo.sqResponseInfo.nbnTechnologyType = sq.technologyType;
                                            //Translation for technologytype
                                            if(sq.technologyType=='Fibre To The Node'){
                                                siteInfo.sqResponseInfo.nbnTechnologyTypeAcrnym = 'FTTN';
                                            }else if(sq.technologyType=='Fibre To The Building'){
                                                siteInfo.sqResponseInfo.nbnTechnologyTypeAcrnym = 'FTTB';
                                            }else if(sq.technologyType=='Fibre To The Curb'){
                                                siteInfo.sqResponseInfo.nbnTechnologyTypeAcrnym = 'FTTC';
                                            }else if(sq.technologyType=='Fibre To The Premise'){
                                                siteInfo.sqResponseInfo.nbnTechnologyTypeAcrnym = 'FTTP';
                                            }else if(sq.technologyType=='Fibre'){
                                                siteInfo.sqResponseInfo.nbnTechnologyTypeAcrnym = 'FTTP';
                                            }else if(sq.technologyType=='Wireless'){
                                                siteInfo.sqResponseInfo.nbnTechnologyTypeAcrnym = 'Fixed Wireless';
                                            }else {
                                                siteInfo.sqResponseInfo.nbnTechnologyTypeAcrnym = sq.technologyType;
                                            }
                                            //translation ends here
                                            siteInfo.sqResponseInfo.nbnServiceabilityClass = sq.serviceabilityClass;
                                            siteInfo.sqResponseInfo.copperPairIndicator = sq.copperPairIndicator;
                                            siteInfo.sqResponseInfo.nbnCompatibility = ((sq.copperPairIndicator != null && (sq.copperPairIndicator.toLowerCase() == 'yes' || sq.copperPairIndicator.toLowerCase() == 'na' )) || sq.technologyType=='Fibre To The Premise' || sq.technologyType=='FTTP' || sq.technologyType=='Fibre') ? 'Yes' : 'No';
                                            for(SqResponseDTO.Characteristics chars : sq.characteristics){
                                                if(chars.name.containsIgnoreCase('Downstream')){
                                                    siteInfo.sqResponseInfo.nbnMaxDownloadSpeed = chars.value;
                                                }
                                                if(chars.name.containsIgnoreCase('Upstream')){
                                                    siteInfo.sqResponseInfo.nbnMaxUploadSpeed = chars.value;
                                                }
                                            }
                                            sqResponses.add(siteInfo);
                                        }
                                    }
                                }
                            }
                        }
                        if (!sqRecordsToBeInserted.IsEmpty()) {
                            INSERT sqRecordsToBeInserted;
                            sqCheckCompleted = 'Yes';
                            System.debug('Inserted SQ Records : ' + sqRecordsToBeInserted);
                             // Save partial response : ProviderResources
                            siteSQ.saveProviderResources(sqRecordsToBeInserted, addressToResponseMap);
                        }
                        System.debug('sqFailedAdborIds : ' + sqFailedAdborIds);
                        if (!sqFailedAdborIds.isEmpty()) {
                            for (SiteInfoWrapper siteInfo : siteDetails) {
                                siteInfo.sqDisplayStatus = sqFailedAdborIds.containsKey(siteInfo.siteAdborId) ? sqFailedAdborIds.get(siteInfo.siteAdborId) : siteInfo.sqDisplayStatus;
                            }
                        }
                    }
                }
                //Venkat Change Begins
                else
                {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'SQ check already has the latest data within the Configured date range'));
                }
                //Venkat Change Ends
                sqResponsesString = !sqResponses.isEmpty() ? JSON.serialize(sqResponses) : '';
                System.debug('sqCheckCompleted : ' + sqCheckCompleted);
            } else {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'SQ Check is disabled. Please Enable it before proceeding further'));
            }
        }catch (Exception e) {
            System.debug('Exception in initiateSQCheck : ' + e.getMessage());
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Exception while initiating SQ Check : ' + e.getMessage()));
        }
    }
    
    private Map<String,HttpResponse> callSQService(List<String> eligibleAdborIds){
        SqResponseDTO responseDTO = NULL;
        HttpResponse response;
        String payload = '';
        String serviceFilter = 'Internet';
        Map<String,HttpResponse> addressToResponseMap = new Map<String,HttpResponse>();
        
        try{    
            String token = AuthenticationManager.getOauthToken('SiteSQAddressHandler');
            for(String addressId : eligibleAdborIds){
                payload = 'addressId=' + addressid +'&serviceFilter='+serviceFilter;
                Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token};
                response = IntegrationRecordHandlerUtil.callout(payload, 'GET', headerMap, 'SiteSQAddressHandler', NULL, NULL);
                String responseCode = String.valueOf(response.getStatusCode());
                System.debug('Response : ' + response);  
                addressToResponseMap.put(addressid, response);
            }
        }catch (Exception e) {
            System.debug('Exception in callSQService : ' + e.getMessage());
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Exception while checking for Service Qualification : ' + e.getMessage()));
        }       
        System.debug('addressToResponseMap Size'+addressToResponseMap.Size());
        return addressToResponseMap;
    }
    
}