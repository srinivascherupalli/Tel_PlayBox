global with sharing class CS_DeviceTypeFromPriceItemManagedDevice extends cscfga.ALookupSearch {

    public override String getRequiredAttributes(){
        return '[""]';
    }
    
    public override Object[] doLookupSearch(Map<String, String> searchFields, String productDefinitionId, Id[] excludeIds,
        Integer pageOffset, Integer pageLimit){
            List<cspmb__Price_Item__c> priceList = [SELECT Name,Type__c,Model__c,Contract_Type__c,cspmb__Recurring_Charge__c,cspmb__One_Off_Charge__c,Vendor__c,Package_Name__c,cspmb__Product_Definition_Name__c from cspmb__Price_Item__c where Package_Name__c ='Connected Workplace' AND cspmb__Product_Definition_Name__c ='Managed Router'];
            
            Map<String,cspmb__Price_Item__c> typeMap = new  Map<String,cspmb__Price_Item__c>();
            if(priceList!=null)
            {
                for(cspmb__Price_Item__c item : priceList){
                    if(!typeMap.containskey(item.type__c)){
                    typeMap.put(item.type__c,item);
                    }
                }
                
            } 
        if(typeMap!=null && typeMap.size()>0)       
          return typeMap.Values();
        else
          return null;  
    } 
}