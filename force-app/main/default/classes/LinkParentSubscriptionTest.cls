/**
 * Class for link parent subscription test.
 */
@isTest
private class LinkParentSubscriptionTest {

	/**
	 * Tests if the parent subscription id Linked from Config ID (parent selected from Basket)
	 */
	@isTest
	private static void updateParentSubscription_WillLinktheParentFromConfigId() {

		Account acc = AccountTestFactory.buildAccount('Test Account');
		csord__Order__c order = ProductTestService.getNewOrderWithMultipleServices(acc);
		cscfga__Product_Configuration__c config = [select id FROM cscfga__Product_Configuration__c where name = 'test config'];
		csord__Subscription__c parentSubs = [select id FROM csord__Subscription__c where name = 'Test Parent Subs'];

		csord__Service__c ser = [select id, csord__Subscription__c, Parent_reference__c FROM csord__Service__c where name = 'Test Service'];

		ser.Parent_reference__c = config.id;
		update ser;

		Test.startTest();
		LinkParentSubscription.updateParentSubscription(new List<ID> {order.id});
		Test.stopTest();



		csord__Subscription__c testSubs = [select id, Parent_subscription__c FROM csord__Subscription__c where name = 'Test Subscription'];
		System.assertEquals(parentSubs.id, testSubs.Parent_subscription__c);


	}

	/**
	 * Tests if the parent subscription id Linked from Subscription ID (parent selected from Existing Subscription)
	 */
	@isTest
	private static void updateParentSubscription_WillLinktheParentFromSubsId() {

		Account acc = AccountTestFactory.buildAccount('Test Account');
		csord__Order__c order = ProductTestService.getNewOrderWithMultipleServices(acc);

		csord__Subscription__c parentSubs = [select id FROM csord__Subscription__c where name = 'Test Parent Subs'];

		csord__Service__c ser = [select id, csord__Subscription__c, Parent_reference__c FROM csord__Service__c where name = 'Test Service'];

		ser.Parent_reference__c = parentSubs.id;
		update ser;

		Test.startTest();
		LinkParentSubscription.updateParentSubscription(new List<ID> {order.id});
		Test.stopTest();



		csord__Subscription__c testSubs = [select id, Parent_subscription__c FROM csord__Subscription__c where name = 'Test Subscription'];
		System.assertEquals(parentSubs.id, testSubs.Parent_subscription__c);
	}

	/**
	 * Tests no link is created if the service do not have the parent reference ID
	 */
	@isTest
	private static void updateParentSubscription_WillNotLinktheParentIfNoParentReference() {

		Account acc = AccountTestFactory.buildAccount('Test Account');
		csord__Order__c order = ProductTestService.getNewOrderWithMultipleServices(acc);

		csord__Subscription__c parentSubs = [select id FROM csord__Subscription__c where name = 'Test Parent Subs'];

		csord__Service__c ser1 = [select id, csord__Subscription__c, Parent_reference__c FROM csord__Service__c where name = 'Test Service'];

		ser1.Parent_reference__c = null;
		update ser1;

		Test.startTest();
		LinkParentSubscription.updateParentSubscription(new List<ID> {order.id});
		Test.stopTest();



		csord__Subscription__c testSubs = [select id, Parent_subscription__c FROM csord__Subscription__c where name = 'Test Subscription'];
		System.assertEquals(null, testSubs.Parent_subscription__c);
	}

	/**
	 * Tests if the parent subscription id Linked from Subscription ID (parent selected from Existing Subscription)
	 */
	@isTest
	private static void updateParentSubscription_WithBothIds() {

        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        insert acc;
        cscrm__Address__c address = AccountTestFactory.buildAddress('AddressID-1');
        insert address;
        Contact pc = AccountTestFactory.buildContact(acc, 'testPC');
        pc.Email = 'abc@bq.com';
        insert pc;
        Contact sc = AccountTestFactory.buildContact(acc, 'testSC');
        sc.Email = 'bq@abc.com';
        insert sc;

        cscrm__Site__c site = AccountTestFactory.buildSite(address.id, acc.id);
        site.Primary_Contact__c = pc.id;
        site.Secondary_Contact__c = sc.id;
        insert site;

		csord__Order__c order = ProductTestService.getNewOrderWithMultipleServices(acc);

		csord__Subscription__c parentSubs = [select id FROM csord__Subscription__c where name = 'Test Parent Subs'];

		csord__Service__c ser = [select id, csord__Subscription__c, Parent_reference__c FROM csord__Service__c where name = 'Test Service'];

		ser.Parent_reference__c = parentSubs.id;
		ser.SiteId__c = site.id;
		update ser;

		Test.startTest();
		LinkParentSubscription.updateParentSubscription(new List<ID> {order.id});
		Test.stopTest();



		csord__Subscription__c testSubs = [select id, Parent_subscription__c,Site__c FROM csord__Subscription__c where name = 'Test Subscription'];
		System.assertEquals(parentSubs.id, testSubs.Parent_subscription__c);
		System.assertEquals(site.id, testSubs.Site__c);
	}

}