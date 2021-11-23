/* ****************************************************************************
* Author : Laxmi Rahate : EDGE-66050
* Date : 	22 July 2019
* Description : Classes for MDM Tenancy
* *****************************************************************************/
global with sharing class SolutionGetMDMTenancyRangeData implements cssmgnt.RemoteActionDataProvider {

    @RemoteAction
    global static Map<String,Object> getData(Map<String,Object> inputMap) {

        //System.debug('inputMap'+inputMap);

        Map<String, Object> returnMap = new Map<String, Object>(); 
        Set<String> inputKey = inputMap.keySet();
 			list<cspmb__Price_Item__c > priceItem = [SELECT id, rangeFrom__c,rangeTo__C,cspmb__Recurring_Charge__c	 FROM cspmb__Price_Item__c WHERE  name= 'T-MDM Powered by Vmware' AND cspmb__Effective_End_Date__c >= TODAY AND cspmb__Effective_Start_Date__c <= TODAY ORDER BY rangeTo__c ASC];
      
            if (priceItem != null) {
                    returnMap.put('mdmRangeData', priceItem);
            }

    
        return returnMap;
    }

     

}