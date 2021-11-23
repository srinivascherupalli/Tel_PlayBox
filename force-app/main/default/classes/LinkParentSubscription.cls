/**
 * Class for link parent subscription.
 */
public class LinkParentSubscription {

	/**
	 * It finds the parent reference from service and update the parent subscription field in BIP or any other subscription
	 *
	 * @param      orderIdList  The order identifier list
	 */
	public static void updateParentSubscription( List<Id> orderIdList) {

		List<csord__Service__c> serviceList = new List<csord__Service__c>();
		Map<Id, csord__Subscription__c> subListToUpdate = new Map<Id,csord__Subscription__c>();
		//Holds the Ids of subscription and config if selected parent is the product configuration ID
		Map<ID, ID> subsMap = new Map<ID, ID>();
		//Holds the Ids of subscription of the selected configuration ID
		Map<ID, ID> configMap = new Map<ID, ID>();

		//Query the top level services which do not have parent and parent reference field id NOT NULL
		serviceList = [SELECT id, csord__Subscription__c,ReplacedSubscription__c, Parent_reference__c,SiteId__c FROM csord__Service__c
		               where csord__Order__c IN :orderIdList and csord__Service__c = null and (Parent_reference__c != null or 
		               	SiteId__c!=null or ReplacedSubscription__c != null)];
        Map<Id,Id> replacementSubMap = new Map <Id,Id>();
		for (csord__Service__c servObj : serviceList )

		{
			ID subsId = servObj.csord__Subscription__c;
			ID parentRef = servObj.Parent_reference__c;

			if (parentRef != null) {
				String objectName = parentRef.getSObjectType().getDescribe().getName();

				if ('cscfga__Product_Configuration__c'.equals(objectName)) {
					subsMap.put(subsId, parentRef);

				} else if ('csord__Subscription__c'.equals(objectName)) {
					csord__Subscription__c updSub = subListToUpdate.get(subsId)!=null ? subListToUpdate.get(subsId) :
													new csord__Subscription__c(ID = subsId);
					updSub.Parent_Subscription__c = parentRef;
					subListToUpdate.put(subsId, updSub);
				}
			}

			if(servObj.SiteId__c!=null){
				csord__Subscription__c updSub = subListToUpdate.get(subsId)!=null ? subListToUpdate.get(subsId) :
													new csord__Subscription__c(ID = subsId);
				updSub.Site__c = servObj.SiteId__c;
				subListToUpdate.put(subsId, updSub);
			}
           //update replaced subscription mapping from service to subscription  EDGE-3369 
           //link legacy and CWP Subscription
           if(servObj.ReplacedSubscription__c!=null){
				csord__Subscription__c updSub = subListToUpdate.get(subsId)!=null ? subListToUpdate.get(subsId) :
													new csord__Subscription__c(ID = subsId);
				updSub.csordtelcoa__Replaced_Subscription__c = servObj.ReplacedSubscription__c;
				subListToUpdate.put(subsId, updSub);
                replacementSubMap.put(Id.valueOf(servObj.ReplacedSubscription__c),subsId);
			}
		}
        if(replacementSubMap !=null && replacementSubMap.size()>0)
        {
            List<csord__Subscription__c> subReplacementList = [Select id,csordtelcoa__Replacement_Subscription__c from csord__Subscription__c where id in : replacementSubmap.keyset()];
            if(subReplacementList !=null && subReplacementList.size()>0)
            {
                for(csord__Subscription__c legacySub: subReplacementList)
                {
                    legacySub.csordtelcoa__Replacement_Subscription__c = replacementSubMap.get(legacySub.id);
                }
                update subReplacementList;
            }
        
        }
		if (subsMap != null && subsMap.size() > 0) {

			List<ID> configIds = subsMap.values();
			Set<ID> configIdSet = new Set<ID>(configIds);

			//Query the services where the provided configuration ID matching . This is used find the subscription of that service
			serviceList = [SELECT id, csordtelcoa__Product_Configuration__c,ReplacedSubscription__c, csord__Subscription__c FROM csord__Service__c
			               where csordtelcoa__Product_Configuration__c IN :configIdSet ];


			for (csord__Service__c servObj : serviceList )

			{
				ID subsId = servObj.csord__Subscription__c;
				ID configID = servObj.csordtelcoa__Product_Configuration__c;

				configMap.put(configID, subsId);


			}
			for (ID subsIdUpdate : subsMap.keySet()) {
				csord__Subscription__c updSub = subListToUpdate.get(subsIdUpdate)!=null ? subListToUpdate.get(subsIdUpdate) :
													new csord__Subscription__c(ID = subsIdUpdate);
				updSub.Parent_Subscription__c = configMap.get(subsMap.get(subsIdUpdate));
				subListToUpdate.put(subsIdUpdate, updSub);				
			}
		}

		if ( !subListToUpdate.isEmpty()) {
			update subListToUpdate.values();
		}
	}
}