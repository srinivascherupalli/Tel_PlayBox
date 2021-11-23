/**
 * Class for custom button send proposal test.
 */
@isTest
public class CustomButtonSendProposalTest {
    
    @isTest static void performActionTest() {

        disableCSTrigger();
        createCustomSettingValues();
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        insert acc;
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithRealConfigVal(acc);
        basket.csordtelcoa__Basket_Stage__c='Commercial Configuration';
        basket.cscfga__Basket_Status__c = 'Valid';
        update basket;
        
        Id stdPb = Test.getStandardPricebookId();
        ProductTestService.createPriceBookForBasket(basket,acc,stdPb);
        
        Test.startTest();
        CustomButtonSendProposal newCustSendProposal = new CustomButtonSendProposal();
        newCustSendProposal.performAction(basket.Id);
        Test.stopTest();

        //cscfga__Product_Basket__c basket1 = [SELECT Id,csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c WHERE ID = :basket.Id];
        //System.assertEquals('Proposal Sent', basket1.csordtelcoa__Basket_Stage__c);

    }
    
    static void disableCSTrigger() {
        //Disable the trigger through Orders & Subscriptions Options Custom settings
        csordtelcoa__Orders_Subscriptions_Options__c subsSettings = new csordtelcoa__Orders_Subscriptions_Options__c() ; 
        subsSettings.SetupOwnerId = Userinfo.getOrganizationId();
        subsSettings.csordtelcoa__Disable_Triggers__c = True ; 
        subsSettings.csordtelcoa__Opportunity_Stages_creating_orders__c='Closed Won';
        insert subsSettings ; 
    }
    
    static void createCustomSettingValues() { 
        CustomConfigurationOptions__c customSetting = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Proposal Sent', Opportunity_Stage__c = 'Negotiation/Review'); 
        customSetting.Name = 'Proposal Sent';
        customSetting.External_Id__c = 'CCO_1';
        insert customSetting;

        CustomConfigurationOptions__c configOptions3 = new CustomConfigurationOptions__c();
        configOptions3.Enrichment_Basket_Stage__c = 'Commercial Configuration';
        configOptions3.External_Id__c = '9ExternalIdtest3';
        configOptions3.Name = 'CommercialConfiguration';
        configOptions3.Opportunity_Stage__c='Develop';
    insert configOptions3;        
    }
    
    @isTest static void performActionTestWithSeeAllData() {
        disableCSTrigger();
        createCustomSettingValues();
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        insert acc;
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithRealConfigVal(acc);
        Id stdPb = Test.getStandardPricebookId();
        ProductTestService.createPriceBookForBasketWithOppStage(basket,acc,stdPb);
        basket.csordtelcoa__Basket_Stage__c='Commercial Configuration';
        basket.cscfga__Basket_Status__c = 'Valid';
        basket.cscfga__total_contract_value__c = 1000;
        update basket;
        
        //cscfga__Product_Basket__c basket = [SELECT Id,csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c WHERE cscfga__Basket_Status__c = 'Valid' AND cscfga__Opportunity__r.StageName = 'Negotiation/Review' LIMIT 1];
        Test.startTest();
        CustomButtonSendProposal newCustSendProposal = new CustomButtonSendProposal();
        newCustSendProposal.performAction(basket.Id);
        Test.stopTest();
    }
    
    @isTest static void performActionTestWithInvalidProduct() {
        disableCSTrigger();
        createCustomSettingValues();
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        insert acc;
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithRealConfigVal(acc);
        basket.csordtelcoa__Basket_Stage__c='Commercial Configuration';
        update basket;
        
        cscfga__Product_Configuration__c config = [SELECT Id FROM cscfga__Product_Configuration__c WHERE cscfga__product_basket__c = : basket.Id];
        config.cscfga__Configuration_Status__c = 'Incomplete';
        update config;
        
        Id stdPb = Test.getStandardPricebookId();
        ProductTestService.createPriceBookForBasket(basket,acc,stdPb);
        
        Test.startTest();
        CustomButtonSendProposal newCustSendProposal = new CustomButtonSendProposal();
        newCustSendProposal.performAction(basket.Id);
        Test.stopTest();
    }
}