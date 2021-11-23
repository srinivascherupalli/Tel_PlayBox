global class PriceItemMDPaymentTypeLookup  extends cscfga.ALookupSearch {

	public override String getRequiredAttributes()
    { 
        return '["ManufacturerString","ModelString","ColourString"]';
    }

	public override Object[] doLookupSearch(Map<String, String> searchFields,String productDefinitionId, Id[] excludeIds, Integer pageOffset, Integer pageLimit)
    {

        String manufacturerString = searchFields.get('ManufacturerString');
        String modelString = searchFields.get('ModelString');
        String colourString = searchFields.get('ColourString');

        String searchQuery;
        searchQuery = 'SELECT id, '
        + 'Name, Manufacturer__c, Model__c, Colour__c, cspmb__Contract_Term__c, ChargeType__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c, cspmb__Billing_Frequency__c, SKU__c, taxTreatment__c, Unit_Of_Measure__c, Currency__c, BillingSpecId__c, Billing_Description__c, BillInAdvance__c, Prorate__c, frequency__c, Contract_Type__c, billingSubType__c, ProdSpecId__c '
        + 'FROM cspmb__Price_Item__c '
		+ 'WHERE cspmb__Product_Definition_Name__c = \'Mobile Device\' '
        + 'AND Manufacturer__c = :manufacturerString AND Model__c = :modelString AND Colour__c = :colourString '
        + 'ORDER BY Contract_Type__c ASC ';

		System.debug('PriceItemMDPaymentTypeLookup searchQuery: ' + searchQuery);
        List<cspmb__Price_Item__c> CommercialProductsList = Database.query(searchQuery);

        return CommercialProductsList;

/*
		List<cspmb__Price_Item__c> distinctColourList = getUniqueListByField(CommercialProductsList, 'ChargeType__c');
		System.debug('PriceItemMDPaymentTypeLookup distinctPaymentTypeList: ' + distinctColourList);
        return distinctColourList;
*/        
    }

/*
	@TestVisible
    private List<cspmb__Price_Item__c> getUniqueListByField(List<cspmb__Price_Item__c> pis, String fieldName){
        //List<cspmb__Price_Item__c> uItams = new List<cspmb__Price_Item__c>();
		System.debug('PriceItemMDPaymentTypeLookup pis: ' + pis);
		System.debug('PriceItemMDPaymentTypeLookup fieldName: ' + fieldName);
        Map<String, cspmb__Price_Item__c> itemMap =  new Map<String, cspmb__Price_Item__c>();
        for(cspmb__Price_Item__c item : pis) {
            if(fieldName == 'Colour__c' && !itemMap.containsKey(item.Colour__c)) {
                itemMap.put(item.Colour__c, item);
            }
        }
		System.debug('PriceItemMDPaymentTypeLookup itemMap: ' + itemMap);
        return itemMap.values();
    }
*/	
}