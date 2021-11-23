/*
*   This need to be removed as part of 1710 NFB-4098
*/
global class CalloutResponseSQAvailabilityCheck extends csbb.CalloutResponseManagerExt {

    global CalloutResponseSQAvailabilityCheck (Map<String, csbb.CalloutResponse> mapCR,
                                                csbb.ProductCategory productCategory, 
                                                csbb.CalloutProduct.ProductResponse productResponse) {
        this.setData(mapCR, productCategory, productResponse);
    }
    
    public CalloutResponseSQAvailabilityCheck() {}
    
    global void setData(Map<String, csbb.CalloutResponse> mapCR, 
                                csbb.ProductCategory productCategory,
                                csbb.CalloutProduct.ProductResponse productResponse) {
        this.service = 'SQAvailabilityCheck';
        this.productCategoryId = productCategory.productCategoryId;
        this.mapCR = mapCR;
        this.productCategory = productCategory;
        this.productResponse = productResponse;
        this.setPrimaryCalloutResponse();
    }
    
    global Map<String, Object> processResponseRaw (Map<String, Object> inputMap) {
        return new Map<String, Object>();
    }
    
    global Map<String, Object> getDynamicRequestParameters (Map<String, Object> inputMap) {
        return new Map<String, Object>();
    }
    
    global void runBusinessRules (String categoryIndicator) {
        this.productResponse.displayMessage = 'This product is available for the selected address';
        this.productResponse.available = 'true';
        String jsonData = JSON.serialize(crPrimary.take('response'));
        if(jsonData.contains('"code":200') || jsonData.contains('"code":"200"')){
            SiteSQResponseDTO sqResponse = SiteSQResponseDTO.parse(jsonData);
            String technologyType = sqResponse.data.serviceTypeQualifications[0].technologyType;
            String adbordID = sqResponse.request.params.adborId;
            //List<cscrm__Site__c> siteList = [Select id, Name, AdborID__c, cscrm__Installation_Address__r.cscrm__Address_Details__c  from cscrm__Site__c where AdborID__c =: adbordID LIMIT 1];
            this.crPrimary.mapDynamicFields.put(SQConstants.ADBORID, adbordID);
            //this.crPrimary.mapDynamicFields.put(SQConstants.SITE_ADDRESS, siteList[0].cscrm__Installation_Address__r.cscrm__Address_Details__c);
            this.crPrimary.mapDynamicFields.put(SQConstants.ACCESS_TYPE, technologyType);
            this.crPrimary.mapDynamicFields.put(SQConstants.TECHNOLOGY_TYPE, technologyType);
            //System.debug('<<<<'+siteList[0].id);
            //this.crPrimary.mapDynamicFields.put(SQConstants.SITE_ID, siteList[0].id);
        }
        //this.crPrimary.mapDynamicFields.put(SQConstants.MAX_UP_SPEED, resultMap.get(SQConstants.MAX_UP_SPEED));
        //this.crPrimary.mapDynamicFields.put(SQConstants.MAX_DOWN_SPEED, resultMap.get(SQConstants.MAX_DOWN_SPEED));
        //this.crPrimary.mapDynamicFields.put(SQConstants.SITE_NAME, resultMap.get(SQConstants.SITE_NAME));
        //this.crPrimary.mapDynamicFields.put(SQConstants.SITE_ADDRESS, resultMap.get(SQConstants.SITE_ADDRESS));
        //this.crPrimary.mapDynamicFields.put(SQConstants.TRAFFIC_CLASS, resultMap.get(SQConstants.TRAFFIC_CLASS));
        //this.crPrimary.mapDynamicFields.put(SQConstants.TECHNOLOGY_TYPE, resultMap.get(SQConstants.TECHNOLOGY_TYPE));
        //this.crPrimary.mapDynamicFields.put(SQConstants.NDC, resultMap.get(SQConstants.NDC));
        //System.debug('-----------------> resultMap ' + resultMap);
    }
    
    global csbb.Result canOffer (Map<String, String> attMap, 
                                    Map<String, String> responseFields,
                                    csbb.CalloutProduct.ProductResponse productResponse) {
        csbb.Result canOfferResult = new csbb.Result();
        canOfferResult.status = 'OK';
        return canOfferResult;
    }    
}