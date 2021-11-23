public with sharing class MigrationChangeRequestUtil {
	public static MigrateSubscriptionUtil.CustomSettingWrapper settingWrapper {
		get {
			if (settingWrapper == null) {
				settingWrapper = MigrateSubscriptionUtil.extractCustomSetting();
			}
			return settingWrapper;
		}
		set;
	}

	private static Map<String, Map<Id, Object>> getSolutionData(Set<Id> solutionIds, Set<Id> mcrAccountIds) {
		List<csord__Solution__c> solutionList =  [
			select id, name, csord__Account__r.Name, csord__Account__c
			from csord__Solution__c
			where id in :solutionIds
		];
		Map<Id, Object> solutionMap = new Map<Id, Object>();
		Map<Id, Id> accountIdMap = new Map<Id, Id>();
		for (csord__Solution__c sol : solutionList) {
			solutionMap.put(sol.Id, sol);
			accountIdMap.put(sol.Id, sol.csord__Account__c);
		}
		List<Id> accountsIds = new List<Id>();
		for (Id solId : accountIdMap.keySet()) {
			accountsIds.add(accountIdMap.get(solId));
		}
        accountsIds.addAll(mcrAccountIds);
		List<Account> accountList = [select id, name from Account where id in: accountsIds];
		Map<Id, Account> accountDataMap = new Map<Id, Account>();
		for (Account acc : accountList) {
			accountDataMap.put(acc.id, acc);
		}

		return new Map<String, Map<Id, Object>> {
			'solutions' => solutionMap,
			'accountDataMap' => accountDataMap,
			'accountIdMap' => accountIdMap
		};
	}

	private static Map<String, cscfga__Product_Basket__c> getBasketData(Set<Id> basketIds) {
		List<cscfga__Product_Basket__c> basketList = [
			select id, name
			from cscfga__Product_Basket__c
			where id in :basketIds
		];
		Map<String, cscfga__Product_Basket__c> basketMap = new Map<String, cscfga__Product_Basket__c>();
		for (cscfga__Product_Basket__c bsk : basketList) {
			basketMap.put(bsk.Id, bsk);
		}

		return basketMap;
	}

	private static Map<String, cssdm__Solution_Definition__c> getSolutionDefinition(Set<Id> solutionDefIds) {
		List<cssdm__Solution_Definition__c> solutionDefList = [
			select id, name
			from cssdm__Solution_Definition__c
			where id in :solutionDefIds
		];
		Map<String, cssdm__Solution_Definition__c> solutionDefMap = new Map<String, cssdm__Solution_Definition__c>();
		for (cssdm__Solution_Definition__c sol : solutionDefList) {
			solutionDefMap.put(sol.id, sol);
		}

		return solutionDefMap;
	}

	public static String loadMCRs(String accountId, String mcrId) {
		List<Migration_Change_Request__c> mcrList;
		if (String.isNotBlank(accountId)) {
			mcrList = generateMCRList(accountId);
		} else if (String.isNotBlank(mcrId)) {
			mcrList = [
				select id, account_id__c, macd_basket_ids__c,
					migration_status__c, selected_source_solution_ids__c,
					selected_subscription_ids__c, target_solution_id__c,
					target_account__c, solution_definition__c
				from Migration_Change_Request__c
				where id =: mcrId
			];
		}

		Map<Id, String> solutionIdMap = new Map<Id, String>();
		Set<Id> solutionIds = new Set<Id>();
		Set<Id> basketIds = new Set<Id>();
		Set<Id> solutionDefIds = new Set<Id>();
        Set<Id> accountIdSet = new Set<Id>();
		for (Migration_Change_Request__c mcr : mcrList) {
			//add source Solutions Ids
			if (String.isNotBlank(mcr.selected_source_solution_ids__c)) {
				List<Id> solList = mcr.selected_source_solution_ids__c.split(',');
				solutionIds.addAll(solList);
			}
			//add target solutionIds
			solutionIds.add(mcr.target_solution_id__c);
			if (String.isNotBlank(mcr.macd_basket_ids__c)) {
				List<Id> bsktList = mcr.macd_basket_ids__c.split(',');
				basketIds.addAll(bsktList);
			}
			if(String.isNotBlank(mcr.solution_definition__c)) {
				solutionDefIds.add(mcr.solution_definition__c);
			}
            if (!String.isBlank(mcr.account_id__c)) {
                accountIdSet.add(mcr.account_id__c);
            }
            if (mcr.target_account__c != null) {
                accountIdSet.add(mcr.target_account__c);
            }
		}
		Map<String, Map<Id, Object>> solutionData =  getSolutionData(solutionIds, accountIdSet);
		Map<String, cscfga__Product_Basket__c> basketData = (basketIds.size() != 0) ?
			getbasketData(basketIds) :
			new Map<String, cscfga__Product_Basket__c>();
		Map<String, cssdm__Solution_Definition__c> solutionDefData = (solutionDefIds.size() != 0) ?
			getSolutionDefinition(solutionDefIds) :
			new Map<String, cssdm__Solution_Definition__c>();

		List<MigrationChangeRequestWrapper> mcrWrapper = new List<MigrationChangeRequestWrapper> ();
		if (!mcrList.isEmpty()) {
			for (Migration_Change_Request__c mcr : mcrList) {
				List<Id> solIdList = mcr.selected_source_solution_ids__c.split(',');
				//fetch source solution records
				List<csord__Solution__c> sourceSolList = new List<csord__Solution__c>();
				Map<Id, Object> solMap = (Map<Id, Object>) solutionData.get('solutions');
				for (Id solId : solIdList) {
					sourceSolList.add((csord__Solution__c) solMap.get(solId));
				}
				//fetch baskets
				List<cscfga__Product_Basket__c> basketList = new List<cscfga__Product_Basket__c>();
				if (String.isNotBlank(mcr.macd_basket_ids__c)) {
					List<Id> bsktList = mcr.macd_basket_ids__c.split(',');
					for (Id bskId : bsktList) {
						basketList.add(basketData.get(bskId));
					}
				}
                
				MigrationChangeRequestWrapper wrap = new MigrationChangeRequestWrapper(
					mcr,
					sourceSolList,
					(csord__Solution__c) solMap.get(mcr.target_solution_id__c),
					(Account) solutionData.get('accountDataMap').get(mcr.target_account__c),
					basketList,
					settingWrapper.useBatchMode,
					(cssdm__Solution_Definition__c) solutionDefData.get(mcr.solution_definition__c)
				);
				mcrWrapper.add(wrap);
			}
		}

		return JSON.serialize(mcrWrapper);
	}

	public static String upsertMigrationJob(String migrationJobJSON) {
		MigrationChangeRequestWrapper mcrWrap = (MigrationChangeRequestWrapper) JSON.deserialize(
			migrationJobJSON,
			MigrationChangeRequestWrapper.class
		);
		Migration_Change_Request__c mcrInstance = mcrWrap.toSObject();

		String result;
		try {
			upsert mcrInstance;
			result = mcrInstance.Id;
        }catch(DMLException e) {
            result = 'Error: '+e.getDmlMessage(0);
			System.debug(LoggingLevel.Error, e.getStackTraceString());
        }catch (Exception e) {
			result = 'Error: '+e.getMessage();
			System.debug(LoggingLevel.Error, e.getStackTraceString());
		}

		return result;
	}
	
	private static List<Migration_Change_Request__c> generateMCRList(String accountId) {
		List<Migration_Change_Request__c> mcrList = new List<Migration_Change_Request__c>();
		String jsonData = MigrateSubscriptionUtil.extractDynamicFields('ms-mcr-fields');
		if( String.isBlank(jsonData)) {
			return mcrList;
		}
		Map<String, Object> parsedData = (Map<String, Object>) Json.deserializeUntyped(jsonData);
		if( parsedData.containsKey('tableColumns') && !String.isBlank((String) parsedData.get('tableColumns'))) {
			Set<String> fieldsSet = new Set<String>{
				'Id',
				'macd_basket_ids__c',
				'account_id__c',
				'migration_status__c',
				'selected_source_solution_ids__c',
				'selected_subscription_ids__c',
				'target_solution_id__c',
				'target_account__c',
				'solution_definition__c'
			};
			if( MetadataHelper.isMultiCurrencyEnabled()) {
				fieldsSet.add('CurrencyIsoCode');
			}
			List<String> tableFieldList = ((String) parsedData.get('tableColumns')).deleteWhitespace().split(',');
			fieldsSet.addAll(tableFieldList);
			List<String> fieldList = new List<String>();
			fieldList.addAll(fieldsSet);
			String query = 'select ' + String.join(fieldList,',');
			query += ' from Migration_Change_Request__c';
			query += ' where account_id__c =:accountId and migration_status__c != \'Completed\'';
			if( !String.isBlank((String) parsedData.get('orderField')) && !String.isBlank((String) parsedData.get('orderDir'))) {
				query += ' order by ' + (String) parsedData.get('orderField') + ' ' + (String)parsedData.get('orderDir');
			}
			mcrList = Database.query(query);
		}
		return mcrList;
	}
    
	public class MigrationChangeRequestWrapper {

		@TestVisible private String mcrId;
		@TestVisible private String accountId;
		@TestVisible private String basketIds;
		@TestVisible private String migrationStatus;
		@TestVisible private String sourceSolutionIds;
		@TestVisible private String selectedSubIds;
		@TestVisible private String targetSolutionIds;
		@TestVisible private List<csord__Solution__c> sourceSolutionList;
		@TestVisible private csord__Solution__c targetSolution;
		@TestVisible private Account targetAccount;
		@TestVisible private List<cscfga__Product_Basket__c> basketList;
		@TestVisible private String targetAccountId;
		@TestVisible private String targetSolutionDefinitionId;
		@TestVisible private cssdm__Solution_Definition__c targetSolutionDefinition;
		@TestVisible private Boolean isBatchMode;
		@TestVisible private Migration_Change_Request__c mcr;

		public MigrationChangeRequestWrapper (
			Migration_Change_Request__c mcrInstance,
			List<csord__Solution__c> sourceSolutionList,
			csord__Solution__c targetSolution,
			Account targetAccount,
			List<cscfga__Product_Basket__c> basketList,
			Boolean isBatchMode,
			cssdm__Solution_Definition__c targetSolutionDefinition
		) {
			this.mcrId = mcrInstance.id;
			this.accountId = mcrInstance.account_id__c;
			this.basketIds = mcrInstance.macd_basket_ids__c;
			this.migrationStatus = mcrInstance.migration_status__c;
			this.sourceSolutionIds = mcrInstance.selected_source_solution_ids__c;
			this.selectedSubIds = mcrInstance.selected_subscription_ids__c;
			this.targetSolutionIds = mcrInstance.target_solution_id__c;
			this.sourceSolutionList = sourceSolutionList;
			this.targetSolution = targetSolution;
			this.targetAccount = targetAccount;
			this.basketList = basketList;
			this.isBatchMode = isBatchMode;
			this.targetAccountId = mcrInstance.target_account__c;
			this.targetSolutionDefinitionId = mcrInstance.solution_definition__c;
			this.targetSolutionDefinition = targetSolutionDefinition;
			this.mcr = mcrInstance;
		}

		public Migration_Change_Request__c toSObject() {
			Migration_Change_Request__c mcrInstance = new Migration_Change_Request__c();
			if (mcrId != '') {
				mcrInstance.id = mcrId;
			}
			mcrInstance.account_id__c = (Id) accountId;
			mcrInstance.macd_basket_ids__c = basketIds;
			mcrInstance.migration_status__c = migrationStatus;
			mcrInstance.selected_source_solution_ids__c = sourceSolutionIds;
			mcrInstance.selected_subscription_ids__c = selectedSubIds;
			mcrInstance.target_solution_id__c = targetSolutionIds;
			mcrInstance.target_account__c = String.isBlank(targetAccountId) ?
				(Id) accountId :
				targetAccountId;
			if (String.isNotBlank(targetSolutionDefinitionId)) {
				mcrInstance.solution_definition__c = targetSolutionDefinitionId;
			}

			return mcrInstance;
		}
	}

}