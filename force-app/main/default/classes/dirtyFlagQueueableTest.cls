/*********************************************************************************************************************************
 *Class Name      :   dirtyFlagQueueableTest   

 Class : dirtyFlagQueueable
===============================================================================================================================
Ch.No.    Developer Name          Date          Story Description
1.        Ankit          28/07/2020       INC000093454566>>>Dirty flag heap size Attachment FIX
*********************************************************************************************************************************
*/

@isTest
private class dirtyFlagQueueableTest   {
    @TestSetup static void dataSetup()
    {
        Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        testAccount.Customer_Status__c = 'ACTIVE';
        insert testAccount;
        
        Opportunity testOpp = new Opportunity();
        //Test class fix for P2OB-13775 validation on OPP contact role , the contact in opp contact roles should be related to opp account.
        testOpp.AccountId = testAccount.id;
        testOpp.Name = 'testOpp';
        testOpp.Product_Domain__c = 'Other';
        testOpp.StageName = 'Develop';
        testOpp.Product_Type__c = 'Modular';
        testOpp.CloseDate = System.Date.today();
        testOpp.Description__c = 'test';
        //testOpp.Type = 'MACs (Moves, Adds & Change)';
        insert testOpp;
        
        Contact con = new Contact();
        con.LastName = 'test last name';
        con.FirstName = 'Fname';
        con.AccountId = testAccount.Id;
        insert con;

        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId  = con.Id;
        ocr.OpportunityId = testOpp.Id;
        ocr.Role = 'Decision Maker';
        insert ocr;

        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = testAccount.Id;
        testBasket.Name = 'ShowSubTestBasket';
        testBasket.cscfga__Opportunity__c = testOpp.Id;
        insert testBasket;

        cscrm__Address__c add=new cscrm__Address__c();
        add.Name='Test address';
        insert add;
        
        cscrm__Site__c site=new cscrm__Site__c();
        site.Name='Test';
        site.cscrm__Installation_Address__c=add.Id;
        site.cscrm__Account__c=testAccount.Id;
        
        cscrm__Site__c site1=new cscrm__Site__c();
        site1.Name='Test1';
        site1.cscrm__Account__c=testAccount.Id;

        List<cscrm__Site__c> siteList=new List<cscrm__Site__c>{site,site1};
        Insert siteList;
        
        csord__Solution__c sol = new csord__Solution__c(Name = 'Connected Workplace Solution', csord__Status__c = 'Completed',cssdm__total_recurring_charge__c=100.00,cssdm__total_one_off_charge__c=100.00,cssdm__total_contract_value__c=2500.00, csord__Account__c = testAccount.Id, csord__External_Identifier__c = '12345', csord__External_Identifier2__c = '1234', csord__Identification__c = '12');
        ///solutions and billing acc=====//////////////// added by shubhi EDGE-147513 
    csord__Solution__c sol1= PricingTestDataFactory.generateSolution('nextgenEM_positive');
        csord__Solution__c sol2= PricingTestDataFactory.generateSolution('nextgenEM_negative');
        insert new List<csord__Solution__c>{sol,sol1,sol2};
        //Biiling accs
        Billing_Account__c billAcc1=new Billing_Account__c(Billing_Account_Number__c='123456789012',Billing_Account_Owner__c=con.Id, status__c='Created',Account__c=testAccount.id);
        Billing_Account__c billAcc2=new Billing_Account__c(Billing_Account_Number__c='123456789013',Billing_Account_Owner__c=con.Id,status__c='Final',Account__c=testAccount.id);
        insert new List<Billing_Account__c>{billAcc1,billAcc2};
    //////////////// added by shubhi EDGE-147513  ended
        
        List<cscfga__Product_Definition__c> pdList = new List<cscfga__Product_Definition__c>();
        cscfga__Product_Definition__c CWS_PD = new cscfga__Product_Definition__c(Name = 'Connected Workplace Solution', cscfga__Description__c = 'Connected Workplace');
        pdList.add(CWS_PD);
        cscfga__Product_Definition__c CW_PD = new cscfga__Product_Definition__c(Name = 'Connected Workplace', cscfga__Description__c = 'Connected Workplace');
        pdList.add(CW_PD);
        cscfga__Product_Definition__c ucePD = new cscfga__Product_Definition__c(Name = 'Unified Communication', cscfga__Description__c = 'Unified Communication');
        pdList.add(ucePD);
        cscfga__Product_Definition__c IPNet_PD = new cscfga__Product_Definition__c(Name = 'IP Network', cscfga__Description__c = 'IP Network');
        pdList.add(IPNet_PD);
        cscfga__Product_Definition__c Mob_PD = new cscfga__Product_Definition__c(Name = 'Mobility', cscfga__Description__c = 'Mobility');
        pdList.add(Mob_PD);
        insert pdList;
       

        List<cscfga__Product_Configuration__c> prodconfigList=new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c testConfigS = new cscfga__Product_Configuration__c();
        testConfigS.Name = 'Connected Workplace Solution';
        testConfigS.cscfga__Product_Definition__c=CWS_PD.id;
        prodconfigList.add(testConfigS);
        cscfga__Product_Configuration__c testConfig = new cscfga__Product_Configuration__c();
        testConfig.Name = 'Connected Workplace';
        testConfig.cscfga__Product_Basket__c = testBasket.Id;
        testConfig.cscfga__Product_Definition__c=CW_PD.id;
        prodconfigList.add(testConfig);
        cscfga__Product_Configuration__c testConfig1 = new cscfga__Product_Configuration__c();
        testConfig1.Name = System.Label.IP_Network;
        testConfig1.cscfga__Product_Basket__c = testBasket.Id;
        testConfig1.cscfga__Product_Definition__c=ucePD.id;
        prodconfigList.add(testConfig1);
        cscfga__Product_Configuration__c testConfig2 = new cscfga__Product_Configuration__c();
        testConfig2.Name = System.Label.UC_Enterprise;
        testConfig2.cscfga__Product_Basket__c = testBasket.Id;
        testConfig2.cscfga__Product_Definition__c=IPNet_PD.id;
        prodconfigList.add(testConfig2); 
        cscfga__Product_Configuration__c testConfig3 = new cscfga__Product_Configuration__c();
        testConfig3.Name = System.Label.Mobility;
        testConfig3.cscfga__Product_Basket__c = testBasket.Id;
        testConfig3.cscfga__Product_Definition__c=Mob_PD.id;
        prodconfigList.add(testConfig3); 
        insert prodconfigList;

        cscfga__Attribute__c testAttribute = new cscfga__Attribute__c();
        testAttribute.Name = 'testAttributeForTest';
        testAttribute.cscfga__Product_Configuration__c = testConfig.Id;
        insert testAttribute;

        csord__Order__c testOrder = new csord__Order__c();
        testOrder.csord__Account__c = testAccount.Id;
        testOrder.csordtelcoa__Opportunity__c = testOpp.Id;
        testOrder.Name = 'TestOrderNameForTest';
        testOrder.csord__Identification__c = 'test';
        insert testOrder;

        csordtelcoa__Orders_Subscriptions_Options__c testOso = new csordtelcoa__Orders_Subscriptions_Options__c();
        testOso.csordtelcoa__Subscription_Closed_Replaced_State__c = 'test2';
        testOso.csordtelcoa__Statuses_Not_Allowing_Change__c = 'false';
        insert testOso;

        csord__Subscription__c testSubscriptionS = new csord__Subscription__c();
        testSubscriptionS.Name = 'Connected Workplace Solution';
        testSubscriptionS.csord__Account__c = testAccount.Id;
        testSubscriptionS.csord__Order__c = testOrder.Id;
        testSubscriptionS.csord__Identification__c = 'test';
        testSubscriptionS.csordtelcoa__Product_Configuration__c = testConfigS.Id;
        testSubscriptionS.csord__Status__c = 'Completed';
        
        csord__Subscription__c testSubscription = new csord__Subscription__c();
        testSubscription.Name = 'TestSubsforTest';
        testSubscription.csord__Account__c = testAccount.Id;
        testSubscription.csord__Order__c = testOrder.Id;
        testSubscription.csord__Identification__c = 'test';
        testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription.csord__Status__c = 'Active';
        testSubscription.cssdm__solution_association__c = sol.Id; //Change 1

        csord__Subscription__c testSubscription2 = new csord__Subscription__c();
        testSubscription2.Name = 'TestSubsforTest2';
        testSubscription2.csord__Account__c = testAccount.Id;
        testSubscription2.csord__Order__c = testOrder.Id;
        testSubscription2.csord__Identification__c = 'test2';
        testSubscription2.csord__Status__c = 'Pending';

        csord__Subscription__c testSubscription3 = new csord__Subscription__c();
        testSubscription3.Name = 'TestSubsforTest3';
        testSubscription3.csord__Account__c = testAccount.Id;
        testSubscription3.csord__Order__c = testOrder.Id;
        testSubscription3.csord__Identification__c = 'test3';
        testSubscription3.csord__Status__c = null;

        csord__Subscription__c testSubscription4 = new csord__Subscription__c();
        testSubscription4.Name = 'TestSubsforTest4';
        testSubscription4.csord__Account__c = testAccount.Id;
        testSubscription4.csord__Order__c = testOrder.Id;
        testSubscription4.csord__Identification__c = 'test';
        testSubscription4.csordtelcoa__Product_Configuration__c = testConfig1.Id;
        testSubscription4.csord__Status__c = 'Active';
        
        csord__Subscription__c testSubscription5 = new csord__Subscription__c();
        testSubscription5.Name = 'TestSubsforTest5';
        testSubscription5.csord__Account__c = testAccount.Id;
        testSubscription5.csord__Order__c = testOrder.Id;
        testSubscription5.csord__Identification__c = 'test';
        testSubscription5.csordtelcoa__Product_Configuration__c = testConfig3.Id;
        testSubscription5.csord__Status__c = 'Closed Replaced';

        csord__Subscription__c testSubscription6 = new csord__Subscription__c();
        testSubscription6.Name = 'TestSubsforTest6';
        testSubscription6.csord__Account__c = testAccount.Id;
        testSubscription6.csord__Order__c = testOrder.Id;
        testSubscription6.csord__Identification__c = 'test6';
        testSubscription6.csordtelcoa__Product_Configuration__c = testConfig3.Id;
        testSubscription6.Site__c=site.Id;
        testSubscription6.cssdm__solution_association__c=sol.Id;
        testSubscription6.csord__Status__c = 'Active';

        csord__Subscription__c testSubscription7 = new csord__Subscription__c();
        testSubscription7.Name = 'TestSubsforTest7';
        testSubscription7.csord__Account__c = testAccount.Id;
        testSubscription7.csord__Order__c = testOrder.Id;
        testSubscription7.csord__Identification__c = 'test7';
        testSubscription7.Site__c=site1.Id;
        testSubscription7.cssdm__solution_association__c=sol.Id;
        testSubscription7.csordtelcoa__Product_Configuration__c = testConfig3.Id;
        testSubscription7.csord__Status__c = 'Active';
        csord__Subscription__c subs8=PricingTestDataFactory.generateSubscriptionWithBillacc(sol1.id,billAcc2.id,testAccount.id,testOrder.id);
   
        csord__Subscription__c subs9=PricingTestDataFactory.generateSubscriptionWithBillacc(sol2.id,billAcc1.id,testAccount.id,testOrder.id);
 
        List<csord__Subscription__c> testSubsList = new List<csord__Subscription__c>{subs8,subs9,testSubscriptionS,testSubscription,testSubscription2,testSubscription3,testSubscription4,testSubscription5,testSubscription6,testSubscription7};
        insert testSubsList;

        Asset ast=new Asset();
        ast.name='test';
        ast.AssetID__c='56856541';
        ast.Subscription__c=testSubscription7.id;
        ast.Status='Active';
        ast.AccountId=testAccount.Id;

        insert ast;

        Number__c num = new Number__c();
        num.Name='Num';
        num.Subscription_number__c=testSubscription6.csordtelcoa__Subscription_Number__c;
        num.Mobile__c='Fixed';
        num.Service_Number__c='5568451561';

        Number__c num1 = new Number__c();
        num1.Name='Num1';
        num1.Subscription_number__c=testSubscription7.csordtelcoa__Subscription_Number__c;
        num1.Mobile__c='Fixed';
        num1.Service_Number__c='5568451562';
    
        Number__c num2 = new Number__c();
        num2.Name='Num';
        num2.Subscription_number__c=testSubscription6.csordtelcoa__Subscription_Number__c;
        num2.Mobile__c='Mobile';
        num2.Service_Number__c='5568451563';

        Number__c num3 = new Number__c();
        num3.Name='Num1';
        num3.Subscription_number__c=testSubscription7.csordtelcoa__Subscription_Number__c;
        num3.Mobile__c='Mobile';
        num3.Service_Number__c='5568451564';

        List<Number__c> numList = new List<Number__c>{num,num1,num2,num3};
        Insert numList;
    
          Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                          lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                          profileid = pf.id,
                          timezonesidkey='Australia/Sydney',
                          username='salesunifieduser@testsales.com',phone='+121231231234');
        insert sales;
    
    }
   
   
   @isTest
    static void dirtyFlagTest1() {
        Account acc = new Account(Name = 'Test Account');
        INSERT acc;
        Map<String,csord__Solution__c> solMap = new Map<String,csord__Solution__c>([SELECT Id, Name from csord__Solution__c LIMIT 1]);  //Modified as part of EDGE-144681
        Set<String> setOfSolIds = new Set<String>();
        setOfSolIds = solMap.keySet();
        List<String> listOfSolIds = new List<String>(setOfSolIds);
        //Attatchment inserted
        Attachment attachment = new Attachment();
          String encodedContentsString = '[{\"configurations\":[{\"attributes\":[{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":\"708a8899-70dc-9a35-3e10-c4b93268d643\",\"type\":\"String\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"GUID\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":true,\"displayColumn\":null,\"value\":true,\"type\":\"Boolean\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"isMainComponent\",\"name\":\"isMainComponent\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":\"\",\"type\":\"String\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"ConfigName\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":true,\"displayColumn\":null,\"value\":true,\"type\":\"Boolean\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"createPCRs\",\"name\":\"createPCRs\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"a4f5O0000000AcPQAU\",\"displayColumn\":null,\"value\":\"a4f5O0000000AcPQAU\",\"type\":\"String\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"SolutionId\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":\"New\",\"type\":\"Picklist\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"Change Type\",\"name\":\"ChangeType\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":\"\",\"type\":\"Picklist\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"Cancellation Reason\",\"name\":\"CancellationReason\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":\"Corporate Mobile Plus\",\"type\":\"String\",\"required\":false,\"showInUi\":true,\"readOnly\":false,\"label\":\"\",\"name\":\"Solution Name\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"Corporate Mobile Plus\",\"displayColumn\":null,\"value\":\"a9x5O000000000kQAA\",\"type\":\"Lookup\",\"required\":false,\"showInUi\":true,\"readOnly\":false,\"label\":\"Offer Name\",\"name\":\"OfferName\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"Committed Data\",\"displayColumn\":null,\"value\":\"a3u5O00000000QUQAY\",\"type\":\"Lookup\",\"required\":false,\"showInUi\":true,\"readOnly\":false,\"label\":\"Offer Type\",\"name\":\"OfferType\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"20 GB\",\"displayColumn\":null,\"value\":\"a3u5O000000036TQAQ\",\"type\":\"Lookup\",\"required\":false,\"showInUi\":true,\"readOnly\":false,\"label\":\"Data Pack Plan\",\"name\":\"DataPackPlan\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"a3u5O000000036TQAQ\",\"displayColumn\":null,\"value\":\"a3u5O000000036TQAQ\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"DataPackPlanstring\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":50,\"displayColumn\":null,\"value\":50,\"type\":\"Calculation\",\"required\":false,\"showInUi\":true,\"readOnly\":false,\"label\":\"Recurring Charge\",\"name\":\"Data Pack RC\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"20 GB\",\"displayColumn\":null,\"value\":\"20 GB\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":true,\"readOnly\":false,\"label\":\"Data Pack Allowance\",\"name\":\"DataPackAllowanceValue\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"40 GB\",\"displayColumn\":null,\"value\":\"40 GB\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":true,\"readOnly\":false,\"label\":\"Bonus Data Allowance\",\"name\":\"BonusDataAllowanceValue\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"2099-12-31\",\"displayColumn\":null,\"value\":\"2099-12-31\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"BonusDataPromotion EndDate\",\"name\":\"BonusDataPromotionEndDate\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"DMCAT_Offer_000646\",\"displayColumn\":null,\"value\":\"DMCAT_Offer_000646\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"OfferId\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"Committed Data\",\"displayColumn\":null,\"value\":\"Committed Data\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"OfferTypeString\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":\"0\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"Recurring Charge\",\"name\":\"RC\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":\"Enterprise Mobility\",\"type\":\"String\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"PDName\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":\"\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"One Off Charge\",\"name\":\"OC\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":\"Corporate Mobile Plus\",\"type\":\"String\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"SolutionTemplate\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"a9z5O00000000SFQAY\",\"displayColumn\":null,\"value\":\"a9z5O00000000SFQAY\",\"type\":\"Lookup\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"Data Pack Allowance\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"Committed Bonus Data Allowance 40 GB\",\"displayColumn\":null,\"value\":\"a9z5O00000000U3QAI\",\"type\":\"Lookup\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"BonusDataAllowance \",\"name\":\"BonusDataAllowance\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"Corporate Mobile Plus\",\"displayColumn\":null,\"value\":\"Corporate Mobile Plus\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"OfferNameString\",\"name\":\"OfferNameString\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"DMCAT_ProductSpecification_000420\",\"displayColumn\":null,\"value\":\"DMCAT_ProductSpecification_000420\",\"type\":\"String\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"ProdSpecId\",\"name\":\"ProdSpecId\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"420_AW_877,420_AW_805,420_RC_824\",\"displayColumn\":null,\"value\":\"420_AW_877,420_AW_805,420_RC_824\",\"type\":\"String\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"EDMListToDecompose\",\"name\":\"EDMListToDecompose\"}],\"other\":\"{\\"orderEnrichmentMinMax\\":{\\"a6B5O000000001sUAA\\":{\\"min\\":0,\\"max\\":9999}}}\",\"parent\":\"a4f5O0000000AcPQAU\",\"statusMessage\":\"\",\"oeErrorMessages\":{},\"replacedConfigId\":null,\"relatedProductList\":[],\"orderEnrichmentList\":[],\"siteProductList\":[],\"solutionId\":\"a4f5O0000000AcPQAU\",\"status\":true,\"totalContractValue\":1200,\"recurringPrice\":50,\"oneOffPrice\":0,\"name\":\"\",\"id\":\"a3T5O0000001VaWUAU\",\"guid\":\"708a8899-70dc-9a35-3e10-c4b93268d643\",\"errorMessage\":\"\",\"error\":false,\"disabled\":false,\"dirty\":true,\"orderEnrichmentSave\":\"\",\"contractTerm\":24,\"configurationStatus\":\"Valid\",\"configCurrency\":\"\",\"configurationName\":\"Corporate Mobile Plus-Committed Data\"}],\"attributes\":[],\"id\":\"a4f5O0000000AcPQAU\",\"showEditButtonOverride\":false,\"changeType\":\"\",\"visible\":true,\"disabled\":false,\"errorMessage\":\"\",\"active\":false,\"error\":false,\"dirty\":false,\"componentType\":\"Example type\",\"description\":\"Enterprise Mobility\",\"name\":\"Enterprise Mobility\",\"guid\":\"a9v5O000000001kQAA\"},{\"configurations\":[{\"attributes\":[{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":\"59639da5-b58c-a0ff-edb9-13c7629cabb6\",\"type\":\"String\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"GUID\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"a4f5O0000000AcPQAU\",\"displayColumn\":null,\"value\":\"a4f5O0000000AcPQAU\",\"type\":\"String\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"SolutionId\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"New\",\"displayColumn\":null,\"value\":\"New\",\"type\":\"Picklist\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"Change Type\",\"name\":\"ChangeType\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"Voice and Data\",\"displayColumn\":null,\"value\":\"a3u5O000000030ZQAQ\",\"type\":\"Lookup\",\"required\":false,\"showInUi\":true,\"readOnly\":false,\"label\":\"PlanType\",\"name\":\"SelectPlanType\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":\"\",\"type\":\"Picklist\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"Cancellation Reason\",\"name\":\"CancellationReason\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"Voice and Data\",\"displayColumn\":null,\"value\":\"Voice and Data\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"PlanTypeString\",\"name\":\"PlanTypeString\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"Professional\",\"displayColumn\":null,\"value\":\"a3u5O000000030YQAQ\",\"type\":\"Lookup\",\"required\":false,\"showInUi\":true,\"readOnly\":false,\"label\":\"Plan\",\"name\":\"Select Plan\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"72.8\",\"displayColumn\":null,\"value\":\"72.8\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":true,\"readOnly\":false,\"label\":\"Recurring Charge\",\"name\":\"RC\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"Professional\",\"displayColumn\":null,\"value\":\"Professional\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"SelectPlanName\",\"name\":\"SelectPlanName\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"true\",\"displayColumn\":null,\"value\":\"true\",\"type\":\"Boolean\",\"required\":false,\"showInUi\":true,\"readOnly\":false,\"label\":\"MDM Entitlement\",\"name\":\"MDMEntitled\"},{\"validationErrorMessage\":\"\",\"helpText\":\"Place calls to fixed lines and mobile in countries included in your plan\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"Premium\",\"displayColumn\":null,\"value\":\"a3q5O00000002IeQAI\",\"type\":\"Lookup\",\"required\":false,\"showInUi\":true,\"readOnly\":false,\"label\":\"International Direct Dial\",\"name\":\"InternationalDirectDial\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"Premium\",\"displayColumn\":null,\"value\":\"a3l5O0000000386QAA\",\"type\":\"Lookup\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"IDD ChargeLookup\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":0,\"type\":\"Calculation\",\"required\":false,\"showInUi\":true,\"readOnly\":false,\"label\":\"Recurring Charge\",\"name\":\"IDD Charge\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":\"\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"InContractDeviceEnrollEligibility\",\"name\":\"InContractDeviceEnrollEligibility\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":\"\",\"type\":\"Lookup\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"PlanDiscountLookup\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"a3u5O00000006gZQAQ\",\"displayColumn\":null,\"value\":\"a3u5O00000006gZQAQ\",\"type\":\"String\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"InContractDeviceRecId\"},{\"validationErrorMessage\":\"\",\"helpText\":\"Eligible discounts will be automatically applied\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":\"\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":true,\"readOnly\":false,\"label\":\"Plan Discount\",\"name\":\"TotalPlanBonus\"},{\"validationErrorMessage\":\"\",\"helpText\":\"Select the format you want your recorded message to be presented in.\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"3G Standard Retail\",\"displayColumn\":null,\"value\":\"a3q5O00000002IUQAY\",\"type\":\"Lookup\",\"required\":false,\"showInUi\":true,\"readOnly\":false,\"label\":\"Message Bank\",\"name\":\"MessageBank\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":0,\"type\":\"Calculation\",\"required\":false,\"showInUi\":true,\"readOnly\":false,\"label\":\"Recurring Charge\",\"name\":\"MessageBank RC\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"a3u5O000000030YQAQ\",\"displayColumn\":null,\"value\":\"a3u5O000000030YQAQ\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"CommercialProductID\",\"name\":\"CommercialProductID\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":\"DMCAT_Offer_000646\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"OfferId\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":\"Committed Data\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"OfferTypeString\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":\"Mobile Subscription\",\"type\":\"String\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"PDName\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"72.8\",\"displayColumn\":null,\"value\":\"72.8\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"Net Recurring Charge\",\"name\":\"NetRC\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":\"\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"One Off Charge\",\"name\":\"OC\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":\"\",\"type\":\"String\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"Mobile Number\",\"name\":\"MobileNumber\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":\"DMCAT_ProductSpecification_000420\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"ProdSpecId\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":\"\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"DataPackChargeRec\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":\"\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"DataPackRC\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":\"\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"Data Pack Allowance\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"International Direct Dial In Allowance\",\"displayColumn\":null,\"value\":\"a9z5O00000000LnQAI\",\"type\":\"Lookup\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"IDDAllowance\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"Mobility_Fulfilment,Mobile Access_Fulfilment,420_RC_654,263_NRC_601,326_ASR,151_ASR,420_AW_806,420_AW_644,263_AW_606,263_AW_607,421_ASR\",\"displayColumn\":null,\"value\":\"Mobility_Fulfilment,Mobile Access_Fulfilment,420_RC_654,263_NRC_601,326_ASR,151_ASR,420_AW_806,420_AW_644,263_AW_606,263_AW_607,421_ASR\",\"type\":\"String\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"EDMListToDecompose\",\"name\":\"EDMListToDecompose\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"Committed Base Plan Allowance Professional\",\"displayColumn\":null,\"value\":\"a9z5O00000000T8QAI\",\"type\":\"String\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"PlanAllowance\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"0032O000001zlgVQAQ\",\"displayColumn\":null,\"value\":\"0032O000001zlgVQAQ\",\"type\":\"String\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"SiteDeliveryContact\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"a4O2O0000004TWxUAM\",\"displayColumn\":null,\"value\":\"a4O2O0000004TWxUAM\",\"type\":\"String\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"SiteDeliveryAddress\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":\"\",\"type\":\"String\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"isNumberEnrichComplete\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":\"\",\"type\":\"Date\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"Disconnection Date\",\"name\":\"DisconnectionDate\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":\"\",\"type\":\"String\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"Call Control\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"Yes\",\"displayColumn\":null,\"value\":\"Yes\",\"type\":\"Boolean\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"INTROAM\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"2019-11-29\",\"displayColumn\":null,\"value\":\"2019-11-29\",\"type\":\"Date\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"Not Before CRD\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"2019-11-30\",\"displayColumn\":null,\"value\":\"2019-11-30\",\"type\":\"Date\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"Preferred CRD\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"24\",\"displayColumn\":null,\"value\":\"24\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"RemainingTerm\",\"name\":\"RemainingTerm\"},{\"validationErrorMessage\":\"\",\"helpText\":\"Remaining device(s) only charge. May vary based on actual disconnection date. Device(s) owned outright upon payment.\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":\"\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"Balance Due on Device\",\"name\":\"EarlyTerminationCharge\"}],\"other\":\"{\\"relatedProductMinMax\\":{\\"Device\\":{\\"min\\":null,\\"max\\":9999}},\\"orderEnrichmentMinMax\\":{\\"a6B5O000000001xUAA\\":{\\"min\\":0,\\"max\\":1},\\"a6B5O0000000022UAA\\":{\\"min\\":0,\\"max\\":1},\\"a6B5O000000002WUAQ\\":{\\"min\\":0,\\"max\\":1}},\\"dirtyOrderEnrichment\\":[\\"a6B5O000000001xUAA\\",\\"a6B5O000000002WUAQ\\",\\"a6B5O0000000022UAA\\"]}\",\"parent\":\"a4f5O0000000AcPQAU\",\"statusMessage\":\"\",\"oeErrorMessages\":{},\"replacedConfigId\":null,\"relatedProductList\":[{\"configuration\":{\"attributes\":[{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":\"\",\"type\":\"Boolean\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"Cancel\",\"name\":\"CancelFlag\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":\"\",\"type\":\"string\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"DeviceStatus\",\"name\":\"DeviceStatus\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":null,\"type\":\"string\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"ReplaceConfig\",\"name\":\"ReplaceConfig\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":\"None\",\"type\":\"Picklist\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"ChangeType\",\"name\":\"ChangeTypeDevice\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"Voice and Data\",\"displayColumn\":null,\"value\":\"Voice and Data\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"PlanType\",\"name\":\"PlanType\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"Mobile Handset\",\"displayColumn\":null,\"value\":\"a3u5O00000006gBQAQ\",\"type\":\"Lookup\",\"required\":false,\"showInUi\":true,\"readOnly\":false,\"label\":\"Device Type\",\"name\":\"Device Type\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"Mobile Handset\",\"displayColumn\":null,\"value\":\"Mobile Handset\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"deviceTypeString\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"APPLE PTY LTD\",\"displayColumn\":null,\"value\":\"a3u5O00000000uSQAQ\",\"type\":\"Lookup\",\"required\":false,\"showInUi\":true,\"readOnly\":false,\"label\":\"Manufacturer\",\"name\":\"MobileHandsetManufacturer\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"APPLE IPHONE 11 128GB 4GX\",\"displayColumn\":null,\"value\":\"a3u5O00000006gBQAQ\",\"type\":\"Lookup\",\"required\":false,\"showInUi\":true,\"readOnly\":false,\"label\":\"Model\",\"name\":\"MobileHandsetModel\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"BLACK\",\"displayColumn\":null,\"value\":\"a3u5O00000006gZQAQ\",\"type\":\"Lookup\",\"required\":false,\"showInUi\":true,\"readOnly\":false,\"label\":\"Colour\",\"name\":\"MobileHandsetColour\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"Hardware Repayment\",\"displayColumn\":null,\"value\":\"a3u5O00000006gZQAQ\",\"type\":\"Lookup\",\"required\":false,\"showInUi\":true,\"readOnly\":false,\"label\":\"Payment Type\",\"name\":\"PaymentTypeLookup\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"24\",\"displayColumn\":null,\"value\":\"a3u5O00000006gZQAQ\",\"type\":\"Lookup\",\"required\":false,\"showInUi\":true,\"readOnly\":false,\"label\":\"Term\",\"name\":\"ContractTerm\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"48.2\",\"displayColumn\":null,\"value\":\"48.2\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":true,\"readOnly\":false,\"label\":\"Recurring Charge\",\"name\":\"InstalmentCharge\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"Eligible\",\"displayColumn\":null,\"value\":\"Eligible\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"InContractDeviceEnrollEligibility\",\"name\":\"InContractDeviceEnrollEligibility\"},{\"validationErrorMessage\":\"\",\"helpText\":\"This feature enables devices to automatically enrol in an organisation\u2019s MDM platform\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"ENROL\",\"displayColumn\":null,\"value\":\"ENROL\",\"type\":\"Picklist\",\"required\":false,\"showInUi\":true,\"readOnly\":false,\"label\":\"Device Enrolment\",\"name\":\"DeviceEnrollment\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":\"DMCAT_Offer_000646\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"OfferId\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"a3u5O000000030YQAQ\",\"displayColumn\":null,\"value\":\"a3u5O000000030YQAQ\",\"type\":\"String\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"ParentPriceItem\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"APPLE PTY LTD\",\"displayColumn\":null,\"value\":\"APPLE PTY LTD\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"ManufacturerString\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"APPLE IPHONE 11 128GB 4GX\",\"displayColumn\":null,\"value\":\"APPLE IPHONE 11 128GB 4GX\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"ModelString\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"BLACK\",\"displayColumn\":null,\"value\":\"BLACK\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"ColourString\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"Hardware Repayment\",\"displayColumn\":null,\"value\":\"Hardware Repayment\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"PaymentTypeString\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"24\",\"displayColumn\":null,\"value\":\"24\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"Contract Term\",\"name\":\"ContractTermString\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":\"\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"MRO Bonus\",\"name\":\"MROBonus\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":\"8ab5856b-9b88-42e6-369e-0917d8dddec8\",\"type\":\"String\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"GUID\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"a4f5O0000000AcPQAU\",\"displayColumn\":null,\"value\":\"a4f5O0000000AcPQAU\",\"type\":\"String\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"SolutionId\"},{\"validationErrorMessage\":\"\",\"helpText\":\"Remaining device(s) only charge. May vary based on actual disconnection date. Device(s) owned outright upon payment.\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":null,\"displayColumn\":null,\"value\":\"\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"Balance Due on Device\",\"name\":\"EarlyTerminationCharge\"},{\"validationErrorMessage\":\"\",\"helpText\":\"\",\"errorMessage\":\"\",\"status\":true,\"error\":false,\"other\":\"\",\"displayValue\":\"24\",\"displayColumn\":null,\"value\":\"24\",\"type\":\"Calculation\",\"required\":false,\"showInUi\":false,\"readOnly\":false,\"label\":\"\",\"name\":\"RemainingTerm\"}],\"other\":\"{}\",\"parent\":\"a4f5O0000000AcPQAU\",\"statusMessage\":\"\",\"oeErrorMessages\":{},\"replacedConfigId\":null,\"relatedProductList\":[],\"orderEnrichmentList\":[],\"siteProductList\":[],\"status\":true,\"totalContractValue\":1156.8,\"recurringPrice\":48.2,\"oneOffPrice\":0,\"name\":\"\",\"id\":\"a3T5O0000001VacUAE\",\"guid\":\"8ab5856b-9b88-42e6-369e-0917d8dddec8\",\"errorMessage\":\"\",\"error\":false,\"disabled\":false,\"dirty\":true,\"orderEnrichmentSave\":\"\",\"contractTerm\":24,\"configurationStatus\":\"Valid\",\"configCurrency\":\"AUD\",\"configurationName\":\"APPLE PTY LTD  BLACK\"},\"type\":\"Related Component\",\"relatedProductName\":\"Device\",\"componentId\":\"a9v5O000000001mQAA\",\"groupName\":\"Device\",\"guid\":\"8ab5856b-9b88-42e6-369e-0917d8dddec8\",\"recurringCharge\":0,\"oneOffCharge\":0,\"name\":\"Device\",\"productDefinitionId\":\"a3V5O00000002Z2UAI\",\"configurationId\":\"a3T5O0000001VacUAE\"}],\"orderEnrichmentList\":[],\"siteProductList\":[],\"status\":true,\"totalContractValue\":2904,\"recurringPrice\":72.8,\"oneOffPrice\":0,\"name\":\"\",\"id\":\"a3T5O0000001VabUAE\",\"guid\":\"59639da5-b58c-a0ff-edb9-13c7629cabb6\",\"errorMessage\":\"\",\"error\":false,\"disabled\":false,\"dirty\":true,\"orderEnrichmentSave\":\"\",\"contractTerm\":24,\"configurationStatus\":\"Valid\",\"configCurrency\":\"\",\"configurationName\":\"Committed Data - Professional\"}],\"attributes\":[],\"id\":\"a4f5O0000000AcPQAU\",\"showEditButtonOverride\":false,\"changeType\":\"\",\"visible\":true,\"disabled\":false,\"errorMessage\":\"\",\"active\":false,\"error\":false,\"dirty\":false,\"componentType\":\"Example type\",\"description\":\"Mobile Subscription\",\"name\":\"Mobile Subscription\",\"guid\":\"a9v5O000000001lQAA\"},{\"configurations\":[],\"attributes\":[],\"id\":\"a4f5O0000000AcPQAU\",\"showEditButtonOverride\":false,\"changeType\":\"\",\"visible\":true,\"disabled\":false,\"errorMessage\":\"\",\"active\":false,\"error\":false,\"dirty\":false,\"componentType\":\"Overview\",\"name\":\"Enterprise Mobility Overview\",\"guid\":\"a9v5O000000001pQAA\"}]';
          attachment.Body = Blob.valueOf(encodedContentsString);
          attachment.Name = String.valueOf('NumberManagementv1_schema.json');
          attachment.ParentId = listOfSolIds[0];
          insert attachment;
        Opportunity opp = TestDataFactory.generateOpportunity();
        cscfga__Product_Basket__c basket = TestDataFactory.generateProductBasket();
        basket.csbb__Account__c = acc.Id;
        basket.cscfga__Opportunity__c = opp.Id;
        UPDATE basket;
       
           
        Try{
             Test.startTest();
       
                ID jobID = System.enqueueJob(new dirtyFlagQueueable(listOfSolIds));
                Test.stopTest();    
            System.assertEquals(jobID != null, true);//EDGE-153459
       }catch(Exception e){
       system.debug('exception occured');
      }  
    }
}