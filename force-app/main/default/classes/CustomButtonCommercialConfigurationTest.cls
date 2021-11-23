@isTest
public class CustomButtonCommercialConfigurationTest {
    
    @isTest static void performActionTest_serviceDetailing() {
        disableCSTrigger();
        createCustomSettingEnrichment();
        createCustomSettingClosedWon();
        createCustomSettingCancelled();
        createCustomSettingCommercialConfiguration();
        Account acc = new Account(Name='Test Account');
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(acc);
        basket.csordtelcoa__Basket_Stage__c = 'Enriched';
        update basket;
        
        //Enrich basket on success condition
        Test.startTest();
        CustomButtonCommercialConfiguration commConfig = new CustomButtonCommercialConfiguration();
        commConfig.performAction(basket.Id);
        Test.stopTest();

        cscfga__Product_Basket__c basket1 = [SELECT Id,csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c WHERE ID = :basket.Id];
        System.assertEquals('Commercial Configuration', basket1.csordtelcoa__Basket_Stage__c);
    }
    
    @isTest static void performActionTest_commercialConfig() {
        disableCSTrigger();
        createCustomSettingEnrichment();
        createCustomSettingClosedWon();
        createCustomSettingCancelled();
        createCustomSettingCommercialConfiguration();
        Account acc = new Account(Name='Test Account');
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(acc);
        basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        update basket;
        
        //Enrich basket on success condition
        Test.startTest();
        CustomButtonCommercialConfiguration commConfig = new CustomButtonCommercialConfiguration();
        commConfig.performAction(basket.Id);
        Test.stopTest();

        cscfga__Product_Basket__c basket1 = [SELECT Id,csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c WHERE ID = :basket.Id];
        System.assertEquals('Commercial Configuration', basket1.csordtelcoa__Basket_Stage__c);
    }
    
    @isTest static void performActionTest_blankConfig() {
        disableCSTrigger();
        createCustomSettingEnrichment();
        createCustomSettingClosedWon();
        createCustomSettingCancelled();
        createCustomSettingCommercialConfiguration();
        Account acc = new Account(Name='Test Account');
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(acc);
        basket.csordtelcoa__Basket_Stage__c = '';
        update basket;
        
        //Enrich basket on success condition
        Test.startTest();
        CustomButtonCommercialConfiguration commConfig = new CustomButtonCommercialConfiguration();
        commConfig.performAction(basket.Id);
        Test.stopTest();

        cscfga__Product_Basket__c basket1 = [SELECT Id,csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c WHERE ID = :basket.Id];
        System.assertEquals(null, basket1.csordtelcoa__Basket_Stage__c);
    }
    
    @isTest static void performActionTest_commercialConfiguration_noconfig() {
        disableCSTrigger();
        Account acc = new Account(Name='Test Account');
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(acc);
        basket.csordtelcoa__Basket_Stage__c = 'Draft';
        update basket;
        
        //Enrich basket on success condition
        Test.startTest();
        CustomButtonCommercialConfiguration commConfig = new CustomButtonCommercialConfiguration();
        commConfig.performAction(basket.Id);
        Test.stopTest();
        
        cscfga__Product_Basket__c basket1 = [SELECT Id,csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c WHERE ID = :basket.Id];
        System.assertEquals('Draft', basket1.csordtelcoa__Basket_Stage__c);
    }
    
    @isTest static void performActionTest_exception() {
        disableCSTrigger();
        createCustomSettingEnrichment();
        createCustomSettingClosedWon();
        createCustomSettingCancelled();
        createCustomSettingCommercialConfiguration();
        Account acc = new Account(Name='Test Account');
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithConfig(acc);
        basket.csordtelcoa__Basket_Stage__c = '';
        update basket;
        
        //Enrich basket on success condition
        Test.startTest();
        CustomButtonCommercialConfiguration.setStageCommercialConfiguration('Hello"');
        Test.stopTest();

        cscfga__Product_Basket__c basket1 = [SELECT Id,csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c WHERE ID = :basket.Id];
        System.assertEquals(null, basket1.csordtelcoa__Basket_Stage__c);
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
        CustomConfigurationOptions__c customSetting = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Enriched'); 
        customSetting.Name = 'ServiceDetailing';
        customSetting.External_Id__c = 'CCO_T_1';
        insert customSetting;
    }
    
    static void createCustomSettingClosedWon() {
        //Custom settings for Closed Won
        CustomConfigurationOptions__c customSetting = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Valid'); 
        customSetting.Name = 'ClosedWon';
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
    
    static void createCustomSettingCommercialConfiguration() {
        //Custom settings for Commercial Configuration
        CustomConfigurationOptions__c customSetting = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Commercial Configuration');
        customSetting.Name = 'CommercialConfiguration';
        customSetting.External_Id__c = 'CCO_T_4';
        insert customSetting;
    }
}