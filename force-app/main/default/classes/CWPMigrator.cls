public with sharing class CWPMigrator {
    boolean m_SaveResult;
    List<Opportunity> m_oppsToMigrate;
    Map<Id, cscfga__Product_Basket__c> m_id2BasketMap;
    List<cscfga__Product_Configuration__c> m_productConfigsToMigrate;
    Map<String, cscfga__Attribute__c> m_attributesOfExistingConfigs = new Map<String, cscfga__Attribute__c>();
    List<Id> m_configIds;

    List<cscfga__Product_Configuration__c> m_configurationsToAdd = new List<cscfga__Product_Configuration__c>();
    Map<Id, cscfga__Product_Configuration__c> m_configurationsToRemove = new Map<Id, cscfga__Product_Configuration__c>();
    List<csord__Solution__c> m_solutionsToAdd = new List<csord__Solution__c>();
    Map<csord__Solution__c, Attachment> m_attachmentsToAdd = new Map<csord__Solution__c, Attachment>();
    List<csbb__Product_Configuration_Request__c> m_pcrsToAdd = new List<csbb__Product_Configuration_Request__c>();
    List<csbb__Product_Configuration_Request__c> m_pcrsToRemove = new List<csbb__Product_Configuration_Request__c>();
    List<cscfga__Attribute__c> m_attributesToAdd = new List<cscfga__Attribute__c>();
    List<cscfga__Attribute__c> m_attributesToUpdate = new List<cscfga__Attribute__c>();
    String m_logSummary = '';
    CWP_Migration_Log__c m_log = new CWP_Migration_Log__c();
    Map<cscfga__Product_Configuration__c, csord__Solution__c> m_config2SolutionMap = new Map<cscfga__Product_Configuration__c, csord__Solution__c>();
    Map<csbb__Product_Configuration_Request__c, cscfga__Product_Configuration__c> m_pcrToPcMap = new Map<csbb__Product_Configuration_Request__c, cscfga__Product_Configuration__c>();
    Map<cscfga__Attribute__c, cscfga__Product_Configuration__c> m_attributeToConfigMap = new Map<cscfga__Attribute__c, cscfga__Product_Configuration__c>();
    Map<Id, String> m_pcIdToGUID = new Map<Id, String>();
    Map<Id, csord__Solution__c> m_accountToSolutionMap = new Map<Id, csord__Solution__c>();
    Map<Id, cscfga__Product_Configuration__c> m_accountToMainConfigMap = new Map<Id, cscfga__Product_Configuration__c>();
    Map<cscfga__Product_Configuration__c, Id> m_mainConfigToAccountMap = new Map<cscfga__Product_Configuration__c, Id>();
    Map<Id, cscfga__Product_Basket__c> m_accountToFinalBasketMap = new Map<Id, cscfga__Product_Basket__c>();
    List<csord__Service__c> m_liveServices = new List<csord__Service__c>();
    List<Id> m_liveServiceIds = new List<Id>();

    
    final String c_CWP_package_name = 'Connected Workplace';
    final String c_SolutionName = 'Connected Workplace Solution';
    final String c_Identification = 'Solution Management';
    final String c_solution_Status_open = 'Open';
    final String c_solution_Status_complete = 'Completed';

    final cscfga__Product_Definition__c c_CWP_product_definition;
    final RecordType c_package_Definition_Record_Type;
    final cssdm__Solution_Definition__c c_main_solution_definition;
    final List<cssdm__Solution_Definition__c> c_component_solution_definitions;
    final Map<String, cscfga__Attribute_Definition__c> c_pdAndName2AttributeDef;
    
    public CWPMigrator(boolean SaveResult, id CWPproductDefinitionID) {
        /*
        Constructor.
        boolean SaveResult: 
            if TRUE, commit/save results to salesforce
            if FALSE, calculate (and store) list of changes for review
        */
        this.m_SaveResult = SaveResult;

        
        List<cscfga__Product_Definition__c> prodDefs = 
                [SELECT 
                    Id 
                FROM 
                    cscfga__Product_Definition__c 
                WHERE 
                    name = 'Connected Workplace Solution' 
                and cscfga__Active__c = true and Id = :CWPproductDefinitionID];
        if (prodDefs.size()==0)
        {
            throw new CS_Exception(String.Format('CWP Solution product definition not found (specified id = "{0}")', new List<String> {'CWPproductDefinitionID'}));
        }
        else
        c_CWP_product_definition = prodDefs[0];

        c_package_Definition_Record_Type = 
                [Select 
                    Id
                From 
                    RecordType 
                where 
                    sobjecttype = 'cscfga__Product_Definition__c' 
                and 
                    name in ('Package Definition')];
    

        c_main_solution_definition = 
                [SELECT 
                    Id, 
                    Name, 
                    cssdm__Product_Definition__c, 
                    cssdm__Component_Type__c, 
                    cssdm__schema__r.csutil__value__c 
                FROM 
                    cssdm__Solution_Definition__c 
                WHERE 
                    Name = 'Connected Workplace' 
                and 
                    cssdm__Type__c = 'Main'];


        c_component_solution_definitions = new List<cssdm__Solution_Definition__c>(
                [SELECT 
                    Id, 
                    Name, 
                    cssdm__Product_Definition__c, 
                    cssdm__Component_Type__c, 
                    cssdm__schema__r.csutil__value__c,
                    cssdm__Type__c 
                FROM 
                    cssdm__Solution_Definition__c 
                where 
                    cssdm__main_component__c = :c_main_solution_definition.Id 
                and 
                    (cssdm__Type__c = 'Component' or cssdm__Type__c = 'Custom Component' or cssdm__Type__c = 'Related Component')]);//Added 03/10/2019

        List<cscfga__Attribute_Definition__c> ads = [SELECT 
                                                Id,
                                                Name,
                                                cscfga__Product_Definition__c,
						cscfga__Default_Value__c
                                            FROM 
                                                cscfga__Attribute_Definition__c 
                                            ];
        c_pdAndName2AttributeDef = new Map<String, cscfga__Attribute_Definition__c>();
        for (cscfga__Attribute_Definition__c ad : ads) {
            c_pdAndName2AttributeDef.put(ad.cscfga__Product_Definition__c + ad.Name, ad);
        }
    }

    public void migrate(List<Id> accounts) {
        /*
        Main entry point for migration script.
        Migrates all CWP data related to the specified list of accounts
        */
        this.initialiseDataFromAccounts(accounts); //LIVESVC REVIEWED
        this.RemoveOldPCRs(); //LIVESVC REVIEWED
        this.RemovePackageConfigs(); //LIVESVC REVIEWED
        this.CreateSolutionAndPCRecords(accounts); //LIVESVC REVIEWED
        this.AddGUIDsToExistingPCs();
        if (this.m_SaveResult)
        {
            this.SaveResult();
        }
        this.AddAttachmentToSolution(accounts);
        if (this.m_SaveResult)
        {
            this.SaveAttachment();
        }
        this.WriteUpgradeSummary();
        insert m_log;
    }

    public void updateSubsAndServices(List<Id> accounts) {
        /*Update the subscriptions and services linked to the specified accounts
        */
        this.initialiseDataFromAccounts(accounts);
        this.BuildOandSdataForAccounts(accounts);

    }
    public void rollBack(String logName, List<Id> accountIds) {
        /*
        Roll back / delete data that was inserted during previous migration:
        inserted records ids stored in CWP_Migration_Log__c specified by logName
        */
        CWP_Migration_Log__c log = [Select Inserted_Records__c FROM CWP_Migration_Log__c where Name = :logName];
        List<String> insertedRecordIds = (List<String>)JSON.deserializeStrict(log.Inserted_Records__c, List<String>.class);
        clearRecords(insertedRecordIds, accountIds);
    }

    public void rollBackAll(List<Id> accountIds) {
        /*
        Delete all records created as part of a migration process
        */
        List<String> insertedRecordIds = new List<String>();
        List<CWP_Migration_Log__c> logs = [Select Inserted_Records__c FROM CWP_Migration_Log__c];
        for (CWP_Migration_Log__c log : logs)
        {
            if (log.Inserted_Records__c!= null)
            {
                insertedRecordIds.addAll((List<String>)JSON.deserializeStrict(log.Inserted_Records__c, List<String>.class));
            }
        }   
        clearRecords(insertedRecordIds, accountIds);
    }

    private void clearRecords(List<String> insertedRecordIds, List<Id> accountIds) {
        List<csord__Solution__c> insertedSolutions = [SELECT Id FROM csord__Solution__c WHERE Id in :insertedRecordIds
	AND csord__Account__c in :accountIds];
        delete insertedSolutions;
        List<cscfga__Product_Configuration__c> insertedConfigs = [SELECT Id FROM cscfga__Product_Configuration__c WHERE Id in :insertedRecordIds
	AND cscfga__Product_Basket__r.csbb__Account__c in :accountIds];
        delete insertedConfigs;
        List<csbb__Product_Configuration_Request__c> insertedPCRs = [SELECT Id FROM csbb__Product_Configuration_Request__c WHERE Id in :insertedRecordIds
	AND csbb__Product_Basket__r.csbb__Account__c in :accountIds];
        delete insertedPCRs;
        List<cscfga__Attribute__c> insertedAttributes = [SELECT Id FROM cscfga__Attribute__c WHERE Id in :insertedRecordIds
	AND cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csbb__Account__c in :accountIds];
        delete insertedAttributes;
    }

    private void BuildOandSdataForAccounts(List<Id> accounts) {
        /*select orders, subscriptions, services related to the upgraded accounts
        */
        //SELECT PRIMARY BASKETS FROM OPPORTUNITIES ON THIS ACCOUNT
        Map<Id, cscfga__Product_Basket__c> baskets = new Map<Id, cscfga__Product_Basket__c> (
            [
                SELECT 
                    Id,
                    cscfga__Opportunity__c 
                from 
                    cscfga__Product_Basket__c 
                WHERE 
                    csbb__Account__c in :accounts 
                AND 
                    Primary_Basket__c = true]);
        Map<Id,Id> oppty2PrimaryBasketMap = new Map<Id,Id>();
        for (Id bId : baskets.keySet())
        {
            cscfga__Product_Basket__c basket = baskets.get(bId);
            oppty2PrimaryBasketMap.put(basket.cscfga__Opportunity__c, bId);
        }
        Map<Id, csord__Solution__c> solutions = new Map<Id, csord__Solution__c> (
            [
                SELECT
                    Id,
                    cssdm__product_basket__c 
                FROM
                    csord__Solution__c]);
        Map<Id, Id> basketId2SolutionId = new Map<Id,Id>();
        for (Id solId : solutions.keySet())
        {
            csord__Solution__c solution = solutions.get(solId);
            basketId2SolutionId.put(solution.cssdm__product_basket__c, solution.Id);
        }
        Map<Id,csord__Order__c> orders = new Map<Id, csord__Order__c> (
            [
                SELECT 
                    Id, 
                    csordtelcoa__Opportunity__c 
                FROM 
                    csord__Order__c
                WHERE 
                    csord__Account__c in :accounts]);
        System.Debug('BuildOandSdataForAccounts: orders = '+  orders);
        Map<Id, csord__Subscription__c> subs = new Map<Id, csord__Subscription__c> (
            [
                SELECT 
                    Id, 
                    csord__Order__c 
                FROM 
                    csord__Subscription__c 
                WHERE 
                    csord__Order__c in :orders.keySet()
            ]);
        System.Debug('BuildOandSdataForAccounts: subs = '+  subs);
        Map<Id, csord__Service__c> services = new Map<Id, csord__Service__c> (
            [
                SELECT 
                    Id, 
                    csord__Subscription__c,
                    cssdm__Solution_Association__c
                FROM 
                    csord__Service__c 
                WHERE 
                    csord__Subscription__c in :subs.keySet()
            ]);
        System.Debug('BuildOandSdataForAccounts: services = '+  services);
        for (Id svcId : services.keySet())
        {
            csord__Service__c service = services.get(svcId);
            csord__Subscription__c sub = subs.get(service.csord__Subscription__c);
            csord__Order__c ord = orders.get(sub.csord__Order__c);
            Id oppId = ord.csordtelcoa__Opportunity__c;
            cscfga__Product_Basket__c basket = baskets.get(oppty2PrimaryBasketMap.get(oppId));
            csord__Solution__c solution = solutions.get(basketId2SolutionId.get(basket.Id));
            /*Looks ok
            System.Debug('Got linked objects for service Id ' + svcId);
            System.Debug('Service = ' + service);
            System.Debug('Subscription = ' + sub);
            System.Debug('Order = ' + ord);
            System.Debug('Opportunity = ' + oppId);
            System.Debug('Primary basket = ' + basket);
            */
            service.cssdm__Solution_Association__c = solution.Id;
            sub.cssdm__Solution_Association__c = solution.Id;
        }

        //
        Map<Id, csord__Subscription__c> subsToUpdatePC = new Map<Id, csord__Subscription__c>([
                                SELECT 
                                    Id,
                                    Name,
                                    csordtelcoa__Product_Configuration__c
                                FROM 
                                    csord__Subscription__c
                                WHERE
                                    Name = 'Connected Workplace']);
        List<csord__Service__c> servicesWithNoParent = [
                                SELECT
                                    Id,
                                    csord__Subscription__c,
                                    csordtelcoa__Product_Configuration__c,
                                    csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name
                                FROM
                                    csord__Service__c
                                WHERE
                                    csord__Subscription__c in :subsToUpdatePC.keySet()
                                AND
                                    csord__Service__c = null];
        List<csord__Subscription__c> subsToUpdate = new List<csord__Subscription__c>();
        for (csord__Service__c service : servicesWithNoParent)
        {
            csord__Subscription__c sub = subs.get(service.csord__Subscription__c);
            if (sub==null) {
                throw new CS_Exception('No subscription for service ' + service.Id);
            }
            if (!subsToUpdate.contains(sub)) {subsToUpdate.add(sub);}
            sub.csordtelcoa__Product_Configuration__c = service.csordtelcoa__Product_Configuration__c;
            sub.Name = service.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name;
        }
        update servicesWithNoParent;
        update subsToUpdate;
        
    }

    private void initialiseDataFromAccounts(List<Id> accounts) {
        /*
        For the list of accounts to be migrated, set up lists of baskets and product configurations
        //LIVESVC REVIEWED
        */
        m_oppsToMigrate = [SELECT Id FROM Opportunity WHERE AccountId in :accounts];
        System.Debug('Opportunities to migrate = ' + m_oppsToMigrate); //added 3/10/2019
        //TODO LIVESVC Remove basketsToMigrate
        m_id2BasketMap = new Map<Id, cscfga__Product_Basket__c>(
            [
                            SELECT 
                                Id, 
                                Name,
                                Account_Id__c,
                                lastModifiedDate,
                                cscfga__Basket_Status__c
                            FROM 
                                cscfga__Product_Basket__c 
                            WHERE 
                            	csbb__Account__c in :accounts  //changed 3/10/2019; removed requirement for oppty reference        
                			and 
                                csordtelcoa__Basket_Stage__c != 'Cancelled'
            ]
        );
        System.Debug('id2basketmap = ' + m_id2BasketMap);
        SetProductConfigurationsToMigrate(accounts);                            
        m_configIds = new List<Id>();
        System.Debug('CWPMigrator: Found ' + m_productConfigsToMigrate.size() + ' configurations to migrate');
        for (cscfga__Product_Configuration__c pc : m_productConfigsToMigrate)
        {
            if (!pc.cscfga__Product_Definition__r.cscfga__Active__c)
            {
                System.Debug(LoggingLevel.WARN, String.Format('Product Configuration {0} ({1}) in basket {2} required upgrade to an active product definition', new List<String> {pc.Name, pc.Id, pc.cscfga__Product_Basket__r.Name}));
            }
            m_configIds.add(pc.Id);
        }       
    }

    private void SetProductConfigurationsToMigrate(List<Id> accounts) {
        /*
        * List of product configurations to migrate.
        * All products connected to live services (if there is at least one live CWP service)
        * Else all products in the *ONLY* open primary basket (ensure there is only one)
        *
        * Populates 
        * - m_productConfigsToMigrate
        * - m_accountToFinalBasketMap
        //LIVESVC created method
        */
        List<Id> accountsWithNoLiveServices = accounts.clone();
        List<Id> productDefinitionsToInclude = new List<Id> {c_main_solution_definition.cssdm__product_definition__c};
        for (cssdm__Solution_Definition__c sd : c_component_solution_definitions) {
            productDefinitionsToInclude.add(sd.cssdm__Product_Definition__c);
        }

        m_liveServices = [
            SELECT Id, 
                csordtelcoa__Product_Configuration__c, 
                csordtelcoa__Product_Configuration__r.cscfga__Parent_Configuration__c, 
		csord__Subscription__c,
                csord__Subscription__r.csord__Account__c,
                csord__Subscription__r.csordtelcoa__Product_Configuration__c
            FROM csord__Service__c 
            WHERE csord__Subscription__r.csord__Account__c in :accounts 
            AND csord__Status__c != 'Closed Replaced'
        ];
        List<Id> configIdsOfLiveServices = new List<Id>();
        for (csord__Service__c svc : m_liveServices) {
		m_liveServiceIds.add(svc.Id); // will be used in future method to update subscription references
            configIdsOfLiveServices.add(svc.csordtelcoa__Product_Configuration__c);
            Integer ix = accountsWithNoLiveServices.indexOf(svc.csord__Subscription__r.csord__Account__c);
            if (ix > -1) {
                accountsWithNoLiveServices.remove(ix);
            }
        }
        system.debug('configIdsOfLiveServices'+configIdsOfLiveServices);
        system.debug('accountsWithNoLiveServices'+accountsWithNoLiveServices);
        system.debug('productDefinitionsToInclude'+productDefinitionsToInclude);
        m_productConfigsToMigrate = [
            SELECT Id,
                Name,
                cscfga__Product_Definition__c,
                cscfga__Product_Definition__r.cscfga__Active__c,
                cssdm__Solution_Association__c,
                cscfga__Product_Basket__c,
                cscfga__Product_Basket__r.Name,
                cscfga__Product_Basket__r.lastModifiedDate,
                cscfga__Product_Basket__r.csbb__Account__c
            FROM cscfga__Product_Configuration__c
            WHERE 
            (
                cscfga__Product_Basket__r.csbb__Account__c in :accountsWithNoLiveServices
                OR Id in :configIdsOfLiveServices
            )
            AND cscfga__Product_Definition__c in :productDefinitionsToInclude
        ];
	for (cscfga__Product_Configuration__c pc : [
            SELECT Id,
                Name,
                cscfga__Product_Definition__c,
                cscfga__Product_Definition__r.cscfga__Active__c,
                cssdm__Solution_Association__c,
                cscfga__Product_Basket__c,
                cscfga__Product_Basket__r.Name,
                cscfga__Product_Basket__r.lastModifiedDate,
                cscfga__Product_Basket__r.csbb__Account__c
            FROM cscfga__Product_Configuration__c
            WHERE 
            (
                cscfga__Product_Basket__r.csbb__Account__c in :accountsWithNoLiveServices
                OR Id in :configIdsOfLiveServices
            )
        ]) {
		System.Debug(pc.Name + ', ' +  pc.cscfga__Product_Definition__c);
	}
        System.Debug('Found ' + m_productConfigsToMigrate.size() + ' configurations. Tested ' + configIdsOfLiveServices.size() + 'configs');
        List<cscfga__Attribute__c> attrs = [
            SELECT Id, 
                Name, 
                cscfga__Value__c, 
                cscfga__Product_Configuration__c,
                cscfga__Attribute_Definition__c
            FROM cscfga__Attribute__c
            WHERE cscfga__Product_Configuration__c in :m_productConfigsToMigrate
        ];
        for (cscfga__Attribute__c attr : attrs)
        {
            m_attributesOfExistingConfigs.put(attr.cscfga__Product_Configuration__c + attr.Name, attr);
        }

       // System.assert(m_productConfigsToMigrate.size() > 0);
        List<Id> liveReplacedConfigIds = GetListOfLiveReplacedConfigurations(accounts, configIdsOfLiveServices);

        //TODO LIVESVC Filter product configuration list to only those linked to CWP solution definition
        //TODO LIVESVC No cancelled baskets


        /* Identify the last active basket for each account. Solution will be linked to this basket */

        for (Integer i = m_productConfigsToMigrate.size()-1; i>=0; i--) {
            cscfga__Product_Configuration__c config = m_productConfigsToMigrate[i];
            //Remove replaced configs from consideration
            if (liveReplacedConfigIds.contains(config.Id)) {
                m_productConfigsToMigrate.remove(i);
                continue;
            }

            Id acctId = config.cscfga__Product_Basket__r.csbb__Account__c;
            Id basketId = config.cscfga__Product_Basket__c;
            System.Debug('Configuration ' + config.Id + 'is in basket ' + basketId);
            cscfga__Product_Basket__c basket = m_id2BasketMap.get(basketId);

            if (!m_accountToFinalBasketMap.containsKey(acctId)) {
                System.Debug('Adding basket to map ' + basketId + ', ' + basket); //added 3/10/2019
                m_accountToFinalBasketMap.put(acctId, basket);
            } else {
                cscfga__Product_Basket__c prevBasket = m_accountToFinalBasketMap.get(acctId);
                if (configIdsOfLiveServices.indexOf(config.Id)>-1) { 
                    //this configuration is part of a live service
                    //Make sure we are storing the most recently modified basket for this account
                    if (prevBasket.lastModifiedDate < basket.lastModifiedDate) {
                        m_accountToFinalBasketMap.put(acctId, basket);
                    }
                } else {
                    //this configuration is not part of a live service
                    //check that all configs are from same (Primary) basket 
                    //System.assertEquals(prevBasket.Id, basketId);
                    //TODO LIVESVC Check basket is primary
                }
            }
        }
        System.Debug(accounts);
        System.Debug(m_accountToFinalBasketMap);
	for (Id accountId : accounts) {
		if (!m_accountToFinalBasketMap.containsKey(accountId)) {
			throw new CS_Exception('No configurations found for account ' + accountId + '. Have configurations been upgraded?');
		}
	}
        //System.assertEquals(accounts.size(), m_accountToFinalBasketMap.size());
    }

    List<Id> GetListOfLiveReplacedConfigurations(List<Id> accounts, List<Id>configIdsOfLiveServices) {
        /* Do not replace any configurations which are linked to live services but marked as replacement
         * of another configuration. This situation will arise when a MAC basket has been created, but not 
         * yet closed.
         */
        List<Id> liveReplacedConfigIds = new List<Id>();
        for (cscfga__Product_Configuration__c config : [
            SELECT csordtelcoa__Replaced_Product_Configuration__c
            FROM cscfga__Product_Configuration__c
            WHERE cscfga__Product_Basket__r.csbb__Account__c in :accounts
            AND csordtelcoa__Replaced_Product_Configuration__c in :configIdsOfLiveServices
        ]) {
            liveReplacedConfigIds.add(config.csordtelcoa__Replaced_Product_Configuration__c);
        }
        return liveReplacedConfigIds;
    }

    private void upgradeConfigurations() {
        /*
        Upgrade all seleted configs to the latest version (only if committing results)
        LIVESVC REVIEWED
        */
        if (this.m_SaveResult) {
            cfgug1.ProductConfigurationUpgrader.upgradeConfigurations(this.m_configIds);
        }       
    }

    private void RemovePackageConfigs() {
        /*
        Remove the old Connected Workplace packages from old configs list
        //LIVESVC REVIEWED
        */
        m_configurationsToRemove = new Map<Id, cscfga__Product_Configuration__c>(
            [
                SELECT Id
                FROM cscfga__Product_Configuration__c
                WHERE Id
                In :m_productConfigsToMigrate
                AND cscfga__Product_Definition__r.Name = :c_CWP_package_name
                and cscfga__Product_Definition__r.recordtypeid = :c_package_Definition_Record_Type.Id
            ]
        );
        System.Debug('CWPMigrator: Storing old package configurations to remove ' + m_configurationsToRemove);
    }

    private void RemoveOldPCRs() {
        /*
        We need to remove any existing PCRs on the selected baskets.
        Only "Connected Workplace Solution" will be displayed in sales console
        after upgrade
        //LIVESVC REVIEWED
        */
        m_pcrsToRemove = [
            SELECT Id,
            Name
            FROM csbb__Product_Configuration_Request__c
            WHERE csbb__Product_Configuration__c 
            IN :m_productConfigsToMigrate
        ];
        System.Debug('CWPMigrator: Storing old PCRs to remove ' + m_pcrsToRemove);
    }

    private void AddGUIDsToExistingPCs(){
        /*
        * LIVESVC REVIEWED
        */
        System.Debug('CWPMigrator: AddGUIDsToExistingPCs');
        for (cscfga__Product_Configuration__c pc : m_productConfigsToMigrate)
        {
            System.Debug('CWPMigrator: AddGUIDsToExistingPCs: config = ' + pc);
            if (m_configurationsToRemove.containsKey(pc.Id)) continue;
	    String guid = createGUID();
            AddGUIDToPC(pc, guid);
        }
    }

    private void AddGUIDToPC(cscfga__Product_Configuration__c pc, String guid){
        /*
	   Add the specified guid as an attribute to the product configuration
        LIVESVC REVIEWED
        */
        Id pcId = pc.Id;
        if (pcId == null) {
            //For a configuration that's not yet stored (main configuration) use the basket id as the key.
            //This assumes a single main configuration to be added per basket
            pcId = pc.cscfga__Product_Basket__c;
        }
       // System.assert(pcId != null);
        m_pcIdToGUID.put(pcId, guid);
        AddAttributeToPC(pc, 'GUID', guid);
        AddAttributeToPC(pc, 'SolutionId', '');
        System.Debug('CWPMigrator: Added GUID ' + guid + ' to product configuration ' + pc.Id + 'basket = ' + pc.cscfga__Product_Basket__c);
    }

    private void AddAttributeToPC(cscfga__Product_Configuration__c pc, String name, String value){
        /*
        * LIVESVC REVIEWED
        */
        System.Debug('CWPMigrator: AddAttributeToPC('+pc.Id+', '+name+', '+value+')');
        System.Debug('CWPMigrator: c_pdAndName2AttributeDef = '+c_pdAndName2AttributeDef);
        cscfga__Attribute_Definition__c ad = c_pdAndName2AttributeDef.get(pc.cscfga__Product_Definition__c + name);
        if (ad == null) {
            throw new CS_Exception('Attribute definition not found for ' + name + ', ' + pc.cscfga__Product_Definition__c);
        }
	if (value == null) {
		value = ad.cscfga__Default_Value__c;
	}
        //UPDATE EXISTING ATTRIBUTE OR CREATE NEW
        if (!m_attributesOfExistingConfigs.containsKey(pc.Id + name))
        {
            System.Debug('CWPMigrator: Creating new attribute ' + name + ' = ' + value);
            cscfga__Attribute__c attribute = new cscfga__Attribute__c(
                Name = name,
                cscfga__Value__c = value,
                cscfga__Product_Configuration__c = pc.Id,
                cscfga__Attribute_Definition__c = ad.Id);
            m_attributeToConfigMap.put(attribute, pc);
            m_attributesToAdd.add(attribute);
        }
        else
        {
            cscfga__Attribute__c attribute = m_attributesOfExistingConfigs.get(pc.Id + name);
            attribute.cscfga__Value__c = value;
            System.Debug('CWPMigrator: Updating attribute ' + attribute.id + ', ' + attribute.Name + ' to ' + value);
            m_attributesToUpdate.add(attribute);
        }

    }

    private void CreateSolutionAndPCRecords(List<Id> accounts) {
        /*
        Create the CWP solution.
        Create the main Connected Workplace configuration and PCR
        //LIVESVC reviewed
        */
        for (Id acctId : accounts)
        {
            cscfga__Product_Basket__c basket = m_accountToFinalBasketMap.get(acctId);
            String guid = this.createGUID();
            cscfga__Product_Configuration__c main_config = this.createMainConfig(basket, guid);
            csord__Solution__c solution = this.CreateSolutionRecord(basket, guid);
            csbb__Product_Configuration_Request__c pcr = this.createPCR(main_config);

            AddGUIDToPC(main_config, guid);
            AddAttributeToPC(main_config, 'Solution Name', 'Connected Workplace');
            AddAttributeToPC(main_config, 'createPCRs', 'Yes');
            AddAttributeToPC(main_config, 'isMainComponent', 'Yes');
            AddAttributeToPC(main_config, 'Default Offer Name',null);

            m_accountToSolutionMap.put(acctId, solution);
            m_accountToMainConfigMap.put(acctId, main_config);
            m_config2SolutionMap.put(main_config, solution);
            m_configurationsToAdd.add(main_config);
            m_pcrsToAdd.add(pcr);
            m_pcrToPcMap.put(pcr, main_config);

            System.Debug('CWPMigrator: Create main configuration: ' + main_config);
            System.Debug('CWPMigrator: Created solution record: ' + solution);
            System.Debug('CWPMigrator: Created PCR: ' + pcr);
        }
    }

    @testvisible
    private List<migrate_attribute_wrapper> CreateAttributesJSON(cscfga__Product_Configuration__c configInstance) {
        /*Create a list of attributes for the specified configuration
        LIVESVC REVIEWED
        */
        List<migrate_attribute_wrapper> attributes = new List<migrate_attribute_wrapper>();
        return attributes;
    }

    private String createGUID() {
        /*
        What it says on the tin
        LIVESVC REVIEWED
        */
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        return guid;
    }

    private boolean IsBasketComplete(cscfga__Product_Basket__c basket) {
        /*
        Determines if basket is completed
        LIVESVC REVIEEWED
        */
        if (basket.cscfga__Basket_Status__c == 'Complete')
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    private csord__Solution__c CreateSolutionRecord(cscfga__Product_Basket__c basket, String guid) {
        /*Create new Connected Workplace Solution record for a basket (assumed to have CWP products in it TODO)
        LIVESVC REVIEWED
        */
        csord__Solution__c solution = new csord__Solution__c(
            csord__Account__c = basket.Account_Id__c,
            csord__Identification__c = c_Identification,
            csord__Status__c = c_solution_Status_complete,
            cssdm__main_product__c = guid,
            cssdm__product_basket__c = basket.Id,
            cssdm__total_contract_value__c = 0.00,
            cssdm__total_recurring_charge__c = 0.00,
            cssdm__total_one_off_charge__c = 0.00,
            Name = c_SolutionName
        );

        m_solutionsToAdd.add(solution);
        return solution;
    }

    private Attachment CreateSolutionAttachment(Id accountId){
        /*Method to create the solutionDetails.json attachment to a solution object
        * LIVESVC REVIEWED
        */
        cscfga__Product_Configuration__c mainConfig = m_accountToMainConfigMap.get(accountId);

        Id basketId = m_accountToFinalBasketMap.get(accountId).Id;

        List<SolutionWrapper> solution_components = new List<SolutionWrapper>();
        solution_components.add(SolutionWriter.CreateSolutionJSON(c_main_solution_definition, basketId, mainConfig, m_pcIdToGUID));
        for (cssdm__Solution_Definition__c sd : c_component_solution_definitions)
        {
            if (sd.cssdm__Type__c != 'Related Component') {
                System.Debug('Adding solution component for ' + sd.Name + ', ' + sd.cssdm__Type__c);
                solution_components.add(SolutionWriter.CreateSolutionJSON(sd, accountId, m_pcIdToGUID));
            }
        }

        String solution_json = JSON.serialize(solution_components);
        Attachment attachment = new Attachment();
        attachment.Body = Blob.valueOf(solution_json);
        attachment.Name = 'solutionDetails.json';
        return attachment;
    }

    private csbb__Product_Configuration_Request__c createPCR(cscfga__Product_Configuration__c config) {
        /*
        * LIVESVC REVIEWED
        */
        csbb__Product_Configuration_Request__c pcr = new csbb__Product_Configuration_Request__c(
            csbb__optionals__c = '{"selectedAddressDisplay":null}',
            csbb__product_basket__c = config.cscfga__Product_Basket__c,
            csbb__product_configuration__c = config.Id,
            csbb__status__c = 'finalized'
        );
        return pcr;
    }

    private cscfga__Product_Configuration__c createMainConfig(cscfga__Product_Basket__c basket, String guid) {
        /*
         * Create main configuration (Connected Workplace), linked to most recent or active basket
         * REVIEWED PRODUCT SELECTION LOGIC 9 SEPTEMBER
         * LIVESVC
         */
        cscfga__Product_Configuration__c config = new cscfga__Product_Configuration__c(
            cscfga__Product_Definition__c = c_CWP_product_definition.Id,
            Name = c_SolutionName,
            cscfga__billing_frequency__c = 12,
            cscfga__Contract_Term_Period__c = 12,
            cscfga__Contract_Term__c = null, //to match CS116
            cscfga__Index__c = null, //to match CS116
            cscfga__Total_Contract_Value__c = 0, //CS116
            cscfga__Total_one_off_charge__c = 0, //CS116
            cscfga__total_recurring_charge__c = 0, //CS116
            cscfga__Last_Screen_Index__c = 0, //CS116
            cscfga__Unit_Price__c = 0, //CS116
            cscfga__Recurrence_Frequency__c = 12, //CS116
            cscfga__Pricing_Status__c = 'Current', //CS116
            Cscfga__Description__c = c_SolutionName,
            Cscfga__Product_Basket__c = basket.Id,
            Cscfga__Product_Family__c = c_SolutionName
        );
        System.Debug(String.format('CWPMigrator: Created main configuration for {0}: {1}',
            new List<String> {config.cscfga__Product_Basket__c, String.valueOf(config)}));
        return config;
    }

    private void AddAttachmentToSolution(List<Id> accountIds) {
        /*
        * LIVESVC REVIEWED
        */
        for (Id acctId : accountIds) {

            cscfga__Product_Basket__c basket = m_accountToFinalBasketMap.get(acctId);
            csord__Solution__c solution = m_accountToSolutionMap.get(acctId);
            Attachment attachment = CreateSolutionAttachment(acctId);
            attachment.parentId = solution.Id;
            m_attachmentsToAdd.put(solution,attachment);
            System.Debug('CWPMigrator: linking solution ' + solution + ' to attachment ' + attachment);
        }

    }
    private void SaveResult() {
        /*
        * LIVESVC REVIEWED
        */
        List<String> insertedRecordIds = new List<String>();
	List<cscfga__Product_Configuration__c> allConfigs = new List<cscfga__Product_Configuration__c>();
        insert m_solutionsToAdd;
        for (csord__Solution__c solution : m_solutionsToAdd)
        {
            insertedRecordIds.add(solution.Id);
            //connect attachments to solution parent
        }
        
    updateServicesAndSubscriptions();
        
        for (cscfga__Product_Configuration__c config : m_configurationsToAdd)
        {
		allConfigs.add(config);
            csord__Solution__c solution = m_config2SolutionMap.get(config);
            config.cssdm__Solution_Association__c = solution.Id;
            System.Debug('CWPMigrator: setting solution association for '+config.Id + ' to ' + solution.Id);
        }
        
        insert m_configurationsToAdd;
        List<csord__Subscription__c> subscriptionsToAdd = new List<csord__Subscription__c>();
        List<csord__Service__c> servicesToAdd = new List<csord__Service__c>();

        Map<cscfga__Product_Configuration__c, csord__Subscription__c> config2SubMap = new Map<cscfga__Product_Configuration__c, csord__Subscription__c>();
        for (cscfga__Product_Configuration__c config : m_configurationsToAdd)
        {
            csord__Subscription__c sub = CreateSubscriptionForMainComponent(config);
            subscriptionsToAdd.add(sub);
            config2SubMap.put(config, sub);
            insertedRecordIds.add(config.Id);
        }
        insert subscriptionsToAdd;
        for (cscfga__Product_Configuration__c config : m_configurationsToAdd) {
            csord__Subscription__c sub = config2SubMap.get(config);
            csord__Service__c service = CreateServiceForMainComponent(config, sub);
            servicesToAdd.add(service);
        }
        insert servicesToAdd;
        
        for (csord__Service__c service : servicesToAdd) {
            insertedRecordIds.add(service.Id);
        }
        
        for (csord__Subscription__c sub : subscriptionsToAdd) {
            insertedRecordIds.add(sub.Id);
        }

        for (cscfga__Attribute__c attribute : m_attributesToAdd)
        {
            cscfga__Product_Configuration__c pc = m_attributeToConfigMap.get(attribute);
            if (pc != null)
            {
                attribute.cscfga__Product_Configuration__c = pc.Id;
            }
            else
            {
                throw new CS_Exception(String.Format('No product configuration found for attribute {0}',
                    new List<String> {attribute.Name}));
            }
        }
        insert m_attributesToAdd;
        update m_attributesToUpdate;
        
        for (cscfga__Attribute__c attribute : m_attributesToAdd)
        {
            insertedRecordIds.add(attribute.Id);
        }

        for (csbb__Product_Configuration_Request__c pcr : m_pcrsToAdd)
        {
            cscfga__Product_Configuration__c config = m_pcrToPcMap.get(pcr);
            pcr.csbb__product_configuration__c = config.Id;
        }

        //insert m_pcrsToAdd;

        for (csbb__Product_Configuration_Request__c pcr : m_pcrsToAdd)
        {
            insertedRecordIds.add(pcr.Id);
        }

        for (cscfga__Product_Configuration__c config : m_productConfigsToMigrate)
        {
		allConfigs.add(config);
            Id acctId = config.cscfga__Product_Basket__r.csbb__Account__c;
            csord__Solution__c solution = m_accountToSolutionMap.get(acctId);
            config.cssdm__Solution_Association__c = solution.Id;
            System.Debug('CWPMigrator: setting solution association for '+config.Id + ' to ' + solution.Id);
        }

        update m_productConfigsToMigrate;

        //UPDATE Solution Id attributes
        List<cscfga__Attribute__c> attrs = [SELECT Id, cscfga__Value__c, cscfga__Product_Configuration__r.cssdm__Solution_Association__c FROM cscfga__Attribute__c WHERE Name = 'SolutionId' AND (cscfga__Product_Configuration__c in :m_productConfigsToMigrate OR cscfga__Product_Configuration__c in :m_configurationsToAdd)];
        for (cscfga__Attribute__c attr : attrs)
        {
            attr.cscfga__Value__c = attr.cscfga__Product_Configuration__r.cssdm__Solution_Association__c;
        }
        update attrs;

        m_log.Inserted_Records__c = JSON.serialize(insertedRecordIds);
	CWPMigrator.updateSubscriptionReferences(m_liveServiceIds);

	//Data for attachment building
	List<Id> solutionDefinitionIds = new List<Id>();
	for (cssdm__Solution_Definition__c sd : c_component_solution_definitions) {
		solutionDefinitionIds.add(sd.Id);
	}
	SolutionWriter.LoadSolutionDefinitionSchemas(allConfigs, solutionDefinitionIds);
    }

    @future
    private static void updateSubscriptionReferences(List<Id> serviceIds) {
	    /*
	     * Update references on subscriptions which no longer point to root configuration (future method to avoid SOQL issues in triggers)
	     */
	Map<Id, Id> subToProductMap = new Map<Id, Id>();
	for (csord__Service__c liveService : [
			SELECT csordtelcoa__Product_Configuration__r.cscfga__Parent_Configuration__c,
			csord__Subscription__r.csordtelcoa__Product_Configuration__c,
			csordtelcoa__Product_Configuration__c 
			FROM csord__Service__c
			WHERE Id in :serviceIds]) {
		if (liveService.csordtelcoa__Product_Configuration__r.cscfga__Parent_Configuration__c == null) {
			if (
					liveservice.csord__Subscription__r.csordtelcoa__Product_Configuration__c 
					!= liveservice.csordtelcoa__Product_Configuration__c
			) {
				subToProductMap.put(
					liveservice.csord__Subscription__c, liveservice.csordtelcoa__Product_Configuration__c
				);
			}
		}
	}
	List<csord__Subscription__c> subs = [
		SELECT Id,
		       csordtelcoa__Product_Configuration__c
		FROM csord__Subscription__c
		WHERE Id in :subToProductMap.keySet()
	];
	List<csord__Subscription__c> subsToUpdate = new List<csord__Subscription__c>();
	for (csord__Subscription__c sub : subs) {
		sub.csordtelcoa__Product_Configuration__c = subToProductMap.get(sub.Id);
		subsToUpdate.add(sub);
	}
	update subsToUpdate;

    }

    private csord__Subscription__c CreateSubscriptionForMainComponent(cscfga__Product_Configuration__c config) {
        /*
         * Create a subscription for newly generated (but inserted) Connected Workplace Solution product configuration
         */
	    System.Debug('CWPMigrator: setting account to ' + m_id2BasketMap.get(config.cscfga__Product_Basket__c).Account_Id__c + ' from ' + config.cscfga__Product_Basket__c);
            return new csord__Subscription__c(
		Name = config.Name,
                csord__Account__c = m_id2BasketMap.get(config.cscfga__Product_Basket__c).Account_Id__c,
                cssdm__Solution_Association__c = config.cssdm__Solution_Association__c,
		csordtelcoa__Product_Configuration__c = config.Id,
		csord__Identification__c = 'Subscription'
            );
    }

    private csord__Service__c CreateServiceForMainComponent(cscfga__Product_Configuration__c config, csord__Subscription__c sub) {
        /*
         * Create a subscription for newly generated (but inserted) Connected Workplace Solution product configuration
         */
        return new csord__Service__c(
	    Name = config.Name,
            csord__Subscription__c = sub.Id, 
            csordtelcoa__Product_Configuration__c = config.Id,
            cssdm__Solution_Association__c = config.cssdm__Solution_Association__c,
	    csord__Identification__c = 'Service'
        );
    }
    private void SaveAttachment(){
        /*Store the attachments against the generated solutions
        * Requires solution.Id to be set (therefore must be run after SaveResult)
        * LIVESVC REVIEWED
        */

        for (csord__Solution__c solution : m_attachmentsToAdd.keySet())
        {
            System.Debug(String.Format('CWPMigrator: Attaching attachment to solution {0}',
                new List<String> {solution.Id}));
            Attachment attachment = m_attachmentsToAdd.get(solution);
            attachment.ParentId = solution.Id;
        }

        insert m_attachmentsToAdd.values();
    }

    private void updateServicesAndSubscriptions() {
        List<csord__Service__c> servicesToUpdate = [
        SELECT
            Id,
            csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.csbb__Account__c,
            cssdm__Solution_Association__c,
            csord__Subscription__c
        FROM
            csord__Service__c
        WHERE
            csordtelcoa__Product_Configuration__c in :m_productConfigsToMigrate
        ];
        Map<Id, Id> subscriptionToSolutionMap = new Map<Id, Id>();
        for (csord__Service__c service : servicesToUpdate) {
            csord__Solution__c solution = m_accountToSolutionMap.get(
                service.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.csbb__Account__c
            );
            service.cssdm__Solution_Association__c = solution.Id;
            subscriptionToSolutionMap.put(service.csord__Subscription__c,solution.Id);
        }
        List<csord__Subscription__c> subsToUpdate = [
        SELECT
            Id,
            cssdm__Solution_Association__c
        FROM
            csord__Subscription__c
        WHERE Id in :subscriptionToSolutionMap.keyset()
        ];
        for (csord__Subscription__c sub : subsToUpdate)
        {
            sub.cssdm__Solution_Association__c = subscriptionToSolutionMap.get(sub.Id);
        }
        update subsToUpdate;
        update servicesToUpdate;


    }
    private String makeIdAndNameSummary(List<sObject> objects) {
        /*
        * Make a comma-separated list of ids and names for the sObjects in list
        * Returned as a string for reporting/logging purposes
        * LIVESVC REVIEWED
        */
        String summary = '';
        for (sObject obj : objects)
        {
            summary = summary + String.Format('({0}: {1}), ', new List<Object> {obj.id, obj.get('Name')});
        }
        summary = summary.removeEnd(', ');
        return summary;     
    }

    private void writeLogLine(String s){
        /*
        * Write a line to debug log and also to CWP Migration log object
        * LIVESVC REVIEWED
        */
        System.debug(LoggingLevel.INFO, s);
        m_log.Log_messages__c = m_log.Log_messages__c + s + '\n';
    }

    private void WriteUpgradeSummary() {
        /*
        * Write a summary of changes made to the debug log
        * LIVESVC REVIEWED
        */
        String solutionSummary = this.m_solutionsToAdd.size() + ' solutions created: ' + makeIdAndNameSummary(m_solutionsToAdd);
        String pcrAddSummary = this.m_pcrsToAdd.size() + ' PCRs created: ' + makeIdAndNameSummary(m_pcrsToAdd);
        String pcrRemoveSummary = this.m_pcrsToRemove.size() + ' PCRs removed: ' + makeIdAndNameSummary(m_pcrsToRemove);
        String configAddSummary = this.m_configurationsToAdd.size() + ' configs added: ' + makeIdAndNameSummary(m_configurationsToAdd);
        String attributeAddSummary = this.m_attributesToAdd.size() + ' attributes added: ' + makeIdAndNameSummary(
            m_attributesToAdd);
        String configUpdatedSummary = this.m_productConfigsToMigrate.size() + 'configurations updated: ' + makeIdAndNameSummary(m_productConfigsToMigrate);
        writeLogLine(solutionSummary);
        writeLogLine(pcrAddSummary);
        writeLogLine(pcrRemoveSummary);
        writeLogLine(configAddSummary);
        writeLogLine(attributeAddSummary);
        writeLogLine(configUpdatedSummary);

    }
}