global with sharing class CS_HuntGroupPrice extends cscfga.ALookupSearch {

    public override String getRequiredAttributes() {
        return '["ParentConfigID", "OfferId"]';
    }
    
    public override Object[] doDynamicLookupSearch(Map<String, String> searchFields, String productDefinitionId){
        System.debug('***searchFields.get(ParentConfigID)****' +searchFields.get('ParentConfigID'));
        system.debug('***searchFields.containsKey(ParentConfigID)***'+searchFields.containsKey('ParentConfigID'));
        List<cscfga__Product_Configuration__c> configList=new List<cscfga__Product_Configuration__c>();
        if(searchFields.containsKey('ParentConfigID'))
        {
            configList =[SELECT Name,cscfga__Configuration_Status__c,cscfga__originating_offer__r.Offer_Spec_Id__c from cscfga__Product_Configuration__c where Id =: searchFields.get('ParentConfigID')];
            System.debug('*****' +configList);
        }
        String offerId = searchFields.get('OfferId') != null ? searchFields.get('OfferId') : '';
         system.debug(LoggingLevel.INFO, 'CS_HuntGroupPrice.offerId = ' + offerId);
        List<cspmb__Price_Item__c> priceList= new List<cspmb__Price_Item__c>();
        Map<String,cspmb__Price_Item__c> PriceMap = new  Map<String,cspmb__Price_Item__c>();
        //if(!configList.isEmpty() && configList.size()>0)
        //{

            priceList = [SELECT id,Name,cspmb__Recurring_Charge__c,frequency__c,cspmb__One_Off_Charge__c,Check_todays_date__c,Currency__c,taxTreatment__c,unit_of_measure__c,billing_description__c from cspmb__Price_Item__c where cspmb__Product_Definition_Name__c =: System.Label.Hunt_group_PD_name AND Offer_Id__c = : offerId];
            system.debug('**priceList**'+priceList);
       // }
         
        return priceList;
          
    } 
}