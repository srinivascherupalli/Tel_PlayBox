/*********************************************************************************************************************************
 *Class Name      :   ZoneLookupCustom

Test Class : CS_TypeFromPriceItemTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Laxmi  Rahate       03/09/2019        EDGE-96379-> TID - Dispaly Unique Zones
 *********************************************************************************************************************************
*/

global with sharing class ZoneLookupCustom extends cscfga.ALookupSearch {
    //Tests for this class are in Zone  class PriceItemLookupCustomTest
    public override String getRequiredAttributes()
    { 
        return '["OfferId"]'; 
    }

    public override Object[] doLookupSearch(Map<String, String> searchFields,String productDefinitionId, Id[] excludeIds, Integer pageOffset, Integer pageLimit)
    {
   
        String offerId = searchFields.get('OfferId') != null ? searchFields.get('OfferId') : '';
        //String prodSpecId = searchFields.get('prodSpecID') != null ? searchFields.get('ProdSpecId') : '';
       // String offerTypeString = searchFields.get('OfferTypeString') != null ? searchFields.get('OfferTypeString') : '';
        system.debug(LoggingLevel.INFO, 'ZoneLookupCustom.offerId = ' + offerId );
        String searchQuery;
        
        searchQuery = 'select Id, Name, Zone__c, BandwidthWeight__c,IP_Access_Configuration__c , cspmb__Recurring_Charge__c, Bandwidth__c  from cspmb__Price_Item__c where Zone__c !=null '
        + ' and Offer_Id__c = : offerId ORDER BY Zone__c';

            
        System.debug('ZoneLookupCustom searchQuery: ' + searchQuery);
        List<cspmb__Price_Item__c> CommercialProductsList = Database.query(searchQuery);

        List<cspmb__Price_Item__c> distinctZoneList = getUniqueListByField(CommercialProductsList, 'Zone__c');
        return distinctZoneList;
    }

    @TestVisible
    private List<cspmb__Price_Item__c> getUniqueListByField(List<cspmb__Price_Item__c> pis, String fieldName){
        //List<cspmb__Price_Item__c> uItams = new List<cspmb__Price_Item__c>();
        Map<String, cspmb__Price_Item__c> itemMap =  new Map<String, cspmb__Price_Item__c>();
        for(cspmb__Price_Item__c item : pis) {
            if(fieldName == 'zone__c' && !itemMap.containsKey(item.Zone__c)) {
               System.debug( 'Added value in Map ---' + item.Zone__c ); 
                itemMap.put(item.zone__c, item);
            }
        }
        System.debug('-----------> NonModuleTypeLookupCustom itemMap.values()   ' + itemMap.values());
        return itemMap.values();
    }
}