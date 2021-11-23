/****************************************************************************
@Name			: OpportunityLineItemTriggerHelper
@TestCoverage   : OpportunityLineItemTriggerHandlerTest
@Author			: SFO(SanFrancisco)/Sravanthi
@Sprint 		: 20.08[P2OB-6818]
@CreateDate		: 15/06/2020
@Description	: This Class is for OpportunityLineItem Trigger
********************************************************************************/
public without sharing class OpportunityLineItemTriggerHelper {
    /****************************************************************************
@Method Name	: setNPSS
@Author			: SFO(SanFrancisco)/Sravanthi
@Sprint 		: 20.08[P2OB-6818]
@CreateDate		: 15/06/2020
@Description	: This Method is triggered before insert of Opportunity line Item to set the NPSS__c field.
********************************************************************************/
    public void setNPSS(Map<id,OpportunityLineItem> oldOppLineItemMap,List<OpportunityLineItem> newOppLineItemList){
        try{
            Map<string,NPSS__c> productCodeNPSSMap = getNPSSMap(oldOppLineItemMap,newOppLineItemList);
            
            if( !productCodeNPSSMap.isEmpty()){
                for(OpportunityLineItem oppProduct : newOppLineItemList){
                    if(productCodeNPSSMap.containsKey(oppProduct.Product_Code__c) && oldOppLineItemMap == null ||(oldOppLineItemMap !=null && oldOppLineItemMap.containsKey(oppProduct.id) && oldOppLineItemMap.get(oppProduct.id).Product_Code__c !=oppProduct.Product_Code__c) ){
                        oppProduct.NPSS__c =productCodeNPSSMap.get(oppProduct.Product_Code__c).id;
                    }
                    else if(oldOppLineItemMap == null ||(productCodeNPSSMap.get(oppProduct.Product_Code__c)== null && oldOppLineItemMap.get(oppProduct.id).Product_Code__c !=oppProduct.Product_Code__c)){
                        oppProduct.NPSS__c =null;
                    }
                }
                
            }
            
        }
        catch(Exception ex){
            system.debug('Exception:::: OpportunityLineItemTriggerHelper Class:::: setNPSS Method'+ Ex.getMessage());
        }  
    }
    /****************************************************************************
@Method Name	: getNPSS
@Author			: SFO(SanFrancisco)/Sravanthi
@Sprint 		: 20.08[P2OB-6818]
@CreateDate		: 15/06/2020
@Description	: This Method is called from before insert/update and returns map of NPSS product code with relevant NPSS record. 
@Updated        : P2OB-6787 , Bypassed the NPSS field population for modular opportunities.
********************************************************************************/    
    private Map<string,NPSS__c> getNPSSMap(Map<id,OpportunityLineItem> oldOppLineItemMap,List<OpportunityLineItem> newOppLineItemList){
        Map<string,NPSS__c> productCodeNPSSMap = new Map<string,NPSS__c>();
        try{
            List<String> productCodes = new List<String>();
            if(newOppLineItemList != null && !newOppLineItemList.isEmpty()){
                for(OpportunityLineItem oppProduct : newOppLineItemList){
                    //P2OB-6787 , Bypassed the NPSS field population for modular opportunities
                    if(oppProduct.Opportunity_Product_Type__c != Label.Opp_ProductType_Modular && (oldOppLineItemMap == null ||(oldOppLineItemMap !=null && oldOppLineItemMap.containsKey(oppProduct.id) && oldOppLineItemMap.get(oppProduct.id).Product_Code__c !=oppProduct.Product_Code__c)) ){
                        productCodes.add(oppProduct.Product_Code__c);
                    }
                }
                if(!productCodes.isEmpty()){
                    for(NPSS__c npss :[SELECT id,Name FROM NPSS__c WHERE Name in : productCodes]){
                        productCodeNPSSMap.put(npss.Name,npss);
                    }
                }
            }
        }
        catch(Exception ex){
            system.debug('Exception:::: OpportunityLineItemTriggerHelper Class:::: getNPSSMap Method'+ Ex.getMessage());
        }
        return productCodeNPSSMap;
    }
    
}