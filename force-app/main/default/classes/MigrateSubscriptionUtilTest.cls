@IsTest
private class MigrateSubscriptionUtilTest {

//gesi specific testing
public static cscfga__Product_Basket__c MOCK_PRODUCT_BASKET;
public static cscfga__Product_Definition__c MOCK_PRODUCT_DEFINITION_MAIN;
public static cscfga__Product_Definition__c MOCK_PRODUCT_DEFINITION_COMPONENT;
public static void  initProductDefination() {
	MOCK_PRODUCT_DEFINITION_MAIN = new cscfga__Product_Definition__c(
		Name = 'Ring Network',
		cscfga__Description__c = 'Ring Network',
		cscfga__Active__c = true,
		cscfga__runtime_version__c = 'v2',
		csexpimp1__guid__c = '1ead7f23-0939-478d-84f5-e6ed2186f9ce'
	);
	insert MOCK_PRODUCT_DEFINITION_MAIN;
	MOCK_PRODUCT_DEFINITION_COMPONENT = new cscfga__Product_Definition__c(
		Name = 'Site',
		cscfga__Description__c = 'Site',
		cscfga__Active__c = true,
		cscfga__runtime_version__c = 'v2',
		csexpimp1__guid__c = '99f7b1d8-359c-4791-93ac-32fa1cf6eabb'
	);
	insert MOCK_PRODUCT_DEFINITION_COMPONENT;
}

public static List<cscfga__Attribute_Definition__c> initAttributeDefinitions() {
	if (MOCK_PRODUCT_DEFINITION_MAIN == null) {
		initProductDefination();
	}
	// ----- Attribute Definition -----
cscfga__Attribute_Definition__c MOCK_ATTRIBUTE_DEFINITION_GUID = new cscfga__Attribute_Definition__c(
		Name = 'GUID',
		cscfga__Type__c = 'User Input',
		cscfga__Data_Type__c = 'String',
		cscfga__Product_Definition__c = MOCK_PRODUCT_DEFINITION_MAIN.Id
	);
	insert  MOCK_ATTRIBUTE_DEFINITION_GUID;

	return new List<cscfga__Attribute_Definition__c>{MOCK_ATTRIBUTE_DEFINITION_GUID};
}

public static List<cssdm__Solution_Definition__c> initSolutionDefinitions() {
	if (MOCK_PRODUCT_DEFINITION_MAIN == null) {
		initProductDefination();
	}
	csutil__JSON_Data__c MOCK_JSON_DATA_MAIN = new csutil__JSON_Data__c(
		Name = 'Ring Network Schema',
		csutil__value__c = '{"attributes":[{"showInUI":false,"required":false,"type":"String","name":"Type","value":"Ring Network"},{"showInUI":true,"required":true,"type":"Lookup","name":"Network Type 1","lookupClass":"RingVariantLookup","filterAttributes":"Type","columns":"Name","displayColumn":"Name"},{"showInUI":true,"required":true,"type":"Picklist","name":"Contract Term","options":["12","24","36"]},{"showInUI":true,"required":false,"type":"Calculation","name":"Min Bandwidth","columns":"Network Type","displayColumn":"cssolution_t1__Bandwidth__c"},{"showInUI":true,"required":false,"type":"String","name":"Solution Name"},{"showInUI":false,"required":false,"type":"String","name":"SolutionId"},{"showInUI":false,"required":false,"type":"String","name":"GUID"}],"journey":["one","two"],"name":"Ring Network","description":"Ring Network"}'
	);
	insert MOCK_JSON_DATA_MAIN;
	cssdm__Solution_Definition__c MOCK_SOLUTION_DEFINITION_MAIN = new cssdm__Solution_Definition__c(
		Name = 'Ring Network',
		cssdm__type__c = 'Main',
		cssdm__description__c = 'Ring Network',
		cssdm__create_pcr__c = true,
		cssdm__max__c = 1,
		cssdm__min__c = 1,
		cssdm__guid__c = 'ec7aa93f-a6f1-445c-91e0-d4eb8426824b',
		cssdm__show_add_ons__c = false,
		cssdm__schema__c = MOCK_JSON_DATA_MAIN.Id,
		cssdm__product_definition__c = MOCK_PRODUCT_DEFINITION_MAIN.Id
	);
	insert MOCK_SOLUTION_DEFINITION_MAIN;

	cssdm__Solution_Definition__c MOCK_SOLUTION_DEFINITION_COMPONENT = new cssdm__Solution_Definition__c(
		Name = 'Site',
		cssdm__type__c = 'Component',
		cssdm__description__c = 'Site',
		cssdm__main_component__c = MOCK_SOLUTION_DEFINITION_MAIN.Id,
		cssdm__create_pcr__c = false,
		cssdm__max__c = 9999,
		cssdm__guid__c = 'eafa2d87-49b8-457c-807f-8fb44193b081',
		cssdm__min__c = 0,
		cssdm__show_add_ons__c = true,
		cssdm__product_definition__c = MOCK_PRODUCT_DEFINITION_MAIN.Id
	);
	insert MOCK_SOLUTION_DEFINITION_COMPONENT;

	return new List<cssdm__Solution_Definition__c>{MOCK_SOLUTION_DEFINITION_MAIN, MOCK_SOLUTION_DEFINITION_COMPONENT};
}
public static List<cscfga__Product_Basket__c> initProductBasket() {
	// ----- Product Basket -----
	MOCK_PRODUCT_BASKET = new cscfga__Product_Basket__c(
		Name = 'Test Basket',
		cscfga__Basket_Status__c = 'Valid',
		cscfga__Products_In_Basket__c = '[Site],[Add On],[Ring Network]',
		cscfga__total_contract_value__c = 1332.00,
		cscfga__Total_Price__c = 780.00
	);
	insert MOCK_PRODUCT_BASKET;

	return new List<cscfga__Product_Basket__c>{MOCK_PRODUCT_BASKET};
}
 public static List<cscfga__Product_Configuration__c> initProductConfiguration() {
	initProductBasket();
	initProductDefination();
	// ----- Product Configuration -----
	List<cscfga__Product_Configuration__c> configList = new List<cscfga__Product_Configuration__c>();
	cscfga__Product_Configuration__c MOCK_PRODUCT_CONFIGURATION = new cscfga__Product_Configuration__c (
		Name = 'Ring Network PC',
		cscfga__Total_Price__c = 0.00,
		cscfga__Configuration_Status__c = 'Valid',
		cscfga__Description__c = 'Ring Network PC',
		cscfga__Quantity__c = 1,
		cscfga__Unit_Price__c = 0.00,
		cscfga__Product_Basket__c = MOCK_PRODUCT_BASKET.Id,
		csexpimp1__guid__c = null,
		cscfga__Key__c = '053efd9e-a34c-4b64-857e-fc6e04744ec3',
		cscfga__Recurrence_Frequency__c = 12,
		cscfga__Contract_Term__c = 36,
		cscfga__Contract_Term_Period__c = 12,
		cscfga__Product_Family__c = 'Ring Network',
		cscfga__Product_Definition__c = MOCK_PRODUCT_DEFINITION_MAIN.Id
	);
	configList.add(MOCK_PRODUCT_CONFIGURATION);
	cscfga__Product_Configuration__c MOCK_PRODUCT_CONFIGURATION_FIRST_SITE = new cscfga__Product_Configuration__c (
		Name = 'Site PC 1',
		cscfga__Total_Price__c = 276,
		cscfga__Configuration_Status__c = 'Valid',
		cscfga__Description__c = 'Site PC 1',
		cscfga__Quantity__c = 1,
		cscfga__Unit_Price__c = 276,
		cscfga__Product_Basket__c = MOCK_PRODUCT_BASKET.Id,
		csexpimp1__guid__c = null,
		cscfga__Key__c = '497687e3-a2fd-4248-8222-0cc23f1e1c9c',
		cscfga__Recurrence_Frequency__c = 12,
		cscfga__Contract_Term__c = 36,
		cscfga__Contract_Term_Period__c = 12,
		cscfga__Product_Family__c = 'Site',
		cscfga__Product_Definition__c = MOCK_PRODUCT_DEFINITION_COMPONENT.Id
	);
	configList.add(MOCK_PRODUCT_CONFIGURATION_FIRST_SITE);
	cscfga__Product_Configuration__c MOCK_PRODUCT_CONFIGURATION_SECOND_SITE = new cscfga__Product_Configuration__c (
		Name = 'Site PC 2',
		cscfga__Total_Price__c = 252,
		cscfga__Configuration_Status__c = 'Valid',
		cscfga__Description__c = 'Site PC 2',
		cscfga__Quantity__c = 2,
		cscfga__Unit_Price__c = 252,
		cscfga__Product_Basket__c = MOCK_PRODUCT_BASKET.Id,
		csexpimp1__guid__c = null,
		cscfga__Key__c = '40e81623-bfd0-4d86-a659-ad762d773e50',
		cscfga__Recurrence_Frequency__c = 12,
		cscfga__Contract_Term__c = 12,
		cscfga__Contract_Term_Period__c = 12,
		cscfga__Product_Family__c = 'Site',
		cscfga__Product_Definition__c = MOCK_PRODUCT_DEFINITION_COMPONENT.Id
	);
	configList.add(MOCK_PRODUCT_CONFIGURATION_SECOND_SITE);
	insert configList;

	return configList;
}

	@TestSetup
	static void prepareTestData() {
		//MockObjects.initCustomSettings();
		//MockObjects.initSolutionDefinitions();

		List<csord__Solution__c> solList = new List<csord__Solution__c>();
		List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
		for (Integer i = 1; i <= 5; i++) {
			csord__Solution__c sol = new csord__Solution__c();
			sol.Name = 'TSol'+ i;
			sol.csord__Identification__c = 'SI'+ i;
			solList.add(sol);
		}
		insert solList;
		csutil__JSON_Data__c jsonData = new csutil__JSON_Data__c (
			Name = 'ms-solution-fields',
			csutil__value__c = '{"maxLimit": "10","searchType": "LIKE",'+
				'"lookupColumns": "cssdm__total_contract_value__c,csord__Identification__c,csord__Status__c",'+
				'"searchFields": "name,csord__Status__c",'+
				'"tableColumns": "cssdm__total_contract_value__c,csord__Identification__c,csord__Status__c"}'
		);
		insert jsonData;
		csutil__JSON_Data__c jsonDataSubscription = new csutil__JSON_Data__c (
			Name = 'ms-subscription-fields',
			csutil__value__c = '{"maxLimit": "10","searchType": "LIKE",'+
				'"lookupColumns": "csord__total_contract_value__c,csord__Total_One_Off_Charges__c,csord__status__c",'+
				'"searchFields": "name",'+
				'"tableColumns": "csord__total_contract_value__c,csord__Total_One_Off_Charges__c"}'
		);
		insert jsonDataSubscription;
		for (Integer i = 1; i <= 5; i++) {
			csord__Subscription__c sub = new csord__Subscription__c();
			sub.Name = 'TSub'+ i;
			sub.csord__Identification__c = 'SubI'+ i;
			sub.csord__Status__c = 'Valid';
			subscriptionList.add(sub);
		}
		insert subscriptionList;
		//PD setup
		cscfga__Product_Definition__c mock_mainPd = new cscfga__Product_Definition__c(
			name = 'Main Network',
			cscfga__Description__c = 'Main Network',
			cscfga__Active__c = true,
			cscfga__runtime_version__c = 'v2',
			csexpimp1__guid__c = '1ead7f23-0939-478d-84f5-e6ed2186f9ce'
		);
		insert mock_mainPd;
		cscfga__Product_Definition__c mock_testPD = new cscfga__Product_Definition__c(
			name = 'Sub Network2',
			cscfga__Description__c = 'Sub Network2',
			cscfga__Active__c = true,
			cscfga__runtime_version__c = 'v2',
			csexpimp1__guid__c = '99f7b1d8-359c-4791-93ac-32fa1cf423aa'
		);
		insert mock_testPD;
		cscfga__Product_Definition__c strayPD = new cscfga__Product_Definition__c(
			name = 'Stray Network',
			cscfga__Description__c = 'Stray Network',
			cscfga__Active__c = true,
			cscfga__runtime_version__c = 'v2',
			csexpimp1__guid__c = '99f7b1d8-359c-4791-93ac-32fa1cf423bp'
		);
		insert strayPD;
		//JSONData
		csutil__JSON_Data__c mockJsonData = new csutil__JSON_Data__c(
			name = 'Ring Network Schema',
			csutil__value__c = ''
		);
		insert mockJsonData;
		//SD
		cssdm__Solution_Definition__c SD1 = new cssdm__Solution_Definition__c(
			name = 'SD1',
			cssdm__type__c = 'Main',
			cssdm__description__c = 'SD1',
			cssdm__guid__c = 'ec7aa93f-a6f1-445c-91e0-d4eb8426824b',
			cssdm__schema__c = mockJsonData.Id,
			cssdm__product_definition__c = mock_mainPd.Id
		);
		insert SD1;
		cssdm__Solution_Definition__c SDChild2 = new cssdm__Solution_Definition__c(
			name = 'SD-Child2',
			cssdm__type__c = 'Component',
			cssdm__description__c = 'SD-Child2',
			cssdm__guid__c = 'ec7aa93f-a6f1-445c-91e0-d4eb8426824b',
			cssdm__main_component__c = SD1.id,
			cssdm__schema__c = mockJsonData.Id,
			cssdm__product_definition__c = mock_testPD.Id
		);
		insert SDChild2;
		cssdm__Solution_Definition__c SD2 = new cssdm__Solution_Definition__c(
			name = 'SD1',
			cssdm__type__c = 'Main',
			cssdm__description__c = 'SD1',
			cssdm__guid__c = 'ec7aa93f-a6f1-445c-91e0-d4eb8426824b',
			cssdm__schema__c = mockJsonData.Id,
			cssdm__product_definition__c = strayPD.Id
		);
		insert SD2;
	}

	@isTest
	static void testSourceSolution() {
		MigrateSubscriptionUtil controller = new MigrateSubscriptionUtil();
		List<csord__Solution__c> solList = [
			select id, Name
			from csord__Solution__c
		];
		Account acc = new Account(
			Name = 'testAccount'
		);
		insert acc;
		Test.startTest();
		String response = MigrateSubscriptionUtil.getActiveSolutionList(acc.id, 'Sol');
		Test.stopTest();
		Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);

		System.AssertNotEquals(
			null,
			((List<Object>) responseMap.get('solution'))
		);
		List<String> recordNameList = new List<String>{
			'ms-solution-fields',
			'ms-subscription-fields',
			'ms-account-fields',
			'ms-solutionDefinition-fields',
			'ms-mcr-fields'
		};
		List<csutil__JSON_Data__c> jsonDataList = new List<csutil__JSON_Data__c>();
		for(String name : recordNameList){
			csutil__JSON_Data__c jsonData = new csutil__JSON_Data__c(
			Name = name,
			csutil__value__c = '{"maxLimit": "10","searchType": "LIKE",'+
				'"lookupColumns": "name",'+
				'"searchFields": "name",'+
				'"tableColumns": "name"}'
			);
			jsonDataList.add(jsonData);
		}
		Insert jsonDataList;
		MigrateSubscriptionUtil.getFieldMetadata();
	}

	@isTest
	static void testFilterSolutionName() {
		MigrateSubscriptionUtil controller = new MigrateSubscriptionUtil();
		List<csord__Solution__c> solList = [
			select id, Name
			from csord__Solution__c
		];
		Account acc = new Account(
			Name = 'testAccount'
		);
		insert acc;
		csord__Solution__c sol = new csord__Solution__c (
			Name = 'TSol6',
			csord__Identification__c = 'SI6'
		);
		insert sol;
		Test.startTest();
		String response = MigrateSubscriptionUtil.getActiveSolutionList(acc.id, 'TSol6');
		Test.stopTest();
		Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);

		System.AssertNotEquals(
			null,
			((List<Object>) responseMap.get('solution'))
		);
	}

	@isTest
	static void testReplacedSourceSolution() {
		MigrateSubscriptionUtil controller = new MigrateSubscriptionUtil();
		List<csord__Solution__c> solList = [
			select id, Name
			from csord__Solution__c
		];
		solList[4].cssdm__replaced_solution__c = solList[0].id;
		update solList[4];
		Account acc = new Account(
			Name = 'testAccount'
		);
		insert acc;
		Test.startTest();
		String response = MigrateSubscriptionUtil.getActiveSolutionList(acc.id, 'Sol');
		Test.stopTest();
		Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);

		System.AssertNotEquals(
			null,
			((List<Object>) responseMap.get('solution'))
		);
	}

	@isTest
	static void testPassingNullSearchString() {
		MigrateSubscriptionUtil controller = new MigrateSubscriptionUtil();
		List<csord__Solution__c> solList = [
			select id, Name
			from csord__Solution__c
		];
		Account acc = new Account(
			Name = 'testAccount'
		);
		insert acc;
		Test.startTest();
		String response = MigrateSubscriptionUtil.getActiveSolutionList(acc.id, '');
		Test.stopTest();
		Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);

		System.AssertNotEquals(
			null,
			((List<Object>) responseMap.get('solution'))
		);
	}

	@isTest
	static void testAllSourceSubscriptions() {
		MigrateSubscriptionUtil controller = new MigrateSubscriptionUtil();
		List<Id> idList = new List<Id>();
		List<csord__Solution__c> solList = [
			select id
			from csord__Solution__c
		];
		for (csord__Solution__c sol : solList) {
			idList.add(sol.Id);
		}
		List<csord__Subscription__c> subList = [
			select id, Name
			from csord__Subscription__c
		];
		for (csord__Subscription__c sub : subList) {
			sub.cssdm__solution_association__c = solList[0].id;
		}
		update subList;
		Test.startTest();
		String response = MigrateSubscriptionUtil.getActiveSubscriptions(idList, 'Sub', 10, 1);
		Test.stopTest();
		Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);

		System.AssertNotEquals(
			null,
			((List<Object>) responseMap.get('subscription'))
		);
	}

	@isTest
	static void testPartiallyConnectedSubscriptions() {
		MigrateSubscriptionUtil controller = new MigrateSubscriptionUtil();
		List<Id> idList = new List<Id>();
		List<csord__Solution__c> solList = [
			select id
			from csord__Solution__c
		];
		for (csord__Solution__c sol : solList) {
			idList.add(sol.Id);
		}
		List<csord__Subscription__c> subList = [
			select id, Name
			from csord__Subscription__c
		];
		subList[1].cssdm__solution_association__c = solList[0].id;
		update subList[1];
		Test.startTest();
		String response = MigrateSubscriptionUtil.getActiveSubscriptions(idList, 'Sub', 10, 1);
		Test.stopTest();
		Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);

		System.AssertNotEquals(
			null,
			((List<Object>) responseMap.get('subscription'))
		);
	}

	@isTest
	static void testSubscriptionsFilteredByStatus() {
		MigrateSubscriptionUtil controller = new MigrateSubscriptionUtil();
		List<Id> idList = new List<Id>();
		List<csord__Solution__c> solList = [
			select id
			from csord__Solution__c
		];
		for (csord__Solution__c sol : solList) {
			idList.add(sol.Id);
		}
		List<csord__Subscription__c> subList = [
			select id, Name
			from csord__Subscription__c
		];
		for (csord__Subscription__c sub : subList) {
			if (sub.Name == 'TSub1') {
				sub.csord__Status__c = 'Closed Replaced';
			}
			if (sub.Name == 'TSub2') {
				sub.csord__Status__c = 'Completed';
			}
			sub.cssdm__solution_association__c = solList[0].id;
		}
		update subList;
		Test.startTest();
		String response = MigrateSubscriptionUtil.getActiveSubscriptions(idList, 'Sub', 10, 1);
		Test.stopTest();
		Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);

		System.AssertNotEquals(null,((List<Object>) responseMap.get('subscription')));
	}

	@isTest
	static void testTargetSolution() {
		MigrateSubscriptionUtil controller = new MigrateSubscriptionUtil();
		List<csord__Solution__c> sourceSolList = new List<csord__Solution__c>();
		for (Integer i = 1; i <= 3; i++) {
			csord__Solution__c sol = new csord__Solution__c();
			sol.Name = 'SourceSol'+ i;
			sol.csord__Identification__c = 'SISource'+ i;
			sourceSolList.add(sol);
		}
		insert sourceSolList;

		List<csord__Solution__c> solList = [
			select id, Name
			from csord__Solution__c
		];
		sourceSolList.add(solList[4]);
		List<Id> idList = new List<Id>();
		for (csord__Solution__c sol : sourceSolList) {
		  idList.add(sol.Id);
		}
		Account acc = new Account(
			Name = 'testAccount'
		);
		insert acc;

		Test.startTest();
		String response = MigrateSubscriptionUtil.getTargetSolutions(idList, null, acc.id, 'Sol');
		Test.stopTest();
		Map<String, Object> desMap = (Map<String, Object>) JSON.deserializeUntyped(response);
		if (desMap.get('solutions') != null) {
			List<Object> myMapObjects = (List<Object>) desMap.get('solutions');
			System.AssertNotEquals(null, myMapObjects);
		}
	}

	@isTest
	static void testEmptyFilterTargetSolution() {
		MigrateSubscriptionUtil controller = new MigrateSubscriptionUtil();
		List<csord__Solution__c> sourceSolList = new List<csord__Solution__c>();
		for (Integer i = 1; i <= 3; i++) {
			csord__Solution__c sol = new csord__Solution__c();
			sol.Name = 'SourceSol'+ i;
			sol.csord__Identification__c = 'SISource'+ i;
			sourceSolList.add(sol);
		}
		insert sourceSolList;

		List<csord__Solution__c> solList = [
			select id, Name
			from csord__Solution__c
		];
		Account acc = new Account(
			Name = 'testAccount'
		);
		insert acc;

		Test.startTest();
		String response = MigrateSubscriptionUtil.getTargetSolutions(null, null, acc.id, '');
		Test.stopTest();
		Map<String, Object> desMap = (Map<String, Object>) JSON.deserializeUntyped(response);
		if (desMap.get('solutions') != null) {
			List<Object> myMapObjects = (List<Object>) desMap.get('solutions');
			System.AssertNotEquals(null, myMapObjects);
		}
	}

	@isTest
	static void testReplacedTargetSolution() {
		MigrateSubscriptionUtil controller = new MigrateSubscriptionUtil();
		List<csord__Solution__c> sourceSolList = new List<csord__Solution__c>();
		for (Integer i = 1; i <= 3; i++) {
			csord__Solution__c sol = new csord__Solution__c();
			sol.Name = 'SourceSol'+ i;
			sol.csord__Identification__c = 'SISource'+ i;
			sourceSolList.add(sol);
		}
		insert sourceSolList;

		List<csord__Solution__c> solList = [
			select id, Name
			from csord__Solution__c
		];
		solList[3].cssdm__replaced_solution__c = solList[0].id;
		update solList[3];
		List<Id> idList = new List<Id>();
		for (csord__Solution__c sol : sourceSolList) {
		  idList.add(sol.Id);
		}
		Account acc = new Account(
			Name = 'testAccount'
		);
		insert acc;

		Test.startTest();
		String response = MigrateSubscriptionUtil.getTargetSolutions(idList, null, acc.id, '');
		Test.stopTest();
		Map<String, Object> desMap = (Map<String, Object>) JSON.deserializeUntyped(response);
		if (desMap.get('solutions') != null) {
			List<Object> myMapObjects = (List<Object>) desMap.get('solutions');
			System.AssertNotEquals(null, myMapObjects);
		}
	}

	@isTest
	static void testReturningNullTargetSolution() {
		MigrateSubscriptionUtil controller = new MigrateSubscriptionUtil();
		List<csord__Solution__c> solList = [
			select id, Name
			from csord__Solution__c
		];
		List<Id> idList = new List<Id>();
		for (csord__Solution__c sol : solList) {
		  idList.add(sol.Id);
		}
		Account acc = new Account(
			Name = 'testAccount'
		);
		insert acc;

		Test.startTest();
		String response = MigrateSubscriptionUtil.getTargetSolutions(idList, null, acc.id, '');
		Test.stopTest();
		Map<String, Object> desMap = (Map<String, Object>) JSON.deserializeUntyped(response);
		if (desMap.get('solutions') != null) {
			List<Object> myMapObjects = (List<Object>) desMap.get('solutions');
			System.AssertEquals(0, myMapObjects.size(), 'No solutions returned');
		}
	}

	@isTest
	static void testSolutionDefinationFiltering() {
		List<cscfga__Product_Configuration__c> configList = initProductConfiguration();
		List<cssdm__Solution_Definition__c> solutionDefinitions = initSolutionDefinitions();

		cscfga__Product_Definition__c PD1 = new cscfga__Product_Definition__c(
			Name = 'Ring Network',
			cscfga__Description__c = 'Ring Network',
			cscfga__Active__c = true,
			cscfga__runtime_version__c = 'v2',
			csexpimp1__guid__c = '9ead7f23-0939-478d-84f5-e6ed2186f9ce'
		);
		insert PD1;
		cscfga__Product_Definition__c PD2 = new cscfga__Product_Definition__c(
			Name = 'Test PD',
			cscfga__Description__c = 'Test PD',
			cscfga__Active__c = true,
			cscfga__runtime_version__c = 'v2',
			csexpimp1__guid__c = '9ead7f23-0939-478d-84f5-e6ed2186f94e'
		);
		insert PD2;
		solutionDefinitions[0].cssdm__product_definition__c = PD1.Id;
		update solutionDefinitions[0];
		solutionDefinitions[1].cssdm__product_definition__c = PD2.Id;
		update solutionDefinitions[1];
		List<csord__Solution__c> sourceSolList = new List<csord__Solution__c>();
		for (Integer i = 1; i <= 3; i++) {
			csord__Solution__c sol = new csord__Solution__c();
			sol.Name = 'SourceSol'+ i;
			sol.csord__Identification__c = 'SISource'+ i;
			sol.cssdm__solution_definition__c = solutionDefinitions[0].id;
			sourceSolList.add(sol);
		}
		insert sourceSolList;

		List<Id> idList = new List<Id>();
		for (csord__Solution__c sol : sourceSolList) {
			idList.add(sol.Id);
		}
		List<csord__Solution__c> solList = [
			select id, Name
			from csord__Solution__c
		];
		for (csord__Solution__c sol : solList) {
			if (sol.name == 'TSol1') {
				sol.cssdm__solution_definition__c = solutionDefinitions[1].id;
			}else {
				sol.cssdm__solution_definition__c = solutionDefinitions[0].id;
			}
		}
		update solList;
		List<csord__Subscription__c> subList = [
			select id, Name
			from csord__Subscription__c
		];
		List<Id> subIdList = new List<Id>();
		for (csord__Subscription__c sub : subList) {
			sub.cssdm__solution_association__c = solList[0].id;
			subIdList.add(sub.Id);
		}
		update subList;
		csord__Service__c service1 = new csord__Service__c(
			Name = 'Test Service',
			csord__Identification__c = 'Service_0',
			csord__Status__c = 'Service created',
			csord__Subscription__c = subIdList[0]
		);
		insert service1;
		for (cscfga__Product_Configuration__c pc : configList) {
			pc.cscfga__Product_Definition__c = PD1.id;
		}
		update configList;
		Account acc = new Account(
			Name = 'testAccount'
		);
		insert acc;
		Test.startTest();
		MigrateSubscriptionUtil.OSInstance = new OSModuleConnector();
		String response = MigrateSubscriptionUtil.getTargetSolutions(
			idList,
			subIdList,
			acc.id,
			'Sol'
		);
		Test.stopTest();
		Map<String, Object> desMap = (Map<String, Object>) JSON.deserializeUntyped(response);
		if (desMap.get('solutions') != null) {
			List<Object> myMapObjects = (List<Object>) desMap.get('solutions');
			System.AssertNotEquals(null, myMapObjects);
		}
	}

	@isTest
	static void testLinkingSubs() {
		MigrateSubscriptionUtil controller = new MigrateSubscriptionUtil();
		List<cscfga__Product_Configuration__c> configList = initProductConfiguration();
		List<cscfga__Product_Basket__c> basketList = initProductBasket();
		List<cscfga__Attribute_Definition__c> attributeDefList = initAttributeDefinitions();

		configList[0].cscfga__Product_Basket__c = basketList[0].Id;
		configList[1].cscfga__Product_Basket__c = basketList[0].Id;
		update configList;

		cscfga__Attribute__c guidAttribute = new cscfga__Attribute__c (
			Name = 'GUID',
			cscfga__Product_Configuration__c = configList[0].Id,
			cscfga__Discount_Type__c = 'amount',
			cscfga__Attribute_Definition__c = attributeDefList[0].Id,
			cscfga__value__c = '12345367-be95-4e67-6c0c-72f911e6533a'
		);
		insert guidAttribute;
		cscfga__Attribute__c guidAttribute2 = new cscfga__Attribute__c (
			Name = 'GUID',
			cscfga__Product_Configuration__c = configList[1].Id,
			cscfga__Attribute_Definition__c = attributeDefList[0].Id,
			cscfga__value__c = '12345367-be95-4e67-6c0c-72f911e6533a'
		);
		insert guidAttribute2;

		Migration_Change_Request__c mcr = new Migration_Change_Request__c(
			Name = 'MCR1',
			macd_basket_ids__c = basketList[0].Id
		);
		insert mcr;
		Test.startTest();
		MigrateSubscriptionUtil.OSInstance = new OSModuleConnector();
		String response = MigrateSubscriptionUtil.linkSubscriptionsAfterMigration(mcr.id);
		Test.stopTest();
		System.AssertEquals('Updated successfully', response ,
			'Valid scenario when both incoming and outgoing subscriptions have same guid');

	}

	@isTest
	static void testValidateMCR() {
		MigrateSubscriptionUtil controller = new MigrateSubscriptionUtil();
		List<cscfga__Product_Configuration__c> configList = initProductConfiguration();
		List<cscfga__Product_Basket__c> basketList = initProductBasket();
		List<cscfga__Attribute_Definition__c> attributeDefList = initAttributeDefinitions();

		configList[0].cscfga__Product_Basket__c = basketList[0].Id;
		configList[1].cscfga__Product_Basket__c = basketList[0].Id;
		update configList;

		cscfga__Attribute__c guidAttribute = new cscfga__Attribute__c (
			Name = 'GUID',
			cscfga__Product_Configuration__c = configList[0].Id,
			cscfga__Discount_Type__c = 'amount',
			cscfga__Attribute_Definition__c = attributeDefList[0].Id,
			cscfga__value__c = '12345367-be95-4e67-6c0c-72f911e6533a'
		);
		insert guidAttribute;

		cscfga__Attribute__c guidAttribute2 = new cscfga__Attribute__c (
			Name = 'GUID',
			cscfga__Product_Configuration__c = configList[1].Id,
			cscfga__Attribute_Definition__c = attributeDefList[0].Id,
			cscfga__value__c = '12345367-be95-4e67-6c0c-72f911e6533a'
		);
		insert guidAttribute2;

		List<csord__Subscription__c> subscriptionList = [
			select id, name
			from csord__Subscription__c
		];

		Opportunity opp = new Opportunity(
			Name = 'Opp1',
			StageName = 'Open',
			CloseDate = system.today()
		);
		insert opp;

		for (cscfga__Product_Basket__c basket : basketList) {
			basket.cscfga__Opportunity__c = opp.id;
			basket.csbb__Synchronised_With_Opportunity__c = true;
			basket.csordtelcoa__Synchronised_with_Opportunity__c = true;
		}
		update basketList;

		Migration_Change_Request__c mcr = new Migration_Change_Request__c(
			Name = 'MCR1',
			macd_basket_ids__c = basketList[0].Id,
			selected_subscription_ids__c = subscriptionList[0].id
		);
		insert mcr;

		Test.startTest();
		MigrateSubscriptionUtil.OSInstance = new OSModuleConnector();
		String response = MigrateSubscriptionUtil.validateMCR(mcr.id);
		Test.stopTest();
		Opportunity result = [Select id,name,StageName from Opportunity];
		System.AssertEquals('Closed', result.StageName, 'Updated opportunity to closed');

	}

	@isTest
	static void testFetchMCRData() {
		List<csord__Solution__c> solutionList = [
			select id, name
			from csord__Solution__c
		];
		List<Id> solId = new List<Id>();
		for (csord__Solution__c sol : solutionList) {
			solId.add(sol.id);
		}
		List<csord__Subscription__c> subscriptionList = [
			select id, name
			from csord__Subscription__c
		];
		List<Id> subId = new List<Id>();
		for (csord__Subscription__c sub : subscriptionList) {
			subId.add(sub.id);
		}
		Test.startTest();
		String response = MigrateSubscriptionUtil.getFieldTableSolutionList(solId);
		Test.stopTest();
		List<csord__Solution__c> responseList = (List<csord__Solution__c>) JSON.deserialize(
			response,
			List<csord__Solution__c>.class
		);

		System.AssertEquals(5, responseList.size());
	}

	@isTest
	static void testFieldTableSubscriptionList() {
		List<csord__Subscription__c> subscriptionList = [
			select id, name
			from csord__Subscription__c
		];
		List<String> subIds = new List<String>();
		for (csord__Subscription__c sub : subscriptionList) {
			subIds.add(sub.id);
		}
		Test.startTest();
		String response = MigrateSubscriptionUtil.getFieldTableSubscriptionList(subIds);
		Test.stopTest();
		Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);

		System.AssertEquals(5, ((List<Object>) responseMap.get('subscription')).size());
	}

	@isTest
	static void testTargetCompatibleSolution() {
		List<csord__Subscription__c> subscriptionList = [
			select id, name
			from csord__Subscription__c
		];
		List<String> subIds = new List<String>();
		for (csord__Subscription__c sub : subscriptionList) {
			subIds.add(sub.id);
		}
		csord__Service__c service1 = new csord__Service__c(
			name = 'Test Service',
			csord__Identification__c = 'Service_0',
			csord__Status__c = 'Service created',
			csord__Subscription__c = subIds[0]
		);
		insert service1;

		List<cscfga__Product_Definition__c> pdList = [
			select id, name
			from cscfga__Product_Definition__c
		];
		List<csutil__JSON_Data__c> jsonData = [select id, name from csutil__JSON_Data__c];
		List<cscfga__Product_Basket__c> basketList = initProductBasket();
		cscfga__Product_Configuration__c mockConfig = new cscfga__Product_Configuration__c (
			name = 'Ring Network PC',
			cscfga__Configuration_Status__c = 'Valid',
			cscfga__Description__c = 'Ring Network PC',
			cscfga__Product_Basket__c = basketList[0].Id,
			cscfga__Key__c = '053efd9e-a34c-4b64-857e-fc6e04744ec3',
			cscfga__Product_Family__c = 'Ring Network',
			cscfga__Product_Definition__c = pdList[1].Id
		);
		insert mockConfig;

		Test.startTest();
		MigrateSubscriptionUtil.OSInstance = new OSModuleConnector();
		List<Id> response = MigrateSubscriptionUtil.checkSolutionCompatibility(subIds);
		Test.stopTest();

		System.AssertNotEquals(null, response);
	}

	@isTest
	static void testNonCompatibleTargetSolution() {
		List<csord__Subscription__c> subscriptionList = [
			select id, name
			from csord__Subscription__c
		];
		List<String> subIds = new List<String>();
		for (csord__Subscription__c sub : subscriptionList) {
			subIds.add(sub.id);
		}
		csord__Service__c service1 = new csord__Service__c(
			name = 'Test Service',
			csord__Identification__c = 'Service_0',
			csord__Status__c = 'Service created',
			csord__Subscription__c = subIds[0]
		);
		insert service1;

		List<cscfga__Product_Definition__c> pdList = [
			select id, name
			from cscfga__Product_Definition__c
		];
		List<csutil__JSON_Data__c> jsonData = [select id, name from csutil__JSON_Data__c];
		List<cscfga__Product_Basket__c> basketList = initProductBasket();
		cscfga__Product_Configuration__c mockConfig = new cscfga__Product_Configuration__c (
			name = 'Ring Network PC',
			cscfga__Configuration_Status__c = 'Valid',
			cscfga__Description__c = 'Ring Network PC',
			cscfga__Product_Basket__c = basketList[0].Id,
			cscfga__Key__c = '053efd9e-a34c-4b64-857e-fc6e04744ec3',
			cscfga__Product_Family__c = 'Ring Network',
			cscfga__Product_Definition__c = pdList[1].Id
		);
		insert mockConfig;
		cscfga__Product_Configuration__c strayConfig = new cscfga__Product_Configuration__c (
			name = 'Stray PC',
			cscfga__Configuration_Status__c = 'Valid',
			cscfga__Description__c = 'Stray PC',
			cscfga__Product_Basket__c = basketList[0].Id,
			cscfga__Key__c = '053efd9e-a34c-4b64-857e-fc6e04742323',
			cscfga__Product_Family__c = 'Ring Network',
			cscfga__Product_Definition__c = pdList[2].Id
		);
		insert strayConfig;

		Test.startTest();
		MigrateSubscriptionUtil.OSInstance = new OSModuleConnector();
		List<Id> response = MigrateSubscriptionUtil.checkSolutionCompatibility(subIds);
		Test.stopTest();

		System.AssertnotEquals(null, response);
		String guids = MigrateSubscriptionUtil.getSubscriptionGuids(subIds);
	}
	@isTest
	static void testOSModuleConnectorMock() {
		Opportunity opp = new Opportunity(
			Name = 'Opp1',
			StageName = 'Open',
			CloseDate = system.today()
		);
		insert opp;
		List<csord__Subscription__c> subscriptionList = [
			select id, name
			from csord__Subscription__c
		];
		List<String> subIds = new List<String>();
		for (csord__Subscription__c sub : subscriptionList) {
			subIds.add(sub.id);
		}
		csord__Service__c service1 = new csord__Service__c(
			name = 'Test Service',
			csord__Identification__c = 'Service_0',
			csord__Status__c = 'Service created',
			csord__Subscription__c = subIds[0]
		);
		insert service1;

	  List<cscfga__Product_Basket__c> basketList = initProductBasket();
	  Map<Id,String> guidmap = new Map<Id,String>();
	  
	  List<Id> bList = new List<Id>();
		for(cscfga__Product_Basket__c pb : basketList){
			bList.add(pb.id);
			guidmap.put(pb.id,pb.id);
		}
		guidmap.put(service1.id,service1.id);
		OSModuleConnectorMock.getPCList(bList);
		OSModuleConnectorMock.getSubList(null,null);
		OSModuleConnectorMock.getSubscriptionMap(subscriptionList,guidmap);
		OSModuleConnectorMock.getBaskets(bList);
		OSModuleConnectorMock.getSubscriptionsList(null);
		OSModuleConnectorMock.getAttributeList(null);
		OSModuleConnectorMock.checkSourceValid(null,null);
		OSModuleConnectorMock.getTargetGUIDList(null);
		OSModuleConnectorMock.createEmptyMacBasketRecord(null,null);
		OSModuleConnectorMock.createEmptyMacOppRecord(null,null);
		OSModuleConnectorMock.updateBasketAccount(null,null,null);
		OSModuleConnectorMock.getPCIds(null);
		OSModuleConnectorMock.getServiceList(null);
		OSModuleConnectorMock.getServicePCIds(null);
		MigrateSubscriptionException mtg = new MigrateSubscriptionException();
		Map<String,Object> inputMap = new Map<String,Object>();
		MigrateSubscriptionAccounts msA = new MigrateSubscriptionAccounts();
		msA.executeLogic(inputMap);
		MigrateSubscriptionCustomLogic msC = new MigrateSubscriptionCustomLogic();
		msC.executeLogic(inputMap);
	}
	@isTest
	static void testLinkMigrateSubs() {
		List<Account> accLst= new List<Account>();
		Account accOut = new Account();
		accOut.name = 'Test CHOWN Outgoing Account';
		accLst.add(accOut);
		
		Account accIn = new Account();
		accIn.name = 'Test CHOWN Incoming Account';
		accLst.add(accIn);
		insert accLst;
		
		List<Opportunity> opptyLst= new List<Opportunity>();
		Opportunity opptyOut = new Opportunity();
		opptyOut.Account = accOut;
		opptyOut.name = 'Test CHOWN Outgoing Oppty';
		opptyOut.StageName = 'Propose';
		opptyOut.CloseDate = System.today()+1;
		opptyLst.add(opptyOut);
		
		Opportunity opptyIn = new Opportunity();
		opptyIn.Account = accIn;
		opptyIn.name = 'Test CHOWN Incoming Oppty';
		opptyIn.StageName = 'Propose';
		opptyIn.CloseDate = System.today()+1;
		opptyLst.add(opptyIn);
		insert opptyLst;
		
		List<cscfga__Product_Basket__c> basketLst= new List<cscfga__Product_Basket__c>();
		cscfga__Product_Basket__c basketOut = new cscfga__Product_Basket__c();
		basketOut.name = 'Test CHOWN Outgoing Basket';
		basketOut.BasketType__c = 'Outgoing';
		basketOut.csordtelcoa__Basket_Stage__c = 'Enriched';
		basketOut.csbb__Account__c = accOut.id;
		basketOut.cscfga__Opportunity__c = opptyOut.id;
		basketLst.add(basketOut);
		
		cscfga__Product_Basket__c basketIn = new cscfga__Product_Basket__c();
		basketIn.name = 'Test CHOWN Outgoing Basket';
		basketIn.BasketType__c = 'Incoming';
		basketIn.csordtelcoa__Basket_Stage__c = 'Enriched';
		basketIn.csbb__Account__c = accIn.id;
		basketIn.cscfga__Opportunity__c = opptyIn.id;
		basketLst.add(basketIn);
		insert basketLst;
		
		csord__Solution__c sol = new csord__Solution__c (
			Name = 'TSol6',
			csord__Identification__c = 'SI6',
			cssdm__product_basket__c = basketLst[0].id
		);
		insert sol;
		
		List<csord__Subscription__c> subList = new List<csord__Subscription__c>();  
		csord__Subscription__c subOut = new csord__Subscription__c();
		subOut.csord__Identification__c = 'Subscription_1';
		subOut.name = 'Test Outgoing Subscription';
		subOut.csordtelcoa__Replacement_Subscription__c = null;
		subout.cssdm__solution_association__c = sol.id;
		subout.csord__Account__c = accOut.id;
		subList.add(subOut);
		
		csord__Subscription__c subIn = new csord__Subscription__c();
		subIn.csord__Identification__c = 'Subscription_2';
		subIn.name = 'Test Incoming Subscription';
		subIn.csordtelcoa__Replaced_Subscription__c = null;
		subIn.cssdm__solution_association__c = sol.id;
		subin.csord__Account__c = accIn.id;
		subList.add(subIn);
		insert subList;
		
		List<Migration_Change_Request__c> mcrLst = new List<Migration_Change_Request__c>();
		Migration_Change_Request__c mcr = new Migration_Change_Request__c();
		mcr.migration_status__c = 'Completed';
		String basketOutId = basketOut.id;
		String basketInId = basketIn.id;
		String basketMACId = basketOutId+','+basketInId;
		mcr.macd_basket_ids__c = basketMACId;
		mcr.target_account__c = accIn.id;
		mcr.account_id__c = accOut.id;
		mcrLst.add(mcr);
		insert mcrLst;
		Map<Id, csord__Subscription__c> subMap = new Map<Id, csord__Subscription__c>([SELECT Id FROM csord__Subscription__c]);
		List<Id> subscriptionIds = new List<Id>(subMap.keySet());
		LinkMigrateSubscriptionObserver observer = new LinkMigrateSubscriptionObserver();
		csordtelcoa.OrderGenerationObservable o = new csordtelcoa.OrderGenerationObservable('LinkMigrateSubscriptionObserver',null,null,subscriptionIds,null,null,null,null,null,null);
		observer.execute(o, null);
	}

	@isTest
	static void testGetAccountList(){
		csutil__JSON_Data__c jsonData = new csutil__JSON_Data__c(
			Name = 'ms-account-fields',
			csutil__value__c = '{"maxLimit": "10","searchType": "LIKE",'+
				'"lookupColumns": "name,Type,CIDN__c",'+
				'"searchFields": "name,Type,CIDN__c",'+
				'"tableColumns": "name,Type,CIDN__c,IsPartner"}'
			);
		Insert jsonData;
		
		Account accid = new Account(name = 'Test CHOWN Incoming Account');
		insert accid;
		
		Map<String, Object> solutionDefMap = (Map<String, Object>) JSON.deserializeUntyped( MigrateSubscriptionUtil.getAccountList(accid.id,'test'));
		System.AssertEquals(2,solutionDefMap.size());
	}

	@IsTest
	static void testGetCompatibleSolutions(){
		csutil__JSON_Data__c jsonData = new csutil__JSON_Data__c(
			Name = 'ms-solutionDefinition-fields',
			csutil__value__c = '{"maxLimit": "10","searchType": "LIKE",'+
				'"lookupColumns": "name",'+
				'"searchFields": "name",'+
				'"tableColumns": "name"}'
			);
		Insert jsonData;
		jsonData = new csutil__JSON_Data__c(
			Name = 'ms-account-fields',
			csutil__value__c = '{"maxLimit": "10","searchType": "LIKE",'+
				'"lookupColumns": "name,Type,CIDN__c",'+
				'"searchFields": "name,Type,CIDN__c",'+
				'"tableColumns": "name,Type,CIDN__c,IsPartner"}'
			);
		Insert jsonData;
		
		prepareTestData();
		csord__Solution__c solution = [ Select id from csord__Solution__c Limit 1 ];
		List<Id> solutions = new List<Id>();
		solutions.add(solution.id);
		Map<String, Object> solutionDefMap = (Map<String, Object>) JSON.deserializeUntyped( MigrateSubscriptionUtil.getCompatibleSolutions(solutions ,'test'));
		System.AssertEquals(2,solutionDefMap.size());
	}
}