public class OSModuleConnectorMock implements OSLogic {
	public static List<cscfga__Product_Configuration__c> getPCList(List<Id> macdBasketList) {
		List<cscfga__Product_Configuration__c> pcListmock = [
			select id, name,
				(select Id, name, cscfga__Value__c
				from cscfga__Attributes__r
				where name = 'GUID')
			from cscfga__Product_Configuration__c
			];

		return pcListmock;
	}

	public static List<csord__Subscription__c> getSubList(
		List<cscfga__Product_Configuration__c> pcList,
		List<String> orignalReplacedSubList
	) {
		List<csord__Subscription__c> subscriptionList = [
			select id, name
			from csord__Subscription__c
		];

		return subscriptionList;
	}

	public static Map<String, Map<String, csord__Subscription__c>> getSubscriptionMap(
		List<csord__Subscription__c> subList,
		Map<Id, String> guidMap
	) {
		List<String> pcidList = new List<String>();
		for (String pc : guidMap.keySet()) {
			pcidList.add(guidMap.get(pc));
		}

		return new Map<String, Map<String, csord__Subscription__c>> {
			'fetchNewMap' => new Map<String, csord__Subscription__c> {
				pcidList[1] => subList[1]
			},
			'fetchOldMap' => new Map<String, csord__Subscription__c> {
				pcidList[0] => subList[0]
			}
		};
	}

	public static List<csord__Subscription__c> getSubscriptionsList(List<String> selectedSubList) {
		return [
			select id, name
			from csord__Subscription__c
		];
	}

	public static List<cscfga__Product_Basket__c> getBaskets(List<Id> macdBasketIds) {
		return [
			select id, name,cscfga__Opportunity__c, cscfga__Opportunity__r.StageName
			from cscfga__Product_Basket__c
		];
	}

	public static List<cscfga__Attribute__c> getAttributeList(List<Id> pcList) {
		return [
			select id, name, cscfga__Value__c
			from cscfga__Attribute__c
			where name = 'GUID'
		];
	}

	public static Boolean checkSourceValid(
		List<cscfga__Product_Configuration__c> configList,
		List<Id> subIdList
	) {
		return true;
	}

	public static List<String> getTargetGUIDList(List<cscfga__Product_Configuration__c> configList) {
		List<String> guidList = new List<String>();
		List<cscfga__Attribute__c> attList = [
			select id, cscfga__Value__c
			from cscfga__Attribute__c
			where Name ='GUID'
		];
		for (cscfga__Attribute__c att : attList) {
			guidList.add(att.cscfga__Value__c);
		}

		return guidList;
	}

	public static Map<String, Object> createEmptyMacBasketRecord(
		Map<String, Object> args,
		Map<String, Object> basketMap
	) {
		List<cscfga__Product_Basket__c> basketList = [
			select id, name
			from cscfga__Product_Basket__c
		];
		if (basketList.isEmpty()) {
			throw new MigrateSubscriptionException(
				'mock basket has to be created before calling this method'
			);
		}
		List<csord__Solution__c> solList = [
			select id, name, csord__Account__c, csord__Identification__c
			from csord__Solution__c
		];
		List<Id> solIdList = new List<Id>();
		for (csord__Solution__c sol : solList) {
			solIdList.add(sol.id);
		}

		return new Map<String, Object> {
			basketList[0].id => solIdList
		};
	}

	public static Map<String, Object> createEmptyMacOppRecord(
		Map<String, Object> args,
		Map<String, Object> basketMap
	) {
		List<Opportunity> oppList = [select id, name from Opportunity];
		List<csord__Solution__c> solList = [
			select id, name, csord__Account__c, csord__Identification__c
			from csord__Solution__c
		];
		List<Id> solIdList = new List<Id>();
		for (csord__Solution__c sol : solList) {
			solIdList.add(sol.id);
		}
		if (oppList.isEmpty()) {
			throw new MigrateSubscriptionException(
				'mock opportunity has to be created before calling this method'
			);
		}

		return new Map<String, Object> {
			oppList[0].id => solIdList
		};
	}

	public static List<cscfga__Product_Basket__c> updateBasketAccount(
		List<cscfga__Product_Basket__c> basketList,
		Migration_Change_Request__c mcrInstance,
		Map<String, Object> basketCreationResponseMap
	) {
		return basketList;
	}

	public static List<Id> getPCIds(List<csord__Subscription__c> subList) {
		List<cscfga__Product_Configuration__c> configList = [
			select id, name
			from cscfga__Product_Configuration__c
		];
		List<Id> pcIds = new List<Id>();
		for (cscfga__Product_Configuration__c pc : configList) {
			pcIds.add(pc.id);
		}

		return pcIds;
	}

	public static List<csord__Service__c> getServiceList(List<Id> subscriptionList) {
		List<csord__Service__c> serviceList = [select id, name from csord__Service__c];
		if (serviceList.isEmpty()) {
			 throw new MigrateSubscriptionException(
				'mock services need to be created before calling this method'
			);
		}

		return serviceList;
	}

	public static List<Id> getServicePCIds(List<csord__Service__c> serviceList) {
		List<cscfga__Product_Configuration__c> configList = [
			select id, name
			from cscfga__Product_Configuration__c
		];
		List<Id> pcIds = new List<Id>();
		for (cscfga__Product_Configuration__c pc : configList) {
			pcIds.add(pc.id);
		}

		return pcIds;
	}

}