/****************************************************************************************************************************************
Name : PriceItemPayTypeLookupCustom 
Test Class  : PriceItemPayTypeLookupCustomTest
=========================================================================================================================================
Sr.No.    Developer Name      Date            Story          Description
1.        Gnana              30/04/2020      EDGE-140968     Added Charge id in SOQL query
2.        Aman Soni          23/06/2020      EDGE-148667     Added Device_Care__c field in SOQL Query and updated version setting to 48.0
*****************************************************************************************************************************************/
global with sharing class PriceItemPayTypeLookupCustom  extends cscfga.ALookupSearch {

    public override String getRequiredAttributes()
    { 
        return '["ManufacturerString","ModelString","ColourString","PaymentTypeString","OfferId"]';
    }

    public override Object[] doLookupSearch(Map<String, String> searchFields,String productDefinitionId, Id[] excludeIds, Integer pageOffset, Integer pageLimit)
    {
        String manufacturerString;
        String modelString;
        String colourString;
        String paymentTypeString;
        String offerId;
        
        if(searchFields != null){
             manufacturerString = searchFields.get('ManufacturerString');
             modelString = searchFields.get('ModelString');
             colourString = searchFields.get('ColourString');
             paymentTypeString = searchFields.get('PaymentTypeString');
             offerId = searchFields.get('OfferId') != null ? searchFields.get('OfferId') : '';
        }
        system.debug(LoggingLevel.INFO, 'offerId = ' + offerId);

        String searchQuery;
        //Added by Aman Soni as a part of EDGE-148667 || Start
        Model_PriceItem mdPI = new Model_PriceItem();
        searchQuery = mdPI.getPayType(offerId, manufacturerString, modelString, colourString);
        //Added by Aman Soni as a part of EDGE-148667 || End 
        System.debug('PriceItemMDPaymentTypeLookup searchQuery: ' + searchQuery);
        List<cspmb__Price_Item__c> CommercialProductsList = new List<cspmb__Price_Item__c>();
        if(String.isNotBlank(searchQuery))
            CommercialProductsList =Database.query(searchQuery);
            System.debug('PriceItemMDPaymentTypeLookup CommercialProductsList : ' + CommercialProductsList );
        return CommercialProductsList;
    }
}