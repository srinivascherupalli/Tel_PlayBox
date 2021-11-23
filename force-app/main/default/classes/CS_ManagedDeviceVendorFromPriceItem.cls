global with sharing class CS_ManagedDeviceVendorFromPriceItem extends cscfga.ALookupSearch {

    public override String getRequiredAttributes(){
        return '["DeviceTypeValue"]';
    }
    
    public override Object[] doLookupSearch(Map<String, String> searchFields, String productDefinitionId, Id[] excludeIds,
        Integer pageOffset, Integer pageLimit){
            List<cspmb__Price_Item__c> priceList = [SELECT Name,Type__c,Model__c,Contract_Type__c,cspmb__Recurring_Charge__c,cspmb__One_Off_Charge__c,Vendor__c,Package_Name__c,cspmb__Product_Definition_Name__c from cspmb__Price_Item__c where Type__c =:searchFields.get('DeviceTypeValue')];
            
            Map<String,cspmb__Price_Item__c> vendorMap = new  Map<String,cspmb__Price_Item__c>();
            if(priceList!=null)
            {
                for(cspmb__Price_Item__c item : priceList){
                    if(!vendorMap.containskey(item.Vendor__c)){
                    vendorMap.put(item.Vendor__c,item);
                    }
                }
                
            } 
        if(vendorMap!=null && vendorMap.size()>0)       
          return vendorMap.Values();
        else
          return null;  
    } 
}