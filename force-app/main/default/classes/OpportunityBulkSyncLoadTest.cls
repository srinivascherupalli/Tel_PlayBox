@isTest (seeAllData=true) //seeAllData is set to true to ensure cscfga.API_1.syncBundleToOpportunity
private class OpportunityBulkSyncLoadTest{

	@isTest
	static void test_BulkSyncOpportunity(){
		
		/*
		OpportunityBulkSyncDataSetup.testDataSetup();

		List<cscfga__Product_Basket__c> basketList = [SELECT Id, Name, cscfga__Opportunity__c
            										 FROM cscfga__Product_Basket__c WHERE Name LIKE 'Test Basket BulkSync %'];

		List<cscfga__Product_Basket__c> basketList1 = new List<cscfga__Product_Basket__c>();
		System.debug(basketList);
		
		Test.startTest();
			for(Integer z = 0; z < 1; z++){
				basketList1.add(basketList[z]);
			}
			
			OpportunityBulkSyncUtility.syncWithOpportunity(basketList1, '');
		Test.stopTest();

		List<cscfga__Product_Basket__c> syncbasketList = [SELECT cscfga__Opportunity__c
            										 FROM cscfga__Product_Basket__c WHERE Name LIKE 'Test Basket BulkSync %' and csordtelcoa__Synchronised_with_Opportunity__c = true];
        List<Id> opptyIds = new List<Id>();
        for(cscfga__Product_Basket__c pb: syncbasketList){
        	opptyIds.add(pb.cscfga__Opportunity__c);
        	System.debug('<><> pb.cscfga__Opportunity__c == ' + pb.cscfga__Opportunity__c);
        }
		List<OpportunityLineItem> opptyItemList = [SELECT Id, Name from OpportunityLineItem where OpportunityId IN :opptyIds];
		//List<OpportunityProduct> lstProd2 = [select Id, Name from OpportunityProduct];// where Opportunity IN :opptyIds];
        List<Opportunity> opptyList = [SELECT Id, Name, StageName from Opportunity where Id IN :opptyIds];
		System.debug('<><> opptyItemList == ' + opptyItemList);
		System.debug('<><> opptyList' + opptyList);
		System.assert(syncbasketList.size() > 0);
		*/
	}
}