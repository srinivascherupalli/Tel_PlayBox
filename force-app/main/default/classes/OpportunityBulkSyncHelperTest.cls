@isTest
private class OpportunityBulkSyncHelperTest {
	@testsetup public static void setup(){

		OpportunityTestFactory.createDataforTest();

	}

	@isTest static void test_DeleteOLIs() {
		// Implement test code
		Test.startTest();
		List<Opportunity> opptys = [SELECT Id from Opportunity];
		List<String> opptyIds = new List<String>();
		for(Opportunity opty: opptys){
			opptyIds.add(opty.Id);
		}
		OpportunityBulkSyncHelper.deleteOLI(opptyIds);
		Test.stopTest();
		List<OpportunityLineItem> oLIList = OpportunityBulkSyncHelper.getOLIlist(opptyIds);
		System.assert(oLIList.size() == 0);
	}

	@isTest static void test_FetchOLIs() {
		// Implement test code

		List<Opportunity> opptys = [SELECT Id from Opportunity];
		List<String> opptyIds = new List<String>();
		for(Opportunity opty: opptys){
			opptyIds.add(opty.Id);
		}
		Test.startTest();
		List<OpportunityLineItem> oLIList = OpportunityBulkSyncHelper.getOLIlist(opptyIds);
		Test.stopTest();

		System.assert(oLIList.size() > 0);
	}

	@isTest static void test_getConfigList(){
		List<cscfga__Product_Basket__c> baskets = [SELECT Id, Name from cscfga__Product_Basket__c];
		List<String> basketIds = new List<String>();
		for(cscfga__Product_Basket__c basket: baskets){
			basketIds.add(basket.Id);
		}

		Test.startTest();
		List<cscfga__Product_Configuration__c> configList = OpportunityBulkSyncHelper.getConfigList(basketIds);
		Test.stopTest();

		System.assert(configList.size() > 0);
		System.assert(configList.size() == 12);
		//System.debug(configList[10].Name);
		System.assert(configList[10].cscfga__Description__c == 'test Description 10');
	}

	@isTest static void test_updateOLI(){
		Test.startTest();
		List<cscfga__Product_Basket__c> baskets = [SELECT Id, Name from cscfga__Product_Basket__c];
		List<String> basketIds = new List<String>();
		for(cscfga__Product_Basket__c basket: baskets){
			basketIds.add(basket.Id);
		}
		List<Opportunity> opptys = [SELECT Id from Opportunity];
		List<String> opptyIds = new List<String>();
		for(Opportunity opty: opptys){
			opptyIds.add(opty.Id);
		}
		String queryString = 'SELECT ' + OpportunityBulkSyncHelper.getSobjectFields('cscfga__Product_Basket__c') +
            ', cscfga__opportunity__r.pricebook2.isstandard ' +
            ', (SELECT cscfga__product_definition__r.name ' +
            ', cscfga__product_definition__r.cscfga__product_category__r.name ' + ', ' +
            OpportunityBulkSyncHelper.getSobjectFields('cscfga__Product_Configuration__c') +
            ' FROM cscfga__Product_Configurations__r) ' +
            ' FROM cscfga__Product_Basket__c where id in :basketIds' ;

        List<cscfga__Product_Basket__c> productBasketList = Database.query(queryString);
        List<cscfga__Product_Configuration__c> configList = OpportunityBulkSyncHelper.getConfigList(basketIds);
        List<OpportunityLineItem> oLIList = OpportunityBulkSyncHelper.getOLIlist(opptyIds);

        Integer oldSize = oLIList.size();
		System.debug('Description'+oLIList[0].Description);
		OpportunityBulkSyncHelper.updateOLIs(productBasketList, configList, oLIList);
		Test.stopTest();

	/*	System.assert(oLIList.size() > 0);
		System.assert(oLIList.size() == oldSize);
		System.debug(oLIList[0].cscfga__Attribute__r.cscfga__Product_Configuration__c);
		System.assert(oLIList[0].Partner_Info__c!=null);
		System.assert(oLIList[0].Contract_Terms__c != null);
        System.assert(oLIList[0].SRM__c != null);
        System.assert(oLIList[0].Once_Off_Revenue__c != null);
        System.assert(oLIList[0].New_Income_Revenue__c != null);
        System.assert(oLIList[0].Quantity != null);
        system.assertEquals('Lost',oLIList[0].Product_Status__c);
        System.assert(oLIList[0].Acquisition_Revenue__c != null);
        System.assert(oLIList[0].Avg_Annualised_Revenue__c != null);
        System.assert(oLIList[0].Competitor__c != null);
        System.assert(oLIList[0].Current_Revenue__c != null);
        System.assert(oLIList[0].Incremental_Revenue__c != null);
        System.assert(oLIList[0].Domain__c != null);
        System.assert(oLIList[0].Product_Code__c != null);
        System.assert(oLIList[0].Product_Name__c != null);
        System.assert(oLIList[0].Renewal_Revenue__c != null);*/
	}

	//OpportunityBulkSyncHelper.getSobjectFields('cscfga__Product_Basket__c')
	@isTest static void test_getSobjectFields_Basket(){
		String fields = OpportunityBulkSyncHelper.getSobjectFields('cscfga__Product_Basket__c');

		System.assert(fields.contains('cscfga__Basket_Status__c'));
		System.assert(fields.contains('csordtelcoa__Basket_Stage__c'));
		System.assert(fields.contains('cscfga__Opportunity__c'));
		System.assert(fields.contains('csbb__Account__c'));
	}
	//OpportunityBulkSyncHelper.getSobjectFields('cscfga__Product_Configuration__c')
	@isTest static void test_getSobjectFields_Config(){
		String fields = OpportunityBulkSyncHelper.getSobjectFields('cscfga__Product_Configuration__c');

		System.assert(fields.contains('cscfga__Product_Basket__c'));
		System.assert(fields.contains('cscfga__Attribute_Name__c'));
		System.assert(fields.contains('cscfga__Configuration_Status__c'));
		System.assert(fields.contains('cscfga__Product_Bundle__c'));
		System.assert(fields.contains('cscfga__Product_Definition__c'));
		System.assert(fields.contains('cscfga__Recurring_Charge__c'));
	}
	//public static List<cscfga__Product_Bundle__c> createTempBundle(List<cscfga__Product_Basket__c> productBaskets)
	@isTest static void test_createTempBundle(){
		List<cscfga__Product_Basket__c> baskets = [SELECT Id, Name from cscfga__Product_Basket__c];
		List<String> basketIds = new List<String>();
		for(cscfga__Product_Basket__c basket: baskets){
			basketIds.add(basket.Id);
		}

		String queryString = 'SELECT ' + OpportunityBulkSyncHelper.getSobjectFields('cscfga__Product_Basket__c') +
            ', cscfga__opportunity__r.pricebook2.isstandard ' +
            ', (SELECT cscfga__product_definition__r.name ' +
            ', cscfga__product_definition__r.cscfga__product_category__r.name ' + ', ' +
            OpportunityBulkSyncHelper.getSobjectFields('cscfga__Product_Configuration__c') +
            ' FROM cscfga__Product_Configurations__r) ' +
            ' FROM cscfga__Product_Basket__c where id in :basketIds' ;

        List<cscfga__Product_Basket__c> productBasketList = Database.query(queryString);

        List<cscfga__Product_Bundle__c> bundles = OpportunityBulkSyncHelper.createTempBundle(productBasketList);

        //List<cscfga__Product_Configuration__c> configList = OpportunityBulkSyncHelper.getConfigList(basketIds);
        System.assert(productBasketList.size() == bundles.size());
        //System.assert(configList[0].cscfga__Product_Bundle__c != null);
        System.assert(bundles[0].cscfga__Opportunity__c != null);
        System.assert(bundles[0].cscfga__Bundle_Status__c == 'Valid');

	}

	//public static void cleanupTempBundle(List<cscfga__Product_Basket__c> productBaskets, List<cscfga__Product_Bundle__c> bundles, String basketStage)
	@isTest static void test_cleanupTempBundle(){
		List<cscfga__Product_Basket__c> baskets = [SELECT Id, Name from cscfga__Product_Basket__c];
		List<String> basketIds = new List<String>();
		for(cscfga__Product_Basket__c basket: baskets){
			basketIds.add(basket.Id);
		}

		String queryString = 'SELECT ' + OpportunityBulkSyncHelper.getSobjectFields('cscfga__Product_Basket__c') +
            ', cscfga__opportunity__r.pricebook2.isstandard ' +
            ', (SELECT cscfga__product_definition__r.name ' +
            ', cscfga__product_definition__r.cscfga__product_category__r.name ' + ', ' +
            OpportunityBulkSyncHelper.getSobjectFields('cscfga__Product_Configuration__c') +
            ' FROM cscfga__Product_Configurations__r) ' +
            ' FROM cscfga__Product_Basket__c where id in :basketIds' ;
		
        List<cscfga__Product_Basket__c> productBasketList = Database.query(queryString);
        Test.startTest();
		List<cscfga__Product_Bundle__c> bundles = OpportunityBulkSyncHelper.createTempBundle(productBasketList);
		update bundles;
		update productBasketList;

        List<cscfga__Product_Configuration__c> configList = OpportunityBulkSyncHelper.getConfigList(basketIds);
		OpportunityBulkSyncHelper.cleanupTempBundle(productBasketList, bundles, null);
		update productBasketList;
        Test.stopTest();
		List<cscfga__Product_Bundle__c> newBundles = [SELECT Id, Name from cscfga__Product_Bundle__c];
        List<cscfga__Product_Configuration__c> newconfigList = OpportunityBulkSyncHelper.getConfigList(basketIds);
		System.assert(newBundles.size() == 0);
        System.assert(newconfigList[0].cscfga__Product_Bundle__c == null);
	}

	//public static void updateOpptInfo(List<Opportunity> opps, List<cscfga__Product_Basket__c> productBaskets, String basketStage)
	@isTest static void test_updateOpptInfo(){
		List<cscfga__Product_Basket__c> baskets = [SELECT Id, Name, cscfga__Opportunity__c from cscfga__Product_Basket__c];
		List<String> basketIds = new List<String>();
		List<String> opptyIds = new List<String>();
		for(cscfga__Product_Basket__c basket: baskets){
			basketIds.add(basket.Id);
			opptyIds.add(basket.cscfga__Opportunity__c);
		}

		String queryString = 'SELECT ' + OpportunityBulkSyncHelper.getSobjectFields('cscfga__Product_Basket__c') +
            ', cscfga__opportunity__r.pricebook2.isstandard ' +
            ', (SELECT cscfga__product_definition__r.name ' +
            ', cscfga__product_definition__r.cscfga__product_category__r.name ' + ', ' +
            OpportunityBulkSyncHelper.getSobjectFields('cscfga__Product_Configuration__c') +
            ' FROM cscfga__Product_Configurations__r) ' +
            ' FROM cscfga__Product_Basket__c where id in :basketIds' ;

        List<cscfga__Product_Basket__c> productBasketList = Database.query(queryString);
        List<Opportunity> opptyList = [SELECT Id, Name, Pricebook2Id, Amount, StageName from Opportunity];
        OpportunityBulkSyncHelper.updateOpptInfo(opptyList, productBasketList, null);

        update opptyList;

        System.assert(opptyList[0].StageName != null);
        System.assert(opptyList[0].Amount == productBasketList[0].cscfga__total_contract_value__c);

	}

}