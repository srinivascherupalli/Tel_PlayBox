/*******************************************************************
   @Author : Krunal Taak / Ila Verma
   @Description : Lookup Custom class to fetch the Accessory Type & Model in MobileAccessory in Adaptive Mobility
   @Release : Sprint 20.16 - DPG-3506

   S.No.  Date         User Story   Owner      Description
   1      03-12-2020   DPG-3506     Krunal T.  Repliacted from Apex class "UCDeviceModelLookupCustom"


   2	  05-02-2021   DPG-4071		Mahima G.  Added Device_Care__c in the queries. for calculating DeviceEligibilityCare Attribute


*******************************************************************/

global with sharing class AdaptiveMobilityAccessoryLookup extends cscfga.ALookupSearch {
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

    searchQuery = 'SELECT id,Type__c,Plan_Type__c, Name, Manufacturer__c, Offer_Type__c, BYO__c, Offer__c, cspmb__Is_Active__c, Model__c, Colour__c, cspmb__Contract_Term__c,Charge_Id__c, ChargeType__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c, cspmb__Billing_Frequency__c, SKU__c, taxTreatment__c, Unit_Of_Measure__c, Currency__c, BillingSpecId__c, Billing_Description__c, BillInAdvance__c, Prorate__c, frequency__c, Contract_Type__c, billingSubType__c, ProdSpecId__c, Offer_Id__c,cspmb__Price_Item_Code__c,Commercial_Product_Code__c,rangeFrom__c,rangeTo__c,Plan__c,Check_todays_date__c,Mode__c, Device_Care__c,External_Id__c FROM cspmb__Price_Item__c WHERE Offer_Id__c = :offerId and Model__c != null AND Check_todays_date__c=true ';     // added by shubhi Check_todays_date__c for EDGE-139224

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