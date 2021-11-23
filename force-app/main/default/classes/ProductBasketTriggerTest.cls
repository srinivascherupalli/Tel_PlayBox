/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-22-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
private class ProductBasketTriggerTest
{
    
    @isTest 
    static void insertBasketSimpleTest() {

        createCustomSettingEnrichment();
        Account acc = new Account(Name='Test Account');
        
        Test.startTest();
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithRealConfigVal(acc);
        cscfga__Product_Basket__c bb = [Select Id, Customer_Request_Date__c from cscfga__Product_Basket__c where id=:basket.id LIMIT 1];    
        Test.stopTest();
        
        System.assertEquals(basket.Id, bb.Id); 

    }
    
    @isTest 
    static void updateBasketSimpleTest() {
        string testName = 'Basket for testing';
        createCustomSettingEnrichment();
        Account acc = new Account(Name='Test Account');
        insert acc;
        Opportunity opp = new Opportunity (Name='TestOpp', Account = acc, Product_Domain__c='MOBILES', Description='test',StageName='Define', CloseDate=Date.today());
        insert opp;
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithRealConfigVal(acc);
        basket.cscfga__Opportunity__c = opp.Id;
        
        Test.startTest();
        basket.Name = testName;
        update basket;
        cscfga__Product_Basket__c bb = [Select Id, Name, Customer_Request_Date__c from cscfga__Product_Basket__c where id=:basket.id LIMIT 1];    
        Test.stopTest();
        
        System.assertEquals(bb.Name, testName); 

    }

    @isTest
    static void insertBasketHandler() {
        createCustomSettingEnrichment();
        Account acc = new Account(Name='Test Account');
        insert acc;        
        Test.startTest();
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithRealConfigValwithOpty(acc);//fdr fix by shubhi
        cscfga__Product_Basket__c bb = [Select Id, Primary_Basket__c from cscfga__Product_Basket__c where id=:basket.id LIMIT 1];    
        Test.stopTest();
        
        // check if first basket and set to Primary_Basket__c
        System.assertEquals(bb.Primary_Basket__c, true);
    }
    
    @isTest
    static void beforeUpdateBasketHandler() {
        createCustomSettingEnrichment();
        Account acc = new Account(Name='Test Account');
        insert acc;
        Opportunity opp = new Opportunity (Name='TestOpp', Account = acc, Product_Domain__c='MOBILES', Description='test',StageName='Define', CloseDate=Date.today());
        insert opp;
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithRealConfigVal(acc);
        basket.cscfga__Opportunity__c = opp.Id;
        basket.csbb__Synchronised_With_Opportunity__c = true;
        Test.startTest();
        basket.csordtelcoa__Basket_Stage__c = 'Contract Accepted';
        update basket;
        cscfga__Product_Basket__c bb = [Select Id, csbb__Synchronised_With_Opportunity__c from cscfga__Product_Basket__c where id=:basket.id LIMIT 1];    
        Test.stopTest();
        
        // with basket stage changed to Contract accepted set sync to true
        System.assertEquals(bb.csbb__Synchronised_With_Opportunity__c, true);
    }
    
    @isTest
    static void afterUpdateBasketHandler() {
        createCustomSettingEnrichment();
        Account acc = new Account(Name='Test Account');
        insert acc;
        Opportunity opp = new Opportunity (Name='TestOpp', Account = acc, Product_Domain__c='MOBILES', Description='test',StageName='Define', CloseDate=Date.today());
        insert opp;
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithRealConfigVal(acc);
        basket.cscfga__Opportunity__c = opp.Id;       
        Test.startTest();
        basket.csordtelcoa__Basket_Stage__c = 'Contract Accepted';
        basket.cscfga__Basket_Status__c = 'Valid';
        basket.csbb__Synchronised_With_Opportunity__c = true;
        update basket;
        cscfga__Product_Basket__c bb = [Select Id, csbb__Synchronised_With_Opportunity__c from cscfga__Product_Basket__c where id=:basket.id LIMIT 1];    
        Test.stopTest();
        
        // with basket stage changed to Contract accepted set sync to true
        System.assertEquals(bb.csbb__Synchronised_With_Opportunity__c, true);
    }
    
    @isTest
    static void insertSecondPrimaryBasketBasket() {
        Test.startTest();
        createCustomSettingEnrichment();
        Account acc = new Account(Name='Test Account');
        insert acc;
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithRealConfigValwithOpty(acc);//fdr fix by shubhi
        cscfga__Product_Basket__c secondBasket = new cscfga__Product_Basket__c();
        secondBasket.Primary_Basket__c = true;
        secondBasket.cscfga__Opportunity__c = basket.cscfga__Opportunity__c;
        insert secondBasket;
        cscfga__Product_Basket__c bb = [Select Id, Primary_Basket__c from cscfga__Product_Basket__c where id=:secondBasket.id LIMIT 1];    
        Test.stopTest();
        
        // check if second basket status is false
        System.assertEquals(bb.Primary_Basket__c, false);
    }

    static void createCustomSettingEnrichment() {
 
        CustomConfigurationOptions__c customSetting = new CustomConfigurationOptions__c(MarketableOfferList__c = 'test config,Business IP'); 
        customSetting.Name = 'MarketableOfferList';
        customSetting.External_Id__c = '1001';
        insert customSetting;
    }

    @isTest
    static void afterUpdateBasketHandlerTest2() {
        createCustomSettingEnrichment();
        Account acc = new Account(Name='Test Account');
        insert acc;
        Opportunity opp = new Opportunity (Name='TestOpp', Account = acc, Product_Domain__c='MOBILES', Description='test',StageName='Define', CloseDate=Date.today());
        insert opp;
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithRealConfigVal(acc);
        basket.cscfga__Opportunity__c = opp.Id;
        
        basket.Primary_Basket__c = true;
        //insert basket;

        Test.startTest();

        basket.csordtelcoa__Basket_Stage__c = 'Draft';
        basket.cscfga__Basket_Status__c = 'Valid';
        update basket;
        
        Test.stopTest();
        
        cscfga__Product_Basket__c bb = [Select Id, csordtelcoa__Basket_Stage__c from cscfga__Product_Basket__c where id=:basket.id LIMIT 1];    
        System.assertEquals(bb.csordtelcoa__Basket_Stage__c, 'Draft');
    }
}