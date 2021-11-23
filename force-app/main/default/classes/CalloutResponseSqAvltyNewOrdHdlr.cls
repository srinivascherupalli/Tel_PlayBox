//This is created as part of EDGE-62720
global class CalloutResponseSqAvltyNewOrdHdlr extends csbb.CalloutResponseManagerExt {
    public static boolean createSiteRecSync = false;
    public static string sqResponseCode = 'errorResponse';
    public string adborAddId = '';
    public integer resultCode;
    //Logger2 logger = Logger2.getLogger('SqAvltyNewOrdHdlr');
    global CalloutResponseSqAvltyNewOrdHdlr (Map<String, csbb.CalloutResponse> mapCR,
                                                csbb.ProductCategory productCategory, 
                                                csbb.CalloutProduct.ProductResponse productResponse) {
        this.setData(mapCR, productCategory, productResponse);
    }
    
    public CalloutResponseSqAvltyNewOrdHdlr() {}
    
     global void setData(Map<String, csbb.CalloutResponse> mapCR, csbb.ProductCategory productCategory, csbb.CalloutProduct.ProductResponse productResponse) {
        
        this.service = 'SqAvltyNewOrdHdlr';
        this.productCategoryId = productCategory.productCategoryId;
        this.mapCR = mapCR;
        this.productCategory = productCategory;
        this.productResponse = productResponse;
        this.setPrimaryCalloutResponse();
        system.debug('ResponseVRAVI::::'+mapCR);
        system.debug('Product Response:::'+productResponse);
        system.debug('product Category:::'+productCategory);
        return;
    }
    
    global Map<String, Object> processResponseRaw (Map<String, Object> inputMap) {
        return new Map<String, Object>();
    }
    
    global Map<String, Object> getDynamicRequestParameters (Map<String, Object> inputMap) {
        String hashString = String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        String regExp = '[-:\\s]';
        String replacement = '';
        String uniqueString = hashString.replaceAll(regExp, replacement);
        
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(uniqueString));
        String hexDigest = EncodingUtil.convertToHex(hash).subString(0, 18);
        System.debug('Generated Unique Key: ' + hexDigest);
        inputmap.put('CORRELATIONID',hexDigest);
        return inputMap;
    }
    
    global void runBusinessRules (String categoryIndicator) {
        system.debug('Inside runBusinessRules:::::'+categoryIndicator);
        //Map<String,String> AttributeValueMappingMap =new Map<String,String>();
        
        this.productResponse.displayMessage = 'This product is available for the selected address';
        this.productResponse.available = 'true';
        String jsonData;
        if(Test.isRunningTest())
            jsonData = '{"correlationId":"2cc94865-ae8d-4eff-dece-376cb80e511c","request":{"correlationId":"25c53bbf-6884-4435-619b-5dc7d589efc4","requestId":"d29072cd-4fa2-436b-9b0c-ca09577f120d","method":"GET","path":"/service-addresses","data":{},"params":{"serviceFilter":"Internet","addressId":"141671646"}},"data":{"scheduledDates":{"orderStabilityPeriodDate":"","ceaseSaleDate":""},"messages":[{"message":"The dates cannot be retrieved due to downstream errors","code":"SQNTT002"}],"serviceTypeQualifications":[{"appointmentRequired":"No","readyForServiceDate":"2011-10-09","copperPairIndicator":"Y","characteristics":[{"value":"100 Mbps","name":"TC4 Downstream Upper Rate"},{"value":"75 Mbps","name":"TC4 Downstream Lower Rate"},{"value":"40 Mbps","name":"TC4 Upstream Upper Rate"},{"value":"20 Mbps","name":"TC4 Upstream Lower Rate"}],"statusReason":"NBN Internet is serviceable at this address","providerResources":[{"serviceabilityClass":"13","status":"Line Not In Use","id":"CPI170808084915","resourceType":"Copper Pair"}],"status":"Available","locationId":"LOC170808084915","serviceType":"Internet","serviceTransferIndicator":"N","csaId":"CSA700000000406","newDevelopmentChargesApply":"No","technologyType":"Fibre To The Node","serviceabilityClass":"13"}],"additionalTrafficClassAvailability":[{"value":"No","name":"High Speed TC2 (greater or equal to 20Mbps)"},{"value":"No","name":"TC2"},{"value":"No","name":"NCAS TC2 5Mbps Capacity"},{"value":"No","name":"NCAS TC2 10Mbps Capacity"},{"value":"No","name":"NCAS TC2 20Mbps Capacity"},{"value":"No","name":"NCAS TC2 30Mbps Capacity"},{"value":"No","name":"NCAS TC2 40Mbps Capacity"},{"value":"No","name":"NCAS TC4 High Speed Tiers (greater or equal to 250Mbps)"},{"value":"Yes","name":"NCAS TC1 High Speed Tiers (greater or equal to 0.3Mbps)"},{"value":"Yes","name":"NCAS TC1 High Speed Tiers (greater or equal to 2Mbps)"},{"value":"No","name":"Multicast"}],"addressId":"141671646"},"time":"2019-03-13T17:41:23+10:00","status":200,"code":200}'; 
        else
            jsonData = JSON.serialize(crPrimary.take('response'));
        system.debug('Jsondata'+jsonData);
        system.debug('crPrimary:::'+crPrimary);
        Logger2 logger = Logger2.getLogger('SiteSQAddressHandler');        

        try{
            list<csbb__Product_Configuration_Request__c> pcrUpdLst = new list<csbb__Product_Configuration_Request__c>();
            string siteAccId = null;
            string accCIDN;
            string accEntId;
            if(Test.isRunningTest()){
                siteAccId = 'test';
                accCIDN = 'test';
                accEntId = 'test';
            }
            else{
                cscfga__Product_Basket__c bsktDtls = CalloutResponseSqAvltyNewOrdHdlr.getAccountId(this.basketId);
                siteAccId = bsktDtls.csbb__Account__c;
                accCIDN = bsktDtls.csbb__Account__r.CIDN__c;
                accEntId = bsktDtls.csbb__Account__r.Enterprise_ID__c;
            }            
            boolean isLegacySite = false;
            Id pcrRecId = null;
            if(jsonData!= null){
                SqResponseDTO resDto = new SqResponseDTO();
                JSONParser parser = JSON.createParser(jsonData);             
                resDto = (SqResponseDTO)parser.readValueAs(SqResponseDTO.class);
                logger.logMessages('SqAvltyNewOrdHdlr_resDto', string.valueof(resDto), '', '', '', '', false, false,Integer.valueof('111') , null, null, null);                
                adborAddId = resDto.request.params.addressId;
                resultCode = resDto.code;
                id basktId = this.basketId;
                OptionalsAddId optnl;
                // <Start> Added by Ravi for EDGE-80150
                List<cscrm__Site__c> siteLst = [select id from cscrm__Site__c  where cscrm__Account__c = :siteAccId AND AdborID__c = :adborAddId order by Lastmodifieddate desc];
                if(siteLst == null || siteLst.size() == 0){
                    isLegacySite = true;                
                }// <End> Added by Ravi for EDGE-80150
                list<csbb__Product_Configuration_Request__c> pcrLst = [select id,csbb__Product_Configuration__c,SQ_Callout_Finished__c,csbb__Optionals__c from csbb__Product_Configuration_Request__c where csbb__Product_Basket__c = :basktId];
                for(csbb__Product_Configuration_Request__c pcr :pcrLst){            
                    optnl = (OptionalsAddId)System.JSON.deserialize(pcr.csbb__Optionals__c, OptionalsAddId.class); 
                    // <Start> Added by Ravi for EDGE-80150, call to observer class method to create a site record synchronously
                    if(isLegacySite && optnl.hiddenParam1 != null && adborAddId == optnl.hiddenParam1 && resultCode != null && (resultCode == 200 || resultCode == 201 || resultCode == 202)){
                        pcrRecId = pcr.id;
                        createSiteRecSync = true;
                        ObserverCloneBasketHelper.CreateStiteAndaddresses(pcrRecId,accCIDN,accEntId);
                        createSiteRecSync = false;
                    }// <End> Added by Ravi for EDGE-80150                   
                    if(optnl.hiddenParam1 != null && adborAddId == optnl.hiddenParam1 && resultCode != null && resultCode != 200 && resultCode != 201 && resultCode != 202){
                        pcr.SQ_Callout_Finished__c = true;
                        pcrUpdLst.add(pcr);     
                    }
                }
                if(resDto != null && (resDto.code == 200 || resDto.code == 201 || resDto.code == 202)){
                    sqResponseCode = 'successResponse';
                    SQcheckCalloutHandler sqHdlr;
                    if(Test.isRunningTest())
                        sqHdlr = new SQcheckCalloutHandler(new List<String>{resDto.request.params.addressId}, '1a1a1a1a');
                    else
                        sqHdlr = new SQcheckCalloutHandler(new List<String>{resDto.request.params.addressId}, siteAccId);
                    SQcheckCalloutHandler.NBNAttributeWrapper nbnwrapper=new SQcheckCalloutHandler.NBNAttributeWrapper();                   
                    if(!Test.isRunningTest()){
                        Map<String,SqResponseDTO> mapAddrIdRes = new Map<String,SqResponseDTO>();
                        mapAddrIdRes.put(resDto.request.params.addressId,resDto);
                        sqHdlr.saveSQResponse(mapAddrIdRes);
                        //sqHdlr.saveSQResponse(resDto.request.params.addressId, resDto);
                         //Added by shubhi for NBN SQ  attribute mapping EDGE-65964                    
                        nbnwrapper=SQcheckCalloutHandler.nbnAttributes;
                    }
                    //System.debug('CalloutResponseSqAvltyNewOrdHdlr runBusinessRules nbnwrapper ' + nbnwrapper);
                    String AdborID = nbnwrapper.adbordID;
                    String NBNAvailability=nbnwrapper.NBNAvailability;
                    String NBNRFSDate=nbnwrapper.NBNRFSDate; 
                    String NBNTechnologyType=nbnwrapper.NBNTechnologyType;
                    String MaxUploadSpeed=nbnwrapper.MaxUploadSpeed;
                    String MaxDownloadSpeed=nbnwrapper.MaxDownloadSpeed;            
                    String serviceabilityClass=nbnwrapper.serviceabilityClass;
                    String copperPairIndicator=nbnwrapper.copperPairIndicator;
                    logger.logMessages('NBN Attributes', string.valueof(nbnwrapper), '', '', '', '', false, false,Integer.valueof('111') , null, null, null);
                    this.crPrimary.mapDynamicFields.put('AdborID',AdborID);
                    this.crPrimary.mapDynamicFields.put('NBNAvailability',NBNAvailability);
                    this.crPrimary.mapDynamicFields.put('NBNRFSDate', NBNRFSDate);
                    this.crPrimary.mapDynamicFields.put('NBNTechnologyType', NBNTechnologyType);
                    this.crPrimary.mapDynamicFields.put('MaxUploadSpeed',MaxUploadSpeed);
                    this.crPrimary.mapDynamicFields.put('MaxDownloadSpeed',MaxDownloadSpeed);
                    this.crPrimary.mapDynamicFields.put('serviceabilityClass',serviceabilityClass);
                    this.crPrimary.mapDynamicFields.put('SQVacantCopperPairs',copperPairIndicator);
                    //end EDGE-65964                    
                }

                if(!pcrUpdLst.isEmpty()){
                    update pcrUpdLst;
                }
                if(isLegacySite && resultCode != null && (resultCode == 200 || resultCode == 201 || resultCode == 202)){// <Start> Added by Ravi for EDGE-80150
                    ObserverCloneBasketHelper.CreateStiteAndaddresses(pcrRecId,accCIDN,accEntId);//site record update with call to EAST
                }// <End> Added by Ravi for EDGE-80150
            }
            //// Response to custom setting mapping added by Shubhi
            //String technologyType = sqResponse.data.serviceTypeQualifications[0].technologyType;
            ///Edge-65964            
        }   
        catch(Exception ex){
            system.debug('Error occurred in SQ_availability_ProcessResponseRaw::::'+ex.getMessage()+'<<>>'+ex.getLineNumber());
        }
        logger.exitLogger();   
        return;
    }
    
    global csbb.Result canOffer (Map<String, String> attMap, Map<String, String> responseFields, csbb.CalloutProduct.ProductResponse productResponse) {
        csbb.Result canOfferResult = new csbb.Result();
        if(sqResponseCode == 'successResponse')
            canOfferResult.status = 'OK';
        else
            canOfferResult.status = '';
        return canOfferResult;
    }
    public static cscfga__Product_Basket__c getAccountId(String basketID){
        cscfga__Product_Basket__c basketAccDetails=[select id,csordtelcoa__Account__c,csbb__Account__c,csbb__Account__r.CIDN__c,csbb__Account__r.Enterprise_ID__c from cscfga__Product_Basket__c where id=:basketID];
        return basketAccDetails;
    }
    public class OptionalsAddId{
        public String hiddenParam1;
    }
}