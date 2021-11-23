global class PriceItemContractTermLookupCustom  extends cscfga.ALookupSearch {
    //Tests for this class are in PriceItemLookupCustomTest class
	public override String getRequiredAttributes()
    { 
        return '["MobileHandsetManufacturer","MobileHandsetModel","MobileHandsetColour","PaymentType"]';
    }

	public override Object[] doLookupSearch(Map<String, String> searchFields,String productDefinitionId, Id[] excludeIds, Integer pageOffset, Integer pageLimit)
    {
		System.debug('PriceItemContractTermLookupCustom searchFields: ' + searchFields);
        //String searchValue = ApexPages.currentPage().getParameters().get('searchValue');
		String searchValue = '%' + searchFields.get('searchValue') + '%';
		System.debug('PriceItemContractTermLookupCustom searchValue: ' + searchValue);
		System.debug('PriceItemContractTermLookupCustom searchFields: ' + searchFields);
		Id chosenManufacturerPriceItemId = Id.valueOf(searchFields.get('MobileHandsetManufacturer'));
		cspmb__Price_Item__c chosenManufacturerPriceItem = [SELECT Manufacturer__c FROM cspmb__Price_Item__c WHERE Id =: chosenManufacturerPriceItemId];
		System.debug('PriceItemContractTermLookupCustom chosenManufacturerPriceItem: ' + chosenManufacturerPriceItem);
		String selectedManufacturer = chosenManufacturerPriceItem.Manufacturer__c;		
		System.debug('PriceItemContractTermLookupCustom selectedManufacturer: ' + selectedManufacturer);
		Id chosenModelPriceItemId = Id.valueOf(searchFields.get('MobileHandsetModel'));
		cspmb__Price_Item__c chosenModelPriceItem = [SELECT Model__c FROM cspmb__Price_Item__c WHERE Id =: chosenModelPriceItemId];
		String selectedModel = chosenModelPriceItem.Model__c;
		System.debug('PriceItemContractTermLookupCustom chosenModelPriceItem: ' + chosenModelPriceItem);
		System.debug('PriceItemContractTermLookupCustom selectedModel: ' + selectedModel);
		Id chosenColourPriceItemId = Id.valueOf(searchFields.get('MobileHandsetColour'));
		cspmb__Price_Item__c chosenColourPriceItem = [SELECT Colour__c FROM cspmb__Price_Item__c WHERE Id =: chosenColourPriceItemId];
		String selectedColour = chosenColourPriceItem.Colour__c;
		System.debug('PriceItemContractTermLookupCustom chosenColourPriceItem: ' + chosenColourPriceItem);
		System.debug('PriceItemContractTermLookupCustom selectedColour: ' + selectedColour);
		Id chosenPaymentTypePriceItemId = Id.valueOf(searchFields.get('PaymentType'));
		cspmb__Price_Item__c chosenPaymentTypePriceItem = [SELECT ChargeType__c FROM cspmb__Price_Item__c WHERE Id =: chosenPaymentTypePriceItemId];
		String selectedPaymentType = chosenPaymentTypePriceItem.ChargeType__c;

        String searchQuery;
        if (searchValue == null) {
            searchQuery = 'SELECT id, name, Manufacturer__c, Model__c, Colour__c, cspmb__Contract_Term__c, ChargeType__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c, cspmb__Billing_Frequency__c, SKU__c FROM cspmb__Price_Item__c '
			+ 'WHERE Manufacturer__c =: selectedManufacturer AND Model__c =: selectedModel AND Colour__c =: selectedColour AND ChargeType__c =: selectedPaymentType '
            + 'ORDER BY cspmb__Contract_Term__c ASC ';
        } else {
            String likeValue = '%' + searchValue + '%';
            searchQuery = 'SELECT id, name, Manufacturer__c, Model__c, Colour__c, cspmb__Contract_Term__c, ChargeType__c, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c, cspmb__Billing_Frequency__c, SKU__c FROM cspmb__Price_Item__c '
            + 'WHERE ChargeType__c LIKE :likeValue AND Manufacturer__c =: selectedManufacturer AND Model__c =: selectedModel AND Colour__c =: selectedColour AND ChargeType__c =: selectedPaymentType '
            + 'ORDER BY cspmb__Contract_Term__c ASC ';            
        }
		System.debug('PriceItemContractTermLookupCustom searchQuery: ' + searchQuery);
        List<cspmb__Price_Item__c> CommercialProductsList = Database.query(searchQuery);

		List<cspmb__Price_Item__c> distinctContractTermList = getUniqueListByField(CommercialProductsList, 'cspmb__Contract_Term__c');
		System.debug('PriceItemContractTermLookupCustom distinctContractTermList: ' + distinctContractTermList);
        return distinctContractTermList;
    }

	@TestVisible
    private List<cspmb__Price_Item__c> getUniqueListByField(List<cspmb__Price_Item__c> pis, String fieldName){
        //List<cspmb__Price_Item__c> uItams = new List<cspmb__Price_Item__c>();
		System.debug('PriceItemContractTermLookupCustom pis: ' + pis);
		System.debug('PriceItemContractTermLookupCustom fieldName: ' + fieldName);
        Map<String, cspmb__Price_Item__c> itemMap =  new Map<String, cspmb__Price_Item__c>();
        for(cspmb__Price_Item__c item : pis) {
            if(fieldName == 'cspmb__Contract_Term__c' && !itemMap.containsKey(item.cspmb__Contract_Term__c)) {
                itemMap.put(item.cspmb__Contract_Term__c, item);
            }
        }
		System.debug('PriceItemPaymentTypeLookupCustom itemMap: ' + itemMap);
        return itemMap.values();
    }
}