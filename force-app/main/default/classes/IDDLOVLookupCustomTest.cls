@isTest 
private class IDDLOVLookupCustomTest {
	@TestSetup
	private static void testSetup()
	{	    
		Product_Attribute_LOV__c testLOV1 = new Product_Attribute_LOV__c();
		testLOV1.Name = 'InternationalDirectDialIn';
		testLOV1.Value__c = '45';

		Product_Attribute_LOV__c testLOV2 = new Product_Attribute_LOV__c();
		testLOV2.Name = 'InternationalDirectDialIn';
		testLOV2.Value__c = '30';

		Product_Attribute_LOV__c testLOV3 = new Product_Attribute_LOV__c();
		testLOV3.Name = 'InternationalDirectDialIn';
		testLOV3.Value__c = '15';
		List<Product_Attribute_LOV__c> testList = new List<Product_Attribute_LOV__c> {testLOV1,testLOV2,testLOV3};
		insert testList;
	}
	@isTest
	private static void testDoLookupSearch45() {
		Map<String,String> testStringStringMap = new Map<String, String> {'MobilityPlanSelected'=>'L', 'searchValue'=>''};

	    IDDLOVLookupCustom classInit = new IDDLOVLookupCustom();
		Test.startTest();
		List<Object> res1 = classInit.doLookupSearch(testStringStringMap, '', null, 0, 0);
		Test.stopTest();

		System.assertNotEquals(true, res1.isEmpty());
	}

	@isTest
	private static void testDoLookupSearch30() {
		Map<String,String> testStringStringMap = new Map<String, String> {'MobilityPlanSelected'=>'M', 'searchValue'=>''};

	    IDDLOVLookupCustom classInit = new IDDLOVLookupCustom();
		Test.startTest();
		List<Object> res1 = classInit.doLookupSearch(testStringStringMap, '', null, 0, 0);
		Test.stopTest();

		System.assertNotEquals(true, res1.isEmpty());
	}

	@isTest
	private static void testDoLookupSearch15() {
		Map<String,String> testStringStringMap = new Map<String, String> {'MobilityPlanSelected'=>'S', 'searchValue'=>''};

	    IDDLOVLookupCustom classInit = new IDDLOVLookupCustom();
		Test.startTest();
		List<Object> res1 = classInit.doLookupSearch(testStringStringMap, '', null, 0, 0);
		Test.stopTest();

		System.assertNotEquals(true, res1.isEmpty());
	}

	@IsTest
	private static void testGetRequiredAttributes()
	{
		IDDLOVLookupCustom classInit = new IDDLOVLookupCustom();
		
		Test.startTest();
		String res1 = classInit.getRequiredAttributes();
		Test.stopTest();

		System.assertNotEquals('', res1);
	}
}