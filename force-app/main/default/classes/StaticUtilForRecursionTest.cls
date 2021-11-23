@isTest
private class StaticUtilForRecursionTest {
	
	@isTest static void testRunOnceBeforeUpdatePCR() {
		Boolean value = false;
		Boolean secondValue = false;
		Test.startTest();
		value = StaticUtilForRecursion.runOnceBeforeUpdatePCR();
		secondValue = StaticUtilForRecursion.runOnceBeforeUpdatePCR();
		Test.stopTest();

		System.assertEquals(value, true);
		System.assertEquals(secondValue, false);
	}

	@isTest static void testRunOnceAfterInsertPCR() {
		Boolean value = false;
		Boolean secondValue = false;
		Test.startTest();
		value = StaticUtilForRecursion.runOnceAfterInsertPCR();
		secondValue = StaticUtilForRecursion.runOnceAfterInsertPCR();
		Test.stopTest();

		System.assertEquals(value, true);
		System.assertEquals(secondValue, false);
	}

	@isTest static void testrunOnceAfterUpdateBasket() {
		Boolean value = false;
		Boolean secondValue = false;
		Test.startTest();
		value = StaticUtilForRecursion.runOnceAfterUpdateBasket();
		secondValue = StaticUtilForRecursion.runOnceAfterUpdateBasket();
		Test.stopTest();

		System.assertEquals(value, true);
		System.assertEquals(secondValue, false);
	}

	@isTest static void testrunAutoSyncOnce() {
		Boolean value = false;
		Boolean secondValue = false;

		Test.startTest();
		value = StaticUtilForRecursion.runAutoSyncOnce();
		StaticUtilForRecursion.autoSyncRunFlag = false;
		secondValue = StaticUtilForRecursion.runAutoSyncOnce();
		Test.stopTest();

		System.assertEquals(value, true);
		System.assertEquals(secondValue, false);
	}

@isTest static void testrunOnceContactRoleupdate() {
		Boolean value = false;
		Boolean secondValue = false;

		Test.startTest();
		value = StaticUtilForRecursion.runOnceContactRoleupdate();
		secondValue = StaticUtilForRecursion.runOnceContactRoleupdate();
		Test.stopTest();

		System.assertEquals(value, true);
		System.assertEquals(secondValue, false);
	}
    
@isTest static void testrunOnceCheckOfferReference() {
		Boolean value = false;
		Boolean secondValue = false;

		Test.startTest();
		value = StaticUtilForRecursion.runOnceCheckOfferReference();
		secondValue = StaticUtilForRecursion.runOnceCheckOfferReference();
		Test.stopTest();

		System.assertEquals(value, true);
		System.assertEquals(secondValue, false);
	}   
    
@isTest static void testrunUpdateChargeLineItemWithPC() {
		Boolean value = false;
		Boolean secondValue = false;

		Test.startTest();
		value = StaticUtilForRecursion.runUpdateChargeLineItemWithPC();
		secondValue = StaticUtilForRecursion.runUpdateChargeLineItemWithPC();
		Test.stopTest();

		System.assertEquals(value, true);
		System.assertEquals(secondValue, false);
	}
    
@isTest static void testupdateOpportunityDetailsInsertUpdate() {
		Boolean value = false;
		Boolean secondValue = false;

		Test.startTest();
		value = StaticUtilForRecursion.updateOpportunityDetailsInsertUpdate();
		secondValue = StaticUtilForRecursion.updateOpportunityDetailsInsertUpdate();
		Test.stopTest();

		System.assertEquals(value, true);
		System.assertEquals(secondValue, false);
	}
    
@isTest static void testdeleteOLIsProductDetailsAfterUpdate() {
		Boolean value = false;
		Boolean secondValue = false;

		Test.startTest();
		value = StaticUtilForRecursion.deleteOLIsProductDetailsAfterUpdate();
		secondValue = StaticUtilForRecursion.deleteOLIsProductDetailsAfterUpdate();
		Test.stopTest();

		System.assertEquals(value, true);
		System.assertEquals(secondValue, false);
	}
    
@isTest static void testupdateOpportunityDetails() {
		Boolean value = false;
		Boolean secondValue = false;

		Test.startTest();
		value = StaticUtilForRecursion.updateOpportunityDetails();
		secondValue = StaticUtilForRecursion.updateOpportunityDetails();
		Test.stopTest();

		System.assertEquals(value, true);
		System.assertEquals(secondValue, false);
	}
}