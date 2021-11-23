/*************************************************************************************************
Name : Model_addonPriceItemAssociation
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.         Shubhi             09-Sept-2020        EDGE-160037 (new)
2.         Shubhi               06-10-2020      Edge-177601
3.         Shubhi             06-11-2020        EDGE-187013
===============================================================================================================================
***************************************************************************************************/

public with sharing class Model_addonPriceItemAssociation{
   
     /*  
     * Method Name : getAddonPriceItemAssociation
     * Owner : shubhi V
     * Jira : EDGE-160037
    */
    public static cspmb__Price_Item_Add_On_Price_Item_Association__c getAddonPriceItemAssociation(String addonName ,String chargeId, String offer, String planId){
        cspmb__Price_Item_Add_On_Price_Item_Association__c addonassoc=new cspmb__Price_Item_Add_On_Price_Item_Association__c();
        if(String.isNotBlank(addonName) && String.isNotBlank(chargeId) && String.isNotBlank(offer) && String.isNotBlank(planId))
           addonassoc=[Select id,cspmb__price_item__c,cspmb__add_on_price_item__c,cspmb__add_on_price_item__r.Offer_Id__c,
                  cspmb__add_on_price_item__r.Charge_Id__c,Check_todays_date__c,name,isChargeable__c,AddOn_Name__c,
                    cspmb__add_on_price_item__r.cspmb__recurring_charge__c,cspmb__recurring_charge__c,cspmb__one_off_charge__c,
                    cspmb__add_on_price_item__r.addOn_Name__c,cspmb__add_on_price_item__r.cspmb__one_off_charge__c,AddOnName__c//EDGE-187013
                    FROM cspmb__Price_Item_Add_On_Price_Item_Association__c WHERE cspmb__price_item__c=:planId
                         AND cspmb__add_on_price_item__r.Offer_Id__c=: offer 
                         AND cspmb__add_on_price_item__r.Charge_Id__c=: chargeId 
                         AND cspmb__add_on_price_item__r.addOn_Name__c=:addonName AND Check_todays_date__c=true limit 1]; //Edge-177601 updated query 
        return addonassoc;
        
    }
    /*  
     * Method Name : getAddonPriceItemAssociation_dataFeatures
     * Owner : shubhi V
     * Jira : EDGE-160037
    */
    public static Map<String,cspmb__Price_Item_Add_On_Price_Item_Association__c> getAddonPriceItemAssociationBulk(List<String> chargeId, String offer, String planId, List<string> addonName){
        Map<String,cspmb__Price_Item_Add_On_Price_Item_Association__c> addonassocMap=new Map<String,cspmb__Price_Item_Add_On_Price_Item_Association__c>();
        if(addonName!=null && !addonName.isEmpty()){
            for(cspmb__Price_Item_Add_On_Price_Item_Association__c addassoc:[Select id,cspmb__price_item__c,cspmb__add_on_price_item__c,cspmb__add_on_price_item__r.Offer_Id__c,
                  cspmb__add_on_price_item__r.Charge_Id__c,Check_todays_date__c,name,isChargeable__c,AddOn_Name__c,
                    cspmb__add_on_price_item__r.cspmb__recurring_charge__c,isDefault__c,cspmb__recurring_charge__c,cspmb__one_off_charge__c,
                    cspmb__add_on_price_item__r.addOn_Name__c,cspmb__add_on_price_item__r.cspmb__one_off_charge__c,AddOnName__c//EDGE-187013
                    FROM cspmb__Price_Item_Add_On_Price_Item_Association__c WHERE cspmb__price_item__c=:planId
                    AND cspmb__add_on_price_item__r.Offer_Id__c=: offer 
                    AND cspmb__add_on_price_item__r.Charge_Id__c IN: chargeId 
                    AND Check_todays_date__c=true]){ ////Edge-177601 updated query
                        addonassocMap.put(addassoc.cspmb__add_on_price_item__r.Charge_Id__c,addassoc);
                    }
            
        }else{
           for(cspmb__Price_Item_Add_On_Price_Item_Association__c addassoc:[Select id,cspmb__price_item__c,cspmb__add_on_price_item__c,cspmb__add_on_price_item__r.Offer_Id__c,
                                                                            cspmb__add_on_price_item__r.Charge_Id__c,Check_todays_date__c,name,isChargeable__c,AddOn_Name__c,
                                                                            cspmb__add_on_price_item__r.cspmb__recurring_charge__c,isDefault__c,cspmb__recurring_charge__c,cspmb__one_off_charge__c,
                                                                            cspmb__add_on_price_item__r.addOn_Name__c,cspmb__add_on_price_item__r.cspmb__one_off_charge__c,AddOnName__c
                                                                            FROM cspmb__Price_Item_Add_On_Price_Item_Association__c WHERE cspmb__price_item__c=:planId
                                                                            AND cspmb__add_on_price_item__r.Offer_Id__c=: offer 
                                                                            AND cspmb__add_on_price_item__r.Charge_Id__c IN: chargeId 
                                                                            AND Check_todays_date__c=true AND isDefault__c=true]){ ////Edge-177601 updated query
                 addonassocMap.put(addassoc.cspmb__add_on_price_item__r.Charge_Id__c,addassoc);
           }
            
        }
                 
        return addonassocMap;
        
    }
    
}