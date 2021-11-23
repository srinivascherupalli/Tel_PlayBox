/*****************************************************************************************************************************
Name : OpportunityProductType
Description : Used to have the common functionalities in this parent class and abstract methods to be overridden by sub classes.
1.		Laxmi Rahate	   07/04/2020	 EDGE-131729 CHanges for Incremental Revenue

******************************************************************************************************************************/

public abstract class OpportunityProductType {
    
    //abstract methods to be defined by sub-classes.    
    public abstract OpportunityLineItem updateOpportunityLineItem (OpportunityLineItem oli, Map <String,String> incrRevenueMap); //EDGE-131729 - Added Map in Signature
    public abstract List<cscfga__Product_Configuration__c> refreshOffer(String typeOfOffer);
    
    /* Factory pattern used to return the instance of the type based on basket. */
    public static OpportunityProductType getProductTypeInstance(String type){
        
        if(String.isBlank(type))
            return null;
        OpportunityProductType productType = new NonModularProductType();
        if(type == Label.Modular){
            productType = new ModularProductType();
        }
        return productType;
    }
    
    /* Checks if the product type in product basket is modular or not.
       returns boolean
    */   
    public static Boolean isModularProductType(cscfga__Product_Basket__c productBasket){
        return (productBasket.cscfga__Opportunity__r.Product_Type__c == Label.Modular); 
    } 
    
}