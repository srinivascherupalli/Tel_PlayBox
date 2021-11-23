global with sharing class CS_DeviceModelFromPriceItem extends cscfga.ALookupSearch {

    public override String getRequiredAttributes(){
        return '["TypeSelected"]';
    }
    
    public override Object[] doLookupSearch(Map<String, String> searchFields, String productDefinitionId, Id[] excludeIds,
        Integer pageOffset, Integer pageLimit){
            List<cspmb__Price_Item__c> priceList = [SELECT Name,Type__c,Model__c,Contract_Type__c,cspmb__Recurring_Charge__c,cspmb__One_Off_Charge__c from cspmb__Price_Item__c where Type__c =:searchFields.get('TypeSelected')];
            
            Map<String,cspmb__Price_Item__c> modelMap = new  Map<String,cspmb__Price_Item__c>();
            if(priceList!=null)
            {
                for(cspmb__Price_Item__c item : priceList){
                    if(!modelMap.containskey(item.Model__c)){
                    modelMap.put(item.Model__c,item);
                    }
                }
                
            } 
        if(modelMap!=null && modelMap.size()>0)       
          return modelMap.Values();
        else
          return null;  
    } 
}