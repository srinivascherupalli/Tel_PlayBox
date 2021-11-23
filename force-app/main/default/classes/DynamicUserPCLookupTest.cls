@isTest
private class DynamicUserPCLookupTest {
	
	static{
		TestDataFactory.generateService();
	}

	@isTest static void test_doDynamicLookupSearch() {

		List<cscfga__Product_Configuration__c> prodConfs = [SELECT Id, Name, cscfga__Product_Basket__r.csbb__Account__c, 
															Quantity_Product_Configuration__c, csordtelcoa__Replaced_Product_Configuration__c,
															cscfga__Product_Basket__c 
															FROM cscfga__Product_Configuration__c];

		Map<String, String> searchFields = new Map<String, String>{
			'BasketId' => prodConfs[0].cscfga__Product_Basket__c,
			'AccountId' => prodConfs[0].cscfga__Product_Basket__r.csbb__Account__c
		};

		DynamicUserPCLookup dUserLookup = new DynamicUserPCLookup();
		List<cscfga__Product_Configuration__c> prodConfsResult = (List<cscfga__Product_Configuration__c>)dUserLookup.doDynamicLookupSearch(searchFields, '');

		//TODO PUT A LIST FOR BETTER ASSERT
		System.assert(prodConfsResult[0].Quantity_Product_Configuration__c == 2);
	}
	
	@isTest static void test_getRequiredAttributes() {
		DynamicUserPCLookup dUserLookup = new DynamicUserPCLookup();
		String attResult = dUserLookup.getRequiredAttributes();
		System.debug(attResult); 
		System.assert( '["AccountId","BasketId"]'.equals(attResult));
	}
	
}