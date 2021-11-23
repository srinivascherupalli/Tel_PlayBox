global with sharing class CS_HandSTypeFromPriceItem extends cscfga.ALookupSearch {
    public override String getRequiredAttributes() {
        return '["Prod_Cnf_Id", "OfferId"]';
    }

    public override Object[] doLookupSearch(Map<String, String> searchFields, String productDefinitionId, Id[] excludeIds,
                                            Integer pageOffset, Integer pageLimit) {

        final Integer SELECT_LIST_LOOKUP_PAGE_SIZE = 25; 
        final Integer SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT = 26;

        Integer recordOffset = 0;
        if (pageOffset != null && pageOffset != 0 && pageLimit != null && pageLimit != 0)
            recordOffset = pageOffset * SELECT_LIST_LOOKUP_PAGE_SIZE;

        List<cspmb__Price_Item__c> priceList = [
            SELECT Name, Type__c, cspmb__Product_Definition_Name__c, Check_todays_date__c, model__c,
            Contract_Type__c, OP_Contract_Term__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c,
            cspmb__Price_Item_Code__c, Commercial_Product_Code__c,Frequency__c, taxTreatment__c, Unit_Of_Measure__c, 
            cspmb__Effective_End_Date__c, cspmb__Effective_Start_Date__c,Billing_Description__c
            FROM cspmb__Price_Item__c
            WHERE Check_todays_date__c = true
                AND Package_Name__c = 'Connected Workplace'
                AND cspmb__Product_Definition_Name__c
                LIKE '%Handset and Accessories%'
                AND Offer_Id__c = :searchFields.get('OfferId') 
            LIMIT :SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT
            OFFSET :recordOffset
        ];

        system.debug(LoggingLevel.INFO, 'CS_HandSTypeFromPriceItem.priceList = ' + priceList);

        Map<String, cspmb__Price_Item__c> typeMap = new  Map<String, cspmb__Price_Item__c>();
        if (priceList != null) {
            for (cspmb__Price_Item__c item : priceList) {
                if (!typeMap.containskey(item.Type__c))
                    typeMap.put(item.Type__c, item);
            }
        }

        if (typeMap != null && typeMap.size() > 0)
            return typeMap.Values();
        else
            return null;
    }
}