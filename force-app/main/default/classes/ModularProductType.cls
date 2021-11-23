/***********************************************************************************
Name : ModularProductType
Description : Used to have the functionalities associated with modular product type
1.		Laxmi Rahate	   07/04/2020	 EDGE-131729 CHanges for Incremental Revenue
1.		Laxmi Rahate	   10/04/2020	 EDGE-133414 Commented population of Unit Price
************************************************************************************/
global with sharing class ModularProductType extends OpportunityProductType {
    //Invoked from CustomButtonOpportunitySync.cls
    public override OpportunityLineItem updateOpportunityLineItem(OpportunityLineItem oli,Map <String,String> incrRevenueMap) //EDGE-131729 - Added Map in Signature
    {
        //   EDGE-61607
        if(oli.Recurring_Price__c > 0.00){
            oli.New_Income_Revenue__c = oli.Recurring_Price__c * oli.Quantity * Decimal.valueof(label.Contract_Term_For_New_Income);
            oli.Avg_Annualised_Revenue__c = oli.New_Income_Revenue__c;
        }
        if(oli.One_Off_Price__c > 0.00){
            oli.Once_Off_Revenue__c = oli.One_Off_Price__c * oli.Quantity;
        }
        // EDGE-131729 - setting the incremental Revenue field from the MAP sent in signature
        if (incrRevenueMap.containsKey (oli.cscfga__Attribute__c)){
	        String incrementalRevenueStr = incrRevenueMap.get(oli.cscfga__Attribute__c);
            if (incrementalRevenueStr!= null && incrementalRevenueStr != '') {
            oli.Incremental_Revenue__c = Decimal.valueof (incrementalRevenueStr); 
            }
        }
         //EDGE-131729 Commented OLD Incremental Revenue Logic as part of 
		/****
        if(oli.New_Income_Revenue__c == null)
            oli.Incremental_Revenue__c = oli.Once_Off_Revenue__c;
        else{
            system.debug('valueof'+oli.New_Income_Revenue__c+'onceoff'+oli.Once_Off_Revenue__c);
            if(oli.Once_Off_Revenue__c != null){
                oli.Incremental_Revenue__c = oli.New_Income_Revenue__c+oli.Once_Off_Revenue__c;
            }
            else{
                oli.Incremental_Revenue__c = oli.New_Income_Revenue__c;
            }
        }
        **/ //EDGE-131729 - Comment END
        //  EDGE-61607
        // Commented Below If Condition to set Unit Price as PART OF EDGE-133414
        // below if condition added as part of EDGE-79675
       /* if(!((oli.cscfga__Attribute__r.name).contains('EarlyTerminationCharge')))
            oli.UnitPrice = oli.cscfga__Attribute__r.cscfga__Product_Configuration__r.cscfga__Total_Contract_Value__c;
		**/
        oli.OfferName__c = oli.cscfga__Attribute__r.cscfga__Product_Configuration__r.OfferName__c;
        return oli;
    }
    // Invoked from OfferAutoRefresh.cls
    public override List<cscfga__Product_Configuration__c> refreshOffer(String typeOfOffer){
        List<cscfga__Product_Configuration__c> configIds = New List<cscfga__Product_Configuration__c> ();
        String modularOffers = Label.Modular_Offers;
        List<String> listmodularOffers = modularOffers != null ? modularOffers.split(',') : null;
        if(null != listmodularOffers){
            configIds =[ SELECT Id ,
                         cscfga__Configuration_Status__c
                         FROM cscfga__Product_Configuration__c
                         where cscfga__Product_Configuration__c.cscfga__Product_Basket__c = null ];
            }
        return configIds;
    }
    //Updates the info of opportunity
    public static void updateOpportunityInfo(cscfga__Product_Basket__c productBasket){
        if(productBasket.csordtelcoa__Basket_Stage__c == CustomConfigurationOptions__c.getValues('CommercialConfiguration').Enrichment_Basket_Stage__c)
            OpportunitySyncUtil.updateOpptInfo(productBasket, 'CommercialConfiguration');        
        if(productBasket.csordtelcoa__Basket_Stage__c == CustomConfigurationOptions__c.getValues('Quote').Enrichment_Basket_Stage__c)
            OpportunitySyncUtil.updateOpptInfo(productBasket, 'Quote');                
        if(productBasket.csordtelcoa__Basket_Stage__c == CustomConfigurationOptions__c.getValues('ContractAccepted').Enrichment_Basket_Stage__c)
            OpportunitySyncUtil.updateOpptInfo(productBasket, 'ContractAccepted');
    }
}