// 25/01/2021 updated by shubhi for fdr test class fixes

@IsTest
public class ProductTestService {

    public static cscfga__Configuration_Offer__c createOffer(String name) {
        cscfga__Configuration_Offer__c  offer =  new cscfga__Configuration_Offer__c ();
        offer.cscfga__Active__c = true;
        offer.Name = name;
        insert offer;

        // Gnana - Commented below code to fix PB -> Associate Product Configuration to CLI - SOQL Issue - Start
        /*Create Product configuration
        cscfga__Product_Configuration__c config = createProductConfiguration();
        config.cscfga__Configuration_Offer__c = offer.Id;
        update config;*/
        // Gnana - Commented below code to fix PB -> Associate Product Configuration to CLI - SOQL Issue - End
        return offer;
    }
    
    // Gnana - Added to fix PB -> Associate Product Configuration to CLI - SOQL Issue - Start
    public static cscfga__Product_Definition__c createProductDefintion(){
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Test Product', 'Test Plan');
        insert prodDef;
        createSFAssociationForProdDefinition(prodDef.id);
        return prodDef;
    }

    public static void createProductConfiguration(List<cscfga__Configuration_Offer__c> listOfOffer){
        cscfga__Product_Definition__c prodDef = createProductDefintion();
        List<cscfga__Product_Configuration__c> listOfPC = new List<cscfga__Product_Configuration__c>();
        for(cscfga__Configuration_Offer__c offer : listOfOffer){          
            //Create Product configuration
            cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(prodDef.id);
            config.cscfga__Contract_Term__c = 12;
            config.cscfga__total_contract_value__c = 325;
            config.cscfga__Configuration_Offer__c = offer.Id;
            listOfPC.add(config);
        }
        insert listOfPC;
    }
    // Gnana - Added to fix PB -> Associate Product Configuration to CLI - SOQL Issue - End

    public static csord__Order__c getNewOrderForAccount(Account acc) {
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        insert ord;
        csord__Subscription__c subs = ProductTestFactory.buildSubscription('TestOrder', acc.id, ord.id, ordReq.id);
        insert subs;
        csord__Service__c ser = ProductTestFactory.buildService('TestOrder', ord.id, subs.id, ordReq.id);
        insert ser;

        return ord;
    }

    public static Account getNewAccount(String accName) {
        
        Account acc = new Account(Name = accName, Pref_Comm_Method__c = 'B2B', Customer_Status__c = 'Active');//adding Customer_Status__c as per the Sprint 19.17 P2OB-4149
        insert acc;
        return acc;
    }

    public static csord__Subscription__c getNewSubscriptionForAccount(Account acc) {
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        insert ord;
        csord__Subscription__c subs = ProductTestFactory.buildSubscription('TestOrder', acc.id, ord.id, ordReq.id);
        insert subs;
        csord__Service__c ser = ProductTestFactory.buildService('TestOrder', ord.id, subs.id, ordReq.id);
        insert ser;

        return subs;
    }

    public static csord__Subscription__c attachSiteToSubscription(csord__Subscription__c subs, Account acc) {
        String addressId = 'ADDR-1';
        cscrm__Address__c address = AccountTestFactory.buildAddress(addressId);
        insert address;
        cscrm__Site__c site = AccountTestFactory.buildSite(address.id, acc.id);
        insert site;
        //subs.Site__c = site.id;
        update subs;

        return subs;
    }

    public static csord__Service__c attachProductConfigToService(csord__Service__c ser, Map<String, String> attMap) {
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('TEST', null);
        insert prodDef;
        cscfga__Product_Configuration__c prodConfig = ProductTestFactory.buildProductConfig(prodDef.id);
        insert prodConfig;
        List<cscfga__Attribute__c> atts = new List<cscfga__Attribute__c>();
        for (String name : attMap.keySet()) {
            cscfga__Attribute__c att = ProductTestFactory.buildAttribute(name, attMap.get(name), prodConfig.id);
            atts.add(att);
        }
        insert atts;
        ser.csordtelcoa__Product_Configuration__c = prodConfig.id;

        return ser;
    }

    public static csord__Service__c getNewServiceForAccount(Account acc) {
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        insert ord;
        csord__Subscription__c subs = ProductTestFactory.buildSubscription('TestOrder', acc.id, ord.id, ordReq.id);
        insert subs;
        csord__Service__c ser = ProductTestFactory.buildService('TestOrder', ord.id, subs.id, ordReq.id);
        insert ser;

        return ser;
    }

    public static void createChangeType(List<String> changeTypes) {
        List<csordtelcoa__Change_Types__c> cts =  new List<csordtelcoa__Change_Types__c>();
        for (String changeType : changeTypes) {
            cts.add(ProductTestFactory.buildChangeType(changeType));
        }
        insert cts;
    }

    public static csbb__Product_Configuration_Request__c createPCRWIthCalloutResults() {
        cscfga__Product_Category__c  pc = ProductTestFactory.buildProductCategory();
        insert pc;
        csbb__Product_Configuration_Request__c pcr = new csbb__Product_Configuration_Request__c();
        pcr.csbb__Product_Category__c = pc.id;
        insert pcr;
        csbb__Callout_Result__c cor = ProductTestFactory.buildCallOutResults();
        insert cor;
        csbb__Callout_Product_Result__c copr = ProductTestFactory.buildCalloutProductResults(pcr, cor);
        insert copr;

        return pcr;
    }
    
    public static csbb__Product_Configuration_Request__c createPCRWIthAddressCalloutResults(Id basketId) {
        
        csbb__Product_Configuration_Request__c pcr = new csbb__Product_Configuration_Request__c();
        //Create CWP Offer
        cscfga__Configuration_Offer__c offer = new cscfga__Configuration_Offer__c();
        offer.name = System.Label.Connected_Workplace_Package;
        insert offer;
        system.debug('testclassOfferId ' + offer.Id);
        pcr.csbb__Offer__c = offer.id;
        pcr.csbb__Product_Basket__c = basketId;
        pcr.csbb__Optionals__c = '{"selectedAddressDisplay":"WILLIAMS VIC MELBOURNE 3111","hiddenParam1":"213141258"}';
        insert pcr;
        return pcr;
    }

    /**
     * Gets the new basket with configuration.
     *
     * @param      acc   The acc
     *
     * @return     The new basket with configuration.
     */
    public static cscfga__Product_Basket__c getNewBasketWithConfig(Account acc) {
        AttributeTest testName1 = new AttributeTest('Test Name', 'Test Value', false, null);
        AttributeTest testName2 = new AttributeTest('Test Name', 'Test Value', true, 25.00);
        AttributeTest testName3 = new AttributeTest('Test Name', 'Test Value', false, 25.00);
        List<AttributeTest> attributeTests = new List<AttributeTest>{testName1, testName2, testName3};
        return getNewBasketWithProductConfigData(acc, attributeTests);
    }

    /**
    * Gets the new basket with configuration.
    *
    * @param      acc   The acc
    *
    * @return     The new basket with configuration.
    */
    public static cscfga__Product_Basket__c getNewBasketWithRealConfigVal(Account acc) {
        AttributeTest crd = new AttributeTest('Customer Requested Date', null, false, null);
        AttributeTest aggregator = new AttributeTest('Aggregator', null, false, null);
        AttributeTest fCIDN = new AttributeTest('Financial CIDN', null, false, null);
        AttributeTest iaID = new AttributeTest('Invoice Arrangement ID', null, false, null);
        AttributeTest pon = new AttributeTest('Purchase Order Number', null, false, null);
        AttributeTest bStatus = new AttributeTest('Basket Status', null, false, null);
        AttributeTest productType = new AttributeTest('ProductType', null, false, null);
        List<AttributeTest> attributeTests = new List<AttributeTest>{crd, aggregator, fCIDN, iaID, pon, bStatus, productType};
        return getNewBasketWithProductConfigData(acc, attributeTests);
    }
	
    /**
    * Gets the new basket with configuration.
    *
    * @param      acc   The acc
    *
    * @return     The new basket with configuration.
    * added by shubhi
    */
    public static cscfga__Product_Basket__c getNewBasketWithRealConfigValwithOpty(Account acc) {
        AttributeTest crd = new AttributeTest('Customer Requested Date', null, false, null);
        AttributeTest aggregator = new AttributeTest('Aggregator', null, false, null);
        AttributeTest fCIDN = new AttributeTest('Financial CIDN', null, false, null);
        AttributeTest iaID = new AttributeTest('Invoice Arrangement ID', null, false, null);
        AttributeTest pon = new AttributeTest('Purchase Order Number', null, false, null);
        AttributeTest bStatus = new AttributeTest('Basket Status', null, false, null);
        AttributeTest productType = new AttributeTest('ProductType', null, false, null);
        List<AttributeTest> attributeTests = new List<AttributeTest>{crd, aggregator, fCIDN, iaID, pon, bStatus, productType};
        return getNewBasketWithProductConfigDatawithOpty(acc, attributeTests);
    }

    public static void createSFAssociationForProdDefinition(Id prodDefId) {
        List<cscfga__Screen_Flow__c> sfs = new List<cscfga__Screen_Flow__c>();
        cscfga__Screen_Flow__c sf1 = ProductTestFactory.buildScreenFlow('SF Name 1');
        sfs.add(sf1);
        cscfga__Screen_Flow__c sf2 = ProductTestFactory.buildScreenFlow('SF Name 2');
        sfs.add(sf2);
        insert sfs;

        List<cscfga__Screen_Flow_Product_Association__c> sfAs = new List<cscfga__Screen_Flow_Product_Association__c>();
        cscfga__Screen_Flow_Product_Association__c sfA1 = ProductTestFactory.buildSFAssociation(prodDefId, sf1.id);
        sfAs.add(sfA1);
        cscfga__Screen_Flow_Product_Association__c sfA2 = ProductTestFactory.buildSFAssociation(prodDefId, sf2.id);
        sfAs.add(sfA2);
        insert sfAs;
    }

    public static cspmb__Price_Item_Add_On_Price_Item_Association__c createPricingData(String piCode, String addOnName, String itemCode, String accessType, String accessConfig, String classOfService, String planName) {
        cspmb__Price_Item__c pi = ProductTestFactory.buildPriceItem(piCode, 2.2, 3.2, piCode);
        insert pi;
        cspmb__add_on_price_item__c aopi = ProductTestFactory.buildAddOnPriceItem(addOnName, itemCode, accessType, accessConfig, classOfService, planName);
        insert aopi;
        cspmb__Price_Item_Add_On_Price_Item_Association__c aopia = ProductTestFactory.buildPriceAssociation(pi.id, aopi.id);
        insert aopia;
        return aopia;
    }

    public static csord__Order__c getNewOrderWithOrderHeader(Account acc) {
        //Create Basket
        
        Billing_Account__c billingAccount = ProductTestFactory.getBillingAccount();
        insert billingAccount;
        
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.csordtelcoa__Basket_Stage__c = 'Enriched';
        basket.Maxim_Opportunity_ID__c = '1111';
        basket.Service_Number__c = '22';
        basket.Hot_Cutover__c = true;
        basket.Hot_Cutover_Comments__c = 'Comments';
        basket.Billing_Account__c = billingAccount.id;
        basket.Project_ID__c = 'acc01';
        basket.Project_Complexity__c = 'Complex';
        basket.PM_Required__c = true;
        basket.Project_Manager_User_ID__c = 'test01';
        basket.Project_Manager_Contact_Number__c = '9985018467';
        basket.Project_Manager_Email__c = 'test@gmail.com';

        insert basket;

        //Create Product configuration
        cscfga__Product_Configuration__c config = createProductConfiguration();
        config.cscfga__Product_Basket__c = basket.id;
        update config;

        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        insert ord;
        csord__Subscription__c subs = ProductTestFactory.buildSubscription('TestOrder', acc.id, ord.id, ordReq.id);
        insert subs;
        csord__Service__c ser = ProductTestFactory.buildService('TestOrder', ord.id, subs.id, ordReq.id);
        ser.csordtelcoa__Product_Configuration__c = config.id;
        insert ser;
        return ord;
    }

    /**
     * Gets the new order with multiple services.
     *
     * @param      acc   The acc
     *
     * @return     The new order with multiple services.
     */
    public static csord__Order__c getNewOrderWithMultipleServices(Account acc) {
        //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;

        insert basket;

        //Create Product configuration
        cscfga__Product_Configuration__c config = createProductConfiguration();
        config.cscfga__Product_Basket__c = basket.id;
        update config;

        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        insert ord;
        csord__Subscription__c subs = ProductTestFactory.buildSubscription('Test Subscription', acc.id, ord.id, ordReq.id);
        insert subs;

        csord__Subscription__c parentSubs = ProductTestFactory.buildSubscription('Test Parent Subs', acc.id, ord.id, ordReq.id);
        insert parentSubs;

        csord__Service__c parentSer = ProductTestFactory.buildService('Test Parent Service', ord.id, parentSubs.id, ordReq.id);
        parentSer.csordtelcoa__Product_Configuration__c = config.id;
        insert parentSer;

        csord__Service__c testSer = ProductTestFactory.buildService('Test Service', ord.id, subs.id, ordReq.id);
        insert testSer;

        return ord;
    }

    public static List<Id> getNewOrderWithMultipleServicesRealData(Account acc) {
        List<Id> serviceList = new List<Id>();
        //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;

        insert basket;

        //Create Product configuration
        cscfga__Product_Configuration__c config = createProductConfiguration();
        config.cscfga__Product_Basket__c = basket.id;
        update config;

        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        insert ord;
        csord__Subscription__c subs = ProductTestFactory.buildSubscription('Test Subscription', acc.id, ord.id, ordReq.id);
        insert subs;

        csord__Subscription__c parentSubs = ProductTestFactory.buildSubscription('Test Parent Subs', acc.id, ord.id, ordReq.id);
        insert parentSubs;

        csord__Service__c parentSer = ProductTestFactory.buildService('Business Bundle: DOT Core Extra Large', ord.id, parentSubs.id, ordReq.id);
        parentSer.csordtelcoa__Product_Configuration__c = config.id;
        insert parentSer;

        csord__Service__c testSer1 = ProductTestFactory.buildService('Business Internet: DOT Core Extra Large', ord.id, subs.id, ordReq.id);
        insert testSer1;

        csord__Service__c testSer2 = ProductTestFactory.buildService('Additional Static IP Subnet 26', ord.id, subs.id, ordReq.id);
        insert testSer2;

        csord__Service__c testSer3 = ProductTestFactory.buildService('Business Internet Device: Devg2020 Router Netgear', ord.id, subs.id, ordReq.id);
        insert testSer3;

        csord__Service__c testSer4 = ProductTestFactory.buildService('Training1: OnSite mentoring', ord.id, subs.id, ordReq.id);
        insert testSer4;

        csord__Service__c testSer5 = ProductTestFactory.buildService('Add Ons', ord.id, subs.id, ordReq.id);
        insert testSer5;

        serviceList.add(parentSer.Id);
        serviceList.add(testSer1.Id);
        serviceList.add(testSer2.Id);
        serviceList.add(testSer3.Id);
        serviceList.add(testSer4.Id);
        serviceList.add(testSer5.Id);

        return serviceList;
    }

    public static void getCompleteOrderWithSli(Account acc) {
        List<Id> serviceList = new List<Id>();
        //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;

        insert basket;

        //Create Product configuration
        cscfga__Product_Configuration__c config = createProductConfiguration();
        config.cscfga__Product_Basket__c = basket.id;
        update config;

        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        insert ord;
        csord__Subscription__c subs = ProductTestFactory.buildSubscription('Test Subscription', acc.id, ord.id, ordReq.id);
        insert subs;

        csord__Subscription__c parentSubs = ProductTestFactory.buildSubscription('Test Parent Subs', acc.id, ord.id, ordReq.id);
        insert parentSubs;

        csord__Service__c parentSer = ProductTestFactory.buildService('Business Bundle: DOT Core Extra Large', ord.id, parentSubs.id, ordReq.id);
        parentSer.csordtelcoa__Product_Configuration__c = config.id;
        insert parentSer;

        csord__Service__c testSer1 = ProductTestFactory.buildService('------------Business Internet: DOT Core Extra Large', ord.id, subs.id, ordReq.id);
        insert testSer1;

        csord__Service_Line_Item__c sli = ProductTestFactory.buildServiceLineItem('------------Business Internet: DOT Core Extra Large', testSer1.Id);
        insert sli;
    }

    public static CSPOFA__Orchestration_Process__c getNewOrchestrationProcess(CSPOFA__Orchestration_Process_Template__c processTemplate){
        CSPOFA__Orchestration_Process__c parentProcess = ProductTestFactory.buildOrchProcess(processTemplate);
        insert parentProcess;

        return parentProcess;
    }

    public static CSPOFA__Orchestration_Step__c getOrchStep(CSPOFA__Orchestration_Process__c parentProcess){
        CSPOFA__Orchestration_Step__c orchStep = ProductTestFactory.buildOrchStep(parentProcess);
        insert orchStep;

        return orchStep;
    }

    public static CSPOFA__Orchestration_Process_Template__c getOrchProcessTemplate(){
        CSPOFA__Orchestration_Process_Template__c processTemplate = ProductTestFactory.buildOrchProcessTemplate();
        insert processTemplate;

        return processTemplate;
    }


    public static cscfga__Product_Basket__c getNewBasketWithProductConfigData(Account acc, List<AttributeTest> atts) {


        //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;

        insert basket;

        //Create Product configuration
        cscfga__Product_Configuration__c config = createProductConfiguration();
        config.cscfga__Product_Basket__c = basket.id;
        update config;

        //Create Product Confuguration Request using existing method

        csbb__Product_Configuration_Request__c pcr  = ProductTestService.createPCRWIthCalloutResults();
        pcr.csbb__Product_Configuration__c = config.id;
        pcr.csbb__Product_Basket__c = basket.id;
        pcr.csbb__Total_OC__c = 25;
        pcr.csbb__Total_MRC__c = 25;

        update pcr;

        List<cscfga__Attribute_Definition__c> attDefList =  new List<cscfga__Attribute_Definition__c>();
        List<cscfga__Attribute__c> attList =  new List<cscfga__Attribute__c>();
        for(AttributeTest attTest : atts) {
            cscfga__Attribute_Definition__c attDef = ProductTestFactory.buildAttributeDefinition(attTest.name, config.cscfga__Product_Definition__c);
            attDefList.add(attDef);
            cscfga__Attribute__c att  = ProductTestFactory.buildPriceAttribute(attTest.name, attTest.value, config.id, attTest.isLineItem, attTest.price);
            att.cscfga__Attribute_Definition__c = attDef.id;
            attList.add(att);
        }

        insert attDefList;
        insert attList;

        List<cscfga__Attribute_Field_Definition__c> attFdDefList =  new List<cscfga__Attribute_Field_Definition__c>();
        for(cscfga__Attribute_Definition__c def : attDefList){
            cscfga__Attribute_Field_Definition__c fdDef = new cscfga__Attribute_Field_Definition__c();
            fdDef.name = 'Required_for_Fulfilment';
            fdDef.cscfga__Default_Value__c = 'Submit';
            fdDef.cscfga__Attribute_Definition__c = def.id;
            attFdDefList.add(fdDef);
        }

        if(attFdDefList.size()>0){
            insert attFdDefList;
        }

        return basket;
    }
    // return basket with opty added by shubhi for fdr fix
    public static cscfga__Product_Basket__c getNewBasketWithProductConfigDatawithOpty(Account acc, List<AttributeTest> atts) {

		//insert opty
		Opportunity opp = new Opportunity (Name='TestOpp', Account = acc, Product_Domain__c='MOBILES', Description='test',StageName='Define', CloseDate=Date.today());
        insert opp;
        //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c=opp.id;

        insert basket;

        //Create Product configuration
        cscfga__Product_Configuration__c config = createProductConfiguration();
        config.cscfga__Product_Basket__c = basket.id;
        update config;

        //Create Product Confuguration Request using existing method

        csbb__Product_Configuration_Request__c pcr  = ProductTestService.createPCRWIthCalloutResults();
        pcr.csbb__Product_Configuration__c = config.id;
        pcr.csbb__Product_Basket__c = basket.id;
        pcr.csbb__Total_OC__c = 25;
        pcr.csbb__Total_MRC__c = 25;

        update pcr;

        List<cscfga__Attribute_Definition__c> attDefList =  new List<cscfga__Attribute_Definition__c>();
        List<cscfga__Attribute__c> attList =  new List<cscfga__Attribute__c>();
        for(AttributeTest attTest : atts) {
            cscfga__Attribute_Definition__c attDef = ProductTestFactory.buildAttributeDefinition(attTest.name, config.cscfga__Product_Definition__c);
            attDefList.add(attDef);
            cscfga__Attribute__c att  = ProductTestFactory.buildPriceAttribute(attTest.name, attTest.value, config.id, attTest.isLineItem, attTest.price);
            att.cscfga__Attribute_Definition__c = attDef.id;
            attList.add(att);
        }

        insert attDefList;
        insert attList;

        List<cscfga__Attribute_Field_Definition__c> attFdDefList =  new List<cscfga__Attribute_Field_Definition__c>();
        for(cscfga__Attribute_Definition__c def : attDefList){
            cscfga__Attribute_Field_Definition__c fdDef = new cscfga__Attribute_Field_Definition__c();
            fdDef.name = 'Required_for_Fulfilment';
            fdDef.cscfga__Default_Value__c = 'Submit';
            fdDef.cscfga__Attribute_Definition__c = def.id;
            attFdDefList.add(fdDef);
        }

        if(attFdDefList.size()>0){
            insert attFdDefList;
        }

        return basket;
    }
    // Create Subscription for cancel subscription functionality.
    public static csord__Subscription__c getSubscriptionObject(Account acc)
    {
       //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.csordtelcoa__Basket_Stage__c = 'Enriched';
        basket.Maxim_Opportunity_ID__c = '1111';
        basket.Service_Number__c = '22';
        basket.Hot_Cutover__c = true;
        basket.Hot_Cutover_Comments__c = 'Comments';
        insert basket;

        //Create Product configuration
        cscfga__Product_Configuration__c config = createProductConfiguration();
        config.cscfga__Product_Basket__c = basket.id;
        update config;

        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        insert ord;
        csord__Subscription__c subs = ProductTestFactory.buildSubscription('TestOrder', acc.id, ord.id, ordReq.id);
        insert subs;
        return  subs;
    }
    public static List<csord__Subscription__c> getSubscriptionAsList(Account acc)
    {
        List<csord__Subscription__c> subscriptionObjList = new List<csord__Subscription__c>();
        integer i;
       //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.csordtelcoa__Basket_Stage__c = 'Enriched';
        basket.Maxim_Opportunity_ID__c = '1111';
        basket.Service_Number__c = '22';
        basket.Hot_Cutover__c = true;
        basket.Hot_Cutover_Comments__c = 'Comments';
        insert basket;

        //Create Product configuration
        cscfga__Product_Configuration__c config = createProductConfiguration();
        config.cscfga__Product_Basket__c = basket.id;
        update config;

        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        insert ord;
        for(  i= 0; i<11;i++)
        {
            csord__Subscription__c subs = new csord__Subscription__c ();
            subs = ProductTestFactory.buildSubscription('TestOrder'+i, acc.id, ord.id, ordReq.id);
            subscriptionObjList.add(subs);
        }
        insert subscriptionObjList;
        return subscriptionObjList;
    }


     public static void createSubscriptionWithChild(Account acc)
     {
        List<csord__Subscription__c> subscriptionObjList = new List<csord__Subscription__c>();

       //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.csordtelcoa__Basket_Stage__c = 'Enriched';
        basket.Maxim_Opportunity_ID__c = '1111';
        basket.Service_Number__c = '22';
        basket.Hot_Cutover__c = true;
        basket.Hot_Cutover_Comments__c = 'Comments';
        insert basket;

        //Create Product configuration
        cscfga__Product_Configuration__c config = createProductConfiguration();
        config.cscfga__Product_Basket__c = basket.id;
        update config;

        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        insert ord;

        csord__Subscription__c Parentsubs = new csord__Subscription__c ();
        Parentsubs = ProductTestFactory.buildSubscription('TestSubscriptionParent', acc.id, ord.id, ordReq.id);
        insert Parentsubs;

        csord__Subscription__c Childsubs = new csord__Subscription__c ();
        Childsubs  = ProductTestFactory.buildSubscription('TestSubscriptionChild', acc.id, ord.id, ordReq.id);
        Childsubs.Parent_Subscription__c = Parentsubs.id;
        insert Childsubs;
    }

    public static cscfga__Product_Configuration__c createProductConfiguration() {
        //Create Product Definition
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Test Product', 'Test Plan');
        insert prodDef;
        createSFAssociationForProdDefinition(prodDef.id);

        //Create Product configuration
        cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(prodDef.id);
        config.cscfga__Contract_Term__c = 12;
        config.cscfga__total_contract_value__c = 325;
        insert config;
        return config;
    }

    public static csord__Order__c getNewOrderWithRealAttributeDataAndMultipleServices(Account acc) {

        AttributeTest crd = new AttributeTest('Customer Requested Date', null, false, null);
        AttributeTest aggregator = new AttributeTest('Aggregator', null, false, null);
        AttributeTest fCIDN = new AttributeTest('Financial CIDN', null, false, null);
        AttributeTest iaID = new AttributeTest('Invoice Arrangement ID', null, false, null);
        AttributeTest pon = new AttributeTest('Purchase Order Number', null, false, null);
        AttributeTest bStatus = new AttributeTest('Basket Status', null, false, null);
        AttributeTest productType = new AttributeTest('ProductType', null, false, null);
        List<AttributeTest> attributeTests = new List<AttributeTest>{crd, aggregator, fCIDN, iaID, pon, bStatus, productType};

        //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;

        insert basket;

        //Create Product configuration
        cscfga__Product_Configuration__c config = createProductConfiguration();
        config.cscfga__Product_Basket__c = basket.id;
        update config;

        //Create Product Confuguration Request using existing method

        csbb__Product_Configuration_Request__c pcr  = ProductTestService.createPCRWIthCalloutResults();
        pcr.csbb__Product_Configuration__c = config.id;
        pcr.csbb__Product_Basket__c = basket.id;
        pcr.csbb__Total_OC__c = 25;
        pcr.csbb__Total_MRC__c = 25;

        update pcr;

        List<cscfga__Attribute_Definition__c> attDefList =  new List<cscfga__Attribute_Definition__c>();
        List<cscfga__Attribute__c> attList =  new List<cscfga__Attribute__c>();
        for(AttributeTest attTest : attributeTests) {
            cscfga__Attribute_Definition__c attDef = ProductTestFactory.buildAttributeDefinition(attTest.name, config.cscfga__Product_Definition__c);
            attDefList.add(attDef);
        }

        insert attDefList;

        for(Integer i=0;i<attributeTests.size();i++){
            AttributeTest attTest = attributeTests.get(i);
            cscfga__Attribute_Definition__c attDef = attDefList.get(i);
            cscfga__Attribute__c att  = ProductTestFactory.buildPriceAttribute(attTest.name, attTest.value, config.id, attTest.isLineItem, attTest.price);
            att.cscfga__Attribute_Definition__c = attDef.id;
            attList.add(att);
        }

        insert attList;

        Set<id> attributeDefIds = new Set<Id>();

        List<cscfga__Attribute_Field_Definition__c> attFdDefList =  new List<cscfga__Attribute_Field_Definition__c>();
        for(cscfga__Attribute_Definition__c def : attDefList){
            cscfga__Attribute_Field_Definition__c fdDef = new cscfga__Attribute_Field_Definition__c();
            fdDef.name = 'Required_for_Fulfilment';
            fdDef.cscfga__Default_Value__c = 'Submit';
            fdDef.cscfga__Attribute_Definition__c = def.id;
            attFdDefList.add(fdDef);
            attributeDefIds.add(def.id);
        }

        if(attFdDefList.size()>0){
            insert attFdDefList;
        }

        for(cscfga__Attribute_Definition__c de: [Select FulFillmentRequired_Count__c from cscfga__Attribute_Definition__c where id in :attributeDefIds]){
            System.debug('cscfga__Attribute_Definition__c def ' + de.FulFillmentRequired_Count__c);
        }

        for(cscfga__Attribute__c de1: [Select cscfga__Attribute_Definition__c, cscfga__Attribute_Definition__r.FulFillmentRequired_Count__c from cscfga__Attribute__c LIMIT 100]){
            System.debug('cscfga__Attribute__c ddddd ' + de1.cscfga__Attribute_Definition__c);
        }

        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        insert ord;
        csord__Subscription__c subs = ProductTestFactory.buildSubscription('Test Subscription', acc.id, ord.id, ordReq.id);
        insert subs;

        csord__Subscription__c parentSubs = ProductTestFactory.buildSubscription('Test Parent Subs', acc.id, ord.id, ordReq.id);
        insert parentSubs;

        csord__Service__c parentSer = ProductTestFactory.buildService('Test Parent Service', ord.id, parentSubs.id, ordReq.id);
        parentSer.csordtelcoa__Product_Configuration__c = config.id;
        insert parentSer;

        csord__Service__c testSer = ProductTestFactory.buildService('Test Service', ord.id, subs.id, ordReq.id);
        insert testSer;

        return ord;
    }

    public static void createPriceBookForBasket(cscfga__Product_Basket__c basket, Account acc, Id stdPb){

        //Create a pricebookentry for the standard pricebook
        Product2 prod = ProductTestFactory.getProduct();
        insert prod;
        PricebookEntry standardPrice = ProductTestFactory.getPricebookEntry(prod,stdPb);
        insert standardPrice;

        //Create pricebookentry for custom pricebook
        Pricebook2 pb = ProductTestFactory.getPricebook();
        insert pb;
        PricebookEntry customPrice = ProductTestFactory.getPricebookEntry(prod,pb.Id);
        insert customPrice;

        //Create opportunity linking account and the custom pricebook
        Opportunity opp  = ProductTestFactory.getOpportunity(acc,pb);
        insert opp;

        //Create opportunity line item linking opportunity and custom pricebookentry
        OpportunityLineItem oli = ProductTestFactory.getOpportunityLineItem(opp,customPrice);
        insert oli;

        //Update basket
        basket.cscfga__Opportunity__c = opp.Id;
        update basket;
    }

    public static void createPriceBookForBasketWithOppStage(cscfga__Product_Basket__c basket, Account acc, Id stdPb){

        //Create a pricebookentry for the standard pricebook
        Product2 prod = ProductTestFactory.getProduct();
        insert prod;
        PricebookEntry standardPrice = ProductTestFactory.getPricebookEntry(prod,stdPb);
        insert standardPrice;

        //Create pricebookentry for custom pricebook
        Pricebook2 pb = ProductTestFactory.getPricebook();
        insert pb;
        PricebookEntry customPrice = ProductTestFactory.getPricebookEntry(prod,pb.Id);
        insert customPrice;

        //Create opportunity linking account and the custom pricebook
        Opportunity opp  = ProductTestFactory.getOpportunity(acc,pb);
        opp.Product_Type__c = 'Modular';
        opp.StageName = 'Negotiation/Review';
        insert opp;

        //Create opportunity line item linking opportunity and custom pricebookentry
        OpportunityLineItem oli = ProductTestFactory.getOpportunityLineItem(opp,customPrice);
        insert oli;

        //Update basket
        basket.cscfga__Opportunity__c = opp.Id;
        update basket;
    }
	/*
	 A test class should have atleast one test method.Otherwise,we will get bug,so to avoid a bug, added one test method.
	*/
	private static testMethod void runPositiveTestCasesToFixBug() {
		System.assertequals('BugFix','BugFix');		
	}

}