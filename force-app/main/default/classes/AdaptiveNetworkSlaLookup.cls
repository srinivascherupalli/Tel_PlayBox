/******************************************************************************************************************************
Name          : AdaptiveNetworkLookupTest
Created By    : Ravi Kumar Jain
Created Date  : OCT 12 2021
Description   : SLA lookup search based on Access Type.
-------
History
-------
VERSION     AUTHOR                       DATE            DETAIL
-------     ------                       -----           ---------
1.1         Ravi Kumar Jain            OCT 12 2021      Created
1.2      Ravi Kumar Jain        Nov 15 2021     Updated : Sequence updated as per the desgin & defect DIGI-39548
******************************************************************************************************************************/

global with sharing class AdaptiveNetworkSlaLookup extends cscfga.ALookupSearch {
    public override Object[] doLookupSearch(Map<String, String> searchFields,String productDefinitionId, Id[] excludeIds, Integer pageOffset, Integer pageLimit) {
        Map<String,cspmb__Price_Item_Add_On_Price_Item_Association__c> returnMap = new Map<String,cspmb__Price_Item_Add_On_Price_Item_Association__c>();
        String techType = (searchFields.containsKey('Access Type') && searchFields.get('Access Type') != NULL)? searchFields.get('Access Type') : '';
        String zone = (searchFields.containsKey('SLA Zone') && searchFields.get('SLA Zone') != NULL)? searchFields.get('SLA Zone') : '';
        String adaptService = (searchFields.containsKey('Adapt Service Value') && searchFields.get('Adapt Service Value') != NULL)? searchFields.get('Adapt Service Value') : '';
        String slaType = (searchFields.containsKey('SLA Type Value') && searchFields.get('SLA Type Value') != NULL)? searchFields.get('SLA Type Value') : '';
        String query = 'SELECT Id,Name,access_type__c,cspmb__add_on_price_item__r.port_type__c,cspmb__price_item__r.redundancytype__c,cspmb__Add_On_Price_Item__r.external_id__c,cspmb__add_on_price_item__c,cspmb__Add_On_Price_Item__r.Adapt_Service__c,cspmb__add_on_price_item__r.sla_type__c,cspmb__add_on_price_item__r.service_management__c FROM cspmb__Price_Item_Add_On_Price_Item_Association__c WHERE cspmb__add_on_price_item__r.cspmb__is_active__c = TRUE AND cspmb__Add_On_Price_Item__r.Access_Type__c =:techType';
        
        if(techType != '') {
            if(slaType == '') {
                query += ' AND cspmb__Add_On_Price_Item__r.sla_type__c != \'\'';
                for(cspmb__Price_Item_Add_On_Price_Item_Association__c assoc : Database.query(query)) {
                    if(!returnMap.containsKey(assoc.cspmb__Add_On_Price_Item__r.sla_type__c)) {
                        returnMap.put(assoc.cspmb__Add_On_Price_Item__r.sla_type__c, assoc);
                    }
                }
            } else if(adaptService == '' && slaType != '') {
                query += ' AND cspmb__Add_On_Price_Item__r.sla_type__c =: slaType ';
                for(cspmb__Price_Item_Add_On_Price_Item_Association__c assoc : Database.query(query)) {
                    if(!returnMap.containsKey(assoc.cspmb__Add_On_Price_Item__r.Adapt_Service__c)) {
                        returnMap.put(assoc.cspmb__Add_On_Price_Item__r.Adapt_Service__c, assoc);
                    }
                }
            } else if(adaptService != '' && slaType != '' && zone != '') {
                query += ' AND cspmb__Add_On_Price_Item__r.sla_type__c =: slaType AND cspmb__Add_On_Price_Item__r.Adapt_Service__c =:adaptService AND cspmb__Add_On_Price_Item__r.SLA_Zone__c =:zone';
                for(cspmb__Price_Item_Add_On_Price_Item_Association__c assoc : Database.query(query)) {
                    if(!returnMap.containsKey(assoc.cspmb__Add_On_Price_Item__r.service_management__c)) {
                        returnMap.put(assoc.cspmb__Add_On_Price_Item__r.service_management__c, assoc);
                    }
                }
            }
        }
        return returnMap.values();
    }
}