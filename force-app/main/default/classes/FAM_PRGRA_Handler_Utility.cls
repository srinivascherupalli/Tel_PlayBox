/*****************************************************************************************
* Name : FAM_PRGRA_Handler_Utility
* Description : 
* ModifiedBy        ModifiedDate    Edge Number   Description
* Shashank Jadhav   10/05/2021      EDGE-219476   Pricing Rule per product family     
* Shashank Jadhav   28/07/2021      EDGE-229566	  Pricing rule code is blank for newly created Pricing Rules.
************************************************************************************************************************************************/
public with sharing class FAM_PRGRA_Handler_Utility {
    
    //Get the exiting Oricing Rules    
    public Map<Id,cspmb__pricing_rule__c> getExistingPricingRules(Set<Id> setOfPricingRules){
        //EDGE- :Added cspmb__pricing_rule_code__c in query
        return new Map<Id,cspmb__pricing_rule__c>([SELECT cspmb__pricing_rule_code__c,cspmb__description__c,cspmb__effective_end_date__c,cspmb__effective_start_date__c,Id,Name,Product_Family__c FROM cspmb__Pricing_Rule__c where Id IN: setOfPricingRules]);
    }
    
    //Upsert the List OF Pricing Rules
    public Boolean upsertListOfPricingRules(List<cspmb__pricing_rule__c> listOfPRToUpsert){
        Boolean isError=false;
        if((listOfPRToUpsert != null && !listOfPRToUpsert.isEmpty()) || Test.isRunningTest() ){
            Database.UpsertResult[] saveResultList = Database.upsert(listOfPRToUpsert);
            for (Database.UpsertResult sr : saveResultList) {
                if (!sr.isSuccess()){isError=true;}
            }
        }
        return isError;
    }
    
    //Upsert the List OF PRGRA
    public Boolean upsertListOfPricingRulesGroupRuleAsssociation(List<cspmb__Pricing_Rule_Group_Rule_Association__c> listOfPRGRARecords){
        Boolean isError2=false;
        if(listOfPRGRARecords != null && !listOfPRGRARecords.isEmpty()){
            Database.UpsertResult[] saveResultList = Database.upsert(listOfPRGRARecords);
            for (Database.UpsertResult sr : saveResultList) {
                if (!sr.isSuccess()) {isError2=true;}
            }
        }
        return isError2;
    }
    
    //Update the List Of PIPRA records
    public Boolean upsertListOfPricingRulesGroupRuleAsssociation(List<cspmb__Price_Item_Pricing_Rule_Association__c> listOfPIPRAForUpdate){
        Boolean isError3=false;
        if(listOfPIPRAForUpdate != null && !listOfPIPRAForUpdate.isEmpty()){
            Database.SaveResult[] updateResultList = Database.update(listOfPIPRAForUpdate);
            for (Database.SaveResult sr : updateResultList) {
                if (!sr.isSuccess()) {                    isError3=true;               }
            }
        }
        return isError3;
    }
}