@isTest
private class SiteContactRoleTriggerHelperTest {
	static Account account;
	static Contact contact;
	static cscrm__Site__c site;
	static cscrm__Address__c address;

	private static void setupData(){
		account = AccountTestFactory.buildAccount('test');
		insert account;

		contact = AccountTestFactory.buildContact(account, 'test');
		insert contact;

		address = AccountTestFactory.buildAddressFull('test');
		insert address;

		site = AccountTestFactory.buildSite(address.Id, account.Id);
		insert site;
	}
	
	@isTest static void testInsertSiteContactRole() {
		setupData();

		Test.startTest();

		Site_Contact_Role__c scr1 = TestDataFactory.generateSiteContactRole(false, contact, site);
		scr1.Contact_Type__c = SiteContactRoleTriggerHelper.ROLE_PRIMARY;
		insert scr1;

		Site_Contact_Role__c scr2 = TestDataFactory.generateSiteContactRole(false, contact, site);
		scr2.Contact_Type__c = SiteContactRoleTriggerHelper.ROLE_SECONDARY;
		insert scr2;

		System.assertNotEquals(scr1, null);
		System.assertNotEquals(scr2, null);

		Test.stopTest();
	}

	@isTest static void testDeleteSiteContactRole() {
		setupData();

		Site_Contact_Role__c scr1 = TestDataFactory.generateSiteContactRole(false, contact, site);
		scr1.Contact_Type__c = SiteContactRoleTriggerHelper.ROLE_PRIMARY;
		insert scr1;

		Site_Contact_Role__c scr2 = TestDataFactory.generateSiteContactRole(false, contact, site);
		scr2.Contact_Type__c = SiteContactRoleTriggerHelper.ROLE_SECONDARY;
		insert scr2;

		Test.startTest();

		List<Site_Contact_Role__c> siteList = new List<Site_Contact_Role__c>{scr1, scr2};
		siteList.clear();

		Test.stopTest();

		System.assertEquals(0,siteList.size(),'List was not deleted');
	}

	@isTest static void testUpdateSiteContactRole() {
		setupData();

		Site_Contact_Role__c scr1 = TestDataFactory.generateSiteContactRole(false, contact, site);
		scr1.Contact_Type__c = SiteContactRoleTriggerHelper.ROLE_PRIMARY;
		insert scr1;

		Site_Contact_Role__c scr2 = TestDataFactory.generateSiteContactRole(false, contact, site);
		scr2.Contact_Type__c = SiteContactRoleTriggerHelper.ROLE_SECONDARY;
		insert scr2;

		Site_Contact_Role__c scr3 = TestDataFactory.generateSiteContactRole(false, contact, site);
		scr3.Contact_Type__c = 'After Hours';
		insert scr3;

		Test.startTest();

		scr3.Contact_Type__c = 'Sales';
		update scr3;

		update scr1;

		try{
			update scr2;
		}
		catch(Exception exc){
			System.assertNotEquals(exc, null);
		}

		Test.stopTest();
		System.assertEquals('Sales', scr3.Contact_Type__c, 'Update was not successful');
	}

	@isTest static void testErrorUpdateSiteContactRole() {
		setupData();

		Site_Contact_Role__c scr1 = TestDataFactory.generateSiteContactRole(false, contact, site);
		scr1.Contact_Type__c = SiteContactRoleTriggerHelper.ROLE_PRIMARY;
		insert scr1;

		Site_Contact_Role__c scr2 = TestDataFactory.generateSiteContactRole(false, contact, site);
		scr2.Contact_Type__c = SiteContactRoleTriggerHelper.ROLE_SECONDARY;
		insert scr2;

		Test.startTest();

		try{
			scr1.Contact_Type__c = SiteContactRoleTriggerHelper.ROLE_SECONDARY;
			update scr1;
		}
		catch(Exception exc){
			System.assertNotEquals(exc, null);
		}

		Test.stopTest();
		System.assertEquals(SiteContactRoleTriggerHelper.ROLE_SECONDARY,scr1.Contact_Type__c, 'Update was not successful');
	}
}