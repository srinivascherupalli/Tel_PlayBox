@isTest
global class Test_CS_DeviceModelFromPriceItem
{
	static testmethod void test_modeldoesexist()
	{
		cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(
			name = 'Device',
			cscfga__Description__c = 'Device');
		insert pd;

		cscfga__Attribute_Definition__c atd = new cscfga__Attribute_Definition__c(
			name = 'TypeSelected',
			cscfga__Data_Type__c = 'String',
			cscfga__Type__c = 'Calculation',
			cscfga__Product_Definition__c = pd.id);
		insert atd;

		cscfga__Product_Configuration__c pc = new cscfga__Product_Configuration__c(
			name = 'Device',
			cscfga__Product_Definition__c = pd.id);
		insert pc;

		cscfga__Attribute__c att = new cscfga__Attribute__c(
			name = 'TypeSelected', cscfga__Value__c = 'IP End Point',
			cscfga__Product_Configuration__c = pc.id,
			cscfga__Attribute_Definition__c = atd.id);
		insert att;

		cspmb__Price_Item__c pi = new cspmb__Price_Item__c(
			name = 'device ucd1',
			Type__c = 'IP End Point',
			Model__c = 'Panasonic TGP500',
			Contract_Type__c = 'Outright Purchase',
			cspmb__Recurring_Charge__c = 100,
			cspmb__One_Off_Charge__c = 20,
			cspmb__Price_Item_Code__c = 'Unified Communication Device',
			Commercial_Product_Code__c = 'Unified Communication Device', //AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
			PI_External_Id__c = '457896122');
		insert pi;

		string productDefinitionId = pd.id;
		Map<String, String> searchFields = new Map<String, String>();
		searchFields.put('TypeSelected','IP End Point');
		Id[] excludeIds = new Id[] {};
		Integer pageOffset = 25;
		Integer pageLimit = 26;

		test.startTest();
		CS_DeviceModelFromPriceItem cd = new CS_DeviceModelFromPriceItem();
		cd.getRequiredAttributes();
		cd.doLookupSearch(searchFields, productDefinitionId, excludeIds, pageOffset, pageLimit);
		Integer iProdDefRecord = [SELECT count() FROM cscfga__Product_Definition__c WHERE name = 'Device' and cscfga__Description__c =  'Device'];
		System.debug('iProdDefRecord====>'+iProdDefRecord);
		System.assertEquals(1, iProdDefRecord);
		Integer iAttrDefRecord = [SELECT count() FROM cscfga__Attribute_Definition__c WHERE name = 'TypeSelected' and cscfga__Data_Type__c = 'String' and cscfga__Type__c = 'Calculation'];
		System.debug('iAttrDefRecord ====>'+iAttrDefRecord);
		System.assertEquals(1, iAttrDefRecord);
		Integer iProdConfRecord = [SELECT count() FROM cscfga__Product_Configuration__c WHERE name = 'Device'];
		System.debug('iProdConfRecord ===>'+iProdConfRecord);
		System.assertEquals(1, iProdConfRecord);
		Integer iAttrRecord = [SELECT count() FROM cscfga__Attribute__c WHERE name = 'TypeSelected'];
		System.assertEquals(1, iAttrRecord);
		Integer iPriItemRecord = [SELECT count()
		                          FROM cspmb__Price_Item__c
		                          WHERE name = 'device ucd1'
		                              AND Commercial_Product_Code__c = 'Unified Communication Device' //AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
		                              AND PI_External_Id__c = '457896122'];
		System.assertEquals(1, iPriItemRecord);
		test.stopTest();

	}

	static testmethod void test_modeldoesnotexist()
	{
		cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(name = 'Device', cscfga__Description__c = 'Device');
		insert pd;

		cscfga__Attribute_Definition__c atd = new cscfga__Attribute_Definition__c(name = 'TypeSelected', cscfga__Data_Type__c = 'String', cscfga__Type__c = 'Lookup',cscfga__Product_Definition__c = pd.id);
		insert atd;

		cscfga__Product_Configuration__c pc = new cscfga__Product_Configuration__c(name = 'Device', cscfga__Product_Definition__c = pd.id);
		insert pc;

		cscfga__Attribute__c att = new cscfga__Attribute__c(name = 'TypeSelected', cscfga__Value__c = 'IP End Point', cscfga__Product_Configuration__c = pc.id, cscfga__Attribute_Definition__c = atd.id);
		insert att;

		string productDefinitionId = pd.id;
		Map<String, String> searchFields = new Map<String, String>();
		searchFields.put('TypeSelected','IP End Point');
		Id[] excludeIds = new Id[] {};
		Integer pageOffset = 25;
		Integer pageLimit = 26;

		test.startTest();
		CS_DeviceModelFromPriceItem cd = new CS_DeviceModelFromPriceItem();
		cd.getRequiredAttributes();
		cd.doLookupSearch(searchFields, productDefinitionId, excludeIds, pageOffset, pageLimit);

		Integer iProdDefRecord = [SELECT count() FROM cscfga__Product_Definition__c WHERE name = 'Device' and cscfga__Description__c =  'Device'];
		System.debug('iProdDefRecord====>'+iProdDefRecord);
		System.assertEquals(1, iProdDefRecord);
		Integer iAttrDefRecord = [SELECT count() FROM cscfga__Attribute_Definition__c WHERE name = 'TypeSelected' and cscfga__Data_Type__c = 'String' AND cscfga__Type__c = 'Calculation'];
		System.debug('iAttrDefRecord ====>'+iAttrDefRecord);
		System.assertEquals(0, iAttrDefRecord);
		Integer iProdConfRecord = [SELECT count() FROM cscfga__Product_Configuration__c WHERE name = 'Device'];
		System.debug('iProdConfRecord ===>'+iProdConfRecord);
		System.assertEquals(1, iProdConfRecord);
		Integer iAttrRecord = [SELECT count() FROM cscfga__Attribute__c WHERE name = 'TypeSelected'];
		System.assertEquals(1, iAttrRecord);
		Integer iPriItemRecord = [SELECT count()
		                          FROM cspmb__Price_Item__c
		                          WHERE name = 'device ucd1'
		                              AND Commercial_Product_Code__c = 'Unified Communication Device' //AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
		                              AND PI_External_Id__c = '457896122'];
		System.assertEquals(0, iPriItemRecord);
		test.stopTest();

	}

}