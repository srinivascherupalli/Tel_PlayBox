global class OPTypeLookupCustom extends cscfga.ALookupSearch {

	public static final String PICode = 'Opportunity Product';
	public override String getRequiredAttributes(){
		return '["ProductSelected"]';
	}

	public override Object[] doLookupSearch(Map<String, String> searchFields, String productDefinitionId, Id[] excludeIds, Integer pageOffset, Integer pageLimit){
		String opProduct = searchFields.get('ProductSelected');
		String searchValue = searchFields.get('searchValue');
		System.debug('-----------> NonModuleTypeLookupCustom opProduct   ' + opProduct);
		System.debug('-----------> NonModuleTypeLookupCustom searchValue   ' + searchValue);
		String searchMatch = '';

		if (String.isEmpty(opProduct)) {
			return null;
		} else {
			searchMatch = 'OP_Product__c = ' + '\'' + opProduct + '\'';
		}

		String searchQuery = 'SELECT name, OP_Product__c, OP_Type__c, OP_Option__c, OP_Contract_Term__c, id, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c' +
		    ' FROM cspmb__Price_Item__c';
		String whereClause = '';
		if (String.isEmpty(searchMatch)) {
			whereClause = ' WHERE Commercial_Product_Code__c = \'' + PICode + '\' AND name != null'; //AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
		} else {
			whereClause = ' WHERE Commercial_Product_Code__c = \'' + PICode + '\' AND ' + searchMatch; //AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
		}
		if (!String.isEmpty(searchValue)) {
			whereClause += ' AND OP_Type__c LIKE \'' +  searchValue + '%\'';
		}

		System.debug('-----------> NonModuleTypeLookupCustom whereClause   ' + whereClause);
		List<cspmb__Price_Item__c> pis = Database.query(searchQuery + whereClause);

		return getUniqueListByField(pis, 'Type');
	}

	@TestVisible
	private List<cspmb__Price_Item__c> getUniqueListByField(List<cspmb__Price_Item__c> pis, String fieldName){
		//List<cspmb__Price_Item__c> uItams = new List<cspmb__Price_Item__c>();
		Map<String, cspmb__Price_Item__c> itemMap =  new Map<String, cspmb__Price_Item__c>();
		for (cspmb__Price_Item__c item : pis) {
			if (fieldName == 'Type' && !itemMap.containsKey(item.OP_Type__c)) {
				itemMap.put(item.OP_Type__c, item);
			}
		}
		System.debug('-----------> NonModuleTypeLookupCustom itemMap.values()   ' + itemMap.values());
		return itemMap.values();
	}
}