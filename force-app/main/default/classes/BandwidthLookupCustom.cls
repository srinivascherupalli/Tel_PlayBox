/*********************************************************************************************************************************
 *Class Name      :   BandwidthLookupCustom

Test Class : BandwidthLookupCustomTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Laxmi  Rahate       03/09/2019        EDGE-96379-> TID - Dispaly Unique Bandwidth Values
2.            Laxmi Rahate        04/12/2019        EDGE-98299-> Charge Zone 
2.            Venkata Ramanan G      16/12/2019 .      EDGE- 123125 -> Added One off charge field to the query 
 *********************************************************************************************************************************
*/

global with sharing class BandwidthLookupCustom extends cscfga.ALookupSearch {
    //Tests for this class are in Zone  class PriceItemLookupCustomTest
    public override String getRequiredAttributes()
    { 
        return '["OfferId", "SelectZone" ]'; // Added by Laxmi as a part of EDGE-98299
    }

    public override Object[] doLookupSearch(Map<String, String> searchFields,String productDefinitionId, Id[] excludeIds, Integer pageOffset, Integer pageLimit)
    {
   
        String offerId = searchFields.get('OfferId') != null ? searchFields.get('OfferId') : '';
        String zone = searchFields.get('SelectZone') != null ? searchFields.get('SelectZone') : '';// Added by Laxmi as a part of EDGE-98299

        //String prodSpecId = searchFields.get('prodSpecID') != null ? searchFields.get('ProdSpecId') : '';
       // String offerTypeString = searchFields.get('OfferTypeString') != null ? searchFields.get('OfferTypeString') : '';
        system.debug(LoggingLevel.INFO, 'BandwidthLookupCustom.offerId = ' + offerId + 'zone - '+ zone);
        String searchQuery;
        
        searchQuery = 'select Id, Name, Zone__c, BandwidthWeight__c,IP_Access_Configuration__c , Bandwidth__c ,cspmb__Recurring_Charge__c, cspmb__One_Off_Charge__c from cspmb__Price_Item__c where Bandwidth__c !=null '
        + ' and Offer_Id__c =:offerId and Zone__c =:zone ORDER BY cspmb__Recurring_Charge__c ';
    
            
        System.debug('ZoneLookupCustom searchQuery: ' + searchQuery);
        List<cspmb__Price_Item__c> CommercialProductsList = Database.query(searchQuery);

        List<cspmb__Price_Item__c> distinctBandwidthList = getUniqueListByField(CommercialProductsList, 'Bandwidth__c');
       
        return distinctBandwidthList;
  
      
    }

    @TestVisible
    private List<cspmb__Price_Item__c> getUniqueListByField(List<cspmb__Price_Item__c> pis, String fieldName){
        //List<cspmb__Price_Item__c> uItams = new List<cspmb__Price_Item__c>();
        Map<String, cspmb__Price_Item__c> itemMap =  new Map<String, cspmb__Price_Item__c>();
        for(cspmb__Price_Item__c item : pis) {
            if(fieldName == 'Bandwidth__c' && !itemMap.containsKey(item.Bandwidth__c)) {
               //System.debug( 'Added value in Map ---' + item.Bandwidth__c ); 
                itemMap.put(item.Bandwidth__c, item);
            }
        }
        System.debug('-----------> NonModuleTypeLookupCustom itemMap.values()   ' + itemMap.values());
        return itemMap.values();
    }
}