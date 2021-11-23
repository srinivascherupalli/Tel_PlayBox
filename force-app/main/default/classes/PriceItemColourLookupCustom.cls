/******************************************************************************************************************************************
Class Name : PriceItemColourLookupCustom
Test Class : PriceItemLookupCustomTest
===============================================================================================================================
Change.No.    Developer Name         Date          Story        Description
1.            Ankit Goswami         30/8/2019      EDGE-112367  PPHH - added DeviceEnrollment__c field in Query for Device Type
2.            Aman Soni             15/10/2019     EDGE-112367  correction in Device_Enrolment__c field
3.            Ankit Goswami         29/10/2019     EDGE-113391  Check_todays_date__c added 
4.            Gnana                 30/04/2020     EDGE-140968  Added Charge id in SOQL query
5.            Aman Soni             23/06/2020     EDGE-148667  Added Device_Care__c field in SOQL Query and updated version setting to 48.0
********************************************************************************************************************************************/

global with sharing class PriceItemColourLookupCustom  extends cscfga.ALookupSearch {
   
    public override String getRequiredAttributes()
    { 
        return '["MobileHandsetManufacturer","MobileHandsetModel","OfferId"]';//EDGE-81077 added OfferID]';
    }

    public override Object[] doLookupSearch(Map<String, String> searchFields,String productDefinitionId, Id[] excludeIds, Integer pageOffset, Integer pageLimit)
    {
        System.debug('PriceItemColourLookupCustom searchFields: ' + searchFields);
        //String searchValue = ApexPages.currentPage().getParameters().get('searchValue');
        String searchValue = '';
        
        if (searchFields.containsKey('searchValue') && searchFields.get('searchValue') != NULL && searchFields.get('searchValue') != '') {
            searchValue = '%' + searchFields.get('searchValue') + '%';
        }
        System.debug('PriceItemColourLookupCustom searchValue: ' + searchValue);
        System.debug('PriceItemColourLookupCustom searchFields: ' + searchFields);
        Id chosenManufacturerPriceItemId = Id.valueOf(searchFields.get('MobileHandsetManufacturer'));
        cspmb__Price_Item__c chosenManufacturerPriceItem = [SELECT Manufacturer__c FROM cspmb__Price_Item__c WHERE Id =: chosenManufacturerPriceItemId];
        String selectedManufacturer = chosenManufacturerPriceItem.Manufacturer__c;
        Id chosenModelPriceItemId = Id.valueOf(searchFields.get('MobileHandsetModel'));
        cspmb__Price_Item__c chosenModelPriceItem = [SELECT Model__c FROM cspmb__Price_Item__c WHERE Id =: chosenModelPriceItemId];
        String selectedModel = chosenModelPriceItem.Model__c;
        //EDGE-81077 start
        String offerId = searchFields.get('OfferId') != null ? searchFields.get('OfferId') : '';
        system.debug(LoggingLevel.INFO, 'CS_TypeFromPriceItem.offerId = ' + offerId);
        //EDGE-81077 end
        String searchQuery;
        //Added by Aman Soni as a part of EDGE-148667 || Start
        Model_PriceItem mdPI = new Model_PriceItem();
        searchQuery = mdPI.getColour(searchValue, offerId, selectedManufacturer, selectedModel);
        //Added by Aman Soni as a part of EDGE-148667 || End  
        System.debug('PriceItemColourLookupCustom searchQuery: ' + searchQuery);
        List<cspmb__Price_Item__c> CommercialProductsList = new  List<cspmb__Price_Item__c>();
        if(String.isNotBlank(searchQuery))
             CommercialProductsList =Database.query(searchQuery);
             
        List<cspmb__Price_Item__c> distinctColourList = getUniqueListByField(CommercialProductsList, 'Colour__c');
        System.debug('PriceItemColourLookupCustom distinctColourList: ' + distinctColourList);
        return distinctColourList;
    }

    @TestVisible
    private List<cspmb__Price_Item__c> getUniqueListByField(List<cspmb__Price_Item__c> pis, String fieldName){
        //List<cspmb__Price_Item__c> uItams = new List<cspmb__Price_Item__c>();
        System.debug('PriceItemColourLookupCustom pis: ' + pis);
        System.debug('PriceItemColourLookupCustom fieldName: ' + fieldName);
        Map<String, cspmb__Price_Item__c> itemMap =  new Map<String, cspmb__Price_Item__c>();
        for(cspmb__Price_Item__c item : pis) {
            if(fieldName == 'Colour__c' && !itemMap.containsKey(item.Colour__c)) {
                itemMap.put(item.Colour__c, item);
            }
        }
        System.debug('PriceItemColourLookupCustom itemMap: ' + itemMap);
        return itemMap.values();
    }
}