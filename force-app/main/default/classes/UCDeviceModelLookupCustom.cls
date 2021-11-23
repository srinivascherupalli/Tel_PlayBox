/*******************************************************************
   @Author : Venkata Ramanan G (CloudSense)
   @Description : Lookup Custom class to fetch the Device/Accessory Type & Model in Telstra Colloboration Solution
   @Release : Sprint 19.12 - EDGE - 93255

   S.No.  Date         User Story     Description
   1      23-09-2019   EDGE-108257    Added few fields in SOQL for NgUC MTS Build
   2      04-02-2020   EDGE-133963    Charge_Id__c added in SOQL query by Aman Soni for NGUC pricing
   3      05-02-2020   EDGE-139224     check todays date condition  in query
   2      04-02-2020   EDGE-140157    Charge_Id__c deploying as this field in query is missing in qa1
   5      21-4-2020    EDge-120919     shubhi added updated query added mode__c
   6      23-11-2020   EDGE-178210    Added External_Id__c by Aman Soni
   8      08-01-2021   EDGE-189340    Added cspmb__Master_Price_item__c by Mukta
*******************************************************************/

global with sharing class UCDeviceModelLookupCustom extends cscfga.ALookupSearch {
    //Tests for this class are in PriceItemLookupCustomTest class
    public override String getRequiredAttributes()
    {
        return '["OfferId","TypeName","ItemCode"]';
    }

    public override Object[] doLookupSearch(Map<String, String> searchFields,String productDefinitionId, Id[] excludeIds, Integer pageOffset, Integer pageLimit)
    {

        String searchValue = '';
        if (searchFields.containsKey('searchValue') && searchFields.get('searchValue') != NULL && searchFields.get('searchValue') != '') {
            searchValue = '%' + searchFields.get('searchValue') + '%';
        }
        String offerid = (searchFields.containsKey('OfferId') && searchFields.get('OfferId') != NULL)? searchFields.get('OfferId'):'';
        String DeviceType = (searchFields.containsKey('TypeName') && searchFields.get('TypeName') != NULL)? searchFields.get('TypeName'):'';
        String itemcode = (searchFields.containsKey('ItemCode') && searchFields.get('ItemCode') != NULL)? searchFields.get('ItemCode'):'';

        System.debug('PriceItemManufacturerLookupCustom searchValue2: ' + searchValue);

        String searchQuery;
        String mapkey = 'Type__c';
        //if (String.isEmpty(searchValue) && !String.isEmpty(DeviceType)) {
        // //Edge120919 added Mode__c in below query
        //AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c in below query
        searchQuery = 'SELECT id,Type__c, Name, Manufacturer__c, Model__c, Colour__c, cspmb__Contract_Term__c,Charge_Id__c, ChargeType__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c, cspmb__Billing_Frequency__c, SKU__c, taxTreatment__c, Unit_Of_Measure__c, Currency__c, BillingSpecId__c, Billing_Description__c, BillInAdvance__c, Prorate__c, frequency__c, Contract_Type__c, billingSubType__c, ProdSpecId__c,External_Id__c, Offer_Id__c,cspmb__Price_Item_Code__c,Commercial_Product_Code__c,rangeFrom__c,rangeTo__c,Plan__c,Check_todays_date__c,Mode__c,cspmb__Master_Price_item__c FROM cspmb__Price_Item__c WHERE Offer_Id__c = :offerId and Model__c != null AND Check_todays_date__c=true '; // added by shubhi Check_todays_date__c for EDGE-139224 || Added External_Id__c by Aman Soni for EDGE-178210 i// EDGE-189340 Added cspmb__Master_Price_item__c by Mukta
        if (!String.isEmpty(DeviceType)) {
            searchQuery += ' and Type__c = :DeviceType';
            mapkey = 'Model__c';
        }
        if (!String.isEmpty(itemcode)) {
            searchQuery += ' and Name = :itemcode';
        }
        if (!String.isEmpty(searchValue)) {
            if (!String.isEmpty(DeviceType)) {
                searchQuery += ' and Model__c LIKE :searchValue';
            }
            else {
                searchQuery += ' and Type__c LIKE :searchValue';
                //mapkey = ;
            }
        }
        System.debug('PriceItemManufacturerLookupCustom searchQuery: ' + searchQuery);
        List<cspmb__Price_Item__c> CommercialProductsList = Database.query(searchQuery);

        List<cspmb__Price_Item__c> distinctManufacturerList = getUniqueListByField(CommercialProductsList, mapkey);
        return distinctManufacturerList;
    }

    public List<cspmb__Price_Item__c> getUniqueListByField(List<cspmb__Price_Item__c> pis, String fieldName){
        //List<cspmb__Price_Item__c> uItams = new List<cspmb__Price_Item__c>();
        Map<String, cspmb__Price_Item__c> itemMap =  new Map<String, cspmb__Price_Item__c>();
        for (cspmb__Price_Item__c item : pis) {
            if (fieldName == 'Model__c' && !itemMap.containsKey(item.Model__c)) {
                itemMap.put(item.Model__c, item);
            }
            else if (fieldName == 'Type__c' && !itemMap.containsKey(item.Type__c)) {
                itemMap.put(item.Type__c, item);
            }
        }
        System.debug('-----------> NonModuleTypeLookupCustom itemMap.values()   ' + itemMap.values());
        return itemMap.values();
    }
}