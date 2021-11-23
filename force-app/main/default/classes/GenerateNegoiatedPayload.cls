/*
* @Author  : Mukta Wadhwani 
  @Team    : Apple
* @Date    : 18-05-2021
* @Desc    : This class is to generate custom rate block in RTB Payload for NGUC.
* @Jira    : EDGE-218386
1.  Vijaya                10/08/2021      DIGI-28478	To generate custom rate block in RTB Payload for IoT.
*/
public class GenerateNegoiatedPayload {
    public static Map<Id,Map<Id, Map<Id, Decimal>>> subIdRateCardAndRateValueMap {get;set;}
    private static Map<String, String> rateCardIds {
        get{
            if(rateCardIds == null){
                rateCardIds = new Map<String, String>();

                for(cspmb__Price_Item_Rate_Card_Association__c item : [SELECT cspmb__Price_Item__c, cspmb__Rate_Card__c
                                                                        FROM cspmb__Price_Item_Rate_Card_Association__c
                                                                        WHERE cspmb__Price_Item__c IN: [SELECT Offer_Id__c
                                                                        FROM cspmb__Price_Item__c
                                                                        WHERE Offer_Id__c ='DMCAT_Offer_001522']
                                                                        AND (NOT cspmb__Rate_Card__r.Name LIKE '%ExcessCharge%')]){
                    rateCardIds.put(item.cspmb__Price_Item__c, item.cspmb__Rate_Card__c);
                }
            }
            return rateCardIds;
        }
        set;
    }
    
    //This method is creating a map of subscription Id and the negotiated prices recieved from fram aggrement.
    public static Map<Id,Map<Id,Map<Id,Decimal>>> getSubscriptionIdRateValueMap(List<Id> subscriptionIdList){
        
        FAM_Utility famUtil = new FAM_Utility(subscriptionIdList); 
        Map<Id,Map<Id,Decimal>> rateValueMap = new Map<Id,Map<Id,Decimal>>();
        Map<Id,Map<Id,Map<Id,Decimal>>> subscriptionIdRateValueMap = new Map<Id,Map<Id,Map<Id,Decimal>>>();
        Map<Id,Map<Id, FAM_Utility.VolumeAndPricing>> productToVolumeAndPricingBulkMap = famUtil.getProductToVolumeAndPricingBulkMap();
        Map<Id,Id> sourceToFrameAggrementIdMap = famUtil.getSourceToFrameAggrementIdMap();
        for(Id subId : sourceToFrameAggrementIdMap.keyset()){
            Map<Id, FAM_Utility.VolumeAndPricing> productRateCardLineMap = new  Map<Id, FAM_Utility.VolumeAndPricing>();
            if ( sourceToFrameAggrementIdMap.containsKey(subId) && productToVolumeAndPricingBulkMap.containsKey( sourceToFrameAggrementIdMap.get(subId) ) ) {
                	productRateCardLineMap = productToVolumeAndPricingBulkMap.get(sourceToFrameAggrementIdMap.get(subId));
            }
            for(FAM_Utility.VolumeAndPricing volumePricingObj : productRateCardLineMap.values()){ 
                Map<Id,Map<Id, Decimal>> ratecardLineMap = volumePricingObj.rateCardToRateCardLinesMap;
                if(ratecardLineMap != null){
                    for(String rateCardId : ratecardLineMap.keySet()){
                        Map<Id, Decimal> rateCardLineandValueMap = ratecardLineMap.get(rateCardId);
                        rateValueMap.put(rateCardId,rateCardLineandValueMap);
                    }
                    subscriptionIdRateValueMap.put(subId,rateValueMap);
                }
            }
        }
        subIdRateCardAndRateValueMap = subscriptionIdRateValueMap;
        return subscriptionIdRateValueMap;
    }
    //getSubscriptionIdRateValueMap method ends.
    
    //This method is creating the custom rate and rate group block for billing specification in RTB Payload.
    public  BillingSpecDTOV2.BillingSpecifications createCustomRateAndRateGroup(populateBillingSpecWrapper wrapObj){
        Map<String,String> valueMap = new map<String,String>();
        for(CS_SpecificationDTO.SimpleAttributes simpleAttribute : wrapObj.billSpec.simpleAttributes){
            if(wrapObj.addExternalId && simpleAttribute.name == 'externalId' && simpleAttribute.value != null){
                wrapObj.billingspecification.externalRateId = simpleAttribute.value;
            }
        else if(wrapObj.addExternalId && simpleAttribute.name == 'billDescription' && simpleAttribute.value != null){
                wrapObj.billingspecification.description = simpleAttribute.value;
            }
            else{
                valueMap.put(simpleAttribute.name,simpleAttribute.value);
            }
        }
        String plan = valueMap.containsKey('callingPlans') ? valueMap.get('callingPlans') : '';
        String mode = valueMap.containsKey('concurrencyLimitMode') ? valueMap.get('concurrencyLimitMode') : '';
        //If condition to check if plan and mode matches with specification data then prepare custom rate block 
        if(wrapObj.rateCardWrapperObj.comboToLinesWrap.containsKey(mode+'-'+plan) && !wrapObj.rateCardWrapperObj.comboToLinesWrap.get(mode+'-'+plan).isEmpty()){
            populateBillingSpecWrapper populateBillingWrapObj = new populateBillingSpecWrapper();
            populateBillingWrapObj.rateCardWrapperObj = wrapObj.rateCardWrapperObj;
            populateBillingWrapObj.valueMap = valueMap;
            populateBillingWrapObj.billingspecification = wrapObj.billingspecification;
            populateBillingWrapObj.mode = mode;
            populateBillingWrapObj.plan = plan;
            populateBillingWrapObj.subscriptionId = wrapObj.subscriptionId;
            wrapObj.billingspecification = populateCustomRateBlockForCallingPlan(populateBillingWrapObj);
        } 
        // DIGI-28478	To generate custom rate block in RTB Payload for IoT.
		else if(valueMap.containsKey('sharedPlanId'))
		{
            System.debug('-=00=- '+rateCardIds);
            System.debug('Sharedplan Id '+valueMap.get('sharedPlanId'));
            if(rateCardIds.containsKey(valueMap.get('sharedPlanId'))) {
                wrapObj.billingspecification = populateCustomRateBlockForIoT(wrapObj.rateCardWrapperObj, wrapObj.billingspecification, wrapObj.subscriptionId, valueMap.get('sharedPlanId'));
            }
		}
		//If condition to check if feature usage charge Id is there in specification data then prepare rate group block
        else if( valueMap.containsKey('chargeId') && wrapObj.rateCardWrapperObj.chargeId == valueMap.get('chargeId') ) {
            wrapObj.billingspecification = populateRateGroupForFeaturePlan(wrapObj.rateCardWrapperObj,wrapObj.billingspecification,wrapObj.subscriptionId);
            
        }

        return wrapObj.billingspecification;
    }
     //Prepare custom rate block for calling plan.
    private static BillingSpecDTOV2.BillingSpecifications populateCustomRateBlockForCallingPlan(populateBillingSpecWrapper populateBillingWrapObj){
        List<BillingSpecDTOV2.CustomRate> customRateList = new List<BillingSpecDTOV2.CustomRate>();
        for (cspmb__Rate_Card_Line__c rateCardLineObj: populateBillingWrapObj.rateCardWrapperObj.comboToLinesWrap.get(populateBillingWrapObj.mode+'-'+populateBillingWrapObj.plan)){
            if(populateBillingWrapObj.valueMap.containsKey('chargeId') && populateBillingWrapObj.valueMap.get('chargeId') == rateCardLineObj.cspmb__Rate_Card__r.Charge_ID__c){
                BillingSpecDTOV2.CustomRate customRate = new BillingSpecDTOV2.CustomRate();
                customRate.fromUnit 				   = String.valueOf(Integer.valueOf(rateCardLineObj.fromUnit__c));
                customRate.toUnit                      = String.valueOf(Integer.valueOf(rateCardLineObj.toUnit__c));
                
                //Check if negotiated prices are present put negotiated prices in unitPrice
                if(subIdRateCardAndRateValueMap.containsKey(populateBillingWrapObj.subscriptionId) && 
                   subIdRateCardAndRateValueMap.get(populateBillingWrapObj.subscriptionId) != null && 
                   subIdRateCardAndRateValueMap.get(populateBillingWrapObj.subscriptionId).containsKey(rateCardLineObj.cspmb__Rate_Card__c) &&
                   subIdRateCardAndRateValueMap.get(populateBillingWrapObj.subscriptionId).get(rateCardLineObj.cspmb__Rate_Card__c) != null){
                       customRate.unitPrice             =   String.valueOf(subIdRateCardAndRateValueMap.get(populateBillingWrapObj.subscriptionId).get(rateCardLineObj.cspmb__Rate_Card__c).get(rateCardLineObj.Id));
                   }
                
                //If negotiated prices are not present put the prices from rate card line object 
                else{
                    customRate.unitPrice                =   String.valueOf(rateCardLineObj.cspmb__rate_value__c);
                }
                customRate.externalRateId               =   rateCardLineObj.External_Id__c;
                customRateList.add(customRate);
                populateBillingWrapObj.billingspecification.featureId          =   rateCardLineObj.cspmb__Rate_Card__r.cspmb__Rate_Card_Code__c;
            }
        }
        if (!customRateList.isEmpty()){
            populateBillingWrapObj.billingspecification.customRate = customRateList;
        }
        return populateBillingWrapObj.billingspecification;
    }
     //Prepare Rate Group block for feature usage charges product if negotiated prices are present
    private static BillingSpecDTOV2.BillingSpecifications populateRateGroupForFeaturePlan(RetrieveRateCard.PriceItemWrapper rateCardWrapperObj,BillingSpecDTOV2.BillingSpecifications billingspecification,Id subscriptionId){
        List<BillingSpecDTOV2.RateGroup> rateGroupList = new List<BillingSpecDTOV2.RateGroup>();    
        for (String rateCardId : rateCardWrapperObj.comboToLinesWrap.keySet()){
            if(!rateCardId.contains('-') && subIdRateCardAndRateValueMap.containsKey(subscriptionId) &&
               subIdRateCardAndRateValueMap.get(subscriptionId) != null  &&
               subIdRateCardAndRateValueMap.get(subscriptionId).containsKey(rateCardId)){
                   BillingSpecDTOV2.RateGroup rateGroup = new BillingSpecDTOV2.RateGroup();
                   rateGroup.rateGroupId = rateCardWrapperObj.comboToLinesWrap.get(rateCardId)[0].cspmb__Rate_Card__r.cspmb__Rate_Card_Code__c;
                   rateGroup.customRate = new List<BillingSpecDTOV2.CustomRate>();
                   for(cspmb__Rate_Card_Line__c rateCardLineObj : rateCardWrapperObj.comboToLinesWrap.get(rateCardId)){
                       BillingSpecDTOV2.CustomRate customRate  =   new BillingSpecDTOV2.CustomRate();
                       customRate.fromUnit                     =   String.valueOf(Integer.valueOf(rateCardLineObj.fromUnit__c));
                       customRate.toUnit                       =   String.valueOf(Integer.valueOf(rateCardLineObj.toUnit__c));
                       customRate.unitPrice                    =  String.valueOf(subIdRateCardAndRateValueMap.get(subscriptionId).get(rateCardId).get(rateCardLineObj.Id));
                       customRate.externalRateId               =   rateCardLineObj.External_Id__c;
                       rateGroup.customRate.add(customRate);
                   }
                   rateGroupList.add(rateGroup);
               }
        }
        if (!rateGroupList.isEmpty()){
            billingspecification.rateGroups = rateGroupList;
        }
        return billingspecification;
    }
	
	// DIGI-28478	To generate custom rate block in RTB Payload for IoT.
	//Prepare custom rate block for IoT.
    public BillingSpecDTOV2.BillingSpecifications populateCustomRateBlockForIoT(RetrieveRateCard.PriceItemWrapper rateCardWrapperObj, BillingSpecDTOV2.BillingSpecifications billingspecification, Id subscriptionId, String sharedPlanId){
		List<BillingSpecDTOV2.CustomRate> customRateList = new List<BillingSpecDTOV2.CustomRate>();
        String rateCardId = rateCardIds.get(sharedPlanId);
				for(cspmb__Rate_Card_Line__c rateCardLineObj : rateCardWrapperObj.comboToLinesWrap.get(rateCardId)){

                        BillingSpecDTOV2.CustomRate customRate  =   new BillingSpecDTOV2.CustomRate();
                        customRate.fromUnit                     =   String.valueOf(Integer.valueOf(rateCardLineObj.fromUnit__c));
                        customRate.toUnit                       =   String.valueOf(Integer.valueOf(rateCardLineObj.toUnit__c));
                        if(subIdRateCardAndRateValueMap.containsKey(subscriptionId)) {
                            customRate.unitPrice = String.valueOf(subIdRateCardAndRateValueMap.get(subscriptionId).get(rateCardId).get(rateCardLineObj.Id));
                        }else{
                            customRate.unitPrice = String.valueOf(rateCardLineObj.cspmb__rate_value__c);
                        }
                        customRateList.add(customRate);
                        billingspecification.featureId          =   rateCardLineObj.cspmb__Rate_Card__r.cspmb__Rate_Card_Code__c;
                }
        if (!customRateList.isEmpty()){
			billingspecification.customRate = customRateList;
        }
        return billingspecification;
    }
	// DIGI-28478	End
	
    public class populateBillingSpecWrapper{
        public  Id subscriptionId;
        public  RetrieveRateCard.PriceItemWrapper rateCardWrapperObj;
        public  CS_SpecificationDTO.ServiceSpecification billSpec;
        public  BillingSpecDTOV2.BillingSpecifications billingspecification;
        public  boolean addExternalId;
        public  Map<String,String> valueMap;
        public  String mode;
        public  String plan;
    }
}