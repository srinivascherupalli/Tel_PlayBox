global class PriceItemPaymentTypeLookupCustom  extends cscfga.ALookupSearch {
    //Tests for this class are in PriceItemLookupCustomTest class
	public override String getRequiredAttributes()
    { 
        return '["MobileHandsetManufacturer","MobileHandsetModel","MobileHandsetColour"]';
    }

	public override Object[] doLookupSearch(Map<String, String> searchFields,String productDefinitionId, Id[] excludeIds, Integer pageOffset, Integer pageLimit)
    {
		System.debug('PriceItemPaymentTypeLookupCustom searchFields: ' + searchFields);
        //String searchValue = ApexPages.currentPage().getParameters().get('searchValue');
		String searchValue = '%' + searchFields.get('searchValue') + '%';
		System.debug('PriceItemPaymentTypeLookupCustom searchValue: ' + searchValue);
		System.debug('PriceItemPaymentTypeLookupCustom searchFields: ' + searchFields);
		Id chosenManufacturerPriceItemId = Id.valueOf(searchFields.get('MobileHandsetManufacturer'));
		cspmb__Price_Item__c chosenManufacturerPriceItem = [SELECT Manufacturer__c FROM cspmb__Price_Item__c WHERE Id =: chosenManufacturerPriceItemId];
		System.debug('PriceItemPaymentTypeLookupCustom chosenManufacturerPriceItem: ' + chosenManufacturerPriceItem);
		String selectedManufacturer = chosenManufacturerPriceItem.Manufacturer__c;		
		System.debug('PriceItemPaymentTypeLookupCustom selectedManufacturer: ' + selectedManufacturer);
		Id chosenModelPriceItemId = Id.valueOf(searchFields.get('MobileHandsetModel'));
		cspmb__Price_Item__c chosenModelPriceItem = [SELECT Model__c FROM cspmb__Price_Item__c WHERE Id =: chosenModelPriceItemId];
		String selectedModel = chosenModelPriceItem.Model__c;
		System.debug('PriceItemPaymentTypeLookupCustom chosenModelPriceItem: ' + chosenModelPriceItem);
		System.debug('PriceItemPaymentTypeLookupCustom selectedModel: ' + selectedModel);
		Id chosenColourPriceItemId = Id.valueOf(searchFields.get('MobileHandsetColour'));
		cspmb__Price_Item__c chosenColourPriceItem = [SELECT Colour__c FROM cspmb__Price_Item__c WHERE Id =: chosenColourPriceItemId];
		String selectedColour = chosenColourPriceItem.Colour__c;
		System.debug('PriceItemPaymentTypeLookupCustom chosenColourPriceItem: ' + chosenColourPriceItem);
		System.debug('PriceItemPaymentTypeLookupCustom selectedColour: ' + selectedColour);

        String searchQuery;
        if (searchValue == null) {
            searchQuery = 'SELECT id, name, Manufacturer__c, Model__c, Colour__c, cspmb__Contract_Term__c, ChargeType__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c, cspmb__Billing_Frequency__c, SKU__c FROM cspmb__Price_Item__c '
			+ 'WHERE Manufacturer__c =: selectedManufacturer AND Model__c =: selectedModel AND Colour__c =: selectedColour '
            + 'ORDER BY ChargeType__c ASC ';
        } else {
            String likeValue = '%' + searchValue + '%';
            searchQuery = 'SELECT id, name, Manufacturer__c, Model__c, Colour__c, cspmb__Contract_Term__c, ChargeType__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c, cspmb__Billing_Frequency__c, SKU__c FROM cspmb__Price_Item__c '
            + 'WHERE ChargeType__c LIKE :likeValue AND Manufacturer__c =: selectedManufacturer AND Model__c =: selectedModel AND Colour__c =: selectedColour '
            + 'ORDER BY ChargeType__c ASC ';            
        }
		System.debug('PriceItemPaymentTypeLookupCustom searchQuery: ' + searchQuery);
        List<cspmb__Price_Item__c> CommercialProductsList = Database.query(searchQuery);

		List<cspmb__Price_Item__c> distinctPaymentTypeList = getUniqueListByField(CommercialProductsList, 'ChargeType__c');
		System.debug('PriceItemPaymentTypeLookupCustom distinctPaymentTypeList: ' + distinctPaymentTypeList);
        return distinctPaymentTypeList;
    }

	@TestVisible
    private List<cspmb__Price_Item__c> getUniqueListByField(List<cspmb__Price_Item__c> pis, String fieldName){
        //List<cspmb__Price_Item__c> uItams = new List<cspmb__Price_Item__c>();
		System.debug('PriceItemPaymentTypeLookupCustom pis: ' + pis);
		System.debug('PriceItemPaymentTypeLookupCustom fieldName: ' + fieldName);
        Map<String, cspmb__Price_Item__c> itemMap =  new Map<String, cspmb__Price_Item__c>();
        for(cspmb__Price_Item__c item : pis) {
            if(fieldName == 'ChargeType__c' && !itemMap.containsKey(item.ChargeType__c)) {
                itemMap.put(item.ChargeType__c, item);
            }
        }
		System.debug('PriceItemPaymentTypeLookupCustom itemMap: ' + itemMap);
        return itemMap.values();
    }
}