/***************************************************************************************************
Name          : AN_RedundancyCosLookup
Created By    : Ravi Kumar Jain
Created Date  : Nov 12 2021
Description   : To Search and display Redundancy Type based on Access Type & Zone
-------
History
-------
VERSION     AUTHOR                       DATE            DETAIL
-------     ------                       -----           ---------
1.1         Ravi Kumar Jain        		Nov 12 2021      Created
***************************************************************************************************/

global with sharing class AN_RedundancyCosLookup extends cscfga.ALookupSearch {
    public override Object[] doLookupSearch(Map<String, String> searchFields,String productDefinitionId, Id[] excludeIds, Integer pageOffset, Integer pageLimit) {
        Map<String,cspmb__Price_Item__c> returnMap = new Map<String,cspmb__Price_Item__c>();
        String accessType = (searchFields.containsKey('Access Type') && searchFields.get('Access Type') != NULL)? searchFields.get('Access Type') : '';
        String zone = (searchFields.containsKey('Zone') && searchFields.get('Zone') != NULL)? searchFields.get('Zone') : '';
        String query = 'SELECT Id, Name, bandwidth__c ,port_type__c , zone__c ,technology_type__c ,redundancytype__c ,cspmb__is_active__c ,classofservice__c ,cspmb__price_item_code__c FROM cspmb__Price_Item__c WHERE cspmb__is_active__c = TRUE AND technology_type__c =: accessType AND zone__c =: zone';
        if (searchFields.containsKey('searchValue') && searchFields.get('searchValue') != NULL && searchFields.get('searchValue') != '') {
            query += (accessType == 'nbn Enterprise Ethernet')? ' AND classofservice__c ': ' AND redundancytype__c ' ;
            query += 'LIKE \'%'+ String.escapeSingleQuotes(searchFields.get('searchValue')) + '%\'';
        }
        if(accessType != '' && zone != '') {
            for(cspmb__Price_Item__c cp : Database.query(query)) {
                if(accessType == 'nbn Enterprise Ethernet') {
                    if(!returnMap.containsKey(cp.classofservice__c)) {
                        returnMap.put(cp.classofservice__c, cp);
                    } 
                } else {
                    if(!returnMap.containsKey(cp.redundancytype__c)) {
                        returnMap.put(cp.redundancytype__c, cp);
                    }       
                }
            }
        }
        return returnMap.values();
    }
}