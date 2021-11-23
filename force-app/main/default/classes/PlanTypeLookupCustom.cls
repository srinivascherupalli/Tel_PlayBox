/*********************************************************************************************************************************
Class Name :  PlanTypeLookupCustom
Test Class : PriceItemLookupCustomTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Laxmi  Rahate       20/8/2019       EDGE-92844-> PPHH - Class fpr Plan Type
2.            Hitesh/Aman         17/07/2020      EDGE-154026 moved offerTypeString in condition to be added only if present.
**********************************************************************************************************************************/
global with sharing class PlanTypeLookupCustom extends cscfga.ALookupSearch {
    public override String getRequiredAttributes()
    { 
        return '["OfferId,OfferTypeString,ProdSpecId"]'; 
    }

    public override Object[] doLookupSearch(Map<String, String> searchFields,String productDefinitionId, Id[] excludeIds, Integer pageOffset, Integer pageLimit)
    {   
        String searchQuery;
        String offerId='';
        String prodSpecId='';
        String offerTypeString='';
        //Added null check searchFields !=null by Aman Soni as a part of EDGE-154026
        if(searchFields !=null){
         offerId = searchFields.get('OfferId') != null ? searchFields.get('OfferId') : '';
         prodSpecId = searchFields.get('prodSpecID') != null ? searchFields.get('ProdSpecId') : '';
         offerTypeString = searchFields.get('OfferTypeString') != null ? searchFields.get('OfferTypeString') : ''; 
        }
        //Added by Aman Soni as a part of EDGE-154026 || Start
        Model_PriceItem mdPI = new Model_PriceItem();
        searchQuery = mdPI.getPlanType(offerId, offerTypeString);
        
        List<cspmb__Price_Item__c> CommercialProductsList = new List<cspmb__Price_Item__c>();
        if(String.isNotBlank(searchQuery)){
        CommercialProductsList = Database.query(searchQuery);
        }
        //Added by Aman Soni as a part of EDGE-154026 || End
        List<cspmb__Price_Item__c> distinctManufacturerList = new List<cspmb__Price_Item__c>();
        if(CommercialProductsList.size()>0){
          distinctManufacturerList = getUniqueListByField(CommercialProductsList, 'Type__c');
        }        
        return distinctManufacturerList;
    }

    @TestVisible
    private List<cspmb__Price_Item__c> getUniqueListByField(List<cspmb__Price_Item__c> pis, String fieldName){
        //List<cspmb__Price_Item__c> uItams = new List<cspmb__Price_Item__c>();
        Map<String, cspmb__Price_Item__c> itemMap =  new Map<String, cspmb__Price_Item__c>();
        for(cspmb__Price_Item__c item : pis) {
            if(fieldName == 'Type__c' && !itemMap.containsKey(item.Type__c)) {
                itemMap.put(item.type__c, item);
            }
        }
        System.debug('-----------> NonModuleTypeLookupCustom itemMap.values()   ' + itemMap.values());
        return itemMap.values();
    }
}