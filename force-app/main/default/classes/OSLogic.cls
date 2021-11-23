public interface OSLogic {
	List<cscfga__Product_Configuration__c> getPCList(List<Id> macdBasketList);

	List<csord__Subscription__c> getSubList(
		List<cscfga__Product_Configuration__c> pcList,
		List<String> orignalReplacedSubList);

	Map<String, Map<String, csord__Subscription__c>> getSubscriptionMap(
		List<csord__Subscription__c> subList,
		Map<Id, String> guidMap
	);

	List<csord__Subscription__c> getSubscriptionsList(List<String> selectedSubList);

	List<cscfga__Product_Basket__c> getBaskets(List<Id> macdBasketIds);

	List<cscfga__Attribute__c> getAttributeList(List<Id> pcList);

	Boolean checkSourceValid(
		List<cscfga__Product_Configuration__c> configList,
		List<Id> subIdList
	);

	List<String> getTargetGUIDList(List<cscfga__Product_Configuration__c> configList);

	Map<String, Object> createEmptyMacBasketRecord(Map<String, Object> args, Map<String, Object> basketMap);

	Map<String, Object> createEmptyMacOppRecord(Map<String, Object> args, Map<String, Object> basketMap);

	List<cscfga__Product_Basket__c> updateBasketAccount(
		List<cscfga__Product_Basket__c> basketList,
		Migration_Change_Request__c mcrInstance,
		Map<String, Object> basketCreationResponseMap
	);

	List<Id> getPCIds(List<csord__Subscription__c> subList);

	List<csord__Service__c> getServiceList(List<Id> subscriptionList);

	List<Id> getServicePCIds(List<csord__Service__c> serviceList);
}