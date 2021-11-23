global class OpportunityBulkSyncBatchable implements Database.Batchable<sObject> {
	
	//made public for test class
    public String query = 'SELECT Id, cscfga__Opportunity__c, csordtelcoa__Synchronised_with_Opportunity__c FROM cscfga__Product_Basket__c WHERE cscfga__Opportunity__c != null AND csordtelcoa__Synchronised_with_Opportunity__c = false';
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<cscfga__Product_Basket__c> scope) {
		System.debug('Before execute == ');
        OpportunityBulkSyncUtility.syncWithOpportunity(scope);
        System.debug('After execute == ');
	}
	
	global void finish(Database.BatchableContext BC) {
		System.debug('Executed Finis == ');
	}
	
}