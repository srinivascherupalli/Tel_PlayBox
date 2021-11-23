/* ****************************************************************************
* Author : Jainish Shukla : EDGE-81081
* Date :    22 July 2019
* Description : Classes for PPHH
===============================================================================================================================
 Change.No.    Developer Name          Date          Story Description
1.                  Shubhi          05/09/2020
* *****************************************************************************/
global with sharing class MobileSubscriptionGetAddOnData implements cssmgnt.RemoteActionDataProvider{
    @RemoteAction
    global static Map<String,Object> getData(Map<String,Object> inputMap) {

        System.debug('inputMap'+inputMap);

        Map<String, Object> returnMap = new Map<String, Object>(); 
        Set<String> inputKey = inputMap.keySet();

        if(inputMap!=null && inputMap.size()> 0 ) {
            if(inputMap.containsKey('priceItemId')){
                String k='priceItemId';
                String priceItemId = (String)inputMap.get('priceItemId');
                list<cspmb__Price_Item_Add_On_Price_Item_Association__c> addOnIDDList = getIDDAddOn(k, (String)inputMap.get(k));
                list<cspmb__Price_Item_Add_On_Price_Item_Association__c> addOnMsgBankList = getMsgBankAddOn(k, (String)inputMap.get(k));

                if (addOnIDDList != null && !addOnIDDList.isEmpty()) {
                        returnMap.put('addOnIDD', addOnIDDList);
                }
                if (addOnMsgBankList != null && !addOnMsgBankList.isEmpty()) {
                        returnMap.put('addOnMsgBank', addOnMsgBankList);
                }
            }
            //EDGE-160037 added by shubhi start-----------
            else if(inputMap.containsKey('getAddonPriceItemAssociation')){
                String offerid='';
                if(inputMap.containskey('offerid'))
                   offerid=(String)inputMap.get('offerid');
                String chargeid='';
                if(inputMap.containskey('chargeid'))
                    chargeid=(String)inputMap.get('chargeid');
                String plan='';
                if(inputMap.containskey('plan'))
                    plan=(String)inputMap.get('plan');
                String addonName='';
                if(inputMap.containskey('addonName'))
                    addonName=(String)inputMap.get('addonName');
                if(String.isNotBlank(offerid) && String.isNotBlank(chargeid) && String.isNotBlank(plan) && String.isNotBlank(addonName)){
                    returnMap.put('getAddonPriceItemAssociation',Model_addonPriceItemAssociation.getAddonPriceItemAssociation(addonName,chargeid,offerid,plan));
                }   
            }else if(inputMap.containsKey('getAddonPriceItemAssociationBulk')){
                String offerid='';
                if(inputMap.containskey('offerid'))
                   offerid=(String)inputMap.get('offerid');
                List<String> chargeidList=new List<string>();
                if(inputMap.containskey('chargeidList')){
                    String jsonString=(String)inputMap.get('chargeidList');
                    system.debug('chargeidList-->'+jsonString);                
                    chargeidList=jsonString.split(',');
                }
                String plan='';
                if(inputMap.containskey('plan'))
                    plan=(String)inputMap.get('plan');
                List<String> addonNameList=new List<string>();
                if(inputMap.containskey('addonNameList')){
                    String jsonString=(String)inputMap.get('addonNameList');
                    addonNameList=jsonString.split(',');
                }
                //if(inputMap.containskey('addonName'))
                    //addonName=(String)inputMap.get('addonName');
                if(String.isNotBlank(offerid) && chargeidList!=null && String.isNotBlank(plan)){
                    returnMap.put('setAddonPriceItemAssociation',Model_addonPriceItemAssociation.getAddonPriceItemAssociationBulk(chargeidList,offerid,plan,addonNameList));
                }   
            }//EDGE-160037 added by shubhi end-----------
            //
        }
    
        return returnMap;
    }
    
    private static list<cspmb__Price_Item_Add_On_Price_Item_Association__c> getIDDAddOn(String relatesTo, String relatesToId) {
        List<cspmb__Price_Item_Add_On_Price_Item_Association__c> addOnList = new List<cspmb__Price_Item_Add_On_Price_Item_Association__c>();
        if (relatesTo == 'priceItemId') {
            addOnList = [select id, name, AddOn_Code__c,AddOn_Name__c,cspmb__Price_Item__c,cspmb__Recurring_Charge__c,cspmb__Sequence__c,cspmb__Add_On_Price_Item__c,
                         cspmb__Add_On_Price_Item__r.ProdSpecId__c,cspmb__Add_On_Price_Item__r.cspmb__Recurring_Charge__c,cspmb__Add_On_Price_Item__r.Charge_Id__c                        
                            from cspmb__Price_Item_Add_On_Price_Item_Association__c
                            where cspmb__Price_Item__c = :relatesToId and cspmb__Add_On_Price_Item__r.External_Id__c like '%DMCAT_RecurringCharge_000669%'
                        ];
        }
        return addOnList;
    }
    
    private static list<cspmb__Price_Item_Add_On_Price_Item_Association__c> getMsgBankAddOn(String relatesTo, String relatesToId) {
        List<cspmb__Price_Item_Add_On_Price_Item_Association__c> addOnList = new List<cspmb__Price_Item_Add_On_Price_Item_Association__c>();
        if (relatesTo == 'priceItemId') {
            addOnList = [select id, name, AddOn_Code__c,AddOn_Name__c,cspmb__Price_Item__c,cspmb__Recurring_Charge__c,cspmb__Sequence__c,cspmb__Add_On_Price_Item__c,
                         cspmb__Add_On_Price_Item__r.ProdSpecId__c,cspmb__Add_On_Price_Item__r.cspmb__Recurring_Charge__c,cspmb__Add_On_Price_Item__r.Message_Bank__c,cspmb__Add_On_Price_Item__r.Charge_Id__c
                            from cspmb__Price_Item_Add_On_Price_Item_Association__c
                            where cspmb__Price_Item__c = :relatesToId and cspmb__Add_On_Price_Item__r.External_Id__c like '%DMCAT_RecurringCharge_000497%'
                        ];
        }
        return addOnList;
    }
}