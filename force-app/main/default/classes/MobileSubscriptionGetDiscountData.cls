/* ****************************************************************************
* Author : Jainish Shukla : EDGE-81081
* Date :    22 July 2019
* Description : Classes for PPHH
* Sr no 2 -EDGE-127421 - DiscountCHargeID is select query
*this will help in Populating the BusinessiD for MROBonus on MobileSubscription
* *****************************************************************************/
    global with sharing class MobileSubscriptionGetDiscountData implements cssmgnt.RemoteActionDataProvider{
    @RemoteAction
    global static Map<String,Object> getData(Map<String,Object> inputMap) {
        //input would be the map consisting of 1 recordId of Junction Object
        System.debug('inputMap'+inputMap);

        Map<String, Object> returnMap = new Map<String, Object>(); 
        Set<String> inputKey = inputMap.keySet();
        String planRecordId = '';
        String deviceRecordId = '';
        for (String k :inputKey) {
            switch on k{
                when 'planRecord'{
                    planRecordId = (String)inputMap.get(k);
                    
                }
                when 'deviceRecord'{
                    deviceRecordId = (String)inputMap.get(k);
                }
            }
        }
        if(planRecordId!= null && deviceRecordId!= null){
            List<Product_To_Product_Association__c> planDiscountList = getFromPriceAssociation(planRecordId,deviceRecordId);
            if(!planDiscountList.isEmpty()){
                returnMap.put('planDiscountList', planDiscountList);
            }
        }
        return returnMap;
    }
    private static List<Product_To_Product_Association__c> getFromPriceAssociation(String planRecordId,String deviceRecordId){
        List<Product_To_Product_Association__c> planDiscountList = new List<Product_To_Product_Association__c>();
        //Laxmi Rahate - Added DiscountChargeID in select Query EDGE-127421

        for(Product_To_Product_Association__c ptpa : [select id,name,Governed_Attribute_Name__c,Governed_Attribute_Value__c,Recurring_Charge__c,Governed_Attribute_Value_Type__c,Contract_Term__c,Effective_End_Date__c,Effective_Start_Date__c,DiscountChargeID__c  from Product_To_Product_Association__c where Governed_Product__c =:planRecordId and Governing_Product__c =:deviceRecordId and Check_todays_date__c = true]){
            if(ptpa.Governed_Attribute_Name__c == 'PlanDiscount'){
                planDiscountList.add(ptpa);    
            }
        }
        return planDiscountList;
    }
}