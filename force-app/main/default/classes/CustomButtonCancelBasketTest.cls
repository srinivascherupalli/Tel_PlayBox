@isTest
public class CustomButtonCancelBasketTest {
	@isTest static void performActionTest_ClosedWon() {
        createCustomSettingClosedWon();
        createCustomSettingEnrichment();
        Account acc = new Account(Name='Test Account');
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(acc);
        basket.csordtelcoa__Basket_Stage__c='Draft';
        update basket;
        
        //Enrich basket on success condition
        Test.startTest();
        CustomButtonCancelBasket cancelBasket = new CustomButtonCancelBasket();
        cancelBasket.performAction(basket.Id);
        Test.stopTest();
    }
    
    @isTest static void performActionTest_NotClosedWon() {
        createCustomSettingEnrichment();
        Account acc = new Account(Name='Test Account');
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(acc);
        basket.csordtelcoa__Basket_Stage__c='Draft';
        update basket;
        
        //Enrich basket on success condition
        Test.startTest();
        CustomButtonCancelBasket cancelBasket = new CustomButtonCancelBasket();
        cancelBasket.performAction(basket.Id);
        Test.stopTest();
    }
    
    @isTest static void performActionTestCancelled() {
        disableCSTrigger();
        createCustomSettingEnrichment();
        createCustomSettingClosedWon();
        createCustomSettingCancelled();
        Account acc = new Account(Name='Awesome Account');
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(acc);
        basket.csordtelcoa__Basket_Stage__c = 'Cancelled';
        update basket;
        
        //Enrich basket when basket stage is closed won
        Test.startTest();
        CustomButtonCancelBasket cancelBasket = new CustomButtonCancelBasket();
        cancelBasket.performAction(basket.Id);
        Test.stopTest();
        
        cscfga__Product_Basket__c basket1 = [SELECT Id,csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c WHERE ID = :basket.Id];
        System.assertEquals('Cancelled', basket1.csordtelcoa__Basket_Stage__c);
    }
    
    @isTest static void performActionTestNotCancelled() {
        disableCSTrigger();
        createCustomSettingEnrichment();
        createCustomSettingClosedWon();
        createCustomSettingCancelled();
        Account acc = new Account(Name='Awesome Account');
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(acc);
        basket.csordtelcoa__Basket_Stage__c = '';
        update basket;
        
        //Enrich basket when basket stage is closed won
        Test.startTest();
        CustomButtonCancelBasket cancelBasket = new CustomButtonCancelBasket();
        cancelBasket.performAction(basket.Id);
        Test.stopTest();
    }
    
    //Negative Test Condition
    @isTest static void performActionTestCancelledNegativeCondition()
    {
        disableCSTrigger();
        createCustomSettingNotClosedWon();
        createCustomSettinNotCancelBasket();
        //createCustomSettingCancelled();
        Account acc = new Account(Name='Awesome Account');
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(acc);
        basket.csordtelcoa__Basket_Stage__c = 'Cancelled';
        update basket;
        
        //Enrich basket when basket stage is closed won
        Test.startTest();
        CustomButtonCancelBasket cancelBasket = new CustomButtonCancelBasket();
        cancelBasket.performAction(basket.Id);
        Test.stopTest();
        
        cscfga__Product_Basket__c basket1 = [SELECT Id,csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c WHERE ID = :basket.Id];
        System.assertEquals('Cancelled', basket1.csordtelcoa__Basket_Stage__c);
    }

    static void disableCSTrigger() {
        //Disable the trigger through Orders & Subscriptions Options Custom settings
        csordtelcoa__Orders_Subscriptions_Options__c subsSettings = new csordtelcoa__Orders_Subscriptions_Options__c() ; 
        subsSettings.SetupOwnerId = Userinfo.getOrganizationId();
        subsSettings.csordtelcoa__Disable_Triggers__c = True ; 
        subsSettings.csordtelcoa__Opportunity_Stages_creating_orders__c='Valid';
        insert subsSettings ;
    }
    
    static void createCustomSettingEnrichment() {
        //Custom settings for In Enrichment
        CustomConfigurationOptions__c customSetting = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Service Detailing'); 
        customSetting.Name = 'ServiceDetailing';
        customSetting.External_Id__c = 'CCO_T_1';
        insert customSetting;
    }
    
    static void createCustomSettingClosedWon() {
        //Custom settings for Closed Won
        CustomConfigurationOptions__c customSetting = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Validated'); 
        customSetting.Name = 'Valid';
        customSetting.External_Id__c = 'CCO_T_2';
        insert customSetting;
    }
    
    static void createCustomSettingCancelled() {
        //Custom settings for Cancelled
        CustomConfigurationOptions__c customSetting = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Cancelled');
        customSetting.Name = 'CancelBasket';
        customSetting.External_Id__c = 'CCO_T_3';
        insert customSetting;
    }
    static void createCustomSettingNotClosedWon() {
        //Custom settings for Closed Won
        CustomConfigurationOptions__c customSetting = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'NotClosedWon'); 
        customSetting.Name = 'ClosedWon';
        customSetting.External_Id__c = 'CCO_T_4';
        insert customSetting;
    }
    
    static void createCustomSettinNotCancelBasket() {
        //Custom settings for Cancelled
        CustomConfigurationOptions__c customSetting = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'NotCancelBasket');
        customSetting.Name = 'CancelBasket';
        customSetting.External_Id__c = 'CCO_T_5';
        insert customSetting;
    }
}