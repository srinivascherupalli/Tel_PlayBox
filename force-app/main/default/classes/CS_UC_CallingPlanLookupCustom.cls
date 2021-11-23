/*******************************************************************
@Author : Venkata Ramanan G (CloudSense)
@Description : Lookup Custom class to fetch the Calling Plan in Telstra Colloboration Solution- MTS Version
@Release : Sprint 19.13 - EDGE - 108257
@Created Date :   23-Sept-2019
@modified : Shubhi EDge-120919 21-4-2020 updated query added mode__c
S.No.  Date         User Story     Description
1      23-11-2020   EDGE-178210    Added External_Id__c by Aman Soni
2      07-01-2021   EDGE-189340    Added cspmb__Master_Price_item__c by Mukta
******************************************************************/

global with sharing class CS_UC_CallingPlanLookupCustom extends cscfga.ALookupSearch {
    //Tests for this class are in PriceItemLookupCustomTest class
    public override String getRequiredAttributes()
    { 
        return '["OfferId","Mode","ModeString"]'; //EDge-120919
    }

    public override Object[] doLookupSearch(Map<String, String> searchFields,String productDefinitionId, Id[] excludeIds, Integer pageOffset, Integer pageLimit)
    {
       
        String searchValue = '';
        if (searchFields.containsKey('searchValue') && searchFields.get('searchValue') != NULL && searchFields.get('searchValue') != '') {
            searchValue = '%' + searchFields.get('searchValue') + '%';
        }
        String offerid = (searchFields.containsKey('OfferId') && searchFields.get('OfferId') != NULL)? searchFields.get('OfferId'):'';
        
        //added by shubhi for EDge-120919 start
        String Mode = (searchFields.containsKey('Mode') && searchFields.get('Mode') != NULL)? searchFields.get('Mode'):'';
        String ModeString = (searchFields.containsKey('ModeString') && searchFields.get('ModeString') != NULL)? searchFields.get('ModeString'):'';
        System.debug('PriceItemManufacturerLookupCustom searchValue2: ' + searchValue);
        String mapkey ='Mode__c'; 
        //AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
        String searchQuery = 'SELECT id,Type__c,Manufacturer__c, Model__c, Colour__c, Name,rangeFrom__c,cspmb__Contract_Term__c,rangeTo__c, ChargeType__c, cspmb__One_Off_Charge__c, Plan__c, cspmb__Recurring_Charge__c, cspmb__Billing_Frequency__c, SKU__c, taxTreatment__c, Unit_Of_Measure__c, Currency__c, BillingSpecId__c, Billing_Description__c, BillInAdvance__c, Prorate__c, frequency__c, Contract_Type__c, billingSubType__c, ProdSpecId__c,External_Id__c, Offer_Id__c,cspmb__Price_Item_Code__c,Commercial_Product_Code__c,cspmb__Price_Item_Description__c,Charge_Id__c,Check_todays_date__c,Mode__c,cspmb__Master_Price_item__c FROM cspmb__Price_Item__c WHERE Offer_Id__c = :offerId and Plan__c != null AND Check_todays_date__c=true';  // added Charge_Id__c to lookup for EDGE-121376 // added by shubhi Check_todays_date__c for EDGE-139224 //Edge120919 added Mode__c || Added External_Id__c for EDGE-178210 by Aman Soni// EDGE-189340 Added cspmb__Master_Price_item__c by Mukta
        if(!String.isEmpty(ModeString)){
             searchQuery += ' and Mode__c = :ModeString' ;
             mapkey = 'Plan__c';
        }
        
         if(!String.isEmpty(searchValue)){
            if(String.isEmpty(ModeString)){
                searchQuery += ' and Mode__c LIKE :searchValue';
            }   
            else{
                searchQuery += ' and Plan__c LIKE :searchValue';
            }
         }
        //added by shubhi for EDge-120919 end
         //System.debug('PriceItemManufacturerLookupCustom searchQuery: ' + searchQuery);
         List<cspmb__Price_Item__c> CommercialProductsList = Database.query(searchQuery);
        List<cspmb__Price_Item__c> distinctplanlst = getUniqueListByField(CommercialProductsList, mapkey);////added by shubhi for EDge-120919 
        return distinctplanlst;
    }

    //@TestVisible
    //added by shubhi for EDge-120919 upadted method added mode__c condition
    private List<cspmb__Price_Item__c> getUniqueListByField(List<cspmb__Price_Item__c> pis, String fieldName){
        //List<cspmb__Price_Item__c> uItams = new List<cspmb__Price_Item__c>();
        Map<String, cspmb__Price_Item__c> itemMap =  new Map<String, cspmb__Price_Item__c>();
        for(cspmb__Price_Item__c item : pis) {
            //add if block for EDge-120919
             if(fieldName == 'Mode__c' && !itemMap.containsKey(item.Mode__c)) {
                itemMap.put(item.Mode__c, item);
            }
            else if(fieldName == 'Plan__c' && !itemMap.containsKey(item.Plan__c)) {
                itemMap.put(item.Plan__c, item);
            }
            
        }
        //System.debug('-----------> CS_US_CallingPlanLookupCustom itemMap.values()   ' + itemMap.values());
        return itemMap.values();
    }
}