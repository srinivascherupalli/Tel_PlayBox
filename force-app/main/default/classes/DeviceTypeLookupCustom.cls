/*********************************************************************************************************************************
Class Name : DeviceTypeLookupCustom
Test Class : DeviceTypeLookupCustomTest
===============================================================================================================================
Change.No.    Developer Name          Date     Story        Description
1.            Ankit Goswami     30/8/2019      EDGE-112367  PPHH - Class for Device Type
2.            Aman Soni         27/9/2019      EDGE-112367  PPHH - Class for Device Type
3.            Aman Soni         16/10/2019     EDGE-112367  Change in Type__c field values
4.            Aman Soni         16/10/2019     EDGE-148729  Modified Type__c condition and added Model__c and Manufacturer__c by Aman Soni
5.            Aman Soni         03/10/2020     EDGE-148667  Added by Aman Soni
6.            Krunal Taak       05/01/2021     DPG-3358     Added new attribute "ItemCode" and passed new parameter in getDeviceType method
*********************************************************************************************************************************/

global with sharing class DeviceTypeLookupCustom extends cscfga.ALookupSearch {
    public override String getRequiredAttributes()
    {return '["OfferId,PlanType,ItemCode"]';}

    public override Object[] doLookupSearch(Map<String, String> searchFields,String productDefinitionId, Id[] excludeIds, Integer pageOffset, Integer pageLimit)
    {       
        String offerId;
        String PlanType;
        String ItemCode;
        String searchQuery;
        List<cspmb__Price_Item__c> distinctDeviceList=new List<cspmb__Price_Item__c>();
        if(searchFields !=null){
             offerId = searchFields.get('OfferId') != null ? searchFields.get('OfferId') : '';
             PlanType= searchFields.get('PlanType') != null ? searchFields.get('PlanType') : '';
             ItemCode= searchFields.get('ItemCode') != null ? searchFields.get('ItemCode') : '';
         }
        system.debug(LoggingLevel.INFO, 'PlanTypeLookupCustom.offerId = ' + offerId + ' PlanType - ' + PlanType);
        //Added by Aman Soni as a part of EDGE-148667 || Start
        Model_PriceItem mdPI = new Model_PriceItem();
        searchQuery = mdPI.getDeviceType(offerId, PlanType, ItemCode);
               
        System.debug('PlanTypeLookupCustom searchQuery: ' + searchQuery);
        List<cspmb__Price_Item__c> CommercialProductsList = new  List<cspmb__Price_Item__c>();
        if(String.isNotBlank(searchQuery))
             CommercialProductsList =Database.query(searchQuery);
        System.debug('CommercialProductsListy: ' + CommercialProductsList);
        //Added by Aman Soni as a part of EDGE-148667 || End 
        if(!CommercialProductsList.isEmpty()){
            distinctDeviceList = getUniqueListByField(CommercialProductsList,'Type__c');
        }
        return distinctDeviceList;
    }

  @TestVisible
    private List<cspmb__Price_Item__c> getUniqueListByField(List<cspmb__Price_Item__c> pis, String fieldName){
        Map<String, cspmb__Price_Item__c> itemMap =  new Map<String, cspmb__Price_Item__c>();
        for(cspmb__Price_Item__c item : pis) {
            if(fieldName == 'Type__c' && !itemMap.containsKey(item.Type__c)) {
                itemMap.put(item.Type__c, item);
            }
        }
        System.debug('-----------> NonModuleTypeLookupCustom itemMap.values()   ' + itemMap.values());
        return itemMap.values();
    }
}