/**
 * Class for custom button send contract test.
 */
@isTest
public class CustomButtonSendContractTest {

    @isTest static void performActionTest() {

        disableCSTrigger();
        createCustomSettingValues();
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        insert acc;
        cscfga__Product_Basket__c basket = ProductTestService.getNewBasketWithRealConfigVal(acc);
        basket.csordtelcoa__Basket_Stage__c='Commercial Configuration';
        update basket;
        
        Id stdPb = Test.getStandardPricebookId();
        ProductTestService.createPriceBookForBasket(basket,acc,stdPb);
        
        Test.startTest();
        CustomButtonSendContract newCustSendContract = new CustomButtonSendContract();
        newCustSendContract.performAction(basket.Id);
        Test.stopTest();

        //cscfga__Product_Basket__c basket1 = [SELECT Id,csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c WHERE ID = :basket.Id];
        //System.assertEquals('Contract Sent', basket1.csordtelcoa__Basket_Stage__c);

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
        CustomConfigurationOptions__c customSetting = new CustomConfigurationOptions__c(Enrichment_Basket_Stage__c = 'Contract Sent', Opportunity_Stage__c = 'Negotiation/Review'); 
        customSetting.Name = 'Contract Sent';
        customSetting.External_Id__c = 'CCO_T_1';
        insert customSetting;        
    }
}