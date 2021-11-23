/*************************************************************************************************
Name : productUtilityForModular
Test Class: productUtilityForModularTest
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.         Ankit Goswami     19/11/2020     EDGE-178204:External ID & Order Type Framework
2.         Gokul             15/12/2020     EDGE-178211,187998,181998,188858,187313 - Create OLIS for RatecardLineItems - TC,MS,MDM
3.         Kamlesh           25/03/2021     EDGE-205509 Added UpdateBasketwithJobIdTest to test sync job updation
4.		   Natasha			 25/10/2021		DIGI-32161:Added Changes for DMS Sales Incentive
===============================================================================================================================
***************************************************************************************************/

@isTest    
public class productUtilityForModularTest 
{   
    static String PROD_CONFIGURATION_TYPE_NEW = 'New';
    static String PROD_CONFIGURATION_STATUS_INVALID = 'Incomplete';
    static String PROD_CONFIGURATION_STATUS_VALID = 'Valid';
    static String PRODUCT_BASKET_STAGE = 'Contract Accepted';
    
    @testSetup
    static void testdata(){
        
        Account testAccount = AccountTestFactory.buildAccount ('testAccount');
        //Laxmi - EDGE - 133414 added below record type code ode to satisfy partner type condition
        RecordType recType = [Select id, name From RecordType Where sObjectType = 'Account' and Name = 'Partner'];
        testAccount.RecordTypeID = recType.id;
        // EDGE-133414 changes end
        insert testAccount;
        
        // EDGE-144345  changed to use ProductTestFactory
        Opportunity testOpp = ProductTestFactory.getOpportunityBasic (testAccount);
        testOpp.Account = testAccount;
        testOpp.Product_Type__c = 'Modular';
        insert testOpp;
        
        cscfga__Product_Basket__c testBasket = ProductTestFactory.buildEmptyBasket();
        testBasket.csbb__Account__c = testAccount.Id;
        testBasket.Name = 'ShowSubTestBasket';
        testBasket.cscfga__Opportunity__c = testOpp.Id;
        // testBasket.csordtelcoa__Change_Type__c = 'Upgrade';
        insert testBasket;
        
        cscfga__Product_Definition__c pd1 = new cscfga__Product_Definition__c ();
        pd1.Name = 'IP Network';
        pd1.cscfga__Description__c = 'Description';
        insert pd1;

        List <cscfga__Product_Configuration__c> listTestConfig = new List <cscfga__Product_Configuration__c>();
        
        //EDGE-144345  changed to use ProductTestFactory
        cscfga__Product_Configuration__c testConfig = ProductTestFactory.buildProductConfig (pd1.id );
        testConfig.Name = 'IP Network1';
        testConfig.cscfga__Product_Basket__c = testBasket.Id;
        testConfig.cscfga__Product_Family__c = 'Modular';
        testConfig.Quantity_Product_Configuration__c = 1;
        testConfig.cscfga__Contract_Term__c = 12;
        testConfig.cscfga__Product_Definition__c =pd1.id ;
        testConfig.Quantity_Product_Configuration__c = 6;
        testConfig.cscfga__discounts__c = '{"discounts":[{"source":"BasePrices","version":"3-1-0","discountPrice":"list","discountCharge":"__PRODUCT__","amount":1162.72,"type":"override","chargeType":"oneOff","recordType":"single","customData":{"promotion":true},"description":"BasePrices"}]}';
        testConfig.cscfga__total_recurring_charge__c = 100;
        testConfig.cscfga__total_one_off_charge__c = 10;
        listTestConfig.add (testConfig);        
                
        // Added as part of EDGE-133414
        cscfga__Product_Configuration__c testConfigCancel = ProductTestFactory.buildProductConfig (pd1.id );
        testConfigCancel.Name = 'IP Network';
        testConfigCancel.cscfga__Product_Basket__c = testBasket.Id;
        testConfigCancel.cscfga__Product_Family__c = 'Modular';
        testConfigCancel.Quantity_Product_Configuration__c = 1;
        testConfigCancel.cscfga__Contract_Term__c = 12;
        testConfigCancel.Type__c ='Cancel';
        testConfigCancel.cscfga__discounts__c = '{"discounts":[{"source":"BasePrices","version":"3-1-0","discountPrice":"list","discountCharge":"__PRODUCT__","amount":1162.72,"type":"override","chargeType":"oneOff","recordType":"single","customData":{"promotion":true},"description":"BasePrices"}]}';
        testConfigCancel.Quantity_Product_Configuration__c = 6;
        testConfig.cscfga__total_recurring_charge__c = 100;
        
        testConfig.cscfga__total_one_off_charge__c = 10;
        listTestConfig.add (testConfigCancel);
        
        insert listTestConfig;
        
        // EDGE-133414 Changes END
        List <cscfga__Attribute__c> listTestAttribute = new List <cscfga__Attribute__c>();
        
        cscfga__Attribute__c testAttribute = new cscfga__Attribute__c();
        testAttribute.Name = 'EarlyTerminationCharge';
        testAttribute.cscfga__Product_Configuration__c = testConfig.Id;
        testAttribute.cscfga__Is_Line_Item__c = true;
        testAttribute.cscfga__is_active__c = true;
        //testAttribute.cscfga__Product_Configuration__r =  testConfig;
        testAttribute.cscfga__Line_Item_Description__c = 'Test';        
        testAttribute.cscfga__Recurring__c = true;
        testAttribute.cscfga__Price__c = 100;
        testAttribute.cscfga__Value__c = '100';
        testAttribute.cscfga__List_Price__c = 100;
        listTestAttribute.add (testAttribute); // Added as part of EDGE-133414
        
        cscfga__Attribute__c testChargeAttribute = new cscfga__Attribute__c();
        testChargeAttribute.Name = 'RC';
        testChargeAttribute.cscfga__Product_Configuration__c = testConfig.Id;
        testChargeAttribute.cscfga__Is_Line_Item__c = true;
        testChargeAttribute.cscfga__is_active__c = true;
        //testAttribute.cscfga__Product_Configuration__r =  testConfig;
        testChargeAttribute.cscfga__Line_Item_Description__c = 'Test';        
        testChargeAttribute.cscfga__Recurring__c = true;
        testChargeAttribute.cscfga__Price__c = 59.09;
        testChargeAttribute.cscfga__Value__c = '59.09';
        testChargeAttribute.cscfga__List_Price__c = 59.09;
        testChargeAttribute.cscfga__Discount_Type__c = 'amount';
        
        
        listTestAttribute.add (testChargeAttribute); // Added as part of EDGE-185438
        
        // Added as part of EDGE-133414
        cscfga__Attribute__c testAttributeETC =  ProductTestFactory.buildPriceAttribute ('ETCCancel','100',testConfigCancel.Id,true,100); 
        testAttributeETC.cscfga__Is_Line_Item__c = true;
        testAttributeETC.cscfga__is_active__c = true;
        testAttributeETC.cscfga__Line_Item_Description__c = 'Test Cancel';        
        
        listTestAttribute.add (testAttributeETC);
        insert listTestAttribute; 
        // EDGE-133414  Changes END
        
        // EDGE-185438 Insert Incremental Revenue for RC
        //EDGE-173495 :|| start
        List<cscfga__Attribute_Field__c> attrFieldList= new  List<cscfga__Attribute_Field__c>();
        cscfga__Attribute_Field__c attrField=new cscfga__Attribute_Field__c();
        attrField.name ='IncrementalRevenue';
        attrField.cscfga__Attribute__c=testAttribute.id;
        attrField.cscfga__Value__c='0';
        attrFieldList.add(attrField);
        
        cscfga__Attribute_Field__c attrField1=new cscfga__Attribute_Field__c();
        attrField1.name ='TechTransRevenue';
        attrField1.cscfga__Attribute__c=testAttributeETC.id;
        attrField1.cscfga__Value__c='0';
        attrFieldList.add(attrField1);
        insert attrFieldList;
        
        Product2 prodct2=new Product2();
        prodct2.Family='Modular'; 
        prodct2.IsActive=true;
        prodct2.Name='Test';
        prodct2.ProductCode='test';
        insert prodct2;
        //EDGE-173495 :|| end 

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
        
        Marketable_Offer__c marOff = new Marketable_Offer__c();
        marOff.Name = 'Enterprise Mobility Managed Service';
        marOff.Offer_ID__c = 'DMCAT_Offer_000854';
        insert marOff;
        
        List <csord__Subscription__c> listTestSubscription = new List <csord__Subscription__c>(); // Added as part of 133414 as multiple inserts were done
        
        csord__Subscription__c testSubscription = new csord__Subscription__c();
        testSubscription.Name = 'IP Network';
        testSubscription.csord__Account__c = testAccount.Id;
        testSubscription.csord__Order__c = testOrder.Id;
        testSubscription.csord__Identification__c = 'test';
        testSubscription.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription.csord__Status__c = 'Active';
        testSubscription.MarketableOffer__c = marOff.id; 
        listTestSubscription.add (testSubscription);
        
        
        csord__Subscription__c testSubscription1 = new csord__Subscription__c();
        testSubscription1.Name = 'Unified Communication Enterprise';
        testSubscription1.csord__Account__c = testAccount.Id;
        testSubscription1.csord__Order__c = testOrder.Id;
        testSubscription1.csord__Identification__c = 'test';
        testSubscription1.csordtelcoa__Product_Configuration__c = testConfig.Id;
        testSubscription1.csord__Status__c = 'Active';
        testSubscription1.MarketableOffer__c = marOff.id; 
        listTestSubscription.add (testSubscription1);
        
        insert listTestSubscription; // Changed as part of EDGE-133414 - Inserted list instead of multiple inserts
        
        csord__Service__c serv2 = new csord__Service__c();
        serv2.name ='User - Fixed Seat';
        serv2.csordtelcoa__Product_Configuration__c = testConfig.id;
        serv2.csord__Identification__c  = 'testIdentify_2';
        serv2.csord__Subscription__c = testSubscription.Id;
        insert serv2; 
        
        //Added as part of EDGE-144345  
        List <User> userList = new List <User>();
        Profile testProfile = [select id from profile where name =:Label.Profile_SalesEnterprise];  
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='TestingProdUtil', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = testProfile.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesuser@testsales.com',phone='+121231231234');     
        userList.add (sales);
        
        
        Profile testProfileAdmin = [select id from profile where name =:Label.Profile_SystemAdmin];  
        User admin = new User(alias = 'standt',email='admin@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='TestingAdmin', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = testProfileAdmin.id,
                              timezonesidkey='Australia/Sydney',
                              username='admin@testsales.com',phone='+121231231256');   
        userList.add(admin);
        insert userList;
        
        // Changes End EDGE-144345  
        
    }
    
    @istest 
    public static void CreateOLIsTest(){
        //  EDGE-144345  - Added Run as , test.startTest(),test.stopTest() and changed the assertNot equal to Null to actual expected
        
        
        User admin = [ select name,id, lastname from  User where lastname = 'TestingAdmin' ];
        System.runAS (admin){  
            Environment_Configurations__c ecCusSetting  =   Environment_Configurations__c.getInstance(UserInfo.getUserId());
            cscfga__Product_Basket__c basketTest = [Select csordtelcoa__Synchronised_with_Opportunity__c, id from cscfga__Product_Basket__c Limit 1];
            test.startTest();
            set<string> setUnSyncedProductBasketId = new set<string>();
            setUnSyncedProductBasketId.add(basketTest.id);      
            productUtilityForModular prod=new productUtilityForModular();
            prod.syncProductBaskt(setUnSyncedProductBasketId,ecCusSetting);
            Opportunity opp1 = [select id,Opportunity_Line_Item_Count__c  from Opportunity limit 1 ];
			list<OpportunityLineItem> listOli = new list<OpportunityLineItem>([select id, Quantity, New_Income_Revenue__c from OpportunityLineItem]);
            system.debug(' up listOli-'+listOli);
            test.stopTest();
            System.assertNotEquals(null,opp1.Id);
        }
    }
    @istest 
    public static void CreateOLIsAsyncTest(){
        cscfga__Product_Basket__c basketTest = [Select csordtelcoa__Synchronised_with_Opportunity__c, id from cscfga__Product_Basket__c Limit 1];
        Test.startTest();
        set<string> setUnSyncedProductBasketId = new set<string>();
        setUnSyncedProductBasketId.add(basketTest.id);
        //productUtilityForModular prod=new productUtilityForModular();
        productUtilityForModular.createOLIsAsync(setUnSyncedProductBasketId);
        Opportunity opp1 = [select id,Opportunity_Line_Item_Count__c  from Opportunity limit 1 ];
        Test.stopTest();
        System.assertNotEquals(null,opp1.Id);
    }
//Created by Natasha as part of DIGI-32161
    @istest 
    private static void createOLIForChargeFrequency(){
        
        User admin = [ select name,id, lastname from  User where lastname = 'TestingAdmin' ];
        System.runAS (admin){  
      	account testAccount = [select id from account];
        opportunity testOpp = [select id from opportunity];
        
        cscfga__Product_Basket__c testBasket1 = ProductTestFactory.buildEmptyBasket();
        testBasket1.csbb__Account__c = testAccount.Id;
        testBasket1.Name = 'DMSBasket';
        testBasket1.cscfga__Opportunity__c = testOpp.Id;
        insert testBasket1;
        
        cscfga__Product_Definition__c pd2 = new cscfga__Product_Definition__c ();
        pd2.Name = 'Digital Managed Service Solution';
        pd2.cscfga__Description__c = 'Description';
        insert pd2;
        
        cscfga__Product_Configuration__c testConfig1 = ProductTestFactory.buildProductConfig (pd2.id );
        testConfig1.Name = 'Digital Managed Service Solution';
        testConfig1.cscfga__Product_Basket__c = testBasket1.Id;
        testConfig1.cscfga__Product_Family__c = 'Digital Managed Service Solution';
        testConfig1.Quantity_Product_Configuration__c = 1;
        testConfig1.cscfga__Contract_Term__c = 24;
        testConfig1.cscfga__Product_Definition__c =pd2.id ;
        testConfig1.Quantity_Product_Configuration__c = 6;
        testConfig1.cscfga__total_recurring_charge__c = 100;
        testConfig1.cscfga__total_one_off_charge__c = 10;
        testConfig1.Type__c = 'New';
        insert testConfig1;
        
        cscfga__Attribute__c testAttribute1 = new cscfga__Attribute__c();
        testAttribute1.Name = 'json_sios';
        testAttribute1.cscfga__Product_Configuration__c = testConfig1.Id;
        testAttribute1.cscfga__is_active__c = true;
        testAttribute1.cscfga__Line_Item_Description__c = 'DMS Test';        
        testAttribute1.cscfga__Recurring__c = true;
        testAttribute1.cscfga__Price__c = 0;
        testAttribute1.cscfga__Value__c = '[{"name":"MPC Critical SQL PaaS","expectedSIO":1,"currentRate":7.6,"previousRate":0,"actualSIO":0,"rateCardId":"DMCAT_Offer_001540_DMCAT_ProductSpecification_001541_DMCAT_RecurringCharge_001545_15186_170","rateCardName":"MPC Critical SQL PaaS","chargeFrequency":"Daily"}]';
        testAttribute1.cscfga__List_Price__c = 0;
        insert testAttribute1;
        
        cscfga__Attribute_Field__c attrField = new cscfga__Attribute_Field__c ();
        attrField.name = 'isRateCardLineItem';
        attrField.cscfga__Attribute__c = testAttribute1.id;
        attrField.cscfga__Value__c = 'true';
        insert attrField;
		 
        Product2 prod = ProductTestFactory.getProduct();
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        //Create Pricebook
        Pricebook2 pb = ProductTestFactory.getPricebook();
        insert pb;
        
        //Create PricebookEntry
        PricebookEntry pbe = ProductTestFactory.getPricebookEntry(prod,pb.Id);
        pbe.Pricebook2Id = pricebookId;
        insert pbe;
        
        ProductUtilityForModular.OLIWrapper wrap = new ProductUtilityForModular.OLIWrapper();
        wrap.UnitPrice = 7.6;
        wrap.OpportunityId = testOpp.id;
        wrap.ProductBasketId = testbasket1.id;
        wrap.attributeId = testAttribute1.id;
        wrap.productConfigId = testConfig1.id;
		wrap.ProductBasketFamily = 'DMS Product';
        wrap.prodConfigType = testConfig1.Type__c;
        wrap.chargeFrequency = 'Daily';
        wrap.expectedsio = 2;
		wrap.isRecurring = true;            
        wrap.contarctTerm ='3';
        wrap.isPatner = 'test';
        wrap.attributeName = 'json_sios';
        wrap.prodConfigType = 'test ';
         
        OpportunityLineItem optyLi = new OpportunityLineItem();
        optyLi.OpportunityId = wrap.OpportunityId;
        optyLi.Quantity = wrap.expectedsio;
        optyLi.UnitPrice = 20.0;
        optyli.PricebookEntryId = pbe.id ;
        optyli.Recurring_Price__c = 3;
        optyli.One_Off_Price__c = 1;
        insert optyLi;
        
        cspmb__Price_Item__c testcommercial = new cspmb__Price_Item__c();
		testcommercial.Name = 'Digital Managed Services';
		testcommercial.chargeFrequency__c = 'Daily';
		insert testcommercial; 
              
        
        productUtilityForModular PM = new productUtilityForModular();
        
        Test.startTest();
		set<string> setUnSyncedProductBasketId = new set<string>();
        setUnSyncedProductBasketId.add(testBasket1.id);
        productUtilityForModular.createOLIsAsync(setUnSyncedProductBasketId);
        OpportunityLineItem oli = PM.getTmpOpportunityLineItem(optyLi ,wrap);  
        Opportunity opp1 = [select id,Opportunity_Line_Item_Count__c  from Opportunity where id=:testOpp.id limit 1 ];
        System.assertNotEquals(null,opp1.Id);
   		System.assertEquals('Daily', wrap.chargeFrequency);
		System.assertEquals(optyLi.New_Income_Revenue__c, 5548.0);
        system.debug('optyLi.New_Income_Revenue__c'+oli.New_Income_Revenue__c);
        list<OpportunityLineItem> listOli = new list<OpportunityLineItem>([select id, Quantity, New_Income_Revenue__c from OpportunityLineItem]);
        system.debug('listOli-'+listOli);
        Test.stopTest();     
    }
    }
    @istest 
    private static void CreateOLIsForRateLineItemTest(){
        
        account testAccount = [select id from account];
        opportunity testOpp = [select id from opportunity];
        cscfga__Product_Basket__c testBasket = ProductTestFactory.buildEmptyBasket();
        testBasket.csbb__Account__c = testAccount.Id;
        testBasket.Name = 'ShowSubTestBasket';
        testBasket.cscfga__Opportunity__c = testOpp.Id;
        // testBasket.csordtelcoa__Change_Type__c = 'Upgrade';
        insert testBasket;
        
        cscfga__Product_Definition__c pd1 = new cscfga__Product_Definition__c ();
        pd1.Name = 'Telstra Colloboration';
        pd1.cscfga__Description__c = 'Description';
        insert pd1;
        
        cscfga__Product_Configuration__c testConfig = ProductTestFactory.buildProductConfig (pd1.id );
        testConfig.Name = 'IP Network1';
        testConfig.cscfga__Product_Basket__c = testBasket.Id;
        testConfig.cscfga__Product_Family__c = 'Modular';
        testConfig.Quantity_Product_Configuration__c = 1;
        testConfig.cscfga__Contract_Term__c = 12;
        testConfig.cscfga__Product_Definition__c =pd1.id ;
        testConfig.Quantity_Product_Configuration__c = 6;
        testConfig.cscfga__total_recurring_charge__c = 100;
        testConfig.cscfga__total_one_off_charge__c = 10;
        insert testConfig;
        
        cscfga__Attribute__c testAttribute = new cscfga__Attribute__c();
        testAttribute.Name = 'json_sios';
        testAttribute.cscfga__Product_Configuration__c = testConfig.Id;
        testAttribute.cscfga__is_active__c = true;
        testAttribute.cscfga__Line_Item_Description__c = 'Test';        
        testAttribute.cscfga__Recurring__c = true;
        testAttribute.cscfga__Price__c = 0;
        testAttribute.cscfga__Value__c = '[{"name":"Cloud User","expectedSIO":11,"currentRate":3,"previousRate":0,"actualSIO":0,"rateCardName":"Cloud User"}]';
        testAttribute.cscfga__List_Price__c = 0;
        insert testAttribute;
        
        cscfga__Attribute_Field__c attrField = new cscfga__Attribute_Field__c ();
        attrField.name = 'isRateCardLineItem';
        attrField.cscfga__Attribute__c = testAttribute.id;
        attrField.cscfga__Value__c = 'true';
        insert attrField;
        
        Test.startTest();
        set<string> setUnSyncedProductBasketId = new set<string>();
        setUnSyncedProductBasketId.add(testBasket.id);
        productUtilityForModular.createOLIsAsync(setUnSyncedProductBasketId);
        Opportunity opp1 = [select id,Opportunity_Line_Item_Count__c  from Opportunity limit 1 ];
        System.assertNotEquals(null,opp1.Id);
        Test.stopTest();
        
    }
    
    @istest 
    private static void CreateOLIsForRateLineItemMACDTest(){
        
        account testAccount = [select id from account];
        opportunity testOpp = [select id from opportunity];
        cscfga__Product_Basket__c testBasket = ProductTestFactory.buildEmptyBasket();
        testBasket.csbb__Account__c = testAccount.Id;
        testBasket.Name = 'ShowSubTestBasket';
        testBasket.cscfga__Opportunity__c = testOpp.Id;
        insert testBasket;
        
        cscfga__Product_Definition__c pd1 = new cscfga__Product_Definition__c ();
        pd1.Name = 'Telstra Colloboration';
        pd1.cscfga__Description__c = 'Description';
        insert pd1;
        
        cscfga__Product_Configuration__c testConfig = ProductTestFactory.buildProductConfig (pd1.id );
        testConfig.Name = 'IP Network1';
        testConfig.cscfga__Product_Basket__c = testBasket.Id;
        testConfig.cscfga__Product_Family__c = 'Modular';
        testConfig.Quantity_Product_Configuration__c = 1;
        testConfig.cscfga__Contract_Term__c = 12;
        testConfig.type__c = 'modify';
        testConfig.cscfga__Product_Definition__c =pd1.id ;
        testConfig.Quantity_Product_Configuration__c = 6;
        testConfig.cscfga__total_recurring_charge__c = 100;
        testConfig.cscfga__total_one_off_charge__c = 10;
        insert testConfig;
        
        cscfga__Attribute__c testAttribute = new cscfga__Attribute__c();
        testAttribute.Name = 'json_sios';
        testAttribute.cscfga__Product_Configuration__c = testConfig.Id;
        testAttribute.cscfga__is_active__c = true;
        testAttribute.cscfga__Line_Item_Description__c = 'Test';        
        testAttribute.cscfga__Recurring__c = true;
        testAttribute.cscfga__Price__c = 0;
        testAttribute.cscfga__Value__c = '[{"name":"Cloud User","expectedSIO":11,"currentRate":3,"previousRate":0,"actualSIO":0,"rateCardName":"Cloud User"}]';
        testAttribute.cscfga__List_Price__c = 0;
        insert testAttribute;
        cscfga__Attribute_Field__c attrField = new cscfga__Attribute_Field__c ();
        attrField.name = 'isRateCardLineItem';
        attrField.cscfga__Attribute__c = testAttribute.id;
        attrField.cscfga__Value__c = 'true';
        insert attrField;
        
        Test.startTest();
        set<string> setUnSyncedProductBasketId = new set<string>();
        setUnSyncedProductBasketId.add(testBasket.id);
        productUtilityForModular.createOLIsAsync(setUnSyncedProductBasketId);
        Opportunity opp1 = [select id,Opportunity_Line_Item_Count__c  from Opportunity limit 1 ];
        System.assertNotEquals(null,opp1.Id);  
        Test.stopTest();
        
    }
    
     @istest 
    public static void deleteOpportunityOLITest(){
        cscfga__Product_Basket__c basketTest = [Select csordtelcoa__Synchronised_with_Opportunity__c, id from cscfga__Product_Basket__c Limit 1];
        Test.startTest();
        set<id> setUnSyncedProductBasketId = new set<id>();
        setUnSyncedProductBasketId.add(basketTest.id);
        //productUtilityForModular prod=new productUtilityForModular();
        productUtilityForModular.deleteOpportunityOLIs(setUnSyncedProductBasketId);
        Opportunity opp1 = [select id,Opportunity_Line_Item_Count__c  from Opportunity limit 1 ];
        Test.stopTest();
        System.assertNotEquals(null,opp1.Id);
    }
    
    @istest 
    public static void UpdateBasketwithJobIdTest(){
        cscfga__Product_Basket__c basketTest = [Select csordtelcoa__Synchronised_with_Opportunity__c, id from cscfga__Product_Basket__c Limit 1];
        Test.startTest();
        set<string> setUnSyncedProductBasketId = new set<string>();
        setUnSyncedProductBasketId.add(basketTest.id);
        //productUtilityForModular prod=new productUtilityForModular();
        productUtilityForModular.updateBasketwithJobId('[{"name":"syncJobId","isCompleted":true,"id":"7072N00000L8FF2QAN","error":false},{"name":"fundJobId","isCompleted":true,"id":"7072N00000L8FF2QAQ","error":true}]','fundJobId',setUnSyncedProductBasketId ,new Map<String,String>());
        Map<String,String> jobMap = new Map<String,String>();
        jobMap.put(basketTest.id,'[{"name":"syncJobId","isCompleted":true,"id":"7072N00000L8FF2QAN","error":false}]');
        productUtilityForModular.updateBasketwithJobId('','oppSync',setUnSyncedProductBasketId,jobMap);
        productUtilityForModular.updateBasketwithJobId('[{"name":"oppSyncJobId","isCompleted":true,"id":"7072N00000L8FF2QAN","error":false}]','oppSync',setUnSyncedProductBasketId,new Map<String,String>());
        Opportunity opp1 = [select id,Opportunity_Line_Item_Count__c  from Opportunity limit 1 ];
        Test.stopTest();
        System.assertNotEquals(null,opp1.Id);
    }
}