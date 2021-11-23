global with sharing class MigrateSubscriptionsController {
    @TestVisible
    private static OSLogic osInstance = new OSModuleConnector();

    global String fieldMetadata {
        get {
            if (String.isBlank(fieldMetadata)) {
                fieldMetadata = MigrateSubscriptionUtil.getFieldMetadata();
            }
            return fieldMetadata;
        }
        set;
    }
    global String migrationAttributes {
        get {
            if (String.isBlank(migrationAttributes)) {
                migrationAttributes = MigrateSubscriptionUtil.extractDynamicFields(
                    'ms-subscription-attributes'
                );
            }
            return migrationAttributes;
        }
        set;
    }
    global String basketSummaryAttributes {
		get {
			if (String.isBlank(basketSummaryAttributes)) {
				basketSummaryAttributes = MigrateSubscriptionUtil.extractDynamicFields(
					'ms-basket-summary-fields'
				);
			}
			return basketSummaryAttributes;
		}
		set;
	}

    global transient csutil.CustomResource[] commonContainerPageResources { get; private set; }

    global MigrateSubscriptionsController() {
        this.commonContainerPageResources = csutil.CustomResource.loadCustomResourceDescriptors('MigrateSubs');
    }

    global MigrateSubscriptionsController(cssmgnt.SolutionManagementController controller) {}

    @RemoteAction
    global static String createMacBasketOppty(String mcrId) {
        try{
            if (mcrId == null) {
                throw new MigrateSubscriptionException('invalid MCR id');
            }
            Migration_Change_Request__c mcrInstance = [
                select id, account_id__c, macd_basket_ids__c, migration_status__c,
                    selected_source_solution_ids__c, target_account__c, solution_definition__c,
                    selected_subscription_ids__c, target_solution_id__c
                from Migration_Change_Request__c
                where id = :mcrId
            ];
            if (mcrInstance.selected_source_solution_ids__c == '' || mcrInstance.target_solution_id__c == '') {
                throw new MigrateSubscriptionException('invalid source or target MCR data');
            }
            List<Id> sourceIdList = mcrInstance.selected_source_solution_ids__c.split(',');
            List<Id> selectedIdList = new List<Id>();
            if (!String.isBlank(mcrInstance.target_solution_id__c)) {
                selectedIdList.add(mcrInstance.target_solution_id__c);
            }
            selectedIdList.addall(sourceIdList);
            if (!String.isBlank(mcrInstance.solution_definition__c)) {
                selectedIdList.add(mcrInstance.solution_definition__c);
            }
            List<csord__Solution__c> solutionList = [
                select id, name, csord__Account__c
                from csord__Solution__c
                where id in :selectedIdList
            ];
            Map<String, Object> basketMap = new Map<String, Object>();
            if (mcrInstance.account_id__c != mcrInstance.target_account__c) {
                basketMap.put('basket1', sourceIdList);
                if (!String.isBlank(mcrInstance.target_solution_id__c)) {
                    basketMap.put('basket2', new List<Id>{mcrInstance.target_solution_id__c});
                } else {
                    basketMap.put('basket2', new List<Id>{mcrInstance.solution_definition__c});
                }
            } else {
                basketMap.put('basket1', selectedIdList);
            }
            Map<String, Object> response = MigrateSubscriptionUtil.executeObserver(
                'migrationCustomLogic',
                basketMap
            );
    
            Map<String, Object> basketCreationResponseMap = new Map<String, Object>();
    
            if (response != null && response.get('allbaskets') != null) {
                basketMap =  (Map<String, Object>) response.get('allbaskets');
            }
            basketCreationResponseMap = createMacBaskets(basketMap, mcrInstance);
    
            return JSON.serialize(basketCreationResponseMap);
        }catch(DMLException e) {
            System.debug(LoggingLevel.Error, e.getStackTraceString());
            return 'Error: '+e.getDmlMessage(0);
        }catch (Exception e) {
            System.debug(LoggingLevel.Error, e.getStackTraceString());
			return 'Error: '+e.getMessage();
		}
    }

    private static Map<String, Object> createMacBaskets(
        Map<String, Object> basketMap,
        Migration_Change_Request__c mcrInstance
    ) {
        Map<String, Object> basketCreationResponseMap = new Map<String, Object>();
        List<String> basketIdList = new List<String>();
        if (MigrateSubscriptionUtil.settingWrapper.createMacBaskets) {
            Map<String, Object> args = new Map<String, Object> {
                'changeTypeName' => 'Change Solution',
                'basketName' => 'MAC - Change Solution - ' + String.valueOf(system.now())
            };
            basketCreationResponseMap = osInstance.createEmptyMacBasketRecord(args, basketMap);
            for (String str : basketCreationResponseMap.keySet()) {
                basketIdList.add(str);
            }
        }
        Set<String> oppIdSet = new Set<String>();
        Map<String, Object> oppKeyMap = new Map<String, Object>();
        if (MigrateSubscriptionUtil.settingWrapper.createMacOpportunities) {
            Map<String, Object> args = new Map<String, Object> {
                'changeTypeName' => 'Change Solution',
                'opportunityName' => 'MAC - Change Solution - ' + String.valueOf(system.now()),
                'oppRecordTypeId' => null
            };
            oppKeyMap = osInstance.createEmptyMacOppRecord(args, basketMap);
            //fetch basketids from MAC opportunity
            oppIdSet = oppKeyMap.keySet();
            List<cscfga__Product_Basket__c> opportunityBaskets = [
                select id, cscfga__Opportunity__c, name
                from cscfga__Product_Basket__c
                where cscfga__Opportunity__c in :oppIdSet
            ];

            Map<String, String> oppBaskets = new Map<String, String>();
            for (cscfga__Product_Basket__c basket : opportunityBaskets) {
                basketIdList.add(basket.id);
                oppBaskets.put(basket.cscfga__Opportunity__c, basket.id);
            }
            //converting opp=>solutionids map to associated basket=>solutionids
            for (Id oppId : oppKeyMap.keySet()) {
                basketCreationResponseMap.put(oppBaskets.get(oppId) , oppKeyMap.get(oppId));
            }
        }
        /*
        1. update MCR record with basketid's
        2. update account info on new baskets & Opportunities
        */
        if (basketIdList.size() > 0) {
            try {
                if (oppIdSet.size() > 0) {
                    List<Opportunity> oppList = [
                        select id, AccountId
                        from Opportunity
                        where id in :oppIdSet
                    ];
                    for (Opportunity opp : oppList) {
                        opp.AccountId = mcrInstance.account_id__c;
                        if (oppKeyMap.containsKey(opp.Id)) {
                            List<Id> solIds = (List<Id>) oppKeyMap.get(opp.Id);
                            if (
                                mcrInstance.account_id__c != mcrInstance.target_account__c &&
                                (
                                    solIds.contains(mcrInstance.target_solution_id__c) ||
                                    solIds.contains(mcrInstance.solution_definition__c)
                                )
                            ) {
                                opp.AccountId = mcrInstance.target_account__c;
                            }
                        }
                    }
                    update oppList;
                }
                List<cscfga__Product_Basket__c> basketList = [
                    select id, cscfga__Opportunity__c, name
                    from cscfga__Product_Basket__c
                    where id in :basketIdList
                ];
                basketList = osInstance.updateBasketAccount(basketList, mcrInstance, basketCreationResponseMap);
                update basketList;

                mcrInstance.macd_basket_ids__c = string.join(basketIdList,',');
                mcrInstance.migration_status__c = 'Basket Created';
                update mcrInstance;
            }
            catch (Exception e){
                throw e;
            }
        }

        return basketCreationResponseMap;
    }

    @RemoteAction
    global static String loadMigrations(String accountId, String mcrId) {
        return MigrationChangeRequestUtil.loadMCRs(accountId, mcrId);
    }

    @RemoteAction
    global static String createMigrationJob(String migrationJobJSON) {
        return MigrationChangeRequestUtil.upsertMigrationJob(migrationJobJSON);
    }

    @RemoteAction
    global static String getLookupData(String params) {
        Map<String, Object> inputmap = (Map<String, Object>) JSON.deserializeUntyped(params);
        Map<String, Object> infoMap = (Map<String, Object>) inputmap.get('additionalCriteria');
        String accid = (String) infoMap.get('accountId');
        String searchTerm = (String) inputmap.get('searchTerm');
        List<String> solIdList = new List<String>();
        if (infoMap.get('sourceSolutionList') != null) {
            for (Object instance : (List<Object>) infoMap.get('sourceSolutionList')) {
                solIdList.add((String) instance);
            }
        }
        List<String> subIdList = new List<String>();
        if (infoMap.get('sourceSubscriptionList') != null) {
            for (Object instance : (List<Object>) infoMap.get('sourceSubscriptionList')) {
                subIdList.add((String) instance);
            }
        }
        String result = '';
        String objectValue = (String) inputmap.get('sObjectType');
        if (objectValue == 'csord__Solution__c') {
            if ((String) infoMap.get('type') == 'sourceSolution') {
                result = MigrateSubscriptionUtil.getActiveSolutionList(accid, searchTerm);
            } else {
                result = MigrateSubscriptionUtil.getTargetSolutions(
                    solIdList,
                    subIdList,
                    accid,
                    searchTerm
                );
            }
        } else if (objectValue == 'csord__Subscription__c') {
            result = MigrateSubscriptionUtil.getActiveSubscriptions(
                solIdList,
                searchTerm,
                (Integer) infoMap.get('pageSize'),
                (Integer) infoMap.get('pageNo')                
            );
        } else if (objectValue == 'Account') {
            result = MigrateSubscriptionUtil.getAccountList(accid, searchTerm);
        } else if (objectValue == 'cssdm__Solution_Definition__c') {
            result = MigrateSubscriptionUtil.getCompatibleSolutions(subIdList, searchTerm);
        }

        return result;
    }

    @RemoteAction
    global static String getFieldTableSolutions(String params) {
        List<String> solutionIds = (List<String>)JSON.deserialize(params, List<String>.class);
        String result = MigrateSubscriptionUtil.getFieldTableSolutionList(solutionIds);

        return result;
    }

    @RemoteAction
    global static String getFieldTableSubscriptions(String params) {
        List<String> subscriptionIds = (List<String>)JSON.deserialize(params, List<String>.class);
        String result = MigrateSubscriptionUtil.getFieldTableSubscriptionList(subscriptionIds);

        return result;
    }

    @RemoteAction
    global static String getSubscriptionGuids(String params) {
        List<String> subscriptionIds = (List<String>)JSON.deserialize(params, List<String>.class);
        String result = MigrateSubscriptionUtil.getSubscriptionGuids(subscriptionIds);

        return result;
    }

    @RemoteAction
    global static void updateMCR(String mcrId, String message, String status) {
        Migration_Change_Request__c mcrInstance = [
            select id, description__c, migration_status__c
            from Migration_Change_Request__c
            where Id = :mcrId
        ];
        try {
            mcrInstance.migration_status__c = status;
            if (!String.isBlank(message)) {
                mcrInstance.description__c = message;
            }
            update mcrInstance;
        } catch (Exception e) {
            system.debug(LoggingLevel.ERROR, e.getStackTraceString());
        }
    }

    @RemoteAction
    global static String submitMCR(String mcrId) {
        return MigrateSubscriptionUtil.validateMCR(mcrId);
    }

    @RemoteAction
    global static String addSolutionToBasket(String basketId, String solutionId) {
        String result;
        system.debug('addSolntoBasket--'+basketId+'--'+solutionId);
        try {
            result = cssmgnt.API_1.addSolutionToChange(basketId, (Id) solutionId);
        } catch (Exception e) {
            system.debug(LoggingLevel.ERROR, e.getStackTraceString());
            result = e.getMessage();
        }
        return result;
    }

    @RemoteAction
    global static Boolean checkIsBatchJobRunning(String basketId) {
        List<Object> taskList = csutil.AsyncTaskStatusComponentCtrl.getTaskElements(basketId);
                system.debug('checkIsBatchJobRunning--'+basketId+'--'+taskList);

        if (!taskList.isEmpty()) {
            //return true;
            return false;
        } else {
            //return false;
            return true;
        }
    }

    @RemoteAction
    global static String processAllBasket(String basketId, String action, String replacedMainConfigurationId) {
        system.debug('processAllBasket--'+basketId+'--'+action+'--'+replacedMainConfigurationId);

        return cssmgnt.API_1.postSelectiveMACDProcessing(basketId, replacedMainConfigurationId);
    }

    @RemoteAction
    global static void createDatabaseMACDSolution(
        String replacedSolutionId,
        String targetSolutionId,
        String targetBasketId,
        String targetMainConfigurationId,
        String changeType
    ) {
        Map<String, String> inputMap = new Map<String, String> {
            'replacedSolutionId' => replacedSolutionId,
            'targetSolutionId' =>  targetSolutionId,
            'targetBasketId' => targetBasketId,
            'changeType' => changeType,
            'targetMainConfigurationId' => targetMainConfigurationId
        };
        cssmgnt.SolutionMACDController.createHerokuMACDSolution(inputMap);
        system.debug('createDatabaseMACDSolution--'+targetBasketId+'--'+changeType+'--'+targetMainConfigurationId);

    }
    @RemoteAction
	global static Map<Id,cscfga__Product_Basket__c> getBasketDetails(List<Id> basketIdList) {
		String basketFields = MigrateSubscriptionUtil.extractDynamicFields('ms-basket-summary-fields');
		if (String.isBlank(basketFields)) {
			return basketDetails(basketIdList);
		}
		Map<String, Object> basketFieldMap = (Map<String, Object>)Json.deserializeUntyped(basketFields);
		if (basketFieldMap.containsKey('basketIdentifierField') && basketFieldMap.containsKey('solutionIdentifierField')) {
			String queryString = 'select id,' +
				String.escapeSingleQuotes((String)basketFieldMap.get('basketIdentifierField')) +
				',(select id,' +
				String.escapeSingleQuotes((String)basketFieldMap.get('solutionIdentifierField')) +
				' from cssdm__Solutions__r )' +
				' from cscfga__Product_Basket__c' +
				' where id in :basketIdList';
			List<cscfga__Product_Basket__c> basketList = (List<cscfga__Product_Basket__c>) Database.query(queryString);
			return new Map<Id, cscfga__Product_Basket__c>(basketList);
		} else {
			return basketDetails(basketIdList);
		}
	}

	private static Map<Id,cscfga__Product_Basket__c> basketDetails(List<Id> basketIdList) {
		return new Map<Id, cscfga__Product_Basket__c>([
			select id,name,(select id,name from cssdm__Solutions__r ) 
			from cscfga__Product_Basket__c
			where id in :basketIdList
		]);
	}
}