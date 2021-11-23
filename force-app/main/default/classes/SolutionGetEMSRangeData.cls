/* ****************************************************************************
* Author : Laxmi Rahate : EDGE-116138
* Date :   15 Oct 2019
* Description : Classes for SolutionGetEMSRangeData

2.        Venkat 01/11/2019   Edge-117274 Updated the query logic to cater for the generic Tenancy modelling 
3.        Shubhi 05/11/2019   Edge-117563 updated orderby in query
* *****************************************************************************/
global with sharing class SolutionGetEMSRangeData  {
    
    @RemoteAction
    global static List<cspmb__Price_Item__c> getData(Map<String,Object> inputMap) {
        String likeFilter;
        System.debug('inputMap'+inputMap);
        
        String externalId = (inputMap.containsKey('externalId') && inputMap.get('externalId') != '')? (String)inputMap.get('externalId'):'';
                String offerId = (inputMap.containsKey('offerId') && inputMap.get('offerId') != '')? (String)inputMap.get('offerId'):'';
                   String vendor = (inputMap.containsKey('vendor') && inputMap.get('vendor') != '')? (String)inputMap.get('vendor'):'';

        // String type = (inputMap.containsKey('type') && inputMap.get('type') != '')? (String)inputMap.get('type'):'';
        if(String.isNotBlank(externalId)){
         likeFilter = '%'+String.escapeSingleQuotes(externalId)+'%';
        }
        system.debug('likeFilter----->'+likeFilter);
        
        Map<String, Object> returnMap = new Map<String, Object>(); 
        Set<String> inputKey = inputMap.keySet();
        
        String Query = 'SELECT id, Vendor__c,External_Id__c,rangeFrom__c,rangeTo__C,cspmb__Recurring_Charge__c,Feature_Level__c ,Technical_Support__c,Type__c,Offer_Id__c,Name  FROM cspmb__Price_Item__c '; 
        if(String.IsNotBlank(externalId)){
        Query += 'where  External_Id__c  like \''+likeFilter+'\' ';
        }
        system.debug('offerid'+offerId);
        if(String.isNotBlank(offerId)){
           String filter1 = (String.IsNotBlank(Query) && Query.contains('where')) ? ' and Offer_Id__c =\''+offerId  +'\'': 'where Offer_Id__c =\''+offerId+'\'';
           Query += filter1;
        }
        Query += ' ORDER BY cspmb__Recurring_Charge__c DESC'; //edge-117563
        system.debug('query:::'+Query);
        list<cspmb__Price_Item__c > priceItem = Database.query(Query);
        
        if (priceItem.size()>0) {
            returnMap.put('emsRangeData', priceItem);
        }
       
       return priceItem;
    }
    
    
    
}