/*********************************************************************************************************************************
 *Class Name      :   TechnicalSupportLookupCustom

Test Class : TechnicalSupportLookupCustTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Laxmi  Rahate       03/09/2019        EDGE-116138-> EMS - Dispaly Unique TechnicalSupport
2.            Shubhi       		  31/10/2019        EDGE-117563
 *********************************************************************************************************************************
*/

global with sharing class TechnicalSupportLookupCustom extends cscfga.ALookupSearch {
    //Tests for this class are in Technical Support  class PriceItemLookupCuastomTest
    public override String getRequiredAttributes()
    { 
        return '["OfferId","ProductSpecId"]'; 
    }

    public override Object[] doLookupSearch(Map<String, String> searchFields,String productDefinitionId, Id[] excludeIds, Integer pageOffset, Integer pageLimit)
    {
   
        String offerId = searchFields.get('OfferId') != null ? searchFields.get('OfferId') : '';

        String ProductSpecId = searchFields.get('ProductSpecId') != null ? searchFields.get('ProductSpecId') : '';
        //String prodSpecId = searchFields.get('prodSpecID') != null ? searchFields.get('ProdSpecId') : '';
       // String offerTypeString = searchFields.get('OfferTypeString') != null ? searchFields.get('OfferTypeString') : '';
        system.debug(LoggingLevel.INFO, 'TechnicalSupport.offerId = ' + offerId );
        //offerId = 'DMCAT_Offer_000854';
        String searchQuery;

        //Updated query for 117563
        searchQuery = 'SELECT Id,Name,cspmb__Recurring_Charge__c,Billing_Description__c,cspmb__One_Off_Charge__c,Check_todays_date__c,currency__c,cspmb__Contract_Term__c,Technical_Support__c,Feature_Level__c,Offer_Id__c,ProdSpecId__c FROM cspmb__Price_Item__c'
        + ' WHERE Offer_Id__c = : offerId AND Check_todays_date__c = true AND ProdSpecId__c = :ProductSpecId ORDER BY Technical_Support__c ';

            
        System.debug('TechnicalSupport searchQuery: ' + searchQuery);
        List<cspmb__Price_Item__c> CommercialProductsList = Database.query(searchQuery);

        List<cspmb__Price_Item__c> distrinctTechnicalSupp = getUniqueListByField(CommercialProductsList, 'Technical_Support__c');
        return distrinctTechnicalSupp;
    }

    @TestVisible
    private List<cspmb__Price_Item__c> getUniqueListByField(List<cspmb__Price_Item__c> pis, String fieldName){
        //List<cspmb__Price_Item__c> uItams = new List<cspmb__Price_Item__c>();
        Map<String, cspmb__Price_Item__c> itemMap =  new Map<String, cspmb__Price_Item__c>();
        for(cspmb__Price_Item__c item : pis) {
            if(fieldName == 'Technical_Support__c' && !itemMap.containsKey(item.Technical_Support__c)) {
               System.debug( 'Added value in Map ---' + item.Technical_Support__c ); 
                itemMap.put(item.Technical_Support__c, item);
            }
        }
        System.debug('-----------> NonModuleTypeLookupCustom itemMap.values()   ' + itemMap.values());
        return itemMap.values();
    }
}