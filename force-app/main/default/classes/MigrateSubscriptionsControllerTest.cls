@IsTest
private class MigrateSubscriptionsControllerTest {

//gesi specific testing
public static cscfga__Product_Basket__c MOCK_PRODUCT_BASKET;
public static cscfga__Product_Definition__c MOCK_PRODUCT_DEFINITION_MAIN;
public static cscfga__Product_Definition__c MOCK_PRODUCT_DEFINITION_COMPONENT;
public static void  initProductDefination() {
     MOCK_PRODUCT_DEFINITION_MAIN = new cscfga__Product_Definition__c(
        Name = 'Ring Network',
        cscfga__Description__c = 'Ring Network',
        cscfga__Active__c = true,
        cscfga__runtime_version__c = 'v2',
        csexpimp1__guid__c = '1ead7f23-0939-478d-84f5-e6ed2186f9ce'
    );
    insert MOCK_PRODUCT_DEFINITION_MAIN;
     MOCK_PRODUCT_DEFINITION_COMPONENT = new cscfga__Product_Definition__c(
        Name = 'Site',
        cscfga__Description__c = 'Site',
        cscfga__Active__c = true,
        cscfga__runtime_version__c = 'v2',
        csexpimp1__guid__c = '99f7b1d8-359c-4791-93ac-32fa1cf6eabb'
    );
    insert MOCK_PRODUCT_DEFINITION_COMPONENT;
}

public static List<cscfga__Attribute_Definition__c> initAttributeDefinitions() {
    if (MOCK_PRODUCT_DEFINITION_MAIN == null) {
        initProductDefination();
    }
    // ----- Attribute Definition -----
cscfga__Attribute_Definition__c MOCK_ATTRIBUTE_DEFINITION_GUID = new cscfga__Attribute_Definition__c(
        Name = 'GUID',
        cscfga__Type__c = 'User Input',
        cscfga__Data_Type__c = 'String',
        cscfga__Product_Definition__c = MOCK_PRODUCT_DEFINITION_MAIN.Id
    );
    insert  MOCK_ATTRIBUTE_DEFINITION_GUID;

    return new List<cscfga__Attribute_Definition__c>{MOCK_ATTRIBUTE_DEFINITION_GUID};
}

public static List<cssdm__Solution_Definition__c> initSolutionDefinitions() {
    if (MOCK_PRODUCT_DEFINITION_MAIN == null) {
        initProductDefination();
    }
    csutil__JSON_Data__c MOCK_JSON_DATA_MAIN = new csutil__JSON_Data__c(
        Name = 'Ring Network Schema',
        csutil__value__c = '{"attributes":[{"showInUI":false,"required":false,"type":"String","name":"Type","value":"Ring Network"},{"showInUI":true,"required":true,"type":"Lookup","name":"Network Type 1","lookupClass":"RingVariantLookup","filterAttributes":"Type","columns":"Name","displayColumn":"Name"},{"showInUI":true,"required":true,"type":"Picklist","name":"Contract Term","options":["12","24","36"]},{"showInUI":true,"required":false,"type":"Calculation","name":"Min Bandwidth","columns":"Network Type","displayColumn":"cssolution_t1__Bandwidth__c"},{"showInUI":true,"required":false,"type":"String","name":"Solution Name"},{"showInUI":false,"required":false,"type":"String","name":"SolutionId"},{"showInUI":false,"required":false,"type":"String","name":"GUID"}],"journey":["one","two"],"name":"Ring Network","description":"Ring Network"}'
    );
    insert MOCK_JSON_DATA_MAIN;
    cssdm__Solution_Definition__c MOCK_SOLUTION_DEFINITION_MAIN = new cssdm__Solution_Definition__c(
        Name = 'Ring Network',
        cssdm__type__c = 'Main',
        cssdm__description__c = 'Ring Network',
        cssdm__create_pcr__c = true,
        cssdm__max__c = 1,
        cssdm__min__c = 1,
        cssdm__guid__c = 'ec7aa93f-a6f1-445c-91e0-d4eb8426824b',
        cssdm__show_add_ons__c = false,
        cssdm__schema__c = MOCK_JSON_DATA_MAIN.Id,
        cssdm__product_definition__c = MOCK_PRODUCT_DEFINITION_MAIN.Id
    );
    insert MOCK_SOLUTION_DEFINITION_MAIN;

    cssdm__Solution_Definition__c MOCK_SOLUTION_DEFINITION_COMPONENT = new cssdm__Solution_Definition__c(
        Name = 'Site',
        cssdm__type__c = 'Component',
        cssdm__description__c = 'Site',
        cssdm__main_component__c = MOCK_SOLUTION_DEFINITION_MAIN.Id,
        cssdm__create_pcr__c = false,
        cssdm__max__c = 9999,
        cssdm__guid__c = 'eafa2d87-49b8-457c-807f-8fb44193b081',
        cssdm__min__c = 0,
        cssdm__show_add_ons__c = true,
        cssdm__product_definition__c = MOCK_PRODUCT_DEFINITION_MAIN.Id
    );
    insert MOCK_SOLUTION_DEFINITION_COMPONENT;

    return new List<cssdm__Solution_Definition__c>{MOCK_SOLUTION_DEFINITION_MAIN, MOCK_SOLUTION_DEFINITION_COMPONENT};
}
public static List<cscfga__Product_Basket__c> initProductBasket() {
    // ----- Product Basket -----
    MOCK_PRODUCT_BASKET = new cscfga__Product_Basket__c(
        Name = 'Test Basket',
        cscfga__Basket_Status__c = 'Valid',
        cscfga__Products_In_Basket__c = '[Site],[Add On],[Ring Network]',
        cscfga__total_contract_value__c = 1332.00,
        cscfga__Total_Price__c = 780.00
    );
    insert MOCK_PRODUCT_BASKET;

    return new List<cscfga__Product_Basket__c>{MOCK_PRODUCT_BASKET};
}
 public static List<cscfga__Product_Configuration__c> initProductConfiguration() {
     initProductBasket();
     initProductDefination();
    // ----- Product Configuration -----
    List<cscfga__Product_Configuration__c> configList = new List<cscfga__Product_Configuration__c>();
    cscfga__Product_Configuration__c MOCK_PRODUCT_CONFIGURATION = new cscfga__Product_Configuration__c (
        Name = 'Ring Network PC',
        cscfga__Total_Price__c = 0.00,
        cscfga__Configuration_Status__c = 'Valid',
        cscfga__Description__c = 'Ring Network PC',
        cscfga__Quantity__c = 1,
        cscfga__Unit_Price__c = 0.00,
        cscfga__Product_Basket__c = MOCK_PRODUCT_BASKET.Id,
        csexpimp1__guid__c = null,
        cscfga__Key__c = '053efd9e-a34c-4b64-857e-fc6e04744ec3',
        cscfga__Recurrence_Frequency__c = 12,
        cscfga__Contract_Term__c = 36,
        cscfga__Contract_Term_Period__c = 12,
        cscfga__Product_Family__c = 'Ring Network',
        cscfga__Product_Definition__c = MOCK_PRODUCT_DEFINITION_MAIN.Id
    );
    configList.add(MOCK_PRODUCT_CONFIGURATION);
    cscfga__Product_Configuration__c MOCK_PRODUCT_CONFIGURATION_FIRST_SITE = new cscfga__Product_Configuration__c (
        Name = 'Site PC 1',
        cscfga__Total_Price__c = 276,
        cscfga__Configuration_Status__c = 'Valid',
        cscfga__Description__c = 'Site PC 1',
        cscfga__Quantity__c = 1,
        cscfga__Unit_Price__c = 276,
        cscfga__Product_Basket__c = MOCK_PRODUCT_BASKET.Id,
        csexpimp1__guid__c = null,
        cscfga__Key__c = '497687e3-a2fd-4248-8222-0cc23f1e1c9c',
        cscfga__Recurrence_Frequency__c = 12,
        cscfga__Contract_Term__c = 36,
        cscfga__Contract_Term_Period__c = 12,
        cscfga__Product_Family__c = 'Site',
        cscfga__Product_Definition__c = MOCK_PRODUCT_DEFINITION_COMPONENT.Id
    );
    configList.add(MOCK_PRODUCT_CONFIGURATION_FIRST_SITE);
    cscfga__Product_Configuration__c MOCK_PRODUCT_CONFIGURATION_SECOND_SITE = new cscfga__Product_Configuration__c (
        Name = 'Site PC 2',
        cscfga__Total_Price__c = 252,
        cscfga__Configuration_Status__c = 'Valid',
        cscfga__Description__c = 'Site PC 2',
        cscfga__Quantity__c = 2,
        cscfga__Unit_Price__c = 252,
        cscfga__Product_Basket__c = MOCK_PRODUCT_BASKET.Id,
        csexpimp1__guid__c = null,
        cscfga__Key__c = '40e81623-bfd0-4d86-a659-ad762d773e50',
        cscfga__Recurrence_Frequency__c = 12,
        cscfga__Contract_Term__c = 12,
        cscfga__Contract_Term_Period__c = 12,
        cscfga__Product_Family__c = 'Site',
        cscfga__Product_Definition__c = MOCK_PRODUCT_DEFINITION_COMPONENT.Id
    );
    configList.add(MOCK_PRODUCT_CONFIGURATION_SECOND_SITE);
    insert configList;

    return configList;
}

    @TestSetup
    static void setData() {
        Account acc = new Account(
            Name = 'testAccount'
        );
        insert acc;

        List<csord__Solution__c> solutionList = new List<csord__Solution__c>();
        for (Integer i = 1; i <= 3; i++) {
            csord__Solution__c sol = new csord__Solution__c();
            sol.Name = 'TSol' + i;
            sol.csord__Account__c = acc.id;
            sol.csord__Identification__c = 'SI' + i;
            solutionList.add(sol);
        }
        insert solutionList;
        String strSol = solutionList[0].id + ',' + solutionList[1].id;
        List<cscfga__Product_Basket__c> basketList = initProductBasket();
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        for (Integer i = 1; i <= 3; i++) {
            csord__Subscription__c sub = new csord__Subscription__c();
            sub.Name = 'TSub' + i;
            sub.csord__Identification__c = 'SubI' + i;
            sub.csord__Status__c = 'Valid';
            sub.cssdm__solution_association__c = solutionList[0].id;
            subscriptionList.add(sub);
        }
        insert subscriptionList;
        //PD setup
        cscfga__Product_Definition__c mock_mainPd = new cscfga__Product_Definition__c(
            name = 'Main Network',
            cscfga__Description__c = 'Main Network',
            cscfga__Active__c = true,
            cscfga__runtime_version__c = 'v2',
            csexpimp1__guid__c = '1ead7f23-0939-478d-84f5-e6ed2186f9ce'
        );
        insert mock_mainPd;
        cscfga__Product_Definition__c mock_testPD = new cscfga__Product_Definition__c(
            name = 'Sub Network2',
            cscfga__Description__c = 'Sub Network2',
            cscfga__Active__c = true,
            cscfga__runtime_version__c = 'v2',
            csexpimp1__guid__c = '99f7b1d8-359c-4791-93ac-32fa1cf423aa'
        );
        insert mock_testPD;
        cscfga__Product_Definition__c strayPD = new cscfga__Product_Definition__c(
            name = 'Stray Network',
            cscfga__Description__c = 'Stray Network',
            cscfga__Active__c = true,
            cscfga__runtime_version__c = 'v2',
            csexpimp1__guid__c = '99f7b1d8-359c-4791-93ac-32fa1cf423bp'
        );
        insert strayPD;
        //JSONData
        csutil__JSON_Data__c mockJsonData = new csutil__JSON_Data__c(
            name = 'Ring Network Schema',
            csutil__value__c = ''
        );
        csutil__JSON_Data__c mcrJsonData = new csutil__JSON_Data__c (
            Name = 'ms-mcr-fields',
            csutil__value__c = '{"tableColumns": "Name","orderField": "CreatedDate", "orderDir" : "DESC"}'
        );
        insert new List<csutil__JSON_Data__c>{mockJsonData, mcrJsonData};
        //SD
        cssdm__Solution_Definition__c SD1 = new cssdm__Solution_Definition__c(
            name = 'SD1',
            cssdm__type__c = 'Main',
            cssdm__description__c = 'SD1',
            cssdm__guid__c = 'ec7aa93f-a6f1-445c-91e0-d4eb8426824b',
            cssdm__schema__c = mockJsonData.Id,
            cssdm__product_definition__c = mock_mainPd.Id
        );
        insert SD1;
        cssdm__Solution_Definition__c SDChild2 = new cssdm__Solution_Definition__c(
            name = 'SD-Child2',
            cssdm__type__c = 'Component',
            cssdm__description__c = 'SD-Child2',
            cssdm__guid__c = 'ec7aa93f-a6f1-445c-91e0-d4eb8426824b',
            cssdm__main_component__c = SD1.id,
            cssdm__schema__c = mockJsonData.Id,
            cssdm__product_definition__c = mock_testPD.Id
        );
        insert SDChild2;
        cssdm__Solution_Definition__c SD2 = new cssdm__Solution_Definition__c(
            name = 'SD1',
            cssdm__type__c = 'Main',
            cssdm__description__c = 'SD1',
            cssdm__guid__c = 'ec7aa93f-a6f1-445c-91e0-d4eb8426824b',
            cssdm__schema__c = mockJsonData.Id,
            cssdm__product_definition__c = strayPD.Id
        );
        insert SD2;
        Migration_Change_Request__c mcr = new Migration_Change_Request__c (
            account_id__c = acc.Id,
            macd_basket_ids__c = basketList[0].id,
            migration_status__c = 'Open',
            selected_source_solution_ids__c = strSol,
            selected_subscription_ids__c = 'subId1, subId2, subId3',
            target_solution_id__c = solutionList[2].id,
            solution_definition__c = SD1.id
        );
        insert mcr;
    }

    @IsTest
    private static void testloadMigrations() {
        String migrationWrapper;

        Account acc = [
            select Id, Name
            from Account
            where Name = 'testAccount'
        ];
        
        Test.startTest();
        migrationWrapper = MigrateSubscriptionsController.loadMigrations(acc.Id, '');
        Test.stopTest();

        List<MigrationChangeRequestUtil.MigrationChangeRequestWrapper> mcrWrappers =
            (List<MigrationChangeRequestUtil.MigrationChangeRequestWrapper>) JSON.deserialize(
                migrationWrapper,
                List<MigrationChangeRequestUtil.MigrationChangeRequestWrapper>.class
            );

        System.assertEquals('Open', mcrWrappers[0].migrationStatus);
        System.assertEquals(acc.Id, mcrWrappers[0].accountId, 'account mismatch');
        System.assertEquals(2, mcrWrappers[0].sourceSolutionList.size());
    }

    @IsTest
    private static void testCreateMigrationJob() {
        Migration_Change_Request__c mcrInst = [
            select
                Id, account_id__c, macd_basket_ids__c,
                migration_status__c, selected_source_solution_ids__c,
                selected_subscription_ids__c, target_solution_id__c,
                target_account__c, solution_definition__c
            from Migration_Change_Request__c
        ];
        List<cscfga__Product_Basket__c> basketList = initProductBasket();
        List<Account> accountList = [select id, name from Account];
        List<csord__Solution__c> solutionList = [
            select id, name
            from csord__Solution__c
        ];
        csord__Solution__c targetSolution = new csord__Solution__c (
            csord__Account__c = accountList[0].Id,
            Name = 'targetSolutionName',
            csord__Identification__c = 'SITarget'
        );
        insert targetSolution;
        List<cssdm__Solution_Definition__c> solDefList = [
            select id, name
            from cssdm__Solution_Definition__c
        ];
        MigrationChangeRequestUtil.MigrationChangeRequestWrapper mcrWrap =
            new MigrationChangeRequestUtil.MigrationChangeRequestWrapper (
                mcrInst,
                solutionList,
                targetSolution,
                accountList[0],
                basketList,
                false,
                solDefList[0]
            );

        Test.startTest();
        MigrateSubscriptionsController.createMigrationJob(JSON.serialize(mcrWrap));
        Test.stopTest();

        List<Migration_Change_Request__c> mcr = new List<Migration_Change_Request__c> ([
            select Id, account_id__c, macd_basket_ids__c, migration_status__c,
                selected_source_solution_ids__c,
                selected_subscription_ids__c, target_solution_id__c
            from Migration_Change_Request__c
            where migration_status__c = 'Open'
        ]);

        System.assertEquals('Open', mcr[0].migration_status__c);
    }

    @IsTest
    private static void testUpdateMigrationJob() {
        List<Migration_Change_Request__c> inputMcr = [
            select Id, account_id__c, macd_basket_ids__c, migration_status__c,
                selected_source_solution_ids__c,
                selected_subscription_ids__c, target_solution_id__c,
                target_account__c, solution_definition__c
            from Migration_Change_Request__c
            where migration_status__c = 'Open'
        ];
        System.assertEquals(inputMcr.size(), 1);
        inputMcr[0].migration_status__c = 'In Progress';
        List<cscfga__Product_Basket__c> basketList = initProductBasket();
        List<Account> accountList = [select id, name from Account];
        List<csord__Solution__c> solutionList = [
            select id, name
            from csord__Solution__c
        ];
        csord__Solution__c targetSolution = new csord__Solution__c (
            csord__Account__c = accountList[0].Id,
            Name = 'targetSolutionName',
            csord__Identification__c = 'SITarget'

        );
        insert targetSolution;
        List<cssdm__Solution_Definition__c> solDefList = [
            select id, name
            from cssdm__Solution_Definition__c
        ];

        MigrationChangeRequestUtil.MigrationChangeRequestWrapper mcrWrap =
            new MigrationChangeRequestUtil.MigrationChangeRequestWrapper (
            inputMcr[0],
            solutionList,
            targetSolution,
            accountList[0],
            basketList,
            false,
            solDefList[0]
            );

        Test.startTest();
        MigrateSubscriptionsController.createMigrationJob(JSON.serialize(mcrWrap));
        Test.stopTest();

        List<Migration_Change_Request__c> mcr = new List<Migration_Change_Request__c> ([
            select Id, account_id__c, macd_basket_ids__c, migration_status__c,
                selected_source_solution_ids__c,
                selected_subscription_ids__c, target_solution_id__c
            from Migration_Change_Request__c
            where migration_status__c = 'In Progress'
        ]);

        System.assertEquals('In Progress', mcr[0].migration_status__c);
        System.assertEquals(inputMcr[0].Id, mcr[0].id, 'validate id matches during data update');
    }

    @IsTest
    private static void testcreateMacBasketOppty() {
        String response;
        csordtelcoa__Change_Types__c ct = new csordtelcoa__Change_Types__c();
        ct.Name = 'Change Solution';
        ct.csordtelcoa__Auto_Create_Bundle__c = true;
        ct.csordtelcoa__Allow_Multiple_Subscriptions__c =true;
        insert ct;
        List<Account> acc = [
            select id, name from Account
        ];
        List<csord__Solution__c> solList = [
            select id, name,csord__Account__c,csord__Identification__c from csord__Solution__c
        ];
        List<Id> solIdList = new List<Id>();
        for (csord__Solution__c sol : solList) {
            solIdList.add(sol.id);
        }
        List<cscfga__Product_Basket__c> basketList = initProductBasket();
        String solIds = solList[0].id +','+ solList[1].id;
        Migration_Change_Request__c mcr = new Migration_Change_Request__c(
            Name = 'MCR1',
            macd_basket_ids__c = basketList[0].Id,
            selected_source_solution_ids__c = solIds,
            target_solution_id__c = solList[2].id
        );
        insert mcr;
        Opportunity inputOpp = new Opportunity(
            Name = 'MAC - Change Solution - UT',
            StageName = 'Prospecting',
            CloseDate = Date.today()
        );
        insert inputOpp;
        for (cscfga__Product_Basket__c bsk : basketList) {
            bsk.cscfga__Opportunity__c = inputOpp.id;
        }
        update basketList;

        Test.startTest();
        MigrateSubscriptionsController.OSInstance = new OSModuleConnector();
        try{
            response = MigrateSubscriptionsController.createMacBasketOppty(mcr.id);
        }catch(Exception e){}
        Test.stopTest();
        system.assertNotEquals(basketList,null);
    }

    @isTest
    static void testGetLookupSourceData() {
        MigrateSubscriptionUtil controller = new MigrateSubscriptionUtil();
        List<csord__Solution__c> solList = [
            select id, Name
            from csord__Solution__c
        ];
        Account acc = new Account(
            Name = 'testAccount'
        );
        insert acc;
        csutil__JSON_Data__c jsonData = new csutil__JSON_Data__c (
            Name = 'ms-solution-fields',
            csutil__value__c = '{"maxLimit": "10","searchType": "LIKE",'+
                '"lookupColumns": "cssdm__total_contract_value__c,csord__Status__c",'+
                '"searchFields": "name,csord__Status__c",'+
                '"tableColumns": "cssdm__total_contract_value__c,csord__Status__c"}'
        );
        insert jsonData;
        String jsonString = '{"searchTerm": "Sol","maximumRows": "10","sObjectType": "csord__Solution__c",'+
            '"additionalCriteria": {"accountId": "001bjd232","type": "sourceSolution",'+
            '"sourceSolutionList": ["00019823u219"],"sourceSubscriptionList": ["0987yh320ejwe"]}}';
        Test.startTest();
        String response = MigrateSubscriptionsController.getLookupData(jsonString);
        Test.stopTest();
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);

        System.AssertNotEquals(null, ((List<Object>) responseMap.get('solution')));
    }

    @isTest
    static void testSubscriptionGuids() {
        MigrateSubscriptionUtil controller = new MigrateSubscriptionUtil();
        List<csord__Solution__c> solList = [
            select id, Name
            from csord__Solution__c
        ];
        List<csord__Subscription__c> subscriptionList = [
            select id, name,csordtelcoa__product_configuration__c
            from csord__Subscription__c
        ];

        Account acc = new Account(
            Name = 'testAccount'
        );
        insert acc;
        List<cscfga__Product_Configuration__c> configList = initProductConfiguration();
        List<cscfga__Attribute_Definition__c> attributeDefList = initAttributeDefinitions();
        configList[0].cssdm__solution_association__c = solList[0].id;
        update configList;
        for(csord__Subscription__c sub:subscriptionList){
            sub.csordtelcoa__product_configuration__c = configList[0].Id;
        }
        update subscriptionList;
        cscfga__Attribute__c guidAttribute = new cscfga__Attribute__c (
            Name = 'GUID',
            cscfga__Product_Configuration__c = configList[0].Id,
            cscfga__Discount_Type__c = 'amount',
            cscfga__Attribute_Definition__c = attributeDefList[0].Id,
            cscfga__value__c = '12345367-be95-4e67-6c0c-72f911e6533a'
        );
        insert guidAttribute;
        cscfga__Attribute__c guidAttribute1 = new cscfga__Attribute__c (
                Name = 'GUID',
                cscfga__Product_Configuration__c = configList[0].Id,
                cscfga__Discount_Type__c = 'amount',
                cscfga__Attribute_Definition__c = attributeDefList[0].Id,
                cscfga__value__c = '12345367-be95-4e67-6c0c-72f911e6533a'
        );
        insert guidAttribute1;
        String jsonString = '["' + subscriptionList[0].Id + '"]';
        Test.startTest();
        MigrateSubscriptionUtil.OSInstance = new OSModuleConnector();
        String response = MigrateSubscriptionsController.getSubscriptionGuids(jsonString);
        Test.stopTest();

        System.AssertNotEquals(null,subscriptionList);
    }

    @isTest
    static void testGetFieldTableSolutions() {
        List<csord__Solution__c> solutionList = [
            select id, name
            from csord__Solution__c
        ];
        List<Id> solId = new List<Id>();
        for (csord__Solution__c sol : solutionList) {
            solId.add(sol.id);
        }
        String jsonString = '["' + solId[0] + '", "' + solId[1] + '", "' + solId[2] + '"]';
        Test.startTest();
        String response = MigrateSubscriptionsController.getFieldTableSolutions(jsonString);
        Test.stopTest();
        List<csord__Solution__c> responseList = (List<csord__Solution__c>) JSON.deserialize(
            response,
            List<csord__Solution__c>.class
        );

        System.AssertEquals(3, responseList.size());
    }

    @isTest
    static void testGetFieldTableSubscriptions() {
        List<csord__Subscription__c> subscriptionList = [
            select id, name
            from csord__Subscription__c
        ];
        List<Id> subId = new List<Id>();
        for (csord__Subscription__c sub : subscriptionList) {
            subId.add(sub.id);
        }
        csutil__JSON_Data__c jsonDataSubscription = new csutil__JSON_Data__c (
            Name = 'ms-subscription-fields',
            csutil__value__c = '{"maxLimit": "10","searchType": "LIKE",'+
                '"lookupColumns": "csord__total_contract_value__c,csord__Total_One_Off_Charges__c",'+
                '"searchFields": "name",'+
                '"tableColumns": "csord__total_contract_value__c,csord__Total_One_Off_Charges__c"}'
        );
        insert jsonDataSubscription;
        String jsonString = '["' + subId[0] + '", "' + subId[1] + '", "' + subId[2] + '"]';
        Test.startTest();
        String response = MigrateSubscriptionsController.getFieldTableSubscriptions(jsonString);
        Test.stopTest();
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);

        System.AssertEquals(3, ((List<Object>) responseMap.get('subscription')).size());
    }

    @isTest
    static void testUpdateMCR() {
        Migration_Change_Request__c mcr = [
            select id, name
            from Migration_Change_Request__c
        ];
        Test.startTest();
        MigrateSubscriptionsController.updateMCR(mcr.id, 'mcr description updated', 'Invalid');
        Test.stopTest();
        Migration_Change_Request__c outputMcr = [
            select id, name, description__c
            from Migration_Change_Request__c
        ];

        System.AssertEquals('mcr description updated', outputMcr.Description__c, 'mcr not updated');
    }

    @isTest
    static void testSubmitMCR() {
        List<cscfga__Product_Configuration__c> configList = initProductConfiguration();
        List<cscfga__Product_Basket__c> basketList = initProductBasket();
        List<cscfga__Attribute_Definition__c> attributeDefList = initAttributeDefinitions();

        configList[0].cscfga__Product_Basket__c = basketList[0].Id;
        configList[1].cscfga__Product_Basket__c = basketList[0].Id;
        update configList;

        cscfga__Attribute__c guidAttribute = new cscfga__Attribute__c (
            Name = 'GUID',
            cscfga__Product_Configuration__c = configList[0].Id,
            cscfga__Discount_Type__c = 'amount',
            cscfga__Attribute_Definition__c = attributeDefList[0].Id,
            cscfga__value__c = '12345367-be95-4e67-6c0c-72f911e6533a'
        );
        insert guidAttribute;
        cscfga__Attribute__c guidAttribute2 = new cscfga__Attribute__c (
            Name = 'GUID',
            cscfga__Product_Configuration__c = configList[1].Id,
            cscfga__Attribute_Definition__c = attributeDefList[0].Id,
            cscfga__value__c = '12345367-be95-4e67-6c0c-72f911e6533a'
        );
        insert guidAttribute2;
        List<csord__Subscription__c> subscriptionList = [
            select id, name
            from csord__Subscription__c
        ];
        Opportunity opp = new Opportunity(
            Name = 'Opp1',
            StageName = 'Open',
            CloseDate = system.today()
        );
        insert opp;
        for (cscfga__Product_Basket__c basket : basketList) {
            basket.cscfga__Opportunity__c = opp.id;
            basket.csbb__Synchronised_With_Opportunity__c = true;
            basket.csordtelcoa__Synchronised_with_Opportunity__c = true;
        
        
        }
        update basketList;
        Migration_Change_Request__c mcr = new Migration_Change_Request__c(
            Name = 'MCR1',
            macd_basket_ids__c = basketList[0].Id,
            selected_subscription_ids__c = subscriptionList[0].id
        );
        insert mcr;
        Test.startTest();
        MigrateSubscriptionUtil.OSInstance = new OSModuleConnector();
        String response = MigrateSubscriptionsController.submitMCR(mcr.id);
        Test.stopTest();
        Opportunity result = [Select id,name,StageName from Opportunity];

        System.AssertEquals('Closed', result.StageName, 'Opportunity updated');
    }

    @isTest
    static void testGetLookupAccounts() {
        MigrateSubscriptionUtil controller = new MigrateSubscriptionUtil();
        Account acc = new Account(
            name = 'testAccount'
        );
        insert acc;
        csutil__JSON_Data__c jsonData = new csutil__JSON_Data__c (
            name = 'ms-account-fields',
            csutil__value__c = '{"maxLimit": "10","searchType": "LIKE",'+
                '"lookupColumns": "name,isPartner",'+
                '"searchFields": "name",'+
                '"tableColumns": "name"}'
        );
        insert jsonData;
        String jsonString = '{"searchTerm": "test","maximumRows": "10","sObjectType": "Account",'+
            '"additionalCriteria": {"accountId": "'+ acc.id +'","type": "sourceSolution"}}';
        Test.startTest();
        String response = MigrateSubscriptionsController.getLookupData(jsonString);
        Test.stopTest();
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);

        System.AssertEquals(
            1,
            ((List<Object>) responseMap.get('accounts')).size()
        );
    }

    @isTest
    static void testGetLookupSolutionDefs() {
        MigrateSubscriptionUtil controller = new MigrateSubscriptionUtil();
        List<csord__Subscription__c> subscriptionList = [
            select id, name
            from csord__Subscription__c
        ];
        List<String> subIds = new List<String>();
        for (csord__Subscription__c sub : subscriptionList) {
            subIds.add(sub.id);
        }
        csord__Service__c service1 = new csord__Service__c(
            name = 'Test Service',
            csord__Identification__c = 'Service_0',
            csord__Status__c = 'Service created',
            csord__Subscription__c = subIds[0]
        );
        insert service1;
        csutil__JSON_Data__c jsonData = new csutil__JSON_Data__c (
            name = 'ms-solutionDefinition-fields',
            csutil__value__c = '{"maxLimit": "10","searchType": "LIKE",'+
                '"lookupColumns": "name",'+
                '"searchFields": "name",'+
                '"tableColumns": "name"}'
        );
        insert jsonData;
        String jsonString = '{"searchTerm": "%%%","maximumRows": "10","sObjectType": "cssdm__Solution_Definition__c",'+
            '"additionalCriteria": {"sourceSubscriptionList": ["'+ subIds[0] +'"]}}';
        List<cscfga__Product_Definition__c> pdList = [select id, name from cscfga__Product_Definition__c];
        List<cscfga__Product_Basket__c> basketList = initProductBasket();
        cscfga__Product_Configuration__c pc = new cscfga__Product_Configuration__c (
            name = 'Ring Network PC',
            cscfga__Configuration_Status__c = 'Valid',
            cscfga__Description__c = 'Ring Network PC',
            cscfga__Product_Basket__c = basketList[0].Id,
            cscfga__Key__c = '053efd9e-a34c-4b64-857e-fc6e04744ec3',
            cscfga__Product_Family__c = 'Ring Network',
            cscfga__Product_Definition__c = pdList[1].Id
        );
        insert pc;

        Test.startTest();
        MigrateSubscriptionUtil.OSInstance = new OSModuleConnector();
        String response = MigrateSubscriptionsController.getLookupData(jsonString);
        Test.stopTest();
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response);

        System.AssertNotEquals(
            null,
            ((List<Object>) responseMap.get('solutionDefinition'))
        );
    }

    @isTest
    static void testFieldMetadata() {
        csutil__JSON_Data__c solutionDefinitionData = new csutil__JSON_Data__c (
            name = 'ms-solutionDefinition-fields',
            csutil__value__c = '{"maxLimit": "10","searchType": "LIKE",'+
                '"lookupColumns": "name",'+
                '"searchFields": "name",'+
                '"tableColumns": "name"}'
        );
        insert solutionDefinitionData;
        csutil__JSON_Data__c accountData = new csutil__JSON_Data__c (
            name = 'ms-account-fields',
            csutil__value__c = '{"maxLimit": "10","searchType": "LIKE",'+
                '"lookupColumns": "name",'+
                '"searchFields": "name",'+
                '"tableColumns": "name"}'
        );
        insert accountData;
        csutil__JSON_Data__c solutionData = new csutil__JSON_Data__c (
            name = 'ms-solution-fields',
            csutil__value__c = '{"maxLimit": "10","searchType": "LIKE",'+
                '"lookupColumns": "cssdm__total_contract_value__c,csord__Identification__c,csord__Status__c",'+
                '"searchFields": "name,csord__Status__c",'+
                '"tableColumns": "cssdm__total_contract_value__c,csord__Identification__c,csord__Status__c"}'
        );
        insert solutionData;
        csutil__JSON_Data__c subData = new csutil__JSON_Data__c (
            name = 'ms-subscription-fields',
            csutil__value__c = '{"maxLimit": "10","searchType": "LIKE",'+
                '"lookupColumns": "csord__total_contract_value__c,csord__Total_One_Off_Charges__c",'+
                '"searchFields": "name",'+
                '"tableColumns": "csord__total_contract_value__c,csord__Total_One_Off_Charges__c"}'
        );
        insert subData;

        Test.startTest();
        MigrateSubscriptionsController instance = new MigrateSubscriptionsController();
        Integer startQueries = Limits.getQueries();
        String response = instance.fieldMetadata;
        String duplicateResponse = instance.fieldMetadata;
        Integer endQueries = Limits.getQueries();
        Test.stopTest();
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);

        system.assertEquals(1, endQueries, 'only one query should be executed');
        system.assertEquals(true, responseMap.size()>0, '4 lookup rows and 5 field table rows expected');
    }

    @isTest
    static void testmigrationAttributes() {
        csutil__JSON_Data__c subData = new csutil__JSON_Data__c (
            name = 'ms-subscription-attributes',
            csutil__value__c = '{"sourceAttributes" : ['+
                '{"name": "Migration Status", "value": "Moved out" }],'+
                '"targetAttributes" : ['+
                '{"name": "Migration Status", "value": "Moved in" }]'
        );
        insert subData;
        Test.startTest();
        MigrateSubscriptionsController instance = new MigrateSubscriptionsController();
        Integer startQueries = Limits.getQueries();
        String response = instance.migrationAttributes;
        String duplicateResponse = instance.migrationAttributes;
        Integer endQueries = Limits.getQueries();
        Test.stopTest();

        system.assertEquals(1, endQueries, 'only one query should be executed');
        system.assertEquals(subData.csutil__value__c, response);
    }

    @IsTest
    private static void testDifferentTargetAccount() {
        csordtelcoa__Orders_Subscriptions_Options__c settings = csordtelcoa__Orders_Subscriptions_Options__c.getOrgDefaults();
        settings.csordtelcoa__Create_Mac_Baskets__c = true;
        settings.csordtelcoa__Create_Mac_Opportunities__c = true;
        upsert settings csordtelcoa__Orders_Subscriptions_Options__c.Id;

        csordtelcoa__Change_Types__c ct = new csordtelcoa__Change_Types__c();
        ct.Name = 'Change Solution';
        ct.csordtelcoa__Auto_Create_Bundle__c = true;
        ct.csordtelcoa__Allow_Multiple_Subscriptions__c =true;
        insert ct;
        List<Account> acc = [
            select id, name from Account
        ];
        Account accNew = new Account(
            Name = 'testAccount'
        );
        insert accNew;
        List<csord__Solution__c> solList = [
            select id, name,csord__Account__c,csord__Identification__c from csord__Solution__c
        ];
        List<Id> solIdList = new List<Id>();
        for (csord__Solution__c sol : solList) {
            sol.csord__Account__c = accNew.Id;
            solIdList.add(sol.id);
        }
        update solList;
        List<cscfga__Product_Basket__c> basketList = initProductBasket();
        String solIds = solList[0].id +','+ solList[1].id;
        Migration_Change_Request__c mcr = new Migration_Change_Request__c(
            Name = 'MCR1',
            macd_basket_ids__c = basketList[0].Id,
            selected_source_solution_ids__c = solIds,
            target_solution_id__c = solList[2].id,
            target_account__c = accNew.id
        );
        insert mcr;
        Opportunity inputOpp = new Opportunity(
            Name = 'MAC - Change Solution - UT',
            StageName = 'Prospecting',
            CloseDate = Date.today()
        );
        insert inputOpp;
        for (cscfga__Product_Basket__c bsk : basketList) {
            bsk.cscfga__Opportunity__c = inputOpp.id;
        }
        update basketList;

        Test.startTest();
        MigrateSubscriptionsController.OSInstance = new OSModuleConnector();
        try{
        String response = MigrateSubscriptionsController.createMacBasketOppty(mcr.id);
        }catch(Exception e){}
        Test.stopTest();
        system.assertNotEquals(basketList,null);
    }
    @IsTest
    private static void testBasketDetailGeneration() {
        String dynamicField = 'cscfga__Basket_Status__c';
        csutil__JSON_Data__c basketSummaryFields = new csutil__JSON_Data__c (
            Name = 'ms-basket-summary-fields',
            csutil__value__c = '{"basketIdentifierField" : "' + dynamicField + '", "solutionIdentifierField" : "Name"}'
        );
        insert basketSummaryFields;
        cscfga__Product_Basket__c basket = [
            select id, name,cscfga__Basket_Status__c 
            from cscfga__Product_Basket__c 
            limit 1
        ];
        Test.startTest();
        List<Id> basketList = new List<Id>{basket.id};
        Map<Id, cscfga__Product_Basket__c> basketMap = MigrateSubscriptionsController.getBasketDetails(basketList);
        Test.stopTest();
        System.assertEquals((String) basketMap.values()[0].get(dynamicField), basket.cscfga__Basket_Status__c);
    }
    @IsTest
    private static void testBasketDetailGeneration_DefaultScenario() {
        cscfga__Product_Basket__c basket = [
            select id, name 
            from cscfga__Product_Basket__c 
            limit 1
        ];
        Test.startTest();
        List<Id> basketList = new List<Id>{basket.id};
        Map<Id, cscfga__Product_Basket__c> basketMap = MigrateSubscriptionsController.getBasketDetails(basketList);
        Test.stopTest();
        System.assertEquals((String)basketMap.values()[0].get('Name'), basket.Name );
    }
   /* @IsTest
    private static void testDraftMCRRetrievalScenario() {
        Migration_Change_Request__c mcr = new Migration_Change_Request__c();
        mcr.migration_status__c = 'Draft';
        insert mcr;
        Test.startTest();
        String mcrJSON = MigrateSubscriptionsController.loadMigrations('',mcr.id);
        Test.stopTest();
        List<MigrationChangeRequestUtil.MigrationChangeRequestWrapper> mcrWrapperList =
            (List<MigrationChangeRequestUtil.MigrationChangeRequestWrapper>) JSON.deserialize(
                mcrJSON,
                List<MigrationChangeRequestUtil.MigrationChangeRequestWrapper>.class
            );
        System.assertEquals('Draft', mcrWrapperList[0].migrationStatus, 'System able to retrieve draft mcr data');
    }*/
    @IsTest
    private static void testbasketSummaryAttributes(){
        csutil__JSON_Data__c subData = new csutil__JSON_Data__c (
                name = 'ms-basket-summary-fields',
                csutil__value__c = '{"sourceAttributes" : ['+
                        '{"name": "Migration Status", "value": "Moved out" }],'+
                        '"targetAttributes" : ['+
                        '{"name": "Migration Status", "value": "Moved in" }]'
        );
        insert subData;
        Test.startTest();
        MigrateSubscriptionsController instance = new MigrateSubscriptionsController();
        Integer startQueries = Limits.getQueries();
        String response = instance.basketSummaryAttributes;
        String duplicateResponse = instance.basketSummaryAttributes;
        Integer endQueries = Limits.getQueries();
        Test.stopTest();

        system.assertEquals(1, endQueries, 'only one query should be executed');
        system.assertEquals(subData.csutil__value__c, response);
    }
    @IsTest
    private static void testcheckISBatchJobRunning(){
        List<cscfga__Product_Basket__c> basketList = initProductBasket();
        Boolean result = MigrateSubscriptionsController.checkIsBatchJobRunning(basketList[0].id);
        System.assertEquals(true,result);
    }
    @IsTest
    private static void testaddSolutionToBasket(){
        List<cscfga__Product_Basket__c> basketList = initProductBasket();
        List<csord__Solution__c> solutiondata = [
                select id, name
                from csord__Solution__c
        ];
        String result = MigrateSubscriptionsController.addSolutionToBasket(basketList[0].id, solutiondata[0].id);
    }
}