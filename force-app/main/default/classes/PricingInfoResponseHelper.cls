/*
Class Name          :    PricingInfoResponseHelper
Test Class          :    PricingInfoResponseHelperTest
Author              :    Team Nirvana
Date                :    25th OCT 2021
--------------------------------------------------------------------------------------------------*/
public with sharing class PricingInfoResponseHelper {
    
    public static PricingAPIResponse processRequest(PricingAPIRequest request, string sourceSystem){
        
        String  cidn=request.cidn;
        String  marketableOfferId=request.marketableOfferId;
        List<String>  productCode=request.productCode;
        
        PricingAPIResponse response = new PricingAPIResponse();
        List<PricingAPIResponse.priceDetails> priceDetailsList = new List<PricingAPIResponse.priceDetails>();
        
        Map<Id,cspmb__Pricing_Rule_Group_Rule_Association__c> mapPriceRulewithPRGPRA = new Map<Id,cspmb__Pricing_Rule_Group_Rule_Association__c>();
        Map<Id,cspmb__Pricing_Rule_Group_Rule_Association__c> mapPriceRulewithFrameAgreement = new Map<Id,cspmb__Pricing_Rule_Group_Rule_Association__c>();
        
        
        
        List<cspmb__Pricing_Rule_Group_Rule_Association__c> lstPrgPRA = [SELECT cspmb__pricing_rule__c, cspmb__pricing_rule_group__c,
                                                                         cspmb__pricing_rule_group__r.csconta__frame_agreement__c, Name, Id FROM cspmb__Pricing_Rule_Group_Rule_Association__c
                                                                         WHERE (cspmb__pricing_rule_group__r.cspmb__always_applied__c=true AND
                                                                                cspmb__pricing_rule_group__r.csfam__standard_price_book__c =true AND cspmb__pricing_rule_group__r.Check_todays_date__c=true) 
                                                                         OR cspmb__pricing_rule_group__r.csconta__frame_agreement__r.csconta__Account__r.CIDN__c= :cidn];
        
        
        
        
        for(cspmb__Pricing_Rule_Group_Rule_Association__c prgpra :lstPrgPRA){
            mapPriceRulewithPRGPRA.put(prgpra.cspmb__pricing_rule__c,prgpra);
            if(prgpra.cspmb__pricing_rule_group__r.csconta__frame_agreement__c != null)
            mapPriceRulewithFrameAgreement.put(prgpra.cspmb__pricing_rule__c,prgpra);// only if cspmb__pricing_rule_group__r.csconta__frame_agreement__r populated
        }
        
        
        
        
        
        List<cspmb__Price_Item_Pricing_Rule_Association__c> lstCPPRA= [SELECT Id, cspmb__association_type__c,
                                                                       cspmb__pricing_rule__c, cspmb__price_item__c, cspmb__add_on__c, cspmb__pricing_element__c,
                                                                       cspmb__target_price__c, cspmb__quantity__c, cspmb__price_item_add_on_association__c,
                                                                       cspmb__price_item__r.cspmb__Price_Item_Code__c,cspmb__price_item__r.taxTreatment__c,
                                                                       cspmb__recurring_adjustment__c,cspmb__one_off_adjustment__c,
                                                                       cspmb__commercial_product_association__c FROM cspmb__Price_Item_Pricing_Rule_Association__c
                                                                       //WHERE (cspmb__price_item__r.Offer_Id__c= :marketableOfferId AND cspmb__price_item__r.cspmb__Price_Item_Code__c IN :productcode)
                                                                       WHERE cspmb__price_item__r.Offer_Id__c= :marketableOfferId
                                                                       AND (cspmb__pricing_rule__c IN: mapPriceRulewithPRGPRA.keyset() OR cspmb__pricing_rule__c IN:mapPriceRulewithFrameAgreement.keyset())
                                                                       AND cspmb__target_price__c = 'Sales' AND cspmb__pricing_rule__r.Check_todays_date__c=true];
        
        Map<String,Map<String,String>> pricingMap = new  Map<String,Map<String,String>>();
        for(cspmb__Price_Item_Pricing_Rule_Association__c cppra: lstCPPRA){
            if (productCode != null && productCode.size() >0){
                if (!productCode.contains(cppra.cspmb__price_item__r.cspmb__Price_Item_Code__c))
                   continue;
             }
            if(pricingMap.containsKey(cppra.cspmb__price_item__r.cspmb__Price_Item_Code__c)){
                if(mapPriceRulewithFrameAgreement.containsKey(cppra.cspmb__pricing_rule__c)){
                    pricingMap.get(cppra.cspmb__price_item__r.cspmb__Price_Item_Code__c).put('DiscountedPrice',
                                                                                             cppra.cspmb__recurring_adjustment__c != null ? String.valueOf(cppra.cspmb__recurring_adjustment__c) : 
                                                                                             String.valueOf(cppra.cspmb__one_off_adjustment__c));
                }else
                    pricingMap.get(cppra.cspmb__price_item__r.cspmb__Price_Item_Code__c).put('StandardPrice',
                                                                                             cppra.cspmb__recurring_adjustment__c != null ? String.valueOf(cppra.cspmb__recurring_adjustment__c) : 
                                                                                             String.valueOf(cppra.cspmb__one_off_adjustment__c));
            }else{
                Map<String,String> productCodeMap = new Map<String,String>();
                productCodeMap.put('isGSTIncluded',cppra.cspmb__price_item__r.taxTreatment__c == 'GST Applicable' ? 'True' : 'False');
                productCodeMap.put('ChargeType',cppra.cspmb__recurring_adjustment__c != null ? 'Recurring' : 'Oneoff');
                
                if(mapPriceRulewithFrameAgreement.containsKey(cppra.cspmb__pricing_rule__c)){
                    productCodeMap.put('DiscountedPrice',cppra.cspmb__recurring_adjustment__c != null ? String.valueOf(cppra.cspmb__recurring_adjustment__c) : 
                                       String.valueOf(cppra.cspmb__one_off_adjustment__c));
                }else
                {
                    productCodeMap.put('StandardPrice',cppra.cspmb__recurring_adjustment__c != null ? String.valueOf(cppra.cspmb__recurring_adjustment__c) : 
                                       String.valueOf(cppra.cspmb__one_off_adjustment__c));
                    productCodeMap.put('DiscountedPrice','0.0');
                }
                pricingMap.put(cppra.cspmb__price_item__r.cspmb__Price_Item_Code__c,productCodeMap);
            }
            
        }
        for(String prodCode: pricingMap.keySet()){
            PricingAPIResponse.priceDetails pd = new PricingAPIResponse.priceDetails();
            pd.ProductCode=prodCode;
            pd.StandardPrice=pricingMap.get(prodCode).get('StandardPrice');
            pd.DiscountedPrice=pricingMap.get(prodCode).get('DiscountedPrice');
            pd.isGSTIncluded=pricingMap.get(prodCode).get('isGSTIncluded');
            pd.ChargeType=pricingMap.get(prodCode).get('ChargeType');
            priceDetailsList.add(pd);
        }
        response.code='200';
        response.status='ok';
        response.marketableOfferId=marketableOfferId;
        response.sourceSystem=sourceSystem;
        response.cidn=cidn;
        response.priceDetails=priceDetailsList;
        return response;
    }
    
    /**************************************************************************************
****** Desc         : Method to get PricingAPIResponse based on input parameters
****** Story        : DIGI-32339,DIGI-16483,DIGI-16567
****** Created By   : Team Nirvana
***************************************************************************************/   
    public static PricingAPIResponse prepareResponse(string errorCode,String errorMessage, List<PricingAPIResponse.errors> errorList) {
        PricingAPIResponse resp = new PricingAPIResponse();
        resp.code = errorCode;
        //resp.Status = status;
        resp.errors = errorList;
        resp.message = errorMessage;
        return resp;       
    }
    
    
    public static PricingAPIResponse.errors getErrorMessage(string errorMessage,string errorCode){
        PricingAPIResponse.errors err = new PricingAPIResponse.errors();
        err.message = errorMessage;
        err.errorCode  = errorCode;
        
        return err;
    }
    
    /**************************************************************************************
****** Desc :Method to prepare input parameters for rest response
****** Developer : DIGI-32339,DIGI-16483,DIGI-16567
***************************************************************************************/
    public static RestResponse getRestResponse(PricingAPIResponse response, string correlationId){
        RestResponse res = RestContext.response;
        res.responseBody = Blob.valueOf(JSON.serialize(response,true));
        res.statusCode = Integer.valueOf(response.code);
        res.addHeader('Code', response.code);
        res.addHeader('Status', response.status);
        res.addHeader('correlationId', correlationId);
        res.addHeader('Content-Type', 'application/json');
        return res;
        
    }
    
    
    
    /**************************************************************************************
****** Desc         : Method to validate mandatory parameters are included in the API request
****** Story        : DIGI-32339,DIGI-16483,DIGI-16567
****** Team         : Nirvana
***************************************************************************************/
    public static boolean validateMandatory(PricingAPIRequest request, string sourceSystem){
        boolean isValidOffer = true;
        String marketableOfferId=request.marketableOfferId;
        //String offerName = 'DMCAT_Offer_';
        List<cspmb__Price_Item__c> offerList = [Select ID,cspmb__Price_Item_Code__c,cspmb__Is_Active__c FROM cspmb__Price_Item__c WHERE Offer_Id__c= :marketableOfferId];
        if(offerList.size()<1)
        {
         isValidOffer = false;
        }
        
        return isValidOffer ;
    }
    
    
    
    
    /**************************************************************************************
****** Desc         : Method to validate Product Code
****** Story        : DIGI-32339,DIGI-16483,DIGI-16567
****** Team         : Nirvana
***************************************************************************************/
    public static boolean isValidProductCode(PricingAPIRequest request, string sourceSystem){
        String  marketableOfferId=request.marketableOfferId;
        List<String>  productCode=request.productCode;
        boolean isValidProductCode = true;
        
        
        List<cspmb__Price_Item__c> prodList = [Select ID,cspmb__Price_Item_Code__c,cspmb__Is_Active__c FROM cspmb__Price_Item__c WHERE Offer_Id__c= :marketableOfferId AND cspmb__Price_Item_Code__c IN : productCode AND (cspmb__Is_Active__c = True) WITH SECURITY_ENFORCED ];
        
        
        if(prodList.size() != productCode.size())
        {
            isValidProductCode = false;
        }
        
        
        
        return isValidProductCode ;
    }
    
    /**************************************************************************************
****** Desc         : Method to validate CIDN Number
****** Story        : DIGI-32339,DIGI-16483,DIGI-16567
****** Team         : Nirvana
***************************************************************************************/
    public static boolean isValidCIDN(PricingAPIRequest request, string sourceSystem){
        boolean isValidCIDN = true;
        
        
        List<Account> accList = [Select ID,Name,CIDN__c FROM Account WHERE CIDN__c =: request.cidn WITH SECURITY_ENFORCED  LIMIT 1];
        
        
        if(accList.size()<1){
            isValidCIDN = false;
        }
        
        
        
        return isValidCIDN ;
    }
    
}