/*
===============================================================================================================================
Class : CompUtilityReplicatorManager
Developer Name : Shubhi
Test Class : CompUtilityReplicatorManagerTest
===============================================================================================================================
Sr.No.    Developer Name        Date          Story Description
1.        Shubhi ,Harsh,Rohit   21/3/2019     CheckEligibilitySolution (EDGE-66570 ,EDGE-72453,EDGE-73521)
2.        Maq                   25/05/2019    New JSON response from replicator (EDGE-75696, EDGE-85840, EDGE-84055)
3.        Shresth               2/03/21       DPG-4072
4.        Dheeraj Bhatt         10 Aug 2020   DIGI-1940 -Enable Chatter notifications to Opportunity Owner upon initiation/completion/Failure of auto configuration
===============================================================================================================================
*/
public with sharing class CompUtilityReplicatorManager {
    
    public static String productSpecMobile = Label.ProductSpecificationMobile;
    public static List<String> listproductSpecMobile = productSpecMobile.split(',');
    public static List < String > listproductSpecNgUc = Label.ProductSpecificationNgUc.split(',');
    //Manoj : nguc
    public static final String prdNguc= 'nguc';
    public static final String prdCwp= 'cwp';
    //Preeti : Feedback Case Creation
    public static string DIGITIZED_ORDERING = 'Digitised Ordering Issue';
    public static string CHECKPOINT_TRANSITION ='Checkpoint/ Transition';
    public static string CASE_PRIORITY ='High';
    public static string CASE_STATUS ='New';
    public static string CASE_SEVERITY ='Medium';
    public static string CASE_ORIGIN ='Feedback';
    public static String TransitionJSONDataMobile = Label.MobileTransitionName;
    public static String TransitionJSONDataNgUc = Label.NgUcTransitionName;
    public static Map<String,String> serviceIdToProductCodeMap = new Map<String,String>();
    //Start of DIGI-33080 by Abhishek(Osaka) to introduce IoT for Check Eligiblity
    public static Map<string,Sobject> MTMMetadataUtilityMap = ConstantMetadataUtility.getConstantMetadataUtilityRecords('MTM_Metadata_Utility__mdt');
    public static String IoT_Dormancy = String.valueOf(MTMMetadataUtilityMap.get('IoT_Dormancy').get('Value__c'));
    //End of DIGI-33080

    // Default Constructor
    public CompUtilityReplicatorManager(){}

    /**Create Map of ProductBasketSiteDataObject with AdborId to make data for Replicator Call*/
    @AuraEnabled
    public static Map<String,ProductBasketSiteDataObject> fetchSiteFromBasketControllerMap(String basketId){
        try{
            system.debug('basketId>>>' + basketId);
            String cidn = getBasket(basketId).csbb__Account__r.CIDN__c;
            system.debug('---------------->>><<<'+cidn);
            Map<String,ProductBasketSiteDataObject> pbsdMap = new Map<String,ProductBasketSiteDataObject>();
            
            /*-- Going forward, Team Eureka going to remove PCRtoPCFlag custom setting once eveything moved to PC from PCR --*/
            String PCRtoPCFlag = EnvironmentVariable__c.getValues('PCRtoPCFlag').Value__c;
            if(PCRtoPCFlag == 'true'){
            //Vimal: Changes to move away from PCR records and store and read data from PC
            //List<csbb__Product_Configuration_Request__c> pcrList = [select id, Product_Configuration_Name__c,csbb__Product_Configuration__c,csbb__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c, csbb__Optionals__c, csbb__Product_Basket__c,csbb__Offer__r.name, Type__c from csbb__Product_Configuration_Request__c where csbb__Product_Basket__c =: basketId];
            
            // added for Solution console for PCR to PC change
            List<cscfga__Product_Configuration__c> lstProdConfig = [select Id,isEligibleForTransition__c,cscfga__Root_Configuration__c, cscfga__Description__c, cscfga__Quantity__c, Type__c, csordtelcoa__Replaced_Product_Configuration__c, Name from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =: basketId AND Name = 'IP Site'];
            
            system.debug('lstProdConfig--->'+lstProdConfig);
            
            List<cscfga__Attribute__c> lstAttribute = [select Name, cscfga__Is_Line_Item__c, Quantity__c,cscfga__Product_Configuration__c, cscfga__Product_Configuration__r.cscfga__Description__c, cscfga__Product_Configuration__r.cscfga__Root_Configuration__c, cscfga__value__c from cscfga__Attribute__c where cscfga__Product_Configuration__r.cscfga__Product_Basket__c =: basketId and (cscfga__Is_Line_Item__c = true OR Name IN ('Site Name','Site Address','Site ID','AdborID')) ];
            List<String> adboridList=new List<String>();
            for(cscfga__Attribute__c att:lstAttribute){
                if(att.Name=='AdborID'){
                    adboridList.add(att.cscfga__value__c);
                }               
            }
            system.debug('@@lstAttribute-->'+lstAttribute);
            
            system.debug('@@@adboridList@@@'+adboridList);
            Map<String,cscrm__Address__c> AddressSiteMap =new Map<String,cscrm__Address__c>();
            for(cscrm__Address__c add:[Select id,cscrm__State_Province__c,Locality__c,Address_ID__c from cscrm__Address__c where Address_ID__c IN:adboridList]){
                AddressSiteMap.put(add.Address_ID__c,add);
            }

            for(cscfga__Product_Configuration__c pc : lstProdConfig){
                if(pc.Name == 'IP Site'){
                    system.debug('pc-->'+pc);
                    //if((pcr.csbb__Offer__r.name == 'Connected Workplace' || pcr.csbb__Offer__r.name == 'Connected Workplace Package' ) && pcr.csbb__Optionals__c != null){     
                    //JSONParser parser = JSON.createParser(pcr.csbb__Optionals__c);
                    String siteName = null;
                    String adBorId = null;
                    String siteAddress = null; 
                    String state=null;
                    String locality=null;
                    List<ProductBasketSiteDataObject.ProductConfiguration> lstProdConfigDetails = new List<ProductBasketSiteDataObject.ProductConfiguration>();
                    for(cscfga__Attribute__c attr : lstAttribute)
                    {
                        if(attr.cscfga__Is_Line_Item__c = true && (pc.id == attr.cscfga__Product_Configuration__r.cscfga__Root_Configuration__c && (attr.cscfga__Product_Configuration__r.cscfga__Description__c !='Managed Router' || attr.cscfga__Product_Configuration__r.cscfga__Description__c !='Managed Device')))
                        {
                            ProductBasketSiteDataObject.ProductConfiguration prodConfigDetails = new ProductBasketSiteDataObject.ProductConfiguration();
                            prodConfigDetails.description = attr.cscfga__Product_Configuration__r.cscfga__Description__c;
                            prodConfigDetails.quantity = attr.Quantity__c;
                            //if(!lstProdConfigDetails.contains(prodConfigDetails)){
                                lstProdConfigDetails.add(prodConfigDetails);
                            //}
                            System.debug('prodConfigDetails: '+ prodConfigDetails);
                        }
                        else if(pc.id == attr.cscfga__Product_Configuration__c && attr.name == 'Site Name'){
                            siteName = attr.cscfga__value__c;
                        }
                        else if(pc.id == attr.cscfga__Product_Configuration__c && attr.name == 'Site Address'){
                            siteAddress = attr.cscfga__value__c;
                        }
                        else if(pc.id == attr.cscfga__Product_Configuration__c && attr.name == 'AdborID'){
                            adBorId = attr.cscfga__value__c;
                            if(AddressSiteMap!=null && AddressSiteMap.containsKey(adBorId)){
                                state=AddressSiteMap.get(adBorId).Address_ID__c;
                                locality=AddressSiteMap.get(adBorId).Locality__c;
                            }
                        }
                    }
                    if(siteName !=null && adBorId !=null){
                        ProductBasketSiteDataObject pbsdObject = new ProductBasketSiteDataObject();
                        pbsdObject.pcrId = pc.Id;
                        pbsdObject.siteName = siteName;
                        pbsdObject.adBorId = adBorId;
                        pbsdObject.pcrName = 'Connected Workplace';
                        pbsdObject.siteAddress = siteAddress;
                        pbsdObject.orderType = pc.Type__c;
                        pbsdObject.oldConfigId = pc.csordtelcoa__Replaced_Product_Configuration__c;
                        pbsdObject.lstProdConfig = lstProdConfigDetails;
                        pbsdObject.state=state;
                        pbsdObject.locality=locality; 
                        pbsdObject.pcIsEligible=pc.isEligibleForTransition__c;
                        pbsdMap.put(adBorId,pbsdObject);                        
                    }
                }
            }
        }
        /*-- Old flow - Attachement will be stored in PCR --*/
        else{
            List<csbb__Product_Configuration_Request__c> pcrList = [select id, Product_Configuration_Name__c,csbb__Product_Configuration__c,csbb__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c, csbb__Optionals__c, csbb__Product_Basket__c,csbb__Offer__r.name, Type__c,csbb__Product_Configuration__r.isEligibleForTransition__c from csbb__Product_Configuration_Request__c where csbb__Product_Basket__c =: basketId];
            //List<cscfga__Product_Configuration__c> lstProdConfig = [select Id,cscfga__Root_Configuration__c,cscfga__Description__c,cscfga__Quantity__c, (select Id, Name, cscfga__Is_Line_Item__c, Quantity__c from cscfga__Attribute__c) from cscfga__Product_Configuration__c where cscfga__Root_Configuration__r.cscfga__Product_Basket__c =: basketId];
            List<cscfga__Attribute__c> lstAttribute = [select Name, cscfga__Is_Line_Item__c, Quantity__c, cscfga__Product_Configuration__r.cscfga__Description__c, cscfga__Product_Configuration__r.cscfga__Root_Configuration__c from cscfga__Attribute__c where cscfga__Product_Configuration__r.cscfga__Root_Configuration__r.cscfga__Product_Basket__c =: basketId and cscfga__Is_Line_Item__c = true];
            List<cscrm__Site__c> lstSiteAddress = [select Id, Composite_Key__c, Address__c from cscrm__Site__c where cscrm__Account__r.CIDN__c = : cidn];
            for(csbb__Product_Configuration_Request__c pcr : pcrList){
                if(pcr.Product_Configuration_Name__c == 'IP Site' && pcr.csbb__Optionals__c != null){
                    //if((pcr.csbb__Offer__r.name == 'Connected Workplace' || pcr.csbb__Offer__r.name == 'Connected Workplace Package' ) && pcr.csbb__Optionals__c != null){     
                    JSONParser parser = JSON.createParser(pcr.csbb__Optionals__c);
                    String siteName = null;
                    String adBorId = null;
                    String siteAddress = null;
                    String streetNumberFromCalc =null;
                    String streetNumberTo = null;
                    String cscrmStreetName = null;         
                    String cscrmStreetType = null; 
                    String locality = null;
                    String cscrmStateProvince = null;
                    String cscrmZipPostalCode = null;
                    
                    //EDGE-57834 ~ Site Name and Address were not populated
                    while (parser.nextToken() != null) {
                        if(parser.getText() == 'cscrm_installation_addressr_street_number_from_calc_c'){
                            parser.nextToken();
                            streetNumberFromCalc = parser.getText();
                        }else if(parser.getText() == 'cscrm_installation_address_r_street_number_to_c'){
                            parser.nextToken();
                            streetNumberTo = parser.getText();
                        }else if(parser.getText() == 'cscrm_installation_address_r_cscrm_street_name_c'){
                            parser.nextToken();
                            cscrmStreetName = parser.getText();
                        }else if(parser.getText() == 'cscrm_installation_address_r_cscrm_street_type_c'){
                            parser.nextToken();
                            cscrmStreetType = parser.getText();
                        }else if(parser.getText() == 'cscrm_installation_address_r_locality_c'){
                            parser.nextToken();
                            locality = parser.getText();
                        }else if(parser.getText() == 'cscrm_installation_address_r_cscrm_zip_postal_code_c'){
                            parser.nextToken();
                            cscrmZipPostalCode = parser.getText();
                        }else if(parser.getText() == 'cscrm_installation_address_r_cscrm_state_province_c'){
                            parser.nextToken();
                            cscrmStateProvince = parser.getText();
                        }else if(parser.getText() == 'hiddenParam1'){
                            parser.nextToken();
                            adBorId = parser.getText();
                        }
                    }
                    if(streetNumberFromCalc!=null && streetNumberFromCalc!='null'){
                        if(siteName==null){
                            if(streetNumberTo!=null && streetNumberTo!='null'){
                                siteName = streetNumberFromCalc+'-';
                            }
                            else{
                                siteName = streetNumberFromCalc+' ';
                            }
                        }
                    }
                    System.debug('site Name1 ---->' + siteName);
                    if(streetNumberTo!=null && streetNumberTo!='null'){
                        if(siteName==null){
                            sitename = streetNumberTo+' ';
                        }
                        else{
                            sitename=sitename+streetNumberTo+' ';
                        } 
                    }
                    if(cscrmStreetName!=null && cscrmStreetName!='null'){
                        if(siteName==null){
                            sitename = cscrmStreetName+' ';
                        }
                        else{
                            sitename=sitename+cscrmStreetName+' ';
                        } 
                    }
                    if(cscrmStreetType!=null && cscrmStreetType!='null'){
                        if(siteName==null){
                            sitename = cscrmStreetType+' ';
                        }
                        else{
                            sitename=sitename+cscrmStreetType+' ';
                        } 
                    }
                    if(locality!=null){
                        if(siteName==null){
                            sitename = locality;
                        }
                        else{
                            sitename=sitename+locality;
                        } 
                    }
                    siteAddress = siteName;
                    if(cscrmStateProvince !=null){
                        siteAddress = siteAddress + ' ' + cscrmStateProvince;
                    }
                    if(cscrmZipPostalCode !=null){
                        siteAddress = siteAddress + ' ' + cscrmZipPostalCode;
                    }
                    System.debug('site Name ---->' + siteName);
                    if(siteName!=null && siteName.length()>80){
                        siteName = siteName.subString(0,80);
                    }                    
                    System.debug('***** Optionals ---->' + pcr.csbb__Optionals__c);
                    /*for(cscrm__Site__c siteAd : lstSiteAddress)
{
if(siteAd.Composite_Key__c == cidn+adBorId)
{
siteAddress = siteAd.Address__c;
//siteName = siteAd.Display_Name__c;
}
}*/
                    
                    List<ProductBasketSiteDataObject.ProductConfiguration> lstProdConfigDetails = new List<ProductBasketSiteDataObject.ProductConfiguration>();
                    for(cscfga__Attribute__c attr : lstAttribute)
                    {
                        if(pcr.csbb__Product_Configuration__c == attr.cscfga__Product_Configuration__r.cscfga__Root_Configuration__c && (attr.cscfga__Product_Configuration__r.cscfga__Description__c !='Managed Router' || attr.cscfga__Product_Configuration__r.cscfga__Description__c !='Managed Device'))
                        {
                            ProductBasketSiteDataObject.ProductConfiguration prodConfigDetails = new ProductBasketSiteDataObject.ProductConfiguration();
                            prodConfigDetails.description = attr.cscfga__Product_Configuration__r.cscfga__Description__c;
                            prodConfigDetails.quantity = attr.Quantity__c;
                            if(!lstProdConfigDetails.contains(prodConfigDetails))
                            {
                                lstProdConfigDetails.add(prodConfigDetails);
                            }
                        }
                    }
                    if(siteName !=null && adBorId !=null){
                        ProductBasketSiteDataObject pbsdObject = new ProductBasketSiteDataObject();
                        pbsdObject.pcrId = pcr.id;
                        pbsdObject.siteName = siteName;
                        pbsdObject.adBorId = adBorId;
                        pbsdObject.pcrName = 'Connected Workplace';
                        pbsdObject.siteAddress = siteAddress;
                        pbsdObject.orderType = pcr.Type__c;
                        pbsdObject.oldConfigId = pcr.csbb__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c;
                        pbsdObject.lstProdConfig = lstProdConfigDetails;
                        if(cscrmStreetName!=null){
                            pbsdObject.state=cscrmStreetName;
                        }else{
                            pbsdObject.state='';
                        }
                        if(locality!=null){
                            pbsdObject.locality=locality;
                        }else{
                            pbsdObject.locality='';
                        } 
                        pbsdObject.pcIsEligible=pcr.csbb__Product_Configuration__r.isEligibleForTransition__c;
                        pbsdMap.put(adBorId,pbsdObject);
                    }
                }
            }
        }
            System.debug('pbsdMap-->>>'+pbsdMap);

           return pbsdMap;
        }
        catch(Exception e){
            return null;
        }
    }
    /** Get ReplicatorGetServiceDataObject response from Replicator Input Parameter finCIDN from Account and ProductBasketSiteDataObject as a String from CompUtility Component*/
    @AuraEnabled 
    public static ReplicatorGetServiceDataObject getCustomerServices(String finCIDN,String prodBasSites) {
        System.debug('**********prodBasSites : '+prodBasSites);
        Map<String,ProductBasketSiteDataObject> mapProdBasSites = (Map<String,ProductBasketSiteDataObject>) System.JSON.deserialize(prodBasSites, Map<String,ProductBasketSiteDataObject>.class);
        List<String> adbor_Id = new List<String>();
        List<String> adborIdWithLegacy = new List<String>();
        for(ProductBasketSiteDataObject prodSite : mapProdBasSites.Values())
        {
            adbor_Id.add(prodSite.adBorId);
        }
        List<cscrm__Site__c> lstSite = [select Legacy__c,AdborID__c from cscrm__Site__c where AdborID__c in :adbor_Id];
        for(cscrm__Site__c sit : lstSite)
        {
            if(sit.Legacy__c)
            {
                adborIdWithLegacy.add(sit.AdborID__c);
            }
        }
        if(adborIdWithLegacy.isEmpty())
        {
            return null;
        }
        return getCustomerServicesAtSite(finCIDN,adborIdWithLegacy);
    }

    /*Get ReplicatorGetServiceDataObject_V2 data from Old DTO  
        Input Parameter
        - finCIDN from Account
        - ProductBasketSiteDataObject as a String from CompUtility Component
        Interally It is calling getCustomerServices
        This method also fetching data from attachment of If there are already ReplicatorGetServiceDataObject_V2 prsent on existing basket
    */ 
    @AuraEnabled
    public static ReplicatorGetServiceDataObject_V2 getCustomerServices_New(String finCIDN,String prodBasSites, String selectedAdborid) {
        System.debug('*** getCustomerServices_New ***'+selectedAdborid);
        
        /* EDGE-75696, EDGE-85840, EDGE-84055 : Getting Custom setting to check which flow to execute for replicator response */
        String newReplicatorJSONresponse = EnvironmentVariable__c.getValues('newReplicatorJSONresponseO').Value__c;
        ReplicatorGetServiceDataObject_V2 ServiceDTOToReturn = new ReplicatorGetServiceDataObject_V2();
        Map<String,ProductBasketSiteDataObject> pbsdMap = (Map<String,ProductBasketSiteDataObject>) System.JSON.deserialize(prodBasSites, Map<String,ProductBasketSiteDataObject>.class);
        
        Set<String> PCRIdSet = new Set<String>();
        Map<Id,Attachment> atttchmentWithParentId = new Map<Id,Attachment>();
        Set<String> adborIdWithReplicatorCall = new Set<String>(); 
        Set<String> attachedSiteAdborId = new Set<String>();
        Map<String,ProductBasketSiteDataObject> pbsdMapForReplicatorCall = new Map<String,ProductBasketSiteDataObject>();
 
        for(String adborId: pbsdMap.keySet()){
            PCRIdSet.add(pbsdMap.get(adborId).pcrId);
            
        }
        List<Attachment> attList = [select ID, name, body, parentId from Attachment where parentId in: PCRIdSet and name =: 'TransitionJSONData.json' ];
        
        if(attList.size() > 0){
            for(Attachment atchmnt:attList){
                atttchmentWithParentId.put(atchmnt.parentId, atchmnt);
            }
        }
        if(attList.size() != 0){
            for(String pcrId:PCRIdSet){
                if(attList.size() > 0 && atttchmentWithParentId.keySet().contains(pcrId)){
                    System.debug('***If Attachment Exist****');
                    System.debug('PCRID->>>>'+pcrId);
                    System.debug('Attachment Body String->>>'+atttchmentWithParentId.get(pcrId).body.toString());   
                    ReplicatorGetServiceDataObject_V2 AttchedServiceDTO = ReplicatorGetServiceDataObject_V2.parse(atttchmentWithParentId.get(pcrId).body.toString());   
                    System.debug('AttchedServiceDTO-->>>'+AttchedServiceDTO);
                    ServiceDTOToReturn.Source_System_Id = AttchedServiceDTO.Source_System_Id;
                    ServiceDTOToReturn.CIDN = AttchedServiceDTO.CIDN;
                    ServiceDTOToReturn.Correlation_Id = AttchedServiceDTO.Correlation_Id;
                    ServiceDTOToReturn.Error_Code = AttchedServiceDTO.Error_Code;
                    ServiceDTOToReturn.Error_Description = AttchedServiceDTO.Error_Description;
                    ServiceDTOToReturn.serviceCount = AttchedServiceDTO.serviceCount;
                    System.debug('AttchedServiceDTO.site-->>>' +AttchedServiceDTO.site);
                    if(AttchedServiceDTO.site.size() > 0){
                    attachedSiteAdborId.add(AttchedServiceDTO.site[0].ADBOR_Id);
                        system.debug('AttchedServiceDTO.site[0].ADBOR_Id=='+AttchedServiceDTO.site[0].ADBOR_Id);
                    ServiceDTOToReturn.site.add(AttchedServiceDTO.site[0]);
                    }
                    
                }
            }
            system.debug('pbsdMap.keySet()=='+pbsdMap.keySet());
            for(String adBorId: pbsdMap.keySet()){
                if(!attachedSiteAdborId.contains(adBorId)){
                    ProductBasketSiteDataObject pbSiteDateObject = pbsdMap.get(adBorId);
                    if (pbSiteDateObject.orderType != 'Cancel'){
                        pbsdMapForReplicatorCall.put(adBorId, pbsdMap.get(adBorId));
                    }
                }
            }
            if(pbsdMapForReplicatorCall.size() > 0){
                System.debug('*** Additional Call to Replicator ***');
                String pbsdMapForReplicatorCallString = String.valueOf(JSON.serialize(pbsdMapForReplicatorCall));
                System.debug('pbsdMapForReplicatorCallString-->>'+pbsdMapForReplicatorCallString);

                /* EDGE-75696, EDGE-85840, EDGE-84055 - Changes done for modified replicator response - Maq */
                ReplicatorGetServiceDataObject serviceObjDTO = new ReplicatorGetServiceDataObject();
                ReplicatorGetServiceDTO serviceObjDTO_V3 = new ReplicatorGetServiceDTO();
                if(newReplicatorJSONresponse == 'true'){
                    serviceObjDTO_V3 = ReplicatorGetServiceManager.getCustomerServicesNew(finCIDN,pbsdMapForReplicatorCallString,selectedAdborid);
                    System.debug('---serviceObjDTO_V3 if---'+serviceObjDTO_V3);
                }
                else{
                    serviceObjDTO = getCustomerServices(finCIDN,pbsdMapForReplicatorCallString);
                }

                System.debug('addtional serviceObjDTO-->>'+serviceObjDTO);
                if(serviceObjDTO != null || serviceObjDTO_V3 != null){
                    ReplicatorGetServiceDataObject_V2 SeviceOBJDTO_New = new ReplicatorGetServiceDataObject_V2();
                    if(newReplicatorJSONresponse == 'true'){
                        SeviceOBJDTO_New = ReplicatorGetServiceManager.replicatorResponseToTransition(serviceObjDTO_V3);
                        System.debug('---SeviceOBJDTO_New if---'+SeviceOBJDTO_New);
                    }
                    else{
                        SeviceOBJDTO_New = getNewServiceDTO(serviceObjDTO);
                    }
                    
                    System.debug('SeviceOBJDTO_New-->>'+SeviceOBJDTO_New);
                    for(ReplicatorGetServiceDataObject_V2.SiteDTO_V2 site:SeviceOBJDTO_New.site){
                        
                        for(ReplicatorGetServiceDataObject_V2.productListDTO product: site.productList){
                            if((product.eligibilityStatus == 'Eligible') && (product.Product_Type == 'ISDN-BRA' || product.Product_Type == 'ISDN2' || product.Product_Type == 'ISDN2DID' || product.Product_Type == 'PSTN')){
                                product.checkValue = true;
                                SeviceOBJDTO_New.serviceCount++;
                                
                            }
                        }
                        ServiceDTOToReturn.site.add(site);
                    }
                }
            }
            
            
        }else{
            System.debug('If Attachment Not Exist');
            /* EDGE-75696, EDGE-85840, EDGE-84055 - Changes done for modified replicator response - Maq */
            ReplicatorGetServiceDataObject serviceObjDTO = new ReplicatorGetServiceDataObject();
            ReplicatorGetServiceDTO serviceObjDTO_V3 = new ReplicatorGetServiceDTO();
            if(newReplicatorJSONresponse == 'true'){
                
                serviceObjDTO_V3 = ReplicatorGetServiceManager.getCustomerServicesNew(finCIDN,prodBasSites,selectedAdborid);
                System.debug('---serviceObjDTO_V3 else---'+serviceObjDTO_V3);
            }
            else{
                serviceObjDTO = getCustomerServices(finCIDN,prodBasSites);
            }
            //    ReplicatorGetServiceDataObject serviceObjDTO = getCustomerServices(finCIDN,prodBasSites);
            System.debug('*** serviceObjDTO--->>'+serviceObjDTO); 
            if(serviceObjDTO != null || serviceObjDTO_V3 != null){
                ReplicatorGetServiceDataObject_V2 SeviceOBJDTO_New = new ReplicatorGetServiceDataObject_V2();
                system.debug('$$$$$$$$$$$----->'+newReplicatorJSONresponse);
                if(newReplicatorJSONresponse == 'true'){
                    SeviceOBJDTO_New = ReplicatorGetServiceManager.replicatorResponseToTransition(serviceObjDTO_V3);
                    System.debug('---SeviceOBJDTO_New else---'+SeviceOBJDTO_New);
                    system.debug('$$$$$$$$$$$ If----->'+SeviceOBJDTO_New);
                }
                else{
                    if(serviceObjDTO!=null)
                        SeviceOBJDTO_New = getNewServiceDTO(serviceObjDTO);
                        system.debug('$$$$$$$$$$$ else----->'+SeviceOBJDTO_New);
                }

            //    ReplicatorGetServiceDataObject_V2 SeviceOBJDTO_New = getNewServiceDTO(serviceObjDTO);
                System.debug('SeviceOBJDTO_New-->>'+SeviceOBJDTO_New);
                for(ReplicatorGetServiceDataObject_V2.SiteDTO_V2 site:SeviceOBJDTO_New.site){
                    
                    for(ReplicatorGetServiceDataObject_V2.productListDTO product: site.productList){
                        if((product.Product_Type == 'ISDN-BRA' || product.Product_Type == 'ISDN2' || product.Product_Type == 'ISDN2DID' || product.Product_Type == 'PSTN')){
                            product.checkValue = true;
                            SeviceOBJDTO_New.serviceCount++; 
                        }
                    }
                }
                ServiceDTOToReturn = SeviceOBJDTO_New;
            }
        }   
        
        System.debug('ServiceDTOToReturn-->>'+ServiceDTOToReturn);
        return ServiceDTOToReturn; 
               
    }
    
    /** ///Create Map of ReplicatorGetServiceDataObject_V2.SiteDTO with AdborId for show on Lightning Component */
    @AuraEnabled
    public static Map<String,ReplicatorGetServiceDataObject_V2.SiteDTO_V2> getCustomerServicesMap_New(String serviceDTO_V2, Map<String,ReplicatorGetServiceDataObject_V2.SiteDTO_V2> sitesMap_v2Custom) {
        System.debug('@@@@@prods-------->'+JSON.serialize(serviceDTO_V2));
        ReplicatorGetServiceDataObject_V2 SeviceOBJDTO_New = ReplicatorGetServiceDataObject_V2.parse(serviceDTO_V2);
        Map<String,ReplicatorGetServiceDataObject_V2.SiteDTO_V2> mapSites = new Map<String,ReplicatorGetServiceDataObject_V2.SiteDTO_V2>();
        String validProductType = System.Label.TransitionEligibleProductList;

        List<String> validProductTypeList = validProductType.split(',');

        System.debug('@@@@@prods'+validProductTypeList);
        for(ReplicatorGetServiceDataObject_V2.SiteDTO_V2 siteObj : SeviceOBJDTO_New.site)
        {
        system.debug('---@@@@@@@@@@@@@@---->'+sitesMap_v2Custom);
         if(sitesMap_v2Custom != null && sitesMap_v2Custom.isEmpty() != true){
                system.debug('---@@@@@@@@@@@@@@--Inside-->'+sitesMap_v2Custom.get(siteObj.ADBOR_Id));
            }
            for(ReplicatorGetServiceDataObject_V2.ProductListDTO prod: siteObj.productList)
            {
            if(sitesMap_v2Custom != null && sitesMap_v2Custom.isEmpty() != true){
            if (sitesMap_v2Custom.get(siteObj.ADBOR_Id) != NULL && sitesMap_v2Custom != NULL) {
                for (ReplicatorGetServiceDataObject_V2.ProductListDTO prodMapValue: sitesMap_v2Custom.get(siteObj.ADBOR_Id).productList) {
                        if (prodMapValue.Product_type == prod.Product_Type) {
                            prod.checkValue = prodMapValue.checkValue;
                        }
                    }
                }
                }
                Boolean eligibilityNotAssessed=true;
                Boolean Ineligible=false;
                String EligibilityStatus='';                
                for(ReplicatorGetServiceDataObject_V2.serviceListDTO serv:prod.serviceList)
                {                       
                    if(validProductTypeList.contains(prod.Product_Type))
                    {
                        for(ReplicatorGetServiceDataObject_V2.ServiceDTO_V2 serv2:serv.service)
                        {
                                                        
                            for(ReplicatorGetServiceDataObject_V2.ServiceExtensionDTO_V2 servext:serv2.serviceExtension)
                            {
                                System.debug('@@@@@servext'+servext.eligibilityStatus);
                                if(servext.eligibilityStatus==null){
                                    eligibilityNotAssessed=true;
                                }else if(servext.eligibilityStatus=='Eligible'){
                                eligibilityNotAssessed=false;
                                }else if(servext.eligibilityStatus=='Ineligible'){
                                    eligibilityNotAssessed=false;
                                    Ineligible=true;
                                }
                            }
                            //  added for bug Edge-90736
                            System.debug('@@@@@serv2'+serv2.eligibilityStatus);
                            if(serv2.serviceExtension.size()>0 && eligibilityNotAssessed==false){
                                if(Ineligible==true){
                                    eligibilityNotAssessed=false;
                                    serv2.eligibilityStatus='Ineligible';
                                }else{
                                    eligibilityNotAssessed=false;
                                    serv2.eligibilityStatus='Eligible';
                                }
                            }else{
                                if(serv2.eligibilityStatus==null){
                                    eligibilityNotAssessed=true;
                                }else if(serv2.eligibilityStatus=='Eligible'){
                                    eligibilityNotAssessed=false;
                                }else if(serv2.eligibilityStatus=='Ineligible'){
                                    eligibilityNotAssessed=false;
                                    Ineligible=true;
                                }   
                            }                           
                        }

                        if(eligibilityNotAssessed==true){
                            prod.eligibilityStatus='Ready for assessment';                          
                        }else{
                            if(Ineligible==true){
                                prod.eligibilityStatus='Ineligible';    
                            }else{
                                prod.eligibilityStatus='Eligible';
                            }
                        }
                    }
                    else{
                        prod.eligibilityStatus='Not valid for assessment';
                    }   
                }
            }           
            mapSites.put(siteObj.ADBOR_Id,siteObj);
        }
        return mapSites;
    }

    /** Call to Replicator to get ReplicatorGetServiceDataObject*/
    public static ReplicatorGetServiceDataObject getCustomerServicesAtSite(String finCIDN, List<String> adbor_Id) {
        ReplicatorGetServiceDataObject serviceDTO;
        try{
            if(!Test.IsRunningTest()){
                serviceDTO = ReplicatorLegacyAssetService.getCustomerServices(finCIDN, adbor_Id);     
            }
            Logger.getLogger('Transition getService response').logResponse(JSON.serialize(serviceDTO));
            Logger.exitLogger();
        }catch(Exception e){
            System.debug('Exception Occure In Response from Replicator');
            Logger.getLogger(ReplicatorManager.class).debug(e);
            Logger.exitLogger();
        }   
        System.debug('serviceDTO'+serviceDTO);
        return serviceDTO;
    }    
    
    //Transition to Basket Page
    @AuraEnabled
    public static String redirectToBasket(String legacyProd,String basketID){
        String urlToBasket;
        ReplicatorGetServiceDataObject serviceDTO;
        try{
            serviceDTO = ReplicatorGetServiceDataObject.parse(legacyProd);
            PageReference basketPage= TransitionProductBasketUpdate.createTransitionBasket(serviceDTO,basketID);
            system.debug('*********basketPage : '+basketPage);
            urlToBasket=basketPage.getUrl();
            cscfga__Product_Basket__c basket = [Select Id, TransitionComplete__c from cscfga__Product_Basket__c where Id =: basketID];
            basket.TransitionComplete__c = true;
            update basket;
            system.debug('*********urlToBasket : '+urlToBasket);
        }catch(Exception e){
            Logger.getLogger(ReplicatorManager.class).debug(e);
            Logger.exitLogger();
            system.debug('*********urlToBasket : '+urlToBasket);
        }
        return urlToBasket;
    }
    
    /** Save selected service in basket to all PCRs with there respective AdborId*/
    @AuraEnabled 
    public static ReplicatorGetServiceDataObject_V2 getSelectedSite_V2(String serviceDTO_V2, String basketId, String siteMap2, Boolean SendCallout) {
        //Start of DIGI-33080 by Abhishek(Osaka) to enable Check eligibility for IoT
        String IoTJsonName = 'IoT_Dormancy_False';
        String prodSpecIoT = 'IoT_Dormancy_False';
        if(IoT_Dormancy == 'true'){
            IoTJsonName = String.valueOf(MTMMetadataUtilityMap.get('IoTTransitionName').get('Value__c'));
            prodSpecIoT = String.valueOf(MTMMetadataUtilityMap.get('IoT_Marketable_Offer').get('Value__c'));
        }
        //End of DIGI-33080

        System.debug('*** Server Call attachTransitionJSONData ****'+SendCallout);
        System.debug('*** Server Call basketId ****' + basketId);
        System.debug('*** Server Call siteMap2 ****' + siteMap2);
        System.debug('*** Server Call serviceDTO_V2 ****' + serviceDTO_V2);
        
        List<Attachment> attList = new List<Attachment>();
        Map<string,ReplicatorGetServiceDataObject_V2.SiteDTO_V2> siteMap2Obj = (Map<string,ReplicatorGetServiceDataObject_V2.SiteDTO_V2>)Json.deserialize(siteMap2, Map<string,ReplicatorGetServiceDataObject_V2.SiteDTO_V2>.Class);
        List<ReplicatorGetServiceDataObject_V2> servicedtolist= new List<ReplicatorGetServiceDataObject_V2>();
        Map<String, ProductBasketSiteDataObject> pbsdMap = fetchSiteFromBasketControllerMap(basketId);
        ReplicatorGetServiceDataObject_V2 ServiceDTO = ReplicatorGetServiceDataObject_V2.parse(serviceDTO_V2);
        System.debug('TM1: serviceDTO'+ServiceDTO);
        System.debug('TM1: siteMap2'+siteMap2Obj);
        Set<String> prcIdSet = new Set<String>();
        for(ProductBasketSiteDataObject pbsObj: pbsdMap.values()){
            prcIdSet.add(pbsObj.pcrId);
        }
        System.debug('prcIdSet-->>>'+prcIdSet);
        List<Attachment> attchedJSON = [select ID, name, body, parentId from Attachment where parentId in: prcIdSet and name =: 'TransitionJSONData.json'];
        
        System.debug('attchedJSON-->>'+attchedJSON);
        System.debug('siteMap2Obj>>>'+siteMap2Obj.values());
        System.debug('pbsdMap-->>>'+pbsdMap);
       
       //EDGE - 66569 
        Map<String,ReplicatorGetServiceDataObject_V2> mapPcrToServiceDTO = new Map<String,ReplicatorGetServiceDataObject_V2>();
       
        if(pbsdMap != null && ServiceDTO != null){
            for(ProductBasketSiteDataObject pbsObj: pbsdMap.values()){
                ReplicatorGetServiceDataObject_V2 ServiceDTOToBeStored = new ReplicatorGetServiceDataObject_V2();
                ServiceDTOToBeStored.Source_System_Id = ServiceDTO.Source_System_Id;
                ServiceDTOToBeStored.CIDN = ServiceDTO.CIDN;
                ServiceDTOToBeStored.Correlation_Id = ServiceDTO.Correlation_Id;
                ServiceDTOToBeStored.Error_Code = ServiceDTO.Error_Code;
                ServiceDTOToBeStored.Error_Description = ServiceDTO.Error_Description;
                ServiceDTOToBeStored.serviceCount = ServiceDTO.serviceCount;
                if(siteMap2Obj.get(pbsObj.adBorId)!=null){
                    ServiceDTOToBeStored.site.add(siteMap2Obj.get(pbsObj.adBorId));
                }                
                system.debug('ServiceDTOToBeStored>>>>>' + ServiceDTOToBeStored); 
                servicedtolist.add(ServiceDTOToBeStored);                
                String pcrID = pbsObj.pcrId;
                String TransitionJSONData=JSON.serialize(ServiceDTOToBeStored);
                Blob body = Blob.valueOf(TransitionJSONData);
                Attachment att = new Attachment();
                att.Name =  'TransitionJSONData.json';
                att.ParentId = pcrID;
                System.debug('pcrID-->>>'+pcrID);
                att.Body = body;
                attList.add(att);
                
                 //EDGE-66569
                mapPcrToServiceDTO.put(pcrID,ServiceDTOToBeStored);
                
                ServiceDTOToBeStored = null;
                
            }
        }
        //EDGE-66569
        //TM1EligibilityCheckHandler.TramasEligibilityRequestMethod(servicedtolist);
        try
        {
            if(SendCallout==true){          
             //start EDGE-85160 - removing this code for sprint 19.09
             System.debug('SendCallout## '+SendCallout); 
                List<Id> pcIds=new List<Id>();
                //Added OR Condition : Manoj

                //DIGI-33080 :  Introduced IoT (prodSpecIoT) condition in OR clause to enable check Eligibility for IoT
                for(cscfga__Product_Configuration__c pc:[SELECT id FROM cscfga__Product_Configuration__c WHERE 
                        cscfga__Product_Basket__c =:basketId AND 
                         (cscfga__Product_Definition__r.product_Specification__c IN: listproductSpecMobile OR cscfga__Product_Definition__r.product_Specification__c IN: listproductSpecNgUc
							OR cscfga__Product_Definition__r.product_Specification__c = :prodSpecIoT) ]){
                    pcIds.add(pc.id);
                }
                
                System.debug('pcIds'+pcIds);                
                //DIGI-33080 :  Introduced IoT (IoTJsonName) condition in OR clause to enable check Eligibility for IoT

                if(!pcIds.isEmpty()){
                    List<Attachment> attachments=[SELECT id,Name,body,ParentId  FROM Attachment WHERE ParentId in :pcIds AND 
                                                  (Name=:system.label.MobileTransitionName OR Name= :Label.NgUcTransitionName OR Name = :IoTJsonName) 
                                                    order by createdDate desc];                  
                    System.debug('attachments## '+attachments);
                    
                    if(!attachments.isEmpty()){
                        for(Attachment att : attachments){
                          //Manoj : Checking for mobile transition
                          
                          //DIGI-33080 :  Introduced IoT (IoTJsonName) condition in OR clause to enable check Eligibility for IoT and re-use Mobility logic
                          if(att.Name == label.MobileTransitionName || att.Name == IoTJsonName){
                                
                                String mobileTransitionDTO=att.body.toString();
                                String pcId=att.ParentId;
                                System.debug('mobileTransitionDTO'+mobileTransitionDTO);
                                
                                
                                TM1EligibilityCheckServiceV2.tramasEligibilityRequestMethod(mobileTransitionDTO,pcId);
                                system.debug('AfterTM1Called');
                            }
                           //Manoj :  Checking for nguc
                             if(att.Name == Label.NgUcTransitionName){
                                String ngucTransitionDTO=att.body.toString();
                                String pcId=att.ParentId;
                                System.debug('ngucTransitionDTO'+ngucTransitionDTO);
                                
                                
                               TramasBatchEligibilityCheckService.constructNgucBatchRequest(ngucTransitionDTO,pcId,prdNguc);
                                system.debug('AfterTM1ngucCalled');
                            }
                            
                        }
                        

                    }
                }
                
                //end EDGE-85160  - removing this code for sprint 19.09
                //TM1EligibilityCheckService.TramasEligibilityRequestMethod(mapPcrToServiceDTO);
                //BulkMethodcall
                if(!mapPcrToServiceDTO.IsEmpty())
               TramasBatchEligibilityCheckService.constructBatchCreateRequest(mapPcrToServiceDTO,prdCwp);
                
                //Added for 90158
                cscfga__Product_Basket__c prodBasket = [Select id , isEligibilityCheckComplete__c , isEligibilityTriggered__c,Transition_basket_stage__c from cscfga__Product_Basket__c where id = : basketId ];
                prodBasket.isEligibilityCheckComplete__c=false;         
                List <cscfga__Product_Configuration__c> prodConfig = [select id , name ,  isEligibleForTriggered__c,isEligibleForTransition__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__r.Id = :  basketId and name = 'IP Site'];
                for(cscfga__Product_Configuration__c pc:prodConfig){
                    pc.isEligibleForTriggered__c=false;
                    pc.isEligibleForTransition__c=false;
                    
                }
                update prodConfig;  
            }
            
            system.debug('valueservicedtolist'+servicedtolist);
            if(attList != null){
                delete attchedJSON;
                insert attList;
            }
        }
        catch(Exception e){
            System.debug('Exception: ' + e);
            Logger.getLogger(CompUtilityReplicatorManager.class + ':' +basketId ).debug(e);
            Logger.exitLogger();
            return null;
        }
        System.debug('Attachment Stored **');
            
        return ServiceDTO;
    }
    
    //Commented as this is no longer in use
    
    /*// Save all the eligible service in basket to all PCRs with there respective AdborId
    @AuraEnabled 
    public static void transitionAllRecommended(String serviceDTO_V2, String basketId) {
        
        System.debug('*** Server Call transitionAllRecommended ****');
        
        ReplicatorGetServiceDataObject_V2 ServiceDTOToBeStored;
        List<Attachment> attList = new List<Attachment>();
        Set<String> prcIdSet = new Set<String>();
        
        Map<String, ProductBasketSiteDataObject> pbsdMap = fetchSiteFromBasketControllerMap(basketId);
        ReplicatorGetServiceDataObject_V2 ServiceDTO = ReplicatorGetServiceDataObject_V2.parse(serviceDTO_V2);
        Map<String,ReplicatorGetServiceDataObject_V2.SiteDTO_V2> SiteMap = getCustomerServicesMap_New(serviceDTO_V2);
        
        for(ProductBasketSiteDataObject pbsObj: pbsdMap.values()){
            prcIdSet.add(pbsObj.pcrId);
        }
        System.debug('prcIdSet-->>>'+prcIdSet);
        List<Attachment> attchedJSON = [select ID, name, body, parentId from Attachment where parentId in: prcIdSet and name =: 'TransitionJSONData.json'];
        System.debug('attchedJSON-->>'+attchedJSON);
        System.debug('pbsdMap-->>>'+pbsdMap);
        system.debug('ServiceDTO>>>>>' + ServiceDTO);
       
        if(pbsdMap != null && ServiceDTO != null){
            for(ProductBasketSiteDataObject pbsObj: pbsdMap.values()){
                ServiceDTOToBeStored = new ReplicatorGetServiceDataObject_V2();
                ServiceDTOToBeStored.Source_System_Id = ServiceDTO.Source_System_Id;
                ServiceDTOToBeStored.CIDN = ServiceDTO.CIDN;
                ServiceDTOToBeStored.Correlation_Id = ServiceDTO.Correlation_Id;
                ServiceDTOToBeStored.Error_Code = ServiceDTO.Error_Code;
                ServiceDTOToBeStored.Error_Description = ServiceDTO.Error_Description;
                ServiceDTOToBeStored.serviceCount = ServiceDTO.serviceCount;
        if(siteMap.get(pbsObj.adBorId)!=null){
          ServiceDTOToBeStored.site.add(siteMap.get(pbsObj.adBorId));
        }               
       
                system.debug('valueofServiceDTOToBeStored'+ServiceDTOToBeStored );
                String pcrID = pbsObj.pcrId;
                String TransitionJSONData=JSON.serialize(ServiceDTOToBeStored);
                system.debug(TransitionJSONData);
                Blob body = Blob.valueOf(TransitionJSONData);
                Attachment att = new Attachment();
                att.Name =  'TransitionJSONData.json';
                att.ParentId = pcrID;
                System.debug('pcrID-->>>'+pcrID);
                att.Body = body;
                attList.add(att);   
                ServiceDTOToBeStored = null;                  
            }
        }
       
        if(attList != null){
            delete attchedJSON;
            insert attList;
            System.debug('Attachment Stored **');
        }
        
    }*/ 
    
    /** This is fetch all the attributes of Basket*/
    @AuraEnabled 
    public static cscfga__Product_Basket__c getBasket(String basketId) {
    //Start of EDGE-201125::Pradeep Mudenur:Updated SOQL to add ABN associated with the account.
        cscfga__Product_Basket__c prodBasket = [select Id, Name, isEligibilityCheckComplete__c,isEligibilityTriggered__c,cscfga__total_contract_value__c, csbb__Account__c, csbb__Account__r.CIDN__c,csbb__Account__r.ABN__c, csbb__Synchronised_With_Opportunity__c, Primary_Basket__c, csbb__Account__r.Name, cscfga__Opportunity__c, CreatedById, Created_By__c, cscfga__Opportunity__r.Name,cscfga__Opportunity__r.Type, Description__c, csordtelcoa__Basket_Stage__c,Transition_basket_stage__c from cscfga__Product_Basket__c where Id =: basketId];
    //End of EDGE-201125    
        return prodBasket;
    }
    
    /** /// this will fetch all ISDN-BRA,PSTN,ISDN2DID,ISDN2 Products**/
    @AuraEnabled
    public static Map<String,List<String>> getISDNBRAProduct_V2(String basketId, String serviceDTO_V2) {
        ReplicatorGetServiceDataObject_V2 serviceObjDTO_V2 = ReplicatorGetServiceDataObject_V2.parse(serviceDTO_V2);
        Map<String,ReplicatorGetServiceDataObject_V2.SiteDTO_V2> mapSites = new Map<String,ReplicatorGetServiceDataObject_V2.SiteDTO_V2>();
        List<string> lstISDNBRAProd = new List<string>();
        List<string> lstNonISDNBRAProd = new List<string>();
        List<string> preTransISDNBRAProd = getTransitionServices_V2(basketId, serviceObjDTO_V2);
        Map<String,List<String>> mapProdIds = new Map<String,List<String>>();
        for(ReplicatorGetServiceDataObject_V2.SiteDTO_V2 siteObj : serviceObjDTO_V2.site)
        {
            for(ReplicatorGetServiceDataObject_V2.ProductListDTO prod: siteObj.productList)
            {
                
                if(prod.Product_Type == 'ISDN-BRA'|| prod.Product_Type == 'PSTN'|| prod.Product_Type == 'ISDN2' || prod.Product_Type == 'ISDN2DID' )
                {
                    if(!preTransISDNBRAProd.contains(siteObj.ADBOR_Id + '-' + prod.Product_Type))
                    {
                        lstISDNBRAProd.add(siteObj.ADBOR_Id + '-' + prod.Product_Type);
                    }
                }
                else
                {
                    lstNonISDNBRAProd.add(siteObj.ADBOR_Id + '-' + prod.Product_Type);
                }
            }
        }
        
        mapProdIds.put('ISDNBRA', lstISDNBRAProd);
        mapProdIds.put('NonISDNBRA', lstNonISDNBRAProd);
        mapProdIds.put('TransISDNBRAProd', preTransISDNBRAProd);
        return mapProdIds;
    }
    public static List<string> getTransitionServices_V2(String basketId, ReplicatorGetServiceDataObject_V2 serviceObjDTO_V2){
        Map<String, ProductBasketSiteDataObject> mapProdBasSite = fetchSiteFromBasketControllerMap(basketId);
        List<String> lstAdborId = new List<String>();
        List<string> lstServiceId = new List<String>();
        List<string> preSelectedProd = new List<String>();
        for(ProductBasketSiteDataObject prodBasSite : mapProdBasSite.values())
        {
            lstAdborId.add('Service_'+prodBasSite.adBorId);
        }
        for(csord__Service__c ser : [select Id, Primary_FNN__c, csord__Identification__c from csord__Service__c where csord__Identification__c in : lstAdborId]){
            lstServiceId.add(ser.Primary_FNN__c);
        }
        for(ReplicatorGetServiceDataObject_V2.SiteDTO_V2 site : serviceObjDTO_V2.site){
            for(ReplicatorGetServiceDataObject_V2.productListDTO prod : site.productList){
                for(ReplicatorGetServiceDataObject_V2.serviceListDTO servList : prod.serviceList ){
                    for(ReplicatorGetServiceDataObject_V2.ServiceDTO_V2 serv: servList.service){
                        if(lstServiceId.contains(serv.Service_Id))
                        {
                            preSelectedProd.add(site.ADBOR_Id + '-' + prod.Product_Type);
                        }
                    }   
                }
            }
        }
        return preSelectedProd;
    }
    
    @AuraEnabled 
    public static List<ProductBasketSiteDataObject.ProductConfiguration> getExistingSubscription(String configId) {
        List<cscfga__Attribute__c> lstAttribute = [select Name, cscfga__Is_Line_Item__c, Quantity__c, cscfga__Product_Configuration__r.cscfga__Description__c, cscfga__Product_Configuration__r.cscfga__Root_Configuration__c from cscfga__Attribute__c where cscfga__Product_Configuration__r.cscfga__Root_Configuration__c =: configId and cscfga__Is_Line_Item__c = true];
        List<ProductBasketSiteDataObject.ProductConfiguration> lstProdConfigDetails = new List<ProductBasketSiteDataObject.ProductConfiguration>();
        for(cscfga__Attribute__c attr : lstAttribute)
        {
            ProductBasketSiteDataObject.ProductConfiguration prodConfigDetails = new ProductBasketSiteDataObject.ProductConfiguration();
            prodConfigDetails.description = attr.cscfga__Product_Configuration__r.cscfga__Description__c;
            prodConfigDetails.quantity = attr.Quantity__c;
            if(!lstProdConfigDetails.contains(prodConfigDetails))
            {
                lstProdConfigDetails.add(prodConfigDetails);
            }
        }
        
        return lstProdConfigDetails;
    }
    //
    @AuraEnabled
    public static ReplicatorGetServiceDataObject_V2 getNewServiceDTO(ReplicatorGetServiceDataObject serviceDTO){
        ReplicatorGetServiceDataObject_V2 serviceDTO_new= new ReplicatorGetServiceDataObject_V2();
        if(serviceDTO!=null){
            serviceDTO_new.Source_System_Id=ServiceDTO.Source_System_Id;
            serviceDTO_new.CIDN=serviceDTO.CIDN; 
            serviceDTO_new.Correlation_Id=serviceDTO.Correlation_Id; 
            serviceDTO_new.Error_Code=serviceDTO.Error_Code; 
            serviceDTO_new.Error_Description=serviceDTO.Error_Description;
            system.debug('serviceDTO'+serviceDTO);
            serviceDTO_new.site=getSites(serviceDTO);   
        }
        return serviceDTO_new;
    }
    //
    @AuraEnabled
    public static List<ReplicatorGetServiceDataObject_V2.SiteDTO_V2> getSites(ReplicatorGetServiceDataObject serviceDTOResponse){
        
        system.debug('serviceDTOResponse-->'+serviceDTOResponse);
        system.debug('serviceDTOResponse.site-->'+serviceDTOResponse.site);
        List<ReplicatorGetServiceDataObject_V2.SiteDTO_V2> siteList =new List<ReplicatorGetServiceDataObject_V2.SiteDTO_V2>();  
        for(ReplicatorGetServiceDataObject.SiteDTO site:serviceDTOResponse.site){
            Map<String,Map<String,List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2>>> ProdToServListMap = new Map<String,Map<String,List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2>>>();
            Map<String,List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2>> serviceTypeToserviceDTO_v2Map = new Map<String,List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2>>();
            ProdToServListMap=getProductTypeSites(site.productList);
            system.debug('ProdToServListMap-->'+ProdToServListMap);
            ReplicatorGetServiceDataObject_V2.SiteDTO_V2 site_V2= new ReplicatorGetServiceDataObject_V2.SiteDTO_V2();
            List<ReplicatorGetServiceDataObject_V2.productListDTO> prdListDTOList= new List<ReplicatorGetServiceDataObject_V2.productListDTO>();           
            for(String prodType:ProdToServListMap.keyset()){
                ReplicatorGetServiceDataObject_V2.productListDTO productListDTO= new ReplicatorGetServiceDataObject_V2.productListDTO();
                productListDTO.Product_type=prodType;
                productListDTO.serviceList=new List<ReplicatorGetServiceDataObject_V2.serviceListDTO>();
                serviceTypeToserviceDTO_v2Map=ProdToServListMap.get(prodType);
                for(String serviceType:serviceTypeToserviceDTO_v2Map.keyset()){
                    ReplicatorGetServiceDataObject_V2.serviceListDTO servListDTO= new ReplicatorGetServiceDataObject_V2.serviceListDTO();
                    servListDTO.Service_Type=serviceType;
                    servListDTO.service=serviceTypeToserviceDTO_v2Map.get(serviceType);
                    productListDTO.serviceList.add(servListDTO);
                }
                prdListDTOList.add(productListDTO);
            }
            system.debug('prdListDTOList'+prdListDTOList);          
            site_V2.ADBOR_Id=site.ADBOR_Id;
            site_V2.siteName=site.siteName;
            site_V2.Error_Code=site.Error_Code;
            site_V2.Error_Description=site.Error_Description;
            site_V2.productList=prdListDTOList;
            siteList.add(site_V2);
            system.debug('site_V2.productList'+site_V2.productList);
        }
        return  siteList;
    }
    //
    private static Map<String,Map<String,List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2>>> getProductTypeSites(List<ReplicatorGetServiceDataObject.ProductDTO> ProdDTOList){
        Map<String,Map<String,List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2>>> prodTypeToserviceDTO_v2Map= new Map<String,Map<String,List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2>>>(); 
        for(ReplicatorGetServiceDataObject.ProductDTO ProdDTO: ProdDTOList){
            for(ReplicatorGetServiceDataObject.ServiceDTO serv_OLdDTO: ProdDTO.service){
                ReplicatorGetServiceDataObject_V2.ServiceDTO_V2 serviceDTO_V2 =new ReplicatorGetServiceDataObject_V2.ServiceDTO_V2();
                
                serviceDTO_V2.Service_Id=serv_OLdDTO.Service_Id;
                serviceDTO_V2.User_Type = getserviceCharacteristic(serv_OLdDTO.serviceCharacteristic,'User_Type');
                serviceDTO_V2.Service_Type=serv_OLdDTO.Service_Type;
                serviceDTO_V2.serviceExtension= new List<ReplicatorGetServiceDataObject_V2.ServiceExtensionDTO_V2>();
                serviceDTO_V2.In_Flight_Flag=ProdDTO.In_Flight_Flag;
                serviceDTO_V2.In_Flight_Legacy_System=ProdDTO.In_Flight_Legacy_System; 
                serviceDTO_V2.In_Flight_Order_Id=ProdDTO.In_Flight_Order_Id;
                serviceDTO_V2.eligibilityStatus='';
                serviceDTO_V2.eligibilityReason='';
                //Added As a Part of EDGE-48032 start
                serviceDTO_V2.Association_Type = ProdDTO.Association_Type;
                if(ProdDTO.Association_Role != null && ProdDTO.Association_Role != '' ){
                    serviceDTO_V2.Association_Role = ProdDTO.Association_Role;
                }
                else if(serv_OLdDTO.Technical_Association_Role != null){
                    if(serv_OLdDTO.Technical_Association_Role == 'Primary'){
                        
                        serviceDTO_V2.Association_Role = serv_OLdDTO.Technical_Association_Role;
                        
                    }else if(serv_OLdDTO.Technical_Association_Role == 'Secondary'){
                        serviceDTO_V2.Association_Role = 'Auxiliary';
                    }else{
                    serviceDTO_V2.Association_Role = '';
                    }
                }
                
                
                //Added As a Part of EDGE-48032 stop
                for(ReplicatorGetServiceDataObject.ServiceRelationshipDTO servRelationship:serv_OLdDTO.serviceRelationship){
                    system.debug('relationshipDTO'+serv_OLdDTO.serviceRelationship);
                    if(servRelationship.serviceExtension!=null && servRelationship.serviceExtension.size()>0){
                        for(ReplicatorGetServiceDataObject.ServiceExtensionDTO servExtentionOLDDto:servRelationship.serviceExtension){
                            ReplicatorGetServiceDataObject_V2.ServiceExtensionDTO_V2  servExtention= new ReplicatorGetServiceDataObject_V2.ServiceExtensionDTO_V2();
                            servExtention.Services_From =servExtentionOLDDto.Services_From;
                            servExtention.Services_To =servExtentionOLDDto.Services_To;
                            servExtention.eligibilityStatus='';
                            servExtention.eligibilityReason='';
                            serviceDTO_V2.serviceExtension.add(servExtention);                           
                        }   
                    }
                } 
                List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2> serviceList =new List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2>();
                Map<String,List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2>> serviceTypeToserviceDTO_v2Map1 = new Map<String,List<ReplicatorGetServiceDataObject_V2.ServiceDTO_V2>>();
                if(prodTypeToserviceDTO_v2Map.containskey(ProdDTO.Product_Type)){
                    serviceTypeToserviceDTO_v2Map1=prodTypeToserviceDTO_v2Map.get(ProdDTO.Product_Type);
                    if(serviceTypeToserviceDTO_v2Map1.containsKey(serv_OLdDTO.Service_Type)){
                        serviceList=serviceTypeToserviceDTO_v2Map1.get(serv_OLdDTO.Service_Type);
                        serviceList.add(serviceDTO_V2); 
                    }else{
                        serviceList.add(serviceDTO_V2); 
                    }
                    serviceTypeToserviceDTO_v2Map1.put(serv_OLdDTO.Service_Type,serviceList);                           
                }else{
                    if(serviceTypeToserviceDTO_v2Map1.containsKey(serv_OLdDTO.Service_Type)){
                        serviceList=serviceTypeToserviceDTO_v2Map1.get(serv_OLdDTO.Service_Type);
                        serviceList.add(serviceDTO_V2); 
                    }else{
                        serviceList.add(serviceDTO_V2); 
                    }
                    serviceTypeToserviceDTO_v2Map1.put(serv_OLdDTO.Service_Type,serviceList); 
                }
                prodTypeToserviceDTO_v2Map.put(ProdDTO.Product_Type,serviceTypeToserviceDTO_v2Map1); 
            }            
        }
        return prodTypeToserviceDTO_v2Map;
    }
    public static String getserviceCharacteristic(List<ReplicatorGetServiceDataObject.ServiceCharacteristicDTO> serviceCharacteristicList, String UserType){
        String value = '';
        for(ReplicatorGetServiceDataObject.ServiceCharacteristicDTO ServiceCharacteristic : serviceCharacteristicList){
            if(ServiceCharacteristic.name == UserType ){
                value =  ServiceCharacteristic.value;
            }
        }
        return value;
    }
         /**
    * @Author   :   Shubhi Vijayvergia
    * @Date     :   22 May 2019
    * @Desc     :  //to display tree grid data in get services component
    * */
    @AuraEnabled
    public static List<TableWrapper> getServicesTablewrapper(ReplicatorGetServiceDataObject_V2.SiteDTO_V2 sitesValue_V2){
        List<TableWrapper> tablWrapperList=new List<TableWrapper>();
        for(ReplicatorGetServiceDataObject_V2.productListDTO prod:sitesValue_V2.productList){
            TableWrapper tablWrapper=new TableWrapper();
            tablWrapper.Children=new List<TableChildWrapper>();
            tablWrapper.product=prod.Product_Type;
            tablWrapper.keyProduct=sitesValue_V2.ADBOR_Id+'-'+prod.Product_Type;
            String EligibilityStatus='';
            //String Reason='';
            //tableWrapper.eligibilityStatus=;
            //tableWrapper.eligibilityReason=
            tablWrapper.checkValue=prod.checkValue;
            for(ReplicatorGetServiceDataObject_V2.serviceListDTO serv:prod.serviceList)
            {                
                for(ReplicatorGetServiceDataObject_V2.ServiceDTO_V2 serv2:serv.service)
                {
                    TableChildWrapper tablWrapperChild=new TableChildWrapper();
                    tablWrapperChild.Children=new List<TableChildWrapper>();
                    tablWrapperChild.product=serv2.Service_Id;
                    tablWrapperChild.eligibilityStatus=serv2.eligibilityStatus;
                    tablWrapperChild.eligibilityReason=serv2.eligibilityReason;                    
                    tablWrapperChild.checkValue=prod.checkValue;
                    tablWrapperChild.keyProduct=sitesValue_V2.ADBOR_Id+'-'+serv2.Service_Id;
                    if(tablWrapperChild.eligibilityStatus=='Eligible'){
                            tablWrapperChild.iconName='action:approval';
                        }else if(tablWrapperChild.eligibilityStatus=='Ineligible') {
                           tablWrapperChild.iconName='utility:warning'; 
                        }
                    for(ReplicatorGetServiceDataObject_V2.ServiceExtensionDTO_V2 servext:serv2.serviceExtension){
                        TableChildWrapper tablWrapperGrandChild=new TableChildWrapper();
                        tablWrapperGrandChild.Children=new List<TableChildWrapper>();
                        tablWrapperGrandChild.product=servext.Services_From+':'+servext.Services_To;
                        tablWrapperGrandChild.keyProduct=sitesValue_V2.ADBOR_Id+'-'+tablWrapperGrandChild.product;
                        tablWrapperGrandChild.eligibilityStatus=servext.eligibilityStatus;
                        tablWrapperGrandChild.eligibilityReason=servext.eligibilityReason;
                        tablWrapperGrandChild.checkValue=prod.checkValue;
                        if(tablWrapperGrandChild.eligibilityStatus=='Eligible'){
                            tablWrapperGrandChild.iconName='action:approval';
                        }else if(tablWrapperGrandChild.eligibilityStatus=='Ineligible') {
                           tablWrapperGrandChild.iconName='utility:warning'; 
                        }
                        tablWrapperChild.Children.add(tablWrapperGrandChild);
                    }
                    tablWrapper.Children.add(tablWrapperChild);
                    if(EligibilityStatus==''){
                        EligibilityStatus='Eligible';
                    }
                }
            }
            tablWrapper.eligibilityStatus=prod.eligibilityStatus;
            if(tablWrapper.eligibilityStatus=='Eligible'){
                tablWrapper.iconName='action:approval';
            }else if(tablWrapper.eligibilityStatus=='Ineligible'){
               tablWrapper.iconName='utility:warning'; 
            }
            tablWrapper.eligibilityReason='';
            tablWrapperList.add(tablWrapper);
        }
        system.debug('tablWrapperList--'+tablWrapperList);
        return tablWrapperList;
    }
         /**
    * @Author   :   Shubhi Vijayvergia
    * @Date     :   22 May 2019
    * @Desc     :  //to disable buttons and lock screen 
    * */
    @AuraEnabled   
    public static List<Integer> getEligibityStatus(String basketId){
        System.debug('getEligibityStatus-->>');
        List<Integer> progressRing = new List<Integer>();
        try
        {
            cscfga__Product_Basket__c prodBasket = [Select id , isEligibilityCheckComplete__c , isEligibilityTriggered__c,Transition_basket_stage__c from cscfga__Product_Basket__c where id = : basketId ];
        
            List <cscfga__Product_Configuration__c> prodConfig = [select id , name ,  isEligibleForTriggered__c,isEligibleForTransition__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__r.Id = :  basketId and (name = 'IP Site' OR cscfga__Product_Definition__r.product_Specification__c IN: listproductSpecNgUC)];
            System.debug('prodConfig '+prodConfig);
            //List<TramasElgibilityCallbackResponse__c> tm1List=[select id , Product_Configuration__r.id ,Eligibility_Criteria__c from TramasElgibilityCallbackResponse__c where Product_Basket__c = : basketId AND Product_Configuration__c in : prdConfig order by lastmodifiedDate desc];
            
            //START: Modified by Sajal for DIGI-24043
            Map<id,List<TramasElgibilityCallbackResponse__c>> tm1PCMap=new Map<id,List<TramasElgibilityCallbackResponse__c>>();
            for(TramasElgibilityCallbackResponse__c tm1:[SELECT Id , Product_Configuration__c,Eligibility_Criteria__c from TramasElgibilityCallbackResponse__c where Product_Basket__c = : basketId AND Product_Configuration__c in : prodConfig AND Eligibility_Criteria__c != 'Reset' ORDER BY lastmodifiedDate desc]){//Modified by Sajal
                if(!tm1PCMap.containsKey(tm1.Product_Configuration__c)){                
                    tm1PCMap.put(tm1.Product_Configuration__c,new List<TramasElgibilityCallbackResponse__c>{});
                }
                tm1PCMap.get(tm1.Product_Configuration__c).add(tm1);//Added by Sajal
            }
            //END for DIGI-24043
            system.debug('prodConfig ---> '+prodConfig);
            system.debug('tm1PCMap ---> '+tm1PCMap);
            Integer totalPCItems = 0;
            Integer totalPCEligibiltyDOne = 0;
            Integer flag =1;

            //START: Added by Sajal for DIGI-24043
            for(Id pcid: tm1PCMap.keyset()){
                for(TramasElgibilityCallbackResponse__c tms: tm1PCMap.get(pcid)){
                    totalPCItems = totalPCItems + 1;
                }
            }
            //END for DIGI-24043
        
            progressRing.add(totalPCItems);
            
            Integer isEligibilityResultcalculatedCount=0;
            for (cscfga__Product_Configuration__c pc : prodConfig ){
            //pc.isEligibleForTransition__c
                if(tm1PCMap.containskey(pc.id)){
                    if (pc.isEligibleForTriggered__c == true)
                        totalPCEligibiltyDOne++;
                    if (pc.isEligibleForTriggered__c == false)
                        flag =0;
                    //START: Added by Sajal for DIGI-24043
                    for(Id pcId: tm1PCMap.keySet()){
                        for(TramasElgibilityCallbackResponse__c tms: tm1PCMap.get(pc.Id)){
                            if(tms.Eligibility_Criteria__c.containsIgnoreCase('Eligible')){
                                isEligibilityResultcalculatedCount++;
                            }
                        }
                    }
                    //END for DIGI-24043
                }
                    
            }
            system.debug('totalPCEligibiltyDOne ---> '+totalPCEligibiltyDOne);
            system.debug('isEligibilityResultcalculatedCount ---> '+isEligibilityResultcalculatedCount);
            if(totalPCItems == isEligibilityResultcalculatedCount){//Modified by Sajal for DIGI-24043
                prodBasket.isEligibilityCheckComplete__c=true;
                if(prodbasket.Transition_basket_stage__c=='Check Eligibility Triggered'){
                   prodbasket.Transition_basket_stage__c='Check Eligibility Completed';
                }
                    System.debug('prodBasket @@@###' + prodBasket);
                    update prodBasket; 
            }
            system.debug('totalPCEligibiltyDOne ---> '+isEligibilityResultcalculatedCount);
            system.debug('totalPCItems ---> '+totalPCItems);
            //progressRing.put(totalPCItems,totalPCEligibiltyDOne);
            progressRing.add(isEligibilityResultcalculatedCount);
            progressRing.add(flag);
            if (prodBasket.isEligibilityCheckComplete__c == false)
            progressRing.add(0);
            if (prodBasket.isEligibilityTriggered__c == false)
            progressRing.add(0);
            else 
            progressRing.add(1);
                system.debug('return Map ---> '+progressRing);
            
            return progressRing;
            
        }
        catch(Exception e)
        {
            Logger.getLogger(CompUtilityReplicatorManager.class + ':' +basketId ).debug(e);
            Logger.exitLogger();
            return null;
        }
    }
    
    /*****************************************************************************************************************************
 * Story: EDGE-199057
 * Team : Osaka
 * Developer : Abhishek
 * Description: This method is to check whether MobileTramasEligibility.json(related to MobileTramaEligibility) has been updated with CallBack response
 *         and only refresh the page on Transition screen if response is updated.
 * ************************************************************************************************************************************/
    @AuraEnabled
    public static boolean getEligibilityStatusMobile(String basketId){
        Boolean isResponseUpdated;

        try{
            cscfga__Product_Basket__c prodBasket = getBasket(basketId);
        
            List <cscfga__Product_Configuration__c> prodConfig = [select id , name ,  isEligibleForTriggered__c,isEligibleForTransition__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__r.Id = :  basketId and (cscfga__Product_Definition__r.product_Specification__c IN: listproductSpecMobile)];
            System.debug('prodConfig '+prodConfig);
            
            List<MobileTramasElgibility__c> mobileTramRec = new List<MobileTramasElgibility__c>();

            mobileTramRec = [SELECT id,Type__c FROM MobileTramasElgibility__c where Product_Basket__c = :basketId AND Product_Configuration__c in :prodConfig ORDER BY CreatedDate DESC LIMIT 1];
            System.debug('Mobile Tram Record::::' +mobileTramRec);
            
            List<Attachment> attRec = new List<Attachment>();
            if(mobileTramRec.size() > 0){
                attRec = [SELECT id, body from Attachment where ParentId = :mobileTramRec[0].id ORDER BY CreatedDate DESC LIMIT 1];
            }
            
            if(attRec.size() > 0){
                //EDGE-198375:- Added below condition for handling TM0/TM1 failure/error scenarios
                if(prodbasket.Transition_basket_stage__c=='Check Eligibility Triggered'){
                if(attRec[0].body.size()>0 && mobileTramRec[0].Type__c == 'TM1'){
                isResponseUpdated = true;
                prodBasket.isEligibilityCheckComplete__c=true;
                if(prodbasket.Transition_basket_stage__c=='Check Eligibility Triggered'){
                    prodbasket.Transition_basket_stage__c='Check Eligibility Completed';
                }
                System.debug('prodBasket Mobile' + prodBasket);
                update prodBasket; 
                // DIGI-1751 START
                List<ChatterUtilityClass.ChatterFeedWrapper> feedsLsts = new List<ChatterUtilityClass.ChatterFeedWrapper>();
                    
                String communityId=null;
                String subjectId=prodBasket.id;
                System.debug('subjectId@@@ ' + subjectId);
                String textWithMentions='The check eligibility call has been completed for the basket'+ prodBasket.Name+'{'+prodBasket.CreatedById+'}\n'+ URL.getSalesforceBaseUrl().toExternalForm()+'/'+prodBasket.Id;
                feedsLsts.add(new ChatterUtilityClass.ChatterFeedWrapper(communityId,subjectId, textWithMentions ));
                System.debug('feedsLsts@@@@' + feedsLsts);
                ChatterUtilityClass.chatterNotificationHelper(feedsLsts);
                     
                    
                user u= [SELECT Id, Name, CreatedById, Email, CreatedBy.Name FROM User WHERE Id = :prodBasket.createdById][0];
                        
                CustomNotificationType notificationType = [SELECT Id, DeveloperName 
                                                               FROM CustomNotificationType 
                                                               WHERE DeveloperName='Notification_to_Product_Basket_Creator'];
                    
                CustomNotificationFromApex.sendNotificationsToBasketUser(notificationType, prodBasket, prodBasket.Name, textWithMentions); 
                   
                    
                Messaging.SingleEmailMessage m = new Messaging.SingleEmailMessage();
                //m.setWhatId(prodBasket.id);
                m.setSubject(prodBasket.id);
                m.settoaddresses(new string[] {  u.email });
                //m.setsaveasactivity(true);
                m.setPlainTextBody(textWithMentions);
                messaging.sendemail(new messaging.email[] { m });
               // DIGI-1751 END
                }
            else
            {
                isResponseUpdated = false;
            }
        
        }
            }

        }
        catch(Exception e)
        {
            Logger.getLogger(CompUtilityReplicatorManager.class + ':' +basketId ).debug(e);
            Logger.exitLogger();
            return null;
        }

        return isResponseUpdated;
    }
         /**
    * @Author   :   Shubhi Vijayvergia
    * @Date     :   22 May 2019
    * @Desc     :  //to Handle Button Hide Show
    * */
    @AuraEnabled   
    public static Map<String,Boolean> HandleButtonHideShow(String basketId)
    {
        //List<Integer> progressRing = new List<Integer>();
        Map<String,Boolean> buttonvaluemap=new Map<String,Boolean>();
        cscfga__Product_Basket__c prodBasket = [Select id , isEligibilityCheckComplete__c , isEligibilityTriggered__c from cscfga__Product_Basket__c where id = : basketId ];
        if(prodBasket.isEligibilityTriggered__c==false && prodBasket.isEligibilityCheckComplete__c==false ){
            buttonvaluemap.put('displayTransBtn',true);
            buttonvaluemap.put('checkEligibilityInprogress',false);
            buttonvaluemap.put('checkEligibilityComplete',false);
        }
        else if(prodBasket!=null && prodBasket.isEligibilityTriggered__c==true && prodBasket.isEligibilityCheckComplete__c==false){
            buttonvaluemap.put('displayTransBtn',false);
            buttonvaluemap.put('checkEligibilityInprogress',true);
            buttonvaluemap.put('checkEligibilityComplete',false);
        }
        else if(prodBasket!=null && prodBasket.isEligibilityTriggered__c==true && prodBasket.isEligibilityCheckComplete__c==true){
            buttonvaluemap.put('displayTransBtn',false);
            buttonvaluemap.put('checkEligibilityInprogress',false);
            buttonvaluemap.put('checkEligibilityComplete',true);
            //buttonvaluemap.put('reviewConfirmdisabled',);
        }else{
            buttonvaluemap.put('displayTransBtn',true);
            buttonvaluemap.put('checkEligibilityInprogress',false);
            buttonvaluemap.put('checkEligibilityComplete',false);
        }
        return buttonvaluemap;
    }
     /**
    * @Author   :   Shubhi Vijayvergia
    * @Date     :   22 May 2019
    * @Desc     :  //to disable review and confirm button
    * */
    
    @AuraEnabled
    public static Map<String,ReplicatorGetServiceDataObject_V2.SiteDTO_V2> HandleCheckValueOnProductSelectDeselect(Map<String,ReplicatorGetServiceDataObject_V2.SiteDTO_V2> sitesMap_v2,List<String> selectedProduct , String adborid){
        system.debug('map'+sitesMap_v2);
        system.debug('List'+ selectedProduct);
        system.debug('adborid'+adborid);
        if(sitesMap_v2.containsKey(adborid)){ 
            ReplicatorGetServiceDataObject_V2.SiteDTO_V2 siteObj=sitesMap_v2.get(adborid);
            for(ReplicatorGetServiceDataObject_V2.ProductListDTO prod: siteObj.productList)
            {
                system.debug('adborid-->'+siteObj.ADBOR_Id);
                system.debug('prod-->'+prod);
                string aboridProduct=siteObj.ADBOR_Id+'-'+prod.Product_type;
                system.debug('aboridProduct-->'+aboridProduct);
                if(selectedProduct!=null && selectedProduct.contains(aboridProduct)){
                    prod.checkValue=true;
                }else{
                    prod.checkValue=false;
                }
            }
            
        }
        system.debug('----sitesMap_v2----->'+sitesMap_v2);
        return  sitesMap_v2;    
    }
       /**
    * @Author   :   Shubhi Vijayvergia
    * @Date     :   22 May 2019
    * @Desc     :  //to disable review and confirm button
    * */
    
    @AuraEnabled
    public static Boolean reviewConfirmedDisabledCalculate(Map<String,ReplicatorGetServiceDataObject_V2.SiteDTO_V2> sitesMap_v2,String basketID){
        Boolean reviewConfirmedDisabled=false;
        if(sitesMap_v2!=null)
        {   
            for(ReplicatorGetServiceDataObject_V2.SiteDTO_V2 siteObj:sitesMap_v2.values())
            {   
                
                for(ReplicatorGetServiceDataObject_V2.ProductListDTO prod: siteObj.productList)
                {
                    if(prod.eligibilityStatus=='Ineligible')
                    {
                        reviewConfirmedDisabled=true;
                        return reviewConfirmedDisabled;
                    }   
                }
            }
        }
        /*if(reviewConfirmedDisabled==false){
            /*cscfga__Product_Basket__c prodbasket=new cscfga__Product_Basket__c();
            try
            {
                if(basketId!=null)
                {
                    prodbasket=[select id,Transition_basket_stage__c from cscfga__Product_Basket__c where id =:basketId];
                    prodbasket.Transition_basket_stage__c='Review & Confirm';
                    update prodbasket;
                }   
            }
            catch(Exception e){
                System.debug('Exception: ' + e);
                Logger.getLogger(CompUtilityReplicatorManager.class + ':' +basketId ).debug(e);
                Logger.exitLogger();
                return null;    
            }
        }*/
        return reviewConfirmedDisabled;
    }
        /**
    * @Author   :   Shubhi Vijayvergia
    * @Date     :   22 May 2019
    * @Desc     :  //Data for review and cofirm table
    * */
    
    @AuraEnabled
    public static List<TransitionReviewConfirmWrapper> getReviewConfirmData(Map<String,ReplicatorGetServiceDataObject_V2.SiteDTO_V2> sitesMap_v2,Map<String,ProductBasketSiteDataObject> siteDTOMap)
    {
        system.debug('JSondata map1'+sitesMap_v2);
        system.debug('site map'+ siteDTOMap);
        List<TransitionReviewConfirmWrapper> reviewConfirmWrapperList=new List<TransitionReviewConfirmWrapper>();
        for(ReplicatorGetServiceDataObject_V2.SiteDTO_V2 siteObj:sitesMap_v2.values())
        {   
            TransitionReviewConfirmWrapper reviwCnfrm=new TransitionReviewConfirmWrapper();
            for(ReplicatorGetServiceDataObject_V2.ProductListDTO prod: siteObj.productList)
            {
            reviwCnfrm=new TransitionReviewConfirmWrapper();
                if(siteDTOMap.containsKey(siteObj.ADBOR_Id) && prod.checkValue==true)
                {
                    reviwCnfrm.siteId=siteObj.ADBOR_Id+prod.Product_type;
                    reviwCnfrm.offer=siteDTOMap.get(siteObj.ADBOR_Id).pcrName;
                    reviwCnfrm.legacyTechnology=prod.Product_type;
                    reviwCnfrm.orderType=siteDTOMap.get(siteObj.ADBOR_Id).orderType;
                    reviwCnfrm.siteName=siteDTOMap.get(siteObj.ADBOR_Id).siteName;
                    reviwCnfrm.locality=siteDTOMap.get(siteObj.ADBOR_Id).locality;
                    reviwCnfrm.state=siteDTOMap.get(siteObj.ADBOR_Id).state;
                    String fnn='';
                    for(ReplicatorGetServiceDataObject_V2.serviceListDTO serv:prod.serviceList)
                    {                
                        for(ReplicatorGetServiceDataObject_V2.ServiceDTO_V2 serv2:serv.service)
                        {
                            if(fnn==''){
                                fnn+=serv2.Service_Id;
                            }else{
                                fnn+=','+serv2.Service_Id;
                            }   
                            for(ReplicatorGetServiceDataObject_V2.ServiceExtensionDTO_V2 servext:serv2.serviceExtension)
                            {
                                if(fnn==''){
                                    fnn+=servext.Services_From+':'+servext.Services_To;
                                }else{
                                    fnn+=','+servext.Services_From+':'+servext.Services_To;
                                }
                            }
                            reviwCnfrm.fnn=fnn;
                        }
                    }
                }
                reviewConfirmWrapperList.add(reviwCnfrm);
            }
           // reviewConfirmWrapperList.add(reviwCnfrm);
        }
        return reviewConfirmWrapperList;        
    }
    
        /**
    * @Author   :   Maq
    * @Date     :   02 April 2020
    * @Desc     :  //updated Data for review and cofirm table
    * */
    
    @AuraEnabled
    public static Map<String, List<TransitionReviewConfirmWrapper>> getReviewConfirmDataNew(Map<String,ReplicatorGetServiceDataObject_V2.SiteDTO_V2> sitesMap_v2,Map<String,ProductBasketSiteDataObject> siteDTOMap)
    {
        system.debug('sitesMap_v2.values()'+sitesMap_v2.values());
        Map<String, List<TransitionReviewConfirmWrapper>> allSelectedCWPData = New Map<String, List<TransitionReviewConfirmWrapper>>();
        List<TransitionReviewConfirmWrapper> reviewConfirmWrapperList=new List<TransitionReviewConfirmWrapper>();
        for(ReplicatorGetServiceDataObject_V2.SiteDTO_V2 siteObj:sitesMap_v2.values())
        { 
            List<TransitionReviewConfirmWrapper> reviewConfirmWrapperListTemp=new List<TransitionReviewConfirmWrapper>();
            TransitionReviewConfirmWrapper reviwCnfrm=new TransitionReviewConfirmWrapper();
            for(ReplicatorGetServiceDataObject_V2.ProductListDTO prod: siteObj.productList)
            {
            reviwCnfrm=new TransitionReviewConfirmWrapper();
            system.debug('siteDTOMap'+siteDTOMap+'siteObj.ADBOR_Id'+siteObj.ADBOR_Id+'prod.checkValue'+prod.checkValue);
                if(siteDTOMap.containsKey(siteObj.ADBOR_Id) && prod.checkValue==true)
                {
                    reviwCnfrm.siteId=siteObj.ADBOR_Id+prod.Product_type;
                    reviwCnfrm.offer=siteDTOMap.get(siteObj.ADBOR_Id).pcrName;
                    reviwCnfrm.legacyTechnology=prod.Product_type;
                    reviwCnfrm.orderType=siteDTOMap.get(siteObj.ADBOR_Id).orderType;
                    reviwCnfrm.siteName=siteDTOMap.get(siteObj.ADBOR_Id).siteName;
                    reviwCnfrm.locality=siteDTOMap.get(siteObj.ADBOR_Id).locality;
                    reviwCnfrm.state=siteDTOMap.get(siteObj.ADBOR_Id).state;
                    String fnn='';
                    for(ReplicatorGetServiceDataObject_V2.serviceListDTO serv:prod.serviceList)
                    {                
                        for(ReplicatorGetServiceDataObject_V2.ServiceDTO_V2 serv2:serv.service)
                        {
                            if(fnn==''){
                                fnn+=serv2.Service_Id;
                            }else{
                                fnn+=','+serv2.Service_Id;
                            }   
                            for(ReplicatorGetServiceDataObject_V2.ServiceExtensionDTO_V2 servext:serv2.serviceExtension)
                            {
                                if(fnn==''){
                                    fnn+=servext.Services_From+':'+servext.Services_To;
                                }else{
                                    fnn+=','+servext.Services_From+':'+servext.Services_To;
                                }
                            }
                            reviwCnfrm.fnn=fnn;
                        }
                    }
                }
                reviewConfirmWrapperList.add(reviwCnfrm);
                reviewConfirmWrapperListTemp.add(reviwCnfrm);
            }
            if(allSelectedCWPData.containsKey(siteObj.ADBOR_Id)) {
                allSelectedCWPData.get(siteObj.ADBOR_Id).addall(reviewConfirmWrapperListTemp);
            } 
            else {
                allSelectedCWPData.put(siteObj.ADBOR_Id, reviewConfirmWrapperListTemp );
            }
        }
        return allSelectedCWPData;        
    }
    
    //Initialize parentchildmap in computilitygetservices_new component
    @AuraEnabled
    public static Map<Object,Object>  initializeGridDataMap(){
        return new Map<Object,Object>();
    }
    
    /**
    * @Author   :   Shubhi Vijayvergia
    * @Date     :   22 May 2019
    * @Desc     :  to update isEligibilityTriggered__c field of basket
    * */    
    @AuraEnabled
   public static  cscfga__Product_Basket__c setIsEligibilityTriggeredUpdate(Id basketId){
        cscfga__Product_Basket__c prodbasket=new cscfga__Product_Basket__c();
        try
        {
            if(basketId!=null)
            {
                prodbasket=[select Id, Name, isEligibilityCheckComplete__c,isEligibilityTriggered__c,cscfga__total_contract_value__c, csbb__Account__c, csbb__Account__r.CIDN__c, csbb__Synchronised_With_Opportunity__c, Primary_Basket__c, csbb__Account__r.Name, cscfga__Opportunity__c, CreatedById, Created_By__c, cscfga__Opportunity__r.Name, Description__c, csordtelcoa__Basket_Stage__c,Transition_basket_stage__c from cscfga__Product_Basket__c where Id =: basketId];
                prodbasket.isEligibilityTriggered__c=true;
                update prodbasket;
            }   
        }
        catch(Exception e){
            System.debug('Exception: ' + e);
            Logger.getLogger(CompUtilityReplicatorManager.class + ':' +basketId ).debug(e);
            Logger.exitLogger();
            return null;    
        }
        return prodbasket;
    }
        /**
    * @Author   :   Shubhi Vijayvergia
    * @Date     :   22 May 2019
    * @Desc     :  //to update Transition basket stage to initial
    * */
    @AuraEnabled  
    public static cscfga__Product_Basket__c updatetransitionBasketStagetoInitial(String basketId){
        cscfga__Product_Basket__c prodbasket=new cscfga__Product_Basket__c();
        try
        {
            if(basketId!=null)
            {
                prodbasket=[select Id, Name, isEligibilityCheckComplete__c,cscfga__Opportunity__r.Type,isEligibilityTriggered__c,cscfga__total_contract_value__c, csbb__Account__c, csbb__Account__r.CIDN__c, csbb__Synchronised_With_Opportunity__c, Primary_Basket__c, csbb__Account__r.Name, cscfga__Opportunity__c, CreatedById, Created_By__c, cscfga__Opportunity__r.Name, Description__c, csordtelcoa__Basket_Stage__c,Transition_basket_stage__c from cscfga__Product_Basket__c where Id =: basketId];
                if(prodbasket.Transition_basket_stage__c==null){
                    prodbasket.Transition_basket_stage__c='Initial';
                    update prodbasket;
                }
            }   
        }
        catch(Exception e){
            System.debug('Exception: ' + e);
            Logger.getLogger(CompUtilityReplicatorManager.class + ':' +basketId ).debug(e);
            Logger.exitLogger();
            return null;    
        }
        return prodbasket;
        
    }
    
    /**
    * @Author   :   Shubhi Vijayvergia
    * @Date     :   22 May 2019
    * @Desc     :  //to update Transition basket stage to checkEligibility
    * */
    @AuraEnabled  
    public static cscfga__Product_Basket__c updatetransitionBasketStagetoCheckEligibility(String basketId){
        cscfga__Product_Basket__c prodbasket=new cscfga__Product_Basket__c();
        try
        {
            if(basketId!=null)
            {
                prodbasket=[select Id, Name, isEligibilityCheckComplete__c,isEligibilityTriggered__c,cscfga__total_contract_value__c, csbb__Account__c, csbb__Account__r.CIDN__c, csbb__Synchronised_With_Opportunity__c, Primary_Basket__c, csbb__Account__r.Name, cscfga__Opportunity__c, CreatedById, Created_By__c, cscfga__Opportunity__r.Name, Description__c, csordtelcoa__Basket_Stage__c,Transition_basket_stage__c from cscfga__Product_Basket__c where Id =: basketId];
                if(prodbasket.Transition_basket_stage__c=='Modify Selection' || prodbasket.Transition_basket_stage__c=='Initial')
                {
                    prodbasket.Transition_basket_stage__c='Check Eligibility Triggered';
                    prodbasket.isEligibilityTriggered__c=true;
                    update prodbasket;
                }
            }   
        }
        catch(Exception e){
            System.debug('Exception: ' + e);
            Logger.getLogger(CompUtilityReplicatorManager.class + ':' +basketId ).debug(e);
            Logger.exitLogger();
            return null;    
        }
        return prodbasket;      
    }
    /**
    * @Author   :   Shubhi Vijayvergia
    * @Date     :   22 May 2019
    * @Desc     :  //to update Transition basket stage to modify selection
    * */
    @AuraEnabled  
    public static cscfga__Product_Basket__c updatetransitionBasketStagetoModifySelection(String basketId){
        cscfga__Product_Basket__c prodbasket=new cscfga__Product_Basket__c();
        try
        {
            if(basketId!=null)
            {
                prodbasket=[select Id, Name, isEligibilityCheckComplete__c,isEligibilityTriggered__c,cscfga__total_contract_value__c, csbb__Account__c, csbb__Account__r.CIDN__c, csbb__Synchronised_With_Opportunity__c, Primary_Basket__c, csbb__Account__r.Name, cscfga__Opportunity__c, CreatedById, Created_By__c, cscfga__Opportunity__r.Name, Description__c, csordtelcoa__Basket_Stage__c,Transition_basket_stage__c from cscfga__Product_Basket__c where Id =: basketId];
                if(prodbasket.Transition_basket_stage__c=='Check Eligibility Completed'){
                    prodbasket.Transition_basket_stage__c='Modify Selection';
                    update prodbasket;
                }
            }   
        }
        catch(Exception e){
            System.debug('Exception: ' + e);
            Logger.getLogger(CompUtilityReplicatorManager.class + ':' +basketId ).debug(e);
            Logger.exitLogger();
            return null;    
        }
        return prodbasket;
        
    }
    /**
    * @Author   :   Shubhi Vijayvergia
    * @Date     :   22 May 2019
    * @Desc     :  //to update Transition basket stage to review&Confirm
    * */
    @AuraEnabled  
    public static cscfga__Product_Basket__c updatetransitionBasketStagetoReviewConfirm(String basketId){
        cscfga__Product_Basket__c prodbasket=new cscfga__Product_Basket__c();
        try
        {
            if(basketId!=null)
            {
                prodbasket=[select Id, Name, isEligibilityCheckComplete__c,isEligibilityTriggered__c,cscfga__total_contract_value__c, csbb__Account__c, csbb__Account__r.CIDN__c, csbb__Synchronised_With_Opportunity__c, Primary_Basket__c, csbb__Account__r.Name, cscfga__Opportunity__c, CreatedById, Created_By__c, cscfga__Opportunity__r.Name, Description__c, csordtelcoa__Basket_Stage__c,Transition_basket_stage__c from cscfga__Product_Basket__c where Id =: basketId];
                prodbasket.Transition_basket_stage__c='Review & Confirm';
                update prodbasket;
            }   
        }
        catch(Exception e){
            System.debug('Exception: ' + e);
            Logger.getLogger(CompUtilityReplicatorManager.class + ':' +basketId ).debug(e);
            Logger.exitLogger();
            return null;    
        }
        return prodbasket;      
    }
         /**
    * @Author   :   Shubhi Vijayvergia
    * @Date     :   13 June 2019
    * @Desc     :  //to get selected product (adborid and product combination)
    * */
    @AuraEnabled  
    public static List<String> updateSelectedProduct(Map<String,ReplicatorGetServiceDataObject_V2.SiteDTO_V2> sitesMap_v2){
        system.debug('sites map sitesMap_v2'+sitesMap_v2);
        List<String> SelectedProductList=new List<String>();
        for(ReplicatorGetServiceDataObject_V2.SiteDTO_V2 siteObj:sitesMap_v2.values())
        {   
            for(ReplicatorGetServiceDataObject_V2.ProductListDTO prod: siteObj.productList)
            {
                if(prod.checkValue==true){
                    SelectedProductList.add(siteObj.ADBOR_Id+'-'+prod.Product_type);
                }
            }
        }
        return SelectedProductList;        
    }
    
        /**
* @Author   :   Maq
* @Date     :   07 July 2019
* @Desc     :  //merge all the response for different site
* */
    @AuraEnabled  
    public static ReplicatorGetServiceDataObject_V2  mergeIndividualSiteResponse(ReplicatorGetServiceDataObject_V2 clickedResponse,ReplicatorGetServiceDataObject_V2 previousResponses, String selectedAdborid, String cidnResponse){
        system.debug('*******clickedResponse => '+clickedResponse);
        system.debug('*******previousResponses => '+previousResponses);
        Boolean alreadyExistFlag = false;
        ReplicatorGetServiceDataObject_V2 serviceDTO_new = new ReplicatorGetServiceDataObject_V2();
        List < ReplicatorGetServiceDataObject_V2.SiteDTO_V2 > siteListFinal = new List < ReplicatorGetServiceDataObject_V2.SiteDTO_V2 > ();
        
        for(ReplicatorGetServiceDataObject_V2.SiteDTO_V2 mSiteListValue : previousResponses.site){
            if(selectedAdborid == mSiteListValue.ADBOR_Id){
                alreadyExistFlag = true;
                break;              
            }

        }
        if(alreadyExistFlag == false){
            siteListFinal = previousResponses.site;
            siteListFinal.addall(clickedResponse.site);
            
        }
        else{
        system.debug('*******FinalResponses No Change=> '+JSON.serialize(previousResponses));
         return previousResponses;
        }
        serviceDTO_new.serviceCount = clickedResponse.serviceCount;              
        serviceDTO_new.CIDN = cidnResponse;
        serviceDTO_new.Source_System_Id = 'Replicator';
        serviceDTO_new.Correlation_Id = clickedResponse.Correlation_Id; 
        serviceDTO_new.Error_Code=''; 
        serviceDTO_new.Error_Description='';
        serviceDTO_new.site = siteListFinal;   
        system.debug('*******FinalResponses => '+JSON.serialize(serviceDTO_new));
        return serviceDTO_new; 
       
    }
    
         @AuraEnabled
    public static List<Attachment> insertJSONResponseMobile(TransitionDataDTO TransitionDataJSON, List<ReplicatorGetServiceManager.TableWrapper> selectedList, String basketId, Boolean SendCallout) {
        List<Attachment> attachmentJSONMobileList = new List<Attachment>();
        try{    
         system.debug('*******FinalResponses No Change=> '+JSON.serialize(TransitionDataJSON));
          attachmentJSONMobileList = ReplicatorGetServiceManager.insertJSONResponseMobile(TransitionDataJSON, selectedList, basketId, SendCallout);
        }
        catch(Exception e){
            return null;
        }
        return attachmentJSONMobileList;
    }
    
      /* @Author   :   Maqsood Alam
* @Date     :   21 July 2019
* @Desc     :   <getservices> As a Sales Enterprise B2B and partner user, I want to see list of customer's legacy mobile services as part of transition order journey So that I can verify the services customer would like to transition.
* @US       :   EDGE-66392
* @Status   :   Development
* */
    @AuraEnabled
    public static List < ReplicatorGetServiceManager.TableWrapper > getMobileServicesTablewrapper(TransitionDataDTO transitionMoblileData, String basketId) {
        List < ReplicatorGetServiceManager.TableWrapper > mobileTableWrapperList = new List < ReplicatorGetServiceManager.TableWrapper > ();
        List < ReplicatorGetServiceManager.TableWrapper > mobileTableWrapperListFiltered = new List < ReplicatorGetServiceManager.TableWrapper > ();
            String TransitionJSONDataMobile = 'TransitionData.json';
            String mobileOfferName = 'CWP Mobility';
            
        List < Attachment > attachmentListMobile = [SELECT Id, ParentId, Name, Body from Attachment WHERE ParentId IN(SELECT id FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c = :basketId AND cscfga__Product_Definition__r.product_Specification__c IN: listproductSpecMobile) AND Name = :TransitionJSONDataMobile LIMIT 1];
            if (attachmentListMobile.size() > 0) {
                mobileTableWrapperList = ReplicatorGetServiceManager.getMobileServicesTablewrapper(TransitionDataDTO.parse(attachmentListMobile[0].Body.toString()),basketId);

            }
            else{
                mobileTableWrapperList = ReplicatorGetServiceManager.getMobileServicesTablewrapper(transitionMoblileData,basketId);
            }

            for(ReplicatorGetServiceManager.TableWrapper mobileData : mobileTableWrapperList){
                if(mobileData.checkValue == true){
                    mobileTableWrapperListFiltered.add(mobileData);
                }
            }
        return mobileTableWrapperListFiltered;
    }

/* @Author  :   Maqsood Alam
* @Date     :   09 Dec 2019
* @Desc     :   
* @US       :   
* @Status   :   Development
* */
    @AuraEnabled
    public static List < ReplicatorGetServiceManager.NgUCTableWrapper > getNgUcServicesTablewrapper(TransitionDataDTO transitionMoblileData, String basketId) {
        List < ReplicatorGetServiceManager.NgUCTableWrapper > ngUcWrapperList = new List < ReplicatorGetServiceManager.NgUCTableWrapper > ();
        List < ReplicatorGetServiceManager.NgUCTableWrapper > ngUcWrapperListFiltered = new List < ReplicatorGetServiceManager.NgUCTableWrapper > ();
        String TransitionJSONDataNguc = Label.NgUcTransitionName;
        
        List < Attachment > attachmentListNgUc = [SELECT Id, ParentId, Name, Body from Attachment WHERE ParentId IN(SELECT id FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c = :basketId AND cscfga__Product_Definition__r.product_Specification__c IN: listproductSpecNgUc) AND Name = :TransitionJSONDataNguc LIMIT 1];
        if (attachmentListNgUc.size() > 0) {
            ngUcWrapperList = ReplicatorGetServiceManager.getNgUCServicesTablewrapperV1(TransitionDataDTO.parse(attachmentListNgUc[0].Body.toString()),basketId);
            
        }
        else{
            ngUcWrapperList = ReplicatorGetServiceManager.getNgUCServicesTablewrapperV1(transitionMoblileData,basketId);
        }
        system.debug('ngUcWrapperList'+ngUcWrapperList);
        for(ReplicatorGetServiceManager.NgUCTableWrapper ngUcData : ngUcWrapperList){
           if(ngUcData.checkValue == true){
                ngUcWrapperListFiltered.add(ngUcData);
           }
        }
        
        return ngUcWrapperListFiltered;
    }    

      /* @Author    :   Maqsood Alam
        * @Date     :   09 Oct 2019
        * @Desc     :   As a Sales Enterprise B2B user and Partner user, as part of transition order I should be able to see legacy services (ISDN10/20/30) to transition them into ngUC hosted offer.
        * @US       :   EDGE-92538
        * @Status   :   Development
       * */    
    @AuraEnabled
    public static List<Attachment> insertJSONResponseNgUc(TransitionDataDTO TransitionDataNgUcJSON, List<ReplicatorGetServiceManager.NgUCTableWrapper> selectedList, String basketId, Boolean SendCallout) {
        List<Attachment> attachmentJSONMobileList = new List<Attachment>();
        try{    
            system.debug('*******FinalResponses No Change NGUC=> '+JSON.serialize(TransitionDataNgUcJSON));
            system.debug('*******selectedListNo Change NGUC=> '+JSON.serialize(selectedList));
            attachmentJSONMobileList = ReplicatorGetServiceManager.insertJSONResponseNgUc(TransitionDataNgUcJSON, selectedList, basketId, SendCallout);
        }
        catch(Exception e){
            return null;
        }
        return attachmentJSONMobileList;
    }
         /* @Author    :   Abhishek Mallick(Osaka Team)
        * @Date     :   14th Octobr 2020
        * @Desc     :   Persisting staging table data returned from replicator
        * @US       :   EDGE-177640
        * @Status   :   Development
       * */   
    
    @AuraEnabled
    public static List<Legacy_Service__c> getMROLegacyDetails(TransitionDataDTO TransitionDataJSON, String basketId){
        Id AccountId = getBasket(basketId).csbb__Account__c;
        String OpportunityType = getBasket(basketId).cscfga__Opportunity__r.Type;//EDGE-209973
    //Start of EDGE-201125::Pradeep Mudenur:Fetching existing ABN associated with the account.
        String abn = getBasket(basketId).csbb__Account__r.ABN__c;
        System.debug('ABN retrieved ' +abn);
        //End of EDGE-201125
        System.debug('transition JSON' +JSON.serialize(TransitionDataJSON));
        List<Legacy_Service__c> legacyServiceRecordsList = new List<Legacy_Service__c>();
        List<Service_Add_On__c> listToInsert = new List<Service_Add_On__c>();
        Map<String,List<Service_Add_On__c>> serviceAddOnMap = new Map<String,List<Service_Add_On__c>>();
        Set<String> serviceIdList = new Set<String>();
        Set<String> serviceIdListUI = new Set<String>();
        for (TransitionDataDTO.productListDTO productList: TransitionDataJSON.productList) {
            for (TransitionDataDTO.SiteDTOMobile siteDTO: productList.site) {
                for (TransitionDataDTO.serviceListDTOMobile serviceListDTO: siteDTO.serviceList) {
                    for (TransitionDataDTO.groupDTOMobile groupDTO: serviceListDTO.groupType) {
                        for (TransitionDataDTO.serviceDTOMobile serviceDTO: groupDTO.service) {
                            Legacy_Service__c legacyServiceRecords = new Legacy_Service__c();
                            legacyServiceRecords.Transition_Id__c = groupDTO.transitionId;
                            legacyServiceRecords.Product_Type__c = productList.Product_Type; 
                            legacyServiceRecords.Service_Id__c = serviceDTO.Service_Id;
                            if(serviceDTO.TON_Barring_Status == 'Barred'){
                            	legacyServiceRecords.TON_Barring_Status__c = 'Barred';    
                            }
                            else{
                            	legacyServiceRecords.TON_Barring_Status__c = 'UnBarred';   
                            }
                            legacyServiceRecords.Eligibility_Status__c = serviceListDTO.EligibilityStatus;
                            legacyServiceRecords.Eligibility_Reason__c = serviceListDTO.EligibilityReason;
                            legacyServiceRecords.Plan_Name__c = serviceDTO.plan_name;
                            legacyServiceRecords.Plan_Type__c = serviceDTO.plan_type;
                            legacyServiceRecords.Contract_Term__c = serviceDTO.contract_term;
                            legacyServiceRecords.Account__c = AccountId; //Account Mapping
                            // To ensure overwrite older basket IDs mapped to the same service.
                            legacyServiceRecords.Product_Basket__c = basketId;
                            legacyServiceRecords.Select__c = serviceListDTO.checkValue;
              //Start of EDGE-201125::Pradeep Mudenur:Persisting existing ABN and BAN associated with the account.
                            legacyServiceRecords.ABN__c = abn;
                            legacyServiceRecords.BAN__c = serviceDTO.accountDetails.accountNumber;
                            //End of EDGE-201125
      						//Start of EDGE-205938 by Abhishek(Osaka): Introducing Nickname
                            legacyServiceRecords.Nickname__c = serviceDTO.user_name;
                            //End of EDGE-205938 by Abhishek(Osaka)
                            //UI Selected check
                            if(legacyServiceRecords.Select__c == true){
                                legacyServiceRecordsList.add(legacyServiceRecords);         //This list contains legacy services selected on UI.
                                serviceIdListUI.add(legacyServiceRecords.Service_Id__c);
                            }
                            List<Service_Add_On__c> serviceAddOnRecordsList = new List<Service_Add_On__c>();
                            List<Service_Add_On__c> serviceAddOnRecordsListNew = new List<Service_Add_On__c>();
                            if(serviceDTO.repayments!= null){
                                System.debug('Extracting all Addons from the replicator JSON');
                                for(TransitionDataDTO.repaymentsDTO repaymentsDTO: serviceDTO.repayments){
                                    Service_Add_On__c serviceAddOnRecords = new Service_Add_On__c();
                                    serviceAddOnRecords.Product_Id__c = repaymentsDTO.productID;
                                    serviceAddOnRecords.Device_Id__c = repaymentsDTO.deviceID;
                                    serviceAddOnRecords.Device_Type__c = repaymentsDTO.deviceType;
                                    /*EDGE-194026 Enhancements to staging table for transtions and 
                                    regression testing of transition functionality */ 
                                    serviceAddOnRecords.Legacy_Billing_Account_Number__c = serviceDTO.accountDetails.accountNumber;
                                    serviceAddOnRecords.Device_ID_Type__c = 'IMEI';
                                    serviceAddOnRecords.Transaction_Type__c = 'Transition';
                                    // End EDGE-194026
                                    //Start EDGE-209973
                                    if(OpportunityType == 'Migration'){
                                        serviceAddOnRecords.Transaction_Type__c = 'Migration';
                                        serviceAddOnRecords.Account__c = AccountId;
                                        serviceAddOnRecords.Product_Basket__c = basketId;                                        
                                    }
                                    serviceAddOnRecords.isMicaDependency__c = True;
                                    //End EDGE-209973
                                    serviceAddOnRecords.Device_Description__c =  repaymentsDTO.billLiteral;
                                    serviceAddOnRecords.Contract_Type__c = repaymentsDTO.contractType;
                                    serviceAddOnRecords.Monthly_Amount__c = repaymentsDTO.monthlyAmount;
                                    serviceAddOnRecords.Residual_Remaining_Term__c = repaymentsDTO.remainingTerm;
                                    serviceAddOnRecords.Residual_Remaining_Amount__c = repaymentsDTO.remainingAmount;
                                    serviceAddOnRecords.Instance_Id__c = repaymentsDTO.productID;
                                    serviceAddOnRecords.Charging_Option__c = 'Keep monthly repayment';
                                    //Start EDGE-213739
                                    serviceAddOnRecords.Product_End_Date__c = repaymentsDTO.productEndDate;
                                    //End EDGE-213739
                                    //EDGE-185955:Ramya:No additions done to status for the replicator JSON map as pending since it is default
                                    //serviceAddOnRecords.Status__c= 'Pending';
                                    serviceIdList.add(serviceDTO.Service_Id);
                                    //All add-on records list from replicator
                                    serviceAddOnRecordsList.add(serviceAddOnRecords);
                                    //Map of all services and add-ons irrespective of selection
                                    serviceAddOnMap.put(serviceDTO.Service_Id,serviceAddOnRecordsList); //This map contains add-ons associated to each service with service Id as key
                                }
                            }
                            //Start: DIGI-1683
                            Boolean stagingTableToggle =  FeatureEligibilityChecker.determineFeatureEligiblity('stagingTable',null);
                            system.debug('serviceAddOnMap1851'+serviceAddOnMap);
                            system.debug('serviceDTO.AddOns'+serviceDTO.AddOns);
                            if(stagingTableToggle && serviceDTO.AddOns!=null){
                                Id addOnRecTypeId = Schema.SObjectType.Service_Add_On__c.getRecordTypeInfosByName().get('Add On').getRecordTypeId();//Added for DIGI-1683
                                system.debug('serviceDTO.AddOns'+serviceDTO.AddOns);
                                for(TransitionDataDTO.AddOnsDTO addOnsDTO: serviceDTO.AddOns){
                                    system.debug('addOnsDTO'+addOnsDTO);
                                    Service_Add_On__c serviceAddOnRecords = new Service_Add_On__c();
                                    if(OpportunityType == 'Migration'){
                                        serviceAddOnRecords.Transaction_Type__c = 'Migration';
                                        serviceAddOnRecords.Account__c = AccountId;
                                        serviceAddOnRecords.Product_Basket__c = basketId;                                        
                                    }
                                    serviceAddOnRecords.Name = AddOnsDTO.addOnName;
                                    serviceAddOnRecords.Product_Code__c = AddOnsDTO.productCode;
                                    serviceAddOnRecords.Instance_Id__c = serviceDTO.Service_Id+'-'+AddOnsDTO.productCode;
                                    //Added for DIGI-1683
                                    if(addOnRecTypeId != null){
                                        serviceAddOnRecords.RecordTypeId = addOnRecTypeId;
                                    }
                                    serviceAddOnRecordsListNew.add(serviceAddOnRecords);
                                    if(!serviceIdList.contains(serviceDTO.Service_Id)){
                                        serviceIdList.add(serviceDTO.Service_Id);
                                    }
                                    system.debug('serviceAddOnRecords'+serviceAddOnRecords);
                                    serviceIdToProductCodeMap.put(serviceDTO.Service_Id,AddOnsDTO.productCode);
                                    serviceAddOnMap.put(serviceDTO.Service_Id+'-'+AddOnsDTO.productCode,serviceAddOnRecordsListNew);
                                }   
                                system.debug('serviceIdToProductCodeMap'+serviceIdToProductCodeMap);
                                system.debug('serviceAddOnMap'+serviceAddOnMap);   
                                //End: DIGI-1683                           
                            }
                        }
                    }
                }
            }
        }
        System.debug('Service list Id' +serviceIdList);
        System.debug('Service Map::' +serviceAddOnMap);
       //Legacy services with selected =true in legacy service record.
       Set<String> selectedListDb = getExistingServices(basketId);

       //Ramya:Deselected services-Removed since the solution is not on Next button->First time add-on save.
       //Set<String> deselectedServices= getDeselectedServices(serviceIdListUI, selectedListDb);
       //Final list with deselected service and selected services.
       List<Legacy_Service__c> legacyListFinal = insertLegacyServices(serviceIdListUI,selectedListDb,legacyServiceRecordsList);
        System.debug('Legacy List Final' +legacyListFinal);
        Set<Legacy_Service__c> legacySet = new Set<Legacy_Service__c>(legacyListFinal);
        List<Legacy_Service__c> legacyListFinalInsert = new List<Legacy_Service__c>(legacySet);
        if(legacyListFinalInsert.size()>0){
            upsert legacyListFinalInsert Service_Id__c;
        }

        //EDGE-185955::Ramya G:Fetching existing Add-ons based on basket ID, current selection and addOns already in staging table
        //List<Service_Add_On__c> deselectedaddOns = new List<Service_Add_On__c>();
        //deselectedaddOns =getDeselectedAddOns(basketId, serviceIdListUI, selectedListDb);
        //Addons for deselected services in UI already persisted in staging table.
        //List<Service_Add_On__c> addOnsDB = getExistingAddons(deselectedServices);
        //List<Service_Add_On__c> UISelectedaddOnDB = getExistingAddons(serviceIdListUI);
          // System.debug('Service Add On from DB'+addOnsDB);
           //serviceIdList has all services from replicator, serviceAddOnMap has addons for all services from replicator.
           //legacyListFinalInsert has all services to upsert for the basket.
        List<Service_Add_On__c> serviceAddOnList = insertAddOn(serviceIdList,legacyListFinalInsert,serviceAddOnMap);
        System.debug('Service Add On List'+serviceAddOnList);
         List<Legacy_Service__c> compositeService =new List<Legacy_Service__c>();
          compositeService=getSavedServicesAddon(basketId);
          system.debug('compositeService service:## ' + compositeService.size());
          updateAddStatus(compositeService);
        return legacyServiceRecordsList;
    }
    /* @Author      :   Ramya G(Osaka Team)
     
        * @Desc     :    Fetch deselected services.
        * @US       :   EDGE-185955
        
       * */  
   /* public static Set<String> getDeselectedServices(Set<String> serviceIdListUI, Set<String> selectedListDb)     {
    Set <String> deselectedService = new Set <String>();
    if(!selectedListDb.isEmpty()) {
        deselectedService = selectedListDb.clone();
        for (String serviceId:serviceIdListUI) {
           if(deselectedService.contains(serviceId)) 
               deselectedService.remove(serviceId);
        }
       
    }
    system.debug('Deselected services count :'  +deselectedService.size());
    
    return deselectedService;
    }
    */
    /* @Author    :   Abhishek Mallick(Osaka Team)
     * @Modified by: Ramya G, EDGE-185955: Added argument for fetched add-ons from staging table for status check.
        * @Desc     :   Persisting add-ons associated to Legacy services.
        * @US       :   EDGE-177640
        * @Status   :   Development
       * */   
    
   // public static List<Service_Add_On__c> insertAddOn(Set<String> serviceIdList,List<Legacy_Service__c> legacyServiceRecordsList,Map<String,List<Service_Add_On__c>> serviceAddOnMap, List<Service_Add_On__c> addOnsDB, List<Service_Add_On__c> UIaddOnsDB){
       public static List<Service_Add_On__c> insertAddOn(Set<String> serviceIdList,List<Legacy_Service__c> legacyServiceRecordsList,Map<String,List<Service_Add_On__c>> serviceAddOnMap){

        List<Service_Add_On__c> listToInsert = new List<Service_Add_On__c>();
        List<Service_Add_On__c> listToInsertServiceAddOn = new List<Service_Add_On__c>();
     //   Map<String, String> addOnInstanceStatusMap = new Map<String, String>();
     //  Map<String, String> UIaddOnInstStatusMap = new Map<String, String>();
     //   List<Service_Add_On__c> addOnsDBClone = new List<Service_Add_On__c>(addOnsDB);
     //   List<Service_Add_On__c> UIaddOnsDBClone = new List<Service_Add_On__c>(UIaddOnsDB);
        //List<Service_Add_On__c> listToInsert = new List<Service_Add_On__c>();
        //Map of deselected statuses
       /* if (!addOnsDBClone.isEmpty()) {
        addOnInstanceStatusMap =getInstanceStatusMap(addOnsDBClone);
        UIaddOnInstStatusMap =getInstanceStatusMap(UIaddOnsDBClone);
        }*/
        if(!serviceAddOnMap.isEmpty()){
            System.debug('After List' +serviceIdList);
            for(Legacy_Service__c legacyRec : legacyServiceRecordsList){
                if(serviceIdList.contains(legacyRec.Service_Id__c)){
                    for(Service_Add_On__c addOnRec:serviceAddOnMap.get(legacyRec.Service_Id__c)){
                        if(addOnRec!=null){
                            addOnRec.Legacy_Service__c = legacyRec.Id;
                            /*if(legacyRec.Select__c && UIaddOnInstStatusMap.get(addOnRec.Instance_Id__c) =='Pending') {
                                addOnRec.Status__c ='Ready for Sync';
                                system.debug('Selected Pending ->'+ addOnRec.Status__c);
                            }*/
                            //Ramya-Removed since map is for deselected only.
                           /* if (addOnInstanceStatusMap.get(addOnRec.Instance_Id__c) == 'Pending') 
                                addOnRec.Status__c ='Ready for Sync';*/
                            //Ramya: Added for condition to check status of existing add-on.
                           /* for(Service_Add_On__c addOnRecordStatus:UIaddOnsDBClone ) {
                                  if (!UIaddOnsDBClone.isEmpty() && addOnRecordStatus!=null && addOnRecordStatus.Instance_Id__c ==addOnRec.Instance_Id__c )
                                  {
                                      if(addOnInstanceStatusMap.get(addOnRec.Instance_Id__c)=='Pending') {
                                          addOnRec.Status__c ='Ready for Sync';
                                      }
                                  }
                            } */
                          /* for(Service_Add_On__c addOnRecordStatus:addOnsDBClone ) {
                                  if (!addOnsDBClone.isEmpty() && addOnRecordStatus.Instance_Id__c ==addOnRec.Instance_Id__c )
                                  {
                                    //Ramya:Should work only one time when addon statuses are to be updated conditionally.
                                    system.debug('Status reversal for ' +addOnRec.Status__c);
                                    if(addOnInstanceStatusMap.get(addOnRec.Instance_Id__c)=='Sync Completed') {
                                       addOnRec.Status__c ='Sync Removal Pending';
                                        system.debug('Sync Completed reversal ::: ' +addOnRec.Status__c);
                                    }/* else if (addOnInstanceStatusMap.get(addOnRec.Instance_Id__c) !='Sync Removal Pending') {
                                       addOnRec.Status__c ='Ready for Sync';
                                        system.debug('Sync  reversal :::' +addOnRec.Status__c);
                                    }
                                  }
                            }*/
                            listToInsert.add(addOnRec);
                            
                        }
                    }
                    //Start: DIGI-1683
                    system.debug('serviceAddOnMap-------'+serviceAddOnMap);
                    system.debug('serviceIdToProductCodeMap-------'+serviceIdToProductCodeMap);
                    system.debug('legacyRec----------'+legacyRec);
                    Boolean stagingTableToggle =  FeatureEligibilityChecker.determineFeatureEligiblity('stagingTable',null);    
                if(stagingTableToggle && !serviceAddOnMap.isEmpty() && !serviceIdToProductCodeMap.isEmpty() && legacyRec!=null 
                      && serviceAddOnMap.containsKey(legacyRec.Service_Id__c+'-'+serviceIdToProductCodeMap.get(legacyRec.Service_Id__c))){
                for(Service_Add_On__c addOnRec:serviceAddOnMap.get(legacyRec.Service_Id__c+'-'+serviceIdToProductCodeMap.get(legacyRec.Service_Id__c))){
                    system.debug('in for');
                    if(addOnRec!=null){
                        addOnRec.Legacy_Service__c = legacyRec.Id;
                        listToInsert.add(addOnRec);
                       }
                    }
                  }
                  //End: DIGI-1683
               }
            }
        }
        System.debug('List To Insert Add On: ' +listToInsert);
        
        if(!listToInsert.isEmpty()){
            upsert listToInsert Instance_Id__c;
        }
        /* if(!listToInsertServiceAddOn.isEmpty()){
        upsert listToInsertServiceAddOn Product_Code__c;
        } */
        system.debug('listToInsert'+listToInsert);
        return listToInsert;
    }
    
    /* @Author    :   Abhishek Mallick(Osaka Team)
        * @Desc     :   This method performs 2 actions.
        *               1) Unchecks select__c checkbox in database when a services is de-selected on UI.
        *               2) Inserts services which are selected on UI and not present in database.
        * @US       :   EDGE-177640
        * @Status   :   Development
       * */   
    public static List<Legacy_Service__c> insertLegacyServices(Set<String> selectedListUI,Set<String> selectedListDb,List<Legacy_Service__c> legacyServiceRecordsList){
        System.debug('SelectedUI' +selectedListUI);
        System.debug('selectedListDb'+selectedListDb);
        System.debug('LegacyServiceRecordList' +legacyServiceRecordsList);
        List<Legacy_Service__c> legacyListToInsert = new List<Legacy_Service__c>();
        //Services are already in staging
        if(!selectedListDb.isEmpty()){
            System.debug('Inside Selected DB');
            //Reset the flag for all records mapped to the basket
            for(String legacyRec : selectedListDb){
                if(!selectedListUI.contains(legacyRec)){
                    System.debug('Inside SelectedUI');
                    Legacy_Service__c legacyServiceRec = new Legacy_Service__c();
                    legacyServiceRec.Service_Id__c = legacyRec;
                    legacyServiceRec.Select__c = false;
                    legacyListToInsert.add(legacyServiceRec);
                }
            }
            //Selected services in UI for upsert.
            for(String serviceId : selectedListUI ){
                System.debug('Inside SelectedUI2');
                if(!selectedListDb.contains(serviceId)){
                    System.debug('Inside selected UI');
                    for(Legacy_Service__c legacyRecNew : legacyServiceRecordsList){
                        if(serviceId == legacyRecNew.Service_Id__c){
                            legacyListToInsert.add(legacyRecNew);
                            System.debug('Test::::'+legacyListToInsert);
                        }
                    }
                }
            }
            legacyListToInsert.addAll(legacyServiceRecordsList);
            System.debug('ListInsert' +legacyListToInsert);
        }
        else{
            legacyListToInsert.addAll(legacyServiceRecordsList);
        }
        return legacyListToInsert;
    }
    
    /* @Author    :   Abhishek Mallick(Osaka Team)
        * @Desc     :   This method fetches services which are marked Select__c = true from database.
        * @US       :   EDGE-177640
        * @Status   :   Development
       * */       
    public static Set<String> getExistingServices(String basketId){
        Set<String> selectedListDb = new Set<String>();
        List<Legacy_Service__c> legacyServiceList = new List<Legacy_Service__c>();
        legacyServiceList = [Select Service_Id__c from Legacy_Service__c where Product_Basket__r.Id = :basketId and Select__c = true ];
        if(!legacyServiceList.isEmpty()){
            for(Legacy_Service__c legacyRecord : legacyServiceList){
                selectedListDb.add(legacyRecord.Service_Id__c);
            }
        }
        return selectedListDb;
    }
    
    /* @Author    :   Ramya G(Osaka Team)
        * @Desc     :   Fetch all Addons and existing status
        
        * @US       :   EDGE-185955
 
       * */    
    
    public static List<Legacy_Service__c> getSavedServicesAddon(String basketId){
        List<Legacy_Service__c> legacyServiceList = new List<Legacy_Service__c>();
        List<Id> serviceId = new List<Id>();
        legacyServiceList = [Select id, Select__c, Service_Id__c,(select id,Status__c,Instance_Id__c from Service_Add_Ons__r) from Legacy_Service__c where Product_Basket__c =: basketId];
        return legacyServiceList;
    }
    
       /* @Author    :   Ramya G(Osaka Team)
        * @Desc     :   Set final Addon  status
        
        * @US       :   EDGE-185955
 
       * */   
    public static void updateAddStatus(List<Legacy_Service__c> legacyService) {
        
        List<Legacy_Service__c> legacyServiceList = new List<Legacy_Service__c>(legacyService);
        List<Service_Add_on__c> addOnList = new List<Service_Add_on__c>();
        Service_Add_on__c legacyAddOnList;
        for(Legacy_Service__c service: legacyServiceList) {
            if(service!=null && service.Service_Add_Ons__r.size()>0) {
                System.debug('Add on count is greater than zero for ' + service);
                for(Service_Add_on__c addOn:service.Service_Add_Ons__r) {
                  // legacyAddOnList=null;
                  legacyAddOnList =new Service_Add_on__c ();
                   legacyAddOnList.id=addOn.id;
                   legacyAddOnList.Instance_Id__c=addOn.Instance_Id__c;
                   if(service.Select__c) {                       
                       if(addOn.Status__c=='Pending') {                           
                           legacyAddOnList.Status__c='Ready for Sync';
                       } else if(addOn.Status__c=='Sync Removal Pending') {
                           legacyAddOnList.Status__c='Sync Completed';
                       }else if(addOn.Status__c=='Sync Removal Completed') {
                           legacyAddOnList.Status__c='Ready for sync';
                       }
                   } else {
                       if(addOn.Status__c=='Sync Completed') {                           
                           legacyAddOnList.Status__c='Sync Removal Pending';
                       } else if(addOn.Status__c=='Ready for sync') {
                           legacyAddOnList.Status__c='Pending';
                       }
                   }
                   addOnList.add(legacyAddOnList);
                 }
            } 
                    
           } 
        if(addOnList.size()>0) {
        Set<Service_Add_on__c> uniqueAddOn= new Set<Service_Add_on__c>(addOnList); 
        System.debug('Actual add on elements ### '+ addOnList.size() + 'Unique add on elements ### '+ uniqueAddOn.size());
        addOnList.clear();
        addOnList = new List<Service_Add_on__c>(uniqueAddOn);
        System.debug('Final add on elements ### '+ addOnList.size());
        upsert addOnList Instance_Id__c;
        }
                    
    } 
   
    
    
    /*
    public static List<Service_Add_On__c> getExistingAddons(Set<String> deselectedServices){
          //  Set<String> mergedSet=new Set<String>(serviceIdListUI);
          //  mergedSet.addAll(deselectedServices);
          //  List<String> selectedServiceList= new List<String>(mergedSet);
            List<String> selectedServiceList= new List<String>(deselectedServices);
            Set<ID> selectedServiceId = new Set<ID>();
            List<Service_Add_On__c> addOnList = new List<Service_Add_On__c>();
            if(selectedServiceList!=null && !selectedServiceList.isEmpty()) {
                selectedServiceId =new Map<Id,SObject>([select id from Legacy_Service__c where Service_Id__c IN :selectedServiceList]).keySet();
            }
        addOnList = [select id, Instance_Id__c,Status__c, Contract_Type__c,Legacy_Service__c from Service_Add_On__c where Legacy_Service__c IN :selectedServiceId ];

               return addOnList ;
    }*/
      /* @Author    :   Ramya G(Osaka Team)
        * @Desc     :   Map of unique Addon instance ID and existing status
        * @US       :   EDGE-185955
 
       * */   
   /* public static Map<String, String> getInstanceStatusMap (List<Service_Add_On__c> addOnDB) {
        Map<String, String> prodInstanceStatusMap = new Map<String, String>();
        if(!addOnDB.isEmpty()) {
            for(Service_Add_On__c legacyRec : addOnDB){ 
                if (legacyRec.Instance_Id__c !=null) {
                  prodInstanceStatusMap.put(legacyRec.Instance_Id__c,legacyRec.Status__c);
                }
            }
                
        }
      return prodInstanceStatusMap;
    }*/

/* @Author    :  Jayghosh Mishra(Osaka Team)
        * @Desc     :   Ability to filter the Add on Type and provide capability to search based on service number
        * @US       :   EDGE-173837
 
       * */    
    
@AuraEnabled(cacheable=true) 
//START: Modified for EDGE-224107- Modified return type to String
public static String getMRODetails(String basketId, String searchFinalVal)
//END for EDGE-224107
{ 
    
MROWrapperData mrowrapperObj;  
List<Legacy_Service__c> servicesList = new List<Legacy_Service__c>();
List<MROWrapperData> mroWrapperList=new List<MROWrapperData>();
List<MROScreenWrapper> mroWrapper=new List<MROScreenWrapper>(); 
MROScreenWrapper mroObject= new MROScreenWrapper ();

if(searchFinalVal <> NULL && basketId <> NULL){
   
String key ='%' + searchFinalVal + '%';
servicesList = Database.query('select id,Service_Id__c, Product_Basket__c, Eligibility_Status__c,(select status__c, Contract_Type__c,Device_Description__c,Residual_Remaining_Term__c,Residual_Remaining_Amount__c,Final_Remaining_Term__c,Final_Remaining_Amount__c,Charging_Option__c,Product_End_Date__c from Service_Add_Ons__r) from Legacy_Service__c where Product_Basket__c =:   basketId   AND Service_Id__c like : key AND Select__c=true');
//System.debug('servicesList after Search!!!' + servicesList);

if(!(servicesList.isEmpty())){
    List<Legacy_Service__c> filteredServicesList = new List<Legacy_Service__c>();
    List<Legacy_Service__c> filteredServiceId = new List<Legacy_Service__c>();
    filteredServicesList.addAll(servicesList);
    for(Legacy_Service__c validServiceIds : filteredServicesList){
        if(validServiceIds.Service_Id__c.startsWith(searchFinalVal) && validServiceIds.Service_Id__c.contains(searchFinalVal)){
        
            servicesList.clear();
            filteredServiceId.add(validServiceIds);
        }else{
            servicesList.clear();
            filteredServiceId.clear();
        }
        servicesList.addAll(filteredServiceId);
    }
}else{
 
if(servicesList.isEmpty()){
    servicesList = Database.query('select id,Service_Id__c, Product_Basket__c, Eligibility_Status__c,(select status__c, Contract_Type__c,Device_Description__c,Residual_Remaining_Term__c,Legacy_Service__c,Residual_Remaining_Amount__c,Final_Remaining_Term__c,Final_Remaining_Amount__c,Charging_Option__c,Product_End_Date__c from Service_Add_Ons__r where Device_Description__c like : key) from Legacy_Service__c where Product_Basket__c =:   basketId AND Select__c=true' );
    List<Legacy_Service__c> filteredServicesList = new List<Legacy_Service__c>();
    Set<Legacy_Service__c> filteredServiceIdBasedOnMica = new Set<Legacy_Service__c>();
    filteredServicesList.addAll(servicesList);
    for(Legacy_Service__c filteredSrv : filteredServicesList){
        if(filteredSrv.Service_Add_Ons__r.size() > 0){
            for(Service_Add_On__c micaProduct : filteredSrv.Service_Add_Ons__r){
                if((micaProduct.Device_Description__c.startsWith(searchFinalVal)) && (micaProduct.Device_Description__c.contains(searchFinalVal))){
                    
                    servicesList.clear();
                    filteredServiceIdBasedOnMica.add(filteredSrv);
                    servicesList.addAll(filteredServiceIdBasedOnMica);
                    
                }else{

                    servicesList.clear();
                }
            }
            
        }else{
            if(!(filteredServicesList.isEmpty()) && (filteredServiceIdBasedOnMica.isEmpty())){
            servicesList.clear();
            }
        }
    }
    /*for(Integer k = 0; k < filteredServiceIdBasedOnMica.size(); k++){
        for(Integer l = k+1; l = filteredServiceIdBasedOnMica.size(); l++){
            //if(filteredServiceIdBasedOnMica[k] == filteredServiceIdBasedOnMica[l]){
                filteredServiceIdBasedOnMica.remove(l);
            //}
            servicesList.addAll(filteredServiceIdBasedOnMica);
        }
    }
    System.debug('servicesList final after all Product iteration' + servicesList);*/
    
}   
} 
    
    
/*-------------------     EDGE-173837 --------------------*/
}else{
    
    if(basketId <> NULL){
    servicesList = [select id,Service_Id__c, Product_Basket__c, Eligibility_Status__c,(select status__c,Contract_Type__c,Residual_Remaining_Term__c,Residual_Remaining_Amount__c,Device_Description__c,Final_Remaining_Term__c,Final_Remaining_Amount__c,Charging_Option__c,Product_End_Date__c from Service_Add_Ons__r ) from Legacy_Service__c where Product_Basket__c =:  basketId and Select__c=true];
    
    }
}



for(Legacy_Service__c serv : servicesList)
{
    System.debug('legacy Service Value' + serv);
    mroWrapper=new List<MROScreenWrapper>(); 
    mrowrapperObj = new MROWrapperData();
    List<MROScreenWrapper> aroWrapper = new List<MROScreenWrapper>();//dpg-4072
    //Start EDGE-213740
    String expiredProduct = System.Label.Expired_Product;
    String nearExpiryProduct = System.Label.Near_Expiry_Product;
    String activeProduct = System.Label.Active_Product;
    String productRemainingEndDays = System.Label.ProductRemainingEndDays;
    Date today = System.today();
    //End EDGE-213740
    for (Service_Add_On__c child : serv.Service_Add_Ons__r)
    {
     System.debug('Service_Add_On__c' + child);  
    mroObject= new MROScreenWrapper ();
    mroObject.serviceNumber=serv.Service_Id__c;
    mroObject.paymentType=child.Contract_Type__c; 
    mroObject.chargeOption=child.Charging_Option__c;
    mroObject.billLiteral=child.Device_Description__c;
    mroObject.status= child.Status__c;
    mroObject.reminingAmount='$'+String.valueOf(child.Residual_Remaining_Amount__c);
    mroObject.reminingTerm=String.valueOf(child.Residual_Remaining_Term__c);
    //Start EDGE-213740
    mroObject.transitionMROScreen='TRUE';
    if(child.Product_End_Date__c != null){
        mroObject.productEndDate=child.Product_End_Date__c;
        if(child.Product_End_Date__c<today){
            mroObject.termStatus=expiredProduct;
        }
        else if(today.daysBetween(child.Product_End_Date__c) < integer.valueof(productRemainingEndDays)){
            mroObject.termStatus=nearExpiryProduct;
        }
        else{
            mroObject.termStatus=activeProduct;
        }
    }
    //End EDGE-213740
    System.debug('mroObject'+mroObject); 
    if( mroObject.paymentType=='MRO'){mroWrapper.add(mroObject);}  
    else if(mroObject.paymentType=='ARO'){aroWrapper.add(mroObject);}//DPG-4072
    }


    mrowrapperObj.serviceStr= serv.Service_Id__c;
    
    if (mroWrapper.size() == 0 && aroWrapper.size()==0){//DPG-4072
    mrowrapperObj.noAddon= serv.Service_Id__c+'  This number has no Payment Types'; }
     
    mrowrapperObj.arowrapperList= aroWrapper;//DPG-4072 
    mrowrapperObj.containsRecords = aroWrapper.size()>0 || mroWrapper.size()>0; //DPG-4072
    mrowrapperObj.mrowrapperList= mroWrapper;
    mrowrapperObj.record = serv.Product_Basket__c; // Adding Product Basket Id to get the Id 
    mroWrapperList.add(mrowrapperObj);
    system.debug('data @@'+mroWrapperList);
}
  //START: Modified for EDGE-224107
  return System.JSON.serialize(mroWrapperList); 
  //END for EDGE-224107

}



    
    public class MROWrapperData
        {
            @AuraEnabled
         Public String serviceStr{get; set;}
          @AuraEnabled
        public  String noAddon{get; set;}
            @AuraEnabled
       public List<MROScreenWrapper> mrowrapperList{get; set;} 
            @AuraEnabled
       public Id record {get; set;}
          @AuraEnabled 
          public List<MROScreenWrapper> arowrapperList{get; set;}//DPG-4072    
          @AuraEnabled  
         public Boolean containsRecords{get; set;}//DPG-4072
        }   
    
    
    
    /**
    * @Author   :   Shubhi Vijayvergia
    * @Date     :   22 May 2019
    * @Desc     :   wrappwr class for tree grid
    * */
    
    public class TableWrapper{
        @AuraEnabled
        public string product{get; set;}
        @AuraEnabled
        public string eligibilityStatus{get; set;}
        @AuraEnabled
        public string eligibilityReason{get; set;}
        @AuraEnabled
        public boolean checkValue{get; set;}
        @AuraEnabled
        public List<TableChildWrapper> Children{get; set;}
        @AuraEnabled
        public string iconName{get; set;}
        @AuraEnabled
        public string keyProduct{get; set;}
    } 
         /**
    * @Author   :   Shubhi Vijayvergia
    * @Date     :   22 May 2019
    * @Desc     :   wrappwr class for tree grid
    * */
    public class TableChildWrapper{
        @AuraEnabled
        public string product{get; set;}
        @AuraEnabled
        public string eligibilityStatus{get; set;}
        @AuraEnabled
        public string eligibilityReason{get; set;}
        @AuraEnabled
        public boolean checkValue{get; set;}
        @AuraEnabled
        public List<TableChildWrapper> Children{get; set;}
        @AuraEnabled
        public string iconName{get; set;}
        @AuraEnabled
        public string keyProduct{get; set;}
    }
    
    public class MROScreenWrapper
    {
        @AuraEnabled
        public String paymentType{get; set;}
        @AuraEnabled
        public String chargeOption{get; set;}
        @AuraEnabled
        public String billLiteral{get; set;}
        @AuraEnabled
        public String reminingAmount{get; set;}
        @AuraEnabled
        public String reminingTerm{get; set;}
        @AuraEnabled
        public String status{get; set;}
        @AuraEnabled
        public String serviceNumber{get; set;}
        @AuraEnabled
        public Date productEndDate{get; set;}
        @AuraEnabled
        public String termStatus{get; set;}
        @AuraEnabled
        public String transitionMROScreen{get; set;}
    }
    
    
    /* @Author    :  Jayghosh Mishra(Osaka Team)
        * @Desc     :   Ability to filter the Add on Type and provide capability to search based on service number
        * @US       :   EDGE-173837
 
       * */
    @AuraEnabled(cacheable = true)
        public static List<All_Payment_Types__mdt> enablePaymentTypes (){
            List<All_Payment_Types__mdt> paymentTypes = [select Id, Label,DeveloperName from All_Payment_Types__mdt]; 
        return paymentTypes;
            
    }
    

       @AuraEnabled(cacheable = true)
        public static List<Object> getMROConfirmDetails (String basketId){
            // DIGI-1940-Dheeraj Bhatt- Enable Chatter notifications to Opportunity Owner
            //  TransitionAutoConfigHelper.setBasketAutoConfigStatus(basketId,'In Progress');
         //   List<Legacy_Service__c> compositeService =new List<Legacy_Service__c>();
         //   compositeService=getSavedServicesAddon(basketId);
         //   updateAddStatus(compositeService);
    List<Legacy_Service__c> objectData=[select id,Service_Id__c, Select__c,(select id,status__c from Service_Add_Ons__r) from Legacy_Service__c where Product_Basket__c =:   basketId];
        
            Map<String,List<String>> mapValues=new Map<String,List<String>>();
            
            
            return objectData;
            
    }
    
    /* @Author    :  Jayghosh Mishra(Osaka Team)
        * @Desc     :   Skipping the MRO screen for BOH user- Migration scenario
        * @US       :   EDGE-188078
 
       * */
    @AuraEnabled(cacheable = true)
        public static Boolean getProfileInfo (){
        Id profile_id=userinfo.getProfileId();
        system.debug('~~'+profile_id);
        boolean applicableMro=true;
        String profile_name = [select Name from Profile where id = :profile_id].Name;
      System.debug('Migration BOH user ~~'+profile_name);
        //EDGE-218979 - Reverted EDGE-208434 for FDR fix by Abhishek(Osaka) -On behalf of Cairo.
      if(profile_name == 'Migration BOH user'){
            applicableMro = false;
        }
      return applicableMro;
    }
/*-----------------------------------------------------------------------------
EDGE-200766
Method Name -feedbackCase
Description -Create Feedback case for Not eligible products.  
Author      -Preeti Malik
-------------------------------------------------------------------------------*/
    @AuraEnabled 
    public static Case feedbackCase(string basketId, string cidnNumber,string transactionId,string fnnList){
        String feedbackCaseRTId  = Schema.SObjectType.Case.RecordTypeInfosByName.get('Feedback').RecordTypeId;  
        Id feedbackQueueId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperNAME = 'Modular_Order' LIMIT 1].Id; //DIGI-6677 changes queue from feedback to Modular
        
        system.debug('feedbackCase@@@');

        system.debug('@@@fnnList'+fnnList);
        string accountId ='';
        string basketNumber ='';
        if(basketId != null){   
            accountId = [select id,csbb__Account__c from cscfga__Product_Basket__c where id=:basketId].csbb__Account__c;
            basketNumber = [select id,Basket_Number__c from cscfga__Product_Basket__c where id=:basketId].Basket_Number__c;
        }   
        Case newCase = new Case( Subject = 'TRAMAS TM1 request failed - BT'+basketNumber, 
                                accountId = accountId,
                                OwnerId = feedbackQueueId,
                                Priority = CASE_PRIORITY,
                                Status = CASE_STATUS,
                                Severity__c = CASE_SEVERITY,
                                Feedback_Related_to__c = DIGITIZED_ORDERING,
                                Feedback_Category__c = CHECKPOINT_TRANSITION,
                                Description = 'TRAMAS TM1 call is not completed for the below FNNs that belong to CIDN - '+ cidnNumber +' TRAMAS Transition Id - '+transactionId+':'+fnnList,
                                Origin = CASE_ORIGIN,
                                RecordTypeId = feedbackCaseRTId
                                
                               );

        try{
            Insert newCase;
      			Case caseCreated = [SELECT Id, CaseNumber, Subject, accountId, OwnerId, Priority, Status, Severity__c, Feedback_Related_to__c, Feedback_Category__c, 
                                  Description, Origin, RecordTypeId FROM Case WHERE Id = :newCase.Id ];
              	return caseCreated;
        }catch(Exception ex){
            System.debug('Inside-> caseCreate -> Error occured: '+ ex.getMessage() +' Stack Trace: '+ ex.getStackTraceString());
        }
        return null;

    }
	@AuraEnabled
    public static String getCommunityUrl() {
        if(Network.getNetworkId()!=null)
            return network.getLoginUrl(Network.getNetworkId()).removeEnd('login');
        return null;
    }
    //End EDGE-200766  

    /*EDGE-198375
     Desc:Fetch tramas error code
   Team:Nirvana
*/
     @AuraEnabled 
    public static NumberReservationTM2CallOut.ErrorWrapper getTramsErrorCode(String offerType,string basketId,String exetype,DateTime currentDate){
        NumberReservationTM2CallOut.ErrorWrapper errorWrap=NumberReservationTM2CallOut.getTramsErrorCode(offerType,basketId,exetype,currentDate);
        return errorWrap;
       //   return null;
    }
    @AuraEnabled 
    public static DateTime getCurrentDatetime(){
        DateTime gmtDate =  System.now();
       // String convertedDate = gmtDate.format('yyyy-MM-dd HH:mm:ss');
    //return Datetime.valueofgmt(gmtDate);
    return gmtDate; 
    }
 /******************************************************************************************************************************
 * Story: DIGI-1753
 * Team : Osaka
 * Developer : Pradeep Mudenur
 * Description: Remove dependency on the user to restart the Transition UI journey
 * ************************************************************************************************************************************/
    @AuraEnabled
    public static boolean checkReplicatorResponseHelper(String basketId){
    Boolean isTransitionJsonReturned=CompUtilityReplicatorManagerHelper.checkReplicatorResponse(basketId);
    return isTransitionJsonReturned;
    }
/*===============================================================================================================================
Developer Name        Date          Story Description
Dheeraj Bhatt         13 sept 2021   DIGI-1939 - Enable an API call to the MS to initiate digi plan configuration
===============================================================================================================================
*/
    @AuraEnabled public static boolean autoSIOConfig(String basketId){
     return OrderLodgement.orderLodgmentServiceRequest(basketId);   
    }
/*****************************************************************************************************************************
 * Story: DIGI-1741
 * Team : Osaka
 * Developer : Abhishek
 * Description: This method fetches custom metadata records.
 * ************************************************************************************************************************************/
    @AuraEnabled
    public static Map<string,Sobject> getCustomMetadataRecords(String metadataDevName){
        Map<string,Sobject> customMetadataRec = new Map<string,Sobject> ();
        customMetadataRec = ConstantMetadataUtility.getConstantMetadataUtilityRecords(metadataDevName);
        return customMetadataRec;
    }
}