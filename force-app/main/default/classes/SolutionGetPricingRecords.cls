/* ****************************************************************************
* Author : Jainish Shukla : EDGE-81081
* Date :    22 July 2019
* Description : Classes for PPHH
* *****************************************************************************/

global with sharing class SolutionGetPricingRecords implements cssmgnt.RemoteActionDataProvider{
    @RemoteAction
    global static Map<String,Object> getData(Map<String,Object> inputMap) {
        //input would be the map consisting of 1 recordId of Junction Object
        System.debug('inputMap'+inputMap);

        Map<String, Object> returnMap = new Map<String, Object>(); 
        Set<String> inputKey = inputMap.keySet();
        system.debug('inputkey'+inputKey);
        for (String k :inputKey) {
            system.debug('k'+k);
            system.debug('String.escapeSingleQuotes(k)'+String.escapeSingleQuotes(k));
            system.debug('KeyPrefix.GetKeyPrefix(String.escapeSingleQuotes(k)'+KeyPrefix.GetKeyPrefix(String.escapeSingleQuotes(k)));
            String objectName =  KeyPrefix.GetKeyPrefix(String.escapeSingleQuotes(k));
            system.debug('objectName ' + objectName);
            if(objectName == 'cspmb__Price_Item_Add_On_Price_Item_Association__c'){
                switch on (String)inputMap.get(k){
                    when 'getAddOn'{
                        list<cspmb__Add_On_Price_Item__c> addOnList = getFromPriceAssociation(k,'getAddOn');
                        if (!addOnList.isEmpty()) {
                            returnMap.put('addOnList', addOnList);
                        }
                    }
                    when 'getPriceItem'{
                        list<cspmb__Price_Item__c> priceItemList = getFromPriceAssociation(k,'getPriceItem');
                        if (!priceItemList.isEmpty()) {
                            returnMap.put('priceList', priceItemList);
                        }
                    }
                }
            }
            if(objectName == 'cspmb__Commercial_Product_Allowance_Assoc__c'){
                switch on (String)inputMap.get(k){
                    when 'getAddOn'{
                        list<cspmb__Add_On_Price_Item__c> addOnList = getFromAllowanceAssociation(k,'getAddOn');
                        if (!addOnList.isEmpty()) {
                            returnMap.put('addOnList', addOnList);
                        }
                    }
                    when 'getPriceItem'{
                        list<cspmb__Price_Item__c> priceItemList = getFromAllowanceAssociation(k,'getPriceItem');
                        if (!priceItemList.isEmpty()) {
                            returnMap.put('priceList', priceItemList);
                        }
                    }
                    when 'getAllowance'{
                        list<cspmb__Allowance__c> allowanceList = getFromAllowanceAssociation(k,'getAllowance');
                        if (!allowanceList.isEmpty()) {
                            returnMap.put('allowanceList', allowanceList);
                        }
                    }
                }
            }
        }
        return returnMap;
    }
    private static list<sObject> getFromPriceAssociation(String relatesToId,String relation){
        switch on relation {
            when 'getAddOn'{
                String addonRecId;
                for(cspmb__Price_Item_Add_On_Price_Item_Association__c piaopia : [select id, name,cspmb__Add_On_Price_Item__c,cspmb__Add_On_Price_Item__r.Charge_Id__c from cspmb__Price_Item_Add_On_Price_Item_Association__c where id =:relatesToId]){
                    addonRecId = piaopia.cspmb__Add_On_Price_Item__c;
                }
                
                if(addonRecId!=null){
                    List<cspmb__Add_On_Price_Item__c> addOnList = [select id, name,Charge_Id__c from cspmb__Add_On_Price_Item__c where id =: addonRecId];
                    return addOnList;
                }
            }
            when 'getPriceItem'{
                String priceItemRecId;
                for(cspmb__Price_Item_Add_On_Price_Item_Association__c piaopia : [select id, name,cspmb__Price_Item__c from cspmb__Price_Item_Add_On_Price_Item_Association__c where id =:relatesToId]){
                    priceItemRecId = piaopia.cspmb__Price_Item__c;
                }
                
                if(priceItemRecId!=null){
                    List<cspmb__Price_Item__c> priceItemList = [select id, name from cspmb__Price_Item__c where id =: priceItemRecId];
                    return priceItemList;
                }
            }
        }
        return null;
    }
    
    private static list<sObject> getFromAllowanceAssociation(String relatesToId,String relation){
        switch on relation {
            when 'getAddOn'{
                String addonRecId;
                for(cspmb__Commercial_Product_Allowance_Assoc__c piaopia : [select id, name,cspmb__add_on__c from cspmb__Commercial_Product_Allowance_Assoc__c where id =:relatesToId]){
                    addonRecId = piaopia.cspmb__add_on__c;
                }
                
                if(addonRecId!=null){
                    List<cspmb__Add_On_Price_Item__c> addOnList = [select id, name from cspmb__Add_On_Price_Item__c where id =: addonRecId];
                    return addOnList;
                }
            }
            when 'getPriceItem'{
                String priceItemRecId;
                for(cspmb__Commercial_Product_Allowance_Assoc__c piaopia : [select id, name,cspmb__commercial_product__c from cspmb__Commercial_Product_Allowance_Assoc__c where id =:relatesToId]){
                    priceItemRecId = piaopia.cspmb__commercial_product__c;
                }
                
                if(priceItemRecId!=null){
                    List<cspmb__Price_Item__c> priceItemList = [select id, name from cspmb__Price_Item__c where id =: priceItemRecId];
                    return priceItemList;
                }
            }
            when 'getAllowance'{
                String allowanceRecId;
                for(cspmb__Commercial_Product_Allowance_Assoc__c piaopia : [select id, name,cspmb__allowance__c from cspmb__Commercial_Product_Allowance_Assoc__c where id =:relatesToId]){
                    allowanceRecId = piaopia.cspmb__allowance__c;
                }
                
                if(allowanceRecId!=null){
                    List<cspmb__Allowance__c> allowanceList = [select id, name,value__c from cspmb__Allowance__c where id =: allowanceRecId];
                    return allowanceList;
                }
            }
        }
        return null;
    }
   
}