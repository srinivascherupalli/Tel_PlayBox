/********************************************************
Class Name      :   PopulateRateCardRowsforBilling
Test Class : PopulateRateCardRowsforBillingTest
===============================================================================================================================
Change.No.    Developer Name          	Date          Story Description
1.            Suyash Chiplunkar        20/07/20        DPG-2000 RTB Updated by adding Rate Rows for Shared Data IOT Solutions 
*******************************************************************************************************************************
*/
public with sharing class PopulateRateCardRowsforBilling {

	public static Map<Id, List<BillingSpecDTOV2.CustomRate>> getRateCardItems(String offerId){
		Map<Id, Id> rateCardIdCommercialProductIdMap = new Map<Id, Id>();

		for(cspmb__Price_Item_Rate_Card_Association__c rcl: [SELECT id,cspmb__Price_Item__r.Plan__c,cspmb__Price_Item__r.Name,
																cspmb__Rate_Card__r.Name,cspmb__Rate_Card__c 
															FROM   cspmb__Price_Item_Rate_Card_Association__c 
															WHERE  cspmb__Price_Item__r.Plan__c != NULL
															AND    cspmb__Price_Item__c !=NULL  
															AND    cspmb__Rate_Card__c != NULL  
															AND    cspmb__Price_Item__r.Offer_Id__c=:offerId 
															AND    cspmb__Price_Item__r.Plan__c != NULL]){

																
			rateCardIdCommercialProductIdMap.put(rcl.cspmb__Rate_Card__c,rcl.cspmb__Price_Item__c);
		}
		if(rateCardIdCommercialProductIdMap != null && !rateCardIdCommercialProductIdMap.isEmpty()){
			Set<Id> rateCardIdSet = rateCardIdCommercialProductIdMap.keySet();
			Map<Id, List<BillingSpecDTOV2.CustomRate>> RateCardMap = new Map<Id, List<BillingSpecDTOV2.CustomRate>>();
			for(cspmb__Rate_Card_Line__c rcl:[Select cspmb__Rate_Card__r.Name,id,name,Check_todays_date__c,
															toUnit__c,fromUnit__c,cspmb__Rate_Card__c,rateLineGroupIdentifier__c,
															cspmb__rate_value__c,cspmb__Rate_Card_Line_Unit__c,cspmb__Rate_Card__r.Offer_Id__c,cspmb__Rate_Card__r.cspmb__Rate_Card_Code__c,
															cspmb__Rate_Card__r.Check_todays_date__c 
													FROM   	cspmb__Rate_Card_Line__c 
													WHERE  	cspmb__Rate_Card__r.Offer_Id__c=:offerId 
													AND    	cspmb__Rate_Card__r.cspmb__Is_Active__c = True
													AND    	cspmb__Rate_Card__c IN :(rateCardIdSet) 
													AND    	Check_todays_date__c=true
													AND 	toUnit__c != NULL 
													AND 	fromUnit__c !=NULL
													//AND    cspmb__Rate_Card__r.Name  LIKE :queryFilter 
													ORDER By fromUnit__c]){
				BillingSpecDTOV2.CustomRate rateCardDto = new BillingSpecDTOV2.CustomRate();
				List < BillingSpecDTOV2.CustomRate > ChargeRateCardDTOIOTList = new List < BillingSpecDTOV2.CustomRate > ();

				rateCardDto.fromUnit=String.valueOf(Integer.valueOf(rcl.fromUnit__c));
				rateCardDto.toUnit=String.valueOf(Integer.valueOf(rcl.toUnit__c));
				rateCardDto.unitPrice=String.valueOf(rcl.cspmb__rate_value__c);
				
				if(RateCardMap!=null && RateCardMap.size()>0 && RateCardMap.containskey(rateCardIdCommercialProductIdMap.get(rcl.cspmb__Rate_Card__c))){
					ChargeRateCardDTOIOTList.addAll(RateCardMap.get(rateCardIdCommercialProductIdMap.get(rcl.cspmb__Rate_Card__c)));
					ChargeRateCardDTOIOTList.add(rateCardDto);
					RateCardMap.put(rateCardIdCommercialProductIdMap.get(rcl.cspmb__Rate_Card__c),ChargeRateCardDTOIOTList);
				}else{
					ChargeRateCardDTOIOTList.add(rateCardDto);
					RateCardMap.put(rateCardIdCommercialProductIdMap.get(rcl.cspmb__Rate_Card__c),ChargeRateCardDTOIOTList);
				}
			}
			return RateCardMap;
		}
		return null;
	}

	//Search RateRow based on commercial product id
	public static List<BillingSpecDTOV2.CustomRate> addRateCardRowsToBillingSpecs(BillingSpecDTOV2.BillingSpecifications billingspecification, CS_SpecificationDTO.ServiceSpecification billingSpec, String OfferId, Map<Id, List<BillingSpecDTOV2.CustomRate>> RateCardMap){

		if(billingSpec.simpleAttributes.size()!=0 && billingSpec.simpleAttributes!=null){
			Map<String,String> valueMap=new map<String,String>();
			for(CS_SpecificationDTO.SimpleAttributes simpleAttribute:billingSpec.simpleAttributes){
				valueMap.put(simpleAttribute.name,simpleAttribute.value);
			}
			String commercialProductId;
			if(valueMap.containsKey('sharedPlanId')){
				commercialProductId = valueMap.get('sharedPlanId');
				List<BillingSpecDTOV2.CustomRate> customRateIOTList=new List<BillingSpecDTOV2.CustomRate>();
				if(RateCardMap.containsKey(commercialProductId)){
					customRateIOTList = RateCardMap.get(commercialProductId); 
					return customRateIOTList;
				}
				return null;
			}
			return null;
		}
		return null;
	}
}