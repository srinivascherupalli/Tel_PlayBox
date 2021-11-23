global class CalloutResponseAddressCheck extends csbb.CalloutResponseManagerExt {
    global CalloutResponseAddressCheck (Map<String, csbb.CalloutResponse> mapCR, csbb.ProductCategory productCategory, csbb.CalloutProduct.ProductResponse productResponse) {
        this.setData(mapCR, productCategory, productResponse);
    }
    
    public CalloutResponseAddressCheck() {}

    global void setData(Map<String, csbb.CalloutResponse> mapCR, csbb.ProductCategory productCategory, csbb.CalloutProduct.ProductResponse productResponse) {
        return;
    }

    global Map<String, Object> processResponseRaw (Map<String, Object> inputMap) {
        return new Map<String, Object>();
    }

    global Map<String, Object> getDynamicRequestParameters (Map<String, Object> inputMap) {
        return new Map<String, Object>();
    }

    global void runBusinessRules (String categoryIndicator) {
        return;
    }
    
    global csbb.Result canOffer (Map<String, String> attMap, Map<String, String> responseFields, csbb.CalloutProduct.ProductResponse productResponse) {
        csbb.Result canOfferResult = new csbb.Result();
        canOfferResult.status = 'OK';
        return canOfferResult;
    }
}