/*******************************************************************
@Author : Monali Mukherjee
@Description : Lookup Custom class to fetch the APN and Add On based on Account Id and Select Plan in Data Custom in Enterprise Mobility Plan
@Release : Sprint 21.07 - DPG-5295

 S.No. Date User Story Owner Description
1 19-05-2021 DPG-5295 Monali M APN lookup
*******************************************************************/

global with sharing class AdaptiveMobilityDataCustomAPNLookup extends cscfga.ALookupSearch {
public override String getRequiredAttributes()
{
return '["AccountID","Select Plan"]';
}

 public override Object[] doLookupSearch(Map<String, String> searchFields,String productDefinitionId, Id[] excludeIds, Integer pageOffset, Integer pageLimit)
{

 String searchValue = '';
if (searchFields.containsKey('searchValue') && searchFields.get('searchValue') != NULL && searchFields.get('searchValue') != '') {
searchValue = '%' + searchFields.get('searchValue') + '%';
}
String accountid = (searchFields.containsKey('AccountID') && searchFields.get('AccountID') != NULL)? searchFields.get('AccountID'):'';
String selectplan = (searchFields.containsKey('Select Plan') && searchFields.get('Select Plan') != NULL)? searchFields.get('Select Plan'):'';

 System.debug('AdaptiveMobilityDataCustomAPNLookup searchValue2: ' + searchValue);
system.debug('accountid**' +accountid + ' selectplan**' +selectplan);
 String searchQuery;
 searchQuery=   'Select cspmb__add_on_price_item__r.ProdSpecId__c,AddOn_Name__c,cspmb__Add_On_Price_Item__r.external_id__c ,cspmb__add_on_price_item__r.BillingSpecId__c,cspmb__Add_On_Price_Item__r.Message_Bank__c,Check_todays_date__c,cspmb__add_on_price_item__r.Charge_Id__c, cspmb__add_on_price_item__r.Offer_Id__c,cspmb__add_on_price_item__r.ocsProdID__c,cspmb__add_on_price_item__r.addOn_Name__c,isDefault__c,Id,isChargeable__c,AddOnName__c,cspmb__add_on_price_item__r.cspmb__Add_On_Price_Item_Code__c,cspmb__add_on_price_item__r.dataName__c,cspmb__One_Off_Charge__c,name,cspmb__Add_On_Price_Item__r.name,cspmb__add_on_price_item__r.cspmb__one_off_charge__c,cspmb__Recurring_Charge__c,cspmb__add_on_price_item__r.cspmb__recurring_charge__c,cspmb__price_item__c,cspmb__add_on_price_item__c,cspmb__default_quantity__c,cspmb__group__c,cspmb__min__c,cspmb__max__c,cspmb__Overrides_Add_On_Charges__c from cspmb__Price_Item_Add_On_Price_Item_Association__c WHERE cspmb__Price_Item__c = :selectplan AND Check_todays_date__c=true';

System.debug('PriceItemManufacturerLookupCustom searchQuery: ' + searchQuery);
List<cspmb__Price_Item_Add_On_Price_Item_Association__c> addOnAssocList = Database.query(searchQuery);
   system.debug('addOnAssocList**' +addOnAssocList);
    Set<String> apnName = new Set<String>();
  
 List<cspmb__Price_Item_Add_On_Price_Item_Association__c> finalListForAddOn = new List<cspmb__Price_Item_Add_On_Price_Item_Association__c>();
 List<APN__c> apnNameList=new List<APN__c>();

    apnNameList = [Select Name from APN__c where Status__c=true and Customer__c=:accountid];
   system.debug('apnNameList**' +apnNameList);
    for(APN__c apnRecName : apnNameList)
    {
       apnName.add(apnRecName.Name);
    }
    system.debug('apnName**' +apnName);
    for(cspmb__Price_Item_Add_On_Price_Item_Association__c addOnPriceItem :addOnAssocList ){
        if(apnName.contains(addOnPriceItem.AddOnName__c))
            finalListForAddOn.add(addOnPriceItem);
        
    }
    system.debug('finalListForAddOn&&' +finalListForAddOn);
    
    return finalListForAddOn;
    
}
    
}