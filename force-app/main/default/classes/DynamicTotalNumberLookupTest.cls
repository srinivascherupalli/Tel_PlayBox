@isTest
private class DynamicTotalNumberLookupTest {
	static {
		TestDataFactory.generateAttachment('Test Attachment', TestDataFactory.jsonNumberOfNumber, TestDataFactory.generateProductConfiguration().Id);
	}

	@isTest static void test_doDynamicLookupSearch() {
		List<Attachment> attachments = [SELECT Id, Name, parentId FROM Attachment ];
		System.debug(attachments);

		/*
		Id basktId = searchFields.get('BasketId');
		Id accountId = searchFields.get('AccountId');
		Id configId = searchFields.get('ConfigId');*/

		//TODO REFACT TO REMOVEE THIS 3 SOQL'S
		List<cscfga__Product_Basket__c> prodBaskets = [SELECT Id, Name FROM cscfga__Product_Basket__c];
		List<Account> accounts = [SELECT Id, Name FROM Account];
		List<cscfga__Product_Configuration__c> prodConfigurations = [SELECT Id, Name FROM cscfga__Product_Configuration__c];


		//List<Attachment> [select id,body from attachment where ParentId  =:UCEConfigId]
		
		Map<String, String> searchFields = new Map<String, String>{
			'BasketId' => prodBaskets[0].Id,
			'AccountId' => accounts[0].Id,
			'UCEConfigId' => prodConfigurations[0].Id
		};

		DynamicTotalNumberLookup dynTotalNumbLookup = new DynamicTotalNumberLookup();
		Object[] results = dynTotalNumbLookup.doDynamicLookupSearch(searchFields, '');

		System.debug(results);
		system.assert(results != null);


	}
}