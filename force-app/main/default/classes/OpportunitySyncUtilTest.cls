/*************************************************************************************************
Name : OpportunitySyncUtilTest
Description : Test class for OpportunitySyncUtil
**************************************************************************************************/
@isTest

private class OpportunitySyncUtilTest {
    
    @testSetup static void setup() {
        CustomConfigurationOptions__c customSetting = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Commercial Configuration'); 
        customSetting.Name = 'CommercialConfiguration';
        customSetting.External_Id__c = 'CCO_T_1';
        customSetting.Opportunity_Stage__c = 'Define';
        insert customSetting;
        CustomConfigurationOptions__c customSetting1 = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Quote'); 
        customSetting1.Name = 'Quote';
        customSetting1.External_Id__c = 'CCO_T_3';
        customSetting1.Opportunity_Stage__c = 'Define';
        insert customSetting1;
        CustomConfigurationOptions__c customSetting2 = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Contract Accepted'); 
        customSetting2.Name = 'ContractAccepted';
        customSetting2.External_Id__c = 'CCO_T_2';
        customSetting2.Opportunity_Stage__c = 'Define';
        insert customSetting2;
    
        Account acc = AccountTestFactory.buildAccount('Test Account 0') ;
        acc.Customer_Status__c = 'ACTIVE';
        insert acc;
        
        Id pricebookId = Test.getStandardPricebookId();

        //CREATE PRICEBOOK
        Pricebook2 pb = ProductTestFactory.getPricebook();
        insert pb;

        //CREATE PRODUCT
        Product2 prod = ProductTestFactory.getProduct();
        prod.Name = 'Recurring';
        insert prod;

        //CREATE PRICEBOOKENTRY
        PricebookEntry pbe = ProductTestFactory.getPricebookEntry(prod,pb.Id);
        pbe.Pricebook2Id = pricebookId;

        insert pbe;

        //CREATE OPPORTUNITY
        Opportunity opp  = ProductTestFactory.getOpportunity(acc,pb);
        opp.StageName = 'Commercial Configuration';
        insert opp;


        //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.Name = 'BasketOppSyncTest';
        basket.cscfga__Opportunity__c = opp.id;
        basket.cscfga__total_contract_value__c = 10000;
        insert basket;
        
        cscfga__Product_Basket__c basket1 = ProductTestFactory.buildEmptyBasket();
        basket1.csbb__Account__c = acc.id;
        basket1.Name = 'BasketZ1';
        basket1.cscfga__Opportunity__c = opp.id;
        basket1.cscfga__total_contract_value__c = 20000;
        basket1.csbb__synchronised_with_opportunity__c =true;
        insert basket1;
        
        cscfga__Product_Configuration__c config = ProductTestService.createProductConfiguration();
        config.cscfga__Product_Basket__c = basket.id;
        config.cscfga__Description__c = 'test Description sync 0';
        config.cscfga__Contract_Term__c = 36;

        cscfga__Product_Configuration__c config1 = ProductTestService.createProductConfiguration();
        config1.cscfga__Product_Basket__c = basket.id;
        config1.cscfga__Description__c = 'test Description sync 1';
        config1.cscfga__Contract_Term__c = 24;


        List<cscfga__Product_Configuration__c> configList = new List<cscfga__Product_Configuration__c>{config, config1};
        update configList;

        //Creation of Attributes with different attrbiutes Name and values.
        List<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>();
        for(cscfga__Product_Configuration__c configr:configList){
            cscfga__Attribute__c attr0 = ProductTestFactory.buildAttribute('SRM', '100.00', configr.id);
            attList.add(attr0);

            cscfga__Attribute__c attr1 = ProductTestFactory.buildAttribute('Partner Name', '200.00', configr.id);
            attList.add(attr1);

            cscfga__Attribute__c attr2 = ProductTestFactory.buildAttribute('OC', '400.00', configr.id);
            attList.add(attr2);

            cscfga__Attribute__c attr3 = ProductTestFactory.buildAttribute('Quantity', '300.00', configr.id);
            attList.add(attr3);

            cscfga__Attribute__c attr4 = ProductTestFactory.buildAttribute('ContractTerms', '500.00', configr.id);
            attList.add(attr4);

            cscfga__Attribute__c attr5 = ProductTestFactory.buildAttribute('Product Status', 'Lost', configr.id);
            attList.add(attr5);
            
            cscfga__Attribute__c attr6 = ProductTestFactory.buildAttribute('RC', '700.00', configr.id);
            attList.add(attr6);
            
            cscfga__Attribute__c attr7 = ProductTestFactory.buildAttribute('Product', 'Some value', configr.id);
            attList.add(attr7);
            
        }
        
        insert attList;

        List<cscfga__Attribute__c> newattrList = new List<cscfga__Attribute__c>();
        for(cscfga__Attribute__c attr : attList){
            if(attr.Name == 'Product'){
                newattrList.add(attr);
            }

        }

        OpportunityLineItem oli0  = new OpportunityLineItem(TotalPrice = 2000.00, Product_Status__c = 'Lost', pricebookentryid=pbe.Id,Quantity = 2, OpportunityId = basket.cscfga__Opportunity__c, Description = config.cscfga__Description__c, cscfga__Attribute__c = newattrList[0].Id);
        OpportunityLineItem oli1  = new OpportunityLineItem(TotalPrice = 2000.00, Product_Status__c = 'WOn', pricebookentryid=pbe.Id,Quantity = 2, OpportunityId = basket.cscfga__Opportunity__c, Description = config1.cscfga__Description__c, cscfga__Attribute__c = newattrList[1].Id);
        List<OpportunityLineItem> oLIList = new List<OpportunityLineItem>{oli0, oli1};
        insert oLIList;
       
        Id basketId =basket.Id;
        csbb__Product_Configuration_Request__c pcr0 = ProductTestFactory.buildConfigRequest(basketId,configList[0].id);
        csbb__Product_Configuration_Request__c pcr1 = ProductTestFactory.buildConfigRequest(basketId,configList[1].id);
        
        List<csbb__Product_Configuration_Request__c> pcrList = new List<csbb__Product_Configuration_Request__c>{pcr0,pcr1};
            insert pcrList;
    }

    
    //private static void setOppToStdPriceBook(cscfga__Product_Basket__c productBasket)
    @isTest static void test_setOppToStdPriceBook() {
        
        Account acc = AccountTestFactory.buildAccount('Test Account 0');
        acc.Customer_Status__c = 'ACTIVE';
        insert acc;
  
        Id pricebookId = Test.getStandardPricebookId();

        //CREATE PRICEBOOK
        Pricebook2 pb = ProductTestFactory.getPricebook();
        insert pb;

        //CREATE PRODUCT
        Product2 prod = ProductTestFactory.getProduct();
        prod.Name = 'Recurring';
        insert prod;

        //CREATE PRICEBOOKENTRY
        PricebookEntry pbe = ProductTestFactory.getPricebookEntry(prod,pb.Id);
        pbe.Pricebook2Id = pricebookId;

        insert pbe;

        //CREATE OPPORTUNITY
        Opportunity opp  = ProductTestFactory.getOpportunity(acc,pb);
        insert opp;


        //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.Name = 'Basket';
        basket.cscfga__Opportunity__c = opp.id;
        insert basket;
        
        Test.startTest();

        OpportunitySyncUtil.setOppToStdPriceBook(basket);
        Opportunity oppty = [SELECT id,Pricebook2Id from Opportunity where Id =:opp.id ];
        System.assert(oppty.Pricebook2Id != null);
        Test.stopTest();
    }
    
    @isTest static void test_updateOpptInfo() {
        
        Account acc = AccountTestFactory.buildAccount('Test Account 0');
        acc.Customer_Status__c = 'ACTIVE';  
        insert acc;
        
        Id pricebookId = Test.getStandardPricebookId();

        //CREATE PRICEBOOK
        Pricebook2 pb = ProductTestFactory.getPricebook();
        insert pb;

        //CREATE PRODUCT
        Product2 prod = ProductTestFactory.getProduct();
        prod.Name = 'Recurring';
        insert prod;

        //CREATE PRICEBOOKENTRY
        PricebookEntry pbe = ProductTestFactory.getPricebookEntry(prod,pb.Id);
        pbe.Pricebook2Id = pricebookId;

        insert pbe;

        //CREATE OPPORTUNITY
        Opportunity opp  = ProductTestFactory.getOpportunity(acc,pb);
        insert opp;


        //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.Name = 'Basket';
        basket.cscfga__Opportunity__c = opp.id;
        basket.cscfga__total_contract_value__c = 10000;
        insert basket;
        
        Test.startTest();
        OpportunitySyncUtil.updateOpptInfo(basket,'');
        Opportunity opt = [Select amount from Opportunity where id=:opp.id];
        System.assertEquals(10000,opt.Amount);
        Test.stopTest();
    }
    
    @isTest static void test_syncStatelessWithOpportunity(){
        
        String queryString = 'SELECT ' + OpportunitySyncUtil.getSobjectFields('cscfga__Product_Basket__c') +
            ', cscfga__opportunity__r.pricebook2.isstandard ' +
            ', (SELECT cscfga__product_definition__r.name ' +
            ', cscfga__product_definition__r.cscfga__product_category__r.name ' + ', ' +
            OpportunityBulkSyncHelper.getSobjectFields('cscfga__Product_Configuration__c') +
            ' FROM cscfga__Product_Configurations__r) ' +
            ' FROM cscfga__Product_Basket__c ORDER BY Name Limit 1';

        cscfga__Product_Basket__c productbasket = Database.query(queryString);
        Test.startTest();
        OpportunitySyncUtil.syncWithOpportunity(productbasket);
        System.assert(productBasket.csbb__synchronised_with_opportunity__c == true);
        Test.stopTest();
        
    }
    
    @isTest static void test_syncEmptyWithOpportunity(){
        
        cscfga__Product_Basket__c emptyProductbasket = null;
        Exception expectedException; 
        Test.startTest();
        String msg = OpportunitySyncUtil.syncWithOpportunity(emptyProductbasket, '');
        System.assert(msg != '');
        Test.stopTest();
        
    }

    @isTest static void test_syncWithOpportunity(){
        
        String queryString = 'SELECT ' + OpportunitySyncUtil.getSobjectFields('cscfga__Product_Basket__c') +
            ', cscfga__opportunity__r.pricebook2.isstandard ' +
            ', (SELECT cscfga__product_definition__r.name ' +
            ', cscfga__product_definition__r.cscfga__product_category__r.name ' + ', ' +
            OpportunityBulkSyncHelper.getSobjectFields('cscfga__Product_Configuration__c') +
            ' FROM cscfga__Product_Configurations__r) ' +
            ' FROM cscfga__Product_Basket__c ORDER BY Name Limit 1';

        cscfga__Product_Basket__c productbasket = Database.query(queryString);
        Test.startTest();
        String msg1 = OpportunitySyncUtil.syncWithOpportunity(productbasket, 'CommercialConfiguration');
        System.assert(productBasket.csbb__synchronised_with_opportunity__c == true);
        Test.stopTest();
        
    }
    
    @isTest
    static void testCheckOppContactRolePositive()
    {
        Test.startTest();
        Account acc = AccountTestFactory.buildAccount('Test Account 0') ;
        acc.Customer_Status__c = 'ACTIVE';
        insert acc;
        
        Pricebook2 pb = ProductTestFactory.getPricebook();
        insert pb;
        
        Opportunity opp  = ProductTestFactory.getOpportunity(acc,pb);
        opp.StageName = 'Commercial Configuration';
        insert opp;
        
        Contact c = new Contact();
        c.FirstName = 'Testing';
        c.LastName = 'Test';
        c.AccountId = acc.id;
        insert c;
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = c.Id;
        ocr.OpportunityId = opp.Id;
        ocr.IsPrimary = TRUE;
        ocr.Role = 'Decision Maker';
        insert ocr;
        Test.stopTest();
        
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.Name = 'BasketOppSyncTest';
        basket.cscfga__Opportunity__c = opp.id;
        basket.cscfga__total_contract_value__c = 10000;
        insert basket;
        
        
        Boolean testBool = OpportunitySyncUtil.checkOppContactRole(basket.Id,null);
        
        System.assertEquals(true, testBool, 'Opportunity should have a contact role');
    }
    
    @isTest
    static void testCheckOppContactRoleNegative()
    {
        Account acc = AccountTestFactory.buildAccount('Test Account 0') ;
        acc.Customer_Status__c = 'ACTIVE';
        insert acc;
        
        Pricebook2 pb = ProductTestFactory.getPricebook();
        insert pb;
        
        Opportunity opp2  = ProductTestFactory.getOpportunity(acc,pb);
        opp2.StageName = 'Commercial Configuration';
        insert opp2;

        cscfga__Product_Basket__c basket2 = ProductTestFactory.buildEmptyBasket();
        basket2.csbb__Account__c = acc.id;
        basket2.Name = 'BasketOppSyncTest2';
        basket2.cscfga__Opportunity__c = opp2.id;
        basket2.cscfga__total_contract_value__c = 10000;
        insert basket2;
        
        Test.startTest();
        Boolean testBool2 = OpportunitySyncUtil.checkOppContactRole(basket2.Id,null);
        Test.stopTest();
        System.assertEquals(false, testBool2, 'Opportunity should not have a contact role');
    }
    
    @isTest
    static void testGetStdPriceBook()
    {
        String testError;
        Test.startTest();
        try{
        Pricebook2 testPricebook = OpportunitySyncUtil.getStdPriceBook();
        }
        catch(Exception e)
        {
            testError = e.getMessage(); 
        }
        Test.stopTest();
        System.assertEquals(true, testError.contains('List has no rows for assignment to SObject'), 'Should return a standard pricebook');
    }
    
    @isTest
    static void testSyncWithOpportunity()
    {
        Account acc = AccountTestFactory.buildAccount('Test Account 0') ;
        acc.Customer_Status__c = 'ACTIVE';
        insert acc;
        
        Pricebook2 pb = ProductTestFactory.getPricebook();
        insert pb;
        
        Opportunity opp  = ProductTestFactory.getOpportunity(acc,pb);
        opp.StageName = 'Commercial Configuration';
        insert opp;
        
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.Name = 'BasketOppSyncTest';
        basket.cscfga__Opportunity__c = opp.id;
        basket.cscfga__total_contract_value__c = 10000;
        insert basket;
        
        Test.startTest();
        String result = OpportunitySyncUtil.syncWithOpportunity(String.valueOf(basket.Id), 'Draft');
        Test.stopTest();
        
        System.assertEquals(true, result.contains('error'), 'since it calls another method, return should be error');
    }
   
}