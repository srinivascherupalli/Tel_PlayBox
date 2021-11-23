/*******************************************************************************************************************************
Name : NonModularProductType
Description : Extends OpportunityProductType and it is used to have the functionalities associated with non-modular product type
1.		Laxmi Rahate	   07/04/2020	 EDGE-131729 CHanges for Incremental Revenue

********************************************************************************************************************************/

global with sharing class NonModularProductType extends OpportunityProductType{

    public override OpportunityLineItem updateOpportunityLineItem(OpportunityLineItem oli,Map <String,String> incrRevenueMap)//EDGE-131729 - Added Map in Signature
    {
        if(oli.Product_Status__c == 'Lost' || oli.Product_Status__c == 'Withdrawn')
            oli.UnitPrice = 0.00;
        else
            oli.UnitPrice = oli.cscfga__Attribute__r.cscfga__Product_Configuration__r.cscfga__Total_Contract_Value__c;
        
        return oli;
    }
    
    // Invoked from OfferAutoRefresh.cls
    public override List<cscfga__Product_Configuration__c> refreshOffer(String typeOfOffer){
        List<cscfga__Product_Configuration__c> configIds = New List<cscfga__Product_Configuration__c> ();
        String nonModularOffers = Label.NonModular_Offers;
        List<String> listNonModularOffers = nonModularOffers != null ? nonModularOffers.split(',') : null;
        
        if(null != listNonModularOffers){
            configIds =[SELECT Id ,
                         cscfga__Configuration_Status__c
                         FROM cscfga__Product_Configuration__c
                         where cscfga__Product_Configuration__c.OfferName__c
                         in : listNonModularOffers ];
        }

       return configIds;
    }
}