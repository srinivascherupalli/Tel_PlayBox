@IsTest
private class MigrationChangeRequestUtilTest {
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
        acc = new Account(
            Name = 'testAccount2'
        );
        insert acc;

        csord__Solution__c sol = new csord__Solution__c();
        sol.Name = 'TSol' + 4;
        sol.csord__Account__c = acc.id;
        sol.csord__Identification__c = 'SI' + 4;
        solutionList.add(sol);

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
    private static void testCreateMigrationJob() {

        csord__Solution__c solution = [Select id, csord__Account__c from csord__Solution__c where name = 'TSol4' LIMIT 1];

        List<MigrationChangeRequestUtil.MigrationChangeRequestWrapper> mcrWrappers= (List<MigrationChangeRequestUtil.MigrationChangeRequestWrapper>) JSON.deserialize(MigrationChangeRequestUtil.loadMCRs(solution.csord__Account__c, null) , List <MigrationChangeRequestUtil.MigrationChangeRequestWrapper>.class) ;
        System.assertEquals('Open', mcrWrappers[0].migrationStatus);
        System.assertEquals(solution.csord__Account__c, mcrWrappers[0].accountId);

        mcrWrappers= (List<MigrationChangeRequestUtil.MigrationChangeRequestWrapper>) JSON.deserialize(MigrationChangeRequestUtil.loadMCRs(null, mcrWrappers[0].mcr.id) , List <MigrationChangeRequestUtil.MigrationChangeRequestWrapper>.class) ;

        MigrationChangeRequestUtil.upsertMigrationJob(Json.serialize(mcrWrappers[0].mcr));
    }
}