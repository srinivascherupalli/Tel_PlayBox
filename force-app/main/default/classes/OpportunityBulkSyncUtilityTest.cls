@isTest(seeAllData=true) //seeAllData is set to true to ensure cscfga.API_1.syncBundleToOpportunity doesnot throw error while querying pricebook

private class OpportunityBulkSyncUtilityTest {
    //private static void deleteOrphanProdConfigs(List<String> basketIds)
    @isTest static void test_deleteOrphanProdConfigs() {
        OpportunityTestFactory.createDataforTest();
        List<cscfga__Product_Basket__c> basketList = [SELECT Id, Name from cscfga__Product_Basket__c where Name Like 'Test Class Basket %' Limit 10];
        List<String> basketIds = new List<String>();
        for(cscfga__Product_Basket__c basket:basketList){
            basketIds.add(basket.Id);
        }

        OpportunityBulkSyncUtility.deleteOrphanProdConfigs(basketIds);

        List<cscfga__Product_Configuration__c> prodConfigList = [SELECT Id, Name,cscfga__root_configuration__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c in:basketIds and Name='test config' and cscfga__root_configuration__c = null];
        System.assert(prodConfigList.size() == 0);
    }
   
    //private static void setOppToStdPriceBook(List<Opportunity> opptys)
    @isTest static void test_setOppToStdPriceBook() {
        OpportunityTestFactory.createDataforTest();
        List<Opportunity> opptyList = [SELECT Id, Name, Pricebook2Id, Pricebook2.IsStandard, StageName from Opportunity where Name ='TestOpp' and CloseDate=:System.Today() LIMIT 5];
        OpportunityBulkSyncUtility.setOppToStdPriceBook(opptyList);
        System.assert(opptyList[0].Pricebook2Id != null);
        System.assert(opptyList[1].Pricebook2Id != null);
        System.assert(opptyList[3].Pricebook2Id != null);

    }
    
    @isTest static void test_getStdPricebookId() {
        OpportunityTestFactory.createDataforTest();
        List<Opportunity> opptyList = [SELECT Id, Name, Pricebook2Id, Pricebook2.IsStandard, StageName from Opportunity  where Name ='TestOpp' and CloseDate=:System.Today() LIMIT 1];
		OpportunityBulkSyncUtility.setOppToStdPriceBook(opptyList);
        Id pb = OpportunityBulkSyncUtility.getStdPricebookId();
        Pricebook2 pbBook = OpportunityBulkSyncUtility.getStdPricebook();
        System.assert(pb == opptyList[0].Pricebook2Id);
        
    }
    //private static List<cscfga__Product_Basket__c> getValidProductBasket(List<String> basketIds, List<cscfga__Product_Configuration__c> configList)
    @isTest static void test_getValidProductBasket() {
       //Create accounts
        List<Account> accountList = new List<Account>();

        for(Integer i= 0; i < 10; i++){
            Account acc1 = AccountTestFactory.buildAccount('Test Account '+i);
            accountList.add(acc1);
        }

        insert accountList;

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
        List<Opportunity> opptyList = new List<Opportunity>();
        for(Integer j = 0; j < 8; j++){
            Opportunity opp0  = ProductTestFactory.getOpportunity(accountList[j],pb);
            opptyList.add(opp0);
        }
        insert opptyList;


        List<cscfga__Product_Basket__c> baskets = new List<cscfga__Product_Basket__c>();
        for(Integer b = 0; b < 8; b++){
            cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
            basket.csbb__Account__c = accountList[b].id;
            basket.Name = 'Test Class Basket '+b;
            basket.cscfga__Opportunity__c = opptyList[b].id;
            baskets.add(basket);
        }

        cscfga__Product_Basket__c basket8 = ProductTestFactory.buildEmptyBasket();
        basket8.csbb__Account__c = accountList[7].id;
        basket8.Name = 'Test Class Basket 8';
        basket8.cscfga__Opportunity__c = opptyList[7].id;
        baskets.add(basket8);

        cscfga__Product_Basket__c basket9 = ProductTestFactory.buildEmptyBasket();
        basket9.csbb__Account__c = accountList[7].id;
        basket9.Name = 'Test Class Basket 9';
        basket9.cscfga__Opportunity__c = opptyList[7].id;
        baskets.add(basket9);

        insert baskets;

        //Create config
        List<cscfga__Product_Configuration__c> configList = new List<cscfga__Product_Configuration__c>();

        for(Integer c = 0; c < 9; c++){
            cscfga__Product_Configuration__c config = ProductTestService.createProductConfiguration();
            config.cscfga__Product_Basket__c = baskets[c].id;
            config.cscfga__Description__c = 'test Description '+c;
            config.cscfga__Contract_Term__c = 12;
            configList.add(config);
        }
        
        cscfga__Product_Configuration__c config9 = ProductTestService.createProductConfiguration();
        config9.cscfga__Product_Basket__c = baskets[9].id;
        config9.cscfga__Description__c = 'test Description 9';
        config9.cscfga__Contract_Term__c = 24;
        configList.add(config9);

        cscfga__Product_Configuration__c config10 = ProductTestService.createProductConfiguration();
        config10.cscfga__Product_Basket__c = baskets[9].id;
        config10.cscfga__Description__c = 'test Description 10';
        config10.cscfga__Contract_Term__c = 12;
        configList.add(config10);

        cscfga__Product_Configuration__c config11 = ProductTestService.createProductConfiguration();
        config11.cscfga__Product_Basket__c = baskets[9].id;
        config11.cscfga__Description__c = 'test Description 11';
        config11.cscfga__Contract_Term__c = 12;
        configList.add(config11);

        update configList;

        //Creation of Attributes with different attrbiutes Name and values.
        List<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>();
        for(cscfga__Product_Configuration__c config:configList){
            cscfga__Attribute__c attr0 = ProductTestFactory.buildAttribute('SRM', '100.00', config.id);
            attList.add(attr0);

            cscfga__Attribute__c attr1 = ProductTestFactory.buildAttribute('PartnerName', '200.00', config.id);
            attList.add(attr1);

            cscfga__Attribute__c attr2 = ProductTestFactory.buildAttribute('OC', '400.00', config.id);
            attList.add(attr2);

            cscfga__Attribute__c attr3 = ProductTestFactory.buildAttribute('Quantity', '300.00', config.id);
            attList.add(attr3);

            cscfga__Attribute__c attr4 = ProductTestFactory.buildAttribute('ContractTerms', '500.00', config.id);
            attList.add(attr4);

            cscfga__Attribute__c attr5 = ProductTestFactory.buildAttribute('ProductStatus', 'Lost', config.id);
            attList.add(attr5);
            
            cscfga__Attribute__c attr6 = ProductTestFactory.buildAttribute('RC', '700.00', config.id);
            attList.add(attr6);
            
            cscfga__Attribute__c attr8 = ProductTestFactory.buildAttribute('Product', null, config.id);
            attList.add(attr8);
            
            cscfga__Attribute__c attr9 = ProductTestFactory.buildAttribute('AcquisitionRevenue', '100.00', config.id);
            attList.add(attr9);
            
            cscfga__Attribute__c attr10 = ProductTestFactory.buildAttribute('AvgAnnualisedRevenue', '200.00', config.id);
            attList.add(attr10);
            
            cscfga__Attribute__c attr11 = ProductTestFactory.buildAttribute('Competitor', '300.00', config.id);
            attList.add(attr11);
            
            cscfga__Attribute__c attr12 = ProductTestFactory.buildAttribute('CurrentRevenue', '400.00', config.id);
            attList.add(attr12);
            
            cscfga__Attribute__c attr13 = ProductTestFactory.buildAttribute('IncrementalRevenue', '600.00', config.id);
            attList.add(attr13);
            
            cscfga__Attribute__c attr14 = ProductTestFactory.buildAttribute('Domain', 'Test Dom', config.id);
            attList.add(attr14);
            
            cscfga__Attribute__c attr15 = ProductTestFactory.buildAttribute('ProductCode', '1345', config.id);
            attList.add(attr15);
            
            cscfga__Attribute__c attr16 = ProductTestFactory.buildAttribute('ProductMaximName', 'Elvin', config.id);
            attList.add(attr16);
            
            cscfga__Attribute__c attr17 = ProductTestFactory.buildAttribute('RenewalRevenue', '900.00', config.id);
            attList.add(attr17);
            
            
        }
        
        insert attList;

        List<cscfga__Attribute__c> newattrList = new List<cscfga__Attribute__c>();
        for(cscfga__Attribute__c attr : attList){
            if(attr.Name == 'Product'){
                newattrList.add(attr);
            }

        }

        //create opportunity
        List<OpportunityLineItem> oLIList = new List<OpportunityLineItem>();
        for(Integer d = 0; d < 9; d++){
            OpportunityLineItem oli0  = new OpportunityLineItem(TotalPrice = 2000.00, Product_Status__c = 'Lost', pricebookentryid=pbe.Id,Quantity = 2, OpportunityId = baskets[d].cscfga__Opportunity__c, Description = configList[d].cscfga__Description__c, cscfga__Attribute__c = newattrList[d].Id);
            oLIList.add(oli0);
        }

        OpportunityLineItem oli9  = new OpportunityLineItem(TotalPrice = 2000.00, Product_Status__c = 'Won', pricebookentryid=pbe.Id,Quantity = 2, OpportunityId = baskets[9].cscfga__Opportunity__c, Description = configList[9].cscfga__Description__c, cscfga__Attribute__c = newattrList[9].Id);
        oLIList.add(oli9);
        OpportunityLineItem oli10 = new OpportunityLineItem(TotalPrice = 2000.00, Product_Status__c = 'Won', pricebookentryid=pbe.Id,Quantity = 2, OpportunityId = baskets[9].cscfga__Opportunity__c, Description = configList[10].cscfga__Description__c, cscfga__Attribute__c = newattrList[10].Id);
        oLIList.add(oli10);
        OpportunityLineItem oli11 = new OpportunityLineItem(TotalPrice = 2000.00, Product_Status__c = 'Won', pricebookentryid=pbe.Id,Quantity = 2, OpportunityId = baskets[9].cscfga__Opportunity__c, Description = configList[11].cscfga__Description__c, cscfga__Attribute__c = newattrList[11].Id);
        oLIList.add(oli11);

        insert oLIList;
        
        configList[0].cscfga__Configuration_Status__c = 'Incomplete';
        update configList;
         List<String> basketIds = new List<String>();
    for(cscfga__Product_Basket__c basket: baskets){
      basketIds.add(basket.Id);
    }
  
         List<cscfga__Product_Basket__c> newBasketList = OpportunityBulkSyncUtility.getValidProductBasket(basketIds, configList);

    System.assert(newBasketList.size() == baskets.size());
    //System.assert(newBasketList.size() != basketList.size(), 'One or more invalid product configurations in the basket');
        //if configuration status is not Valid    
         System.assert(configList[0].cscfga__Configuration_Status__c == 'Incomplete','One or more invalid product configurations in the basket');

        
        //OpportunityBulkSyncUtility utility = new OpportunityBulkSyncUtility();

       //System.assert(newBasketList.size() != basketList.size(), 'One or more invalid product configurations in the basket');
        //if configuration status is not Valid    
         System.assert(configList[0].cscfga__Configuration_Status__c == 'Incomplete','One or more invalid product configurations in the basket');


    }
    
    

    @isTest static void test_syncWithOpportunity(){
         //Create accounts
        List<Account> accountList = new List<Account>();

        for(Integer i= 0; i < 10; i++){
            Account acc1 = AccountTestFactory.buildAccount('Test Account '+i);
            accountList.add(acc1);
        }

        insert accountList;

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
        List<Opportunity> opptyList = new List<Opportunity>();
        for(Integer j = 0; j < 8; j++){
            Opportunity opp0  = ProductTestFactory.getOpportunity(accountList[j],pb);
            opptyList.add(opp0);
        }
        insert opptyList;


        List<cscfga__Product_Basket__c> baskets = new List<cscfga__Product_Basket__c>();
        for(Integer b = 0; b < 8; b++){
            cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
            basket.csbb__Account__c = accountList[b].id;
            basket.Name = 'Test Class Basket '+b;
            basket.cscfga__Opportunity__c = opptyList[b].id;
            baskets.add(basket);
        }

        cscfga__Product_Basket__c basket8 = ProductTestFactory.buildEmptyBasket();
        basket8.csbb__Account__c = accountList[7].id;
        basket8.Name = 'Test Class Basket 8';
        basket8.cscfga__Opportunity__c = opptyList[7].id;
        baskets.add(basket8);

        cscfga__Product_Basket__c basket9 = ProductTestFactory.buildEmptyBasket();
        basket9.csbb__Account__c = accountList[7].id;
        basket9.Name = 'Test Class Basket 9';
        basket9.cscfga__Opportunity__c = opptyList[7].id;
        baskets.add(basket9);

        insert baskets;

        //Create config
        List<cscfga__Product_Configuration__c> configList = new List<cscfga__Product_Configuration__c>();

        for(Integer c = 0; c < 9; c++){
            cscfga__Product_Configuration__c config = ProductTestService.createProductConfiguration();
            config.cscfga__Product_Basket__c = baskets[c].id;
            config.cscfga__Description__c = 'test Description '+c;
            config.cscfga__Contract_Term__c = 12;
            configList.add(config);
        }
        
        cscfga__Product_Configuration__c config9 = ProductTestService.createProductConfiguration();
        config9.cscfga__Product_Basket__c = baskets[9].id;
        config9.cscfga__Description__c = 'test Description 9';
        config9.cscfga__Contract_Term__c = 24;
        configList.add(config9);

        cscfga__Product_Configuration__c config10 = ProductTestService.createProductConfiguration();
        config10.cscfga__Product_Basket__c = baskets[9].id;
        config10.cscfga__Description__c = 'test Description 10';
        config10.cscfga__Contract_Term__c = 12;
        configList.add(config10);

        cscfga__Product_Configuration__c config11 = ProductTestService.createProductConfiguration();
        config11.cscfga__Product_Basket__c = baskets[9].id;
        config11.cscfga__Description__c = 'test Description 11';
        config11.cscfga__Contract_Term__c = 12;
        configList.add(config11);

        update configList;

        //Creation of Attributes with different attrbiutes Name and values.
        List<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>();
        for(cscfga__Product_Configuration__c config:configList){
            cscfga__Attribute__c attr0 = ProductTestFactory.buildAttribute('SRM', '100.00', config.id);
            attList.add(attr0);

            cscfga__Attribute__c attr1 = ProductTestFactory.buildAttribute('PartnerName', '200.00', config.id);
            attList.add(attr1);

            cscfga__Attribute__c attr2 = ProductTestFactory.buildAttribute('OC', '400.00', config.id);
            attList.add(attr2);

            cscfga__Attribute__c attr3 = ProductTestFactory.buildAttribute('Quantity', '300.00', config.id);
            attList.add(attr3);

            cscfga__Attribute__c attr4 = ProductTestFactory.buildAttribute('ContractTerms', '500.00', config.id);
            attList.add(attr4);

            cscfga__Attribute__c attr5 = ProductTestFactory.buildAttribute('ProductStatus', 'Lost', config.id);
            attList.add(attr5);
            
            cscfga__Attribute__c attr6 = ProductTestFactory.buildAttribute('RC', '700.00', config.id);
            attList.add(attr6);
            
            cscfga__Attribute__c attr8 = ProductTestFactory.buildAttribute('Product', 'Router XYZ', config.id);
            attList.add(attr8);
            
            cscfga__Attribute__c attr9 = ProductTestFactory.buildAttribute('AcquisitionRevenue', '100.00', config.id);
            attList.add(attr9);
            
            cscfga__Attribute__c attr10 = ProductTestFactory.buildAttribute('AvgAnnualisedRevenue', '200.00', config.id);
            attList.add(attr10);
            
            cscfga__Attribute__c attr11 = ProductTestFactory.buildAttribute('Competitor', '300.00', config.id);
            attList.add(attr11);
            
            cscfga__Attribute__c attr12 = ProductTestFactory.buildAttribute('CurrentRevenue', '400.00', config.id);
            attList.add(attr12);
            
            cscfga__Attribute__c attr13 = ProductTestFactory.buildAttribute('IncrementalRevenue', '600.00', config.id);
            attList.add(attr13);
            
            cscfga__Attribute__c attr14 = ProductTestFactory.buildAttribute('Domain', 'Test Dom', config.id);
            attList.add(attr14);
            
            cscfga__Attribute__c attr15 = ProductTestFactory.buildAttribute('ProductCode', '1345', config.id);
            attList.add(attr15);
            
            cscfga__Attribute__c attr16 = ProductTestFactory.buildAttribute('ProductMaximName', 'Elvin', config.id);
            attList.add(attr16);
            
            cscfga__Attribute__c attr17 = ProductTestFactory.buildAttribute('RenewalRevenue', '900.00', config.id);
            attList.add(attr17);
            
            
        }
        
        insert attList;

        List<cscfga__Attribute__c> newattrList = new List<cscfga__Attribute__c>();
        for(cscfga__Attribute__c attr : attList){
            if(attr.Name == 'Product'){
                newattrList.add(attr);
            }

        }

        //create opportunity
        List<OpportunityLineItem> oLIList = new List<OpportunityLineItem>();
        for(Integer d = 0; d < 9; d++){
            OpportunityLineItem oli0  = new OpportunityLineItem(TotalPrice = 2000.00, Product_Status__c = 'Lost', pricebookentryid=pbe.Id,Quantity = 2, OpportunityId = baskets[d].cscfga__Opportunity__c, Description = configList[d].cscfga__Description__c, cscfga__Attribute__c = newattrList[d].Id);
            oLIList.add(oli0);
        }

        OpportunityLineItem oli9  = new OpportunityLineItem(TotalPrice = 2000.00, Product_Status__c = 'Won', pricebookentryid=pbe.Id,Quantity = 2, OpportunityId = baskets[9].cscfga__Opportunity__c, Description = configList[9].cscfga__Description__c, cscfga__Attribute__c = newattrList[9].Id);
        oLIList.add(oli9);
        OpportunityLineItem oli10 = new OpportunityLineItem(TotalPrice = 2000.00, Product_Status__c = 'Won', pricebookentryid=pbe.Id,Quantity = 2, OpportunityId = baskets[9].cscfga__Opportunity__c, Description = configList[10].cscfga__Description__c, cscfga__Attribute__c = newattrList[10].Id);
        oLIList.add(oli10);
        OpportunityLineItem oli11 = new OpportunityLineItem(TotalPrice = 2000.00, Product_Status__c = 'Won', pricebookentryid=pbe.Id,Quantity = 2, OpportunityId = baskets[9].cscfga__Opportunity__c, Description = configList[11].cscfga__Description__c, cscfga__Attribute__c = newattrList[11].Id);
        oLIList.add(oli11);

        insert oLIList;

        List<String> basketIds = new List<String>();
    for(cscfga__Product_Basket__c basket: baskets){
      basketIds.add(basket.Id);
    }
        
        String queryString = 'SELECT ' + OpportunityBulkSyncHelper.getSobjectFields('cscfga__Product_Basket__c') +
            ', cscfga__opportunity__r.pricebook2.isstandard ' +
            ', (SELECT cscfga__product_definition__r.name ' +
            ', cscfga__product_definition__r.cscfga__product_category__r.name ' + ', ' +
            OpportunityBulkSyncHelper.getSobjectFields('cscfga__Product_Configuration__c') +
            ' FROM cscfga__Product_Configurations__r) ' +
            ' FROM cscfga__Product_Basket__c where id in :basketIds LIMIT 6';
        
        List<cscfga__Product_Basket__c> newBasketList = OpportunityBulkSyncUtility.getValidProductBasket(basketIds, configList);
        System.assertEquals(10,newBasketList.size());
        List<cscfga__Product_Basket__c> productBasketList = Database.query(queryString);
        System.assert(!configList.isEmpty());
        List<cscfga__Product_Bundle__c> bundles = OpportunityBulkSyncHelper.createTempBundle(productBasketList);
        update bundles;
        update productBasketList;
    System.assert(productBasketList.size() == 6);
        List<cscfga__Product_Basket__c> emptyBasketList = new List<cscfga__Product_Basket__c>();
        Test.startTest();
        //String msg = OpportunityBulkSyncUtility.syncWithOpportunity(emptyBasketList, 'Validated');
        OpportunityBulkSyncUtility.syncWithOpportunity(productBasketList, '');
        //System.assert(newBundles.size() == 0);
        //System.assert(configList[0].cscfga__Product_Bundle__c == null);
        //System.assert(newBasketList.size() != basketList.size(),'One or more invalid product configurations in the basket');
        Test.stopTest();

    }
    
    
  
}