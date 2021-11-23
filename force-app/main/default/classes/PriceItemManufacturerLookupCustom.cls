/***************************************************************************************************************************************
Class Name : PriceItemManufacturerLookupCustom
Test Class : PriceItemManufacturerLookupCustomTest
===============================================================================================================================
Change.No.    Developer Name          Date     Story        Description
1.            Ankit Goswami     30/8/2019      EDGE-112367  PPHH - Class for Device Type
2.            Aman Soni         15/10/2019     EDGE-112367  correction in Device_Enrolment__c field API
3.            Hitesh Gandhi     30/12/2019     EDGE-126960  added for defect fix.
4.            Gnana             30/04/2020     EDGE-140968  Added Charge id in SOQL query
5.            Aman Soni         23/06/2020     EDGE-148667  Added Device_Care__c field in SOQL Query and updated version setting to 48.0
*****************************************************************************************************************************************/

global with sharing class PriceItemManufacturerLookupCustom extends cscfga.ALookupSearch {
   
    public override String getRequiredAttributes()
    { 
        return '["OfferId,deviceTypeString"]';//EDGE-112367 added OfferID
    }

    public override Object[] doLookupSearch(Map<String, String> searchFields,String productDefinitionId, Id[] excludeIds, Integer pageOffset, Integer pageLimit)
    {
        System.debug('PriceItemManufacturerLookupCustom searchFields: ' + searchFields);
        System.debug('PriceItemManufacturerLookupCustom searchValue1: ' + searchFields.get('searchValue'));
        //String searchValue = ApexPages.currentPage().getParameters().get('searchValue');
        String searchValue = '';
        if (searchFields.containsKey('searchValue') && searchFields.get('searchValue') != NULL && searchFields.get('searchValue') != '') {
            searchValue = '%' + searchFields.get('searchValue') + '%';
        }
        System.debug('PriceItemManufacturerLookupCustom searchValue2: ' + searchValue);
        //EDGE-81077 start
        String offerId = searchFields.get('OfferId') != null ? searchFields.get('OfferId') : '';
        String deviceTypeString = searchFields.get('deviceTypeString') != null ? searchFields.get('deviceTypeString') : '';
        system.debug(LoggingLevel.INFO, 'CS_TypeFromPriceItem.offerId = ' + offerId);
        //EDGE-81077 end
        String searchQuery;
        //Added by Aman Soni as a part of EDGE-148667 || Start
        Model_PriceItem mdPI = new Model_PriceItem();
        searchQuery = mdPI.getManufacturer(searchValue, offerId, deviceTypeString);
        //Added by Aman Soni as a part of EDGE-148667 || End  
        System.debug('PriceItemManufacturerLookupCustom searchQuery: ' + searchQuery);
        List<cspmb__Price_Item__c> CommercialProductsList = new List<cspmb__Price_Item__c>();
        if(String.isNotBlank(searchQuery))
            CommercialProductsList =Database.query(searchQuery);

        List<cspmb__Price_Item__c> distinctManufacturerList = getUniqueListByField(CommercialProductsList, 'Manufacturer__c');
        return distinctManufacturerList;
    }

    @TestVisible
    private List<cspmb__Price_Item__c> getUniqueListByField(List<cspmb__Price_Item__c> pis, String fieldName){
        //List<cspmb__Price_Item__c> uItams = new List<cspmb__Price_Item__c>();
        Map<String, cspmb__Price_Item__c> itemMap =  new Map<String, cspmb__Price_Item__c>();
        for(cspmb__Price_Item__c item : pis) {
            if(fieldName == 'Manufacturer__c' && !itemMap.containsKey(item.Manufacturer__c)) {
                itemMap.put(item.Manufacturer__c, item);
            }
        }
        System.debug('-----------> NonModuleTypeLookupCustom itemMap.values()   ' + itemMap.values());
        return itemMap.values();
    }
}