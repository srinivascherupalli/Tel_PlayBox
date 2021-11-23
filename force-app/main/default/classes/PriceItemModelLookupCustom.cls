/******************************************************************************************************************************************
Class Name : PriceItemModelLookupCustom
Test Class : PriceItemModelLookupCustomTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Ankit Goswami         30/8/2019      EDGE-112367  PPHH -Test class for PriceItemColourLookupCustom
2.            Aman Soni             15/10/2019     EDGE-112367  correction in Device_Enrolment__c field
3.            Ankit Goswami         29/10/2019     EDGE-113391  deviceTypeString and Check_todays_date__c added 
4.            Gnana                 30/04/2020     EDGE-140968   Added Charge id in SOQL query
5.            Aman Soni             23/06/2020     EDGE-148667  Added Device_Care__c field in SOQL Query and updated version setting to 48.0
*********************************************************************************************************************************************
*/

global with sharing  class PriceItemModelLookupCustom  extends cscfga.ALookupSearch {
   
    public override String getRequiredAttributes()
    { 
        return '["MobileHandsetManufacturer","OfferId","deviceTypeString"]';//EDGE-81077 added OfferID //deviceTypeString added as part of EDGE-113391
    }

    public override Object[] doLookupSearch(Map<String, String> searchFields,String productDefinitionId, Id[] excludeIds, Integer pageOffset, Integer pageLimit)
    {
        System.debug('PriceItemModelLookupCustom searchFields: ' + searchFields);
        //String searchValue = ApexPages.currentPage().getParameters().get('searchValue');
        String searchValue = '';
        
        if (searchFields.containsKey('searchValue') && searchFields.get('searchValue') != NULL && searchFields.get('searchValue') != '') {
            searchValue = '%' + searchFields.get('searchValue') + '%';
        }
        
        System.debug('PriceItemModelLookupCustom searchValue: ' + searchValue);
        System.debug('PriceItemModelLookupCustom searchFields: ' + searchFields);
        
        
        Id chosenManufacturerPriceItemId = Id.valueOf(searchFields.get('MobileHandsetManufacturer'));
        cspmb__Price_Item__c chosenManufacturerPriceItem = [SELECT Manufacturer__c FROM cspmb__Price_Item__c WHERE Id =: chosenManufacturerPriceItemId];
        String selectedManufacturer = chosenManufacturerPriceItem.Manufacturer__c;
        System.debug('PriceItemModelLookupCustom chosenManufacturerPriceItem: ' + chosenManufacturerPriceItem);
        System.debug('PriceItemModelLookupCustom selectedManufacturer: ' + selectedManufacturer);
        //EDGE-81077 start
        String offerId = searchFields.get('OfferId') != null ? searchFields.get('OfferId') : '';
        String deviceTypeString= searchFields.get('deviceTypeString') != null ? searchFields.get('deviceTypeString') : '';//EDGE-113391  deviceTypeString  added 
        system.debug(LoggingLevel.INFO, 'CS_TypeFromPriceItem.offerId = ' + offerId + deviceTypeString);
        //EDGE-81077 end
        String searchQuery;
        //Added by Aman Soni as a part of EDGE-148667 || Start
        Model_PriceItem mdPI = new Model_PriceItem();
        searchQuery = mdPI.getModel(searchValue, offerId, selectedManufacturer, deviceTypeString);
        //Added by Aman Soni as a part of EDGE-148667 || End  
        System.debug('PriceItemModelLookupCustom searchQuery: ' + searchQuery);
        List<cspmb__Price_Item__c> CommercialProductsList = Database.query(searchQuery);
        if(String.isNotBlank(searchQuery))
            CommercialProductsList =Database.query(searchQuery);
        System.debug('CommercialProductsList: ' + CommercialProductsList);
        List<cspmb__Price_Item__c> distinctModelList = getUniqueListByField(CommercialProductsList, 'Model__c');
        System.debug('PriceItemModelLookupCustom distinctModelList: ' + distinctModelList);
        return distinctModelList;
    }

    @TestVisible
    private List<cspmb__Price_Item__c> getUniqueListByField(List<cspmb__Price_Item__c> pis, String fieldName){
        //List<cspmb__Price_Item__c> uItams = new List<cspmb__Price_Item__c>();
        System.debug('PriceItemModelLookupCustom pis: ' + pis);
        System.debug('PriceItemModelLookupCustom fieldName: ' + fieldName);
        Map<String, cspmb__Price_Item__c> itemMap =  new Map<String, cspmb__Price_Item__c>();
        for(cspmb__Price_Item__c item : pis) {
            if(fieldName == 'Model__c' && !itemMap.containsKey(item.Model__c)) {
                itemMap.put(item.Model__c, item);
            }
        }
        System.debug('PriceItemModelLookupCustom itemMap: ' + itemMap);
        return itemMap.values();
    }
}