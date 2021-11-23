global class SyncBasketFromPageLayout  
{
	webservice static string SynchronizeBasket(string ProductBasketId)
	{
		
		ProductBasketId = (string) (Id) ProductBasketId;
		//system.debug('****ProductBasketId=' + ProductBasketId);

		cscfga__Product_Basket__c CurrentBasket = [select Id, csordtelcoa__Synchronised_with_Opportunity__c, cscfga__Opportunity__c
			from cscfga__Product_Basket__c where Id=:ProductBasketId][0];
		
		//system.debug('****CurrentBasket before update=' + CurrentBasket);
		
		//de-sync first and then synce again
		if (CurrentBasket.csordtelcoa__Synchronised_with_Opportunity__c)
		{
			CurrentBasket.csordtelcoa__Synchronised_with_Opportunity__c=false;
			update CurrentBasket;
		}
		
		CurrentBasket.csordtelcoa__Synchronised_with_Opportunity__c=true;
		update CurrentBasket;
		
		//system.debug('****CurrentBasket after update=' + CurrentBasket);
		
		return CurrentBasket.cscfga__Opportunity__c;
	}
}