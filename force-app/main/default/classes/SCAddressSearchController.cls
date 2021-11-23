/*
===============================================================================================================================
Class : SCAddressSearchController
Developer Name : Shubhi
Test Class : SCAddressSearchControllerTest
===============================================================================================================================
Sr.No.    Developer Name        Date          Story Description
1           Vimal               7/12/2019       Created for solution console to support site sq and legacy sites creation
2           Shubhi              7/12/2019       Edge-99110 Q record is not getting created at site level on click of SQ Check button from Solution Console
3           Shubhi              7/12/2019       EDGE-105508  Replicator sites are not populating while searching inside the product basket for CRM and PRM.
4           Rohit T             8/03/2019       EDGE-105802 Unable to search sites in the basket and not able to Progress the Order
5           Manoj               05 Aug 2019     19.01 || QA2 || Solution Console || Replicator sites are not populating while searching inside the product basket for CRM and PRM.

6           Tihomir             09/05/2019       EDGE-83354 - additional info for failed sq
7           Ashish/Shubhi               20 Aug 2019        CRQ000004439482 production incident
8           Antun               09/07/2019      Changes for TID
9           Abinash/Pawan       27/09/2019      Fixes for prod issue EDGE-111452 : NBN Unavailable sites are not able to be added to the basket as per the attached email.
10           shubhi             04/10/2019      Edge-113351
11          Samish              25/11/2019      EDGE-98322 - Initiate the widefeas API1 from solution console and display the SQ results against site
12          Gnana               27/12/2019      EDGE-127666 - Modified isSQCheckEnabled, makeSQCallout,runSearch  methods to reduce cyclomatic complexity
13          Samish/Pawan        02-Jan-2020     EDGE-113537 - Common logging framework.
===============================================================================================================================
*/global with sharing class SCAddressSearchController {

    private CalloutResponseAddressCheck2 calloutResponseAddressCheck2;
    public static boolean testCheck = false;
    private List < Map < String, Object >> responseSiteRecordList;

     private String cidn;
     private String enterpriseId;

    public List < AddressSummary > addressList {get;set;}
    
    //--------Added for EDGE-98322 by Samish START--------//
    List<String> addressidList=null;
    public Integer counter =0;
    SQcheckCalloutHandler sqChkCtr = null;
    //--------Added for EDGE-98322 by Samish END--------//

    public String selectedAddressList {get;set;}

    public string ipSiteconfigId {get;private set;}

    public String caller {get; set;}
    public String offerId {get; set;} //EDGE-108959
    public String offerSQcheckRequired {get; set;} //EDGE-108959

    public String searchString {get;set;}
    
    public String sqCheckEnabled {get; set;}

    public String sqCheckCompleted {get; set;}
    
    public String sqCheckRequired {get; set;}
    
    public String allowedToAdd {get; set;}
    
    public Set<String> sqUnavailAdborIds = new Set<String>();
    
    public List<AddressSummary> hiddenAddressList {get;set;}
    
    public List<Service_Qualification__c> sqRecordToBeInserted {get;set;}
    public Map<String,Service_Qualification__c> sqRecordToBeInsertedMap {get;set;}
    
    //public SiteSQContractCalloutHandler siteSQ {get;set;}
    
    public transient Map<String,HttpResponse> addressToSQResponseMap ;
    
    public Map<String,List<Service_Qualification_Provider_Resource__c>> providerresourceListMap {get; set;}
    private String CARRIAGESOLUTION = '';                                   //Added for EDGE-98322 by Samish
    private List<Offer_to_SQ_mapping__mdt> lstSQMapping;                    //Added for EDGE-98322 by Samish
    public String newOfferSQcheckRequired {get; set;}                       //Added for EDGE-98322 by Samish
    
    public SCAddressSearchController() {
        calloutResponseAddressCheck2 = new CalloutResponseAddressCheck2();
        addressList = new List < AddressSummary > ();
        hiddenAddressList = new List < AddressSummary > ();
        selectedAddressList = '';
        sqCheckCompleted = 'No';
        sqCheckRequired = 'No';
        allowedToAdd = 'No';
        isSQCheckEnabled();
        ipSiteconfigId = ApexPages.currentPage().getParameters().get('configId');
        caller = ApexPages.currentPage().getParameters().get('caller');
        offerId = ApexPages.currentPage().getParameters().get('offerId'); //EDGE-108959
        isOfferSQcheckRequired();//EDGE-108959
        system.debug('@@@@# offerId= '+offerId);
    }

    @TestVisible
    private void isSQCheckEnabled() {
        try {
            if(Test.isRunningTest() && testCheck){
                CalloutException e = new CalloutException();
                throw e;
            }
            List<SQ_Check_Enablement__c> sqCheckEnablements = SQ_Check_Enablement__c.getAll().Values();
            sqCheckEnabled = (sqCheckEnablements != NULL && !sqCheckEnablements.isEmpty()) ? (sqCheckEnablements[0].Is_SQ_Check_Enabled__c ? 'Yes' : 'No') : 'No'; // Added as part of Cyclomatic complexity: EDGE-127666 tech debt by Gnana
            // Commented below code as part of Cyclomatic complexity: EDGE-127666 tech debt by Gnana - Start
            /*if (sqCheckEnablements != NULL && !sqCheckEnablements.isEmpty()) {
                sqCheckEnabled = sqCheckEnablements[0].Is_SQ_Check_Enabled__c ? 'Yes' : 'No';
            }
            else {
                sqCheckEnabled = 'No';
            }*/
            // Commented above code as part of Cyclomatic complexity: EDGE-127666 tech debt by Gnana - End
            
            
        } catch (Exception e) {
            System.debug('Exception while checking for SQ Check ENablement : ' + e.getMessage());
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Exception in isSQCheckEnabled : ' + e.getMessage()));
        }
    }

    public void makeSQCallout(String techType) {            //changed to accommodate technology type for Telstra Fibre and NBN - EDGE-98322 by Samish
        system.debug('@@@@# techType=== '+techType);
        List<String> adborIds = new List<String>();
        List<String> eligibleAdborIds = new List<String>();
        Map<String,HttpResponse> addressToResponseMap = new  Map<String,HttpResponse>();
        Map<String, String> sqFailedAdborIds = new Map<String, String>();

        //--------------Added for EDGE-98322 by Samish START-------------//
        //SQ Check for 'Telstra Fibre'
        if(techType.equalsIgnoreCase('Telstra Fibre')){
            String optyAccountId = '';
            WidefeaseSQResponseDTO responseDTO =null;
            String sqHandler = [SELECT Id, DeveloperName FROM Integration_Handler__mdt WHERE MasterLabel = 'WidefeasSQAddressHandler'].DeveloperName;
            system.debug('@@@@# sqHandler=== '+sqHandler);
            Logger2 logger = Logger2.getLogger(sqHandler);
            Map<String, AddressSummary> map_adborID_AddressDetail = new Map<String, AddressSummary>();
            lstSQMapping = new List<Offer_to_SQ_mapping__mdt>();
            
            system.debug('@@@@# offerId=== '+offerId);
            

                
            try {
            if(Test.isRunningTest() && testCheck){
                CalloutException e = new CalloutException();
                throw e;
                }
                String basketId = ApexPages.currentPage().getParameters().get('basketId');
                
                //get Product basket related to basketid
                List<cscfga__Product_Basket__c> lstPrdBasket = [SELECT Id, cscfga__Opportunity__c, cscfga__Opportunity__r.AccountId FROM cscfga__Product_Basket__c WHERE id =: basketId LIMIT 1];
                system.debug('@@@@# all addressList====>>>>>>'+addressList);

                //get list of selected addresses
                List<AddressSummary> lstSelectedAddress = getSelectedAddressList(addressList);
                system.debug('@@@@# lstSelectedAddress====>>>>>>'+lstSelectedAddress);

                //collecting all adborIDs as map key
                for (AddressSummary addr: addressList){
                    map_adborID_AddressDetail.put(addr.adborID, addr);
                }
                system.debug('@@@@# map_adborID_AddressDetail=== '+map_adborID_AddressDetail);

                //get adborID of selected addresses
                for (AddressSummary addr: lstSelectedAddress) {
                    adborIds.add(addr.adborID);
                }
                //system.debug('@@@@# selected adborIds====>>>>>>'+adborIds);
            
                if (adborIds.isEmpty()) {
                    allowedToAdd = 'Yes';
                }
                else if (!adborIds.isEmpty() && lstPrdBasket.size()>0) {
                    eligibleAdborIds = adborIds;
                    optyAccountId = lstPrdBasket[0].cscfga__Opportunity__r.AccountId;
                    if (!eligibleAdborIds.isEmpty()) {
                        addressidList = eligibleAdborIds;
                        sqChkCtr = new SQcheckCalloutHandler(eligibleAdborIds, optyAccountId);          //accid to be initialized by optyAccountId
                        String token = AuthenticationManager.getOauthToken(sqHandler);
                        //System.debug('@@@@#token= '+token);
                        addressToResponseMap = widefeasCalloutSQ(token,techType,sqHandler);     //bulkified to collect all the responses
                        // responseDTO = sqChkCtr.widefeasCalloutSQ(token,techType);            //returned only last response
                        System.debug('@@@@#counter= '+counter);
                        System.debug('@@@@# addressToResponseMap= '+addressToResponseMap);
                        
                        if(addressidList.size()>0 && addressToResponseMap!=null){
                            for(String addId: addressToResponseMap.keyset()){
                                HttpResponse res = addressToResponseMap.get(addId);
                                System.debug('HttpResponse :=  '+'addID : '+addId+'==> response : '+res+'  body  '+res.getBody());
                                
                                if (res.getStatusCode() == 200 || res.getStatusCode() == 201 || res.getStatusCode() == 202) {
                                    System.debug('res.getBody()---->'+res.getBody());
                                    responseDTO = WidefeaseSQResponseDTO.parse(res.getBody());
                                    
                                    //logger.logMessages(addId, res.getBody(), '', '', '', '', false, false,Integer.valueof(res.getStatusCode()) , null, null, null);       //Commented by Samish for EDGE-113537
                                    
                                    // for (AddressSummary addr: addressList) {
                                    for (AddressSummary addr: lstSelectedAddress) {
                                        system.debug('@@@@# lstSelectedAddress1= '+lstSelectedAddress);
                                        if (addr.addressId==addId) {
                                            Boolean isEthernetMAN_TID_Available = false;Boolean isEthernetMAN_TID_MaybeAvailable = false;                                            
                                            String crgSolReasonCode_Available = '';String crgSolReasonCode_MaybeAvailable = '';
                                            List<WidefeaseSQResponseDTO.location> locationlist = responseDTO.data.location; 
                                            for(WidefeaseSQResponseDTO.location loc : locationlist){
                                                for(WidefeaseSQResponseDTO.ProductDetails prod : loc.productDetails){
                                                    if(prod.carriageSolution.equalsIgnoreCase(CARRIAGESOLUTION)){
                                                        if(String.isNotBlank(prod.carriageSolutionStatus)){
                                                            if(prod.carriageSolutionStatus.equalsIgnoreCase('Available')){
                                                                isEthernetMAN_TID_Available = true;crgSolReasonCode_Available = prod.carriageSolutionReasonCode;                                                              
                                                            }
                                                            else if(prod.carriageSolutionStatus.equalsIgnoreCase('MaybeAvailable')){
                                                                isEthernetMAN_TID_MaybeAvailable = true;crgSolReasonCode_MaybeAvailable = prod.carriageSolutionReasonCode;                                                                
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            //if Responses = "Available && MaybeAvailable" AND "MaybeAvailable && MaybeAvailable"
                                            if(isEthernetMAN_TID_MaybeAvailable){
                                                addr.telstraFibreStatus = 'MaybeAvailable';addr.telstraFibreAdditionalInfo = crgSolReasonCode_MaybeAvailable;                                               
                                            }
                                            //if Responses = Available && Available
                                            else if(isEthernetMAN_TID_Available && !isEthernetMAN_TID_MaybeAvailable){
                                                addr.telstraFibreStatus = 'Available';addr.telstraFibreAdditionalInfo = crgSolReasonCode_Available;                                                
                                            }
                                            
                                            system.debug('@@@@# lstSelectedAddress2= '+lstSelectedAddress);
                                        }
                                        
                                        // Moved below code to avoid for loop iterating same list EDGE-127666 tech debt by Gnana - Start
                                        //putting telstraFibreStatus && telstraFibreAdditionalInfo of selected addresses into map
                                        if(map_adborID_AddressDetail.containsKey(addr.adborID)){
                                            map_adborID_AddressDetail.get(addr.adborID).telstraFibreStatus = addr.telstraFibreStatus;
                                            map_adborID_AddressDetail.get(addr.adborID).telstraFibreAdditionalInfo = addr.telstraFibreAdditionalInfo;
                                        }
                                        // Moved above code to avoid for loop iterating same list EDGE-127666 tech debt by Gnana - End
                                    }
                                    sqChkCtr.saveWidefeasSQResponse(addId,responseDTO);     //calling Nirvana's existing logic
                                    
                                    // Commented below code as part of Cyclomatic complexity: EDGE-127666 tech debt by Gnana - Start
                                    /*putting telstraFibreStatus && telstraFibreAdditionalInfo of selected addresses into map
                                    for (AddressSummary addr: lstSelectedAddress){
                                        if(map_adborID_AddressDetail.containsKey(addr.adborID)){
                                            map_adborID_AddressDetail.get(addr.adborID).telstraFibreStatus = addr.telstraFibreStatus;
                                            map_adborID_AddressDetail.get(addr.adborID).telstraFibreAdditionalInfo = addr.telstraFibreAdditionalInfo;
                                        }
                                    }*/
                                    // Commented above code as part of Cyclomatic complexity: EDGE-127666 tech debt by Gnana - End

                                    if(map_adborID_AddressDetail!=null && !map_adborID_AddressDetail.isEmpty()){
                                        for(AddressSummary addr : addressList){
                                            if(map_adborID_AddressDetail.containsKey(addr.adborID)){
                                                addr.telstraFibreStatus = map_adborID_AddressDetail.get(addr.adborID).telstraFibreStatus;
                                                addr.telstraFibreAdditionalInfo = map_adborID_AddressDetail.get(addr.adborID).telstraFibreAdditionalInfo;
                                            }
                                        }
                                    }
                                    system.debug('@@@@# addressList final= '+addressList);
                                    selectedAddressList = JSON.serialize(getSelectedAddressList(addressList));//testing
                                }
                                else {
                                    responseDTO = WidefeaseSQResponseDTO.parse(res.getBody());
                                    system.debug('responseDTO' +responseDTO);
                                    // logger.logMessages(addId, res.getBody(), '', '', '', '', false, false, Integer.valueOf(res.getStatusCode()) , null, null, null);     //Commented by Samish for EDGE-113537
                                }
                                
                                // logger.exitLogger();         //Commented by Samish for EDGE-113537
                            }
                        }
                    }
                }
            }
            catch (Exception e) {
                System.debug('Exception while checking for Service Qualification : ' + e.getMessage());
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Exception in makeSQCallout : ' + e.getMessage()));
                Logger2 logger1 = Logger2.getLogger('SiteSQAddressHandler');
                logger1.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
                logger1.exitLogger();
            }
        }
        //--------------Added for EDGE-98322 by Samish END-------------//
        
        //SQ Check for 'NBN' - EDGE-98322 by Samish
        else if(techType.equalsIgnoreCase('NBN')){       //added for existing SQ check callout - EDGE-98322 by Samish
            
            //moved existing logic for SQ check in this if block - EDGE-98322 by Samish
            try {
                String basketId = ApexPages.currentPage().getParameters().get('basketId');
                cscfga__Product_Basket__c prdBasket = [SELECT Id, cscfga__Opportunity__c, cscfga__Opportunity__r.AccountId FROM cscfga__Product_Basket__c WHERE id =: basketId LIMIT 1];
                system.debug('addressList====>>>>>>'+addressList);
                for (AddressSummary addr: addressList) {
                    if (addr.isSelected && addr.sqStatusDesc != 'Available'/* && addr.legacysite == 'No'*/) {
                        adborIds.add(addr.adborID);
                    }
                }
            
                if (adborIds.isEmpty()) {
                    allowedToAdd = 'Yes';
                }
                else if (!adborIds.isEmpty() && prdBasket != NULL) {
                    //Commented this line and added next line ny Mahaboob as agreed wth Vimal on Skype(Team Zagreb group) at 13:07
                    //eligibleAdborIds = getConfigurableAddressIds(adborIds, prdBasket.cscfga__Opportunity__r.AccountId);
                    eligibleAdborIds = adborIds;
                    if (!eligibleAdborIds.isEmpty()) {
                        // addressToResponseMap = initiateSQService(eligibleAdborIds);      //commented for EDGE-98322 by Samish to accommodate Telstra Fibre/NBN
                        addressToResponseMap = initiateSQService(techType, eligibleAdborIds);         //added for EDGE-98322 by Samish to accommodate Telstra Fibre/NBN
                        System.debug('addressToResponseMap : ' + addressToResponseMap);
                        if(addressToResponseMap.isEmpty() || addressToResponseMap == NULL){
                            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'SQ Failed'));
                        }
                        else
                        {
                            //SQcheckCalloutHandler sqCheck = new SQcheckCalloutHandler(eligibleAdborIds, prdBasket.cscfga__Opportunity__r.AccountId);
                            SiteSQContractCalloutHandler siteSQ = new SiteSQContractCalloutHandler();
                            sqRecordToBeInserted=new List<Service_Qualification__c>();////added for Edge-99110
                            for(String adborId: eligibleAdborIds){
                                if(addressToResponseMap.ContainsKey(adborId)) {
                                    system.debug('StatusCode for ' + adborId + ' is ' + addressToResponseMap.get(adborId).getStatusCode());
                                    if(addressToResponseMap.get(adborId).getStatusCode() != 200){
                                    // sqFailedAdborIds.put(adborId, 'Error');
                                    HttpResponse res = addressToResponseMap.get(adborId);  
                                    //-----Commented by Samish for EDGE-113537---START----//
                                    /*
                                    Logger2 logger2 = Logger2.getLogger('SiteSQAddressHandler');
                                    logger2.logMessages(adborId, res.getBody(), '', '', '', '', false, false,Integer.valueof(res.getStatusCode()) , null, null, null);
                                    logger2.exitLogger();
                                    */
                                    //-----Commented by Samish for EDGE-113537---END----//
                                        String jsonStr = addressToResponseMap.get(adborId).getBody();
                                        Map<String,Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonStr);
                                        sqFailedAdborIds.put(adborId, addressToResponseMap.get(adborId).getStatus()  + ': ' + (String)responseMap.get('message'));
                                    }
                                    else {
                                        if(addressToResponseMap.get(adborId).getStatusCode() == 200){
                                            HttpResponse res = addressToResponseMap.get(adborId);    
                                            //added for Edge-99110
                                            //-----Commented by Samish for EDGE-113537---START----//
                                            /*
                                            Logger2 logger2 = Logger2.getLogger('SiteSQAddressHandler');
                                            logger2.logMessages(adborId, res.getBody(), '', '', '', '', false, false,Integer.valueof(res.getStatusCode()) , null, null, null);
                                            logger2.exitLogger();
                                            */
                                            //-----Commented by Samish for EDGE-113537---END----//
                                            SqResponseDTO responseDTO = SqResponseDTO.parse(res.getBody());
                                            if(responseDTO != NULL && responseDTO.data != NULL){
                                                //sqCheck.saveSQResponse(adborId,responseDTO);
                                                Service_Qualification__c sqRec = new Service_Qualification__c();
                                                sqRec =siteSQ.saveSQResponse(adborId,responseDTO,prdBasket.cscfga__Opportunity__r.AccountId);
                                                sqRecordToBeInserted.add(sqRec);
                                                List<SqResponseDTO.ServiceTypeQualifications> srvQualifications = responseDTO.data.serviceTypeQualifications;
                                                if(!srvQualifications.isEmpty()) {
                                                    //for(SqResponseDTO.ServiceTypeQualifications sq: srvQualifications){
                                                        SqResponseDTO.ServiceTypeQualifications sq = srvQualifications[0];
                                                        for (AddressSummary adr: addressList) {
                                                            if (adborId == adr.adborID) {
                                                                System.debug('adr before : ' + adr);
                                                                System.debug('sq before : ' + sq);
                                                                adr.sqStatusDesc = sq.Status;
                                                                adr.sqStatusErrorMessage = sq.statusReason;
                                                                adr.nbnAvailability = sq.Status == 'Available' ? 'Available' : 'Not Available';
                                                                adr.nbnRFSDate = sq.readyForServiceDate;
                                                                adr.nbnTechnologyType = sq.technologyType;
                                                                //Translation for technologytype
                                                                if(sq.technologyType=='Fibre To The Node'){
                                                                    adr.nbnTechnologyTypeAcrnym = 'FTTN';
                                                                }else if(sq.technologyType=='Fibre To The Building'){
                                                                    adr.nbnTechnologyTypeAcrnym = 'FTTB';
                                                                }else if(sq.technologyType=='Fibre To The Curb'){
                                                                    adr.nbnTechnologyTypeAcrnym = 'FTTC';
                                                                }else if(sq.technologyType=='Fibre To The Premise'){
                                                                    adr.nbnTechnologyTypeAcrnym = 'FTTP';
                                                                }else if(sq.technologyType=='Fibre'){
                                                                    adr.nbnTechnologyTypeAcrnym = 'FTTP';
                                                                }else if(sq.technologyType=='Wireless'){
                                                                    adr.nbnTechnologyTypeAcrnym = 'Fixed Wireless';
                                                                }else {
                                                                    adr.nbnTechnologyTypeAcrnym = sq.technologyType;
                                                                }
                                                                //translation ends here
                                                                adr.nbnServiceabilityClass = sq.serviceabilityClass;
                                                                adr.copperPairIndicator = sq.copperPairIndicator;
                                                                adr.nbnCompatibility = ((sq.copperPairIndicator != null && (sq.copperPairIndicator.toLowerCase() == 'yes' || sq.copperPairIndicator.toLowerCase() == 'na' )) || sq.technologyType=='Fibre To The Premise' || sq.technologyType=='FTTP' || sq.technologyType=='Fibre') ? 'Yes' : 'No';
                                                                adr.sqStatus = adr.sqStatusDesc == 'Available';
                                                                for(SqResponseDTO.Characteristics chars : sq.characteristics){
                                                                    if(chars.name.containsIgnoreCase('Downstream')){
                                                                        adr.nbnMaxDownloadSpeed = chars.value;
                                                                    }
                                                                    if(chars.name.containsIgnoreCase('Upstream')){
                                                                        adr.nbnMaxUploadSpeed = chars.value;
                                                                    }
                                                                }
                                                                System.debug('adr after : ' + adr);
                                                                System.debug('sq after : ' + sq);
                                                            }
                                                        }
                                                    //}
                                                }
                                            }
                                        }
                                        
                                    }
                                }
                            }
                            //added for Edge-99110
                            if(!sqRecordToBeInserted.IsEmpty()){
                                insert sqRecordToBeInserted;
                                System.debug('serviceQList** '+sqRecordToBeInserted);
                                // Save partial response : ProviderResources    
                                addressToSQResponseMap= new Map<String,HttpResponse>();                         
                                addressToSQResponseMap.putAll(addressToResponseMap);
                                siteSQ.saveProviderResources(sqRecordToBeInserted,addressToResponseMap);
                            }
                        }
                        System.debug('sqFailedAdborIds : ' + sqFailedAdborIds);
                        for (String adborId : sqFailedAdborIds.keyset()) {
                            for (AddressSummary adr: addressList) {
                                if (adborId == adr.adborID) {
                                    adr.sqStatusDesc = 'Error';
                                    adr.sqStatusErrorMessage = sqFailedAdborIds.get(adborId);
                                    adr.sqStatus = adr.sqStatusDesc == 'Available';
                                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Selected Site(s) are not qualified, Please chose other site(s)'));
                                }
                            }
                        }
                        sqCheckCompleted = 'Yes';
                        for (AddressSummary addr: addressList) {
                            System.debug('sqStatusDesc : ' + addr.sqStatusDesc);
                            if (addr.isSelected && addr.sqStatusDesc == 'Error') {
                                sqUnavailAdborIds.add(addr.adborID);
                            }
                        }
                        if (sqUnavailAdborIds.isEmpty()) {
                            allowedToAdd = 'Yes';
                            sqCheckRequired = 'No';
                        }
                    }
                }
                hiddenAddressList = addressList;

                selectedAddressList = JSON.serialize(getSelectedAddressList(addressList));
            } catch (Exception e) {
                System.debug('Exception while checking for Service Qualification : ' + e.getMessage());
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Exception in makeSQCallout : ' + e.getMessage()));
                Logger2 logger = Logger2.getLogger('SiteSQAddressHandler');
                logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
                logger.exitLogger();
            }
        }        
    }
        //------------Added by Pawan for EDGE-113537 START-----------//
    private boolean createLogEntry(Boolean isLoggingDone, DateTime startTime, DateTime endTime, String payload, HttpResponse res, String correId, String insideMethod){
        if(!isLoggingDone){ 
            Logger2 logger2 = Logger2.getLogger(insideMethod);
            Long requestTime = 0;
            requestTime = logger2.getRequestTimeDifference(startTime, endTime);
            logger2.logMessages(payload, res.getBody(), '', '', '', '', String.valueOf(res.getStatusCode()), correId, '','','','Read',requestTime ,'GET',false, false);
            isLoggingDone = true;
        }   
        return isLoggingDone;
    }

    /*private List<String> getConfigurableAddressIds(List<String> adborIds,String AccountId){
        List<cscrm__Site__c> sites = [SELECT id,AdborID__c,(SELECT CreatedDate,Copper_Pair_Indicator__c,Status__c from Service_qualifications__r ORDER BY CreatedDate DESC LIMIT 1) FROM 
                                         cscrm__Site__c WHERE AdborID__c IN :adborIds AND cscrm__Account__c =:AccountId];
        List<String> eligibleAdborIds = new List<String>();
        if (sites != NULL && !sites.isEmpty()) {
            for(cscrm__Site__c site : sites){
                if(site.Service_qualifications__r.isEmpty()){
                    eligibleAdborIds.add(site.AdborID__c);
                }
                else{
                    if(shouldInitiateSQ(Date.valueOf(site.Service_qualifications__r[0].CreatedDate))){
                        eligibleAdborIds.add(site.AdborID__c);
                    }
                }
            }
        }
        else {
            eligibleAdborIds.addAll(adborIds);
        }
        System.debug('eligibleAdborIds : ' + eligibleAdborIds);
        return eligibleAdborIds;
    }*/
    
    public Boolean shouldInitiateSQ(Date createdDate){
        Date todayDate = Date.today();
        system.debug('todayDate.daysBetween(createdDate)==='+todayDate.daysBetween(createdDate));
        if(todayDate.daysBetween(createdDate) > Integer.valueOf(Label.SQSiteConfigDays)) {
            return TRUE;
        }
        else{
            return FALSE;
        }
    }

    // public Map<String,HttpResponse> initiateSQService(List<String> eligibleAdborIds) 
    public Map<String,HttpResponse> initiateSQService(String techType, List<String> eligibleAdborIds){      //changed for EDGE-98322 by Samish to accommodate technology type as Telstra Fibre or NBN on 30-11-19
        Map<String,HttpResponse> addressToResponseMap = new Map<String,HttpResponse>();
        try {
            if(Test.isRunningTest() && testCheck){
                CalloutException e = new CalloutException();
                throw e;
                }
            if (!eligibleAdborIds.isEmpty()) {
                String token = AuthenticationManager.getOauthToken('SiteSQAddressHandler');
                addressToResponseMap = callSQService(token,eligibleAdborIds);
            }
        } catch (Exception e) {
            System.debug('Exception while checking for Service Qualification : ' + e.getMessage());
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Exception in initiateSQService : ' + e.getMessage()));
        }
        return addressToResponseMap;
    }

    @TestVisible
    private Map<String,HttpResponse> callSQService(String token, List<String> eligibleAdborIds){
        Logger2 logger2 = Logger2.getLogger('callSQService');
        SqResponseDTO responseDTO = NULL;
        HttpResponse response;
        String payload = '';
        String serviceFilter = 'Internet';
        //------------Added by Samish for EDGE-113537 START-----------//
        String correlationId = IntegrationRecordHandlerUtil.getCorrelationId();
        DateTime startTime;
        DateTime endTime;
        Boolean isLoggingDone = false;
        //------------Added by Samish for EDGE-113537 END-----------//
        Map<String,HttpResponse> addressToResponseMap = new Map<String,HttpResponse>();
        try{  
            if(Test.isRunningTest() && testCheck){
                CalloutException e = new CalloutException();
                throw e;
                }
        
            for(String addressId : eligibleAdborIds){
                payload = 'addressId=' + addressid +'&serviceFilter='+serviceFilter;
                Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token};
                
                if(!isLoggingDone)                  //Added by Samish for EDGE-113537
                    startTime = DateTime.now();
                
                response = IntegrationRecordHandlerUtil.callout(payload, 'GET', headerMap, 'SiteSQAddressHandler', NULL, NULL);
                
                if(!isLoggingDone){                 //Added by Samish for EDGE-113537
                    endTime = DateTime.now();
                    isLoggingDone = createLogEntry(isLoggingDone, startTime, endTime, payload, response, correlationId, 'SiteSQAddressHandler');
                }
                //String responseCode = String.valueOf(response.getStatusCode());     //Commented by Samish as the variable was unused EDGE-113537
                System.debug('Response : ' + response); 
                addressToResponseMap.put(addressid,response);
            }
          
            /*for(String addId : addressToResponseMap.keyset()){
                HttpResponse res = addressToResponseMap.get(addId);
                System.debug('res.getStatusCode## ' + res.getStatusCode());
                if (res.getStatusCode() == 200) {
                    responseDTO = SqResponseDTO.parse(res.getBody());
                    System.debug('responseDTO: ' + responseDTO);
                    System.debug('MapOfResp ' + addressToResponseMap);
                    //sqHandler.saveSQResponse(addId,responseDTO);
                }  
            }*/
        }catch (Exception e) {
            System.debug('Exception while checking for Service Qualification : ' + e.getMessage());
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Exception in initiateSQService : ' + e.getMessage()));
        }       
        System.debug('addressToResponseMap Size'+addressToResponseMap.Size());
        return addressToResponseMap;
    }

    public void saveSelectedSitesToSfdc() {

        System.debug('saveSelectedSitesToSfdc');
        selectedAddressList = JSON.serialize(getSelectedAddressList(addressList));
        System.debug('selectedAddressList '+selectedAddressList);
       
        if (sqCheckEnabled == 'Yes' && offerSQcheckRequired == 'Yes') {
            //for (AddressSummary adr: addressList) {
              //  System.debug('adr.isSelected=' + adr.isSelected + '---adr.sqStatus=' + adr.sqStatus + 'adr.legacysite=' + adr.legacysite);
                //if (adr.isSelected /*&& adr.legacysite == 'No'*/) {
                  //  if (String.isEmpty(adr.sqStatus)) {
                    //    system.debug('Inside sqCheckRequired If : ');
                      //  sqCheckRequired = 'Yes';
                    //}
                    //else if (adr.sqStatus == 'Available') {
                      //  system.debug('Inside allowedToAdd Else : ');
                        //allowedToAdd = 'Yes';
                    //}
                //}
            //}
            //Added by Mahaboob on 18/06/2019 to allow selection of nbn available sites
            Integer countSQFalse = 0;
            for (AddressSummary adr: addressList) {
                /*if (adr.isSelected && adr.nbnAvailability != 'Available') {
                    countSQFalse++;
                }*/
                if (adr.isSelected && adr.nbnAvailability == 'error') {
                    countSQFalse++;
                }
                if (adr.isSelected && (adr.nbnAvailability == '' || adr.nbnAvailability == null)) {
                    sqCheckRequired = 'Yes';
                    sqCheckCompleted = 'No';
                }
            }
            if (countSQFalse <= 0) {
                allowedToAdd = 'Yes';
            }
            //End by Mahaboob on 18/06/2019
            if (sqCheckRequired == 'Yes' && sqCheckCompleted == 'No') {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Please complete SQ Check before adding IP Site to Solution'));
            }
            /*else if (allowedToAdd == 'No') {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Only Sites with Successful SQ can be added to the Solution'));
            }*/
            else {
                saveSelectedSites();
            }
        }
        else {
            saveSelectedSites();
        }

        System.debug('sqCheckRequired=' + sqCheckRequired + '---sqCheckCompleted=' + sqCheckCompleted + '---allowedToAdd=' + allowedToAdd);
        System.debug('saveSelectedSitesToSfdc finished');
    }

    private void saveSelectedSites() {
        
        System.debug('responseSiteRecordList '+responseSiteRecordList);

        if (responseSiteRecordList == null || responseSiteRecordList.size() == 0)
            return;

        ReplicatorGetSiteDataObject sitesTobeInserted = new ReplicatorGetSiteDataObject();
        List < ReplicatorGetSiteDataObject.SiteDTO > addressToBeInsertedList = new List < ReplicatorGetSiteDataObject.SiteDTO > ();
        List < String > adborIdListTobeinserted = new List < String > ();
        List < String > compositeKeyListTobeinserted = new List < String > ();

        System.debug('addressList : ' + addressList);
        for (AddressSummary adr: addressList) {
            if (!adr.isSelected)
                continue;

            System.debug('Selected ' + adr);

            for (Map < String, Object > op: responseSiteRecordList) {

                if (op.get('adborid__c') != null && (String) op.get('adborid__c') != adr.adborID)
                    continue;

                System.debug('Selecting: ' + op);

                ReplicatorGetSiteDataObject.SiteDTO addressToBeInserted = new ReplicatorGetSiteDataObject.SiteDTO();
                adborIdListTobeinserted.add(adr.adborID);
                addressToBeInserted.adbor_id = adr.adborID;
                addressToBeInserted.Site_Address_Status = (String) op.get('status__c');
                addressToBeInserted.Street_Name = (String) op.get('cscrm__street_name__c');
                addressToBeInserted.loc_name = (String) op.get('locality__c');
                addressToBeInserted.State = (String) op.get('cscrm__state_province__c');
                addressToBeInserted.ADBoR_Postcode = (String) op.get('cscrm__zip_postal_code__c');
                addressToBeInserted.Address_No_To = (String) op.get('street_number_to__c');
                addressToBeInserted.Address_No_From = (String) op.get('street_number_from_calc__c');
                addressToBeInserted.Street_Type = (String) op.get('cscrm__street_type__c');
                addressToBeInserted.Suffix_From = (String) op.get('streetnumberstartsuffix__c');
                addressToBeInserted.Suffix_To = (String) op.get('streetnumberendsuffix__c');
                addressToBeInserted.Sub2_Descriptor_1 = (String) op.get('sub_address2_number__c');
                addressToBeInserted.Sub2_CodeSet_Abbrev = (String) op.get('sub_address2_type__c');
                addressToBeInserted.Sub1_Descriptor_1 = (String) op.get('sub_address1_number__c');
                addressToBeInserted.Sub1_CodeSet_Abbrev = (String) op.get('sub_address1_type__c');
                addressToBeInserted.Sub3_Descriptor_1 = (String) op.get('sub_address_3_number__c');
                addressToBeInserted.Sub3_CodeSet_Abbrev = (String) op.get('sub_address_3_type__c');
                addressToBeInserted.Sub4_Descriptor_1 = (String) op.get('sub_address_4_number__c');
                addressToBeInserted.Sub4_CodeSet_Abbrev = (String) op.get('sub_address_4_type__c');
                //addressToBeInserted.rfs_date=(String)op.get('cscrm__street_type__c');
                addressToBeInserted.disconnection_date = (String) op.get('disconnection_date__c');
                addressToBeInserted.in_flight_order = (String) op.get('in_flight_order__c');
                addressToBeInserted.serviceability = (String) op.get('servicability__c');
                addressToBeInserted.disconnect_wave = (String) op.get('disconnect_wave__c');
                addressToBeInserted.site_composition = (String) op.get('site_composition__c');
                addressToBeInserted.order_stability_date = (String) op.get('order_stability_date__c');
                addressToBeInserted.service_class = (String) op.get('service_class__c');
                addressToBeInserted.Site_Migration_Flag = (String) op.get('site_migration_flag__c');
                addressToBeInserted.Site_Nick_Name = (String) op.get('site_nick_name__c');

                addressToBeInsertedList.add(addressToBeInserted);

                break;

            }
        }

        /*//Map<String,cscrm__Site__c> aboridAlreadypresent=new  Map<String,cscrm__Site__c>();
        List < cscrm__Site__c > sites = [select AdborID__c from cscrm__Site__c where AdborID__c IN: adborIdListTobeinserted];*/
        
        // added for composite key unique logic for production incident CRQ000004439482
        system.debug('adborIdListTobeinserted===='+adborIdListTobeinserted);
        for(String adbrid : adborIdListTobeinserted){
            String compkey =  cidn+adbrid;
            compositeKeyListTobeinserted.add(compkey);
        }
        
        //Map<String,cscrm__Site__c> aboridAlreadypresent=new  Map<String,cscrm__Site__c>();
        List < cscrm__Site__c > sites = [select AdborID__c from cscrm__Site__c where Composite_Key__c IN: compositeKeyListTobeinserted]; //// updated for composite key unique logic for production incident CRQ000004439482
        List<ReplicatorGetSiteDataObject.SiteDTO> objectsToRemove = new List<ReplicatorGetSiteDataObject.SiteDTO>();
        if (sites != null && sites.size() > 0) {
            for (cscrm__Site__c s: sites)
            {
                 System.debug('Removing existing: ' + s);
                if (adborIdListTobeinserted.indexOf(s.AdborID__c) != -1)
                {
                    Integer index = adborIdListTobeinserted.indexOf(s.AdborID__c);
                    if (index>=0 & index<adborIdListTobeinserted.size())
                        adborIdListTobeinserted.remove(index);
                }
                for (ReplicatorGetSiteDataObject.SiteDTO dto: addressToBeInsertedList){
                    if (s.AdborID__c == dto.adbor_id) {
                       objectsToRemove.add(dto);
                        break;
                    }
                }
            }
        }
        
        for(ReplicatorGetSiteDataObject.SiteDTO dto: objectsToRemove)
        {
            Integer i = addressToBeInsertedList.indexOf(dto);if (i>=0 && i <addressToBeInsertedList.size())addressToBeInsertedList.remove(i);                   
        }
        //Edge-113351
        //Map<String,Service_Qualification__c > SqMaptoUpdated=new Map<String,Service_Qualification__c >();
        //SqMaptoUpdated=getInsertedOrphanSQRecords(adborIdListTobeinserted);
        sqRecordToBeInsertedMap=new Map<String,Service_Qualification__c>();
        Map<String,HttpResponse> addressToSQResponseMapFinal=new Map<String,HttpResponse>();
        if(sqRecordToBeInserted!=null){
            for(Service_Qualification__c sqRec:sqRecordToBeInserted){
                if(adborIdListTobeinserted!=null && adborIdListTobeinserted.contains(sqRec.Address_ID__c)){
                    sqRecordToBeInsertedMap.put(sqRec.Address_ID__c,sqRec);
                    System.debug('addressToSQResponseMap:::: : ' + addressToSQResponseMap);
                    System.debug('sqRec.Address_ID__c:::: : ' + sqRec.Address_ID__c);
                    if(addressToSQResponseMap!=null && addressToSQResponseMap.containsKey(sqRec.Address_ID__c)) { 
                        //added for EDGE-113351
                        providerresourceListMap=new Map<String,List<Service_Qualification_Provider_Resource__c>>();
                        List<Service_Qualification_Provider_Resource__c> proResList = new List<Service_Qualification_Provider_Resource__c>();
                        if(addressToSQResponseMap.containsKey(sqRec.Address_ID__c)){
                            HttpResponse res = addressToSQResponseMap.get(sqRec.Address_ID__c);
                            if (res.getStatusCode() == 200) {                      
                                system.debug('resgetbody:::'+ res.getBody());
                                SqResponseDTO responseDTO = SqResponseDTO.parse(res.getBody());
                                system.debug('responseDTO:::'+ responseDTO);
                                if(responseDTO != NULL && responseDTO.data != NULL){
                                List<SqResponseDTO.ServiceTypeQualifications> srvQualificationList = responseDTO.data.serviceTypeQualifications;
                                if(!srvQualificationList.isEmpty()){
                                    for(SqResponseDTO.ServiceTypeQualifications sq: srvQualificationList){
                                        List<SqResponseDTO.ProviderResources> proResourceList = sq.providerResources;
                                        for(SqResponseDTO.ProviderResources sqpr:  proResourceList){
                                           if(sqpr.resourceType!=null && 'Copper Pair'.equalsIgnoreCase(sqpr.resourceType)){
                                                Service_Qualification_Provider_Resource__c proRes =new Service_Qualification_Provider_Resource__c ();                   
                                                proRes.Copper_Pair_ID__c    =   sqpr.id ;
                                                proRes.Copper_Pair_Status__c    =   sqpr.status ;
                                                proRes.Copper_Pair_SC__c    =   sqpr.serviceabilityClass;
                                                proRes.Service_Qualification__c = sqRec.id;
                                                proResList.add(proRes);                                         
                                           }
                                            providerresourceListMap.put(sqRec.Address_ID__c,proResList);                                       
                                        }
                                    }
                                }
                            } 
                            }
                        }
                                  
                    }
                    
                }
                                                
            }
        }

        sitesTobeInserted.CIDN=cidn;
        sitesTobeInserted.Enterprise_Id=enterpriseId;

        System.debug('addressToBeInsertedList ' + addressToBeInsertedList);
        
        if(addressToBeInsertedList.size()>0) {
            sitesTobeInserted.Site=addressToBeInsertedList;
            System.debug('sitesTobeInserted ' + sitesTobeInserted);
            AddressAndSiteObjectUtilitySQ.upsertEastAddressAndSiteAndSQ(AdborIdListTobeinserted,cidn,sitesTobeInserted,sqRecordToBeInsertedMap,providerresourceListMap);
            System.debug('saveSelectedSites finished');
        }
    }
   
    
    /*public void mapReplicatorSitewithSQ(List<String> AdborIdsInserted) {
        List<Service_Qualification__c> sqsToBeUpdated = new List<Service_Qualification__c>();
        Map<String, String> adborIdToSiteIdMap = new Map<String, String>();
        for (cscrm__Site__c site : [SELECT Id, Name, AdborID__c FROM cscrm__Site__c WHERE AdborID__c IN :AdborIdsInserted]) {
            adborIdToSiteIdMap.put(site.AdborID__c, site.Id);
        }
        if (!adborIdToSiteIdMap.isEmpty()) {
            for (Service_Qualification__c sq : [SELECT Id, Name, Site__c, Address_ID__c FROM Service_Qualification__c WHERE Address_ID__c IN :AdborIdsInserted ORDER BY CreatedDate DESC LIMIT 1]) {
                if (sq.Site__c == NULL) {
                    sq.Site__c = adborIdToSiteIdMap.get(sq.Address_ID__c);
                    sqsToBeUpdated.add(sq);
                }
            }
            if (!sqsToBeUpdated.isEmpty()) {
                UPDATE sqsToBeUpdated;
            }
        }
    }*/
    
    // runs the search with parameters passed via Javascript
    public void runSearch() {

        System.debug('searchString= ' + searchString);
         //Manoj Kumar : Toggle on DTO Class getSite v2 api : bug : EDGE-105508

        String Enable_GetSiteReplicatorV2 = EnvironmentVariable__c.getValues('Enable_GetSiteReplicatorV2').Value__c;
        
        string basketId = ApexPages.currentPage().getParameters().get('basketId');
        System.debug('SCAddressSearchController, basketId= ' + basketId);
        //Sites already added in the solution
        string siteIdStr = ApexPages.currentPage().getParameters().get('adborIds');
        string[] siteIds;
        System.debug('SCAddressSearchController, adborIds= ' + siteIdStr);
        if (siteIdStr != null && siteIdStr.length() > 0) {
            siteIds = siteIdStr.Split(',');
        }
        System.debug('SCAddressSearchController, siteIds splits= ' + siteIds);

        cscfga__Product_Basket__c bkt = null;
        try {
            bkt = [select id, csbb__Account__c, csbb__Account__r.CIDN__c, csbb__Account__r.Enterprise_ID__c from cscfga__Product_Basket__c where id =: basketId LIMIT 1];
            system.debug('cscfga__Product_Basket__c:  ' + bkt);   
        } catch (Exception e) {
            
        }
               
        if (bkt != null && bkt.csbb__Account__r != null) {
            if (bkt.csbb__Account__r.CIDN__c != null)
               cidn = bkt.csbb__Account__r.CIDN__c;

            if (bkt.csbb__Account__r.CIDN__c != null)
               enterpriseId = bkt.csbb__Account__r.Enterprise_ID__c;
        }



        system.debug('CIDN = :  ' + cidn);
        system.debug('enterpriseId = :  ' + enterpriseId);
       
        //Manoj : toggle on old & new getSite : EDGE-105508

        ReplicatorGetSiteDataObject getSiteDTO;
        ReplicatorGetSiteDataObject_V2 getSiteDTO_V2;
        
        if(Enable_GetSiteReplicatorV2.equalsIgnoreCase('True')){
            getSiteDTO_V2 = getCustomerSitesV2(cidn);
        }
        else{
            getSiteDTO = getCustomerSites(cidn);
        }
     
        System.debug('ReplicatorGetSiteService ' + getSiteDTO_V2);
        

        List < Map < String, Object >> siteRecordList2 = new List < Map < String, Object >> ();
         Set < cscrm__Site__c > siteSet = new  Set < cscrm__Site__c >(); 
         
        //Manoj Kumar : Toggle on DTO Class getSite v2 api : EDGE-105508
        
        if(Enable_GetSiteReplicatorV2.equalsIgnoreCase('True')){
              //EDGE-105802
            if (getSiteDTO_V2 != null && getSiteDTO_V2.CIDN != null) { 
                siteRecordList2 = calloutResponseAddressCheck2.getSiteFromReplicatorResponseV2(getSiteDTO_V2, basketId);
                System.debug('siteRecordList2 '+siteRecordList2);
            }
            
            
        }
        else{
              if (getSiteDTO != null && getSiteDTO.CIDN != null) { 
                siteRecordList2 = calloutResponseAddressCheck2.getSiteFromReplicatorResponse(getSiteDTO, basketId);
                System.debug('siteRecordList2 '+siteRecordList2);
            }
            
           
        }
      
        siteSet = calloutResponseAddressCheck2.getSiteMinusSubs(basketId);

        //GET ALL UNIQUE REPLICATOR SITES BY REMOVING ACCOUNT SITES

        List < Map < String, Object >> uniqueReplicatorSiteList =  calloutResponseAddressCheck2.markDuplicateReplicatorSites('' + basketId, siteRecordList2);
        //GET UNIQUE LIST OF SITES FROM ALL SITES AND REPLICATOR RECEIVED SITES
        responseSiteRecordList = calloutResponseAddressCheck2.getUniqueSiteResponse(siteSet, uniqueReplicatorSiteList);
        system.debug('responseSiteRecordList ' + responseSiteRecordList);


        Map<String, Map<String, String>> adborToSRStatus = new Map<String, Map<String, String>>();
        List<cscrm__Site__c> sites = new List<cscrm__Site__c>();
        String sqqueryString;
        Id accountId = bkt.csbb__Account__c;
       /* if (siteIds != NULL) {
            //SOQL Site SQ results to check if NBN available, remove sites already added to the Solution
            sqqueryString = 'SELECT id,AdborID__c,(SELECT CreatedDate,Copper_Pair_Indicator__c,Max_Downstream_Speed__c,Max_Upstream_Speed__c,Technology_Type__c,Ready_for_Service_Date__c,Status__c' +
                    ' from Service_qualifications__r ORDER BY CreatedDate DESC LIMIT 1) FROM' +
                    ' cscrm__Site__c WHERE AdborID__c NOT IN :siteIds AND cscrm__Account__c =:accountId';
        }else{
            sqqueryString = 'SELECT id,AdborID__c,(SELECT CreatedDate,Copper_Pair_Indicator__c,Max_Downstream_Speed__c,Max_Upstream_Speed__c,Technology_Type__c,Ready_for_Service_Date__c,Status__c' +
                    ' from Service_qualifications__r ORDER BY CreatedDate DESC LIMIT 1) FROM '+
                    ' cscrm__Site__c WHERE cscrm__Account__c =:accountId';

        }
        */

        List<String> siteIdsForSq = new List<String>();

        if (responseSiteRecordList != null && responseSiteRecordList.size() > 0) {
            for (Map < String, Object > site : responseSiteRecordList) {
                if (siteIds != null && siteIds.contains((String) site.get('adborid__c')))
                    continue;

                if ((searchString != null) && (searchString.length() > 0) && (((String) site.get('name')).indexOfIgnoreCase(searchString, 0) == -1) && (((String) site.get('display_name__c')).indexOfIgnoreCase(searchString, 0) == -1))
                    continue;

                siteIdsForSq.add((String) site.get('adborid__c'));
            }
        }

        //-------------added for EDGE-98322 by Samish on START-------------//
        Map<String, String> mapAdborID_SQId = new Map<String, String>();String crgSolReasonCode_Available = '';
        Boolean isEthernetMAN_TID_Available = false;
        Boolean isEthernetMAN_TID_MaybeAvailable = false;       
        String crgSolReasonCode_MaybeAvailable = '';
        Map<String, CarriageSolution> mapAdborId_CarriageSolution = new Map<String, CarriageSolution>();
        //-------------added for EDGE-98322 by Samish on END--------------//
        
        sites = [SELECT id,AdborID__c, cscrm__Installation_Address__r.ESA_Code__c, 
                        (SELECT id, CreatedDate,Copper_Pair_Indicator__c,Max_Downstream_Speed__c,Max_Upstream_Speed__c,Technology_Type__c,              Ready_for_Service_Date__c,Serviceability_Class__c,Status__c
                        FROM Service_qualifications__r 
                        ORDER BY CreatedDate DESC LIMIT 1)
                FROM cscrm__Site__c WHERE AdborID__c  IN :siteIdsForSq AND cscrm__Account__c =: accountId  ];       //modified (added id in query) for EDGE-98322 by Samish on 30-11-19           //modified (added ESA_Code__c in query) by Samish for EDGE-123563 on 18-12-19

        if (sites != NULL && !sites.isEmpty()) {
            for (cscrm__Site__c site : sites) {
            system.debug('site.Service_qualifications__r.isEmpty==='+site.Id);
                
                if(!site.Service_qualifications__r.isEmpty()){          //added for EDGE-98322 by Samish on 30-11-19
                    mapAdborID_SQId.put(site.AdborID__c, site.Service_qualifications__r[0].Id);
                }
                
                if(!site.Service_qualifications__r.isEmpty() && !(shouldInitiateSQ(Date.valueOf(site.Service_qualifications__r[0].CreatedDate)))){
                    //Map<String, String> adborToSQStatus = new Map<String, String>();
                    Map<String, String> adborToSQStatus =  createAdborToSRStatusMap(site);
                    // Moved below code to new method "createAdborToSRStatusMap" to reduce CC as part of EDGE-127666 tech debt by Gnana - Start
                    /*adborToSQStatus.put('nbnAvailability', site.Service_qualifications__r[0].Status__c);
                    adborToSQStatus.put('copperPairIndicator', site.Service_qualifications__r[0].Copper_Pair_Indicator__c);
                    adborToSQStatus.put('nbnMaxDownloadSpeed', site.Service_qualifications__r[0].Max_Downstream_Speed__c);
                    adborToSQStatus.put('nbnMaxUploadSpeed', site.Service_qualifications__r[0].Max_Upstream_Speed__c);
                    adborToSQStatus.put('nbnTechnologyType', site.Service_qualifications__r[0].Technology_Type__c);
                    //translation for technologyType
                    if(site.Service_qualifications__r[0].Technology_Type__c=='Fibre To The Node'){
                        //nbnAttributes.NBNTechnologyType='FTTN';
                        adborToSQStatus.put('nbnTechnologyTypeAcrnym', 'FTTN');
                    }else if(site.Service_qualifications__r[0].Technology_Type__c=='Fibre To The Building'){
                        //nbnAttributes.NBNTechnologyType='FTTB';
                        adborToSQStatus.put('nbnTechnologyTypeAcrnym', 'FTTB');
                    }else if(site.Service_qualifications__r[0].Technology_Type__c=='Fibre To The Curb'){
                        //nbnAttributes.NBNTechnologyType='FTTC';
                        adborToSQStatus.put('nbnTechnologyTypeAcrnym', 'FTTC');
                    }else if(site.Service_qualifications__r[0].Technology_Type__c=='Fibre To The Premise'){
                        //nbnAttributes.NBNTechnologyType='FTTP';
                        adborToSQStatus.put('nbnTechnologyTypeAcrnym', 'FTTP');
                    }else if(site.Service_qualifications__r[0].Technology_Type__c=='Fibre'){
                        //nbnAttributes.NBNTechnologyType='FTTP';
                        adborToSQStatus.put('nbnTechnologyTypeAcrnym', 'FTTP');
                    }else if(site.Service_qualifications__r[0].Technology_Type__c=='Wireless'){
                        //nbnAttributes.NBNTechnologyType='Fixed Wireless';
                        adborToSQStatus.put('nbnTechnologyTypeAcrnym', 'Fixed Wireless');
                    }else {
                        //nbnAttributes.NBNTechnologyType=serviceQ.Technology_Type__c;  
                        adborToSQStatus.put('nbnTechnologyTypeAcrnym', site.Service_qualifications__r[0].Technology_Type__c);
                    }
                            
                    if((site.Service_qualifications__r[0].Copper_Pair_Indicator__c!=null && (site.Service_qualifications__r[0].Copper_Pair_Indicator__c=='Yes' || site.Service_qualifications__r[0].Copper_Pair_Indicator__c=='NA')) || site.Service_qualifications__r[0].Technology_Type__c=='Fibre To The Premise' || site.Service_qualifications__r[0].Technology_Type__c=='FTTP' || site.Service_qualifications__r[0].Technology_Type__c=='Fibre'){
                        adborToSQStatus.put('nbnCompatibility', 'Yes');
                    }else{
                        adborToSQStatus.put('nbnCompatibility', 'No');
                    }
                    adborToSQStatus.put('nbnServiceabilityClass', site.Service_qualifications__r[0].Serviceability_Class__c);        
                    if (site.Service_qualifications__r[0].Ready_for_Service_Date__c != null)
                        adborToSQStatus.put('nbnRFSDate', String.valueOf(site.Service_qualifications__r[0].Ready_for_Service_Date__c.format()));
                    else
                        adborToSQStatus.put('nbnRFSDate', '');
                    
                    if(String.isNotBlank(site.cscrm__Installation_Address__r.ESA_Code__c))  //added by Samish for EDGE-123563 on 18-12-19
                        adborToSQStatus.put('siteESACode', '');*/
                    // Moved above code to new method "createAdborToSRStatusMap" to reduce CC as part of EDGE-127666 tech debt by Gnana - Start

                    adborToSRStatus.put(site.AdborID__c, adborToSQStatus);

                    
                }
            }

            //------------------------added for EDGE-98322 by Samish on 30-11-19 START------------------------//
            if(mapAdborID_SQId!=null && !mapAdborID_SQId.isEmpty()){    
                for(Service_Qualification__c srvQl : [SELECT Id, Technology_Type__c, Site__r.AdborID__c, (SELECT Id, Name, carriageSolutionStatus__c, carriageSolutionReasonCode__c, Service_Qualification__c FROM Carriage_Solutions__r) FROM Service_Qualification__c WHERE Id IN: mapAdborID_SQId.values()]){
                    CarriageSolution wrapCrgSol = new CarriageSolution();
                    for(Carriage_Solutions__c crgSol : srvQl.Carriage_Solutions__r){
                        if(crgSol.Name.equalsIgnoreCase(CARRIAGESOLUTION)){
                            if(crgSol.carriageSolutionStatus__c.equalsIgnoreCase('Available')){
                                isEthernetMAN_TID_Available = true;crgSolReasonCode_Available = crgSol.carriageSolutionReasonCode__c;
                            }
                            else if(crgSol.carriageSolutionStatus__c.equalsIgnoreCase('MaybeAvailable')){
                                isEthernetMAN_TID_MaybeAvailable = true;crgSolReasonCode_MaybeAvailable = crgSol.carriageSolutionReasonCode__c;                               
                            }
                        }
                    }
                    //if Responses = "Available && MaybeAvailable" AND "MaybeAvailable && MaybeAvailable"
                    if(isEthernetMAN_TID_MaybeAvailable){
                        wrapCrgSol.crgSolStatus = 'MaybeAvailable';
                        wrapCrgSol.crgSolReasonCode = crgSolReasonCode_MaybeAvailable;
                    }
                    //if Responses = Available && Available
                    else if(isEthernetMAN_TID_Available && !isEthernetMAN_TID_MaybeAvailable){
                        wrapCrgSol.crgSolStatus = 'Available';
                        wrapCrgSol.crgSolReasonCode = crgSolReasonCode_Available;
                    }
                    if(wrapCrgSol!=null)
                        mapAdborId_CarriageSolution.put(srvQl.Site__r.AdborID__c, wrapCrgSol);
                }
            }
            //------------------------added for EDGE-98322 by Samish on 30-11-19 END------------------------//
        }


        addressList.clear();
        if (responseSiteRecordList != null && responseSiteRecordList.size() > 0) {
            for (Map < String, Object > site: responseSiteRecordList) {
                if (siteIds != null && siteIds.contains((String) site.get('adborid__c')))
                    continue;

                if ((searchString != null) && (searchString.length() > 0) && (((String) site.get('name')).indexOfIgnoreCase(searchString, 0) == -1) && (((String) site.get('display_name__c')).indexOfIgnoreCase(searchString, 0) == -1))
                    continue;
                // Moved below code to new method "initialiseAddressSummary" to reduce CC as part of EDGE-127666 tech debt by Gnana - Start
                /*
                AddressSummary adr = new AddressSummary();
                adr.isSelected = false;
                adr.addressId = (String) site.get('id');
                adr.addressName = (String) site.get('name');
                adr.addressDisplayName = (String) site.get('display_name__c');
                adr.adborID = (String) site.get('adborid__c');
                adr.ipSiteconfigId = ipSiteconfigId;
                adr.legacysite = (String) site.get('legacysite');
                adr.sqStatusDesc = adborToSRStatus.containsKey((String) site.get('adborid__c')) ? adborToSRStatus.get((String) site.get('adborid__c')).get('nbnAvailability') : '';
                adr.sqStatus = adr.sqStatusDesc == 'Available';
                adr.nbnAvailability = adborToSRStatus.containsKey((String) site.get('adborid__c')) ? adborToSRStatus.get((String) site.get('adborid__c')).get('nbnAvailability') : '';
                adr.nbnRFSDate = adborToSRStatus.containsKey((String) site.get('adborid__c')) ? adborToSRStatus.get((String) site.get('adborid__c')).get('nbnRFSDate') : '';
                adr.nbnTechnologyType = adborToSRStatus.containsKey((String) site.get('adborid__c')) ? adborToSRStatus.get((String) site.get('adborid__c')).get('nbnTechnologyType') : '';
                adr.nbnTechnologyTypeAcrnym = adborToSRStatus.containsKey((String) site.get('adborid__c')) ? adborToSRStatus.get((String) site.get('adborid__c')).get('nbnTechnologyTypeAcrnym') : '';
                adr.nbnMaxUploadSpeed = adborToSRStatus.containsKey((String) site.get('adborid__c')) ? adborToSRStatus.get((String) site.get('adborid__c')).get('nbnMaxUploadSpeed') : '';
                adr.nbnMaxDownloadSpeed = adborToSRStatus.containsKey((String) site.get('adborid__c')) ? adborToSRStatus.get((String) site.get('adborid__c')).get('nbnMaxDownloadSpeed') : '';
                adr.copperPairIndicator = adborToSRStatus.containsKey((String) site.get('adborid__c')) ? adborToSRStatus.get((String) site.get('adborid__c')).get('copperPairIndicator') : '';
                adr.nbnCompatibility = adborToSRStatus.containsKey((String) site.get('adborid__c')) ? adborToSRStatus.get((String) site.get('adborid__c')).get('nbnCompatibility') : '';
                adr.nbnServiceabilityClass = adborToSRStatus.containsKey((String) site.get('adborid__c')) ? adborToSRStatus.get((String) site.get('adborid__c')).get('nbnServiceabilityClass') : '';
                
                //-------------added for EDGE-98322 by Samish on 30-11-19 START--------------//
                string adborid1 = (String) site.get('adborid__c');
                if(mapAdborId_CarriageSolution!=null && mapAdborId_CarriageSolution.containsKey(adborid1)){
                    adr.telstraFibreStatus = mapAdborId_CarriageSolution.get(adborid1).crgSolStatus;
                    adr.telstraFibreAdditionalInfo = mapAdborId_CarriageSolution.get(adborid1).crgSolReasonCode;
                }
                //-------------added for EDGE-98322 by Samish on 30-11-19 END-------------//
                
                adr.siteESACode = adborToSRStatus.containsKey((String) site.get('adborid__c')) ? adborToSRStatus.get((String) site.get('adborid__c')).get('siteESACode') : '';    //added by Samish for EDGE-123563 on 18-12-19
                */
                // Commented above code to new method "initialiseAddressSummary" to reduce CC as part of EDGE-127666 tech debt by Gnana - End
                addressList.add(initialiseAddressSummary(site,adborToSRStatus,mapAdborId_CarriageSolution));
            }

            selectedAddressList = JSON.serialize(getSelectedAddressList(addressList));

            system.debug('addressList: ' + addressList);
        } else {
            System.debug('getSiteMinusSubs: found nothing');
        }
    }
    
    // Created this method to reduce CC of runSearch method as part of EDGE-127666 tech debt by Gnana
    public Map<String,String> createAdborToSRStatusMap(cscrm__Site__c site){
        Map<String, String> adborToSQStatus = new Map<String, String>();
        adborToSQStatus.put('nbnAvailability', site.Service_qualifications__r[0].Status__c);
        adborToSQStatus.put('copperPairIndicator', site.Service_qualifications__r[0].Copper_Pair_Indicator__c);
        adborToSQStatus.put('nbnMaxDownloadSpeed', site.Service_qualifications__r[0].Max_Downstream_Speed__c);
        adborToSQStatus.put('nbnMaxUploadSpeed', site.Service_qualifications__r[0].Max_Upstream_Speed__c);
        adborToSQStatus.put('nbnTechnologyType', site.Service_qualifications__r[0].Technology_Type__c);
        //translation for technologyType
        if(site.Service_qualifications__r[0].Technology_Type__c=='Fibre To The Node'){
            //nbnAttributes.NBNTechnologyType='FTTN';
            adborToSQStatus.put('nbnTechnologyTypeAcrnym', 'FTTN');
        }else if(site.Service_qualifications__r[0].Technology_Type__c=='Fibre To The Building'){
            //nbnAttributes.NBNTechnologyType='FTTB';
            adborToSQStatus.put('nbnTechnologyTypeAcrnym', 'FTTB');
        }else if(site.Service_qualifications__r[0].Technology_Type__c=='Fibre To The Curb'){
            //nbnAttributes.NBNTechnologyType='FTTC';
            adborToSQStatus.put('nbnTechnologyTypeAcrnym', 'FTTC');
        }else if(site.Service_qualifications__r[0].Technology_Type__c=='Fibre To The Premise'){
            //nbnAttributes.NBNTechnologyType='FTTP';
            adborToSQStatus.put('nbnTechnologyTypeAcrnym', 'FTTP');
        }else if(site.Service_qualifications__r[0].Technology_Type__c=='Fibre'){
            //nbnAttributes.NBNTechnologyType='FTTP';
            adborToSQStatus.put('nbnTechnologyTypeAcrnym', 'FTTP');
        }else if(site.Service_qualifications__r[0].Technology_Type__c=='Wireless'){
            //nbnAttributes.NBNTechnologyType='Fixed Wireless';
            adborToSQStatus.put('nbnTechnologyTypeAcrnym', 'Fixed Wireless');
        }else {
            //nbnAttributes.NBNTechnologyType=serviceQ.Technology_Type__c;  
            adborToSQStatus.put('nbnTechnologyTypeAcrnym', site.Service_qualifications__r[0].Technology_Type__c);
        }
        
        if((site.Service_qualifications__r[0].Copper_Pair_Indicator__c!=null && (site.Service_qualifications__r[0].Copper_Pair_Indicator__c=='Yes' || site.Service_qualifications__r[0].Copper_Pair_Indicator__c=='NA')) || site.Service_qualifications__r[0].Technology_Type__c=='Fibre To The Premise' || site.Service_qualifications__r[0].Technology_Type__c=='FTTP' || site.Service_qualifications__r[0].Technology_Type__c=='Fibre'){
            adborToSQStatus.put('nbnCompatibility', 'Yes');
        }else{
            adborToSQStatus.put('nbnCompatibility', 'No');
        }
        adborToSQStatus.put('nbnServiceabilityClass', site.Service_qualifications__r[0].Serviceability_Class__c);        
        if (site.Service_qualifications__r[0].Ready_for_Service_Date__c != null)
            adborToSQStatus.put('nbnRFSDate', String.valueOf(site.Service_qualifications__r[0].Ready_for_Service_Date__c.format()));
        else
            adborToSQStatus.put('nbnRFSDate', '');
        
        if(String.isNotBlank(site.cscrm__Installation_Address__r.ESA_Code__c))  //added by Samish for EDGE-123563 on 18-12-19
            adborToSQStatus.put('siteESACode', '');
        
        return adborToSQStatus;
    }
    
    // Created method to reduce CC of runSearch method as part of EDGE-127666 tech debt by Gnana
    public AddressSummary initialiseAddressSummary(Map < String, Object > site, Map<String, Map<String, String>> adborToSRStatus, Map<String, CarriageSolution> mapAdborId_CarriageSolution){
        system.debug('inside initialiseAddressSummary...');
        AddressSummary adr = new AddressSummary();
        adr.isSelected = false;
        adr.addressId = (String) site.get('id');
        adr.addressName = (String) site.get('name');
        adr.addressDisplayName = (String) site.get('display_name__c');
        adr.adborID = (String) site.get('adborid__c');
        adr.ipSiteconfigId = ipSiteconfigId;
        adr.legacysite = (String) site.get('legacysite');
        adr.sqStatusDesc = adborToSRStatus.containsKey((String) site.get('adborid__c')) ? adborToSRStatus.get((String) site.get('adborid__c')).get('nbnAvailability') : '';
        adr.sqStatus = adr.sqStatusDesc == 'Available';
        adr.nbnAvailability = adborToSRStatus.containsKey((String) site.get('adborid__c')) ? adborToSRStatus.get((String) site.get('adborid__c')).get('nbnAvailability') : '';
        adr.nbnRFSDate = adborToSRStatus.containsKey((String) site.get('adborid__c')) ? adborToSRStatus.get((String) site.get('adborid__c')).get('nbnRFSDate') : '';
        adr.nbnTechnologyType = adborToSRStatus.containsKey((String) site.get('adborid__c')) ? adborToSRStatus.get((String) site.get('adborid__c')).get('nbnTechnologyType') : '';
        adr.nbnTechnologyTypeAcrnym = adborToSRStatus.containsKey((String) site.get('adborid__c')) ? adborToSRStatus.get((String) site.get('adborid__c')).get('nbnTechnologyTypeAcrnym') : '';
        adr.nbnMaxUploadSpeed = adborToSRStatus.containsKey((String) site.get('adborid__c')) ? adborToSRStatus.get((String) site.get('adborid__c')).get('nbnMaxUploadSpeed') : '';
        adr.nbnMaxDownloadSpeed = adborToSRStatus.containsKey((String) site.get('adborid__c')) ? adborToSRStatus.get((String) site.get('adborid__c')).get('nbnMaxDownloadSpeed') : '';
        adr.copperPairIndicator = adborToSRStatus.containsKey((String) site.get('adborid__c')) ? adborToSRStatus.get((String) site.get('adborid__c')).get('copperPairIndicator') : '';
        adr.nbnCompatibility = adborToSRStatus.containsKey((String) site.get('adborid__c')) ? adborToSRStatus.get((String) site.get('adborid__c')).get('nbnCompatibility') : '';
        adr.nbnServiceabilityClass = adborToSRStatus.containsKey((String) site.get('adborid__c')) ? adborToSRStatus.get((String) site.get('adborid__c')).get('nbnServiceabilityClass') : '';
        
        //-------------added for EDGE-98322 by Samish on 30-11-19 START--------------//
        string adborid1 = (String) site.get('adborid__c');
        if(mapAdborId_CarriageSolution!=null && mapAdborId_CarriageSolution.containsKey(adborid1)){
            adr.telstraFibreStatus = mapAdborId_CarriageSolution.get(adborid1).crgSolStatus;
            adr.telstraFibreAdditionalInfo = mapAdborId_CarriageSolution.get(adborid1).crgSolReasonCode;
        }
        //-------------added for EDGE-98322 by Samish on 30-11-19 END-------------//
        
        adr.siteESACode = adborToSRStatus.containsKey((String) site.get('adborid__c')) ? adborToSRStatus.get((String) site.get('adborid__c')).get('siteESACode') : '';    //added by Samish for EDGE-123563 on 18-12-19
        system.debug('completed initialiseAddressSummary... '+ adr);
        return adr;
    }

    //clear variables
    @TestVisible
    private void clearVar() {
        // addressList = new List<AddressSummary>();
        // searchString = '';
        //pgMessage = '';
    }


    //Manoj Kumar : bug : EDGE-105508 : callout for api v2
    @TestVisible
    private ReplicatorGetSiteDataObject_V2 getCustomerSitesV2(String finCIDN) {
        String token = AuthenticationManager.getOauthToken('ReplicatorGetSiteService');
        String correId = 'SFDC_REP_GETSITE' + IntegrationRecordHandlerUtil.getCorrelationId();
        Map < String, String > headerMap = new Map < String, String > {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer ' + token,
            'correlationId' => correId //EDGE-105508 
        };
        String payload = 'CIDN=' + finCIDN;
        ReplicatorGetSiteDataObject_V2 getSiteDTO_V2;
        
        //------------Added by Pawan for EDGE-113537 START-----------//
        DateTime startTime;
        DateTime endTime;
        Boolean isLoggingDone = false;
        //------------Added by Pawan for EDGE-113537 END-----------//       
        
        try {
                    if(Test.isRunningTest() && testCheck){
                CalloutException e = new CalloutException();
                throw e;
                }
                
            if(!isLoggingDone){                  //Added by Pawan for EDGE-113537
                startTime = DateTime.now();
            }
            HttpResponse res = IntegrationRecordHandlerUtil.callout(payload, IntegrationRecordHandlerUtil.HTTP_METHOD_GET, headerMap, ReplicatorGetSiteService.class.getName(), null, correId);
            if(!isLoggingDone){                 //Added by Pawan for EDGE-113537
                endTime = DateTime.now();
                isLoggingDone = createLogEntry(isLoggingDone, startTime, endTime, payload, res, correId, 'SiteSQAddressHandler');
                
            }
            System.debug('GetSiteResponse: ' + res.getBody());
                        
            System.debug('GetSiteResponseCode: ' + res.getStatusCode());
            getSiteDTO_V2 = ReplicatorGetSiteDataObject_V2.parse(res.getBody());
            System.debug('GetSiteDTO: ' + getSiteDTO_V2);

                

          /*  if (getSiteDTO.Site != null) {
                for (ReplicatorGetSiteDataObject.SiteDTO site: getSiteDTO.Site) {
                    site.concatenatedAddress = site.Sub1_CodeSet_Abbrev + ' ' + site.Sub1_Descriptor_1 + site.Sub1_Descriptor_2 + ' ' +
                        site.Sub2_CodeSet_Abbrev + ' ' + site.Sub2_Descriptor_1 + ' ' + site.Sub2_Descriptor_2 + ' ' +
                        site.Sub3_CodeSet_Abbrev + ' ' + site.Sub3_Descriptor_1 + ' ' + site.Sub3_Descriptor_2 + ' ' +
                        site.Sub4_CodeSet_Abbrev + ' ' + site.Sub4_Descriptor_1 + ' ' + site.Sub4_Descriptor_2 + ' ' +
                        site.Street_Name + ' ' + site.Address_No_From + site.Suffix_From + '-' + site.Address_No_To + ' ' + site.Suffix_To + ' ' +
                        site.Name + ' ' + site.Street_Type + ' ' + site.Loc_Name + ' ' + site.State;
                    if (site.concatenatedAddress != null) {
                        site.concatenatedAddress = site.concatenatedAddress.replace('  ', ' ');
                        site.concatenatedAddress = site.concatenatedAddress.replace('- ', '');
                    }
                }
            } */
            if (res.getStatusCode() != IntegrationRecordHandlerUtil.HTTP_SUCCESS) {
                String internalErrorDesc;
                if (String.isBlank(getSiteDTO_V2.Error_Code) && String.isBlank(getSiteDTO_V2.Error_Description)) {
                    if (res.getStatusCode() == IntegrationRecordHandlerUtil.ERROR_404_CODE) {
                        getSiteDTO_V2.Error_Code = String.valueOf(IntegrationRecordHandlerUtil.ERROR_404_CODE);
                        internalErrorDesc = IntegrationRecordHandlerUtil.ERROR_404_DESC;
                    } else if (res.getStatusCode() == IntegrationRecordHandlerUtil.ERROR_500_CODE) {
                        getSiteDTO_V2.Error_Code = String.valueOf(IntegrationRecordHandlerUtil.ERROR_500_CODE);
                        internalErrorDesc = IntegrationRecordHandlerUtil.ERROR_500_DESC;
                    } else if (res.getStatusCode() == IntegrationRecordHandlerUtil.ERROR_503_CODE) {
                        getSiteDTO_V2.Error_Code = String.valueOf(IntegrationRecordHandlerUtil.ERROR_503_CODE);
                        internalErrorDesc = IntegrationRecordHandlerUtil.ERROR_503_DESC;
                    } else {
                        internalErrorDesc = Label.Replicator_Technical_Error_Message;
                    }
                    getSiteDTO_V2.Error_Code = String.valueOf(res.getStatusCode());
                    getSiteDTO_V2.Error_Description = internalErrorDesc;
                }
                Logger.getLogger(ReplicatorGetSiteService.class + ':' + correId).debug(getSiteDTO_V2.Error_Code + ': ' + getSiteDTO_V2.Error_Description);
                
            }
        } catch (Exception e) {
            System.debug('getCustomerSites Exception: ' + e);
            Logger.getLogger(ReplicatorGetSiteService.class + ':' + correId).debug(e);
            Logger.exitLogger();
            return null;
        }
        System.debug('Final GetSiteDTO: ' + getSiteDTO_V2);
        return getSiteDTO_V2;
    }
    
    
    private ReplicatorGetSiteDataObject getCustomerSites(String finCIDN) {
        String token = AuthenticationManager.getOauthToken('ReplicatorGetSiteService');
        String correId = 'SFDC_REP_GETSITE' + IntegrationRecordHandlerUtil.getCorrelationId();
        Map < String, String > headerMap = new Map < String, String > {
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer ' + token,
            'correlationId' => correId //EDGE-105508 
        };
        String payload = 'CIDN=' + finCIDN;
        ReplicatorGetSiteDataObject getSiteDTO;
        //------------Added by Pawan for EDGE-113537 START-----------//
        DateTime startTime;
        DateTime endTime;
        Boolean isLoggingDone = false;
        //------------Added by Pawan for EDGE-113537 END-----------//
        try {
            if(!isLoggingDone){                  //Added by Pawan for EDGE-113537
                startTime = DateTime.now();
            }
            HttpResponse res = IntegrationRecordHandlerUtil.callout(payload, IntegrationRecordHandlerUtil.HTTP_METHOD_GET, headerMap, ReplicatorGetSiteService.class.getName(), null, correId);
            if(!isLoggingDone){                 //Added by Pawan for EDGE-113537
                endTime = DateTime.now();
                isLoggingDone = createLogEntry(isLoggingDone, startTime, endTime, payload, res, correId, 'SiteSQAddressHandler');
            }
            System.debug('GetSiteResponse: ' + res.getBody());
            getSiteDTO = ReplicatorGetSiteDataObject.parse(res.getBody());
            System.debug('GetSiteDTO: ' + getSiteDTO);


            if (getSiteDTO.Site != null) {
                for (ReplicatorGetSiteDataObject.SiteDTO site: getSiteDTO.Site) {
                    site.concatenatedAddress = site.Sub1_CodeSet_Abbrev + ' ' + site.Sub1_Descriptor_1 + site.Sub1_Descriptor_2 + ' ' +
                        site.Sub2_CodeSet_Abbrev + ' ' + site.Sub2_Descriptor_1 + ' ' + site.Sub2_Descriptor_2 + ' ' +
                        site.Sub3_CodeSet_Abbrev + ' ' + site.Sub3_Descriptor_1 + ' ' + site.Sub3_Descriptor_2 + ' ' +
                        site.Sub4_CodeSet_Abbrev + ' ' + site.Sub4_Descriptor_1 + ' ' + site.Sub4_Descriptor_2 + ' ' +
                        site.Street_Name + ' ' + site.Address_No_From + site.Suffix_From + '-' + site.Address_No_To + ' ' + site.Suffix_To + ' ' +
                        site.Name + ' ' + site.Street_Type + ' ' + site.Loc_Name + ' ' + site.State;
                    if (site.concatenatedAddress != null) {
                        site.concatenatedAddress = site.concatenatedAddress.replace('  ', ' ');
                        site.concatenatedAddress = site.concatenatedAddress.replace('- ', '');
                    }
                }
            }
            if (res.getStatusCode() != IntegrationRecordHandlerUtil.HTTP_SUCCESS) {
                String internalErrorDesc;
                if (String.isBlank(getSiteDTO.Error_Code) && String.isBlank(getSiteDTO.Error_Description)) {
                    if (res.getStatusCode() == IntegrationRecordHandlerUtil.ERROR_404_CODE) {
                        getSiteDTO.Error_Code = String.valueOf(IntegrationRecordHandlerUtil.ERROR_404_CODE);
                        internalErrorDesc = IntegrationRecordHandlerUtil.ERROR_404_DESC;
                    } else if (res.getStatusCode() == IntegrationRecordHandlerUtil.ERROR_500_CODE) {
                        getSiteDTO.Error_Code = String.valueOf(IntegrationRecordHandlerUtil.ERROR_500_CODE);
                        internalErrorDesc = IntegrationRecordHandlerUtil.ERROR_500_DESC;
                    } else if (res.getStatusCode() == IntegrationRecordHandlerUtil.ERROR_503_CODE) {
                        getSiteDTO.Error_Code = String.valueOf(IntegrationRecordHandlerUtil.ERROR_503_CODE);
                        internalErrorDesc = IntegrationRecordHandlerUtil.ERROR_503_DESC;
                    } else {
                        internalErrorDesc = Label.Replicator_Technical_Error_Message;
                    }
                    getSiteDTO.Error_Code = String.valueOf(res.getStatusCode());
                    getSiteDTO.Error_Description = internalErrorDesc;
                }
                Logger.getLogger(ReplicatorGetSiteService.class + ':' + correId).debug(getSiteDTO.Error_Code + ': ' + getSiteDTO.Error_Description);             
            }
        } catch (Exception e) {
            System.debug('getCustomerSites Exception: ' + e);
            Logger.getLogger(ReplicatorGetSiteService.class + ':' + correId).debug(e);
            Logger.exitLogger();
            return null;
        }
        System.debug('Final GetSiteDTO: ' + getSiteDTO);
        return getSiteDTO;
    }

    public List <AddressSummary> getSelectedAddressList (List <AddressSummary> sourceList) {
        List <AddressSummary> ret = new List <AddressSummary>();
        for (AddressSummary adrSum: sourceList) {
            if (adrSum.isSelected) {
                ret.add(adrSum);
            }
        }
        return ret;
    }

    //EDGE-108959
    private void isOfferSQcheckRequired() {
        offerSQcheckRequired = 'Yes';
        if (String.isNotBlank(offerId)) {
            //we have offer if, see if SQ check is required
            List<Marketable_Offer__c> marketableOffers = [SELECT Id, SqCheckNotRequired__c FROM Marketable_Offer__c WHERE Offer_ID__c = :offerId];
            if (!marketableOffers.isEmpty()) {
                offerSQcheckRequired = marketableOffers[0].SqCheckNotRequired__c ? 'No' : 'Yes';
            }
        }

        //------------Added new logic for SQ check - for EDGE-98322 by Samish on 30-11-19 START---------------//
        system.debug('@@@@# isOfferSQcheckRequired().offerId= '+offerId);
        if (String.isNotBlank(offerId)){
            lstSQMapping = [SELECT Carriage_Solution__c, NBN_SQ__c, OfferId__c, Telstra_Fibre_SQ__c FROM Offer_to_SQ_mapping__mdt WHERE OfferId__c =: offerId LIMIT 1];

            if(lstSQMapping!=null && lstSQMapping.size()>0){
                if(lstSQMapping[0].Telstra_Fibre_SQ__c)
                    newOfferSQcheckRequired = 'Yes';
                else
                    newOfferSQcheckRequired = 'No';
                CARRIAGESOLUTION = lstSQMapping[0].Carriage_Solution__c;
            }
            system.debug('@@@@# CARRIAGESOLUTION= '+CARRIAGESOLUTION);
            system.debug('@@@@# newOfferSQcheckRequired= '+newOfferSQcheckRequired); 
        }
        //------------Added new logic for SQ check - for EDGE-98322 by Samish on 30-11-19 END---------------//
    }
    
    /*private Map<String,Service_Qualification__c > getInsertedOrphanSQRecords(List<String> AdborIdList){
        Map<String,Service_Qualification__c > SqMap=new Map<String,Service_Qualification__c >();
        for(Service_Qualification__c sqrec:[Select id,Address_ID__c,Site__c,lastmodifieddate  from Service_Qualification__c where Site__c=null and Address_ID__c IN:AdborIdList order by lastmodifieddate desc]){
            if(!SqMap.containsKey(sqrec.Address_ID__c)){
                SqMap.put(sqrec.Address_ID__c,sqrec);
            }
        }
        return SqMap;
    }*/

    //------------------------------Added for EDGE-98322 by Samish - START------------------------------//

    //To make NBN SQ callout
    public void makeNBNSQCallout(){
        system.debug('@@@@# makeNBNSQCallout called');
        makeSQCallout('NBN');
    }

    //To make Telstra Fibre SQ callout
    public void makeTelstraFibreSQCallout(){
        system.debug('@@@@# makeTelstraFibreSQCallout called');
        makeSQCallout('Telstra Fibre');
    }
    
    //Added for EDGE-98322 by Samish
    public Map<String,HttpResponse> widefeasCalloutSQ(String token,String techType, String sqHandler){
        WidefeaseSQResponseDTO responseDTO =null;
        // String sqHandler ='WidefeasSQAddressHandler'; //TODO- to be used from custom lable
        Logger2 logger = Logger2.getLogger(sqHandler);
        //------------Added by Samish for EDGE-113537 START-----------//
        String correlationId = IntegrationRecordHandlerUtil.getCorrelationId();
        DateTime startTime;
        DateTime endTime;
        Boolean isLoggingDone = false;
        //------------Added by Samish for EDGE-113537 END-----------//
        HttpResponse response;
        String payload = '';
        String profileId='enterprise';
        Map<String,HttpResponse> addressToResponseMap = new Map<String,HttpResponse>();
        Map<String,WidefeaseSQResponseDTO > responseDTOMap = new Map<String,WidefeaseSQResponseDTO >();
        try{    
            system.debug('@@@@# addressidList for callout= '+addressidList);
            for(String addressId:addressidList){
                payload = 'addressId='+addressid+'&profileId='+profileId;
                Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token,'Correlation-Id'=>correlationId};
                if(!isLoggingDone)                  //Added by Samish for EDGE-113537
                    startTime = DateTime.now();
                response = IntegrationRecordHandlerUtil.callout(payload,'GET',headerMap,sqHandler,null, null);
                if(!isLoggingDone){                 //Added by Samish for EDGE-113537
                    endTime = DateTime.now();
                    isLoggingDone = createLogEntry(isLoggingDone, startTime, endTime, payload, response, correlationId, sqHandler);
                }                  
                    
                //String responseCode = String.valueOf(response.getStatusCode());       //Commented by Samish as the variable was unused EDGE-113537
                System.debug('@@@@# widefeasCalloutSQ() response==== '+response);
                System.debug('@@@@# widefeasCalloutSQ() response.getBody==== '+response.getBody());
                addressToResponseMap.put(addressid,response);
                counter++;
            }
        }catch (Exception e) {
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();
            //resultStr = e.getMessage();
        }
        
        system.debug('@@@@# addressToResponseMap= ' +addressToResponseMap);    
        return addressToResponseMap ;
    }

//------------------------------Added for EDGE-98322 by Samish - END------------------------------//
    
    //Address summary class
    global class AddressSummary {
        public String addressId {
            get;
            set;
        }
        public String addressName {
            get;
            set;
        }
        public String addressDisplayName {
            get;
            set;
        }
        public String addressLine1 {
            get;
            set;
        }
        public String addressLine2 {
            get;
            set;
        }
        public String addressType {
            get;
            set;
        }
        public string adborID {
            get;
            set;
        }
        public Boolean isSelected {
            get;
            set;
        }
        public String ipSiteconfigId {
            get;
            set;
        }
        public String legacysite {
            get;
            set;
        }
        public String sqStatusDesc {
            get;
            set;
        }
        public Boolean sqStatus {
            get;
            set;
        }
        public String sqStatusErrorMessage {
            get;
            set;
        }

        public String nbnAvailability {
            get;
            set;
        }
        public String nbnRFSDate {
            get;
            set;
        }
        public String nbnTechnologyType {
            get;
            set;
        }
        public String nbnTechnologyTypeAcrnym {
            get;
            set;
        }
        public String nbnMaxUploadSpeed {
            get;
            set;
        }
        public String nbnMaxDownloadSpeed {
            get;
            set;
        }
        public String copperPairIndicator {
            get;
            set;
        }
        public String nbnCompatibility {
            get;
            set;
        }
        public String nbnServiceabilityClass {
            get;
            set;
        }
        public String telstraFibreStatus {          //added for EDGE-98322 by Samish on 30-11-19
                get;
                set;
            }
        public String telstraFibreAdditionalInfo {  //added for EDGE-98322 by Samish on 30-11-19
                get;
                set;
            }
        public String siteESACode {  //added for EDGE-123563 on 18-12-19 
                get;
                set;
            }     
        
        /*public SQDetails sqdetails {
            get;
            set;
        }
        
        public class SQDetails {
            public string nbnAdborID {
                get;
                set;
            }
            public String nbnAvailability {
                get;
                set;
            }
            public String nbnRFSDate {
                get;
                set;
            }
            public String nbnTechnologyType {
                get;
                set;
            }
            public String nbnMaxUploadSpeed {
                get;
                set;
            }
            public String nbnMaxDownloadSpeed {
                get;
                set;
            }
            public String telstraFibreStatus {
                get;
                set;
            }
            public String telstraFibreAdditionalInfo {
                get;
                set;
            }           
        }*/
    }    

    //------------------------------Added for EDGE-98322 by Samish - START------------------------------//
    public class CarriageSolution{
        String crgSolStatus;
        String crgSolReasonCode;
    }
    //------------------------------Added for EDGE-98322 by Samish - END------------------------------//
}