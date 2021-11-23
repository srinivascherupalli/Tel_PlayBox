/* ****************************************************************************
* Author : Jainish Shukla : EDGE-81081
* Date :    22 July 2019
* Description : Classes for PPHH
VERSION     AUTHOR          DATE            DETAIL                   
-------     ------          -----           ---------                 
1.1         ankit           30-08-2019      Added cspmb__allowance__r.Value__c in Query
1.2         ankit           10-09-2019      Added cspmb__allowance__r.External_Id__c in Query  EDGE-103385 
2.         shubhi           7/5/2020        checkTodaysDate Edge-120919
* *****************************************************************************/
global with sharing class SolutionGetAllowanceData implements cssmgnt.RemoteActionDataProvider {

    @RemoteAction
    global static Map<String,Object> getData(Map<String,Object> inputMap) {

        System.debug('inputMap'+inputMap);

        Map<String, Object> returnMap = new Map<String, Object>(); 
        Set<String> inputKey = inputMap.keySet();

        for (String k :inputKey) {
            list<cspmb__Commercial_Product_Allowance_Assoc__c> allowanceList = getAllowance(k, (String)inputMap.get(k));

            if (allowanceList != null && !allowanceList.isEmpty()) {
                    returnMap.put('allowances', allowanceList);
            }
        }
    
        return returnMap;
    }

    private static list<cspmb__Commercial_Product_Allowance_Assoc__c> getAllowance(String relatesTo, String relatesToId) {

        list<cspmb__Commercial_Product_Allowance_Assoc__c> allowanceList = new list<cspmb__Commercial_Product_Allowance_Assoc__c>();

        if (relatesTo == 'priceItemId') {
            //query updated by shubhi added check todays date edge-120919
            allowanceList = [select id, name, cspmb__allowance__r.name, cspmb__allowance__r.specId__c,cspmb__allowance__r.Value__c,cspmb__allowance__r.External_Id__c,//added as part of EDGE-103385 
             cspmb__allowance__r.billingSpecId__c, cspmb__allowance__r.ocsProdId__c, cspmb__allowance__r.startDate__c, cspmb__allowance__r.endDate__c, 
                 cspmb__allowance__r.type__c,cspmb__allowance__r.subType__c, cspmb__allowance__r.Unit_Of_Measure__c, cspmb__allowance__r.cspmb__amount__c,cspmb__allowance__r.CheckTodaysDate__c
                            from cspmb__Commercial_Product_Allowance_Assoc__c
                            where cspmb__commercial_product__c = :relatesToId and cspmb__allowance__r.CheckTodaysDate__c=true
                        ];

        }

        if (relatesTo == 'addOnPriceItemId') {
            allowanceList = [select id, name, cspmb__allowance__r.name,cspmb__allowance__r.Value__c,cspmb__allowance__r.specId__c, cspmb__allowance__r.billingSpecId__c, cspmb__allowance__r.ocsProdId__c, cspmb__allowance__r.startDate__c, cspmb__allowance__r.endDate__c, cspmb__allowance__r.type__c, cspmb__allowance__r.subType__c, cspmb__allowance__r.Unit_Of_Measure__c, cspmb__allowance__r.cspmb__amount__c
                            from cspmb__Commercial_Product_Allowance_Assoc__c
                            where cspmb__add_on__c = :relatesToId
                        ];

        }

        return allowanceList;
    }   

}