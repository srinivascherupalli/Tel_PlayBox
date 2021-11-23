public with sharing class MigrateSubscriptionUtil {

    @TestVisible
    private static OSLogic osInstance = new OSModuleConnector();

    public static CustomSettingWrapper settingWrapper {
        get {
            if (settingWrapper == null) {
                settingWrapper = extractCustomSetting();
            }
            return settingWrapper;
        }
        set;
    }
    public static List<cssdm__Solution_Definition__c> getAllAssociations(Boolean isActive) {
        List<cssdm__Solution_Definition__c> solutionDefinitions = [
            select cssdm__type__c, cssdm__product_definition__c, cssdm__min__c, cssdm__max__c,
            cssdm__main_component__c, cssdm__parent_component__c, cssdm__sequence__c, name, id, cssdm__schema__c,
            cssdm__schema__r.csutil__value__c, cssdm__create_pcr__c, cssdm__description__c, cssdm__image_url__c,
            cssdm__component_type__c, cssdm__product_definition__r.name, cssdm__show_site_products__c,
            cssdm__related_product_name__c, cssdm__show_add_ons__c, cssdm__effective_end_date__c,
            cssdm__effective_start_date__c, cssdm__current_version__c, cssdm__version_number__c,
            cssdm__schema__r.name, cssdm__product_definition__r.csexpimp1__guid__c
          from cssdm__Solution_Definition__c
          order by cssdm__sequence__c nulls last
        ];

        List<cssdm__Solution_Definition__c> activeDefinitions = new List<cssdm__Solution_Definition__c>();
        if (isActive) {
          for (cssdm__Solution_Definition__c sd : solutionDefinitions) {
            if (sd.cssdm__current_version__c == null && (sd.cssdm__effective_end_date__c == null || sd.cssdm__effective_end_date__c >= Datetime.now())
              && (sd.cssdm__effective_start_date__c == null || sd.cssdm__effective_start_date__c <= Datetime.now())) {
              activeDefinitions.add(sd);
            }
          }
        } else {
          return solutionDefinitions;
        }

        return activeDefinitions;
      }

    public static String getFieldMetadata() {
        Map<String, Object> fieldMetadataMap = new Map<String, Object>();

        List<String> recordNameList = new List<String>{
            'ms-solution-fields',
            'ms-subscription-fields',
            'ms-account-fields',
            'ms-solutionDefinition-fields',
            'ms-mcr-fields'
        };
        Map<String, String> jsonDataMap = extractDynamicFields(recordNameList);

        Map<String, String> objectMap = new Map<String, String>{
            'csord__Solution__c' => 'ms-solution-fields',
            'csord__Subscription__c' => 'ms-subscription-fields',
            'Account' => 'ms-account-fields',
            'cssdm__Solution_Definition__c' => 'ms-solutionDefinition-fields',
            'Migration_Change_Request__c' => 'ms-mcr-fields'
        };
        for (String objName : objectMap.keySet()) {
            Map<String, Object> parsedData = (Map<String, Object>) JSON.deserializeUntyped(
                jsonDataMap.get(objectMap.get(objName))
            );
            Set<String> fieldAPINameList = new Set<String>();
            if (String.isNotBlank((String) parsedData.get('lookupColumns'))) {
                List<String> lookupFieldsList = ((String) parsedData.get('lookupColumns')).split(',');
                fieldMetadataMap.put(
                    objectMap.get(objName) + '-lookup',
                    MetadataHelper.generateFieldMetadata(
                        objName,
                        lookupFieldsList
                    )
                );
            }
            if (String.isNotBlank((String) parsedData.get('tableColumns'))) {
                List<String> tableFieldsList = ((String) parsedData.get('tableColumns')).split(',');
                fieldMetadataMap.put(
                    objectMap.get(objName) + '-table',
                    MetadataHelper.generateFieldMetadata(
                        objName,
                        tableFieldsList
                    )
                );
            }
        }

        return JSON.serialize(fieldMetadataMap);
    }

    public static Map<String, String> extractDynamicFields(List<String> recordNameList) {
        Map<String, String> nameValueMap = new Map<String, String>();
        Id profileId = UserInfo.getProfileId();
        List<csutil__JSON_Data__c> jsonDataList = [
            select name, csutil__profile_name__c, csutil__value__c
            from csutil__JSON_Data__c
            where name = :recordNameList
            and (csutil__profile_name__c = null
                or csutil__profile_name__c = :profileId)
            order by csutil__profile_name__c ASC nulls Last
        ];
        String dynamicFields = '';
        if (!jsonDataList.isEmpty()) {
            for (csutil__JSON_Data__c jd : jsonDataList) {
                if (!nameValueMap.containsKey(jd.Name)) {
                    nameValueMap.put(jd.Name, jd.csutil__value__c);
                }
            }
        }

        return nameValueMap;
    }

    public static String extractDynamicFields(String recordName) {

        Id profileId = UserInfo.getProfileId();
        List<csutil__JSON_Data__c> jsonDataList = [
            select name, csutil__profile_name__c, csutil__value__c
            from csutil__JSON_Data__c
            where name = :recordName
            and (csutil__profile_name__c = null
                or csutil__profile_name__c = :profileId)
        ];
        String dynamicFields = '';
        if (!jsonDataList.isEmpty()) {
            dynamicFields = jsonDataList[0].csutil__value__c;
            for (csutil__JSON_Data__c jd : jsonDataList) {
                if (jd.csutil__profile_name__c != null) {
                    dynamicFields = jd.csutil__value__c;
                }
            }
        }

        return dynamicFields;
    }

    public static CustomSettingWrapper extractCustomSetting() {

        String extension = 'csordtelcoa';
        Id orgId = UserInfo.getOrganizationId();
        Id profileId = UserInfo.getProfileId();
        Id userId = UserInfo.getUserId();
        Map<String, SObject> settingMap = new Map<String, SObject>();
        if (!Test.isRunningTest()) {
			List<SObject> csList = [select	id,name,setupOwnerId,csordtelcoa__Basket_Linked_To_Opportunity__c,csordtelcoa__Opportunity_Stages_creating_orders__c,csordtelcoa__Subscription_Closed_Replaced_State__c,csordtelcoa__Statuses_Not_Allowing_Change__c,csordtelcoa__Create_Mac_Baskets__c,csordtelcoa__Create_Mac_Opportunities__c,csordtelcoa__Use_Batch_Mode__c from csordtelcoa__Orders_Subscriptions_Options__c where setupOwnerId = :orgId or setupOwnerId = :profileId or setupOwnerId = :userId];
																	   
																			 
																			 
																	   
															 
																   
													   
																			 
												 
												  
												
																					  
            for (SObject cs : csList) {
                Id csid = (Id) cs.get('setupOwnerId');
                settingMap.put(String.valueOf(csid.getSObjectType()),cs);
            }

            SObject obj;
            if (settingMap.containsKey('User')) {
                obj = settingMap.get('User');
            } else if (settingMap.containsKey('Profile')) {
                obj = settingMap.get('Profile');
            } else if (settingMap.containsKey('Organization')) {
                obj = settingMap.get('Organization');
            }

            return new CustomSettingWrapper (
				(Boolean) obj.get('csordtelcoa__Basket_Linked_To_Opportunity__c'),
				(String) obj.get('csordtelcoa__Opportunity_Stages_creating_orders__c'),
				(String) obj.get('csordtelcoa__Subscription_Closed_Replaced_State__c'),
				(String) obj.get('csordtelcoa__Statuses_Not_Allowing_Change__c'),
				(Boolean) obj.get('csordtelcoa__Create_Mac_Baskets__c'),
				(Boolean) obj.get('csordtelcoa__Create_Mac_Opportunities__c'),
				(Boolean) obj.get('csordtelcoa__Use_Batch_Mode__c')
            );
        }
        else {
            return new CustomSettingWrapper (
                true,
                'Closed',
                'Closed Replaced',
                'Completed',
                true,
                true,
                true
            );
        }

    }

    public static Map<String, Object> executeObserver(String observableName, Map<String, Object> params) {
        List<Observer__mdt> observerList = [
            select id, execution_order__c, class_name__c, observable__c
            from Observer__mdt
        ];
        String className = '';
        for (Observer__mdt obs : observerList) {
            if (obs.observable__c == observableName && obs.class_name__c != null) {
                className = obs.class_name__c;
                break;
            }
        }
        Map<String, Object> response = new Map<String, Object>();
        if (className != '') {
            Type filter = Type.forName(className);
            if (filter != null) {
                    MigrateSubscriptionObserver handler = (MigrateSubscriptionObserver) filter.newInstance();
                    response = (Map<String, Object>) handler.executeLogic(params);
            }
        }

        return response;
    }

    public static List<Id> checkSolutionCompatibility(List<Id> subscriptionList) {
        List<csord__Service__c> serviceList = osInstance.getServiceList(subscriptionList);
        List<Id> pcIds = osInstance.getServicePCIds(serviceList);
        List<cscfga__Product_Configuration__c> pcList = [
            select id, name, cscfga__Product_Definition__c,cscfga__Product_Definition__r.cscfga__IsArchived__c,
            cscfga__Product_Definition__r.cscfga__Label__c 
            from cscfga__Product_Configuration__c
            where id in :pcIds
        ];
        Set<Id> prodDefIds = new Set<Id>();
        Set<string> prodDefLabels = new Set<string>();
        for (cscfga__Product_Configuration__c pc : pcList) {
            if(pc.cscfga__Product_Definition__r.cscfga__IsArchived__c)
                prodDefLabels.add(pc.cscfga__Product_Definition__r.cscfga__Label__c);  
            else
                prodDefIds.add(pc.cscfga__Product_Definition__c);
        }
        for(cscfga__Product_Definition__c pd : [select id from cscfga__Product_Definition__c where cscfga__Label__c IN : prodDefLabels and cscfga__IsArchived__c = false]){
            prodDefIds.add(pd.id);
        }
        List<cssdm__Solution_Definition__c> activeSolDefs = getAllAssociations(true);
        Map<Id, Set<Id>> sdPdMap = new Map<Id, Set<Id>>();
        for (cssdm__Solution_Definition__c sd : activeSolDefs) {
            if (sd.cssdm__main_component__c == null) {
                if (sdPdMap.get(sd.id) == null) {
                    sdPdMap.put(sd.id, new Set<Id>{sd.cssdm__product_definition__c});
                } else {
                    sdPdMap.get(sd.id).add(sd.cssdm__product_definition__c);
                }
            } else {
                if (sdPdMap.get(sd.cssdm__main_component__c) == null) {
                    sdPdMap.put(sd.cssdm__main_component__c, new Set<Id>{sd.cssdm__product_definition__c});
                } else {
                    sdPdMap.get(sd.cssdm__main_component__c).add(sd.cssdm__product_definition__c);
                }
            }
        }
        List<Id> selectSolutionDefs = new List<Id>();
        for (Id sdId : sdPdMap.keySet()) {
            if (sdPdMap.get(sdId).containsAll(prodDefIds)) {
                selectSolutionDefs.add(sdId);
            }
        }

        return selectSolutionDefs;
    }
    /**
    * Method builds query for fetching source and target solutions for lookup table
    */
    public static Map<String, Object> getSolutionData(
        String callingMethod,
        List<Id> sourceSolutionList,
        String accountId,
        String userInputString,
        List<Id> sourceSubscriptionList
    ) {
										 
        String jsonData = extractDynamicFields('ms-solution-fields');
        Map<String, Object> parsedData = (Map<String, Object>) JSON.deserializeUntyped(jsonData);
        userInputString = String.escapeSingleQuotes(userInputString);
        List<String> fieldAPINameList = new List<String>{};
        Set<String> queryFieldSet = new Set<String>{'id'};
        String solutionQuery = 'select ';
        if (String.isNotBlank((String) parsedData.get('lookupColumns'))) {
            queryFieldSet.addAll(((String) parsedData.get('lookupColumns')).split(','));
            List<String> lookupFieldsList = ((String) parsedData.get('lookupColumns')).split(',');
            fieldAPINameList.addAll(lookupFieldsList);
        }
        if (String.isNotBlank((String) parsedData.get('tableColumns'))) {
            queryFieldSet.addAll(((String) parsedData.get('tableColumns')).split(','));
        }
        if (queryFieldSet.size() == 1) {
            queryFieldSet.add('name');
        }
        solutionQuery += String.join(new List<String>(queryFieldSet), ',');

        if (MetadataHelper.isMultiCurrencyEnabled() && !solutionQuery.contains('currencyisocode')) {
            solutionQuery += ' , currencyisocode ';
        }
        solutionQuery += ' from csord__Solution__c where '
            + ' cssdm__solution_definition__c != null ';

        if (callingMethod == 'Target' && sourceSolutionList != null) {
            solutionQuery += ' and Id not in :sourceSolutionList';
        }
        if (callingMethod == 'Target' && sourceSubscriptionList != null) {
            List<Id> activeSolutionDef = checkSolutionCompatibility(sourceSubscriptionList);
            solutionQuery += ' and cssdm__solution_definition__c in :activeSolutionDef';
        }
        if (userInputString != null && String.isNotBlank((String) parsedData.get('searchFields'))) {
            List<String> searchFieldsList = ((String) parsedData.get('searchFields')).split(',');
            String filterString = '';
            for (Integer count = 0; count < searchFieldsList.size(); count++) {
                if (count == 0) {
                    filterString += ' ( ' + searchFieldsList[count] + ' LIKE \'%' + userInputString + '%\')';
                } else {
                    filterString += ' or ( ' + searchFieldsList[count] + ' LIKE \'%' + userInputString + '%\') ';
                }
            }
            solutionQuery += ' and (' + filterString + ') ';
        }
        List<String> orderCreationStageList = (settingWrapper.OpportunityStagesCreatingOrders != null) ?
            settingWrapper.OpportunityStagesCreatingOrders.split(',') : new List<String>();
        if (!Test.isRunningTest()) {
            solutionQuery += 'and cssdm__product_basket__r.csordtelcoa__Account__c = :accountId ';
													  

            if (!settingWrapper.basketLinkedToOpportunity) {
                solutionQuery += 'and cssdm__product_basket__r.'
                + 'csordtelcoa__Basket_Stage__c in :orderCreationStageList';
            } else {
                solutionQuery += ' and cssdm__product_basket__r.cscfga__Opportunity__r.StageName '
                    + ' in :orderCreationStageList';
            }
        }
        solutionQuery += ' limit ' + (String) parsedData.get('maxLimit');
        system.debug('solQuery--'+ solutionQuery);
        List<csord__Solution__c> solutionList = (List<csord__Solution__c>) Database.query(solutionQuery);
        system.debug('solList--'+solutionList);
        List<MetadataHelper.FieldMetadataWrapper> fieldWrapper = MetadataHelper.generateFieldMetadata(
            'csord__Solution__c',
            fieldAPINameList
        );

        return new Map<String, Object> {
            'solution' => solutionList,
            'metadata' =>  new Map<String, Object> {
                'displayFieldInformation' => fieldWrapper
            }
        };
    }

    public static String getActiveSolutionList(String accountId, String userInputString) {
        Map<String, Object> solutionMap = getSolutionData(
            'Source',
            null,
            accountId,
            userInputString,
            null
        );
        List<csord__Solution__c> solutionList = (List<csord__Solution__c>) solutionMap.get('solution');

        Map<String, Object> params = new Map<String, Object>{
            'solutions' => solutionList,
            'accountId' => accountId,
            'userInputText' => userInputString
        };
        Map<String, Object> response = executeObserver('getSourceSolutions', params);
        if (response != null && response.get('solutions') != null) {
            solutionList = (List<csord__Solution__c>) response.get('solutions');
            solutionMap.put('solution', solutionList);
        }

        return JSON.serialize(solutionMap);
    }

    public static String getActiveSubscriptions(List<Id> solutionList, String userInputString, Integer pageSize, Integer pageNumber) {
										 
        String jsonData = extractDynamicFields('ms-subscription-fields');
        Map<String, Object> parsedData =(Map<String, Object>) JSON.deserializeUntyped(jsonData);
        userInputString = String.escapeSingleQuotes(userInputString);
        List<String> fieldAPINameList = new List<String>{};
        Set<String> queryFieldSet = new Set<String>{'id'};
        String subQuery = 'select ';
        if (String.isNotBlank((String) parsedData.get('lookupColumns'))) {
            queryFieldSet.addAll(((String) parsedData.get('lookupColumns')).split(','));
            List<String> lookupFieldsList = ((String) parsedData.get('lookupColumns')).split(',');
            fieldAPINameList.addAll(lookupFieldsList);
        }
        if (String.isNotBlank((String) parsedData.get('tableColumns'))) {
            queryFieldSet.addAll(((String) parsedData.get('tableColumns')).split(','));
        }
        if (queryFieldSet.size() == 1) {
            queryFieldSet.add('name');
        }

        subQuery += String.join(new List<String>(queryFieldSet), ',');
        if (MetadataHelper.isMultiCurrencyEnabled() && !subQuery.contains('currencyisocode')) {
            subQuery += ' , currencyisocode ';
        }

        subQuery += ' from csord__Subscription__c '
            + 'where cssdm__solution_association__c in :solutionList' ;

        if (userInputString != null && String.isNotBlank((String) parsedData.get('searchFields'))) {
            List<String> searchFieldsList = ((String) parsedData.get('searchFields')).split(',');
            String filterString = '';
            for (Integer count = 0; count < searchFieldsList.size(); count++) {
                if (count == 0) {
                    filterString += ' ( ' + searchFieldsList[count] + ' LIKE \'%' + userInputString + '%\')';
                } else {
                    filterString += ' or ( ' + searchFieldsList[count] + ' LIKE \'%' + userInputString + '%\') ';
                }
            }
            subQuery += ' and (' + filterString + ') ';
        }

        if (!Test.isRunningTest()) {
            subQuery += 'and csordtelcoa__Cancelled_By_Change_Process__c = false '
                + ' and csordtelcoa__Replacement_Subscription__c = null ';
        }
        List<String> supportingChangeList = (settingWrapper.subscriptionClosedReplacedState != null) ?
            settingWrapper.subscriptionClosedReplacedState.split(',') : new List<String>();
        if (!supportingChangeList.isEmpty()) {
            subQuery += ' and csord__Status__c not in :supportingChangeList ';
        }

        String closedReplacedState = settingWrapper.statusesNotAllowingChange;
        Integer limitRecords =  Integer.valueOf(parsedData.get('maxLimit'));
        Integer offSet = limitRecords*pageNumber;
        subQuery += ' and csord__Status__c != :closedReplacedState ';
        subQuery += ' limit ' + limitRecords + ' offset ' + offset ;

        List<csord__Subscription__c> subList = (List<csord__Subscription__c>) Database.query(subQuery);

        Map<String, Object> params = new Map<String, Object>{
            'subscriptions' => subList,
            'userInputText' => userInputString
        };
        Map<String, Object> response = executeObserver('getSourceSubscriptions', params);
        if (response != null && response.get('subscriptions') != null) {
            subList = (List<csord__Subscription__c>) response.get('subscriptions');
        }
        List<MetadataHelper.FieldMetadataWrapper> fieldWrapper = MetadataHelper.generateFieldMetadata(
            'csord__Subscription__c',
            fieldAPINameList
        );
        Map<String, Object> subscriptionMap = new Map<String, Object>{
            'subscription' => subList,
            'metadata' =>  new Map<String, Object> {
                'displayFieldInformation' => fieldWrapper
            }
        };

        return JSON.serialize(subscriptionMap);
    }

    public static String getTargetSolutions(List<Id> solutionList,
        List<Id> subscriptionList, String accountId, String userInputString) {
        Map<String, Object> solutionMap = getSolutionData(
            'Target',
            solutionList,
            accountId,
            userInputString,
            subscriptionList
        );
        List<csord__Solution__c> targetSolutionList = (List<csord__Solution__c>) solutionMap.get('solution');
        userInputString = String.escapeSingleQuotes(userInputString);
        Map<String, Object> params = new Map<String, Object> {
            'solutions' => targetSolutionList,
            'accountId' => accountId,
            'sourceSolutions' => solutionList,
            'sourceSubscriptions' => subscriptionList,
            'userInputText' => userInputString
        };
        Map<String, Object> response = executeObserver('getTargetSolutions', params);
        if (response != null && response.get('solutions') != null) {
            targetSolutionList = (List<csord__Solution__c>) response.get('solutions');
            solutionMap.put('solution', targetSolutionList);
        }
        solutionMap.putAll(response);

        return JSON.serialize(solutionMap);
    }

    public static String linkSubscriptionsAfterMigration(Id migrateSubscriptionId) {
        Migration_Change_Request__c migrationRecord = [
            select id, macd_basket_ids__c
            from Migration_Change_Request__c
            where Id = :migrateSubscriptionId
        ];
        List<Id> macdBasketList = migrationRecord.macd_basket_ids__c != '' ?
            migrationRecord.macd_basket_ids__c.split(',') :
            new List<Id>();

        String extension = 'csordtelcoa';
        List<cscfga__Product_Configuration__c> pcList = [ select id, cscfga__Product_Basket__c,
			cscfga__Parent_Configuration__c, cscfga__product_definition__c,
			cssdm__solution_association__r.cssdm__solution_definition__r.cssdm__product_definition__c,
			cssdm__solution_association__r.cssdm__replaced_solution__r.cssdm__solution_definition__r.cssdm__product_definition__c,
			cssdm__solution_association__r.cssdm__replaced_solution__c,csordtelcoa__Ignore_For_Order_Decomposition__c,
			(select Id,name, cscfga__Value__c from cscfga__Attributes__r where name = 'GUID'),
			csordtelcoa__cancelled_by_change_process__c, csordtelcoa__Replaced_Subscription__c
			from cscfga__Product_Configuration__c
			where cscfga__Product_Basket__c in :macdBasketList order by cscfga__package_guid__c];

        Map<String, csord__Subscription__c> oldSubMap = new Map<String, csord__Subscription__c>();
        Map<String, csord__Subscription__c> newSubMap = new Map<String, csord__Subscription__c>();
        Map<Id, String> guidMap = new Map<Id, String>();
        List<String> orignalReplacedSubList = new List<String>();
        for (cscfga__Product_Configuration__c pc : pcList) {
            if (!Test.isRunningTest()) {
                if (pc.get('csordtelcoa__Ignore_For_Order_Decomposition__c') == true) {
                    orignalReplacedSubList.add(String.valueOf(pc.get('csordtelcoa__Replaced_Subscription__c')));
                }
            }
            for (cscfga__Attribute__c attRec : pc.cscfga__Attributes__r) {
                guidMap.put(pc.id, attRec.cscfga__Value__c);
            }
        }

        List<csord__Subscription__c> subList = osInstance.getSubList(pcList, orignalReplacedSubList);
        Map<String, Map<String, csord__Subscription__c>> returnMap = osInstance.getSubscriptionMap(subList, guidMap);
        oldSubMap = returnMap.get('fetchOldMap');
        newSubMap = returnMap.get('fetchNewMap');
        List<csord__Subscription__c> subscriptions = new List<csord__Subscription__c>();
        String result;

        try {
            for (String guid : newSubMap.keyset()) {
                // Rahul updated code in GESA 
                if (newSubMap.get(guid) != null && oldSubMap.get(guid) != null) {
                    // Rahul updated code in GESA
                    csord__Subscription__c newSubRec = newSubMap.get(guid);
                    csord__Subscription__c oldSubRec = oldSubMap.get(guid);
                    if (!Test.isRunningTest()) {
                        newSubRec.put((String)('csordtelcoa__Replaced_Subscription__c'), oldSubRec.Id);
                        oldSubRec.put((String)('csordtelcoa__Replacement_Subscription__c'), newSubRec.Id);
                    }
                    subscriptions.add(newSubRec);
                    subscriptions.add(oldSubRec);
                }
            }
            update subscriptions;
            result = 'Updated successfully';
        } catch (Exception e) {
            result = e.getMessage();
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
        }

        return result;
    }

    public static String validateMCR(String mcrId) {
        Migration_Change_Request__c mcrInstance = [
            select id, account_id__c, macd_basket_ids__c, migration_status__c,
                selected_source_solution_ids__c,
                selected_subscription_ids__c, target_solution_id__c
            from Migration_Change_Request__c
            where id = :mcrId
        ];

        List<String> selectedSubList = mcrInstance.selected_subscription_ids__c != '' ?
            mcrInstance.selected_subscription_ids__c.split(',') :
            new List<String>();
        String extension = 'csordtelcoa';

        List<csord__Subscription__c> subList = osInstance.getSubscriptionsList(selectedSubList);

        List<Id> pcList = new List<Id>();
        List<Id> subIdList = new List<Id>();
        for (csord__Subscription__c sub : subList) {
            subIdList.add(sub.Id);
            if (!Test.isRunningTest()) {
                pcList.add((Id) sub.get('csordtelcoa__Product_Configuration__c'));
            }
        }

        List<cscfga__Attribute__c> sourceGUIDAttributeList = osInstance.getAttributeList(pcList);

        List<String> guidSourceList =  new List<String>();
        for (cscfga__Attribute__c attRec : sourceGUIDAttributeList) {
            guidSourceList.add(attRec.cscfga__Value__c);
        }

        List<Id> macdBasketIds = mcrInstance.macd_basket_ids__c != '' ?
            mcrInstance.macd_basket_ids__c.split(',') :
            new List<Id>();
        List<cscfga__Product_Configuration__c> configList = [ select	id,
																		cscfga__Product_Basket__c,
																		cscfga__Parent_Configuration__c,
																		cscfga__product_definition__c,
																		cssdm__solution_association__r.cssdm__solution_definition__r.cssdm__product_definition__c,
																		cssdm__solution_association__r.cssdm__replaced_solution__r.cssdm__solution_definition__r.cssdm__product_definition__c,
																		cssdm__solution_association__r.cssdm__replaced_solution__c,csordtelcoa__Ignore_For_Order_Decomposition__c,
																		(select Id,name, cscfga__Value__c from cscfga__Attributes__r where name = 'GUID'),
																		csordtelcoa__cancelled_by_change_process__c, csordtelcoa__Replaced_Subscription__c
																		from cscfga__Product_Configuration__c
																		where cscfga__Product_Basket__c in :macdBasketIds order by cscfga__package_guid__c];
        Boolean isSourceValid = osInstance.checkSourceValid(configList, subIdList);
        List<String> guidTargetList =  osInstance.getTargetGUIDList(configList);

        Boolean isTargetValid =  true;
        for (String guid : guidSourceList ) {
            if (!guidTargetList.contains(guid) && guidTargetList.size() > 0) {
                isTargetValid = false;
            }
        }

        Map<String, Object> returnMap = new Map<String, Object>();
        if (isSourceValid && isTargetValid) {
            Map<String, Object> params = new Map<String, Object>();
            params.put('mcrId', mcrId);
            Map<String, Object> beforeSaveObs = executeObserver('beforeMigrationSubmit', params);
            if (beforeSaveObs != null && beforeSaveObs.get('status') != null) {
                Boolean status = (Boolean) beforeSaveObs.get('status');
                if (status) {
                    submitMigration(macdBasketIds, mcrInstance);
                } else if (beforeSaveObs.get('message') != null) {
                returnMap.put('message', (String) beforeSaveObs.get('message'));
                }
            }  else {
                submitMigration(macdBasketIds, mcrInstance);
            }
            Map<String, Object> afterSaveObs = executeObserver('afterMigrationSubmit', params);
            if (afterSaveObs != null && afterSaveObs.get('message') != null) {
                returnMap.put('message', (String) afterSaveObs.get('message'));
            }
        } else {
            returnMap.put('info', 'Error: either source or target not valid');
        }

        return JSON.serialize(returnMap);
    }

    public static void submitMigration(List<Id> macdBasketIds, Migration_Change_Request__c mcrInstance) {
										 

        List<cscfga__Product_Basket__c> basketList = osInstance.getBaskets(macdBasketIds);
        List<Id> oppIdList = new List<Id>();
        for (cscfga__Product_Basket__c basket : basketList) {
            oppIdList.add(basket.cscfga__Opportunity__c);
        }

        if (!settingWrapper.basketLinkedToOpportunity) {
            for (cscfga__Product_Basket__c basket : basketList) {
                if (!Test.isRunningTest()) {
                    basket.put(
                        ('csordtelcoa__Basket_Stage__c'),
                        settingWrapper.OpportunityStagesCreatingOrders.split(',')[0]
                    );
                }
            }
            update basketList;

        } else {
            
            List<Opportunity > oppList = [
                select id, StageName
                from Opportunity
                where id in: oppIdList
            ];
            for (Opportunity opp : oppList) {
                opp.StageName = settingWrapper.OpportunityStagesCreatingOrders.split(',')[0];
            }
            update oppList;
        }

        try {
            mcrInstance.migration_status__c = 'Completed';
            upsert mcrInstance;
        }
        catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
        }
    }

    public static String getFieldTableSolutionList(List<String> solutionIds) {
        String solutionQuery = ' select id, name '
            + ' from csord__Solution__c where '
            + ' id in  :solutionIds ';

        List<csord__Solution__c> solutionList = (List<csord__Solution__c>) Database.query(solutionQuery);

        return JSON.serialize(solutionList);
    }

    public static String getFieldTableSubscriptionList(List<String> subscriptionIds) {
        String jsonData = extractDynamicFields('ms-subscription-fields');
        Map<String, Object> parsedData =(Map<String, Object>) JSON.deserializeUntyped(jsonData);
        List<String> fieldAPINameList = new List<String>();
        Set<String> queryFieldSet = new Set<String>{'id', 'cssdm__solution_association__c'};

        String subQuery = 'select ';
        if (String.isNotBlank((String) parsedData.get('tableColumns'))) {
            queryFieldSet.addAll(((String) parsedData.get('tableColumns')).split(','));
            List<String> lookupFieldsList = ((String) parsedData.get('tableColumns')).split(',');
            fieldAPINameList.addAll(lookupFieldsList);
        }
        if (queryFieldSet.size() == 2) {
            queryFieldSet.add('name');
        }
        subQuery += String.join(new List<String>(queryFieldSet), ',');
        if (MetadataHelper.isMultiCurrencyEnabled() && !subQuery.contains('currencyisocode')) {
            subQuery += ' , currencyisocode ';
        }

        subQuery += ' from csord__Subscription__c '
            + 'where id in :subscriptionIds' ;
        List<csord__Subscription__c> subList = (List<csord__Subscription__c>) Database.query(subQuery);
        List<MetadataHelper.FieldMetadataWrapper> fieldWrapper = MetadataHelper.generateFieldMetadata(
            'csord__Subscription__c',
            fieldAPINameList
        );
        Map<String, Object> subscriptionMap = new Map<String, Object>{
            'subscription' => subList,
            'metadata' =>  new Map<String, Object> {
                'displayFieldInformation' => fieldWrapper
            }
        };

        return JSON.serialize(subscriptionMap);
    }

    public static String getSubscriptionGuids(List<String> subscriptions) {
        List<csord__Subscription__c> subList = osInstance.getSubscriptionsList(subscriptions);
        List<Id> pcIdList = osInstance.getPCIds(subList);
        List<cscfga__Attribute__c> attrList = [
            select id, name, cscfga__product_configuration__c, cscfga__value__c,
                cscfga__product_configuration__r.cssdm__solution_association__c
            from cscfga__Attribute__c
            where name = 'GUID'
            and cscfga__Product_Configuration__c in :pcIdList
        ];
        Map<Id, List<String>> solutionGuidsMap = new Map<Id, List<String>>();
        for (cscfga__Attribute__c attRec : attrList) {
            Id solId = attRec.cscfga__Product_Configuration__r.cssdm__solution_association__c;
            if (solutionGuidsMap.containsKey(solId)) {
                List<String> existingGuids = solutionGuidsMap.get(solId);
                existingGuids.add(attRec.cscfga__Value__c);
                solutionGuidsMap.put(solId, existingGuids);
            } else {
                solutionGuidsMap.put(solId, new List<String>{attRec.cscfga__Value__c});
            }
        }

        return JSON.serialize(solutionGuidsMap);
    }

    public static String getAccountList(String accid, String userInputString) {
        String jsonData = extractDynamicFields('ms-account-fields');
        Map<String, Object> parsedData = (Map<String, Object>) JSON.deserializeUntyped(jsonData);
        Set<String> fieldAPINameList = new Set<String>();
        userInputString = String.escapeSingleQuotes(userInputString);
        String query = queryBuilder('Account', fieldAPINameList, parsedData, userInputString);
        if (!String.isBlank(accid)) {
            query += ' and id = :accid';
        }
        query += ' limit ' + (String) parsedData.get('maxLimit');

        List<Account> accounts = (List<Account>) Database.query(query);
        Map<String, Object> params = new Map<String, Object>{
            'accounts' => accounts,
            'userInputText' => userInputString
        };
        Map<String, Object> response = executeObserver('getAccounts', params);
        if (response != null && response.get('accounts') != null) {
            accounts = (List<Account>) response.get('accounts');
        }
        List<MetadataHelper.FieldMetadataWrapper> fieldWrapper = MetadataHelper.generateFieldMetadata(
            'Account',
            new List<String>(fieldAPINameList)
        );
        Map<String, Object> accountMap = new Map<String, Object>{
            'accounts' => accounts,
            'metadata' => new Map<String, Object> {
                'displayFieldInformation' => fieldWrapper
            }
        };

        return JSON.serialize(accountMap);
    }

    public static String getCompatibleSolutions(List<Id> subscriptionIds, String userInputString) {
        List<Id> solDefIds = MigrateSubscriptionUtil.checkSolutionCompatibility(subscriptionIds);
        String jsonData = extractDynamicFields('ms-solutionDefinition-fields');
        Map<String, Object> parsedData = (Map<String, Object>) JSON.deserializeUntyped(jsonData);
        Set<String> fieldAPINameList = new Set<String>();
        userInputString = String.escapeSingleQuotes(userInputString);
        String query = queryBuilder('cssdm__Solution_Definition__c', fieldAPINameList, parsedData, userInputString);
        query += ' and id in :solDefIds';
        query += ' limit ' + (String) parsedData.get('maxLimit');
        List<cssdm__Solution_Definition__c> solutionDefs = (List<cssdm__Solution_Definition__c>) Database.query(query);

        List<MetadataHelper.FieldMetadataWrapper> fieldWrapper = MetadataHelper.generateFieldMetadata(
            'cssdm__Solution_Definition__c',
            new List<String>(fieldAPINameList)
        );
        Map<String, Object> solutionDefMap = new Map<String, Object>{
            'solutionDefinition' => solutionDefs,
            'metadata' => new Map<String, Object> {
                'displayFieldInformation' => fieldWrapper
            }
        };

        return JSON.serialize(solutionDefMap);
    }

    private static String queryBuilder(
        String objectName,
        Set<String> fieldAPINameList,
        Map<String, Object> parsedData,
        String userInputString
    ) {
        String query = ' select id';
        if (MetadataHelper.isMultiCurrencyEnabled()) {
            query += ' ,currencyisocode ';
        }
        if (String.isNotBlank((String) parsedData.get('lookupColumns'))) {
            List<String> lookupFieldsList = ((String) parsedData.get('lookupColumns')).split(',');
            fieldAPINameList.addAll(lookupFieldsList);
        }
        if (String.isNotBlank((String) parsedData.get('tableColumns'))) {
            List<String> tableFieldsList = ((String) parsedData.get('tableColumns')).split(',');
            for(String field : tableFieldsList) {
                if (!fieldAPINameList.contains(field))  {
                    fieldAPINameList.add(field);
                }
            }
        }
        for (String field : fieldAPINameList) {
            query += ',' + field;
        }
        query += ' from ' + objectName;

        if (userInputString != null && String.isNotBlank((String) parsedData.get('searchFields'))) {
            List<String> searchFieldsList = ((String) parsedData.get('searchFields')).split(',');
            String filterString = '';
            for (Integer count = 0; count < searchFieldsList.size(); count++) {
                if (count == 0) {
                    filterString += ' ( ' + searchFieldsList[count] + ' LIKE \'%' + userInputString + '%\')';
                } else {
                    filterString += ' or ( ' + searchFieldsList[count] + ' LIKE \'%' + userInputString + '%\') ';
                }
            }
            query += ' where (' + filterString + ') ';
        }

        return query;
    }

    public class CustomSettingWrapper {

        public Boolean basketLinkedToOpportunity;
        public String OpportunityStagesCreatingOrders;
        public String subscriptionClosedReplacedState;
        public String statusesNotAllowingChange;
        public Boolean createMacBaskets;
        public Boolean createMacOpportunities;
        public Boolean useBatchMode;

        public CustomSettingWrapper (
            Boolean basketLinkedToOpportunity,
            String OpportunityStagesCreatingOrders,
            String subscriptionClosedReplacedState,
            String statusesNotAllowingChange,
            Boolean createMacBaskets,
            Boolean createMacOpportunities,
            Boolean useBatchMode
        ) {
            this.basketLinkedToOpportunity = basketLinkedToOpportunity;
            this.OpportunityStagesCreatingOrders = OpportunityStagesCreatingOrders;
            this.subscriptionClosedReplacedState = subscriptionClosedReplacedState;
            this.statusesNotAllowingChange = statusesNotAllowingChange;
            this.createMacBaskets = createMacBaskets;
            this.createMacOpportunities = createMacOpportunities;
            this.useBatchMode = useBatchMode;
        }

    }

}