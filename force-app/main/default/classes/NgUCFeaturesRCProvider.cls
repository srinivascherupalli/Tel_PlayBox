/********************************************************
Class Name      :   NgUCFeaturesRCProvider
Test Class : NgUCFeaturesRCProviderTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Venkata Ramanan G     29/10/2019      EDGE-112869  Created for fetching the RC for NgUC features
2.            Hitesh Gandhi         09/01/2020      EDGE-129989  Removed UOM from query
3.            Hitesh Gandhi         20/01/2020      EDGE-130739  Changed Billing description
4.            Hitesh Gandhi         13/02/2020      EDGE-135705  Added Charge Id
********************************************************************/

global with sharing class NgUCFeaturesRCProvider implements cssmgnt.RemoteActionDataProvider{

 //String offerId;
//static Map<String,String> priceitemfiltermap = new Map<String,String>();

static string offerId,attrname,UOM,billingdesc,RCattrname,chargeId;
static integer quantity;
 static List<cspmb__price_item__c> priceItemList = new List<cspmb__price_item__c>();
 static Map<String,Map<String,String>> priceitemfiltermap = new Map<String,Map<String,String>>();


  /* Method to fetch all the required data for population of Rate Card. 
  Gets the input map & fetches all the PCs associated to the Basket & solution.
  Fetches all CustomRateCard__mdt based on the Offer ID & fetches the associated NCS(Non-commercial Schema).
  Fetches the details of the NCS based on the above result.
  Return param is null since its invoked from the Solution JS & it doesnt need to return any data to front end. 
  */
@RemoteAction
    global static Map<String,Object> getData(Map<String,Object> inputMap) {
    
    priceitemfiltermap.put('UCUserQuantity',new Map<String,String>{'Unit_Of_Measure__c' => 'each','Billing_Description__c' => 'Hosted User','RCAttributeName' => 'TotalRecurringChargeforUser','Charge_Id__c' => 'DMCAT_RecurringCharge_000813'});//EDGE-135705
priceitemfiltermap.put('HuntGroupQuantity',new Map<String,String>{'Unit_Of_Measure__c' => 'per Hunt Group','Billing_Description__c' => 'Group feature - hunt group','RCAttributeName' => 'TotalRecurringChargeforHuntGroup','Charge_Id__c' => 'DMCAT_RecurringCharge_000811'}); //EDGE-130739,EDGE-135705
priceitemfiltermap.put('AutoAttendantQuantity',new Map<String,String>{'Unit_Of_Measure__c' => 'per Auto Attendant','Billing_Description__c' => 'Group feature - auto attendant','RCAttributeName' => 'TotalRecurringChargeforAutoAttendant','Charge_Id__c' => 'DMCAT_RecurringCharge_000810'});//EDGE-130739,EDGE-135705
priceitemfiltermap.put('MainBusinessNumberQuantity',new Map<String,String>{'Unit_Of_Measure__c' => 'per Main Business Number','Billing_Description__c' => 'Group feature - virtual business number','RCAttributeName' => 'TotalRecurringChargeforMainBusiness','Charge_Id__c' => 'DMCAT_RecurringCharge_000812'});//EDGE-130739,EDGE-135705
priceitemfiltermap.put('HostedUCQuantity',new Map<String,String>{'Unit_Of_Measure__c' => 'per Feature Pack','Billing_Description__c' => 'Hosted user add-on - cloud unified communications','RCAttributeName' => 'TotalRecurringChargeforHostedUC','Charge_Id__c' => 'DMCAT_RecurringCharge_000816'});//EDGE-130739,EDGE-135705

Map<String,String> UOMfiltermap = new Map<String,String>();
        Map<String, Object> returnMap = new Map<String, Object>(); 
       
      offerId = (inputMap.containsKey('Offer_Id__c') && inputMap.get('Offer_Id__c') != '')? (String)inputMap.get('Offer_Id__c'):'';
      attrname =  (inputMap.containsKey('Attribute_Name') && inputMap.get('Attribute_Name') != '')? (String)inputMap.get('Attribute_Name'):'';
      quantity = (inputMap.containsKey('quantity') && inputMap.get('quantity') != '')? Integer.valueof(inputMap.get('quantity')): 0 ;


UOMfiltermap = (priceitemfiltermap.size() >0 && priceitemfiltermap.containsKey(attrname)) ? priceitemfiltermap.get(attrname): null;

 if(!UOMfiltermap.isEmpty()){
      UOM = UOMfiltermap.get('Unit_Of_Measure__c');
     billingdesc = UOMfiltermap.get('Billing_Description__c');
     RCattrname = UOMfiltermap.get('RCAttributeName');
     chargeId = UOMfiltermap.get('Charge_Id__c');
 }
if(UOM != null && UOM != ''){
for( cspmb__Price_Item__c pi : [select id,rangeFrom__c, rangeTo__c, Billing_Description__c, Unit_Of_Measure__c,cspmb__Recurring_Charge__c,Charge_Id__c from cspmb__Price_Item__c where name like '%Next Gen%Voice' and Offer_Id__c = :offerId and Check_todays_date__c = true  order by rangeTo__c]){ //Hitesh EDGE-129989  Removed UOM from query
    if(billingdesc != '' && pi.Billing_Description__c != null && pi.Charge_Id__c == chargeId  && Integer.valueof(pi.rangeFrom__c) <= quantity && Integer.valueOf(pi.rangeTo__c) >= quantity) //EDGE-135705
                {
                    returnMap.put(RCattrname,pi);
                    
                }
}
}
        system.debug('returnMap----->'+returnMap);
return returnMap;
    }
    }