/*********************************************************************************************************************************
 *Class Name      :   IPAccessConfigurationCustom

Test Class : CS_TypeFromPriceItemTest
=======================================================================  ========================================================
Change.No.    Developer Name          Date          Story Description
1.            Aditya Pareek          05/09/2019        EDGE-96379-> TID - Dispaly Unique IP Access Configuration
1.            Laxmi Rahate           15/12/2019        EDGE-98299-> TID - Changed ATtribute Name from Zone Shadow to SelectZone
2.            Venkata Ramanan G      16/12/2019 .      EDGE- 123125 -> Added One off charge field to the query 
 *********************************************************************************************************************************
*/

global with sharing class IPAccessConfigurationCustom extends cscfga.ALookupSearch {
    //Tests for this class are in IpAccess  class
    public override String getRequiredAttributes()
    { 
        return '["OfferId","SelectZone"]'; 
    }

    public override Object[] doLookupSearch(Map<String, String> searchFields,String productDefinitionId, Id[] excludeIds, Integer pageOffset, Integer pageLimit)
    {
   
        String offerId = searchFields.get('OfferId') != null ? searchFields.get('OfferId') : '';
        String zone = searchFields.get('SelectZone') != null ? searchFields.get('SelectZone') : '';
       // String offerTypeString = searchFields.get('OfferTypeString') != null ? searchFields.get('OfferTypeString') : '';
        system.debug(LoggingLevel.INFO, 'IPAccessConfigurationCustom.offerId = ' + offerId );
        String searchQuery;
        if(!(String.isBlank(offerId) && String.isBlank(zone))){
        searchQuery = 'select Id, Name, zone__c, BandwidthWeight__c,IP_Access_Configuration__c , cspmb__Recurring_Charge__c, Bandwidth__c,cspmb__One_Off_Charge__c  from cspmb__Price_Item__c where IP_Access_Configuration__c !=null '
        + ' and Offer_Id__c = : OfferId and Zone__c = :zone ORDER BY IP_Access_Configuration__c';

            }
        System.debug('IPAccessConfigurationCustom searchQuery: ' + searchQuery);
        if (searchQuery != '') {
        List<cspmb__Price_Item__c> CommercialProductsList = Database.query(searchQuery);

        List<cspmb__Price_Item__c> distinctIPAccessList = getUniqueListByField(CommercialProductsList, 'IP_Access_Configuration__c');
        return distinctIPAccessList;
        }
        else 
            return null;
    }

    @TestVisible
    private List<cspmb__Price_Item__c> getUniqueListByField(List<cspmb__Price_Item__c> pis, String fieldName){
        //List<cspmb__Price_Item__c> uItams = new List<cspmb__Price_Item__c>();
        Map<String, cspmb__Price_Item__c> itemMap =  new Map<String, cspmb__Price_Item__c>();
        for(cspmb__Price_Item__c item : pis) {
            if(fieldName == 'IP_Access_Configuration__c' && !itemMap.containsKey(item.IP_Access_Configuration__c)) {
               System.debug( 'Added value in Map ---' + item.IP_Access_Configuration__c ); 
                itemMap.put(item.IP_Access_Configuration__c, item);
            }
        }
        System.debug('-----------> NonModuleTypeLookupCustom itemMap.values()   ' + itemMap.values());
        return itemMap.values();
    }
}