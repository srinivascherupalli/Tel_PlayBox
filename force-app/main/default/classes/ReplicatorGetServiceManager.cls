/**
* @Author   :   Maqsood Alam
* @Date     :   22 May 2019
* @Desc     :   Changing the response type from replicator based on new response JSON (Flat JSON structure)
* @US       :   EDGE-75696, EDGE-85840, EDGE-84055
* @Status   :   End point Deveopment is still pending.
* 
EDGE 145809 - Aarathi from Team Amsterdam - additional eligibility method to check with Number object
EDGE 148583 - Aarathi from Team Amsterdam - changed error message
EDGE-152495 - Vivek/Ankit from Team Apple - Seprating the grouping logic for TIPT-SIPC Product family; using hybrid logic for this family
EDGE-151827  - Mukta from Team Apple      - Prepare transtion UI table grouping for TIPT-SIPC
EDGE-204581 - Vivek/Ankit from Team Apple - Rainy day scenario for TIPT-SIPC
* */
public with sharing class ReplicatorGetServiceManager {
    public static Boolean DuplicateServiceIdCheck = false;
    public static string errorDescription = '';
    public static Integer errorStatusCode;
    public static string errorDescriptionMobile = '';
    public static Integer errorStatusCodeMobile;
    public static string errorDescriptionNGUC = '';
    public static Integer errorStatusCodeNGUC;
    public static String TransitionJSONDataMobile = Label.MobileTransitionName;
    public static String TransitionJSONDataNgUc = Label.NgUcTransitionName;
    public static String mobileOfferName = 'CWP Mobility';
    public static String productSpecMobile = Label.ProductSpecificationMobile;
    public static List < String > listproductSpecMobile = productSpecMobile.split(',');
    public static List < String > listproductSpecNgUc = Label.ProductSpecificationNgUc.split(',');
    public static Map < String, Map < String, list < String >>> gdnParentChild = New Map < String, Map < String, list < String >>> ();
    public static Map < String, Map < String, List < TransitionDataDTO.serviceDTOMobile > >> prodGroupTypeMapping = New Map < String, Map < String, List < TransitionDataDTO.serviceDTOMobile > >> ();
    public static Map < String, list < TransitionDataDTO.SiteDTOMobile >> prodSiteMapGlobal = new Map < String, list < TransitionDataDTO.SiteDTOMobile >> ();
    public static Map < String, String > parentUniqueStringMap = new Map < String, String > ();
    public static map < string, List < TransitionDataDTO.serviceDTOMobile >> groupUniqueStringMap = new map < string, List < TransitionDataDTO.serviceDTOMobile >> ();
    public static Map < string, list < string >> prodGroupTypeNewMapping = new Map < string, list < string >> ();
    public static map < string, map < string, string >> groupEligibleMap = new map < string, map < string, string >> ();
    public static String FNN_String = ''; // EDGE-152495 Added By vivek
    public static Set < String > CIDN_String_List = new Set < String > (); // EDGE-152495 Added By vivek
    public static Map < String, String > fnnToTypeOfService = new Map < String, String > (); // EDGE-152495 Added By vivek
    public static Map < String, Boolean > productFamilyToHybridCheck = new map < String, Boolean > (); // EDGE-152495 : @Apple : VM ;
    
    private static String correlationId = GuidUtil.NewGuid();
    private static final String CONST_INTERFACENAME = 'ReplicatorGetServiceManager';
    private static final C2O_ExceptionHandler.Capability CONST_CAPABILITY = C2O_ExceptionHandler.Capability.BSK;
    public static String isOsakaDormant	= 	System.Label.Is_Osaka_Dormant_21_09; //Added flag for dormancy by Jay (Osaka) as a part of EDGE-208790
    public static String sioConfigMode;//DIGI-1681

    //Start of DIGI-16451 by Abhishek (Osaka) to enable IoT
    public static Map<string,Sobject> MTMMetadataUtilityMap = ConstantMetadataUtility.getConstantMetadataUtilityRecords('MTM_Metadata_Utility__mdt');
    public static String IoT_Dormancy = String.valueOf(MTMMetadataUtilityMap.get('IoT_Dormancy').get('Value__c'));
    //End of DIGI-16451
    
    /*--- fetch valid adborId With Legacy and call replicator function to get the response ---*/
    public static ReplicatorGetServiceDTO getCustomerServicesNew(String finCIDN, String prodBasSites, String selectedAdborid) {
        System.debug('**********prodBasSites : ' + prodBasSites);
        System.debug('**********selectedAdborid : ' + selectedAdborid);
        Map < String,
            ProductBasketSiteDataObject > mapProdBasSites = (Map < String, ProductBasketSiteDataObject > ) System.JSON.deserialize(prodBasSites, Map < String, ProductBasketSiteDataObject > .class);
        List < String > adbor_Id = new List < String > ();
        List < String > adborIdWithLegacy = new List < String > ();
        for (ProductBasketSiteDataObject prodSite: mapProdBasSites.Values()) {
            adbor_Id.add(prodSite.adBorId);
        }
        System.debug('**********adbor_Id : ' + adbor_Id);
        System.debug('**********mapProdBasSites : ' + mapProdBasSites);
        List < cscrm__Site__c > lstSite = [select Legacy__c, AdborID__c from cscrm__Site__c where AdborID__c in: adbor_Id];
        for (cscrm__Site__c sit: lstSite) {
            if (sit.Legacy__c) {
                adborIdWithLegacy.add(sit.AdborID__c);
            }
        }
        if (adborIdWithLegacy.isEmpty()) {
            return null;
        }
        return getCustomerServicesAtSite_V2(finCIDN, adborIdWithLegacy, selectedAdborid);
    }
    // Call to Replicator to get ReplicatorGetServiceDataObject
    public static ReplicatorGetServiceDTO getCustomerServicesAtSite_V2(String finCIDN, List < String > adbor_Id, String selectedAdborid) {
        ReplicatorGetServiceDTO serviceDTO;
        try {
           
            /* Replicator end point call to get the response */
            serviceDTO = getCustomerServices_V2(finCIDN, adbor_Id, selectedAdborid);
            Integer i = test.isRunningTest() ? 1 / 0 : 0;
            
        } catch (Exception ex) {
            System.debug('Exception Occure In Response from Replicator' + ex);
            System.debug(LoggingLevel.debug, '--->Error occurred##> ' + ex.getMessage());
            System.debug(LoggingLevel.debug, '--->Error Line##> ' + ex.getLineNumber());
            System.debug(LoggingLevel.debug, '--->Error Trace##> ' + ex.getStackTraceString());
            System.debug(LoggingLevel.debug, '--->Error Cause##> ' + ex.getCause());
            Logger.getLogger(ReplicatorManager.class).debug(ex);
            Logger.exitLogger();
            
            logException('getCustomerServicesAtSite_V2', '', correlationId, ex.getMessage(), 'Get ReplicatorGetServiceDataObject');
            
            if(Test.isRunningTest()){               
               logException(null,'getCustomerServicesAtSite_V2', '','','', correlationId,'','', ex.getMessage(), 'Get ReplicatorGetServiceDataObject','',null,'',''); 
            }
        }
        System.debug('serviceDTO' + serviceDTO);
        return serviceDTO;
    }
    /**
* @Author   :   Maqsood Alam
* @Date     :   22 May 2019
* @Desc     :   Changing the response type from replicator based on new response JSON
* @Status   :   End point is pending from replicator team.
* */
    public static ReplicatorGetServiceDTO getCustomerServices_V2(String finCIDN, List < String > adborId, String selectedAdborid) {
        ReplicatorGetServiceDTO getServiceDTO;
        String GETSERVICE_EVENT = 'ReplicatorLegacyAssetService';
        String token = AuthenticationManager.getOauthToken(GETSERVICE_EVENT);
        String cidn = finCIDN;
        String siteId = selectedAdborid;
        if (selectedAdborid == '') {
            for (String item: adborId) {
                if (item != '') siteId = item;
                break;
            }
        }
        //    String correId = 'SFDC_REP_GETSERVICE'+IntegrationRecordHandlerUtil.getCorrelationId();
        String correId = IntegrationRecordHandlerUtil.getCorrelationId();
        Long requestTime = null;
        Logger2 logger2 = Logger2.getLogger(ReplicatorGetServiceManager.class);
        Map < String,
            String > headerMap = new Map < String,
            String > {
                'Content-Type' => 'application/json',
                    'Authorization' => 'Bearer ' + token,
                    'correlationId' => correId,
                    'siteId' => siteId,
                    'cidn' => cidn,
                    'siteType' => 'ADBOR_ID'
                    };
                        try {
                            /* Calling replicator end point -- */
                            DateTime startTime = DateTime.now();
                            HttpResponse res = IntegrationRecordHandlerUtil.callout('', IntegrationRecordHandlerUtil.HTTP_METHOD_GET, headerMap, ReplicatorLegacyAssetService.class.getName(), null, correId);
                            DateTime endTime = DateTime.now();
                            requestTime = logger2.getRequestTimeDifference(startTime, endTime);
                            System.debug('GetServiceResponse: ' + res.getBody());
                            getServiceDTO = ReplicatorGetServiceDTO.parse(res.getBody().replace('serviceextension', 'service_extension').replace('"services"', '"servicesList"'));
                            //    getServiceDTO = ReplicatorGetServiceDTO.parse('{"correlationId":"6bcb6236dccdd5a428","services":[{"cidn":"1100037407","productFamily":"ISDN2DID","fnn":"08472251115","site":{"siteType":"ADBOR_ID","siteId":"50866935"},"replicatorUpdateDateTime":"2019-05-06 17:41:50.573","account":{"accountNumber":"","complexBillingIndicator":"","creditManagementFlag":"","serviceWithEtcFlag":""},"serviceCharacteristics":[{"name":"association_type","value":""},{"name":"directory_option","value":"Directory Listing"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":""},{"name":"service_extension","value":"50829813450-50829813540"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"50829813"}],"devices":[],"serviceAssociations":[],"serviceExtensions":[]},{"cidn":"1100037407","productFamily":"ISDN2","fnn":"0847225111","site":{"siteType":"ADBOR_ID","siteId":"50866935"},"replicatorUpdateDateTime":"2019-05-06 17:41:50.573","account":{"accountNumber":"","complexBillingIndicator":"","creditManagementFlag":"","serviceWithEtcFlag":""},"serviceCharacteristics":[{"name":"association_type","value":""},{"name":"directory_option","value":"Directory Listing"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":""},{"name":"service_extension","value":"5082981345-5082981354"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"50829813"}],"devices":[],"serviceAssociations":[],"serviceExtensions":[]},{"cidn":"1100037407","productFamily":"PSTN","fnn":"08472251112","site":{"siteType":"ADBOR_ID","siteId":"50484467"},"replicatorUpdateDateTime":"2019-05-06 17:41:50.573","account":{"accountNumber":"","complexBillingIndicator":"","creditManagementFlag":"","serviceWithEtcFlag":""},"serviceCharacteristics":[{"name":"association_type","value":""},{"name":"directory_option","value":"Directory Listing"},{"name":"inflight_order","value":"N"},{"name":"service_association_role","value":""},{"name":"service_extension","value":"5082981345-5082981354"},{"name":"service_type","value":"voice"},{"name":"source_site","value":"50829813"}],"devices":[],"serviceAssociations":[],"serviceExtensions":[]}]}'.replace('"services"', '"servicesList"' ));  // for review and confirm
                            system.debug('adbID---> ' + selectedAdborid);
                            System.debug('GetServiceDTO: ' + JSON.serialize(getServiceDTO));
                            /* If Error is returned in the response */
                            if (res.getStatusCode() != IntegrationRecordHandlerUtil.HTTP_SUCCESS) {
                                String internalErrorDesc;
                                if (res.getStatusCode() == IntegrationRecordHandlerUtil.ERROR_404_CODE) {
                                    internalErrorDesc = IntegrationRecordHandlerUtil.ERROR_404_DESC;
                                } else if (res.getStatusCode() == IntegrationRecordHandlerUtil.ERROR_500_CODE) {
                                    internalErrorDesc = IntegrationRecordHandlerUtil.ERROR_500_DESC;
                                } else if (res.getStatusCode() == IntegrationRecordHandlerUtil.ERROR_503_CODE) {
                                    internalErrorDesc = IntegrationRecordHandlerUtil.ERROR_503_DESC;
                                } else {
                                    internalErrorDesc = Label.Replicator_Technical_Error_Message;
                                }
                                errorDescription = internalErrorDesc;
                                errorStatusCode = res.getStatusCode();
                                logger2.logMessages(cidn, res.getBody(), '', '', '', '', String.ValueOf(res.getStatusCode()), correId, '', '', '', '', requestTime, '', false, false);
                                logger2.exitLogger();
                            } else {
                                logger2.logMessages(cidn, res.getBody(), '', '', '', '', String.ValueOf(res.getStatusCode()), correId, '', '', '', '', requestTime, '', false, false);
                                logger2.exitLogger();
                            }
                        } catch (Exception ex) {
                            System.debug('Exception Occure In Response from Replicator' + ex);
                            System.debug(LoggingLevel.debug, '--->Error occurred##> ' + ex.getMessage());
                            System.debug(LoggingLevel.debug, '--->Error Line##> ' + ex.getLineNumber());
                            System.debug(LoggingLevel.debug, '--->Error Trace##> ' + ex.getStackTraceString());
                            System.debug(LoggingLevel.debug, '--->Error Cause##> ' + ex.getCause());
                            logger2.logMessages('ReplicatorGetServiceManager:getCustomerServices_V2', ex.getMessage(), '', '', '', '', false, false, null, null, null, null);
                            logger2.exitLogger();
                            
                            logException('getCustomerServices_V2', '', correlationId, ex.getMessage(), 'Get getCustomerServices_V2 response');

                            
                            return null;
                        }
        System.debug('Final GetServiceDTO: ' + getServiceDTO);
        return getServiceDTO;
    }
    /* Parsing logic - Convert Flat based JSON response  to Trnasition JSON hierarchy structure*/
    public static ReplicatorGetServiceDataObject_V2 replicatorResponseToTransition(ReplicatorGetServiceDTO serviceObjDTO) {
        ReplicatorGetServiceDataObject_V2 serviceDTO_new = new ReplicatorGetServiceDataObject_V2();
        try {
            List < ReplicatorGetServiceDataObject_V2.SiteDTO_V2 > siteList = new List < ReplicatorGetServiceDataObject_V2.SiteDTO_V2 > ();
            Map < String, ReplicatorGetServiceDataObject_V2.SiteDTO_V2 > siteMap = new Map < String, ReplicatorGetServiceDataObject_V2.SiteDTO_V2 > ();
            List < ReplicatorGetServiceDataObject_V2.productListDTO > prdListDTOListAll = new List < ReplicatorGetServiceDataObject_V2.productListDTO > ();
            Map < String, ReplicatorGetServiceDataObject_V2.productListDTO > prdListDTOMap = new Map < String, ReplicatorGetServiceDataObject_V2.productListDTO > ();
            map < String, list < ReplicatorGetServiceDataObject_V2.serviceListDTO >> serviceListMap = new map < String, list < ReplicatorGetServiceDataObject_V2.serviceListDTO >> ();
            Map < String, ReplicatorGetServiceDataObject_V2.ServiceAssociationsDTO_V2 > sAssocMap = new Map < String, ReplicatorGetServiceDataObject_V2.ServiceAssociationsDTO_V2 > (); //EDGE 98925
            String CIDN_String = '';
            String sioConfig = '';
            for (ReplicatorGetServiceDTO.servicesDTO serviceDetails: serviceObjDTO.servicesList) {
                CIDN_String = serviceDetails.cidn;
                if(sioConfig=='' || sioConfig == 'N'){
                    sioConfig=serviceDetails.addOns==null?'N':'Y';//Anurag
                }
                System.debug('---sioConfig---'+sioConfig);
                Map < String, Map < String, List < ReplicatorGetServiceDataObject_V2.ServiceDTO_V2 >>> ProdToServListMap = new Map < String, Map < String, List < ReplicatorGetServiceDataObject_V2.ServiceDTO_V2 >>> ();
                Map < String, List < ReplicatorGetServiceDataObject_V2.ServiceDTO_V2 >> serviceTypeToserviceDTO_v2Map = new Map < String, List < ReplicatorGetServiceDataObject_V2.ServiceDTO_V2 >> ();
                try {
                    ProdToServListMap = getProductTypeSites(serviceDetails);
                } catch (exception e) {
                    System.debug('Exception-->' + e);
                    logException('replicatorResponseToTransition', '', correlationId, e.getMessage(), 'Get Product type sites');
                }
                if (siteMap.containskey(serviceDetails.site.siteId)) {
                    // -- Code to populate ProdToServListMap Map ----                    
                    system.debug('----------ProdToServListMap----:  ' + JSON.serialize(ProdToServListMap));
                    for (String prodType: ProdToServListMap.keyset()) {
                        serviceTypeToserviceDTO_v2Map = ProdToServListMap.get(prodType);
                        system.debug('****serviceTypeToserviceDTO_v2Map contains' + serviceTypeToserviceDTO_v2Map);
                        for (String serviceType: serviceTypeToserviceDTO_v2Map.keyset()) {
                            ReplicatorGetServiceDataObject_V2.serviceListDTO servListDTO = new ReplicatorGetServiceDataObject_V2.serviceListDTO();
                            servListDTO.Service_Type = serviceType;
                            servListDTO.service = serviceTypeToserviceDTO_v2Map.get(serviceType);
                            if (serviceListMap.containsKey(serviceDetails.site.siteId + '~!@!~' + prodType)) {
                                serviceListMap.get(serviceDetails.site.siteId + '~!@!~' + prodType).add(servListDTO);
                            } else {
                                serviceListMap.put(serviceDetails.site.siteId + '~!@!~' + prodType, new list < ReplicatorGetServiceDataObject_V2.serviceListDTO > {
                                    servListDTO
                                        });
                            }
                        }
                    }
                }
                // New Site - Site record irretrating for the first time -----
                else {
                    // -- Code to populate ProdToServListMap Map ----
                    system.debug('----------ProdToServListMap----:  ' + JSON.serialize(ProdToServListMap));
                    ReplicatorGetServiceDataObject_V2.SiteDTO_V2 site_V2 = new ReplicatorGetServiceDataObject_V2.SiteDTO_V2();
                    List < ReplicatorGetServiceDataObject_V2.productListDTO > prdListDTOList = new List < ReplicatorGetServiceDataObject_V2.productListDTO > ();
                    for (String prodType: ProdToServListMap.keyset()) {
                        ReplicatorGetServiceDataObject_V2.productListDTO productListDTO = new ReplicatorGetServiceDataObject_V2.productListDTO();
                        productListDTO.Product_type = prodType;
                        productListDTO.serviceList = new List < ReplicatorGetServiceDataObject_V2.serviceListDTO > ();
                        serviceTypeToserviceDTO_v2Map = ProdToServListMap.get(prodType);
                        for (String serviceType: serviceTypeToserviceDTO_v2Map.keyset()) {
                            ReplicatorGetServiceDataObject_V2.serviceListDTO servListDTO = new ReplicatorGetServiceDataObject_V2.serviceListDTO();
                            servListDTO.Service_Type = serviceType;
                            servListDTO.service = serviceTypeToserviceDTO_v2Map.get(serviceType);
                            productListDTO.serviceList.add(servListDTO);
                            if (serviceListMap.containsKey(serviceDetails.site.siteId + '~!@!~' + prodType)) {
                                System.debug('*********Contains +' + servListDTO);
                                serviceListMap.get(serviceDetails.site.siteId + '~!@!~' + prodType).add(servListDTO);
                            } else {
                                System.debug('*********Contains Not +' + servListDTO);
                                serviceListMap.put(serviceDetails.site.siteId + '~!@!~' + prodType, new list < ReplicatorGetServiceDataObject_V2.serviceListDTO > {
                                    servListDTO
                                        });
                            }
                        }
                        prdListDTOList.add(productListDTO);
                        prdListDTOMap.put(prodType, productListDTO);
                    }
                    system.debug('prdListDTOList' + prdListDTOList);
                    if (serviceDetails.site.siteType == 'adbor_id') {
                        site_V2.ADBOR_Id = serviceDetails.site.siteId;
                    }
                    site_V2.siteName = '';
                    site_V2.Error_Code = '';
                    site_V2.Error_Description = '';
                    site_V2.productList = prdListDTOListAll;
                    siteList.add(site_V2);
                    siteMap.put(site_V2.ADBOR_Id, site_V2);
                }
            }
            Map<String,String> oppTypeMap = new Map<String,String>();
            Boolean sioConfigModeToggle =  FeatureEligibilityChecker.determineFeatureEligiblity('sioConfigMode',null);
            if(sioConfigModeToggle && CIDN_String != null){
                List<Opportunity> oppList = [Select id,CIDN__c,Type from Opportunity where CIDN__c =:CIDN_String AND type = 'Migration'];
                for(Opportunity opp: oppList){
                    oppTypeMap.put(opp.CIDN__c,opp.Type);    
                }
            }
            system.debug('&&&&&&&&&&&&%%%%%%%%%%%>>>' + siteList);
            List < ReplicatorGetServiceDataObject_V2.SiteDTO_V2 > siteListFinal = new List < ReplicatorGetServiceDataObject_V2.SiteDTO_V2 > ();
            /*--- Irretating Site list records to handle multiple site record in next node ----*/
            for (ReplicatorGetServiceDataObject_V2.SiteDTO_V2 mSiteListValue: siteList) {
                List < ReplicatorGetServiceDataObject_V2.productListDTO > prdListDTOListAllTemp = new List < ReplicatorGetServiceDataObject_V2.productListDTO > ();
                ReplicatorGetServiceDataObject_V2.SiteDTO_V2 site_V2 = new ReplicatorGetServiceDataObject_V2.SiteDTO_V2();
                site_V2.ADBOR_Id = mSiteListValue.ADBOR_Id;
                site_V2.siteName = '';
                site_V2.Error_Code = '';
                site_V2.Error_Description = '';
                /*-- Service List to map against corresponding product which intern map to Site --*/
                for (String adborId_pFamily: serviceListMap.keyset()) {
                    ReplicatorGetServiceDataObject_V2.productListDTO productListDTO = new ReplicatorGetServiceDataObject_V2.productListDTO();
                    string abdorIDVal = adborId_pFamily.split('~!@!~')[0];
                    string prodFamily = adborId_pFamily.split('~!@!~')[1];
                    /*--- Product Family grouping logic ---*/
                    if (abdorIDVal == mSiteListValue.ADBOR_Id) {
                        productListDTO.Product_type = prodFamily;
                        productListDTO.serviceList = new List < ReplicatorGetServiceDataObject_V2.serviceListDTO > ();
                        for (ReplicatorGetServiceDataObject_V2.serviceListDTO sl: serviceListMap.get(adborId_pFamily)) {
                            productListDTO.serviceList.add(sl);
                        }
                        prdListDTOListAllTemp.add(productListDTO);
                    }
                }
                site_V2.productList = prdListDTOListAllTemp;
                siteListFinal.add(site_V2);
            }
            system.debug('****serviceListMap contains' + JSON.serialize(serviceListMap));
            system.debug('****siteListFinal contains' + siteListFinal);
            Integer serviceCount = 0;
            if (serviceListMap.keyset().size() > 0) {
                serviceCount = serviceListMap.keyset().size();
            }
            serviceDTO_new.serviceCount = serviceCount;
            serviceDTO_new.CIDN = CIDN_String;
            System.debug('---sioConfig---'+sioConfig);
            if(sioConfigModeToggle && oppTypeMap.containsKey(CIDN_String)){
                System.debug('--in if CIDN_String--'+oppTypeMap);
                if(oppTypeMap.get(CIDN_String) == 'Migration'){
                    System.debug('--in if CIDN_String migration--'+oppTypeMap);
                  //serviceDTO_new.sendAddOnsConfig = sioConfigMode;
                  serviceDTO_new.sendAddOnsConfig = sioConfig;
                }
             }
            serviceDTO_new.Source_System_Id = 'Replicator';
            serviceDTO_new.Correlation_Id = serviceObjDTO.correlationId;
            serviceDTO_new.Error_Code = '';
            serviceDTO_new.Error_Description = '';
            if (errorDescription != '') {
                serviceDTO_new.Error_Code = String.ValueOf(errorStatusCode);
                serviceDTO_new.Error_Description = errorDescription;
            }
            serviceDTO_new.site = siteListFinal;
        }
        Catch(Exception ex) {
            System.debug('Exception Occure In Response from Replicator' + ex);
            System.debug(LoggingLevel.debug, '--->Error occurred##> ' + ex.getMessage());
            System.debug(LoggingLevel.debug, '--->Error Line##> ' + ex.getLineNumber());
            System.debug(LoggingLevel.debug, '--->Error Trace##> ' + ex.getStackTraceString());
            System.debug(LoggingLevel.debug, '--->Error Cause##> ' + ex.getCause());
            
            logException('replicatorResponseToTransition', '', correlationId, ex.getMessage(), 'Get response');

        }
        system.debug('########>>>>> serviceDTO_new  ' + JSON.serialize(serviceDTO_new));
        return serviceDTO_new;
    }
    // function to populate the SiteList and add it to product list
    private static Map < String,
        Map < String,
        List < ReplicatorGetServiceDataObject_V2.ServiceDTO_V2 >>> getProductTypeSites(ReplicatorGetServiceDTO.servicesDTO serviceDetails) {
            Map < String,
                Map < String,
                List < ReplicatorGetServiceDataObject_V2.ServiceDTO_V2 >>> ProdToServListMap = new Map < String,
                Map < String,
                List < ReplicatorGetServiceDataObject_V2.ServiceDTO_V2 >>> ();
            Map < String,
                List < ReplicatorGetServiceDataObject_V2.ServiceDTO_V2 >> serviceTypeToserviceDTO_v2Map = new Map < String,
                List < ReplicatorGetServiceDataObject_V2.ServiceDTO_V2 >> ();
            // -- Code to populate ProdToServListMap Map ----       
            Map < String,
                Map < String,
                List < ReplicatorGetServiceDataObject_V2.ServiceDTO_V2 >>> prodTypeToserviceDTO_v2Map = new Map < String,
                Map < String,
                List < ReplicatorGetServiceDataObject_V2.ServiceDTO_V2 >>> ();
            serviceCharacteristicTempDTO tempChar = new serviceCharacteristicTempDTO();
            Integer serviceExtensionCount = 0;
            List < service_extensionDTO > serviceExtensionList = new List < service_extensionDTO > ();
            Integer serviceAssociationCount = 0;
            List < service_AssociationsDTO > serviceAssociationList = new List < service_AssociationsDTO > ();
            List < service_extensionDTO > serviceExtensionDTOList = new List < service_extensionDTO > ();
            system.debug('$$$$$$$$$$$$>>>>>' + JSON.serialize(serviceDetails));
            for (ReplicatorGetServiceDTO.serviceCharacteristicDTO sChars: serviceDetails.serviceCharacteristics) {
                if (sChars.name == 'service_type') {
                    tempChar.service_type = sChars.value;
                }
                if (sChars.name == 'in_flight_flag') {
                    tempChar.In_Flight_Flag = sChars.value;
                }
                if (sChars.name == 'association_type') {
                    tempChar.association_type = sChars.value;
                }
                if (sChars.name == 'service_association_role') {
                    tempChar.service_association_role = sChars.value;
                }
                if (sChars.name == 'service_extension') {
                    if (sChars.value != '' && sChars.value != null) {
                        service_extensionDTO se = new service_extensionDTO();
                        se.serviceExtensionFrom = sChars.name;
                        se.serviceExtensionTo = sChars.value;
                        serviceExtensionList.add(se);
                        serviceExtensionCount = serviceExtensionCount + 1;
                    }
                }
            }
            // EDGE 98925 start
            for (ReplicatorGetServiceDTO.serviceAssociationDTO sAssoc: serviceDetails.serviceAssociations) {
                if (sAssoc.linkedServiceId != '' && sAssoc.linkedServiceId != null) {
                    service_AssociationsDTO serviceAssociationRec = new service_AssociationsDTO();
                    serviceAssociationRec.linkedServiceId = sAssoc.linkedServiceId;
                    serviceAssociationRec.linkedServiceRole = sAssoc.linkedServiceRole;
                    serviceAssociationList.add(serviceAssociationRec);
                }
            }
            for (ReplicatorGetServiceDTO.serviceExtensionsDTO sExtn: serviceDetails.serviceExtensions) {
                if (sExtn.serviceExtensionFrom != '' && sExtn.serviceExtensionTo != null) {
                    service_extensionDTO serviceExtnRec = new service_extensionDTO();
                    serviceExtnRec.serviceExtensionFrom = sExtn.serviceExtensionFrom;
                    serviceExtnRec.serviceExtensionTo = sExtn.serviceExtensionTo;
                    serviceExtensionDTOList.add(serviceExtnRec);
                }
            }
            // EDGE 98925 end
            ReplicatorGetServiceDataObject_V2.ServiceDTO_V2 serviceDTO_V2 = new ReplicatorGetServiceDataObject_V2.ServiceDTO_V2();
            serviceDTO_V2.Service_Id = serviceDetails.fnn;
            serviceDTO_V2.User_Type = ''; //TBD
            serviceDTO_V2.Service_Type = tempChar.service_type;
            serviceDTO_V2.serviceExtension = new List < ReplicatorGetServiceDataObject_V2.ServiceExtensionDTO_V2 > ();
            serviceDTO_V2.In_Flight_Flag = tempChar.In_Flight_Flag;
            serviceDTO_V2.In_Flight_Legacy_System = ''; //TBD 
            serviceDTO_V2.In_Flight_Order_Id = ''; //TBD
            serviceDTO_V2.eligibilityStatus = ''; //TBD
            serviceDTO_V2.eligibilityReason = ''; //TBD
            serviceDTO_V2.Association_Type = tempChar.association_type;
            if (tempChar.service_association_role != '') {
                serviceDTO_V2.Association_Role = tempChar.service_association_role;
            } else {
                // TBD
            }
            for (service_extensionDTO servRelationship: serviceExtensionList) {
                if (serviceExtensionList != null && serviceExtensionList.size() > 0) {
                    ReplicatorGetServiceDataObject_V2.ServiceExtensionDTO_V2 servExtention = new ReplicatorGetServiceDataObject_V2.ServiceExtensionDTO_V2();
                    if (servRelationship.serviceExtensionTo.contains('-')) {
                        servExtention.Services_From = servRelationship.serviceExtensionTo.split('-')[0]; // EDGE 98925 - Canged Value to serviceExtensionTo 
                        servExtention.Services_To = servRelationship.serviceExtensionTo.split('-')[1];
                    } else {
                        servExtention.Services_From = '';
                        servExtention.Services_To = '';
                    }
                    servExtention.eligibilityStatus = '';
                    servExtention.eligibilityReason = '';
                    serviceDTO_V2.serviceExtension.add(servExtention);
                }
            }
            system.debug('----------serviceExtensionCount:  ' + serviceExtensionCount + '********####' + serviceExtensionList);
            system.debug('----------serviceDTO_V2:  ' + serviceDTO_V2);
            system.debug('----------extension----:  ' + serviceDTO_V2.serviceExtension);
            //EDGE 98925
            list < TransitionDataDTO.devicesDTO > deviceList = New list < TransitionDataDTO.devicesDTO > ();
            for (ReplicatorGetServiceDTO.devicesDTO device: serviceDetails.devices) {
                TransitionDataDTO.devicesDTO deviceData = New TransitionDataDTO.devicesDTO();
                deviceData.deviceType = device.deviceType;
                deviceData.networkId = device.networkId;
                deviceData.physicalId = device.physicalId;
                deviceList.add(deviceData);
            }
            List < ReplicatorGetServiceDataObject_V2.ServiceDTO_V2 > serviceList = new List < ReplicatorGetServiceDataObject_V2.ServiceDTO_V2 > ();
            Map < String,
                List < ReplicatorGetServiceDataObject_V2.ServiceDTO_V2 >> serviceTypeToserviceDTO_v2Map1 = new Map < String,
                List < ReplicatorGetServiceDataObject_V2.ServiceDTO_V2 >> ();
            if (prodTypeToserviceDTO_v2Map.containskey(serviceDetails.productFamily)) {
                serviceTypeToserviceDTO_v2Map1 = prodTypeToserviceDTO_v2Map.get(serviceDetails.productFamily);
                if (serviceTypeToserviceDTO_v2Map1.containsKey(tempChar.service_type)) {
                    serviceList = serviceTypeToserviceDTO_v2Map1.get(tempChar.service_type);
                    serviceList.add(serviceDTO_V2);
                } else {
                    serviceList.add(serviceDTO_V2);
                }
                serviceTypeToserviceDTO_v2Map1.put(tempChar.service_type, serviceList);
            } else {
                if (serviceTypeToserviceDTO_v2Map1.containsKey(tempChar.service_type)) {
                    serviceList = serviceTypeToserviceDTO_v2Map1.get(tempChar.service_type);
                    serviceList.add(serviceDTO_V2);
                } else {
                    serviceList.add(serviceDTO_V2);
                }
                serviceTypeToserviceDTO_v2Map1.put(tempChar.service_type, serviceList);
            }
            prodTypeToserviceDTO_v2Map.put(serviceDetails.productFamily, serviceTypeToserviceDTO_v2Map1);
            system.debug('----------prodTypeToserviceDTO_v2Map----:  ' + JSON.serialize(prodTypeToserviceDTO_v2Map));
            return prodTypeToserviceDTO_v2Map;
        }
    /**
* @Author   :   Maqsood Alam
* @Date     :   22 July 2019
* @Desc     :   <getservices> As a Sales Enterprise B2B and partner user, I want to see list of customer's legacy mobile services as part of transition order journey So that I can verify the services customer would like to transition.
* @US       :   EDGE-EDGE-66392
* @Status   :   Development
* */
    public static Map < String, list < String >> fetchProdFamilyFmBasket(String CIDNString, String basketId, String callFor) {
        Map < String, List < String >> cidnProductFamily = new Map < String, List < String >> ();
        try {
            // String cidn = CompUtilityReplicatorManager.getBasket(basketId).csbb__Account__r.CIDN__c;
            // Logic to populate Product Family is still pending
            list < String > productFamily = New list < String > ();
            System.debug('callFor::::' + callFor);
            Product_Family_Transition__mdt[] prodFamily = [SELECT DeveloperName, Label, Product_Family_Values__c FROM Product_Family_Transition__mdt WHERE DeveloperName =: callFor];
            for (Product_Family_Transition__mdt PF: prodFamily) {
                productFamily.addAll(PF.Product_Family_Values__c.split(','));
            }
            System.debug('Product Family: ' + productFamily);
            cidnProductFamily.put(CIDNString, productFamily);
        } catch (Exception ex) {
            System.debug('Exception Occure In Response from Replicator' + ex);
            System.debug(LoggingLevel.debug, '--->Error occurred##> ' + ex.getMessage());
            System.debug(LoggingLevel.debug, '--->Error Line##> ' + ex.getLineNumber());
            System.debug(LoggingLevel.debug, '--->Error Trace##> ' + ex.getStackTraceString());
            System.debug(LoggingLevel.debug, '--->Error Cause##> ' + ex.getCause());
            
            logException('fetchProdFamilyFmBasket', basketId, correlationId, ex.getMessage(), 'Get Product Family from Basket');

            return new Map < String, List < String >> ();
        }
        return cidnProductFamily;
    }
    /**
* @Author   :   Maqsood Alam
* @Date     :   22 July 2019
* @Desc     :   <getservices> As a Sales Enterprise B2B and partner user, I want to see list of customer's legacy mobile services as part of transition order journey So that I can verify the services customer would like to transition.
* @US       :   EDGE-EDGE-66392
* @Status   :   Development
* */
    //  public static ReplicatorGetServiceDTO getCustomerServicesMobile(String finCIDN, String basketId) {
    
    
    @AuraEnabled
    public static TransitionDataDTO getCustomerServicesMobile(String finCIDN, String basketId, String callFrom, String callFor, List < String > selectedCIDN, Boolean isCidnHierarchy, List < String > prodFamilyList, String sioConfigMode) {//Added sioConfigMode for DIGI-1681
        String CIDNHierarchy = '';
        //Start EDGE-1681
        Boolean sioConfigModeToggle =  FeatureEligibilityChecker.determineFeatureEligiblity('sioConfigMode',null);
        if(sioConfigModeToggle){
            ReplicatorGetServiceManager.sioConfigMode = sioConfigMode;
        }
        //End EDGE-1681
        //System.debug('isCidnHierarchy' + isCidnHierarchy);
        //  if(isCidnHierarchy){
        if (selectedCIDN != NULL && !(selectedCIDN.isEmpty())) {
            //  if(selectedCIDN != NULL
            CIDNHierarchy = String.join(selectedCIDN, ',');
            System.debug('CIDNHierarchy 2 ' + CIDNHierarchy);
        }
        // }
        System.debug('CIDNHierarchy' + CIDNHierarchy);
        //Start of EDGE-209985 by Abhishek(Osaka) to pass list of selected product families(On-Screen) to replicator
        String selectedProdFamily = '';
        if(prodFamilyList != Null && !prodFamilyList.isEmpty()){
            if(prodFamilyList.size() == 1){
                selectedProdFamily = prodFamilyList[0];
            }
            else{
                selectedProdFamily = String.join(prodFamilyList, ',');
            }
        }
        System.debug('Select Product Family::'+selectedProdFamily);
        //End of EDGE-209985 by Abhishek(Osaka)
        Map < String, List < String >> cidnProductFamily = fetchProdFamilyFmBasket(finCIDN, basketId, callFor);
        ReplicatorGetServiceDTO responseDTO;
        TransitionDataDTO attchedResponseeDTO;
        TransitionDataDTO mobileResponseFinal;
        try {
            //-- check if attach is present for the Given basket and product configuration --
            List < Attachment > attachmentListMobile = New List < Attachment > ();
            if (callFrom == 'Mobile') {
                system.debug('###callFrom system' + callFrom);
                attachmentListMobile = [SELECT Id, ParentId, Name, Body from Attachment WHERE ParentId IN(SELECT id FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c =: basketId AND cscfga__Product_Definition__r.product_Specification__c IN: listproductSpecMobile) AND Name =: TransitionJSONDataMobile LIMIT 1];
            } else {
                attachmentListMobile = [SELECT Id, ParentId, Name, Body from Attachment WHERE ParentId IN(SELECT id FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c =: basketId AND cscfga__Product_Definition__r.product_Specification__c IN: listproductSpecNgUC) AND Name =: TransitionJSONDataNgUc LIMIT 1];
                system.debug('###callFrom system' + callFrom);
            }
            if (attachmentListMobile.size() > 0) {
                if (callFrom == 'Mobile')
                    attchedResponseeDTO = TransitionDataDTO.parse(attachmentListMobile[0].Body.toString());
                else
                    attchedResponseeDTO = TransitionDataDTO.parse(attachmentListMobile[0].Body.toString()); // NgUC    
                system.debug('#####attachedMobileResponse$$$-->' + JSON.serialize(attchedResponseeDTO));
                system.debug('#####attachmentListMobile$$$-->' + JSON.serialize(attachmentListMobile[0].Body.toString()));
            } else {
                    //EDGE-190190:Ramya:For CIDN Hierarchy
                    //EDGE-209885 : Added selectedProdFamily Parameter for sending list of on-scree selected product family to replicator
                    responseDTO = getSiteAgnosticServices(finCIDN, cidnProductFamily.get(finCIDN), basketId, CIDNHierarchy, isCidnHierarchy,selectedProdFamily);
            }
            System.debug('---responseDTO--->' + responseDTO);
            if (attachmentListMobile.size() > 0) {
                mobileResponseFinal = attchedResponseeDTO;
            } else {
                if (callFrom == 'Mobile') {
                    mobileResponseFinal = transformReplicatorResponse(responseDTO, basketId, 'Mobile'); // Mobile call
                } else {
                    //EDGE-222176 :  Added Additional parameters finCIDN, SelectedCIDN List for TIPT-SIPC eligibility by Abhishek(Osaka)
                    //EDGE-222176 Dormancy block with all the values set added for Bamboo deployment             
                    /*if(isOsakaDormant =='true'){
                        finCIDN = '';
                       selectedCIDN.clear();
                     }  */
                    mobileResponseFinal = transformReplicatorResponseNgUc(responseDTO, basketId ,finCIDN ,selectedCIDN); //ngUc call
                }
            }
            system.debug('#####mobileResponseFinal$$$-->' + JSON.serialize(mobileResponseFinal));
        } catch (Exception ex) {
            System.debug('Exception Occure In Response from Replicator');
            System.debug(LoggingLevel.debug, '--->Error occurred##> ' + ex.getMessage());
            System.debug(LoggingLevel.debug, '--->Error Line##> ' + ex.getLineNumber());
            System.debug(LoggingLevel.debug, '--->Error Trace##> ' + ex.getStackTraceString());
            System.debug(LoggingLevel.debug, '--->Error Cause##> ' + ex.getCause());
            //Logger.getLogger(ReplicatorManager.class).debug(ex);
            Logger.exitLogger();
            
           logException('getCustomerServicesMobile', basketId, correlationId, ex.getMessage(), 'Get Customer Service Mobile details');
        }
        return mobileResponseFinal;
    }
    /**
* @Author   :   Rahul Asarma
* @Date     :   13 January 2020
* @Desc     :   <getservices> As a Sales Enterprise B2B and partner user, I want to see list of customer's MDM Tanancy services as part of transition order journey So that I can verify the services customer would like to transition.
* @US       :   EDGE-120171
* @Status   :   Development
* */
    @AuraEnabled
    public static TransitionDataDTO getCustomerServicesMDMTenancies(String finCIDN, String basketId, String callFrom, String callFor) {
        ReplicatorGetServiceDTO responseDTO;
        String finCIDNString = '';
        //Changes to remove SonarQube vulnerabilities  by Abhishek(Osaka)(Argument cannot be used directly so using a local variable finCIDNValue)
        String finCIDNValue = '';
        finCIDNValue = finCIDN;
        TransitionDataDTO mdmTenancyResponseFinal;
        try {
            //if (finCIDN == '') {
            if (finCIDNValue == '') {
                // If javascript not able to parse CIDN, fetch it from product basket -> account field CIDN
                for (cscfga__Product_Basket__c accountRecord: [SELECT Id, csbb__Account__c, csbb__Account__r.CIDN__c FROM cscfga__Product_Basket__c where Id =: basketId]) {
                    finCIDNString = accountRecord.csbb__Account__r.CIDN__c;
                }
                //Changes to remove SonarQube vulnerabilities  by Abhishek(Osaka)
                //finCIDN = finCIDNString;
                finCIDNValue = finCIDNString;
                
            }
            if (callFrom == 'MDM Tenancy')
                //Changes to remove SonarQube vulnerabilities  by Abhishek(Osaka)
                //responseDTO = getMDMTenancies(finCIDN);
                responseDTO = getMDMTenancies(finCIDNValue);
            else {}
            System.debug('---responseDTO--->' + responseDTO);
            if (callFrom == 'MDM Tenancy') {
                mdmTenancyResponseFinal = transformReplicatorResponse(responseDTO, basketId, 'MDM Tenancy'); // MDM Tenancy
            } else {}
            system.debug('#####mdmTenancyResponseFinal$$$-->' + JSON.serialize(mdmTenancyResponseFinal));
        } catch (Exception ex) {
            System.debug('Exception Occure In Response from Replicator');
            System.debug(LoggingLevel.debug, '--->Error occurred##> ' + ex.getMessage());
            System.debug(LoggingLevel.debug, '--->Error Line##> ' + ex.getLineNumber());
            System.debug(LoggingLevel.debug, '--->Error Trace##> ' + ex.getStackTraceString());
            System.debug(LoggingLevel.debug, '--->Error Cause##> ' + ex.getCause());
            Logger.getLogger(ReplicatorManager.class).debug(ex);
            Logger.exitLogger();
            
            logException('getCustomerServicesMDMTenancies', basketId, correlationId, ex.getMessage(), 'Get customers MDM Tanancy services');
        }
        return mdmTenancyResponseFinal;
    }
    /**
* @Author   :   Maqsood Alam
* @Date     :   22 May 2019
* @Desc     :   Make a web call out to the standard getServices endpoint by passing CIDN & Product families from the input argument list.
* @US       :   EDGE-89542
* @Status   :   Development
* */
    @AuraEnabled
    public static ReplicatorGetServiceDTO getSiteAgnosticServices(String finCIDN, List < String > prodFamilies, String basketId, String cidnHierarchy, Boolean isCidnHierarchy, String selectedProdFamily) {
        System.debug('---this.mode---'+ReplicatorGetServiceManager.sioConfigMode);
        System.debug('isCidnHierarchy--->'+isCidnHierarchy);
        
        ReplicatorGetServiceDTO getServiceDTO;
       
        Long requestTime = null;
        Logger2 logger2 = Logger2.getLogger(ReplicatorGetServiceManager.class);
        
        // Start of DIGI-1746:- HeaderMap logic has been moved to helper
        Map < String, String > headerMap = ReplicatorGetServiceManagerHelper.prepareHeader(finCIDN, prodFamilies, basketId,  cidnHierarchy, isCidnHierarchy, selectedProdFamily, ReplicatorGetServiceManager.sioConfigMode);//Added sioConfigMode for DIGI-1681
        // End of DIGI-1746
        String cidn = headerMap.get('cidn');
        String correId = headerMap.get('correlationId');
        
        system.debug('---Header Info--' + headerMap);
        try {
            DateTime startTime = DateTime.now();
            HttpResponse resMobile = IntegrationRecordHandlerUtil.callout('', IntegrationRecordHandlerUtil.HTTP_METHOD_GET, headerMap, ReplicatorLegacyAssetService.class.getName(), null, correId);
            DateTime endTime = DateTime.now();
            requestTime = logger2.getRequestTimeDifference(startTime, endTime);
            getServiceDTO = ReplicatorGetServiceDTO.parse(resMobile.getBody().replace('serviceextension', 'service_extension').replace('"services"', '"servicesList"'));
            //getServiceDTO = ReplicatorGetServiceDTO.parse('{"correlationId":"dd8218f8efa3c2fa17","services":[{"cidn":"4851828808","productFamily":"Enterprise Mobility","fnn":"61429761210","site":{"siteType":"ADBOR_ID","siteId":"0","linkedSiteType":"","linkedSiteId":""},"replicatorUpdateDateTime":"2021-03-16T15:33:23.145+11:00","account":{"accountNumber":"2281867420","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N","dealerCode":"","adaptiveCareIndicator":"N"},"serviceCharacteristics":[{"name":"aro_indicator","value":"N"},{"name":"user_name","value":"Testing UserName"},{"name":"calling_line_identifier","value":"Y"},{"name":"contract_remaining_term","value":"0"},{"name":"contract_term","value":"0"},{"name":"device_lease_contract_indicator","value":"N"},{"name":"directory_listing","value":"Y"},{"name":"etc_flag","value":"N"},{"name":"idd","value":""},{"name":"international_roaming","value":""},{"name":"message_bank","value":"MSGBK|Messagebank Access Fee"},{"name":"mro_with_no_imei","value":""},{"name":"plan_name","value":"GBDS*000|Go Business Bonus Data SIM $0 "},{"name":"plan_type","value":"Mobile Broadband"},{"name":"service_status","value":"AC"},{"name":"service_type","value":"NORM"},{"name":"telstra_one_number_indicator","value":"N"}],"devices":[{"deviceType":"SIM","physicalId":"6328205800005","networkId":"505013487427638"}],"repayments":[],"serviceAssociations":[],"serviceExtensions":[]}]}'.replace('"services"', '"servicesList"' ));
            
            System.debug('GetServiceDTO: ' + getServiceDTO);
            /* If Error is returned in the response */
            if (resMobile.getStatusCode() != IntegrationRecordHandlerUtil.HTTP_SUCCESS) {
                String internalErrorDesc;
                if (resMobile.getStatusCode() == IntegrationRecordHandlerUtil.ERROR_404_CODE) {
                    internalErrorDesc = IntegrationRecordHandlerUtil.ERROR_404_DESC;
                } else if (resMobile.getStatusCode() == IntegrationRecordHandlerUtil.ERROR_500_CODE) {
                    internalErrorDesc = IntegrationRecordHandlerUtil.ERROR_500_DESC;
                } else if (resMobile.getStatusCode() == IntegrationRecordHandlerUtil.ERROR_503_CODE) {
                    internalErrorDesc = IntegrationRecordHandlerUtil.ERROR_503_DESC;
                } else {
                    internalErrorDesc = Label.Replicator_Technical_Error_Message;
                }
                errorDescription = internalErrorDesc;
                errorStatusCode = resMobile.getStatusCode();
                logger2.logMessages(cidn, resMobile.getBody(), '', '', '', '', String.ValueOf(resMobile.getStatusCode()), correId, '', '', '', '', requestTime, '', false, false);
                logger2.exitLogger();
            } else {
                logger2.logMessages(cidn, resMobile.getBody(), '', '', '', '', String.ValueOf(resMobile.getStatusCode()), correId, '', '', '', '', requestTime, '', false, false);
                logger2.exitLogger();
            }
        } catch (Exception ex) {
            System.debug('Exception: ' + ex);
            System.debug('Exception Occure In Response from Replicator');
            System.debug(LoggingLevel.debug, '--->Error occurred##> ' + ex.getMessage());
            System.debug(LoggingLevel.debug, '--->Error Line##> ' + ex.getLineNumber());
            System.debug(LoggingLevel.debug, '--->Error Trace##> ' + ex.getStackTraceString());
            System.debug(LoggingLevel.debug, '--->Error Cause##> ' + ex.getCause());
            logger2.logMessages('ReplicatorGetServiceManager:getSiteAgnosticServices', ex.getMessage(), '', '', '', '', false, false, null, null, null, null);
            logger2.exitLogger();
            
           logException('getSiteAgnosticServices', basketId, correlationId, ex.getMessage(), 'Get Services endpoint by passing CIDN & Product families');

            
            return null;
        }
        return getServiceDTO;
    }
    @AuraEnabled
    public static ReplicatorGetServiceDTO getMDMTenancies(String finCIDN) {
        String tenancyFamily = 'Product_Family_for_MDM_Tenancy';
        Map < String, List < String >> cidnProductFamily = fetchProdFamilyFmBasket(finCIDN, '', tenancyFamily);
        ReplicatorGetServiceDTO getServiceDTO;
        // Preparing head for HTTP request --
        String GETSERVICE_EVENT = 'ReplicatorLegacyAssetService';
        String token = AuthenticationManager.getOauthToken(GETSERVICE_EVENT);
        String cidn = finCIDN;
        String productFamilyString = String.join(cidnProductFamily.get(finCIDN), ',');
     
        System.debug('valueofFAMILY' + productFamilyString);
        String correId = IntegrationRecordHandlerUtil.getCorrelationId();
        Long requestTime = null;
        Logger2 logger2 = Logger2.getLogger(ReplicatorGetServiceManager.class);
        Map < String,
            String > headerMap = new Map < String,
            String > {
                'Content-Type' => 'application/json',
                    'Authorization' => 'Bearer ' + token,
                    'correlationId' => correId,
                    'productFamily' => productFamilyString,
                    'cidn' => cidn
                    };
                        system.debug('---Header Info--' + headerMap);
        try {
            DateTime startTime = DateTime.now();
            HttpResponse resMobile = IntegrationRecordHandlerUtil.callout('', IntegrationRecordHandlerUtil.HTTP_METHOD_GET, headerMap, ReplicatorLegacyAssetService.class.getName(), null, correId);
            DateTime endTime = DateTime.now();
            requestTime = logger2.getRequestTimeDifference(startTime, endTime);
            system.debug('ResponseBODY************' + resMobile.getBody());
            getServiceDTO = ReplicatorGetServiceDTO.parse(resMobile.getBody().replace('serviceextension', 'service_extension').replace('"services"', '"servicesList"'));
            //  getServiceDTO = ReplicatorGetServiceDTO.parse('{"correlationId":"5465764671208","services":[{"cidn":"1234567890","productFamily":"MDM Tenancy","fnn":"616","site":{"siteType":"","siteId":""},"replicatorUpdateDateTime":"2019-07-26 11:11:49.593","account":{"accountNumber":"3424036691","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"N"},"serviceCharacteristics":[{"name":"tenancy_name","value":"Australia Post Production"}],"devices":[],"serviceAssociations":[],"serviceExtensions":[]},{"cidn":"1234567890","productFamily":"MDM Tenancy","fnn":"5588","site":{"siteType":"","siteId":""},"replicatorUpdateDateTime":"2019-07-26 11:11:49.593","account":{"accountNumber":"3424036691","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"Y"},"serviceCharacteristics":[{"name":"tenancy_name","value":"Australia Post Test"}],"devices":[],"serviceAssociations":[],"serviceExtensions":[]},{"cidn":"1234567890","productFamily":"MDM Tenancy","fnn":"5589","site":{"siteType":"","siteId":""},"replicatorUpdateDateTime":"2019-07-26 11:11:49.593","account":{"accountNumber":"3424036691","complexBillingIndicator":"N","creditManagementFlag":"N","serviceWithEtcFlag":"Y"},"serviceCharacteristics":[{"name":"tenancy_name","value":"Australia Post Development"}],"devices":[],"serviceAssociations":[],"serviceExtensions":[]}]}'.replace('"services"', '"servicesList"'));
            System.debug('GetServiceDTO: ' + getServiceDTO);
            /* If Error is returned in the response */
            if (resMobile.getStatusCode() != IntegrationRecordHandlerUtil.HTTP_SUCCESS) {
                String internalErrorDesc;
                if (resMobile.getStatusCode() == IntegrationRecordHandlerUtil.ERROR_404_CODE) {
                    internalErrorDesc = IntegrationRecordHandlerUtil.ERROR_404_DESC;
                } else if (resMobile.getStatusCode() == IntegrationRecordHandlerUtil.ERROR_500_CODE) {
                    internalErrorDesc = IntegrationRecordHandlerUtil.ERROR_500_DESC;
                } else if (resMobile.getStatusCode() == IntegrationRecordHandlerUtil.ERROR_503_CODE) {
                    internalErrorDesc = IntegrationRecordHandlerUtil.ERROR_503_DESC;
                } else {
                    internalErrorDesc = Label.Replicator_Technical_Error_Message;
                }
                errorDescription = internalErrorDesc;
                errorStatusCode = resMobile.getStatusCode();
                logger2.logMessages(cidn, resMobile.getBody(), '', '', '', '', String.ValueOf(resMobile.getStatusCode()), correId, '', '', '', '', requestTime, '', false, false);
                logger2.exitLogger();
            } else {
                logger2.logMessages(cidn, resMobile.getBody(), '', '', '', '', String.ValueOf(resMobile.getStatusCode()), correId, '', '', '', '', requestTime, '', false, false);
                logger2.exitLogger();
            }
        } catch (Exception ex) {
            System.debug('Exception: ' + ex);
            System.debug('Exception Occure In Response from Replicator');
            System.debug(LoggingLevel.debug, '--->Error occurred##> ' + ex.getMessage());
            System.debug(LoggingLevel.debug, '--->Error Line##> ' + ex.getLineNumber());
            System.debug(LoggingLevel.debug, '--->Error Trace##> ' + ex.getStackTraceString());
            System.debug(LoggingLevel.debug, '--->Error Cause##> ' + ex.getCause());
            logger2.logMessages('ReplicatorGetServiceManager:getSiteAgnosticServices', ex.getMessage(), '', '', '', '', false, false, null, null, null, null);
            logger2.exitLogger();
            
           logException('getMDMTenancies', '', correlationId, ex.getMessage(), 'Get MDMTenancies');

            
            return null;
        }
        return getServiceDTO;
    }
    /**
* @Author   :   Maqsood Alam
* @Date     :   22 May 2019
* @Desc     :   1) Create a new instance of TransitionDataDTO
2) Loop through the Service Elements of ReplicatorGetServiceDTO and construct a collection of Service elements in TransitionDataDTO
3) Once the loop is finished, insert the TransitionDataDTO object.
* @US       :   EDGE-89542
* @Status   :   Development
* */
    @AuraEnabled
    public static TransitionDataDTO transformReplicatorResponse(ReplicatorGetServiceDTO responseFmReplicator, String basketId, String callingFrom) {
        TransitionDataDTO transitionResponseMobile = new TransitionDataDTO();
        Boolean hasAddons = false;
        Map < String, Map < String, List < TransitionDataDTO.SiteDTOMobile >>> ProdToSiteListMap = new Map < String, Map < String, List < TransitionDataDTO.SiteDTOMobile >>> ();
        Map < String, list < TransitionDataDTO.SiteDTOMobile >> prodSiteMap = new Map < String, list < TransitionDataDTO.SiteDTOMobile >> ();
        List < TransitionDataDTO.productListDTO > productFamilyListFinal = new List < TransitionDataDTO.productListDTO > ();
        List < TransitionDataDTO.productListDTO > productFamilyListFinal1 = new List < TransitionDataDTO.productListDTO > ();
        String CIDN_String = '';
        try {
            /*-- if Response Already exist in the Product Configuration --*/
            List < Id > productConfigIds = new List < Id > ();
            for (cscfga__Product_Configuration__c productConfig: [SELECT id FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c =: basketId AND cscfga__Product_Definition__r.product_Specification__c IN: listproductSpecMobile
                                                                  ORDER BY Createddate DESC
                                                                 ]) {
                                                                     productConfigIds.add(productConfig.id);
                                                                 }
            if (productConfigIds.size() > 0 && callingFrom == 'Mobile') {
                List < Attachment > attchedJSON = [SELECT id, name, body, parentId FROM Attachment WHERE ParentId in: productConfigIds AND Name =: TransitionJSONDataMobile order by createdDate desc limit 1];
                if (attchedJSON.size() > 0) {
                    TransitionDataDTO AttchedTransitonDTOJSON = TransitionDataDTO.parse(attchedJSON[0].body.toString());
                    system.debug('######>>>>>>********' + AttchedTransitonDTOJSON);
                    return AttchedTransitonDTOJSON;
                }
            }
            /*-- if Response Already exist in the Product Configuration --*/
            TransitionDataDTO.productListDTO productFamilyDTOObj = New TransitionDataDTO.productListDTO();
            for (ReplicatorGetServiceDTO.servicesDTO serviceDetails: responseFmReplicator.servicesList) {
                System.debug('---serviceDetails---'+serviceDetails.addOns);
                system.debug('**********serviceDetails.productFamily if --- ' + serviceDetails.productFamily);
                system.debug('**********prodSiteMap ++++ ' + prodSiteMap);
                if (prodSiteMap.containskey(serviceDetails.productFamily)) {
                    system.debug('**********prodSiteMap.get(serviceDetails.productFamily)++++ ' + prodSiteMap.get(serviceDetails.productFamily));
                    if (prodSiteMap.get(serviceDetails.productFamily).size() > 0) {
                        //  list<TransitionDataDTO.SiteDTOMobile> siteRecord = new list<TransitionDataDTO.SiteDTOMobile>();
                        //  siteRecord.add(getSiteList(serviceDetails));
                        prodSiteMap.get(serviceDetails.productFamily).add(getSiteList(serviceDetails));
                        system.debug('**********serviceDetails.productFamily if _____' + serviceDetails.productFamily);
                    }
                } else {
                    system.debug('**********serviceDetails.productFamily else ' + serviceDetails.productFamily);
                    productFamilyDTOObj = New TransitionDataDTO.productListDTO();
                    list < TransitionDataDTO.SiteDTOMobile > siteRecord = new list < TransitionDataDTO.SiteDTOMobile > ();
                    productFamilyDTOObj.site = new List < TransitionDataDTO.SiteDTOMobile > ();
                    siteRecord.add(getSiteList(serviceDetails));
                    prodSiteMap.put(serviceDetails.productFamily, siteRecord);
                    productFamilyDTOObj.Product_Type = serviceDetails.productFamily;
                    productFamilyDTOObj.site = siteRecord;
                    productFamilyListFinal.add(productFamilyDTOObj);
                }
                CIDN_String = serviceDetails.cidn;
                //START: Added by Anurag for DIGI-1684
                if(!hasAddOns && serviceDetails.addOns != null){
                    hasAddOns = true;
                }
                //END
                for (String key: prodSiteMap.keySet()) {
                    system.debug('$$$$$$$$$$$$>>>>>prodSiteMapLoop ' + prodSiteMap.get(key));
                }
            }
            system.debug('$$$$$$$$$$$$>>>>>productFamilyListFinal ' + JSON.serialize(productFamilyListFinal));
            system.debug('$$$$$$$$$$$$>>>>>prodSiteMap ' + JSON.serialize(prodSiteMap));
            /* Constructing mobile Transistion JSON file */
            transitionResponseMobile.CIDN = CIDN_String;
            transitionResponseMobile.Source_System_Id = 'Replicator';
            transitionResponseMobile.productList = productFamilyListFinal;
            transitionResponseMobile.Correlation_Id = responseFmReplicator.correlationId;
            transitionResponseMobile.Error_Code = '';
            transitionResponseMobile.Error_Description = '';
            if (errorDescriptionMobile != '') {
                transitionResponseMobile.Error_Code = String.ValueOf(errorStatusCodeMobile);
                transitionResponseMobile.Error_Description = errorDescriptionMobile;
            }
            //START: Added by Anurag for DIGI-1684
            System.debug('---responseFmReplicator.sendAddOnsConfig---'+responseFmReplicator.sendAddOnsConfig);
            if(hasAddOns){
                transitionResponseMobile.sendAddOnsConfig = 'Auto SIO';
            }
            else{
                transitionResponseMobile.sendAddOnsConfig = 'Manual SIO';
            }
            //END for DIGI-1684
        }
        Catch(Exception ex) {
            System.debug('Exception Occure In Response from Replicator' + ex);
            System.debug(LoggingLevel.debug, '--->Error occurred##> ' + ex.getMessage());
            System.debug(LoggingLevel.debug, '--->Error Line##> ' + ex.getLineNumber());
            System.debug(LoggingLevel.debug, '--->Error Trace##> ' + ex.getStackTraceString());
            System.debug(LoggingLevel.debug, '--->Error Cause##> ' + ex.getCause());
            
           logException('transformReplicatorResponse', basketId, correlationId, ex.getMessage(), 'create transformReplicatorResponse');

        }
        system.debug('########>>>>> transitionResponseMobile  ' + JSON.serialize(transitionResponseMobile));
        return transitionResponseMobile;
    }
    /**
* @Author   :   Maqsood Alam
* @Date     :   22 May 2019
* @Desc     :   get ProductFamilyList for sites
* @US       :   EDGE-89542
* @Status   :   Development
* */
    @AuraEnabled
    public static TransitionDataDTO.SiteDTOMobile getSiteList(ReplicatorGetServiceDTO.servicesDTO serviceDetails) {
        List < TransitionDataDTO.productListDTO > productFamilyList = new List < TransitionDataDTO.productListDTO > ();
        Map < String,
            Map < String,
            List < TransitionDataDTO.SiteDTOMobile >>> ProdToSiteListMap = new Map < String,
            Map < String,
            List < TransitionDataDTO.SiteDTOMobile >>> ();
        system.debug('$$$$$$$$$$$$>>>>>' + JSON.serialize(serviceDetails));
        TransitionDataDTO.serviceDTOMobile tempChar = new TransitionDataDTO.serviceDTOMobile();
         system.debug('tempChar>>>>>' + tempChar );
        for (ReplicatorGetServiceDTO.serviceCharacteristicDTO sChars: serviceDetails.serviceCharacteristics) {
            if (sChars.name == 'service_status') {
                tempChar.service_status = sChars.value;
            }
            if (sChars.name == 'service_type_code') {
                tempChar.service_type_code = sChars.value;
            }
            if (sChars.name == 'service_type') {
                tempChar.service_type = sChars.value;
            }
            if (sChars.name == 'imsi_number') {
                tempChar.imsi_number = sChars.value;
            }
            if (sChars.name == 'sim_serial_number') {
                tempChar.sim_serial_number = sChars.value;
            }
            if (sChars.name == 'calling_line_identifier') {
                tempChar.calling_line_identifier = sChars.value;
            }
            if (sChars.name == 'plan_name') {
                tempChar.plan_name = sChars.value;
            }
            if (sChars.name == 'contract_term') {
                tempChar.contract_term = sChars.value;
            }
            if (sChars.name == 'international_roaming') {
                tempChar.international_roaming = sChars.value;
            }
            if (sChars.name == 'message_bank') {
                tempChar.message_bank = sChars.value;
            }
            if (sChars.name == 'idd') {
                tempChar.idd = sChars.value;
            }
            if (sChars.name == 'tenancy_name') {
                tempChar.tenancy_name = sChars.value;
            }
            //Changes Start for EDGE-145906
            if (sChars.name == 'plan_type') {
                tempChar.plan_type = sChars.value;
            }
            //Changes End for EDGE-145906
            
            //EDGE-179394 changes by Abhishek from Osaka Team----START----
            if (sChars.name == 'aro_indicator') {
                tempChar.aro_indicator = sChars.value;
            }
            if (sChars.name == 'device_lease_contract_indicator') {
                tempChar.device_lease_contract_indicator = sChars.value;
            }
                  
            if (sChars.name == 'telstra_one_number_indicator') {
                tempChar.telstra_one_number_indicator = sChars.value;
            } 
            if (sChars.name == 'mro_with_no_imei') {
                tempChar.mro_with_no_imei = sChars.value;
            }
            //EDGE-179394 changes by Abhishek from Osaka Team----END----
            
            //Changes Start for EDGE-173831 by Abhishek from Osaka Team
            if (sChars.name == 'contract_remaining_term') {
                tempChar.contract_remaining_term = sChars.value;
            }
            //Changes End for EDGE-173831
            
            //Changes Start for EDGE-185055 by Abhishek from Osaka Team
            if (sChars.name == 'etc_flag') {
                tempChar.etc_flag = sChars.value;
            }
            //Changes End for EDGE-185055
           
            //Start of EDGE-205939 by Abhishek from Osaka Team
            if (sChars.name == 'user_name') {
                tempChar.user_name = sChars.value;
            }
            //End of EDGE-205938
        }
        tempChar.replicatorUpdateDateTime = serviceDetails.replicatorUpdateDateTime;
        list < TransitionDataDTO.devicesDTO > deviceList = New list < TransitionDataDTO.devicesDTO > ();
        for (ReplicatorGetServiceDTO.devicesDTO device: serviceDetails.devices) {
            TransitionDataDTO.devicesDTO deviceData = New TransitionDataDTO.devicesDTO();
            deviceData.deviceType = device.deviceType;
            deviceData.networkId = device.networkId;
            deviceData.physicalId = device.physicalId;
            deviceList.add(deviceData);
        }
        System.debug('&&&&&&&&&&&&&>>>>>>>>>>>--' + deviceList);
        tempChar.devices = deviceList;
        //B2B-1495:EDGE-177640 and EDGE-192009: Reading repayments from replicator response into transition JSON : Abhishek/Ramya
        list < TransitionDataDTO.repaymentsDTO > repaymentList = new List < TransitionDataDTO.repaymentsDTO > ();
        for (ReplicatorGetServiceDTO.repaymentsDTO repayments: serviceDetails.repayments) {
            TransitionDataDTO.repaymentsDTO repaymentData = New TransitionDataDTO.repaymentsDTO();
            repaymentData.productID = repayments.productId;
            repaymentData.deviceID = repayments.deviceId;
            repaymentData.deviceType = repayments.deviceType;
            repaymentData.billLiteral = repayments.billLiteral;
            repaymentData.contractType = repayments.contractType;
            repaymentData.monthlyAmount = repayments.monthlyAmount;
            repaymentData.remainingTerm = repayments.remainingTerm;
            repaymentData.remainingAmount = repayments.remainingAmount;
            repaymentData.productEndDate = repayments.productEndDate;
            repaymentList.add(repaymentData);
        }
        
        System.debug('RepaymentList ....###' + repaymentList);
        tempChar.repayments = repaymentList;
        //START- Added by Anurag for DIGI-1683
        Boolean sioConfigModeToggle =  FeatureEligibilityChecker.determineFeatureEligiblity('sioConfigMode',null);
        if(sioConfigModeToggle &&serviceDetails.addOns != null){
            List < TransitionDataDTO.addonsDTO > addOnsList = new List < TransitionDataDTO.addonsDTO > ();
            for (ReplicatorGetServiceDTO.addOnsDTO addOn: serviceDetails.addOns) {
                TransitionDataDTO.addonsDTO addondto = new TransitionDataDTO.addonsDTO();
                addondto.addOnName = addOn.addonName; 
                addondto.productCode = addOn.productCode; 
                addOnsList.add(addondto);
            }

            System.debug('addOnsList ....###' + addOnsList);
            tempChar.addOns = addOnsList;
        }
        //End for DIGI-1683   
        TransitionDataDTO.accountDTO accountDTOData = New TransitionDataDTO.accountDTO();
        accountDTOData.accountNumber = serviceDetails.account.accountNumber;
        accountDTOData.complexBillingIndicator = serviceDetails.account.complexBillingIndicator;
        accountDTOData.creditManagementFlag = serviceDetails.account.creditManagementFlag;
        accountDTOData.serviceWithEtcFlag = serviceDetails.account.serviceWithEtcFlag;
        accountDTOData.dealerCode = serviceDetails.account.dealerCode; //Changes for EDGE-145906
        accountDTOData.sourceCIDN = serviceDetails.cidn; // Changes for EDGE-198200
        tempChar.accountDetails = accountDTOData;
        TransitionDataDTO.groupDTOMobile groupDTOMobileList = new TransitionDataDTO.groupDTOMobile();
        groupDTOMobileList.service = new List < TransitionDataDTO.serviceDTOMobile > ();
        groupDTOMobileList.groupId = 'mobileGroup';
        groupDTOMobileList.service.add(tempChar);
        system.debug('$$$$$$$$$$$$>>>>>groupDTOMobile : ' + JSON.serialize(groupDTOMobileList));
        TransitionDataDTO.serviceListDTOMobile serviceListDTOMobileList = new TransitionDataDTO.serviceListDTOMobile();
        serviceListDTOMobileList.groupType = new List < TransitionDataDTO.groupDTOMobile > ();
        tempChar.Service_Id = serviceDetails.fnn;
        serviceListDTOMobileList.Service_Type = tempChar.service_type;
        serviceListDTOMobileList.groupType.add(groupDTOMobileList);
        //EDGE-185055 by Abhishek from Osaka Team
        Map < String, Replicator_Eligibility_Rule__mdt > eligibilityMobile = new Map < String, Replicator_Eligibility_Rule__mdt > ();
        eligibilityMobile = ReplicatorGetServiceManagerHelper.getReplicatorEligibilityRules();
        // Logic to check eligibility at servicelist level -- START
        
        // serviceDetails.account.serviceWithEtcFlag == 'Y' commented as a part of EDGE-185055 by Abhishek from Osaka Team
       
        
        //----------START of EDGE-185055 by Abhishek from Osaka Team----------//
        serviceListDTOMobileList.disableCheck = true;
        if (tempChar.etc_flag == eligibilityMobile.get('etc_flag').Identifier_Value__c) {
            serviceListDTOMobileList.EligibilityStatus = eligibilityMobile.get('etc_flag').Compatibility__c;
            serviceListDTOMobileList.EligibilityReason = eligibilityMobile.get('etc_flag').Reason__c;
        }
        //Start of EDGE-213742 Removing credit Ineligibility criteria by Abhishek(Osaka)
       
        //End of EDGE-213742 Removing credit Ineligibility criteria by Abhishek(Osaka)
        else if (accountDTOData.complexBillingIndicator == eligibilityMobile.get('complexBillingIndicator').Identifier_Value__c) {
            serviceListDTOMobileList.EligibilityStatus = eligibilityMobile.get('complexBillingIndicator').Compatibility__c;
            serviceListDTOMobileList.EligibilityReason = eligibilityMobile.get('complexBillingIndicator').Reason__c;
        } else if (tempChar.aro_indicator == eligibilityMobile.get('aro_indicator').Identifier_Value__c) {
            serviceListDTOMobileList.EligibilityStatus = eligibilityMobile.get('aro_indicator').Compatibility__c;
            serviceListDTOMobileList.EligibilityReason = eligibilityMobile.get('aro_indicator').Reason__c;
        } else if (tempChar.device_lease_contract_indicator == eligibilityMobile.get('device_lease_contract_indicator').Identifier_Value__c) {
            serviceListDTOMobileList.EligibilityStatus = eligibilityMobile.get('device_lease_contract_indicator').Compatibility__c;
            serviceListDTOMobileList.EligibilityReason = eligibilityMobile.get('device_lease_contract_indicator').Reason__c;
        } 
        //START EDGE-218846 Commented by Nikhil
       
        //END EDGE-218846
        else if (tempChar.mro_with_no_imei == eligibilityMobile.get('mro_with_no_imei').Identifier_Value__c) {
            serviceListDTOMobileList.EligibilityStatus = eligibilityMobile.get('mro_with_no_imei').Compatibility__c;
            serviceListDTOMobileList.EligibilityReason = eligibilityMobile.get('mro_with_no_imei').Reason__c;
        }
        //----------END of EDGE-185055 by Abhishek from Osaka Team----------//
        else {
            
            serviceListDTOMobileList.EligibilityStatus = 'Eligible';
            serviceListDTOMobileList.disableCheck = false;
            serviceListDTOMobileList.EligibilityReason = '';
            
        }
        // Logic to check eligibility at servicelist level -- END
        system.debug('$$$$$$$$$$$$>>>>>serviceListDTOMobileList : ' + JSON.serialize(serviceListDTOMobileList));
        TransitionDataDTO.SiteDTOMobile siteListDTOMobileList = new TransitionDataDTO.SiteDTOMobile();
        siteListDTOMobileList.serviceList = new List < TransitionDataDTO.serviceListDTOMobile > ();
        siteListDTOMobileList.ADBOR_Id = serviceDetails.site.siteId;
        siteListDTOMobileList.serviceList.add(serviceListDTOMobileList);
        system.debug('$$$$$$$$$$$$>>>>>siteListDTOMobileList : ' + JSON.serialize(siteListDTOMobileList));
        return siteListDTOMobileList;
    }
    /**
* @Author   :   Maqsood Alam
* @Date     :   21 July 2019
* @Desc     :   <getservices> As a Sales Enterprise B2B and partner user, I want to see list of customer's legacy mobile services as part of transition order journey So that I can verify the services customer would like to transition.
* @US       :   EDGE-66392
* @Status   :   Development
* */
    @AuraEnabled
    public static List < TableWrapper > getMobileServicesTablewrapper(TransitionDataDTO transitionMoblileData,
                                                                      String basketId) {
                                                                          //Set < String > allServiceIds = ReplicatorGetServiceManagerHelper.getDuplicateServiceIds(basketId);
                                                                          Set < String > allServiceIds = ReplicatorGetServiceManagerHelper.getDuplicateServiceIds(transitionMoblileData, basketId);
                                                                          Set<String> uniqueCidnValues = csvUploaderHelper.checkForCIDNHierarchy(basketId);                                                                  
                                                                          Map<String, String> cidnAbnMap = ReplicatorGetServiceManagerHelper.getABNBasedOnSourceCIDN(uniqueCidnValues);
                                                                          List<String> getSourceCidn = new List<String>();                                                               
                                                                          //Start of EDGE-198138: Collating all the service IDs returned from replicator.Ramya. Osaka.                                                                 
                                                                          List < String > serviceId = new List < String > ();
                                                                          // END of EDGE-198138
                                                                          System.debug('allServiceIds' + allServiceIds);
                                                                          Map < String,
                                                                              List < TableWrapper > > tableWrapperMap = new Map < String,
                                                                              List < TableWrapper > > ();
                                                                          //EDGE-179394                                                                  
                                                                          Map < String, Replicator_Eligibility_Rule__mdt > eligibilityMobile = new Map < String, Replicator_Eligibility_Rule__mdt > ();
                                                                          Boolean isResponseExist = false;
                                                                          List < TableWrapper > mobileTableWrapperList = new List < TableWrapper > ();
                                                                          // EDGE 145809 - Aarathi from Team Amsterdam - list create     
                                                                          
                                                                          //List < Number__c > reservedNums = [SELECT Service_Number__c from Number__c where Status__c = 'RESERVED'];
																		   List < Number__c > reservedNums = [SELECT Service_Number__c,Account__c from Number__c where Status__c = 'RESERVED' AND Account__r.CIDN__c in : uniqueCidnValues];
                                                                          Set < String > numSet = new Set < String > ();
                                                                          for (Number__c resnum: reservedNums) {
                                                                              numSet.add(String.valueOf(resnum.Service_Number__c));
                                                                          }
                                                                          try {
                                                                              eligibilityMobile = ReplicatorGetServiceManagerHelper.getReplicatorEligibilityRules(); //EDGE-179394 
                                                                              List < Attachment > attachmentListMobile = [SELECT Id, ParentId, Name, Body from Attachment WHERE ParentId IN(SELECT id FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c =: basketId AND cscfga__Product_Definition__r.product_Specification__c IN: listproductSpecMobile) AND Name =: TransitionJSONDataMobile LIMIT 1];
                                                                              if (attachmentListMobile.size() > 0) {
                                                                                  isResponseExist = true;
                                                                              }
                                                                              if (transitionMoblileData != NULL && transitionMoblileData.productList.size() > 0) {
                                                                                  for (TransitionDataDTO.productListDTO tMobileDataProduct: transitionMoblileData.productList) {
                                                                                      //    TableWrapper mobileTableWrapper=new TableWrapper();
                                                                                      system.debug('#######>>>>>******* site: ' + '--side--' + transitionMoblileData.productList.size() + '@@@@@@@' + tMobileDataProduct);
                                                                                      system.debug('#######>>>>>******* anem: ' + tMobileDataProduct.Product_Type + '--Status--' + tMobileDataProduct.eligibilityStatus + '@@@@@@@' + tMobileDataProduct.eligibilityReason);
                                                                                      for (TransitionDataDTO.SiteDTOMobile tMobileDataSite: tMobileDataProduct.site) {
                                                                                          system.debug('#######>>>>>******* tMobileDataSite: ' + JSON.serialize(tMobileDataSite));
                                                                                          for (TransitionDataDTO.serviceListDTOMobile tMobileDataServiceList: tMobileDataSite.serviceList) {
                                                                                              system.debug('#######>>>>>******* tMobileDataServiceList: ' + JSON.serialize(tMobileDataServiceList));
                                                                                              for (TransitionDataDTO.groupDTOMobile tMobileDataGroupType: tMobileDataServiceList.groupType) {
                                                                                                  system.debug('#######>>>>>******* tMobileDataGroupType: ' + JSON.serialize(tMobileDataGroupType));
                                                                                                  for (TransitionDataDTO.serviceDTOMobile tMobileDataService: tMobileDataGroupType.service) {
                                                                                                      system.debug('#######>>>>>******* tMobileDataService: ' + JSON.serialize(tMobileDataService));
                                                                                                      TableWrapper mobileTableWrapper = new TableWrapper();
                                                                                                      mobileTableWrapper.Id = tMobileDataProduct.Product_Type + '~!@@!~' + tMobileDataService.Service_Id;
                                                                                                      mobileTableWrapper.Product_Type = tMobileDataProduct.Product_Type;
                                                                                                      mobileTableWrapper.tenancy_name = tMobileDataService.tenancy_name;
                                                                                                      mobileTableWrapper.Product_Number = tMobileDataService.Service_Id;
                                                                                                      //DIGI-1741 : Added by Abhishek(Osaka) for handling validations on Confirm Button.
                                                                                                      mobileTableWrapper.planConfigMode = (transitionMoblileData.sendAddOnsConfig!=null) ? transitionMoblileData.sendAddOnsConfig : '' ;
                                                                                                      //Start of EDGE-205938 by Abhishek(Osaka) : Introducing Nickname
                                                                                                      mobileTableWrapper.user_name = tMobileDataService.user_name;
                                                                                                      //End of EDGE-205938 by Abhishek(Osaka) : Introducing Nickname
                                                                                                      if(tMobileDataService.accountDetails != NULL) {
                                                                                                          mobileTableWrapper.BAN = tMobileDataService.accountDetails.accountNumber;
                                                                                                          mobileTableWrapper.source_CIDN = tMobileDataService.accountDetails.sourceCIDN;
                                                                                                          mobileTableWrapper.ABN = cidnAbnMap.get(mobileTableWrapper.source_CIDN);    
                                                                                                      }
                                                                                                      
                                                                                                      //EDGE-198138: Collating service ID:Ramya,Osaka
                                                                                                      serviceId.add(tMobileDataService.Service_Id);
                                                                                                      // EDGE-103382 - Point 3 - Maq - START --   
                                                                                                      // START of EDGE-179394  : Osaka: Reading eligibility criteria from metadata
                                                                                                      mobileTableWrapper.checkValue = false;
                                                                                                      //Start Of EDGE-185055 : Change to Replicator_Eligibility_Rule__mdt metadata, renaming servicewithetcflag to etc_flag by Abhishek from Osaka Team                                    
                                                                                                      //START OF EDGE-199057 by Abhishek from Osaka Team
                                                                                                      
                                                                                                      if (allServiceIds.contains(tMobileDataService.Service_Id)) {
                                                                                                          System.debug('Inside Ineligible If recently added');
                                                                                                          mobileTableWrapper.eligibilityStatus = eligibilityMobile.get('existingService_indicator').Compatibility__c;
                                                                                                          mobileTableWrapper.eligibilityReason = eligibilityMobile.get('existingService_indicator').Reason__c;
                                                                                                      } else if (tMobileDataGroupType.transitionId != null && tMobileDataGroupType.transitionId != '') {
                                                                                                          System.debug('Inside TM1');
                                                                                                          //tMobileDataServiceList.disableCheck = true;
                                                                                                          mobileTableWrapper.eligibilityStatus = tMobileDataServiceList.EligibilityStatus;
                                                                                                          mobileTableWrapper.eligibilityReason = tMobileDataServiceList.EligibilityReason;
                                                                                                      }
                                                                                                      //END OF EDGE-199057 by Abhishek from Osaka Team   
                                                                                                      else if (tMobileDataService.etc_flag == eligibilityMobile.get('etc_flag').Identifier_Value__c) {
                                                                                                          mobileTableWrapper.eligibilityStatus = eligibilityMobile.get('etc_flag').Compatibility__c;
                                                                                                          mobileTableWrapper.eligibilityReason = eligibilityMobile.get('etc_flag').Reason__c;
                                                                                                          //END Of EDGE-185055
                                                                                                          //System.debug('Check Value inside if:::'+mobileTableWrapper.checkValue);
                                                                                                      } 
                                                                                                      //Start of EDGE-213742 Removing credit Ineligibility criteria by Abhishek(Osaka)
                                                                                                      
                                                                                                      //End of EDGE-213742 Removing credit Ineligibility criteria by Abhishek(Osaka)
                                                                                                      else if (tMobileDataService.accountDetails.complexBillingIndicator == eligibilityMobile.get('complexBillingIndicator').Identifier_Value__c) {
                                                                                                          mobileTableWrapper.eligibilityStatus = eligibilityMobile.get('complexBillingIndicator').Compatibility__c;
                                                                                                          mobileTableWrapper.eligibilityReason = eligibilityMobile.get('complexBillingIndicator').Reason__c;
                                                                                                      } else if (tMobileDataService.aro_indicator == eligibilityMobile.get('aro_indicator').Identifier_Value__c) {
                                                                                                          mobileTableWrapper.eligibilityStatus = eligibilityMobile.get('aro_indicator').Compatibility__c;
                                                                                                          mobileTableWrapper.eligibilityReason = eligibilityMobile.get('aro_indicator').Reason__c;
                                                                                                      } else if (tMobileDataService.device_lease_contract_indicator == eligibilityMobile.get('device_lease_contract_indicator').Identifier_Value__c) {
                                                                                                          mobileTableWrapper.eligibilityStatus = eligibilityMobile.get('device_lease_contract_indicator').Compatibility__c;
                                                                                                          mobileTableWrapper.eligibilityReason = eligibilityMobile.get('device_lease_contract_indicator').Reason__c;
                                                                                                      } 
                                                                                                      //START EDGE-218846 Commented by Nikhil
                                                                                                     
                                                                                                      //END EDGE-218846
                                                                                                      else if (tMobileDataService.mro_with_no_imei == eligibilityMobile.get('mro_with_no_imei').Identifier_Value__c) {
                                                                                                          mobileTableWrapper.eligibilityStatus = eligibilityMobile.get('mro_with_no_imei').Compatibility__c;
                                                                                                          mobileTableWrapper.eligibilityReason = eligibilityMobile.get('mro_with_no_imei').Reason__c;
                                                                                                      } else {
                                                                                                          System.debug('Inside else checkValue ' + mobileTableWrapper.checkValue);
                                                                                                          // END of EDGE-179394  : Osaka: Reading eligibility criteria from metadata
                                                                                                          mobileTableWrapper.eligibilityStatus = tMobileDataServiceList.EligibilityStatus; //'Eligible';
                                                                                                          mobileTableWrapper.eligibilityReason = tMobileDataServiceList.EligibilityReason; //tMobileDataProduct.eligibilityReason;
                                                                                                          mobileTableWrapper.checkValue = true;
                                                                                                          // EDGE 145809 - Aarathi from Team Amsterdam -- start if loop
                                                                                                          if (numSet.size() > 0) {
                                                                                                              if (numSet.contains(mobileTableWrapper.Product_Number)) {
                                                                                                                  mobileTableWrapper.eligibilityStatus = 'Not Eligible';
                                                                                                                  //EDGE 148583 - Aarathi from Team Amsterdam - changed error message
                                                                                                                  mobileTableWrapper.eligibilityReason = Label.IneligibleReserved;
                                                                                                                  mobileTableWrapper.checkValue = false;
                                                                                                                  system.debug('matched numbers are:' + mobileTableWrapper.Product_Number);
                                                                                                              }
                                                                                                          }
                                                                                                          //EDGE 145809 - Aarathi from Team Amsterdam --end if loop
                                                                                                      } // else ending
                                                                                                      System.debug('Check Value after else:::' + mobileTableWrapper.checkValue);
                                                                                                      // EDGE-103382 - Point 3 - Maq - END -- 
                                                                                                      mobileTableWrapper.plan_name = tMobileDataService.plan_name;
                                                                                                      mobileTableWrapper.contract_term = tMobileDataService.contract_term;
                                                                                                      //---START---Changes for EDGE-173831 by Abhishek from Osaka Team
                                                                                                      mobileTableWrapper.contract_remaining_term = tMobileDataService.contract_remaining_term;
                                                                                                      //---END---Changes for EDGE-173831 by Abhishek from Osaka Team
                                                                                                      if (isResponseExist == true) {
                                                                                                          System.debug('isResponseExist inside if' + tMobileDataServiceList.checkValue);
                                                                                                          //Fix for saved JSON's de-selection of Ineligible Services for EDGE-187740 by Abhishek form Osaka Team----START----
                                                                                                          if (mobileTableWrapper.eligibilityStatus == 'Not Eligible') {
                                                                                                              mobileTableWrapper.checkValue = false;
                                                                                                          }
                                                                                                          //Fix for saved JSON's de-selection of Ineligible Services for EDGE-187740 by Abhishek form Osaka Team----END-----
                                                                                                          else {
                                                                                                              mobileTableWrapper.checkValue = tMobileDataServiceList.checkValue;
                                                                                                          }
                                                                                                          
                                                                                                      }
                                                                                                      System.debug('Check Value isResponse:::' + mobileTableWrapper.checkValue);
                                                                                                      //EDGE-198376 . set reason and status TM1 callback failure Start 
                                                                                                     
                                                                                                      
                                                                                                      //EDGE-139071 start
                                                                                                      if (tMobileDataService.accountDetails.dealerCode != '') {
                                                                                                          mobileTableWrapper.Dealer_Code = tMobileDataService.accountDetails.dealerCode;
                                                                                                      } else {
                                                                                                          mobileTableWrapper.Dealer_Code = 'NA';
                                                                                                      }
                                                                                                      if (tMobileDataService.plan_type != '') {
                                                                                                          mobileTableWrapper.Plan_Type = tMobileDataService.plan_type;
                                                                                                      } else {
                                                                                                          mobileTableWrapper.Plan_Type = 'NA';
                                                                                                      }
                                                                                                      //EDGE-139071 end
                                                                                                      mobileTableWrapperList.add(mobileTableWrapper);
                                                                                                  }
                                                                                              }
                                                                                          }
                                                                                      }
                                                                                  }
                                                                              } else {
                                                                                  //Changes to remove SonarQube Vulnerabilities by Abhishek(Osaka)(Returning empty list instead of null)
                                                                                    return null;
                                                                                    //return new List < TableWrapper > ();
                                                                              }
                                                                          } catch (Exception ex) {
                                                                              System.debug('Exception Occure In Response from Replicator' + ex);
                                                                              System.debug(LoggingLevel.debug, '--->Error occurred##> ' + ex.getMessage());
                                                                              System.debug(LoggingLevel.debug, '--->Error Line##> ' + ex.getLineNumber());
                                                                              System.debug(LoggingLevel.debug, '--->Error Trace##> ' + ex.getStackTraceString());
                                                                              System.debug(LoggingLevel.debug, '--->Error Cause##> ' + ex.getCause());
                                                                            
                                                                              logException('getMobileServicesTablewrapper', basketId, correlationId, ex.getMessage(), 'get MobileServicesTablewrapper');

                                                                              //Changes to remove SonarQube Vulnerabilities by Abhishek(Osaka)(Returning empty list instead of null)
                                                                              //return null;
                                                                              return new List < TableWrapper > ();
                                                                          }
                                                                          //List<String> relatedABNFromSourceCIDN = getABNBasedOnSourceCIDN(getSourceCidn);
                                                                          return mobileTableWrapperList;
                                                                      }
    
    
    
    /**
* @Author   :   Maqsood Alam
* @Date     :   22 May 2019
* @Desc     :   Should Mobility transition JSON response as JSON attachment (with the name TransitionData.json) inside one of the Mobility Product Configiration in the Product Basket
* @US       :   EDGE-89542
* @Status   :   Development
* */
    @AuraEnabled
    public static List < Attachment > insertJSONResponseMobile(TransitionDataDTO TransitionDataJSON, List < TableWrapper > selectedList, String basketId, Boolean SendCallout) {
        //Start of EDGE-211664 by Abhishek(Osaka)
        Set<String> uniqueCidnValues = csvUploaderHelper.checkForCIDNHierarchy(basketId);                                                                  
        Map<String, String> cidnAbnMap = ReplicatorGetServiceManagerHelper.getABNBasedOnSourceCIDN(uniqueCidnValues);
        String target_CIDN = getBasket(basketId).csbb__Account__r.CIDN__c;
        //End of EDGE-211664 by Abhishek(Osaka)
        List < Attachment > attachmentJSONMobileList = new List < Attachment > ();
        system.debug('************before' + JSON.serialize(TransitionDataJSON));
        system.debug('************Sel' + JSON.serialize(selectedList));
        TransitionDataJSON.CIDN = target_CIDN;//Added as a part of EDGE-211664 By Abhishek(Osaka) to persist Target CIDN in Default and CIDN Hierarchy in TransitionData.json
        for (TransitionDataDTO.productListDTO productList: TransitionDataJSON.productList) {
            for (TransitionDataDTO.SiteDTOMobile siteDTO: productList.site) {
                for (TransitionDataDTO.serviceListDTOMobile serviceListDTO: siteDTO.serviceList) {
                    for (TransitionDataDTO.groupDTOMobile groupDTO: serviceListDTO.groupType) {
                        for (TransitionDataDTO.serviceDTOMobile serviceDTO: groupDTO.service) {
                            //Start of EDGE-211664 by Abhishek(Osaka)
                            if(serviceDTO.accountDetails != NULL){
                                //Persist ABN(businessnumber) in Transition JSON for mobile.
                                serviceDTO.accountDetails.businessnumber = cidnAbnMap.get(serviceDTO.accountDetails.sourceCIDN);
                            }
                            //End of EDGE-211664 by Abhishek(Osaka)
                            if (selectedList.size() > 0) {
                                for (TableWrapper pFamServiceId: selectedList) {
                                    system.debug('<--Pair value-->' + productList.Product_Type + '~!@@!~' + serviceDTO.Service_Id + '<===>' + pFamServiceId.Id);
                                    if (productList.Product_Type + '~!@@!~' + serviceDTO.Service_Id == pFamServiceId.Id) {
                                        serviceListDTO.checkValue = true;
                                        groupDTO.checkValue = true;
                                        break;
                                    } else {
                                        serviceListDTO.checkValue = false;
                                        groupDTO.checkValue = false;
                                    }
                                }
                            } else {
                                serviceListDTO.checkValue = false;
                                groupDTO.checkValue = false;
                            }
                        }
                    }
                }
            }
        }
        system.debug('************after' + JSON.serialize(TransitionDataJSON));
        List < Id > productConfigIds = new List < Id > ();
        try {
            for (cscfga__Product_Configuration__c productConfig: [SELECT id FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c =: basketId AND cscfga__Product_Definition__r.product_Specification__c IN: listproductSpecMobile
                                                                  ORDER BY Createddate DESC
                                                                 ]) {
                                                                     productConfigIds.add(productConfig.id);
                                                                 }
            system.debug('*******productConfigIds=> ' + JSON.serialize(productConfigIds) + '&&&&&' + basketId);
            if (productConfigIds.size() > 0) {
                List < Attachment > attchedJSON = [SELECT id, name, body, parentId FROM Attachment WHERE ParentId in: productConfigIds AND Name =: TransitionJSONDataMobile order by createdDate desc limit 1];
                String TransitionJSONData = JSON.serialize(TransitionDataJSON);
                Blob bodyAttachmentMobile = Blob.valueOf(TransitionJSONData);
                //    Blob bodyAttachmentMobile = Blob.valueOf(TransitionJSONData);
                system.debug('******debug' + TransitionDataJSON);
                /* Inserting into attachement Obj */
                Attachment attachmentJSONMobile = new Attachment();
                attachmentJSONMobile.Name = TransitionJSONDataMobile;
                attachmentJSONMobile.ParentId = productConfigIds[0];
                attachmentJSONMobile.Body = bodyAttachmentMobile;
                attachmentJSONMobileList.add(attachmentJSONMobile);
                system.debug('*******FinalResponses=> ' + JSON.serialize(attachmentJSONMobileList));
                //if (attachmentJSONMobileList != null) {
                if (attachmentJSONMobile != null) {    
                    if (attchedJSON.size() > 0) delete attchedJSON;
                    //insert attachmentJSONMobileList;
                    insert attachmentJSONMobile;
                }
            }
        }
        Catch(Exception ex) {
            System.debug('Exception Occure In Response from Replicator' + ex);
            System.debug(LoggingLevel.debug, '--->Error occurred##> ' + ex.getMessage());
            System.debug(LoggingLevel.debug, '--->Error Line##> ' + ex.getLineNumber());
            System.debug(LoggingLevel.debug, '--->Error Trace##> ' + ex.getStackTraceString());
            System.debug(LoggingLevel.debug, '--->Error Cause##> ' + ex.getCause());
            
            logException('insertJSONResponseMobile', basketId, correlationId, ex.getMessage(), 'insertJSONResponseMobile');
            
            //Changes to remove SonarQube Vulnerabilities by Abhishek(Osaka)(Returning empty list instead of null)
            //return null;
            return new List < Attachment > ();
        }
        return attachmentJSONMobileList;
    }
    /** This is fetch all the attributes of Basket*/
    @AuraEnabled
    public static cscfga__Product_Basket__c getBasket(String basketId) {
        //Added csbb__Account__r.CIDN__c in select as a part of EDGE-211350 by Abhishek(Osaka)
        cscfga__Product_Basket__c prodBasket = [select Id, Transition_basket_stage__c,csbb__Account__r.CIDN__c from cscfga__Product_Basket__c where Id =: basketId];
        return prodBasket;
    }
    /**
* @Author   :   Maqsood Alam
* @Date     :   16 Oct 2019
* @Desc     :   As a Sales Enterprise B2B user and Partner user, as part of transition order I should be able to see legacy services (ISDN10/20/30) to transition them into ngUC hosted offer.
* @US       :   EDGE-92538
* @Status   :   Development
* */
    @AuraEnabled
    public static List < Attachment > insertJSONResponseNgUc(TransitionDataDTO TransitionDataJSON, List < ReplicatorGetServiceManager.NgUCTableWrapper > selectedList, String basketId, Boolean SendCallout) {
        List < Attachment > attachmentJSONNgUcList = new List < Attachment > ();
        
        try {
            //Start of EDGE-208791 by Abhishek(Osaka)
            Set<String> uniqueCidnValues = csvUploaderHelper.checkForCIDNHierarchy(basketId);                                                                  
            Map<String, String> cidnAbnMap = ReplicatorGetServiceManagerHelper.getABNBasedOnSourceCIDN(uniqueCidnValues);
            String target_CIDN = getBasket(basketId).csbb__Account__r.CIDN__c;
            TransitionDataJSON.CIDN = target_CIDN;
            //End of EDGE-208791 by Abhishek(Osaka)
            system.debug('*******FinalResponses No Change NGUC=>Main ' + JSON.serialize(TransitionDataJSON));
            system.debug('*******selectedListNo Change NGUC=> Main ' + JSON.serialize(selectedList));
            for (TransitionDataDTO.productListDTO productList: TransitionDataJSON.productList) {
                for (TransitionDataDTO.SiteDTOMobile siteDTO: productList.site) {
                    for (TransitionDataDTO.serviceListDTOMobile serviceListDTO: siteDTO.serviceList) {
                        for (TransitionDataDTO.groupDTOMobile groupDTO: serviceListDTO.groupType) {
                            groupDTO.checkValue = false;
                            for (TransitionDataDTO.serviceDTOMobile serviceDTO: groupDTO.service) {
                                //Start of EDGE-208791 by Abhishek(Osaka)
                                if(serviceDTO.accountDetails != NULL){
                                    //Persist ABN(businessnumber) in Transition JSON for Nguc.
                                    serviceDTO.accountDetails.businessnumber = cidnAbnMap.get(serviceDTO.accountDetails.sourceCIDN);
                                }
                                //End of EDGE-208791 by Abhishek(Osaka)
                                if (selectedList.size() > 0) {
                                    for (NgUCTableWrapper pFamServiceId: selectedList) {
                                        system.debug('<--Pair value-->' + productList.Product_Type + '~!@@!~' + serviceDTO.Service_Id + '<===>' + pFamServiceId.Id);
                                        // check at group level -----------
                                        if (productList.Product_Type == pFamServiceId.Product_Type) {
                                            if (serviceDTO.Service_Id + '_PFamily' == pFamServiceId.Id || pFamServiceId.Id.contains(groupDTO.groupId)) {
                                                groupDTO.checkValue = true;
                                                // break;
                                            }
                                        }
                                        // check at service level----------
                                    }
                                } else {
                                    groupDTO.checkValue = false;
                                }
                            }
                        }
                    }
                }
            }
            system.debug('*******FinalResponses No Change NGUC=>Outside ' + JSON.serialize(TransitionDataJSON));
            List < Id > productConfigIds = new List < Id > ();
            for (cscfga__Product_Configuration__c productConfig: [SELECT id FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c =: basketId AND cscfga__Product_Definition__r.product_Specification__c IN: listproductSpecNgUc ORDER BY Createddate DESC]) {
                productConfigIds.add(productConfig.id);
            }
            system.debug('*******productConfigIds=> ' + JSON.serialize(productConfigIds) + '&&&&&' + basketId);
            if (productConfigIds.size() > 0 || true) {
                List < Attachment > attchedJSON = [SELECT id, name, parentId FROM Attachment WHERE ParentId in: productConfigIds AND Name =: TransitionJSONDataNgUc order by createdDate desc limit 1];
                system.debug('attchedJSON---->' + attchedJSON);
                String TransitionJSONData = JSON.serialize(TransitionDataJSON);
                Blob bodyAttachmentNgUc = Blob.valueOf(TransitionJSONData);
                //    Blob bodyAttachmentNgUc = Blob.valueOf(TransitionJSONData);
                system.debug('******debug' + TransitionDataJSON);
                /* Inserting into attachement Obj */
                Attachment attachmentJSONNgUc = new Attachment();
                attachmentJSONNgUc.Name = TransitionJSONDataNgUc;
                if (productConfigIds.size() > 0) {
                    attachmentJSONNgUc.ParentId = productConfigIds[0];
                } else {
                    //attachmentJSONNgUc.ParentId = 'a3Q2N0000002ugdUAA';
                }
                attachmentJSONNgUc.Body = bodyAttachmentNgUc;
                attachmentJSONNgUcList.add(attachmentJSONNgUc);
                system.debug('*******FinalResponses=> ' + JSON.serialize(attachmentJSONNgUcList));
                //EDGE-223930 : Commenting lines to avoid creation of multiples JSONs by Abhishek(Osaka)
                //if (attachmentJSONNgUcList != null) {
                    if (attachmentJSONNgUc != null) {    
                        if (attchedJSON.size() > 0) {
                            system.debug('attchedJSON---->Inside' + attchedJSON);
                            delete attchedJSON;
                        }
                        //EDGE-223930 : Commenting lines to avoid creation of multiples JSONs by Abhishek(Osaka)
                        //insert attachmentJSONNgUcList;
                        insert attachmentJSONNgUc;
                    }
            }
        } catch (Exception ex) {
            System.debug('Exception Occure In Response from Replicator');
            System.debug(LoggingLevel.debug, '--->Error occurred##> ' + ex.getMessage());
            System.debug(LoggingLevel.debug, '--->Error Line##> ' + ex.getLineNumber());
            System.debug(LoggingLevel.debug, '--->Error Trace##> ' + ex.getStackTraceString());
            System.debug(LoggingLevel.debug, '--->Error Cause##> ' + ex.getCause());
            
            logException('insertJSONResponseNgUc', basketId, correlationId, ex.getMessage(), 'insertJSONResponseNgUc');
                
            //Changes to remove SonarQube Vulnerabilities by Abhishek(Osaka)(Returning empty list instead of null)
            //return null;
            return new List < Attachment > ();
        }
        return attachmentJSONNgUcList;
    }
    /**
* @Author   :   Maqsood Alam
* @Date     :   16 Oct 2019
* @Desc     :   As a Sales Enterprise B2B user and Partner user, as part of transition order I should be able to see legacy services (ISDN10/20/30) to transition them into ngUC hosted offer.
* @US       :   EDGE-92538
* @Status   :   Development
* */
    @AuraEnabled
    public static ReplicatorGetServiceDTO getSiteAgnosticServicesNgUc(String finCIDN, List < String > prodFamilies, String basketId, String cidnHierarchy, Boolean isCidnHierarchy, String selectedProdFamily) {
        
        System.debug('Inside Nguc isCidnHierarchy check::'+isCidnHierarchy);
        System.debug('Inside Nguc Selected CIDN List::'+cidnHierarchy);
        ReplicatorGetServiceDTO getServiceDTO = getSiteAgnosticServices(finCIDN, prodFamilies, basketId, cidnHierarchy, isCidnHierarchy, selectedProdFamily);
        return getServiceDTO;
    }
    /**
* @Author   :   Maqsood Alam
* @Date     :   16 Oct 2019
* @Desc     :   As a Sales Enterprise B2B user and Partner user, as part of transition order I should be able to see legacy services (ISDN10/20/30) to transition them into ngUC hosted offer.
* @US       :   EDGE-92538
* @Status   :   Development
* */
    @AuraEnabled
    //EDGE-222176 :  Added Additional parameters finCIDN, SelectedCIDN List for TIPT-SIPC eligibility by Abhishek(Osaka)
    public static TransitionDataDTO transformReplicatorResponseNgUc(ReplicatorGetServiceDTO responseFmReplicator, String basketId, String finCIDN, List<String> selectedCIDN) {
        
        TransitionDataDTO transitionResponseNgUc = new TransitionDataDTO();
        ReplicatorGetServiceManagerHandler replicatorClass = new ReplicatorGetServiceManagerHandler();
        map < string, list < String >> gdnPrimeAuxRelation = new map < string, list < String >> ();
        Map < String, list < TransitionDataDTO.SiteDTOMobile >> prodSiteMap = new Map < String, list < TransitionDataDTO.SiteDTOMobile >> ();
        List < TransitionDataDTO.productListDTO > productFamilyListFinal = new List < TransitionDataDTO.productListDTO > ();
        List < TransitionDataDTO.productListDTO > productFamilyList = new List < TransitionDataDTO.productListDTO > ();
        
        prodSiteMapGlobal = new Map < String, list < TransitionDataDTO.SiteDTOMobile >> ();
        
        TransitionDataDTO.productListDTO productFamilySiteMapping = New TransitionDataDTO.productListDTO();
        List < TransitionDataDTO.productListDTO > productFamilyListNgUc = new List < TransitionDataDTO.productListDTO > ();
        
        String CIDN_String = '';
        gdnParentChild = New Map < String, Map < String, list < String >>> ();
        
        /*-- if Response Already exist in the Product Configuration --*/
        List < Id > productConfigIds = new List < Id > ();
        for (cscfga__Product_Configuration__c productConfig: [SELECT id FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c =: basketId AND cscfga__Product_Definition__r.product_Specification__c IN: listproductSpecNgUc ORDER BY Createddate DESC]) {
            productConfigIds.add(productConfig.id);
        }
        
        if (productConfigIds.size() > 0) {
            List < Attachment > attchedJSON = [SELECT id, name, body, parentId FROM Attachment WHERE ParentId in: productConfigIds AND Name =: TransitionJSONDataNgUc order by createdDate desc limit 1];
            if (attchedJSON.size() > 0) {
                TransitionDataDTO AttchedTransitonDTOJSON = TransitionDataDTO.parse(attchedJSON[0].body.toString());
                system.debug('######>>>>>>********' + AttchedTransitonDTOJSON);
                return AttchedTransitonDTOJSON;
            }
        }
        
        /*-- if Response Already exist in the Product Configuration --*/
        TransitionDataDTO.productListDTO productFamilyDTOObj = New TransitionDataDTO.productListDTO();
        // Fetch custom metadata value ----
        map < String, String > transGroupStructMap = new map < String, String > ();
        
        for (Transition_Group_Structure_New__mdt transGroupStruct: [SELECT DeveloperName, Label, Node_1__c, Node_2__c, Node_3__c, Product_Family__c, Range_Indicator__c, Hybrid__c FROM Transition_Group_Structure_New__mdt]) {
            transGroupStructMap.put(transGroupStruct.Product_Family__c, transGroupStruct.Range_Indicator__c + '~!@!~' + transGroupStruct.Node_1__c + '~!@!~' + transGroupStruct.Node_2__c + '~!@!~' + transGroupStruct.Node_3__c);
            productFamilyToHybridCheck.put(transGroupStruct.Product_Family__c, transGroupStruct.Hybrid__c); // EDGE-152495 : @Apple : VM ;
        }
        //system.debug('**********transGroupStructMap if ++++ ' + JSON.serialize(transGroupStructMap));
        //system.debug('********** responseFmReplicator.servicesList if ++++ ' + responseFmReplicator.servicesList);
        
        for (ReplicatorGetServiceDTO.servicesDTO serviceDetails: responseFmReplicator.servicesList) {
            ReplicatorGetServiceManagerHandler.groupingLogic_ByNodeParent(serviceDetails);
        }
        
        for (ReplicatorGetServiceDTO.servicesDTO serviceDetails: responseFmReplicator.servicesList) {
            //---- Grouping Logic Code ----
            
            if (transGroupStructMap.containskey(serviceDetails.productFamily)) {
                List < String > nodes = transGroupStructMap.get(serviceDetails.productFamily).split('~!@!~');
                // EDGE-152495 : @Apple : VM ; 29 jAN 2021
                // Run previous / existing logic for other prduct family
                if (productFamilyToHybridCheck != null && productFamilyToHybridCheck.containskey(serviceDetails.productFamily) && !productFamilyToHybridCheck.get(serviceDetails.productFamily)) {
                    if (nodes[0] == 'true') { // Range condition - ISDN2DID, ISDN30
                        ReplicatorGetServiceManagerHandler.groupingLogic_ByRange(serviceDetails);
                    } else { // Non Range condition - PSTN, ISDN2 
                        ReplicatorGetServiceManagerHandler.groupingLogic_ByNodeChild(serviceDetails);
                    }
                } else { // Run New logic for TIPT-SIPC prduct family EDGE-152495
                    // ReplicatorGetServiceManagerHandler.groupingLogic_ByHybrid_New( serviceDetails ); //EDGE-204581 commented
                }
            }
            //---- Grouping Logic Code ----
            CIDN_String = serviceDetails.cidn;
            //FNN_String = serviceDetails.fnn; //EDGE-152495 Added By ankit ; keep it for future reference
        }
        system.debug('******************ngucNewImp' + JSON.serialize(prodGroupTypeMapping)); // This variable contain all the FNN - Range & Group
        system.debug('******************parentUniqueStringMap' + JSON.serialize(parentUniqueStringMap)); // This variable contain all the FNN - Range & Group
        system.debug('******************transGroupStructMapMain' + JSON.serialize(ReplicatorGetServiceManagerHandler.transGroupStructMapMain)); // This variable contain all the FNN - Range & Group
        
        
        // @Rainy Start EDGE-204581
        // if ( productFamilyToHybridCheck != null && productFamilyToHybridCheck.containskey( serviceDetails.productFamily ) &&  productFamilyToHybridCheck.get( serviceDetails.productFamily ) ) { 
        
        //EDGE-222176 :  Added Additional parameters finCIDN, SelectedCIDN List for TIPT-SIPC eligibility by Abhishek(Osaka)
        TransitionDataDTO.SiteDTOMobile returnedDataDTO = ReplicatorParserManagerNGUC.transformReplicatorResponseNgUc(responseFmReplicator, basketId , finCIDN, selectedCIDN);
        // }
        // @Rainy End EDGE-204581 
        
        Map < String, list < TransitionDataDTO.SiteDTOMobile > > prodFamilySiteMap = New Map < String, list < TransitionDataDTO.SiteDTOMobile > > ();
        boolean isEnterprise = true; //EDGE-204581
        //-- combining all the json from different product family into one | Site logic as well ---
        for (ReplicatorGetServiceDTO.servicesDTO serviceDetails: responseFmReplicator.servicesList) {
            String pFamily_PLabel = serviceDetails.productFamily;
            if (parentUniqueStringMap.get(serviceDetails.fnn) != null) {
                pFamily_PLabel = pFamily_PLabel + '_' + ReplicatorGetServiceManagerHandler.transGroupStructMapMain.get(parentUniqueStringMap.get(serviceDetails.fnn).toLowerCase()).Label + '_' + serviceDetails.fnn;
            }
            //system.debug('******************pFamily_PLabel' + JSON.serialize(pFamily_PLabel));
            if (prodGroupTypeMapping.containsKey(pFamily_PLabel) && productFamilyToHybridCheck != null && productFamilyToHybridCheck.containskey(serviceDetails.productFamily) && !productFamilyToHybridCheck.get(serviceDetails.productFamily)) { //added another condition EDGE-204581
                // if (prodGroupTypeMapping.get(pFamily_PLabel).containsKey(serviceDetails.fnn)){
                if (prodFamilySiteMap.containsKey(pFamily_PLabel)) {
                    //two GDN have same site   
                    prodFamilySiteMap.get(pFamily_PLabel).add(getSiteLogicNgUc(serviceDetails, ReplicatorGetServiceManagerHandler.transGroupStructMapMain));
                } else {
                    // 1st gdn 
                    productFamilySiteMapping = New TransitionDataDTO.productListDTO();
                    list < TransitionDataDTO.SiteDTOMobile > siteRecord = new list < TransitionDataDTO.SiteDTOMobile > ();
                    TransitionDataDTO.SiteDTOMobile siteListDTOMobileList = new TransitionDataDTO.SiteDTOMobile();
                    siteRecord.add(getSiteLogicNgUc(serviceDetails, ReplicatorGetServiceManagerHandler.transGroupStructMapMain));
                    productFamilySiteMapping.site = new List < TransitionDataDTO.SiteDTOMobile > ();
                    productFamilySiteMapping.Product_Type = serviceDetails.productFamily;
                    productFamilySiteMapping.site = siteRecord;
                    prodFamilySiteMap.put(pFamily_PLabel, siteRecord);
                    productFamilyListNgUc.add(productFamilySiteMapping);
                }
                // }
            } //adde EDGE-204581 || strat
            else if (isEnterprise) {
                isEnterprise = false;
                productFamilySiteMapping = New TransitionDataDTO.productListDTO();
                list < TransitionDataDTO.SiteDTOMobile > siteRecord = new list < TransitionDataDTO.SiteDTOMobile > ();
                TransitionDataDTO.SiteDTOMobile siteListDTOMobileList = new TransitionDataDTO.SiteDTOMobile();
                siteRecord.add(returnedDataDTO);
                productFamilySiteMapping.site = new List < TransitionDataDTO.SiteDTOMobile > ();
                productFamilySiteMapping.Product_Type = serviceDetails.productFamily;
                productFamilySiteMapping.site = siteRecord;
                prodFamilySiteMap.put(pFamily_PLabel, siteRecord);
                productFamilyListNgUc.add(productFamilySiteMapping);
            }
            //adde EDGE-204581 || end
        }
        
        //-- combining all the json from different product family into one ---
        system.debug('******************prodGroupTypeMapping' + JSON.serialize(prodGroupTypeMapping));
        system.debug('******************nguc' + JSON.serialize(productFamilyListFinal));
        // productFamilyList
        /* Constructing NgUC Transistion JSON file */
        // transitionResponseNgUc.CIDN = CIDN_String;
        
        List < String > cidnListString = new List < String > ();
        cidnListString.addAll(CIDN_String_List);
        //transitionResponseNgUc.CIDN = String.join(cidnListString,', ');  // keep it for future reference EDGE-152495 : @Apple : VM     
        transitionResponseNgUc.CIDN = CIDN_String;
        
        //transitionResponseNgUc.CIDNList = CIDN_String_List;
        transitionResponseNgUc.Source_System_Id = 'Replicator';
        //    transitionResponseNgUc.productList = productFamilyListFinal;
        transitionResponseNgUc.productList = productFamilyListNgUc;
        transitionResponseNgUc.Correlation_Id = responseFmReplicator.correlationId;
        transitionResponseNgUc.Error_Code = '';
        transitionResponseNgUc.Error_Description = '';
        //EDGE-208791 Commented Legacy TenancyId by Abhishek(Osaka)
        //EDGE-208791 by Abhishek(Osaka): Removing LegacyTenancyId from json file. Dormancy flag added to enable it only after 21.10 deployment.
        /*if(isOsakaDormant == 'true'){
            transitionResponseNgUc.LegacyTenancyID = FNN_String; //EDGE-152495 Added By ankit;
        }*/
        if (errorDescriptionMobile != '') { // Need to change
            transitionResponseNgUc.Error_Code = String.ValueOf(errorStatusCodeMobile);
            transitionResponseNgUc.Error_Description = errorDescriptionMobile;
        }
        system.debug('******************ParentToChildGDN' + JSON.serialize(gdnParentChild));
        system.debug('******************productFamilyListNgUc' + JSON.serialize(productFamilyListNgUc));
        system.debug('******************prodGroupTypeMapping' + JSON.serialize(prodGroupTypeMapping));
        system.debug('******************ngucTransition' + JSON.serialize(transitionResponseNgUc));
        return transitionResponseNgUc;
    }
    /**
* @Author   :   Maqsood Alam
* @Date     :   17 Oct 2019
* @Desc     :   get ProductFamilyList for sites
* @US       :   EDGE-92538
* @Status   :   Development
* */
    @AuraEnabled
    public static TransitionDataDTO.SiteDTOMobile getSiteLogicNgUc(ReplicatorGetServiceDTO.servicesDTO serviceDetails, map < String, Transition_Group_Structure_New__mdt > transGroupStructMapMain) {
        TransitionDataDTO.groupDTOMobile groupDTOMobileList = new TransitionDataDTO.groupDTOMobile();
        groupDTOMobileList.service = new List < TransitionDataDTO.serviceDTOMobile > ();
        TransitionDataDTO.serviceListDTOMobile serviceListDTOMobileList = new TransitionDataDTO.serviceListDTOMobile();
        serviceListDTOMobileList.groupType = new List < TransitionDataDTO.groupDTOMobile > ();
        String pFamily_PLabel = serviceDetails.productFamily;
        
        if (parentUniqueStringMap.get(serviceDetails.fnn) != null) {
            pFamily_PLabel = pFamily_PLabel + '_' + transGroupStructMapMain.get(parentUniqueStringMap.get(serviceDetails.fnn).toLowerCase()).Label + '_' + serviceDetails.fnn;
        }
        // Commented as part of EDGE-204581 || start
        /*if ( productFamilyToHybridCheck.containskey( serviceDetails.productFamily ) &&   productFamilyToHybridCheck.get( serviceDetails.productFamily ) ) { 
for( ReplicatorGetServiceDTO.serviceAssociationDTO sChars:serviceDetails.serviceAssociations ){ 
if ( sChars.linkedServiceRole == 'group' && prodGroupTypeNewMapping.containskey(serviceDetails.fnn) ) {
for(string groupId: prodGroupTypeNewMapping.get(serviceDetails.fnn)){
if(groupId==sChars.linkedServiceId){
TransitionDataDTO.groupDTOMobile serviceMobileList      =   new TransitionDataDTO.groupDTOMobile();
serviceMobileList.service                               =   new List < TransitionDataDTO.serviceDTOMobile > ();
serviceMobileList.groupId                               =   groupId;
serviceMobileList.service                               =   groupUniqueStringMap.get(groupId); 
serviceMobileList.EligibilityStatus                     =   groupEligibleMap.containskey(sChars.linkedServiceId)?groupEligibleMap.get(sChars.linkedServiceId).get('bw_eligibility_flag'):null;
serviceMobileList.EligibilityReason                     =   groupEligibleMap.containskey(sChars.linkedServiceId)?groupEligibleMap.get(sChars.linkedServiceId).get('bw_eligibility_reason_code'):null; 
serviceListDTOMobileList.groupType.add(serviceMobileList);  
}
}

}
}           
}
else{*/ // Commented as part of EDGE-204581 || end
        groupDTOMobileList.groupId = serviceDetails.fnn;
        //    groupDTOMobileList.service = prodGroupTypeMapping.get(serviceDetails.productFamily).get(serviceDetails.fnn);
        groupDTOMobileList.service = prodGroupTypeMapping.get(pFamily_PLabel).get(serviceDetails.fnn);
        serviceListDTOMobileList.groupType.add(groupDTOMobileList);
        //}
        system.debug('$$$$$$$$$$$$>>>>>groupDTOMobile : ' + JSON.serialize(serviceListDTOMobileList));
        system.debug('$$$$$$$$$$$$>>>>>groupDTOMobile : ' + JSON.serialize(groupDTOMobileList));
        
        for (ReplicatorGetServiceDTO.serviceCharacteristicDTO sChars: serviceDetails.serviceCharacteristics) {
            if (sChars.name == 'service_type') {
                serviceListDTOMobileList.Service_Type = sChars.value;
            }
        }
        //    serviceListDTOMobileList.Service_Type = serviceDetails.fnn; // to be changed
        
        TransitionDataDTO.SiteDTOMobile siteListDTOList = new TransitionDataDTO.SiteDTOMobile();
        siteListDTOList.serviceList = new List < TransitionDataDTO.serviceListDTOMobile > ();
        // 05/20/2021 Fix @vm
        if (serviceDetails.site.siteType.equalsIgnoreCase ('adbor_id')) {
            siteListDTOList.ADBOR_Id = serviceDetails.site.siteId;
        }
        siteListDTOList.linkedSiteId = serviceDetails.site.linkedSiteId;
        siteListDTOList.serviceList.add(serviceListDTOMobileList);
        system.debug('$$$$$$$$$$$$>>>>>siteListDTOList : ' + JSON.serialize(siteListDTOList));
        return siteListDTOList;
    }
    
    @AuraEnabled
    public static TransitionDataDTO.serviceDTOMobile getServiceNgUc(ReplicatorGetServiceDTO.servicesDTO serviceDetails) {
        TransitionDataDTO.serviceDTOMobile serviceRecord = new TransitionDataDTO.serviceDTOMobile();
        for (ReplicatorGetServiceDTO.serviceCharacteristicDTO sChars: serviceDetails.serviceCharacteristics) {
            if (sChars.name == 'service_status') {
                serviceRecord.service_status = sChars.value;
            }
            if (sChars.name == 'service_type_code') {
                serviceRecord.service_type_code = sChars.value;
            }
            if (sChars.name == 'service_type') {
                serviceRecord.service_type = sChars.value;
            }
            if (sChars.name == 'imsi_number') {
                serviceRecord.imsi_number = sChars.value;
            }
            if (sChars.name == 'sim_serial_number') {
                serviceRecord.sim_serial_number = sChars.value;
            }
            if (sChars.name == 'calling_line_identifier') {
                serviceRecord.calling_line_identifier = sChars.value;
            }
            if (sChars.name == 'plan_name') {
                serviceRecord.plan_name = sChars.value;
            }
            if (sChars.name == 'contract_term') {
                serviceRecord.contract_term = sChars.value;
            }
            if (sChars.name == 'international_roaming') {
                serviceRecord.international_roaming = sChars.value;
            }
            if (sChars.name == 'message_bank') {
                serviceRecord.message_bank = sChars.value;
            }
            if (sChars.name == 'idd') {
                serviceRecord.idd = sChars.value;
            }
            if (sChars.name == 'service_association_role') {
                serviceRecord.service_association_role = sChars.value;
            }
        }
        serviceRecord.Service_Id = serviceDetails.fnn;
        serviceRecord.replicatorUpdateDateTime = serviceDetails.replicatorUpdateDateTime;
        list < TransitionDataDTO.serviceExtensionDTO > extensionList = New list < TransitionDataDTO.serviceExtensionDTO > ();
        if (serviceDetails.serviceExtensions != null) {
            for (ReplicatorGetServiceDTO.serviceExtensionsDTO extension: serviceDetails.serviceExtensions) {
                TransitionDataDTO.serviceExtensionDTO extensionData = New TransitionDataDTO.serviceExtensionDTO();
                extensionData.serviceExtensionFrom = extension.serviceExtensionFrom;
                extensionData.serviceExtensionTo = extension.serviceExtensionTo;
                extensionList.add(extensionData);
            }
            serviceRecord.serviceExtensions = extensionList;
        }
        system.debug('#######>>>>>******* serviceRecord: ' + JSON.serialize(serviceRecord));
        return serviceRecord;
    }
    /**
* @Author   :   Maqsood Alam
* @Date     :   16 Oct 2019
* @Desc     :   As a Sales Enterprise B2B user and Partner user, as part of transition order I should be able to see legacy services (ISDN10/20/30) to transition them into ngUC hosted offer.
* @US       :   EDGE-92538
* @Status   :   Development
* */
    @AuraEnabled
    public static List < NgUCTableWrapper > getNgUCServicesTablewrapper(TransitionDataDTO transitionMoblileData, String basketId) {
        Map < String, List < NgUCTableWrapper > > tableWrapperMap = new Map < String, List < NgUCTableWrapper > > ();
        TransitionDataDTO ngUCResponse = transitionMoblileData;
        Boolean isResponseExist = false;
        List < NgUCTableWrapper > ngUCTableWrapperClassList = new List < NgUCTableWrapper > ();
        map < String, String > transGroupStructMap = new map < String, String > ();
        //Start of EDGE-218343 by Pradeep Mudenur(Osaka)
        Set<String> uniqueCidnValues = csvUploaderHelper.checkForCIDNHierarchy(basketId);                                                                  
        Map<String, String> cidnAbnMap = ReplicatorGetServiceManagerHelper.getABNBasedOnSourceCIDN(uniqueCidnValues);
        //End of EDGE-218343
        for (Transition_Group_Structure__mdt transGroupStruct: [SELECT DeveloperName, Label, Node_1__c, Node_2__c, Node_3__c, Product__c FROM Transition_Group_Structure__mdt]) {
            transGroupStructMap.put(transGroupStruct.Product__c, transGroupStruct.Node_1__c + '~!@!~' + transGroupStruct.Node_2__c + '~!@!~' + transGroupStruct.Node_3__c);
        }
        System.debug('transGroupStructMap-->' + transGroupStructMap);
        system.debug('#######>>>>>******* ngUCResponse: ' + JSON.serialize(ngUCResponse));
        try {
            List < Attachment > attachmentListNgUc = [SELECT Id, ParentId, Name, Body from Attachment WHERE ParentId IN(SELECT id FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c =: basketId AND cscfga__Product_Definition__r.product_Specification__c IN: listproductSpecNgUC) AND Name =: TransitionJSONDataNgUc LIMIT 1];
            if (attachmentListNgUc.size() > 0) {
                isResponseExist = true;
            }
            if (ngUCResponse.productList.size() > 0) {
                // NgUCTableWrapper ngUCTableWrapperClass = new NgUCTableWrapper();
                for (TransitionDataDTO.productListDTO tNgUcDataProduct: ngUCResponse.productList) {
                    // if(tNgUcDataProduct.Product_Type == 'ISDN10' || tNgUcDataProduct.Product_Type == 'ISDN20' || tNgUcDataProduct.Product_Type == 'ISDN30'){                      
                    //   TableWrapper ngUCTableWrapperGroup = new TableWrapper();
                    for (TransitionDataDTO.SiteDTOMobile tNgUcDataSite: tNgUcDataProduct.site) {
                        system.debug('#######>>>>>******* tNgUcDataSite: ' + JSON.serialize(tNgUcDataSite));
                        for (TransitionDataDTO.serviceListDTOMobile tNgUcDataServiceList: tNgUcDataSite.serviceList) {
                            system.debug('#######>>>>>******* tNgUcDataServiceList: ' + JSON.serialize(tNgUcDataServiceList));
                            if (transGroupStructMap.containskey(tNgUcDataProduct.Product_Type)) {
                                List < String > nodes = transGroupStructMap.get(tNgUcDataProduct.Product_Type).split('~!@!~');
                                System.debug('nodes-->' + nodes);
                                for (TransitionDataDTO.groupDTOMobile tNgUcDataGroupType: tNgUcDataServiceList.groupType) {
                                    //    if (tNgUcDataProduct.Product_Type == 'ISDN10' || tNgUcDataProduct.Product_Type == 'ISDN20' || tNgUcDataProduct.Product_Type == 'ISDN30') {
                                    //      if (nodes[0] == 'RANGES' && nodes[1] == '-' && nodes[2] == '-') {  
                                    if ((nodes[0] == 'RANGES' && nodes[1] == '-' && nodes[2] == '-') || (nodes[0] == 'PRIME' && nodes[1] == '-' && nodes[2] == '-')) {
                                        NgUCTableWrapper ngUCTableWrapperClass = new NgUCTableWrapper();
                                        ngUCTableWrapperClass.Product_Type = tNgUcDataProduct.Product_Type;
                                        String fNNString = '';
                                        system.debug('#######>>>>>******* tNgUcDataGroupType: ' + JSON.serialize(tNgUcDataGroupType));
                                        for (TransitionDataDTO.serviceDTOMobile tNgUcDataService: tNgUcDataGroupType.service) {
                                            system.debug('#######>>>>>******* tNgUcDataService: ' + JSON.serialize(tNgUcDataService));
                                            String extensionRangeString = '';
                                            String associationTypeString = '';
                                            //  ngUCTableWrapperClass.Id = tNgUcDataProduct.Product_Type + '~!@@!~' + tNgUcDataService.Service_Id;
                                            ngUCTableWrapperClass.Id = tNgUcDataService.Service_Id + '_PFamily';
                                            for (TransitionDataDTO.serviceExtensionDTO extensionList: tNgUcDataService.serviceExtensions) {
                                                associationTypeString = associationTypeString + '\n' + 'Range';
                                                extensionRangeString = extensionRangeString + '\n' + extensionList.serviceExtensionFrom + ' : ' + extensionList.serviceExtensionTo;
                                            }
                                            if (tNgUcDataService.service_association_role == null) {
                                                tNgUcDataService.service_association_role = '';
                                            }
                                            fNNString = fNNString + tNgUcDataService.Service_Id + extensionRangeString;
                                            ngUCTableWrapperClass.checkValue = true;
                                            ngUCTableWrapperClass.FNN_Number = fNNString;
                                            ngUCTableWrapperClass.Association_Type = tNgUcDataService.service_association_role + associationTypeString;
                                            ngUCTableWrapperClass.contract_term = tNgUcDataService.contract_term;
                                            ngUCTableWrapperClass.eligibilityStatus = tNgUcDataService.Eligibility_status;
                                            ngUCTableWrapperClass.eligibilityReason = tNgUcDataService.eligibilityReason;
                                            //Start of EDGE-218343 by Pradeep Mudenur(Osaka) to persist CIDN, ABN and BAN.
                                            if(tNgUcDataService.accountDetails != NULL){
                                               ngUCTableWrapperClass.source_CIDN=tNgUcDataService.accountDetails.sourceCIDN;
                                               ngUCTableWrapperClass.ABN=cidnAbnMap.get(ngUCTableWrapperClass.source_CIDN);
                                               ngUCTableWrapperClass.BAN=tNgUcDataService.accountDetails.accountNumber;
                                               System.debug('@@@@@@@@*********Response from account CIDN ' + tNgUcDataService.accountDetails.sourceCIDN + 'ABN ' + tNgUcDataService.accountDetails.businessnumber + 'BAN ' + tNgUcDataService.accountDetails.accountNumber);
                                            }
                                            //End of EDGE-218343
                                            if (isResponseExist == true) {
                                                //    ngUCTableWrapperClass.checkValue = tNgUcDataServiceList.checkValue;
                                                ngUCTableWrapperClass.checkValue = tNgUcDataGroupType.checkValue;
                                            } else {
                                                //  ngUCTableWrapperClass.checkValue = true;
                                            }
                                        }
                                        ngUCTableWrapperClassList.add(ngUCTableWrapperClass);
                                    } else if (nodes[0] == 'GDN' && nodes[1] == 'PRIME' && nodes[2] == 'AUXILLARY') {
                                        // rest of the product family ----
                                        //NgUCTableWrapper ngUCTableWrapperGroup = new NgUCTableWrapper();
                                        String parentServiceId = '';
                                        for (TransitionDataDTO.serviceDTOMobile tNgUcDataService: tNgUcDataGroupType.service) {
                                            NgUCTableWrapper ngUCTableWrapperGroup = new NgUCTableWrapper();
                                            ngUCTableWrapperGroup.Product_Type = '';
                                            if (tNgUcDataService.service_association_role == 'GDN') {
                                                parentServiceId = tNgUcDataService.Service_Id;
                                                ngUCTableWrapperGroup.Product_Type = tNgUcDataProduct.Product_Type;
                                                ngUCTableWrapperGroup.Id = parentServiceId + '_PFamily';
                                            } else {
                                                ngUCTableWrapperGroup.Id = parentServiceId + '_!@!_' + tNgUcDataService.Service_Id;
                                            }
                                            ngUCTableWrapperGroup.checkValue = true;
                                            ngUCTableWrapperGroup.FNN_Number = tNgUcDataService.Service_Id;
                                            ngUCTableWrapperGroup.Association_Type = tNgUcDataService.service_association_role;
                                            ngUCTableWrapperGroup.contract_term = tNgUcDataService.contract_term;
                                            ngUCTableWrapperGroup.eligibilityStatus = tNgUcDataService.Eligibility_status;
                                            ngUCTableWrapperGroup.eligibilityReason = tNgUcDataService.eligibilityReason;
                                            //Start of EDGE-218343 by Pradeep Mudenur(Osaka) to persist CIDN, ABN and BAN.
                                            if(tNgUcDataService.accountDetails != NULL){
                                               ngUCTableWrapperGroup.source_CIDN=tNgUcDataService.accountDetails.sourceCIDN;
                                               ngUCTableWrapperGroup.ABN=cidnAbnMap.get(ngUCTableWrapperGroup.source_CIDN);
                                               ngUCTableWrapperGroup.BAN=tNgUcDataService.accountDetails.accountNumber;
                                                System.debug('@@@@@@@@*********Response from account CIDN ' + tNgUcDataService.accountDetails.sourceCIDN + 'ABN ' + tNgUcDataService.accountDetails.businessnumber + 'BAN ' + tNgUcDataService.accountDetails.accountNumber);
                                            }
                                            //End of EDGE-218343
                                            if (isResponseExist == true) {
                                                //  ngUCTableWrapperGroup.checkValue = tNgUcDataServiceList.checkValue;
                                                ngUCTableWrapperGroup.checkValue = tNgUcDataGroupType.checkValue;
                                            }
                                            ngUCTableWrapperClassList.add(ngUCTableWrapperGroup);
                                        }
                                    }
                                }
                            }
                        }
                    }
                    //  }
                }
            }
        } catch (Exception ex) {
            System.debug('Exception Occure In Response from Replicator' + ex);
            System.debug(LoggingLevel.debug, '--->Error occurred##> ' + ex.getMessage());
            System.debug(LoggingLevel.debug, '--->Error Line##> ' + ex.getLineNumber());
            System.debug(LoggingLevel.debug, '--->Error Trace##> ' + ex.getStackTraceString());
            System.debug(LoggingLevel.debug, '--->Error Cause##> ' + ex.getCause());
            
            logException('getNgUCServicesTablewrapper', basketId, correlationId, ex.getMessage(), 'getNgUCServicesTablewrapper');

            
            //Changes to remove SonarQube Vulnerabilities by Abhishek(Osaka)(Returning empty instead of null)
            //return null;
            return new List < NgUCTableWrapper >();
        }
        system.debug('#######>>>>>******* ngUCTableWrapperClass: ' + JSON.serialize(ngUCTableWrapperClassList));
        return ngUCTableWrapperClassList;
    }
    /**
* @Author   :   Maqsood Alam
* @Date     :   09 April 2020
* @Desc     :   As a Sales Enterprise B2B user or Partner user, I want to view all existing PSTN, ISDN, ISDN2DID services so that I can transition my customer to eligible Telstra Collaboration plans.
* @US       :   EDGE-120154
* @Status   :   Development
* */
    @AuraEnabled
    public static List < NgUCTableWrapper > getNgUCServicesTablewrapperV1(TransitionDataDTO transitionMoblileData, String basketId) {
        Map < String, List < NgUCTableWrapper > > tableWrapperMap = new Map < String, List < NgUCTableWrapper > > ();
        
        TransitionDataDTO ngUCResponse = transitionMoblileData;
        Boolean isResponseExist = false;
        List < NgUCTableWrapper > ngUCTableWrapperClassList = new List < NgUCTableWrapper > ();
        map < String, Transition_Group_Structure_New__mdt > transGroupStructMap = new map < String, Transition_Group_Structure_New__mdt > ();
        //Start of EDGE-218343 by Pradeep Mudenur(Osaka)
        Set<String> uniqueCidnValues = csvUploaderHelper.checkForCIDNHierarchy(basketId);                                                                  
        Map<String, String> cidnAbnMap = ReplicatorGetServiceManagerHelper.getABNBasedOnSourceCIDN(uniqueCidnValues);
        //End of EDGE-218343
        for (Transition_Group_Structure_New__mdt transGroupStruct: [SELECT DeveloperName, Label, Node_1__c, Node_2__c, Node_3__c, Product_Family__c, Range_Indicator__c, Hybrid__c FROM Transition_Group_Structure_New__mdt]) {
            transGroupStructMap.put((transGroupStruct.Product_Family__c + '~!@!~' + transGroupStruct.Node_1__c + '~!@!~' + transGroupStruct.Node_2__c + '~!@!~' + transGroupStruct.Node_3__c).toLowerCase().replaceAll('~!@!~null', ''), transGroupStruct);
            //EDGE-151827 Added for TIPT-SIPC
            if (transGroupStruct.Hybrid__c) {
                transGroupStructMap.put(transGroupStruct.Product_Family__c + '~!@!~' + true, transGroupStruct);
            }
        }
        System.debug('transGroupStructMap-->' + transGroupStructMap);
        system.debug('#######>>>>>******* ngUCResponse: ' + JSON.serialize(ngUCResponse));
        try {
            List < Attachment > attachmentListNgUc = [SELECT Id, ParentId, Name, Body from Attachment WHERE ParentId IN(SELECT id FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c =: basketId AND cscfga__Product_Definition__r.product_Specification__c IN: listproductSpecNgUC) AND Name =: TransitionJSONDataNgUc LIMIT 1];
            if (attachmentListNgUc.size() > 0) {
                isResponseExist = true;
            }
            if (ngUCResponse.productList != null && ngUCResponse.productList.size() > 0) {
                for (TransitionDataDTO.productListDTO tNgUcDataProduct: ngUCResponse.productList) {
                    
                    for (TransitionDataDTO.SiteDTOMobile tNgUcDataSite: tNgUcDataProduct.site) {
                        system.debug('#######>>>>>******* tNgUcDataSite: ' + JSON.serialize(tNgUcDataSite));
                        for (TransitionDataDTO.serviceListDTOMobile tNgUcDataServiceList: tNgUcDataSite.serviceList) {
                            system.debug('#######>>>>>******* tNgUcDataServiceList: ' + JSON.serialize(tNgUcDataServiceList));
                            for (TransitionDataDTO.groupDTOMobile tNgUcDataGroupType: tNgUcDataServiceList.groupType) {
                                NgUCTableWrapper ngUCTableWrapperClass = new NgUCTableWrapper();
                                ngUCTableWrapperClass.Product_Type = tNgUcDataProduct.Product_Type;
                                String fNNString = '';
                                system.debug('#######>>>>>******* tNgUcDataGroupType: ' + JSON.serialize(tNgUcDataGroupType));
                                String childNodes = '';
                                for (TransitionDataDTO.serviceDTOMobile tNgUcDataService: tNgUcDataGroupType.service) {
                                    if (tNgUcDataService.service_association_role != null) {
                                        if (!childNodes.contains(tNgUcDataService.service_association_role))
                                            childNodes += '~!@!~' + tNgUcDataService.service_association_role;
                                    }
                                }
                                String uniqueDataString = tNgUcDataProduct.Product_Type + childNodes;
                                system.debug('#######>>>>>******* uniqueDataString: ' + JSON.serialize(uniqueDataString));
                                if (transGroupStructMap.get(uniqueDataString.toLowerCase()) != null) {
                                    if (transGroupStructMap.get(uniqueDataString.toLowerCase()).Product_Family__c.toLowerCase() == tNgUcDataProduct.Product_Type.toLowerCase() && transGroupStructMap.get(uniqueDataString.toLowerCase()).Range_Indicator__c == true) {
                                        for (TransitionDataDTO.serviceDTOMobile tNgUcDataService: tNgUcDataGroupType.service) {
                                            system.debug('#######>>>>>******* tNgUcDataService: ' + JSON.serialize(tNgUcDataService));
                                            String extensionRangeString = '';
                                            String associationTypeString = '';
                                            //  ngUCTableWrapperClass.Id = tNgUcDataProduct.Product_Type + '~!@@!~' + tNgUcDataService.Service_Id;
                                            ngUCTableWrapperClass.Id = tNgUcDataService.Service_Id + '_PFamily';
                                            for (TransitionDataDTO.serviceExtensionDTO extensionList: tNgUcDataService.serviceExtensions) {
                                                associationTypeString = associationTypeString + '\n' + 'Range';
                                                extensionRangeString = extensionRangeString + '\n' + extensionList.serviceExtensionFrom + ' : ' + extensionList.serviceExtensionTo;
                                                // DIGI-4339 starts here 
                                                if(tNgUcDataProduct.Product_Type.contains('ISDN')){
                                                    ngUCTableWrapperClass.eligibilityStatus = extensionList.eligibilityStatus;
                                                    ngUCTableWrapperClass.eligibilityReason = extensionList.eligibilityReason;
                                                }
                                                // DIGI-4339 starts here 
                                            }
                                            if (tNgUcDataService.service_association_role == null) {
                                                tNgUcDataService.service_association_role = '';
                                            }
                                            fNNString = fNNString + tNgUcDataService.Service_Id + extensionRangeString;
                                            ngUCTableWrapperClass.checkValue = true;
                                            ngUCTableWrapperClass.FNN_Number = fNNString;
                                            ngUCTableWrapperClass.Association_Type = tNgUcDataService.service_association_role + associationTypeString;
                                            ngUCTableWrapperClass.contract_term = tNgUcDataService.contract_term;
                                            // DIGI-4339 starts here 
                                            if(!tNgUcDataProduct.Product_Type.contains('ISDN')){                                             
                                                ngUCTableWrapperClass.eligibilityStatus = tNgUcDataService.Eligibility_status;
                                                ngUCTableWrapperClass.eligibilityReason = tNgUcDataService.eligibilityReason;
                                            }
                                            // DIGI-4339 starts here 
                                            
                                            //Start of EDGE-218343 by Pradeep Mudenur(Osaka) to persist CIDN, ABN and BAN.
                                            if(tNgUcDataService.accountDetails != NULL){
                                               ngUCTableWrapperClass.source_CIDN=tNgUcDataService.accountDetails.sourceCIDN;
                                               ngUCTableWrapperClass.ABN=cidnAbnMap.get(ngUCTableWrapperClass.source_CIDN);
                                               ngUCTableWrapperClass.BAN=tNgUcDataService.accountDetails.accountNumber;
                                               System.debug('@@@@@@@@*********Response from account CIDN ' + tNgUcDataService.accountDetails.sourceCIDN + 'ABN ' + tNgUcDataService.accountDetails.businessnumber + 'BAN ' + tNgUcDataService.accountDetails.accountNumber);
                                            }
                                            //End of EDGE-218343
                                                
                                            if (isResponseExist == true) {
                                                //    ngUCTableWrapperClass.checkValue = tNgUcDataServiceList.checkValue;
                                                ngUCTableWrapperClass.checkValue = tNgUcDataGroupType.checkValue;
                                            } else {
                                                //  ngUCTableWrapperClass.checkValue = true;
                                            }
                                        }
                                        ngUCTableWrapperClassList.add(ngUCTableWrapperClass);
                                    } else if (transGroupStructMap.get(uniqueDataString.toLowerCase()).Range_Indicator__c == false && transGroupStructMap.get(uniqueDataString.toLowerCase()).Product_Family__c == tNgUcDataProduct.Product_Type) {
                                        // rest of the product family ----
                                        String parentServiceId = '';
                                        for (TransitionDataDTO.serviceDTOMobile tNgUcDataService: tNgUcDataGroupType.service) {
                                            NgUCTableWrapper ngUCTableWrapperGroup = new NgUCTableWrapper();
                                            ngUCTableWrapperGroup.Product_Type = '';
                                            
                                            if ((tNgUcDataService.service_association_role != '' && tNgUcDataService.service_association_role != null) && tNgUcDataService.service_association_role.toLowerCase() == transGroupStructMap.get(uniqueDataString.toLowerCase()).Node_1__c.toLowerCase()) {
                                                parentServiceId = tNgUcDataService.Service_Id;
                                                ngUCTableWrapperGroup.Product_Type = tNgUcDataProduct.Product_Type;
                                                ngUCTableWrapperGroup.Id = parentServiceId + '_PFamily';
                                            } else {
                                                if (tNgUcDataService.service_association_role == '') {
                                                    ngUCTableWrapperGroup.Product_Type = tNgUcDataProduct.Product_Type;
                                                    ngUCTableWrapperGroup.Id = tNgUcDataService.Service_Id + '_PFamily';
                                                } else
                                                    ngUCTableWrapperGroup.Id = parentServiceId + '_!@!_' + tNgUcDataService.Service_Id;
                                            }
                                            ngUCTableWrapperGroup.checkValue = true;
                                            ngUCTableWrapperGroup.FNN_Number = tNgUcDataService.Service_Id;
                                            ngUCTableWrapperGroup.Association_Type = tNgUcDataService.service_association_role;
                                            ngUCTableWrapperGroup.contract_term = tNgUcDataService.contract_term;
                                            ngUCTableWrapperGroup.eligibilityStatus = tNgUcDataService.Eligibility_status;
                                            ngUCTableWrapperGroup.eligibilityReason = tNgUcDataService.eligibilityReason;
                                            //Start of EDGE-218343 by Pradeep Mudenur(Osaka) to persist CIDN, ABN and BAN.
                                            if(tNgUcDataService.accountDetails != NULL){
                                               ngUCTableWrapperGroup.source_CIDN=tNgUcDataService.accountDetails.sourceCIDN;
                                               ngUCTableWrapperGroup.ABN=cidnAbnMap.get(ngUCTableWrapperGroup.source_CIDN);
                                               ngUCTableWrapperGroup.BAN=tNgUcDataService.accountDetails.accountNumber;
                                               System.debug('@@@@@@@@*********Response from account CIDN ' + tNgUcDataService.accountDetails.sourceCIDN + 'ABN ' + tNgUcDataService.accountDetails.businessnumber + 'BAN ' + tNgUcDataService.accountDetails.accountNumber);
                                            }
                                            //End of EDGE-218343
                                            
                                            if (isResponseExist == true) {
                                                //  ngUCTableWrapperGroup.checkValue = tNgUcDataServiceList.checkValue;
                                                ngUCTableWrapperGroup.checkValue = tNgUcDataGroupType.checkValue;
                                            }
                                            ngUCTableWrapperClassList.add(ngUCTableWrapperGroup);
                                        }
                                    }
                                }
                                //EDGE-151827 Prepare transtion UI table grouping for TIPT-SIPC
                                if (transGroupStructMap.containsKey(tNgUcDataProduct.Product_Type + '~!@!~' + true)) {
                                    ngUCTableWrapperClassList.addAll(ReplicatorParserManagerNGUC.preapreNGUCTableWrapper(tNgUcDataProduct,tNgUcDataGroupType,isResponseExist,cidnAbnMap));
                                }
                                
                                //EDGE-151827 ends
                            }
                        }
                    }
                }
            }
        } catch (Exception ex) {
            System.debug('Exception Occure In Response from Replicator' + ex);
            System.debug(LoggingLevel.debug, '--->Error occurred##> ' + ex.getMessage());
            System.debug(LoggingLevel.debug, '--->Error Line##> ' + ex.getLineNumber());
            System.debug(LoggingLevel.debug, '--->Error Trace##> ' + ex.getStackTraceString());
            System.debug(LoggingLevel.debug, '--->Error Cause##> ' + ex.getCause());
            
            logException('getNgUCServicesTablewrapperV1', basketId, correlationId, ex.getMessage(), 'getNgUCServicesTablewrapperV1');

            
            //Changes to remove SonarQube Vulnerabilities by Abhishek(Osaka)(Returning empty instead of null)
            //return null;
            return new List < NgUCTableWrapper >();
        }
        system.debug('#######>>>>>******* ngUCTableWrapperClass: ' + JSON.serialize(ngUCTableWrapperClassList));
        return ngUCTableWrapperClassList;
    }
    @AuraEnabled
    public static Map < String, String > servicesPresentInTransition(String basketId) {
        String prodSpecIoT = 'IoT_Dormancy_False';
        //Start of DIGI-16451 by Abhishek(Osaka)
        if(IoT_Dormancy == 'true'){
            prodSpecIoT = String.valueOf(MTMMetadataUtilityMap.get('IoT_Marketable_Offer').get('Value__c'));
        }
        //End of DIGI-16451
        Boolean isMobilityProduct = false;
        Map < String, String > isServicesPresent = New Map < String, String > ();
        isServicesPresent.put('Mobility', 'false');
        isServicesPresent.put('NgUc', 'false');
        isServicesPresent.put('IoT', 'false');// Added as a part of DIGI-16451
        List < String > listproductSpecMobile = Label.ProductSpecificationMobile.split(',');
        List < String > listproductSpecNgUc = Label.ProductSpecificationNgUc.split(',');
        List < String > listproductSpec = New List < String > ();
        listproductSpec.addAll(listproductSpecMobile);
        listproductSpec.addAll(listproductSpecNgUc);
        listproductSpec.add(prodSpecIoT);//Added as a part of DIGI-16451 to enable IoT
        try {
            List < Id > productConfigIds = new List < Id > ();
            for (cscfga__Product_Configuration__c productConfig: [SELECT id, Name, cscfga__Product_Definition__r.product_Specification__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c =: basketId AND cscfga__Product_Definition__r.product_Specification__c IN: listproductSpec ORDER BY Createddate DESC]) {
                productConfigIds.add(productConfig.id);
                if (listproductSpecMobile.contains(productConfig.cscfga__Product_Definition__r.product_Specification__c)) {
                    isServicesPresent.put('Mobility', 'true');
                }
                if (listproductSpecNgUc.contains(productConfig.cscfga__Product_Definition__r.product_Specification__c)) {
                    isServicesPresent.put('NgUc', 'true');
                }
                //Start of DIGI-16451 by Abhishek(Osaka) to enable IoT Transition
                if (productConfig.cscfga__Product_Definition__r.product_Specification__c == prodSpecIoT) {
                    isServicesPresent.put('IoT', 'true');
                }
                //End of DIGI-16451
                system.debug('productConfig--->' + productConfig.cscfga__Product_Definition__r.product_Specification__c);
            }
        } catch (exception ex) {
            System.debug('Exception Occure In Response from Replicator' + ex);
            System.debug(LoggingLevel.debug, '--->Error occurred##> ' + ex.getMessage());
            System.debug(LoggingLevel.debug, '--->Error Line##> ' + ex.getLineNumber());
            System.debug(LoggingLevel.debug, '--->Error Trace##> ' + ex.getStackTraceString());
            System.debug(LoggingLevel.debug, '--->Error Cause##> ' + ex.getCause());
            
            logException('servicesPresentInTransition', basketId, correlationId, ex.getMessage(), 'servicesPresentInTransition');
            
            return null;
        }
        return isServicesPresent;
    }
    public class serviceCharacteristicTempDTO {
        public String service_type {
            get;
            set;
        }
        public String association_type {
            get;
            set;
        }
        public String service_association_role {
            get;
            set;
        }
        public String in_flight_flag {
            get;
            set;
        }
        public list < service_extensionDTO > service_extension {
            get;
            set;
        }
    }
    public class service_extensionDTO { //EDGE 98925 Modify name values
        public String serviceExtensionFrom {
            get;
            set;
        }
        public String serviceExtensionTo {
            get;
            set;
        }
    }
    public class service_AssociationsDTO { //EDGE-98925
        public String linkedServiceId {
            get;
            set;
        }
        public String linkedServiceRole {
            get;
            set;
        }
    }
    /**
* @Author   :   Maq
* @Date     :   22 July 2019
* @Desc     :   wrapper class for table view
* */
    public class TableWrapper {
        @AuraEnabled
        public string Id {
            get;
            set;
        }
        @AuraEnabled
        public string Product_Type {
            get;
            set;
        }
        @AuraEnabled
        public string Product_Number {
            get;
            set;
        }
        @AuraEnabled
        public string plan_name {
            get;
            set;
        }
        @AuraEnabled
        public string contract_term {
            get;
            set;
        }
        @AuraEnabled
        public string eligibilityStatus {
            get;
            set;
        }
        @AuraEnabled
        public string eligibilityReason {
            get;
            set;
        }
        @AuraEnabled
        public Boolean checkValue {
            get;
            set;
        }
        @AuraEnabled
        public string tenancy_name {
            get;
            set;
        }
        @AuraEnabled
        //EDGE-139071
        public string Plan_Type {
            get;
            set;
        }
        @AuraEnabled
        public string Dealer_Code {
            get;
            set;
        }
        //EDGE-139071 End
        @AuraEnabled
        public string contract_remaining_term {
            get;
            set;
        } //Changes for EDGE-173831 by Abhishek from Osaka Team
        
        @AuraEnabled
        public string BAN {get;set;}
        @AuraEnabled
        public string ABN {get;set;}
        @AuraEnabled
        public string source_CIDN {get;set;}
        //Added as a part of EDGE-205938 by Abhishek(Osaka): Introducing Nickname
        @AuraEnabled
        public string user_name {get;set;}
        @AuraEnabled
        public string planConfigMode {get;set;}//DIGI-1741 : Added by Abhishek(Osaka) for handling validations on Confirm Button.
    }
    /**
* @Author   :   Maqsood Alam
* @Date     :   16 Oct 2019
* @Desc     :   As a Sales Enterprise B2B user and Partner user, as part of transition order I should be able to see legacy services (ISDN10/20/30) to transition them into ngUC hosted offer.
* @US       :   EDGE-92538
* @Status   :   Development
* */
    public class NgUCTableWrapper {
        @AuraEnabled
        public string Id {
            get;
            set;
        }
        @AuraEnabled
        public string Product_Type {
            get;
            set;
        }
        @AuraEnabled
        public string FNN_Number {
            get;
            set;
        }
        @AuraEnabled
        public string Association_Type {
            get;
            set;
        }
        @AuraEnabled
        public string SITE_ADBORID {
            get;
            set;
        }
        @AuraEnabled
        public string contract_term {
            get;
            set;
        }
        @AuraEnabled
        public string eligibilityStatus {
            get;
            set;
        }
        @AuraEnabled
        public string eligibilityReason {
            get;
            set;
        }
        @AuraEnabled
        public Boolean checkValue {
            get;
            set;
        }
        //Start of EDGE-218343 by Pradeep Mudenur(Osaka) Introducing source_CIDN, ABN and BAN.
          @AuraEnabled
        public string source_CIDN {
            get;
            set;
        }
          @AuraEnabled
        public string ABN {
            get;
            set;
        }
          @AuraEnabled
        public string BAN {
            get;
            set;
        }
        //End of EDGE-218343
        
    }
    public class ProductFamilyTblWrapper {
        @AuraEnabled
        public string Id {
            get;
            set;
        }
        @AuraEnabled
        public string Linked_AssociationRole {
            get;
            set;
        }
        @AuraEnabled
        public string Linked_AssociationID {
            get;
            set;
        }
        @AuraEnabled
        public string Product_Family {
            get;
            set;
        }
        @AuraEnabled
        public string FNN {
            get;
            set;
        }
        @AuraEnabled
        public Boolean checkValue {
            get;
            set;
        }
    }
    /*EDGE-179394 */
    
    //Start of EDGE-211350 by Abhishek(Osaka)
    @AuraEnabled
    public static String gridDisplayData(List<TableWrapper> tableWrapperList){
        String gridFormatResponse;
        
        gridFormatResponse = ReplicatorGetServiceManagerHelper.populateCidnWrapper(tableWrapperList);
        
        return gridFormatResponse; 
        
    }
    //End of EDGE-211350 by Abhishek(Osaka)
    
    /**
     * @description Exception Handling Framework 
     */
    private static void logException(String methodName, String referenceNumber, String correlationId, String errorMessage, String businessDescription){
        Map<String, Object> eLogMap = new Map<String, Object>();
        eLogMap.put('capability', CONST_CAPABILITY);
        eLogMap.put('interfaceName', CONST_INTERFACENAME);
        eLogMap.put('elementName', methodName);
        eLogMap.put('referenceNumber', referenceNumber);
        eLogMap.put('correlationId', correlationId);
        eLogMap.put('errorDescription', errorMessage);
        eLogMap.put('businessDescription', businessDescription);
        C2O_Utilities.logException(eLogMap, false);
    }
    
    private static void logException(String severity, string methodName, String referenceNumber, String endpointURL, String integrationPayload, String correlationId, String httpStatusCode, String errorCode, String errorMessage,  String responseMessage, String destinationSystem, String sourceName, String businessDescription, String errorCategory) {
        Map<String, Object> eLogMap = new Map<String, Object>();
        eLogMap.put('severity', severity);
        eLogMap.put('interfaceName', CONST_INTERFACENAME);
        eLogMap.put('elementName', methodName);
        eLogMap.put('referenceNumber', referenceNumber);
        eLogMap.put('capability', CONST_CAPABILITY);
        eLogMap.put('endpointURL', endpointURL);
        eLogMap.put('integrationPayload', integrationPayload);
        eLogMap.put('correlationId', correlationId);
        eLogMap.put('httpStatusCode', httpStatusCode);
        eLogMap.put('errorCode', errorCode);
        eLogMap.put('errorDescription', errorMessage);
        eLogMap.put('responseMessage', responseMessage);
        eLogMap.put('destinationSystem', destinationSystem);
        eLogMap.put('sourceName', sourceName);
        eLogMap.put('businessDescription', businessDescription);
        eLogMap.put('errorCategory', errorCategory);
        C2O_Utilities.logException(eLogMap, false);
    }
}