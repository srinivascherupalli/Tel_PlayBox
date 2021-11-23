/*******************************************************************
@Author : Venkata Ramanan G (CloudSense)
@Description : Lookup Custom class/Remote action class to fetch the Vendor values in tenancy model
   @Description : Lookup Custom class/Remote action class to fetch the Vendor values in tenancy model
@Release : Sprint 19.14 - EDGE - 117274
* 1       04-11-2019      EDGE- 117274    Created for Tenancy Offer to fetch Vendor
* 2        15-10-2020    EDGE-169456         added Commercial_Product_Code__c as part of Pricing Service
*******************************************************************/
global with sharing class CSTenancyVendorlookup  extends cscfga.ALookupSearch implements cssmgnt.RemoteActionDataProvider {
    //Tests for this class are in PriceItemLookupCustomTest class
    public override String getRequiredAttributes()
    { 
        return '["OfferId"]';
    }
    @RemoteAction
    global static Map<String,Object> getData(Map<String,Object> searchFields) {
         String offerid = (searchFields != null && searchFields.containsKey('OfferId') && searchFields.get('OfferId') != NULL)? (String)searchFields.get('OfferId'):'';
         if(offerid != '' && !String.isBlank(offerid)){
         List<cspmb__Price_Item__c> pilst = fetchdata(offerid);
         Map<String,cspmb__Price_Item__c> pimap = new Map<String,cspmb__Price_Item__c>();
         if(pilst != null && !pilst.isEmpty() && pilst.size() == 1){
                pimap.put('vendor',pilst[0]);
            return pimap;
            }
            return null;
         }
            else
            return null;
    }
    public override Object[] doLookupSearch(Map<String, String> searchFields,String productDefinitionId, Id[] excludeIds, Integer pageOffset, Integer pageLimit)
    {
        String searchValue = '';
        if (searchFields != null && searchFields.containsKey('searchValue') && searchFields.get('searchValue') != NULL && searchFields.get('searchValue') != '') {
            searchValue = '%' + searchFields.get('searchValue') + '%';
        }
        String offerid = (searchFields != null && searchFields.containsKey('OfferId') && searchFields.get('OfferId') != NULL)? searchFields.get('OfferId'):'';
       /* String DeviceType = (searchFields.containsKey('TypeName') && searchFields.get('TypeName') != NULL)? searchFields.get('TypeName'):'';
        String itemcode = (searchFields.containsKey('ItemCode') && searchFields.get('ItemCode') != NULL)? searchFields.get('ItemCode'):'';
*/
        System.debug('PriceItemManufacturerLookupCustom searchValue2: ' + searchValue);
        if(offerid != '' && !String.isBlank(offerid)){
        List<cspmb__Price_Item__c> pilst = CSTenancyVendorlookup.fetchdata(offerid);
            return pilst;
       }
       return null;
}      
 public static List<cspmb__Price_Item__c> fetchdata(String offerId){
        String searchQuery;
  //      String mapkey ='Type__c'; 
        //if (String.isEmpty(searchValue) && !String.isEmpty(DeviceType)) {

        //EDGE-169456         added Commercial_Product_Code__c as part of Pricing Service
        searchQuery = 'SELECT id,Type__c, Name,Vendor__c, Manufacturer__c, Model__c, Colour__c, cspmb__Contract_Term__c, ChargeType__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c, cspmb__Billing_Frequency__c, SKU__c, taxTreatment__c, Unit_Of_Measure__c, Currency__c, BillingSpecId__c, Billing_Description__c, BillInAdvance__c, Prorate__c, frequency__c, Contract_Type__c, billingSubType__c, ProdSpecId__c, Offer_Id__c,cspmb__Price_Item_Code__c,Commercial_Product_Code__c,rangeFrom__c,rangeTo__c,Plan__c FROM cspmb__Price_Item__c WHERE Offer_Id__c = :offerId AND Check_todays_date__c = true';

        System.debug('PriceItemManufacturerLookupCustom searchQuery: ' + searchQuery);
        List<cspmb__Price_Item__c> CommercialProductsList = Database.query(searchQuery);
        List<cspmb__Price_Item__c> distinctManufacturerList = getUniqueListByField(CommercialProductsList, 'Vendor__c');
        return distinctManufacturerList;
//    }
}
    @TestVisible
    private static List<cspmb__Price_Item__c> getUniqueListByField(List<cspmb__Price_Item__c> pis, String fieldName){
        //List<cspmb__Price_Item__c> uItams = new List<cspmb__Price_Item__c>();
        Map<String, cspmb__Price_Item__c> itemMap =  new Map<String, cspmb__Price_Item__c>();
        for(cspmb__Price_Item__c item : pis) {
            if(fieldName == 'Vendor__c' && !itemMap.containsKey(item.Vendor__c)) {
                itemMap.put(item.Vendor__c, item);
            }
        }
        System.debug('-----------> NonModuleTypeLookupCustom itemMap.values()   ' + itemMap.values());
        return itemMap.values();
    }
}